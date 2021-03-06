;
;=============================================================================
;LZ32Compression subroutines.
;All rights may be reserved by SexyDufus
;Disassembled by IDA v3.xx with little help of Green Monster ;-)
;==============================================================================
;
;Interface:
;int   lz_compresss(char *inbuf, char *outbuf, int size, char *buf)
;
;-----------------------------------------------------------------------------
;������� size ���⮢ �� inbuf, �����뢠� ����祭��� � outbuf.
;��� ᫮���� �ᯮ������ ���譨� ����� (buf)
;�����頥� ࠧ��� ᦠ⮣�.
;=============================================================================
;

;������⪨:
;char   = �㪢� = ���� = �, �� ��㧨��� �� inbuf
;symbol = ᨬ��� = ��६����� ������⢮ ��� (9-12), ������ � outbuf

include lzcd.asi



;---------------------------------------------------
;������ �������� ��६����� (���� �� �� �㭪樨)

ProcFrame       struc                      ;
FirstSym        dw ?                       ;���� ᨬ���
Link            dw ?                       ;��離�
DictBound       dw ?                       ;������ �࠭�� ᫮����
BitsPerSym      dw ?                       ;��⮢�� ࠧ��୮��� �뢮��
                                           ;(㢥��稢����� �� ��� ����������
                                           ; ᫮����)
NextInChar      db ?                       ;�������� �㪢� � ��⮪� �����
field_9         db ?                       ;  �����
field_A         db ?                       ;  �� ����
field_B         db ?                       ;  �����
                                           ;�뢮�: NextChar �� DWORD'�� ;-)
                                           ;
OutBufPos       dd ?                       ;������ ������ �뢮��
InBufRelPos     dd ?                       ;������ ������ �����
RetEIP          dd ?                       ;���� ������ lz_compress
                                           ;
                                           ;��㬥���:
InBuf           dd ?                       ;�室��� �����
OutBuf          dd ?                       ;��室��� �����
SuxxSize        dd ?                       ;������ ������ �� �室��� �����
Malloced        dd ?                       ;��᮪ ����� ��� ᫮����
ProcFrame       ends                       ;
                                           ;
;-------------------------------------------
;������� ᫮��୮� �����                ;
;                                          ;
TableItem       struc                      ;
Sym             dw ?                       ;������
NextSym         dw ?                       ;������騩 ᨬ���
NextChar        db ?                       ;�������� �㪢� � 楯�窥
TableItem       ends                       ;
                                           ;
;=============================================================================
; �᭮���� �㭪��
;=============================================================================
lz_compress     proc near                  ;
                sub     eax, eax           ;
                push    eax                ;��������� ���� ��������
                push    eax                ;
                push    eax                ;
                push    eax                ;
                push    eax                ;
                mov     ebp, esp           ;EBP -> ProcFrame
                                           ;
                call    lz_init            ;���� ᫮����
;                                          ;
                sub     eax, eax           ;
                inc     ah                 ;������ 100h = "����� ᫮����"
                call    Save_And_Step      ;�뢥�� � ��室��� ��⮪
                                           ;
                call    Get_Byte           ;������� ���� ����.
                                           ;
@@compess_cycle:                           ;AL = �㪢�
                sub     ah, ah             ;
                                           ;AX = ᨬ���
@@get_chain:                               ;�饬 㭨������ 楯��� �㪢
                mov     [ebp+ProcFrame.FirstSym], ax
                call    Get_Byte           ;
                jb      short lzc_exit     ;
                                           ;
                mov     [ebp+ProcFrame.NextInChar], al
                movzx   ebx, [ebp+ProcFrame.FirstSym]
                call    Search_Table       ;
                jnb     short @@get_chain  ;
                                           ;����窠 �������
                call    Set_Char_Link      ;
                                           ;�뢮��� ᨬ���
                push    ebx                ;
                movzx   eax, [ebp+ProcFrame.FirstSym]
                call    Save_And_Step      ;
                pop     ebx                ;
                mov     al, [ebp+ProcFrame.NextInChar]
                cmp     bx, [ebp+ProcFrame.DictBound]
                jl      short @@compess_cycle
                                           ;
;--------->replaced<------------------------
;                cmp     [ebp+ProcFrame.BitsPerSym], 0Ch
                cmp     [ebp+ProcFrame.BitsPerSym], MAX_BITS  ;�।�� ࠧ�來���?
;--------->end<-----------------------------
                jl      short next_bit     ;
                                           ;
                sub     eax, eax           ;
                inc     ah                 ; 100h - ��२��樠����஢��� ᫮����
                call    Save_And_Step      ;
                call    lz_init            ; � ᠬ� ��२��樠�����㥬
                mov     al, [ebp+ProcFrame.NextInChar]
                jmp     short @@compess_cycle
; ���������������������������������������������������������������������������
                                           ;
next_bit:                                  ;
                inc     [ebp+ProcFrame.BitsPerSym]   ;�����稢��� ࠧ�來����
                shl     [ebp+ProcFrame.DictBound], 1 ;�����稢��� ᫮����
                jmp     short @@compess_cycle
; ���������������������������������������������������������������������������
                                           ;
lzc_exit:                                  ;
                movzx   eax, [ebp+ProcFrame.FirstSym]
                call    Save_And_Step      ;
                mov     eax, 101h          ; 101h - ������ 楯�窨
                call    Save_And_Step      ;
                xchg    eax, edi           ;
                sub     eax, [ebp+ProcFrame.OutBuf]  ;EAX = end-start = size
                add     esp, 14h           ;
                retn    10h                ;
lz_compress     endp                       ;
                                           ;
;-----------------------------------------------------------------------------
;��२��樠������� ᫮����
;-----------------------------------------------------------------------------
lz_init         proc near                  ;
                pusha                      ;
                mov     [ebp+ProcFrame.BitsPerSym], 9     ;9 ��� �� ᨬ��� �뢮��
                mov     [ebp+ProcFrame.DictBound], 200h   ;512 ᨬ����� ᫮����
                sub     eax, eax           ;
                dec     eax                ;
                                           ;���⪠ ᫮����
;------>replaced<------                    ;
;                mov     ecx, 280h         ; � �ਣ����� ��祬�-� ⠪...
                mov     ecx, COMPR_BUFFER_SIZE/2  ;� ������ - ⠪.
;------>end<-----------                    ;
                                           ;
                mov     edi, [ebp+ProcFrame.Malloced]
                repe stosw                 ;STOSW - �� ����� ���� ;-)
                                           ;
                mov     [ebp+ProcFrame.Link], 102h ;���� ᢮����� ᨬ���
                                           ;
                                           ;(00-FF) - ����� ᨬ����-�㪢�
                                           ;          (��������� ᫮����)
                                           ; 100    - ᨬ��� ��� ᫮����
                                           ; 101    - ����� ������
                                           ;102-... - ᢮����� ᨬ����
                                           ;
                popa                       ;
                retn                       ;
lz_init         endp                       ;
                                           ;
;------------------------------------------------------------------------------------
;�����뢠�� ᨬ��� ������� ࠧ�來��� (9-...���) � ��室��� ��⮪ �� EAX
;------------------------------------------------------------------------------------
Save_And_Step   proc near                  ;
                push    eax                ;
                mov     eax, [ebp+ProcFrame.OutBufPos] ;EAX -> ��� � ��室��� �����
                movzx   ecx, word ptr [ebp.ProcFrame.BitsPerSym] ;ECX = ࠧ�來����
                add     [ebp+ProcFrame.OutBufPos], ecx ;Step
                                           ;��⠥� ����� ���
                mov     ecx, 8             ;
                sub     edx, edx           ;
                div     ecx                ; EDX = OutBufPos mod 8
                add     eax, [ebp+ProcFrame.OutBuf]
                xchg    eax, edi           ;EDI -> �㤠 �����
                pop     eax                ;
                                           ;
                mov     ecx, edx           ;
                sub     edx, edx           ;
                jcxz    save_3bytes        ;���室, �᫨ ஢�� �� �࠭�� ���
                                           ;
                shl     eax, cl            ;
                or      al, [edi]          ;
                                           ;
save_3bytes:                               ;
                stosw                      ;
                shr     eax, 10h           ;
                stosb                      ;
                retn                       ;
Save_And_Step   endp                       ;
                                           ;
;-----------------------------------------------------------------------------
;��⠥� �㪢� �� �室���� ��⮪� � AL.
;-----------------------------------------------------------------------------
Get_Byte        proc near                  ;
                mov     esi, [ebp+ProcFrame.InBuf]       ; ESI -> InBuf
                mov     edi, [ebp+ProcFrame.InBufRelPos] ; EDI -> RelInBufPos
                cmp     edi, [ebp+ProcFrame.SuxxSize]    ; ��� ���稫���?
                jnb     short byaka                      ;
;                                                        ;
                mov     al, [esi+edi]                    ;��⠥�
                inc     [ebp+ProcFrame.InBufRelPos]      ;
                clc                                      ;
                retn                                     ;
    byaka:                                               ;
                stc                                      ;
                retn                                     ;
Get_Byte        endp                                     ;
                                                         ;
;-----------------------------------------------------------------------------
;���� �� ᫮����
;-----------------------------------------------------------------------------
Search_Table    proc near
                call    Calc_Sym_Pos                ;ESI -> TableItem
                sub     edi, edi                    ;EDI=0=䫠� success'�
                cmp     [esi+TableItem.Sym], 0FFFFh ;��� ᨬ���?
                jz      short not_found             ;
                                                    ;
                inc     edi                         ;������ 䫠�
                movzx   ebx, [esi+TableItem.Sym]    ;EBX=ᨬ���
                                                    ;
scan_chain:                                         ;
                call    Calc_Sym_Pos                ;
                cmp     [esi+TableItem.NextChar], al  ;���� ���?
                jnz     short next_char             ;
                                                    ;
                clc                                 ;��� ����?
                movzx   eax, bx                     ;EAX=ᨬ��� 楯�窨
                retn                                ;
; ���������������������������������������������������������������������������
                                                    ;
next_char:                                          ;
                cmp     [esi+TableItem.NextSym], 0FFFFh  ;������ 楯�窨?
                jz      short not_found             ;
                movzx   ebx, [esi+TableItem.NextSym] ;EBX=᫥���騩 ᨬ���
                jmp     short scan_chain            ;
; ���������������������������������������������������������������������������
                                                    ;
not_found:                                          ;
                stc                                 ;��� ⠪�� 楯�窨
                retn                                ;
Search_Table    endp                                ;
                                                    ;
;-----------------------------------------------------------------------------
;�����뢠�� ���� TableItem � ᫮��� �� ᨬ���� � EBX
;-----------------------------------------------------------------------------
Calc_Sym_Pos    proc near                           ;
                lea     esi, [ebx+ebx*4]            ; ESI = EBX*sizeof(TableItem)
                add     esi, [ebp+ProcFrame.Malloced] ;ESI += ᬥ�. ����
                retn                                ;
Calc_Sym_Pos    endp                                ;
                                                    ;
;-----------------------------------------------------------------------------
;��離� �㪢� � ᨬ���� � ᫮���
;-----------------------------------------------------------------------------
Set_Char_Link   proc near                           ;
                movzx   ebx, [ebp+ProcFrame.Link]   ;
                cmp     edi, 0                      ; EDI=Search_Table status
                jz      short set_link              ;
                mov     [esi.TableItem.NextSym], bx ;
                jmp     short test_sym              ;
; ���������������������������������������������������������������������������
                                                    ;
set_link:                                           ;
                mov     [esi.TableItem.Sym], bx     ;�ய��뢠���� ᨬ���
                                                    ;
test_sym:                                           ;
;------>replaced<------                             ;
;               cmp     bx, 1000h                   ;
                cmp     bx, BITS_DEPENDED_BUFF_SIZE ;��᫥���� ᨬ��� � ᫮���?
;------>end<-----------                             ;
                jz      short scl_exit              ;
                                                    ;
                call    Calc_Sym_Pos                ; ������ FFFF'���
                mov     word ptr [esi.TableItem.Sym], 0FFFFh
                mov     word ptr [esi.TableItem.NextSym], 0FFFFh
                mov     [esi.TableItem.NextChar], al
                inc     [ebp+ProcFrame.Link]        ;
                                                    ;
scl_exit:                                           ;
                retn                                ;
Set_Char_Link   endp                                ;
                                                    ;