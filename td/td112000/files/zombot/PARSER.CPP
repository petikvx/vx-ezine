
#define PARSER_MAXSTR   256

int   strc;                     // # of params
char* strv[PARSER_MAXSTR];      // ptr to param in strs, with 0 at end
char* ptrv[PARSER_MAXSTR];
char  strx[1024];               // irc_recvstr() copy, patched with 0s

void irc_parsestr(char* s)
{
  s = strcpy(strx, s);
  strc = 0;

  for (;;)
  {
    while (*s==32) s++;
    if (!*s) break;
    (DWORD)ptrv[strc] = (DWORD)s + (DWORD)&irc_recvstr - (DWORD)&strx;
    strv[strc++] = s;
    if (strc>=PARSER_MAXSTR) break;
    while ((*s)&&(*s!=32)) s++;
    if (!*s) break;
    *s++=0;
  }

  int i = strc;
  while (i<PARSER_MAXSTR)
    strv[i] = ptrv[i++] = "";
}

void irc_parse()
{
  irc_parsestr(irc_recvstr);

  // irc_caller == caller's name, when somebody /PRIVMSG us
  // used by irc_reply()
  strcpy(irc_caller, strv[0]+1);        // skip ':'
  killchar(irc_caller,'!');
  killchar(irc_caller,'@');

  irc_rpl = atoi(strv[1]);              // 3-byte numeric reply/errmsg
}
