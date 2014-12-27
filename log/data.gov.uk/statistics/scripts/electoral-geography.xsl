<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:csv="http://www.jenitennison.com/xslt/csv"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:owl="http://www.w3.org/2002/07/owl#"
	xmlns:foaf="http://xmlns.com/foaf/0.1/"
	xmlns:dct="http://purl.org/dc/terms/"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#"
	xmlns:admingeo="http://data.ordnancesurvey.co.uk/ontology/admingeo/"
	xmlns:spatial="http://data.ordnancesurvey.co.uk/ontology/spatialrelations/"
	xmlns:elec="http://statistics.data.gov.uk/def/electoral-geography/"
	exclude-result-prefixes="xs csv" 
	version="2.0">
	
<xsl:variable name="ontology" as="xs:string"
	select="'http://statistics.data.gov.uk/def/electoral-geography/'" />

<xsl:variable name="base" as="xs:string"
	select="'http://statistics.data.gov.uk/'" />
	
<xsl:variable name="parliamentary-constituency" as="xs:string"
	select="concat($base, 'id/parliamentary-constituency')" />

<xsl:variable name="eer" as="xs:string"
	select="concat($base, 'id/eer')" />

</xsl:stylesheet>
