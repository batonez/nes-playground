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
    LDA player_y
    CLC
    ADC player_size + 1
    CMP block_y
    BCC skip_resolve

    LDA block_y
    CLC
    ADC block_size + 1
    CMP player_y
    BCC skip_resolve

    LDA player_x
    CLC
    ADC player_size
    CMP block_x
    BCC skip_resolve

    LDA block_x
    CLC
    ADC block_size
    CMP player_x
    BCC skip_resolve

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
      BCS skip_overwrite
      STA y_dist

      LDA player_y
      SEC
      SBC y_dist
      STA player_y
      CLV
      BVC skip_resolve

      skip_overwrite:
      LDA player_y
      CLC
      ADC y_dist
      STA player_y
    skip_resolve:
    RTS
  .endproc

.segment "BSS"
  x_dist: .res 1
  y_dist: .res 1

.export resolve_collisions
