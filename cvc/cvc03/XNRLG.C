/*
		NRLG Vaccine by Park Jeenhong
		(c) 1996, Virus and Assembler Study Association
*/

#include <io.h>
#include <stdio.h>
#include <conio.h>
#include <stdlib.h>
#include <alloc.h>
#include <fcntl.h>
#include <dos.h>

#ifndef __LARGE__
#error Must be compiled in LARGE model
#endif

union scan {
	unsigned c;
	unsigned char ch[2];
} sc;

char buffer[100], *buff, *bufx3;
char directory[256];

int count, isnear, INFECTION;
long SIZE;
unsigned off;

FILE *fp, *fp2;

void interrupt (*Virtual)(void);

void *GetVect(int);
void SetVect(int, void *);
int compare(char *, char *, int);
void find_mem(void);
void find(void);
void find_virus(char *);

void main(int argc, char *argv[])
{
	register int xl;
	char cur_path[256], name[15];

	INFECTION=0;

	textattr(0x8F);
	cprintf(" XNRLG : NRLG (found in PUG) Vaccine by Park Jeenhong ");
	textattr(0x07);
	cprintf("\r\n\r\n");

	find_mem();

	buff=malloc(2048);
	bufx3=malloc(2048);
	if(!buff || !bufx3) {
		printf("Memory allocation error!\n");
		return;
	}

	strcpy(cur_path,"X:\\");
	strcpy(directory,"X:\\");
	cur_path[0]='A'+getdisk();
	getcurdir(0, &cur_path[3]);

	if(argc<2) {
		printf("\nUsage : XNRLG path\n");

		setdisk(toupper(*cur_path)-'A');
		chdir(cur_path);

		free(buff);

		return;
	}

	xl=toupper(argv[1][0])-'A';
	directory[0]=toupper(argv[1][0]);
	setdisk(xl);
	if(getdisk()!=xl) {
		printf("Invalid drive specification\n");
		return;
	}

	chdir(argv[1]);

	find();

	setdisk(toupper(cur_path[0])-'A');

	chdir(cur_path);

	free(buff);
	free(bufx3);

	if(INFECTION>0) {
		if(INFECTION>1) printf("\n%d infected files\n", INFECTION);
		else printf("\n1 infected file\n");
	}
	else printf("\nNo infected file\n");

	return;
}

void *GetVect(int int_num)
{
	asm {
		push	ds
		push	si
		mov	si, int_num
		shl	si, 1
		shl	si, 1
		xor	ax, ax
		mov	ds, ax
		mov	ax, word ptr [si]
		mov	dx, word ptr [si+2]
		pop	si
		pop	ds
	}

	return (void *)((void _seg *)_DX+(void near *)_AX);
}

void SetVect(int int_num, void *IVT)
{
	unsigned X_SEG, X_OFF;

	X_SEG=FP_SEG(IVT);
	X_OFF=FP_OFF(IVT);

	asm {
		push	ds
		push	si
		mov	si, int_num
		shl	si, 1
		shl	si, 1
		xor	ax, ax
		mov	ds, ax
		mov	ax, X_OFF
		mov	word ptr [si], ax
		mov	ax, X_SEG
		mov	word ptr [si+2], ax
		pop	si
		pop	ds
	}

	return;
}

int compare(char *src, char *dest, int len)
{
	unsigned X_SEG, X_OFF, X_SEG2, X_OFF2;

	X_SEG=FP_SEG(src);
	X_OFF=FP_OFF(src);
	X_SEG2=FP_SEG(dest);
	X_OFF2=FP_OFF(dest);

	asm {
		push	ds
		push	es
		push	si
		push	di
		cld
		mov	cx, len
		mov	ax, X_SEG
		mov	ds, ax
		mov	si, X_OFF
		mov	ax, X_SEG2
		mov	es, ax
		mov	di, X_OFF2
		repz	cmpsb
		pop	di
		pop	si
		pop	es
		pop	ds
		jcxz	EQS
	}

	return 0;

EQS:	return 1;
}

void find_mem(void)
{
	unsigned I8_SEG, I8_OFF, I21_SEG, I21_OFF;
	unsigned *READ;
	char *I8, *I21;

	asm {
		mov ax, 0xCACA
		int 0x21
		cmp bh, 0xCA
		jz OK
		jmp NAY
	}

OK:
	I21=(char *)GetVect(0x21);
	I21_OFF=FP_OFF(I21);
	I21_SEG=FP_SEG(I21);
	if(compare((char *)(I21+10),"\x80\xFC\x12\x74\x23\x3D\xCA\xCA\x75\x02",10)) {
		I21=MK_FP(I21_SEG, I21_OFF+0x19A);
		READ=(unsigned *)I21;
		I21_OFF=*READ++;
		I21_SEG=*READ;
		I21=MK_FP(I21_SEG, I21_OFF);
		Virtual=(void interrupt *)I21;
		SetVect(0x21, Virtual);
		printf("Found NRLG Virus in memory and cured\n\n");
	}

NAY:

	return;
}

void find(void)
{
	register int xl;
	int done;
	struct ffblk ffblk;

	find_virus("*.COM");

	done=findfirst("*.*",&ffblk,FA_DIREC|FA_ARCH);
	while(!done) {
		if(ffblk.ff_attrib&FA_DIREC && strcmp(ffblk.ff_name,".")!=0 && strcmp(ffblk.ff_name,"..")!=0) {
			chdir(ffblk.ff_name);
			getcurdir(0, &directory[3]);
			gotoxy(1,wherey());
			textattr(0x1E);
			cprintf(" Directory : %s ",directory);
			find();
			chdir("..");
			gotoxy(1,wherey());
			textattr(0x07);
			for(xl=0;xl<strlen(directory)+14;xl++) cprintf(" ");
		}
		done=findnext(&ffblk);
	}

	return;
}

void find_virus(char *dest)
{
	register int xl, xr;
	unsigned char ENC_KEY;
	unsigned S_SEG, S_OFF, SEG, OFF;
	long len, header;
	int handle, xp, done, inf, xp_prev, redo;
	char *bufx2;
	struct ffblk ffblk;

	done=findfirst(dest,&ffblk,FA_ARCH);
	textattr(0x07);
	cprintf("\r\n");
	inf=0;
	redo=0;
	while(!done) {
		fp=fopen(ffblk.ff_name,"rb");
		buffer[0]=fgetc(fp);
		if(buffer[0]=='\xE9' || buffer[0]=='\xE8') {
			if(buffer[0]=='\xE9') {
				fread(&off, 2, 1, fp);
				fseek(fp, off, SEEK_CUR);
			}
			else fseek(fp, 0, SEEK_SET);
			S_SEG=FP_SEG(bufx3);
			S_OFF=FP_OFF(bufx3);
			S_SEG+=((unsigned)(S_OFF/16)+1);
			S_OFF=0;
			bufx2=MK_FP(S_SEG, S_OFF);
			fread(bufx2, 985, 1, fp);
			asm {
				push ds
				push es
				push si
				push di
				mov ax, S_SEG
				mov ds, ax
				mov di, 0x4E
				mov cx, 0x4DC
				cmp byte ptr [di], 0xB9
				jnz SKIPS
				jmp SKIPX
			}
SKIPS:		asm {
				xor byte ptr [di], 0x94
				xor byte ptr [di], 0x79
				xor byte ptr [di], 0xCE
				xor byte ptr [di], 0x19
				add word ptr [di], 0xFED5
				inc byte ptr [di]
				sub byte ptr [di], 0x55
				add byte ptr [di], 0x89
				inc byte ptr [di]
				add byte ptr [di], 0xE6
				inc word ptr [di]
				inc word ptr [di]
				inc di
				inc di
				loop SKIPS
				mov di, 0x5C
				mov cx, 0x4DC
			}
AXC:			asm {
				xor byte ptr [di], 1
				inc di
				loop AXC
			}
SKIPX:		asm {
				pop di
				pop si
				pop es
				pop ds
			}
			if(compare(bufx2+256, "N.R.L.G. AZRAEL\xE9\x7A\x02\x9C\x60\x56", 21)) {
				if(redo==0) {
					INFECTION++;
					cprintf("%s - Infected with NRLG Virus\r\n", ffblk.ff_name);
					textattr(0x0C);
					cprintf("                             Repair it (y/N)?");
					textattr(0x07);
				}
				if(redo==1 || toupper(getch())=='Y') {
					if(redo==0) cprintf(" Yes ");
					inf=1;
					fp2=fopen("IV$$$RMV.$MP","wb");
					if(!fp2) {
						cprintf("\x07Unable to repair the infected file\r\n");
						fclose(fp);
						break;
					}
					else {
						sc.ch[0]=*(bufx2+0x26B);
						sc.ch[1]=*(bufx2+0x26C);
						SIZE=(long)sc.c;
						SIZE+=3;
						fseek(fp, 0, SEEK_SET);
						for(xl=0;xl<(int)(SIZE/2048);xl++) {
							fread(buff,2048,1,fp);
							if(xl==0) for(xr=0;xr<3;xr++) *(buff+xr)=*(bufx2+0x26E+xr);
							fwrite(buff,2048,1,fp2);
						}
						fread(buff,SIZE%2048,1,fp);
						if(xl==0) for(xr=0;xr<3;xr++) *(buff+xr)=*(bufx2+0x26E+xr);
						fwrite(buff,SIZE%2048,1,fp2);
						fclose(fp2);
						fclose(fp);
						unlink(ffblk.ff_name);
						rename("IV$$$RMV.$MP",ffblk.ff_name);
						if(_dos_open(ffblk.ff_name,O_RDONLY,&handle)==0) {
							_dos_setftime(handle,ffblk.ff_fdate,ffblk.ff_ftime);
							_dos_close(handle);
							textattr(0x0B);
							cprintf("-> Repaired");
							textattr(0x07);
							cprintf("\r\n");
						}
					}
				}
				else {
					cprintf(" No\r\n");
					fclose(fp);
					break;
				}
			}
			else fclose(fp);
		}
		else fclose(fp);
		if(inf==0) {
			done=findnext(&ffblk);
			redo=0;
		}
		else {
			done=0;
			inf=0;
			redo=1;
		}
	}

	return;
}
