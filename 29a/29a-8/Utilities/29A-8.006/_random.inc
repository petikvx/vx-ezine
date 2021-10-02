
; input:  EDI=buffer
;         ECX=buffer size
; action: fill with random data

gen_rndbuf:             pusha

                        lea     esi, [esp+3*4]  ; pusha.esp -- unused

                        push    edi                       ; buf
                        push    ecx                       ; len

                        xor     ebx, ebx
                        push    0F0000000h  ; CRYPT_VERIFYCONTEXT  tnx2 d-x-l
                        push    1           ; PROV_RSA_FULL
                        push    ebx         ; 0
                        push    ebx         ; 0
                        push    esi         ; hProv
                        callW   CryptAcquireContextA

                        or      eax, eax
                        stc
                        jz      __exit

                        push    dword ptr [esi]           ; hProv
                        callW   CryptGenRandom

                        push    ebx              ; 0
                        push    dword ptr [esi]  ; hProv
                        callW   CryptReleaseContext

                        clc
__exit:
                        popa
                        retn
