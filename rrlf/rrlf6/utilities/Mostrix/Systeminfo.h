#include <windows.h>
#include <winbase.h>

bool SystemInfo(char Command[200]);

bool SystemInfo(char Command[200])
{
	char	TempBuffer [MAX_PATH];
	char	MainBuffer [MAX_PATH * 3];
	DWORD	ComputerNameLength = 55;

	char	SaveFile[200];
	HANDLE	SaveFileHandle;
	DWORD	BytesWritten;

	lstrcpy(MainBuffer, "Computer Name:\t\t");
	GetComputerName(TempBuffer, &ComputerNameLength);
	lstrcat(MainBuffer, TempBuffer);
	lstrcat(MainBuffer, "\r\n");

	lstrcat(MainBuffer, "Windows Directory:\t");
	GetWindowsDirectory(TempBuffer, sizeof(TempBuffer));
	lstrcat(MainBuffer, TempBuffer);
	lstrcat(MainBuffer, "\r\n");

	lstrcat(MainBuffer, "System Directory:\t");
	GetSystemDirectory(TempBuffer, sizeof(TempBuffer));
	lstrcat(MainBuffer, TempBuffer);
	lstrcat(MainBuffer, "\r\n");

	lstrcat(MainBuffer, "Mostrix Directory:\t");
	GetCurrentDirectory(sizeof(TempBuffer), TempBuffer);
	lstrcat(MainBuffer, TempBuffer);
	lstrcat(MainBuffer, "\r\n");

	//continue...

	lstrcpyn(SaveFile, Command + 12, lstrlen(Command) - 14);

	SaveFileHandle = CreateFile(SaveFile, GENERIC_WRITE, FILE_SHARE_WRITE, 0, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);

	if(SaveFileHandle != INVALID_HANDLE_VALUE)
	{
		if(WriteFile(SaveFileHandle, MainBuffer, lstrlen(MainBuffer), &BytesWritten, 0) != 0)
		{
			CloseHandle(SaveFileHandle);
			return true;
		}

		CloseHandle(SaveFileHandle);
	}

	return false;
}