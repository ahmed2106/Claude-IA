# 🎯 Résumé exécutif — Coût d'une intervention SMHIT
## Pour comité de direction (1 page)

---

## Le besoin

Chaque prestation SMHIT (dératisation / désinsectisation) suit le cycle :
**Convention → Intervention planifiée → Ordre de service → Feuille de route → Facture**.

Aujourd'hui, il est impossible de savoir **ce que coûte réellement une intervention** et donc quelle est la **marge par client, site ou zone**.

## La solution proposée

Un module dans Business Central (SaaS) qui calcule automatiquement le coût de chaque intervention selon la formule :

> **Coût intervention = Main d'œuvre + Consommables (appâts) + Véhicule**

| Composante | Comment c'est calculé | Norme appliquée |
|---|---|---|
| 🔧 **Main d'œuvre** | Techniciens × **heures réelles sur site** × taux horaire chargé | ABC + ISO 9001 |
| 🐀 **Appâts/produits** | Quantité consommée × coût article | ISO 14001 |
| 🚛 **Véhicule** | Km de la tournée × taux/km (carburant + entretien, **sans amortissement** car camions déjà amortis) | Comptabilité de gestion |

## Exemple

| Poste | Montant |
|---|---|
| 2 techniciens × 3 h × 15 TND/h | 90,000 TND |
| 4 appâts × 12,500 TND | 50,000 TND |
| 20 km × 2,500 TND/km | 50,000 TND |
| **Coût total** | **190,000 TND** |

**Marge = Prix du contrat − 190 TND** → visible par intervention, client et zone.

## Pourquoi cette méthode

- ✅ **Temps réel et pas forfait** : la norme internationale (ABC, ISO 9001) impose d'imputer le coût au temps réellement passé — c'est la seule méthode juste quand une équipe de plusieurs techniciens intervient.
- ✅ **Maximum de standard BC** : contrats, ordres de service, factures, ressources et temps déjà existants dans Business Central — peu de développement spécifique.
- ✅ **Traçabilité complète** : conforme aux certifications ISO de SMHIT.

## Ce qui est déjà en place

3 tables créées (intervention 50120, équipe 50124, feuille de route 50154) + spécification complète (`SPEC-CalculCoutIntervention.md`).

## Prochaine étape après validation

Développement du calculateur de coût et de la génération automatique des ordres de service.

---

*Document de synthèse — 06/11/2026*
