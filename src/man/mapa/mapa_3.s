
.include "mapa.h.s"
.include "mapas.h.s"

;;antes de la direccion del mapa debe haber una referencia al siguiente
mapa_3_tamano: .dw #0x0C08   ; 8x16
mapa_3_siguiente: .dw #mapa_4
mapa_3::
	;;SIZE x = 12 y = 8
	.db #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio
	.db #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio
	.db #mapa_simboloVacio, #mapa_simboloPared, #mapa_simboloPared, #mapa_simboloPared, #mapa_simboloPared, #mapa_simboloPared, #mapa_simboloPared, #mapa_simboloPared, #mapa_simboloPared, #mapa_simboloPared, #mapa_simboloVacio, #mapa_simboloVacio
	.db #mapa_simboloVacio, #mapa_simboloPared, #mapa_simboloHueco, #mapa_simboloJugador, #mapa_simboloHueco, #mapa_simboloDefUp, #mapa_simboloHueco, #mapa_simboloEnemigo1, #mapa_simboloHueco, #mapa_simboloAscensor, #mapa_simboloVacio, #mapa_simboloVacio
	.db #mapa_simboloVacio, #mapa_simboloPared, #mapa_simboloPared, #mapa_simboloPared, #mapa_simboloPared, #mapa_simboloPared, #mapa_simboloPared, #mapa_simboloPared, #mapa_simboloPared, #mapa_simboloPared, #mapa_simboloVacio, #mapa_simboloVacio
	.db #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio
	.db #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio
	.db #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio
