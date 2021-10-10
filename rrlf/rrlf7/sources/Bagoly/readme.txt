--------------------------------------------------------------------------------
                          First Matlab .m file infector 
                                  by Positron
--------------------------------------------------------------------------------

Virus name: MatLab.Bagoly.a
----------------------------

This virus demonstrates how to infect Matlab .m  files. It search  *.m files  in
current directory  and add itself  to the start of the  original .m file (like a
prepender  infector).  Every time when the user  call the infected  .m file, the 
virus  search all  .m file in  the current directory, and infect them  if the .m 
file is  not already infected. 
It is a prototype,  so there are lots of  things what  are need  optimalization.
I tested it under MatLab 7.2 (Windows version).

- I  use  "__"  chars  after  all of  my variables,  because I  do not want same
  variables as the victim .rm file include.
- With  minimal  modifications  able to  make it  workable under Unix and MaxOSX
  too. I have not implemented it, beacuse I have only Windows. :)
- Easy  to make  it polymorphic.  MatLab has same algorithm what can help a lot.
- If you have enough free time, you can combine it with neural network,  genetic 
  algoritms, ....


      
Positron
