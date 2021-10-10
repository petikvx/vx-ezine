bool getdirectory(void);

bool getdirectory(void)
{
	char	CurrentDir[MAX_PATH];

	if(GetCurrentDirectory(sizeof(CurrentDir), CurrentDir) != 0)
	{
		if(lstrcmp(CurrentDir + (lstrlen(CurrentDir) - 1), "\\") != 0) lstrcat(CurrentDir, "\\");
		lstrcpy(MainBuffer, CurrentDir);
		return true;
	}

	return false;
}