;;
;; MANEJADOR OBJETO.H.S
;;

;;INCLUDE EXCEPCIONAL
.include "man/entidadFisica.h.s"

.globl objeto_iniciar
.globl objeto_iniciarNivel
.globl objeto_crearAscensor
.globl objeto_crearHealthUp
.globl objeto_crearHealthMaxUp
.globl objeto_crearAtkUp
.globl objeto_crearDefUp
.globl objeto_crearSpdUp
.globl objeto_borrar
.globl objeto_enPosicion

;;ESTRUCTURA OBJETO
;; Bytes    Contenido
;; 0        simbolo en mapa de estado
;; 1-2      Direccion sprite
;; 3-4      Posicion xy (en memoria guardas como little endian, es decir: y x)
;; 5-6      Funcion logica en colision


objeto_offsetSimbolo = entidadFisica_offsetSimbolo
objeto_offsetSprite = 1
;;CUIDADO POSICION SE DEFINE COMO XY, NO SEPARAR
objeto_offsetPosicion = 3
objeto_offsetColision = 5
objeto_sizeOf = 7


objeto_offsetSpriteBajo = objeto_offsetSprite
objeto_offsetSpriteAlto = objeto_offsetSprite + 1
objeto_offsetPosicionY = objeto_offsetPosicion
objeto_offsetPosicionX = objeto_offsetPosicion + 1
objeto_offsetColisionBajo = objeto_offsetColision
objeto_offsetColisionAlto = objeto_offsetColision + 1


;;hacks (no se si se pueden hacer :/)
objeto_offsetSiguienteDesdePosicionX = objeto_sizeOf - objeto_offsetPosicionX
objeto_sizeOfNegativo = -objeto_sizeOf

objeto_max = 20

.macro objeto_DefineEntidad
    .rept #objeto_sizeOf
        .db #0xAA
    .endm
.endm

.macro objeto_DefineArray _N
    .rept _N
        objeto_DefineEntidad
    .endm
.endm


;;UTILIZA: a, hl, ix
.macro  objeto_RellenaEntidad _objeto, _sprite, _posX, _posY, _colision, _Simbolo
    ld ix, _objeto
    ld hl, _sprite                                 ;;Carga las dos partes de la direccion de memoria
    ld objeto_offsetSpriteAlto(ix), h
    ld objeto_offsetSpriteBajo(ix), l
    ld objeto_offsetPosicionX(ix), _posX
    ld objeto_offsetPosicionY(ix), _posY
    ld hl, _colision                              ;;Carga las dos partes de la direccion de memoria
    ld objeto_offsetColisionAlto(ix), h
    ld objeto_offsetColisionBajo(ix), l
    ld objeto_offsetSimbolo(ix), _Simbolo
.endm
