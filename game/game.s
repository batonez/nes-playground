.import oam_pointer
.import timer
.import player_init
.import block_init
.import text_init
.import init_objects_array

.segment "CODE"
  .proc game_init
  ; initialize oam pointer
    LDA #0
    STA oam_pointer
  ; initialize nmi timer 
    STA timer

    JSR init_objects_array
    JSR player_init
    JSR text_init

    LDX #80
    LDY #200
    JSR block_init
    LDX #88
    LDY #200
    JSR block_init
    LDX #96
    LDY #200
    JSR block_init

    RTS
  .endproc

  .proc game_main
    forever:
      JMP forever
    RTS
  .endproc

  .proc nmi_loop
    RTS
  .endproc

.export game_init
.export game_main
.export nmi_loop

