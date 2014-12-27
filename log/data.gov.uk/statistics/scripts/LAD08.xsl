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
		<xsl:with-param name="output" select="'LAD08.rdf'" />
		<xsl:with-param name="alias" select="$county" />
	</xsl:call-template>
</xsl:template>

<xsl:function name="rdf:each-line" as="element(rdf:Description)?">
	<xsl:param name="values" as="xs:string+" />
	<xsl:param name="fields" as="xs:string+" />
	<xsl:variable name="label" as="xs:string" select="csv:field($values, 'LAD08NM', $fields)" />
	<xsl:variable name="code" as="xs:string" select="csv:field($values, 'LAD08CD', $fields)" />
	<xsl:variable name="countyCode" as="xs:string" select="csv:field($values, 'CTY08CD', $fields)" />
	<xsl:variable name="countyLabel" as="xs:string" select="csv:field($values, 'CTY08NM', $fields)" />
	<xsl:variable name="gorCode" as="xs:string" select="csv:field($values, 'GOR08CD', $fields)" />
	<xsl:variable name="countryCode" as="xs:string" select="csv:field($values, 'CTRY08CD', $fields)" />
	<xsl:if test="$code != ''">
		<xsl:variable name="id" as="xs:string" select="concat($local-authority-district, '/', $code)" />
		<xsl:variable name="countyId" as="xs:string">
			<xsl:value-of>
				<xsl:value-of select="$county" />
				<xsl:choose>
					<xsl:when test="$countyCode = '00'">
						<xsl:text>?name=</xsl:text>
						<xsl:value-of select="encode-for-uri($countyLabel)" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>/</xsl:text>
						<xsl:value-of select="$countyCode" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:value-of>
		</xsl:variable>
		<rdf:Description rdf:about="{$id}">
			<rdf:type rdf:resource="{$ontology}LocalAuthorityDistrict" />
			<rdfs:label><xsl:value-of select="$label" /></rdfs:label>
			<skos:altLabel><xsl:value-of select="$label" /></skos:altLabel>
			<skos:notation><xsl:value-of select="$code" /></skos:notation>
			<xsl:sequence select="area:containedBy('district', $id, 'county', $countyId)" />
			<xsl:sequence select="area:containedBy('district', $id, 'region', concat($government-office-region, '/', $gorCode))" />
			<xsl:sequence select="area:containedBy('district', $id, 'country', concat($country, '/', $countryCode))" />
		</rdf:Description>
	</xsl:if>
</xsl:function>
	
</xsl:stylesheet>
