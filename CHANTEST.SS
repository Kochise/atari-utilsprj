; /// > CHANNEL TEST - KOSS 2001 < ///
;

; *** Equates Zone ************************************************************

	; *** Equates for Assembly

ASMEQU_DAY	EQU	8	
ASMEQU_MONTH	EQU	6
ASMEQU_YEAR	EQU	2001
	; Date Format :	%AAAAAAAmmmmJJJJJ
ASMEQU_DATE	EQU	((ASMEQU_YEAR-1980)<<9)|(ASMEQU_MONTH<<5)|(ASMEQU_DAY)

	; *** Commands for Assembly

	OPT	p=68030/68882
	comment	HEAD=7	; FastLoad

; /////////////////////////////////////////////////////////////////////////////	
	SECTION	TEXT
; /////////////////////////////////////////////////////////////////////////////	
	
	BRA	CTST_TEXT_START

	; *** Program Informations for PROGINFO
	
	dc.b	"ProgHEAD"	; ProgHEADER
	dc.w	$0100	; ProgVERSION
	dc.w	ASMEQU_DATE	; ProgDATE
	dc.b	"CHANNEL TEST",0	; ProgNAME
	dc.b	"Kochise",0	; ProgAUTHOR
	
CTST_TEXT_START:	movea.l	(4,SP),A6	; ADDR PROG BLOCK START (BASEPAGE)
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

CTST_TEXT_PRT_MAIN_SCR:	pea	CTST_DATA_MAIN_SCR_0
	move.w	#9,-(SP)	; - C_CONWS -
	TRAP	#1	; *** GEMDOS ***
	addq.l	#6,SP
	
	BSR	CTST_TEXT_PRT_CHANNEL
	
	pea	CTST_DATA_MAIN_SCR_1
	move.w	#9,-(SP)	; - C_CONWS -
	TRAP	#1	; *** GEMDOS ***
	addq.l	#6,SP

CTST_TEXT_GET_CHOICE:	move.w	#1,-(SP)	; - C_CONIN -
	TRAP	#1	; *** GEMDOS ***
	addq.l	#2,SP
	
	sub.b	#'0',D0
	BMI	CTST_TEXT_PRT_MAIN_SCR
	
	cmpi.b	#3,D0
	BGT	CTST_TEXT_PRT_MAIN_SCR
	
	lea	CTST_DATA_ROUT_TAB,A0
	JSR	([A0,D0.w*4])
	
	BRA	CTST_TEXT_PRT_MAIN_SCR
	
CTST_TEXT_SEND:	pea	CTST_DATA_SEND_SCR0
	move.w	#9,-(SP)	; - C_CONWS -
	TRAP	#1	; *** GEMDOS ***
	addq.l	#6,SP

	BSR	CTST_TEXT_PRT_CHANNEL

	pea	CTST_DATA_CRLF
	move.w	#9,-(SP)	; - C_CONWS -
	TRAP	#1	; *** GEMDOS ***
	addq.l	#6,SP

	pea	CTST_DATA_ESC_RETURN
	move.w	#9,-(SP)	; - C_CONWS -
	TRAP	#1	; *** GEMDOS ***
	addq.l	#6,SP
	
	pea	CTST_DATA_SEND_SCR1
	move.w	#9,-(SP)	; - C_CONWS -
	TRAP	#1	; *** GEMDOS ***
	addq.l	#6,SP
	
CTST_TEXT_SEND_LOOP:	move.w	#1,-(SP)	; - C_CONIN -
	TRAP	#1	; *** GEMDOS ***
	addq.l	#2,SP

	move.w	D0,D4

	cmpi.b	#13,D0
	BNE	CTST_TEXT_SEND_OUT	
	
	move.w	#10,-(SP)
	move.w	#2,-(SP)	; - C_CONOUT -
	TRAP	#1	; *** GEMDOS ***
	addq.l	#4,SP

CTST_TEXT_SEND_OUT:	move.w	D4,-(SP)	; DATA
	move.w	CTST_DATA_CURR_CHANNEL,-(SP)
	move.w	#3,-(SP)	; - BCONOUT -
	TRAP	#13	; *** BIOS ***
	addq.l	#6,SP
	
	cmpi.b	#27,D4	; [Esc]
	BNE	CTST_TEXT_SEND_LOOP
	
	RTS

CTST_TEXT_RECEIVE:	pea	CTST_DATA_RECEIVE_SCR0
	move.w	#9,-(SP)	; - C_CONWS -
	TRAP	#1	; *** GEMDOS ***
	addq.l	#6,SP

	BSR	CTST_TEXT_PRT_CHANNEL
	
	pea	CTST_DATA_CRLF
	move.w	#9,-(SP)	; - C_CONWS -
	TRAP	#1	; *** GEMDOS ***
	addq.l	#6,SP

	pea	CTST_DATA_ESC_RETURN
	move.w	#9,-(SP)	; - C_CONWS -
	TRAP	#1	; *** GEMDOS ***
	addq.l	#6,SP
	
	pea	CTST_DATA_RECEIVE_SCR1
	move.w	#9,-(SP)	; - C_CONWS -
	TRAP	#1	; *** GEMDOS ***
	addq.l	#6,SP
	
CTST_TEXT_RECEIVE_LOOP:	move.w	CTST_DATA_CURR_CHANNEL,-(SP)
	move.w	#1,-(SP)	; - BCONSTAT -
	TRAP	#13	; *** BIOS ***
	addq.l	#4,SP

	tst.w	D0
	BNE	CTST_TEXT_RECEIVE_GET
	
	move.w	#2,-(SP)
	move.w	#1,-(SP)	; - BCONSTAT -
	TRAP	#13	; *** BIOS ***
	addq.l	#4,SP

	tst.w	D0
	BEQ	CTST_TEXT_RECEIVE_LOOP
	
	move.w	#2,-(SP)
	move.w	#2,-(SP)	; - BCONIN -
	TRAP	#13	; *** BIOS ***
	addq.l	#4,SP

	move.w	D0,D4
	
	BRA	CTST_TEXT_RECEIVE_END

CTST_TEXT_RECEIVE_GET:	move.w	CTST_DATA_CURR_CHANNEL,-(SP)
	move.w	#2,-(SP)	; - BCONIN -
	TRAP	#13	; *** BIOS ***
	addq.l	#4,SP
	
	move.w	D0,D4

	cmpi.b	#13,D0
	BNE	CTST_TEXT_RECEIVE_OUT	
	
	move.w	#10,-(SP)
	move.w	#2,-(SP)	; - C_CONOUT -
	TRAP	#1	; *** GEMDOS ***
	addq.l	#4,SP
	
CTST_TEXT_RECEIVE_OUT:	move.w	D4,-(SP)
	move.w	#2,-(SP)	; - C_CONOUT -
	TRAP	#1	; *** GEMDOS ***
	addq.l	#4,SP
	
CTST_TEXT_RECEIVE_END:	cmpi.b	#27,D4	; [Esc]
	BNE	CTST_TEXT_RECEIVE_LOOP
	
	RTS
	
CTST_TEXT_CHANGE:	pea	CTST_DATA_CHANGE_SCR0
	move.w	#9,-(SP)	; - C_CONWS -
	TRAP	#1	; *** GEMDOS ***
	addq.l	#6,SP

	BSR	CTST_TEXT_PRT_CHANNEL
	
	pea	CTST_DATA_CHANGE_SCR1
	move.w	#9,-(SP)	; - C_CONWS -
	TRAP	#1	; *** GEMDOS ***
	addq.l	#6,SP

	clr.w	D4
	
CTST_TEXT_CHANGE_LIST:	BSR	CTST_TEXT_PRT_CHAN_OUT

	pea	CTST_DATA_CRLF
	move.w	#9,-(SP)	; - C_CONWS -
	TRAP	#1	; *** GEMDOS ***
	addq.l	#6,SP

	addq.w	#1,D4
	cmpi.w	#8,D4
	BLE	CTST_TEXT_CHANGE_LIST
	
	pea	CTST_DATA_ESC_RETURN
	move.w	#9,-(SP)	; - C_CONWS -
	TRAP	#1	; *** GEMDOS ***
	addq.l	#6,SP

	pea	CTST_DATA_CHANGE_SCR2
	move.w	#9,-(SP)	; - C_CONWS -
	TRAP	#1	; *** GEMDOS ***
	addq.l	#6,SP

CTST_TEXT_CHANGE_GET:	move.w	#1,-(SP)	; - C_CONIN -
	TRAP	#1	; *** GEMDOS ***
	addq.l	#2,SP
	
	cmpi.b	#27,D0	; [Esc]
	BEQ	CTST_TEXT_CHANGE_EXIT
	
	sub.b	#'0',D0
	BMI	CTST_TEXT_CHANGE
	
	cmpi.b	#8,D0
	BGT	CTST_TEXT_CHANGE
	
	move.w	D0,CTST_DATA_CURR_CHANNEL
	
CTST_TEXT_CHANGE_EXIT:	RTS

CTST_TEXT_EXIT:	clr.w	-(SP)	; - P_TERM0 -
	trap	#1	; *** GEMDOS ***

CTST_TEXT_PRT_CHANNEL:	move.w	CTST_DATA_CURR_CHANNEL,D4
CTST_TEXT_PRT_CHAN_OUT:	lea	CTST_DATA_CHAN_LST_TXT,A0
	move.w	D4,D5
	asl.l	#4,D5
	lea	(A0,D5.w),A0
	move.l	A0,-(SP)
	move.w	#9,-(SP)	; - C_CONWS -
	TRAP	#1	; *** GEMDOS ***
	addq.l	#6,SP

	RTS

; /////////////////////////////////////////////////////////////////////////////	
	SECTION	DATA
; /////////////////////////////////////////////////////////////////////////////	
	
CTST_DATA_MAIN_SCR_0:	dc.b	7,27,"E","/// CHANNEL TEST - KOSS 2001 ///",13,10
	dc.b	13,10
	dc.b	"ACTIVE CHANNEL IS :",13,10,0
	
CTST_DATA_MAIN_SCR_1:	dc.b	13,10,13,10
	dc.b	" 1 - SEND",13,10
	dc.b	" 2 - RECEIVE",13,10
	dc.b	" 3 - CHANGE CHANNEL",13,10
	dc.b	" 0 - QUIT",13,10
	dc.b	13,10
	dc.b	"CHOICE: ",0
	
CTST_DATA_SEND_SCR0:	dc.b	13,10,13,10
	dc.b	"> SENDING ON :",13,10,0
	
CTST_DATA_SEND_SCR1:	dc.b	"OUT:",0

CTST_DATA_RECEIVE_SCR0:	dc.b	13,10,13,10
	dc.b	"> RECEIVING ON :",13,10,0
	
CTST_DATA_RECEIVE_SCR1:	dc.b	"IN:",0

CTST_DATA_ESC_RETURN:	dc.b	13,10
	dc.b	" [Esc] TO RETURN AT MAIN SCREEN...",13,10
	dc.b	13,10,0

CTST_DATA_CHANGE_SCR0:	dc.b	13,10,13,10
	dc.b	"> CURRENT CHANNEL IS :",13,10,0
	
CTST_DATA_CHANGE_SCR1:	dc.b	13,10,13,10
	dc.b	"> POSSIBLE CHANNEL ARE :",13,10,0
	
CTST_DATA_CHANGE_SCR2:	dc.b	"CHANNEL:",0
	
CTST_DATA_CRLF:	dc.b	13,10,0
	
CTST_DATA_CURR_CHANNEL:	dc.w	8

CTST_DATA_CHAN_LST_TXT:	dc.b	"0-PARALLEL PORT",0
	dc.b	"1-SERIAL   PORT",0
	dc.b	"2-CONSOLE  DEV ",0
	dc.b	"3-MIDI     PORT",0
	dc.b	"4-IKBD     PORT",0
	dc.b	"5-RAWSCR   DEV ",0
	dc.b	"6-MODEM1   SER ",0
	dc.b	"7-MODEM2   SCCB",0
	dc.b	"8-LAN      SCCA",0
		
CTST_DATA_ROUT_TAB:	dc.l	CTST_TEXT_EXIT
	dc.l	CTST_TEXT_SEND
	dc.l	CTST_TEXT_RECEIVE
	dc.l	CTST_TEXT_CHANGE

; /////////////////////////////////////////////////////////////////////////////	
	SECTION	BSS
; /////////////////////////////////////////////////////////////////////////////	
