Clidoku
=======

An advanced and well documented Sudoku solver written in CLIPS with a JavaFX GUI and an integrated debugger.

This is a rapidly developed prototype. It's far from being complete.

## Features
* A CLIPSJNI example. Check out the source code to find out how to use it. The source code is well commented, but not well structured.
* A CLIPS example. Check out the rules files to learn how CLIPS was utilized to solve Sudoku.
* A nice game. The GUI has many features to ease the game, like saving a check point and hiding a candidate. It comes with 20 puzzles.
* This is a rapidly developed prototype. It's far from being complete.

## How
1. load init.clp
2. load a puzzle
3. load print.clp (to see output!)
4. load solve.clp
5. running:
	1. to build the loaded puzzle: `(assert (phase build-puzzle)) (run)`
	2. to print the puzzle before solving it: `(assert (phase print-puzzle)) (run)`
	3. to solve the puzzle: `(assert (phase solve)) (run)`
	4. to print the solved puzzle: `(assert (phase print-puzzle)) (run)`
	5. to print the techniques used to solve the puzzle: `(assert (phase print-techniques)) (run)`
6. to check a puzzle: load check.clp then `(assert (phase check)) (run) (assert (phase print-status)) (run)`

## GUI
* You should tell java where CLIPJNI library is by using the argument: `-Djava.library.path=./lib/`
* Note that you might need to change the './lib/' part.
* It might be a good idea (a necessary one if the app crashes due to insufficient memory) to give the app extra memory using the argument: `-Xms64m`

## License
GPLv3 or later.