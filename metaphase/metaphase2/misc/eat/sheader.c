#include <stdio.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <elf.h>

main(int argc, char *argv[])
{

Elf32_Ehdr ehdr;			/* ELF Header */
Elf32_Shdr shdr;			/* Section Header */
Elf32_Phdr phdr;			/* Program Header */
int i;					/* */
int fd;					/* File descriptor */
int c;					/* counter for string name length */
unsigned long x;			/* to hold offset of string table */
char strname[30];			/* section header string name */

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


fseek(fp,(ehdr.e_shoff+(ehdr.e_shstrndx*ehdr.e_shentsize)+16),SEEK_SET);
fread(&x,1,4,fp);	 /* offset of string table */


for(i=0;i < ehdr.e_shnum;i++)
{

fseek(fp,(ehdr.e_shoff+(i*ehdr.e_shentsize)),SEEK_SET);
fread(&shdr,ehdr.e_shentsize,1,fp);

printf("\n===== Section Header Table Entry #%d =====\n",(i+1));

/****************Begin the long and complex process of *******************/
/****************obtaining the string table address    *******************/
/****************and parsing each SH entry's name out  *******************/

printf("Section Name: ");


fseek(fp,(shdr.sh_name+x),SEEK_SET);	/* here we seek to the offset of the
					   section name (from the current entry)					   in the string table */

c = 0;				/* our counter */

loop:				/* loop back to here and keep getting chars */
strname[c] = fgetc(fp);		/* if we don't encounter a null byte 	    */	
if(c != 0 && strname[c] == 0)	
{goto cont;}			/* if we do, break the loop		   */	
else{c++; goto loop;}

cont:

if(strname[0] != 0)		/* check for null byte */
{
printf("%s\n",strname);		/* if not null, print name */
}

else
{
printf("none\n");		/* otherwise, section has no name */
}

/**********************End long process***************************************/
/*****************************************************************************/
/* it took me hours to do the above .. probably minutes to do the below      */

printf("Section Contents: ");
if(shdr.sh_type==0){printf("SHT_NULL\n");}
if(shdr.sh_type==1){printf("SHT_PROGBITS\n");}
if(shdr.sh_type==2){printf("SHT_SYMTAB\n");}
if(shdr.sh_type==3){printf("SHT_STRTAB\n");}
if(shdr.sh_type==4){printf("SHT_RELA\n");}
if(shdr.sh_type==5){printf("SHT_HASH\n");}
if(shdr.sh_type==6){printf("SHT_DYNAMIC\n");}
if(shdr.sh_type==7){printf("SHT_NOTE\n");}
if(shdr.sh_type==8){printf("SHT_NOBITS\n");}
if(shdr.sh_type==9){printf("SHT_REL\n");}
if(shdr.sh_type==10){printf("SHT_SHLIB\n");}
if(shdr.sh_type==11){printf("SHT_DYNSYM\n");}
if(shdr.sh_type==0x70000000){printf("SHT_LOPROC\n");}
if(shdr.sh_type==0x7fffffff){printf("SHT_HIPROC\n");}
if(shdr.sh_type==0x80000000){printf("SHT_LOUSER\n");}
if(shdr.sh_type==0xffffffff){printf("SHT_HIUSER\n");}

printf("Section Flags: ");
if(shdr.sh_flags == 0x1){printf("SHF_WRITE\n");}
if(shdr.sh_flags == 0x2){printf("SHF_ALLOC\n");}
if(shdr.sh_flags == 0x4){printf("SHF_EXECINSTR\n");}
if(shdr.sh_flags == 0xf0000000){printf("SHF_MASKPROC\n");}
if(shdr.sh_flags == 0){printf("0\n");}

printf("Memory Image Offset: %x\n",shdr.sh_addr);
printf("Section File Offset: %x\n",shdr.sh_offset);
printf("Section Size: %x\n",shdr.sh_size);

if(shdr.sh_type == 6){printf("Index of string table for this section: %x\n",shdr.sh_link);}

if(shdr.sh_type == 5){printf("Index of symbol table to which hash table applies: %x\n",shdr.sh_link);}

if(shdr.sh_type == 9 || shdr.sh_type == 4)
{
printf("Index of symbol table: %x\n",shdr.sh_link);
printf("Index of section to which relocation applies: %x\n",shdr.sh_info);
}

if(shdr.sh_type == 2 || shdr.sh_type == 11)
{
printf("Index of associated string table: %x\n",shdr.sh_link);
printf("sh_info: %x\n",shdr.sh_info);
}

printf("Section Alignment: %x\n",shdr.sh_addralign);

if(shdr.sh_entsize !=0)
{
printf("Size of fixed entry for this section: %x\n",shdr.sh_entsize);
}


}
fclose(fp);
exit(0);

usage:
printf("\nELF Section Header Table Reader v 0.01a (sblip)\n");
printf("usage: sheader <file>\n");
exit(-1);
}

not_elf()
{
printf("\nThis file is not a valid elf object file\n");
exit(-1);
}


