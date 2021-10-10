
;      ▄▄                  █
;     ▀▀▀  Virus Magazine  █ Box 176, Kiev 210, Ukraine      IV  1997
;     ▀██ ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀ █ ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀ ▀ ▀▀▀▀▐▀▀▀  █▀▀▀▀▀▀█
;      ▐█ █▀▄ █▀▀ ▄▀▀ ▄▀▀ ▄█▄ ▄▀▀ █▀█    ▌ █ ▄▀█ █ ▄▀▀ █▄▄   █ █  █ █
;       █ █ █ █▀  █▀  █    █  █▀  █ █    █ █ █ █ █ █   █     █ █  █ █
;       █ ▐ ▐ ▐   ▐▄▄ ▐▄▄  ▐  ▐▄▄ ▐▄▀     ▀█ ▀▄█ ▐ ▐▄▄ ▐▄▄▄  █ █  █ █
;       ▐ ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄ ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄  █▄▄▄▄▄▄█
;          (C) Copyright, 1994-97, by STEALTH group WorldWide, unLtd.

; Данный материал позволяет программисту вируса перевести
; процессор в зашишенный режим!
; В этом самом режиме вирус может к примеру расшифровать некоторые
; данные!
;-------------------------------------------------------------------------
; Приведенная ниже программа делает следущее :
; - создает таблицы GDT и LDT используя текущие значения CS,DS,SS
; - запрещает ВСЕ прерывания,открывает линию A20 (для доступа к RAM>1mb)
; - переводит процессор в защищенный режим
; - в первый символ строки qw заносит символ L
; - выходит в реальный режим (разрешает прерывания,закрывает A20)
; - выводит на экран строку qw ('Light General')
; - exit to Dos



                .286
                .model tiny
                .code
                org     100h
;-------------------------------------------------------------------------
;       EQUs    for     protected mode program
;-------------------------------------------------------------------------
desc_struc      STRUC
                limit   dw      0
                base_l  dw      0
                base_h  db      0
                access  db      0
                rsrv    dw      0
desc_struc      ENDS

ACC_PRESENT     equ     10000000b
ACC_CSEG        equ     00011000b
ACC_DSEG        equ     00010000b
ACC_EXPDOWN     equ     00000100b
ACC_CONFORM     equ     00000100b
ACC_DATAWR      equ     00000010b

DATA_ACC  = ACC_PRESENT or ACC_DSEG or ACC_DATAWR                ; 10010010b
CODE_ACC  = ACC_PRESENT or ACC_CSEG or ACC_CONFORM               ; 10011100b
STACK_ACC = ACC_PRESENT or ACC_DSEG or ACC_DATAWR or ACC_EXPDOWN ; 10010110b

CSEG_SIZE  = 65535
DSEG_SIZE  = 65535
STACK_SIZE = 65535

CS_DESCR = (gdt_cs - gdt_0)
DS_DESCR = (gdt_ds - gdt_0)
SS_DESCR = (gdt_ss - gdt_0)

CMOS_PORT       equ     70h
STATUS_PORT     equ     64h
SHUT_DOWN       equ     0feh
A20_PORT        equ     0d1h
A20_ON          equ     0dfh
A20_OFF         equ     0ddh
INT_MASK_PORT   equ     21h
KBD_PORT_A      equ     60h
;-----------------------------------------------------------------------
start:

                call    init_protected_mode
                call    set_protected_mode
;--------------------------------------------
; Теперь тачка пребывает в защищенном режиме!
; Т.к. таблица прерываний реального режима HЕ МОЖЕТ быть использована
; в защищенном - то прерывания запрещены!!!
;***********************************************************************
;***********************************************************************
; Именно тут (или в конце предыдущей подпрограммы)
; должно вставить инструкции потребные вирусу!!!
;***********************************************************************
;***********************************************************************
                call    set_real_mode

                mov     ah,09
                lea     dx,qw
                int     21h

                mov     ax,4c00h
                int     21h
;-------------------------------------------------------------------------
setgdtentry     MACRO
                mov     [desc_struc.base_l][bx],ax
                mov     [desc_struc.base_h][bx],dl
                ENDM
;-------------------------------------------------------------------------
init_protected_mode     PROC
                mov     ax,ds
                mov     dl,ah
                shr     dl,4
                shl     ax,4    ; AX:DL = физический адрес сегмента DS
;---- DS ---------------------------
                mov     bx,offset gdt_ds
                setgdtentry
;---- GDTR ---------------------------
                mov     bx,offset gdt_gdt
                add     ax,offset gdtr
                adc     dl,0
                setgdtentry
;---- CS ---------------------------
                mov     bx,offset gdt_cs
                mov     ax,cs
                mov     dl,ah
                shr     dl,4
                shl     ax,4
                setgdtentry
;---- SS ---------------------------
                mov     bx,offset gdt_ss
                mov     ax,ss
                mov     dl,ah
                shr     dl,4
                shl     ax,4
                setgdtentry
;--------------------------------------------
                push    ds
                mov     ax,40h
                mov     ds,ax
                mov     word ptr ds:[0067h],offset shutdown_return
                mov     word ptr ds:[0069h],cs
                pop     ds

                cli
                in      al,INT_MASK_PORT
                and     al,0ffh
                out     INT_MASK_PORT,al

                mov     al,8fh
                out     CMOS_PORT,al
                jmp     $+2
                mov     al,5
                out     CMOS_PORT+1,al
                ret
init_protected_mode     ENDP
;-------------------------------------------------------------------------
set_protected_mode      PROC
                call    enable_a20
                mov     real_ss,ss

;----- GOTO Protected mode! -------------
                ideal
                p286
                lgdt    [QWORD gdt_gdt] ; db 0Fh,01h,16h  dw offset gdt_gdt
                mov     ax,0001h
                lmsw    ax              ; db    0fh,01h,0f0h
;-----------------------------------------
                masm
                .286

;               jmp     far flush

                db      0eah
                dw      offset flush
                dw      CS_DESCR
;------------------------------------------
flush:
                mov     ax,SS_DESCR
                mov     ss,ax
                mov     ax,DS_DESCR
                mov     ds,ax
                mov     byte ptr ds:[offset qw+2],'L'
                ret
set_protected_mode      ENDP
;-------------------------------------------------------------------------
set_real_mode   PROC
                mov     real_sp,sp
                mov     al,SHUT_DOWN
                out     STATUS_PORT,al
wait_reset:
                hlt
                jmp     wait_reset
;-----------------------------------
shutdown_return:
                push    cs
                pop     ds

                mov     ss,real_ss
                mov     sp,real_sp

                call    disable_a20

                mov     ax,000dh
                out     CMOS_PORT,al

                in      al,INT_MASK_PORT
                and     al,0
                out     INT_MASK_PORT,al
                sti

                ret
set_real_mode   ENDP
;-------------------------------------------------------------------------
enable_a20      PROC
                mov     al,A20_PORT
                out     STATUS_PORT,al
                mov     al,A20_ON
                out     KBD_PORT_A,al
                ret
enable_a20      ENDP
;-------------------------------------------------------------------------
disable_a20     PROC
                mov     al,A20_PORT
                out     STATUS_PORT,al
                mov     al,A20_OFF
                out     KBD_PORT_A,al
                ret
disable_a20     ENDP
;-------------------------------------------------------------------------
real_sp         dw      ?
real_ss         dw      ?
qw      db      13,10,'?ight General',13,10,'$'

GDT_BEG = $

gdtr    label   WORD
gdt_0   desc_struc <0,0,0,0,0>
gdt_gdt desc_struc <GDT_SIZE-1  ,,,DATA_ACC,0>
gdt_ds  desc_struc <DSEG_SIZE-1 ,,,DATA_ACC,0>
gdt_cs  desc_struc <CSEG_SIZE-1 ,,,CODE_ACC,0>
gdt_ss  desc_struc <STACK_SIZE-1,,,DATA_ACC,0>

GDT_SIZE = ( $ - GDT_BEG )
;-------------------------------------------------------------------------
                END     start

; Материал выцарапан из книги :
; "Защишенный режим процессоров intel 80286/80386/80486" А.В.Фролов,
; Г.В.Фролов
; Hабито,переделано и отлажано :
; Light General
; (извИЕняюсь за отсутствие определения процессоров,ПРИДЕЛАЕТЕ САМИ!!!,
; а так-Же за отсутствие коMMMентариев - т.к. пришлось бы набивать всю 
; книгу)