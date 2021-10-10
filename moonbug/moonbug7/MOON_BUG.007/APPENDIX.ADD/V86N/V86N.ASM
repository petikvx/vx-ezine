;--------------------------------------------------------------------------------------
; CopyRight [C] 1997-1998 RAM Scanner // [CiD], VD. All Rights Reserved
;--------------------------------------------------------------------------------------
.Model Tiny
.386p
.Code

		Jumps
		Locals @@

Br		Equ Byte Ptr
Wr		Equ Word Ptr
Dr		Equ Dword Ptr
Ofs		Equ Offset
;--------------------------------------------------------------------------------------
; Структурка, описывающая состояние стека после	командочки PUSHAD в процедурке
; GPF_Trap
;--------------------------------------------------------------------------------------
StackRegs	Struc
		RegEDI	Dd ?
		RegESI	Dd ?
		RegEBP	Dd ?
		RegESP	Dd ?
		RegEBX	Dd ?
		RegEDX	Dd ?
		RegECX	Dd ?
		RegEAX	Dd ?

		OldEIP	Dd ?
		OldCS	Dd ?
		OldEFL	Dd ?
		OldESP	Dd ?
		OldSS	Dd ?

		OldES	Dd ?
		OldDS	Dd ?
		OldFS	Dd ?
		OldGS	Dd ?
		Ends
;--------------------------------------------------------------------------------------
Include		Macrosez.Inc
;--------------------------------------------------------------------------------------
Start:
		jmp	Install_PGM
;--------------------------------------------------------------------------------------
; DS=сегмент данных
;**************************************************************************************
; Описываем GDT
;--------------------------------------------------------------------------------------
GDT		Label Byte
;--------------	Пустой селектор	-------------------------------------------------------
		Dq 0
;--------------	Енто наш селектор кода ------------------------------------------------
Sel_CODE	= $-GDT
		Dw	0ffffh		     ; Размер
		Dw	0		     ; Начало сегмента
		GdLimit	0,0,0
		PlType	0,Ex_Rd
		Dw	@Code
;--------------	А енто наш сегмент данных ---------------------------------------------
Sel_DATA	= $-GDT
		Dw	0ffffh
		Dw	0
		GdLimit	0,0,0
		PlType	0,Rd_Wr
		Dw	@Code
;--------------	Енто флат сегмент -----------------------------------------------------
Sel_FLAT	= $-GDT
		Dw	0ffffh
		Dw	0
		GdLimit	1,0,0
		PlType	0,Rd_Wr
		Dw	0
;--------------	Селектор видеопамяти --------------------------------------------------
Sel_VIDEO	= $-GDT
		Dw	0ffffh
		Dw	0
		GdLimit	0,0,0
		PlType	0,Rd_Wr
		Dw	0b800h
;--------------	Енто TSS задачи	v86 ---------------------------------------------------
Sel_TSS_V86	= $-GDT
		Dw	(Type SysTask)-1
		Dw	Ofs SysTask
		GdLimit	0,0,0
		PlType	0,XTSS
		Dw	@Code
;--------------	Энто два селектора для INT 15 -----------------------------------------
Sel_SRC		= $-GDT
Sel_Src_Addr    Dq      0
Sel_DST		= $-GDT
Sel_Dst_Addr    Dq      0
;--------------------------------------------------------------------------------------
GDTSize		= $-GDT
;**************************************************************************************
; IDT поехала...
;--------------------------------------------------------------------------------------
IDT		Label Word
;--------------	Это программные	эксепшены ---------------------------------------------
		Irp	No,<00,01,02,03,04,05,06,07,08,09,10,11,12,13,14,??>
		Dw	Fault_&No,Sel_CODE,(XInt_Gate Or 80h) Shl 8,0
		Endm

		Irp	No,<??,??,??,??,??,??,??,??,??,??,??,??,??,??,??,??>
		Dw	Fault_&No,Sel_CODE,(XInt_Gate Or 80h) Shl 8,0
		Endm
;--------------	Хардверные эксепшены сюда заремувили ----------------------------------
		Irp	No,<00,01,02,03,04,05,06,07,08,09,0a,0b,0c,0d,0e,0f>
		Dw	HWInt_&No,Sel_CODE,(XInt_Gate Or 80h) Shl 8,0
		Endm
IDTSize		= $-IDT
;--------------------------------------------------------------------------------------
; Небольшая отвлекалка
;--------------------------------------------------------------------------------------
;--------------------------------------------------------------------------------------
; TSS задачи V86
;--------------------------------------------------------------------------------------
SysTask		XTaskSegment <>
;**************************************************************************************
; Точки	входа в	программные эксепшены
;--------------------------------------------------------------------------------------
; Куда перейти ───────┐
; Номер	эксепшена ─┐  │
; Имя метки ────┐  │  │
FaultJmp	00,00,ReflectVM
FaultJmp	01,01,ReflectVM
FaultJmp	02,02,ReflectVM
FaultJmp	03,03,ReflectVM
FaultJmp	04,04,GPF_Trap
FaultJmp	05,05,ReflectVM
FaultJmp	06,06,GPF_Trap
FaultJmp	07,07,GPF_Trap
FaultJmp	08,08,GPF_Trap_Err
FaultJmp	09,09,GPF_Trap
FaultJmp	10,10,GPF_Trap_Err
FaultJmp	11,11,GPF_Trap_Err
FaultJmp	12,12,GPF_Trap_Err
FaultJmp	GP,13,GPF_Trap_Err
FaultJmp	14,14,GPF_Trap_Err
FaultJmp	15,15,GPF_Trap
FaultJmp	16,16,GPF_Trap
FaultJmp	??,32,GPF_Trap

;**************************************************************************************
; Это поехал код обработки аппаратных прерываний
;--------------------------------------------------------------------------------------
; Куда перейти ────────┐
; Номер	эксепшена──┐   │
; Имя метки ────┐  │   │
HardwIntJmp	00,08h,ReflectVM
HardwIntJmp	01,09h,ReflectVM
HardwIntJmp	02,0ah,ReflectVM
HardwIntJmp	03,0bh,ReflectVM
HardwIntJmp	04,0ch,ReflectVM
HardwIntJmp	05,0dh,ReflectVM
HardwIntJmp	06,0eh,ReflectVM
HardwIntJmp	07,0fh,ReflectVM
HardwIntJmp	08,70h,ReflectVM
HardwIntJmp	09,71h,ReflectVM
HardwIntJmp	0a,72h,ReflectVM
HardwIntJmp	0b,73h,ReflectVM
HardwIntJmp	0c,74h,ReflectVM
HardwIntJmp	0d,75h,ReflectVM
HardwIntJmp	0e,76h,ReflectVM
HardwIntJmp	0f,77h,ReflectVM
;--------------------------------------------------------------------------------------
; Падалка с кодом ошибки. Отсюдова выгребается код ошибки в вариаблу
; FaultErrCode и заодно задается адрес строчки в которую она будет
; впечатываться. TrapErr==0xff говорит о том, что валились с ErrorCode
;--------------------------------------------------------------------------------------
GPF_Trap_Err	Proc Near
		push	ds					; Сохраним DS
		mov	ds,cs:[Sel_DATA$]			;-)
		pop	[REG_Ds]				; Вытащим его значение
		mov	[StackSeg],ss
		mov	[StackAdr],esp
		mov	[REG_Es],es				; Ну это no comments
		mov	[REG_Gs],gs
		mov	[REG_Fs],fs
		pop	dr ds:[FaultNumber]
		pop	dr ds:[FaultErrCode]
		mov	[MSG_ErrCode],ofs DIG_ErrCode
		push	dr ds:[FaultNumber]
		mov	[TrapErr],0ffh				; Есть ErrCode
GPF_Trap_Err	Endp
;--------------------------------------------------------------------------------------
; Падаем по ошибке. Отсюдова вываливаем Panic Dump. Расскажем все-все про
; регистры и прочую фуфню.
;--------------------------------------------------------------------------------------
GPF_Trap	Proc Near
		push	ds					; Спасаем DS
		mov	ds,cs:[Sel_DATA$]			;-)
		cmp	[TrapErr],0ffh				; Все уже заполнено ?
		jz	@@SegRegs_Saved				; Если так, то выходим
		pop	[REG_Ds]				; иначе	спасаем
		mov	[REG_Es],es				; сегментные регистры
		mov	[REG_Gs],gs
		mov	[REG_Fs],fs
		jmp	@@Cont_GPF_Trap				; выходим
@@SegRegs_Saved:
		add	esp,2					; Убрать со стека DS
@@Cont_GPF_Trap:
		mov	es,[Sel_DATA$]
		mov	fs,[Sel_FLAT$]

		mov	[StackSeg],ss
		mov	[StackAdr],esp
		pop	dr ds:[FaultNumber]
		pushad
;--------------	Ну, понеслось... ------------------------------------------------------
		mov	ebp,esp
		cld
;--------------	Говорим	номер фаульта -------------------------------------------------
		mov	di,ofs DIG_ExcNum
		mov	al,br [FaultNumber]
		call	OutByte
;--------------	Говорим	ErrorCode -----------------------------------------------------
		mov	di,ofs DIG_ErrCode
		mov	eax,[FaultErrCode]
		call	OutDword
;--------------	Говорим	про CR0, CR2 и CR3 --------------------------------------------
		mov	eax,cr0
		mov	di,ofs DIG_Cr0
		call	OutDword

		mov	eax,cr2
		mov	di,ofs DIG_Cr2
		call	OutDword

		mov	eax,cr3
		mov	di,ofs DIG_Cr3
		call	OutDword

;-------------- Расскажем про флажки префиксов ----------------------------------------
                mov     ax,[PrefixFlags]
                mov     di,ofs DIG_Prefix
                call    OutWord

;--------------	Заполним fault instruction --------------------------------------------
; Упасть можно в двух местах - из V86 и	из KeRNeL. Вычисляться адрес инструкции
; при этом будет по разному.
;--------------------------------------------------------------------------------------
		mov	eax,[ebp][StackRegs.OldCS]		; eax:esi - адрес
		mov	esi,[ebp][StackRegs.OldEIP]		; откуда свалились
;--------------	Выводим	адрес, где упали ----------------------------------------------
		call	OutFaultAddr				; честно его рисуем
;-------------- А не из V86 ли мы свалилися то ? --------------------------------------
		test	[ebp][StackRegs.OldEFL],00020000h	; VM86 ?
		jz	@@GetInstrAdr_KRNL			; Если нет - kernl упал
;--------------	Рухнул v86, конвертим во флат адрес -----------------------------------
		movzx	eax,ax
		shl	eax,4					; Считаем флат адрес
		add	eax,esi
		push	eax					; запомним
;-------------- Зарисуем V86 Stack ----------------------------------------------------
                mov     eax,[ebp][StackRegs.OldSS]              ; стек выгребли
		mov	esi,[ebp][StackRegs.OldESP]
		call	OutStackAddr				; зарисовали
;-------------- И сегментные регистры V86 тожа зарисуем -------------------------------
		mov	ax,wr [ebp][StackRegs.OldES]		; Добываем значения
		mov	di,ofs DIG_Es				; сегментных регистров
		call	OutWord					; v86 задачи ;-)

		mov	ax,wr [ebp][StackRegs.OldDS]
		mov	di,ofs DIG_Ds
		call	OutWord

		mov	ax,wr [ebp][StackRegs.OldFS]
		mov	di,ofs DIG_Fs
		call	OutWord

		mov	ax,wr [ebp][StackRegs.OldGS]
		mov	di,ofs DIG_Gs
		call	OutWord
;-------------- Тут в ESI flat адрес откель рухнули -----------------------------------
		pop	esi					; восстановили флат
;--------------	Debug -----------------------------------------------------------------
		mov	di,ofs DIG_FlatAddr
		mov	eax,esi
		call	OutDword
;-------------- Выводим состояние виртуального IFF ------------------------------------
		mov	[IFF_Status],ofs MSG_IFF_En
                cmp     [Virtual_IF],INT_ENABLED
		je	@@Int_Enabled
		mov	[IFF_Status],ofs MSG_IFF_Dis
@@Int_Enabled:
;--------------------------------------------------------------------------------------
		mov	fs,[Sel_FLAT$]				; адрес
		jmp	@@FaultAddrDone				; пошли	код рисовать
;--------------	Если рухнул KeRNeL, то стек надо выдать	-------------------------------
@@GetInstrAdr_KRNL:

		mov	[IFF_Status],ofs MSG_IFF_Un

		push	eax					; запомним сей великий
		push	esi					; адрес

		mov	ax,[REG_ES]				; Сегментные регистры
		mov	di,ofs DIG_Es				; для случая
		call	OutWord					; падения внутри
								; Kernel добываются
		mov	ax,[REG_DS]				; по другому
		mov	di,ofs DIG_Ds
		call	OutWord

		mov	ax,[REG_FS]
		mov	di,ofs DIG_Fs
		call	OutWord

		mov	ax,[REG_GS]
		mov	di,ofs DIG_Gs
		call	OutWord

		movzx	eax,[StackSeg]				; вытащим стек отсюда
		mov	esi,[StackAdr]				; т.к. не менялся PL
		call	OutStackAddr				; зарисуем его
		pop	esi					; вернем адрес
		pop	eax					; tha same
		mov	fs,ax					; CS у нас EX_RD ;-)
;--------------------------------------------------------------------------------------
; fs:esi - адрес откель	упали
;--------------------------------------------------------------------------------------
@@FaultAddrDone:
		mov	di,ofs DIG_Instr
		mov	cl,16
@@OutFaultInstrLoop:
		mov	al,fs:[esi]				; Байтик выгребли
		inc	esi
		call	OutByte					; нарисовали
		inc	di
		dec	cl
		jnz	@@OutFaultInstrLoop			; NexT 0nE ;-)

;--------------	Расскажем все про регистры --------------------------------------------

		mov	eax,[ebp][StackRegs.OldEFL]
		mov	di,ofs DIG_EFlags
		call	OutDword

		mov	eax,[ebp][StackRegs.RegEDI]
		mov	di,ofs DIG_Edi
		call	OutDword

		mov	eax,[ebp][StackRegs.RegESI]
		mov	di,ofs DIG_Esi
		call	OutDword

		mov	eax,[ebp][StackRegs.RegEBP]
		mov	di,ofs DIG_Ebp
		call	OutDword

		mov	eax,[ebp][StackRegs.RegEBX]
		mov	di,ofs DIG_Ebx
		call	OutDword

		mov	eax,[ebp][StackRegs.RegEDX]
		mov	di,ofs DIG_Edx
		call	OutDword

		mov	eax,[ebp][StackRegs.RegECX]
		mov	di,ofs DIG_Ecx
		call	OutDword

		mov	eax,[ebp][StackRegs.RegEAX]
		mov	di,ofs DIG_Eax
		call	OutDword
;--------------	Расскажем про число интерраптов	---------------------------------------

		mov	eax,[HWintCount]
		mov	di,ofs DIG_HWInt
		call	OutDword

		mov	eax,[SWIntCountL]
		mov	di,ofs DIG_SWIntL
		call	OutDword

		mov	eax,[SWIntCountH]
		mov	di,ofs DIG_SWIntH
		call	OutDword

;--------------	Чистим экран ----------------------------------------------------------
		push	es
		mov	es,[Sel_VIDEO$]
		xor	di,di
		mov	cx,2000
		xor	ax,ax
		rep	stosw
		pop	es
;--------------	Комментируем эксепшн --------------------------------------------------
                mov     bx,wr [FaultNumber]                    ; А валидный ли у нас
                cmp     bx,MaxFaultNum                         ; FaultNumber ?
                jbe     @@FaultNum_OK                          ; Опс, валидный :-)
                mov     bx,0fh                                 ; Если невалидный то нехай 0fh
@@FaultNum_OK:
                shl     bx,1                                   ; Выгребаем адрес
                mov     bx,[EXC_Table][bx]                     ; мессаги
                mov     [MSG_ExcName],bx                       ; Прописываем его
;--------------	Вырисовываем все это дело на экране -----------------------------------
		xor	bx,bx
@@DisplayRegsLoop:
		mov	si,[MSG_Table][bx]
		cmp	si,0ffffh
		jz	@@Regs_Displayed
		mov	dx,wr [MSG_YX][bx]
		call	WriteStrXY
		add	bx,2
		jmp	@@DisplayRegsLoop
@@Regs_Displayed:
;--------------------------------------------------------------------------------------
; С этого места	делаются потуги	завершиться. Ожидаем клавишу, после чего вываливаемся
; в RealMode
;--------------	Сваливаем отседова ----------------------------------------------------
@@WaitKey:
		in	al,60h
		cmp	al,1
		jnz	@@WaitKey
;--------------------------------------------------------------------------------------
; Точка	входа для выхода из PM в RealMode
;--------------------------------------------------------------------------------------
Go_PM_RM	Label Byte
;-------------- Копируем DOS назад вниз -----------------------------------------------
                call    Enable_A20
                jc      @@Dont_Copy                                       ; Это сакс, придется не копировать
;-------------- Ахтунг, стек трогать тут нельзя, он пофиксится :-) --------------------
                mov     ds,cs:[Sel_FLAT$]
                push    ds
                pop     es
                cld
                mov     esi,cs:[Mirror_Region]
                xor     edi,edi
                mov     ecx,44000h
                rep     movs dr es:[edi],ds:[esi]
                mov     ds,cs:[Sel_DATA$]
;--------------	Сбросим	PIC'и ---------------------------------------------------------
@@Dont_Copy:
                mov     al,20h
		out	20h,al
		out	0a0h,al
;-------------- Ремувим IRQшники назад как было ---------------------------------------
                mov     [PIC_1_Int],8h
		mov	[PIC_2_Int],70h
		call	Prog_PIC
;-------------- Пытаемся выйти в RealMode ---------------------------------------------

		lidt	STUB_IDT

                mov     eax,cr0                                ; Сбрасываем PE
		and	eax,(Not 1)
		mov	cr0,eax

                Db      0eah                                   ; Делаем FAR JMP @@ShutDown
		Dw	@@ShutDown
		Dw	@Code

STUB_IDT        Label Qword                                    ; Дефолтная IDT
                Dw      1024                                   ; для RealMode
		Dd	0

;--------------	С этого	места мы в RM -------------------------------------------------
@@ShutDown:

                mov     ax,cs                                  ; Стек - прежде всего
		mov	ss,ax
		mov	sp,ofs KernelStack

                push    cs                                     ; заодно кривые
                pop     ds                                     ; лимиты погрохаем
		push	cs
		pop	es

                in      al,60h                                 ; Чтобы взвиса не було

;-------------- Снимаем лочку с блока памяти ------------------------------------------
                mov     ah,0dh
                mov     dx,[Mirror_Handle]
                call    dr [XMS_Entry]
                test    al,al
                jz      @@XMS_Failure
;-------------- Освобождаем блок ------------------------------------------------------
                mov     ah,0ah
                call    dr [XMS_Entry]
;--------------------------------------------------------------------------------------
@@XMS_Failure:
                mov     es,cs:[MyPSP]
                mov     ah,49h
                int     21h

                call    UpTime

                mov     ax,4c00h                               ; Asta la basta :-)
		int	21h

		Db	4,'TraP HaNdLeR',4
GPF_Trap	Endp
;--------------------------------------------------------------------------------------
UpTime          Proc    Near
                mov     ah,2
                int     1ah

                mov     al,ch
                call    CorrectTime
                mov     ch,al
                mov     al,cl
                call    CorrectTime
                mov     cl,al
                mov     al,dh
                call    CorrectTime
                mov     dh,al
                xor     dl,dl

                mov     ah,2dh
                int     21h
                ret
UpTime          Endp
;--------------------------------------------------------------------------------------
CorrectTime     Proc    Near
                push    ax
                shr     al,4
                mov     bl,0ah
                mul     bl
                pop     bx
                and     bl,0fh
                add     al,bl
                ret
CorrectTime     Endp
;--------------------------------------------------------------------------------------
; Эта процедурка сделана в обход остальных. Если что валим отседова на
; Fault_GP - там стандартная обработка
;--------------------------------------------------------------------------------------
Fault_13	Proc Near
		test	[esp][12],00020000h			; Из V86 выпали	?
		jz	Fault_GP				; Если нет

;--------------------------------------------------------------------------------------
; Все дальнейшее вправляние мозгов идет	через этот инклуд
;--------------------------------------------------------------------------------------
Include		Fault13.Inc
Fault_13	Endp
;--------------------------------------------------------------------------------------
ReflectVM	Proc Near
		test	[esp][12],00020000h
		jz	Fault_GP
		mov	ds,cs:[Sel_DATA$]
		mov	fs,[Sel_FLAT$]
		inc	[HWIntCount]
		pop	[@@HWInt_No]
;--------------------------------------------------------------------------------------
; Сюда попадаем если прерывания внутри v86 задачи разрешены, и стоит их
; зарефлектить.
;--------------	Эмулируем аппаратные инты ---------------------------------------------

		pushad
		mov	ebp,esp
		movzx	ebx,wr [@@HWInt_No]

;--------------	Дебажим'с -------------------------------------------------------------

                jmp     Do_Interrupt
@@HWInt_No	Dd	?
ReflectVM	Endp
;--------------------------------------------------------------------------------------
; Могучая область данных ;-) Адреса строк составляющих Panic Dump
;--------------------------------------------------------------------------------------
MSG_Table       Dw MSG_Exception
		Dw MSG_ExcNum
		Dw Msg_ErrCodeT
MSG_ErrCode	Dw MSG_ExcNoneT				; Адрес	строки с FaultErrorCode
		Dw MSG_Registers
		Dw MSG_Eax
		Dw MSG_Ecx
		Dw MSG_Edx
		Dw MSG_Ebx
		Dw MSG_Ebp
		Dw MSG_Esi
		Dw MSG_Edi
		Dw MSG_CSEIP
		Dw MSG_Instr
		Dw MSG_SSESP
		Dw MSG_EFlags
IFF_Status	Dw MSG_IFF_Un				; Virtual IFF
		Dw MSG_Ds
		Dw MSG_Es
		Dw MSG_Gs
		Dw MSG_Fs
		Dw MSG_Cr0
		Dw MSG_Cr2
		Dw MSG_Cr3
		Dw MSG_HWInt
		Dw MSG_SWInt
		Dw MSG_Reboot
MSG_ExcName	Dw ?					; Расшифровка exception
		Dw 0ffffh

MSG_YX		Db 0,0					; Exception
		Db 1,0					; ExcNum
		Db 2,0					; ErrCodeT
		Db 2,22					; ErrCode/ExcNoneT
		Db 3,0					; Registers
		Db 4,0					; Eax
		Db 4,20					; Ecx
		Db 5,0					; Edx
		Db 5,20					; Ebx
		Db 6,0					; Ebp
		Db 7,0					; Esi
		Db 7,20					; Edi
		Db 8,0					; CSEIP
		Db 9,0					; Instr
		Db 10,0					; SSESP
		Db 11,0					; EFlags
                Db 11,41                                ; Virtual IFF
		Db 12,0					; DS
		Db 12,12				; ES
		Db 12,24				; GS
		Db 12,36				; GS
		Db 14,0					; Cr3
		Db 15,0					; Cr2
		Db 16,0					; Cr0
		Db 18,0					; HWInt
		Db 19,0					; SWInt
		Db 21,0					; Reboot
		Db 1,24					; Exc Name

FaultErrCode	Dd ?					; Код ошибки
FaultNumber	Dd ?					; Номер	эксепшна

StackSeg	Dw ?					; Стек при входе в обработчик
StackAdr	Dd ?					; соответственно
TrapErr		Db 0					; Устанавливается в 0ff	при
							; сваливании с ErrorCode
REG_Ds		Dw ?
REG_Es		Dw ?
REG_Fs		Dw ?
REG_Gs		Dw ?

Sel_DATA$	Dw Sel_DATA
Sel_FLAT$	Dw Sel_FLAT
Sel_VIDEO$	Dw Sel_VIDEO
Sel_SRC$        Dw Sel_SRC
Sel_DST$        Dw Sel_DST

SysColor	Db 0ah
DefaultColor	Equ 0ah					; Дефолтный цвет

HWIntCount	Dd ?					; Счетчик хардверных интов
SWIntCountL	Dd ?					; Счетчих софтверных интов
SWIntCountH	Dd ?

V86_IDT_Addr	Dd 0					; LIDT эмулить будем ;-)
MyPSP           Dw ?
;--------------------------------------------------------------------------------------
; Фичи касабельные виртуальной памяти
;--------------------------------------------------------------------------------------
XMS_Entry       Dd ?                                    ; Адрес вызова XMS драйвера
Mirror_Handle   Dw ?
Mirror_Region   Dd ?                                    ; Плоский адрес региона в верхней памяти
A20_Type        Dw ?                                    ; Тип A20

;--------------------------------------------------------------------------------------
; Всякие мессаги разные
;--------------------------------------------------------------------------------------

EXC_0		Db 1,0eh,'Divide overflow',0
EXC_1		Db 1,0eh,'Single step',0
EXC_2		Db 1,0eh,'NonMaskable interrupt',0
EXC_3		Db 1,0eh,'BreakPoint',0
EXC_4		Db 1,0eh,'INTO detected overflow',0
EXC_5		Db 1,0eh,'Bound range exceeded',0
EXC_6		Db 1,0eh,'Invalid opcode',0
EXC_7		Db 1,0eh,'FPU extension unavailable',0
EXC_8		Db 1,0eh,'Double exception',0
EXC_9		Db 1,0eh,'FPU protection error',0
EXC_A		Db 1,0eh,'Invalid TSS',0
EXC_B		Db 1,0eh,'Segment not present',0
EXC_C		Db 1,0eh,'Stack fault',0
EXC_D		Db 1,0eh,'General protection violation',0
EXC_E		Db 1,0eh,'Page fault',0
EXC_F		Db 1,0eh,'It seems to be $uXX - Call programmer',0
EXC_10          Db 1,0eh,'HALT with no Hardware interrupts enabled',0
EXC_11          Db 1,0eh,'Could not enable A20 gate',0

EXC_Table	Dw EXC_0
		Dw EXC_1
		Dw EXC_2
		Dw EXC_3
		Dw EXC_4
		Dw EXC_5
		Dw EXC_6
		Dw EXC_7
		Dw EXC_8
		Dw EXC_9
		Dw EXC_A
		Dw EXC_B
		Dw EXC_C
		Dw EXC_D
		Dw EXC_E
		Dw EXC_F
                Dw EXC_10
                Dw EXC_11

MSG_Exception	Db 1,0fh
		Db 'RSVM86 Panic Dump: KeRNeL Fault/Exception detected',0
MSG_ExcNum	Db 1,0bh
		Db 'Exception number ['
DIG_ExcNum	Db '00] -',0

MSG_ErrCodeT	Db 'Exception error code [',0
DIG_ErrCode	Db '00000000]',0
MSG_ExcNoneT	Db 'Not present]',0

MSG_Registers	Db 1,0ch
		Db '---== CPU register values ==---',0

MSG_Eax		Db 'EAX = ['
DIG_Eax		Db '00000000]',0

MSG_Ecx		Db 'ECX = ['
DIG_Ecx		Db '00000000]',0

MSG_Edx		Db 'EDX = ['
DIG_Edx		Db '00000000]',0

MSG_Ebx		Db 'EBX = ['
DIG_Ebx		Db '00000000]',0

MSG_Ebp		Db 'EBP = ['
DIG_Ebp		Db '00000000]',0

MSG_Esi		Db 'ESI = ['
DIG_Esi		Db '00000000]',0

MSG_Edi		Db 'EDI = ['
DIG_Edi		Db '00000000]',0

MSG_CSEIP	Db 1,0bh
		Db 'Fault address: ['
DIG_CS		Db '0000:'
DIG_EIP		Db '00000000] - Flat Address: ['
DIG_FlatAddr	Db '■ None ■]',0

MSG_Instr	Db 1,0fh
		Db 'Fault instruction: ['
DIG_Instr	Db '00∙00∙00∙00∙00∙00∙00∙00∙00∙00∙00∙00∙00∙00∙00∙00]',0

MSG_SSESP	Db 1,0eh
		Db 'Task stack: ['
DIG_SS		Db '0000:'
DIG_ESP		Db '00000000]',0

MSG_EFlags	Db 1,0bh
		Db 'Task flags: ['
DIG_EFlags      Db '00000000] Prefix FLG ['
DIG_Prefix      Db '0000]',0

MSG_Ds		Db 'DS = ['
DIG_Ds		Db '0000]',0

MSG_Es		Db 'ES = ['
DIG_Es		Db '0000]',0

MSG_Gs		Db 'GS = ['
DIG_Gs		Db '0000]',0

MSG_Fs		Db 'FS = ['
DIG_Fs		Db '0000]',0

MSG_Cr3		Db 'CR3 = ['
DIG_Cr3		Db '00000000]',0

MSG_Cr2		Db 'CR2 = ['
DIG_Cr2		Db '00000000]',0

MSG_Cr0		Db 'CR0 = ['
DIG_Cr0		Db '00000000]',0

MSG_HWInt	Db 1,0bh
                Db 'Reflected IRQ counter = ['
DIG_HWInt	Db '00000000]',0

MSG_SWInt	Db 1,0bh
                Db 'Reflected INT counter = ['
DIG_SWIntH	Db '00000000'
DIG_SWIntL	Db '00000000]',0

MSG_IFF_En	Db 'Virtual interrupt state [Enabled]',0
MSG_IFF_Dis	Db 'Virtual interrupt state [Disabled]',0
MSG_IFF_Un	Db 'Virtual interrupt state [N/A]',0

MSG_Reboot      Db 'Press [ESCape] for a deactivate RSVM86 attempt.',0

;--------------------------------------------------------------------------------------
; Стек монитора	- на 2 вложенности + 256 байт на все про все. Все равно	3-го уровня
; вложенности тут не будет
;--------------------------------------------------------------------------------------
		Db ((Type (StackRegs)) Shr 3) *	2 + 64 Dup ('∙StAcK∙',0)
KernelStack	Label Word
;--------------------------------------------------------------------------------------
; Порядок процедур нельзя менять !!! Промеж имями ничего нельзя	вставлять !!! ;-)
; Везде	предполагается,	что DF=0
;--------------------------------------------------------------------------------------
; Вход:	eax - слово
; Вывод	слова в	es:di, портит eax,di
;--------------------------------------------------------------------------------------
OutDword	Proc Near
		push	eax
		shr	eax,16
		call	OutWord
		pop	eax
OutDword	Endp
;--------------------------------------------------------------------------------------
; Вход:	ax - слово
; Вывод	слова в	es:di, портит ax,di
;--------------------------------------------------------------------------------------
OutWord		Proc Near
		xchg	al,ah
		call	OutByte
		xchg	al,ah
OutWord		Endp
;--------------------------------------------------------------------------------------
; Вход:	al - байт
; Вывод	байта в	es:di, портит al, di
;--------------------------------------------------------------------------------------
OutByte		Proc Near
		push	ax
		shr	al,4
		call	@@OutByteLoc
		pop	ax
@@OutByteLoc:
		and	al,0fh
		cmp	al,0ah
		sbb	al,69h
		das
		stosb
		ret
OutByte		Endp
;--------------------------------------------------------------------------------------
; Заполнялка CS:EIP. На	входе -	AX:ESI - адрес
;--------------------------------------------------------------------------------------
OutFaultAddr	Proc Near
		push	eax
		mov	di,ofs DIG_CS
		call	OutWord
		mov	eax,esi
		mov	di,ofs DIG_EIP
		call	OutDword
		pop	eax
		ret
OutFaultAddr	Endp
;--------------------------------------------------------------------------------------
; Заполнялка SS:ESP. На	входе -	AX:ESI - адрес
;--------------------------------------------------------------------------------------
OutStackAddr	Proc Near
		push	eax
		mov	di,ofs DIG_SS
		call	OutWord
		mov	eax,esi
		mov	di,ofs DIG_ESP
		call	OutDword
		pop	eax
		ret
OutStackAddr	Endp
;--------------------------------------------------------------------------------------
; Пишет	ASCIIZ на экран
; DH - Y, DL - X, DS:SI	адрес строки
;--------------------------------------------------------------------------------------
WriteStrXY	Proc Near
		mov	gs,[Sel_VIDEO$]
		push	ax
		push	di
		push	si
		xor	ax,ax
		mov	al,dl
		shl	ax,5
		mov	di,ax
		shl	ax,2
		add	di,ax
		mov	al,dh
		cbw
		shl	ax,1
		add	di,ax
@@WriteStrLoop:
		lodsb
		test	al,al
		jz	@@WriteStrEnd
		cmp	al,1
		jnz	@@NoSetColor
		lodsb
		mov	[SysColor],al
		jmp	@@WriteStrLoop
@@NoSetColor:
		mov	ah,[SysColor]
		mov	gs:[di],ax
		add	di,2
		jmp	@@WriteStrLoop
@@WriteStrEnd:
		mov	[SysColor],DefaultColor
		pop	si
		pop	di
		pop	ax
		ret
WriteStrXY	Endp
;--------------------------------------------------------------------------------------
; Программирование PIC.
;--------------------------------------------------------------------------------------
Prog_PIC	Proc Near
		cld
		push	ax
		push	dx
		push	si

		mov	si,ofs PIC_Prg			; Чем будем программировать
		xor	dx,dx
		in	al,21h				; Текущее состояние IRQ	Mask
		xchg	al,ah				; Для PIC 1
		in	al,0a1h				; Для PIC 2
		push	ax
		mov	al,0ffh				; Маскируем все	IRQ
		out	21h,al				; 0...7
		out	0a1h,al				; 8...F
@@PIC_Loop:
		lodsw
		mov	dl,ah				; Адрес	порта
		test	al,al				; А не конец ли	еще ?
		jz	@@PIC_End			; Пожалуй конец.
		out	dx,al				; Или  программируем
		jmp	$+2
		jmp	@@PIC_Loop
@@PIC_End:
		pop	ax
		out	0a1h,al				; Восстановим IRQ Mask PIC 2
		xchg	al,ah
		out	21h,al				; и PIC	1
		mov	al,20h				; Разрешаем прерываться
		out	20h,al

		pop	si
		pop	dx
		pop	ax
		ret

PIC_Prg		Db 11h,0a0h
PIC_2_Int	Db 70h,0a1h				; Это мы так будем переносить
		Db 02h,0a1h,01h,0a1h			; IRQ на другие	вектора
		Db 11h,020h
PIC_1_Int	Db 08h,021h
		Db 04h,021h,01h,021h
		Db 0

Prog_PIC	Endp
;-----------------------------------------------------------------------------
; Разрешает A20Line, предполагаются запрещенные	прерывания, DS=Sel_Data
; Выход	CF=1 если A20 не включается
;-----------------------------------------------------------------------------
Enable_A20      Proc    Near
                pusha
                mov     ax,[A20_Type]
                dec     ax
                jnz     @@EA20_PS2
@@EA20_AT:
                call    Sync8042
                jnz     @@EA20_Fail
                mov     al,0d1h
                out     64h,al
                call    Sync8042
                jnz     @@EA20_Fail
                mov     al,0dfh
                out     60h,al
                call    Sync8042
                jnz     @@EA20_Fail
                mov     al,0ffh                  ; Pulse output port NUL for
                out     64h,al                   ; A20 line to settle up to
                call    Sync8042                 ; 20 usecs
                jnz     @@EA20_Fail
                jmp     @@EA20_Done

@@EA20_PS2:
                dec     ax
                jnz     @@EA20_HP
                in      al,92h                   ; Current A20 State (PS2_PortA)
                test    al,2                     ; Already on ?
                jnz     @@EA20_Done
                or      al,2
                out     92h,al
                xor     cx,cx
@@Wait_PS2:
                in      al,92h
                test    al,2                     ; Wait 4 A20 line to come on
                loopz   @@Wait_PS2
                jz      @@EA20_Fail
                jmp     @@EA20_Done

@@EA20_HP:
                call    Sync8042
                jnz     @@EA20_Fail
                mov     al,0dfh
                out     64h,al
                call    Sync8042
                jnz     @@EA20_Fail
                mov     al,0dfh
                out     64h,al
                call    Sync8042
                jnz     @@EA20_Fail

@@EA20_Done:
                clc
                jmp     @@EA20_Exit
@@EA20_Fail:
                stc
@@EA20_Exit:
                popa
                ret
Enable_A20      Endp

;-----------------------------------------------------------------------------
Sync8042        Proc    Near
                xor     cx,cx
@@Wait8042:
                in      al,64h
                test    al,2
                loopnz  @@Wait8042
                ret
Sync8042        Endp
;--------------------------------------------------------------------------------------
; Конец	резидентной части кода
;--------------------------------------------------------------------------------------
Install_PGM	Proc Near

		push	cs
		pop	ds

                mov     [MyPSP],es

		push	cs
		pop	es

		mov	dx,ofs MSG_Intro
		mov	ah,9
		int	21h

                mov     wr [RealSSSP][0],sp
		mov	wr [RealSSSP][2],ss

;-------------- Разберемся с A20 ------------------------------------------------------
                call    Get_A20_Type
                mov     ax,[A20_Type]
                dec     ax
                shl     ax,1
                mov     di,ax
                add     di,ofs A20NamesTbl
                mov     dx,ds:[di]
                mov     ah,9
                int     21h
;--------------------------------------------------------------------------------------
                smsw    ax
		test	al,1
		jnz	@@Running_V86
;-------------- Поработаем с XMS ------------------------------------------------------
                mov     ax,4300h
                int     2fh
                cmp     al,80h
                jnz     @@No_XMS_Driver
;-------------- Get driver address ----------------------------------------------------
                mov     ax,4310h
                int     2fh
                mov     wr [XMS_Entry][0],bx
                mov     wr [XMS_Entry][2],es
;-------------- Узнаем сколько памяти XMS ---------------------------------------------
                xor     bl,bl
                mov     ah,8
                call    dr [XMS_Entry]
                test    bl,bl
                jnz     @@XMS_Failure
                cmp     ax,1096                                 ; Нам надо 1096Kb
                jb      @@Not_Enuff_XMS
;-------------- Аллочим память --------------------------------------------------------
                mov     ah,9
                mov     dx,1096                                 ; Аллочим эти 1096Kb
                call    dr [XMS_Entry]
                test    al,al
                jz      @@XMS_Failure
                mov     [Mirror_Handle],dx
;-------------- Лочим этот блок (в dx - handle) ---------------------------------------
                mov     ah,0ch
                call    dr [XMS_Entry]
                test    al,al
                jz      @@XMS_Failure
;-------------- Выравниваем на страницу -----------------------------------------------
                shl     edx,16
                mov     dx,bx
                test    dx,0fffh
                jz      @@Page_Rounded
                or      dx,0fffh
                inc     edx
@@Page_Rounded:
                mov     [Mirror_Region][0],edx
;--------------	Заходим	в Protected Mode ----------------------------------------------
                push    cs
                pop     es
                Adjust_Table GDT,(GDTSize/8)                    ; Приводим селекторы
		Adjust_Table IDT,(IDTSize/8)			; к нужному формату

		cli

		mov	[PIC_1_Int],20h
		mov	[PIC_2_Int],28h
		call	Prog_PIC

		mov	ax,cs
		shl	eax,4

		add	[GDT_Base],eax
		add	[IDT_Base],eax

		lgdt	GDT_R
		lidt	IDT_R

		mov	eax,cr0
		or	al,1
		mov	cr0,eax
;--------------	После этого перехода имеем место быть в	PMode -------------------------
		Db	0eah
		Dw	@@Cont_PM
		Dw	Sel_CODE
;--------------	С этого	места мы в протмоде -------------------------------------------
@@Cont_PM:
		mov	ss,cs:[Sel_DATA$]
		mov	esp,ofs	KernelStack
;--------------	Городим	огород для входа в V86 mode -----------------------------------
		mov	ds,cs:[Sel_DATA$]

		mov	[SysTask.SS0],ss			; Инитим стек PL0
		mov	[SysTask.ESP0],esp

		mov	ax,Sel_TSS_V86				; Это TaskRegister
		ltr	ax

		xor	eax,eax					; Работаем без LDT
		lldt	ax

		push	eax					; Unused esp из	tss

		mov	ax,@Code
		push	eax					; GS
		push	eax					; FS
		push	eax					; DS
		push	eax					; ES

		mov	ax,wr [RealSSSP][2]			; SS и SP для V86
		push	eax					; задачи
		mov	ax,wr [RealSSSP][0]
		push	eax

                IfnDef  $$IOPL0
                push    dr 00023000h                            ; Еейныя флаги
                EndIf

                IfDef   $$IOPL0
                push    dr 00020000h
                EndIf

		mov	ax,@Code				; Точка	старта V86
		push	eax
		mov	ax,ofs @@VMStart
		push	eax

		clts						; Задача не переключена

;-------------- Копируем DOS наверх ---------------------------------------------------

                call    Enable_A20
                mov     ds,[Sel_FLAT$]
                push    ds
                pop     es
                xor     esi,esi
                mov     edi,cs:[Mirror_Region]
                cld
                mov     ecx,44000h
                rep     movs dr es:[edi],ds:[esi]

;--------------------------------------------------------------------------------------
                push    dr 0h
		popfd

		iretd
;--------------	С этого	места мы в V86 ------------------------------------------------
@@VMStart:

                cli

                pushfd

                sti

                push    cs
		pop	es

		push	cs
		pop	ds

		mov	dx,ofs MSG_Hello
		mov	ah,9
		int	21h

                mov     dx,ofs Install_PGM
		shr	dx,4
		add	dx,11h
		mov	ax,3100h
		int	21h

;--------------------------------------------------------------------------------------
@@Running_V86:
		mov	dx,ofs MSG_V86Run
		mov	ah,9
		int	21h
@@Bye:
                jmp     __Terminate
;--------------------------------------------------------------------------------------
@@No_XMS_Driver:
                mov     dx,ofs MSG_NoXMS
                mov     ah,9
                int     21h
                jmp     __Terminate
;--------------------------------------------------------------------------------------
@@Not_Enuff_XMS:
                mov     dx,ofs MSG_OutOfXMS
                mov     ah,9
                int     21h
                jmp     __Terminate
;--------------------------------------------------------------------------------------
@@XMS_Failure:
                mov     dx,ofs MSG_FailXMS
                mov     ah,9
                int     21h
Install_PGM     Endp
;-------------- Завершалка ------------------------------------------------------------
__Terminate:
                mov     ax,4c00h
		int	21h

;--------------------------------------------------------------------------------------
; Аджустилка селекторов	под нужный формат
;--------------------------------------------------------------------------------------
Adjust		Proc Near
		add	si,2
		mov	di,si
		lodsw
		movzx	edx,ax
		lodsw
		mov	bx,ax
		lodsw
		test	bh,00010000b
		jnz	@@Next
		test	bh,00000100b
		jnz	@@Adjust

@@Next:
		movzx	eax,ax
		shl	eax, 4
		add	eax,edx
		stosw
		shr	eax,16
		xchg	ah,bh
		stosw
		mov	ax,bx
		stosw
@@Adjust:
		loop	Adjust
		ret
Adjust		Endp

;--------------------------------------------------------------------------------------
; Определялка типа A20
;--------------------------------------------------------------------------------------
Normal_A20      Equ 1
PS2_A20         Equ 2
Vectra_A20      Equ 3

Get_A20_Type    Proc Near
                push es
                mov ah,0c0h
                xor bx,bx
                int 15h
                mov [A20_Type],Normal_A20    ; По умолчанию тип A20
                mov al,br es:[bx][5]
                test al,2                    ; Шина MCA ?
                jz @@HP_A20                  ; Если нет, то может Vectra ?
                mov [A20_Type],PS2_A20       ; Иначе PS2
                jmp @@Exit_A20
@@HP_A20:
                mov ax,0f000h
                mov es,ax
                cmp wr es:[08fh],'PH'        ; Hewlett Packard ?
                jnz @@Exit_A20               ; Если нет - стандартная ISA
                mov [A20_Type],Vectra_A20
@@Exit_A20:
                pop es
                ret
Get_A20_Type    Endp

;--------------------------------------------------------------------------------------
GDT_R		Label Qword
		Dw GDTSize
GDT_Base	Dd ofs GDT
IDT_R		Label Qword
		Dw IDTSize
IDT_Base	Dd ofs IDT

RealSSSP	Dd ?
A20NamesTbl     Dw MSG_NormalISA,MSG_IBMPS2,MSG_HPVectra
;--------------------------------------------------------------------------------------
MSG_Intro	Db '■ RSVM86 ',Version_,', copyright [C] ',??Date,', ',??Time,' RAM Scanner // [CiD], VD',13,10,'$'
MSG_V86Run	Db '■ RSVM86: CPU already in V86 mode, could not initialize, exiting...',13,10,'$'
MSG_NoXMS       Db '■ RSVM86: No XMS driver installed.',13,10,'$'
MSG_OutOfXMS    Db '■ RSVM86: Not enuff XMS memory. Required 1096Kb at least.',13,10,'$'
MSG_FailXMS     Db '■ RSVM86: XMS driver failure, call rejected.',13,10,'$'
MSG_Hello       Db '■ Virtual86 mode established'
                IfDef $$IOPL0
                Db ' at IOPL0'
                EndIf
                Db '...',13,10,'$'
MSG_NormalISA   Db '■ Standard PC AT memory controller detected.',13,10,'$'
MSG_IBMPS2      Db '■ MCA Bus with IBM PS/2 memory controller detected.',13,10,'$'
MSG_HPVectra    Db '■ Hewlett Packard HP Vectra memory controller detected.',13,10,'$'
;-------------- Тут стек опишем для стартапа ------------------------------------------
.Stack		100h
End Start
