bool reboot(void);

bool reboot(void)
{
	if(ExitWindowsEx(EWX_REBOOT, 0) != 0)
	{
		lstrcpy(MainBuffer, "Reboot... (you can close the client)");
		return true;
	}

	return false;
}