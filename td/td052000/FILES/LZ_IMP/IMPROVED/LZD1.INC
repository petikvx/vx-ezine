;
;=============================================================================
;LZ32Decompression subroutines.
;All rights may be reserved by SexyDufus
;Disassembled by IDA v3.xx with little help of Green Monster ;-)
;==============================================================================
;
;Interface:
;int   lz_decompresss(char *inbuf, char *outbuf, int size, char *buf)
;
;-----------------------------------------------------------------------------
;��ᦨ���� ������� ����� �� inbuf, �����뢠� ����祭��� � outbuf.
;��� ᫮���� �ᯮ������ ���譨� ����� (buf)
;�����頥� ࠧ��� ⮣�, �� ����稫���.
;=============================================================================
;

VarFrame        struc                      ;
vf_Const01FF    dw ?                       ;��᪠ (����⭠�)
vf_Const03FF    dw ?                       ;�� ����
vf_Const07FF    dw ?                       ;�����
vf_Const0FFF    dw ?                       ;��᫥����
                                           ;
vf_Sym1         dw ?                       ;�������
vf_Sym2         dw ?                       ;
vf_Sym3         dw ?                       ;
                                           ;
vf_FreeSym      dw ?                       ;�������� ᨬ���
vf_CharCount    dw ?                       ;���稪 �㪢
vf_DictSize     dw ?                       ;������ ᫮����
vf_BitSize      dw ?                       ;����來����
vf_SimpleChar   db ?                       ;�㪢�
vf_CharToLink   db ?                       ;� ⠪ ����⭮
                                           ;
vf_InBufRelPos  dw ?                       ;������ �� �室��� ����
field_1A        dw ?                       ;
vf_OutBufPos    dd ?                       ;������ � ��室��� ����
field_20        dw ?                       ;
field_22        dw ?                       ;
                                           ;��㬥���
vf_InBuf        dd ?                       ;char *inbuf
vf_OutBuf       dd ?                       ;char *outbuf
vf_SuxxSize     dd ?                       ;char *size (�� �㦎�)
vf_Malloced     dd ?                       ;char *buf (᫮����)
VarFrame        ends                       ;
                                           ;
;=============================================================================
;�᭮���� ��楤�ઠ
;=============================================================================
lz_decompress   proc near                  ;
                sub     eax, eax           ;
                push    eax                ;���樠������ ��������
                push    eax                ;
                push    9                  ;
                push    2000000h           ;
                push    1020000h           ;
                push    eax                ;
                push    0FFF07FFh          ;����饭᪨� ��᪨
                push    3FF01FFh           ;
                mov     ebp, esp           ;
                                           ;
get_next_sym:                              ;
                call    Get_Sym            ;����稫� ᨬ���
                cmp     ax, 101h           ; 101h - ����� ������
                jz      lzd_exit           ;
                cmp     ax, 100h           ; 100h - ��� ᫮����
                jnz     short other_syms   ;
                                           ;
                call    lzd_init           ;����
                                           ;
                call    Get_Sym            ;� ᨬ����� �� ��������
                mov     [ebp+VarFrame.vf_Sym1], ax        ;
                mov     [ebp+VarFrame.vf_Sym2], ax        ;
                mov     [ebp+VarFrame.vf_CharToLink], al  ;
                mov     [ebp+VarFrame.vf_SimpleChar], al  ;
                call    Save_Char          ;���� ᨬ��� �ᥣ�� ���⮩
                jmp     short get_next_sym ;
; ���������������������������������������������������������������������������
                                           ;
other_syms:                                ;
                mov     [ebp+VarFrame.vf_Sym1], ax      ;
                mov     [ebp+VarFrame.vf_Sym3], ax      ;
                cmp     ax, [ebp+VarFrame.vf_FreeSym]   ;������ 㦥 � ᫮���?
                jl      short already_in_dict           ;
                                                        ;
                movzx   eax, [ebp+VarFrame.vf_Sym2]     ;
                mov     [ebp+VarFrame.vf_Sym1], ax      ;
                movzx   eax, [ebp+VarFrame.vf_SimpleChar]
                push    eax                             ;��⠢��� � �⥪�
                inc     [ebp+VarFrame.vf_CharCount]     ;
                                                        ;
already_in_dict:                                        ;
                cmp     [ebp+VarFrame.vf_Sym1], 0FFh    ;
                jle     short one_time_again            ;
;                                                       ;
                movzx   ebx, [ebp+VarFrame.vf_Sym1]     ;
                call    _Calc_Sym_Pos                   ;
                mov     al, [ebx+2]                     ;
                push    eax                             ;���⠢�塞 楯��� � �⥪�
                inc     [ebp+VarFrame.vf_CharCount]     ;
                movzx   eax, word ptr [ebx]             ;
                mov     [ebp+VarFrame.vf_Sym1], ax      ;
                jmp     short already_in_dict           ;
; ���������������������������������������������������������������������������
                                                        ;
one_time_again:                                         ;
                movzx   eax, [ebp+VarFrame.vf_Sym1]        ;
                mov     [ebp+VarFrame.vf_SimpleChar], al   ;
                mov     [ebp+VarFrame.vf_CharToLink], al   ;
                push    eax                                ;
                inc     [ebp+VarFrame.vf_CharCount]        ;
                movzx   ecx, [ebp+VarFrame.vf_CharCount]   ;
                jcxz    no_chars                           ;
                                                           ;
save_from_stack:                                           ;�����뢠�� 楯���
                pop     eax                                ;
                call    Save_Char                          ;� ��室��� ��⮪
                loop    save_from_stack                    ;
                                                           ;
no_chars:                                                  ;
                mov     [ebp+VarFrame.vf_CharCount], cx    ;
                                                           ;
                call    Add_Chain                          ;
                movzx   eax, [ebp+VarFrame.vf_Sym3]        ;
                mov     [ebp+VarFrame.vf_Sym2], ax         ;
                movzx   ebx, [ebp+VarFrame.vf_FreeSym]     ;
;                                                          ;
                cmp     bx, [ebp+VarFrame.vf_DictSize]     ;
                jl      get_next_sym                       ;
;                                                          ;
;-------->replaced<-----------------                        ;
;                cmp     [ebp+VarFrame.vf_BitSize], 0Ch     ;
                cmp     [ebp+VarFrame.vf_BitSize], MAX_BITS ;�஢��塞 ࠧ�來����
;-------->end<---------------------                        ;
                jz      get_next_sym                       ;
                                                           ;
                inc     [ebp+VarFrame.vf_BitSize]          ;�����稢��� ��
                shl     [ebp+VarFrame.vf_DictSize], 1      ;� ࠧ��� ᫮����
                jmp     get_next_sym                       ;
; ���������������������������������������������������������������������������
                                                           ;
lzd_exit:                                                  ;
                xchg    eax, edi                           ;EAX = end-start = size
                sub     eax, [ebp+VarFrame.vf_OutBuf]      ;
                add     esp, 20h                           ;
                retn    10h                                ;
lz_decompress   endp                                       ;
                                                           ;
;-----------------------------------------------------------------------------
;������뢠�� ���� ������� ᫮���� �� ������ ᨬ����
;-----------------------------------------------------------------------------
_Calc_Sym_Pos   proc near                                  ;
                lea     ebx, [ebx+ebx*2]                   ;EBX *= 3
                add     ebx, [ebp+VarFrame.vf_Malloced]    ;
                retn                                       ;
_Calc_Sym_Pos   endp                                       ;
                                                           ;
;-----------------------------------------------------------------------------
;��⠥� ᨬ��� ��६����� ࠧ�來��� �� �室���� ��⮪�
;-----------------------------------------------------------------------------
Get_Sym         proc near                                 ;
                movzx   eax, [ebp+VarFrame.vf_BitSize]    ;
                add     eax, dword ptr [ebp+VarFrame.vf_InBufRelPos]
                xchg    eax, dword ptr [ebp+VarFrame.vf_InBufRelPos]
                mov     ecx, 8                            ;
                sub     edx, edx                          ;
                div     ecx                               ; /8 (bits per byte)
                add     eax, [ebp+VarFrame.vf_InBuf]      ;
                xchg    eax, esi                          ;
                lodsw                                     ;����㦠�� 3 ����
                movzx   ebx, ax                           ;
                lodsb                                     ;
                movzx   ecx, dx                           ;
                jcxz    getsym_exit                       ;
                                                          ;�롨ࠥ� �, �� �㦭�
select_bits:                                              ;
                shr     al, 1                             ;
                rcr     bx, 1                             ;
                loop    select_bits                       ;
                                                          ;
getsym_exit:                                              ;
                movzx   eax, bx                           ;
                movzx   ebx, [ebp+VarFrame.vf_BitSize]    ;
                                                          ;
;------------>replaced<---------------------------------  ;
;                sub     ebx, 9                           ;
;                and     ax, [ebp+ebx*2+VarFrame.vf_Const01FF]
                                                          ;
                mov     cl, bl                            ;
                xor     ebx, ebx                          ;
                inc     ebx                               ;
                shl     bx, cl                            ;
                dec     bx                                ;
                and     ax, bx                            ;
                                                          ;
;------------>end<--------------------------------------  ;
                                                          ;
                retn                                      ;
Get_Sym         endp                                      ;
                                                          ;
;-----------------------------------------------------------------------------
;��२��樠����஢��� ᫮����
;-----------------------------------------------------------------------------
lzd_init        proc near                                 ;
                mov     [ebp+VarFrame.vf_BitSize], 9      ;����來����
                mov     [ebp+VarFrame.vf_DictSize], 200h  ;������ ᫮����
                mov     [ebp+VarFrame.vf_FreeSym], 102h   ;���� ᢮����� ᨬ���
                retn                                      ;
lzd_init        endp                                      ;
                                                          ;
;-----------------------------------------------------------------------------
;���࠭�� �㪢� � ��室��� ��⮪.
;-----------------------------------------------------------------------------
Save_Char       proc near                                 ;
                mov     edi, [ebp+VarFrame.vf_OutBufPos]  ;
                add     edi, [ebp+VarFrame.vf_OutBuf]     ;
                stosb                                     ;
                inc     [ebp+VarFrame.vf_OutBufPos]       ;
                retn                                      ;
Save_Char       endp                                      ;
                                                          ;
;-----------------------------------------------------------------------------
;�ய��뢠�� �裡 � ᫮����
;-----------------------------------------------------------------------------
Add_Chain       proc near                                 ;
                movzx   ebx, [ebp+VarFrame.vf_FreeSym]    ;
                call    _Calc_Sym_Pos                     ;
                movzx   eax, [ebp+VarFrame.vf_CharToLink] ;
                mov     [ebx+2], al                       ;
                movzx   eax, [ebp+VarFrame.vf_Sym2]       ;
                mov     [ebx], ax                         ;
                inc     [ebp+VarFrame.vf_FreeSym]         ;
                retn                                      ;
Add_Chain       endp                                      ;
                                                          ;