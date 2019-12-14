CP_KEY_VALUE:
	cp value1, key
	breq LED_OUTPUT
	ret

LED_OUTPUT:
	subi result, -1
	cpi temp1, 8
	breq FIRST
	cpi temp1, 7
	breq SECOND
	cpi temp1, 6
	breq THIRD
	cpi temp1, 5
	breq FOURTH
	cpi temp1, 4
	breq FIFTH
	cpi temp1, 3
	breq SIXTH
	cpi temp1, 2
	breq SEVENTH
	cpi temp1, 1
	breq EIGHTH

FIRST:
	in temp2, PORTE
	subi temp2, -1
	out PORTE, temp2
	ret

SECOND:
	in temp2, PORTE
	subi temp2, -2
	out PORTE, temp2
	ret

THIRD:
	in temp2, PORTE
	subi temp2, -4
	out PORTE, temp2
	ret

FOURTH:
	in temp2, PORTE
	subi temp2, -8
	out PORTE, temp2
	ret

FIFTH:
	in temp2, PORTE
	subi temp2, -16
	out PORTE, temp2
	ret

SIXTH:
	in temp2, PORTE
	subi temp2, -32
	out PORTE, temp2
	ret


SEVENTH:
	in temp2, PORTE
	subi temp2, -64
	out PORTE, temp2
	ret

EIGHTH:
	in temp2, PORTE
	ori temp2, LAST_LED
	out PORTE, temp2
	ret

