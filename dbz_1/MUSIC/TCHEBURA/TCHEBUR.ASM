;Copyright GURRE 09 April 1996
;                       *** "Tcheburatchka" ***
;This message (c)Copyright 1996 by Y&Y Corporation
;��᫥����⥫�᪨� 業�� ����室���� �ணࠬ����� 
;     ���ᯥ祭�� ����� "�笥����� �����"
;

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
continue: cmp ax,PAUS
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
C2 = 2279 ;��
CIS2 = 2151;��# 
D2=2030   ;�� (2) 
P = PAUS  ;�����
DIS2=DIS/2;��#
E2 = E/2 ;��
F2 = F/2 ;��
FIS2 = FIS/2 ;��#
;************************ ���ம�।������ ��� (�����)******************************
mus:
;     ��ᥭ�� �� ���㡮� ����� (BLUE ?????????) �� ����䨫쬠 "�����誠"                            
;
;
;
; �������� ࠪ��� 㫥��� �����
DW A2,A2,A2,A2,A2,A2,A2, P, D2,D2,D2,D2,D2,D2,D2, P, CIS2,CIS2,CIS2,CIS2,CIS2,CIS2,CIS2, P
DW D2,D2,D2,D2,D2,D2,D2, P, E2,E2,E2,E2,E2,E2,E2, P, D2,D2,D2,D2,D2,D2, P
DW C2,C2,C2,C2,C2,C2,C2, P, D2,D2,D2,D2,D2,D2, P, C2,C2,C2,C2,C2,C2,C2,C2,C2,C2, P,P,P
DW B2,B2,B2,B2,B2,B2,B2,B2,B2,B2,B2,B2, P,P,P, B2,B2,B2,B2,B2,B2,B2,B2,B2,B2,B2,B2, P,P,P
;
;����� � ���� �� 㦥 �� ���...
DW G,G,G,G,G,G,G, P, C2,C2,C2,C2,C2,C2,C2, P, H2,H2,H2,H2,H2,H2,H2, P, C2,C2,C2,C2,C2,C2,C2, P
DW D2,D2,D2,D2,D2,D2,D2, P, C2,C2,C2,C2,C2,C2,C2, P, G,G,G,G,G,G,G, P, B2,B2,B2,B2,B2,B2,B2, P
DW A2,A2,A2,A2,A2,A2,A2,A2,A2,A2,A2,A2,A2,A2,A2, P,P,P
;
;� ��� ������� ������� ����
DW A2,A2,A2,A2,A2,A2,A2, P, D2,D2,D2,D2,D2,D2,D2, P, CIS2,CIS2,CIS2,CIS2,CIS2,CIS2,CIS2, P
DW D2,D2,D2,D2,D2,D2,D2, P, E2,E2,E2,E2,E2,E2,E2, P, D2,D2,D2,D2,D2,D2, P
DW C2,C2,C2,C2,C2,C2,C2, P, B2,B2,B2,B2,B2,B2,B2, P, A2,A2,A2,A2,A2,A2,A2,A2,A2,A2,A2,A2,A2,A2,A2, P,P
DW G,G,G,G,G,G,G,G,G,G,G,G, P,P, D2,D2,D2,D2,D2,D2,D2,D2,D2,D2,D2,D2,D2,D2,D2, P,P,P 
;
;���襥, ����筮, ���।� !
DW A2,A2,A2,A2,A2,A2,A2, P, F2,F2,F2,F2,F2,F2, P, E2,E2,E2,E2,E2,E2,E2, P, D2,D2,D2,D2,D2,D2,D2, P
DW CIS2,CIS2,CIS2,CIS2,CIS2,CIS2,CIS2, P, D2,D2,D2,D2,D2,D2,D2, P, E2,E2,E2,E2,E2,E2,E2, P
DW CIS2,CIS2,CIS2,CIS2,CIS2,CIS2,CIS2, P,P, D2,D2,D2,D2,D2,D2,D2,D2,D2,D2,D2,D2,D2,D2,D2, P,P,P
;
;
;                         REFREN:
DW D,D,D,D,D,D,D,D,D,D,D,D, P,P, F,F,F,F,F,F,F,F,F,F,F,F, P,P, A2,A2,A2,A2,A2,A2,A2,A2,A2,A2,A2,A2, P,P,P 
;
;��������-᪠�����
DW D2,D2,D2,D2,D2,D2,D2,D2,D2,D2, P,P, A2,A2,A2,A2,A2,A2,A2, P, D2,D2,D2,D2,D2,D2,D2, P, C2,C2,C2,C2,C2,C2,C2, P
DW B2,B2,B2,B2,B2,B2,B2, P,   G,G,G,G,G,G,G, P,P,P 
;
;������
DW B2,B2,B2,B2,B2,B2,B2, P, A2,A2,A2,A2,A2,A2,A2, P, E,E,E,E,E,E,E,E,E,E, P,P,P
;
;�⥫����
DW B2,B2,B2,B2,B2,B2,B2, P, A2,A2,A2,A2,A2,A2,A2, P, F,F,F,F,F,F,F,F,F,F, P,P,P
;
;� ����ࠥ���
DW D2,D2,D2,D2,D2,D2,D2,D2,D2,D2, P,P, CIS2,CIS2,CIS2,CIS2,CIS2,CIS2,CIS2, P, D2,D2,D2,D2,D2,D2,D2, P
DW E2,E2,E2,E2,E2,E2,E2, P, D2,D2,D2,D2,D2,D2,D2, P,  B2,B2,B2,B2,B2,B2,B2, P,P,P
;
;��� ��⨢����
DW A2,A2,A2,A2,A2,A2,A2, P, F2,F2,F2,F2,F2,F2,F2, P, E2,E2,E2,E2,E2,E2,E2, P
DW F2,F2,F2,F2,F2,F2,F2, P, D2,D2,D2,D2,D2,D2,D2,D2,D2,D2,D2,D2,D2,D2,D2, P,P,P
;
;�������,�������
DW D2,D2,D2,D2,D2,D2,D2,D2,D2,D2, P,P, A2,A2,A2,A2,A2,A2,A2, P, D2,D2,D2,D2,D2,D2,D2, P, C2,C2,C2,C2,C2,C2,C2, P
DW B2,B2,B2,B2,B2,B2,B2, P,   G,G,G,G,G,G,G, P,P,P 
;
;� ���襥
DW B2,B2,B2,B2,B2,B2,B2, P, A2,A2,A2,A2,A2,A2,A2, P, E,E,E,E,E,E,E,E,E,E, P,P,P
;
;������
DW B2,B2,B2,B2,B2,B2,B2, P, A2,A2,A2,A2,A2,A2,A2, P, F,F,F,F,F,F,F,F,F,F, P,P,P
;
;������-������ !!!!!
DW D2,D2,D2,D2,D2,D2,D2,D2,D2,D2, P,P, CIS2,CIS2,CIS2,CIS2,CIS2,CIS2,CIS2, P, D2,D2,D2,D2,D2,D2,D2, P
DW E2,E2,E2,E2,E2,E2,E2, P, D2,D2,D2,D2,D2,D2,D2, P,  B2,B2,B2,B2,B2,B2,B2, P,P,P
;
;�⮬�� ����� !!!!!
DW A2,A2,A2,A2,A2,A2,A2, P, F2,F2,F2,F2,F2,F2,F2, P, E2,E2,E2,E2,E2,E2,E2, P
DW F2,F2,F2,F2,F2,F2,F2, P, D2,D2,D2,D2,D2,D2,D2,D2,D2,D2,D2,D2,D2,D2,D2, P,P,P



DW PAUS,END_MUSIC

old1c	dw 00
old1ch	dw 00
counter dw 00


.stack
end start
