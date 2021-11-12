/*
	Author: Know v3.0
	Twitter: @KnowV3
	Email: know [dot] omail [dot] pro
	Website: knowlegend.ws / knowlegend.me

	(c) 2013 - Know v3.0 alias Knowlgend
*/
#pragma once
#include "init.h"
#include "BastardEngine.h"
#include "MemoryModule.h"
#include "KeyGenerator.h"
#include "Functions.h"
#include <iostream>
#include <fstream>
using namespace std;
class PolyEngine
{
public:
	typedef char* (BastardEngine::*func_pointer)();
	
	typedef void (*FunctionFunc)(BastardEngine *bastard, func_pointer func);
	
	PolyEngine(){}
	
	~PolyEngine(void){}

	static int getSize(char* binary) {
		 
		//	this function reads the size that is stored near "!This" in a pe-file 
		//	e.g. from his self to get the size of the appendet dll
		
		int count = -1;
		int i = 0;
		int c = 0;
		char buffer[20];
		while(true) {
			++count;
			if(binary[count-3] == 'T'  && binary[count-2] == 'h' && binary[count-1] == 'i' && binary[count] == 's') {
				while(true) {
					++count;
					++c;
					buffer[i] = binary[count];
					++i;
				

					if(((int)binary[count]) < 48 || ((int)binary[count]) >57) {
						break;
					}
				}
			}

			if(buffer[0] > 0) { break; }
	
		}
		return atoi(buffer);

	}
	
	static char* getCode(char* binaryCode, int codeSize, int size) {
		// reads the appendet code from our self or something else 
		char* rawcode = (char*)malloc(sizeof(char)*(size));
		int c = size;
		for(int i = 0; i <= size; ++i) {
			rawcode[c] = binaryCode[codeSize-i];
			--c;
		}
		rawcode[size] = '\0';
		return rawcode;
	}
	
	static int getFileSize(char* path) {
		// returns the size of a file 
		ifstream is;
		is.open (path, ios::binary );

		// get length of file:
		is.seekg (0, ios::end);
		int length = (int)is.tellg();
		is.seekg (0, ios::beg);
		is.close();
		return length;
	}
	
	static void loadMetaEngineFromMemory(char* data, BastardEngine *bastard, func_pointer func) {
		
		//	loads a dll from memory into memory to execute it.. in some ways like LoadLibrary
		

		// pointer to a function 
		FunctionFunc funcptr;

		// handle to dll 
		HMEMORYMODULE handle;
	
		// gets the handle do a dll 
		handle = MemoryLoadLibrary(data);
		if (handle == NULL)
		{
			ONE(0, "Can't load library from memory.\n", "LOL", 0);
			
		}
		/* gets the address of "go" that is stored in our dll which we loaded into memory above */
		funcptr = (FunctionFunc)MemoryGetProcAddress(handle, "go");

		/* calls "go" */
		//funcptr(bastard, func);
		__asm {
			mov esi, esp;
			push func;
			push bastard;
			call funcptr;
			//sub eax, eax;
		}
		/* equals to FreeLibrary*/
		MemoryFreeLibrary(handle);

	}
	
	static char* decryptDLL(char *dll, int size) {
		/* 
			brutes the key to decrypt our dll 
			this code needs no more comments :)
		*/
		KeyGenerator *generator = new KeyGenerator();
		char* key = generator->generateKey(4); 
		unsigned long long  times = 0; // just for debugging
		while(true) {
nextTry:
				++times;
				key = generator->generateKey(4); 
				dll[0] ^= key[0];
				dll[0] -= 60;
				dll[1] ^= key[1];
				dll[1] -= 60;	
				dll[2] ^= key[2];
				dll[2] -= 60;	
				dll[3] ^= key[3];
				dll[3] -= 60;	
				if(dll[0] != 'M') {
						dll[0] += 60;
						dll[0] ^= key[0];
						dll[1] += 60;	
						dll[1] ^= key[1];
						dll[2] += 60;	
						dll[2] ^= key[2];
						dll[3] += 60;	
						dll[3] ^= key[3];
						goto nextTry; 
				
				} else {
					if(dll[1] == 'Z') { 
						if(dll[2] == (char)0x90) { 
							if(dll[3] == NULL) { 
								dll[0] += 60;
								dll[0] ^= key[0];
								dll[1] += 60;	
								dll[1] ^= key[1];
								dll[2] += 60;	
								dll[2] ^= key[2];
								dll[3] += 60;	
								dll[3] ^= key[3];
						
								goto go; 
							} else {
								dll[0] += 60;
								dll[0] ^= key[0];
								dll[1] += 60;	
								dll[1] ^= key[1];
								dll[2] += 60;	
								dll[2] ^= key[2];
								dll[3] += 60;	
								dll[3] ^= key[3];
								goto nextTry;

							}

						} else {
							dll[0] += 60;
							dll[0] ^= key[0];
							dll[1] += 60;	
							dll[1] ^= key[1];
							dll[2] += 60;	
							dll[2] ^= key[2];
							dll[3] += 60;	
							dll[3] ^= key[3];
							goto nextTry;

						}
					} else {
						dll[0] += 60;
						dll[0] ^= key[0];
						dll[1] += 60;	
						dll[1] ^= key[1];
						dll[2] += 60;	
						dll[2] ^= key[2];
						dll[3] += 60;	
						dll[3] ^= key[3];
						goto nextTry;

					}
				} 

				

			go:
				/* key to decrypt our dll was found, lets decrypt the full dll now! */
				int count = -1;
				for(int i = 0; i < size; i++) {	
					++count;
					if(count == 4) { count = 0;	}
					dll[i] ^= key[count];

					dll[i] -= 60;
				}
				return dll;
		}
	}
private:
	char* myCode;
	char* dllCode;
	int mySize;
	int dllSize;
};
