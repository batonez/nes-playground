.include "constants.inc"
.include "emu.inc"

.import set_palettes
.import game_init
.import game_main

.import update_player_sprites
.import player_simulation_tick
.import left_handler
.import right_handler
.import up_handler
.import down_handler
.import a_handler

.segment "VECTOR"
  .addr nmi, reset, irq

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

  JSR update_player_sprites
  JSR simulation_tick
  JSR read_input
  JSR handle_input

  INC timer
  LDA #2
  CMP timer
  BCS skip_timer_zeroing
  LDA #0
  STA timer
  skip_timer_zeroing:

  PLA
  TAX
  PLA
  RTI

irq:
  rti

.proc reset
  JSR set_palettes
  JSR game_init

; turn on NMIs, sprites use first pattern table
  LDA #%10010000  
  STA PPUCTRL

; turn on screen
  LDA #%00011110  
  STA PPUMASK

  JSR game_main
.endproc

.proc handle_input
  LDX buttons

  TXA
  AND #%00000001
  BEQ skip_right_handler
  JSR right_handler
  skip_right_handler:

  TXA
  AND #%00000010
  BEQ skip_left_handler
  JSR left_handler
  skip_left_handler:

  TXA
  AND #%00000100
  BEQ skip_down_handler
  JSR down_handler
  skip_down_handler:

  TXA
  AND #%00001000
  BEQ skip_up_handler
  JSR up_handler
  skip_up_handler:

  TXA
  AND #%10000000
  BEQ skip_a_handler
  JSR a_handler
  LDA #0
  STA jump_btn_pressed
  skip_a_handler:
  RTS
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

.proc simulation_tick
  JSR player_simulation_tick
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
  STA OAMRAM + 1, Y
  TXA
  STA OAMRAM + 2, Y
  LDA #$00
  STA OAMRAM + 0, Y
  STA OAMRAM + 3, Y

  LDA oam_pointer
  TAX
  CLC
  ADC #4
  STA oam_pointer
  RTS
.endproc

.segment "BSS"
buttons: .res 1
oam_pointer: .res 1
jump_btn_pressed: .res 1
timer: .res 1

.export load_sprite
.export oam_pointer
.export timer
.export jump_btn_pressed
