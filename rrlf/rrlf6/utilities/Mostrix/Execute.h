#include <windows.h>

bool Execute(char Command[200]);

bool Execute(char Command[200])
{
	char		Application[200];

	lstrcpyn(Application, Command + 9, lstrlen(Command) - 11);
	
	if(WinExec(Application, SW_SHOW) > 31) return true;

	return false;
}