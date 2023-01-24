;;
;; MANEJADOR PERSONAJE.H.S
;;

;;INCLUDE EXCEPCIONAL
.include "man/entidadFisica.h.s"

.globl personaje_jugador
.globl personaje_arrayEnemigos
.globl personaje_numEnemigos

.globl personaje_iniciar
.globl personaje_iniciarNivel
.globl personaje_crearEnemigo1
.globl personaje_crearEnemigo2
.globl personaje_crearEnemigo3
.globl personaje_crearEnemigo4
.globl personaje_crearEnemigo5
.globl personaje_crearEnemigo6
.globl personaje_borrarEnemigo
.globl personaje_numEnemigos
.globl personaje_enemigoEnPosicion
.globl personaje_esJugador

;;ESTRUCTURA PERSONAJE
;; Bytes    Contenido
;; 0        simbolo en mapa de estado
;; 1-2      Direccion sprite
;; 3-4      Posicion xy (en memoria guardas como little endian, es decir: y x)
;; 5        Vida max (3 bits), vida actual (3 bits) y ataque (2 bits)
;; 6        Velocidad (2 bits), movimiento disponible (2 bits (nos sobra un bit) ), defensa max (2 bits) y defensa actual (2 bits)
;; 7-8      Funcion accion
;; 9-10     Objetivo xy de la IA (en memoria guardas como little endian, es decir: y x)
;; 11       IA status
;; 12       simbolo pisando (por si un enemigo pisa un objeto)


personaje_offsetSimbolo = entidadFisica_offsetSimbolo
personaje_offsetSprite = 1
;;CUIDADO POSICION SE DEFINE COMO XY, NO SEPARAR
personaje_offsetPosicion = 3
personaje_offsetHealthAtk = 5
personaje_offsetSpdMovDef = 6
personaje_offsetControlador = 7
personaje_offsetIAObjetivo = 9
personaje_offsetIAStatus=11
personaje_offsetSimboloPisando = 12
personaje_sizeOf = 13

;;valores maximos stats invariables
personaje_maxAtk = 3
personaje_maxSpd = 3
personaje_maxDef = 3
personaje_maxHealth = 7

;;constantes de registro alto y bajo de los
personaje_offsetSpriteBajo = personaje_offsetSprite
personaje_offsetSpriteAlto = personaje_offsetSprite + 1
personaje_offsetPosicionY = personaje_offsetPosicion
personaje_offsetPosicionX = personaje_offsetPosicion + 1
personaje_offsetControladorBajo = personaje_offsetControlador
personaje_offsetControladorAlto = personaje_offsetControlador + 1
personaje_offsetIAObjetivoY = personaje_offsetIAObjetivo
personaje_offsetIAObjetivoX = personaje_offsetIAObjetivo + 1

;;MOVER A AI CONTROL
;; Enumeración con los valores que puede tomar IAStatus
e_ai_noAI = 0
e_ai_standBy = 1
e_ai_moveTo = 2

;;hacks (no se si se pueden hacer :/)
personaje_offsetSiguienteDesdePosicionX = personaje_sizeOf - personaje_offsetPosicionX
personaje_sizeOfNegativo = -personaje_sizeOf

personaje_maxEnemigos = 40

.macro personaje_DefineEntidad
    .rept #personaje_sizeOf
        .db #0xAA
    .endm
.endm

.macro personaje_DefineArray _N
    .rept _N
        personaje_DefineEntidad
    .endm
.endm

;;UTILIZA: a, b, hl, ix
.macro  personaje_RellenaEntidad _personaje, _sprite, _posX, _posY, _spd, _atk, _def, _health, _controlador, _IAObjetivoX, _IAObjetivoY, _IAStatus, _Simbolo
    ld ix, _personaje
    ld hl, _sprite                                 ;;Carga las dos partes de la direccion de memoria
    ld personaje_offsetSimbolo(ix), _Simbolo
    ld personaje_offsetSpriteAlto(ix), h
    ld personaje_offsetSpriteBajo(ix), l
    ld personaje_offsetPosicionX(ix), _posX
    ld personaje_offsetPosicionY(ix), _posY
    ;;por como funciona set, si a empieza a todo 0, lo que no se setee, sera 0
    ;;No setea mov ni def act para que se reinicien al empezar turno
    xor a
    ;;carga la spd y la setea
    ld b, _spd
    personaje_setSpd
    ;;carga la def y la setea
    ld b, _def
    personaje_setDefMax
    ld personaje_offsetSpdMovDef(ix), a
    ;;carga la health y la setea
    ld b, _health
    personaje_setHealthMax
    ld b, _health
    personaje_setHealthAct
    ;;carga el atk y lo setea
    ld b, _atk
    personaje_setAtk
    ld personaje_offsetHealthAtk(ix), a
    ld hl, _controlador                             ;;Carga las dos partes de la direccion de memoria
    ld personaje_offsetControladorAlto(ix), h
    ld personaje_offsetControladorBajo(ix), l
    ld personaje_offsetIAObjetivoX(ix), _IAObjetivoX
    ld personaje_offsetIAObjetivoY(ix), _IAObjetivoY
    ld personaje_offsetIAStatus(ix), _IAStatus
    ld personaje_offsetSimboloPisando(ix), #0x00
.endm

;;RECIBE: SPDMOVDEF en a
;;UTILIZA: a, b
;;DEVUELVE: DEF en a
.macro  personaje_getDefAct
    ;;guarda mascara
    ld b, #0x03
    ;;aplica mascara
    and b
.endm

;;RECIBE: SPDMOVDEF en a, defAct en b
;;UTILIZA: a, b
;;DEVUELVE: SPDMOVDEF en a
.macro personaje_setDefAct
    ;;guarda defAct
    push bc
    ;;guarda anti mascara
    ld b, #0xFC
    ;;aplica anti mascara
    and b
    ;;recupera defAct
    pop bc
    ;;guarda SPDMOVDEF
    push af
    ;;pone defAct en a
    ld a, b
    ;;guarda mascara
    ld b, #0x03
    ;;aplica mascara
    and b
    ;;guarda defAct en b
    ld b, a
    ;;recupera SPDMOVDEF
    pop af
    ;;suma nueva defAct
    add a, b
.endm

;;RECIBE: SPDMOVDEF en a
;;UTILIZA: a, b
;;DEVUELVE: DEF en a
.macro  personaje_getDefMax
    ;;guarda mascara
    ld b, #0x0C
    ;;aplica mascara
    and b
    ;;desplaza a
    srl a
    srl a
.endm


;;RECIBE: SPDMOVDEF en a, defMax en b
;;UTILIZA: a, b
;;DEVUELVE: SPDMOVDEF en a
.macro personaje_setDefMax
    ;;guarda defMax
    push bc
    ;;guarda anti mascara
    ld b, #0xF3
    ;;aplica anti mascara
    and b
    ;;recupera defMax
    pop bc
    ;;guarda SPDMOVDEF
    push af
    ;;pone defMax en a
    ld a, b
    ;;guarda mascara
    ld b, #0x03
    ;;aplica mascara
    and b
    ;;desplaza defMax
    sla a
    sla a
    ;;guarda defMax en b
    ld b, a
    ;;recupera SPDMOVDEF
    pop af
    ;;suma nueva defAct
    add a, b
.endm

;;RECIBE: SPDMOVDEF en a
;;UTILIZA: a
;;DEVUELVE: SPD en a
.macro  personaje_getSpd
    ;;desplaza a
    srl a
    srl a
    srl a
    srl a
    srl a
    srl a
.endm

;;RECIBE: SPDMOVDEF en a, spd en b
;;UTILIZA: a, b
;;DEVUELVE: SPDMOVDEF en a
.macro personaje_setSpd
    ;;guarda spd
    push bc
    ;;guarda anti mascara
    ld b, #0x3F
    ;;aplica anti mascara
    and b
    ;;recupera spd
    pop bc
    ;;desplaza spd
    sla b
    sla b
    sla b
    sla b
    sla b
    sla b
    ;;suma nueva spd
    add a, b
.endm

;;RECIBE: SPDMOVDEF en a
;;UTILIZA: a, b
;;DEVUELVE: MOV en a
.macro  personaje_getMov
    ;;guarda mascara
    ld b, #0x30
    ;;aplica mascara
    and b
    ;;desplaza a
    srl a
    srl a
    srl a
    srl a
.endm

;;RECIBE: SPDMOVDEF en a, mov en b
;;UTILIZA: a, b
;;DEVUELVE: SPDMOVDEF en a
.macro personaje_setMov
    ;;guarda mov
    push bc
    ;;guarda anti mascara
    ld b, #0xCF
    ;;aplica anti mascara
    and b
    ;;recupera mov
    pop bc
    ;;guarda SPDMOVDEF
    push af
    ;;pone mov en a
    ld a, b
    ;;guarda mascara
    ld b, #0x03
    ;;aplica mascara
    and b
    ;;desplaza mov
    sla a
    sla a
    sla a
    sla a
    ;;guarda mov en b
    ld b, a
    ;;recupera SPDMOVDEF
    pop af
    ;;suma nueva mov
    add a, b
.endm

;;RECIBE: HEALTHATK en a
;;UTILIZA: a, b
;;DEVUELVE: HEALTHATK en a
.macro  personaje_getHealthAct
    ;;guarda mascara
    ld b, #0x1C
    ;;aplica mascara
    and b
    ;;deplaza a
    srl a
    srl a
.endm


;;RECIBE: HEALTHATK en a, healthAct en b
;;UTILIZA: a, b
;;DEVUELVE: HEALTHATK en a
.macro personaje_setHealthAct
    ;;guarda healthAct
    push bc
    ;;guarda anti mascara
    ld b, #0xE3
    ;;aplica anti mascara
    and b
    ;;recupera healthAct
    pop bc
    ;;guarda HEALTHATK
    push af
    ;;pone healthAct en a
    ld a, b
    ;;guarda mascara
    ld b, #0x07
    ;;aplica mascara
    and b
    ;;desplaza a
    sla a
    sla a
    ;;guarda healthAct en b
    ld b, a
    ;;recupera HEALTHATK
    pop af
    ;;suma nueva healthAct
    add a, b
.endm

;;RECIBE: HEALTHATK en a
;;UTILIZA: a
;;DEVUELVE: HEALTHATK en a
.macro  personaje_getHealthMax
    ;;desplaza a
    srl a
    srl a
    srl a
    srl a
    srl a
.endm

;;RECIBE: HEALTHATK en a, healthMax en b
;;UTILIZA: a, b
;;DEVUELVE: HEALTHATK en a
.macro personaje_setHealthMax
    ;;guarda healthMax
    push bc
    ;;guarda anti mascara
    ld b, #0x1F
    ;;aplica anti mascara
    and b
    ;;recupera healthMax
    pop bc
    ;;desplaza healthMax
    sla b
    sla b
    sla b
    sla b
    sla b
    ;;suma nueva healthMax
    add a, b
.endm


;;RECIBE: HEALTHATK en a
;;UTILIZA: a, b
;;DEVUELVE: ATK en a
    ;;como ATK esta en la misma posicion que DEFACT
    ;;es lo mismo que DEFACT
.macro  personaje_getAtk
    personaje_getDefAct
.endm

;;RECIBE: HEALTHATK en a, atk en b
;;UTILIZA: a, b
;;DEVUELVE: HEALTHATK en a
    ;;como ATK esta en la misma posicion que DEFACT
    ;;es lo mismo que DEFACT
.macro  personaje_setAtk
    personaje_setDefAct
.endm
