<!--- Copyright (c) 2011 Paul Connell <certman@paulconnell.info> --->
<cfif NOT IsDefined("form.alias") OR NOT Len(Trim(form.alias))>
	<cfif FileExists("#cffile.serverdirectory#/#cffile.serverfile#")>
		<cffile action="Delete" file="#cffile.serverdirectory#/#cffile.serverfile#">
	</cfif>
	<cflocation url="addCertForm.cfm?error=You must provide a valid Key Alias">
</cfif>

<cfinvoke component="KeyStoreManager" method="init" returnvariable="KeyStoreManager">

<cfif KeyStoreManager.containsAlias(form.alias)>
	<cfif FileExists("#cffile.serverdirectory#/#cffile.serverfile#")>
		<cffile action="Delete" file="#cffile.serverdirectory#/#cffile.serverfile#">
	</cfif>
	<cflocation url="addCertForm.cfm?error=The alias '#form.alias#' is already used.  Please choose another alias or delete the existing key.">
</cfif>

<cftry>
	<cffile action="upload" filefield="form.pubkey" nameconflict="makeunique" destination="#Expandpath('./tmp')#">
	<cfcatch type="Application">
		<cfif FileExists("#cffile.serverdirectory#/#cffile.serverfile#")>
			<cffile action="Delete" file="#cffile.serverdirectory#/#cffile.serverfile#">
		</cfif>
		<cflocation url="addCertForm.cfm?error=You must provide a valid key file."><cfabort>
	</cfcatch>
</cftry>

<cftry>
	<cfset KeyClashAlias = KeyStoreManager.add(form.alias,"#cffile.serverdirectory#/#cffile.serverfile#")>
	<cfcatch type="Any">
		<cfif cfcatch.type EQ "java.security.cert.CertificateException">
			<cfif FileExists("#cffile.serverdirectory#/#cffile.serverfile#")>
				<cffile action="Delete" file="#cffile.serverdirectory#/#cffile.serverfile#">
			</cfif>
			<cflocation url="addCertForm.cfm?error=Invalid or corrupt key file."><cfabort>
		</cfif>
	</cfcatch>
</cftry>

<cfif Len(Trim(KeyClashAlias))>
	<cfif FileExists("#cffile.serverdirectory#/#cffile.serverfile#")>
		<cffile action="Delete" file="#cffile.serverdirectory#/#cffile.serverfile#">
	</cfif>
	<cflocation url="addCertForm.cfm?error=Certificate is already in the store as '#KeyClashAlias#'."><cfabort>
</cfif>

<cfif FileExists("#cffile.serverdirectory#/#cffile.serverfile#")>
	<cffile action="Delete" file="#cffile.serverdirectory#/#cffile.serverfile#">
</cfif>

<cflocation url="index.cfm?restartreq=1&message=Certificate successfully added to the keystore." addtoken="false">
