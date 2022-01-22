.include "constants.inc"

.segment "ZEROPAGE"
.importzp player_x, player_y, explosion_frames

.segment "CODE"
.import main
.export end_game

.proc end_game
  ; save registers
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA
  
  LDA #$00
  STA $0211
  STA $0215
  STA $0219
  STA $021d
  STA $0212
  STA $0216
  STA $021a
  STA $021e
  STA $0210
  STA $0213
  STA $0214
  STA $0217
  STA $0218
  STA $021b
  STA $021c
  STA $021f
  

  LDA #$0a
  STA $0201
  STA $0205
  STA $0209
  STA $020d
  ; write player ship tile attributes
  ; use palette 0
  LDA #%00000001
  STA $0202
  LDA #%01000001
  STA $0206
  LDA #%10000001
  STA $020a
  LDA #%11000001
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
  LDA explosion_frames
  CMP #10
  BCS frame_2
  JMP end
  frame_2:
  LDA #$0b
  STA $0201
  STA $0205
  STA $0209
  STA $020d
  LDA explosion_frames
  CMP #30
  BCS frame_3
  JMP end
  frame_3:
  LDA #$0c
  STA $0201
  STA $0205
  STA $0209
  STA $020d
  LDA explosion_frames
  CMP #40
  BCS frame_4
  JMP end
  frame_4:
  LDA #$0d
  STA $0201
  STA $0205
  STA $0209
  STA $020d
  LDA explosion_frames
  CMP #60
  BCS frame_5
  JMP end
  frame_5:
  LDA #$00
  STA $0201
  STA $0205
  STA $0209
  STA $020d

  end:
  ; restore registers and return
  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc
