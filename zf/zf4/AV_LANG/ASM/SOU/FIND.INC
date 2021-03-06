;INTERFACE
;ScanDir proc near
;Recurse proc near

;IMPLEMENTATION
; (c) Alexander Zigar' FidoNet: 2:5058/56.8
;**************************************************************************
ScanDir proc near
        mov ah,19h
        int 21h
        mov ah,0Eh
        push ax
        mov dl,dsk
        int 21h
        mov ah,47h
        cwd
        lea si,oldpath
        push si
        int 21h
        lea dx,startpath ;pth
        call Recurse
        pop dx
        mov ah,3Bh
        int 21h
        pop ax
        mov dl,al
        int 21h
        retn
ScanDir endp
;**************************************************************************
Recurse proc near
        mov ah,3Bh      ; ���室�� � ���� ��⠫��
        int 21h
        sub sp,44       ; ᮧ���� �������� DTA
        mov dx,sp       ; �ᥣ� ����� ���� �� ����� 31 �����⠫��� => �ᥣ�
        mov si,dx       ; ����� ���ॡ������� (44+4)*31=1488 ���� �⥪�
        add si,1Eh      ; �� ⠪ � � �����
        mov ah,1Ah
        int 21h
        inc AllPathFound
        lea dx,msk      ; ���� 䠩���
        xor cx,cx
        mov ah,4Eh
        int 21h
        jc @1
@2:     call DetectFile ;PrintName  ; ��諨!
        mov ah,4Fh
        int 21h
        jnc @2
@1:
        mov cx,16       ; ���� ��� ��⠫����
        lea dx,all
        mov ah,4Eh
        int 21h
        jc @3
@5:
        test byte ptr [si-9],16 ; ������ ms-dos ����� � ��⠫����� �뤠��
                                ; � 䠩�� - �㤥� ��ᥪ���
        jz @4
        cmp word ptr [si],'.'           ; ��୥��� ��४���
        jz @4
        cmp word ptr [si],'..'          ; �����⠫��
        jz @4

        push si
        mov dx,si
        call Recurse    ; ४��ᨢ�� �맮�
        lea dx,old      ; �뮤�� �� �����⠫���
        mov ah,3Bh
        int 21h
        pop si
        lea dx,[si-1Eh] ; �����砥� ����� dta
        mov ah,1Ah
        int 21h
@4:
        mov ah,4Fh
        int 21h
        jnc @5
@3:
        add sp,44       ; 㤠��塞 �������� dta
        retn
Recurse endp
;**************************************************************************
