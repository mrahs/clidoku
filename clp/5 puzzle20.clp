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
;	* 1 9  2 7 *  6 3 *
;	* 6 2  9 * 3  * 4 7
;	7 3 *  6 * *  * 9 2
;
;	6 5 3  * * *  9 2 *
;	* * *  5 3 2  * * *
;	* 2 7  * 6 9  4 5 3
;
;	3 * *  * * 6  2 8 4
;	2 * *  3 * 8  * * *
;	* * 6  * 2 *  3 1 *

; Solution:
;	8 1 9  2 7 4  6 3 5
;	5 6 2  9 8 3  1 4 7
;	7 3 4  6 5 1  8 9 2
;
;	6 5 3  4 1 7  9 2 8
;	9 4 8  5 3 2  7 6 1
;	1 2 7  8 6 9  4 5 3
;
;	3 7 5  1 9 6  2 8 4
;	2 9 1  3 4 8  5 7 6
;	4 8 6  7 2 5  3 1 9

(defrule build-puzzle
	?f <- (phase build-puzzle)
	=>
	(retract ?f)
	(assert 
		(cell (id 01) (val 0) (box 1) (row 1) (col 1) )
		(cell (id 02) (val 1) (box 1) (row 1) (col 2) )
		(cell (id 03) (val 9) (box 1) (row 1) (col 3) )
		(cell (id 04) (val 2) (box 2) (row 1) (col 4) )
		(cell (id 05) (val 7) (box 2) (row 1) (col 5) )
		(cell (id 06) (val 0) (box 2) (row 1) (col 6) )
		(cell (id 07) (val 6) (box 3) (row 1) (col 7) )
		(cell (id 08) (val 3) (box 3) (row 1) (col 8) )
		(cell (id 09) (val 0) (box 3) (row 1) (col 9) )
		(cell (id 10) (val 0) (box 1) (row 2) (col 1) )
		(cell (id 11) (val 6) (box 1) (row 2) (col 2) )
		(cell (id 12) (val 2) (box 1) (row 2) (col 3) )
		(cell (id 13) (val 9) (box 2) (row 2) (col 4) )
		(cell (id 14) (val 0) (box 2) (row 2) (col 5) )
		(cell (id 15) (val 3) (box 2) (row 2) (col 6) )
		(cell (id 16) (val 0) (box 3) (row 2) (col 7) )
		(cell (id 17) (val 4) (box 3) (row 2) (col 8) )
		(cell (id 18) (val 7) (box 3) (row 2) (col 9) )
		(cell (id 19) (val 7) (box 1) (row 3) (col 1) )
		(cell (id 20) (val 3) (box 1) (row 3) (col 2) )
		(cell (id 21) (val 0) (box 1) (row 3) (col 3) )
		(cell (id 22) (val 6) (box 2) (row 3) (col 4) )
		(cell (id 23) (val 0) (box 2) (row 3) (col 5) )
		(cell (id 24) (val 0) (box 2) (row 3) (col 6) )
		(cell (id 25) (val 0) (box 3) (row 3) (col 7) )
		(cell (id 26) (val 9) (box 3) (row 3) (col 8) )
		(cell (id 27) (val 2) (box 3) (row 3) (col 9) )
		(cell (id 28) (val 6) (box 4) (row 4) (col 1) )
		(cell (id 29) (val 5) (box 4) (row 4) (col 2) )
		(cell (id 30) (val 3) (box 4) (row 4) (col 3) )
		(cell (id 31) (val 0) (box 5) (row 4) (col 4) )
		(cell (id 32) (val 0) (box 5) (row 4) (col 5) )
		(cell (id 33) (val 0) (box 5) (row 4) (col 6) )
		(cell (id 34) (val 9) (box 6) (row 4) (col 7) )
		(cell (id 35) (val 2) (box 6) (row 4) (col 8) )
		(cell (id 36) (val 0) (box 6) (row 4) (col 9) )
		(cell (id 37) (val 0) (box 4) (row 5) (col 1) )
		(cell (id 38) (val 0) (box 4) (row 5) (col 2) )
		(cell (id 39) (val 0) (box 4) (row 5) (col 3) )
		(cell (id 40) (val 5) (box 5) (row 5) (col 4) )
		(cell (id 41) (val 3) (box 5) (row 5) (col 5) )
		(cell (id 42) (val 2) (box 5) (row 5) (col 6) )
		(cell (id 43) (val 0) (box 6) (row 5) (col 7) )
		(cell (id 44) (val 0) (box 6) (row 5) (col 8) )
		(cell (id 45) (val 0) (box 6) (row 5) (col 9) )
		(cell (id 46) (val 0) (box 4) (row 6) (col 1) )
		(cell (id 47) (val 2) (box 4) (row 6) (col 2) )
		(cell (id 48) (val 7) (box 4) (row 6) (col 3) )
		(cell (id 49) (val 0) (box 5) (row 6) (col 4) )
		(cell (id 50) (val 6) (box 5) (row 6) (col 5) )
		(cell (id 51) (val 9) (box 5) (row 6) (col 6) )
		(cell (id 52) (val 4) (box 6) (row 6) (col 7) )
		(cell (id 53) (val 5) (box 6) (row 6) (col 8) )
		(cell (id 54) (val 3) (box 6) (row 6) (col 9) )
		(cell (id 55) (val 3) (box 7) (row 7) (col 1) )
		(cell (id 56) (val 0) (box 7) (row 7) (col 2) )
		(cell (id 57) (val 0) (box 7) (row 7) (col 3) )
		(cell (id 58) (val 0) (box 8) (row 7) (col 4) )
		(cell (id 59) (val 0) (box 8) (row 7) (col 5) )
		(cell (id 60) (val 6) (box 8) (row 7) (col 6) )
		(cell (id 61) (val 2) (box 9) (row 7) (col 7) )
		(cell (id 62) (val 8) (box 9) (row 7) (col 8) )
		(cell (id 63) (val 4) (box 9) (row 7) (col 9) )
		(cell (id 64) (val 2) (box 7) (row 8) (col 1) )
		(cell (id 65) (val 0) (box 7) (row 8) (col 2) )
		(cell (id 66) (val 0) (box 7) (row 8) (col 3) )
		(cell (id 67) (val 3) (box 8) (row 8) (col 4) )
		(cell (id 68) (val 0) (box 8) (row 8) (col 5) )
		(cell (id 69) (val 8) (box 8) (row 8) (col 6) )
		(cell (id 70) (val 0) (box 9) (row 8) (col 7) )
		(cell (id 71) (val 0) (box 9) (row 8) (col 8) )
		(cell (id 72) (val 0) (box 9) (row 8) (col 9) )
		(cell (id 73) (val 0) (box 7) (row 9) (col 1) )
		(cell (id 74) (val 0) (box 7) (row 9) (col 2) )
		(cell (id 75) (val 6) (box 7) (row 9) (col 3) )
		(cell (id 76) (val 0) (box 8) (row 9) (col 4) )
		(cell (id 77) (val 2) (box 8) (row 9) (col 5) )
		(cell (id 78) (val 0) (box 8) (row 9) (col 6) )
		(cell (id 79) (val 3) (box 9) (row 9) (col 7) )
		(cell (id 80) (val 1) (box 9) (row 9) (col 8) )
		(cell (id 81) (val 0) (box 9) (row 9) (col 9) )
	)
)