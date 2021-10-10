
// - dcc send/recv routines
// - taken from Bhunji's ircbot srcs, rewritten in c++, a little bit modified
// - multiple send's and/or recv's allowed at one time
// - no resume supported

// PRIVMSG destnick :DCC SEND fname 2130706433 2002 123456

struct dcc_send_struct
{
  char dcc_send_reply[32];
  char dcc_send_nick[32];
  char dcc_send_fname[1024];
};

struct dcc_recv_struct
{
  char dcc_recv_reply[32];
  char dcc_recv_fname[1024];
  int  dcc_recv_ip;
  int  dcc_recv_port;
  int  dcc_recv_size;
};

struct dcc_recv_struct dccr;

void __stdcall dcc_send(dcc_send_struct *ss)
{
  log3("þ dcc send [%s]-->[%s]\n", ss->dcc_send_fname, ss->dcc_send_nick);

  char prefix[1024];
  sprintf(prefix, "PRIVMSG %s :dcc send %s-->%s :",
      ss->dcc_send_reply,
      ss->dcc_send_fname,
      ss->dcc_send_nick);

  HANDLE h;
  SOCKET dccsock, sock;

  for (;;)      // lots of break's within
  {

    dccsock = socket(AF_INET, SOCK_STREAM, IPPROTO_IP);
    if ((DWORD)dccsock == INVALID_SOCKET) break;

    int dccport = rndR(50200,52200);      // dunno

    struct sockaddr_in addr = {AF_INET};
    addr.sin_port = htons(dccport);
    addr.sin_addr.s_addr = 0;

    if (bind(dccsock, (sockaddr*)&addr, sizeof(addr)) != 0)
    {
      log1("bind error\n");
      break;
    }

    h = fopen_ro(ss->dcc_send_fname);
    if (h == INVALID_HANDLE_VALUE)
    {
      log1("fopen_ro error\n");
      break;
    }

    int len = GetFileSize(h,0);

    irc_send("PRIVMSG %s :DCC SEND %s %u %i %i\n",
      ss->dcc_send_nick, ss->dcc_send_fname, htonl(irc_local_ip), dccport, len);

    irc_send("%s waiting on %s:%i\n", prefix, irc_local_ip_str, dccport);

    listen(dccsock, 2);

    fd_set readfd;
    readfd.fd_count = 1;
    readfd.fd_array[0] = dccsock;

    struct timeval tv = {60,0};

    if (select(0, &readfd, 0,0, &tv) == 0)
    {
      irc_send("%s timeout\n", prefix);
      log1("select error\n");
      break;
    }

    SOCKET sock = accept(dccsock, 0, 0);

    closesocket(dccsock);

    irc_send("%s sending %i bytes...\n", prefix, len);

    for (;;)
    {
      char buf[1024];
      DWORD bufsize;
      ReadFile(h, buf,sizeof(buf), &bufsize, 0);
      int res = send(sock, buf, bufsize, 0);
      if (res == SOCKET_ERROR)
        irc_send("%s error\n", prefix);
      if (res != sizeof(buf)) break;     // eof || send() error
    }

    irc_send("%s complete\n", prefix);

    Sleep(5*1000);                // wait until last portion sent

    break;
  } // for

  closesocket(sock);
  closesocket(dccsock);
  CloseHandle(h);

  free(ss);

  log1("þ dccsend complete\n");
}

void __stdcall dcc_recv(dcc_recv_struct *rr)
{
  log2("þ dccrecv [%s]\n", rr->dcc_recv_fname);

  char prefix[1024];
  sprintf(prefix, "PRIVMSG %s :dcc recv %s :",
      rr->dcc_recv_reply,
      rr->dcc_recv_fname);

  irc_send("%s ip=%s port=%i\n", prefix,
        IP2STR(rr->dcc_recv_ip),
        rr->dcc_recv_port);

  SOCKET dccsock;
  HANDLE h;

  for (;;)
  {

    dccsock = socket(AF_INET, SOCK_STREAM, IPPROTO_IP);
    if ((DWORD)dccsock == INVALID_SOCKET) break;

    struct sockaddr_in addr = {AF_INET};
    addr.sin_port = htons(rr->dcc_recv_port);
    addr.sin_addr.s_addr = rr->dcc_recv_ip;

    if (connect(dccsock, (sockaddr*)&addr, sizeof(addr)) == SOCKET_ERROR)
    {
      irc_send("%s connect error\n", prefix);
      log1("connect error\n");
      break;
    }

    h = fopen_new(rr->dcc_recv_fname);
    if (!h) break;

    irc_send("%s receiving %i bytes\n", prefix, rr->dcc_recv_size);

    int fpos = 0;

    for (;;)
    {
      char buf[1024];
      int bufsize = recv(dccsock, buf, sizeof(buf), 0);

      if (  (bufsize == SOCKET_ERROR) || (bufsize == 0)  )
      {
        irc_send("%s recv() error\n", prefix);
        break;
      }

      DWORD numwritten;
      WriteFile(h, buf,bufsize, &numwritten, 0);

      fpos += bufsize;

      DWORD temp = htonl(fpos);
      if (send(dccsock, (char*)&temp, sizeof(temp), 0) != sizeof(temp))
      {
        irc_send("%s send() error\n", prefix);
        break;
      }

      if (fpos >= rr->dcc_recv_size) break;
    }

    irc_send("%s complete\n", prefix);

    break;
  } // for

  closesocket(dccsock);
  CloseHandle(h);
  free(rr);

  log1("þ dccrecv complete\n");
}

void dcc_cmd(int n)
{

  if (!stricmp(strv[n], "send"))
  if (strc==(n+3))
  {
    auth(strv[n+1]);
    if (  (!auth_host[0]) || (GetFileAttributes(strv[n+2]) == 0xFFFFFFFF)  )
    {
      irc_reply("%s and/or %s not found\n", strv[n+1], strv[n+2]);
      return;
    }
    dcc_send_struct *ss = (dcc_send_struct*) malloc(sizeof(dcc_send_struct));
    strcpy(ss->dcc_send_reply, irc_caller);
    strcpy(ss->dcc_send_nick,  strv[n+1]);
    strcpy(ss->dcc_send_fname, strv[n+2]);
    DWORD tid;
    CreateThread(0, 65536, (unsigned long (__stdcall*)(void*))&dcc_send,
                    ss, 0, &tid);
    return;
  }

  if (!stricmp(strv[n], "recv"))
  {
    if (!dccr.dcc_recv_ip)
    {
      irc_reply("no info received yet\n");
      return;
    }
    dcc_recv_struct *rr = (dcc_recv_struct*) malloc(sizeof(dcc_recv_struct));
    memcpy(rr, &dccr, sizeof(dcc_recv_struct));
    strcpy(rr->dcc_recv_reply, irc_caller);
    DWORD tid;
    CreateThread(0, 65536, (unsigned long (__stdcall*)(void*))&dcc_recv,
                    rr, 0, &tid);
    dccr.dcc_recv_ip = 0;
    return;
  }

}
