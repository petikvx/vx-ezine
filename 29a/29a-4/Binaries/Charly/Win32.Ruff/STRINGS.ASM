;-----------------------------------------------------------
; StrCompare Сравнить две строки
;-----------------------------------------------------------
; Вход:
;       si = адрес строки 1 (s1)
;       di = адрес строки 2 (s2)
; Выход:
;       набор флагов для условных переходов jb, jbe,
;       je, ja, jae, or
; Регистры:
;       не используются
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
; StrPos Найти вхождение в строку подстроки
;-----------------------------------------------------------
; Вход:
;       si = адрес искомой подстроки
;       di = адрес проверяемой целевой строки
; Выход:
;       Если zf = 1, тогда dx = индекс подстроки
;       Если zf = 0, тогда подстрока не найдена
; Замечание: если zf = 0, то значение в dx не имеет никакого смысла
; Регистры:
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
; StrLength Подсчитать в строке количество ненулевых символов
;-----------------------------------------------------------
; Вход:
;       di = адрес строки (s)
; Выход:
;       cx = количество ненулевых символов в s
; Регистры:
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
