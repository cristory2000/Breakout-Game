# Breakout-Game
For project 1, you’ll be writing a video game in MIPS assembly: Breakout! If you’re not familiar with the game, find an online version of it and play around. It’s pretty simple - it was originally made without a CPU after all! Will be using Mars.


# Brief game description 
In Breakout, you control the paddle at the bottom of the screen. You can move the paddle left and right.

The blocks are the colored rectangles at the top of the screen. Your goal is to break all the blocks. When all the blocks are broken, the game ends.

The way you do that is by bouncing a ball with your paddle. The ball breaks a block if it touches them, and then bounces off the block. The ball also bounces off the walls and ceiling.

If the ball goes off the bottom of the screen, that is a miss, andthe paddle and ball are reset (but the blocks remain).

When the game first starts, or whenever you miss the ball, the paddle should appear at a random horizontal position with the ball sitting on top of it. The ball will not move until the player hits any key. Then it will move up-right.
