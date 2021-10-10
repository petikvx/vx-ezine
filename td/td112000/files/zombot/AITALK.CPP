
// simple talk

void aitalk(int onchan, char* c)
{
  if (onchan)                           // answere on chan only if nick used
    if (!strstri(c, irc_user_nick))
      return;

  if (  ((strlen(c)<5)&&strstri(c,"hi"))    ||
        strstri(c,"hey")     ||
        strstri(c,"hello")   ||
        strstri(c,"howdy")
     )
  {
    irc_reply("hi\n");
    return;
  } // hi

  if (  (strstri(c,"who")!=0) +
        (strstri(c,"are")!=0) +
        (strstri(c,"you")!=0) +
        (strstri(c,"is")!=0)  +
        (strstri(c,"bot")!=0) >= 2  )
  {
    irc_reply("i'm bot\n");
    return;
  }

  if ( strstri(c,"fuck") ||
       strstri(c,"suck") ||
       strstri(c,"kick") ||
       strstri(c,"sux")
     )
  {
    irc_reply("you're now known as apocasiphilytical dogfukker\n");
    return;
  }

  // other shit removed

  // NO DEFAULT MSGS!!!

} // aitalk()
