;200316059 Ikram Celal KESKIN
;200316011 Musa Sina ERTUGRUL
LIST P=16F877A
#INCLUDE <P16F877A.INC>
__CONFIG H'3F31'

DEG      EQU 0x20
decimal  EQU 0x21
tens     EQU 0x22
ones     EQU 0x23  

ORG      0x00
GOTO     start

start
    MOVLW   0xFF
    BANKSEL TRISA
    MOVWF   TRISA   ; Set all PORTA pins as input (ADC input)
    CLRF    TRISB   ; Set all PORTB pins as output
    CLRF    TRISC   ; Set all PORTC pins as output
    CLRF    TRISD   ; Set all PORTD pins as output
    BANKSEL PORTA
    CLRF    PORTB   ; Clear PORTB
    CLRF    PORTC   ; Clear PORTC
    CLRF    PORTD   ; Clear PORTD
    MOVLW   B'01000001'  ; Configure ADCON0: ADC Clock Fosc/8, ADON=1
    MOVWF   ADCON0
    BANKSEL ADCON1
    MOVLW   B'10000000'  ; Configure ADCON1: Right justified, VREF=VDD
    MOVWF   ADCON1

loop
    CALL    ReadADC        
    BANKSEL PORTB
    MOVFW   ADRESH
    MOVWF   PORTB  ; Move ADC result to PORTB
    CALL    Degree
    GOTO    loop

;------------------------------------------------------

ReadADC
    BANKSEL ADCON0
    BSF     ADCON0, GO
read
    BTFSC   ADCON0, GO  ; Wait for ADC conversion to complete
    GOTO    read
        
    BANKSEL ADRESH
    MOVFW   ADRESH  ; Move high byte of ADC result to W
RETURN

;-----------------------------------------------------
Degree
    MOVFW   ADRESH
    MOVWF   DEG
    MOVLW   0x0A
    CALL    TensOnesDeclare
RETURN

;----------------------------------------------------
TensOnesDeclare
    BANKSEL DEG
    MOVF    DEG, W
    MOVWF   decimal
    CLRF    tens
    CLRF    ones

countTens
    SUBLW   10
    BTFSS   STATUS, C  ; If result is negative, end loop
    GOTO    doneTens
    INCF    tens, F
    MOVWF   decimal
    GOTO    countTens

doneTens
    MOVF    decimal, W
    MOVWF   ones

showSevenSeg
    MOVF    tens, W
    CALL    table
    BANKSEL PORTC
    MOVWF   PORTC  ; Display tens on PORTC
    MOVF    ones, W
    CALL    table
    BANKSEL PORTD
    MOVWF   PORTD  ; Display ones on PORTD
RETURN

;---------------------------------------------------
table
    addwf   PCL
    retlw   B'11111100' 
    retlw   B'01100000' 
    retlw   B'11011010' 
    retlw   B'11110010' 
    retlw   B'01100110' 
    retlw   B'10110110' 
    retlw   B'10111110' 
    retlw   B'11100000' 
    retlw   B'11111110' 
    retlw   B'11110110' 

END
