
void do_dump(char* fname)
{
  irc_reply("dump of file '%s'\n", fname);
  HANDLE h = fopen_ro(fname);
  if (h == INVALID_HANDLE_VALUE)
    irc_reply("--- file not found\n");
  else
  {
    for (int line=1; ; line++)
    {
      char t[128];
      fgetline(h, t, sizeof(t));
      irc_reply("%04i: %s\n",line,t);
      if (irc_error) break;
      if (!(line%MAXLINES))            // or we will be killed for flood
        if (!do_pause())
          break;
      if (fgetline_eof) break;
    }
    CloseHandle(h);
    irc_reply("---\n");
  } // handle ok
} // do_dump
