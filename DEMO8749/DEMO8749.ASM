;	DEMO8749 - MCS8749 PROGRAMING EXAMPLES
;	WRITTEN BY TETSUYA SUZUKI
;	MIT LICENSE
;
;	SEGMENT DEFINITION (MACHINE-DEPENDENT)
SEGA	EQU	01111111B
SEGB	EQU	10111111B
SEGC	EQU	11110111B
SEGD	EQU	11111110B
SEGE	EQU	11111011B
SEGF	EQU	11011111B
SEGG	EQU	11101111B
SEGP	EQU	11111101B
;
;	NUMERIC IMAGE
FON0	EQU	SEGA&SEGB&SEGC&SEGD&SEGE&SEGF
FON1	EQU	SEGB&SEGC
FON2	EQU	SEGA&SEGB&SEGD&SEGE&SEGG
FON3	EQU	SEGA&SEGB&SEGC&SEGD&SEGG
FON4	EQU	SEGB&SEGC&SEGF&SEGG
FON5	EQU	SEGA&SEGC&SEGD&SEGF&SEGG
FON6	EQU	SEGA&SEGC&SEGD&SEGE&SEGF&SEGG
FON7	EQU	SEGA&SEGB&SEGC
FON8	EQU	SEGA&SEGB&SEGC&SEGD&SEGE&SEGF&SEGG
FON9	EQU	SEGA&SEGB&SEGC&SEGD&SEGF&SEGG
FONA	EQU	SEGA&SEGB&SEGC&SEGE&SEGF&SEGG
FONB	EQU	SEGC&SEGD&SEGE&SEGF&SEGG
FONC	EQU	SEGA&SEGD&SEGE&SEGF
FOND	EQU	SEGB&SEGC&SEGD&SEGE&SEGG
FONE	EQU	SEGA&SEGD&SEGE&SEGF&SEGG
FONF	EQU	SEGA&SEGE&SEGF&SEGG
FONN	EQU	0FFH
;
;	UPPER HALF IMAGE
TOP0	EQU	SEGC&SEGE&SEGG
TOP1	EQU	SEGC
TOP2	EQU	SEGC&SEGD&SEGG
TOP3	EQU	SEGC&SEGD&SEGG
TOP4	EQU	SEGC&SEGD&SEGE
TOP5	EQU	SEGD&SEGE&SEGG
TOP6	EQU	SEGD&SEGE&SEGG
TOP7	EQU	SEGC&SEGG
TOP8	EQU	SEGC&SEGD&SEGE&SEGG
TOP9	EQU	SEGC&SEGD&SEGE&SEGG
TOPA	EQU	SEGC&SEGD&SEGE&SEGG
TOPB	EQU	SEGD&SEGE
TOPC	EQU	SEGE&SEGG
TOPD	EQU	SEGD&SEGE
TOPE	EQU	SEGD&SEGE&SEGG
TOPF	EQU	SEGD&SEGE&SEGG
;
;	LOWER HALF IMAGE
BOT0	EQU	SEGB&SEGF&SEGG
BOT1	EQU	SEGB
BOT2	EQU	SEGA&SEGF&SEGG
BOT3	EQU	SEGA&SEGB&SEGG
BOT4	EQU	SEGA&SEGB
BOT5	EQU	SEGA&SEGB&SEGG
BOT6	EQU	SEGA&SEGB&SEGF&SEGG
BOT7	EQU	SEGB
BOT8	EQU	SEGA&SEGB&SEGF&SEGG
BOT9	EQU	SEGA&SEGB&SEGG
BOTA	EQU	SEGA&SEGB&SEGF
BOTB	EQU	SEGA&SEGB&SEGF&SEGG
BOTC	EQU	SEGF&SEGG
BOTD	EQU	SEGA&SEGB&SEGF&SEGG
BOTE	EQU	SEGA&SEGF&SEGG
BOTF	EQU	SEGA&SEGF
;
;	RESET VECTOR
	ORG	00H
	JMP	INIT	; JUMP MAIN ROUTINE
;
;	EXTERNAL INTERRUPT VECTOR
	ORG	03H
	RETR		; DO NOTHING
;
;	TIMER INTERRUPT VECTOR
	ORG	07H
	JMP	TINT
;
;	DELY
;	WAIT UNTIL TICK COUNTS MATCH
;	R2: TICK COUNT (INCREMENTED BY 45Hz)
DLAY:	MOV	R0,#TICK; TICK POINTER
	MOV	@R0,#00H; CLEAR TICK
L002	MOV	A,R2	; GET PARAM
	CALL	PTON	; CONVERT TO NEGATIVE
	ADD	A,@R0	; SAME AS SUBTRACTION
	JNC	L002	; WAIT FOR TICK > R2
	RETR
;
;	PTON
;	CONVERT POSITIVE TO NEGATIVE
;	A: NUMERIC
PTON:	CPL	A	; CONVERT STEP1
	INC	A	; CONVERT STEP2
	RETR
;
;	BADD
;	BINARY ADDITION
;	R1: 2 BYTES AUGEND POINTER
;	R2: ADDEND
BADD:	MOV	A,R2
	ADD	A,@R1
	MOV	@R1,A
	JNC	L014
	DEC	R1
	INC	@R1
L014	RETR
;
;	BSUB
;	BINARY SUBTRACTION
;	R1: 2 BYTES MINUEND POINTER
;	R2: SUBTRAHEND
BSUB:	MOV	A,R2
	CALL	PTON
	ADD	A,@R1
	MOV	@R1,A
	JC	L015
	DEC	R1
	MOV	A,@R1
	DEC	A
	MOV	@R1,A
L015	RETR
;
;	DADD
;	DECIMAL ADDITION
;	R1: LOWER OF 2 BYTES AUGEND POINTER
;	R2: ADDEND
DADD:	MOV	A,R2	; GET ADDEND
	ADD	A,@R1	; ADD LOWER AUGEND
	DA	A	; DECIMAL ADJUST
	MOV	@R1,A	; STORE RESULT
	JNC	L011	; IF NOT CARRY, RETURN
	DEC	R1	; UPPER BYTE
	MOV	A,#1	; GET 1
	ADD	A,@R1	; ADD UPPER AUGEND
	DA	A	; DECIMAL ADJUST
	MOV	@R1,A	; STORE RESULT
L011	RETR
;
;	DSUB
;	DECIMAL SUBTRACTION
;	R1: LOWER OF 2 BYTES MINUEND POINTER
;	R2: SUBTRAHEND
DSUB:	MOV	A,R2	; GET SUBTRAHEND
	CALL	PTON	; CONVERT POSITIVE TO NEGATIVE
	ADD	A,#9AH	; ADD MAGIC NUMBER
	ADD	A,@R1	; SUBTRACT LOWER MINUEND
	DA	A	; DECIMAL ADJUST
	MOV	@R1,A	; STORE RESULT
	JC	L013	; IF CARRY, RETURN
	DEC	R1	; UPPER BYTE
	MOV	A,#99H	; MAGIC NUMBER
	ADD	A,@R1	; ADD UPPER MINUEND
	DA	A	; DECIMAL ADJUST
	MOV	@R1,A	; STORE RESULT
L013	RETR
;
;	DCHG
;	DISPLAY CHANGE BY TEMPORARY IMAGE
DCHG:	MOV	R0,#TIMG; TEMPORARY IMAGE POINTER
	MOV	R1,#VRAM; VRAM BASE ADDRESS
	MOV	R7,#4	; DIGIT COUNTER (4 TO 1)
	MOV	A,R6	; COPY STEP 1
	MOV	R5,A	; COPY STEP 2
L005	MOV	A,R5	; GET UPDATE FLAG
	RRC	A	; CHECK LSB
	MOV	R5,A	; SAVE FOR NEXT
	JNC	L006	; IF LSB=0, DO NOTHING
	MOV	A,@R0	; GET TEMPORARY IMAGE
	MOV	@R1,A	; SAVE IT VRAM
L006	INC	R0	; NEXT TEMPORARY IMAGE
	INC	R1	; NEXT VRAM ADDRESS
	DJNZ	R7,L005	; LOOP DIGIT 4 TO 1
	RETR
;
;	PUTN
;	DISPLAY NUMERIC
PUTN:	MOV	R0,#VRAM	; VRAM POINTER
	MOV	R1,#NNOW	; NUMERIC POINTER
	MOV	R2,#FTBL	; FONT TABLE
	MOV	R3,#TPNC	; COMMAND TABLE
;
;	NTOI
;	NUMERIC TO IMAGE
NTOI:	MOV	R7,#4	; DIGIT COUNTER (4 TO 1)
L007	CALL	BREN	; BRANCH COMMAND FOR EACH NIBBLE
	ANL	A,#0FH	; GET DIGIT NUMBER
	ADD	A,R2	; FONT TABLE LOOKUP
	MOVP3	A,@A	; GET FONT
	MOV	@R0,A	; STORE FONT
	INC	R0	; NEXT DIGIT
	DJNZ	R7,L007	; LOOP
	RETR
;
;	BREN
;	BRANCH COMMAND FOR EACH NIBBLE
BREN:	MOV	A,R7	; GET DIGIT
	ANL	A,#01H	; UPPER OR LOWER NIBBLE?
	ADD	A,R3	; COMMAND TABLE SETUP
	JMPP	@A	; JUMP SUB COMMAND
;
;	PUTN SUB COMMAND VECTOR TABLE
TPNC	DB	PNC1	; UPPER NIBBLE
	DB	PNC2	; LOWER NIBBLE
;
;	FOR UPPER NIBBLE
PNC1:	MOV	A,@R1	; GET BYTE
	SWAP	A	; SWAP NIBBLE
	RETR		; BACK
;
;	FOR LOWER NIBBLE
PNC2:	MOV	A,@R1	; GET BYTE
	INC	R1	; NEXT BYTE
	RETR		; BACK
;
;	PUTS
;	CHANGE DISPLAY WITH ANIMATION
PUTS:	MOV	R0,#NNEW; NEW NUMBER
	MOV	R1,#NNOW; CURRENT NUMBER
	MOV	R3,#TPSC; COMMAND TABLE
;
;	SETUP UPDATE FLAG TO R6
	MOV	R6,#00H	; CLEAR FLAGS
	MOV	R7,#4	; DIGIT COUNTER (4 TO 1)
L003	MOV	A,R6	; ROTATE RIGHT STEP1
	RR	A	; ROTATE RIGHT STEP2
	MOV	R6,A	; ROTATE RIGHT STEP3
	CALL	BREN	; BRANCH COMMAND FOR EACH NIBBLE
	ANL	A,#0FH	; GET COMPARE RESULT
	JZ	L004	; IF EQUAL, DO NOTHING
	MOV	A,R6	; BIT SET STEP1
	ORL	A,#08H	; BIT SET STEP2
	MOV	R6,A	; BIT SET STEP3
L004	DJNZ	R7,L003	; LOOP DIGIT 4 TO 1
;
;	FLAME OUT
	MOV	R0,#TIMG; TEMPORARY IMAGE POINTER
	MOV	R1,#NNOW; NUMERIC POINTER
	MOV	R2,#LTBL; FONT TABLE POINTER
	MOV	R3,#TPNC; COMMAND TABLE
	CALL	NTOI	; SETUP TEMPORARY IMAGE
	CALL	DCHG	; DISPLAY CHANGE BY TEMPORARY IMAGE
	MOV	R2,#4	; FOR 4/45 SEC,
	CALL	DLAY	; MAINTAIN DISPLAY
;
;	BLANK
	MOV	R7,#4
	MOV	R1,#VRAM; VRAM BASE ADDRESS
	MOV	A,R6	; COPY STEP 1
	MOV	R5,A	; COPY STEP 2
L008	MOV	A,R5	; GET UPDATE FLAG
	RRC	A	; CHECK LSB
	MOV	R5,A	; SAVE FOR NEXT
	JNC	L012	; IF LSB=0, DO NOTHING
	MOV	@R1,#FONN	; BLANK
L012	INC	R1	; NEXT DIGIT
	DJNZ	R7,L008	; LOOP DIGIT 4 TO 1
	MOV	R2,#8	; FOR 8/45 SEC,
	CALL	DLAY	; MAINTAIN DISPLAY
;
;	FLAME IN
	MOV	R0,#TIMG; TEMPORARY IMAGE POINTER
	MOV	R1,#NNEW; NEW NUMBER  POINTER
	MOV	R2,#UTBL; FONT TABLE POINTER
	MOV	R3,#TPNC; COMMAND TABLE
	CALL	NTOI	; SETUP TEMPORARY IMAGE
	CALL	DCHG	; DISPLAY CHANGE BY TEMPORARY IMAGE
	MOV	R2,#4	; FOR 4/45 SEC,
	CALL	DLAY	; MAINTAIN DISPLAY
;
;	UPDATE NUMERIC
UPDN:	MOV	R0,#NNOW; CURRENT NUMERIC POINTER
	MOV	R1,#NNEW; UPDATE NUMERIC POINTER
	MOV	A,@R1	; GET UPDATE NUMERIC
	MOV	@R0,A	; PUT CURRENT NUMERIC
	INC	R0	; NEXT BYTE
	INC	R1	; NEXT BYTE
	MOV	A,@R1	; GET UPDATE NUMERIC
	MOV	@R0,A	; PUT CURRENT NUMERIC
	CALL	PUTN	; DISPLAY NUMERIC
	RETR
;
;	PUTS SUB COMMAND VECTOR TABLE
TPSC	DB	PSC1 	; UPPER NIBBLE
	DB	PSC2 	; LOWER NIBBLE
;
;	FOR UPPER NIBBLE
PSC1:	MOV	A,@R0	; GET NEW NUMBER
	XRL	A,@R1	; COMPARE CURRENT NUMBER
	MOV	R2,A	; SAVE RESULT
	SWAP	A	; SWAP NIBBLE
	RETR		; BACK
;
;	FOR LOWER NIBBLE
PSC2:	MOV	A,R2	; RESTORE COMPARE RESULT
	INC	R0	; NEXT BYTE
	INC	R1	; NEXT BYTE
	RETR		; BACK
;
;	MAIN ROUTINE
	ORG	100H
INIT:	ANL	P2,#0FH	; TURN OFF ALL DIGIT
	STOP	TCNT	; STOP TIMER
	NOP		; CLEAR TIMER FLAG
;
	SEL	RB1	; SELECT SUB RESISTER BANK
	MOV	R0,#TICK; SET TICK POINTER
	MOV	R7,#0	; INITIAL DIGIT NUMBER
	SEL	RB0	; RESTORE RESISTER BANK
;
	EN	TCNTI	; ENABLE TIMER INTERRUPT
	STRT	T	; START TIMER
;
;	INITIAL DISPLAY
	MOV	R1,#NNOW; CURRENT NUMERIC POINTER
	MOV	@R1,#87H; SET 87H
	INC	R1	; NEXT DIGIT
	MOV	@R1,#49H; SET 49H
	CALL	PUTN	; DISPLAY CURRENT NUMERIC
	MOV	R2,#45	; FOR 45/45 SEC,
	CALL	DLAY	; MAINTAIN DISPLAY
;
;	COUNT UP/DOWN
	MOV	R1,#NNEW; UPDATE NUMERIC POINTER
	MOV	@R1,#00H; SET 0
	INC	R1	; NEXT DIGIT
	MOV	@R1,#00H; SET 0
	CALL	UPDN	; UPDATE NUMERIC
TEST:	CALL	DLAY	; MAINTAIN DISPLAY
	MOV	R1,#NNEW+1	; LOWER OF 2 BYTES POINTER
	MOV	R2,#5	; COUNT STEP
	JNT0	L016	; IF T0 PUSHED, JUMP
	MOV	R2,#1	; COUNT STEP
	JNT1	L017	; IF T1 PUSHED, JUMP
;
	CALL	BLINK	; 8243 P5/BIT1 CONTROL
	CALL	DADD	; DECIMAL ADDITION
	CALL	PUTS	; CHANGE DISPLAY WITH ANIMATION
	MOV	R2,#45	; FOR 45/45 SEC,
	JMP	TEST
L016	CALL	DADD	; DECIMAL ADDITION
	CALL	UPDN	; UPDATE NUMERIC
	MOV	R2,#1	; FOR 1/45 SEC,
	JMP	TEST
L017	CALL	DSUB	; DECIMAL SUBTRACTION
	CALL	UPDN	; UPDATE NUMERIC
	MOV	R2,#5	; FOR 5/45 SEC,
	JMP	TEST
;
;	8243 P5/BIT1 CONTROL
BLINK:	MOV	A,@R1	; GET UPDATE NUMERIC
	ANL	A,#01H	; CHECK EVEN/ODD
	JZ	L018	; SKIP IF EVEN (IT MEANS NOW ODD)
	MOV	A,#02H	; LED OFF
	ORLD	P5,A	; WRITE P5
	RETR
L018	MOV	A,#0DH	; LED ON
	ANLD	P5,A	; WRITE P5
	RETR
;
;	TIMER INTERRUPT SERVICE ROUTINE
;	DISPLAY VRAM IMAGE, AND COUNT UP TICK
TINT:	SEL	RB1	; SELECT SUB RESISTER BANK
	MOV	A,#03H	; USE LOWER 2 BITS
	ANL	A,R7	; GET DIGIT NUMBER(0-3)
	MOV	R7,A	; SAVE DIGIT NUMBER
	JNZ	L001	; ONCE PER 4 TIMES,
	INC	@R0	; INCREMENT TICK
;
L001	MOV	R1,#VRAM; VRAM BASE ADDRESS
	ADD	A,R1	; VRAM DIGIT POINTER
	MOV	R1,A	; SET IT TO R1
;
	ANL	P2,#0FH	; TURN OFF ALL DIGIT
	MOV	A,@R1	; GET SEGMENT IMAGE
	OUTL	P1,A	; SET SEGMENT
	MOV	A,R7	; RESTORE DIGIT NUMBER
	ADD	A,#DTBL&0FFH	; DIGIT CONTROLL BASE ADDRESS
	MOVP3	A,@A	; GET DIGIT CONTROL
	OUTL	P2,A	; DIGIT ON
;
	MOV	A,T	; GET TIMER COUNT
	ADD	A,#204	; 180Hz, FOR SOME REASON
	MOV	T,A	; SET TIMER COUNT
	INC	R7	; INCREMENT DIGIT FOR NEXT TIME
	RETR		; EXIT INTERRUPT
;
	ORG	300H
;	DIGIT CONTROLL TABLE
DTBL	DB	80H,40H,20H,10H
;
;	SEGMENT IMAGE TABLE
LTBL	DB	BOT0, BOT1, BOT2, BOT3
	DB	BOT4, BOT5, BOT6, BOT7
	DB	BOT8, BOT9, BOTA, BOTB
	DB	BOTC, BOTD, BOTE, BOTF
UTBL	DB	TOP0, TOP1, TOP2, TOP3
	DB	TOP4, TOP5, TOP6, TOP7
	DB	TOP8, TOP9, TOPA, TOPB
	DB	TOPC, TOPD, TOPE, TOPF
FTBL	DB	FON0, FON1, FON2, FON3
	DB	FON4, FON5, FON6, FON7
	DB	FON8, FON9, FONA, FONB
	DB	FONC, FOND, FONE, FONF
;
;	VARIABLES (RAM)
	ORG	20H
TICK	DS	1	; INCREMENT 45/SEC
VRAM	DS	4	; IMAGE
TIMG	DS	4	; TEMPORARY IMAGE
NNOW	DS	2	; NUMERIC
NNEW	DS	2	; NUMERIC FOR UPDATE
;
	END