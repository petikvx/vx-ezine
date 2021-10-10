/*
 * By using this file, you agree to the terms and conditions set
 * forth in the COPYING file which can be found at the top level
 * of this distribution.
 */
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <assert.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

typedef unsigned char uchar;
extern int ari_compress(uchar *src, uchar *dst, int src_len, uchar *temp);
extern int lzw_compress(uchar *src, uchar *dst, int src_len, uchar *temp);
extern int rle_compress(uchar *src, uchar *dst, int src_len);
extern int ari_expand(uchar *src, uchar *dst, uchar *temp);
extern int lzw_expand(uchar *src, uchar *dst, uchar *temp);
extern int rle_expand(uchar *src, uchar *dst, int length);

uint32_t crc32(unsigned char *block, unsigned int length);
void crc32_gentab(void);

const char *names[3] = { "ARI", "LZW", "RLE" };
unsigned char temp[91000];

int compress(int type, unsigned char *src, unsigned char *dst, int length)
{
	if (type == 0)
		return ari_compress(src, dst, length, temp);
	else if (type == 1)
		return lzw_compress(src, dst, length, temp);
	else if (type == 2)
		return rle_compress(src, dst, length);
	else
		return 0;
}

int expand(int type, unsigned char *src, unsigned char *dst, int length)
{
	if (type == 0)
		return ari_expand(src, dst, temp);
	else if (type == 1)
		return lzw_expand(src, dst, temp);
	else if (type == 2)
		return rle_expand(src, dst, length);
}

int main(int argc, char **argv)
{
	int		h, l, i, r, cs, ds;
	unsigned char	*src, *dst, *new;
	uint32_t	crc1, crc2;
	
	crc32_gentab();
	
	r = 2;
	if ((h = open(argv[1], 0)) < 0) {
		fprintf(stderr, "Failed to open the file '%s'\n", argv[1]);
		goto __return;
	}
	if ((l = lseek(h, 0, 2)) < 0 || lseek(h, 0, 0) < 0) {
		fprintf(stderr, "lseek...\n");
		goto __close;
	}
	if ((src = (unsigned char*)malloc(l)) == NULL) {
		fprintf(stderr, "OOM!\n");
		goto __close;
	}
	if ((dst = (unsigned char*)malloc(l)) == NULL) {
		fprintf(stderr, "OOM!\n");
		goto __free0;
	}
	if ((new = (unsigned char*)malloc(l)) == NULL) {
		fprintf(stderr, "OOM!\n");
		goto __free1;
	}	
	if (read(h, src, l) != l) {
		fprintf(stderr, "read\n");
		goto __free2;
	}
	r = 0;

	printf("File: %s\n", argv[1]);
	crc1 = crc32(src, l);
	for (i = 0; i < 3; i++) {
		memset(dst, 0, l);
		memset(new, 0, l);

		fprintf(stderr, "%s:C", names[i]);
		fflush(stderr);
		cs = compress(i, src, dst, l);
		if (cs == 0) {
			fprintf(stderr, "\tcompression failed\n");
			continue;
		} else {
			fprintf(stderr, "X");
			fflush(stderr);
			ds = expand(i, dst, new, cs);
			assert(ds == l);
	
			crc2 = crc32(new, l);
			if (crc1 != crc2) {
				fprintf(stderr, "checksum failed\n");
				continue;
			}
			printf("\t%-6d %-6d %-2d%% %s\n", l, cs, cs * 100 / l, argv[1]);
			fflush(stdout);
		}
	}
__free2:
	free(new);
__free1:
	free(dst);
__free0:
	free(src);
__close:
	close(h);
__return:
	return r;
}

uint32_t crc_tab[256];
uint32_t crc32(unsigned char *block, unsigned int length)
{
   register unsigned long crc;
   unsigned long i;

	crc = 0xFFFFFFFF;
	for (i = 0; i < length; i++)
		crc = ((crc >> 8) & 0x00FFFFFF) ^ crc_tab[(crc ^ *block++) & 0xFF];
	return (crc ^ 0xFFFFFFFF);
}
void crc32_gentab(void)
{
	unsigned long crc, poly;
	int i, j;
	poly = 0xEDB88320L;
	for (i = 0; i < 256; i++) {
		crc = i;
		for (j = 8; j > 0; j--) {
			if (crc & 1)
				crc = (crc >> 1) ^ poly;
			else
				crc >>= 1;
		}
		crc_tab[i] = crc;
   	}
}
