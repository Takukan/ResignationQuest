;;
;; SISTEMA JUEGO/LOGICA.S
;;

.include "logica.h.s"
.include "man/partida.h.s"
.include "man/personaje.h.s"
.include "man/mapa/mapa.h.s"
.include "sys/visual/render.h.s"
.include "man/objeto.h.s"
.include "juego.h.s"


;;REINICIAR LA VIDA A FINAL DE MAPA? NO CREO.

;;Reiniciar los atributos antes de empezar un turno
;;UTILIZA: de, hl, ix
logica_inicioRonda::
    ;;carga el inicio del array de entidades, el contador y el tamano
    ld ix, #personaje_jugador
    ld hl, #personaje_numEnemigos
    ld de, #personaje_sizeOf
    ld c, #0xFF

    logica_iniciar_loop:
        ;;guarda en a la defensaMax
        ld a, personaje_offsetSpdMovDef(ix)
        personaje_getDefMax
        ;;guarda la defensaMax en defensaAct
        ld b, a
        ld a, personaje_offsetSpdMovDef(ix)
        personaje_setDefAct
        ld personaje_offsetSpdMovDef(ix), a
        ;;resetea los movimientos
        ld b, #0x01
        ld a, personaje_offsetSpdMovDef(ix)
        personaje_setMov
        ld personaje_offsetSpdMovDef(ix), a
        ;;aumenta el cotador y el iterador
        inc c
        ld a, c
        add ix, de
        ;;sale del loop si no quedan entidades
        cp (hl)
        ret z
        jr logica_iniciar_loop

;;coge los primeros 4 bits
;;RECIBE: valor en a
;;UTILIZA: a, d
;;DEVUELVE: primeros 4 bits en a
logica_primerosCuatroBits:
    ld d, #0xF0
    and d
    srl a
    srl a
    srl a
    srl a
    ret

;;Ejecuta la logica del juego para el movimiento anterior
;;UTILIZA: a, bc, d, ix
;;DEVUELVE: (flags) z si movimiento invalido, nz si movimiento valido
logica_actualizar::
    ;;si la entidadPasiva esta vacia (#0x00XX) no hace nada
    ld bc, (partida_entidadPasiva)
    ld a, b
    or a
    jr z, logica_actualizar_valida

    ;;obtiene los simbolos, pasivo en b, activo en c
    ld ix, (partida_entidadPasiva)
    ld b, personaje_offsetSimbolo(ix)
    ld ix, (partida_entidadActiva)
    ld c, personaje_offsetSimbolo(ix)

    ;;obtiene solo los 4 primeros bit del simbolo pasivo
    ld a, b
    call logica_primerosCuatroBits
    ld b, a
    ;;obtiene solo los 4 primeros bit del simbolo activo
    ld a, c
    call logica_primerosCuatroBits
    ld c, a
    ;;elige como actuar
    ld a, #0x08
    cp c
    jr z, logica_actualizar_activo8X
    ld a, #0x09
    cp c
    jr z, logica_actualizar_activo9X
    ;;Si el activo no es 8X (jugador) o 9X (enemigo) no hace nada
    ;;La entidad activa no puede cambiar si todos sus movimientos son invalidos
    ;;tendria que ser invalido, pero prefiero evitar posible bucle infinito
    jr logica_actualizar_valida
    
    logica_actualizar_activo8X:
        ;;si pasivo es 9X salta a ciclo de combate
        ld a, #0x09
        cp b
        jr z, logica_actualizar_cicloCombate
        ;;si pasivo es 1X salta a activar objeto
        ld a, #0x01
        cp b
        jr z, logica_actualizar_activarObjeto
        ;;si no es ninguno de estos, acaba sin hacer nada
        jr logica_actualizar_invalida        

    logica_actualizar_activo9X:
        ;;si pasivo es 8X salta a ciclo de combate
        ld a, #0x08
        cp b
        jr z, logica_actualizar_cicloCombate
        ;;si pasivo es 1X es un movimiento valido pero no hace nada
        ld a, #0x01
        cp b
        jr z, logica_actualizar_valida
        ;;si no es ninguno de estos, acaba sin hacer nada
        jr logica_actualizar_invalida

    logica_actualizar_cicloCombate:
        ;;ejecuta combate
        call logica_combate
        call logica_comprobarMuertePasiva
        ;;ANIMACIONES AQUI?? NO ESTOY SEGURO
        jr logica_actualizar_valida

    logica_actualizar_activarObjeto:
        ;;llama a la funcion de logica del objeto
        ld ix, (partida_entidadPasiva)
        ld d, objeto_offsetColisionAlto(ix)
        ld e, objeto_offsetColisionBajo(ix)
        ex de, hl
        ld (logica_actualizar_activarObjeto_colision), hl
        logica_actualizar_activarObjeto_colision = .+1
        call #0xADDE
        jr logica_actualizar_valida

    logica_actualizar_valida:
        xor a
        inc a
        ret
    
    logica_actualizar_invalida:
        xor a
        ret
        
;;utilizar macros de personaje para hacer danyo
;;comprobaciones de vida, destruccion
;;eliminar muertos, incluyendo el mapa_actual
;;crear en partida una "consecuenciaAccion"
;;  para pantala de muerte si muerto
;;  ?para cargar nivel si cambio de nivel?
;;UTILIZA: a, bc, d, ix
logica_combate:
    ;;OBTIENE EL ATACA
    ;;almacena el ataque en c
    ld ix, (partida_entidadActiva)
    ld a, personaje_offsetHealthAtk(ix)
    personaje_getAtk
    ld c, a

    ;;ATACA A LA DEFENSA
    ;;almacena la defensa en a
    ld ix, (partida_entidadPasiva)
    ld a, personaje_offsetSpdMovDef(ix)
    personaje_getDefAct
    ;;le quita a la defensa, el atak
    sub c
    jr c, #logica_combate_saltarAnimacionEscudo
        push af
        push bc
        push de
        push hl
        call render_animarAtaqueEscudo
        pop hl
        pop de
        pop bc
        pop af
    logica_combate_saltarAnimacionEscudo:
    jp p, logica_combate_defAtk ;;la defensa absorbe el ataque

    ;;REINICIA LA DEFENSA
    ;;si la defensa no absorbe todo el ataque, se guarda en d la defensa negativa
    ld d, a
    ;;guarda la defensa 0
    ld a, #0x00
    call logica_combate_defAtk

    ;;ATACA A LA VIDA
    ;;guarda la vida en a
    push af
        push bc
        push de
        push hl
        call render_animarAtaqueVida
        pop hl
        pop de
        pop bc
        pop af
    ld a, personaje_offsetHealthAtk(ix)
    personaje_getHealthAct
    ;;le quita a la vida la defensa negativa
    add a, d
    jp p, logica_combate_healthAtk ;;la vida absorbe el ataque
    ;;si la vida no absorbe todo el ataque, guarda la vida 0
    xor a
    jr logica_combate_healthAtk

    ;;GUARDA LA DEFENSA
    logica_combate_defAtk:
    ;;guarda la nueva defensa disminuida
    ld b, a
    ld a, personaje_offsetSpdMovDef(ix)
    personaje_setDefAct
    ld personaje_offsetSpdMovDef(ix), a
    ret

    ;;GUARDA LA VIDA
    logica_combate_healthAtk:
    ;;guarda la nueva vida disminuida
    ld b, a
    ld a, personaje_offsetHealthAtk(ix)
    personaje_setHealthAct
    ld personaje_offsetHealthAtk(ix), a

    ret

;;TODO: ACTUALIZAR SCORE!
;;UTILIZA: a, bc, hl, ix
logica_comprobarMuertePasiva:
    ;;obtiene la vida de la entidad pasiva
    ld ix, (partida_entidadPasiva)
    ld a, personaje_offsetHealthAtk(ix)
    personaje_getHealthAct
    ;;si no es 0, no hace nada
    or a
    ret nz
    jr logica_muertePasiva

;;Funcion siguiente nivel
;;parece inutil, pero los objetos necesitan funcion de logica
;;UTILIZA: hl
logica_siguienteNivel::
    ld hl, #juego_siguienteNivel
    ld (partida_consecuenciaAccion), hl
    ret
;;Funcion auxiliar de muerte
logica_muertePasiva:
    ;;si ha muerto, ademas lo mata.
    ld hl, #juego_matarPasiva
    ld (partida_consecuenciaAccion), hl
    ret
;;Funcion healthUp
logica_healthUp::
    ;;aumenta la vida en uno si es posible
    ld ix, (partida_entidadActiva)
    ld a, personaje_offsetHealthAtk(ix)
    personaje_getHealthMax
    ld d, a
    ld a, personaje_offsetHealthAtk(ix)
    personaje_getHealthAct
    ;;si esta a tope de vida salta
    cp d
    jr z, logica_healthUp_maxHealth
    ;;si no esta a tope de vida, le suma uno a la vida actual
    inc a
    ld b, a
    ld a, personaje_offsetHealthAtk(ix)
    personaje_setHealthAct
    ld personaje_offsetHealthAtk(ix), a
    logica_healthUp_maxHealth:
    ;;destruye el objeto
    jr logica_muertePasiva

;;Funcion healthMaxUp
logica_healthMaxUp::
    ;;aumenta la vida maxima y la vida en uno si es posible
    ld ix, (partida_entidadActiva)
    ld a, personaje_offsetHealthAtk(ix)
    personaje_getHealthMax
    cp #personaje_maxHealth
    ;;si está a tope, salta
    jr z, logica_healthMaxUp_maxHealth
    ;;si no esta a tope
    inc a
    ld b, a
    ld a, personaje_offsetHealthAtk(ix)
    personaje_setHealthMax
    ;;guarda en d el nuevo HealthAtk
    ld d, a
    ;;aumenta la vida actual en uno
    personaje_getHealthAct
    inc a
    ld b, a
    ld a, d
    personaje_setHealthAct
    ;;guarda el healthAtk final
    ld personaje_offsetHealthAtk(ix), a
    logica_healthMaxUp_maxHealth:
    ;;destruye el objeto
    jp logica_muertePasiva
;;Funcion atkUp
logica_atkUp::
    ;;aumenta el ataque en uno si es posible
    ld ix, (partida_entidadActiva)
    ld a, personaje_offsetHealthAtk(ix)
    personaje_getAtk
    cp #personaje_maxAtk
    ;;si está a tope, salta
    jr z, logica_atkUp_maxAtk
    ;;si no esta a tope
    inc a
    ld b, a
    ld a, personaje_offsetHealthAtk(ix)
    personaje_setAtk
    ld personaje_offsetHealthAtk(ix), a
    logica_atkUp_maxAtk:
    ;;destruye el objeto
    jp logica_muertePasiva
;;Funcion defUp
logica_defUp::
    ;;aumenta la defensa maxima y la defensa en uno si es posible
    ld ix, (partida_entidadActiva)
    ld a, personaje_offsetSpdMovDef(ix)
    personaje_getDefMax
    cp #personaje_maxDef
    ;;si está a tope, salta
    jr z, logica_defUp_maxDef
    ;;si no esta a tope
    inc a
    ld b, a
    ld a, personaje_offsetSpdMovDef(ix)
    personaje_setDefMax
    ;;guarda en d el nuevo HealthAtk
    ld d, a
    ;;aumenta la vida actual en uno
    personaje_getDefAct
    inc a
    ld b, a
    ld a, d
    personaje_setDefAct
    ;;guarda el healthAtk final
    ld personaje_offsetSpdMovDef(ix), a
    logica_defUp_maxDef:
    ;;destruye el objeto
    jp logica_muertePasiva
;;Funcion spdUp
logica_spdUp::
    ;;aumenta la velocidad en uno si es posible
    ld ix, (partida_entidadActiva)
    ld a, personaje_offsetSpdMovDef(ix)
    personaje_getSpd
    cp #personaje_maxSpd
    ;;si está a tope, salta
    jr z, logica_spdUp_maxSpd
    ;;si no esta a tope
    inc a
    ld b, a
    ld a, personaje_offsetSpdMovDef(ix)
    personaje_setSpd
    ld personaje_offsetSpdMovDef(ix), a
    logica_spdUp_maxSpd:
    ;;destruye el objeto
    jp logica_muertePasiva
