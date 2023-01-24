;;
;; MANEJADOR OBJETO.S
;;

.include "macros/cpct_undocumentedOpcodes.h.s"

.include "objeto.h.s"

.include "assets/sprites.h.s"
.include "man/mapa/mapa.h.s"
.include "sys/juego/logica.h.s"

objeto_prototipoAscensor: objeto_DefineEntidad
objeto_prototipoHealthUp: objeto_DefineEntidad
objeto_prototipoHealthMaxUp: objeto_DefineEntidad
objeto_prototipoAtkUp: objeto_DefineEntidad
objeto_prototipoDefUp: objeto_DefineEntidad
objeto_prototipoSpdUp: objeto_DefineEntidad

objeto_array:: objeto_DefineArray objeto_max
objeto_num:: .db #0
objeto_siguiente: .dw #objeto_array


;;Inicializar datos
;;UTILIZA: a, hl
objeto_iniciar::
    ;;reinicia el protitipo escalera
    objeto_RellenaEntidad #objeto_prototipoAscensor, #_spAscensor, #0xAD, #0xDE, #logica_siguienteNivel, #mapa_simboloAscensor
    objeto_RellenaEntidad #objeto_prototipoHealthUp, #_spHealthUpMasked, #0xAD, #0xDE, #logica_healthUp, #mapa_simboloHealthUp
    objeto_RellenaEntidad #objeto_prototipoHealthMaxUp, #_spHealthMaxUpMasked, #0xAD, #0xDE, #logica_healthMaxUp, #mapa_simboloHealthMaxUp
    objeto_RellenaEntidad #objeto_prototipoAtkUp, #_spAtkMasked, #0xAD, #0xDE, #logica_atkUp, #mapa_simboloAtkUp
    objeto_RellenaEntidad #objeto_prototipoDefUp, #_spDefMasked, #0xAD, #0xDE, #logica_defUp, #mapa_simboloDefUp
    objeto_RellenaEntidad #objeto_prototipoSpdUp, #_spSpdMasked, #0xAD, #0xDE, #logica_spdUp, #mapa_simboloSpdUp
objeto_iniciarNivel::
    ;;reinicia el siguiente
    ld hl, #objeto_array
    ld (objeto_siguiente), hl
    ;;reinicia num objetos
    xor a
    ld (objeto_num), a
    ret
;;Crea un ascensor
;;RECIBE: posicionX en b, posicionY en c
;;UTILIZA: a, bc, de, hl
;;DEVUELVE: (flags) z si no creo objeto, nz si creo objeto
objeto_crearAscensor::
    ;;carga el prototipo a crear
    ld hl, #objeto_prototipoAscensor
    ld (objeto_crear_prototipo), hl
    ;;crea el objeto
    jr objeto_crear
;;Crea un healthUp
;;RECIBE: posicionX en b, posicionY en c
;;UTILIZA: a, bc, de, hl
;;DEVUELVE: (flags) z si no creo objeto, nz si creo objeto
objeto_crearHealthUp::
    ;;carga el prototipo a crear
    ld hl, #objeto_prototipoHealthUp
    ld (objeto_crear_prototipo), hl
    ;;crea el objeto
    jr objeto_crear
;;Crea un healthMaxUp
;;RECIBE: posicionX en b, posicionY en c
;;UTILIZA: a, bc, de, hl
;;DEVUELVE: (flags) z si no creo objeto, nz si creo objeto
objeto_crearHealthMaxUp::
    ;;carga el prototipo a crear
    ld hl, #objeto_prototipoHealthMaxUp
    ld (objeto_crear_prototipo), hl
    ;;crea el objeto
    jr objeto_crear
;;Crea un atkUp
;;RECIBE: posicionX en b, posicionY en c
;;UTILIZA: a, bc, de, hl
;;DEVUELVE: (flags) z si no creo objeto, nz si creo objeto
objeto_crearAtkUp::
    ;;carga el prototipo a crear
    ld hl, #objeto_prototipoAtkUp
    ld (objeto_crear_prototipo), hl
    ;;crea el objeto
    jr objeto_crear
;;Crea un defUp
;;RECIBE: posicionX en b, posicionY en c
;;UTILIZA: a, bc, de, hl
;;DEVUELVE: (flags) z si no creo objeto, nz si creo objeto
objeto_crearDefUp::
    ;;carga el prototipo a crear
    ld hl, #objeto_prototipoDefUp
    ld (objeto_crear_prototipo), hl
    ;;crea el objeto
    jr objeto_crear
;;Crea un spdUp
;;RECIBE: posicionX en b, posicionY en c
;;UTILIZA: a, bc, de, hl
;;DEVUELVE: (flags) z si no creo objeto, nz si creo objeto
objeto_crearSpdUp::
    ;;carga el prototipo a crear
    ld hl, #objeto_prototipoSpdUp
    ld (objeto_crear_prototipo), hl
    ;;crea el objeto
    jr objeto_crear


;;Crea un nuevo objeto sin comprobar la posicion
;;TODO: si la pila llega muy lejos, guardar bc en ix
;;RECIBE: posicionX en b, posicionY en c
;;UTILIZA: a, bc, de, hl
;;DEVUELVE: (flags) z si no creo objeto, nz si creo objeto
objeto_crear:
    ;;Si no queda espacio vuelve
    ld a, (objeto_num)
    sub #objeto_max
    ret z
    ;;Guarda bc
    push bc
    ;;Copia el prototipo que le hayan dicho
    objeto_crear_prototipo = .+1
    ld hl, #0xADDE
    ld de, (objeto_siguiente)
    ld bc, #objeto_sizeOf
    ldir
    ;;Recupera bc y hl
    pop bc
    ld hl, (objeto_siguiente)
    ;;Cambia la posicion                         _______________
    ;;DOS OPCIONES:                             |___S___|___T___|
    ld de, #objeto_offsetPosicion             ;;|   3   |   10  |
    add hl, de                                ;;|   1   |   11  |
    ld (hl), c;; Guarda y en el registro bajo   |   1   |   7   |
    inc hl                                    ;;|   1   |   6   |_______________
    ld (hl), b;;Guarda x en el registro alto    |___1___|___7___|___7___|___41__|
    ;;  ex de hl                                |   1   |   4   |
    ;;  ld ixh, d                               |   2   |   8   |
    ;;  ld ixl, e                               |   2   |   8   |
    ;;  ld posX(ix), b                          |   3   |   19  |_______________
    ;;  ld posY(ix), c                          |___3___|___19__|___11__|___58__|
    ;;Actualiza el siguienteObjeto
    ld de, #objeto_offsetSiguienteDesdePosicionX
    add hl, de
    ld (objeto_siguiente), hl
    ;;Aumenta el contador de objetos (nunca da 0)
    ld hl, #objeto_num
    inc (hl)
    ret

;;Destruye un objeto (no comprueba que el objeto exista, cuidaito)
;;RECIBE: puntero a objeto a borrar en de
;;UTILIZA: a, bc, de, hl
objeto_borrar::
    ;;Calcula el ultimo objeto
    ld hl, (objeto_siguiente)
    ld bc, #objeto_sizeOfNegativo
    add hl, bc

    ;;Guarda el ultimo objeto como el siguiente disponible
    ld (objeto_siguiente), hl
    
    ;;Sobrescribe el objeto borrado, copiando el ultimo de la lista
    ld bc, #objeto_sizeOf
    ldir

    ;;Decrementa el contador de objetos
    ld hl, #objeto_num
    dec (hl)
    ret

;;Encuentra el objeto en la posicion dada, si no hay objeto ahí, revienta fuerte, bucle infinito hasta que rompa cosas
;;RECIBE: la posicion en bc
;;UTILIZA: a, bc, de, hl, ix
;;DEVUELVE: el puntero al objeto en hl
objeto_enPosicion::
    ld ix, #objeto_array
    objeto_enPosicion_loop:
        ;;comprueba que la x sea buena
        ld a, b
        cp objeto_offsetPosicionX(ix)
        jr nz, objeto_enPosicion_noPosicion
        ;;comprueba que la y sea buena
        ld a, c
        cp objeto_offsetPosicionY(ix)
        jr nz, objeto_enPosicion_noPosicion
        ;;si coincide, mete ix en hl (con dificultad)
        ld__d_ixh
        ld__e_ixl
        ex de, hl
        ret
        objeto_enPosicion_noPosicion:
        ;;salta al siguiente del array y vuelve a empezar el bucle
        ld de, #objeto_sizeOf
        add ix, de
        jr objeto_enPosicion_loop