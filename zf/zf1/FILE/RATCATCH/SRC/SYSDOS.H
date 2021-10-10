/////////////////////////////////////////////////////////////////////////////
// RatCatcher Beta
// Version 1.0
// ==========================================================================
// Copyright (c) 1997, Andrew "ReCoder" Kondrashov
// ==========================================================================
// SysDos : access to system DOS areas and structures
//
// Programmer : Andrew Kondrashow
// ==========================================================================
// Started at : August, 1997
/////////////////////////////////////////////////////////////////////////////

#ifndef _SYSDOS_H_
#define _SYSDOS_H_

#pragma -a-
#pragma pack ( push, 1 )

typedef struct _ebpb {
    unsigned sectsize;
    char     clustsize;
    unsigned ressecs;
    char     fatcnt;
    unsigned rootsize;
    unsigned totsecs;
    char     media;
    unsigned fatsize;
    unsigned seccnt;
    unsigned headcnt;
    unsigned hiddensec_low;
    unsigned hiddensec_high;
    unsigned long drvsecs;
} EBPB;
typedef EBPB* EBPBPTR;

typedef struct _boot {
    char    jmp [ 3 ];
    char    oem [ 8 ];
    EBPB    bpb;
    char    drive;
    char    reserved;
    char    sign;
    unsigned vol_ser_lo;
    unsigned vol_ser_hi;
    char    label [ 11 ];
    char    fat_format [ 8 ];
    char    boot_code [ 448 ];
    union
    {
        unsigned char Char2[ 2 ];
        unsigned int  Int1      ;
    } signature;
} BOOT;
typedef BOOT* BOOTPTR;

typedef struct _part_entry {
    unsigned char flag ;
    unsigned char beg_head ;
    unsigned int  beg_sec_cyl ;
    unsigned char sys ;
    unsigned char end_head ;
    unsigned int  end_sec_cyl ;
    unsigned long rel_sec ;
    unsigned long size ;
} PART_ENTRY;

typedef struct _mboot {
    char boot_prg [ 0x1BE ];
    PART_ENTRY part_table[ 4 ];
    union {
        unsigned char Char2 [ 2 ];
        unsigned int  Int1       ;
    } signature;
} MBOOT;
typedef MBOOT* MBOOTPTR;

typedef struct _mcb {
    unsigned char type;
    unsigned owner;
    unsigned size;
    char reserved[ 11 ];
} MCB;
typedef MCB* MCBPTR;

typedef struct _cvt {
    unsigned    first_mcb ;
    void far*   dev_cb;
    void far*   file_tab;
    void far*   clock_drv;
    void far*   con_drv;
    unsigned    max_btbl;
    void far*   disk_bufs;
    void far*   drv_info;
    void far*   fcb_tbl;
    unsigned    fcb_size;
    unsigned char num_bdev;
    unsigned char lastdriv;

    static _cvt far* GetCVT();
} CVT;
typedef CVT far* CVTPTR;

#define FarPtr(S,O) ((void far* ) \
    ( \
      ( \
        ( (unsigned long) (unsigned) (S) \
      ) << 16L \
    ) | \
    ( \
      (unsigned long)(unsigned)(O) \
    ) \
)
#define UInt(P) (*((unsigned int*)(P)))
#define Int(P)  (*((signed   int*)(P)))

typedef struct _exehdr {
    unsigned signature;    // + 0x0
    unsigned part_page;    // + 0x2
    unsigned file_size;    // + 0x4
    unsigned rel_item;     // + 0x8
    unsigned hdr_size;     // + 0xA
    unsigned min_mem;      // + 0xC
    unsigned max_mem;      // + 0xE
    unsigned ss_reg;       // + 0x10
    unsigned sp_reg;       // + 0x12
    unsigned chk_sum;      // + 0x14
    unsigned ip_reg;       // + 0x16
    unsigned cs_reg;       // + 0x18
    unsigned relt_off;     // + 0x1A
    unsigned overlay;      // + 0x1C

    long GetEntryPoint();

} EXEHDR;
typedef EXEHDR* EXEHDRPTR;

typedef struct _drvhdr {
    unsigned next_ofs;
    unsigned next_seg;
    unsigned attrib;
    unsigned strategy;
    unsigned intrpt;
    char name[ 8 ];
} DRVHDR;
typedef DRVHDR* DRVHDRPTR;

#pragma pack ( pop, 1 )

BOOL IsFile( LPCTSTR lpszFileName );

#endif