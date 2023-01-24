;;
;; MANEJADOR MAPA.H.S
;;

mapa_maxFilas = 30	;; tama?o maximo 12, usando 2x2 caracteres por celda
mapa_maxColumnas = 30 ;; si se cambia esto de debe actualizar el desplazamiento de getCelda

.globl mapa_getCelda
.globl mapa_setCelda
.globl mapa_getCeldaIterative
.globl mapa_actual
.globl mapa_cargar
.globl mapa_filas
.globl mapa_columnas
.globl mapa_siguiente

;;LOGICA ASUME ESTOS VALORES, NO TOCARLOS SIN PREGUNTAR
;;Positive numbers represent you can move to
;;Huecos
mapa_simboloHueco = #0x00
;;objects
mapa_simboloAscensor = #0x10
mapa_simboloHealthUp = #0x11
mapa_simboloHealthMaxUp = #0x12
mapa_simboloAtkUp = #0x13
mapa_simboloDefUp = #0x14
mapa_simboloSpdUp = #0x15
;;Negative numbers represent collision
;; #0x8X no ataca a 0x8X
mapa_simboloJugador = #0x81
;; #0x9X no taca a 0x9X
mapa_simboloEnemigo1 = #0x92
mapa_simboloEnemigo2 = #0x93
mapa_simboloEnemigo3 = #0x94
mapa_simboloEnemigo4 = #0x95
mapa_simboloEnemigo5 = #0x96
mapa_simboloEnemigo6 = #0x97

;;Paredes
mapa_simboloPared = #0xFF
mapa_simboloVacio = #0xFE