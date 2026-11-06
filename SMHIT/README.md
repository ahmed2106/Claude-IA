# SMHIT.GestionConventions

Extension AL **Business Central SaaS Cloud** pour la **gestion des conventions de maintenance et d'hygiène industrielle** de SMHIT.

> Migration du module On-Premise vers SaaS Cloud avec refonte complète : versioning des conventions, génération automatique des plannings d'intervention, contrôle d'invariants (annuel et mensuel via *buckets*), gestion des reports, audit complet.

---

## Sommaire

1. [Vision métier](#vision-métier)
2. [Architecture](#architecture)
3. [Modèle de données](#modèle-de-données)
4. [Concepts clés](#concepts-clés)
5. [Structure du projet](#structure-du-projet)
6. [Installation et déploiement](#installation-et-déploiement)
7. [Workflow utilisateur](#workflow-utilisateur)
8. [Permission Sets](#permission-sets)
9. [Migration des données existantes](#migration-des-données-existantes)
10. [Limites connues et évolutions](#limites-connues-et-évolutions)

---

## Vision métier

Une **convention** SMHIT est un contrat de service entre SMHIT et un client. Elle peut couvrir plusieurs sites (ex : un client Carrefour avec une dizaine d'hypermarchés) et plusieurs prestations (nettoyage, dératisation…).

**Chaque ligne de convention = un couple (site × service)** avec un nombre garanti d'interventions à l'année.

### Invariants fondamentaux

- **Invariant annuel (FORT)** : le nombre d'interventions par an défini dans la convention est **strict** et constant. Si 26/an alors toujours 26 sur l'année.
- **Invariant mensuel (FORT)** : la cadence mensuelle est constante. Si 2/mois, alors toujours 2/mois.
- **Débordement de fin de mois** : autorisé exceptionnellement vers le début du mois suivant (max 7 jours par défaut), **tracé** explicitement.
- **Immutabilité du passé** : un avenant n'agit **jamais** rétroactivement. Le passé est figé.

### Convention versionnée

| Concept | Stable | Exemple |
|---|---|---|
| N° contrat | ✅ Toujours stable | `CS25-0033` |
| Version | Incrémentée à chaque avenant | `V1`, `V2`, `V3`… |
| Date d'effet | Date à partir de laquelle la version s'applique | `2025-04-01` |

---

## Architecture

### Architecture hybride

Cette extension suit le principe **"étendre, pas remplacer"** :

```
┌────────────────────────────────────────────────────────────────┐
│  BC Application (Microsoft)                                    │
│  ┌─────────────────────────────────────────────┐               │
│  │  Module Service standard                    │               │
│  │  - Service Contract Header (5965)           │               │
│  │  - Service Contract Line (5964)             │               │
│  │  - Service Header / Service Item Line       │               │
│  └─────────────────────────────────────────────┘               │
└────────────────────────────────────────────────────────────────┘
                            ↑
                            │ extends (TableExtension)
┌────────────────────────────────────────────────────────────────┐
│  SMHIT.GestionConventions (50000-50149)                        │
│                                                                │
│  Tables custom : versioning, buckets, planning, audit          │
│  Codeunits     : moteurs métier                                │
│  Pages         : UI dédiée + extensions des pages standard     │
│  Role Center   : tableau de bord planificateur                 │
└────────────────────────────────────────────────────────────────┘
```

**Avantages** :
- Aucune duplication des fonctions standard (facturation Service Contract → ordres de service → facture client).
- Compatibilité maximale avec les futures mises à jour Microsoft.
- Pas de dépendance à des objets propriétaires.

### Range d'IDs

- Range utilisé : **50000-50149** (Per-Tenant Extension)
- Préfixe : `SMHIT`
- Convention de nommage : noms d'objets et de champs en **anglais sans accents** ; tous les *Captions* en **français avec accents**.

---

## Modèle de données

### Couche 1 — Référentiel

| Table | ID | Rôle |
|---|---|---|
| `SMHIT Calendar Header` / `Line` | 50100 / 50101 | Calendriers (LUN-VEN, LUN-SAM, DIMANCHE…) |
| `SMHIT Calculation Base` | 50102 | Bases de calcul (1S, 2S, M, Q…) |
| `SMHIT Holiday` | 50103 | Jours fériés (TN par défaut) |
| `SMHIT Transition Rule Setup` | 50105 | Matrice des règles d'avenant |

### Couche 2 — Convention versionnée

| Table | ID | Rôle |
|---|---|---|
| `Service Contract Header` + ext | 5965 / 50110 | Convention (numéro stable + statut SMHIT) |
| `Service Contract Line` + ext | 5964 / 50111 | Lignes (site × service × calendrier × Nb/an) |
| `SMHIT Convention Version` | 50111 | Versions successives (V1, V2…) |
| `SMHIT Conv. Amendment Log` | 50113 | Journal des avenants |

### Couche 3 — Planification

| Table | ID | Rôle |
|---|---|---|
| `SMHIT Planned Intervention` | 50120 | Intervention planifiée (table centrale) |
| `SMHIT Monthly Bucket` | 50121 | **Gardien d'invariant mensuel** |
| `SMHIT Intervention Log` | 50122 | Audit complet de chaque évènement |
| `SMHIT Postponement Request` | 50123 | Demandes de report client |

### Couche 4 — Setup et Cues

| Table | ID | Rôle |
|---|---|---|
| `SMHIT Setup` | 50130 | Singleton de paramétrage |
| `SMHIT Planner Cue` | 50140 | Compteurs visuels du Role Center |

---

## Concepts clés

### 1. Le Bucket mensuel (le gardien d'invariant)

Pour chaque couple **(convention × version × ligne × mois)**, un bucket matérialise :

- `Theoretical Quota` : quota prévu par le contrat pour ce mois
- `Consumed Quota` (FlowField) : nombre d'interventions effectivement comptées dans ce bucket
- `Overflow In` / `Overflow Out` : interventions débordées entrantes/sortantes
- `Has Violation` : vrai si le consommé sort des bornes Min/Max

**Décision métier importante** : lors d'un report qui change le mois calendaire, le bucket d'origine **reste celui du mois théorique initial**. L'intervention reste comptabilisée dans son mois "de droit", même si elle est exécutée en débordement. Cela protège l'invariant comptable.

### 2. Le Versioning des conventions

```
CS25-0033 (n° stable)
 ├── V1 : 2025-01-01 → 2025-03-31  [LOCKED]  (signature initiale, 26/an)
 ├── V2 : 2025-04-01 → 2025-08-31  [LOCKED]  (passage à 30/an)
 └── V3 : 2025-09-01 → ...         [ACTIVE]  (changement calendrier)
```

À chaque avenant :
1. La version précédente est **verrouillée** (`Locked = true`) et reçoit sa `End Effect Date`.
2. Une nouvelle version est créée avec une date d'effet **dans le futur**.
3. Les interventions **antérieures** à la date d'effet sont **figées** (`Locked = true`).
4. Les interventions **postérieures** sont régénérées selon la nouvelle règle.

### 3. La matrice de transition (règle de bascule)

Quand un avenant change quelque chose au cours du mois, comment traiter ce mois ?

| Type de changement | Règle par défaut | Logique |
|---|---|---|
| Augmentation quantité | **Immediate New** (Option B) | Nouveau rythme dès la date d'effet, plus d'interventions |
| Diminution quantité | **Pro Rata** (Option A) | Prorata strict, respecte le nouvel invariant |
| Changement calendrier | **Manual** (Option C) | Validation manuelle des nouvelles dates |
| Changement base | **Immediate New** | Nouveau rythme |
| Ajout périmètre | **Immediate New** | Génération immédiate |
| Retrait périmètre | **Immediate New** | Suppression immédiate des futures |
| Tarifaire pur | **Immediate New** | Aucun impact planning |

Ces règles sont **paramétrables** via `SMHIT Transition Rule Setup` et peuvent être surchargées au cas par cas.

### 4. L'algorithme de génération des dates

Le `SMHIT Planning Engine` répartit `N` interventions équitablement sur la période :

1. Calcul de l'intervalle théorique : `IntervalDays = TotalDays / N`
2. Pour chaque séquence `i` de 1 à N : `IdealDate = Start + (i - 0.5) × IntervalDays`
3. `SnapToActiveDay` : ajuste sur un jour actif du calendrier (en évitant les jours fériés si configuré)
4. Création de l'intervention avec `Initial Theoretical Date = ActualDate` (immuable)

---

## Structure du projet

```
SMHIT.GestionConventions/
├── app.json                        # Manifeste de l'extension
├── .vscode/                        # Config VS Code AL
├── src/
│   ├── Enums/                      # 11 énumérations métier (statuts, types…)
│   ├── Referentiel/                # Tables et pages calendriers/bases/fériés
│   ├── TableExt/                   # 4 extensions sur tables BC standard
│   ├── PageExt/                    # 4 extensions sur pages BC standard
│   ├── Convention/                 # Versioning + Codeunit cycle de vie
│   ├── Planning/                   # Cœur du moteur :
│   │                               #  - Moteur de génération
│   │                               #  - Buckets mensuels
│   │                               #  - Vérificateur d'invariants
│   │                               #  - Gestionnaire de reports
│   ├── Setup/                      # Setup + Install + Migration
│   ├── RoleCenter/                 # Tableau de bord planificateur + Profile
│   ├── Reports/                    # 4 rapports
│   └── Permissions/                # 4 permission sets
└── README.md                       # Ce fichier
```

---

## Installation et déploiement

### Prérequis

- Business Central Cloud (SaaS), version 24.0 ou supérieure
- Visual Studio Code + extension AL Language
- Environnement Sandbox pour les tests

### Compilation

```bash
# Dans VS Code
Ctrl+Shift+P → AL: Download symbols
Ctrl+Shift+P → AL: Package
```

### Publication

```bash
Ctrl+Shift+P → AL: Publish (Ctrl+F5)
```

L'extension dispose d'un `OnInstallAppPerCompany` qui initialise automatiquement :
- Les 5 calendriers types (LUN-VEN, LUN-SAM, LUN-JEU, DIMANCHE, JEUDI)
- Les 7 bases de calcul (1S, 2S, 3S, Q, M, 2M, T)
- Les 8 règles de transition par type de changement
- Les 9 jours fériés tunisiens de l'année courante
- L'instance singleton du Setup

---

## Workflow utilisateur

### 1. Création d'une convention

```
1. Service Contracts (BC standard) → New
2. Renseigner : Client, n°, période, type SMHIT
3. Ajouter les lignes (Site × Service) avec :
   - Calendrier (SMHIT Calendar Code)
   - Base de calcul (SMHIT Calculation Base)
   - Nb interventions / an (INVARIANT FORT)
   → Monthly Target / Min / Max sont calculés automatiquement
4. Action : "Signer (SMHIT) & générer planning"
   → Crée la Version V1
   → Génère les N interventions théoriques sur la période
   → Crée les buckets mensuels
```

### 2. Suivi quotidien (Role Center "Planificateur SMHIT")

Le Role Center affiche en permanence :
- Interventions du jour / des 7 prochains jours
- Manquées des 30 derniers jours (en rouge)
- Demandes de report en attente
- Violations de buckets (en rouge)
- Conventions actives / avenants en cours

### 3. Demande de report client

```
1. Liste interventions → sélectionner → "Demande de report"
2. Renseigner : canal (Email/Tel/Teams…), nom demandeur, date demandée, motif
3. Le système calcule :
   - Causes Overflow : vrai/faux selon le bucket
   - Requires Approval : vrai si débordement + setup l'exige
4. Si pas de débordement → auto-approuvé
   Sinon → status "New" en attente de validation manuelle
5. Validation : "Approuver" → applique le nouveau planning + log audit
```

### 4. Création d'un avenant

```
1. Convention → "Créer un avenant"
2. Choisir : type de changement, date d'effet, règle de transition
3. La nouvelle version (V2) est créée mais pas encore appliquée
4. Modifier les valeurs (ex: Nb annuel : 26 → 30)
5. Action : "Appliquer avenant"
   → Verrouille V1 et fige les interventions du passé
   → Régénère les interventions futures selon V2
   → Recalcule les buckets affectés
```

---

## Permission Sets

| Permission Set | Public visé | Droits |
|---|---|---|
| `SMHIT-ALL` | Administrateurs | Tout (RIMD) |
| `SMHIT-PLANNER` | Planificateurs | Lecture/écriture, **pas de suppression** des historiques |
| `SMHIT-TECHNICIAN` | Techniciens terrain | Lecture, mise à jour statuts uniquement |
| `SMHIT-READONLY` | Consultation | Lecture seule, rapports |

---

## Migration des données existantes

Le codeunit `SMHIT Migration Utilities` (50101) propose :

```al
// Reprend toutes les conventions existantes sans données SMHIT
SMHITMigrationUtilities.BackfillExistingConventions();
```

Effets :
1. Crée automatiquement une version `V1` pour chaque convention existante.
2. Renseigne les calendriers et bases de calcul par défaut sur les lignes.
3. Initialise les statuts SMHIT.

**Important** : la reprise des interventions historiques (passées) doit se faire via un autre process (import RapidStart ou Excel) car ces interventions sont par essence "verrouillées" et ne doivent pas être régénérées.

---

## Limites connues et évolutions

### Limites V1.0

- Les **layouts RDLC** des reports sont vides (BC génère un layout par défaut). À personnaliser via Report Builder ou Word Layout pour l'aspect final.
- L'**email parsing automatique** des demandes de report (ex : depuis Outlook) n'est pas implémenté ; la création reste manuelle ou via API.
- Les **notifications** (Notify On Missed / Notify On Violation) sont préparées dans le Setup mais le mécanisme d'envoi (Email Scenario) est à brancher selon les pratiques SMHIT.

### Évolutions possibles V1.1+

- Connecteur **Microsoft Graph / Outlook** pour ingestion automatique des emails de report
- Application mobile compagnon pour les techniciens (BC Mobile + extensions)
- Module **Power BI** sur les buckets pour analyse multi-clients
- Optimisation d'affectation des techniciens (algorithme de routage géographique)
- Génération automatique des **ordres de service** (Service Header) à J-X de chaque intervention

---

## Auteur & Support

Extension développée pour **SMHIT** dans le cadre de la migration BC On-Premise → SaaS Cloud.

Pour toute question technique ou demande d'évolution, contacter l'équipe BC SMHIT.
