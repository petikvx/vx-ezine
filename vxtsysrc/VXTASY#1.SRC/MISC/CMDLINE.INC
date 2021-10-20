; ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
; ³ (c) Lord Julus - 2000		 Vxtasy #1 - Magazine source code ³
; ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

; Read command line

parse_command_line proc near		   ;
		pusha			   ;
		push es ds		   ;
		push es 		   ;
		pop ds			   ;
		mov si, 80h		   ; get command line
		lodsb			   ;
		cmp al, 0		   ; isit empty?
		je no_command_line	   ;
		xor cx, cx		   ;
		mov cl, al		   ;
		dec cx			   ;
		inc si			   ;
		lea di, commandline	   ;
					   ;
		mov ax, DATA_SEGMENT	   ;
		mov es, ax		   ;
		rep movsb		   ; copy cmd line
		push es 		   ;
		pop ds			   ;
		mov byte ptr [di], 20h	   ; put some ending bytes
		mov byte ptr [di+1], 0FEh  ;
		lea si, parameters	   ; si = our parameters
		lea di, commandline	   ; di = parameters on cmdline
		mov bx, 0		   ; bx = what parameter?
					   ;
check_command_line:			   ;
		push di 		   ;
					   ;
		push di 		   ;
		mov di, si		   ;
		mov al, 0h		   ;
		mov cx, 0FFh		   ;
		repnz scasb		   ; check length of first param
		mov cx, di		   ;
		sub cx, si		   ;
		dec cx			   ;
		pop di			   ;
					   ;
		inc bx			   ;
		rep cmpsb		   ; compare it with the one input
		je found_a_parameter	   ; found?
					   ;
check_again:				   ;
		mov di, si		   ; point our next param
		mov al, 0		   ;
		mov cx, 0FFh		   ;
		repnz scasb		   ;
		mov si, di		   ;
					   ;
		pop di			   ;
					   ;
		cmp byte ptr [si], 0FEh    ; did we try all?
		je command_line_error	   ; if so, there is an invalid op.
		jmp check_command_line	   ;
					   ;
found_a_parameter:			   ; Bx = what param...
		call handle_line	   ;
		pop di			   ;
		mov al, 20h		   ;
		mov cx, 0FFh		   ;
		repnz scasb		   ; do we have any more on cmdline?
		cmp byte ptr [di], 0FEh    ;
		je finished_command_line   ; finish if no...
		push di 		   ;
		mov bx, 0		   ; restore bx=0
		jmp check_again 	   ;
					   ;
command_line_error:			   ; display error
		push cs 		   ;
		pop ds			   ;
		lea dx, command_line_msg   ;
		mov ah,09h		   ;
		int 21h 		   ;
		mov ax, 4c01h		   ;
		int 21h 		   ;
					   ;
no_command_line:			   ;
finished_command_line:			   ;
		pop ds es		   ;
		popa			   ;
		ret			   ;
parse_command_line endp 		   ;
					   ;
handle_line proc near			   ;
		pusha			   ;
		cmp bx, 4		   ;
		jbe cmd_help		   ;
		cmp bx, 6		   ;
		jbe cmd_nosound 	   ;
		jmp over_cmd_line	   ;
					   ;
cmd_help:				   ;
		lea dx, help_text	   ;
		mov ah, 09h		   ;
		int 21h 		   ;
		mov ax, 4C00h		   ;
		int 21h 		   ;
					   ;
cmd_nosound:				   ;
		mov no_sound, 1 	   ;
		jmp over_cmd_line	   ;
					   ;
over_cmd_line:				   ;
		popa			   ;
		ret			   ;
handle_line endp			   ;
					   ;
command_line_msg   db 13,10		   ;
		   db 'Invalid command line option. Type -h for help.'
                   db 13, 10, '$'          ;