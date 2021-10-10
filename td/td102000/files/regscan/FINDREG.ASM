
; þ example of registry scanning for commandline keyword

C_MULTIKEYSIZE          equ     1024    ; max length of key\key\key string
C_SINGLEKEYSIZE         equ     256     ; max length of single key
C_VALUENAMESIZE         equ     256     ; max length of value name
C_VALUESIZE             equ     512     ; max length of value

include                 consts.inc

callW                   macro   _xxx
                        extrn   _xxx:proc
                        call    _xxx
                        endm

                        p386
                        model   flat
                        locals  __

                        .data

msg1                    db      'FINDREG  Super-Puper Registry KeyWord Finder  (x) 2000',13,10,0
msg2                    db      13,10
                        db      'syntax:',13,10
                        db      '  FINDREG keyword',13,10,0
msg3                    db      'þ scan complete',13,10,0

argc                    dd      ?
argv0                   db      256 dup (?)
argv1                   db      256 dup (?)
argv2                   db      256 dup (?)
argv3                   db      256 dup (?)

                        .code

start:
                        lea     edx, msg1
                        call    dump_asciiz_edx

                        call    getcmdline
                        cmp     argc, 2
                        jne     help

                        call    regscan

                        lea     edx, msg3
                        call    dump_asciiz_edx

quit:                   push    -1
                        callW   ExitProcess

help:                   lea     edx, msg2
                        call    dump_asciiz_edx
                        jmp     quit

; ---------------------------------------------------------------------------

; scans:
;   HKEY_CLASSES_ROOT
;   HKEY_CURRENT_USER
;   HKEY_LOCAL_MACHINE
;   ...

regscan:                pusha
                        sub     esp, C_MULTIKEYSIZE

                        mov     ebx, 80000000h

                        mov     edi, esp
                        mov     word ptr [edi], '0'

__cycle:                call    scankey

                        inc     byte ptr [edi]

                        inc     ebx
                        cmp     bl, 6
                        jbe     __cycle

                        add     esp, C_MULTIKEYSIZE
                        popa
                        retn

; ---------------------------------------------------------------------------

; input: EBX=hKey
;        EDI=keyname

scankey:                pusha

                        mov     eax, C_MULTIKEYSIZE-C_SINGLEKEYSIZE-1

                        dec     edi

__scan0:                inc     edi

                        dec     eax
                        jz      __quit

                        cmp     byte ptr [edi], 0
                        jne     __scan0

                        mov     al, '\'
                        stosb

                        xor     esi, esi        ; subkey index

__cycle:                push    C_SINGLEKEYSIZE ; cbName
                        push    edi             ; lpName
                        push    esi             ; dwIndex
                        push    ebx             ; hKey
                        callW   RegEnumKeyA

                        or      eax, eax
                        jnz     __exit

                        push    eax
                        push    esp             ; phkResult
                        push    edi             ; lpSubKey
                        push    ebx             ; hKey
                        callW   RegOpenKeyA
                        or      eax, eax
                        pop     eax             ; EAX<--hKey
                        jnz     __skip

                        xchg    edi, [esp].pusha_edi
                        xchg    ebx, eax
                        call    scanvalue       ; scan current key's values
                        call    scankey         ; recursivly scan subkeys
                        xchg    ebx, eax
                        xchg    edi, [esp].pusha_edi

                        push    eax             ; hKey
                        callW   RegCloseKey

__skip:                 inc     esi             ; subkey index
                        jmp     __cycle

__exit:                 mov     byte ptr [edi-1], 0

__quit:                 popa
                        retn

; ---------------------------------------------------------------------------

; input: EBX=hKey
;        EDI=keyname

scanvalue:              pusha

                        sub     esp, C_VALUENAMESIZE

                        mov     edi, esp        ; EDI = ValueName
                        sub     esp, C_VALUESIZE

                        xor     esi, esi        ; value index

__cycle:                push    C_VALUESIZE     ; Value length
                        mov     ecx, esp
                        push    C_VALUENAMESIZE ; ValueName length
                        mov     edx, esp
                        push    0               ; Type
                        mov     eax, esp

                        push    ecx             ; lpcbData
                        lea     ecx, [esp+16]
                        push    ecx             ; lpData
                        push    eax             ; lpType
                        push    0               ; lpReserved
                        push    edx             ; lpcbValueName
                        push    edi             ; lpValueName
                        push    esi             ; dwIndex
                        push    ebx             ; hKey
                        callW   RegEnumValueA
                        or      eax, eax
                        pop     eax             ; Type
                        pop     edx             ; ValueName length
                        pop     ecx             ; Value length
                        jnz     __exit

                        cmp     eax, REG_SZ     ; Type
                        jne     __skip

;                       or      edx, edx        ; ValueName length
;                       jz      __skip
;                       or      ecx, ecx        ; Value length
;                       jz      __skip

                        mov     edx, [esp+C_VALUENAMESIZE+C_VALUESIZE].pusha_edi
                        mov     ecx, esp
                        call    checkentry

__skip:                 inc     esi             ; value index
                        jmp     __cycle

__exit:                 add     esp, C_VALUENAMESIZE+C_VALUESIZE

                        popa
                        retn

; ---------------------------------------------------------------------------

; input: EBX=hKey
;        EDX=keyname
;        EDI=valuename (may be zero-length)
;        ECX=value     (may be zero-length)

checkentry:             pusha

                        mov     esi, edx
                        call    findsubstr
                        je      __ok

                        mov     esi, edi
                        call    findsubstr
                        je      __ok

                        mov     esi, ecx
                        call    findsubstr
                        je      __ok

__exit:                 popa
                        retn

__ok:                   call    got_entry
                        jmp     __exit

; ---------------------------------------------------------------------------

; input:  EDX,EDI,ECX=asciiz
;         ESI=current
; output: ZF==0 (jnz) -- substring (argv1) NOT found
;         ZF==1 (jz)  -- substring (argv1) found

findsubstr:             pusha

                        lea     edi, argv1

                        xor     eax, eax        ; ECX<--strlen(argv1)
                        lea     ecx, [eax-1]
                        repnz   scasb
                        not     ecx
                        dec     ecx

                        lea     edi, argv1      ; EDI<--argv1

__cycle:                pusha
                        rep     cmpsb
                        popa
                        je      __exit  ; ZR

                        cmp     byte ptr [esi], 0
                        lea     esi, [esi+1]
                        jne     __cycle
                        inc     esi     ; NZ

__exit:                 popa
                        retn

; ---------------------------------------------------------------------------

; input: EBX=hKey
;        EDX=keyname
;        EDI=valuename (may be zero-length)
;        ECX=value     (may be zero-length)

got_entry:              pusha

                        call    dump_asciiz_edx
                        mov     al, ':'
                        call    dump_al
                        mov     edx, edi
                        call    dump_asciiz_edx
                        mov     al, '='
                        call    dump_al
                        mov     edx, ecx
                        call    dump_asciiz_edx
                        call    dump_crlf

                        popa
                        retn

; ---------------------------------------------------------------------------

include                 console.inc
include                 cmdline.inc

; ---------------------------------------------------------------------------

                        end     start
