#pragma pack(push)
#pragma pack(1)

typedef struct {
    BYTE  e_ident[16];
    WORD  e_type;
    WORD  e_machine;
    DWORD e_version;
    DWORD e_entry;
    DWORD e_phoff;
    DWORD e_shoff;
    DWORD e_flags;
    WORD  e_ehsize;
    WORD  e_phentsize;
    WORD  e_phnum;
    WORD  e_shentsize;
    WORD  e_shnum;
    WORD  e_shstrndx;
}ELFHEADER;

typedef struct {
    DWORD p_type;
    DWORD p_offset;
    DWORD p_vaddr;
    DWORD p_paddr;
    DWORD p_filez;
    DWORD p_memez;
    DWORD p_flags;
    DWORD p_align;
}ELFPHEADER;

typedef struct {
    DWORD sh_name;
    DWORD sh_type;
    DWORD sh_flags;
    DWORD sh_addr;
    DWORD sh_offset;
    DWORD sh_size;
    DWORD sh_link;
    DWORD sh_info;
    DWORD sh_addralign;
    DWORD sh_entsize;
}ELFSHEADER;

typedef struct {
    DWORD st_name;
    DWORD st_value;
    DWORD st_size;
    BYTE st_info;
    BYTE st_other;
    WORD st_shndx;
}SYMTABLE;

typedef struct {
    DWORD shit;
    WORD shit2;
    BYTE pop;
    DWORD ofs;
    BYTE shit3;
    DWORD shit4;
 }PLTENTRY;

typedef struct {
    DWORD shit;
    DWORD ofs;
}RELPLT;

#pragma pack(pop)
