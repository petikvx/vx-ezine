
#include <windows.h>
#include <stdio.h>
#include <stdlib.h>
#include <io.h>
#pragma hdrstop

void main(int argc, char* argv[])
{
  printf("sniptest  v1.01\n");

  if (argc != 5 && argc != 6)
  {
    printf("syntax: sniptest ip port snippet_prefix snippet_file [text]\n");
    exit(0);
  }
  char* ip_str    = argv[1];
  char* port_str  = argv[2];
  char* sn_prefix = argv[3];
  char* sb_fname  = argv[4];
  char* text      = argc==6?argv[5]:NULL;

  FILE*f=fopen(sb_fname,"rb");
  if (f==NULL)
  {
    printf("fopen() error\n");
    exit(0);
  }
  int len = filelength(fileno(f));
  BYTE* buf = new BYTE[ len + (text==NULL?0:(strlen(text)+1)) + 10 ];
  fread(buf,1,len,f);
  fclose(f);

  if (text)
  {
    memcpy(buf+len, text, strlen(text)+1);
    len += strlen(text)+1;
  }

  while(len&3) buf[len++] = 0x90;       // ALIGN 4

  WSADATA WSAData;
  WSAStartup(MAKEWORD(1,1), &WSAData);

  struct sockaddr_in addr;
  addr.sin_family = AF_INET;
  addr.sin_port   = htons(atoi(port_str));
  addr.sin_addr.s_addr = inet_addr(ip_str);

  SOCKET s = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
  if (s == INVALID_SOCKET)
  {
    printf("connect() error\n");
    exit(0);
  }

  if (connect(s, (struct sockaddr*)&addr, sizeof(addr)) != 0)
  {
    printf("connect() error\n");
    exit(0);
  }

  char cmd[1024];
  strcpy(cmd, sn_prefix);
  memcpy(cmd+strlen(sn_prefix), &len, 4);
  int cmd_len = strlen(sn_prefix) + 4;

  if (send(s, cmd, cmd_len, 0) != cmd_len)
  {
    printf("send() error\n");
    exit(0);
  }

  Sleep(1000);

  if (send(s, (char*)buf, len, 0) != len)
  {
    printf("send() error\n");
    exit(0);
  }

  Sleep(5000);

  closesocket(s);

  WSACleanup();

} /* main */

/* EOF */
