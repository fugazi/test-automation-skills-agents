# WCAG 2.2 AA Manual Audit Checklist: WCAG 2.2 Additions, Exceptions, References

> Part of the `accessibility-selenium-testing` skill. See [SKILL.md](../SKILL.md) for full context.

> **Related:** this file was split from the original wcag21aa-checklist.md. See the other related files in this folder.

## WCAG 2.2 Additions (new AA-level success criteria)

These new AA success criteria were introduced in WCAG 2.2 (axe tag `wcag22aa`). Verify them in addition to the 2.1 criteria above.

### Focus Not Obscured (Minimum) (2.4.11)

- [ ] Receiving focus does not leave a component entirely hidden behind sticky/positioned content
- [ ] Tested against common sticky headers, cookie banners, and floating action buttons

### Dragging Movements (2.5.7)

- [ ] Functionality using dragging (sliders, reorder lists, Kanban) has a single-pointer alternative (arrows, buttons, menu)
- [ ] Drag-and-drop is not the only way to perform the action

### Target Size (Minimum) (2.5.8)

- [ ] Interactive targets are at least 24×24 CSS px (with documented exceptions: inline links, essential spacing, UA defaults)

### Consistent Help (3.2.6)

- [ ] Help mechanisms (human contact, mech, self-help) appear in the same relative order across pages where present

### Redundant Entry (3.3.7)

- [ ] Previously entered information in the same process is auto-populated or selectable, not re-keyed (e.g., shipping == billing)

### Accessible Authentication (Minimum) (3.3.8)

- [ ] Authentication does not require a cognitive function test (no distorted-text transcription, no memory of personal info)
- [ ] Copy/paste of passwords and password managers are not blocked

---

## Exception Documentation Template

For any accepted exception, document:

| Field              | Value                              |
| ------------------ | ---------------------------------- |
| **WCAG Criterion** | e.g., 1.4.3 Contrast               |
| **Component/Page** | e.g., Third-party chat widget      |
| **User Impact**    | Who is affected and how            |
| **Mitigation**     | Alternative provided or workaround |
| **Owner**          | Responsible team/person            |
| **Ticket**         | JIRA/GitHub issue reference        |
| **Target Date**    | Remediation deadline               |

---

## W3C/WAI References

- **WCAG 2.2 Specification**: https://www.w3.org/TR/WCAG22/
- **WCAG Quick Reference**: https://www.w3.org/WAI/WCAG22/quickref/
- **WAI-ARIA Practices**: https://www.w3.org/WAI/ARIA/apg/
- **WAI-ARIA Specification**: https://www.w3.org/TR/wai-aria/
- **Deque Axe Rules**: https://dequeuniversity.com/rules/axe/4.10
