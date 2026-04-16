# Defect lifecycle (lightweight)

## Typical states

- New → Triaged → In Progress → Fixed → Verified → Closed
- Reopened when verification fails or issue persists.

## Triage checklist

- Confirm reproducibility and scope (roles, platforms, data)
- Set severity (impact) and priority (urgency)
- Identify duplicates and related issues
- Assign owner and target fix version
- Decide immediate mitigation/workaround if needed

## Verification checklist

- Reproduce on the fixed build using the same (or controlled) data
- Run focused regression around the changed area
- Add/adjust test cases and automation to prevent recurrence (especially for escaped defects)
