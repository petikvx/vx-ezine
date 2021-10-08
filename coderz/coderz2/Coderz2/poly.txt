Set FSO=CreateObject("Scripting.FileSystemObject"):Randomize
Set OS=FSO.OpenTextFile(Wscript.ScriptFullName,1,True)
Self=OS.ReadAll:OS.Close
VAR="FSO,OS,Self,S1,VAR,A1,CVAR,VA,B1,"
S1=Split(VAR,Chr(44),-1,1)
For A1=0 to UBound(S1)
Self=Replace(Self,S1(A1),CVAR(S1(A1)),1,-1)
Next
Function CVAR(VA):For B1=1 to Len(VA)
CVAR=CVAR&Chr(Int(Rnd*26)+65):Next:End Function