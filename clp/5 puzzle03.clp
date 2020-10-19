;
;	 Copyright 2013 Anas H. Sulaiman (ahs.pw)
;	
;	 This file is part of Clidoku.
;
;    Clidoku is free software: you can redistribute it and/or modify
;    it under the terms of the GNU General Public License as published by
;    the Free Software Foundation, either version 3 of the License, or
;    (at your option) any later version.
;
;    Clidoku is distributed in the hope that it will be useful,
;    but WITHOUT ANY WARRANTY; without even the implied warranty of
;    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;    GNU General Public License for more details.
;
;   You should have received a copy of the GNU General Public License
;   along with Clidoku.  If not, see <http://www.gnu.org/licenses/>.

; Puzzle:
;	8 * *  6 2 *  9 4 5
;	* 4 5  * 1 8  * 6 *
;	6 * *  * * *  * 1 8
;
;	* 9 8  * * 6  * * *
;	* * *  7 9 5  * 8 *
;	5 6 7  2 8 1  4 3 9
;
;	* 3 *  8 * 2  * * *
;	* 5 *  1 * *  8 2 *
;	2 8 6  * 7 4  * * *

; Solution:
;	8 1 3  6 2 7  9 4 5
;	9 4 5  3 1 8  2 6 7
;	6 7 2  5 4 9  3 1 8
;
;	1 9 8  4 3 6  5 7 2
;	3 2 4  7 9 5  6 8 1
;	5 6 7  2 8 1  4 3 9
;
;	4 3 1  8 5 2  7 9 6
;	7 5 9  1 6 3  8 2 4
;	2 8 6  9 7 4  1 5 3

; Using
;	Locked Candidate Pointing
;	Naked Single
;	Full House

(defrule build-puzzle
	?f <- (phase build-puzzle)
	=>
	(retract ?f)
	(assert 
		(cell (val 8) (row 1) (col 1) (id 01) (box 1) )
		(cell (val 0) (row 1) (col 2) (id 02) (box 1) )
		(cell (val 0) (row 1) (col 3) (id 03) (box 1) )
		(cell (val 6) (row 1) (col 4) (id 04) (box 2) )
		(cell (val 2) (row 1) (col 5) (id 05) (box 2) )
		(cell (val 0) (row 1) (col 6) (id 06) (box 2) )
		(cell (val 9) (row 1) (col 7) (id 07) (box 3) )
		(cell (val 4) (row 1) (col 8) (id 08) (box 3) )
		(cell (val 5) (row 1) (col 9) (id 09) (box 3) )
		(cell (val 0) (row 2) (col 1) (id 10) (box 1) )
		(cell (val 4) (row 2) (col 2) (id 11) (box 1) )
		(cell (val 5) (row 2) (col 3) (id 12) (box 1) )
		(cell (val 0) (row 2) (col 4) (id 13) (box 2) )
		(cell (val 1) (row 2) (col 5) (id 14) (box 2) )
		(cell (val 8) (row 2) (col 6) (id 15) (box 2) )
		(cell (val 0) (row 2) (col 7) (id 16) (box 3) )
		(cell (val 6) (row 2) (col 8) (id 17) (box 3) )
		(cell (val 0) (row 2) (col 9) (id 18) (box 3) )
		(cell (val 6) (row 3) (col 1) (id 19) (box 1) )
		(cell (val 0) (row 3) (col 2) (id 20) (box 1) )
		(cell (val 0) (row 3) (col 3) (id 21) (box 1) )
		(cell (val 0) (row 3) (col 4) (id 22) (box 2) )
		(cell (val 0) (row 3) (col 5) (id 23) (box 2) )
		(cell (val 0) (row 3) (col 6) (id 24) (box 2) )
		(cell (val 0) (row 3) (col 7) (id 25) (box 3) )
		(cell (val 1) (row 3) (col 8) (id 26) (box 3) )
		(cell (val 8) (row 3) (col 9) (id 27) (box 3) )
		(cell (val 0) (row 4) (col 1) (id 28) (box 4) )
		(cell (val 9) (row 4) (col 2) (id 29) (box 4) )
		(cell (val 8) (row 4) (col 3) (id 30) (box 4) )
		(cell (val 0) (row 4) (col 4) (id 31) (box 5) )
		(cell (val 0) (row 4) (col 5) (id 32) (box 5) )
		(cell (val 6) (row 4) (col 6) (id 33) (box 5) )
		(cell (val 0) (row 4) (col 7) (id 34) (box 6) )
		(cell (val 0) (row 4) (col 8) (id 35) (box 6) )
		(cell (val 0) (row 4) (col 9) (id 36) (box 6) )
		(cell (val 0) (row 5) (col 1) (id 37) (box 4) )
		(cell (val 0) (row 5) (col 2) (id 38) (box 4) )
		(cell (val 0) (row 5) (col 3) (id 39) (box 4) )
		(cell (val 7) (row 5) (col 4) (id 40) (box 5) )
		(cell (val 9) (row 5) (col 5) (id 41) (box 5) )
		(cell (val 5) (row 5) (col 6) (id 42) (box 5) )
		(cell (val 0) (row 5) (col 7) (id 43) (box 6) )
		(cell (val 8) (row 5) (col 8) (id 44) (box 6) )
		(cell (val 0) (row 5) (col 9) (id 45) (box 6) )
		(cell (val 5) (row 6) (col 1) (id 46) (box 4) )
		(cell (val 6) (row 6) (col 2) (id 47) (box 4) )
		(cell (val 7) (row 6) (col 3) (id 48) (box 4) )
		(cell (val 2) (row 6) (col 4) (id 49) (box 5) )
		(cell (val 8) (row 6) (col 5) (id 50) (box 5) )
		(cell (val 1) (row 6) (col 6) (id 51) (box 5) )
		(cell (val 4) (row 6) (col 7) (id 52) (box 6) )
		(cell (val 3) (row 6) (col 8) (id 53) (box 6) )
		(cell (val 9) (row 6) (col 9) (id 54) (box 6) )
		(cell (val 0) (row 7) (col 1) (id 55) (box 7) )
		(cell (val 3) (row 7) (col 2) (id 56) (box 7) )
		(cell (val 0) (row 7) (col 3) (id 57) (box 7) )
		(cell (val 8) (row 7) (col 4) (id 58) (box 8) )
		(cell (val 0) (row 7) (col 5) (id 59) (box 8) )
		(cell (val 2) (row 7) (col 6) (id 60) (box 8) )
		(cell (val 0) (row 7) (col 7) (id 61) (box 9) )
		(cell (val 0) (row 7) (col 8) (id 62) (box 9) )
		(cell (val 0) (row 7) (col 9) (id 63) (box 9) )
		(cell (val 0) (row 8) (col 1) (id 64) (box 7) )
		(cell (val 5) (row 8) (col 2) (id 65) (box 7) )
		(cell (val 0) (row 8) (col 3) (id 66) (box 7) )
		(cell (val 1) (row 8) (col 4) (id 67) (box 8) )
		(cell (val 0) (row 8) (col 5) (id 68) (box 8) )
		(cell (val 0) (row 8) (col 6) (id 69) (box 8) )
		(cell (val 8) (row 8) (col 7) (id 70) (box 9) )
		(cell (val 2) (row 8) (col 8) (id 71) (box 9) )
		(cell (val 0) (row 8) (col 9) (id 72) (box 9) )
		(cell (val 2) (row 9) (col 1) (id 73) (box 7) )
		(cell (val 8) (row 9) (col 2) (id 74) (box 7) )
		(cell (val 6) (row 9) (col 3) (id 75) (box 7) )
		(cell (val 0) (row 9) (col 4) (id 76) (box 8) )
		(cell (val 7) (row 9) (col 5) (id 77) (box 8) )
		(cell (val 4) (row 9) (col 6) (id 78) (box 8) )
		(cell (val 0) (row 9) (col 7) (id 79) (box 9) )
		(cell (val 0) (row 9) (col 8) (id 80) (box 9) )
		(cell (val 0) (row 9) (col 9) (id 81) (box 9) )
	)
)