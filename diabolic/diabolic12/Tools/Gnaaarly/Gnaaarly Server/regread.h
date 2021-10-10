#include <winreg.h>

bool regread(char CmdLine[500]);

bool regread(char CmdLine[500])
{
	char			HKEYName[50];
	char			Subkey[200];
	char			ValueName[250];
	char			TempChar[3];
	unsigned short	StringPos ;
	unsigned short	CharCount;

	HKEY			HKEY_Name = 0;
	HKEY			RegHandle;
	char			Value[MAX_PATH];
	DWORD			ValueSize = sizeof(Value);

	if(CheckCmdLine(CmdLine, 6) == true)
	{
		lstrcpyn(HKEYName, "", sizeof(HKEYName));
		lstrcpyn(Subkey, "", sizeof(Subkey));
		lstrcpyn(Value, "", sizeof(Value));
		lstrcpy(TempChar, "x");
		StringPos = 10;
		CharCount = 0;

		while(lstrcmp(TempChar, "'") != 0)
		{
			lstrcpyn((char *)&HKEYName[CharCount], CmdLine + StringPos, 2);
			lstrcpyn(TempChar, (char *)&HKEYName[CharCount], 2);
			StringPos++;
			CharCount++;
		}

		lstrcpy((char *)&HKEYName[CharCount - 1], "");
		lstrcpy(TempChar, "x");

		CharCount = 0;
		StringPos = StringPos + 2;

		while(lstrcmp(TempChar, "'") != 0)
		{
			lstrcpyn((char *)&Subkey[CharCount], CmdLine + StringPos, 2);
			lstrcpyn(TempChar, (char *)&Subkey[CharCount], 2);
			StringPos++;
			CharCount++;
		}

		lstrcpy((char *)&Subkey[CharCount - 1], "");
		lstrcpy(TempChar, "x");

		CharCount = 0;
		StringPos = StringPos + 2;

		while(lstrcmp(TempChar, "'") != 0)
		{
			lstrcpyn((char *)&ValueName[CharCount], CmdLine + StringPos, 2);
			lstrcpyn(TempChar, (char *)&ValueName[CharCount], 2);
			StringPos++;
			CharCount++;
		}

		lstrcpy((char *)&ValueName[CharCount - 1], "");

		if(lstrcmp(HKEYName, "HKEY_CLASSES_ROOT") == 0)		HKEY_Name = HKEY_CLASSES_ROOT;
		if(lstrcmp(HKEYName, "HKEY_CURRENT_USER") == 0)		HKEY_Name = HKEY_CURRENT_USER;
		if(lstrcmp(HKEYName, "HKEY_LOCAL_MACHINE") == 0)	HKEY_Name = HKEY_LOCAL_MACHINE;
		if(lstrcmp(HKEYName, "HKEY_USERS") == 0)			HKEY_Name = HKEY_USERS;

		if(RegOpenKeyEx(HKEY_Name, Subkey, 0, KEY_QUERY_VALUE, &RegHandle) == ERROR_SUCCESS)
		{
			if(RegQueryValueEx(RegHandle, ValueName, 0, 0, (BYTE *)Value, &ValueSize) == ERROR_SUCCESS)
			{
				RegCloseKey(RegHandle);
				lstrcpy(MainBuffer, Value);
				return true;
			}
		}
	}

	return false;
}