# YOUR FULL NAME HERE
#Cristopher Story
# YOUR USERNAME HERE
#crs165
.include "display_2211_0822.asm"

# change these to whatever you like.
.eqv BALL_COLOR COLOR_WHITE
.eqv PADDLE_COLOR COLOR_ORANGE

.eqv BLOCK_WIDTH  8 # pixels wide
.eqv BLOCK_HEIGHT 4 # pixels tall

.eqv BOARD_BLOCK_WIDTH    8 # 8 blocks wide
.eqv BOARD_BLOCK_HEIGHT   6 # 6 blocks tall
.eqv BOARD_MAX_BLOCKS    48 # = BOARD_BLOCK_WIDTH * BOARD_BLOCK_HEIGHT
.eqv BOARD_BLOCK_BOTTOM  24 # = BLOCK_HEIGHT * BOARD_BLOCK_HEIGHT
                            # (the Y coordinate of the bottom of the blocks)

.eqv PADDLE_WIDTH  12 # pixels wide
.eqv PADDLE_HEIGHT  2 # pixels tall
.eqv PADDLE_Y      54 # fixed Y coordinate
.eqv PADDLE_MIN_X   0 # furthest left the left side can go
.eqv PADDLE_MAX_X  52 # furthest right the *left* side can go (= 64 - PADDLE_WIDTH)

.data
	off_screen:    .word 0 # bool, set to 1 when ball goes off-screen.
	paddle_x:      .word 0 # paddle's X coordinate
	paddle_vx:     .word 0 # paddle's X velocity (optional)

	ball_x:        .word 0 # ball's coordinates
	ball_y:        .word 0
	ball_vx:       .word 0 # ball's velocity
	ball_vy:       .word 0
	ball_old_x:    .word 0 # used during collision to back the ball up when it collides
	ball_old_y:    .word 0

	# the blocks to be broken! these are just colors from constants.asm. 0 is empty.
	blocks:
	.byte 0 0 0 0 0 0 0 0
	.byte 0 0 0 0 0 0 0 0
	.byte 0 0 1 2 3 4 0 0
	.byte 0 0 5 6 8 9 0 0
	.byte 0 0 0 0 0 0 0 0
	.byte 0 0 0 0 0 0 0 0
.text

# -------------------------------------------------------------------------------------------------

.globl main
main:
	_loop:
		# TODO:
		 jal setup_paddle
		 jal setup_ball
		 jal wait_for_start
		 jal play_game
	jal count_blocks_left
	bnez v0, _loop
	
	
	# shorthand for li v0, 10; syscall
	syscall_exit

# -------------------------------------------------------------------------------------------------

# returns number of blocks in blocks array that are not 0.
count_blocks_left:
enter
	li v0,0
	#li t0,0
	li t1,0
	_count_loop:
		bge t1,BOARD_MAX_BLOCKS,_break_count_loop
			lb t0,blocks(t1)#goes through memory
				beq t0,0,_out_count_if
					inc v0
		_out_count_if:
			inc t1
	j _count_loop
	
	_break_count_loop:
	
	
	
	
leave
# --------------------------------------------------------------------------------------------------
# setup paddle
setup_paddle:
enter
	li t0, PADDLE_MAX_X
	li a0,0#bottoms range
	subu a1, t0,PADDLE_MIN_X#top range
	syscall_rand_range#retruns random number
	addu t0, v0,PADDLE_MIN_X#
	sw t0,paddle_x
leave
#----------------------------------------------------------------------------------------------------
#start game
play_game:
enter

_game_loop:
	
	jal draw_paddle
	jal draw_ball
		
	jal check_input
	jal check_ball_input
		
	jal add_velocity
	jal check_collision
	jal draw_blocks
		
	jal show_blocks_left
		
	jal display_update_and_clear
	jal wait_for_next_frame
	
	
	
	lw t0,off_screen
	beq t0,1,_exit_loop
	
	jal count_blocks_left
	bne v0,0,_game_loop
	
	
	
_exit_loop:
leave
#----------------------------------------------------------------------------------------------------
#draws paddle
draw_paddle:
enter 
	lw a0,paddle_x
	li a1, PADDLE_Y
	li a2, PADDLE_WIDTH
	li a3, PADDLE_HEIGHT
	li v1, PADDLE_COLOR
	jal display_fill_rect
leave
#-----------------------------------------------------------------------------------------------------
check_input:
enter 
	jal input_get_keys_held
	and t0,v0, KEY_L
	beq t0,0,_check_right
		lw t0,paddle_x
		dec t0
		sw t0,paddle_x
_check_right:
	and t0,v0,KEY_R
	beq t0,0,_end
		lw t0,paddle_x
		inc t0
		sw t0,paddle_x
	
_end:
	li t0,PADDLE_MAX_X#keeps it in range
	lw t1,paddle_x
	min t3,t0,t1
	sw t3,paddle_x
	
	li t0,PADDLE_MIN_X#keeps it in range
	lw t1,paddle_x
	max t3,t0,t1
	sw t3,paddle_x
leave 
#----------------------------------------------------------------------------------------------------
draw_blocks:
enter s0,s1
	li s0,0 #counter 1
	li s1,0 #counter 2
_loop:
	bge s0 ,BOARD_BLOCK_WIDTH, _break_out
		_inner_loop:
			bge s1,BOARD_BLOCK_HEIGHT,_break_inner
				la t0,blocks
				mul t1,s0,BOARD_BLOCK_WIDTH
				mul t2,s1,1
				add,t0,t0,t1
				add, t0,t0,t2
				lb t0,(t0)
				beq t0,0,_empty_space
					mul a0,s1,BLOCK_WIDTH #flip s registers because memory addressing from left to right while loop is up and down
					mul a1,s0,BLOCK_HEIGHT
					li a2,BLOCK_WIDTH
					li a3, BLOCK_HEIGHT
					move v1,t0
					jal display_fill_rect
		_empty_space:
			inc s1
		j _inner_loop
_break_inner:
	inc s0
	li s1,0
	j _loop
_break_out:
	




leave s0,s1
#---------------------------------------------------------------------------------------------------------------------------
show_blocks_left:
enter
	jal count_blocks_left
	li a0,3
	li a1,57
	move a2,v0
	jal display_draw_int
	
leave
#----------------------------------------------------------------------------------------------------------------------------
draw_ball:
enter
	lw a0,ball_x
	lw a1,ball_y
	li a2,BALL_COLOR
	jal display_set_pixel
leave
#----------------------------------------------------------------------------------------------------------------------------
setup_ball:
enter 
	lw t0,paddle_x#puts ball on paddle
	li t1,PADDLE_Y
	add t0,t0,5
	sub t1,t1,1
	sw t0,ball_x
	sw t1,ball_y
	
	li t0,0
	sw t0,off_screen
	sw t0,ball_vx
	sw t0,ball_vy
leave 
#----------------------------------------------------------------------
check_ball_input:
enter 
	jal input_get_keys_pressed
	and t0,v0, KEY_L
	beq t0,0,_r_pressed#check input for all letters and arrows
_l_pressed:
	#set up and to the right
	lw t0,ball_vx
	bne t0,0,_end_check_pressed
		li t0,1
		sw t0,ball_vx
		lw t0,ball_vy
		li t0,-1
		sw t0,ball_vy
	j _end_check_pressed

_r_pressed:
and t0,v0,KEY_R
beq t0,0,_u_pressed
	lw t0,ball_vx
	bne t0,0,_end_check_pressed
		li t0,1
		sw t0,ball_vx
		lw t0,ball_vy
		li t0,-1
		sw t0,ball_vy
		j _end_check_pressed

_u_pressed:
and t0,v0,KEY_U
beq t0,0,_d_pressed
	lw t0,ball_vx
	bne t0,0,_end_check_pressed
		li t0,1
		sw t0,ball_vx
		lw t0,ball_vy
		li t0,-1
		sw t0,ball_vy
		j _end_check_pressed
_d_pressed:
and t0,v0,KEY_D
beq t0,0,_z_pressed
	lw t0,ball_vx
	bne t0,0,_end_check_pressed
		li t0,1
		sw t0,ball_vx
		lw t0,ball_vy
		li t0,-1
		sw t0,ball_vy
		j _end_check_pressed
_z_pressed:
and t0,v0,KEY_Z
beq t0,0,_x_pressed
	lw t0,ball_vx
	bne t0,0,_end_check_pressed
		li t0,1
		sw t0,ball_vx
		lw t0,ball_vy
		li t0,-1
		sw t0,ball_vy
		j _end_check_pressed
_x_pressed:
and t0,v0,KEY_X
beq t0,0,_c_pressed
	lw t0,ball_vx
	bne t0,0,_end_check_pressed
		li t0,1
		sw t0,ball_vx
		lw t0,ball_vy
		li t0,-1
		sw t0,ball_vy
		j _end_check_pressed
_c_pressed:
and t0,v0,KEY_C
beq t0,0,_b_pressed
	lw t0,ball_vx
	bne t0,0,_end_check_pressed
		li t0,1
		sw t0,ball_vx
		lw t0,ball_vy
		li t0,-1
		sw t0,ball_vy
		j _end_check_pressed
_b_pressed:
and t0,v0,KEY_B
beq t0,0,_end_check_pressed
	lw t0,ball_vx
	bne t0,0,_end_check_pressed
		li t0,1
		sw t0,ball_vx
		lw t0,ball_vy
		li t0,-1
		sw t0,ball_vy
		j _end_check_pressed
_end_check_pressed:
leave 
#------------------------------
add_velocity:
enter 
	lw t0,ball_x
	lw t1,ball_y
	
	sw t0,ball_old_x
	sw t1,ball_old_y
	#add to the velocity in x
	
	lw t0,ball_x
	lw t1, ball_vx
	
	add t0,t0,t1
	sw t0,ball_x
leave
#----------------------------------
check_collision:
enter
	jal breaking_blocks
	beq v0,1,_on_side
	#check if ball ran into sides
		lw t0,ball_x
		beq t0,0,_on_side
		bne t0,64,_not_on_side
_on_side:
	lw t0,ball_x
	lw t1,ball_old_x
	move t0,t1
	sw t0,ball_x
	lw t0,ball_vx
	not t0,t0
	add t0,t0,1
	sw t0,ball_vx
		
	
	#add to the  velovity in y
_not_on_side:
	lw t0,ball_y
	lw t1, ball_vy
		
	add t0,t0,t1
	sw t0,ball_y
	jal breaking_blocks
	beq v0,1,_on_ceiling
		#check if it hits ceiling
		lw t0,ball_y
		bne t0,0,_not_on_ceiling
_on_ceiling:
	lw t0,ball_y
	lw t1,ball_old_y
	move t0,t1
	sw t0,ball_y
	lw t0,ball_vy
	not t0,t0
	add t0,t0,1
	sw t0,ball_vy
	beq v0,0,_doesnt_hit_paddle
_not_on_ceiling:
	#check if it hits paddle
	lw t0,ball_x
	lw t1,ball_y
	lw t2,paddle_x
	bne t1,PADDLE_Y,_doesnt_hit_paddle
	blt t0,t2,_doesnt_hit_paddle
		add t2,t2,PADDLE_WIDTH
	bge t0,t2,_doesnt_hit_paddle
_hits_paddle:
	lw t0,ball_y
	lw t1,ball_old_y
	move t0,t1
	sw t0,ball_y
	lw t0,ball_vy
	not t0,t0
	add t0,t0,1
	sw t0,ball_vy
_doesnt_hit_paddle:
	#check if hits bottom of screen
	lw t0,ball_y
	bne t0,64,_not_on_bottom
		li t0,1
		sw t0,off_screen
_not_on_bottom:
leave 
#---------------------------------------
breaking_blocks:
enter
	li v0,0
	lw t1,ball_x#row
	lw t2,ball_y#col
	bgt t2,BOARD_BLOCK_BOTTOM,_not_in_range	
		div t1,t1,BLOCK_WIDTH
		div t2,t2,BLOCK_HEIGHT
		la t0,blocks
		mul t2,t2,BOARD_BLOCK_WIDTH
		mul t1,t1,1
		add,t0,t0,t1
		add, t0,t0,t2
		lb t1,(t0)
	beq t1,0,_not_in_range
		li t2,0
		sb t2,(t0)
		li v0,1
_not_in_range:
leave
#------------------------------------------------------
wait_for_start:
enter
	#jal wait_for_next_frame
	jal check_ball_input
	lw t0,ball_vx
_wait_loop:
	bne t0,0,_end_wait
		jal draw_paddle
		jal draw_blocks
		jal draw_ball
		jal display_update_and_clear
		jal show_blocks_left
		jal wait_for_next_frame
		j _wait_loop
_end_wait:
leave
