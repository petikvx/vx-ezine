;Program by CyberShadow...
;creating date 01:08:97 
;My Copyright
;Private use only...
;This stupid program was made for fun only, remake from my virus 'Example'

;������ �孮����� ����� ��୮� �ਬ������, ����� �ணࠬ��� �த�� ⮬�
;���⢥ত����.


.model tiny
.code
.286
	org 100h
Start:
        mov bl,ds:[80h]
        or  bx,bx
        je  nkm1
        mov byte ptr [bx+81h],0
        mov dx,82h
        sub CX,CX                    ;� ��諨 ��p��� ��� 䠩��.
        mov AH,4eh                   ;�
        int 21h                      ;�
Next:
        mov cx,ds:[9ah]  	     ;� ����� ����� 61000 ����
	mov bp,cx
	cmp ch,0eeh                  ;60928..61183
        ja exit                      ;� ��-�뢠��������
        mov DX,80h+1eh               ;�
        mov AX,3d02h                 ;� ��p뫨 䠩�.
        ja exit
        int 21h                      ;�
        jc exit                      ;�
        mov BX,AX                    ;�
        mov DX,offset finish
	mov si,dx
        mov AH,3fh
        int 21h
        or  ax,ax
nkm1:
        je close_file
        cmp word ptr ds:[si],'P;'    ;� �஢�ਬ�� �� ������
        je close_file                ;� ��-�뢠��������
        mov ax,5700h                 ;�
        int 21h                      ;� ��࠭��� �६� � ���� 䠩��
        push dx                      ;�
        push cx                      ;�
        mov cx,dx
	mov di,offset date
	mov ax,3030h
	stosw
	stosw
	stosw
	stosw
        sub di,7
	mov al,cl
	and al,31
	call prt_al
	mov al,'.'
	stosb
	inc di
	shr cx,5
	mov al,cl
	and al,15
	call prt_al
	mov al,'.'
	stosb
	inc di
	shr cx,4
	mov al,cl
	add al,80
	call prt_al
        xor cx,cx
        xor dx,dx
        mov ax,4200h
        int 21h
        mov DX,offset copyr
	mov cx,bp
        add CX,offset finish-offset copyr
        mov AH,40h
        int 21h
        pop cx                       ;� ����⠭����� �६� � ����
        pop dx                       ;�
        mov ax,5701h                 ;�
        int 21h                      ;�
close_file:
        mov AH,3eh                   ;� ���p뫨 䠩�
        int 21h                      ;�
        mov AH,4fh                   ;�
        int 21h                      ;� ᫥���騩 䠩�
        jc exit                      ;�
	jmp next
exit:
	ret
prt_al:
        push di
      	xor ah,ah
      	mov si,10
cont_div:
      	xor dx,dx
      	div si
      	add dl,'0'
      	mov [di],dl
      	dec di
      	or  ax,ax
      	jne cont_div
      	pop di
        inc di
      	ret

copyr		db ';Program by CyberShadow...',0dh,0ah
		db ';creating date '
date		db '        '
		db 0dh,0ah
finish:
end start
