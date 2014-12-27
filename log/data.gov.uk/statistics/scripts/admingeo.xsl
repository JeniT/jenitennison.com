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
	
<xsl:import href="utils.xsl" />
<xsl:import href="os.xsl" />
<xsl:import href="administrative-geography.xsl" />
	
<xsl:variable name="source" as="document-node()"
	select="doc('../source/regions/admingeo.rdf')" />

<xsl:template name="area">
	<xsl:param name="output" as="xs:string" required="yes" />
	<xsl:param name="alias" as="xs:string" required="yes" />
	<xsl:result-document href="../data/{$output}">
		<rdf:RDF xml:lang="en">
			<xsl:variable name="descriptions" as="element(rdf:Description)+">
				<xsl:apply-templates select="$source/rdf:RDF/*" />
			</xsl:variable>
			<xsl:call-template name="alias">
				<xsl:with-param name="descriptions" select="$descriptions" />
				<xsl:with-param name="query" select="$alias" />
			</xsl:call-template>
		</rdf:RDF>
	</xsl:result-document>
</xsl:template>

</xsl:stylesheet>
