;MmM (RIORITA, SLOW VERSION ) + MARSH
;
;
;?????????????????????????????????????????????????????????????????????????????
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;
;Помните ли вы жаркое-прежаркое лето 1994 года, когда был расцвет МмМ, а по те-
;левизору передавали чемпионат мира по футболу ???
;В те дни я курсировал между домом (там у меня есть телевизор) и метро Нагатин-
;ская (там находится пресловутая Варшавка,26)
;В те дни и засел мне в мозги этот веселый мотивчик, который транслировали по 
;телевизору пожалуй даже чаще, чем сам чемпионат...
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
;Исследовательский центр Самоходного программного обеспечения имени "Ячменного Колоса"
;
;         Lurische Abweisung... (Лирическое отступление)
;Опп--а Опп--а вышли       Н Е П О Н Я Т К И  ! ! !
;Голосуй за Борового - и будет все в порядке ! 
;
;
;Вероятно,многие из вас хотели бы украсить свои вируса веселой музычкой ?
;NO PROBLEM !!! 
;Берете гитарку или пианину - и вперед !
;Подобрали музычку,записали нотки - и вносите их вместо моих 
;
;Непонятно ? Вы не учились в музыкальных школах (в отл. от меня и BEER(a) )
;Nicht's zu machen !     aber...   (Ничего не поделаешь,но...)
;Хрен с вами - разрешаем использовать нашу музычку;
;А будете ее колупать глядишь и разберетесь... 
;А если и не разберетесь - по барабану : мы еще до Х.я сделаем -
;Хватит на всех 
;C уважением Gurre & Beer  
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
C2 = C/2 ;ДО
CIS2 = CIS/2 ;ДО# 
D2= D/2   ;РЕ (2) 
P = PAUS  ;ПАУЗА
DIS2=DIS/2
E2 = E/2 ;МИ
F2 = F/2 
FIS2 = FIS/2 
;************************ Макроопределения нот (конец)******************************
mus:
;                                 ***   MARSH  *** (из кинофильма "Запасной игрок")
;
;              Мы болеем за наш футбол: 
;
;
DW D,D,D,D,D,D,D,D,D, P,P, G,G,G,G,G,G, P,P, G,G,G,G, P,G,G,G,G, P, G,G,G,G ;РЕ СОЛЬ СОЛЬ СОЛЬ СОЛЬ
DW FIS,FIS,FIS,FIS,FIS,  G,G,G,G,G,  A2,A2,A2,A2,A2, H2,H2,H2,H2,H2,H2,H2,H2,H2,H2,H2,H2 ;ФА# СОЛЬ ЛЯ СИ
DW A2,A2,A2,A2,A2, P, G,G,G,G,G,G,G, P,P, D,D,D,D,D,D,D,D,D,D, P ;ЛЯ СОЛЬ РЕ 
DW H2,H2,H2,H2,H2,H2, P,P, H2,H2,H2,H2, P, H2,H2,H2,H2, P, H2,H2,H2,H2, P; СИ СИ СИ СИ
DW A2,A2,A2,A2,A2, H2,H2,H2,H2,H2, C2,C2,C2,C2,C2, A2,A2,A2,A2,A2,A2,A2 ; ЛЯ СИ ДО ЛЯ
DW P,P
DW D2,D2,D2,D2, P,P, D2,D2,D2,D2, P,P,P, D2,D2,D2,D2,D2,D2,D2,D2, P,P ;РЕ РЕ РЕ
DW FIS2,FIS2,FIS2,FIS2,FIS2,FIS2,FIS2,FIS2, P, E2,E2,E2,E2, P, D2,D2,D2,D2,D2, P,P ; ФА МИ РЕ
DW E2,E2,E2,E2,E2,E2, P, D2,D2,D2,D2,D2,D2,D2,D2, P,P, C2,C2,C2,C2, P, H2,H2,H2,H2,H2 ; МИ РЕ ДО СИ
DW P,P 

;                            *** RIORITA ***

DW D,D,D,D,D,D,D,D,D,D,D,D, P,P, H2,H2,H2,H2,H2,H2,H2,H2,H2,H2,H2,H2,H2,H2,H2, P,P ;РЕ СИ
DW A2,A2,A2,A2,A2,A2,    H2,H2,H2,H2,H2,H2 ;ЛЯ СИ
DW A2,A2,A2,A2,A2,A2,     G,G,G,G,G,G,G,G,G,G,G,G, P,P,P,P,P ;ЛЯ СОЛЬ

DW D,D,D,D,D,D,     G,G,G,G,G,G, A2,A2,A2,A2,A2 ;РЕ СОЛЬ ЛЯ
DW H2,H2,H2,H2,H2, P, H2,H2,H2,H2,H2, P, H2,H2,H2,H2,H2 ;СИ СИ СИ
DW C2,C2,C2, H2,H2,H2, A2,A2,A2,A2,A2, H2,H2,H2,H2,H2 ;ДО СИ ЛЯ СИ
DW C2,C2,C2,C2,C2,C2, D2,D2,D2,D2,D2,D2, P,P,P,P,P,P,P,P  ;ДО РЕ(2) 

DW D,D,D,D,D,D,D,D,D,D,D,D, P,P, A2,A2,A2,A2,A2,A2,A2,A2,A2,A2,A2,A2,A2,A2,A2, P,P ; РЕ ЛЯ  
DW G,G,G,G,G,G, A2,A2,A2,A2,A2,A2 ;СОЛЬ ЛЯ 
DW G,G,G,G,G,G, FIS,FIS,FIS,FIS,FIS,FIS,FIS,FIS,FIS,FIS,FIS,FIS, P,P,P,P,P ;СОЛЬ ФА# 

DW D,D,D,D,D,D,   FIS,FIS,FIS,FIS,FIS,FIS, A2,A2,A2,A2,A2,A2 ; РЕ ФА# ЛЯ
DW C2,C2,C2,C2,C2, P, C2,C2,C2,C2,C2, P, C2,C2,C2,C2,C2 ;ДО ДО ДО
DW D2,D2,D2, C2,C2,C2, H2,H2,H2,H2,H2,H2, C2,C2,C2,C2,C2,C2 ;РЕ ДО СИ ДО 
DW D2,D2,D2,D2,D2,D2,D2,D2,D2,D2,D2,D2,D2,D2,D2, P,P,P,P,P,P,P,P ;РЕ

DW D2,D2,D2,D2,D2,D2,D2,D2, DIS2,DIS2,DIS2,DIS2,DIS2,DIS2,DIS2,DIS2 ;РЕ(2) РЕ#(2) 
DW F2,F2,F2,F2,F2,F2,F2,F2,F2,F2,F2,F2,F2,F2,F2, P,P,P ; ФА(2)
DW DIS2,DIS2,DIS2,DIS2,DIS2,DIS2, P,P, D2,D2,D2,D2,D2,D2,D2,D2, C2,C2,C2,C2,C2,C2,C2,C2 ;РЕ#(2) РЕ(2) ДО(2)   
DW P,P,P,P,P,P,P,P

DW A2,A2,A2,A2,A2,A2,A2,A2, B2,B2,B2,B2,B2,B2,B2,B2 ;ЛЯ ЛЯ#
DW C2,C2,C2,C2,C2,C2,C2,C2,C2,C2,C2,C2,C2,C2,C2, P,P,P ;ДО
DW DIS2,DIS2,DIS2,DIS2,DIS2,DIS2, D2,D2,D2,D2,D2,D2, C2,C2,C2,C2,C2,C2, H2,H2,H2,H2,H2,H2 ;РЕ# РЕ ДО СИ
DW P,P,P,P,P,P,P,P,P,P,P

DW D,D,D,D,D,D,D,D,D,D,D,D, P,P, H2,H2,H2,H2,H2,H2,H2,H2,H2,H2,H2,H2,H2,H2,H2, P,P ;РЕ СИ
DW A2,A2,A2,A2,A2,A2,    H2,H2,H2,H2,H2,H2 ;ЛЯ СИ
DW A2,A2,A2,A2,A2,A2,     G,G,G,G,G,G,G,G,G,G,G,G, P,P,P,P,P ;ЛЯ СОЛЬ

DW D,D,D,D,D,D,     G,G,G,G,G,G, A2,A2,A2,A2,A2 ;РЕ СОЛЬ ЛЯ
DW H2,H2,H2,H2,H2, D2,D2,D2,D2,D2,D2, C2,C2,C2,C2,C2,C2 ;СИ РЕ ДО
DW D2,D2,D2, C2,C2,C2 ;РЕ ДО
DW H2,H2,H2,H2,H2, A2,A2,A2,A2,A2,A2, G,G,G,G,G,G  ;СИ ЛЯ СОЛЬ
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
