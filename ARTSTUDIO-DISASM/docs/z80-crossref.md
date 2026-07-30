# MS-0515 ↔ ZX Spectrum cross-reference map

Maps the MS-0515 MACRO-11 disasm (`ART.MAC`, `ART1.MAC`, `ART2.MAC`, `ARTDAT.MAC`) to the
original ZX Spectrum Z80 disasm reference (`x-spectrum-disasm/0NN-topic.asm`).

The two disasms were made independently, but earlier work already borrowed Z80 routine
names for many resolved MS-0515 subroutines (`JCursHide`, `PutCursor`, `MenuSel`, ...),
and a few stray `; (ld188)`-style comments point straight at Z80 labels. This doc makes
that mapping explicit and complete at the menu/overlay level, so unresolved subroutines
can be looked up against the matching Z80 topic file instead of searched for blind.

## Z80 topic files

| File | Topic |
|---|---|
| `005-text.asm` | text |
| `006-attrs.asm` | ink/paper/border/bright/flash attributes |
| `007-shapes.asm` | line/rect/polygon/circle drawing |
| `008-misc.asm` | misc |
| `009-windows.asm` | window define/cut/paste/merge |
| `010-fill.asm` | flood fill / texture fill |
| `011-paint.asm` | pen/spray/brush painting |
| `012-file.asm` | load/save |
| `013-titles.asm` | title screen |
| `014-magn.asm` | magnifier / lens |
| `015-main.asm` | main loop, screen scroll |
| `016-fonted.asm` | font editor |
| `017-menu.asm` | menu engine (open/select/click) |
| `018-data.asm` | data tables |

## MAIN_MENU dispatch — `ART.MAC:2534` (`K30076`)

Top-level menu table. Every entry below is one branch point into a feature area —
everything reachable from it maps to the listed Z80 file(s).

| Menu item | MS-0515 target | Z80 file |
|---|---|---|
| init => MAIN_INIT | `K26272` | 015-main.asm |
| PRINT_MENU | `K36254` | 008-misc.asm / 013-titles.asm |
| FILE | `K40310` | 012-file.asm |
| ATTRS_MENU | `K43466` | 006-attrs.asm |
| PAINT_MENU | `K31420` | 011-paint.asm |
| MISC_MENU | `K35512` | 008-misc.asm |
| UNDO | `K26460` | 008-misc.asm |
| WIND_MENU | `K55300` | 009-windows.asm |
| FILL_MENU | `K60524` | 010-fill.asm (overlay: `ART2.MAC`) |
| MAGNIFY_MENU | `K52226` | 014-magn.asm (overlay: `ART2.MAC`) |
| TextMenu | `TEXTMN` | 005-text.asm (overlay: `ART1.MAC`) |
| SHAPES_MENU | `K51544` | 007-shapes.asm |
| SCRN_UP | `K25666` | 015-main.asm |
| SCRN_DN | `K25526` | 015-main.asm |
| EXIT | `K25116` | 015-main.asm |

## Submenu items already named

Named entries found inside each submenu table (`ART.MAC`). Unnamed/raw-address entries
are omitted — those are next in line to resolve, using the same Z80 file as their parent.

**PAINT_MENU** — `ART.MAC:2727` (`K31420`) → `011-paint.asm`
- PaintPen → `K32126`
- PaintSpray → `K31700`
- PaintBrush → `K32412`
- PaintEdBrush → `K33204`
- PaintInverse → `K33770`

**MISC_MENU** — `ART.MAC:3371` (`K35512`) → `008-misc.asm`
- ViewScreen → `K34422`
- ClearScreen → `K34456`
- BrightGrid1 → `K34476`
- BrightGrid2 → `K34510`
- RemoveGrid → `K34522`
- ChangeColor → `K35044`
- VERS_MENU (submenu, no further named items) → `K36114`

**ATTRS_MENU** — `ART.MAC:4212` (`K43466`) → `006-attrs.asm`
- INK_MENU (submenu) → `K44176`
- PAPER_MENU (submenu, not yet detailed) → `K44350`
- BORDER_MENU (submenu, not yet detailed) → `K44522`
- BRIGHT_MENU (submenu, not yet detailed) → `K45070`
- FLASH_MENU (submenu, not yet detailed) → `K45536`
- OverSel → `K43262`
- InverseSel → `K43302`
- TranspSel → `K43340`
- StandSel → `K43372`

**SHAPES_MENU** — `ART.MAC:5206` (`K51544`) → `007-shapes.asm`
- ShapSel (7 shape-type entries, all dispatch through one handler) → `K46726`
- ElasticSel → `K51460`
- SnapHrzSel → `K51476`
- SnapVrtSel → `K51514`

**MAGNIFY_MENU** — `ART.MAC:5270` (`K52226`) → `014-magn.asm` (overlay: `ART2.MAC`)
- MagnifySel (x2/x4/x8) → `MAGSEL` (`ART2.MAC:1002`)
- MagnGrid → `MAGRID` (`ART2.MAC:1111`)
- nested LENS_MENU (`K52444`, not yet fully detailed) — multiple `LensSelX` entries → `LENSEL` (`ART2.MAC:919`)

**WIND_MENU** — `ART.MAC:5747` (`K55300`) → `009-windows.asm`
- W_Define → `K54114`
- W_Last → `K54756`
- W_WholeScr → `K54764`
- W_Clear → `K54602`
- W_CutPast → `K54160`
- W_CutClrPast → `K54154`
- W_Invert → `K54574`
- W_Merge → `K55032`
- W_Multiply → `K55050`
- (remaining table slots are unnamed placeholders)

**FILL_MENU** — `ART.MAC:6306` (`K60524`) → `010-fill.asm` (overlay: `ART2.MAC`)
- FillSolid → `FILLSD` (`ART2.MAC:19`)
- FillTexture → `FILLTX` (`ART2.MAC:89`)
- FillWashTexure → `FILLWT` (`ART2.MAC:97`)
- TEXED_MENU (submenu, init => `TEXEDI`, not yet detailed) → `K61012`

**FILE** — `ART.MAC:3691` (`K40310`) → `012-file.asm`
- Code routine, not a `.WORD` table like the others. Opens `FILE_MENU` (referenced near
  `K41530`, table itself not yet located/read).

## Overlay entry points

### ART1.MAC — Overlay #1 (0x6c00 in ART.SAV, 2404 words)

Header: text menu, font editor menu, font editor / symbol, font editor / buffer, font editor / font.

| Line | Label | Z80 file |
|---|---|---|
| 16 | `TEXTMN::` | 005-text.asm |
| 707 | `FONTED::` | 016-fonted.asm |

### ART2.MAC — Overlay #2 (2289 words)

Header: fill menu, FillTexture, FillWashTexure, drawing-lens menu, magnifier-lens menu changes.

| Line | Label | Z80 file | Notes |
|---|---|---|---|
| 15 | `FILLIT::` | 010-fill.asm | FILL_MENU init |
| 19 | `FILLSD::` | 010-fill.asm | FillSolid |
| 89 | `FILLTX::` | 010-fill.asm | FillTexture |
| 97 | `FILLWT::` | 010-fill.asm | FillWashTexure |
| 180 | `TEXEDA::` | 010-fill.asm | texture edit |
| 190 | `TEXEDB::` | 010-fill.asm | texture edit |
| 196 | `TEXEDI::` | 010-fill.asm | TEXED_INIT |
| 665 | `LENSHM::` | 014-magn.asm | LensHome |
| 690 | `LENSLT::` | 014-magn.asm | LensLeft |
| 709 | `LENSRT::` | 014-magn.asm | LensRight |
| 740 | `LENSUP::` | 014-magn.asm | LensUp |
| 759 | `LENSDN::` | 014-magn.asm | LensDown |
| 919 | `LENSEL::` | 014-magn.asm | LensSelX |
| 973 | `ART33::` | 014-magn.asm | EditModeSel — on/off/toggle in LENS_MENU |
| 1002 | `MAGSEL::` | 014-magn.asm | MagnifySel — x2/x4/x8 |
| 1111 | `MAGRID::` | 014-magn.asm | MagnGrid |
| 1115 | `ART36::` | 014-magn.asm | |
| 1406 | `ART37::` | 014-magn.asm | |
| 1411 | `ART38::` | 014-magn.asm | grid step calc for "NxN frame" items |
| 1420 | `ART39::` | 014-magn.asm | selection-frame picker |

## Known confirmed Z80 label pointers

Inline breadcrumbs left in the source pointing at a specific Z80 label — either
found as-is, or added while resolving a subroutine against its Z80 counterpart:

- `ART2.MAC:34` — `; (ld188)` → `x-spectrum-disasm/010-fill.asm:14` (`ld188`, coordinate
  quantization for texture-fill target cell). Target routine still unnamed (`L65714:`).
- `ART2.MAC:78` `L66110` → `ld1d2` (010-fill.asm:37) — get address of current texture
  pattern cell. Resolved, named `TextureAddrCur`.
- `ART2.MAC:284` `L67244` → `ld54e` (010-fill.asm:262) — plot one interpolated pixel run
  while dragging the fill/texture brush.
- `ART2.MAC:449` `L70110` / `ART2.MAC:539` `L70336` → `ld652` (010-fill.asm:335), split
  into forward/reverse direction blocks — rotate-based line/mask stepper.
- `ART2.MAC:553` `L70544` → `ld6f8` (010-fill.asm:385) — row boundary compute/test.
- `ART2.MAC:565` `L70602` → `ld728` (010-fill.asm:399) — dispatch to row/column clamp
  based on distance from saved position.
- `ART2.MAC:612` `L70752` → `ld768` (010-fill.asm:419) — clamp/step row at screen
  top/bottom.
- `ART2.MAC:635` `L71036` → `ld786` (010-fill.asm:430) — clamp/step column at screen
  left/right.
- `ART2.MAC:653` `L71110` → `ld79d` (010-fill.asm:438) — store a line segment into the
  ring buffer, advance/wrap pointer.
- `ART2.MAC:665` block header (`L66706`-`L71172`) → Z80 block `ld462`-`ld79d`
  (010-fill.asm:205-445) — whole mouse-driven fill/wash-texture drawing loop.

`ART2.MAC:280` `L67240` looked like it should match Z80 `CheckBreak` (010-fill.asm:259)
by call position, but the MS-0515 body is just `SEC / RETURN` — a stub, not a real port
of the Break-key poll. Flagged in the source, not renamed.

## ART1.MAC resolved against 005-text.asm / 016-fonted.asm

All 15 previously-bare `Subroutine ??` blocks in `ART1.MAC` now carry a description and
a Z80 breadcrumb:

- `J67230`/`J67240`/`J67326` → `la12e`/`la131`/`la15e` — draw text-entry cursor box
- `J67354` → `la16b` — clamp cursor position to screen
- `J67426` → `la186` — direct-text-entry keyboard input loop
- `J70300` → `la2c5` — draw/erase text position marker
- `J70336` → `la2d9` — stretch symbol bitmap per WidthFl
- `J70550` → `la336`, `J70604` → `la34a` — sideways-text bit rotation, each direction
- `J70702` → `la374` — move text X position left, wrap
- `J71046` → `la3b9` — clamp new-char position with snap flags
- `J71202` → `la3f8` — draw cursor-row separator line
- `J71244` → `la40f` — refresh Height/Width menu checkmarks
- `J72726` → `F_Capt1`/`F_Capt2` (016-fonted.asm) — FontCapture pixel-row collector
- `J74410` → `ScanFire` (016-fonted.asm) — poll fire key, break char-scroll loop
- `J74434` → `_jphl_` (016-fonted.asm) — indirect jump through R3
- `J75242` → `SetCharXY` (016-fonted.asm) — char index to screen X/Y in font grid

## ART.MAC: 61 of 66 bare subroutines resolved

Resolved via a research pass across the whole file (menu engine, window marquee,
lens/magnify scaling, brush rasterizer, printer dump, file dialog helpers). Only two
confirmed Z80 label matches this pass — most of ART.MAC turned out to be either
MS-0515-specific (memory bank switching, hardware screen paging) or generic-enough
PDP-11 helper code that no confident Z80 counterpart could be identified; those got a
plain description instead of a forced/weak match:

- `K17530` → `PutAttrs` (006-attrs.asm) — color-swatch grid drawing
- `K47624` → `lb2bc` (007-shapes.asm) — shape-anchor reset to -1
- `K54052` → `lbfed` (009-windows.asm) — window-selection cleanup

**Still bare, need a fresh look** (the first research pass mislabeled/skipped these —
line numbers below are current, i.e. after the above edits):

- `K22352` (~line 1641) — near the x8-magnify attribute dispatch chain (K22004/K22040/K22074/K22130)
- `K25354` (~line 2120) — called at the very start of many pixel-plot routines, looks
  like a shared setup/dispatch helper, worth checking against `_HrzLine`/`_VrtLine`
  entry code in the Z80 source
- `K26476` (~line 2324, 11 usages) — screen-page address calculator, related to
  `K30532` (current visible screen page)
- `K27156` (~line 2414) — bulk block-copy between two fixed screen buffer addresses,
  called once from startup
- `K37210` (~line 3552) — loops calling `K37642` six times to refresh PRINT_MENU
  checkbox states

## Feature areas with no matching Z80 topic file

- `ART2.MAC:1572` `L76150`, `ART2.MAC:1584` `L76200`, `ART2.MAC:1632` `L76414` — screen
  dump to printer (found while resolving the LENS/magnifier area; not part of it).
  No corresponding file in `x-spectrum-disasm/` identified — printer support may be
  MS-0515-specific, or the original wasn't disassembled for this feature. Left with a
  plain description, no Z80 breadcrumb.

## ATTRS_MENU submenus — `006-attrs.asm`

**INK_MENU** — `ART.MAC:4385` (`K44176`), init => `K44076` (INK_INIT)
- both selectable swatch-grid entries → `K43120` (unnamed handler, same target both
  entries — likely a single "pick this ink color" routine keyed off which swatch index
  was clicked)

**PAPER_MENU** — `ART.MAC:4411` (`K44350`), init => `K44314` (PAPER_INIT)
- both swatch-grid entries → `K42756` (paper-color-pick handler, same pattern as INK_MENU)

**BORDER_MENU** — `ART.MAC:4437` (`K44522`), init => `K44466` (BORDER_INIT)
- swatch-grid entry → `K42522` (border-color-pick handler)

**BRIGHT_MENU** — `ART.MAC:4506` (`K45070`), init => `K44670` (BRIGHT_INIT)
- 3 entries ("Off"/"On"/"Toggle" style, exact Cyrillic labels: `К45154`/`К45204`/`К45234`
  swatch positions) all → `K44624` (bright-flag select handler)

**FLASH_MENU** — `ART.MAC:4587` (`K45536`), init => `K45336` (FLASH_INIT)
- same 3-entry pattern as BRIGHT_MENU, all → `K45272` (flash-flag select handler)

INK/PAPER/BORDER/BRIGHT/FLASH all follow the same shape: an `_INIT` routine that calls
`K17530` (`PutAttrs`, see above) to draw the swatch grid, plus a `_Curs`/select handler
called from the menu items to apply the pick and redraw the cursor/checkmark.

## LENS_MENU — `014-magn.asm`, ART.MAC table / ART2.MAC handlers

`ART.MAC:5413` (`K52444`), no exit/init (both `000000`)
- x2/x4/x8 zoom entries → `LENSEL` (`ART2.MAC`, LensSelX)
- "Attrs." → `K43466` (ATTRS_MENU, jumps out to color menu)
- Set/Reset/Toggle → `ART33` (`ART2.MAC`, EditModeSel)
- "Menu" → `K52444` itself (re-open, i.e. a no-op/refresh entry)
- Home/Left/Right/Up/Down arrows → `LENSHM`/`LENSLT`/`LENSRT`/`LENSUP`/`LENSDN`
  (`ART2.MAC`)

Matches the Z80 `LENS_MENU` table in `014-magn.asm:252` item-for-item (x2/x4/x8, Attrs.,
Set/Reset/Toggle, Menu, Home/Left/Right/Up/Down).

## TEXED_MENU — `010-fill.asm`, ART.MAC table / ART2.MAC handlers

`ART.MAC:6506` (`K61012`), init => `TEXEDI` (TEXED_INIT, `ART2.MAC`)
- texture-edit-lens click → `TEXEDA` (`ART2.MAC`, Z80 `ld365`)
- "Menu"/back → `TEXEDB` (`ART2.MAC`, Z80 `ld3e0`)

## FILE_MENU — `012-file.asm`

`ART.MAC:3999` (`K41530`), exit => `K30076` (MAIN_MENU)
- Save/Load/Erase file → all 3 → `K41174` (FileOper, single handler dispatching on
  which item was picked)

## Gaps / not yet detailed

- WIND_MENU table tail past `ART.MAC:5805` not confirmed to reach its `177777` terminator.
- `K43120`/`K42756`/`K42522`/`K44624`/`K45272` (the swatch/flag pick handlers above) are
  themselves still unnamed in `ART.MAC` — good next targets since their Z80 counterparts
  in `006-attrs.asm` should be straightforward to find (ink/paper/border/bright/flash
  select routines).

## How to use this

1. Pick an unresolved `; Subroutine ??` block.
2. Find which menu branch it falls under (nearest preceding named menu/submenu entry in
   `ART.MAC`, or which `ART1.MAC`/`ART2.MAC` overlay it's in).
3. Open the matching Z80 file from the table above.
4. Match by call order / constants / register roles, not just line-for-line — the two
   ISAs and code layouts differ; Z80 is a reference for *behavior*, not a template.
5. Name and comment the MS-0515 routine, and if there's a direct Z80 label match, leave a
   `; (Z80Label)` breadcrumb like the existing `ART2.MAC:34` one.
