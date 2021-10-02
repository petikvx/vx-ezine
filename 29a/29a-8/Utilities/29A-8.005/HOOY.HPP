
//
// each PE EXE/DLL file is splitted by the MISTFALL engine into the
// linked list of 'struct HOOY' entries.
//

// FL_LABEL   specifies "virtual" (zero-sized) entry, other entries links to.
//
// FL_CREF    used with FL_LABEL, means that label is referenced by some
//            jxx/call/jmp/...
//
// FL_DREF    used with FL_LABEL, means that label is referenced by address
//
// FL_DATA    specifies contiguous block of bytes we dont know anything about.
//
// FL_DELTA   specifies difference between RVA of two other labels.
//            arg1/arg2 specifies addresses of these labels.
//
// FL_FIXUP   specifies relocatable VA of some entry (we assume so),
//            arg1 - contains RVA,
//            arg2 - if FL_OPCODE is specified, contains fixup offset
//                   within instruction, otherwise 0
//
// FL_RVA     specifies pointer to some label,
//            it is defined by file structure (headers, imports/exports, etc.)
//            arg1 contains address.
//
// FL_OPCODE  specifies 1st byte of some instruction
//            if FL_FIXUP is specified, then instruction contains
//            fixup somewhere in the middle,
//            and arg1/arg2 are used correspondingly
//
// FL_CODE    specifies any byte of the instruction.
//            if used without FL_OPCODE, original instruction was split
//            into two list entries (since 2.00, should happen only on errors)
//
// FL_HAVEREL instruction has relative argument, i.e. jxx, jmp/call near, ...
//
// FL_ANALYZED, FL_NEXT
//            used temporarily, while parsing codeseg into instructions
//
//

#ifndef __HOOY_HPP__
#define __HOOY_HPP__

// list entry flags

#define FL_RVA            0x00000001
#define FL_DELTA          0x00000002
#define FL_FIXUP          0x00000004
#define FL_LABEL          0x00000008
#define FL_OPCODE         0x00000010
#define FL_CODE           0x00000020
#define FL_HAVEREL        0x00000040
#define FL_CREF           0x00000080
#define FL_DREF           0x00000100
#define FL_NEXT           0x00000200
#define FL_ANALYZED       0x00000400
#define FL_SECTALIGN      0x00000800    // new section
#define FL_PHYS           0x00001000    // FL_RVA/FL_DELTA modifier, use offs instead of rva
#define FL_PRESENT        0x00002000    // physically present
#define FL_VPRESENT       0x00004000    // virtually present
#define FL_FORCEOBJALIGN  0x00008000    // used for sizeofcode & sizeofidata
#define FL_FORCEFILEALIGN 0x00010000    // used for section[i].physsize
#define FL_DATA           0x00020000
#define FL_STOP           0x00040000    // JMP/RET-alike
#define FL_SIGNATURE      0x00080000    // should be set by sigman()
#define FL_ERROR          0x10000000    // intersected objects or bad ptr
#define FL_rsrv1          0x20000000    // this and prev entries are parts of the same instruction
#define FL_HEADER         0x40000000    // dataptr is in header, not alloc()
#define FL_RES8           0x80000000    // high bit set, ==0x80000000

#pragma pack(push)
#pragma pack(1)

struct HOOY                             // list entry structure
{
  HOOY*     prev;           // used here to override CListEntry's void*
  HOOY*     next;

  DWORD     flags;          // FL_xxx
  DWORD     datalen;        // data length (0 if no data)
  BYTE*     dataptr;        // ptr to data (NULL if no data)
  DWORD     arg1;           // used with FL_RVA, FL_FIXUP & FL_DELTA
  DWORD     arg2;           // used with FL_DELTA & FL_FIXUP(fixofs)
  DWORD     oldrva;         // original RVA
  DWORD     newrva;         // unused while mutate()
  DWORD     newofs;         // unused while mutate()

  DWORD     regused;        // [NEW] xset of used registers BEFORE current instr,
                            // set by tools.cpp::h_AnalyzeRegs(CMistfall*),
                            // see also XDE

}; // struct HOOY

#pragma pack(pop)

void __cdecl CHooyListOnFree(void* entry);

class CHooyList : public CList
{
  public:
  CHooyList() : CList( sizeof(HOOY) ) { OnFree = CHooyListOnFree; }
}; // class CHooyList

#endif // __HOOY_HPP__
