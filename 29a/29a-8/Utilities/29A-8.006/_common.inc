
pusha_struct            struct
pusha_edi               dd      ?
pusha_esi               dd      ?
pusha_ebp               dd      ?
pusha_esp               dd      ?
pusha_ebx               dd      ?
pusha_edx               dd      ?
pusha_ecx               dd      ?
pusha_eax               dd      ?
                        ends

; CF:EDI[] = (EDI[] << 1) | CF

RCL_CYCLE               macro
                        local   __rcl_cycle
__rcl_cycle:            rcl     dword ptr [edi], 1
                        lea     edi, [edi+4]
                        loop    __rcl_cycle
                        endm

; EDI[0..ECX-1] vs ESI[0..ECX-1]

CMP_CYCLE               macro   j_below, j_above
                        local   __cmp_cycle
                        dec     ecx
__cmp_cycle:            mov     eax, [edi+ecx*4]
                        cmp     eax, [esi+ecx*4]
                        jb      j_below
                        ja      j_above
                        dec     ecx
                        jns     __cmp_cycle
; j_equal:
                        endm

; CF:EDI[0..ECX-1] -= ESI[0..ECX-1] + CF

SBB_CYCLE               macro
                        local   __sbb_cycle
__sbb_cycle:            mov     eax, [esi]
                        sbb     [edi], eax
                        lea     esi, [esi+4]
                        lea     edi, [edi+4]
                        loop    __sbb_cycle
                        endm

; CF:EDI[0..ECX-1] = ESI[0..ECX-1] - CF

COPY_SBB_CYCLE          macro
                        local   __cpy_sbb_cycle
__cpy_sbb_cycle:        lodsd
                        sbb     eax, 0
                        stosd
                        loop    __cpy_sbb_cycle
                        endm

; CF:EDI[0..ECX-1] += ESI[0..ECX-1] + CF

ADC_CYCLE               macro
                        local   __adc_cycle
__adc_cycle:            mov     eax, [esi]
                        adc     [edi], eax
                        lea     esi, [esi+4]
                        lea     edi, [edi+4]
                        loop    __adc_cycle
                        endm
