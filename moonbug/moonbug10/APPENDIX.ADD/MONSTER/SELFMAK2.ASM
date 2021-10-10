;Self Source Maker - part II - by FRiZER
.model tiny
.code
.286
.startup
org 256
s:
cld
mov cx,48
lea si,dat
lea di,obkl1
push si
call prn_all
pop si
mov cx,50
lea di,obkl2
call prn_all
mov cx,2
lea si,e-7
lea di,obkl1
call prn_all
ret
prn_all:
push di
xchg si,di
call prn_str
xchg si,di
call prn_str
xchg si,di
call prn_str
xchg si,di
pop di
loop prn_all
ret
prn_str:
lodsb
cmp al,0
jnz $+3
ret
xchg ax,dx
mov ah,2
int 21h
jmp prn_str
obkl1:
db 0,13,10,0
obkl2:
db "db ",27h,0,39,",0",13,10,0
dat:
db ';Self Source Maker - part II - by FRiZER',0
db '.model tiny',0
db '.code',0
db '.286',0
db '.startup',0
db 'org 256',0
db 's:',0
db 'cld',0
db 'mov cx,48',0
db 'lea si,dat',0
db 'lea di,obkl1',0
db 'push si',0
db 'call prn_all',0
db 'pop si',0
db 'mov cx,50',0
db 'lea di,obkl2',0
db 'call prn_all',0
db 'mov cx,2',0
db 'lea si,e-7',0
db 'lea di,obkl1',0
db 'call prn_all',0
db 'ret',0
db 'prn_all:',0
db 'push di',0
db 'xchg si,di',0
db 'call prn_str',0
db 'xchg si,di',0
db 'call prn_str',0
db 'xchg si,di',0
db 'call prn_str',0
db 'xchg si,di',0
db 'pop di',0
db 'loop prn_all',0
db 'ret',0
db 'prn_str:',0
db 'lodsb',0
db 'cmp al,0',0
db 'jnz $+3',0
db 'ret',0
db 'xchg ax,dx',0
db 'mov ah,2',0
db 'int 21h',0
db 'jmp prn_str',0
db 'obkl1:',0
db 'db 0,13,10,0',0
db 'obkl2:',0
db 'db "db ",27h,0,39,",0",13,10,0',0
db 'dat:',0
db 'e:',0
db 'end',0
e:
end
