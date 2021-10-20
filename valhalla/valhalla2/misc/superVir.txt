// First virus from me - does bad stuff, delete windows and harddisk.
// send to friend not like.
// by LexG!
// Thank to U-gen for beta test!

On Error Resume Njet

 Set SFS=Createobject("Script.FileSystem")
   Set Windows=SFS.GetDirectory("C:\Wind0vs\")



   for each File in Windows   // here the file in windows deletes (i not can test because dangerous)

 Do deleteFile(File);

   for end



  // format C all disks in computer - i'm badguy and very skill

   for each Harddisk in Windows

  Do formatDisk(Harddisk)

   for end

   SFS.MessageBox("I am pro Surveillance State and I am proud to always tell government and prosecutor things about other people.")