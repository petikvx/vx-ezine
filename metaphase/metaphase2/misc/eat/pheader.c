#include <stdio.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <elf.h>

main(int argc, char *argv[])
{

Elf32_Ehdr ehdr;			/* ELF Header */
Elf32_Shdr *shdr;			/* Section Header */
Elf32_Phdr phdr;			/* Program Header */
int i;					/* */
int fd;					/* File descriptor */

FILE *fp;

if(argc < 2){goto usage;}


fp = fopen(argv[1],"rwb+");
fread(&ehdr,sizeof(ehdr),1,fp);

if (
	ehdr.e_ident[0] != ELFMAG0 ||
	ehdr.e_ident[1] != ELFMAG1 ||
	ehdr.e_ident[2] != ELFMAG2 ||
	ehdr.e_ident[3] != ELFMAG3
)
{ not_elf(); }

rewind(fp);

for(i=0;i < ehdr.e_phnum;i++)
{

fseek(fp,(ehdr.e_phoff+(i*ehdr.e_phentsize)),SEEK_SET);
fread(&phdr,ehdr.e_phentsize,1,fp);

printf("===== Program Header Table Entry #%d =====\n",(i+1));

printf("Segment Type: ");
if(phdr.p_type == 0){printf("Unused Segment (PT_NULL)\n");}
if(phdr.p_type == 1){printf("Loadable Segment (PT_LOAD)\n");}
if(phdr.p_type == 2){printf("Dynamic Linking Information (PT_DYNAMIC)\n");}
if(phdr.p_type == 3){printf("Path to Interpreter (PT_INTERP)\n");}
if(phdr.p_type == 4){printf("Path to Auxiliary information (PT_NOTE)\n");}
if(phdr.p_type == 5){printf("Reserved. does not conform to ABI. (PT_SHLIB)\n");}
if(phdr.p_type == 6){printf("Program Header Table index (PT_PHDR)\n");}

printf("File offset: %x\n",phdr.p_offset);
printf("Virtual address: %x\n",phdr.p_vaddr);
printf("Physical address: %x\n",phdr.p_paddr);
printf("Section size: %x\n",phdr.p_filesz);
printf("Memory Size: %x\n",phdr.p_memsz);
printf("Flags: %x\n",phdr.p_flags);
printf("alignment: %x\n",phdr.p_align);
printf("\n");

}

fclose(fp);
exit(0);

usage:
printf("\nELF Program Header Table Reader v 0.04a (sblip)\n");
printf("usage: pheader <file>\n");
exit(-1);
}

not_elf()
{
printf("\nThis file is not a valid elf object file\n");
exit(-1);
}


