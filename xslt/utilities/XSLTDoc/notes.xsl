<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="xslt-doc.xsl" ?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:doc="http://www.jenitennison.com/xslt/doc"
                xmlns:html="http://www.w3.org/1999/xhtml"
                xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                extension-element-prefixes="msxsl">

<xsl:import href="xslt-doc-utils.xsl" />
<xsl:import href="xpath-doc.xsl" />

<xsl:variable name="row">
   <xsl:text>row</xsl:text>
   <xsl:choose>
      <xsl:when test="generate-id($node) = generate-id($node-construct)"><xsl:value-of select="$show" /></xsl:when>
      <xsl:otherwise><xsl:value-of select="count($node-construct/preceding::* | $node-construct/ancestor::*) + 1" /></xsl:otherwise>
   </xsl:choose>
</xsl:variable>

<xsl:template match="/">
   <html>
      <head>
         <title>XSLT Notes</title>
         <style type="text/css">
            body { <xsl:apply-templates select="$prefs/notes/body" mode="css" /> }
            <xsl:for-each select="$prefs/notes/*[not(self::body)]">
               <xsl:text />.<xsl:value-of select="name()" /> {<xsl:text />
               <xsl:apply-templates select="." mode="css" /> }<xsl:text />
            </xsl:for-each>
         </style>
      </head>
      <body>
         <xsl:apply-templates select="$node" mode="notes" />
      </body>
   </html>
</xsl:template>

<xsl:variable name="element-doc" select="document('xslt-doc.xml')/doc" />

<xsl:template match="xsl:*" priority="1" mode="notes">
   <xsl:variable name="name" select="local-name()" />
   <xsl:variable name="doc" select="$element-doc/element[@name = $name]" />
   <p>
      <a href="http://www.w3.org/TR/xslt#element-{$name}">XSLT Recommendation definition</a>
   </p>
   <xsl:apply-templates select="$doc/doc" />
   <xsl:if test="@name and parent::xsl:stylesheet">
      <xsl:variable name="overridden-rtf">
         <xsl:apply-templates select="." mode="find-overriding" />
      </xsl:variable>
      <xsl:if test="string($overridden-rtf)">
         <xsl:variable name="overridden" select="msxsl:node-set($overridden-rtf)" />
         <p>
            This <xsl:value-of select="local-name()" /> is overridden in 
            <span class="link">
               <xsl:attribute name="onclick">
                  <xsl:text>javascript:</xsl:text>
                  <xsl:choose>
                     <xsl:when test="$overridden/in = $current-stylesheet">top.loadSummary('<xsl:value-of select="$current-stylesheet" />', '<xsl:value-of select="$overridden/id" />')</xsl:when>
                     <xsl:otherwise>top.loadTree('<xsl:value-of select="$overridden/in" />', '<xsl:value-of select="$overridden/id" />')</xsl:otherwise>
                  </xsl:choose>
               </xsl:attribute>
               <xsl:value-of select="$overridden/in" />
            </span>
         </p>
      </xsl:if>
   </xsl:if>
   <xsl:if test="$doc/more">
      <ul>
         <xsl:for-each select="$doc/more">
         	<li><a href="{@href}"><xsl:value-of select="." /></a></li>
         </xsl:for-each>
      </ul>
   </xsl:if>
</xsl:template>

<xsl:template match="*" mode="notes">
   <xsl:variable name="prefix" select="substring-before(name(), ':')" />
   <xsl:choose>
      <xsl:when test="$prefix and
                      contains(concat(' ', normalize-space(ancestor::xsl:stylesheet/@extension-element-prefixes), ' '),
                               $prefix)">
         
         <p>
            <a href="http://www.w3.org/TR/xslt#extension-element">XSLT Recommendation description</a>
         </p>
         <p>This is an extension element from the namespace '<xsl:value-of select="namespace::*[name() = $prefix]" />'.</p>
      </xsl:when>
      <xsl:otherwise>
         <p>
            <a href="http://www.w3.org/TR/xslt#literal-result-element">XSLT Recommendation description</a>
         </p>
         <p>This is a literal result element that will be copied into the result tree.</p>
         <xsl:if test="@xsl:use-attribute-sets">
            <p>The following attribute sets will be included:</p>
            <xsl:apply-templates select="@xsl:use-attribute-sets" mode="explain" />
         </xsl:if>
         <xsl:if test="@*">
            <p>The following attributes will be included:</p>
            <ul>
               <xsl:for-each select="@*">
                  <li>
                     <span class="attribute-name"><xsl:value-of select="name()" /></span>:<xsl:text />
                     <xsl:call-template name="explain">
                        <xsl:with-param name="xpath" select="." />
                        <xsl:with-param name="type" select="'avt'" />
                     </xsl:call-template>
                  </li>
               </xsl:for-each>
            </ul>
         </xsl:if>
      </xsl:otherwise>
   </xsl:choose>
</xsl:template>

<xsl:template match="el | at">
	<span class="{name()}">
      <xsl:apply-templates />
   </span>
</xsl:template>

<xsl:template match="if[starts-with(@test, '!')]">
   <xsl:variable name="test" select="substring-after(@test, '!')" />
   <xsl:choose>
      <xsl:when test="$test = '#content'">
         <xsl:if test="not($node/child::node())">
            <xsl:apply-templates />
         </xsl:if>
      </xsl:when>
      <xsl:when test="starts-with($test, '@')">
         <xsl:if test="not($node/@*[name() = substring-after($test, '@')])">
            <xsl:apply-templates />
         </xsl:if>
      </xsl:when>
      <xsl:when test="not($node/*[name() = $test])">
         <xsl:apply-templates />
      </xsl:when>
   </xsl:choose>
</xsl:template>

<xsl:template match="if">
	<xsl:variable name="test" select="@test" />
   <xsl:choose>
   	<xsl:when test="contains($test, '=')">
         <xsl:variable name="what" select="substring-before($test, '=')" />
         <xsl:variable name="val" select="substring-after($test, '=')" />
         <xsl:variable name="not" select="substring($what, string-length($what), 1) = '!'" />
         <xsl:choose>
         	<xsl:when test="starts-with($what, '@')">
               <xsl:choose>
                  <xsl:when test="$not and $node/@*[name() = substring($what, 2, string-length($what) - 2)] != $val">
                     <xsl:apply-templates />
                  </xsl:when>
                  <xsl:when test="not($not) and $node/@*[name() = substring($what, 2)] = $val">
                     <xsl:apply-templates />
                  </xsl:when>
               </xsl:choose>
            </xsl:when>
         	<xsl:when test="$not and $node/*[name() = substring($what, 1, string-length($what) - 1)] != $val">
               <xsl:apply-templates />
            </xsl:when>
            <xsl:when test="not($not) and $node/*[name() = $what] = $val">
               <xsl:apply-templates />
            </xsl:when>
         </xsl:choose>
      </xsl:when>
      <xsl:when test="$test = '#content' and $node/child::node()">
         <xsl:apply-templates />
      </xsl:when>
      <xsl:when test="starts-with($test, '@') and $node/@*[name() = substring-after($test, '@')]">
         <xsl:apply-templates />
      </xsl:when>
      <xsl:when test="$node/*[name() = $test]">
         <xsl:apply-templates />
      </xsl:when>
   </xsl:choose>
</xsl:template>

<xsl:template match="ref">
   <xsl:variable name="sel" select="@select" />
	<xsl:choose>
      <xsl:when test="$sel = '#content'"><xsl:apply-templates select="$node/node()" mode="explain" /></xsl:when>
		<xsl:when test="starts-with($sel, '@')"><xsl:apply-templates select="$node/@*[name() = substring-after($sel, '@')]" mode="explain" /></xsl:when>
		<xsl:otherwise><xsl:apply-templates select="$node/*[name() = $sel]" mode="explain" /></xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- pattern attribute values -->
<xsl:template match="xsl:key/@match | xsl:number/@count | xsl:number/@from |
                     xsl:template/@match" mode="explain">
   <xsl:call-template name="explain">
   	<xsl:with-param name="xpath" select="." />
      <xsl:with-param name="type" select="'pattern'" />
   </xsl:call-template>
</xsl:template>

<!-- expression attribute values -->
<xsl:template match="xsl:apply-templates/@select | xsl:copy-of/@select | 
                     xsl:for-each/@select | xsl:number/@value | xsl:sort/@select |
                     xsl:key/@use" mode="explain">
	<xsl:call-template name="explain">
		<xsl:with-param name="xpath" select="." />
      <xsl:with-param name="type" select="'node-set'" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="xsl:param/@select | xsl:variable/@select | xsl:with-param/@select" mode="explain">
	<xsl:call-template name="explain">
		<xsl:with-param name="xpath" select="." />
	</xsl:call-template>
</xsl:template>

<xsl:template match="xsl:value-of/@select" mode="explain">
	<xsl:call-template name="explain">
		<xsl:with-param name="xpath" select="." />
      <xsl:with-param name="type" select="'string'" />
	</xsl:call-template>
</xsl:template>

<!-- test attribute values -->
<xsl:template match="xsl:if/@test | xsl:when/@test" mode="explain">
	<xsl:call-template name="explain">
		<xsl:with-param name="xpath" select="." />
      <xsl:with-param name="type" select="'boolean'" />
	</xsl:call-template>
</xsl:template>

<!-- attribute value templates -->
<xsl:template match="xsl:element/@name | xsl:element/@namespace |
                     xsl:attribute/@name | xsl:attribute/@namespace |
                     xsl:number/@format | xsl:number/@lang | xsl:number/@letter-value |
                     xsl:number/@grouping-size | xsl:number/@grouping-separator |
                     xsl:processing-instruction/@name | xsl:sort/@order |
                     xsl:sort/@data-type | xsl:sort/@lang | xsl:sort/@case-order" mode="explain">
   <xsl:call-template name="explain">
		<xsl:with-param name="xpath" select="." />
      <xsl:with-param name="type" select="'avt'" />
	</xsl:call-template>
</xsl:template>

<!-- NMTOKEN attribute values -->
<xsl:template match="xsl:attribute-set/@use-attribute-sets | xsl:copy/@use-attribute-sets | 
                     xsl:output/@cdata-section-elements | xsl:element/@use-attribute-sets |
                     xsl:preserve-space/@elements | xsl:strip-space/@elements |
                     xsl:stylesheet/@exclude-result-prefixes | 
                     xsl:stylesheet/@extension-element-prefixes |
                     xsl:transform/@exclude-result-prefixes | xsl:transform/@extension-element-prefixes |
                     @xsl:use-attribute-sets" mode="explain">
	<ul>
      <xsl:call-template name="get-nmtokens">
      	<xsl:with-param name="nmtokens" select="normalize-space(.)" />
      </xsl:call-template>
   </ul>
</xsl:template>

<xsl:key name="attribute-sets" match="xsl:attribute-set" use="@name" />

<!-- NMTOKEN attribute values with links -->
<xsl:template match="xsl:attribute-set/@use-attribute-sets | xsl:copy/@use-attribute-sets |
                     xsl:element/@use-attribute-sets | @xsl:use-attribute-sets" mode="explain">
   <xsl:variable name="attribute-sets-rtf">
      <xsl:call-template name="get-nmtokens">
         <xsl:with-param name="nmtokens" select="normalize-space(.)" />
      </xsl:call-template>
   </xsl:variable>
   <ul>
      <xsl:for-each select="msxsl:node-set($attribute-sets-rtf)/li">
         <xsl:variable name="attribute-set" select="key('attribute-sets', .)" />
         <xsl:variable name="id" select="count($attribute-set/preceding::* | $attribute-set/ancestor::*) + 1" />
         <xsl:copy>
            <xsl:copy-of select="@*" />
            <span class="link" onclick="javascript:top.loadSummary('{$current-stylesheet}', '{$id}')">
               <xsl:copy-of select="node()" />
            </span>
         </xsl:copy>
      </xsl:for-each>
   </ul>
</xsl:template>

<!-- literal attribute values -->
<xsl:template match="xsl:apply-templates/@mode | xsl:attribute-set/@name | 
                     xsl:decimal-format/@* | 
                     xsl:import/@href | xsl:include/@href |
                     xsl:key/@name | xsl:message/@terminate |
                     xsl:namespace-alias/@stylesheet-prefix | xsl:namespace-alias/@result-prefix |
                     xsl:number/@level | xsl:output/@method | xsl:output/@version |
                     xsl:output/@encoding | xsl:output/@omit-xml-declaration |
                     xsl:output/@standalone | xsl:output/@doctype-system |
                     xsl:output/@doctype-public | xsl:output/@indent | xsl:output/@media-type |
                     xsl:template/@mode | xsl:template/@name |
                     xsl:text/@disable-output-escaping | xsl:value-of/@disable-output-escaping |
                     xsl:variable/@name | xsl:param/@name | xsl:with-param/@name" mode="explain">
	<xsl:text />'<xsl:value-of select="." />'<xsl:text />
</xsl:template>

<xsl:template match="xsl:import/@href | xsl:include/@href" mode="explain">
   <span class="link" onclick="javascript:top.loadTree('{.}', '2')">
   	<xsl:text />'<xsl:value-of select="." />'<xsl:text />
   </span>
</xsl:template>

<!-- literal attribute values with links -->
<xsl:template match="xsl:call-template/@name" mode="explain">
   <xsl:variable name="template-rtf">
      <xsl:apply-templates select="document($source-stylesheet)/xsl:stylesheet" mode="find-construct">
         <xsl:with-param name="name" select="." />
         <xsl:with-param name="type" select="'xsl:template'" />
      </xsl:apply-templates>
   </xsl:variable>
   <xsl:variable name="template" select="msxsl:node-set($template-rtf)" />
   <xsl:text>'</xsl:text>
   <span class="link">
      <xsl:attribute name="onclick">
         <xsl:text>javascript:</xsl:text>
         <xsl:choose>
            <xsl:when test="$template/in = $current-stylesheet">top.loadSummary('<xsl:value-of select="$current-stylesheet" />', '<xsl:value-of select="$template/id" />')</xsl:when>
            <xsl:otherwise>top.loadTree('<xsl:value-of select="$template/in" />', '<xsl:value-of select="$template/id" />')</xsl:otherwise>
         </xsl:choose>
      </xsl:attribute>
      <xsl:value-of select="." />
   </span>
   <xsl:text>'</xsl:text>
</xsl:template>

<xsl:template match="xsl:text/text()" mode="explain">
	<xsl:text />"<xsl:value-of select="." />"<xsl:text />
</xsl:template>

<!-- numerical attribute values -->
<xsl:template match="xsl:template/@priority" mode="explain">
   <xsl:value-of select="." />
</xsl:template>

<xsl:template match="html:*">
	<xsl:element name="{local-name()}">
      <xsl:copy-of select="@*" />
      <xsl:apply-templates />
	</xsl:element>
</xsl:template>

<xsl:template name="explain-variable">
   <xsl:param name="variable-name" />
   <xsl:variable name="ancestors-not-parent" select="$node/ancestor::*[position() > 1]" />
   <xsl:variable name="local-var"
                 select="($node/preceding-sibling::xsl:variable | $node/preceding-sibling::xsl:param | 
                          $ancestors-not-parent/xsl:variable | $ancestors-not-parent/xsl:param)[@name = $variable-name][last()]" />
   <xsl:choose>
      <xsl:when test="$local-var">
         <xsl:variable name="id" select="count($local-var/preceding::* | $local-var/ancestor::*) + 1" />
         <xsl:text> '</xsl:text>
         <span class="link" onclick="javascript:top.loadSummary('{$current-stylesheet}', '{$id}')">
            <xsl:value-of select="$variable-name" />
         </span>
         <xsl:text>'</xsl:text>
      </xsl:when>
      <xsl:otherwise>
         <xsl:variable name="var-rtf">
            <xsl:apply-templates select="document($source-stylesheet)/xsl:stylesheet" mode="find-construct">
               <xsl:with-param name="name" select="$variable-name" />
               <xsl:with-param name="type" select="'xsl:param xsl:variable'" />
            </xsl:apply-templates>
         </xsl:variable>
         <xsl:variable name="var" select="msxsl:node-set($var-rtf)" />
         <xsl:text> '</xsl:text>
         <span class="link">
            <xsl:attribute name="onclick">
               <xsl:text>javascript:</xsl:text>
               <xsl:choose>
                  <xsl:when test="$var/in = $current-stylesheet">top.loadSummary('<xsl:value-of select="$current-stylesheet" />', '<xsl:value-of select="$var/id" />')</xsl:when>
                  <xsl:otherwise>top.loadTree('<xsl:value-of select="$var/in" />', '<xsl:value-of select="$var/id" />')</xsl:otherwise>
               </xsl:choose>
            </xsl:attribute>
            <xsl:value-of select="$variable-name" />
         </span>
         <xsl:text>'</xsl:text>
      </xsl:otherwise>
   </xsl:choose>
</xsl:template>

<xsl:template name="get-nmtokens">
	<xsl:param name="nmtokens" />
   <xsl:choose>
   	<xsl:when test="contains($nmtokens, ' ')">
         <li><xsl:value-of select="substring-before($nmtokens, ' ')" /></li>
         <xsl:call-template name="get-nmtokens">
         	<xsl:with-param name="nmtokens" select="substring-after($nmtokens, ' ')" />
         </xsl:call-template>
      </xsl:when>
   	<xsl:otherwise>
         <li><xsl:value-of select="$nmtokens" /></li>
      </xsl:otherwise>
   </xsl:choose>
</xsl:template>

</xsl:stylesheet>