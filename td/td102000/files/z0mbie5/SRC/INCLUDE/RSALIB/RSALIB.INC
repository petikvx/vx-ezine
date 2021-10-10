
; Here it is -- RSA encryption written in assembler. FREEWARE!
;
; You may use this sources in any vx-related (or destructive) purposes.
;
;                                                                     Z0MBiE
;                                                      http://z0mbie.cjb.net

; to encrypt/decrypt data just call rsa_main(...). see EXAMPLE
;
; FEATURES:
; - code is fucking slow
; - but it works
; - no overflow & other checking
; - fixed length of bignumbers (see BN_xxx consts)
; - to create your RSA keys see howkey.zip/scrgrab.zip/txt2den.zip
;
; Q> how many data bytes may be encrypted per one call to rsa_main() ?
; a> when encrypting, your data is represented as a big number,
;    and it should be less than m_, so accept max data block size
;    equal to ((rsa_bit/8)-1) bytes.
;
; NOTE:
; - Size of big numbers (RSA_BIT or BN_BIT) should be aligned to 32-bits;
;   this because DWORDs are used in encryption subroutines.
; - Highest (last) bit in all big numbers which are passed to the rsa_main()
;   should be 0. This can be achieved in two ways:
;   1. when generating keys (using PGP) use key sizes 511,1023,2047,etc-bits.
;      by the way, even if you selected 511-bit key, rsa_bit in the DEN.INC
;      should be equal to 512, etc. (32-bit aligned)
;   2. add DD 0 to the end of the each number (D,E,N) and
;      change the following line from 'BN_BIT equ rsa_bit' to
;      'BN_BIT equ (rsa_bit+32)'.

BN_BIT                  equ     rsa_bit         ; both to be 32-bit aligned
BN_BYTE                 equ     BN_BIT/8
BN_DWORD                equ     BN_BIT/32
MAX_BLOCK_SIZE          equ     ((rsa_bit/8)-1)

; subroutine: rsa_main
; action:     x_ = (a_^b_) mod m_

rsa_main                proc    pascal
                        arg     m_:DWORD         ; modulus
                        arg     b_:DWORD         ; exponent
                        arg     x_:DWORD         ; result
                        arg     a_:DWORD         ; base
                        local   p_:DWORD:BN_DWORD; temporary (a_^i) mod m_
                        local   t_:DWORD:BN_DWORD; temporary bgnumber
                        pusha

                        cld

; x_ = 1
                        mov     edi, x_
                        mov     eax, 1
                        stosd
                        mov     ecx, BN_DWORD-1
                        dec     eax
                        rep     stosd

; p_ = a_
                        lea     edi, p_
                        mov     esi, a_
                        mov     ecx, BN_DWORD
                        rep     movsd

; ebx = highestbit(b_)
                        mov     edi, b_
                        call    @@bitscan

; for (edx=0; edx<=ebx; edx++)

                        xor     edx, edx
@@pwr_cycle:            push    edx
                        push    ebx

; if (b_.bit[edx])
                        mov     eax, b_
                        bt      [eax], edx
                        jnc     @@pwr_nobit

; x_=(x_*p_) mod m_
                        mov     edx, x_
                        call    @@mulmod

@@pwr_nobit:

; p_=(p_*p_) mod m_
                        lea     edx, p_
                        call    @@mulmod

; } // for
                        pop     ebx
                        pop     edx

                        inc     edx
                        cmp     edx, ebx
                        jbe     @@pwr_cycle

                        popa
                        ret

; input:  x_ in EDX
; action: x_=(x_*p_) mod m_
; used:   t_

                        align   4
@@mulmod:
                        lea     edi, t_
                        mov     ecx, BN_DWORD
                        xor     eax, eax
                        rep     stosd

                        lea     edi, p_
                        call    @@bitscan

@@mul_cycle:            lea     edi, t_
                        mov     ecx, BN_DWORD
                        xor     eax, eax
@@shl_cycle:            rcl     dword ptr [edi], 1
                        lea     edi, [edi+4]
                        loop    @@shl_cycle

                        call    @@cmpsub

                        bt      p_, ebx
                        jnc     @@mul_nobit

                        mov     esi, edx
                        lea     edi, t_
                        xor     eax, eax
                        mov     ecx, BN_DWORD
@@add_cycle:            mov     eax, [esi]
                        adc     [edi], eax
                        lea     esi, [esi+4]
                        lea     edi, [edi+4]
                        loop    @@add_cycle

                        call    @@cmpsub

@@mul_nobit:            dec     ebx
                        jns     @@mul_cycle

                        mov     edi, edx
                        lea     esi, t_
                        mov     ecx, BN_DWORD
                        rep     movsd

                        retn

; input:  EDI=bignumber
; output: EBX=number of highest bit (0-based)

@@bitscan:              mov     ebx, BN_BIT-1
@@bitscan_cycle:        bt      [edi], ebx
                        jc      @@bitscan_exit
                        dec     ebx
                        jnz     @@bitscan_cycle
@@bitscan_exit:         retn

; action: if (t_>=m_) t_-=m_;

                        align   4
@@cmpsub:
                        lea     esi, t_
                        mov     edi, m_
                        mov     ecx, BN_DWORD-1
@@cmp_cycle:            mov     eax, [esi+ecx*4]
                        cmp     eax, [edi+ecx*4]
                        jb      @@cmpsub_exit
                        ja      @@sub
                        dec     ecx
                        jns     @@cmp_cycle
@@sub:
                        mov     esi, m_
                        lea     edi, t_
                        xor     eax, eax
                        mov     ecx, BN_DWORD
@@sub_cycle:            mov     eax, [esi]
                        sbb     [edi], eax
                        lea     esi, [esi+4]
                        lea     edi, [edi+4]
                        loop    @@sub_cycle
@@cmpsub_exit:
                        retn

                        endp
