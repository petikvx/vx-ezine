; 旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
; � (c) Lord Julus - 2000		 Vxtasy #1 - Magazine source code �
; 읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

IPS = 50

;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께
; Enables and starts the player interrupt.
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
SetInt: 	push	ax es

		cli
		xor	ax,ax
		mov	es,ax
		mov	ax,es:[8*4]
		mov	word ptr cs:OldInt,ax
		mov	ax,es:2[8*4]
		mov	word ptr cs:OldInt+2,ax
		mov	word ptr es:[8*4], offset PlayerInt
		mov	es:2[8*4],cs

;		mov	ax,IPS
;		call	SetTimer

		sti
		pop	es ax
		ret


;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께
; Disables the player interrupt.
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
ResetInt:	push	ax es

		cli
		xor	ax,ax
		mov	es,ax
		mov	ax,word ptr cs:OldInt
		mov	es:[8*4],ax
		mov	ax,word ptr cs:OldInt+2
		mov	es:2[8*4],ax

		call	ResetTimer

		sti
		pop	es ax
		ret

;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께
; The player interrupt.  Called 50 times a second.
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
PlayerInt:	push	ax

		cmp soundstatus, 1
		jne dontplay
		call	PlayMusic

dontplay:
	; see if we have passed 18.2/s mark
;	 @@lx:	 mov	 ax,cs:TimerSteps	    ; this no. of steps per int.
;		 add	 cs:TimerCnt,ax
;		 jnc	 @@ly			 ; don't call timer interrupt
		pop	ax
		jmp	cs:OldInt		; call old interrupt handlers

	; standard exit
	@@ly:	mov	al,20h
		out	20h,al
		pop	ax
		iret

;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께
; Sets the interrupt timer duty cycle.
; IN:
;	AX	- number of times per second for INT08.
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
SetTimer:	push	ax bx dx

		mov	bx,ax
		mov	ax,13532   ; 1193180 mod 65536 (TASM craps out)
		mov	dx,18	   ; 1193180/65536 (TASM can't calculate this)
		div	bx
		mov	bx,ax

		mov	al,36h
		out	43h,al
		mov	al,bl
		out	40h,al
		mov	al,bh
		out	40h,al

		mov	cs:TimerSteps,bx   ; for keeping 18.2 timer correct
		mov	cs:TimerCnt,0	   ; counter

		pop	dx bx ax
		ret

;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께
; Resets the interrupt timer back to 18.2/sec duty cycle.
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
ResetTimer:	push	ax

		mov	al,36h
		out	43h,al
		xor	al,al
		out	40h,al
		out	40h,al

		pop	ax
		ret

OldInt		dd	?
TimerCnt	dw	?
TimerSteps	dw	?
