@dt             equ     <- offset DES_tables>

;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;In:    EDX:EAX = 64(56)-bit key
;        EAX=low
;        EDX=high
;       EDI = K1-K16 bufer
;       EBP = DES tables
DESinit:
        pushad

        mov ecx,28
        push ecx
        lea esi,[ebp+PC1_C0 @dt]
        call permutate
        pop ecx

        push ebx

        ;ECX=28
        add esi,ecx                                     ; ESI=PC1_D0
;        mov ecx,28
;        lea esi,[ebp+PC1_D0 @dt]
        push ecx
        call permutate
        pop ecx

        mov edx,ebx                                     ; EDX=d0
        pop ebx
        xchg eax,ebx                                    ; EAX=c0


;        lea esi,[ebp+SHIFT @dt]
        add esi,ecx                                     ; ESI = SHIFT
        mov ecx,16

keys_cycle:
        push ecx

        push eax
        lodsb
        xchg ecx,eax
        pop eax

;------------------------------------------------------------------------------

        xor ebx,ebx                                     ;
        shrd ebx,eax,CL                                 ; ror-28
        shr eax,CL                                      ;
        shr ebx,4                                       ; c0
        or eax,ebx                                      ;

        xor ebx,ebx                                     ;
        shrd ebx,edx,CL                                 ; ror-28
        shr edx,CL                                      ;
        shr ebx,4                                       ; d0
        or edx,ebx                                      ;

        push eax
        push edx
        push esi

        shl eax,4                                       ; add d0 to c0
        shrd eax,edx,4                                  ;
        shr edx,4

        lea esi,[ebp+PC2 @dt]                           ;
        mov ecx,48                                      ; PC-2
        call permutate                                  ;

        xchg eax,ebx                                    ;
        stosd                                           ;
                                                        ; K(n)
        xchg eax,ecx                                    ;
        stosd                                           ;

        pop esi
        pop edx
        pop eax
;------------------------------------------------------------------------------

        pop ecx
        loop keys_cycle

        popad
        ret


;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; F(R(n),K(n))
;
;In:    EAX=R(n)
;       EDI=key offset
;       EBP = DES tables
;
;Out:   EBX=F
F	macro
        push ecx
        push edx
        push eax
        push edi

        lea esi,[ebp+E @dt]
        mov ecx,48
        call permutate                                  ; expand R(n)

        ;ECX:EBX = expanded R(n)

        xchg eax,ebx
        mov edx,ecx

        xor eax,[edi]                                   ; expanded
        xor edx,[edi+4]                                 ;      R(n) xor K(n)

;--[Substitution]------------------------------------------------------------

        xor edi,edi

;        lea esi,[ebp+S1 @dt]
        add esi,48                                      ; ESI = S1
        mov ecx,8

substitution:
        push ecx

;        mov bh,bl                                       ;
;        and bl,1                                        ;
;        shr bh,4                                        ;
;        and bh,10b                                      ; EBX = line
;        or bl,bh                                        ;
;        xor bh,bh                                       ;

        xor ebx,ebx
        shrd ebx,eax,1
        bt eax,5
        rcr ebx,1
        shr ebx,(32-2)-4

;        shl ebx,4                                       ; * 16

        mov cl,al
        and cl,11110b                                   ; ECX = row
        shr ecx,1                                       ;

        or bl,cl                                        ; ECX=line*16+row
        mov bl,1 ptr[esi+ebx]                           ; BL=S(n).row

        shrd edi,ebx,4                                  ; add part

        shrd eax,edx,6
        shr edx,6
        add esi,16*4                                    ; next S
        pop ecx
        loop substitution

        ;EDI = Substitution (R(n) xor K(n))

        xchg eax,edi

        ;ESI = P
;        lea esi,[ebp+P @dt]
        mov ecx,32
        call permutate

        ;EBX = F

        pop edi
        pop eax
        pop edx
        pop ecx
        endm

;²² DES encrypt ²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;In:    EDX=high
;       EAX=low
;       EBP = DES tables
;       EDI= K1-K16 bufer
;
;Out:   EDX:EAX=crypted data block

DESencrypt:
        push ebx
        push ecx
        push esi
        push edi

        mov ecx,16

;----------------------------------------------------------------------------
encrypt:
        ;EAX=R(n)
        F
        ;EBX=F
        xor edx,ebx                                     ; Ln=Ln xor F(K(n),R(n))
        xchg eax,edx                                    ; L(n)  R(n)

        scasd                                           ;
        scasd                                           ; add edi,8
        loop encrypt

;----------------------------------------------------------------------------
        pop edi
        pop esi
        pop ecx
        pop ebx
        ret




;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;In:    EDX:EAX=input block
;       ESI=permutation table
;       ECX=length
;
;Out:   ECX:EBX=permutated d0+c0
permutate:
        push esi
        push edi

        push edx
        push eax
        mov edi,esp

        xor ebx,ebx
        xor eax,eax
        cdq

        push ecx
perm_main:
        lodsb
        dec eax
        shrd ebx,edx,1
        bt [edi],eax
        rcr edx,1
        loop perm_main
        pop esi

        mov ecx,32

        cmp esi,ecx
        ja perm_shift

        xchg edx,ebx
        add esi,ecx

perm_shift:
        shl ecx,1
        sub ecx,esi

        shrd ebx,edx,cl
        shr edx,cl
        xchg edx,ecx

        pop eax
        pop edx
        pop edi
        pop esi
        ret
