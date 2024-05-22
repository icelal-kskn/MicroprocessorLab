;200316059 Ikram Celal KESKIN
;200316011 Musa Sina ERTUGRUL

    LIST P=16F877A
    #include <p16f877a.inc>
    
    __CONFIG _CP_OFF & _WDT_OFF & _XT_OSC & _PWRTE_ON & _BODEN_ON & _LVP_OFF

    ;----------------------
    ; Deðiþken tanýmlarý
    ;----------------------
    cblock 0x20
        temp_val   ; ADC sonucu saklama
        temp_c     ; Sýcaklýk deðeri
        temp_digit ; 7-segment için basamak deðeri
    endc

    ;----------------------
    ; Baþlangýç ayarlarý
    ;----------------------
    ORG 0x00
    GOTO START

    ORG 0x04
    GOTO START

START:
    ; Osilatör frekansýný ayarla
    bsf STATUS, RP0
    bcf STATUS, RP1

    ; ADC ayarlarý
    bsf STATUS, RP0        ; Bank 1 seçimi
    movlw 0x01
    movwf ADCON1           ; AN0 analog, diðerleri dijital

    bcf STATUS, RP0        ; Bank 0 seçimi
    movlw 0xC1             ; FOSC/32, ADON
    movwf ADCON0

    ; I/O port ayarlarý
    bsf STATUS, RP0        ; Bank 1 seçimi
    movlw 0x00
    movwf TRISA            ; PORTA tümü giriþ
    movlw 0x00
    movwf TRISC            ; PORTC tümü çýkýþ
    movlw 0x00
    movwf TRISD            ; PORTD tümü çýkýþ

    bcf STATUS, RP0        ; Bank 0 seçimi

    ;----------------------
    ; Ana döngü
    ;----------------------
MAIN_LOOP:
    ; ADC dönüþümünü baþlat
    bsf ADCON0, GO_DONE
    btfsc ADCON0, GO_DONE
    goto $-1

    ; ADC sonucu al
    movf ADRESH, W
    movwf temp_val

    ; Sýcaklýk deðerini hesapla
    ; 0-1023 -> 0-100 (yaklaþýk 0-100°C)
    ; Referans voltajý 5V -> her bir birim 4.88mV -> her bir birim yaklaþýk 0.488°C
    ; Sýcaklýk = ADC Deðeri * 0.488
    movf temp_val, W
    call CONVERT_ADC_TO_TEMP

    ; Sýcaklýk deðerini 7-segment göstergelere bölme
    movf temp_c, W
    call DIVIDE_TEMPERATURE

    ; Onlar basamaðý göster
    movf temp_digit, W
    call DISPLAY_TENS

    ; Birler basamaðý göster
    movf temp_c, W
    call DISPLAY_ONES

    goto MAIN_LOOP

    ;----------------------
    ; ADC Deðerini Sýcaklýða Çevirme Alt Programý
    ;----------------------
CONVERT_ADC_TO_TEMP:
    ; temp_val -> temp_c
    ; ADC deðeri * 0.488
    movlw .2
    mulwf temp_val, F
    movf PRODH, W
    movwf temp_c
    return

    ;----------------------
    ; Sýcaklýðý Basamaklara Bölme Alt Programý
    ;----------------------
DIVIDE_TEMPERATURE:
    ; temp_c -> onlar basamaðý ve birler basamaðý
    movlw 10
    movwf temp_digit
    divwf temp_c, F
    movf temp_digit, W
    movwf temp_digit
    return

    ;----------------------
    ; Onlar Basamaðýný Gösterme Alt Programý
    ;----------------------
DISPLAY_TENS:
    ; temp_digit -> PORTC
    movlw 0x3F
    andwf temp_digit, W
    movwf PORTC
    return

    ;----------------------
    ; Birler Basamaðýný Gösterme Alt Programý
    ;----------------------
DISPLAY_ONES:
    ; temp_c -> PORTD
    movlw 0x3F
    andwf temp_c, W
    movwf PORTD
    return

    END