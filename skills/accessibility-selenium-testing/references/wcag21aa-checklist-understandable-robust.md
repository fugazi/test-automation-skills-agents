# WCAG 2.2 AA Manual Audit Checklist: Understandable, Robust, Assistive Tech

> Part of the `accessibility-selenium-testing` skill. See [SKILL.md](../SKILL.md) for full context.

> **Related:** this file was split from the original wcag21aa-checklist.md. See the other related files in this folder.

## Understandable

### Language of Page (3.1.1)

- [ ] `<html lang="en">` (or appropriate language code)
- [ ] Language code matches content language

### Language of Parts (3.1.2)

- [ ] Foreign phrases marked with `lang` attribute
- [ ] `<span lang="es">Hola</span>`

### On Focus (3.2.1)

- [ ] Focus doesn't trigger unexpected context changes
- [ ] No auto-submit on focus
- [ ] No unexpected navigation on focus

### On Input (3.2.2)

- [ ] Input doesn't trigger unexpected navigation
- [ ] Select menus don't navigate on change (unless noted)
- [ ] Radio buttons don't submit form

### Consistent Navigation (3.2.3)

- [ ] Navigation appears in same relative order
- [ ] Main menu is consistent across pages
- [ ] Search is in the same location

### Consistent Identification (3.2.4)

- [ ] Same functionality = same label
- [ ] Search icon always means search
- [ ] Icons are used consistently

### Error Identification (3.3.1)

- [ ] Errors are identified in text (not just color)
- [ ] Error messages are associated with fields
- [ ] Error summary at top of form (optional but helpful)

### Labels or Instructions (3.3.2)

- [ ] All inputs have visible labels
- [ ] Required fields are indicated
- [ ] Format requirements are stated (e.g., "MM/DD/YYYY")
- [ ] Character limits are indicated

### Error Suggestion (3.3.3)

- [ ] Errors suggest corrections when known
- [ ] "Email is required" → "Enter your email address"
- [ ] "Invalid format" → "Enter date as MM/DD/YYYY"

### Error Prevention (3.3.4)

- [ ] Financial/legal transactions:
  - Reviews submission before final
  - Confirms action with checkbox or dialog
  - Allows editing before submission
  - Provides undo capability

---

## Robust

### Parsing (4.1.1)

- [ ] Valid HTML (no duplicate IDs)
- [ ] Properly nested elements
- [ ] Complete start/end tags
- [ ] No obsolete attributes

### Name, Role, Value (4.1.2)

- [ ] Custom controls have correct ARIA role
- [ ] Custom controls have accessible name
- [ ] State changes are announced (expanded, selected, checked)
- [ ] Dynamic updates are reflected in accessibility tree

### Status Messages (4.1.3)

- [ ] Success/error messages use `role="status"` or `role="alert"`
- [ ] Loading indicators are announced
- [ ] Toast notifications are announced
- [ ] Messages don't require focus to be perceived

---

## Assistive Technology Testing

### Screen Reader Testing

| Platform | Screen Reader | Browser         |
| -------- | ------------- | --------------- |
| Windows  | NVDA (free)   | Firefox, Chrome |
| Windows  | JAWS          | Chrome, Edge    |
| macOS    | VoiceOver     | Safari          |
| iOS      | VoiceOver     | Safari          |
| Android  | TalkBack      | Chrome          |

#### Screen Reader Test Checklist

- [ ] Page title announced on load
- [ ] Landmarks are navigable (D key in NVDA)
- [ ] Headings are navigable (H key)
- [ ] Forms are labeled correctly
- [ ] Buttons announce action
- [ ] Links announce destination
- [ ] Images announce alt text
- [ ] Tables announce headers
- [ ] Dynamic content changes announced

### Zoom Testing

- [ ] 200% zoom - no loss of content
- [ ] 400% zoom - content reflows
- [ ] Browser zoom and OS scaling
- [ ] Text-only zoom (if available)

### High Contrast Testing

- [ ] Windows High Contrast Mode
- [ ] macOS Increase Contrast
- [ ] Forced Colors media query respected
- [ ] Focus indicators visible
- [ ] Icons visible

### Reduced Motion Testing

- [ ] `@media (prefers-reduced-motion: reduce)` respected
- [ ] Animations can be disabled
- [ ] Parallax effects reduced
- [ ] Carousels pause

---
