---
name: "ways-of-working"
description: "How Ahmed structures audit deliverables and dev specs for COMAFDOM — Excel workbooks, .md specs with before/after C/AL, plus the NAV tables and objects in play"
---

- Ahmed works with structured Excel deliverables (multi-tab workbooks) covering raw data, diagnostic tables with filters, confirmed anomalies with corrective action plans, uncertain/borderline cases with explanations, and methodology documentation.
- Development specs are delivered as `.md` documents with exact before/after C/AL code for each modification site.
- Ahmed prioritizes minimum development effort — solutions are evaluated and trimmed to the smallest viable patch surface.

## Tools and references
- Microsoft Dynamics NAV / Business Central (C/AL development).
- Excel, for multi-sheet audit deliverables.
- Key NAV tables: Item Ledger Entries, Value Entries, Item Application Entries (table 339), Item (table 27).
- Key NAV objects: Codeunit 5895 ("Inventory Adjustment"), Codeunit 5804 ("ItemCostManagement"), Report 795.
