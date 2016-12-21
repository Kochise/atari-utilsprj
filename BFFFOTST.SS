; ///  - KOSS 1999 ///

; WARNING : START  A7.l = 2
; BUG       OPCODE      move.B Dx,-(SP)
; REPORT    END    A7.l = 0, and NOT 1

	comment	HEAD=7
	
	SECTION	TEXT

	BFFFO 	NbBitsPerColor{11:5},D0	; Look for the Greatest Color Bit
	BEQ	NoBitsPerColor	; Hey, are U silly, 0 Bit per Color ?
	move.l	#15,D1	; NbOfBitsPerRegisters
	sub.l	D0,D1
	moveq.w	#1,D0	; Just 1 Bit, for sure NOW...
	lsl.l	D1,D0	; Put it on the right upper place found
	move.w	D0,NbBitsPerColor	; OK, that's it !

NoBitsPerColor	clr.w	-(SP)
	trap	#1	; *** GEMDOS ***

	SECTION	DATA
	
NbBitsPerColor	dc.w	%1010
	
	SECTION	BSS