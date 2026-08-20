# General architecture

Program structure, memory layout, and screen/hardware handling for the MS-0515 port of
Art Studio, as reconstructed in `ART.MAC`/`ART1.MAC`/`ART2.MAC`/`ARTDAT.MAC`. See also
`Menu-System.md` (UI engine) and `z80-crossref.md` (mapping to the ZX Spectrum original).

## Program structure

Three source files, one binary (`ART.SAV`):

- **`ART.MAC`** — main program. Assembled as a single `.ASECT` at address `001000`
  (link command: `ART,ART.MAP,ART.STB=ART/C`). Pulls in `ARTDAT.MAC` via
  `.INCLUDE /ARTDAT.MAC/` for static data (fonts, cursor sprites, brush shapes). Holds
  the menu engine, cursor/input handling, all always-resident feature code (paint,
  shapes, attributes, windows, undo, print) and the top-level `MAIN_MENU` dispatch.
- **`ART1.MAC`** — "Overlay #1": Text tool + Font editor (`TEXTMN`, `FONTED` and
  everything under them — `CHAR_MENU`, `FONT_MENU`, `FONTMISC_MENU`).
- **`ART2.MAC`** — "Overlay #2": Fill/texture tool + Magnifier/Lens (`FILLIT`/`FILLSD`/
  `FILLTX`/`FILLWT`, `TEXEDA`/`TEXEDB`/`TEXEDI`, and all the `LENS*`/`MAGSEL`/`MAGRID`/
  `ART33`/`ART36`-`ART39` magnifier code).

Per `ART.COM` (the LINK command file):
```
R LINK
ART,ART.MAP,ART.STB=ART/C
ART1/O:1/C
ART2/O:1
```
`ART1` and `ART2` are both linked into **overlay region 1** (`/O:1`) — RT-11's overlay
linker loads whichever one is needed on top of the same memory region, so **only one of
Text/Font-editor or Fill/Magnifier is resident at a time**. Both overlays start at the
same address, `0x6c00` (`066000` octal), confirmed by each file's own header comment
("Overlay #1"/"Overlay #2", starts at 0x6c00 in ART.SAV). Switching overlays is an
RT-11 runtime service call, not something visible as ordinary `JSR`/`CALL` in the
source — entry points like `TEXTMN`, `FONTED`, `FILLIT` are the overlay's public
entry symbols (`::`-suffixed global labels).

## Memory map

| Region | Address | Notes |
|---|---|---|
| Main program | `001000` and up | `ART.MAC`, assembled `.ASECT` |
| Overlay region 1 | `066000` (`0x6c00`) | `ART1.MAC` or `ART2.MAC`, mutually exclusive |
| Scratch line/menu-background buffer | `103600` | `BuffAddr` (`K30536`) — general-purpose save area used by `SaveMenuBackground`/`GetBuff`, texture captures, etc. |
| Screen page 0 | `040000` | primary visible screen bank |
| Screen page 1 | `100000` | secondary visible screen bank |
| Alt-RAM screen buffer | `120000` | off-screen working copy — see "Screen paging" below |
| Attribute plane offset | `+060000` | added to a pixel address by `PixAddr0Attr` to get the matching attribute-byte address |

Additionally, the font-editor overlay uses its own fixed working area starting at
`103600` for a temp screen buffer (`FONTED`'s `MOV #103600, K30536`), and the printer
dump code and file dialogs use small fixed scratch buffers of their own (`K41510`,
etc.) — not centrally documented, see the routines themselves.

## Screen addressing

**`PixAddr0`** (`K27752`, ported near-verbatim from Z80 `PixAddr0` in `015-main.asm`)
is the core address-translation routine: given pixel column X (R3, 0-255.) and row Y
(R4, 0-191.), it returns the screen byte address in R3. The computation:

1. `Y*80.` = row's byte offset into a pixel plane (Z80's screen is `Y*32` per third;
   MS-0515's `*80` reflects its different, wider byte-per-row layout).
2. If that offset exceeds a threshold, it wraps and selects the **second screen page**
   (`100000`); otherwise the **first** (`040000`) — see "Screen paging" below.
3. `X/8` = byte column. A hardware mode flag at `@#157760` is checked; if not set, the
   byte column is **doubled** — this accounts for an interleaved-plane byte stride
   (two logical planes interleaved byte-by-byte, doubling the effective row stride).
4. Final address = page base + row offset + byte column.

`PixAddr0Attr` (`K30060`) is `PixAddr0` plus a fixed `+060000` offset, for reading the
matching attribute byte instead of the pixel byte.

## Screen paging / bank switching

The MS-0515 has multiple physical RAM banks mapped through a hardware memory-control
register at `@#177400` (`K25506` holds the value written there). Code that touches
off-screen or alternate memory does the same dance throughout:

```
MTPS  #000340        ; disable interrupts
BIS   #000340, K25474
BIS   #000340, K25500
BIC   #000140, K25506   ; (or #000154, selecting different bank combos)
MOV   K25506, @#177400  ; commit to hardware
... do the memory access ...
BIS   #000140, K25506   ; restore
MOV   K25506, @#177400
MTPS  #000000        ; enable interrupts
```

This pattern (seen in `CopyScreenToBuffer`, `CopyBufferToScreen`,
`CopyAltScreenToPrimary`, `InitScreenBuffers`, `RedrawLensWindow`, and others) has **no
Z80 equivalent** — the ZX Spectrum has one flat 16K screen area, while MS-0515 needs
explicit bank switching to reach its alternate/off-screen RAM. This is the single
biggest hardware-coupling point to deal with when porting to a different PDP-11-like
machine (UKNC, BK) — those have their own, different, memory-mapping schemes.

Other hardware registers referenced in the source (values not fully documented — see
the commented-out stub lines near the end of `ART.MAC`):
- `@#157700` — "Memory control MS0515" (same register as `177400`? or an alias/related
  control port — needs confirming)
- `@#157706` — "SysRegC MS0515"
- `@#157760` — screen hardware mode flag (tested by `PixAddr0`)
- `@#177722` — serial port control (used by the printer-dump code and TX interrupt
  handler)

## Virtual screen pages (scroll feature)

Separately from the hardware bank-switching above, the program implements a **4-page
virtual screen** the user can scroll through with `SCRN_UP`/`SCRN_DN` (`K25666`/
`K25526`, top-level `MAIN_MENU` entries). `K30532` holds the current page index
(0-3.); routines like `ScreenPageAddr` (`K26476`) compute an address from it. This is
a program-level feature (matches the Z80 original's `l8c46`/screen-number variable),
distinct from the MS-0515-specific hardware page-0/page-1 selection inside `PixAddr0`.

## Data (`ARTDAT.MAC`)

Included into `ART.MAC`. Holds:
- `Font2` — the 96-character bitmap font (8 bytes/glyph)
- `TabBrush` / `Brush_0`-`Brush_15` — paint-brush shape bitmaps
- `TabCursor` / `Cursor_0`-`Cursor_9` — mouse cursor sprites (width, height, offsetX,
  offsetY, then row data — see `PutCursor` in `Menu-System.md`)
- `TextureAddr` — fill-texture pattern table (8 patterns, used by `FillTexture`)

Already well-labeled from earlier disasm work; not touched this session.

## File I/O (`FileOper`, `K41174`)

`FileOper` is the single handler behind all three FILE_MENU items (Save/Load/Erase) —
each item calls it with a different pre-set `_Attrs2` value (0/1/2), which `FileOper`
stores as `FileConfirmAction` (`K41506`) to remember which operation to run once the
filename is entered.

Flow:
1. Show the confirm box (`ShowFileConfirmBox`), print the "Имя файла ?" prompt, and
   run `FilenameEdit` (`K40374`) to read a name into `K41510` (16-byte buffer).
2. If the user cancelled (no name entered), close the box and stop
   (`CloseFileConfirmBox`).
3. Otherwise `FilenameRad50Entry` (`K41726`) packs the typed name into RAD-50 words —
   RT-11's filesystem stores names as two RAD-50-packed words (filename) plus one more
   (extension), not raw ASCII. The default extension is passed as an inline `.WORD`
   operand right after the `CALL` (`073512` for the image file, `023704` for a font
   file) — `FilenameRad50Entry` reads it off the return address and skips past it,
   a common MACRO-11 idiom for "pass a literal operand inline after the call."
4. Dispatch on `FileConfirmAction`: `000` = Load (`K23210`), `001` = Save (`K23202`),
   `002` = Erase (handled inline in `FileOper` itself).

**Save/Load** (`K23202`/`K23210`, converge at `K23214`) both:
- Pack the filename the same way (`FilenameRad50Entry`, same two default-extension
  values depending on `K24452`'s image-vs-font flag).
- Save additionally calls `SaveScreen` first (backs up the working screen into the
  `120000` alt-RAM buffer); Load calls `UpdateScreen` afterward (writes the alt-RAM
  buffer back to the visible screen) — see "Screen paging" above.
- Do the actual disk transfer via `EMT 346`/`EMT 347` (`.LOCK`/`.UNLOCK`, exclusive
  monitor access around the transfer) wrapping one or more `EMT 375` calls. Each
  `EMT 375` takes a small command block built on the stack (function code byte, buffer
  address, byte count, block number) — first to open/locate the file, then to
  read-or-write 256.-word (512.-byte) blocks directly between disk and screen memory
  (`040000`), advancing the block number each time. This is a low-level RT-11
  programmed-request convention, not the more familiar `.LOOKUP`/`.READW` macro calls —
  the command-block layout would need to be reverse-engineered further (byte offsets
  +0/+1/+2/+4/+6/+10 are used, exact field meanings not fully documented here) before
  porting this to a different OS/filesystem.
- On error, jump to a "file not found"/"disk full"-style message.

**Erase** (`K41174`'s own inline code): packs the filename via `FilenameRad50Entry`,
then does a single `EMT 375` transaction (function code `0` in the command block, per
`CLR (SP)`) to delete the directory entry — no data transfer.

None of this has a Z80 counterpart to preserve (the Z80 original's `012-file.asm`
routines like `InputName` cover only the filename-entry UI, matched already — see
`z80-crossref.md`; the actual storage mechanism is necessarily RT-11-specific). A port
to a different OS/filesystem replaces this whole disk-transfer section while keeping
the `FilenameEdit`/`FilenamePutChar` UI layer as-is.

## Input / hardware I/O summary

- Keyboard/mouse input arrives via `EMT 340` (`.TTYIN`), an RT-11 system call, not
  direct hardware polling — the OS terminal driver translates raw keyboard/mouse
  events into a byte stream `ScanKey` decodes (see `Menu-System.md`).
- Filenames are packed into RAD-50 (`FilenameRad50Entry`) for RT-11's filesystem — this
  has no ZX Spectrum equivalent and will need reworking for any non-RT-11 target.
- Printer output goes through `SendToPrinter` (`K65356`) and a serial UART control
  register (`@#177722`) — also MS-0515/RT-11-specific, no Z80 origin.

## Self-modifying code

The program writes into its own instruction stream in 13 places, all marked in the
source with `!!MUT-...!!` comments. There are two distinct idioms, with very different
porting implications.

### Idiom A — patched opcode (true self-modifying code)

Only one case, but the important one.

**`CursSave` / `CursorHide` copy loop** (`ART.MAC`, `K13230`/`K13232`/`K13234`)

Three consecutive `NOP`s in the inner loop of the shared save/restore routine
(`K13166`). Before the loop runs, the caller loads R0 with a *complete PDP-11
instruction word* and stores it over all three `NOP`s:

| Caller | R0 value | Instruction written | Effect |
|---|---|---|---|
| `CursSave` (`K13114`) | `012321` | `MOV (R3)+,(R1)+` | screen → buffer |
| `CursorHide` (`K13142`) | `012123` | `MOV (R1)+,(R3)+` | buffer → screen |

One loop body serves both directions; the direction is chosen by rewriting the
instructions rather than by branching. Three copies are patched so three words move per
iteration without loop overhead.

This is the only place where an *opcode* is modified. Everything else below only
modifies operand words.

### Idiom B — immediate operand used as a variable slot

The other 12 cases exploit PDP-11 immediate addressing: the literal word embedded in an
instruction is also a perfectly good memory location, so the program uses it as a named
variable and refers to it as `<Label+offset>`. Executing the instruction writes the
slot; other code reads and updates it directly. This saves a word of data storage per
variable — a real concern in a program this size.

The instruction still executes normally; only the embedded literal changes. Note that
`<Label+2>` is the operand word and `<Label+3>` is that word's high byte.

| Site | Instruction | Slot used as | Written by |
|---|---|---|---|
| `K16654` (`ImageTrailShift`) | `MOV #000050, #000000` | bytes remaining to right screen edge (40. minus X/8) | executing the instruction, then `SUB R3, <K16654+4>` |
| `K16552` (`PutImage`) | `DEC #00001` | per-row column counter | `MOV <K16654+4>, <K16552+2>` |
| `K16754` (`PixPrint`) | `CLR #000000` | 16-bit shift register for sub-byte glyph placement — glyph byte goes into the high half (`<K16754+3>`), `ROR <K16754+2>` aligns it, both halves are then written to screen | the `CLR` itself, plus `BISB (R2)+, <K16754+3>` |
| `K23202` (Save file) | `MOV SP, #000000` | save/load direction flag — *executing* it stores nonzero SP = "save" | `CLR <K23202+2>` at `K23210` sets "load" |
| `K23720` | `MOV #000000, SP` | general scratch: saved SP during file ops; also reused in `ART2.MAC` as a saved-PSW slot (`MFPS`/`MTPS <K23720+2>`) | `MOV SP, <K23720+2>` in several places |
| `K64624` | `MOV #000000, R2` | current font base address — executing it loads R2 from the slot | `MOV R0, <K64624+2>` at `K24654` |
| `K42750` (`SetBorder`) | `MOV R0, #000000` | stores the computed border value — **no reader found anywhere in the source**; appears vestigial | the instruction itself |
| `L66104` (`ART2.MAC`) | `JMP @#L66104` | fill-mode dispatch vector, self-referential until patched | `FillTexture` writes `#L65642`, `FillWashTexure` writes `#L67220` |
| `L70776`, `L71044` (`ART2.MAC`) | `CMP R0, #177747` / `CMP R0, #000337` | top and bottom row bounds for the current virtual screen page | the `L66706` block: page index (`K30532`) × 8, negated, ±offset |

### Porting implications

- **Idiom A cannot survive** a port to any target where code is in ROM, is
  write-protected, or where an instruction cache is not flushed on write. It needs
  rewriting as either two separate loops or one loop with a direction flag. The
  performance motive (avoiding a per-word branch) matters much less on a target that
  isn't cycle-starved.
- **Idiom B is mechanical to remove** — each slot becomes an ordinary `.WORD` and the
  instruction takes a normal memory operand. Watch for the two cases where *executing*
  the instruction is what sets the value (`K23202`, `K16654`): converting those needs an
  explicit store added, or the surrounding logic breaks silently.
- `K42750` can simply be deleted once confirmed no reader exists.
- All 13 sites are greppable via the `MUT` marker, so the checklist is easy to
  regenerate: `grep -n "MUT" *.MAC`.

## Porting notes

The hardware/OS coupling points that will need rework for a UKNC or BK port, roughly in
order of how deeply embedded they are in the drawing code:

1. **`PixAddr0`'s addressing scheme** — row stride, page selection, and the
   interleaved-plane doubling are specific to MS-0515's screen memory layout. Any
   target with a different screen memory organization needs this rewritten, and
   everything calling it (nearly every drawing primitive) depends on its contract
   (X/Y in, screen byte address out) staying the same even if the internals change.
2. **Bank-switching sequences** — scattered inline throughout (see above), not behind
   a single abstraction. **105 writes to `@#177400`** across the three files (ART.MAC 96,
   ART1.MAC 3, ART2.MAC 6), plus 19 interrupt-disable blocks (`MTPS #000340`). Too many
   to convert by hand one at a time — either wrap the pattern in a MACRO-11 `.MACRO`
   first (can be done in the current source without changing the assembled bytes; verify
   with `fc /b`) or accept a very large mechanical diff.
3. **Self-modifying code** — 13 sites, see the section above. The `CursSave`/`CursorHide`
   opcode patch must be restructured; the other 12 are mechanical operand-slot
   conversions.
4. **RAD-50 filenames / RT-11 file I/O** — see "File I/O" above. The `EMT 375`
   command-block format is RT-11-specific and only partially documented here; needs
   full reverse-engineering before a port can replace it.
5. **Printer support** — isolated already (`SendToPrinter`, `ComputePrintPitch`,
   `RefreshPrintFlags`), no Z80 origin to preserve, easiest to either drop or rewrite
   fresh for the target.
6. Everything else (menu engine, cursor handling, paint/shape/fill/text/font-editor
   logic) is either architecture-neutral PDP-11 code or has a confirmed Z80 origin —
   see `z80-crossref.md` for what maps where.
