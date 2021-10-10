;Copyright GURRE 20 April 1996
;                       *** "2x2=4" ***
;This message (c)Copyright 1996 by Y&Y Corporation
;Исследовательский центр Самоходного программного 
;     обеспечения имени "Ячменного Колоса"
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
;************************ Макроопределения нот (начало)******************************
A = 5422  ;ЛЯ 
B = 5117  ;ЛЯ#
H = 4830  ;СИ
;
C = 4559  ;ДО
CIS = 4303;ДО#
D = 4061  ;РЕ
DIS = 3833;РЕ#
E = 3619  ;МИ
F = 3416  ;ФА
FIS = 3224;ФА#
G = 3042  ;СОЛЬ
GIS = 2872;СОЛЬ#
A2 = 2711 ;ЛЯ
B2 = 2559 ;ЛЯ#
H2 = 2415 ;СИ
;
C2 = 2279 ;ДО
CIS2 = 2151;ДО# 
D2=2030   ;РЕ (2) 
P = PAUS  ;ПАУЗА
DIS2=DIS/2;РЕ#
E2 = E/2 ;МИ
F2 = F/2 ;ФА
FIS2 = FIS/2 ;ФА#
;************************ Макроопределения нот (конец)******************************
mus:
;     Песенка 2x2                            
;
;
;ТВО БУ ТВО - ЧЕТЫРЕ !!!
DW G,G,G,G,G,G,G,G, P, G,G,G,G,G,G,G,G, GIS,GIS,GIS,GIS, G,G,G,G, F,F,F,F, DIS,DIS,DIS,DIS
;TWO BY TWO -TCHETYRYE
DW G,G,G,G,G,G,G,G, P, G,G,G,G,G,G,G,G, GIS,GIS,GIS,GIS, G,G,G,G, F,F,F,F, DIS,DIS,DIS,DIS
;А НЕ 3
DW G,G,G,G, F,F,F,F, P, B2,B2,B2,B2,B2,B2,B2,B2
;А НЕ 5
DW G,G,G,G, F,F,F,F, P, B2,B2,B2,B2,B2,B2,B2,B2
;this надо кновать !!!
DW C2,C2,C2,C2, B2,B2,B2,B2, GIS,GIS,GIS,GIS, G,G,G,G, B2,B2,B2,B2,B2,B2,B2,B2    
;
DW P,P,P,P
;
DW G,G,G,G,G,G,G,G, P, G,G,G,G,G,G,G,G, GIS,GIS,GIS,GIS, G,G,G,G, F,F,F,F, DIS,DIS,DIS,DIS
DW G,G,G,G,G,G,G,G, P, G,G,G,G,G,G,G,G, GIS,GIS,GIS,GIS, G,G,G,G, F,F,F,F, DIS,DIS,DIS,DIS
DW G,G,G,G, F,F,F,F, P, B2,B2,B2,B2,B2,B2,B2,B2
DW G,G,G,G, F,F,F,F, P, B2,B2,B2,B2,B2,B2,B2,B2
DW C2,C2,C2,C2, B2,B2,B2,B2, GIS,GIS,GIS,GIS, F,F,F,F, DIS,DIS,DIS,DIS    




DW PAUS,END_MUSIC

old1c	dw 00
old1ch	dw 00
counter dw 00


.stack
end start
