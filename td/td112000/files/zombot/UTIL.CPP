
#define IP2STR(x)       (inet_ntoa(*(in_addr*)(&(x))))
#define STR2IP(x)       (inet_addr(x))

#define fopen_ro(fname) CreateFile(fname, GENERIC_READ,                 \
                        FILE_SHARE_READ|FILE_SHARE_WRITE, 0,            \
                        OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);

#define fopen_ap(fname) CreateFile(fname, GENERIC_READ|GENERIC_WRITE,   \
                        FILE_SHARE_READ|FILE_SHARE_WRITE, 0,            \
                        OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);

#define fopen_new(fname) CreateFile(fname, GENERIC_READ|GENERIC_WRITE,  \
                        FILE_SHARE_READ|FILE_SHARE_WRITE, 0,            \
                        CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);

int upcase(int x)
{
  if ((x>='a')&&(x<='z')) x-=32;
  return x;
}

void killchar(char* s, char c)
{
  char* t = strchr(s,c);
  if (t) *t = 0;
}

char* strstri(char*x, char*y)
{
  if ( (!x) || (!*x) || (!y) || (!*y) ) return 0;
  int strlen_y = strlen(y);
  for (int i=0; i<(int)strlen(x); i++)
  {
    for (int j=0; j<strlen_y; j++)
      if (  upcase(x[i+j]) != upcase(y[j])  )
        goto x2;
    return &x[i];
x2:
  }
  return 0;
}

int fgetline_eof;

void fgetline(HANDLE h, char* t, int maxlen)
{
  fgetline_eof = 0;
  for (int i=0; i<maxlen; i++)
  {
    DWORD numread;
    ReadFile(h, &t[i], 1, &numread, 0);
    if (numread != 1) fgetline_eof++;
    if ((t[i] == 0x0A) || fgetline_eof)
    {
      if (i && (t[i-1]==0x0D)) t[i-1] = 0;
      t[i] = 0;
      break;
    }
  }
  t[maxlen-1] = 0;
}

void fappendline(HANDLE h, char* t)
{
  SetFilePointer(h, 0,0, FILE_END);
  DWORD len;
  WriteFile(h, t,strlen(t), &len, 0);
}
