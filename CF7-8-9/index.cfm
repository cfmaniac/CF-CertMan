<!--- Copyright (c) 2011 Paul Connell <certman@paulconnell.info> --->
<cfinvoke component="KeyStoreManager" method="init" returnvariable="KeyStoreManager">
<cfset CertificateArray = KeyStoreManager.listAll()>
<cfinclude template="../header.cfm">

<h2 class="pageHeader"> SSL Certificates &gt; Certificate Management</h2>

<p>Certificates listed below are used by tags such as CFHTTP/CFEXCHANGE to access SSL sites.  To access a self-signed SSL site, add the certificate to the keystore.</p>
<form action="addCertForm.cfm" method="get">
<input type="submit" name="addCert" value="Add a New Certificate">
</form>
<cfif isDefined("url.message")>
	<p style="font-size:larger;color:ff0000;"><cfoutput>#url.message#</cfoutput></p>
</cfif>
<table border="0" cellpadding="5" cellspacing="0" width="100%">
<tr>
	<td bgcolor="#E2E6E7" class="cellBlueTopAndBottom">
		<b>Certificates</b>
	</td>
</tr>
<tr>
	<td>
		<table border="0" cellpadding="2" cellspacing="0" width="100%">
		<tr>
			<th scope="col" nowrap bgcolor="#F3F7F7" class="cellBlueTopAndBottom">
				<strong> Actions </strong></th>
			<th scope="col" nowrap bgcolor="#F3F7F7" class="cellBlueTopAndBottom">				
				<strong> Alias </strong>
			</th>
			<th scope="col" nowrap bgcolor="#F3F7F7" class="cellBlueTopAndBottom">				
				<strong> Not Before </strong>
			</th>
			<th scope="col" nowrap bgcolor="#F3F7F7" class="cellBlueTopAndBottom">				
				<strong> Not After </strong>
			</th>
			<th scope="col" nowrap bgcolor="#F3F7F7" class="cellBlueTopAndBottom">				
				<strong> Common Name </strong>
			</th>
		</tr>
		<cfloop from="1" to="#ArrayLen(CertificateArray)#" step="1" index="i">
		<tr bgcolor="ffffff">
				<td nowrap class="cell3BlueSides">
					<table border="0" cellpadding="2" cellspacing="0" align="center">
					<tr>
						<td align="center">
							<cfoutput>
							<a href="downloadCert.cfm?alias=#CertificateArray[i][1]#"
							   onmouseover="window.status='Download PEM'; return true;"
							   onmouseout="window.status=''; return true;"
							   title="Download PEM"><img src="/CFIDE/administrator/images/download.gif" vspace="2" hspace="2" width="16" height="16" alt="Download PEM" title="Download PEM" border="0"></a>
							<a href="deleteCert.cfm?alias=#CertificateArray[i][1]#"
							   onmouseover="window.status='Delete Certificate'; return true;"
							   onmouseout="window.status=''; return true;"
							   onclick="return confirm('Are you sure you want to delete this certificate?');"
							   title="Delete Certificate"><img src="/CFIDE/administrator/images/idelete.gif" vspace="2" hspace="1" width="16" height="16" alt="Delete Certificate" border="0"></a>
							</cfoutput>
						</td>
					</tr>
					</table>
					
				</td>
				<td nowrap class="cellRightAndBottomBlueSide">
					<cfoutput><a href="displayCert.cfm?alias=#CertificateArray[i][1]#"
					   onmouseover2="window.status='View Certificate Details'; return true;"
					   onmouseout2="window.status='';" title="View Certificate Details">
					   #CertificateArray[i][1]#</a></cfoutput>
				</td>
				<td nowrap class="cellRightAndBottomBlueSide">
					<cfoutput>#LSdateformat(CertificateArray[i][2].getNotBefore())#</cfoutput>
				</td>
				<td nowrap class="cellRightAndBottomBlueSide" <cfif CertificateArray[i][2].getNotAfter() LT Now()>bgcolor="#ff0000"</cfif>>
					<cfoutput>#LSdateformat(CertificateArray[i][2].getNotAfter())#</cfoutput>
				</td>
				<td nowrap class="cellRightAndBottomBlueSide">
					<cfoutput>#left(CertificateArray[i][2].getCommonName(),80)#</cfoutput>
				</td>
		
			</tr>
			</cfloop>
			</table>
		</tr>
	</table>
	
	<cfif isDefined("url.restartreq")>
	<script>
		window.alert('For these changes to take effect, you must restart the ColdFusion Service.');
	</script>
	</cfif>
	
<cfinclude template="footer.cfm">
