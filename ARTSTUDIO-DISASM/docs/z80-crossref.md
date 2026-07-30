# MS-0515 ↔ ZX Spectrum cross-reference map

Maps the MS-0515 MACRO-11 disasm (`ART.MAC`, `ART1.MAC`, `ART2.MAC`, `ARTDAT.MAC`) to the
original ZX Spectrum Z80 disasm reference (`x-spectrum-disasm/0NN-topic.asm`).

The two disasms were made independently, but earlier work already borrowed Z80 routine
names for many resolved MS-0515 subroutines (`JCursHide`, `PutCursor`, `MenuSel`, ...),
and a few stray `; (ld188)`-style comments point straight at Z80 labels. This doc makes
that mapping explicit at the menu/overlay level, and records the Z80 breadcrumbs found
while resolving the rest.

References below are by **label**, not line number — the source has moved around a lot
as it's been annotated; labels are the stable anchor. Search for the label in the named
file to find it.

**Status: all subroutines in ART.MAC / ART1.MAC / ART2.MAC are named.** No bare
`; Subroutine ??` blocks remain in any of the three files.

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

## MAIN_MENU dispatch — `ART.MAC`, `K30076`

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

## Submenu items

**PAINT_MENU** (`K31420`) → `011-paint.asm`
- PaintPen → `K32126`
- PaintSpray → `K31700`
- PaintBrush → `K32412`
- PaintEdBrush → `K33204`
- PaintInverse → `K33770`

**MISC_MENU** (`K35512`) → `008-misc.asm`
- ViewScreen → `K34422`
- ClearScreen → `K34456`
- BrightGrid1 → `K34476`
- BrightGrid2 → `K34510`
- RemoveGrid → `K34522`
- ChangeColor → `K35044`
- VERS_MENU (submenu, no further named items) → `K36114`

**ATTRS_MENU** (`K43466`) → `006-attrs.asm`
- INK_MENU (submenu) → `K44176`
- PAPER_MENU (submenu) → `K44350`
- BORDER_MENU (submenu) → `K44522`
- BRIGHT_MENU (submenu) → `K45070`
- FLASH_MENU (submenu) → `K45536`
- OverSel → `K43262`
- InverseSel → `K43302`
- TranspSel → `K43340`
- StandSel → `K43372`

**SHAPES_MENU** (`K51544`) → `007-shapes.asm`
- ShapSel (7 shape-type entries, all dispatch through one handler) → `K46726`
- ElasticSel → `K51460`
- SnapHrzSel → `K51476`
- SnapVrtSel → `K51514`

**MAGNIFY_MENU** (`K52226`) → `014-magn.asm` (overlay: `ART2.MAC`)
- MagnifySel (x2/x4/x8) → `MAGSEL`
- MagnGrid → `MAGRID`
- nested LENS_MENU (`K52444`) — multiple `LensSelX` entries → `LENSEL`

**WIND_MENU** (`K55300`) → `009-windows.asm`
- W_Define → `K54114`
- W_Last → `K54756`
- W_WholeScr → `K54764`
- W_Clear → `K54602`
- W_CutPast → `K54160`
- W_CutClrPast → `K54154`
- W_Invert → `K54574`
- W_Merge → `K55032`
- W_Multiply → `K55050`

**FILL_MENU** (`K60524`) → `010-fill.asm` (overlay: `ART2.MAC`)
- FillSolid → `FILLSD`
- FillTexture → `FILLTX`
- FillWashTexure → `FILLWT`
- TEXED_MENU (submenu, init => `TEXEDI`) → `K61012`

**LENS_MENU** (`K52444`) → `014-magn.asm` (overlay handlers in `ART2.MAC`)
- x2/x4/x8 zoom entries → `LENSEL` (LensSelX)
- "Attrs." → `K43466` (jumps out to ATTRS_MENU)
- Set/Reset/Toggle → `ART33` (EditModeSel)
- "Menu" → `K52444` itself (refresh/re-open)
- Home/Left/Right/Up/Down → `LENSHM`/`LENSLT`/`LENSRT`/`LENSUP`/`LENSDN`

Matches the Z80 `LENS_MENU` table in `014-magn.asm` item-for-item.

**TEXED_MENU** (`K61012`) → `010-fill.asm` (overlay handlers in `ART2.MAC`), init => `TEXEDI`
- texture-edit-lens click → `TEXEDA` (Z80 `ld365`)
- "Menu"/back → `TEXEDB` (Z80 `ld3e0`)

**FILE** (`K40310`) → `012-file.asm`
- Code routine, not a `.WORD` table like the others. Opens `FILE_MENU` (`K41530`).

**FILE_MENU** (`K41530`) → `012-file.asm`, exit => `MAIN_MENU`
- Save/Load/Erase file → all 3 → `FileOper` (single handler dispatching on which item
  was picked)

## ATTRS_MENU color-pick submenus — `006-attrs.asm`

**INK_MENU** (`K44176`), init => `K44076` (INK_INIT)
- swatch-grid entries → `K43120` (ink-color-pick handler, informally commented "выбор
  цвета чернил" in the source; not yet given a formal `Subroutine` name)

**PAPER_MENU** (`K44350`), init => `K44314` (PAPER_INIT)
- swatch-grid entries → `K42756` (paper-color-pick handler, same pattern)

**BORDER_MENU** (`K44522`), init => `K44466` (BORDER_INIT)
- swatch-grid entry → `K42522` (`BordSel` in source comment — border-color-pick handler)

**BRIGHT_MENU** (`K45070`), init => `K44670` (BRIGHT_INIT)
- 3 entries (Off/On/Toggle) all → `K44624` (bright-flag select handler)

**FLASH_MENU** (`K45536`), init => `K45336` (FLASH_INIT)
- same 3-entry pattern as BRIGHT_MENU, all → `K45272` (flash-flag select handler)

INK/PAPER/BORDER/BRIGHT/FLASH all follow the same shape: an `_INIT` routine that calls
`PutAttrs` (`K17530`) to draw the swatch grid, plus a select handler called from the menu
items to apply the pick and redraw the cursor/checkmark. The select handlers are named
and breadcrumbed: `InkSel` (`K43120`), `PaperSel` (`K42756`), `BordSel` (`K42522`),
`BrightSel` (`K44624`), `FlashSel` (`K45272`) — all confirmed identical-name matches in
`006-attrs.asm`.

## Overlay headers

### ART1.MAC — Overlay #1 (0x6c00 in ART.SAV, 2404 words)

Header comment: text menu, font editor menu, font editor / symbol, font editor / buffer,
font editor / font.

| Entry label | Z80 file |
|---|---|
| `TEXTMN` | 005-text.asm |
| `FONTED` | 016-fonted.asm |

### ART2.MAC — Overlay #2 (2289 words)

Header comment: fill menu, FillTexture, FillWashTexure, drawing-lens menu,
magnifier-lens menu changes.

| Entry label | Z80 file | Notes |
|---|---|---|
| `FILLIT` | 010-fill.asm | FILL_MENU init |
| `FILLSD` | 010-fill.asm | FillSolid |
| `FILLTX` | 010-fill.asm | FillTexture |
| `FILLWT` | 010-fill.asm | FillWashTexure |
| `TEXEDA` | 010-fill.asm | texture edit |
| `TEXEDB` | 010-fill.asm | texture edit |
| `TEXEDI` | 010-fill.asm | TEXED_INIT |
| `LENSHM` | 014-magn.asm | LensHome |
| `LENSLT` | 014-magn.asm | LensLeft |
| `LENSRT` | 014-magn.asm | LensRight |
| `LENSUP` | 014-magn.asm | LensUp |
| `LENSDN` | 014-magn.asm | LensDown |
| `LENSEL` | 014-magn.asm | LensSelX |
| `ART33` | 014-magn.asm | EditModeSel — on/off/toggle in LENS_MENU |
| `MAGSEL` | 014-magn.asm | MagnifySel — x2/x4/x8 |
| `MAGRID` | 014-magn.asm | MagnGrid |
| `ART36` | 014-magn.asm | |
| `ART37` | 014-magn.asm | |
| `ART38` | 014-magn.asm | grid step calc for "NxN frame" items |
| `ART39` | 014-magn.asm | selection-frame picker |

## Known confirmed Z80 label pointers

Inline breadcrumbs left in the source (`; (z80_label)`) pointing at a specific Z80
routine, found while resolving each MS-0515 subroutine:

**ART.MAC**
- `PutAttrs` (`K17530`) → `PutAttrs` (006-attrs.asm)
- `ResetShapeAnchor` (`K47624`) → `lb2bc` (007-shapes.asm)
- `WindSelCleanup` (`K54052`) → `lbfed` (009-windows.asm)

**ART1.MAC** (all resolved against `005-text.asm` / `016-fonted.asm`)
- `TextCursorDraw` (`J67230`/`J67240`/`J67326`) → `la12e`/`la131`/`la15e`
- `TextCursorClamp` (`J67354`) → `la16b`
- `TextEntryKeyLoop` (`J67426`) → `la186`
- `TextMarkerDraw` (`J70300`) → `la2c5`
- `SymbolStretch` (`J70336`) → `la2d9`
- `SymbolRotateFwd`/`SymbolRotateBack` (`J70550`/`J70604`) → `la336`/`la34a`
- `TextPosStepLeft` (`J70702`) → `la374`
- `TextPlaceClamp` (`J71046`) → `la3b9`
- `TextRowSeparator` (`J71202`) → `la3f8`
- `RefreshSizeChecks` (`J71244`) → `la40f`
- `FontCaptureRow` (`J72726`) → `F_Capt1`/`F_Capt2` (016-fonted.asm)
- `ScanFireBreak` (`J74410`) → `ScanFire` (016-fonted.asm)
- `JumpIndirect` (`J74434`) → `_jphl_` (016-fonted.asm)
- `CharGridXY` (`J75242`) → `SetCharXY` (016-fonted.asm)

**ART2.MAC** (resolved against `010-fill.asm` / `014-magn.asm`)
- `ART2.MAC:34` — `; (ld188)` → `ld188` (010-fill.asm), coordinate quantization for
  texture-fill target cell. Target routine `L65714` still needs a formal name.
- `TextureAddrCur` (`L66110`) → `ld1d2`
- `PlotBrushRun` (`L67244`) → `ld54e`
- `LineStepFwd`/`LineStepRev` (`L70110`/`L70336`) → `ld652`, split into forward/reverse
  direction blocks
- `RowBoundTest` (`L70544`) → `ld6f8`
- `ClampDispatch` (`L70602`) → `ld728`
- `RowClamp` (`L70752`) → `ld768`
- `ColClamp` (`L71036`) → `ld786`
- `SegmentBufferStore` (`L71110`) → `ld79d`
- block `L66706`-`L71172` → Z80 block `ld462`-`ld79d` — whole mouse-driven
  fill/wash-texture drawing loop
- `PutXLens` (`L72634`) → `PutXLens` (014-magn.asm), `PutEditMode` (`L72754`) →
  `PutEditMode` (014-magn.asm) — identical names, confirmed

**Also confirmed** (identical-name matches, quick to verify): `_VrtLine`/`_HrzLine`
(`ART.MAC`) → `017-menu.asm`; `GetMasks` (`K60040`) → `009-windows.asm`; `PassFire`
(`K61754`) → `017-menu.asm`; `CharCursor`/`LensPrvChar`/`LensCurChar`/`CharAddr`/
`CharFHrz`/`CharFVrt2`/`CharRot1`/`CharScrlDn1` (`ART1.MAC`) → `016-fonted.asm`.

**Brush/paint routines** (`ART.MAC`) → `011-paint.asm`:
- `BrushCursorPosition` (`K31160`) → `l8d30`
- `DrawBrushIconGrid` (`K32220`) → `l8ebc`
- `PutCenteredIcon` (`K32262`) → `l8ed5`
- `BuildBrushMask` (`K34006`) → `l911c`
- `BrushMaskAdvance` (`K34234`) → `l9182`
- `BrushRadiusLookup` (`K34304`) → `l91a2` (indexes the table already breadcrumbed at
  `K34316` → `l91b4`)

**File dialog** (`ART.MAC`) → `012-file.asm`:
- `FilenameEdit` (`K40374`) / `FilenamePutChar` (`K40624`) → `InputName`
- `LensZoomRound` (`L72010`) → `lb7c0`
- `LensScanFire` (`L72050`) → `lb7da`
- `LensBarX`/`LensBarY` (`L72076`/`L72222`) → `lb7e6`/`lb818`
- `LensScale` (`L72344`) → `lb84e`
- `Mul16` (`L72412`) → `lb86b`
- `LensBoundsBox` (`L73536`) → `lb9f8`
- `LensPixelEdit` (`L73622`) → `lbb43`
- `SetLensZoom` (`L74322`) → `lbc4c`
- `ZoomRoundDown` (`L74702`) → `lbcd3`
- `LensInBounds` (`L74740`) → `lbce6`
- `DivByZoom` (`L75074`) → `lbd12`
- `MulByZoom` (`L75120`) → `lbd1f`

`CheckBreakStub` (`L67240`) looked like it should match Z80 `CheckBreak` (010-fill.asm)
by call position, but the MS-0515 body is just `SEC / RETURN` — a stub, not a real port
of the Break-key poll.

## Feature areas with no matching Z80 topic file

- `PrinterDumpByte`/`PrinterDumpRow`/`PrinterDumpPlot` (`ART2.MAC`, `L76150`/`L76200`/
  `L76414`) — screen dump to printer. No corresponding file in `x-spectrum-disasm/`
  identified — printer support may be MS-0515-specific, or the original wasn't
  disassembled for this feature.
- `ComputePrintPitch`/`RefreshPrintFlags` and the rest of the PRINT_MENU machinery in
  `ART.MAC` — same story, no Z80 counterpart.

## Feature parity: Z80-only and MS-0515-only routines

Full-inventory comparison (every `call`/`jp` target across all 14 Z80 topic files vs.
every `; Subroutine <Name>` in the three MAC files, matched by identical name, `;
(z80_label)` breadcrumb, or coverage elsewhere in this doc). Z80 local jump-target
labels (`l8a2b`-style addresses, `_Circle5/6/8`-style continuation labels) are excluded
— they're not distinct routines, just range-workarounds for an already-matched one.

### Z80 routines with no apparent MS-0515 counterpart

Candidates for "behavior missing from the port" — but a lot of these are plausibly just
*folded into* an already-ported routine under a different name rather than genuinely
absent, so confidence is noted per row. Worth checking individually before assuming a
feature was dropped.

| Z80 routine | Topic file | Likely feature | Confidence |
|---|---|---|---|
| `AttrHL0` / `AttrHL1` | 015-main.asm | attribute-address calc paired with `PixAddr0/1` | medium — may be inlined into `PixAddr0Attr` |
| `PixAddr1` | 015-main.asm | secondary pixel-address variant (companion to `PixAddr0`, which is ported) | medium |
| `CheckBeep` | 017-menu.asm | menu beep-on-error sound (distinct from the no-op `MenuBeep` stub) | high |
| `CheckKey` | 017-menu.asm | keyboard poll in menu loop | low — likely folded into `ScanKey`/`ProcessScanCode` |
| `ChkMsMove` | 017-menu.asm | mouse-movement-changed check | low — likely folded into `ProcessScanCode` |
| `ClrAttrs` | 015-main.asm | clear attribute plane separately from pixel plane | medium |
| `Copy0to1` / `Copy1to0` | 015-main.asm | screen-buffer 0↔1 copy | low — MS-0515 likely does this via bank-swap instead of a copy loop (see `Screen1to0`) |
| `CopyBuff` | 015-main.asm | generic buffer copy helper | low, generic |
| `CopyLine` | 015-main.asm | line copy | low — likely subsumed by `CopyLine0` |
| `IFileFnt` / `IFileSrc` | 012-file.asm | font/source-file specific load helpers | medium |
| `Inkey` | 012-file.asm | raw keyboard read in file dialog | low, generic |
| `InputName` | 012-file.asm | filename text entry | low — likely renamed to `FilenameEdit`/`FilenamePutChar` |
| `MousDrive` / `MouseFire` | 017-menu.asm | mouse driver poll / fire-button check | low — likely folded into `ProcessScanCode`/`cp_ArrFire` |
| `OnPage` | 015-main.asm | screen-page/bank test | medium |
| `P_LnAttr` / `P_LnClr` | 009-windows.asm | window line attribute/clear helpers | medium |
| `PassKey` | 012-file.asm | key pass-through in dialog | low, generic |
| `PrintA` / `PrtFlName` | 012-file.asm | print message / filename to screen | medium |

### MS-0515 routines with no Z80 origin

Genuinely new — mostly hardware/OS differences (bank-switched screen memory vs. ZX's
flat 6912-byte screen, RT-11's RAD-50 filenames, PDP-11 word-oriented pixel ops) rather
than new *features* of the program.

| MS-0515 routine | File | Why it's new |
|---|---|---|
| `EXX` | ART.MAC | emulates the Z80 `EXX` instruction itself, not a ported subroutine |
| `PrinterDumpByte`/`PrinterDumpRow`/`PrinterDumpPlot` | ART2.MAC | printer screen-dump, no Z80 topic file for it |
| `ComputePrintPitch` / `RefreshPrintFlags` | ART.MAC | PRINT_MENU machinery, no Z80 counterpart |
| `FilenameRad50Entry` | ART.MAC | RT-11 filesystem uses RAD-50 filename packing — no ZX equivalent possible |
| `CopyScreenToBuffer` / `CopyBufferToScreen` / `CopyAltScreenToPrimary` / `InitScreenBuffers` / `ScreenPageAddr` | ART.MAC | bank-switched screen memory management (multiple physical screen banks, unlike ZX's flat screen) |
| `RedrawLensWindow` | ART.MAC | memory-paging for lens redraw |
| `MouseToPageXY` / `ApplyPageOffsetY` | ART.MAC | mouse coordinate → paged-screen-bank translation |
| `PixPlotReentryGuard` | ART.MAC | reentrancy guard, likely interrupt-driven mouse/redraw specific |
| `SetPixelAttrRMW` / `PixAddr0Attr` | ART.MAC | attribute-byte read-modify-write — MS-0515's color-attribute cell format differs from ZX's ink/paper/bright/flash byte |
| `LensAttrHiNibble` / `LensAttrRaw` / `LensAttrShiftPack` / `NormalizeLensAttr` | ART.MAC | lens attribute nibble-packing specific to MS-0515's attribute encoding |
| `LensX4Decode0`..`LensX4Decode3` | ART.MAC | 4 decode variants for MS-0515-specific attribute layout at x4 lens zoom |
| `XorBox2Row` / `XorBox4Row` / `FillBox8Row` | ART.MAC | fixed-size pixel-box bit ops tied to PDP-11's word-oriented pixel layout |
| `ResetMouseAccel` | ART.MAC | mouse acceleration-state reset, mouse driver detail |

**Note:** a follow-up pass (see "Also confirmed" above) closed 22 of these. ~65 remain
unconfirmed, concentrated in three clusters that resisted a first matching attempt and
would benefit from a dedicated deeper look rather than more broad sweeps:
- **Window drag/marquee** (`ART.MAC`, `009-windows.asm`): `WindDragLoop`, `WindConfirmEdit`,
  `WindDragDelta`, `WindCommitEdit`, `WindBaseReset`, `WindClearEntry`,
  `WindDrawBaseEdges`, `WindMarqueeErase`, `WindEdgeBase`/`WindEdgeLive`,
  `WindRowTestBase`/`WindRowTestLive`, `WindDrawHrzEdges`, `WindEdgeClipPlot`,
  `WindVrtEdgeBase`, `BoxOutlineRedraw`, `BoxToWindow`, `NormalizeRect`
- **Shape drawing** (`ART.MAC`, `007-shapes.asm`): `ShapExeDispatch`, `ShapTriEdges`,
  `ShapDrawToEnd` (`ShapDeadSlot` is likely genuine dead code, low priority)
- **PRINT_MENU checkboxes** (`ART.MAC`): `RedrawPrintQualityFlag`/`PitchFlag`/
  `OrientFlag`/`FeedFlag` — plausibly no Z80 match at all (print-quality/pitch options
  may be MS-0515-specific), worth confirming one way or the other rather than leaving
  ambiguous

Remaining unconfirmed elsewhere: `PixClearRow`, `RestoreBuffRow`, `WindMarqueeVEdge`,
`DashHrzRun`, `PutImage`, `ImageTrailShift`, `PrtFlagXYInline`, `PixBoxVEdges`,
`PutTexturePreview`, `CommitTextureRows`, `LensPlotSet`/`LensPlotToggle`/`LensPlotRow`,
`LensApplyPixel`, `LensX4Decode0`-`3`, `BuildAttrMasks`, `PixAddr0Attr`,
`ShowFileConfirmBox`, `CloseFileConfirmBox`, `DrawLineSavePos`, `ProcessScanCode`
(`ART.MAC`); `TextPosStepDown`, `RedrawHeightFlag`/`WidthFlag`, `PrtTriFlag`,
`RedrawSidewayFlag`/`BoldFlag`/`CapsFlag`/`SnapHrzFlag` (`ART1.MAC`);
`DrawTextureSelFrame`, `ScanColClamp`, `RedrawLensBars` (`ART2.MAC`).

## Gaps / not yet detailed

- WIND_MENU's submenu table has some unnamed placeholder slots past the 9 named items
  above — not yet confirmed whether they're all genuinely unused or just undocumented.
- ~~Two data words remain genuinely unresolved~~ — resolved: `K32610` is `BrushItemH`,
  the custom-brush-size dialog's single menu item's Height field (confirmed via struct
  offset arithmetic against the `MenuOpen` item layout). `K37640` has zero references
  anywhere in the source — confirmed dead/unused, left uncommented with a note rather
  than a forced name.

## How to use this

1. Pick a routine you want to cross-check or improve the description of.
2. Find which menu branch it falls under (nearest preceding named menu/submenu entry in
   `ART.MAC`, or which `ART1.MAC`/`ART2.MAC` overlay it's in).
3. Open the matching Z80 file from the topic table above.
4. Match by call order / constants / register roles, not just line-for-line — the two
   ISAs and code layouts differ; Z80 is a reference for *behavior*, not a template.
5. If there's a direct Z80 label match, leave a `; (Z80Label)` breadcrumb like the ones
   listed above.
