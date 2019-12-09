INIT_LCD_MAIN:
	rcall INIT_LCD
	rcall CLEAR_LCD
	rjmp END_LCD_INIT

INIT_LCD:
	cbi PORTA,1 ; CLR RS
	ldi temp,0x38 ; MOV DATA,0x38 --> 8bit, 2line, 5x7
	out PORTB,temp
	sbi PORTA,0 ; SETB EN
	cbi PORTA,0 ; CLR EN
	rcall DELAY_01
	cbi PORTA,1 ; CLR RS
	ldi temp,$0E ; MOV DATA,0x0E --> disp ON, cursor ON, blink OFF
	out PORTB,temp
	sbi PORTA,0 ; SETB EN
	cbi PORTA,0 ; CLR EN
	rcall DELAY_01
	rcall CLEAR_LCD ; CLEAR LCD
	cbi PORTA,1 ; CLR RS
	ldi temp,$06 ; MOV DATA,0x06 --> increase cursor, display sroll OFF
	out PORTB,temp
	sbi PORTA,0 ; SETB EN
	cbi PORTA,0 ; CLR EN
	rcall DELAY_01
	ret

CLEAR_LCD:
	cbi PORTA,1 ; CLR RS
	ldi temp,$01 ; MOV DATA,0x01
	out PORTB,temp
	sbi PORTA,0 ; SETB EN
	cbi PORTA,0 ; CLR EN
	rcall DELAY_01
	ret

END_LCD_INIT:
	ser temp
	out DDRA,temp ; Set port A as output
	out DDRB,temp ; Set port B as output
