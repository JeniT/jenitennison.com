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
	exclude-result-prefixes="xs csv" 
	version="2.0">

<xsl:import href="csv.xsl" />

<xsl:template name="rdf">
	<xsl:param name="output" as="xs:string" required="yes" />
	<xsl:param name="alias" as="xs:string?" select="()" />
	<xsl:param name="namespaces" as="node()*" select="()" />
	<xsl:result-document href="../data/{$output}">
		<rdf:RDF xml:lang="en">
			<xsl:sequence select="$namespaces" />
			<xsl:variable name="descriptions" as="element(rdf:Description)*">
				<xsl:for-each select="$lines[position() > 1]">
					<xsl:sequence select="rdf:each-line(csv:values(.))" />
				</xsl:for-each>
			</xsl:variable>
			<xsl:choose>
				<xsl:when test="exists($alias)">
					<xsl:call-template name="alias">
						<xsl:with-param name="descriptions" select="$descriptions" />
						<xsl:with-param name="query" select="$alias" />
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:for-each-group select="$descriptions" group-by="@rdf:about">
						<xsl:sequence select="." />
					</xsl:for-each-group>
				</xsl:otherwise>
			</xsl:choose>
		</rdf:RDF>
	</xsl:result-document>
</xsl:template>

<xsl:template name="alias">
	<xsl:param name="descriptions" as="element(rdf:Description)+" required="yes" />
	<xsl:param name="query" as="xs:string" required="yes" />
	<xsl:for-each-group select="$descriptions" group-by="@rdf:about">
		<xsl:sort select="current-grouping-key()" />
		<xsl:variable name="description" as="element(rdf:Description)" select="." />
		<xsl:if test="not(contains($description/@rdf:about, '?'))">
			<xsl:for-each select="distinct-values($description/(skos:prefLabel | skos:altLabel))">
				<rdf:Description rdf:about="{$query}?name={encode-for-uri(.)}">
					<owl:sameAs rdf:resource="{$description/@rdf:about}" />
				</rdf:Description>
			</xsl:for-each>
		</xsl:if>
		<xsl:sequence select="$description" />
	</xsl:for-each-group>
</xsl:template>

<xsl:function name="rdf:link" as="element()+">
	<xsl:param name="rels" as="xs:QName+" />
	<xsl:param name="subject" as="xs:string" />
	<xsl:param name="revs" as="xs:QName*" />
	<xsl:param name="object" as="xs:string" />
	<xsl:for-each select="$rels">
		<xsl:element name="{.}" namespace="{namespace-uri-from-QName(.)}">
			<xsl:choose>
				<xsl:when test="position() = 1 and exists($revs)">
					<rdf:Description rdf:about="{$object}">
						<xsl:for-each select="$revs">
							<xsl:element name="{.}" namespace="{namespace-uri-from-QName(.)}">
								<xsl:attribute name="rdf:resource" select="$subject" />
							</xsl:element>
						</xsl:for-each>
					</rdf:Description>
				</xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="rdf:resource" select="$object" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
	</xsl:for-each>
</xsl:function>

<xsl:function name="rdf:each-line" as="element(rdf:Description)?">
	<xsl:param name="values" as="xs:string+" />
	<xsl:sequence select="rdf:each-line($values, $fields)" />
</xsl:function>
	
<xsl:function name="rdf:each-line" as="element(rdf:Description)?">
	<xsl:param name="values" as="xs:string+" />
	<xsl:param name="fields" as="xs:string+" />
	<xsl:sequence select="()" />
</xsl:function>

</xsl:stylesheet>
