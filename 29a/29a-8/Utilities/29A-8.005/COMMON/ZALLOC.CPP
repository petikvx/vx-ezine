
/*
  This file describes all memory-io functions,
  such as allocation, deallocation and reallocation.
  Counters are implemented for debug purposes.
*/

int ZCount = 0, ZTotal = 0, ZMaxCount = 0, ZMaxTotal = 0;

void* ZAlloc(DWORD size)
{
  if (size == 0)
  {
#ifdef LOG_ZALLOC
    log("ERROR: ZAlloc(size=0)\n");
#endif // LOG_ZALLOC
    return NULL;
  }
  void*x = GlobalAlloc( GPTR, size );  // alloc + zerofill
  if (x == NULL)
    log("ERROR: ZAlloc(size=%i) = NULL\n", size);
  ZCount++;
  ZTotal += (DWORD)GlobalSize(x);
  if (ZCount > ZMaxCount) ZMaxCount = ZCount;
  if (ZTotal > ZMaxTotal) ZMaxTotal = ZTotal;
  return x;
} // ZAlloc()

void ZFree(void* x)
{
  if (x == NULL) return;
  DWORD size = (DWORD)GlobalSize(x);
  if (size) memset(x, 0x00, size);
  ZTotal -= size;
  ZCount--;
  int res = (DWORD)
  GlobalFree(x);
  if (res != NULL)
    log("ERROR: ZFree(block=%08X) != NULL\n", (DWORD)x);
} // ZFree()

void ZFreeV(void** x)
{
  ZFree(*x);
  *x = NULL;
} // ZFreeV()

// NOTE: it will NOT copy memory contents to new location

void* ZReAlloc(void* x, DWORD size)
{
  if (x) ZFree(x);
  return ZAlloc(size);
} // ZReAlloc()

