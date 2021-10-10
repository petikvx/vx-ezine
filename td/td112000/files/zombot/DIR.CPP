
int mustexit, recurse, folders, totalcount, totalsize, linecount;

void real_dir(char* path)
{
  if (mustexit) return;
  folders++;
  char t[1024];
  strcpy(t, path);
  if (!t[0]) strcpy(t,".");
  if (t[strlen(t)-1] != '\\') strcat(t, "\\");
  strcat(t, "*.*");
  irc_reply("directory of %s\n", t);
  linecount++;
  WIN32_FIND_DATA ff;
  HANDLE h = FindFirstFile(t, &ff);
  if (h == INVALID_HANDLE_VALUE)
  {
    irc_reply("--- no files found\n");
    linecount++;
    return;
  }
  int localcount = 0, localsize = 0;
  for (;;)
  {
    char a[9] = "--------";
    DWORD d = ff.dwFileAttributes;
    if (d & FILE_ATTRIBUTE_DIRECTORY)  a[0] = 'D';
    if (d & FILE_ATTRIBUTE_HIDDEN)     a[1] = 'H';
    if (d & FILE_ATTRIBUTE_SYSTEM)     a[2] = 'S';
    if (d & FILE_ATTRIBUTE_READONLY)   a[3] = 'R';
    if (d & FILE_ATTRIBUTE_ARCHIVE)    a[4] = 'A';
    if (d & FILE_ATTRIBUTE_COMPRESSED) a[5] = 'C';
    if (d & FILE_ATTRIBUTE_OFFLINE)    a[6] = 'O';
    if (d & FILE_ATTRIBUTE_TEMPORARY)  a[7] = 'T';
    SYSTEMTIME st;
    FileTimeToSystemTime(&ff.ftLastWriteTime, &st);
    char sz[32];
    itoa(ff.nFileSizeLow, sz, 10);
    irc_reply("%12s %8s %s %s %s\n",
      ff.cAlternateFileName[0]!=0 ? ff.cAlternateFileName : ff.cFileName,
      (d & FILE_ATTRIBUTE_DIRECTORY) ? "<DIREC>" : sz,
      a,
      irc_time2str(st),
      ff.cAlternateFileName[0]!=0 ? ff.cFileName : "");
    localcount++;
    totalcount++;
    localsize += ff.nFileSizeLow;
    totalsize += ff.nFileSizeLow;
    if (linecount++>=MAXLINES)
    {
      linecount = 0;
      if (!do_pause())
      {
        mustexit++;
        break;
      }
    }
    if (!FindNextFile(h, &ff)) break;
  }
  FindClose(h);
  irc_reply("--- %i files, %i bytes\n", localcount, localsize);
  linecount++;

  if (!recurse) return;

  h = FindFirstFile(t, &ff);
  if (h == INVALID_HANDLE_VALUE) return;
  for (;;)
  {
    if (ff.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY)
    if (strcmp(ff.cFileName,"."))
    if (strcmp(ff.cFileName,".."))
    {
      strcpy(t, path);
      if (t[strlen(t)-1] != '\\') strcat(t, "\\");
      strcat(t, ff.cFileName);
      real_dir(t);
      if (mustexit) break;
    }
    if (!FindNextFile(h, &ff)) break;
  }
  FindClose(h);

} // real_dir

void do_dir(int n)
{
  linecount = totalcount = totalsize = folders = mustexit = 0;
  recurse = !stricmp(strv[n+1], "/s");
  real_dir(strv[n]);
  if (recurse)
    irc_reply("--- %i files, %i bytes, %i folders\n", totalcount, totalsize, folders);
}
