.import oam_pointer
.import timer
.import player_init

.segment "CODE"
  .proc game_init
  ; initialize oam pointer
    LDA #0
    STA oam_pointer
  ; initialize nmi timer 
    STA timer

    JSR player_init

    RTS
  .endproc

  .proc game_main
    forever:
      JMP forever
    RTS
  .endproc

.export game_init
.export game_main
