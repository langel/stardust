

;;;;; SUBROUTINES


nametable_fill: subroutine
	; a = nametable high address
	; temp00 = fill tile
	; temp01 = fill attribute
	; requires render_disable status
	sta PPU_ADDR
	lda #$00
	sta PPU_ADDR
	sta PPU_CTRL
	tax
	lda temp00
.loop0
	sta PPU_DATA
	inx
	bne .loop0
.loop1
	sta PPU_DATA
	inx
	bne .loop1
.loop2
	sta PPU_DATA
	inx
	bne .loop2
.loop3
	sta PPU_DATA
	inx
	cpx #$c0
	bne .loop3
	; attributes here
	lda temp01
.attr_loop
	sta PPU_DATA
	inx
	bne .attr_loop
	rts


nametable_load: subroutine
	; a = nametable high address
	; temp00 = .nam lo address
	; temp01 = .nam hi address
	sta PPU_ADDR
	lda #$00
	sta PPU_ADDR
	sta PPU_CTRL
	tay
.loop0
	lda (temp00),y
	sta PPU_DATA
	iny
	bne .loop0
	inc temp01
.loop1
	lda (temp00),y
	sta PPU_DATA
	iny
	bne .loop1
	inc temp01
.loop2
	lda (temp00),y
	sta PPU_DATA
	iny
	bne .loop2
	inc temp01
.loop3
	lda (temp00),y
	sta PPU_DATA
	iny
	bne .loop3
	rts



shift_divide_7_into_8: subroutine
	; kills x
	; temp00 dividend
	; temp01 divisor
	; RETURNS
	; A = remainder
	; temp00 = result
	; temp01 = remainder
	ldx #$08
	lda #$00
	clc
.loop
	asl temp00
	rol 
	cmp temp01
	bcc .no_sub
	sbc temp01
	inc temp00
.no_sub
	dex
	bne .loop
	sta temp01
	rts


shift_divide_7_into_16: subroutine
	; kills x
	; temp00 dividend lo
	; temp01 dividend hi
	; temp02 divisor
	; RETURNS
	; A = remainder
	; temp00 = result
	; temp01 = remainder
	ldx #16
	lda #0
.loop
	asl temp00
	rol temp01
	rol 
	cmp temp02
	bcc .no_sub
	sbc temp02
	inc temp00
.no_sub
	dex
	bne .loop
	sta temp01
	rts


shift_divide_15_into_16: subroutine
	; kills x y
	; temp00 = dividend lo
	; temp01 = dividend hi
	; temp02 = divisor lo
	; temp03 = divisor hi
	; RETURNS
	; temp00 = result (lo only)
	; temp04 = remainder lo
	; temp05 = remainder hi

	lda #0	        ; zero out remainder
	sta temp04
	sta temp05
	ldx #16	        

.loop	
	asl temp00	
	rol temp01	
	rol temp04	
	rol temp05
	lda temp04
	sec
	sbc temp02	; check if divisor fits
	tay	       
	lda temp05
	sbc temp03
	bcc .skip	
	sta temp05	
	sty temp04	
	inc temp00	; XXX could add result hi byte 
.skip	
	dex
	bne .loop	
	rts


shift_multiply: subroutine
	; shift + add multiplication
	; kills x
	; temp00, temp01 in = factors
	; returns little endian 16bit val
	;         at temp01, temp00
	lda #$00
	ldx #$08
	lsr temp00
.loop
	bcc .no_add
	clc
	adc temp01
.no_add
	ror
	ror temp00
	dex
	bne .loop
	sta temp01
	rts        


shift_percent: subroutine
	; a = 8bit base value
	; x = 8bit percentage
	; returns result in a
	sta temp00
	txa
	eor #$ff
	sta temp01
	lda #$00	; 12 cycles
	lsr temp00
	asl temp01
	bcs .not_7
	adc temp00
.not_7			; +15 per bit
	lsr temp00
	asl temp01
	bcs .not_6
	adc temp00
.not_6
	lsr temp00
	asl temp01
	bcs .not_5
	adc temp00
.not_5
	lsr temp00
	asl temp01
	bcs .not_4
	adc temp00
.not_4
	lsr temp00
	asl temp01
	bcs .not_3
	adc temp00
.not_3
	lsr temp00
	asl temp01
	bcs .not_2
	adc temp00
.not_2
	lsr temp00
	asl temp01
	bcs .not_1
	adc temp00
.not_1		
	lsr temp00
	asl temp01
	bcs .not_0
	adc temp00
.not_0			; 15 * 7 + 12
	rts		; +6 = 123 cycles


registers_clear: subroutine
	lda #$00
	sta temp00
	sta temp01
	sta temp02
	sta temp03
	sta temp04
	sta temp05
	sta state00
	sta state01
	sta state02
	sta state03
	sta state04
	sta state05
	sta state06
	sta state07
	rts


rand: subroutine
	lda rng0
	lsr
	bcc .no_ex_or
	eor #$d4
.no_ex_or:
	sta rng0
	rts

rng_next subroutine
	lsr
	bcc .NoEor
	eor #$d4
.NoEor:
	rts

rng_prev subroutine
	asl
	bcc .NoEor
	eor #$a9
.NoEor:
	rts

; THESE ARE RIPPED FROM SMB2
rng_seed: subroutine
	lda #$86
	sta rng_seed0
	rts

rng_update: subroutine
	; destroys Y
	ldy #$00
	jsr rng_update_inner
	iny
rng_update_inner:
	lda rng_seed0
	asl
	asl
	sec
	adc rng_seed0
	sta rng_seed0
	asl rng_seed1
	lda #$20
	bit rng_seed1
	bcc rng_reverse
	beq rng_eor
	bne rng_inc_eor
rng_reverse:
	bne rng_eor
rng_inc_eor:
	inc rng_seed1
rng_eor:
	lda rng_seed1
	eor rng_seed0
	sta rng_val0,y
	rts


render_enable:
	lda #CTRL_NMI|CTRL_BG_1000
	sta PPU_CTRL	; enable NMI
	lda ppu_mask_emph
	ora #MASK_BG|MASK_SPR|MASK_SPR_CLIP|MASK_BG_CLIP
	sta PPU_MASK	; enable rendering
	rts


render_disable:
	lda #$00
	sta PPU_MASK	
	sta PPU_CTRL	
	rts


vsync_wait:
	bit PPU_STATUS
	bpl vsync_wait
	rts




collision_detect: subroutine
	; returns true/false in a
	clc
	lda collision_0_x
	adc collision_0_w
	bcs .no_collision ; make sure x+w is not less than x
	cmp collision_1_x
	bcc .no_collision
	clc
	lda collision_1_x
	adc collision_1_w
	cmp collision_0_x
	bcc .no_collision
	clc
	lda collision_0_y
	adc collision_0_h
	cmp collision_1_y
	bcc .no_collision
	clc 
	lda collision_1_y
	adc collision_1_h
	cmp collision_0_y
	bcc .no_collision
.collision
	lda #$ff
	rts
.no_collision
	lda #$00
	rts

player_calc_distance: subroutine
	; returns distance in a
	sec
	lda collision_0_x
	sbc collis_char_x
	bcs .x_done
	eor #$ff ; abs()
	adc #$01
.x_done
	sta temp00 ; x distance
	sec
	lda collision_0_y
	sbc collis_char_y
	bcs .y_done
	eor #$ff ; abs()
	adc #$01
.y_done
	sta temp01 ; y distance
	; check which is larger
	; then: max + min / 2
	lda temp00
	cmp temp01
	bcs .y_smaller
.x_smaller
	lda temp00
	lsr
	clc
	adc temp01
	rts
.y_smaller
	lda temp01
	lsr
	clc
	adc temp00
	rts



;;;;; CONTROLLER READING

BUTTON_A       EQM 1 << 7
BUTTON_B       EQM 1 << 6
BUTTON_SELECT 	EQM 1 << 5
BUTTON_START  	EQM 1 << 4
BUTTON_UP     	EQM 1 << 3
BUTTON_DOWN   	EQM 1 << 2
BUTTON_LEFT   	EQM 1 << 1
BUTTON_RIGHT  	EQM 1 << 0

controller_poller: subroutine
	ldx #$01
	stx JOYPAD1
	dex
	stx JOYPAD1
	ldx #$08
.read_loop
	lda JOYPAD1
	lsr
	rol temp00
	lsr
	rol temp01
	dex
	bne .read_loop
	lda temp00
	ora temp01
	sta temp00
	rts

controller_read: subroutine
	jsr controller_poller
.checksum_loop
	ldy temp00
	jsr controller_poller
	cpy temp00
	bne .checksum_loop
	lda temp00
	tay
	eor controls
	and temp00
	sta controls_d
	sty controls
	rts


sine_table:
	hex 808386898c8f9295
	hex 989b9ea2a5a7aaad
	hex b0b3b6b9bcbec1c4
	hex c6c9cbced0d3d5d7
	hex dadcdee0e2e4e6e8
	hex eaebedeef0f1f3f4
	hex f5f6f8f9fafafbfc
	hex fdfdfefefeffffff
	hex fffffffffefefefd
	hex fdfcfbfafaf9f8f6
	hex f5f4f3f1f0eeedeb
	hex eae8e6e4e2e0dedc
	hex dad7d5d3d0cecbc9
	hex c6c4c1bebcb9b6b3
	hex b0adaaa7a5a29e9b
	hex 9895928f8c898683
	hex 807c797673706d6a
	hex 6764615d5a585552
	hex 4f4c494643413e3b
	hex 393634312f2c2a28
	hex 2523211f1d1b1917
	hex 151412110f0e0c0b
	hex 0a09070605050403
	hex 0202010101000000
	hex 0000000001010102
	hex 0203040505060709
	hex 0a0b0c0e0f111214
	hex 1517191b1d1f2123
	hex 25282a2c2f313436
	hex 393b3e414346494c
	hex 4f5255585a5d6164
	hex 676a6d707376797c



decimal_x9_text_offset_80:
	hex 0080008100820083008400850086008700880089
	hex 8180818181828183818481858186818781888189
	hex 8280828182828283828482858286828782888289
	hex 8380838183828383838483858386838783888389
	hex 8480848184828483848484858486848784888489
	hex 8580858185828583858485858586858785888589
	hex 8680868186828683868486858686868786888689
	hex 8780878187828783878487858786878787888789
	hex 8880888188828883888488858886888788888889
	hex 8980898189828983898489858986898789888989
decimal_99_text_offset_80:
	hex 8080808180828083808480858086808780888089
	hex 8180818181828183818481858186818781888189
	hex 8280828182828283828482858286828782888289
	hex 8380838183828383838483858386838783888389
	hex 8480848184828483848484858486848784888489
	hex 8580858185828583858485858586858785888589
	hex 8680868186828683868486858686868786888689
	hex 8780878187828783878487858786878787888789
	hex 8880888188828883888488858886888788888889
	hex 8980898189828983898489858986898789888989



map_data:
	hex ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
	hex ffffffffffffffffffff2e30ffffffff1415163fffffffffffffffffffffffff
	hex ffffffffffffffffff2c2d2f0d0f111317183d3effffffffffffffffffffffff
	hex 0001020304050607080affff0c0e1012191a1bffff1cffffffffffffffffffff
	hex 1d1e1f2022242628090bffffff35383a3cff40414244ffffffffffffffffffff
	hex ffffff21232527292a2b31323336393bff4547ff43ffffffffffffffffffffff
	hex ffffffffffffffffffffffff3437ffffff4648ffffffffffffffffffffffffff
	hex ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff




metapattern_id_offset:
	; ((n >> 3) << 5) + ((n & $07) << 1);
	hex 00 02 04 06 08 0a 0c 0e
	hex 20 22 24 26 28 2a 2c 2e
	hex 40 42 44 46 48 4a 4c 4e
	hex 60 62 64 66 68 6a 6c 6e
	hex 80 82 84 86 88 8a 8c 8e
	hex a0 a2 a4 a6 a8 aa ac ae
	hex c0 c2 c4 c6 c8 ca cc ce
	hex e0 e2 e4 e6 e8 ea ec ee
	

	; DEBUG
#IF 0
	lda #$c0 ; x pos
	sta temp00
	lda #$03 ; attr
	sta temp02
	lda #$20
	sta temp01
	lda player_x_hi
	ldx #$c0
	jsr sprite_hex_display
	lda #$2c
	sta temp01
	lda player_x
	ldx #$c8
	jsr sprite_hex_display
	lda #$38
	sta temp01
	lda player_y
	ldx #$d0
	jsr sprite_hex_display
#ENDIF
	rts

; XXX replace with following subroutine
relic_tile_offset: subroutine
	; a = relic id / #$ff = empty
	; RETURNS
	; x = first row offset
	; y = second row offset
	; $20 + ((n >> 3) << 5) + ((n & $07) << 1);
	sta temp00
	lsr
	lsr
	lsr
	asl
	asl
	asl
	asl
	asl
	sta temp01
	lda temp00
	and #$07
	asl
	clc
	adc temp01
	adc #$20
	tax
	adc #$10
	tay
	rts
chr_metatile_offset: subroutine
	; a = metatile id
	; RETURNS
	; a = chr offset
	; ((n >> 3) << 5) + ((n & $07) << 1);
	sta temp00
	lsr
	lsr
	lsr
	asl
	asl
	asl
	asl
	asl
	sta temp01
	lda temp00
	and #$07
	asl
	clc
	adc temp01
	rts


state_relic_long_desc_str:
	hex f3dedcd1ffcbd5d8ccd4dcffe0d2ddd1ffcecadcceffe0d1ced7ffe2d8deffe0cecadbffddd1cedcceffd0d5d8dfcedcbfffffffffffffffffffffffffffffff
	hex f6d6cad5d5ffcee1d9d5d8dcd2dfcedcffddd1caddffd6cad4ceffdaded2ccd4ffe0d8dbd4ffd8cfffcbdbd2ddddd5ceffdbd8ccd4bfffffffffffffffffffff
	hex efcaddccd1ffd8d7ddd8ffcbd5d8ccd4dcffddd8ffccdbd8dcdcffe0d2cdceffd0cad9dcffd2d7ffcaffccd2d7ccd1bfffffffffffffffffffffffffffffffff
	hex f7d1cedcceffd1d2d0d1bfddceccd1ffcbd8d8dddcffd9deddffcaffdcd9dbd2d7d0ffd2d7ffe2d8dedbffdcddced9bfffffffffffffffffffffffffffffffff
	hex f6e0d2d6ffded7cdcedbe0caddcedbffe0d2ddd1ffddd1ceffd0dbcaccceffd8cfffcaffd6cedbd9cedbdcd8d7bfffffffffffffffffffffffffffffffffffff
	hex e4ffd5cecaddd1cedbffdccacdcdd5ceffddd8ffdbd2cdceffcaddd8d9ffcad7e2ffccdbcecadddedbceffd9cad2d7d5cedcdcd5e2bfffffffffffffffffffff
	hex e9d5d8caddffdcd5d8e0d5e2ffddd8ffddd1ceffd0dbd8ded7cdffe0d2ddd1ffddd1d2dcffced5ced0cad7ddffd9cadbcadcd8d5bfffffffffffffffffffffff
	hex f6d9d2d4e2ffdcd1d8cedcffddd1caddffcccadedcceffcdcad6cad0ceffddd8ffcad7e2ddd1d2d7d0ffddd1cee2ffddd8deccd1bfffffffffffffffffffffff
	hex e4ffe0d1d2dbd5d2d7d0ffced7cedbd0e2ffd9dbd8ddceccdddcffe2d8deffe0d1d2d5ceffcedaded2d9d9cecdbfffffffffffffffffffffffffffffffffffff
	hex f3dbd8ddceccddd2dfceffcadbd6d8dbffd6cacdceffcfdbd8d6ffd1ded0ceffd6d8d5d5dedcd4ffdcd1ced5d5dcbfffffffffffffffffffffffffffffffffff
	hex e4ffdcd1d2d6d6cedbd2d7d0ffdfcedcddffe0d1d2ccd1ffe0cadbcddcffd8cfcfffcad7e2ffcad2d5d6ced7ddbfffffffffffffffffffffffffffffffffffff
	hex f7d1d2dcffcdceced9bfcbd5deceffd9d2d7ffd9dbcedfced7dddcffd9d8d2dcd8d7d2d7d0bfffffffffffffffffffffffffffffffffffffffffffffffffffff
	hex e4d7ffced7ccd1cad7ddcecdffcfcecaddd1cedbffcad5d5d8e0dcffcfd8dbffd0dbcacccecfded5ffd5cad7cdd2d7d0dcbfffffffffffffffffffffffffffff
	hex f5ded7ffd5d2d4ceffddd1ceffe0d2d7cdffe0d2ddd1ffddd1d2dcffd9dbcedddde2ffcbd8e0bfffffffffffffffffffffffffffffffffffffffffffffffffff
	hex ecd7ccdbcecadcceffe2d8dedbffd6cad0d2cccad5ffdbcad7d0ceffe0d2ddd1ffddd1d2dcffdccecaffdcd7cad2d5ffcbcacdd0cebfffffffffffffffffffff
	hex ead5d8dfcedcffd8cfffdfd8d5cccad7d2ccffd0d5cadcdcffd6cad4ceffe2d8deffcfceced5ffd9d8e0cedbcfded5bfffffffffffffffffffffffffffffffff
	hex e4ffcfdedcd2d8d7ffd8cfffd6cad0d2ccffcad7cdffddceccd1d7d8d5d8d0e2ffd9dbd8d9ced5dcffe2d8deffddd1dbd8ded0d1ffddd1ceffdcd4e2bfffffff
	hex f7ced5ced9d8dbddffd2d7dcddcad7ddd5e2ffe0d2ddd1ffddd1d2dcffd6d8cdcedbd7ffccd8d7dddbcad9ddd2d8d7bfffffffffffffffffffffffffffffffff
	hex f7d1d2dcffdfced5dfcedde2ffcccad9ceffdcd1d2d6d6cedbdcffded7cdcedbffddd1ceffd5d2d0d1ddffd8cfffddd1ceffd6d8d8d7bfffffffffffffffffff
	hex f5ded6d8dedbdcffdccae2ffddd1caddffe2d8deffcccad7ffdcceceffd5d8dfcecdffd8d7cedcffd2d7ffd2dddcffcfcacccedddcbfffffffffffffffffffff


