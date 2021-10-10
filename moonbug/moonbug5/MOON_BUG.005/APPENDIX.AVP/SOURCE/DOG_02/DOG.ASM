.8086
;*********************************************************************
;Новое поколение антивируса DocGarry *DOG*
;Версия от 13.12.95 20 вирусов  - коренная переработка DOCGARRY
;Версия от 20.12.95 31 вирус    - исправлена ошибка при выводе report
;Версия от 25.12.95 33 вируса   - включено шифрование тела антивируса
;Версия от 26.12.95 37 вирусов  - появилось самовосстановление
;Версия от 13.02.96 44 вирусов  - изменен алгоритм криптозащиты
;Версия от 04.03.96 55 вирусов  - удалено шифрование тела антивируса
;Версия от 12.03.96 67 вирусов  - удалено шифрование тела антивируса
;*********************************************************************

CSEG    segment
        assume cs:CSEG,ds:CSEG,es:CSEG

        org 100h
DOCTOR:
        jmp READ_PARAM

Ident   dw 0aabbh
        dw 0ccddh
        dw 0eeffh
IdLen equ $-Ident
;------------------------------------
TO_DOS:
        mov ah,4ch
        int 21h
;-----------------------------------
READ_PARAM:
START_CRYPTO equ $-DOCTOR
        cmp byte ptr cs:[80h],0
        je INFORM
        mov ax,ds
        mov es,ax
        cld
        mov al,'e'
        call CMP_PARAM
        je Er_Print
        mov al,'E'
        call CMP_PARAM
        je Er_Print
        jmp TESTED_Ok
Er_Print:
        inc Er_byte
TESTED_Ok:
        mov al,'o'
        call CMP_PARAM
        je Ok_Print
        mov al,'O'
        call CMP_PARAM
        je Ok_Print
        jmp TESTED_MODE
Ok_Print:
        inc Ok_byte
TESTED_MODE:
        mov al,'c'
        call CMP_PARAM
        je CURE_MODE
        mov al,'C'
        call CMP_PARAM
        je CURE_MODE
        mov al,'f'
        call CMP_PARAM
        je FIND_MODE
        mov al,'F'
        call CMP_PARAM
        je FIND_MODE
INFORM:
        lea dx,INFORMATIONS
P_MSG:
        mov ah,09h
        int 21h
        jmp TO_DOS
CURE_MODE:
        mov MODE,1
        jmp ALLOC_MEM
FIND_MODE:
        mov MODE,0
ALLOC_MEM:
        lea dx,INFORMATIONS
        mov ah,09h
        int 21h
        mov ax,ds
        mov es,ax
        mov bx,1100h
        mov ah,4ah
        int 21h
        jnc ALLOCATED
NOT_ALLOCATED:
        lea dx,NO_MEM
        jmp P_MSG
ALLOCATED:
        lea ax,LBL
        mov cl,4
        shr ax,cl
        inc ax
        mov bx,ds
        add ax,bx
        mov FSEG,ax
WORK:
        lea dx,CMASK
        call SEARCH
EXIT:
        cmp FILESI,0
        jne REPORT
        lea dx,NOT_INFECT
        mov ah,09h
        int 21h
REPORT:
        lea dx,ENTER_RET
        mov ah,09h
        int 21h
        mov al,FILEST
        mov STR_BYTE,al
        call DECODE_STRING
        lea dx,MSGT
        mov ah,09h
        int 21h
        mov al,FILESI
        mov STR_BYTE,al
        call DECODE_STRING
        lea dx,MSGI
        mov ah,09h
        int 21h
        mov al,LONG_FILE
        mov STR_BYTE,al
        call DECODE_STRING
        lea dx,MSGLONG
        mov ah,09h
        int 21h
        mov al,FILESC
        mov STR_BYTE,al
        call DECODE_STRING
        lea dx,MSGC
        jmp P_MSG
;------------------------------------------
CMP_PARAM:
        mov ch,0
        mov cl,cs:[80h]
        mov di,81h
repne   scasb
        ret
;------------------------------------------
SEARCH:
       mov cx,0ffh
       mov ah,4eh
       int 21h
       jnc STORE_FNAME
       jmp NOT_SEARCH
STORE_FNAME:
        call TESTED
        mov ah,4fh
        int 21h
        jnc STORE_FNAME
NOT_SEARCH:
        ret
;------------------------------------------
PRINT_ERROR:
        cmp Er_byte,1
        je Ok_er
        ret
Ok_Er:
        mov ah,03h
        mov bx,0
        mov cx,bx
        mov dx,cx
        int 10h
        cmp dl,0
        je p_F_N_E
        mov ah,09h
        lea dx,CLREOL
        int 21h
p_F_N_E:
        mov ah,0Eh
        mov bl,87h
        mov bh,0
        mov bx,0
LOOP_P_ERR:
        mov al,FNAME[bx]
        cmp al, 161
        je L_P_E
        int 10h
        inc bx
        jmp LOOP_P_ERR
L_P_E:
        lea dx,FILES_ERR
        mov ah,09h
        int 21h
        ret
;------------------------------------------
PRINT_OK:
        cmp Ok_Byte,1
        je Ok_Mes
        ret
Ok_Mes:
        mov ah,03h
        mov bx,0
        mov cx,bx
        mov dx,cx
        int 10h
        cmp dl,0
        je p_F_N_O
        mov ah,09h
        lea dx,CLREOL
        int 21h
p_F_N_O:
        mov ah,0Eh
        mov bl,87h
        mov bh,0
        mov bx,0
LOOP_P_OK:
        mov al,FNAME[bx]
        cmp al, 161
        je L_P_O
        int 10h
        inc bx
        jmp LOOP_P_Ok
L_P_O:
        lea dx,Ok
        mov ah,09h
        int 21h
        ret
;------------------------------------------
TESTED:
        call Clear_FNAME
        mov bx,0
NEXT_SYM:
        mov al,byte ptr cs:[bx+9eh]
        mov FNAME[bx],al
        cmp byte ptr cs:[bx+9eh],0
        je SET_ATTR
        inc bx
        cmp bx,13
        jng NEXT_SYM
        jmp OSHIBKA
SET_ATTR:
        lea dx,FNAME
        mov ax,4300h
        int 21h
        mov FATTR,cx
        mov ax,4301h
        mov cx,20h
        int 21h
OPEN_FILE:
        cmp HANDLE,0FFFFh
        je ALL_CLOSE
        call CLOSE_FILE
ALL_CLOSE:
        lea dx,FNAME
        mov ax,3d02h
        int 21h
        jc FILE_ERROR
        jmp YES_OPEN
FILE_ERROR:
        lea dx,FILES_ERR
        mov ah,09h
        int 21h
        jmp OSHIBKA
YES_OPEN:
        mov bx,ax
        mov HANDLE,ax
GET_FDATE:
        mov ax,5700h
        int 21h
        mov FDATA,dx
        mov FTIME,cx
OPEN_TARG:
        mov bx,HANDLE
        mov ax,4202h
        sub cx,cx
        mov dx,cx
        int 21h
        inc FILEST
        mov FLEN,ax
        cmp dx,0
        je SET_FSTART
        mov FLEN,0ffffh
SET_FSTART:
        mov cx,FLEN
        mov bx,57000
        cmp cx,bx
        jc TINY_FILE
        inc LONG_FILE
        call PRINT_ERROR
        jmp CLOSE_FILE
TINY_FILE:
        mov ax,4200h
        mov bx,HANDLE
        sub cx,cx
        mov dx,cx
        int 21h
READ_FILE:
        mov bx,HANDLE
        mov cx,FLEN
        mov dx,0
        cmp FLEN,8001h
        jb READ_REST
        mov cx,8000h
        push ds
        mov dx,0
        mov ax,FSEG
        mov ds,ax
        mov ah,3fh
        int 21h
        pop ds
        mov cx,FLEN
        mov dx,8000h
        sub cx,8000h
READ_REST:
        mov bx,HANDLE
        push ds
        mov ax,FSEG
        mov ds,ax
        mov ah,3fh
        int 21h
        pop ds
        jnc CHECK_SIG
        jmp CLOSE_FILE
CHECK_SIG:
        push ax
        mov ah,FILESI
        mov RESERVED[0],ah
        pop ax
        mov ONE_TESTED,0
        call VIRUS_1
        call VIRUS_2
        call VIRUS_3
        call VIRUS_4
        call VIRUS_5
        call VIRUS_6
        call VIRUS_7
        call VIRUS_8
        call VIRUS_9
        call VIRUS_10
        call VIRUS_11
        call VIRUS_12
        call VIRUS_13
        call VIRUS_14
        call VIRUS_15
        call VIRUS_16
        call VIRUS_17
        call VIRUS_18
        call VIRUS_19
        call VIRUS_20
        call VIRUS_21
        call VIRUS_22
        call VIRUS_23
        call VIRUS_24
        call VIRUS_25
        call VIRUS_26
        call VIRUS_27
        call VIRUS_28
        call VIRUS_29
        call VIRUS_30
        call VIRUS_31
        call VIRUS_32
        call VIRUS_33
        call VIRUS_34
        call VIRUS_35
        call VIRUS_36
        call VIRUS_37
        CALL VIRUS_38
        CALL VIRUS_39
        CALL VIRUS_40
        CALL VIRUS_41
        CALL VIRUS_42
        CALL VIRUS_43
        CALL VIRUS_44
        CALL VIRUS_45
        CALL VIRUS_46
        CALL VIRUS_47
        CALL VIRUS_48
        CALL VIRUS_49
        CALL VIRUS_50
        CALL VIRUS_51
        CALL VIRUS_52
        CALL VIRUS_53
        CALL VIRUS_54
        CALL VIRUS_55
        CALL VIRUS_56
        CALL VIRUS_57
        CALL VIRUS_58
        CALL VIRUS_59
        CALL VIRUS_60
        CALL VIRUS_61
        CALL VIRUS_62
        CALL VIRUS_63
        CALL VIRUS_64
        CALL VIRUS_65
        CALL VIRUS_66
;////////////////////////////////////////////////////////////////
;Сюда и нужно вставлять вызовы подпрограмм идентификации вирусов
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
        push ax
        push bx
        mov ah,FILESI
        mov bh,RESERVED[0]
        cmp ah,bh
        pop bx
        pop ax
        jne CLOSE_FILE
        call PRINT_OK
CLOSE_FILE:
        mov ax,5701h
        mov dx,FDATA
        mov cx,FTIME
        int 21h
        mov ah,3eh
        mov bx,HANDLE
        int 21h
        mov HANDLE,0FFFFh
        lea dx,FNAME
        mov ax,4301h
        mov cx,FATTR
        int 21h
OSHIBKA:
        ret
;-------------------------------------------------------------
CLEAR_FNAME:
        push ax
        push bx
        push cx
        push dx
        cld
        mov cx,12
        mov bx,0
BLANK_1:
        mov FNAME[bx],' '
        inc bx
        loop BLANK_1
        pop dx
        pop cx
        pop bx
        pop ax
        ret
;-------------------------------------------------------------
CLEAR_VIRNAM:
        push ax
        push bx
        push cx
        push dx
        cld
        mov cx,20
        mov bx,0
BLANK_2:
        mov NAMVIR[bx],' '
        inc bx
        loop BLANK_2
        pop dx
        pop cx
        pop bx
        pop ax
        ret
;-------------------------------------------------------------
INTERFACE:
        push cs
        pop ds
        mov ax,FSEG
        mov es,ax

        mov di,3
        lea si,Ident
        mov cx,IdLen
        repe cmpsb
        jne FIND_SIG
        mov di,0
        lea si,Ident3B
        mov cx,3
        repe cmpsb
        jne VIRUS_WAR
        jmp NO_SIG
VIRUS_WAR:
        lea dx, DOG_INFECTED
        mov ah,09h
        int 21h
        dec FILESI
        mov Er_byte,1
        mov Ok_byte,1
        int 20h
FIND_SIG:
        mov di,0
        cld
        mov cx,FLEN
        xor ax,ax
        mov al,SIGL
        mov ah,0
        mov al,SIG[0]
NEXT_0:
        repne scasb
        je FOUND_0
NO_SIG:
        ret
FOUND_0:
        push cx
        push di
        dec di
        mov SIG0,di
        lea SI,SIG
        push ax
        xor ax,ax
        mov al,SIGL
        mov cx,ax
        pop ax
        repe cmpsb
        je FOUND_SIG
        pop di
        pop cx
        jmp NEXT_0
FOUND_SIG:
        pop di
        pop cx
        cmp ONE_TESTED,1
        jne CURE_SIG
        jmp NO_SIG
CURE_SIG:
        inc FILESI
        mov ONE_TESTED,1
        lea dx,WARNING
        mov ah,09h
        int 21h
        cmp MODE,1
        je CURE
        jmp NO_SIG
CURE:
        push cs
        pop ds
        cmp SIG0B,0
        jne NEXT_CURE_VIR
        mov ah,09h
        lea dx,NOT_HAVE_V
        int 21h
        jmp NO_SIG
COMPLETE_BEG:
        mov ax,FLEN
        sub ax,VIRLEN
        mov SIGLB,ax
NEXT_CURE_VIR:
        cmp SIGLB,0
        JE COMPLETE_BEG
        mov bx,SIG0
        mov cx,SIG0B
        cmp SIGB,0
        je Add_SIG
        sub bx,cx
        jmp RESTORE_BEG
Add_SIG:
        add bx,cx
RESTORE_BEG:
        push cx
        push bx
        push cs
        mov bx,SIG0
        cmp SEGLEN0,0
        je add_len
        mov cx,SEGLEN
        sub bx,cx
        jmp Relate_Len
add_len:
        mov cx,SEGLEN
        add bx,cx
Relate_Len:
        mov ax,FSEG
        mov es,ax
        mov ds,ax
        mov ax,es:[bx]
        pop ds
        add ax,3
        mov FLENOLD,ax
        cmp SEGLEN,0
        jne POP_REG
        mov ax,FLEN
        sub ax,VIRLEN
        mov FLENOLD,ax
POP_REG:
        pop bx
        pop cx
        cld
        mov ax,FSEG
        mov es,ax
        mov ds,ax
        mov si,bx
        mov di,0
        push ax
        push ds
        push cs
        pop ds
        xor ax,ax
        mov ax,SIGLB
        mov cx,ax
        pop ds
        pop ax
        rep movsb
SAVE_FILE:
        push cs
        pop ds
        push cs
        pop es
        mov cx,0
        mov dx,cx
        mov bx,HANDLE
        mov ax,4200h
        int 21h
        jc POS_ERROR
        jmp NEXT_WRITE
POS_ERROR:
        mov ah,09h
        lea dx,FILES_ERR
        int 21h
        jmp NO_SIG
NEXT_WRITE:
        mov cx,FLENOLD
        mov bx,HANDLE
        mov ax,FSEG
        mov ds,ax
        sub dx,dx
        mov ah,40h
        int 21h
CUT_FILE:
        mov cx,0
        mov ah,40h
        int 21h
        push cs
        pop ds
        inc FILESC
        lea dx,CURED
        mov ah,09h
        int 21h
        jmp NO_SIG
;-------------------------------------------------------------
VIRUS_1:
        push es
        push ds
        push si
        push di
        push cs
        pop ds
        push cs
        pop es
        jmp MORNING
                            ;Сигнатура вируса
MORNING_SIG db 044h,049h,057h,020h,031h,02eh,030h
MOR_SIG_LEN equ $-MORNING_SIG         ;Длина сигнатуры
MORNING_NAM db '<MORNING STAR (COM)>' ;Название вируса (max 20 символов)
MOR_NAM_LEN equ $-MORNING_NAM         ;Длина названия вируса
MORNING_BEG equ 1                     ;0-добавлять, 1-вычитать смещение
MORNING_LEN equ 189h                  ;Длина вирусного кода
MOR_BEG_SEG equ 3                     ;Смещение начальных байт программы
MOR_BEG_LEN equ 3                     ;Кол-во начальных байт программы
MOR_SEG_LEN equ 11                    ;Смещение длины
MOR_SEG_000 equ 1                     ;Вычитать смещение длины

MORNING:
        call CLEAR_VIRNAM
        lea si,MORNING_NAM
        lea di,NAMVIR
        mov cx,MOR_NAM_LEN
        cld
        rep movsb
        lea si,MORNING_SIG
        lea di,SIG
        mov cx,MOR_SIG_LEN
        rep movsb
        mov ax,MOR_SEG_LEN
        mov SEGLEN,ax
        mov ah,MOR_SEG_000
        mov SEGLEN0,ah
        mov al,MOR_SIG_LEN
        mov SIGL,al
        mov ah,MORNING_BEG
        mov SIGB,ah
        mov ax,MORNING_LEN
        mov VIRLEN,ax
        mov ax,MOR_BEG_SEG
        mov SIG0B,ax
        mov ax,MOR_BEG_LEN
        mov SIGLB,ax
        pop di
        pop si
        pop ds
        pop es
        call INTERFACE
        ret
;-------------------------------------------------------------
VIRUS_2:
        push es
        push ds
        push si
        push di
        push cs
        pop ds
        push cs
        pop es
        jmp VESNA
                            ;Сигнатура вируса
VESNA_SIG db 0adh,0c1h,0c4h,0c5h,080h,0c9h,0ceh,080h,0b2h,0d5h
VES_SIG_LEN equ $-VESNA_SIG         ;Длина сигнатуры
VESNA_NAM db '< VESNA   (COM,EXE)>' ;Название вируса (max 20 символов)
VES_NAM_LEN equ $-VESNA_NAM         ;Длина названия вируса
VESNA_BEG equ 0                     ;0-добавлять, 1-вычитать смещение
VESNA_LEN equ 07A3h                 ;Длина вирусного кода
VES_BEG_SEG equ 708                 ;Смещение начальных байт программы
VES_BEG_LEN equ 11                  ;Кол-во начальных байт программы
VES_SEG_LEN equ 526                 ;Смещение длины
VES_SEG_000 equ 1                   ;Вычитать смещение длины

VESNA:
        call CLEAR_VIRNAM
        lea si,VESNA_NAM
        lea di,NAMVIR
        mov cx,VES_NAM_LEN
        cld
        rep movsb
        lea si,VESNA_SIG
        lea di,SIG
        mov cx,VES_SIG_LEN
        rep movsb
        mov ax,VES_SEG_LEN
        mov SEGLEN,ax
        mov ah,VES_SEG_000
        mov SEGLEN0,ah
        mov al,VES_SIG_LEN
        mov SIGL,al
        mov ah,VESNA_BEG
        mov SIGB,ah
        mov ax,VESNA_LEN
        mov VIRLEN,ax
        mov ax,VES_BEG_SEG
        mov SIG0B,ax
        mov ax,VES_BEG_LEN
        mov SIGLB,ax
        pop di
        pop si
        pop ds
        pop es
        call INTERFACE
        ret
;-------------------------------------------------------------
VIRUS_3:
        push es
        push ds
        push si
        push di
        push cs
        pop ds
        push cs
        pop es
        jmp CLIPPER
                            ;Сигнатура вируса
CLIP_SIG db 064h,062h,066h,000h,063h,06ch,069h,070h,03fh,03fh
CLP_SIG_LEN equ $-CLIP_SIG         ;Длина сигнатуры
CLIP_NAM db '<ANTI CLIPPER (COM)>'     ;Название вируса (max 20 символов)
CLP_NAM_LEN equ $-CLIP_NAM         ;Длина названия вируса
CLIP_BEG equ 1                     ;0-добавлять, 1-вычитать смещение
CLIP_LEN equ 0235h                 ;Длина вирусного кода
CLP_BEG_SEG equ 7                  ;Смещение начальных байт программы
CLP_BEG_LEN equ 3                  ;Кол-во начальных байт программы
CLP_SEG_LEN equ 15                 ;Смещение длины
CLP_SEG_000 equ 1                  ;Вычитать смещение длины

CLIPPER:
        call CLEAR_VIRNAM
        lea si,CLIP_NAM
        lea di,NAMVIR
        mov cx,CLP_NAM_LEN
        cld
        rep movsb
        lea si,CLIP_SIG
        lea di,SIG
        mov cx,CLP_SIG_LEN
        rep movsb
        mov ax,CLP_SEG_LEN
        mov SEGLEN,ax
        mov ah,CLP_SEG_000
        mov SEGLEN0,ah
        mov al,CLP_SIG_LEN
        mov SIGL,al
        mov ah,CLIP_BEG
        mov SIGB,ah
        mov ax,CLIP_LEN
        mov VIRLEN,ax
        mov ax,CLP_BEG_SEG
        mov SIG0B,ax
        mov ax,CLP_BEG_LEN
        mov SIGLB,ax
        pop di
        pop si
        pop ds
        pop es
        call INTERFACE
        ret
;-------------------------------------------------------------
VIRUS_4:
        push es
        push ds
        push si
        push di
        push cs
        pop ds
        push cs
        pop es
        jmp CLRSCR
                            ;Сигнатура вируса
CLR_SIG db 0b8h,003h,000h,050h,0b4h,02ch,0cdh,021h,080h,0fdh
CLR_SIG_LEN equ $-CLR_SIG         ;Длина сигнатуры
CLR_NAM db '<CLEAR SCREEN (COM)>'     ;Название вируса (max 20 символов)
CLR_NAM_LEN equ $-CLR_NAM         ;Длина названия вируса
CLR_BEG equ 1                     ;0-добавлять, 1-вычитать смещение
CLR_LEN equ 01ach                 ;Длина вирусного кода
CLR_BEG_SEG equ 249               ;Смещение начальных байт программы
CLR_BEG_LEN equ 3                 ;Кол-во начальных байт программы
CLR_SEG_LEN equ 257               ;Смещение длины
CLR_SEG_000 equ 1                 ;Вычитать смещение длины

CLRSCR:
        call CLEAR_VIRNAM
        lea si,CLR_NAM
        lea di,NAMVIR
        mov cx,CLR_NAM_LEN
        cld
        rep movsb
        lea si,CLR_SIG
        lea di,SIG
        mov cx,CLR_SIG_LEN
        rep movsb
        mov ax,CLR_SEG_LEN
        mov SEGLEN,ax
        mov ah,CLR_SEG_000
        mov SEGLEN0,ah
        mov al,CLR_SIG_LEN
        mov SIGL,al
        mov ah,CLR_BEG
        mov SIGB,ah
        mov ax,CLR_LEN
        mov VIRLEN,ax
        mov ax,CLR_BEG_SEG
        mov SIG0B,ax
        mov ax,CLR_BEG_LEN
        mov SIGLB,ax
        pop di
        pop si
        pop ds
        pop es
        call INTERFACE
        ret
;-------------------------------------------------------------
VIRUS_5:
        push es
        push ds
        push si
        push di
        push cs
        pop ds
        push cs
        pop es
        jmp DBFKILL
                            ;Сигнатура вируса
DBF_SIG db 02ah,02eh,064h,062h,066h,000h,05ah,0bfh,000h,001h
DBF_SIG_LEN equ $-DBF_SIG         ;Длина сигнатуры
DBF_NAM db '< DBF KILLER  (COM)>' ;Название вируса (max 20 символов)
DBF_NAM_LEN equ $-DBF_NAM         ;Длина названия вируса
DBF_BEG equ 1                     ;0-добавлять, 1-вычитать смещение
DBF_LEN equ 0182h                 ;Длина вирусного кода
DBF_BEG_SEG equ 5                 ;Смещение начальных байт программы
DBF_BEG_LEN equ 3                 ;Кол-во начальных байт программы
DBF_SEG_LEN equ 13                ;Смещение длины
DBF_SEG_000 equ 1                 ;Вычитать смещение длины

DBFKILL:
        call CLEAR_VIRNAM
        lea si,DBF_NAM
        lea di,NAMVIR
        mov cx,DBF_NAM_LEN
        cld
        rep movsb
        lea si,DBF_SIG
        lea di,SIG
        mov cx,DBF_SIG_LEN
        rep movsb
        mov ax,DBF_SEG_LEN
        mov SEGLEN,ax
        mov ah,DBF_SEG_000
        mov SEGLEN0,ah
        mov al,DBF_SIG_LEN
        mov SIGL,al
        mov ah,DBF_BEG
        mov SIGB,ah
        mov ax,DBF_LEN
        mov VIRLEN,ax
        mov ax,DBF_BEG_SEG
        mov SIG0B,ax
        mov ax,DBF_BEG_LEN
        mov SIGLB,ax
        pop di
        pop si
        pop ds
        pop es
        call INTERFACE
        ret
;-------------------------------------------------------------
VIRUS_6:
        push es
        push ds
        push si
        push di
        push cs
        pop ds
        push cs
        pop es
        jmp R1000
                            ;Сигнатура вируса
RUB_SIG db 02eh,00ah,00dh,024h,000h,00ah,00dh,087h,0a0h,0e1h
RUB_SIG_LEN equ $-RUB_SIG         ;Длина сигнатуры
RUB_NAM db '<1000 РУБЛЕЙ  (COM)>' ;Название вируса (max 20 символов)
RUB_NAM_LEN equ $-RUB_NAM         ;Длина названия вируса
RUB_BEG equ 1                     ;0-добавлять, 1-вычитать смещение
RUB_LEN equ 022bh                 ;Длина вирусного кода
RUB_BEG_SEG equ 34                ;Смещение начальных байт программы
RUB_BEG_LEN equ 3                 ;Кол-во начальных байт программы
RUB_SEG_LEN equ 42                ;Смещение длины
RUB_SEG_000 equ 1                 ;Вычитать смещение длины

R1000:
        call CLEAR_VIRNAM
        lea si,RUB_NAM
        lea di,NAMVIR
        mov cx,RUB_NAM_LEN
        cld
        rep movsb
        lea si,RUB_SIG
        lea di,SIG
        mov cx,RUB_SIG_LEN
        rep movsb
        mov ax,RUB_SEG_LEN
        mov SEGLEN,ax
        mov ah,RUB_SEG_000
        mov SEGLEN0,ah
        mov al,RUB_SIG_LEN
        mov SIGL,al
        mov ah,RUB_BEG
        mov SIGB,ah
        mov ax,RUB_LEN
        mov VIRLEN,ax
        mov ax,RUB_BEG_SEG
        mov SIG0B,ax
        mov ax,RUB_BEG_LEN
        mov SIGLB,ax
        pop di
        pop si
        pop ds
        pop es
        call INTERFACE
        ret
;-------------------------------------------------------------
VIRUS_7:
        push es
        push ds
        push si
        push di
        push cs
        pop ds
        push cs
        pop es
        jmp ELEFANT
                            ;Сигнатура вируса
ELF_SIG db 038h,039h,00ah,00dh,024h,000h,00ah,00dh,061h,062h
ELF_SIG_LEN equ $-ELF_SIG         ;Длина сигнатуры
ELF_NAM db '< ELEFANT V02 (COM)>' ;Название вируса (max 20 символов)
ELF_NAM_LEN equ $-ELF_NAM         ;Длина названия вируса
ELF_BEG equ 1                     ;0-добавлять, 1-вычитать смещение
ELF_LEN equ 0255h                 ;Длина вирусного кода
ELF_BEG_SEG equ 33                ;Смещение начальных байт программы
ELF_BEG_LEN equ 3                 ;Кол-во начальных байт программы
ELF_SEG_LEN equ 41                ;Смещение длины
ELF_SEG_000 equ 1                 ;Вычитать смещение длины

ELEFANT:
        call CLEAR_VIRNAM
        lea si,ELF_NAM
        lea di,NAMVIR
        mov cx,ELF_NAM_LEN
        cld
        rep movsb
        lea si,ELF_SIG
        lea di,SIG
        mov cx,ELF_SIG_LEN
        rep movsb
        mov ax,ELF_SEG_LEN
        mov SEGLEN,ax
        mov ah,ELF_SEG_000
        mov SEGLEN0,ah
        mov al,ELF_SIG_LEN
        mov SIGL,al
        mov ah,ELF_BEG
        mov SIGB,ah
        mov ax,ELF_LEN
        mov VIRLEN,ax
        mov ax,ELF_BEG_SEG
        mov SIG0B,ax
        mov ax,ELF_BEG_LEN
        mov SIGLB,ax
        pop di
        pop si
        pop ds
        pop es
        call INTERFACE
        ret
;-------------------------------------------------------------
VIRUS_8:
        push es
        push ds
        push si
        push di
        push cs
        pop ds
        push cs
        pop es
        jmp EXEKILLER
                            ;Сигнатура вируса
EXE_SIG db 02Ah,02Eh,065h,078h,065h,000h,05Ah,0BFh,000h,001h
EXE_SIG_LEN equ $-EXE_SIG         ;Длина сигнатуры
EXE_NAM db '<EXE - KILLER (COM)>' ;Название вируса (max 20 символов)
EXE_NAM_LEN equ $-EXE_NAM         ;Длина названия вируса
EXE_BEG equ 1                     ;0-добавлять, 1-вычитать смещение
EXE_LEN equ 0185h                 ;Длина вирусного кода
EXE_BEG_SEG equ 5                 ;Смещение начальных байт программы
EXE_BEG_LEN equ 3                 ;Кол-во начальных байт программы
EXE_SEG_LEN equ 13                ;Смещение длины
EXE_SEG_000 equ 1                 ;Вычитать смещение длины

EXEKILLER:
        call CLEAR_VIRNAM
        lea si,EXE_NAM
        lea di,NAMVIR
        mov cx,EXE_NAM_LEN
        cld
        rep movsb
        lea si,EXE_SIG
        lea di,SIG
        mov cx,EXE_SIG_LEN
        rep movsb
        mov ax,EXE_SEG_LEN
        mov SEGLEN,ax
        mov ah,EXE_SEG_000
        mov SEGLEN0,ah
        mov al,EXE_SIG_LEN
        mov SIGL,al
        mov ah,EXE_BEG
        mov SIGB,ah
        mov ax,EXE_LEN
        mov VIRLEN,ax
        mov ax,EXE_BEG_SEG
        mov SIG0B,ax
        mov ax,EXE_BEG_LEN
        mov SIGLB,ax
        pop di
        pop si
        pop ds
        pop es
        call INTERFACE
        ret
;-------------------------------------------------------------
VIRUS_9:
        push es
        push ds
        push si
        push di
        push cs
        pop ds
        push cs
        pop es
        jmp HAMLO
                            ;Сигнатура вируса
HAM_SIG db 009h,0B9h,003h,000h,0F3h,0A4h,0C3h,0CDh,062h,0C3h
HAM_SIG_LEN equ $-HAM_SIG         ;Длина сигнатуры
HAM_NAM db '<MULTI HAMLER (COM)>' ;Название вируса (max 20 символов)
HAM_NAM_LEN equ $-HAM_NAM         ;Длина названия вируса
HAM_BEG equ 1                     ;0-добавлять, 1-вычитать смещение
HAM_LEN equ 0195h                 ;Длина вирусного кода
HAM_BEG_SEG equ 466               ;Смещение начальных байт программы
HAM_BEG_LEN equ 3                 ;Кол-во начальных байт программы
HAM_SEG_LEN equ 474               ;Смещение длины
HAM_SEG_000 equ 1                 ;Вычитать смещение длины

HAMLO:
        call CLEAR_VIRNAM
        lea si,HAM_NAM
        lea di,NAMVIR
        mov cx,HAM_NAM_LEN
        cld
        rep movsb
        lea si,HAM_SIG
        lea di,SIG
        mov cx,HAM_SIG_LEN
        rep movsb
        mov ax,HAM_SEG_LEN
        mov SEGLEN,ax
        mov ah,HAM_SEG_000
        mov SEGLEN0,ah
        mov al,HAM_SIG_LEN
        mov SIGL,al
        mov ah,HAM_BEG
        mov SIGB,ah
        mov ax,HAM_LEN
        mov VIRLEN,ax
        mov ax,HAM_BEG_SEG
        mov SIG0B,ax
        mov ax,HAM_BEG_LEN
        mov SIGLB,ax
        pop di
        pop si
        pop ds
        pop es
        call INTERFACE
        ret
;-------------------------------------------------------------
VIRUS_10:
        push es
        push ds
        push si
        push di
        push cs
        pop ds
        push cs
        pop es
        jmp LOTOS
                            ;Сигнатура вируса
LOT_SIG db 02Ah,02Eh,064h,062h,066h,000h,061h,069h,064h,073h
LOT_SIG_LEN equ $-LOT_SIG         ;Длина сигнатуры
LOT_NAM db '<ANTI ANTIVIR (COM)>' ;Название вируса (max 20 символов)
LOT_NAM_LEN equ $-LOT_NAM         ;Длина названия вируса
LOT_BEG equ 1                     ;0-добавлять, 1-вычитать смещение
LOT_LEN equ 0200h                 ;Длина вирусного кода
LOT_BEG_SEG equ 5                 ;Смещение начальных байт программы
LOT_BEG_LEN equ 3                 ;Кол-во начальных байт программы
LOT_SEG_LEN equ 13                ;Смещение длины
LOT_SEG_000 equ 1                 ;Вычитать смещение длины

LOTOS:
        call CLEAR_VIRNAM
        lea si,LOT_NAM
        lea di,NAMVIR
        mov cx,LOT_NAM_LEN
        cld
        rep movsb
        lea si,LOT_SIG
        lea di,SIG
        mov cx,LOT_SIG_LEN
        rep movsb
        mov ax,LOT_SEG_LEN
        mov SEGLEN,ax
        mov ah,LOT_SEG_000
        mov SEGLEN0,ah
        mov al,LOT_SIG_LEN
        mov SIGL,al
        mov ah,LOT_BEG
        mov SIGB,ah
        mov ax,LOT_LEN
        mov VIRLEN,ax
        mov ax,LOT_BEG_SEG
        mov SIG0B,ax
        mov ax,LOT_BEG_LEN
        mov SIGLB,ax
        pop di
        pop si
        pop ds
        pop es
        call INTERFACE
        ret
;-------------------------------------------------------------
VIRUS_11:
        push es
        push ds
        push si
        push di
        push cs
        pop ds
        push cs
        pop es
        jmp MINIMAL
                            ;Сигнатура вируса
MIN_SIG db 0DDh,02Ah,02Eh,063h,06Fh,06Dh,000h
MIN_SIG_LEN equ $-MIN_SIG         ;Длина сигнатуры
MIN_NAM db '< MINIMAL 0D4 (COM)>' ;Название вируса (max 20 символов)
MIN_NAM_LEN equ $-MIN_NAM         ;Длина названия вируса
MIN_BEG equ 0                     ;0-добавлять, 1-вычитать смещение
MIN_LEN equ 00D4h                 ;Длина вирусного кода
MIN_BEG_SEG equ 7                 ;Смещение начальных байт программы
MIN_BEG_LEN equ 3                 ;Кол-во начальных байт программы
MIN_SEG_LEN equ 2                 ;Смещение длины
MIN_SEG_000 equ 1                 ;Вычитать смещение длины

MINIMAL:
        call CLEAR_VIRNAM
        lea si,MIN_NAM
        lea di,NAMVIR
        mov cx,MIN_NAM_LEN
        cld
        rep movsb
        lea si,MIN_SIG
        lea di,SIG
        mov cx,MIN_SIG_LEN
        rep movsb
        mov ax,MIN_SEG_LEN
        mov SEGLEN,ax
        mov ah,MIN_SEG_000
        mov SEGLEN0,ah
        mov al,MIN_SIG_LEN
        mov SIGL,al
        mov ah,MIN_BEG
        mov SIGB,ah
        mov ax,MIN_LEN
        mov VIRLEN,ax
        mov ax,MIN_BEG_SEG
        mov SIG0B,ax
        mov ax,MIN_BEG_LEN
        mov SIGLB,ax
        pop di
        pop si
        pop ds
        pop es
        call INTERFACE
        ret
;-------------------------------------------------------------
VIRUS_12:
        push es
        push ds
        push si
        push di
        push cs
        pop ds
        push cs
        pop es
        jmp KHIZHNJAK_BASED
                            ;Сигнатура вируса
KBV_SIG db 01Fh,0EAh,000h,001h,000h,000h,0B8h,000h,04Ch,0CDh
KBV_SIG_LEN equ $-KBV_SIG         ;Длина сигнатуры
KBV_NAM db '<HIZHNJAK VIR (COM)>' ;Название вируса (max 20 символов)
KBV_NAM_LEN equ $-KBV_NAM         ;Длина названия вируса
KBV_BEG equ 0                     ;0-добавлять, 1-вычитать смещение
KBV_LEN equ 0775h                 ;Длина вирусного кода
KBV_BEG_SEG equ 39                ;Смещение начальных байт программы
KBV_BEG_LEN equ 3                 ;Кол-во начальных байт программы
KBV_SEG_LEN equ 30                ;Смещение длины
KBV_SEG_000 equ 0                 ;Вычитать смещение длины

KHIZHNJAK_BASED:
        call CLEAR_VIRNAM
        lea si,KBV_NAM
        lea di,NAMVIR
        mov cx,KBV_NAM_LEN
        cld
        rep movsb
        lea si,KBV_SIG
        lea di,SIG
        mov cx,KBV_SIG_LEN
        rep movsb
        mov ax,KBV_SEG_LEN
        mov SEGLEN,ax
        mov ah,KBV_SEG_000
        mov SEGLEN0,ah
        mov al,KBV_SIG_LEN
        mov SIGL,al
        mov ah,KBV_BEG
        mov SIGB,ah
        mov ax,KBV_LEN
        mov VIRLEN,ax
        mov ax,KBV_BEG_SEG
        mov SIG0B,ax
        mov ax,KBV_BEG_LEN
        mov SIGLB,ax
        pop di
        pop si
        pop ds
        pop es
        call INTERFACE
        ret
;-------------------------------------------------------------
VIRUS_13:
        push es
        push ds
        push si
        push di
        push cs
        pop ds
        push cs
        pop es
        jmp VIRUSOFT_INC
                            ;Сигнатура вируса
VSI_SIG db 06Ah,06Dh,0B5h,0D3h,0C5h,0D2h,080h,0B0h,0A3h,080h
VSI_SIG_LEN equ $-VSI_SIG         ;Длина сигнатуры
VSI_NAM db '<VIRUSOFT Inc (COM)>' ;Название вируса (max 20 символов)
VSI_NAM_LEN equ $-VSI_NAM         ;Длина названия вируса
VSI_BEG equ 1                     ;0-добавлять, 1-вычитать смещение
VSI_LEN equ 0258h                 ;Длина вирусного кода
VSI_BEG_SEG equ 24                ;Смещение начальных байт программы
VSI_BEG_LEN equ 3                 ;Кол-во начальных байт программы
VSI_SEG_LEN equ 32                ;Смещение длины
VSI_SEG_000 equ 1                 ;Вычитать смещение длины

VIRUSOFT_INC:
        call CLEAR_VIRNAM
        lea si,VSI_NAM
        lea di,NAMVIR
        mov cx,VSI_NAM_LEN
        cld
        rep movsb
        lea si,VSI_SIG
        lea di,SIG
        mov cx,VSI_SIG_LEN
        rep movsb
        mov ax,VSI_SEG_LEN
        mov SEGLEN,ax
        mov ah,VSI_SEG_000
        mov SEGLEN0,ah
        mov al,VSI_SIG_LEN
        mov SIGL,al
        mov ah,VSI_BEG
        mov SIGB,ah
        mov ax,VSI_LEN
        mov VIRLEN,ax
        mov ax,VSI_BEG_SEG
        mov SIG0B,ax
        mov ax,VSI_BEG_LEN
        mov SIGLB,ax
        pop di
        pop si
        pop ds
        pop es
        call INTERFACE
        ret
;-------------------------------------------------------------
VIRUS_14:
        push es
        push ds
        push si
        push di
        push cs
        pop ds
        push cs
        pop es
        jmp HAPPY_VIR
                            ;Сигнатура вируса
HAP_SIG db 06Ah,06Dh,0B4h,0B9h,0B0h,0A5h,080h,022h,048h,041h
HAP_SIG_LEN equ $-HAP_SIG         ;Длина сигнатуры
HAP_NAM db '<HAPPY FRIDAY (COM)>' ;Название вируса (max 20 символов)
HAP_NAM_LEN equ $-HAP_NAM         ;Длина названия вируса
HAP_BEG equ 0                     ;0-добавлять, 1-вычитать смещение
HAP_LEN equ 0727h                 ;Длина вирусного кода
HAP_BEG_SEG equ 429               ;Смещение начальных байт программы
HAP_BEG_LEN equ 11                ;Кол-во начальных байт программы
HAP_SEG_LEN equ 1065              ;Смещение длины
HAP_SEG_000 equ 1                 ;Вычитать смещение длины

HAPPY_VIR:
        call CLEAR_VIRNAM
        lea si,HAP_NAM
        lea di,NAMVIR
        mov cx,HAP_NAM_LEN
        cld
        rep movsb
        lea si,HAP_SIG
        lea di,SIG
        mov cx,HAP_SIG_LEN
        rep movsb
        mov ax,HAP_SEG_LEN
        mov SEGLEN,ax
        mov ah,HAP_SEG_000
        mov SEGLEN0,ah
        mov al,HAP_SIG_LEN
        mov SIGL,al
        mov ah,HAP_BEG
        mov SIGB,ah
        mov ax,HAP_LEN
        mov VIRLEN,ax
        mov ax,HAP_BEG_SEG
        mov SIG0B,ax
        mov ax,HAP_BEG_LEN
        mov SIGLB,ax
        pop di
        pop si
        pop ds
        pop es
        call INTERFACE
        ret
;-------------------------------------------------------------
VIRUS_15:
        push es
        push ds
        push si
        push di
        push cs
        pop ds
        push cs
        pop es
        jmp SUPER_VIR
                            ;Сигнатура вируса
SPV_SIG db 06Ah,06Dh,080h,080h,0A6h,0D2h,0C9h,0C4h,0C1h,0D9h
SPV_SIG_LEN equ $-SPV_SIG         ;Длина сигнатуры
SPV_NAM db '<FRIDAY 13th  (COM)>' ;Название вируса (max 20 символов)
SPV_NAM_LEN equ $-SPV_NAM         ;Длина названия вируса
SPV_BEG equ 1                     ;0-добавлять, 1-вычитать смещение
SPV_LEN equ 03E8h                 ;Длина вирусного кода
SPV_BEG_SEG equ 29                ;Смещение начальных байт программы
SPV_BEG_LEN equ 3                 ;Кол-во начальных байт программы
SPV_SEG_LEN equ 37                ;Смещение длины
SPV_SEG_000 equ 1                 ;Вычитать смещение длины

SUPER_VIR:
        call CLEAR_VIRNAM
        lea si,SPV_NAM
        lea di,NAMVIR
        mov cx,SPV_NAM_LEN
        cld
        rep movsb
        lea si,SPV_SIG
        lea di,SIG
        mov cx,SPV_SIG_LEN
        rep movsb
        mov ax,SPV_SEG_LEN
        mov SEGLEN,ax
        mov ah,SPV_SEG_000
        mov SEGLEN0,ah
        mov al,SPV_SIG_LEN
        mov SIGL,al
        mov ah,SPV_BEG
        mov SIGB,ah
        mov ax,SPV_LEN
        mov VIRLEN,ax
        mov ax,SPV_BEG_SEG
        mov SIG0B,ax
        mov ax,SPV_BEG_LEN
        mov SIGLB,ax
        pop di
        pop si
        pop ds
        pop es
        call INTERFACE
        ret
;-------------------------------------------------------------
VIRUS_16:
        push es
        push ds
        push si
        push di
        push cs
        pop ds
        push cs
        pop es
        jmp AIDS_VIR
                            ;Сигнатура вируса
APV_SIG db 0B4h,03Bh,02Eh,088h,065h,014h,0B4h,052h,02Eh,088h
APV_SIG_LEN equ $-APV_SIG         ;Длина сигнатуры
APV_NAM db '<Tula *AIDS*  (COM)>' ;Название вируса (max 20 символов)
APV_NAM_LEN equ $-APV_NAM         ;Длина названия вируса
APV_BEG equ 1                     ;0-добавлять, 1-вычитать смещение
APV_LEN equ 0279h                 ;Длина вирусного кода
APV_BEG_SEG equ 579               ;Смещение начальных байт программы
APV_BEG_LEN equ 3                 ;Кол-во начальных байт программы
APV_SEG_LEN equ 587               ;Смещение длины
APV_SEG_000 equ 1                 ;Вычитать смещение длины

AIDS_VIR:
        call CLEAR_VIRNAM
        lea si,APV_NAM
        lea di,NAMVIR
        mov cx,APV_NAM_LEN
        cld
        rep movsb
        lea si,APV_SIG
        lea di,SIG
        mov cx,APV_SIG_LEN
        rep movsb
        mov ax,APV_SEG_LEN
        mov SEGLEN,ax
        mov ah,APV_SEG_000
        mov SEGLEN0,ah
        mov al,APV_SIG_LEN
        mov SIGL,al
        mov ah,APV_BEG
        mov SIGB,ah
        mov ax,APV_LEN
        mov VIRLEN,ax
        mov ax,APV_BEG_SEG
        mov SIG0B,ax
        mov ax,APV_BEG_LEN
        mov SIGLB,ax
        pop di
        pop si
        pop ds
        pop es
        call INTERFACE
        ret
;-------------------------------------------------------------
VIRUS_17:
        push es
        push ds
        push si
        push di
        push cs
        pop ds
        push cs
        pop es
        jmp SHORT_VIR
                            ;Сигнатура вируса
SRT_SIG db 047h,04Bh,080h,08Ch,08Ah,01Dh,080h,085h,047h,04Bh
SRT_SIG_LEN equ $-SRT_SIG         ;Длина сигнатуры
SRT_NAM db '<RESTART  (COM,EXE)>' ;Название вируса (max 20 символов)
SRT_NAM_LEN equ $-SRT_NAM         ;Длина названия вируса
SRT_BEG equ 0                     ;0-добавлять, 1-вычитать смещение
SRT_LEN equ 05E9h                 ;Длина вирусного кода
SRT_BEG_SEG equ 1091              ;Смещение начальных байт программы
SRT_BEG_LEN equ 11                ;Кол-во начальных байт программы
SRT_SEG_LEN equ 1494              ;Смещение длины
SRT_SEG_000 equ 0                 ;Вычитать смещение длины

SHORT_VIR:
        call CLEAR_VIRNAM
        lea si,SRT_NAM
        lea di,NAMVIR
        mov cx,SRT_NAM_LEN
        cld
        rep movsb
        lea si,SRT_SIG
        lea di,SIG
        mov cx,SRT_SIG_LEN
        rep movsb
        mov ax,SRT_SEG_LEN
        mov SEGLEN,ax
        mov ah,SRT_SEG_000
        mov SEGLEN0,ah
        mov al,SRT_SIG_LEN
        mov SIGL,al
        mov ah,SRT_BEG
        mov SIGB,ah
        mov ax,SRT_LEN
        mov VIRLEN,ax
        mov ax,SRT_BEG_SEG
        mov SIG0B,ax
        mov ax,SRT_BEG_LEN
        mov SIGLB,ax
        pop di
        pop si
        pop ds
        pop es
        call INTERFACE
        ret
;-------------------------------------------------------------
VIRUS_18:
        push es
        push ds
        push si
        push di
        push cs
        pop ds
        push cs
        pop es
        jmp SEARCH377_VIR
                            ;Сигнатура вируса
S37_SIG db 0B4h,02Ch,0CDh,021h,080h,0FDh,00Fh,07Ch,034h,08Bh
S37_SIG_LEN equ $-S37_SIG         ;Длина сигнатуры
S37_NAM db '< SEARCH-377  (COM)>' ;Название вируса (max 20 символов)
S37_NAM_LEN equ $-S37_NAM         ;Длина названия вируса
S37_BEG equ 1                     ;0-добавлять, 1-вычитать смещение
S37_LEN equ 0179h                 ;Длина вирусного кода
S37_BEG_SEG equ 281               ;Смещение начальных байт программы
S37_BEG_LEN equ 3                 ;Кол-во начальных байт программы
S37_SEG_LEN equ 289               ;Смещение длины
S37_SEG_000 equ 1                 ;Вычитать смещение длины

SEARCH377_VIR:
        call CLEAR_VIRNAM
        lea si,S37_NAM
        lea di,NAMVIR
        mov cx,S37_NAM_LEN
        cld
        rep movsb
        lea si,S37_SIG
        lea di,SIG
        mov cx,S37_SIG_LEN
        rep movsb
        mov ax,S37_SEG_LEN
        mov SEGLEN,ax
        mov ah,S37_SEG_000
        mov SEGLEN0,ah
        mov al,S37_SIG_LEN
        mov SIGL,al
        mov ah,S37_BEG
        mov SIGB,ah
        mov ax,S37_LEN
        mov VIRLEN,ax
        mov ax,S37_BEG_SEG
        mov SIG0B,ax
        mov ax,S37_BEG_LEN
        mov SIGLB,ax
        pop di
        pop si
        pop ds
        pop es
        call INTERFACE
        ret
;-------------------------------------------------------------
VIRUS_19:
        push es
        push ds
        push si
        push di
        push cs
        pop ds
        push cs
        pop es
        jmp GLUP_VIR
                            ;Сигнатура вируса
GLP_SIG db 04Ch,080h,0E4h,08Eh,02Eh,08Bh,04Dh,00Eh,02Eh,08Bh
GLP_SIG_LEN equ $-GLP_SIG         ;Длина сигнатуры
GLP_NAM db '<MARAZM VIRUS (COM)>' ;Название вируса (max 20 символов)
GLP_NAM_LEN equ $-GLP_NAM         ;Длина названия вируса
GLP_BEG equ 1                     ;0-добавлять, 1-вычитать смещение
GLP_LEN equ 01BBh                 ;Длина вирусного кода
GLP_BEG_SEG equ 159               ;Смещение начальных байт программы
GLP_BEG_LEN equ 3                 ;Кол-во начальных байт программы
GLP_SEG_LEN equ 167               ;Смещение длины
GLP_SEG_000 equ 1                 ;Вычитать смещение длины

GLUP_VIR:
        call CLEAR_VIRNAM
        lea si,GLP_NAM
        lea di,NAMVIR
        mov cx,GLP_NAM_LEN
        cld
        rep movsb
        lea si,GLP_SIG
        lea di,SIG
        mov cx,GLP_SIG_LEN
        rep movsb
        mov ax,GLP_SEG_LEN
        mov SEGLEN,ax
        mov ah,GLP_SEG_000
        mov SEGLEN0,ah
        mov al,GLP_SIG_LEN
        mov SIGL,al
        mov ah,GLP_BEG
        mov SIGB,ah
        mov ax,GLP_LEN
        mov VIRLEN,ax
        mov ax,GLP_BEG_SEG
        mov SIG0B,ax
        mov ax,GLP_BEG_LEN
        mov SIGLB,ax
        pop di
        pop si
        pop ds
        pop es
        call INTERFACE
        ret
;-------------------------------------------------------------
VIRUS_20:
        push es
        push ds
        push si
        push di
        push cs
        pop ds
        push cs
        pop es
        jmp MAO_VIR
                            ;Сигнатура вируса
MAO_SIG db 047h,044h,049h,049h,042h,02Bh,047h,04Ch,04Fh,001h
MAO_SIG_LEN equ $-MAO_SIG         ;Длина сигнатуры
MAO_NAM db '< MAO (TSR,EXE,COM)>' ;Название вируса (max 20 символов)
MAO_NAM_LEN equ $-MAO_NAM         ;Длина названия вируса
MAO_BEG equ 0                     ;0-добавлять, 1-вычитать смещение
MAO_LEN equ 1465                  ;Длина вирусного кода
MAO_BEG_SEG equ 0                 ;Смещение начальных байт программы
MAO_BEG_LEN equ 0                 ;Кол-во начальных байт программы
MAO_SEG_LEN equ 0                 ;Смещение длины
MAO_SEG_000 equ 0                 ;Вычитать смещение длины

MAO_VIR:
        call CLEAR_VIRNAM
        lea si,MAO_NAM
        lea di,NAMVIR
        mov cx,MAO_NAM_LEN
        cld
        rep movsb
        lea si,MAO_SIG
        lea di,SIG
        mov cx,MAO_SIG_LEN
        rep movsb
        mov ax,MAO_SEG_LEN
        mov SEGLEN,ax
        mov ah,MAO_SEG_000
        mov SEGLEN0,ah
        mov al,MAO_SIG_LEN
        mov SIGL,al
        mov ah,MAO_BEG
        mov SIGB,ah
        mov ax,MAO_LEN
        mov VIRLEN,ax
        mov ax,MAO_BEG_SEG
        mov SIG0B,ax
        mov ax,MAO_BEG_LEN
        mov SIGLB,ax
        pop di
        pop si
        pop ds
        pop es
        call INTERFACE
        ret
;-------------------------------------------------------------
VIRUS_21:
        push es
        push ds
        push si
        push di
        push cs
        pop ds
        push cs
        pop es
        jmp HERBALIFE_VIR
                            ;Сигнатура вируса
HRB_SIG db 08Ah,08Eh,0C3h,0CFh,0CDh,060h,0C3h,09Ah,0BCh,08Ah
HRB_SIG_LEN equ $-HRB_SIG         ;Длина сигнатуры
HRB_NAM db '<HERBALIFE(COM,EXE)>' ;Название вируса (max 20 символов)
HRB_NAM_LEN equ $-HRB_NAM         ;Длина названия вируса
HRB_BEG equ 0                     ;0-добавлять, 1-вычитать смещение
HRB_LEN equ 06D9H                 ;Длина вирусного кода
HRB_BEG_SEG equ 1371              ;Смещение начальных байт программы
HRB_BEG_LEN equ 11                ;Кол-во начальных байт программы
HRB_SEG_LEN equ 32                ;Смещение длины
HRB_SEG_000 equ 0                 ;Вычитать смещение длины

HERBALIFE_VIR:
        call CLEAR_VIRNAM
        lea si,HRB_NAM
        lea di,NAMVIR
        mov cx,HRB_NAM_LEN
        cld
        rep movsb
        lea si,HRB_SIG
        lea di,SIG
        mov cx,HRB_SIG_LEN
        rep movsb
        mov ax,HRB_SEG_LEN
        mov SEGLEN,ax
        mov ah,HRB_SEG_000
        mov SEGLEN0,ah
        mov al,HRB_SIG_LEN
        mov SIGL,al
        mov ah,HRB_BEG
        mov SIGB,ah
        mov ax,HRB_LEN
        mov VIRLEN,ax
        mov ax,HRB_BEG_SEG
        mov SIG0B,ax
        mov ax,HRB_BEG_LEN
        mov SIGLB,ax
        pop di
        pop si
        pop ds
        pop es
        call INTERFACE
        ret
;-------------------------------------------------------------
VIRUS_22:
        push es
        push ds
        push si
        push di
        push cs
        pop ds
        push cs
        pop es
        jmp HERB2_VIR
                            ;Сигнатура вируса
HR2_SIG db 0A7h,0A1h,0B2h,0B2h,0B9h,00Ah,00Dh,048h,045h,052h
HR2_SIG_LEN equ $-HR2_SIG         ;Длина сигнатуры
HR2_NAM db '<HERBARY  (COM,EXE)>' ;Название вируса (max 20 символов)
HR2_NAM_LEN equ $-HR2_NAM         ;Длина названия вируса
HR2_BEG equ 0                     ;0-добавлять, 1-вычитать смещение
HR2_LEN equ 05F5H                 ;Длина вирусного кода
HR2_BEG_SEG equ 137               ;Смещение начальных байт программы
HR2_BEG_LEN equ 11                ;Кол-во начальных байт программы
HR2_SEG_LEN equ 96                ;Смещение длины
HR2_SEG_000 equ 0                 ;Вычитать смещение длины

HERB2_VIR:
        call CLEAR_VIRNAM
        lea si,HR2_NAM
        lea di,NAMVIR
        mov cx,HR2_NAM_LEN
        cld
        rep movsb
        lea si,HR2_SIG
        lea di,SIG
        mov cx,HR2_SIG_LEN
        rep movsb
        mov ax,HR2_SEG_LEN
        mov SEGLEN,ax
        mov ah,HR2_SEG_000
        mov SEGLEN0,ah
        mov al,HR2_SIG_LEN
        mov SIGL,al
        mov ah,HR2_BEG
        mov SIGB,ah
        mov ax,HR2_LEN
        mov VIRLEN,ax
        mov ax,HR2_BEG_SEG
        mov SIG0B,ax
        mov ax,HR2_BEG_LEN
        mov SIGLB,ax
        pop di
        pop si
        pop ds
        pop es
        call INTERFACE
        ret
;-------------------------------------------------------------
VIRUS_23:
        push es
        push ds
        push si
        push di
        push cs
        pop ds
        push cs
        pop es
        jmp ALEX_K_VIR
                            ;Сигнатура вируса
ARK_SIG db 02Ah,054h,055h,04Ch,041h,02Ah,064h,069h,02Bh,02Fh
ARK_SIG_LEN equ $-ARK_SIG         ;Длина сигнатуры
ARK_NAM db '<RUS. KILLER  (COM)>' ;Название вируса (max 20 символов)
ARK_NAM_LEN equ $-ARK_NAM         ;Длина названия вируса
ARK_BEG equ 1                     ;0-добавлять, 1-вычитать смещение
ARK_LEN equ 1000                  ;Длина вирусного кода
ARK_BEG_SEG equ 11                ;Смещение начальных байт программы
ARK_BEG_LEN equ 3                 ;Кол-во начальных байт программы
ARK_SEG_LEN equ 19                ;Смещение длины
ARK_SEG_000 equ 1                 ;Вычитать смещение длины

ALEX_K_VIR:
        call CLEAR_VIRNAM
        lea si,ARK_NAM
        lea di,NAMVIR
        mov cx,ARK_NAM_LEN
        cld
        rep movsb
        lea si,ARK_SIG
        lea di,SIG
        mov cx,ARK_SIG_LEN
        rep movsb
        mov ax,ARK_SEG_LEN
        mov SEGLEN,ax
        mov ah,ARK_SEG_000
        mov SEGLEN0,ah
        mov al,ARK_SIG_LEN
        mov SIGL,al
        mov ah,ARK_BEG
        mov SIGB,ah
        mov ax,ARK_LEN
        mov VIRLEN,ax
        mov ax,ARK_BEG_SEG
        mov SIG0B,ax
        mov ax,ARK_BEG_LEN
        mov SIGLB,ax
        pop di
        pop si
        pop ds
        pop es
        call INTERFACE
        ret
;-------------------------------------------------------------
VIRUS_24:
        push es
        push ds
        push si
        push di
        push cs
        pop ds
        push cs
        pop es
        jmp ANDROMEDA_VIR
                            ;Сигнатура вируса
AND_SIG db 0CDh,013h,0B8h,000h,001h,050h,0C3h,0B4h,02Ah,02Eh
AND_SIG_LEN equ $-AND_SIG         ;Длина сигнатуры
AND_NAM db '< ANDROMEDA   (COM)>' ;Название вируса (max 20 символов)
AND_NAM_LEN equ $-AND_NAM         ;Длина названия вируса
AND_BEG equ 0                     ;0-добавлять, 1-вычитать смещение
AND_LEN equ 478                   ;Длина вирусного кода
AND_BEG_SEG equ 0EH               ;Смещение начальных байт программы
AND_BEG_LEN equ 3                 ;Кол-во начальных байт программы
AND_SEG_LEN equ 20                ;Смещение длины
AND_SEG_000 equ 0                 ;Вычитать смещение длины

ANDROMEDA_VIR:
        call CLEAR_VIRNAM
        lea si,AND_NAM
        lea di,NAMVIR
        mov cx,AND_NAM_LEN
        cld
        rep movsb
        lea si,AND_SIG
        lea di,SIG
        mov cx,AND_SIG_LEN
        rep movsb
        mov ax,AND_SEG_LEN
        mov SEGLEN,ax
        mov ah,AND_SEG_000
        mov SEGLEN0,ah
        mov al,AND_SIG_LEN
        mov SIGL,al
        mov ah,AND_BEG
        mov SIGB,ah
        mov ax,AND_LEN
        mov VIRLEN,ax
        mov ax,AND_BEG_SEG
        mov SIG0B,ax
        mov ax,AND_BEG_LEN
        mov SIGLB,ax
        pop di
        pop si
        pop ds
        pop es
        call INTERFACE
        ret
;-------------------------------------------------------------
VIRUS_25:
        push es
        push ds
        push si
        push di
        push cs
        pop ds
        push cs
        pop es
        jmp KRANTY_VIR
                            ;Сигнатура вируса
KR8_SIG db 0B8h,000h,001h,050h,0C3h,08Ah,0E0h,0A0h,0ADh,0E2h
KR8_SIG_LEN equ $-KR8_SIG         ;Длина сигнатуры
KR8_NAM db '< KRANTY - 8  (COM)>' ;Название вируса (max 20 символов)
KR8_NAM_LEN equ $-KR8_NAM         ;Длина названия вируса
KR8_BEG equ 0                     ;0-добавлять, 1-вычитать смещение
KR8_LEN equ 255                   ;Длина вирусного кода
KR8_BEG_SEG equ 14                ;Смещение начальных байт программы
KR8_BEG_LEN equ 3                 ;Кол-во начальных байт программы
KR8_SEG_LEN equ 0;1237              ;Смещение длины
KR8_SEG_000 equ 0;1                 ;Вычитать смещение длины

KRANTY_VIR:
        call CLEAR_VIRNAM
        lea si,KR8_NAM
        lea di,NAMVIR
        mov cx,KR8_NAM_LEN
        cld
        rep movsb
        lea si,KR8_SIG
        lea di,SIG
        mov cx,KR8_SIG_LEN
        rep movsb
        mov ax,KR8_SEG_LEN
        mov SEGLEN,ax
        mov ah,KR8_SEG_000
        mov SEGLEN0,ah
        mov al,KR8_SIG_LEN
        mov SIGL,al
        mov ah,KR8_BEG
        mov SIGB,ah
        mov ax,KR8_LEN
        mov VIRLEN,ax
        mov ax,KR8_BEG_SEG
        mov SIG0B,ax
        mov ax,KR8_BEG_LEN
        mov SIGLB,ax
        pop di
        pop si
        pop ds
        pop es
        call INTERFACE
        ret
;-------------------------------------------------------------
VIRUS_26:
        push es
        push ds
        push si
        push di
        push cs
        pop ds
        push cs
        pop es
        jmp DIEHARD2_VIR
                            ;Сигнатура вируса
DH2_SIG db 0FDh,0ABh,08Bh,0C3h,0B1h,004h,0D3h,0E8h,040h,08Ch
DH2_SIG_LEN equ $-DH2_SIG         ;Длина сигнатуры
DH2_NAM db '<SAYHA DIEHARD(TSR)>' ;Название вируса (max 20 символов)
DH2_NAM_LEN equ $-DH2_NAM         ;Длина названия вируса
DH2_BEG equ 0                     ;0-добавлять, 1-вычитать смещение
DH2_LEN equ 0                     ;Длина вирусного кода
DH2_BEG_SEG equ 0                 ;Смещение начальных байт программы
DH2_BEG_LEN equ 0                 ;Кол-во начальных байт программы
DH2_SEG_LEN equ 0                   ;Смещение длины
DH2_SEG_000 equ 0                   ;Вычитать смещение длины

DIEHARD2_VIR:
        call CLEAR_VIRNAM
        lea si,DH2_NAM
        lea di,NAMVIR
        mov cx,DH2_NAM_LEN
        cld
        rep movsb
        lea si,DH2_SIG
        lea di,SIG
        mov cx,DH2_SIG_LEN
        rep movsb
        mov ax,DH2_SEG_LEN
        mov SEGLEN,ax
        mov ah,DH2_SEG_000
        mov SEGLEN0,ah
        mov al,DH2_SIG_LEN
        mov SIGL,al
        mov ah,DH2_BEG
        mov SIGB,ah
        mov ax,DH2_LEN
        mov VIRLEN,ax
        mov ax,DH2_BEG_SEG
        mov SIG0B,ax
        mov ax,DH2_BEG_LEN
        mov SIGLB,ax
        pop di
        pop si
        pop ds
        pop es
        call INTERFACE
        ret
;-------------------------------------------------------------
VIRUS_27:
        push es
        push ds
        push si
        push di
        push cs
        pop ds
        push cs
        pop es
        jmp MsDos_VIR
                            ;Сигнатура вируса
MDJ_SIG db 073h,055h,04dh,073h,044h,06Fh,073h,000h,001h
MDJ_SIG_LEN equ $-MDJ_SIG         ;Длина сигнатуры
MDJ_NAM db '< JERUSALEM   (TSR)>' ;Название вируса (max 20 символов)
MDJ_NAM_LEN equ $-MDJ_NAM         ;Длина названия вируса
MDJ_BEG equ 0                     ;0-добавлять, 1-вычитать смещение
MDJ_LEN equ 1808                  ;Длина вирусного кода
MDJ_BEG_SEG equ 1805              ;Смещение начальных байт программы
MDJ_BEG_LEN equ 0                 ;Кол-во начальных байт программы
MDJ_SEG_LEN equ 14                ;Смещение длины
MDJ_SEG_000 equ 0                 ;Вычитать смещение длины

MsDos_VIR:
        call CLEAR_VIRNAM
        lea si,MDJ_NAM
        lea di,NAMVIR
        mov cx,MDJ_NAM_LEN
        cld
        rep movsb
        lea si,MDJ_SIG
        lea di,SIG
        mov cx,MDJ_SIG_LEN
        rep movsb
        mov ax,MDJ_SEG_LEN
        mov SEGLEN,ax
        mov ah,MDJ_SEG_000
        mov SEGLEN0,ah
        mov al,MDJ_SIG_LEN
        mov SIGL,al
        mov ah,MDJ_BEG
        mov SIGB,ah
        mov ax,MDJ_LEN
        mov VIRLEN,ax
        mov ax,MDJ_BEG_SEG
        mov SIG0B,ax
        mov ax,MDJ_BEG_LEN
        mov SIGLB,ax
        pop di
        pop si
        pop ds
        pop es
        call INTERFACE
        ret
;-------------------------------------------------------------
VIRUS_28:
        push es
        push ds
        push si
        push di
        push cs
        pop ds
        push cs
        pop es
        jmp KhiMy_VIR
                            ;Сигнатура вируса
KMV_SIG db 083h,0C2h,00Eh,0CDh,021h,0BBh,000h,001h,0FFh,0E3h
KMV_SIG_LEN equ $-KMV_SIG         ;Длина сигнатуры
KMV_NAM db '<HIZHNJAK MIN (COM)>' ;Название вируса (max 20 символов)
KMV_NAM_LEN equ $-KMV_NAM         ;Длина названия вируса
KMV_BEG equ 1                     ;0-добавлять, 1-вычитать смещение
KMV_LEN equ 297                   ;Длина вирусного кода
KMV_BEG_SEG equ 281               ;Смещение начальных байт программы
KMV_BEG_LEN equ 4                 ;Кол-во начальных байт программы
KMV_SEG_LEN equ 283               ;Смещение длины
KMV_SEG_000 equ 1                 ;Вычитать смещение длины

KhiMy_VIR:
        call CLEAR_VIRNAM
        lea si,KMV_NAM
        lea di,NAMVIR
        mov cx,KMV_NAM_LEN
        cld
        rep movsb
        lea si,KMV_SIG
        lea di,SIG
        mov cx,KMV_SIG_LEN
        rep movsb
        mov ax,KMV_SEG_LEN
        mov SEGLEN,ax
        mov ah,KMV_SEG_000
        mov SEGLEN0,ah
        mov al,KMV_SIG_LEN
        mov SIGL,al
        mov ah,KMV_BEG
        mov SIGB,ah
        mov ax,KMV_LEN
        mov VIRLEN,ax
        mov ax,KMV_BEG_SEG
        mov SIG0B,ax
        mov ax,KMV_BEG_LEN
        mov SIGLB,ax
        pop di
        pop si
        pop ds
        pop es
        call INTERFACE
        ret
;-------------------------------------------------------------
VIRUS_29:
        push es
        push ds
        push si
        push di
        push cs
        pop ds
        push cs
        pop es
        jmp S432_VIR
                            ;Сигнатура вируса
VSA_SIG db 000h,0B2h,080h,0CDh,013h,0B8h,000h,001h,050h,0C3h
VSA_SIG_LEN equ $-VSA_SIG         ;Длина сигнатуры
VSA_NAM db '<SEARCH - 432 (COM)>' ;Название вируса (max 20 символов)
VSA_NAM_LEN equ $-VSA_NAM         ;Длина названия вируса
VSA_BEG equ 0                     ;0-добавлять, 1-вычитать смещение
VSA_LEN equ 432                   ;Длина вирусного кода
VSA_BEG_SEG equ 17                ;Смещение начальных байт программы
VSA_BEG_LEN equ 3                 ;Кол-во начальных байт программы
VSA_SEG_LEN equ 0                 ;Смещение длины
VSA_SEG_000 equ 0                 ;Вычитать смещение длины

S432_VIR:
        call CLEAR_VIRNAM
        lea si,VSA_NAM
        lea di,NAMVIR
        mov cx,VSA_NAM_LEN
        cld
        rep movsb
        lea si,VSA_SIG
        lea di,SIG
        mov cx,VSA_SIG_LEN
        rep movsb
        mov ax,VSA_SEG_LEN
        mov SEGLEN,ax
        mov ah,VSA_SEG_000
        mov SEGLEN0,ah
        mov al,VSA_SIG_LEN
        mov SIGL,al
        mov ah,VSA_BEG
        mov SIGB,ah
        mov ax,VSA_LEN
        mov VIRLEN,ax
        mov ax,VSA_BEG_SEG
        mov SIG0B,ax
        mov ax,VSA_BEG_LEN
        mov SIGLB,ax
        pop di
        pop si
        pop ds
        pop es
        call INTERFACE
        ret
;-------------------------------------------------------------
VIRUS_30:
        push es
        push ds
        push si
        push di
        push cs
        pop ds
        push cs
        pop es
        jmp MUSIC_VIR
                            ;Сигнатура вируса
JDV_SIG db 0E8h,000h,000h,05Bh,081h,0EBh,0D4h,007h,02Eh,0C6h
JDV_SIG_LEN equ $-JDV_SIG         ;Длина сигнатуры
JDV_NAM db '<JANKE DOODLE (TSR)>' ;Название вируса (max 20 символов)
JDV_NAM_LEN equ $-JDV_NAM         ;Длина названия вируса
JDV_BEG equ 0                     ;0-добавлять, 1-вычитать смещение
JDV_LEN equ 0                     ;Длина вирусного кода
JDV_BEG_SEG equ 0                 ;Смещение начальных байт программы
JDV_BEG_LEN equ 0                 ;Кол-во начальных байт программы
JDV_SEG_LEN equ 0                 ;Смещение длины
JDV_SEG_000 equ 0                 ;Вычитать смещение длины

MUSIC_VIR:
        call CLEAR_VIRNAM
        lea si,JDV_NAM
        lea di,NAMVIR
        mov cx,JDV_NAM_LEN
        cld
        rep movsb
        lea si,JDV_SIG
        lea di,SIG
        mov cx,JDV_SIG_LEN
        rep movsb
        mov ax,JDV_SEG_LEN
        mov SEGLEN,ax
        mov ah,JDV_SEG_000
        mov SEGLEN0,ah
        mov al,JDV_SIG_LEN
        mov SIGL,al
        mov ah,JDV_BEG
        mov SIGB,ah
        mov ax,JDV_LEN
        mov VIRLEN,ax
        mov ax,JDV_BEG_SEG
        mov SIG0B,ax
        mov ax,JDV_BEG_LEN
        mov SIGLB,ax
        pop di
        pop si
        pop ds
        pop es
        call INTERFACE
        ret
;-------------------------------------------------------------
VIRUS_31:
        push es
        push ds
        push si
        push di
        push cs
        pop ds
        push cs
        pop es
        jmp OMSK_VIR
                            ;Сигнатура вируса
BFV_SIG db 000h,022h,0CDh,013h,072h,003h,0E9h,071h,002h,0C6h
BFV_SIG_LEN equ $-BFV_SIG         ;Длина сигнатуры
BFV_NAM db '<OMSK FORMAT  (TSR)>' ;Название вируса (max 20 символов)
BFV_NAM_LEN equ $-BFV_NAM         ;Длина названия вируса
BFV_BEG equ 0                     ;0-добавлять, 1-вычитать смещение
BFV_LEN equ 0                     ;Длина вирусного кода
BFV_BEG_SEG equ 0                 ;Смещение начальных байт программы
BFV_BEG_LEN equ 0                 ;Кол-во начальных байт программы
BFV_SEG_LEN equ 0                 ;Смещение длины
BFV_SEG_000 equ 0                 ;Вычитать смещение длины

OMSK_VIR:
        call CLEAR_VIRNAM
        lea si,BFV_NAM
        lea di,NAMVIR
        mov cx,BFV_NAM_LEN
        cld
        rep movsb
        lea si,BFV_SIG
        lea di,SIG
        mov cx,BFV_SIG_LEN
        rep movsb
        mov ax,BFV_SEG_LEN
        mov SEGLEN,ax
        mov ah,BFV_SEG_000
        mov SEGLEN0,ah
        mov al,BFV_SIG_LEN
        mov SIGL,al
        mov ah,BFV_BEG
        mov SIGB,ah
        mov ax,BFV_LEN
        mov VIRLEN,ax
        mov ax,BFV_BEG_SEG
        mov SIG0B,ax
        mov ax,BFV_BEG_LEN
        mov SIGLB,ax
        pop di
        pop si
        pop ds
        pop es
        call INTERFACE
        ret
;-------------------------------------------------------------
VIRUS_32:
        push es
        push ds
        push si
        push di
        push cs
        pop ds
        push cs
        pop es
        jmp SillyRC143
                            ;Сигнатура вируса
SRC_SIG db 0A5h,0A5h,0B2h,03Ah,01Fh,0B8h,021h,025h,0CDh,021h
SRC_SIG_LEN equ $-SRC_SIG         ;Длина сигнатуры
SRC_NAM db '<SILLYRC 143  (TSR)>' ;Название вируса (max 20 символов)
SRC_NAM_LEN equ $-SRC_NAM         ;Длина названия вируса
SRC_BEG equ 1                     ;0-добавлять, 1-вычитать смещение
SRC_LEN equ 08FH                  ;Длина вирусного кода
SRC_BEG_SEG equ 45                ;Смещение начальных байт программы
SRC_BEG_LEN equ 4                 ;Кол-во начальных байт программы
SRC_SEG_LEN equ 0                 ;Смещение длины
SRC_SEG_000 equ 0                 ;Вычитать смещение длины

SillyRC143:
        call CLEAR_VIRNAM
        lea si,SRC_NAM
        lea di,NAMVIR
        mov cx,SRC_NAM_LEN
        cld
        rep movsb
        lea si,SRC_SIG
        lea di,SIG
        mov cx,SRC_SIG_LEN
        rep movsb
        mov ax,SRC_SEG_LEN
        mov SEGLEN,ax
        mov ah,SRC_SEG_000
        mov SEGLEN0,ah
        mov al,SRC_SIG_LEN
        mov SIGL,al
        mov ah,SRC_BEG
        mov SIGB,ah
        mov ax,SRC_LEN
        mov VIRLEN,ax
        mov ax,SRC_BEG_SEG
        mov SIG0B,ax
        mov ax,SRC_BEG_LEN
        mov SIGLB,ax
        pop di
        pop si
        pop ds
        pop es
        call INTERFACE
        ret
;-------------------------------------------------------------
VIRUS_33:
        push es
        push ds
        push si
        push di
        push cs
        pop ds
        push cs
        pop es
        jmp EXE13
                            ;Сигнатура вируса
E13_SIG db 081h,07Dh,003h,049h,044h,075h,016h,0EBh,045h,090h
E13_SIG_LEN equ $-E13_SIG         ;Длина сигнатуры
E13_NAM db '<EXE KILLER 13(TSR)>' ;Название вируса (max 20 символов)
E13_NAM_LEN equ $-E13_NAM         ;Длина названия вируса
E13_BEG equ 1                     ;0-добавлять, 1-вычитать смещение
E13_LEN equ 256                   ;Длина вирусного кода
E13_BEG_SEG equ 159               ;Смещение начальных байт программы
E13_BEG_LEN equ 5                 ;Кол-во начальных байт программы
E13_SEG_LEN equ 0                 ;Смещение длины
E13_SEG_000 equ 0                 ;Вычитать смещение длины

EXE13:
        call CLEAR_VIRNAM
        lea si,E13_NAM
        lea di,NAMVIR
        mov cx,E13_NAM_LEN
        cld
        rep movsb
        lea si,E13_SIG
        lea di,SIG
        mov cx,E13_SIG_LEN
        rep movsb
        mov ax,E13_SEG_LEN
        mov SEGLEN,ax
        mov ah,E13_SEG_000
        mov SEGLEN0,ah
        mov al,E13_SIG_LEN
        mov SIGL,al
        mov ah,E13_BEG
        mov SIGB,ah
        mov ax,E13_LEN
        mov VIRLEN,ax
        mov ax,E13_BEG_SEG
        mov SIG0B,ax
        mov ax,E13_BEG_LEN
        mov SIGLB,ax
        pop di
        pop si
        pop ds
        pop es
        call INTERFACE
        ret
;-------------------------------------------------------------
VIRUS_34:
        push es
        push ds
        push si
        push di
        push cs
        pop ds
        push cs
        pop es
        jmp CHDIR783
                            ;Сигнатура вируса
CDR_SIG db 08Ah,0B0h,000h,0BFh,021h,001h,0B9h,02Bh,000h,0F3h
CDR_SIG_LEN equ $-CDR_SIG         ;Длина сигнатуры
CDR_NAM db '<ChDir783 (COM,TSR)>' ;Название вируса (max 20 символов)
CDR_NAM_LEN equ $-CDR_NAM         ;Длина названия вируса
CDR_BEG equ 1                     ;0-добавлять, 1-вычитать смещение
CDR_LEN equ 783                   ;Длина вирусного кода
CDR_BEG_SEG equ 250               ;Смещение начальных байт программы
CDR_BEG_LEN equ 6                 ;Кол-во начальных байт программы
CDR_SEG_LEN equ 0                 ;Смещение длины
CDR_SEG_000 equ 0                 ;Вычитать смещение длины

CHDIR783:
        call CLEAR_VIRNAM
        lea si,CDR_NAM
        lea di,NAMVIR
        mov cx,CDR_NAM_LEN
        cld
        rep movsb
        lea si,CDR_SIG
        lea di,SIG
        mov cx,CDR_SIG_LEN
        rep movsb
        mov ax,CDR_SEG_LEN
        mov SEGLEN,ax
        mov ah,CDR_SEG_000
        mov SEGLEN0,ah
        mov al,CDR_SIG_LEN
        mov SIGL,al
        mov ah,CDR_BEG
        mov SIGB,ah
        mov ax,CDR_LEN
        mov VIRLEN,ax
        mov ax,CDR_BEG_SEG
        mov SIG0B,ax
        mov ax,CDR_BEG_LEN
        mov SIGLB,ax
        pop di
        pop si
        pop ds
        pop es
        call INTERFACE
        ret
;-------------------------------------------------------------
VIRUS_35:
        push es
        push ds
        push si
        push di
        push cs
        pop ds
        push cs
        pop es
        jmp NATAS
                            ;Сигнатура вируса
NTS_SIG db 087h,0C3h,07Dh,0ECh,0E9h,055h,0F1h
NTS_SIG_LEN equ $-NTS_SIG         ;Длина сигнатуры
NTS_NAM db '<NATAS 4744   (TSR)>' ;Название вируса (max 20 символов)
NTS_NAM_LEN equ $-NTS_NAM         ;Длина названия вируса
NTS_BEG equ 0                     ;0-добавлять, 1-вычитать смещение
NTS_LEN equ 4744                  ;Длина вирусного кода
NTS_BEG_SEG equ 90                ;Смещение начальных байт программы
NTS_BEG_LEN equ 23                ;Кол-во начальных байт программы
NTS_SEG_LEN equ 0                 ;Смещение длины
NTS_SEG_000 equ 0                 ;Вычитать смещение длины

NATAS:
        call CLEAR_VIRNAM
        lea si,NTS_NAM
        lea di,NAMVIR
        mov cx,NTS_NAM_LEN
        cld
        rep movsb
        lea si,NTS_SIG
        lea di,SIG
        mov cx,NTS_SIG_LEN
        rep movsb
        mov ax,NTS_SEG_LEN
        mov SEGLEN,ax
        mov ah,NTS_SEG_000
        mov SEGLEN0,ah
        mov al,NTS_SIG_LEN
        mov SIGL,al
        mov ah,NTS_BEG
        mov SIGB,ah
        mov ax,NTS_LEN
        mov VIRLEN,ax
        mov ax,NTS_BEG_SEG
        mov SIG0B,ax
        mov ax,NTS_BEG_LEN
        mov SIGLB,ax
        pop di
        pop si
        pop ds
        pop es
        call INTERFACE
        ret
;-------------------------------------------------------------
VIRUS_36:
        push es
        push ds
        push si
        push di
        push cs
        pop ds
        push cs
        pop es
        jmp NUCLEAR
                            ;Сигнатура вируса
WWN_SIG db 0B8h,0FFh,051h,0CDh,021h,03Dh,051h,0FFh,074h,016h
WWN_SIG_LEN equ $-WWN_SIG         ;Длина сигнатуры
WWN_NAM db '<NUCLEAR (WIN WORD)>' ;Название вируса (max 20 символов)
WWN_NAM_LEN equ $-WWN_NAM         ;Длина названия вируса
WWN_BEG equ 0                     ;0-добавлять, 1-вычитать смещение
WWN_LEN equ 1332                  ;Длина вирусного кода
WWN_BEG_SEG equ 0                ;Смещение начальных байт программы
WWN_BEG_SEG1 equ 0               ;Смещение начальных байт программы
WWN_BEG_LEN equ 0                 ;Кол-во начальных байт программы
WWN_SEG_LEN equ 0                 ;Смещение длины
WWN_SEG_000 equ 0                 ;Вычитать смещение длины

NUCLEAR:
        call CLEAR_VIRNAM
        lea si,WWN_NAM
        lea di,NAMVIR
        mov cx,WWN_NAM_LEN
        cld
        rep movsb
        lea si,WWN_SIG
        lea di,SIG
        mov cx,WWN_SIG_LEN
        rep movsb
        mov ax,WWN_SEG_LEN
        mov SEGLEN,ax
        mov ah,WWN_SEG_000
        mov SEGLEN0,ah
        mov al,WWN_SIG_LEN
        mov SIGL,al
        mov ah,WWN_BEG
        mov SIGB,ah
        mov ax,WWN_LEN
        mov VIRLEN,ax
        mov ax,WWN_BEG_SEG
        mov SIG0B,ax
        mov ax,WWN_BEG_LEN
        mov SIGLB,ax
        pop di
        pop si
        pop ds
        pop es
        call INTERFACE
        ret
;-------------------------------------------------------------
VIRUS_37:
        push es
        push ds
        push si
        push di
        push cs
        pop ds
        push cs
        pop es
        jmp SOFIA
                            ;Сигнатура вируса
DAS_SIG db 0E8h,072h,0FDh,08Ch,0C8h,048h,04Bh,08Eh,0DBh,0F9h
DAS_SIG_LEN equ $-DAS_SIG         ;Длина сигнатуры
DAS_NAM db '<Dark Avenger (TSR)>' ;Название вируса (max 20 символов)
DAS_NAM_LEN equ $-DAS_NAM         ;Длина названия вируса
DAS_BEG equ 0                     ;0-добавлять, 1-вычитать смещение
DAS_LEN equ 1800                  ;Длина вирусного кода
DAS_BEG_SEG equ 134              ;Смещение начальных байт программы
DAS_BEG_LEN equ 3                 ;Кол-во начальных байт программы
DAS_SEG_LEN equ 0                 ;Смещение длины
DAS_SEG_000 equ 0                 ;Вычитать смещение длины

SOFIA:
        call CLEAR_VIRNAM
        lea si,DAS_NAM
        lea di,NAMVIR
        mov cx,DAS_NAM_LEN
        cld
        rep movsb
        lea si,DAS_SIG
        lea di,SIG
        mov cx,DAS_SIG_LEN
        rep movsb
        mov ax,DAS_SEG_LEN
        mov SEGLEN,ax
        mov ah,DAS_SEG_000
        mov SEGLEN0,ah
        mov al,DAS_SIG_LEN
        mov SIGL,al
        mov ah,DAS_BEG
        mov SIGB,ah
        mov ax,DAS_LEN
        mov VIRLEN,ax
        mov ax,DAS_BEG_SEG
        mov SIG0B,ax
        mov ax,DAS_BEG_LEN
        mov SIGLB,ax
        pop di
        pop si
        pop ds
        pop es
        call INTERFACE
        ret
;-------------------------------------------------------------
VIRUS_38:
        push es
        push ds
        push si
        push di
        push cs
        pop ds
        push cs
        pop es
        jmp Trojan_Short
                            ;Сигнатура вируса
TSV_SIG db 054h,05Dh,075h,03Ch,033h,0C0h,0B2h,001h,0CDh,013h
TSV_SIG_LEN equ $-TSV_SIG         ;Длина сигнатуры
TSV_NAM db '<Trojan.Short (COM)>' ;Название вируса (max 20 символов)
TSV_NAM_LEN equ $-TSV_NAM         ;Длина названия вируса
TSV_BEG equ 0                     ;0-добавлять, 1-вычитать смещение
TSV_LEN equ 106                   ;Длина вирусного кода
TSV_BEG_SEG equ 93               ;Смещение начальных байт программы
TSV_BEG_LEN equ 3                 ;Кол-во начальных байт программы
TSV_SEG_LEN equ 0                ;Смещение длины
TSV_SEG_000 equ 0                 ;Вычитать смещение длины

Trojan_Short:
        call CLEAR_VIRNAM
        lea si,TSV_NAM
        lea di,NAMVIR
        mov cx,TSV_NAM_LEN
        cld
        rep movsb
        lea si,TSV_SIG
        lea di,SIG
        mov cx,TSV_SIG_LEN
        rep movsb
        mov ax,TSV_SEG_LEN
        mov SEGLEN,ax
        mov ah,TSV_SEG_000
        mov SEGLEN0,ah
        mov al,TSV_SIG_LEN
        mov SIGL,al
        mov ah,TSV_BEG
        mov SIGB,ah
        mov ax,TSV_LEN
        mov VIRLEN,ax
        mov ax,TSV_BEG_SEG
        mov SIG0B,ax
        mov ax,TSV_BEG_LEN
        mov SIGLB,ax
        pop di
        pop si
        pop ds
        pop es
        call INTERFACE
        ret
;-------------------------------------------------------------
VIRUS_39:
        push es
        push ds
        push si
        push di
        push cs
        pop ds
        push cs
        pop es
        jmp Seat_1614
                            ;Сигнатура вируса
SEA_SIG db 001h,0BDh,04Eh,007h,03Eh,081h,07Eh,000h,04Dh,05Ah
SEA_SIG_LEN equ $-SEA_SIG         ;Длина сигнатуры
SEA_NAM db '<SEAT-1614(COM,TSR)>' ;Название вируса (max 20 символов)
SEA_NAM_LEN equ $-SEA_NAM         ;Длина названия вируса
SEA_BEG equ 0                     ;0-добавлять, 1-вычитать смещение
SEA_LEN equ 1614                  ;Длина вирусного кода
SEA_BEG_SEG equ 0                 ;Смещение начальных байт программы
SEA_BEG_LEN equ 0                 ;Кол-во начальных байт программы
SEA_SEG_LEN equ 0                 ;Смещение длины
SEA_SEG_000 equ 0                 ;Вычитать смещение длины

SEAT_1614:
        call CLEAR_VIRNAM
        lea si,SEA_NAM
        lea di,NAMVIR
        mov cx,SEA_NAM_LEN
        cld
        rep movsb
        lea si,SEA_SIG
        lea di,SIG
        mov cx,SEA_SIG_LEN
        rep movsb
        mov ax,SEA_SEG_LEN
        mov SEGLEN,ax
        mov ah,SEA_SEG_000
        mov SEGLEN0,ah
        mov al,SEA_SIG_LEN
        mov SIGL,al
        mov ah,SEA_BEG
        mov SIGB,ah
        mov ax,SEA_LEN
        mov VIRLEN,ax
        mov ax,SEA_BEG_SEG
        mov SIG0B,ax
        mov ax,SEA_BEG_LEN
        mov SIGLB,ax
        pop di
        pop si
        pop ds
        pop es
        call INTERFACE
        ret
;-------------------------------------------------------------
VIRUS_40:
        push es
        push ds
        push si
        push di
        push cs
        pop ds
        push cs
        pop es
        jmp African_109
                            ;Сигнатура вируса
AFR_SIG db 0B3h,0FCh,0C7h,007h,0ACh,0AAh,0C7h,047h,002h,0E2h
AFR_SIG_LEN equ $-AFR_SIG         ;Длина сигнатуры
AFR_NAM db '<AFRICAN-109 (COM) >' ;Название вируса (max 20 символов)
AFR_NAM_LEN equ $-AFR_NAM         ;Длина названия вируса
AFR_BEG equ 0                     ;0-добавлять, 1-вычитать смещение
AFR_LEN equ 109                   ;Длина вирусного кода
AFR_BEG_SEG equ 0                 ;Смещение начальных байт программы
AFR_BEG_LEN equ 0                 ;Кол-во начальных байт программы
AFR_SEG_LEN equ 0                 ;Смещение длины
AFR_SEG_000 equ 0                 ;Вычитать смещение длины

AFRICAN_109:
        call CLEAR_VIRNAM
        lea si,AFR_NAM
        lea di,NAMVIR
        mov cx,AFR_NAM_LEN
        cld
        rep movsb
        lea si,AFR_SIG
        lea di,SIG
        mov cx,AFR_SIG_LEN
        rep movsb
        mov ax,AFR_SEG_LEN
        mov SEGLEN,ax
        mov ah,AFR_SEG_000
        mov SEGLEN0,ah
        mov al,AFR_SIG_LEN
        mov SIGL,al
        mov ah,AFR_BEG
        mov SIGB,ah
        mov ax,AFR_LEN
        mov VIRLEN,ax
        mov ax,AFR_BEG_SEG
        mov SIG0B,ax
        mov ax,AFR_BEG_LEN
        mov SIGLB,ax
        pop di
        pop si
        pop ds
        pop es
        call INTERFACE
        ret
;-------------------------------------------------------------
VIRUS_41:
        push es
        push ds
        push si
        push di
        push cs
        pop ds
        push cs
        pop es
        jmp Search_208
                            ;Сигнатура вируса
S28_SIG db 0CBh,08Bh,0F9h,08Bh,0F3h,08Bh,0C7h,08Bh,0D6h,0C3h
S28_SIG_LEN equ $-S28_SIG         ;Длина сигнатуры
S28_NAM db '< SEARCH-208 (COM) >' ;Название вируса (max 20 символов)
S28_NAM_LEN equ $-S28_NAM         ;Длина названия вируса
S28_BEG equ 0                     ;0-добавлять, 1-вычитать смещение
S28_LEN equ 208                   ;Длина вирусного кода
S28_BEG_SEG equ 14                ;Смещение начальных байт программы
S28_BEG_LEN equ 4                 ;Кол-во начальных байт программы
S28_SEG_LEN equ 0                 ;Смещение длины
S28_SEG_000 equ 0                 ;Вычитать смещение длины

SEARCH_208:
        call CLEAR_VIRNAM
        lea si,S28_NAM
        lea di,NAMVIR
        mov cx,S28_NAM_LEN
        cld
        rep movsb
        lea si,S28_SIG
        lea di,SIG
        mov cx,S28_SIG_LEN
        rep movsb
        mov ax,S28_SEG_LEN
        mov SEGLEN,ax
        mov ah,S28_SEG_000
        mov SEGLEN0,ah
        mov al,S28_SIG_LEN
        mov SIGL,al
        mov ah,S28_BEG
        mov SIGB,ah
        mov ax,S28_LEN
        mov VIRLEN,ax
        mov ax,S28_BEG_SEG
        mov SIG0B,ax
        mov ax,S28_BEG_LEN
        mov SIGLB,ax
        pop di
        pop si
        pop ds
        pop es
        call INTERFACE
        ret
;-------------------------------------------------------------
VIRUS_42:
        push es
        push ds
        push si
        push di
        push cs
        pop ds
        push cs
        pop es
        jmp Search_248
                            ;Сигнатура вируса
S24_SIG db 0FCh,0BEh,000h,001h,056h,08Bh,0FEh,003h,074h,002h
S24_SIG_LEN equ $-S24_SIG         ;Длина сигнатуры
S24_NAM db '< SEARCH-248 (COM) >' ;Название вируса (max 20 символов)
S24_NAM_LEN equ $-S24_NAM         ;Длина названия вируса
S24_BEG equ 1                     ;0-добавлять, 1-вычитать смещение
S24_LEN equ 284                   ;Длина вирусного кода
S24_BEG_SEG equ 4                 ;Смещение начальных байт программы
S24_BEG_LEN equ 4                 ;Кол-во начальных байт программы
S24_SEG_LEN equ 0                 ;Смещение длины
S24_SEG_000 equ 0                 ;Вычитать смещение длины

SEARCH_248:
        call CLEAR_VIRNAM
        lea si,S24_NAM
        lea di,NAMVIR
        mov cx,S24_NAM_LEN
        cld
        rep movsb
        lea si,S24_SIG
        lea di,SIG
        mov cx,S24_SIG_LEN
        rep movsb
        mov ax,S24_SEG_LEN
        mov SEGLEN,ax
        mov ah,S24_SEG_000
        mov SEGLEN0,ah
        mov al,S24_SIG_LEN
        mov SIGL,al
        mov ah,S24_BEG
        mov SIGB,ah
        mov ax,S24_LEN
        mov VIRLEN,ax
        mov ax,S24_BEG_SEG
        mov SIG0B,ax
        mov ax,S24_BEG_LEN
        mov SIGLB,ax
        pop di
        pop si
        pop ds
        pop es
        call INTERFACE
        ret
;-------------------------------------------------------------
VIRUS_43:
        push es
        push ds
        push si
        push di
        push cs
        pop ds
        push cs
        pop es
        jmp Tiny_122
                            ;Сигнатура вируса
T12_SIG db 0C0h,033h,0FFh,0B1h,078h,0F3h,0A4h,06Ah,012h,0CBh
T12_SIG_LEN equ $-T12_SIG         ;Длина сигнатуры
T12_NAM db '<TINY-122 (COM,TSR)>' ;Название вируса (max 20 символов)
T12_NAM_LEN equ $-T12_NAM         ;Длина названия вируса
T12_BEG equ 0                     ;0-добавлять, 1-вычитать смещение
T12_LEN equ 122                   ;Длина вирусного кода
T12_BEG_SEG equ 0                 ;Смещение начальных байт программы
T12_BEG_LEN equ 0                 ;Кол-во начальных байт программы
T12_SEG_LEN equ 0                 ;Смещение длины
T12_SEG_000 equ 0                 ;Вычитать смещение длины

Tiny_122:
        call CLEAR_VIRNAM
        lea si,T12_NAM
        lea di,NAMVIR
        mov cx,T12_NAM_LEN
        cld
        rep movsb
        lea si,T12_SIG
        lea di,SIG
        mov cx,T12_SIG_LEN
        rep movsb
        mov ax,T12_SEG_LEN
        mov SEGLEN,ax
        mov ah,T12_SEG_000
        mov SEGLEN0,ah
        mov al,T12_SIG_LEN
        mov SIGL,al
        mov ah,T12_BEG
        mov SIGB,ah
        mov ax,T12_LEN
        mov VIRLEN,ax
        mov ax,T12_BEG_SEG
        mov SIG0B,ax
        mov ax,T12_BEG_LEN
        mov SIGLB,ax
        pop di
        pop si
        pop ds
        pop es
        call INTERFACE
        ret
;-------------------------------------------------------------
VIRUS_44:
        push es
        push ds
        push si
        push di
        push cs
        pop ds
        push cs
        pop es
        jmp Dinky_80
                            ;Сигнатура вируса
DNK_SIG db 04Eh,04Fh,0B1h,050h,0F3h,0A4h,0BEh,084h,000h,056h
DNK_SIG_LEN equ $-DNK_SIG         ;Длина сигнатуры
DNK_NAM db '<Dinky-80 (COM,TSR)>' ;Название вируса (max 20 символов)
DNK_NAM_LEN equ $-DNK_NAM         ;Длина названия вируса
DNK_BEG equ 0                     ;0-добавлять, 1-вычитать смещение
DNK_LEN equ 80                    ;Длина вирусного кода
DNK_BEG_SEG equ 0                 ;Смещение начальных байт программы
DNK_BEG_LEN equ 0                 ;Кол-во начальных байт программы
DNK_SEG_LEN equ 0                 ;Смещение длины
DNK_SEG_000 equ 0                 ;Вычитать смещение длины

Dinky_80:
        call CLEAR_VIRNAM
        lea si,DNK_NAM
        lea di,NAMVIR
        mov cx,DNK_NAM_LEN
        cld
        rep movsb
        lea si,DNK_SIG
        lea di,SIG
        mov cx,DNK_SIG_LEN
        rep movsb
        mov ax,DNK_SEG_LEN
        mov SEGLEN,ax
        mov ah,DNK_SEG_000
        mov SEGLEN0,ah
        mov al,DNK_SIG_LEN
        mov SIGL,al
        mov ah,DNK_BEG
        mov SIGB,ah
        mov ax,DNK_LEN
        mov VIRLEN,ax
        mov ax,DNK_BEG_SEG
        mov SIG0B,ax
        mov ax,DNK_BEG_LEN
        mov SIGLB,ax
        pop di
        pop si
        pop ds
        pop es
        call INTERFACE
        ret
;-------------------------------------------------------------
VIRUS_45:
        push es
        push ds
        push si
        push di
        push cs
        pop ds
        push cs
        pop es
        jmp Micro_42
                            ;Сигнатура вируса
m42_SIG db 093h,0bah,000h,001h,0b1h,02ah,0B4h,040h,0cdh,021h
m42_SIG_LEN equ $-m42_SIG         ;Длина сигнатуры
m42_NAM db '<Micro-42 (COM,OVR)>' ;Название вируса (max 20 символов)
m42_NAM_LEN equ $-m42_NAM         ;Длина названия вируса
m42_BEG equ 0                     ;0-добавлять, 1-вычитать смещение
m42_LEN equ 42                    ;Длина вирусного кода
m42_BEG_SEG equ 0                 ;Смещение начальных байт программы
m42_BEG_LEN equ 0                 ;Кол-во начальных байт программы
m42_SEG_LEN equ 0                 ;Смещение длины
m42_SEG_000 equ 0                 ;Вычитать смещение длины

Micro_42:
        call CLEAR_VIRNAM
        lea si,m42_NAM
        lea di,NAMVIR
        mov cx,m42_NAM_LEN
        cld
        rep movsb
        lea si,m42_SIG
        lea di,SIG
        mov cx,m42_SIG_LEN
        rep movsb
        mov ax,m42_SEG_LEN
        mov SEGLEN,ax
        mov ah,m42_SEG_000
        mov SEGLEN0,ah
        mov al,m42_SIG_LEN
        mov SIGL,al
        mov ah,m42_BEG
        mov SIGB,ah
        mov ax,m42_LEN
        mov VIRLEN,ax
        mov ax,m42_BEG_SEG
        mov SIG0B,ax
        mov ax,m42_BEG_LEN
        mov SIGLB,ax
        pop di
        pop si
        pop ds
        pop es
        call INTERFACE
        ret
;-------------------------------------------------------------
VIRUS_46:
        push es
        push ds
        push si
        push di
        push cs
        pop ds
        push cs
        pop es
        jmp JUMP_466
                            ;Сигнатура вируса
J46_SIG db 0EAh,04Ah,055h,04Dh,050h,0E9h,053h,042h,0EAh,05Bh
J46_SIG_LEN equ $-J46_SIG         ;Длина сигнатуры
J46_NAM db '<JUMP-466 (COM,TSR)>' ;Название вируса (max 20 символов)
J46_NAM_LEN equ $-J46_NAM         ;Длина названия вируса
J46_BEG equ 1                     ;0-добавлять, 1-вычитать смещение
J46_LEN equ 466                   ;Длина вирусного кода
J46_BEG_SEG equ 4                 ;Смещение начальных байт программы
J46_BEG_LEN equ 3                 ;Кол-во начальных байт программы
J46_SEG_LEN equ 0                 ;Смещение длины
J46_SEG_000 equ 0                 ;Вычитать смещение длины

JUMP_466:
        call CLEAR_VIRNAM
        lea si,J46_NAM
        lea di,NAMVIR
        mov cx,J46_NAM_LEN
        cld
        rep movsb
        lea si,J46_SIG
        lea di,SIG
        mov cx,J46_SIG_LEN
        rep movsb
        mov ax,J46_SEG_LEN
        mov SEGLEN,ax
        mov ah,J46_SEG_000
        mov SEGLEN0,ah
        mov al,J46_SIG_LEN
        mov SIGL,al
        mov ah,J46_BEG
        mov SIGB,ah
        mov ax,J46_LEN
        mov VIRLEN,ax
        mov ax,J46_BEG_SEG
        mov SIG0B,ax
        mov ax,J46_BEG_LEN
        mov SIGLB,ax
        pop di
        pop si
        pop ds
        pop es
        call INTERFACE
        ret
;-------------------------------------------------------------
VIRUS_47:
        push es
        push ds
        push si
        push di
        push cs
        pop ds
        push cs
        pop es
        jmp CASCADE_1701
                            ;Сигнатура вируса
AAE_SIG db 08Dh,0B7h,04Dh,001h,0BCh,082h,006h,031h,034h,031h
AAE_SIG_LEN equ $-AAE_SIG         ;Длина сигнатуры
AAE_NAM db '<CASCADE-1701 (TSR)>' ;Название вируса (max 20 символов)
AAE_NAM_LEN equ $-AAE_NAM         ;Длина названия вируса
AAE_BEG equ 0                     ;0-добавлять, 1-вычитать смещение
AAE_LEN equ 1701                  ;Длина вирусного кода
AAE_BEG_SEG equ 0                 ;Смещение начальных байт программы
AAE_BEG_LEN equ 0                 ;Кол-во начальных байт программы
AAE_SEG_LEN equ 0                 ;Смещение длины
AAE_SEG_000 equ 0                 ;Вычитать смещение длины

CASCADE_1701:
        call CLEAR_VIRNAM
        lea si,AAE_NAM
        lea di,NAMVIR
        mov cx,AAE_NAM_LEN
        cld
        rep movsb
        lea si,AAE_SIG
        lea di,SIG
        mov cx,AAE_SIG_LEN
        rep movsb
        mov ax,AAE_SEG_LEN
        mov SEGLEN,ax
        mov ah,AAE_SEG_000
        mov SEGLEN0,ah
        mov al,AAE_SIG_LEN
        mov SIGL,al
        mov ah,AAE_BEG
        mov SIGB,ah
        mov ax,AAE_LEN
        mov VIRLEN,ax
        mov ax,AAE_BEG_SEG
        mov SIG0B,ax
        mov ax,AAE_BEG_LEN
        mov SIGLB,ax
        pop di
        pop si
        pop ds
        pop es
        call INTERFACE
        ret
;-------------------------------------------------------------
VIRUS_48:
        push es
        push ds
        push si
        push di
        push cs
        pop ds
        push cs
        pop es
        jmp Micro_45
                            ;Сигнатура вируса
M45_SIG db 093h,08Bh,0D6h,0B1h,02Dh,0B4h,040h,0CDh,021h,072h
M45_SIG_LEN equ $-M45_SIG         ;Длина сигнатуры
M45_NAM db '<MICRO-45 (COM,OVR)>' ;Название вируса (max 20 символов)
M45_NAM_LEN equ $-M45_NAM         ;Длина названия вируса
M45_BEG equ 0                     ;0-добавлять, 1-вычитать смещение
M45_LEN equ 45                    ;Длина вирусного кода
M45_BEG_SEG equ 0                 ;Смещение начальных байт программы
M45_BEG_LEN equ 0                 ;Кол-во начальных байт программы
M45_SEG_LEN equ 0                 ;Смещение длины
M45_SEG_000 equ 0                 ;Вычитать смещение длины

Micro_45:
        call CLEAR_VIRNAM
        lea si,M45_NAM
        lea di,NAMVIR
        mov cx,M45_NAM_LEN
        cld
        rep movsb
        lea si,M45_SIG
        lea di,SIG
        mov cx,M45_SIG_LEN
        rep movsb
        mov ax,M45_SEG_LEN
        mov SEGLEN,ax
        mov ah,M45_SEG_000
        mov SEGLEN0,ah
        mov al,M45_SIG_LEN
        mov SIGL,al
        mov ah,M45_BEG
        mov SIGB,ah
        mov ax,M45_LEN
        mov VIRLEN,ax
        mov ax,M45_BEG_SEG
        mov SIG0B,ax
        mov ax,M45_BEG_LEN
        mov SIGLB,ax
        pop di
        pop si
        pop ds
        pop es
        call INTERFACE
        ret
;-------------------------------------------------------------
VIRUS_49:
        push es
        push ds
        push si
        push di
        push cs
        pop ds
        push cs
        pop es
        jmp problem2
                            ;Сигнатура вируса
PR2_SIG db 089h,09dh,0feh,001h,08bh,0d7h,081h,0c2h,041h,002h
PR2_SIG_LEN equ $-PR2_SIG         ;Длина сигнатуры
PR2_NAM db '< PROBLEM-2  (COM) >' ;Название вируса (max 20 символов)
PR2_NAM_LEN equ $-PR2_NAM         ;Длина названия вируса
PR2_BEG equ 0                     ;0-добавлять, 1-вычитать смещение
PR2_LEN equ 0                     ;Длина вирусного кода
PR2_BEG_SEG equ 0                 ;Смещение начальных байт программы
PR2_BEG_LEN equ 0                 ;Кол-во начальных байт программы
PR2_SEG_LEN equ 0                 ;Смещение длины
PR2_SEG_000 equ 0                 ;Вычитать смещение длины

PROBLEM2:
        call CLEAR_VIRNAM
        lea si,PR2_NAM
        lea di,NAMVIR
        mov cx,PR2_NAM_LEN
        cld
        rep movsb
        lea si,PR2_SIG
        lea di,SIG
        mov cx,PR2_SIG_LEN
        rep movsb
        mov ax,PR2_SEG_LEN
        mov SEGLEN,ax
        mov ah,PR2_SEG_000
        mov SEGLEN0,ah
        mov al,PR2_SIG_LEN
        mov SIGL,al
        mov ah,PR2_BEG
        mov SIGB,ah
        mov ax,PR2_LEN
        mov VIRLEN,ax
        mov ax,PR2_BEG_SEG
        mov SIG0B,ax
        mov ax,PR2_BEG_LEN
        mov SIGLB,ax
        pop di
        pop si
        pop ds
        pop es
        call INTERFACE
        ret
;-------------------------------------------------------------
VIRUS_50:
        push es
        push ds
        push si
        push di
        push cs
        pop ds
        push cs
        pop es
        jmp VIENA_627
                            ;Сигнатура вируса
V27_SIG db 089h,07Ch,016h,08Bh,0FEh,081h,0C7h,01Fh,000h,08Bh
V27_SIG_LEN equ $-V27_SIG         ;Длина сигнатуры
V27_NAM db '< VIENNA 627 (COM) >' ;Название вируса (max 20 символов)
V27_NAM_LEN equ $-V27_NAM         ;Длина названия вируса
V27_BEG equ 0                     ;0-добавлять, 1-вычитать смещение
V27_LEN equ 627                   ;Длина вирусного кода
V27_BEG_SEG equ 199H              ;Смещение начальных байт программы
V27_BEG_LEN equ 3                 ;Кол-во начальных байт программы
V27_SEG_LEN equ 0                 ;Смещение длины
V27_SEG_000 equ 0                 ;Вычитать смещение длины

VIENA_627:
        call CLEAR_VIRNAM
        lea si,V27_NAM
        lea di,NAMVIR
        mov cx,V27_NAM_LEN
        cld
        rep movsb
        lea si,V27_SIG
        lea di,SIG
        mov cx,V27_SIG_LEN
        rep movsb
        mov ax,V27_SEG_LEN
        mov SEGLEN,ax
        mov ah,V27_SEG_000
        mov SEGLEN0,ah
        mov al,V27_SIG_LEN
        mov SIGL,al
        mov ah,V27_BEG
        mov SIGB,ah
        mov ax,V27_LEN
        mov VIRLEN,ax
        mov ax,V27_BEG_SEG
        mov SIG0B,ax
        mov ax,V27_BEG_LEN
        mov SIGLB,ax
        pop di
        pop si
        pop ds
        pop es
        call INTERFACE
        ret
;-------------------------------------------------------------
VIRUS_51:
        push es
        push ds
        push si
        push di
        push cs
        pop ds
        push cs
        pop es
        jmp VIENA_534
                            ;Сигнатура вируса
V34_SIG db 08Bh,0D7h,02Bh,0F9h,083h,0C7h,002h,005h,003h,001h
V34_SIG_LEN equ $-V34_SIG         ;Длина сигнатуры
V34_NAM db '< VIENNA 534 (COM) >' ;Название вируса (max 20 символов)
V34_NAM_LEN equ $-V34_NAM         ;Длина названия вируса
V34_BEG equ 0                     ;0-добавлять, 1-вычитать смещение
V34_LEN equ 534                   ;Длина вирусного кода
V34_BEG_SEG equ 06BH              ;Смещение начальных байт программы
V34_BEG_LEN equ 3                 ;Кол-во начальных байт программы
V34_SEG_LEN equ 0                 ;Смещение длины
V34_SEG_000 equ 0                 ;Вычитать смещение длины

VIENA_534:
        call CLEAR_VIRNAM
        lea si,V34_NAM
        lea di,NAMVIR
        mov cx,V34_NAM_LEN
        cld
        rep movsb
        lea si,V34_SIG
        lea di,SIG
        mov cx,V34_SIG_LEN
        rep movsb
        mov ax,V34_SEG_LEN
        mov SEGLEN,ax
        mov ah,V34_SEG_000
        mov SEGLEN0,ah
        mov al,V34_SIG_LEN
        mov SIGL,al
        mov ah,V34_BEG
        mov SIGB,ah
        mov ax,V34_LEN
        mov VIRLEN,ax
        mov ax,V34_BEG_SEG
        mov SIG0B,ax
        mov ax,V34_BEG_LEN
        mov SIGLB,ax
        pop di
        pop si
        pop ds
        pop es
        call INTERFACE
        ret
;-------------------------------------------------------------
VIRUS_52:
        push es
        push ds
        push si
        push di
        push cs
        pop ds
        push cs
        pop es
        jmp VIENA_623
                            ;Сигнатура вируса
V23_SIG db 0CDh,021h,089h,01Ch,08Ch,044h,002h,0B8h,024h,035h
V23_SIG_LEN equ $-V23_SIG         ;Длина сигнатуры
V23_NAM db '< VIENNA 623 (COM) >' ;Название вируса (max 20 символов)
V23_NAM_LEN equ $-V23_NAM         ;Длина названия вируса
V23_BEG equ 1                     ;0-добавлять, 1-вычитать смещение
V23_LEN equ 623                   ;Длина вирусного кода
V23_BEG_SEG equ 0ABH              ;Смещение начальных байт программы
V23_BEG_LEN equ 3                 ;Кол-во начальных байт программы
V23_SEG_LEN equ 0                 ;Смещение длины
V23_SEG_000 equ 0                 ;Вычитать смещение длины

VIENA_623:
        call CLEAR_VIRNAM
        lea si,V23_NAM
        lea di,NAMVIR
        mov cx,V23_NAM_LEN
        cld
        rep movsb
        lea si,V23_SIG
        lea di,SIG
        mov cx,V23_SIG_LEN
        rep movsb
        mov ax,V23_SEG_LEN
        mov SEGLEN,ax
        mov ah,V23_SEG_000
        mov SEGLEN0,ah
        mov al,V23_SIG_LEN
        mov SIGL,al
        mov ah,V23_BEG
        mov SIGB,ah
        mov ax,V23_LEN
        mov VIRLEN,ax
        mov ax,V23_BEG_SEG
        mov SIG0B,ax
        mov ax,V23_BEG_LEN
        mov SIGLB,ax
        pop di
        pop si
        pop ds
        pop es
        call INTERFACE
        ret
;-------------------------------------------------------------
VIRUS_53:
        push es
        push ds
        push si
        push di
        push cs
        pop ds
        push cs
        pop es
        jmp VIENA_648
                            ;Сигнатура вируса
V48_SIG db 089h,08Ch,004h,000h,089h,094h,006h,000h,0B4h,02Ch
V48_SIG_LEN equ $-V48_SIG         ;Длина сигнатуры
V48_NAM db '< VIENNA 648 (COM) >' ;Название вируса (max 20 символов)
V48_NAM_LEN equ $-V48_NAM         ;Длина названия вируса
V48_BEG equ 0                     ;0-добавлять, 1-вычитать смещение
V48_LEN equ 648                   ;Длина вирусного кода
V48_BEG_SEG equ 0D7H              ;Смещение начальных байт программы
V48_BEG_LEN equ 3                 ;Кол-во начальных байт программы
V48_SEG_LEN equ 0                 ;Смещение длины
V48_SEG_000 equ 0                 ;Вычитать смещение длины

VIENA_648:
        call CLEAR_VIRNAM
        lea si,V48_NAM
        lea di,NAMVIR
        mov cx,V48_NAM_LEN
        cld
        rep movsb
        lea si,V48_SIG
        lea di,SIG
        mov cx,V48_SIG_LEN
        rep movsb
        mov ax,V48_SEG_LEN
        mov SEGLEN,ax
        mov ah,V48_SEG_000
        mov SEGLEN0,ah
        mov al,V48_SIG_LEN
        mov SIGL,al
        mov ah,V48_BEG
        mov SIGB,ah
        mov ax,V48_LEN
        mov VIRLEN,ax
        mov ax,V48_BEG_SEG
        mov SIG0B,ax
        mov ax,V48_BEG_LEN
        mov SIGLB,ax
        pop di
        pop si
        pop ds
        pop es
        call INTERFACE
        ret
;-------------------------------------------------------------
VIRUS_54:
        push es
        push ds
        push si
        push di
        push cs
        pop ds
        push cs
        pop es
        jmp HYMN_1865
                            ;Сигнатура вируса
HYM_SIG db 02Eh,081h,0BCh,042h,007h,04Dh,05Ah,074h,00Eh,0FAh
HYM_SIG_LEN equ $-HYM_SIG         ;Длина сигнатуры
HYM_NAM db '<HYMN1865 (COM,EXE)>' ;Название вируса (max 20 символов)
HYM_NAM_LEN equ $-HYM_NAM         ;Длина названия вируса
HYM_BEG equ 0                     ;0-добавлять, 1-вычитать смещение
HYM_LEN equ 1865                  ;Длина вирусного кода
HYM_BEG_SEG equ 6F1H              ;Смещение начальных байт программы
HYM_BEG_LEN equ 3                 ;Кол-во начальных байт программы
HYM_SEG_LEN equ 0                 ;Смещение длины
HYM_SEG_000 equ 0                 ;Вычитать смещение длины

HYMN_1865:
        call CLEAR_VIRNAM
        lea si,HYM_NAM
        lea di,NAMVIR
        mov cx,HYM_NAM_LEN
        cld
        rep movsb
        lea si,HYM_SIG
        lea di,SIG
        mov cx,HYM_SIG_LEN
        rep movsb
        mov ax,HYM_SEG_LEN
        mov SEGLEN,ax
        mov ah,HYM_SEG_000
        mov SEGLEN0,ah
        mov al,HYM_SIG_LEN
        mov SIGL,al
        mov ah,HYM_BEG
        mov SIGB,ah
        mov ax,HYM_LEN
        mov VIRLEN,ax
        mov ax,HYM_BEG_SEG
        mov SIG0B,ax
        mov ax,HYM_BEG_LEN
        mov SIGLB,ax
        pop di
        pop si
        pop ds
        pop es
        call INTERFACE
        ret
;-------------------------------------------------------------
VIRUS_55:
        push es
        push ds
        push si
        push di
        push cs
        pop ds
        push cs
        pop es
        jmp SEPT_13
                            ;Сигнатура вируса
S13_SIG db 089h,09Ch,09Bh,000h,08Ch,084h,09Dh,000h,007h,0BFh
S13_SIG_LEN equ $-S13_SIG         ;Длина сигнатуры
S13_NAM db '<SEPTEMBER 13 (COM)>' ;Название вируса (max 20 символов)
S13_NAM_LEN equ $-S13_NAM         ;Длина названия вируса
S13_BEG equ 1                     ;0-добавлять, 1-вычитать смещение
S13_LEN equ 440                   ;Длина вирусного кода
S13_BEG_SEG equ 04AH              ;Смещение начальных байт программы
S13_BEG_LEN equ 4                 ;Кол-во начальных байт программы
S13_SEG_LEN equ 0                 ;Смещение длины
S13_SEG_000 equ 0                 ;Вычитать смещение длины

SEPT_13:
        call CLEAR_VIRNAM
        lea si,S13_NAM
        lea di,NAMVIR
        mov cx,S13_NAM_LEN
        cld
        rep movsb
        lea si,S13_SIG
        lea di,SIG
        mov cx,S13_SIG_LEN
        rep movsb
        mov ax,S13_SEG_LEN
        mov SEGLEN,ax
        mov ah,S13_SEG_000
        mov SEGLEN0,ah
        mov al,S13_SIG_LEN
        mov SIGL,al
        mov ah,S13_BEG
        mov SIGB,ah
        mov ax,S13_LEN
        mov VIRLEN,ax
        mov ax,S13_BEG_SEG
        mov SIG0B,ax
        mov ax,S13_BEG_LEN
        mov SIGLB,ax
        pop di
        pop si
        pop ds
        pop es
        call INTERFACE
        ret
;-------------------------------------------------------------
VIRUS_56:
        push es
        push ds
        push si
        push di
        push cs
        pop ds
        push cs
        pop es
        jmp Micro_58
                            ;Сигнатура вируса
M58_SIG db 01Fh,099h,0B9h,03Ah,000h,0CDh,021h,01Fh,061h,0EAh
M58_SIG_LEN equ $-M58_SIG         ;Длина сигнатуры
M58_NAM db '<Micro_58 (COM,TSR)>' ;Название вируса (max 20 символов)
M58_NAM_LEN equ $-M58_NAM         ;Длина названия вируса
M58_BEG equ 0                     ;0-добавлять, 1-вычитать смещение
M58_LEN equ 58                    ;Длина вирусного кода
M58_BEG_SEG equ 0                 ;Смещение начальных байт программы
M58_BEG_LEN equ 0                 ;Кол-во начальных байт программы
M58_SEG_LEN equ 0                 ;Смещение длины
M58_SEG_000 equ 0                 ;Вычитать смещение длины

Micro_58:
        call CLEAR_VIRNAM
        lea si,M58_NAM
        lea di,NAMVIR
        mov cx,M58_NAM_LEN
        cld
        rep movsb
        lea si,M58_SIG
        lea di,SIG
        mov cx,M58_SIG_LEN
        rep movsb
        mov ax,M58_SEG_LEN
        mov SEGLEN,ax
        mov ah,M58_SEG_000
        mov SEGLEN0,ah
        mov al,M58_SIG_LEN
        mov SIGL,al
        mov ah,M58_BEG
        mov SIGB,ah
        mov ax,M58_LEN
        mov VIRLEN,ax
        mov ax,M58_BEG_SEG
        mov SIG0B,ax
        mov ax,M58_BEG_LEN
        mov SIGLB,ax
        pop di
        pop si
        pop ds
        pop es
        call INTERFACE
        ret
;-------------------------------------------------------------
VIRUS_57:
        push es
        push ds
        push si
        push di
        push cs
        pop ds
        push cs
        pop es
        jmp Micro_33
                            ;Сигнатура вируса
M33_SIG db 0BAh,000h,001h,0CDh,021h,0B4h,04Fh,0E2h,0E5h,02Ah
M33_SIG_LEN equ $-M33_SIG         ;Длина сигнатуры
M33_NAM db '<Micro_33 (COM,OVR)>' ;Название вируса (max 20 символов)
M33_NAM_LEN equ $-M33_NAM         ;Длина названия вируса
M33_BEG equ 0                     ;0-добавлять, 1-вычитать смещение
M33_LEN equ 33                    ;Длина вирусного кода
M33_BEG_SEG equ 0                 ;Смещение начальных байт программы
M33_BEG_LEN equ 0                 ;Кол-во начальных байт программы
M33_SEG_LEN equ 0                 ;Смещение длины
M33_SEG_000 equ 0                 ;Вычитать смещение длины

Micro_33:
        call CLEAR_VIRNAM
        lea si,M33_NAM
        lea di,NAMVIR
        mov cx,M33_NAM_LEN
        cld
        rep movsb
        lea si,M33_SIG
        lea di,SIG
        mov cx,M33_SIG_LEN
        rep movsb
        mov ax,M33_SEG_LEN
        mov SEGLEN,ax
        mov ah,M33_SEG_000
        mov SEGLEN0,ah
        mov al,M33_SIG_LEN
        mov SIGL,al
        mov ah,M33_BEG
        mov SIGB,ah
        mov ax,M33_LEN
        mov VIRLEN,ax
        mov ax,M33_BEG_SEG
        mov SIG0B,ax
        mov ax,M33_BEG_LEN
        mov SIGLB,ax
        pop di
        pop si
        pop ds
        pop es
        call INTERFACE
        ret
;-------------------------------------------------------------
VIRUS_58:
        push es
        push ds
        push si
        push di
        push cs
        pop ds
        push cs
        pop es
        jmp Micro_30
                            ;Сигнатура вируса
M30_SIG db 093h,0B4h,040h,0BAh,000h,001h,0CDh,021h,0C3h,02Ah
M30_SIG_LEN equ $-M30_SIG         ;Длина сигнатуры
M30_NAM db '<Micro_30 (COM,OVR)>' ;Название вируса (max 20 символов)
M30_NAM_LEN equ $-M30_NAM         ;Длина названия вируса
M30_BEG equ 0                     ;0-добавлять, 1-вычитать смещение
M30_LEN equ 30                    ;Длина вирусного кода
M30_BEG_SEG equ 0                 ;Смещение начальных байт программы
M30_BEG_LEN equ 0                 ;Кол-во начальных байт программы
M30_SEG_LEN equ 0                 ;Смещение длины
M30_SEG_000 equ 0                 ;Вычитать смещение длины

Micro_30:
        call CLEAR_VIRNAM
        lea si,M30_NAM
        lea di,NAMVIR
        mov cx,M30_NAM_LEN
        cld
        rep movsb
        lea si,M30_SIG
        lea di,SIG
        mov cx,M30_SIG_LEN
        rep movsb
        mov ax,M30_SEG_LEN
        mov SEGLEN,ax
        mov ah,M30_SEG_000
        mov SEGLEN0,ah
        mov al,M30_SIG_LEN
        mov SIGL,al
        mov ah,M30_BEG
        mov SIGB,ah
        mov ax,M30_LEN
        mov VIRLEN,ax
        mov ax,M30_BEG_SEG
        mov SIG0B,ax
        mov ax,M30_BEG_LEN
        mov SIGLB,ax
        pop di
        pop si
        pop ds
        pop es
        call INTERFACE
        ret
;-------------------------------------------------------------
VIRUS_59:
        push es
        push ds
        push si
        push di
        push cs
        pop ds
        push cs
        pop es
        jmp Micro_29
                            ;Сигнатура вируса
M29_SIG db 0B4h,040h,08Bh,0D6h,0CDh,021h,0B4h,04Fh,0EBh,0EBh
M29_SIG_LEN equ $-M29_SIG         ;Длина сигнатуры
M29_NAM db '<Micro_29 (COM,OVR)>' ;Название вируса (max 20 символов)
M29_NAM_LEN equ $-M29_NAM         ;Длина названия вируса
M29_BEG equ 0                     ;0-добавлять, 1-вычитать смещение
M29_LEN equ 29                    ;Длина вирусного кода
M29_BEG_SEG equ 0                 ;Смещение начальных байт программы
M29_BEG_LEN equ 0                 ;Кол-во начальных байт программы
M29_SEG_LEN equ 0                 ;Смещение длины
M29_SEG_000 equ 0                 ;Вычитать смещение длины

Micro_29:
        call CLEAR_VIRNAM
        lea si,M29_NAM
        lea di,NAMVIR
        mov cx,M29_NAM_LEN
        cld
        rep movsb
        lea si,M29_SIG
        lea di,SIG
        mov cx,M29_SIG_LEN
        rep movsb
        mov ax,M29_SEG_LEN
        mov SEGLEN,ax
        mov ah,M29_SEG_000
        mov SEGLEN0,ah
        mov al,M29_SIG_LEN
        mov SIGL,al
        mov ah,M29_BEG
        mov SIGB,ah
        mov ax,M29_LEN
        mov VIRLEN,ax
        mov ax,M29_BEG_SEG
        mov SIG0B,ax
        mov ax,M29_BEG_LEN
        mov SIGLB,ax
        pop di
        pop si
        pop ds
        pop es
        call INTERFACE
        ret
;-------------------------------------------------------------
VIRUS_60:
        push es
        push ds
        push si
        push di
        push cs
        pop ds
        push cs
        pop es
        jmp Micro_28
                            ;Сигнатура вируса
M28_SIG db 0CDh,021h,093h,0B4h,040h,08Bh,0D6h,0CDh,021h,0C3h
M28_SIG_LEN equ $-M28_SIG         ;Длина сигнатуры
M28_NAM db '<Micro_28 (COM,OVR)>' ;Название вируса (max 20 символов)
M28_NAM_LEN equ $-M28_NAM         ;Длина названия вируса
M28_BEG equ 0                     ;0-добавлять, 1-вычитать смещение
M28_LEN equ 28                    ;Длина вирусного кода
M28_BEG_SEG equ 0                 ;Смещение начальных байт программы
M28_BEG_LEN equ 0                 ;Кол-во начальных байт программы
M28_SEG_LEN equ 0                 ;Смещение длины
M28_SEG_000 equ 0                 ;Вычитать смещение длины

Micro_28:
        call CLEAR_VIRNAM
        lea si,M28_NAM
        lea di,NAMVIR
        mov cx,M28_NAM_LEN
        cld
        rep movsb
        lea si,M28_SIG
        lea di,SIG
        mov cx,M28_SIG_LEN
        rep movsb
        mov ax,M28_SEG_LEN
        mov SEGLEN,ax
        mov ah,M28_SEG_000
        mov SEGLEN0,ah
        mov al,M28_SIG_LEN
        mov SIGL,al
        mov ah,M28_BEG
        mov SIGB,ah
        mov ax,M28_LEN
        mov VIRLEN,ax
        mov ax,M28_BEG_SEG
        mov SIG0B,ax
        mov ax,M28_BEG_LEN
        mov SIGLB,ax
        pop di
        pop si
        pop ds
        pop es
        call INTERFACE
        ret
;-------------------------------------------------------------
VIRUS_61:
        push es
        push ds
        push si
        push di
        push cs
        pop ds
        push cs
        pop es
        jmp Micro_18
                            ;Сигнатура вируса
M18_SIG db 00Fh,0BAh,05Ch,000h,0CDh,021h,0B4h,015h,0CDh,021h
M18_SIG_LEN equ $-M18_SIG         ;Длина сигнатуры
M18_NAM db '<Micro_18 (COM,OVR)>' ;Название вируса (max 20 символов)
M18_NAM_LEN equ $-M18_NAM         ;Длина названия вируса
M18_BEG equ 0                     ;0-добавлять, 1-вычитать смещение
M18_LEN equ 18                    ;Длина вирусного кода
M18_BEG_SEG equ 0                 ;Смещение начальных байт программы
M18_BEG_LEN equ 0                 ;Кол-во начальных байт программы
M18_SEG_LEN equ 0                 ;Смещение длины
M18_SEG_000 equ 0                 ;Вычитать смещение длины

Micro_18:
        call CLEAR_VIRNAM
        lea si,M18_NAM
        lea di,NAMVIR
        mov cx,M18_NAM_LEN
        cld
        rep movsb
        lea si,M18_SIG
        lea di,SIG
        mov cx,M18_SIG_LEN
        rep movsb
        mov ax,M18_SEG_LEN
        mov SEGLEN,ax
        mov ah,M18_SEG_000
        mov SEGLEN0,ah
        mov al,M18_SIG_LEN
        mov SIGL,al
        mov ah,M18_BEG
        mov SIGB,ah
        mov ax,M18_LEN
        mov VIRLEN,ax
        mov ax,M18_BEG_SEG
        mov SIG0B,ax
        mov ax,M18_BEG_LEN
        mov SIGLB,ax
        pop di
        pop si
        pop ds
        pop es
        call INTERFACE
        ret
;-------------------------------------------------------------
VIRUS_62:
        push es
        push ds
        push si
        push di
        push cs
        pop ds
        push cs
        pop es
        jmp Micro_13
                            ;Сигнатура вируса
M13_SIG db 035h,000h,03Ch,041h,087h,0F2h,0CDh,021h,093h,0B4h
M13_SIG_LEN equ $-M13_SIG         ;Длина сигнатуры
M13_NAM db '<Micro_13 (COM,OVR)>' ;Название вируса (max 20 символов)
M13_NAM_LEN equ $-M13_NAM         ;Длина названия вируса
M13_BEG equ 0                     ;0-добавлять, 1-вычитать смещение
M13_LEN equ 13                    ;Длина вирусного кода
M13_BEG_SEG equ 0                 ;Смещение начальных байт программы
M13_BEG_LEN equ 0                 ;Кол-во начальных байт программы
M13_SEG_LEN equ 0                 ;Смещение длины
M13_SEG_000 equ 0                 ;Вычитать смещение длины

Micro_13:
        call CLEAR_VIRNAM
        lea si,M13_NAM
        lea di,NAMVIR
        mov cx,M13_NAM_LEN
        cld
        rep movsb
        lea si,M13_SIG
        lea di,SIG
        mov cx,M13_SIG_LEN
        rep movsb
        mov ax,M13_SEG_LEN
        mov SEGLEN,ax
        mov ah,M13_SEG_000
        mov SEGLEN0,ah
        mov al,M13_SIG_LEN
        mov SIGL,al
        mov ah,M13_BEG
        mov SIGB,ah
        mov ax,M13_LEN
        mov VIRLEN,ax
        mov ax,M13_BEG_SEG
        mov SIG0B,ax
        mov ax,M13_BEG_LEN
        mov SIGLB,ax
        pop di
        pop si
        pop ds
        pop es
        call INTERFACE
        ret
;-------------------------------------------------------------
VIRUS_63:
        push es
        push ds
        push si
        push di
        push cs
        pop ds
        push cs
        pop es
        jmp Micro_7A
                            ;Сигнатура вируса
M7A_SIG db 091h,0D4h,01Ch,08Bh,0D6h,0CDh,021h
M7A_SIG_LEN equ $-M7A_SIG         ;Длина сигнатуры
M7A_NAM db '<Micro_7a (COM,OVR)>' ;Название вируса (max 20 символов)
M7A_NAM_LEN equ $-M7A_NAM         ;Длина названия вируса
M7A_BEG equ 0                     ;0-добавлять, 1-вычитать смещение
M7A_LEN equ 7                     ;Длина вирусного кода
M7A_BEG_SEG equ 0                 ;Смещение начальных байт программы
M7A_BEG_LEN equ 0                 ;Кол-во начальных байт программы
M7A_SEG_LEN equ 0                 ;Смещение длины
M7A_SEG_000 equ 0                 ;Вычитать смещение длины

Micro_7A:
        call CLEAR_VIRNAM
        lea si,M7A_NAM
        lea di,NAMVIR
        mov cx,M7A_NAM_LEN
        cld
        rep movsb
        lea si,M7A_SIG
        lea di,SIG
        mov cx,M7A_SIG_LEN
        rep movsb
        mov ax,M7A_SEG_LEN
        mov SEGLEN,ax
        mov ah,M7A_SEG_000
        mov SEGLEN0,ah
        mov al,M7A_SIG_LEN
        mov SIGL,al
        mov ah,M7A_BEG
        mov SIGB,ah
        mov ax,M7A_LEN
        mov VIRLEN,ax
        mov ax,M7A_BEG_SEG
        mov SIG0B,ax
        mov ax,M7A_BEG_LEN
        mov SIGLB,ax
        pop di
        pop si
        pop ds
        pop es
        call INTERFACE
        ret
;-------------------------------------------------------------
VIRUS_64:
        push es
        push ds
        push si
        push di
        push cs
        pop ds
        push cs
        pop es
        jmp Micro_7B
                            ;Сигнатура вируса
M7B_SIG db 0B4h,040h,043h,08Bh,0D6h,0CDh,021h
M7B_SIG_LEN equ $-M7B_SIG         ;Длина сигнатуры
M7B_NAM db '<Micro_7b (COM,OVR)>' ;Название вируса (max 20 символов)
M7B_NAM_LEN equ $-M7B_NAM         ;Длина названия вируса
M7B_BEG equ 0                     ;0-добавлять, 1-вычитать смещение
M7B_LEN equ 7                     ;Длина вирусного кода
M7B_BEG_SEG equ 0                 ;Смещение начальных байт программы
M7B_BEG_LEN equ 0                 ;Кол-во начальных байт программы
M7B_SEG_LEN equ 0                 ;Смещение длины
M7B_SEG_000 equ 0                 ;Вычитать смещение длины

Micro_7B:
        call CLEAR_VIRNAM
        lea si,M7B_NAM
        lea di,NAMVIR
        mov cx,M7B_NAM_LEN
        cld
        rep movsb
        lea si,M7B_SIG
        lea di,SIG
        mov cx,M7B_SIG_LEN
        rep movsb
        mov ax,M7B_SEG_LEN
        mov SEGLEN,ax
        mov ah,M7B_SEG_000
        mov SEGLEN0,ah
        mov al,M7B_SIG_LEN
        mov SIGL,al
        mov ah,M7B_BEG
        mov SIGB,ah
        mov ax,M7B_LEN
        mov VIRLEN,ax
        mov ax,M7B_BEG_SEG
        mov SIG0B,ax
        mov ax,M7B_BEG_LEN
        mov SIGLB,ax
        pop di
        pop si
        pop ds
        pop es
        call INTERFACE
        ret
;-------------------------------------------------------------
VIRUS_65:
        push es
        push ds
        push si
        push di
        push cs
        pop ds
        push cs
        pop es
        jmp Micro_5A
                            ;Сигнатура вируса
M5A_SIG db 095h,08Bh,0D6h,0CDh,021h
M5A_SIG_LEN equ $-M5A_SIG         ;Длина сигнатуры
M5A_NAM db '<Micro_5a (COM,OVR)>' ;Название вируса (max 20 символов)
M5A_NAM_LEN equ $-M5A_NAM         ;Длина названия вируса
M5A_BEG equ 0                     ;0-добавлять, 1-вычитать смещение
M5A_LEN equ 5                     ;Длина вирусного кода
M5A_BEG_SEG equ 0                 ;Смещение начальных байт программы
M5A_BEG_LEN equ 0                 ;Кол-во начальных байт программы
M5A_SEG_LEN equ 0                 ;Смещение длины
M5A_SEG_000 equ 0                 ;Вычитать смещение длины

Micro_5A:
        call CLEAR_VIRNAM
        lea si,M5A_NAM
        lea di,NAMVIR
        mov cx,M5A_NAM_LEN
        cld
        rep movsb
        lea si,M5A_SIG
        lea di,SIG
        mov cx,M5A_SIG_LEN
        rep movsb
        mov ax,M5A_SEG_LEN
        mov SEGLEN,ax
        mov ah,M5A_SEG_000
        mov SEGLEN0,ah
        mov al,M5A_SIG_LEN
        mov SIGL,al
        mov ah,M5A_BEG
        mov SIGB,ah
        mov ax,M5A_LEN
        mov VIRLEN,ax
        mov ax,M5A_BEG_SEG
        mov SIG0B,ax
        mov ax,M5A_BEG_LEN
        mov SIGLB,ax
        pop di
        pop si
        pop ds
        pop es
        call INTERFACE
        ret
;-------------------------------------------------------------
VIRUS_66:
        push es
        push ds
        push si
        push di
        push cs
        pop ds
        push cs
        pop es
        jmp Micro_22
                            ;Сигнатура вируса
M22_SIG db 0BAh,09Eh,000h,0CDh,021h,093H,0B4H,040H
M22_SIG_LEN equ $-M22_SIG         ;Длина сигнатуры
M22_NAM db '<Micro_22/23  (OVR)>' ;Название вируса (max 20 символов)
M22_NAM_LEN equ $-M22_NAM         ;Длина названия вируса
M22_BEG equ 0                     ;0-добавлять, 1-вычитать смещение
M22_LEN equ 22                    ;Длина вирусного кода
M22_BEG_SEG equ 0                 ;Смещение начальных байт программы
M22_BEG_LEN equ 0                 ;Кол-во начальных байт программы
M22_SEG_LEN equ 0                 ;Смещение длины
M22_SEG_000 equ 0                 ;Вычитать смещение длины

Micro_22:
        call CLEAR_VIRNAM
        lea si,M22_NAM
        lea di,NAMVIR
        mov cx,M22_NAM_LEN
        cld
        rep movsb
        lea si,M22_SIG
        lea di,SIG
        mov cx,M22_SIG_LEN
        rep movsb
        mov ax,M22_SEG_LEN
        mov SEGLEN,ax
        mov ah,M22_SEG_000
        mov SEGLEN0,ah
        mov al,M22_SIG_LEN
        mov SIGL,al
        mov ah,M22_BEG
        mov SIGB,ah
        mov ax,M22_LEN
        mov VIRLEN,ax
        mov ax,M22_BEG_SEG
        mov SIG0B,ax
        mov ax,M22_BEG_LEN
        mov SIGLB,ax
        pop di
        pop si
        pop ds
        pop es
        call INTERFACE
        ret
;-------------------------------------------------------------
;//////////////////////////////////////////////////////////////
;Сюда и следует добавлять новые процедуры идентификации вирусов
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
;-------------------------------------------------------------
                               ;49th - число обезвреживаемых вирусов
INFORMATIONS db 0ah,0dh,0ah,0dh,'   <----------------------------------->'
             db 0ah,0dh,'   <-    АНТИВИРУС-ПОЛИФАГ DOG.67v    ->'
             db 0ah,0dh,'   <-    -------------------------    ->'
             db 0ah,0dh,'   <-      Некоммерческая версия      ->'
             db 0ah,0dh,'   <-     только для COM-программ     ->'
             db 0ah,0dh,'   <-    -------------------------    ->'
             db 0ah,0dh,'   <-    Автор:  И.В. Дикшев / ТГУ    ->'
             db 0ah,0dh,'   <-    -------------------------    ->'
             db 0ah,0dh,'   <-        Вызов: DOG [опции]       ->'
             db 0ah,0dh,'   <- Опции:                          ->'
             db 0ah,0dh,'   <-    f - поиск вирусов в файлах   ->'
             db 0ah,0dh,'   <-    c - лечение больных файлов   ->'
             db 0ah,0dh,'   <-    o - Ok для здоровых файлов   ->'
             db 0ah,0dh,'   <-    e - сообщать об ошибках      ->'
             db 0ah,0dh,'   <----------------------------------->'
             db 0ah,0dh,'$'
MODE         db ? ;Режим работы программы
CURED        db ' - обезврежен! :-)','$'
FSEG         dw ? ;Адрес сегмента тестируемой программы
NO_MEM       db 0ah,0dh,'Не хватает памяти для работы! :-(',0ah,0dh,'$'
FILEST       db ? ;Кол-во проверенных файлов
CMASK        db '*.com',0h
FILESI       db ? ;Кол-во инфицированных файлов
NOT_INFECT   db 0ah,0dh,'Вирусы не обнаружены! :-))','$'
FILESC       db ? ;Кол-во восстановленных файлов
FILES_ERR    db 07h,'Ошибка открытия файла!',07h,' :-()','$'
FLEN         dw ? ;Длина программы
MSGT         db ' файлов проверено',0ah,0dh,'$'
HANDLE       dw 0FFFFh ;Файловый номер открытого файла
MSGI         db ' файлов заражено',0ah,0dh,'$'
FATTR        dw ? ;Атрибуты файла
MSGC         db ' файлов восстановлено',0ah,0dh,'$'
FDATA        dw ? ;Дата создания файла
NOT_HAVE_V   db 07,' - звони Касперскому!',07,'$'
LONG_FILE    db ? ;Кол-во необследованных файлов
MSGLONG      db ' ошибок при открытии файлов',0ah,0dh,'$'
ONE_TESTED   db 0 ;Для запрета лечения несколькими подпрограммами одновременно
CLREOL       db 0ah,0dh,'$'
FTIME        dw ? ;Время создания файла
DOG_INFECTED db 0ah,0dh,0ah,0dh,'     Программа DOG искажена!',0ah,0dh
             db 0ah,0dh,0ah,0dh,'$'
Ident3B      db 0Ebh,00bh,090h
SIGB         db ? ;1 - добавлять, 0 - вычитать смещение начальных байт файла
SEGLEN       dw ? ;Смещение длины чистой программы
SEGLEN0      db ? ;1 - доб., 0 - вычитать смещение длины
VIRLEN       dw ? ;Длина вирусного кода (минимальная)
FLENOLD      dw ? ;Длина программы без вирусного кода (максимальная)
SIG          db 10 dup (?) ;Сигнатура вируса
SIGL         db ? ;Длина сигнатуры
SIG0         dw ? ;Смещение сигнатуры от начала сегмента
SIG0B        dw ? ;Смещение от начала сигнатуры до начальных байт файла
SIGLB        dw ? ;Кол-во начальных байт файла, модифицированных вирусом
ENTER_RET    db 0ah,0dh,'∙.∙.∙.∙.∙.∙.∙.∙.∙.∙.∙.∙.∙.∙.∙.∙.∙.∙'
             db '.∙.∙.∙.∙.∙.∙.∙.∙.∙.∙.∙.∙.∙',0ah,0dh,'$'
Ok_byte      db ?
Ok           db '- жив! :-)','$'
Er_byte      db ?
STR_BYTE     db ?
STRING       db 3 dup (?) ; Нужно для печати кол-ва файлов
WARNING      db 0ah,0dh,'Файл '
FNAME        db 12 dup (?)
             db ' болен вирусом '
NAMVIR       db 20 dup (?)
             db ' 8*O','$'
RESERVED     db 10 dup (?) ;Пока зарезервировано
;----------------------------------------------------------------
;-----------------------------------------------------------
DECODE_STRING:
     push ax
     push bx
     push cx
CALCULATE_BYTE:
     cmp STR_BYTE,10
     jnl DECODE
     jmp ENDE_DECODE
DECODE:
     inc STRING[1]
     sub STR_BYTE,10
     cmp STRING[1],10
     jl  CALCULATE_BYTE
     inc STRING[2]
     mov STRING[1],0
     jmp CALCULATE_BYTE
ENDE_DECODE:
     mov al,STRING[2]
     add al,30h
     mov ah,0eh
     int 10h
     mov al,STRING[1]
     add al,30h
     mov ah,0eh
     int 10h
     mov al,STR_BYTE
     add al,30h
     mov ah,0eh
     int 10h
     mov STR_BYTE,0
     mov STRING[0],0
     mov STRING[1],0
     mov STRING[2],0
     pop cx
     pop bx
     pop ax
ret
;-----------------------------------------------------------
LBL_L        db 0h   ;Версия антивируса, младшая часть значения
LBL_H        db 67  ;Версия антивируса, старшая часть значения
DOG_LENGTH equ $-DOCTOR
LBL          label byte
        CSEG ends
                end doctor
