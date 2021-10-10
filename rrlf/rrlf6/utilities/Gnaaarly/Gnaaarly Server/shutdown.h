bool shutdown(void);

bool shutdown(void)
{
	if(ExitWindowsEx(EWX_SHUTDOWN, 0) != 0)
	{
		lstrcpy(MainBuffer, "Shutdown... (you can close the client)");
		return true;
	}

	return false;
}