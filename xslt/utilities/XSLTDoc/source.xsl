<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:doc="http://www.jenitennison.com/xslt/doc"
                xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                extension-element-prefixes="msxsl">

<xsl:import href="xslt-doc-utils.xsl" />

<xsl:template match="/">
   <html>
      <head>
         <title>XSLT Source</title>
         <style type="text/css">
            div.element div.content { margin-left: <xsl:value-of select="$prefs/source/indent" />; }
            body { <xsl:apply-templates select="$prefs/source/body" mode="css" /> }
            <xsl:for-each select="$prefs/source/*[not(self::body or self::indent)]">
               <xsl:text />.<xsl:value-of select="name()" /> {<xsl:text />
               <xsl:apply-templates select="." mode="css" /> }<xsl:text />
            </xsl:for-each>
         </style>
         <script type="text/javascript" src="{$stylesheet-path}loadTransformedXML.js" />
         <script type="text/javascript">
            var selectedNode = '';
            function select(node) {
               if (selectedNode != '') {
                  selectedNode.style.background = '';
                  selectedNode.style.color = '';
               }
               selectedNode = node;
               node.style.background = '<xsl:value-of select="$prefs/source/selected/@background" />';
               node.style.color = '<xsl:value-of select="$prefs/source/selected/@color" />';
            }
         </script>
      </head>
      <body onload="javascript:select(node{$show});">
         <xsl:variable name="preceding-element" select="generate-id($node-construct/preceding-sibling::*[1])" />
         <xsl:variable name="comments" select="$node-construct/preceding-sibling::comment() | $node-construct/preceding-sibling::processing-instruction()" />
         <xsl:apply-templates select="$comments[generate-id(preceding-sibling::*[1]) = $preceding-element]" />
         <xsl:apply-templates select="$node-construct" />
      </body>
   </html>
</xsl:template>

<xsl:template match="xsl:*" mode="element-name">
   <xsl:variable name="id" select="count(preceding::* | ancestor::*) + 1" />
	<span onclick="javascript:top.loadNotes('{$current-stylesheet}', '{$id}');select(node{$id});"
         class="xsl-element-name">
      <xsl:value-of select="name()" />
   </span>
</xsl:template>

<xsl:template match="xsl:*/@*" mode="attribute-name">
	<span class="xsl-attribute-name">
      <xsl:value-of select="name()" />
   </span>
</xsl:template>

<xsl:template match="xsl:*/@*" mode="attribute-value">
	<span class="xsl-attribute-value">
      <xsl:value-of select="." />
   </span>
</xsl:template>

<xsl:template match="*[*] | *[not(normalize-space(text()))]/*" priority="-1">
   <xsl:variable name="id" select="count(preceding::* | ancestor::*) + 1" />
   <div class="element" id="node{$id}">
      <xsl:apply-templates select="." mode="start-tag" />
      <xsl:if test="child::node()">
         <xsl:choose>
         	<xsl:when test="*">
               <div class="content">
                  <xsl:apply-templates />
               </div>
            </xsl:when>
         	<xsl:otherwise>
               <span class="content"><xsl:apply-templates /></span>
            </xsl:otherwise>
         </xsl:choose>
         <xsl:apply-templates select="." mode="end-tag"/>
      </xsl:if>
   </div>
</xsl:template>

<xsl:template match="*[not(*) and normalize-space(parent::*/text())]" priority="-1">
   <xsl:variable name="id" select="count(preceding::* | ancestor::*) + 1" />
	<span class="element" id="node{$id}">
      <xsl:apply-templates select="." mode="start-tag" />
      <xsl:if test="child::node()">
         <span class="content"><xsl:apply-templates /></span>
         <xsl:apply-templates select="." mode="end-tag" />
      </xsl:if>
   </span>
</xsl:template>

<xsl:template match="*" mode="start-tag">
   <span class="start-tag">
      <xsl:text>&lt;</xsl:text>
      <xsl:apply-templates select="." mode="element-name" />
      <xsl:apply-templates select="@*[name() != 'doc:id']" />
      <xsl:if test="not(child::node())"> /</xsl:if>
      <xsl:text>&gt;</xsl:text>
   </span>
</xsl:template>

<xsl:template match="@*">
   <xsl:text> </xsl:text>
   <span class="attribute">
      <xsl:apply-templates select="." mode="attribute-name" />
      <xsl:text>="</xsl:text>
      <xsl:apply-templates select="." mode="attribute-value" />
      <xsl:text>"</xsl:text>
   </span>
</xsl:template>

<xsl:template match="*" mode="end-tag">
   <span class="end-tag">
      <xsl:text />&lt;/<xsl:apply-templates select="." mode="element-name" />&gt;<xsl:text />
   </span>
</xsl:template>

<xsl:template match="*" mode="element-name">
   <xsl:variable name="id" select="count(preceding::* | ancestor::*) + 1" />
	<span onclick="javascript:top.loadNotes('{$current-stylesheet}', '{$id}');select(node{$id});"
         class="element-name">
	   <xsl:value-of select="name()" />
   </span>
</xsl:template>

<xsl:template match="@*" mode="attribute-name">
	<span class="attribute-name"><xsl:value-of select="name()" /></span>
</xsl:template>

<xsl:template match="@*" mode="attribute-value">
	<span class="attribute-value"><xsl:value-of select="." /></span>
</xsl:template>

<xsl:template match="comment()">
   <span class="comment">&lt;!--<xsl:value-of select="." />--&gt;</span><br />
</xsl:template>

<xsl:template match="processing-instruction()">
   <xsl:text />&lt;?<xsl:value-of select="name()" />
   <xsl:text> </xsl:text>
   <xsl:value-of select="." /> ?&gt;<xsl:text />
</xsl:template>

<xsl:template match="text()[not(normalize-space())]" />

<xsl:variable name="replacements-rtf">
	<replace><from>&lt;</from><to><span class="entity">&amp;lt;</span></to></replace>
	<replace><from>&gt;</from><to><span class="entity">&amp;gt;</span></to></replace>
	<replace><from>&amp;</from><to><span class="entity">&amp;amp;</span></to></replace>
  	<replace><from>&quot;</from><to><span class="entity">&amp;quot;</span></to></replace>
	<replace><from>&apos;</from><to><span class="entity">&amp;apos;</span></to></replace>
   <replace><from>&#160;</from><to><span class="entity">&amp;#160;</span></to></replace>
	<replace><from>&#x0A;</from><to><br /></to></replace>
</xsl:variable>

<xsl:variable name="replacements" select="msxsl:node-set($replacements-rtf)/replace" />

<xsl:template match="text()">
	<xsl:call-template name="substitute">
		<xsl:with-param name="string" select="." />
	</xsl:call-template>
</xsl:template>

<xsl:template name="substitute">
	<xsl:param name="string" />
   <xsl:variable name="sub" select="$replacements[contains($string, from)][1]" />
   <xsl:choose>
   	<xsl:when test="$sub">
         <xsl:variable name="before" select="substring-before($string, $sub/from)" />
         <xsl:variable name="after" select="substring-after($string, $sub/from)" />
         <xsl:if test="$before">
            <xsl:call-template name="substitute">
            	<xsl:with-param name="string" select="$before" />
            </xsl:call-template>
         </xsl:if>
         <xsl:copy-of select="$sub/to" />
         <xsl:if test="$after">
            <xsl:call-template name="substitute">
               <xsl:with-param name="string" select="$after" />
            </xsl:call-template>
         </xsl:if>
      </xsl:when>
   	<xsl:otherwise><xsl:value-of select="$string" /></xsl:otherwise>
   </xsl:choose>
</xsl:template>

</xsl:stylesheet>