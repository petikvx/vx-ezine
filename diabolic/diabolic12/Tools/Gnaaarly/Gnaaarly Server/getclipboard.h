bool getclipboard(void);

bool getclipboard(void)
{
	char	*ClipData;

	if(OpenClipboard(0) != 0)
	{
		ClipData = (char *)GetClipboardData(CF_TEXT);

		if(ClipData != 0)
		{
			lstrcpy(MainBuffer, ClipData);
			return true;
		}
	}

	return false;
}