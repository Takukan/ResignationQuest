;;
;; SISTEMA VISUAL/GUI.S
;;

.globl gui_actualizar
.globl gui_pintarBase
.globl gui_inicioRonda


;;Mover los numeros a mano, son 0xXXYY
gui_atkPos = 0x8402
gui_spdPos = gui_defPos+36
gui_healthPos = gui_atkPos+0x1400
gui_defPos = gui_healthPos+0x1400

gui_spAncho = 8