.include "constants.inc"

.segment "ZEROPAGE"
.importzp enemy_x, enemy_y

.segment "CODE"
.import main
.export draw_enemy
.export update_enemy

.proc draw_enemy
  ; save registers
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA
  ; write enemy ship tile numbers
  LDA #$07
  STA $0211
  LDA #$08
  STA $0215
  LDA #$05
  STA $0219
  LDA #$06
  STA $021d
  ; write enemy ship tile attributes
  ; use palette 0
  LDA #%10000010
  STA $0212
  STA $0216
  LDA #%00000010
  STA $021a
  STA $021e
  ; store tile locations
  ; top left tile:
  LDA enemy_y
  STA $0210
  LDA enemy_x
  STA $0213
  ; top right tile (x + 8):
  LDA enemy_y
  STA $0214
  LDA enemy_x
  CLC
  ADC #$08
  STA $0217
  ; bottom left tile (y + 8):
  LDA enemy_y
  CLC
  ADC #$08
  STA $0218
  LDA enemy_x
  STA $021b
  ; bottom right tile (x + 8, y + 8)
  LDA enemy_y
  CLC
  ADC #$08
  STA $021c
  LDA enemy_x
  CLC
  ADC #$08
  STA $021f
  ; restore registers and return
  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc update_enemy
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  JSR move_down
  JSR move_right

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

.proc move_up
  DEC enemy_y
  RTS
.endproc

.proc move_down
  INC enemy_y
  RTS
.endproc

.proc move_right
  INC enemy_x
  RTS
.endproc

.proc move_left
  DEC enemy_x
  RTS
.endproc