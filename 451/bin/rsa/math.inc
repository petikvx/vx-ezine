

;² BASE ADDITION N,M ²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;In:     EDI = N (N+1)
;        EDX = M length  (N>M)
;        BL = base number

badd_n:
        pushad
        mov esi,edi
        lea ecx,[edx-1]

        lodsb
        add al,bl
        stosb

        jecxz badd_n_end

badd_n_main:
        lodsb
        adc al,0
        stosb
        loop badd_n_main

badd_n_end:
        popad
        ret

;² BASE SUBSTRACTION ²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;In:     EDI = N (N+1)
;        EDX = M length  (N>M)
;        BL = base number

bsub_n:
        pushad
        mov esi,edi
        lea ecx,[edx-1]

        lodsb
        sub al,bl
        stosb

        jecxz bsub_n_end

bsub_n_main:
        lodsb
        sbb al,0
        stosb
        loop bsub_n_main

bsub_n_end:
        popad
        ret



;² ADDITION N,M ²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;In:     EDI = N (N+1)
;        ESI = M
;        ECX = M length  (N>M)

add_nm:
        pushad

        clc

add_nm_main:
        lodsb
        adc 1 ptr[edi],al
        inc edi
        loop add_nm_main

        adc 1 ptr[edi],0
        popad
        ret

;² SUBTRACTION N,M ²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;In:     EDI = N
;        ESI = M
;        ECX = M length  (N>M)

sub_nm:
        pushad
        clc

sub_nm_main:
        lodsb
        sbb 1 ptr[edi],AL
        inc edi
        loop sub_nm_main

        popad
        ret

;² SHR N ²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;In:     EDI= N
;        EDX= N length
;        ECX= bits count
shr_n:
        push ecx
        push edx

        dec edx

shr_n_cnt:
        clc
        push edx
;----------------------------------------------------------------------------
shr_n_n:
        rcr 1 ptr[edi+edx],1
        dec edx
        jns shr_n_n
;----------------------------------------------------------------------------
        pop edx
        loop shr_n_cnt

        pop edx
        pop ecx
        ret


;² SHL N ²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;In:     EDI= N
;        EDX= N length
;        ECX= bits count
shl_n:
        push ecx

shl_n_cnt:
        clc
        push edx
        push edi
;----------------------------------------------------------------------------
shl_n_n:
        rcl 1 ptr[edi],1
        inc edi

        dec edx
        jnz shl_n_n
;----------------------------------------------------------------------------
        pop edi
        pop edx
        loop shl_n_cnt

        pop ecx
        ret


;² MULTIPLICATION N,M ²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;In:     EDI = N (N+M)
;        ESI = M
;        ---
;        EDX = N lenght
;        ECX = M length  (N>M)
mul_nm:
        pushad

        lea ebx,[edx+ecx]                               ;
        sub esp,ebx                                     ; EBP = temp bufer
        mov ebp,esp                                     ;
        push ebx
        push ebp

;--[clear bufer]------------------------------------------------------------

        push ecx
        push edi

        xor eax,eax
        mov edi,ebp
        mov ecx,ebx
        rep stosb

        pop edi
        pop ecx

;---------------------------------------------------------------------------
mul_nm_m:
        xor eax,eax
        xor ebx,ebx                                     ; carry

        lodsb                                           ; M[i]
        or al,al
        jz mul_nm_next

        push edi
        push edx
        push ebp
        push ecx

mul_nm_n:
        push eax

        mul 1 ptr[edi]                                  ; *N[i]

        movzx ecx,1 ptr[ebp]                            ;
        add eax,ebx                                     ; +carry & prev result
        add eax,ecx                                     ;

        mov 1 ptr[ebp],al
        movzx ebx,ah

        pop eax

        inc ebp
        inc edi

        dec edx
        jnz mul_nm_n

        mov 1 ptr[ebp],bl

        pop ecx
        pop ebp
        pop edx
        pop edi

mul_nm_next:

        inc ebp                                         ; next result byte
        dec ecx
        jnz mul_nm_m

        pop esi                                         ;
        pop ecx                                         ; out copy
        add esp,ecx                                     ;
        rep movsb                                       ;

        popad
        ret


;² DIVISION N,M ²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;In:     EDI = N+0    out: (mod-M)
;        ESI = M
;        EBX =        out: result (N)
;        ---
;        EDX = N lenght
;        ECX = M length  (N>M)
div_nm:
        pushad

        lea eax,[ecx+1]                                 ; EAX = M len+1 (for mul_nm)
        sub esp,eax
        mov ebp,esp                                     ; EBP = mul bufer
        push eax                                        ;

        push edi                                        ;
        push ecx                                        ;
        mov edi,ebx                                     ;
        mov ecx,edx                                     ; clear result
        xor eax,eax                                     ;
        rep stosb                                       ;
        pop ecx                                         ;
        pop edi                                         ;

div_nm_high:
        cmp 1 ptr [esi+ecx-1],0
        jne div_nm_highend

        dec ecx
        jmp div_nm_high
div_nm_highend:

        mov eax,edx
        sub eax,ecx
        lea ebx,[ebx+eax]

div_nm_n:

        cmp edx,ecx
        jb div_nm_end

        push edx
        push ebx

        movzx ebx,1 ptr[esi+ecx-1]                      ; BYTE M[i_high]
        movzx eax,2 ptr[edi+edx-1]                      ; WORD N[i_high]
        cdq                                             ; EDX = 0
        div bx                                          ;
        or ax,ax

        pop ebx
        pop edx
        jz div_nm_lower                                 ; k = 0?

;----------------------------------------------------------------------------

        or ah,ah
        jz div_nm_lff

        mov ax,00FFh                                    ; AL =FF

div_nm_lff:

;--["fast" multiply of divisor to k]-----------------------------------------
; ESI=M
        pusha

        xor ebx,ebx                                     ; carry
        xchg edx,eax
        mov edi,ebp

div_nm_mul1:

        xor eax,eax
        lodsb
        mul dl
        add eax,ebx
        stosb
        movzx ebx,ah
        loop div_nm_mul1

        xchg ebx,eax
        stosb
        popa

;----------------------------------------------------------------------------
div_nm_cmp:

        pusha

        mov esi,ebp                                     ; ESI=M*k

        add edi,edx
        sub edi,ecx                                     ; EDI=N-M-1 position
        inc ecx                                         ; ECX=M*k lenght

        mov edx,ecx

        call cmp_nm
        jc div_nm_more

        call sub_nm
        clc

div_nm_more:
        popa
        jnc div_nm_lower

        dec al
        jnz div_nm_lff
;----------------------------------------------------------------------------
div_nm_lower:

        mov 1 ptr[ebx],AL                               ; k
        dec ebx

        dec edx
        jmp div_nm_n

div_nm_end:

        pop eax
        add esp,eax

div_chck_end:
        popad
        ret

;² MOD N,M ²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;In:     EDI = N
;        ESI = M
;        ---
;        EDX = N lenght
;        ECX = M length
mod_nm:
        pushad
        lea eax,[edx*2+1]
        sub esp,eax
        mov ebp,esp

        push edi
        push esi
        push ecx

        mov esi,edi
        lea edi,[ebp+edx]
        mov ecx,edx
        rep movsb

        mov 1 ptr[edi],0

        pop ecx
        pop esi

        mov ebx,ebp                                     ; quotient
        lea edi,[ebp+edx]                               ; N copy + '\0'
        call div_nm

        mov esi,edi
        pop edi

        mov ecx,edx
        rep movsb

        add esp,eax
        popad
        ret


;² POWERMOD N,M,C ²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;In:     EDI = N
;        EDX = N length
;
;        ESI = M
;        ECX = M length
;        ---
;        EBP = C
;        EBX = C len

powermod_nmc:
        pushad
                                                        ;   C           A                 B
                                                        ;                               
        lea eax,[ebx*4+ebx]                             ;ÚÄÄÄÄÄ¿ ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿   ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ  ¿
        lea eax,[eax+edx*4]                             ;³C_len³+³(N_len+C_len)*2  ³(N_len+C_len)*2³
        sub esp,eax
        push eax

;-----------------------------------------------------------------------------
        push edi                                        ;
        push ecx                                        ;
                                                        ;
        xchg ecx,eax                                    ;
        xor eax,eax                                     ; clear bufers
        lea edi,[esp+4*3]                               ;
        rep stosb                                       ;
                                                        ;
        pop ecx                                         ;
        pop edi                                         ;
;-----------------------------------------------------------------------------

        xchg eax,ebp                                    ; EAX = C
        lea ebp,[esp+4]                                 ; EBP = bufer

        push edi
        push ecx
;-----------------------------------------------------------------------------
        push esi

        xchg esi,eax                                    ;
        mov eax,edi                                     ; EAX = N
        mov edi,ebp                                     ;
        mov ecx,ebx                                     ;
        rep movsb                                       ; copy to C

        mov esi,eax                                     ; ESI = N
        mov ecx,edx                                     ; ECX = N_len
        rep movsb                                       ; copy to A

        lea edi,[edi+ebx*2]                             ;
        add edi,edx                                     ; EDI = B

        push edi
        mov esi,eax                                     ;
        mov ecx,edx                                     ;
        rep movsb                                       ; copy to B

        pop edi                                         ; EDI = B
        pop esi

;-----------------------------------------------------------------------------

        push edi                                        ;
        push edx                                        ;
        mov edi,ebp                                     ; EDI = C
        mov edx,ebx                                     ; EDX = C len

        xor ecx,ecx                                     ; ECX = 1
        inc ecx                                         ;

        call shr_n                                      ; C >>
        pop edx                                         ;
        pop edi                                         ;
        jc power_mod_mlen                               ;

;-----------------------------------------------------------------------------

        push edi                                        ;
        ;EDI = B                                        ;
        mov ecx,edx                                     ;
        xor eax,eax                                     ; B = 1
        rep stosb                                       ;
        pop edi                                         ;
        mov 1 ptr[edi],1                                ;

power_mod_mlen:

        pop ecx                                         ; ECX = M_len
        mov eax,edx                                     ; EAX = B_len

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
powermod_nm_c:

        push edx                                        ;
        push edi                                        ;
                                                        ;
        mov edi,ebp                                     ; EDI = C
        mov edx,ebx                                     ; EDX = C_len
        call zero_n                                     ;
                                                        ;
        pop edi                                         ;
        pop edx                                         ; C = 0?
        jz powermod_nm_end                              ;

        push edi
        push esi
        push ecx

        lea edi,[ebp+ebx]                               ; EDI = A
        mov esi,edi                                     ; ESI = A
        mov ecx,edx                                     ; ECX = A len
        ;EDX = A len                                    ;
        call mul_nm                                     ; A * A
        shl edx,1                                       ; EDX = A_len*2

        pop ecx
        pop esi

        ; ECX = M len
        ; EDX = A len
        ; ESI = M
        ; EDI = A
        call mod_nm
        mov edx,ecx                                     ; A_len = M_len

;------------------------------------------------------------------------------

        push edx                                        ;
        push ecx                                        ;
        mov edx,ebx                                     ; EDX = C_len
        mov edi,ebp                                     ; EDI = C
                                                        ;
        xor ecx,ecx                                     ; ECX = 1
        inc ecx                                         ;
        call shr_n                                      ;
        pop ecx                                         ; C >>
        pop edx                                         ;

        pop edi
        jnc powermod_nm_c

;------------------------------------------------------------------------------

        push edx
        push esi
        push ecx

        ; EDI = B
        lea esi,[ebp+ebx]                               ; ESI = A
        mov ecx,edx                                     ; ECX = A_len
        mov edx,eax                                     ; EDX = B_len
        call mul_nm                                     ; B = N*A

        add edx,ecx                                     ; B_len = B_len+A_len
        pop ecx
        pop esi

        ; EDX = B len
        ; ECX = M len
        ; ESI = M
        ; EDI = B
        call mod_nm
        pop edx

        mov eax,ecx                                     ; N_len = M_len
        jmp powermod_nm_c

powermod_nm_end:

        mov esi,edi                                     ; B
        pop edi                                         ; N
        ; ECX = B size
        rep movsb

        pop eax
        add esp,eax
        popad
        ret


;² ZERO N ²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;In:    EDI = N
;       EDX = N length
;Out:   ZF=1 if N=0

zero_n:
        pushad

        mov ecx,edx
        xor eax,eax
        repz scasb

        popad
        ret



;² CMP N,M ²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;In:     EDI = N
;        ESI = M
;        ECX = M length
;
;Out:    CF = 1 if N < M
;        ZF = 1 if N = M
;        CF = 0 if N > M
cmp_nm:
        pushad

        xchg esi,edi
        lea esi,[esi+ecx-1]
        lea edi,[edi+ecx-1]
        std

cmp_nm_m:
        cmpsb
        loopz cmp_nm_m

        cld
        popad
        ret


;² PRIME  N ²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;
;In:    EDI = N
;       ---
;       EDX = N length
;Out:   CF = 1 if number aren't prime
;

prime_n:
        pusha
        sub esp,edx
        mov ebp,esp

        mov 1 ptr[ebp],2                        ;
        xchg ebp,edi                            ; EBP = N , EDI = C(3)
        mov esi,ebp                             ; ESI = M = N
        mov ecx,edx                             ; ECX = M_len
        mov ebx,edx                             ; EBX = C_len

        xor edx,edx                             ; EDX = N_len = 1
        inc edx                                 ;
        call powermod_nmc

        inc edi                                 ;
        lea edx,[ebx-1]                         ; N_len - 1
        call zero_n
        jnz prime_cf1
                                                ;  N
        cmp 1 ptr[edi-1],2                      ; 3  mod N = 3 ?
        jne prime_cf1                           ;

prime_cf0:
        add esp,ebx
        popa
        clc
        ret

prime_cf1:
        add esp,ebx
        popa
        stc
        ret




