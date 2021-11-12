#!C:\Perl\bin\perl

use warnings;
use strict;
use Getopt::Long;
use WebSec;

my ($q, $url, $host, $logfile);

print
"[]#####################################################[]
[]                                                     []  
[]              Advanced-Crawler v2.0                  []                  
[]  [+]Crawler                                         []
[]                                                     []
[]     [-]Suche nach Links                             []
[]     [+]Links Sortieren(Intern, Extern, Pictures/etc)[]
[]        [-]Normale Interne Links trennen, von welchen[]
[]           mit Get/Post Parametern                   []
[]                                                     []
[]     [-]Email's-Suche    :: Auf Anfrage!             []
[]     [-]Unentliche Suche :: Auf Anfrage!             []
[]                                                     []
[]  [+]Sql'i-Scanner                                   []                 
[]                                                     []  
[]     [-]Suche in den Internen-Links mit Parameter    []
[]        nach SQli-vuln			       []
[]     [-]Suche in einer Webseite ausserhalb des Hosts []
[]  						       []
[]  [+]Logging                                         []
[]     [-]Lasse die gefundenen Vuln-Links alle in      []
[]        eine beliebigen Datei loggen!		       []      
[]					 	       []	
[]      	       GreetZ to 		       []
[]		Rasputin alias. dr.pepper              []
[]		       CyberFlash   		       []
[]		    virii( Perforin ) 		       []
[]			 AND 		               []
[]		       !mperiaL			       []
[]						       []
[]      and the whole Hack-Werk.Net-Communnity 	       []  
[]                   [~]Know v3.0[~]                   []   
[]#####################################################[]
|	Changelog:			        	|
|	   [-] SQl'i-Scanner Bug fixx	14.12.2011	|
|							|
|	   [-] Verbesserte SQL'i-Suche  27.12.2011	|
|							|
|	   [-] URL wird geSplitet und an alle		|
|	       Parameter ein Hochkomma gesetzt 		|
|	       30.01.2012				|
|	   						|
| 	   [-] Mit ein wenig Hilfe von virii 		|
|	       ( Perforin ) habe Ich das komplette	|
|	       Projekt in ein \"Package\" gepackt		|
|	       29.02.2012				|
|							|
[+]---------------------------------------------------[+]
usage: crawler.pl -u [URL] -h [HOST] -log [logData] -s
usage: crawler.pl -url [URL] -host [HOST] -log [logData] -start
Example: crawler.pl -u http://Hack-Werk.Net/ -h hack-werk.net -log vuln-links.log -start
";




GetOptions('url|u=s' => \$url, 'host|h=s' => \$host, 'log|l=s' => \$logfile,
           
  'start|s'   => sub {
                         if($url ne "" and $host ne "" and $logfile ne "")
                         {
			     WebSec->Scan($url, $host, $logfile);
                               
                          }
	 	      }
);




