
DWORD pswtohash(char* x)
{
  DWORD hash=0;
  while (*x)
  {
    hash = ((hash + *x) * (hash - *x)) ^ 0xBABEFACC;
    x++;
  }
  return hash;
}
