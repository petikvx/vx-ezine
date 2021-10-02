//loading elf files under w32
//(c) Vecna/29A 2004

#include <stdio.h>
#include <windows.h>

#include "elf.h"
#include "libc.cpp"
#include "handlers.cpp"

#define ELF_BASE 0x08048000

//#define DEBUG 1

int main(int argc,char *argv[]){
    HANDLE hnd;
    DWORD aux,tmp,pltsize,dynsym,relplt;
    char *strings,*dynstrings,*section,*function;
    void *elf;
    ELFHEADER *elfheader;
    ELFPHEADER *pheaders;
    ELFSHEADER *sheaders;
    PLTENTRY *plt;

    if(argc!=2){
        printf("Load and run a ELF under W32.\n\n");
        printf("USAGE %s <ELF>\n",argv[0]);
        return 1;
    }

    hnd=CreateFile(argv[1],
                   GENERIC_READ,
                   0,
                   0,
                   OPEN_EXISTING,
                   FILE_ATTRIBUTE_NORMAL,
                   0);
    if(((int)hnd)!=-1){
        tmp=GetFileSize(hnd,0);
        elf=VirtualAlloc((void *)ELF_BASE,
                      tmp+0x8000,
                      MEM_COMMIT|MEM_RESERVE,
                      PAGE_EXECUTE_READWRITE);
        if(elf!=NULL){
            ReadFile(hnd,(void *)((DWORD)elf+0x8000),tmp,&aux,0);
            CloseHandle(hnd);
        }else{
            CloseHandle(hnd);
            printf("Memory error...\n");
            return 3;
        }
    }else{
        printf("File error...\n");
        return 2;
    }

    elfheader=(ELFHEADER *)((DWORD)elf+0x8000);
    sheaders=(ELFSHEADER *)((elfheader->e_shoff)+(DWORD)elfheader);
    pheaders=(ELFPHEADER *)((elfheader->e_phoff)+(DWORD)elfheader);
    strings=(char *)((((ELFSHEADER *)
        &sheaders[elfheader->e_shstrndx])->sh_offset)+
        (DWORD)elfheader);

#ifdef DEBUG
    printf("SECTIONS\n");
#endif
    for(aux=0;aux<(DWORD)elfheader->e_shnum;aux++){
        section=&strings[((ELFSHEADER *)&sheaders[aux])->sh_name];
#ifdef DEBUG
        printf("%s\n",section);
#endif
        tmp=((((ELFSHEADER *)&sheaders[aux])->sh_offset)+(DWORD)elfheader);
        if(!(lstrcmp(section,".dynsym")))
            dynsym=tmp;
        else if(!(lstrcmp(section,".rel.plt")))
            relplt=tmp;
        else if(!(lstrcmp(section,".dynstr")))
            dynstrings=(char *)tmp;
        else if(!(lstrcmp(section,".plt"))){
            plt=(PLTENTRY *)tmp;
            pltsize=(((ELFSHEADER *)&sheaders[aux])->sh_size)>>4;
        }
    }

#ifdef DEBUG
    printf("FUNCTIONS\n");
#endif
    for(aux=pltsize;aux;plt++,aux--){
        if(plt->pop==0x68){
            function=&dynstrings[((SYMTABLE *)(((((RELPLT *)((plt->ofs)+
                relplt))->ofs)>>4)+dynsym))->st_name];
#ifdef DEBUG
            printf("%s\n",function);
#endif
            tmp=GetFuntionAddress(function);
            memset(plt,0x90,sizeof(PLTENTRY));
            plt->shit3=0xe9;
            plt->shit4=tmp-(DWORD)&plt[1];
            if(tmp==(DWORD)&unhandled){
                plt->pop=0x68;
                plt->ofs=(DWORD)function;
                plt->shit3=0xe8;
            }
        }
    }

    for(aux=0;aux<(DWORD)elfheader->e_phnum;aux++){
        VirtualProtect((void *)((ELFPHEADER *)&pheaders[aux])->p_offset,
                       ((ELFPHEADER *)&pheaders[aux])->p_memez,
                       ((ELFPHEADER *)&pheaders[aux])->p_flags&1?
                            PAGE_READONLY:
                            PAGE_READWRITE,
                       &tmp);
    }

    tmp=elfheader->e_entry;
    asm mov eax,tmp;
    asm jmp eax;

    return 0;
}
