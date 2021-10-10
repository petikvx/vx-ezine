
char* str1 = "bcdfghjklmnpqrstvwxz";
char* str2 = "aeiouy";

// returns nick-alike random string

char* mkrndstr(int usekewl, char* s)
{
  int len = rndR(3,9);
  char *q = s;
  if (usekewl)
    if (!rnd(4)) *q++ = rnd(2)?'_':'-';
  char *c = rnd(2) ? str1 : str2;
  while (len--)
  {
    (DWORD)c ^= (DWORD)str1 ^ (DWORD)str2;
    char t = c[ rnd(strlen(c)) ];
    if (usekewl)
      if (t=='o') if (rnd(2)) t='0';
    *q++ = t;
  }
  if (usekewl)
  {
    if (!rnd(3)) *q++ = rndR('0','9');
    if (!rnd(4)) *q++ = rnd(2)?'_':'-';
    if (!rnd(3)) *s = upcase(*s);
  }
  else
    *s = upcase(*s);
  *q = 0;
  return q;
}

// host is somebody's IP address
// returns 'realname', depending on host

char  host2real_tmp[256];

char* host2real(char *host)
{
  DWORD hash = 1;
  while (*host)
    hash *= hash ^ *host++;  // host --> hash
  DWORD temp = randseed;
  randseed = hash;
  char *c = host2real_tmp;
  c = mkrndstr(0,c);
  *c++ = 32;
  mkrndstr(0, c);
  randseed ^= temp;
  return host2real_tmp;
}
