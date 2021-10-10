#define	SRC_FRAG(x)		(((x).r >> 31) & 1)		/* 0 - code, 1 - data */
#define	DST_FRAG(x)		(((x).r >> 29) & 3)		/* 0 - code, 1 - data, 2 - ext. 3 - int.  */
#define	SRC_TYPE(x)		(((x).r >> 28) & 1)		/* 0 - abs., 1 - rel. */
#define	SRC_OFF(x)		(((x).r >> 14) & 16383)		/* where to patch */
#define	DST_OFF(x)		( (x).r & 16383)		/* what to patch */

#define	MK_SRC_FRAG(R, x)	(R).r |= ((x & 1) << 31)
#define	MK_DST_FRAG(R, x)	(R).r |= ((x & 3) << 29)
#define	MK_SRC_TYPE(R, x)	(R).r |= ((x & 1) << 28)
#define	MK_SRC_OFF(R, x)	(R).r |= ((x & 16383) << 14)
#define	MK_DST_OFF(R, x)	(R).r |= (x & 16383)
#define	ADJUST_DST_OFF(R, x)	(R).r += (x & 16383)
#define	MK_FINI(R)		(R).r = 0xffffffff
#define	IS_FINI(R)		((R).r == 0xffffffff)

typedef struct {
	uint32_t r;
} reloc_t;
