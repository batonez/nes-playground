.include "constants.inc"
.include "object_struct.inc"

.import load_sprite

.segment "CODE"
  .proc init_objects_array
    LDA #0
    STA array_size
    RTS
  .endproc

  .proc block_init
  ; initialize block vars
    INC array_size

    STX objects + COORD_X
    STY objects + COORD_Y
    LDA #8
    STA objects + SIZE_X
    STA objects + SIZE_Y

  ; load block sprites
    LDA objects + COORD_X
    STA $00
    LDA objects + COORD_Y
    STA $01
    LDA #40
    LDX #0
    JSR load_sprite
    STX objects + SPRITE_INDEX

    RTS
  .endproc

  .proc block_update_sprites
    RTS
  .endproc

.segment "BSS"
  array_size: .res 1
  objects: .res 50

.export init_objects_array
.export block_init
.export block_update_sprites

