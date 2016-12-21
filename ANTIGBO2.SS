; /// > ANTI SHRINK/GROW BOX - KOSS 2002 < ///

	OPT	p=68030/68882
	COMMENT	HEAD=7	; FastLoad

BS:	EQU	1	; Bytes size
WS:	EQU	2
LS:	EQU	4

BB:	EQU	BS*8	; Bits size
WB:	EQU	WS*8
LB:	EQU	LS*8

FALSE:	EQU	0
TRUE:	EQU	1

; --- EQUATE ASSEMBLY (EA) ----------------------------------------------------

; --- EQUATE DATA (ED) --------------------------------------------------------

ASGB_ED_MAJOR_VERSION:	EQU	$01
ASGB_ED_MINOR_VERSION:	EQU	$00
ASGB_ED_ASSEMBLY_VERSION:	EQU	(ASGB_ED_MAJOR_VERSION<<8)|ASGB_ED_MINOR_VERSION

ASGB_ED_DAY:	EQU	16	; Binary Date Format
ASGB_ED_MONTH:	EQU	03	;  FEDC BA98 7654 3210
ASGB_ED_YEAR:	EQU	2002	; %YYYY YYYM MMMD DDDD
ASGB_ED_ASSEMBLY_DATE:	EQU	((ASGB_ED_YEAR-1980)<<9)|(ASGB_ED_MONTH<<5)|(ASGB_ED_DAY)

; --- EQUATE INDEX (EI) -------------------------------------------------------

; --- EQUATE SYSTEM (ES) ------------------------------------------------------

; /////////////////////////////////////////////////////////////////////////////	
	SECTION	TEXT
; /////////////////////////////////////////////////////////////////////////////	
	
;	BRA	ASGB_TUI_START
	
;	dc.b	"ProgHEAD"	; ProgHEADER
;	dc.w	ASGB_ED_ASSEMBLY_VERSION	; ProgVERSION
;	dc.w	ASGB_ED_ASSEMBLY_DATE	; ProgDATE
;	dc.b	"AntiShrinkGrowBox",0	; ProgNAME
;	dc.b	"Kochise",0	; ProgAUTHOR
	
; --- TEXT USER INIT (TUI) ----------------------------------------------------
	
ASGB_TUI_BOOT:	BRA	ASGB_TUM_START

	dc.b	"XBRA"
	dc.b	"ASGB"
ASGB_TSM_OLD_TRAP2_VECTOR:	ds.l	1
ASGB_TSM_NEW_TRAP2_VECTOR:	move.l	A0,-(SP)
	cmpi.l	#200,D0	; *** AES ***
	BNE	ASGB_TSM_JMP_OLD_TRAP2_VECTOR

	movea.l	D1,A0
	cmpi.w	#73,([A0])	; - GRAF_GROWBOX -
	BEQ	ASGB_TSM_SKIP_TRAP2_VECTOR
	cmpi.w	#74,([A0])	; - GRAF_SHRINKBOX -
	BEQ	ASGB_TSM_SKIP_TRAP2_VECTOR

ASGB_TSM_JMP_OLD_TRAP2_VECTOR:	move.l	(SP)+,A0
	JMP	([ASGB_TSM_OLD_TRAP2_VECTOR])
	
ASGB_TSM_SKIP_TRAP2_VECTOR:	move.l	(SP)+,A0
	RTE

; --- TEXT USER MAIN (TUM) ----------------------------------------------------

ASGB_TUM_START:	pea	ASGB_TSS_CHANGE_TRAP2_VECTOR
	move.w	#$26,-(SP)	; - SUPEXEC -
	TRAP	#14	; *** XBIOS ***
	addq.l	#6,SP

; --- TEXT USER EXIT (TUE) ----------------------------------------------------

	clr.w	-(SP)
	move.l	#ASGB_TUM_START-ASGB_TUI_BOOT,D0
	add.l	#$100,D0	; BASEPAGE
	move.l	D0,-(SP)
	move.w	#$31,-(SP)	; - P_TERMRES -
	TRAP	#1	; *** GEMDOS ***

; --- TEXT USER SUB (TUS) -----------------------------------------------------

; =============================================================================

; --- TEXT SUPER MAIN (TSM) ---------------------------------------------------

; --- TEXT SUPER SUB (TSS) ----------------------------------------------------

ASGB_TSS_CHANGE_TRAP2_VECTOR:	move.l	$88.w,ASGB_TSM_OLD_TRAP2_VECTOR
	move.l	#ASGB_TSM_NEW_TRAP2_VECTOR,$88.w
	
	RTS

; /////////////////////////////////////////////////////////////////////////////	
	SECTION	DATA
; /////////////////////////////////////////////////////////////////////////////	
	
; --- DATA ADDRESS TABLE (DAT) ------------------------------------------------
	
; --- DATA DEFINED ARRAY (DDA) ------------------------------------------------
	
; /////////////////////////////////////////////////////////////////////////////	
	SECTION	BSS
; /////////////////////////////////////////////////////////////////////////////	

; --- BSS DATA BUFFER (BDB) ---------------------------------------------------

; --- BSS FLAG BUFFER (BFB) ---------------------------------------------------
