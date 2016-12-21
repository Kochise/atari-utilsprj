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

	clr.w	-(SP)
	pea	Counter_File
	move.w	#$3D,-(SP)
	trap	#1
	addq.l	#8,SP
	
	move.w	D0,D7
	
	pea	Counter_Data
	move.l	#4,-(SP)
	move.w	D0,-(SP)
	move.w	#$3F,-(SP)
	trap	#1
	lea	(12,SP),SP
	
	move.w	D7,-(SP)
	move.w	#$3E,-(SP)
	trap	#1
	addq.l	#4,SP

	move.l	Counter_Data,D1
	addq.l	#1,D1
	move.l	D1,Counter_Data
	
	clr.w	-(SP)	
	pea	Counter_File
	move.w	#$3C,-(SP)
	trap	#1
	addq.l	#8,SP
	
	move.w	D0,D7
	
	pea	Counter_Data
	move.l	#4,-(SP)
	move.w	D0,-(SP)
	move.w	#$40,-(SP)
	trap	#1
	lea	(12,SP),SP
	
	move.w	D7,-(SP)
	move.w	#$3E,-(SP)
	trap	#1
	addq.l	#4,SP

	pea	Protect_Text
	move.w	#9,-(SP)
	trap	#1
	addq.l	#6,SP
	
Loop	nop
	BRA	Loop
	
	SECTION	DATA
	
Protect_Text	dc.b	27,"E",13,10
	dc.b	27,"p ATTENTION ",27,"q Cet ordinateur est actuellement en mode",13,10
	dc.b	" prot‚g‚, et ne sera … nouveau utilisable qu'… partir du :",13,10
	dc.b	13,10
	dc.b	" Lun 16/04/2001",13,10
	dc.b	13,10
	dc.b	" AU REVOIR...",0
	
Counter_File	dc.b	"\PROTECT.DAT",0
	
	SECTION	BSS
	
Counter_Data	ds.l	1