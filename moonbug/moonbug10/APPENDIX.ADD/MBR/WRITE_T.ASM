;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;Copyright (c) 96-1998 Black Harmer
;Version 1.0
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;CALLNAME: WRITE_T
;TYPE: TINY(COM)
;Processor: 80286
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;귛��: DS:DX - 묅p�첓 � 召ζ쯄レ��� 兒p쵟收.
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;귣若�:
;H� 咨p젺� 飡p�첓, 췅�ⓤ젺췅� � 收ゃ耀� ��㎤與� ゃp貰p� �
;� 歟β졾.
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;렞ⓤ젺��:
;� DS:DX 飡p�첓 � 笹ⅳ莘耀� 兒p쵟收:
;01h,"묅p�첓 Ħβ 誠α�",'$'
; � ��pÆ呻 歟β� (첓え� 歟β�� �獸죖젲졻� 飡p�ゃ)
;                        � 묅p�첓 ㄾウ췅 쭬첓�葉쥯筍碎 歲Б�ギ� '$',
;                          첓� DOS 押�ゆ⑨ 09h.
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
write_t:
        pusha
        push     ds es
        push     ds
        pop      es
        mov      bp,dx
        inc      bp
        mov      ah,03h
        xor      bh,bh
        int      10h
        mov      ax,1301h
        call     tmp232230_call
        mov      bl,byte ptr es:[bp-1]
        int      10h
        mov      ax,0920h
        mov      bx,0007h
        mov      cx,1h
        int      10h
        jmp  L232933
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
tmp232230_call:
        push     di
        xor      cx,cx
        mov      di,bp
L232336:
        cmp      byte ptr [di],24h
        jz       L232320
        inc      cx
        inc      di
        jmp      L232336
L232320:
        pop      di
        retn
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
L232933:
        pop      es ds
        popa
        retn
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
