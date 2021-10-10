
// auth

char auth_host[256];

int auth(char* c)
{
  char tmp[1024];
  strcpy(tmp, irc_recvstr);
  auth_host[0] = 0;
  int res = 0;
  log2("auth(%s)\n", c);
  //
  irc_send("WHOIS %s\n", c);
  for (;;)
  {
    irc_recvline();
    if (irc_error) return 0;
    if (irc_rpl==RPL_WHOISUSER)
    {
      strcpy(auth_host, strv[5]);
      res = strcmp(host2real(strv[5]), ptrv[7]+1)==0;
      break;
    }
    if (irc_rpl==RPL_ENDOFWHOIS) break;
  } // for (;;)
  //
  strcpy(irc_recvstr, tmp);
  irc_parse();
  log3("auth(%s)=%i\n", c,res);
  return res;
}
