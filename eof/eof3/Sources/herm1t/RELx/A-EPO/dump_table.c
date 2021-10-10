#include <stdio.h>
#include <stdint.h>
#include <elf.h>
#include <sys/mman.h>


int main(int argc, char **argv)
{
	int i;
	if (argc < 2)
		return 1;
	int h = open(argv[1], 0);
	if (h < 0)
		return 1;
	int l = lseek(h, 0, 2);
	uint8_t *m = mmap(NULL, l, PROT_READ, MAP_SHARED, h, 0);
	Elf32_Ehdr *ehdr = (Elf32_Ehdr*)m;
	Elf32_Phdr *phdr = (Elf32_Phdr*)(m + ehdr->e_phoff);
	for (i = 0; i < ehdr->e_phnum; i++) {
		if (phdr[i].p_type == PT_LOAD) {
			uint32_t *p = m + phdr[i].p_offset;
			switch (*p) {
				case 0x1BADF00D:
					printf("I am a bad food!\n");
					goto header_info;
				case 0xFEEDF00D:
					printf("In progresss...\n");
					int j;
					for (j = 0; j < p[1]; j++)
						printf("%08x %04x %d\n", p[2 + j*2], p[3 + j*2] >> 16, p[3 + j*2] & 0xffff);
					goto header_info;
				case 0xDEADBEEF:
					printf("Done\n");
header_info:				printf("Header size %d, table size %d\n", phdr[i].p_filesz, p[1]);
					break;
				default:
					break;
			}
		}
	}
	return 0;
}
