#include <elf.h>
int main(int argc, char **argv)
{
	if (argc < 2)
		return 2;
	int h = open(argv[1], 2);
	Elf32_Ehdr ehdr;
	if (h < 0)
		return 2;
	pread(h, &ehdr, sizeof(Elf32_Ehdr), 0);
	ehdr.e_ident[15] = 1;
	pwrite(h, &ehdr, sizeof(Elf32_Ehdr), 0);
	close(h);
	return 0;
}
