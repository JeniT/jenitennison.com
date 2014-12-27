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
	
<xsl:import href="utils.xsl" />

<xsl:variable name="filename" select="resolve-uri('../source/SNAC2008_EXCEL/PCON08_EER08_UK_LU.csv', base-uri(.))" />

<xsl:variable name="ontology" as="xs:string"
	select="'http://statistics.data.gov.uk/def/electoral-geography/'" />

<xsl:variable name="base" as="xs:string"
	select="'http://statistics.data.gov.uk/'" />
	
<xsl:variable name="parliamentary-constituency" as="xs:string"
	select="concat($base, 'id/parliamentary-constituency')" />

<xsl:variable name="eer" as="xs:string"
	select="concat($base, 'id/eer')" />

<xsl:variable name="admingeo" as="xs:string"
	select="'http://data.ordnancesurvey.co.uk/ontology/admingeo'" />
	
<xsl:template name="area">
	<xsl:param name="output" as="xs:string" required="yes" />
	<xsl:param name="alias" as="xs:string" required="yes" />
	<xsl:call-template name="rdf">
		<xsl:with-param name="output" select="$output" />
		<xsl:with-param name="alias" select="$alias" />
		<xsl:with-param name="namespaces" select="doc('')/*/namespace::*[name() = ('elec', 'admingeo', 'spatial')]" />
	</xsl:call-template>
</xsl:template>

<xsl:function name="elec:containedBy" as="element()+">
	<xsl:param name="subjectTypes" as="xs:string+" />
	<xsl:param name="subject" as="xs:string" />
	<xsl:param name="objectTypes" as="xs:string+" />
	<xsl:param name="object" as="xs:string" />
	<xsl:variable name="subjectQNames" as="xs:QName+"
		select="for $type in $subjectTypes return QName($ontology, concat('elec:', $type)), xs:QName('spatial:contains')" />
	<xsl:variable name="objectQNames" as="xs:QName+"
		select="for $type in $objectTypes return QName($ontology, concat('elec:', $type)), xs:QName('spatial:containedBy')" />
	<xsl:sequence select="rdf:link($objectQNames, $subject, $subjectQNames, $object)" />
</xsl:function>

</xsl:stylesheet>
