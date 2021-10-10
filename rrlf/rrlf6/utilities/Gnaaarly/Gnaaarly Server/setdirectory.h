bool setdirectory(char CmdLine[500]);

bool setdirectory(char CmdLine[500])
{
	char	Path[MAX_PATH];

	if(CheckCmdLine(CmdLine, 2) == true)
	{
		lstrcpyn(Path, CmdLine + 15, lstrlen(CmdLine) - 15);

		if(lstrcmp(Path + (lstrlen(Path) - 1), "\\") != 0) lstrcat(Path, "\\");

		if(SetCurrentDirectory(Path) != 0)
		{
			lstrcpy(MainBuffer, "Directory changed.");
			return true;
		}
	}

	return false;
}