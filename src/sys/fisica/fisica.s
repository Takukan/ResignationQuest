;;
;; SISTEMA FISICA/FISICA.S
;;

.include "fisica.h.s"
.include "man/partida.h.s"
.include "man/mapa/mapa.h.s"
.include "man/personaje.h.s"
.include "man/objeto.h.s"

;;Ejecuta la siguiente accion
;;UTILIZA: a, bc, hl, ix, iy
;;DEVUELVE: (flags) z si movimiento invalido, nz si movimiento valido
fisica_actualizar::
    ld hl, (partida_siguienteAccion)
    ld (fisica_funcionAccion), hl
    fisica_funcionAccion = .+1
    jp 0xADDE
    ret
    
;;No hace nada
;;UTILIZA: a
;;DEVUELVE: (flags) nz, movimiento siempre valido
fisica_noMover::
    xor a
    inc a
    ret
;;UTILIZA: a, bc, hl, ix, iy
fisica_moverDerecha::
    ld a, #fisica_derecha
    ld (fisica_mover_direccion), a
    jr fisica_mover

;;UTILIZA: a, bc, hl, ix, iy
fisica_moverIzquierda::
    ld a, #fisica_izquierda
    ld (fisica_mover_direccion), a
    jr fisica_mover

;;UTILIZA: a, bc, hl, ix, iy
fisica_moverAbajo::
    ld a, #fisica_abajo
    ld (fisica_mover_direccion), a
    jr fisica_mover

;;UTILIZA: a, bc, hl, ix, iy
fisica_moverArriba::
    ld a, #fisica_arriba
    ld (fisica_mover_direccion), a
    jr fisica_mover

;;Mueve al personaje
;;UTILIZA: a, de, bc, hl, ix, iy
;;DEVUELVE: (flags) z si movimiento invalido, nz si movimiento valido
fisica_mover:
    ;;carga la posicion activa
    ld iy, (partida_entidadActiva)
    ld b, personaje_offsetPosicionX(iy)
    ld c, personaje_offsetPosicionY(iy)
    ;;guarda la posicion activa original
    ld h, b
    ld l, c
    ;;modifica la posicion
    fisica_mover_direccion: .db #0xAA
    ;;comprueba las colisiones
    push bc
    push hl
    call fisica_colision  ;;se carga bc y hl... devuelve dato en d, comprobar
    pop hl
    pop bc
    ;;si se choca, comprueba contra que
    jr c, fisica_chocar
    ;;si no se choca, se mueve y comprueba si pisa algo (objetos, aun no)
    ;;guarda la nueva posicion
    ld personaje_offsetPosicionX(iy), b
    ld personaje_offsetPosicionY(iy), c
    ;;rellena la nueva posicion en el mapaEstado
    ld a, personaje_offsetSimbolo(iy)
    ld ix, #mapa_actual
    push hl
    call mapa_setCelda
    pop hl
    ;;guarda el simbolo devuelto en d
    push de
    ;;rellena el mapa de estado con hueco
    ld b, h
    ld c, l                     ;;recupera la posicion antigua
    call fisica_dejarPosicion
    ;;cambia la entidadPasiva
    ;;recupera la posicion
    ld b, personaje_offsetPosicionX(iy)
    ld c, personaje_offsetPosicionY(iy)
    ;;recupera el simbolo devuelto en d
    pop de
    jr fisica_pisar

;;Deja una posicion (es global porque hay que llamarlo cuando mueres)
;;RECIBE: la posicion a dejar en bc, entidad en iy
;;UTILIZA:  a, bc, de, hl, ix, iy (pero no se carga iy)
;;DEVUELVE: en d el simbolo anterior
fisica_dejarPosicion::
    ld ix, #mapa_actual
    ld a, personaje_offsetSimboloPisando(iy)
    call mapa_setCelda
    ret


;;Detecta la entidad que se piso
;;RECIBE: simbolo de la entidad en d, posicion de la entidad en bc, entidad activa en iy
;;UTILIZA: a, hl, d, iy
fisica_pisar:

    ;;Guarda el simbolo pisado en la entidadActiva
    ld personaje_offsetSimboloPisando(iy), d

    ;;si pisas un hueco, deja entidad vacia en blanco
    ld a, #mapa_simboloHueco
    cp d
    jr nz, fisica_pisar_noHueco
    ld hl, #0x0000
    ld (#partida_entidadPasiva), hl
    jr fisica_pisar_valido
    fisica_pisar_noHueco:
    ld a, #mapa_simboloVacio
    cp d
    jr nz, fisica_pisar_noVacio
    ld hl, #0x0000
    ld (#partida_entidadPasiva), hl
    jr fisica_pisar_valido
    fisica_pisar_noVacio:
    ;;DETECCION DE OBJETOS AQU�?
    ;;como no hay otra cosa, asume directamente que es un objeto
    call objeto_enPosicion
    ld (#partida_entidadPasiva), hl
    
    ;;devuelve nz
    fisica_pisar_valido:
    xor a
    inc a
    ret

;;Deteca la entidad contra la que se choco
;;RECIBE: simbolo de la entidad en d, posicion de la entidad en bc
;;UTILIZA: 
fisica_chocar:
    ;;si chocas contra pared, deja entidad pasiva en blanco
    ld a, #mapa_simboloPared
    cp d
    jr nz, fisica_chocar_noPared
    ld hl, #0x0000
    ld (#partida_entidadPasiva), hl
    jp fisica_chocar_invalido
    fisica_chocar_noPared:
    ;;DETECCION DE ENTIDADES AQUI
    ;;si chocas contra el jugador, lo pones como pasivo
    ld a, #mapa_simboloJugador
    cp d
    jr nz, fisica_chocar_noJugador
    ld hl, #personaje_jugador
    ld (#partida_entidadPasiva), hl
    jp fisica_chocar_valido

    fisica_chocar_noJugador:
    ;;si chocas contra un enemigo, lo busca y lo pone como pasivo
    ld a, #mapa_simboloEnemigo1
    cp d
    jr nz, fisica_chocar_noEnemigo1
    call personaje_enemigoEnPosicion
    ld (#partida_entidadPasiva), hl
    jp fisica_chocar_valido

    fisica_chocar_noEnemigo1:
    ;;si chocas contra un enemigo, lo busca y lo pone como pasivo
    ld a, #mapa_simboloEnemigo2
    cp d
    jr nz, fisica_chocar_noEnemigo2
    call personaje_enemigoEnPosicion
    ld (#partida_entidadPasiva), hl
    jp fisica_chocar_valido

    fisica_chocar_noEnemigo2:
    ;;si chocas contra un enemigo, lo busca y lo pone como pasivo
    ld a, #mapa_simboloEnemigo3
    cp d
    jr nz, fisica_chocar_noEnemigo3
    call personaje_enemigoEnPosicion
    ld (#partida_entidadPasiva), hl
    jp fisica_chocar_valido

    fisica_chocar_noEnemigo3:
    ;;si chocas contra un enemigo, lo busca y lo pone como pasivo
    ld a, #mapa_simboloEnemigo4
    cp d
    jr nz, fisica_chocar_noEnemigo4
    call personaje_enemigoEnPosicion
    ld (#partida_entidadPasiva), hl
    jp fisica_chocar_valido

    fisica_chocar_noEnemigo4:
    ;;si chocas contra un enemigo, lo busca y lo pone como pasivo
    ld a, #mapa_simboloEnemigo5
    cp d
    jr nz, fisica_chocar_noEnemigo5
    call personaje_enemigoEnPosicion
    ld (#partida_entidadPasiva), hl
    jp fisica_chocar_valido

    fisica_chocar_noEnemigo5:
    ;;si chocas contra un enemigo, lo busca y lo pone como pasivo
    ld a, #mapa_simboloEnemigo6
    cp d
    jr nz, fisica_chocar_noEnemigo6
    call personaje_enemigoEnPosicion
    ld (#partida_entidadPasiva), hl
    jp fisica_chocar_valido

    fisica_chocar_noEnemigo6:
    fisica_chocar_invalido:
    ;;devuelve z
    xor a
    ret
    fisica_chocar_valido:
    ;;devuelve nz
    xor a
    inc a
    ret

;;ACABAR OSTIA
;;comprueba si se puede mover hacia la posicion
;;RECIBE: la posicion xy en bc
;;UTILIZA: a, bc, de, hl, ix
;;DEVUELVE: el simbolo de la entidad en d, (flags) c si colision, nc si no colision
fisica_colision:
    ld ix, #mapa_actual
    call mapa_getCelda
    ;;comprueba si a es negativo (colision)
    ld d, a
    add a, #0x80
    ret
    