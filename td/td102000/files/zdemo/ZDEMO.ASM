
; based on IRIS.SS (completely reversed)

COOL                    equ     YEAH

                        p386
                        model   tiny
                        locals  __
                        jumps

                        .code

                        org     100h
start:
                        call    demo

                        mov     ax, 4c00h
                        int     21h

demo:                   mov     ax, 0013h
                        int     10h

                        mov     ax, cs
                        add     ax, 1000h
                        mov     fs, ax
                        add     ax, 1000h
                        mov     gs, ax

                        call    gentexture
                        call    genindex
                        call    setpal

main_cycle:             call    waitretrace
                        call    genimage
                        call    updatexy
                        call    putimage

                        mov     ah, 1
                        int     16h
                        jz      main_cycle

                        xor     ah, ah
                        int     16h

                        mov     ax, 0003h
                        int     10h

                        retn

putimage:               push    0a000h
                        pop     es

                        xor     si, si
__cycle:
                        mov     bl, fs:[si]
                        mov     bh, gs:[si]

;                       cmp     si, bx
;                       je      __skip

                        mov     al, image[bx]

                        mov     bx, si
                        mov     bl, bh
                        xor     bh, bh
                        shl     bx, 6

                        mov     es:[bx+si+32], al

__skip:
                        inc     si
                        cmp     si, 256*200
                        jb      __cycle

                        retn

genimage:               lea     si, index

                        push    cs
                        pop     es
                        lea     di, image

                        mov     cl, x3
IFDEF COOL
                        mov     ch, x4
ENDIF

                        mov     ah, 200
cycle_y:                push    ax

                        xor     ah, ah

                        mov     dl, x1
IFDEF COOL
                        mov     dh, x2
ENDIF

cycle_x:                mov     bx, bp
                        mov     al, bl
                        xor     bh, bh
                        mov     bl, dl
                        add     al, [bx+si]
IFDEF COOL
                        mov     bl, dh
                        add     al, [bx+si]
ENDIF
                        mov     bl, cl
                        add     al, [bx+si]
IFDEF COOL
                        mov     bl, ch
                        add     al, [bx+si]
ENDIF
;                       or      al, 128
                        stosb
                        add     dl, 1
IFDEF COOL
                        add     dh, 3
ENDIF

                        dec     ah
                        jnz     cycle_x

                        add     cl, 2
IFDEF COOL
                        add     ch, 1
ENDIF
                        pop     ax
                        dec     ah
                        jnz     cycle_y

                        retn

updatexy:               dec     bp
                        mov     bx, bp

                        xor     bl, bh
                        xor     bl, cl
                        xor     bl, dl
IFDEF COOL
                        add     bl, ch
                        add     bl, dh
                        xor     bh, bh
ENDIF

                        lea     di, inc_x1
                        test    bl, 8
                        jnz     loc_0_EB
                        and     bl, 3
                        cmp     byte ptr [bx+di], 3
                        jg      loc_0_F5
                        inc     byte ptr [bx+di]
                        jmp     loc_0_F5
loc_0_EB:               and     bl, 3
                        cmp     byte ptr [bx+di], -3
                        jl      loc_0_F5
                        dec     byte ptr [bx+di]
loc_0_F5:

                        mov     dl, inc_x1
                        mov     cl, inc_x3
                        add     x1, dl
                        add     x3, cl
IFDEF COOL
                        mov     dh, dec_x2
                        mov     ch, dec_x4
                        sub     x2, dh
                        sub     x4, ch
ENDIF
                        retn

waitretrace:            mov     dx, 3DAh
__1:                    in      al, dx
                        test    al, 8
                        jz      __1
__2:                    in      al, dx
                        test    al, 8
                        jnz     __2
                        retn

gentexture:
                        xor     di, di

__cycle_y:              xor     si, si

                        mov     bx, 199
                        sub     bx, di
                        shl     bx, 8

                        mov     bp, di
                        shl     bp, 8

__cycle_x:              movzx   ax, texture[bx]
                        lea     dx, [si-128]
                        imul    ax, dx
                        sar     ax, 8
                        add     ax, si
                        mov     fs:[bp], al

                        movzx   ax, texture[bx]
                        lea     dx, [di-100]
                        imul    ax, dx
                        sar     ax, 11
                        add     ax, di

__z2:                   cmp     ax, 200
                        jl      __z1
                        sub     ax, 200
                        jmp     __z2
__z1:                   cmp     ax, -200
                        jg      __z3
                        add     ax, 200
                        jmp     __z1
__z3:
                        mov     gs:[bp], al

                        inc     bx
                        inc     bp

                        inc     si
                        cmp     si, 256
                        jb      __cycle_x

                        inc     di
                        cmp     di, 200
                        jb      __cycle_y

                        retn


genindex:               finit

                        xor     di, di
                        xor     cl, cl

__cycle:                xor     ah, ah
                        mov     al, cl
                        sub     ax, 128

                        push    ax
                        fild    word ptr [esp]
                        fild    word ptr cw_128
                        fdiv
                        fldpi
                        fmul
                        fcos
                        fild    word ptr cw_64
                        fmul
                        fistp   word ptr [esp]
                        pop     ax

                        mov     index[di], al
                        inc     di

                        dec     cl
                        jnz     __cycle

                        retn

setpal:                 mov     dx, 3C8h
                        xor     al, al
                        out     dx, al
                        inc     dx

                        lea     si, palette
                        mov     ch, 8

__cycle1:               xor     cl, cl

__cycle2:               xor     bx, bx

__cycle3:               mov     al, [si+bx+3]
                        sub     al, [si+bx]
                        imul    cl
                        idiv    byte ptr cb_31
                        add     al, [si+bx]
                        out     dx, al

                        inc     bx
                        cmp     bl, 3
                        jb      __cycle3

                        inc     cl
                        cmp     cl, 32
                        jb      __cycle2

                        add     si, 3

                        dec     ch
                        jnz     __cycle1

                        retn

                        ;        r  g  b  dr dg db

rgb                     macro   r,g,b
                        db      r*63/255
                        db      g*63/255
                        db      b*63/255
                        endm

palette:                rgb       0,  0,  0
                        rgb       0,  0,  0
                        rgb       0,  0,  0
                        rgb     255,  0,  0
                        rgb     255,255,255
                        rgb       0,  0,255
                        rgb       0,  0,  0
                        rgb       0,  0,  0
                        ;;
                        rgb       0,  0,  0

cw_128                  dw      128
cw_64                   dw      64
cb_31                   db      31

inc_x1                  db      2
dec_x2                  db      1
inc_x3                  db      3
dec_x4                  db      4

x1                      db      ?
x2                      db      ?
x3                      db      ?
x4                      db      ?

index                   db      256 dup (?)

image                   label   byte
texture                 label   byte
include                 texture.inc

                        end     start


