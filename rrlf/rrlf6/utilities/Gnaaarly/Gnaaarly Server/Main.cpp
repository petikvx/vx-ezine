//Winsock example - remote control :: Server
//(c)2005 by Sebastian Senf

#include <small.h>
#include <windows.h>

char MainBuffer[2000];

#include "Server.h"

int main()
{
	if(MessageBox(0, "Start server?", "winsock example - remote control", MB_YESNO + MB_ICONQUESTION) == IDYES)
	{
		if(StartServer() == false)
		{
			MessageBox(0, "Cannot start server", "error", MB_ICONERROR);
		}
	}

	return 0;
}