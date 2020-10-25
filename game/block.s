.include "constants.inc"

.import load_sprite

.segment "CODE"
  .proc block_init
  ; initialize block vars
    LDA #80
    STA block_x
    LDA #208
    STA block_y

  ; load block sprites
    LDA #3
    LDX #0
    JSR load_sprite
    STX sprite_addr

    RTS
  .endproc

  .proc block_update_sprites
    ; We do nothing here, just waste cycles
    ; Better to pass x and y to load_sprites and get rid of this code
    LDX sprite_addr

    LDA block_x
    STA OAMRAM + 3, X
    LDA block_y
    STA OAMRAM + 0, X

    RTS
  .endproc

.segment "BSS"
  sprite_addr: .res 1
  block_x: .res 1
  block_y: .res 1

.export block_init
.export block_update_sprites

