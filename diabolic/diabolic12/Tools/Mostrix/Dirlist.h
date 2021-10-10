#include <windows.h>

bool Dirlist(char Command[200]);

bool Dirlist(char Command[200])
{
	unsigned short	DirToListStart = 9;
	unsigned short	DirToListEnd;
	char			DirToList[100];

	unsigned short	SaveFileStart;
	unsigned short	SaveFileEnd;
	char			SaveFile[100];

	HANDLE			FileHandle;
	DWORD			BytesWritten;
	char			Contains[] = " cotains:\r\n";

	HANDLE			FindHandle;
	WIN32_FIND_DATA Win32FindData;
	char			FilePoint[2];

	char			Space[] = "   ";
	char			Break[] = "\r\n";

	DirToListEnd = GetParameter(Command, DirToListStart);
	lstrcpyn(DirToList, Command + DirToListStart, DirToListEnd - DirToListStart);
	if(lstrcmp(DirToList + (lstrlen(DirToList) - 1), "\\") != 0) lstrcat(DirToList, "\\");

	SaveFileStart = DirToListEnd + 2;
	SaveFileEnd = GetParameter(Command, SaveFileStart);
	lstrcpyn(SaveFile, Command + SaveFileStart, SaveFileEnd - SaveFileStart);

	FileHandle = CreateFile(SaveFile, GENERIC_WRITE, FILE_SHARE_WRITE, 0, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);

	if(FileHandle != INVALID_HANDLE_VALUE)
	{
		if(SetCurrentDirectory(DirToList) != 0)
		{
			WriteFile(FileHandle, DirToList, lstrlen(DirToList), &BytesWritten, 0);
			WriteFile(FileHandle, Contains, lstrlen(Contains), &BytesWritten, 0);

			FindHandle = FindFirstFile("*.*", &Win32FindData);

			if(FindHandle != 0)
			{
				do
				{
					lstrcpyn(FilePoint, Win32FindData.cFileName + (lstrlen(Win32FindData.cFileName) - 4), 2);

					if(lstrcmp(FilePoint, ".") != 0 && lstrcmp(Win32FindData.cFileName, ".") != 0 && lstrcmp(Win32FindData.cFileName, "..") != 0)
					{
						WriteFile(FileHandle, Space, lstrlen(Space), &BytesWritten, 0);
						WriteFile(FileHandle, Win32FindData.cFileName, lstrlen(Win32FindData.cFileName), &BytesWritten, 0);
						WriteFile(FileHandle, Break, lstrlen(Break), &BytesWritten, 0);
					}
				} while(FindNextFile(FindHandle, &Win32FindData) != 0);

				CloseHandle(FindHandle);
				CloseHandle(FileHandle);
				return true;
			}

			CloseHandle(FileHandle);
		}
	}

	return false;
}
	

