;;
;; LIBRERIA STRING.S
;;

.include "string.h.s"


;
; Función para convertir un valor numérico a un array de caracteres (por sus valores ASCII) (termina en un valor nulo)
; INPUT: 
;       
; DESTROYS:
;
; RETURN: 
;
;http://map.grauw.nl/sources/external/z80bits.html#5.2
string_Num2Hex::
    ld	a,h
	call	string_Num2Hex_Num1H
	ld	a,h
	call	string_Num2Hex_Num2H
	ld	a,l
	call	string_Num2Hex_Num1H
	ld	a,l
	jr	string_Num2Hex_Num2H

    string_Num2Hex_Num1H:
        rra
        rra
        rra
        rra
    string_Num2Hex_Num2H:
        or	#0xF0
        daa
        add	a,#0xA0
        adc	a,#0x40

        ld	(de),a
        inc	de
        ret


string_Num2Dec::
    ld	bc,#-10000
	call	string_Num2Dec_Num1D
	ld	bc,#-1000
	call	string_Num2Dec_Num1D
	ld	bc,#-100
	call	string_Num2Dec_Num1D
	ld	c,#-10
	call	string_Num2Dec_Num1D
	ld	c,b

string_Num2Dec_Num1D:
	ld	a,#'0'-1
string_Num2Dec_Num2D:
	inc	a
	add	hl,bc
	jr	c,string_Num2Dec_Num2D
	sbc	hl,bc

	ld	(de),a
	inc	de
	ret

