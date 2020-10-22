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
  JSR update_player

  PLA
  TAX
  PLA
  RTI

irq:
  rti

.proc reset
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

; initialize oam pointer
  LDA #0
  STA oam_pointer

; initialize player
  LDA #0
  STA player_x
  STA player_y

; load player sprites
  LDA #5
  LDX #0
  JSR load_sprite
  STX left_sprite_addr

  LDA #6
  LDX #0
  JSR load_sprite
  STX right_sprite_addr

; turn on NMIs, sprites use first pattern table
  LDA #%10010000  
  STA PPUCTRL

; turn on screen
  LDA #%00011110  
  STA PPUMASK

forever:
  JMP forever
.endproc

.proc handle_input
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
  BNE down_handler
  down_handled:

  TXA
  AND #%00001000
  BNE up_handler
  up_handled:

  RTS

  right_handler:
    INC player_x
    CLV
    BVC right_handled
  left_handler:
    DEC player_x
    CLV
    BVC left_handled
  down_handler:
    INC player_y
    CLV
    BVC down_handled
  up_handler:
    DEC player_y
    CLV
    BVC up_handled
.endproc

.proc read_input
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
.endproc

.proc update_player
  LDX left_sprite_addr

  LDA player_x
  STA $0203, X
  LDA player_y
  STA $0200, X

  LDX right_sprite_addr
  STA $0200, X

  LDA player_x
  ADC #7
  STA $0203, X
  RTS
.endproc

.proc beep
  lda #$01    ; enable pulse 1
  sta $4015
  lda #$08    ; period
  sta $4002
  lda #$02
  sta $4003
  lda #$bf    ; volume
  sta $4000
  rts
.endproc

.proc load_sprite
  LDY oam_pointer
  STA $0201, Y
  TXA
  STA $0202, Y
  LDA #$00
  STA $0200, Y
  STA $0203, Y

  LDA oam_pointer
  TAX
  ADC #4
  STA oam_pointer
  RTS
.endproc

.segment "BSS"
buttons: .res 1

oam_pointer: .res 1

left_sprite_addr: .res 1
right_sprite_addr: .res 1
player_x: .res 1
player_y: .res 1

