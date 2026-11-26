# 📄 Document de présentation — Calcul du coût d'une intervention
## Projet SMHIT.GestionConventions — Extension Business Central SaaS

| | |
|---|---|
| **Document** | Spécification fonctionnelle et technique — Module coût d'intervention |
| **Version** | 1.0 (soumis à validation) |
| **Date** | 06/11/2026 |
| **Cible** | Microsoft Dynamics 365 Business Central Cloud (SaaS), runtime 17.0 / application 28.0 |
| **Périmètre** | Dératisation, désinsectisation et hygiène industrielle — contrats de service, interventions, feuilles de route, facturation |

---

## 1. Contexte métier

SMHIT est une société certifiée ISO (ISO 9001, ISO 14001, ISO 45001) prestataire de services de **dératisation / désinsectisation** sur des sites clients (ex : enseignes de grande distribution). Le cycle de vie d'une prestation :

```
CONVENTION (contrat de service, versionnée par avenants)
   └──► LIGNE DE CONVENTION = couple (site × service) avec un nombre garanti d'interventions/an
         └──► INTERVENTION PLANIFIÉE (date théorique, bucket mensuel, invariants)
               └──► ORDRE DE SERVICE (Service Header BC)
                     └──► FEUILLE DE ROUTE (tournée : 1 technicien, 1 camion, N visites)
                           └──► FACTURE DE SERVICE (facturation client)
```

**Objectif du module** : calculer le **coût réel de chaque intervention** en s'appuyant au maximum sur le standard BC, afin de mesurer la marge par prestation et piloter la rentabilité par client / site / zone.

---

## 2. Flux métier détaillé

### 2.0 Schéma visuel du flux

```
┌─────────────────┐    avenants     ┌──────────────────────────┐
│  CONVENTION     │◄───────────────►│  Version V1 → V2 → V3    │
│  (5965 + 50110) │   (verrouillée)  │  (50111)                 │
└────────┬────────┘                 └──────────────────────────┘
         │ lignes = site × service (Nb interventions/an)
         ▼
┌─────────────────────────┐     ┌─────────────────────────────┐
│ INTERVENTION 50120      │────►│ Bucket mensuel 50121        │
│ (date théorique, statut)│     │ (gardien d'invariant)       │
└───────────┬─────────────┘     └─────────────────────────────┘
            │ sélectionnée
            ▼
┌─────────────────────────┐     ┌─────────────────────────────┐
│ FEUILLE DE ROUTE 50154  │────►│ 1 technicien + 1 camion     │
│ (tournée, compteurs km) │     │ km = compteur fin − début   │
└───────────┬─────────────┘     └─────────────────────────────┘
            │ 1 ligne = 1 ordre de service
            ▼
┌─────────────────────────┐     ┌─────────────────────────────┐
│ ORDRE DE SERVICE 5900   │────►│ Service Lines 5902 :        │
│ (réf. intervention)     │     │ Resource + Item + G/L       │
└───────────┬─────────────┘     │ Coût = Σ "Line Cost"        │
            │ clôture (heures     └─────────────────────────────┘
            │ réelles + appâts)
            ▼
┌─────────────────────────┐
│ COÛT INTERVENTION       │────►  MO (50124) + Appâts + Véhicule (km)
│ (codeunit Cost Calc.)   │
└───────────┬─────────────┘
            ▼
┌─────────────────────────┐
│ FACTURE SERVICE         │────►  Marge = Prix contrat − Coût
└─────────────────────────┘
```


### 2.1 De la convention à l'intervention
1. Création de la convention dans **Service Contracts** (BC standard, table 5965, étendue par 50110).
2. Lignes de convention = site × service, avec calendrier, base de calcul et **nombre d'interventions/an (invariant fort)**.
3. À la signature : création de la version V1, génération des N interventions théoriques et des **buckets mensuels** (gardiens d'invariant, table 50121).
4. Chaque avenant crée une nouvelle version (V2, V3…) : le passé est verrouillé, le futur est régénéré (matrice de transition, table 50105).

### 2.2 De l'intervention à la feuille de route
1. Les interventions sélectionnées sont affectées à une **feuille de route** (table 50154) : 1 technicien, 1 camion, une demi-journée ou journée complète, avec compteurs kilométriques début/fin.
2. **Chaque ligne de feuille de route = un ordre de service (Service Header 5900)** qui référence une intervention (table 50120).
3. Le technicien réalise les visites et saisit les heures réelles (Time Sheet) et les consommables (appâts) depuis l'ordre de service.

### 2.3 De l'ordre de service à la facture
1. L'ordre de service est posté → **Service Invoice** (facturation standard BC).
2. Le coût de l'intervention (calculé par le module) est comparé au prix de vente du contrat → **marge**.

---

## 3. Schéma final de calcul du coût d'une intervention

### 3.1 Formule générale

```
┌────────────────────────────────────────────────────────────────────┐
│  COÛT TOTAL INTERVENTION =                                         │
│      COÛT MAIN D'ŒUVRE                                             │
│    + COÛT CONSOMMABLES (appâts / produits)                         │
│    + COÛT VÉHICULE (quote-part feuille de route)                   │
└────────────────────────────────────────────────────────────────────┘
```

### 3.2 Composante 1 — Main d'œuvre (imputation au temps réel, méthode ABC)

```
Coût MO = Σ (technicien i de l'équipe) × Heures réelles sur site × Taux horaire chargé i
```

| Donnée | Source |
|---|---|
| Équipe de l'intervention (plusieurs techniciens possibles) | Table custom **50124 SMHIT Intervention Team** |
| Heures réelles | Saisie à la clôture, alimentée par la **Time Sheet BC (5200)** |
| Taux horaire chargé | **Resource Card (5156) → Unit Cost** = (salaire + charges + frais généraux) / heures productives/an |

> Justification normative : l'**Activity-Based Costing (ABC)** et l'ISO 9001:2015 (approche processus, informations documentées) imposent d'imputer le coût à l'activité qui le consomme réellement → le **temps passé sur site**, et non une répartition forfaitaire par appât ou par zone.

### 3.3 Composante 2 — Consommables

```
Coût consommables = Σ (article) × Quantité consommée × Coût unitaire article
```

| Donnée | Source |
|---|---|
| Appâts / produits | **Service Line (5902) type = Item**, consommation postée via *Item Journal* |
| Coût unitaire | **Item Card (27)** — coût moyen / dernier prix d'achat (Item Ledger Entry) |

### 3.4 Composante 3 — Véhicule (coût variable uniquement)

```
Coût véhicule = Kilomètres totaux × Taux véhicule/km
Kilomètres totaux = Compteur fin − Compteur début   (table 50154)
```

| Donnée | Source |
|---|---|
| Km parcourus | Table **50154 SMHIT Route Sheet Line** (compteurs) |
| Taux/km | Paramétré dans **SMHIT Setup (50130)** = carburant + entretien + pneus |

> ⚠️ **Amortissement exclu** : les camions étant la propriété de la société et déjà amortis, le coût d'intervention intègre uniquement le **coût variable** (coût historique irrécupérable). La dotation aux amortissements reste en comptabilité générale.

### 3.5 Exemple chiffré

| Poste | Calcul | Coût |
|---|---|---|
| Main d'œuvre | 2 techniciens × 3 h réelles × 15 TND/h | 90,000 TND |
| Appâts / produits | 4 unités × 12,500 TND | 50,000 TND |
| Véhicule | 20 km × 2,500 TND/km | 50,000 TND |
| **COÛT TOTAL** | | **190,000 TND** |

**Marge = Prix facturé (contrat) − Coût total**

### 3.6 Chaîne de données

```
CONVENTION (5965 + ext 50110) ──► INTERVENTION 50120 ◄── ÉQUIPE 50124 (technicien × h × taux)
                                        │                        │
                                        ▼                        │
                              SERVICE HEADER 5900 ◄── FEUILLE DE ROUTE 50154 (camion, km)
                                        │
                              Service Lines 5902 : Resource + Item + G/L
                                        │
                              COÛT TOTAL = Σ "Line Cost" standard
                                        ▼
                              FACTURE SERVICE → Marge = Prix contrat − Coût
```

---

## 4. Modèle de données

### 4.1 Objets BC standard utilisés (maximum)

| Objet | Rôle |
|---|---|
| Service Contract Header 5965 / Line 5964 | Conventions et lignes (étendues, pas remplacées) |
| Service Header 5900 / Service Line 5902 | Ordre de service et composantes de coût (`Line Cost`) |
| Service Invoice | Facturation et marge |
| Resource 5156 / Time Sheet 5200 / Work Type 5202 | Techniciens, temps réel, taux horaires |
| Item 27 / Item Journal / Item Ledger Entry | Appâts, consommables, coûts articles |

### 4.2 Nouveaux objets custom (range 50100–50300)

| Table / Objet | ID | Statut | Rôle |
|---|---|---|---|
| `SMHIT Planned Intervention` | **50120** | ✅ créé | Table centrale : tous les champs de l'intervention (dates théorique/planifiée/réelle, bucket, statut, équipe, liens ordre de service / feuille de route / facture) |
| `SMHIT Intervention Status` (enum) | **50120** | ✅ créé | Planifiée, En cours, Réalisée, Manquée, Reportée, Annulée |
| `SMHIT Intervention Team` | **50124** | ✅ créé | Équipe : technicien × heures estimées/réelles × taux horaire → coût MO |
| `SMHIT Route Sheet Line` | **50154** | ✅ créé | Feuille de route : technicien, camion, compteurs km, statut, référence ordre de service + intervention, coût véhicule |
| `SMHIT Monthly Bucket` | 50121 | à développer | Gardien d'invariant mensuel |
| `SMHIT Convention Version` | 50111 | à développer | Versioning des conventions |
| `SMHIT Setup` | 50130 | à développer | Singleton : taux véhicule/km, seuils débordement, notifications |
| Codeunit `SMHIT Cost Calculator` | à définir | à développer | Calcule le coût total (MO + consommables + véhicule) |
| Codeunit `SMHIT Service Order Mgt` | à définir | à développer | Crée l'ordre de service + lignes de coût depuis l'intervention |

---

## 5. Paramétrage (Setup)

| Paramètre | Emplacement | Valeur par défaut |
|---|---|---|
| Taux véhicule / km (carburant + entretien) | SMHIT Setup 50130 | à définir avec la comptabilité |
| Taux horaire chargé par technicien | Resource Card → Unit Cost | selon paie + charges |
| Seuil de débordement de fin de mois | SMHIT Setup | 7 jours |
| Calendriers (LUN-VEN, LUN-SAM, DIMANCHE…) | 50100/50101 | 5 calendriers initialisés à l'installation |
| Bases de calcul (1S, 2S, M, Q…) | 50102 | 7 bases |
| Jours fériés (TN) | 50103 | 9 jours/an |
| Règles de transition des avenants | 50105 | 8 règles (Immediate New, Pro Rata, Manual) |

---

## 6. Normes et référentiels appliqués

| Référentiel | Application dans le projet |
|---|---|
| **ISO 9001:2015** | Approche processus + traçabilité : chaque intervention trace temps, consommables, coûts (audit log) |
| **ISO 14001** | Traçabilité des produits biocides/appâts (fiches de sécurité, déchets) |
| **ISO 45001** | Suivi du temps exposé des techniciens sur site |
| **ABC (Activity-Based Costing)** | Imputation de la main d'œuvre au temps réel passé, pas de répartition forfaitaire |
| **Comptabilité de gestion** | Coût d'intervention = coût variable (véhicule sans amortissement, déjà amorti) |

---

## 7. Workflow utilisateur (résumé)

1. **Planificateur** : signe la convention → génère le planning et les buckets.
2. **Planificateur** : construit les feuilles de route (technicien + camion + visites).
3. **Technicien** (mobile) : réalise les visites, saisit heures réelles et appâts consommés.
4. **Système** : calcule le coût de chaque intervention à la clôture de l'ordre de service.
5. **Responsable** : consulte la marge par intervention / client / zone (Role Center + rapports).
6. **Facturation** : poste la facture de service standard BC.

---

## 8. Prochaines étapes (après validation)

| Ordre | Développement | Objet |
|---|---|---|
| 1 | Codeunit de calcul du coût (MO + consommables + véhicule) | `SMHIT Cost Calculator` |
| 2 | Création automatique de l'ordre de service et de ses lignes de coût depuis l'intervention | `SMHIT Service Order Mgt` |
| 3 | Tables restantes : buckets 50121, versions 50111, setup 50130 | Tables custom |
| 4 | Clôture d'intervention : consommation réelle appâts + heures réelles | Codeunit de clôture |
| 5 | Pages UI + Role Center planificateur + rapports de marge | Pages / Reports |

---

*Document soumis à validation — équipe projet SMHIT / COMAFDOM.*
