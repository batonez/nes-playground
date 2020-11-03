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
    skip_overwrite_x:

    JSR resolve_collision

    end:
    RTS
  .endproc

  .proc resolve_collision
    LDA x_dist
    CMP y_dist
    BCS resolve_y
    
    resolve_x:
    LDA player_x
    SEC
    SBC x_dist
    STA player_x
    CLV
    BVC end

    resolve_y:
    LDA player_y
    SEC
    SBC y_dist
    STA player_y
    
    end:
    RTS
  .endproc

.segment "BSS"
  x_dist: .res 1
  y_dist: .res 1

.export resolve_collisions
