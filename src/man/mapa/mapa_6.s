
.include "mapa.h.s"
.include "mapas.h.s"

;;antes de la direcciona del mapa debe haber una referencia al siguiente
mapa_6_tamano: .dw #0x0C0C
mapa_6_siguiente: .dw #mapa_7
mapa_6::
;;SIZE x = 12 y = 12
    .db #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloPared, #mapa_simboloPared, #mapa_simboloPared, #mapa_simboloPared, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio
    .db #mapa_simboloVacio, #mapa_simboloPared, #mapa_simboloPared, #mapa_simboloPared, #mapa_simboloPared, #mapa_simboloHueco, #mapa_simboloEnemigo1, #mapa_simboloPared, #mapa_simboloPared, #mapa_simboloPared, #mapa_simboloPared, #mapa_simboloVacio
    .db #mapa_simboloVacio, #mapa_simboloPared, #mapa_simboloHealthUp, #mapa_simboloHueco, #mapa_simboloHueco, #mapa_simboloHueco, #mapa_simboloHueco, #mapa_simboloHueco, #mapa_simboloHueco, #mapa_simboloHueco, #mapa_simboloAscensor, #mapa_simboloVacio
    .db #mapa_simboloVacio, #mapa_simboloPared, #mapa_simboloHueco, #mapa_simboloPared, #mapa_simboloPared, #mapa_simboloHueco, #mapa_simboloHueco, #mapa_simboloPared, #mapa_simboloPared, #mapa_simboloHueco, #mapa_simboloPared, #mapa_simboloVacio
    .db #mapa_simboloPared, #mapa_simboloPared, #mapa_simboloHueco, #mapa_simboloPared, #mapa_simboloEnemigo1, #mapa_simboloHueco, #mapa_simboloHueco, #mapa_simboloEnemigo1, #mapa_simboloPared, #mapa_simboloHueco, #mapa_simboloPared, #mapa_simboloPared
    .db #mapa_simboloPared, #mapa_simboloEnemigo1, #mapa_simboloHueco, #mapa_simboloHueco, #mapa_simboloHueco, #mapa_simboloPared, #mapa_simboloPared, #mapa_simboloHueco, #mapa_simboloHueco, #mapa_simboloHueco, #mapa_simboloHueco, #mapa_simboloPared
    .db #mapa_simboloPared, #mapa_simboloHueco, #mapa_simboloHueco, #mapa_simboloHueco, #mapa_simboloHueco, #mapa_simboloPared, #mapa_simboloPared, #mapa_simboloHueco, #mapa_simboloHueco, #mapa_simboloHueco, #mapa_simboloEnemigo1, #mapa_simboloPared
    .db #mapa_simboloPared, #mapa_simboloPared, #mapa_simboloHueco, #mapa_simboloPared, #mapa_simboloEnemigo1, #mapa_simboloHueco, #mapa_simboloHueco, #mapa_simboloEnemigo1, #mapa_simboloPared, #mapa_simboloHueco, #mapa_simboloPared, #mapa_simboloPared
    .db #mapa_simboloVacio, #mapa_simboloPared, #mapa_simboloHueco, #mapa_simboloPared, #mapa_simboloPared, #mapa_simboloHueco, #mapa_simboloHueco, #mapa_simboloPared, #mapa_simboloPared, #mapa_simboloHueco, #mapa_simboloPared, #mapa_simboloVacio
    .db #mapa_simboloVacio, #mapa_simboloPared, #mapa_simboloJugador, #mapa_simboloHueco, #mapa_simboloHueco, #mapa_simboloHueco, #mapa_simboloHueco, #mapa_simboloHueco, #mapa_simboloHueco, #mapa_simboloHealthUp, #mapa_simboloPared, #mapa_simboloVacio
    .db #mapa_simboloVacio, #mapa_simboloPared, #mapa_simboloPared, #mapa_simboloPared, #mapa_simboloPared, #mapa_simboloEnemigo1, #mapa_simboloHueco, #mapa_simboloPared, #mapa_simboloPared, #mapa_simboloPared, #mapa_simboloPared, #mapa_simboloVacio
    .db #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloPared, #mapa_simboloPared, #mapa_simboloPared, #mapa_simboloPared, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio, #mapa_simboloVacio