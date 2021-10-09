/* YAD 0.10 (Yet Another Disassembler) (x) herm1t@vx.netlux.org, 2008 */
#include "yad.h"
#include "yad_data.h"

int yad(uint8_t *opcode, yad_t *diza)
{
	uint8_t c, *p, datasize, addrsize;
	uint16_t flags;
	uint32_t j, i, mod, rm, reg;
#ifndef	YAD_PACK6
	uint16_t *yad_table = (uint16_t*)(yad_data + YAD_VALUES_OFFSET);
#define	fetch(x)	yad_table[yad_data[x]]
#else
	uint16_t fetch(uint32_t i) {
		uint32_t t = *(uint32_t*)(yad_data + (((i << 1) + i) >> 2));
		if ((i &= 3) == 0)
			t >>= 2;
		else if (--i == 0)
			t = ((t & 3) << 4) | ((t >> 12) & 15);
		else if (--i == 0)
			t = ((t & 15) << 2) | ((t >> 14) & 3);
		t = (t & 63) << 1;
		return *(uint16_t*)(yad_data + YAD_VALUES_OFFSET + t);
	}
#endif
	for (i = 0; i < sizeof(yad_t); i++)
		*((char*)diza + i) = 0;
	datasize = addrsize = 4; p = opcode; flags = 0; 
	if (*(uint16_t*)p == 0x0000 || *(uint16_t*)p == 0xffff)
		diza->flags |= C_BAD;
	/* prefixes */
	for (;;) {
		c = *p++;
#define	GET_PREFIX(cond,field,expr)	\
if (cond) { if (diza->field) goto bad; diza->field = c; expr; continue; }
		GET_PREFIX(c == 0x66, p_66, datasize = 2)
		GET_PREFIX(c == 0x67, p_67, addrsize = 2)
		GET_PREFIX((c & 0xfe) == 0x64 || (c & 0xe7) == 0x26, p_seg, )
		GET_PREFIX((c & 0xfe) == 0xf2, p_rep, )
		GET_PREFIX(c == 0xf0, p_lock, )
		break;
bad:		diza->flags |= C_BAD;
#undef	GET_PREFIX
	}
	/* opcode */
	if ((diza->opcode = c) == 0x0f) {
		diza->opcode2 = *p++;
		j = 256 + diza->opcode2;
	} else
		j = c;
	/* instruction flags by opcode */
	if ((flags |= fetch(j)) == C_ERROR)
		return 0;
	/* parse ModRM and SIB, (prefix) groups, FPU */
	if (flags & (C_MODRM|C_GROUP|C_PREGRP)) {
		diza->modrm = c = *p++;
		mod = c >> 6;
		reg = (c >> 3) & 7;
		rm = c & 7;
		if (flags & (C_GROUP|C_PREGRP)) {
			i = diza->p_rep & 3;
			flags = fetch((flags & YAD_GROUP_MASK) +
				(flags & C_GROUP ? reg :
				(diza->p_66 ? 2 : i ^ (i >> 1))));
			if (flags == C_ERROR)
				return 0;
		} else
		/* check FPU instructions */
		if ((c = diza->opcode) >= 0xd8 && c <= 0xdf) {
			c -= 0xd8;
			if (mod != 3) {
				i = reg;
			} else {
				c = ((c + 1) << 3) + reg;
				i = rm;
			}
			if (yad_data[YAD_FLOAT_OFFSET + c] & (1 << i))
				return 0;
		}
		/* ModRM and SIB */
		if (mod != 3) {
			if (diza->p_67) {
				if (mod == 0 && rm == 6)
					goto sf;
			} else {
				if (rm == 4) {
					c = *p++;
					flags |= C_SIB;
					diza->sib = c;
				}
				if (mod == 0 && (rm == 5 || (diza->sib & 7) == 5))
					goto sf;
			} 
			if (mod == 1)
				flags |= C_ADDR1;
			if (mod == 2)
sf:				flags |= C_ADDR67;
		}
	}
	diza->flags |= flags;
#define	COPY_ARG(size,flag,var,save)	\
{ uint8_t a = size;			\
if (flags & flag)			\
	a += var;			\
diza->var = a;				\
for (i = 0; i < a; i++)			\
	*(&save + i) = *p++;		\
}
	COPY_ARG((flags >> 3) & 5, C_ADDR67, addrsize, diza->addr1);
	COPY_ARG(flags & 3, C_DATA66, datasize, diza->data1);
#undef	COPY_ARG
	/* check 3D Now suffix */
	if (diza->opcode == 0x0f && diza->opcode2 == 0x0f) {
		i = diza->data1;
		if (yad_data[YAD_3DNOW_OFFSET + (i >> 3)] & (1 << (i & 7)))
			return 0;
	}
	if ((diza->len = p - opcode) > 15)
		return 0;
	return diza->len;
#ifndef	PACK6
#undef	fetch
#endif
}

int yad_asm(uint8_t *opcode, yad_t *diza)
{
	int i;
	uint8_t *p = opcode;
	for (i = 0; i < 5; i++)
		if (*(&diza->p_seg + i))
			*p++ = *(&diza->p_seg + i);		
	*p++ = diza->opcode;
	if (diza->opcode == 0x0f)
		*p++ = diza->opcode2;
	if (diza->flags & C_MODRM)
		*p++ = diza->modrm;
	if (diza->flags & C_SIB)
		*p++ = diza->sib;
	for (i = 0; i < diza->addrsize; i++)
		*p++ = *(&diza->addr1 + i);
	for (i = 0; i < diza->datasize; i++)
		*p++ = *(&diza->data1 + i);
	return p - opcode;
}
