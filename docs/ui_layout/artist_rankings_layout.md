# Artist Rankings Page Layout

This document explains how the **Artists** page is assembled, why each piece is positioned the way it is, and where there's room for tidy-ups that do *not* change behaviour.

---
## 1. Header (`Header.tsx`)
* Fixed to the viewport (`fixed top-0`) with `z-50` – topmost layer.
* Houses navigation, user/profile menus and (optional) admin menus.
* Separate state flags control each dropdown (`isOpen`, `isProfileOpen`, `isAdminOpen`).
* Global *mousedown* listeners close dropdowns when clicking outside.

**Ideas for later**
* Extract a `useClickOutside()` hook – we repeat the same listener pattern three times.
* Replace magic numbers with semantic z-index tokens defined in `tailwind.config.js`.

---
## 2. Page Shell (`MainLayout.tsx`)
* Renders **below** `Header`.
* Contains a *page header* that is **sticky inside the document** (`sticky top-0` / `z-[45]`).  It shows:
  * "My Artist Rankings" title
  * Toggle button that collapses/expands the `SearchBar`.
* Width is capped with `max-w-3xl mx-auto` – same rule as the rest of the app.
* Layout skeleton:

```txt
Header (fixed)
└── MainLayout (flex col)
    ├── Page Header  (sticky)
    │   └── Collapsible SearchBar
    └── Content Viewport (flex-1)
        └── ArtistRankingForm | ArtistCanvas
```

---
## 3. Ranking List (`ArtistRankingForm.tsx`)
* Lives inside the **content viewport** and owns the **only scrollbar on the page**.
* Wrapper `div` receives full height from parent (`h-full`).
* Inner `div` uses `overflow-y-auto` so list scrolls but the rest of the page does not.
* For each tier we render:
  * **Tier header** with `sticky top-0 z-[40]` – sticks to top of *its scroll container* so newer tier headers push older ones out while scrolling.
  * Artist rows with dropdowns / action menu.

### Z-index ladder
| Layer                            | Class  |
|----------------------------------|--------|
| App Header                       | `z-50` |
| Page Header (+ Search)           | `z-[45]` |
| Dropdowns / Context menus        | `z-[41]` |
| Tier Headers                     | `z-[40]` |
| Regular content                  | default |

### State & behaviour highlights
* Rebuilds a `grouped` map of artists → tier every render (can be memoised).
* Global outside-click listener closes per-artist menu.
* Pagination only applied to *Unranked* tier.

**Ideas for later**
1. Memoise `grouped` + pagination slices with `useMemo`.
2. Extract dropdown/menu logic into a reusable component.
3. Add ARIA roles / keyboard navigation.
4. Centralise z-index values in Tailwind config (`theme.extend.zIndex`).

---
## Interaction Flow
1. `Header` mounts (fixed, z-50).
2. Route renders `MainLayout`.
3. Page header (sticky) appears; `SearchBar` slides open/closed.
4. `ArtistRankingForm` supplies its own scrollable area.
5. Tier headers stick inside that scroll area; dropdowns float above them but below the page header.

---
## Terminology Cheat-Sheet
* **Fixed** – positioned relative to *viewport*; stays put while the page scrolls.
* **Sticky** – behaves like *relative* until its scroll container reaches an offset, then locks in place.
* **Flex-1** – tells an element in a flex column to grow and fill remaining space.

---
## Why this matters
Keeping a single, predictable scroll context makes sticky headers reliable and eliminates double-scrollbars.  Using semantic z-index tokens and small reusable hooks/components will make future visual tweaks much safer and faster. 