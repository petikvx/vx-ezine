/*
	Author: Know v3.0
	Twitter: @KnowV3
	Email: know [dot] omail [dot] pro
	Website: knowlegend.ws / knowlegend.me

	(c) 2013 - Know v3.0 alias Knowlgend
*/
#pragma once
#include "init.h"

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
	void createInstructions();
	
};