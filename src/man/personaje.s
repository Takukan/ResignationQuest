;;
;; MANEJADOR PERSONAJE.S
;;

.include "personaje.h.s"
.include "man/mapa/mapa.h.s"
.include "assets/sprites.h.s"
.include "sys/control/jugador.h.s"
.include "sys/control/AI.h.s"

.include "macros/cpct_undocumentedOpcodes.h.s"


;;Los getters no encapsularian de verdad, así que hacer global
;;  el cuidado lo tendrías que tener igual con el getter
;;TODO: Los datos de incializar no son potables, cambiarlos por valores reales
;;DISCLAIMER: LA POSICION DE LOS OBJETOS EN ARRAY NO ES FIJA. NO GUARDEIS ESO.

personaje_prototipoEnemigo1:  personaje_DefineEntidad
personaje_prototipoEnemigo2:  personaje_DefineEntidad
personaje_prototipoEnemigo3:  personaje_DefineEntidad
personaje_prototipoEnemigo4:  personaje_DefineEntidad
personaje_prototipoEnemigo5:  personaje_DefineEntidad
personaje_prototipoEnemigo6:  personaje_DefineEntidad
personaje_jugador:: personaje_DefineEntidad
personaje_arrayEnemigos:: personaje_DefineArray personaje_maxEnemigos
personaje_numEnemigos:: .db #0
personaje_siguienteEnemigo: .dw #personaje_arrayEnemigos


;;Inicializar datos
;;UTILIZA: a, hl
personaje_iniciar::
    ;;reinicia el protitipo enemigo1
     personaje_RellenaEntidad #personaje_prototipoEnemigo1, #_spEnemy1, #0xAD, #0xDE, #0x00, #0x01, #0x00, #0x02, #AI_persigueVisionR4, #0xAD, #0xDE, #e_ai_noAI, #mapa_simboloEnemigo1
    ;;reinicia el protitipo enemigo2
     personaje_RellenaEntidad #personaje_prototipoEnemigo2, #_spEnemy2, #0xAD, #0xDE, #0x00, #0x01, #0x00, #0x02, #AI_standby, #0xAD, #0xDE, #e_ai_noAI, #mapa_simboloEnemigo2
    ;;reinicia el protitipo enemigo3
     personaje_RellenaEntidad #personaje_prototipoEnemigo3, #_spEnemy3, #0xAD, #0xDE, #0x00, #0x01, #0x00, #0x02, #AI_standby, #0xAD, #0xDE, #e_ai_noAI, #mapa_simboloEnemigo3
    ;;reinicia el protitipo enemigo4
     personaje_RellenaEntidad #personaje_prototipoEnemigo4, #_spEnemy4, #0xAD, #0xDE, #0x00, #0x01, #0x00, #0x02, #AI_standby, #0xAD, #0xDE, #e_ai_noAI, #mapa_simboloEnemigo4
    ;;reinicia el protitipo enemigo5
     personaje_RellenaEntidad #personaje_prototipoEnemigo5, #_spEnemy5, #0xAD, #0xDE, #0x00, #0x01, #0x00, #0x02, #AI_standby, #0xAD, #0xDE, #e_ai_noAI, #mapa_simboloEnemigo5
    ;;reinicia el protitipo enemigo5
     personaje_RellenaEntidad #personaje_prototipoEnemigo6, #_spEnemy6, #0xAD, #0xDE, #0x00, #0x01, #0x00, #0x02, #AI_standby, #0xAD, #0xDE, #e_ai_noAI, #mapa_simboloEnemigo6
    

    ;;reinicia el jugador
     personaje_RellenaEntidad #personaje_jugador, #_spPlayer, #0, #0, #0x00, #0x01, #0x00, #0x02, #jugador_movimiento, #0xAD, #0xDE, #e_ai_standBy, #mapa_simboloJugador

personaje_iniciarNivel::
    ;;reinicia el siguienteEnemigo
    ld hl, #personaje_arrayEnemigos
    ld (personaje_siguienteEnemigo), hl
    ;;reinicia numEnemigos
    xor a
    ld (personaje_numEnemigos), a
    ret

;;Crea un nuevo enemigo (de tipo 1 siempre) sin comprobar la posicion
;;TODO: si la pila llega muy lejos, guardar bc en ix
;;RECIBE: posicionX en b, posicionY en c
;;UTILIZA: a, bc, de, hl
;;DEVUELVE: (flags) z si no creo enemigo, nz si creo enemigo
personaje_crearEnemigo6::
    ld hl, #personaje_prototipoEnemigo6
    jp personaje_crearEnemigoGenerico
personaje_crearEnemigo5::
    ld hl, #personaje_prototipoEnemigo5
    jp personaje_crearEnemigoGenerico
personaje_crearEnemigo4::
    ld hl, #personaje_prototipoEnemigo4
    jp personaje_crearEnemigoGenerico
personaje_crearEnemigo3::
    ld hl, #personaje_prototipoEnemigo3
    jp personaje_crearEnemigoGenerico
personaje_crearEnemigo2::
    ld hl, #personaje_prototipoEnemigo2
    jp personaje_crearEnemigoGenerico
personaje_crearEnemigo1::
    ld hl, #personaje_prototipoEnemigo1
   


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ; ld hl, #objeto_prototipoAscensor
    ; ld (objeto_crear_prototipo), hl
    ; ;;crea el objeto
    ; jr objeto_crear

;;;;;;;;;;;;;;;;;;;;;;;,

personaje_crearEnemigoGenerico:
 ld (personaje_prototipoEnemigo),hl
    ;;Si no queda espacio vuelve
    ld a, (personaje_numEnemigos)
    sub #personaje_maxEnemigos
    ret z
    ;;Guarda bc
    push bc
    ;;Copia el prototipo
    personaje_prototipoEnemigo=.+1

    ld hl, #0xADDE
    ld de, (personaje_siguienteEnemigo)
    ld bc, #personaje_sizeOf
    ldir
    ;;Recupera bc y hl
    pop bc
    ld hl, (personaje_siguienteEnemigo)
    ;;Cambia la posicion                         _______________
    ;;DOS OPCIONES:                             |___S___|___T___|
    ld de, #personaje_offsetPosicion          ;;|   3   |   10  |
    add hl, de                                ;;|   1   |   11  |
    ld (hl), c;; Guarda y en el registro bajo   |   1   |   7   |
    inc hl                                    ;;|   1   |   6   |_______________
    ld (hl), b;;Guarda x en el registro alto    |___1___|___7___|___7___|___41__|
    ;;  ex de hl                                |   1   |   4   |
    ;;  ld ixh, d                               |   2   |   8   |
    ;;  ld ixl, e                               |   2   |   8   |
    ;;  ld posX(ix), b                          |   3   |   19  |_______________
    ;;  ld posY(ix), c                          |___3___|___19__|___11__|___58__|
    ;;Actualiza el siguienteEnemigo
    ld de, #personaje_offsetSiguienteDesdePosicionX
    add hl, de
    ld (personaje_siguienteEnemigo), hl
    ;;Aumenta el contador de enemigos (nunca da 0)
    ld hl, #personaje_numEnemigos
    inc (hl)
    ret

;;Destruye un enemigo (no comprueba que el enemigo exista, cuidaito)
;;RECIBE: puntero a enemigo a borrar en de
;;UTILIZA: a, bc, de, hl
personaje_borrarEnemigo::
    ;;Calcula el ultimo enemigo
    ld hl, (personaje_siguienteEnemigo)
    ld bc, #personaje_sizeOfNegativo
    add hl, bc

    ;;Guarda el ultimo enemigo como el siguiente disponible
    ld (personaje_siguienteEnemigo), hl
    
    ;;Sobrescribe el enemigo borrado, copiando el ultimo de la lista
    ld bc, #personaje_sizeOf
    ldir

    ;;Decrementa el contador de enemigos
    ld hl, #personaje_numEnemigos
    dec (hl)
    ret

;;Comprueba si un personaje es el jugador
;;RECIBE: el puntero a personaje en hl
;;UTILIZA a, de, hl
;;DEVUELVE: (flags) z si es jugador, nz si no es jugador
personaje_esJugador::
    ld de, #personaje_jugador
    ld a, e
    sub l
    ret nz
    ld a, d
    sub h
    ret
;;Encuentra el enemigo en la posicion dada, si no hay enemigo ahí, revienta fuerte, bucle infinito hasta que rompa cosas
;;RECIBE: la posicion en bc
;;UTILIZA: a, bc, de, hl, ix
;;DEVUELVE: el puntero al enemigo en hl
personaje_enemigoEnPosicion::
    ld ix, #personaje_arrayEnemigos
    personaje_enemigoEnPosicion_loop:
        ;;comprueba que la x sea buena
        ld a, b
        cp personaje_offsetPosicionX(ix)
        jr nz, personaje_enemigoEnPosicion_noPosicion
        ;;comprueba que la y sea buena
        ld a, c
        cp personaje_offsetPosicionY(ix)
        jr nz, personaje_enemigoEnPosicion_noPosicion
        ;;si coincide, mete ix en hl (con dificultad)
        ld__d_ixh
        ld__e_ixl
        ex de, hl
        ret
        personaje_enemigoEnPosicion_noPosicion:
        ;;salta al siguiente del array y vuelve a empezar el bucle
        ld de, #personaje_sizeOf
        add ix, de
        jr personaje_enemigoEnPosicion_loop