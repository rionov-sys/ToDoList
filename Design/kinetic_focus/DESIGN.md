---
name: Kinetic Focus
colors:
  surface: '#f8f9ff'
  surface-dim: '#cbdbf5'
  surface-bright: '#f8f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#eff4ff'
  surface-container: '#e5eeff'
  surface-container-high: '#dce9ff'
  surface-container-highest: '#d3e4fe'
  on-surface: '#0b1c30'
  on-surface-variant: '#464555'
  inverse-surface: '#213145'
  inverse-on-surface: '#eaf1ff'
  outline: '#777587'
  outline-variant: '#c7c4d8'
  surface-tint: '#4d44e3'
  primary: '#3525cd'
  on-primary: '#ffffff'
  primary-container: '#4f46e5'
  on-primary-container: '#dad7ff'
  inverse-primary: '#c3c0ff'
  secondary: '#4648d4'
  on-secondary: '#ffffff'
  secondary-container: '#6063ee'
  on-secondary-container: '#fffbff'
  tertiary: '#41485e'
  on-tertiary: '#ffffff'
  tertiary-container: '#586076'
  on-tertiary-container: '#d4dbf5'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#e2dfff'
  primary-fixed-dim: '#c3c0ff'
  on-primary-fixed: '#0f0069'
  on-primary-fixed-variant: '#3323cc'
  secondary-fixed: '#e1e0ff'
  secondary-fixed-dim: '#c0c1ff'
  on-secondary-fixed: '#07006c'
  on-secondary-fixed-variant: '#2f2ebe'
  tertiary-fixed: '#dae2fd'
  tertiary-fixed-dim: '#bec6e0'
  on-tertiary-fixed: '#131b2e'
  on-tertiary-fixed-variant: '#3f465c'
  background: '#f8f9ff'
  on-background: '#0b1c30'
  surface-variant: '#d3e4fe'
typography:
  headline-xl:
    fontFamily: Plus Jakarta Sans
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 26px
    fontWeight: '700'
    lineHeight: 34px
    letterSpacing: -0.015em
  headline-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
    letterSpacing: -0.01em
  headline-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 17px
    fontWeight: '600'
    lineHeight: 24px
    letterSpacing: -0.005em
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
    letterSpacing: 0em
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
    letterSpacing: 0em
  body-sm:
    fontFamily: Inter
    fontSize: 13px
    fontWeight: '400'
    lineHeight: 18px
    letterSpacing: 0.005em
  label-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 13px
    fontWeight: '600'
    lineHeight: 18px
    letterSpacing: 0.01em
  label-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 11px
    fontWeight: '600'
    lineHeight: 14px
    letterSpacing: 0.02em
  mono-time:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: -0.01em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 0.75rem
  margin: 1rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 0.75rem
  space-lg: 1rem
  space-xl: 1.5rem
---

## Brand & Style

The design system embodies focused momentum, clarity, and precision. Built specifically for high-efficiency mobile workflows, it avoids visual clutter in favor of crisp spatial hierarchy, high information density without claustrophobia, and instant visual orientation. 

The aesthetic fuses **Modern Contemporary UI** with understated **Tactile Elevation**:
- Tactile cards and floating timeline connectors provide tangible feedback for task lifecycle tracking.
- Color functions as functional metadata rather than decoration: priorities, statuses, and deadlines telegraph urgency without alarming the user.
- The interface feels responsive, deliberate, and calm, transforming daily chaos into structured progress across a standard 390px mobile viewport.

## Colors

The palette establishes clear optical separation between canvas, structural containers, and action-driven semantics.

### Functional Roles & Accents
- **Canvas Base:** `#F8FAFC` (Slate 50) supplies a soft, paper-like background that mitigates eye fatigue.
- **Surface Elevation:** Pure `#FFFFFF` elevates active cards, timeline clusters, and sheets from the canvas.
- **Primary & Interactive:** Deep Indigo (`#4F46E5`) anchors focal action buttons, active tab indicators, and timeline current-time needles. Electric Indigo (`#6366F1`) serves as the hover/pressed and active gradient companion.
- **Deep Slate Anchors:** `#0F172A` delivers authoritative contrast for primary typography, timeline stems, and high-emphasis floating action buttons.

### Priority & Status Tints
- **Urgent / High Priority:** Rose Coral (`#F43F5E`) with tinted container wash (`#FFF1F2`).
- **In Progress / Medium Priority:** Warm Amber (`#F59E0B`) with tinted container wash (`#FFFBEB`).
- **Completed / Low Priority:** Vibrant Emerald (`#10B981`) with tinted container wash (`#ECFDF5`).
- **Todo / Backlog:** Neutral Slate (`#64748B`) with tinted container wash (`#F1F5F9`).

Avoid large flood fills of high-saturation colors; maintain status indicators within badges, milestone nodes, and left-aligned card border trims.

## Typography

Typography pairs **Plus Jakarta Sans** for structural headers, card titles, and metadata tags with **Inter** for readable narrative descriptions, task notes, and data-dense timestamps.

- **Numerics & Timing:** Inter handles all timeline hours (`09:30 AM`), sub-task counts (`3/5 completed`), and countdown badges to leverage its neutral numeric tabular alignment.
- **Visual Weighting:** Task item titles utilize `headline-sm` with a tight negative tracking to maintain punchiness in constrained widths. Notes and secondary descriptions transition strictly to `body-sm` in Slate 500 (`#64748B`).

## Layout & Spacing

Designed primarily for standard 390px mobile screens, the spacing framework uses an 8px base rhythm with 4px sub-increments for compact UI widgets.

- **Canvas Safe Area:** 16px (`1rem`) horizontal margin anchors all primary content feeds, ensuring content remains tap-friendly and comfortably spaced from screen bezels.
- **Vertical Rhythm:** 
  - 12px (`0.75rem`) vertical space between discrete task cards.
  - 24px (`1.5rem`) vertical space separating chronological timeline blocks (e.g., Morning, Afternoon, Evening).
- **Timeline Alignment:** A fixed 56px left rail manages node icons, current-time pips, and vertical connecting traces. Task cards stretch across the remaining viewport width (390px - 16px margin - 56px rail - 16px margin = 302px fluid width).

## Elevation & Depth

Visual hierarchy combines low-opacity ambient shadows with delicate 1px border keylines (`rgba(15, 23, 42, 0.06)`):

- **Level 0 (Canvas):** Flat `#F8FAFC`, no shadow.
- **Level 1 (Resting Cards & Timeline Items):** `#FFFFFF` surface accompanied by a subtle ambient drop shadow: `0 1px 3px rgba(15, 23, 42, 0.04), 0 4px 12px rgba(15, 23, 42, 0.03)` with a 1px solid border in `#E2E8F0`.
- **Level 2 (Active Drag / Selected Cards):** `0 8px 24px rgba(79, 70, 229, 0.12), 0 2px 6px rgba(15, 23, 42, 0.04)` with a border highlight of `#6366F1`.
- **Level 3 (Modals & Bottom Creation Sheets):** `0 -8px 32px rgba(15, 23, 42, 0.12)` accompanied by a backdrop dim of `rgba(15, 23, 42, 0.4)`.
- **Timeline Connector Depth:** Vertical rail lines sit flat at 2px width (`#E2E8F0`), while milestone nodes feature an inner ring: 12px dot with a 4px white mask and 2px colored ring to convey physical anchoring.

## Shapes

The design uses balanced, rounded contours (`roundedness: 2` / 16px card standard) to communicate accessibility, approachability, and smooth gesture transitions on touchscreens.

- **Cards & Sheets:** Default to 16px (`rounded-lg`), creating soft corners that comfortably frame dense multi-line content.
- **Interactive Controls (Inputs, Buttons, Filter Chips):** 8px to 12px (`rounded-md` to `rounded-lg`) to balance tap area precision with visual structure.
- **Milestone Nodes & Pill Tags:** Fully pill-shaped (`9999px`) for status indicators, quick priority badges, and timeline status circles.

## Components

### Task Cards
- **Structure:** 16px internal padding, white background, 16px corner radius, hairline `#E2E8F0` border.
- **Priority Indicator:** Vertical 3px pill along the left inside edge, tinted to the assigned priority (Rose for Urgent, Amber for In Progress, Emerald for Low).
- **Progressive Disclosure:** Sub-tasks and assignees reveal inline with a 12px icon button; swipe right triggers immediate completion, swipe left reveals reschedule actions.

### Timeline & Milestone Markers
- **Timeline Spine:** 2px solid vertical line in `#E2E8F0`, running down the 56px left column.
- **Milestone Node:** 16px circular disk. Unfinished milestones use a white center with a 2px slate border; in-progress milestones pulse with a primary indigo halo; finished milestones collapse into a filled emerald checkmark disk.
- **Current Time Pip:** Horizontal `#4F46E5` line with an arrow badge projecting from the left margin, displaying the real-time clock.

### Buttons & Quick Actions
- **Primary Action (FAB / Submit):** Solid Indigo (`#4F46E5`), white label, 12px radius, min-height 48px to satisfy touch target ergonomics.
- **Secondary Action:** Slate 100 (`#F1F5F9`) background, `#0F172A` text, 0px border.
- **Interactive Checkboxes:** Custom rounded squares (6px radius), 20x20px dimension. Unchecked: 1.5px `#CBD5E1` border. Checked: `#10B981` solid fill with animated white SVG checkmark.

### Progress Bars
- **Track:** 6px height, rounded full (`9999px`), `#E2E8F0` background.
- **Indicator Fill:** Dynamic gradient from `#4F46E5` to `#6366F1` for general velocity; shifts to `#10B981` when tasks achieve 100% completion.

### Chips & Priority Filter Tabs
- **Height:** 32px height, fully pill-shaped.
- **Inactive:** `#FFFFFF` background with 1px `#E2E8F0` border, `#64748B` typography.
- **Active:** Deep Slate (`#0F172A`) or Indigo (`#4F46E5`) fill with pure white typography.