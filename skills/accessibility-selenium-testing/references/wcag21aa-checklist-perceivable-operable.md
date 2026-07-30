# WCAG 2.2 AA Manual Audit Checklist: Perceivable and Operable

> Part of the `accessibility-selenium-testing` skill. See [SKILL.md](../SKILL.md) for full context.

> **Related:** this file was split from the original wcag21aa-checklist.md. See the other related files in this folder.

Use this checklist to complement automated axe-core scans. WCAG 2.2 AA is a superset of 2.1 AA (adds the criteria in the "WCAG 2.2 Additions" section near the end). Many success criteria require human judgment, assistive technology testing, or design review.

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
