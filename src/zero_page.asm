;;;;; VARIABLES

	seg.u ZEROPAGE
	org $0
        
wtf                    byte
nmi_lockout            byte ; *
temp00                 byte
temp01                 byte
temp02                 byte
temp03                 byte
temp04                 byte
temp05                 byte
temp06                 byte
temp07                 byte
state00                byte
state01                byte
state02                byte
state03                byte
state04                byte
state05                byte
state06                byte
state07                byte
rng0                   byte
oam_disable            byte ; *
controls               byte
controls_d             byte
ppu_mask_emph          byte ; *

state_jmp_lo   byte
state_jmp_hi   byte

timer_lo byte
timer_hi byte


scroll_x       byte
scroll_y       byte
scroll_ms 	   byte ; map screen



collision_0_x	byte
collision_0_y	byte
collision_0_w	byte
collision_0_h	byte
collision_1_x	byte
collision_1_y	byte
collision_1_w	byte
collision_1_h	byte
collis_char_x  byte
collis_char_y  byte

arctang_velocity_lo  byte ; *
arctang_velocity_hi  byte ; *

rng_seed0  byte
rng_seed1  byte
rng_val0   byte
rng_val1   byte


