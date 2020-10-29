.include "constants.inc"
.include "emu.inc"

.import set_palettes
.import game_init
.import game_main
.import resolve_collisions

.import block_update_sprites

.import player_update_sprites
.import player_simulation_tick
.import left_handler
.import right_handler
.import up_handler
.import down_handler
.import a_handler
.import a_handler_down

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

  JSR simulation_tick
  JSR resolve_collisions
  JSR player_update_sprites
  JSR block_update_sprites

  JSR read_input
  JSR dispatch_input_event

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

.proc dispatch_input_event
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
  skip_a_handler:

  TXA
  AND #%10000000
  BEQ skip_a_handler_down
  AND buttons_prev
  BNE skip_a_handler_down
  JSR a_handler_down
  skip_a_handler_down:

  RTS
.endproc

.proc read_input
  LDA buttons
  STA buttons_prev

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
buttons_prev: .res 1
oam_pointer: .res 1
timer: .res 1

.export load_sprite
.export oam_pointer
.export timer
.export beep
