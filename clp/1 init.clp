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


(deftemplate cell
	(slot val)
	(slot row)
	(slot col)
	(slot id)
	(slot box)
)

(deftemplate ccell "candidate cell"
	(slot val)
	(slot row)
	(slot col)
	(slot id)
	(slot box)
)

(deftemplate invalid "used when checking the puzzle"
	(multislot why)
)

(deftemplate technique
	(slot name)
	(slot priority)
	(slot active
		(allowed-symbols yes no)
	)
	(slot used
		(allowed-symbols yes no)
	)
)

(deftemplate scell "short cell (intended for simple assertion)"
	(slot val)
	(slot row)
	(slot col)
)

(deffunction get-box
	(?row ?col)
	(+ (* (integer (/ ?row 3)) 3) (integer (/ ?col 3)))
)

;(deffunction get-box-silly
;	(?row ?col)
;	(if (<= ?row 3)
;		then
;		(if (<= ?col 3)
;			then
;			1
;			else
;			(if (<= ?col 6)
;				then
;				2
;				else
;				3
;			)
;		)
;		else
;		(if (<= ?row 6)
;			then
;			(if (<= ?col 3)
;				then
;				4
;				else
;				(if (<= ?col 6)
;					then
;					5
;					else
;					6
;				)
;			)
;			else
;			(if (<= ?col 3)
;				then
;				7
;				else
;				(if (<= ?col 6)
;					then
;					8
;					else
;					9
;				)
;			)
;		)
;	)
;)
