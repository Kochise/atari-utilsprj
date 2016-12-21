; /// XXX FastDeCoder - KOSS 2000 ///

	comment	HEAD=7

; /////////////////////////////////////////////////////////////////////////////
	SECTION	TEXT
; /////////////////////////////////////////////////////////////////////////////

	; On v‚rifie la CommandLine
	
	move.l	(4,SP),A6		; Adresse de la BASEPAGE
	lea	XXX_Name,A5
	lea	(128,A6),A6		; Adresse de la COMMAND-TAIL

	move.b	(A6)+,D0		; Taille de la COMMAND-TAIL (ATTENTION : Format PASCAL)
	BNE	Copy_XXX_Name		; Si la COMMAND-TAIL existe...

	move.b	#0,(A5)+		; Pas de COMMAND-TAIL
	clr.w	D0

	BRA	Greetings	; On n'a plus rien … faire

	; On copie la CommandLine

Copy_XXX_Name	move.b	(A6)+,(A5)+	; Copie de la COMMAND-TAIL

	subq.b	#1,D0
	BNE	Copy_XXX_Name

	clr.b	(A5)	; Mets un OCTET nul … la fin de la chaine (ATTENTION : Transformation au format C)
	move.l	-(A5),D0	; Les derniŠres lettres (.RAW en principe)

	cmpi.l	#".JPG",D0	; On v‚rifie … tout hasard
	BNE	Exit	; A la prochaine...

Init_PRG_Mem	movea.l	4(SP),A6	; Adresse de la BASEPAGE
	move.l	($C,A6),D0	; Taille du SEGMENT TEXT
	add.l	($14,A6),D0	; Additionne la taille du SEGMENT DATA … D0
	add.l	($1C,A6),D0	; Additionne la taille du SEGMENT BSS … D0
	addi.l	#$100,D0	; Additionne la taille de la BASEPAGE … D0
	addi.l	#$400,D0	; Additionne la taille de la future PILE (Ici, 256 positions longues (1024 OCTETS))
	move.l	D0,D1	; Copie D0 dans D1 (Taille … r‚server)
	add.l	A6,D1	; Additionne l'adresse du d‚but du programme avec D1 (La taille … r‚server)
	andi.l	#-2,D1	; Rend D1 pair (Au cas o— il ne l'‚tait pas)
	subq.l	#8,D1	; Place pour le pointeur de la BasePage
	movea.l	D1,SP	; Installe l'adresse de fin du programme+place nouvelle PILE dans la PILE
	move.l	A6,(4,SP)	; Pointeur de la BasePage

	move.l	D0,-(SP)	; EmPILE la taille … reserver   \
	move.l	A6,-(SP)	; EmPILE l'adresse du programme |-> Rend le reste de la m‚moire au systŠme
	clr.w	-(SP)	; R‚serv‚                       |
	move.w	#$4A,-(SP)	; - M_SHRINK -                  |
	trap	#1	; *** GEMDOS ***                /
	lea	(12,SP),SP

	tst	D0	; Si D0<>0, problŠme grave
	BNE	Exit

; *****************************************************************************

Main	pea	Prog_Title
	move.w	#9,-(SP)	; - C_CONWS -
	trap	#1	; *** GEMDOS ***
	addq.l	#6,SP

	BSR	Convert_XXX_File
	BSR	Free_Memory
	
Exit	move.w	D0,-(SP)
	move.w	#$4C,-(SP)	; - P_TERM -
	trap	#1	; *** GEMDOS ***

; *****************************************************************************

Greetings	pea	Prog_Title
	move.w	#9,-(SP)	; - C_CONWS -
	trap	#1	; *** GEMDOS ***
	addq.l	#6,SP

	pea	Greets_To
	move.w	#9,-(SP)	; - C_CONWS -
	trap	#1	; *** GEMDOS ***
	addq.l	#6,SP

	move.w	#7,-(SP)	; - C_RAWCIN -
	trap	#1	; *** GEMDOS ***
	addq.l	#2,SP

	clr.w	D0	; No Problem...
	
	BRA	Exit

; *****************************************************************************

Convert_XXX_File	pea	Load_Text
	move.w	#9,-(SP)	; - C_CONWS -
	trap	#1	; *** GEMDOS ***
	addq.l	#6,SP
	
	; Ouvre XXX

	move.w	#2,-(SP)
	pea	XXX_Name
	move.w	#$3D,-(SP)	; - F_OPEN -
	trap	#1	; *** GEMDOS ***
	addq.l	#8,SP
	
	move.w	D0,D7	; Handle
	
	; Se place … la fin pour en connaitre la taille
	
	move.w	#2,-(SP)	; Fin
	move.w	D0,-(SP)
	clr.l	-(SP)	; Fin du fichier
	move.w	#$42,-(SP)	; - F_SEEK -
	trap	#1	; *** GEMDOS ***
	lea	(10,SP),SP
	
	move.l	D0,D6	; Taille

	; Revient au d‚but

	clr.w	-(SP)	; D‚but
	move.w	D7,-(SP)
	clr.l	-(SP)	; D‚but du fichier
	move.w	#$42,-(SP)	; - F_SEEK -
	trap	#1	; *** GEMDOS ***
	lea	(10,SP),SP

	; R‚serve M‚moire

	move.w	#3,-(SP)	; TT-RAM Prefered
	move.l	D6,-(SP)	; Taille du fichier
	move.w	#$44,-(SP)	; - M_XALLOC -
	trap	#1	; *** GEMDOS ***
	addq.l	#8,SP

	move.l	D0,D5	; Adresse
	
	; Charge Fichier
	
	move.l	D5,-(SP)
	move.l	D6,-(SP)
	move.w	D7,-(SP)
	move.w	#$3F,-(SP)	; - F_READ -
	trap	#1	; *** GEMDOS ***
	lea	(12,SP),SP
	
	; Revient au d‚but

	clr.w	-(SP)	; D‚but
	move.w	D7,-(SP)
	clr.l	-(SP)	; D‚but du fichier
	move.w	#$42,-(SP)	; - F_SEEK -
	trap	#1	; *** GEMDOS ***
	lea	(10,SP),SP
	
	movea.l	D5,A0
	move.l	D6,D2
	subq.l	#1,D2

;Test_XXX_File	move.l	(A0),D0
;	cmpi.l	#$FFD8FFE0,D0
;	BEQ	Close_File
;	
;	move.b	(A0),D0
;	eori.b	#$FF,D0

	move.b	#$A5,D0

Convert_Loop	eor.b	D0,(A0)+

	DBF	D2,Convert_Loop
	
	; Sauve le Fichier
	
	pea	Save_Text
	move.w	#9,-(SP)	; - C_CONWS -
	trap	#1	; *** GEMDOS ***
	addq.l	#6,SP

	move.l	D5,-(SP)
	move.l	D6,-(SP)
	move.w	D7,-(SP)
	move.w	#$40,-(SP)	; - F_WRITE -
	trap	#1	; *** GEMDOS ***
	lea	(12,SP),SP

Close_File	move.w	D7,-(SP)
	move.w	#$3E,-(SP)	; - F_CLOSE -
	trap	#1	; *** GEMDOS ***
	addq.l	#4,SP
	
	RTS
	
; *****************************************************************************

Free_Memory	pea	Free_Text
	move.w	#9,-(SP)	; - C_CONWS -
	trap	#1	; *** GEMDOS ***
	addq.l	#6,SP
	
	move.l	D5,-(SP)
	move.w	#$49,-(SP)	; - M_FREE -
	trap	#1	; *** GEMDOS ***
	addq.l	#6,SP

	tst.w	D0
	BNE	Free_Escape
	
	clr.w	D0	; No error
	
Free_Escape	RTS

; /////////////////////////////////////////////////////////////////////////////
	SECTION	DATA
; /////////////////////////////////////////////////////////////////////////////

XXX_Name	ds.b	256

Prog_Title	dc.b	27,"E",27,"p XXX FastDeCoder - KOSS 2000 ",27,"q",13,10,13,10,0
Load_Text	dc.b	"Loading File ",34,"*.JPG",34," File...",13,10,0
Save_Text	dc.b	"Saving File ",34,"*.JPG",34," File..",13,10,0
Free_Text	dc.b	"Free Memory from Previous Allocation...",13,10,0
Greets_To	dc.b	"Any File Draged...",13,10,13,10,0
	
; /////////////////////////////////////////////////////////////////////////////
	SECTION	BSS
; /////////////////////////////////////////////////////////////////////////////
