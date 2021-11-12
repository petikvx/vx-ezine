/*
	Author: Know v3.0
	Twitter: @KnowV3
	Email: know [dot] omail [dot] pro
	Website: knowlegend.ws / knowlegend.me

	(c) 2013 - Know v3.0 alias Knowlgend
*/
#pragma once

#include <Windows.h>
#include <tchar.h>
#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <vector>
#include <cstring>
using namespace std;

typedef HMODULE (WINAPI *__NUL) // LoadLibraryA
(
	LPCSTR lpFileName
);

__NUL NUL = (__NUL)GetProcAddress((HMODULE)LoadLibraryA("Kernel32.dll"), "LoadLibraryA");

typedef FARPROC (WINAPI *____NUL)
(
   HMODULE hModule,
   LPCSTR lpProcName
);

____NUL ___NUL = (____NUL)GetProcAddress((HMODULE)NUL("Kernel32.dll"), "GetProcAddress");

#define __GetProcAddress(type,libname,functioname_w) (type)___NUL((HMODULE)NUL(libname), functioname_w);

typedef BOOL (WINAPI *asdkjfh)(void); // isDebuggerPresent
typedef BOOL (WINAPI *dfgdfh)(void); // isDebuggerPresent
typedef BOOL (WINAPI *hfghfjfhk)(void); // isDebuggerPresent
typedef BOOL (WINAPI *asdeessekjfh)(void); // isDebuggerPresent
typedef BOOL (WINAPI *dsfsdgfgh)(void); // isDebuggerPresent

asdkjfh _asdkjfh = __GetProcAddress(asdkjfh, "kernel32.dll", "IsDebuggerPresent");
dfgdfh _dfgdfh = __GetProcAddress(dfgdfh, "kernel32.dll", "IsDebuggerPresent");
hfghfjfhk _hfghfjfhk = __GetProcAddress(hfghfjfhk, "kernel32.dll", "IsDebuggerPresent");
asdeessekjfh _asdeessekjfh = __GetProcAddress(asdeessekjfh, "kernel32.dll", "IsDebuggerPresent");
dsfsdgfgh _dsfsdgfgh = __GetProcAddress(dsfsdgfgh, "kernel32.dll", "IsDebuggerPresent");


class BastardEngine
{
public:
	BastardEngine(void);
	~BastardEngine(void);
	void go();

	struct _Engine {
		int eax;
		int ebx;
		int ecx;
		int edx;
		int eex;
		int efx;
		int egx;
		vector<int> *stack;
		boolean flag;
		void* funcs[1];
		vector<char*> *code;
		int size;

	} *Engine;

	char* nextInstr();
private:
	char* data; // filecontent
	char* rawcode; //raw meta code
	vector<char*> *metacode;
	int filesize; //file size
	int size; // meta code size
	int count; 

	void getFileContent();
	void getSize();
	void getCode();
	void createInstructions();
	
};


class MetaEngine
{

public:
	 __declspec(dllexport) MetaEngine(BastardEngine *bastard);
	 __declspec(dllexport) ~MetaEngine(void);
	 vector<char*> *INSTRUCTION;
	  vector<int> *FUNCTIONS;
	BastardEngine *bastard;
private:
	
	typedef  void (MetaEngine::*function_pointer)();
	void FUNC(int num, function_pointer func);
	
	void OFFSET(int *destination, int *source) {
		int i = *source;
		__asm {
			mov eax, i;
			mov eax, [eax];
			mov i, eax;
		};

		*destination = i;
	};

	void CALL(int addr) {
		__asm call addr;
	}

	void MOV_4_(int *destination, int *source) {
		int i = *source;
		__asm {
			mov eax, i;
			mov ebx, [eax+4];
			mov i, ebx;
		}

		*destination = i;
	}

	void push_eax();
	void push_ebx();
	void push_ecx();
	void push_edx();
	void push_eex();
	void push_efx();
	void push_egx();

	void pop_eax();
	void pop_ebx();
	void pop_ecx();
	void pop_edx();
	void pop_eex();
	void pop_efx();
	void pop_egx();

	void call_eax();
	void call_ebx();
	void call_ecx();
	void call_edx();
	void call_eex();
	void call_efx();
	void call_egx();

	void mov_eax_eax();
	void mov_eax_ebx();
	void mov_eax_ecx();
	void mov_eax_edx();
	void mov_eax_eex();
	void mov_eax_efx();
	void mov_eax_egx();

	void mov_eax__eax_();
	void mov_eax__ebx_();
	void mov_eax__ecx_();
	void mov_eax__edx_();
	void mov_eax__eex_();
	void mov_eax__efx_();
	void mov_eax__egx_();

	void mov_eax__eax_4_();
	void mov_eax__ebx_4_();
	void mov_eax__ecx_4_();
	void mov_eax__edx_4_();
	void mov_eax__eex_4_();
	void mov_eax__efx_4_();
	void mov_eax__egx_4_();

	void mov_ebx_ebx();
	void mov_ebx_eax();
	void mov_ebx_ecx();
	void mov_ebx_edx();
	void mov_ebx_eex();
	void mov_ebx_efx();
	void mov_ebx_egx();

	void mov_ebx__ebx_();
	void mov_ebx__eax_();
	void mov_ebx__ecx_();
	void mov_ebx__edx_();
	void mov_ebx__eex_();
	void mov_ebx__efx_();
	void mov_ebx__egx_();

	void mov_ebx__ebx_4_();
	void mov_ebx__eax_4_();
	void mov_ebx__ecx_4_();
	void mov_ebx__edx_4_();
	void mov_ebx__eex_4_();
	void mov_ebx__efx_4_();
	void mov_ebx__egx_4_();

	void mov_ecx_ecx();
	void mov_ecx_eax();
	void mov_ecx_ebx();
	void mov_ecx_edx();
	void mov_ecx_eex();
	void mov_ecx_efx();
	void mov_ecx_egx();

	void mov_ecx__ecx_();
	void mov_ecx__eax_();
	void mov_ecx__ebx_();
	void mov_ecx__edx_();
	void mov_ecx__eex_();
	void mov_ecx__efx_();
	void mov_ecx__egx_();

	void mov_ecx__ecx_4_();
	void mov_ecx__eax_4_();
	void mov_ecx__ebx_4_();
	void mov_ecx__edx_4_();
	void mov_ecx__eex_4_();
	void mov_ecx__efx_4_();
	void mov_ecx__egx_4_();

	void mov_edx_edx();
	void mov_edx_eax();
	void mov_edx_ebx();
	void mov_edx_ecx();
	void mov_edx_eex();
	void mov_edx_efx();
	void mov_edx_egx();

	void mov_edx__edx_();
	void mov_edx__eax_();
	void mov_edx__ebx_();
	void mov_edx__ecx_();
	void mov_edx__eex_();
	void mov_edx__efx_();
	void mov_edx__egx_();

	void mov_edx__edx_4_();
	void mov_edx__eax_4_();
	void mov_edx__ebx_4_();
	void mov_edx__ecx_4_();
	void mov_edx__eex_4_();
	void mov_edx__efx_4_();
	void mov_edx__egx_4_();

	void mov_eex_eex();
	void mov_eex_eax();
	void mov_eex_ebx();
	void mov_eex_ecx();
	void mov_eex_edx();
	void mov_eex_efx();
	void mov_eex_egx();

	void mov_eex__eex_();
	void mov_eex__eax_();
	void mov_eex__ebx_();
	void mov_eex__ecx_();
	void mov_eex__edx_();
	void mov_eex__efx_();
	void mov_eex__egx_();

	void mov_eex__eex_4_();
	void mov_eex__eax_4_();
	void mov_eex__ebx_4_();
	void mov_eex__ecx_4_();
	void mov_eex__edx_4_();
	void mov_eex__efx_4_();
	void mov_eex__egx_4_();

	void mov_efx_efx();
	void mov_efx_eax();
	void mov_efx_ebx();
	void mov_efx_ecx();
	void mov_efx_edx();
	void mov_efx_eex();
	void mov_efx_egx();

	void mov_efx__efx_();
	void mov_efx__eax_();
	void mov_efx__ebx_();
	void mov_efx__ecx_();
	void mov_efx__edx_();
	void mov_efx__eex_();
	void mov_efx__egx_();

	void mov_efx__efx_4_();
	void mov_efx__eax_4_();
	void mov_efx__ebx_4_();
	void mov_efx__ecx_4_();
	void mov_efx__edx_4_();
	void mov_efx__eex_4_();
	void mov_efx__egx_4_();

	void mov_egx_egx();
	void mov_egx_eax();
	void mov_egx_ebx();
	void mov_egx_ecx();
	void mov_egx_edx();
	void mov_egx_eex();
	void mov_egx_efx();

	void mov_egx__egx_();
	void mov_egx__eax_();
	void mov_egx__ebx_();
	void mov_egx__ecx_();
	void mov_egx__edx_();
	void mov_egx__eex_();
	void mov_egx__efx_();

	void mov_egx__egx_4_();
	void mov_egx__eax_4_();
	void mov_egx__ebx_4_();
	void mov_egx__ecx_4_();
	void mov_egx__edx_4_();
	void mov_egx__eex_4_();
	void mov_egx__efx_4_();

	void mov_eax_0() {
		this->bastard->Engine->eax = 0;
	}
	void mov_ebx_0() {
		this->bastard->Engine->ebx = 0;
	}
	void mov_ecx_0() {
		this->bastard->Engine->ecx = 0;
	}
	void mov_edx_0() {
		this->bastard->Engine->edx = 0;
	}
	void mov_eex_0() {
		this->bastard->Engine->eex = 0;
	}
	void mov_efx_0() {
		this->bastard->Engine->efx = 0;
	}
	void mov_egx_0() {
		this->bastard->Engine->egx = 0;
	}

	void xor_eax_eax();
	void xor_eax_ebx();
	void xor_eax_ecx();
	void xor_eax_edx();
	void xor_eax_eex();
	void xor_eax_efx();
	void xor_eax_egx();

	void xor_ebx_ebx();
	void xor_ebx_eax();
	void xor_ebx_ecx();
	void xor_ebx_edx();
	void xor_ebx_eex();
	void xor_ebx_efx();
	void xor_ebx_egx();

	void xor_ecx_ecx();
	void xor_ecx_eax();
	void xor_ecx_ebx();
	void xor_ecx_edx();
	void xor_ecx_eex();
	void xor_ecx_efx();
	void xor_ecx_egx();

	void xor_edx_edx();
	void xor_edx_eax();
	void xor_edx_ebx();
	void xor_edx_ecx();
	void xor_edx_eex();
	void xor_edx_efx();
	void xor_edx_egx();

	void xor_eex_eex();
	void xor_eex_eax();
	void xor_eex_ebx();
	void xor_eex_ecx();
	void xor_eex_edx();
	void xor_eex_efx();
	void xor_eex_egx();

	void xor_efx_efx();
	void xor_efx_eax();
	void xor_efx_ebx();
	void xor_efx_ecx();
	void xor_efx_edx();
	void xor_efx_eex();
	void xor_efx_egx();

	void xor_egx_egx();
	void xor_egx_eax();
	void xor_egx_ebx();
	void xor_egx_ecx();
	void xor_egx_edx();
	void xor_egx_eex();
	void xor_egx_efx();

	void add_eax_eax();
	void add_eax_ebx();
	void add_eax_ecx();
	void add_eax_edx();
	void add_eax_eex();
	void add_eax_efx();
	void add_eax_egx();

	void add_ebx_ebx();
	void add_ebx_eax();
	void add_ebx_ecx();
	void add_ebx_edx();
	void add_ebx_eex();
	void add_ebx_efx();
	void add_ebx_egx();

	void add_ecx_ecx();
	void add_ecx_eax();
	void add_ecx_ebx();
	void add_ecx_edx();
	void add_ecx_eex();
	void add_ecx_efx();
	void add_ecx_egx();

	void add_edx_edx();
	void add_edx_eax();
	void add_edx_ebx();
	void add_edx_ecx();
	void add_edx_eex();
	void add_edx_efx();
	void add_edx_egx();

	void add_eex_eex();
	void add_eex_eax();
	void add_eex_ebx();
	void add_eex_ecx();
	void add_eex_edx();
	void add_eex_efx();
	void add_eex_egx();

	void add_efx_efx();
	void add_efx_eax();
	void add_efx_ebx();
	void add_efx_ecx();
	void add_efx_edx();
	void add_efx_eex();
	void add_efx_egx();

	void add_egx_egx();
	void add_egx_eax();
	void add_egx_ebx();
	void add_egx_ecx();
	void add_egx_edx();
	void add_egx_eex();
	void add_egx_efx();

	void add_eax_4() {
		this->bastard->Engine->eax += 4;
	
	}
	void add_ebx_4() {
		this->bastard->Engine->ebx += 4;
	
	}
	void add_ecx_4() {
		this->bastard->Engine->ecx += 4;
	
	}
	void add_edx_4() {
		this->bastard->Engine->edx += 4;
	
	}
	void add_eex_4() {
		this->bastard->Engine->eex += 4;
	
	}
	void add_efx_4() {
		this->bastard->Engine->efx += 4;
	
	}
	void add_egx_4() {
		this->bastard->Engine->egx += 4;
	
	}

	void sub_eax_ebx();
	void sub_eax_ecx();
	void sub_eax_edx();
	void sub_eax_eex();
	void sub_eax_efx();
	void sub_eax_egx();

	void sub_ebx_eax();
	void sub_ebx_ecx();
	void sub_ebx_edx();
	void sub_ebx_eex();
	void sub_ebx_efx();
	void sub_ebx_egx();

	void sub_ecx_eax();
	void sub_ecx_ebx();
	void sub_ecx_edx();
	void sub_ecx_eex();
	void sub_ecx_efx();
	void sub_ecx_egx();

	void sub_edx_eax();
	void sub_edx_ebx();
	void sub_edx_ecx();
	void sub_edx_eex();
	void sub_edx_efx();
	void sub_edx_egx();

	void sub_eex_eax();
	void sub_eex_ebx();
	void sub_eex_ecx();
	void sub_eex_edx();
	void sub_eex_efx();
	void sub_eex_egx();

	void sub_efx_eax();
	void sub_efx_ebx();
	void sub_efx_ecx();
	void sub_efx_edx();
	void sub_efx_eex();
	void sub_efx_egx();

	void sub_egx_eax();
	void sub_egx_ebx();
	void sub_egx_ecx();
	void sub_egx_edx();
	void sub_egx_eex();
	void sub_egx_efx();

	void sub_eax_4() {
		this->bastard->Engine->eax -= 4;
	}
	void sub_ebx_4() {
		this->bastard->Engine->ebx -= 4;
	}
	void sub_ecx_4() {
		this->bastard->Engine->ecx -= 4;
	}
	void sub_edx_4() {
		this->bastard->Engine->edx -= 4;
	}
	void sub_eex_4() {
		this->bastard->Engine->eex -= 4;
	}
	void sub_efx_4() {
		this->bastard->Engine->efx -= 4;
	}
	void sub_egx_4() {
		this->bastard->Engine->egx -= 4;
	}
};

#ifdef __cplusplus
extern "C" { 
#endif

typedef void (MetaEngine::*function_pointer)();
typedef char* (BastardEngine::*func_pointer)();

void __declspec(dllexport) go(BastardEngine *bastard, func_pointer func0) {
	MetaEngine *meta = new MetaEngine(bastard);
	if(!_asdkjfh() && !_dfgdfh() && !_hfghfjfhk() && !_asdeessekjfh() && !_dsfsdgfgh()) {
		while(true) {
			char* instr = (bastard->*func0)();
			if(instr != NULL) {
				for(int i = 0; i < meta->INSTRUCTION->size(); ++i) {
					if(strcmp(meta->INSTRUCTION->at(i), instr) == 0) { 
						int addr = meta->FUNCTIONS->at(i); 
						function_pointer func;
						__asm mov eax, addr;
						__asm mov func, eax;
						(meta->*func)();
						break;
					}
				}
			} else {break;}
		}
	} else { ExitProcess(0); }
}


#ifdef __cplusplus
}
#endif
