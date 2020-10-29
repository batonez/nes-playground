.include "constants.inc"

.charmap 48, 91
.charmap 49, 92
.charmap 50, 93
.charmap 51, 94
.charmap 52, 95
.charmap 53, 96
.charmap 54, 97
.charmap 55, 98
.charmap 56, 99
.charmap 57, 100
.charmap 33, 101
.charmap 47, 102

.import load_sprite

.segment "CODE"
  .proc text_init
  ; initialize text vars
    LDA #30
    STA text_x
    LDA #30
    STA text_y

  ; load text sprites
    LDA text
    SEC
    SBC #65
    LDX #0
    JSR load_sprite
    STX sprite_addr

    RTS
  .endproc

  .proc text_update_sprites
    ; We do nothing here, just waste cycles
    ; Better to pass x and y to load_sprites and get rid of this code
    LDX sprite_addr

    LDA text_x
    STA OAMRAM + 3, X
    LDA text_y
    STA OAMRAM + 0, X

    RTS
  .endproc
  
  text: .asciiz "/"

.segment "BSS"
  sprite_addr: .res 1

  text_coord:
  text_x: .res 1
  text_y: .res 1

.export text_init
.export text_update_sprites

.export text_coord
.export text_x
.export text_y
