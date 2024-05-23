LIST P = 16F877A
#INCLUDE <P16F877A.INC>
__CONFIG H'3F31'

DEG		EQU		0X20
delay1 	EQU 	0x21
delay2 	EQU 	0x22

		ORG		0X00
		GOTO	start

start	MOVLW	0XFF
		BANKSEL	TRISA
		MOVWF	TRISA
		CLRF	TRISB
		CLRF	TRISC
		CLRF	TRISC
		CLRF	TRISD	
		BANKSEL	PORTA
		CLRF	PORTB
		CLRF	PORTC
		MOVLW	B'01000001'	;0X41		ADC Clock Fosc*1/8 ADON=1	
		MOVWF	ADCON0
		BANKSEL	ADCON1
		MOVLW	B'10000000'	;0X80
		MOVWF	ADCON1


loop	CALL	ReadADC		
		BANKSEL	PORTB
		MOVWF	PORTB
		MOVFW	ADRESH
		MOVWF	PORTC
		CALL	LED_CON

		GOTO	loop
;------------------------------------------------------

ReadADC				
		BANKSEL	ADCON0
		BSF		ADCON0,GO
read	BTFSC	ADCON0,GO
		GOTO	read
		
		BANKSEL	ADRESH
		RRF		ADRESH,F
		BANKSEL	ADRESL
		RRF		ADRESL,W
RETURN
;-----------------------------------------------------
LED_CON
			MOVFW	PORTB
			MOVWF	DEG
			MOVLW	0X05	
SUB			SUBWF	DEG,1
			BTFSC	STATUS,Z
			GOTO	LED_ON
			BTFSC	STATUS,C
			GOTO	SUB
			BCF	PORTD,0	
			RETURN
LED_ON		BSF		PORTD,0
			RETURN
	

		END	