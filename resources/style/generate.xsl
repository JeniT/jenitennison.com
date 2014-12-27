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
                exclude-result-prefixes="rdf dc dcq my html vcf">

<xsl:include href="cv.xsl" />

<my:files>
  <my:file>index.xml</my:file>
  <my:file>cv.xml</my:file>
  <my:file>compatibility.xml</my:file>
  <my:file>consulting/index.xml</my:file>
  <my:file>xslt/index.xml</my:file>
  <my:file>xslt/conditions.xml</my:file>
  <my:file>xslt/processing.xml</my:file>
  <my:file>xslt/sorting.xml</my:file>
  <my:file>xslt/number.xml</my:file>
  <my:file>xslt/strings.xml</my:file>
  <my:file>xslt/merging-XSLT.xml</my:file>
  <my:file>xslt/unique.xml</my:file>
  <my:file>xslt/associating.xml</my:file>
  <my:file>xslt/grouping/index.xml</my:file>
  <my:file>xslt/grouping/muenchian.xml</my:file>
  <my:file>xslt/hierarchies-out.xml</my:file>
  <my:file>xslt/namespaces.xml</my:file>
  <my:file>xslt/xpath.xml</my:file>
  <my:file>xslt/escaping.xml</my:file>
  <my:file>xslt/variables.xml</my:file>
  <my:file>xslt/keys.xml</my:file>
  <my:file>xslt/document.xml</my:file>
  <my:file>xslt/elements.xml</my:file>
  <my:file>xslt/copying.xml</my:file>
  <my:file>xslt/hierarchies-in.xml</my:file>
  <my:file>xslt/merging-docs.xml</my:file>
  <my:file>xslt/comparing-docs.xml</my:file>
  <my:file>xslt/debugging.xml</my:file>
  <my:file>xslt/performance.xml</my:file>
  <my:file>xslt/simplification.xml</my:file>
  <my:file>xslt/documentation.xml</my:file>
  <my:file>xslt/utilities/index.xml</my:file>
  <my:file>xslt/utilities/markup.xml</my:file>
  <my:file>xslt/utilities/markup-example.xml</my:file>
  <my:file>xslt/utilities/markup-explanation.xml</my:file>
  <my:file>xslt/utilities/selectParameters.xml</my:file>
  <my:file>xslt/utilities/selectParameters-example.xml</my:file>
  <my:file>xslt/utilities/selectParameters-explanation.xml</my:file>
  <my:file>xslt/utilities/paramDoc.xml</my:file>
</my:files>

<xsl:template match="generate">
  <xsl:for-each select="document('')/xsl:stylesheet/my:files/my:file">
    <xsl:variable name="uri" select="concat('F:/', .)" />
    <xsl:for-each select="document(concat('file:///', $uri))">
      <xsl:message>Generating HTML from <xsl:value-of select="$uri" />...</xsl:message>
      <saxon:output file="{substring($uri, 1, string-length($uri) - 4)}.html">
        <xsl:apply-templates />
      </saxon:output>
    </xsl:for-each>
  </xsl:for-each>
</xsl:template>

</xsl:stylesheet>
