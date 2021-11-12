PROJECT TITLE: Suicide
PURPOSE OF PROJECT: Little Java virus
VERSION or DATE: 1.0
HOW TO START THIS PROJECT: Use the class "Suicide" as main class
AUTHORS: R3s1stanc3 [vxnetw0rk]
USER INSTRUCTIONS:

Suicide is a little Java virus, I wrote when Perforin told me about the idea, to use the printer for the payload.
I tried to write such a payload in Java, because I thought it would work on every plattform (but it didn't)
So I wrote a few more functions and here it is:
    SUICIDE

Infection: 
     - copy the hostfile to ".filename" and hide it if we run under windows
     - copy the virus to "filename"
     - read ".filename" (the hostfile) and add its content to "filename" (the virus)
     - delete ".filename"
     
Run infected file
     - check if the current file is infected ( Virii -> isInfected ( file, splitStr ) ) if not delete the current file
     - split the current file at the splitstring and write the second part to ".filename" and hide it under windows
     - run & delete ".filename"
     
Payloads:
    Linux:
     - forkbomb
    Windows:
     - print the class "Suicide"
    Both:
     - flood the current directory with rand ( 1000 ) textfiles
     
thanks to all people on the internet 
and special greetings to:
    ringi - for some codes
    virii/Perforin - for bringing me to #vxnet
    
 written by R3s1stanc3 [vxnetw0rk]
            r3s1stanc3@tormail.org
            www.r3s1stanc3.co.cc