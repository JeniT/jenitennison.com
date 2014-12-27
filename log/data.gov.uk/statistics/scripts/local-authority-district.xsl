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
	
<xsl:import href="csv.xsl" />

<xsl:variable name="filename" select="resolve-uri('../source/SNAC2008_EXCEL/CTRY08_GOR08_CTY08_OTH_UK_LU.csv', base-uri(.))" />

<xsl:variable name="ontology" as="xs:string"
	select="'http://statistics.data.gov.uk/def/administrative-geography'" />

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

<xsl:variable name="admingeo" as="xs:string"
	select="'http://data.ordnancesurvey.co.uk/ontology/admingeo'" />

<xsl:template match="/">
	<xsl:result-document href="../data/LAD08.rdf">
		<rdf:RDF xml:lang="en">
			<xsl:variable name="local-authority-districts" as="element(rdf:Description)+">
				<xsl:for-each select="$lines[position() > 1]">
					<xsl:variable name="values" as="xs:string+" select="csv:values(.)" />
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
							<rdf:type rdf:resource="{$ontology}/LocalAuthorityDistrict" />
							<rdfs:label><xsl:value-of select="$label" /></rdfs:label>
							<skos:altLabel><xsl:value-of select="$label" /></skos:altLabel>
							<skos:notation><xsl:value-of select="$code" /></skos:notation>
							<area:county>
								<rdf:Description rdf:about="{$countyId}">
									<area:district rdf:resource="{$id}" />
									<spatial:contains rdf:resource="{$id}" />
								</rdf:Description>
							</area:county>
							<area:region>
								<rdf:Description rdf:about="{$government-office-region}/{$gorCode}">
									<area:district rdf:resource="{$id}" />
									<spatial:contains rdf:resource="{$id}" />
								</rdf:Description>
							</area:region>
							<area:country>
								<rdf:Description rdf:about="{$country}/{$countryCode}">
									<area:district rdf:resource="{$id}" />
									<spatial:contains rdf:resource="{$id}" />
								</rdf:Description>
							</area:country>
							<spatial:containedBy rdf:resource="{$countyId}" />
							<spatial:containedBy rdf:resource="{$government-office-region}/{$gorCode}" />
							<spatial:containedBy rdf:resource="{$country}/{$countryCode}" />
						</rdf:Description>
					</xsl:if>
				</xsl:for-each>
			</xsl:variable>
			<xsl:for-each-group select="$local-authority-districts" group-by="@rdf:about">
				<xsl:variable name="description" as="element(rdf:Description)" select="." />
				<xsl:if test="$description/skos:notation">
					<xsl:for-each select="distinct-values($description/(skos:prefLabel | skos:altLabel))">
						<rdf:Description rdf:about="{$local-authority-district}?name={encode-for-uri(.)}">
							<owl:sameAs rdf:resource="{$description/@rdf:about}" />
						</rdf:Description>
					</xsl:for-each>
				</xsl:if>
				<xsl:sequence select="$description" />
			</xsl:for-each-group>
		</rdf:RDF>
	</xsl:result-document>
</xsl:template>

</xsl:stylesheet>
