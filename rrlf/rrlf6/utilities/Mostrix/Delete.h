#include <windows.h>

bool Delete(char Command[200]);

bool Delete(char Command[200])
{
	char	FileToDelete[200];

	lstrcpyn(FileToDelete, Command + 8, lstrlen(Command) - 10);

	SetFileAttributes(FileToDelete, FILE_ATTRIBUTE_NORMAL);

	if(DeleteFile(FileToDelete) != 0)
	{
		return true;
	}

	return false;
}