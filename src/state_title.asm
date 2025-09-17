
state_title_palette:
	hex 0f 01 22 35
	hex 0f 01 22 35
	hex 0f 01 22 35
	hex 0f 01 22 35
	hex 0f 01 22 35
	hex 0f 01 22 35
	hex 0f 01 22 35
	hex 0f 01 22 35


str_title:
	byte "STARDUST"


state_title_init: subroutine
	STATE_SET state_title_update

	jsr render_disable

	lda #$3f
	sta PPU_ADDR
	lda #$00
	sta PPU_ADDR
	ldx #$00
.pal_load_loop
	lda state_title_palette,x
	sta PPU_DATA
	inx
	cpx #$20
	bne .pal_load_loop

	lda #$20
	sta temp00
	lda #$00
	sta temp01
	lda #$00
	jsr nametable_fill

	lda #$21
	sta PPU_ADDR
	lda #$8c
	sta PPU_ADDR
	ldx #$00
.title_loop
	lda str_title,x
	sta PPU_DATA
	inx
	cpx #$08
	bne .title_loop

	jsr render_enable

	rts

state_title_update: subroutine
	lda controls_d
	beq .do_nothing
	jsr state_explore_init
.do_nothing
	rts
