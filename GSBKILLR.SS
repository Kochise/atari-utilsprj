; /// GRAF_GROWBOX & GRAF_SHRINKBOX Killer - KOSS 1999 ///

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

	pea	GSB_Install
	move.w	#$26,-(SP)	; - SUPEXEC -
	trap	#14	; *** XBIOS ***
	addq.l	#6,SP

	clr.w	-(SP)
	move.l	D7,-(SP)
	move.w	#$31,-(SP)	; - P_TERMRES -
	trap	#1	; *** GEMDOS ***

GSB_Install	move.l	$88.w,OldTRAP2
	move.l	#NewTRAP2,$88.w

	RTS

	dc.b	"XBRA"
	dc.b	"GSBK"
OldTRAP2	ds.l	1

NewTRAP2	cmpi.l	#200,D0	; AES ?
	BNE	JumpOldTRAP2	; NON !

	movem.l	D0/A0,-(SP)	; Sauve
	
	movea.l	D1,A0	; AES_Params
	move.w	([A0]),D0
	
	cmpi.w	#73,D0	; - GRAF_GROWBOX -
	BEQ	EndTRAP2
	
	cmpi.w	#74,D0	; - GRAF_SHRINKBOX -
	BEQ	EndTRAP2
	
	movem.l	(SP)+,D0/A0	; Restaure
	
	; C'est pas bon, on continue … l'ancienne routine

JumpOldTRAP2	JMP	([OldTRAP2])	; Zou...

EndTRAP2	movem.l	(SP)+,D0/A0	; Restaure

	RTE

	SECTION	DATA
	
	SECTION	BSS