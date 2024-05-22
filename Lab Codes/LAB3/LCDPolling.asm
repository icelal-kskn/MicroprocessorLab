LIST P = PIC16F877A
#INCLUDE <P16F877A.INC>	
__CONFIG H'3F31'

#define RS PORTC,0 ; Lcd Data/Command
#define RW PORTC,1 ; Read/Write Data
#define EN PORTC,2 ; LCD Enable

S1 		EQU 0X20	; Delay var
S2 		EQU 0X21	; Delay var
TEMP		EQU 0X22 	; For Working Reg Back-up
CHAR    	EQU 0X23	; For Counter Display next char;

ORG 0X00
START

CALL REG_INIT			
CALL LCD_INIT

MOVLW	0x80
CALL	LCD_COMMAND
MOVLW	0X01
CALL 	LCD_COMMAND


POLL
BTFSS	PORTB,0
GOTO	POLL
CALL 	PRINT
MOVLW	0X01
CALL 	LCD_COMMAND
GOTO 	POLL


;TRIS REG Initialization for PORT A B C ----------------------------------------------
REG_INIT
BANKSEL TRISC
MOVLW   B'00000001'
MOVWF	TRISB
CLRF	TRISC
CLRF	TRISD
BANKSEL PORTD
CLRF	PORTD
CLRF	PORTB
CLRF 	CHAR
RETURN
;For Printing Char on LCD Display----------------------------------------------------
PRINT
BANKSEL CHAR
MOVLW	"A"
ADDWF 	CHAR,0
CALL 	LCD_DATA
INCF	CHAR
RETURN
;For LCD Display Initialization-------------------------------------------------------
LCD_INIT
MOVLW	0X38			
CALL 	LCD_COMMAND
MOVLW 	0X06
CALL	LCD_COMMAND
MOVLW	0X0E
CALL	LCD_COMMAND
MOVLW	0X01
CALL 	LCD_COMMAND
RETURN
;--------------------------------------------------------------------------------------
LCD_COMMAND
BCF		RS
BCF		RW
BSF		EN
MOVWF 	TEMP
CALL 	DELAY
MOVFW	TEMP
BANKSEL	PORTD
MOVWF	PORTD
BCF		EN
RETURN
;----------------------------------------------------------------------------------
LCD_DATA
BSF		RS
BCF		RW
BSF		EN
MOVWF 		TEMP
CALL 		DELAY
MOVFW		TEMP
BANKSEL		PORTD
MOVWF		PORTD
BCF		EN
RETURN
;------------FOR DELAY-----------
DELAY
MOVLW 0XFF
MOVWF S1
L1
	MOVLW 0XFF
	MOVWF S2
	L2
		DECFSZ S2
		GOTO   L2
	DECFSZ S1
	GOTO   L1
RETURN	

END