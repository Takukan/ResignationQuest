;;
;; LIBRERIA DRAW.S
;;

.include "draw.h.s"
;;
;; Función para pintar todo el fondo de pntalla del color recibido en A (en modo 0)
;; INPUT:
;;       A: Recibe el color del que pintar la pantalla
;; DESTROYS:
;;       AF,BC,DE,HL
;;
draw_pintaFondoPantallaM0::
   ld de, #0xC000                ;Guardamos en DE la primera posición de la pantalla
   ld c, #40                     ;Guardamos en C el ancho de la caja (40 bytes (160 px (media pantalla)))
   ld b, #200                    ;Guardamos en B el alto de la caja (200 bytes (200px (la pantalla completa)))
   push af                       ;Enviamos AF a la pila para que no se pierda el color del que hay que pintar
   call cpct_drawSolidBox_asm    ;Pintamos la caja
   pop af                        ;Recuperamos AF de la pila para saber de que color pintar
   ld de, #0xC028                ;Guardamos en DE la primera posición del segundo cuadrado
   ld c, #40                     ;Guardamos en C el ancho de la caja (40 bytes (160 px (media pantalla)))
   ld b, #200                    ;Guardamos en B el alto de la caja (200 bytes (200px (la pantalla completa)))
   call cpct_drawSolidBox_asm    ;Pintamos la caja
   ret
