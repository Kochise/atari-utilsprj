; /// TPI to TGA File Converter - KOSS 1998 ///

	comment	HEAD=7

	SECTION	TEXT

	; Initialise le BORDEL

	move.l	4(SP),A6		; Adresse de la BASEPAGE
	lea	$80(A6),A6		; Adresse de la COMMAND-TAIL
	move.b	(A6)+,D0		; Taille de la COMMAND-TAIL (ATTENTION : Format PASCAL)
	lea	TPI_Name,A5
	bne	Copy_TPI_Name		; Si la COMMAND-TAIL existe...
	move.b	#0,(A5)+		; Pas de COMMAND-TAIL
	clr.w	D0
	bra	Greetings	; On n'a plus rien … faire

Copy_TPI_Name	move.b	(A6)+,(A5)+	; Copie de la COMMAND-TAIL
	subq.b	#1,D0
	bne	Copy_TPI_Name
	clr.b	(A5)	; Mets un OCTET nul … la fin de la chaine (ATTENTION : Transformation au format C)
	move.l	-(A5),D0	; Les derniŠres lettres (.RAW en principe)
	cmpi.l	#".TPI",D0	; On v‚rifie … tout hasard
	bne	Exit	; A la prochaine...

	movea.l	4(SP),A6	; Adresse de la BASEPAGE
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
	lea	12(SP),SP
	tst	D0	; Si D0<>0, problŠme grave
	bne	Exit

	; Ouvre le Fichier

	clr.w	-(SP)
	pea	TPI_Name
	move.w	#$3D,-(SP)	; - F_OPEN -
	trap	#1	; *** GEMDOS ***
	addq.l	#8,SP
	move.w	D0,D7	; Handle
	
	; Taille
	
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

	; M‚moire -> Taille

	move.w	#3,-(SP)	; TT-RAM Prefered
	move.l	D6,-(SP)	; Taille du fichier
	move.w	#$44,-(SP)	; - M_XALLOC -
	trap	#1	; *** GEMDOS ***
	addq.l	#8,SP
	
	; C'est idiot
	
	tst.l	D0
	BEQ	Close_File
	
	move.l	D0,TPI_Data
	
	; Charge
	
	move.l	D0,-(SP)	; Adresse du fichier
	move.l	D6,-(SP)	; Taille du fichier
	move.w	D7,-(SP)	; Handle
	move.w	#$3F,-(SP)	; - F_READ -
	trap	#1	; *** GEMDOS ***
	lea	12(SP),SP
	
	; Ferme
	
Close_File	move.w	D7,-(SP)
	move.w	#$3E,-(SP)	; - F_CLOSE -
	trap	#1	; *** GEMDOS ***
	addq.l	#4,SP
	
	; La taille de l'Image
	
	move.l	TPI_Data,A0
	clr.l	D0
	clr.l	D1
	move.w	(8,A0),D0
	mulu.l	#3,D0
	move.w	(10,A0),D1
	mulu.l	D1,D0
	add.l	#18,D0
	
	move.l	D0,D6
	
	; M‚moire -> Targa
	
	move.w	#3,-(SP)	; TT-RAM Prefered
	move.l	D6,-(SP)	; Taille du fichier
	move.w	#$44,-(SP)	; - M_XALLOC -
	trap	#1	; *** GEMDOS ***
	addq.l	#8,SP
	tst.l	D0
			
	move.l	D0,TGA_Data

	movea.l	TPI_Data,A0
	movea.l	D0,A1
	
	; Header Targa
	
	move.l	#$200,(A1)
	clr.l	(4,A1)
	clr.l	(8,A1)
	move.w	(8,A0),D0
	rol.w	#8,D0
	move.w	D0,(12,A1)
	move.w	(10,A0),D0
	rol.w	#8,D0
	move.w	D0,(14,A1)
	move.w	#$1820,(16,A1)
	
	movea.l	A0,A2	; TPI_Pic
	adda.l	#128,A2
	movea.l	A1,A3	; TGA_Pic
	adda.l	#18,A3
		
	; Conversion
		
	move.w	(8,A0),D1

Line_Loop	move.w	(10,A0),D0
	
Pixel_Loop	move.w	(A2)+,D2	; RRRRRGGG GGGBBBBB
	move.w	D2,D3	; RRRRRGGG GGGBBBBB
	move.w	D2,D4	; RRRRRGGG GGGBBBBB
	
	andi.w	#%11111,D2	; ........ ...BBBBB
	rol.b	#3,D2	;          BBBBB...
	
	andi.w	#%11111100000,D3	; .....GGG GGG.....
	ror.w	#3,D3	; ........ GGGGGG..
	
	rol.w	#8,D4	; GGGBBBBB RRRRRGGG
	andi.w	#%11111000,D4	; ........ RRRRR...
	
	move.b	D2,(A3)+	; Bleu
	move.b	D3,(A3)+	; Vert
	move.b	D4,(A3)+	; Rouge
		
	DBF	D0,Pixel_Loop
	
	DBF	D1,Line_Loop

	; Nom mais Extension TGA

	lea	TPI_Name,A0
	move.l	#".TPI",D0
	move.w	#256,D2
	
LookExtension	move.l	(A0,D2.w),D1
	cmp.l	D0,D1
	
	BEQ	ExtensionFound
	
	DBF	D2,LookExtension
	
	move.w	#-1,D0
	
	RTS
	
ExtensionFound	move.l	#".TGA",(A0,D2.w)

	; Ecraser

	clr.w	-(SP)
	pea	TPI_Name
	move.w	#$3C,-(SP)	; - F_CREATE -
	trap	#1	; *** GEMDOS ***
	addq.l	#8,SP
	
	move.w	D0,D7
	
	; Ecrire
	
	move.l	TGA_Data,-(SP)
	move.l	D6,-(SP)
	move.w	D7,-(SP)
	move.w	#$40,-(SP)	; - F_WRITE -
	trap	#1	; *** GEMDOS ***
	lea	(12,SP),SP
	
	; Fermer
	
	move.w	D7,-(SP)
	move.w	#$3E,-(SP)	; - F_CLOSE -
	trap	#1	; *** GEMDOS ***
	addq.l	#4,SP

	; Lib‚rer M‚moire

	move.l	TPI_Data,-(SP)
	move.w	#$49,-(SP)	; - M_FREE -
	trap	#1	; *** GEMDOS ***
	addq.l	#6,SP
	
	tst.w	D0
	BNE	Exit
	
	move.l	TGA_Data,-(SP)
	move.w	#$49,-(SP)	; - M_FREE -
	trap	#1	; *** GEMDOS ***
	addq.l	#6,SP
	
	tst.w	D0
	BNE	Exit

	clr.w	D0	; No error
	
	; Kassos
	
Exit	move.w	D0,-(SP)
	move.w	#$4C,-(SP)	; - P_TERM -
	trap	#1	; *** GEMDOS ***

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
	
	bra	Exit

	SECTION	DATA
	
Prog_Title	dc.b	27,"E",27,"p TPI to TGA File Converter - KOSS 1999 ",27,"q",13,10,13,10,0
Load_Text	dc.b	"Loading TPI Image ",34,"TPI",34," File...",13,10,0
Save_Text	dc.b	"Saving Targa ",34,"TGA",34," File..",13,10,0
Free_Text	dc.b	"Free Memory from Previous Allocation...",13,10,0
Greets_To	dc.b	"Any File Draged...",13,10,13,10,"A Little Message Instead Of Working...",13,10
	dc.b	"If Ever You Wanna Convert An Image Grabbed Using XGRAB Into The",13,10
	dc.b	"Targa Standart Format, Just Drag Your TPI File Onto TPI2TGA.PRG",13,10
	dc.b	"And It's All. WARNING : XGRABBER Work And Save only In 16Bits Format!",13,10
	dc.b	"Good Job With This Little Piece Of Code Originated From PRAWPLAY ;-]",13,10,13,10
	dc.b	"       ",27,"p> Press ANY Keys... <",27,"q",13,10,0

	SECTION	BSS
	
TPI_Name	ds.b	256
TPI_Data	ds.l	1
TGA_Data	ds.l	1
