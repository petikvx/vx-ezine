#include <stdio.h>

int main(int argc, char **argv)
{
	FILE *f = fopen("lib.txt", "r");
	char s[32];
	char strtab[1024];
	int strp = 0, count = 0, i;
	int off[1024];
	if (f == NULL)
		return 2;
	while (fgets(s, 32, f) != NULL) {
		s[strlen(s) - 1] = '\0';
		memcpy(strtab + strp, s, strlen(s) + 1);
		printf("#define\t%s(...)\t((int(*)())libc_call(%d))(__VA_ARGS__)\n", s, count);
		off[count] = strp;
		strp += strlen(s) + 1;
		count ++;
	}
	printf("uint32_t v_got_plt[%d];\n", count);
	printf("char v_dyn_str[%d] = {\n", strp);
	for (i = 0; i < strp; i++) {
		if (i % 16 == 15)
			putchar('\n');
		printf("%d,", strtab[i]);
	}
	printf("\n};\n");
	printf("char v_dyn_off[%d] = {\n", count);
	for (i = 0; i < count; i++) { printf("%d, ", off[i]); }
	printf("\n};\n");
}
