# Manual audit checklist (WCAG 2.2 Level AA / W3C WAI)

> Part of the `a11y-playwright-testing` skill. See [SKILL.md](../SKILL.md) for full context.

Use this to complement automated checks. WCAG 2.2 AA is a superset of 2.1 AA — it adds the success criteria listed in the "WCAG 2.2 additions" section below. Many success criteria require human judgment, assistive tech testing, or design review.

## Perceivable

- **Text alternatives (1.1.1)**: Provide meaningful `alt` text for informative images; mark decorative images appropriately.
- **Time-based media (1.2.x)**: Provide captions and (where required) audio descriptions; verify player controls are accessible.
- **Info and relationships (1.3.1)**: Use semantic structure (headings, lists, tables) and proper form labeling; don’t rely on visual layout alone.
- **Meaningful sequence (1.3.2)**: Confirm reading and focus order matches the intended meaning.
- **Sensory characteristics (1.3.3)**: Avoid instructions like “click the red button”; add programmatic cues.
- **Orientation (1.3.4)**: Support both portrait and landscape unless essential.
- **Identify input purpose (1.3.5)**: Use appropriate `autocomplete` tokens where applicable.
- **Use of color (1.4.1)**: Do not use color as the only way to convey information.
- **Contrast (minimum) (1.4.3)**: Verify text contrast across themes and states (hover, disabled, error).
- **Resize text (1.4.4)**: Verify text can be resized to 200% without loss of content/functionality.
- **Images of text (1.4.5)**: Avoid images of text except for essential cases.
- **Reflow (1.4.10)**: Verify at 320 CSS px width (or equivalent zoom) that content reflows without horizontal scroll for common pages.
- **Non-text contrast (1.4.11)**: Verify contrast for UI components and focus indicators (not just text).
- **Text spacing (1.4.12)**: Verify content remains usable with increased line/letter/word spacing.
- **Content on hover/focus (1.4.13)**: Ensure hover/focus tooltips/popovers are dismissible, hoverable, and persistent as required.

## Operable

- **Keyboard (2.1.1)**: Complete all tasks with keyboard only.
- **No keyboard trap (2.1.2)**: Ensure users can exit components (modals, menus, editors) via keyboard.
- **Timing adjustable (2.2.1)**: Provide controls for time limits where present.
- **Pause, stop, hide (2.2.2)**: Provide controls for moving/blinking/auto-updating content.
- **Three flashes (2.3.1)**: Avoid flashing content that could trigger seizures.
- **Bypass blocks (2.4.1)**: Provide skip links/landmarks; ensure they work.
- **Page titled (2.4.2)**: Every page has a unique, descriptive title.
- **Focus order (2.4.3)**: Focus follows a logical sequence; no unexpected jumps.
- **Link purpose (in context) (2.4.4)**: Links convey their destination or action in context.
- **Multiple ways (2.4.5)**: Provide more than one way to locate pages (nav, search, sitemap) where applicable.
- **Headings and labels (2.4.6)**: Headings/labels describe topic or purpose.
- **Focus visible (2.4.7)**: Focus indicator is always visible and clearly distinguishable.
- **Pointer gestures (2.5.1)**: Provide single-pointer alternatives for multi-point/complex gestures.
- **Pointer cancellation (2.5.2)**: Prevent accidental activation; allow cancel/undo on down-events where needed.
- **Label in name (2.5.3)**: Visible label text is included in the accessible name for voice control users.
- **Motion actuation (2.5.4)**: Provide alternatives for device-motion-based actions.

## Understandable

- **Language of page (3.1.1)**: Set correct `lang` on the document.
- **Language of parts (3.1.2)**: Mark language changes within content when needed.
- **On focus (3.2.1)**: Focus does not trigger unexpected context changes.
- **On input (3.2.2)**: Input does not trigger unexpected navigation/changes without warning.
- **Consistent navigation (3.2.3)**: Navigation patterns are consistent across pages.
- **Consistent identification (3.2.4)**: Components with the same function are identified consistently.
- **Error identification (3.3.1)**: Clearly identify errors in text and associate them with fields.
- **Labels or instructions (3.3.2)**: Provide clear labels/instructions for required formats and constraints.
- **Error suggestion (3.3.3)**: Suggest corrections when possible.
- **Error prevention (3.3.4)**: Confirm/review/undo for critical transactions where applicable.

## Robust

- **Parsing (4.1.1)**: Ensure valid HTML (no duplicate IDs, properly nested elements) and predictable DOM structure.
- **Name, role, value (4.1.2)**: Custom controls expose correct role, name, state, and value to assistive tech.
- **Status messages (4.1.3)**: Announce dynamic updates (success/errors/loading) without moving focus unexpectedly.

## WCAG 2.2 additions (AA-level new success criteria)

These are the new AA success criteria introduced in WCAG 2.2 (axe tag `wcag22aa`). They are additive — verify them in addition to the 2.1 criteria above.

- **Focus not obscured (minimum) (2.4.11)**: When a component receives focus it is not entirely hidden by sticky headers, footers, or non-user-interface content.
- **Focus not obscured (enhanced) (2.4.12)** — AAA, optional: focus is not hidden at all by any content.
- **Dragging movements (2.5.7)**: Functionality that uses dragging (sliders, Kanban boards, reorder lists) has a single-pointer alternative that does not require dragging (e.g., arrow keys, +/- buttons, menu).
- **Target size (minimum) (2.5.8)**: Interactive targets are at least 24×24 CSS px, with documented exceptions (inline links, essential spacing, user-agent default). (2.5.5 is the stricter AAA 44×44.)
- **Consistent help (3.2.6)**: Help mechanisms (contact, human contact, mech, self-help) appear in the same relative order across pages when present.
- **Redundant entry (3.3.7)**: Information already entered/available is auto-populated or selectable, not re-keyed in the same process (e.g., shipping == billing address).
- **Accessible authentication (minimum) (3.3.8)**: Authentication does not require a cognitive function test (no transcription of distorted text, no memory of personal info); copy/paste of passwords is allowed.

## Assistive technology and real-user checks

- Screen reader smoke tests:
  - **macOS**: VoiceOver + Safari
  - **Windows**: NVDA + Firefox/Chrome (as available)
- Zoom and scaling:
  - 200% zoom and up to 400% (reflow, truncation, overlap, responsive nav)
- High contrast / forced colors (where applicable) and dark mode
- Reduced motion and reduced transparency preferences

## Documentation and exception handling

- For any exception, record:
  - impacted WCAG success criterion
  - user impact and affected journeys
  - mitigation (if any) and remediation plan
  - owner and target date

## W3C/WAI references

- WCAG 2.2 (Recommendation): https://www.w3.org/TR/WCAG22/
- WCAG 2.2 Quick Reference: https://www.w3.org/WAI/WCAG22/quickref/
- WAI-ARIA Authoring Practices Guide (APG): https://www.w3.org/WAI/ARIA/apg/
- WAI-ARIA specification: https://www.w3.org/TR/wai-aria/
