<!--- Copyright (c) 2011 Paul Connell <certman@paulconnell.info> --->
<cfcomponent displayname="Certificate" hint="Data and Methods representing an SSL certificate" output="false">

	<cfset Variables.ThisCertificate = "">

	<cffunction name="init" output="false" access="public">
		<cfargument name="CertificateObject" required="true">
		<cfset Variables.ThisCertificate = Arguments.CertificateObject>
		<cfreturn This>
	</cffunction>
	
	<!--- return this certificate entry as a raw string --->
	<cffunction name="asString" output="false" access="public">
		<cfreturn Variables.ThisCertificate.toString()>
	</cffunction>
	
	<!--- certificate common name (some certs do not have this)--->
	<cffunction name="getCommonName" output="false">
		<cfset var certificateDetailsList = Trim(Variables.ThisCertificate.getSubjectX500Principal().getName())>
		<cfset var certificateDetailsStruct = StructNew()>
		<cfif ListLen(certificateDetailsList)>
			<!--- This is a comma delimited list, with key value pairs - extract them --->
			<cfloop from="1" to="#ListLen(certificateDetailsList)#" step="1" index="i">
				<cfset currentItem = ListGetAt(certificateDetailsList,i,',')>
				<cfset certificateDetailsStruct[listfirst(currentitem,'=')] = listLast(currentitem,'=')>
			</cfloop>
			<cfif StructKeyExists(certificateDetailsStruct,"CN")>			
				<cfreturn Trim(certificateDetailsStruct["CN"])>
			<cfelseif StructKeyExists(certificateDetailsStruct,"OU")>			
				<cfreturn Trim(certificateDetailsStruct["OU"])>			
			</cfif>
		<cfelse>
			<cfreturn "Unknown">
		</cfif>
	</cffunction>
	
	<cffunction name="getNotBefore" output="false" access="public">
		<cfreturn Variables.ThisCertificate.getNotBefore()>
	</cffunction>
	
	<cffunction name="getNotAfter" output="false" access="public">
		<cfreturn Variables.ThisCertificate.getNotAfter()>
	</cffunction>
	
	<cffunction name="getPublicKeyBase64">
		<cfreturn Trim("-----BEGIN CERTIFICATE-----#Chr(13)##Chr(10)##Wrap(ToBase64(Variables.ThisCertificate.getEncoded()),64,true)#-----END CERTIFICATE-----")>
	</cffunction>
	
</cfcomponent>
