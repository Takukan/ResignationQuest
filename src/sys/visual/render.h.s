;;
;; SISTEMA VISUAL/RENDER.H.S
;;

.globl render_esperar
.globl render_dibujarMapa
.globl render_animarAtaqueVida
.globl render_animarAtaqueEscudo

render_posY = 0
render_posX = 1
render_tamanoMapaAlto = 2
render_tamanoMapaBajo = 3
render_mapaPosY = 4
render_mapaPosX = 5

render_mapaFilas = 8
render_mapaColumnas = 10

render_modoBytes = 4							;; modo 0 = 4 bytes ;; modo 1/3 = 2 bytes ;; modo 2 = 1 byte
render_tamanoCelda = 2							;; tama?o de la celda nxn
render_tamanoContador = #render_modoBytes * #render_tamanoCelda 				;; comprobar si se cambia render_modoBytes
render_tamanoSprite == #8 * #render_tamanoCelda * #0x100 + #render_tamanoContador		;; comprobar si se cambia modoByte

jrHexcode = #0x18
render_tamanoGetSpritePtrPersonaje = #0x6



.macro render_getScreenPtr
	ld b, render_posY(iy)						;; set y
	ld c, render_posX(iy)						;; set x
	ld de, #0xc000								;; de = start vram
	call cpct_getScreenPtr_asm    				;; Calculate video memory location and return it in HL
	ex de, hl									;; de = puntero a vram donde se va a dibujar	
.endm

; .macro render_getScreenPtrPersonaje
; 	ld a, personaje_offsetPosicionY(iy)		;; bc = yx pos
; 	ld b, render_mapaPosY(ix)				;; logica para comprobar si esta dentro del mapa virtual
; 	sub b									;; quitamos el inicio del mapa virtual
; 	jr c, render_saltaDibujarPersonaje		;; si overflow, saltamos
; 	cp #render_mapaFilas					;; a?adimos el tama?o del mapa virtual (a es negativo ahora mismo)
; 	jr nc, render_saltaDibujarPersonaje		;; si no overflow, saltamos 
; 	ld b, a									;; guardamos la posicion actual (convertida a mapa virtual)
; 	;;multiplica la y por 16 (cambia con el modo)
; 	sla b
; 	sla b
; 	sla b
; 	sla b

; 	ld a, personaje_offsetPosicionX(iy)		;; bc = yx pos
; 	ld c, render_mapaPosX(ix)				;; logica para comprobar si esta dentro del mapa virtual
; 	sub c									;; quitamos el inicio del mapa virtual
; 	jr c, render_saltaDibujarPersonaje		;; si overflow, saltamos
; 	cp #render_mapaColumnas					;; a?adimos el tama?o del mapa virtual (a es negativo ahora mismo)
; 	jr nc, render_saltaDibujarPersonaje		;; si no overflow, saltamos 
; 	ld c, a									;; guardamos la posicion actual (convertida a mapa virtual)
; 	;;multiplica la x por 8 (cambia con el modo)
; 	sla c
; 	sla c
; 	sla c

; 	ld de, #0xc000						;; de = start vram

; 	;;destruye AF, BC, DE, HL
; 	call cpct_getScreenPtr_asm    		;; Calculate video memory location and return it in HL
; 	ex de, hl							;; de = puntero a vram donde se va a dibujar	
; .endm

.macro render_getSpritePtrPersonaje
	ld h, personaje_offsetSpriteAlto(iy)	;; hl = puntero a sprite
    ld l, personaje_offsetSpriteBajo(iy)
.endm

.macro render_decrementarContadorCeldas
	ld h, render_tamanoMapaAlto(iy)			;; carga tamanoMapa(escoger mejor nombre) en hl
	ld l, render_tamanoMapaBajo(iy)						
	dec hl								;; decrementa en uno(la celda que acaba de dibujar)
	ld render_tamanoMapaAlto(iy), h
	ld render_tamanoMapaBajo(iy), l			;; actualiza tamanoMapa
.endm


.macro render_getMapaVirtualPtr
	ld ix, #personaje_jugador			;; carga puntero a personaje

	ld a, personaje_offsetPosicionY(ix)	;; coge pos Y y le resta la mitad del tama?o vertical del mapa
	ld b, #render_mapaFilas / 2
	sub b
	ld b, a								;; asi conseguimos la posicion Y en la que empezar a dibujar

	ld a, personaje_offsetPosicionX(ix)	;; lo mismo que antes con X
	ld b, #render_mapaColumnas / 2
	sub b
	ld c, a
.endm