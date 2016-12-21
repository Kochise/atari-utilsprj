; /// Desert Drain File Converter - KOSS 2000 ///

	comment	HEAD=7

; /////////////////////////////////////////////////////////////////////////////
	SECTION	TEXT
; /////////////////////////////////////////////////////////////////////////////

	; On v‚rifie la CommandLine
	
	move.l	(4,SP),A6		; Adresse de la BASEPAGE
	lea	ASM_Name,A5
	lea	(128,A6),A6		; Adresse de la COMMAND-TAIL

	move.b	(A6)+,D0		; Taille de la COMMAND-TAIL (ATTENTION : Format PASCAL)
	BNE	Copy_ASM_Name		; Si la COMMAND-TAIL existe...

	move.b	#0,(A5)+		; Pas de COMMAND-TAIL
	clr.w	D0

	BRA	Greetings	; On n'a plus rien … faire

	; On copie la CommandLine

Copy_ASM_Name	move.b	(A6)+,(A5)+	; Copie de la COMMAND-TAIL

	subq.b	#1,D0
	BNE	Copy_ASM_Name

	clr.b	(A5)	; Mets un OCTET nul … la fin de la chaine (ATTENTION : Transformation au format C)
	move.w	-(A5),D0	; Les derniŠres lettres (.RAW en principe)

	cmpi.w	#".S",D0	; On v‚rifie … tout hasard
	BNE	Exit	; A la prochaine...

Init_PRG_Mem	movea.l	4(SP),A6	; Adresse de la BASEPAGE
	move.l	$C(A6),D0	; Taille du SEGMENT TEXT
	add.l	$14(A6),D0	; Additionne la taille du SEGMENT DATA … D0
	add.l	$1C(A6),D0	; Additionne la taille du SEGMENT BSS … D0
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

	BSR	Convert_ASM_File
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

Convert_ASM_File	; D0.w = 
	; D1.w = 
	; D2.w = Number of PARTs
	; D3.l = PART Size
	; D4.l = DEV Size
	; D5.l = ASM Size
	; D6.w = DEV Handle
	; D7.w = ASM Handle
	
	; A0. = 
	; A1. = 
 	; A2.l = DEV Address
 	; A3.l = ASM Address
	; A4. = 
	; A5. = 
 	; A6. = 
 	; A7.l = Stack 

	pea	Load_Text
	move.w	#9,-(SP)	; - C_CONWS -
	trap	#1	; *** GEMDOS ***
	addq.l	#6,SP
	
	; Ouvre ASM

	clr.w	-(SP)
	pea	ASM_Name
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
	
	move.l	D0,D5	; Taille

	; Revient au d‚but

	clr.w	-(SP)	; D‚but
	move.w	D7,-(SP)
	clr.l	-(SP)	; D‚but du fichier
	move.w	#$42,-(SP)	; - F_SEEK -
	trap	#1	; *** GEMDOS ***
	lea	(10,SP),SP

	lea	ASM_Name,A0
	move.w	#".S",D0
	move.w	#256,D2
	
LookExtension	move.w	(A0,D2.w),D1
	cmp.w	D0,D1
	
	BEQ	ExtensionFound
	
	DBF	D2,LookExtension
	
	move.w	#-1,D0
	
	BRA	Close_File
	
ExtensionFound	move.l	#$2E535300",(A0,D2.w)	; ".SS",0

	clr.w	-(SP)
	pea	ASM_Name
	move.w	#$3C,-(SP)	; - F_CREATE -
	trap	#1	; *** GEMDOS ***
	addq.l	#8,SP
	
	move.w	D0,D6

	; Taille Maximum

	move.w	#3,-(SP)	; TT-RAM Prefered
	move.l	#-1,-(SP)	; Taille du fichier
	move.w	#$44,-(SP)	; - M_XALLOC -
	trap	#1	; *** GEMDOS ***
	addq.l	#8,SP

	tst.l	D0
	BEQ	Close_File

	; On v‚rifie si on peut charger 2* le fichier ASM

	move.l	D5,D1	; Taille ASM
	asl.l	#1,D1	; *2
	
	move.l	D5,D3	; Taille OK
	
	cmpi.l	D1,D0
	BGE	Reserve	; Assez de m‚moire
	
	; divu.l works like this :
	; D0 is the Quotient
	; D1 is the Rest
	;
	; D0.l <- Int [(D0+D1)/Value] (here Value == #Immediate)
	; D1.l <- Int [(Frac [(D0+D1)/Value])*Value ]
	
	sub.l	#512*1024,D0	; On laisse 512Ko
	asr.l	#1,D0	; /2
	
	clr.l	D1	; No Rest
	divu.l	#512*1024,D1:D0	; Reste Mem/512Ko
	
	mulu.l	#512*1024,D0	; On regarde Taille
	move.l	D0,D3	; Taille PART
	
	clr.l	D2	; Nombre PART
	move.l	D5,D0	; Taille ASM
	divu.l	D3,D0:D2	; 

Reserve	move.w	#3,-(SP)	; TT-RAM Prefered
	move.l	D3,-(SP)	; Taille du fichier
	move.w	#$44,-(SP)	; - M_XALLOC -
	trap	#1	; *** GEMDOS ***
	addq.l	#8,SP

	move.l	D0,A3
	
	move.w	#3,-(SP)	; TT-RAM Prefered
	move.l	D3,-(SP)	; Taille du fichier
	move.w	#$44,-(SP)	; - M_XALLOC -
	trap	#1	; *** GEMDOS ***
	addq.l	#8,SP

	move.l	D0,A2
	
	pea	Save_Text
	move.w	#9,-(SP)	; - C_CONWS -
	trap	#1	; *** GEMDOS ***
	addq.l	#6,SP


Convert_Loop	nop

	DBF	D2,Convert_Loop

Close_File	move.w	D7,-(SP)
	move.w	#$3E,-(SP)	; - F_CLOSE -
	trap	#1	; *** GEMDOS ***
	addq.l	#4,SP

	move.w	D6,-(SP)
	move.w	#$3E,-(SP)	; - F_CLOSE -
	trap	#1	; *** GEMDOS ***
	addq.l	#4,SP
	
	RTS
	
Load_Asm	move.l	D0,-(SP)	; Adresse du fichier
	move.l	D6,-(SP)	; Taille du fichier
	move.w	D7,-(SP)	; Handle
	move.w	#$3F,-(SP)	; - F_READ -
	trap	#1	; *** GEMDOS ***
	lea	(12,SP),SP
	
	RTS
	
Write_Dev	move.l	DEV_Data,-(SP)
	move.l	D6,-(SP)
	move.w	D7,-(SP)
	move.w	#$40,-(SP)	; - F_WRITE -
	trap	#1	; *** GEMDOS ***
	lea	(12,SP),SP

	RTS

; *****************************************************************************

Free_Memory	pea	Free_Text
	move.w	#9,-(SP)	; - C_CONWS -
	trap	#1	; *** GEMDOS ***
	addq.l	#6,SP
	
	move.l	ASM_Addr,-(SP)
	move.w	#$49,-(SP)	; - M_FREE -
	trap	#1	; *** GEMDOS ***
	addq.l	#6,SP

	tst.w	D0
	BNE	Free_Escape
	
	move.l	DEV_Addr,-(SP)
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

ASM_Name	ds.b	256

Prog_Title	dc.b	27,"E",27,"p DES to DEV File Converter - KOSS 1998 ",27,"q",13,10,13,10,0
Load_Text	dc.b	"Loading Desert Drain ",34,"*.S",34," File...",13,10,0
Save_Text	dc.b	"Saving DevPac ",34,"*.SS",34," File..",13,10,0
Free_Text	dc.b	"Free Memory from Previous Allocation...",13,10,0
Greets_To	dc.b	"Any File Draged...",13,10,13,10,0
	
; /////////////////////////////////////////////////////////////////////////////
	SECTION	BSS
; /////////////////////////////////////////////////////////////////////////////
