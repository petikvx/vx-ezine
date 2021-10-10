bool dirlist(char CmdLine[500]);

bool dirlist(char CmdLine[500])
{
	char			Path[MAX_PATH];
	WIN32_FIND_DATA	Win32FindData;
	HANDLE			FindHandle;
	char			FilePoint[3];
	unsigned short	WatchBuffer = 0;

	if(CheckCmdLine(CmdLine, 2) == true)
	{
		lstrcpyn(Path, CmdLine + 10, lstrlen(CmdLine) - 10);

		if(lstrcmp(Path + (lstrlen(Path) - 1), "\\") != 0) lstrcat(Path, "\\");

		lstrcpy(MainBuffer, Path);
		lstrcat(MainBuffer, " contains:\r\n");

		if(SetCurrentDirectory(Path) != 0)
		{
			FindHandle = FindFirstFile("*.*", &Win32FindData);

			if(FindHandle != 0)
			{
				do
				{
					lstrcpyn(FilePoint, Win32FindData.cFileName + (lstrlen(Win32FindData.cFileName) - 4), 2);
					
					if(lstrcmp(FilePoint, ".") != 0 && lstrcmp(Win32FindData.cFileName, ".") != 0 && lstrcmp(Win32FindData.cFileName, "..") != 0)
					{
						lstrcat(MainBuffer, "  ");
						lstrcat(MainBuffer, Win32FindData.cFileName);
						lstrcat(MainBuffer, "\r\n");

						WatchBuffer = WatchBuffer + lstrlen(Win32FindData.cFileName);
						if(WatchBuffer > 1999)
						{
							lstrcpy(MainBuffer, "Not enough space.");
							return true;
						}
					}

				} while(FindNextFile(FindHandle, &Win32FindData) != 0);

				CloseHandle(FindHandle);
				return true;
			}
		}
	}

	return false;
}