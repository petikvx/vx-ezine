//께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께
//OUTPUT
//께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께

typedef  struct {

                BYTE		lc_size;	//command size
                BYTE		lc_psize;	//prefixes size

                DWORD		lc_flags;	//prefix flags & other
                BYTE		lc_tttn;	//tttn

                BYTE		lc_sib;		//sib
                BYTE		lc_modrm;	//modrm

		BYTE		lc_reg;		//reg
                BYTE		lc_mod;		//mod
                BYTE		lc_ro;		//r/o
                BYTE		lc_rm;		//r/m

                BYTE		lc_base;	//base
                BYTE		lc_index;	//index
                BYTE		lc_scale;	//scale

                DWORD		lc_offset;	//offset

                BYTE		lc_operand[6];  //operand

                BYTE		lc_soffset;	//offset's size
                BYTE		lc_soperand;	//operand's size

		BYTE		lc_mask1;	//command mask
		BYTE		lc_mask2;       //
		} cmd;

//께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께
//LC_FLAGS:
//께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께

// PREFIXES

#define	LF_PCS     0x00000001
#define	LF_PDS     0x00000002
#define	LF_PES     0x00000004
#define	LF_PSS     0x00000008
#define	LF_PFS     0x00000010
#define	LF_PGS     0x00000020
#define	LF_POP     0x00000040
#define	LF_POF     0x00000080
#define	LF_PLOCK   0x00000100
#define	LF_PREPZ   0x00000200
#define	LF_PREPNZ  0x00000400

#define	LF_MODRM   0x80000000
#define	LF_SIB     0x40000000
#define	LF_OFFSET  0x20000000
#define	LF_OPERAND 0x10000000

#define	LF_REG     0x08000000
#define	LF_REG1    0x04000000
#define	LF_REG2    0x02000000
#define	LF_BASE    0x01000000
#define	LF_INDEX   0x00800000

#define	LF_MEM     0x00400000
#define	LF_TTTN    0x00200000
#define	LF_RAW	   0x00100000
                                  
#define	LF_D	   0x00008000
#define	LF_S	   0x00004000
#define	LF_SDV     0x00002000
#define	LF_W       0x00001000
#define	LF_WV      0x00000800


//께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께
//DESCRIPTOR FORMAT
//께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께
//        旼컴컴컴컴쩡컴쩡컴쩡컴쩡컴쩡컴崙컴쩡컴쩡컴컴컴컴컴쩡컴쩡컴쩡컴?
//        ?         ?   ?   ?   ?   ?   ?   ?   ?           ?   ?   ?   ?
//        ? 7  6  5 ? 4 ? 3 ? 2 ? 1 ? 0 ? 7 ? 6 ? 5   4   3 ? 2 ? 1 ? 0 ?
//        ?         ?   ?   ?   ?   ?   ?   ?   ?           ?   ?   ?   ?
//        읕컴컫컴컴좔쩡좔쩡좔쩡좔쩡좔컴崙쩡좔쩡좔컴컴쩡컴컴좔쩡좔쩡좔쩡?
//             ?      ?   ?   ?   ?       ?   ?       ?       ?   ?   ?
//             ?      ?   ?   ?   ?       ?   ?       ?       ?   ?   ?
//             ?      ?   ?   ?   ?       ?   ?       ?       ?   ?   ?
//LFD_MASKX   켸      ?   ?   ?   ?       ?   ?       ?       ?   ?   ?
//LFD_MODRM   컴컴컴컴?   ?   ?   ?       ?   ?       ?       ?   ?   ?
//                        ?   ?   ?       ?   ?       ?       ?   ?   ?
//LFD_COP_ART 컴컴컴컴컴컴?   ?   ?       ?   ?       ?       ?   ?   ?
//LFD_COP_F   컴컴컴컴컴컴컴컴?   ?       ?   ?       ?       ?   ?   ?
//LFD_0F      컴컴컴컴컴컴컴컴컴컴?       ?   ?       ?       ?   ?   ?
//                                        ?   ?       ?       ?   ?   ?
//LFD_D       컴컴컴컴컴컴컴컴컴컴컴컴컴컴?   ?       ?       ?   ?   ?
//LFD_CFLAGS  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?       ?       ?   ?   ?
//                                                    ?       ?   ?   ?
//LFD_OP_V    컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?       ?   ?   ?
//LFD_OP_MEM  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?   ?   ?
//LFD_PREFIX  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?   ?
//LFD_TTTN    컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
                                                                     
#define	LFD_MASK4   0x6000//          0110000000000000b
#define	LFD_MASK5   0x8000//          1000000000000000b
#define	LFD_MASK6   0xA000//          1010000000000000b
#define	LFD_MASK7   0xC000//          1100000000000000b
#define	LFD_MASK8   0xE000//          1110000000000000b

#define	LFD_MODRM   0x1000//          0001000000000000b

#define	LFD_COP_ART 0x800 //          0000100000000000b
#define	LFD_COP_F   0x400 //          0000010000000000b
#define	LFD_0F      0x200 //          0000001000000000b

#define	LFD_S       0x00  //          0000000000000000b	; 0 - S
#define	LFD_D       0x80  //          0000000010000000b	; 1 - D
#define	LFD_CFLAGS  0x40  //          0000000001000000b

#define	LFD_OP_V1   0x8   //          0000000000001000b
#define	LFD_OP_V2   0x10  //          0000000000010000b
#define	LFD_OP_V3   0x18  //          0000000000011000b
#define	LFD_OP_V4   0x20  //          0000000000100000b
#define	LFD_OP_V6   0x30  //          0000000000110000b
#define	LFD_OP_VX   0x38

#define	LFD_OP_MEM  0x4
#define	LFD_PREFIX  0x2
#define	LFD_TTTN    0x1

