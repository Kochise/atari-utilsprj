; ///  - KOSS 1999 ///

; WARNING : START  A7.l = 2
; BUG       OPCODE      move.B Dx,-(SP)
; REPORT    END    A7.l = 0, and NOT 1

	comment	HEAD=7
	
	SECTION	TEXT
	
	movea.l	(4,SP),A6	; Adresse de la BASEPAGE
	move.l	($C,A6),D0	; Taille du SEGMENT TEXT
	add.l	($14,A6),D0	; Additionne la taille du SEGMENT DATA … D0
	add.l	($1C,A6),D0	; Additionne la taille du SEGMENT BSS … D0
	addi.l	#$100,D0	; Additionne la taille de la BASEPAGE … D0
	addi.l	#$400,D0	; Additionne la taille de la future PILE (Ici, 256 positions longues (1024 OCTETS))
	move.l	D0,D1	; Copie D0 dans D1 (Taille … r‚server)
	move.l	D0,D7
	add.l	A6,D1	; Additionne l'adresse du d‚but du programme avec D1 (La taille … r‚server)
	andi.l	#-2,D1	; Rend D1 pair (Au cas o— il ne l'‚tait pas)
	subq.l	#8,D1	; Garde de la place pour l'adresse de la BASEPAGE
	move.l	(4,SP),D2	; Sauvegarde l'adresse de la BASEPAGE
	movea.l	D1,SP	; Installe l'adresse de fin du programme+place nouvelle PILE dans la PILE
	move.l	D2,(4,SP)	; R‚installe l'adresse de la BASEPAGE
	move.l	D0,-(SP)	; EmPILE la taille … r‚server
	move.l	A6,-(SP)	; EmPILE l'adresse du programme
	clr.w	-(SP)	; R‚serv‚
	move.w	#$4A,-(SP)	; - M_SHRINK -
	trap	#1	; *** GEMDOS ***
	lea	(12,SP),SP

	; D5 == Adresse
	; D6 == Taille
	; D7 == Handle

	clr.w	-(SP)
	pea	DataName
	move.w	#$3D,-(SP)	; - F_OPEN -
	trap	#1	; *** GEMDOS ***
	addq.l	#8,SP

	move.w	D0,D7	; Handle
	
	move.w	#2,-(SP)	; Fin
	move.w	D0,-(SP)
	clr.l	-(SP)	; Fin du fichier
	move.w	#$42,-(SP)	; - F_SEEK -
	trap	#1	; *** GEMDOS ***
	lea	10(SP),SP
	
	move.l	D0,D6	; Taille

	clr.w	-(SP)	; D‚but
	move.w	D7,-(SP)
	clr.l	-(SP)	; D‚but du fichier
	move.w	#$42,-(SP)	; - F_SEEK -
	trap	#1	; *** GEMDOS ***
	lea	10(SP),SP

	move.w	#3,-(SP)	; TT-RAM Prefered
	move.l	D6,-(SP)	; Taille du fichier
	move.w	#$44,-(SP)	; - M_XALLOC -
	trap	#1	; *** GEMDOS ***
	addq.l	#8,SP
	tst.l	D0
	
	BEQ	Close_File
	
	move.l	D0,DataData
	move.l	D0,D5
	
	move.l	D5,-(SP)	; Adresse du fichier
	move.l	D6,-(SP)	; Taille du fichier
	move.w	D7,-(SP)	; Handle
	move.w	#$3F,-(SP)	; - F_READ -
	trap	#1	; *** GEMDOS ***
	lea	12(SP),SP
	
Close_File	move.w	D7,-(SP)
	move.w	#$3E,-(SP)	; - F_CLOSE -
	trap	#1	; *** GEMDOS ***
	addq.l	#4,SP

; ---
	; D5 == Adresse
	; D6 == Taille
	; D7 == Handle

	clr.w	-(SP)
	pea	TestName
	move.w	#$3C,-(SP)	; - F_CREATE -
	trap	#1	; *** GEMDOS ***
	addq.l	#8,SP
	
	move.w	D0,D7
	
	move.l	D5,D0
	add.l	D6,D0
	subq.l	#4,D0
	movea.l	D0,A0
	move.l	(A0),D1	; Taille
	sub.l	D1,D0	; D‚but
	
	move.l	D0,-(SP)
	move.l	D1,-(SP)
	move.w	D7,-(SP)
	move.w	#$40,-(SP)	; - F_WRITE -
	trap	#1	; *** GEMDOS ***
	lea	(12,SP),SP
	
	move.w	D7,-(SP)
	move.w	#$3E,-(SP)	; - F_CLOSE -
	trap	#1	; *** GEMDOS ***
	addq.l	#4,SP

; ---
	move.l	DataData,-(SP)
	move.w	#$49,-(SP)	; - M_FREE -
	trap	#1	; *** GEMDOS ***
	addq.l	#6,SP

	tst.w	D0
	BNE	Free_Escape

	clr.w	D0	; No error
	
; ---

Free_Escape	move.w	D0,-(SP)
	move.w	#$4C,-(SP)	; - P_TERM -
	trap	#1	; *** GEMDOS ***

	SECTION	DATA
	
DataName	dc.b	"D:\DATA.DAT",0
TestName	dc.b	"D:\TEST.DAT",0
	
	SECTION	BSS
	
DataData	ds.l	1