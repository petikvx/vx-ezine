; ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
; ³ (c) Lord Julus - 2000		 Vxtasy #1 - Magazine source code ³
; ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

; Fade in/out, bright in/out, save/restore pallete

SavePalette PROC NEAR	     ; Save entire palette into an array
    cli 		     ; Clear interrupts
    lea     bp,Parray	     ; bp points to offset Palette array
    mov     dx,03c7h	     ; Read register
    xor     al,al	     ; Set al to 0 (start reading at color 0)
    out     dx,al	     ; Give info to VGA
    mov     dx,03c9h	     ; Data register
    mov     cx,300h	     ; Save all colors (256*3)
Saving: 		     ;
    in	    al,dx	     ; Get what's in the register (read)
    and     al,00111111b     ; Mask of the upper 2 bits (value=0..63)
    mov     byte ptr [bp],al ; Save value into array
    mov     byte ptr [bp+300h],al  ; And save into second layer of array
    inc     bp		     ; Point to next cel in aray
    loop    Saving	     ; And loop while cx > 0
    sti 		     ; Enable interrupts again
    ret 		     ;
SavePalette ENDP	     ;
			     ;
clearsecond proc near	     ;
     lea bp, Parray	     ;
     add bp, 300h	     ;
     mov cx, 300h	     ;
     xor ax, ax 	     ;
clear:			     ;
     mov byte ptr [bp], al   ;
     inc bp		     ;
     loop clear 	     ;
     ret		     ;
clearsecond endp	     ;
			     ;
BlackOut PROC NEAR	     ; Reset all R,G,B values to 0
    cli 		     ;
    mov     dx,03c8h	     ; Write register
    xor     al,al	     ; Start at color 0 (and set R,G,B to 0 too)
    out     dx,al	     ; Pass info to VGA
    mov     dx,03c9h	     ; Data register
    mov     cx,300h	     ; Do all colors (256*3)
Reset:			     ;
    out     dx,al	     ; Out all zero's to VGA
    loop    Reset	     ; Loop while cx > 0
    sti 		     ;
    ret 		     ;
BlackOut ENDP		     ;
			     ;
FadeOut PROC NEAR	     ; Fades the screen to black
    cli 		     ; Disable interrupts
    lea     bp,Parray	     ; Load offset Palette array
    mov     cx,64d	     ; Set loopcounter
Loop64d:		     ;
    xor     bx,bx	     ; Set bx to 0
Loop300h:		     ;
    cmp     byte ptr [bp],0  ; Is it 0 already?
    je	    FadeOn	     ;
    dec     byte ptr [bp]    ; Decrease the value with 1
FadeOn: 		     ;
    inc     bp		     ; Point to next cel in array
    inc     bx		     ; Increase loopcounter
    cmp     bx,300h	     ; Done all registers?
    jl	    Loop300h	     ; If not, loop again
    push    cx		     ; Save first loopcounter
    mov     cx,300h	     ; Write all new R,G,B values
    call    WaitVerticalRetrace 	 ; Wait for a vertical retrace
;   call    WaitVerticalRetrace 	 ; Twice
    sub     bp,300h	     ; Reset bp to 0
    mov     dx,03c8h	     ; Write register
    mov     al,0	     ; Start writing at color 0
    out     dx,al	     ; Give info to VGA
    mov     dx,03c9h	     ; Data register
WriteAll:		     ;
    mov     al,byte ptr [bp] ; Get the value
    out     dx,al	     ; Write to VGA
    inc     bp		     ; Point to next cel
    loop    WriteAll	     ; Loop while cx > 0
    sub     bp,300h	     ; Point to start array again
    pop     cx		     ; Restore loopcounter from stack
    loop    Loop64d	     ; Have we done enough?
    sti 		     ; Enable interrupts
    ret 		     ; Return to main program
FadeOut ENDP		     ;
			     ;
BrightOut PROC NEAR	     ; Fades the screen to white
    cli 		     ; Disable interrupts
    lea     bp,Parray	     ; Load offset Palette array
    mov     cx,64d	     ; Set loopcounter
_Loop64d:		     ;
    xor     bx,bx	     ; Set bx to 0
_Loop300h:		     ;
    cmp     byte ptr [bp],63 ; Is it 63 already?
    je	    _FadeOn	     ;
    inc     byte ptr [bp]    ; Increase the value with 1
_FadeOn:		     ;
    inc     bp		     ; Point to next cel in array
    inc     bx		     ; Increase loopcounter
    cmp     bx,300h	     ; Done all registers?
    jl	    _Loop300h	     ; If not, loop again
    push    cx		     ; Save first loopcounter
    mov     cx,300h	     ; Write all new R,G,B values
    call    WaitVerticalRetrace 	 ; Wait for a vertical retrace
    call    WaitVerticalRetrace 	 ; Twice
    sub     bp,300h	     ; Reset bp to 0
    mov     dx,03c8h	     ; Write register
    mov     al,0	     ; Start writing at color 0
    out     dx,al	     ; Give info to VGA
    mov     dx,03c9h	     ; Data register
_WriteAll:		     ;
    mov     al,byte ptr [bp] ; Get the value
    out     dx,al	     ; Write to VGA
    inc     bp		     ; Point to next cel
    loop    _WriteAll	     ; Loop while cx > 0
    sub     bp,300h	     ; Point to start array again
    pop     cx		     ; Restore loopcounter from stack
    loop    _Loop64d	     ; Have we done enough?
    sti 		     ; Enable interrupts
    ret 		     ; Return to main program
BrightOut ENDP		     ;
			     ;
			     ;
FadeIn PROC NEAR	     ; Fades screen to desired colors
    cli 		     ; Disable interrupts
    lea     bp,Parray	     ; Load offset Palette array
    mov     cx,64d	     ; Set loopcounter
loop64dX:		     ;
    xor     bx,bx	     ; Reset bx to 0
Loop300hX:		     ;
    mov     dl,byte ptr [bp] ; Store original value in dl
    mov     dh,byte ptr [bp+300h]    ; And fade-up value in dh
    cmp     dl,dh	     ; Compare them
    je	    NextOne	     ; If they are equal then do the next one
    inc     byte ptr [bp]    ; Else increase with 1 (second layer)
NextOne:		     ;
    inc     bp		     ; Point to next arraycel
    inc     bx		     ; Increase counter
    cmp     bx,300h	     ; Have we done all registers?
    jl	    Loop300hX	     ;
    push    cx		     ; Save first loopcounter
    mov     cx,300h	     ; Do all R,G,B values
    call    WaitVerticalRetrace 	 ; Wait for a vertical retrace
;   call    WaitVerticalRetrace 	 ; Twice
    mov     dx,03c8h	     ; Write register
    xor     al,al	     ; Start writing at color 0
    out     dx,al	     ; Give info to VGA
    mov     dx,03c9h	     ; Data register
    lea bp, Parray	     ;
WritemAll:		     ;
    mov     al,byte ptr [bp] ; Get the value (bp points to second palette)
    out     dx,al	     ; Write to VGA
    inc     bp		     ; Point to next cel
    loop    WritemAll	     ; Loop while cx > 0
    sub     bp,300h	     ; Point to start palette again (reached the end)
    pop     cx		     ; Restore loopcounter from stack
    loop    Loop64dX	     ; Have we done enough?
    sti 		     ; Enable interrupts
    ret 		     ; Return to main program
FadeIn ENDP

; Waiting procedures start here
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
WaitVerticalRetrace proc near
		mov dx,03dah
VRetrace:	in al,dx
		test al,00001000b
		jnz VRetrace
NoVRetrace:	in al,dx
		test al,00001000b
		jz NoVRetrace
		ret
WaitVerticalRetrace endp
