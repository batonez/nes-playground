.import player_coord
.import player_x
.import player_y
.import player_size

.import block_coord
.import block_x
.import block_y
.import block_size

.import beep

.segment "CODE"
  .proc resolve_collisions
    LDA #0
    STA x_dist
    STA y_dist
    STA x_sign
    STA y_sign

    LDA player_y
    CLC
    ADC player_size + 1
    CMP block_y
    BCC end

    LDA block_y
    CLC
    ADC block_size + 1
    CMP player_y
    BCC end

    LDA player_x
    CLC
    ADC player_size
    CMP block_x
    BCC end

    LDA block_x
    CLC
    ADC block_size
    CMP player_x
    BCC end

    caclulate_y_dist:
    LDA block_y
    CLC
    ADC block_size + 1
    SEC
    SBC player_y
    STA y_dist

    LDA player_y
    CLC
    ADC player_size + 1
    SEC
    SBC block_y
    CMP y_dist
    BCS skip_overwrite_y
    STA y_dist
    LDA #1
    STA y_sign
    skip_overwrite_y:

    caclulate_x_dist:
    LDA block_x
    CLC
    ADC block_size
    SEC
    SBC player_x
    STA x_dist

    LDA player_x
    CLC
    ADC player_size
    SEC
    SBC block_x
    CMP x_dist
    BCS skip_overwrite_x
    STA x_dist
    LDA #1
    STA x_sign
    skip_overwrite_x:

    JSR resolve_collision

    end:
    RTS
  .endproc

  .proc resolve_collision
    LDA #1
    STA axis
    LDA y_dist
    STA dist
    LDA y_sign
    STA sign

    LDA x_dist
    CMP y_dist
    BCS skip_axis_override
    LDA #0
    STA axis
    LDA x_dist
    STA dist
    LDA x_sign
    STA sign
    skip_axis_override:
 
    LDA sign
    AND #1
    BEQ add

    LDX axis
    LDA player_coord, X
    SEC
    SBC dist
    STA player_coord, X
    RTS

    add:
    LDX axis
    LDA player_coord, X
    CLC
    ADC dist
    STA player_coord, X
    
    RTS
  .endproc

.segment "BSS"
  x_dist: .res 1
  y_dist: .res 1
  x_sign: .res 1
  y_sign: .res 1
  dist: .res 1
  axis: .res 1
  sign: .res 1

.export resolve_collisions
