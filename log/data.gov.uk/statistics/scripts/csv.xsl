<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
      xmlns:xs="http://www.w3.org/2001/XMLSchema"
      xmlns:csv="http://www.jenitennison.com/xslt/csv"
      xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
      xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
      exclude-result-prefixes="xs csv"
      version="2.0">

<xsl:param name="filename" as="xs:string?" select="()" />

<xsl:variable name="csv" as="xs:string" select="unparsed-text($filename)" />
<xsl:variable name="lines" as="xs:string+" select="csv:lines($csv)" />
<xsl:variable name="fields" as="xs:string+" select="csv:fields($lines)" />

<xsl:template match="/" name="main">
	<rdf:RDF>
		<xsl:for-each select="$lines[position() > 1]">
			<xsl:call-template name="csv:line">
				<xsl:with-param name="values" select="csv:values(.)" />
			</xsl:call-template>
		</xsl:for-each>
	</rdf:RDF>
</xsl:template>

<xsl:template name="csv:line">
	<xsl:param name="values" as="xs:string+" required="yes" />
</xsl:template>

<xsl:function name="csv:lines" as="xs:string*">
	<xsl:param name="file" as="xs:string" />
	<xsl:sequence select="tokenize($file, '\n')[normalize-space(.) != '']" />
</xsl:function>

<xsl:function name="csv:values" as="xs:string+">
	<xsl:param name="line" as="xs:string" />
	<xsl:analyze-string select="$line" regex="(&quot;([^&quot;]+)&quot;)|([^&quot;,]+)">
		<xsl:matching-substring>
			<xsl:choose>
				<xsl:when test="regex-group(1) != ''">
					<xsl:sequence select="regex-group(2)" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="regex-group(3)" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:matching-substring>
		<xsl:non-matching-substring>
			<xsl:if test=". != ','">
				<xsl:sequence select="tokenize(., ',')[position() > 2]" />
			</xsl:if>
		</xsl:non-matching-substring>
	</xsl:analyze-string>
</xsl:function>

<xsl:function name="csv:field" as="xs:string?">
	<xsl:param name="values" as="xs:string+" />
	<xsl:param name="field" as="xs:string" />
	<xsl:sequence select="csv:field($values, $field, $fields)" />
</xsl:function>

<xsl:function name="csv:field" as="xs:string?">
	<xsl:param name="values" as="xs:string+" />
	<xsl:param name="field" as="xs:string" />
	<xsl:param name="fields" as="xs:string+" />
	<xsl:sequence select="$values[index-of($fields, $field)]" />
</xsl:function>

<xsl:function name="csv:fields" as="xs:string+">
	<xsl:param name="lines" as="xs:string+" />
	<xsl:sequence select="csv:values($lines[1])" />
</xsl:function>

</xsl:stylesheet>
