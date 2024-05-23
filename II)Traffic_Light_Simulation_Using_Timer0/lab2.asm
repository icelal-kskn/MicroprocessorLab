;200316059 Ikram Celal KESKIN
;200316011 Musa Sina ERTUGRUL


LIST P = PIC16F877A
#INCLUDE <P16F877A.INC>
;__CONFIG H'3F31'

;Var Def---------------------------------
T0Counter	EQU	0X25
Itr2		EQU	0X26
Itr1		EQU	0X27
Itr3		EQU	0X28

;First 	Address--------------------------
		ORG 		0x00
		GOTO 		start

;Interrupt Address-----------------------
		ORG 	0x04
		BTFSS	INTCON,TMR0IE
		GOTO	intRet
		BTFSS	INTCON,TMR0IF
		GOTO	intRet
		MOVLW	D'6'			;256-6 = 250 Step 
		MOVWF	TMR0
		BCF		INTCON,TMR0IF	; INTCON Timer Flag Cleared
		INCF	T0Counter
		
intStart
		MOVLW	D'250'			;250 x 4000 us = 1000 000 us 
		SUBWF	T0Counter,W
		BTFSS	STATUS,C		;T0Counter >= 250 ? IF then skip below instruction.
		GOTO	intRet			;Else Retrun from Interrupt
		CLRF	T0Counter		;IF T0 > 250 -> T0 = 0
		BTFSS	PORTD,2
		GOTO	threeSec
		BTFSS	PORTD,1
		GOTO	twoSec
		GOTO	oneSec
threeSec
		MOVLW 	D'3'
		INCF	Itr2
		BCF		STATUS,C
		SUBWF	Itr2,W
		BTFSS	STATUS,C
		GOTO	intRet
		GOTO	checkOthers
twoSec
		MOVLW	D'2'
		INCF	Itr2
		BCF		STATUS,C
		SUBWF	Itr2,W
		BTFSS	STATUS,C
		GOTO	threeSec
		BTFSS	PORTD,1
		GOTO	setLedYellow
		GOTO	checkOthers
oneSec
		MOVLW	D'1'
		INCF	Itr2
		BCF		STATUS,C
		SUBWF	Itr2,W
		BTFSS	STATUS,C
		GOTO	threeSec
		GOTO	setLedGreen
checkOthers
		MOVLW 	D'1'
		BCF		STATUS,C
		SUBWF	Itr3,W
		BTFSS	STATUS,C
		GOTO	setLedGreen
		MOVLW 	D'2'
		BCF		STATUS,C
		SUBWF	Itr3,W
		BTFSS	STATUS,C		;If	1. LED = 1 -> cont. to turn out LED1 & 
		GOTO	setLedYellow
		MOVLW 	D'3'
		BCF		STATUS,C
		SUBWF	Itr3,W
		BTFSS	STATUS,C
		GOTO	setLedRed
		GOTO	intRet

			;
setLedGreen	
		BCF		PORTD,2	
		BCF		PORTD,1			;Swap LED Conditions...
		BSF		PORTD,0
		CLRF	Itr2
		CLRF	Itr1
		INCF	Itr3
		GOTO	intRet
setLedYellow	
		BCF		PORTD,0			;Swap LED Conditions...
		BSF		PORTD,1
		CLRF	Itr2
		CLRF	Itr1
		BTFSS	PORTD,2
		INCF	Itr3
		GOTO	intRet
setLedRed	
		BCF		PORTD,0
		BCF		PORTD,1			;Swap LED Conditions...
		BSF		PORTD,2
		CLRF	Itr2
		CLRF	Itr1
		CLRF	Itr3
		BCF		STATUS,C
		GOTO	intRet

intRet	
		RETFIE

;Main Programm------------------------------------------------------
start	CLRF	T0Counter
		BANKSEL	TRISD
		CLRF	TRISD
		BANKSEL	OPTION_REG
		MOVLW	B'11010011'		;OPT_REG 1:16  1 x 250 x 16 = 4000 us
		MOVWF	OPTION_REG
		BANKSEL	PORTD
		CLRF	PORTD
		MOVLW	D'6'
		MOVWF	TMR0
		BSF		INTCON,TMR0IE
		BSF		INTCON,GIE
		CLRF	Itr3
		MOVLW	D'1'
		MOVWF	Itr3
		CLRF	Itr2
		MOVLW	D'0'
		MOVWF	Itr2
		CLRF	Itr1
		MOVLW	D'0'
		MOVWF	Itr1
		BSF		PORTD,0	
		BCF		PORTD,1
		BCF		PORTD,2

loop	GOTO 	loop

END