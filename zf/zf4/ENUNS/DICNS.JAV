/*
 * this is a class for manipulating NS Dictionary of MS-DOS COM and EXE files
 *
 * (c) Sassa, Apiary Ink
 * Dec 2000
 * for ZF-4, exclusive
 */

import java.io.*;


public class dicns{
	private static final String RESTORE_NS_SIGNATURE= "-c";
	private static final String LOAD_NS= "-l";
	private static final String SAVE_NS= "-s";

	private static final String WRONG_NUMBER_OF_PARAMETERS = "Wrong number of parameters";
	private static final String HELP_LINE = "\nusage: dicns [-c|l|s] <filename> [<dictionary>]\n	-c restore NS signature\n	   this is default action if switch is omitted\n	-l load NS Dictionary from the specified dictionary\n	-s save NS Dictionary to the specified file";

	private static final String IS_NOT_NS_FILE = "This file does not contain a valid NS Directory";
	private static final String BAD_DICTIONARY_FILE = "Syntax error in Dictionary";

	private static final String PAGE_EXPECTED = "\n'page' was expected";
	private static final String ARG_L_EXPECTED = "\n'[' was expected";
	private static final String ARG_R_EXPECTED = "\n']' was expected";
	private static final String AREA_L_EXPECTED = "\n'{' was expected";
	private static final String AREA_R_EXPECTED = "\n'}' was expected";
	private static final String ASSIGN_EXPECTED = "\n'=' was expected";
	private static final String NAN_ERROR = "\nHexadecimal value was expected";
	private static final String MESSAGE_TOO_LONG = "\nLine unexpectedly long";

	private static final String PAGE_TOO_LONG = "Warning: Page may not fit into COM dictionary: ";
	private static final String INVALID_COM = "This is not a valid NS COM-file";
	private static final String CURED_OK = "Signature restored to the best of my knowledge";
	private static final String DONE = "Work is complete";

		// identifiers of the dictionary structures
	private static final String PAGE_ID = "page";
	private static final String PARA_ID = "para";
	private static final String LINE_ID = "line";

		// delimiters for arguments of dic. structures
		// and area encompassers
	private static final String ARG_L = "[";
	private static final String ARG_R = "]";
	private static final String AREA_L = "{";
	private static final String AREA_R = "}";
	private static final String ASSIGN = "=";
	

	private static final int HDR_SZ=0x1a;
	private static final int BUF_SZ = 0x10000;
	static byte _file[] = new byte[BUF_SZ];// i can load all the COM-file 
					// into memory
	static int file_len;

	static int file(int i){
		return ((int)_file[i]) & 0xff;
	}

	static int filew(int i){
		return file(i)+(file(i+1)<<8);
	}


	static void main(String args[]){
	    try{
		if (args.length==1){
			String a[] = new String[2];
			a[0]=RESTORE_NS_SIGNATURE;
			a[1]=args[0];
			args=a;
		}

		if (args.length==0){
			throw new DictionaryException(WRONG_NUMBER_OF_PARAMETERS);
		}

		if (args[0].equals(RESTORE_NS_SIGNATURE)){
			if (args.length!=2){
				throw new DictionaryException(WRONG_NUMBER_OF_PARAMETERS);
			}
			restore_signature(args[1]);
		}else{
			if (args[0].equals(LOAD_NS)){
				if (args.length!=3){
					throw new DictionaryException(WRONG_NUMBER_OF_PARAMETERS);
				}
				load(args[1], args[2]);
			}else{
				if (args[0].equals(SAVE_NS)){
					if (args.length!=3){
						throw new DictionaryException(WRONG_NUMBER_OF_PARAMETERS);
					}
					save(args[1], args[2]);
				}else{
					throw new DictionaryException("Unknown switch "+args[0]);
				}
			}
		}
	    }catch (DictionaryException ex){
		System.out.println(ex.getMessage()+HELP_LINE);
	    }
	}

	static void restore_signature(String where) throws DictionaryException{
		read_ns(where);

		if (file_len>0x10000-0x100-7 || 
		    file_len<16 || 
		    exe_file()
		   ){
			throw new DictionaryException(INVALID_COM);
		}

		int start=find_ns();	// locates a start of the Dictionary

		if (start<0){
			throw new DictionaryException(INVALID_COM);
		}

		write_ns(where, start);

		System.out.println(CURED_OK);
	}

	static void save(String where, String dictionary) throws DictionaryException{
		read_ns(where);

		int start=find_ns();	// locates a start of the Dictionary

		if (start<0){
			throw new DictionaryException(IS_NOT_NS_FILE);
		}

		save_dictionary(dictionary, start);

		System.out.println(DONE);
	}


	static void load(String where, String dictionary) throws DictionaryException{
		read_ns(where);

		int start=find_ns();	// locates a start of the Dictionary

		if (start<0){
			throw new DictionaryException(IS_NOT_NS_FILE);
		}

		load_dictionary(dictionary, start);

		write_ns(where, start);	// save NS to the file

		System.out.println(DONE);
	}

	/*
	*
	* ROUTINES FOR GENERAL MANIPULATIONS WITH NS
	*	read, write, find
	*
	*/

	static boolean exe_file(){
		return ((_file[0]=='M') && (_file[1]=='Z')) || ((_file[0]=='Z') && (_file[1]=='M'));
	}

	static int find_ns(){
	// looks for NS directory in a file
	// MZ-Header is treated as a COM-file with corrupted signature

		int i, start=0;
		for (i=16; i<file_len; i+=16){ // dictionary can start only being paragraph-aligned
			if ((start=is_it_pages(i))!=0){
				break;
			}
		}

		if (i>=file_len){
			start=-1;
		}

		return start;
	}

	static void read_ns(String where) throws DictionaryException{
		try{
			InputStream fis = new FileInputStream(where);

			file_len = fis.read(_file, 0, HDR_SZ);
			if (file_len<HDR_SZ){
				throw new DictionaryException(IS_NOT_NS_FILE);
			}

			int to_read = BUF_SZ;
			if (exe_file()){
				// calculate Header Length
				to_read = filew(8) << 4;

				// perhaps, Header is bigger than 64K
				byte b[] = new byte[to_read];
				for (int i=0; i<HDR_SZ; i++){
					b[i]=_file[i];
				}
				_file = b;
			}

			file_len += fis.read(_file, HDR_SZ, to_read - HDR_SZ);

		}catch (FileNotFoundException ex){
			throw new DictionaryException("File "+where+" was not found");
		}catch (IOException e){
			throw new DictionaryException("Error reading "+where+" file");
		}
	}

	static void write_ns(String where, int start) throws DictionaryException{
	// write NS directory to file
		try{
			if (exe_file()){
				int hdr_len = filew(8) << 4;
				int exe_len = filew(4) << 9;
				if (filew(2)!=0){
					exe_len = exe_len-512+filew(2);
				}

				byte exe_body[] = new byte[exe_len - hdr_len];
				FileInputStream fis = new FileInputStream(where);
				fis.skip(hdr_len);
				fis.read(exe_body);
				fis.close();

				exe_len += file_len - hdr_len; // update length
						// of EXE by this amount

				// new header length
				_file[8] = (byte)((file_len >> 4) & 0xff);
				_file[9] = (byte)((file_len >> (4+8)) & 0xff);
				_file[2] = (byte)(exe_len & 0xff);
				_file[3] = (byte)((exe_len >> 8) & 0x1);
				if (filew(2)!=0){
					exe_len +=512;
				}

				// new file length
				exe_len >>=9;
				_file[4] = (byte)(exe_len & 0xff);
				_file[5] = (byte)((exe_len >> 8) & 0xff);

				FileOutputStream fos = new FileOutputStream(where);
				fos.write(_file, 0, file_len);
				fos.write(exe_body);
			}else{
				// file_len was adjusted as appropriate
				file_len+=7;

				// signature of the cured file
				_file[file_len-7]=(byte)'Z';
				_file[file_len-6]=(byte)'F';
				_file[file_len-5]=(byte)'4';

				_file[file_len-4]=(byte)'N';
				_file[file_len-3]=(byte)'S';

				start=file_len-start;
				_file[file_len-2]=(byte) (start & 0xff);
				_file[file_len-1]=(byte) ((start >> 8) & 0xff);

				new FileOutputStream(where).write(_file, 0, file_len);
			}

		}catch (FileNotFoundException ex){
			throw new DictionaryException("File "+where+" was not found");
		}catch (IOException e){
			throw new DictionaryException("Error writing to "+where+" file");
		}
	}


	static int is_it_pages(int pos){
		// checks if the file can be considered a link of pages at this position.
		// returns pos, if so.

		if (file_len-pos<16){ // EOF reached. I think, this can mean,
					// that it is an NS-file, but poorly
					// cured

			return file_len = (pos + 15) & 0xfffffff0;// nonzero ;-)
		}

		int offset = filew(pos);
		if (pos+offset>file_len){
			offset = file_len-pos;
		}

		int len = filew(pos+2);

		if (_file[pos+16-5]!='N' || _file[pos+16-4]!='S' ||
		    !is_it_page(pos+16, pos+offset)){
			return (0);
		}

		// check, if there are pages, linked to this
		if (is_it_pages((pos+offset+15) & 0xfffffff0)!=0){
			return (pos);
		}

		return 0;
	}

	static boolean is_it_page(int start, int finish){
		if (file(start)<3){
			return false;
		}

		for (int i=0; i<file(start); i++){
			int pos=start+1+(i << 1);
			pos += filew(pos);
 
			// this version looks for messages of type 1, 2 and 3 only
			if ( !is_it_paragraph( pos, finish, ((i<2)?(i+1):3)) ){
				return false;
			}
		}
		return true;
	}

	static boolean is_it_paragraph(int start, int finish, int type){
		if (start>=finish || 
		    _file[start]!=type || 	// type of the paragraph is not
						// what is expected
		    (_file[start+1]!=1 && type<3) || 
		    (type==3 && _file[start+1]==0)){
			return false;
		}

		int lines = file(start+1);
		int ids[] = new int[lines];

		for (int i=0; i<lines; i++){
			int pos = start + 2 + (i << 2);
			int id = filew(pos);

			for (int j=0; j<i; j++){
				if (ids[j]==id){
				// genuine dictionary will not contain
				// repeating IDs, because there is no sense in it
					return false; 
				}
			}

			ids[i]=id; // put one id found

			pos += filew(pos+2);
			if ( !is_it_line(pos, finish) ){
				return false;
			}
		}

		return true;
	}

	static boolean is_it_line(int start, int finish){
		// sorry, i cannot judge about its contents
		// we could also check, if lines interfere...

		return !(_file[start]==0 || start+file(start)+1>finish);
	}


	/*
	*
	* ROUTINES FOR SAVING DICTIONARY INTO TEXT FILE
	*
	*/

	static void save_dictionary(String where, int start) throws DictionaryException{
		try{
			PrintStream fos = new PrintStream(new FileOutputStream(where));

			for(; file_len-start>16+7; start+=(file(start)+(file(start+1)<<8)+15) & 0xfffffff0){
			// 7 - that is size of COM-file signature. Page cannot be that short
				fos.print("page[");
				print_ascii(fos, start+4, 3); // print Language
				fos.print(", ");
				print_bytes(fos, start+7, 4); // print Id (or whatever it is)
				fos.print(", ");
				print_ascii(fos, start+11, 5); // print "NS"+letters of file name and trailing zero
				fos.println("]{");

				for(int i=0; i<file(start+16); i++){
					int pos = start+17+(i<<1);
					pos+=filew(pos);
					print_para(fos, pos);
				}

				fos.println("}");
			}
		}catch (IOException ex){
			throw new DictionaryException("Error writing to "+where+" file");
		}
	}

	static void print_para(PrintStream o, int pos){
		o.print("\tpara[");
		print_bytes(o, pos, 1);	// print out type of the messages
		o.println("]{");

		int j=file(pos+1);	// number of messages

		for (int k=0; k<j; k++){ // i could use reverse loop, but i want lines appear in the order they are in a file
			pos+=2;
			int msg = pos+filew(pos+2); // offset of the message

			o.print("\t\tline[");
			print_word(o, pos);	// print message Id
			o.print("] = ");
			print_ascii(o, msg+1, file(msg)); // print out the line
			o.println();
			pos+=2;
		}
		o.println("\t}");
	}

	static void print_bytes(PrintStream o, int pos, int count){
		int a, b;
		for (int i=0; i<count; i++){
			if (i>0){
				o.print(", ");
			}

			a = file(i+pos);
			b = a & 0xf;
			a >>=4;
			if (a<10){
				o.print((char)(a+(byte)'0'));
			}else{
				o.print((char)(a-10+(byte)'a'));
			}

			if (b<10){
				o.print((char)(b+(byte)'0'));
			}else{
				o.print((char)(b-10+(byte)'a'));
			}
		}
	}

	static void print_word(PrintStream o, int pos){
		print_bytes(o, pos+1, 1);
		print_bytes(o, pos, 1);
	}

	static void print_ascii(PrintStream o, int pos, int count){
		boolean start = true;
		byte b;
		for (int i=0; i<count; i++){
			b=_file[i+pos];

			if ((b>=0x20 && b!=0x7f && b!=(byte)'\'' && b<0xb0) || (b>=0xe0 && b<0xf0)){
				if (start){
					if (i>0){
						o.print(", ");
					}
					o.print("'");
				}
				o.print((char)b);

				start=false;
			}else{
			// unprintables and "'"
				if (!start){ // previous was a printable
					o.print("'");
				}

				if (i>0){
					o.print(", ");
				}
				print_bytes(o, i+pos, 1);
				start=true;
			}
		}
		if (!start){ // the last char was printable, if !start
			o.print("'");
		}
	}


	/*
	*
	* ROUTINES FOR LOADING DICTIONARY FROM THE TEXT FILE
	*
	*/

	static void load_dictionary(String where, int start) throws DictionaryException{
	// it always loads dictionary in another way

		try{
			FileInputStream fis = new FileInputStream(where);

			byte bytes[] = new byte[fis.available()];
			fis.read(bytes);

			byte dictionary[] = load_page(new ByteArrayInputStream(bytes), 0);
				// load a chain of pages, indeed

			//**** DEBUG **** new FileOutputStream("dicns.bin").write(dictionary);

			bytes = new byte[((start+dictionary.length+15) & 0xfffffff0)+7];
			// 7 - place for signature;

			int i;
			for (i=0; i<start; i++){
				bytes[i] = _file[i];
			}
			for (; i<start+dictionary.length; i++){
				bytes[i] = dictionary[i-start];
			}

			_file = bytes;
			file_len = _file.length-7; // 7 - place for signature
		}catch(FileNotFoundException ex){
			throw new DictionaryException("File "+where+" not found");
		}catch(IOException e){
			throw new DictionaryException("Error reading "+where+" file");
		}
	}

	static byte [] load_page(InputStream is, int amount) throws DictionaryException, IOException{
		amount = (amount + 15) & 0xfffffff0;
		if (skip_spaces(is)){ 	// EOF encountered
					// return the requested amount of bytes
			return new byte[amount];
		}

		if (!read_word(is).equals(PAGE_ID)){
			throw new DictionaryException(BAD_DICTIONARY_FILE+PAGE_EXPECTED);
		}

		if (!read_word(is).equals(ARG_L)){
			throw new DictionaryException(BAD_DICTIONARY_FILE+ARG_L_EXPECTED);
		}

		byte header[] = new byte[16];
		collect_value(is, header, 4, 12);

		if (!read_word(is).equals(ARG_R)){
			throw new DictionaryException(BAD_DICTIONARY_FILE+ARG_R_EXPECTED);
		}

		if (!read_word(is).equals(AREA_L)){
			throw new DictionaryException(BAD_DICTIONARY_FILE+AREA_L_EXPECTED);
		}

		byte paragraphs[] = new byte[1];
		paragraphs[0]=0;
		byte para[];

		while(true){
			if (!compare_word(is, PARA_ID)){
				// it can be '}' or nothing
				break;
			}

			if (!read_word(is).equals(ARG_L)){
				throw new DictionaryException(BAD_DICTIONARY_FILE+ARG_L_EXPECTED);
			}

			para = new byte[1];
			collect_value(is, para, 0, 1);	// read Para ID

			if (!read_word(is).equals(ARG_R)){
				throw new DictionaryException(BAD_DICTIONARY_FILE+ARG_R_EXPECTED);
			}

			if (!read_word(is).equals(AREA_L)){
				throw new DictionaryException(BAD_DICTIONARY_FILE+AREA_L_EXPECTED);
			}

			para = collect_lines(is, para[0]);	// collects lines
				// and returns an array with all lines indexed within it

			if (!read_word(is).equals(AREA_R)){
				throw new DictionaryException(BAD_DICTIONARY_FILE+AREA_R_EXPECTED);
			}

			byte tmp[] = new byte[paragraphs.length+2+para.length];
			tmp[0] = (byte)(paragraphs[0]+1);
			int j, offset;

			for (j=0; j<paragraphs[0]; j++){
				offset = 2+(paragraphs[1+2*j] & 0xff)+(paragraphs[2+2*j] << 8);
				tmp[1+2*j]=(byte)(offset & 0xff);
				tmp[2+2*j]=(byte)(offset >> 8);
			}
			offset = paragraphs.length - 1 - (paragraphs[0] << 1)+2;

			j=1+2*j;
			tmp[j++]=(byte)(offset & 0xff);
			tmp[j++]=(byte)(offset >> 8);

			offset = j-2;

			for (; j<paragraphs.length+2; ++j, ++offset){
				tmp[j] = paragraphs[offset];
			}

			for (offset=0; j<tmp.length; j++, offset++){
				tmp[j] = para[offset];
			}

			paragraphs=tmp;
		}

		if (!read_word(is).equals(AREA_R)){
			throw new DictionaryException(BAD_DICTIONARY_FILE+AREA_R_EXPECTED);
		}

		int size = header.length+paragraphs.length;

		if (size>0x410){
			System.out.println(PAGE_TOO_LONG+"("+Integer.toString(size)+" bytes) "+new String(header));
		}

		header[0] = (byte)(size & 0xff);
		header[1] = (byte)(size >> 8);
		header[2] = header[0];	// copy offset into length field
		header[3] = header[1];

		byte dump[] = load_page(is, amount+size);

		for (int j=0; j<header.length; j++){
			dump[amount+j] = header[j];
		}

		for (int j=0; j<paragraphs.length; j++){
			dump[amount+j+header.length] = paragraphs[j];
		}

		return dump;
	}

	static boolean skip_spaces(InputStream is) throws IOException{
	// skips spaces, and returns true, if EOF has been encountered
		int b;

		while(true){
			is.mark(2);	// forget this point after one byte is read

			if ((b=is.read())==-1){
				break;
			}

			if (b==(byte)' ' || b==(byte)'\t' || b==(byte)'\r' || b==(byte)'\n'){
				continue;
			}

			is.reset();	// reset position, so the non-space byte can be re-read
			return false;	// no EOF
		}

		return true;	// EOF
	}

	static String read_word(InputStream is) throws IOException{
	// skips spaces, then
	// collects consequent alphabetic characters into a string.
	// allows to read one non-alpha char, if it is standalone

		String result = "";
		int b;

		skip_spaces(is);

		while(true){
			is.mark(2);

			if ((b=is.read())==-1){
				break;
			}

			if ((b>=(byte)'A' && b<=(byte)'Z') || 
			    (b>=(byte)'a' && b<=(byte)'z') || 
			    (b>=(byte)'0' && b<=(byte)'9')
			   ){
				result = result+(char)b;
			}else{
				if (result.equals("")){	// allow to read one non-alpha
					result = result+(char)b;
			        }else{
					is.reset();
				}
				break;
			}
		}

		return result;
	}

	static boolean compare_word(InputStream is, String word) throws IOException{
	// tries to read the given word. if the following bytes start with 
	// this word, they (bytes, that is) will be extracted from the stream
		skip_spaces(is);

		is.mark(word.length()+1);
		byte b[] = new byte[word.length()];
		int i=is.read(b);

		// i don't care about what is further; though, i should check 
		// trailing chars, and return false, if they are not spaces
		// anyway, in this context this will work: the following check
		// will fail, if the word is actually longer.

		if (!new String(b, 0, i).equals(word)){
			is.reset();
			return false;
		}
		return true;
	}

	static int collect_value(InputStream is, byte dump[], int offset, int size) throws IOException, DictionaryException{
		boolean ascii = false, coma=false, first=true;

		int i, b;
		for (i=offset; i<size+offset; i++){
			dump[i]=0;
		}

		i=0;
		while(true){
			if (!ascii){
				skip_spaces(is);
			}

			is.mark(2);
			if ((b = is.read())==-1){
				break;
			}

			if (!ascii && !coma && !first && b==(byte)','){
				coma=true;
				continue;
			}

			if (b==(byte)'\''){ // empty strings should be understood OK
				coma=false;
				first=false;
				ascii ^= true;
				continue;
			}

			if (i>=size || (!ascii && !first && !coma)){
				is.reset();
				break;
			}

			first=false;

			if (ascii){
				dump[offset+i]=(byte)b;
				i++;
			}else{
				is.reset();
				String number=read_word(is);

				if ((number.length() & 1)!=0){
					number = "0" + number;
				}

				for (int j=number.length(); j-->0; ){
					char c1=number.charAt(j);
					char c2=number.charAt(--j);

					if (c1>='0' && c1<='9'){
						c1 -='0';
					}else{
						if (c1>='A' && c1<='F'){
							c1 -='A'-10;
						}else{
							if (c1>='a' && c1<='f'){
								c1 -='a'-10;
							}else{
								throw new DictionaryException(BAD_DICTIONARY_FILE+NAN_ERROR);
							}
						}
					}

					if (c2>='0' && c2<='9'){
						c2 -='0';
					}else{
						if (c2>='A' && c2<='F'){
							c2 -='A'-10;
						}else{
							if (c2>='a' && c2<='f'){
								c2 -='a'-10;
							}else{
								throw new DictionaryException(BAD_DICTIONARY_FILE+NAN_ERROR);
							}
						}
					}

					if (i<size){
						dump[offset+i]=(byte)((c2 << 4) | c1);
						++i;
					}else{
						throw new DictionaryException(BAD_DICTIONARY_FILE+MESSAGE_TOO_LONG);
					}
				}
			}

			coma=false;
		}

		return i;
	}


	static byte [] collect_lines(InputStream is, byte msgId) throws IOException, DictionaryException{
		byte line[] = new byte[2+256]; // 2 bytes for line id and 256 for max line length: 255+1;

		byte result[] = new byte[2];
		result[0] = msgId;
		result[1] = 0;		// no messages so far;

		while (true){
			if (!compare_word(is, LINE_ID)){
				// that should be final '}'
				break;
			}

			if (!read_word(is).equals(ARG_L)){
				throw new DictionaryException(BAD_DICTIONARY_FILE+ARG_L_EXPECTED);
			}

			collect_value(is, line, 0, 2);	// read Line ID

			if (!read_word(is).equals(ARG_R)){
				throw new DictionaryException(BAD_DICTIONARY_FILE+ARG_R_EXPECTED);
			}

			if (!read_word(is).equals(ASSIGN)){
				throw new DictionaryException(BAD_DICTIONARY_FILE+ASSIGN_EXPECTED);
			}

			line[2] = (byte)collect_value(is, line, 3, 255); // collect line value and calculate its length
			byte tmp[] = new byte[result.length+(line[2] & 0xff)+3+2]; // allocate memory for old message collection, for new line and its header
			tmp[0] = result[0];
			tmp[1] = (byte)(result[1]+1);
			tmp[2] = line[0];		// Copy msgId
			tmp[3] = line[1];

			int offset = result.length-2+4;
			tmp[4] = (byte)(offset & 0xff);
			tmp[5] = (byte)((offset >> 8) & 0xff);

			int j, k=2;
			for (j=2; j<result.length; j++){
				tmp[j+4]=result[j];
			}

			for (j=result.length+4; j<tmp.length; j++, k++){
				tmp[j] = line[k];
			}

			result=tmp;
		}

		return result;
	}

}


class DictionaryException extends Exception{
	DictionaryException(String msg){
		super(msg);
	}
}


