;;
;; SISTEMA CONTROL/AI.S
;;

.include "AI.h.s"
.include "../fisica/fisica.h.s"
.include "../../man/personaje.h.s"
.include "../../man/partida.h.s"
.include "../../man/mapa/mapa.h.s"
.include "../../utils/draw.h.s"
.include "../../utils/math.h.s"
.include "../../man/mapa/mapa.h.s"

;Función para las pruebas del sistema de IA
AI_pruebas::
    ret


;Flag para que la función AI_persigueJugador vaya alternando entre probar primero vertical y horizontal
AI_flagAlternarMovimiento: .db #0x00
;Función de acción para que un personaje persiga al jugador
;INPUT:
;   
;RETURNS:
;       HL: Constante que indica a física hacia dónde moverse (ej:fisica_moverDerecha) 
;DESTROYS:
;       AF,BC,DE,HL
;
AI_persigueJugador::
    ld ix, #personaje_jugador             ;Cargo la información del personaje Jugador en IX
    ld b,personaje_offsetPosicionX(ix)    ;Y ahora muevo a BC la coordenada XY del Jugador     
    ld c,personaje_offsetPosicionY(ix)    
    
    ld ix,(#partida_entidadActiva)        ;Cargo la información del personaje perseguidor en IX
    ld d,personaje_offsetPosicionX(ix)    ;Y muevo a DE la coordenada XY del enemigo perseguidor
    ld e,personaje_offsetPosicionY(ix)
    
    ld a, (AI_flagAlternarMovimiento) ;Cargamos en A el flag de alternar movimiento
    cp #0                                 ;Dará Z o NZ en función de como esté el flag para alternar movimiento  
    call AI_moveTo

    ld a,(AI_flagAlternarMovimiento)
    cpl                                                 ;Invertimos el flag de probar primero horizontal o vertical
    ld (AI_flagAlternarMovimiento),a
    ret

;
; Función de acción para que un personaje se mueva de forma aleatoria por el mapa
; INPUT:
;        Nada
; RETURNS:
;        HL: Constante que indica a física hacia dónde moverse (ej:fisica_moverDerecha).
; DESTROYS:
;        AF,BC,DE,HL
;
AI_movimientoRandom::
    call cpct_getRandom_mxor_u8_asm       ;Devuelve en L un valor aleatorio
    ld a,l                                ;Cargamos en A el valor random
    ld hl,#mapa_columnas
    ld l,(hl)                             ;Cargamos en L el tamaño X del mapa
    call math_modulo                      ;Calculamos el módulo numeroRandom%tamañoXDelMapa, para obtener una coordenada X dentro del mapa
    push af                                ;Nos guardamos A en la pila

    call cpct_getRandom_mxor_u8_asm       ;Devuelve en L un valor aleatorio
    ld a,l                                ;Cargamos en A el valor random
    ld hl,#mapa_filas
    ld l,(hl)                             ;Cargamos en L el tamaño Y del mapa
    
    
    call math_modulo                      ;Calculamos el módulo numeroRandom%tamañoYDelMapa, para obtener una coordenada Y dentro del mapa
    pop bc                                ;Recuperamos en BC la coordenada XY del punto objetivo
    ld c,a

    ld ix,(#partida_entidadActiva)        ;Cargo la información del personaje perseguidor en IX
    ld d,personaje_offsetPosicionX(ix)    ;Y muevo a DE la coordenada XY del enemigo perseguidor
    ld e,personaje_offsetPosicionY(ix)


    call AI_moveTo
ret

;
; Función de acción para que un personaje se mueva de forma aleatoria por el mapa
; hasta encontrar en su rango de visión (4) al jugador, en ese caso le seguirá hasta que uno de
; los dos muera o lo pierda de vista.
; INPUT:
;       Nada
; RETURNS:
;       HL: Constante que indica a física hacia dónde moverse (ej:fisica_moverDerecha). Si recibe como objetivo el punto en el que se encuentra devuelve fisica_noMover.
; DESTROYS:
;
AI_persigueVisionR4::
    ld ix,(#partida_entidadActiva)        ;Cargo la información del personaje perseguidor en IX
    ld d,personaje_offsetPosicionX(ix)    ;Y muevo a DE la coordenada XY del enemigo perseguidor
    ld e,personaje_offsetPosicionY(ix)
    ld b, #4
    ld c, #mapa_simboloJugador

    
    call AI_buscaEnRangoJugador
    jp z, AI_persigueVisionR4_persigue
    call AI_standby
    ret
    AI_persigueVisionR4_persigue:
        call AI_persigueJugador
    ret


;
; Función que dada la posición de un personaje, devuelve Z si este puede ataccar al jugador en 1 turno,
; es decir, si está a un paso de éste, y de ser así el movimiento que el enemigo debe hacer para atacarlo
; INPUT:
;       DE: Posición del personaje que queremos ver si puede atacar
; RETURNS:
;       Z: Si el jugador está en posición atacable, NZ: si no el jugador no está en posición atacable
;       HL: Movimiento físico que el personaje debe hacer para atacar al jugador (ej: mover derecha)
; DESTROYS:
;       A, IX
AI_jugadorAtacable::
    ld ix, #personaje_jugador             ;Cargo la información del personaje Jugador en IX
    ld b,personaje_offsetPosicionX(ix)    ;Y ahora muevo a BC la coordenada XY del Jugador     
    ld c,personaje_offsetPosicionY(ix) 

    push de
    push bc

    ;Empezamos comprobando la izquierda
    AI_jugadorAtacable_compruebaIzquierda:
        ld a, b
        inc a
        cp d
        jp nz, #AI_jugadorAtacable_compruebaDerecha
    ;Si está a 1 de distancia en la horizontal, comprobamos que esté a 0 en la vertical
        ld a, c
        cp e
        jp z, #AI_jugadorAtacable_atacaIzquierda

    AI_jugadorAtacable_compruebaDerecha:
        ld a, b
        inc d
        cp d
        jp nz, #AI_jugadorAtacable_compruebaArriba
        ;Si está a 1 de distancia en la horizontal, comprobamos que esté a 0 en la vertical
        ld a, c
        cp e
        jp z, #AI_jugadorAtacable_atacaDerecha

    AI_jugadorAtacable_compruebaArriba:
        dec d
        ld a, c
        inc a
        cp e
        jp nz, #AI_jugadorAtacable_compruebaAbajo
        ;Si está a 1 de distancia en l vertical, comprobamos que esté a 0 en la horizontal
        ld a,b
        cp d
        jp z, #AI_jugadorAtacable_atacaArriba

    AI_jugadorAtacable_compruebaAbajo:
        ld a, c
        inc e
        cp e
        jp nz, #AI_jugadorAtacable_noAtacable
        ;Si está a 1 de distancia en l vertical, comprobamos que esté a 0 en la horizontal
        ld a,b
        cp d
        jp z, #AI_jugadorAtacable_atacaAbajo


    AI_jugadorAtacable_noAtacable:
        jp AI_jugadorAtacable_return         ;Si ha llegado aqui es que vale NZ

    AI_jugadorAtacable_atacaIzquierda:
        ld hl, #fisica_moverIzquierda
        jp AI_jugadorAtacable_return

    AI_jugadorAtacable_atacaDerecha:
        ld hl, #fisica_moverDerecha
        jp AI_jugadorAtacable_return

    AI_jugadorAtacable_atacaArriba:
        ld hl, #fisica_moverArriba
        jp AI_jugadorAtacable_return

    AI_jugadorAtacable_atacaAbajo:
        ld hl, #fisica_moverAbajo
        jp AI_jugadorAtacable_return

    AI_jugadorAtacable_return:
        pop bc
        pop de
        ret






    




;
; Función de acción para que un personaje se mueva de forma aleatoria por el mapa
; hasta encontrar en su rango de visión (4) al jugador, en ese caso le seguirá hasta que uno de
; los dos muera o lo pierda de vista.
; INPUT:
;       Nada
; RETURNS:
;       HL: Constante que indica a física hacia dónde moverse (ej:fisica_moverDerecha). Si recibe como objetivo el punto en el que se encuentra devuelve fisica_noMover.
; DESTROYS:
;
AI_defensivoVisionR4::
    ld ix,(#partida_entidadActiva)        ;Cargo la información del personaje perseguidor en IX
    ld d,personaje_offsetPosicionX(ix)    ;Y muevo a DE la coordenada XY del enemigo perseguidor
    ld e,personaje_offsetPosicionY(ix)

    ;Antes que nada, vemos si el jugador está en posición atacable, de ser así, le atacamos
    call AI_jugadorAtacable
    ret z

    ;Si no podemos atacar y estamos sobre un objeto no nos movemos, para seguir defendiendolo
    ld ix,(#partida_entidadActiva)
    ld a, personaje_offsetSimboloPisando(ix)    ;Obtenemos en A el símbolo que está pisando el personaje, para comprobar si es un objeto a defender
    or a    
    jp z,#AI_defensivoVisionR4_noCasosBase    ;Si es 0 (NO está sobre un objeto) toacará buscar el objeto más cercano
    ld hl, #fisica_noMover  ;Si sí que está sobre un objeto, no se mueve, lo defiende
    ret


    AI_defensivoVisionR4_noCasosBase:
    ;Usamos un bucle de 1 a R para ir aumentando el radio y que vaya siempre al objeto más cercano que encuentre
    ld b, #1
    push de
    ld c, #mapa_simboloJugador
    AI_defensivoVisionR4_bucle:
        push de
        push bc
        call AI_buscaEnRangoItems
        pop bc
        pop de
        jr z, #AI_buscaEnRangoItems_encontrado
        inc b
        ld a, #4                            ;Aquí le decimos el radio máximo en el que buscar
        cp b
        jr z, #AI_buscaEnRangoItems_noEncontrado
        jr #AI_defensivoVisionR4_bucle

    AI_buscaEnRangoItems_noEncontrado:
    or #1                                  ;Ponemos NZ (no encontrado)
    AI_buscaEnRangoItems_encontrado:
    push hl
    pop bc
    jp z, AI_defensivoVisionR4_persigue
    pop de
    call AI_standby
    ret
    AI_defensivoVisionR4_persigue:
        ld a, #1
        ld hl,#AI_flagAlternarMovimiento
        xor (hl)
        ld (AI_flagAlternarMovimiento),a
        pop de
        call AI_moveTo

    ret








;
; Función de acción para que un personaje realice una patrulla horizontal de tres casillas
; es decir una a izq y otra a der de la de inicio.
; INPUT:
;       Nada
; RETURNS:
;       HL: Movimiento a realizar
;
;AI_patrolH3::




; Función para que el personaje no se mueva
; INPUT:
;       Nada
; RETURNS:
;       HL: #fisica_noMover
;
AI_standby::
    ld hl, #fisica_noMover
    ret



; Variables de control de los bucles anidados en la función AI_buscaEnRango
AI_buscaEnRango_j: .db #0x00
AI_buscaEnRango_i: .db #0x00
AI_buscaEnRango_inicioJ: .db #0x00
AI_buscaEnRango_finJ: .db #0x00
AI_buscaEnRango_finI: .db #0x00
; Función que dado un radio, una posición XY de origen y un código de entidad (de los
; que usamos en mapa para representarlas) nos devuelve Z si una entidad del tipo de 
; cuyo código le hemos pasado se encuentra dentro del rango dado respecto al origen.
; INPUT:
;       DE: Posición de origen (D=X, E=Y)
;       B: Radio del cuadrado en la que buscar
;       C: Código de tipo de entidad a buscar
; RETURNS:
;       Z: Z Si encuentra en el cuadrado de radio B el tipo de entidad buscado.  NZ si no encuentra en el cuadrado de radio B el tipo de entidad buscado
;       HL: Posición dónde lo encuentra
; DESTROYS:
;
; KNOWN LIMITATIONS: Si le pedimos que busque una entidad como la que está buscando siempre
; se encontrará a si mismo y por tanto devolverá True.
;
 AI_buscaEnRango::
    ld a, d
    sub b               ;Restamos X-R (dónde X es la coordenada X del origen y R el radio de búsqueda) que es la primera X a buscar
    ld (AI_buscaEnRango_i), a
    add b
    add b
    ld (AI_buscaEnRango_finI), a

    ld a, e
    sub b               ;Restamos Y-R (dónde X es la coordenada X del origen y R el radio de búsqueda) que es la primera Y a buscar
    ld (AI_buscaEnRango_j), a
    ld (AI_buscaEnRango_inicioJ), a
    add b
    add b
    ld (AI_buscaEnRango_finJ), a

    AI_buscaEnRango_outerLoop:
        AI_buscaEnRango_innerLoop:
            push bc                         ;Nos guardamos BC (Radio y código a buscar) en pila
            ld bc, (AI_buscaEnRango_j)      ;Como i y j se guardan seguidas en memoria con cargar i en bc j se carga en c e i en b
            
            ld a, b                         ;Comprobamos si alguna de las coordenadas es negativa, de ser así no miramos esa celda
            or b
            jp m,#AI_buscaEnRango_celdaNegativa
            ld a, c
            or c
            jp m,#AI_buscaEnRango_celdaNegativa
            
            ld ix, #mapa_actual             ;Si ninguno de las coordenadas es negativa, guardamos el puntero al mapa en IX
            call mapa_getCelda              ;Consultamos el contenido del mapa en el punto (I,J). Lo devuelve en A.
            pop bc
            cp a,c
            ld hl,(AI_buscaEnRango_j)
            ret z                           ;Si coincide el contenido de la celda y el elemento buscado, devolvemos Z
            AI_buscaEnRango_celdaNegativa:  ;Si la celda a buscar contiene un elemento negativo saltamos aquí
            pop bc
            ld hl, #AI_buscaEnRango_j        ;Incrementamos la variable de  control interna
            inc (hl)
            ld a,(AI_buscaEnRango_finJ)
            cp (hl)                         ;Vemos si la variable de control del eje Y supera el tamaño del mapa
            jp p, AI_buscaEnRango_innerLoop
        ld a, (AI_buscaEnRango_inicioJ)                         
        ld (AI_buscaEnRango_j),a             ;Reiniciamos el bucle interior

        ld hl, #AI_buscaEnRango_i            ;Incrementamos la variable de  control externa
        inc (hl)
        ld a,(AI_buscaEnRango_finI)
        cp (hl)                         ;Vemos si la variable de control del eje Y supera el tamaño del mapa
        jp p, AI_buscaEnRango_outerLoop

    ret         ;Si el código llega aquí siempre valdrá NZ, si no habría saltado en el jp p de antes





; Función que dado un radio, una posición XY de origen y un código de entidad (de los
; que usamos en mapa para representarlas) nos devuelve Z si una entidad del tipo de 
; cuyo código le hemos pasado se encuentra dentro del rango dado respecto al origen.
; INPUT:
;       DE: Posición de origen (D=X, E=Y)
;       B: Radio del cuadrado en la que buscar
;       C: Código de tipo de entidad a buscar
; RETURNS:
;       Z: Z Si encuentra en el cuadrado de radio B el tipo de entidad buscado.  NZ si no encuentra en el cuadrado de radio B el tipo de entidad buscado
;       HL: Posición dónde lo encuentra
; DESTROYS:
;
; KNOWN LIMITATIONS: Si le pedimos que busque una entidad como la que está buscando siempre
; se encontrará a si mismo y por tanto devolverá True.
;
AI_buscaEnRangoJugador::
    ld a, d
    sub b               ;Restamos X-R (dónde X es la coordenada X del origen y R el radio de búsqueda) que es la primera X a buscar
    ld (AI_buscaEnRango_i), a
    add b
    add b
    ld (AI_buscaEnRango_finI), a

    ld a, e
    sub b               ;Restamos Y-R (dónde X es la coordenada X del origen y R el radio de búsqueda) que es la primera Y a buscar
    ld (AI_buscaEnRango_j), a
    ld (AI_buscaEnRango_inicioJ), a
    add b
    add b
    ld (AI_buscaEnRango_finJ), a

    AI_buscaEnRangoJugador_outerLoop:
        AI_buscaEnRangoJugador_innerLoop:
            push bc                         ;Nos guardamos BC (Radio y código a buscar) en pila
            ld bc, (AI_buscaEnRango_j)      ;Como i y j se guardan seguidas en memoria con cargar i en bc j se carga en c e i en b

            ld a, b                         ;Comprobamos si alguna de las coordenadas es negativa, de ser así no miramos esa celda
            or b
            jp m,#AI_buscaEnRangoJugador_celdaNegativa
            ld a, c
            or c
            jp m,#AI_buscaEnRangoJugador_celdaNegativa
            ;Comprobamos si está fuera del tablero
            

            ld ix, #mapa_actual             ;Guardamos el puntero al mapa en IX
            call mapa_getCelda              ;Consultamos el contenido del mapa en el punto (I,J). Lo devuelve en A.
            pop bc
            cp a,#0x10
            jp z,AI_buscaEnRangoJugador_continue       ;Si encontramos un objeto (menor de 0x80 y mayor de 0x00) devolvemos su posición en HL y Z
            jp m,AI_buscaEnRangoJugador_continue
            ld hl,(AI_buscaEnRango_j)
            and #0
            ret

            AI_buscaEnRangoJugador_celdaNegativa:
            pop bc

            AI_buscaEnRangoJugador_continue:    
            ld hl, #AI_buscaEnRango_j        ;Incrementamos la variable de  control interna
            inc (hl)
            ld a,(AI_buscaEnRango_finJ)
            cp (hl)                         ;Vemos si la variable de control del eje Y supera el tamaño del mapa
            jp p, AI_buscaEnRangoJugador_innerLoop
        ld a, (AI_buscaEnRango_inicioJ)                         
        ld (AI_buscaEnRango_j),a             ;Reiniciamos el bucle interior

        ld hl, #AI_buscaEnRango_i            ;Incrementamos la variable de  control externa
        inc (hl)
        ld a,(AI_buscaEnRango_finI)
        cp (hl)                         ;Vemos si la variable de control del eje Y supera el tamaño del mapa
        jp p, AI_buscaEnRangoJugador_outerLoop
    ret         ;Si el código llega aquí siempre valdrá NZ, si no habría saltado en el jp p de antes




; Función que dado un radio, una posición XY de origen y un código de entidad (de los
; que usamos en mapa para representarlas) nos devuelve Z si una entidad del tipo de 
; cuyo código le hemos pasado se encuentra dentro del rango dado respecto al origen.
; INPUT:
;       DE: Posición de origen (D=X, E=Y)
;       B: Radio del cuadrado en la que buscar
; RETURNS:
;       Z: Z Si encuentra en el cuadrado de radio B el tipo de entidad buscado.  NZ si no encuentra en el cuadrado de radio B el tipo de entidad buscado
;       HL: Posición dónde lo encuentra
; DESTROYS:
;
; KNOWN LIMITATIONS: Si le pedimos que busque una entidad como la que está buscando siempre
; se encontrará a si mismo y por tanto devolverá True.
;
 AI_buscaEnRangoItems::
    ld a, d
    sub b               ;Restamos X-R (dónde X es la coordenada X del origen y R el radio de búsqueda) que es la primera X a buscar
    ld (AI_buscaEnRango_i), a
    add b
    add b
    ld (AI_buscaEnRango_finI), a

    ld a, e
    sub b               ;Restamos Y-R (dónde X es la coordenada X del origen y R el radio de búsqueda) que es la primera Y a buscar
    ld (AI_buscaEnRango_j), a
    ld (AI_buscaEnRango_inicioJ), a
    add b
    add b
    ld (AI_buscaEnRango_finJ), a

    AI_buscaEnRangoItems_outerLoop:
        AI_buscaEnRangoItems_innerLoop:
            push bc                         ;Nos guardamos BC (Radio y código a buscar) en pila
            ld bc, (AI_buscaEnRango_j)      ;Como i y j se guardan seguidas en memoria con cargar i en bc j se carga en c e i en b

            ld a, b                         ;Comprobamos si alguna de las coordenadas es negativa, de ser así no miramos esa celda
            or b
            jp m,#AI_buscaEnRangoItem_celdaNegativa
            ld a, c
            or c
            jp m,#AI_buscaEnRangoItem_celdaNegativa
            ;Comprobamos si está fuera del tablero
            

            ld ix, #mapa_actual             ;Guardamos el puntero al mapa en IX
            call mapa_getCelda              ;Consultamos el contenido del mapa en el punto (I,J). Lo devuelve en A.
            pop bc
            cp a,#0x10
            jp z,AI_buscaEnRangoItems_continue       ;Si encontramos un objeto (menor de 0x80 y mayor de 0x00) devolvemos su posición en HL y Z
            jp m,AI_buscaEnRangoItems_continue
            ld hl,(AI_buscaEnRango_j)
            and #0
            ret

            AI_buscaEnRangoItem_celdaNegativa:
            pop bc

            AI_buscaEnRangoItems_continue:    
            ld hl, #AI_buscaEnRango_j        ;Incrementamos la variable de  control interna
            inc (hl)
            ld a,(AI_buscaEnRango_finJ)
            cp (hl)                         ;Vemos si la variable de control del eje Y supera el tamaño del mapa
            jp p, AI_buscaEnRangoItems_innerLoop
        ld a, (AI_buscaEnRango_inicioJ)                         
        ld (AI_buscaEnRango_j),a             ;Reiniciamos el bucle interior

        ld hl, #AI_buscaEnRango_i            ;Incrementamos la variable de  control externa
        inc (hl)
        ld a,(AI_buscaEnRango_finI)
        cp (hl)                         ;Vemos si la variable de control del eje Y supera el tamaño del mapa
        jp p, AI_buscaEnRangoItems_outerLoop
    ret         ;Si el código llega aquí siempre valdrá NZ, si no habría saltado en el jp p de antes


;
; Función simplemente para mover un personaje a un punto
; INPUT:
;       DE: Posición XY en la que se encuentra
;       BC: Posición XY hacia la que desplazarse
;       Z:  Si recibe Z intenta primero el eje X, si recibe NZ, intenta primero el eje Y
; RETURNS:
;       HL: Constante que indica a física hacia dónde moverse (ej:fisica_moverDerecha). Si recibe como objetivo el punto en el que se encuentra devuelve fisica_noMover.
; DESTROYS:
;       AF,BC,DE,HL
;
AI_moveTo::
    ;Lo primero es comprobar si el punto origen y el punto objetivo coinciden
    push af
    ld a,d                                      ;Cargamos en A la X del personaje para comparar           
    cp b                                        ;Comparamos la X del personaje (A) con la del objetivo (B)
    jp nz, AI_moveTo_sonPuntosDistintos         ;Si la X del personaje y la del objetivo son distintas, pasamos a comprobar hacia donde movernos
    ld a,e                                      ;Cargamos en A la Y del personaje para comparar
    cp c                                        ;Comparamos la Y del personaje (A) con la del objetivo (C)
    jp z, AI_moveTo_noMover                     ;Si la X y la Y del personaje y la X y la Y del objetivo son iguales, no nos movemos (estamos ya en el punto objetivo)

    ;Una vez comprobado que origen y objetivo son puntos distintos, hay que calcular hacia cónde moverse
    AI_moveTo_sonPuntosDistintos:
    pop af
    jp nz, AI_moveTo_comprobarEjeY              ;Si recibe NZ intenta primero el eje Y

    AI_moveTo_comprobarEjeX:
    ld a,d                                      ;Cargamos en A la X del personaje para comparar                         
    cp b                                        ;Comparamos la X del personaje (A) con la del objetivo (B)
    jp z, AI_moveTo_comprobarEjeY               ;Si la X del personaje es igual a la del objetivo comprobamos el eje Y
    jp p, AI_moveTo_moverIzquierda              ;Si la X del personaje es más grande movemos a la izquierda
    jp m, AI_moveTo_moverDerecha                ;Si la X del personaje es más pequeña movemos a la derecha

    AI_moveTo_comprobarEjeY:
    ld a,e                                      ;Cargamos en A la Y del personaje para comparar
    cp c                                        ;Comparamos la Y del personaje (A) con la del objetivo (C)
    jp z, AI_moveTo_comprobarEjeX               ;Si la Y del personaje es igual a la del objetivo comprobamos el eje X
    jp p, AI_moveTo_moverArriba                 ;Si la Y del personaje es más grande movemos abajo
    jp m, AI_moveTo_moverAbajo                  ;Si la Y del personaje es más pequeña movemos arriba

    AI_moveTo_moverIzquierda::
        ld hl,#fisica_moverIzquierda
        ret
    AI_moveTo_moverDerecha::
        ld hl,#fisica_moverDerecha
        ret
    AI_moveTo_moverArriba::
        ld hl,#fisica_moverArriba
        ret
    AI_moveTo_moverAbajo::
        ld hl,#fisica_moverAbajo
        ret
    AI_moveTo_noMover::
        pop af
        ld hl,#fisica_noMover
        ret