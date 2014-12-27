<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:owl="http://www.w3.org/2002/07/owl#"
	xmlns:foaf="http://xmlns.com/foaf/0.1/"
	xmlns:dct="http://purl.org/dc/terms/"
	xmlns:admingeo="http://data.ordnancesurvey.co.uk/ontology/admingeo/"
	xmlns:area="http://statistics.data.gov.uk/def/administrative-geography"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#"
	xmlns:void="http://rdfs.org/ns/void#"
	exclude-result-prefixes="xs" 
	version="2.0">

<xsl:variable name="source" as="document-node(element(rdf:RDF))+"
	select="doc('../data/admingeo-LAD.rdf'), doc('../data/LAD08.rdf'), doc('../data/admingeo-CTY.rdf'), doc('../data/CTY08.rdf')" />

<xsl:variable name="local-authority" as="xs:string"
	select="'http://statistics.data.gov.uk/id/local-authority'" />

<xsl:variable name="ontology" as="xs:string"
	select="'http://statistics.data.gov.uk/def/administrative-geography'" />

<xsl:template match="/">
	<xsl:result-document href="../data/local-authorities.rdf">
		<rdf:RDF xml:lang="en">
			<xsl:for-each-group select="$source/rdf:RDF/*[skos:notation]" group-by="@rdf:about">
				<xsl:sort select="current-grouping-key()" />
				<xsl:variable name="code" as="xs:string" select="skos:notation" />
				<xsl:variable name="description" as="element(area:LocalAuthority)">
					<area:LocalAuthority rdf:about="{$local-authority}/{$code}">
						<xsl:apply-templates select="(current-group()/skos:prefLabel)[1]" />
						<xsl:if test="not(current-group()/skos:prefLabel)">
							<xsl:choose>
								<xsl:when test="string-length(skos:notation) = 2">
									<skos:prefLabel>
										<xsl:value-of select="(current-group()/skos:altLabel)[1]" />
										<xsl:text> County Council</xsl:text>
									</skos:prefLabel>
								</xsl:when>
								<xsl:otherwise>
									<skos:altLabel>
										<xsl:value-of select="(current-group()/skos:altLabel)[1]" />
										<xsl:text> Council</xsl:text>
									</skos:altLabel>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:if>
						<skos:notation><xsl:value-of select="$code" /></skos:notation>
						<area:coverage rdf:resource="{@rdf:about}" />
					</area:LocalAuthority>
				</xsl:variable>
				<xsl:for-each select="$description/(skos:prefLabel, skos:altLabel)">
					<rdf:Description rdf:about="{$local-authority}?name={encode-for-uri(.)}">
						<owl:sameAs rdf:resource="{$local-authority}/{$code}" />
					</rdf:Description>
				</xsl:for-each>
				<xsl:sequence select="$description" />
			</xsl:for-each-group>
		</rdf:RDF>
	</xsl:result-document>
</xsl:template>

<xsl:template match="skos:prefLabel[starts-with(., 'The London Borough of ')]">
	<skos:prefLabel>
		<xsl:value-of select="substring-after(., 'The London Borough of ')" />
		<xsl:text> London Borough Council</xsl:text>
	</skos:prefLabel>
</xsl:template>

<xsl:template match="skos:prefLabel[starts-with(., 'The Borough of ')]">
	<skos:prefLabel>
		<xsl:value-of select="substring-after(., 'The Borough of ')" />
		<xsl:text> Borough Council</xsl:text>
	</skos:prefLabel>
</xsl:template>
	
<xsl:template match="skos:prefLabel[starts-with(., 'The Royal Borough of ')]">
	<skos:prefLabel>
		<xsl:value-of select="substring-after(., 'The Royal Borough of ')" />
		<xsl:text> Royal Borough Council</xsl:text>
	</skos:prefLabel>
</xsl:template>
	
<xsl:template match="skos:prefLabel[starts-with(., 'The County Borough of ')]">
	<skos:prefLabel>
		<xsl:value-of select="substring-after(., 'The County Borough of ')" />
		<xsl:text> County Borough Council</xsl:text>
	</skos:prefLabel>
</xsl:template>

<xsl:template match="skos:prefLabel[starts-with(., 'The City of ')]">
	<skos:prefLabel>
		<xsl:value-of select="substring-after(., 'The City of ')" />
		<xsl:text> City Council</xsl:text>
	</skos:prefLabel>
</xsl:template>
	
<xsl:template match="skos:prefLabel[starts-with(., 'The District of ')]">
	<skos:prefLabel>
		<xsl:value-of select="substring-after(., 'The District of ')" />
		<xsl:text> District Council</xsl:text>
	</skos:prefLabel>
</xsl:template>

<xsl:template match="skos:prefLabel[starts-with(., 'The County of ')]">
	<skos:prefLabel>
		<xsl:value-of select="substring-after(., 'The County of ')" />
		<xsl:text> County Council</xsl:text>
	</skos:prefLabel>
</xsl:template>

<xsl:template match="skos:prefLabel[. = 'The City and County of the City of London']">
	<skos:prefLabel>City of London</skos:prefLabel>
</xsl:template>

<xsl:template match="skos:prefLabel[. = 'The City and County of Swansea']">
	<skos:prefLabel>Swansea City and Borough Council</skos:prefLabel>
</xsl:template>

<xsl:template match="skos:prefLabel[. = 'The City and County of Cardiff']">
	<skos:prefLabel>Cardiff Council</skos:prefLabel>
</xsl:template>
	
<xsl:template match="skos:prefLabel[. = 'The Isle of Wight']">
	<skos:prefLabel>Isle of Wight Council</skos:prefLabel>
</xsl:template>

<xsl:template match="skos:prefLabel[. = 'The Isles of Scilly']">
	<skos:prefLabel>Council of the Isles of Scilly</skos:prefLabel>
</xsl:template>
	
<xsl:template match="skos:prefLabel[. = 'Highland']">
	<skos:prefLabel>The Highland Council</skos:prefLabel>
</xsl:template>

<xsl:template match="skos:prefLabel[. = 'Na H-Eileanan an Iar']">
	<skos:prefLabel>Comhairle nan Eilean Siar</skos:prefLabel>
</xsl:template>

<xsl:template match="skos:prefLabel">
	<skos:prefLabel>
		<xsl:sequence select="@xml:lang" />
		<xsl:value-of select="." />
		<xsl:text> Council</xsl:text>
	</skos:prefLabel>
</xsl:template>

</xsl:stylesheet>
