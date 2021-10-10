#include <windows.h>

bool CheckPrivMsg(char LineToCheck[200]);

bool CheckPrivMsg(char LineToCheck[200])
{
	unsigned short	Position = 0;
	char			TempChar[2];

	while(lstrcmp(TempChar, "\n") != 0)
	{
		lstrcpyn(TempChar, LineToCheck + Position, 2);

		if(lstrcmp(TempChar, "#") == 0)
		{
			return false;
		}

		Position++;
	}

	return true;
}