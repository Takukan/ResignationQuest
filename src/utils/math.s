;;
;; LIBRERIA MATH.S
;;

.include "math.h.s"

math_randomSeed:: .db #0x00

;;Multiplica dos numeros enteros
;;RECIBE: en d y e los dos numeros a multiplicar
;;UTILIZA: a, de, hl
;;DEVUELVE: el resultado en hl
math_multiplicacion::
    ;;carga el primer numero en a
    ld a, d
    ;;borra el registro alto de de
    ld d, #0x00
    ;;borra hl
    ld hl, #0x0000
    ;;le suma de (e) d veces a hl
    math_multiplicacion_loop:
        or a
        ret z
        add hl, de
        dec a
        jr math_multiplicacion_loop

;Función que realiza la operación módulo (%)
;INPUT:
;       A: Numerador (A%L)
;       L: Denominador (A%L)
;RETURNS:
;       A: Resultado de realizar la operación módulo
;DESTROYS:
;       A,L
math_modulo::
    cp #0x00
    jp p, #math_modulo_bucle    ;Si el número está en negativo lo convertimos a positivo
    cpl
    inc a
    math_modulo_bucle:
        sub l
        jp p, math_modulo_bucle
        add a,l
        ret
