; Puzzle:
;	4 1 3  * * 6  * * *
;	9 * *  3 * *  4 * *
;	* 2 *  * * 4  * * 1
;
;	* * 9  * * *  * * *
;	* 8 *  4 7 5  * 1 *
;	* * *  * * *  5 * *
;
;	6 * *  7 * *  * 9 *
;	* * 5  * * 1  * * 3
;	* * *  5 * *  2 4 8
;
; Solution:
;	4 1 3  2 5 6  9 8 7
;	9 6 8  3 1 7  4 5 2
;	5 2 7  8 9 4  6 3 1
;
;	1 5 9  6 3 2  8 7 4
;	2 8 6  4 7 5  3 1 9
;	3 7 4  1 8 9  5 2 6
;
;	6 3 2  7 4 8  1 9 5
;	8 4 5  9 2 1  7 6 3
;	7 9 1  5 6 3  2 4 8

(defrule puzzle
	?f <- (phase build-puzzle)
	=>
	(retract ?f)
   (assert (cell (id 01) (val 4) (box 1) (row 1) (col 1) ))
   (assert (cell (id 02) (val 1) (box 1) (row 1) (col 2) ))
   (assert (cell (id 03) (val 3) (box 1) (row 1) (col 3) ))
   (assert (cell (id 04) (val 9) (box 1) (row 2) (col 1) ))
   (assert (cell (id 05) (val 0) (box 1) (row 2) (col 2) ))
   (assert (cell (id 06) (val 0) (box 1) (row 2) (col 3) ))
   (assert (cell (id 07) (val 0) (box 1) (row 3) (col 1) ))
   (assert (cell (id 08) (val 2) (box 1) (row 3) (col 2) ))
   (assert (cell (id 09) (val 0) (box 1) (row 3) (col 3) ))
   (assert (cell (id 10) (val 0) (box 2) (row 1) (col 4) ))
   (assert (cell (id 11) (val 0) (box 2) (row 1) (col 5) ))
   (assert (cell (id 12) (val 6) (box 2) (row 1) (col 6) ))
   (assert (cell (id 13) (val 3) (box 2) (row 2) (col 4) ))
   (assert (cell (id 14) (val 0) (box 2) (row 2) (col 5) ))
   (assert (cell (id 15) (val 0) (box 2) (row 2) (col 6) ))
   (assert (cell (id 16) (val 0) (box 2) (row 3) (col 4) ))
   (assert (cell (id 17) (val 0) (box 2) (row 3) (col 5) ))
   (assert (cell (id 18) (val 4) (box 2) (row 3) (col 6) ))
   (assert (cell (id 19) (val 0) (box 3) (row 1) (col 7) ))
   (assert (cell (id 20) (val 0) (box 3) (row 1) (col 8) ))
   (assert (cell (id 21) (val 0) (box 3) (row 1) (col 9) ))
   (assert (cell (id 22) (val 4) (box 3) (row 2) (col 7) ))
   (assert (cell (id 23) (val 0) (box 3) (row 2) (col 8) ))
   (assert (cell (id 24) (val 0) (box 3) (row 2) (col 9) ))
   (assert (cell (id 25) (val 0) (box 3) (row 3) (col 7) ))
   (assert (cell (id 26) (val 0) (box 3) (row 3) (col 8) ))
   (assert (cell (id 27) (val 1) (box 3) (row 3) (col 9) ))
   (assert (cell (id 28) (val 0) (box 4) (row 4) (col 1) ))
   (assert (cell (id 29) (val 0) (box 4) (row 4) (col 2) ))
   (assert (cell (id 30) (val 9) (box 4) (row 4) (col 3) ))
   (assert (cell (id 31) (val 0) (box 4) (row 5) (col 1) ))
   (assert (cell (id 32) (val 8) (box 4) (row 5) (col 2) ))
   (assert (cell (id 33) (val 0) (box 4) (row 5) (col 3) ))
   (assert (cell (id 34) (val 0) (box 4) (row 6) (col 1) ))
   (assert (cell (id 35) (val 0) (box 4) (row 6) (col 2) ))
   (assert (cell (id 36) (val 0) (box 4) (row 6) (col 3) ))
   (assert (cell (id 37) (val 0) (box 5) (row 4) (col 4) ))
   (assert (cell (id 38) (val 0) (box 5) (row 4) (col 5) ))
   (assert (cell (id 39) (val 0) (box 5) (row 4) (col 6) ))
   (assert (cell (id 40) (val 4) (box 5) (row 5) (col 4) ))
   (assert (cell (id 41) (val 7) (box 5) (row 5) (col 5) ))
   (assert (cell (id 42) (val 5) (box 5) (row 5) (col 6) ))
   (assert (cell (id 43) (val 0) (box 5) (row 6) (col 4) ))
   (assert (cell (id 44) (val 0) (box 5) (row 6) (col 5) ))
   (assert (cell (id 45) (val 0) (box 5) (row 6) (col 6) ))
   (assert (cell (id 46) (val 0) (box 6) (row 4) (col 7) ))
   (assert (cell (id 47) (val 0) (box 6) (row 4) (col 8) ))
   (assert (cell (id 48) (val 0) (box 6) (row 4) (col 9) ))
   (assert (cell (id 49) (val 0) (box 6) (row 5) (col 7) ))
   (assert (cell (id 50) (val 1) (box 6) (row 5) (col 8) ))
   (assert (cell (id 51) (val 0) (box 6) (row 5) (col 9) ))
   (assert (cell (id 52) (val 5) (box 6) (row 6) (col 7) ))
   (assert (cell (id 53) (val 0) (box 6) (row 6) (col 8) ))
   (assert (cell (id 54) (val 0) (box 6) (row 6) (col 9) ))
   (assert (cell (id 55) (val 6) (box 7) (row 7) (col 1) ))
   (assert (cell (id 56) (val 0) (box 7) (row 7) (col 2) ))
   (assert (cell (id 57) (val 0) (box 7) (row 7) (col 3) ))
   (assert (cell (id 58) (val 0) (box 7) (row 8) (col 1) ))
   (assert (cell (id 59) (val 0) (box 7) (row 8) (col 2) ))
   (assert (cell (id 60) (val 5) (box 7) (row 8) (col 3) ))
   (assert (cell (id 61) (val 0) (box 7) (row 9) (col 1) ))
   (assert (cell (id 62) (val 0) (box 7) (row 9) (col 2) ))
   (assert (cell (id 63) (val 0) (box 7) (row 9) (col 3) ))
   (assert (cell (id 64) (val 7) (box 8) (row 7) (col 4) ))
   (assert (cell (id 65) (val 0) (box 8) (row 7) (col 5) ))
   (assert (cell (id 66) (val 0) (box 8) (row 7) (col 6) ))
   (assert (cell (id 67) (val 0) (box 8) (row 8) (col 4) ))
   (assert (cell (id 68) (val 0) (box 8) (row 8) (col 5) ))
   (assert (cell (id 69) (val 1) (box 8) (row 8) (col 6) ))
   (assert (cell (id 70) (val 5) (box 8) (row 9) (col 4) ))
   (assert (cell (id 71) (val 0) (box 8) (row 9) (col 5) ))
   (assert (cell (id 72) (val 0) (box 8) (row 9) (col 6) ))
   (assert (cell (id 73) (val 0) (box 9) (row 7) (col 7) ))
   (assert (cell (id 74) (val 9) (box 9) (row 7) (col 8) ))
   (assert (cell (id 75) (val 0) (box 9) (row 7) (col 9) ))
   (assert (cell (id 76) (val 0) (box 9) (row 8) (col 7) ))
   (assert (cell (id 77) (val 0) (box 9) (row 8) (col 8) ))
   (assert (cell (id 78) (val 3) (box 9) (row 8) (col 9) ))
   (assert (cell (id 79) (val 2) (box 9) (row 9) (col 7) ))
   (assert (cell (id 80) (val 4) (box 9) (row 9) (col 8) ))
   (assert (cell (id 81) (val 8) (box 9) (row 9) (col 9) ))
)