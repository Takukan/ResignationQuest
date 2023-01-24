;;
;; SISTEMA CONTROL/JUGADOR.S
;;

.include "jugador.h.s"
.include "sys/fisica/fisica.h.s"
.include "utils/keyboard.h.s"

jugador_arrayFunciones: .dw #fisica_moverArriba, #fisica_moverAbajo, #fisica_moverIzquierda, #fisica_moverDerecha, #fisica_noMover, #0x0000

jugador_arrayTeclas: .dw #keyboard_keyQ, #keyboard_keyA, #keyboard_keyO, #keyboard_keyP, #keyboard_keySpace

;;Interpreta una orden de teclado y pide a fisica el movimiento correspondiente
;;RECIBE:
;;UTILIZA: af, bc, de, hl, ix, iy
;;DEVUELVE: puntero a la funcion fisica en hl
jugador_movimiento::
    ld ix, #jugador_arrayFunciones
    ld iy, #jugador_arrayTeclas
    jugador_movimiento_loop:
        ;;Si ha llegado al final del array (#0x00XX) reinicia la funcion
        ld a, 1(ix)
        or a
        jr z, jugador_movimiento
        ;;Si no, comprueba si la tecla se pulsa
        ld d, 1(iy)
        ld e, 0(iy)
        ex de, hl
        call keyboard_siPulsadoYSoltado
        jr z, jugador_movimiento_teclaPulsada
        ;;Si la tecla no esta pulsada sigue iterando
        inc ix
        inc ix
        inc iy
        inc iy
        jr jugador_movimiento_loop
        jugador_movimiento_teclaPulsada:
        ;;si la tecla esta pulsada mete en hl la funcion y sale
        ld d, 1(ix)
        ld e, 0(ix)
        ex de, hl
        ret


