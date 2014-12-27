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
	xmlns:area="http://statistics.data.gov.uk/def/administrative-geography/"
	exclude-result-prefixes="xs csv" 
	version="2.0">
	
<xsl:import href="utils.xsl" />
<xsl:import href="os.xsl" />
<xsl:import href="administrative-geography.xsl" />

<xsl:variable name="filename" select="resolve-uri('../source/SNAC2008_EXCEL/CTRY08_GOR08_CTY08_OTH_UK_LU.csv', base-uri(.))" />
	
<xsl:template name="area">
	<xsl:param name="output" as="xs:string" required="yes" />
	<xsl:param name="alias" as="xs:string" required="yes" />
	<xsl:call-template name="rdf">
		<xsl:with-param name="output" select="$output" />
		<xsl:with-param name="alias" select="$alias" />
		<xsl:with-param name="namespaces" select="doc('')/*/namespace::*[name() = ('area', 'admingeo', 'spatial')]" />
	</xsl:call-template>
</xsl:template>

<xsl:function name="area:containedBy" as="element()+">
	<xsl:param name="subjectTypes" as="xs:string+" />
	<xsl:param name="subject" as="xs:string" />
	<xsl:param name="objectTypes" as="xs:string+" />
	<xsl:param name="object" as="xs:string" />
	<xsl:variable name="subjectQNames" as="xs:QName+"
		select="for $type in $subjectTypes return QName($ontology, concat('area:', $type)), xs:QName('spatial:contains')" />
	<xsl:variable name="objectQNames" as="xs:QName+"
		select="for $type in $objectTypes return QName($ontology, concat('area:', $type)), xs:QName('spatial:containedBy')" />
	<xsl:sequence select="rdf:link($objectQNames, $subject, $subjectQNames, $object)" />
</xsl:function>

</xsl:stylesheet>
