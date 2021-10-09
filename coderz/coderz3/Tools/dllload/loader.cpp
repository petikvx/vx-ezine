#include <stdio.h>
#include <stdlib.h>
#include <windows.h>
void id2();
void id1();
typedef LPVOID (WINAPI *VALLOC)(LPVOID lpAddress, DWORD dwSize,
	DWORD flAllocationType, DWORD flProtect);
typedef BOOL (WINAPI *VPROTECT)(LPVOID lpAddress, DWORD dwSize,
	DWORD flNewProtect, PDWORD lpflOldProtect);
typedef BOOL (WINAPI *VFREE)(LPVOID lpAddress, DWORD dwSize,
	DWORD dwFreeType);
typedef HMODULE (WINAPI *LLIB)(LPCTSTR lpLibFileName);
typedef FARPROC (WINAPI *GPADDR)(HMODULE hModule, LPCSTR lpProcName);

FARPROC GetApi(HMODULE hdll, PCHAR fname);
HMODULE __cdecl XLoadLibrary(char *m,
    VALLOC pVirtualAlloc,
    VPROTECT pVirtualProtect,
    VFREE pVirtualFree,
    LLIB pLoadLibrary,
    GPADDR pGetProcAddress
	);

BOOL XFreeLibrary(HMODULE hmod);
typedef BOOL (WINAPI *SLEEP)(DWORD time);
SLEEP pSleep;
int main(int argc, char **argv)
{
	HANDLE hf, hm;
    DWORD d=(DWORD)id2-(DWORD)id1;
	char *m;
	if(argc<2){
		printf("Parameter: DLL name\n");
		return 0;
	}
	hf=CreateFile(argv[1], GENERIC_READ, FILE_SHARE_READ, 
		0, OPEN_EXISTING, 0, 0);
	if(hf==INVALID_HANDLE_VALUE){
		printf("Can not open file\n");
		return 0;
	}
	hm=CreateFileMapping(hf, NULL, PAGE_READONLY, 0, 0, NULL);
	m=(char*)MapViewOfFile(hm, FILE_MAP_READ, 0, 0, 0);
	if(!m)
		return 0;
	USHORT s=*((USHORT*)(m+0x3c));
	if(s>GetFileSize(hf, NULL))
		return 0;
    HMODULE hk=LoadLibrary("kernel32");
    if(hk==NULL)
    	return 0;
	HMODULE hmod=XLoadLibrary(m,
    	(VALLOC)GetProcAddress(hk, "VirtualAlloc"),
    	(VPROTECT)GetProcAddress(hk, "VirtualProtect"),
    	(VFREE)GetProcAddress(hk, "VirtualFree"),
    	(LLIB)GetProcAddress(hk, "LoadLibraryA"),
    	(GPADDR)GetProcAddress(hk, "GetProcAddress")
    );
    if(hmod==NULL)
    	return 0;
    pSleep=(SLEEP)GetProcAddress(hmod, /*"EnumProcessModues");*/"Sleep");
	pSleep=(SLEEP)GetApi(hmod, /*"EnumProcessModues");*/"Sleep");
	if(pSleep)
		BOOL b=pSleep(10000);
	return 0;
}


typedef BOOL (WINAPI *DLLMAIN)(
    HINSTANCE hinstDLL,	// handle to DLL module
    DWORD fdwReason,	// reason for calling function
    LPVOID lpvReserved 	// reserved
   );

#define _memcpy(a,b,s) {__asm pushad;\
	__asm mov ecx, (s);\
	__asm mov edi, offset a;\
	__asm mov esi, offset b;\
	__asm rep movsb;\
	__asm popad;}
#define MIN(a,b) ((a)<(b)?(a):(b))

DWORD GetSectionProtection(DWORD sc);
BOOL IsImportByOrdinal(DWORD ImportDescriptor);
BOOL XFreeLibrary(HMODULE hmod)
{
	return VirtualFree((PVOID)hmod, 0, MEM_RELEASE);
}

void id1() { __emit__( 0xEB,0x02,0xFF,1 ); }

HMODULE __cdecl XLoadLibrary(char *m,
    VALLOC pVirtualAlloc,
    VPROTECT pVirtualProtect,
    VFREE pVirtualFree,
    LLIB pLoadLibrary,
    GPADDR pGetProcAddress
	)
{
	int i;
	IMAGE_OPTIONAL_HEADER *poh;
	IMAGE_FILE_HEADER *pfh;
	IMAGE_SECTION_HEADER *psh;
	USHORT s=*((USHORT*)(m+0x3c));
	pfh=(IMAGE_FILE_HEADER *)(m+s+4);
	DWORD sectnum=pfh->NumberOfSections;
	poh=(IMAGE_OPTIONAL_HEADER *)(m+s+4+sizeof(IMAGE_FILE_HEADER));
	if(poh->Magic!=IMAGE_NT_OPTIONAL_HDR32_MAGIC)
		return 0;
	DWORD ImageSize=poh->SizeOfImage;
	PCHAR ImageBase=(PCHAR)
		pVirtualAlloc((PVOID)poh->ImageBase,ImageSize,MEM_RESERVE,
			PAGE_NOACCESS/*READWRITE*//*NOACCESS*/);
	if(ImageBase==NULL){
		ImageBase=(PCHAR)
			pVirtualAlloc(NULL,ImageSize,MEM_RESERVE,
				PAGE_NOACCESS/*READWRITE*//*NOACCESS*/);
		if(ImageBase==NULL)
			return NULL;
	}
	//copy the header
	PCHAR SectionBase=(PCHAR)pVirtualAlloc(ImageBase,poh->SizeOfHeaders,MEM_COMMIT,
        PAGE_READWRITE);
	//Выделяем часть зарезервированной памяти
    DWORD size=poh->SizeOfHeaders;
    PCHAR from, to;
	_memcpy(SectionBase,m,size);
	DWORD oldprot;
//  pVirtualProtect(SectionBase,poh->SizeOfHeaders,PAGE_READONLY,&oldprot);
	psh=(IMAGE_SECTION_HEADER *)(poh+1);
	for(i=0; i<sectnum//pfh->NumberOfSections
		; i++){
		SectionBase=(PCHAR)pVirtualAlloc(ImageBase+psh[i].VirtualAddress,
			psh[i].Misc.VirtualSize,MEM_COMMIT,PAGE_READWRITE);
		if(SectionBase==NULL){
			pVirtualFree(ImageBase, 0, MEM_RELEASE);
			return NULL;
		}
		SectionBase=ImageBase+psh[i].VirtualAddress;
        size=MIN(psh[i].SizeOfRawData,psh[i].Misc.VirtualSize);
        from=m+psh[i].PointerToRawData;
        to=SectionBase;
		_memcpy(to, from,
			 size);
	}
	// правим адреса
	DWORD ImageBaseDelta=(DWORD)ImageBase-poh->ImageBase;
	if(ImageBaseDelta!=0 && poh->DataDirectory[IMAGE_DIRECTORY_ENTRY_BASERELOC].VirtualAddress!=0){
		IMAGE_BASE_RELOCATION *pbr=(IMAGE_BASE_RELOCATION *)
			(ImageBase+poh->DataDirectory[IMAGE_DIRECTORY_ENTRY_BASERELOC].VirtualAddress),
			*pbr0=pbr;
		WORD *pr;
		DWORD modcount;
		int i;
		while((DWORD)pbr0-(DWORD)pbr<poh->DataDirectory[IMAGE_DIRECTORY_ENTRY_BASERELOC].Size){
			modcount=(pbr0->SizeOfBlock-sizeof(pbr))/2;
			pr=(WORD *)(pbr+1);
			for(i=0; i<modcount; i++, pr++)
				if((*pr & 0xf000) !=0){
					PDWORD pdw=(PDWORD)(ImageBase+pbr0->VirtualAddress+((*pr)&0xfff));
					(*pdw)+=ImageBaseDelta;
				}
			pbr=(IMAGE_BASE_RELOCATION *)pr;
		}

	}
	else if(ImageBaseDelta!=0){
		pVirtualFree(ImageBase, 0, MEM_RELEASE);
		return NULL;
	}

	IMAGE_IMPORT_DESCRIPTOR *pi=(IMAGE_IMPORT_DESCRIPTOR *)(ImageBase+
			poh->DataDirectory[IMAGE_DIRECTORY_ENTRY_IMPORT].VirtualAddress);
	for(;pi->Name!=0;pi++){
		PCHAR plibname=(PCHAR)(ImageBase+pi->Name), pimpname;
		HMODULE hmod=pLoadLibrary(plibname);
		DWORD *pimport, *paddress;
		DWORD ProcAddress;
		paddress=(DWORD *)(ImageBase+pi->/*Original*/FirstThunk);
		if(pi->TimeDateStamp==0)
			pimport=(DWORD *)(ImageBase+pi->FirstThunk);
		else
			pimport=(DWORD *)(ImageBase+pi->OriginalFirstThunk);
		for(i=0; pimport[i]!=0; i++){
			if(IsImportByOrdinal(pimport[i]))	// импорт по номеру
				ProcAddress=(DWORD)pGetProcAddress(hmod, (PCHAR)(pimport[i]&0xFFFF));
			else {						// импорт по имени
				pimpname=(PCHAR)(ImageBase+(pimport[i])+2);
				ProcAddress=(DWORD)pGetProcAddress(hmod, pimpname);
			}
			paddress[i]=ProcAddress;
		}
	}

	// устанавливаем защиты секций
	for(i=0; i<sectnum; i++)
		pVirtualProtect((PVOID)(ImageBase+psh[i].VirtualAddress),
			psh[i].Misc.VirtualSize,
			GetSectionProtection(psh[i].Characteristics),
			&oldprot);


	// вызываем DllMain
	DWORD EntryPoint=poh->AddressOfEntryPoint;
	if(EntryPoint!=0){
		DLLMAIN dllmain=(DLLMAIN)(ImageBase+EntryPoint);
		if(!dllmain((HMODULE)ImageBase, DLL_PROCESS_ATTACH, NULL)){
			pVirtualFree(ImageBase, 0, MEM_RELEASE);
			return NULL;
		}

	}



	return (HMODULE)ImageBase;
}

DWORD GetSectionProtection(DWORD sc)
{
	DWORD result=0;
	if (sc & IMAGE_SCN_MEM_NOT_CACHED)
		result|=PAGE_NOCACHE;
	//Далее E означает Execute(выполнение), R – Read (чтение) и W – Write (запись)
	if (sc & IMAGE_SCN_MEM_EXECUTE)    //E ?
		if (sc & IMAGE_SCN_MEM_READ){  //ER ?
			if (sc & IMAGE_SCN_MEM_WRITE) //ERW ?
				result|=PAGE_EXECUTE_READWRITE;
			else
				result|=PAGE_EXECUTE_READ;
		}
		else {
			if (sc & IMAGE_SCN_MEM_WRITE) //EW?
				result|=PAGE_EXECUTE_WRITECOPY;
			else
				result|=PAGE_EXECUTE;
		}

    else
		if (sc & IMAGE_SCN_MEM_READ){ // R?
			if (sc & IMAGE_SCN_MEM_WRITE) //RW?
				result|=PAGE_READWRITE;
			else
				result|=PAGE_READONLY;
		}
		else {
			if (sc & IMAGE_SCN_MEM_WRITE) //W?
				result|=PAGE_WRITECOPY;
			else
				result|=PAGE_NOACCESS;
		}
	return result;
}

BOOL IsImportByOrdinal(DWORD ImportDescriptor)
{
	return (ImportDescriptor & IMAGE_ORDINAL_FLAG32)!=0;
}

void id2() { __emit__( 0xEB,0x02,0xFF,2 ); }


FARPROC GetApi(HMODULE hdll, PCHAR fname)
{
    PIMAGE_DOS_HEADER pdos;
    PIMAGE_FILE_HEADER pfh;
    PIMAGE_OPTIONAL_HEADER poh;
    PIMAGE_EXPORT_DIRECTORY pexp;
    DWORD exportrva, fn, hash, api;
    PDWORD namesrva, funcrva;
    PWORD ord;
    PDWORD pfunc, pname;
    PCHAR pc, name;
    int i;
	DWORD result;

    pdos=(PIMAGE_DOS_HEADER)hdll;
    i=pdos->e_lfanew;
    pfh=(PIMAGE_FILE_HEADER)(((PCHAR)hdll)+i+4);
    poh=(PIMAGE_OPTIONAL_HEADER)(pfh+1); // immediate after
    exportrva=poh->DataDirectory[IMAGE_DIRECTORY_ENTRY_EXPORT].VirtualAddress;
	pc=(PCHAR)hdll;
    pexp=(PIMAGE_EXPORT_DIRECTORY)(pc+exportrva);
    namesrva=(PDWORD)(pc+pexp->AddressOfNames);
    funcrva=(PDWORD)(pc+pexp->AddressOfFunctions);
    ord=(PWORD)(pc+pexp->AddressOfNameOrdinals);
    fn=pexp->NumberOfNames;
    for(i=0; i<fn; i++){
    	name=((PCHAR)(pc+namesrva[i]));	// addres of function name
		// calculate hash
		/*
        __asm {
        	mov edi, [name]
			mov ecx, [k]
			xor     eax, eax
@@calc_hash:
			rol     eax, 3
			xor     al, byte ptr [edi]
			inc     edi
			loop @@calc_hash
            mov [hash], eax
        }*/
        if(0==lstrcmp(fname, name))//hash==a->_hash)
			return (FARPROC)(pc+funcrva[ord[i]]);
    }
    return NULL;
}

