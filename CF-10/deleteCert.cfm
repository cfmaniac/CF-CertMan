<!--- Copyright (c) 2011 Paul Connell <certman@paulconnell.info> --->
<cfinvoke component="KeyStoreManager" method="init" returnvariable="KeyStoreManager">
<cfset KeyStoreManager.delete(url.alias)>

<cflocation url="index.cfm?restartreq=1&message=Certificate successfully deleted from the keystore.">


