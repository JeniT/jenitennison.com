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
	
<xsl:variable name="ontology" as="xs:string"
	select="'http://statistics.data.gov.uk/def/administrative-geography/'" />

<xsl:variable name="base" as="xs:string"
	select="'http://statistics.data.gov.uk/'" />
	
<xsl:variable name="local-authority-district" as="xs:string"
	select="concat($base, 'id/local-authority-district')" />

<xsl:variable name="county" as="xs:string"
	select="concat($base, 'id/county')" />

<xsl:variable name="government-office-region" as="xs:string"
	select="concat($base, 'id/government-office-region')" />

<xsl:variable name="country" as="xs:string"
	select="concat($base, 'id/country')" />

</xsl:stylesheet>
