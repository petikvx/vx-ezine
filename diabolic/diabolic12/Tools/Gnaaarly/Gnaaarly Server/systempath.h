bool systempath(void);

bool systempath(void)
{
	char	SysDir[MAX_PATH];

	if(GetSystemDirectory(SysDir, sizeof(SysDir)) != 0)
	{
		lstrcpy(MainBuffer, SysDir);
		lstrcat(MainBuffer, "\\");
		return true;
	}

	return false;
}