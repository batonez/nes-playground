;;; Size of PRG in units of 16 KiB.
PRG_NPAGE = 1
;;; Size of CHR in units of 8 KiB.
CHR_NPAGE = 1
;;; INES mapper number.
MAPPER = 0
;;; Mirroring (0 = horizontal, 1 = vertical)
MIRRORING = 1

;;; PPU registers.
PPUCTRL   = $2000
PPUMASK   = $2001
PPUSTATUS = $2002
OAMADDR   = $2003
OAMDATA   = $2004
PPUSCROLL = $2005
PPUADDR   = $2006
PPUDATA   = $2007

;;; Other IO registers.
OAMDMA    = $4014
APUSTATUS = $4015
JOYPAD1   = $4016
JOYPAD2   = $4017

.segment "INES"
  .byte $4e, $45, $53, $1a
  .byte PRG_NPAGE 
  .byte CHR_NPAGE
  .byte ((MAPPER & $0f) << 4) | (MIRRORING & 1)
  .byte MAPPER & $f0

.segment "VECTOR"
  .addr nmi
  .addr reset
  .addr irq

.segment "CHR0a"
  .incbin "graphics.chr"

.segment "CODE"
nmi:
  LDA #$00
  STA OAMADDR
  LDA #$02
  STA OAMDMA
  RTI

irq:
  rti

reset:

  ; write palettes
  LDX PPUSTATUS ; resets PPUADDR
  LDX #$3f
  STX PPUADDR
  LDX #$00
  STX PPUADDR

  ; four background palettes
  LDA #$22
  STA PPUDATA
  LDA #$16
  STA PPUDATA
  LDA #$2A
  STA PPUDATA
  LDA #$08
  STA PPUDATA

  LDA #$22
  STA PPUDATA
  LDA #$16
  STA PPUDATA
  LDA #$2A
  STA PPUDATA
  LDA #$08
  STA PPUDATA

  LDA #$22
  STA PPUDATA
  LDA #$16
  STA PPUDATA
  LDA #$2A
  STA PPUDATA
  LDA #$08
  STA PPUDATA

  LDA #$22
  STA PPUDATA
  LDA #$16
  STA PPUDATA
  LDA #$2A
  STA PPUDATA
  LDA #$08
  STA PPUDATA

  ; four foreground palettes
  LDA #$22
  STA PPUDATA
  LDA #$30
  STA PPUDATA
  LDA #$2A
  STA PPUDATA
  LDA #$08
  STA PPUDATA

  LDA #$22
  STA PPUDATA
  LDA #$16
  STA PPUDATA
  LDA #$2A
  STA PPUDATA
  LDA #$08
  STA PPUDATA

  LDA #$22
  STA PPUDATA
  LDA #$16
  STA PPUDATA
  LDA #$2A
  STA PPUDATA
  LDA #$08
  STA PPUDATA

  LDA #$22
  STA PPUDATA
  LDA #$16
  STA PPUDATA
  LDA #$2A
  STA PPUDATA
  LDA #$08
  STA PPUDATA
;;;;

  ; write sprite data
  LDA #$00
  STA $0200 ; Y-coord of first sprite
  LDA #$05
  STA $0201 ; tile number of first sprite
  LDA #%00000000
  STA $0202 ; attributes of first sprite
  LDA #$00
  STA $0203 ; X-coord of first sprite

  LDA #$00
  STA $0204
  LDA #$06
  STA $0205
  LDA #%00000000
  STA $0206
  LDA #$08
  STA $0207

  LDA #%10010000  ; turn on NMIs, sprites use first pattern table
  STA PPUCTRL
  LDA #%00011110  ; turn on screen
  STA PPUMASK

forever:
  jmp forever

