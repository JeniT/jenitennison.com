<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:param name="source-stylesheet" />
<xsl:param name="current-stylesheet" select="$source-stylesheet" />
<xsl:param name="show" select="2" />

<xsl:key name="stylesheet-elements" match="*" use="count(preceding::* | ancestor::*) + 1" />

<xsl:variable name="node" select="key('stylesheet-elements', $show)" />
<xsl:variable name="node-construct" select="$node/ancestor-or-self::*[parent::xsl:stylesheet]" />

<xsl:variable name="prefs" select="document('xslt-doc-prefs.xml')/prefs" />

<xsl:variable name="stylesheet-url">
   <xsl:variable name="pi" select="//processing-instruction('xml-stylesheet')" />
   <xsl:variable name="after" select="substring-after($pi, ' href=')" />
   <xsl:variable name="quote" select="substring($after, 1, 1)" />
   <xsl:value-of select="substring-before(substring-after($after, $quote), $quote)" />
</xsl:variable>

<xsl:variable name="stylesheet-path">
	<xsl:call-template name="substring-before-last">
		<xsl:with-param name="string" select="$stylesheet-url" />
      <xsl:with-param name="find" select="'/'" />
	</xsl:call-template>
</xsl:variable>

<xsl:template name="substring-before-last">
	<xsl:param name="string" />
   <xsl:param name="find" />
   <xsl:if test="contains($string, $find)">
      <xsl:value-of select="substring-before($string, $find)" />
      <xsl:value-of select="$find" />
      <xsl:call-template name="substring-before-last">
         <xsl:with-param name="string" select="substring-after($string, $find)" />
         <xsl:with-param name="find" select="$find" />
      </xsl:call-template>
   </xsl:if>
</xsl:template>

<xsl:key name="named-constructs" match="xsl:stylesheet/xsl:*[@name]" use="@name" />

<xsl:template match="xsl:stylesheet" mode="find-construct">
   <xsl:param name="name" />
   <xsl:param name="type" />
   <xsl:param name="stylesheet" select="$source-stylesheet" />
   <xsl:variable name="construct" select="key('named-constructs', $name)[contains($type, name())]" />
   <xsl:choose>
      <xsl:when test="$construct">
         <in><xsl:value-of select="$stylesheet" /></in>
         <id><xsl:value-of select="count($construct/preceding::* | $construct/ancestor::*) + 1" /></id>
      </xsl:when>
      <xsl:otherwise>
         <xsl:apply-templates select="(xsl:import | xsl:include)[1]" mode="find-construct">
            <xsl:with-param name="name" select="$name" />
            <xsl:with-param name="type" select="$type" />
         </xsl:apply-templates>
      </xsl:otherwise>
   </xsl:choose>
</xsl:template>

<xsl:template match="xsl:import | xsl:include" mode="find-construct">
   <xsl:param name="name" />
   <xsl:param name="type" />
   <xsl:variable name="construct">
      <xsl:apply-templates select="document(@href)/xsl:stylesheet" mode="find-construct">
         <xsl:with-param name="name" select="$name" />
         <xsl:with-param name="type" select="$type" />
         <xsl:with-param name="stylesheet" select="@href" />
      </xsl:apply-templates>
   </xsl:variable>
   <xsl:choose>
      <xsl:when test="string($construct)">
         <xsl:copy-of select="$construct" />
      </xsl:when>
      <xsl:otherwise>
         <xsl:variable name="next" select="(following-sibling::xsl:import | following-sibling::xsl:include)[1]" />
         <xsl:apply-templates select="$next" mode="find-construct">
            <xsl:with-param name="name" select="$name" />
            <xsl:with-param name="type" select="$type" />
         </xsl:apply-templates>
      </xsl:otherwise>
   </xsl:choose>
</xsl:template>

<xsl:template match="xsl:*[@name]" mode="find-overriding">
   <xsl:variable name="name" select="@name" />
   <xsl:variable name="type" select="name()" />
   <xsl:choose>
      <xsl:when test="following-sibling::*[name() = $type][@name = $name][1]">
         <xsl:value-of select="$current-stylesheet" />
      </xsl:when>
      <xsl:when test="$current-stylesheet != $source-stylesheet">
         <xsl:apply-templates select="document($source-stylesheet)/xsl:stylesheet" mode="find-overriding">
            <xsl:with-param name="name" select="$name" />
            <xsl:with-param name="type" select="$type" />
         </xsl:apply-templates>
      </xsl:when>
   </xsl:choose>
</xsl:template>

<xsl:template match="xsl:stylesheet" mode="find-overriding">
   <xsl:param name="name" />
   <xsl:param name="type" />
   <xsl:param name="stylesheet" select="$source-stylesheet" />
   <xsl:variable name="construct" select="key('named-constructs', $name)[name() = $type]" />
   <xsl:choose>
      <xsl:when test="$construct">
         <in><xsl:value-of select="$stylesheet" /></in>
         <id><xsl:value-of select="count($construct/preceding::* | $construct/ancestor::*) + 1" /></id>
      </xsl:when>
      <xsl:otherwise>
         <xsl:variable name="next" select="(xsl:import | xsl:include)[1]" />
         <xsl:if test="$next/@href != $current-stylesheet">
            <xsl:apply-templates select="$next" mode="find-overriding">
               <xsl:with-param name="name" select="$name" />
               <xsl:with-param name="type" select="$type" />
            </xsl:apply-templates>
         </xsl:if>
      </xsl:otherwise>
   </xsl:choose>
</xsl:template>

<xsl:template match="xsl:import | xsl:include" mode="find-overriding">
   <xsl:param name="name" />
   <xsl:param name="type" />
   <xsl:variable name="construct">
      <xsl:apply-templates select="document(@href)/xsl:stylesheet" mode="find-overriding">
         <xsl:with-param name="name" select="$name" />
         <xsl:with-param name="type" select="$type" />
         <xsl:with-param name="stylesheet" select="@href" />
      </xsl:apply-templates>
   </xsl:variable>
   <xsl:choose>
      <xsl:when test="string($construct)">
         <xsl:copy-of select="$construct" />
      </xsl:when>
      <xsl:otherwise>
         <xsl:variable name="next" select="(following-sibling::xsl:import | following-sibling::xsl:include)[1]" />
         <xsl:if test="$next/@href != $current-stylesheet">
            <xsl:apply-templates select="$next" mode="find-overriding">
               <xsl:with-param name="name" select="$name" />
               <xsl:with-param name="type" select="$type" />
            </xsl:apply-templates>
         </xsl:if>
      </xsl:otherwise>
   </xsl:choose>
</xsl:template>

<xsl:template match="*" mode="css">
   <xsl:for-each select="@*">
      <xsl:value-of select="name()" />: <xsl:value-of select="." />; <xsl:text />
   </xsl:for-each>
</xsl:template>

</xsl:stylesheet>