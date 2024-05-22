LIST P = PIC16F877A
#INCLUDE <P16F877A.INC>	
__CONFIG H'3F31'

#define RS PORTC,0 ; Lcd Data/Command
#define RW PORTC,1 ; Read/Write Data
#define EN PORTC,2 ; LCD Enable

S1 		EQU 0X20
S2 		EQU 0X21
TEMP	EQU 0X22 
CHAR    EQU 0X23

ORG 0X00
GOTO START
;Interrupt Routine-----------
ORG 0X04
BANKSEL 	INTCON 
BCF	 		INTCON,INTF
BANKSEL 	CHAR
CALL 		PRINT
MOVLW		0X01
CALL 		LCD_COMMAND
RETFIE
;----------------------------

START
CALL REG_INIT
CALL LCD_INIT
CALL INT_INIT

MOVLW	0x80
CALL	LCD_COMMAND
MOVLW	0X01
CALL 	LCD_COMMAND


POLL GOTO 	POLL



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

PRINT
BANKSEL CHAR
MOVLW	"A"
ADDWF 	CHAR,0
CALL 	LCD_DATA
INCF	CHAR
MOVLW	D'26'
SUBWF	CHAR,0
BTFSS	STATUS,Z
GOTO	RET
CLRF	CHAR
RET
RETURN

INT_INIT
BANKSEL INTCON		 ;Interrupt Control Register
BSF		INTCON,GIE   ;Global Interrupt Enable
BSF		INTCON,INTE  ;PortB/0 change Interrupt Enable

RETURN

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
;---------------------------------
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
LCD_DATA
BSF		RS
BCF		RW
BSF		EN
MOVWF 	TEMP
CALL 	DELAY
MOVFW	TEMP
BANKSEL	PORTD
MOVWF	PORTD
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