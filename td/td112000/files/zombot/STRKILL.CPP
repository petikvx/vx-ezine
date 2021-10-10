
// fill substr within target with '*'
void strkill(char* target, char* substr)
{
  for (;;)
  {
    char *c = strstri(target, substr);
    if (!c) return;
    setmem(c, strlen(substr), '*');
  }
}

// fill password within given string with '*'
// use it before output strings to IRC/LOG
void strkillpsw(char* t)
{
  strkill(t, irc_psw);
}
