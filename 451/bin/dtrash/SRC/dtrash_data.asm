
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�
;
; Dtrash 1.0 opcode table
;
; 			(c) 451 2002/03
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�

trash_table:

;===========================================================================
                db      8Dh                             ; LEA
                dd      DT_MODRM
                dd      0
                dw      0
;===========================================================================
                db      88h                             ; MOV
                dd      DT_D+DT_W+DT_MODRM
                dd      0FFFFFFFFh
                dw      0
;---------------------------------------------------------------------------
                db      0A0h                            ; MOV mem,eax/ax/al
                dd      DT_D+DT_W+DT_XD+DT_EAX_OPT
                dd      0
                dw      0
;---------------------------------------------------------------------------
                db      0C6h                            ; MOV mem,im
                dd      DT_W+DT_MODRM+DT_CRO+DT_ALL+DT_OP+DT_OM
                dd      0FFFFFFFFh                      ; any r/o
                dw      0

DTRASH_NOFLAGS_CNT = ($ - offset trash_table)/SIZE dtrash_entry

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�

                db      38h                             ; CMP
                dd      DT_D+DT_W+DT_MODRM
                dd      0
                dw      0
;---------------------------------------------------------------------------
                db      84h                             ; TEST
                dd      DT_W+DT_MODRM
                dd      0
                dw      0
;---------------------------------------------------------------------------
                db      30h                             ; XOR
                dd      DT_D+DT_W+DT_MODRM
                dd      0
                dw      0
;---------------------------------------------------------------------------
                db      00h                             ; ADD
                dd      DT_D+DT_W+DT_MODRM
                dd      0
                dw      0
;---------------------------------------------------------------------------
                db      10h                             ; ADC
                dd      DT_D+DT_W+DT_MODRM
                dd      0
                dw      0
;---------------------------------------------------------------------------
                db      18h                             ; SBB
                dd      DT_D+DT_W+DT_MODRM
                dd      0
                dw      0
;---------------------------------------------------------------------------
                db      28h                             ; SUB
                dd      DT_D+DT_W+DT_MODRM
                dd      0
                dw      0
;---------------------------------------------------------------------------
                db      20h                             ; AND
                dd      DT_D+DT_W+DT_MODRM
                dd      0
                dw      0
;---------------------------------------------------------------------------
                db      80h                             ; 80h group
                dd      DT_ALL+DT_S+DT_W+DT_MODRM+DT_CRO+DT_OP+DT_OM
                dd      0FFFFFFFFh
                dw      0
                ; ADD
                ; OR
                ; ADC
                ; SBB
                ; AND
                ; SUB
                ; XOR
                ; CMP

;---------------------------------------------------------------------------
                db      0C0h                            ; C0 group (cmd,im8)
                dd      (DT_1+DT_2+DT_3+DT_4+DT_5+DT_6+DT_8) \
                        +DT_W+DT_CRO+DT_MODRM+DT_OP+DT_OP1+DT_OM
                dd      32
                dw      0
                ; ROL
                ; ROR
                ; RCL
                ; RCR
                ; SHL
                ; SHR
                ; SAL
                ; SAR
;---------------------------------------------------------------------------
                db      0D0h                            ; D0 group (cmd,1)
                dd      (DT_1+DT_2+DT_3+DT_4+DT_5+DT_6+DT_8) \
                        +DT_W+DT_CRO+DT_MODRM+DT_OM
                dd      0
                dw      0
                ; ROL
                ; ROR
                ; RCL
                ; RCR
                ; SHL
                ; SHR
                ; SAL
                ; SAR
;---------------------------------------------------------------------------
                db      0D2h                            ; D2 group (cmd,cl)
                dd      (DT_1+DT_2+DT_3+DT_4+DT_5+DT_6+DT_8) \
                        +DT_W+DT_CRO+DT_MODRM+DT_OM
                dd      0
                dw      0
                ; ROL
                ; ROR
                ; RCL
                ; RCR
                ; SHL
                ; SHR
                ; SAL
                ; SAR
;---------------------------------------------------------------------------
                db      0A4h                            ; SHLD mem,reg,i8
                dd      DT_0F+DT_MODRM+DT_OP+DT_OP1+DT_OFFS4+DT_OM
                dd      0FFFFFFFFh
                dw      0
;---------------------------------------------------------------------------
                db      0A5h                            ; SHLD mem,reg,cl
                dd      DT_0F+DT_MODRM+DT_OFFS4+DT_OM
                dd      0
                dw      0
;---------------------------------------------------------------------------
                db      0ACh                            ; SHLD mem,reg,im8
                dd      DT_0F+DT_MODRM+DT_OP+DT_OP1+DT_OFFS4+DT_OM
                dd      0FFFFFFFFh
                dw      0
;---------------------------------------------------------------------------
                db      0ADh                            ; SHLD mem,reg,cl
                dd      DT_0F+DT_MODRM+DT_OFFS4+DT_OM
                dd      0
                dw      0
;---------------------------------------------------------------------------
                db      0BAh                            ; BA group
                dd      (DT_5+DT_6+DT_7+DT_8) \
                        +DT_0F+DT_CRO+DT_MODRM+DT_OP+DT_OP1+DT_OFFS4
                dd      32
                dw      DA_OM_6+DA_OM_7+DA_OM_8
                ;
                ;
                ;
                ;
                ; BT
                ; BTS
                ; BTR
                ; BTC
;---------------------------------------------------------------------------
                db      0F6h                            ; F6 group
                dd      (DT_1+DT_3+DT_4)\
                        +DT_W+DT_MODRM+DT_CRO+DT_OP
                dd      0FFFFFFFFh
                dw      DA_NOP_3+DA_NOP_4+DA_OM_3+DA_OM_4
                ; TEST 000
                ;
                ; NOT  010
                ; NEG  011
                ;
                ;
                ;
                ;
;---------------------------------------------------------------------------
                db      0FEh                            ; FE group
                dd      (DT_1+DT_2)\
                        +DT_W+DT_MODRM+DT_CRO+DT_OM
                dd      0
                dw      0
                ; INC
                ; DEC
                ;
                ;
                ;
                ;
                ;
                ;

DTRASH_CNT= ($ - offset trash_table)/SIZE dtrash_entry
