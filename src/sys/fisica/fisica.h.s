;;
;; SISTEMA FISICA/FISICA.H.S
;;

.globl fisica_moverDerecha
.globl fisica_moverIzquierda
.globl fisica_moverArriba
.globl fisica_moverAbajo
.globl fisica_noMover

.globl fisica_actualizar

.globl fisica_dejarPosicion

;;inc b
fisica_derecha = #0x04
;;inc c
fisica_abajo = #0x0C
;;dec b
fisica_izquierda = #0x05
;;dec c
fisica_arriba = #0x0D