# Design System Specification: The Fluid Scholar

## 1. Overview & Creative North Star
The "Fluid Scholar" is the creative North Star of this design system. It moves away from the rigid, boxed-in layouts of traditional educational platforms and toward a "Digital Sanctuary"—an environment that feels open, breathable, and intellectually stimulating. 

By leveraging **Asymmetric Composition** and **Tonal Depth**, we break the "template" look. Instead of a grid of identical boxes, we use intentional overlapping, varied card heights, and generous white space to guide the student's eye. This system is designed to reduce "academic anxiety" by replacing sharp edges and heavy borders with soft, organic transitions and a sophisticated editorial hierarchy.

---

## 2. Color & Surface Philosophy

### The Palette
The system utilizes a refined Material 3 logic to ensure high contrast for accessibility while maintaining a premium feel.
- **Primary (Sabi Green - #0d631b):** Used for "Success" pathways and core brand moments.
- **Secondary (Growth Orange - #8b5000):** Used sparingly for motivational triggers and "In-Progress" states.
- **Tertiary (Knowledge Blue - #00569f):** Used for deep focus areas, resource links, and "Stable" information.

### The "No-Line" Rule
**Explicit Instruction:** 1px solid borders are prohibited for sectioning. Boundaries must be defined through:
1.  **Background Color Shifts:** Placing a `surface_container_low` section atop a `surface` background.
2.  **Tonal Transitions:** Using the hierarchy of surfaces to imply containment.

### Surface Hierarchy & Nesting
Treat the UI as physical layers of "Frosted Glass" or "Fine Paper." 
- **Base Layer:** `surface` (#f8faf8)
- **Content Blocks:** `surface_container_low` (#f2f4f2)
- **Interactive Cards:** `surface_container_lowest` (#ffffff)
- **Elevated Modals:** `surface_bright` (#f8faf8) with Glassmorphism.

### The "Glass & Gradient" Rule
To inject "soul" into the interface, use a **Signature Texture**: A subtle linear gradient from `primary` to `primary_container` for hero actions. For floating navigation or mobile top-bars, use **Glassmorphism**: `surface` at 80% opacity with a `backdrop-filter: blur(12px)`.

---

## 3. Typography: Editorial Authority
We utilize a dual-typeface system to balance character with extreme legibility.

- **Display & Headlines (Plus Jakarta Sans):** These are our "Editorial" voices. The wider apertures and modern geometric curves make learning feel contemporary.
    - *Usage:* `display-lg` (3.5rem) for hero welcomes; `headline-md` (1.75rem) for module titles.
- **Body & Labels (Inter):** The "Workhorse." Chosen for its exceptional tall x-height and readability on mobile screens.
    - *Usage:* `body-lg` (1rem) for lesson content; `label-md` (0.75rem) for metadata.

**Hierarchy Note:** Always maintain a minimum 1.5x line-height for body text to ensure low cognitive load for students with dyslexia or visual fatigue.

---

## 4. Elevation & Depth: Tonal Layering

### The Layering Principle
Avoid "shadow-overload." Create depth by stacking tokens:
- **Level 0 (Floor):** `surface_dim`
- **Level 1 (Section):** `surface_container`
- **Level 2 (Card):** `surface_container_lowest`

### Ambient Shadows
When an element must float (e.g., a "Start Lesson" FAB), use a **Tinted Ambient Shadow**:
- `box-shadow: 0 12px 32px -4px rgba(27, 109, 36, 0.08);` (Using a tint of `surface_tint` rather than black).

### The "Ghost Border" Fallback
If a border is required for accessibility (e.g., in high-contrast mode), use a **Ghost Border**: `outline_variant` at 15% opacity. Never use 100% opaque lines.

---

## 5. Components & Interaction Patterns

### Buttons
- **Primary:** `primary` background, `on_primary` text. **Corner Radius:** `full` (pill-shaped) for high touch-target comfort.
- **Secondary:** `secondary_container` background. Use for "Secondary Actions" like "Save for Later."
- **Tertiary:** No background. Use `primary` text with a `1rem` (DEFAULT) rounded focus state.

### Cards & Learning Modules
- **Forbid Dividers:** Do not use lines to separate content within a card. Use `1.5rem` (md) vertical padding to create "Gutter Space."
- **Corner Radius:** Always `1rem` (DEFAULT) for standard cards; `2rem` (lg) for major hero sections to emphasize "Softness."

### Input Fields
- **Surface:** `surface_container_highest`.
- **States:** On focus, transition the "Ghost Border" from 15% to 100% `primary` thickness (2px).
- **Feedback:** Error states use `error` text with an `error_container` background wash over the entire input field.

### Progress Indicators
- Use a soft gradient transition from `primary_fixed` to `primary`. Avoid "harsh" loading bars; use rounded caps (`full`) and a width transition of 300ms Easing.

---

## 6. Do’s and Don’ts

### Do:
- **Embrace Asymmetry:** Align a headline to the left and a supporting "Quick Tip" card slightly offset to the right.
- **Prioritize Breathing Room:** If in doubt, double the whitespace. The goal is "Airy."
- **Use Haptic Colors:** Use `Growth Orange` specifically for "Aha!" moments—badges, streak counters, and rewards.

### Don’t:
- **Don't use Pure Black:** Always use `on_surface` (#191c1b) for text to prevent eye strain.
- **Don't use Box Shadows on everything:** Let background color shifts do the heavy lifting.
- **Don't use standard 4px corners:** Our minimum is `16px` (1rem). Anything sharper feels "Institutional" and creates friction in a friendly learning environment.
- **Don't use Dividers:** If you feel the need to add a line, add `24px` of empty space instead.