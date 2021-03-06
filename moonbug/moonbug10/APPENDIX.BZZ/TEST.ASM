;-----------------------------------------------------
;        Test of RDCG v0.2 by B!Z0n //[BzZ]
;-----------------------------------------------------
MODEL TINY
CODESEG
STARTUPCODE
P386
CR      equ  0Dh, 0Ah

num = 10    ; cryptor\decryptor command num.

start:
        mov  ah, 03h
        int  10h
        push cx
        mov  ah, 01h
        mov  ch, 20h
        int  10h

        mov  ax, 351Ch
        int  21h
        mov  word ptr [oldint], bx
        mov  word ptr [oldint+2], es
        mov  dx, offset newint
        mov  ax, 251Ch
        int  21h

        push cs cs
        pop  ds es

        lea  dx, message
        mov  ah, 9h
        int  21h

test_loop:
        lea  si, cryptor
        lea  di, decryptor
        mov  cx, num
        call RDCG
        mov  al, 0C3h
        stosb

        mov  cx, crypt-test_loop-1
        push cx
        lea  di, crypt-1
crypt:
        dec  di
        call si
        loop crypt

        pop  cx
        lea  di, test_loop

decrypt:
        call decryptor
        inc  di
        loop decrypt

        inc  dword ptr [timer]
        jz   exit

        mov  ah, 01h
        int  16h
        jz   test_loop

        xor  ah, ah
        int  16h

exit:
        mov  ax, 251Ch
        lds  dx, oldint
        int  21h
        push cs
        pop  ds
        lea  dx, messageok
        mov  ah, 9h
        int  21h

        pop  cx
        mov  ah, 01h
        int  10h

        mov  ah, 4ch
        int  21h

newint: pushf
        pusha
        push   es ds
;---
        push   cs cs
        pop    ds es
;---
;- out roll
        lea    bx, [fase]
        lea    di, [fasenum]

lod:    mov    al, byte ptr [di]
        xlat
        or     al, al
        jnz    outfase
        stosb
        dec    di
        jmp    lod
outfase:
        push   ax
        mov    ah, 0Fh
        int    10h
        pop    ax
        mov    ah, 0Ah
        mov    cx, 0001
        int    10h
        inc    byte ptr [di]

;-----
        dec    byte ptr [calc]
        jnz    no_chg

;- chg num lock status

chgnumlock:
        mov    byte ptr [calc], 12
        push   0040h
        pop    es
        xor    byte ptr es:[17h], 00100000b

no_chg: pop    ds es
        popa
        popf
             db  0EAh
oldint       dd  ?
calc         db  01h
message      db  'Test of Random De- Cryptor Generator v0.2 by B!Z0n //[BzZ]', CR
             db  'Press any key to end test...$'
messageok    db  'O.K.',CR,'$'
timer        dd  0

fasenum      db  00h
fase         db  '��+*#�#*+�',0

include rdcg2.inc

decryptor:

org $+ num*8+2
cryptor:


end                                        