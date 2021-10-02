mz_header:
.magic                  dw "MZ"
.cblp                   dw 0
.cp                     dw 1
.crlc                   dw 0
.cparhdr                dw 4
.minalloc               dw 0
.maxalloc               dw 0
.ss                     dw 1
.sp                     dw 0
.csum                   dw 0
.ip                     dw 0
.cs                     dw 0
.lfarlc                 dw 40h
.ovno                   dw 0
.res                    times 4 dw 0
.oemid                  dw 0
.oeminfo                dw 0
.res2                   times 10 dw 0
.lfanew                 dd pe_header

stub:
	mov ah, 4ch
	int 21h

align 4, db 0

pe_header:
.Signature              dd "PE"
.Machine                dw 14Ch
.NumberOfSections       dw 1
.TimeDateStamp          dd 0
.PointerToSymbolTable   dd 0
.NumberOfSymbols        dd 0
.SizeOfOptionalHeader   dw 0E0h
.Characteristics        dw 10Fh
.Magic                  dw 10Bh
.MajorLinkerVersion     db 0
.MinorLinkerVersion     db 0
.SizeOfCode             dd 1000h
.SizeOfInitializedData  dd 1000h
.SizeOfUninitialzedData dd 0
.AddressOfEntryPoint    dd code+RVADIFF
.BaseOfCode             dd CODE_BASE
.BaseOfData             dd CODE_BASE
.ImageBase              dd imagebase
.SectionAlignment       dd 1000h
.FileAlignment          dd 200h
.MajorOperSystemVersion dw 1
.MinorOperSystemVersion dw 0
.MajorImageVersion      dw 0
.MinorImageVersion      dw 0
.MajorSubsystemVersion  dw 4
.MinorSubsystemVersion  dw 0
.Reserved1              dd 0
.SizeOfImage            dd 2000h
.SizeOfHeaders          dd 200h
.CheckSum               dd 0
.Subsystem              dw 2
.DllCharacteristics     dw 0
.SizeOfStackReserve     dd 100000h
.SizeOfStackCommit      dd 2000h
.SizeOfHeapReserve      dd 100000h
.SizeOfHeapCommit       dd 1000h
.LoaderFlags            dd 0
.NumberOfRvaAndSizes    dd 10h
.export                 times 2 dd 0
.import                 dd import+RVADIFF, import_end-import_start
.misc_sectionz          times 28 dd 0

sections:
.SectionName            db "FTPD", 0, 0, 0, 0
.VirtualSize            dd 1000h
.VirtualAddress         dd CODE_BASE
.SizeOfRawData          dd code_end-code_start
.PointerToRawData       dd code_start
.PointerToRelocations   dd 0
.PointerToLinenumbers   dd 0
.NumberOfRelocations    dw 0
.NumberOfLinenumbers    dw 0
.Characteristics        dd 0E0000060h

