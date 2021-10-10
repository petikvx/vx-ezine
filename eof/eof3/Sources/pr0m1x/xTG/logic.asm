;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
;																										 ;
;																										 ;
;                                                            											 ;
;																										 ;
;                                       																 ;
;                                     xxxxxxxxxxxxxxxxxxxxxxxxxx      xxxxxxxxxxxxxxxxxxx				 ;
;                                     xxxxxxxxxxxxxxxxxxxxxxxxxx     xxxxxxxxxxxxxxxxxxxx     			 ;
;                                     xxxxxxxxxxxxxxxxxxxxxxxxxx    xxxxxxxxxxxxxxxxxxxxx      			 ;
;        x                         x  xxxxxxxxxxxxxxxxxxxxxxxxxx   xxxxxxxxxxxxxxxxxxxxxx				 ;
;        xxx                     xxx           xxxxxxxx           xxxxxxx		  xxxxxxx      			 ; 
;        xxxxx                 xxxxx           xxxxxxxx           xxxxxxx								 ;
;        xxxxxxx             xxxxxxx           xxxxxxxx           xxxxxxx								 ;
;        xxxxxxxxx         xxxxxxxxx           xxxxxxxx           xxxxxxx								 ;
;         xxxxxxxxxx     xxxxxxxxxx            xxxxxxxx           xxxxxxx								 ;
;           xxxxxxxxxx xxxxxxxxxx              xxxxxxxx           xxxxxxx								 ;
;             xxxxxxxxxxxxxxxxx                xxxxxxxx           xxxxxxx								 ;
;               xxxxxxxxxxxxx                  xxxxxxxx           xxxxxxx       xxxxxxxxx				 ;
;                xxxxxxxxxxx                   xxxxxxxx           xxxxxxx       xxxxxxxxx				 ;
;              xx  xxxxxxx  xx                 xxxxxxxx           xxxxxxx       xxxxxxxxx				 ;
;             xxxx  xxxxx  xxxx                xxxxxxxx           xxxxxxx         xxxxxxx				 ;
;            xxxxxx   x   xxxxxx               xxxxxxxx           xxxxxxx         xxxxxxx				 ;
;           xxxxxxxx     xxxxxxxx              xxxxxxxx            xxxxxxxxxxxxxxxxxxxxxx 				 ;
;          xxxxxxxx       xxxxxxxx             xxxxxxxx             xxxxxxxxxxxxxxxxxxxxx 				 ;
;         xxxxxxxx         xxxxxxxx            xxxxxxxx              xxxxxxxxxxxxxxxxxxxx 				 ;
;        xxxxxxxx           xxxxxxxx           xxxxxxxx               xxxxxxxxxxxxxxxxxxx				 ;
;																										 ;
;																										 ;
;																										 ;
;																										 ;
;																										 ; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
;							eXperimental/eXtended/eXecutable Trash Generator							 ;
;												  xTG													 ;
;												logic.asm												 ;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
;																										 ;
;												  xD													 ;
;																										 ;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
;����� ������ ���裥�� logic.asm (��� xtg.inc, xtg.asm); �᫮��� "������";								 ; 
;�஢�ઠ � ����஥��� ������ �������権/������権; 													 ;
;!!!!! ����� ���� �� �� swap-reg �����, � �ᯮ�짮���� ��㣨� ���� ���権, ⠪ ��� ����� ���� 	 ;
;!!!!! ��ᮮ⢥��⢨� ॣ�� � ����㠫��� ॣ��!														 ;
;!!!!! ��� ��������� �� ���砩 ����!																	 ;
;!!!!! �᫨ ������ �� �㦭�, ⮣�� �� �㭪� �����⨬, � �, �� � ᠬ�� ���� ��� - ᮮ⢥��⢥���, 	 ;
;!!!!! �᪮���⨬ � ��;																				 ;
;!!!!! ��᫠������� =) 																				 ;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
;v2.0.0


																		;m1x
																		;pr0mix@mail.ru
																		;EOF



 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;�㭪� let_init ;vl -> verify logic; let - logic in executable trash; 
;���樠������ ࠧ����� ������ ��� �ࠢ��쭮� ࠡ��� �㭪樨 �஢�ન/����஥��� ������ ����-����
;�뤥����� �����, ���樠������ ��६�����, ������ ����� � �.�.; 
;���� (stdcall: DWORD let_init(DWORD xparam)):
;	xparam		-	���� ����������� �������� XTG_TRASH_GEN (����� ��������� ⮫쪮 ������� ����);
;�����:
;	EAX			-	0, �᫨ �� ����稫��� ��� �ந��樠����஢���, ���� ������� ���� �뤥������� 
;					���⪠ ����� (��� ���� ����� (�㦭�) ⠪�� ��ᬠ�ਢ��� ��� ���� (�����������) �������� 
;					XTG_LOGIC_STRUCT); 
;�������:
;	���� ��� ����室����� ᫥���� �� ���ᠬ� ⨯� 403008h etc, � ⠪�� ����஢��� ���⪨ ����� 
;	� ᢮� ����㠫��� ������ ��� ���樨. �����筮 (����) ���� �뤥���� ������; 
;	⠪��, ��� ����室����� ᫥���� �� �ࠢ���� ���ﭨ�� 䫠��� (ZF etc); 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
vl_struct1_addr		equ		dword ptr [ebp + 24h]						;XTG_TRASH_GEN

let_init:
	pushad
	cld
	mov		ebp, esp
	xor		eax, eax 
	mov		ebx, vl_struct1_addr 
	assume	ebx: ptr XTG_TRASH_GEN
	cmp		[ebx].fmode, XTG_REALISTIC									;�� LET �㤥� ࠡ���� ⮫쪮 � ०��� "ॠ���⨪", 
	jne		_vl_ret_
	test	[ebx].xmask1, XTG_LOGIC										;����稫� ������?
	je		_vl_ret_
	cmp		[ebx].alloc_addr, 0											;� ⠪�� �� ����稨 �㭮� �뤥�����/�᢮�������� �����; 
	je		_vl_ret_
	cmp		[ebx].free_addr, 0
	je		_vl_ret_ 
																		;�����, �뤥��� ������ ���:
	mov		esi, (sizeof (XTG_LOGIC_STRUCT) + 04 + sizeof (XTG_INSTR_DATA_STRUCT))						;+ ������ XTG_LOGIC_STRUCT + flags + struct XTG_INSTR_DATA_STRUCT + 
	add		esi, (sizeof (XTG_INSTR_PARS_STRUCT) + vl_vstack_size + vl_vstack_small_size)				;+ ������ XTG_INSTR_PARS_STRUCT + ࠧ��� ����㠫쭮�� �⥪� + ࠧ��� �������⥫쭮�� ����㠫쭮�� �⥪� + 
	add		esi, (sizeof (XTG_REGS_CURV_STRUCT) + (vl_regs_states + 01) * (sizeof (XTG_REGS_STRUCT)))	;+ ⥪�騥 ���祭�� ॣ���஢ (� 2 ��᪨) (� �㫨�㥬�� ����) + ���ﭨ� ॣ�� (100 ���ﭨ� + 1 ⠪�� �� ������� ��� �࠭���� ������� ���ﭨ� ॣ�� � ���ᨢ� ������� (���ﭨ�)) + 
	add		esi, ((vl_lv_num + 01 + 01 + 01) * 04 + (vl_lv_states + 01) * vl_lv_num * 04)				;+ ���� ��࠭��� �஢��塞�� �������� ��६����� (+ 2 ��᪨ (�᫨ ���-�� �����-��஢ 㢥��稢�����, ⮣�� � �������� ����� ��� ��᮪ - ⠪ ��� 1 ��� ��� 1 �����-���, �᫨ > 32, � �㦥� �� ���� etc) + 1 ���� ��� �࠭���� ���-�� ��⨢��� �����-��஢) + ���ﭨ� ��� �����-��஢ (etc) + 
	add		esi, (vl_instr_buf_size + 1000h)															;+ ���� ��� ����஢���� � ���쭥�襣� ����᪠ �㫨�㥬�� �������樨 (+ 1000h ���⮢ �� ����� - ����� ��� ��ࠢ������� � ���� =)) + 
	mov		edi, [ebx].xdata_struct_addr
	assume	edi: ptr XTG_DATA_STRUCT
	test	edi, edi
	je		_vl_nxt_1_
	add		esi, [edi].rdata_size										;+ �᫨ ���� ������� �����, � �� � ��� ��� ������; 
	add		esi, [edi].xdata_size        

_vl_nxt_1_:	
	push	esi
	call	[ebx].alloc_addr											;�뤥��� ���� ⠪��, ���஢�� ������� �����; 

	test	eax, eax													;�ᯥ譮?
	je		_vl_ret_

	mov		edx, eax													;� ⥯��� �ந��樠�����㥬 ���, �� �㦭�; 
	assume	edx: ptr XTG_LOGIC_STRUCT
	mov		[edx].xalloc_buf_addr, eax									;��࠭�� ���� ⮫쪮 �� �뤥������ ������ ����� � ������ ����; 
	mov		[edx].xalloc_buf_size, esi									;� ࠧ��� �⮩ ������ �����; 
	add		eax, sizeof (XTG_LOGIC_STRUCT)								;᪮�४��㥬 ���쭥�訩 ����
	mov		[edx].flags_addr, eax										;���� ��� �࠭���� 䫠��� (ZF etc); 
	add		eax, 04
	mov		[edx].xinstr_data_struct_addr, eax							;��� ������ XTG_INSTR_DATA_STRUCT; 
	add		eax, sizeof (XTG_INSTR_DATA_STRUCT)
	mov		[edx].xinstr_pars_struct_addr, eax							;������ (����) ��� ������ XTG_INSTR_PARS_STRUCT; 
	add		eax, (sizeof (XTG_INSTR_PARS_STRUCT) + vl_vstack_size)		;
	mov		[edx].vstack_addr, eax										;���� ������ ����㠫쭮�� ��� 
	add		eax, vl_vstack_small_size
	mov		[edx].vstack_small_addr, eax								;���� ��� ���. ����. �⥪�;
	add		eax, 04
	mov		[edx].xregs_curv_struct_addr, eax							;���� ��� �࠭���� ⥪��� ���祭�� ॣ���஢ (� �㫨�㥬�� ����);
	add		eax, sizeof (XTG_REGS_CURV_STRUCT)
	mov		[edx].xregs_states_addr, eax								;���� ��� �࠭���� ���ﭨ� ॣ�� (+ �� ����権 � ���ᨢ� ���ﭨ� -> � ���� ᭠砫� �� �⮬� ����� �㤥� ������� XTG_REGS_STRUCT, 
																		;� ���ன ���� �࠭����� ���-�� ��࠭��� ���ﭨ� ��� ������� ॣ�, �� � ��⮬ ���ᨢ ��� ������� - ᮡ᭮, ���ﭨ� ॣ��); 
	add		eax, (vl_regs_states + 01) * (sizeof (XTG_REGS_STRUCT))
	mov		[edx].xlv_addr, eax											;���� ��� �࠭���� ���ᮢ - �������� ��६�����;
	add		eax, ((vl_lv_num + 01 + 01 + 01) * 04)
	mov		[edx].xlv_states_addr, eax									;��� �� ���ﭨ� (etc);
	add		eax, ((vl_lv_states + 01) * vl_lv_num * 04)
	and		[edx].xdata_addr, 0
	test	edi, edi
	je		_vl_nxt_2_													;�᫨ �뫠 ��।��� ��� � ������� �����, � � ��� ��� ᢮� ����;
	mov		[edx].xdata_addr, eax
	add		eax, [edi].rdata_size
	add		eax, [edi].xdata_size
	add		eax, 10h													;
_vl_nxt_2_:
	mov		[edx].instr_buf_addr, eax									;� ��� ���� ��� ���樨 ������; 

	mov		edi, [edx].xalloc_buf_addr									;������ ���� �� ���祭��;
	mov		ecx, sizeof (XTG_LOGIC_STRUCT)
	add		edi, ecx
	sub		ecx, [edx].xalloc_buf_size
	neg		ecx
	xor		eax, eax
	rep		stosb
	mov		edi, [edx].xregs_curv_struct_addr
	assume	edi: ptr XTG_REGS_CURV_STRUCT
	mov		eax, [edx].vstack_addr
	mov		[edi].xregs_struct.x_esp, eax								;v_esp = ����� ����㠫쭮�� (������) �⥪�; 
	mov		[edi].xregs_struct.x_ebp, eax								;v_ebp = v_esp; 
	xchg	eax, edx 
		
_vl_ret_:
	mov		dword ptr [ebp + 1Ch], eax									;eax = ����� �뤥������� ���⪠ �����;
	mov		esp, ebp 
	popad
	ret		4															;��室��; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;����� �㭪� let_init 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx





;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;�㭪� let_main
;����஥��� ������ ����-����; 
;���� (stdcall: DWORD let_main(DWORD xparam1, xparam2)):
;	xparam1		-	���� (�室���) �������� XTG_TRASH_GEN
;	xparam2		_	���� (�室���) �������� XTG_LOGIC_STRUCT
;�����:
;	EAX			-	0	-	�᫨ ���������/�������� �� ���室��;
;					-1	-	�᫨ �������� �������⭠� ���������;
;					1	-	�᫨ ��������� ���室��, ��� ���; 
;	(+)			-	�㦭� ���� ��������� ᮮ�-騬 ��ࠧ��;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
vlm_struct1_addr		equ		dword ptr [ebp + 24h]					;XTG_TRASH_GEN
vlm_struct2_addr		equ		dword ptr [ebp + 28h]					;XTG_LOGIC_STRUCT

vlm_xids_addr			equ		dword ptr [ebp - 04]					;XTG_INSTR_DATA_STRUCT
vlm_xips_addr			equ		dword ptr [ebp - 08]					;XTG_INSTR_PARS_STRUCT
vlm_real_flags			equ		dword ptr [ebp - 12]					;��� �࠭���� 䫠��� �����
vlm_xrcs_addr			equ		dword ptr [ebp - 16]					;XTG_REGS_CURV_STRUCT
																		;ࠧ���� �ᯮ����⥫�� ��६����; 
vlm_tmp_var1			equ		dword ptr [ebp - 20]					;�㤥� �࠭��� ��� regs_init
vlm_tmp_var2			equ		dword ptr [ebp - 24]					;� ��� regs_used

vlm_xlv_addr			equ		dword ptr [ebp - 28]					;���� ����, � ���஬ ���� �࠭����� ���� �������� ��६�����, � ⠪�� 2 ��᪨ � �᫮ ��⨢��� �.�.; 
vlm_xlv_states_addr		equ		dword ptr [ebp - 32]					;���� ���ᨢ� "�������", ��� �࠭���� ���ﭨ� �����-��஢; 
vlm_xlv_init_addr		equ		dword ptr [ebp - 36]					;���� ���ठ, ��� �࠭���� ��᪠ init ��� �������� ��६����� - ���樠����஢���� �����-����;
vlm_xlv_used_addr		equ		dword ptr [ebp - 40]					;etc, ��� �࠭���� ��᪠ used - �����-����, ����� ����� ��; 
vlm_xlv_alv_addr		equ		dword ptr [ebp - 44]					;etc, ��� �࠭���� �᫮ ��⨢��� �����-��஢; 

vlm_tmp_var3			equ		dword ptr [ebp - 48]					;��� �㤥� �࠭��� ���� init �����-��஢
vlm_tmp_var4			equ		dword ptr [ebp - 52]					;used �����-��஢
vlm_tmp_var5			equ		dword ptr [ebp - 56]					;�᫮ ��⨢��� �����-��஢
vlm_tmp_var6			equ		dword ptr [ebp - 60]					;������ �����⭮�� ���� �����-��� � ���� (���ᨢ�) ���ᮢ �����-��஢; 

let_main:
	pushad
	mov		ebp, esp													;�������� ࠧ���� ⥬� =)! 
	sub		esp, 64
	mov		ebx, vlm_struct1_addr
	assume	ebx: ptr XTG_TRASH_GEN
	mov		edx, vlm_struct2_addr
	assume	edx: ptr XTG_LOGIC_STRUCT
	mov		eax, [edx].xinstr_data_struct_addr
	mov		vlm_xids_addr, eax											;XTG_INSTR_DATA_STRUCT etc; 
	mov		eax, [edx].xinstr_pars_struct_addr
	mov		vlm_xips_addr, eax											;XTG_INSTR_PARS_STRUCT etc; 
	mov		eax, [edx].xregs_curv_struct_addr
	mov		vlm_xrcs_addr, eax											;XTG_REGS_CURV_STRUCT

	mov		eax, [edx].xlv_states_addr
	mov		vlm_xlv_states_addr, eax									;���� ���� ���ﭨ� �����-��஢

	mov		eax, [edx].xlv_addr
	mov		vlm_xlv_addr, eax											;���� ���� ���ᮢ �����-��஢
	lea		ecx, dword ptr [eax + (vl_lv_num * 4)]
	mov		vlm_xlv_init_addr, ecx										;���� ��᪨ init ��� �����-��஢
	lea		ecx, dword ptr [eax + (vl_lv_num + 01) * 4]
	mov		vlm_xlv_used_addr, ecx										;used
	lea		ecx, dword ptr [eax + (vl_lv_num + 01 + 01) * 4]
	mov		vlm_xlv_alv_addr, ecx										;etc ��⨢��� �����-��஢; 

	call	vl_check_instr												;�맮��� �㭪� �஢�ન � ����஥��� ������ ����-���� (����-�������); 

	mov		dword ptr [ebp + 1Ch], eax									;-1, 0 ��� 1; 
	mov		esp, ebp
	popad
	ret		04 * 2
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;����� �㭪� let_main; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx





;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;�ᯮ����⥫쭠� (����७���) �㭪� vl_check_instr; 
;�஢�ઠ � ����஥��� ������ ������権;
;����:
;	ebx		-	XTG_TRASH_GEN
;	�� �㭪� ��뢠���� �� let_main � �� �����-���� let_main; 
;	etc;
;�����:
;	(+)		-	��������� �㭪� let_main; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
vl_check_instr:
	push	ecx															;᭠砫� ��࠭�� ����� ॣ�; 
	push	edx
	push	esi
	push	edi
	mov		ecx, vlm_xids_addr
	assume	ecx: ptr XTG_INSTR_DATA_STRUCT
	mov		edx, vlm_xips_addr
	assume	edx: ptr XTG_INSTR_PARS_STRUCT
	mov		eax, [ecx].flags
	and		[edx].param_3, 0 											;���㫨� ������ ���� - ��易⥫쭮 ��� �ࠢ��쭮� ࠡ��� vl_code_analyzer'a; 
																		;�� ����室����� ������� �������樨 ᠬ� ���⠢�� �㦭� ���祭�� � �� ����; 

;--------------------------------------------[FLAGS]-----------------------------------------------------
	test	eax, eax
	je		vl_inc_dec___r32											;00
	dec		eax
	je		vl_not_neg___r32											;01
	dec		eax
	je		vl_mov_xchg___r32__r32										;02
	dec		eax
	je		vl_mov_xchg___r8__r8_imm8									;03
	dec		eax
	je		vl_mov___r32_r16__imm32_imm16								;04
	dec		eax
	je		vl_lea___r32___mso											;05
	dec		eax
	je		vl_adc_add_and_or_sbb_sub_xor___r32_r16__r32_r16			;06
	dec		eax
	je		vl_adc_add_and_or_sbb_sub_xor___r8__r8						;07
	dec		eax
	je		vl_adc_add_and_or_sbb_sub_xor___r32__imm32					;08
	dec		eax
	je		vl_adc_add_and_or_sbb_sub_xor___r32__imm8					;09
	dec		eax
	je		vl_adc_add_and_or_sbb_sub_xor___r8__imm8					;10
	dec		eax
	je		vl_rcl_rcr_rol_ror_shl_shr___r32__imm8						;11
	dec		eax															;12
	dec		eax
	je		vl_push_pop___imm8___r32									;13
	dec		eax
	je		vl_cmp___r32__r32											;14
	dec		eax
	je		vl_cmp___r32__imm8											;15
	dec		eax
	je		vl_cmp___r32__imm32											;16
	dec		eax
	je		vl_test___r32_r8__r32_r8 									;17
	dec		eax
	je		vl_jxx_short_down___rel8									;18
	dec		eax
	je		vl_jxx_near_down___rel32									;19
	dec		eax
	je		vl_jxx_up___rel8___rel32									;20
	dec		eax
	je		vl_jmp_down___rel8___rel32									;21
	dec		eax															;22
	dec		eax															;23
	dec		eax															;24
	dec		eax
;--------------------------------------------------------------------------------------------------------
	je		vl_mov___r32_m32__m32_r32									;25
	dec		eax
	je		vl_mov___m32__imm8_imm32									;26
	dec		eax
	je		vl_mov___r8_m8__m8_r8										;27
	dec		eax
	je		vl_inc_dec___m32											;28
	dec		eax
	je		vl_adc_add_and_or_sbb_sub_xor___r32__m32					;29
	dec		eax
	je		vl_adc_add_and_or_sbb_sub_xor___m32__r32					;30
	dec		eax
	je		vl_adc_add_and_or_sbb_sub_xor___r8_m8__m8_r8				;31
	dec		eax
	je		vl_adc_add_and_or_sbb_sub_xor___m32_m8__imm32_imm8			;32
	dec		eax
	je		vl_cmp___r32_m32__m32_r32									;33
	dec		eax
	je		vl_cmp___m32_m8__imm32_imm8									;34
;--------------------------------------------------------------------------------------------------------
	dec		eax
	je		vl_mov_lea___r32__m32ebpo8									;35
	dec		eax
	je		vl_mov___m32ebpo8__r32										;36
	dec		eax
	je		vl_mov___m32ebpo8__imm32									;37
	dec		eax
	je		vl_adc_add_and_or_sbb_sub_xor___r32__m32ebpo8				;38
	dec		eax
	je		vl_adc_add_and_or_sbb_sub_xor___m32ebpo8__r32				;39
	dec		eax
	je		vl_adc_add_and_or_sbb_sub_xor___m32ebpo8__imm32_imm8		;40
	dec		eax
	je		vl_cmp___r32_m32ebpo8__m32ebpo8_r32							;41
	dec		eax
	je		vl_cmp___m32ebpo8__imm32_imm8								;42
;--------------------------------------------------------------------------------------------------------
	dec		eax
	je		vl_xwinapi_func												;43
;--------------------------------------------------------------------------------------------------------
	sub		eax, 958
	je		vl_xif_prolog												;1001
	dec		eax
	je		vl_xif_param												;1002
	dec		eax
	je		vl_xif_call													;1003
	dec		eax
	je		vl_xif_epilog												;1004
;--------------------------------------------[FLAGS]----------------------------------------------------- 
	xor		eax, eax													;�᫨ ����⨫��� �������ন������ ��������, ⮣�� ���� (� eax) -01; 
	dec		eax
;--------------------------------------------------------------------------------------------------------
_vlci_ret_: 
	pop		edi
	pop		esi
	pop		edx
	pop		ecx
	ret																	;�� ��室! 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;end of func vl_check_instr;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx


	
;=========================================[INC/DEC REG32]================================================
vl_inc_dec___r32:
	mov		[edx].flags, (XTG_VL_INSTR_CHG + XTG_VL_P1_GET + XTG_VL_P1_REG)	
																		;㪠�뢠�, �� �� ������� ��������� ���祭�� ��ࠬ��� (1); 
																		;⠪��, �� 1 ��ࠬ��� - ॣ����, ����� ����砥� ���祭�� (� ����� ��祣� �� ������⢮���� (⨯� �� ���� ॣ � �.�.)); 
	mov		eax, [ecx].instr_addr
	movzx	eax, byte ptr [eax]											;���� �����
	and		eax, 07														;����砥� ॣ
	mov		[edx].param_1, eax											;� �����뢠�� ��� � param_1; 
	;and	[edx].param_3, 0											;����塞 3-�� ��ࠬ��� �� ��直�, ⠪ ��� �� ��� �� �� � �⮩ �������樨; 

	call	vl_emul_run_instr											;��뢠�� ����� - ����� ������� � ᯥ樠�쭮� �।�; ����� �� �஢����� � ��室��� ���祭�� eax ��᫥ �맮�� ������ �㭪�; 

	call	vl_code_analyzer											;��뢠�� ���������/���४�� ����-����;

	jmp		_vlci_ret_
;=========================================[INC/DEC REG32]================================================



;=========================================[NOT/NEG REG32]================================================
vl_not_neg___r32:
	mov		[edx].flags, (XTG_VL_INSTR_CHG + XTG_VL_P1_GET + XTG_VL_P1_REG)
	mov		eax, [ecx].instr_addr
	movzx	eax, byte ptr [eax + 01] 									;etc 
	and		eax, 07 
	mov		[edx].param_1, eax 											;����砥� ॣ � �����뢠�� ��� � 㪠����� param_1; 

	call	vl_emul_run_instr

	call	vl_code_analyzer

	jmp		_vlci_ret_	
;=========================================[NOT/NEG REG32]================================================



;=====================================[MOV/XCHG REG32, REG32]============================================
vl_mov_xchg___r32__r32:
																		;ॣ� �� ������ ���� ��������묨 (�����, ��� �� ����)! �� �⨬ ᫥��� xTG! (xtg.asm); 
	mov		[edx].flags, (XTG_VL_INSTR_INIT + XTG_VL_P1_GET + XTG_VL_P1_REG + XTG_VL_P2_GIVE + XTG_VL_P2_REG)
	mov		eax, [ecx].instr_addr
	cmp		byte ptr [eax], 8Bh											;mov reg32, reg32
	je		_vl_mov_r32_r32_
	mov		[edx].flags, (XTG_VL_INSTR_CHG + XTG_VL_P1_GET + XTG_VL_P1_REG + XTG_VL_P2_GIVE + XTG_VL_P2_GET + XTG_VL_P2_REG)
	cmp		byte ptr [eax], 87h											;xchg reg32, reg32
	je		_vl_xchg_r32_r32_

_vl_xchg_eax_r32_:														;xchg eax, reg32
	and		[edx].param_1, 0											;instr_size = 1; param_1 = 0 (eax); etc; 
	movzx	eax, byte ptr [eax]
	sub		eax, 90h
	mov		[edx].param_2, eax
	jmp		_vl_mx_r32_r32_nxt_1_

_vl_mov_r32_r32_:														;mov reg32, reg32
_vl_xchg_r32_r32_:														;xchg reg32, reg32
_vl_mx_r32_r32_gp_:														;instr_size = 2;
	movzx	eax, byte ptr [eax + 01]
	mov		esi, eax
	shr		esi, 03
	and		esi, 07 
	mov		[edx].param_1, esi
	and		eax, 07
	mov		[edx].param_2, eax

_vl_mx_r32_r32_nxt_1_:
	call	vl_emul_run_instr

	call	vl_code_analyzer 

	jmp		_vlci_ret_
;=====================================[MOV/XCHG REG32, REG32]============================================



;====================================[MOV/XCHG REG8, REG8/IMM8]==========================================
vl_mov_xchg___r8__r8_imm8:
	mov		eax, [ecx].instr_addr
	cmp		byte ptr [eax], 0B0h 
	jb		_vl_mov_xchg_r8r8_
	movzx	eax, byte ptr [eax]
	sub		eax, 0B0h
	cmp		eax, 04
	jl		_vlmxr8r8_nxt_0_
	sub		eax, 04														;�᫨ �� ah/ch/dh/bh -> � �� ���� ������ �� ॣ�� eax/ecx/edx/ebx; 
_vlmxr8r8_nxt_0_:
	mov		[edx].param_1, eax											;mov reg8, imm8
	mov		[edx].flags, (XTG_VL_INSTR_CHG + XTG_VL_P1_GET + XTG_VL_P1_REG + XTG_VL_P2_GIVE + XTG_VL_P2_NUM)
	jmp		_vlmxr8_n1_

_vl_mov_xchg_r8r8_:
	cmp		byte ptr [eax], 8Ah 
	je		_vlmxr8r8_nxt_1_
	mov		[edx].flags, (XTG_VL_INSTR_CHG + XTG_VL_P1_GET + XTG_VL_P1_REG + XTG_VL_P2_GIVE + XTG_VL_P2_GET + XTG_VL_P2_REG)
	jmp		_vlmxr8r8_nxt_2_											;xchg reg8, reg8
_vlmxr8r8_nxt_1_:														;mov reg8, reg8
	mov		[edx].flags, (XTG_VL_INSTR_CHG + XTG_VL_P1_GET + XTG_VL_P1_REG + XTG_VL_P2_GIVE + XTG_VL_P2_REG)
_vlmxr8r8_nxt_2_:
	movzx	eax, byte ptr [eax + 01]
	mov		esi, eax
	shr		esi, 03
	and		esi, 07
	and		eax, 07
	cmp		esi, 04
	jl		_vlmxr8r8_nxt_3_
	sub		esi, 04
_vlmxr8r8_nxt_3_:
	cmp		eax, 04														;al
	jl		_vlmxr8r8_nxt_4_
	sub		eax, 04
_vlmxr8r8_nxt_4_:
	cmp		eax, esi													;�� �᫨ ᪠��� �������� ������� ⨯� mov al,ah -> �ᯮ������� ࠧ�� ��� ������ ॣ� EAX, ���⮬� ��� ⠪�� ���権 ᢮� 䫠��! 
	jne		_vlmxr8r8_nxt_5_
	mov		[edx].flags, (XTG_VL_INSTR_CHG + XTG_VL_P1_GET + XTG_VL_P1_REG)
_vlmxr8r8_nxt_5_:
	mov		[edx].param_1, esi
	mov		[edx].param_2, eax

_vlmxr8_n1_:
	call	vl_emul_run_instr 

	call	vl_code_analyzer 

	jmp		_vlci_ret_													;�� ��室! 
;====================================[MOV/XCHG REG8, REG8/IMM8]==========================================


 
;==================================[MOV REG32/REG16, IMM32/IMM16]========================================
vl_mov___r32_r16__imm32_imm16:
	mov		[edx].flags, (XTG_VL_INSTR_INIT + XTG_VL_P1_GET + XTG_VL_P1_REG + XTG_VL_P2_GIVE + XTG_VL_P2_NUM)
																		;etc - ������� ���樠����樨 ��ࠬ��� (1)
																		;1 ��ࠬ��� - ����砥� ���祭�� � ��� 1 ��ࠬ - ॣ;
																		;2 ��ࠬ��� - �᫮, �⤠�� ���祭��; 
	mov		eax, [ecx].instr_addr
	cmp		byte ptr [eax], 66h
	jne		_vl_movr3216_imm3216_nxt_1_
	mov		[edx].flags, (XTG_VL_INSTR_CHG + XTG_VL_P1_GET + XTG_VL_P1_REG + XTG_VL_P2_GIVE + XTG_VL_P2_NUM)
	inc		eax															;�᫨ ���� ��䨪� 66h, ⮣�� �� �㤥� ������� ��������� ���祭�� ��ࠬ���; 
	movzx	esi, word ptr [eax + 01]
	jmp		_vl_movr3216_imm3216_nxt_2_
_vl_movr3216_imm3216_nxt_1_:
	mov		esi, dword ptr [eax + 01]
_vl_movr3216_imm3216_nxt_2_:
	mov		[edx].param_2, esi											;number
	movzx	esi, byte ptr [eax]
	sub		esi, 0B8h
	mov		[edx].param_1, esi											;reg (1); 

	call	vl_emul_run_instr

	call	vl_code_analyzer

	jmp		_vlci_ret_
;==================================[MOV REG32/REG16, IMM32/IMM16]========================================
	


;====================================[LEA MODRM SIB OFFSET]==============================================
vl_lea___r32___mso:
	mov		[edx].flags, (XTG_VL_INSTR_INIT + XTG_VL_P1_GET + XTG_VL_P1_REG + XTG_VL_P2_GIVE + XTG_VL_P2_NUM)
	mov		eax, [ecx].instr_addr 
	movzx	esi, byte ptr [eax + 01]
	push	esi
	shr		esi, 03
	and		esi, 07
	mov		[edx].param_1, esi
	pop		esi
	push	esi
	shr		esi, 06
	cmp		esi, 00
	pop		esi
	je		_vl_lr32mso_nxt_1_
	and		esi, 07
	cmp		[edx].param_1, esi
	jne		_vl_lr32mso_othr_1_
	mov		[edx].flags, (XTG_VL_INSTR_CHG + XTG_VL_P1_GET + XTG_VL_P1_REG + XTG_VL_P2_GIVE + XTG_VL_P2_NUM)
_vl_lr32mso_othr_1_:
	bts		[edx].param_3, esi
	jmp		_vl_lr32mso_nxt_2_

_vl_lr32mso_nxt_1_:
_vl_lr32mso_sib_:
	movzx	eax, byte ptr [eax + 02]
	mov		esi, eax
	shr		esi, 03
	and		esi, 07
	and		eax, 07
	bts		[edx].param_3, esi
	bts		[edx].param_3, eax
	cmp		[edx].param_1, esi
	jne		_vl_lr32mso_othr_2_
	mov		[edx].flags, (XTG_VL_INSTR_CHG + XTG_VL_P1_GET + XTG_VL_P1_REG + XTG_VL_P2_GIVE + XTG_VL_P2_NUM)
_vl_lr32mso_othr_2_:
	cmp		[edx].param_1, eax
	jne		_vl_lr32mso_nxt_2_
	mov		[edx].flags, (XTG_VL_INSTR_CHG + XTG_VL_P1_GET + XTG_VL_P1_REG + XTG_VL_P2_GIVE + XTG_VL_P2_NUM)

_vl_lr32mso_nxt_2_:
	call	vl_emul_run_instr

	call	vl_code_analyzer

	jmp		_vlci_ret_
;====================================[LEA MODRM SIB OFFSET]==============================================



;=======================[ADC/ADD/AND/OR/SBB/SUB/XOR REG32/REG16, REG32/REG16]============================
vl_adc_add_and_or_sbb_sub_xor___r32_r16__r32_r16:
	mov		[edx].flags, (XTG_VL_INSTR_CHG + XTG_VL_P1_GET + XTG_VL_P1_REG + XTG_VL_P2_GIVE + XTG_VL_P2_REG)
																		;add ecx, edx etc;
																		;XTG_VL_INSTR_CHG - �� ������� ��������� ��ࠬ���(��);
																		;XTG_VL_P1_GET - ���� ��ࠬ��� - ����砥� ���祭��;
																		;XTG_VL_P1_REG - ���� ��ࠬ - ॣ;
																		;XTG_VL_P2_GIVE - ��ன ��ࠬ - ��।��� ᢮� ���祭��;
																		;XTG_VL_P2_REG - ��ன ��ࠬ - ॣ; 
																		;⠪�� ��᪠, ���ਬ��, ��� add/sub/xor/etc reg32_1, reg32_2 -> reg32_1 != reg32_2; 
																		;etc 
	mov		eax, [ecx].instr_addr
	cmp		byte ptr [eax], 66h
	jne		_vl_aaaossxr3216_r3216_nxt_1_
	inc		eax
_vl_aaaossxr3216_r3216_nxt_1_:
	push	eax
	movzx	eax, byte ptr [eax + 01]
	mov		esi, eax
	shr		esi, 03
	and		esi, 07
	and		eax, 07
	mov		[edx].param_1, esi
	mov		[edx].param_2, eax
	pop		eax
	cmp		esi, [edx].param_2											;if reg32_1 == reg32_2
	jne		_vl_aaaossxr3216_r3216_nxt_2_
	cmp		[ecx].instr_size, 03										;�᫨ ���� ��䨪� 66h, ⮣�� �� ������� ��������� ���祭�� ��ࠬ���
	je		_vl_aaaossxr3216_r3216_nxt_3_
	cmp		byte ptr [eax], 33h											;���� �᫨ �� xor eax,eax � �.�., ⮣�� �� ������� ���樠����樨 ��ࠬ���
	je		_vl_aaaossxr3216_r3216_nxt_2_1_
	cmp		byte ptr [eax], 2Bh											;���� �᫨ �� sub ecx,ecx etc -> ⮦� ���樠������; 
	jne		_vl_aaaossxr3216_r3216_nxt_3_
_vl_aaaossxr3216_r3216_nxt_2_1_:
	mov		[edx].flags, (XTG_VL_INSTR_INIT + XTG_VL_P1_GET + XTG_VL_P1_REG)
	jmp		_vl_aaaossxr3216_r3216_nxt_2_
_vl_aaaossxr3216_r3216_nxt_3_:
	mov		[edx].flags, (XTG_VL_INSTR_CHG + XTG_VL_P1_GET + XTG_VL_P1_REG)

_vl_aaaossxr3216_r3216_nxt_2_:
	call	vl_emul_run_instr

	call	vl_code_analyzer

	jmp		_vlci_ret_
;=======================[ADC/ADD/AND/OR/SBB/SUB/XOR REG32/REG16, REG32/REG16]============================



;============================[ADC/ADD/AND/OR/SBB/SUB/XOR REG8, REG8]=====================================
vl_adc_add_and_or_sbb_sub_xor___r8__r8:
	mov		[edx].flags, (XTG_VL_INSTR_CHG + XTG_VL_P1_GET + XTG_VL_P1_REG + XTG_VL_P2_GIVE + XTG_VL_P2_REG)
	mov		eax, [ecx].instr_addr
	movzx	eax, byte ptr [eax + 01]
	mov		esi, eax
	shr		esi, 03
	and		esi, 07
	and		eax, 07
	cmp		esi, 04
	jl		_vaaaossx_r8r8_nxt_1_
	sub		esi, 04
_vaaaossx_r8r8_nxt_1_:
	cmp		eax, 04
	jl		_vaaaossx_r8r8_nxt_2_
	sub		eax, 04
_vaaaossx_r8r8_nxt_2_:
	mov		[edx].param_1, esi
	mov		[edx].param_2, eax
	cmp		esi, eax
	jne		_vaaaossx_r8r8_nxt_3_
	mov		[edx].flags, (XTG_VL_INSTR_CHG + XTG_VL_P1_GET + XTG_VL_P1_REG)

_vaaaossx_r8r8_nxt_3_:
	call	vl_emul_run_instr

	call	vl_code_analyzer

	jmp		_vlci_ret_
;============================[ADC/ADD/AND/OR/SBB/SUB/XOR REG8, REG8]=====================================



;===========================[ADC/ADD/AND/OR/SBB/SUB/XOR REG32, IMM32]====================================
;===========================[ADC/ADD/AND/OR/SBB/SUB/XOR REG32, IMM8]=====================================
;============================[RCL/RCR/ROL/ROR/SHL/SHR REG32, IMM8]=======================================
vl_adc_add_and_or_sbb_sub_xor___r32__imm32:
vl_adc_add_and_or_sbb_sub_xor___r32__imm8:
vl_rcl_rcr_rol_ror_shl_shr___r32__imm8:
	and		[edx].param_1, 0
	mov		[edx].flags, (XTG_VL_INSTR_CHG + XTG_VL_P1_GET + XTG_VL_P1_REG + XTG_VL_P2_GIVE + XTG_VL_P2_NUM)
	mov		eax, [ecx].instr_addr
	cmp		byte ptr [eax], 81h
	je		_vaaaosx_ri32_nxt_1_ 
	cmp		byte ptr [eax], 83h
	je		_vaaaosx_ri32_nxt_1_
	cmp		byte ptr [eax], 0C1h
	je		_vaaaosx_ri32_nxt_1_
	cmp		byte ptr [eax], 0D1h
	jne		_vaaaosx_ri32_nxt_2_
_vaaaosx_ri32_nxt_1_:
	movzx	eax, byte ptr [eax + 01]
	and		eax, 07 ;al
	mov		[edx].param_1, eax

_vaaaosx_ri32_nxt_2_:
	call	vl_emul_run_instr

	call	vl_code_analyzer

	jmp		_vlci_ret_
;===========================[ADC/ADD/AND/OR/SBB/SUB/XOR REG32, IMM32]====================================
;===========================[ADC/ADD/AND/OR/SBB/SUB/XOR REG32, IMM8]=====================================
;============================[RCL/RCR/ROL/ROR/SHL/SHR REG32, IMM8]=======================================



;===========================[ADC/ADD/AND/OR/SBB/SUB/XOR REG8, IMM8]====================================== 
vl_adc_add_and_or_sbb_sub_xor___r8__imm8:
	and		[edx].param_1, 0
	mov		[edx].flags, (XTG_VL_INSTR_CHG + XTG_VL_P1_GET + XTG_VL_P1_REG + XTG_VL_P2_GIVE + XTG_VL_P2_NUM)
	mov		eax, [ecx].instr_addr
	cmp		byte ptr [eax], 80h
	jne		_vaaaossx_rimm8_nxt_1_
	movzx	eax, byte ptr [eax + 01]
	and		eax, 07
	cmp		eax, 04
	jl		_vaaaossx_rimm8_nxt_2_
	sub		eax, 04
_vaaaossx_rimm8_nxt_2_:
	mov		[edx].param_1, eax

_vaaaossx_rimm8_nxt_1_:
	call	vl_emul_run_instr

	call	vl_code_analyzer

	jmp		_vlci_ret_
;===========================[ADC/ADD/AND/OR/SBB/SUB/XOR REG8, IMM8]======================================



;=====================================[PUSH IMM8   POP REG32]============================================
vl_push_pop___imm8___r32:
	mov		eax, [ecx].instr_addr
	cmp		byte ptr [eax], 6Ah
	je		_vpush_6ah_
	xor		eax, eax
	inc		eax
	jmp		_vlci_ret_
;--------------------------------------------------------------------------------------------------------
_vpush_6ah_:
	xor		eax, eax 
	mov		[edx].flags, (XTG_VL_INSTR_INIT + XTG_VL_P1_GET + XTG_VL_P1_REG + XTG_VL_P2_GIVE + XTG_VL_P2_NUM)
	mov		esi, [ecx].param_1
	and		esi, 07
	mov		[edx].param_1, esi
	xchg	eax, esi
	mov		edx, vlm_struct2_addr
	assume	edx: ptr XTG_LOGIC_STRUCT
	mov		edi, [edx].instr_buf_addr
	mov		esi, [ecx].instr_addr
	mov		edx, [ecx].instr_size
	inc		[ecx].instr_size
	push	esi
	push	edx
	push	ecx
	push	edx
	add		edi, vl_instr_buf_size
	sub		edi, [ecx].instr_size
	mov		[ecx].instr_addr, edi
	pop		ecx
	rep		movsb
	add		al, 58h 
	stosb

	call	vl_emul_run_instr

	call	vl_code_analyzer

	pop		ecx
	assume	ecx: ptr XTG_INSTR_DATA_STRUCT
	assume	edx: ptr XTG_INSTR_PARS_STRUCT
	pop		[ecx].instr_size
	pop		[ecx].instr_addr

	jmp		_vlci_ret_
;=====================================[PUSH IMM8   POP REG32]============================================
	


;=====================================[CMP REG32, REG32]=================================================
;=====================================[CMP REG32, IMM8]==================================================
;=====================================[CMP REG32, IMM32]=================================================
vl_cmp___r32__r32:
vl_cmp___r32__imm8: 
vl_cmp___r32__imm32:
	mov		[edx].flags, (XTG_VL_INSTR_CHG + XTG_VL_P2_GIVE + XTG_VL_P2_NUM)
	mov		esi, [ecx].instr_addr
	movzx	eax, byte ptr [esi + 01]
	
	cmp		byte ptr [esi], 3Bh
	je		_vcmprr32_
	cmp		byte ptr [esi], 83h
	je		_vcmpr32imm8_
	cmp		byte ptr [esi], 81h
	je		_vcmpr32imm32_
	cmp		byte ptr [esi], 3Dh
	je		_vcmpeaximm32_
																		;
_vcmpeaximm32_:
	xor		eax, eax
_vcmpr32imm8_:
_vcmpr32imm32_: 
	and		eax, 07
	bts		[edx].param_3, eax
	jmp		_vcmpri_nxt_1_

_vcmprr32_:
	mov		esi, eax
	shr		esi, 03
	and		esi, 07
	and		eax, 07
	bts		[edx].param_3, esi
	bts		[edx].param_3, eax
	                        
_vcmpri_nxt_1_:
	call	vl_emul_run_instr

	call	vl_code_analyzer

	jmp		_vlci_ret_
;=====================================[CMP REG32, REG32]=================================================
;=====================================[CMP REG32, IMM8]==================================================
;=====================================[CMP REG32, IMM32]=================================================



;================================[TEST REG32/REG8, REG32/REG8]===========================================	
vl_test___r32_r8__r32_r8:
	mov		[edx].flags, (XTG_VL_INSTR_CHG + XTG_VL_P2_GIVE + XTG_VL_P2_NUM)
	mov		edi, [ecx].instr_addr
	mov		eax, dword ptr [edi + 01]
	mov		esi, eax
	shr		esi, 03
	and		esi, 07
	and		eax, 07
	cmp		byte ptr [edi], 85h
	je		_vtest_r328_nxt_1_
	cmp		esi, 04
	jl		_vtest_r328_nxt_2_
	sub		esi, 04
_vtest_r328_nxt_2_:
	cmp		eax, 04
	jl		_vtest_r328_nxt_1_
	sub		eax, 04
_vtest_r328_nxt_1_:
	bts		[edx].param_3, esi
	bts		[edx].param_3, eax

	call	vl_emul_run_instr

	call	vl_code_analyzer

	jmp		_vlci_ret_
;================================[TEST REG32/REG8, REG32/REG8]===========================================
	


;====================================[JXX_SHORT_DOWN REL8]===============================================
;====================================[JXX_NEAR_DOWN REL32]===============================================
;====================================[JMP_DOWN REL8/REL32]===============================================
vl_jxx_short_down___rel8:
vl_jxx_near_down___rel32:
vl_jmp_down___rel8___rel32:
	xor		eax, eax
	mov		ecx, vlm_xrcs_addr
	assume	ecx: ptr XTG_REGS_CURV_STRUCT
	test	[ecx].regs_used, 11001111b
	je		_vlci_ret_
	inc		eax
	jmp		_vlci_ret_
;====================================[JXX_SHORT_DOWN REL8]===============================================
;====================================[JXX_NEAR_DOWN REL32]===============================================
;====================================[JMP_DOWN REL8/REL32]===============================================



;=====================================[JXX_UP REL8/REL32]================================================
vl_jxx_up___rel8___rel32:
	xor		eax, eax
	assume	ecx: ptr XTG_INSTR_DATA_STRUCT
	mov		esi, [ecx].param_1
	and		esi, 07
	mov		ecx, vlm_xrcs_addr
	assume	ecx: ptr XTG_REGS_CURV_STRUCT
	bt		[ecx].regs_init, esi
	jc		_vlci_ret_
	bt		[ecx].regs_used, esi
	jnc		_vlci_ret_
	inc		eax
	jmp		_vlci_ret_ 
;=====================================[JXX_UP REL8/REL32]================================================



;================================[MOV REG32/MEM32, MEM32/REG32]==========================================
vl_mov___r32_m32__m32_r32:
	assume	ecx: ptr XTG_INSTR_DATA_STRUCT
	push	01 
	pop		esi
	and		[edx].param_1, 0
	and		[edx].param_2, 0
	mov		[edx].flags, (XTG_VL_INSTR_INIT + XTG_VL_P1_GET + XTG_VL_P1_REG) 
	mov		edi, [ecx].instr_addr
	
	cmp		byte ptr [edi], 0A1h
	je		_vmrmmr32_nxt_1_
	cmp		byte ptr [edi], 0A3h
	je		_vmrmmr32_nxt_2_
	inc		esi
	movzx	eax, byte ptr [edi + 01]
	shr		eax, 03
	and		eax, 07
	mov		[edx].param_1, eax
	mov		[edx].param_2, eax
	cmp		byte ptr [edi], 8Bh
	je		_vmrmmr32_nxt_1_
_vmrmmr32_nxt_2_:	
	mov		[edx].flags, (XTG_VL_INSTR_INIT + XTG_VL_P2_GIVE + XTG_VL_P2_REG)

_vmrmmr32_nxt_1_:
	lea		eax, dword ptr [edi + esi]
	call	vl_chk_crct_instr_m
	
	jmp		_vlci_ret_
;================================[MOV REG32/MEM32, MEM32/REG32]==========================================



;===================================[MOV MEM32, IMM8/IMM32]==============================================
;=======================================[INC/DEC MEM32]==================================================
;======================[ADC/ADD/AND/OR/SBB/SUB/XOR MEM32/MEM8, IMM32/IMM8]===============================
;=================================[CMP MEM32/MEM8, IMM32/IMM8]=========================================== 
vl_mov___m32__imm8_imm32:
vl_inc_dec___m32:;��� ��� �� �����, ���� ��� 祭�� - ⠪ ��� ��� ����� ���� ���㫨�� �� - ������� ����� �ன��� �஢��� =) 
vl_adc_add_and_or_sbb_sub_xor___m32_m8__imm32_imm8:
vl_cmp___m32_m8__imm32_imm8:
	mov		eax, [ecx].instr_addr
	inc		eax 
	inc		eax 
	mov		[edx].flags, (XTG_VL_INSTR_INIT)

	call	vl_chk_crct_instr_m 

	jmp		_vlci_ret_
;===================================[MOV MEM32, IMM8/IMM32]==============================================
;=======================================[INC/DEC MEM32]==================================================
;======================[ADC/ADD/AND/OR/SBB/SUB/XOR MEM32/MEM8, IMM32/IMM8]===============================
;=================================[CMP MEM32/MEM8, IMM32/IMM8]=========================================== 



;==================================[MOV REG8/MEM8, MEM8/REG8]============================================	
vl_mov___r8_m8__m8_r8:
	assume	ecx: ptr XTG_INSTR_DATA_STRUCT
	push	01 
	pop		esi
	and		[edx].param_1, 0
	and		[edx].param_2, 0
	mov		[edx].flags, (XTG_VL_INSTR_CHG + XTG_VL_P1_GET + XTG_VL_P1_REG) 
	mov		edi, [ecx].instr_addr
	
	cmp		byte ptr [edi], 0A0h
	je		_vmrmmr8_nxt_1_
	cmp		byte ptr [edi], 0A2h
	je		_vmrmmr8_nxt_2_
	inc		esi 
	movzx	eax, byte ptr [edi + 01]
	shr		eax, 03
	and		eax, 07
	cmp		eax, 04
	jl		_vmrmmr8_nxt_3_
	sub		eax, 04
_vmrmmr8_nxt_3_:
	mov		[edx].param_1, eax
	mov		[edx].param_2, eax
	cmp		byte ptr [edi], 8Ah
	je		_vmrmmr8_nxt_1_
_vmrmmr8_nxt_2_:	
	mov		[edx].flags, (XTG_VL_INSTR_CHG + XTG_VL_P2_GIVE + XTG_VL_P2_REG)

_vmrmmr8_nxt_1_:
	lea		eax, dword ptr [edi + esi]
	call	vl_chk_crct_instr_m
	
	jmp		_vlci_ret_
;==================================[MOV REG8/MEM8, MEM8/REG8]============================================



;==========================[ADC/ADD/AND/OR/SBB/SUB/XOR REG32, MEM32]=====================================
vl_adc_add_and_or_sbb_sub_xor___r32__m32:
	mov		[edx].flags, (XTG_VL_INSTR_CHG + XTG_VL_P1_GET + XTG_VL_P1_REG)
	mov		eax, [ecx].instr_addr
	movzx	esi, byte ptr [eax + 01]
	shr		esi, 03
	and		esi, 07
	mov		[edx].param_1, esi
	inc		eax 
	inc		eax

	call	vl_chk_crct_instr_m

	jmp		_vlci_ret_
;==========================[ADC/ADD/AND/OR/SBB/SUB/XOR REG32, MEM32]=====================================



;==========================[ADC/ADD/AND/OR/SBB/SUB/XOR MEM32, REG32]=====================================
vl_adc_add_and_or_sbb_sub_xor___m32__r32:
	mov		[edx].flags, (XTG_VL_INSTR_CHG + XTG_VL_P2_GIVE + XTG_VL_P2_REG)
	mov		eax, [ecx].instr_addr
	movzx	esi, byte ptr [eax + 01]
	shr		esi, 03
	and		esi, 07
	mov		[edx].param_2, esi
	inc		eax 
	inc		eax

	call	vl_chk_crct_instr_m

	jmp		_vlci_ret_
;==========================[ADC/ADD/AND/OR/SBB/SUB/XOR MEM32, REG32]=====================================



;=======================[ADC/ADD/AND/OR/SBB/SUB/XOR REG8/MEM8, MEM8/REG8]================================
vl_adc_add_and_or_sbb_sub_xor___r8_m8__m8_r8:
	mov		[edx].flags, (XTG_VL_INSTR_CHG + XTG_VL_P1_GET + XTG_VL_P1_REG)
	mov		eax, [ecx].instr_addr
	movzx	esi, byte ptr [eax + 01]
	shr		esi, 03
	and		esi, 07
	cmp		esi, 04
	jl		_vaaaossxrmmr8_nxt_1_
	sub		esi, 04
_vaaaossxrmmr8_nxt_1_:
	mov		[edx].param_1, esi
	mov		[edx].param_2, esi
	movzx	edi, byte ptr [eax]
	inc		eax 
	inc		eax
	and		edi, 03
	test	edi, edi
	jne		_vaaaossxrmmr8_nxt_2_
	mov		[edx].flags, (XTG_VL_INSTR_CHG + XTG_VL_P2_GIVE + XTG_VL_P2_REG)

_vaaaossxrmmr8_nxt_2_:
	call	vl_chk_crct_instr_m

	jmp		_vlci_ret_
;=======================[ADC/ADD/AND/OR/SBB/SUB/XOR REG8/MEM8, MEM8/REG8]================================



;================================[CMP REG32/MEM32, MEM32/REG32]==========================================
vl_cmp___r32_m32__m32_r32:
	mov		eax, [ecx].instr_addr
	movzx	esi, byte ptr [eax + 01]
	shr		esi, 03
	and		esi, 07
	mov		[edx].param_2, esi
	mov		[edx].flags, (XTG_VL_INSTR_CHG + XTG_VL_P2_GIVE + XTG_VL_P2_REG)
	inc		eax 
	inc		eax

	call	vl_chk_crct_instr_m

	jmp		_vlci_ret_
;================================[CMP REG32/MEM32, MEM32/REG32]==========================================



;=============================[MOV/LEA REG32, DWORD PTR [ebp +- XXh]]==================================== 
;==============================[MOV DWORD PTR [ebp +- XXh], REG32]======================================= 
;====================[ADC/ADD/AND/OR/SBB/SUB/XOR REG32, DWORD PTR [ebp +- XXh]]========================== 
;====================[ADC/ADD/AND/OR/SBB/SUB/XOR DWORD PTR [ebp +- XXh], REG32]==========================
vl_mov_lea___r32__m32ebpo8:	
vl_mov___m32ebpo8__r32:
vl_adc_add_and_or_sbb_sub_xor___r32__m32ebpo8:
vl_adc_add_and_or_sbb_sub_xor___m32ebpo8__r32:
	mov		[edx].flags, (XTG_VL_INSTR_INIT + XTG_VL_P1_GET + XTG_VL_P1_REG + XTG_VL_P2_GIVE + XTG_VL_P2_ADDR) 
	mov		eax, [ecx].instr_addr

	push	eax
	call	processing_lv_addr
	xchg	eax, edi
	pop		eax

	mov		[edx].param_2, edi

	movzx	esi, byte ptr [eax + 01] 
	shr		esi, 03
	and		esi, 07
	mov		[edx].param_1, esi

	movzx	ecx, byte ptr [eax] 
	cmp		cl, 8Bh
	je		_viic_nxt_3_
	mov		[edx].flags, (XTG_VL_INSTR_INIT + XTG_VL_P1_GET + XTG_VL_P1_REG)
	cmp		cl, 8Dh
	je		_viic_nxt_3_
	mov		[edx].flags, (XTG_VL_INSTR_INIT + XTG_VL_P1_GET + XTG_VL_P1_ADDR + XTG_VL_P2_GIVE + XTG_VL_P2_REG)
	cmp		cl, 89h
	je		_viic_nxt_4_
	mov		[edx].flags, (XTG_VL_INSTR_CHG + XTG_VL_P1_GET + XTG_VL_P1_REG + XTG_VL_P2_GIVE + XTG_VL_P2_ADDR)
	and		cl, 03
	cmp		cl, 03
	je		_viic_nxt_3_
	mov		[edx].flags, (XTG_VL_INSTR_CHG + XTG_VL_P1_GET + XTG_VL_P1_ADDR + XTG_VL_P2_GIVE + XTG_VL_P2_REG)

_viic_nxt_4_:
	mov		[edx].param_1, edi
	mov		[edx].param_2, esi

_viic_nxt_3_:
	call	vl_emul_run_instr

	call	vl_code_analyzer

	jmp		_vlci_ret_
;=============================[MOV/LEA REG32, DWORD PTR [ebp +- XXh]]====================================
;==============================[MOV DWORD PTR [ebp +- XXh], REG32]======================================= 
;====================[ADC/ADD/AND/OR/SBB/SUB/XOR REG32, DWORD PTR [ebp +- XXh]]==========================
;====================[ADC/ADD/AND/OR/SBB/SUB/XOR DWORD PTR [ebp +- XXh], REG32]==========================



;==============================[MOV DWORD PTR [ebp +- XXh], IMM32]=======================================
;==================[ADC/ADD/AND/OR/SBB/SUB/XOR DWORD PTR [ebp +- XXh], IMM32/IMM8]=======================
vl_mov___m32ebpo8__imm32:
vl_adc_add_and_or_sbb_sub_xor___m32ebpo8__imm32_imm8:
	mov		[edx].flags, (XTG_VL_INSTR_INIT + XTG_VL_P1_GET + XTG_VL_P1_ADDR)
	mov		eax, [ecx].instr_addr
	cmp		byte ptr [eax], 0C7h
	je		_vmaaaossxm32ebpo8_i832_nxt_1_
	mov		[edx].flags, (XTG_VL_INSTR_CHG + XTG_VL_P1_GET + XTG_VL_P1_ADDR)

_vmaaaossxm32ebpo8_i832_nxt_1_:
	call	processing_lv_addr

	mov		[edx].param_1, eax 

	call	vl_emul_run_instr

	call	vl_code_analyzer

	jmp		_vlci_ret_
;==============================[MOV DWORD PTR [ebp +- XXh], IMM32]=======================================
;==================[ADC/ADD/AND/OR/SBB/SUB/XOR DWORD PTR [ebp +- XXh], IMM32/IMM8]=======================



;==================[CMP REG32/DWORD PTR [EBP +- XXh], DWORD PTR [EBP +- XXh]/REG32]======================
vl_cmp___r32_m32ebpo8__m32ebpo8_r32:
	mov		eax, [ecx].instr_addr
	movzx	esi, byte ptr [eax + 01]
	shr		esi, 03
	and		esi, 07
	
	call	processing_lv_addr

	mov		[edx].flags, (XTG_VL_INSTR_CHG + XTG_VL_P1_GIVE + XTG_VL_P1_REG + XTG_VL_P2_GIVE + XTG_VL_P2_ADDR)
	mov		[edx].param_1, esi 
	mov		[edx].param_2, eax

	call	vl_emul_run_instr

	call	vl_code_analyzer

	jmp		_vlci_ret_
;==================[CMP REG32/DWORD PTR [EBP +- XXh], DWORD PTR [EBP +- XXh]/REG32]======================



;===========================[CMP DWORD PTR [EBP +- XXh], IMM32/IMM8]=====================================
vl_cmp___m32ebpo8__imm32_imm8:
	mov		[edx].flags, (XTG_VL_INSTR_CHG + XTG_VL_P2_GIVE + XTG_VL_P2_ADDR)
	mov		eax, [ecx].instr_addr 

	call	processing_lv_addr

	mov		[edx].param_2, eax 

	call	vl_emul_run_instr

	call	vl_code_analyzer

	jmp		_vlci_ret_
;===========================[CMP DWORD PTR [EBP +- XXh], IMM32/IMM8]=====================================
	


;=====================================[FAKE WINAPI FUNC]=================================================
vl_xwinapi_func:														;�஢�ઠ ��।������� ��ࠬ��஢ � ��������; 
	mov		edi, [ecx].instr_addr

_vwf_cycle_:
	cmp		word ptr [edi], 15FFh										;�� ��諨 �� �맮�� ������? (call dword ptr [<addr?]) (�� �᫨ �� �஢ਫ� �� ��ࠬ� ��� �� �� �뫮 �����); 
	je		_vwf_crct_fields_											;⮣�� ��룠�� �����
	cmp		byte ptr [edi], 6Ah											;���� �஢��塞 ��ࠬ�: �� push imm8?
	jne		_vwfc_nxt_1_
	inc		edi															;�᫨ ⠪, � �� �������筮 ��室�� �஢��� (��� �� ॣ��, �� ���ᮢ etc - �� ᫥��� �஢२��) - ��।�������� �� ����� �⮩ ������� � ��룠�� �� �஢��� ᫥���饩 �������; 
	inc		edi
	jmp		_vwf_cycle_
_vwfc_nxt_1_:
	cmp		byte ptr [edi], 68h											;�� push imm32? �᫨ ⠪, � �������筮, ��� ��ࠬ��� ��室�� �஢��� � �� ��룠�� �����; 
	jne		_vwfc_nxt_2_
	add		edi, 05 
	jmp		_vwf_cycle_
_vwfc_nxt_2_:
	cmp		word ptr [edi], 75FFh										;��� �� push [ebp +- XXh]?
	jne		_vwfc_nxt_3_												;�᫨ �� �� ⠪, � �஢��塞 �����
	mov		eax, edi													;���� ����稬 ���� �����쭮� ��६�����/�室���� ��ࠬ�
	add		edi, 03														;edi ���४��㥬 �� ᫥������ ������� (ࠧ��� �⮩ ������� = 3 ����); 
	call	processing_lv_addr											;����砥� ���� (� �᫨ �㦭�, ��ࠡ��뢠�� ��� ����); 
	mov		[edx].flags, (XTG_VL_INSTR_CHG + XTG_VL_P2_GIVE + XTG_VL_P2_ADDR)
																		;���⠢�塞 ᮮ�-騥 䫠��;
	mov		[edx].param_2, eax											;��࠭塞 � �㦭�� ���� ����祭�� ���� �����-���/�室���� ��ࠬ�; 
	jmp		_vwfc_ca_													;� ��룠�� �� �஢��� ��ࠬ��� (��� ������); 
_vwfc_nxt_3_:
	cmp		word ptr [edi], 35FFh										;��� �� push dword ptr [<addr>]?
	jne		_vwfc_nxt_4_												;
	add		edi, 06														;�᫨ �� ⠪, � ⠪�� ��ࠬ��� ⮦� ��� ���室�� (���祭�� �� �⨬ ���ᠬ �ᥣ�� ����� ����� �ந��樠����஢���묨, � �� ���� �� ������� �஢�ઠ - ��� � �� �㦭�); 
	jmp		_vwf_cycle_
_vwfc_nxt_4_:
	xor		eax, eax													;eax = 0; 
	cmp		byte ptr [edi], 50h											;�᫨ �� ���� < 50h, ⮣�� �� �������ন����� ��ࠬ � �� ��室�� � �����頥� 0;
	jb		_vlci_ret_
	cmp		byte ptr [edi], 57h											;�������筮 � ���, ⮫쪮 �᫨ ���� > 57h; 
	ja		_vlci_ret_
	movzx	eax, byte ptr [edi]											;���� �� ������� push reg32
	and		eax, 07														;����砥� ॣ
	inc		edi 														;���४��㥬 edi �� ᫥������ �������
	mov		[edx].flags, (XTG_VL_INSTR_CHG + XTG_VL_P2_GIVE + XTG_VL_P2_REG)
																		;�⠢�� �㦭� ��ਡ���
	mov		[edx].param_2, eax											;��࠭塞 � ᮮ�-饥 ���� ����� ॣ�; 
	
_vwfc_ca_:
	call	vl_code_analyzer											;� ��뢠�� ��������� ���� (� ������ ��砥 ����� �� �㦭�, �� ���� �஢�ਬ ������� (��ࠬ���) - ���室�� �� ��� ����-���� �� ������); 
	test	eax, eax
	jne		_vwf_cycle_													;�᫨ ��, ⮣�� ��� ��, �த������ �������஢��� ��⠫�� ��ࠬ����; 
	jmp		_vlci_ret_													;���� ��室��;
_vwf_crct_fields_:														;� � �� ��������, �᫨ �� ��ࠬ���� ��諨 �஢��� (��� �� ����� �� �뫮); 
	mov		ecx, vlm_xrcs_addr											;⮣�� ������誠 ᣥ��७��� ������誠 ��諠 �஢��� � �� �� ��⠢��
	assume	ecx: ptr XTG_REGS_CURV_STRUCT
	and		[ecx].regs_init, 11111000b									;��ᨬ � �⮩ ��᪥ eax, ecx, edx - �� ����� ������ ���樠����஢���; 
	and		[ecx].regs_used, 11111001b									;� �⮩ ��᪥ ��ᨬ ecx, edx - �� ����� ��;
	or		[ecx].regs_used, 00000001b									;� ���⠢�� � �⮩ ��᪥ eax;
																		;� �⮣�, ����砥� ᫥���饥: 
																		;eax ����� ���樠����஢��� � � � �� �६� �ᯮ�짮���� � �������� add reg32, reg32 � ��.;
																		;ecx & edx ����� ⮫쪮 ���樠���������, � � ��㣨� �������� ��� ���樠����樨 ����� �㤥� ��; 
	xor		eax, eax
	inc		eax 														;eax = 1;
	jmp		_vlci_ret_													;�� ��室; 
;=====================================[FAKE WINAPI FUNC]=================================================



;===============================[FUNC PROLOG/PARAM/CALL/EPILOG]==========================================
vl_xif_prolog:															;prolog
	call	vl_emul_run_instr											;�㫨�㥬 �஫�� ��襩 �㭪�
	xor		eax, eax
	inc		eax															;eax = 1;
	jmp		_vlci_ret_													;�� ��室;
;--------------------------------------------------------------------------------------------------------
vl_xif_param:															;param; 
	assume	ecx: ptr XTG_INSTR_DATA_STRUCT								;���㫨� � �஢�ਬ ��।������ ��ࠬ���� � �㭪�; 
	mov		[edx].flags, (XTG_VL_INSTR_CHG + XTG_VL_P2_GIVE + XTG_VL_P2_NUM)
	xor		eax, eax
	mov		edi, [ecx].instr_addr
	cmp		byte ptr [edi], 6Ah											;push imm8
	je		_vxp_emul_
	cmp		byte ptr [edi], 68h											;push imm32;
	je		_vxp_emul_
	cmp		word ptr [edi], 35FFh										;push dword ptr [<addr>]
	je		_vxp_emul_
	cmp		word ptr [edi], 75FFh										;push dword ptr [ebp +- XXh]
	jne		_vxp_nxt_1_
	mov		eax, edi
	call	processing_lv_addr
	mov		[edx].flags, (XTG_VL_INSTR_CHG + XTG_VL_P2_GIVE + XTG_VL_P2_ADDR)
	mov		[edx].param_2, eax
	jmp		_vxp_emul_
_vxp_nxt_1_:
	cmp		byte ptr [edi], 50h											;push reg32; 
	jb		_vlci_ret_
	cmp		byte ptr [edi], 57h
	ja		_vlci_ret_
	movzx	eax, byte ptr [edi]
	and		eax, 07
	mov		[edx].flags, (XTG_VL_INSTR_CHG + XTG_VL_P2_GIVE + XTG_VL_P2_REG)
	mov		[edx].param_2, eax

_vxp_emul_:
	call	vl_emul_run_instr

	call	vl_code_analyzer
	test	eax, eax
	jne		_vlci_ret_													;�᫨ �஢�ઠ �ᯥ譮 �ன����, ��室��
	mov		ecx, vlm_xrcs_addr
	assume	ecx: ptr XTG_REGS_CURV_STRUCT
	add		[ecx].xregs_struct.x_esp, 04								;���� ᪮�४��㥬 ����㠫�� esp - ⠪ ��� �� �㫨�� push, �� 㬥��蠥� esp �� 4; 
	jmp		_vlci_ret_													;�� ��室; 
;--------------------------------------------------------------------------------------------------------
vl_xif_call:															;call
	mov		ecx, vlm_xrcs_addr
	assume	ecx: ptr XTG_REGS_CURV_STRUCT
	sub		[ecx].xregs_struct.x_esp, 04								;��� �� �㦭� ���㤠 ��룠��, ⠪ ��� �㦭� ���� �ᥣ�� �㤥� ��।�������;
	xor		eax, eax													;���� 㬥��訬 ����㠫�� esp �� 4, ⨯� �������� ���� ������ � ����㠫�� ��� =) 
	inc		eax
	jmp		_vlci_ret_
;--------------------------------------------------------------------------------------------------------
vl_xif_epilog:															;epilog
	assume	ecx: ptr XTG_INSTR_DATA_STRUCT
	xor		esi, esi
	mov		[ecx].instr_size, 01
	mov		edi, [ecx].instr_addr
	cmp		byte ptr [edi], 0C9h										;leave = size = 1 byte;
	je		_vxe_nxt_1_
	mov		[ecx].instr_size, 03										;���� �� mov esp, ebp  pop ebp; 
_vxe_nxt_1_:
	add		edi, [ecx].instr_size										;��।������ edi �� ���� ������� ret; 
	cmp		byte ptr [edi], 0C3h										;ret 0xC3?
	je		_vxe_nxt_2_
	movzx	esi, word ptr [edi + 01]									;esi = ���, ᪮�쪮 �㦭� ������ � ���

_vxe_nxt_2_:
	add		esi, 04														;� �⮣� [ecx].instr_size = ࠧ���� �����, � esi = ���, ᪮�쪮 ���� ���⮢ ��⮫����� �� ���; 
	
	call	vl_emul_run_instr											;�㫨�

	mov		ecx, vlm_xrcs_addr
	assume	ecx: ptr XTG_REGS_CURV_STRUCT
	add		[ecx].xregs_struct.x_esp, esi								;� ��⠫������ �㦭�� �᫮ ���⮢ �� ���; 
	xor		eax, eax
	inc		eax															;eax = 1;
	jmp		_vlci_ret_													;��室��; 
;===============================[FUNC PROLOG/PARAM/CALL/EPILOG]==========================================
	
	
	


;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;�㭪� vl_chk_crct_instr_m
;���४�஢�� ������� � ��᫥����� �� �஢�ઠ;
;�ந�������� ���४�஢�� ������, ᮤ�ঠ�� ��᮫��� ����㠫�� ����;
;���ਬ��, ���� ������� mov ecx, dword ptr [403008h]
;�����, ᭠砫� ���� 403008h �㤥� ������ �� ᮮ⢥�����騩 ��� ���� � �����, �।�����祭��� 
;��� ���樨, ���ਬ��, �� 880008h. ����稢���� ������� mov ecx, dword ptr [880008h] 
;�㤥� ���㫨஢��� � �஢�७� ��������஬; 
;����:
;	ebx			-		XTG_TRASH_GEN;
;	eax			-		���� (� �������), �� ���஬� ��室���� VA (����� ������� �� ᢮� ����); 
;	etc
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
vl_chk_crct_instr_m:
	assume	ecx: ptr XTG_INSTR_DATA_STRUCT
	push	edx
	push	esi
	push	edi
	push	[ecx].instr_addr
	push	ecx
	mov		esi, [ebx].xdata_struct_addr
	assume	esi: ptr XTG_DATA_STRUCT
	mov		edi, vlm_struct2_addr
	assume	edi: ptr XTG_LOGIC_STRUCT
	mov		edx, dword ptr [eax] 										;edx = VA; for example, 403008h 
	sub		edx, [esi].xdata_addr										;�⭨���� �� edx ���� ��砫� ������ �����, ���ன �ਭ������� ���� � edx; ⠪�� ��ࠧ�� ����砥� ᬥ饭�� ���� � ��।����� ������ ����� [ebx].xdata_addr; 
	add		edx, [edi].xdata_addr										;������塞 � ᬥ饭�� ���� ��砫� ������ ����� ��� ���樨; �.�., ����砥� ���� � ����� ��� ���樨, ᮮ�-騩 VA; �믮����� �८�ࠧ������; 
	mov		edi, [edi].instr_buf_addr									;edi - ���� ����, � ����� ᪮���㥬 �८�ࠧ������� ������� � �����⨬ ��� ���� (�����); 
	add		edi, vl_instr_buf_size 										;edi = ����� �⮣� ����
	sub		edi, [ecx].instr_size										;�⭨���� ࠧ��� ��।����� �� �஢��� �������; 
	mov		esi, [ecx].instr_addr										;esi = ���� ��।����� �������;
	mov		[ecx].instr_addr, edi										;�����塞 ���� �� ���� - ��� �㤥� ������ �८�ࠧ������� �������; 
	mov		ecx, [ecx].instr_size										;ecx = ࠧ��� �������
	sub		eax, esi													;eax = ᬥ饭�� VA � �������; 
	push	edi
	rep		movsb														;�����㥬 ������� � ���� ����
	pop		edi
	mov		dword ptr [edi + eax], edx									;�����塞 VA �� ᢮� ���� (���ਬ��, 403008h ���塞 �� 880008h); 
	mov		ecx, dword ptr [edx]										;��࠭塞 ���祭��, ���஥ ����� �� ����� 880008h etc; 

	call	vl_emul_run_instr											;�㫨�㥬 �८�ࠧ������� �������

	call	vl_code_analyzer											;�஢�ਬ �८�ࠧ������� �������

	test	eax, eax													;�᫨ ������� ��� ���室�� �� ������, ⮣�� ��룠�� �� ��室; 
	jne		_vccim_nxt_1_
	mov		dword ptr [edx], ecx										;���� ���� ࠭�� ��࠭񭭮� ���祭�� � 880008h; (880008h ���� ���� ��� �ਬ��, ���᭮, ��� ���� ��㣨� ����); 
_vccim_nxt_1_:
	pop		ecx
	pop		[ecx].instr_addr											;����⠭�������� ���
	pop		edi
	pop		esi
	pop		edx
	ret																	;� �� ��室; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;����� �㭪� vl_chk_crct_instr_m 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
	


;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;�㭪� processing_lv_addr
;��ࠡ�⪠ ���ᮢ �������� ��६����� (� �室��� ��ࠬ��஢);
;����祭�� ���� �����쭮� ��६�����/�室���� ��ࠬ��� (�.�./�.�.) � �������; 
;�᫨ �� ���� �室���� ��ࠬ��� (ebp + XXh), ⮣�� �� ��� ��� �஢�ਬ - ���� �� ⠪�� ���� � 
;���� ���ᮢ �����-��஢ � �室��� ��ࠬ��. �᫨ ����, ⮣�� ������ �㭪� ���� ����� ���� 
;�⮣� ��ࠬ���. �᫨ �� ���� �� ������, ⮣�� ����襬 ���, � ⠪�� ��ᨬ ��� ���ﭨ� � 0 � 
;������� ��ࢮ� ���ﭨ�. ��� ����� ������, ��⮬� ��� �室��� ��ࠬ��� �� ����� (�� �� ��।���� 
;��ࠬ��� ��� ���祭��, ���ਬ�� push 5 - > 5 - ���४⭮� ���祭�� etc); 
;����:
;	ebx		-		etc;
;	eax		-		���� ������� � �����쭮� ��६�����/�室��� ��ࠬ��஬ (���ਬ��, ⠪�� �������:
;					mov ecx, dword ptr [ebp - 14h] - �.�., mov dword ptr [ebp + 18h] - �.�., edx   etc);
;�����:
;	eax		-		���� �����쭮� ��६�����/�室���� ��ࠬ���;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
processing_lv_addr:
	push	ecx
	push	esi 
	mov		esi, vlm_xrcs_addr
	assume	esi: ptr XTG_REGS_CURV_STRUCT
	movzx	ecx, byte ptr [eax + 02]									;ecx - ᮤ�ন� 8-��⭮� ᬥ饭��
	mov		eax, [esi].xregs_struct.x_ebp								;eax = ����㠫쭮�� ���祭�� ebp; 
	mov		esi, ecx
	neg		cl															;8-��⭮� ᬥ饭�� ������ �� ����� ������⥫��; 
	js		_pla_nxt_1_
	sub		eax, ecx													;�᫨ �� �����-���, � ���� �⭨��� �� ebp ����祭��� ���祭��
	jmp		_pla_nxt_2_
_pla_nxt_1_:
	add		eax, esi 													;�᫨ �� �室��� ��ࠬ, � �ਡ���� � �맮��� �㭪� ��ࠡ�⪨ ���� �室���� ��ࠬ�; 
	call	vlca_new_lv_param
_pla_nxt_2_:
	pop		esi
	pop		ecx
	ret																	;��室��; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;����� �㭪� processing_lv_addr 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

	



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;�㭪� vl_emul_run_instr
;����� ����
;����� �������樨/������樨 � ᯥ樠�쭮� �।�
;����:
;	�㭪� ��뢠���� �� let_main � �� �� ��६���� etc;
;�����:
;	eax		-	1, �᫨ ��� ��ࠡ�⠫ ���窠; 
;
;�������:
;1)
;ᯥ樠�쭠� �।� �।�⠢��� ᮡ�� ����, � ����� ᪮��஢��� �஢��塞�� ������� � ������� 
;��㣨� ᯥ�. �������. ���:
;		mov		edx, dword ptr [esp + 04]			;
;		mov		esp, dword ptr [esp + 08]
;		;x_instr									;��� ᪮��஢����� ��� ��� �������; 
;		mov		dword ptr [addr_1], ecx
;		mov		dword ptr [addr_1 + 04], esp
;		mov		esp, 
;		ret		08
;	addr_1:
;		;...
;
;2) �᫨ �㦭� ���஢��� ����� ���, � ���� �� �� swap-reg, ⠪ ��� ����� ���� ��ᮮ⢥��⢨� 
;	ॣ�� � ����㠫��� ॣ��; ���� �।�ᬮ���� ������ �����;
;	�� ��ᠥ��� ��� �㭪権 vl;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
vl_emul_run_instr:
	pushad
	xor		eax, eax
	mov		edx, vlm_struct2_addr
	assume	edx: ptr XTG_LOGIC_STRUCT
	mov		edi, [edx].xregs_curv_struct_addr
	assume	edi: ptr XTG_REGS_CURV_STRUCT
	mov		ecx, [edx].vstack_addr
	sub		ecx, [edi].xregs_struct.x_esp
	add		ecx, 04
	cmp		ecx, vl_vstack_size											;���� � ��� ��� ���� � ����㠫쭮� ���?
	jb		_veri_nxt_1_
	mov		ecx, [edx].vstack_addr
	mov		[edi].xregs_struct.x_esp, ecx
	mov		[edi].xregs_struct.x_ebp, ecx
	;jmp		_veri_ret_
_veri_nxt_1_:
	mov		esi, vlm_xids_addr 
	assume	esi: ptr XTG_INSTR_DATA_STRUCT
	mov		edi, [edx].instr_buf_addr
	mov		ecx, [esi].instr_size
	mov		esi, [esi].instr_addr
	mov		eax, 0424548Bh												;mov edx, dword ptr [esp + 04]
	stosd																;�㤥� �������� ���祭�� edx'a ������ � ᯥ�. ���� (�।�);
																		;⠪ ᤥ���� ��⮬�, �� � ��襬 ����� ���� �맮� call dword ptr [edx + xxh];
																		;�� �� ��� ࠧ �믮��塞 ������� � ᯥ�. �।�; �᫨ �� �������� edx � �����, ⮣�� �믮����� �㫨�㥬� ������� �� ᬮ��� - 
																		;edx �ਬ�� 㦥 ��㣮� ���祭��;
	mov		eax, 0824648Bh												;mov esp, dword ptr [esp + 08]
	stosd																;esp - ⮦� �����塞 � ᯥ�. �।�, �⮡� �� ����न�� ����㠫�� ���;
	rep		movsb														;x_instr;

	mov		ecx, [edx].xregs_curv_struct_addr
	assume	ecx: ptr XTG_REGS_CURV_STRUCT

	mov		ax, 0D89h													;mov dword ptr [addr_1], ecx
	stosw																;�� ��室� �� ᯥ�. �।� �� ������ ��࠭��� ���� ���祭�� ����㠫��� ॣ��;
																		;��� �⮣� �������� ᯥ�. �����, ����㯭�� �१ ecx; ���⮬� ��। ��室�� �� ��࠭�� 
																		;���祭�� ����㠫쭮�� ecx � ᯥ�. �।�; � ��᫥ � ����� ����⠭���� ecx. � ����� ���쬥� ���祭�� ����. ecx, ���஥ ��࠭��� � ᯥ�. �।� 
																		;� ��࠭�� ��� � ��襩 �����;
	lea		eax, dword ptr [edi + 18]
	stosd
	mov		ax, 2589h													;mov dword ptr [addr_1 + 04], esp
	stosw																;etc
	lea		eax, dword ptr [edi + 12 + 04]
	stosd
	mov		al, 0BCh													;mov esp, value
	stosb																;esp ������ 㪠�뢠�� �� �� ����, �⮡� ���४⭮ ��� �� ᯥ�. �।� (����); 
	lea		eax, dword ptr [esp - (8 * 4 + 4 + 4 * 2 + 4)]				;pushad + push ecx + push + push + call; 
	stosd
	mov		al, 0C2h													;ret 08;
	stosb
	mov		ax, 0008h
	stosw

	pushfd
	mov		eax, dword ptr [esp] 
	mov		vlm_real_flags, eax 										;��࠭�� � ������ ��६����� ⥪�騥 ���祭�� 䫠��� �����;
	mov		eax, [edx].flags_addr
	mov		eax, dword ptr [eax]										;��⥬ ���쬥� ��࠭���� ���祭�� 䫠��� �㫨�㥬��� ���� 
	mov		dword ptr [esp], eax										;� ᤥ���� �� ⥪�騬�
	popfd

	pushad																;��࠭�� ॣ�
	push	ecx															;� �⤥�쭮 ecx;
	mov		eax, [ecx].xregs_struct.x_eax								;��⠭���� ���祭�� ॣ�� ⥪�騬� ���祭�ﬨ ����㠫��� ॣ�� (��� �㫨�㥬��� ����);
	mov		ebx, [ecx].xregs_struct.x_ebx
	mov		ebp, [ecx].xregs_struct.x_ebp
	mov		esi, [ecx].xregs_struct.x_esi
	mov		edi, [ecx].xregs_struct.x_edi
	push	[ecx].xregs_struct.x_esp									;edx & esp - ���� ��⠭���������� 㦥 � ᯥ�. �।�;
	push	[ecx].xregs_struct.x_edx
	mov		ecx, [ecx].xregs_struct.x_ecx
	call	[edx].instr_buf_addr										;����᪠�� ������� � ᯥ樠�쭮� �।� (�����); 

	pop		ecx															;����⠭���� ecx;
	mov		[ecx].xregs_struct.x_eax, eax								;��࠭�� ���� ���祭�� ����㠫��� ॣ��;
	mov		[ecx].xregs_struct.x_edx, edx
	mov		[ecx].xregs_struct.x_ebx, ebx
	mov		[ecx].xregs_struct.x_ebp, ebp
	mov		[ecx].xregs_struct.x_esi, esi
	mov		[ecx].xregs_struct.x_edi, edi
	popad																;����⠭���� ��⠫�� ॣ�
	mov		eax, dword ptr [edi]										;����६ �� ᯥ�. �।� ���祭�� ����㠫쭮�� ॣ� ecx;
	mov		[ecx].xregs_struct.x_ecx, eax								;� ��࠭�� ��� � ��襩 �����;
	mov		eax, dword ptr [edi + 04]									;�������筮 � esp;
	mov		[ecx].xregs_struct.x_esp, eax

	pushfd																;��࠭�� 䫠�� �㫨�㥬��� ����, 
	mov		eax, dword ptr [esp]										;� ����⠭���� 䫠�� �����;
	mov		edi, [edx].flags_addr
	mov		dword ptr [edi], eax
	mov		eax, vlm_real_flags
	mov		dword ptr [esp], eax
	popfd

	xor		eax, eax
	inc		eax

_veri_ret_:
	mov		dword ptr [esp + 1Ch], eax
	popad
	ret																	;��室��;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;����� �㭪� vl_emul_run_instr; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx





;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;�㭪� vl_code_analyzer
;��������� ����: ������ (� ����஥���) ������ �������樨/������樨; 
;����: 
;	ebx		-	etc;
;	����������� ����� XTG_INSTR_PARS_STRUCT; 
;	⠪�� ��। �맮��� ������ �㭪�, �㦭� ��� ����室���� ����ந�� � ���㫨��;
;	ᬮ�� � ����; 
;	etc;
;�����:
;	EAX		-	0, �᫨ ��������� �� ���室�� �� ������, ���� 1;
;	(+)		-	᪮�४�஢���� ��᪨, ���ﭨ� ॣ��, �����-��஢ � �.�.;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
vl_code_analyzer:
	pushad

	mov		ecx, vlm_xrcs_addr
	assume	ecx: ptr XTG_REGS_CURV_STRUCT
	mov		edx, vlm_xips_addr
	assume	edx: ptr XTG_INSTR_PARS_STRUCT

	mov		eax, [ecx].regs_init
	mov		vlm_tmp_var1, eax											;� �⮩ ��६����� ��࠭�� ���� regs_init;
	mov		eax, [ecx].regs_used
	mov		vlm_tmp_var2, eax											;this var = regs_used; 

	mov		eax, vlm_xlv_init_addr
	mov		eax, dword ptr [eax]										;�� ��६���� ���� �࠭���:
	mov		vlm_tmp_var3, eax											;���祭�� ��᪨ init ��� �����-��஢
	mov		eax, vlm_xlv_used_addr
	mov		eax, dword ptr [eax]
	mov		vlm_tmp_var4, eax											;used
	mov		eax, vlm_xlv_alv_addr
	mov		eax, dword ptr [eax]
	mov		vlm_tmp_var5, eax											;���-�� ��⨢��� �����-��஢/�室��� ��ࠬ�� etc; 

;========================================================================================================
																		;����� ���� �஢�ન �� ࠧ���� ��।���� 䫠��; 

;-------------------------------------------------------------------------------------------------------- 
	test	[edx].flags, XTG_VL_INSTR_CHG								;���砫� ��।����: �� ������� ��������� ���祭�� ��ࠬ���(��)? 
	jne		_vlca_instr_chg_
	test	[edx].flags, XTG_VL_INSTR_INIT								;��� ���樠����樨 ��ࠬ��஢? 
	jne		_vlca_instr_init_
	;jmp	_x_
;-------------------------------------------------------------------------------------------------------- 

;------------------------------------------------[CHG]---------------------------------------------------
;--------------------------------------------------------------------------------------------------------
_vlca_instr_chg_:														;�᫨ �� ������� ��������� ���祭�� ��ࠬ��஢, ⮣�� 
	test	[edx].flags, XTG_VL_P1_GET									;�஢�ਬ, 1-� ��ࠬ��� ����砥� ���祭��?
	jne		_vlca_ic_p1_get_											;�᫨ ��, � ��룠�� �����;
_vlca_ic_1_:
	test	[edx].flags, XTG_VL_P1_GIVE									;���� ��ࠬ �⤠�� ᢮� ���祭��?
	jne		_vlca_ic_p1_give_
_vlca_ic_2_:
_vlca_ic_3_:
	test	[edx].flags, XTG_VL_P2_GIVE									;��ன ��ࠬ �⤠�� ᢮� ���祭��?
	jne		_vlca_ic_p2_give_
_vlca_ic_4_:
	test	[edx].flags, XTG_VL_P2_GET									;��ன ��ࠬ �ਭ����� ᢮� ���祭��?
	jne		_vlca_ic_p2_get_
_vlca_ic_5_:
	jmp		_vlca_instr_ok_												;�᫨ �� ��ࠡ�⠫� �� �� 䫠�� � �� �஢�ન �ன���� �ᯥ譮, ⮣�� ��룠�� �� ���� ����, �⢥��騩 �� ���쭥���� ���४�஢�� ������ �������; 
;--------------------------------------------------------------------------------------------------------

;--------------------------------------------------------------------------------------------------------
_vlca_ic_p1_get_:														;�᫨ ���� ���� ��ࠬ, � �� �ਭ����� ���祭��, � 㧭���, �� �� �� ��ࠬ; 
	test	[edx].flags, XTG_VL_P1_REG									;�� ॣ?
	jne		_vlca_ic_p1_get_reg_
	test	[edx].flags, XTG_VL_P1_ADDR 								;��� ����?
	jne		_vlca_ic_p1_get_addr_

_vlca_ic_p1_give_:														;�᫨ ���� ��ࠬ �⤠�� ᢮� ���祭��, ⮣�� ⠪�� 㧭���, ����� �� ��ࠬ���; 
	test	[edx].flags, XTG_VL_P1_REG									;�� ॣ����?
	jne		_vlca_ic_p1_give_reg_

_vlca_ic_p2_give_:														;�᫨ ���� ��ன ��ࠬ, ����� �⤠�� ᢮� ���祭�� -  � 㧭���, ����� �� ��ࠬ; 
	test	[edx].flags, XTG_VL_P2_REG									;ॣ
	jne		_vlca_ic_p2_give_reg_
	test	[edx].flags, XTG_VL_P2_NUM									;�᫮
	jne		_vlca_ic_p2_give_num_
	test	[edx].flags, XTG_VL_P2_ADDR 								;���� (�����-���/�室��� ��ࠬ); 
	jne		_vlca_ic_p2_give_addr_

_vlca_ic_p2_get_:														;��ன ��ࠬ ����砥� ���祭��
	test	[edx].flags, XTG_VL_P2_REG									;��ன ��ࠬ ���� ॣ��; 
	jne		_vlca_ic_p2_get_reg_
;--------------------------------------------------------------------------------------------------------

;--------------------------------------------------------------------------------------------------------
;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
_vlca_ic_p1_get_reg_:													;������� ��������� ���祭�� ��ࠬ��, ��� ���� ��ࠬ ���� ॣ��, ����� ����砥� ���祭��; 
	mov		eax, [edx].param_1											;eax = ����� ॣ�, ����� �㦭� �஢����; 
	bt		[ecx].regs_used, eax										;�஢��塞, ����� �� ��� �� (�������� ��� ���祭��) � ��������; 
	jnc		_vlca_instr_no_												;�᫨ ���, ⮣�� ��룠�� �� ���� ����, ����� �⪠�� ���祭�� �㦭�� ��ࠬ��஢ �� �।��饥; 
	bts		vlm_tmp_var1, eax											;����, �� �ᯮ����⥫쭮� ��६����� (����� ᮮ�-�� ��᪥ regs_init) ���⠢�� 䫠�, ᮮ�-騩 ������� ॣ� - �� ����砥�, �� ॣ ����� ����୮ ���樠����஢��� (⠪ ��� �� 㦥 �ந��樠����஢��) (�� ����� �������� ��� ���祭��); 
	call	vlca_check_reg_state										;�஢�ਬ ���ﭨ� ॣ�
	test	eax, eax													;�᫨ ��� ⥪�饥 ���ﭨ� ���� � ⠡��� ���ﭨ� ��� ������� ॣ�, ⮣�� ������� �� ���室�� - ��� �� �⪠� ���祭��; 
	je		_vlca_instr_no_
	jmp		_vlca_ic_1_													;�᫨ �� ⥪�饥 ���ﭨ� �� �뫮 �������, ⮣�� ��� �� - ���室�� �� �஢��� ��⠫��� 䫠���; 
;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
_vlca_ic_p1_get_addr_: 													;etc, ⮫쪮 �� �� ॣ, � �����-���/�室��� ��ࠬ ([ebp +- XXh]); 
	mov		eax, [edx].param_1											;eax - ᮤ�ন� ���� �����쭮� ��६�����; 
	call	vlca_search_index_lv_addr									;�஢��塞, ���� �� ⠪�� ���� � ⠡��� ���ᮢ �����-��஢; 
	mov		vlm_tmp_var6, eax											;����祭��� ���祭�� (������ ��� -1) ��࠭�� � ������ ��६�����; 
	inc		eax															;
	je		_vlca_instr_no_												;�᫨ ���� ⠪��� ���, ����� ��६����� �� ���樠����஢���, � ᮮ�-��, � ��� ��� �������� ���祭��, �⮡� ��� ����� �뫮 ��������; 
	dec		eax
	mov		esi, vlm_xlv_used_addr										;����
	bt		dword ptr [esi], eax										;�஢�ਬ, ����� �� �������� ���祭�� ������ �����쭮� ��६�����
	jnc		_vlca_instr_no_												;�᫨ ���, ⮣�� ��� �� �⪠� ���祭��; 
	bts		vlm_tmp_var3, eax											;�᫨ ��, � ���砫� ���⠢�� 䫠� (� ��६�����) ��� ������ �����-���, �� ��� ����� ����୮ ���樠����஢���
	call	vlca_check_lv_state											;� ��⥬ �஢�ਬ ⥪�饥 ����� ���ﭨ�
	test	eax, eax													;�᫨ ⠪�� 㦥 �뫮, ����� ������� �� ��室�� �஢��� 
	je		_vlca_instr_no_
	jmp		_vlca_ic_1_													;���� ��� �� �஢��� ��㣨� 䫠���; 
;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	
;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
_vlca_ic_p1_give_reg_:													;etc, ⮫쪮 �� ॣ, ����� �⤠�� ���祭��
	mov		eax, [edx].param_1											;eax = ����� �஢��塞��� ॣ�; 
	bt		[ecx].regs_used, eax										;���祭�� ॣ� ����� ��������?
	jnc		_vlca_instr_no_												;�᫨ ���, � �⪠�뢠����
	btr		vlm_tmp_var1, eax											;����, � ᮮ�-饩 ��६����� ���⠢�� 䫠�, 㪠�뢠�騩, ॣ �⤠� ᢮� ���祭�� - � ��� ᭮�� ����� �ந��樠����஢���; 
	jmp		_vlca_ic_2_													;���室�� � �஢�થ ᫥����� 䫠���; 
;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	
;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
_vlca_ic_p2_give_reg_:													;etc, ⮫쪮 �� ��ࠬ 2 - ॣ, �⤠�騩 ᢮� ���祭��; 
	mov		eax, [edx].param_2											;eax = ����� �஢��塞��� ॣ�;
	bt		[ecx].regs_used, eax										;���祭�� ॣ� ����� ��������?
	jnc		_vlca_instr_no_												;�᫨ ���, � �� �⪠�
	btr		vlm_tmp_var1, eax											;�᫨ ��, 㪠���, �� ॣ ᭮�� ����� ���樠����஢���; 
	jmp		_vlca_ic_4_													;���室 �� �஢��� ��㣨� 䫠��� ������樨; 
;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
_vlca_ic_p2_give_num_:													;�⠥� �������� ��⪨, � =) (�⠪, �� ᥩ ࠧ �� ॣ � ��祥, � �᫮); 
	call	vlca_chkreset_param_3										;� �᫨ �� �᫮, ����� �������� ���� ���� param_3; �맮��� �㭪� �஢�ન; 
	inc		eax															;�᫨ � param_3 ����⢨⥫쭮 �뫨 ���⠢���� ���� ॣ��, �⤠��� ᢮� ���祭�� � �����-� (��� ��) �� ��� �� ��襫 �஢���, ⮣�� ��� �� �⪠� ���ﭨ� etc; 
	je		_vlca_instr_no_
	jmp		_vlca_ic_4_													;���� ��룠�� �� �஢��� ��⠫��� 䫠���; 
;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
_vlca_ic_p2_give_addr_: 												;etc, ⮫쪮 �� ���� �����-���/�室���� ��ࠬ�; 
	mov		eax, [edx].param_2 											;eax - ᮤ�ন� ��� ����; 
	call	vlca_search_index_lv_addr									;�஢�ਬ, ���� �� ��� ���� � ���� ���ᮢ �����-��஢/�室��� ��ࠬ��; 
	inc		eax
	je		_vlca_instr_no_												;�᫨ ���, ⮣�� ��� �����-���/etc �� �� ����� - �� �� �ந��樠����஢�� etc; ��룠�� �� �⪠� ���ﭨ� etc; etc; 
	dec		eax															;���� 
	mov		esi, vlm_xlv_used_addr
	bt		dword ptr [esi], eax										;�஢�ਬ, ����� �� �������� ���祭�� �����-���
	jnc		_vlca_instr_no_												;�᫨ ���, ⮣�� ��룠�� �� �⪠�
	btr		vlm_tmp_var3, eax											;���� 㪠���, �� �����-��� ᭮�� ����� ���樠����஢���; 
	;mov		vlm_tmp_var6, eax
	jmp		_vlca_ic_4_													;��룠�� �� �஢��� ��⠫��� 䫠���; 
;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
_vlca_ic_p2_get_reg_:													;ॣ
	mov		eax, [edx].param_2
	bt		[ecx].regs_used, eax										;����� �� �������� ��� ���祭��?
	jnc		_vlca_instr_no_
	bts		vlm_tmp_var1, eax											;����� ����୮� ���樠����樨
	call	vlca_check_reg_state										;�஢�ઠ ⥪�饣� ���ﭨ� � ��㣨��, ࠭�� ����祭�묨 ���ﭨﬨ
	test	eax, eax
	je		_vlca_instr_no_												;⠪�� 㦥 �뫮?
	jmp		_vlca_ic_5_													;�᫨ ���, � ��룠�� ����� �� �஢��� ��㣨� 䫠���; 
;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;--------------------------------------------------------------------------------------------------------
;------------------------------------------------[CHG]---------------------------------------------------

;------------------------------------------------[INIT]--------------------------------------------------
;--------------------------------------------------------------------------------------------------------	
_vlca_instr_init_:														;������� ���樠����樨 ��ࠬ��; 
	test	[edx].flags, XTG_VL_P1_GET									;���� ��ࠬ ����砥� ���祭��
	jne		_vlca_ii_p1_get_
_vlca_ii_1_:
_vlca_ii_2_:
_vlca_ii_3_:
	test	[edx].flags, XTG_VL_P2_GIVE									;��ன ��ࠬ �⤠�� ᢮� ���祭��; 
	jne		_vlca_ii_p2_give_
_vlca_ii_4_:
	jmp		_vlca_instr_ok_
;--------------------------------------------------------------------------------------------------------

;--------------------------------------------------------------------------------------------------------
_vlca_ii_p1_get_:														;etc
	test	[edx].flags, XTG_VL_P1_REG									;ॣ
	jne		_vlca_ii_p1_get_reg_
	test	[edx].flags, XTG_VL_P1_ADDR									;���� (�����-���)
	jne		_vlca_ii_p1_get_addr_

_vlca_ii_p2_give_:
	test	[edx].flags, XTG_VL_P2_REG									;ॣ
	jne		_vlca_ii_p2_give_reg_
	test	[edx].flags, XTG_VL_P2_NUM									;�᫮
	jne		_vlca_ii_p2_give_num_ 	
	test	[edx].flags, XTG_VL_P2_ADDR									;�����-���
	jne		_vlca_ii_p2_give_addr_
;--------------------------------------------------------------------------------------------------------

;--------------------------------------------------------------------------------------------------------	 
;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
_vlca_ii_p1_get_reg_:													;ॣ
	mov		eax, [edx].param_1											;eax = ����� ॣ� (0 - eax etc); 
	bt		[ecx].regs_init, eax										;ॣ 㦥 �� �ந��樠����஢��?
	jc		_vlca_instr_no_												;�᫨ ��, ⮣�� �� �㤥� ����ୠ� ���樠������ - � �� �� ���� ��, ����頥� - ���室 �� �⪠� ���祭��; 
	bts		vlm_tmp_var1, eax											;����, ���⠢�� 䫠�, �� ॣ �ந��樠����஢��
	bts		vlm_tmp_var2, eax											;� ��� ����� �� � ࠧ����� ���������; 
	call	vlca_check_reg_state										;⠪��, �஢�ਬ ⥪�饥 ���ﭨ� ॣ� 
	test	eax, eax													;�᫨ ��� 㦥 �뫮, ����� ������� �� ������ �� ���室�� - ��� � ���� - ��� �� �⪠� ���祭��; 
	je		_vlca_instr_no_
	jmp		_vlca_ii_1_													;�᫨ ⠪��� ���祭�� ��� �� �뫮, ⮣�� ���� ��� ���, �஢��塞 ��㣨� ��⠢訥�� 䫠�� �������; 
;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
_vlca_ii_p1_get_addr_: 													;���� �����-���; 
	mov		eax, [edx].param_1											;eax - ᮤ�ন� ��� ����
	call	vlca_search_index_lv_addr									;㧭��, ���� �� ��� ���� � ⠡��� ���ᮢ �����-��஢
	mov		vlm_tmp_var6, eax											;�᫨ ��� ������� -1 - ⮣�� �⮣� ���� ��� �� �뫮, � ����� ��� �����-��� �� �� �ந��樠����஢�� - � �� ᤥ���� �����=) 
	inc		eax															;�᫨ �� ������� �⫨筮� �� -1 �᫮ (��� ������ ���� � ⠡��� ���ᮢ), ⮣�� ���� ����, � �㦭� ��� �������⥫쭮 �஢�����; 
	jne		_viip1geta_idxok_
	dec		eax
	cmp		vlm_tmp_var5, vl_lv_num										;⠪��, �஢�ਬ, ᪮�쪮 � ��� 㦥 ��⨢��� �����-��஢: �᫨ >= max �����ন������� ��� �����-��஢, ⮣�� �����, ��룠�� �� �⪠� ���祭��; 
	jae		_vlca_instr_no_
	mov		eax, vlm_xlv_alv_addr										;���� - �� ��� ���⮪ ���� �� ��������, �᫨ ���� �� �� ������ � ⠡��� ���ᮢ �����-��஢; 
	mov		eax, dword ptr [eax]										;eax - ����砥� �᫮ ��⨢��� �����-��஢ - �� �᫮ ��� ࠧ �㤥� �����ᮬ � ⠡��� ���ᮢ, �� ���஬� ����� ������� ��� ����; 
	mov		vlm_tmp_var6, eax 											;��࠭�� ������ � ��६�����
	mov		esi, vlm_xlv_addr											;esi - ���� ⠡���� ���ᮢ �����-��஢; 
	push	[edx].param_1												;� ��࠭塞 ���� ����
	pop		dword ptr [esi + eax * 4]									;� �⮬ ����; 
	bts		vlm_tmp_var3, eax											;� ���⠢�� ��ਡ���, 㪠�뢠�騥, �� ��� �����-��� 㦥 �ந��樠����஢�� (����� �� ����୮� ���樠����樨); 
	bts		vlm_tmp_var4, eax											;� ��� ���祭�� ����� �ᯮ�짮���� � ࠧ����� ��������; 
	inc		vlm_tmp_var5												;㢥��稢��� �᫮ ��⨢��� �����-��஢ �� +1; 
	jmp		_vlca_ii_1_													;��룠�� �� �஢��� ��㣨� 䫠��� �������樨; 

_viip1geta_idxok_:														;� � �� ��������, �᫨ ���� �����-��� �� � ⠡��� ���ᮢ; 
	dec		eax
	mov		esi, vlm_xlv_init_addr										;�஢�ਬ, �����-��� 㦥 �ந��樠����஢��?
	bt		dword ptr [esi], eax
	jc		_vlca_instr_no_												;�᫨ ��, � �� �⪠�
	bts		vlm_tmp_var3, eax											;���� ���⠢��, �� ⥯��� �� �ந��樠����஢��
	bts		vlm_tmp_var4, eax											;� ��� ���祭�� ����� �� � ࠧ��� ��������; 
	call	vlca_check_lv_state											;� �஢�ਬ ⥪�饥 ���ﭨ� �����-���
	test	eax, eax													;�᫨ ��� 㦥 �뫮 (������� � ⠡��� ���ﭨ�), ⮣�� �� �⪠�; 
	je		_vlca_instr_no_
	jmp		_vlca_ii_1_													;�᫨ �� ���, � ���� �� ����� ���ﭨ� - ⮣�� ��� ��, �஢�ਬ ᫥���騥 䫠��; 
;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
_vlca_ii_p2_give_reg_:													;ॣ
	mov		eax, [edx].param_2											;eax - ����� ॣ�
	bt		[ecx].regs_used, eax										;ॣ ����� �� � ��������?
	jnc		_vlca_instr_no_												;�᫨ ���, ⮣�� �� �⪠� (⠪�� �뢠��, ����� ॣ ���� �� �ந��樠����஢��); 
	btr		vlm_tmp_var1, eax											;����, ��ᨬ 䫠� - �� ����砥�, �� ॣ ᭮�� ����� ���樠����஢���; 
	jmp		_vlca_ii_4_
;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
_vlca_ii_p2_give_num_:													;�᫮ - � ࠧ ⠪, ⮣�� ���� param_3 ����� ᮤ�ঠ�� ���⠢����� ����, ᮮ�-騥 ������� ॣ��, �஢�ਬ ��; 
	call	vlca_chkreset_param_3
	inc		eax 														;�����頥��� �᫮ >=0, ⮣�� ��� ��, ���� �� �஢��� ��㣨� 䫠���
	je		_vlca_instr_no_												;�᫨ �� �᫮ = -1, ⮣�� param_3 �筮 ���, � �����-� ॣ �� ���� �஢��� - ����� �� �⪠� ��� =) 
	jmp		_vlca_ii_4_
;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
_vlca_ii_p2_give_addr_:													;���� �����-���; 
	mov		eax, [edx].param_2 											;eax - ���� �����-���
	call	vlca_search_index_lv_addr									;�஢�ਬ, ���� �� ���� � ⠡��� ���ᮢ
	inc		eax
	je		_vlca_instr_no_												;�᫨ ���, � �� �⪠� (eax = -01); 
	dec		eax
	mov		esi, vlm_xlv_used_addr										;����, �஢�ਬ, ����� �� �����-��� �� � ��㣨� ��������?
	bt		dword ptr [esi], eax
	jnc		_vlca_instr_no_												;�᫨ ���, ⮣�� �⪠�뢠����
	btr		vlm_tmp_var3, eax											;�᫨ ��, ⮣�� ��ᨬ 䫠� � ��᪥ init - � ���� �����-��� ᭮�� ����� �㤥� ���樠����஢���; 
	jmp		_vlca_ii_4_													;��룠�� �� �஢��� ��⠫��� 䫠��� ������樨; 
;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;--------------------------------------------------------------------------------------------------------
;------------------------------------------------[INIT]--------------------------------------------------

;----------------------------------------------[INSTR OK]------------------------------------------------
_vlca_instr_ok_:														;�᫨ ������� �஢諠 �� �஢�ન, ⮣�� ��� �⫨筮, ������� ������� (�� �㤥� �⪠⮢); ⥯��� ᪮�४��㥬 ������; 
;_vlca_instr_reg_ok_:
;--------------------------------------------------------------------------------------------------------
	test	[edx].flags, XTG_VL_P1_GET									;���� ���� ��ࠬ, ����� ����砥� ���祭��?
	je		_virok_p2_
	test	[edx].flags, XTG_VL_P1_REG									;� �� ॣ?
	je		_virok_p1_addr_
	mov		eax, [edx].param_1											;eax - ����� ॣ�
	test	[edx].flags, XTG_VL_INSTR_INIT								;�᫨ �஢��塞�� ������� ��������� ��������� ���樠����樨, 
	je		_virok_p1_nxt_1_
	call	vlca_reset_reg_state										;⮣�� ��ᨬ �� ���ﭨ� ॣ� � 0 
_virok_p1_nxt_1_:	
	call	vlca_new_reg_state											;��࠭�� ����� ���ﭨ� ॣ�; 
;--------------------------------------------------------------------------------------------------------

;--------------------------------------------------------------------------------------------------------
_virok_p1_addr_: 														;�᫨ �� ���� ��ࠬ ����砥� ���祭��, � ��� ���� ��ࠬ - �����-���, ⮣�� ����㯨� � ���४�஢��; 
	test	[edx].flags, XTG_VL_P1_ADDR
	je		_virok_p2_
	mov		eax, vlm_tmp_var6											;eax - ᮤ�ন� ������ ���� �⮣� �����-��� � ⠡��� ���ᮢ �����-��஢; 
	inc		eax
	je		_virok_p2_													;�᫨ � eax = -1 (�� �� ������), ⮣�� ��룠�� ����� - ���४�஢��� ��祣�; 
	dec		eax
	test	[edx].flags, XTG_VL_INSTR_INIT								;����, �஢�ਬ, �஢��塞�� ������� - �� ������� ���樠����樨?
	je		_virok_p1_nxt_2_
	call	vlca_reset_lv_state											;�᫨ ⠪, � ��ᨬ �� ���ﭨ� �����-��� � 0; 
_virok_p1_nxt_2_:
	call	vlca_new_lv_state											;��࠭�� � ⠡��� ���ﭨ� ⥪�饥 ����� ���ﭨ� ������� �����-���; 
;--------------------------------------------------------------------------------------------------------

;--------------------------------------------------------------------------------------------------------
_virok_p2_:
	test	[edx].flags, XTG_VL_P2_GET									;��� ��� �������筮; 
	je		_virok_p3_
	test	[edx].flags, XTG_VL_P2_REG
	je		_virok_p2_addr_
	mov		eax, [edx].param_2
	test	[edx].flags, XTG_VL_INSTR_INIT
	je		_virok_p2_nxt_1_
	call	vlca_reset_reg_state
_virok_p2_nxt_1_:
	call	vlca_new_reg_state
;--------------------------------------------------------------------------------------------------------

;--------------------------------------------------------------------------------------------------------
_virok_p2_addr_:
_virok_p3_:
_virok_riu_:
	mov		ecx, vlm_xrcs_addr											;� ⥯��� �� ���� ���祭�� ��᮪, ��࠭�� �� �६����� ��६�����, ��७��� � ����ﭭ� ��६����; 
	assume	ecx: ptr XTG_REGS_CURV_STRUCT
	mov		eax, vlm_tmp_var1
	mov		[ecx].regs_init, eax
	mov		eax, vlm_tmp_var2
	mov		[ecx].regs_used, eax

	mov		ecx, vlm_xlv_init_addr	
	mov		eax, vlm_tmp_var3
	mov		dword ptr [ecx], eax
	mov		ecx, vlm_xlv_used_addr
	mov		eax, vlm_tmp_var4
	mov		dword ptr [ecx], eax
	mov		ecx, vlm_xlv_alv_addr
	mov		eax, vlm_tmp_var5 
	mov		dword ptr [ecx], eax

	xor		eax, eax													;eax = 1; ������� �ᯥ譮 ��諠 �஢���, ��� �� �㤥� ������ - ��⠭���� � ����-����, � ������ ᪮�४�஢���, ��� �⫨筮 - ��室�� xD; 
	inc		eax
	jmp		_vlca_ret_
;--------------------------------------------------------------------------------------------------------
;----------------------------------------------[INSTR OK]------------------------------------------------

;----------------------------------------------[INSTR NO]------------------------------------------------	
_vlca_instr_no_:
;_vlca_instr_reg_no_:
;--------------------------------------------------------------------------------------------------------
	test	[edx].flags, XTG_VL_P1_GET ;+ XTG_VL_P1_GIVE				;�᫨ ���� ��ࠬ - ॣ, ����� ����砥� ���祭��, ⮣�� �⪠⨬ ���祭��; 
	je		_virno_p2_
	test	[edx].flags, XTG_VL_P1_REG
	je		_virno_p1_addr_
	mov		eax, [edx].param_1											;eax - ����� ॣ�
	call	vlca_invalid_reg_state										;�⪠⨬ ��� ⥪�饥 ���祭�� �� �।��饥; 
;--------------------------------------------------------------------------------------------------------

;--------------------------------------------------------------------------------------------------------
_virno_p1_addr_: 														;�᫨ ��ࠬ - �����-���, ⮣�� �⪠⨬��
	test	[edx].flags, XTG_VL_P1_ADDR
	je		_virno_p2_
	mov		eax, vlm_tmp_var6											;eax - ������ ���� �����-��� � ⠡��� ���ᮢ; 
	inc		eax															;��� -1 - �᫨ -1, ⮣�� �⪠�뢠�� ��祣�, �� ��室; 
	je		_virno_p2_
	dec		eax
	call	vlca_invalid_lv_state										;����, �᫨ ������ (eax >= 0), ⮣�� �⪠⨬ ⥪�饥 ���祭�� �����-��� �� �।��饥; 
;--------------------------------------------------------------------------------------------------------

;--------------------------------------------------------------------------------------------------------
_virno_p2_:
	test	[edx].flags, XTG_VL_P2_GET ;+ XTG_VL_P2_GIVE				;�������筮
	je		_virno_p3_ 
	test	[edx].flags, XTG_VL_P2_REG
	je		_virno_p2_addr_
	mov		eax, [edx].param_2
	call	vlca_invalid_reg_state										;etc; 
;--------------------------------------------------------------------------------------------------------

;--------------------------------------------------------------------------------------------------------
_virno_p2_addr_:
_virno_p3_:
_vlca_inr_:
	xor		eax, eax													;eax = 0;
;--------------------------------------------------------------------------------------------------------
;----------------------------------------------[INSTR NO]------------------------------------------------

_vlca_ret_:
	mov		dword ptr [esp + 1Ch], eax									;eax
	popad
	ret																	;��室�� 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;����� �㭪� vl_code_analyzer; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx





;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;�㭪� vlca_chkreset_param_3
;�஢�ઠ ���� param_3 �� ������⢨� ���⠢������ ��⮢. �� ���� ᮮ�-�� ������� ॣ��. 
;� �஢�ઠ ��� ॣ��;
;����:
;		etc;
;		param_3		-	���祭��;
;�����:
;		eax			-	-1, �᫨ �஢�ઠ �� �ன����, ���� �᫮ >= 0 (8);
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
vlca_chkreset_param_3:
	xor		eax, eax													;eax = 0; 
_vcp3_cycle_:
	bt		[edx].param_3, eax ;btr										;�᫨ ��� ��⠭�����, ⮣�� � eax - ����� ॣ�, �⤠�饣� ᢮� ���祭��; 
	jnc		_vcp3_nr_
	bt		[ecx].regs_used, eax										;�஢�ਬ, ����� �� ��� ॣ �� � ��������?
	jnc		_vcp3_inv_													;�᫨ ���, ⮣�� �ࠧ� �� ��室;
	btr		vlm_tmp_var1, eax											;����, ���뢠�� ��� � ��᪥ init - �� ����砥�, �� ॣ ᭮�� ����� ���樠����஢���; 
_vcp3_nr_:
	inc		eax 														;㢥��稢��� ����稪; 
	cmp		eax, 08
	jne		_vcp3_cycle_
	jmp		_vcp3_ret_
_vcp3_inv_:
	xor		eax, eax
	dec		eax
_vcp3_ret_:
	ret																	;��室��; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;����� �㭪� vlca_chkreset_param_3 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx




	
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;�㭪� vlca_check_reg_state 
;�஢�ઠ ⥪�饣� ���ﭨ� ����㠫쭮�� ॣ� - ���� �� �� � ⠡��� ���ﭨ� ��� ������� ॣ�;
;����:
;	ebx		-	etc;
;	eax		-	����� ॣ�, ⥪�饥 ���ﭨ� ���ண� ���� �஢����; 
;�����:
;	eax		-	0, �᫨ ⥪�饥 ���ﭨ� ���� � ⠡��� ���ﭨ�, ���� 1 (���ﭨ� �� �������); 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
vlca_check_reg_state:
	push	ecx
	push	edx
	push	ebx
	push	edi
	mov		ecx, vlm_xrcs_addr
	assume	ecx: ptr XTG_REGS_CURV_STRUCT
	mov		edi, vlm_struct2_addr
	assume	edi: ptr XTG_LOGIC_STRUCT
	mov		edi, [edi].xregs_states_addr								;edi - ���� ⠡���� ���ﭨ�;
	mov		ebx, dword ptr [edi + eax * 4]								;��ࢠ� ������� - ���-�� ���ﭨ� ��� ������� ॣ�; ebx = ���-�� ����������� ���ﭨ� �஢��塞��� ॣ�; 
	mov		ecx, dword ptr [ecx + eax * 4]								;ecx = ⥪�饬� ���ﭨ�, ���஥ ���� �஢����; 
_vlca_crs_cycle_:	
	test	ebx, ebx													;�᫨ ���-�� ���ﭨ� = 0 (� ���� �� ����� ���), ⮣�� �஢����� �� � 祬, � ���᭮,  ⥪�饥 ���ﭨ� �� ������� =) 
	je		_vlca_not_found_state_
	dec		ebx															;����, � ebx - ������ ��।��� �������� XTG_REGS_CURV_STRUCT; (��稭��� � ����); 
	imul	edx, ebx, sizeof (XTG_REGS_STRUCT)							;edx = ࠧ��� 
	lea		edx, dword ptr [edx + edi + sizeof (XTG_REGS_STRUCT)]		;�ய�᪠�� ����� ��������, � edx = ���� �� ��।��� ��������, ����� �࠭�� ��।��� ���ﭨ� ॣ�; 
	cmp		ecx, dword ptr [edx + eax * 4]								;�ࠢ������ ⥪�饥 ���ﭨ� � ����� ���������� ���ﭨ��
	je		_vlca_yes_found_state_										;�᫨ ࠢ��, ⮣�� eax = 0 � ��室��
	jmp		_vlca_crs_cycle_											;����, �஢��塞 �����

_vlca_not_found_state_:													;�᫨ ⥪�饣� ���ﭨ� �� ������� � ����������� ���ﭨ� ��� ������� ॣ� ��� ����� ��� ����������� ���ﭨ�, ⮣�� eax = 1 � ��室��; 
	xor		eax, eax
	inc		eax
	jmp		_vlca_crs_ret_
_vlca_yes_found_state_:
	xor		eax, eax
	
_vlca_crs_ret_:
	pop		edi
	pop		ebx
	pop		edx
	pop		ecx
	ret																	;�� ��室 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;����� �㭪� vlca_check_reg_state 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx





;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;�㭪� vlca_new_reg_state
;���������� ������ ���ﭨ� � ⠡���� ���ﭨ� (� ���������� ���ﭨ�) ��� �����⭮�� ॣ�
;����:
;	eax		-	����� �஢��塞��� ॣ� (0 - eax, 1 - ecx etc); 
;�����:
;	(+)		-	����������� ���ﭨ� � 㢥��祭��� �� +1 ���-�� ���ﭨ� ��� ������� ॣ�; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
vlca_new_reg_state:
	push	ecx
	push	edx
	push	esi
	push	edi
	mov		ecx, vlm_xrcs_addr
	assume	ecx: ptr XTG_REGS_CURV_STRUCT
	mov		edi, vlm_struct2_addr
	assume	edi: ptr XTG_LOGIC_STRUCT
	mov		edi, [edi].xregs_states_addr
	mov		esi, dword ptr [edi + eax * 4]								;esi - ���-�� ����������� ���ﭨ�
	mov		ecx, dword ptr [ecx + eax * 4]								;ecx - ⥪�饥 ����� ���ﭨ�
	cmp		esi, vl_regs_states											;�᫨ ���-�� ����������� ���ﭨ� >= max �����ন������� ���-�� ���ﭨ�, ⮣�� 
	jb		_vlca_add_rs_crct_
	xor		esi, esi
	and		dword ptr [edi + eax * 4], 0								;���㫨� (��ᨬ � 0) ���-�� ���ﭨ� ������� ॣ�; 
_vlca_add_rs_crct_:
	imul	edx, esi, sizeof (XTG_REGS_STRUCT)
	lea		edx, dword ptr [edx + edi + sizeof (XTG_REGS_STRUCT)]		;edx - ᮤ�ন� ���� �� ��᫥���� �� ����� ������ ������ன, �࠭�饩 ���ﭨ� ॣ��
	mov		dword ptr [edx + eax * 4], ecx								;������塞 � ����� ����� ⥪�饥 ���ﭨ� ॣ�
	inc		dword ptr [edi + eax * 4]									;㢥��稢��� �� +1 ���-�� ����������� ���ﭨ� ������� ॣ�; 
	pop		edi
	pop		esi
	pop		edx
	pop		ecx
	ret																	;��室 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;����� �㭪� vlca_new_reg_state 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx





;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;�㭪� vlca_invalid_reg_state
;�⪠� ⥪�饣� ���ﭨ� ॣ� �� �।��饥
;��६ ��᫥���� ���ﭨ� � ����������� ���ﭨ�� ������� ॣ�, � ������ ��� ⥪�騬 ���ﭨ�� 
;�⮣� ॣ�
;����:
;	eax		-	����� ॣ�; 
;�����:
;	(+)		-	�⪠� ���ﭨ�; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
vlca_invalid_reg_state:
	push	ecx
	push	edx
	push	esi
	push	edi
	mov		ecx, vlm_xrcs_addr
	assume	ecx: ptr XTG_REGS_CURV_STRUCT
	mov		edi, vlm_struct2_addr
	assume	edi: ptr XTG_LOGIC_STRUCT
	mov		edi, [edi].xregs_states_addr
	mov		esi, dword ptr [edi + eax * 4]								;esi - ᮤ�ন� ���-�� ��� ����������� ���ﭨ� ������� ॣ�; 
	test	esi, esi													;�᫨ ��� = 0 (� ���� ���ﭨ� ��� �� �뫮), ⮣�� ��९�룭�� ����� (⠪�� ����� ����, �᫨ ॣ �� ࠧ� �� �஢����� - �� �㦭� ���� �ந��樠����஢��� � 0); 
	je		_vlca_na_rs_0_s_
	dec		esi															;㬥��蠥� �� -1;
_vlca_na_rs_0_s_:
	imul	edx, esi, sizeof (XTG_REGS_STRUCT) 
	lea		edx, dword ptr [edx + edi + sizeof (XTG_REGS_STRUCT)]		;edx - ᮤ�ন� ���� �� ��᫥���� �� ����� ������ ��������, �࠭���� ���ﭨ� ॣ��
	mov		edx, dword ptr [edx + eax * 4]								;���� ��᫥���� ���ﭨ� ������� ॣ�; 
	mov		dword ptr [ecx + eax * 4], edx								;� ������ ��� ⥪�騬; 
	;xor		eax, eax
	pop		edi
	pop		esi
	pop		edx
	pop		ecx	
	ret																	;��室��; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;����� �㭪� vlca_invalid_reg_state
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx





;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;�㭪� vlca_reset_reg_state
;��� ����������� ���ﭨ� ॣ� � 0; 
;����:
;	eax		-	����� ॣ�;
;�����:
;	(+)		-	���-�� ����������� ���ﭨ� �⮣� ॣ� ⥯��� = 0; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
vlca_reset_reg_state:
	push	edi
	mov		edi, vlm_struct2_addr
	assume	edi: ptr XTG_LOGIC_STRUCT
	mov		edi, [edi].xregs_states_addr
	and		dword ptr [edi + eax * 4], 0								;���뢠�� ���-�� ����������� ���ﭨ� �⮣� ॣ�; 
	pop		edi
	ret
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;����� �㭪� vlca_reset_reg_state; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx





;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;�㭪� vlca_new_lv_param
;�஢�ઠ - ���� �� ���� �室���� ��ࠬ� ([ebp + XXh]) � ⠡��� ���ᮢ �����-��஢/�室��� ��ࠬ�� 
;� �᫨ ���, ⮣�� ���������� �⮣� ����, � ⠪�� ���㫥��� ���-�� ���ﭨ� � ���������� ��ࢮ�� 
;⥪�饣� ���ﭨ� � ⠡���� ���ﭨ�;
;����:
;	eax		-	���� �室���� ��ࠬ�;
;�����:
;	(+)		-	㦥 ����ᠫ =)
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
vlca_new_lv_param:
	push	ecx
	push	esi
	push	edi
	push	eax
	
	call	vlca_search_index_lv_addr									;���砫� �஢�ਬ, ���� �� ⠪�� ���� � ⠡��� ���ᮢ �����-��஢; 
	
	inc		eax 
	pop		eax
	jne		_vnlp_ret_													;�᫨ ���� (eax = -1), ⮣�� ��室��
	mov		ecx, vlm_xlv_alv_addr										;�᫨ ���, ⮣�� ���堫� �����; 
	mov		edi, dword ptr [ecx]										;edi - ᮤ�ন� ���-�� ��⨢��� �����-��஢ � �室��� ��ࠬ��; 
	cmp		edi, vl_lv_num 												;�᫨ �� ���-�� >= max �����ন������� �᫠ ��⨢��� �����-��஢, ⮣�� ��室��; 
	jae		_vnlp_ret_
	inc		dword ptr [ecx]												;����, 㢥��稬 �� +1 �� ���-��; 
	mov		esi, vlm_xlv_addr
	mov		dword ptr [esi + edi * 4], eax 								;������� � ����� ���� ����
	mov		esi, vlm_xlv_used_addr 
	bts		dword ptr [esi], edi										;㪠���, �� ����� �室��� ��ࠬ ����� �� � ��㣨� ��������; 
	push	eax
	xchg	eax, edi 
	
	call	vlca_reset_lv_state											;� ⠪�� ᤥ���� ���-�� ��� ������������ ���ﭨ� = 0;
	
	call	vlca_new_lv_state ; 										;� ������� ⥪�饥 ���ﭨ� � ⠡���� ���ﭨ� - �� �㤥� ��ࢮ� ����������� ���ﭨ�; 
	
	pop		eax
_vnlp_ret_:
	pop		edi
	pop		esi
	pop		ecx
	ret																	;��室��; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;����� �㭪� vlca_new_lv_param
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx





;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;�㭪� vlca_check_lv_state
;�஢�ઠ ⥪�饣� ���ﭨ� �����-��� - ���� �� �� � ⠡��� ���ﭨ� ��� ������� �����-���;
;����:
;	ebx		-	etc;
;	eax		-	������ ���� �����-��� � ⠡��� ���ᮢ �����-��஢, ⥪�饥 ���ﭨ� ���ண� ���� �஢����; 
;�����:
;	eax		-	0, �᫨ ⥪�饥 ���ﭨ� ���� � ⠡��� ���ﭨ�, ���� 1 (���ﭨ� �� �������); 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
vlca_check_lv_state:
	push	ecx
	push	edx
	push	ebx
	push	edi
	mov		ecx, vlm_xlv_addr
	mov		ecx, dword ptr [ecx + eax * 4] 								;ecx - ᮤ�ন� ���� ������� �����-���; 
	mov		edi, vlm_xlv_states_addr
	mov		ebx, dword ptr [edi + eax * 4]								;ebx - ���-�� ����������� ���ﭨ� �⮣� �����-���; 
	mov		ecx, dword ptr [ecx] 										;ecx - ⥪�饥 ���ﭨ� �����-���
_vcls_cycle_:	
	test	ebx, ebx													;�᫨ ebx = 0, ��룠�� �����
	je		_vcls_nfs_
	dec		ebx
	imul	edx, ebx, (vl_lv_num * 4)
	lea		edx, dword ptr [edx + edi + (vl_lv_num * 4)]
	cmp		ecx, dword ptr [edx + eax * 4]								;����, ��稭��� �஢����� ������ ��࠭񭭮� ���ﭨ� � ⥪�騬 ���ﭨ��
	je		_vcls_yfs_													;�᫨ ᮢ������� �������, ⮣�� eax = 0 � ��室�� ���
	jmp		_vcls_cycle_

_vcls_nfs_:
	xor		eax, eax													;�᫨ ᮢ������� �� ������� ��� ��࠭��� ���ﭨ� ��� ���, ⮣�� eax = 1 � ��室��; 
	inc		eax
	jmp		_vcls_ret_
_vcls_yfs_:
	xor		eax, eax
	
_vcls_ret_:
	pop		edi
	pop		ebx
	pop		edx
	pop		ecx
	ret																	;�� ��室; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;����� �㭪� vlca_check_lv_state; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx





;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;�㭪� vlca_new_lv_state
;���������� ������ ���ﭨ� � ⠡���� ���ﭨ� (� ���������� ���ﭨ�) ��� �����⭮�� local-var; 
;����:
;	eax		-	������ �����-��� � ⠡��� ���ᮢ �����-��஢;
;�����:
;	(+)		-	����������� ���ﭨ� � 㢥��祭��� �� +1 ���-�� ���ﭨ� ��� ������� local var; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
vlca_new_lv_state:
	push	ecx
	push	edx
	push	esi
	push	edi
	mov		ecx, vlm_xlv_addr
	mov		ecx, dword ptr [ecx + eax * 4]								;ecx - ���� �����-���
	mov		edi, vlm_xlv_states_addr
	mov		esi, dword ptr [edi + eax * 4]								;esi - ���-�� ����������� ���ﭨ� �����-���
	mov		ecx, dword ptr [ecx] 										;ecx - ⥪�饥 ���ﭨ� �����-���
	cmp		esi, vl_lv_states											;�᫨ ���-�� ����������� ���ﭨ� �����-��� >= max �����ন������� ���-��, ⮣�� 
	jb		_vnls_nxt_1_
	xor		esi, esi
	and		dword ptr [edi + eax * 4], 0								;��ᨬ ���-�� ���ﭨ� � 0; 
_vnls_nxt_1_:
	imul	edx, esi, (vl_lv_num * 4)
	lea		edx, dword ptr [edx + edi + (vl_lv_num * 4)]				;edx - ���� �� ��᫥���� ������ன, ᮤ�ঠ�㥩 ���ﭨ� (��᫥���� ���ﭨ�) �����-��஢; 
	mov		dword ptr [edx + eax * 4], ecx								;������塞 ⥪�饥 ���ﭨ� � ���������� ���ﭨ�;
	inc		dword ptr [edi + eax * 4]									;㢥��稢��� �� +1 ���-�� ����������� ���ﭨ� �����-���; 
	pop		edi
	pop		esi
	pop		edx
	pop		ecx
	ret																	;��室��; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;����� �㭪� vlca_new_lv_state; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx





;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;�㭪� vlca_invalid_lv_state
;�⪠� ⥪�饣� ���ﭨ� local var �� �।��饥
;��६ ��᫥���� ���ﭨ� � ����������� ���ﭨ�� ������� local var, � ������ ��� ⥪�騬 ���ﭨ�� 
;�⮣� local var'a;
;����:
;	eax		-	������ ���� �����-��� � ⠡��� ���ᮢ �����-��஢; 
;�����:
;	(+)		-	�⪠� ���ﭨ�; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
vlca_invalid_lv_state:
	push	ecx
	push	edx
	push	esi
	push	edi
	mov		ecx, vlm_xlv_addr
	mov		ecx, dword ptr [ecx + eax * 4]								;ecx - ���� �����-���
	mov		edi, vlm_xlv_states_addr
	mov		esi, dword ptr [edi + eax * 4]								;esi - ���-�� ����������� ���ﭨ� �����-���
	test	esi, esi
	je		_vils_nxt_1_
	dec		esi
_vils_nxt_1_:
	imul	edx, esi, (vl_lv_num * 4)
	lea		edx, dword ptr [edx + edi + (vl_lv_num * 4)]				;edx - ���� �� ��᫥���� ��������, ᮤ�ঠ��� ��࠭�� ���ﭨ� (��᫥���� ���ﭨ�) �����-��஢
	mov		edx, dword ptr [edx + eax * 4]								;���� ���㤠 ���ﭨ� ������� �����-���
	mov		dword ptr [ecx], edx 										;� ������ ��� ⥪�騬 ���ﭨ�� ��� ������� �����-���; 
	pop		edi
	pop		esi
	pop		edx
	pop		ecx	
	ret																	;��室��; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;����� �㭪� vlca_invalid_lv_state; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 





;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;�㭪� vlca_search_index_lv_addr
;���� ���� �����-��� � ⠡��� ���ᮢ �����-��஢. 
;�᫨ ���� ������, ⮣�� ������� ������ � ⠡���, �� ���஬� �㤥� ������ ������ ����;
;����:
;	eax		-	���� �����-���;
;�����:
;	eax		-	-1, �᫨ ���� �� ������, ���� ������� ������ � ⠡��� ���ᮢ; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
vlca_search_index_lv_addr:
	push	ecx
	push	esi
	mov		esi, vlm_xlv_addr
	mov		ecx, vlm_xlv_alv_addr
	mov		ecx, dword ptr [ecx]										;ecx - ���-�� ��⨢��� �����-��஢ - �㤥� �஢�ઠ ⮫쪮 �।� ��⨢��� �����-��஢ - �� �����!
_vsila_cycle_:
	test	ecx, ecx													;�᫨ ecx = 0, ��룠�� �����; 
	je		_vsila_nf_
	dec		ecx
	cmp		dword ptr [esi + ecx * 4], eax								;�஢��塞 ���� � ����� ��࠭�� ���ᮬ � ⠡��� ���ᮢ �����-��஢; 
	je		_vsila_ok_													;�᫨ ���� ᮢ�������, ⮣�� �� ��室;
	jmp		_vsila_cycle_												;���� �஢��塞 �����;
_vsila_nf_:
	xor		ecx, ecx													;�᫨ ���� �� ������ ��� ���-�� ��⨢��� �����-��஢ = 0, ⮣�� ���� � eax = -1;
	dec		ecx
_vsila_ok_:
	xchg	eax, ecx													;
	pop		esi
	pop		ecx
	ret																	;��室��; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;����� �㭪� vlca_search_index_lv_addr; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx





;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;�㭪� vlca_reset_lv_state
;��� ����������� ���ﭨ� local-var � 0; 
;����:
;	eax		-	������ � ⠡��� ���ᮢ �����-��஢, �� ���஬� ����� ����� ���� ������� �����-���; 
;�����:
;	(+)		-	���-�� ����������� ���ﭨ� �⮣� local var ⥯��� = 0; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
vlca_reset_lv_state:
	push	edi
	mov		edi, vlm_xlv_states_addr
	and		dword ptr [edi + eax * 4], 0								;���뢠�� ���ﭨ� � 0; 
	pop		edi
	ret
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;����� �㭪� vlca_reset_lv_state; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx


	
	
 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;!!!!! �᫨ ������ �� �㦭�, � �� �㭪� �᪮������, � ��㣨� ����������; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
comment !
let_init:
	xor		eax, eax
	ret		04

let_main:
	ret		04 * 2
		
let_exit:
	ret
		;!
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx




