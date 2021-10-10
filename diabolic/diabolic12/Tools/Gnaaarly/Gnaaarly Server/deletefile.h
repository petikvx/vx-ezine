bool deletefile(char CmdLine[500]);

bool deletefile(char CmdLine[500])
{
	char			ExistingFile[MAX_PATH];

	if(CheckCmdLine(CmdLine, 2) == true)
	{
		lstrcpyn(ExistingFile, CmdLine + 13, lstrlen(CmdLine) - 13);
	
		SetFileAttributes(ExistingFile, FILE_ATTRIBUTE_NORMAL);

		if(DeleteFile(ExistingFile) != 0)
		{
			lstrcpy(MainBuffer, "Deleted.");
			return true;
		}
	}

	return false;
}