;>sa1 end

;#########################################################################
;# Prepare OAM

main:
    lda $1493|!addr
    ora $13D4|!addr
    ora $9D
    bne init
    lda $0D9B
    cmp #$C1
    beq init

.run_timer
    dec $0F30|!addr
    bpl .skip_update_timer
    lda #$28
    sta $0F30|!addr
    lda $0F31|!addr
    ora $0F32|!addr
    ora $0F33|!addr
    beq .no_kill
    ldx #$02
.loop
    dec $0F31|!addr,x
    bpl .done
    lda #$09
    sta $0F31|!addr,x 
    dex 
    bpl .loop
.done
    lda $0F31|!addr
    bne .no_speed_up
    lda $0F32|!addr
    and $0F33|!addr
    cmp #$09
    bne .no_speed_up
    lda #$FF
    sta $1DF9|!addr
.no_speed_up
    lda $0F31|!addr
    ora $0F32|!addr
    ora $0F33|!addr
    bne .no_kill
    jsl $00F606
.no_kill
.skip_update_timer

.run_coins
    lda $13CC|!addr
    beq ..no_coins
    dec $13CC|!addr
    inc $0DBF|!addr
    lda $0DBF|!addr
    cmp #$64
    bcc ..no_coins
    inc $18E4|!addr
    lda $0DBF|!addr
    sec 
    sbc #$64
    sta $0DBF|!addr
..no_coins

.max_lives
    lda $0DBE|!addr
    bmi ..skip
    cmp #$62
    bcc ..skip
    lda #$62
    sta $0DBE|!addr
..skip

.bonus_stars
    ldx $0DB3|!addr
    lda $0F48|!addr,x
    cmp #$64
    bcc ..skip
    lda #$FF
    sta $1425|!addr
    lda $0F48|!addr,x
    sec 
    sbc #$64
    sta $0F48|!addr,x
..skip
    rtl

end:
    lda $0100|!addr
    cmp #$14
    bne +
    lda $13D4|!addr
    bne +
    lda #$01
    sta $2250
    jsr draw_lives
    jsr draw_yoshi_coins
    jsr draw_bonus_stars
    jsr draw_item_box
    jsr draw_timer
    jsr draw_coins
    jsr draw_score
+   
    rtl

!ui_name_x_pos = $10
!ui_name_y_pos = $10
!ui_lives_x_pos = $18
!ui_lives_y_pos = $18
!ui_yoshi_coins_y_pos = $10
!ui_yoshi_coins_x_pos = $40
!ui_bonus_stars_x_pos = $48
!ui_bonus_stars_y_pos = $18
!ui_timer_x_pos = $98
!ui_timer_y_pos = $10

!ui_coins_x_pos = $C8
!ui_coins_y_pos = $10

!ui_score_x_pos = $B8
!ui_score_y_pos = $18

!ui_item_box_x_pos = $70
!ui_item_box_y_pos = $08



draw_lives:
.draw_name
    lda #!ui_name_x_pos
    sta $00
    lda #!ui_name_y_pos-1
    sta $01
    stz $02
    lda #$3E
    xba 
    ldx #$00
..loop
    lda $0DB3|!addr
    bne ..luigi
    lda .mario,x
    bra ..write
..luigi
    lda .luigi,x
..write
    jsr draw_ui_tile
    lda $00
    clc 
    adc #$08
    sta $00
    inx 
    cpx #$05
    bne ..loop
.draw_x
    lda #!ui_lives_x_pos
    sta $00
    lda #!ui_lives_y_pos-1
    sta $01
    lda #$C8
    jsr draw_ui_tile
.draw_live_count
    lda #!ui_lives_x_pos+$08
    sta $00
    ldy $0DBE|!addr
    iny 
    jsr mod_10
    pha 
    beq +
    tax 
    lda.w ui_numbers_white,x
    jsr draw_ui_tile
+   
    plx 
    lda #!ui_lives_x_pos+$10
    sta $00
    lda.w ui_numbers_white,x
    jsr draw_ui_tile
    rts

.mario
    db $E0,$E1,$E2,$E3,$E4
.luigi
    db $F0,$F1,$F2,$F3,$F4

draw_yoshi_coins:
    ldx $1422|!addr
    beq .return
    cpx #$05
    bcc .draw
.return
    rts 
.draw
    dex 
    lda #!ui_yoshi_coins_y_pos-1
    sta $01
    lda #!ui_yoshi_coins_x_pos
    sta $00
    lda #$3E
    xba 
.loop
    lda #$C6
    jsr draw_ui_tile
    lda $00
    clc 
    adc #$08
    sta $00
    dex 
    bpl .loop
    rts 

draw_bonus_stars:
.icon
    lda #$3E
    xba 
    lda #!ui_bonus_stars_y_pos-1
    sta $01
    lda #!ui_bonus_stars_x_pos
    sta $00
    lda #$C5
    jsr draw_ui_tile
    lda #!ui_bonus_stars_x_pos+$08
    sta $00
    lda #$C8
    jsr draw_ui_tile
.number
    lda #!ui_bonus_stars_x_pos+$18
    sta $00
    ldx $0DB3|!addr
    ldy $0F48|!addr,x
    jsr mod_10
    pha 
    beq +
    tyx 
    lda #!ui_bonus_stars_y_pos-$08-1
    sta $01
    lda.w ui_numbers_big_top,x
    jsr draw_ui_tile
    lda #!ui_bonus_stars_y_pos-1
    sta $01
    lda.w ui_numbers_big_bottom,x
    jsr draw_ui_tile
+   
    lda #!ui_bonus_stars_x_pos+$20
    sta $00
    plx 
    lda #!ui_bonus_stars_y_pos-$08-1
    sta $01
    lda.w ui_numbers_big_top,x
    jsr draw_ui_tile
    lda #!ui_bonus_stars_y_pos-1
    sta $01
    lda.w ui_numbers_big_bottom,x
    jsr draw_ui_tile
    rts

draw_item_box:
    lda #!ui_item_box_x_pos
    sta $00
    lda #!ui_item_box_y_pos-1
    sta $01
    lda #$02
    sta $02
    lda #$3E
    xba 
    lda #$B0
    jsr draw_ui_tile
    lda #!ui_item_box_x_pos+$10
    sta $00
    lda #$3E|$40
    xba 
    lda #$B0
    jsr draw_ui_tile
    lda #!ui_item_box_y_pos+$10-1
    sta $01
    lda #$3E|$40|$80
    xba 
    lda #$B0
    jsr draw_ui_tile
    lda #!ui_item_box_x_pos
    sta $00
    lda #$3E|$80
    xba 
    lda #$B0
    jsr draw_ui_tile
    lda #$3E
    xba 
    stz $02
    rts 

draw_timer:
.static
    lda #!ui_timer_x_pos
    sta $00
    lda #!ui_timer_y_pos-1
    sta $01
    lda #$C2
    jsr draw_ui_tile
    lda #!ui_timer_x_pos+$08
    sta $00
    lda #$C3
    jsr draw_ui_tile
    lda #!ui_timer_x_pos+$10
    sta $00
    lda #$C4
    jsr draw_ui_tile
.numbers
    lda #!ui_timer_y_pos+$08-1
    sta $01
    ldx $0F31|!addr
    beq +
    lda #!ui_timer_x_pos
    sta $00
    lda.w ui_numbers_yellow,x
    jsr draw_ui_tile
+   
    ldx $0F32|!addr
    txa 
    ora $0F31|!addr
    beq +
    lda #!ui_timer_x_pos+$08
    sta $00
    lda.w ui_numbers_yellow,x
    jsr draw_ui_tile
+   
    lda #!ui_timer_x_pos+$10
    sta $00
    ldx $0F33|!addr
    lda.w ui_numbers_yellow,x
    jsr draw_ui_tile
    rts 

draw_coins:
.static
    lda #!ui_coins_y_pos-1
    sta $01
    lda #!ui_coins_x_pos
    sta $00
    lda #$C6
    jsr draw_ui_tile
    lda #!ui_coins_x_pos+$08
    sta $00
    lda #$C8
    jsr draw_ui_tile
.nums
    ldy $0DBF|!addr
    jsr mod_10
    pha 
    beq +
    tyx 
    lda #!ui_coins_x_pos+$18
    sta $00
    lda.w ui_numbers_white,x
    jsr draw_ui_tile
+   
    plx 
    lda #!ui_coins_x_pos+$20
    sta $00
    lda.w ui_numbers_white,x
    jsr draw_ui_tile
    rts 

draw_score:
    lda #!ui_score_y_pos-1
    sta $01
    ;Yxxxxx0
    lda $0F36|!addr
    lsr #4
    sta $08
    beq +
    tax 
    lda #!ui_score_x_pos
    sta $00
    lda.w ui_numbers_white,x
    jsr draw_ui_tile
+   
    ;xYxxxx0
    lda $0F36|!addr
    and #$0F
    sta $09
    tax 
    ora $08
    beq +
    lda #!ui_score_x_pos+$08
    sta $00
    lda.w ui_numbers_white,x
    jsr draw_ui_tile
+   
    ;xxYxxx0
    lda $0F35|!addr
    lsr #4
    sta $0A
    tax 
    ora $08
    ora $09
    beq +
    lda #!ui_score_x_pos+$10
    sta $00
    lda.w ui_numbers_white,x
    jsr draw_ui_tile
+   
    ;xxxYxx0
    lda $0F35|!addr
    and #$0F
    sta $0B
    tax 
    ora $08
    ora $09
    ora $0A
    beq +
    lda #!ui_score_x_pos+$18
    sta $00
    lda.w ui_numbers_white,x
    jsr draw_ui_tile
+   
    ;xxxxYx0
    lda $0F34|!addr
    lsr #4
    sta $0C
    tax 
    ora $08
    ora $09
    ora $0A
    ora $0B
    beq +
    lda #!ui_score_x_pos+$20
    sta $00
    lda.w ui_numbers_white,x
    jsr draw_ui_tile
+   
    ;xxxxxY0
    lda $0F34|!addr
    and #$0F
    tax 
    ora $08
    ora $09
    ora $0A
    ora $0B
    ora $0C
    beq +
    lda #!ui_score_x_pos+$28
    sta $00
    lda.w ui_numbers_white,x
    jsr draw_ui_tile
+   
    ;xxxxxx0
    lda #!ui_score_x_pos+$30
    sta $00
    lda #$E5
    jsr draw_ui_tile
    rts 

ui_numbers:
.white
    db $E5,$E6,$E7,$E8,$E9,$EA,$EB,$EC,$ED,$EE
.yellow
    db $F5,$F6,$F7,$F8,$F9,$FA,$FB,$FC,$FD,$FE
.big
..top
    db $D0,$D1,$D3,$D3,$D5,$D7,$D9,$DA,$DB,$D0
..bottom
    db $DC,$D2,$D4,$D8,$D6,$D8,$DC,$D2,$DD,$DE

;###############################################################
;# Routine

draw_ui_tile:
    phx 
    rep #$10
    ldx !maxtile_pointer_max+0
    cpx !maxtile_pointer_max+8
    beq .no_slot
    sta !maxtile_allocation_ram+$02,x
    xba 
    sta !maxtile_allocation_ram+$03,x
    xba 
    lda $00
    sta !maxtile_allocation_ram+$00,x
    lda $01
    sta !maxtile_allocation_ram+$01,x
    dex #4
    stx !maxtile_pointer_max+0
    ldx !maxtile_pointer_max+2
    lda $02
    and #$03
    sta !maxtile_allocation_ram,x
    dex 
    stx !maxtile_pointer_max+2
.no_slot
    sep #$10
    plx 
    rts

mod_10:
    sty $2251
    stz $2252
    lda #$0A
    sta $2253
    stz $2254
    nop #3
    lda $2308
    ldy $2306
    rts 

scorecard_2:
    jsl scorecard
    jml $00AF35|!bank

scorecard:
    jsl $05CBFF
.static
    ldx.b #.x_disp_bonus-.x_disp-1
    stz $02
    lda #$3E
    xba 
..loop
    lda.l .x_disp,x
    sta $00
    lda.l .y_disp,x
    sta $01
    lda $0DB3|!addr
    bne ..luigi
    lda.l .text_mario,x
    bra ..write
..luigi
    lda.l .text_luigi,x
..write
    jsr draw_ui_tile
    dex 
    bpl ..loop

.bonus
    lda $13D9|!addr
    cmp #$01
    bcc ..skip 
    cmp #$02
    bcs +
    lda $1900|!addr
    beq ..skip
    lda $1424|!addr
    bpl ..skip
+
..static
    lda #$3E
    xba 
    ldx.b #.y_disp-.x_disp_bonus-1
..loop
    lda.l .x_disp_bonus,x
    sta $00
    lda.l .y_disp_bonus,x
    sta $01
    lda.l .text_mario_bonus,x
    jsr draw_ui_tile
    dex 
    bpl ..loop
..nums
    lda #$98
    sta $00
    lda $1900|!addr
    lsr #4
    beq +
    tax 
    lda #$78
    sta $01
    lda.l ui_numbers_big_top,x
    jsr draw_ui_tile
    lda #$80
    sta $01
    lda.l ui_numbers_big_bottom,x
    jsr draw_ui_tile
+   
    lda $1900|!addr
    and #$0F
    tax 
    lda #$A0
    sta $00
    lda #$78
    sta $01
    lda.l ui_numbers_big_top,x
    jsr draw_ui_tile
    lda #$80
    sta $01
    lda.l ui_numbers_big_bottom,x
    jsr draw_ui_tile
..skip

.timer
    lda #$68
    sta $01
    ldx $0F31|!addr
    beq +
    lda #$50
    sta $00
    lda.l ui_numbers_white,x
    jsr draw_ui_tile
+   
    ldx $0F32|!addr
    txa 
    ora $0F31|!addr
    beq +
    lda #$58
    sta $00
    lda.l ui_numbers_white,x
    jsr draw_ui_tile
+   
    lda #$60
    sta $00
    ldx $0F33|!addr
    lda.l ui_numbers_white,x
    jsr draw_ui_tile

.score
    lda #$01
    sta $2250

    rep #$10
    ldy $0F40|!addr
    sty $2251
    ldy.w #10000
    sty $2253
    nop #3
    lda $2306
    sta $08
    ldy $2308
    sty $2251
    ldy.w #1000
    sty $2253
    nop #3
    lda $2306
    sta $09
    ldy $2308
    sty $2251
    ldy.w #100
    sty $2253
    nop #3
    lda $2306
    sta $0A
    ldy $2308
    sty $2251
    ldy.w #10
    sty $2253
    nop #3
    lda $2306
    sta $0B
    lda $2308
    sta $0C
    sep #$10

    lda #$3E
    xba 
    lda #$68
    sta $01

    ldx $08
    beq +
    lda #$88
    sta $00
    lda.l ui_numbers_white,x
    jsr draw_ui_tile
+   
    ldx $09
    txa 
    ora $08
    beq +
    lda #$90
    sta $00
    lda.l ui_numbers_white,x
    jsr draw_ui_tile
+   
    ldx $0A
    txa 
    ora $08
    ora $09
    beq +
    lda #$98
    sta $00
    lda.l ui_numbers_white,x
    jsr draw_ui_tile
+   
    ldx $0B
    txa 
    ora $08
    ora $09
    ora $0A
    beq +
    lda #$A0
    sta $00
    lda.l ui_numbers_white,x
    jsr draw_ui_tile
+   
    lda #$A8
    sta $00
    ldx $0C
    lda.l ui_numbers_white,x
    jsr draw_ui_tile
    rtl

.x_disp
..mario
    db $68,$70,$78,$80,$88
..course
    db $48,$50,$58,$60,$68,$70
..clear
    db $80,$88,$90,$98,$A0,$A8
..timer
    db $48,$68,$70,$78,$80
..bonus
    db $50,$58,$60,$68,$70,$78,$88,$90

.y_disp
..mario
    db $40,$40,$40,$40,$40
..course
    db $50,$50,$50,$50,$50,$50
..clear
    db $50,$50,$50,$50,$50,$50
..timer
    db $68,$68,$68,$68,$68
..bonus
    db $80,$80,$80,$80,$80,$80,$80,$80

.text_mario
    db $E0,$E1,$E2,$E3,$E4
..course
    db $B2,$B3,$B4,$B5,$B6,$B7
..clear
    db $B2,$B8,$B7,$B9,$B5,$DF
..timer
    db $C7,$C8,$EA,$E5,$C9
..bonus
    db $EF,$B3,$FF,$B4,$B6,$DF,$C5,$C8

.text_luigi
    db $F0,$F1,$F2,$F3,$F4
..course
    db $B2,$B3,$B4,$B5,$B6,$B7
..clear
    db $B2,$B8,$B7,$B9,$B5,$DF
..timer
    db $C7,$C8,$EA,$E5,$C9
..bonus
    db $EF,$B3,$FF,$B4,$B6,$DF,$C5,$C8

pushpc 

org $00C944|!bank
    jsl scorecard
org $00AF29|!bank
    jml scorecard_2


org $05CC84
    jsr $CE4C
    rep #$20
    lda $02
    sta $0F40|!addr
    sep #$20
    jmp $CD26

org $05CF4D
    jmp $CFE6

org $05CD30
    sep #$30
    rts

org $05CD80
    jmp $CDD5

;---------------------------------------------------------------

; this was originally called as part of a 24-bit hex->dec conversion, now unneeded, so we use this area for a routin to add score
; call with X/Y in 8-bit mode; A in either, which will be preserved
; A should contain the 16-bit BCD value to add to the current player's score

org $008CB0|!bank
AddScore:
    ldx $0DB3|!addr    ; offset into score (+3 for luigi)
    beq .XSet
    ldx #$03

.XSet
    php
    sed
    rep #$21
    adc $0F34|!addr,x : sta $0F34|!addr,x
    sep #$20
    bcc .Done
    lda $0F36|!addr,x : adc #$00 : sta $0F36|!addr,x
    bcc .Done
    lda #$99
    sta $0F34|!addr,x : sta $0F35|!addr,x : sta $0F36|!addr,x

.Done:
    plp
    rtl


;-----------------------------------------------------------------

; add 5(0) points for breaking a turn block

org $028758
BreakTurnBlock:
    lda #$00
    xba
    lda #$05
    jsl AddScore
    bra .Continue

org $028773
.Continue:

;-----------------------------------------------------------------

; don't give score for coin score sprites (a la wiggler score glitch)
org $02AE01
    bra +
org $02AE35
+

; handle giving points from score sprites

org $02AE12
ScoreSpriteGivePoints:
    lda.w .PointsHigh,y
    xba
    lda.w .PointsLow,y
    jsl AddScore
    bra .Continue

org $02AE35
.Continue:

; score sprite values, converted to BCD

org $02AD78
.PointsLow:
    db $00,$01,$02,$04,$08,$10,$20,$40
    db $80,$00,$00,$00,$00,$00,$00,$00
    db $00

.PointsHigh:
    db $00,$00,$00,$00,$00,$00,$00,$00
    db $00,$01,$02,$04,$08,$00,$00,$00
    db $00


;-------------------------------------------------------

; handle giving points from the course clear countdown

org $05CEF5
CourseClear:
    jsl AddScore_XSet
    bra .Continue

org $05CF05
.Continue:

; point value table, converted to BCD
org $05CEC6
.Points:
    dw $0001, $0010

;-------------------------------------------------------

org $0081F4            ; JSR $008DAC
    BRA + : NOP : +
org $0082E8            ; JSR $008DAC
    BRA + : NOP : +
org $00A5A8            ; JSR $008CFF
    BRA + : NOP : +
org $00985A            ; JSR $008CFF
    BRA + : NOP : +
org $00A2D5            ; JSR $008E1A
    BRA + : NOP : +
org $00A5D5            ; JSR $008E1A
    BRA + : NOP : +
    
    
org $008275            ; this one nukes the IRQ
    JMP NMI_hijack

org $008C81
NMI_hijack:
    LDA $0D9B|!addr
    BNE .special
    if !sa1
        LDX #$81        ; don't do IRQ (lated stored to $4200)
    else
        LDA #$81        ; don't do IRQ
        STA $4200
    endif
    LDA $22            ; update mirrors
    STA $2111
    LDA $23
    STA $2111
    LDA $24
    STA $2112
    LDA $25
    STA $2112
    LDA $3E
    STA $2105
    LDA $40
    STA $2131
    JMP $82B0
    
.special
    JMP $827A    

    print pc
    warnpc $009012

pullpc 