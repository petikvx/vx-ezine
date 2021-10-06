Conway's Game of Life... written in batch.

This is not meant to be a useful program, rather
it is merely an exercise in batch programming.

Requires stock DOS 6 with an ANSI driver installed.
If you use a different DOS good luck making this run.
It shouldn't be that difficult but you'd probably have
to re-do some of the user interface components.

Originally this consisted of one big batch but I separated
the most-used subroutines into separate batches because it
improves the generation speed by about three times. The
files LIFE.BAT, SUB0.BAT, SUB1.BAT, PLUS.BAT and MINUS.BAT
should all be placed in one directory. Run 'LIFE' to start
the program. You can choose a random start or enter a cell
pattern with the cell editor. Once cells have been made
you also have the option of continuing or clearing the
cells. Press Control-C or Control-Break at any time to
return to the menu.

(the original batch is included as BATLIFE.BAT)
