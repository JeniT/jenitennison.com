<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:csv="http://www.jenitennison.com/xslt/csv"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:owl="http://www.w3.org/2002/07/owl#"
	xmlns:foaf="http://xmlns.com/foaf/0.1/"
	xmlns:dct="http://purl.org/dc/terms/"
	xmlns:admingeo="http://data.ordnancesurvey.co.uk/ontology/admingeo/"
	xmlns:spatial="http://data.ordnancesurvey.co.uk/ontology/spatialrelations/"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#"
	xmlns:area="http://statistics.data.gov.uk/def/administrative-geography/"
	exclude-result-prefixes="xs csv" 
	version="2.0">

<xsl:import href="admingeo.xsl" />

<xsl:template match="/">
	<xsl:call-template name="area">
		<xsl:with-param name="output" select="'admingeo-CTY.rdf'" />
		<xsl:with-param name="alias" select="$county" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="rdf:Description[string-length(admingeo:hasCensusCode) = 2]">
	<xsl:variable name="code" as="xs:string" select="admingeo:hasCensusCode" />
	<rdf:Description rdf:about="{$county}/{$code}">
		<rdf:type rdf:resource="{$ontology}County" />
		<xsl:copy-of copy-namespaces="no" select="rdf:type" />
		<xsl:apply-templates select="admingeo:hasOfficialName" />
		<xsl:apply-templates select="foaf:name[. != ../admingeo:hasOfficialName]" />
		<skos:notation><xsl:value-of select="$code" /></skos:notation>
		<owl:sameAs rdf:resource="{@rdf:about}" />
	</rdf:Description>
</xsl:template>

<xsl:template match="rdf:Description" />

</xsl:stylesheet>
