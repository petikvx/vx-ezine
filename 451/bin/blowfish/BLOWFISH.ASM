include klimport.ash
include macros.ash

        .586p
        .model flat
        .data

includelib import32.lib

S        dd      256*4 dup(0)
P        dd      18    dup(0)
key      db      'superkey'

seed     dd      12345678h

        .code
_start:
        int 3

        mov esi,offset S
        mov edi,offset P

;北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
        push edi

        mov ecx,18

blowf_rnd_P:
        push 0FFFFFFFFh
        push offset seed
        call rnd
        add esp,8

        stosd
        loop blowf_rnd_P

;---------------------------------------------------------------------------

        mov edi,esi
        mov ecx,256*4
blowf_rnd_S:
        push 0FFFFFFFFh
        push offset seed
        call rnd
        add esp,8

        stosd
        loop blowf_rnd_S

        pop edi
;北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北

        mov edx,offset key
        call BlowfishInit

        mov eax,12345678h
        mov edx,4321ABCDh

        call BlowfishEncrypt
        call BlowfishDecrypt

        push 0
        xcall ExitProcess

include blowfish.inc

include rnd.inc
end _start
