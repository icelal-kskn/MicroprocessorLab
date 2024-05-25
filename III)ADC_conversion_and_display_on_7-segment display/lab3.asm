;200316059 Ikram Celal KESKIN
;200316011 Musa Sina ERTUGRUL
    LIST P = 16F877A
    #INCLUDE <P16F877A.INC>
    __CONFIG H'3F31'

DEG     EQU     0X20
delay1  EQU     0x21
delay2  EQU     0x22
temp    EQU     0X23
ones    EQU     0X24
tens    EQU     0X25
divisor EQU     0X26

        ORG     0X00
        GOTO    start

start   
        ; port adc settings
        MOVLW   0XFF
        BANKSEL TRISA
        MOVWF   TRISA
        BANKSEL TRISB
        CLRF    TRISB
        BANKSEL TRISC
        CLRF    TRISC
        BANKSEL TRISD   
        CLRF    TRISD
        BANKSEL PORTA
        CLRF    PORTA
        BANKSEL PORTB
        CLRF    PORTB
        BANKSEL PORTC
        CLRF    PORTC
        BANKSEL PORTD
        CLRF    PORTD
        MOVLW   B'01000001' ;0X41       ADC Clock Fosc*1/8 ADON=1  
        BANKSEL ADCON0
        MOVWF   ADCON0
        BANKSEL ADCON1
        MOVLW   B'10000000' ;0X80
        MOVWF   ADCON1

loop    
        CALL    ReadADC     
        BANKSEL temp
        MOVF    ADRESH,W
        MOVWF   temp       ;high byte of ADC result to temp
        BANKSEL DEG
        MOVF    ADRESL,W
        MOVWF   DEG        ;low byte of ADC result to DEG

        ; Combine ADRESH and ADRESL to get the full 10-bit result
        BANKSEL temp
        MOVF    temp, W
        MOVWF   tens
        MOVLW   D'10'
        MOVWF   divisor
        CLRF    ones
DIVIDE_LOOP:
        SUBWF   tens, W
        BTFSS   STATUS, C
        GOTO    DONE_DIVIDE
        INCF    ones, F
        GOTO    DIVIDE_LOOP
DONE_DIVIDE:
        ADDWF   tens, F        ; restore the original value

        ; Display tens digit
        MOVF    ones, W
        CALL    table
        BANKSEL PORTC
        MOVWF   PORTC
        BSF     PORTD, 0       ; Activate first 7 segment display
        CALL    DELAY
        BCF     PORTD, 0       ; Deactivate first 7 segment display

        ; Display ones digit
        MOVF    tens, W
        CALL    table
        MOVWF   PORTC
        BSF     PORTD, 1       ; Activate second 7 segment display
        CALL    DELAY
        BCF     PORTD, 1       ; Deactivate second 7 segment display

        GOTO    loop

;------------------------------------------------------

ReadADC             
        BANKSEL ADCON0
        BSF     ADCON0,GO
read    
        BANKSEL ADCON0
        BTFSC   ADCON0,GO
        GOTO    read
        
        BANKSEL ADRESH
        MOVF    ADRESH, W
        MOVWF   temp
        BANKSEL ADRESL
        MOVF    ADRESL, W
        MOVWF   DEG
        RETURN
;-----------------------------------------------------
table   
        ADDWF   PCL
        RETLW   B'11111100' ;0
        RETLW   B'01100000' ;1
        RETLW   B'11011010' ;2
        RETLW   B'11110010' ;3
        RETLW   B'01100110' ;4
        RETLW   B'10110110' ;5
        RETLW   B'10111110' ;6
        RETLW   B'11100000' ;7
        RETLW   B'11111110' ;8
        RETLW   B'11110110' ;9

;-------------------------------------------------
DELAY:
    ;for delay
    MOVLW D'250'
DELAY_LOOP1:
    MOVWF delay1
DELAY_LOOP2:
    MOVLW D'250'
DELAY_LOOP3:
    MOVWF delay2
    NOP
    DECFSZ delay2, F
    GOTO DELAY_LOOP3
    DECFSZ delay1, F
    GOTO DELAY_LOOP2
    RETURN

    END
