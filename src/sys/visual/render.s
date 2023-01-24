;;
;; SISTEMA VISUAL/RENDER.S
;;

.include "render.h.s"
.include "gui.h.s"
.include "assets/sprites.h.s"
.include "man/partida.h.s"
.include "man/personaje.h.s"
.include "man/mapa/mapa.h.s"
.include "utils/draw.h.s"

;;ESTO ESTA MUY DESORDENADO, POR FAVOR HAZ UN RENDER_ACTUALIZAR O ALGO

render_posicionY: .db 0
render_posicionX: .db 0
render_tamanoMapa: .dw 0
render_mapaPosicionY: .db 0
render_mapaPosicionX: .db 0
render_lastMapaPosicionY: .db 0 ;;quitar
render_lastMapaPosicionX: .db 0
render_numPersonajes: .db 0


;;Espera x interrupciones (6 ~= 1 refresco de pantalla; 300 ~= 1 segundo)
;;RECIBE: interrupciones en a
;;UTILIZA: a
render_esperar:
	halt
	dec a
	jr nz, render_esperar
	ret

render_animarAtaqueVida::
	ld iy, #render_posicionY


	ld a, personaje_offsetPosicionY(ix)		;; bc = yx pos
	ld b, render_mapaPosY(iy)				;; logica para comprobar si esta dentro del mapa virtual
	sub b
	sla a
	sla a
	sla a
	sla a
	ld b, a
	ld a, personaje_offsetPosicionX(ix)		;; bc = yx pos
	ld c, render_mapaPosX(iy)				;; logica para comprobar si esta dentro del mapa virtual
	sub c
	sla a
	sla a
	sla a
	ld c, a									;; ahora BC = YX en el render
	ld de, #0xc000
	call cpct_getScreenPtr_asm    		;; Calculate video memory location and return it in HL
	ex de, hl
	ld hl, #_m_hitMasked
	ld bc, #render_tamanoSprite
	call cpct_drawSpriteMasked_asm
	
	ld a, #60
    call render_esperar
	ret

render_animarAtaqueEscudo::
	ld iy, #render_posicionY


	ld a, personaje_offsetPosicionY(ix)		;; bc = yx pos
	ld b, render_mapaPosY(iy)				;; logica para comprobar si esta dentro del mapa virtual
	sub b
	sla a
	sla a
	sla a
	sla a
	ld b, a
	ld a, personaje_offsetPosicionX(ix)		;; bc = yx pos
	ld c, render_mapaPosX(iy)				;; logica para comprobar si esta dentro del mapa virtual
	sub c
	sla a
	sla a
	sla a
	ld c, a									;; ahora BC = YX en el render
	ld de, #0xc000
	call cpct_getScreenPtr_asm    		;; Calculate video memory location and return it in HL
	ex de, hl
	ld hl, #_m_hitEscudoMasked
	ld bc, #render_tamanoSprite
	call cpct_drawSpriteMasked_asm
	
	ld a, #60
    call render_esperar
	ret

;; dibuja el mapa en pantalla
;; entrada
;; destruye AF, BC, DE, HL 
;; salida
render_dibujarMapa::
    ; ;;limpia la pantalla
	call gui_actualizar

	call render_inicializaMemoria						;; iniciliza la memoria
	
	ld hl, #mapa_actual								;; de = puntero a mapa
	push hl											;; mas adelante deberia sustituir el push por memoria estatica

	render_dibujarMapa_dibujarMapaLoop:

		render_getScreenPtr							;; de = puntero vram
		
		call render_dibujarCelda

		ld a, render_posX(iy)						;; carga x(bytes) para incrementarlo segun el tama?o de la celda
		add #render_tamanoContador
		cp a, #render_mapaColumnas * #render_tamanoContador
		ld render_posX(iy), a						;; guarda x actualizado
		jr nz, #render_dibujarMapa_saltarCarry					;; si se llega al limite en x se aumenta y
			ld render_posX(iy), #0					;; x = 0			
			ld a, render_posY(iy)					;; carga y(filas) para incrementarlo segun el tama?o de la celda
			add #render_tamanoCelda * 8
			ld render_posY(iy), a						
		render_dibujarMapa_saltarCarry:
		
		;; esto debe ser muy ineficiente, comprobar ciclos de reloj y alternativas
		render_decrementarContadorCeldas

		;; si h o l son diferentes de cero el ciclo continua
		xor a										;; set a = 0
		cp l										;; si l != 0 vuelve al loop
		jr nz, #render_dibujarMapa_dibujarMapaLoop
		cp h										;; si h != 0 vuelve al loop
		jr nz, #render_dibujarMapa_dibujarMapaLoop
	pop hl										;; limpia el stack
	ret 

render_dibujarCelda::
	ld a, render_posX(iy)
	sra a
	sra a
	sra a
	add render_mapaPosX(iy)
	ld b, a
	ld a, render_posY(iy)
	sra a
	sra a
	sra a
	sra a
	add render_mapaPosY(iy)
	ld c, a
	ld ix, #mapa_actual
	push bc
	push de
	call mapa_getCelda
	pop de
	;; Carga el hueco, si es un muro, carga el muro
	ld bc, #render_tamanoSprite			;; bc = sprite array size
	call render_placeholderGetSprite	;; hl = sprite pointer (no implementado);; z = masked
	jr z, render_dibujarCelda_dibujarMasked
		call cpct_drawSprite_asm			;; dibuja un sprite
		pop bc
		ret
	render_dibujarCelda_dibujarMasked:
	pop bc
	push hl
	push de
	call personaje_enemigoEnPosicion
	ld de, #12
	add hl, de
	ld a, (hl)
	call render_placeholderGetSprite
	pop de
	push de
	ld bc, #render_tamanoSprite
	call cpct_drawSprite_asm
	pop de
	pop hl
	ld bc, #render_tamanoSprite
	call cpct_drawSpriteMasked_asm
	ret

render_inicializaMemoria::	
	ld ix, #personaje_jugador				;; carga puntero a personaje
	ld iy, #render_posicionY
	;; carga la posicion Y del mapa virtual que se va a dibujar teniendo en cuenta la pos del personaje
	ld a, personaje_offsetPosicionY(ix)		;; coge pos Y y le resta la mitad del tama?o vertical del mapa
	ld b, #render_mapaFilas / 2
	sub b									;; asi conseguimos la posicion Y en la que empezar a dibujar
	jr nc, #render_limiteSuperior			;; si al restar es negativo, lo ponemos a 0
		xor a
	render_limiteSuperior:
	
	push af
	ld a, (mapa_filas)
	sub #render_mapaFilas
	ld e, a
	pop af
	cp e	;; si es superior a filas - renderFilas
	jr c, #render_limiteInferior
		ld a, e	;; lo ponemos a filas - renderFilas
	render_limiteInferior:
	ld render_mapaPosY(iy), a					;; guarda la posicion
	
	;; carga la posicion X del mapa virtual que se va a dibujar teniendo en cuenta la pos del personaje
	ld a, personaje_offsetPosicionX(ix)		;; lo mismo que antes con X
	ld b, #render_mapaColumnas / 2
	sub b
	jr nc, #render_limiteIzquierdo			;; si al restar es negativo, lo ponemos a 0
		xor a
	render_limiteIzquierdo:
	
	push af
	ld a, (mapa_columnas)
	sub #render_mapaColumnas
	ld e, a
	pop af
	cp e	;; si es superior a columnas - renderColumnas
	jr c, #render_limiteDerecho
		ld a, e	;; lo ponemos a columnas - renderColumnas
	render_limiteDerecho:
	ld render_mapaPosX(iy), a					;;guarda la posicion

	xor a
	ld render_posY(iy), a
	ld render_posX(iy), a
	ld hl, #render_mapaColumnas * #render_mapaFilas	;; contador de celdas a dibujar
	ld render_tamanoMapaAlto(iy), h
	ld render_tamanoMapaBajo(iy), l
	ret

;; placeholder para cuando tengamos que buscar el sprite
;; deberia evaluar pared o suelo
render_placeholderGetSprite:
	;;esto debe ir lo ultimo
	cp #mapa_simboloEnemigo1
	jr nz, render_placeholderGetSprite_notEnemigo1
	ld hl, #_m_enemy1Masked
	xor a
	ret
	render_placeholderGetSprite_notEnemigo1:
	cp #mapa_simboloEnemigo2
	jr nz, render_placeholderGetSprite_notEnemigo2
	ld hl, #_m_enemy2Masked
	xor a
	ret
	render_placeholderGetSprite_notEnemigo2:
	cp #mapa_simboloEnemigo3
	jr nz, render_placeholderGetSprite_notEnemigo3
	ld hl, #_m_enemy3Masked
	xor a
	ret
	render_placeholderGetSprite_notEnemigo3:
	cp #mapa_simboloEnemigo4
	jr nz, render_placeholderGetSprite_notEnemigo4
	ld hl, #_m_enemy4Masked
	xor a
	ret
	render_placeholderGetSprite_notEnemigo4:
	cp #mapa_simboloEnemigo5
	jr nz, render_placeholderGetSprite_notEnemigo5
	ld hl, #_m_enemy5Masked
	xor a
	ret
	render_placeholderGetSprite_notEnemigo5:
	cp #mapa_simboloEnemigo6
	jr nz, render_placeholderGetSprite_notEnemigo6
	ld hl, #_m_enemy6Masked
	xor a
	ret
	render_placeholderGetSprite_notEnemigo6:

	ld hl, #_spTile
	cp #mapa_simboloPared
	jr nz, render_placeholderGetSprite_notWall
	ld hl, #_spWall
	render_placeholderGetSprite_notWall:
	cp #mapa_simboloJugador
	jr nz, render_placeholderGetSprite_notJugador
	ld hl, #_spPlayer
	render_placeholderGetSprite_notJugador:
	cp #mapa_simboloVacio
	jr nz, render_placeholderGetSprite_notVoid
	ld hl, #_spVoidTile
	render_placeholderGetSprite_notVoid:
	cp #mapa_simboloAscensor
	jr nz, render_placeholderGetSprite_notAscensor
	ld hl, #_spAscensor
	render_placeholderGetSprite_notAscensor:
	cp #mapa_simboloHealthUp
	jr nz, render_placeholderGetSprite_notHealthUp
	ld hl, #_spHealthUp
	render_placeholderGetSprite_notHealthUp:

	cp #mapa_simboloHealthMaxUp
	jr nz, render_placeholderGetSprite_notHealthMaxUp
	ld hl, #_spHealthMaxUp
	render_placeholderGetSprite_notHealthMaxUp:

	cp #mapa_simboloAtkUp
	jr nz, render_placeholderGetSprite_notAtkUp
	ld hl, #_spAtk
	render_placeholderGetSprite_notAtkUp:

	cp #mapa_simboloDefUp
	jr nz, render_placeholderGetSprite_notDefUp
	ld hl, #_spDef
	render_placeholderGetSprite_notDefUp:

	cp #mapa_simboloSpdUp
	jr nz, render_placeholderGetSprite_notSpdUp
	ld hl, #_spSpd
	render_placeholderGetSprite_notSpdUp:
	ld a, #1
	or a
	ret

;;dibuja los personajes // ahora mismo no comprueba si el personaje est vivo
;; entrada
;; destruye AF, BC, DE, HL
;; salida
;render_borrarPersonajes::
	; ld ix, #render_dibujarPersonaje_saltarInstruccion
	; ld (ix), #jrHexcode									;; carga un salto relativo
	; ld 1(ix), #render_tamanoGetSpritePtrPersonaje			;; tama?o de macro render_getSpritePtrPersonaje
;render_dibujarPersonajes::
	; call gui_actualizar
	; ld iy, #personaje_jugador								;; iy = puntero a array de personajes
	; ld ix, #render_posicionY								;; ix = puntero a memoria de render

	; ld a, (personaje_numEnemigos)							;; a = tama?o array de enemigos
	; inc a													;; a++ para incluir al jugador
	; ld (render_numPersonajes), a							;; guarda el tama?o en render_numPersonajes

	; render_dibujarPersonaje_dibujarPersonajesLoop:
	; 	;;destruye AF, BC, DE, HL
	; 	render_getScreenPtrPersonaje						;; de = puntero vram
	;   call render_placeholderGetSprite
	; 	render_dibujarPersonaje_saltarInstruccion:			;; direccion para modificar el salto relativo
	; 		.dw 0											;; salta render_getSpritePtrPersonaje
	; 	render_getSpritePtrPersonaje						;; hl = puntero a sprite

	; 	ld bc, #render_tamanoSprite							;; bc = sprite array size
	; 	call cpct_drawSprite_asm							;; dibuja un sprite
	; 	render_saltaDibujarPersonaje:
	; 	ld de, #personaje_sizeOf							;; de = tama?o de personaje
	; 	add iy, de											;; ix = siguiente personaje

	; 	ld a, (render_numPersonajes)						;; a = contador personajes
	; 	dec a
	; 	ld (render_numPersonajes), a
	; 	jr nz, #render_dibujarPersonaje_dibujarPersonajesLoop	;; a-- y salta si render_numPersonajes = 0
	
	; ld ix, #render_dibujarPersonaje_saltarInstruccion
	; ld (ix), #0
	; ld 1(ix), #0
;	ret

