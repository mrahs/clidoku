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

; The puzzle is printed as the following sample:
; Puzzle:
;	* * *  * 2 8  * 6 9
;	* 6 *  9 3 4  * 5 7
;	* 9 *  1 * 7  * * 3
;
;	* * *  * * *  5 1 8
;	* 1 7  * * 2  9 * 6
;	6 5 9  * * 1  7 * *
;
;	1 * *  * * 5  * * *
;	9 2 *  * * 3  * 7 *
;	5 7 *  2 9 6  * * *

(defrule print-start
	(phase print-puzzle)
	=>
	(printout t "Puzzle: " crlf)
	(assert (print-cell 1 1))
)

(defrule print-value
	?f0 <- (phase print-puzzle)
	?f1 <- (print-cell ?r ?c)
	(cell (row ?r) (col ?c) (val ?v))
	=>
	(retract ?f1)

	; print value
	(if (= ?v 0)
		then
		(printout t "*")
		else
		(printout t ?v)
	)

	(if (< ?c 9)
		then	; print cell separator
		(if (= 0 (mod ?c 3))
			then
			(printout t "  ")
			else
			(printout t " ")
		)
		(assert (print-cell ?r (+ 1 ?c)))
		else	; print row separator
		(if (< ?r 9)
			then
			(if (= 0 (mod ?r 3))
				then
				(printout t crlf crlf)
				else
				(printout t crlf)
			)
			(assert (print-cell (+ 1 ?r) 1))
			else	; print footer
			(printout t crlf)
			(retract ?f0)
		)
	)
)

(defrule print-used-techniques-header
	(declare (salience 2)) ; to activate first
	(phase print-techniques)
	=>
	(printout t "Techniques Used:" crlf)
)

(defrule print-used-techniques
	(declare (salience 1)) ; to activate secnod
	(phase print-techniques)
	(technique (name ?t) (used yes))
	=>
	(printout t "    " ?t crlf)
)

(defrule print-used-techniques-done
	(declare (salience 0)) ; to activate third
	?f <- (phase print-techniques)
	=>
	(retract ?f)
)

(defrule print-status-valid
	?f <- (phase print-status)
	(valid)
	=>
	(retract ?f)
	(printout t "Solved :)" crlf)
)

(defrule print-status-invalid
	?f <- (phase print-status)
	(invalid (why $?r))
	=>
	(retract ?f)
	(printout t "Invalid: " ?r crlf)
)
