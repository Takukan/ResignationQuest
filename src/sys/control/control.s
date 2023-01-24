;;
;; SISTEMA CONTROL/CONTROL.S
;;

.include "control.h.s"
.include "jugador.h.s"
.include "man/partida.h.s"
.include "man/personaje.h.s"

;;
;; Sistema de control
;;
control_iniciar::
    ret

;;Llama a la funcion control de una entidad
;;RECIBE: entidad en ix
;;UTILIZA: a, ix, hl
;;  potenciamente: todos, depende de la funcion llamada
control_actualizar::
    ;;Llama al controlador de la entidad activa
    ld ix, (partida_entidadActiva)
    ld a, personaje_offsetControladorAlto(ix)
    ld (control_byteAltoControlador), a
    ld a, personaje_offsetControladorBajo(ix)
    ld (control_byteBajoControlador), a
    control_byteBajoControlador = .+1
    control_byteAltoControlador = .+2
    call #0xADDE
    ;;recibe en hl un puntero a la funcion de accion y lo pone en juego_siguienteAccion
    ld (partida_siguienteAccion), hl
    ret


;;IDEA DE LA OSTIA:
;;hacer los sistemas de control macros muy grandes, llamar a los macros aquí entre dos etiquetas
;; inicio_control:
;;      macro1
;;      macro1
;;       ...
;; fin_control:
;;Y antes de llamar que compruebe si la direccion a llamar está entre inicio y fin.