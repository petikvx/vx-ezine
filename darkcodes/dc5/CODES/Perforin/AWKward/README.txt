::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::[*NIX.AWKward.AWK.Perforin-vxnetw0rk]::::::::::::::::::::::::::::
::::::::::::::::::::::::[AWK]::::::::::::::::::::::[Perforin]:::::::::::
::::::::::::::::::::::::::::::::::::::[LIP]:::::::::::::::::::::::::::::


AWK by Wikipedia:
"The AWK utility is an interpreted programming language typically used
as a data extraction and reporting tool. It is a standard feature of
most Unix-like operating systems."

This is my AWK creation which I created for the LIP [1] contest by SPTH.
It's goal is to infect AWK files in the current directory by prepending
code resulting in an EPO.

Most AWK files start with the following block:

BEGIN {
		FOOBAR
		FOOBAR
		FOOBAR
}

AWKward replaces this BEGIN block with the following code:

BEGIN { infected()
		FOOBAR
		FOOBAR
		FOOBAR
}

function infected() {
		VIRUS BODY
}


This ensures that every time an infected AWK file gets executed it
searches for other AWK files to infect.



[1] http://spth.virii.lu/LIP.html 

Perforin - virii@tormail.org - virii.lu
