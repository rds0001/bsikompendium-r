# bsikompendium 0.2.0

Implementation complete. Package and CRAN validation results are documented
separately in the versioned project acceptance report. No publication or CRAN
submission has been performed.

- Individual contracts cover all 1,835 active requirements in 111 modules,
  including conditions, exceptions, alternatives, roles, object relationships,
  quantities and temporal limits.
- Added 111 executable module-specific modelling contracts and 83 separately
  counted method steps from BSI Standards 200-1, 200-2 and 200-3, version 1.0.
- Native R evaluation distinguishes unknown facts from known failures and checks
  collection completeness, object identities, event states, calendar deadlines
  and UTC timestamps. No Python runtime is required.
- Coupled check decisions and coverage with the actual catalogue; coupled risk
  treatment with matrix calculations, implementation evidence, planned effects
  and institution-specific acceptance criteria.
- Completed independent source reviews and targeted positive/negative reference
  scenarios. Runtime parity and substantive source review are separate evidence.
- Added `individueller_pruefablauf`, using the same JSON input as the Python example.
- Clearly marked paragraph self-assessments and `kundenportal` as legacy examples,
  distinct from individual substantive checks.

Source edition: IT-Grundschutz Compendium 2023, including errata of 2026-03-26.

# 0.1.0

Erste lokale Ausgabe für BSI IT-Grundschutz; native Python-/R-Prüfungen.
