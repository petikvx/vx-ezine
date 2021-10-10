bool location(void);

bool location(void)
{
	char			Server[MAX_PATH];

	if(GetModuleFileName(0, Server, sizeof(Server)) != 0)
	{
		lstrcpy(MainBuffer, Server);
		return true;
	}

	return false;
}