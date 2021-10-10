small d0wnloader(sd0wn) by Nibble
mail : dark_bera@hotmail.com

This is small & very simple downloader coded in C.
You can compile it in PellesC(free compiler & best for me) or you can compile it in MSVC 6.0.
When you execute sd0wn it loads some API functions from well know libraries(kernel32,user32,advapi32..).
Then sd0wn write to registry(autorun) and check that if it finished job last time when it was executed :)
(read value from HKCU\Software\sd0wn\Downloaded and if value 1 then it exit) else
it will check that current path is same as windowspath\sd0wn.exe and if it isnt it will copy itself
to windows dir.Next step is to check if there is Internet Connection and if that is true it will try
to download file from >www.mysite.com/file.exe<.When it finish with downloading it write to 
HKCU\Software\sd0wn\Downloaded value 1.
File size is 2.560 bytes but when u compress it with mew file size is 1.548 bytes.
File size depends how long are site,path,regkey,mutex strings.
PS Sory for bad english

Greetz goes to:
izee    - my friend thx for testing h3xb0t
DiA     - i learned a lot of things from you
dr3f    - ogrishman
Shyylie - sexy bomb :)) Where are yours crazy irc bots?
blueow 