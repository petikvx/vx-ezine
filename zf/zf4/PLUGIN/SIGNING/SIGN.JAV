/*
 * application for signing files for distribution.
 * (c) 2001, Sassa, Apiary Ink
 * ZF4
 */

import java.io.*;
import java.security.*;
import java.security.spec.*;


public class Sign {

	public static final int KEY_SZ = 1024;
	public static final String PKALG = "DSA";
	public static final String ALGORITHM = "SHA1withDSA";
	public static final String HELPSCREEN = "usage: Sign [-gsv] <file1> [<signature>] <key>\n\t-g Generate key pair.\n\t\tSpecify <file1> and <key> - \n\t\tfiles for storing Secret Key and Public Key respectively\n\t-s Sign <file1> using Secret Key <key> and store\n\t\tits digest to <signature>\n\t-v Verify <signature> of a <file1> using Public Key <key>.\n\t\tThis is the default action, if no switches were specified";

	public static final String BAD_SIGNATURE = "\n\n*** Signature is bad! ***\n";
	public static final String SIGNATURE_OK = "Signature verifies\n";

	public static final int BUF_SZ = 60000;

	public static void main(String args[]){
	   try{
		if (args.length==3 && args[0].equals("-g")){ // generate keys
			KeyPairGenerator kpg = KeyPairGenerator.getInstance(PKALG);
			kpg.initialize(KEY_SZ);	// key size

			KeyPair kp = kpg.genKeyPair();

			FileOutputStream skos = new FileOutputStream(args[1]);
			skos.write(kp.getPrivate().getEncoded());

			FileOutputStream pkos = new FileOutputStream(args[2]);
			pkos.write(kp.getPublic().getEncoded());

			// System.out.println("Secret: "+kp.getPrivate().getFormat());
			// System.out.println("Public: "+kp.getPublic().getFormat());
			// why do they store SK and PK in different formats? 8-(
		}else{
		  KeyFactory kf = null;
		  Signature signature = null;
		  byte [] key = null;	// key material

		  if (args.length>=3){
			kf = KeyFactory.getInstance(PKALG);
			signature = Signature.getInstance(ALGORITHM);

			FileInputStream kis = new FileInputStream(args[args.length-1]);
			key = new byte[kis.available()];

			kis.read(key);
		  }

		  if (args.length==4 && args[0].equals("-s")){ // sign
			FileInputStream fis = new FileInputStream(args[1]);
			FileOutputStream fos = new FileOutputStream(args[2]);

			signature.initSign(kf.generatePrivate(new PKCS8EncodedKeySpec(key)));
			int i;
			byte [] b=new byte[BUF_SZ];
			do{
				i=fis.read(b);
				signature.update(b, 0, i);
			}while(i==BUF_SZ);

			fos.write(signature.sign());
		  }else{
		    int shift = args.length-3;	// where file names start
		    if ((shift==1 && args[0].equals("-v")) ||
			(shift==0 && args[0].charAt(0)!='-')){ // verify
			
			FileInputStream fis = new FileInputStream(args[shift]);
			FileInputStream fos = new FileInputStream(args[shift+1]);

			signature.initVerify(kf.generatePublic(new X509EncodedKeySpec(key)));
			int i;
			byte [] b=new byte[BUF_SZ];
			do{
				i=fis.read(b);
				signature.update(b, 0, i);
			}while(i==BUF_SZ);

			b=new byte[fos.available()];
			fos.read(b);

			String result=BAD_SIGNATURE;
			if (signature.verify(b)){
				result = SIGNATURE_OK;
			}

			System.out.println(result);
		    }else{
			System.out.println(HELPSCREEN);
		    }
		  }
		}
	   }catch(Exception ex){
		ex.printStackTrace();
	   }
	}


}

