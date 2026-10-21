---
name: "nav-patch-spec"
description: "Scoped C/AL patch for per-article cost calculation start date — Codeunits 5895 and 5804, the four procedures touched, and what deliberately stays unpatched"
---

- A technical development solution has been scoped and validated: reuse the existing `"Date de Mise en dispo."` field on Item (table 27) as a per-article cost calculation start date override, requiring minimal development.
- The patch touches exactly 4 procedures with inline logic only and zero new procedures.
- `AdjustItemAppliedCost` and `SetAppliedEntryToAdjustFromBuf` in Codeunit 5895 ("Inventory Adjustment").
- `SetFilters` and `ExcludeOpenOutbndCosts` in Codeunit 5804 ("ItemCostManagement").
- One unavoidable additional operation: a `GET` on Item in `SetAppliedEntryToAdjustFromBuf`, since no Item context variable is pre-positioned in that procedure. Ahmed validated this approach.
- The two pre-selection procedures (`InvtToAdjustExist` and `MakeSingleLevelAdjmt`) control whether an article enters the processing loop but do not determine which entries get recalculated — they do not need to be patched.
