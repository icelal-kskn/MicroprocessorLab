LIST P = 16F877A
#INCLUDE <P16F877A.INC>


delay1 EQU 0x20
delay2 EQU 0x21
index  EQU 0X22

ORG 0X00
GOTO MAIN

MAIN
BANKSEL TRISB
CLRF	TRISD
BANKSEL PORTD
CLRF	PORTD
;-------------------------------------------------


CLRF 	index
LOOP
MOVFW	index
CALL    table
movwf	PORTD
CALL 	DELAY
INCF    index
GOTO	LOOP	

;-------------------------------------------------
DELAY
MOVLW	0XFF
MOVWF   delay1	
WAIT
	MOVLW 0XFF
	MOVWF delay2 	
 	WAIT2
		DECFSZ delay2 
		GOTO WAIT2	 
	DECFSZ delay1	 
	GOTO WAIT		  
RETURN	

table 	addwf PCL
      	retlw B'11111100' ;0
	  	retlw B'01100000' ;1
	  	retlw B'11011010' ;2
	  	retlw B'11110010' ;3
	  	retlw B'01100110' ;4
		retlw B'10110110' ;5
		retlw B'10111110' ;6
		retlw B'11100000' ;7
		retlw B'11111110' ;8
		retlw B'11110110' ;9	

END
