
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
