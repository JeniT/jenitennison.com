<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#">

<xsl:strip-space elements="rdf:RDF rdf:Description" />
<xsl:output indent="yes" />
	
<xsl:variable name="rdf" select="'http://www.w3.org/1999/02/22-rdf-syntax-ns#'" />
<xsl:variable name="rdfs" select="'http://www.w3.org/2000/01/rdf-schema#'" />
<xsl:variable name="skos" select="'http://www.w3.org/2004/02/skos/core#'" />
	
<xsl:variable name="defaultNs">
	<xsl:call-template name="namespace">
		<xsl:with-param name="string" select="/rdf:RDF/rdf:Description[1]/rdf:type[1]/@rdf:resource" />
	</xsl:call-template>
</xsl:variable>

<xsl:template match="rdf:RDF[count(*) = 1]">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="rdf:Description[rdf:type]">
	<xsl:variable name="uri" select="rdf:type[1]/@rdf:resource" />
	<xsl:variable name="namespace">
		<xsl:call-template name="namespace">
			<xsl:with-param name="string" select="$uri" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="local" select="substring-after($uri, $namespace)" />
	<xsl:variable name="prefix">
		<xsl:call-template name="prefix">
			<xsl:with-param name="namespace" select="$namespace" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="qname">
		<xsl:call-template name="qname">
			<xsl:with-param name="prefix" select="$prefix" />
			<xsl:with-param name="local" select="$local" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:element name="{$qname}" namespace="{$namespace}">
		<xsl:copy-of select="namespace::rdf | namespace::rdfs" />
		<xsl:apply-templates select="@*" />
		<xsl:apply-templates select="*">
			<xsl:sort select="namespace-uri() = $rdf" order="descending" />
			<xsl:sort select="namespace-uri() = $rdfs" order="descending" />
			<xsl:sort select="not(@rdf:resource)" order="descending" />
			<xsl:sort select="name()" />
			<xsl:sort select="@rdf:resource" />
		</xsl:apply-templates>
	</xsl:element>
</xsl:template>

<xsl:template match="rdf:Description/rdf:type[1]" priority="3" />

<xsl:template match="rdf:Description/*">
	<xsl:variable name="prefix">
		<xsl:call-template name="prefix">
			<xsl:with-param name="namespace" select="namespace-uri()" />
			<xsl:with-param name="default" select="substring-before(name(), ':')" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="qname">
		<xsl:call-template name="qname">
			<xsl:with-param name="prefix" select="$prefix" />
			<xsl:with-param name="local" select="local-name()" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:element name="{$qname}" namespace="{namespace-uri()}">
		<xsl:apply-templates select="@*|node()" />
	</xsl:element>
</xsl:template>

<xsl:template match="@*|node()">
	<xsl:copy>
		<xsl:apply-templates select="@*|node()" />
	</xsl:copy>
</xsl:template>

<xsl:template name="qname">
	<xsl:param name="prefix" />
	<xsl:param name="local" />
	<xsl:choose>
		<xsl:when test="$prefix = ''">
			<xsl:value-of select="$local" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="concat($prefix, ':', $local)" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="prefix">
	<xsl:param name="namespace" />
	<xsl:param name="default" />
	<xsl:choose>
		<xsl:when test="$namespace = $defaultNs" />
		<xsl:otherwise>
			<xsl:value-of select="$default" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="namespace">
	<xsl:param name="string" />
	<xsl:param name="namespace" />
	<xsl:choose>
		<xsl:when test="contains($string, '#')">
			<xsl:value-of select="concat(substring-before($string, '#'), '#')" />
		</xsl:when>
		<xsl:when test="contains($string, '/')">
			<xsl:call-template name="namespace">
				<xsl:with-param name="string" select="substring-after($string, '/')" />
				<xsl:with-param name="namespace"
					select="concat($namespace, substring-before($string, '/'), '/')" />
			</xsl:call-template>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="$namespace" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

</xsl:stylesheet>
