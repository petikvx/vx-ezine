.386p
seg_a   segment  byte public use16
        assume   cs:seg_a, ds:seg_a
        org      100h
readmbr proc     far
start:
        mov      dx,offset logo
        call     write_t
        mov      dx,offset logo2
        call     write_t
        ;p®¢¥p¨¬ ¯®¤ ç¥¬ ¬ë ­ å®¤¨¬áï ¯®¤ Windows ¨«¨ ¯®¤ DOS
        ;‚ëå®¤: CF = 1 - DOS
        ;       CF = 0 - Windows
        call     check_windows_present
        jc       DOS
        ;®¤£®â®¢ª  ª § é¨é¥­­®¬ã p¥¦¨¬ã
        call     prepare_to_protect_mode
        jc       exit_
        ;¥p¥å®¤¨¬ ¢ § é¨é¥­­ë© p¥¦¨¬
        ;H  ¢å®¤¥ â¥p¥¡ã¥âáï ES - p¨¢ â­ë© á¥£¬¥­â ¤«ï DPMI
        mov      ax,cs
        add      ax,0500h
        mov      es,ax
        mov      ax,1
        call     DPMI_call
        jc       exit_
        ;•®p®è® ¢ § é¨é¥­­®¬ p¥¦¨¬¥, ­® ¢ p¥ «ì­®¬ «ãçè¥ :)
        push     ds
        pop      es
        call     open_RING0_16prot_function
        mov      di,offset read_mbr
        call     RING0_16prot_function
        call     close_RING0_16prot_function
        ;¥p¥å®¤¨¬ ®¡p â­® ¢ p¥ «ì­ë© p¥¦¨¬
        call     back_to_real
        call     write_to_file
        jmp      exit_
DOS:
        call     read_mbr
        call     write_to_file
exit_:
        mov      ax,4C00h
        int      21h
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
write_to_file:
        mov      ah,3Ch
        mov      dx,offset filename
        xor      cx,cx
        int      21h
        mov      bx,ax
        mov      ah,40h
        mov      cx,200h
        mov      dx,offset buffer
        int      21h
        mov      ah,3Eh
        int      21h
        retn
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
read_mbr:
        mov      di,offset buffer
        call     read_mbr_via_port
        retn
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;‚ëå®¤: CF = 1 - DOS
;       CF = 0 - Windows
check_windows_present:
        mov      di,offset buffer
        call     read_mbr_via_port
        cmp      word ptr ds:[buffer],0ffffh
        jnz      DOS_present
        clc
        retn
DOS_present:
        stc
        retn
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
logo     db 0eh,'READMBR v1.1 ş copr. (c) 98 Black Harmer',0dh,0ah,'$'
logo2    db 07h,'This programm read your MBR via ports I/O',0dh,0ah
         db     'It work correct under DOS and Windows 95/98',0dh,0ah,'$'
filename db 'MBR.DMP',0
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
include  ring0_16.asm
include  rw_mbr.asm
include  write_t.asm
include  prot16.asm
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
buffer   db 200h dup (?)
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
readmbr endp
seg_a   ends
end     start
