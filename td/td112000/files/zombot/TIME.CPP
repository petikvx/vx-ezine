
char irc_gettime_tmp[32];                        // used by irc_gettime()

char* irc_time2str(SYSTEMTIME& st)
{
  sprintf(irc_gettime_tmp, "%02i/%02i/%04i %02i:%02i:%02i",
    st.wDay, st.wMonth, st.wYear,
    st.wHour,st.wMinute,st.wSecond);
  return irc_gettime_tmp;
}

char* irc_gettime()
{
  SYSTEMTIME st;
  GetLocalTime(&st);
  return irc_time2str(st);
}
