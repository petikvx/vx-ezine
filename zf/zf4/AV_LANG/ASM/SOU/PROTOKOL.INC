;INTERFACE

;TextProt proc near
;DECODE_STRING proc near

;IMPLEMENTATION
;-----------------------------------------------------------------------------
TextProt proc near
         cmp KhizhnjakMyCouFind,0
         je @_@1
         inc AllVirusFound
@_@1:
         cmp RedArcMyCouFind,0
         je @_@2
         inc AllVirusFound
@_@2:
         call Ctrl
         lea dx,pCountPath
         mov ax,AllPathFound
         call TextWrite
         lea dx,pFilesFound
         mov ax,AllFileFound
         call TextWrite
         lea dx,pFileTested
         mov ax,AllFileTested
         call TextWrite
         lea dx,pCouError
         mov ax,AllErrorFound
         call TextWrite
         lea dx,pKnowVirus
         mov ax,AllKnownVirus
         call TextWrite
         lea dx,pInfectFound
         mov ax,AllFileInfect
         call TextWrite
         lea dx,pCouCureFile
         mov ax,AllFileCured
         call TextWrite
         lea dx,pEraseFile
         mov ax,AllFileErased
         call TextWrite
         lea dx,pCountVirus
         mov ax,AllVirusFound
         call TextWrite
         lea dx,pCouSkipVir
         mov ax,AllVurusSkip
         call TextWrite
         lea dx,pFileError
         mov ax,AllFileError
         call TextWrite
         retn
TextProt endp
;-----------------------------------------------------------------------------
DECODE_STRING proc near
     mov startpath[0],0
     mov startpath[1],0
     mov startpath[2],0
     mov startpath[3],0
     mov startpath[4],0
     mov FLAG_DECRYPT,0
CALCULATE_BYTE:
     cmp FileLength,10
     jnl DECODE
     jmp ENDE_DECODE
DECODE:
     inc startpath[1]
     sub FileLength,10
     cmp startpath[1],10
     jl  CALCULATE_BYTE
     inc startpath[2]
     mov startpath[1],0
     cmp startpath[2],10
     jl CALCULATE_BYTE
     inc startpath[3]
     mov startpath[2],0
     cmp startpath[3],10
     jl CALCULATE_BYTE
     inc startpath[4]
     mov startpath[3],0
     cmp startpath[4],10
     jmp CALCULATE_BYTE
FLAG_DECRYPT db ?
ENDE_DECODE:
     cmp startpath[4],0
     jz LOC_R1
     mov al,startpath[4]
     add al,30h
     mov ah,0eh
     int 10h
     mov FLAG_DECRYPT,1
LOC_R1:
     cmp startpath[3],0
     jnz LOC_R2
     cmp FLAG_DECRYPT,0
     jz LOC_R3
LOC_R2:
     mov al,startpath[3]
     add al,30h
     mov ah,0eh
     int 10h
     mov FLAG_DECRYPT,1
LOC_R3:
     cmp startpath[2],0
     jnz LOC_R4
     cmp FLAG_DECRYPT,0
     jz LOC_R5
LOC_R4:
     mov al,startpath[2]
     add al,30h
     mov ah,0eh
     int 10h
     mov FLAG_DECRYPT,1
LOC_R5:
     cmp startpath[1],0
     jnz LOC_R6
     cmp FLAG_DECRYPT,0
     jz LOC_R7
LOC_R6:
     mov al,startpath[1]
     add al,30h
     mov ah,0eh
     int 10h
     mov FLAG_DECRYPT,1
LOC_R7:
     mov ax,FileLength
     add al,30h
     mov ah,0eh
     int 10h
     mov FileLength,0
     ret
DECODE_STRING endp
;-----------------------------------------------------------------------------
TextWrite proc near
         push ax
         call Write
         call WriteLine
         pop ax
         mov FileLength,ax
         call DECODE_STRING
         call Ctrl
         ret
TextWrite endp
;-----------------------------------------------------------------------------

