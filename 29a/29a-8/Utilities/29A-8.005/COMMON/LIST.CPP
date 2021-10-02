
/*
  This file implements CList class,
  which is prototype for all lists used in this project.

  OnFree() method is a callback for derived classes,
  when pointers to dynamic memory are stored in the list entries.
*/

  // available only for member functions
#define ForEach( entry_s, var )              \
  for( var = (entry_s*) root;       \
       var != NULL;                          \
       var = (entry_s*) var->next )

#define ForEachInList( list, entry_s, var )       \
  for( var = (entry_s*) list.root;       \
       var != NULL;                               \
       var = (entry_s*) var->next )

#define ForEachInPList( list, entry_s, var )      \
  for( var = (entry_s*) list->root;      \
       var != NULL;                               \
       var = (entry_s*) var->next )

struct CListEntry                       // list entry prototype
{
  CListEntry* prev;                     // pointer to prev entry in list
  CListEntry* next;                     // pointer to next entry in list
//DWORD whatever;                       // data
};

class CList
{
  public:
  DWORD count;                   // # of entries
  DWORD entry_size;              // size of entry
  CListEntry* root;              // root entry
  CListEntry* tail;              // tail entry
  void (__cdecl* OnFree)(void* entry);
  CList(DWORD entry_size_0);
  ~CList();
  void Empty();                  // empty list
  void* Alloc();
  void Free(void* entry);
  void Attach(void* entry);
  void Detach(void* entry);
  void InsertAfter(void* w, void* a);  // insert w after a
}; // class CList

CList::CList(DWORD entry_size_0)
{
  count = 0;
  root = tail = NULL;
  entry_size = entry_size_0;
  OnFree = NULL;
} // CList::CList()

void CList::Empty()
{
  CListEntry* x = root;
  while(x)
  {
    CListEntry* t = x->next;
    Free(x);
    x = t;
  }
  root = tail = NULL;
  count = 0;
} // CList::Empty()

CList::~CList()
{
  Empty();
  //memset(this, 0x00, sizeof(CList));
} // CList::~CList()

void* CList::Alloc()
{
  return ZAlloc( entry_size );  // alloc + zerofill
} // CList::Alloc()

void CList::Free(void* entry)
{
  if (OnFree) OnFree(entry);
  ZFree(entry);
} // CList::Free()

void CList::Attach(void* entry)
{
  count++;

  CListEntry* t = (CListEntry*) entry;

  t->prev = tail;
  t->next = NULL;

  if (root == NULL)
    root = t;
  else
    tail->next = t;

  tail = t;

} // CList::Attach()

void CList::Detach(void* entry)
{
  CListEntry* t = (CListEntry*) entry;

  if (t == root)                // (t->prev == NULL)
    root = t->next;
  else
    t->prev->next = t->next;

  if (t == tail)                // (t->next == NULL)
    tail = t->prev;
  else
    t->next->prev = t->prev;

  t->prev = NULL;
  t->next = NULL;

  count--;

} // CList::Detach()

void CList::InsertAfter(void* w, void* a)
{
  CListEntry* x = (CListEntry*)w;
  CListEntry* y = (CListEntry*)a;
  x->next = y->next;
  x->prev = y;
  if (y->next) y->next->prev = x;
  y->next = x;
  if ((CListEntry*)tail == a) tail = (CListEntry*)w;
} // CList::InsertAfter()
