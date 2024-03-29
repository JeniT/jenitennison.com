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
	
<xsl:import href="CTRY08_GOR08_CTY08_OTH_UK_LU.xsl" />

<xsl:template match="/">
	<xsl:call-template name="area">
		<xsl:with-param name="output" select="'GOR08.rdf'" />
		<xsl:with-param name="alias" select="$government-office-region" />
	</xsl:call-template>
</xsl:template>

<xsl:function name="rdf:each-line" as="element(rdf:Description)?">
	<xsl:param name="values" as="xs:string+" />
	<xsl:param name="fields" as="xs:string+" />
	<xsl:variable name="code" as="xs:string" select="csv:field($values, 'GOR08CD', $fields)" />
	<xsl:variable name="label" as="xs:string" select="csv:field($values, 'GOR08NM', $fields)" />
	<xsl:variable name="countryCode" as="xs:string" select="csv:field($values, 'CTRY08CD', $fields)" />
	<xsl:if test="$code != ''">
		<rdf:Description rdf:about="{$government-office-region}/{$code}">
			<rdf:type rdf:resource="{$admingeo}/GovernmentOfficeRegion" />
			<rdfs:label><xsl:value-of select="$label" /></rdfs:label>
			<skos:prefLabel><xsl:value-of select="$label" /></skos:prefLabel>
			<skos:notation><xsl:value-of select="$code" /></skos:notation>
			<xsl:sequence select="area:containedBy('region', concat($government-office-region, '/', $code), 'country', concat($country, '/', $countryCode))"></xsl:sequence>
		</rdf:Description>
	</xsl:if>
</xsl:function>

</xsl:stylesheet>
