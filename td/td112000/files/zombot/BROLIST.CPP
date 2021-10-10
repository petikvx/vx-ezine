
// example: K kicked N.
// all bots on chan will check, if N is brother and then kick/ban/flood K.
// best command to check if N is brother is /WHOIS N
// "brother list" allow us to reduce some /WHOIS calls,
// increasing speed of our reaction.

// this implementation of brolist may be effectivly used per ONE channel

#define MAXBRO  1024
char bro_nick[MAXBRO][10];
char bro_host[MAXBRO][16];              // IP in asciiz format

void brolist_init()
{
  setmem((char*)&bro_nick, sizeof(bro_nick), 0);
}

int brolist_matchban(char* ban)
{
  for (int i=0; i<MAXBRO; i++)
  if (bro_nick[i][0])
  {
    if (  strstri(ban, bro_nick[i])  ||     // banned brother?
          strstri(ban, bro_host[i])  )
      return 1;
  }
  return 0;
}

int is_brolist(char* nick)
{
  for (int i=0; i<MAXBRO; i++)
    if (!stricmp(bro_nick[i], nick))
      return 1;
  return 0;
}

void brolist_add(char* nick, char* host)
{
  if (is_brolist(nick)) return;
  for (int i=0; i<MAXBRO; i++)
    if (!bro_nick[i][0])
    {
      strcpy(bro_nick[i], nick);
      strcpy(bro_host[i], host);
      return;
    }
}

void brolist_del(char* nick)
{
  for (int i=0; i<MAXBRO; i++)
    if (!stricmp(bro_nick[i], nick))
    {
      bro_nick[i][0]=0;
      return;
    }
}

void brolist_ren(char* oldnick, char* newnick)
{
  for (int i=0; i<MAXBRO; i++)
    if (!stricmp(bro_nick[i], oldnick))
    {
      strcpy(bro_nick[i], newnick);
      return;
    }
}
