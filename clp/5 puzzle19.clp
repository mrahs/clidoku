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
;	9 * *  * 1 7  2 * 3
;	8 3 *  * 9 5  1 * *
;	7 * 1  * 3 4  5 * *
;
;	* 1 7  3 * *  8 * *
;	6 4 9  5 7 8  3 2 1
;	* 8 3  1 * 9  6 * *
;
;	4 * 6  7 * 3  9 1 *
;	3 7 8  9 5 1  4 6 2
;	1 9 *  4 * *  7 3 *

; Solution:
;	9 6 5  8 1 7  2 4 3
;	8 3 4  2 9 5  1 7 6
;	7 2 1  6 3 4  5 8 9
;
;	5 1 7  3 6 2  8 9 4
;	6 4 9  5 7 8  3 2 1
;	2 8 3  1 4 9  6 5 7
;
;	4 5 6  7 2 3  9 1 8
;	3 7 8  9 5 1  4 6 2
;	1 9 2  4 8 6  7 3 5

; Using:
;	Unique Rectangle 6
;	Unique Rectangle 4
;	XY-Wing
; 	Hidden Triple
;	Locked Candidate Claiming
;	Locked Candidate Pointing
;	Hidden Single

(defrule build-puzzle
	?f <- (phase build-puzzle)
	=>
	(retract ?f)
	(assert 
		(cell (id 01) (val 9) (box 1) (row 1) (col 1) )
		(cell (id 01) (val 0) (box 1) (row 1) (col 2) )
		(cell (id 01) (val 0) (box 1) (row 1) (col 3) )
		(cell (id 01) (val 0) (box 2) (row 1) (col 4) )
		(cell (id 01) (val 1) (box 2) (row 1) (col 5) )
		(cell (id 01) (val 7) (box 2) (row 1) (col 6) )
		(cell (id 01) (val 2) (box 3) (row 1) (col 7) )
		(cell (id 01) (val 0) (box 3) (row 1) (col 8) )
		(cell (id 01) (val 3) (box 3) (row 1) (col 9) )
		(cell (id 02) (val 8) (box 1) (row 2) (col 1) )
		(cell (id 02) (val 3) (box 1) (row 2) (col 2) )
		(cell (id 02) (val 0) (box 1) (row 2) (col 3) )
		(cell (id 02) (val 0) (box 2) (row 2) (col 4) )
		(cell (id 02) (val 9) (box 2) (row 2) (col 5) )
		(cell (id 02) (val 5) (box 2) (row 2) (col 6) )
		(cell (id 02) (val 1) (box 3) (row 2) (col 7) )
		(cell (id 02) (val 0) (box 3) (row 2) (col 8) )
		(cell (id 02) (val 0) (box 3) (row 2) (col 9) )
		(cell (id 03) (val 7) (box 1) (row 3) (col 1) )
		(cell (id 03) (val 0) (box 1) (row 3) (col 2) )
		(cell (id 03) (val 1) (box 1) (row 3) (col 3) )
		(cell (id 03) (val 0) (box 2) (row 3) (col 4) )
		(cell (id 03) (val 3) (box 2) (row 3) (col 5) )
		(cell (id 03) (val 4) (box 2) (row 3) (col 6) )
		(cell (id 03) (val 5) (box 3) (row 3) (col 7) )
		(cell (id 03) (val 0) (box 3) (row 3) (col 8) )
		(cell (id 03) (val 0) (box 3) (row 3) (col 9) )
		(cell (id 04) (val 0) (box 4) (row 4) (col 1) )
		(cell (id 04) (val 1) (box 4) (row 4) (col 2) )
		(cell (id 04) (val 7) (box 4) (row 4) (col 3) )
		(cell (id 04) (val 3) (box 5) (row 4) (col 4) )
		(cell (id 04) (val 0) (box 5) (row 4) (col 5) )
		(cell (id 04) (val 0) (box 5) (row 4) (col 6) )
		(cell (id 04) (val 8) (box 6) (row 4) (col 7) )
		(cell (id 04) (val 0) (box 6) (row 4) (col 8) )
		(cell (id 04) (val 0) (box 6) (row 4) (col 9) )
		(cell (id 05) (val 6) (box 4) (row 5) (col 1) )
		(cell (id 05) (val 4) (box 4) (row 5) (col 2) )
		(cell (id 05) (val 9) (box 4) (row 5) (col 3) )
		(cell (id 05) (val 5) (box 5) (row 5) (col 4) )
		(cell (id 05) (val 7) (box 5) (row 5) (col 5) )
		(cell (id 05) (val 8) (box 5) (row 5) (col 6) )
		(cell (id 05) (val 3) (box 6) (row 5) (col 7) )
		(cell (id 05) (val 2) (box 6) (row 5) (col 8) )
		(cell (id 05) (val 1) (box 6) (row 5) (col 9) )
		(cell (id 06) (val 0) (box 4) (row 6) (col 1) )
		(cell (id 06) (val 8) (box 4) (row 6) (col 2) )
		(cell (id 06) (val 3) (box 4) (row 6) (col 3) )
		(cell (id 06) (val 1) (box 5) (row 6) (col 4) )
		(cell (id 06) (val 0) (box 5) (row 6) (col 5) )
		(cell (id 06) (val 9) (box 5) (row 6) (col 6) )
		(cell (id 06) (val 6) (box 6) (row 6) (col 7) )
		(cell (id 06) (val 0) (box 6) (row 6) (col 8) )
		(cell (id 06) (val 0) (box 6) (row 6) (col 9) )
		(cell (id 07) (val 4) (box 7) (row 7) (col 1) )
		(cell (id 07) (val 0) (box 7) (row 7) (col 2) )
		(cell (id 07) (val 6) (box 7) (row 7) (col 3) )
		(cell (id 07) (val 7) (box 8) (row 7) (col 4) )
		(cell (id 07) (val 0) (box 8) (row 7) (col 5) )
		(cell (id 07) (val 3) (box 8) (row 7) (col 6) )
		(cell (id 07) (val 9) (box 9) (row 7) (col 7) )
		(cell (id 07) (val 1) (box 9) (row 7) (col 8) )
		(cell (id 07) (val 0) (box 9) (row 7) (col 9) )
		(cell (id 08) (val 3) (box 7) (row 8) (col 1) )
		(cell (id 08) (val 7) (box 7) (row 8) (col 2) )
		(cell (id 08) (val 8) (box 7) (row 8) (col 3) )
		(cell (id 08) (val 9) (box 8) (row 8) (col 4) )
		(cell (id 08) (val 5) (box 8) (row 8) (col 5) )
		(cell (id 08) (val 1) (box 8) (row 8) (col 6) )
		(cell (id 08) (val 4) (box 9) (row 8) (col 7) )
		(cell (id 08) (val 6) (box 9) (row 8) (col 8) )
		(cell (id 08) (val 2) (box 9) (row 8) (col 9) )
		(cell (id 09) (val 1) (box 7) (row 9) (col 1) )
		(cell (id 09) (val 9) (box 7) (row 9) (col 2) )
		(cell (id 09) (val 0) (box 7) (row 9) (col 3) )
		(cell (id 09) (val 4) (box 8) (row 9) (col 4) )
		(cell (id 09) (val 0) (box 8) (row 9) (col 5) )
		(cell (id 09) (val 0) (box 8) (row 9) (col 6) )
		(cell (id 09) (val 7) (box 9) (row 9) (col 7) )
		(cell (id 09) (val 3) (box 9) (row 9) (col 8) )
		(cell (id 09) (val 0) (box 9) (row 9) (col 9) )
	)
)