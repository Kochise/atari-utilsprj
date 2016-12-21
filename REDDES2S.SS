; /// > DESERT DRAIN SOURCE REDUCER - KOSS 2000 < ///

; *** Equates Zone ************************************************************

	; *** Equates for Assembly - DON'T CARE ABOUT THE SYNTAX ! IT WORKS !

_ASMEQU_DAY	EQU	15	
_ASMEQU_MONTH	EQU	7
_ASMEQU_YEAR	EQU	2000
_ASMEQU_DATE	EQU	((_ASMEQU_YEAR-1980)<<9)|(_ASMEQU_MONTH<<5)|(_ASMEQU_DAY)
	; SYSTEM DATE FORMAT :	%AAAAAAAmmmmJJJJJ
	
	; *** Commands for Assembly

	OPT	p=68030/68882
	comment	HEAD=7	; FastLoad

; /////////////////////////////////////////////////////////////////////////////	
	SECTION	TEXT
; /////////////////////////////////////////////////////////////////////////////	
	
	BRA	SRED_UMTEXT_START

	; *** PROG INFOS
	
	dc.b	"ProgHEAD"	; ProgHEADER
	dc.w	$0100	; ProgVERSION
	dc.w	_ASMEQU_DATE	; ProgDATE
	dc.b	"S REDUCER",0	; ProgNAME
	dc.b	"KOSS",0	; ProgAUTHOR
	
	; *** CREATE FILE PATH

SRED_UMTEXT_START:	lea	SRED_BSS_FILEPATH,A5

	move.w	#$19,-(SP)	; - D_GETDRV -
 	TRAP	#1	; *** GEMDOS ***
 	addq.l	#2,SP
 	
 	cmpi.w	#26,D0
 	BGE	SRED_UMTEXT_BDOSCMP
 	
 	add.w	#65,D0	; A..Z
 	
 	BRA	SRED_UMTEXT_BDOSDN
 	
SRED_UMTEXT_BDOSCMP:	add.w	#48-26,D0	; 1..6
 	
SRED_UMTEXT_BDOSDN: 	move.b	D0,(A5)+
 	move.b	#":",(A5)+
 	
 	clr.w	-(SP)
 	move.l	A5,-(SP)
 	move.w	#$47,-(SP)	; - D_GETPATH -
 	TRAP	#1	; *** GEMDOS ***
 	addq.l	#8,SP

SRED_UMTEXT_BDOSEP:	move.b	(A5)+,D0
	BNE	SRED_UMTEXT_BDOSEP

	move.b	#"\",(-1,A5)
	
	; *** CREATE FILE NAME

	move.l	(4,SP),A6	; Adresse de la BASEPAGE
	lea	(128,A6),A6	; Adresse de la COMMAND-TAIL

	move.b	(A6)+,D0	; Taille de la COMMAND-TAIL (ATTENTION : Format PASCAL)
	BNE	SRED_UMTEXT_COPYFN	; Si la COMMAND-TAIL existe...

	clr.w	D0

	BRA	SRED_UMTEXT_EXIT

SRED_UMTEXT_COPYFN:	subq.w	#1,D0

SRED_UMTEXT_COPYFNLOOP:	move.b	(A6)+,(A5)+	; Copie de la COMMAND-TAIL

	DBF	D0,SRED_UMTEXT_COPYFNLOOP

	clr.b	(A5)	; Mets un OCTET nul … la fin de la chaine (ATTENTION : Transformation au format C)
	clr.w	D0
	move.w	-(A5),D1	; Les derniŠres lettres
	cmpi.w	#".S",D1	; On v‚rifie … tout hasard
	BNE	SRED_UMTEXT_EXIT	; A la prochaine...

	; *** SHRINK MEMORY

	movea.l	(4,SP),A6	; ADDR PROG BLOCK START (BASEPAGE)
	move.l	(12,A6),D0	; SIZE SECTION TEXT
	add.l	(20,A6),D0	; SIZE SECTION DATA +
	add.l	(28,A6),D0	; SIZE SECTION BSS  +
	addi.l	#$100,D0	; SIZE BASEPAGE     +
	addi.l	#$400,D0	; SIZE NEW STACK    +
	move.l	D0,D1	; SIZE PROG BLOCK   =
	move.l	D0,D7
	add.l	A6,D1	; ADDR PROG BLOCK END (NEW STACK BLOCK END)
	andi.l	#-2,D1	; ADDR PROG BLOCK END (EVEN ADDR)              
	subq.l	#8,D1	; ADDR NEW STACK BLOCK END - 8 (NEW STACK POINTER START)
	move.l	(4,SP),D2	; ADDR PROG BLOCK START SAVE (BASEPAGE)
	movea.l	D1,SP	; ADDR NEW STACK POINTER START INSTALL
	move.l	D2,(4,SP)	; ADDR PROG BLOCK START RESTORE (BASEPAGE)
	move.l	D0,-(SP)	; SIZE PROG BLOCK RESERVE
	move.l	A6,-(SP)	; ADDR PROG BLOCK START RESERVE
	clr.w	-(SP)	; RESERVED
	move.w	#$4A,-(SP)	; - M_SHRINK -
	trap	#1	; *** GEMDOS ***
	lea	(12,SP),SP

	; *** INIT MEMORY

	move.l	#SRED_BSS_FILEPATH,D0
	BSR	SRED_USTEXT_GETFSIZE
	move.l	D0,SRED_BSS_SSIZE
	
	BSR	SRED_USTEXT_RESERVE
	move.l	D0,SRED_BSS_DADDR

	move.l	SRED_BSS_SSIZE,D0
	BSR	SRED_USTEXT_RESERVE
	move.l	D0,SRED_BSS_SADDR
	
	move.l	#SRED_BSS_FILEPATH,D1
	move.l	SRED_BSS_SSIZE,D2
	BSR	SRED_USTEXT_FLOAD
	
	; *** CONVERT FILE

	move.l	SRED_BSS_SSIZE,D0
	clr.l	D1
	clr.w	D3
	
	movea.l	SRED_BSS_SADDR,A0
	movea.l	SRED_BSS_DADDR,A1
	
SRED_UMTEXT_CONVSTART:	move.b	(A0)+,D2
	cmpi.b	#9,D2	; TAB
	BEQ	SRED_UMTEXT_CONVTAB
	
	cmpi.b	#" ",D2
	BEQ	SRED_UMTEXT_CONVSPACE
	
	cmpi.b	#"'",D2
	BNE	SRED_UMTEXT_CONVCOPY
	
	cmpi.b	#"'",D4
	BEQ	SRED_UMTEXT_CONVENDS
	
	move.b	D2,D4
	
	BRA	SRED_UMTEXT_CONVCOPY
	
SRED_UMTEXT_CONVSPACE:	cmpi.b	#"'",D4
	BEQ	SRED_UMTEXT_CONVCOPY
	
	move.b	#9,D2
	
SRED_UMTEXT_CONVTAB:	cmpi.b	#9,D3
	BNE	SRED_UMTEXT_CONVCOPY
	
	BRA	SRED_UMTEXT_CONVNEXT
	
SRED_UMTEXT_CONVENDS:	clr.b	D4

SRED_UMTEXT_CONVCOPY:	move.b	D2,D3
	move.b	D2,(A1)+
	addq.l	#1,D1

SRED_UMTEXT_CONVNEXT:	subq.l	#1,D0
	BNE	SRED_UMTEXT_CONVSTART
	
SRED_UMTEXT_CONVEND:	move.l	D1,SRED_BSS_DSIZE
	
	; *** SAVE MEMORY
	
	move.l	#SRED_BSS_FILEPATH,D0
	BSR	SRED_USTEXT_ENDS
	
	movea.l	D0,A0
	move.b	#"S",(A0)+
	clr.b	(A0)
	
	move.l	SRED_BSS_DADDR,D0
	move.l	#SRED_BSS_FILEPATH,D1
	move.l	SRED_BSS_DSIZE,D2
	BSR	SRED_USTEXT_FSAVE
	
	; *** EXIT

SRED_UMTEXT_EXIT:	move.w	D0,-(SP)
	move.w	#$4C,-(SP)	; - P_TERM -
	TRAP	#1	; *** GEMDOS ***

; *****************************************************************************

	; *** GET FILE SIZE
	; INPUT  : D0.l > FILE PATH
	; OUTPUT : D0.l = FILE SIZE
SRED_USTEXT_GETFSIZE:	clr.w	-(SP)
	move.l	D0,-(SP)
	move.w	#$3D,-(SP)	; - F_OPEN -
	TRAP	#1	; *** GEMDOS ***
	addq.l	#8,SP

	move.w	D0,D7	; HANDLE
	
	move.w	#2,-(SP)	; Fin
	move.w	D0,-(SP)
	clr.l	-(SP)	; Fin du fichier
	move.w	#$42,-(SP)	; - F_SEEK -
	TRAP	#1	; *** GEMDOS ***
	lea	10(SP),SP
	
	move.l	D0,D6	; SIZE

	move.w	D7,-(SP)
	move.w	#$3E,-(SP)	; - F_CLOSE -
	TRAP	#1	; *** GEMDOS ***
	addq.l	#4,SP
	
	move.l	D6,D0

	RTS

	; *** RESERVE MEMORY
	; INPUT  : D0.l = SIZE OF A BLOCK TO RESERVE
	; OUTPUT : D0.l > RESERVED BLOCK
SRED_USTEXT_RESERVE:	move.w	#3,-(SP)	; TT-RAM Prefered
	move.l	D0,-(SP)	; Taille du fichier
	move.w	#$44,-(SP)	; - M_XALLOC -
	TRAP	#1	; *** GEMDOS ***
	addq.l	#8,SP

	RTS

	; *** FILE LOAD
	; INPUT  : D0.l > DESTINATION AREA FOR THE FILE
	;          D1.l > FILE PATH
	;          D2.l > FILE SIZE
	; OUTPUT : NONE
SRED_USTEXT_FLOAD:	move.l	D0,D5
	move.l	D2,D6

	clr.w	-(SP)
	move.l	D1,-(SP)
	move.w	#$3D,-(SP)	; - F_OPEN -
	trap	#1	; *** GEMDOS ***
	addq.l	#8,SP

	move.w	D0,D7	; HANDLE

	move.l	D5,-(SP)	; Adresse du fichier
	move.l	D6,-(SP)	; Taille du fichier
	move.w	D7,-(SP)	; Handle
	move.w	#$3F,-(SP)	; - F_READ -
	TRAP	#1	; *** GEMDOS ***
	lea	12(SP),SP
	
	move.w	D7,-(SP)
	move.w	#$3E,-(SP)	; - F_CLOSE -
	TRAP	#1	; *** GEMDOS ***
	addq.l	#4,SP

	RTS

	; *** END STRING
	; INPUT  : D0.l > START OF STRING
	; OUTPUT : D0.l > END OF STRING (EXCLUSIVE)
SRED_USTEXT_ENDS:	movea.l	D0,A0

SRED_USTEXT_ENDSLOOP:	move.b	(A0)+,D0
	BNE	SRED_USTEXT_ENDSLOOP
	
	move.l	A0,D0
	subq.l	#1,D0

	RTS

	; *** FILE SAVE
	; INPUT  : D0.l > SOURCE AREA FOR THE FILE
	;          D1.l > FILE PATH
	;          D2.l > BLOCK SIZE
	; OUTPUT : NONE
SRED_USTEXT_FSAVE:	move.l	D0,D5
	move.l	D2,D6

	clr.w	-(SP)
	move.l	D1,-(SP)
	move.w	#$3C,-(SP)	; - F_CREATE -
	TRAP	#1	; *** GEMDOS ***
	addq.l	#8,SP

	move.w	D0,D7	; HANDLE

	move.l	D5,-(SP)	; Adresse du fichier
	move.l	D6,-(SP)	; Taille du fichier
	move.w	D7,-(SP)	; Handle
	move.w	#$40,-(SP)	; - F_WRITE -
	TRAP	#1	; *** GEMDOS ***
	lea	12(SP),SP
	
	move.w	D7,-(SP)
	move.w	#$3E,-(SP)	; - F_CLOSE -
	TRAP	#1	; *** GEMDOS ***
	addq.l	#4,SP

	RTS
	
; /////////////////////////////////////////////////////////////////////////////	
	SECTION	DATA
; /////////////////////////////////////////////////////////////////////////////	
	
; /////////////////////////////////////////////////////////////////////////////	
	SECTION	BSS
; /////////////////////////////////////////////////////////////////////////////	

SRED_BSS_SADDR	ds.l	1
SRED_BSS_DADDR	ds.l	1

SRED_BSS_SSIZE	ds.l	1
SRED_BSS_DSIZE	ds.l	1

SRED_BSS_FILEPATH	ds.b	256