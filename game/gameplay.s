.import oam_pointer
.import left_sprite_addr
.import right_sprite_addr
.import jump_btn_pressed
.import jump_force
.import is_on_the_floor
.import player_x
.import player_y
.import timer
.import load_sprite

.segment "CODE"
  .proc game_init
  ; initialize oam pointer
    LDA #0
    STA oam_pointer

  ; initialize player
    LDA #0
    STA player_x
    STA player_y
    STA jump_force
    STA is_on_the_floor
    STA jump_btn_pressed

  ; initialize nmi timer 
    STA timer

  ; load player sprites
    LDA #5
    LDX #0
    JSR load_sprite
    STX left_sprite_addr

    LDA #6
    LDX #0
    JSR load_sprite
    STX right_sprite_addr
    RTS
  .endproc

  .proc game_main
    forever:
      JMP forever
    RTS
  .endproc

.export game_init
.export game_main
