
//#define DEBUG_PRINTF            // status messages
//#define DEBUG_DUMPLIST
//#define DEBUG_DUMP_FILES

#define MAXCMDLEN       16      // max length of command: 16 bytes
#define NONE            0xFFFFFFFF

#define FASTHOOY        // fast entrylist post-process (Z5: +256k of memory!)

  // engine() return codes
#define ERR_SUCCESS     0       // success, code permutated
#define ERR_DISASM      1       // cant disassemble instruction
#define ERR_SMALLBUF    2       // not enough space in output buffer
#define ERR_NOMEMORY    3    // not enough memory (user_malloc returned NULL)
#define ERR_NOTPROGRAMMED 4     // some situation not programmed yet
#define ERR_BADJMP      5       // bad relative jmp/call within src buffer

  // states of imap[] array
#define C_NONE          '-'     // empty (no code here)
#define C_NEXT          'N'     // to be analyzed
#define C_CODE          'c'     // alredy analyzed, code

  // hooy.flags
#define CM_STOP         1       // JMP/RET-alike instruction
#define CM_HAVEREL      2       // have relative argument (JMP,JCC,CALL,etc.)
#define CM_EXTREL       4       // rel. arg points to external label
#define CM_ASSEMBLED    8       // alredy assembled
#define CM_XREF         16      // label, i.e. have XREF

/* |<--SPACE_START--> [code] <--SPACE_BETWEEN--> [code] <--SPACE_END-->| */
#define SPACE_START     32
#define SPACE_BETWEEN   32
#define SPACE_END       32

#define NTRY  1000 // try to find new ip NTRY times, then return ERR_SMALLBUF

  // instruction list entry structure
struct hooy
{
  BYTE          cmd[MAXCMDLEN]; // opcode
  BYTE*         ofs;            // pointer to current location (temporary)
  DWORD         len;            // length of command
  DWORD         flags;          // CM_xxx
  hooy*         rel;      // CM_HAVEREL: 0=NULL 1= CM_EXTREL: 0=hooy* 1=BYTE*
  hooy*         nxt;            // CM_STOP: 1=NULL 0=hooy* (opcode 'thread')
  hooy*         next;           // next entry or NULL (all list)
};
