To compile Virus.java do the following:

1)  run javac -O Virus.java
2)  run java VirusInfo Virus.class
3)  enter the information into the source
4)  run javap -c Virus>javap.txt
5)  edit javap.txt
6)  scroll to the bottom where the following appears
    xx invokevirtual #yy <Method void StrangeBrew()>
7)  enter yy into the source as the virus_methodref
8)  run javac -O Virus.java
9)  use a hex editor to make the file length%101 = 0
10) run java Virus

A compiled version Virus.class is located in the classes directory