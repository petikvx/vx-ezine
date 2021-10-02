;TINY FTP SERVER FOR LINUX
;(c) Vecna 2004

;compile with nasm 0.98.38

[BITS 32]

%define PORT	   21
%define PORT2	   20
%define PASSWORD   "PASS ancev123"

;%define MULTITHREAD
%define NO_CODE_PTRS

%define TIMEOUT	   120

%define jmps	   jmp short

%define	origin     31930000h

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

code_start equ $

%include "elfheader.inc"

%include "syscall.inc"
%include "useful.inc"

code:
%ifdef  NO_CODE_PTRS
	mov edi,dword code
	call .delta
  .delta:
	pop esi
	sub esi,byte (.delta-code)
	mov ecx,code_end-code
	rep movsb
	push dword .lowstart
	ret
  .lowstart:
%endif
        sub ebx,ebx

        call get_socket
	jz phdr.finish

	push ebx
	push ebx
	push ebx
	push dword ((PORT&0xFF)<<24)|(((PORT&0xFF00)>>8)<<16)+2
	mov esi,esp

        call bind_listen
	lea esp,[esp+4*4]
	jnz phdr.finish

  .wait4connect:
	push ebx
	push ebx
	push ebp
	mov al,SYS_ACCEPT
	call socket_call
	add esp,byte 3*4

%ifdef 	MULTITHREAD
        push eax
        push byte __NR_clone
        pop eax
        int 80h
        test eax,eax
        pop eax
        jz near ftpd_thread
%else
        call ftpd_thread
%endif

	jmps .wait4connect



socket_call:
        pushad
        movzx ebx,al
        push byte __NR_socketcall
        pop eax
        lea ecx,[esp+8*4+4]
        int 80h
        mov [esp+7*4],eax
        popad
        ret


bind_listen:
	push byte 16
	push esi
	push ebp
	mov al,SYS_BIND
	call socket_call
	test eax,eax

	push byte 5
	push ebp
	jnz .error
	mov al,SYS_LISTEN
	call socket_call
	test eax,eax
  .error:
	lea esp,[esp+5*4]
        ret



get_socket:
	push byte 0
	push byte 1
	push byte 2
	mov al,SYS_SOCKET
	call socket_call
	add esp,byte 3*4
	mov ebp,eax
	inc eax
        ret



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

	push byte 0
	push ecx
	push edi
	push ebp
	mov al,SYS_SEND
	call socket_call

	inc eax
	jmps recv_data.exit



recv_data:
	pushad
	mov esi,[esp+(8*4)+4]

	push byte 0
	push byte 7ch
	push esi
	push ebp
	mov al,SYS_RECV
	call socket_call
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
        lea esp,[esp+4*4]
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



value2ascii:
	pushad
	push byte -1
	push byte 10
	pop ecx
  .loop:
	sub edx,edx
	div ecx
	push edx
	test eax,eax
	jnz .loop
  .loop2:
	pop eax
	inc eax
	jz .done
	add al,"0"-1
	stosb	
	jmps .loop2	
  .done:
	mov [esp],edi
	popad
	ret



connect_data:
	push esi
	push dword datainit
	call send_data

        call get_socket
	jnz .noerror
  .set_error:
	inc eax
	jmps .error

  .noerror:
        lea esi,[esp+edi+4+4+4+4]
	lodsd
	test eax,eax
	lodsd
	jz .no_pasv

        call bind_listen

	push byte 0
	push byte 0
	push ebp
	mov al,SYS_ACCEPT
	call socket_call
        add esp,byte 3*4

	push eax
	call close
	pop ebp

        mov eax,ebp
        inc eax
        jz .set_error
        sub eax,eax
        jmps .error

  .no_pasv:
	push byte 16
	push esi
	push ebp
	mov al,SYS_CONNECT
	call socket_call
        add esp,byte 3*4

	test eax,eax
  .error:
        pop esi
	ret



close:
	push byte 2
	push ebp
	mov al,SYS_SHUTDOWN
	call socket_call
	pop eax
	pop eax
        xchg ebx,ebp
	push byte __NR_close
        pop eax
        int 80h
	ret



open:
        pushad

        push byte __NR_open
        pop eax
        mov ebx,esi
        int 80h
        mov [esp+4*4],eax
        test eax,eax
        js .error
        mov ebx,eax

        mov ecx,[esp+edi+4+4+4+(4*8)]
        push byte __NR_lseek
        pop eax
        cdq
        int 80h
        test eax,eax
  .error:
        popad
	ret



set_sockaddr:
	mov di,2
	mov cl,7ch+4+4+4+4
	mov [esp+ecx],edi
	mov [esp+ecx+4],ebx
        ret



ftpd_thread:
	pushad

	mov ebp,[esp+7*4]

	push byte __NR_chdir
	pop eax
	mov esi,dword root

	mov ebx,esi
	int 80h

	lodsw
	push esi
	call send_data
	jz near .exit

	sub eax,eax
	sub esp,byte 4*4
	push eax
	push eax
	push eax

  .wait4command:
	push byte 0
	push byte TIMEOUT
	mov edi,esp

        push byte 0
        bts [esp],ebp
        mov ecx,esp

        sub esi,esi
        sub edx,edx
        mov eax,__NR__newselect
        lea ebx,[ebp+1]
        int 80h
        add esp,byte 3*4
        dec eax
	jnz near .exit2

	push byte 7ch
	pop edi

	sub esp,edi
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

	mov ebx,dword logged

	cmp_ecx_hash "QUIT"
  .je2exit3:
	je near .exit3

	cmp_ecx_hash PASSWORD
	jne .no_pass
	inc dword [esp+edi]
	push ebx
	jmps .jmp2jmp2sendinfo
  .no_pass:

	mov edx,[esp+edi]
	test edx,edx
	jnz .logged
	add ebx,byte (password-logged)
	push ebx
  .jmp2jmp2sendinfo:
	jmps .jmp2sendinfo

  .logged:
        cmp_hash "TYPE"
        je .done_ok

        cmp_hash "REST"
        jne .no_rest
        call ascii2value
        mov [esp+(4+4+edi)],edx
	add ebx,byte (restok-logged)
	push ebx
	jmps .jmp2sendinfo

  .no_rest:
        cmp_ecx_hash "CDUP"
	jne .no_cdup
        add ebx,byte (dotdot-logged)
	xchg ebx,esi
	jmps .chdir

  .no_cdup:
	cmp_hash "CWD"
	jne .no_cwd
	mov ebx,esi
  .chdir:
	push byte __NR_chdir
	jmps .doint80

  .no_cwd:
	cmp_hash "DELE"
	jne .no_dele
        push byte __NR_unlink
  .doint80:
	xchg ebx,esi
        pop eax
        int 80h

  .done_ok_error:
  	test eax,eax
  	js near .done_error

  .done_ok:
	push dword done
  .jmp2sendinfo:
	jmp .sendinfo

  .no_dele:
	cmp_hash "PORT"
	jne .no_port

	push byte 6
	pop ecx
	sub edi,edi
	sub ebx,ebx
  .port_cmd:
 	cmp cl,2
	jne .noportpart
	xchg edi,ebx
  .noportpart:
        call ascii2value
	or edi,edx
  	ror edi,8
	loop .port_cmd
        call set_sockaddr
	sub eax,eax
        mov dword [esp+ecx+(7ch+4-(7ch+4+4+4+4))],eax
	jmps .done_ok

  .no_port:
	cmp_ecx_hash "PASV"
	jne .no_pasv

	sub esp,edi
	mov ebx,esp

	push byte 16
	push esp
	push ebx
	push ebp
	mov al,SYS_GETSOCKNAME
	call socket_call
	
	push ebx

	mov edi,ebx
        mov ebx,[ebx+4]
	mov edx,ebx
	
	mov esi,dword pasv
	push byte pasv_size
	pop ecx
	rep movsb
    
        push byte 6
        pop ecx
  .decimal:
        cmp cl,2
        jne .skipport
        mov edx,(PORT2&0xFF)<<8|(PORT2&0xFF00)>>8
  .skipport:
        movzx eax,dl
        ror edx,8
	call value2ascii
	mov al,','
	stosb
        loop .decimal
	mov dword [edi-1], (10<<8) | ")"

	call send_data

	lea esp,[esp+7ch+4*4]

        mov edi,((PORT2&0xFF)<<24)|(((PORT2&0xFF00)>>8)<<16)
        sub ecx,ecx
        call set_sockaddr

        inc dword [esp+ecx+(7ch+4-(7ch+4+4+4+4))]
	jmp .wait4input

  .no_pasv:
	cmp_ecx_hash "LIST"
	jne near .no_list

	push ebp
	call connect_data
	jnz near .close_data_connection

        push byte __NR_open
        pop eax
        cdq
	sub ecx,ecx
	mov ebx,dword dotdot+1
        int 80h
        test eax, eax
        js .close_data_connection

        xchg eax, ebx
	sub esp,edi
	sub esp,edi
  .next_entry:
	push byte 7ch
	pop edi

	mov ecx,esp
        push byte __NR_readdir
        pop eax
        int 80h 
	dec eax
        jnz .done_search

	push ebx
        lea ebx, [esp+0ah+4h]
       
	sub esp,edi
        mov ecx,esp
        push byte __NR_stat
        pop eax
        int 80h

	mov al,'-'
	test byte [esp+9h],40h
	jz .setset
	mov al,'d'
  .setset:
	mov edx,[esp+14h]

	shl edi,2
	sub esp,edi
	mov edi,esp

	stosb

	mov esi,dword list_fmt
	push byte list_fmt_size
	pop ecx
	rep movsb

	mov eax,edx
	call value2ascii

	push byte list_fmt2_size
	pop ecx
	rep movsb

	push (5*7ch)
	pop ebx
        lea esi, [esp+0ah+4+ebx]
        movzx ecx, word [esp+8h+4+ebx]
        rep movsb
	
	push byte 10
	pop eax
	stosd

	push esp
	call send_data

	add esp,ebx
	pop ebx
	jmps .next_entry

  .done_search:
	add esp,edi
	add esp,edi
	push byte __NR_close
	pop eax
	int 80h

  .close_data_connection:
	jmp .data_exit2

  .no_list:
	cmp_hash "RETR"
	jne .no_retr

	push byte O_RDONLY
	pop ecx
	sub edx,edx
	call open
	js .js2done_error

	push ebp
	call connect_data
	jnz .jnz2data_exit2

	sub esp,edi
  .loop_read:
  	mov ecx,esp
	push edi
	pop edx
	push byte __NR_read
	pop eax
	int 80h

  	mov ecx,esp
	push byte 0
  	push eax
	push ecx
	push ebp
	mov al,SYS_SEND
	call socket_call
	add esp,byte 4*4

	xor eax,edi
	jz .loop_read
	jmps .data_exit

  .no_retr:
 	cmp_hash "STOR"
	jne .done_error

	push byte O_CREAT | O_WRONLY
	pop ecx
	mov eax,S_IRWXU
	call open
  .js2done_error:
	js .done_error

	push ebp
	call connect_data
  .jnz2data_exit2:
	jnz .data_exit2

	sub esp,edi
  .loop_write:
  	mov ecx,esp
	push byte 0
	push edi
	push ecx
	push ebp
	mov al,SYS_RECV
	call socket_call
	add esp,byte 4*4

	inc eax
	jz .data_exit
	dec eax

  	mov ecx,esp
	mov edx,eax
	push byte __NR_write
	pop eax
	int 80h

	test eax,eax
	jnz .loop_write

  .data_exit:
	add esp,byte 7ch
	push byte __NR_close
        pop eax
        int 80h

  .data_exit2:
	call close
	pop ebp
	push dword dataok
	jmps .sendinfo

  .done_error:
	push dword error
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
%ifdef 	MULTITHREAD
	jmp phdr.finish
%else
	popad
	ret
%endif


list_fmt  db "rw-rw-rw",9,"1",9,"root",9,"root",9
list_fmt_size equ $-list_fmt
list_fmt2 db 9,"Sat",9,"1",9,"0:0",9
list_fmt2_size equ $-list_fmt2

pasv	 db "227 entering passive mode ("
pasv_size equ $-pasv

root     db "/",0
welcome  db "220 ftpd",10,0
password db "331 psw",10,0
logged   db "230 logged",10,0
done  	 db "200 ok",10,0
datainit db "150 init",10,0
dataok   db "226 ok",10,0
restok   db "350 ok",10,0
error	 db "500 error",10,0	

dotdot   db "..",0

code_end   equ $

