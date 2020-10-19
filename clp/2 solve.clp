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

; reference: http://hodoku.sourceforge.net/en/techniques.php

; Notes:
; The solving phase is divided into two sub-phases: find-candidates sub-phase and rc sub-phase.
; In find-candidates sub-phase, we iterate over every cell with a value of 0, and add all possible candidates using the Sudoku's basic principle.
; In rc (remove-candidates) sub-phase, we start removing candidates using various techniques.

; Priorities:
; When a candidate wins for a cell, all other candidates must be removed from that cell. And any other candidate that is confined by a house of the solved cell must be removed as well.
; The 'house' term means a box, a row, or a column.
; This is achieved through priorities. For example, we assign a higher priority for the cleaning rules, whose mission is to remove candidates when a cell is solved.

; Techniques Activation:
; When more techniques are added, the performance degraded; and I needed a solution.
; The problem is that CLIPS will try all technique in every step.
; The basic idea was to activate one technique at a time, and try others only after the active technique is no longer useful.
; This is achieved using priorities.
;	0. make a notice of activating the highest priority non-active technique.
;	1. before activating the technique, deactivate all others.
; 	2. activate the technique.
;	3. try it.
;	4. if it has been used
;		then (reverse activation) activate other techniques with a higher priority, one at a time, in their descending order of priorities (highest first).
;		else try next (go to 0).
; This solution is not complete. During the reverse activation step, all active techniques are checked.
; However, I had good results.

; Manual Technique Assertion:
; You can tell the solver what techniques to use. This is achieved by manual techniques assertion.
; If your assert the fact (manual-technique-assertion), no technique will be asserted, and you'll have to manually assert them.
; This fact must be asserted before the fact (phase solve).

; Debug Mode:
; If you assert that fact (debug) before (phase solve), solving will pause after sub-phase find-candidates.


;############################
;# Priorities of Techniques #
;############################

(defglobal ?*priority-cleaning* 						 = 100)
(defglobal ?*priority-Full-House*						 = -1)
(defglobal ?*priority-Naked-Single* 					 = -2)
(defglobal ?*priority-Hidden-Single* 					 = -3)
(defglobal ?*priority-Locked-Candidate-Pointing* 		 = -4)
(defglobal ?*priority-Locked-Candidate-Claiming* 		 = -5)
(defglobal ?*priority-Locked-Candidate-Multiple-Lines*	 = -6)
(defglobal ?*priority-Naked-Pair*						 = -7)
(defglobal ?*priority-Hidden-Pair* 						 = -8)
(defglobal ?*priority-Locked-Pair*						 = -9)
(defglobal ?*priority-X-Wing*							 = -10)
(defglobal ?*priority-Naked-Triple* 					 = -11)
(defglobal ?*priority-Hidden-Triple*					 = -12)
(defglobal ?*priority-Locked-Triple*					 = -13)
(defglobal ?*priority-XY-Wing*							 = -14)
(defglobal ?*priority-XYZ-Wing* 						 = -15)
(defglobal ?*priority-W-Wing* 							 = -16)
(defglobal ?*priority-Unique-Rectangle-1*				 = -17)
(defglobal ?*priority-Unique-Rectangle-2*				 = -18)
(defglobal ?*priority-Unique-Rectangle-4*				 = -19)
(defglobal ?*priority-Unique-Rectangle-5*				 = -20)
(defglobal ?*priority-Unique-Rectangle-6*				 = -21)
(defglobal ?*priority-Swordfish*						 = -22)
(defglobal ?*priority-Naked-Quadruple*					 = -23)
(defglobal ?*priority-Hidden-Quadruple*					 = -24)
(defglobal ?*priority-Jellyfish*						 = -25)

(defglobal ?*priority-technique-used* 					 = -50)
(defglobal ?*priority-technique-reverse-activation* 	 = -51)
(defglobal ?*priority-technique-reverse-activation-done* = -52)
(defglobal ?*priority-technique-notify-next*			 = -53)
(defglobal ?*priority-technique-next-deactivate-othres*	 = -54)
(defglobal ?*priority-technique-next-activate* 			 = -55)

;######################
;# Techniques Control #
;######################

(defrule techniques-priorities "initialize techniques with priorities"
	(rc)
	(not (manual-technique-assertion))
	=>
	(assert
		(technique (name Full-House) 						(priority ?*priority-Full-House*) 						(active no) (used no) )
		(technique (name Naked-Single) 						(priority ?*priority-Naked-Single*)						(active no) (used no) )
		(technique (name Hidden-Single) 					(priority ?*priority-Hidden-Single*)					(active no) (used no) )
		(technique (name Locked-Candidate-Pointing)			(priority ?*priority-Locked-Candidate-Pointing*)		(active no) (used no) )
		(technique (name Locked-Candidate-Claiming) 		(priority ?*priority-Locked-Candidate-Claiming*)		(active no) (used no) )
		(technique (name Locked-Candidate-Multiple-Lines) 	(priority ?*priority-Locked-Candidate-Multiple-Lines*)	(active no) (used no) )
		(technique (name Naked-Pair) 						(priority ?*priority-Naked-Pair*)						(active no) (used no) )
		(technique (name Hidden-Pair) 						(priority ?*priority-Hidden-Pair*)						(active no) (used no) )
		(technique (name Locked-Pair) 						(priority ?*priority-Locked-Pair*)						(active no) (used no) )
		(technique (name Locked-Triple) 					(priority ?*priority-Locked-Triple*)					(active no) (used no) )
		(technique (name X-Wing) 							(priority ?*priority-X-Wing*)							(active no) (used no) )
		(technique (name Naked-Triple) 						(priority ?*priority-Naked-Triple*)						(active no) (used no) )
		(technique (name Hidden-Triple) 					(priority ?*priority-Hidden-Triple*)					(active no) (used no) )
		(technique (name XY-Wing) 							(priority ?*priority-XY-Wing*)							(active no) (used no) )
		(technique (name XYZ-Wing) 							(priority ?*priority-XYZ-Wing*)							(active no) (used no) )
		(technique (name W-Wing) 							(priority ?*priority-W-Wing*)							(active no) (used no) )
		(technique (name Swordfish) 						(priority ?*priority-Swordfish*)						(active no) (used no) )
		(technique (name Naked-Quadruple) 					(priority ?*priority-Naked-Quadruple*)					(active no) (used no) )
		(technique (name Hidden-Quadruple) 					(priority ?*priority-Hidden-Quadruple*)					(active no) (used no) )
		(technique (name Jellyfish) 						(priority ?*priority-Jellyfish*)						(active no) (used no) )
		(technique (name Unique-Rectangle-1) 				(priority ?*priority-Unique-Rectangle-1*)				(active no) (used no) )
		(technique (name Unique-Rectangle-2) 				(priority ?*priority-Unique-Rectangle-2*)				(active no) (used no) )
		(technique (name Unique-Rectangle-4) 				(priority ?*priority-Unique-Rectangle-4*)				(active no) (used no) )
		(technique (name Unique-Rectangle-5) 				(priority ?*priority-Unique-Rectangle-5*)				(active no) (used no) )
		(technique (name Unique-Rectangle-6) 				(priority ?*priority-Unique-Rectangle-6*)				(active no) (used no) )
		(start-techniques)
	)
)

(defrule start-techniques
	(rc)
	?f1 <- (start-techniques)

	; get the highest priority technique
	?f2 <- (technique (priority ?p1))
	(not   (technique (priority ?p2&:(> ?p2 ?p1))))

	=>
	(retract ?f1)
	(assert (activate-reverse))
	(modify ?f2 (active yes))
)

(defrule technique-reverese-activation
	(declare (salience ?*priority-technique-reverse-activation*))

	(rc)
	(activate-reverse)

	; get the lowest priority active technique
		 (technique (active yes) (priority ?p1))
	(not (technique (active yes) (priority ?p2&:(< ?p2 ?p1))))

	; get the highest non-active technique whose priority is higher than the choosen active one
	?f <- (technique (active no) (priority ?p3&:(> ?p3 ?p1)))
	(not  (technique (active no) (priority ?p4&:(and
													(> ?p4 ?p1)
													(> ?p4 ?p3)))))
	
	=>
	(modify ?f (active yes))
)

(defrule technique-reverese-activation-done
	(declare (salience ?*priority-technique-reverse-activation-done*))

	(rc)
	?f <- (activate-reverse)

	=>
	(retract ?f)
)

(defrule technique-notify-next
	(declare (salience ?*priority-technique-notify-next*))

	(rc)
	(not (activate-reverse))

	; get the lowest priority active technique
		 (technique (active yes) (priority ?p1))
	(not (technique (active yes) (priority ?p2&:(< ?p2 ?p1))))

	; get the next lower priority non-active technique
		 (technique (active no) (priority ?p3&:(< ?p3 ?p1)) (name ?n) )
	(not (technique (active no) (priority ?p4&:(and
													(< ?p4 ?p1)
													(> ?p4 ?p3)))))

	=>
	(assert (next ?n))
)

(defrule technique-next-deactivate-othres
	(declare (salience ?*priority-technique-next-deactivate-othres*))

	(rc)
	(not (activate-reverse))

	; if there is a notice of a next technique
	(next ?n)
	(technique (name ?n) (priority ?p1))

	; get the higher priority active technique
	?f <- (technique (active yes) (priority ?p2&:(> ?p2 ?p1)))

	=>
	(modify ?f (active no))
)

(defrule technique-next-activate
	(declare (salience ?*priority-technique-next-activate*))

	(rc)
	(not (activate-reverse))

	; if there is a notice of a next technique
	?f1 <- (next ?n)
	?f2 <- (technique (name ?n))

	=>
	(retract ?f1)
	(modify ?f2 (active yes))
)

(defrule technique-used
	(declare (salience ?*priority-technique-used*))

	; if there is a notice on a used technique
	?f1 <- (tech-used ?name)
	?f2 <- (technique (name ?name))

	=>
	(retract ?f1)
	(modify ?f2 (used yes))
	(assert (activate-reverse))
)

;#################
;# Start Solving #
;#################

(defrule solve-start
	?f <- (phase solve)
	=>
	(retract ?f)
	(assert (find-candidates))
)

;################
;# Stop Solving #
;################

(defrule solve-stop
	?f <- (rc)
	(not (ccell))
	=>
	(retract ?f)
)

;###################
;# Find Candidates #
;###################

(defrule find-candidates
	(find-candidates)

	(cell (id ?id) (val 0))

	=>
	(assert (iterate ?id 1))
)

; Two possible states:
;	Constraints are met 	=> add candidate
;	Constraints are not met => ignore the iteration

(defrule iterate-assert
	?f <- (iterate ?id ?i)

	(cell (id ?id) (box ?b) (row ?r) (col ?c))	; get info

	(not (cell (val ?i) (id ~?id) (box ?b)))	; box doesn't have the value
	(not (cell (val ?i) (id ~?id) (row ?r)))	; row doesn't have the value
	(not (cell (val ?i) (id ~?id) (col ?c)))	; col doesn't have the value

	=>
	(retract ?f)
	(assert (ccell (id ?id) (val ?i) (box ?b) (row ?r) (col ?c) ))
	(if (<> ?i 9)
		then
		(assert (iterate ?id (+ 1 ?i)))
	)
)

(defrule iterate-ignore
	?f <- (iterate ?id ?i)

	(cell (id ?id) (box ?b) (row ?r) (col ?c))	; get info

	(or
		(cell (val ?i) (id ~?id) (box ?b))		; box has the value
		(cell (val ?i) (id ~?id) (row ?r))		; row has the value
		(cell (val ?i) (id ~?id) (col ?c))		; col has the value
	)

	=>
	(retract ?f)
	(if (<> ?i 9)
		then
		(assert (iterate ?id (+ 1 ?i)))
	)
)

(defrule start-rc
	(declare (salience -1))	; find-candidates is done

	?f <- (find-candidates)	; we are in sub-phase find-candidates
	(not (iterate ? ?))		; no more iterations
	(not (debug))			; we are not in debug mode

	=>
	(retract ?f)
	(assert (rc))
)

(defrule find-candidates-done
	(declare (salience -1))	; find-candidates is done

	?f <- (find-candidates) ; we are in sub-phase find-candidates
	(not (iterate ? ?))		; no more iterations
	(debug)					; we are in debug mode

	=>
	(retract ?f)
)

;######################################
;# Cleaning After a Winning Candidate #
;######################################

(defrule cleaning-cell
	(declare (salience ?*priority-cleaning*))

	(rc)

	(solved ?v ? ?r ?c)							; if we have a notice of a solved cell
	?f <- (ccell (row ?r) (col ?c))				; and there is another candidate for the same cell

	=>
	(retract ?f)
)

(defrule cleaning-box
	(declare (salience ?*priority-cleaning*))

	(rc)

	(solved ?v ?b ? ?)							; if we have a notice of a solved cell
	?f <- (ccell (val ?v) (box ?b))				; and there is a candidate with same value in the same box

	=>
	(retract ?f)
)

(defrule cleaning-row
	(declare (salience ?*priority-cleaning*))

	(rc)

	(solved ?v ? ?r ?)							; if we have a notice of a solved cell
	?f <- (ccell (val ?v) (row ?r))				; and there is a candidate with same value in the same row

	=>
	(retract ?f)
)

(defrule cleaning-col
	(declare (salience ?*priority-cleaning*))

	(rc)

	(solved ?v ? ? ?c)							; if we have a notice of a solved cell
	?f <- (ccell (val ?v) (col ?c))				; and there is a candidate with same value in the same column

	=>
	(retract ?f)
)

(defrule cleaning-done
	(declare (salience ?*priority-cleaning*))

	(rc)

	?f <- (solved ?v ?b ?r ?c)						; if we have a notice of a solved cell
	(not (ccell (row ?r) (col ?c)))					; cell doesn't have candidates
	(not (ccell (val ?v) (box ?b)))					; box doesn't contain a candidate with the same value
	(not (ccell (val ?v) (row ?r)))					; row doesn't contain a candidate with the same value
	(not (ccell (val ?v) (col ?c)))					; col doesn't contain a candidate with the same value

	=>
	(retract ?f)
)

;########################
;########################
;## Singles Techniques ##
;########################
;########################

;########################
;# Full-House Technique #
;########################
; look for a house that has only one candidate left

(defrule rc-Full-House-box
	(declare (salience ?*priority-Full-House*))

	(rc)
	(technique (name Full-House) (active yes))

	?f1 <- (ccell (val  ?v) (box ?b))
	(not   (ccell (val ~?v) (box ?b)))

	?f2 <- (cell  (val   0) (box ?b) (row ?r) (col ?c) )		; get info

	=>
	(retract ?f1)
	(modify ?f2 (val ?v))
	(assert (solved ?v ?b ?r ?c))		; this will activate cleaning rules
	(assert (tech-used Full-House))
)

(defrule rc-Full-House-row
	(declare (salience ?*priority-Full-House*))

	(rc)
	(technique (name Full-House) (active yes))

	?f1 <- (ccell (val  ?v) (row ?r))
	(not   (ccell (val ~?v) (row ?r)))

	?f2 <- (cell   (val  0) (row ?r) (col ?c) (box ?b) )		; get info

	=>
	(retract ?f1)
	(modify ?f2 (val ?v))
	(assert (solved ?v ?b ?r ?c))		; this will activate cleaning rules
	(assert (tech-used Full-House))
)

(defrule rc-Full-House-col
	(declare (salience ?*priority-Full-House*))

	(rc)
	(technique (name Full-House) (active yes))

	?f1 <- (ccell (val  ?v) (col ?c))
	(not   (ccell (val ~?v) (col ?c)))
	?f2 <- (cell  (val   0) (col ?c) (row ?r) (box ?b) )		; get info

	=>
	(retract ?f1)
	(modify ?f2 (val ?v))
	(assert (solved ?v ?b ?r ?c))		; this will activate cleaning rules
	(assert (tech-used Full-House))
)

;##########################
;# Naked-Single Technique #
;##########################
; look for a cell that has only one candidate

(defrule rc-Naked-Single
	(declare (salience ?*priority-Naked-Single*))

	(rc)
	(technique (name Naked-Single) (active yes))

	?f1 <- (ccell (val  ?v) (id ?id))
	(not   (ccell (val ~?v) (id ?id)))

	?f2 <- (cell  (val   0) (id ?id) (box ?b) (row ?r) (col ?c))		; get info

	=>
	(retract ?f1)
	(modify ?f2 (val ?v))
	(assert (solved ?v ?b ?r ?c))		; this will activate cleaning rules
	(assert (tech-used Naked-Single))
)

;###########################
;# Hidden-Single Technique #
;###########################
; look for a candidate who is the only one in a house

(defrule rc-Hidden-Single-box
	(declare (salience ?*priority-Hidden-Single*))

	(rc)
	(technique (name Hidden-Single) (active yes))

	?f1 <- (ccell (val ?v) (box ?b) (id  ?id))
	(not   (ccell (val ?v) (box ?b) (id ~?id)))

	?f2 <- (cell  (val  0) (box ?b) (id  ?id) (row ?r) (col ?c))		; get info

	=>
	(retract ?f1)
	(modify ?f2 (val ?v))
	(assert (solved ?v ?b ?r ?c))
	(assert (tech-used Hidden-Single))
)

(defrule rc-Hidden-Single-row
	(declare (salience ?*priority-Hidden-Single*))

	(rc)
	(technique (name Hidden-Single) (active yes))

	?f1 <- (ccell (val ?v) (row ?r) (id  ?id))
	(not   (ccell (val ?v) (row ?r) (id ~?id)))

	?f2 <- (cell  (val  0) (row ?r) (id  ?id) (box ?b) (col ?c))		; get info

	=>
	(retract ?f1)
	(modify ?f2 (val ?v))
	(assert (solved ?v ?b ?r ?c))
	(assert (tech-used Hidden-Single))
)

(defrule rc-Hidden-Single-col
	(declare (salience ?*priority-Hidden-Single*))

	(rc)
	(technique (name Hidden-Single) (active yes))

	?f1 <- (ccell (val ?v) (col ?c) (id  ?id))
	(not   (ccell (val ?v) (col ?c) (id ~?id)))
	?f2 <- (cell  (val  0) (col ?c) (id  ?id) (box ?b) (row ?r))		; get info

	=>
	(retract ?f1)
	(modify ?f2 (val ?v))
	(assert (solved ?v ?b ?r ?c))
	(assert (tech-used Hidden-Single))
)

;############################
;############################
;# Intersections Techniques #
;############################
;############################

;#######################################
;# Locked-Candidate-Pointing Technique #
;#######################################
; look for a candidate that appears only in one line in a box
; and remove it from other boxes in the same line

(defrule rc-Locked-Candidate-Pointing-row
	(declare (salience ?*priority-Locked-Candidate-Pointing*))

	(rc)
	(technique (name Locked-Candidate-Pointing) (active yes))

		 	(ccell (val ?v) (box  ?b) (row  ?r))	; if we have a candidate in a row and a box
	(not 	(ccell (val ?v) (box  ?b) (row ~?r)))	; and it doesn't appear in any other row in this box
	?f1 <-  (ccell (val ?v) (box ~?b) (row  ?r))	; get other candidates with the same value and in the same row but from other boxes

	=>
	(retract ?f1)
	(assert (tech-used Locked-Candidate-Pointing))
)

(defrule rc-Locked-Candidate-Pointing-col
	(declare (salience ?*priority-Locked-Candidate-Pointing*))

	(rc)
	(technique (name Locked-Candidate-Pointing) (active yes))

			(ccell (val ?v) (box  ?b) (col  ?c))		; if we have a candidate in a column and a box
	(not 	(ccell (val ?v) (box  ?b) (col ~?c)))		; and it doesn't appear in any other column in this box
	?f1 <-  (ccell (val ?v) (box ~?b) (col  ?c))		; get other candidates with the same value and in the same column but from other boxes

	=>
	(retract ?f1)
	(assert (tech-used Locked-Candidate-Pointing))
)

;#######################################
;# Locked-Candidate-Claiming Technique #
;#######################################
; look for a candidate that appears only in one box in a line
; and remove it from other lines of the same box

(defrule rc-Locked-Candidate-Claiming-row
	(declare (salience ?*priority-Locked-Candidate-Claiming*))

	(rc)
	(technique (name Locked-Candidate-Claiming) (active yes))

			(ccell (val ?v) (box  ?b) (row ?r))				; if we have a candidate in a row and a box
	(not 	(ccell (val ?v) (box ~?b) (row ?r)))			; and it doesn't appear in the same row from other boxes
	?f1 <-  (ccell (val ?v) (box  ?b) (row ~?r))			; get other candidates with the same value and the same box but other rows

	=>
	(retract ?f1)
	(assert (tech-used Locked-Candidate-Claiming))
)


(defrule rc-Locked-Candidate-Claiming-col
	(declare (salience ?*priority-Locked-Candidate-Claiming*))

	(rc)
	(technique (name Locked-Candidate-Claiming) (active yes))

			(ccell (val ?v) (box  ?b) (col  ?c))			; if we have a candidate in a column and a box
	(not 	(ccell (val ?v) (box ~?b) (col  ?c)))			; and it doesn't appear in the same column from other boxes
	?f1 <-  (ccell (val ?v) (box  ?b) (col ~?c))			; get other candidates with the same value and the same box but other columns

	=>
	(retract ?f1)
	(assert (tech-used Locked-Candidate-Claiming))
)

;#############################################
;# Locked-Candidate-Multiple-Lines Technique #
;#############################################
; look for a candidate that appears only in the same two lines of two boxes
; and remove it from those two lines of the third box

(defrule rc-Locked-Candidate-Multiple-Lines-rows
	(declare (salience ?*priority-Locked-Candidate-Multiple-Lines*))

	(rc)
	(technique (name Locked-Candidate-Multiple-Lines) (active yes))

		 (ccell (val ?v) (box ?b1) (row  ?r1))				; if we have a candidate in a row (r1) and a box
		 (ccell (val ?v) (box ?b1) (row  ?r2 & ~?r1))		; and it appears in another row (r2) in the same box
	(not (ccell (val ?v) (box ?b1) (row ~?r2 & ~?r1)))		; but it doesn't appear in the third row

		 (ccell (val ?v) (box ?b2&~?b1) (row  ?r1))			; and it appears in another box and the same row (r1)
		 (ccell (val ?v) (box ?b2) 	 	(row  ?r2))			; and it appears in that other box in that same other row (r2)
	(not (ccell (val ?v) (box ?b2) 		(row ~?r2 & ~?r1)))	; but it doesn't appear in that third row

	?f1 <- (ccell (val ?v) (box ~?b1 & ~?b2) (row ?r1 | ?r2))	; get other candidates from the third box and those two rows (r1 & r2)
	=>
	(retract ?f1)
	(assert (tech-used Locked-Candidate-Multiple-Lines))
)

(defrule rc-Locked-Candidate-Multiple-Lines-cols
	(declare (salience ?*priority-Locked-Candidate-Multiple-Lines*))

	(rc)
	(technique (name Locked-Candidate-Multiple-Lines) (active yes))

		 (ccell (val ?v) (box ?b1) (col  ?c1))				; if we have a candidate in a column (c1) and a box
		 (ccell (val ?v) (box ?b1) (col  ?c2 & ~?c1))		; and it appears in another column (c2) in the same box
	(not (ccell (val ?v) (box ?b1) (col ~?c2 & ~?c1)))		; but it doesn't appear in the third column

		 (ccell (val ?v) (box ?b2&~?b1) (col  ?c1))			; and it appears in another box and the same column (c1)
		 (ccell (val ?v) (box ?b2) 		(col  ?c2))			; and it appears in that other box in that same other column (c2)
	(not (ccell (val ?v) (box ?b2) 		(col ~?c2 & ~?c1)))	; but it doesn't appear in that third column

	?f1 <- (ccell (val ?v) (box ~?b1 & ~?b2) (col ?c1 | ?c2))	; get other candidates from the third box and those two columns (c1 & c2)

	=>
	(retract ?f1)
	(assert (tech-used Locked-Candidate-Multiple-Lines))
)

;#########################
;# Locked-Pair Technique #
;#########################
; look for a naked pair that is confined to two houses (a box with a row or a column)
; and remove the pair from other cells of the two houses

(defrule Locked-Pair-row
	(declare (salience ?*priority-Locked-Pair*))

	(rc)
	(technique (name Locked-Pair) (active yes))

		 (ccell (val  ?v1) 		  (id ?id1) 		 (box ?b) (row ?r))
		 (ccell (val  ?v2 & ~?v1) (id ?id1))
	(not (ccell (val ~?v1 & ~?v2) (id ?id1)))

		 (ccell (val  ?v1) 		  (id ?id2 & ~?id1)  (box ?b) (row ?r))
		 (ccell (val  ?v2) 		  (id ?id2))
	(not (ccell (val ~?v1 & ~?v2) (id ?id2)))

	?f1 <- (ccell (val ?v1 | ?v2) (id ~?id1 & ~?id2) (box ?bx) (row ?rx))
	(test (or
			(= ?bx ?b)
			(= ?rx ?r)
		)
	)

	=>
	(retract ?f1)
	(assert (tech-used Locked-Pair))
)

(defrule Locked-Pair-col
	(declare (salience ?*priority-Locked-Pair*))

	(rc)
	(technique (name Locked-Pair) (active yes))

		 (ccell (val  ?v1) 		  (id ?id1)  		 (box ?b) (col ?c))
		 (ccell (val  ?v2 & ~?v1) (id ?id1))
	(not (ccell (val ~?v1 & ~?v2) (id ?id1)))

		 (ccell (val  ?v1) 		  (id ?id2 & ~?id1)  (box ?b) (col ?c))
		 (ccell (val  ?v2) 		  (id ?id2))
	(not (ccell (val ~?v1 & ~?v2) (id ?id2)))

	?f1 <- (ccell (val ?v1 | ?v2) (id ~?id1 & ~?id2) (box ?bx) (col ?cx))
	(test (or
			(= ?bx ?b)
			(= ?cx ?c)
		)
	)

	=>
	(retract ?f1)
	(assert (tech-used Locked-Pair))
)

;###########################
;# Locked-Triple Technique #
;###########################
; look for a naked triple that is confined to two houses (a box with a row or a column)
; and remove candidates from the two houses

(defrule Locked-Triple-row
	(declare (salience ?*priority-Locked-Triple*))

	(rc)
	(technique (name Locked-Triple) (active yes))

	; find three different candidates (triple) in a box and a row
	(ccell (box ?b) (row ?r) (val ?v1)           	 (id ?id1))
	(ccell (box ?b) (row ?r) (val ?v2 & ~?v1)      	 (id ?id2 & ~?id1))
	(ccell (box ?b) (row ?r) (val ?v3 & ~?v1 & ~?v2) (id ?id3 & ~?id1 & ~?id2))

	; make sure that each id dosen't have any other candidate
	(not (ccell (id ?id1 | ?id2 | ?id3) (val ~?v1 & ~?v2 & ~?v3)))

	?f1 <- (ccell (val ?v1 | ?v2 | ?v3) (id ~?id3 & ~?id2 & ~?id1) (box ?bx) (row ?rx))
	(test (or
			(= ?bx ?b)
			(= ?rx ?r)
		)
	)

	=>
	(retract ?f1)
	(assert (tech-used Locked-Triple))
)

(defrule Locked-Triple-col
	(declare (salience ?*priority-Locked-Triple*))

	(rc)
	(technique (name Locked-Triple) (active yes))

	; find three different candidates (triple) in a box and a column
	(ccell (box ?b) (col ?c) (val ?v1)           	 (id ?id1))
	(ccell (box ?b) (col ?c) (val ?v2 & ~?v1)      	 (id ?id2 & ~?id1))
	(ccell (box ?b) (col ?c) (val ?v3 & ~?v1 & ~?v2) (id ?id3 & ~?id1 & ~?id2))

	; make sure that each id dosen't have any other candidate
	(not (ccell (id ?id1 | ?id2 | ?id3) (val ~?v1 & ~?v2 & ~?v3)))

	?f1 <- (ccell (val ?v1 | ?v2 | ?v3) (id ~?id3 & ~?id2 & ~?id1) (box ?bx) (col ?cx))
	(test (or
			(= ?bx ?b)
			(= ?cx ?c)
		)
	)

	=>
	(retract ?f1)
	(assert (tech-used Locked-Triple))
)

;############################
;############################
;# Naked Subsets Techniques #
;############################
;############################

;########################
;# Naked-Pair Technique #
;########################
; look for two cells in a house that have only the same two candidates
; and remove these candidates from other cells of that house

(defrule rc-Naked-Pair-box
	(declare (salience ?*priority-Naked-Pair*))

	(rc)
	(technique (name Naked-Pair) (active yes))

		 (ccell (val  ?v1) 		  (id ?id1) 	   (box ?b))	; if we have a candidate (v1) for id1 in a box
		 (ccell (val  ?v2 & ~?v1) (id ?id1))					; and we have another candidate (v2) for id1 in the same box
	(not (ccell (val ~?v2 & ~?v1) (id ?id1)))					; and we don't have any other candidate for id1 in the same box

		 (ccell (val  ?v1) 		  (id ?id2 & ~?id1) (box ?b))	; and we have THE candidate (v1) for another id (id2) in the same box
		 (ccell (val  ?v2) 		  (id ?id2))					; and we have THE candidate (v2) for for (id2) in the same box
	(not (ccell (val ~?v2 & ~?v1) (id ?id2)))					; and we don't have any other candidate for (id2) in the same box

	?f1 <- (ccell (box ?b) (val ?v1 | ?v2) (id ~?id2 & ~?id1))	; get other candidates with value (v1) or (v2) in the same box

	=>
	(retract ?f1)
	(assert (tech-used Naked-Pair))
)

(defrule rc-Naked-Pair-row
	(declare (salience ?*priority-Naked-Pair*))

	(rc)
	(technique (name Naked-Pair) (active yes))

		 (ccell (val  ?v1) 		  (id ?id1) 		(row ?r))	; if we have a candidate (v1) for id1 in a row
		 (ccell (val  ?v2 & ~?v1) (id ?id1))					; and we have another candidate (v2) for id1 in the same row
	(not (ccell (val ~?v2 & ~?v1) (id ?id1)))					; and we don't have any other candidate for id1 in the same row

		 (ccell (val  ?v1) 		  (id ?id2 & ~?id1) (row ?r))	; and we have THE candidate (v1) for another id (id2) in the same row
		 (ccell (val  ?v2) 		  (id ?id2))					; and we have THE candidate (v2) for for (id2) in the same row
	(not (ccell (val ~?v2 & ~?v1) (id ?id2)))					; and we don't have any other candidate for (id2) in the same row

	?f1 <- (ccell (row ?r) (val ?v1 | ?v2) (id ~?id2 & ~?id1))		; get other candidates with value (v1) or (v2) in the same row

	=>
	(retract ?f1)
	(assert (tech-used Naked-Pair))
)

(defrule rc-Naked-Pair-col
	(declare (salience ?*priority-Naked-Pair*))

	(rc)
	(technique (name Naked-Pair) (active yes))

		 (ccell (val  ?v1) 		  (id ?id1) 	    (col ?c))	; if we have a candidate (v1) for id1 in a col
		 (ccell (val  ?v2 & ~?v1) (id ?id1))					; and we have another candidate (v2) for id1 in the same col
	(not (ccell (val ~?v2 & ~?v1) (id ?id1)))					; and we don't have any other candidate for id1 in the same col

		 (ccell (val  ?v1) 		  (id ?id2 & ~?id1) (col ?c))	; and we have THE candidate (v1) for another id (id2) in the same col
		 (ccell (val  ?v2) 		  (id ?id2))					; and we have THE candidate (v2) for for (id2) in the same col
	(not (ccell (val ~?v2 & ~?v1) (id ?id2)))					; and we don't have any other candidate for (id2) in the same col

	?f1 <- (ccell (col ?c) (val ?v1 | ?v2) (id ~?id2 & ~?id1))		; get other candidates with value (v1) or (v2) in the same col

	=>
	(retract ?f1)
	(assert (tech-used Naked-Pair))
)

;#########################
;# Hidden-Pair Technique #
;#########################
; look for two candidates in a house that appears only in two cells
; and remove all other candidates from these two cells

(defrule rc-Hidden-Pair-box
	(declare (salience ?*priority-Hidden-Pair*))

	(rc)
	(technique (name Hidden-Pair) (active yes))

		 (ccell (val ?v1) (box ?b) (id  ?id1))					; if we have a candidate for id1 in a box
		 (ccell (val ?v1) (box ?b) (id  ?id2 & ~?id1))			; and we have the same candidate for another id (id2) in the same box
	(not (ccell (val ?v1) (box ?b) (id ~?id2 & ~?id1)))			; and this candidate doesn't appear anywhere else in this box

		 (ccell (val ?v2 & ~?v1) (id  ?id1))					; and we have the another candidate for id1 in the same box
		 (ccell (val ?v2) 		 (id  ?id2))					; and we have it again in the other id (id2) in the same box
	(not (ccell (val ?v2) 		 (id ~?id2 & ~?id1) (box ?b)))	; and it doesn't appear again in this box

	?f1 <- (ccell (val ~?v1 & ~?v2) (id ?id1 | ?id2))	; get other candidates for the these two ids (id1 and id2)

	=>
	(retract ?f1)
	(assert (tech-used Hidden-Pair))
)

(defrule rc-Hidden-Pair-row
	(declare (salience ?*priority-Hidden-Pair*))

	(rc)
	(technique (name Hidden-Pair) (active yes))

		 (ccell (val ?v1) (row ?r) (id  ?id1))					; if we have a candidate for id in a row
		 (ccell (val ?v1) (row ?r) (id  ?id2 & ~?id1))			; and we have the same candidate for another id (id2) in the same row
	(not (ccell (val ?v1) (row ?r) (id ~?id2 & ~?id1)))			; and this candidate doesn't appear anywhere else in this row

		 (ccell (val ?v2 & ~?v1) (id  ?id1))					; and we have the another candidate for id in the same row
		 (ccell (val ?v2) 		 (id  ?id2))					; and we have it again in the other id (id2) in the same row
	(not (ccell (val ?v2) 		 (id ~?id2 & ~?id1) (row ?r)))	; and it doesn't appear again in this row

	?f1 <- (ccell (val ~?v1 & ~?v2) (id ?id1 | ?id2))	; get other candidates for the these two ids (id and id2)

	=>
	(retract ?f1)
	(assert (tech-used Hidden-Pair))
)

(defrule rc-Hidden-Pair-col
	(declare (salience ?*priority-Hidden-Pair*))

	(rc)
	(technique (name Hidden-Pair) (active yes))

		 (ccell (val ?v1) (col ?c) (id  ?id1))					; if we have a candidate for id in a col
		 (ccell (val ?v1) (col ?c) (id  ?id2 & ~?id1))			; and we have the same candidate for another id (id2) in the same col
	(not (ccell (val ?v1) (col ?c) (id ~?id2 & ~?id1)))			; and this candidate doesn't appear anywhere else in this col

		 (ccell (val ?v2 & ~?v1) (id  ?id))						; and we have the another candidate for id in the same col
		 (ccell (val ?v2) 		 (id  ?id2))					; and we have it again in the other id (id2) in the same col
	(not (ccell (val ?v2) 		 (id ~?id2 & ~?id1) (col ?c)))	; and it doesn't appear again in this col

	?f1 <- (ccell (val ~?v1 & ~?v2) (id ?id1 | ?id2))	; get other candidates for the these two ids (id and id2)

	=>
	(retract ?f1)
	(assert (tech-used Hidden-Pair))
)

;##########################
;# Naked-Triple Technique #
;##########################
; look for three cells in a house whose candidates are no more than 3 and they are similar
; and remove them from all other cells in that house

(defrule rc-Naked-Triple-box
	(declare (salience ?*priority-Naked-Triple*))

	(rc)
	(technique (name Naked-Triple) (active yes))

	; find three different candidates (triple) in the box
	(ccell (box ?b) (val ?v1)           	(id ?id1))
	(ccell (box ?b) (val ?v2 & ~?v1)      	(id ?id2 & ~?id1))
	(ccell (box ?b) (val ?v3 & ~?v1 & ~?v2) (id ?id3 & ~?id1 & ~?id2))

	; make sure that each id dosen't have any other candidate
	(not (ccell (id ?id1 | ?id2 | ?id3) (val ~?v1 & ~?v2 & ~?v3)))

	; get candidates (v1, v2 or v3) in the same box but other cells
	?f1 <- (ccell (box ?b) (val ?v1 | ?v2 | ?v3) (id ~?id1 & ~?id2 & ~?id3))

	=>
	(retract ?f1)
	(assert (tech-used Naked-Triple))
)

(defrule rc-Naked-Triple-row
	(declare (salience ?*priority-Naked-Triple*))

	(rc)
	(technique (name Naked-Triple) (active yes))

	; find three different candidates (triple) in the row
	(ccell (row ?r) (val ?v1)           	(id ?id1))
	(ccell (row ?r) (val ?v2 & ~?v1)      	(id ?id2 & ~?id1))
	(ccell (row ?r) (val ?v3 & ~?v1 & ~?v2) (id ?id3 & ~?id1 & ~?id2))

	; make sure that each id dosen't have any other candidate
	(not (ccell (id ?id1 | ?id2 | ?id3) (val ~?v1 & ~?v2 & ~?v3)))

	; get candidates (v1, v2 or v3) in the same row but other cells
	?f1 <- (ccell (row ?r) (val ?v1 | ?v2 | ?v3) (id ~?id1 & ~?id2 & ~?id3))

	=>
	(retract ?f1)
	(assert (tech-used Naked-Triple))
)

(defrule rc-Naked-Triple-col
	(declare (salience ?*priority-Naked-Triple*))
	(rc)
	(technique (name Naked-Triple) (active yes))

	; find three different candidates (triple) in the column
	(ccell (col ?c) (val ?v1)           	(id ?id1))
	(ccell (col ?c) (val ?v2 & ~?v1)      	(id ?id2 & ~?id1))
	(ccell (col ?c) (val ?v3 & ~?v1 & ~?v2) (id ?id3 & ~?id1 & ~?id2))

	; make sure that each id dosen't have any other candidate
	(not (ccell (id ?id1 | ?id2 | ?id3) (val ~?v1 & ~?v2 & ~?v3)))
	
	; get candidates (v1, v2 or v3) in the same column but other cells
	?f1 <- (ccell (col ?c) (val ?v1 | ?v2 | ?v3) (id ~?id1 & ~?id2 & ~?id3))

	=>
	(retract ?f1)
	(assert (tech-used Naked-Triple))
)

;###########################
;# Hidden-Triple Technique #
;###########################
; look for three candidates in a house that appear only in three cells
; and remove all other candidates from these three cells

(defrule rc-Hidden-Triple-box
	(declare (salience ?*priority-Hidden-Triple*))

	(rc)
	(technique (name Hidden-Triple) (active yes))

	; find three different candidates (triple) in the box
	(ccell (box ?b) (val ?v1)           	(id ?id1))
	(ccell (box ?b) (val ?v2 & ~?v1)      	(id ?id2 & ~?id1))
	(ccell (box ?b) (val ?v3 & ~?v1 & ~?v2) (id ?id3 & ~?id1 & ~?id2))

	; make sure these candidates don't appear anywhere else in the box
	(not (ccell (box ?b) (val ?v1 | ?v2 | ?v3) (id ~?id1 & ~?id2 & ~?id3)))

	; get other candidates for the these three ids
	?f1 <- (ccell (val ~?v1 & ~?v2 & ~?v3) (id ?id1 | ?id2 | ?id3))

	=>
	(retract ?f1)
	(assert (tech-used Hidden-Triple))
)

(defrule rc-Hidden-Triple-row
	(declare (salience ?*priority-Hidden-Triple*))

	(rc)
	(technique (name Hidden-Triple) (active yes))

	; find three different candidates (triple) in the row
	(ccell (row ?r) (val ?v1)           	(id ?id1))
	(ccell (row ?r) (val ?v2 & ~?v1)      	(id ?id2 & ~?id1))
	(ccell (row ?r) (val ?v3 & ~?v1 & ~?v2) (id ?id3 & ~?id1 & ~?id2))

	; make sure these candidates don't appear anywhere else in the row
	(not (ccell (row ?r) (val ?v1 | ?v2 | ?v3) (id ~?id1 & ~?id2 & ~?id3)))

	; get other candidates for the these three ids
	?f1 <- (ccell (val ~?v1 & ~?v2 & ~?v3) (id ?id1 | ?id2 | ?id3))

	=>
	(retract ?f1)
	(assert (tech-used Hidden-Triple))
)

(defrule rc-Hidden-Triple-col
	(declare (salience ?*priority-Hidden-Triple*))

	(rc)
	(technique (name Hidden-Triple) (active yes))

	; find three different candidates (triple) in the column
	(ccell (col ?c) (val ?v1)           	(id ?id1))
	(ccell (col ?c) (val ?v2 & ~?v1)      	(id ?id2 & ~?id1))
	(ccell (col ?c) (val ?v3 & ~?v1 & ~?v2) (id ?id3 & ~?id1 & ~?id2))

	; make sure these candidates don't appear anywhere else in the column
	(not (ccell (col ?c) (val ?v1 | ?v2 | ?v3) (id ~?id1 & ~?id2 & ~?id3)))

	; get other candidates for the these three ids
	?f1 <- (ccell (val ~?v1 & ~?v2 & ~?v3) (id ?id1 | ?id2 | ?id3))

	=>
	(retract ?f1)
	(assert (tech-used Hidden-Triple))
)

;#############################
;# Naked-Quadruple Technique #
;#############################
; look for four cells in a house whose candidates are no more than 4 and they are similar
; and remove them from all other cells in that house

(defrule Naked-Quadruple-box
	(declare (salience ?*priority-Naked-Quadruple*))

	(rc)
	(technique (name Naked-Quadruple) (active yes))

	; find four different candidates (quadruple) in the box
	(ccell (box ?b) (val ?v1)           			(id ?id1))
	(ccell (box ?b) (val ?v2 & ~?v1)      			(id ?id2 & ~?id1))
	(ccell (box ?b) (val ?v3 & ~?v1 & ~?v2) 		(id ?id3 & ~?id1 & ~?id2))
	(ccell (box ?b) (val ?v4 & ~?v1 & ~?v2 & ~?v3) 	(id ?id4 & ~?id1 & ~?id2 & ~?id3))

	; make sure that each id dosen't have any other candidate
	(not (ccell (id ?id1 | ?id2 | ?id3 | ?id4) (val ~?v1 & ~?v2 & ~?v3 & ~?v4)))

	; get candidates (v1, v2, v3 or v4) in the same box but other cells
	?f1 <- (ccell (box ?b) (val ?v1 | ?v2 | ?v3 | ?v4) (id ~?id4 & ~?id3 & ~?id2 & ~?id1))

	=>
	(retract ?f1)
	(assert (tech-used Naked-Quadruple))
)

(defrule Naked-Quadruple-row
	(declare (salience ?*priority-Naked-Quadruple*))
	(rc)
	(technique (name Naked-Quadruple) (active yes))

	; find four different candidates (quadruple) in the row
	(ccell (row ?r) (val ?v1)           			(id ?id1))
	(ccell (row ?r) (val ?v2 & ~?v1)      			(id ?id2 & ~?id1))
	(ccell (row ?r) (val ?v3 & ~?v1 & ~?v2) 		(id ?id3 & ~?id1 & ~?id2))
	(ccell (row ?r) (val ?v4 & ~?v1 & ~?v2 & ~?v3) 	(id ?id4 & ~?id1 & ~?id2 & ~?id3))

	; make sure that each id dosen't have any other candidate
	(not (ccell (id ?id1 | ?id2 | ?id3 | ?id4) (val ~?v1 & ~?v2 & ~?v3 & ~?v4)))

	; get candidates (v1, v2, v3 or v4) in the same row but other cells
	?f1 <- (ccell (row ?r) (val ?v1 | ?v2 | ?v3 | ?v4) (id ~?id4 & ~?id3 & ~?id2 & ~?id1))

	=>
	(retract ?f1)
	(assert (tech-used Naked-Quadruple))
)

(defrule Naked-Quadruple-col
	(declare (salience ?*priority-Naked-Quadruple*))
	(rc)
	(technique (name Naked-Quadruple) (active yes))

	; find four different candidates (quadruple) in the col
	(ccell (col ?c) (val ?v1)           			(id ?id1))
	(ccell (col ?c) (val ?v2 & ~?v1)      			(id ?id2 & ~?id1))
	(ccell (col ?c) (val ?v3 & ~?v1 & ~?v2) 		(id ?id3 & ~?id1 & ~?id2))
	(ccell (col ?c) (val ?v4 & ~?v1 & ~?v2 & ~?v3) 	(id ?id4 & ~?id1 & ~?id2 & ~?id3))

	; make sure that each id dosen't have any other candidate
	(not (ccell (id ?id1 | ?id2 | ?id3 | ?id4) (val ~?v1 & ~?v2 & ~?v3 &~?v4)))

	; get candidates (v1, v2, v3 or v4) in the same column but other cells
	?f1 <- (ccell (col ?c) (val ?v1 | ?v2 | ?v3 | ?v4) (id ~?id4 & ~?id3 & ~?id2 & ~?id1))

	=>
	(retract ?f1)
	(assert (tech-used Naked-Quadruple))
)

;##############################
;# Hidden-Quadruple Technique #
;##############################
; look for four candidates in a house that appear only in four cells
; and remove all other candidates from these four cells

(defrule Hidden-Quadruple-box
	(declare (salience ?*priority-Hidden-Quadruple*))

	(rc)
	(technique (name Hidden-Quadruple) (active yes))

	; find four different candidates (quadruple) in the box
	(ccell (box ?b) (val ?v1)           			(id ?id1))
	(ccell (box ?b) (val ?v2 & ~?v1)      			(id ?id2 & ~?id1))
	(ccell (box ?b) (val ?v3 & ~?v1 & ~?v2) 		(id ?id3 & ~?id1 & ~?id2))
	(ccell (box ?b) (val ?v4 & ~?v1 & ~?v2 & ~?v3) 	(id ?id4 & ~?id1 & ~?id2 & ~?id3))

	; make sure these candidates don't appear anywhere else in the box
	(not (ccell (box ?b) (val ?v1 | ?v2 | ?v3 | ?v4) (id ~?id1 & ~?id2 & ~?id3 & ~?id4)))

	; get other candidates for the these four ids
	?f1 <- (ccell (box ?b) (val ~?v1 & ~?v2 & ~?v3 & ~?v4) (id ?id1 | ?id2 | ?id3 | ?id4))

	=>
	(retract ?f1)
	(assert (tech-used Hidden-Quadruple))
)

(defrule Hidden-Quadruple-row
	(declare (salience ?*priority-Hidden-Quadruple*))

	(rc)
	(technique (name Hidden-Quadruple) (active yes))

	; find four different candidates (quadruple) in the row
	(ccell (row ?r) (val ?v1)           			(id ?id1))
	(ccell (row ?r) (val ?v2 & ~?v1)      			(id ?id2 & ~?id1))
	(ccell (row ?r) (val ?v3 & ~?v1 & ~?v2) 		(id ?id3 & ~?id1 & ~?id2))
	(ccell (row ?r) (val ?v4 & ~?v1 & ~?v2 & ~?v3) 	(id ?id4 & ~?id1 & ~?id2 & ~?id3))

	; make sure these candidates don't appear anywhere else in the row
	(not (ccell (row ?r) (val ?v1 | ?v2 | ?v3 | ?v4) (id ~?id1 & ~?id2 & ~?id3 & ~?id4)))

	; get other candidates for the these four ids
	?f1 <- (ccell (row ?r) (val ~?v1 & ~?v2 & ~?v3 & ~?v4) (id ?id1 | ?id2 | ?id3 | ?id4))

	=>
	(retract ?f1)
	(assert (tech-used Hidden-Quadruple))
)

(defrule Hidden-Quadruple-col
	(declare (salience ?*priority-Hidden-Quadruple*))

	(rc)
	(technique (name Hidden-Quadruple) (active yes))

	; find four different candidates (quadruple) in the col
	(ccell (col ?c) (val ?v1)           			(id ?id1))
	(ccell (col ?c) (val ?v2 & ~?v1)      			(id ?id2 & ~?id1))
	(ccell (col ?c) (val ?v3 & ~?v1 & ~?v2) 		(id ?id3 & ~?id1 & ~?id2))
	(ccell (col ?c) (val ?v4 & ~?v1 & ~?v2 & ~?v3) 	(id ?id4 & ~?id1 & ~?id2 & ~?id3))

	; make sure these candidates don't appear anywhere else in the column
	(not (ccell (col ?c) (val ?v1 | ?v2 | ?v3 | ?v4) (id ~?id1 & ~?id2 & ~?id3 & ~?id4)))

	; get other candidates for the these four ids
	?f1 <- (ccell (col ?c) (val ~?v1 & ~?v2 & ~?v3 & ~?v4) (id ?id1 | ?id2 | ?id3 | ?id4))

	=>
	(retract ?f1)
	(assert (tech-used Hidden-Quadruple))
)

;#########################
;#########################
;# Basic Fish Techniques #
;#########################
;#########################

;####################
;# X-Wing Technique #
;####################
; look for a candidate that appears only twice in two parallel lines
; and there exists other two parallel lines that intersect with previous two and contain the candidate
; remove the candidate from the intersecting parallel pair (but not from the first parallel pair)

(defrule rc-X-Wing-row
	(declare (salience ?*priority-X-Wing*))

	(rc)
	(technique (name X-Wing) (active yes))

		 (ccell (val ?v) (row ?r1) 		  (col  ?c1))			; if we have a candidate in a row (r1) and a column (c1)
		 (ccell (val ?v) (row ?r1) 		  (col  ?c2 & ~?c1))	; and it appears again in the same row (r1) but other column (c2)
	(not (ccell (val ?v) (row ?r1) 		  (col ~?c1 & ~?c2)))	; and it doesn't appear anywhere else in the row (r1)

		 (ccell (val ?v) (row ?r2 & ~?r1) (col  ?c1))			; and it appears again in another row (r2) and the same column (c1)
		 (ccell (val ?v) (row ?r2) 		  (col  ?c2))			; and it appears again in (r2) and the same column (c2)
	(not (ccell (val ?v) (row ?r2) 		  (col ~?c1 & ~?c2)))	; and it doesn't appear anywhere else in the row (r2)

	?f1 <- (ccell (val ?v) (col ?c1 | ?c2) (row ~?r1 & ~?r2))	; get other candidates from the two columns but other rows

	=>
	(retract ?f1)
	(assert (tech-used X-Wing))
)

(defrule rc-X-Wing-col
	(declare (salience ?*priority-X-Wing*))

	(rc)
	(technique (name X-Wing) (active yes))

		 (ccell (val ?v) (col ?c1) 		  (row  ?r1))			; if we have a candidate in a column (c1) and a row (r1)
		 (ccell (val ?v) (col ?c1) 		  (row  ?r2 & ~?r1))	; and it appears again in the same column (c2) but other row (r2)
	(not (ccell (val ?v) (col ?c1) 		  (row ~?r1 & ~?r2)))	; and it doesn't appear anywhere else in the column (c1)

		 (ccell (val ?v) (col ?c2 & ~?c1) (row ?r1))			; and it appears again in another column (c2) and the same row (r1)
		 (ccell (val ?v) (col ?c2) 		  (row ?r2))			; and it appears again in (c2) and the same row (r2)
	(not (ccell (val ?v) (col ?c2) 		  (row ~?r1 & ~?r2)))	; and it doesn't appear anywhere else in the column (c2)

	?f1 <- (ccell (val ?v) (row ?r1 | ?r2) (col ~?c1 & ~?c2))	; get other candidates from the two rows but other columns

	=>
	(retract ?f1)
	(assert (tech-used X-Wing))
)

;#######################
;# Swordfish Technique #
;#######################
; look for a candidate that appears three times or less in three parallel lines
; and there exists other three parallel lines that intersect with previous three and contain the candidate
; remove the candidate from the intersecting parallel triple (but not from the first parallel triple)

(defrule rc-Swordfish-row
	(declare (salience ?*priority-Swordfish*))

	(rc)
	(technique (name Swordfish) (active yes))

	; find three different columns in one row
	(ccell (row ?r) (col ?c1))
	(ccell (row ?r) (col ?c2 & ~?c1))
	(ccell (row ?r) (col ?c3 & ~?c1 & ~?c2))

	; find a candidate that is confined to at least two of them and not any others
		 (ccell (val ?v) (row ?r1) (col  ?c1))
		 (ccell (val ?v) (row ?r1) (col  ?c2))
	(not (ccell (val ?v) (row ?r1) (col ~?c1 & ~?c2 & ~?c3)))

	; second row
		 (ccell (val ?v) (row ?r2 & ~?r1) (col  ?c2))
		 (ccell (val ?v) (row ?r2) 	   	  (col  ?c1 |  ?c3))
	(not (ccell (val ?v) (row ?r2) 		  (col ~?c1 & ~?c2 & ~?c3)))

	; third row
		 (ccell (val ?v) (row ?r3 & ~?r2 & ~?r1) (col  ?c3))
		 (ccell (val ?v) (row ?r3) 				 (col  ?c1 |  ?c2))
	(not (ccell (val ?v) (row ?r3) 				 (col ~?c1 & ~?c2 & ~?c3)))

	; get other candidates from the other three columns but other rows
	?f <- (ccell (val ?v) (row ~?r1 & ~?r2 & ~?r3) (col ?c1 | ?c2 | ?c3))

	=>
	(retract ?f)
	(assert (tech-used Swordfish))
)

(defrule rc-Swordfish-col
	(declare (salience ?*priority-Swordfish*))

	(rc)
	(technique (name Swordfish) (active yes))

	; find three different rows in one column
	(ccell (col ?c) (row ?r1))
	(ccell (col ?c) (row ?r2 & ~?r1))
	(ccell (col ?c) (row ?r3 & ~?r1 & ~?r2))

	; find a candidate that is confined to at least two of them and not any others
		 (ccell (val ?v) (col ?c1) (row  ?r1))
		 (ccell (val ?v) (col ?c1) (row  ?r2))
	(not (ccell (val ?v) (col ?c1) (row ~?r1 & ~?r2 & ~?r3)))

	; second column
		 (ccell (val ?v) (col ?c2 & ~?c1) (row  ?r2))
		 (ccell (val ?v) (col ?c2) 	   	  (row  ?r1 |  ?r3))
	(not (ccell (val ?v) (col ?c2) 		  (row ~?r1 & ~?r2 & ~?r3)))

	; third column
		 (ccell (val ?v) (col ?c3 & ~?c2 & ~?c1) (row  ?r3))
		 (ccell (val ?v) (col ?c3) 				 (row  ?r1 |  ?r2))
	(not (ccell (val ?v) (col ?c3) 				 (row ~?r1 & ~?r2 & ~?r3)))

	; get other candidates from the other three rows but other columns
	?f <- (ccell (val ?v) (col ~?c1 & ~?c2 & ~?c3) (row ?r1 | ?r2 | ?r3))

	=>
	(retract ?f)
	(assert (tech-used Swordfish))
)

;#######################
;# Jellyfish Technique #
;#######################
; look for a candidate that appears four times or less in four parallel lines
; and there exists other four parallel lines that intersect with previous four and contain the candidate
; remove the candidate from the intersecting parallel quadruple (but not from the first parallel quadruple)

(defrule rc-Jellyfish-row
	(declare (salience ?*priority-Jellyfish*))

	(rc)
	(technique (name Jellyfish) (active yes))

	; find four different columns in one row
	(ccell (row ?r) (col ?c1))
	(ccell (row ?r) (col ?c2 & ~?c1))
	(ccell (row ?r) (col ?c3 & ~?c1 & ~?c2))
	(ccell (row ?r) (col ?c4 & ~?c1 & ~?c2 & ~?c3))

	; find a candidate that is confined to at least two of them and not any others
		 (ccell (val ?v) (row ?r1) (col  ?c1))
		 (ccell (val ?v) (row ?r1) (col  ?c2))
	(not (ccell (val ?v) (row ?r1) (col ~?c1 & ~?c2 & ~?c3 & ~?c4)))

	; second row
		 (ccell (val ?v) (row ?r2 & ~?r1) (col  ?c2))
		 (ccell (val ?v) (row ?r2) 	   	  (col  ?c1 |  ?c3 |  ?c4))
	(not (ccell (val ?v) (row ?r2) 		  (col ~?c1 & ~?c2 & ~?c3 & ~?c4)))

	; third row
		 (ccell (val ?v) (row ?r3 & ~?r2 & ~?r1) (col  ?c3))
		 (ccell (val ?v) (row ?r3) 				 (col  ?c1 |  ?c2 |  ?c4))
	(not (ccell (val ?v) (row ?r3) 				 (col ~?c1 & ~?c2 & ~?c3 & ~?c4)))

	; fourth row
		 (ccell (val ?v) (row ?r4 & ~?r3 & ~?r2 & ~?r1) (col  ?c4))
		 (ccell (val ?v) (row ?r4) 				 		(col  ?c1 |  ?c2 |  ?c3))
	(not (ccell (val ?v) (row ?r4) 						(col ~?c1 & ~?c2 & ~?c3 & ~?c4)))

	; get other candidates from the other four columns but other rows
	?f <- (ccell (val ?v) (row ~?r1 & ~?r2 & ~?r3 & ~?r4) (col ?c1 | ?c2 | ?c3 | ?c4))

	=>
	(retract ?f)
	(assert (tech-used Jellyfish))
)

(defrule rc-Jellyfish-col
	(declare (salience ?*priority-Jellyfish*))

	(rc)
	(technique (name Jellyfish) (active yes))

	; find four different rows in one column
	(ccell (col ?c) (row ?r1))
	(ccell (col ?c) (row ?r2 & ~?r1))
	(ccell (col ?c) (row ?r3 & ~?r1 & ~?r2))
	(ccell (col ?c) (row ?r4 & ~?r1 & ~?r2 & ~?r3))

	; find a candidate that is confined to at least two of them and not any others
		 (ccell (val ?v) (col ?c1) (row  ?r1))
		 (ccell (val ?v) (col ?c1) (row  ?r2))
	(not (ccell (val ?v) (col ?c1) (row ~?r1 & ~?r2 & ~?r3 & ~?r4)))

	; second column
		 (ccell (val ?v) (col ?c2 & ~?c1) (row  ?r2))
		 (ccell (val ?v) (col ?c2) 	   	  (row  ?r1 |  ?r3 |  ?r4))
	(not (ccell (val ?v) (col ?c2) 		  (row ~?r1 & ~?r2 & ~?r3 & ~?r4)))

	; third column
		 (ccell (val ?v) (col ?c3 & ~?c2 & ~?c1) (row  ?r3))
		 (ccell (val ?v) (col ?c3) 				 (row  ?r1 |  ?r2 |  ?r4))
	(not (ccell (val ?v) (col ?c3) 				 (row ~?r1 & ~?r2 & ~?r3 & ~?r4)))

	; fourth column
		 (ccell (val ?v) (col ?c4 & ~?c3 & ~?c2 & ~?c1) (row  ?r4))
		 (ccell (val ?v) (col ?c4) 				 		(row  ?r1 |  ?r2 |  ?r3))
	(not (ccell (val ?v) (col ?c4) 						(row ~?r1 & ~?r2 & ~?r3 & ~?r4)))

	; get other candidates from the other four rows but other columns
	?f <- (ccell (val ?v) (col ~?c1 & ~?c2 & ~?c3 & ~?c4) (row ?r1 | ?r2 | ?r3 | ?r4))

	=>
	(retract ?f)
	(assert (tech-used Jellyfish))
)

;####################
;####################
;# Wings Techniques #
;####################
;####################

;#####################
;# XY-Wing Technique #
;#####################
; described in comments

(defrule rc-XY-Wing
	(declare (salience ?*priority-XY-Wing*))

	(rc)
	(technique (name XY-Wing) (active yes))

	; find a cell that has only two candidates left (x,y)
		 (ccell (val  ?x) 		(id ?id1) 				  (box ?b1) (row ?r1) (col ?c1) )
		 (ccell (val  ?y & ~?x) (id ?id1))
	(not (ccell (val ~?x & ~?y) (id ?id1)))

	; find another cell that has only two cadidates left (x,z)
		 (ccell (val  ?x) 		(id ?id2 & ~?id1) 		  (box ?b2) (row ?r2) (col ?c2) )
		 (ccell (val  ?z & ~?x) (id ?id2))
	(not (ccell (val ~?z & ~?x) (id ?id2)))

	; the two cells must be confined to a house
	(test (or 
				(= ?b1 ?b2) 
				(= ?r1 ?r2) 
				(= ?c1 ?c2)
			)
	)

	; find a third cell that has only two candidates left (y,z)
		 (ccell (val  ?y) 		(id ?id3 & ~?id2 & ~?id1) (box ?b3) (row ?r3) (col ?c3) )
		 (ccell (val  ?z & ~?y) (id ?id3))
	(not (ccell (val ~?z & ~?y) (id ?id3)))

	; the second and the first cell must be confied by a house
	(test (or
				(= ?b1 ?b3)
				(= ?r1 ?r3)
				(= ?c1 ?c3)
			)
	)

	; find all other candidates of (z) that can be seen by the second and the third cells together

	?f <- (ccell (val ?z) (box ?b4) (row ?r4) (col ?c4) (id ?id4 & ~?id1 & ~?id2 & ~?id3))
	(test (and
				(or
					(= ?b2 ?b4)
					(= ?r2 ?r4)
					(= ?c2 ?c4)
				)
				(or 
					(= ?b3 ?b4)
					(= ?r3 ?r4)
					(= ?c3 ?c4)
				)
			)
	)

	=>
	(retract ?f)
	(assert (tech-used XY-Wing))
)

;######################
;# XYZ-Wing Technique #
;######################

(defrule rc-XYZ-Wing
	(declare (salience ?*priority-XYZ-Wing*))

	(rc)
	(technique (name XYZ-Wing) (active yes))

	; find a cell that has only three candidates left (x,y,z)
		 (ccell (val  ?x) 			  (id ?id1) 		 (box ?b1) (row ?r1) (col ?c1) )
		 (ccell (val  ?y & ~?x) 	  (id ?id1))
		 (ccell (val  ?z & ~?x & ~?y) (id ?id1))
	(not (ccell (val ~?x & ~?y & ~?z) (id ?id1)))

	; find another cell that has only two cadidates left (x,z)
		 (ccell (val  ?x) 		(id ?id2 & ~?id1) 		 (box ?b2) (row ?r2) (col ?c2) )
		 (ccell (val  ?z) 		(id ?id2))
	(not (ccell (val ~?z & ~?x) (id ?id2)))

	; the two cells must be confined to a house
	(test (or 
				(= ?b1 ?b2) 
				(= ?r1 ?r2) 
				(= ?c1 ?c2)
			)
	)

	; find a third cell that has only two candidates left (y,z)
		 (ccell (val  ?y) 		(id ?id3 & ~?id2 & ~?id1) (box ?b3) (row ?r3) (col ?c3))
		 (ccell (val  ?z) 		(id ?id3))
	(not (ccell (val ~?z & ~?y) (id ?id3)))

	; the second and the third cell must be confied by a house
	(test (or
				(= ?b1 ?b3)
				(= ?r1 ?r3)
				(= ?c1 ?c3)
			)
	)

	; find all other candidates of (z) that can be seen by the all cells

	?f <- (ccell (val ?z) (box ?b4) (row ?r4) (col ?c4) (id ?id4 & ~?id1 & ~?id2 & ~?id3))
	(test (and
				(or
					(= ?b1 ?b4)
					(= ?r1 ?r4)
					(= ?c1 ?c4)
				)
				(or
					(= ?b2 ?b4)
					(= ?r2 ?r4)
					(= ?c2 ?c4)
				)
				(or 
					(= ?b3 ?b4)
					(= ?r3 ?r4)
					(= ?c3 ?c4)
				)
			)
	)

	=>
	(retract ?f)
	(assert (tech-used XYZ-Wing))
)

;####################
;# W-Wing Technique #
;####################
; look for two cells that have only two candidates left
; one of the candidates has only two 
(defrule rc-W-Wing
	(declare (salience ?*priority-W-Wing*))

	(rc)
	(technique (name W-Wing) (active yes))

		 (ccell (val  ?x) 		(id ?id1) 							(box ?b1) (row ?r1) (col ?c1))
		 (ccell (val  ?y & ~?x) (id ?id1))
	(not (ccell (val ~?x & ~?y) (id ?id1)))

		 (ccell (val  ?x) 		(id ?id2 & ~?id1) 					(box ?b2) (row ?r2) (col ?c2))
		 (ccell (val  ?y) 		(id ?id2))
	(not (ccell (val ~?x & ~?y) (id ?id2)))

		 (ccell (val  ?x) 		(id ?id3 & ~?id1 & ~?id2) 			(box ?b3) (row ?r3) (col ?c3) )
		 (ccell (val  ?x) 		(id ?id4 & ~?id1 & ~?id2 & ~?id3) 	(box ?b4) (row ?r4) (col ?c4) )
	(or
		(and
			(test (= ?b3 ?b4))
			(not (ccell (val ?x) (box ?b3) (id ~?id3 & ~?id4)))
		)
		(and
			(test (= ?r3 ?r4))
			(not (ccell (val ?x) (row ?r3) (id ~?id3 & ~?id4)))
		)
		(and
			(test (= ?c3 ?c4))
			(not (ccell (val ?x) (col ?c3) (id ~?id3 & ~?id4)))
		)
	)

	(test (and
			(or
				(= ?b1 ?b3)
				(= ?r1 ?r3)
				(= ?c1 ?c3)
			)
			(or
				(= ?b2 ?b4)
				(= ?r2 ?r4)
				(= ?c2 ?c4)
			)
	))

	?f <- (ccell (val ?y) (box ?b) (row ?r) (col ?c) (id ~?id1 & ~?id2))
	(test (and
			(or
				(= ?r ?r1)
				(= ?c ?c1)
				(= ?b ?b1)
			)
			(or
				(= ?r ?r2)
				(= ?c ?c2)
				(= ?b ?b2)
			)
	))

	=>
	(retract ?f)
	(assert (tech-used W-Wing))
)

;#########################
;#########################
;# Uniqueness Techniques #
;#########################
;#########################

;################################
;# Unique-Rectangle-1 Technique #
;################################
; look for four cells that has only two candidates left except for one of them
; and they form a rectangle
; remove the two candidates from the cell that has others

(defrule Unique-Rectangle-1-row
	(declare (salience ?*priority-Unique-Rectangle-1*))

	(rc)
	(technique (name Unique-Rectangle-1) (active yes))

	; find a possible UR
			(ccell (id ?id1) (val ?x) 			(box ?b1) 		 (row ?r1) 			(col ?c1) )
			(ccell (id ?id1) (val ?y & ~?x) )

			(ccell (id ?id2) (val ?x) 			(box ?b1) 		 (row ?r1) 			(col ?c2 & ~?c1) )
			(ccell (id ?id2) (val ?y) )
			
			(ccell (id ?id3) (val ?x) 			(box ?b2 & ~?b1) (row ?r2 & ~?r1) 	(col ?c1) )
			(ccell (id ?id3) (val ?y) )

	?f1 <- 	(ccell (id ?id4) (val ?x) 			(box ?b2) 		 (row ?r2) 			(col ?c2) )
	?f2 <- 	(ccell (id ?id4) (val ?y) )

	; make sure three of the cells don't have candidates other than x and y
	(not (ccell (id ?id1 | ?id2 | ?id3) (val ~?x & ~?y) ))

	; and the 4th one has at least one extra value
	(ccell (id ?id4) (val ~?x & ~?y) )

	=>
	(retract ?f1 ?f2)
	(assert (tech-used Unique-Rectangle-1))
)

(defrule Unique-Rectangle-1-col
	(declare (salience ?*priority-Unique-Rectangle-1*))

	(rc)
	(technique (name Unique-Rectangle-1) (active yes))

	; find a possible UR
			(ccell (id ?id1) (val ?x) 			(box ?b1) 		 (row ?r1) 			(col ?c1) )
			(ccell (id ?id1) (val ?y & ~?x) )

			(ccell (id ?id2) (val ?x) 			(box ?b1) 		 (row ?r2 & ~?r1) 	(col ?c1) )
			(ccell (id ?id2) (val ?y) )
			
			(ccell (id ?id3) (val ?x) 			(box ?b2 & ~?b1) (row ?r1) 			(col ?c2 & ~?c1) )
			(ccell (id ?id3) (val ?y) )

	?f1 <- 	(ccell (id ?id4) (val ?x) 			(box ?b2) 		 (row ?r2) 			(col ?c2) )
	?f2 <- 	(ccell (id ?id4) (val ?y) )

	; make sure three of the cells don't have candidates other than x and y
	(not (ccell (id ?id1 | ?id2 | ?id3) (val ~?x & ~?y) ))

	; and the 4th one has at least one extra value
	(ccell (id ?id4) (val ~?x & ~?y) )
	
	=>
	(retract ?f1 ?f2)
	(assert (tech-used Unique-Rectangle-1))
)

;################################
;# Unique-Rectangle-2 Technique #
;################################

(defrule Unique-Rectangle-2-row-one-box
	(declare (salience ?*priority-Unique-Rectangle-2*))

	(rc)
	(technique (name Unique-Rectangle-2) (active yes))

	; find a possible UR
	(ccell (id ?id1) (val ?x) 			(box ?b1) 			(row ?r1) 			(col ?c1) )
	(ccell (id ?id1) (val ?y & ~?x) )

	(ccell (id ?id2) (val ?x) 			(box ?b1) 			(row ?r1) 			(col ?c2 & ~?c1) )
	(ccell (id ?id2) (val ?y) )
	
	(ccell (id ?id3) (val ?x) 			(box ?b2 & ~?b1) 	(row ?r2 & ~?r1) 	(col ?c1) )
	(ccell (id ?id3) (val ?y) )

	(ccell (id ?id4) (val ?x) 			(box ?b2) 			(row ?r2) 			(col ?c2) )
	(ccell (id ?id4) (val ?y) )

	; 
			(ccell (id ?id1) 	     (val  ?z & ~?x & ~?y) )
			(ccell (id ?id2) 	     (val  ?z) )
	(not 	(ccell (id ?id1 | ?id2)  (val ~?x & ~?y & ~?z) ))
	(not 	(ccell (id ?id3 | ?id4)  (val ~?x & ~?y)))

	?f <- 	(ccell (val ?z) (box ?bx) (row ?rx) (id ~?id1 & ~?id2))
	(test (or
			(= ?bx ?b1)
			(= ?rx ?r1)
		)
	)

	=>
	(retract ?f)
	(assert (tech-used Unique-Rectangle-2))
)

(defrule Unique-Rectangle-2-row-two-boxes
	(declare (salience ?*priority-Unique-Rectangle-2*))

	(rc)
	(technique (name Unique-Rectangle-2) (active yes))

	; find a possible UR
	(ccell (id ?id1) (val ?x) 				(box ?b1) 			(row ?r1) 			(col ?c1) )
	(ccell (id ?id1) (val ?y & ~?x) )

	(ccell (id ?id2) (val ?x) 				(box ?b1) 			(row ?r1) 			(col ?c2 & ~?c1) )
	(ccell (id ?id2) (val ?y) )
	
	(ccell (id ?id3) (val ?x) 				(box ?b2 & ~?b1) 	(row ?r2 & ~?r1) 	(col ?c1) )
	(ccell (id ?id3) (val ?y) )

	(ccell (id ?id4) (val ?x) 				(box ?b2) 			(row ?r2) 			(col ?c2) )
	(ccell (id ?id4) (val ?y) )

	; 
			(ccell (id ?id1) 	     (val  ?z & ~?x & ~?y) )
			(ccell (id ?id3) 	   	 (val  ?z) )
	(not 	(ccell (id ?id1 | ?id3)  (val ~?x & ~?y & ~?z) ))
	(not 	(ccell (id ?id2 | ?id4)  (val ~?x & ~?y)))

	?f <- 	(ccell (val ?z) (col ?c1) (id ~?id1 & ~?id3))

	=>
	(retract ?f)
	(assert (tech-used Unique-Rectangle-2))
)

(defrule Unique-Rectangle-2-col-one-box
	(declare (salience ?*priority-Unique-Rectangle-2*))

	(rc)
	(technique (name Unique-Rectangle-2) (active yes))

	; find a possible UR
	(ccell (id ?id1) (val ?x) 				(box ?b1) 			(row ?r1) 			(col ?c1) )
	(ccell (id ?id1) (val ?y&~?x) )

	(ccell (id ?id2) (val ?x) 				(box ?b1) 			(row ?r2 & ~?r1)	(col ?c1) )
	(ccell (id ?id2) (val ?y) )
	
	(ccell (id ?id3) (val ?x) 				(box ?b2 & ~?b1) 	(row ?r1) 			(col ?c2 & ~?c1) )
	(ccell (id ?id3) (val ?y) )

	(ccell (id ?id4) (val ?x) 				(box ?b2) 			(row ?r2) 			(col ?c2) )
	(ccell (id ?id4) (val ?y) )

	; 
			(ccell (id ?id1) 	   	 (val  ?z & ~?x & ~?y) )
			(ccell (id ?id2) 	     (val  ?z) )
	(not 	(ccell (id ?id1 | ?id2)  (val ~?x & ~?y & ~?z) ))
	(not 	(ccell (id ?id3 | ?id4)  (val ~?x & ~?y)))

	?f <- 	(ccell (val ?z) (box ?bx) (col ?cx) (id ~?id1 & ~?id2))
	(test (or
			(= ?bx ?b1)
			(= ?cx ?c1)
		)
	)

	=>
	(retract ?f)
	(assert (tech-used Unique-Rectangle-2))
)

(defrule Unique-Rectangle-2-col-two-boxes
	(declare (salience ?*priority-Unique-Rectangle-2*))

	(rc)
	(technique (name Unique-Rectangle-2) (active yes))

	; find a possible UR
	(ccell (id ?id1) (val ?x) 				(box ?b1) 			(row ?r1) 			(col ?c1) )
	(ccell (id ?id1) (val ?y&~?x) )

	(ccell (id ?id2) (val ?x) 				(box ?b1) 			(row ?r2 & ~?r1)	(col ?c1) )
	(ccell (id ?id2) (val ?y) )
	
	(ccell (id ?id3) (val ?x) 				(box ?b2 & ~?b1) 	(row ?r1) 			(col ?c2 & ~?c1) )
	(ccell (id ?id3) (val ?y) )

	(ccell (id ?id4) (val ?x) 				(box ?b2) 			(row ?r2) 			(col ?c2) )
	(ccell (id ?id4) (val ?y) )

	; 
			(ccell (id ?id1) 	   (val  ?z & ~?x & ~?y) )
			(ccell (id ?id3) 	   (val  ?z) )
	(not 	(ccell (id ?id1|?id3)  (val ~?x & ~?y & ~?z) ))
	(not 	(ccell (id ?id2|?id4)  (val ~?x & ~?y)))

	?f <- 	(ccell (val ?z) (row ?r1) (id ~?id1 & ~?id3))

	=>
	(retract ?f)
	(assert (tech-used Unique-Rectangle-2))
)

;################################
;# Unique-Rectangle-4 Technique #
;################################

(defrule Unique-Rectangle-4-row-one-box
	(declare (salience ?*priority-Unique-Rectangle-4*))

	(rc)
	(technique (name Unique-Rectangle-4) (active yes))

	; find a possible UR
	?f1 <-  (ccell (id ?id1) (val ?x) 					(box ?b1) 			(row ?r1) 			(col ?c1) )
			(ccell (id ?id1) (val ?y & ~?x) )

	?f2 <-	(ccell (id ?id2) (val ?x) 					(box ?b1) 			(row ?r1) 			(col ?c2 & ~?c1) )
			(ccell (id ?id2) (val ?y) )
	
			(ccell (id ?id3) (val ?x) 					(box ?b2 & ~?b1) 	(row ?r2 & ~?r1) 	(col ?c1) )
			(ccell (id ?id3) (val ?y) )

			(ccell (id ?id4) (val ?x) 					(box ?b2) 			(row ?r2) 			(col ?c2) )
			(ccell (id ?id4) (val ?y) )

	; 
			(ccell (id ?id1) 	     (val ~?x & ~?y) )
			(ccell (id ?id2) 	     (val ~?x & ~?y) )
	(not 	(ccell (id ?id3 | ?id4)  (val ~?x & ~?y)))
	(or
		(not (ccell (val ?y) (box ?b1)   (id ~?id1 & ~?id2)))
		(not (ccell (val ?y) (row ?r1)   (id ~?id1 & ~?id2)))
	)

	=>
	(retract ?f1 ?f2)
	(assert (tech-used Unique-Rectangle-4))
)

(defrule Unique-Rectangle-4-row-two-boxes
	(declare (salience ?*priority-Unique-Rectangle-4*))

	(rc)
	(technique (name Unique-Rectangle-4) (active yes))

	; find a possible UR
	?f1 <- 	(ccell (id ?id1) (val ?x) 					(box ?b1) 			(row ?r1) 			(col ?c1) )
			(ccell (id ?id1) (val ?y & ~?x) )

			(ccell (id ?id2) (val ?x) 					(box ?b1) 			(row ?r1) 			(col ?c2 & ~?c1) )
			(ccell (id ?id2) (val ?y) )
			
	?f2 <- 	(ccell (id ?id3) (val ?x) 					(box ?b2 & ~?b1) 	(row ?r2 & ~?r1) 	(col ?c1) )
			(ccell (id ?id3) (val ?y) )

			(ccell (id ?id4) (val ?x) 					(box ?b2) 			(row ?r2) 			(col ?c2) )
			(ccell (id ?id4) (val ?y) )

	; 
			(ccell (id ?id1) 	   (val ~?x & ~?y) )
			(ccell (id ?id3) 	   (val ~?x & ~?y) )
	(not 	(ccell (id ?id2|?id4)  (val ~?x & ~?y)))
	
	(not (ccell (val ?y) (col ?c1) (id ~?id1 & ~?id3)))

	=>
	(retract ?f1 ?f2)
	(assert (tech-used Unique-Rectangle-4))
)

(defrule Unique-Rectangle-4-col-one-box
	(declare (salience ?*priority-Unique-Rectangle-4*))

	(rc)
	(technique (name Unique-Rectangle-4) (active yes))

	; find a possible UR
	?f1 <-  (ccell (id ?id1) (val ?x) 					(box ?b1) 			(row ?r1) 			(col ?c1) )
			(ccell (id ?id1) (val ?y & ~?x) )

	?f2 <-	(ccell (id ?id2) (val ?x) 					(box ?b1) 			(row ?r2 & ~?r1)	(col ?c1) )
			(ccell (id ?id2) (val ?y) )
	
			(ccell (id ?id3) (val ?x) 					(box ?b2 & ~?b1) 	(row ?r1) 			(col ?c2 & ~?c1) )
			(ccell (id ?id3) (val ?y) )

			(ccell (id ?id4) (val ?x) 					(box ?b2) 			(row ?r2) 			(col ?c2) )
			(ccell (id ?id4) (val ?y) )

	; 
			(ccell (id ?id1) 	   (val ~?x & ~?y) )
			(ccell (id ?id2) 	   (val ~?x & ~?y) )
	(not 	(ccell (id ?id3|?id4)  (val ~?x & ~?y)))
	(or
		(not (ccell (val ?y) (box ?b1)   (id ~?id1 & ~?id2)))
		(not (ccell (val ?y) (col ?c1)   (id ~?id1 & ~?id2)))
	)

	=>
	(retract ?f1 ?f2)
	(assert (tech-used Unique-Rectangle-4))
)

(defrule Unique-Rectangle-4-col-two-boxes
	(declare (salience ?*priority-Unique-Rectangle-4*))

	(rc)
	(technique (name Unique-Rectangle-4) (active yes))

	; find a possible UR
	?f1 <-  (ccell (id ?id1) (val ?x)					(box ?b1) 			(row ?r1) 			(col ?c1) )
			(ccell (id ?id1) (val ?y & ~?x) )

			(ccell (id ?id2) (val ?x) 					(box ?b1) 			(row ?r2 & ~?r1)	(col ?c1) )
			(ccell (id ?id2) (val ?y) )
	
	?f2 <-	(ccell (id ?id3) (val ?x) 					(box ?b2 & ~?b1) 	(row ?r1) 			(col ?c2 & ~?c1) )
			(ccell (id ?id3) (val ?y) )

			(ccell (id ?id4) (val ?x) 					(box ?b2) 			(row ?r2) 			(col ?c2) )
			(ccell (id ?id4) (val ?y) )

	; 
			(ccell (id ?id1) 	   (val ~?x & ~?y) )
			(ccell (id ?id3) 	   (val ~?x & ~?y) )
	(not 	(ccell (id ?id2|?id4)  (val ~?x & ~?y)))
	
	(not (ccell (val ?y) (row ?r1) (id ~?id1 & ~?id3)))

	=>
	(retract ?f1 ?f2)
	(assert (tech-used Unique-Rectangle-4))
)

;################################
;# Unique-Rectangle-5 Technique #
;################################

(defrule Unique-Rectangle-5-row-two
	(declare (salience ?*priority-Unique-Rectangle-5*))

	(rc)
	(technique (name Unique-Rectangle-5) (active yes))

	; find a possible UR
	(ccell (id ?id1) (val ?x) 					(box ?b1) 			(row ?r1) 			(col ?c1) )
	(ccell (id ?id1) (val ?y & ~?x) )

	(ccell (id ?id2) (val ?x)					(box ?b1) 			(row ?r1)			(col ?c2 & ~?c1) )
	(ccell (id ?id2) (val ?y) )
		
	(ccell (id ?id3) (val ?x) 					(box ?b2 & ~?b1) 	(row ?r2 & ~?r1)	(col ?c1) )
	(ccell (id ?id3) (val ?y) )

	(ccell (id ?id4) (val ?x) 					(box ?b2) 			(row ?r2) 			(col ?c2) )
	(ccell (id ?id4) (val ?y) )

	;
		 (ccell (id ?id1) 		 (val  ?z & ~?x & ~?y))
		 (ccell (id ?id4) 		 (val  ?z))

	(not (ccell (id ?id1 | ?id4) (val ~?x & ~?y & ~?z)))
	(not (ccell (id ?id2 | ?id3) (val ~?x & ~?y)))

	?f <- (ccell (val ?z) (box ?bx) (col ?cx) (id ~?id1 & ~?id4))
	(test (or
			(and
				(= ?bx ?b1)
				(= ?cx ?c2)
			)
			(and
				(= ?bx ?b2)
				(= ?cx ?c1)
			)
		)
	)

	=>
	(retract ?f)
	(assert (tech-used Unique-Rectangle-5))
)

(defrule Unique-Rectangle-5-row-three
	(declare (salience ?*priority-Unique-Rectangle-5*))

	(rc)
	(technique (name Unique-Rectangle-5) (active yes))

	; find a possible UR
	(ccell (id ?id1) (val ?x) 					(box ?b1) 			(row ?r1) 			(col ?c1) )
	(ccell (id ?id1) (val ?y & ~?x) )

	(ccell (id ?id2) (val ?x) 					(box ?b1) 			(row ?r1)			(col ?c2 & ~?c1) )
	(ccell (id ?id2) (val ?y) )
		
	(ccell (id ?id3) (val ?x) 					(box ?b2 & ~?b1) 	(row ?r2 & ~?r1)	(col ?c1) )
	(ccell (id ?id3) (val ?y) )

	(ccell (id ?id4) (val ?x) 					(box ?b2) 			(row ?r2) 			(col ?c2) )
	(ccell (id ?id4) (val ?y) )

	;
	(not (ccell (id ?id1) 			 	 (val       ~?x & ~?y)))
		 (ccell (id ?id2) 			 	 (val  ?z & ~?x & ~?y))
		 (ccell (id ?id3) 			 	 (val  ?z))
		 (ccell (id ?id4) 			 	 (val  ?z))
	(not (ccell (id ?id2 | ?id3 | ?id4)  (val ~?x & ~?y & ~?z)))

	?f <- (ccell (val ?z) (box ?b2) (col ?c2) (id ~?id2 & ~?id3 & ~?id4))

	=>
	(retract ?f)
	(assert (tech-used Unique-Rectangle-5))
)

(defrule Unique-Rectangle-5-col-two
	(declare (salience ?*priority-Unique-Rectangle-5*))

	(rc)
	(technique (name Unique-Rectangle-5) (active yes))

	; find a possible UR
	(ccell (id ?id1) (val ?x) 					(box ?b1) 			(row ?r1) 			(col ?c1) )
	(ccell (id ?id1) (val ?y & ~?x) )

	(ccell (id ?id2) (val ?x) 					(box ?b1) 			(row ?r2 & ~?r1)	(col ?c1) )
	(ccell (id ?id2) (val ?y) )
		
	(ccell (id ?id3) (val ?x) 					(box ?b2 & ~?b1) 	(row ?r1)			(col ?c2 & ~?c1) )
	(ccell (id ?id3) (val ?y) )

	(ccell (id ?id4) (val ?x) 					(box ?b2) 			(row ?r2) 			(col ?c2) )
	(ccell (id ?id4) (val ?y) )

	;
		 (ccell (id ?id1) 		 (val  ?z & ~?x & ~?y))
		 (ccell (id ?id4) 		 (val  ?z))

	(not (ccell (id ?id1 | ?id4) (val ~?x & ~?y & ~?z)))
	(not (ccell (id ?id2 | ?id3) (val ~?x & ~?y)))

	?f <- (ccell (val ?z) (box ?bx) (row ?rx) (id ~?id1 & ~?id4))
	(test (or
			(and
				(= ?bx ?b1)
				(= ?rx ?r2)
			)
			(and
				(= ?bx ?b2)
				(= ?rx ?r1)
			)
		)
	)

	=>
	(retract ?f)
	(assert (tech-used Unique-Rectangle-5))
)

(defrule Unique-Rectangle-5-col-three
	(declare (salience ?*priority-Unique-Rectangle-5*))

	(rc)
	(technique (name Unique-Rectangle-5) (active yes))

	; find a possible UR
	(ccell (id ?id1) (val ?x) 					(box ?b1) 			(row ?r1) 			(col ?c1) )
	(ccell (id ?id1) (val ?y & ~?x) )

	(ccell (id ?id2) (val ?x) 					(box ?b1) 			(row ?r2 & ~?r1)	(col ?c1) )
	(ccell (id ?id2) (val ?y) )
		
	(ccell (id ?id3) (val ?x) 					(box ?b2 & ~?b1) 	(row ?r1)			(col ?c2 & ~?c1) )
	(ccell (id ?id3) (val ?y) )

	(ccell (id ?id4) (val ?x) 					(box ?b2) 			(row ?r2) 			(col ?c2) )
	(ccell (id ?id4) (val ?y) )

	;
	(not (ccell (id ?id1) 			 (val       ~?x & ~?y)))
		 (ccell (id ?id2) 			 (val  ?z & ~?x & ~?y))
		 (ccell (id ?id3) 			 (val  ?z))
		 (ccell (id ?id4) 			 (val  ?z))
	(not (ccell (id ?id2|?id3|?id4)  (val ~?x & ~?y & ~?z)))

	?f <- (ccell (val ?z) (box ?b2) (row ?r2) (id ~?id2 & ~?id3 & ~?id4))

	=>
	(retract ?f)
	(assert (tech-used Unique-Rectangle-5))
)

;################################
;# Unique-Rectangle-6 Technique #
;################################

(defrule Unique-Rectangle-6-row
	(declare (salience ?*priority-Unique-Rectangle-6*))

	(rc)
	(technique (name Unique-Rectangle-6) (active yes))

	; find a possible UR
	?f1 <-  (ccell (id ?id1) (val ?x) 					(box ?b1) 			(row ?r1) 			(col ?c1) )
			(ccell (id ?id1) (val ?y & ~?x) )

			(ccell (id ?id2) (val ?x) 					(box ?b1) 			(row ?r1)			(col ?c2 & ~?c1) )
			(ccell (id ?id2) (val ?y) )
				
			(ccell (id ?id3) (val ?x) 					(box ?b2 & ~?b1) 	(row ?r2 & ~?r1)	(col ?c1) )
			(ccell (id ?id3) (val ?y) )

	?f2 <- 	(ccell (id ?id4) (val ?x) 					(box ?b2) 			(row ?r2) 			(col ?c2) )
			(ccell (id ?id4) (val ?y) )

	;
		 (ccell (id ?id1) 			(val ~?x & ~?y))
		 (ccell (id ?id4) 			(val ~?x & ~?y))

	(not (ccell (id ?id2 | ?id3) 	(val ~?x & ~?y)))

	(not (ccell (val ?x) (row ?r1 | ?r2) (col ~?c1 & ~?c2)))
	(not (ccell (val ?x) (col ?c1 | ?c2) (row ~?r1 & ~?r2)))

	=>
	(retract ?f1 ?f2)
	(assert (tech-used Unique-Rectangle-6))
)

(defrule Unique-Rectangle-6-col
	(declare (salience ?*priority-Unique-Rectangle-6*))

	(rc)
	(technique (name Unique-Rectangle-6) (active yes))

	; find a possible UR
	?f1 <-  (ccell (id ?id1) (val ?x) 					(box ?b1) 			(row ?r1) 			(col ?c1) )
			(ccell (id ?id1) (val ?y & ~?x) )

			(ccell (id ?id2) (val ?x) 					(box ?b1) 			(row ?r2 & ~?r1)	(col ?c1) )
			(ccell (id ?id2) (val ?y) )
				
			(ccell (id ?id3) (val ?x) 					(box ?b2 & ~?b1) 	(row ?r1)			(col ?c2 & ~?c1) )
			(ccell (id ?id3) (val ?y) )

	?f2 <- 	(ccell (id ?id4) (val ?x) 					(box ?b2) 			(row ?r2) 			(col ?c2) )
			(ccell (id ?id4) (val ?y) )

	;
	(ccell (id ?id1) (val  ~?x & ~?y))
	(ccell (id ?id4) (val  ~?x & ~?y))

	(not (ccell (id ?id2 | ?id3) 	(val ~?x & ~?y)))

	(not (ccell (val ?x) (row ?r1 | ?r2) (col ~?c1 & ~?c2)))
	(not (ccell (val ?x) (col ?c1 | ?c2) (row ~?r1 & ~?r2)))

	=>
	(retract ?f1 ?f2)
	(assert (tech-used Unique-Rectangle-6))
)

;###############
;# cleaning up #
;###############

(defrule done-solve-remove-unused-techniques
	(declare (salience -200))

	(not (debug))
	?f <- (technique (used no))
	=>
	(retract ?f)
)

(defrule done-solve-remove-subphases
	(declare (salience -200))
	?f <- (rc)
	=>
	(retract ?f)
)

(defrule done-solve-remove-dangling-flag
	(declare (salience -200))
	?f <- (activate-reverse)
	=>
	(retract ?f)
)
