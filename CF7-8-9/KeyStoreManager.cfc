<!--- Copyright (c) 2008 Paul Connell <certman@paulconnell.info> --->

<cfcomponent displayname="KeyStoreManager" hint="Methods and data for accessing the Java Keystore" output="false">

	<cfset Variables.KeyStorePath = "">
	<!--- if this is not your cacerts password, alter it (this is the default) --->
	<cfset Variables.KeyStorePassword = "changeit">
	<cfset Variables.ks = "">

	<cffunction name="init" output="false" access="public">
		<cfscript>
		var SystemSettings = CreateObject("java","java.lang.System");
		var FileSeparator = SystemSettings.getProperty("file.separator");
		Variables.KeyStorePath = "#SystemSettings.getProperty('java.home')##FileSeparator#lib#FileSeparator#security#FileSeparator#cacerts";
		// load the keystore into the object
		Load();
		return This;
		</cfscript>
	</cffunction>

	<cffunction name="listAll" output="false" access="public">
		<cfset var CertificateArray = ArrayNew(2)>
		<cfset var AliasEnum = Variables.ks.aliases()>
		<cfset var ThisCertificate = "">
		<cfset var AliasString = "">
		<cfset var ArrayLength = 0>
		<cfloop condition="#AliasEnum.hasMoreElements()#">
			<cfscript>
			ArrayLength = ArrayLen(CertificateArray)+1;
			AliasString = AliasEnum.nextElement().toString();
			ThisCertificate = CreateObject("component","Certificate").init(Variables.ks.getCertificate(AliasString));
			CertificateArray[ArrayLength][1] = AliasString;
			CertificateArray[ArrayLength][2] = ThisCertificate;
			</cfscript>
		</cfloop>
		<cfset sortedCertArray=ArraySort2D(CertificateArray, 1, "textnocase")>
		<cfreturn sortedCertArray>
	</cffunction>

	<cffunction name="containsAlias" output="false" access="public">
		<cfargument name="Alias" required="true">
		<cfreturn Variables.ks.containsAlias(Arguments.Alias)>
	</cffunction>

	<cffunction name="add" output="false" access="public">
		<cfargument name="Alias" required="true">
		<cfargument name="CertificateFilePath" required="true">
		<cfset var InputStream = "">
		<cfset var BufferedInputStream = "">
		<cfset var CertificateFactory = "">
		<cfset var Certificate = "">
		<cftry>
		<cfscript>
		InputStream = CreateObject("java","java.io.FileInputStream").init(Arguments.CertificateFilePath);
		BufferedInputStream = CreateObject("java","java.io.BufferedInputStream").init(InputStream);
		CertificateFactory = CreateObject("java", "java.security.cert.CertificateFactory").getInstance("X.509");
		Certificate = CertificateFactory.generateCertificate(BufferedInputStream);
		InputStream.close();
		
		if (NOT Len(Trim(Variables.ks.getCertificateAlias(Certificate))))
		{
			Variables.ks.setCertificateEntry(Arguments.Alias, Certificate);		
			Store();
			return "";
		}
		else
		{
			return Variables.ks.getCertificateAlias(Certificate);
		}
		</cfscript>
		<cfcatch type="any">
			<cfset InputStream.close()>
			<cfrethrow>
		</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="delete" output="false" access="public">
		<cfargument name="CertificateAlias" required="true">
		<cfscript>
		if (Variables.ks.containsAlias(Arguments.CertificateAlias))
		{
			Variables.ks.deleteEntry(Arguments.CertificateAlias);
			Store();
		}
		</cfscript>
	</cffunction>

	<cffunction name="read" output="false" access="public">
		<cfargument name="CertificateAlias" required="true">
		<cfscript>
		var ThisCertificate = "";
		if (Variables.ks.containsAlias(Arguments.CertificateAlias))
		{
			ThisCertificate = CreateObject("component","Certificate").init(Variables.ks.getCertificate(Arguments.CertificateAlias));
		}
		return ThisCertificate;
		</cfscript>
	</cffunction>

	<cffunction name="load" output="false" access="private">
		<cfset var KeyStore = "">
		<cfset var InputStream = "">
		<cftry>
		<cflock name="KeyStoreFileLock" timeout="5" type="readonly">
			<cfscript>
			KeyStore = CreateObject("java","java.security.KeyStore");
			Variables.ks = KeyStore.getInstance(KeyStore.getDefaultType());
			InputStream = CreateObject("java","java.io.FileInputStream").init(Variables.KeyStorePath);
			Variables.ks.load(InputStream, Variables.KeyStorePassword.toCharArray());
			InputStream.close();
			</cfscript>
		</cflock>
		<cfcatch type="any">
			<cfset InputStream.close()>
			<cfrethrow>
		</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="store" output="false" access="private">
		<cfset var OutputStream = "">
		<cftry>
		<cflock name="KeyStoreFileLock" timeout="5" type="exclusive">
			<cfscript>
			OutputStream = CreateObject("java","java.io.FileOutputStream").init(Variables.KeyStorePath);
        	Variables.ks.store(OutputStream, Variables.KeyStorePassword.toCharArray());
	        OutputStream.close();
		</cfscript>
		</cflock>
		<cfcatch type="any">
			<cfset OutputStream.close()>
			<cfrethrow>
		</cfcatch>
		</cftry>
	</cffunction>
	
	<cfscript>
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
</cfscript>
	
</cfcomponent>