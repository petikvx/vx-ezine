/*
 * By using this file, you agree to the terms and conditions set
 * forth in the COPYING file which can be found at the top level
 * of this distribution.
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <stdint.h>
#include <fcntl.h>

typedef struct {
	char		*name;
	uint32_t	addr;
} t_label;
int cmp_label(const void *_l1, const void *_l2) {
	t_label *l1 = (t_label*)_l1, *l2 = (t_label*)l2;
	return (l1->addr - l2->addr);
}

int main(int argc, char **argv)
{
	unsigned char	*buf;
	t_label		*labels = NULL;
	int		l = 0, c, i, h, len, j, r;


	if (argc < 4 || (argc & 1)) {
		fprintf(stderr, "Usage:\n%s <file> <label> <address> ...\n", *argv);
		return 2;
	}
	
	/* read labels */
	for (i = 2; i < argc; i += 2) {
		if (argv[i] != NULL && argv[i + 1] != NULL && strcmp(argv[i], "") && strcmp(argv[i + 1], "")) {
			labels = (t_label*)realloc(labels, sizeof(t_label) * (l + 1));
			if (labels == NULL) {
				fprintf(stderr, "Out of memory!\n");
				return 2;
			}
			labels[l].name = (char*)strdup(argv[i]);
			labels[l].addr = strtol(argv[i + 1], NULL, 16);
			l++;
		}
	}
	qsort(labels, l, sizeof(t_label), cmp_label);

	r = 2;
	if ((h = open(argv[1], 0)) < 0) {
		fprintf(stderr, "Unable to open file %s\n", argv[1]);
		goto _free;
	}
	if ((len = lseek(h, 0, 2)) < 0 || lseek(h, 0, 0) < 0) {
		fprintf(stderr, "lseek failed!\n");
		goto _close;
	}
	if ((buf = (unsigned char*)malloc(len)) == NULL) {
		fprintf(stderr, "Out of memory!\n");
		goto _close;
	}
	if (read(h, buf, len) != len) {
		fprintf(stderr, "read failed!\n");
		goto _free0;
	}
	close(h);
	r = 0;
#if 0	
	for (i = 0; i < l; i++)
		fprintf(stderr, "%-16s %08x\n", labels[i].name, labels[i].addr);
#endif	
	printf("; Warning this file is automatically generated!\n");
	printf("; Size is %d bytes\n", len);
	printf("global ");
	for (i = 0; i < l; i++) {
		if (i > 0)
			printf(", ");
		printf("%s", labels[i].name);
	}
	putchar('\n');
	
	c = h = 0;
	for (i = 0; i < len; i++) {
		for (j = h; j < l; j++)
			if (i == labels[j].addr) {
				printf("\n%s:\n", labels[j].name);
				c = 0;
				h = j;
				break;
			}
		if (c == 0)
			printf("db\t");
		if (c > 0)
			putchar(',');
		printf("0x%02x", buf[i]);
		if (c == 15) {
			putchar('\n');
			c = 0;
		} else
			c++;
	}
	putchar('\n');
	fflush(stdout);

_free0:
	free(buf);
_close:
	close(h);
_free:	
	for (i = 0; i < l; i++)
		free(labels[i].name);
	free(labels);
	return r;
}
