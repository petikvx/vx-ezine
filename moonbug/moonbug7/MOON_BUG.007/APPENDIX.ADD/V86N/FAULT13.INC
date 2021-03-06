;--------------------------------------------------------------------------------------
; CopyRight [C] 1997-1998 RAM Scanner // [CiD], VD. All Rights Reserved
;--------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------
; ������ ��直� ࠧ���⥩ � ���᭮�⥩
;----------------------------------------------------------------------------------
		mov	ds,cs:[Sel_DATA$]
		add	[SWIntCountL],1
		adc	[SWIntCountH],0
		mov	fs,[Sel_FLAT$]
		pop	[FaultErrCode]
		pushad
		mov	ebp,esp
;--------------	����� ����� �⠭�����	���� �⥪� --------------------------------
		movzx	esi,wr [ebp][StackRegs.OldCS]
		shl	esi,4
		add	esi,[ebp][StackRegs.OldEIP]
;--------------	�������	��䨪�� --------------------------------------------------
		mov	[FaultAddr],esi
		call	Skip_Prefixes
		mov	ax,wr [PrefixSize]
		add	wr [ebp][StackRegs.OldEIP],ax
;--------------	���᫨�� ����	����襩 ������� ---------------------------------
		mov	ax,fs:[esi]			; ��� ������� ���⠫�
		cmp	al,0cdh
		jne	@@Not_Int
		shr	ax,8
		add	wr [ebp][StackRegs.OldEIP],2
		movzx	ebx,ax
		jmp	Do_Interrupt
;--------------	� �������� �᫨ ���� �� INT ----------------------------------
@@Not_Int:
;--------------	��祪��� �� INT	3 -------------------------------------------------
		cmp	al,0cch
		jnz	@@Not_Int_3
		mov	ebx,3
		inc	wr [ebp][StackRegs.OldEIP]
		jmp	Do_Interrupt
;--------------	��, �� �� INT	3 -------------------------------------------------
@@Not_Int_3:
		call	Check_Other

		popad
		push	[FaultErrCode]

		jmp	Fault_GP
__Restart_VM:
		popad
		iretd
;----------------------------------------------------------------------------------
; ������ ������� INT
;----------------------------------------------------------------------------------
; � BX - ����� ���뢠���
;-------------- ��窠 �室� ��� ReflectVM -----------------------------------------
Do_Interrupt	Proc Near

;-------------- �᫨ �� INT 15 � ���㤨� ������� --------------------------------
                cmp     bl,15h
                jnz     @@Not_Int_15
                cmp     br [ebp][StackRegs.RegEAX][1],87h
                jz      Emulate_1587

;-------------- ����⠥� ����� ---------------------------------------------------
@@Not_Int_15:
                shl     bx,2                            ; �������� �� 4
		add	ebx,[V86_IDT_Addr]		; � � IDT ᪫��� ;-)
		mov	ebx,fs:[ebx]			; ���⠫� ����� - EAX ����

		movzx	edx,wr [ebp][StackRegs.OldSS]	; ����塞 ���� �⥪�
		shl	edx,4
		sub	wr [ebp][StackRegs.OldESP],6
		movzx	eax,wr [ebp][StackRegs.OldESP]
		add	edx,eax

		push	wr [ebp][StackRegs.OldEIP]
		push	wr [ebp][StackRegs.OldCS]
		push	wr [ebp][StackRegs.OldEFL]
		pop	wr fs:[edx][4]
		pop	wr fs:[edx][2]
		pop	wr fs:[edx][0]

		mov	wr [ebp][StackRegs.OldEIP],bx
		shr	ebx,16
		mov	wr [ebp][StackRegs.OldCS],bx

		and	[ebp][StackRegs.OldEFL],0fffefcffh ; Clear RF,TF,IF

		jmp	__Restart_VM
Do_Interrupt	Endp
;----------------------------------------------------------------------------------
; �室	 FS:ESI	- ����	�������, DS - ᥣ���� ������
; ��室	 FS:ESI	- ����	��� ��䨪ᮢ, PrefixSize - ࠧ��� ��䨪ᮢ
;----------------------------------------------------------------------------------
Skip_Prefixes	Proc Near
		push	dx
		mov	[PrefixSize],0
		mov	[PrefixFlags],0
		mov	di,0ffffh
@@PrefixLoop:
		inc	di
		mov	al,ds:[Prefixes][di]
		test	al,al
		je	@@PrefixEnd
		cmp	fs:[esi],al
		jnz	@@PrefixLoop
		inc	esi				; ������騩 ����
		inc	[PrefixSize]			; �����稬 �᫮ ��䨪ᮢ
		push	di
		add	di,di
		mov	bx,[PrefixMasks][di]		; ���ᨬ ᮮ�. 䫠���
		and	[PrefixFlags],bx		; �᫨ ��䨪� ����ࠩ�����
		mov	bx,[PrefixBits][di]		; ��⠭���� ᮮ�. ��䨪��
		or	[PrefixFlags],bx
		pop	di
		jmp	@@PrefixLoop
@@PrefixEnd:
		pop	dx
		ret
Skip_Prefixes	Endp
;----------------------------------------------------------------------------------
FaultAddr	Dd ?
PrefixSize	Dw ?
;--------------	��ଠ� 䫠��� ��䨪ᮢ	-------------------------------------------
PrefixFlags	Dw ?
; FEDCBA9876543210
; ����������������
; ����ٳ����������� [Seg ES]
;   �  ������������ [Seg SS]
;   �  ������������ [Seg FS]
;   �  ������������ [Seg GS]
;   �  ������������ [Seg CS]
;   �  ������������ [Seg DS]
;   �  ������������ [OpSize]
;   �  ������������ [AddrSize]
;   �  ������������ [Rep]
;   �  ������������ [RepNE]
;   �  ������������ [Lock]
;   ��������������� [*unused*]
;----------------------------------------------------------------------------------
;		   ES	  SS	 FS	GS     CS     DS     OpSiz  AdrSz  Rep	  RepNe	 Lock
Prefixes	Db 00026h,00036h,00064h,00065h,0002eh,0003eh,00066h,00067h,000f2h,000f3h,000f0h,0
PrefixBits	Dw 00001h,00002h,00004h,00008h,00010h,00020h,00040h,00080h,00100h,00200h,00400h
PrefixMasks	Dw 0ffc0h,0ffc0h,0ffc0h,0ffc0h,0ffc0h,0ffc0h,0ffffh,0ffffh,0fcffh,0fcffh,0ffffh
Virtual_IF      Dw INT_ENABLED                               ; ����㠫�� IF
Virtual_EFL     Dw 0                                         ; ����㠫�� EFLAGS
;--------------	�஢�ઠ � ������ ��⠫��� ���᭮�⥩ --------------------------
Check_Other	Proc Near
		mov	di,0ffffh
@@Check_Loop:
		inc	di
		mov	al,ds:[Instruct][di]
		test	al,al
		je	@@Other_End
		cmp	fs:[esi],al
		jne	@@Check_Loop
		add	esp,2
		add	di,di
		jmp	[InstrAdr][di]
@@Other_End:
		ret
Check_Other	Endp
;--------------	��१���� ��᫥ ������� �⫨筮� �� INT --------------------------
$$Restart:
		and	[ebp][StackRegs.OldEFL],0fffeffffh		; Clear	RF
                test    wr [ebp][StackRegs.OldEFL],100h                 ; ����஢�� ?
		popad
                jnz     Fault_01
		iretd
;----------------------------------------------------------------------------------
; �����窠 ��㫨�㥬�� ������� � �孨� ���ᮢ ;-)
;----------------------------------------------------------------------------------
Instruct        Db 09ch,09dh,0cfh,0f4h,0fah,0fbh,0
InstrAdr        Dw $$Pushf,$$Popf,$$Iret,$$Halt,$$Cli,$$Sti

;-------------- ������ pushf ----------------------------------------------------
; ����ﭨ� 䫠���� �� �������, �� �� �ண���. � �⥪ V86 ��堥�
; ���祭�� �� Virtual_IF
;----------------------------------------------------------------------------------
$$Pushf		Proc Near
		movzx	edi,wr [ebp][StackRegs.OldSS]
		shl	edi,4
                add     edi,[ebp][StackRegs.OldESP]
                sub     wr [ebp][StackRegs.OldESP],2

                test    [PrefixFlags],40h
                jz      @@No_Pushfd

                sub     wr [ebp][StackRegs.OldESP],2
                inc     wr [ebp][StackRegs.OldEIP]
                mov     ax,[Virtual_EFL]
                mov     fs:[edi][-2],ax
                sub     edi,2

@@No_Pushfd:
		mov	ax,wr [ebp][StackRegs.OldEFL]
                mov     fs:[edi][-2],ax

		inc	wr [ebp][StackRegs.OldEIP]
		jmp	$$Restart
$$Pushf		Endp
;--------------	������ popf -----------------------------------------------------
; �� �⥪� V86 ��堥� ���祭�� IF � Virtual_IF, � ࠧ�蠥� ���뢠���
;----------------------------------------------------------------------------------
$$Popf          Proc Near
		movzx	edi,wr [ebp][StackRegs.OldSS]
		shl	edi,4
		add	edi,[ebp][StackRegs.OldESP]

                test    [PrefixFlags],40h
                jz      @@No_Popfd
                add     wr [ebp][StackRegs.OldESP],2
                inc     wr [ebp][StackRegs.OldEIP]
                mov     ax,fs:[edi]

                and     ax,100b

                mov     [Virtual_EFL],ax
                add     edi,2

@@No_Popfd:

		add	wr [ebp][StackRegs.OldESP],2
		mov	ax,fs:[edi]

                IfDef   $$IOPL0
                and     ax,8fffh                        ; Set IOPL=0
                EndIf

		mov	wr [ebp][StackRegs.OldEFL],ax
		inc	wr [ebp][StackRegs.OldEIP]
		jmp	$$Restart
$$Popf		Endp
;--------------	������ iret -----------------------------------------------------
$$Iret		Proc Near
;-------------- �஢�ਬ����� �� IRETD --------------------------------------------
                test    [PrefixFlags],40h
                jz      @@Do_Iret
                mov     ax,[PrefixSize]
                sub     wr [ebp][StackRegs.OldEIP],ax
                popad
                push    dr 6
                jmp     GPF_Trap
;-------------- �� �㫥��� IRET -------------------------------------------------
@@Do_Iret:
                movzx   edi,wr [ebp][StackRegs.OldSS]
		shl	edi,4
		add	edi,[ebp][StackRegs.OldESP]
		add	wr [ebp][StackRegs.OldESP],6
		mov	ax,fs:[edi][0]
		mov	wr [ebp][StackRegs.OldEIP],ax
		mov	ax,fs:[edi][2]
		mov	wr [ebp][StackRegs.OldCS],ax
		mov	ax,fs:[edi][4]

                IfDef   $$IOPL0
                and     ax,8fffh                        ; Set IOPL=0
                EndIf

		mov	wr [ebp][StackRegs.OldEFL],ax
		jmp	$$Restart
$$Iret		Endp
;--------------	������ hlt ------------------------------------------------------
$$Halt		Proc Near
                inc     wr [ebp][StackRegs.OldEIP]
                test    wr [ebp][StackRegs.OldEFL],200h
                jnz     $$Restart
;-------------- HALT �� ����饭��� ���뢠���� �� ᠪ� -------------------------
                popad
                push    dr 10h                          ; FaultNumber
                jmp     GPF_Trap
$$Halt		Endp
;--------------	������ cli ------------------------------------------------------
$$Cli		Proc Near
		inc	wr [ebp][StackRegs.OldEIP]
                and     wr [ebp][StackRegs.OldEFL],Not 200h
		jmp	$$Restart
$$Cli		Endp
;--------------	������ sti ------------------------------------------------------
$$Sti		Proc Near
		inc	wr [ebp][StackRegs.OldEIP]
                or      wr [ebp][StackRegs.OldEFL],200h
		jmp	$$Restart
$$Sti		Endp
;----------------------------------------------------------------------------------
; ������ ����뫪� ����� int 15h ah 87h
;----------------------------------------------------------------------------------
Emulate_1587    Proc    Near

                add     wr [ebp][StackRegs.OldEIP],2

                call    Enable_A20
                jnc     @@A20_Ok

;-------------- A20 �� ����稫���, ᠪ� -------------------------------------------
                and     dr [ebp][StackRegs.OldEFL],0fffefcffh    ; Clear RF,TF,IF
                or      br [ebp][StackRegs.OldEFL],1             ; Set CF
                mov     br [ebp][StackRegs.RegEAX],3             ; A20 error code
                jmp     __Restart_VM

;-------------- A20 ����稫���, �㫥� ---------------------------------------------
@@A20_Ok:
                and     br [ebp][StackRegs.OldEFL],0feh          ; Clear CF
                cld

                movzx   esi,wr [ebp][StackRegs.RegESI]           ; ��ॡ��� GDT
                movzx   eax,wr [ebp][StackRegs.OldES]            ; ���� ES
                shl     eax,4
                add     esi,eax                                  ; ���᪨� ���� ����稫�

                add     esi,10h

                mov     es,cs:[Sel_DATA$]
                mov     ds,cs:[Sel_FLAT$]                        ; DS - ���᪨�

                mov     edi,ofs Sel_Src_Addr
                mov     cx,8
                rep     movs br [esi],[edi]

                mov     edi,ofs Sel_Dst_Addr
                mov     cx,8
                rep     movs br [esi],[edi]

                xor     si,si
                mov     di,si

                mov     ds,cs:[Sel_SRC$]
                mov     es,cs:[Sel_DST$]

                mov     cx,wr [ebp][StackRegs.RegECX]
                rep     movsw

                mov     br [ebp][StackRegs.RegEAX][1],0          ; mov ah,0

                jmp     __Restart_VM
Emulate_1587    Endp

