//
// CONVERT
//   + uses convert.ini
//   + merge different databases into single file
//   + fix errors, merge/delete ranges
//   + generate "unused" ranges
//

#include <windows.h>
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <io.h>
#pragma hdrstop

#define MAXIP           1000000         // max # of ip ranges

#define INI_FILE        "convert.ini"

char ALL_IP_FILE [1024] = "";
char ERR_LOG_FILE[1024] = "";
char SKIP_COUNTRY[4096] = "";

#define MIN(a,b)        ((a)<(b)?(a):(b))
#define MAX(a,b)        ((a)>(b)?(a):(b))
#define is_digit(x)     (((x)>='0')&&((x)<='9'))
#define IP_STR(x)       (((x)>>24)&255), (((x)>>16)&255), (((x)>>8)&255), ((x)&255)

typedef unsigned __int64 x64;

typedef struct IP_ENTRY_STRUCT
{
  DWORD enabled;
  DWORD min_ip;
  DWORD max_ip;
  DWORD country;
  DWORD dt;
  x64   src;
  struct IP_ENTRY_STRUCT* prev;
  struct IP_ENTRY_STRUCT* next;
} IP_ENTRY;

int ip_entry_count = 0;
IP_ENTRY* root[64] = {NULL};
IP_ENTRY* tail[64] = {NULL};
IP_ENTRY** ip_entry   = NULL;
//IP_ENTRY** ip_entry_t = NULL;

int src_count = 0;
char* src_name[64];
int src_used[64] = {0};

void process_ipcountry(DWORD ip,DWORD n,char* cn,int mode,DWORD dt,int src)
{
  if (strstr(SKIP_COUNTRY,cn)==NULL)
  {
    assert(ip_entry_count < MAXIP);
    assert(src < 64);

    //printf(".1");
    DWORD min_ip = ip;
    DWORD max_ip = (mode==1) ? (ip | (0xFFFFFFFFu>>n)) : (ip + n - 1);

    IP_ENTRY* x = NULL;

    if (tail[src] == NULL || min_ip < tail[src]->min_ip)
    for(x = root[src]; x != NULL; x = x->next)
      if (min_ip <= x->min_ip)
        break;

    IP_ENTRY* t = new IP_ENTRY;
    assert(t);

    t->enabled = 1;
    t->min_ip  = min_ip;
    t->max_ip  = max_ip;
    t->country = (cn[1]<<8) | cn[0];
    t->dt      = dt;
    t->src     = 1 << (x64)src;
    t->next = t->prev = NULL;

    if (root[src] == NULL)
    {
      root[src] = tail[src] = t;
    }
    else
    {
      // [root] ... [x->prev]  /t\   [x]  [x->next] ... [tail]

      if (x == NULL)
      {
        t->prev = tail[src];
        tail[src]->next = t;
        tail[src] = t;
      }
      else
      {
        if (x->prev == NULL)
        {
          assert(x == root[src]);
          x->prev = t;
          t->next = x;
          root[src] = t;
        }
        else
        {
          assert(x && x->prev && x->next);
          t->prev = x->prev;
          t->next = x;
          x->prev->next = t;
          x->prev = t;
        }
      }
    }

    //printf(".2");
    ip_entry_count++;
  }
}

void process_rir(char* fname,int mode,int mode2,int src)
{
  if (access(fname, 4) != 0)
  {
    printf("+ skipped: %s\n", fname);
    return;
  }

  printf("+ reading: %s...\n", fname);

  FILE*f=fopen(fname,"rb");
  assert(f);
  int len = filelength(fileno(f));
  char* buf = new char[ len+1 ];
  assert(buf);
  assert(fread(buf,1,len,f)==len);
  fclose(f);

  printf("+ processing...\n");

  int a_count = 0;
  int a_len[64];
  a_len[a_count] = 0;
  static char a_str[64][64];
  for(int i=0; i<len; i++)
  {
    char c = buf[i];
    if (c == '#')
    {
      while((buf[i]!=0x0A)&&(i<len)) i++;
      continue;
    }
    else
    if (c == 0x0A)
    {
      a_count++;
      //

//      printf("(%d) ",a_count); for(int t=0; t<a_count; t++) printf("[%s]", a_str[t]); printf("\n");

      assert(a_count==7||a_count==6);
      if (a_str[0][0]!='1')
      if (a_str[1][0]!='*')
      if (*(DWORD*)&a_str[2][0] == '4vpi')
      {
        char* cn = a_str[1];
        DWORD a1,a2,a3,a4,n;
        assert(sscanf(a_str[3],"%d.%d.%d.%d",&a1,&a2,&a3,&a4)==4);
        n = atoi(a_str[4]);
        DWORD a = (a1<<24)|(a2<<16)|(a3<<8)|a4;
        DWORD y,m,d;
        if ((a_str[5][0]=='0')&&(a_str[5][1]==0))
        {
          y=m=d=0;
        }
        else
        {
          if (mode2==1)
          {
            assert(strlen(a_str[5]) == 8);
            y=(a_str[5][0]-'0')*1000+
              (a_str[5][1]-'0')*100+
              (a_str[5][2]-'0')*10+
              (a_str[5][3]-'0');
            m=(a_str[5][4]-'0')*10+
              (a_str[5][5]-'0');
            d=(a_str[5][6]-'0')*10+
              (a_str[5][7]-'0');
          }
          else
          {
            assert(strlen(a_str[5]) == 10);
            y=(a_str[5][0]-'0')*1000+
              (a_str[5][1]-'0')*100+
              (a_str[5][2]-'0')*10+
              (a_str[5][3]-'0');
            m=(a_str[5][5]-'0')*10+
              (a_str[5][6]-'0');
            d=(a_str[5][8]-'0')*10+
              (a_str[5][9]-'0');
          }
        }
        DWORD dt = y*10000+m*100+d;
        process_ipcountry(a,n,cn,mode,dt,src);
      }

      //
      a_count = 0;
      a_len[a_count] = 0;
    }
    else
    if (c == '|')
    {
      a_count++;
      a_len[a_count] = 0;
    }
    else
    {
      a_str[a_count][a_len[a_count]] = c;
      a_len[a_count]++;
      a_str[a_count][a_len[a_count]] = 0;
    }
  }

  delete buf;

}

DWORD htonl_inet_addr(char*s)
{
  DWORD a,b,c,d;
  assert(sscanf(s,"%d.%d.%d.%d",&a,&b,&c,&d)==4);
  return (a<<24)|(b<<16)|(c<<8)|d;
}

void process_geoip(char*fname,int date,int src)
{
  if (access(fname, 4) != 0)
  {
    printf("+ skipped: %s\n", fname);
    return;
  }

  printf("+ processing: %s\n", fname);

  FILE*f1=fopen(fname,"rb");
  assert(f1);
  static char t[1024];
  for(char*s=fgets(t,sizeof(t),f1); s!=NULL; s=fgets(t,sizeof(t),f1))
  {
//  printf("%s",s);
    char* x1 = s+1;
    char* x2 = strstr(x1,"\",\""); assert(x2); *x2 = 0; x2 += 3;
    char* x3 = strstr(x2,"\",\""); assert(x3); *x3 = 0; x3 += 3;
    char* x4 = strstr(x3,"\",\""); assert(x4); *x4 = 0; x4 += 3;
    char* x5 = strstr(x4,"\",\""); assert(x5); *x5 = 0; x5 += 3;
    char* x6 = strstr(x5,"\",\""); assert(x6); *x6 = 0;
    //printf("[%s][%s][%s]\n",x1,x2,x5);
    DWORD a1 = htonl_inet_addr(x1);
    DWORD a2 = htonl_inet_addr(x2);
    process_ipcountry(a1,a2-a1+1,x5,2,date,src);
  }
  fclose(f1);
}

void process_ini()
{
  FILE*f=fopen(INI_FILE,"rb");
  assert(f);
  static char t[1024];
  int n = 0;
  for(char*s=fgets(t,sizeof(t)-1,f); s!=NULL; s=fgets(t,sizeof(t)-1,f))
  {
    while(s[0]&&(s[strlen(s)-1]<=32)) s[strlen(s)-1]=0;
    if (s[0]&&(s[0]!='#'))
    {
      n++;
      if (n==1)
        strcpy(ALL_IP_FILE,s);
      else
      if (n==2)
        strcpy(ERR_LOG_FILE,s);
      else
      if (n==3)
        strcpy(SKIP_COUNTRY,s);
      else
      {
        char* p, *x, *y, *z;                              // s=type
        p = strchr(s, ';'); assert(p); *p++ = 0; x = p;   // x=db_name
        p = strchr(p, ';'); assert(p); *p++ = 0; y = p;   // y=db_file
        p = strchr(p, ';'); assert(p); *p++ = 0; z = p;   // z=arg1
        p = strchr(p, ';'); assert(p); *p++ = 0;          // p=arg2
        //printf("[%s] [%s] [%s] [%s] [%s]\n", s, x, y, z, p);
        assert(s[1]==0&&(s[0]=='1'||s[0]=='2'));

        assert(src_count < 64);
        src_name[src_count] = strdup(x);

        if (s[0]=='1')
        {
          assert(z[1]==0&&(z[0]=='1'||z[0]=='2'));
          assert(p[1]==0&&(p[0]=='1'||p[0]=='2'));
          process_rir(y,atoi(z),atoi(p),src_count);
        }
        else
        {
          assert(strlen(z)==8);
          assert(p[1]==0&&p[0]=='0');
          process_geoip(y,atoi(z),src_count);
        }

        src_count++;

      }
    }
  }

  assert(ALL_IP_FILE[0] && ERR_LOG_FILE[0]);

} // process_ini

char* src_str(x64 src)
{
  static char t[1024];
  t[0]=0;
  for(int i=0; i<src_count; i++)
    if (src & (1<<i))
      sprintf(t+strlen(t),"%s%s", t[0]?"+":"", src_name[i]);
  return t;
}

char fmt_s[10][1024];
int  fmt_n = 0;
char* fmt_ip(int n)
{
  fmt_n = (fmt_n + 1) % 10;

  sprintf(fmt_s[fmt_n], "%-10s  %2s  %8d  %08x-%08x   %d.%d.%d.%d-%d.%d.%d.%d",
    src_str(ip_entry[n]->src),
    (char*)&ip_entry[n]->country,
    ip_entry[n]->dt,
    ip_entry[n]->min_ip,
    ip_entry[n]->max_ip,
    IP_STR(ip_entry[n]->min_ip),
    IP_STR(ip_entry[n]->max_ip) );

  return  fmt_s[fmt_n];
}

void print_ip(FILE* f, int n)
{
  fprintf(f, "  %s %s\n", ip_entry[n]->enabled ? " ":"-", fmt_ip(n));
}

void main()
{
  ip_entry_count = 0;
  memset(root,0,sizeof(root));
  memset(tail,0,sizeof(tail));

  process_ini();

  /* merge src_count sorted linked lists into sorted array */

  ip_entry = new IP_ENTRY*[ ip_entry_count+1 ];
  assert(ip_entry);

  DWORD t = 0;

  int modified = 1;
  while(modified)
  {
    modified = 0;

    DWORD min_ip = 0xffffffff;
    int m = -1;
    for(int n = 0; n < src_count; n++)
    if (root[n])
    {
      if (min_ip >= root[n]->min_ip)
      {
        min_ip = root[n]->min_ip;
        m = n;
      }
    }
    if (m != -1)
    {
      modified++;
      ip_entry[t++] = root[m];
      root[m] = root[m]->next;
    }
  }

  assert(t==ip_entry_count);

  for(t=1; t<ip_entry_count; t++)
  {
    assert(ip_entry[t]->min_ip >= ip_entry[t-1]->min_ip);
  }

  printf("+ checking...\n");

  FILE* lf = fopen("convert.err","wb");
  assert(lf);

  DWORD t0=0,i,j,n;
  int err[10] = {0,0,0,0,0, 0,0,0,0,0};
  int dump = GetFileType(GetStdHandle(STD_OUTPUT_HANDLE)) != FILE_TYPE_DISK;

  int iter = 0, del = 0;
  modified = 1;
  while(modified)
  {
    modified = 0;

    iter++;
    fprintf(lf, "! iter=%d\n", iter);

    for(i=0; i<ip_entry_count; i++)
    if (ip_entry[i]->enabled)
    {

      int i_modified = 0;

      if (dump)
      if ((GetTickCount() - t0) > 1000)
      {
        t0 = GetTickCount();
        //
        printf("%d/%d/%d   %d/%d/%d/%d/%d/%d       \r",
          iter,
          i,
          ip_entry_count,
          err[1], err[2], err[3], err[4], err[5], err[6]);
      }

      for(j=MAX((int)(i-10),0); j<MIN(i+10,ip_entry_count); j++)
      if (j!=i)
      if (ip_entry[j]->enabled)
      {

        if ( (ip_entry[i]->min_ip >= ip_entry[j]->min_ip) &&
             (ip_entry[i]->min_ip <= ip_entry[j]->max_ip) &&
             (ip_entry[i]->max_ip >= ip_entry[j]->min_ip) &&
             (ip_entry[i]->max_ip <= ip_entry[j]->max_ip) )
        {
          if (ip_entry[i]->country != ip_entry[j]->country)
          {
            modified++;
            i_modified++;
            err[1]++;
            fprintf(lf,".1  range inclusion, country mismatch, using latest\n");
            del++;

            ip_entry[ip_entry[i]->dt > ip_entry[j]->dt ? j : i]->enabled = 0;

            print_ip(lf,i);
            print_ip(lf,j);
          }
          else
          if (
               (ip_entry[i]->min_ip == ip_entry[j]->min_ip)
               &&
               (ip_entry[i]->max_ip == ip_entry[j]->max_ip)
             )
          {
            modified++;
            i_modified++;
            err[2]++;
            fprintf(lf,".2  range equal, country equal, using latest\n");
            ip_entry[ip_entry[i]->dt > ip_entry[j]->dt ? j : i]->enabled = 0;
            del++;

            print_ip(lf,i);
            print_ip(lf,j);
          }
          else
          {
            modified++;
            i_modified++;
            err[3]++;
            fprintf(lf,".3  range inclusion, country equal, remove inner\n");
            ip_entry[i]->enabled = 0;
            del++;

            print_ip(lf,i);
            print_ip(lf,j);
          }
        }

        if (!modified)
        if (
             (
               (ip_entry[i]->min_ip >= ip_entry[j]->min_ip)
               &&
               (ip_entry[i]->min_ip <= ip_entry[j]->max_ip)
             )
             ||
             (
               (ip_entry[i]->min_ip >= ip_entry[j]->min_ip)
               &&
               (ip_entry[i]->min_ip <= ip_entry[j]->max_ip)
             )
           )
        {
          if (ip_entry[i]->country == ip_entry[j]->country)
          {
            modified++;
            i_modified++;
            err[4]++;
            fprintf(lf,".4  range intersection, country equal, merge ranges\n");
            del++;

            ip_entry[i]->enabled = 0;
            ip_entry[j]->enabled = 0;
            print_ip(lf,i);
            print_ip(lf,j);

            ip_entry[ip_entry[i]->dt > ip_entry[j]->dt ? j : i]->enabled = 0;
            n =      ip_entry[i]->dt > ip_entry[j]->dt ? i : j;

            ip_entry[n]->enabled = 1;

            ip_entry[n]->min_ip = MIN(ip_entry[i]->min_ip, ip_entry[j]->min_ip);
            ip_entry[n]->max_ip = MAX(ip_entry[i]->max_ip, ip_entry[j]->max_ip);

            ip_entry[n]->src = ip_entry[i]->src | ip_entry[j]->src;

            print_ip(lf,n);

          }
          else
          {
            modified++;
            i_modified++;
            err[5]++;
            fprintf(lf,".5  range intersection, country mismatch, using latest\n");
            del++;

            // todo: split oldest range. nb: requires partial re-sorting

            ip_entry[ip_entry[i]->dt > ip_entry[j]->dt ? j : i]->enabled = 0;

            print_ip(lf,i);
            print_ip(lf,j);
          }
        }

        if (!modified)
        if (ip_entry[i]->country == ip_entry[j]->country)
        {
          if ( ((ip_entry[i]->max_ip+1) == ip_entry[j]->min_ip) ||
               ((ip_entry[j]->max_ip+1) == ip_entry[i]->min_ip) )
          {
            modified++;
            i_modified++;
            err[6]++;
            fprintf(lf,".6  ranges near, country equal, joining\n");
            del++;

            ip_entry[i]->enabled = 0;
            ip_entry[j]->enabled = 0;
            print_ip(lf,i);
            print_ip(lf,j);

            n = ip_entry[i]->dt > ip_entry[j]->dt ? i : j;

            ip_entry[n]->min_ip = MIN(ip_entry[i]->min_ip, ip_entry[j]->min_ip);
            ip_entry[n]->max_ip = MAX(ip_entry[i]->max_ip, ip_entry[j]->max_ip);

            ip_entry[n]->src = ip_entry[i]->src | ip_entry[j]->src;

            ip_entry[n]->enabled = 1;
            print_ip(lf,n);
          }
        }

      } //for j

      if (i_modified && (i!=0) && ip_entry[i]->enabled) i--;

    } // for i


    if ((del > 5) || (!modified))
    {
      j = 0;
      for(i=0; i<ip_entry_count; i++)
      {
        if (ip_entry[i]->enabled)
        {
          if (i != j)
            ip_entry[j] = ip_entry[i];
          j++;
        }
        else
        {
          delete ip_entry[i];
        }
      }
      ip_entry_count = j;
    }

  } // while

  for(i=1; i<=6; i++)
    fprintf(lf,"error=%d count=%d\n", i, err[i]);

  for(i=0; i<ip_entry_count; i++)
    if (ip_entry[i]->enabled)
      for(j=0; j<src_count; j++)
        if (ip_entry[i]->src & (1<<(x64)j))
          src_used[j]++;
  for(j=0; j<src_count; j++)
    fprintf(lf,"src=%-16s count=%d\n", src_name[j], src_used[j]);

  fclose(lf);

  if (dump && t0)
  printf("\n");

  printf("+ writing: %s\n", ALL_IP_FILE);

  FILE*f=fopen(ALL_IP_FILE,"wb");
  assert(f);

  setvbuf(f,NULL,_IOFBF,65536);

  fprintf(f,"#\n");
  fprintf(f,"# generated file. do not edit\n");
  fprintf(f,"# format:\n");
  fprintf(f,"# min_ip_hex,max_ip_hex,min_ip,max_ip,date,country,source\n");
  fprintf(f,"#\n");

  DWORD prev_max_ip = 0;

  for(i=0; i<ip_entry_count; i++)
  {
    assert(ip_entry[i]->enabled);

    if (ip_entry[i]->min_ip > prev_max_ip)
    {
      fprintf(f,"%08x,%08x,%d.%d.%d.%d,%d.%d.%d.%d,0,**,N/A\n",
        prev_max_ip,
        ip_entry[i]->min_ip-1,
        IP_STR(prev_max_ip),
        IP_STR(ip_entry[i]->min_ip-1) );
    }

    fprintf(f,"%08x,%08x,%d.%d.%d.%d,%d.%d.%d.%d,%d,%c%c,%s\n",
      ip_entry[i]->min_ip,
      ip_entry[i]->max_ip,
      IP_STR(ip_entry[i]->min_ip),
      IP_STR(ip_entry[i]->max_ip),
      ip_entry[i]->dt,
      ip_entry[i]->country&0xff,
      (ip_entry[i]->country>>8)&0xff,
      src_str(ip_entry[i]->src)
      );

    if (i)
      assert(ip_entry[i-1]->max_ip < ip_entry[i]->min_ip);

    prev_max_ip = ip_entry[i]->max_ip + 1;

  }

  if (prev_max_ip != 0xffffffff)
  fprintf(f,"%08x,%08x,%d.%d.%d.%d,%d.%d.%d.%d,0,**,N/A\n",
    prev_max_ip,
    0xffffffff,
    IP_STR(prev_max_ip),
    IP_STR(0xffffffff) );

  fprintf(f,"# EOF\n");

  fclose(f);

  printf("\n");
  printf("All OK\n");

} // main
