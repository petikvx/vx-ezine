/*
	Author: Know v3.0
	Twitter: @KnowV3
	Email: know [dot] omail [dot] pro
	Website: knowlegend.ws / knowlegend.me

	(c) 2013 - Know v3.0 alias Knowlgend
*/
#include "init.h"
#include "BastardEngine.h"

int __stdcall WinMain (HINSTANCE hThisInstance, HINSTANCE hPrevInstance, char* lpszArgument, int nCmdShow) {
	BastardEngine *engine = new BastardEngine();
	engine->go();
}
