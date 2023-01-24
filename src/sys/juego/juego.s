;;
;; SISTEMA JUEGO/JUEGO.S
;;

.include "juego.h.s"

.include "assets/sprites.h.s"

.include "man/mapa/mapa.h.s"
.include "man/personaje.h.s"
.include "man/partida.h.s"
.include "man/objeto.h.s"

.include "utils/keyboard.h.s"
.include "utils/draw.h.s"
.include "utils/string.h.s"
.include "utils/math.h.s"

.include "sys/fisica/fisica.h.s"
.include "sys/juego/logica.h.s"
.include "sys/juego/turno.h.s"
.include "sys/control/control.h.s"
.include "sys/visual/render.h.s"

.include "macros/cpct_undocumentedOpcodes.h.s"

;; Define one Zero-terminated string to be used later on
;; Define one Zero-terminated string to be used later on
juego_controlesQA: .asciz "Use Q/A to move"
juego_updown: .asciz "UP/DOWN"
juego_controlesOP: .asciz "Use O/P to move"
juego_leftright: .asciz "LEFT/RIGHT"
juego_space: .asciz "SPACE"
juego_controlesSPACE: .asciz "Use SPACE"
juego_toWait: .asciz "to wait"
juego_pulsaTecla: .asciz "PRESS ANY KEY TO START";
juego_strPressAnyKey: .asciz "PRESS ANY KEY";
juego_strToStart: .asciz "TO START"
juego_tituloJuego: .asciz "RESIGNATION  QUEST"
juego_strFinDelJuego: .asciz "GAME OVER"
juego_strScore: .asciz "FINAL SCORE:"
juego_atk: .asciz "Attack damage"
juego_def: .asciz "Damage negated"
juego_spd: .asciz "Movements left"
juego_health: .asciz "Health points"


juego_contadorMovimientos: .db #0xAA

;;se encarga de que partida_consecuenciaAccion sea invalido por default
;;UTILIZA: ix
juego_inicioMovimiento::
   ;;guarda en el bit alto de consecuenciaAccion un 0x00
   ld ix, #partida_consecuenciaAccion
   ld 0x01(ix), #0x00
   ;;se asegura también de que entidadPasiva sea invalida por default
   ld ix, #partida_entidadPasiva
   ld 0x01(ix), #0x00
   ret

;;Ejecuta todos los turnos de una ronda
;;DESTRUYE TODO!!! (osea no esta comprobado pero llama a todo lo demas...)
;;DEVUELVE: (flags) nz si el jugador murio, z si el juego continua
juego_ronda_contadorErroneo: .db #0xAA
juego_ronda::
   ;;si no quedan mas turnos, acaba con z
   call turno_actualizar
   ret z

   ;;reinicia el contador de movimientos a -1 (spd es movimientos extra)
   ld hl, #juego_contadorMovimientos
   ld (hl), #0xFF

   juego_ronda_movimiento:
      call render_dibujarMapa
      ;ld a, #60
      ;call render_esperar

      ld a, #0 
      ld (juego_ronda_contadorErroneo),a
      juego_ronda_movimientoIncorrecto:
         call juego_inicioMovimiento
         
         ld hl, #juego_ronda_contadorErroneo
         inc (hl)
         ld hl, (partida_entidadActiva)
         call personaje_esJugador         ;Comprobamos si la entidad activa es Jugador
         jr z,juego_ronda_movimientoIncorrecto_esJugador   ;Si es jugador tiene movimientos incorrectos ilimitados
         ld bc,(juego_ronda_contadorErroneo)
         ld a,#5
         cp c                             ;Vemos si el personaje ha hecho 4 movimientos incorrectos
         jr z,juego_ronda_movimientoIncorrecto_pierdeTurno ;Si ha hecho 4 movimientos incorrectos y es enemigo pierde el turno
         
         juego_ronda_movimientoIncorrecto_esJugador:
         call control_actualizar
         call fisica_actualizar
         jr z, juego_ronda_movimientoIncorrecto
         call logica_actualizar
         jr z, juego_ronda_movimientoIncorrecto
      juego_ronda_movimientoIncorrecto_pierdeTurno:
      ;;si la consecuencia devuelve z, se reincia la ronda
      call juego_actualizar
      ret z

      ;;Si se ha muerto el jugador, para la ronda
      ld a, (partida_jugadorMuerto)
      or a
      ret nz

      ;;le suma uno al contador de movimientos
      ld hl, #juego_contadorMovimientos
      inc (hl)
      ;;obtiene la velocidad de la entidad activa
      ld ix, (partida_entidadActiva)
      ld a, personaje_offsetSpdMovDef(ix)
      personaje_getSpd
      ;; a = a - (hl)
      cp (hl)
      ;;si el resultado es no cero, repite movimiento
      ;;CUIDADO, SI a < (hl) ~256 MOVIMIENTOS
      jr nz, juego_ronda_movimiento
   ;;si el resultado es cero acaba el turno y sigue sigue la ronda
   jr juego_ronda

;; ESTO DEBERIA IR EN UTILS DRAW
;; Función para pintar todo el fondo de pntalla del color recibido en A (en modo 1)
;; INPUT:
;;       A: Recibe el color del que pintar la pantalla
;; DESTROYS:
;;       AF,BC,DE,HL
;;
juego_pintaFondoPantallaM1::
   ld de, #0xC000                ;Guardamos en DE la primera posición de la pantalla
   ld c, #40                     ;Guardamos en C el ancho de la caja (40 bytes (160 px (media pantalla)))
   ld b, #200                    ;Guardamos en B el alto de la caja (200 bytes (200px (la pantalla completa)))
   push af                       ;Enviamos AF a la pila para que no se pierda el color del que hay que pintar
   call cpct_drawSolidBox_asm    ;Pintamos la caja
   pop af                        ;Recuperamos AF de la pila para saber de que color pintar
   ld de, #0xC028                ;Guardamos en DE la primera posición del segundo cuadrado
   ld c, #40                     ;Guardamos en C el ancho de la caja (40 bytes (160 px (media pantalla)))
   ld b, #200                    ;Guardamos en B el alto de la caja (200 bytes (200px (la pantalla completa)))
   call cpct_drawSolidBox_asm    ;Pintamos la caja
   ret



;;
;; Función para dibujar una tecla de 24px por 24px en pantalla (cómo las que se usan para indicar los controles)
;; INPUT:
;;       B: Recibe el código ASCII de la tecla a dibujar
;;       DE: Recibe la posición del cuadrado de la tecla
;;       
;; DESTROYS:
;;       AF,BC,DE,HL
;;
juego_pintaTecla::
   ;Empezamos pintando el cuadrado de la tecla
   push bc                       ;Guardamos BC en la pila para mantener el carácter ASCII
   push de                       ;Guardamos DE en la pila para mantener la posición de memoria

   ld h,#12                      ;Guardamos en H el indice del color que queremos
   ld l,#12                      ;Guardamos en L el indice del color que queremos

   call cpct_px2byteM0_asm       ;Devuelva en A el formato de pixel con el color que le hemos indicado en HL

   pop de
   push de
   ld c, #6                      ;Guardamos en C el ancho de la caja (6 bytes (24 px (3 chars)))
   ld b, #24                     ;Guardamos en B el alto de la caja (24 bytes (24px (3 chars)))
   call cpct_drawSolidBox_asm    ;Pintamos la caja


   ;Y ahora escribimos el carácter en el centro de ella
   ld h, #12
   ld l, #1
   call cpct_setDrawCharM0_asm

   pop de                        ;Recuperamos la posición de memoria que nos habían pasado en DE
   ex de, hl                     ;Intercambiamos DE por HL para tener en HL la posición dónde se pintó el cuadrado
   pop bc                        ;Recuperamos el caracter ASCII que se cargará en D
   ld e,b                        ;Cargamos en E el valor de B, que es el código ASCII del char
   ld bc, #0x51                  ;Cargamos en BC 51 que es lo que hay que sumarle a la posicion de la tecla para tener la posición del char
   add hl,bc                     ;Le sumamos a la posición de pantalla de la tecla (HL) 52 (BC) para obtener la posición de dibujado del char

   call cpct_drawCharM0_asm      ;Pintamos el caracter
   ret

;;
;; Función para probar cosas que es llamada al principio del main, así evitamos tener que tocar el main para hacer pruebas sencillas
;;
juego_prueba::
   ;call juego_pantallaFinal
   ret

;;
;; Función para dibujar la pantalla de inicio
;; DESTROYS:
;;       AF,BC,DE,HL
;;
juego_pantallaDeInicio::
   ld a, #0xC0
   call draw_pintaFondoPantallaM0

   ;Pintamos el título del juego

   ;; Set up draw char colours in mode 0 before calling draw string
   ld    l, #15         ;; D = Background PEN (1)
   ld    h, #01         ;; E = Foreground PEN (3)
   call cpct_setDrawCharM0_asm   ;; Set draw char colours


   ld hl, #0xC004                 ;En HL almacenamos la posición dónde comienza el string OP
   ld iy, #juego_tituloJuego           ;En IY almacenamos el puntero al string juego_tituloJuego
   call cpct_drawStringM0_asm    ;Draw the string dibujamos el string OP

   ;Vamos a pintar los controles:
    
   ;; Set up draw char colours before calling draw string
   ld    l, #0x0         ;; D = Background PEN (2)
   ld    h, #0xF         ;; E = Foreground PEN (0)
   call cpct_setDrawCharM0_asm   ;; Set draw char colours

   ld b, #81
   ld de, #0xC0A8
   call juego_pintaTecla
   
   ld b, #65
   ld de, #0xC1E8
   call juego_pintaTecla

   ld b, #79
   ld de, #0xC414
   call juego_pintaTecla

   ld b, #80
   ld de, #0xC41C
   call juego_pintaTecla

   ;Por último, escribiremos los mensajes
    ld    l, #15         ;; D = Background PEN (1)
   ld    h, #01         ;; E = Foreground PEN (3)
   call cpct_setDrawCharM0_asm   ;; Set draw char colours

   ld hl, #0xC154                ;En HL almacenamos la posición dónde comienza el string QA
   ld iy, #juego_controlesQA           ;En IY almacenamos el puntero al string QA
   call cpct_drawStringM0_asm    ;Draw the string dibujamos el string QA
   ld hl, #0xC204                ;En HL almacenamos la posición dónde comienza el string QA
   ld iy, #juego_updown           ;En IY almacenamos el puntero al string UP/DOWN
   call cpct_drawStringM0_asm    ;Draw the string dibujamos el string UP/DOWN


   ld hl, #0xC424                ;En HL almacenamos la posición dónde comienza el string OP
   ld iy, #juego_controlesOP           ;En IY almacenamos el puntero al string OP
   call cpct_drawStringM0_asm    ;Draw the string dibujamos el string OP
   ld hl, #0xC4CE                ;En HL almacenamos la posición dónde comienza el string juego_leftright
   ld iy, #juego_leftright             ;En IY almacenamos el puntero al string juego_leftright
   call cpct_drawStringM0_asm    ;Draw the string dibujamos el string juego_leftright

   ;;;;;;;;;;;;;Por último, pintamos a mano la tecla espacio por ser distinta al resto
   ld h,#12                      ;Guardamos en H el indice del color que queremos
   ld l,#12                      ;Guardamos en L el indice del color que queremos
   call cpct_px2byteM0_asm
   ld de, #0xC5A1
   ld c, #20                      ;Guardamos en C el ancho de la caja (12 bytes (48 px (6 chars)))
   ld b, #24                     ;Guardamos en B el alto de la caja (24 bytes (24px (3 chars)))
   call cpct_drawSolidBox_asm    ;Pintamos la caja

   ld h, #12
   ld l, #1
  call cpct_setDrawCharM0_asm
  ld hl, #0xC5F1                ;En HL almacenamos la posición dónde comienza el string juego_space
  ld iy, #juego_space             ;En IY almacenamos el puntero al string juego_space
  call cpct_drawStringM0_asm


   ld    l, #15         ;; D = Background PEN (1)
   ld    h, #01         ;; E = Foreground PEN (3)
   call cpct_setDrawCharM0_asm   ;; Set draw char colours


   ld hl, #0xC5C0                ;En HL almacenamos la posición dónde comienza el string useSpace
   ld iy, #juego_controlesSPACE             ;En IY almacenamos el puntero al string useSpace
   call cpct_drawStringM0_asm    ;Draw the string dibujamos el string useSpace
   ld hl, #0xC664                ;En HL almacenamos la posición dónde comienza el string toWait
   ld iy, #juego_toWait             ;En IY almacenamos el puntero al string toWait
   call cpct_drawStringM0_asm    ;Draw the string dibujamos el string toWait
   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

   ld hl, #0xC73F                ;En HL almacenamos la posición dónde comienza el string TECLA
   ld iy, #juego_strPressAnyKey            ;En IY almacenamos el puntero al string TECLA
   call cpct_drawStringM0_asm    ;Draw the string dibujamos el string TECLA
   ld hl, #0xC798                ;En HL almacenamos la posición dónde comienza el string TECLA
   ld iy, #juego_strToStart            ;En IY almacenamos el puntero al string TECLA
   call cpct_drawStringM0_asm    ;Draw the string dibujamos el string TECLA

   juego_pantallaDeInicio_loopWaitingKey: ;TODO, hay que cambiar esto para evitar que si pulsa una de las teclas de control se interprete como control
      ld hl, #math_randomSeed
      inc (hl)
      halt
      call cpct_scanKeyboard_asm
      call cpct_isAnyKeyPressed_asm
      jr z, juego_pantallaDeInicio_loopWaitingKey
   ld hl, #math_randomSeed
   call cpct_setSeed_mxor_asm
   ret


   ;;
;; Función para dibujar la pantalla de inicio
;; DESTROYS:
;;       AF,BC,DE,HL
;;
juego_pantallaDeInicio2::
   ld a, #0xC0
   call draw_pintaFondoPantallaM0

   ;Pintamos el título del juego

   ;; Set up draw char colours in mode 0 before calling draw string
   ld    l, #15         ;; D = Background PEN (1)
   ld    h, #01         ;; E = Foreground PEN (3)
   call cpct_setDrawCharM0_asm   ;; Set draw char colours


   ;Vamos a pintar los controles:
    
   ;; Set up draw char colours before calling draw string
   ld    l, #0x0         ;; D = Background PEN (2)
   ld    h, #0xF         ;; E = Foreground PEN (0)
   call cpct_setDrawCharM0_asm   ;; Set draw char colours

   ld de, #0xC148
   ld bc, #render_tamanoSprite
   ld hl, #_spAtkBlue
   call cpct_drawSprite_asm
   
   ld de, #0xC288
   ld bc, #render_tamanoSprite
   ld hl, #_spDefBlue
   call cpct_drawSprite_asm
   
   ld de, #0xC3C8
   ld bc, #render_tamanoSprite
   ld hl, #_spHealthBlue
   call cpct_drawSprite_asm
   
   ld de, #0xC508
   ld bc, #render_tamanoSprite
   ld hl, #_spSpdBlue
   call cpct_drawSprite_asm

   
   ;Por último, escribiremos los mensajes
   ld    l, #15         ;; D = Background PEN (1)
   ld    h, #01         ;; E = Foreground PEN (3)
   call cpct_setDrawCharM0_asm   ;; Set draw char colours

   ld hl, #0xE151                ;En HL almacenamos la posición dónde comienza el string QA
   ld iy, #juego_atk           ;En IY almacenamos el puntero al string QA
   call cpct_drawStringM0_asm    ;Draw the string dibujamos el string QA
   ld hl, #0xE291                ;En HL almacenamos la posición dónde comienza el string QA
   ld iy, #juego_def           ;En IY almacenamos el puntero al string UP/DOWN
   call cpct_drawStringM0_asm    ;Draw the string dibujamos el string UP/DOWN
   ld hl, #0xE3D1                ;En HL almacenamos la posición dónde comienza el string QA
   ld iy, #juego_health           ;En IY almacenamos el puntero al string UP/DOWN
   call cpct_drawStringM0_asm    ;Draw the string dibujamos el string UP/DOWN
   ld hl, #0xE511                ;En HL almacenamos la posición dónde comienza el string QA
   ld iy, #juego_spd           ;En IY almacenamos el puntero al string UP/DOWN
   call cpct_drawStringM0_asm    ;Draw the string dibujamos el string UP/DOWN

   ld    l, #15         ;; D = Background PEN (1)
   ld    h, #01         ;; E = Foreground PEN (3)
   call cpct_setDrawCharM0_asm   ;; Set draw char colours


   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

   ld hl, #0xC73F                ;En HL almacenamos la posición dónde comienza el string TECLA
   ld iy, #juego_strPressAnyKey            ;En IY almacenamos el puntero al string TECLA
   call cpct_drawStringM0_asm    ;Draw the string dibujamos el string TECLA
   ld hl, #0xC798                ;En HL almacenamos la posición dónde comienza el string TECLA
   ld iy, #juego_strToStart            ;En IY almacenamos el puntero al string TECLA
   call cpct_drawStringM0_asm    ;Draw the string dibujamos el string TECLA

   juego_pantallaDeInicio2_loopWaitingKey: ;TODO, hay que cambiar esto para evitar que si pulsa una de las teclas de control se interprete como control
      ld hl, #math_randomSeed
      inc (hl)
      halt
      call cpct_scanKeyboard_asm
      call cpct_isAnyKeyPressed_asm
      jr z, juego_pantallaDeInicio2_loopWaitingKey
   ld hl, #math_randomSeed
   call cpct_setSeed_mxor_asm
   ret

;;Carga un mapa
;;RECIBE: el mapa a cargar en hl
;;UTILIZA: a, bc, de, hl, ix
juego_cargarMapa::
   ;;REINICIA LO QUE NECESITES REINICIAR!
   ex de, hl
   call personaje_iniciarNivel
   call objeto_iniciarNivel
   ex de, hl
   ;;carga el mapa
   call mapa_cargar
   ;;recorre el mapa de estado creando a los personajes
   ;;Super ineficiente, pero me suda la polla un poquito
   ld ix, #mapa_actual
   ;;b es x, c es y
   ld a, (mapa_filas)
   ld b, a
   juego_cargarMapa_loop1:
      ld a, (mapa_columnas)
      ld c, a
      juego_cargarMapa_loop2:
         push bc                    ;;almacena el contador
         call mapa_getCelda         ;;Recibe el valor de la celda
         pop bc                     ;;recupera el contador para cargarElemento
         push bc                    ;;pero se lo guarda por si acaso otra vez
         call juego_cargarElemento  ;;Carga el elemento recibido
         pop bc                     ;;recupera el contador
         dec c
         ld a, #0xFF
         cp c
         jr nz, juego_cargarMapa_loop2 ;;sigue ciclando si no va de 0 a FF
      dec b
      cp b
      jr nz, juego_cargarMapa_loop1 ;;sigue ciclando si no va de 0 a FF
   ret

;;Carga un elemento de mapa
;;RECIBE: el elemento a cargar en a, la posicion a cargar en bc
;;UTILIZA: a, bc, ix (pero ix lo "recupera" cuando lo usa)
juego_cargarElemento:
   ;;si es pared o hueco, no hace nada
   cp #mapa_simboloHueco
   ret z
   cp #mapa_simboloPared
   ret z
   ;;si es jugador
   cp #mapa_simboloJugador
   jr z, juego_cargarElemento_jugador
   ;;si es enemigo1
   cp #mapa_simboloEnemigo1
   jr z, juego_cargarElemento_enemigo1
   ;;si es enemigo2
   cp #mapa_simboloEnemigo2
   jr z, juego_cargarElemento_enemigo2
   ;;si es enemigo3
   cp #mapa_simboloEnemigo3
   jr z, juego_cargarElemento_enemigo3
   ;;si es enemigo4
   cp #mapa_simboloEnemigo4
   jr z, juego_cargarElemento_enemigo4
   ;;si es enemigo5
   cp #mapa_simboloEnemigo5
   jr z, juego_cargarElemento_enemigo5
   ;;si es enemigo6
   cp #mapa_simboloEnemigo6
   jr z, juego_cargarElemento_enemigo6
   ;;si es ascensor
   cp #mapa_simboloAscensor
   jr z, juego_cargarElemento_ascensor
   ;;si es healthUp
   cp #mapa_simboloHealthUp
   jr z, juego_cargarElemento_healthUp
   ;;si es healthMaxUp
   cp #mapa_simboloHealthMaxUp
   jr z, juego_cargarElemento_healthMaxUp
   ;;si es atkUp
   cp #mapa_simboloAtkUp
   jr z, juego_cargarElemento_atkUp
   ;;si es defUp
   cp #mapa_simboloDefUp
   jr z, juego_cargarElemento_defUp
   ;;si es spdUp
   cp #mapa_simboloSpdUp
   jr z, juego_cargarElemento_spdUp
   ret
   juego_cargarElemento_jugador:
      ;;pone al jugador en esa posicion
      ld ix, #personaje_jugador
      ld personaje_offsetPosicionX(ix), b
      ld personaje_offsetPosicionY(ix), c
      ;;y elimina el simbolo anterior
      ld personaje_offsetSimboloPisando(ix), #0x00
      ld ix, #mapa_actual ;;repone ix
      ret
   juego_cargarElemento_enemigo1:
      ;;crea un enemigo uno en esa posicion
      call personaje_crearEnemigo1
      ret
   juego_cargarElemento_enemigo2:
      ;;crea un enemigo uno en esa posicion
      call personaje_crearEnemigo2
      ret
   juego_cargarElemento_enemigo3:
      ;;crea un enemigo uno en esa posicion
      call personaje_crearEnemigo3
      ret
   juego_cargarElemento_enemigo4:
      ;;crea un enemigo uno en esa posicion
      call personaje_crearEnemigo4
      ret
   juego_cargarElemento_enemigo5:
      ;;crea un enemigo uno en esa posicion
      call personaje_crearEnemigo5
      ret
   juego_cargarElemento_enemigo6:
      ;;crea un enemigo uno en esa posicion
      call personaje_crearEnemigo6
      ret
   juego_cargarElemento_ascensor:
      ;;crea un ascensor en esa posicion
      call objeto_crearAscensor
      ret
   juego_cargarElemento_healthUp:
      ;;crea un healthUp en esa posicion
      call objeto_crearHealthUp
      ret
   juego_cargarElemento_healthMaxUp:
      ;;crea un healthMaxUp en esa posicion
      call objeto_crearHealthMaxUp
      ret
   juego_cargarElemento_atkUp:
      ;;crea un atkUp en esa posicion
      call objeto_crearAtkUp
      ret
   juego_cargarElemento_defUp:
      ;;crea un defUp en esa posicion
      call objeto_crearDefUp
      ret
   juego_cargarElemento_spdUp:
      ;;crea un spdUp en esa posicion
      call objeto_crearSpdUp
      ret


;;
;; Función que crea la pantalla de fin del juego
;;
;;

juego_pantallaFinal_espacio:
   .db 0xDE,0xAD,0xDE,0xAD,0xDE,00
   
juego_pantallaFinal::
   ld h, #0x14
   ld l, #0x10
   call cpct_setPALColour_asm
   
   ;Por último, escribiremos los mensajes
   ld    l, #15                  ; Foreground pen
   ld    h, #6                   ; Background pen
   call cpct_setDrawCharM0_asm   ;; Set draw char colours
   ld h, #6
   ld l, #6
   call cpct_px2byteM0_asm
   call draw_pintaFondoPantallaM0

   ld hl, #0xC066                ;En HL almacenamos la posición dónde comienza el string game over
   ld iy, #juego_strFinDelJuego        ;En IY almacenamos el puntero al string game over
   call cpct_drawStringM0_asm    ;Draw the string dibujamos el string game over

   ld hl, #0xC2E2                ;En HL almacenamos la posición dónde comienza el string score
   ld iy, #juego_strScore              ;En IY almacenamos el puntero al string score
   call cpct_drawStringM0_asm    ;Draw the string dibujamos el string score

   ld hl, #0xC50F                ;En HL almacenamos la posición dónde comienza el string pulsa tecla
   ld iy, #juego_strPressAnyKey            ;En IY almacenamos el puntero al string pulsa tecla
   call cpct_drawStringM0_asm    ;Draw the string dibujamos el string pulsa tecla
   ld hl, #0xC569                ;En HL almacenamos la posición dónde comienza el string pulsa tecla
   ld iy, #juego_strToStart            ;En IY almacenamos el puntero al string pulsa tecla
   call cpct_drawStringM0_asm    ;Draw the string dibujamos el string pulsa tecla
   
   ld de,#juego_pantallaFinal_espacio    ;Cargamos en DE la posición de memoria dónde irá el string (importante, 5 bytes y un NULL al final)
   ld hl, (partida_puntuacion)           ;Cargamos en HL el número que queremos convertir a cadena ASCII
   call string_Num2Dec                          ;Llamamos a la función que nos pone en la posición que apunta DE el valor ASCII del número en HL
   ld iy, #juego_pantallaFinal_espacio   ;Cargamos en IY la cadena de la posición dada


   ld    l, #8                  ; Foreground pen
   ld    h, #6                   ; Background pen
   call cpct_setDrawCharM0_asm   ;; Set draw char colours
   ld hl, #0xC3E0                   ;En HL guardamos la posición de pantalla dónde imprimir
   call cpct_drawStringM0_asm       ;Imprimimos la cadena de IY
   
   juego_pantallaFinal_loopWaitingKey:
      call keyboard_siPulsadoYSoltadoCualquiera
      ret z
      jr juego_pantallaFinal_loopWaitingKey

;;ejecuta la consecuencia de la accion
;;UTILIZA: a, hl
;;    es posible que todas dependiendo a quien llame
juego_actualizar::
   ;;Comprueba que la consecuencia no sea nula (#0x00XX)
   ld hl, (partida_consecuenciaAccion)
   ld a, h
   or a
   jr z, juego_actualizar_consecuenciaNula
   ;;Llama a la consecuencia
   ld (juego_Consecuencia), hl
   juego_Consecuencia = .+1
   call #0xADDE
   ret
   juego_actualizar_consecuenciaNula:
   inc a ;;devuelve nz porque a es 0
   ret

;;funcion para ejecutar a la entidad pasiva
;;UTILIZA: a, bc, de, hl, ix, iy
juego_matarPasiva::
   ld hl, (partida_entidadPasiva)
   call personaje_esJugador
   jr z, juego_matarJugador
   ;;Si no es jugador, mata a la entidad que sea
   ;;Meter animacion muerte enemigo en el stack
   ld ix, (partida_entidadPasiva)
   ;;simbolo positivo, no es colisionable, es un objeto
   ld a, personaje_offsetSimbolo(ix)
   or a
   jp p, juego_matarPasiva_objeto
   ;;quita al enemigo del mapa
   ld b, personaje_offsetPosicionX(ix)
   ld c, personaje_offsetPosicionY(ix)
   ld iy, (partida_entidadPasiva)
   call fisica_dejarPosicion
   ;;mata al enemigo
   ld de, (partida_entidadPasiva)
   call personaje_borrarEnemigo
   ;;si matas tu score suma el minimo*2
   ld bc, #partida_minSumaPuntuacion
   ld hl, (partida_puntuacion)
   add hl, bc
   add hl, bc
   ld (partida_puntuacion), hl
   ret
   juego_matarPasiva_objeto:
   ;;Borra la entidad pasiva
   ld__d_ixh
   ld__e_ixl
   call objeto_borrar
   ;;borra el simbolo del objeto
   ld ix, (partida_entidadActiva)
   ld personaje_offsetSimboloPisando(ix), #mapa_simboloHueco
   ;;si consigues objeto tu score suma el minimo
   ld bc, #partida_minSumaPuntuacion
   ld hl, (partida_puntuacion)
   add hl, bc
   ld (partida_puntuacion), hl
   ret
;;funcion para ejectuar al jugador
;;es global porque podria usarse como consecuencia
;;UTILIZA: a
juego_matarJugador::
   ;;Meter animacion muerte jugador en el stack
   ld a, #0x01
   ld (partida_jugadorMuerto), a
   inc a ;;devuelve nz porque a es 1
   ret
;;funcion siguiente nivel (consecuencia)
;;UTILIZA: a, hl
juego_siguienteNivel::
   ld hl, (mapa_siguiente)
   call juego_cargarMapa

   ;;si pasas de nivel, tu score suma el minimo*3
   ld bc, #partida_minSumaPuntuacion
   ld hl, (partida_puntuacion)
   add hl, bc
   add hl, bc
   add hl, bc
   ld (partida_puntuacion), hl
   xor a ;;devuelve z
   ret