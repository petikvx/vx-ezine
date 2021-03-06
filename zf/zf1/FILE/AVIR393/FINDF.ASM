
public	findIni,findRun,changePath,varAll,varFiles,pathIni,path,fTime,fDate
extrn	 print:near,readKey:near

	.model	small

	assume cs:code, ds:data
code	segment public
comment *
nextDisk:
	call findIni
nextFile:
	call findRun
	jc goChange
	lea dx,path
	call print
	jmp nextFile
goChange:
	call changePath
	jc nextDisk
	ret
print:
	push ax si
	mov si,dx
nextChar:
	lodsb
	or al,al
	je endPrint
	mov ah,0Eh
	int 10h
	jmp nextChar
endPrint:
	mov ax,0E0Ah
	int 10h
	mov ax,0E0Dh
	int 10h
	pop si ax
	ret
*
; ����ணࠬ�� �ନ஢���� ��ப� path � ���樠����樨 ⠡���� fptr
findIni proc
	push ax bx cx dx si di
	lea si,fptr
	lodsw
	mov word ptr [si-2],si
	mov word ptr [si],0
	lea si,pathIni
	cmp byte ptr [si],0
	je  goodExit
	call setAlld
	lea di,path
	mov cx,32
	rep movsw
	call delSlash
doDelSl:
	call addMaskToPath
	call findPath
	jnc goodExit
	cmp al,12h
	je  findAll
	call delTailName
	call fillMask
	call findPath
	jnc goodExit
	cmp al,12h
	stc
	jne goodExit
findAll:
	call delDirName
	call findDir
	clc
goodExit:
	pop di si dx cx bx ax
	ret
	endp

; ����ணࠬ�� �஢�ન ��ப� * ��� �஢�ન ��� ��᪮�
setAlld proc
	push si
	lea si,pathIni
	cmp word ptr [si],'*'
	je  findAlld
	cmp word ptr [si],':*'
	jne find2
	call fillMask
findAlld:
	mov varAll,1
	mov word ptr [si],':C'
	mov byte ptr [si+2],0
find2:
	pop si
	ret
	endp

; ����ணࠬ�� 㤠��� ����� \ �� ��ப� path, �᫨ �� ���������
delSlash     proc
	push cx si di
	call formDI_CX
	dec si
	dec si
	cmp byte ptr [si],'\'
	jne noDelSl
	mov byte ptr [si],0
noDelSl:
	pop di si cx
	ret
	endp

; ����ணࠬ�� �����頥�: SI - 㪠��⥫� �� ����� ��ப� + 1, 
; DI - 㪠��⥫� �� ��� 䠩�� ��� ���, CX - ����� ����� 䠩��
formDI_CX    proc
	lea si,path
	push ax
	mov di,si
	xor cx,cx
cicFind1:
	lodsb
	cmp al,':'
	je storePtr
	cmp al,'\'
	jne noStorePtr
storePtr:
	xor cx,cx
	mov di,si
noStorePtr:
	inc cx
	or al,al
	jne cicFind1
	pop ax
	ret
	endp

; ����ணࠬ�� �������� \'maskF' � ��ப� path
addMaskToPath	proc
	push cx si di
	call formDI_CX
	mov di,si
	dec si
	mov byte ptr [si],'\'
	lea si,maskF
	mov cx,7
	rep movsw
	pop di si cx
	ret
	endp

; ����ணࠬ�� �ந������ ���� ᫥���饣� 䠩��
findPath     proc
	push cx dx
	call setDta
	mov cx,00100111b
	lea dx,path
	mov ah,4Eh
	int 21h
	pop dx cx
	ret
	endp

; ����ணࠬ�� ��⠭�������� DTA �� ����� DS:DX
setDta	     proc
	push ax dx
	lea dx,myDta
	mov ah,1ah
	int 21h
	pop dx ax
	ret
	endp

; ����ணࠬ�� 㤠��� ��� 䠩�� �� ��ப� path
delTailName  proc
	push cx si di
	call formDI_CX
	mov byte ptr [di-1],0
	pop di si cx
	ret
	endp

; ����ணࠬ�� ����頥� ��� 䠩�� ��᪮� maskF
fillMask     proc
	push ax cx si di
	call formDI_CX
	mov si,di
	lea di,maskF
	cmp byte ptr [si],0
	je noFillM
	rep movsb
	mov varFiles,1
noFillM:
	pop di si cx ax
	ret
	endp

; ����ணࠬ�� 㤠��� ���� � ��� ��⠫��� �� ��ப� path
delDirName2  proc
	call delTailName
delDirName:
	call delTailName
	call addMaskAll
	ret
	endp

; ����ணࠬ�� ��� ��⠫��� �� ��� path
findDir      proc
	push cx dx
	call setDta
	mov cx,00010000b
	lea dx,path
	mov ah,4Eh
	int 21h
	pop dx cx
	jc dirFound
checkDir:
	cmp attrib,10h
	je dirFound
	call findNextP
	jnc checkDir
dirFound:
	ret
	endp

; ����ணࠬ�� ��� ᫥���騩 䠩�
findNextP    proc
	push ax
	call setDta
	mov ah,4Fh
	int 21h
	pop ax
	ret
	endp

; ����ணࠬ�� ��� ᫥���騩 䠩�
findRun      proc
	push ax cx dx si
	mov si,fptr
	cmp word ptr [si],0
	je  findFile
findNextFile:
	call findNextP
	jnc fileFound
	jmp short findFistDir
findFile:
	inc word ptr [si]
	call findPath
	jnc  fileFound
	jmp short findFistDir
backDir:
	dec si
	dec si
	cmp si,offset fptr
	stc
	je fileNotFound
	call delDirName2
	mov fptr,si
findFistDir:
	call delDirName
	mov cx,[si]
	call findDir
	jc backDir
	dec cx
	jz changeDir
findNextDir:
	call findNextP
	jc  backDir
	cmp attrib,10h
	jne findNextDir
	loop findNextDir
changeDir:
	inc cx
	inc word ptr [si]
	cmp byte ptr fname,'.'
	je  findNextDir
	inc si
	inc si
	mov fptr,si
	mov word ptr [si],0
	call addDirName
	call addMaskToPath
	jmp findFile
fileFound:
	call addDirName
	clc
fileNotFound:
	pop si dx cx ax
	ret
	endp

addDirName   proc
	push cx si di
	call formDI_CX
	lea si,fname
	mov cx,7
	rep movsw
	pop di si cx
	ret
	endp

; ����ணࠬ�� �������� ���� *.* � ��ப� path ��� ���᪠ ��⠫����
addMaskAll   proc
	push cx si di
	call formDI_CX
	dec si
	mov word ptr [si],'*\'
	mov word ptr [si+2],'*.'
	mov byte ptr [si+4],0
	pop di si cx
	ret
	endp

; ����ணࠬ�� ����訢��� ᫥���騩 䫮��� ��� 
; ��� ��⠭�������� ���� ���⪨� ���
changePath	proc
	push ax dx
	cmp varAll,1
	jne checkFlopy
	call getHD
	jmp short changeHD
checkFlopy:
	mov ax,word ptr path
	cmp ah,':'
	clc
	jne exitChPath
	or al,20h
	cmp al,'b'
	ja exitChPath
	lea dx,diskete
	call print
	call readKey
changeHD:
	cmc
exitChPath:
	pop dx ax
	ret
	endp

; ����ணࠬ�� ��� ᫥���騩 ���ꥬ�� ���⪨� ���
getHD	proc
	push ax bx dx
	mov bl,pathIni
	xor bh,bh
	sub bl,40h
nextHD:
	inc bx
	cmp bl,26
	cmc
	jb notFound
	mov ax,4409h
	int 21h
	jc  nextHD
	test dh,92h
	jnz nextHD
	mov ax,4408h
	int 21h
	dec ax
	jnz nextHD
	xchg ax,bx
	or al,40h
	mov pathIni,al
	clc
notFound:
	pop dx bx ax
	ret
	endp
	ends
data	segment public
diskete 	db 'Check another disk (y/n) ? ',0
varFiles	db 0
varAll		db 0
maskF		db '*.*', 10 dup (0)
myDta		db 15h dup (?)
attrib		db ?
fTime		dw ?
fDate		dw ?
longFlo 	dw ?
longFhi 	dw ?
fname		db 20 dup (?)
pathIni 	db '*:\*.*',0,70 dup (?)
path		db 70 dup (?)
fptr		dw 100 dup (?)
	ends
        end
