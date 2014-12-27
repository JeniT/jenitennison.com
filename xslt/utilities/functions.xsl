<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:doc="http://www.jenitennison.com/xslt/doc"
                extension-element-prefixes="doc">

<xsl:import href="selectParameters.xsl" />

<doc:param name="function">
  <doc:label>Function: </doc:label>
  <doc:choice><doc:value>concat</doc:value></doc:choice>
  <doc:choice><doc:value>starts-with</doc:value></doc:choice>
  <doc:choice><doc:value>contains</doc:value></doc:choice>
  <doc:choice><doc:value>substring-before</doc:value></doc:choice>
  <doc:choice><doc:value>substring-after</doc:value></doc:choice>
</doc:param>
<xsl:param name="function" select="'starts-with'" />

<xsl:template match="/">
  <html>
    <head>
      <title>Function Descriptions</title>
    </head>
    <body>
      <h1>Function Descriptions</h1>
      <p>Select the function that you wish to learn about:</p>
      <xsl:call-template name="insert-selectParameters-form" />
      <xsl:apply-templates select="functions/function[contains(defn, concat($function, '('))]" />
    </body>
  </html>
</xsl:template>

<xsl:template match="function">
  <h2>Function: <xsl:value-of select="defn" /></h2>
  <p><xsl:value-of select="desc" /></p>
</xsl:template>

</xsl:stylesheet>
