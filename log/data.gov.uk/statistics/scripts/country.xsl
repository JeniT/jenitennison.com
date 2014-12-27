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
	xmlns:skos="http://www.w3.org/2004/02/skos/core#"
	xmlns:area="http://statistics.data.gov.uk/def/administrative-geography/"
	exclude-result-prefixes="xs csv" 
	version="2.0">
	
<xsl:import href="csv.xsl" />

<xsl:variable name="filename" select="resolve-uri('../source/SNAC2008_EXCEL/CTRY08_GOR08_CTY08_OTH_UK_LU.csv', base-uri(.))" />

<xsl:variable name="ontology" as="xs:string"
	select="'http://statistics.data.gov.uk/def/administrative-geography'" />

<xsl:variable name="base" as="xs:string"
	select="'http://statistics.data.gov.uk/'" />

<xsl:variable name="country" as="xs:string"
	select="concat($base, 'id/country')" />

<xsl:variable name="admingeo" as="xs:string"
	select="'http://data.ordnancesurvey.co.uk/ontology/admingeo'" />

<xsl:template match="/">
	<xsl:result-document href="../data/CTRY08.rdf">
		<rdf:RDF xml:lang="en">
			<xsl:variable name="countries" as="element(rdf:Description)+">
				<xsl:for-each select="$lines[position() > 1]">
					<xsl:variable name="values" as="xs:string+" select="csv:values(.)" />
					<xsl:variable name="code" as="xs:string" select="csv:field($values, 'CTRY08CD', $fields)" />
					<xsl:variable name="label" as="xs:string" select="csv:field($values, 'CTRY08NM', $fields)" />
					<rdf:Description rdf:about="{$country}/{$code}">
						<rdf:type rdf:resource="{$ontology}/Country" />
						<rdfs:label><xsl:value-of select="$label" /></rdfs:label>
						<skos:prefLabel><xsl:value-of select="$label" /></skos:prefLabel>
						<skos:notation><xsl:value-of select="$code" /></skos:notation>
					</rdf:Description>
				</xsl:for-each>
			</xsl:variable>
			<xsl:for-each-group select="$countries" group-by="@rdf:about">
				<xsl:variable name="description" as="element(rdf:Description)" select="." />
				<xsl:for-each select="distinct-values($description/(skos:prefLabel | skos:altLabel))">
					<rdf:Description rdf:about="{$country}?name={encode-for-uri(.)}">
						<owl:sameAs rdf:resource="{$description/@rdf:about}" />
					</rdf:Description>
				</xsl:for-each>
				<xsl:sequence select="$description" />
			</xsl:for-each-group>
		</rdf:RDF>
	</xsl:result-document>
</xsl:template>

</xsl:stylesheet>
