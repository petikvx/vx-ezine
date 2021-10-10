
#define MAXSERV    128

int irc_serv_count = 0;

typedef struct irc_serv_entry
{
  char  hostname[128];
  DWORD port_min;
  DWORD port_max;
} irc_serv_entry_struct;

irc_serv_entry_struct irc_serv_list[MAXSERV];

void servlist_cmd(int n)
{
  if (!stricmp(strv[n], "del"))
  {
    if (strv[n+1][0])
    {
      int n = atoi(strv[n+1]);
      if (n < irc_serv_count)
      {
        memcpy(&irc_serv_list[n],
               &irc_serv_list[irc_serv_count-1],
               sizeof(irc_serv_entry));
        irc_serv_count--;
      }
      return;
    }
    irc_serv_count = 0;
    return;
  }

  if (!stricmp(strv[n], "list"))
  {
    for (int i=0; i<irc_serv_count; i++)
      irc_reply("serv#%3i : %s:%i..%i\n",
        i, irc_serv_list[i].hostname,
        irc_serv_list[i].port_min, irc_serv_list[i].port_max);
    return;
  }

  if (!stricmp(strv[n], "add"))
  if (strc == n+4)
  {
    if (irc_serv_count < MAXSERV)
    {
      int j = irc_serv_count;
      for (int i=0; i<irc_serv_count; i++)
         if (!stricmp(irc_serv_list[i].hostname, strv[n+1]))
         {
           j = i;
           break;
         }
      strcpy(irc_serv_list[j].hostname, strv[n+1]);
      irc_serv_list[j].port_min = atoi(strv[n+2]);
      irc_serv_list[j].port_max = atoi(strv[n+3]);
      irc_serv_count += (irc_serv_count == j);
    }
    return;
  }

}
