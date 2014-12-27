<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0"
                xmlns:my="http://www.jenitennison.com/"
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:html="http://www.w3.org/1999/xhtml"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                xmlns:dcq="http://purl.org/dc/qualifiers/1.0/"
                xmlns:vcf="http://www.ietf.org/internet-drafts/draft-dawson-vcard-xml-dtd-03.txt"
								xmlns:resume="urn:schemas-biztalk-org:HR-XML-org/Resume"
                exclude-result-prefixes="rdf dc dcq my html vcf resume">

<xsl:include href="page.xsl" />

<xsl:template match="resume:Resume">
  <xsl:variable name="metadata" select="/*/rdf:RDF" />
  <xsl:variable name="uri" select="$metadata/rdf:Description[1]/@about" />
	<html>
		<head>
			<title>
				<xsl:call-template name="get-metadata">
					<xsl:with-param name="what" select="'title'" />
				  <xsl:with-param name="about" select="$uri" />
				</xsl:call-template>
			</title>
			<xsl:call-template name="get-metadata">
				<xsl:with-param name="what" select="'link'" />
				<xsl:with-param name="about" select="$uri" />
			</xsl:call-template>
			<link rel="alternate" type="text/xml" href="{$uri}" />
			<xsl:call-template name="get-metadata">
			  <xsl:with-param name="what" select="'rights'" />
			  <xsl:with-param name="about" select="$uri" />
			</xsl:call-template>
		</head>
		<body>
			<xsl:if test="$dynamic = 'false'">
				<p id="xml-link">
					Try the <a href="{$uri}">XML version</a> of this page.
					If you have problems with it, consult the
					<a href="/compatibility.html">compatibility page</a>.
				</p>
			</xsl:if>
    	<h1>
    		<xsl:for-each select="resume:ResumeBody/resume:PersonalData/resume:Name">
    			<xsl:if test="resume:Prefix">
    				<xsl:value-of select="resume:Prefix" />
    				<xsl:text> </xsl:text>
    			</xsl:if>
    			<xsl:choose>
    				<xsl:when test="resume:Nickname">
    					<xsl:value-of select="resume:Nickname" />
    				</xsl:when>
    				<xsl:otherwise>
    					<xsl:value-of select="resume:First" />
    				</xsl:otherwise>
    			</xsl:choose>
    			<xsl:text> </xsl:text>
    			<xsl:value-of select="resume:Last" />
    		</xsl:for-each>
        <xsl:call-template name="insert-navigation" />
    	</h1>
    	<table>
    		<tr>
    			<td><xsl:apply-templates select="resume:ResumeProlog" /></td>
    			<td><xsl:apply-templates select="resume:ResumeBody/resume:PersonalData/resume:Address" /></td>
    			<td><xsl:apply-templates select="resume:ResumeBody/resume:PersonalData/resume:Voice |
    			                                 resume:ResumeBody/resume:PersonalData/resume:Email" /></td>
    		</tr>
    	</table>
    	<xsl:apply-templates select="resume:ResumeBody/resume:ResumeSection" />
			<xsl:apply-templates select="." mode="colophon" />
		</body>
	</html>
</xsl:template>

<xsl:template match="resume:RevisionDate">
	<p>
		Last Revised: <xsl:apply-templates />
	</p>
</xsl:template>

<xsl:template match="resume:Date">
	<xsl:if test="resume:Day">
		<xsl:value-of select="resume:Day" />
		<xsl:text> </xsl:text>
	</xsl:if>
	<xsl:if test="resume:Month">
		<xsl:value-of select="resume:Month" />
		<xsl:text> </xsl:text>
	</xsl:if>
	<xsl:value-of select="resume:Year" />
</xsl:template>

<xsl:template match="resume:AvailabilityDate">
	<p>
		Availability: <xsl:apply-templates />
	</p>
</xsl:template>

<xsl:template match="resume:Address">
	<address>
		<xsl:for-each select="resume:AddressLine | resume:City | resume:Province | resume:PostalCode | resume:Country">
			<xsl:value-of select="." /><br class="break"/>
		</xsl:for-each>
	</address>
</xsl:template>

<xsl:template match="resume:Voice">
	<p>
		<xsl:text>+</xsl:text><xsl:value-of select="resume:IntlCode" />
		<xsl:text> </xsl:text><xsl:value-of select="resume:AreaCode" />
		<xsl:text> </xsl:text><xsl:value-of select="resume:TelNumber" />
	</p>
</xsl:template>

<xsl:template match="resume:Email">
	<p>
		<xsl:apply-templates select="." mode="link" />
	</p>
</xsl:template>

<xsl:template match="resume:ResumeBody/resume:ResumeSection">
	<div class="{@SecType}">
		<xsl:apply-templates select="resume:SectionTitle" />
		<xsl:apply-templates select="resume:SecBody" />
	</div>
</xsl:template>

<xsl:template match="resume:ResumeBody/resume:ResumeSection/resume:SectionTitle[not(*)]">
	<h2><xsl:value-of select="." /></h2>
</xsl:template>

<xsl:template match="resume:SecBody/resume:ResumeSection/resume:SectionTitle[not(*)]">
	<h3><xsl:value-of select="." /></h3>
</xsl:template>

<xsl:template match="resume:SecBody/resume:ResumeSection/resume:SectionTitle[*]">
	<h3>
		<small>
			<xsl:apply-templates select="resume:StartDate" />-<xsl:apply-templates select="resume:EndDate" />
		</small>
		<br class="break" />
		<xsl:for-each select="resume:EducationQualif | resume:JobTitle">
			<xsl:value-of select="." />
			<br class="break" />
		</xsl:for-each>
		<xsl:if test="resume:EmployerName">
			<xsl:apply-templates select="resume:EmployerName" />
		</xsl:if>
	</h3>
</xsl:template>

<xsl:template match="resume:CurrentPosition">present</xsl:template>

<xsl:template match="resume:SecBody[resume:ResumeSection]">
	<table>
		<xsl:apply-templates select="resume:ResumeSection" />
	</table>
</xsl:template>

<xsl:template match="resume:SecBody/resume:ResumeSection">
	<tr>
		<td>
			<xsl:apply-templates select="resume:SectionTitle" />
		</td>
		<td>
			<xsl:apply-templates select="resume:SecBody" />
		</td>
	</tr>
</xsl:template>

<xsl:template match="resume:dl">
	<table>
		<xsl:for-each select="resume:dt">
			<tr>
				<th><p><xsl:value-of select="." />:</p></th>
				<td><p><xsl:value-of select="following-sibling::resume:dd[1]" /></p></td>
			</tr>
		</xsl:for-each>
	</table>
</xsl:template>

<xsl:template match="resume:*">
	<xsl:element name="{local-name()}">
		<xsl:apply-templates />
	</xsl:element>
</xsl:template>

</xsl:stylesheet>

