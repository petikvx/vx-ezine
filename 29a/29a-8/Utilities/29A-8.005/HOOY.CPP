
/*
  This file implements CHooyList class,
  which is used to manipulate
  with disassembly list entries of type HOOY.
*/

//#define LOG_HOOY

#include "hooy.hpp"

void __cdecl CHooyListOnFree(void* entry)
{
  HOOY*t = (HOOY*)entry;
  if ((t->flags & FL_HEADER)==0)
    ZFreeV((void**)&t->dataptr);
} // CHooyList::OnFree()
