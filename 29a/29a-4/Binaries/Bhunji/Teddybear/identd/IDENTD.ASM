
includelib kernel32.lib
includelib user32.lib
includelib wsock32.lib

.486
.model flat, stdcall

include c:\masm\include\windows.inc
include c:\masm\include\wsock32.inc
include c:\masm\include\kernel32.inc
include c:\masm\include\user32.inc


.data
        sin_family              dw      AF_INET
        sin_port                dw      113
        sin_addr                dd      0
        sin_zero                dd      0,0

        vsin_family             dw      0
        vsin_port               dw      0    
        vsin_addr               dd      0
        vsin_zero               dd      0,0

        SocketPtr               dd      0

        Query                   db      100 dup (0)

        Reply                   db      " : USERID : UNIX : steve"
                                db      0dh,0ah
        ReplyEnd                db      0

        BindStr                 db      "BindError",0

        ErrorStr                db      "Error",0

.code

Kernel32                db      "kernel32",0
RegisterService         db      "RegisterServiceProcess", 0
HideProgram:
        invoke  GetModuleHandleA, offset Kernel32
        invoke  GetProcAddress, eax, offset RegisterService
        test    eax,eax
        jz      NoHide
        push    1
        push    0
        call    eax
     NoHide:
        ret


    Main:
	call	HideProgram
        sub     esp,1000h
        mov     eax,esp
        INVOKE  WSAStartup, 1h, eax
        add     esp,1000h

        test    eax,eax
        jnz     Error

        invoke  socket, AF_INET, SOCK_STREAM, 0
        cmp     eax,-1
        jz      Error

        mov     SocketPtr,eax

        push    word ptr [sin_port]
        call    htons
        mov     word ptr [sin_port],ax

        lea     eax,sin_family

        invoke  bind, SocketPtr, eax, 16
        cmp     eax,-1
        jz      Error

        invoke  listen, SocketPtr, 2
        cmp     eax,-1
        jz      Error

        push    16
        lea     eax,vsin_family
        invoke  accept, SocketPtr, eax, esp
        cmp     eax,-1
        jz      Error


        add     esp,4

        push    eax
        invoke  closesocket, SocketPtr
        pop     SocketPtr


        lea     edi, Query
        invoke  recv, SocketPtr, edi, 100, 0
        cmp     eax,-1
        jz      CloseError


        add     edi,eax
        sub     edi,2

        lea     esi,Reply
        mov     ecx,ReplyEnd-Reply
        lea     eax,[ecx+eax-2]

        rep     movsb        

        lea     edi,Query
        invoke  send, SocketPtr, edi, eax, 0

        invoke  Sleep, 50000
CloseError:
        invoke  closesocket, SocketPtr

Error:
        invoke  ExitProcess,0

end Main

