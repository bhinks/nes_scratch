.include "constants.inc"

.segment "ZEROPAGE"
.importzp player_x, player_y, player_dir, buttons

.segment "CODE"
.import main
.export draw_player
.export update_player

.proc draw_player
  ; save registers
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA
  ; write player ship tile numbers
  LDA #$05
  STA $0201
  LDA #$06
  STA $0205
  LDA #$07
  STA $0209
  LDA #$08
  STA $020d
  ; write player ship tile attributes
  ; use palette 0
  LDA #$00
  STA $0202
  STA $0206
  STA $020a
  STA $020e
  ; store tile locations
  ; top left tile:
  LDA player_y
  STA $0200
  LDA player_x
  STA $0203
  ; top right tile (x + 8):
  LDA player_y
  STA $0204
  LDA player_x
  CLC
  ADC #$08
  STA $0207
  ; bottom left tile (y + 8):
  LDA player_y
  CLC
  ADC #$08
  STA $0208
  LDA player_x
  STA $020b
  ; bottom right tile (x + 8, y + 8)
  LDA player_y
  CLC
  ADC #$08
  STA $020c
  LDA player_x
  CLC
  ADC #$08
  STA $020f
  ; restore registers and return
  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc update_player
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  up_pressed:
    LDA buttons
    AND #%00001000
    CMP #%00001000
    BEQ move_up
  down_pressed:
    LDA buttons
    AND #%00000100
    CMP #%00000100
    BEQ move_down
  left_pressed:
    LDA buttons
    AND #%00000010
    CMP #%00000010
    BEQ move_left
  right_pressed:
    LDA buttons
    AND #%00000001
    CMP #%00000001
    BEQ move_right
    JMP exit_subroutine

  move_up:
    DEC player_y
    DEC player_y
    JMP exit_subroutine
  move_down:
    INC player_y
    INC player_y
    JMP exit_subroutine
  move_right:
    INC player_x
    INC player_x
    JMP exit_subroutine
  move_left:
    DEC player_x
    DEC player_x

  exit_subroutine:
    ; all done, clean up and return
    PLA
    TAY
    PLA
    TAX
    PLA
    PLP
    RTS
.endproc