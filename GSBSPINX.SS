; /// GRAF_GROWBOX & GRAF_SHRINKBOX Spinner - KOSS 1999 ///

; WARNING : START  A7.l = 2
; BUG       OPCODE      move.B Dx,-(SP)
; REPORT    END    A7.l = 0, and NOT 1

	OPT	p=68030/68882
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
	
	dc.w	$A000
	move.l	A0,LineA

	RTS

	dc.b	"XBRA"
	dc.b	"GSBK"
OldTRAP2	ds.l	1

	; En-dehors de l'AES, rien ne nous int‚resse...
NewTRAP2	cmpi.l	#200,D0	; AES ?
	BNE	JumpOldTRAP2	; NON !

	movem.l	D0-D7/A0-A6,-(SP)	; Sauve
	
	movea.l	D1,A0	; AES_Params
	move.w	([A0]),D0
	
	cmpi.w	#73,D0	; - GRAF_GROWBOX -
	BEQ	GrowSpinBox
	
	cmpi.w	#74,D0	; - GRAF_SHRINKBOX -
	BEQ	ShrinkSpinBox
	
	; Tant pis, c'‚tait pas la bonne
	movem.l	(SP)+,D0-D7/A0-A6	; Restaure
	
	; C'est pas bon, on continue … l'ancienne routine

JumpOldTRAP2	JMP	([OldTRAP2])	; Zou...

	; On tourne en positif
GrowSpinBox	move.w	#1,WheelTurn
	
	BRA	SpinBox
	
	; On tourne en n‚gatif
ShrinkSpinBox	move.w	#-1,WheelTurn

	; Pr‚calcule le Bintz
SpinBox	;ILLEGAL
	
	move.l	A0,-(SP)
	
	movea.l	LineA,A0
	move.w	(-12,A0),XScreen
	move.w	(-4,A0),YScreen
	
	movea.l	(SP)+,A0
	
	BSR	WheelsMath

	; Un coup on affiche, l'autre on efface
	move.w	#1,D7
	
	; Ze TŠ‹bleulle
WayReturn	lea	SpinningWheels,A0

	; Et hop, c'est parti pour 10 tours !
	move.w	#9,D6

GraphTurn	;move.l	(A0)+,GraphWheel
	;move.l	(A0),GraphWheel+4
	;BSR	GraphWheels	; Line 01

	;move.l	(A0)+,GraphWheel
	;move.l	(A0),GraphWheel+4
	;BSR	GraphWheels	; Line 12

	;move.l	(A0)+,GraphWheel
	;move.l	(A0)+,GraphWheel+4
	;BSR	GraphWheels	; Line 23

	;move.l	(A0)+,GraphWheel
	;move.l	(-16,A0),GraphWheel+4
	;BSR	GraphWheels	; Line 30
	
	movea.l	A0,A1
	
	move.l	A0,-(SP)
	
	move.l	LineA,A0
	move.w	#6,([4,A0])	; OpCode
	move.w	#5,([4,A0],2)	; NbCouple
	move.w	#0,([4,A0],4)
	move.w	#0,([4,A0],6)
	move.w	#6,([4,A0],8)
	move.w	#1,([4,A0],12)	; Ecran
	
	movea.l	(12,A0),A2
	
	move.l	(A1)+,(A2)+
	move.l	(A1)+,(A2)+
	move.l	(A1)+,(A2)+
	move.l	(A1)+,(A2)+
	move.l	(-16,A1),(A2)

	move.l	#115,D0
	move.l	A0,D1
	addq.l	#4,D1
	trap	#2	; *** VDI ***
	
	movea.l	(SP)+,A0

	DBF	D6,GraphTurn

	DBF	D7,WayReturn

	movem.l	(SP)+,D0-D7/A0-A6	; Restaure

	RTE
	
	; L… dedans, on va pr‚calculer TOUT le bintz
	
WheelsMath	fmove.w	([8,A0],4),FP0	; L1
	fmove.w	([8,A0],6),FP1	; H1
	fmove.w	([8,A0],12),FP2	; L2
	fmove.w	([8,A0],14),FP3	; H2

	; Calcul de WheelAngle

	fmove.x	FP1,FP4
	fdiv.x	FP0,FP4
	fatan.x	FP4	; Angle D‚part
	fmove.s	FP4,WheelAngle
	fmove.x	FP4,FP6

	; Calcul de WheelAnglePart

	fmove.x	FP3,FP4
	fdiv.x	FP2,FP4
	fatan.x	FP4	; Angle Fin
	fsub.x	FP6,FP4
	fdiv.x	#9,FP4
	fmove.s	FP4,WheelAnglePart

	; Calcul de WheelCenterX
	
	fmove.x	FP0,FP4
	fdiv.x	#2,FP4
	fmove.w	([8,A0]),FP5	; X1
	fadd.x	FP5,FP4
	fmove.s	FP4,WheelCenterX
	fmove.x	FP4,FP6
	
	; Calcul de WheelCenterPartX

	fmove.x	FP2,FP4
	fdiv.x	#2,FP4
	fmove.w	([8,A0],8),FP5	; X2
	fadd.x	FP5,FP4
	fsub.x	FP6,FP4
	fdiv.x	#9,FP4
	fmove.s	FP4,WheelCenterPartX

	; Calcul de WheelCenterY

	fmove.x	FP1,FP4
	fdiv.x	#2,FP4
	fmove.w	([8,A0],2),FP5	; Y1
	fadd.x	FP5,FP4
	fmove.s	FP4,WheelCenterY
	fmove.x	FP4,FP6
	
	; Calcul de WheelCenterPartY
	
	fmove.x	FP3,FP4
	fdiv.x	#2,FP4
	fmove.w	([8,A0],10),FP5	; Y2
	fadd.x	FP5,FP4
	fsub.x	FP6,FP4
	fdiv.x	#9,FP4
	fmove.s	FP4,WheelCenterPartY

	; Calcul de WheelRadius par Pythagore

	fmul.x	FP0,FP0
	fmul.x	FP1,FP1
	fmul.x	FP2,FP2
	fmul.x	FP3,FP3
	
	fadd.x	FP1,FP0
	fadd.x	FP3,FP2
	
	fsqrt.x	FP0
	fsqrt.x	FP2
	
	fdiv.x	#2,FP0
	fdiv.x	#2,FP2
	
	fmove.s	FP0,WheelRadius

	; Calcul de WheelRadiusPart
	
	fsub.x	FP0,FP2
	fdiv.x	#9,FP2
	fmove.s	FP2,WheelRadiusPart

	; Calcul de l'Animation
	clr.w	D0
	lea	SpinningWheels,A0
	
SpinZeWheel	fmove.w	D0,FP0
	fmove.w	WheelTurn,FP1
	fmul.x	FP0,FP1
	fmovecr.x	#0,FP2
	fdiv.x	#18,FP2
	fmul.x	FP2,FP1
	
	; Calcul de l'Angle
	
	fmove.s	WheelAngle,FP2
	fadd.x	FP2,FP1
	fmove.s	WheelAnglePart,FP2
	fmul.x	FP0,FP2
	fadd.x	FP2,FP1	; Angle
	
	; Calcul du Rayon
	
	fmove.s	WheelRadius,FP2
	fmove.s	WheelRadiusPart,FP3
	fmul.x	FP0,FP3
	fadd.x	FP3,FP2	; Rayon
	
	; Calcul de X
	
	fmove.s	WheelCenterX,FP3
	fmove.s	WheelCenterPartX,FP4
	fmul.x	FP0,FP4
	fadd.x	FP4,FP3	; X
	
	; Calcul de Y
	
	fmove.s	WheelCenterY,FP4
	fmove.s	WheelCenterPartY,FP5
	fmul.x	FP0,FP5
	fadd.x	FP5,FP4	; Y
	
	; Calcul du point 1
	
	fmove.x	FP1,FP7
	
	BSR	FinalCoordonate
	
	; Calcul du point 2
	
	fmovecr.x	#0,FP7
	fsub.x	FP1,FP7

	BSR	FinalCoordonate
	
	; Calcul du point 3

	fmovecr.x	#0,FP7
	fadd.x	FP1,FP7

	BSR	FinalCoordonate
	
	; Calcul du point 4
	
	fmovecr.x	#0,FP7
	fsub.x	FP1,FP7
	fmovecr.x	#0,FP1
	fadd.x	FP1,FP7
	
	BSR	FinalCoordonate
	
	addq.w	#1,D0
	cmpi.w	#9,D0
	BLE	SpinZeWheel
	
	RTS

FinalCoordonate	fmove.x	FP7,FP5
	fmove.x	FP7,FP6
	
	fcos.x	FP5
	fsin.x	FP6
	
	fmul.x	FP2,FP5
	fmul.x	FP2,FP6
	
	fadd.x	FP3,FP5
	fadd.x	FP4,FP6
	
	fmove.x	#0,FP0
	fcmp.x	FP0,FP5
	FBGE	AddX
	
	BRA	KO_X

AddX	fmove.w	XScreen,FP0
	fcmp.x	FP0,FP5
	FBLT	OK_X
	
KO_X	fmove.x	FP0,FP5	
	
OK_X	fmove.w	FP5,(A0)+
	
	fmove.x	#0,FP0
	fcmp.x	FP0,FP6
	FBGE	AddY
	
	BRA	KO_Y

AddY	fmove.w	YScreen,FP0
	fcmp.x	FP0,FP6
	FBLT	OK_Y
	
KO_Y	fmove.x	FP0,FP6

OK_Y	fmove.w	FP6,(A0)+

	RTS

GraphWheels	move.l	A0,-(SP)

	movea.l	LineA,A0
	move.w	GraphWheel,(38,A0)	; _X1
	move.w	GraphWheel+2,(40,A0)	; _Y1
	move.w	GraphWheel+4,(42,A0)	; _X2
	move.w	GraphWheel+6,(44,A0)	; _Y2
	
	move.w	#1,(24,A0)	; _FG_BP1
	clr.w	(26,A0)	; _FG_BP2
	clr.w	(28,A0)	; _FG_BP3
	clr.w	(30,A0)	; _FG_BP4
	
	move.w	#$FAFA,(34,A0)	; _Ln_Mask
	
	move.w	#2,(36,A0)	; _Wrt_Mod

	move.w	#-1,(32,A0)	; _LstLin

	dc.w	$A003	; Line

	move.l	(SP)+,A0

	RTS

	SECTION	DATA
	
	SECTION	BSS
	
WheelAngle	ds.l	1
WheelAnglePart	ds.l	1
WheelCenterX	ds.l	1
WheelCenterPartX	ds.l	1
WheelCenterY	ds.l	1
WheelCenterPartY	ds.l	1
WheelRadius	ds.l	1
WheelRadiusPart	ds.l	1

LineA	ds.l	1
SpinningWheels	ds.l	40
GraphWheel	ds.l	2
WheelTurn	ds.w	1
XScreen	ds.w	1
YScreen	ds.w	1