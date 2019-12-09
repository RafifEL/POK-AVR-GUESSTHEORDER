.include "m8515def.inc"

.def temp =r16	; Define temporary variable
.def temp5 = r17;
.def temp6 = r22;
.def temp4 =r20 ;

.def temp1 =r21	; USED For Loop

.def temp2 =r19	;

.def key = r18 ; KeyPad Output

.def value1 = r9
.def value2 = r10

;PORT A For LCD EN, RS, RW
;PORT B For LCD output
;PORT C For KeyPad
;PORT D For Interrupt
;PORT E For LED

.equ ARRAY = $60	;Starting Array
.equ LAST_LED = 0b10000000

.org $00
rjmp MAIN
.org $01
rjmp ext_int0

.include "lcd_output.asm"

MAIN:

INIT_STACK:
	ldi temp, low(RAMEND)
	out SPL, temp
	ldi temp, high(RAMEND)
	out SPH, temp

INIT_LCD_CALL:
	.include "init_lcd.asm"

INIT_INTERRUPT:
	ldi temp,0b00000010
	out MCUCR,temp
	ldi temp,0b01000000
	out GICR,temp
	sei

INIT_LED:
	ser temp ; load $FF to temp
	out DDRE,temp ; Set PORTA to output
	ldi temp, 0x00
	out PORTE, temp

INIT_Z_POINTER_USER_INPUT:
	ldi ZH,high(2*input_user_message) ; Load high part of byte address into ZH
	ldi ZL,low(2*input_user_message) ; Load low part of byte address into ZL
	rjmp ASK_USER_INPUT_PROMPT

INIT_Z_POINTER_MUCH_SWITCH:
	ldi ZH,high(2*input_user_random_message) ; Load high part of byte address into ZH
	ldi ZL,low(2*input_user_random_message) ; Load low part of byte address into ZL
	ret

INIT_Z_POINTER_START_GUESS:
	ldi ZH,high(2*good_luck_prompt) ; Load high part of byte address into ZH
	ldi ZL,low(2*good_luck_prompt) ; Load low part of byte address into ZL
	ret

GET_SPACE:
	ldi temp, 32
	ret

ASK_USER_INPUT_PROMPT:
	lpm
	
	tst r0;
	breq NEW_LINE_USER_INPUT

	mov temp, r0 ; Put the character into Port B
	rcall WRITE_TEXT

	adiw ZL,1 ; Increase Z registers
	rjmp ASK_USER_INPUT_PROMPT

NEW_LINE_USER_INPUT:
	rcall MOVE_BOTTOM_LCD
	rjmp PROGRAM_EX

;LOOP Pertama Minta Urutan Angka (Zero Indexing)
PROGRAM_EX:
	ldi temp1, 8
	rcall INIT_LOOP

LOOP1_INPUT:
	tst temp1
	breq ASK_MUCH_SWITCH_PROMPT

	rcall KEYPAD

	mov temp, key 	; Put number in decimal to temp
	SUBI temp, -48	; converting temp to ascii
	rcall WRITE_TEXT

	rcall GET_SPACE
	rcall WRITE_TEXT
	
	st Y+, key

	subi temp1, 1
	rjmp LOOP1_INPUT

ASK_MUCH_SWITCH_PROMPT:
	rcall CLEAR_LCD
	rcall INIT_Z_POINTER_MUCH_SWITCH
	rjmp ASK_MUCH_SWITCH_PROMPT_LCD

ASK_MUCH_SWITCH_PROMPT_LCD:
	lpm
	
	tst r0;
	breq NEW_LINE_MUCH_SWITCH

	mov temp, r0 ; Put the character into Port B
	rcall WRITE_TEXT

	adiw ZL,1
	rjmp ASK_MUCH_SWITCH_PROMPT_LCD

NEW_LINE_MUCH_SWITCH:
	rcall MOVE_BOTTOM_LCD
	rjmp ASK_MUCH_SWITCH

ASK_MUCH_SWITCH:
	rcall KEYPAD
	tst key
	breq ASK_MUCH_SWITCH
	cpi key, 0xF0
	breq ASK_MUCH_SWITCH

	mov temp1, key
	mov temp, key
	subi temp, -48 	;Convert to Ascii
	rcall WRITE_TEXT 

SWITCH_PLACE:
	tst temp1
	breq START_GUESS_PROMPT	
	
	rcall CLEAR_LCD
	rcall INIT_LOOP
	;First Number
	rcall INPUT_SWITCH
	;Write on LCD
	mov temp, key
	subi temp, -48
	rcall WRITE_TEXT
	
	rcall GET_SPACE
	rcall WRITE_TEXT
	;mov temp6, key
	;rcall INC_YPOINTER
	add YL, key
	ld value1, Y
	
	rcall SECONDARY_POINTER
	;Second Number
	rcall INPUT_SWITCH
	;Write on LCD
	mov temp, key
	subi temp, -48
	rcall WRITE_TEXT
	
	rcall GET_SPACE
	rcall WRITE_TEXT
	;mov temp6, key
	;rcall INC_XPOINTER
	add XL, key
	ld value2, X
	
	;Switching Order
	st Y, value2
	st X, value1

	subi temp1, 1
	rjmp SWITCH_PLACE

START_GUESS_PROMPT:
	rcall CLEAR_LCD
	rcall INIT_Z_POINTER_START_GUESS
	rjmp START_GUESS_PROMPT_LCD

START_GUESS_PROMPT_LCD:
	lpm
	
	tst r0;
	breq GUESS_PROMPT

	mov temp, r0 ; Put the character into Port B
	rcall WRITE_TEXT

	adiw ZL,1 ; Increase Z registers
	rjmp START_GUESS_PROMPT_LCD

GUESS_PROMPT:
	rcall CLEAR_LCD
	rjmp START_GUESS

START_GUESS:
	ldi temp1, 8
	rcall INIT_LOOP
GUESS_INPUT:
	tst temp1
	breq FOREVER

	rcall KEYPAD
	
	mov temp, key
	subi temp, -48
	rcall WRITE_TEXT
	
	rcall GET_SPACE
	rcall WRITE_TEXT

	ld value1, Y+
	rcall CHECK_GUESS

	
	subi temp1, 1
	rjmp GUESS_INPUT

ext_int0:
	ldi temp1, 0
	ldi temp2, 0
	ldi temp4, 0
	ldi temp5, 0
	ldi temp6, 0
	mov value1, temp1
	mov value2, temp1
	pop key
	pop key
	ldi key, 0
	nop
	rjmp	0x00


FOREVER:
	rjmp FOREVER

INPUT_SWITCH:
	rcall KEYPAD
	cpi key, 8
	brge INPUT_SWITCH
	ret

KEYPAD:
	.include "init_keypad.asm"
	ret

INIT_LOOP:
	ldi YH, high(ARRAY)
	ldi YL, low(ARRAY)
	ret

SECONDARY_POINTER:
	ldi XH, high(ARRAY)
	ldi XL, low(ARRAY)
	ret

CHECK_GUESS:
	.include "led_output.asm"
	
KeyTable: ;dari kiri
	.db 0xF0, 0xF0, 0xF0, 0xF0 ; kolom ke empat
	.DB 0x03, 0x06, 0x09, 0xF0 ; kolom ke tiga
	.DB 0x02, 0x05, 0x08, 0x00 ; kolom ke dua
	.DB 0x01, 0x04, 0x07, 0xF0 ; kolom pertama

input_user_message:
	.db "Masukkan Angka",0
input_user_random_message:
	.db "Jumlah Pengacakan", 0
good_luck_prompt:
	.db "Good Luck!", 0
