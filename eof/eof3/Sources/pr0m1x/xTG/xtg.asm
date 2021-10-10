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
;												xtg.asm													 ;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
;																										 ;
;												  =)!													 ;
;																										 ; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
;																										 ;
;												xTG														 ;
;			�����������������/�����������/���������� ��������� �������� ����������/������				 ; 
;																										 ;
;���� (stdcall: DWORD xTG(DWORD xparam)):																 ;
;	xparam				-	���� �������� XTG_TRASH_GEN 												 ;
;--------------------------------------------------------------------------------------------------------;
;�����:																									 ;
;	(+)					-	ᣥ���஢���� ����� �������/�����										 ;
;	(+)					-	���������� ��室�� ���� �������� XTG_TRASH_GEN							 ;
;	EAX					-	���� ��� ���쭥�襩 ����� ����											 ;
;--------------------------------------------------------------------------------------------------------;
;�������:																								 ;
;	(+)					-	�室�� ���� �������� XTG_TRASH_GEN (� ��㣨� �������) ��᫥ ��ࠡ�⪨ 	 ;
;							������ ������� ⥬� ��, �� � ��। �맮��� - �� ��������; 				 ; 
;	(+)					-	�᫨ �������� ���� ����������, � ������ �� ࠧ��� ���� 4;				 ;
;	(+)					-	����� ���� �㦥� ��� �����樨 ������ ������権. ����� �ਬ������� ���	 ;
;							ᠬ����⥫�� ������, ⠪ �, ���ਬ��, ����� � �������䮬, ����⠭⮬ 	 ;
;							��� ����஥��� ࠧ��筮�� ���� (堮�, ॠ����筮�� � �.�., ������/�ࢨ/	 ;
;							����), �ணࠬ� (������ ��shit'�) etc; 									 ;
;	(+)					-	���� ��⮨� �� 3 䠩���: xtg.inc & xtg.asm & logic.asm. ���� 䠩� - 		 ;
;							��������筨�. � �� ������� �� ����室��� �������� etc, � �� ��⪨� 	 ;
;							���ᠭ��. 2 & 3 䠩�� - ᠬ� ॠ������ ������ xTG � ��� ������. 			 ;
;							����� �� �����⠬ �㤥� ��⠫쭠� ������ ��� ����� ��� �㦭�� �������	 ; 
;	(+)					-	� ������� ���� ����, ���筮�� ����� ����-���� �������;					 ;
;	(+)					-	����� ��-� ��� xD;														 ; 
;--------------------------------------------------------------------------------------------------------; 
;																										 ; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
;v2.0.0

	

																		;m1x
																		;pr0mix@mail.ru
																		;EOF 

 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;�㭪a xTG
;�� � ���� ��� ����� (������ �㭪�);
;���� (stdcall xTG(DWORD xparam)):
;	xparam					-	���� �������� XTG_TRASH_GEN
;�����:
;	(+)						-	ᣥ���஢���� ����;
;	(+)						-	���������� ��室�� ���� �������� XTG_TRASH_GEN
;	EAX						-	���� ��� ���쭥�襩 ����� ����; 
;	(!) 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

xtg_struct1_addr		equ		dword ptr [ebp + 24h]					;���� �������� XTG_TRASH_GEN; 

xtg_allocated_addr		equ		dword ptr [ebp - 04]					;�뤥������ ������ � ������� alloc_addr
xtg_struct2_addr		equ		dword ptr [ebp - 08]					;���� �������� XTG_EXT...; 
																		;����� ���� ࠧ���� �ᯮ����⥫�� ��६���� (�� ��� � �祩, ������� ������ ����� ��थ�. ���祭��, ��� �����-���� �㭪権, ���ਬ��, xtg_tmp_var1 etc); 
xtg_tmp_var1			equ		dword ptr [ebp - 12]
xtg_tmp_var2			equ		dword ptr [ebp - 16]
xtg_tmp_var3			equ		dword ptr [ebp - 20]
xtg_tmp_var4			equ		dword ptr [ebp - 24]
xtg_tmp_var5			equ		dword ptr [ebp - 28]
xtg_tmp_var6			equ		dword ptr [ebp - 32]					;

xTG:
	pushad																;��࠭塞 � �⥪� �� ���; 
	cld																	;���뢠�� 䫠� ���ࠢ����� (��� ������襪); 
	mov		ebp, esp
	sub		esp, 36														;�뤥�塞 ���� � �⥪� ��� �������-��६����; 
	mov		xtg_tmp_var6, esp 											;��࠭�� ⥪�饥 ���祭�� ��;
	xor		eax, eax 
	mov		ebx, xtg_struct1_addr 
	assume	ebx: ptr XTG_TRASH_GEN										;ebx - address of XTG_TRASH_GEN 
	and		[ebx].nobw, 0												;����塞 ������ ���� (��� ��室���); 
	cmp		[ebx].alloc_addr, 0											;⥯��� ��।����, ����� ������ �� �㤥� ��: �� �⥪� ��� �뤥��� � ������� ᮮ�-� �㭮�; 
	je		_aafs_														;�᫨ ���� �㭪� �뤥����� �/��� �᢮�������� ����� ࠢ�� 0, ⮣�� �뤥��� ������ � �⥪�; 
	cmp		[ebx].free_addr, 0
	jne		_aaua_														
_aafs_:																	;allocate address from stack
	sub		esp, (sizeof (XTG_EXT_TRASH_GEN))							;�뤥�塞 ���� � �⥪� ��� �������� XTG_EXT_TRASH_GEN
	jmp		_stat_minsize_tbl_ 

_aaua_:																	;allocate address by using alloc_addr 
	push	(NUM_INSTR * 4 + sizeof(XTG_EXT_TRASH_GEN) + size_of_stack_commit + 04)
	call	[ebx].alloc_addr 											;�뤥�塞 ������ ��� ���� ������� + �������� XTG_EXT_TRASH_GEN + ᢮� ���� ���; 

	test	eax, eax													;�᫨ �� ����稫��� �뤥���� ����, ⮣�� �뤥��� ������ �� ���; 
	je		_aafs_
	
	lea		esp, dword ptr [eax + (NUM_INSTR * 04) + size_of_stack_commit]						
																		;esp = ����� � �뤥������ ���⪥ �����, � ���ண� (� ��஭� ������ ���ᮢ) �㤥� ������ ������� XTG_EXT_TRASH_GEN, 
																		;� � ���ண� (� ��஭� ������ ���ᮢ - ��� �⥪) �㤥� ��࠭��� ⠡���� ࠧ��஢ ������ � ���� ����� �������; 
_stat_minsize_tbl_:
	mov		xtg_allocated_addr, eax										;��࠭�� �������⥫쭮 ��� ���� � �����쭮� ��६�����; 
	mov		ecx, esp													;ecx - ᮦ�ন� ����, �� ���஬� �㤥� ࠧ��饭� ������� XTG_EXT_TRASH_GEN; 
																		;� ���� ⠡��� ࠧ��஢ ������ � ���� �� �������, � ⠪�� ������� XTG_EXT_TRASH_GEN �㤥� ��室���� ���� � �⥪�, ���� � �뤥������ �����; 
	
;---------------[TABLE OF (MAX) SIZE OF INSTR & OPCODE FREQUENCY STATISTICS (BEGIN)]---------------------
																		;� ��饬 ⥬� ⠪��: �᫨ �㦭� �������� �����-� ᢮� ���������, ⮣��: 
																		;1) ᮧ���� �� (� xtg.asm)
																		;2) 㢥��稢��� �� +1 NUM_INSTR (xtg.inc)
																		;3) ����� � ��� ⠡���� �����뢠�� ᢮� ����� �� ����� �������樨 (���� push - �� ��᫥���� ���������, � ������� ��� �஭㬥஢���); ���ਬ��, �᫨ ������塞 ᢮� push � ��砫�, ⮣�� � ⠡��� ���室�� - ������塞 ᢮� ���室 � ᠬ� �����; 
																		;4) ��᫥ ������塞 � "⠡���� ���室��" ���室 �� ᢮� ���������; 
																		;����⨪� ����砥���� ������� ����� �� ������� ᪮�४�஢��� �� ��㣮��. � ���� ����� ������ ��㯯� �������権 ⠪�� =)
																		;����訥 2 ���� - �� ���, ���訥 2 ���� - �� max ࠧ��� �������樨; 
;----------------------------------------[XMASK2 BEGIN]--------------------------------------------------		
	mov		eax, WINAPI_MAX_SIZE
	shl		eax, 16
	add		eax, 090h 
	push	eax
		
	push	030D0015h													;43	42	10 
	push	03090020h													;42	41	09
	push	00070009h													;41	40	08
	push	00030002h													;40	39	07
	push	00030008h													;39 38	06
	push	00070008h													;38	37	05
	push	00030030h													;37	36	04
	push	00030060h													;36	35	03
	push	03100011h													;35	34	02
	push	030C0010h													;34	33	01
	push	000A000Ah													;33	32	00
;-----------------------------------------[XMASK2 END]---------------------------------------------------
;----------------------------------------[XMASK1 BEGIN]--------------------------------------------------
	push	00060001h													;32	31
	push	00060002h													;31	30
	push	00060008h													;30	29
	push	00060003h													;29	28
	push	00060005h													;28	27
	push	000A000Eh													;27	26
	push	00060060h													;26	25
	push	00030000h													;25	24
	push	00020000h													;24	23
	push	00030000h													;23	22
	push	060B0020h													;22	21
	push	0364001Ah													;21	20
	push	03060001h													;20	19
	push	00810003h													;19	18
	push	03080025h													;18	17
	push	030C0009h													;17	16
	push	03090010h													;16	15
	push	03080010h													;15	14
	push	000D0030h													;14	13
	push	00550000h													;13	12	;�᫨ ०�� XTG_REALISTIC � � ��� ���� 0, ⮣�� �� ������� �� �㤥� ���������; 
	push	00030006h													;12	11
	push	00030002h													;11	10
	push	00030015h													;10	09
	push	00060003h													;09	08
	push	00020004h													;08	07
	push	00030016h													;07	06
	push	00060016h													;06	05
	push	0005000Bh													;05	04
	push	00020004h													;04	03
	push	00020040h													;03	02
	push	00020003h													;02	01
	push	00010010h													;01	00 
;-----------------------------------------[XMASK1 END]---------------------------------------------------	 
;---------------[TABLE OF (MAX) SIZE OF INSTR & OPCODE FREQUENCY STATISTICS (END)]----------------------- 
	mov		xtg_struct2_addr, ecx										;
	assume	ecx: ptr XTG_EXT_TRASH_GEN
	mov		[ecx].ofs_addr, esp											;��࠭塞 � ������ ���� ���� ⠡���� ࠧ��஢ ������ � ����⨪� �� �������; 
	mov		[ecx].one_byte_opcode_addr, 0								;���� �� ���㫨� ������ ����;
	mov		edi, [ebx].xfunc_struct_addr								;��࠭�� � �⥪� ������ ���� - ��� ����� ����������; 
	
_xtg_data_gen_:															;�������(��) ����-������: ��ப/�ᥫ; 
	push	[ebx].xdata_struct_addr	
	push	ebx
	call	xtg_data_gen

_xtg_let_:
	push	ebx															;XTG_TRASH_GEN   
	call	let_init													;��뢠�� �㭪� ���樠����樨 "������" ����-����; 

	mov		[ecx].xlogic_struct_addr, eax								;���� 0 ���� ���� �뤥������ ����� (��� ⠪�� XTG_LOGIC_STRUCT) (ᬮ�� � ����!) 
	
	call	gen_data_for_func 											;��뢠�� �㭪� �����樨 ������� (������) ��� ����� �㭪権 - �� ��। �⨬ �㭪� �஢���, 㪠���� ��, �⮡� �� ����ਫ� �㭪� ��� ���? 

	test	eax, eax													;�᫨ �� �����-� ��稭� (ᬮ�� � �㭪�) �� �� ������㥬 �㭪�, ⮣�� ��ࠢ�塞�� ���� �� ������� ������; 
	je		_xtg_gen_trash_ 

_xtg_realistic_plus_func_:
	push	ecx
	push	ebx
	call	gen_func													;���� �맮��� �㭪� ������ �㭪権 � �஫�����, ���襬, ������� etc; 

	push	xtg_tmp_var1												;� xtg_tmp_var1 - � ��� �㤥� �������� ���� �뤥������ �����, ⠪ ��� �᢮����� ��; 
	call	[ebx].free_addr
 
	jmp		_xtg_nxt_1_ 												;��룠�� �����; 

_xtg_gen_trash_:	
	push	ecx
	push	ebx
	call	xtg_main													;��� ��뢠�� ᠬ� �㭪� �����樨 ����; 

_xtg_nxt_0_:	
	mov		eax, [ebx].tw_trash_addr									;eax - �室��� ����, �㤠 ���� �뫮 ������� ����
	mov		[ebx].ep_trash_addr, eax									;�� �� � �窠 �室� � ᮧ����� ����;
	add		eax, [ebx].nobw												;� nobw - ���-�� ॠ�쭮 ᣥ���஢������ ����
	mov		[ebx].fnw_addr, eax 										;� �� ���� ⥯��� ᮤ�ন� ���� ��� ���쭥�襩 ����� ����; 
_xtg_nxt_1_: 
	mov		esp, xtg_tmp_var6											;����⠭���� ��; 
	cmp		[ecx].xlogic_struct_addr, 0
	je		_xtg_nxt_2_

	push	[ecx].xlogic_struct_addr
	call	[ebx].free_addr

_xtg_nxt_2_:
	cmp		xtg_allocated_addr, 0										;�᫨ �� ���� != 0, ⮣�� ࠭�� �뫠 �뤥���� ������, ᥩ�� �᢮����� ��; 
	je		_xtg_final_
	
	push	xtg_allocated_addr
	call	[ebx].free_addr
		
_xtg_final_:	
	mov		[ebx].xfunc_struct_addr, edi								;����⠭�������� ࠭�� ��࠭񭭮� ���� ��������; 
	mov		eax, [ebx].fnw_addr 
	mov		dword ptr [ebp + 1Ch], eax 									;�� ��室� eax �㤥� ᮤ�ঠ�� ���� ��� ���쭥�襩 ����� ����; 
	mov		esp, ebp
	popad
	ret		04															;��室��!; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;����� �㭪� xtg 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx





;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;�㭪a xtg_main
;�᭮���� �㭪� �����樨 ���� (����७���); 
;���� (stdcall xtg_main(DWORD param1, DWORD param2)):
;	param1				-	���� (�����������) �������� XTG_TRASH_GEN 
;	param2				-	���� �������� XTG_EXT_TRASH_GEN  
;�����:
;	XTG_TRASH_GEN.nobw 	- 	���-�� ॠ�쭮 ����ᠭ��� ���⮢;
;	(+)					-	ᣥ��७�� ����; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;��� ���� ࠧ���� �ᯮ����⥫�� ��६����/���祭��/etc; 
XM_EAX				equ		00000000b									;00h 
XM_ECX				equ		00000001b									;01h
XM_EDX				equ		00000010b									;02h
XM_EBX				equ		00000011b									;03h
XM_ESP				equ		00000100b									;04h
XM_EBP				equ		00000101b									;05h
XM_ESI				equ		00000110b									;06h
XM_EDI				equ		00000111b									;07h

xm_struct1_addr		equ		dword ptr [ebp + 24h]						;XTG_TRASH_GEN
xm_struct2_addr		equ		dword ptr [ebp + 28h]						;XTG_EXT_TRASH_GEN 

xm_minsize_instr	equ		dword ptr [ebp - 04]						;�㤥� ᮤ�ঠ�� ࠧ��� ᠬ�� ���⪮� �������, ����㯭�� ��� �����樨; 
xm_tmp_reg0			equ		dword ptr [ebp - 08]						;� ��� ���� ࠧ���� ��६����, �� ������� �� ��� ���� � � ��㣨� �ᯮ����⥫��� �㭪�� (���砥� ����); 
xm_tmp_reg1			equ		dword ptr [ebp - 12]
xm_tmp_reg2			equ		dword ptr [ebp - 16]
xm_tmp_reg3			equ		dword ptr [ebp - 20]
xm_tmp_reg4			equ		dword ptr [ebp - 24]
xm_tmp_reg5			equ		dword ptr [ebp - 28]
xm_xids_addr		equ		dword ptr [ebp - 32]
  
xtg_main:
	pushad
	mov		ebp, esp
	sub		esp, 36
	mov		ebx, xm_struct1_addr
	assume	ebx: ptr XTG_TRASH_GEN
	mov		esi, xm_struct2_addr
	assume	esi: ptr XTG_EXT_TRASH_GEN
	mov		esi, [esi].xlogic_struct_addr
	assume	esi: ptr XTG_LOGIC_STRUCT
	test	esi, esi													;�᫨ ��� 0, ⮣�� ������ ����� �� �㤥� �ᯮ�짮������; 
	je		_xm_nxt_0_
	mov		esi, [esi].xinstr_data_struct_addr
_xm_nxt_0_:
	assume	esi: ptr XTG_INSTR_DATA_STRUCT
	mov		xm_xids_addr, esi											;XTG_INSTR_DATA_STRUCT;
	 
	call	get_minsize_instr											;�맮��� �㭪� ����祭�� �������쭮�� ࠧ��� �������, ����㯭�� ᥩ�� ��� �����樨; 
	
	mov		ecx, [ebx].trash_size										;ecx - ᮤ�ন� ࠧ��� ����, ����� ���� ᣥ�����; 
	mov		edi, [ebx].tw_trash_addr									;edi - ����, �㤠 ������� ����
	or		xm_tmp_reg0, -01											;�ந��樠�����㥬 ������ �������� ��६����� = -1; 
	add		[ebx].nobw, ecx 											;�� ���� ᥩ�� ࠢ�� ࠧ���� ����, ����� ���� ᣥ�����; 

_chk_instr_:

	mov		edx, xm_struct2_addr										;�����, ��� �஢�ਬ, ����� �� �� ������ � �᫨ ��, � ������ ��;
	assume	edx: ptr XTG_EXT_TRASH_GEN
	mov		esi, xm_xids_addr
	assume	esi: ptr XTG_INSTR_DATA_STRUCT
	test	esi, esi													;����� �� �� ������?
	je		_xm_nxt_1_
	cmp		[esi].instr_addr, 0											;�᫨ ��� 0, ⮣�� ��९�루���� (⠪�� �뢠��, ����� �� ���� ࠧ (��� ᭮��, ��� �� �����樨 �������権 (४����)) ��뢠�� xtg_main ��� �����樨 ����-����); 
	je		_xm_nxt_1_
	cmp		edi, [esi].instr_addr										;�᫨ �� ���� ᮢ����, � ��९�룭�� (⠪�� ����砥���, ����� �� ���諨 �� ������� �����-���� �������, �, ��� ���, ���ਬ��, 㦥 �� 墠⠥� ���⮢ - ⮣�� �� �����頥��� �� �롮� ��㣮� �������, � �� ���� ���� ࠢ��); 
	je		_xm_nxt_1_
	sub		[esi].instr_size, ecx										;����, ������� ᣥ��ਫ��� - �஢�ਬ, ���室�� �� ��� ��襬� ����-���� �� ������; 
																		;instr_size - ᮤ�ন� ��� ࠧ��� �⮩ �������; 
	push	[edx].xlogic_struct_addr									;XTG_LOGIC_STRUCT
	push	ebx															;XTG_TRASH_GEN
	call	let_main													;��뢠�� �㭪� �஢�ન (+ ���४樨) ������ ����-����; 

	test	eax, eax 													;�᫨ ������� ���室�� �� ������, ⮣�� ��� �⫨筮! (eax = 1); 
	jne		_xm_nxt_1_
	cmp		[esi].norb, 06												;�᫨ �� �� ���室��, � �஢�ਬ, ᪮�쪮 ��� ���⮢ ��⠫��� ��� �����樨 ����?
	jb		_xm_l06_													;�᫨ ���⮢ >= 6, ⮣�� ᣥ��७��� ������� ���� (��㣮� ����� ��������); ᪮�४��㥬 ���� � ࠧ���, �㤠 � ᪮�쪮 �����뢠�� ���� (���� ��� ����� ���� �㤥� 㪠�뢠�� ᭮�� �� � ����, ��� ᥩ�� ����ᠭ� �������, ����� ��� �� ����諠, 
	mov		edi, [esi].instr_addr										;� ࠧ��� ᭮�� ࠢ�� ���祭��, ���஥ �뫮 ��। �����樥� �⮩ �������); 
	mov		ecx, [esi].norb												;�᫮ 6 (���⮢) - ������ ⠪��, ⠪ ��� �᫨ �㦭� �ந��樠����஢��� ॣ ��� �������� ��� ���祭�� �a ����� (���ண� ��� �� �뫮), � 6 ���⮢ ������ ���室�� (���ਬ��, ������� mov reg32, imm32 � add reg32, imm32   etc); 
	jmp		_xm_nxt_1_													;� �⮣� ������� �� ����諠, �� ᪮�४�஢��� ���� � ࠧ��� ��� �����樨 ����, � ����ਬ ����� �������; 
_xm_l06_:
	test	[esi].param_1, XTG_XIDS_CONSTR								;�᫨ < 6, ⮣�� ��� �஢�ਬ, �� �� ���⠢��� ���訩 ��� � ������ ���� - �᫨ ���, ⮣�� �� ����ਬ �������, ����� �� �ਭ������� ��������� (push/pop etc), 
	je		_xm_nxt_1_													;� �७ � �⮩ �������� - ������ ⠪, �� ��� ��室�� �஢��� - �� ��� ⮣�, �⮡� ��� ���裥� ࠡ�⠫ ���४⭮; 
	mov		edi, [esi].instr_addr										;�᫨ �� ���訩 ��� �� ��⠭�����, ⮣�� ������� ����� ����� �������樨 � ࠧ���� �� ������� ����� - �� ���� ᪮�४��㥬 ���� � ࠧ��� ��� �����樨 ���� � �멤�� (�� ४��ᨨ); 
	mov		ecx, [esi].norb
	jmp		_xm_final_
		
_xm_nxt_1_:
	cmp		ecx, xm_minsize_instr										;� ⥯��� ��筥� ������� ���蠪... �᫨ ���-�� ��⠢���� ���⮢ ��� �����樨 ���� ����� ࠧ��� ᠬ�� ���⪮� ������樨, ����㯭�� ��� �����樨, ⮣�� ��室��; 
	jl		_xm_final_
	
_ci_:		
	push	NUM_INSTR													;���� ��砩�� ��।����, ����� ������� �㤥� �������?; 
	call	[ebx].rang_addr
	
	call	check_instr													;�஢�ਬ, ���� �� ��ਪ �� �������? 
	
	inc		eax
	je		_ci_														;�᫨ ���, ⮣�� ��� ���, ��筥� ��-����� =)! 
	dec		eax
	 
	test	esi, esi													;�᫨ ������ ����饭�, ⮣�� ��९�루����
	je		_xm_nxt_2_
	mov		[esi].instr_addr, edi										;���� ��࠭�� ���� ���饩 ����� �������
	mov		[esi].instr_size, ecx										;�� ࠧ��� ᥩ�� = ���-�� ��⠢���� ����. ����, �ਬ��: �����⨬, ᥩ�� �� ��� ����ᠫ� 5 (ecx = 5), ��⥬ ᣥ��ਫ� ���塠�⮢�� ������� (ecx = 5 - 3 = 2), � ��᫥ (� ���) �� ᤥ���� 5 - 2 = 3 ���� -> ࠧ��� ᣥ��७��� �������; 
	mov		[esi].flags, eax											;䫠� - �� ���� �� ��।����, �� �� ������� ����ਫ�;
	mov		[esi].norb, ecx												;���-�� ��⠢���� ���� ��� �����樨 ���� (�㦭� ��� �⪠�, �᫨ ������� �� �������� �� ������); 
	
;------------------------------------[TABLE OF JMP'S (BEGIN)]--------------------------------------------
																		;etc 
;----------------------------------------[XMASK1 BEGIN]--------------------------------------------------
_xm_nxt_2_:	
	;dec		eax
	test	eax, eax														
	je		inc_dec___r32												;00 (1 byte)
	dec		eax
	je		not_neg___r32												;01 (2 bytes) 
	dec		eax
	je		mov_xchg___r32__r32											;02 (2 bytes)
	dec		eax																
	je		mov_xchg___r8__r8_imm8										;03 (2 bytes)
	dec		eax
	je		mov___r32_r16__imm32_imm16									;04 (5 bytes) 
	dec		eax
	je		lea___r32___mso												;05 (6 bytes) 
	dec		eax
	je		adc_add_and_or_sbb_sub_xor___r32_r16__r32_r16				;06 (3 bytes)
	dec		eax
	je		adc_add_and_or_sbb_sub_xor___r8__r8							;07 (2 bytes) 
	dec		eax
	je		adc_add_and_or_sbb_sub_xor___r32__imm32						;08 (6 bytes)
	dec		eax
	je		adc_add_and_or_sbb_sub_xor___r32__imm8						;09 (3 bytes)
	dec		eax
	je		adc_add_and_or_sbb_sub_xor___r8__imm8						;10 (3 bytes)
	dec		eax
	je		rcl_rcr_rol_ror_shl_shr___r32__imm8							;11 (3 bytes)
	dec		eax
	je		push_pop___r32___r32										;12 (2 + 53h = 55h bytes)
	dec		eax
	je		push_pop___imm8___r32										;13 (3 + 0Ah = 0Dh bytes)
	dec		eax
	je		cmp___r32__r32												;14 (2 + 6 + 300h = 308h bytes) 
	dec		eax
	je		cmp___r32__imm8												;15 (3 + 6 + 300h = 309h bytes)
	dec		eax
	je		cmp___r32__imm32											;16 (6 + 6 + 300h = 30Ch bytes)
	dec		eax
	je		test___r32_r8__r32_r8										;17 (2 + 6 + 300h = 308h bytes)  
	dec		eax
	je		jxx_short_down___rel8										;18 (2 + 7Fh = 81h bytes)
	dec		eax
	je		jxx_near_down___rel32										;19 (6 + 300h = 306h bytes) 
	dec		eax
	je		jxx_up___rel8___rel32										;20 (300h + 50h + 05 + 03 + 06 + 06 = 364h bytes) 
	dec		eax
	je		jmp_down___rel8___rel32										;21 (300h + 300h + 06 + 05 = 60Bh bytes); 
	dec		eax
	je		cmovxx___r32__r32											;22 (3 bytes); 
	dec		eax
	je		bswap___r32													;23 (2 bytes) 
	dec		eax
	je		three_bytes_instr											;24 (3 bytes); 
	dec		eax
	je		mov___r32_m32__m32_r32										;25 (6 bytes); 
	dec		eax
	je		mov___m32__imm8_imm32										;26 (0Ah bytes); 
	dec		eax
	je		mov___r8_m8__m8_r8											;27 (06 bytes); 
	dec		eax
	je		inc_dec___m32												;28 (06 bytes); 
	dec		eax
	je		adc_add_and_or_sbb_sub_xor___r32__m32						;29 (06 bytes); 
	dec		eax
	je		adc_add_and_or_sbb_sub_xor___m32__r32						;30 (06 bytes); 
	dec		eax
	je		adc_add_and_or_sbb_sub_xor___r8_m8__m8_r8					;31 (06 bytes);  
;-----------------------------------------[XMASK1 END]---------------------------------------------------
;----------------------------------------[XMASK2 BEGIN]--------------------------------------------------
	dec		eax
	je		adc_add_and_or_sbb_sub_xor___m32_m8__imm32_imm8				;32 00 (0Ah bytes); 
	dec		eax
	je		cmp___r32_m32__m32_r32										;33 01 (300h + 06 + 06 = 30Ch bytes); 
	dec		eax
	je		cmp___m32_m8__imm32_imm8									;34 02 (300h + 10 + 06 = 310h bytes); 
	dec		eax
	je		mov_lea___r32__m32ebpo8										;35 03 (03 bytes); 
	dec		eax
	je		mov___m32ebpo8__r32											;36 04 (03 bytes); 
	dec		eax
	je		mov___m32ebpo8__imm32										;37 05 (07 bytes); 
	dec		eax
	je		adc_add_and_or_sbb_sub_xor___r32__m32ebpo8					;38 06 (03 bytes); 
	dec		eax
	je		adc_add_and_or_sbb_sub_xor___m32ebpo8__r32					;39 07 (03 bytes); 
	dec		eax
	je		adc_add_and_or_sbb_sub_xor___m32ebpo8__imm32_imm8			;40 08 (max 07 bytes etc); 
	dec		eax
	je		cmp___r32_m32ebpo8__m32ebpo8_r32							;41 09 (300h + 03 + 06 = 309h bytes); 
	dec		eax
	je		cmp___m32ebpo8__imm32_imm8									;42 10 (300h + 07 + 06 = 30Dh bytes); 

	dec		eax
	je		xwinapi_func												;43 
;-----------------------------------------[XMASK2 END]--------------------------------------------------- 
;------------------------------------[TABLE OF JMP'S (END)]----------------------------------------------

;-------------------------------------[EXIT FROM XTG_MAIN]-----------------------------------------------
_xm_final_: 
	sub		[ebx].nobw, ecx 											;�⭨���� �� ���祭�� ������� ���� ���-�� ������ᠭ��� ���⮢, � ����砥� �᫮ ॠ�쭮 ����ᠭ��� ���⮢; 
	mov		esp, ebp
	popad
	ret		04 * 2														;��室��; 
;-------------------------------------[EXIT FROM XTG_MAIN]-----------------------------------------------




 
;=========================================[INC/DEC REG32]================================================
;INC	EAX	etc (40h)
;DEC	EAX	etc	(48h) 
inc_dec___r32:
	test	ecx, ecx													;�᫨ ����� ��� ���� ��� �����樨 ����, � �� ��室
	je		_xm_final_

	push	02															;���� ��砩�� �롥६, ����� �� ���� �������� ������権 �㤥� �������
	call	[ebx].rang_addr

	shl		eax, 03
	add		al, 40h
	xchg	eax, edx

	call	get_free_r32												;����稬 ��砩�� ᢮����� ॣ����

	add		eax, edx
	stosb																;����襬 ᣥ���஢���� �����
	dec		ecx															;᪮�४��㥬 �᫮ ��⠢���� ���� ��� �����樨 � ����� ����
	jmp		_chk_instr_
;=========================================[INC/DEC REG32]================================================	 



;=========================================[NOT/NEG REG32]================================================
;NOT	EAX		etc (0F7h XXh)
;NEG	EAX		etc (0F7h XXh)
;etc
not_neg___r32:
	cmp		ecx, 02														;�᫨ �᫮ ��⠢���� ��� �����樨 � ����� ���� ���� ����� 2-�, � ��室��
	jl		_chk_instr_ 
	mov		al, 0F7h													;���� ᭠砫� ����襬 �����
	stosb

	push	02
	call	[ebx].rang_addr												;��⥬ ��砩�� �롥६, ����� �������� �㤥� �����஢���

	shl		eax, 03														;ᬮ��, ��� ��ந��� ����� ���� (����)
	add		al, 0D0h
	xchg	eax, edx

	call	get_free_r32												;����砥� ᢮����� ॣ����

	add		eax, edx
	stosb																;etc 
	dec		ecx
	dec		ecx
	jmp		_chk_instr_
;=========================================[NOT/NEG REG32]================================================



;=====================================[MOV/XCHG REG32, REG32]============================================	 
;[MOV/XCHG REG32, REG32] ;�᫨ ����ਬ XCHG REG32, REG32, ⮣�� REG32 != EAX; 
;� ⠪�� REG32_1 != REG32_2
;MOV	EAX, EDX	etc (8Bh)
;XCHG	ECX, EDX	etc (87h)
;XCHG	EAX, EDX	etc (9Xh)
mov_xchg___r32__r32:
																		;����� ���� ����� ��।����� ������� (��㯯 ������� ������) 
OFS_MOV_8Bh			equ		50
OFS_XCHG_87h		equ		01
OFS_XCHG_9Xh		equ		01
																		;50 + 1 + 1 = 52 = 0x34; 
	cmp		ecx, 02														;�᫨ ����� ������㥬�� ������樨 ����� 2-�, 
	jl		_chk_instr_													;⮣�� ���஡㥬 ᣥ����� ����� ��������
	
	push	(OFS_MOV_8Bh + OFS_XCHG_87h + OFS_XCHG_9Xh) 				;����� �㬬� ���� ������ ������ ������� � ��� - �� ��ࠬ��� ��� ���;
	call	[ebx].rang_addr												;ᣥ��ਬ ��;
	
	cmp		eax, OFS_XCHG_9Xh											;�᫨ �� ����� ����� OFS_XCHG_9Xh, ⮣�� ᣥ��ਬ ����� �����;
	jl		xchg___eax__r32
	
	push	[ebx].fregs													;save
	
	cmp		eax, (OFS_XCHG_87h + OFS_XCHG_9Xh)							;�᫨ �� ����� �㬬� ���� OFS_XCHG_87h + OFS_XCHG_9Xh, � ᣥ��ਬ ����� �����
	jge		_8Bh_ 														;�᫨ �� ����� ���� ࠢ��, ⮣�� ᣥ��ਬ ����� 0x8B; 
_87h_:	
	mov		al, 87h														;[XCHG REG32, REG32] (REG32 != EAX); 
	
	mov		xm_tmp_reg0, XM_EAX											;and xm_tmp_reg0, 0; 㪠�뢠��, �� �㦭� �������஢��� ॣ���� EAX, ⠪ ��� ������� XCHG EAX, reg32 � ������ 2 �����! - �� ���;   
	call	set_r32														;��稬 ����� ॣ;
	
	jmp		_8Bh_87h_													;���室�� �����
_8Bh_:
	mov		al, 8Bh														;[MOV REG32, REG32]
_8Bh_87h_:
	stosb																;����襬 �����;

_gmm114r32_1_:
	call	modrm_mod11_for_r32											;����ਬ ���� MODRM;
	
	mov		edx, xm_tmp_reg1											;�᫨ reg1 == reg2, ⮣�� ����ਬ �� ����� ����� ����;
	cmp		edx, xm_tmp_reg2											;���� ����� ���������, ���ਬ��, [MOV EAX, EAX] etc - � �� � ��� ���; 
	je		_gmm114r32_1_
	stosb																;����襬 ��ன ���⥪;
	
	pop		[ebx].fregs													;restore 

	;call	unset_r32													;ࠧ��稬 ࠭�� �������஢���� REG;  
	
	dec		ecx															;᪮�४��㥬 ���-�� ��⠢���� ���� ��� �����樨 ����; 
	dec		ecx		 
	jmp		_chk_instr_													;���室�� � �����樨 ᫥���饩 �������; 

;========================================================================================================
;[XCHG EAX, REG32] ;REG32 != EAX;
;XCHG	EAX, EDX	etc (9Xh) 
xchg___eax__r32:														;�� ������� ������ ������樨 �� ����� ������� ⮫쪮 �� ����� mov_xchg___r32__r32 
	test	ecx, ecx
	je		_xm_final_
	
	mov		xm_tmp_reg0, XM_EAX											;㪠�뢠��, �� �㦭� �஢����, ᢮����� �� ॣ���� EAX
	call	is_free_r32													;��뢠�� �㭪� �஢���;
	
	inc		eax
	je		_chk_instr_
	dec		eax															;����? =)

_gfr32_for_9Xh_:	
	call	get_free_r32												;����砥� ��砩�� ᢮����� ॣ����
	
	test	al, al														;�᫨ �� EAX, � �஡㥬 ᭮��, ⠪ ��� ��� �� ���ࠨ���� ������� [XCHG EAX, EAX]; 
	je		_gfr32_for_9Xh_
	add		al, 90h
	stosb																;�����뢠�� ᣥ���஢���� ����; 
	dec		ecx
	jmp		_chk_instr_ 
;=====================================[MOV/XCHG REG32, REG32]============================================



;====================================[MOV/XCHG REG8, REG8/IMM8]==========================================
;[MOV/XCHG REG8, REG8] and [MOV REG8, IMM8]
;MOV	AL, CL	etc (8Ah)
;XCHG	AL, CL	etc (86h)
;MOV	AL, 05	etc	(0BXh) 
mov_xchg___r8__r8_imm8:

OFS_MOV_8Ah			equ		02
OFS_MOV_0BXh		equ		01
OFS_XCHG_86h		equ		01
	
	cmp		ecx, 02														;�������筮; 
	jl		_chk_instr_

	push	(OFS_MOV_8Ah + OFS_MOV_0BXh + OFS_XCHG_86h) 
	call	[ebx].rang_addr

	cmp		eax, OFS_XCHG_86h
	jl		_86h_
	cmp		eax, (OFS_XCHG_86h + OFS_MOV_0BXh)
	jge		_8Ah_

_0BXh_:																	;[MOV AL, 05]
	call	get_free_r8

	add		al, 0B0h
	stosb
	
	push	255
	call	[ebx].rang_addr
	
	inc		eax															;IMM8 > 0; 
	stosb
	jmp		_mxr8r8imm8_ret_
_86h_:																	;[XCHG AL, CL]
	mov		al, 86h
	jmp		_86h_8Ah_
_8Ah_:																	;[MOV AL, CL]
	mov		al, 8Ah
_86h_8Ah_:
	stosb

_gmm114r8_1_:
	call	modrm_mod11_for_r8

	mov		edx, xm_tmp_reg1
	cmp		edx, xm_tmp_reg2
	je		_gmm114r8_1_
	stosb
_mxr8r8imm8_ret_:
	dec		ecx
	dec		ecx
	jmp		_chk_instr_
;====================================[MOV/XCHG REG8, REG8/IMM8]==========================================	
	


;==================================[MOV REG32/REG16, IMM32/IMM16]========================================
;MOV	EAX, 12345678h	etc (0B8h XXXXXXXXh)
;MOV	AX , 1234h		etc	(66h 0B8h XXXXh)  
mov___r32_r16__imm32_imm16:
	cmp		ecx, 05
	jl		_chk_instr_
	xor		edx, edx

	push	10															;����⭮��� �����樨 ��䨪� 66h ��� ������ ������� = 1/10; 
	call	[ebx].rang_addr

	test	eax, eax
	jne		_mr32r16imm32imm16_0BXh_
_mr32r16imm32imm16_66h_:
	mov		al, 66h
	stosb
	inc		ecx
	xchg	eax, edx

_mr32r16imm32imm16_0BXh_:
	call	get_free_r32

	add		al, 0B8h
	stosb 

_mr32r16imm32imm16_grn_:
	push	-01															;������㥬 �� � ��������� [0x00..0xFFFFFFFF]; 
	call	[ebx].rang_addr

	cmp		eax, 81h													;imm32/imm16 > 80h (��� ����� � 80h �������), � ������ ⠪ ��⮬� �� � ॠ�쭮� ���� �᫨ imm32/imm16 < 80h, � ������ push imm32/imm16 pop reg32/reg16,  
	jb		_mr32r16imm32imm16_grn_ 									;���� ����� ������� �����; 
	stosw 
	cmp		dl, 66h
	je		_mr32r16imm32imm16_c_ecx_
	db		0Fh, 0C8h													;bswap	eax
	stosw
_mr32r16imm32imm16_c_ecx_:
	sub		ecx, 5
	jmp		_chk_instr_
;==================================[MOV REG32/REG16, IMM32/IMM16]========================================



;====================================[LEA MODRM SIB OFFSET]==============================================
;LEA	EAX, DWORD PTR [ECX + EDX]		etc	FOR ALL THIS INSTR OPCODE = 8Dh 
;LEA	ECX, DWORD PTR [EDX + EBX * 2]
;LEA	EDX, DWORD PTR [EBX + 0Ch]
;LEA	EBX, DWORD PTR [ESI + 1005h]
;etc 
lea___r32___mso:														;MODRM SIB OFFSET 
	cmp		ecx, 06														;etc 
	jl		_chk_instr_ 
	mov		al, 08Dh													;opcode
	stosb

	push	03															;����� �㤥� ��ந�� ���� modrm
	call	[ebx].rang_addr												;��� ��砫� ��砩�� �롥६ ०�� MOD; 

	mov		esi, eax
	shl		esi, 06
	test	eax, eax													;MOD == 000b ?
	je		_lea_mod_000b_
	dec		eax															;MOD == 001b ?
	je		_lea_mod_001b_
_lea_mod_010b_:															;MOD = 010b (2)
	call	get_free_r32												;� �⮬ ०��� �� ����� ����ந�� ⠪�� �������: LEA ECX, DWORD PTR [EDX + 558h] etc; offset - �� 32-塨⭮� �᫮; 
																		;����稬 ᢮����� ॣ32;
	shl		eax, 03														;ᤢ�� ����� �� 3 ���;
	add		esi, eax													;������� � mod;

	call	get_free_r32												;����稬 �� ���� ᢮����� ॣ32
																		;�����⭮ � �롮஬ ॣ��! �᫨ ᢮����� �㤥� ���ਬ�� esp ��� ebp, ⮣�� ������� lea �㤥� ᮢᥬ ��㣠�!; 
	add		eax, esi
	stosb																;modrm 

	push	(1000h)
	call	[ebx].rang_addr

	add		eax, 101h													;� ����� ����ਬ ᬥ饭�� aka offset;
	stosd																;offset = [0x101..0x1000 - 0x01 + 0x101] 
	sub		ecx, 06
	jmp		_chk_instr_

_lea_mod_001b_:															;MOD = 001 (1); 
	call	get_free_r32												;� �⮬ ०��� �� ����� ����ந�� ⠪�� �������: LEA ECX, DWORD PTR [EDX + 0x55] etc; offset - �� 8-����⭮� �᫮; 
																		;get free reg32;
	shl		eax, 03
	add		esi, eax

	call	get_free_r32												;get free reg32

	add		eax, esi
	stosb

	push	(256 - 1)													;offset = [1..256 - 1 - 1 + 1]; 
	call	[ebx].rang_addr 

	inc		eax
	stosb
	jmp		_lea_r32mso_ret_
_lea_mod_000b_:															;MOD = 000b (0)
	call	get_free_r32												;� �⮬ ०��� �� ����� ����ந�� ⠪�� �������: LEA ECX, DWORD PTR [EDX * 8 + EDI] etc; ����� ����� offset'a ���� sib; 
																		;get free reg32;
	shl		eax, 03
	lea		eax, dword ptr [eax + esi + 04]								;ᮡ�ࠥ� ���� modrm, � � �� 㪠�뢠��, �� ��᫥ ���� �㤥� ��� ���� sib; 
	stosb
	
	push	04															;��砩�� �롨ࠥ� ��� ॣ���� �����⥫�: (0 - �����⥫� 1, 1 - 2, 2 - 4, 3 - 8); 
	call	[ebx].rang_addr

	shl		eax, 06
	xchg	eax, esi

	call	get_free_r32												;get free reg32_1; or rnd_reg?

	shl		eax, 03
	add		esi, eax

	call	get_free_r32												;get free reg32_2; etc 

	add		eax, esi
	stosb
_lea_r32mso_ret_:
	sub		ecx, 03
	jmp		_chk_instr_
;====================================[LEA MODRM SIB OFFSET]==============================================



;=======================[ADC/ADD/AND/OR/SBB/SUB/XOR REG32/REG16, REG32/REG16]============================
;ADC	ECX, EDX	etc (13h)											;��࠭� ������ ����� ������, ⠪ ��� ��㣨� ������ ��� ������ ������ ms �� ��������; 
;ADD	EAX, ECX	etc (03h)
;AND	EAX, EBX	etc (23h)
;OR		ESI, EDI	etc (0Bh)
;SBB	EDI, ESI	etc (1Bh) 
;SUB	EBX, EAX	etc (2Bh)
;XOR	ECX, EDI	etc (33h)
;XOR	CX,  AX		etc (66h 33h) 
;etc  
adc_add_and_or_sbb_sub_xor___r32_r16__r32_r16:
;comment ! 
OFS_XOR_33h			equ		35
OFS_ADD_03h			equ		25
OFS_SUB_2Bh			equ		15
OFS_AAAOSSX_r_XXh	equ		01

	cmp		ecx, 03
	jl		_chk_instr_ 

	push	20															;�㤥� �����஢��� ��䨪� 66h � ����⭮���� 1/20
	call	[ebx].rang_addr
	
	test	eax, eax
	jne		_aaaosssx_r__nxt_1_ 
	mov		al, 66h
	stosb
	dec		ecx
 
_aaaosssx_r__nxt_1_:
	push	(OFS_XOR_33h + OFS_ADD_03h + OFS_SUB_2Bh + OFS_AAAOSSX_r_XXh)
	call	[ebx].rang_addr

	cmp		eax, OFS_AAAOSSX_r_XXh 
	jl		_aaaossx_r_XXh_
	cmp		eax, (OFS_AAAOSSX_r_XXh + OFS_SUB_2Bh)
	jl		_2Bh_
	cmp		eax, (OFS_AAAOSSX_r_XXh + OFS_SUB_2Bh + OFS_ADD_03h)
	jge		_33h_
_03h_:																	;[ADD REG32/REG16, REG32/REG16]
	mov		al, 03h 
	jmp		_XXh_2Bh_03h_33h_
_2Bh_:																	;[SUB REG32/REG16, REG32/REG16]
	mov		al, 2Bh														
	jmp		_XXh_2Bh_03h_33h_
_33h_:																	;[XOR REG32/REG16, REG32/REG16]
	mov		al, 33h
	jmp		_XXh_2Bh_03h_33h_ 

_aaaossx_r_XXh_:														;[�� ��⠫�� ����㯭� ����� ������, ������ ᭮�� 03h, 2Bh, 33h]
	push	07															;����� ���� ������ ��砩��� �����樨 ������ �� �������� �������
	call	[ebx].rang_addr 
	
	shl		eax, 03
	add		al, 03 
_XXh_2Bh_03h_33h_:	
	stosb																;����襬 ᣥ���஢���� �����

_gmm114r32_2_: 
	call	modrm_mod11_for_r32											;����� ᣥ����㥬 ᫥���騩 ���� (modrm) 
	 
	cmp		byte ptr [edi - 01], 33h									;ᬮ�ਬ, �᫨ �।��騩 ����ᠭ�� ���� = 33h (XOR), 
	jne		_aaaosssx_r__nxt_2_
	mov		edx, xm_tmp_reg1											;⮣�� �ࠢ��� ��࠭�� ��砩�� ᢮����� ॣ�����
	cmp		edx, xm_tmp_reg2
	je		_aaaosssx_r__nxt_2_											;�᫨ �� ��� ࠢ��, ⮣�� ᬥ�� ����ਬ ����� ���� ���� (����); 

	push	eax

	push	20															;����, �᫨ ॣ����� ࠧ��, ⮣�� ����襬 ᣥ���஢���� ���� (� �⨬� ࠧ�묨 ॣ���) � ����⭮���� 1/20;
	call	[ebx].rang_addr

	test	eax, eax
	pop		eax
	jne		_gmm114r32_2_												;��� ᭮�� �஡㥬 ᣥ����� 2-�� ���� (����); 
_aaaosssx_r__nxt_2_:
	stosb
	dec		ecx
	dec		ecx
	jmp		_chk_instr_ 												;��ࠢ�塞�� �� ������� ᫥���饩 ������樨/�������樨; 
		;!
;=======================[ADC/ADD/AND/OR/SBB/SUB/XOR REG32/REG16, REG32/REG16]============================



;============================[ADC/ADD/AND/OR/SBB/SUB/XOR REG8, REG8]=====================================
;ADC	CL, DL		etc (12h)											;etc 
;ADD	AL, CH		etc (02h)
;AND	AH, BH		etc (22h)
;OR		DH, DL		etc (0Ah)
;SBB	BH, CH		etc (1Ah) 
;SUB	BL, AL		etc (2Ah)
;XOR	CH, DL		etc (32h) 
;etc  
adc_add_and_or_sbb_sub_xor___r8__r8:

OFS_XOR_32h			equ		15
OFS_ADD_02h			equ		15
OFS_SUB_2Ah			equ		15
OFS_AAAOSSX_r8_XXh	equ		01

	cmp		ecx, 02
	jl		_chk_instr_ 
	
	push	(OFS_XOR_32h + OFS_ADD_02h + OFS_SUB_2Ah + OFS_AAAOSSX_r8_XXh)
	call	[ebx].rang_addr

	cmp		eax, OFS_AAAOSSX_r8_XXh 
	jl		_aaaossx_r8_XXh_
	cmp		eax, (OFS_AAAOSSX_r8_XXh + OFS_SUB_2Ah)
	jl		_2Ah_
	cmp		eax, (OFS_AAAOSSX_r8_XXh + OFS_SUB_2Ah + OFS_ADD_02h)
	jge		_32h_
_02h_:																	;[ADD REG8, REG8]
	mov		al, 02h 
	jmp		_XXh_2Ah_02h_32h_
_2Ah_:																	;[SUB REG8, REG8]
	mov		al, 2Ah														
	jmp		_XXh_2Ah_02h_32h_
_32h_:																	;[XOR REG8, REG8]
	mov		al, 32h
	jmp		_XXh_2Ah_02h_32h_ 

_aaaossx_r8_XXh_:														;[�� ��⠫�� ����㯭� ����� ������, ������ ᭮�� 03h, 2Bh, 33h]
	push	07															;����� ���� ������ ��砩��� �����樨 ������ �� �������� �������
	call	[ebx].rang_addr 

	shl		eax, 03
	add		al, 02
_XXh_2Ah_02h_32h_:	
	stosb																;����襬 ᣥ���஢���� �����

_gmm114r8_2_: 
	call	modrm_mod11_for_r8											;����� ᣥ����㥬 ᫥���騩 ���� (modrm) 
	 
	cmp		byte ptr [edi - 01], 32h									;ᬮ�ਬ, �᫨ �।��騩 ����ᠭ�� ���� = 33h (XOR), 
	jne		_aaaosssx_r8__nxt_2_
	mov		edx, xm_tmp_reg1											;⮣�� �ࠢ��� ��࠭�� ��砩�� ᢮����� ॣ�����
	cmp		edx, xm_tmp_reg2
	je		_aaaosssx_r8__nxt_2_										;�᫨ �� ��� ࠢ��, ⮣�� ᬥ�� ����ਬ ����� ���� ���� (����); 

	push	eax

	push	20															;����, �᫨ ॣ����� ࠧ��, ⮣�� ����襬 ᣥ���஢���� ���� (� �⨬� ࠧ�묨 ॣ���) � ����⭮���� 1/20;
	call	[ebx].rang_addr

	test	eax, eax
	pop		eax
	jne		_gmm114r8_2_												;��� ᭮�� �஡㥬 ᣥ����� 2-�� ���� (����); 
_aaaosssx_r8__nxt_2_:
	stosb
	dec		ecx
	dec		ecx
	jmp		_chk_instr_ 												;��ࠢ�塞�� �� ������� ᫥���饩 ������樨/�������樨; 
;============================[ADC/ADD/AND/OR/SBB/SUB/XOR REG8, REG8]=====================================


   
;===========================[ADC/ADD/AND/OR/SBB/SUB/XOR REG32, IMM32]====================================
;[ADC/ADD/AND/OR/SBB/SUB/XOR REG32, IMM32] -> REG32 != EAX
;ADC	ECX, 12345678h	etc	(81h 0DXh)
;ADD	EDX, 87654321h	etc (81h 0CXh)
;AND	EBX, 21436587h	etc (81h 0EXh)
;OR		ESI, 78563412h	etc (81h 0CXh)
;SBB	EDI, 13572468h	etc (81h 0DXh)
;SUB	ECX, 56123487h	etc (81h 0EXh)
;XOR	EDX, 78461235h	etc (81h 0FXh)
adc_add_and_or_sbb_sub_xor___r32__imm32: 

OFS_ADD_81CXh			equ		35
OFS_SUB_81EXh			equ		25
OFS_AND_81EXh			equ		15
OFS_AAAOSSX_r_imm_XXh	equ		01
OFS_AAAOSSX_EAX_IMM_XXh	equ		15

	cmp		ecx, 06														;�᫨ ���-�� ��⠢���� ���� ��� �����樨 ���� ����� 6, ⮣�� �� ��室!
	jl		_chk_instr_

	push	(OFS_ADD_81CXh + OFS_SUB_81EXh + OFS_AND_81EXh + OFS_AAAOSSX_r_imm_XXh + OFS_AAAOSSX_EAX_IMM_XXh) 
	call	[ebx].rang_addr
	
	cmp		eax, OFS_AAAOSSX_EAX_IMM_XXh
	jl		adc_add_and_or_sbb_sub_xor___eax__imm32 
	mov		byte ptr [edi], 81h											;�����뢠�� ���砫� ����� 
	inc		edi
	cmp		eax, (OFS_AAAOSSX_EAX_IMM_XXh + OFS_AAAOSSX_r_imm_XXh)
	jl		_aaaossx_r_imm_XXh_
	cmp		eax, (OFS_AAAOSSX_EAX_IMM_XXh + OFS_AAAOSSX_r_imm_XXh + OFS_AND_81EXh)
	jl		_and_81EXh_
	cmp		eax, (OFS_AAAOSSX_EAX_IMM_XXh + OFS_AAAOSSX_r_imm_XXh + OFS_AND_81EXh + OFS_SUB_81EXh)
	jge		_add_81CXh_
_sub_81EXh_:															;[SUB REG32, IMM32]
	mov		al, 0E8h													;������ ������樨 ᮮ�-�� ���� MODRM [0xE8..0xEF]
	jmp		_aaaossx_r_imm_nxt_1_
_add_81CXh_:															;[ADD REG32, IMM32]
	mov		al, 0C0h
	jmp		_aaaossx_r_imm_nxt_1_
_and_81EXh_:															;[AND REG32, IMM32]
	mov		al, 0E0h 
	jmp		_aaaossx_r_imm_nxt_1_		

_aaaossx_r_imm_XXh_:													;����� ���� ��������� �� ��⠫�� (������ � �।��騥) ����㯭� ������� (�����); 
	push	07															;��� �����樨 CMP...; 
	call	[ebx].rang_addr

	shl		eax, 03
	add		al, 0C0h													;[0xC0..0xF7]
_aaaossx_r_imm_nxt_1_:	
	xchg	eax, edx
	
	;mov	xm_tmp_reg0, XM_EAX											;����� ���� ������� ॣ����
	;call	set_r32

_aaaossx_r_imm_gfr32_:
	call	get_free_r32												;����砥� ��砩�� ᢮����� ॣ
	
	test	eax, eax													;����� ���� ������� ॣ����, ���� ᤥ���� ⠪�� �஢���
	je		_aaaossx_r_imm_gfr32_										;�᫨ ��࠭ ॣ EAX, � ᭮�� �롨ࠥ� ��㣮� ॣ (⠪ ��� ����� ������� � ॣ�� EAX ����� ��㣨� ������ - �� ��ந� �ࠢ���� ������樨!); 

	add		eax, edx													;᪫��뢠�� ����祭�� ॣ���� (ॣ)
	stosb																;�����뢠�� ���� ᣥ���஢���� ���⥪; 

_aaaossx_r_imm_grn_:
	push	-01															;����ਬ �� � ��������� [0x101..0xFFFFFFFF] 
	call	[ebx].rang_addr

	cmp		eax, 101h													;imm32 > 100h, ���� �᫨ � ��� �㤥� imm < 100h, ⮣�� ����� ������� ����, ⠪ ��� � ⠪�� ��砥 ����� ������� 
	jb		_aaaossx_r_imm_grn_ 										;㪮�祭��� ����� ������ (83h...); 

	stosd																;����襬 ᣥ���஢����� ��; 

	;call	unset_r32

	sub		ecx, 06														;᪮�४��㥬 ���-�� ��⠢���� ���� ��� ����� ����; 
	jmp		_chk_instr_													;���室�� �� ������ ��㣨� ������; 

;========================================================================================================
;[ADC/ADD/AND/OR/SBB/SUB/XOR EAX, IMM32]
;ADC	EAX, 12345678h	etc (15h)
;ADD	EAX, 87654321h	etc (05h)
;AND	EAX, 21436587h	etc (25h)
;OR		EAX, 78563412h	etc (0Dh)
;SBB	EAX, 13572468h	etc (1Dh)
;SUB	EAX, 24681357h	etc (2Dh)
;XOR	EAX, 75318642h	etc (35h)
adc_add_and_or_sbb_sub_xor___eax__imm32:

OFS_ADD_EAX_05h			equ		35
OFS_SUB_EAX_2Dh			equ		25
OFS_AND_EAX_25h			equ		15
OFS_AAAOSSX_EAX_XXh		equ		01

	cmp		ecx, 05														;�᫨ ���-�� ��⠢���� ���� ��� �����樨 ���� ����� 5, � ��室�� 
	jl		_chk_instr_

	mov		xm_tmp_reg0, XM_EAX											;㪠�뢠��, �� �㦭� �஢����, ᢮����� �� ॣ���� EAX
	call	is_free_r32													;��뢠�� �㭪� �஢���;
	
	inc		eax															;�᫨ EAX = -01, ����� ॣ���� �����, � � ⠪�� ��砥 ��室�� �� ������ �������樨; 
	je		_chk_instr_
	;dec		eax

	push	(OFS_ADD_EAX_05h + OFS_SUB_EAX_2Dh + OFS_AND_EAX_25h + OFS_AAAOSSX_EAX_XXh)
	call	[ebx].rang_addr

	cmp		eax, OFS_AAAOSSX_EAX_XXh
	jl		_aaaossx_eax_XXh_
	cmp		eax, (OFS_AAAOSSX_EAX_XXh + OFS_AND_EAX_25h)
	jl		_and_eax_25h_
	cmp		eax, (OFS_AAAOSSX_EAX_XXh + OFS_AND_EAX_25h + OFS_SUB_EAX_2Dh)
	jge		_add_eax_05h_
_sub_eax_2Dh_: 															;[SUB EAX, IMM32]
	mov		al, 2Dh
	jmp		_aaaossx_eax_XXh_nxt_1_
_add_eax_05h_:															;[ADD EAX, IMM32]
	mov		al, 05h
	jmp		_aaaossx_eax_XXh_nxt_1_
_and_eax_25h_:															;[AND EAX, IMM32]
	mov		al, 25h
	jmp		_aaaossx_eax_XXh_nxt_1_

_aaaossx_eax_XXh_:														;������� ��� ��⠫��� ����㯭�� ������, ������ � �।��騥;
	push	07
	call	[ebx].rang_addr

	shl		eax, 03h
	add		al, 05h 
_aaaossx_eax_XXh_nxt_1_:
	stosb

_aaaossx_eax_XXh_grn_:													;������㥬 �� � [0x101..0xFFFFFFFF]; 
	push	-01
	call	[ebx].rang_addr

	cmp		eax, 101h													;etc
	jb		_aaaossx_eax_XXh_grn_ 
	stosd																;����襬 ��;
	sub		ecx, 05 													;᪮�४��㥬
	jmp		_chk_instr_ 												;���室�� � �����樨 ��㣨� ������権/�������権; 
;===========================[ADC/ADD/AND/OR/SBB/SUB/XOR REG32, IMM32]====================================



;===========================[ADC/ADD/AND/OR/SBB/SUB/XOR REG32, IMM8]=====================================
;ADC	EAX, 55h	etc	(83h 0DXh)
;ADD	ECX, 35h	etc	(83h 0CXh)
;AND	EDX, 7Fh	etc	(83h 0EXh)
;OR		EBX, 51h	etc	(83h 0CXh)
;SBB	ESI, 35h	etc	(83h 0DXh)
;SUB	EDI, 03h	etc	(83h 0EXh)
;XOR	EAX, 09h	etc	(83h 0FXh)  
adc_add_and_or_sbb_sub_xor___r32__imm8:

OFS_ADD_83CXh			equ		35										;��� ����� ���� ������ �㬬�୮� ���祭��, �� � ⠡��� ����, ���� �������㠫�� ����ன��; 
OFS_SUB_83EXh			equ		25
OFS_AND_83EXh			equ		15
OFS_AAAOSSX_r_imm8_XXh	equ		01 
	
	cmp		ecx, 03														;�᫨ ���-�� ��⠢���� ��� ����� ���� ���� ����� 3, � �� ��室 
	jl		_chk_instr_

	mov		al, 83h														;����襬 ᭠砫� ����� (1-� ����)
	stosb

	push	(OFS_ADD_83CXh + OFS_SUB_83EXh + OFS_AND_83EXh + OFS_AAAOSSX_r_imm8_XXh)
	call	[ebx].rang_addr

	cmp		eax, OFS_AAAOSSX_r_imm8_XXh
	jl		_aaaossx_r_imm8_XXh_
	cmp		eax, (OFS_AAAOSSX_r_imm8_XXh + OFS_AND_83EXh)
	jl		_and_83EXh_
	cmp		eax, (OFS_AAAOSSX_r_imm8_XXh + OFS_AND_83EXh + OFS_SUB_83EXh)
	jge		_add_83CXh_
_sub_83EXh_:															;[SUB REG32, IMM8]
	mov		al,0E8h 
	jmp		_aaaossx_r_imm8_XXh_nxt_1_
_add_83CXh_:															;[ADD REG32, IMM8]
	mov		al,0C0h 
	jmp		_aaaossx_r_imm8_XXh_nxt_1_
_and_83EXh_:															;[AND REG32, IMM8]
	mov		al,0E0h 
	jmp		_aaaossx_r_imm8_XXh_nxt_1_ 

_aaaossx_r_imm8_XXh_:													;[�� ��⠫�� �������, ������ � �।��騥 (SUB/ADD/AND)] 
	push	07
	call	[ebx].rang_addr

	shl		eax, 03														; 
	add		al, 0C0h
_aaaossx_r_imm8_XXh_nxt_1_:
	xchg	eax, edx

	call	get_free_r32												;����砥� ��砩�� ᢮����� ॣ����

	add		eax, edx
	stosb																;�����뢠�� ᫥���騩 (2-��) ���⥪

	push	(256 - 3)													;����稬 �� � ��������� [0x03..0xFF]
	call	[ebx].rang_addr

	add		eax, 03														;imm8 > 02; 
	stosb																;�����뢠�� ᫥���騩 (3-��) ����; 
	sub		ecx, 03
	jmp		_chk_instr_ 
;===========================[ADC/ADD/AND/OR/SBB/SUB/XOR REG32, IMM8]=====================================



;===========================[ADC/ADD/AND/OR/SBB/SUB/XOR REG8, IMM8]====================================== 
;[ADC/ADD/AND/OR/SBB/SUB/XOR REG8, IMM8] -> REG8 != AL
;ADC	CL, 005h	etc (80h 0DXh)
;ADD	DL, 0F8h	etc	(80h 0CXh)
;AND	BL, 78h		etc	(80h 0EXh)
;OR		AH, 35h		etc	(80h 0CXh)
;SBB	CH, 14h		etc	(80h 0DXh)
;SUB	DH, 0FFh	etc	(80h 0EXh)
;XOR	BH, 0EFh	etc	(80h 0FXh)
adc_add_and_or_sbb_sub_xor___r8__imm8:

OFS_ADD_80CXh				equ		35
OFS_SUB_80EXh				equ		25
OFS_AND_80EXh				equ		15
OFS_AAAOSSX_r8_imm8_XXh		equ		01
OFS_AAAOSSX_AL_IMM8_XXh		equ		15

	cmp		ecx, 03
	jl		_chk_instr_ 

	push	(OFS_ADD_80CXh + OFS_SUB_80EXh + OFS_AND_80EXh + OFS_AAAOSSX_r8_imm8_XXh + OFS_AAAOSSX_AL_IMM8_XXh) 
	call	[ebx].rang_addr
	
	cmp		eax, OFS_AAAOSSX_AL_IMM8_XXh
	jl		adc_add_and_or_sbb_sub_xor___al__imm8
	mov		byte ptr [edi], 80h											;᭠砫� ����襬 �����
	inc		edi 
	cmp		eax, (OFS_AAAOSSX_AL_IMM8_XXh + OFS_AAAOSSX_r8_imm8_XXh)
	jl		_aaaossx_r8_imm8_XXh_
	cmp		eax, (OFS_AAAOSSX_AL_IMM8_XXh + OFS_AAAOSSX_r8_imm8_XXh + OFS_AND_80EXh)
	jl		_and_80EXh_
	cmp		eax, (OFS_AAAOSSX_AL_IMM8_XXh + OFS_AAAOSSX_r8_imm8_XXh + OFS_AND_80EXh + OFS_SUB_80EXh)
	jge		_add_80CXh_ 
_sub_80EXh_:
	mov		al, 0E8h													;[SUB REG8, IMM8]
	jmp		_aaaossx_r8_imm8_XXh_nxt_1_
_add_80CXh_:															;[ADD REG8, IMM8]
	mov		al, 0C0h
	jmp		_aaaossx_r8_imm8_XXh_nxt_1_
_and_80EXh_:															;[AND REG8, IMM8]
	mov		al, 0E0h
	jmp		_aaaossx_r8_imm8_XXh_nxt_1_

_aaaossx_r8_imm8_XXh_:													;[�� ��⠫�� �������, ������ � �� SUB/ADD/AND]
	push	07
	call	[ebx].rang_addr

	shl		eax, 03
	add		al, 0C0h
_aaaossx_r8_imm8_XXh_nxt_1_:
	xchg	eax, edx

_aaaossx_r8_imm8_XXh_gfr8_: 
	call	get_free_r8													;����砥� ᢮����� ��砩�� 8-��ࠧ�來� ॣ����; 

	test	eax, eax													;�᫨ �믠� AL, ⮣�� ᭮�� �롨ࠥ� ��㣮� ��砩�� ॣ����; 
	je		_aaaossx_r8_imm8_XXh_gfr8_ 

	add		eax, edx
	stosb																;�����뢠�� ᫥���騩 ����

_aaaossx_r8_imm8_XXh_grn_:
	push	-01															;�롨ࠥ� �� � ��������� [0x03..0xFF]; 
	call	[ebx].rang_addr

	cmp		al, 03														;imm8 > 02; 
	jb		_aaaossx_r8_imm8_XXh_grn_
	stosb																;�����뢠�� �� ���� ���⥪; 
	sub		ecx, 03
	jmp		_chk_instr_ 

;========================================================================================================
;[ADC/ADD/AND/OR/SBB/SUB/XOR AL, IMM8]
;ADC	AL, 12h		etc	(14h)
;ADD	AL, 34h		etc	(04h)
;AND	AL, 0FFh	etc	(24h)
;OR		AL, 0F1h	etc	(0Ch)
;SBB	AL, 98h		etc	(1Ch)
;SUB	AL, 61h		etc	(2Ch)
;XOR	AL, 57h		etc	(34h) 
adc_add_and_or_sbb_sub_xor___al__imm8:

OFS_ADD_AL_04h			equ		35
OFS_SUB_AL_2Ch			equ		25
OFS_AND_AL_24h			equ		15
OFS_AAAOSSX_AL_XXh		equ		01

	cmp		ecx, 02
	jl		_chk_instr_

	mov		xm_tmp_reg0, XM_EAX											;㪠�뢠��, �� �㦭� �஢����, ᢮����� �� ॣ���� EAX (AL, �� �� AH!); 
	call	is_free_r32													;��뢠�� �㭪� �஢���;
	
	inc		eax															;�᫨ EAX = -01, ����� ॣ���� �����, � � ⠪�� ��砥 ��室�� �� ������ �������樨; 
	je		_chk_instr_

	push	(OFS_ADD_AL_04h + OFS_SUB_AL_2Ch + OFS_AND_AL_24h + OFS_AAAOSSX_AL_XXh)
	call	[ebx].rang_addr

	cmp		eax, OFS_AAAOSSX_AL_XXh
	jl		_aaaossx_al_XXh_
	cmp		eax, (OFS_AAAOSSX_AL_XXh + OFS_AND_AL_24h)
	jl		_and_al_24h_
	cmp		eax, (OFS_AAAOSSX_AL_XXh + OFS_AND_AL_24h + OFS_SUB_AL_2Ch)
	jge		_add_al_04h_
_sub_al_2Ch_:															;[SUB AL, IMM8]
	mov		al, 2Ch
	jmp		_aaaossx_al_XXh_nxt_1_
_add_al_04h_:															;[ADD AL, IMM8]
	mov		al, 04h
	jmp		_aaaossx_al_XXh_nxt_1_
_and_al_24h_:															;[AND AL, IMM8]
	mov		al, 24h
	jmp		_aaaossx_al_XXh_nxt_1_
	              
_aaaossx_al_XXh_:														;etc 
	push	07
	call	[ebx].rang_addr

	shl		eax, 03
	add		al, 04
_aaaossx_al_XXh_nxt_1_:
	stosb																;write 1-st byte

_aaaossx_al_XXh_grn_:
	push	-01
	call	[ebx].rang_addr

	cmp		al, 03														;imm8 > 02; 
	jb		_aaaossx_al_XXh_grn_
	stosb																;write 2-nd byte; 
	dec		ecx
	dec		ecx
	jmp		_chk_instr_ 
;===========================[ADC/ADD/AND/OR/SBB/SUB/XOR REG8, IMM8]======================================
 


;============================[RCL/RCR/ROL/ROR/SHL/SHR REG32, IMM8]=======================================
;RCL	EAX, 02h	etc	(0C1h 0DXh)
;RCR	ECX, 12h	etc	(0C1h 0DXh)
;ROL	EDX, 1Fh	etc	(0C1h 0CXh)
;ROR	EBX, 09h	etc	(0C1h 0CXh) 
;SHL	ESI, 05h	etc	(0C1h 0EXh)
;SHR	EDI, 15h	etc	(0C1h 0EXh)
;RCL	EAX, 01h	etc	(0D1h 0DXh) 
;etc 
rcl_rcr_rol_ror_shl_shr___r32__imm8:

OFS_RRRRSS_0C1h			equ		05
OFS_RRRRSS_0D1h			equ		01

OFS_SHL_SHR_r32_imm8	equ		35
OFS_RRRRSS_XXh			equ		15

	cmp		ecx, 03
	jl		_chk_instr_
	;xor		edx, edx 

	push	(OFS_RRRRSS_0C1h + OFS_RRRRSS_0D1h) 						;᭠砫� �롥६, ����� ����� ᣥ���஢���
	call	[ebx].rang_addr

	cmp		eax, OFS_RRRRSS_0D1h
	jl		_rrrrss_0D1h_
_rrrrss_0C1h_:															;[SHL/etc REG32, IMM8] -> IMM8 != 1; 
	mov		al, 0C1h
	jmp		_rrrrss_0C1h_0D1h_ 
_rrrrss_0D1h_:															;[SHL/etc REG32, 1]
	mov		al, 0D1h
_rrrrss_0C1h_0D1h_:
	stosb
	xchg	eax, edx

	push	(OFS_SHL_SHR_r32_imm8 + OFS_RRRRSS_XXh)						;⥯��� �롥६, ����� ������� �㤥� �����஢���
	call	[ebx].rang_addr 

	cmp		eax, OFS_RRRRSS_XXh
	jl		_rrrrss_XXh_

_shl_shr_r32_imm8_:														;[SHL/SHR REG32, IMM8]
	push	02
	call	[ebx].rang_addr
	
	shl		eax, 03
	add		al, 0E0h
	jmp		_rrrrss_r32_imm8_nxt_1_

_rrrrss_XXh_:															;[�� ��⠫�� ������樨, ������ ⠪�� SHL/SHR] 
	push	06															;�᫨ �㦭� �� ������� SAL/SAR, ⮣�� ����� 06 ��襬 08; 
	call	[ebx].rang_addr

	shl		eax, 03
	add		al, 0C0h
_rrrrss_r32_imm8_nxt_1_: 
	xchg	eax, esi

	call	get_free_r32												;����砥� ��砩�� ᢮����� ॣ����

	add		eax, esi
	stosb

	cmp		dl, 0D1h													;�᫨ �뫠 ᣥ���஢����� ������� [SHL/etc REG32, 1] 
	je		_rrrrss_r32_imm8_nxt_2_										;⮣�� �� ��室

	push	30															;���� ᣥ����㥬 IMM8 - �� 1-���⮢�� �᫮ � ��������� [2..31]; 
	call	[ebx].rang_addr

	inc		eax
	inc		eax
	stosb
	dec		ecx
_rrrrss_r32_imm8_nxt_2_: 
	dec		ecx
	dec		ecx	
	jmp		_chk_instr_													;���室�� � �����樨 ᫥����� ������権/������/�������権; 
;============================[RCL/RCR/ROL/ROR/SHL/SHR REG32, IMM8]=======================================
 


;================================[PUSH REG32/IMM8   POP REG32]===========================================

;========================================[PUSH REG32]====================================================
;PUSH	EAX	etc	(50h)
push_pop___r32___r32:
	push	50h															;�᫨ �������� ������ ���祭��, ⮣�� ��� ⠪�� �㦭� �������� � � ⠡��� ࠧ��஢ � ���⨪� ������ (�������); 
	call	[ebx].rang_addr

	add		eax, 03														;��� ⠪��, ⠪ ��� 50 (max ���-�� ���� ����� push � pop) + 3 (���ᠭ�� �� ᫥���饩 ��ப�) + 2 (ࠧ��� push (1) � pop (1) = 1 + 1 = 2 bytes); 
	mov		edx, eax													;3 ���� - ��� ⠪�� ⥬�: �᫨ ᣥ�������� push eax ... pop eax (ॣ� ���������), � �⮡� ��� �뫮 �ࠢ���������, �㦭� ���祭�� ॣ� eax ���-� �ᯮ�짮����, 
																		;���ਬ��, ⠪: push eax inc eax mov ecx,eax pop eax - ⮣�� �� �� �㤥� ���஬. ����� push � pop ��� ࠧ 3 ���� ������ ����砥���; 
	inc		eax															;����� eax += 2 - �� ࠧ��� push reg32 � pop reg32; 
	inc		eax
	cmp		ecx, eax
	jl		_chk_instr_

	call	get_num_free_r32											;����砥� ���-�� ᢮������ ॣ�� �� ����� ������; 

	cmp		eax, (03 + 01)												;�᫨ �� >= 4, ⮣�� ��� �⫨筮! 
	jl		_chk_instr_													;(3 - ��� ���४⭮� ࠡ��� ���裥�� (��� �� ��易⥫쭮), � +1 - ��� ������ �������樨); 

	call	get_free_r32
	
	add		al, 50h														;[PUSH REG32]
	stosb
	dec		ecx															;���४��㥬 ���-�� ��⠢���� ���� (��� ����� ����); 
	jmp		pop___r32													;esi - ᮤ�ন� ॣ����, � edx - �᫮ - ���-�� ���� ����� push & pop; ���室�� �� ������� [POP REG32]
;========================================[PUSH REG32]====================================================



;========================================[PUSH IMM8]=====================================================
;PUSH	55h	etc	(6Ah XXh); 
push_pop___imm8___r32:
	push	0Ah
	call	[ebx].rang_addr												;etc 

	mov		edx, eax													;� ��� ��� ��� ࠧ �������, ����� push imm8 pop reg32 - ����� ��祣� ����� �� ����; 
	add		eax, 03														;3 ���� - �� ࠧ��� push imm8 & pop reg32; 2 + 1 = 3 bytes; 
	cmp		ecx, eax
	jl		_chk_instr_

	call	get_num_free_r32											;etc 

	cmp		eax, (03 + 01)
	jl		_chk_instr_ 
	
	mov		al, 6Ah														;1 byte (opcode)
	stosb

	push	(256 - 2)													;������㥬 ���砩��� ��᫮ (��) � ��������� [2..255]; 
	call	[ebx].rang_addr

	inc		eax
	inc		eax
	stosb																;�����뢠�� � ����砥��� [PUSH IMM8]; 
																		;edx - �᫮ - ᪮�쪮 ���� ����襬 ����� push imm8 & pop reg32; 
	dec		ecx
	dec		ecx
	jmp		pop___r32													;���室�� �� ������� [POP REG32]; 
;========================================[PUSH IMM8]=====================================================



;========================================[POP REG32]=====================================================
;POP	EAX	etc	(58h)
;etc 
pop___r32:
	call	get_free_r32												;����砥� ᢮����� ॣ
;--------------------------------------------------------------------------------------------------------
	mov		esi, xm_xids_addr
	assume	esi: ptr XTG_INSTR_DATA_STRUCT
	test	esi, esi													;����� �� �� ������?
	je		_pr32_nxt_1_ 

	push	[esi].param_1												;�᫨ ��, ⮣�� ��� ��砫� ��࠭�� �� ���� � ���

	sub		[esi].instr_size, ecx										;� �� ���� ⥯��� ࠢ�� �筮�� ࠧ���� ᣥ��७���� push'a
	mov		[esi].param_1, eax											;��࠭塞 ����� ॣ�
	or		[esi].param_1, XTG_XIDS_CONSTR								;㪠�뢠��, �� ����� �㤥� �������� ����, �ਭ������騩 (�⮩) �������樨

	push	eax															;��࠭�� ���祭�� ��� ॣ�� � ���
	push	edx

	mov		edx, xm_struct2_addr
	assume	edx: ptr XTG_EXT_TRASH_GEN
	
	push	[edx].xlogic_struct_addr									;� �맮��� �㭪� ��ࢥન ������ ������ (���饩) �������樨
	push	ebx
	call	let_main

	pop		edx

	cmp		eax, 01														;�᫨ �� ������ ��室��, ⮣�� ��� �����
	pop		eax
	je		_pr32_nxt_0_

	pop		[esi].param_1

	mov		edi, [esi].instr_addr										;���� ���४��㥬 ���祭�� � ��室��
	mov		ecx, [esi].norb
	jmp		_chk_instr_

_pr32_nxt_0_:
	push	[esi].instr_addr											;��࠭� ���祭�� ������ �����, ⠪ ��� ��� ����� ���������� (⠪ ��� �� �㤥� ४����)
	push	[esi].instr_size
	push	[esi].flags 
	push	[esi].norb

	and		[esi].instr_addr, 0											;���뢠�� ���� � 0 - �� �㦭� ��� ⮣�, �⮡� ����� �� ᭮�� �� �஢�ਫ� ��� ��������� �� ������, � �஢��﫨 㦥 ���� ᣥ��७�� ���騥 �������

_pr32_nxt_1_:
	xchg	eax, esi													;esi = ����� ॣ����
;--------------------------------------------------------------------------------------------------------
	push	[ebx].tw_trash_addr											;��࠭塞 � �⥪� ���� ��������: ���� ��� ���쭥�襩 ����� ����, 
	push	[ebx].trash_size											;�᫮ - ᪮�쪮 ���� ���� ᣥ���஢���;
	push	[ebx].nobw													;(������ ���祭�� ���������� ᠬ�� xTG) - ᪮�쪮 ���� ॠ�쭮 ����ᠭ� (���-�� ����); 
	push	[ebx].fregs
	mov		[ebx].tw_trash_addr, edi									;� �⠢�� ���� ���祭�� - ⠪ ��� � �㤥� ४����;
	mov		[ebx].trash_size, edx	
	and		[ebx].nobw, 0
	
	mov		xm_tmp_reg0, esi											;����稬 ॣ, �⮡� �� �� � ��㣨� �������� (���� ����� ���� ���ࠢ��쭠� ������); 
	call	set_r32
	
	push	xm_struct2_addr
	push	ebx
	call	xtg_main													;४��ᨢ�� ��뢠�� XTG;

	mov		edx, [ebx].nobw												;����� � edx ��࠭塞 ���-�� ����ᠭ��� ���� (����); 
	add		edi, edx 													;���४��㥬 edi;
	pop		[ebx].fregs													;��࠭﫨 � ����⠭����� �� ���� - ���⮬� �� ���ॡ������� ��뢠�� unset_r32; 
	pop		[ebx].nobw													;����⠭�������� �� ��� ࠭�� ��࠭���� ���祭��; 
	pop		[ebx].trash_size
	pop		[ebx].tw_trash_addr

	xchg	eax, esi
	add		al, 58h														;� �����뢠�� [POP REG32]
	stosb
	dec		ecx															;���४��㥬 ���-�� ��⠢���� ���� ��� ����� ����;
	sub		ecx, edx 													;� ��� ⮦�;
;--------------------------------------------------------------------------------------------------------
	mov		esi, xm_xids_addr
	assume	esi: ptr XTG_INSTR_DATA_STRUCT
	test	esi, esi													;������ ����� ��?
	je		_pr32_nxt_2_
	pop		[esi].norb													;����⠭�������� ࠭�� ��࠭�� ���祭�� �����
	pop		[esi].flags
	pop		[esi].instr_size
	pop		[esi].instr_addr
	pop		[esi].param_1 
	and		[esi].instr_addr, 0											;᭮�� ����뢠�� � 0 - ��� �ࠢ��쭮�� ����஥���/�஢�ન ������
;--------------------------------------------------------------------------------------------------------
_pr32_nxt_2_:
	jmp		_chk_instr_													;�� ��室! 
;========================================[POP REG32]=====================================================

;================================[PUSH REG32/IMM8   POP REG32]===========================================



;=====================================[CMP REG32, REG32]=================================================
;CMP	EAX, ECX	etc	(3Bh)
cmp___r32__r32:
	push	(300h - 06)													;300h - 1 -> ���ᨬ��쭮� ���-�� ���� ����� ���ᮬ ���室� � ���ᮬ, �㤠 �㤥� ��릮�; 
	call	[ebx].rang_addr

	xchg	eax, edx

	push	edx
	call	[ebx].rang_addr

	and		edx, eax													;��䨫���㥬 �믠�襥 ��; 
	add		edx, 06														;�⮡� �� > 0; 
	mov		eax, edx
	add		eax, (2 + 6)												;2 (���� - ࠧ��� cmp___r32__r32) + 6 (���� - ���ᨬ���� ࠧ��� ���室� (near)); 
	cmp		ecx, eax													;�᫨ ���-�� ��⠢���� ���� ��� �����樨 ���� ����� ����室����� �᫠ ���� ��� �����樨 ������ �������樨, � �� ��室 (�����⨫ ����=)) 
	jl		_chk_instr_
	mov		al, 3Bh														;����� 
	stosb																;1 byte; 
	push	edx															;��࠭�� � �⥪� �᫮ (�� ���-�� ���� ����� ���ᮬ ���饣� ���室� � ���ᮬ, �㤠 �㤥� ���室); 

_cmp_r32_r32_mm114r32_1_:	
	call	modrm_mod11_for_r32											;������㥬 ���� modrm (2 byte); 

	mov		edx, xm_tmp_reg1
	cmp		edx, xm_tmp_reg2											;�᫨ ॣ����� ��������� (���ਬ�� cmp eax, eax etc), � ᭮�� ��६ ��㣨� ॣ����� - ࠧ�� (���ਬ��, cmp ecx, edx); 
	je		_cmp_r32_r32_mm114r32_1_ 
	stosb																;2 byte; 
	pop		edx 
	dec		ecx															;᪮�४��㥬 ������⢮ ��⠢���� ��� ����� ���� ���⥪��; 
	dec		ecx 
	cmp		edx, 80h													;� ��।��塞, �� ������� ������ ���室� ��룭�� (short or near); 
	jl		_jsdrel8_entry_ 
	jmp		_jndrel32_entry_
;=====================================[CMP REG32, REG32]=================================================	 
 


;=====================================[CMP REG32, IMM8]==================================================
;CMP	EAX, 1	etc	(83h 0FX)
;etc 
cmp___r32__imm8:
	push	(300h - 06)
	call	[ebx].rang_addr

	xchg	eax, edx

	push	edx
	call	[ebx].rang_addr

	and		edx, eax
	add		edx, 06														;for add/sub/etc reg32, imm32 etc; (�⮡� ॣ �筮 ᬮ� �ਭ��� ����� ��� ᥡ� ���祭�� (�� ��� ������)); 
	mov		eax, edx 
	add		eax, (3 + 6)												;3 bytes (ࠧ��� cmp___r32__imm8) + 6 bytes (���ᨬ���� ࠧ��� ���饣� �᫮����� ���室� (near)); 
	cmp		ecx, eax
	jl		_chk_instr_ 
	mov		al, 83h
	stosb																;write 1 byte
	push	edx

	call	get_free_r32												;get random free reg;

	add		al, 0F8h
	stosb																;write 2 byte

_cmp_r32_imm8_grn_:
	push	(256 - 1)
	call	[ebx].rang_addr												;get random number [1..255]; 

	inc		eax 														;imm8 > 0; 
	stosb																;write 3 byte; 
	pop		edx
	sub		ecx, 03
	cmp		edx, 80h													;next generate jxx_short or jxx_near? 
	jl		_jsdrel8_entry_
	jmp		_jndrel32_entry_
;=====================================[CMP REG32, IMM8]==================================================	 
	


;=====================================[CMP REG32, IMM32]=================================================
;[CMP REG32, IMM32] -> REG != EAX; 
;CMP	ECX, 12345678h	etc	(81h 0FXh XXXXXXXXh) 
cmp___r32__imm32:

OFS_CMP_81FXh		equ		01
OFS_CMP_EAX_3Dh		equ		01

	push	(300h - 06)														;����砥� �� � [00h..2FFh]
	call	[ebx].rang_addr

	xchg	eax, edx													;��࠭塞 � edx

	push	edx															;�� � [00h..edx]
	call	[ebx].rang_addr

	and		edx, eax													;�� ⨯� ⠪�� ���� ��᪠
	add		edx, 06														;+6 -> ⠪ ��� �� ��᫥ cmp �ࠧ� �㤥� ������� jxx, � ����� ���ᮬ jxx � ���ᮬ, �㤠 �� ��룭��, ������ ���� ��� �� ���� ���� - ���� �㩭� �㤥�; 
	mov		eax, edx													;EAX = EDX
	add		eax, (6 + 6)												;EAX += 12 -> 6 ���� (ࠧ��� ������� cmp) + 6 ���� (ࠧ��� ���ᨬ��쭮�� ���室� (near)); 
	cmp		ecx, eax													;�᫨ ���-�� ��⠢���� ���� ��� ����� ���� ����� �㦭��� ��� ���祭�� ��� �����樨 ������ �������樨, � �� ��室; 
	jl		_chk_instr_

	push	(OFS_CMP_81FXh + OFS_CMP_EAX_3Dh)							;���� ��砩�� ��ࠧ�� ��।���� (��� ����⨪�), ����� ������ cmp �㤥� �������: c ECX/EDX/EBX/ESI/EDI ��� � EAX? (��� EAX ���� ��⨬���஢����� ᯥ�. ����� ������ ������� - � ᮮ�-�� ��㣮� �����); 
	call	[ebx].rang_addr

	cmp		eax, OFS_CMP_EAX_3Dh										;[CMP EAX, XXXXXXXXh]
	jl		cmp___eax__imm32
	push	edx															;��࠭塞 EDX - ᪮�쪮 ���� ᣥ���஢��� ����� ���ᮬ jxx � ���ᮬ, �㤠 �㤥� ��릮�; 
_cmp_81FXh_:
	mov		al, 81h														;1 byte (opcode)
	stosb

_cmp_r32_imm32_gfr32_:	
	call	get_free_r32												;����稬 ��砩�� ॣ

	test	eax, eax													;�᫨ �믠� EAX, � ᭮�� �㤥� �롨���;
	je		_cmp_r32_imm32_gfr32_
	add		al, 0F8h													;���� ᣥ��ਬ 2 ���� (modrm); 
	stosb

_cmp_r32_imm32_grn_:	
	push	-01															;����� ᣥ��ਬ �� [0x101..0xFFFFFFFF]; 
	call	[ebx].rang_addr

	cmp		eax,  101h 
	jb		_cmp_r32_imm32_grn_
	stosd																;����襬 ᫥���騥 4 ���� (imm32 > 100h); 
_cmp_r32_imm32_gni_:
	pop		edx															;����⠭�������� EDX;
	sub		ecx, 06														;���४��㥬 ���-�� ��⠢���� ���� ��� ����� ����; 
	cmp		edx, 80h													;next generate jxx_short or jxx_near? 
	jl		_jsdrel8_entry_
	jmp		_jndrel32_entry_

;========================================================================================================
;[CMP EAX, XXXXXXXXh]
;CMP	EAX, 12345678h	etc	(3Dh); 
cmp___eax__imm32:
	cmp		ecx, 05
	jl		_chk_instr_
	mov		al, 3Dh														;1 byte (opcode);
	stosb
	push	edx															;etc
	inc		ecx															;���४��㥬 ���-�� ��⠢���� ���� ��� ����� ����; 
	jmp		_cmp_r32_imm32_grn_
;=====================================[CMP REG32, IMM32]=================================================

	

;================================[TEST REG32/REG8, REG32/REG8]===========================================
;TEST	EAX, EAX	etc	(85h)
;TEST	CH, CH		etc	(84h)  
;etc 
test___r32_r8__r32_r8:

OFS_TEST_85h		equ		25
OFS_TEST_84h		equ		02

;OFS_TJSDREL8		equ		30
;OFS_TJNDREL32		equ		15
	push	(300h - 06) ;7Fh											;����稬 �� � [00h..2FFh] -> �� max ���祭�� ��� jxx_near; 
	call	[ebx].rang_addr

	xchg	eax, edx													;��࠭塞 �� � EDX; 

	push	edx
	call	[ebx].rang_addr

	;and	edx, eax

	;push	edx
	;call	[ebx].rang_addr
																		;��� ⨯� ���� ��᪠
	and		edx, eax
	add		edx, 06														;etc
	mov		eax, edx 
	add		eax, (02 + 06)												;2 bytes (ࠧ��� test) + 6 ���� (���ᨬ���� ࠧ��� jxx (�� near)); 
	cmp		ecx, eax
	jl		_chk_instr_ 
	push	edx															;etc

	push	(OFS_TEST_85h + OFS_TEST_84h)
	call	[ebx].rang_addr

	cmp		eax, OFS_TEST_84h
	jl		_84h_
_85h_:
	mov		al, 85h														;[TEST REG32, REG32]
	jmp		_84h_85h_
_84h_:
	mov		al, 84h														;[TEST REG8, REG8]
_84h_85h_:
	stosb

	call	get_free_r32												;get_rnd_r

	mov		edx, eax													;� ��� ��� ������ ⠪, �⮡� ॣ� �뫨 ���������, ⠪ ��� test (����) �ᥣ�� �ਬ������ ������ ��� �ࠢ����� ������ � ⮣� �� ॣ�, ���ਬ��, test eax, eax etc; 
	shl		eax, 03
	add		al, 0C0h
	add		eax, edx
	stosb
	pop		edx
	dec		ecx
	dec		ecx	
	cmp		edx, 80h													;etc 
	jl		_jsdrel8_entry_ 											;� ����� ��룠�� �� ������� jxx (SHORT or NEAR); 
	jmp		_jndrel32_entry_ 
;================================[TEST REG32/REG8, REG32/REG8]===========================================



;====================================[JXX_SHORT_DOWN REL8]===============================================
;JL		IMM8	etc	(7Ch)
;JE		IMM8	etc	(74h)
;JNZ	IMM8	etc	(75h) 
;etc
jxx_short_down___rel8:

OFS_JXX_74h			equ		35
OFS_JXX_75h			equ		25
OFS_JXX_7Xh			equ		01
	
	push	7Fh															;������㥬 �� [01h..7Fh]
	call	[ebx].rang_addr

	inc		eax
	mov		edx, eax													;��࠭塞 �� �� � edx; 
	inc		eax															;EAX += 2 -> 2 ���� - �� ࠧ��� ������� jxx;
	inc		eax
	cmp		ecx, eax													;etc 
	jl		_chk_instr_

_jsdrel8_entry_:
;--------------------------------------------------------------------------------------------------------
	mov		esi, xm_xids_addr
	assume	esi: ptr XTG_INSTR_DATA_STRUCT
	test	esi, esi													;����� �� �� ������?
	je		_jsdr8l_nxt_1_ 

	push	[esi].param_1												;�᫨ ��, ⮣�� ��� ��砫� ��࠭�� �� ���� � ���

	sub		[esi].instr_size, ecx										;� �� ���� ⥯��� ࠢ�� �筮�� ࠧ���� ᣥ��७��� �������
	or		[esi].param_1, XTG_XIDS_CONSTR								;㪠�뢠��, �� ����� �㤥� �������� ����, �ਭ������騩 (�⮩) �������樨

	push	edx

	mov		edx, xm_struct2_addr
	assume	edx: ptr XTG_EXT_TRASH_GEN
	
	push	[edx].xlogic_struct_addr									;� �맮��� �㭪� ��ࢥન ������ ������ (���饩) �������樨
	push	ebx
	call	let_main

	pop		edx

	cmp		eax, 01														;�᫨ �� ������ ��室��, ⮣�� ��� �����
	je		_jsdr8l_nxt_0_

	pop		[esi].param_1

	mov		edi, [esi].instr_addr										;���� ���४��㥬 ���祭�� � ��室��
	mov		ecx, [esi].norb
	jmp		_chk_instr_

_jsdr8l_nxt_0_:
	push	[esi].instr_addr											;��࠭� ���祭�� ������ �����, ⠪ ��� ��� ����� ���������� (⠪ ��� �� �㤥� ४����)
	push	[esi].instr_size
	push	[esi].flags 
	push	[esi].norb

	and		[esi].instr_addr, 0											;���뢠�� ���� � 0 - �� �㦭� ��� ⮣�, �⮡� ����� �� ᭮�� �� �஢�ਫ� ��� ��������� �� ������, � �஢��﫨 㦥 ���� ᣥ��७�� ���騥 �������

_jsdr8l_nxt_1_:
;-------------------------------------------------------------------------------------------------------- 
	push	[ebx].tw_trash_addr											;��࠭�� � ��� �㦭� ���� ��������;
	push	[ebx].trash_size
	push	[ebx].nobw
	push	edi															;� ⥪�騩 ���� ��� ����� ����
	inc		edi															;��९�룭�� �� 2 ���� ����� - �� ���� ��� 2-� ���� ���� ����� ����襬 jxx; 
	inc		edi
	mov		[ebx].tw_trash_addr, edi
	mov		[ebx].trash_size, edx	
	and		[ebx].nobw, 0
	
	push	xm_struct2_addr
	push	ebx
	call	xtg_main													;��뢠�� ���裥� ४��ᨢ��

	pop		edi															;����⠭�������� �� ��� ࠭�� ��࠭���� ���祭��;
	mov		edx, [ebx].nobw												;� EDX - �᫮ ॠ�쭮 ����ᠭ��� (��᫥ ४��ᨨ) ���� (����); 
	pop		[ebx].nobw
	pop		[ebx].trash_size
	pop		[ebx].tw_trash_addr
	;test	edx, edx
	;je		_chk_instr_

 	push	(OFS_JXX_74h + OFS_JXX_75h + OFS_JXX_7Xh)					;�����, � ����, "��砩��" ��।����, ����� jxx �㤥� �������; 
 	call	[ebx].rang_addr

 	cmp		eax, OFS_JXX_7Xh
 	jl		_7Xh_
 	cmp		eax, (OFS_JXX_7Xh + OFS_JXX_75h)
 	jge		_74h_
_75h_:																	;[JNE REL8]
	mov		al, 75h
	jmp		_7Xh_75h_74h_
_74h_:																	;[JE REL8]
	mov		al, 74h
	jmp		_7Xh_75h_74h_

_7Xh_:																	;� ��� �롥६ ��砩�� ���� �� 16 ��������� jxx; 
	push	16
	call	[ebx].rang_addr

	add		al, 70h
_7Xh_75h_74h_:
	stosb																;1 byte (opcode)
	xchg	eax, edx
	stosb																;2 byte (imm8) 
	dec		ecx
	dec		ecx
	add		edi, eax													;᪮�४��㥬 ���� ��� ���쭥�襩 ����� ����
	sub		ecx, eax													;᪮�४��㥬 ����稪; 
;--------------------------------------------------------------------------------------------------------
	mov		esi, xm_xids_addr
	assume	esi: ptr XTG_INSTR_DATA_STRUCT
	test	esi, esi													;������ ����� ��?
	je		_jsdr8l_nxt_2_
	pop		[esi].norb													;����⠭�������� ࠭�� ��࠭�� ���祭�� �����
	pop		[esi].flags
	pop		[esi].instr_size
	pop		[esi].instr_addr
	pop		[esi].param_1 

	test	eax, eax													;�᫨ �� �뫮 ᣥ���஢��� �� ����� ������� ����� ���室�� � ���ᮬ, �㤠 ��룠�� - ⮣�� �⪠�뢠�� ��� ��������� � ��룠�� �� ������� ��㣨� ������; 
	jne		_jsdr8l_nxt_3_
	mov		edi, [esi].instr_addr
	mov		ecx, [esi].norb
	;jmp		_chk_instr_

_jsdr8l_nxt_3_:
	and		[esi].instr_addr, 0											;᭮�� ���뢠�� � 0 - ��� �ࠢ��쭮�� ����஥���/�஢�ન ������
;--------------------------------------------------------------------------------------------------------
_jsdr8l_nxt_2_:
	jmp		_chk_instr_
;====================================[JXX_SHORT_DOWN REL8]===============================================

 

;====================================[JXX_NEAR_DOWN REL32]===============================================
;JL		REL32	etc	(0Fh 8Ch)
;JNE	REL32	etc	(0Fh 85h)
;JE		REL32	etc	(0Fh 84h)
;etc 
jxx_near_down___rel32:

OFS_JXX_0F84h		equ		35
OFS_JXX_0F85h		equ		25
OFS_JXX_0F8Xh		equ		01

	push	300h
	call	[ebx].rang_addr

	cmp		eax, 81h													;�� [81h..2FFh]
	jl		jxx_near_down___rel32
	mov		edx, eax
	add		eax, 06														;6 bytes (size of jxx_near); 
	cmp		ecx, eax													;etc 
	jl		_chk_instr_

_jndrel32_entry_:
;--------------------------------------------------------------------------------------------------------
	mov		esi, xm_xids_addr
	assume	esi: ptr XTG_INSTR_DATA_STRUCT
	test	esi, esi													;����� �� �� ������?
	je		_jsdr32l_nxt_1_ 

	push	[esi].param_1												;�᫨ ��, ⮣�� ��� ��砫� ��࠭�� �� ���� � ���

	sub		[esi].instr_size, ecx										;� �� ���� ⥯��� ࠢ�� �筮�� ࠧ���� ᣥ��७��� �������; 
	or		[esi].param_1, XTG_XIDS_CONSTR								;㪠�뢠��, �� ����� �㤥� �������� ����, �ਭ������騩 (�⮩) �������樨

	push	edx

	mov		edx, xm_struct2_addr
	assume	edx: ptr XTG_EXT_TRASH_GEN
	
	push	[edx].xlogic_struct_addr									;� �맮��� �㭪� ��ࢥન ������ ������ (���饩) �������樨
	push	ebx
	call	let_main

	pop		edx

	cmp		eax, 01														;�᫨ �� ������ ��室��, ⮣�� ��� �����
	je		_jsdr32l_nxt_0_

	pop		[esi].param_1

	mov		edi, [esi].instr_addr										;���� ���४��㥬 ���祭�� � ��室��
	mov		ecx, [esi].norb
	jmp		_chk_instr_

_jsdr32l_nxt_0_:
	push	[esi].instr_addr											;��࠭� ���祭�� ������ �����, ⠪ ��� ��� ����� ���������� (⠪ ��� �� �㤥� ४����)
	push	[esi].instr_size
	push	[esi].flags 
	push	[esi].norb

	and		[esi].instr_addr, 0											;���뢠�� ���� � 0 - �� �㦭� ��� ⮣�, �⮡� ����� �� ᭮�� �� �஢�ਫ� ��� ��������� �� ������, � �஢��﫨 㦥 ���� ᣥ��७�� ���騥 �������
;--------------------------------------------------------------------------------------------------------
_jsdr32l_nxt_1_:

	push	[ebx].tw_trash_addr
	push	[ebx].trash_size
	push	[ebx].nobw
	push	edi
	add		edi, 06														;etc (ᬮ�� � ����=)! 
	mov		[ebx].tw_trash_addr, edi
	mov		[ebx].trash_size, edx	
	and		[ebx].nobw, 0
	
	push	xm_struct2_addr
	push	ebx
	call	xtg_main

	pop		edi
	mov		edx, [ebx].nobw
	pop		[ebx].nobw
	pop		[ebx].trash_size
	pop		[ebx].tw_trash_addr
	;test	edx, edx
	;je		_chk_instr_

	mov		al, 0Fh														;1 byte (1-st opcode)
	stosb

	push	(OFS_JXX_0F84h + OFS_JXX_0F85h + OFS_JXX_0F8Xh)
	call	[ebx].rang_addr

	cmp		eax, OFS_JXX_0F8Xh
	jl		_0F8Xh_
	cmp		eax, (OFS_JXX_0F8Xh + OFS_JXX_0F85h)
	jge		_0F84h_
_0F85h_:																;[JNE REL32]
	mov		al, 85h
	jmp		_0F8Xh_0F85h_0F84h_
_0F84h_:																;[JE REL32]
	mov		al, 84h
	jmp		_0F8Xh_0F85h_0F84h_

_0F8Xh_:																;other (16 variants)
	push	16
	call	[ebx].rang_addr

	add		al, 80h
_0F8Xh_0F85h_0F84h_:
	stosb																;2 byte (2-nd opcode)
	xchg	eax, edx
	stosd																;+4 bytes (rel32);
	sub		ecx, 06														;���४��㥬; 
	sub		ecx, eax
	add		edi, eax
;--------------------------------------------------------------------------------------------------------
	mov		esi, xm_xids_addr
	assume	esi: ptr XTG_INSTR_DATA_STRUCT
	test	esi, esi													;������ ����� ��?
	je		_jsdr32l_nxt_2_
	pop		[esi].norb													;����⠭�������� ࠭�� ��࠭�� ���祭�� �����
	pop		[esi].flags
	pop		[esi].instr_size
	pop		[esi].instr_addr
	pop		[esi].param_1 

	test	eax, eax													;�᫨ �� ����� ������� �� �뫮 ᣥ��७� ����� �������� ���室� � ���ᮬ, �㤠 �㤥� ��릮� - ⮣�� �⪠�뢠�� ������ ��������� � ���室�� �� ������� ��㣨� ������; 
	jne		_jsdr32l_nxt_3_
	mov		edi, [esi].instr_addr
	mov		ecx, [esi].norb
	;jmp		_chk_instr_

_jsdr32l_nxt_3_:
	and		[esi].instr_addr, 0											;᭮�� ���뢠�� � 0 - ��� �ࠢ��쭮�� ����஥���/�஢�ન ������
;--------------------------------------------------------------------------------------------------------
_jsdr32l_nxt_2_:

	jmp		_chk_instr_ 
;====================================[JXX_NEAR_DOWN REL32]===============================================



;=====================================[JXX_UP REL8/REL32]================================================
;1) init_reg1															;push imm8  pop reg32_1; mov reg32_1, imm32; etc
;	trash1
;	trash2
;	chg_reg1															;inc/dec reg32_1; add/sub reg32_1, imm8; etc
;	trash3
;	cmp_reg1, value														;cmp reg32_1, imm8; cmp reg32_1, imm32; etc 
;	jxx trash2															;jl/jle/jg/jge; 
;
;2) init_reg1
;	trash1
;	trash2
;	dec reg1
;	jnz trash2
;
;3) trash1
;	trash2
;	chg_reg1
;	trash3
;	cmp_reg1, reg2														;cmp reg32_1, reg32_2; 
;	je trash2
;  
;4)	etc (ࠧ�� �������, ॣ�, � �.�., �������� �������� 横��, jxx_short, jxx_near);  
;
jxx_up___rel8___rel32:
	call	get_num_free_r32											;���砫� �맮��� �㭪� ����祭�� ������⢠ ᢮������ reg32; 

	cmp		eax, (03 + 02)												;03 - �� �������쭮� ���-�� ᢮������ ॣ���஢, �⮡� ���裥� ����쭮 ࠡ�⠫ (०�� "ॠ����筮���"); 
	jl		_chk_instr_													;02 - �� �������쭮� ���-�� ᢮������ ॣ�� ��� ������ �������樨 - ⠪ ��� ��� ��� ����� ���ॡ������� 1 ��� 2 ॣ�; 
																		;�᫨ ���-�� ᢮������ ॣ�� < (03 + 02 = 05), ⮣�� �� ��室; 2FEh + 2 = 300h - ���㣫���� ��x ࠧ��� trash2; 
	push	(2FEh - 05 - 03 - 06 - 06)									;05 - ���ᨬ���� ࠧ��� ������� ���樠����樨 ����稪� (ॣ�) - �� ������� mov reg32, imm32; 
	call	[ebx].rang_addr												;03 - -||- ������� ��������� ����稪� - �� add/sub reg32, imm8;
																		;06 - -||- ������� �ࠢ����� - �� cmp reg32, imm32 (reg32 != EAX);
																		;06 - ���ᨬ���� ࠧ��� �᫮����� ���室� (jxx_near = 6 bytes); 
	xchg	eax, edx

	push	edx
	call	[ebx].rang_addr

	and		eax, edx													;�ਬ��塞 ᯥ�. ���� ��� ����祭�� "����襭����" ���祭��; 
	inc		eax															;rel > 1; �� ����砥� � ��릮� � ������� ���樠����樨, ��������� ����窠, �ࠢ����� � �.�., � ⠪�� ����� �������; 
	inc		eax
	mov		xm_tmp_reg3, eax											;ࠧ��� trash2 ��࠭�� � xm_tmp_reg3; 
	mov		edx, (2FEh - 05 - 03 - 06 - 06 + 01)
	sub		edx, eax
	xchg	eax, esi													;esi = eax; 

	push	edx
	call	[ebx].rang_addr
	
	push	eax
	call	[ebx].rang_addr

	and		eax, edx
	mov		xm_tmp_reg4, eax											;ࠧ��� ���� trash3 ��࠭�� � xm_tmp_reg4; 
	add		esi, eax													;esi += eax;

	push	50h
	call	[ebx].rang_addr

	mov		xm_tmp_reg5, eax											;ࠧ��� ���� trash1 [0..0x50 - 0x01] ��࠭�� � xm_tmp_reg5; 
	add		esi, eax													;esi += eax
	add		esi, (05 + 03 + 06 + 06)									;������� ⠪�� � esi max ࠧ���� ������ ���樠����樨 ����稪� etc; 
	cmp		ecx, esi													;�᫨ ���-�� ��⠢���� ��� ����� ���� ���� ����� ���-�� �㦭�� ���� ��� �����樨 ������ �������樨, � �멤�� ���� ���; 
	jl		_chk_instr_

	push	[ebx].tw_trash_addr											;��࠭�� � �⥪� �㦭� ��� ���� ��������, ⠪ ��� ��� ���� �������� (��� ४��ᨢ���� �맮�� ���裥��); 
	push	[ebx].trash_size
	push	[ebx].fregs													;��࠭�� � �⥪� ������ ���� - ⮣�� ��� �� �㦭� ᫥���� �� xm_tmp_reg0, � ��᫥ �맮�� set_r32 ��뢠�� unset_r32; 
	push	[ebx].xmask1
	push	[ebx].xmask2
	push	[ebx].nobw
																		;!!!!! �������� �������� �஢��� �� ४����! �⮡� �� ��������� ���; 
																		;��� (� �������樨 �����樨 横��) �⪫�砥� ������� ������襪;
																		;���� ����� ���� ��横������� � �.�. �㯭�. 
																		;���ਬ��, � ��� ᣥ��ਫ�� 横�, � ���஬ ����稪 - �� ॣ edx. � � 横�� ᣥ���஢���� �맮� ������. 
																		;��᫥ �맮�� ����� ���� ⠪, �� ॣ edx �ਬ�� �����-� ��㣮� ���祭�� - ����砥��� �� ����稬 ���祭�� ����稪� ��� 横�� - � ����� 横� ����� ���� ��᪮��筭� � �.�.;
																		;��� ⠪; 
	cmp		[ebx].fmode, XTG_REALISTIC									;����� ०�� ᥩ�� ����?
	jne		_jsu_rel8_chk_flag_winapi_m_
_jsu_rel8_chk_flag_winapi_r_:											;��� ०���� ��᪨ � ॠ���⨪� ࠧ�� 䫠��, 㪠�뢠�騥, �� ���� ������� ��-������ �㭪�; 
	test	[ebx].xmask1, XTG_REALISTIC_WINAPI
	je		_jsu_rel8_xmask_ok_
	xor		[ebx].xmask1, XTG_REALISTIC_WINAPI							;�⪫�砥�
	jmp		_jsu_rel8_xmask_ok_

_jsu_rel8_chk_flag_winapi_m_:
	test	[ebx].xmask2, XTG_MASK_WINAPI
	je		_jsu_rel8_xmask_ok_
	xor		[ebx].xmask2, XTG_MASK_WINAPI								;etc 

_jsu_rel8_xmask_ok_:

	call	get_free_r32												;���� ����稬 ᢮����� ॣ���� - �� ��� ����稪 � 横��; 
	
	mov		xm_tmp_reg1, eax											;��࠭�� ��� � xm_tmp_reg1
	mov		xm_tmp_reg0, eax											;� ⠪�� ����稬 ���, �⮡� �� �� � ��㣨� �������� (���� ����� ���� ��横�������); 
	call	set_r32
	;push	xm_tmp_reg0 												;������ ������� �������⥭�, ⠪ ��� �� ��࠭��� [ebx].fregs � ���, ���⮬� ��� �� ���ॡ���� ������ xm_tmp_reg0 � ��뢠�� unset_r32; 

	push	02
	call	[ebx].rang_addr												;����� ��砩�� ��।����, �㤥� �� �� ������� ������� ���樠����樨 ����稪� ��� �� ������稬 2-�� ॣ����? 
	 
	test	eax, eax
	je		_jsu_rel8_init_cnt_

_jsu_rel8_init_reg2_:													;��� ������砥� 2-�� ॣ���� (�� �㤥� �㦥� ��� ������� cmp reg1, reg2); 
	call	get_free_r32
	mov		xm_tmp_reg2, eax
	mov		xm_tmp_reg0, eax
	call	set_r32
	
	jmp		_jsu_rel8_trash1_
_jsu_rel8_init_cnt_:													;� ��� ����ਬ ������� ���樠����樨 ����稪� (aka ॣ���� aka reg1 etc); ���ਬ�� push imm8  pop reg1 etc; 
	call	init_cnt_for_cycle
	mov		xm_tmp_reg2, -01											;xm_tmp_reg2 = -1 -> ⥬ ᠬ� �� 㪠�뢠��, �� 2-�� ॣ ��� �� �㦥�; 
	xchg	eax, edx													;edx = eax = �᫮ - �� ���祭��, ���஥ �뫮 ��᢮��� ����稪� (���樠������); 

_jsu_rel8_trash1_:	
;--------------------------------------------------------------------------------------------------------
	cmp		xm_xids_addr, 0												;����� �� �� ������? 
	je		_vju_nxt_1_ 
	
	push	esi
	mov		esi, xm_xids_addr
	assume	esi: ptr XTG_INSTR_DATA_STRUCT	
	push	ecx
	push	edx
	push	[esi].param_1												;�᫨ ��, ⮣�� ��� ��砫� ��࠭�� �� ���� � ���
	
	mov		eax, xm_tmp_reg1
	mov		[esi].param_1, eax											;�����뢠�� � ����� ॣ�1 ��� �஢�ન
	mov		edx, xm_struct2_addr
	assume	edx: ptr XTG_EXT_TRASH_GEN
	
	push	[edx].xlogic_struct_addr									;� �맮��� �㭪� ��0��ન ������ ������ (���饩) �������樨
	push	ebx
	call	let_main

	cmp		eax, 01														;�᫨ �� �������� �������� ᢮� �஢��� ( �� ��ࢮ� ॣ� ), ⮣�� ��९�루����
	jne		_vju_nxt_2_

	mov		ecx, xm_tmp_reg2
	inc		ecx
	je		_vju_nxt_2_
	dec		ecx															;�᫨ ������ �������� �� � ॣ2, 

	mov		[esi].param_1, ecx											;⮣�� �஢�ਬ � ��� ⮦�

	push	[edx].xlogic_struct_addr									;� �맮��� �㭪� ��ࢥન ������ ������ (���饩) �������樨
	push	ebx
	call	let_main

_vju_nxt_2_:
	pop		[esi].param_1
	pop		edx
	pop		ecx
	cmp		eax, 01														;�᫨ �� ������ ��室��, ⮣�� ��� �����
	je		_vju_nxt_3_

	mov		edi, [esi].instr_addr										;���� ���४��㥬 ���祭�� � ��室��
	mov		ecx, [esi].norb 
	pop		esi
	jmp		_vju_nxt_4_													;���室�� �� ����⠭������� ��㣨� ����� ��㣮� ������ etc; 

_vju_nxt_3_:
	pop		eax 
	push	[esi].param_1 
	or		[esi].param_1, XTG_XIDS_CONSTR								;㪠�뢠��, �� ����� �㤥� �������� ����, �ਭ������騩 (�⮩) �������樨
	and		[esi].instr_addr, 0											;���뢠�� ���� � 0 - �� �㦭� ��� ⮣�, �⮡� ����� �� ᭮�� �� �஢�ਫ� ��� ��������� �� ������, � �஢��﫨 㦥 ���� ᣥ��७�� ���騥 �������
	xchg	eax, esi													;esi = eax; 
;--------------------------------------------------------------------------------------------------------
_vju_nxt_1_:
	
	mov		[ebx].tw_trash_addr, edi									;���� ��� ����� ����;
	mov		eax, xm_tmp_reg5											;eax = ᪮�쪮 ���� ᣥ����� (trash1); 
	mov		[ebx].trash_size, eax	
	and		[ebx].nobw, 0												;����塞 - ������ ���� �����뢠�� �� ��室�, ᪮�쪮 ॠ�쭮 ���� �뫮 ����ᠭ� (���-�� ���⮢); 
	
	push	xm_struct2_addr
	push	ebx
	call	xtg_main													;����ਬ ���� ���� (trash1) (४����); 

	add		edi, [ebx].nobw												;���४��㥬 edi - ⥯��� � ��� ���� �� trash1, ��� ��� � �㦭�;
	sub		ecx, [ebx].nobw												;���४��㥬 ecx - ���-�� ��⠢���� ���� ��� ����� ���쭥�襣� ����; 

_jsu_rel8_trash2_:
;--------------------------------------------------------------------------------------------------------
	push	esi
	mov		esi, xm_xids_addr 
	assume	esi: ptr XTG_INSTR_DATA_STRUCT	
	test	esi, esi
	je		_vju_t2_nxt_
	and		[esi].instr_addr, 0											;��। ������ ४��ᨥ� ���뢠�� ������ ���� � 0, �⮡� ����� �஢��﫨�� �� ������ ���� �������, � �� ᭮�� �� �������� � �.�.; 
_vju_t2_nxt_:
	pop		esi
;--------------------------------------------------------------------------------------------------------

	mov		[ebx].tw_trash_addr, edi									;etc
	mov		eax, xm_tmp_reg3											;trash2
	mov		[ebx].trash_size, eax
	and		[ebx].nobw, 0

	push	xm_struct2_addr
	push	ebx
	call	xtg_main

	mov		xm_tmp_reg3, edi											;⥯��� ��६����� xm_tmp_reg3 ᮤ�ন� ���� ��砫� trash2 (��� � � ���쭥�襬 �㤥� ��� ���室 � 横��); 
	add		edi, [ebx].nobw
	sub		ecx, [ebx].nobw 

	call	chg_cnt_for_cycle											;⥯��� ������㥬 ������� ��������� ����稪�, ���ਬ��, inc/dec reg1 ��� add/sub reg1, imm8 etc; 
	mov		xm_tmp_reg5, eax											;xm_tmp_reg5 ⥯��� ᮤ�ন� ���� ������� ��������� ����稪�;
	xchg	eax, esi													;��࠭�� ��� ���� � esi; 

	cmp		byte ptr [esi], 48h											;�����, �஢��塞, �뫠 ᣥ���஢��� ������� inc reg1?
	jb		_jsu_rel8_nxt_1_
	cmp		byte ptr [esi], 4Fh											;��� dec reg1?
	jbe		_jsu_rel8_nxt_2_
	cmp		byte ptr [esi + 01], 0C7h									;��� add reg1, imm8 ��� sub reg1, imm8?
	ja		_jsu_rel8_nxt_3_
_jsu_rel8_nxt_1_:														;�᫨ �뫠 ᣥ���஢��� ������� 㢥��祭�� ����稪� (inc ��� add etc), ⮣�� ���㫨� esi; 
	xor		esi, esi
	jmp		_jsu_rel8_nxt_3_											;� ��룭�� �� ������� ������� �ࠢ�����; 

_jsu_rel8_nxt_2_:														;�᫨ �� �뫠 ᣥ���஢��� ������� dec reg1, 
	push	02															;⮣�� ��砩�� ��।����, �㤥� �� �����஢����� ������� �ࠢ����� ��� ��� (� �������� dec reg1 ����� � ⠪ � ⠪, ����� etc); 
	call	[ebx].rang_addr

	test	eax, eax
	je		_jsu_rel8_nxt_4_

_jsu_rel8_nxt_3_:
_jsu_rel8_trash3_:
;--------------------------------------------------------------------------------------------------------
	push	esi
	mov		esi, xm_xids_addr
	assume	esi: ptr XTG_INSTR_DATA_STRUCT	
	test	esi, esi
	je		_vju_t3_nxt_
	and		[esi].instr_addr, 0
_vju_t3_nxt_:
	pop		esi
;--------------------------------------------------------------------------------------------------------

	mov		[ebx].tw_trash_addr, edi
	mov		eax, xm_tmp_reg4											;trash3
	mov		[ebx].trash_size, eax
	and		[ebx].nobw, 0

	push	xm_struct2_addr
	push	ebx
	call	xtg_main

	add		edi, [ebx].nobw
	sub		ecx, [ebx].nobw 
	
	xchg	eax, edx													;eax - ��砫쭮� ���祭�� ����稪�;
	xchg	edx, esi													;edx - 0 - �᫨ ������� 㢥��祭�� ����稪�, � ���� (edx != 0), �᫨ ������� 㬥��襭�� ����稪� �뫠 ᮧ����; 
	call	cmp_for_cycle												;������㥬 ������� �ࠢ����� ����稪� � ��㣨� ॣ�� ��� ���祭��� (� ���쭥�襬 ����� �� � 祬-�); 
	or		xm_tmp_reg4, -01											;㪠�뢠��, �� ������� �ࠢ����� �뫠 ᣥ���஢���; 

_jsu_rel8_nxt_4_:
	cmp		xm_tmp_reg2, -01											;��⥬ �஢��塞, �뫠 �� ᣥ���஢��� ������� ���樠����樨 ����稪� ��� �� �� ������⢮��� 2-�� ॣ?
	je		_jsu_rel8_nxt_5_
	
	;call	unset_r32													;�᫨ 2-�� ॣ, ⮣�� �� ��� ࠧ��稬...; ⥯��� �� �� �㦭� ��뢠��; 
	
	mov		al, 74h														;� � ��� �㤥� �᫮��� ���室 je; 
	jmp		_jsu_rel8_nxt_9_
_jsu_rel8_nxt_5_:														;�᫨ �� ������� ���樠����樨 ����稪� �뫠 ᮧ����, ⮣�� 
	mov		eax, xm_tmp_reg5											;�� ��।����, �� �� ������� ��������� ����稪� �뫠 ᮧ����?
	cmp		byte ptr [eax], 48h
	jb		_jsu_rel8_nxt_7_
	cmp		byte ptr [eax], 4Fh
	ja		_jsu_rel8_nxt_7_
	inc		xm_tmp_reg4													;�᫨ �� �� dec reg1, ⮣�� �஢�ਬ, �뫠 �� �� ᣥ���஢��� ������� �ࠢ�����?
	jne		_jsu_rel8_nxt_6_											;�᫨ ���, ⮣�� � ��� �㤥� ���室 jne; 
	
	push	02															;�᫨ �� ������� �ࠢ����� �뫠 ᮧ����, ⮣�� �롥६, ����� �� ��ਠ�⮢ ���室�� ᮧ�����: jne/jxx? 
	call	[ebx].rang_addr

	test	eax, eax
	je		_jsu_rel8_nxt_7_
_jsu_rel8_nxt_6_:														;jne 
	mov		al, 75h
	jmp		_jsu_rel8_nxt_9_
	
_jsu_rel8_nxt_7_:
	xchg	edx, esi													;esi = 0 ��� ��� ��㣮�� ���; 
	
	push	02
	call	[ebx].rang_addr
	
	xchg	eax, edx													;edx = 0 ��� 1; 
	test	esi, esi													;����� ᬮ�ਬ, ����� ������� ��������� ����稪� �뫠 ᣥ���஢���: 㢥��祭�� ��� 㬥��襭��? 
	je		_jsu_rel8_nxt_8_
	shl		edx, 01														;�᫨ 㬥��襭�� (esi != 0), ⮣�� ����� �������� ⠪�� ��ਪ�: jg/jge; 
	add		edx, 05
	mov		al, 78h
	add		al, dl														;!
	jmp		_jsu_rel8_nxt_9_ 
_jsu_rel8_nxt_8_:														;�᫨ 㢥��祭��, ⮣�� ⠪�� ��ਪ�: jl/jle; 
	shl		edx, 01
	add		edx, 04
	mov		al, 78h
	add		al, dl
_jsu_rel8_nxt_9_:
	mov		edx, edi													;edx = ⥪�饬� ����� ��� ����� ����;
	sub		edx, xm_tmp_reg3 											;�⭨���� ���� ��砫� trash2 
	inc		edx															;� ������塞 2 (min_size jxx (short))   
	inc		edx
	cmp		edx, 81h													;�᫨ ����祭��� ���祭�� ����� 81h, ⮣�� ᣥ����㥬 jxx_short_up___rel8; 
	jl		_jxx_short_													;���� jxx_near_up___rel32;
_jxx_near_:																;jxx_near_up___rel32
	mov		byte ptr [edi], 0Fh											;1 byte
	inc		edi
	add		al, 10h														
	stosb																;2 byte;
	xchg	eax, edx													
	add		eax, 04														;!
	neg		eax															;� �������㥬 ������ ���祭��, ⠪ ��� � ��� ���室 ����� (� ���� �� ����訥 ���� aka 横�); 
	stosd																;� ����祭��� � ������� ��� ⠪�� ���� �᫮ �����뢠�� - �� rel32; other bytes; 
	sub		ecx, 06														;᪮�४��㥬 ���-�� ��⠢���� ���� ��� ���쭥�襩 ����� ����; 
	jmp		_jsu_rel8_nxt_10_
_jxx_short_:															;jxx_short_up___rel8
	stosb
	xchg	eax, edx
	neg		eax															;� �������㥬 ������ ���祭��, ⠪ ��� � ��� ���室 ����� (� ���� �� ����訥 ���� aka 横�); 
	stosb																;� ����祭��� � ������� ��� ⠪�� ���� �᫮ �����뢠�� - �� rel8;  
	dec		ecx															;᪮�४��㥬 ���-�� ��⠢���� ���� ��� ���쭥�襩 ����� ����; 
	dec		ecx

_jsu_rel8_nxt_10_:
;--------------------------------------------------------------------------------------------------------
	mov		esi, xm_xids_addr 
	assume	esi: ptr XTG_INSTR_DATA_STRUCT
	test	esi, esi													;����� �� �� ������?
	je		_vju_nxt_4_ 

	and		[esi].instr_addr, 0											;�᫨ ��, ⮣�� ��ᨬ ������ ���� � 0; 
	pop		[esi].param_1												;� ����⠭���� ࠭�� ��࠭񭭮� ����; 
;-------------------------------------------------------------------------------------------------------- 
_vju_nxt_4_: 	

	pop		[ebx].nobw													;����⠭�������� �� ��� ࠭�� ��࠭�� ���祭�� ������ ����� ��������; 
	pop		[ebx].xmask2
	pop		[ebx].xmask1
	pop		[ebx].fregs
	pop		[ebx].trash_size
	pop		[ebx].tw_trash_addr											; 

	;pop	xm_tmp_reg0													;ࠧ��稬 ��� ����稪 (ॣ����); 
	;call	unset_r32													;� �� ⥯��� �� �㦭� ��뢠��; 

	jmp		_chk_instr_
;=====================================[JXX_UP REL8/REL32]================================================
	

 	
;====================================[JMP_DOWN REL8/REL32]===============================================
;jxx trash2
;trash1
;jmp next_code
;trash2
;next_code
;
;jxx/jmp short/near etc; 
;
jmp_down___rel8___rel32:
	mov		eax, (2FEh - 06) 
	push	eax
	call	get_rnd_num_1												;����砥� �� � [0x06..0x2FF] - �� �㤥� ࠧ��� ��� trash1;
	
	add		eax, 06 
	xchg	eax, esi
	mov		xm_tmp_reg1, esi

	pop		eax
	call	get_rnd_num_1												;����砥� �� � [0x06..0x2FF] - �� �㤥� ࠧ��� ��� trash2; 
	
	add		eax, 06
	mov		xm_tmp_reg2, eax
	add		esi, eax													;esi = trash1 + trash2 + 06 (max size of jxx (near)) + 05 (max size of jmp (near)) = 
	add		esi, (06 + 05)												;= 300h + 300h + 06 + 05 = 60Bh (���㣫���); 
	cmp		ecx, esi													;�᫨ ���-�� ��⠢���� ��� ����� ���� ���� ����� �㦭��� ���-�� ���� ��� �����樨 ������ �������樨, � �� ��室; 
	jl		_chk_instr_

	push	[ebx].tw_trash_addr											;��࠭�� � ��� �㦭� ���� ��������, ⠪ ��� �� �� �㤥� �������� � ���쭥�襬; 
	push	[ebx].trash_size
	push	[ebx].nobw

;--------------------------------------------------------------------------------------------------------
	cmp		xm_xids_addr, 0												;����� �� �� ������? 
	je		_vjmpd_nxt_1_ 
	
	push	esi
	mov		esi, xm_xids_addr
	assume	esi: ptr XTG_INSTR_DATA_STRUCT	
	push	edx
	
	mov		edx, xm_struct2_addr
	assume	edx: ptr XTG_EXT_TRASH_GEN
	
	push	[edx].xlogic_struct_addr									;� �맮��� �㭪� ��0��ન ������ ������ (���饩) �������樨
	push	ebx
	call	let_main

	pop		edx
	cmp		eax, 01														;�᫨ �� ������ ��室��, ⮣�� ��� �����
	je		_vjmpd_nxt_3_

	mov		edi, [esi].instr_addr										;���� ���४��㥬 ���祭�� � ��室��
	mov		ecx, [esi].norb 
	pop		esi
	jmp		_vjmpd_nxt_4_												;���室�� �� ����⠭������� ��㣨� ����� ��㣮� ������ etc; 

_vjmpd_nxt_3_:
	pop		eax 
	push	[esi].param_1 
	or		[esi].param_1, XTG_XIDS_CONSTR								;㪠�뢠��, �� ����� �㤥� �������� ����, �ਭ������騩 (�⮩) �������樨
	and		[esi].instr_addr, 0											;���뢠�� ���� � 0 - �� �㦭� ��� ⮣�, �⮡� ����� �� ᭮�� �� �஢�ਫ� ��� ��������� �� ������, � �஢��﫨 㦥 ���� ᣥ��७�� ���騥 �������
	xchg	eax, esi													;esi = eax; 
;--------------------------------------------------------------------------------------------------------
_vjmpd_nxt_1_:
	
	push	02															;eax = 02; 
	pop		eax
	cmp		xm_tmp_reg2, 80h											;�᫨ ࠧ��� ��� trash2 < 80h, ⮣�� jmp �㤥� ������� short (2 bytes)
	jl		_jmpd_nxt_1_
	add		eax, 03														;���� jmp near (5 bytes); 
_jmpd_nxt_1_:
	sub		ecx, eax													;�ࠧ� ᪮�४��㥬 ����稪 ��⠢���� ���⥪��; 
	mov		esi, eax
	add		eax, xm_tmp_reg1											;�����, ������� � ࠧ���� jmp'a ࠧ��� trash1 
	mov		xm_tmp_reg3, eax
	cmp		eax, 80h													;�᫨ ����祭��� ���祭�� < 80h, ⮣�� �㤥� ������� jxx short (2 bytes), ���� jxx near (6 bytes); 
	jl		_jmpd_gen_jxx_short_1_
_jmpd_gen_jxx_near_1_:													;generate jxx near; 
	mov		al, 0Fh														;1 byte;
	stosb
	push	edi															;��࠭�� ����, ��᫥ ����襬 � ��⠫�� �����;
	add		edi, 05														;stosd + inc edi; ���᪠������ �� ������� trash1; 
	jmp		_jmpd_trash1_
_jmpd_gen_jxx_short_1_:													;jxx short; 
	push	edi
	inc		edi
	inc		edi
_jmpd_trash1_:															;trash1
	mov		[ebx].tw_trash_addr, edi
	mov		eax, xm_tmp_reg1
	mov		[ebx].trash_size, eax	
	and		[ebx].nobw, 0
	
	push	xm_struct2_addr
	push	ebx
	call	xtg_main

	pop		edi
	mov		edx, [ebx].nobw

	push	02															;jne/je;
	call	[ebx].rang_addr

	add		al, 74h
	cmp		xm_tmp_reg3, 80h											;generate jxx short or near?
	jl		_jmpd_gen_jxx_short_2_
_jmpd_gen_jxx_near_2_:													;jxx near
	add		al, 10h														;�����뢠�� ��⠫�� �����;
	stosb
	lea		eax, dword ptr [edx + esi]									;jxx �㤥� 㪠�뢠�� �� �������, ������ �ࠧ� �� jmp'�� - � ���� jxx 㪠�뢠�� �� trash2; 
	stosd
	sub		ecx, 06
	jmp		_jmpd_nxt_2_
_jmpd_gen_jxx_short_2_:													;jxx short
	stosb
	lea		eax, dword ptr [edx + esi]  
	stosb
	dec		ecx
	dec		ecx
_jmpd_nxt_2_:
	add		edi, edx 
	sub		ecx, edx 
	push	edi
	add		edi, esi													;��९�룭�� �� ����, �� ���஬� ᣥ��ਬ trash2;
_jmpd_trash2_:															;trash2

;--------------------------------------------------------------------------------------------------------
	push	esi
	mov		esi, xm_xids_addr 
	assume	esi: ptr XTG_INSTR_DATA_STRUCT	
	test	esi, esi
	je		_vjmpd_t2_nxt_
	and		[esi].instr_addr, 0											;��। ������ ४��ᨥ� ���뢠�� ������ ���� � 0, �⮡� ����� �஢��﫨�� �� ������ ���� �������, � �� ᭮�� �� �������� � �.�.; 
_vjmpd_t2_nxt_:
	pop		esi
;--------------------------------------------------------------------------------------------------------

	mov		[ebx].tw_trash_addr, edi
	mov		eax, xm_tmp_reg2
	mov		[ebx].trash_size, eax	
	and		[ebx].nobw, 0
	
	push	xm_struct2_addr
	push	ebx
	call	xtg_main

	pop		edi
	mov		eax, [ebx].nobw

	cmp		xm_tmp_reg2, 80h											;generate jmp short or near?
	jl		_jmpd_gen_jmp_short_1_
_jmpd_gen_jmp_near_1_:													;jmp near;
	mov		byte ptr [edi], 0E9h
	inc		edi
	stosd
	jmp		_jmpd_nxt_3_
_jmpd_gen_jmp_short_1_:													;jmp short; 
	mov		byte ptr [edi], 0EBh
	inc		edi
	stosb
_jmpd_nxt_3_:
	add		edi, eax 
	sub		ecx, eax

;--------------------------------------------------------------------------------------------------------
	mov		esi, xm_xids_addr 
	assume	esi: ptr XTG_INSTR_DATA_STRUCT
	test	esi, esi													;����� �� �� ������?
	je		_vjmpd_nxt_4_ 

	and		[esi].instr_addr, 0											;�᫨ ��, ⮣�� ��ᨬ ������ ���� � 0; 
	pop		[esi].param_1												;� ����⠭���� ࠭�� ��࠭񭭮� ����; 
;-------------------------------------------------------------------------------------------------------- 
_vjmpd_nxt_4_: 

	pop		[ebx].nobw
	pop		[ebx].trash_size
	pop		[ebx].tw_trash_addr

	jmp		_chk_instr_													;���室�� �� ������� ��㣨� ⥬, �! 
;====================================[JMP_DOWN REL8/REL32]===============================================
	  


;====================================[JMP_DOWN REL8/REL32]===============================================
jmp_up_jxx_down___rel8___rel32:
;����� �ਬ�୮ ⠪:
;init_reg1 (push imm8 pop reg1; mov reg1, imm32; etc)
;trash1
;trash2
;chg_reg1 (inc/dec reg1; add/sub reg1, imm8; etc)
;trash3
;cmp_reg1 (cmp reg1, imm8/imm32; etc)
;jxx next_code
;trash4
;jmp trash2
;next_code;
;...
;====================================[JMP_DOWN REL8/REL32]===============================================



;====================================[CMOVXX REG32, REG32]===============================================
;CMOVE	EAX, ECX	etc	(0Fh 4Xh XXh)
cmovxx___r32__r32:
	cmp		ecx, 03
	jl		_chk_instr_
	mov		al, 0Fh
	stosb																;1 byte
	
	push	16
	call	[ebx].rang_addr

	add		al, 40h
	stosb																;2 byte

	call	get_free_r32												;����砥� ��砩�� ᢮����� ॣ����

	xchg	eax, edx

_cmovxx_r32_r32_grr_: 	
	call	get_rnd_r													;����砥� ��砩�� �� ॣ����; 

	cmp		eax, edx													;�᫨ ॣ����� ࠢ��, � ᭮�� �롨ࠥ� ॣ�����, �� ⠪, �⮡� ��� �뫨 ࠧ��; 
	je		_cmovxx_r32_r32_grr_
	shl		edx, 03
	add		al, 0C0h
	add		eax, edx
	stosb																;3 byte 
	sub		ecx, 03
	jmp		_chk_instr_ 
;====================================[CMOVXX REG32, REG32]===============================================



;========================================[BSWAP REG32]===================================================
;BSWAP	EAX	etc	(0Fh 0C8h) 
bswap___r32:
	cmp		ecx, 02
	jl		_chk_instr_
	mov		al, 0Fh
	stosb

	call	get_free_r32												;�롨ࠥ� ��砩�� ᢮����� ॣ����; 

	add		al, 0C8h
	stosb
	dec		ecx
	dec		ecx
	jmp		_chk_instr_ 
;========================================[BSWAP REG32]===================================================



;=====================================[THREE BYTES INSTR]================================================
;BSF	EAX, ECX		etc (0Fh 0BCh XXh)
;BSR	ECX, EDX		etc (0Fh 0BDh etc)
;BT		EDX, EBX		etc (0Fh 0A3h ...)
;BTC	EBX, ESI		etc (0Fh 0BBh)
;BTR	ESI, EDI		etc (0Fh 0B3h)
;BTS	EDI, EAX		etc (0Fh 0ABh)
;IMUL	EAX, ECX		etc (0Fh 0AFh)
;MOVSX	ECX, DL			etc (0Fh 0BEh)
;MOVSX	EDX, BX			etc (0Fh 0BFh)
;MOVZX	EBX, BH			etc (0Fh 0B6h)
;MOVZX	ESI, DI			etc (0Fh 0B7h)
;SHLD	EDX, EBX, CL	etc (0Fh 0A5h)
;SHRD	EDX, EBX, CL	etc (0Fh 0ADh)
;etc 
three_bytes_instr:
	cmp		ecx, 03														;�᫨ ��� �� 墠⠥� ���⮢ ��� �����樨 ������ ������樨, � �� ��室; 
	jl		_chk_instr_
	mov		al, 0Fh														;���� ����襬 1-� ���⥪; 
	stosb
	push	0BCBDA3BBh													;����� � ��堥� � �⥪ 2-� ������ ࠧ����� ������; 
	push	0B3ABAFBEh
	push	0BFB6B7A5h
	push	0ADAFB7AFh
	mov		edx, esp													;edx - ᮤ�ন� ����, ��� �ᯮ������ ����� ������ � �❪�; 

	push	16
	call	[ebx].rang_addr

	movzx	eax, byte ptr [edx + eax]									;�����, �롥६ ��砩�� ���� �� ��� ���⮢; 
	stosb																;� ����襬 ���;
	add		esp, (4 * 4)												;����⠭�������� �⥪; 

_tbi_mm114r32_:
	call	modrm_mod11_for_r32											;⥯��� ����ਬ ���� modrm, ��� mod = 11b; 

	mov		edx, xm_tmp_reg1
	cmp		edx, xm_tmp_reg2											;����� ⠪, �⮡� ॣ� �뫨 ࠧ��; 
	je		_tbi_mm114r32_
	stosb																;�����뢠��;
	sub		ecx, 03														;���४��㥬 ����稪; �!
	jmp		_chk_instr_													;� �� ��室; 
;=====================================[THREE BYTES INSTR]================================================



;================================[MOV REG32/MEM32, MEM32/REG32]==========================================
;MOV	EAX, DWORD PTR [403000h]	etc (0A1h XXXXXXXXh)
;MOV	ECX, DWORD PTR [403008h]	etc (08Bh XXh XXXXXXXXh)
;MOV	DWORD PTR [40300Ch], EAX	etc (0A3h XXXXXXXXh)
;MOV	DWORD PTR [403010h], ECX	etc (089h XXh XXXXXXXXh)
;etc 
mov___r32_m32__m32_r32:

OFS_MOV_8Bh_r32_m32			equ		50
OFS_MOV_89h_m32_r32			equ		32
OFS_MOV_EAX_0A1h_r32_m32	equ		04
OFS_MOV_EAX_0A3h_m32_r32	equ		01

	cmp		ecx, 06														;�᫨ ���-�� ��⠢���� ��� �����樨 ���� ���⮢ ����� 6, ⮣�� �� ��室; 
	jl		_chk_instr_

	call	check_data													;����, �஢�ਬ ᥪ�� ������ �� �ਣ�������; 

	test	eax, eax
	je		_chk_instr_													;�᫨ ⠬ �����-� �㩭�, ⮣�� ��室��; 
	
	push	(OFS_MOV_8Bh_r32_m32 + OFS_MOV_89h_m32_r32 + OFS_MOV_EAX_0A1h_r32_m32 + OFS_MOV_EAX_0A3h_m32_r32) 
	call	[ebx].rang_addr												;����, ��砩��, � ����, �롥६, ����� ������ ������� �� ������� ����� �㤥� �������; 

	cmp		eax, OFS_MOV_EAX_0A3h_m32_r32
	jl		_mov_eax_m32_r32_
	cmp		eax, (OFS_MOV_EAX_0A3h_m32_r32 + OFS_MOV_EAX_0A1h_r32_m32)
	jl		_mov_eax_r32_m32_
	cmp		eax, (OFS_MOV_EAX_0A3h_m32_r32 + OFS_MOV_EAX_0A1h_r32_m32 + OFS_MOV_89h_m32_r32)
	jge		_mov_r32_m32_
_mov_m32_r32_:															;[MOV DWORD PTR [ADDRESS], REG32] -> REG32 != EAX; 
	mov		al, 89h														;opcode
	jmp		_mov_rmrm_nxt_1_ 
_mov_r32_m32_:															;[MOV REG32, DWORD PTR [ADDRESS]] -> REG32 != EAX; 
	mov		al, 8Bh														;opcode
_mov_rmrm_nxt_1_:
	stosb

_mov_rmrm_gfr32_1_:														;generate MODRM, MOD = 00b (0); 
	call	get_free_r32												;����砥� ��砩�� ᢮����� ॣ, ��祬 ॣ != EAX; 

	test	eax, eax
	je		_mov_rmrm_gfr32_1_
	shl		eax, 03
	add		al, 05
	stosb																;modrm
	jmp		_mov_rmrm_gro_1_

_mov_eax_m32_r32_:														;[MOV DWORD PTR [ADDRESS], EAX]
	mov		al, 0A3h													;opcode
	jmp		_mov_rmrm_nxt_2_
_mov_eax_r32_m32_:														;[MOV EAX, DWORD PTR [ADDRESS]] 
	mov		al, 0A1h													;opcode
_mov_rmrm_nxt_2_:	
	xchg	eax, edx

	mov		xm_tmp_reg0, XM_EAX											;㪠�뢠��, �� �㦭� �஢����, ᢮����� �� ॣ���� EAX
	call	is_free_r32													;��뢠�� �㭪� �஢���;
	
	inc		eax
	je		_chk_instr_
	xchg	eax, edx
	stosb
	inc		ecx 

_mov_rmrm_gro_1_:														;generate offset (MEM32) 
	call	get_rnd_data_va												;��뢠�� �㭪� ����祭�� ��砩���� ����, ��⭮�� ���६; 
	
	stosd																;offset
	sub		ecx, 06														;���४��㥬 ����稪
	jmp		_chk_instr_													;�� ��室; 
;================================[MOV REG32/MEM32, MEM32/REG32]==========================================	 



;===================================[MOV MEM32, IMM8/IMM32]==============================================
;MOV	DWORD PTR [403008h], 05			etc (0C7h 05h XXXXXXXXh XXXXXXXXh)
;MOV	DWORD PTR [403010h], 12345678h	etc (0C7h 05h XXXXXXXXh XXXXXXXXh)
;MOV	BYTE PTR [403014h], 01			etc (0C6h 05h XXXXXXXXh XXh)
mov___m32__imm8_imm32:

OFS_MOV_0C7h_m32_imm32		equ		35
OFS_MOV_0C6h_m32_imm8		equ		15

	cmp		ecx, 10														;�᫨ ���-�� ��⠢���� ���� ����� 10, � �� ��室; 
	jl		_chk_instr_

	call	check_data													;����, �஢�ਬ ᥪ�� ������ �� �ਣ�������; 

	test	eax, eax
	je		_chk_instr_													;�᫨ ⠬ �����-� �㩭�, ⮣�� ��室��; 

	mov		eax, 10000h													;�����, ����稬 ��;
	call	get_rnd_num_1

	lea		esi, dword ptr [eax + 01]									;��࠭�� ��� � esi � ������� 1;
	xor		edx, edx  

	push	(OFS_MOV_0C7h_m32_imm32 + OFS_MOV_0C6h_m32_imm8)
	call	[ebx].rang_addr 

	cmp		eax, OFS_MOV_0C6h_m32_imm8
	jl		_mov_0C6h_
_mov_0C7h_:																;[MOV MEM32, IMM32]
	inc		edx
_mov_0C6h_:																;[MOV MEM32, IMM8]
	mov		al, 0C6h
	add		al, dl
	stosb																;opcode
	mov		al, 05
	stosb																;modrm

	call	get_rnd_data_va												;����稬 ��砩�� ���� � ᥪ樨 ������

	stosd																;offset
	xchg	eax, esi													;�����, �᫨ �� ᣥ���஢�� ����� 0C6h, ⮣�� ��� ���� imm8, �᫨ 0C7h - imm32; 
	imul	edx, edx, 03
 	inc		edx															;edx - �᫮ - ᪮�쪮 ���� �������: 1 (imm8) ��� 4 (imm32); 
	sub		ecx, edx													;���४��㥬 
	sub		ecx, 06 													;����稪; 
_mov_0C6h_0C7h_stosX_:
	stosb																;imm (8 or 32?); � �����뢠��; 
	ror		eax, 08														;横���᪨ ᤢ������� �� 1 ���� ��ࠢ� (�⮡� �ࠢ��쭮 ������� imm - ᬮ�� � �⫠�稪+); 
	dec		edx
	jne		_mov_0C6h_0C7h_stosX_ 
	jmp		_chk_instr_ 												;�� ��室, ���! 
;===================================[MOV MEM32, IMM8/IMM32]==============================================
  


;==================================[MOV REG8/MEM8, MEM8/REG8]============================================
;MOV	AL, BYTE PTR [403000h]		etc (0A0h XXXXXXXXh)
;MOV	CL, BYTE PTR [403008h]		etc (08Ah XXh XXXXXXXXh)
;MOV	BYTE PTR [40300Ch], AL		etc (0A2h XXXXXXXXh)
;MOV	BYTE PTR [403010h], CL		etc (088h XXh XXXXXXXXh)
;etc 
mov___r8_m8__m8_r8:

OFS_MOV_8Ah_r8_m8			equ		55
OFS_MOV_88h_m8_r8			equ		35
OFS_MOV_EAX_0A0h_r8_m8		equ		05
OFS_MOV_EAX_0A2h_m8_r8		equ		05

	cmp		ecx, 06														;�᫨ ���-�� ��⠢���� ��� �����樨 ���� ���⮢ ����� 6, ⮣�� �� ��室; 
	jl		_chk_instr_

	call	check_data													;����, �஢�ਬ ᥪ�� ������ �� �ਣ�������; 

	test	eax, eax
	je		_chk_instr_													;�᫨ ⠬ �����-� �㩭�, ⮣�� ��室��; 
	
	push	(OFS_MOV_8Ah_r8_m8 + OFS_MOV_88h_m8_r8 + OFS_MOV_EAX_0A0h_r8_m8 + OFS_MOV_EAX_0A2h_m8_r8) 
	call	[ebx].rang_addr												;����, ��砩��, � ����, �롥६, ����� ������ ������� �� ������� ����� �㤥� �������; 

	cmp		eax, OFS_MOV_EAX_0A2h_m8_r8
	jl		_mov_eax_m8_r8_
	cmp		eax, (OFS_MOV_EAX_0A2h_m8_r8 + OFS_MOV_EAX_0A0h_r8_m8)
	jl		_mov_eax_r8_m8_
	cmp		eax, (OFS_MOV_EAX_0A2h_m8_r8 + OFS_MOV_EAX_0A0h_r8_m8 + OFS_MOV_88h_m8_r8)
	jge		_mov_r8_m8_
_mov_m8_r8_:															;[MOV MEM8, REG8] -> REG8 != AL; 
	mov		al, 88h														;opcode
	jmp		_mov_rmrm_nxt_01_ 
_mov_r8_m8_:															;[MOV REG8, MEM8] -> REG8 != AL; 
	mov		al, 8Ah														;opcode
_mov_rmrm_nxt_01_:
	stosb

_mov_rmrm_gfr8_1_:														;generate MODRM, MOD = 00b (0); 
	call	get_free_r8													;����砥� ��砩�� ᢮����� ॣ, ��祬 ॣ != AL; 

	test	eax, eax 
	je		_mov_rmrm_gfr8_1_
	shl		eax, 03
	add		al, 05
	stosb																;modrm
	jmp		_mov_rmrm_gro_01_

_mov_eax_m8_r8_:														;[MOV MEM8, AL]
	mov		al, 0A2h													;opcode
	jmp		_mov_rmrm_nxt_02_
_mov_eax_r8_m8_:														;[MOV AL, MEM8] 
	mov		al, 0A0h													;opcode
_mov_rmrm_nxt_02_:	
	xchg	eax, edx

	mov		xm_tmp_reg0, XM_EAX											;㪠�뢠��, �� �㦭� �஢����, ᢮����� �� ॣ���� EAX (AL, �� �� AH!); 
	call	is_free_r32													;��뢠�� �㭪� �஢���;
	
	inc		eax
	je		_chk_instr_
	xchg	eax, edx
	stosb
	inc		ecx 

_mov_rmrm_gro_01_:														;generate offset (MEM8) 
	call	get_rnd_data_va												;��뢠�� �㭪� ����祭�� ��砩���� ����, ��⭮�� ���६; 
	
	stosd																;offset
	sub		ecx, 06														;���४��㥬 ����稪
	jmp		_chk_instr_													;�� ��室; 
;==================================[MOV REG8/MEM8, MEM8/REG8]============================================



;=======================================[INC/DEC MEM32]==================================================
;INC	DWORD PTR [403008h]	etc (0FFh 05h XXXXXXXXh)
;DEC	DWORD PTR [40300Ch]	etc (0FFh 0Dh XXXXXXXXh)
inc_dec___m32:
	cmp		ecx, 06														;�᫨ ���-�� ��⠢���� ��� �����樨 ���� ���⮢ ����� 6, ⮣�� �� ��室;  
	jl		_chk_instr_ 

	call	check_data													;����, �஢�ਬ ᥪ�� ������ �� �ਣ�������; 

	test	eax, eax
	je		_chk_instr_													;�᫨ ⠬ �����-� �㩭�, ⮣�� ��室��; 

	mov		al, 0FFh													;opcode (1 bytes)
	stosb 

	push	02															;ᣥ���஢��� inc ��� dec?
	call	[ebx].rang_addr

	shl		eax, 03
	add		al, 05
	stosb																;modrm

	call	get_rnd_data_va												;��뢠�� �㭪� ����祭�� ��砩���� ����, ��⭮�� ���६; 

	stosd																;offset (MEM32); 
	sub		ecx, 06														;���४��㥬 ����稪;
	jmp		_chk_instr_													;���� �� ��室! 
;=======================================[INC/DEC MEM32]==================================================
 


;==========================[ADC/ADD/AND/OR/SBB/SUB/XOR REG32, MEM32]=====================================
;ADC	ECX, DWORD PTR [403008h]	etc (13h XXh XXXXXXXXh)				;��࠭� ������ ����� ������, ⠪ ��� ��㣨� ������ ��� ������ ������ ms �� ��������; 
;ADD	EAX, DWORD PTR [40300Ch]	etc (03h XXh XXXXXXXXh)
;AND	EAX, DWORD PTR [403010h]	etc (23h XXh XXXXXXXXh)
;OR		ESI, DWORD PTR [403014h]	etc (0Bh XXh XXXXXXXXh)
;SBB	EDI, DWORD PTR [403018h]	etc (1Bh XXh XXXXXXXXh) 
;SUB	EBX, DWORD PTR [40301Ch]	etc (2Bh XXh XXXXXXXXh) 
;XOR	ECX, DWORD PTR [403020h]	etc (33h XXh XXXXXXXXh) 
;etc  
adc_add_and_or_sbb_sub_xor___r32__m32:
 
OFS_XOR_33h_r32_m32			equ		05
OFS_ADD_03h_r32_m32			equ		35
OFS_SUB_2Bh_r32_m32			equ		25
OFS_AAAOSSX_r32_m32			equ		05

	cmp		ecx, 06 
	jl		_chk_instr_ 

	call	check_data													;����, �஢�ਬ ᥪ�� ������ �� �ਣ�������; 

	test	eax, eax
	je		_chk_instr_													;�᫨ ⠬ �����-� �㩭�, ⮣�� ��室��; 
	
	push	(OFS_XOR_33h_r32_m32 + OFS_ADD_03h_r32_m32 + OFS_SUB_2Bh_r32_m32 + OFS_AAAOSSX_r32_m32)
	call	[ebx].rang_addr

	cmp		eax, OFS_AAAOSSX_r32_m32 
	jl		_aaaossx_r32_m32_
	cmp		eax, (OFS_AAAOSSX_r32_m32 + OFS_SUB_2Bh_r32_m32)
	jl		_r32m32_2Bh_
	cmp		eax, (OFS_AAAOSSX_r32_m32 + OFS_SUB_2Bh_r32_m32 + OFS_ADD_03h_r32_m32)
	jge		_r32m32_33h_
_r32m32_03h_:															;[ADD REG32, MEM32]
	mov		al, 03h 
	jmp		_r32m32_2Bh_03h_33h_
_r32m32_2Bh_:															;[SUB REG32, MEM32]
	mov		al, 2Bh														
	jmp		_r32m32_2Bh_03h_33h_
_r32m32_33h_:															;[XOR REG32, MEM32]
	mov		al, 33h
	jmp		_r32m32_2Bh_03h_33h_ 

_aaaossx_r32_m32_:														;[�� ��⠫�� ����㯭� ����� ������, ������ ᭮�� 03h, 2Bh, 33h]
	push	07															;����� ���� ������ ��砩��� �����樨 ������ �� �������� �������
	call	[ebx].rang_addr 
	
	shl		eax, 03
	add		al, 03
_r32m32_2Bh_03h_33h_:	
	stosb																;����襬 ᣥ���஢���� �����

	call	get_free_r32

	shl		eax, 03
	add		al, 05
	stosb

	call	get_rnd_data_va												;��뢠�� �㭪� ����祭�� ��砩���� ����, ��⭮�� ���६; 

	stosd 
	sub		ecx, 06
	jmp		_chk_instr_ 												;��ࠢ�塞�� �� ������� ᫥���饩 ������樨/�������樨; 
;==========================[ADC/ADD/AND/OR/SBB/SUB/XOR REG32, MEM32]=====================================



;==========================[ADC/ADD/AND/OR/SBB/SUB/XOR MEM32, REG32]=====================================
;ADC	DWORD PTR [403008h], EAX	etc (11h XXh XXXXXXXXh)				;��࠭� ������ ����� ������, ⠪ ��� ��㣨� ������ ��� ������ ������ ms �� ��������; 
;ADD	DWORD PTR [40300Ch], ECX	etc (01h XXh XXXXXXXXh)
;AND	DWORD PTR [403010h], EDX	etc (21h XXh XXXXXXXXh)
;OR		DWORD PTR [403014h], EBX	etc (09h XXh XXXXXXXXh)
;SBB	DWORD PTR [403018h], ESP	etc (19h XXh XXXXXXXXh) 
;SUB	DWORD PTR [40301Ch], EBP	etc (29h XXh XXXXXXXXh) 
;XOR	DWORD PTR [403020h], ESI	etc (31h XXh XXXXXXXXh) 
;etc  
adc_add_and_or_sbb_sub_xor___m32__r32:
 
OFS_XOR_31h_m32_r32			equ		02
OFS_ADD_01h_m32_r32			equ		15
OFS_SUB_29h_m32_r32			equ		10
OFS_AAAOSSX_m32_r32			equ		01

	cmp		ecx, 06 
	jl		_chk_instr_ 

	call	check_data													;����, �஢�ਬ ᥪ�� ������ �� �ਣ�������; 

	test	eax, eax
	je		_chk_instr_													;�᫨ ⠬ �����-� �㩭�, ⮣�� ��室��; 
	
	push	(OFS_XOR_31h_m32_r32 + OFS_ADD_01h_m32_r32 + OFS_SUB_29h_m32_r32 + OFS_AAAOSSX_m32_r32)
	call	[ebx].rang_addr

	cmp		eax, OFS_AAAOSSX_m32_r32 
	jl		_aaaossx_m32_r32_
	cmp		eax, (OFS_AAAOSSX_m32_r32 + OFS_SUB_29h_m32_r32)
	jl		_m32r32_29h_
	cmp		eax, (OFS_AAAOSSX_m32_r32 + OFS_SUB_29h_m32_r32 + OFS_ADD_01h_m32_r32)
	jge		_m32r32_31h_
_m32r32_01h_:															;[ADD MEM32, REG32]
	mov		al, 01h 
	jmp		_m32r32_29h_01h_31h_
_m32r32_29h_:															;[SUB MEM32, REG32]
	mov		al, 29h														
	jmp		_m32r32_29h_01h_31h_
_m32r32_31h_:															;[XOR MEM32, REG32]
	mov		al, 31h
	jmp		_m32r32_29h_01h_31h_ 

_aaaossx_m32_r32_:														;[�� ��⠫�� ����㯭� ����� ������, ������ ᭮�� 03h, 2Bh, 33h]
	push	07															;����� ���� ������ ��砩��� �����樨 ������ �� �������� �������
	call	[ebx].rang_addr 
	
	shl		eax, 03
	add		al, 01
_m32r32_29h_01h_31h_:	
	stosb																;����襬 ᣥ���஢���� �����

	call	get_rnd_r													;����砥� ��砩�� ॣ����; 

	shl		eax, 03
	add		al, 05
	stosb

	call	get_rnd_data_va												;��뢠�� �㭪� ����祭�� ��砩���� ����, ��⭮�� ���६; 

	stosd 
	sub		ecx, 06
	jmp		_chk_instr_ 												;��ࠢ�塞�� �� ������� ᫥���饩 ������樨/�������樨; 
;==========================[ADC/ADD/AND/OR/SBB/SUB/XOR MEM32, REG32]=====================================
  


;=======================[ADC/ADD/AND/OR/SBB/SUB/XOR REG8/MEM8, MEM8/REG8]================================
;ADC	AL, BYTE PTR [403008h]	etc (12h XXh XXXXXXXXh)						;����� ������ ������� ����, ���⮬� �訫 �� �����஢��� ⠪
;ADD	CL, BYTE PTR [40300Ch]	etc (02h XXh XXXXXXXXh)						;��� ���뢠���� ⮫쪮 ��� �ᥩ ��㯯� ������ �������; 
;AND	DL, BYTE PTR [403010h]	etc (22h XXh XXXXXXXXh)
;OR		BL, BYTE PTR [403014h]	etc (0Ah XXh XXXXXXXXh)
;SBB	AH, BYTE PTR [403018h]	etc (1Ah XXh XXXXXXXXh)
;SUB	CH, BYTE PTR [40301Ch]	etc (2Ah XXh XXXXXXXXh)
;XOR	DH, BYTE PTR [403020h]	etc (32h XXh XXXXXXXXh)
;ADC	BYTE PTR [403024h], BH	etc (10h XXh XXXXXXXXh)
;ADD	BYTE PTR [403028h], AL	etc (00h XXh XXXXXXXXh)
;AND	BYTE PTR [40302Ch], CL	etc (20h XXh XXXXXXXXh)
;OR		BYTE PTR [403030h], DL	etc (08h XXh XXXXXXXXh)
;SBB	BYTE PTR [403034h], BL	etc (18h XXh XXXXXXXXh)
;SUB	BYTE PTR [403038h], AH	etc (28h XXh XXXXXXXXh)
;XOR	BYTE PTR [40303Ch], CH	etc (30h XXh XXXXXXXXh)
;etc 
adc_add_and_or_sbb_sub_xor___r8_m8__m8_r8: 
	cmp		ecx, 06
	jl		_chk_instr_

	call	check_data													;����, �஢�ਬ ᥪ�� ������ �� �ਣ�������; 

	test	eax, eax
	je		_chk_instr_													;�᫨ ⠬ �����-� �㩭�, ⮣�� ��室��; 

	push	02															;����� ��⠢�塞 �����: ���� 3 ������ ��� (0-2) ����� �ਭ����� ���� �� 2-� ���祭��: 0 ��� 2; 
	call	[ebx].rang_addr 											;᫥���騥 3 ��� (3-5) ����� �ਭ����� �� ���祭�� � ��������� [0..6];
																		;� ��᫥���� 2 ��� (6-7) �ᥣ�� ࠢ�� 0; 
	shl		eax, 01
	xchg	eax, edx

	push	07
	call	[ebx].rang_addr

	shl		eax, 03
	add		al, dl
	stosb																;opcode

	call	get_free_r8													;����砥� ��砩�� ᢮����� ॣ8; 

	shl		eax, 03
	add		al, 05
	stosb																;modrm; 

	call	get_rnd_data_va												;��뢠�� �㭪� ����祭�� ��砩���� ����, ��⭮�� ���६; 

	stosd 																;offset 
	sub		ecx, 06
	jmp		_chk_instr_ 												;��ࠢ�塞�� �� ������� ᫥���饩 ������樨/�������樨; 
;=======================[ADC/ADD/AND/OR/SBB/SUB/XOR REG8/MEM8, MEM8/REG8]================================


	
;======================[ADC/ADD/AND/OR/SBB/SUB/XOR MEM32/MEM8, IMM32/IMM8]===============================
;ADC	DWORD PTR [403008h], 1		etc (83h XXh XXXXXXXXh XXh)
;ADD	DWORD PTR [40300Ch], 12345h	etc (81h XXh XXXXXXXXh XXXXXXXXh)
;AND	BYTE PTR  [403010h], 05		etc (80h XXh XXXXXXXXh XXh)
;etc
adc_add_and_or_sbb_sub_xor___m32_m8__imm32_imm8:

OFS_AAAOSSX_m_imm_83h	equ	08
OFS_AAAOSSX_m_imm_81h	equ	01
OFS_AAAOSSX_m_imm_80h	equ	01

;OFS_ADD_m_imm		equ		35
;OFS_SUB_m_imm		equ		25
;OFS_AND_m_imm		equ		15
;OFS_AAAOSSX_m_imm	equ		15 

	cmp		ecx, 10														;�᫨ ���-�� ��⠢���� ���� ��� �����/�����樨 ���� < 10, ��室��; 
	jl		_chk_instr_

	call	check_data													;����, �஢�ਬ ᥪ�� ������ �� �ਣ�������; 

	test	eax, eax
	je		_chk_instr_													;�᫨ ⠬ �����-� �㩭�, ⮣�� ��室��; 

	mov		eax, 10000h													;�����, ����稬 ��;
	call	get_rnd_num_1

	lea		esi, dword ptr [eax + 101h]									;��࠭�� ��� � esi � ������� 101h;
	xor		edx, edx  

	push	(OFS_AAAOSSX_m_imm_83h + OFS_AAAOSSX_m_imm_81h + OFS_AAAOSSX_m_imm_80h)
	call	[ebx].rang_addr												;��⥬, �ᯮ���� ����, "��砩��" ��।����, ����� �����⭮ ������� �㤥� �������; 

	cmp		eax, OFS_AAAOSSX_m_imm_80h
	jl		_aaaossx_m_imm_80h_
	cmp		eax, (OFS_AAAOSSX_m_imm_80h + OFS_AAAOSSX_m_imm_81h)
	jge		_aaaossx_m_imm_83h_
_aaaossx_m_imm_81h_:													;[ADC/etc MEM32, IMM32]
	mov		al, 81h
	add		edx, 03
	jmp		_aaaossx_m_imm_nxt_1_
_aaaossx_m_imm_83h_:													;[ADC/etc MEM32, IMM8]
	mov		al, 83h
	jmp		_aaaossx_m_imm_nxt_1_
_aaaossx_m_imm_80h_:													;[ADC/etc MEM8, IMM8]
	mov		al, 80h
_aaaossx_m_imm_nxt_1_:
	stosb																;opcode 

	push	07															;⥯��� ��।����, ����� �㤥� �������: ADC, ADD, AND etc ? 
	call	[ebx].rang_addr

	shl		eax, 03
	add		al, 05
	stosb																;modrm

	call	get_rnd_data_va												;����稬 ��砩�� ���� � ᥪ樨 ������
	
	stosd																;offset
	inc		edx															;edx = 1 ��� 4; 
	sub		ecx, edx													;�⭨���� �� ecx ���� 7 ���� 10 (ᬮ���, ����� ������� ������㥬); 
	sub		ecx, 06
	xchg	eax, esi
_aaaossx_m_imm_stosX_:
	stosb																;imm 
	ror		eax, 08
	dec		edx
	jne		_aaaossx_m_imm_stosX_ 
	jmp		_chk_instr_
;======================[ADC/ADD/AND/OR/SBB/SUB/XOR MEM32/MEM8, IMM32/IMM8]===============================



;================================[CMP REG32/MEM32, MEM32/REG32]==========================================
;CMP	EAX, DWORD PTR [403008h]	etc (3Bh XXh XXXXXXXXh)
;CMP	DWORD PTR [403008h], ECX	etc (39h XXh XXXXXXXXh) 
cmp___r32_m32__m32_r32:

OFS_CMP_3Bh_r32m32_m32r32	equ	35
OFS_CMP_39h_r32m32_m32r32	equ	25

	mov		eax, (300h - 06)											;�����, ����稬 ��;
	call	get_rnd_num_1 

	add		eax, 06														;�� >= 6, �⮡� ����� ��� �� ���� ������� �뫠 ᣥ��७� (����� ��� ������ 6 ����!); 
	mov		edx, eax
	add		eax, (06 + 06)	
	cmp		ecx, eax													;�᫨ ���-�� ��⠢���� ���⮢ < 30Ch, ⮣�� ��室��
	jl		_chk_instr_

	call	check_data													;����, �஢�ਬ ᥪ�� ������ �� �ਣ�������; 

	test	eax, eax
	je		_chk_instr_													;�᫨ ⠬ �����-� �㩭�, ⮣�� ��室��; 

	push	(OFS_CMP_3Bh_r32m32_m32r32 + OFS_CMP_39h_r32m32_m32r32)
	call	[ebx].rang_addr

	cmp		eax, OFS_CMP_39h_r32m32_m32r32
	jl		_cmp_39h_r32m32_m32r32_
_cmp_3Bh_r32m32_m32r32_:												;[MOV REG32, MEM32]
	mov		al, 3Bh
	jmp		_cmp_3Bh_39h_
_cmp_39h_r32m32_m32r32_:												;[MOV MEM32, REG32]
	mov		al, 39h
_cmp_3Bh_39h_:
	stosb																;opcode

	call	get_free_r32												;get free reg32

	shl		eax, 03
	add		al, 05
	stosb																;modrm (mod = 0);

	call	get_rnd_data_va												;����稬 ��砩�� ���� � ᥪ樨 ������
	
	stosd																;offset
	sub		ecx, 06
	cmp		edx, 80h													;� ��।��塞, �� ������� ������ ���室� ��룭�� (short or near); 
	jl		_jsdrel8_entry_ 
	jmp		_jndrel32_entry_	
;================================[CMP REG32/MEM32, MEM32/REG32]==========================================



;=================================[CMP MEM32/MEM8, IMM32/IMM8]===========================================
;CMP	DWORD PTR [403008h], 1		etc (83h XXh XXXXXXXXh XXh)
;CMP	DWORD PTR [40300Ch], 12345h	etc (81h XXh XXXXXXXXh XXXXXXXXh)
;CMP	BYTE PTR  [403010h], 05		etc (80h XXh XXXXXXXXh XXh)
;etc
cmp___m32_m8__imm32_imm8:

OFS_CMP_m_imm_83h	equ	35
OFS_CMP_m_imm_81h	equ	15
OFS_CMP_m_imm_80h	equ	05 

	mov		eax, (300h - 06)											;����稬 ��;
	call	get_rnd_num_1 

	add		eax, 06														;etc 
	mov		edx, eax
	add		eax, (10 + 06)	
	cmp		ecx, eax													;�᫨ ���-�� ��⠢���� ���⮢ < 310h, ⮣�� ��室��
	jl		_chk_instr_
	
	call	check_data													;����, �஢�ਬ ᥪ�� ������ �� �ਣ�������; 

	test	eax, eax
	je		_chk_instr_													;�᫨ ⠬ �����-� �㩭�, ⮣�� ��室��; 
	push	edx

	mov		eax, 10000h													;�����, ����稬 ��;
	call	get_rnd_num_1

	lea		esi, dword ptr [eax + 101h]									;��࠭�� ��� � esi � ������� 101h (⠪ ��� ���� ���᭮, �㤥� �� ����� 83h ��� 81h); 
	xor		edx, edx  

	push	(OFS_CMP_m_imm_83h + OFS_CMP_m_imm_81h + OFS_CMP_m_imm_80h)
	call	[ebx].rang_addr												;��⥬, �ᯮ���� ����, "��砩��" ��।����, ����� �����⭮ ������� �㤥� �������; 

	cmp		eax, OFS_CMP_m_imm_80h
	jl		_cmp_m_imm_80h_
	cmp		eax, (OFS_CMP_m_imm_80h + OFS_CMP_m_imm_81h)
	jge		_cmp_m_imm_83h_
_cmp_m_imm_81h_:														;[CMP MEM32, IMM32]
	mov		al, 81h
	add		edx, 03
	jmp		_cmp_m_imm_nxt_1_
_cmp_m_imm_83h_:														;[CMP MEM32, IMM8]
	mov		al, 83h
	jmp		_cmp_m_imm_nxt_1_
_cmp_m_imm_80h_:														;[CMP MEM8, IMM8]
	mov		al, 80h
_cmp_m_imm_nxt_1_:
	stosb																;opcode 

	mov		al, 3Dh
	stosb

	call	get_rnd_data_va												;����稬 ��砩�� ���� � ᥪ樨 ������
	
	stosd																;offset
	inc		edx															;edx = 1 ��� 4; 
	sub		ecx, edx													;�⭨���� �� ecx ���� 7 ���� 10 (ᬮ���, ����� ������� ������㥬); 
	sub		ecx, 06
	xchg	eax, esi
_cmp_m_imm_stosX_:
	stosb																;imm 
	ror		eax, 08
	dec		edx
	jne		_cmp_m_imm_stosX_ 
	pop		edx 
	cmp		edx, 80h													;� ��।��塞, �� ������� ������ ���室� ��룭�� (short or near); 
	jl		_jsdrel8_entry_ 
	jmp		_jndrel32_entry_		
;=================================[CMP MEM32/MEM8, IMM32/IMM8]===========================================



;=============================[MOV/LEA REG32, DWORD PTR [ebp +- XXh]]==================================== 
;MOV	EAX, DWORD PTR [EBP - 04]	etc	(8Bh XXh XXh)
;MOV	ECX, DWORD PTR [EBP + 04]	etc	(8Bh XXh XXh)
;LEA	EDX, DWORD PTR [EBP - 08]	etc (8Dh XXh XXh)
;LEA	EBX, DWORD PTR [EBP + 08]	etc (8Dh XXh XXh) 
;!!!!! �᫨ ���⥫��� ������� ������� ��� � � moffs32, ⮣�� �������� ����� �㦭� ���; 
mov_lea___r32__m32ebpo8:

OFS_MOV_r32_m32ebpo8_8Bh		equ		50
OFS_LEA_r32_m32ebpo8_8Dh		equ		20

	cmp		ecx, 03														;�᫨ ���-�� ��⠢���� ���� ��� ����� ���� ����� 3-�, ⮣�� ��室��; 
	jl		_chk_instr_

	call	check_local_param_num										;����, �롥६ ��砩�� ���� ������� ��६����, ���� �室�� ��ࠬ���� � �஢�ਬ ��⥫쭮 ���� �� ��� ��ਠ�⮢; 

	inc		eax
	je		_chk_instr_													;�᫨ eax == -1, � �� ��室; 
	dec		eax
	xchg	eax, edx
	mov		esi, [ebx].xfunc_struct_addr

	push	(OFS_MOV_r32_m32ebpo8_8Bh + OFS_LEA_r32_m32ebpo8_8Dh) 
	call	[ebx].rang_addr

	cmp		eax, OFS_LEA_r32_m32ebpo8_8Dh
	jl		_lea_r32_m32ebpo8_
_mov_r32_m32ebpo8_:														;[MOV REG32, DWORD PTR [EBP +- XXh]]
	mov		al, 8Bh
	jmp		_ml_rm_ebpo8_nxt_1_ 
_lea_r32_m32ebpo8_:														;[LEA REG32, DWORD PTR [EBP +- XXh]] 
	mov		al, 8Dh
_ml_rm_ebpo8_nxt_1_:
	stosb																;opcode (1 byte); 

	call	get_free_r32												;����砥� ��砩�� ᢮����� ॣ32

	shl		eax, 03
	add		al, 45h
	stosb																;modrm (2 byte);
	test	edx, edx
	je		_ml_rm_ebpo8_gl_

_ml_rm_ebpo8_gp_:														;generate param;
	call	get_moffs8_ebp_param

	stosb
	jmp		_ml_rm_ebpo8_nxt_2_

_ml_rm_ebpo8_gl_:														;generate local;
	call	get_moffs8_ebp_local

	stosb																;moffs8 (3 byte) - mem offset8; ebpo8 - ebp offset8; 
_ml_rm_ebpo8_nxt_2_:
	sub		ecx, 03														;���४��㥬 ����稪; 
	jmp		_chk_instr_ 
;=============================[MOV/LEA REG32, DWORD PTR [ebp +- XXh]]====================================



;==============================[MOV DWORD PTR [ebp +- XXh], REG32]=======================================
;MOV	DWORD PTR [EBP - 04], EAX	etc	(89h XXh XXh)
;MOV	DWORD PTR [EBP + 04], ECX	etc (89h XXh XXh)
;etc 
;!!!!! �᫨ ���⥫��� ������� ������� ��� � � moffs32, ⮣�� �������� ����� �㦭� ���; 
mov___m32ebpo8__r32:
	cmp		ecx, 03														;etc
	jl		_chk_instr_

	call	check_local_param_num										;etc

	inc		eax
	je		_chk_instr_
	dec		eax
	xchg	eax, edx
	mov		esi, [ebx].xfunc_struct_addr
	mov		al, 89h
	stosb

	call	get_free_r32

	shl		eax, 03
	add		al, 45h
	stosb
	test	edx, edx
	je		_ml_mr_ebpo8_gl_

_ml_mr_ebpo8_gp_:
	call	get_moffs8_ebp_param

	stosb
	jmp		_ml_mr_ebpo8_nxt_2_

_ml_mr_ebpo8_gl_:
	call	get_moffs8_ebp_local

	stosb
_ml_mr_ebpo8_nxt_2_: 
	sub		ecx, 03														;etc 
	jmp		_chk_instr_
;==============================[MOV DWORD PTR [ebp +- XXh], REG32]=======================================


 
;==============================[MOV DWORD PTR [ebp +- XXh], IMM32]=======================================
;MOV	DWORD PTR [EBP - 08h], 01			etc	(0C7h 45h XXh XXXXXXXXh)
;MOV	DWORD PTR [EBP + 14h], 05			etc (0C7h 45h XXh XXXXXXXXh)
;MOV	DWORD PTR [EBP - 1Ch], 12345678h	etc	(0C7h 45h XXh XXXXXXXXh)
;etc
;!!!!! �᫨ ���⥫��� ������� ������� ��� � � moffs32, ⮣�� �������� ����� �㦭� ���; 
mov___m32ebpo8__imm32:
	cmp		ecx, 07														;�᫨ ���-�� ��⠢���� ���⮢ ����� 7, ⮣�� ��室��
	jl		_chk_instr_

	call	check_local_param_num										;����, �롥६ ��砩�� ���� ������� ��६����, ���� �室�� ��ࠬ���� � �஢�ਬ ��⥫쭮 ���� �� ��� ��ਠ�⮢; 

	inc		eax
	je		_chk_instr_													;�᫨ eax == -1, � �� ��室; 
	dec		eax
	xchg	eax, edx
	mov		ax, 45C7h													;write 2 bytes; 
	stosw

	xchg	eax, edx													;eax = 0 ���� 4;
	call	write_moffs8_for_ebp										;ᣥ��ਬ � ����襬 �������� ��६����� ��� �室��� ��ࠬ��� ��� ebp, ���ਬ��, [ebp - 14h] ��� [ebp + 1Ch] - -14h - �����쭠� ��६�����, � 1Ch - �室��� ��ࠬ���; 

	mov		eax, 1000h													;ᣥ��ਬ ��; 
	call	get_rnd_num_1

	inc		eax															;�� >= 1;
	stosd																;����襬 ���
	sub		ecx, 07														;᪮�४��㥬 ����稪
	jmp		_chk_instr_ 												;� �멤��; 
;==============================[MOV DWORD PTR [ebp +- XXh], IMM32]=======================================

 

;====================[ADC/ADD/AND/OR/SBB/SUB/XOR REG32, DWORD PTR [ebp +- XXh]]==========================
;ADC	EAX, DWORD PTR [EBP - 04h]	etc	(13h XXh XXh)
;ADD	ECX, DWORD PTR [EBP + 08h]	etc (03h XXh XXh)
;AND	EDX, DWORD PTR [EBP - 0Ch]	etc	(23h XXh XXh)
;OR		EBX, DWORD PTR [EBP + 10h]	etc (0Bh XXh XXh)
;SBB	ESI, DWORD PTR [EBP - 14h]	etc (1Bh XXh XXh)
;SUB	EDI, DWORD PTR [EBP + 18h]	etc (2Bh XXh XXh)
;XOR	EAX, DWORD PTR [EBP - 1Ch]	etc (33h XXh XXh)
;etc
;!!!!! �᫨ ���⥫��� ������� ������� ��� � � moffs32, ⮣�� �������� ����� �㦭� ���; 
adc_add_and_or_sbb_sub_xor___r32__m32ebpo8:

OFS_XOR_33h_r32_m32ebpo8		equ		05
OFS_ADD_03h_r32_m32ebpo8		equ		55
OFS_SUB_2Bh_r32_m32ebpo8		equ		35
OFS_AAAOSSX_r32_m32ebpo8		equ		05

	cmp		ecx, 03
	jl		_chk_instr_

	call	check_local_param_num										;����, �롥६ ��砩�� ���� ������� ��६����, ���� �室�� ��ࠬ���� � �஢�ਬ ��⥫쭮 ���� �� ��� ��ਠ�⮢; 

	inc		eax
	je		_chk_instr_													;�᫨ eax == -1, � �� ��室; 
	dec		eax
	xchg	eax, edx

	push	(OFS_XOR_33h_r32_m32ebpo8 + OFS_ADD_03h_r32_m32ebpo8 + OFS_SUB_2Bh_r32_m32ebpo8 + OFS_AAAOSSX_r32_m32ebpo8) 
	call	[ebx].rang_addr

	cmp		eax, OFS_AAAOSSX_r32_m32ebpo8
	jl		_aaaossx_r32_m32ebpo8_
	cmp		eax, (OFS_AAAOSSX_r32_m32ebpo8 + OFS_SUB_2Bh_r32_m32ebpo8)
	jl		_sub_r32_m32ebpo8_
	cmp		eax, (OFS_AAAOSSX_r32_m32ebpo8 + OFS_SUB_2Bh_r32_m32ebpo8 + OFS_ADD_03h_r32_m32ebpo8)
	jge		_xor_r32_m32ebpo8_
_add_r32_m32ebpo8_:														;[ADD REG32, DWORD PTR [EBP +- XXh]]
	mov		al, 03h
	jmp		_aaaossx_r32_m32ebpo8_nxt_1_
_xor_r32_m32ebpo8_:														;[XOR REG32, DWORD PTR [EBP +- XXh]]
	mov		al, 33h
	jmp		_aaaossx_r32_m32ebpo8_nxt_1_
_sub_r32_m32ebpo8_:														;[SUB REG32, DWORD PTR [EBP +- XXh]]
	mov		al, 2Bh
	jmp		_aaaossx_r32_m32ebpo8_nxt_1_
_aaaossx_r32_m32ebpo8_:													;�� ��⠫�� ������, ����㯭� � ������ �������樨/��㯯�; 
	push	07
	call	[ebx].rang_addr

	shl		eax, 03
	add		al, 03
_aaaossx_r32_m32ebpo8_nxt_1_:
	stosb																;opcode

	call	get_free_r32

	shl		eax, 03
	add		al, 45h
	stosb 																;modrm

	xchg	eax, edx													;eax = 0 ���� 4;
	call	write_moffs8_for_ebp										;ᣥ��ਬ � ����襬 �������� ��६����� ��� �室��� ��ࠬ��� ��� ebp, ���ਬ��, [ebp - 14h] ��� [ebp + 1Ch] - -14h - �����쭠� ��६�����, � 1Ch - �室��� ��ࠬ���; 

	sub		ecx, 03														;���४��㥬 ����稪
	jmp		_chk_instr_ 												;�� ��室 
;====================[ADC/ADD/AND/OR/SBB/SUB/XOR REG32, DWORD PTR [ebp +- XXh]]==========================



;====================[ADC/ADD/AND/OR/SBB/SUB/XOR DWORD PTR [ebp +- XXh], REG32]==========================
;ADC	DWORD PTR [EBP + 04h], EAX	etc (11h XXh XXh)
;ADD	DWORD PTR [EBP - 08h], ECX	etc (01h XXh XXh)
;AND	DWORD PTR [EBP + 0Ch], EDX	etc (21h XXh XXh)
;OR		DWORD PTR [EBP - 10h], EBX	etc	(09h XXh XXh)
;SBB	DWORD PTR [EBP + 14h], ESI	etc (19h XXh XXh)
;SUB	DWORD PTR [EBP - 18h], EDI	etc (29h XXh XXh)
;XOR	DWORD PTR [EBP + 1Ch], EAX	etc (31h XXh XXh)
;etc
;!!!!! �᫨ ���⥫��� ������� ������� ��� � � moffs32, ⮣�� �������� ����� �㦭� ���; 
adc_add_and_or_sbb_sub_xor___m32ebpo8__r32:

OFS_XOR_33h_m32ebpo8_r32		equ		05
OFS_ADD_03h_m32ebpo8_r32		equ		55
OFS_SUB_2Bh_m32ebpo8_r32		equ		35
OFS_AAAOSSX_m32ebpo8_r32		equ		05

	cmp		ecx, 03														;�᫨ ���-�� ��⠢���� ���⮢ ��� �����樨 ���� ����� 3, ⮣�� ��室�� 
	jl		_chk_instr_

	call	check_local_param_num										;����, �롥६ ��砩�� ���� ������� ��६����, ���� �室�� ��ࠬ���� � �஢�ਬ ��⥫쭮 ���� �� ��� ��ਠ�⮢; 

	inc		eax
	je		_chk_instr_													;�᫨ eax == -1, � �� ��室; 
	dec		eax
	xchg	eax, edx

	push	(OFS_XOR_33h_m32ebpo8_r32 + OFS_ADD_03h_m32ebpo8_r32 + OFS_SUB_2Bh_m32ebpo8_r32 + OFS_AAAOSSX_m32ebpo8_r32)
	call	[ebx].rang_addr

	cmp		eax, OFS_AAAOSSX_m32ebpo8_r32
	jl		_aaaossx_m32ebpo8_r32_
	cmp		eax, (OFS_AAAOSSX_m32ebpo8_r32 + OFS_SUB_2Bh_m32ebpo8_r32)
	jl		_sub_m32ebpo8_r32_
	cmp		eax, (OFS_AAAOSSX_m32ebpo8_r32 + OFS_SUB_2Bh_m32ebpo8_r32 + OFS_ADD_03h_m32ebpo8_r32)
	jge		_xor_m32ebpo8_r32_
_add_m32ebpo8_r32_:														;[ADD DWORD PTR [EBP +- XX], REG32]
	mov		al, 01h
	jmp		_aaaossx_m32ebpo8_r32_nxt_1_
_xor_m32ebpo8_r32_:														;[XOR DWORD PTR [EBP +- XX], REG32]
	mov		al, 31h 
	jmp		_aaaossx_m32ebpo8_r32_nxt_1_
_sub_m32ebpo8_r32_:														;[SUB DWORD PTR [EBP +- XX], REG32]
	mov		al, 29h
	jmp		_aaaossx_m32ebpo8_r32_nxt_1_
_aaaossx_m32ebpo8_r32_:													;other + this is; 
	push	07
	call	[ebx].rang_addr
	
	shl		eax, 03
	add		al, 01
_aaaossx_m32ebpo8_r32_nxt_1_:
	stosb																;opcode

	call	get_free_r32												;����砥� ��砩�� ᢮����� ॣ; 

	shl		eax, 03
	add		al, 45h
	stosb																;modrm

	xchg	eax, edx													;eax = 0 ���� 4;
	call	write_moffs8_for_ebp										;ᣥ��ਬ � ����襬 �������� ��६����� ��� �室��� ��ࠬ��� ��� ebp, ���ਬ��, [ebp - 14h] ��� [ebp + 1Ch] - -14h - �����쭠� ��६�����, � 1Ch - �室��� ��ࠬ���; 

	sub		ecx, 03														;���४��㥬 ����稪
	jmp		_chk_instr_ 												;�� ��室 
;====================[ADC/ADD/AND/OR/SBB/SUB/XOR DWORD PTR [ebp +- XXh], REG32]==========================
 


;==================[ADC/ADD/AND/OR/SBB/SUB/XOR DWORD PTR [ebp +- XXh], IMM32/IMM8]=======================
;ADC	DWORD PTR [EBP + 04h], 01		etc (83h XXh XXh XXh)
;ADD	DWORD PTR [EBP - 08h], 123h		etc (81h XXh XXh XXXXXXXXh)
;etc
;!!!!! �᫨ ���⥫��� ������� ������� ��� � � moffs32, ⮣�� �������� ����� �㦭� ���; 
adc_add_and_or_sbb_sub_xor___m32ebpo8__imm32_imm8:
																		;m32ebpo8 - mem32 ebp offset32
OFS_AAAOSSX_83h_m32ebpo8_imm8		equ		35							
OFS_AAAOSSX_81h_m32ebpo8_imm32		equ		15

	cmp		ecx, 07														;�᫨ ���-�� ��⠢���� ���⮢ ��� �����樨 ���� ����� 3, ⮣�� ��室�� 
	jl		_chk_instr_

	call	check_local_param_num										;����, �롥६ ��砩�� ���� ������� ��६����, ���� �室�� ��ࠬ���� � �஢�ਬ ��⥫쭮 ���� �� ��� ��ਠ�⮢; 

	inc		eax
	je		_chk_instr_													;�᫨ eax == -1, � �� ��室; 
	dec		eax
	xchg	eax, edx
	xor		esi, esi

	push	(OFS_AAAOSSX_83h_m32ebpo8_imm8 + OFS_AAAOSSX_81h_m32ebpo8_imm32)
	call	[ebx].rang_addr
	
	cmp		eax, OFS_AAAOSSX_81h_m32ebpo8_imm32 
	jl		_81h_m32ebpo8_imm32_
_83h_m32ebpo8_imm8_:													;[ADC/etc DWORD PTR [EBP +- XXh], XXh]
	mov		al, 83h
	jmp		_m32ebpo8_imm_
_81h_m32ebpo8_imm32_: 													;[ADC/etc DWORD PTR [EBP +- XXh], XXXXXXXXh] 
	mov		al, 81h 
	add		esi, 03
_m32ebpo8_imm_:
	stosb																;opcode

	push	07
	call	[ebx].rang_addr

	shl		eax, 03
	add		al, 45h
	stosb																;modrm

	xchg	eax, edx													;eax = 0 ���� 4;
	call	write_moffs8_for_ebp										;ᣥ��ਬ � ����襬 �������� ��६����� ��� �室��� ��ࠬ��� ��� ebp, ���ਬ��, [ebp - 14h] ��� [ebp + 1Ch] - -14h - �����쭠� ��६�����, � 1Ch - �室��� ��ࠬ���; 

	mov		eax, 10000h
	call	get_rnd_num_1

 	add		eax, 101h 													;⠪ ��� �� �� �� �����, ����� imm �㤥� (8 ��� 32), � �� ��直� ᤥ���� eax � ��� imm8 � ��� imm32; 
	inc		esi
	xchg	edx, esi 
	sub		ecx, edx
	sub		ecx, 03
_m32ebpo8_imm_stosX_:
	stosb																;imm (8-�� ��� 32-� ࠧ�來��); 
	ror		eax, 08
	dec		edx
	jne		_m32ebpo8_imm_stosX_ 
	jmp		_chk_instr_													;�� ��室; 
;==================[ADC/ADD/AND/OR/SBB/SUB/XOR DWORD PTR [ebp +- XXh], IMM32/IMM8]=======================
 


;==================[CMP REG32/DWORD PTR [EBP +- XXh], DWORD PTR [EBP +- XXh]/REG32]======================
;CMP	EAX, DWORD PTR [EBP - 04h]	etc (3Bh XXh XXh)
;CMP	DWORD PTR [EBP + 08h], ECX	etc (39h XXh XXh)
;etc
;!!!!! �᫨ ���⥫��� ������� ������� ��� � � moffs32, ⮣�� �������� ����� �㦭� ���; 
cmp___r32_m32ebpo8__m32ebpo8_r32:

OFS_CMP_3Bh_r32_m32ebpo8	equ		35
OFS_CMP_39h_m32ebpo8_r32	equ		20

	mov		eax, (300h - 06)
	call	get_rnd_num_1

	add		eax, 06														;��।��塞 ࠧ��� ���� ����� ���ᮬ jxx'a � ���ᮬ, �㤠 �㤥� ᮢ���� ��릮�; ࠧ��� �ᥣ�� >= 6; 
	mov		edx, eax
	add		eax, (03 + 06)												;size of cmp (this instr) + max size of jxx (near); 
	cmp		ecx, eax
	jl		_chk_instr_													;�᫨ ���-�� ��⠢���� ��� ����� ���� ⮢ ����� �㦭��� �᫠, ⮣�� ��室��

	call	check_local_param_num										;����, �롥६ ��砩�� ���� ������� ��६����, ���� �室�� ��ࠬ���� � �஢�ਬ ��⥫쭮 ���� �� ��� ��ਠ�⮢; 

	inc		eax
	je		_chk_instr_													;�᫨ eax == -1, � �� ��室; 
	dec		eax
	xchg	eax, esi													;��࠭�� ���祭�� � esi;

	push	(OFS_CMP_3Bh_r32_m32ebpo8 + OFS_CMP_39h_m32ebpo8_r32)
	call	[ebx].rang_addr                               

	cmp		eax, OFS_CMP_39h_m32ebpo8_r32
	jl		_cmp_39h_m32ebpo8_r32_
_cmp_3Bh_r32_m32ebpo8_:													;[CMP REG32, DWORD PTR [EBP +- XX]]
	mov		al, 3Bh
	jmp		_cmp_rmmr_ebpo8_
_cmp_39h_m32ebpo8_r32_:													;[CMP DWORD PTR [EBP +- XX], REG32]
	mov		al, 39h
_cmp_rmmr_ebpo8_: 
	stosb																;opcode

	call	get_free_r32

	shl		eax, 03
	add		al, 45h
	stosb																;modrm

	xchg	eax, esi													;eax = 0 ���� 4;
	call	write_moffs8_for_ebp										;ᣥ��ਬ � ����襬 �������� ��६����� ��� �室��� ��ࠬ��� ��� ebp, ���ਬ��, [ebp - 14h] ��� [ebp + 1Ch] - -14h - �����쭠� ��६�����, � 1Ch - �室��� ��ࠬ���; 

	sub		ecx, 03														;���४��㥬 ����稪
	cmp		edx, 80h													;� ��।��塞, �� ������� ������ ���室� ��룭�� (short or near); 
	jl		_jsdrel8_entry_ 											;��易⥫쭮 �᫮ ������ ���� � EDX, ⠪ ��� � ���������� ��� ��릪�� ���-�� ���⮢ ��।����� � edx;  
	jmp		_jndrel32_entry_											;etc
;==================[CMP REG32/DWORD PTR [EBP +- XXh], DWORD PTR [EBP +- XXh]/REG32]======================



;===========================[CMP DWORD PTR [EBP +- XXh], IMM32/IMM8]=====================================
;CMP	DWORD PTR [EBP - 04h], 01		etc (83h XXh XXh XXh)
;CMP	DWORD PTR [EBP + 08h], 123h		etc (81h XXh XXh XXXXXXXXh) 
;etc
;!!!!! �᫨ ���⥫��� ������� ������� ��� � � moffs32, ⮣�� �������� ����� �㦭� ���; 
cmp___m32ebpo8__imm32_imm8:

OFS_CMP_83h_m32ebpo8_imm8	equ		35
OFS_CMP_81h_m32ebpo8_imm32	equ		15

	mov		eax, (300h - 06)											;!!!!! ��� ���� cmp etc ������ 6 ���⮢! 
	call	get_rnd_num_1

	add		eax, 06														;��।��塞 ࠧ��� ���� ����� ���ᮬ jxx'a � ���ᮬ, �㤠 �㤥� ᮢ���� ��릮�; ࠧ��� �ᥣ�� >= 6; 
	mov		edx, eax
	add		eax, (07 + 06)												;size of cmp (this instr) + max size of jxx (near); 
	cmp		ecx, eax
	jl		_chk_instr_													;�᫨ ���-�� ��⠢���� ��� ����� ���� ⮢ ����� �㦭��� �᫠, ⮣�� ��室��

	call	check_local_param_num										;����, �롥६ ��砩�� ���� ������� ��६����, ���� �室�� ��ࠬ���� � �஢�ਬ ��⥫쭮 ���� �� ��� ��ਠ�⮢; 

	inc		eax
	je		_chk_instr_													;�᫨ eax == -1, � �� ��室; 
	dec		eax
	push	eax
	xor		esi, esi

	push	(OFS_CMP_83h_m32ebpo8_imm8 + OFS_CMP_81h_m32ebpo8_imm32)
	call	[ebx].rang_addr

	cmp		eax, OFS_CMP_81h_m32ebpo8_imm32
	jl		_cmp_81h_m32ebpo8_imm32_
_cmp_83h_m32ebpo8_imm8_:												;[CMP DWORD PTR [EBP +- XXh], IMM8]
	mov		al, 83h
	jmp		_cmp_83h_81h_m32ebpo8_imm_
_cmp_81h_m32ebpo8_imm32_:												;[CMP DWORD PTR [EBP +- XXh], IMM32]
	mov		al, 81h
	add		esi, 03
_cmp_83h_81h_m32ebpo8_imm_:
	stosb																;opcode (1 byte); 
	mov		al, 7Dh
	stosb																;modrm

	pop		eax															;eax = 0 ���� 4;
	call	write_moffs8_for_ebp										;ᣥ��ਬ � ����襬 �������� ��६����� ��� �室��� ��ࠬ��� ��� ebp, ���ਬ��, [ebp - 14h] ��� [ebp + 1Ch] - -14h - �����쭠� ��६�����, � 1Ch - �室��� ��ࠬ���; 

	mov		eax, 10000h
	call	get_rnd_num_1

	inc		esi
	add		eax, 101h													;�� >= 101h
	sub		ecx, esi
	sub		ecx, 03
_cmp_m32ebpo8_imm_stosX_:
	stosb																;imm (8 or 32); 
	ror		eax, 08
	dec		esi
	jne		_cmp_m32ebpo8_imm_stosX_
	cmp		edx, 80h													;� ��।��塞, �� ������� ������ ���室� ��룭�� (short or near); 
	jl		_jsdrel8_entry_ 											;��易⥫쭮 �᫮ ������ ���� � EDX, ⠪ ��� � ���������� ��� ��릪�� ���-�� ���⮢ ��।����� � edx;  
	jmp		_jndrel32_entry_											;etc
;===========================[CMP DWORD PTR [EBP +- XXh], IMM32/IMM8]=====================================

 

;=====================================[FAKE WINAPI FUNC]=================================================
;call	dword ptr [402008]	etc	(0FFh XXh XXXXXXXXh) 					;���ਬ��, �� ��� ���� �맮� GetVersion etc; 

;push	403008h															;address of string; 
;call	lstrlenA
;
;etc 
xwinapi_func:
	cmp		ecx, WINAPI_MAX_SIZE										;᭠砫� �஢�ਬ� 墠�� �� ��� ��⠢���� ���⮢ ��� �����樨 ������� �맮�� ������誨; 
	jl		_chk_instr_ 
	mov		edx, [ebx].faka_struct_addr
	assume	edx: ptr FAKA_FAKEAPI_GEN 
	cmp		[ebx].faka_addr, 0											;⥯��� �஢�ਬ, ��।�� �� ���� �� ������ �����樨 ������ ������襪 (���ਬ��, FAKA); 
	je		_chk_instr_
	test	edx, edx 													;��।��� �� �������, ����室���� ��� �ࠢ��쭮� ࠡ��� ������� ��-������
	je		_chk_instr_               
	mov		esi, [edx].xfunc_struct_addr
	cmp		[ebx].fmode, XTG_REALISTIC									;⥯��� ��ᬮ�ਬ, ����� ᥩ�� ���� ०�� �����樨 ������
																		;��� ��� ����� ��: �᫨ ०�� XTG_MASK, � �� ����� - ����� ������ ������� �筮 ����� ������� (�����, �᫨ �� � ��ࠬ���� �ࠢ����);
																		;�᫨ �� �� ०�� XTG_REALISTIC, ⮣�� �㦭� �� �஢����, ���⠢��� �� ᯥ�-䫠� ��� �����樨 ������襪?
																		;��� ������ ����� � ⠡��� ࠧ��஢ ������ � ���� �� �������, � ⠪�� � ⠡��� ���室�� �ᯮ������ ��� �����-� ����஬. 
																		;��᪠� �� �㤥� #45. ��� ���, �᫨ �� ����祭 XTG_MASK � 䫠� XTG_MASK_WINAPI (� � ���� #45), ⮣�� �筮 ����� ������� ������, 
																		;⠪ ��� ����� ��������� 45 == 45. �᫨ �� �� ०�� XTG_REALISTIC, �� �� �뫮 䫠�� XTG_REALISTIC_WINAPI, � �� ��� �� �㤥� �஢����� ������ ⠪, ��� �����, 
																		;⮣�� ������ ���� �����஢�����. �᫨ �� �஢����� ᯥ�. ��ࠧ�� (��� �����) ����� 䫠�, ⮣�� ��� 稪�-�㪨; 
	jne		_xwf_nxt1_
	test	[ebx].xmask1, XTG_REALISTIC_WINAPI
	je		_chk_instr_
	test	[ebx].xmask1, XTG_FUNC										;�᫨ ᥩ�� �⮨� ०�� XTG_REALISTIC, � ���⠢��� 䫠� XTG_FUNC - ⮣�� �㭪� (� �஫����� etc) �㤥� ������� xTG, � ����� 
	je		_xwf_nxt1_ 													;���⠢�� ���� ᢮�� �������� XTG_FUNC_STRUCT; ���� ������� �㭮� �ந�室�� �����-� ��㣨� �������/���㫥�; ��� ����� �����; 
	mov		eax, [ebx].xfunc_struct_addr
	mov		[edx].xfunc_struct_addr, eax

_xwf_nxt1_: 
	push	[edx].tw_api_addr 
	push	[edx].api_size
	push	[edx].api_hash

	mov		[edx].tw_api_addr, edi
	mov		[edx].api_size, WINAPI_MAX_SIZE
	push	[ebx].faka_struct_addr
	call	[ebx].faka_addr

	add		edi, [edx].nobw 
	sub		ecx, [edx].nobw
	pop		[edx].api_hash
	pop		[edx].api_size
	pop		[edx].tw_api_addr
	mov		[edx].xfunc_struct_addr, esi
	jmp		_chk_instr_
;=====================================[FAKE WINAPI FUNC]=================================================
 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;����� �㭪� xtg_main 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx




	
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;�㭪�� get_minsize_instr
;����祭�� ࠧ��� "ᠬ�� ���⪮�", ࠧ�襭��� ��� �����樨, ������樨/�������樨
;����:
;	EBX					-	���� �������� XTG_TRASH_GEN
;	� ��㣨� ��ࠬ���� (� xm_struct2_addr - ���� �������� XTG_EXT_TRASH_GEN etc);
;�����:
;	xm_minsize_instr	-	ࠧ��� "ᠬ�� ���⪮�" ����㯭�� ������樨/�������樨;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
get_minsize_instr:
	pushad
	mov		ecx, xm_struct2_addr
	assume	ecx: ptr XTG_EXT_TRASH_GEN 
	mov		ecx, [ecx].ofs_addr
	xor		edx, edx
	mov		xm_minsize_instr, MAX_SIZE_INSTR							;᭠砫� ���樠�����㥬 ��६����� ᠬ� ����訬 ࠧ��஬ ����㯭�� ������樨/�������樨
_nxtsi1_:
	cmp		[ebx].fmode, XTG_REALISTIC									;�᫨ ०�� �����樨 ���� - "�� ��᪥", 
	je		_cmsi1_
	mov		eax, edx													;⮣�� ᯥࢠ �஢�ਬ, ����㯭� �� ��� �����樨 ��।��� ��������
	
	call	check_mask
	
	jnc		_nxtsi2_
_cmsi1_:																;�᫨ �� �������� ����㯭� (� � ��砥 ०��� "ॠ����筮���" ����㯭� (����) �� �������), � 
	mov		eax, dword ptr [ecx + edx * 4]								;��६ ��।��� dword
	shr		eax, 16														;���㤠 ��६ ࠧ���
	cmp		xm_minsize_instr, eax										;� �ࠢ������, �᫨ ���祭�� � ��६����� ����� ⥪�饣� ���祭�� � EAX, ⮣�� ��࠭�� ���祭��, ���஥ � EAX
	jle		_nxtsi2_
	mov		xm_minsize_instr, eax
_nxtsi2_:
	inc		edx															;���室�� � �ࠢ����� ᫥����� ���祭��;
	cmp		edx, NUM_INSTR 
	jne		_nxtsi1_
	popad
	ret
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;����� �㭪� get_minsize_instr
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
	 


;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;�㭪� check_instr
;�஢�ઠ, ����� �� �����஢��� ��।������� ��������
;����:
;	EAX		-	�᫮ - ���浪��� ����� ������樨 � ⠡��� (� ⠡��� ����⨪� ���� ������� � ࠧ��஢ ������)
;	EBX		-	���� �������� XTG_TRASH_GEN
;	� ��. (ᬮ�� ���);
;�����:
;	EAX		-	�᫨ ������� ����� �����஢���, ⮣�� EAX ��࠭�� ᢮� ��砫쭮� �室��� ���祭��, ���� -1;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
check_instr:
	pushad
	mov		edx, xm_struct2_addr
	assume	edx: ptr XTG_EXT_TRASH_GEN 
	mov		edx, [edx].ofs_addr											;EDX - ���� ⠡��窨 ����⨪� ���� ������� � ࠧ��஢ ������
	mov		edx, dword ptr [edx + eax * 4]								;��६ ����� ������ � ࠧ��� �㦭��� ��� ������; 	
	movzx	edx, dx 													;EDX - ���� ������ �㦭��� ��� ������ (�������);
	cmp		[ebx].fmode, XTG_REALISTIC									;�஢��塞, ����� ०�� �����樨 ���� ᥩ�� �⮨�
	jne		_fmode_mask_

_fmode_realistic_: 														;�᫨ ᥩ�� ०�� "ॠ����筮���", 
	push	MAX_STAT													;⮣�� ᣥ����㥬 ��砩��� �᫮ � ��������� [0..MAX_STAT - 1]; MAX_STAT - ���ᨬ��쭠� ���� ������ ������ - ���� ������ - �� equ 100%;
	call	[ebx].rang_addr
	
	cmp		edx, eax													;�᫨ ���� �㦭��� ��� ������ ����� �믠�襣� ��砩���� �᫠ (�⮡� �������樨 � 0-�� ���⮩ ⮦� ��室���, �����塞 �� jge), ⮣�� �������� ����� �����஢���; 
	jg		_ci_final_ 													;�� � ���� ������᪨� ��⮤� - �롮� ���. ����⭮�⥩;
	jmp		_not_ci_

_fmode_mask_:															;�᫨ ᥩ�� ०�� "��᪠", ⮣�� �஢�ਬ ���� - 㪠���� �� � ���, �� ����� �����஢��� ����� ����� (�������)?
	call	check_mask
	
	jc		_ci_final_  												;�᫨ ��, � ��室��
_not_ci_:	
	or		dword ptr [esp + 1Ch], -01									;���� �� ��室� �� ������ �㭪� EAX = -1;  	 
_ci_final_:
	popad
	ret 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;����� �㭪� check_instr
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;�㭪� check_mask
;�஢�ઠ ������� �� ��᪥ - ����� �� ������� ��࠭��� ������� ��� ���
;����:
;	EAX		-	�᫮ - ������ � ��᪥ ���, ����� �㦭� �஢����; 
;	EBX		-	������� XTG_TRASH_GEN
;�����:
;	�᫨ ������� ����� �������, ⮣�� �㤥� ������ 䫠� CF = 1, ���� CF = 0; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
check_mask:
_xmask1_:
	cmp		eax, 31
	jg		_xmask2_
	bt		[ebx].xmask1, eax 
	ret
_xmask2_:
	sub		eax, (31 + 01) 
	bt		[ebx].xmask2, eax
	ret
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;����� �㭪� check_mask 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;�㭪a check_data 
;�஢�ઠ ���� � ࠧ��� ������ �� ����������; 
;����:
;	EBX		-	XTG_TRASH_GEN 
;	etc
;�����:
;	EAX		-	1, �᫨ ����� �� (��� �����樨 ������) ��।����� ������� ������, ���� 0; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
check_data:
	xor		eax, eax 
	push	esi
	mov		esi, [ebx].xdata_struct_addr
	assume	esi: ptr XTG_DATA_STRUCT
	test	esi, esi													;�᫨ ������ ���� = 0, ����� ������� ����� �� �뫠 ��।���;
	je		_cd_ret_
	cmp		[esi].xdata_addr, 00h										;�᫨ ���� ��砫� ������ ������ (ᥪ樨 ������) ࠢ�� ���, 
	je		_cd_ret_													;� �� ��室;
	cmp		[esi].xdata_size, 04h										;���� �᫨ ࠧ��� ������ (ᥪ樨) ������ ����� 4-�, ⮣�� �� ��室; 
	jb		_cd_ret_ 
	inc		eax															;���� ��� �⫨筮=)! 
_cd_ret_:
	pop		esi 
	ret
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;����� �㭪� check_data
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;�㭪a get_rnd_data_va   
;����祭�� ��砩���� ���� (VA) � ᥪ樨 ������. ���砩�� ���� ��⥭ �����; 
;����:
;	ebx		-	etc
;	etc
;�����:
;	eax		-	��砩�� ����, ���� 4 (�� �᫮���, �� xdata_addr (VirtualAddress) - �� ��⥭ 4); 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
get_rnd_data_va:
	push	edx															;��࠭塞 edx � �⥪�
	push	esi
	mov		esi, [ebx].xdata_struct_addr
	assume	esi: ptr XTG_DATA_STRUCT
	mov		eax, [esi].xdata_size 										;eax = ࠧ��� ᥪ樨 ������ (������ ������); 
	sub		eax, 04														;�⭨���� 4, �⮡� ��砩�� �� ������� �� �㦨� ����; 

	push	eax 
	call	[ebx].rang_addr												;����砥� �� [0..xdata_size - 4 - 1]

	mov		edx, eax
	and		edx, 03
	sub		eax, edx													;������ ����祭��� ���祭�� ���� �����; 
	add		eax, [esi].xdata_addr										;������塞 ����;
	pop		esi
	pop		edx															;����⠭�������� edx; 
	ret 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;����� �㭪� get_rnd_data_va 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;�㭪a get_rnd_num_1 
;����祭�� �� �� �����ன ��᪥;
;����:
;	EAX		-	�᫮ N;
;�����:
;	EAX		-	�� � ��������� [0..N-1]; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
get_rnd_num_1:
	push	edx 

	push	eax
	call	[ebx].rang_addr

	xchg	eax, edx

	push	edx
	call	[ebx].rang_addr

	and		eax, edx
	pop		edx
	ret
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;����� �㭪� get_rnd_num_1
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

		

;====================================[FUNCTIONS FOR CYCLES]==============================================

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;�㭪�� init_cnt_for_cycle
;���樠������ ����稪� (ॣ����)
;���� ����㯭� ��� ⠪�� ��ਠ���:
;1) push imm8	pop reg32
;2) mov reg32, imm32
;����:
;	ECX			-	���-�� ��⠢���� ��� ����� ���� ���⥪�� (��� ����設�⢠ �㭪権 �� ⮦� �⭮���� etc); 
;	EBX			-	���� �������� XTG_TRASH_GEN
;	xm_tmp_reg1	-	�᫮ - ����� ॣ���� (XM_EAX etc) - ����稪 � 横��; 
;�����:
;	������� ����� �� ����㯭�� ������権;
;	���४�஢�� �������� ���祭�� (ECX etc);
;	EAX			-	�᫮ - ��砫쭮� ���祭�� ����稪� (EAX = imm8 ��� imm32 � ����ᨬ���, �� ᣥ��ਫ���); 	  
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
init_cnt_for_cycle:
	push	02
	call	[ebx].rang_addr

	test	eax, eax													;"��砩��" ��ࠧ�� ��।��塞, ����� ������� �㤥� �����஢���; 
	je		_push___imm8____pop___r32_

_mov___r32__imm32_:														;MOV REG32, IMM32		
	mov		eax, xm_tmp_reg1
	add		al, 0B8h
	stosb																;opcode - 1 byte;

	push	1000h
	call	[ebx].rang_addr 

	add		eax, 81h													;IMM32 = [0x81..0x1000 - 0x01 + 0x81];
	stosd
	sub		ecx, 05														;���४��㥬;
	ret

_push___imm8____pop___r32_:												;PUSH IMM8	POP REG32
	mov		al, 6Ah
	stosb

	push	7Eh
	call	[ebx].rang_addr

	inc		eax															;IMM8 = [0x02..0x7F]
	inc		eax
	stosb
	push	eax
	mov		eax, xm_tmp_reg1 
	add		al, 58h
	stosb
	pop		eax
	sub		ecx, 03
	ret
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;����� �㭪� init_cnt_for_cycle 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;�㭪a chg_cnt_for_cycle
;��������� ����稪� (ॣ����) � 横�� (㢥��祭��/㬥��襭��) 
;���� ����㯭� ��� ⠪�� ��ਪ�:
;1) add/sub reg32, imm8
;2) inc/dec reg32
;����:
;	EBX			-	� ��� =)!
;	xm_tmp_reg1	-	�᫮ - ����� ॣ���� (XM_EAX etc); 
;�����:
;	EAX			-	���� � ����, ��� ����ᠭ� ������� ��������� ���稪� � 横��;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
chg_cnt_for_cycle:
	push	edx															;��࠭塞 � ��� ���祭�� EDX; 

	push	02
	call	[ebx].rang_addr												;����稬 0 ��� 1

	xchg	eax, edx													;��࠭�� �� � edx

	push	02
	call	[ebx].rang_addr

	test	eax, eax													;����� ��砩�� �롥६, ����� ������� �㤥� �����஢���
	je		_inc_dec___r32_  
_add_sub___r32__imm8_:													;ADD/SUB REG32, IMM8
	mov		al, 83h
	push	edi
	stosb
	mov		eax, 0C0h;�� al, � eax!;									;ADD -> modrm = [0xC0..0xC7]; SUB -> MODRM = [0xE8..0xEF]  
	imul	edx, edx, 05
	shl		edx, 03
	add		eax, edx
	add		eax, xm_tmp_reg1
	stosb

	push	05;(256 - 3) 
	call	[ebx].rang_addr

	add		eax, 03														;IMM8 = [0x03..0x05 - 0x01 + 0x03]; 
	stosb
	pop		eax
	sub		ecx, 03
	pop		edx
	ret

_inc_dec___r32_:														;INC/DEC REG32
	mov		eax, 40h
	shl		edx, 03
	add		eax, edx
	add		eax, xm_tmp_reg1
	push	edi
	stosb
	pop		eax
	dec		ecx
	pop		edx
	ret
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;����� �㭪� chg_cnt_for_cycle  
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;�㭪a cmp_for_cycle  
;�ࠢ����� ����稪� � 横�� � ��㣨� ॣ���஬ ��� �᫮�;
;���� ����㯭� ��� ⠪�� ��㪨:
;1) cmp reg32_1, reg32_2
;2) cmp reg32, imm8 
;3) cmp reg32, imm32
;����:
;	EBX, ECX		-	etc;
;	EAX				-	�᫮ - ��砫쭮� ���祭�� ����稪� (IMM8 ��� IMM32), ����祭��� ��᫥ �맮�� �㭪� init_cnt_for_cycle; 
;	EDX				-	0 ��� 1; 0 - ����稪 㢥��稢����� ��� 1 - ����稪 㬥��蠥���; (㧭��� ��᫥ �맮�� chg_cnt_for_cycle); 
;	xm_tmp_reg1		-	�᫮ - ����� ॣ���� (XM_EAX etc) - �� � ���� ����稪 (� 横��);
;	xm_tmp_reg2		-	�᫮ - ����� 2-��� ॣ���� - �᫨ ࠢ�� -1, ⮣�� �� ��६����� �� ����; 
;�����:
;	(+); 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
cmp_for_cycle:
	cmp		xm_tmp_reg2, -01											;�᫨ ����� -1, ⮣�� ��९�룭��; 
	je		_c4c_nxt_1_ 												;⠪�� �ந�室�� ⮣��, ����� �� �� ᣥ���஢��� ���樠������ ����稪� (�� �맢��� �㭪� init_cnt_for_cycle); 
								
_cmp___r32__r32_:														;� ⠪�� ���樨 ᣥ��ਬ ������� CMP REG32_1, REG32_2 (REG32_1 != REG32_2); 
	mov		al, 3Bh
	stosb
	mov		eax, xm_tmp_reg1
	shl		eax, 03
	add		al, 0C0h
	add		eax, xm_tmp_reg2
	stosb
	dec		ecx
	dec		ecx
	ret

_c4c_nxt_1_:															;����
	push	edx 
	push	esi
	xchg	eax, esi
	test	edx, edx													;᭠砫� ��।����, 㢥��稢����� ��� 㬥��蠥��� ��� ����稪?
	jne		_c4c_sub_cnt_

_c4c_add_cnt_:															;�᫨ ����稪 㢥��稢�����, 
	push	1000h														;⮣�� �ࠢ�������� ���祭�� (imm8 ��� imm32) ������ ���� ����� ���祭�� ����稪�; 
	call	[ebx].rang_addr												;� ����, ���ਬ��, �᫨ ����稪 � ��� - �� ॣ���� ECX, � �� ࠢ�� 5, ⮣�� IMM (8 ��� 32) ������ ���� > 5; -> cmp ecx, 7 etc; 
	
	xchg	eax, edx
	
	push	edx
	call	[ebx].rang_addr

	and		eax, edx

	lea		eax, dword ptr [eax + esi + 01]								;
	jmp		_c4c_nxt_2_  
_c4c_sub_cnt_:															;�᫨ �� ����稪 㬥��蠥���, ⮣�� �ࠢ�������� ���祭�� ������ ���� ����� ���祭�� ����稪�, ���ਬ��, 
	dec		esi 														;�᫨ ����稪 - �� ecx � �� = 5, ⮣�� imm (8 ��� 32) < 5, �� > 0; 

	push	esi
	call	[ebx].rang_addr

	inc		eax
_c4c_nxt_2_:
	xchg	eax, esi
	cmp		esi, 80h													;� ��� ⥯��� ���� �� �ࠢ�������� �᫮, ⥯��� ��।����, �� imm8 ��� imm32? 
	jl		_cmp___r32__imm8_											;�᫨ ������ ���祭�� < 80h, ����� �� imm8, ���� �� imm32; 
_c4c_cmp___r32__imm32_:													;�᫨ �� �� imm32, ⮣�� ��।����, ����稪 - �� ॣ���� � �����? 
	cmp		xm_tmp_reg1, XM_EAX											;�᫨ �� ����稪 - �� ॣ���� EAX, ⮣�� ᣥ��ਬ "᮪����" ��ਠ�� ������� �ࠢ�����; 
	je		_cmp___eax__imm32_
_cmp___r32__imm32_:														;����, ᣥ����㥬 CMP REG32, IMM32; (REG32 != EAX);
	mov		al, 81h
	stosb
	mov		eax, xm_tmp_reg1
	add		al, 0F8h 
	stosb
	xchg	eax, esi
	stosd
	jmp		_cmp___r32__imm32_ret_
_cmp___eax__imm32_:														;CMP EAX, IMM32; 
	mov		al, 3Dh
	stosb
	xchg	eax, esi
	stosd
	inc		ecx
_cmp___r32__imm32_ret_:
	sub		ecx, 6
	pop		esi
	pop		edx
	ret	 

_cmp___r32__imm8_:														;CMP REG32, IMM8; 
	mov		al, 83h
	stosb
	mov		eax, xm_tmp_reg1
	add		al, 0F8h
	stosb
	xchg	eax, esi
	stosb
	sub		ecx, 03
	pop		esi
	pop		edx
	ret
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;����� �㭪� cmp_for_cycle  
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx


	
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;�㭪� get_num_free_r32   
;����祭�� ���-�� ᢮������ 32-� ࠧ�來�� ॣ���஢; 
;����:
;	ECX, EBX	-	etc;
;�����:
;	EAX			-	������⢮ ᢮������ 32-� ࠧ�來�� ॣ���஢; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
get_num_free_r32:
	push	edx
	push	esi
	xor		edx, edx
	xor		esi, esi
_gnfr32_cycle_:	
	mov		eax, edx

	call	check_r														;��뢠�� �㭪�, ��।�������, ᢮����� ��� ����� ॣ? 

	inc		eax															;�᫨ ��᫥ �맮�� ������ �㭪樨 EAX == -1, ⮣�� ॣ���� �����, ���� ॣ ᢮�����; 
	je		_gnfr32_nxt_1_
	inc		esi
_gnfr32_nxt_1_:
	inc		edx
	cmp		edx, 8
	jne		_gnfr32_cycle_ 
	xchg	eax, esi
	pop		esi
	pop		edx 
	ret 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;����� �㭪� get_num_free_r32  
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

;====================================[FUNCTIONS FOR CYCLES]==============================================



;============================[FUNCTIONS FOR INSTR WITH EBP & moffs8]=====================================
;!!!!! �᫨ ���⥫��� ������� ������� ��� � � moffs32, ⮣�� �������� ����� (� ��� �㭪���) �㦭� ���; 
;!!!!! ������� � moffs32 ����� ������� ��㣮� ���� � ࠧ��� ����� ������, ⠪ � ����;  
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;�㭪a check_local_param_num
;�஢�ઠ �� ���४⭮��� ���-�� �������� ��६����� � �室��� ��ࠬ��஢
;� ⠪�� ��砩�� �롮�, ����� �� 2-� ��ਠ�⮢ �㤥� 祪��� ��⥫쭥� ��� ��᫥���饩 ��� �����樨; 
;����:
;	ebx						-	etc
;	[ebx].xfunc_struct_addr	-	���� �������� XTG_FUNC_STRUCT, �� ���� �㤥� �஢�����; 
;�����:
;	eax						-	-1, �᫨ �஢�ઠ �� �ன���� �ᯥ譮, ���� 0 (�᫨ ��࠭� ������� 
;								��६����) ���� 4 (�᫨ �室�� ��ࠬ����);
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
check_local_param_num: 	
	push	edx															;��࠭塞 � �⥪� ॣ�; 
	push	esi 

	push	02
	call	[ebx].rang_addr												;��砩�� �롨ࠥ�, ����� �� ��ਠ�⮢ �㤥� ��⥫쭥� �஢����� � � ���쭥�襬 �������: �������� ��६����� [ebp - XXh] ��� �室��� ��ࠬ��� [ebp + XXh];   

	shl		eax, 02														;eax = 0 ��� 4; 
	lea		edx, dword ptr [eax + 01]									;edx > 0; 
	mov		esi, [ebx].xfunc_struct_addr
	assume	esi: ptr XTG_FUNC_STRUCT									;esi - address of struct XTG_FUNC_STRUCT; 
	test	esi, esi													;�᫨ ����� 0, ⮣�� �������� ���, � ����� �� �� ����ਬ �㭪�, � ���⮬� ������� ������ � ���⨥� ebp - �� ��ਠ�� ������, ��� �������� �� � ������ ��� ��; 
	je		_clp_fuck_
	cmp		[esi].local_num, (84h / 04)									;���� �஢�ਬ, �᫨ ���-�� �������� ��६����� ����� ������� ���祭��, ⮣�� �멤�� - ⠪ ��� ��� ⠪�� ���樨 ������ ��������� ��㣨� ������. ��� ��ਠ�� ����� ���� �������� ����������� �����樨 ��� ������� � ���; 
	jge		_clp_fuck_
	cmp		[esi].param_num, (80h / 04)									;etc
	jge		_clp_fuck_
	test	eax, eax
	je		_clp_local_
_clp_param_:															;�᫨ ��࠭� �஢�ઠ � ��᫥����� ������� �室��� ��ࠬ���஢, ⮣�� �஢�ਬ, ����� ���� �� �室�� ��ࠬ���� � ������ �������? 
	imul	edx, [esi].param_num
	jmp		_clp_nxt_1_
_clp_local_:
	imul	edx, [esi].local_num										;�� ��� �������� ��६�����; 
_clp_nxt_1_:
	test	edx, edx 													;⥯��� �஢�ਬ edx - �᫨ �� = 0 (� ����, ���ਬ��, �᫨ ��ࠫ� �����. ��६., � �� ���-�� = 0 - � ���� �� ���); 
	jne		_clp_ret_													
_clp_fuck_:																;⮣�� eax = -1 � �� ��室
	xor		eax, eax
	dec		eax
_clp_ret_:
	pop		esi															;���� eax != -1; (= 0 ��� 4); 
	pop		edx 
	ret
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;����� �㭪� check_local_param_num 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;funka get_moffs8_ebp_local
;����祭�� (�������) ��砩���� 8-����⭮�� ᬥ饭�� � ����� ��� ॣ���� ebp (�����쭠� ��६�����);
;���ਬ��, ������� [ebp - 14h] - -14h (���� 0xEC) �� � ���� 8-����⭮� ᬥ饭�� � ����� ��� ॣ���� ebp; 
;����:
;	ebx		-	etc
;�����:
;	eax		-	��砩��� 8-����⭮� ᬥ饭�� (������ ��砩�� ����� �����쭮� ��६����� � ��ந��� ᬥ饭��); 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
get_moffs8_ebp_local:													;moffs8 - mem32 offset8 ebp; 
	push	esi
	mov		esi, [ebx].xfunc_struct_addr
	assume	esi: ptr XTG_FUNC_STRUCT

	push	[esi].local_num												;�롨ࠥ� ��砩�� ����� �����쭮� ��६�����
	call	[ebx].rang_addr

	inc		eax															;��� ������ � ��� �㤥� ����� 1 - ��ࢠ� �����쭠� ��६����� - [ebp - 04] 
	imul	eax, eax, 04												;㬭����� �� 4, ⠪ ��� ࠧ��� �����쭮� ��६����� = 4 ����; 
	neg		eax															;� �������㥬 - ⠪ ��� �� �����. ��६����� (���� "�����"); 
	pop		esi
	ret
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;����� �㭪� get_moffs8_ebp_local
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;funka get_moffs8_ebp_param
;����祭�� (�������) ��砩���� 8-����⭮�� ᬥ饭�� � ����� ��� ॣ���� ebp (�室��� ��ࠬ���);
;���ਬ��, ������� [ebp + 14h] - 14h (���� 0x14) �� � ���� 8-����⭮� ᬥ饭�� � ����� ��� ॣ���� ebp; 
;����:
;	ebx		-	etc 
;�����:
;	eax		-	��砩��� 8-����⭮� ᬥ饭�� (������ ��砩�� ����� �室���� ��ࠬ��� � ��ந��� ᬥ饭��);  
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
get_moffs8_ebp_param:													;moffs8 - mem32 offset8 ebp; 
	push	esi
	mov		esi, [ebx].xfunc_struct_addr
	assume	esi: ptr XTG_FUNC_STRUCT

	push	[esi].param_num												;�롨ࠥ� ��砩�� ����� �室���� ��ࠬ��� (�롨ࠥ� ��砩�� �室��� ��ࠬ���); 
	call	[ebx].rang_addr

	inc		eax															;��� ������ �� 1;
	imul	eax, eax, 04												;㬭����� �� 4; etc
	add		eax, 04														;� ������塞 4 - ⠪ ��� � ��� �㤥� ⠪, ���ਬ��: 
																		;push ecx							;�室��� ��ࠬ���, �� ᥩ�� [esp + 00h]
																		;call	func_1						;�맮� �㭪� func_1, ⥯��� �⮡� �������� � �室���� ��ࠬ����, �㦭� ᤥ���� [esp + 04h]
																		;...
																		;func_1:
																		;push	ebp							;[esp + 08h]
																		;mov	ebp, esp					;[ebp + 08h] 
																		;mov	dword ptr [ebp + 08], 05 
	pop		esi
	ret
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;����� �㭪� get_moffs8_ebp_param
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;�㭪a write_moffs8_for_ebp 
;������� � ������ 1 ���� - �� ���� �����쭠� ��६�����, ���� �室��� ��ࠬ��� ��� ॣ� ebp; 
;� ����, ���ਬ��, [ebp - 14h] � [ebp + 1Ch] - -14h - �� �����쭠� ��६�����, � +1Ch - �室��� ��ࠬ���; 
;����:
;	ebx			-	etc
;	eax			-	0 ��� �� ���� =) (�᫮ 4); 0 - ����� �㤥� ������� �������� ��६�����, ���� �室��� ��ࠬ���
;�����:
;	eax			-	ᣥ���஢���� � ����ᠭ�� ���⥪; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
write_moffs8_for_ebp:
	test	eax, eax
	je		_ebpo8_gl_

_ebpo8_gp_:
	call	get_moffs8_ebp_param

	stosb
	jmp		_ebpo8_ret_

_ebpo8_gl_:
	call	get_moffs8_ebp_local

	stosb
_ebpo8_ret_:
	ret
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;����� �㭪� write_moffs8_for_ebp
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
 
;============================[FUNCTIONS FOR INSTR WITH EBP & moffs8]=====================================



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;�㭪� convert_r32
;�८�ࠧ������ ॣ���� � �㦭�� ᮮ⢥�����饥 �᫮;
;���ਬ��, �᫨ �� �室� �㤥� �᫮ 0b (EAX), � �� ��室� 1b (�㫥��� ��� = ������);
;�᫨ �㤥� 1b (ECX), � �� ��室� �㤥� 10b (���� ��� ࠢ�� 1-�);
;etc 
;����:
;	xm_tmp_reg0		-	�᫮ ��� �������樨
;�����:
;	EAX				-	�८�ࠧ������� �᫮;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
convert_r32:
	push	ecx
	xor		eax, eax
	inc		eax
	mov		ecx, xm_tmp_reg0
	shl		eax, cl 
	pop		ecx
	ret
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;����� �㭪� convert_r32
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;�㭪� set_r32
;�����஢�� ��࠭���� ॣ���� (� ���� ����� ॣ���� �� �㤥� �ᯮ�짮������ ��� �����樨 ������)
;����:
;	xm_tmp_reg0		-	�᫮, ᮎ⢥�����饥 ��।��񭭮�� ॣ�����, ����� �� �⨬ �������;
;	EBX				-	address of XTG_TRASH_GEN
;�����:
;	[ebx].fregs		-	�⮨� �����஢�� ��।. ॣ�;
;	etc
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
set_r32:
	push	eax
	
	call	convert_r32													;������� �᫠
	
	test	[ebx].fregs, eax											;�᫨ ����� reg 㦥 �� ����祭 (���ਬ��, 横���), 
	je		_r32un_														;⮣�� xm_tmp_reg0 = -1. �� ᤥ���� ��� ⮣�, �⮡� �� ࠧ����� ࠭�� ����祭�� ॣ. 
	or		xm_tmp_reg0, -01											;���ਬ��, ࠭�� �� ����祭 ॣ EAX �������樥� "横�". � �ࠧ� ��᫥ �⮣� �� ������ �� ������� ������� [XCHG REG32, REG32]. 
																		;��� �� 㪠����, �⮡� �� ����稫� ॣ EAX. �� �� 㦥 ����祭, ���⮬� �� ������ xm_tmp_reg0 = -1, �⮡� 
																		;�� ����砭�� �����樨 ������ ������� �� ����� EAX. ���� "横�" �㤥� ���ࠢ��쭮 ࠡ����
_r32un_:
	or		[ebx].fregs, eax											;��稬 ॣ���� (��� ࠭�� ����祭���� �� �� ���� �������� ��䥪�);
	pop		eax
	ret
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;����� �㭪� set_r32
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;�㭪� unset_r32
;ࠧ�����஢���� ��࠭���� ॣ���� (� ���� ��࠭�� ॣ ����� ᭮�� �� ��� �����樨 ������)
;����:
;	xm_tmp_reg0		-	ॣ����, ����� �⨬ ࠧ�����;
;	EBX				-	XTG_TRASH_GEN; 
;�����:
;	[ebx].fregs		-	ࠧ��� ॣ�;
;	etc
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
unset_r32:
	cmp		xm_tmp_reg0, -01											;�᫨ �⮨� -1, ⮣�� ॣ���� �� �㦭� ���뢠�� (ࠧ�����஢���)
	je		_ur32_ret_
	push	eax
	
	call	convert_r32
	
	or		xm_tmp_reg0, -01											;���樠�����㥬 xm_tmp_reg0 = -1; 
	xor		[ebx].fregs, eax											;��ᨬ ॣ; 
	pop		eax
_ur32_ret_:
	ret
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;����� �㭪� unset_r32; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;�㭪� is_free_r32
;�஢�ઠ ॣ���� - ᢮����� �� ��? (����� �� ��� �� ��� ᮧ����� ������?)
;����:
;	xm_tmp_reg0 
;�����:
;	EAX				-	-1, �᫨ ॣ �����, ���� �� �᫮, �� ࠢ��� -1; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
is_free_r32:
	call	convert_r32
	
	or		xm_tmp_reg0, -01 											;���樠������
	test	[ebx].fregs, eax
	je		_ifr32_ret_
	or		eax, -01
_ifr32_ret_:
	ret
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;����� �㭪� is_free_r32
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
	 


;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;�㭪� get_rnd_r
;������� ��砩���� �᫠ (ॣ����)
;����:
;	EBX		-	XTG_TRASH_GEN;
;�����:
;	EAX		-	�� [0..7]; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
get_rnd_r:
	push	08
	call	[ebx].rang_addr
	ret
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;����� �㭪� get_rnd_r 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;�㭪� check_r
;�஢�ઠ ॣ���� �� ��������
;����:
;	EAX		-	�᫮ (ॣ����)
;	EBX		-	XTG_TRASH_GEN; 
;�����:
;	EAX		-	�室��� ���祭��, �᫨ �� 0k, ���� EAX = -1;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
check_r:
	push	ecx
	cmp		al, 04														;ESP 
	je		_nvr_
	cmp		al, 05														;EBP
	je		_nvr_
	xor		ecx, ecx
	inc		ecx
	push	eax
	xchg	eax, ecx
	shl		eax, cl
	test	[ebx].fregs, eax
	pop		eax
	je		_chkr_ret_
_nvr_:	
	or		eax, -01
_chkr_ret_:
	pop		ecx
	ret
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;����� �㭪� check_r
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;�㭪� get_free_r32
;����祭�� ᢮������� ॣ���� (EAX/ECX/EDX/EBX/etc)
;����:
;�����:
;	EAX		-	�᫮ (ॣ����) (����� ᢮������� ॣ����);  
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
get_free_r32:
	call	get_rnd_r
	
	call	check_r
	
	inc		eax
	je		get_free_r32
	dec		eax
	ret
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;����� �㭪� get_free_r32
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

	

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;�㭪� modrm_mod11_for_r32
;������� ���� MODRM � mod = 11b;
;�����:
;	EAX		-	���� MODRM; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
modrm_mod11_for_r32:
	push	edx
	call	get_free_r32
	
	mov		xm_tmp_reg1, eax
	shl		eax, 03
	add		al, 0C0h
	xchg	eax, edx
	
	call	get_free_r32
	
	mov		xm_tmp_reg2, eax
	add		eax, edx
	pop		edx
	ret
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;����� �㭪� modrm_mod11_for_r32
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;�㭪� get_free_r8
;����祭�� ᢮������� ॣ���� (AL/CL/DL/BL/AH/CH/DH/BH)
;����:
;�����:
;	EAX		-	�᫮ (����� ᢮������� ॣ����); 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
get_free_r8:
	call	get_rnd_r
	
	push	eax
	cmp		al, 04
	jl		_alcrct_
	sub		al, 04														;�⭨����, ⠪ ��� al = 0, ah = 4, cl = 1, ch = 4 + 1 = 5; �� �� ��� ������ ॣ���� (EAX/ECX/EDX/EBX); 

_alcrct_:	
	call	check_r
	
	inc		eax
	pop		eax
	je		get_free_r8
	ret
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;����� �㭪� get_free_r8 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;�㭪a modrm_mod11_for_r8
;������� ���� MODRM � mod = 11b
;�����:
;	EAX		-	���� MODRM; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
modrm_mod11_for_r8:
	push	edx
	call	get_free_r8

	mov		xm_tmp_reg1, eax
	shl		eax, 03
	add		al, 0C0h
	xchg	eax, edx

	call	get_free_r8

	mov		xm_tmp_reg2, eax
	add		eax, edx
	pop		edx 
	ret
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;����� �㭪� modrm_mod11_for_r8 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;�㭪� gen_data_for_func 
;������� ࠧ����� ������, �㦭�� ��� ᮧ����� �㭪権 � �맮��� �㭪権;
;��� ������� � ���������� ���ᨢ� ������� XTG_FUNC_STRUCT
;����:
;	EBX				-	���� �������� XTG_TRASH_GEN
;�����:
;	EAX				-	0, �᫨ ������� �� ����稫��� (��� �㩭�), ���� ���� ���ᨢ� ������� XTG_FUNC_STRUCT
;	xtg_tmp_var1	-	���� ���ᨢ� ������� XTG_FUNC_STRUCT
;	xtg_tmp_var2	-	���-�� �㭪権, ᪮�쪮 ���� ᣥ����� (���-�� ᣥ��७��� � ���������� ������� XTG_FUNC_STRUCT);
;	;xtg_tmp_var3	-	���� ���� ��� esp ��� (����) �⥪; 
;	(+)				-	����������� ��室�� ���� �������� XTG_TRASH_GEN � �室��� ���� xfunc_struct_addr
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
init_local_max_size		equ		10										;���樠������ �����쭮� ��६�����(��) - ���ᨬ���� ࠧ���; ������ ���� >= 3; 
max_local_num			equ		10										;���ᨬ��쭮� ������⢮ �������� ��६�����; �᫨ ᤥ���� �� ����� 31, ⮣�� � ������ �।�ᬮ���� ������� � ⠪�� ��६., �.�. ��� ����� ������� ����� ������; 
max_param_num			equ		5										;���ᨬ��쭮� ���-�� �室��� ��ࠬ��஢; �᫨ ᤥ���� �� ����� 31, ⮣�� � ������ �।�ᬮ���� ������� � ⠪�� ��६., �.�. ��� ����� ������� ����� ������; 
param_max_size			equ		6										;���ᨬ���� ࠧ��� ������ �室���� ��ࠬ��� (push dword ptr [403008h] = 6 bytes); ᬮ�ਬ � �㭪� gen_param_for_func - �᫨ ⠬ ��������� ����, � � ��� �⮣� ��ࠬ��� �������� ⮣�� ⮦�; 
trash_max_size			equ		35										;���ᨬ���� ࠧ��� ����� ��窨 ����;  ������ ���� >= 6; 
max_func				equ		10										;���ᨬ��쭮� ���-�� �㭪権, ����� ����� ᣥ����� (= ���ᨬ��쭮�� �஢�� ४��ᨨ); 
func_size				equ		(01 + 02 + 06 + init_local_max_size + 02 + 01 + 03 + ((max_func - 01) * 5) + (max_param_num * param_max_size * (max_func - 01)) + trash_max_size)  
																		;���᭨�: 
													   					;push ebp - 01;
													   					;mov ebp, esp - 02 bytes;
													   					;sub esp,XXXXXXXXh 
													   					;mov dword ptr [ebp - XXXXXXXXh], XXXXXXXXh - 10 - ���樠������ ��� �� ����� �����. ��६; 
													   					;mov esp, ebp - 02; (��� leave - 1); �� �� ��६ �� max; 
													   					;pop ebp - 1;
													   					;ret XXh - 3;
													   					;call XXXXXXXXh - ࠧ��� max ���-�� �맮��� � �㭪� (max_func - 1) * 5 byte; 
													   					;push 05 etc - (max_param_num * 6 * (max_func - 01)) - ���ᨬ��쭮� ���-�� �室��� ��ࠬ��஢ � �㭪� * max ࠧ��� ������ ⠪��� ��ࠬ��� * max ���-�� �맮��� (call'��); 
													   					;trash - 100; ���订� ���; 
													   					;���ᨬ���� ࠧ��� �㭪樨; 
gen_data_for_func:
	push	ecx															;��࠭塞 � �⥪� ॣ�����, ����� �㤥� ᥩ�� �ᯮ�짮����; 
	push	edx
	push	esi
	push	edi
	assume	ecx: ptr XTG_FUNC_STRUCT
	assume	edx: ptr XTG_FUNC_STRUCT 
	assume	edi: ptr XTG_FUNC_STRUCT 
	xor		eax, eax
	cmp		[ebx].fmode, XTG_REALISTIC									;���砫� �஢�ਬ, ����� �� ०�� �����樨 ����?
	jne		_gd4f_ret_ 
	test	[ebx].xmask1, XTG_FUNC										;��⥬ �஢�ਬ, ���⠢��� �� ����� 䫠�? �� ����砥�, �� ����� ������� �㭪� � �� �맮�� (call'�); 
	je		_gd4f_ret_ 
	cmp		[ebx].trash_size, (max_func * func_size)					;����� �஢��塞, 墠�� �� ��� ��।����� ���⮢ ��� �����樨 �㭪権?
	jl		_gd4f_ret_
	cmp		[ebx].alloc_addr, 0											;� ⠪�� �஢�ਬ, ��।��� �� ���� �㭪権 �뤥����� � �᢮�������� �����? 
	je		_gd4f_ret_	
	cmp		[ebx].free_addr, 0
	je		_gd4f_ret_

	push	(sizeof (XTG_FUNC_STRUCT) * max_func + 04)					;+ size_of_stack_commit + 04
	call	[ebx].alloc_addr 											;�᫨ ��� �⫨筮, ⮣�� �뤥��� ������ ��� (// ��k &) �������� XTG_FUNC_STRUCT, ����� ᥩ�� �㤥� ���������; 

	test	eax, eax 
	je		_gd4f_ret_

	mov		xtg_tmp_var1, eax 											;xtg_tmp_var1 - ��࠭�� � ������ ��६������ ���� �뤥������� ���⪠ �����; 
	and		xtg_tmp_var2, 0												;xtg_tmp_var2 = 0; 
	xchg	eax, edi													;edi - ���� �뤥������ �����; 
	and		[edi].call_num, 0											;������ ������ ����, �ਭ������饥 ��ࢮ� ����� (��ࢮ� �㭪�) = 0; 
	
	push	max_func													;��砩�� ��।����, ᪮�쪮 �㭮� �㤥� �������; 
	call	[ebx].rang_addr

	;mov	eax, 1														;for test; 
	
	lea		esi, dword ptr [eax + 01]  									;����� � ��� �㤥� ��� �� ���� �㭪�; 
	xor		edx, edx
	mov		eax, [ebx].trash_size										;eax = size of trash; 
	div		esi															;eax = max ࠧ���� ����� �㭪�;
	mov		xtg_tmp_var4, eax											;��࠭�� �� ���祭�� � xtg_tmp_var4; 
	xor		edx, edx
	mov		eax, [ebx].tw_trash_addr									;eax = ����� ��� ����� ����; 
	mov		xtg_tmp_var5, eax
_gd4f_cycle_01_: 														;����� ���� 横�, � ���஬ ��������� ࠧ���� ��ࠬ���� � ����������� ������ન; 
																		;� ��� ⠪�� ��: ���ਬ��, �� �㤥� ������� 5 �㭪権. ����� � ��� ���� 5 ������� XTG_FUNC_STRUCT. ��ࢠ� ������� ����� ������ 0, ���� - 1 � �.�.
																		;��� ���, �誠 � ⮬, �� �㭪� 1 (��� ��� ������� 1-��, � ���ன ������ 0) max ����� �맢��� �㭪� 2,3,4 � 5. �㭪� 2 max ����� �맢��� ⮫쪮 3,4 � 5. 3-� �㭪� - max 4 � 5.
																		;4-�� - max ⮫쪮 5, � 5-�� - ������. ��祬, �㭪� 1 ��易⥫쭮 ������ ᮤ�ঠ�� ��� �� 1 �맮� ��㣮� �㭪�. 
																		;������� �ਬ��: ��࠭� ������� 5 �㭪権. ����� �ᥣ� � �㭪��� ����� ���� max 5 - 1 = 4 �맮��. �����, �� �६� ���������� �������� ��� �㭪� 1 ᬮ�ਬ: ���� 0 ��ࠡ�⠭��� ������� � �㬬� �맮��� ⮦� = 0. 
																		;0 - 0 = 0 == 0. �����, ᣥ��ਫ� ��� ��ࢮ� �㭪� 2 �맮��. ��⥬ �������� �� ������� 2 �������� (������ ��� 2-�� �㭪�). ��� - ��ࠡ�⠭� 㦥 1 ������� (�, �� ��� ��ࢮ� �㭪�), � ᣥ���஢��� 2 �맮�� (�, �� ��� ��ࢮ� �㭪�). 
																		;1 - 2 = -1 < 0 -> �, �����⨬ ��� 2-�� ������ 1 �맮� �㤥�. ��᫥, ���室�� �� 3-� ��������. ��� ��ࠡ�⠭� 2 ������ � �ᥣ� 3 �맮��: 2 - 3 = -1 < 0;
																		;������, ��� 3-�� ������, �����⨬ �㤥� 0 �맮���. ������ �� 4-� ������: ��ࠡ�⠭� 3 �������� � 3 �맮��: 3 - 3 = 0 == 0;
																		;� ��� 4-�� ������ ⮦� �믠�� 0 �맮���. ������ �� ����� ������: 4 ��ࠡ�⠭��� ������ � 3 �맮��: 4 - 3 = 1 > 0 ->������塞 �� �᫮ � call_num ��� ��ࢮ� ������;
																		;⠪�� ��ࠧ�� ���ᯮ�짮����� �맮�� �� �㤥� ��������� � call_num ��ࢮ� ��������; � �� ��᫥ ᣥ��७�� �㭪� ���� �맢��� � ��� �⫨筮! 

	mov		ecx, edx													;ecx = edx -> �� ������ ������ન (���ਬ��, ������ 0 - �� ��ࢠ� ������ઠ), �� equ ���-�� ����������� ������� (��� �㭪権) (0 - 0 ����������� �������); 
	sub		ecx, xtg_tmp_var2											;�⭨���� �� ���-�� ��ࠡ�⠭��� �㭪権 ���-�� �맮��� - �᫨ �� ����祭��� ���祭�� > 0, ⮣�� ������塞 ��� � ���� call_num ��ࢮ� ������ (�㭪�); 
	jb		_gd4f_correct_call_num_for_1st_func_ 						;�᫨ ⠪ �� ᤥ����, ⮣�� �����-� �� ᣥ���஢����� �㭪権 ����� ������� �� ������� �ࠢ�����; 
	add		[edi].call_num, ecx											;�᫨ ����祭��� ���祭�� > 0, ⮣�� �������; �᫨ �� < (<=) 0, ⮣�� �� �㭪�, ����� ᮮ�-�� �� ��ࠡ�⠭�� ������, ���� �맢���; 
	add		xtg_tmp_var2, ecx

_gd4f_correct_call_num_for_1st_func_: 
	
	mov		eax, esi													;
	sub		eax, xtg_tmp_var2											;᪮�쪮 �� ��⠫��� ᢮������ �맮���

_gd4f_nxt_1_:
	push	eax															;������ �㭪� ᪮�쪮 �㤥� ����� �맮��� (call'��)? 
	call	[ebx].rang_addr

	test	edx, edx													;�᫨ �� �㭪� 1
	jne		_gd4f_nxt_2_	
	cmp		esi, 01														;� ���-�� ������㥬�� �㭮� > 1, 
	je		_gd4f_nxt_2_ 
	test	eax, eax													;� �㭪� 1 �㤥� ����� ��� ������ 1 �맮�, ���� ��㣨� �㭪� �� ���� �맢��� - � �� ����� ���; ������; 
	jne		_gd4f_nxt_2_
	inc		eax 
_gd4f_nxt_2_:
	imul	ecx, edx, sizeof (XTG_FUNC_STRUCT)
	mov		[edi + ecx].call_num, eax									;�����뢠�� ���-�� �맮���;
	add		xtg_tmp_var2, eax											;� ������ ��६����� ᮤ�ন��� ���祭�� - ᪮�쪮 �ᥣ� �맮��� 㦥 �㤥�, �� �᫮ �ᥣ�� �� 1 ����� max �᫠ �㭮�, ᠬ�-ᮡ��; 
	mov		eax, xtg_tmp_var5
	mov		[edi + ecx].func_addr, eax									;���� ������ ���饩 �㭪� � ����;

	push	max_local_num
	call	[ebx].rang_addr								

	mov		[edi + ecx].local_num, eax									;���-�� �������� ��६�����

	push	max_param_num
	call	[ebx].rang_addr
	
	test	edx, edx 													;�᫨ ᥩ�� ����������� ����� ��� �㭪� 1, ⮣�� ��� �� ����� �室��� ��ࠬ��஢; 
	jne		_gd4f_nxt_3_
	xor		eax, eax
_gd4f_nxt_3_:
	mov		[edi + ecx].param_num, eax 									;���-�� �室��� ��ࠬ��஢
	mov		eax, xtg_tmp_var4
	sub		eax, func_size

	push	eax
	call	[ebx].rang_addr

	add		eax, func_size   
	mov		[edi + ecx].func_size, eax									;ࠧ��� ������ �㭪�;
	add		eax, [edi + ecx].func_addr
	mov		xtg_tmp_var5, eax
	inc		edx 
	cmp		edx, esi													;���室�� � �����樨 ������ ��� ᫥���饩 �㭪�; 
	jne		_gd4f_cycle_01_
	dec		esi
	imul	eax, esi, sizeof (XTG_FUNC_STRUCT) 
	mov		xtg_tmp_var2, edx											;������ ��६����� ⥯��� �࠭�� ���-�� ������㥬�� �㭪権; 
	mov		edx, [ebx].trash_size										;edx - ࠧ��� ���� (� �����), ᪮�쪮 �ᥣ� ���� ᣥ���஢���; 
	mov		ecx, [edi + eax].func_addr									;ecx - ᮤ�ন� ���� �㭪� � ��᫥���� ������� (���� ��᫥���� �㭪�, ⠪ ��� ���� ᥩ�� ��室���� � ���浪� �����⠭��); 
	sub		edx, ecx													;�⭨���� ��� ����
	sub		edx, [edi + eax].func_size									;� ࠧ��� ��᫥���� �㭪�
	add		edx, [edi].func_addr										;� ������塞 ���� ��ࢮ� �㭪� - ⠪�� ��ࠧ�� � edx �㤥� ���-�� ��ᣥ���஢����� (������ᠭ���) ���⮢;
	add		[edi + eax].func_size, edx									;������� �� ����� � ࠧ���� ��᫥���� �㭪� - ⠪�� ��ࠧ�� �� ᣥ����㥬 �� �����, ᪮�쪮 㪠���� � [ebx].trash_size; 
	add		ecx, [edi + eax].func_size									;ecx += ࠧ��� ������ (��᫥����) �㭪� - ⥯��� ecx ᮤ�ন� ���� �ࠧ� �� ���殬 ��᫥���� �㭪�; 
	mov		[ebx].fnw_addr, ecx											;� ��� ���� �㤥� ���ᮬ ��� ���쭥�襩 ����� ����;
	sub		ecx, [edi].func_addr										;�⭨���� �� �⮣� ���� ���� ᠬ�� ��ࢮ� �㭪�, � ����砥� �᫮ ॠ�쭮 ����ᠭ��� ���⮢. �� ����� �������筮 ���� ����ᠭ�, ⠪ ��� � ०��� 
	mov		[ebx].nobw, ecx												;ॠ����筮��� ���� �ᥣ�� ����ᠭ� �� ����� (�������� ������� ��� ������); � �㭪� ���� ᮧ�������� ⮫쪮 � �⮬ ०���; 
 	xor		ecx, ecx

_gd4f_cycle_02_: 														;��� ������ ᫥���饥: ������ન ⠪�� ������� �� ᢮�� �����, �� ���� func_addr & func_size ��砩�� ���塞 ���⠬� � �������� 
																		;⥬ ᠬ� ����砥��� ⠪, �� �㭪� ���� �ᥣ�� ࠧ�묨, �맮�� ࠧ��, �� ࠧ��� ����� ���; 
 	push	xtg_tmp_var2
 	call	[ebx].rang_addr

	imul	eax, eax, sizeof (XTG_FUNC_STRUCT)
	imul	edx, ecx, sizeof (XTG_FUNC_STRUCT)
	mov		esi, [edi + eax].func_addr
	mov		xtg_tmp_var3, esi
	mov		esi, [edi + eax].func_size
	mov		xtg_tmp_var4, esi
	mov		esi, [edi + edx].func_addr
	mov		[edi + eax].func_addr, esi
	mov		esi, [edi + edx].func_size
	mov		[edi + eax].func_size, esi
	mov		esi, xtg_tmp_var3
	mov		[edi + edx].func_addr, esi
	mov		esi, xtg_tmp_var4
	mov		[edi + edx].func_size, esi 
	inc		ecx 
	cmp		ecx, xtg_tmp_var2
	jne		_gd4f_cycle_02_
	mov		eax, [edi].func_addr										;⥯��� ��६ ���� �㭪� � ᠬ�� ��ࢮ� ������� - �� �� �㭪� ����� ���� �� ��ࢮ�, ⠪ ��� ⮫쪮 �� �� ������ ࠧ��蠫� ࠧ���� � ���� �㭮�; 
	mov		[ebx].ep_trash_addr, eax   
	mov		[ebx].xfunc_struct_addr, edi
	;lea	eax, dword ptr [edi + (sizeof (XTG_FUNC_STRUCT) * max_func + size_of_stack_commit)]
	;mov	xtg_tmp_var3, eax											;��࠭�� � ������ ��६����� ���� � �뤥������ ����� - ��� ���⮪ �⢥��� ��� (����) �⥪; 
	xchg	eax, edi 
_gd4f_ret_:	
	pop		edi 
	pop		esi
	pop		edx
	pop		ecx 
	ret																	;�� ��室! 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;����� �㭪� gen_data_for_func 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
 


;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;�㭪a gen_func
;������� �㭪権 � �஫�����, १�ࢨ஢����� ��� ��� �������� ��६�����, ���樠����樥� �������� 
;��६�����, ���襬, ��।�祩 �室��� ��ࠬ��஢ � �맮���� (call's) ��㣨� �㭪権, �������, ret'���; 
;���� (stdcall: gen_func(param1, param2)):
;	param1								-	���� �������� XTG_TRASH_GEN
;	param2								-	���� �������� XTG_EXT_TRASH_GEN
;	(+) XTG_TRASH_GEN.xfunc_struct_addr	-	���� (����������� ���४⭮) �������� XTG_FUNC_STRUCT 
;�����:
;	EAX									-	���� �������� XTG_FUNC_STRUCT; 
;�������:
;	1) 
;	�㭪� ���� �����஢����� ������ ⠪, �⮡� ������ ������ ����஥��� ������ �⫨筮 ࠡ�⠫ � 
;	����� ���裥���. �� ���� �᫨, ���ਬ��, �������� ᥩ�� �㭪��, � ��ந��� �஫�� � �.�., ��⥬ 
;	����, � �����, �����⨬ ����ਬ �맮� �� ����� �㭪�. � �ࠧ� ��᫥ �⮣� �� ��稭��� ������� 
;	�஫��� � �.�. 㦥 ��㣮� �㭪� (����砥��� ४���� � gen_func). � ��⥬, ����� ���� �㭪� �뫠 
;	ᣥ��७� � � ��� �� �뫮 ��㣨� �맮���, � �� ��室�� �� ���, � ᭮�� �த������ ����ࠨ���� 
;	����� �㭪�. �� ���� �� ��ந� ��� ��� ������ ⠪, ��� �� �㤥� ॠ�쭮 ࠡ����. � ������ ᭠砫� 
;	�㤥� ࠡ���� ��ࢠ� �㭪�, ��⥬ �맮� � ���室 �� �����, ��⥬ ������ � ����� � ���.
;	����� ��ࠧ�� �� ᬮ��� ᤥ���� �ࠢ����� ������ ����, �㫨��� � �஢����/���ࠢ��� ��᫥����⥫쭮 
;	������� �� ��������. �� �⮩ �� ��稭� �� ����� �맢��� ⮫쪮 1 ࠧ ���� �㭪�, � ����� �� ����� 
;	��뢠��, ���� �� ��㣨� �㭪権 - ��⮬� �� ��� 㦥 ����஥��. ���� ⠪�� ��ਠ�� =)  
;
;	2)
;	�㭪� ����� ��ந��, �᫨ ०�� ॠ����筮���, ���⠢��� 䫠� XTG_FUNC � ��।��� ���� �㭪権 
;	�뤥�����/�᢮�������� �����. 
;	
;	3)
;	��� ��ਠ��, ����� �뤥���� �� ����� ����� � ��।��� ��� ���� � esp - ���� ���. � ����� ��ந��
;	�� ����� �㭪権;
;
;	4)
;	�ਬ��: �����⨬, ��࠭�, �� �� �㤥� ������� 4 �㭪�, ��祬 ��ࢠ� �㭪� func_1 (��ࢠ� 
;	������� XTG_FUNC_STRUCT) ����� 2 �맮�� (���� call_num), ���� - 1, 3-� ���� � 4-�� ⮦� 0. ��� 
;	���, ��ந���� �� �� �㭪� ���� ⠪: 
;	᭠砫� ��ந��� func_1: �஫��, ���� (��������, �� १�ࢨ஢���� ���, ����-� �����. ��६.). 
;	��⥬, ᬮ�ਬ, �� � �㭪� ���� 2 �맮��. ��ந� ���� �맮� �� func_2, ��⥬ ���室�� 
;	(४��ᨢ��) �� ������� func_2. ��諨 �� �����樨 �� �맮���, � �����, �� � ��� ���� 1 �맮� - 
;	����ਬ ��� �� func_3. � ���室�� �� ������� func_3. ��� ⠪��, ��ந� �஫��� etc. �����, �����, 
;	�� � ��� ��� �맮��� - ���室�� �� ����஥��� ������ func_3. � ��室��. ������ �� ᭮�� � func_2. 
;	�����⢥��� �� �맮� ᣥ��ਫ� - ����� ���室�� �� ����஥��� ������ func_2. � ��᫥ ��諨 �� func_1. 
;	� func_1 - ��⠫�� �� ���� �맮� - �� �㤥� �� func_4. � ����ਬ func_4. � func_4 - ��� �맮���. � ᭮�� 
;	�������� �� func_1. � func_1 ⥯��� ᣥ��७� �� 2 �맮�� - ��ந� ����. �� �⮬ ���. 
;	� �⮣�, ��������� ����� ⠪:
;		func_4:
;			...
;			ret
;
;		func_3:
;			...
;			ret
;
;		func_1:
;			...
;			call	func_2
;			...
;			call	func_4
;			...
;			ret
;
;		func_2:
;			...
;			call	func_3
;			...
;			ret
;
;	� XTG_TRASH_GEN.ep_trash_addr - �㤥� ������ ���� �� func_1 - aka �窠 �室� � ����=)!; 
;	�����, ������ �㭪�, ����� �����, ���ਬ��, ⠪�� ��稭��: 
;	func_x:
;		push	ebp								;�� ����� ������ ����ﭭ� ��������
;		mov		ebp, esp						;�������筮
;		sub		esp, 14h						;��樮���쭮 - �᫨ ���� ������� ��६����, � �㤥�. � � ����ᨬ��� �� �� ���-��, ����� ���� ��㣮� ���祭�� �� 14h; 
;		...										;���� - ��� �� ���樠������ ॣ� ecx; 
;		mov		dword ptr [ebp - 0Ch], ecx		;�᫨ ������ ����, ⮣�� �㤥� ���樠������ ��� �� ����� �����-��६; 
;		...										;����
;		push	ebx								;�室�� ��ࠬ����
;		push	dword ptr [ebp - 14h]			;
;		call	func_xx							;�맮� �㭪�
;		...										;����
;		leave									;���� 
;		ret										;��室
; 
;� ������ ��㣨� ��ਪ�;
; 	
;etc 
;!!!!! �᫨ ���⥫��� ������� ������� ��� � � moffs32, ⮣�� �������� ����� �㦭� ���;   
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  
gf_struct1_addr		equ		dword ptr [ebp + 24h]						;XTG_TRASH_GEN
gf_struct2_addr		equ		dword ptr [ebp + 28h]						;XTG_EXT_TRASH_GEN 

gf_tmp_var1			equ		dword ptr [ebp - 04]						;�ᯮ����⥫�� ��६����; 
gf_tmp_var2			equ		dword ptr [ebp - 08]
gf_tmp_var3			equ		dword ptr [ebp - 12]
gf_tmp_var4			equ		dword ptr [ebp - 16]

gf_xids_addr		equ		dword ptr [ebp - 20]						;XTG_INSTR_DATA_STRUCT 

gen_func:
	pushad
	mov		ebp, esp
	sub		esp, 24
	xor		ecx, ecx													;ecx ᥩ�� �㤥� ᮡ���� ࠧ��� �஫��� + ࠧ��� ������� १�ࢨ஢���� ���� � �⥪� ��� ������� ��६����; 

;--------------------------------------------------------------------------------------------------------
	mov		ebx, gf_struct2_addr
	assume	ebx: ptr XTG_EXT_TRASH_GEN
	mov		ebx, [ebx].xlogic_struct_addr 
	assume	ebx: ptr XTG_LOGIC_STRUCT									;����� �� �� ������?
	test	ebx, ebx
	je		_gf_fxidsa_
	mov		ebx, [ebx].xinstr_data_struct_addr
_gf_fxidsa_:
	mov		gf_xids_addr, ebx											;� �⮩ ��६����� �������� ���� XTG_INSTR_DATA_STRUCT ���� 0, �᫨ ��� �㩭�; 
;--------------------------------------------------------------------------------------------------------
	
	mov		ebx, gf_struct1_addr
	assume	ebx: ptr XTG_TRASH_GEN 										;ebx - ���� �������� XTG_TRASH_GEN 
	mov		esi, [ebx].xfunc_struct_addr 
	assume	esi: ptr XTG_FUNC_STRUCT									;esi - XTG_FUNC_CTRUCT
	mov		edi, [esi].func_addr										;edi - ����, ��㤠 ��稭��� �����஢��� �㭪� � �� �஫�����, ���襬, ������� etc; 
	imul	eax, [esi].param_num, 04									;eax - ���-�� �室��� ��ࠬ��஢ * 4 (4 ���� - ࠧ��� �室���� ��ࠬ���); 
	mov		gf_tmp_var3, eax											;��࠭�� ������ ���祭�� � gf_tmp_var3
	and		gf_tmp_var4, 0

	push	[ebx].tw_trash_addr											;��࠭�� � ��� �㦭� ���� ��������;
	push	[ebx].trash_size
	push	[ebx].nobw 

	imul	edx, [esi].local_num, 04									;edx - ���-�� �������� ��६����� * 4; 
	mov		al, 55h														;����� ����ਬ �஫�� �㭪�
	stosb																;push ebp
	mov		ax, 0EC8Bh													;mob ebp, esp
	stosw
	add		ecx, 03														;ecx = 3;
	test	edx, edx													;�᫨ edx == 0, ⮣�� �������� ��६����� ���, � ����� �� �㤥� १�ࢨ஢��� � �⥪� ���� ��� �����. ��६.; 
	je		_gf_nxt_1_ 
	cmp		edx, 80h													;���� ᬮ�ਬ, ᪮�쪮 �����. ��६�����, �᫨ �� ���-�� * 4 >= 80h, ⮣�� ����ਬ ������� �뤥����� ���� � ������� 81h, ���� 83h; 
	jge		_gf_sub_esp_81h_
_gf_sub_esp_83h_:														;sub esp, XXh (83h 0ECh XXh) (XXh < 80h); 
	mov		ax, 0EC83h
	stosw
	xchg	eax, edx 
	stosb																;����� ������ ������� = 3 ����; 
	add		ecx, 03														;ecx += 3; 
	jmp		_gf_nxt_1_
_gf_sub_esp_81h_:														;sub esp, XXXXXXXXh (81h 0ECh XXXXXXXXh) (XXXXXXXXh >= 80h); 
	mov		ax, 0EC81h
	stosw
	xchg	eax, edx
	stosd																;length = 6 bytes;
	add		ecx, 06														;ecx += 6; 

_gf_nxt_1_:	
	push	04															;����� ����砥� ��; 
	call	[ebx].rang_addr

	or		al, 01														;� १��� EAX = 1 ��� 3 - �� ࠧ��� ����� (1 ���� - leave; 3 bytes - mov esp,ebp  pop ebp); 
	mov		gf_tmp_var2, eax											;��࠭�� ����祭��� ���祭�� � gf_tmp_var2; 
	cmp		gf_tmp_var3, 0												;����� �� ������ �㭪� �室�� ��ࠬ����? 
	je		_gf_nxt_2_													;�᫨ ���, ⮣�� ������� ��室� (ret) �㤥� ����� ࠧ��� 1 ���� (0C3h);  
	inc		eax															;�᫨ ��, � 3 ���� (ret XXh - 0C2h XXh 00h); 
	inc		eax
_gf_nxt_2_:
	inc		eax															;� ������� �� �᫮ � eax'� - eax ⥯��� �࠭�� ࠧ��� ����� + ࠧ��� ������� ��室�; 
	imul	edx, [esi].call_num, 05										;edx - ᮤ�ন� ࠧ��� ��� �맮��� � ������ �㭪� (call XXXXXXXXh - ࠧ��� 5 ���⮢ (0E8h etc)); 
	add		edx, eax													;������塞 eax
	add		edx, ecx													;� ecx; 
																		;� ���� ��� �㦭� ������� �筮� ���-�� ���⮢, ����� ���� �⢥���� ��� �஫��, ���� � �.�. �������;
																		;� ��� �� �㤥� �࠭����� � edx;
																		;�� �㦭� ��� ⮣�, �⮡� �� ����ᠫ� �� ����� [esi].func_size, �뤥����� ��� �㭪樨. ��� ��� �� ��࠭�� 㦥 ���᫨�� ��� ���� � ࠧ���� �㭪権, ���� ����� ���� ���� � ������ ��� ����; 
																		;� ��⥬ ���⥬: [esi].func_size - edx = ���-�� ���� - �� ��� ����;
	imul	eax, [esi].call_num, (max_param_num * param_max_size)		;⠪...⥯��� 㧭��� ࠧ��� ��� �室��� ��ࠬ��஢ - ⠪ ��� �� �� �� �� ᣥ���஢���, 
																		;���⮬� ��६ ���ᨬ��쭮 �����⨬�� ���-�� ��ࠬ��஢, 㬭����� �� ���ᨬ���� ࠧ��� ������ ��ࠬ��� � 㬭����� ����祭��� ���祭�� �� ���-�� �맮���; 
	add		edx, eax													;� ������塞 � edx; 
	mov		eax, [esi].func_size										;eax ࠢ�� ࠧ���� ������ �㭪�;
	sub		eax, edx													;� ���⠥� ࠧ��� "�㦥����" ���⮢;
	mov		gf_tmp_var1, eax											;��࠭塞 ����祭�� ࠧ��� � gf_tmp_var1; �� �᫮ - �㬬��� ࠧ��� ���� � ������ �㭪�; 

;--------------------------------------------------------------------------------------------------------
	cmp		gf_xids_addr, 0												;����� �� �� ������? 
	je		_gfl_nxt_1_ 

	mov		ecx, gf_xids_addr											;�᫨ ��, ⮣�� ���㫨� ⮫쪮 �� ᣥ��७�� �஫�� ��襩 �㭪�; 
	assume	ecx: ptr XTG_INSTR_DATA_STRUCT 
	mov		edx, [esi].func_addr
	mov		[ecx].instr_addr, edx										;����, ��� ��砫� ����� �஫��
	mov		[ecx].instr_size, edi
	sub		[ecx].instr_size, edx										;ࠧ��� = ���� ��� ⥪�饩 ����� - ���� ��砫� �஫���; 
	mov		[ecx].flags, XTG_ID_FUNC_PROLOG 
	
	mov		edx, gf_struct2_addr
	assume	edx: ptr XTG_EXT_TRASH_GEN
	mov		edx, [edx].xlogic_struct_addr
	assume	edx: ptr XTG_LOGIC_STRUCT
	
	push	edx															;� �맮��� �㭪� ��0��ન ������ ������ �������樨
	push	ebx
	call	let_main

	mov		edx, [edx].xlv_addr
	lea		edx, dword ptr [edx + (vl_lv_num + 01 + 01) * 4]			;� ��� ��� ⠪�� ��: ����� �࠭���� �᫮ ��⨢��� �������� ��६����� - � ���� ⠪��, ����� �ᯮ������� � �����饥 �६�. 
	push	dword ptr [edx]												;������ �㭪� ����� ᢮� �����-���� � �室�� ��ࠬ����. ��� ���, ���ਬ��, �� ᥩ�� ��ந� ����� �㭪� - ����� ᥩ�� 0 ��⨢��� �����-��஢.
																		;��⥬ ��। �����樥� �맮�� � �����樥� ᫥���饩 �㭪�, �����⨬, � ��� �⠫� ��⨢��� 5 �����-��஢. 
																		;��⥬, �� ����ਬ ����� �㭪�. ��� ��� ��࠭�� �᫮ 5. �����, �����⨬, �� ���� �㭪� ������ �� ��뢠�� � �� ���� �����-����. ��᫮ ��⨢��� �.�. = 7; � ���� 5 + 2;
																		;��⥬ �� ᣥ��ਫ� ���� ��ன �㭪� � ��। ��室�� ᭮�� � ����� �㭪� �� ����⠭�������� �᫮ ��⨢��� �.�. = 5 - ⠪ ��� �ࠢ����� ���諮 ᭮�� �� ����� �㭪�, � ���� 2 �.�. �� ��ன �㭪� 㦥 �⠫� ����⨢�묨. � �.�.
																		;etc 
	push	[ecx].param_1
	or		[ecx].param_1, XTG_XIDS_CONSTR								;㪠�뢠��, �� ����� �㤥� �������� ����, �ਭ������騩 (�⮩) �������樨
	and		[ecx].instr_addr, 0											;���뢠�� ���� � 0 - �� �㦭� ��� ⮣�, �⮡� ����� �� ᭮�� �� �஢�ਫ� ��� ��������� �� ������, � �஢��﫨 㦥 ���� ᣥ��७�� ���騥 �������
_gfl_nxt_1_:
;--------------------------------------------------------------------------------------------------------

	xor		ecx, ecx													;ecx - ⥯��� ��� ����稪 ���-�� ᣥ���஢����� �맮��� �㭮� (call's); 
	mov		edx, [esi].call_num											;edx - ���-�� �맮��� ��㣨� �㭮� � ������ �㭪� =)! 
	
	cmp		[esi].local_num, 0											;�᫨ ���-�� �������� ��६����� = 0, ⮣�� ���樠������ ��� �� ����� �����쭮� ��६����� �筮 �� �㦭� xD; 
	je		_gf_not_init_local_
	
	push	[ebx].fmode													;��࠭�� � �⥪� ���� ��������, ⠪ ��� �� �㤥� �� ��������; 
	push	[ebx].xmask1 
	push	[ebx].xmask2
	push	[esi].param_num												; 
		
	mov		eax, (trash_max_size - 06)									;����稬 �� - ࠧ��� ���樨 ����; ����� ᬥ�� ⠪ ������, ⠪ ��� ࠧ��� �筮 墠��, ��� ����⠭� � gen_data_for_func; 
	call	get_rnd_num_1

	add		eax, 06														;�⮡� ��������� ��� �� �ந��樠����஢��� �����-���� ॣ etc; 

	;mov		[ebx].xmask1, (XTG_ON_XMASK - XTG_CMOVXX___R32__R32 - XTG_BSWAP___R32 - XTG_THREE_BYTES_INSTR - XTG_PUSH_POP___R32___R32) ;
	;mov		[ebx].xmask2, XTG_OFF_XMASK 								;㪠�뢠��, �����(��) �������(�) �������; 
	mov		[ebx].tw_trash_addr, edi
	mov		[ebx].trash_size, eax	
	and		[ebx].nobw, 0
 
	push	gf_struct2_addr
	push	ebx
	call	xtg_main													;��뢠�� ���裥� ४��ᨢ��

	mov		eax, [ebx].nobw												;eax = ���-�� ॠ�쭮 ����ᠭ��� ���⮢; 
	add		edi, eax													;᪮�४��㥬 edi �� ���� ��� ���쭥�襩 ����� ����; 
	sub		gf_tmp_var1, eax 											;���⥬ �� �㬬�୮�� ࠧ��� ���� ࠧ��� ⥪�饩 ���樨 ����; 
 
    mov		[ebx].fmode, XTG_MASK										;�⠢�� ०�� "��᪠", �⮡� ᣥ����� ��।�������(�) �������(�); 
    mov		[esi].param_num, 0											;��� �㦭� ���樠������ ⮫쪮 �����-��६, ���⮬� ���㫨� �室�� ��ࠬ���� �㭪�; 
	mov		[ebx].xmask2, XTG_MOV___M32EBPO8__R32						;㪠�뢠��, ����� ������� �������; 
	mov		[ebx].xmask1, XTG_OFF_XMASK									;
	mov		[ebx].tw_trash_addr, edi
	mov		[ebx].trash_size, 03										;etc; 
	and		[ebx].nobw, 0

;--------------------------------------------------------------------------------------------------------
	push	esi
	mov		esi, gf_xids_addr 
	assume	esi: ptr XTG_INSTR_DATA_STRUCT								;᭮�� �஢��塞, ����� �� �� ������? 
	test	esi, esi
	je		_gf_g1stlv_
	and		[esi].instr_addr, 0											;��। ������ ४��ᨥ� ���뢠�� ������ ���� � 0, �⮡� ����� �஢��﫨�� �� ������ ���� �������, � �� ᭮�� �� �������� � �.�.; 
_gf_g1stlv_:
	pop		esi 
	assume	esi: ptr XTG_FUNC_STRUCT
;--------------------------------------------------------------------------------------------------------

	push	gf_struct2_addr
	push	ebx
	call	xtg_main													;��뢠�� ���裥� ४��ᨢ�� 

	mov		eax, [ebx].nobw
	add		edi, eax													;᭮�� ���४��㥬 ���祭��;
	sub		gf_tmp_var1, eax 

	pop		[esi].param_num												;����⠭�������� ���� �������; 
	pop		[ebx].xmask2
	pop		[ebx].xmask1
	pop		[ebx].fmode

_gf_not_init_local_:
_gf_nxt_2_1_:		
_gf_cycle_1_:															;⥯��� �㤥� ������� call'� � ��६��� � ���襬; ���� ���� ���� ����; 
	push	gf_tmp_var1													;����砥� ��砩�� ࠧ��� ��।��� ���樨 ����; 
	call	[ebx].rang_addr
	
	mov		[ebx].tw_trash_addr, edi
	mov		[ebx].trash_size, eax	
	and		[ebx].nobw, 0

;--------------------------------------------------------------------------------------------------------
	push	esi
	mov		esi, gf_xids_addr 
	assume	esi: ptr XTG_INSTR_DATA_STRUCT	
	test	esi, esi													;᭮�� �஢��塞, ����� �� �� ������? 
	je		_gf_t_
	and		[esi].instr_addr, 0											;��। ������ ४��ᨥ� ���뢠�� ������ ���� � 0, �⮡� ����� �஢��﫨�� �� ������ ���� �������, � �� ᭮�� �� �������� � �.�.; 
_gf_t_:
	pop		esi 
	assume	esi: ptr XTG_FUNC_STRUCT
;--------------------------------------------------------------------------------------------------------
	
	push	gf_struct2_addr
	push	ebx
	call	xtg_main													;��뢠�� ���裥� ४��ᨢ��

	mov		eax, [ebx].nobw												;� EAX - �᫮ ॠ�쭮 ����ᠭ��� (��᫥ ४��ᨨ) ���� (����);   
	add		edi, eax													;���४��㥬 edi;
	sub		gf_tmp_var1, eax											;�⭨���� �� �㬬�୮�� ࠧ��� ���� ࠧ��� ⥪�饩 ��窨 ���ઠ; 
	cmp		ecx, edx													;⥯��� ᬮ�ਬ, ���� �� � ������ �㭪� �맮�� ��㣨� �㭪権? � �᫨ ����, � �� �� �� ����ᠫ�? 
	jge		_gf_nxt_3_
	add		esi, sizeof (XTG_FUNC_STRUCT)								;�᫨ �� �맮�� ���� � �� ����ᠫ� �� ��, � ᤥ���� ��!; ��३��� � ����� ᫥���饩 �������� XTG_FUNC_STRUCT, ����뢠�饩 �㭪�, �� ������ �㤥� ������ �맮�; 
	push	ecx
	xor		ecx, ecx
_gf_gen_init_param_:													;�� ��। �����樥� �맮��, ᭠砫� �஢�ਬ, ���� � �㭪�, �� ������ �㤥� �맮�, �室�� ��ࠬ����?

;--------------------------------------------------------------------------------------------------------
	push	esi
	mov		esi, gf_xids_addr 
	assume	esi: ptr XTG_INSTR_DATA_STRUCT	
	test	esi, esi													;᭮�� �஢��塞, ����� �� �� ������? 
	je		_gf_p_nxt_1_
	mov		[esi].instr_addr, edi										;⥯��� �����⮢���� � �஢�થ �室���� ��ࠬ��� - ��࠭�� ���� ���饩 �������
	mov		[esi].flags, XTG_ID_FUNC_PARAM								;� 㪠���, �� �஢����� �㤥� ��ࠬ���; 
_gf_p_nxt_1_:
	pop		esi 
	assume	esi: ptr XTG_FUNC_STRUCT
;--------------------------------------------------------------------------------------------------------

	cmp		ecx, [esi].param_num
	jge		_gf_nxt_2_2_ 												;�᫨ ����, � ᣥ����㥬 ��
	call	gen_param_for_func											;��뢠�� �㭪� �����樨 �室��� ��ࠬ��஢; 
	test	eax, eax													;�᫨ �� ����稫��� ᣥ����� ��ࠬ���, ��⠥��� ��� ࠧ; 
	je		_gf_gen_init_param_											;�᫨ �� ����稫���, � � eax �㤥� ࠧ��� ᣥ��७��� �������; 

;--------------------------------------------------------------------------------------------------------
	cmp		gf_xids_addr, 0												;᭮�� �஢��塞, ����� �� �� ������? 
	je		_gf_p_nxt_2_
	push	esi
	push	edx
	push	eax
	mov		esi, gf_xids_addr 
	assume	esi: ptr XTG_INSTR_DATA_STRUCT	
	mov		edx, gf_struct2_addr
	assume	edx: ptr XTG_EXT_TRASH_GEN
	mov		eax, [esi].instr_addr
	mov		[esi].instr_size, edi
	sub		[esi].instr_size, eax										;����塞 ࠧ��� ⮫쪮 �� ᣥ��७��� �������

	push	[edx].xlogic_struct_addr
	push	ebx
	call	let_main													;� �஢�ਬ, ���室�� �� ����� ��ࠬ��� ��� �� ������?

	test	eax, eax
	pop		eax
	pop		edx
	jne		_gf_pn2e1_													;�᫨ ��室��, ⮣�� ��룠�� ����� 
	mov		edi, [esi].instr_addr										;���� �⪠⨬�� ����� � ᭮�� ����ਬ ��ࠬ��� (���室�騩 ����� ᣥ������); 
	pop		esi
	jmp		_gf_gen_init_param_
_gf_pn2e1_:
	pop		esi
_gf_p_nxt_2_:
	assume	esi: ptr XTG_FUNC_STRUCT
;--------------------------------------------------------------------------------------------------------

	add		gf_tmp_var4, eax											;� gf_tmp_var4 �࠭���� ࠧ��� ��� ᣥ��७��� �室��� ��ࠬ��஢ (������) � ������ �㭪�; 
	inc		ecx															;���室�� � �����樨 ᫥���饣� ��ࠬ���; 
	jmp		_gf_gen_init_param_
_gf_nxt_2_2_:
	pop		ecx

;--------------------------------------------------------------------------------------------------------
	cmp		gf_xids_addr, 0												;᭮�� �஢��塞, ����� �� �� ������? 
	je		_gf_c_
	push	esi
	push	edx
	mov		esi, gf_xids_addr 
	assume	esi: ptr XTG_INSTR_DATA_STRUCT	
	mov		edx, gf_struct2_addr
	assume	edx: ptr XTG_EXT_TRASH_GEN
	mov		[esi].flags, XTG_ID_FUNC_CALL								;�����, 㪠�뢠��, �� ��� �㦭� (�����) ���権 ������� "call"; 

	push	[edx].xlogic_struct_addr
	push	ebx
	call	let_main

	pop		edx
	pop		esi

_gf_c_:
	assume	esi: ptr XTG_FUNC_STRUCT
;--------------------------------------------------------------------------------------------------------

	mov		eax, [esi].func_addr										;eax - ���� ����� �㭪�, �� ������ �㤥� �맮�;
	sub		eax, edi													;�⭨���� ⥪�騩 ���� (�� ����, �� ���஬� ᥩ�� �㤥� ᣥ���஢�� call); 
	sub		eax, 05														;� �⭨���� 5 (���⮢) - �� ࠧ��� �����; 
	push	eax															;� eax � ��� ⥯��� �⭮�⥫�� ���室 (rel32); 
	mov		al, 0E8h													;������㥬 ᠬ call; 
	stosb
	pop		eax
	stosd

	push	[ebx].xfunc_struct_addr										;��࠭�� � �⥪� ���� ��������, ᮮ�-饩 ⥪�饩 ������㥬�� �㭪�; 
	mov		[ebx].xfunc_struct_addr, esi								;����襬 � ������ ���� ���� �� ᫥������ ��������, ᮮ�-��� �㭪�, �� ������ ᥩ�� ᣥ��ਫ� ���室; 

	push	gf_struct2_addr
	push	gf_struct1_addr
	call	gen_func													;� ⥯��� ��뢠�� ४��ᨢ�� gen_func - ��� �㤥� ��ந�� �㭪�, �� ������ ᥩ�� �� ����஥� ���室; 

	pop		[ebx].xfunc_struct_addr										;����⠭�������� ���� � ������ ����; ��࠭塞/����⠭�������� ����� ���� ����� ��� ⮣�, �� �� ��� ᥩ�� �� �㤥� �㦥�;
																		;�᫨ �� save/restore � ��砫� gen_func, ⮣�� �� ��室� �� ४��ᨨ �㤥� ��������� ����, � ��� �㦥� ����, �� �� �� �맮�� ४��ᨨ...�����⨫ � ��� �।������� =); 
	xchg	eax, esi													;esi - ᮤ�ন� ���� �������� XTG_FUNC_STRUCT, ����� ᮮ�-�� ��᫥���� �� ����� ������ ᣥ���஢����� ४��ᨢ�� �㭪�; 
	inc		ecx															;���室�� � �����樨 ᫥���饣� �맮��; 
	jmp		_gf_cycle_1_
_gf_not_calls_:
_gf_nxt_3_:
	imul	eax, edx, (max_param_num * param_max_size)					;࠭��, �� ���⠫� ����� ���ᨬ���� ࠧ���, ⥯��� �� ��� �ਡ����;
	add		gf_tmp_var1, eax
	mov		eax, gf_tmp_var4
	sub		gf_tmp_var1, eax											;�� ���⥬ �� ࠧ���, ����� ॠ�쭮 �� ����ᠭ; �᫨ �� �맮��� �� �뫮 ��� ������ �㭪�, � � �室��� 
																		;��ࠬ��஢ ⮦� �� �뫮, � ����� �� �ਡ�������/���⠭�� ��祣� �� �����, ���祭�� � gf_tmp_var1, �㤥� ᡠ����஢����;
																		;�᫨ �� �맮�� �뫨, �� ��� ��� �� �뫮 �室��� ��ࠬ��஢, � ⠪�� �� �� - ��� ᡠ����஢��� ⥯���; 
	
	mov		eax, gf_tmp_var1											;eax - ᮤ�ন� ࠧ��� ��⠢襣��� ������ᠭ�� ����;
	mov		[ebx].tw_trash_addr, edi
	mov		[ebx].trash_size, eax	
	and		[ebx].nobw, 0

;--------------------------------------------------------------------------------------------------------
	cmp		gf_xids_addr, 0												;᭮�� �஢��塞, ����� �� �� ������? 
	je		_gf_t2_
	push	esi
	mov		esi, gf_xids_addr 
	assume	esi: ptr XTG_INSTR_DATA_STRUCT	
	and		[esi].instr_addr, 0											;���뢠�� ���� � 0;
	xor		[esi].param_1, XTG_XIDS_CONSTR ;							;� ���뢠�� ����� 䫠�, �⮡� ᣥ��ਫ��� �筮 �� �����; 
	pop		esi

_gf_t2_:
	assume	esi: ptr XTG_FUNC_STRUCT
;--------------------------------------------------------------------------------------------------------
	
	push	gf_struct2_addr												;� ����襬 ���; 
	push	ebx
	call	xtg_main													;��뢠�� ���裥� ४��ᨢ��

	add		edi, [ebx].nobw												;���४��㥬 ���� ��� ���쭥�襩 ����� ����; 

;--------------------------------------------------------------------------------------------------------
	cmp		gf_xids_addr, 0												;᭮�� �஢��塞, ����� �� �� ������? 
	je		_gf_e_
	push	esi
	mov		esi, gf_xids_addr 											;�����⮢���� � ��� ����� �㭪�
	assume	esi: ptr XTG_INSTR_DATA_STRUCT	
	mov		[esi].instr_addr, edi										;��࠭�� ���� ��砫� �����
	mov		[esi].flags, XTG_ID_FUNC_EPILOG								;� 㪠��� ᯥ�. 䫠���, �� �㤥� �㫨�� ����
	pop		esi
_gf_e_:
	assume	esi: ptr XTG_FUNC_STRUCT
;--------------------------------------------------------------------------------------------------------

_gf_epilog_:
	cmp		gf_tmp_var2, 01												;⥯��� ᣥ����㥬 ����
	jg		_gfe___mov__esp_ebp___pop__ebp_								;�᫨ ࠭�� �� ��ࠫ� leave, � ����襬 ���
_gfe_leave_:															;leave (1 byte)
	mov		al, 0C9h
	stosb
	jmp		_gf_nxt_4_
_gfe___mov__esp_ebp___pop__ebp_:										;����  
	mov		ax, 0E58Bh													;mov esp, ebp
	stosw																;pop ebp
	mov		al, 5Dh														;(3 bytes) 
	stosb
_gf_nxt_4_:
	cmp		gf_tmp_var3, 0												;�����, ᬮ�ਬ, ���� ��� ������ �㭪� �室�� ��ࠬ����?
	je		_gfe___ret_													;
_gfe___ret__XXh_: 														;�᫨ ����, ⮣�� ����ਬ ret XXh (XX = ���-�� �室��� ��ࠬ��஢ * 4 (ࠧ��� 1 �室���� ��ࠬ���)); 
	mov		al, 0C2h													;
	stosb
	mov		eax, gf_tmp_var3
	stosw
	jmp		_gf_nxt_5_
_gfe___ret_:															;���� ���� ret; 
	mov		al, 0C3h
	stosb

_gf_nxt_5_:

;--------------------------------------------------------------------------------------------------------
	cmp		gf_xids_addr, 0												;᭮�� �஢��塞, ����� �� �� ������? 
	je		_gf_ee_
	push	esi
	mov		esi, gf_xids_addr 
	assume	esi: ptr XTG_INSTR_DATA_STRUCT	
	mov		edx, [esi].instr_addr
	mov		[esi].instr_size, edi
	sub		[esi].instr_size, edx										;etc; ���᫨� ࠧ��� �����
	mov		edx, gf_struct2_addr
	assume	edx: ptr XTG_EXT_TRASH_GEN
	mov		edx, [edx].xlogic_struct_addr								; 
	assume	edx: ptr XTG_LOGIC_STRUCT									;

	push	edx
	push	ebx
	call	let_main													;���㫨� ���

	pop		eax															;eax = ࠭�� ��࠭񭭮� ���祭�� esi;
	pop		[esi].param_1												;����⠭���� ������ ����
	mov		edx, [edx].xlv_addr
	lea		edx, dword ptr [edx + (vl_lv_num + 01 + 01) * 4]			;� ����⠭���� �᫮ ��⨢��� �������� ��६�����; 
	pop		dword ptr [edx]
	xchg	eax, esi													;esi ⥯��� ����砥� ᢮� ࠭�� ��࠭񭭮� ���祭��; 

_gf_ee_:
	assume	esi: ptr XTG_FUNC_STRUCT
;--------------------------------------------------------------------------------------------------------

	pop		[ebx].nobw													;����⠭�������� �� �⥪� ࠭�� ��࠭���� ����; 
	pop		[ebx].trash_size
	pop		[ebx].tw_trash_addr

_gf_ret_:
	mov		dword ptr [ebp + 1Ch], esi									;��࠭塞 � eax ���� �������� XTG_FUNC_STRUCT, ����� ᮮ�-�� ⥪�饩 ������㥬�� �㭪�;
																		;�� �⮡� ᫥���騩 �맮� ����� �뫮 ᣥ����� �� �㭪�, ���ன ᮮ�-�� �������, ������ �� ����� � eax; 
	mov		esp, ebp
	popad
	ret		04 * 2														;��室�� 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;����� �㭪� gen_func 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx


 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;�㭪a gen_param_for_func
;������� �室��� ��ࠬ��஢ ��� �㭪樨
;����:
;	EBX						-	etc
;	[ebx].xfunc_struct_addr	-	���� �������� XTG_FUNC_STRUCT;
;�����:
;	EAX			-	0, �᫨ �� ����稫��� ᣥ�����, ���� � EAX ����� ����� ᣥ���஢����� �������; 
;�������:
;	�奬� ࠡ��� �㭪� ⠪��: � [ebx].xfunc_struct_addr �� ��।��� ���� ������ XTG_FUNC_STRUCT. 
;	�� ���� �᫨, ���ਬ��, �� ᥩ�� � �㭪� gen_func ������㥬 �㭪�, ���ன ᮮ⢥����� 2-�� �� 
;	����� ������� XTG_FUNC_STRUCT, ⮣�� � [ebx].xfunc_struct_addr ��।��� ���� �⮩ �� ������. 
;	��� ��� �室�� ��ࠬ���� �।�����祭� ��� 3-�� �㭪� (3-�� ��������), �� �����뢠�� ��, ����筮 
;	�� 2-�� =)
;	������� �ਬ��:
;		func_2:						;�� ��� 2-�� �㭪�
;			...						;��� �����-� ���� �������;
;			push	ecx				;� ��� �����뢠�� ��� ⠪��, ���ਬ��, �室��� ��ࠬ��� ��� func_3
;			call	func_3			;��뢠�� �㭪� 3
;			...						;
;		func_3:						;� ��� �� ��� �㭪� 3; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;PUSH	DWORD PTR [403008h]		etc (0FFh 35h XXXXXXXXh)
;PUSH	DWORD PTR [EBP - 14h]	etc (0FFh 75h XXh)
;PUSH	DWORD PTR [ebp + 14h]	etc (0FFh 75h XXh)
;PUSH	EAX						etc (5Xh)
;PUSH	05						etc (6Ah XXh)
;PUSH	123h					etc (68h XXXXXXXXh)
;etc
;!!!!! �᫨ ���⥫��� ������� ������� ��� � � moffs32, ⮣�� �������� ����� �㦭� ���;  
gen_param_for_func:

OFS_PARAM_PUSH_0FFh		equ		45
OFS_PARAM_PUSH_5Xh		equ		35
OFS_PARAM_PUSH_6Ah		equ		25
OFS_PARAM_PUSH_68h		equ		15 

	push	ecx															;��࠭�� � �⥪� ����� ॣ�; 
	push	esi

	mov		esi, [ebx].xfunc_struct_addr 
	assume	esi: ptr XTG_FUNC_STRUCT

	push	(OFS_PARAM_PUSH_0FFh + OFS_PARAM_PUSH_5Xh + OFS_PARAM_PUSH_6Ah + OFS_PARAM_PUSH_68h)
	call	[ebx].rang_addr

	cmp		eax, OFS_PARAM_PUSH_68h
	jl		_param_push_68h_
	cmp		eax, (OFS_PARAM_PUSH_68h + OFS_PARAM_PUSH_6Ah)
	jl		_param_push_6Ah_
	cmp		eax, (OFS_PARAM_PUSH_68h + OFS_PARAM_PUSH_6Ah + OFS_PARAM_PUSH_5Xh)
	jge		_param_push_0FFh_

_param_push_5Xh_:														;[PUSH REG32]
	call	get_rnd_r													;�롥६ ��砩�� ॣ;

	add		al, 50h
	stosb																;opcode
	xor		eax, eax
	inc		eax															;length of instr = 1 byte; 
	jmp		_gpff_ret_

_param_push_0FFh_:														;[PUSH MEM32]; [PUSH DWORD PTR [EBP -+ offset8]]; 
	push	02
	call	[ebx].rang_addr

	test	eax, eax
	je		_pp0FFh_with_ebp_

_pp0FFh_mem32_:															;[PUSH MEM32]
	call	check_data													;�஢�ਬ ᥪ�� ������ �� �ਣ�������; 

	test	eax, eax
	je		_gpff_ret_													;�᫨ ⠬ �����-� �㩭�, ⮣�� ��室��; 

	mov		ax, 035FFh
	stosw																;2 bytes;
		
	call	get_rnd_data_va												;����稬 ��砩�� ���� � ᥪ樨 ������
	
	stosd																;offset; 4 bytes; 
	push	06															;length = 6 bytes;
	pop		eax 
	jmp		_gpff_ret_

_pp0FFh_with_ebp_:														;[PUSH DWORD PTR [EBP +- offset8]]; 
	push	02
	call	[ebx].rang_addr

	shl		eax, 02														;eax = ���� 0 ���� 4 (0 - ��� �����樨 �室���� ��ࠬ��� - �����. ��६., ���� 4 - ��� �室. ����-�); 
	xchg	eax, ecx
	xor		eax, eax
	test	ecx, ecx
	je		_ebp_local_
_ebp_param_:															;[PUSH DWORD PTR [EBP + offset8]]; �� �᫨ � ��襩 ⥪�饩 �㭪� ���� �室�� ��ࠬ���� ��� �� �ᯮ�짮����� ⠪�� � ����⢥ �室��� ��ࠬ��஢, �� �� �맮�� ��㣮� �㭪�; 
	cmp		[esi].param_num, 0
	je		_gpff_ret_ 
	cmp		[esi].param_num, (80h / 04)									;�᫨ �室��� ��ࠬ��஢ >= ������� ���祭��, ⮣�� �� ���� �㦭� �����஢��� ������� � offset32, �� �� ���� ���� �멤��; 
	jge		_gpff_ret_
	mov		ax, 75FFh													;2 bytes;
	stosw

	push	[esi].param_num												;��砩�� �롥६, ���祭�� ������ �室���� ��ࠬ��� �㤥� ��।������� � �⥪?; 
	call	[ebx].rang_addr

	inc		eax															;�室��� ��ࠬ��� �������筮 �㤥�; 
	imul	eax, eax, 04												;㬭����� �� 4, ⠪ ��� ࠧ��� �室���� ��ࠬ-� = 4 ���� (sizeof (dword)); 
	add		eax, ecx													;ᠬ� ���� �室��� ��ࠬ��� �㤥� ��稭����� � ��� �ᥣ�� � dword ptr [ebp + 08]; 
	jmp		_gpff_nxt_1_
_ebp_local_:															;[PUSH DWORD PTR [EBP - offset8]]; �� �᫨ � �㭪� ���� ������� ��६����; 
	cmp		[esi].local_num, 0
	je		_gpff_ret_
	cmp		[esi].local_num, (84h / 04)									;etc, �� ���� �� - push dword ptr [ebp - 80h] - 80h - �� �� offset8, � 84h - 㦥 offset32; 
	jge		_gpff_ret_
	mov		ax,75FFh													;2 bytes; 
	stosw

	push	[esi].local_num												;etc
	call	[ebx].rang_addr

	inc		eax 
	imul	eax, eax, 04
	add		eax, ecx
	neg		eax															;⠪ ��� �� �����. ��६�����, � �������㥬 ����祭��� ���祭��; ᬮ�ਬ � ����, � �⫠�稪 � �.�.=)! 
_gpff_nxt_1_:
	stosb																;1 byte; 
	push	03															;length = 3 bytes;
	pop		eax
	jmp		_gpff_ret_
_param_push_6Ah_:														;[PUSH IMM8]
	mov		al, 06Ah
	stosb

	push	256
	pop		eax
	call	get_rnd_num_1 

	stosb
	push	02															;length = 2 bytes;
	pop		eax
	jmp		_gpff_ret_
_param_push_68h_: 														;[PUSH IMM32]
	mov		al, 68h
	stosb

	mov		eax, 1000h													;����稬 ��;
	call	get_rnd_num_1 

	add		eax, 80h													;IMM32 >= 80h
	stosd
	push	05															;����� ������� = 5 ���⮢; 
	pop		eax
_gpff_ret_:	
	pop		esi															;����⠭�������� ॣ�; 
	pop		ecx
	ret
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;����� �㭪� gen_param_for_func 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   







 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;�㭪a xtg_data_gen
;������� ������ (��ப, �ᥫ);
;���� (stdcall xtg_data_gen(DWORD xparam1, DWORD xparam2)):
;	xparam1			-	���� �������� XTG_TRASH_GEN
;	xparam2			-	XTG_DATA_STRUCT
;�����:
;	(+)				-	ᣥ���஢���� �����
;	(+)				-	���������� ��室�� ���� �������� XTG_DATA_STRUCT
;	EAX				-	ࠧ��� (� �����) ॠ�쭮 ᣥ���஢����� ������; 
;�������:
;	�������� ������� ��砩��� ��ப, �ᥫ. 
;	��᫮: ࠧ��� = 4 ���� (32-� ࠧ�來��). ���� �᫠ ��⥭ 4. 
;	��ப�: max ����� = 16 ����. ����� ��ப� ��⭠ 4 � ��஢���� ��ﬨ. ��ப� � ���(ﬨ) � ����. 
;	���� ��ப� ��⥭ 4. ���������� ansi-��ப�. 
;	��᫮ ����� ���� ⠪�� �����:
;		
;		0x555
;		0x1234
;		etc
;
;	��ப� ����� ���� ⠪�� �����:
;
;		'123asHk'
;		'7Kjgh.txt'
;		'faq.exe'
;		'ahe.dll'
;		'a5789.m5p'
;		etc	
; 
;	���: �᫨ �������� ��ப�, �� ᨬ���� �㦠� ��� �����樨 ��ப, � ��⮤ �����樨 ��� ������
;	(��ப/�ᥫ), ⮣�� �।�ᬮ���� ��������� � � ������ FAKA (� ����� ��, ��� �㦭�); 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
xtg_dg_struct1_addr		equ		dword ptr [ebp + 24h]					;XTG_TRASH_GEN
xtg_dg_struct2_addr		equ		dword ptr [ebp + 28h]					;XTG_DATA_STRUCT

xtg_dg_tmp_var1			equ		dword ptr [ebp - 04]					;ࠧ���� �ᯮ����⥫�� ��६����
xtg_dg_tmp_var2			equ		dword ptr [ebp - 08]
xtg_dg_tmp_var3			equ		dword ptr [ebp - 12]
xtg_dg_tmp_var4			equ		dword ptr [ebp - 16]
xtg_dg_tmp_var5			equ		dword ptr [ebp - 20]

xstr_max_len			equ		16										;���ᨬ���� ࠧ��� ��ப�
xnum_size				equ		04										;ࠧ��� ������㥬��� �᫠
xgen_str_len			equ		(16 * 04)								;����� ��ப� ᨬ����� - � ������� ��� ᨬ����� �� ����ਬ ��ப�; 16 (push) * 4 (���-�� ᨬ����� � �⥪�); 
xstr_min_len			equ		07										;�������쭠� ����� ��ப�; 

xtg_data_gen:
	pushad																;��࠭塞 ��� � �⥪�
	cld
	mov		ebp, esp
	sub		esp, 24
	push	'abcd'														;01
	push	'efgh'														;02
	push	'ijkl'														;03
	push	'mnop'														;04
	push	'qrst'														;05
	push	'uvwx'														;06
	push	'yzAB'														;07
	push	'CDEF'														;08
	push	'GHIJ'														;09
	push	'KLMN'														;10
	push	'OPQR'														;11
	push	'STUV'														;12
	push	'WXYZ'														;13
	push	'0123'														;14
	push	'4567'														;15
	push	'89_a'														;16
	mov		xtg_dg_tmp_var5, esp										;��࠭塞 � ������ ��६����� ���� ��ப�, �㦭�� ��� �����樨 ��ப; 
	mov		ebx, xtg_dg_struct1_addr
	assume	ebx: ptr XTG_TRASH_GEN
	mov		esi, xtg_dg_struct2_addr
	assume	esi: ptr XTG_DATA_STRUCT
	mov		edi, [esi].rdata_addr										;edi - ���� � 䠩��(!), �㤠 ᣥ����� ������ �����;
	mov		ecx, [esi].rdata_size										;ecx - ࠧ��� �⮩ ������ �����; 
	mov		xtg_dg_tmp_var1, 'exe.'										;� ᫥���騥 3 ��६���� ��࠭�� �������� ���७��; 
	mov		xtg_dg_tmp_var2, 'lld.'
	mov		xtg_dg_tmp_var3, 'txt.'
	test	edi, edi													;�᫨ ���� � 䠩�� (�� ��� ��⮢ ����� ��।����� ���� ��砫� ������ ������ (ᥪ樨 ������)) ࠢ�� ���, 
	je		_xdg_ret_													;� �� ��室; 
	cmp		ecx, 04h													;���� �᫨ ࠧ��� ������ (ᥪ樨) ������ ����� 4-�, ⮣�� �� ��室; 
	jb		_xdg_ret_ 
	test	[esi].xmask, XTG_DG_NUM32									;�᫨ ���⠢��� ����� 䫠�, ⮣�� �ਭ����� �� ��������� ࠧ��� - ࠧ��� �᫠ - 4 ����; 
	je		_xmask_str_ 
_xmask_num_:															;4 ����;
	push	xnum_size
	pop		edx
	jmp		_xdg_nxt_1_
_xmask_str_:															;���� 16 ����; 
	push	xstr_max_len
	pop		edx

_xdg_nxt_1_:

_xdg_cycle_:															;�����, � 横�� �������� ������� ����� ���蠪��-����묨; 
	cmp		ecx, edx													;�᫨ ���-�� ��⠢���� ��� �����樨 ��ப � �ᥫ ���⮢ ����� �������쭮 ࠧ���, ⮣�� �� ��室; 
	jl		_xdg_ret_ 

	push	02
	call	[ebx].rang_addr

	bt		[esi].xmask, eax											;���� ��砩�� ��।����, �� ᥩ�� �㤥� �����஢���: ��ப� ��� �᫮?
	jnc		_xdg_cycle_
	test	eax, eax
	je		xtg_dg_gen_strA
	dec		eax
	je		xtg_dg_gen_num32

_xdg_ret_:
	mov		eax, [esi].rdata_size
	sub		eax, ecx
	mov		[esi].nobw, eax 
	mov		dword ptr [ebp + 1Ch], eax									;eax - ᮤ�ন� ���-�� ॠ�쭮 ����ᠭ��� ���⮢; 
	mov		esp, ebp 
	popad
	ret		04 * 2
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;����� �㭪� xtg_data_gen
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx





;========================================[GEN STRING ANSI]===============================================
;'abcde'
;etc 
xtg_dg_gen_strA:
	cmp		ecx, xstr_max_len											;���� �� ��ਠ�� ᣥ����� ��ப�?
	jl		_xdg_cycle_
	push	ecx															;�᫨ ��, ⮣�� ᭠砫� ��࠭�� �㦭� ॣ�
	push	edx
	push	esi
	push	edi
	xor		edx, edx													;���㫨� edx
	mov		esi, xtg_dg_tmp_var5										;esi - ᮤ�ন� ���� ��ப� - �� ᨬ����� �⮩ ��ப� �㤥� �����஢��� ��ப�; 

	push	(xstr_max_len - xstr_min_len)
	call	[ebx].rang_addr

	add		al, xstr_min_len
	xchg	eax, ecx													;����砥� ��砩�� ࠧ��� ���饩 ��ப� (max ࠧ��� ��ப� ᥩ�� = 16 ���⮢); � ��࠭塞 ��� � ecx; 
	mov		xtg_dg_tmp_var4, ecx										;� ⠪�� ��࠭�� ���祭�� � ������ ��६�����; 

	push	02
	call	[ebx].rang_addr

	test	eax, eax													;��砩�� ��।����, �㤥� ������� ��ப� � ���७��� ��� ���?
	jne		_xdgs_name_

_xdgs_use_ext_:															;����ਬ ��ப� � ���७���; ���७�� ��⮨� �� 4 ᨬ�����: '.' � ��� 3 ࠧ����� ᨬ����; 
	push	04
	call	[ebx].rang_addr												;⥯��� ��砩�� ��।����, ����� ������ �㤥� ���७��?

	test	eax, eax	
	je		_xdgs_exe_
	dec		eax
	je		_xdgs_dll_
	dec		eax
	je		_xdgs_txt_
_xdgs_xext_:															;��� ᮧ���� ᢮� ���७��; 
	push	edi
	lea		edi, dword ptr [edi + ecx - 04]								;edi = ���� ��ப� + ࠧ��� ��ப� - 4 ���� = ����, ��� ����襬 ���७��; 
	mov		al, '.'
	stosb																;�����뢠�� ���� ᨬ���; 
	push	03
	pop		edx

_xdgs_xext_cycle_:
	push	xgen_str_len 
	call	[ebx].rang_addr												;� ����� �� ᣥ��ਬ � ����襬 �� 3 ᨬ����; 

	mov		al, byte ptr [esi + eax]									;�� ᨬ���� �롥६ ��砩�� �� ��ப� ᨬ����� ��� �����樨 ��ப; 
	stosb
	dec		edx
	jne		_xdgs_xext_cycle_ 
	pop		edi
	jmp		_xdgs_nxt_2_ 
_xdgs_exe_:																;'.exe'
	push	xtg_dg_tmp_var1
	jmp		_xdgs_nxt_1_
_xdgs_dll_:																;'.dll'
	push	xtg_dg_tmp_var2
	jmp		_xdgs_nxt_1_
_xdgs_txt_:																;'.txt'
	push	xtg_dg_tmp_var3
_xdgs_nxt_1_: 
	pop		dword ptr [edi + ecx - 04]									;����襬;
_xdgs_nxt_2_:
	push	04															;��� ᪮�४��㥬 ���-�� ���⮢ ��� ����� ��ப�
	pop		edx															;⠪ ��� ���७�� (4 ����) �� 㦥 ����ᠫ�, � �⭨��� �� �᫮; 
	sub		ecx, edx

_xdgs_name_:
_xdgs_name_cycle_:														;� ��� ᣥ��ਬ � ����襬 ���; 
	push	xgen_str_len
	call	[ebx].rang_addr

	mov		al, byte ptr [esi + eax]
	stosb
	dec		ecx
	jne		_xdgs_name_cycle_ 
	add		edi, edx													;�᫨ �� �� �� �����뢠�� ���७��, � ��।����� edi �� ����� ���७��, �⮡� ������� �㫨 � ���� ��ப�;
																		;�᫨ �� ���७�� �� �뫮, ⮣�� � edx �㤥� 0 (edx = 0); 
	and		xtg_dg_tmp_var4, 03
	push	04
	pop		ecx
	sub		ecx, xtg_dg_tmp_var4										;� ��� ᤥ���� ��ப� �� ����� ��⭮� 4;
	xor		eax, eax
_xdgs_wzero_:	
	stosb																;����襬 �㫨;
	dec		ecx
	jne		_xdgs_wzero_

	pop		edx
	mov		eax, edi
	sub		eax, edx
	pop		esi
	pop		edx
	pop		ecx
	sub		ecx, eax													;᪮�४��㥬 ����稪 - �⭨��� �� ���-�� ��⠢���� ���� ����� ⮫쪮 �� ����ᠭ��� ��ப�; 
	jmp		_xdg_cycle_
;========================================[GEN STRING ANSI]===============================================



;========================================[GEN NUMBER 32-BIT]=============================================	
;12h 34h 56h 78h
;etc
xtg_dg_gen_num32:
	cmp		ecx, xnum_size												;�஢��塞, ���� �� ����� ��� �����樨 �᫠?
	jl		_xdg_cycle_	
	push	edx

	push	10000h
	call	[ebx].rang_addr

	xchg	eax, edx

	push	edx
	call	[ebx].rang_addr

	and		eax, edx													;�᫨ ⠪, � ����ਬ ��
	pop		edx
	stosd																;� �����뢠�� ���
	sub		ecx, xnum_size												;���४��㥬 ����稪; 
	jmp		_xdg_cycle_ 
;========================================[GEN NUMBER 32-BIT]=============================================

 
 

 




	 
  

