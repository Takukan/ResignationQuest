;;
;; SISTEMA JUEGO/TURNO.S
;;

.include "turno.h.s"
.include "man/personaje.h.s"
.include "man/partida.h.s"

;;
;; Sistema de turnos
;;  (podrian haber entidades no personaje en un futuro)
;;

;; NO SE REINICIA EL TURNO SOLO, HAY QUE REINICIARLO

turno_entidadesIteradas: .db #0xAA

;;Encuentra la siguiente entidad con turno
;;UTILIZA: a, de, hl, ix
;;DEVUELVE: siguiente entidad en ix, (flags) nz si encontro entidad, z si no la encontro
turno_siguienteEntidad:
   ;;reinicia las entidades movidas del turno (empiezan a -1 para contar con el jugador)
   ld a, #0xFF
   ld (turno_entidadesIteradas), a
   ;;obtienes el principio del array
   ld ix, #personaje_jugador

   turno_siguienteEntidad_loop:
      ;;obtienes el movimiento de la entidad
      ld a, personaje_offsetSpdMovDef(ix);
      personaje_getMov
      ;;si no se movio, termina
      or a
      ret nz
      ;;si ya se movio
      ;;mueve el iterador
      ld de, #personaje_sizeOf
      add ix, de
      ;;aumenta el contador
      ld hl, #turno_entidadesIteradas
      inc (hl)
      ;;compara los entidades movidos con los entidades en total
      ld a, (personaje_numEnemigos)
      cp (hl)
      ;;sale si no quedan mas entidades
      ret z
      ;;cicla
      jr turno_siguienteEntidad_loop

;;Actualiza la entidad a la que le toca
;;UTILIZA: a, b, de, hl, ix
;;DEVUELVE: (flags) z si no quedan turnos, nz si quedan turnos
turno_actualizar::
   call turno_siguienteEntidad
   ret z
   ;;Pone el entidad como entidadActiva
   ld (partida_entidadActiva), ix
   ;;pone el mov de la entidad a 0
   ld b, #0
   ld a, personaje_offsetSpdMovDef(ix)
   personaje_setMov
   ld personaje_offsetSpdMovDef(ix), a
   xor a
   inc a;;se asegura de devolver nz
   ret


