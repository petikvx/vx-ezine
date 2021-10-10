
int is_oper(char* c)
{
  if (strstri("undernet", irc_server_name))
  {
    if (!strcmpi(c, "X")) return 1;
    if (!strcmpi(c, "W")) return 1;
  }
  return 0;
}

void kix0r(char* chan, char* nick)
{
  if (is_oper(nick)) return;

  irc_send("KICK %s %s :.\n", chan, nick);
  irc_send("MODE %s +b %s!*@*\n", chan, nick);
}

// kill sucker
void do_flood(char* sucker)
{
  if (is_oper(sucker)) return;

  irc_broadcast(2, "$flood %s\n", sucker);
}

// input: irc_recvstr

void aictrl()
{

  // if somebody joins any channel i'm on
  if (!strcmpi(strv[1], "JOIN"))
  if (strcmp(irc_caller, irc_user_nick))        // its not me
  {
    if (auth(irc_caller))
    {
      brolist_add(irc_caller, auth_host);
      irc_send("MODE %s +o %s\n", strv[2]+1, irc_caller);  // +1 to skip ':'
      irc_send("PRIVMSG %s :$brother\n", irc_caller);      // auth
    }
  }

  if (!strcmpi(strv[1], "PRIVMSG"))
  if (!strcmpi(strv[2], irc_user_nick))
  {
    // auth
    if (!strcmpi(strv[3], ":$brother"))
      if (auth(irc_caller))
        brolist_add(irc_caller, auth_host);
  }

  // somebody kicked me ?
  if (!strcmpi(strv[1], "KICK"))
  {
    if (!strcmpi(strv[3], irc_user_nick)) // kicked me
    {
      brolist_init();
      irc_send("JOIN %s\n", strv[2]);
      do_flood(irc_caller);
    }
    else
      if (  is_brolist(strv[3])  ||          // kicked my brother
            auth(strv[3])        )
      {
        brolist_del(strv[3]);
        kix0r(strv[2], irc_caller);
      }
  }

  // somebody deopped me ?
  if (!strcmpi(strv[1], "MODE"))
  if (!strcmpi(strv[3], "-o"))
  {
    if (!strcmpi(strv[4], irc_user_nick)) // deopped me
    {
      do_flood(irc_caller);
    }
    else
      if ( is_brolist(strv[4])  ||         // deopped my brother
           auth(strv[4])        )
      {
        irc_send("MODE %s +o %s\n", strv[2], strv[4]);  // give op back
        kix0r(strv[2], irc_caller);
      }
  }

  if (!strcmpi(strv[1], "QUIT"))
  if (!strcmpi(irc_caller, irc_forward))
  {
    irc_forward[0]=0;
  }

  // brother's quitting?
  if (  (!strcmpi(strv[1], "QUIT"))  ||
        (!strcmpi(strv[1], "PART"))    )
  {
    if (is_brolist(irc_caller))
    {
      brolist_del(irc_caller);
    }
  }

  // handle brothers' nick change
  if (!strcmpi(strv[1], "NICK"))
  if (is_brolist(irc_caller))
  {
    brolist_ren(irc_caller, strv[2]+1);
  }

  // ban protect
  if (!strcmpi(strv[1], "MODE"))
  if (!strcmpi(strv[3], "+b"))
  {
    if (brolist_matchban(ptrv[4]))
    {
      irc_send("MODE %s -b %s\n", strv[2], ptrv[4]);
      kix0r(strv[2], irc_caller);
    }
  }

  // NO DEFAULT MSGS!!!

} // aictrl()
