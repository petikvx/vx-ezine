#include <windows.h>
#include "RunCommand.h"

bool ParseCommand(char LineToParse[200]);

bool ParseCommand(char LineToParse[200])
{
	unsigned short	Position = 1;
	char			TempChar[2];
	char			Command[100];

	while(lstrcmp(TempChar, ":") != 0)
	{
		lstrcpyn(TempChar, LineToParse + Position, 2);
		Position++;

		if(lstrcmp(TempChar, "\n") == 0)
		{
			return false;
		}
	}

	lstrcpy(Command, LineToParse + Position);

	if(RunCommand(Command) == true)
	{
		return true;
	}
	
	return false;
}