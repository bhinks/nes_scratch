; TODO
; enhance backgrounds
; attack
; collision detection
; animated explosion
; game over screen
; title screen
; score
; sound effects (shot, explosion)
; random enemy spawning
; music
; multiple lives
; power-ups (speed, extra life, ?)
; boss?

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

  ;get input from controller
  read_input:
    LDA #$01
    STA CTRL1
    STA buttons
    LSR A
    STA CTRL1
  loop:
    LDA CTRL1
    LSR A
    ROL buttons
    BCC loop

  ;update tiles *after* DMA transfer
  JSR update_player
  JSR draw_player

  JSR update_enemy
  JSR draw_enemy
  
  LDA #$00
  STA $2005
  STA $2005

  LDX #$20
  JSR draw_background
  LDX #$28
  JSR draw_background
  JSR scroll_background

  RTI
.endproc

.import reset_handler
.import draw_player
.import update_player
.import draw_background
.import scroll_background
.import draw_enemy
.import update_enemy

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

  LDA #$80
  STA enemy_x
  LDA #$0a
  STA enemy_y

  LDA #239   ;y is only 240 lines tall
  STA scroll

  load_palettes:
    LDA palettes,X
    STA PPUDATA
    INX
    CPX #$20
    BNE load_palettes

  vblankwait:
    BIT PPUSTATUS
    BPL vblankwait

    LDA #%10010000 ;turn on NMIs, sprites use first pattern table
    STA ppuctrl_settings
    STA PPUCTRL
    LDA #%00011000 ;turn on screen
    STA PPUMASK
  forever:
    JMP forever
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

.segment "ZEROPAGE"
player_x: .res 1
player_y: .res 1
player_dir: .res 1
scroll: .res 1
ppuctrl_settings: .res 1
buttons: .res 1
enemy_x: .res 1
enemy_y: .res 1
.exportzp player_x, player_y, player_dir, ppuctrl_settings, scroll, buttons, enemy_x, enemy_y