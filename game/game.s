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
  PHA
  TXA
  PHA

; Copy sprites into PPU memory
  LDA #$00
  STA OAMADDR
  LDA #$02
  STA OAMDMA

  JSR read_input
  JSR handle_input

  PLA
  TAX
  PLA
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
  LDX #$0
  LDY #$0

write_next_sprite:
  LDA y_coords, Y ; Y-coord of first sprite
  STA $0200, X 
  INX
  LDA tiles, Y ; tile number of first sprite
  STA $0200, X 
  INX
  LDA attrs, Y ; attributes of first sprite
  STA $0200, X 
  INX
  LDA x_coords, Y ; X-coord of first sprite
  STA $0200, X 
  INX

  INY
  CLC
  CPY num_sprites
  BCC write_next_sprite

  LDA #%10010000  ; turn on NMIs, sprites use first pattern table
  STA PPUCTRL
  LDA #%00011110  ; turn on screen
  STA PPUMASK

forever:
  JMP forever

handle_input:
  LDX buttons

  TXA
  AND #%00000001
  BNE right_handler
  right_handled:

  TXA
  AND #%00000010
  BNE left_handler
  left_handled:

  TXA
  AND #%00000100
  BNE up_handler
  up_handled:

  TXA
  AND #%00001000
  BNE down_handler
  down_handled:

  RTS

  right_handler:
    INC $0203
    CLV
    BVC right_handled
  left_handler:
    DEC $0203
    CLV
    BVC left_handled
  up_handler:
    INC $0200
    CLV
    BVC up_handled
  down_handler:
    DEC $0200
    CLV
    BVC down_handled

read_input:
  LDA #$01
  STA JOYPAD1
  STA buttons
  LSR A
  STA JOYPAD1
  read_joy_bit:
    LDA JOYPAD1
    LSR A        ; bit 0 -> Carry
    ROL buttons  ; Carry -> bit 0; bit 7 -> Carry
    BCC read_joy_bit
  RTS

beep:
  lda #$01    ; enable pulse 1
  sta $4015
  lda #$08    ; period
  sta $4002
  lda #$02
  sta $4003
  lda #$bf    ; volume
  sta $4000
  rts

num_sprites: .byte $03
x_coords: .byte $00, $08, $0F
y_coords: .byte $00, $00, $00
tiles: .byte $05, $06, $03
attrs: .byte $00, $00, $00

.segment "BSS"
buttons: .res 1

