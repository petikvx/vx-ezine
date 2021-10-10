;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
;																										 ;
;					xxxxxxxxxxxx    xxxxxxxxx    xxxx    xxxx    xxxxxxxxx								 ;
;					xxxxxxxxxxxx   xxxxxxxxxxx   xxxx   xxxx    xxxxxxxxxxx								 ;
;					xxxx          xxxx     xxxx  xxxx  xxxx    xxxx     xxxx							 ;
;					xxxx          xxxx     xxxx  xxxx xxxx     xxxx     xxxx							 ;
;					xxxxxxxxxx    xxxx xxx xxxx  xxxxxxxx      xxxx xxx xxxx							 ;
;					xxxxxxxxxx    xxxx xxx xxxx  xxxxxxxx      xxxx xxx xxxx							 ;
;					xxxx          xxxx     xxxx  xxxx xxxx     xxxx     xxxx							 ;
;					xxxx          xxxx     xxxx  xxxx  xxxx    xxxx     xxxx							 ;
;					xxxx          xxxx     xxxx  xxxx   xxxx   xxxx     xxxx							 ;
;					xxxx          xxxx     xxxx  xxxx    xxxx  xxxx     xxxx							 ; 
;																										 ;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
;									FAKe winApi generator												 ;
;											FAKA														 ;
;										  faka.asm														 ; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx; 
;																										 ;
;											=)															 ;
;																										 ; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
;																										 ;
;											FAKA														 ;
;					������� ������ ������襪 (������ �맮��� ������ �㭪権)						 ;
;																										 ;
;���� (stdcall: DWORD FAKA(DWORD xparam)):																 ;
;	xparam				-	���� �������� FAKA_FAKEAPI_GEN											 ;
;--------------------------------------------------------------------------------------------------------;
;�����:																									 ;
;	(+)					-	ᣥ���஢���� ����� �맮� ������誨									 ;
;	(+)					-	���������� ��室�� ���� �������� FAKA_FAKEAPI_GEN						 ;
;	EAX					-	���� ��� ���쭥��� ����� ����											 ;
;--------------------------------------------------------------------------------------------------------;
;																										 ;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
;v2.0.0 


																		;m1x
																		;pr0mix@mail.ru
																		;EOF



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;�㭪� FAKA
;������� ��-������ �㭪権;
;���� (stdcall DWORD FAKA(DWORD xparam)):
;	xparam		-	���� �������� FAKA_FAKEAPI_GEN;
;�����:
;	(+)			-	ᣥ���஢����� ��-������誠
;	(+)			-	���������� ��室�� ���� �������� FAKA_FAKEAPI_GEN
;	EAX			-	���� ��� ���쭥�襩 ����� ����; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
faka_struct1_addr	equ		dword ptr [ebp + 24h]						;FAKA_FAKEAPI_GEN

faka_imnth			equ		dword ptr [ebp - 04]						;����� �㤥� �࠭����� ���� � 䠩�� �� �������� IMAGE_NT_HEADERS
faka_imagebase		equ		dword ptr [ebp - 08]						;����� �㤥� ������ ���� ����㧪� 䠩�� (aka ���� OptionalHeader.ImageBase);
faka_iat_size		equ		dword ptr [ebp - 12]						;ࠧ��� IAT - ⠡���� ���ᮢ ������;
faka_imsh			equ		dword ptr [ebp - 16]						;IMAGE_SECTION_HEADER
faka_alloc_addr		equ		dword ptr [ebp - 20]						;���� �뤥������� ���⪠ �����
faka_tmp_esp		equ		dword ptr [ebp - 24]						;����� ��࠭�� ���祭�� esp (� ��᫥ ����⠭����); 
faka_tmp_var1		equ		dword ptr [ebp - 28]						;tmp var; 

faka_stack_size		equ		5000h										;���� ����㠫쭮� �����, �뤥�塞�� ��� �⥪ (����� ������� ���� �⥪� � esp �� ᢮� ���� � �뤥������ ����� - ��� �����樨 ����襣� ���-�� �㭪権); 

FAKA:
	pushad																;��࠭�� � �⥪� ॣ�
	cld
	mov		ebp, esp
	sub		esp, 32
	mov		ebx, faka_struct1_addr
	assume	ebx: ptr FAKA_FAKEAPI_GEN									;ebx - ���� �������� FAKA_FAKEAPI_GEN
	and		faka_alloc_addr, 0
	mov		faka_tmp_esp, esp
	and		[ebx].nobw, 0 												;���㫨� ������ ����
	and		[ebx].api_va, 0												;�ந��樠�����㥬 ������ ���� -> ��� = 0; 
	mov		eax, [ebx].tw_api_addr
	mov		[ebx].fnw_addr, eax											;� �� ���� ����砫쭮 ࠢ�� �����, �㤠 �㤥� �����뢠�� ᣥ���஢���� ���蠪; 

	cmp		[ebx].api_size, WINAPI_MAX_SIZE								;�᫨ ��।����� ���-�� ���⮢ ��� �����樨 ��-������ ����� ������� ���祭��, ⮣�� �� ��室; 
	jl		_faka_ret_ 
	cmp		[ebx].alloc_addr, 0											;���� �� ��ਪ �뤥���� ������ ��� ����� faka'�?
	je		_faka_nxt_1_
	cmp		[ebx].free_addr, 0
	je		_faka_nxt_1_

_faka_alloc_mem_:
	push	(NUM_HASH * 4 + faka_stack_size + 4)						;�᫨ ����, ⮣�� �뤥���, �� 
	call	[ebx].alloc_addr

	test	eax, eax 
	je		_faka_nxt_1_												;�᫨ �� ����稫��� �뤥���� ������, ⮣�� �뤥��� �� �� ���; 
	mov		faka_alloc_addr, eax										;��࠭�� ���� �뤥������ ����� � ������ ��६�����
	lea		esp, dword ptr [eax + (NUM_HASH * 4 + faka_stack_size)]		;᪮�४��㥬 esp �� ���� "������" �⥪�

_faka_nxt_1_:
	mov		esi, [ebx].mapped_addr 
	assume	esi: ptr IMAGE_DOS_HEADER

	push	esi
	call	valid_pe													;��� ��砫� �஢�ਬ �� ���४⭮��� 䠩�;

	test	eax, eax													;�᫨ 䠩� �� ��襫 ���� �஢���, ���� �� �㦥� - ��室��;
	je		_faka_ret_
	add		esi, [esi].e_lfanew
	assume	esi: ptr IMAGE_NT_HEADERS
	mov		faka_imnth, esi												;IMAGE_NT_HEADERS
	mov		eax, [esi].OptionalHeader.ImageBase
	mov		faka_imagebase, eax											;ImageBase
	mov		ecx, [esi].OptionalHeader.DataDirectory[1 * 8].VirtualAddress
	mov		edx, [esi].OptionalHeader.DataDirectory[1 * 8].isize		;ecx = RVA IAT; edx = size of IAT;
	test	ecx, ecx													;�᫨ �����-���� �� ��� ����� = 0, ⮣�� IAT ��⠥� �����४�� � ��室��;
	je		_faka_ret_
	test	edx, edx
	je		_faka_ret_ 
	mov		faka_iat_size, edx											;����, ��࠭�� ࠧ��� iat � ������ ��६�����

	lea		eax, faka_tmp_var1
	push	eax 
	push	ecx
	push	[ebx].mapped_addr
	call	rva_to_offset												;����稬 �� IAT_RVA ���� � 䠩�� (���뢠� mapped_addr);

	test	eax, eax													;�᫨ �� ��室� ����稫� 0, ⮣�� ���� � 䠩�� �� ������, � ����� �� ��室;
	je		_faka_ret_ 
	xchg	eax, esi													;��࠭�� ���� IAT � 䠩�� � ॣ� esi; 

	push	00000000h													;����� � ��� 0 - �� �㤥� ������� ����� ��襩 ⠡��窨 ��襩;
	
	cmp		[ebx].api_hash, 0											;⥯��� �஢�ਬ, ��������� �� ������ ����?
	jne		_faka_search_api_

;------------------------------------------[������� �����]-----------------------------------------------
																		;⠡��� ��襩 �� ��� �㭪権;
																		;��� ⮣�, �⮡� ����� ������ ��� ������� ����� �맮�� ����� ���襪, ������ ᫥����饥:
																		;1) ����砥� ��� �� ����� ⮩ ���誨, 祩 ����� �맮� �⨬ �����஢��� (CRC32);
																		;2) ����� ��� � ��� ⠡���� (���ਬ��, push 12345678h etc);
																		;3) 㢥��稢��� �� +1 ���祭�� NUM_HASH;
																		;4) �� � ����筮 �� ��襬 ᢮� �㭪� ॠ����樨 ������� �맮�� (��������� ��, �� 㦥 ����) � ������ �ࠢ����� � ���室 �� ��� �㭪�; 
																		;5) ���; 

																		;⠡��窠 ��襩 - �࠭�� �� � �⥪�;
																		;�� ��⥪�� �����-� ���襪, ���� ���� ᭮ᨬ �� ���ᤠ, ���� ��९��뢠�� ��ଠ�쭮 �������; 
																		
																		;kerne32.dll
	push	0AD56B042h													;QueryPerformanceCounter
	push	03FD5EECFh													;QueryPerformanceFrequency
	push	0D6874364h													;lstrcmpiA
	push	06B3F543Dh													;lstrcmpA
	push	0AE03DF57h													;lstrcpyA
	push	0E90E2A0Ch													;lstrlenA
	push	0D22204E4h													;GetSystemTime
	push	01BB43D20h													;GetLocalTime
	push	04CCF1A0Fh													;GetVersion; 
	push	0B1530C3Eh													;GetOEMCP; 
	push	08DF87E63h													;GetCurrentThreadId
	push	0D0861AA4h													;GetCurrentProcess
	push	05B4219F8h													;GetTickCount
	push	01DB413E3h													;GetCurrentProcessId
	push	040F6426Dh													;GetProcessHeap
	push	0D777FE44h													;GetACP
	push	02D66B1C5h													;GetCommandLineA
	push	019E65DB6h													;GetCurrentThread
	push	08436F795h													;IsDebuggerPresent
	push	0516EAD48h													;GetThreadLocale
	push	0D9B20494h													;GetCommandLineW
	push	0A67EECABh													;GetSystemDefaultLangID
	push	04ABB7503h													;GetSystemDefaultLCID
	push	0E9CE019Eh													;GetUserDefaultUILanguage
	push	0380CBEEEh													;MulDiv
	push	01C58403Ch													;IsValidCodePage
	push	0F6A56750h													;GetDriveTypeA
	push	035723537h													;IsValidLocale
	push	0B1866570h													;GetModuleHandleA
	;push	03FC1BD8Dh													;LoadLibraryA
	push	0C97C1FFFh													;GetProcAddress

																		;user32
	push	06A64AAF8h													;GetFocus
	push	04B220411h													;GetDesktopWindow
	push	0AFC7EE9Ch													;GetCursor
	push	017B33F70h													;GetActiveWindow
	push	05D79D927h													;GetForegroundWindow
	push	0782D6F29h													;GetCapture
	push	010F8F6EBh													;GetMessagePos
	push	087BC6D66h													;GetMessageTime
	push	0DB0F4F04h													;GetDlgItem
	push	05736E45Dh													;GetParent
	push	005C64EA2h													;GetSystemMetrics
	push	06F2737AEh													;IsDlgButtonChecked
	push	0EBD65FA8h													;IsWindowVisible
	push	0393D7B53h													;IsIconic
	push	0C19F0C75h													;IsWindowEnabled
	push	02E102B44h													;CheckDlgButton
	push	0402F6E2Fh													;GetSysColor
	push	02B510B7Fh													;GetKeyState
	push	0FE4B0747h													;GetDlgCtrlID
	push	06B668BFAh													;GetSysColorBrush
	push	0D9ADC55Ch													;SetActiveWindow
	push	0E4191C8Bh													;IsChild
	push	01698A886h													;GetTopWindow
	push	0EF5B0128h													;GetKeyboardType
	push	0A129CDE7h													;GetKeyboardLayout
	push	049188291h													;IsZoomed
	push	0B9D3B88Dh													;GetWindowTextLengthA
	push	0DFBA6BA5h													;DrawIcon
	push	0E07C965Fh													;GetClientRect
	push	0A4E0595Ah													;GetWindowRect
	push	092626EFCh													;CharNextA
	push	089606806h													;GetCursorPos
	push	0AC9E8550h													;LoadIconA
	push	0034DF7BBh													;LoadCursorA
	push	0C1698B74h													;FindWindowA

																		;gdi32.dll
	push	0941C08E5h													;SelectObject
	push	07725AEC5h													;SetTextColor
	push	05F550585h													;SetBkColor
	push	09734E948h													;SetBkMode
	push	0CEE8783Ah													;Rectangle
	push	0783B7846h													;GetTextColor
	push	071102417h													;GetBkColor
	push	083BEBFF6h													;Ellipse
	push	05836E111h													;GetNearestColor
	push	03B9BDDD6h													;GetObjectType
	push	09420C409h													;PtVisible
	push	0A818302Eh													;GetMapMode
	push	06618FA35h													;GetBkMode
	
;------------------------------------------[������� �����]-----------------------------------------------

	mov		edx, NUM_HASH												;���-�� �襩
	mov		edi, esp													;���� ⠡��窨 ��襩
	call	rnd_swap_elem												;ࠧ��蠥� ������ (���) ������ ⠡���� ��砩�� ��ࠧ��

_faka_sa_cycle_:	
	pop		eax															;⥯��� ���� �� ��� ��।��� ��� 
	test	eax, eax													;� �஢��塞: �᫨ �� ����, ⮣�� ��� ⠡���� �� �ண����, ��室��
	je		_faka_ret_

	mov		[ebx].api_hash, eax											;�᫨ �� �� ���, � ����㧨� ��� � [ebx].api_hash

_faka_search_api_:
	call	search_api 													;� �맮��� �㭪� ���᪠ ���誨 (����) �� ���� �� �� �����;

	test	eax, eax													;�᫨ �㦭�� ����� �� ��諨, ⮣�� ���室�� � ����� ��㣮� ���誨 �� �� ����;
	je		_faka_sa_cycle_
	
	mov		edi, [ebx].tw_api_addr										;����, � edi - ����, �㤠 �㤥� ����� ᣥ���஢���� �맮� ���誨;

																		;kernel32.dll
	cmp		eax, 04CCF1A0Fh												;�� ��誠 GetVersion?
	je		_faka_winapi_0_param_
	cmp		eax, 0AD56B042h												;QueryPerformanceCounter
	je		_faka_QueryPerformanceCounter_
	cmp		eax, 03FD5EECFh												;QueryPerformanceFrequency
	je		_faka_QueryPerformanceFrequency_
	cmp		eax, 0D6874364h												;lstrcmpiA
	je		_faka_lstrcmpiA_
	cmp		eax, 06B3F543Dh												;lstrcmpA
	je		_faka_lstrcmpA_
	cmp		eax, 0AE03DF57h												;lstrcpyA
	je		_faka_lstrcpyA_
	cmp		eax, 0E90E2A0Ch												;lstrlenA
	je		_faka_lstrlenA_
	cmp		eax, 0D22204E4h												;GetSystemTime
	je		_faka_GetSystemTime_
	cmp		eax, 01BB43D20h												;GetLocalTime
	je		_faka_GetLocalTime_
	cmp		eax, 0B1530C3Eh												;GetOEMCP
	je		_faka_winapi_0_param_
	cmp		eax, 08DF87E63h												;GetCurrentThreadId
	je		_faka_winapi_0_param_
	cmp		eax, 0D0861AA4h												;GetCurrentProcess
	je		_faka_winapi_0_param_
	cmp		eax, 05B4219F8h												;GetTickCount; 
	je		_faka_winapi_0_param_ 
	cmp		eax, 01DB413E3h												;GetCurrentProcessId 
	je		_faka_winapi_0_param_
	cmp		eax, 040F6426Dh												;GetProcessHeap
	je		_faka_winapi_0_param_
	cmp		eax, 0D777FE44h												;GetACP
	je		_faka_winapi_0_param_
	cmp		eax, 02D66B1C5h												;GetCommandLineA
	je		_faka_winapi_0_param_
	cmp		eax, 019E65DB6h												;GetCurrentThread
	je		_faka_winapi_0_param_
	cmp		eax, 08436F795h												;IsDebuggerPresent
	je		_faka_winapi_0_param_
	cmp		eax, 0516EAD48h												;GetThreadLocale
	je		_faka_winapi_0_param_
	cmp		eax, 0D9B20494h												;GetCommandLineW
	je		_faka_winapi_0_param_
	cmp		eax, 0A67EECABh												;GetSystemDefaultLangID
	je		_faka_winapi_0_param_
	cmp		eax, 04ABB7503h												;GetSystemDefaultLCID
	je		_faka_winapi_0_param_
	cmp		eax, 0E9CE019Eh												;GetUserDefaultUILanguage
	je		_faka_winapi_0_param_
	cmp		eax, 0380CBEEEh												;MulDiv
	je		_faka_MulDiv_
	cmp		eax, 01C58403Ch												;IsValidCodePage
	je		_faka_IsValidCodePage_
	cmp		eax, 0F6A56750h												;GetDriveTypeA
	je		_faka_GetDriveTypeA_
	cmp		eax, 035723537h												;IsValidLocale
	je		_faka_IsValidLocale_	           
	cmp		eax, 0B1866570h												;GetModuleHandleA
	je		_faka_GetModuleHandleA_
	;cmp	eax, 03FC1BD8Dh												;LoadLibraryA
	;je		_faka_LoadLibraryA_
	cmp		eax, 0C97C1FFFh												;GetProcAddress
	je		_faka_GetProcAddress_

																		;user32.dll
	cmp		eax, 06A64AAF8h												;GetFocus
	je		_faka_winapi_0_param_
	cmp		eax, 04B220411h												;GetDesktopWindow
	je		_faka_winapi_0_param_
	cmp		eax, 0AFC7EE9Ch												;GetCursor
	je		_faka_winapi_0_param_
	cmp		eax, 017B33F70h												;GetActiveWindow
	je		_faka_winapi_0_param_
	cmp		eax, 05D79D927h												;GetForegroundWindow
	je		_faka_winapi_0_param_
	cmp		eax, 0782D6F29h												;GetCapture
	je		_faka_winapi_0_param_
	cmp		eax, 010F8F6EBh												;GetMessagePos
	je		_faka_winapi_0_param_
	cmp		eax, 087BC6D66h												;GetMessageTime
	je		_faka_winapi_0_param_
	cmp		eax, 0DB0F4F04h												;GetDlgItem
	je		_faka_winapi_2_param_ 
	cmp		eax, 06F2737AEh												;IsDlgButtonChecked
	je		_faka_winapi_2_param_
	cmp		eax, 0E4191C8Bh												;IsChild
	je		_faka_winapi_2_param_
	cmp		eax, 05736E45Dh												;GetParent
	je		_faka_winapi_1_param_
	cmp		eax, 0EBD65FA8h												;IsWindowVisible
	je		_faka_winapi_1_param_
	cmp		eax, 0393D7B53h												;IsIconic
	je		_faka_winapi_1_param_
	cmp		eax, 0C19F0C75h												;IsWindowEnabled
	je		_faka_winapi_1_param_
	cmp		eax, 0FE4B0747h												;GetDlgCtrlID
	je		_faka_winapi_1_param_
	cmp		eax, 0D9ADC55Ch												;SetActiveWindow
	je		_faka_winapi_1_param_
	cmp		eax, 01698A886h												;GetTopWindow
	je		_faka_winapi_1_param_
	cmp		eax, 049188291h												;IsZoomed
	je		_faka_winapi_1_param_
	cmp		eax, 0B9D3B88Dh												;GetWindowTextLengthA
	je		_faka_winapi_1_param_
	cmp		eax, 005C64EA2h												;GetSystemMetrics
	je		_faka_GetSystemMetrics_
	cmp		eax, 02E102B44h												;CheckDlgButton
	je		_faka_CheckDlgButton_
	cmp		eax, 0402F6E2Fh												;GetSysColor
	je		_faka_GetSysColor_
	cmp		eax, 02B510B7Fh												;GetKeyState
	je		_faka_GetKeyState_
	cmp		eax, 06B668BFAh												;GetSysColorBrush
	je		_faka_GetSysColorBrush_
	cmp		eax, 0EF5B0128h												;GetKeyboardType
	je		_faka_GetKeyboardType_
	cmp		eax, 0A129CDE7h												;GetKeyboardLayout
	je		_faka_GetKeyboardLayout_
	cmp		eax, 0DFBA6BA5h												;DrawIcon
	je		_faka_DrawIcon_
	cmp		eax, 0E07C965Fh												;GetClientRect
	je		_faka_GetClientRect_
	cmp		eax, 0A4E0595Ah												;GetWindowRect
	je		_faka_GetWindowRect_
	cmp		eax, 092626EFCh												;CharNextA
	je		_faka_CharNextA_
	cmp		eax, 089606806h												;GetCursorPos
	je		_faka_GetCursorPos_
	cmp		eax, 0AC9E8550h												;LoadIconA
	je		_faka_LoadIconA_
	cmp		eax, 0034DF7BBh												;LoadCursorA
	je		_faka_LoadCursorA_
	cmp		eax, 0C1698B74h												;FindWindowA
	je		_faka_FindWindowA_

																		;gdi32.dll
	cmp		eax, 0941C08E5h												;SelectObject
	je		_faka_winapi_2_param_
	cmp		eax, 07725AEC5h												;SetTextColor
	je		_faka_SetTextColor_
	cmp		eax, 05F550585h												;SetBkColor
	je		_faka_SetBkColor_
	cmp		eax, 09734E948h												;SetBkMode
	je		_faka_SetBkMode_
	cmp		eax, 0CEE8783Ah												;Rectangle
	je		_faka_Rectangle_
	cmp		eax, 083BEBFF6h												;Ellipse
	je		_faka_Ellipse_
	cmp		eax, 0783B7846h												;GetTextColor
	je		_faka_winapi_1_param_
	cmp		eax, 071102417h												;GetBkColor
	je		_faka_winapi_1_param_
	cmp		eax, 03B9BDDD6h												;GetObjectType
	je		_faka_winapi_1_param_
	cmp		eax, 0A818302Eh												;GetMapMode
	je		_faka_winapi_1_param_
	cmp		eax, 06618FA35h												;GetBkMode
	je		_faka_winapi_1_param_
	cmp		eax, 05836E111h												;GetNearestColor
	je		_faka_GetNearestColor_
	cmp		eax, 09420C409h												;PtVisible
	je		_faka_PtVisible_
	
	jmp		_faka_ret_													;�᫨ �� ��諨 �� ���� �����, ⮣�� ᪮�४��㥬 ������� ���� � �� ��室; 

_faka_winapi_0_param_:													;������� ������� �맮�� GetVersion;
	call	faka_winapi_0_param
	jmp		_faka_crct_fields_ 

_faka_QueryPerformanceCounter_:
_faka_QueryPerformanceFrequency_:
	call	faka_QueryPerformanceCounter
	jmp		_faka_crct_fields_

_faka_lstrcmpiA_:
_faka_lstrcmpA_:
	call	faka_lstrcmpiA
	jmp		_faka_crct_fields_

_faka_lstrcpyA_:
	call	faka_lstrcpyA
	jmp		_faka_crct_fields_

_faka_lstrlenA_:
_faka_CharNextA_:
;_faka_LoadLibraryA_:
	call	faka_lstrlenA
	jmp		_faka_crct_fields_

_faka_GetSystemTime_:
_faka_GetLocalTime_:
	call	faka_GetSystemTime
	jmp		_faka_crct_fields_

_faka_MulDiv_:
	call	faka_MulDiv
	jmp		_faka_crct_fields_

_faka_IsValidCodePage_:
	call	faka_IsValidCodePage
	jmp		_faka_crct_fields_

_faka_GetDriveTypeA_:
	call	faka_GetDriveTypeA
	jmp		_faka_crct_fields_

_faka_IsValidLocale_:
	call	faka_IsValidLocale
	jmp		_faka_crct_fields_ 

_faka_winapi_2_param_:
	call	faka_winapi_2_param											;GetDlgItem etc; 
	jmp		_faka_crct_fields_

_faka_winapi_1_param_:
	call	faka_winapi_1_param
	jmp		_faka_crct_fields_ 

_faka_GetSystemMetrics_:
	call	faka_GetSystemMetrics
	jmp		_faka_crct_fields_

_faka_CheckDlgButton_:
	call	faka_CheckDlgButton
	jmp		_faka_crct_fields_

_faka_GetSysColor_:
_faka_GetSysColorBrush_:
	call	faka_GetSysColor
	jmp		_faka_crct_fields_

_faka_GetKeyState_:
	call	faka_GetKeyState
	jmp		_faka_crct_fields_

_faka_GetKeyboardType_:
	call	faka_GetKeyboardType
	jmp		_faka_crct_fields_

_faka_GetKeyboardLayout_:
	call	faka_GetKeyboardLayout
	jmp		_faka_crct_fields_

_faka_DrawIcon_:
	call	faka_DrawIcon
	jmp		_faka_crct_fields_

_faka_SetTextColor_:
_faka_SetBkColor_:
_faka_GetNearestColor_:
	call	faka_SetTextColor
	jmp		_faka_crct_fields_

_faka_SetBkMode_:
	call	faka_SetBkMode
	jmp		_faka_crct_fields_

_faka_Rectangle_:
_faka_Ellipse_:
	call	faka_Rectangle
	jmp		_faka_crct_fields_

_faka_winapi_3_param_:
_faka_PtVisible_:
	call	faka_winapi_3_param
	jmp		_faka_crct_fields_

_faka_GetClientRect_:
_faka_GetWindowRect_:
	call	faka_GetClientRect
	jmp		_faka_crct_fields_

_faka_GetModuleHandleA_:
	call	faka_GetModuleHandleA
	jmp		_faka_crct_fields_

_faka_GetCursorPos_:
	call	faka_GetCursorPos
	jmp		_faka_crct_fields_

_faka_LoadIconA_:
_faka_LoadCursorA_:
	call	faka_LoadIconA
	jmp		_faka_crct_fields_

_faka_FindWindowA_:
	call	faka_FindWindowA
	jmp		_faka_crct_fields_

_faka_GetProcAddress_:
	call	faka_GetProcAddress
	jmp		_faka_crct_fields_											;=) 

_faka_crct_fields_:														;eax = ���� ��� ���쭥�襩 ����� ����
	xchg	eax, edi
	mov		[ebx].fnw_addr, eax											;��࠭�� ��� � [ebx].fnw_addr
	sub		eax, [ebx].tw_api_addr										;�⭨��� �� �⮣� ���� ����, �㤠 �����뢠�� ����� �맮� ���誨
	mov		[ebx].nobw, eax 											;� ����稬 ���-�� ॠ�쭮 ����ᠭ��� ���⮢ - ��࠭�� �� ���祭�� � ���� [ebx].nobw; 

_faka_ret_:
	mov		esp, faka_tmp_esp											;��易⥫쭮 ��। �᢮��������� ����� �㦭� ����⠭����� esp; 
	cmp		faka_alloc_addr, 0											;�஢�ਬ, �뤥�﫨 �� �� ������ ��� ���� �⥪?
	je		_faka_ret_01_

	push	faka_alloc_addr												;�᫨ ��, ⮣�� �᢮����� ����� ���㦭�� ������
	call	[ebx].free_addr												; 

_faka_ret_01_: 
	mov		eax, [ebx].fnw_addr											;
	mov		dword ptr [ebp + 1Ch], eax									;eax = ���� ��� ���쭥�襩 ����� ����; 
	mov		esp, ebp 
	popad
	ret		04															;��室��; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;����� �㭪� FAKA
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx





;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;�ᯮ����⥫쭠� func search_api
;���� ���誨, �ࠢ����� ��� �� �� ����� � ��蠬� �� ���� ��㣨� ��������� ���襪
;�᫨ ����� ���襪 ᮢ����, ⮣�� EAX = ���� �� ����� ������ ���, � � [ebx].api_va �㤥� ������
;VA, �� ���஬� (�� ࠡ�� �ணࠬ��) � �㤥� ��室���� �������騩 ��� ���� winapi; 
;����:
;	EBX				-	���� �������� FAKA_FAKEAPI_GEN
;	ESI				-	���� � 䠩�� �� �������� IMAGE_IMPORT_DESCRIPTOR
;	[ebx].api_hash	-	��� �� ����� ������誨, ���� ���ன �⨬ ����; 
;�����:
;	EAX				-	��� �� ����� ��������� ���誨 ��� 0, �᫨ ���� �� ��諨; 
;	[ebx].api_hash	-	��� �� ����� ��������� ���誨 ��� 0, �᫨ ���� �� ��諨; 
;	[ebx].api_va	-	VirtualAddress, �� ���஬� (�� ����㧪� �ணࠬ��, � ���ன �� �᪠��) � 
;						�㤥� ������ �������騩 ��� ���� ������; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 
search_api:
	push	faka_iat_size
	push	ecx															;��࠭�� ॣ�
	push	edx
	push	esi
	assume	esi: ptr IMAGE_IMPORT_DESCRIPTOR

_sa_nxt_IID_cycle_:
	xor		eax, eax 
	mov		ecx, [esi].OriginalFirstThunk
	mov		edx, [esi].FirstThunk
	test	ecx, ecx													;�᫨ ���� OriginalFirstThunk = 0 (� ⠪�� �뢠�� � ��ૠ�᪨� ���������=)), 
	jne		_sa_nxt_1_
	mov		ecx, edx 													;⮣�� ������ ecx = ���� FirstThunk
	test	edx, edx													;�᫨ ��� �� ���� = 0, ⮣�� �� ��᫥���� ����� � ���ᨢ� ������� IMAGE_IMPORT_DESCRIPTOR, ��室�� 
	je		_sa_ret_
_sa_nxt_1_: 															;
	cmp		faka_iat_size, 0											;����, �᫨ ࠧ��� IAT = 0, ⮣�� �� ��室
	je		_sa_ret_
	
	lea		eax, faka_tmp_var1											;�᫨ �� ��� �⫨筮, ⮣�� 
	push	eax 
	push	ecx
	push	[ebx].mapped_addr
	call	rva_to_offset 												;����� ���� � 䠩�� �� RVA, ����� ����� � ecx;

	test	eax, eax													;�᫨ eax = 0, ����� ���� �� RVA ���� � 䠩�� �� ����稫��. ⮣�� �� ��室
	je		_sa_ret_ 
	xchg	eax, ecx													;���� ��࠭�� ���� � ecx;

	lea		eax, faka_imsh
	push	eax
	push	edx
	push	[ebx].mapped_addr
	call	rva_to_offset												;⮦� ᠬ�� �த�����, ⮫쪮 ��� RVA, �� ����� � edx; 

	test	eax, eax
	je		_sa_ret_ 
	xchg	eax, edx

_sa_nxt_ITD_cycle_:
	assume	ecx: ptr IMAGE_THUNK_DATA32
	cmp		[ecx].u1.Ordinal, 0											;�᫨ �� ���� = 0, ����� �� ��᫥���� ����� � ���ᨢ� ������� IMAGE_THUNK_DATA32, ⮣�� �멤��; 
	je		_sa_nxt_IID_ 
	bt		[ecx].u1.Ordinal, 31										;����, �᫨ �� �㭪� ����������� �� �न����, ⮣�� ��३��� � ᫥���饬� ������ IMAGE_THUNK_DATA32; 
	jc		_sa_nxt_ITD_

	lea		eax, faka_tmp_var1
	push	eax 
	push	[ecx].u1.AddressOfData
	push	[ebx].mapped_addr											;�᫨ �� �㭪� ����������� �� �����, ⮣�� � ���� AddressOfData ����� rva �� �������� IMAGE_IMPORT_BY_NAME;
	call	rva_to_offset 

	test	eax, eax													;�᫨ ���� ���� � 䠩�� �� ࢠ/���/rva �� ����稫���, ⮣�� �� ��室
	je		_sa_ret_ 
	inc		eax															;�ய��� ���� hint � ��३��� � ����� �������㥬�� �㭪�
	inc		eax

	push	eax															;����稬 ��� �� �� ����� CRC32
	call	xCRC32A

	cmp		eax, [ebx].api_hash											;�᫨ �� ��諨 �� �㭪�, �� �᪠�� (��� �� ��� ᮢ����), � ��९�룭�� �����
	je		_sa_api_found_ok_ 
_sa_nxt_ITD_: 
	add		ecx, sizeof (IMAGE_THUNK_DATA32)							;���� ��३�� � ᫥���饬� ������ IMAGE_THUNK_DATA32; 
	add		edx, sizeof (IMAGE_THUNK_DATA32) 							;᪮�४��㥬 ��� ॣ�: ecx & edx; 
	jmp		_sa_nxt_ITD_cycle_ 
_sa_nxt_IID_:
	add		esi, sizeof (IMAGE_IMPORT_DESCRIPTOR)						;�᫨ �� �� �஢�ਫ� �� �㭪� (�������� IMAGE_THUNK_DATA32) ⥪�饩 dll (�������� IMAGE_IMPORT_DESCRIPTOR), 
	sub		faka_iat_size, sizeof (IMAGE_IMPORT_DESCRIPTOR) 			;⮣�� ��३��� � ᫥���饩 ������� IMAGE_IMPORT_DESCRIPTOR; 
	jmp		_sa_nxt_IID_cycle_
_sa_api_found_ok_:														;��� �� �㤥�, �᫨ �� ��諨 ���� �����
	mov		esi, faka_imsh												;� faka_imsh - ���� � 䠩�� �� �������� IMAGE_SECTION_HEADER. �� ������� ᮮ�-�� ᥪ樨, � �।���� ���ன ����� ���� edx (� edx - ���� � IAT, �� ���஬� �㤥� ������ ���� ��襩 ������=));
	assume	esi: ptr IMAGE_SECTION_HEADER								; 
	test	esi, esi													;�᫨ IAT �ᯮ������ �� � ᥪ樨, � � ���������, ⮣�� ��९�룭��
	je		_sa_nxt_2_ 
	sub		edx, [esi].PointerToRawData									;�᫨ �� IAT � ᥪ樨, ⮣�� ��ॢ���� 䨧��᪨� ���� � ����㠫�� (VA); 
	add		edx, [esi].VirtualAddress
_sa_nxt_2_:
	sub		edx, [ebx].mapped_addr
	add		edx, faka_imagebase
	mov		[ebx].api_va, edx											;����, � �⮣� � [ebx].api_va �㤥� ������ VA -> ���ਬ�� �� ���� 402008h. 
																		;����� �᫨ �� ����㧪� �ண� (� ���쭥�襩 �� ࠡ��) � ��� �㤥� ��� ⠪�� �������: mov eax, dword ptr [402008h], 
																		;� � eax �㤥� ������ ���� ������-�㭪�; ��� ������ ����� �㤥� �맢��� ⠪: call dword ptr [403008h] etc;
																		;��� ⠪�� ������; 
_sa_ret_: 
	mov		[ebx].api_hash, eax											;��� �㤥� ���� ��� �� ��������� ���誨, ��� 0, �᫨ ���७� ��祣� �� �������; 
	pop		esi
	pop		edx
	pop		ecx
	pop		faka_iat_size 
	ret		 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;����� �㭪� search_api 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
 

 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;�㭪a valid_pe 
;�஢�ઠ 䠩�� (�� ����������/���४⭮���/etc);
;���� (stdcall int valid_pe(LPVOID pExe)):
;	pExe	-	���� ������ 䠩��;
;�����:
;	EAX		-	0, �᫨ 䠩� ����, ���� 1; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx	 
valid_pe:
	push	esi
	xor		eax, eax
	mov		esi, dword ptr [esp + 08h]
	assume	esi: ptr IMAGE_DOS_HEADER
	cmp		[esi].e_magic, 'ZM'
	jne		_vp_xuita_
	cmp		[esi].e_lfanew, 200h
	jae		_vp_xuita_
	add		esi, [esi].e_lfanew
	assume	esi: ptr IMAGE_NT_HEADERS
	cmp		[esi].Signature, 'EP'
	jne		_vp_xuita_
	cmp		[esi].FileHeader.Machine, IMAGE_FILE_MACHINE_I386
	jne		_vp_xuita_
	cmp		[esi].FileHeader.NumberOfSections, 0
	je		_vp_xuita_
	cmp		[esi].FileHeader.NumberOfSections, 96
	jae		_vp_xuita_
	test	[esi].FileHeader.Characteristics, IMAGE_FILE_EXECUTABLE_IMAGE
	je		_vp_xuita_
	test	[esi].FileHeader.Characteristics, IMAGE_FILE_32BIT_MACHINE
	je		_vp_xuita_ 
	cmp		[esi].OptionalHeader.Magic, IMAGE_NT_OPTIONAL_HDR32_MAGIC
	jne		_vp_xuita_
	cmp		[esi].OptionalHeader.Subsystem, IMAGE_SUBSYSTEM_WINDOWS_GUI
	jb		_vp_xuita_
	cmp		[esi].OptionalHeader.Subsystem, IMAGE_SUBSYSTEM_WINDOWS_CUI
	ja		_vp_xuita_
	inc		eax
_vp_xuita_:
	pop		esi
	ret		04
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;����� �㭪� valid_pe
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx	



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;�㭪� rva_to_offset
;��ॢ�� RVA � ᬥ饭�� � 䠩�� (����祭�� ᬥ饭�� (+ ���� ������) � 䠩�� �� RVA);
;���� (stdcall DWORD rva_to_offset(LPVOID pExe, DWORD rva, imSh)):
;	pExe		-	���� ������ 䠩�� (१��� �� �㭪� MapViewOfFile) aka ���� 䠩�� � �����; 
;	rva			-	�⭮�⥫�� ����㠫�� ����
;	imSh		-	���� ��६�����, � ������ �� ��室� �������� ���祭��;
;�����:
;	EAX			-	ᬥ饭�� � 䠩�� (��᮫��� ���� � 䠩��) ��� 0 (�᫨ ���� �� ����稫��� ���� 
;					�� rva ᬥ饭��); 
;	imSh		-	���� � 䠩�� �� ����� � ⠡��� ᥪ権. ��� ����� ᮮ�-�� ᥪ樨, � 
;					�।���� ���ன ����� rva; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
rto_mapped_addr		equ		dword ptr [ebp + 24h]						;���� ������
rto_rva				equ		dword ptr [ebp + 28h]						;RVA
rto_imsh			equ		dword ptr [ebp + 2Ch]						;���� ��६�����

rva_to_offset:
	pushad																;��࠭塞 ॣ�
	mov		ebp, esp 
	mov		esi, rto_mapped_addr										;esi - mapped_addr
	assume	esi: ptr IMAGE_DOS_HEADER
	add		esi, [esi].e_lfanew
	assume	esi: ptr IMAGE_NT_HEADERS
	mov		eax, rto_imsh
	and		dword ptr [eax], 0
	movzx	ecx, [esi].FileHeader.NumberOfSections						;ecx - ���-�� ᥪ権 � 䠩��
	movzx	edx, [esi].FileHeader.SizeOfOptionalHeader					;ࠧ��� �������� IMAGE_OPTIONAL_HEADER
	mov		ebx, [esi].OptionalHeader.FileAlignment
	lea		esi, dword ptr [esi + edx + sizeof (DWORD) + sizeof (IMAGE_FILE_HEADER)]	
	assume	esi: ptr IMAGE_SECTION_HEADER
	mov		eax, rto_rva												;eax = RVA 	
	cmp		eax, [esi].VirtualAddress									;����� ���� rva ����� � �।���� ���������?
	jb		_rto_ret_
	xor		eax, eax
_rto_nxt_sec_cycle_:													;���� ���� ����, � ����� ᥪ�� 㪠�뢠�� ��।���� rva; 
_rto_get_sec_minsize_:
	mov		edi, [esi].SizeOfRawData									;edi - 䨧��᪨� ࠧ��� ᥪ樨
	mov		edx, [esi].Misc.VirtualSize									;edx - ����㠫�� ࠧ��� ᥪ樨
	test	edi, edi													;�����, ��� ��।���� ��������� �� ���� ࠧ��஢ ᥪ樨
	je		_rto_vs_
	test	edx, edx
	je		_rto_nxt_1_
	cmp		edx, edi
	jae		_rto_nxt_1_
_rto_vs_:	
	mov		edi, edx													;edi - ᮤ�ন� ��������� ࠧ��� (����� 䨧��᪨� � ����㠫��) ᥪ樨; 
_rto_nxt_1_:
	mov		edx, [esi].VirtualAddress									;⥯��� ��।����, ����� ᥪ樨 �ਭ������� rva
	cmp		rto_rva, edx
	jb		_rto_nxtsec_
	add		edx, edi
	cmp		rto_rva, edx
	jae		_rto_nxtsec_
	mov		eax, rto_rva
	sub		eax, [esi].VirtualAddress									;�᫨ ��諨 ⠪�� ᥪ��, ⮣�� ������ ����� � �ਡ���� ���� ������
	xchg	eax, edx
	
	push	ebx
	push	[esi].PointerToRawData
	call	align_down													;��祬 䨧��᪨� ���� ᥪ樨 ��஢�塞 �� ������ �࠭���; 

	add		eax, edx													;� eax - ����� ����� � 䠩��
	mov		edx, rto_imsh												;edx - ᮤ�ন� ���� ��६�����
	mov		dword ptr [edx], esi										;����襬 � ��� ��६����� ���� �� ����� � ⠡��窥 ᥪ権; 
_rto_nxtsec_:
	add		esi, sizeof (IMAGE_SECTION_HEADER)							;���� ᬥ頥��� �� �ࠢ����� ��㣮�� ����� � ⠡��� ᥪ権; 
	dec		ecx
	jne		_rto_nxt_sec_cycle_
	test	eax, eax													;�᫨ eax != 0, ⮣�� ᥪ�� �뫠 �������
	je		_rto_ret_1_													;���� ᥪ�� �� �������, � १��� ��࠭�� 0; 	
_rto_ret_:
	add		eax, rto_mapped_addr										;������塞 ���� ������
_rto_ret_1_:
	mov		dword ptr [ebp + 1Ch], eax									;� ��࠭塞 ��� �� ���� � eax;
	mov		esp, ebp
	popad
	ret		04 * 3														;��室�� 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;����� �㭪� rva_to_offset
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx	



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;�㭪� offset_to_va
;��ॢ�� 䨧��᪮�� ���� (� 䠩��) � ����㠫�� (� ����� aka VA);
;���� (stdcall DWORD offset_to_va(LPVOID pExe, DWORD offs)):
;	pExe		-	���� ������ 䠩�� (१��� �� �㭪� MapViewOfFile) aka ���� 䠩�� � �����; 
;	offs		-	䨧��᪨� ���� � 䠩��; 
;�����:
;	EAX			-	VA � ����� ��� 0 (�᫨ ���� �� ����稫��� ����); 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
otv_mapped_addr		equ		dword ptr [ebp + 24h]						;���� ������
otv_offset			equ		dword ptr [ebp + 28h]						;offset

otv_image_base		equ		dword ptr [ebp - 04]						;ImageBase; 

offset_to_va:
	pushad																;��࠭塞 ॣ�
	mov		ebp, esp 
	sub		esp, 08
	mov		esi, otv_mapped_addr										;esi - mapped_addr
	assume	esi: ptr IMAGE_DOS_HEADER
	sub		otv_offset, esi												;�⭨���� �� 䨧��᪮�� ���� ���� ������
	add		esi, [esi].e_lfanew
	assume	esi: ptr IMAGE_NT_HEADERS
	mov		eax, [esi].OptionalHeader.ImageBase
	mov		otv_image_base, eax											;��࠭塞 � ������ ��६����� ImageBase;
	movzx	ecx, [esi].FileHeader.NumberOfSections						;ecx - ���-�� ᥪ権 � 䠩��
	movzx	edx, [esi].FileHeader.SizeOfOptionalHeader					;ࠧ��� �������� IMAGE_OPTIONAL_HEADER
	mov		ebx, [esi].OptionalHeader.FileAlignment
	lea		esi, dword ptr [esi + edx + sizeof (DWORD) + sizeof (IMAGE_FILE_HEADER)]	
	assume	esi: ptr IMAGE_SECTION_HEADER
	mov		eax, otv_offset												;eax = offset
	cmp		eax, [esi].PointerToRawData									;����� ���� offset ����� � �।���� ���������?
	jb		_otv_ret_
	xor		eax, eax
_otv_nxt_sec_cycle_:													;���� ���� ����, � ����� ᥪ�� 㪠�뢠�� ��।���� offset; 
_otv_get_sec_minsize_:
	mov		edi, [esi].SizeOfRawData									;edi - 䨧��᪨� ࠧ��� ᥪ樨
	mov		edx, [esi].Misc.VirtualSize									;edx - ����㠫�� ࠧ��� ᥪ樨
	test	edi, edi													;�����, ��� ��।���� ��������� �� ���� ࠧ��஢ ᥪ樨
	je		_otv_vs_
	test	edx, edx
	je		_otv_nxt_1_
	cmp		edx, edi
	jae		_otv_nxt_1_
_otv_vs_:	
	mov		edi, edx													;edi - ᮤ�ন� ��������� ࠧ��� (����� 䨧��᪨� � ����㠫��) ᥪ樨; 
_otv_nxt_1_:
	mov		edx, [esi].PointerToRawData									;⥯��� ��।����, ����� ᥪ樨 �ਭ������� offset
	cmp		otv_offset, edx
	jb		_otv_nxtsec_
	add		edx, edi
	cmp		otv_offset, edx
	jae		_otv_nxtsec_
	mov		eax, otv_offset
	sub		eax, [esi].PointerToRawData									;�᫨ ��諨 ⠪�� ᥪ��, ⮣�� ������ rva � �ਡ���� ImageBase; 
	xchg	eax, edx
	
	push	ebx
	push	[esi].VirtualAddress
	call	align_down													;��祬 ����㠫�� ���� ᥪ樨 ��஢�塞 �� ������ �࠭���; 

	add		eax, edx													;� eax - ����� rva;
_otv_nxtsec_:
	add		esi, sizeof (IMAGE_SECTION_HEADER)							;���� ᬥ頥��� �� �ࠢ����� ��㣮�� ����� � ⠡��� ᥪ権; 
	dec		ecx
	jne		_otv_nxt_sec_cycle_
	test	eax, eax													;�᫨ eax != 0, ⮣�� ᥪ�� �뫠 �������
	je		_otv_ret_1_													;���� ᥪ�� �� �������, � १��� ��࠭�� 0; 	
_otv_ret_:
	add		eax, otv_image_base											;������塞 ������ ���� ����㧪�; 
_otv_ret_1_:
	mov		dword ptr [ebp + 1Ch], eax									;� ��࠭塞 ��� �� ���� � eax;
	mov		esp, ebp
	popad
	ret		04 * 2														;��室�� 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;����� �㭪� offset_to_va
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx	



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;func align_down
;��ࠢ��� ���祭�� ����
;C-��ਠ��: 
;#define ALIGN_DOWN(x, y)	(x & (~(y - 1)))	//����; 
;���� (stdcall int align_down(int x, int y)):
;	x	-	���祭��, ���஥ �㦭� ��஢���� ����
;	y	-	��ࠢ�����騩 䠪��
;�����:
;	EAX	-	��஢������ ���祭��;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
align_down:
	push	ecx
	mov		eax, dword ptr [esp + 08]									;x
	mov		ecx, dword ptr [esp + 12]									;y
	dec		ecx
	not		ecx
	and		eax, ecx													;��ࠢ������
	pop		ecx
	ret		04 * 2														;��室��; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;����� �㭪� align_down 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;�㭪�� xstrlen
;���᫥��� ����� ��ப�
;���� (stdcall: DWORD xstrlen(char *pszStr)):
;	pszStr	-	㪠��⥫� �� ��ப�, ��� ����� ���� ������� 
;�����:
;	EAX		-	����� ��ப� (� �����) 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
xstrlen:
	push	edi		 
	mov		edi, dword ptr [esp + 08]
	push	edi  
	xor		eax, eax
_numsymbol_: 
	scasb
	jne		_numsymbol_
	xchg	eax, edi
	dec		eax
	pop		edi
	sub		eax, edi
	pop		edi  
	ret		4
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;����� �㭪樨 xstrlen 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 
;�㭪�� xCRC32A
;���᫥��� CRC32 ��ப�
;���� (stdcall DWORD xCRC32A(char *pszStr)):
;	pszStr		-	��ப�, 祩 ��� ���� ������� 
;�����:
;	(+) EAX		- 	��� �� ��ப� 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 
xCRC32A:
	push	ecx
	mov		ecx, dword ptr [esp + 08]   

	push	ecx
	call	xstrlen

	test	eax, eax
	je		_xcrc32aret_

	push	eax
	push	ecx 
	call	xCRC32

_xcrc32aret_: 
	pop		ecx 
	ret		4 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;����� �㭪樨 xCRC32A 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 			



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 
;�㭪�� xCRC32
;������ CRC32 
;���� (stdcall DWORD xCRC32(BYTE *pBuffer, DWORD dwSize)):
;	pBuffer		- 	����, � ���஬ ���, 祩 crc32 ���� �������
;	dwSize		- 	᪮�쪮 ���� ������� ? (+) 
;�����:
;	(+) EAX		-	CRC32 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 
xCRC32:
	pushad
	mov		ebp, esp
	xor		eax, eax
	mov		edx, dword ptr [ebp + 24h]
	mov		ecx, dword ptr [ebp + 28h]
	test	ecx, ecx
	je		@4	
	;jecxz	@4 
	dec		eax 
@1:
	xor		al, byte ptr [edx]
	inc		edx
	push	08
	pop		ebx
@2:
	shr		eax, 1
	jnc		@3
	xor		eax, 0EDB88320h
@3:
	dec		ebx 
	jnz		@2
	dec		ecx
	jne		@1
	;loop	@1
	not		eax
@4:
	mov		dword ptr [ebp + 1Ch], eax 
	popad
	ret		4 * 2 							
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx		
;����� �㭪樨 xCRC32 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 	



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx		
;�㭪�� rnd_swap_elem
;��६�訢���� ����⮢ � ���ᨢ� ��砩�� ��ࠧ��
;����:
;	edx		-	���-�� ����⮢ � ���ᨢ�
;	edi		-	���� �� ���ᨢ, �� ������ ���� ��砩�� ��ࠧ�� ��६����
;�����:
;	(+)		-	��砩�� ��ࠧ�� ��६�蠭�� ������ ��������� ���ᨢ�;
;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 	 
rnd_swap_elem:
	push	ecx
	xor		ecx, ecx

_rse_cycle_:
	push	edx
	call	[ebx].rang_addr

	push	dword ptr [edi + ecx * 4]
	push	dword ptr [edi + eax * 4]
	pop		dword ptr [edi + ecx * 4]
	pop		dword ptr [edi + eax * 4]
	inc		ecx
	cmp		ecx, edx
	jne		_rse_cycle_ 
	pop		ecx
	ret
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx		
;����� �㭪樨 rnd_swap_elem
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 	



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;�㭪� faka_get_rnd_val_va
;����祭�� ����㠫쭮�� ���� (VA) ��砩���� �᫠ ��� ��ப� � ��।����� ������ �����; 
;�᫨ ���� ��������� �����樨 � ������ xTG, ⮣�� ᤥ���� �㦭� ���४⨢� � �����; 
;�����, ��� ����祭�� ���� �᫠ � ������ �����  - �㦥� ⮫쪮 ���४�� ����, � ����� ����� 
;�㤥� ���� � �����. �⮡� ������� ���� ��ப�, ��ப� ������ �뫠 ���� ᣥ���஢��� � �⨬� 
;�᫮��ﬨ:
;
; (+) ࠧ��� �᫠ = 4 ����;
; (+) ����� ��ப� ��⭠ 4 - � ��஢���� ��ﬨ;
; (+) ��ப� � ���(ﬨ) � ����;
; (+) ���� ��ப� � �᫠ ��⥭ 4; 
; (+) �᫮ - 32-� ࠧ�來��; ��ப� ansi; 
;
;����:
;	EBX		-	etc;
;	EAX		-	�������� ���祭��:
;				FAKA_GET_RND_NUM32_ADDR - �᫨ �㦭� ������� ���� ��砩���� �᫠ � ��।����� ������ 
;				����� (rdata_addr & rdata_size);
;				FAKA_GET_RND_STRA_ADDR - �᫨ �㦭� ������� ���� ��砩��� ��ப� etc; 
;�����:
;	EAX		-	0, �᫨ ���� �� 㤠���� �������; ��� ���� (va!) ��ப�/�᫠; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

FAKA_GET_RND_NUM32_ADDR		equ		01h									;���祭�� ��� eax; 
FAKA_GET_RND_STRA_ADDR		equ		02h 

fgrva_tmp_var1				equ		dword ptr [ebp - 04]				;�ᯮ����⥫쭠� ��६�����; 
fgrva_tmp_var2				equ		dword ptr [ebp - 08]

faka_get_rnd_val_va: 
	pushad																;��࠭塞 � �⥪� ॣ�;
	mov		ebp, esp 
	sub		esp, 12
	xchg	eax, ecx													;ecx - ⥯��� ᮤ�ন� 䫠��;
	mov		eax, [ebx].mapped_addr
	mov		fgrva_tmp_var2, eax 										;��࠭�� � ������ ��६����� ���� ������; 
	mov		edx, [ebx].xdata_struct_addr
	assume	edx: ptr XTG_DATA_STRUCT

	call	faka_check_rdata											;��뢠�� �㭪� �஢�ન ��।����� ������: ���� � ࠧ��� ������ �����; 

	test	eax, eax													;�᫨ ���, ⮣�� ��室��
	je		_fgrva_ret_
	
	call	faka_get_rnd_rdata_addr										;����稬 ��砩�� ���� � ��������� ������ �����;

	cmp		ecx, FAKA_GET_RND_NUM32_ADDR								;�� �������: ���� ��ப� ��� �᫠?
	je		_fgrva_otv_ 												;�᫨ �᫠, ⮣�� ���, �� ��室=)! ���� ����稬 ���� ��ப�; 

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
	push	'89_.'														;16
	
	mov		fgrva_tmp_var1, esp											;��࠭�� ���� ������ ��ப� � �����쭮� ��६�����; 

	xchg	eax, esi
	mov		ebx, [edx].rdata_addr
	add		ebx, [edx].rdata_size										;��� ����⠥�, ᪮�쪮 ���⮢ �஢����, ��稭�� �� ⥪�饣� ��࠭���� ���� � �� ���� ������ �����; 
	sub		ebx, esi													;� ebx - �㤥� �࠭��� �� ���祭��;

_fgrva_search_1st_byte_:												;�⠪, ���堫� =). ���砫� ����� �� ����, ����� ᮤ�ন��� � ��ப� ��� �����樨 ��砩��� ��ப (������稬 �� ��� xgen_str); 
	dec		ebx 
	je		_fgrva_ret_0_1_												;�᫨ �� ���� �� ���⮢, ����� � ��ப� xgen_str, �� �� ������ � ������ ����� (��稭�� � ��࠭���� ���� � �� ���� ������ �����), ⮣�� ��室��; 
	mov		edi, fgrva_tmp_var1
	mov		ecx, (16 * 04)
	lodsb
	repne	scasb														;�᫨ �� ⥪�騩 �஢��塞� ���� - �� ���� ����� �� ���⮢ � xgen_str, ⮣�� ���室�� � �ࠢ����� ᫥���饣� ����;
	jne		_fgrva_search_1st_byte_ 

_fgrva_check_addr_1_:													;�᫨ �� ���� �� ������, ⮣�� �஢�ਬ, ��� ���� ����� �� �����, ��⭮�� 4-�?
	lea		eax, dword ptr [esi - 01]
	push	eax
	and		eax, 03
	pop		eax
	jne		_fgrva_search_1st_byte_ 									;�᫨ �� ⠪, ⮣�� ᭮�� �㤥� �᪠�� �� ���� � ������ �����, ����� ���� � ��ப� xgen_str; 
	push	eax															;���� ��࠭�� ���� � �⥪� - �� �㤥� ��砫� ��������� ��ப�; �����७��, �� ��� ���� �� � �᪠�� - �㦭� �஢����; 

_fgrva_search_nxt_bytes_:												;�᫨ �� ॠ�쭮 ��諨 �� ��ப�, ⮣�� ������ �� �����;
	dec		ebx															;����� - �� �� �������� ᨬ���, ����� ��������� � ��ப� xgen_str; 
	je		_fgrva_ret_0_1_ 
	mov		edi, fgrva_tmp_var1
	mov		ecx, (16 * 04)
	lodsb
	repne	scasb
	je		_fgrva_search_nxt_bytes_

_fgrva_check_final_bytes_:												;�᫨ �� ��諨 �� ����, 
	cmp		ebx, 04
	jl		_fgrva_ret_0_1_ 
	lea		ecx, dword ptr [esi - 01]
	mov		edi, ecx
	and		ecx, 03														;⮣�� ��६ ⥪�騩 ���� � �஢�ਬ �� �㫨 N ����. N - �� ⠪�� �᫮, �� �᫨ ��� �ਡ����� � ������� ����� - � �������� ����, ���� 4-�; 
	sub		ecx, 04
	neg		ecx
	xor		eax, eax
	repe	scasb
	pop		eax
	jne		_fgrva_search_1st_byte_ 									;�᫨ �� �� �㫨, ⮣�� �� � �� ��ப�;

_fgrva_otv_:	
	cmp		[edx].rdata_pva, XTG_OFFSET_ADDR							;�஢�ਬ, ����� ���� ��।�� � rdata_addr: 䨧��᪨� ��� ����㠫��?
	jne		_fgrva_ret_													;�᫨ 䨧��᪨�, ⮣�� ��ॢ��� ��� � va; ���� ⠪ � ��⠢��; 

	push	eax															;䨧��᪨� ���� 
	push	fgrva_tmp_var2												;���� ������; 
	call	offset_to_va												;��뢠�� �㭪� ��ॢ��� 䨧��᪮�� ���� (� 䠩��) � ����㠫�� ���� (� �����); 
	
	test	eax, eax
	jne		_fgrva_ret_ 												;���� �� ��諨 ��砩��� ��ப� � �� ���� ��࠭��� � eax; 

_fgrva_ret_0_1_:
	xor		eax, eax
		
_fgrva_ret_:
	mov		dword ptr [ebp + 1Ch], eax
	mov		esp, ebp 
	popad
	ret 																;��室��; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;����� �㭪� faka_get_rnd_val_va
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;�㭪a faka_get_rnd_num_1 
;����祭�� �� �� �����ன ��᪥;
;����:
;	EAX		-	�᫮ N;
;�����:
;	EAX		-	�� � ��������� [0..N-1]; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 
faka_get_rnd_num_1:
	push	edx
	
	push	eax
	call	[ebx].rang_addr

	xchg	eax, edx
	
	push	edx
	call	[ebx].rang_addr

	and		eax, edx													;eax = ��; 
	pop		edx
	ret
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;����� �㭪� faka_get_rnd_num_1 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;�㭪� faka_get_rnd_r32
;����祭�� ��砩���� 32-� ��⭮�� ॣ�;
;����:
;	ebx		-	etc
;�����:
;	EAX		-	��砩�� ॣ32; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
faka_get_rnd_r32:
	push	8
	call	[ebx].rang_addr
	ret 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;����� �㭪� faka_get_rnd_r32
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;�㭪a faka_check_rdata 
;�஢�ઠ ���� � ࠧ��� ������ �� ����������; 
;����:
;	EBX		-	FAKA_FAKEAPI_GEN
;	etc
;�����:
;	EAX		-	1, �᫨ ����� �� (��� �����樨 ������) ��।����� ������� ������, ���� 0; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
faka_check_rdata:
	xor		eax, eax
	push	esi
	mov		esi, [ebx].xdata_struct_addr
	assume	esi: ptr XTG_DATA_STRUCT
	test	esi, esi
	je		_fcd_ret_
	cmp		[esi].rdata_addr, 00h										;�᫨ ���� ��砫� ������ ������ (ᥪ樨 ������) ࠢ�� ���, 
	je		_fcd_ret_													;� �� ��室;
	cmp		[esi].rdata_size, 04h										;���� �᫨ ࠧ��� ������ (ᥪ樨) ������ ����� 4-�, ⮣�� �� ��室; 
	jb		_fcd_ret_ 
	inc		eax															;���� ��� �⫨筮=)! 
_fcd_ret_:
	pop		esi
	ret
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;����� �㭪� faka_check_rdata
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;�㭪a faka_check_xdata 
;�஢�ઠ ���� � ࠧ��� ������ �� ����������; 
;����:
;	EBX		-	FAKA_FAKEAPI_GEN
;	etc
;�����:
;	EAX		-	1, �᫨ ����� �� (��� �����樨 ������) ��।����� ������� ������, ���� 0; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
faka_check_xdata:
	xor		eax, eax
	push	esi
	mov		esi, [ebx].xdata_struct_addr
	assume	esi: ptr XTG_DATA_STRUCT
	test	esi, esi
	je		_fcxd_ret_
	cmp		[esi].xdata_addr, 00h										;�᫨ ���� ��砫� ������ ������ (ᥪ樨 ������) ࠢ�� ���, 
	je		_fcxd_ret_													;� �� ��室;
	cmp		[esi].xdata_size, 04h										;���� �᫨ ࠧ��� ������ (ᥪ樨) ������ ����� 4-�, ⮣�� �� ��室; 
	jb		_fcxd_ret_ 
	inc		eax															;���� ��� �⫨筮=)! 
_fcxd_ret_:
	pop		esi
	ret
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;����� �㭪� faka_check_xdata
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;�㭪a faka_get_rnd_rdata_addr   
;����祭�� ��砩���� ���� (� 䠩��, � �� � �����!) � ᥪ樨 ������. ���砩�� ���� ��⥭ �����; 
;(����� ⠪�� � �����࠭�=)); 
;����:
;	ebx		-	etc
;	etc
;�����:
;	eax		-	��砩�� ����, ���� 4 (�� �᫮���, �� rdata_addr - �� ��⥭ 4); 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
faka_get_rnd_rdata_addr:
	push	edx															;��࠭塞 edx � �⥪�
	push	esi
	mov		esi, [ebx].xdata_struct_addr
	assume	esi: ptr XTG_DATA_STRUCT
	mov		eax, [esi].rdata_size 										;eax = ࠧ��� ᥪ樨 ������ (������ ������); 
	sub		eax, 04														;�⭨���� 4, �⮡� ��砩�� �� ������� �� �㦨� ����; 

	push	eax 
	call	[ebx].rang_addr												;����砥� �� [0..[ebx].data_size - 4 - 1]

	mov		edx, eax
	and		edx, 03
	sub		eax, edx													;������ ����祭��� ���祭�� ���� �����; 
	add		eax, [esi].rdata_addr										;������塞 ����;
	pop		esi
	pop		edx															;����⠭�������� edx; 
	ret 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;����� �㭪� faka_get_rnd_rdata_addr 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;�㭪a faka_get_rnd_xdata_va   
;����祭�� ��砩���� ���� (� �����, � ���� VirtualAddress) � ᥪ樨 ������. ���砩�� ���� ��⥭ �����; 
;(����� ⠪�� � �����࠭�=)); 
;⠬ ��� va (� � ��㣨� ����� ⠪��) - VirtualAddress; 
;����:
;	ebx		-	etc
;	etc
;�����:
;	eax		-	��砩�� ����, ���� 4 (�� �᫮���, �� xdata_addr - �� ��⥭ 4); 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
faka_get_rnd_xdata_va:
	push	edx															;��࠭塞 edx � �⥪�
	push	esi
	mov		esi, [ebx].xdata_struct_addr
	assume	esi: ptr XTG_DATA_STRUCT
	mov		eax, [esi].xdata_size 										;eax = ࠧ��� ᥪ樨 ������ (������ ������); 
	sub		eax, 04														;�⭨���� 4, �⮡� ��砩�� �� ������� �� �㦨� ����; 

	push	eax 
	call	[ebx].rang_addr												;����砥� �� [0..[ebx].data_size - 4 - 1]

	mov		edx, eax
	and		edx, 03
	sub		eax, edx													;������ ����祭��� ���祭�� ���� �����; 
	add		eax, [esi].xdata_addr										;������塞 ����;
	pop		esi
	pop		edx															;����⠭�������� edx; 
	ret 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;����� �㭪� faka_get_rnd_xdata_va
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;�㭪a faka_check_and_get_rnd_data_va 
;�஢�ઠ ���� � ࠧ��� ������ �� ����������, � ⠪�� 
;����祭�� ��砩���� ���� � ᥪ樨 ������. ���砩�� ���� ��⥭ �����; 
;����:
;	ebx		-	etc;
;�����:
;	eax		-	��砩�� ����, ���� 4 (�� �᫮���, �� xdata_addr (rdata_addr) - �� ��⥭ 4), 
;				���� 0, �᫨ �஢�ઠ �� �ன����;
;�������:
;	�஢�ઠ ���� � ࠧ���, � ⠪�� ����祭�� ����  - ��� �� �㤥� �ந�室��� � ����� �� 
;	���� ��砩�� ��࠭��� �����⥩ �����: ���� � rdata, ���� � xdata; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
faka_check_and_get_rnd_data_va: 
	push	02
	call	[ebx].rang_addr

	test	eax, eax
	jne		_cngxd_

_cngrd_:																;rdata
	call	faka_check_rdata

	test	eax, eax
	je		_cngd_ret_

	call	faka_get_rnd_rdata_addr

	push	edx
	mov		edx, [ebx].xdata_struct_addr
	assume	edx: ptr XTG_DATA_STRUCT
	cmp		[edx].rdata_pva, XTG_OFFSET_ADDR							;�஢�ਬ ����: 䨧��᪨� ��� ����㠫�� �� ��।����� � �����? 
	pop		edx
	jne		_cngd_ret_

	push	eax
	push	[ebx].mapped_addr
	call	offset_to_va
	
	jmp		_cngd_ret_ 

_cngxd_:																;xdata
	call	faka_check_xdata

	test	eax, eax
	je		_cngd_ret_

	call	faka_get_rnd_xdata_va

_cngd_ret_:
	ret
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;����� �㭪� faka_check_and_get_rnd_data_va
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;�㭪� faka_get_rnd_suit_xdata_va
;����祭�� ��砩���� ���室�饣� ���� � ������ ����� xdata_addr + xdata_size;
;����, ���� ��⠥��� ���室�騬, �᫨ �� + �᫮ ���⮢ (�� ��।����� � EAX) 
;<= xdata_addr + xdata_size;
;����:
;	ebx		-	etc;
;	eax		-	�᫮ - ���-�� ���⮢ (��� ����� �����-� ������ ������誮�); �� ���� ��� ⠪�� ��쪠: 
;				�����⨬, �� ������㥬 �㭪� QueryPerformanceCounter. ��� �ਭ����� 1 ��ࠬ��� - 
;				8-���⮢� ���� (���� ��⥭ 4 ��� x86) ����, � ����� ������ ������� �����. 
;				� �⮡� ������� ���� ⠪��� ����, �� ��뢠�� �㭪� faka_get_rnd_suit_xdata_va, 
;				��।���� � EAX = 8. � �����, ����� �� �㭪� ������ ��砩�� ����, ��� �஢���, ����� 
;				��, ��稭�� � �⮣� ����, ������� 8 ���⮢, �⮡� �� ��⠫��� � ��������� ��।����� 
;				������ ����� (xdata_addr + xdata_size). � �᫨ �����, ⮣�� ������� ��� ����祭�� 
;				��砩�� ����; 
;�����:
;	eax		-	0, �᫨ �� 㤠���� ������� ��砩�� ���室�騩 ����, ���� ����;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
faka_get_rnd_suit_xdata_va:
	push	ecx
	push	esi
	xchg	eax, ecx													;ecx = eax -> ���-�� ���⮢

	call	faka_check_xdata											;�஢�ਬ �� ���������� ������� xdata

	test	eax, eax													;�᫨ ���, ⮣�� �� ��室
	je		_fgrsxda_ret_

	call	faka_get_rnd_xdata_va										;���� ����稬 ��砩�� ���� � ��������� (xdata_addr + xdata_size); 

	push	eax															;��࠭�� � �⥪� ��� ����
	add		eax, ecx													;������塞 ��।����� ���-�� ���⮢
	mov		esi, [ebx].xdata_struct_addr
	assume	esi: ptr XTG_DATA_STRUCT									;esi - ���� �������� XTG_DATA_STRUCT; 
	mov		ecx, [esi].xdata_addr
	add		ecx, [esi].xdata_size										;ecx = ����� ������ xdata; 
	cmp		eax, ecx													;�᫨ eax < ecx, 
	pop		eax															;⮣�� ����ࠥ� �� ��� ����
	jb		_fgrsxda_ret_												;� �� ��室
	xor		eax, eax													;���� � eax = 0, � �� ��室; 
_fgrsxda_ret_:
	pop		esi 
	pop		ecx 
	ret
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;����� �㭪� faka_get_rnd_suit_xdata_va
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;�ᯮ����⥫쭠� �㭪� faka_param_push___r32
;������� ��।�������� (�室�饣�/�室����) ��ࠬ��� ��� ������誨;
;PUSH	R32 -> push		eax   etc;
;����:
;	ebx			-	���� �������� FAKA_FAKEAPI_GEN
;	ecx			-	��᪠/䫠��, 㪠�뢠�騥, ��� ������ ������� ������ �������;
;					FAKA_PUSH___R32___RND  - �����஢��� ������� � ��砩�� ॣ���஬;
;					FAKA_PUSH___R32___SPEC - �����஢��� ������� � ॣ���஬, ��।������ � edx;
;	edx			-	�� ���祭��, �᫨ 䫠� FAKA_PUSH___R32___RND (���祭�� � edx �㤥� 
;					�����஢�����); � ����� ॣ���� - �᫨ 䫠� FAKA_PUSH___R32___SPEC; 
;	edi			-	���� ��� ����� �⮣� ����;
;�����:
;	(+)			-	ᣥ���஢����� �������; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

FAKA_PUSH___R32___RND		equ		01h									;���祭�� ��� ecx;
FAKA_PUSH___R32___SPEC		equ		02h

FAKA_PUSH_EAX				equ		00h									;���祭�� ��� edx; 
FAKA_PUSH_ECX				equ		01h
FAKA_PUSH_EDX				equ		02h
FAKA_PUSH_EBX				equ		03h
FAKA_PUSH_ESP				equ		04h
FAKA_PUSH_EBP				equ		05h
FAKA_PUSH_ESI				equ		06h
FAKA_PUSH_EDI				equ		07h

faka_param_push___r32:
	cmp		ecx, FAKA_PUSH___R32___RND
	je		_fppr32_r_
_fppr32_s_:																;����ਬ ������� � ��।���� ॣ��;
	mov		eax, edx 
	jmp		_fppr32_nxt_1_

_fppr32_r_:
	call	faka_get_rnd_r32											;����ਬ ������� � ��砩�� ॣ��;

_fppr32_nxt_1_: 
	add		al, 50h														;opcode (push reg32); 
	stosb
	ret
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;����� �㭪� faka_param_push___r32 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx


 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;�㭪a faka_param_push___imm8
;������� ��।�������� (�室�饣�/�室����) ��ࠬ��� ��� ������誨;
;PUSH	IMM8 ->	push	55h	etc
;����:
;	ebx			-	���� �������� FAKA_FAKEAPI_GEN
;	ecx			-	��᪠/䫠��, 㪠�뢠�騥, ��� ������ ������� ������ �������;
;					FAKA_PUSH___IMM8___RND  - �����஢��� ������� � ��砩�� imm8;
;					FAKA_PUSH___IMM8___SPEC - �����஢��� ������� � imm8, ��।���� � edx;
;	edx			-	�� ���祭��, �᫨ ���⠢��� 䫠� FAKA_PUSH___IMM8___RND (���祭�� � edx �㤥� 
;					�����஢�����); � ���祭�� imm8 - �᫨ 䫠� FAKA_PUSH___IMM8___SPEC; 
;	edi			-	���� ��� ����� �⮣� ����;
;�����:
;	(+)			-	ᣥ���஢����� �������; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

FAKA_PUSH___IMM8___RND		equ		01h									;���祭�� ��� ecx; 
FAKA_PUSH___IMM8___SPEC		equ		02h 

faka_param_push___imm8:
	mov		al, 6Ah
	stosb																;opcode
	cmp		ecx, FAKA_PUSH___IMM8___RND
	je		_fppimm8_r_
_fppimm8_s_:															;imm8, ��।���� � edx;
	mov		eax, edx
	stosb
	ret	

_fppimm8_r_:															;imm8, ����祭�� ��砩�� ��ࠧ��; 
	mov		eax, 256
	call	faka_get_rnd_num_1

	stosb
	ret
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;����� �㭪� faka_param_push___imm8
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;�㭪a faka_param_push___imm32
;������� ��।�������� (�室�饣�/�室����) ��ࠬ��� ��� ������誨;
;PUSH	IMM32 -> push	555h	etc
;����:
;	ebx			-	���� �������� FAKA_FAKEAPI_GEN
;	ecx			-	��᪠/䫠��, 㪠�뢠�騥, ��� ������ ������� ������ �������;
;					FAKA_PUSH___IMM32___RND  - �����஢��� ������� � ��砩�� imm32;
;					FAKA_PUSH___IMM32___SPEC - �����஢��� ������� � imm32, ��।���� � edx;
;	edx			-	�� ���祭��, �᫨ ���⠢��� 䫠� FAKA_PUSH___IMM32___RND (���祭�� � edx �㤥� 
;					�����஢�����); � ���祭�� imm32 - �᫨ 䫠� FAKA_PUSH___IMM32___SPEC;
;	edi			-	���� ��� ����� �⮣� ����;
;�����:
;	(+)			-	ᣥ���஢����� �������; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

FAKA_PUSH___IMM32___RND		equ	01h										;���祭�� ��� ecx; 
FAKA_PUSH___IMM32___SPEC	equ	02h 

faka_param_push___imm32:
	mov		al, 68h														;opcode
	stosb
	cmp		ecx, FAKA_PUSH___IMM32___RND
	je		_fppimm32_r_
_fppimm32_s_:															;imm32, ��।���� � edx;
	mov		eax, edx
	stosd																;imm32;
	ret	

_fppimm32_r_:															;imm32, ����祭�� ��砩��; 
	mov		eax, 1000h
	call	faka_get_rnd_num_1

	add		eax, 81h 													;imm >= 81h
	stosd																;imm32
	ret
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;����� �㭪� faka_param_push___imm32 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;�㭪a faka_param_push___m32ebpo8 
;������� ��।�������� (�室�饣�/�室����) ��ࠬ��� ��� ������誨;
;PUSH	DWORD PTR [EBP - 04]
;etc
;����:
;	ebx		-	etc; 
;	edi		-	���� ��� ����� �⮣� ����;
;�����:
;	(+)		-	ᣥ���஢����� �������;
;	EAX		-	0, �᫨ �� ����稫��� ᣥ����� �������, ���� EAX != 0; 
;!!!!! �᫨ ���⥫��� ������� ������� ��� � � moffs32, ⮣�� �������� ����� (� ��� �㭪���) �㦭� ���; 
;!!!!! �������� � moffs32 ����� ������� ��㣮� ���� � ࠧ��� ����� ������, ⠪ � ����; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
faka_param_push___m32ebpo8:
	call	faka_check_local_param_num									;�롥६ ��砩�� ���� ������� ��६����, ���� �室�� ��ࠬ���� � �஢�ਬ ��⥫쭮 ���� �� ��� ��ਠ�⮢; 

	inc		eax
	je		_fppm32ebpo8_ret_											;�᫨ eax == -1, � �� ��室; 
	dec		eax
	push	edx
	xchg	eax, edx
	mov		ax, 75FFh
	stosw

	xchg	eax, edx													;eax = 0 ���� 4;
	call	faka_write_moffs8_for_ebp									;ᣥ��ਬ � ����襬 �������� ��६����� ��� �室��� ��ࠬ��� ��� ebp, ���ਬ��, [ebp - 14h] ��� [ebp + 1Ch] - -14h - �����쭠� ��६�����, � 1Ch - �室��� ��ࠬ���; 

	pop		edx
_fppm32ebpo8_ret_:	
	ret	
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;����� �㭪� faka_param_push___m32ebpo8
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;�㭪a faka_param_push___m32
;������� ��।�������� (�室�饣�/�室����) ��ࠬ��� ��� ������誨;
;PUSH	MEM32 -> push	dword ptr [403008h]	etc
;����:
;	ebx			-	���� �������� FAKA_FAKEAPI_GEN
;	ecx			-	��᪠/䫠��, 㪠�뢠�騥, ��� ������ ������� ������ �������;
;					FAKA_PUSH___M32___RND  - �����஢��� ������� � ��砩�� ���ᮬ (�� ���४��);
;					FAKA_PUSH___M32___SPEC - �����஢��� ������� � M32, ��।���� � edx;
;	edx			-	�� ���祭��, �᫨ ���⠢��� 䫠� FAKA_PUSH___M32___RND (���祭�� � edx �㤥� 
;					�����஢�����); � ���祭�� M32 (����) - �᫨ 䫠� FAKA_PUSH___M32___SPEC;
;	edi			-	���� ��� ����� �⮣� ����;
;�����:
;	(+)			-	ᣥ���஢����� �������; 
;	EAX			-	0, �᫨ �� ����稫��� ᣥ����� �������, ���� EAX != 0; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

FAKA_PUSH___M32___RND		equ		01h									;���祭�� ��� ecx; 
FAKA_PUSH___M32___SPEC		equ		02h 

faka_param_push___m32:
	cmp		ecx, FAKA_PUSH___M32___RND
	je		_fppm32_r_ 
_fppm32_s_:																;M32, ��।���� � edx;
	mov		ax, 35FFh													;opcode + modrm
	stosw
	mov		eax, edx
	stosd																;offset32 (aka mem32);
	ret

_fppm32_r_:																;M32, ᣥ��७�� ��砩�� ��ࠧ��; 
	call	faka_check_and_get_rnd_data_va								;��뢠�� �㭪� �஢�ન ��।����� �����⥩ ����� (rdata & xdata), � ⠪�� (� ��砥 �ᯥ� �஢�ન) ����祭�� ��砩���� ���� � ����� �� ��� �����⥩ 
																		;(�� ����� ������ ������ - �롨ࠥ��� ��砩��); 

	test	eax, eax													;�᫨ ���, ⮣�� ��室��
	je		_fppm32_ret_
	
	push	eax
	mov		ax, 35FFh													;opcode + modrm
	stosw
	pop		eax
	stosd																;offset32 (aka mem32 aka m32 aka address 32-bit); 
_fppm32_ret_:	
	ret
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;����� �㭪� faka_param_push___m32 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;�㭪a faka_param_rnd_push
;������� ��।�������� (�室�饣�/�室����) ��ࠬ��� ��� ������誨;
;����� ������ ��ࠬ��� �㤥� ��������� - �롨ࠥ��� ��砩��
;�㭪� �ᯮ����⥫쭠�/�������⥫쭠�; 
;����� �ந�室�� ������� ⮫쪮 ⠪�� ��ࠬ��஢, �� ���祭�� ���� ��砩�� (� ����, ���ਬ��, 
;�� �㦭� �᪠�� ���� ��ப�, ���� �᫠, �����஢��� push c �����-� ������� ���祭��� � ���� 
;����);
;����:
;	ebx			-	etc;
;	edi			-	���� ��� ����� �⮣� ����;
;�����:
;	(+)			-	ᣥ���஢����� ������� push <�����-� ⥬�>
;	EAX			-	�����-� ����; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 
faka_param_rnd_push:
	push	ecx															;��࠭�� � �⥪� ॣ�
	push	edx
	 
_fprp_get_push_:	
	push	06															;⥯��� ��砩�� ��।����, ����� ������ push �㤥� �������;
	call	[ebx].rang_addr
	
	test	eax, eax
	je		_fprp_imm8_rnd_
	dec		eax
	je		_fprp_imm32_rnd_
	dec		eax
	je		_fprp_imm32_spec_
	dec		eax
	je		_fprp_m32_rnd_
	dec		eax
	je		_fprp_m32ebpo8_ 
	
_fprp_r32_rnd_:															;push reg32
	mov		ecx, FAKA_PUSH___R32___RND									;㪠�뢠��, �� ���� ������� ������ ������� � ��砩�� ॣ��; 
	;mov	edx, 12345678h
	call	faka_param_push___r32										;������㥬 �������;

	jmp		_fprp_ret_													;���室�� �� ��室

_fprp_imm8_rnd_:														;push imm8
	mov		ecx, FAKA_PUSH___IMM8___RND									;㪠�뢠��, �� ���� ������� ������ ������� � ��砩�� imm8; 
	;mov	edx, 12345678h
	call	faka_param_push___imm8

	jmp		_fprp_ret_

_fprp_imm32_rnd_:														;push imm32
	mov		ecx, FAKA_PUSH___IMM32___RND								;㪠�뢠��, �� ���� ������� ������ ������� � ��砩�� imm32; 
	;mov	edx, 12345678h
	call	faka_param_push___imm32

	jmp		_fprp_ret_

_fprp_imm32_spec_:														;push imm32 (spec)
																		;imm32 - �㤥� ᮤ�ঠ�� �� ��� ����� �㩭�, � ���� �� ������� ������ (ᥪ�� ������); 
	call	faka_check_and_get_rnd_data_va

	test	eax, eax													;�᫨ ���, ⮣�� �� ����� ��।����, ����� push ������� - �����-� �� ����� ᣥ��������; 
	je		_fprp_get_push_
	                    
	mov		ecx, FAKA_PUSH___IMM32___SPEC								;㪠�뢠��, �� ���� ������� ������ ������� push imm32 - ��� imm32 - �� ���� �� ���⮪ �����; 
	mov		edx, eax
	call	faka_param_push___imm32

	jmp		_fprp_ret_

_fprp_m32_rnd_:															;push m32;
	mov		ecx, FAKA_PUSH___M32___RND									;㪠�뢠��, �� ���� ������� ������ ������� � ��砩�� ��࠭�� ���ᮬ � ��।����� ������ �����; 
	;mov	edx, 12345678h
	call	faka_param_push___m32

	test	eax, eax
	je		_fprp_get_push_
	jmp		_fprp_ret_

_fprp_m32ebpo8_:														;push dword ptr [ebp +- XXh]
	call	faka_param_push___m32ebpo8									;㪠�뢠��, �� ���� ������� ��� ⠪�� ������� =)! 

	test	eax, eax
	je		_fprp_get_push_ 

_fprp_ret_:
	pop		edx 
	pop		ecx
	ret																	;�� ��室; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;����� �㭪� faka_param_rnd_push 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 


 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;�㭪a faka_param_rnd_push___imm32_imm8 
;������� ��।�������� (�室�饣�/�室����) ��ࠬ��� ��� ������誨;
;����� ������ ��ࠬ��� (push imm8 ��� push imm32) �㤥� ��������� - �롨ࠥ��� ��砩��
;�㭪� �ᯮ����⥫쭠�/�������⥫쭠�; 
;����� �ந�室�� ������� ��ࠬ��஢, �� ���祭�� ��砩�� �롨����� �� ��������� ���������;
;����:
;	ebx			-	etc;
;	edi			-	���� ��� ����� �⮣� ����;
;	ecx			-	�᫮ - min ���祭�� (imm), ���஥ � १���� ����� �ਭ��� ��ࠬ���
;	edx			-	�᫮ - max ���祭��; ��祬 edx > ecx; 
;�����:
;	(+)			-	ᣥ���஢����� ������� push imm (8 ��� 32), ��祬 imm = �� � ��������� 
;					[ecx ; edx - 1]; (�, ��� -2?); 
;	EAX			-	�����-� ����; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 
faka_param_rnd_push___imm32_imm8: 
	push	ecx	
	push	edx 

	xchg	eax, edx
	sub		eax, ecx
	call	faka_get_rnd_num_1											;����ਬ �� 

	lea		edx, dword ptr [eax + ecx]
	cmp		edx, 80h
	jl		_fprpimm328_param_6Ah_

_fprpimm328_param_68h_:
	mov		ecx, FAKA_PUSH___IMM32___SPEC
	call	faka_param_push___imm32										;push imm32

	jmp		_fprpimm328_ret_ 

_fprpimm328_param_6Ah_:
	mov		ecx, FAKA_PUSH___IMM8___SPEC
	call	faka_param_push___imm8										;push imm8

_fprpimm328_ret_:
	pop		edx
	pop		ecx
	ret
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;����� �㭪� faka_param_rnd_push___imm32_imm8
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 



;============================[FUNCTIONS FOR INSTR WITH EBP & moffs8]=====================================
;!!!!! �᫨ ���⥫��� ������� ������� ��� � � moffs32, ⮣�� �������� ����� (� ��� �㭪���) �㦭� ���; 
;!!!!! �������� � moffs32 ����� ������� ��㣮� ���� � ࠧ��� ����� ������, ⠪ � ����;  
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;�㭪a faka_check_local_param_num
;�஢�ઠ �� ���४⭮��� ���-�� �������� ��६����� � �室��� ��ࠬ��஢
;� ⠪�� ��砩�� �롮�, ����� �� 2-� ��ਠ�⮢ �㤥� 祪��� ��⥫쭥� ��� ��᫥���饩 ��� �����樨; 
;����:
;	ebx						-	etc
;	[ebx].xfunc_struct_addr	-	���� �������� XTG_FUNC_STRUCT, �� ���� �㤥� �஢�����; 
;�����:
;	eax						-	-1, �᫨ �஢�ઠ �� �ன���� �ᯥ譮, ���� 0 (�᫨ ��࠭� ������� 
;								��६����) ���� 4 (�᫨ �室�� ��ࠬ����);
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
faka_check_local_param_num: 	
	push	edx															;��࠭塞 � �⥪� ॣ�; 
	push	esi 

	push	02
	call	[ebx].rang_addr												;��砩�� �롨ࠥ�, ����� �� ��ਠ�⮢ �㤥� ��⥫쭥� �஢����� � � ���쭥�襬 �������: �������� ��६����� [ebp - XXh] ��� �室��� ��ࠬ��� [ebp + XXh];   

	shl		eax, 02														;eax = 0 ��� 4; 
	lea		edx, dword ptr [eax + 01]									;edx > 0; 
	mov		esi, [ebx].xfunc_struct_addr
	assume	esi: ptr XTG_FUNC_STRUCT									;esi - address of struct XTG_FUNC_STRUCT; 
	test	esi, esi													;�᫨ ����� 0, ⮣�� �������� ���, � ����� �� �� ����ਬ �㭪�, � ���⮬� ������� ������ � ���⨥� ebp - �� ��ਠ�� ������, ��� �������� �� � ������ ��� ��; 
	je		_fclp_fuck_
	cmp		[esi].local_num, (84h / 04)									;���� �஢�ਬ, �᫨ ���-�� �������� ��६����� ����� ������� ���祭��, ⮣�� �멤�� - ⠪ ��� ��� ⠪�� ���樨 ������ ��������� ��㣨� ������. ��� ��ਠ�� ����� ���� �������� ����������� �����樨 ��� ������� � ���; 
	jge		_fclp_fuck_
	cmp		[esi].param_num, (80h / 04)									;etc
	jge		_fclp_fuck_
	test	eax, eax
	je		_fclp_local_
_fclp_param_:															;�᫨ ��࠭� �஢�ઠ � ��᫥����� ������� �室��� ��ࠬ���஢, ⮣�� �஢�ਬ, ����� ���� �� �室�� ��ࠬ���� � ������ �������? 
	imul	edx, [esi].param_num
	jmp		_fclp_nxt_1_
_fclp_local_:
	imul	edx, [esi].local_num										;�� ��� �������� ��६�����; 
_fclp_nxt_1_:
	test	edx, edx 													;⥯��� �஢�ਬ edx - �᫨ �� = 0 (� ����, ���ਬ��, �᫨ ��ࠫ� �����. ��६., � �� ���-�� = 0 - � ���� �� ���); 
	jne		_fclp_ret_													
_fclp_fuck_:															;⮣�� eax = -1 � �� ��室
	xor		eax, eax
	dec		eax
_fclp_ret_:
	pop		esi															;���� eax != -1; (= 0 ��� 4); 
	pop		edx 
	ret
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;����� �㭪� faka_check_local_param_num 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;funka faka_get_moffs8_ebp_local
;����祭�� (�������) ��砩���� 8-����⭮�� ᬥ饭�� � ����� ��� ॣ���� ebp (�����쭠� ��६�����);
;���ਬ��, ������� [ebp - 14h] - -14h (���� 0xEC) �� � ���� 8-����⭮� ᬥ饭�� � ����� ��� ॣ���� ebp; 
;����:
;	ebx		-	etc
;�����:
;	eax		-	��砩��� 8-����⭮� ᬥ饭�� (������ ��砩�� ����� �����쭮� ��६����� � ��ந��� ᬥ饭��); 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
faka_get_moffs8_ebp_local:												;moffs8 - mem32 offset8 ebp; 
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
;����� �㭪� faka_get_moffs8_ebp_local
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;funka faka_get_moffs8_ebp_param
;����祭�� (�������) ��砩���� 8-����⭮�� ᬥ饭�� � ����� ��� ॣ���� ebp (�室��� ��ࠬ���);
;���ਬ��, ������� [ebp + 14h] - 14h (���� 0x14) �� � ���� 8-����⭮� ᬥ饭�� � ����� ��� ॣ���� ebp; 
;����:
;	ebx		-	etc 
;�����:
;	eax		-	��砩��� 8-����⭮� ᬥ饭�� (������ ��砩�� ����� �室���� ��ࠬ��� � ��ந��� ᬥ饭��);  
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
faka_get_moffs8_ebp_param:												;moffs8 - mem32 offset8 ebp; 
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
;����� �㭪� faka_get_moffs8_ebp_param
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;�㭪a faka_write_moffs8_for_ebp 
;������� � ������ 1 ���� - �� ���� �����쭠� ��६�����, ���� �室��� ��ࠬ��� ��� ॣ� ebp; 
;� ����, ���ਬ��, [ebp - 14h] � [ebp + 1Ch] - -14h - �� �����쭠� ��६�����, � +1Ch - �室��� ��ࠬ���; 
;����:
;	ebx			-	etc
;	eax			-	0 ��� �� ���� =) (�᫮ 4); 0 - ����� �㤥� ������� �������� ��६�����, ���� �室��� ��ࠬ���
;�����:
;	eax			-	ᣥ���஢���� � ����ᠭ�� ���⥪; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
faka_write_moffs8_for_ebp:
	test	eax, eax
	je		_faka_ebpo8_gl_

_faka_ebpo8_gp_:
	call	faka_get_moffs8_ebp_param

	stosb
	jmp		_faka_ebpo8_ret_

_faka_ebpo8_gl_:
	call	faka_get_moffs8_ebp_local

	stosb
_faka_ebpo8_ret_:
	ret
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;����� �㭪� faka_write_moffs8_for_ebp
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
 
;============================[FUNCTIONS FOR INSTR WITH EBP & moffs8]=====================================





;========================================================================================================
;������� ��-������襪
;����:
;	ebx				-	���� �������� FAKA_FAKEAPI_GEN
;	[ebx].api_va	-	VirtualAddress, �� ���஬� �㤥� ������ (��᫥ ����㧪� �ண� � ������) 
;						���� �㦭�� ������ �㭪�;
;	edi				-	����, �㤠 ᣥ���஢��� �������� (edi = [ebx].tw_api_addr);
;�����:
;	(+)				-	ᣥ���஢����� ������誠
;	edi				-	���� ��� ���쭥�襩 ����� ����;
;========================================================================================================

;==================================[GEN WINAPI WITHOUT PARAM]============================================
;======================================[GEN WINAPI CALL]=================================================
;kernel32.dll
;DWORD WINAPI GetVersion(void);
;UINT GetOEMCP(void);
;DWORD WINAPI GetCurrentThreadId(void);
;HANDLE WINAPI GetCurrentProcess(void);
;DWORD WINAPI GetTickCount(void);
;DWORD WINAPI GetCurrentProcessId(void);
;HANDLE WINAPI GetProcessHeap(void);
;UINT GetACP(void);
;LPTSTR WINAPI GetCommandLineA(void);
;HANDLE WINAPI GetCurrentThread(void);
;BOOL WINAPI IsDebuggerPresent(void);
;LCID GetThreadLocale(void);
;LPTSTR WINAPI GetCommandLineW(void);
;LANGID GetSystemDefaultLangID(void);
;LCID GetSystemDefaultLCID(void);
;LANGID GetUserDefaultUILanguage(void);

;user32.dll
;HWND WINAPI GetFocus(void);
;HWND WINAPI GetDesktopWindow(void);
;HCURSOR WINAPI GetCursor(void);
;HWND WINAPI GetActiveWindow(void);
;HWND WINAPI GetForegroundWindow(void);
;HWND WINAPI GetCapture(void);
;DWORD WINAPI GetMessagePos(void);
;LONG WINAPI GetMessageTime(void);
faka_winapi_0_param: 
faka_gen_winapi_call:
	mov		ax, 15FFh
	stosw																;opcode + modrm
	mov		eax, [ebx].api_va											;address (offset32) aka VA; 
	stosd
	ret 
;==================================[GEN WINAPI WITHOUT PARAM]============================================
;======================================[GEN WINAPI CALL]=================================================



;===================================[GEN WINAPI WITH 1 RND PARAM]========================================
;HWND WINAPI GetParent(__in  HWND hWnd);
;BOOL WINAPI IsWindowVisible(__in  HWND hWnd);
;BOOL WINAPI IsIconic(__in  HWND hWnd);
;BOOL WINAPI IsWindowEnabled(__in  HWND hWnd);
;int WINAPI GetDlgCtrlID(__in  HWND hwndCtl);
;HWND WINAPI SetActiveWindow(__in  HWND hWnd); 
;HWND WINAPI GetTopWindow(__in_opt  HWND hWnd);
;BOOL WINAPI IsZoomed(__in  HWND hWnd); 
;int WINAPI GetWindowTextLengthA(__in  HWND hWnd);
;COLORREF GetTextColor(__in  HDC hdc); 
;COLORREF GetBkColor(__in  HDC hdc); 
;DWORD GetObjectType(__in  HGDIOBJ h); 
;int GetMapMode(__in  HDC hdc);
;int GetBkMode(__in  HDC hdc);
faka_winapi_1_param: 
	call	faka_param_rnd_push 										;hWnd; 
	call	faka_gen_winapi_call 
	ret
;===================================[GEN WINAPI WITH 1 RND PARAM]========================================



;===================================[GEN WINAPI WITH 2 RND PARAM]========================================
;HWND WINAPI GetDlgItem(__in_opt  HWND hDlg,__in int nIDDlgItem);
;UINT IsDlgButtonChecked(__in  HWND hDlg,__in  int nIDButton);
;BOOL WINAPI IsChild(__in  HWND hWndParent,__in  HWND hWnd); 
;HGDIOBJ SelectObject(__in  HDC hdc,__in  HGDIOBJ hgdiobj); 
faka_winapi_2_param: 
	call	faka_param_rnd_push 
	call	faka_param_rnd_push
	call	faka_gen_winapi_call
	ret
;===================================[GEN WINAPI WITH 2 RND PARAM]========================================



;==========================================[PtVisible]===================================================
;BOOL PtVisible(__in  HDC hdc,__in  int X,__in  int Y);
faka_winapi_3_param:
faka_PtVisible:
	call	faka_param_rnd_push
	call	faka_param_rnd_push
	call	faka_param_rnd_push

	call	faka_gen_winapi_call 
	
	ret
;==========================================[PtVisible]===================================================
 


;===========================================[MulDiv]===================================================== 
;int MulDiv(__in  int nNumber,__in  int nNumerator,__in  int nDenominator);
faka_MulDiv:
	call	faka_param_rnd_push 										;3 rnd param
	call	faka_param_rnd_push											;2 rnd param
	call	faka_param_rnd_push											;1 rnd param
	call	faka_gen_winapi_call										;call; 
	ret
;===========================================[MulDiv]===================================================== 



;========================================[IsValidCodePage]=============================================== 
;BOOL IsValidCodePage(__in  UINT CodePage);
faka_IsValidCodePage:
	mov		ecx, 37														;push/pop ? ;IBM EBCDIC US-Canada
	mov		edx, 65001													;Unicode (UTF-8) -> �� ����室����� �������� ��ࠬ����; 
	call	faka_param_rnd_push___imm32_imm8							;1 rnd param
	call	faka_gen_winapi_call										;call 
	ret
;========================================[IsValidCodePage]=============================================== 



;=========================================[GetDriveTypeA]================================================ 
;UINT WINAPI GetDriveTypeA(__in_opt  LPCTSTR lpRootPathName);
faka_GetDriveTypeA:
	mov		ecx, FAKA_PUSH___IMM8___SPEC
	xor		edx, edx													;while only 0! 
	call	faka_param_push___imm8										;push imm8
	call	faka_gen_winapi_call
	ret
;=========================================[GetDriveTypeA]================================================  



;=========================================[IsValidLocale]================================================
;BOOL IsValidLocale(__in  LCID Locale,__in  DWORD dwFlags); 
faka_IsValidLocale:
	push	02
	call	[ebx].rang_addr

	inc		eax															;LCID_INSTALLED or LCID_SUPPORTED; 
	mov		ecx, FAKA_PUSH___IMM8___SPEC
	xchg	eax, edx 
	call	faka_param_push___imm8										;2 param

	push	05
	call	[ebx].rang_addr

	inc		eax
	shl		eax, 10
	mov		ecx, FAKA_PUSH___IMM32___SPEC
	xchg	eax, edx
	call	faka_param_push___imm32										;1 param: 400h, 800h, 0C00h, 1000h, 1400h; 
	
	call	faka_gen_winapi_call										;call 

	ret 
;=========================================[IsValidLocale]================================================



;========================================[GetSystemMetrics]==============================================
;int WINAPI GetSystemMetrics(__in  int nIndex);
faka_GetSystemMetrics:
	push	100															;64 < 80h -> imm8; 
	call	[ebx].rang_addr

	mov		ecx, FAKA_PUSH___IMM8___SPEC
	xchg	eax, edx
	call	faka_param_push___imm8

	call	faka_gen_winapi_call										;call 

	ret 
;========================================[GetSystemMetrics]============================================== 



;=========================================[CheckDlgButton]===============================================
;BOOL CheckDlgButton(__in  HWND hDlg,__in  int nIDButton,__in  UINT uCheck);
faka_CheckDlgButton: 
	push	03
	call	[ebx].rang_addr

	mov		ecx, FAKA_PUSH___IMM8___SPEC
	xchg	eax, edx
	call	faka_param_push___imm8										;3 param (BST_CHECKED, BST_INDETERMINATE, BST_UNCHECKED); 

	call	faka_param_rnd_push											;2 param
	call	faka_param_rnd_push											;1 param

	call	faka_gen_winapi_call										;call 
	
	ret
;=========================================[CheckDlgButton]===============================================



;==========================================[GetSysColor]=================================================
;========================================[GetSysColorBrush]==============================================
;DWORD WINAPI GetSysColor(__in  int nIndex);
;HBRUSH GetSysColorBrush(__in  int nIndex);
faka_GetSysColor:
faka_GetSysColorBrush:
	push	31 
	call	[ebx].rang_addr

	mov		ecx, FAKA_PUSH___IMM8___SPEC
	xchg	eax, edx
	call	faka_param_push___imm8										;nIndex

	call	faka_gen_winapi_call										;call ;GetSysColor; 

	ret
;==========================================[GetSysColor]=================================================
;========================================[GetSysColorBrush]==============================================



;==========================================[GetKeyState]=================================================
;SHORT WINAPI GetKeyState(__in  int nVirtKey);
faka_GetKeyState:
	mov		ecx, 000													; 
	mov		edx, 255													;
	call	faka_param_rnd_push___imm32_imm8							;1 rnd param
	call	faka_gen_winapi_call										;call 

	ret
;==========================================[GetKeyState]=================================================



;========================================[GetKeyboardType]===============================================
;int WINAPI GetKeyboardType(__in  int nTypeFlag);
faka_GetKeyboardType:
	push	03
	call	[ebx].rang_addr

	mov		ecx, FAKA_PUSH___IMM8___SPEC
	xchg	eax, edx
	call	faka_param_push___imm8										;nTypeFlag; 

	call	faka_gen_winapi_call										;call;  

	ret
;========================================[GetKeyboardType]===============================================



;========================================[GetKeyboardLayout]=============================================
;HKL WINAPI GetKeyboardLayout(__in  DWORD idThread);
faka_GetKeyboardLayout:
	mov		ecx, FAKA_PUSH___IMM8___SPEC
	xor		edx, edx													;push 0 -> cuurent thread; 
	call	faka_param_push___imm8

	call	faka_gen_winapi_call										;
	ret 
;========================================[GetKeyboardLayout]=============================================



;============================================[DrawIcon]==================================================
;BOOL WINAPI DrawIcon(__in  HDC hDC,__in  int X,__in  int Y,__in  HICON hIcon);
faka_winapi_4_param:
faka_DrawIcon: 
	call	faka_param_rnd_push
	call	faka_param_rnd_push
	call	faka_param_rnd_push
	call	faka_param_rnd_push

	call	faka_gen_winapi_call										; 

	ret
;============================================[DrawIcon]==================================================



;===========================================[SetTextColor]===============================================
;============================================[SetBkColor]================================================
;COLORREF SetTextColor(__in  HDC hdc,__in  COLORREF crColor);
;COLORREF SetBkColor(__in  HDC hdc,__in  COLORREF crColor);
;COLORREF GetNearestColor(__in  HDC hdc,__in  COLORREF crColor);
faka_SetTextColor:
faka_SetBkColor:
faka_GetNearestColor:
	mov		ecx, 00h													; 
	mov		edx, 00FFFFFFh												;MAX COLORREF
	call	faka_param_rnd_push___imm32_imm8							;2 rnd param

	call	faka_param_rnd_push											;1 rnd param; 

	call	faka_gen_winapi_call										;call 


	ret
;===========================================[SetTextColor]===============================================
;============================================[SetBkColor]================================================



;============================================[SetBkMode]=================================================
;int SetBkMode(__in  HDC hdc,__in  int iBkMode);
faka_SetBkMode:
	push	02
	call	[ebx].rang_addr

	inc		eax
	mov		ecx, FAKA_PUSH___IMM8___SPEC
	xchg	eax, edx
	call	faka_param_push___imm8

	call	faka_param_rnd_push

	call	faka_gen_winapi_call										; 
	
	ret
;============================================[SetBkMode]=================================================



;============================================[Rectangle]=================================================
;BOOL Rectangle(__in  HDC hdc,__in  int nLeftRect,__in  int nTopRect,__in  int nRightRect,__in  int nBottomRect);
;BOOL Ellipse(__in  HDC hdc,__in  int nLeftRect,__in  int nTopRect,__in  int nRightRect,__in  int nBottomRect);
faka_winapi_5_param:
faka_Rectangle: 
faka_Ellipse:
	call	faka_param_rnd_push
	call	faka_param_rnd_push
	call	faka_param_rnd_push
	call	faka_param_rnd_push
	call	faka_param_rnd_push

	call	faka_gen_winapi_call 
	
	ret
;============================================[Rectangle]=================================================



;======================================[QueryPerformanceCounter]=========================================
;=====================================[QueryPerformanceFrequency]========================================
;BOOL WINAPI QueryPerformanceCounter(__out  LARGE_INTEGER *lpPerformanceCount);
;BOOL WINAPI QueryPerformanceFrequency(__out  LARGE_INTEGER *lpFrequency);
faka_QueryPerformanceCounter:
faka_QueryPerformanceFrequency:
	push	08 
	pop		eax															;sizeof (LARGE_INTEGER)
	call	faka_get_rnd_suit_xdata_va									;����砥� ��砩�� ���室�騩 ���� (��⥭ 4!); 

	test	eax, eax
	je		_faka_Qx_ret_												;�᫨ �� 㤠���� ⠪�� ���� �������, ⮣�� �� ��室
	
	mov		ecx, FAKA_PUSH___IMM32___SPEC
	xchg	eax, edx
	call	faka_param_push___imm32										;���� ᣥ��ਬ ��ࠬ��� ����: push <address> (68h XXXXXXXXh); 

	call	faka_gen_winapi_call										;call
	
_faka_Qx_ret_:
	ret																	;�� ��室! 
;======================================[QueryPerformanceCounter]=========================================
;=====================================[QueryPerformanceFrequency]========================================



;============================================[lstrcmpiA]=================================================
;============================================[lstrcmpA]==================================================
;int WINAPI lstrcmpiA(__in  LPCTSTR lpString1,__in  LPCTSTR lpString2);
;int WINAPI lstrcmpA(__in  LPCTSTR lpString1,__in  LPCTSTR lpString2); 
faka_lstrcmpiA:
faka_lstrcmpA:
	mov		eax, FAKA_GET_RND_STRA_ADDR
	call	faka_get_rnd_val_va											;����砥� ���� ��砩��� ��ப� (� rdata); 

	test	eax, eax
	je		_faka_xA_ret_												;����稫� 0?
	xchg	eax, esi													;�᫨ ����稫� ��ଠ��� ���� ��ப�, � ��࠭�� ��� � esi; 

	mov		eax, FAKA_GET_RND_STRA_ADDR
	call	faka_get_rnd_val_va											;����砥� ���� ��� ����� ��ப�

	test	eax, eax
	je		_faka_xA_ret_
	cmp		eax, esi													;�᫨ 2 ���� ��������� (���� �� ���� � �� �� ��ப�), ⮣�� �� ��室 
	je		_faka_xA_ret_
		
	mov		ecx, FAKA_PUSH___IMM32___SPEC
	xchg	eax, edx
	call	faka_param_push___imm32										;���� ᣥ��ਬ push <addr 1> (68h ...);

	mov		ecx, FAKA_PUSH___IMM32___SPEC								;push <addr 2> (68h...);
	mov		edx, esi
	call	faka_param_push___imm32

	call	faka_gen_winapi_call										;call 

_faka_xA_ret_:
	ret
;============================================[lstrcmpiA]=================================================
;============================================[lstrcmpA]==================================================



;==========================================[GetSystemTime]===============================================
;==========================================[GetLocalTime]================================================
;void WINAPI GetSystemTime(__out  LPSYSTEMTIME lpSystemTime); 
;void WINAPI GetLocalTime(__out  LPSYSTEMTIME lpSystemTime);
faka_GetSystemTime:
faka_GetLocalTime:
	push	16
	pop		eax															;sizeof (SYSTEMTYME); 
	call	faka_get_rnd_suit_xdata_va									;����砥� ��砩�� ���室�騩 ���� (��⥭ 4!); 

	test	eax, eax
	je		_faka_Gx_ret_												;�᫨ �� 㤠���� ⠪�� ���� �������, ⮣�� �� ��室
	
	mov		ecx, FAKA_PUSH___IMM32___SPEC
	xchg	eax, edx
	call	faka_param_push___imm32										;���� ᣥ��ਬ ��ࠬ��� ����: push <address> (68h XXXXXXXXh); 

	call	faka_gen_winapi_call										;call
	
_faka_Gx_ret_:
	ret																	;�� ��室! 
;==========================================[GetSystemTime]===============================================
;==========================================[GetLocalTime]================================================



;============================================[lstrcpyA]==================================================
;LPTSTR WINAPI lstrcpyA(__out  LPTSTR lpString1,__in   LPTSTR lpString2);
faka_lstrcpyA:
																		;��ப� �� ������ ��४�뢠���� (� ���� ���� ����, ���ਬ��, ������ ���� �� xdata, � ��㣮� �� rdata etc); 
	mov		eax, FAKA_GET_RND_STRA_ADDR
	call	faka_get_rnd_val_va											;����砥� ���� ��砩��� ��ப� (� rdata); 

	test	eax, eax
	je		_faka_lstrxA_ret_											;����稫� 0?
	xchg	eax, esi													;ᥩ�� ࠡ�⠥� ⮫쪮 � ansi-��ப���! 

	push	esi
	call	xstrlen														;㧭��� ����� ��������� ��ப�;

	inc		eax															;eax = ����� ��ப� + '\0'; 
	call	faka_get_rnd_suit_xdata_va									;����砥� ��砩�� ���室�騩 ���� (��⥭ 4!); 

	test	eax, eax
	je		_faka_lstrxA_ret_											;�᫨ �� 㤠���� ⠪�� ���� �������, ⮣�� �� ��室
	push	eax

	mov		ecx, FAKA_PUSH___IMM32___SPEC
	mov		edx, esi
	call	faka_param_push___imm32										;lpString2
	
	mov		ecx, FAKA_PUSH___IMM32___SPEC								;lpString1
	pop		edx 
	call	faka_param_push___imm32										;���� ᣥ��ਬ ��ࠬ��� ����: push <address> (68h XXXXXXXXh); 

	call	faka_gen_winapi_call										;call 

_faka_lstrxA_ret_:
	ret
;============================================[lstrcpyA]==================================================



;============================================[lstrlenA]==================================================
;============================================[CharNextA]=================================================
;===========================================[LoadLibraryA]===============================================
;int WINAPI lstrlenA(__in  LPCTSTR lpString);
;LPTSTR WINAPI CharNextA(__in  LPCTSTR lpsz);
;;HMODULE WINAPI LoadLibraryA(__in  LPCTSTR lpFileName);
faka_lstrlenA:
faka_CharNextA:
;faka_LoadLibraryA:
	mov		eax, FAKA_GET_RND_STRA_ADDR
	call	faka_get_rnd_val_va											;����砥� ���� ��砩��� ��ப� (� rdata); 

	test	eax, eax
	je		_faka_lstrlenA_ret_											;����稫� 0?

	mov		ecx, FAKA_PUSH___IMM32___SPEC								;lpString
	xchg	eax, edx
	call	faka_param_push___imm32										;���� ᣥ��ਬ ��ࠬ��� ����: push <address> (68h XXXXXXXXh); 

	call	faka_gen_winapi_call										;call 

_faka_lstrlenA_ret_:
	ret
;============================================[lstrlenA]==================================================
;============================================[CharNextA]=================================================
;===========================================[LoadLibraryA]=============================================== 



;==========================================[GetClientRect]===============================================
;==========================================[GetWindowRect]===============================================
;BOOL WINAPI GetClientRect(__in   HWND hWnd,__out  LPRECT lpRect);
;BOOL WINAPI GetWindowRect(__in   HWND hWnd,__out  LPRECT lpRect);
faka_GetClientRect: 
faka_GetWindowRect:
	push	16
	pop		eax															;sizeof (RECT); 
	call	faka_get_rnd_suit_xdata_va									;����砥� ��砩�� ���室�騩 ���� (��⥭ 4!); 

	test	eax, eax
	je		_faka_gcrx_ret_												;�᫨ �� 㤠���� ⠪�� ���� �������, ⮣�� �� ��室
	
	mov		ecx, FAKA_PUSH___IMM32___SPEC								;lpRect
	xchg	eax, edx
	call	faka_param_push___imm32										;���� ᣥ��ਬ ��ࠬ��� ����: push <address> (68h XXXXXXXXh); 

	call	faka_param_rnd_push											;hWnd

	call	faka_gen_winapi_call										;call 
	
_faka_gcrx_ret_:
	ret																	;�� ��室! 
;==========================================[GetClientRect]===============================================
;==========================================[GetWindowRect]===============================================



;=========================================[GetModuleHandleA]=============================================
;HMODULE WINAPI GetModuleHandleA(__in_opt  LPCTSTR lpModuleName); 
faka_GetModuleHandleA:
	mov		eax, FAKA_GET_RND_STRA_ADDR
	call	faka_get_rnd_val_va											;����砥� ���� ��砩��� ��ப� (� rdata); 

	xchg	eax, edx
	test	edx, edx
	je		_gmhA_0_

	mov		ecx, FAKA_PUSH___IMM32___SPEC								;lpModuleName (addr); 
	call	faka_param_push___imm32										;���� ᣥ��ਬ ��ࠬ��� ����: push <address> (68h XXXXXXXXh); 

	jmp		_gmhA_gwc_

_gmhA_0_:
	mov		ecx, FAKA_PUSH___IMM8___SPEC
	call	faka_param_push___imm8

_gmhA_gwc_:
	call	faka_gen_winapi_call										;call 

_faka_gmhA_ret_: 
	ret
;=========================================[GetModuleHandleA]=============================================



;===========================================[GetCursorPos]===============================================
;BOOL WINAPI GetCursorPos(__out  LPPOINT lpPoint);
faka_GetCursorPos:
	push	08
	pop		eax															;sizeof (POINT); 
	call	faka_get_rnd_suit_xdata_va									;����砥� ��砩�� ���室�騩 ���� (��⥭ 4!); 

	test	eax, eax
	je		_faka_gcpx_ret_												;�᫨ �� 㤠���� ⠪�� ���� �������, ⮣�� �� ��室
	
	mov		ecx, FAKA_PUSH___IMM32___SPEC								;lpPoint
	xchg	eax, edx
	call	faka_param_push___imm32										;���� ᣥ��ਬ ��ࠬ��� ����: push <address> (68h XXXXXXXXh); 

	call	faka_gen_winapi_call										;call 
	
_faka_gcpx_ret_:
	ret
;===========================================[GetCursorPos]===============================================



;============================================[LoadIconA]=================================================
;===========================================[LoadCursorA]================================================
;HICON WINAPI LoadIconA(__in_opt  HINSTANCE hInstance,__in      LPCTSTR lpIconName);
;HCURSOR WINAPI LoadCursorA(__in_opt  HINSTANCE hInstance,__in      LPCTSTR lpCursorName);
faka_LoadIconA:
faka_LoadCursorA: 
	push	07
	call	[ebx].rang_addr

	add		eax, 32512

	mov		ecx, FAKA_PUSH___IMM32___SPEC
	xchg	eax, edx
	call	faka_param_push___imm32

	mov		ecx, FAKA_PUSH___IMM8___SPEC
	xor		edx, edx
	call	faka_param_push___imm8

	call	faka_gen_winapi_call										;call 

	ret
;============================================[LoadIconA]=================================================
;===========================================[LoadCursorA]================================================



;===========================================[FindWindowA]================================================
;HWND WINAPI FindWindowA(__in_opt  LPCTSTR lpClassName,__in_opt  LPCTSTR lpWindowName);
faka_FindWindowA:
	mov		eax, FAKA_GET_RND_STRA_ADDR
	call	faka_get_rnd_val_va											;����砥� ���� ��砩��� ��ப� (� rdata); 

	xchg	eax, edx
	test	edx, edx
	je		_faka_fwa_ret_

	mov		eax, FAKA_GET_RND_STRA_ADDR
	call	faka_get_rnd_val_va											;����砥� ���� ��砩��� ��ப� (� rdata); 

	test	eax, eax
	je		_faka_fwa_ret_
	cmp		eax, edx
	je		_faka_fwa_ret_

	push	eax
	mov		ecx, FAKA_PUSH___IMM32___SPEC
	call	faka_param_push___imm32

	mov		ecx, FAKA_PUSH___IMM32___SPEC								;��� push ecx ... pop ecx?; 
	pop		edx
	call	faka_param_push___imm32

	call	faka_gen_winapi_call 

_faka_fwa_ret_:
	ret
;===========================================[FindWindowA]================================================



;==========================================[GetProcAddress]==============================================
;FARPROC WINAPI GetProcAddress(__in  HMODULE hModule,__in  LPCSTR lpProcName);
faka_GetProcAddress: 
	mov		eax, FAKA_GET_RND_STRA_ADDR
	call	faka_get_rnd_val_va											;����砥� ���� ��砩��� ��ப� (� rdata); 

	test	eax, eax
	je		_faka_gpa_ret_

	mov		ecx, FAKA_PUSH___IMM32___SPEC
	xchg	eax, edx
	call	faka_param_push___imm32										;lpProcName

	mov		eax, 500h
	call	faka_get_rnd_num_1

	add		eax, 04 
	shl		eax, 20
	mov		ecx, FAKA_PUSH___IMM32___SPEC
	xchg	eax, edx
	call	faka_param_push___imm32										;fake ImageBase (aka hModule);

	call	faka_gen_winapi_call										;call 

_faka_gpa_ret_: 
	ret
;==========================================[GetProcAddress]==============================================

;========================================================================================================
;������� 䥩����� ������ �㭪権; 
;========================================================================================================
     



 




