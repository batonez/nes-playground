.include "constants.inc"

.import load_sprite
.import timer

.segment "CODE"
  .proc player_init
  ; initialize player vars
    LDA #0
    STA player_x
    LDA #1
    STA player_y
    STA jump_force
    STA is_on_the_floor
    LDA #16
    STA player_size
    LDA #8
    STA player_size + 1

  ; load player sprites
    LDA #38
    LDX #1
    JSR load_sprite
    STX left_sprite_addr

    LDA #39
    LDX #1
    JSR load_sprite
    STX right_sprite_addr
    RTS
  .endproc

  .proc player_update_sprites
    LDX left_sprite_addr

    LDA player_x
    STA OAMRAM + 3, X
    LDA player_y
    STA OAMRAM + 0, X

    LDX right_sprite_addr
    STA OAMRAM + 0, X

    LDA player_x
    CLC
    ADC #7
    STA OAMRAM + 3, X
    RTS
  .endproc

  .proc player_simulation_tick
    ; jump/fall
    LDA player_y
    SEC
    SBC jump_force
    CLC
    ADC #2 ;gravity
    STA player_y

    ; decrease jump force by gravity every 3 frames if it's not zero
    LDA #0
    CMP jump_force
    BCS skip_force_reduction
    LDA #0
    CMP timer
    BCC skip_force_reduction

    LDA jump_force
    SEC
    SBC #1
    STA jump_force
    skip_force_reduction:
    RTS
  .endproc

  .proc right_handler
      INC player_x
      RTS
  .endproc

  .proc left_handler
    DEC player_x
    RTS
  .endproc

  .proc down_handler
    RTS
  .endproc

  .proc up_handler
    RTS
  .endproc

  .proc a_handler
    RTS
  .endproc

  .proc a_handler_down
    LDA #0
    CMP is_on_the_floor
    BCS skip_jump

    LDA #7
    STA jump_force

    skip_jump:
    RTS
  .endproc

.segment "BSS"
  left_sprite_addr: .res 1
  right_sprite_addr: .res 1
  jump_force: .res 1
  is_on_the_floor: .res 1
  player_size: .res 2

  player_coord:
  player_x: .res 1
  player_y: .res 1

.export player_init
.export player_update_sprites
.export player_simulation_tick

.export left_handler
.export right_handler
.export up_handler
.export down_handler
.export a_handler
.export a_handler_down
.export player_size

.export player_coord
.export player_x
.export player_y
.export player_size
.export is_on_the_floor

