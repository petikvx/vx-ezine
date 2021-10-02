;loading elf files under w32
;(c) Vecna/29A 2004

.386
.model flat, stdcall
option casemap :none

include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\user32.inc
include \masm32\include\masm32.inc
include elf.inc

includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\user32.lib

includelib \masm32\lib\masm32.lib

ELF_BASE EQU 08048000h

CRC_POLY EQU 0EDB88320h
CRC_INIT EQU 0FFFFFFFFh

crc     macro string
  LOCAL crcReg,ctrlByte
        crcReg = CRC_INIT
        FORC _x, <string>
          ctrlByte = "&_x&" XOR (crcReg AND 255)
          crcReg = crcReg SHR 8
          REPEAT 8
            ctrlByte = (ctrlByte SHR 1) XOR (CRC_POLY * (ctrlByte AND 1))
          ENDM
          crcReg = crcReg XOR ctrlByte
        ENDM
        dd crcReg
endm

libc_api macro funct
        crc funct
        dd offset funct
endm



.data

yourmachinesux db "setup fail",13,10,0
fakelibcsux    db " - libc fail",13,10,0
seh_fmt        db "Emulation fail at 0x%08x",13,10,0
seh_info       db "EAX=%08x ECX=%08x EDX=%08x EBX=%08x",13,10
               db "ESP=%08x EBP=%08x ESI=%08x EDI=%08x",13,10,0


usage          db "run_elf.exe <elf2run>",13,10,0

plt            db ".plt",0
relplt         db ".rel.plt",0
dynstr         db ".dynstr",0
dynsym         db ".dynsym",0




.code

calc_crc proc buf:DWORD
        pushad
        mov esi,[buf]
        mov ecx,CRC_INIT
  @@next_byte:
        lodsb
        test al, al
        jz @@done
        xor cl, al
        mov al, 8
  @@next_bit:
        shr ecx, 1
        jnc @f
        xor ecx, CRC_POLY
  @@:
        dec al
        jnz @@next_bit
        jmp @@next_byte
  @@done:
        mov [esp+7*4],ecx
        popad
        ret
calc_crc endp


dyn_link proc uses esi libc:DWORD
        invoke calc_crc,[libc]
        mov esi,offset libc_ptable
        mov edx,eax
  @@:
        lodsd
        test eax,eax
        jz @f
        cmp eax,edx
        lodsd
        jnz @b
        jmp @@exit
  @@:
        sub eax,eax
  @@exit:
        ret
dyn_link endp


start   proc
  LOCAL file_cmdline[MAX_PATH]:BYTE
  LOCAL tmp:DWORD
  LOCAL v_elf:DWORD
  LOCAL h_file_size:DWORD
  LOCAL h_file_buffer:DWORD
  LOCAL sz:DWORD
  LOCAL _pltsize:DWORD
  LOCAL _plt:DWORD
  LOCAL _relplt:DWORD
  LOCAL _dynstr:DWORD
  LOCAL _dynsym:DWORD

        invoke ArgClC,1,ADDR file_cmdline
        dec eax
        jz @@open_hfile
        invoke StdOut,offset usage
        jmp @@error

  @@open_hfile:
        invoke CreateFile,ADDR file_cmdline,GENERIC_READ,0,0,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
        mov ebx,eax
        inc eax
        jz @f
        invoke GetFileSize,ebx,0
        mov [h_file_size],eax
        invoke GlobalAlloc,GPTR,eax
        test eax,eax
        jz @f
        mov [h_file_buffer],eax
        invoke ReadFile,ebx,[h_file_buffer],[h_file_size],ADDR tmp,0
        test eax,eax
        jz @f
        invoke CloseHandle,ebx
        jmp @@alloc_elf_mem
  @@:
        invoke StdOut,offset yourmachinesux
        jmp @@error

  @@alloc_elf_mem:
        mov eax,[h_file_size]
        add eax,(8000h)+4095
        and eax,-4096
        invoke VirtualAlloc,ELF_BASE,eax,MEM_COMMIT+MEM_RESERVE,PAGE_EXECUTE_READWRITE
        test eax,eax
        jz @b

        mov edi,ELF_BASE
        mov [v_elf],edi
        mov ecx,[h_file_size]
        mov esi,[h_file_buffer]
        rep movsb

        mov edx,[v_elf]
        mov esi,[edx+eh_sh_offset]
        add esi,edx
        movzx edi,word ptr [edx+eh_sh_count]
        movzx eax,word ptr [edx+eh_sh_entrysize]
        mov [sz],eax
        movzx eax,word ptr [edx+eh_sh_str_index]
        imul eax,[sz]
        add eax,esi
        mov ebx,[eax+sh_offset]
        add ebx,edx

  @@:
        add [esi+sh_name],ebx
        invoke lstrcmp,[esi+sh_name],offset dynstr
        test eax,eax
        jnz @@no_dynstr
        mov eax,[esi+sh_offset]
        add eax,[v_elf]
        mov [_dynstr],eax
  @@no_dynstr:
        invoke lstrcmp,[esi+sh_name],offset relplt
        test eax,eax
        jnz @@no_got
        mov eax,[esi+sh_offset]
        add eax,[v_elf]
        mov [_relplt],eax
  @@no_got:
        invoke lstrcmp,[esi+sh_name],offset plt
        test eax,eax
        jnz @@no_plt
        mov eax,[esi+sh_offset]
        add eax,[v_elf]
        mov [_plt],eax
        mov eax,[esi+sh_size]
        mov [_pltsize],eax
  @@no_plt:
        invoke lstrcmp,[esi+sh_name],offset dynsym
        test eax,eax
        jnz @@no
        mov eax,[esi+sh_offset]
        add eax,[v_elf]
        mov [_dynsym],eax
  @@no:
        add esi,[sz]
        dec edi
        jnz @b

        mov esi,[_plt]
  @@:
        add esi,16
        sub [_pltsize],16
        jz @f
        cmp byte ptr [esi+6],68h
        jne @f
        mov eax,[esi+7]
        add eax,[_relplt]
        mov eax,[eax+4]
        shr eax,4
        add eax,[_dynsym]
        mov eax,[eax+st_name]
        add eax,[_dynstr]
        xchg eax,ecx
        invoke dyn_link,ecx
        test eax,eax
        jnz @@emu
        mov eax,offset unhandled_extrn
  @@emu:
        xchg eax,edx
        mov edi,esi
        mov al, 068h
        stosb
        xchg eax,ecx
        stosd
        mov al, 0e9h
        stosb
        stosd
        sub edx,edi
        mov [edi-4],edx
        sub eax,eax
        stosd
        stosw
        jmp @b
  @@:

        mov ebx,[v_elf]
        mov esi,[ebx+eh_ph_offset]
        add esi,ebx
        movzx ecx,word ptr [ebx+eh_ph_count]
  @@:
        push ecx
        mov ecx,PAGE_READWRITE
        test dword ptr [esi+ph_flags],1
        jnz @@r
        mov ecx,PAGE_READONLY
  @@r:
        mov edx,[esi+ph_address]
        invoke VirtualProtect,edx,[esi+ph_memsize],ecx,ADDR tmp
        add esi,sizeof_program_header
        pop ecx
        loop @b

        push offset @@seh_handler
    assume fs:nothing
        push dword ptr fs:[0]
        mov dword ptr fs:[0],esp

        mov eax,[v_elf]
        call dword ptr [eax+eh_entrypoint]
        jmp @@error

  @@seh_handler:
        mov eax,[esp+4]
        mov ebx,[esp+12]
        mov esp,[esp+8]
        mov eax,[eax+12]
        invoke wsprintf,ADDR file_cmdline,offset seh_fmt,eax
        invoke StdOut,ADDR file_cmdline
        invoke wsprintf,ADDR file_cmdline,offset seh_info,\
        dword ptr [ebx+0b0h],dword ptr [ebx+0ach],dword ptr [ebx+0a8h],dword ptr [ebx+0a4h],\
        dword ptr [ebx+0c4h],dword ptr [ebx+0b4h],dword ptr [ebx+0a0h],dword ptr [ebx+09ch]
        invoke StdOut,ADDR file_cmdline

  @@error:
        invoke ExitProcess,0
        ret
start   endp


unhandled_extrn proc libc:DWORD
        invoke StdOut,[libc]
        invoke StdOut,offset fakelibcsux
        invoke ExitProcess,0
        ret
unhandled_extrn endp


include handlers.inc


end     start
