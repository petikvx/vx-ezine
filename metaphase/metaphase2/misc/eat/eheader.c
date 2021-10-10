#include <stdio.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <elf.h>

main(int argc, char *argv[])
{

Elf32_Ehdr ehdr;			/* ELF Header */
Elf32_Shdr *shdr;			/* Section Header */
Elf32_Phdr *phdr;			/* Program Header */
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

printf("\n");

printf("ELF header for %s\n",argv[1]);
printf("  ELF id: %x %c %c %c\n",ehdr.e_ident[0],ehdr.e_ident[1],ehdr.e_ident[2],ehdr.e_ident[3]);

/* printf("  File Class: %x",ehdr.e_ident[4]); */
printf("  File Class: ");
if(ehdr.e_ident[4] ==  ELFCLASSNONE){printf("invalid class\n");}
if(ehdr.e_ident[4] == ELFCLASS32){printf("32-bit object\n");}
if(ehdr.e_ident[5] == ELFCLASS64){printf("64-bit object\n");}

printf("  Data Encoding: ");
if(ehdr.e_ident[5] == ELFDATANONE){printf("Invalid data encoding\n");}
if(ehdr.e_ident[5] == ELFDATA2LSB){printf("Little endian (LSB)\n");}
if(ehdr.e_ident[5] == ELFDATA2MSB){printf("Big endian (MSB)\n");}

printf("  File Version: %x\n",ehdr.e_ident[6]);

printf("Object File Type: ");
if(ehdr.e_type == ET_NONE){printf("No file type\n");}
if(ehdr.e_type == ET_REL) {printf("Relocatable file\n");}
if(ehdr.e_type == ET_EXEC){printf("Executable file\n");}
if(ehdr.e_type == ET_DYN) {printf("Shared Object file\n");}
if(ehdr.e_type == ET_CORE){printf("Core file\n");}

/* below .. this works on linux, but didn't compile on my friends bsd box,
so i looked at his elf files and noticed they are very different. apparantly
the implementation of ELF isn't as integrated across OS's as i thought.
in the ELF specification, ET_LOPROC is defined as 0xff00, but in /linux/elf.h,
it's '5' .. weird. */

#ifdef LINUX
if(ehdr.e_type >= ET_LOPROC){printf("Processor-specific\n");}
#endif

printf("Required Architecture: ");
if(ehdr.e_machine == 0) {printf("No machine\n");}
if(ehdr.e_machine == 1) {printf("AT&T WE 32100\n");}
if(ehdr.e_machine == 2) {printf("SPARC\n");}
if(ehdr.e_machine == 3) {printf("Intel 80386\n");}
if(ehdr.e_machine == 4) {printf("Motorola 68000\n");}
if(ehdr.e_machine == 5) {printf("Motorola 88000\n");}
if(ehdr.e_machine == 6) {printf("EM_486\n");}		/* undocumented */
if(ehdr.e_machine == 7) {printf("Intel 80860\n");}
if(ehdr.e_machine == 8) {printf("MIPS R3000\n");}

/* all these below are also undocumented in the elf-specification ..
                    I pulled them from /linux/elf.h               */

if(ehdr.e_machine == 10) {printf("MIPS R4000 big-endian\n");}
if(ehdr.e_machine == 11) {printf("SPARC v9 (not official) 64-bit\n");}
if(ehdr.e_machine == 15) {printf("HPPA\n");}
if(ehdr.e_machine == 18) {printf("Sun's \"v8plus\"\n");}
if(ehdr.e_machine == 20) {printf("PowerPC\n");}

printf("Object File Version: ");
if(ehdr.e_version == EV_NONE){printf("Invalid version\n");}
if(ehdr.e_version == EV_CURRENT){printf("Current version\n");}

printf("Virtual Entry Address: %x\n",ehdr.e_entry);
printf("Program Header Offset: %x\n",ehdr.e_phoff);
printf("Section Header Offset: %x\n",ehdr.e_shoff);
printf("Processor Flags: %x\n",ehdr.e_flags);
printf("ELF Header Size: %x\n",ehdr.e_ehsize);
printf("Program Header Entry Size: %x\n",ehdr.e_phentsize);
printf("Number of Program Header Entries: %x\n",ehdr.e_phnum);
printf("Section Header Entry Size: %x\n",ehdr.e_shentsize);
printf("Number of Section Header Entries: %x\n",ehdr.e_shnum);
printf("Index of string table in Section Header Table: %x\n",ehdr.e_shstrndx);
exit(0);

usage:
printf("\nELF Header Reader v 0.05a (sblip)\n");
printf("usage: %s <file>\n",argv[0]);
exit(-1);
}

not_elf()
{
printf("\nThis file is not a valid elf object file\n");
exit(-1);
}

