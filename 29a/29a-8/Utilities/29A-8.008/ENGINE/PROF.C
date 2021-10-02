
#include "prof.h"

void __cdecl set_default_profile(struct SHGE_OPTIONS *opt)
{
  memset(opt, 0x00, sizeof(struct SHGE_OPTIONS));

  opt->SHELL_PORT              = 666;
  opt->VAR_PORT                = 0;
  opt->MAXBUFSIZE              = 512;
  opt->USE_SEH                 = 1;
  opt->USE_SEH_TH              = 0;
  opt->USE_MUTEX               = 0;
  opt->DO_REUSEADDR            = 1;
  opt->SUPPORT_WIN9X           = 1;
  opt->USE_OLDWAY_2FIND_K32    = 0;
  opt->XORBYTE                 = 0;
  opt->USE_LASTCALL            = 1;
  opt->USE_XPUSH_STRINGS       = 1;
  opt->ALLOC_BUF               = 0;
  opt->BACKCONNECT             = 0;
  opt->IP_ADDR                 = 0;
  opt->RECONNECT_MS            = 10*1000;
  opt->MULTITHREAD             = 1;
  opt->DONT_DROP               = 1;
  opt->DO_WSA_STARTUP          = 1;
  opt->DIRECT_API              = 0;
  opt->K32_ID                  = 0xB8;
  opt->WS2_ID                  = 0xB9;

  opt->POS_INSTR               = 16;
  opt->POS_ARG1                = 24;
  opt->POS_COMM                = 40;
  opt->POS_HPP_COMMENT         = 50;
  opt->POS_HPP_COMMENT_SIZE    = 70;

  opt->HPP_TYPE                = 1;
  opt->SH_SIZE                 = 1;
  opt->HPP_OFF                 = 1;
  opt->CMT_SRC                 = 1;
  opt->CMT_HPP                 = 1;

  opt->COMPRESSED              = 1;
  opt->BEST                    = 0;
  opt->BEST2                   = 0;
  opt->XORED                   = 1;
  strcpy(opt->HIDE, "/\\\\");
  opt->INACT                   = 0;

  opt->P1                      = 2;
  opt->P2                      = 8;
  opt->P3                      = 0;
  opt->P4                      = 3;
  opt->P5                      = 0;

  opt->SUB_CREATEPIPE          = 0;
  opt->SUB_KILLSHELL           = 1;
  opt->SUB_INIT                = 0;
  opt->SUB_FINDBASE            = 0;
  opt->MACRO_CALL              = 1;

  strcpy(opt->str_mutex  , "sh_mtx");
  strcpy(opt->str_ws2    , "WS2_32.DLL");
  strcpy(opt->str_cmd    , "CMD.EXE");
  strcpy(opt->str_command, "COMMAND.COM");

  opt->BC2HOST                 = 1;
  strcpy(opt->str_host, "localhost");

  opt->SYNTAX                  = 0;
  opt->HASHTYPE                = 0;

  sprintf(opt->l_prefix ,"__");
  sprintf(opt->l_postfix,"");
  sprintf(opt->x_prefix ,"var_");
  sprintf(opt->x_postfix,"");
  sprintf(opt->c_prefix ,"C_");
  sprintf(opt->c_postfix,"");
  sprintf(opt->m_prefix ,"M_");
  sprintf(opt->m_postfix,"");
  sprintf(opt->a_prefix ,"API_");
  sprintf(opt->a_postfix,"");

  opt->NOSHELL                 = 0;
  opt->PROMPT                  = 0;
  opt->AUTH                    = 0;
  opt->SNIPPET                 = 0;
  strcpy(opt->str_prompt ,"yo bro?\\r\\n");
  strcpy(opt->str_auth   ,"wazzup!");
  strcpy(opt->str_snippet,"#cdsnpt#");

} /* set_default_profile */

int load_option(char* z, char* q, void* v)
{
  char s[1024];
  unsigned long d;
  char* x;

  strcpy(s, z);
  d = 0;

  while((s[0]==32)||(s[0]==9)) strcpy(s,s+1);

  while(s[0] && ((s[strlen(s)-1]==13)||
                 (s[strlen(s)-1]==10)||
                 (s[strlen(s)-1]==32)))
    s[strlen(s)-1]=0;

  x = (char*)strchr(s,'=');
  if (x == NULL) return 0;

  *x++ = 0;

  while(s[0] && (s[strlen(s)-1]==32))
    s[strlen(s)-1]=0;

  if (q[0]!='s')
  while((x[0]==32)||(x[0]==9)) strcpy(x,x+1);

  if (stricmp(s,q+2)!=0) return 0;

  if (q[0]=='s')
  {
    strcpy((char*)v, x);
    return 1;
  }

  if ((q[0]=='B')||(q[0]=='W')||(q[0]=='D'))
  {
    if ((x[0]=='0')&&(x[1]=='x'))
    {
      if (sscanf(x+2,"%X",&d)!=1) return 0;
    }
    else
    {
      if (sscanf(x,"%u",&d)!=1) return 0;
    }
    if (q[0]=='B') { *(unsigned char *)v = (unsigned char )d; return 1; }
    if (q[0]=='W') { *(unsigned short*)v = (unsigned short)d; return 1; }
    if (q[0]=='D') { *(unsigned long *)v = (unsigned long )d; return 1; }
  }
  if (q[0]=='i')
  {
    if ((x[0]=='0')&&(x[1]=='x'))
    {
      if (sscanf(x+2,"%X",&d)!=1) return 0;
    }
    else
    {
      if (sscanf(x,"%i",&d)!=1) return 0;
    }
    *(int*)v = d;
    return 1;
  }
  return 0;
} /* load_option */

void save_option(FILE* f, char* q, void* v)
{
  if (q[0]=='B') fprintf(f,"%s=0x%02X\r\n",q+2,*(unsigned char *)v);
  if (q[0]=='W') fprintf(f,"%s=0x%04X\r\n",q+2,*(unsigned short*)v);
  if (q[0]=='D') fprintf(f,"%s=0x%08X\r\n",q+2,*(unsigned long *)v);
  if (q[0]=='i') fprintf(f,"%s=%i\r\n",    q+2,*(int           *)v);
  if (q[0]=='s') fprintf(f,"%s=%s\r\n",    q+2,(char*)v);
} /* save_option */

int __cdecl load_profile(struct SHGE_OPTIONS *opt, char* filename)
{
  FILE* f;
  char t[1024], *s;
  int opt_count;

  set_default_profile(opt);

  f = fopen(filename, "rb");

  if (f==NULL)
    return 0;

  opt_count = 0;

  for(s = fgets(t,sizeof(t)-1,f); s != NULL; s = fgets(t,sizeof(t)-1,f))
  {

    opt_count += load_option(s,"W.SHELL_PORT"                 ,(void*)&opt->SHELL_PORT                 );
    opt_count += load_option(s,"i.VAR_PORT"                   ,(void*)&opt->VAR_PORT                   );
    opt_count += load_option(s,"i.MAXBUFSIZE"                 ,(void*)&opt->MAXBUFSIZE                 );
    opt_count += load_option(s,"i.USE_SEH"                    ,(void*)&opt->USE_SEH                    );
    opt_count += load_option(s,"i.USE_SEH_TH"                 ,(void*)&opt->USE_SEH_TH                 );
    opt_count += load_option(s,"i.USE_MUTEX"                  ,(void*)&opt->USE_MUTEX                  );
    opt_count += load_option(s,"i.DO_REUSEADDR"               ,(void*)&opt->DO_REUSEADDR               );
    opt_count += load_option(s,"i.SUPPORT_WIN9X"              ,(void*)&opt->SUPPORT_WIN9X              );
    opt_count += load_option(s,"i.USE_OLDWAY_2FIND_K32"       ,(void*)&opt->USE_OLDWAY_2FIND_K32       );
    opt_count += load_option(s,"B.XORBYTE"                    ,(void*)&opt->XORBYTE                    );
    opt_count += load_option(s,"i.USE_LASTCALL"               ,(void*)&opt->USE_LASTCALL               );
    opt_count += load_option(s,"i.USE_XPUSH_STRINGS"          ,(void*)&opt->USE_XPUSH_STRINGS          );
    opt_count += load_option(s,"i.ALLOC_BUF"                  ,(void*)&opt->ALLOC_BUF                  );
    opt_count += load_option(s,"i.BACKCONNECT"                ,(void*)&opt->BACKCONNECT                );
    opt_count += load_option(s,"D.IP_ADDR"                    ,(void*)&opt->IP_ADDR                    );
    opt_count += load_option(s,"D.RECONNECT_MS"               ,(void*)&opt->RECONNECT_MS               );
    opt_count += load_option(s,"i.MULTITHREAD"                ,(void*)&opt->MULTITHREAD                );
    opt_count += load_option(s,"D.WS2_ID"                     ,(void*)&opt->WS2_ID                     );
    opt_count += load_option(s,"D.K32_ID"                     ,(void*)&opt->K32_ID                     );
    opt_count += load_option(s,"i.DONT_DROP"                  ,(void*)&opt->DONT_DROP                  );
    opt_count += load_option(s,"i.DO_WSA_STARTUP"             ,(void*)&opt->DO_WSA_STARTUP             );
    opt_count += load_option(s,"i.DIRECT_API"                 ,(void*)&opt->DIRECT_API                 );
    opt_count += load_option(s,"D.API_K32_GlobalAlloc"        ,(void*)&opt->API_K32_GlobalAlloc        );
    opt_count += load_option(s,"D.API_K32_GlobalFree"         ,(void*)&opt->API_K32_GlobalFree         );
    opt_count += load_option(s,"D.API_K32_CreateThread"       ,(void*)&opt->API_K32_CreateThread       );
    opt_count += load_option(s,"D.API_K32_CloseHandle"        ,(void*)&opt->API_K32_CloseHandle        );
    opt_count += load_option(s,"D.API_K32_CreatePipe"         ,(void*)&opt->API_K32_CreatePipe         );
    opt_count += load_option(s,"D.API_K32_CreateProcessA"     ,(void*)&opt->API_K32_CreateProcessA     );
    opt_count += load_option(s,"D.API_K32_GetExitCodeProcess" ,(void*)&opt->API_K32_GetExitCodeProcess );
    opt_count += load_option(s,"D.API_K32_PeekNamedPipe"      ,(void*)&opt->API_K32_PeekNamedPipe      );
    opt_count += load_option(s,"D.API_K32_ReadFile"           ,(void*)&opt->API_K32_ReadFile           );
    opt_count += load_option(s,"D.API_K32_WriteFile"          ,(void*)&opt->API_K32_WriteFile          );
    opt_count += load_option(s,"D.API_K32_TerminateProcess"   ,(void*)&opt->API_K32_TerminateProcess   );
    opt_count += load_option(s,"D.API_K32_ExitThread"         ,(void*)&opt->API_K32_ExitThread         );
    opt_count += load_option(s,"D.API_K32_CreateMutexA"       ,(void*)&opt->API_K32_CreateMutexA       );
    opt_count += load_option(s,"D.API_K32_GetLastError"       ,(void*)&opt->API_K32_GetLastError       );
    opt_count += load_option(s,"D.API_K32_Sleep"              ,(void*)&opt->API_K32_Sleep              );
    opt_count += load_option(s,"D.API_K32_LoadLibraryA"       ,(void*)&opt->API_K32_LoadLibraryA       );
    opt_count += load_option(s,"D.API_K32_GetVersion"         ,(void*)&opt->API_K32_GetVersion         );
    opt_count += load_option(s,"D.API_K32_WaitForSingleObject",(void*)&opt->API_K32_WaitForSingleObject);
    opt_count += load_option(s,"D.API_K32_GetTickCount"       ,(void*)&opt->API_K32_GetTickCount       );
//    opt_count += load_option(s,"D.API_K32_GetProcAddress"     ,(void*)&opt->API_K32_GetProcAddress     );
    opt_count += load_option(s,"D.API_WS2_WSAStartup"         ,(void*)&opt->API_WS2_WSAStartup         );
    opt_count += load_option(s,"D.API_WS2_socket"             ,(void*)&opt->API_WS2_socket             );
    opt_count += load_option(s,"D.API_WS2_setsockopt"         ,(void*)&opt->API_WS2_setsockopt         );
    opt_count += load_option(s,"D.API_WS2_closesocket"        ,(void*)&opt->API_WS2_closesocket        );
    opt_count += load_option(s,"D.API_WS2_connect"            ,(void*)&opt->API_WS2_connect            );
    opt_count += load_option(s,"D.API_WS2_gethostbyname"      ,(void*)&opt->API_WS2_gethostbyname      );
    opt_count += load_option(s,"D.API_WS2_select"             ,(void*)&opt->API_WS2_select             );
    opt_count += load_option(s,"D.API_WS2_bind"               ,(void*)&opt->API_WS2_bind               );
    opt_count += load_option(s,"D.API_WS2_listen"             ,(void*)&opt->API_WS2_listen             );
    opt_count += load_option(s,"D.API_WS2_accept"             ,(void*)&opt->API_WS2_accept             );
    opt_count += load_option(s,"D.API_WS2_send"               ,(void*)&opt->API_WS2_send               );
    opt_count += load_option(s,"D.API_WS2_recv"               ,(void*)&opt->API_WS2_recv               );
    opt_count += load_option(s,"i.POS_INSTR"                  ,(void*)&opt->POS_INSTR                  );
    opt_count += load_option(s,"i.POS_ARG1"                   ,(void*)&opt->POS_ARG1                   );
    opt_count += load_option(s,"i.POS_COMM"                   ,(void*)&opt->POS_COMM                   );
    opt_count += load_option(s,"i.POS_HPP_COMMENT"            ,(void*)&opt->POS_HPP_COMMENT            );
    opt_count += load_option(s,"i.POS_HPP_COMMENT_SIZE"       ,(void*)&opt->POS_HPP_COMMENT_SIZE       );
    opt_count += load_option(s,"i.HPP_TYPE"                   ,(void*)&opt->HPP_TYPE                   );
    opt_count += load_option(s,"i.SH_SIZE"                    ,(void*)&opt->SH_SIZE                    );
    opt_count += load_option(s,"i.COMPRESSED"                 ,(void*)&opt->COMPRESSED                 );
    opt_count += load_option(s,"i.BEST"                       ,(void*)&opt->BEST                       );
    opt_count += load_option(s,"i.BEST2"                      ,(void*)&opt->BEST2                      );
    opt_count += load_option(s,"i.XORED"                      ,(void*)&opt->XORED                      );
    opt_count += load_option(s,"s.HIDE"                       ,(void*)&opt->HIDE                       );
    opt_count += load_option(s,"i.P1"                         ,(void*)&opt->P1                         );
    opt_count += load_option(s,"i.P2"                         ,(void*)&opt->P2                         );
    opt_count += load_option(s,"i.P3"                         ,(void*)&opt->P3                         );
    opt_count += load_option(s,"i.P4"                         ,(void*)&opt->P4                         );
    opt_count += load_option(s,"i.P5"                         ,(void*)&opt->P5                         );
    opt_count += load_option(s,"i.HPP_OFF"                    ,(void*)&opt->HPP_OFF                    );
    opt_count += load_option(s,"i.CMT_SRC"                    ,(void*)&opt->CMT_SRC                    );
    opt_count += load_option(s,"i.CMT_HPP"                    ,(void*)&opt->CMT_HPP                    );
    opt_count += load_option(s,"i.SUB_CREATEPIPE"             ,(void*)&opt->SUB_CREATEPIPE             );
    opt_count += load_option(s,"i.SUB_KILLSHELL"              ,(void*)&opt->SUB_KILLSHELL              );
    opt_count += load_option(s,"i.SUB_INIT"                   ,(void*)&opt->SUB_INIT                   );
    opt_count += load_option(s,"i.SUB_FINDBASE"               ,(void*)&opt->SUB_FINDBASE               );
    opt_count += load_option(s,"i.INACT"                      ,(void*)&opt->INACT                      );
    opt_count += load_option(s,"i.MACRO_CALL"                 ,(void*)&opt->MACRO_CALL                 );
    opt_count += load_option(s,"s.str_mutex"                  ,(void*)&opt->str_mutex                  );
    opt_count += load_option(s,"s.str_ws2"                    ,(void*)&opt->str_ws2                    );
    opt_count += load_option(s,"s.str_cmd"                    ,(void*)&opt->str_cmd                    );
    opt_count += load_option(s,"s.str_command"                ,(void*)&opt->str_command                );
    opt_count += load_option(s,"i.SYNTAX"                     ,(void*)&opt->SYNTAX                     );
    opt_count += load_option(s,"s.l_prefix"                   ,(void*)&opt->l_prefix                   );
    opt_count += load_option(s,"s.l_postfix"                  ,(void*)&opt->l_postfix                  );
    opt_count += load_option(s,"s.x_prefix"                   ,(void*)&opt->x_prefix                   );
    opt_count += load_option(s,"s.x_postfix"                  ,(void*)&opt->x_postfix                  );
    opt_count += load_option(s,"s.c_prefix"                   ,(void*)&opt->c_prefix                   );
    opt_count += load_option(s,"s.c_postfix"                  ,(void*)&opt->c_postfix                  );
    opt_count += load_option(s,"s.m_prefix"                   ,(void*)&opt->m_prefix                   );
    opt_count += load_option(s,"s.m_postfix"                  ,(void*)&opt->m_postfix                  );
    opt_count += load_option(s,"s.a_prefix"                   ,(void*)&opt->a_prefix                   );
    opt_count += load_option(s,"s.a_postfix"                  ,(void*)&opt->a_postfix                  );
    opt_count += load_option(s,"i.HASHTYPE"                   ,(void*)&opt->HASHTYPE                   );
    opt_count += load_option(s,"i.BC2HOST"                    ,(void*)&opt->BC2HOST                    );
    opt_count += load_option(s,"s.str_host"                   ,(void*)&opt->str_host                   );
    opt_count += load_option(s,"i.NOSHELL"                    ,(void*)&opt->NOSHELL                    );
    opt_count += load_option(s,"i.PROMPT"                     ,(void*)&opt->PROMPT                     );
    opt_count += load_option(s,"i.AUTH"                       ,(void*)&opt->AUTH                       );
    opt_count += load_option(s,"i.SNIPPET"                    ,(void*)&opt->SNIPPET                    );
    opt_count += load_option(s,"s.str_prompt"                 ,(void*)&opt->str_prompt                 );
    opt_count += load_option(s,"s.str_auth"                   ,(void*)&opt->str_auth                   );
    opt_count += load_option(s,"s.str_snippet"                ,(void*)&opt->str_snippet                );
  }

  fclose(f);

//  if (opt_count != XXX)
//  {
//    return 0;
//  }

  return 1;

} /* load_profile */

int __cdecl save_profile(struct SHGE_OPTIONS *opt, char* filename)
{
  FILE* f;

  f = fopen(filename, "wb");

  if (f==NULL)
    return 0;

  save_option(f,"W.SHELL_PORT"                 ,(void*)&opt->SHELL_PORT                 );
  save_option(f,"i.VAR_PORT"                   ,(void*)&opt->VAR_PORT                   );
  save_option(f,"i.MAXBUFSIZE"                 ,(void*)&opt->MAXBUFSIZE                 );
  save_option(f,"i.USE_SEH"                    ,(void*)&opt->USE_SEH                    );
  save_option(f,"i.USE_SEH_TH"                 ,(void*)&opt->USE_SEH_TH                 );
  save_option(f,"i.USE_MUTEX"                  ,(void*)&opt->USE_MUTEX                  );
  save_option(f,"i.DO_REUSEADDR"               ,(void*)&opt->DO_REUSEADDR               );
  save_option(f,"i.SUPPORT_WIN9X"              ,(void*)&opt->SUPPORT_WIN9X              );
  save_option(f,"i.USE_OLDWAY_2FIND_K32"       ,(void*)&opt->USE_OLDWAY_2FIND_K32       );
  save_option(f,"B.XORBYTE"                    ,(void*)&opt->XORBYTE                    );
  save_option(f,"i.USE_LASTCALL"               ,(void*)&opt->USE_LASTCALL               );
  save_option(f,"i.USE_XPUSH_STRINGS"          ,(void*)&opt->USE_XPUSH_STRINGS          );
  save_option(f,"i.ALLOC_BUF"                  ,(void*)&opt->ALLOC_BUF                  );
  save_option(f,"i.BACKCONNECT"                ,(void*)&opt->BACKCONNECT                );
  save_option(f,"D.IP_ADDR"                    ,(void*)&opt->IP_ADDR                    );
  save_option(f,"D.RECONNECT_MS"               ,(void*)&opt->RECONNECT_MS               );
  save_option(f,"i.MULTITHREAD"                ,(void*)&opt->MULTITHREAD                );
  save_option(f,"D.WS2_ID"                     ,(void*)&opt->WS2_ID                     );
  save_option(f,"D.K32_ID"                     ,(void*)&opt->K32_ID                     );
  save_option(f,"i.DONT_DROP"                  ,(void*)&opt->DONT_DROP                  );
  save_option(f,"i.DO_WSA_STARTUP"             ,(void*)&opt->DO_WSA_STARTUP             );
  save_option(f,"i.DIRECT_API"                 ,(void*)&opt->DIRECT_API                 );
  save_option(f,"D.API_K32_GlobalAlloc"        ,(void*)&opt->API_K32_GlobalAlloc        );
  save_option(f,"D.API_K32_GlobalFree"         ,(void*)&opt->API_K32_GlobalFree         );
  save_option(f,"D.API_K32_CreateThread"       ,(void*)&opt->API_K32_CreateThread       );
  save_option(f,"D.API_K32_CloseHandle"        ,(void*)&opt->API_K32_CloseHandle        );
  save_option(f,"D.API_K32_CreatePipe"         ,(void*)&opt->API_K32_CreatePipe         );
  save_option(f,"D.API_K32_CreateProcessA"     ,(void*)&opt->API_K32_CreateProcessA     );
  save_option(f,"D.API_K32_GetExitCodeProcess" ,(void*)&opt->API_K32_GetExitCodeProcess );
  save_option(f,"D.API_K32_PeekNamedPipe"      ,(void*)&opt->API_K32_PeekNamedPipe      );
  save_option(f,"D.API_K32_ReadFile"           ,(void*)&opt->API_K32_ReadFile           );
  save_option(f,"D.API_K32_WriteFile"          ,(void*)&opt->API_K32_WriteFile          );
  save_option(f,"D.API_K32_TerminateProcess"   ,(void*)&opt->API_K32_TerminateProcess   );
  save_option(f,"D.API_K32_ExitThread"         ,(void*)&opt->API_K32_ExitThread         );
  save_option(f,"D.API_K32_CreateMutexA"       ,(void*)&opt->API_K32_CreateMutexA       );
  save_option(f,"D.API_K32_GetLastError"       ,(void*)&opt->API_K32_GetLastError       );
  save_option(f,"D.API_K32_Sleep"              ,(void*)&opt->API_K32_Sleep              );
  save_option(f,"D.API_K32_LoadLibraryA"       ,(void*)&opt->API_K32_LoadLibraryA       );
  save_option(f,"D.API_K32_GetVersion"         ,(void*)&opt->API_K32_GetVersion         );
  save_option(f,"D.API_K32_WaitForSingleObject",(void*)&opt->API_K32_WaitForSingleObject);
  save_option(f,"D.API_K32_GetTickCount"       ,(void*)&opt->API_K32_GetTickCount       );
//  save_option(f,"D.API_K32_GetProcAddress"     ,(void*)&opt->API_K32_GetProcAddress     );
  save_option(f,"D.API_WS2_WSAStartup"         ,(void*)&opt->API_WS2_WSAStartup         );
  save_option(f,"D.API_WS2_socket"             ,(void*)&opt->API_WS2_socket             );
  save_option(f,"D.API_WS2_setsockopt"         ,(void*)&opt->API_WS2_setsockopt         );
  save_option(f,"D.API_WS2_closesocket"        ,(void*)&opt->API_WS2_closesocket        );
  save_option(f,"D.API_WS2_connect"            ,(void*)&opt->API_WS2_connect            );
  save_option(f,"D.API_WS2_gethostbyname"      ,(void*)&opt->API_WS2_gethostbyname      );
  save_option(f,"D.API_WS2_select"             ,(void*)&opt->API_WS2_select             );
  save_option(f,"D.API_WS2_bind"               ,(void*)&opt->API_WS2_bind               );
  save_option(f,"D.API_WS2_listen"             ,(void*)&opt->API_WS2_listen             );
  save_option(f,"D.API_WS2_accept"             ,(void*)&opt->API_WS2_accept             );
  save_option(f,"D.API_WS2_send"               ,(void*)&opt->API_WS2_send               );
  save_option(f,"D.API_WS2_recv"               ,(void*)&opt->API_WS2_recv               );
  save_option(f,"i.POS_INSTR"                  ,(void*)&opt->POS_INSTR                  );
  save_option(f,"i.POS_ARG1"                   ,(void*)&opt->POS_ARG1                   );
  save_option(f,"i.POS_COMM"                   ,(void*)&opt->POS_COMM                   );
  save_option(f,"i.POS_HPP_COMMENT"            ,(void*)&opt->POS_HPP_COMMENT            );
  save_option(f,"i.POS_HPP_COMMENT_SIZE"       ,(void*)&opt->POS_HPP_COMMENT_SIZE       );
  save_option(f,"i.HPP_TYPE"                   ,(void*)&opt->HPP_TYPE                   );
  save_option(f,"i.SH_SIZE"                    ,(void*)&opt->SH_SIZE                    );
  save_option(f,"i.COMPRESSED"                 ,(void*)&opt->COMPRESSED                 );
  save_option(f,"i.BEST"                       ,(void*)&opt->BEST                       );
  save_option(f,"i.BEST2"                      ,(void*)&opt->BEST2                      );
  save_option(f,"i.XORED"                      ,(void*)&opt->XORED                      );
  save_option(f,"s.HIDE"                       ,(void*)&opt->HIDE                       );
  save_option(f,"i.P1"                         ,(void*)&opt->P1                         );
  save_option(f,"i.P2"                         ,(void*)&opt->P2                         );
  save_option(f,"i.P3"                         ,(void*)&opt->P3                         );
  save_option(f,"i.P4"                         ,(void*)&opt->P4                         );
  save_option(f,"i.P5"                         ,(void*)&opt->P5                         );
  save_option(f,"i.HPP_OFF"                    ,(void*)&opt->HPP_OFF                    );
  save_option(f,"i.CMT_SRC"                    ,(void*)&opt->CMT_SRC                    );
  save_option(f,"i.CMT_HPP"                    ,(void*)&opt->CMT_HPP                    );
  save_option(f,"i.SUB_CREATEPIPE"             ,(void*)&opt->SUB_CREATEPIPE             );
  save_option(f,"i.SUB_KILLSHELL"              ,(void*)&opt->SUB_KILLSHELL              );
  save_option(f,"i.SUB_INIT"                   ,(void*)&opt->SUB_INIT                   );
  save_option(f,"i.SUB_FINDBASE"               ,(void*)&opt->SUB_FINDBASE               );
  save_option(f,"i.INACT"                      ,(void*)&opt->INACT                      );
  save_option(f,"i.MACRO_CALL"                 ,(void*)&opt->MACRO_CALL                 );
  save_option(f,"s.str_mutex"                  ,(void*)&opt->str_mutex                  );
  save_option(f,"s.str_ws2"                    ,(void*)&opt->str_ws2                    );
  save_option(f,"s.str_cmd"                    ,(void*)&opt->str_cmd                    );
  save_option(f,"s.str_command"                ,(void*)&opt->str_command                );
  save_option(f,"i.SYNTAX"                     ,(void*)&opt->SYNTAX                     );
  save_option(f,"s.l_prefix"                   ,(void*)&opt->l_prefix                   );
  save_option(f,"s.l_postfix"                  ,(void*)&opt->l_postfix                  );
  save_option(f,"s.x_prefix"                   ,(void*)&opt->x_prefix                   );
  save_option(f,"s.x_postfix"                  ,(void*)&opt->x_postfix                  );
  save_option(f,"s.c_prefix"                   ,(void*)&opt->c_prefix                   );
  save_option(f,"s.c_postfix"                  ,(void*)&opt->c_postfix                  );
  save_option(f,"s.m_prefix"                   ,(void*)&opt->m_prefix                   );
  save_option(f,"s.m_postfix"                  ,(void*)&opt->m_postfix                  );
  save_option(f,"s.a_prefix"                   ,(void*)&opt->a_prefix                   );
  save_option(f,"s.a_postfix"                  ,(void*)&opt->a_postfix                  );
  save_option(f,"i.HASHTYPE"                   ,(void*)&opt->HASHTYPE                   );
  save_option(f,"i.BC2HOST"                    ,(void*)&opt->BC2HOST                    );
  save_option(f,"s.str_host"                   ,(void*)&opt->str_host                   );
  save_option(f,"i.NOSHELL"                    ,(void*)&opt->NOSHELL                    );
  save_option(f,"i.PROMPT"                     ,(void*)&opt->PROMPT                     );
  save_option(f,"i.AUTH"                       ,(void*)&opt->AUTH                       );
  save_option(f,"i.SNIPPET"                    ,(void*)&opt->SNIPPET                    );
  save_option(f,"s.str_prompt"                 ,(void*)&opt->str_prompt                 );
  save_option(f,"s.str_auth"                   ,(void*)&opt->str_auth                   );
  save_option(f,"s.str_snippet"                ,(void*)&opt->str_snippet                );

  fclose(f);

  return 1;

} /* save_profile */

/* EOF */
