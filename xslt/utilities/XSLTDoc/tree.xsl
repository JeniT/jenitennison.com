<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:import href="xslt-doc-utils.xsl" />

<xsl:key name="sources" match="source" use="@href" />

<xsl:template match="/">
   <html>
      <head>
         <title>Import Tree</title>
         <style type="text/css">
            div div { margin-left: <xsl:value-of select="$prefs/tree/indent" />; }
            body { <xsl:apply-templates select="$prefs/tree/body" mode="css" /> }
            <xsl:for-each select="$prefs/tree/*[not(self::body or self::indent)]">
               <xsl:text />.<xsl:value-of select="name()" /> {<xsl:text />
               <xsl:apply-templates select="." mode="css" /> }<xsl:text />
            </xsl:for-each>
         </style>
      </head>
      <body>
         <div>
            <xsl:call-template name="insert-tree" />
         </div>
      </body>
   </html>
</xsl:template>

<xsl:template name="insert-tree">
   <xsl:param name="stylesheet" select="$source-stylesheet" />   
   <span onclick="javascript:top.loadTree('{$stylesheet}', '2')">
      <xsl:text>-&#160;</xsl:text>
      <span>
         <xsl:attribute name="class">
            <xsl:value-of select="@type" />
            <xsl:if test="$stylesheet = $current-stylesheet"> selected</xsl:if>
         </xsl:attribute>
         <xsl:value-of select="$stylesheet" />
      </span>
   </span>
   <xsl:if test="position() != last()"><br /></xsl:if>
   <xsl:variable name="stylesheet-doc" select="document($stylesheet)/xsl:stylesheet" />
   <xsl:variable name="imports" select="$stylesheet-doc/xsl:import | $stylesheet-doc/xsl:include" />
   <xsl:if test="$imports">
      <div>
         <xsl:for-each select="$imports">
            <xsl:call-template name="insert-tree">
               <xsl:with-param name="stylesheet" select="@href" />
            </xsl:call-template>
         </xsl:for-each>
      </div>
   </xsl:if>
</xsl:template>

</xsl:stylesheet>