
#define MAXREDIR        128

char redir_i[MAXREDIR][32];
char redir_o[MAXREDIR][32];
int  redir_x[MAXREDIR];

char redir_prefix[1024];

void redir_empty()
{
  for (int i=0; i<MAXREDIR; i++)
    redir_i[i][0] = redir_o[i][0] = 0;
}

void redir_cmd(int n)
{

  if (!strcmpi(strv[n],"del"))
  {
    if (*strv[n+1])
    {
      unsigned i = atoi(strv[n+1]);
      if (i < MAXREDIR)
      {
        redir_i[i][0]=0;
        redir_o[i][0]=0;
        redir_x[i]=0;
        irc_reply("deleted #%i\n", i);
        return;
      }
    }
    redir_empty();
    irc_reply("deleted all\n");
    return;
  }

  if (!strcmpi(strv[n],"list"))
  {
    for (int i=0; i<MAXREDIR; i++)
      if (redir_i[i][0])
        irc_reply("%i. %s --> %s %s\n",
          i, redir_i[i], redir_o[i], redir_x[i]?"<hide>":"");
    irc_reply("---\n");
    return;
  }

  if (!strcmpi(strv[n],"add"))
  if (strc >= n+3)
  {
    for (int i=0; i<MAXREDIR; i++)
    if (redir_i[i][0] == 0)
    {
      strcpy(redir_i[i], strv[n+1]);
      strcpy(redir_o[i], strv[n+2]);
      redir_x[i] = !stricmp(strv[n+3],"hide");
      irc_reply("added #%i\n", i);
      return;
    }
    irc_reply("no space\n");
    return;
  }

}

int do_redir(char* from, char* msg)
{
  int res = 0;
  for (int i=0; i<MAXREDIR; i++)
    if (!stricmp(from, redir_i[i]))
    {
      irc_send("PRIVMSG %s :%s%s\n",
        redir_o[i], redir_x[i]?"":redir_prefix, msg);  // :
      res++;
    }
  return res;
}
