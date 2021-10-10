
FILETIME t_wakeup;

int sleep_read()
{
  DWORD a = sizeof(t_wakeup);
  return RegQueryValueEx(HKEY_LOCAL_MACHINE, "WakeUp",
                         0, 0, (char*)&t_wakeup, &a) == ERROR_SUCCESS;
}

void sleep_write()
{
  RegSetValueEx(HKEY_LOCAL_MACHINE, "WakeUp",
                0, REG_BINARY, (char*)&t_wakeup, sizeof(t_wakeup));
}


// n [sec]
void sleep_setdelta(int n)
{
  GetSystemTimeAsFileTime(&t_wakeup);

  while (n--)
    *(__int64*)&t_wakeup += 10000000;   // sec --> 100*nanosec

  sleep_write();
}

void sleep_main()
{
  if (!sleep_read()) return;

  for (;;)
  {
    FILETIME t_curr;
    GetSystemTimeAsFileTime(&t_curr);
    if (CompareFileTime(&t_curr, &t_wakeup) >= 0) break;
    Sleep(1000); // 1 s
  }
}
