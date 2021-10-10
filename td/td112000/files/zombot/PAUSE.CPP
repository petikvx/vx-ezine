
int do_pause()
{
  irc_send("PING %s\n", irc_caller);
  char t[1024];                  //
  strcpy(t, irc_recvstr);        // backup
  for (;;)
  {
    irc_recvline();
    if (irc_error) return 0;
    if (irc_rpl==ERR_NOSUCHNICK) return 0;
    if (!strcmpi(strv[3], "$stop")) return 0;
    if (!strcmpi(strv[1], "PONG")) break;
  }
  strcpy(irc_recvstr, t);        // restore
  irc_parse();                   //
  return 1;
}
