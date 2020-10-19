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


; 1. look for an unsolved cell.
; 2. check boxes for duplicate numbers.
; 3. check rows for duplicate numbers.
; 4. check columns for duplicate numbers.
; once we find an unsolved cell or a duplicate number in a house, check is terminated.

(defrule check-begin
	(phase check)
	=>
	(assert (check-cell))
)

(defrule check-cell-invalid
	?f0 <- (phase check)
	?f1 <- (check-cell)

	(cell (val 0) (row ?r) (col ?c))
	=>
	(retract ?f0 ?f1)
	(assert (invalid (why Unsolved Cell in ?r ?c)))
)

(defrule check-cell-valid
	(phase check)

	(not (cell (val 0)))
	=>
	(assert (check box 1))
)

(defrule check-box-invalid
	?f0 <- (phase check)
	?f1 <- (check box ?b)
	(cell (box ?b) (val ?v) (id ?id))
	(cell (box ?b) (val ?v) (id ~?id))
	=>
	(retract ?f0 ?f1)
	(assert (invalid (why Duplicate Value ?v in Box ?b)))
)

(defrule check-box-valid
	(phase check)
	?f <- (check box ?b)
	(cell (box ?b) (val ?v) (id ?id))
	(not (cell (box ?b) (val ?v) (id ~?id)))
	=>
	(retract ?f)
	(if (= ?b 9)
		then
		(assert (check row 1))
		else
		(assert (check box (+ 1 ?b)))
	)
)

(defrule check-row-invalid
	?f0 <- (phase check)
	?f1 <- (check row ?r)
	(cell (row ?r) (val ?v) (id ?id))
	(cell (row ?r) (val ?v) (id ~?id))
	=>
	(retract ?f0 ?f1)
	(assert (invalid (why Duplicate Value ?v in row ?r)))
)

(defrule check-row-valid
	(phase check)
	?f <- (check row ?r)
	(cell (row ?r) (val ?v) (id ?id))
	(not (cell (row ?r) (val ?v) (id ~?id)))
	=>
	(retract ?f)
	(if (= ?r 9)
		then
		(assert (check col 1))
		else
		(assert (check row (+ 1 ?r)))
	)
)

(defrule check-column-invalid
	?f0 <- (phase check)
	?f1 <- (check col ?c)
	(cell (col ?c) (val ?v) (id ?id))
	(cell (col ?c) (val ?v) (id ~?id))
	=>
	(retract ?f0 ?f1)
	(assert (invalid (why Duplicate Value ?v in column ?c)))
)

(defrule check-column-valid
	?f0 <- (phase check)
	?f1 <- (check col ?c)
	(cell (col ?c) (val ?v) (id ?id))
	(not (cell (col ?c) (val ?v) (id ~?id)))
	=>
	(retract ?f1)
	(if (= ?c 9)
		then
		(retract ?f0)
		(assert (valid))
		else
		(assert (check col (+ 1 ?c)))
	)
)

;(defrule check-end-invalid
;	?f <- (invalid (why $?r))
;	=>
;	(retract ?f)
;	(printout t "Invalid: " ?r crlf)
;)

;(defrule check-end-valid
;	?f <- (valid)
;	=>
;	(retract ?f)
;	(printout t "Solved :)" crlf)
;)
