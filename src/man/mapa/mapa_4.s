
.include "mapa.h.s"
.include "mapas.h.s"

;;antes de la direccion del mapa debe haber una referencia al siguiente
mapa_4_tamano: .dw #0x0A08
mapa_4_siguiente: .dw #mapa_5
mapa_4::
;;SIZE x = 10 y = 8
	.db #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio 
	.db #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio
	.db #mapa_simboloVacio, #mapa_simboloPared, #mapa_simboloPared, #mapa_simboloPared, #mapa_simboloPared, #mapa_simboloPared, #mapa_simboloPared, #mapa_simboloAscensor, #mapa_simboloPared, #mapa_simboloVacio
	.db #mapa_simboloVacio, #mapa_simboloPared, #mapa_simboloHueco, #mapa_simboloHealthUp, #mapa_simboloHueco, #mapa_simboloHueco, #mapa_simboloHueco, #mapa_simboloHueco, #mapa_simboloPared, #mapa_simboloVacio
	.db #mapa_simboloVacio, #mapa_simboloPared, #mapa_simboloEnemigo1, #mapa_simboloJugador, #mapa_simboloEnemigo1, #mapa_simboloPared, #mapa_simboloHueco, #mapa_simboloEnemigo1, #mapa_simboloPared, #mapa_simboloVacio
	.db #mapa_simboloVacio, #mapa_simboloPared, #mapa_simboloPared, #mapa_simboloPared, #mapa_simboloPared, #mapa_simboloPared, #mapa_simboloPared, #mapa_simboloPared, #mapa_simboloPared, #mapa_simboloVacio
	.db #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio
	.db #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio

