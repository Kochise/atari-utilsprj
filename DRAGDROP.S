; /// Test d'entr‚e Drag'n Drop ///

	comment	HEAD=7

	SECTION	TEXT

	move.l	4(SP),A6	; Adresse de la BASEPAGE
	lea	$80(A6),A6		; Adresse de la COMMAND-TAIL
	move.b	(A6)+,D0		; Taille de la COMMAND-TAIL (ATTENTION : Format PASCAL)
	
	BEQ	Exit

	lea	File,A5

CopyFile	move.b	(A6)+,(A5)+
	
	BNE	CopyFile

 	move.w	#$19,-(SP)
 	trap	#1
 	addq.l	#2,SP
 	
 	add.w	#65,D0
 	
 	lea	Path,A5
 	move.b	D0,(A5)+
 	move.b	#":",(A5)+
 	
 	clr.w	-(SP)
 	move.l	A5,-(SP)
 	move.w	#$47,-(SP)
 	trap	#1
 	addq.l	#8,SP

	pea	File_Txt
	move.w	#9,-(SP)
	trap	#1
	addq.l	#6,SP

	pea	Path_Txt
	move.w	#9,-(SP)
	trap	#1
	addq.l	#6,SP
	
	move.w	#7,-(SP)
	trap	#1
	addq.l	#2,SP
	
Exit	clr.w	-(SP)
	trap	#1
	
	SECTION	DATA
	
File_Txt	dc.b	27,"E"," File : "
File	ds.b	256
Path_Txt	dc.b	13,10," Path : "
Path	ds.b	256


