;MmM (RIORITA, SLOW VERSION ) + MARSH
;
;
;?????????????????????????????????????????????????????????????????????????????
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;
;������ �� �� ��મ�-�०�મ� ��� 1994 ����, ����� �� ��梥� ���, � �� �-
;�������� ��।����� 祬������ ��� �� ��⡮�� ???
;� � ��� � ����஢�� ����� ����� (⠬ � ���� ���� ⥫������) � ���� ����⨭-
;᪠� (⠬ ��室���� ��᫮���� ���蠢��,26)
;� � ��� � ��ᥫ ��� � ����� ��� ��ᥫ� ��⨢稪, ����� �࠭᫨஢��� �� 
;⥫������� ������ ���� ��, 祬 ᠬ 祬������...
;
;
;
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;?????????????????????????????????????????????????????????????????????????????
;Copyright GURRE 1993-1996
;                       *** "Riorita" ***
;This programm dedicated to Samuil Gondonowitch Mavrodi-president "MMM" ltd.
;
;****************************************************************************
;This message (c)Copyright 1996 by Y&Y Corporation
;��᫥����⥫�᪨� 業�� ����室���� �ணࠬ����� ���ᯥ祭�� ����� "�笥����� �����"
;
;         Lurische Abweisung... (����᪮� ����㯫����)
;���--� ���--� ��諨       � � � � � � � � �  ! ! !
;������ �� ��஢��� - � �㤥� �� � ���浪� ! 
;
;
;����⭮,������ �� ��� �⥫� �� ����� ᢮� ����� ��ᥫ�� ���窮� ?
;NO PROBLEM !!! 
;���� ����� ��� ������� - � ���। !
;�����ࠫ� �����,����ᠫ� ��⪨ - � ����� �� ����� ���� 
;
;������⭮ ? �� �� �稫��� � ��몠���� 誮��� (� ��. �� ���� � BEER(a) )
;Nicht's zu machen !     aber...   (��祣� �� ���������,��...)
;�७ � ���� - ࠧ�蠥� �ᯮ�짮���� ���� �����;
;� �㤥� �� ���㯠�� ��廊�� � ࠧ������... 
;� �᫨ � �� ࠧ������ - �� ��ࠡ��� : �� �� �� �.� ᤥ���� -
;����� �� ��� 
;C 㢠������ Gurre & Beer  
;
;End of message
;*********************************************************************

 PAUS = 1
 END_MUSIC = 0

.model small
.8086
.code
int_1C_handler:

mov bx,cs:counter            
shl bx,1
mov ax,cs:[bx][offset mus]
cmp ax,END_MUSIC
jne continue
mov cs:counter,0FFFFh
iret
continue: 
cmp ax,PAUS
jne not_pause
in al,97
and al,0FCh
out 97,al			;Speaker off
jmp return
not_pause:
 out 66,al
 mov al,ah
 out 66,al
 in al,97
 or al,3
 out 97,al
return:
 inc cs:counter
 iret

 start:
mov ax,351Ch			;Get 1C vect
int 21h
mov cs:old1c,bx
mov ax,es
mov cs:old1ch,ax		;Save 1C vector
push cs
pop ds
mov dx,offset int_1C_handler
mov ax,251ch			;Set vect
int 21h
wait_for: cmp cs:counter,0FFFFh
jne wait_for
in al,97
and al,11111100b
out 97,al			;Speaker off
lds dx,dword ptr cs:old1c
mov ax,251ch
int 21h				;Restore 1C vector
mov ax,4C00h
int 21h				;Terminate

EVEN
;************************ ���ம�।������ ��� (��砫�)******************************
A = 5422  ;�� 
B = 5117  ;��#
H = 4830  ;��
;
C = 4559  ;��
CIS = 4303;��#
D = 4061  ;��
DIS = 3833;��#
E = 3619  ;��
F = 3416  ;��
FIS = 3224;��#
G = 3042  ;����
GIS = 2872;����#
A2 = 2711 ;��
B2 = 2559 ;��#
H2 = 2415 ;��
;
C2 = C/2 ;��
CIS2 = CIS/2 ;��# 
D2= D/2   ;�� (2) 
P = PAUS  ;�����
DIS2=DIS/2
E2 = E/2 ;��
F2 = F/2 
FIS2 = FIS/2 
;************************ ���ம�।������ ��� (�����)******************************
mus:
;                                 ***   MARSH  *** (�� ����䨫쬠 "����᭮� ��ப")
;
;              �� ������ �� ��� ��⡮�: 
;
;
DW D,D,D,D,D,D,D,D,D, P,P, G,G,G,G,G,G, P,P, G,G,G,G, P,G,G,G,G, P, G,G,G,G ;�� ���� ���� ���� ����
DW FIS,FIS,FIS,FIS,FIS,  G,G,G,G,G,  A2,A2,A2,A2,A2, H2,H2,H2,H2,H2,H2,H2,H2,H2,H2,H2,H2 ;��# ���� �� ��
DW A2,A2,A2,A2,A2, P, G,G,G,G,G,G,G, P,P, D,D,D,D,D,D,D,D,D,D, P ;�� ���� �� 
DW H2,H2,H2,H2,H2,H2, P,P, H2,H2,H2,H2, P, H2,H2,H2,H2, P, H2,H2,H2,H2, P; �� �� �� ��
DW A2,A2,A2,A2,A2, H2,H2,H2,H2,H2, C2,C2,C2,C2,C2, A2,A2,A2,A2,A2,A2,A2 ; �� �� �� ��
DW P,P
DW D2,D2,D2,D2, P,P, D2,D2,D2,D2, P,P,P, D2,D2,D2,D2,D2,D2,D2,D2, P,P ;�� �� ��
DW FIS2,FIS2,FIS2,FIS2,FIS2,FIS2,FIS2,FIS2, P, E2,E2,E2,E2, P, D2,D2,D2,D2,D2, P,P ; �� �� ��
DW E2,E2,E2,E2,E2,E2, P, D2,D2,D2,D2,D2,D2,D2,D2, P,P, C2,C2,C2,C2, P, H2,H2,H2,H2,H2 ; �� �� �� ��
DW P,P 

;                            *** RIORITA ***

DW D,D,D,D,D,D,D,D,D,D,D,D, P,P, H2,H2,H2,H2,H2,H2,H2,H2,H2,H2,H2,H2,H2,H2,H2, P,P ;�� ��
DW A2,A2,A2,A2,A2,A2,    H2,H2,H2,H2,H2,H2 ;�� ��
DW A2,A2,A2,A2,A2,A2,     G,G,G,G,G,G,G,G,G,G,G,G, P,P,P,P,P ;�� ����

DW D,D,D,D,D,D,     G,G,G,G,G,G, A2,A2,A2,A2,A2 ;�� ���� ��
DW H2,H2,H2,H2,H2, P, H2,H2,H2,H2,H2, P, H2,H2,H2,H2,H2 ;�� �� ��
DW C2,C2,C2, H2,H2,H2, A2,A2,A2,A2,A2, H2,H2,H2,H2,H2 ;�� �� �� ��
DW C2,C2,C2,C2,C2,C2, D2,D2,D2,D2,D2,D2, P,P,P,P,P,P,P,P  ;�� ��(2) 

DW D,D,D,D,D,D,D,D,D,D,D,D, P,P, A2,A2,A2,A2,A2,A2,A2,A2,A2,A2,A2,A2,A2,A2,A2, P,P ; �� ��  
DW G,G,G,G,G,G, A2,A2,A2,A2,A2,A2 ;���� �� 
DW G,G,G,G,G,G, FIS,FIS,FIS,FIS,FIS,FIS,FIS,FIS,FIS,FIS,FIS,FIS, P,P,P,P,P ;���� ��# 

DW D,D,D,D,D,D,   FIS,FIS,FIS,FIS,FIS,FIS, A2,A2,A2,A2,A2,A2 ; �� ��# ��
DW C2,C2,C2,C2,C2, P, C2,C2,C2,C2,C2, P, C2,C2,C2,C2,C2 ;�� �� ��
DW D2,D2,D2, C2,C2,C2, H2,H2,H2,H2,H2,H2, C2,C2,C2,C2,C2,C2 ;�� �� �� �� 
DW D2,D2,D2,D2,D2,D2,D2,D2,D2,D2,D2,D2,D2,D2,D2, P,P,P,P,P,P,P,P ;��

DW D2,D2,D2,D2,D2,D2,D2,D2, DIS2,DIS2,DIS2,DIS2,DIS2,DIS2,DIS2,DIS2 ;��(2) ��#(2) 
DW F2,F2,F2,F2,F2,F2,F2,F2,F2,F2,F2,F2,F2,F2,F2, P,P,P ; ��(2)
DW DIS2,DIS2,DIS2,DIS2,DIS2,DIS2, P,P, D2,D2,D2,D2,D2,D2,D2,D2, C2,C2,C2,C2,C2,C2,C2,C2 ;��#(2) ��(2) ��(2)   
DW P,P,P,P,P,P,P,P

DW A2,A2,A2,A2,A2,A2,A2,A2, B2,B2,B2,B2,B2,B2,B2,B2 ;�� ��#
DW C2,C2,C2,C2,C2,C2,C2,C2,C2,C2,C2,C2,C2,C2,C2, P,P,P ;��
DW DIS2,DIS2,DIS2,DIS2,DIS2,DIS2, D2,D2,D2,D2,D2,D2, C2,C2,C2,C2,C2,C2, H2,H2,H2,H2,H2,H2 ;��# �� �� ��
DW P,P,P,P,P,P,P,P,P,P,P

DW D,D,D,D,D,D,D,D,D,D,D,D, P,P, H2,H2,H2,H2,H2,H2,H2,H2,H2,H2,H2,H2,H2,H2,H2, P,P ;�� ��
DW A2,A2,A2,A2,A2,A2,    H2,H2,H2,H2,H2,H2 ;�� ��
DW A2,A2,A2,A2,A2,A2,     G,G,G,G,G,G,G,G,G,G,G,G, P,P,P,P,P ;�� ����

DW D,D,D,D,D,D,     G,G,G,G,G,G, A2,A2,A2,A2,A2 ;�� ���� ��
DW H2,H2,H2,H2,H2, D2,D2,D2,D2,D2,D2, C2,C2,C2,C2,C2,C2 ;�� �� ��
DW D2,D2,D2, C2,C2,C2 ;�� ��
DW H2,H2,H2,H2,H2, A2,A2,A2,A2,A2,A2, G,G,G,G,G,G  ;�� �� ����
;
;
;                            AO MMM !
;
;
DW PAUS,END_MUSIC

old1c	dw 00
old1ch	dw 00
counter dw 00


.stack
end start
