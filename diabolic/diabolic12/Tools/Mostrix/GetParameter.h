#include <windows.h>

unsigned short GetParameter(char Command[200], unsigned short CurrentPos);

unsigned short GetParameter(char Command[200], unsigned short CurrentPos)
{
	char			TempChar[2];

	while(lstrcmp(TempChar, "'") != 0)
	{
		lstrcpyn(TempChar, Command + CurrentPos, 2);
		CurrentPos++;
	}

	return CurrentPos;
}