<!--- Copyright (c) 2011 Paul Connell <certman@paulconnell.info> --->
<cfinclude template="../header.cfm">

<cfinvoke component="KeyStoreManager" method="init" returnvariable="KeyStoreManager">

<cfset Certificate = KeyStoreManager.read(url.alias)>

<h2 class="pageHeader"> SSL Certificates &gt; Certificate Management &gt; Certificate &quot;<cfoutput>#url.alias#</cfoutput>&quot;</h2>
<form action="index.cfm" method="get">
	<input type="submit" name="back" value="Back to Certificate List">
</form>
<hr />
<cfoutput><pre>#Wrap(Certificate.asString(),155)#</pre></cfoutput>
<hr />
<form action="index.cfm" method="get">
	<input type="submit" name="back" value="Back to Certificate List">
</form>

<cfinclude template="footer.cfm">