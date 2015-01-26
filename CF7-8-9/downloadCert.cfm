<!--- Copyright (c) 2011 Paul Connell <certman@paulconnell.info> --->
<cfinvoke component="KeyStoreManager" method="init" returnvariable="KeyStoreManager">
<cfset Certificate = KeyStoreManager.read(url.alias)>
<cfheader name="content-disposition" value="attachment; filename=#url.alias#.cer"/>
<cfcontent type="text/plain" reset="true"><cfoutput>#Certificate.getPublicKeyBase64()#</cfoutput>


