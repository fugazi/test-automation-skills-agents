# Manual Audit Checklist (WCAG 2.1 Level AA)

Use this checklist to complement automated axe-core scans. Many success criteria require human judgment, assistive technology testing, or design review.

> **Important:** Automated testing catches ~30-50% of accessibility issues. This manual checklist covers what automation cannot detect.

---

## Perceivable

### Text Alternatives (1.1.1)

- [ ] Informative images have meaningful `alt` text describing content
- [ ] Decorative images use `alt=""` or CSS background
- [ ] Complex images (charts, diagrams) have extended descriptions
- [ ] Icons without text labels have accessible names
- [ ] Image buttons have descriptive alt text for action

### Time-based Media (1.2.x)

- [ ] Videos have accurate captions
- [ ] Audio-only content has text transcript
- [ ] Pre-recorded video has audio description (where needed)
- [ ] Media player controls are keyboard accessible
- [ ] Auto-playing media can be paused/stopped

### Info and Relationships (1.3.1)

- [ ] Headings use proper hierarchy (`<h1>` through `<h6>`)
- [ ] Lists use `<ul>`, `<ol>`, `<dl>` appropriately
- [ ] Tables have `<th>` headers with proper scope
- [ ] Form inputs are associated with labels (`<label for="">`)
- [ ] Groups of related inputs use `<fieldset>` and `<legend>`
- [ ] Required fields are programmatically indicated (not just asterisk)

### Meaningful Sequence (1.3.2)

- [ ] Reading order matches visual order
- [ ] CSS doesn't create different meaning when disabled
- [ ] Tab order follows logical sequence

### Sensory Characteristics (1.3.3)

- [ ] Instructions don't rely solely on shape, color, or position
- [ ] "Click the red button" → "Click the Submit button"
- [ ] Icons have text labels or accessible names

### Orientation (1.3.4)

- [ ] Content works in both portrait and landscape
- [ ] No forced orientation unless essential

### Identify Input Purpose (1.3.5)

- [ ] Common inputs use appropriate `autocomplete` attributes
- [ ] Login forms: `autocomplete="username"`, `autocomplete="current-password"`
- [ ] Address forms: `autocomplete="address-line1"`, etc.

### Use of Color (1.4.1)

- [ ] Links are distinguishable without color (underline, icon)
- [ ] Error/success states have text or icon, not just color
- [ ] Charts/graphs use patterns in addition to colors
- [ ] Required fields are not indicated by color alone

### Contrast (Minimum) (1.4.3)

- [ ] Normal text: 4.5:1 contrast ratio
- [ ] Large text (18pt+): 3:1 contrast ratio
- [ ] Check all states: hover, focus, disabled, error
- [ ] Verify in both light and dark themes
- [ ] Text over images has sufficient contrast

### Resize Text (1.4.4)

- [ ] Text resizes to 200% without loss of content
- [ ] No horizontal scrolling at 200% zoom
- [ ] Text doesn't get clipped or overlap

### Images of Text (1.4.5)

- [ ] Avoid images containing text
- [ ] Logos are acceptable exception
- [ ] If unavoidable, include alt text with the text content

### Reflow (1.4.10)

- [ ] Content reflows at 320px width (or 400% zoom)
- [ ] No horizontal scrolling for standard content
- [ ] Tables may scroll but content remains accessible

### Non-text Contrast (1.4.11)

- [ ] UI components: 3:1 contrast ratio
- [ ] Focus indicators: 3:1 contrast ratio
- [ ] Icons: 3:1 contrast ratio (if they convey meaning)
- [ ] Form field borders: 3:1 against background

### Text Spacing (1.4.12)

- [ ] Content remains usable with increased:
  - Line height: 1.5x font size
  - Paragraph spacing: 2x font size
  - Letter spacing: 0.12x font size
  - Word spacing: 0.16x font size

### Content on Hover/Focus (1.4.13)

- [ ] Tooltips/popovers are dismissible (Escape key)
- [ ] Content remains visible while hovering over it
- [ ] Content persists until dismissed or no longer relevant

---

## Operable

### Keyboard (2.1.1)

- [ ] All functionality available via keyboard
- [ ] Tab navigates all interactive elements
- [ ] Enter/Space activates buttons and links
- [ ] Arrow keys work in custom components (menus, tabs)
- [ ] Custom widgets implement expected keyboard patterns

### No Keyboard Trap (2.1.2)

- [ ] Can exit all components via keyboard
- [ ] Modals can be closed with Escape
- [ ] Focus doesn't get stuck in any component
- [ ] Embedded content (iframes, widgets) allows exit

### Timing Adjustable (2.2.1)

- [ ] Session timeouts provide warning and extension option
- [ ] Auto-updating content can be paused
- [ ] Time limits can be turned off or extended

### Pause, Stop, Hide (2.2.2)

- [ ] Carousels have pause controls
- [ ] Animations can be stopped
- [ ] Auto-scrolling content has controls
- [ ] `prefers-reduced-motion` is respected

### Three Flashes (2.3.1)

- [ ] No content flashes more than 3 times per second
- [ ] Animated content is small area or low contrast

### Bypass Blocks (2.4.1)

- [ ] Skip link present ("Skip to main content")
- [ ] Skip link is visible on focus
- [ ] Skip link actually moves focus to main content
- [ ] Landmarks used: `<main>`, `<nav>`, `<header>`, `<footer>`

### Page Titled (2.4.2)

- [ ] Every page has unique, descriptive `<title>`
- [ ] Title describes page content/purpose
- [ ] Dynamic pages update title appropriately
- [ ] Pattern: "Page Name - Site Name"

### Focus Order (2.4.3)

- [ ] Focus order follows logical reading sequence
- [ ] Modals trap focus appropriately
- [ ] Focus returns to trigger element when modal closes
- [ ] No unexpected focus jumps

### Link Purpose (In Context) (2.4.4)

- [ ] Link text describes destination
- [ ] Avoid generic "Click here", "Read more"
- [ ] If generic needed, add visually hidden context
- [ ] Links opening new windows indicate this

### Multiple Ways (2.4.5)

- [ ] Site provides multiple ways to find pages:
  - Navigation menu
  - Search functionality
  - Sitemap
  - Table of contents

### Headings and Labels (2.4.6)

- [ ] Headings describe content they introduce
- [ ] Form labels describe the expected input
- [ ] Button labels describe the action

### Focus Visible (2.4.7)

- [ ] Focus indicator is always visible
- [ ] Focus indicator has sufficient contrast
- [ ] Custom focus styles don't hide the indicator
- [ ] Focus indicator is visible in all themes

### Pointer Gestures (2.5.1)

- [ ] Multi-point gestures have single-pointer alternatives
- [ ] Path-based gestures have alternatives (swipe → buttons)
- [ ] Pinch-to-zoom has +/- buttons

### Pointer Cancellation (2.5.2)

- [ ] Actions occur on "up" event, not "down"
- [ ] Actions can be aborted by moving pointer away
- [ ] Single-click actions don't trigger on mousedown

### Label in Name (2.5.3)

- [ ] Accessible name includes visible text
- [ ] "Search" button has "Search" in accessible name
- [ ] Important for voice control users

### Motion Actuation (2.5.4)

- [ ] Shake/tilt gestures have UI alternatives
- [ ] Motion-based features can be disabled

---

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

- **WCAG 2.1 Specification**: https://www.w3.org/TR/WCAG21/
- **WCAG Quick Reference**: https://www.w3.org/WAI/WCAG21/quickref/
- **WAI-ARIA Practices**: https://www.w3.org/WAI/ARIA/apg/
- **WAI-ARIA Specification**: https://www.w3.org/TR/wai-aria/
- **Deque Axe Rules**: https://dequeuniversity.com/rules/axe/4.10
