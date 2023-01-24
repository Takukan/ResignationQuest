;;
;; MANEJADOR MAPA.S
;;

.include "mapa.h.s"
.include "mapas.h.s"
.include "utils/math.h.s"

.include "macros/cpct_undocumentedOpcodes.h.s"

mapa_columnas:: .db 0
mapa_filas::	.db 0
mapa_siguiente:: .dw #0xADDE

mapa_actual:: .ds mapa_maxColumnas * mapa_maxFilas

;; get valor celda
;; entrada BC = x y, IX = direccion del mapa
;; destruye A, BC, DE, HL, IX
;; salida A = valor celda, (HL = puntero a celda: no uses esto, setCelda)
mapa_getCelda::
	ld a, (#mapa_columnas)
	cp c
	jp z,(#mapa_getCelda_fueraDelMapa)
	jp m,(#mapa_getCelda_fueraDelMapa)

	ld a, (#mapa_filas)
	cp b
	jp z,(#mapa_getCelda_fueraDelMapa)
	jp m,(#mapa_getCelda_fueraDelMapa)

	call mapa_encontrarCelda
	ld a, (hl)					;; return value in a
	ret

	mapa_getCelda_fueraDelMapa:
	ld a, #0xFE
	ret
	

;;set valor celda
;;RECIBE: A = nuevo valor celda, BC = x y, IX = direccion del mapa
;;UTILIZA: A, BC, DE, HL, IX 
;;DEVUELVE: en d el valor anterior (por conveniencia para fisica)
mapa_setCelda::
	call mapa_encontrarCelda
	ld d, (hl)
	ld (hl), a
	ret

;;encuentra la posicion de una celda
;;RECIBE: BC = x,y, IX = direccion del mapa
;;UTILIZA: BC, DE, HL
;;DEVUELVE: el puntero a la celda en hl
mapa_encontrarCelda:
	;;Obtiene en DE el desplazamiento necesario
	ld d, c						;;mete y en d
	ld c, a						;;guarda a en c
	ld a, (mapa_filas)			;;mete el tamaño de las filas en e
	ld e, a
	call math_multiplicacion	;;multiplica
	ld d, #0x00					;;limpia el byte alto de de
	ld e, b						;;guarda x en de
	add hl, de					;;suma al desplazamiento de y el desplazamiento de x
	;;carga la direccion del mapa
	ld__d_ixh
	ld__e_ixl

	ex de, hl					;;guarda en de el desplazamiento y en hl el mapa

	;;ld hl, #mapa_mapa			;; carga puntero a mapa
	add hl, de 					;; hl + desplazamiento
	ld a, c						;; recupera a
	ret


;; retorna el valor de la siguiente celda desde donde apunta HL -> getCelda de HL+1
;; entrada HL = puntero a celda
;; salida A = valor celda, HL = HL + 1	
mapa_getCeldaIterative::  ;; TODO macro???
	ld a, (hl)					;; return value in a
	inc hl
	ret 

;; carga el mapa ubicado en la direccion de memoria de HL
;; entrada HL mapa a cargar
;; destruye HL, BC, DE, IX
;; salida
mapa_cargar::
	;;guarda el siguiente mapa
	dec hl
	dec hl
	dec hl
	dec hl

	ld de, #mapa_columnas
	ld bc, #0x04 ;;tamanyo de una direccion
	ldir
	push hl
	;;vuelve a poner hl al principio del mapa despues de copiar
	ld a, (mapa_filas)
	ld e, a
	ld a, (mapa_columnas)
	ld d, a
	call math_multiplicacion
	ld b, h		;; bc = contador de celdas a cargar
	ld c, l
	pop hl
	ld de, #mapa_actual
	ldir
	ret


