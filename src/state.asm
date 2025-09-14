
palette:
	hex 0f 0c 21 3c
	hex 0f 0c 21 3c
	hex 0f 0c 21 3c
	hex 0f 0c 21 3c
	hex 0f 0c 21 3c
	hex 0f 0c 21 3c
	hex 0f 0c 21 3c
	hex 0f 0c 21 3c


state_init_main_layout: subroutine

	lda #$3f
	sta PPU_ADDR
	lda #$00
	sta PPU_ADDR
	ldx #$00
.pal_load_loop
	lda palette,x
	sta PPU_DATA
	inx
	cpx #$20
	bne .pal_load_loop

	lda #<main_layout_nam
	sta temp00
	lda #>main_layout_nam
	sta temp01
	lda #$20
	jsr nametable_load

	jsr render_enable

	rts



state_main_layout_update: subroutine
	rts
