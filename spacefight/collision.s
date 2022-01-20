.include "constants.inc"

.segment "ZEROPAGE"
.importzp player_x, player_y, enemy_x, enemy_y, dead

.segment "CODE"
.import main
.export collision_test

.proc collision_test
  test_x:
    LDA player_x
    SBC enemy_x
    CMP #$08
    BEQ test_y
    BCC test_y
    LDA player_x
    ADC #$08
    SBC enemy_x
    CMP #$08
    BEQ test_y
    BCC test_y
    JMP end
  test_y:
    LDA player_y
    SBC enemy_y
    CMP #$08
    BEQ end_game
    BCC end_game
    LDA player_y
    ADC #$08
    SBC enemy_y
    CMP #$08
    BEQ end_game
    BCC end_game
    JMP end
  end_game:
    LDA #$01
    STA dead
  end:
    RTS
.endproc
