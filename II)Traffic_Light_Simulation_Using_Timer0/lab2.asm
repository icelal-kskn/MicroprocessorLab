;200316059 Ikram Celal EKSKIN
;200316011 Musa Sina ERTUGRUL

LIST P = PIC16F877A
#INCLUDE <P16F877A.INC>    
__CONFIG H'3F31'

#define RS PORTC,0 ; Lcd Data/Command
#define RW PORTC,1 ; Read/Write Data
#define EN PORTC,2 ; LCD Enable

S1      EQU 0X20    ; Delay var
S2      EQU 0X21    ; Delay var
TEMP        EQU 0X22     ; For Working Reg Back-up
CHAR        EQU 0X23    ; For Counter Display next char;
CHAR2       EQU 0X24

;First   Address--------------------------
ORG     0x00
START

CALL REG_INIT           ; Call function to initialize registers            
CALL LCD_INIT           ; Call function to initialize LCD

MOVLW   0x80
CALL    LCD_COMMAND     ; Move cursor to the start of the first line
MOVLW   0X01
CALL    LCD_COMMAND     ; Clear LCD screen

POLL
BTFSS   PORTB,0         ; Polling for a condition on PORTB, pin 0
GOTO    POLL
CALL    WRITE_COUNTER   ; Call function to write counter value to LCD
CALL    PRINT           ; Call function to print counter value
MOVLW   0X02
CALL    LCD_COMMAND     ; Move cursor to the start of the second line
GOTO    POLL            ; Continue polling

WRITE_COUNTER
MOVLW   "C"
CALL    LCD_DATA        ; Write character 'C' to LCD
CALL    SHIFT_RIGHT     ; Shift cursor to the right
MOVLW   "o"
CALL    LCD_DATA        ; Write character 'o' to LCD
CALL    SHIFT_RIGHT     ; Shift cursor to the right
MOVLW   "u"
CALL    LCD_DATA        ; Write character 'u' to LCD
CALL    SHIFT_RIGHT     ; Shift cursor to the right
MOVLW   "n"
CALL    LCD_DATA        ; Write character 'n' to LCD
CALL    SHIFT_RIGHT     ; Shift cursor to the right
MOVLW   "t"
CALL    LCD_DATA        ; Write character 't' to LCD
CALL    SHIFT_RIGHT     ; Shift cursor to the right
MOVLW   "e"
CALL    LCD_DATA        ; Write character 'e' to LCD
CALL    SHIFT_RIGHT     ; Shift cursor to the right
MOVLW   "r"
CALL    LCD_DATA        ; Write character 'r' to LCD
CALL    SHIFT_RIGHT     ; Shift cursor to the right
MOVLW   ":"
CALL    LCD_DATA        ; Write character ':' to LCD
CALL    SHIFT_RIGHT     ; Shift cursor to the right
RETURN

SHIFT_LEFT
MOVLW   0X04
CALL    LCD_COMMAND     ; Command to shift cursor left
RETURN

SHIFT_RIGHT
MOVLW   0X06
CALL    LCD_COMMAND     ; Command to shift cursor right
RETURN

;TRIS REG Initialization for PORT A B C ----------------------------------------------
REG_INIT
BANKSEL TRISC
MOVLW   B'00000001'
MOVWF   TRISB           ; Set TRISB to configure as input
CLRF    TRISC           ; Clear TRISC
CLRF    TRISD           ; Clear TRISD
BANKSEL PORTD
CLRF    PORTD           ; Clear PORTD
CLRF    PORTB           ; Clear PORTB
CLRF    CHAR            ; Clear CHAR variable
RETURN

;For Printing Char on LCD Display----------------------------------------------------
PRINT
BANKSEL CHAR
BCF     STATUS,C
MOVLW   D'10'
SUBWF   CHAR2,W
BTFSS   STATUS,C
GOTO    PRINT2
CLRF    CHAR2
PRINT2
MOVLW   "0"
ADDWF   CHAR,0
CALL    LCD_DATA        ; Print character to LCD
CALL    SHIFT_RIGHT     ; Shift cursor to the right
MOVLW   "0"
ADDWF   CHAR2,0
CALL    LCD_DATA        ; Print character to LCD
CALL    SHIFT_RIGHT     ; Shift cursor to the right
INCF    CHAR2
BCF     STATUS,C
MOVLW   D'10'
SUBWF   CHAR2,W
BTFSS   STATUS,C
RETURN
INCF    CHAR
RETURN

;For LCD Display Initialization-------------------------------------------------------
LCD_INIT
MOVLW   0X38            ; Function set: 8-bit mode, 2-line display, 5x7 font
CALL    LCD_COMMAND     ; Send command to LCD
MOVLW   0X06            ; Entry mode set: Increment cursor, no display shift
CALL    LCD_COMMAND     ; Send command to LCD
MOVLW   0X0E            ; Display control: Display on, cursor on, blink cursor off
CALL    LCD_COMMAND     ; Send command to LCD
MOVLW   0X01            ; Clear display
CALL    LCD_COMMAND     ; Send command to LCD
RETURN

;--------------------------------------------------------------------------------------
LCD_COMMAND
BCF     RS              ; Set RS pin low (command mode)
BCF     RW              ; Set RW pin low (write mode)
BSF     EN              ; Set EN pin high
MOVWF   TEMP            ; Move command to TEMP register
CALL    DELAY           ; Delay function
MOVFW   TEMP
BANKSEL PORTD
MOVWF   PORTD           ; Send command to PORTD
BCF     EN              ; Set EN pin low
RETURN

;----------------------------------------------------------------------------------
LCD_DATA
BSF     RS              ; Set RS pin high (data mode)
BCF     RW              ; Set RW pin low (write mode)
BSF     EN              ; Set EN pin high
MOVWF   TEMP            ; Move data to TEMP register
CALL    DELAY           ; Delay function
MOVFW   TEMP
BANKSEL PORTD
MOVWF   PORTD           ; Send data to PORTD
BCF     EN              ; Set EN pin low
RETURN

;------------FOR DELAY-----------
DELAY
MOVLW   0XFF
MOVWF   S1
L1
    MOVLW   0XFF
    MOVWF   S2
    L2
        DECFSZ  S2
        GOTO    L2
    DECFSZ  S1
    GOTO    L1
RETURN  

END