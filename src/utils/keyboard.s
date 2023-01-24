;;
;; LIBRERIA KEYBOARD.S
;;

.include "keyboard.h.s"

;;
;; Función que devuelve z si se pulsa una tecla concreta cuando esta es soltada
;; INPUT:
;;      HL: Tecla a comprobar si se ha pulsado y soltado 
;; DESTROYS
;;      A, DE, BC, HL
;;
keyboard_siPulsadoYSoltado::
    push hl
    halt
    call cpct_scanKeyboard_asm
    pop hl
    push hl
    call cpct_isKeyPressed_asm               ;¿Se pulsa la tecla?
    pop hl
    jr z,keyboard_siPulsadoYSoltado_devuelveNZ                             ;Si no se pulsa return NZ
    keyboard_siPulsadoYSoltado_loop:    ;Si se ha pulsado entramos en un bucle hasta que se suelte
        push hl
        halt
        call cpct_scanKeyboard_asm
        pop hl
        push hl
        call cpct_isKeyPressed_asm           ;¿Se suelta la tecla?
        pop hl
        ret z            ;Si se suelta devolvemos Z (la tecla ha sido pulsada y soltada)
        jr keyboard_siPulsadoYSoltado_loop                      ;Si no, seguimos esperando a que se suelte

    keyboard_siPulsadoYSoltado_devuelveNZ:     
        xor a
        inc a
        ret                                     ;Devolvemos NZ



;;
;; Función que devuelve z si se pulsa cualquier tecla cuando esta es soltada
;; INPUT:
;;      
;; DESTROYS
;;      A, D, BC, HL
;;
keyboard_siPulsadoYSoltadoCualquiera::
    push hl
    halt
    call cpct_scanKeyboard_asm
    pop hl
    push hl
    call cpct_isAnyKeyPressed_asm               ;¿Se pulsa la tecla?
    pop hl
    jr z,keyboard_siPulsadoYSoltadoCualquiera_devuelveNZ                             ;Si no se pulsa return NZ
    keyboard_siPulsadoYSoltadoCualquiera_loop:    ;Si se ha pulsado entramos en un bucle hasta que se suelte
        push hl
        halt
        call cpct_scanKeyboard_asm
        pop hl
        push hl
        call cpct_isAnyKeyPressed_asm           ;¿Se suelta la tecla?
        pop hl
        ret z            ;Si se suelta devolvemos Z (la tecla ha sido pulsada y soltada)
        jr keyboard_siPulsadoYSoltadoCualquiera_loop                      ;Si no, seguimos esperando a que se suelte

    keyboard_siPulsadoYSoltadoCualquiera_devuelveNZ:     
        xor a
        inc a
        ret                                     ;Devolvemos NZ