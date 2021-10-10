include src\getd.ash

;STUPID = 1

;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께
;
; Dtrash v 1.00
;
; Dtrash( VOID* DataTable,
;         DWORD DataCnt,
;         VOID* TrashTable,
;         VOID* OutBufer,
;         DWORD Flags,
;         DWORD* Seed,
;         DWORD *(RND(DWORD* SEED,DWORD Range)));
;
; Out:    EAX = Command length
;         EAX = 0 ,if error occured
;
; 					(c) 451 2002/03
;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께

@sd            equ      <+4*8+4>

@datatable     equ      4 ptr[ebp    @sd]
@datacnt       equ      4 ptr[ebp+4  @sd]
@trashtable    equ      4 ptr[ebp+8  @sd]
@outbufer      equ      4 ptr[ebp+12 @sd]
@flags         equ           [ebp+16 @sd]
@seed          equ      4 ptr[ebp+20 @sd]
@rnd           equ      4 ptr[ebp+24 @sd]

;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께

dtrash:

                pusha
                mov ebp,esp


;같 GET DATA 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같


                push @datacnt                                   ; Data count
                push @seed                                      ;
                call @rnd                                       ;
                add esp,8                                       ;
                                                                ;
                mov ecx,@datatable                              ; ESI = dtable
                shl eax,4
                add ecx,eax                                     ; ECX = Data

;같 GET COMMAND 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�
@dt_cmd:

                mov esi,@trashtable                             ;
                mov eax,DTRASH_CNT                              ; DH = flags
                mov DH, 1 ptr @flags                            ;

                test DH,DTF_MFLAGS                              ; Use flags?
                jnz @dt_flags_modify                            ;

                mov eax,DTRASH_NOFLAGS_CNT

@dt_flags_modify:

                test DH,DTF_WRITE                               ; Only read?
                jz @dt_rndcmd                                   ;

                add esi,SIZE dtrash_entry                       ; skip LEA
                dec eax                                         ;

@dt_rndcmd:
                push eax                                        ; EAX = cnt
                push @seed                                      ;
                call @rnd                                       ;
                add esp,8                                       ;
                                                                ;
                imul eax,eax,SIZE dtrash_entry                  ;
                add esi,eax                                     ; ESI = command desc.

;같 MASK/PREFIX 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�

                mov ebx,[esi.dt_flags]                          ; EBX = cmd flags
                mov edi,@outbufer                               ; EDI = out bufer

                test ebx,DT_EAX_OPT
                jz @dt_common

                test 4 ptr @flags,DTF_EAX
                jz @dt_cmd
@dt_common:
                test DH,DTF_WRITE
                jnz @dt_anycmd1

                test bl,DT_OM
                jnz @dt_cmd

@dt_anycmd1:
                mov DL,[esi.dt_mask]                            ; DL = cmd mask

;------------------------------------------------------------------------------

                mov AH,1 ptr[ecx.getd_cdType+1]                 ; AH = data size

                test ebx,DT_OFFS4                               ; work only
                jz  @dt_66get                                   ; with dwords?

                cmp AH,4
                jne @dt_cmd

@dt_66get:
                push eax

                cmp AH,1                                        ; dSize = 1 ?
                jz @dt_SDW                                      ;

                test bl,DT_W                                    ; W ?
                jnz @dt_66                                      ;

                test bl,DT_OP                                   ; Operand?
                jz @dt_SDW                                      ;

@dt_66:                                                         ;
                push 2                                          ;
                push @seed                                      ; Add
                call @rnd                                       ;  Operand
                add esp,8                                       ;   prefix
                                                                ;
                or eax,eax                                      ;
                jz @dt_SDW                                      ;

                mov AL,66h                                      ;
                stosb                                           ;
                or DH,80h                                       ; prefix flag

@dt_SDW:
                pop eax

;같 S/D/W 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�

                test bl,DT_W
                jz @dt_S

                cmp AH,1                                        ; dSize = 1 ?
                je @dt_S                                        ;

                test DH,80h                                     ; prefix?
                jnz  @dt_W1                                     ;

                cmp AH,2
                je @dt_S

                push eax
                push 2
                push @seed
                call @rnd
                add esp,8
                or eax,eax
                pop eax
                jz @dt_S

@dt_W1:
                or DL,1                                         ; W = 1
@dt_S:
;------------------------------------------------------------------------------

                test bl,DT_S
                jz @dt_D

                cmp AH,1                                        ; dSize = 1 ?
                je @dt_D                                        ;

                push 2
                push @seed
                call @rnd
                add esp,8

                or eax,eax
                jz @dt_D

                or DL,2                                         ; S = 1
@dt_D:
;------------------------------------------------------------------------------
                test bl,DT_D
                jz @dt_CRO

                test ebx,DT_XD
                jz @dt_commonD

                or DL,2
@dt_commonD:

                test DH,DTF_WRITE                               ;
                jnz @dt_CRO                                     ; ***********

@dt_D1:
                xor DL,2                                        ; D = 1/0


;같 CRO/Reg (MODR/M)  같같같같같같같같같같같같같같같같같같같같같같같같같같같같�
@dt_CRO:

                test bl,DT_0F                                   ;
                jz @dt_noF0                                     ;
                                                                ; Write 0F
                mov AL,0Fh                                      ;
                stosb                                           ;
@dt_noF0:
                mov AL,DL                                       ; Write opcode
                stosb                                           ;

                test ebx,DT_MODRM
                jz @dt_offset

                test bl,DT_CRO
                jnz @dt_cro_flag

                mov bh,1 ptr @flags+1                           ; BL = register flags

;굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
ifdef STUPID
                or bh,bh
                jnz @dt_cro_flag

                dec bh                                          ; BH=FFh
endif
;굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
@dt_cro_flag:
;------------------------------------------------------------------------------
                push ebx
                push ecx
                push edi

                mov ecx,8
                xor eax,eax
                xor edi,edi

@dt_cro_get:
                shr bh,1
                jnc @dt_cro_next

                push eax                                        ; CRO value
                inc edi
@dt_cro_next:
                inc eax
                loop @dt_cro_get

;------------------------------------------------------------------------------

                push edi                                        ;
                push @seed                                      ; get Random CRO
                call @rnd                                       ;
                add esp,8                                       ;

                movzx eax,1 ptr[esp+eax*4]                      ; AL = CRO/reg

                shl edi,2                                       ; cnt*4
                add esp,edi

                pop edi
                pop ecx
                pop ebx
@dt_modrm:

                mov AH,1 ptr[esi.dt_cro_flags]                  ; AH= cro flags
                push ecx
                mov cl,al
                shl cl,1                                        ; *******
                shr ah,cl
                pop ecx

                test DH,DTF_WRITE
                jnz @dt_anycmd2

                test AH,DA_OM
                jnz @dt_cmd
@dt_anycmd2:

                test AH,DA_NOP
                jz @dt_noF6

                xor bl,DT_OP
@dt_noF6:

                test bl,DT_CRO
                jnz @dt_modrm_stos

                test DL,1                                       ; W = 1?
                jnz @dt_modrm_stos

                cmp AL,100b
                jb @dt_modrm_stos

                push ecx
                mov CL,AL
                sub CL,100b
                mov AH,1
                shl AH,CL
                test BH,AH
                pop ecx
                jz @dt_cmd

@dt_modrm_stos:

                ;**********
                shl AL,3                                        ; r/o = CRO/reg
                or AL,00000101b                                 ; mod = 00,r/m=101
                stosb                                           ; MODRM

;같 Offset  같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�
@dt_offset:

                mov eax,[ecx.getd_dRVA]                         ; Write offset
                stosd                                           ;

;같 Operand 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�
@dt_operand:

                test bl,DT_OP
                jz @dt_exit

                push 4 ptr[esi.dt_range]                        ;
                push @seed                                      ; Get operand
                call @rnd                                       ;
                add esp,8                                       ;

                test bl,DT_OP1
                jnz @dt_op_stosb

                test bl,DT_S
                jz @dt_op_w

                test DL,2                                       ; S = 1 ?
                jnz @dt_op_stosb                                ;
@dt_op_w:
                test DL,1                                       ; W = 1 ?
                jz @dt_op_stosb                                 ;

                test DH,80h                                     ; 66h ?
                jz @dt_op_stosd                                 ;

                stosw                                           ; 2
                jmp @dt_exit                                    ;
@dt_op_stosd:
                stosd                                           ; 4
                jmp @dt_exit                                    ;

@dt_op_stosb:
                stosb                                           ; 1

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같


@dt_exit:
                xchg eax,edi
                sub eax,@outbufer

                mov [esp._eax],eax
                popa
                ret
