;INTERFACE

;KhizhnjakFill proc near
;RedArc112Fill proc near

;IMPLEMENTATION
;-----------------------------------------------------------------------------
KhizhnjakFill proc near
              pusha
              pushf
              lea si,KhizhnjakMyName
              lea di,VirName
              mov cx,KhizhnjakMyNameLen
              mov VirNameLen,cl
              repnz movsb
              mov VirLength,KhizhnjakMyLength
              mov TypeWrt,KhizhnjakMyTypeWrt
              mov Desinfect,KhizhnjakMyDesinfect
              mov CryptInfo,KhizhnjakMyCryptInfo
              mov SigOffset1,0
              mov cx,KhizhnjakMySigLength1
              mov SigLength1,cx
              lea si,KhizhnjakMySigArray1
              lea di,SigArray1
              mov al,KhizhnjakMySigArray1_1
              stosb
              repnz movsb
              mov SigOffset2,KhizhnjakMySigOffset2
              mov cx,KhizhnjakMySigLength2
              mov SigLength2,cx
              lea si,KhizhnjakMySigArray2
              lea di,SigArray2
              repnz movsb
              mov VirBegOffs,KhizhnjakMyVirBegOffs
              mov BytesPartCo,KhizhnjakMyBytesPartCo
              mov BytesOffset,KhizhnjakMyBytesOffset1
              mov BytesLength,KhizhnjakMyBytesLength
              mov BytesCrypt,KhizhnjakMyBytesCrypt
              mov SourceOffs,KhizhnjakMySourceOffs
              popf
              popa
              retn
KhizhnjakFill endp
;-----------------------------------------------------------------------------
RedArc112Fill proc near
              pusha
              pushf
              lea si,RedArcMyName
              lea di,VirName
              mov cx,RedArcMyNameLen
              mov VirNameLen,cl
              repnz movsb
              mov VirLength,RedArcMyLength
              mov TypeWrt,RedArcMyTypeWrt
              mov Desinfect,RedArcMyDesinfect
              mov CryptInfo,RedArcMyCryptInfo
              mov SigOffset1,0
              mov cx,RedArcMySigLength1
              mov SigLength1,cx
              lea si,RedArcMySigArray1
              lea di,SigArray1
              mov al,RedArcMySigArray1_1
              stosb
              repnz movsb
              mov SigOffset2,RedArcMySigOffset2
              mov cx,RedArcMySigLength2
              mov SigLength2,cx
              lea si,RedArcMySigArray2
              lea di,SigArray2
              repnz movsb
              mov VirBegOffs,RedArcMyVirBegOffs
              mov BytesPartCo,RedArcMyBytesPartCo
              popf
              popa
              retn
RedArc112Fill endp
;-----------------------------------------------------------------------------
