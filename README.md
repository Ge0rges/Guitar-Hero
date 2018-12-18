# Guitar-Hero

A primitive implementation of a classic game in verilog. This was presented as a final project for CSC258 at the University of Toronto. Co-authored with Lucas Fenaux. 

The game scrolls from bottom up and includes a random number generator that selects randomly among predefined patterns. The game in it's current state does not speed up/slow down. To play, hook up to a monitor and use the A,S,L and ; keys on your keyboard that respectively correspond to column 1,2,3,4 (Player 1: c1,c2; Player 2: c3,c4).

# Bugs
There is a graphical glitch where the first column of each block is off by -1 on the y-axis. This is most likely due to a mistake in the if conditions (>= instead of > or vice versa) in the vga plotter module. 

We are unsure, but we suspect that our logic for "sticky keys", keeping the state of a key for the duration of a block update, may be flawed leading to timing issues when playing. We didn't have enough time to investigate this adequately. This may have led to a bug in the scoring mechanism too, or they may be independent, or the score may not be buggy. We don't know and have no plans on coming back to this.

# License
We ask that you do not use this in any graded academic work without being clearly cited and adequalty modified (aka don't claim credit for our work please).

Please refer to the license. 
