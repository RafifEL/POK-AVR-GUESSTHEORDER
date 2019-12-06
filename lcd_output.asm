WRITE_TEXT:
	sbi PORTA,1 ; SETB RS
	ldi temp, 0x38
	out PORTB, temp
	sbi PORTA,0 ; SETB EN
	cbi PORTA,0 ; CLR EN
	rcall DELAY_01
	ret

MOVE_BOTTOM:
	cbi PORTA,1 ; CLR RS
	ldi temp,0b11000000 ; MOV DATA,0x01
	out PORTB,temp
	sbi PORTA,0 ; SETB EN
	cbi PORTA,0 ; CLR EN
	rcall DELAY_01
