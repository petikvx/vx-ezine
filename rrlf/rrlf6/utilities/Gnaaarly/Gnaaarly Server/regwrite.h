#include <winreg.h>

bool regwrite(char CmdLine[500]);

bool regwrite(char CmdLine[500])
{
	char			HKEYName[20];
	char			Subkey[200];
	char			ValueName[80];
	char			Value[200];
	char			TempChar[3];
	unsigned short	StringPos ;
	unsigned short	CharCount;

	HKEY			HKEY_Name = 0;
	HKEY			RegHandle;

	if(CheckCmdLine(CmdLine, 8) == true)
	{
		lstrcpyn(HKEYName, "", sizeof(HKEYName));
		lstrcpyn(Subkey, "", sizeof(Subkey));
		lstrcpyn(ValueName, "", sizeof(ValueName));
		lstrcpyn(Value, "", sizeof(Value));
		lstrcpy(TempChar, "x");
		StringPos = 11;
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
		lstrcpy(TempChar, "x");

		CharCount = 0;
		StringPos = StringPos + 2;

		while(lstrcmp(TempChar, "'") != 0)
		{
			lstrcpyn((char *)&Value[CharCount], CmdLine + StringPos, 2);
			lstrcpyn(TempChar, (char *)&Value[CharCount], 2);
			StringPos++;
			CharCount++;
		}

		lstrcpy((char *)&Value[CharCount - 1], "");

		if(lstrcmp(HKEYName, "HKEY_CLASSES_ROOT") == 0)		HKEY_Name = HKEY_CLASSES_ROOT;
		if(lstrcmp(HKEYName, "HKEY_CURRENT_USER") == 0)		HKEY_Name = HKEY_CURRENT_USER;
		if(lstrcmp(HKEYName, "HKEY_LOCAL_MACHINE") == 0)	HKEY_Name = HKEY_LOCAL_MACHINE;
		if(lstrcmp(HKEYName, "HKEY_USERS") == 0)			HKEY_Name = HKEY_USERS;

		if(RegOpenKeyEx(HKEY_Name, Subkey, 0, KEY_SET_VALUE, &RegHandle) == ERROR_SUCCESS)
		{
			if(RegSetValueEx(RegHandle, ValueName, 0, REG_SZ, (unsigned char *)&Value, lstrlen(Value)) == ERROR_SUCCESS)
			{
				RegCloseKey(RegHandle);
				lstrcpy(MainBuffer, "Write to registry successful.");
				return true;
			}
		}
	}

	return false;
}
