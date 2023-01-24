
.include "mapa.h.s"
.include "mapas.h.s"

;;antes de la direccion del mapa debe haber una referencia al siguiente
mapa_2_tamano: .dw #0x0808   ;; mapa 8 x A
mapa_2_siguiente: .dw #mapa_3
mapa_2::
	;;SIZE x = 8 y = 8
	.db #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio
	.db #mapa_simboloVacio, #mapa_simboloPared, #mapa_simboloPared, #mapa_simboloPared, #mapa_simboloPared, #mapa_simboloPared, #mapa_simboloPared, #mapa_simboloPared
	.db #mapa_simboloVacio, #mapa_simboloPared, #mapa_simboloJugador, #mapa_simboloHueco, #mapa_simboloHueco, #mapa_simboloHueco, #mapa_simboloEnemigo1, #mapa_simboloAscensor
	.db #mapa_simboloVacio, #mapa_simboloPared, #mapa_simboloPared, #mapa_simboloPared, #mapa_simboloPared, #mapa_simboloPared, #mapa_simboloPared, #mapa_simboloPared
	.db #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio
	.db #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio
	.db #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio
	.db #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio
