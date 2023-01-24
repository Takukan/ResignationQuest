
.include "mapa.h.s"
.include "mapas.h.s"

;;antes de la direcciona del mapa debe haber una referencia al siguiente
mapa_5_tamano: .dw #0x0A08
mapa_5_siguiente: .dw #mapa_6
mapa_5::
;;SIZE x = 10 y = 8
    .db #mapa_simboloVacio, #mapa_simboloPared, #mapa_simboloPared, #mapa_simboloPared, #mapa_simboloPared, #mapa_simboloPared, #mapa_simboloPared, #mapa_simboloAscensor, #mapa_simboloPared, #mapa_simboloVacio
    .db #mapa_simboloVacio, #mapa_simboloPared, #mapa_simboloHueco, #mapa_simboloHealthUp, #mapa_simboloHealthUp, #mapa_simboloJugador, #mapa_simboloPared, #mapa_simboloHueco, #mapa_simboloPared, #mapa_simboloVacio
    .db #mapa_simboloVacio, #mapa_simboloPared, #mapa_simboloHueco, #mapa_simboloEnemigo1, #mapa_simboloPared, #mapa_simboloPared, #mapa_simboloPared, #mapa_simboloEnemigo1, #mapa_simboloPared, #mapa_simboloVacio
    .db #mapa_simboloVacio, #mapa_simboloPared, #mapa_simboloHueco, #mapa_simboloHueco, #mapa_simboloHueco, #mapa_simboloHueco, #mapa_simboloHueco, #mapa_simboloHueco, #mapa_simboloPared, #mapa_simboloVacio
    .db #mapa_simboloVacio, #mapa_simboloPared, #mapa_simboloHueco, #mapa_simboloHueco, #mapa_simboloHueco, #mapa_simboloHueco, #mapa_simboloHueco, #mapa_simboloHueco, #mapa_simboloPared, #mapa_simboloVacio
    .db #mapa_simboloVacio, #mapa_simboloPared, #mapa_simboloEnemigo1, #mapa_simboloHueco, #mapa_simboloPared, #mapa_simboloHueco, #mapa_simboloPared, #mapa_simboloPared, #mapa_simboloPared, #mapa_simboloVacio
    .db #mapa_simboloVacio, #mapa_simboloPared, #mapa_simboloHueco, #mapa_simboloHueco, #mapa_simboloPared, #mapa_simboloHueco, #mapa_simboloHueco, #mapa_simboloEnemigo1, #mapa_simboloPared, #mapa_simboloVacio
    .db #mapa_simboloVacio, #mapa_simboloPared, #mapa_simboloPared, #mapa_simboloPared, #mapa_simboloPared, #mapa_simboloPared, #mapa_simboloPared, #mapa_simboloPared, #mapa_simboloPared, #mapa_simboloVacio