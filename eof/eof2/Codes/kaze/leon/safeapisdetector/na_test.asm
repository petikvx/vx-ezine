.386p
.model flat,STDCALL

extrn MessageBoxA:PROC
extrn ExitProcess:PROC
extrn CreateFileA:PROC
extrn LoadLibraryA:PROC
extrn GetProcAddress:Proc
extrn WriteFile:PROC
extrn CloseHandle:PROC
extrn DeleteFileA:PROC
extrn GetCommandLineA:PROC
extrn GetTickCount:PROC

NB_ESSAIS       EQU 10000 ;nb de tests avant de la déclarer safe
PREMIER_ESSAI   EQU 15  ;max arguments pour les apis

.data

RAND_SEED       dd 45980131

fhandle dd ?
fname db "na_retour.txt",0

apiname db 50 dup (0)
dllname db 50 dup (0)
apiadr dd ?
dlladr dd ?

nb_argsa db '0',0
nb_args dd 0
sesp dd 0



.code
start:
     call GetTickCount
     mov RAND_SEED,eax
;delete l'ancien na_retour
     call DeleteFileA, offset fname
     call GetCommandLineA
     mov esi,eax

;parse la commandline
arg0:
     lodsb
     cmp al,0
     jz fin
     cmp al,' '
     jnz arg0
;recup le nom de la dll
     mov edi,offset dllname
arg1:
     lodsb
     cmp al,0
     jz fin
     cmp al,' '
     jz arg2
     stosb
     jmp arg1
arg2:
     mov edi,offset apiname
;recup le nom de l'api
arg3:
     lodsb
     cmp al,0
     jz arg4
     cmp al,' '
     jz arg4
     stosb
     jmp arg3
arg4:
;recup l'adress de l'api
     call LoadLibraryA, offset dllname
     test eax,eax
     jz fin
     mov dlladr,eax
     call GetProcAddress,eax,offset apiname
     test eax,eax
     jz fin
     mov apiadr,eax
;cree na_retour.txt
     call CreateFileA,offset fname,0C0000000h,1,0,2,0,0
     cmp eax,0
     jz fin
     cmp eax,-1
     jz fin

     mov fhandle,eax
;mets en place le seh
seh_handler:
     mov esp,[esp+8]
     pop dword ptr fs:[0]
     add esp,4
     call ExitProcess,0

seh:
     push dword ptr fs:[0]
     mov fs:[0],esp
;premier essai: on determine le nb d'arguments
     mov eax,PREMIER_ESSAI
     call rand_pushs
     mov sesp,esp
     call [apiadr]
     mov eax,esp
     sub eax,sesp

     shr eax,2
     mov nb_args,eax
     add al,'0'
     mov nb_argsa,al
     sub al,'0'

     add esp,PREMIER_ESSAI*4
;test intensif l'api
     mov ecx,NB_ESSAIS
lp_essais:
     push ecx
     mov eax,nb_args
     call rand_pushs
     call [apiadr]
     pop ecx
     loop lp_essais
;tout s'est bien passé
     call WriteFile,fhandle,offset nb_argsa,2,offset nb_args,0
     call CloseHandle, fhandle

fin:
     call ExitProcess,0


;=============================================================

rand_pushs proc near  ; in: eax=nb de pushs
    test eax,eax
    jz rp_fin
    pop ebx
    mov ecx,eax
rp_1:
    xor eax,eax
    dec eax
    call rand_tuna
    push eax
    loop rp_1
    push ebx
rp_fin:
    ret
rand_pushs endp


rand_tuna proc near    ;in: eax=val max   out: eax=rand()
    push edx
    push ebx
    push eax
    mov eax,RAND_SEED   ;on initialise eax avec la "graine"
    mov ebx,eax         ;on copie eax dans ebx c-a-d RAND_SEED
    shl eax,13          ;eax = (n << D2) = res1
    xor eax,ebx         ;eax = (res1 ^ n) = res2
    shr eax,19          ;eax = (res2 >> D3) = res3
    and ebx,4294967294  ;ebx = (n & E) = res4
    shl ebx,12          ;ebx = (res4 << D1) = res5
    xor eax,ebx         ;eax = (res5 ^ res3) = resultat final
    mov dword ptr  RAND_SEED,eax  ;on sauvegarde le resultat final
    xor edx,edx
    pop ebx
    div ebx
    mov eax,edx
    pop ebx
    pop edx
    or eax,eax
    ret             ;fini, vous trouvez le npa dans RANDOM_SEED
rand_tuna endp

end start