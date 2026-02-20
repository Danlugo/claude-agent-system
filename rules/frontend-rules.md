# Frontend Rules

> Standards for frontend development. Referenced by: frontend-developer, qa-automation

---

## Design Principles

| Principle | Description |
|-----------|-------------|
| Mobile-first | Design for smallest screen, scale up with media queries |
| Accessibility | WCAG 2.1 AA minimum — semantic HTML, ARIA, keyboard nav |
| Component reuse | Check existing components before creating new ones |
| State colocation | Keep state as close to where it's used as possible |
| Progressive enhancement | Core functionality works without JS where possible |

---

## Component Standards

### Naming

| Type | Convention | Example |
|------|-----------|---------|
| Component file | PascalCase | `HotelCard.tsx` |
| Utility/hook | camelCase | `useHotelData.ts` |
| Style file | Match component | `HotelCard.module.css` |
| Test file | Match component + test | `HotelCard.test.tsx` |
| Constant | SCREAMING_SNAKE | `MAX_PAGE_SIZE` |

### Structure

```
src/
  components/       # Reusable UI components
    Button/
      Button.tsx
      Button.module.css
      Button.test.tsx
      index.ts
  features/         # Feature-specific components
  hooks/            # Custom hooks
  utils/            # Pure utility functions
  services/         # API calls, external integrations
  types/            # Shared TypeScript types
```

---

## Accessibility Checklist

| Requirement | How |
|-------------|-----|
| Semantic HTML | Use `<nav>`, `<main>`, `<article>`, `<button>` — not `<div onClick>` |
| Keyboard navigation | All interactive elements reachable via Tab, operable via Enter/Space |
| Focus management | Visible focus indicator, logical tab order |
| ARIA labels | `aria-label` on icon-only buttons, `aria-describedby` for complex inputs |
| Color contrast | 4.5:1 for normal text, 3:1 for large text |
| Alt text | All `<img>` elements have `alt` attribute (empty string for decorative) |
| Form labels | Every `<input>` has an associated `<label>` |
| Error messages | Linked to inputs via `aria-describedby`, announced by screen readers |

---

## Responsive Breakpoints

| Breakpoint | Min Width | Devices |
|-----------|-----------|---------|
| xs | 0 | Phones (portrait) |
| sm | 640px | Phones (landscape) |
| md | 768px | Tablets |
| lg | 1024px | Laptops |
| xl | 1280px | Desktops |

---

## State Management

| Scope | Tool |
|-------|------|
| Component-local | `useState`, `useReducer` |
| Shared between siblings | Lift to parent |
| Feature-wide | Context + reducer |
| App-wide | State library (Redux, Zustand) or Context |
| Server state | Data fetching library (TanStack Query, SWR) |

---

## Performance

| Practice | Why |
|----------|-----|
| Lazy load routes | Reduce initial bundle |
| Memoize expensive computations | Avoid unnecessary recalculation |
| Avoid inline object/function props | Prevent child re-renders |
| Use virtualization for long lists | DOM performance |
| Image optimization | Lazy loading, proper sizing, modern formats |

---

## Anti-Patterns

| Don't | Do Instead |
|-------|-----------|
| `<div onClick>` | `<button>` with proper semantics |
| Inline styles | CSS modules, styled-components, or Tailwind |
| Prop drilling (5+ levels) | Context or state management library |
| `useEffect` for derived state | Compute during render |
| `// eslint-disable` | Fix the warning |
| `any` type in TypeScript | Define proper types |
| Fetch in `useEffect` without cleanup | Use data fetching library or add cleanup |
| Giant monolithic components | Extract into smaller focused components |
