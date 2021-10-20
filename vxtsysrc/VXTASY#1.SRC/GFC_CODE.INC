; ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
; ³ (c) Lord Julus - 2000		 Vxtasy #1 - Magazine source code ³
; ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

; File reader...			   ;
					   ;
gfc_start:				   ;
	mov cs:events, 0		   ;
	mov in_gfc, 1			   ; set up for gfc
	call _initialize		   ; initialize stuff
					   ;
	call readfile			   ; open and read the file
	jc __finish_error		   ;
					   ;
	call count_lines		   ;
					   ;
	call homeproc			   ;
	mov ax, linesread		   ;
	mov crtdispline, ax		   ;
					   ;
	call hide_mouse 		   ;
	call _makescreen		   ; draw browser screen
	call show_mouse 		   ;
	call browse			   ; browse the file
	jmp __finish			   ;
					   ;
__finish_error: 			   ;
__finish:				   ;
	call _finish			   ; end all
	mov in_gfc, 0			   ;
	mov cs:events, 1		   ;
	ret				   ;
					   ;
;============================================================================
					   ;
include gfc_inf\keyhandl.inf		   ; keyhandlers
include gfc_inf\goodies.inf		   ; scrollbar, percentage, etc.
include gfc_inf\video.inf		   ; video routines
include gfc_inf\read.inf		   ; read routines
include gfc_inf\pageupdn.inf		   ; pageup/pagedown routines
include gfc_inf\homeend.inf		   ; home/end routines
include gfc_inf\miscmove.inf		   ; misc filepointer movements
include gfc_inf\updown.inf		   ; up/down routines
include gfc_inf\initend.inf		   ; init and finish routines
include gfc_inf\misc.inf		   ; miscllancelous routines

