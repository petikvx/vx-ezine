bool windowspath(void);

bool windowspath(void)
{
	char	WinDir[MAX_PATH];

	if(GetWindowsDirectory(WinDir, sizeof(WinDir)) != 0)
	{
		lstrcpy(MainBuffer, WinDir);
		lstrcat(MainBuffer, "\\");
		return true;
	}

	return false;
}