;;
;; MANEJADOR PARTIDA.S
;;


.include "partida.h.s"

partida_entidadActiva:: .dw #0xADDE         ;;Puntero a la entidad que esta haciendo cosas
partida_siguienteAccion:: .dw #0xEFBE       ;;Puntero a la siguiente funcion fisica a ejecutar (ej. mover derecha)
partida_entidadPasiva:: .dw #0xADDE         ;;Puntero a la entidad a la que se le hacen cosas
partida_consecuenciaAccion:: .dw #0xEFDE    ;;Puntero a la funcion de juego a ejecutar tras el movimiento

partida_jugadorMuerto:: .db #0xAA           ;;Del 0 al 1, como de muerto esta el jugador?

;;  ACLARACION SUPER IMPOrTANTE
;;  Por el momento todas nuestras acciones son movimientos:
;;      - Moverse hacia a un lado
;;      - Atacar a un enemigo (te mueves hacia el)
;;      - Usar un objeto (lo pisas)
;;
;;  Esto nos permite simplificar inmensamente los sistemas de control:
;;      Si un enemigo quiere ir hacia el jugador y atacarle, solo necesita ir hacia el jugador
;;  Tambien esta chulo para las interrupciones, el pisar el objeto salida ejecuta una funcion especial
;;
;;  En general la entidad pasiva es la entidad que pise o intente pisar la entidad activa

partida_puntuacion:: .dw #0xADDE

;;UTILIZA: a
partida_iniciar::
    ;;El jugador resulta que empieza no muerto
    xor a
    ld (partida_jugadorMuerto), a
    ;;la puntuacion empieza siendo 0
    ld hl, #0x0000
    ld (partida_puntuacion), hl
    ret
