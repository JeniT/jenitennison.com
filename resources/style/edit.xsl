<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0"
                xmlns:my="http://www.jenitennison.com/"
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:html="http://www.w3.org/1999/xhtml"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                xmlns:dcq="http://purl.org/dc/qualifiers/1.0/"
                xmlns:vcf="http://www.ietf.org/internet-drafts/draft-dawson-vcard-xml-dtd-03.txt"
                xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                xmlns:saxon="http://icl.com/saxon"
                extension-element-prefixes="saxon msxsl"
                exclude-result-prefixes="html">

<xsl:output indent="yes" />

<xsl:strip-space elements="*" />

<xsl:template match="files">
  <xsl:variable name="dir" select="/*/@xml:base" />
  <xsl:for-each select="file">
    <xsl:variable name="uri" select="concat($dir, .)" />
    <xsl:for-each select="document(concat('file:///', $uri))">
      <xsl:message>Editing <xsl:value-of select="$uri" />...</xsl:message>
      <saxon:output file="{substring($uri, 1, string-length($uri) - 4)}.xml">
        <xsl:apply-templates />
      </saxon:output>
    </xsl:for-each>
  </xsl:for-each>
</xsl:template>

<xsl:template match="node()" priority="-2">
   <xsl:copy-of select="." />
</xsl:template>

<xsl:template match="*">
   <xsl:copy>
      <xsl:copy-of select="@*" />
      <xsl:apply-templates />
   </xsl:copy>
</xsl:template>

<xsl:template match="dc:date">
   <dc:date>
      <rdf:Description>
         <xsl:for-each select="@*">
            <xsl:attribute name="{name()}"><xsl:value-of select="." /></xsl:attribute>
         </xsl:for-each>
      </rdf:Description>
   </dc:date>
</xsl:template>

<xsl:template match="my:link[starts-with(@href, 'http://www.mulberrytech.com/xsl/xsl-list/archive/msg')]" />

</xsl:stylesheet>