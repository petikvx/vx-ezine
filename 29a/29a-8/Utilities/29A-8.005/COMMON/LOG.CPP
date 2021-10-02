
//#define LOG_TO_FUNC
//#define LOG_TO_CONSOLE
//#define LOG_TO_DEBUGGER

extern "C++"  // req
void log(char* fmt, ...)
{
  va_list va;
  va_start(va, fmt);
  char s[1024];
  vsnprintf(s, sizeof(s)-1, fmt, va);
  va_end(va);

#ifdef LOG_TO_FUNC
  log_out(s);
#endif

#ifdef LOG_TO_FILE
  FILE*f=fopen(LOG_TO_FILE,"a+");
  if (f==NULL)
  {
    snprintf(s, sizeof(s)-1, "ERROR:CAN NOT WRITE TO LOG FILE " LOG_TO_FILE "\n");
  }
  else
  {
    fprintf(f, "%s", s);
    fclose(f);
  }
#endif // LOG_TO_FILE

#ifdef LOG_TO_CONSOLE
  printf("%s", s);
#endif // LOG_TO_CONSOLE

#ifdef LOG_TO_DEBUGGER
  OutputDebugString(s);
#endif // LOG_TO_DEBUGGER

} // log()
