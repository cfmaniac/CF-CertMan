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
	
	<!--- certificate common name (some certs do not have this, try to fall back to OU)--->
	<cffunction name="getCommonName" output="false">
		<cfif Len(Trim(Variables.ThisCertificate.getSubjectDN().getCommonName()))>
			<cfreturn Variables.ThisCertificate.getSubjectDN().getCommonName()>
		<cfelse>
			<!--- return the ORG/OU instead --->
			<cfreturn "#Variables.ThisCertificate.getSubjectDN().getOrganization()#/#Variables.ThisCertificate.getSubjectDN().getOrganizationalUnit()#">
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