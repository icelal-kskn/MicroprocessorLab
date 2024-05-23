;200316059 Ikram Celal KESKIN
;200316011 Musa Sina ERTUGRUL
    LIST P=16F877A
    #include <p16f877a.inc>
    
    __CONFIG _CP_OFF & _WDT_OFF & _XT_OSC & _PWRTE_ON & _BODEN_ON & _LVP_OFF

    ;----------------------
    ; De�i�ken tan�mlar�
    ;----------------------
    cblock 0x20
        temp_val   ; ADC sonucu saklama
        temp_c     ; S�cakl�k de�eri
        temp_digit ; 7-segment i�in basamak de�eri
    endc

    ;----------------------
    ; Ba�lang�� ayarlar�
    ;----------------------
    ORG 0x00
    GOTO START

    ORG 0x04
    GOTO START

START:
    ; Osilat�r frekans�n� ayarla
    bsf STATUS, RP0
    bcf STATUS, RP1

    ; ADC ayarlar�
    bsf STATUS, RP0        ; Bank 1 se�imi
    movlw 0x80             ; Configure all pins as digital I/O except AN0
    movwf ADCON1

    bcf STATUS, RP0        ; Bank 0 se�imi
    movlw 0x41             ; FOSC/8, ADON
    movwf ADCON0

    ; I/O port ayarlar�
    bsf STATUS, RP0        ; Bank 1 se�imi
    movlw 0x01             ; Configure RA0 as input (AN0)
    movwf TRISA
    movlw 0x00
    movwf TRISC            ; PORTC t�m� ��k��
    movlw 0x00
    movwf TRISD            ; PORTD t�m� ��k��

    bcf STATUS, RP0        ; Bank 0 se�imi

    ;----------------------
    ; Ana d�ng�
    ;----------------------
MAIN_LOOP:
    ; ADC d�n���m�n� ba�lat
    bsf ADCON0, GO_DONE
    call WAIT_ADC
    btfsc ADCON0, GO_DONE
    goto $-1

    ; ADC sonucu al
    movf ADRESH, W
    movwf temp_val

    ; S�cakl�k de�erini hesapla
    ; 0-1023 -> 0-100 (yakla��k 0-100�C)
    ; Referans voltaj� 5V -> her bir birim 4.88mV -> her bir birim yakla��k 0.488�C
    ; S�cakl�k = ADC De�eri * 0.488
    movf temp_val, W
    call CONVERT_ADC_TO_TEMP

    ; S�cakl�k de�erini 7-segment g�stergelere b�lme
    movf temp_c, W
    call DIVIDE_TEMPERATURE

    ; Onlar basama�� g�ster
    movf temp_digit, W
    call DISPLAY_TENS

    ; Birler basama�� g�ster
    movf temp_c, W
    call DISPLAY_ONES

    goto MAIN_LOOP

    ;----------------------
    ; ADC De�erini S�cakl��a �evirme Alt Program�
    ;----------------------
CONVERT_ADC_TO_TEMP:
    ; temp_val -> temp_c
    ; ADC de�eri * 0.488
    ; Approximate by using a shift right to divide by 2 (0.5) and further adjustments
    movf temp_val, W
    movwf temp_c
    clrc
    rrf temp_c, F   ; temp_c = temp_val / 2 (approx 0.5)
    movf temp_c, W
    return

    ;----------------------
    ; S�cakl��� Basamaklara B�lme Alt Program�
    ;----------------------
DIVIDE_TEMPERATURE:
    ; temp_c -> onlar basama�� ve birler basama��
    movlw 10
    movwf temp_digit
    movf temp_c, W
    call DIV10
    movf temp_c, W
    return

    ;----------------------
    ; Onlar Basama��n� G�sterme Alt Program�
    ;----------------------
DISPLAY_TENS:
    ; temp_digit -> PORTC
    movlw 0x3F
    andwf temp_digit, W
    movwf PORTC
    return

    ;----------------------
    ; Birler Basama��n� G�sterme Alt Program�
    ;----------------------
DISPLAY_ONES:
    ; temp_c -> PORTD
    movlw 0x3F
    andwf temp_c, W
    movwf PORTD
    return

    ;----------------------
    ; 10'a B�lme Alt Program�
    ;----------------------
DIV10:

    movwf temp_digit
    clrf temp_c
DIV10_LOOP:
    sublw 10
    btfsc STATUS, C
    goto DIV10_DONE
    incf temp_c, F
    goto DIV10_LOOP
DIV10_DONE:
    addlw 10
    movf temp_c, W
    return

WAIT_ADC:
    movlw 22
    movwf temp_digit
WAIT_ADC_LOOP:
    nop
    nop
    decfsz temp_digit, F
    goto WAIT_ADC_LOOP
    return

    END