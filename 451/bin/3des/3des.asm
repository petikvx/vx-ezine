include klimport.ash
include macros.ash

includelib import32.lib

        .586p
        .model flat
        .data

include 3des_data.inc

K1       dd 16*2 dup (0)
K2       dd 16*2 dup (0)

        .code
_start:
        int 3

        mov ebp,offset DES_tables

        mov edi,offset K1                       ; *1
        mov edx,'keY '                          ; EDX:EAX = key #1
        mov eax,'for '                          ;
        call DESinit                            ;

        mov edi,offset K2                       ; *2
        mov edx,'trip'                          ; EDX:EAX = key #2
        mov eax,'lDES'                          ;
        call DESinit                            ;

        mov eax,086754321h
        mov edx,0ABCDEF00h

        mov esi,offset K1                       ; 3DES encrypt
        call DES3encrypt                        ;

        call DES3decrypt                        ; 3DES decrypt

        push 0
        xcall ExitProcess

include 3des.inc

end _start