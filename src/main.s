;;-----------------------------LICENSE NOTICE------------------------------------
;;  This file is part of CPCtelera: An Amstrad CPC Game Engine 
;;  Copyright (C) 2018 ronaldo / Fremos / Cheesetea / ByteRealms (@FranGallegoBR)
;;
;;  This program is free software: you can redistribute it and/or modify
;;  it under the terms of the GNU Lesser General Public License as published by
;;  the Free Software Foundation, either version 3 of the License, or
;;  (at your option) any later version.
;;
;;  This program is distributed in the hope that it will be useful,
;;  but WITHOUT ANY WARRANTY; without even the implied warranty of
;;  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;  GNU Lesser General Public License for more details.
;;
;;  You should have received a copy of the GNU Lesser General Public License
;;  along with this program.  If not, see <http://www.gnu.org/licenses/>.
;;-------------------------------------------------------------------------------


;; Include all CPCtelera constant definitions, macros and variables
.include "cpctelera.h.s"
;; Librerias del juego
.include "utils/keyboard.h.s"
.include "utils/draw.h.s"
.include "man/personaje.h.s"
.include "man/partida.h.s"
.include "man/objeto.h.s"
.include "man/mapa/mapa.h.s"
.include "sys/juego/turno.h.s"
.include "sys/control/control.h.s"
.include "sys/fisica/fisica.h.s"
.include "sys/juego/juego.h.s"
.include "sys/juego/logica.h.s"
.include "sys/visual/gui.h.s"
.include "sys/visual/render.h.s"
.include "man/mapa/mapas.h.s"

;; 
;; Declare all function entry points as global symbols for the compiler.
;; (The linker will know what to do with them)
;; WARNING: Every global symbol declared will be linked, so DO NOT declare 
;; symbols for functions you do not use.
;;

.globl cpct_disableFirmware_asm
.globl cpct_setVideoMode_asm
.globl cpct_setPALColour_asm
.globl cpct_akp_musicInit_asm
.globl cpct_akp_musicPlay_asm
.globl cpct_akp_stop_asm
.globl _mainTheme
;;
;; Start of _DATA area 
;;  SDCC requires at least _DATA and _CODE areas to be declared, but you may use
;;  any one of them for any purpose. Usually, compiler puts _DATA area contents
;;  right after _CODE area contents.
;;
.globl _g_palette
.area _DATA

;; string: .asciz "CPCtelera up and running!";

;;TODO LO DE LA PALETA IDEALMENTE METERlO EN RENDER_INICIAR
main_main_paleta:
       .db 0x14, 0x04, 0x15, 0x1C, 0x18, 0x0C, 0x05, 0x17, 0x1E, 0x00, 0x0E, 0x07, 0x13, 0x0A, 0x03, 0x0B
; ; ; ; ; ; ; ; ; [=====================================================]
; ; ; ; ; ; ; ; ; | Identifier        | Value| Identifier        | Value|
; ; ; ; ; ; ; ; ; |-----------------------------------------------------|
; ; ; ; ; ; ; ; ; | HW_BLACK          | 0x14 | HW_BLUE           | 0x04 |
; ; ; ; ; ; ; ; ; | HW_BRIGHT_BLUE    | 0x15 | HW_RED            | 0x1C |
; ; ; ; ; ; ; ; ; | HW_MAGENTA        | 0x18 | HW_MAUVE          | 0x1D |
; ; ; ; ; ; ; ; ; | HW_BRIGHT_RED     | 0x0C | HW_PURPLE         | 0x05 |
; ; ; ; ; ; ; ; ; | HW_BRIGHT_MAGENTA | 0x0D | HW_GREEN          | 0x16 |
; ; ; ; ; ; ; ; ; | HW_CYAN           | 0x06 | HW_SKY_BLUE       | 0x17 |
; ; ; ; ; ; ; ; ; | HW_YELLOW         | 0x1E | HW_WHITE          | 0x00 |
; ; ; ; ; ; ; ; ; | HW_PASTEL_BLUE    | 0x1F | HW_ORANGE         | 0x0E |
; ; ; ; ; ; ; ; ; | HW_PINK           | 0x07 | HW_PASTEL_MAGENTA | 0x0F |
; ; ; ; ; ; ; ; ; | HW_BRIGHT_GREEN   | 0x12 | HW_SEA_GREEN      | 0x02 |
; ; ; ; ; ; ; ; ; | HW_BRIGHT_CYAN    | 0x13 | HW_LIME           | 0x1A |
; ; ; ; ; ; ; ; ; | HW_PASTEL_GREEN   | 0x19 | HW_PASTEL_CYAN    | 0x1B |
; ; ; ; ; ; ; ; ; | HW_BRIGHT_YELLOW  | 0x0A | HW_PASTEL_YELLOW  | 0x03 |
; ; ; ; ; ; ; ; ; | HW_BRIGHT_WHITE   | 0x0B |                   |      |
; ; ; ; ; ; ; ; ; [=====================================================]     
;;
;; Start of _CODE area
;; 
.area _CODE

;;ESTO DEBERÍA SER UN .include "lib/sys/render.h.s"

;;No tengo ni idea de lo que voya hacer a continuacion
divisor=6 ;;regula la velocidad de la musica, cuanto mas alto el numero mas despacio la musica
contador: .db #divisor
pararMusica: .db 1
int_handler::
   push af
   push bc
   push de
   push hl

   ld a, (pararMusica)
   or a
   jr nz, handler_saltarMusica

   ld a, (contador)
   dec a
   ld (contador), a
   jr nz, handler_saltarMusica
      ld a, #divisor
      ld (#contador), a
      call cpct_akp_musicPlay_asm
   handler_saltarMusica:

   pop hl
   pop de
   pop bc
   pop af

   ei
   reti


;;
;; MAIN function. This is the entry point of the application.
;;    _main:: global symbol is required for correctly compiling and linking
;;
_main::
   ;; Disable firmware to prevent it from interfering with string drawing
   call cpct_disableFirmware_asm
   ld a, #0xc3
   ld (0x38), a
   ld hl, #int_handler
   ld a, l
   ld (0x39), a
   ld a, h
   ld (0x3A), a
   ld a, #0xc9
   ld (0x3B), a





   ;;ESTO DEBERÍA IR EN render_iniciar
   ;;O EN juego_iniciar
   ld c, #0
   call cpct_setVideoMode_asm
   ;;Cargar la paleta de colores
   ld hl,#_g_palette
   ld de,#16
   call cpct_setPalette_asm

   ld h, #0x04
   ld l, #0x10
   call cpct_setPALColour_asm

   ; ;; Llamamos a la función de pruebas para probar cualquier código simple que necesitemos
   ; call juego_prueba

   call partida_iniciar

nuevaPartida:
   ld de, #_mainTheme
   call cpct_akp_musicInit_asm
   xor a
   ld (pararMusica), a
   
   ld h, #0x04
   ld l, #0x10
   call cpct_setPALColour_asm

   ;;aquí empieza la partida
   call juego_pantallaDeInicio
   call juego_pantallaDeInicio2
   call personaje_iniciar
   call objeto_iniciar

   ld hl, #mapa_1
   call juego_cargarMapa

   call partida_iniciar
   call gui_pintarBase
  
   nuevoTurno:       

      call logica_inicioRonda
      call gui_inicioRonda

      call juego_ronda
      jr z, nuevoTurno
      
   ld a, #1
   ld (pararMusica), a
   call cpct_akp_stop_asm
   ;;Pantalla de muerte
   call juego_pantallaFinal


   ;;vuelve a jugar!
   jr nuevaPartida