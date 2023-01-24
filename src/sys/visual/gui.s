;;
;; SISTEMA VISUAL/GUI.S
;;

.include "gui.h.s"
.include "render.h.s"
.include "utils/draw.h.s"
.include "man/personaje.h.s"
.include "assets/sprites.h.s"

.include "macros/cpct_undocumentedOpcodes.h.s"

gui_inicioRonda::
    ;;empiezas dibujando un cafe de mas
    ld hl, #gui_actualizar_spdInit
    ld (hl), #0xFF
    ret
;; QUE ALGUIEN ARREGLE ESTO POR FAVOR.
gui_pintarBase::
    ;;dibuja el borde derecho
    
    ld iy, #_spRightBound
    ld bc, #0x8048
    call gui_dibujarSprite
    ld iy, #_spRightBound
    ld bc, #0x9048
    call gui_dibujarSprite
    ld iy, #_spRightBound
    ld bc, #0xA048
    call gui_dibujarSprite
    ld iy, #_spRightBound
    ld bc, #0xB048
    call gui_dibujarSprite
    ;;dibuja la esquina inferior derecha
    ld iy, #_spLowerRightCorner
    ld bc, #0xB848
    call gui_dibujarSprite
    ;;dibuja el borde inferior
    ld iy, #_spLowerBound
    ld bc, #0xB840
    call gui_dibujarSprite
    ld iy, #_spLowerBound
    ld bc, #0xB838
    call gui_dibujarSprite
    ld iy, #_spLowerBound
    ld bc, #0xB830
    call gui_dibujarSprite
    ld iy, #_spLowerBound
    ld bc, #0xB828
    call gui_dibujarSprite
    ld iy, #_spLowerBound
    ld bc, #0xB820
    call gui_dibujarSprite
    ld iy, #_spLowerBound
    ld bc, #0xB818
    call gui_dibujarSprite
    ld iy, #_spLowerBound
    ld bc, #0xB810
    call gui_dibujarSprite
    ld iy, #_spLowerBound
    ld bc, #0xB808
    call gui_dibujarSprite
    ;;dibuja la esquina inferior izquierda
    ld iy, #_spLowerLeftCorner
    ld bc, #0xB800
    call gui_dibujarSprite
    ;;dibuja el borde izquierdo
    ld iy, #_spLeftBound
    ld bc, #0xB000
    call gui_dibujarSprite
    ld iy, #_spLeftBound
    ld bc, #0xA000
    call gui_dibujarSprite
    ld iy, #_spLeftBound
    ld bc, #0x9000
    call gui_dibujarSprite
    ;;dibuja la esquina superior izquierdo
    ld iy, #_spUpperLeftCorner
    ld bc, #0x8000
    call gui_dibujarSprite
    ;;dibuja el borde de arriba de la caja
    ld iy, #_spUpperBound
    ld bc, #0x8008
    call gui_dibujarSprite
    ld iy, #_spUpperBound
    ld bc, #0x8010
    call gui_dibujarSprite
    ld iy, #_spUpperBound
    ld bc, #0x8018
    call gui_dibujarSprite
    ld iy, #_spUpperBound
    ld bc, #0x8020
    call gui_dibujarSprite
    ld iy, #_spUpperBound
    ld bc, #0x8028
    call gui_dibujarSprite
    ld iy, #_spUpperBound
    ld bc, #0x8030
    call gui_dibujarSprite
    ld iy, #_spUpperBound
    ld bc, #0x8038
    call gui_dibujarSprite
    ld iy, #_spUpperBound
    ld bc, #0x8040
    call gui_dibujarSprite
    ld iy, #_spUpperBound
    ld bc, #0x8048
    call gui_dibujarSprite

    ;;dibuja la esquina superior derecha
    ld iy, #_spUpperRightCorner
    ld bc, #0x8048
    call gui_dibujarSprite
    ret

;;Este codigo es el peor que he hecho nunca y me arrepiento de haber nacido.
;;UTILIZA TODO PROBABLEMENTE AAAAAAAAAAAAA SON LAS 3:38 NO QUIERO SEGUIR
;;       AF, BC, DE, HL, IX, IY
;;DEVUELVE: nada, de momento
gui_actualizar::

    
    call gui_limpiarGUI
    

    ld ix, #personaje_jugador
    ;;ATK
    ld b, #0x00 ;;contador de dibujados
    ld c, #0x00 ;;contador desplazamiento
    ;;guarda en iy el sprite
    ld iy, #_spAtkMasked
    ;;guarda la posicion
    ld hl, #gui_atkPos
    ld (gui_statIterar_sprite), hl
    gui_actualizar_atkLoop:
        ;;obtiene el atk del personaje
        ld d, b
        ld a, personaje_offsetHealthAtk(ix)
        personaje_getAtk
        ;;si no queda ataques acaba
        ld b, d
        cp b
        jr z, gui_actualizar_atkLoopSalida
        ;;si queda stat dibuja una
        call gui_statIterar
        jr gui_actualizar_atkLoop
    gui_actualizar_atkLoopSalida:
        cp #personaje_maxAtk
        jr nz, gui_actualizar_atkNoFull
        ;;Si esta a tope de atk, dibuja el full
        ld a, c
        ld bc, #gui_atkPos
        add a, c
        ld c, a
        ld iy, #_spFullMasked
        call gui_dibujarSprite
    gui_actualizar_atkNoFull:
    
    ;;HEALTH
    ld b, #0x00 ;;contador de dibujados
    ld c, #0x00 ;;contador desplazamiento
    ;;guarda en iy el sprite
    ld iy, #_spHealthMasked
    ;;guarda la posicion
    ld hl, #gui_healthPos
    ld (gui_statIterar_sprite), hl
    gui_actualizar_healthLoop:
        ;;obtiene el health del personaje
        ld d, b
        ld a, personaje_offsetHealthAtk(ix)
        personaje_getHealthAct
        ;;si no queda vida acaba
        ld b, d
        cp b
        jr z, gui_actualizar_healthLoopSalida
        ;;si queda stat dibuja una
        call gui_statIterar
        jr gui_actualizar_healthLoop
    gui_actualizar_healthLoopSalida:
        ;;guarda en iy el sprite
        ld iy, #_spHealthEmptyMasked
    gui_actualizar_healthMaxLoop:
        ;;obtiene el health max del personaje
        ld d, b
        ld a, personaje_offsetHealthAtk(ix)
        personaje_getHealthMax
        ;;si no queda vida max acaba
        ld b, d
        cp b
        jr z, gui_actualizar_healthMaxLoopSalida
        ;;si queda stat dibuja una
        call gui_statIterar
        jr gui_actualizar_healthMaxLoop
        ;;cambiar el full para quede solo si maxima vida maxima
    gui_actualizar_healthMaxLoopSalida:
        cp #personaje_maxHealth
        jr nz, gui_actualizar_healthNoFull
        ;;Si esta a tope de health, dibuja el full
        ld a, c
        ld bc, #gui_healthPos
        add a, c
        ld c, a
        ld iy, #_spFullMasked
        call gui_dibujarSprite
    gui_actualizar_healthNoFull:

    ;;DEF
    ld b, #0x00 ;;contador de dibujados
    ld c, #0x00 ;;contador desplazamiento
    ;;guarda en iy el sprite
    ld iy, #_spDefMasked
    ;;guarda la posicion
    ld hl, #gui_defPos
    ld (gui_statIterar_sprite), hl
    gui_actualizar_defLoop:
        ;;obtiene el def del personaje
        ld d, b
        ld a, personaje_offsetSpdMovDef(ix)
        personaje_getDefAct
        ;;si no queda def acaba
        ld b, d
        cp b
        jr z, gui_actualizar_defLoopSalida
        ;;si queda stat dibuja una
        call gui_statIterar
        jr gui_actualizar_defLoop
    gui_actualizar_defLoopSalida:
        ld d, #personaje_maxDef
        ld a, personaje_offsetSpdMovDef(ix)
        personaje_getDefMax
        cp d
        jr nz, gui_actualizar_defNoFull
        ;;Si esta a tope de def, dibuja el full, aunque tenga daño
        ld bc, #personaje_maxDef*gui_spAncho+gui_defPos
        ld iy, #_spFullMasked
        call gui_dibujarSprite
    gui_actualizar_defNoFull:
    
    ;;SPD
    ;;dibuja una de mas
    gui_actualizar_spdInit = .+1
    ld b, #0xAA ;;contador de dibujados
    ld c, #0x00 ;;contador desplazamiento
    ;;guarda en iy el sprite
    ld iy, #_spSpdMasked
    ;;guarda la posicion
    ld hl, #gui_spdPos
    ld (gui_statIterar_sprite), hl
    gui_actualizar_spdLoop:
        ;;obtiene el spd del personaje
        ld d, b
        ld a, personaje_offsetSpdMovDef(ix)
        personaje_getSpd
        ;;si no queda ataques acaba
        ld b, d
        cp b
        jr z, gui_actualizar_spdLoopSalida
        ;;si queda stat dibuja una
        call gui_statIterar
        jr gui_actualizar_spdLoop
    gui_actualizar_spdLoopSalida:
        cp #personaje_maxSpd
        jr nz, gui_actualizar_spdNoFull
        ;;Si esta a tope de spd, dibuja el full
        ld bc, #personaje_maxSpd*gui_spAncho+gui_spdPos+gui_spAncho ;;uno extra por el cafe extra
        ld iy, #_spFullMasked
        call gui_dibujarSprite
    gui_actualizar_spdNoFull:
    ;;si has dibujado algun cafe, a la siguiente dibujas uno menos
    ;;cargas tu velocidad
    ld a, personaje_offsetSpdMovDef(ix)
    personaje_getSpd
    ;;la comparas con los cafes que no dibujas
    ld hl, #gui_actualizar_spdInit
    ;;si son iguales, pues no dibujas ninguno
    cp (hl)
    jr z, gui_actualizar_noDibujasCafes
    ;;si no son iguales, sumas uno a los que no dibujas a la siguiente
    inc (hl)
    gui_actualizar_noDibujasCafes:
    ret

;;guarrada para ahorrar lineas de codigo
gui_statIterar:
    push bc
    ;;calcula la nueva posicion
    ;;mueve c un poco como quiere porque la x y la y deberían de ser independientes
    ld a, c
    gui_statIterar_sprite = .+1
    ld bc, #0xADDE
    add a, c
    ld c, a
    call gui_dibujarSprite
    pop bc
    ;;itera
    inc b
    ld a, c
    add a, #gui_spAncho
    ld c, a
    ret
;;Dibuja un sprite en una posicion
;;RECIBE: posicion yx en bc, puntero al sprite en iy
;;UTILIZA: AF, BC, DE, HL 
gui_dibujarSprite:
        ld de, #0xc000				;; de = start vram
        call cpct_getScreenPtr_asm  ;; Calculate video memory location and return it in HL
        ld__d_iyh
        ld__e_iyl                 ;; de = sprite pointer (no implementado)
        ex de, hl	
        ld bc, #render_tamanoSprite	;; bc = sprite array size
        call cpct_drawSprite_asm	;; dibuja un sprite
        ret

;;limpia la pantalla para volver a dibujar la gui
gui_limpiarGUI::
	ld de, #0xC000
	ld b, #130
	ld c, #2
	call cpct_getScreenPtr_asm
	ex de, hl
	ld a, #0xC3
	ld b, #60
	ld c, #64
	call cpct_drawSolidBox_asm
	ld de, #0xC000
	ld b, #130
	ld c, #60
	call cpct_getScreenPtr_asm
	ex de, hl
	ld a, #0xC3
	ld b, #60
	ld c, #15
	call cpct_drawSolidBox_asm
	ret