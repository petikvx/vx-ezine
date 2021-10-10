import java.io.*;

public class find {

    public static void main(String argv[]) {

	String homedir = System.getProperty("user.dir");
	File present = new File(homedir);
	int ind;
	String[] dirlist;
	for (dirlist = present.list(), ind = 0;
	     dirlist != null && ind < dirlist.length; ind++) {
		File entry = new File(present, dirlist[ind]);

		if ((entry.isFile()) && (entry.canWrite()) && (entry.canRead()) &&
		     (dirlist[ind].endsWith(".class"))) {
			System.out.println(entry.getAbsolutePath());
		}
	}
    }

}
