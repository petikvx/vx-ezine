
; RSA demonstartion:
;
;  * Generate keys,
;  * Encrypt block,
;  * Decrypt block
;

include klimport.ash
include macros.ash
includelib import32.lib

        .586p
        .model flat
        .data

p       db  128/8 dup (0)
q       db  128/8 dup (0)
key_len= $ - offset p

e       db 0
n       db key_len dup (0)
d       db key_len dup (0)

seed    dd      4FAFDFFAh

_data   db '12345678'
        db key_len dup (0)

out_buf db key_len*2 dup(0)
bin_buf db key_len dup(0)

        .code

_start:
        int 3

        call randomize
        mov seed,eax

        mov ecx,(key_len)/4
        mov edi,offset p
pq_fill:
        push 0FFFFFFFFh
        push offset seed
        call rnd
        add esp,4
        stosd
        loop pq_fill
;------------------------------------------------------------------------------

        mov ecx,key_len
        mov edi,offset n
        mov edx,offset d
        mov esi,offset e
        mov ebx,offset p
        call RSA_keys

        mov ebx,1
        mov edx,offset _data
;       ESI = e
;       EDI = n
;       ECX = Key len
        call RSA_encrypt

        pusha
        mov ecx,key_len/3+1
        mov esi,edx
        mov edi,offset out_buf

convert:
        call bin3ascii

        add esi,3
        add edi,4
        loop convert
        popa

;---------------------------------------------------------------------------
        pusha
        mov ecx,(key_len/3+1)*4
        mov esi,offset out_buf
        mov edi,offset bin_buf

unconvert:
        call ascii3bin
        add esi,4
        add edi,3
        loop unconvert

        popa
;---------------------------------------------------------------------------

        mov edx,offset bin_buf
        mov ebx,ecx
        mov esi,offset d
        call RSA_encrypt

        push 0
        xcall ExitProcess

include math.inc
include rsa.inc
include rnd.inc
include bin3ascii.inc

end _start