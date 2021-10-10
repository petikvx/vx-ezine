;INTERFACE

;FindSign proc near
;CureFileProc proc near
;WriteBuff proc near

;IMPLEMENTATION
;**************************************************************************
FindSign proc near
         pusha
         pushf
         push ds es
         mov ax,FSEG
         mov es,ax
         xor di,di
         lea si,SigArray1
         mov cx,FileLength
         mov dx,SigLength1
         call BlockPresent
         cmp ax,0
         je NoFileSign
         xor di,di
         lea si,SigArray1
         mov cx,FileLength
         mov dx,SigLength1
         call BlockOffs
         mov SigOffset1,ax
         xor di,di
         lea si,SigArray2
         mov cx,FileLength
         mov dx,SigLength2
         call BlockPresent
         cmp ax,0
         je NoFileSign
         xor di,di
         lea si,SigArray2
         mov cx,FileLength
         mov dx,SigLength2
         call BlockOffs
         sub ax,SigOffset1
         cmp ax,SigOffset2
         jne NoFileSign
         inc CouFind
         mov FlagInfect,1
NoFileSign:
         pop es ds
         popf
         popa
         retn
FindSign endp
;**************************************************************************
CureFileProc proc near
         pusha
         pushf
         mov EraseFlag,0
         cmp Desinfect,DisinfNo
         jne @CFP1
@CFP0:
         inc AllFileErased
         call CloseFile
         lea dx,KillFile
         call Write
         lea dx,SouFileName
         call EraseFile
         mov EraseFlag,1
         jmp RestoreAndExit
@CFP1:
         cmp TypeWrt,TypeBeg
         jne @CFP2
         call FromBegOfFile
         jmp RestoreAndExit
@CFP2:
         cmp TypeWrt,TypeMov
         jne @CFP3
         call CureNone
         jmp RestoreAndExit
@CFP3:
         cmp TypeWrt,TypeAdd
         jne @CFP4
         call CureNone
         jmp RestoreAndExit
@CFP4:
         cmp TypeWrt,TypeIns
         jne @CFP5
         call CureNone
         jmp RestoreAndExit
@CFP5:
         cmp TypeWrt,TypeEnd
         jne @CFP6
         call FromEndOfFile
         jmp RestoreAndExit
@CFP6:
         cmp TypeWrt,TypeOvr
         jne @CFP7
         jmp @CFP0
@CFP7:
         cmp TypeWrt,TypeSat
         jne @CFP8
         call CureNone
         jmp RestoreAndExit
@CFP8:
         cmp TypeWrt,TypeUep
         jne @CFP9
         call CureNone
         jmp RestoreAndExit
@CFP9:
         ;etc
RestoreAndExit:
         popf
         popa
         ret
CureFileProc endp
;**************************************************************************
WriteBuff proc near
          call CloseFile
          lea dx,SouFileName
          xor cx,cx
          call SetFileAttr
          mov al,2
          call OpenFile
          cmp bx,0
          jne NextSave
          inc AllErrorFound
          lea dx,ErrorOpenFile
          call Write
          call Ctrl
          mov al,1
          retn
NextSave:
          push ds
          mov cx,FileLength
          mov ax,FSEG
          mov ds,ax
          xor dx,dx
          call WriteToFile
          xor cx,cx
          call WriteToFile
          pop ds
          call CloseFile
          mov al,0
          retn
WriteBuff endp
;**************************************************************************
