.include "constants.inc"
.include "header.inc"

.segment "CODE"
.proc irq_handler
  RTI
.endproc

.proc nmi_handler
  LDA #$00
  STA OAMADDR
  LDA #$02
  STA OAMDMA
  
  ; update tiles *after* DMA transfer
  JSR update_player
  JSR draw_player
  
  LDA #$00
  STA $2005
  STA $2005

  RTI
.endproc

.import reset_handler

.export main
.proc main
  LDX PPUSTATUS
  LDX #$3f
  STX PPUADDR
  LDX #$00
  STX PPUADDR

  ;init zero-page values
  LDA #$80
  STA player_x
  LDA #$a0
  STA player_y

  load_palettes:
    LDA palettes,X
    STA PPUDATA
    INX
    CPX #$20
    BNE load_palettes
  
  ;write a nametable
  LDA PPUSTATUS
  LDA #$20
  STA PPUADDR
  LDA #$43
  STA PPUADDR
  LDX #$2f
  STX PPUDATA

  LDA PPUSTATUS
  LDA #$21
  STA PPUADDR
  LDA #$59
  STA PPUADDR
  LDX #$2f
  STX PPUDATA

  LDA PPUSTATUS
  LDA #$21
  STA PPUADDR
  LDA #$a5
  STA PPUADDR
  LDX #$2f
  STX PPUDATA

  LDA PPUSTATUS
  LDA #$23
  STA PPUADDR
  LDA #$15
  STA PPUADDR
  LDX #$2e
  STX PPUDATA

  ;write attribute table
  LDA PPUSTATUS
  LDA #$23
  STA PPUADDR
  LDA #$c0
  STA PPUADDR
  LDA #%01000000
  STA PPUDATA
  LDA PPUSTATUS
    
  vblankwait:
    BIT PPUSTATUS
    BPL vblankwait

    LDA #%10010000 ;turn on NMIs, sprites use first pattern table
    STA PPUCTRL
    LDA #%00011000 ;turn on screen
    STA PPUMASK
  forever:
    JMP forever
.endproc

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

  LDA player_x
  CMP #$e0
  BCC not_at_right_edge
  ; if BCC is not taken, we are greater than $e0
  LDA #$00
  STA player_dir    ; start moving left
  JMP direction_set ; we already chose a direction,
                    ; so we can skip the left side check
  not_at_right_edge:
    LDA player_x
    CMP #$10
    BCS direction_set
    ; if BCS not taken, we are less than $10
    LDA #$01
    STA player_dir   ; start moving right
  direction_set:
    ; now, actually update player_x
    LDA player_dir
    CMP #$01
    BEQ move_right
    ; if player_dir minus $01 is not zero,
    ; that means player_dir was $00 and
    ; we need to move left
    DEC player_x
    JMP exit_subroutine
  move_right:
    INC player_x
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

.segment "VECTORS"
.addr nmi_handler, reset_handler, irq_handler

.segment "CHR"
.incbin "starfield.chr"

.segment "RODATA"
palettes:
  .byte $0d, $00, $10, $20
  .byte $0d, $01, $11, $21
  .byte $0d, $06, $16, $26
  .byte $0d, $09, $19, $29
  .byte $0d, $00, $10, $20
  .byte $0d, $01, $11, $21
  .byte $0d, $06, $16, $26
  .byte $0d, $09, $19, $29

sprites:
  .byte $70, $05, $02, $80 ;sprite1 y,tile,attr,x
  .byte $70, $06, $02, $88
  .byte $78, $07, $02, $80
  .byte $78, $08, $02, $88

.segment "ZEROPAGE"
player_x: .res 1
player_y: .res 1
player_dir: .res 1