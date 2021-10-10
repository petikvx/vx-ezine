;*************************************************************
;                 ExeIdent v1.0 
;          (c) Opic [CodeBreakers 98]
;
;Exeident is a simple utility which will illustrate how one
;can tell the difference between a DOS exe and a Windows Exe
;Please see the "Identifying Windows Executables" tutorial
;in CodBrk4 for a more complete explanation. The source
;also doubles as example source for alot of people who have
;wanted to learn how to buffer text from the keyboard in ASM
;so here ya go :) Extra special thanx go out to Spo0ky for
;showing me this simple way to indentify Windbloze .exe 
;compiles: a86 exeident.asm (Its a nice compiler to write small 
;utils with, so dont badmouth it.)
;************************************************************** 

start:
lea dx,offset hello               ;say hello
call screen

;--------------------------

mov ah,0ah
lea dx,input
int 21h

lea si,input
xor ax,ax
mov al,[input+1]
add si,ax
add si,2
mov byte ptr [si],0



;---------------------
go:
mov ah,4eh
lea dx,[input+2]
mov cx,7
int 21h
jc nope
mov ax,3d02h
mov dx,9eh
int 21h
mov bx,ax
mov ah,3fh
lea dx,offset header
mov cx,1ah
int 21h
cmp word ptr cs:[offset header],'MZ'
je cont
cmp word ptr cs:[offset header],'ZM'
je cont
jmp nope
cont:
mov ax,word ptr cs:[offset header+18h]
cmp ax,40h
jae windows

dosexe:
lea dx,offset dossy
call screen
jmp exit

;-----------------

nope:
lea dx,offset noexe
call screen
jmp exit

windows:
lea dx,offset wind
call screen

exit:
lea dx,offset bye
call screen
mov ah,4ch
int 21h

screen proc

mov ah,9
int 21h
ret

screen endp


hello  db  '****************************************************',10,13,
       db  'Welcome to the CodeBreakers ExeIndent v1.0 program',10,13,
       db  'This is a utility to help you identify and delineate',10,13,
       db  'Windows Exe files and DOS Exe file,',10,13,
       db  'Please Enter the filename you would like to examine',10,13,
       db  'now. (file must be in current dir) [ex: file.exe]',10,13,  
       db  '****************************************************',10,13,'$'

header  db 1ah DUP(?)

dossy db   'This file is a DOS Exe file',10,13,'$'
 
noexe db   'Sorry, the file you have entered does not exist, or',10,13, 
      db   'the file you have selected to analyze is not a true',10,13,
      db   'Exe file at all.',10,13,'$'

wind  db   'This file is a Windows Exe file.',10,13,'$'

bye   db   '****************************************************',10,13,
      db   'Thank you for using the CodeBreakers ExeIdent v1.0',10,13,
       db  '(c) and copyrighted: Opic [Cb 1998]',10,13,  
       db  '****************************************************',10,13,'$'
input   db      64,?,64 dup (?)                      ; Set input buffer                              
