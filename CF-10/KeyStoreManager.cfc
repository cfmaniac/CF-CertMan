// Copyright (c) 2008 Paul Connell <certman@paulconnell.info>

component displayName="KeyStoreManager" output="false" {

	Variables.KeyStorePath = '';
	//  if this is not your cacerts password, alter it (this is the default)
	Variables.KeyStorePassword = 'changeit';
	Variables.ks = '';

	public function init() {
		var SystemSettings = CreateObject('java','java.lang.System');
		var FileSeparator = SystemSettings.getProperty("file.separator");
		Variables.KeyStorePath = "#SystemSettings.getProperty('java.home')##FileSeparator#lib#FileSeparator#security#FileSeparator#cacerts";
		// load the keystore into the object
		Load();
		return This;		
	} 


	public function listAll() {
		var CertificateArray = ArrayNew(2);
		var AliasEnum = Variables.ks.aliases();
		var ThisCertificate = '';
		var AliasString = '';
		var ArrayLength = 0;	

		while( AliasEnum.hasMoreElements() )	{
			ArrayLength = ArrayLen(CertificateArray)+1;
			AliasString = AliasEnum.nextElement().toString();
			ThisCertificate = CreateObject("component","Certificate").init(Variables.ks.getCertificate(AliasString));
			CertificateArray[ArrayLength][1] = AliasString;
			CertificateArray[ArrayLength][2] = ThisCertificate;			
		} // End While

		return ArraySort2D(CertificateArray, 1, "textnocase");
	}

	public function containsAlias(required Alias) {
		return Variables.ks.containsAlias(Arguments.Alias);
	}

	public function add(required Alias, required CertificateFilePath) {
		var CertificateArray = ArrayNew(2);
		var AliasEnum = Variables.ks.aliases();
		var ThisCertificate = '';
		var AliasString = '';
		var ArrayLength = 0;

		try {
			InputStream = CreateObject("java","java.io.FileInputStream").init(Arguments.CertificateFilePath);
			BufferedInputStream = CreateObject("java","java.io.BufferedInputStream").init(InputStream);
			CertificateFactory = CreateObject("java", "java.security.cert.CertificateFactory").getInstance("X.509");
			Certificate = CertificateFactory.generateCertificate(BufferedInputStream);
			InputStream.close();
			
			if (NOT Len(Trim(Variables.ks.getCertificateAlias(Certificate)))){
				Variables.ks.setCertificateEntry(Arguments.Alias, Certificate);		
				Store();
				return "";
			} else {
				return Variables.ks.getCertificateAlias(Certificate);
			}
		} catch( any e ) {
			InputStream.close();
			rethrow;
		}	
	}

	public function delete(required CertificateAlias) {
		if (Variables.ks.containsAlias(Arguments.CertificateAlias)) {
			Variables.ks.deleteEntry(Arguments.CertificateAlias);
			Store();
		}
	}

	public function read(required CertificateAlias) {
		var ThisCertificate = "";
		if (Variables.ks.containsAlias(Arguments.CertificateAlias))	{
			ThisCertificate = CreateObject("component","Certificate").init(Variables.ks.getCertificate(Arguments.CertificateAlias));
		}
		return ThisCertificate;
	}

	private function load() {
		var KeyStore = '';
		var InputStream = '';

		try {
			lock name="KeyStoreFileLock" timeout="5" type="readonly" {
				KeyStore = CreateObject("java","java.security.KeyStore");
				Variables.ks = KeyStore.getInstance(KeyStore.getDefaultType());
				InputStream = CreateObject("java","java.io.FileInputStream").init(Variables.KeyStorePath);
				Variables.ks.load(InputStream, Variables.KeyStorePassword.toCharArray());
				InputStream.close();			
			}
		} catch( any e ) {
			InputStream.close();
			rethrow;
		}
	}

	private function store() {
		var OutputStream = '';

		try {
			lock name="KeyStoreFileLock" timeout="5" type="exclusive" {
				OutputStream = CreateObject("java","java.io.FileOutputStream").init(Variables.KeyStorePath);
				Variables.ks.store(OutputStream, Variables.KeyStorePassword.toCharArray());
				OutputStream.close();		
			}
		} catch( any e ) {
			OutputStream.close();
			rethrow;
		}
	}

/**
 * Sorts a two dimensional array by the specified column in the second dimension.
 * 
 * @return Returns an array. 
 * @author Robert West (robert.west@digiphilic.com) 
 * @version 1, October 8, 2002 
 */
function ArraySort2D(arrayToSort, sortColumn, type) {
    var order = "asc";
	var delim = "`";
    var i = 1;
    var j = 1;
    var thePosition = "";
    var theList = "";
    var arrayToReturn = ArrayNew(2);
    var sortArray = ArrayNew(1);
    var counter = 1;
    if (ArrayLen(Arguments) GT 3){
        order = Arguments[4];
    }
    for (i=1; i LTE ArrayLen(arrayToSort); i=i+1) {
        ArrayAppend(sortArray, arrayToSort[i][sortColumn]);
    }
    theList = ArrayToList(sortArray, delim);
    ArraySort(sortArray, type, order);
    for (i=1; i LTE ArrayLen(sortArray); i=i+1) {
        thePosition = ListFind(theList, sortArray[i], delim);
        theList = ListDeleteAt(theList, thePosition, delim);
        for (j=1; j LTE ArrayLen(arrayToSort[thePosition]); j=j+1) {
            arrayToReturn[counter][j] = arrayToSort[thePosition][j];
        }
        ArrayDeleteAt(arrayToSort, thePosition);
        counter = counter + 1;
    }
    	return arrayToReturn;
	}	
}