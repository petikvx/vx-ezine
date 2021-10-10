;²² RSAkeys ²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;
;In:    ECX = Key length
;       EBX = random p & q
;
;       EDI = n ( key_len*2 )
;       ESI = e bufer (    1    )
;       EDX = d bufer ( key_len*2 )
;

RSA_keys:
        pusha
        lea eax,[ecx*2+2]
        sub esp,eax
        mov ebp,esp

        push edx
        push esi

;² p,q ²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²

        push edi

        push ecx                                        ;
        mov edi,ebp                                     ; copy p & q
        mov esi,ebx                                     ;
        rep movsb                                       ;
        pop ecx                                         ;

        shr ecx,1                                       ; key_len / 2

        mov edi,ebp                                     ; EAX = EDI = p
        call fast_prime                                 ;
        mov eax,edi                                     ;

        lea edi,[ebp+ecx]                               ; ESI = EDI = q
        call fast_prime                                 ;
        mov esi,edi                                     ;

        pop edi


;² p*q ²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²

        ; EDI = n bufer
        ; ESI = q

        push esi
        push ecx                                        ;
        push edi                                        ;
        rep movsb                                       ; q  n
        pop edi                                         ;
        pop ecx                                         ;

        mov edx,ecx                                     ; EDX = key len /2
        mov esi,eax                                     ; ESI = p
        call mul_nm                                     ; n = p*q
        pop esi

;² (p-1)*(q-1) ²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²

        mov bl,1
        ; EDX = key len/2

        mov edi,esi                                     ;
        call bsub_n                                     ; p--

        mov edi,eax                                     ;
        call bsub_n                                     ; q--

        ; ECX = key len/2
        xchg edi,eax                                    ; EDI = p1q1 bufer(p-1)
        ; ESI = q-1
        call mul_nm                                     ; (p-1)*(q-1)

;² e   ²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²

        pop esi                                         ; e bufer
        mov 1 ptr [esi],1

        shl edx,1                                       ; EDX = key len
        lea edi,[ebp+edx]                               ; temp p1q1

rsa_keys_e:
        add 1 ptr[esi],2                                ; start from 3
        mov ecx,edx

        push esi                                        ;
        push edi                                        ;
        mov esi,ebp                                     ; p1q1  temp p1q1
        rep movsb                                       ;
        pop edi                                         ;
        pop esi                                         ;

        ; EDX = key len
        ; EDI = temp (p-1)(q-1)
        ; ESI = e
        xor ecx,ecx                                     ;
        inc ecx                                         ; ECX = e_len = 1
        call mod_nm                                     ;

        cmp 1 ptr[edi],0                                ; (p-1)(q-1) mod q !=0 ?
        je rsa_keys_e                                   ;


;² d   ²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²

        pop ebx                                         ; EBX = d bufer

        xor eax,eax                                     ; k = 1

rsa_keys_d:
        inc eax                                         ; k++
        push ebx
        push esi

        mov esi,ebp                                     ; ESI = (p-1)(q-1)
        lea edi,[ebp+edx]                               ; EDI = temp
        mov ecx,edx                                     ; ECX = key_len*2

        push edi                                        ;
        push eax                                        ;
        rep movsb                                       ;
        xor eax,eax                                     ; p1q1  temp p1q1
        stosw                                           ;
        pop eax                                         ;
        pop edi                                         ;

        push eax
        mov esi,esp                                     ; ESI = k
        ; EDX = key_len*2                               ;
        ; EDI = temp (p-1)(q-1)                         ;
        xor ecx,ecx                                     ; ECX = k len = 1
        inc ecx                                         ;
        call mul_nm                                     ;
        pop eax                                         ;

        mov bl,1                                        ;
        call badd_n                                     ; +1

        ; EDI = k*p1q1+1
        ; ECX = 1
        ; EBX = d
        inc edx                                         ; EDX = k*p1q1+1 len
        pop esi                                         ; ESI = e
        pop ebx
        call div_nm

        call zero_n
        jz rsa_keys_dedn

        dec edx
        jmp rsa_keys_d

rsa_keys_dedn:
        lea eax,[edx*2]
        add esp,eax
        popa
        ret


prime_mass_cnt          equ     100
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;
;In:    ECX = Key length
;       EDI = p ( key_len )
;
fast_prime:

        pusha
        sub esp,(prime_mass_cnt*2)*2
        mov esi,esp                                     ; ESI = prime bufer

        push edi
        push ecx

        mov edi,esi
        mov ecx,prime_mass_cnt
        mov ebx,ecx                                     ; *(1)

        xor edx,edx                                     ; EDX = 1
        inc edx                                         ;

        mov ax,1

prime_tbl:

        add ax,2                                        ;
        mov 2 ptr[edi],ax                               ;
        call prime_n                                    ;
        jc prime_tbl                                    ; Build prime table
                                                        ;
        add edi,2                                       ;
        loop prime_tbl                                  ;

        pop ecx
        pop edi

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

        ; EDI = key

        test 1 ptr[edi],1
        jnz prime_mod_i

        inc 1 ptr[edi]

prime_mod_i:


;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

        ; ESI = prime table
        ; EBX = mods cnt *(1)
        lea ebp,[esi+prime_mass_cnt*2]                  ; EBP = mod table
        mov edx,ecx                                     ; EDX = key_len

        pusha
        sub esp,edx                                     ;
        mov eax,esp                                     ; EAX = key bufer

prime_mod:
        push edi
        push ecx
        push esi

        mov esi,edi                                     ; ESI = key
        mov edi,eax                                     ; EDI = temp key

        push edi
        rep movsb
        pop edi

        pop esi                                         ; ESI = M
        mov ecx,2                                       ; ECX = M len
        call mod_nm

        mov cx,2 ptr[edi]
        mov 2 ptr[ebp],cx

        add ebp,2
        add esi,2

        pop ecx
        pop edi

        dec ebx
        jnz prime_mod

        add esp,edx
        popa

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; EBP = mod table
; ESI = prime table
; EBX = mods cnt
; EDI = key
; EDX = key len

        mov eax,2                                       ; Number delta
pr_delta:

        mov ebx,prime_mass_cnt-1
pr_delta_mod:

        push eax
        push edx

        movzx ecx,2 ptr[esi+ebx*2]
        xor edx,edx
        div ecx

        movzx eax,2 ptr[ebp+ebx*2]                      ; ((p mod prime)+d(mod prime)) mod prime
        add eax,edx                                     ;
        cdq                                             ; EDX = 0
        div ecx                                         ;

        or edx,edx
        pop edx
        pop eax
        jz pr_delta_next

        dec ebx
        jns pr_delta_mod

pr_delta_prime:

        push esi
        push eax

        ; EDI = key
        ; EDX = key len
        mov esi,esp
        mov ecx,4
        call add_nm

        call prime_n
        jnc pr_delta_end

        call sub_nm

        pop eax
        pop esi

pr_delta_next:

        add eax,2
        jmp pr_delta

pr_delta_end:

        pop eax
        pop esi

        add esp,(prime_mass_cnt*2)*2                    ;******
        popa
        ret



;²² RSA ²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;In:
;       EDI = n ( key_len*2 )
;       ECX = Key length
;       ---
;       ESI = e/d bufer
;       EBX = e/d size
;       ---
;       EDX = data block (key_len*2)
RSA_encrypt:
        pusha

        mov ebp,esi                                     ; EBP = e/d
        mov esi,edi                                     ; ESI = n
        mov edi,edx                                     ; EDI = data block
        mov edx,ecx                                     ; EDX = ECX = key len
        ; EBX = e/d lem
        call powermod_nmc

        popa
        ret

