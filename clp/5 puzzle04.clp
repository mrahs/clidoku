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
;	8 * 1  4 7 *  * * 3
;	6 7 *  3 5 8  * 1 *
;	3 4 *  * 1 *  7 8 *
;
;	* 3 6  1 8 4  9 7 *
;	1 8 7  * 3 *  * 4 *
;	9 * 4  * 6 7  1 3 8
;
;	* 1 8  7 9 3  * 6 *
;	4 6 *  8 2 1  3 * 7
;	7 * 3  6 4 5  8 * 1

; Solution:
;	1 5 8  2 4 6  3 7 9
;	2 3 6  7 9 1  8 5 4
;	7 9 4  3 8 5  2 6 1
;
;	5 7 9  1 3 8  6 4 2
;	4 8 3  6 2 9  7 1 5
;	6 2 1  5 7 4  9 3 8
;
;	9 6 2  4 1 7  5 8 3
;	3 4 7  8 5 2  1 9 6
;	8 1 5  9 6 3  4 2 7

; Using:
;	XY-Wing
;	Locked Candidate Claiming
;	Locked Canddiate Pointing
;	Hidden Single

(defrule build-puzzle
	?f <- (phase build-puzzle)
	=>
	(retract ?f)
	(assert 
		(cell (val 8) (row 1) (col 1) (id 01) (box 1) )
		(cell (val 0) (row 1) (col 2) (id 01) (box 1) )
		(cell (val 1) (row 1) (col 3) (id 01) (box 1) )
		(cell (val 4) (row 1) (col 4) (id 01) (box 2) )
		(cell (val 7) (row 1) (col 5) (id 01) (box 2) )
		(cell (val 0) (row 1) (col 6) (id 01) (box 2) )
		(cell (val 0) (row 1) (col 7) (id 01) (box 3) )
		(cell (val 0) (row 1) (col 8) (id 01) (box 3) )
		(cell (val 3) (row 1) (col 9) (id 01) (box 3) )
		(cell (val 6) (row 2) (col 1) (id 02) (box 1) )
		(cell (val 7) (row 2) (col 2) (id 02) (box 1) )
		(cell (val 0) (row 2) (col 3) (id 02) (box 1) )
		(cell (val 3) (row 2) (col 4) (id 02) (box 2) )
		(cell (val 5) (row 2) (col 5) (id 02) (box 2) )
		(cell (val 8) (row 2) (col 6) (id 02) (box 2) )
		(cell (val 0) (row 2) (col 7) (id 02) (box 3) )
		(cell (val 1) (row 2) (col 8) (id 02) (box 3) )
		(cell (val 0) (row 2) (col 9) (id 02) (box 3) )
		(cell (val 3) (row 3) (col 1) (id 03) (box 1) )
		(cell (val 4) (row 3) (col 2) (id 03) (box 1) )
		(cell (val 0) (row 3) (col 3) (id 03) (box 1) )
		(cell (val 0) (row 3) (col 4) (id 03) (box 2) )
		(cell (val 1) (row 3) (col 5) (id 03) (box 2) )
		(cell (val 0) (row 3) (col 6) (id 03) (box 2) )
		(cell (val 7) (row 3) (col 7) (id 03) (box 3) )
		(cell (val 8) (row 3) (col 8) (id 03) (box 3) )
		(cell (val 0) (row 3) (col 9) (id 03) (box 3) )
		(cell (val 0) (row 4) (col 1) (id 04) (box 4) )
		(cell (val 3) (row 4) (col 2) (id 04) (box 4) )
		(cell (val 6) (row 4) (col 3) (id 04) (box 4) )
		(cell (val 1) (row 4) (col 4) (id 04) (box 5) )
		(cell (val 8) (row 4) (col 5) (id 04) (box 5) )
		(cell (val 4) (row 4) (col 6) (id 04) (box 5) )
		(cell (val 9) (row 4) (col 7) (id 04) (box 6) )
		(cell (val 7) (row 4) (col 8) (id 04) (box 6) )
		(cell (val 0) (row 4) (col 9) (id 04) (box 6) )
		(cell (val 1) (row 5) (col 1) (id 05) (box 4) )
		(cell (val 8) (row 5) (col 2) (id 05) (box 4) )
		(cell (val 7) (row 5) (col 3) (id 05) (box 4) )
		(cell (val 0) (row 5) (col 4) (id 05) (box 5) )
		(cell (val 3) (row 5) (col 5) (id 05) (box 5) )
		(cell (val 0) (row 5) (col 6) (id 05) (box 5) )
		(cell (val 0) (row 5) (col 7) (id 05) (box 6) )
		(cell (val 4) (row 5) (col 8) (id 05) (box 6) )
		(cell (val 0) (row 5) (col 9) (id 05) (box 6) )
		(cell (val 9) (row 6) (col 1) (id 06) (box 4) )
		(cell (val 0) (row 6) (col 2) (id 06) (box 4) )
		(cell (val 4) (row 6) (col 3) (id 06) (box 4) )
		(cell (val 0) (row 6) (col 4) (id 06) (box 5) )
		(cell (val 6) (row 6) (col 5) (id 06) (box 5) )
		(cell (val 7) (row 6) (col 6) (id 06) (box 5) )
		(cell (val 1) (row 6) (col 7) (id 06) (box 6) )
		(cell (val 3) (row 6) (col 8) (id 06) (box 6) )
		(cell (val 8) (row 6) (col 9) (id 06) (box 6) )
		(cell (val 0) (row 7) (col 1) (id 07) (box 7) )
		(cell (val 1) (row 7) (col 2) (id 07) (box 7) )
		(cell (val 8) (row 7) (col 3) (id 07) (box 7) )
		(cell (val 7) (row 7) (col 4) (id 07) (box 8) )
		(cell (val 9) (row 7) (col 5) (id 07) (box 8) )
		(cell (val 3) (row 7) (col 6) (id 07) (box 8) )
		(cell (val 0) (row 7) (col 7) (id 07) (box 9) )
		(cell (val 6) (row 7) (col 8) (id 07) (box 9) )
		(cell (val 0) (row 7) (col 9) (id 07) (box 9) )
		(cell (val 4) (row 8) (col 1) (id 08) (box 7) )
		(cell (val 6) (row 8) (col 2) (id 08) (box 7) )
		(cell (val 0) (row 8) (col 3) (id 08) (box 7) )
		(cell (val 8) (row 8) (col 4) (id 08) (box 8) )
		(cell (val 2) (row 8) (col 5) (id 08) (box 8) )
		(cell (val 1) (row 8) (col 6) (id 08) (box 8) )
		(cell (val 3) (row 8) (col 7) (id 08) (box 9) )
		(cell (val 0) (row 8) (col 8) (id 08) (box 9) )
		(cell (val 7) (row 8) (col 9) (id 08) (box 9) )
		(cell (val 7) (row 9) (col 1) (id 09) (box 7) )
		(cell (val 0) (row 9) (col 2) (id 09) (box 7) )
		(cell (val 3) (row 9) (col 3) (id 09) (box 7) )
		(cell (val 6) (row 9) (col 4) (id 09) (box 8) )
		(cell (val 4) (row 9) (col 5) (id 09) (box 8) )
		(cell (val 5) (row 9) (col 6) (id 09) (box 8) )
		(cell (val 8) (row 9) (col 7) (id 09) (box 9) )
		(cell (val 0) (row 9) (col 8) (id 09) (box 9) )
		(cell (val 1) (row 9) (col 9) (id 09) (box 9) )
	)
)