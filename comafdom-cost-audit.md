---
name: "comafdom-cost-audit"
description: "COMAFDOM NAV/BC cost anomaly audit — the four confirmed anomalies, Application Worksheet remediation, and diagnostic controls used"
---

- Ahmed is an ERP consultant working with a client company called COMAFDOM on Microsoft Dynamics NAV / Business Central.
- The work involves diagnosing and correcting anomalies in article cost data, performing structured audits, and developing technical solutions to protect corrected costs from being overwritten by the system's cost adjustment engine.
- Domain areas involved: inventory valuation, C/AL development, item ledger mechanics, and cost adjustment architecture in NAV/BC.

## Current state — audit findings
- A full audit of 83 articles is complete, with four confirmed cost anomalies identified.
- MN02030065: phantom cost on two transfer lines with zero quantity.
- MN02030040: receipt cost approximately 10x too high.
- CO05020003: receipt cost approximately 6x too high.
- BO01030003: negative unit cost on an unposted receipt line.
- Planned remediation: relocate remaining quantities from erroneous entries to entries with correct costs via the Application Worksheet (Item Application Entries, table 339) — confirmed as a clean and legitimate method.

## Diagnostic controls and learnings
- Diagnostic controls applied: zero-quantity entries with non-zero real cost; negative unit costs on unposted receipt lines (with exclusions); heuristic receipt-to-invoice unit cost ratio analysis at a 2.5x threshold.
- Supplier rebate lines (negative unit costs on specific entry types) are legitimate and must be explicitly excluded from anomaly detection logic.
- Corrupted correction lines with astronomically large cost values (e.g. ~-299 trillion) propagate directly into displayed unit costs on item cards, making them a high-priority diagnostic signal.
- The `Applied Entry to Adjust` flag on Item Ledger Entries is not a permanent cost lock — it resets automatically on each new transaction, making it unsuitable as a protection mechanism on its own.
