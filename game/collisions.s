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
    ADC #8
    CMP block_y
    BCC skip_resolve
      LDA player_y
      CLC
      ADC #8
      SEC
      SBC block_y
      STA y_dist

      LDA player_y
      SEC
      SBC y_dist
      STA player_y
    skip_resolve:
    RTS
  .endproc

.segment "BSS"
  x_dist: .res 1
  y_dist: .res 1

.export resolve_collisions
