LIST P = PIC16F877A
#INCLUDE <P16F877A.INC>
;__CONFIG H'3F31'

;Var Def---------------------------------
T0Counter	EQU	0X25

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

		MOVLW	D'250'			;250 x 4000 us = 1000 000 us 
		SUBWF	T0Counter,W
		BTFSS	STATUS,C		;T0Counter >= 250 ? IF then skip below instruction.
		GOTO	intRet			;Else Retrun from Interrupt
		CLRF	T0Counter		;IF T0 > 250 -> T0 = 0 
		BTFSS	PORTD,0			;If	1. LED = 1 -> cont. to turn out LED1 & 
		GOTO	setLed			;
		BCF		PORTD,0
		BSF		PORTD,1
		GOTO	intRet
setLed	BSF		PORTD,0			;Swap LED Conditions...
		BCF		PORTD,1

intRet	RETFIE

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

loop	GOTO 	loop

END
