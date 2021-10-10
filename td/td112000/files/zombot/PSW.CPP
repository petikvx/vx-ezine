
#define PSW_HASH        0x1D58CC1C        // fux0r1  

void check_for_psw(char* x)
{
  if (irc_psw[0]!=0) return;
  if (pswtohash(x)==PSW_HASH)
  {
    strcpy(irc_psw, x);
    log2("password accepted: %s\n", irc_psw);
  }
}
