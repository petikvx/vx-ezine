;-----------------------------------------------------------
; StrCompare �ࠢ���� ��� ��ப�
;-----------------------------------------------------------
; �室:
;       si = ���� ��ப� 1 (s1)
;       di = ���� ��ப� 2 (s2)
; ��室:
;       ����� 䫠��� ��� �᫮���� ���室�� jb, jbe,
;       je, ja, jae, or
; ��������:
;       �� �ᯮ�������
;-----------------------------------------------------------
StrCompare     PROC

        push    eax
        push    edi
        push    esi

        cld
@@10:
        lodsb
        scasb
        jne     @@20
        or      al, al
        jne     @@10
@@20:
        pop     esi
        pop     edi
        pop     eax
        ret
ENDP StrCompare
;-----------------------------------------------------------
; StrPos ���� �宦����� � ��ப� �����ப�
;-----------------------------------------------------------
; �室:
;       si = ���� �᪮��� �����ப�
;       di = ���� �஢��塞�� 楫���� ��ப�
; ��室:
;       �᫨ zf = 1, ⮣�� dx = ������ �����ப�
;       �᫨ zf = 0, ⮣�� �����ப� �� �������
; ����砭��: �᫨ zf = 0, � ���祭�� � dx �� ����� �������� ��᫠
; ��������:
;       dx
;-----------------------------------------------------------
ASCNull EQU     0
StrPos    PROC
        push    eax
        push    ebx
        push    ecx
        push    edi

        call    StrLength
        mov     eax, ecx
        xchg    esi, edi
        call    StrLength
        mov     ebx, ecx
        xchg    esi, edi
        sub     eax,ebx
        jb      __20
        mov     edx, 0FFFFFFFFh
__10:
        inc     edx
        mov     cl, byte ptr [ebx + edi]
        mov   byte ptr  [ ebx + edi], ASCNull
        call    StrCompare
        mov   byte ptr [ebx + edi], cl
        je      __20
        inc     edi
        cmp     edx, eax
        jne     __10
        xor     ecx, ecx
        inc     ecx
__20:
        pop     edi
        pop     ecx
        pop     ebx
        pop     eax
        ret
ENDP    StrPos

;-----------------------------------------------------------
; StrLength �������� � ��ப� ������⢮ ���㫥��� ᨬ�����
;-----------------------------------------------------------
; �室:
;       di = ���� ��ப� (s)
; ��室:
;       cx = ������⢮ ���㫥��� ᨬ����� � s
; ��������:
;       cx
;-----------------------------------------------------------
StrLength PROC
        push    eax
        push    edi

        xor     al, al
        mov     ecx, 0FFFFFFFFh
        cld
        repnz   scasb
        not     ecx
        dec     ecx

        pop     edi
        pop     eax
        ret
ENDP StrLength
