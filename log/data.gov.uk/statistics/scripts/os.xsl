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

<xsl:variable name="admingeo" as="xs:string"
	select="'http://data.ordnancesurvey.co.uk/ontology/admingeo'" />
	
<xsl:template match="admingeo:hasOfficialName" priority="10">
	<xsl:next-match />
	<skos:prefLabel>
		<xsl:sequence select="@xml:lang" />
		<xsl:value-of select="." />
	</skos:prefLabel>
</xsl:template>

<xsl:template match="foaf:name" priority="10">
	<xsl:next-match />
	<skos:altLabel>
		<xsl:sequence select="@xml:lang" />
		<xsl:value-of select="." />
	</skos:altLabel>
</xsl:template>

<xsl:template match="admingeo:hasOfficialName | foaf:name">
	<rdfs:label>
		<xsl:sequence select="@xml:lang" />
		<xsl:value-of select="." />
	</rdfs:label>
</xsl:template>

</xsl:stylesheet>
