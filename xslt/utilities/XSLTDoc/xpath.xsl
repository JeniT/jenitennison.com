<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:saxon="http://icl.com/saxon"
                xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                extension-element-prefixes="saxon msxsl">

<xsl:output indent="yes" />

<xsl:template match="xpath">
	<xsl:call-template name="expression">
		<xsl:with-param name="expr" select="." />
	</xsl:call-template>
</xsl:template>

<xsl:template name="avt">
	<xsl:param name="avt" />
   <xsl:message>avt: <xsl:value-of select="$avt" /></xsl:message>
   <xsl:choose>
   	<xsl:when test="contains($avt, '{') or contains($avt, '}}')">
         <avt>
            <xsl:call-template name="avt-sections">
               <xsl:with-param name="avt" select="$avt" />
            </xsl:call-template>
         </avt>
      </xsl:when>
   	<xsl:otherwise><string><xsl:value-of select="$avt" /></string></xsl:otherwise>
   </xsl:choose>
</xsl:template>

<xsl:template name="avt-sections">
	<xsl:param name="avt" />
   <xsl:message>avt-sections: <xsl:value-of select="$avt" /></xsl:message>
   <xsl:choose>
   	<xsl:when test="contains($avt, '{')">
         <xsl:variable name="before" select="substring-before($avt, '{')" />
         <xsl:variable name="after" select="substring-after($avt, '{')" />
         <xsl:choose>
         	<xsl:when test="starts-with($after, '{')">
               <xsl:if test="$before">
                  <xsl:call-template name="avt-sections">
                     <xsl:with-param name="avt" select="$before" />
                  </xsl:call-template>
               </xsl:if>
               <string>{</string>
               <xsl:variable name="next" select="substring($after, 2)" />
               <xsl:if test="$next">
                  <xsl:call-template name="avt-sections">
                     <xsl:with-param name="avt" select="$next" />
                  </xsl:call-template>
               </xsl:if>
            </xsl:when>
         	<xsl:otherwise>
               <xsl:if test="$before">
                  <xsl:call-template name="avt-sections">
                     <xsl:with-param name="avt" select="$before" />
                  </xsl:call-template>
               </xsl:if>
               <expr>
                  <xsl:call-template name="expression">
                     <xsl:with-param name="expr" select="substring-before($after, '}')" />
                  </xsl:call-template>
               </expr>
               <xsl:variable name="next" select="substring-after($after, '}')" />
               <xsl:if test="$next">
                  <xsl:call-template name="avt-sections">
                     <xsl:with-param name="avt" select="$next" />
                  </xsl:call-template>
               </xsl:if>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:when>
      <xsl:when test="contains($avt, '}}')">
         <xsl:variable name="before" select="substring-before($avt, '}}')" />
         <xsl:variable name="after" select="substring-after($avt, '}}')" />
         <xsl:if test="$before">
            <string><xsl:value-of select="$before" /></string>
         </xsl:if>
         <string>}</string>
         <xsl:if test="$after">
            <xsl:call-template name="avt-sections">
               <xsl:with-param name="avt" select="$after" />
            </xsl:call-template>
         </xsl:if>
      </xsl:when>
   	<xsl:otherwise><string><xsl:value-of select="$avt" /></string></xsl:otherwise>
   </xsl:choose>
</xsl:template>

<xsl:template name="pattern">
	<xsl:param name="xpath" />
   <xsl:message>pattern: <xsl:value-of select="$xpath" /></xsl:message>
   <pattern>
      <xsl:variable name="union-rtf">
         <xsl:call-template name="split">
            <xsl:with-param name="string" select="$xpath" />
            <xsl:with-param name="at" select="'|'" />
         </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="union" select="msxsl:node-set($union-rtf)/item" />
      <xsl:choose>
         <xsl:when test="count($union) > 1">
            <union>
               <xsl:for-each select="$union">
                  <xsl:call-template name="location-path-pattern">
                     <xsl:with-param name="xpath" select="." />
                  </xsl:call-template>
               </xsl:for-each>
            </union>
         </xsl:when>
         <xsl:otherwise>
            <xsl:call-template name="location-path-pattern">
               <xsl:with-param name="xpath" select="$xpath" />
            </xsl:call-template>
         </xsl:otherwise>
      </xsl:choose>
   </pattern>
</xsl:template>

<xsl:template name="location-path-pattern">
	<xsl:param name="xpath" />
   <xsl:message>location-path-pattern: <xsl:value-of select="$xpath" /></xsl:message>
   <xsl:choose>
   	<xsl:when test="starts-with($xpath, '//')">
         <path>
            <root />
            <step axis="descendant-or-self">
               <node />
            </step>
            <xsl:call-template name="relative-path-pattern">
               <xsl:with-param name="xpath" select="substring-after($xpath, '//')" />
            </xsl:call-template>
         </path>
      </xsl:when>
      <xsl:when test="starts-with($xpath, '/')">
         <path>
            <root />
            <xsl:if test="substring-after($xpath, '/')">
               <xsl:call-template name="relative-path-pattern">
                  <xsl:with-param name="xpath" select="substring-after($xpath, '/')" />
               </xsl:call-template>
            </xsl:if>
         </path>
      </xsl:when>
      <xsl:when test="starts-with($xpath, 'id(')">
         <xsl:variable name="id" select="normalize-space(substring-before(substring-after($xpath, 'id('), ')'))" />
         <path>
            <function name="id">
               <arg><string><xsl:value-of select="substring($id, 2, string-length($id) - 2)" /></string></arg>
            </function>
            <xsl:variable name="after" select="substring-after($xpath, ')')" />
            <xsl:choose>
               <xsl:when test="starts-with($after, '//')">
                  <step axis="descendant-or-self">
                     <node />
                  </step>
                  <xsl:call-template name="relative-path-pattern">
                     <xsl:with-param name="xpath" select="substring-after($after, '//')" />
                  </xsl:call-template>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:call-template name="relative-path-pattern">
                     <xsl:with-param name="xpath" select="substring-after($after, '/')" />
                  </xsl:call-template>
               </xsl:otherwise>
            </xsl:choose>
         </path>
      </xsl:when>
      <xsl:when test="starts-with($xpath, 'key(')">
         <xsl:variable name="args" select="substring-before(substring-after($xpath, 'key('), ')')" />
         <xsl:variable name="keyspace" select="normalize-space(substring-before($args, ','))" />
         <xsl:variable name="keyvalue" select="normalize-space(substring-after($args, ','))" />
         <xsl:variable name="after" select="substring-after($xpath, ')')" />
         <path>
            <function name="key">
               <arg><string><xsl:value-of select="substring($keyspace, 2, string-length($keyspace) - 2)" /></string></arg>
               <arg><string><xsl:value-of select="substring($keyvalue, 2, string-length($keyvalue) - 2)" /></string></arg>
            </function>
            <xsl:choose>
               <xsl:when test="starts-with($after, '//')">
                  <step axis="descendant-or-self">
                     <node />
                  </step>
                  <xsl:call-template name="relative-path-pattern">
                     <xsl:with-param name="xpath" select="substring-after($after, '//')" />
                  </xsl:call-template>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:call-template name="relative-path-pattern">
                     <xsl:with-param name="xpath" select="substring-after($after, '/')" />
                  </xsl:call-template>
               </xsl:otherwise>
            </xsl:choose>
         </path>
      </xsl:when>
   	<xsl:otherwise>
         <path>
            <xsl:call-template name="relative-path-pattern">
               <xsl:with-param name="xpath" select="$xpath" />
            </xsl:call-template>
         </path>
      </xsl:otherwise>
   </xsl:choose>
</xsl:template>

<xsl:template name="relative-path-pattern">
   <xsl:param name="xpath" />
   <xsl:message>relative-path-pattern: <xsl:value-of select="$xpath" /></xsl:message>
   <xsl:variable name="steps-rtf">
      <xsl:call-template name="split">
         <xsl:with-param name="string" select="$xpath" />
         <xsl:with-param name="at" select="'/'" />
      </xsl:call-template>
   </xsl:variable>
   <xsl:variable name="steps" select="msxsl:node-set($steps-rtf)/item" />
   <xsl:for-each select="$steps">
      <xsl:call-template name="step-pattern">
         <xsl:with-param name="xpath" select="." />
      </xsl:call-template>
   </xsl:for-each>
</xsl:template>

<xsl:template name="step-pattern">
	<xsl:param name="xpath" />
   <xsl:message>step-pattern: <xsl:value-of select="$xpath" /></xsl:message>
   <xsl:variable name="predicates">
      <xsl:if test="contains($xpath, '[')">
         <xsl:value-of select="concat('[', substring-after($xpath, '['))" />
      </xsl:if>
   </xsl:variable>
   <xsl:variable name="axis">
      <xsl:choose>
         <xsl:when test="contains($xpath, '::')"><xsl:value-of select="substring-before($xpath, '::')" /></xsl:when>
         <xsl:when test="starts-with($xpath, '@')">attribute</xsl:when>
         <xsl:when test="not(string($xpath))">descendant-or-self</xsl:when>
         <xsl:otherwise>child</xsl:otherwise>
      </xsl:choose>
   </xsl:variable>
   <xsl:variable name="no-pred">
      <xsl:choose>
         <xsl:when test="string($predicates)"><xsl:value-of select="substring-before($xpath, '[')" /></xsl:when>
         <xsl:otherwise><xsl:value-of select="$xpath" /></xsl:otherwise>
      </xsl:choose>
   </xsl:variable>
   <xsl:variable name="node-test">
      <xsl:choose>
         <xsl:when test="contains($no-pred, '::')"><xsl:value-of select="substring-after($no-pred, '::')" /></xsl:when>
         <xsl:when test="starts-with($no-pred, '@')"><xsl:value-of select="substring-after($no-pred, '@')" /></xsl:when>
         <xsl:when test="not(string($xpath))">node()</xsl:when>
         <xsl:otherwise><xsl:value-of select="$no-pred" /></xsl:otherwise>
      </xsl:choose>
   </xsl:variable>
   <xsl:variable name="namespace">
      <xsl:choose>
         <xsl:when test="$node-test = '*'">any</xsl:when>
         <xsl:when test="contains($node-test, ':')"><xsl:value-of select="substring-before($node-test, ':')" /></xsl:when>
         <xsl:when test="$axis = 'attribute'">element</xsl:when>
         <xsl:otherwise>default</xsl:otherwise>
      </xsl:choose>
   </xsl:variable>
   <xsl:variable name="node-type">
      <xsl:choose>
         <xsl:when test="contains($node-test, ':')"><xsl:value-of select="substring-after($node-test, ':')" /></xsl:when>
         <xsl:otherwise><xsl:value-of select="$node-test" /></xsl:otherwise>
      </xsl:choose>
   </xsl:variable>
   <step axis="{$axis}">
      <xsl:choose>
      	<xsl:when test="$node-type = 'comment()'"><comment /></xsl:when>
         <xsl:when test="$node-type = 'text()'"><text /></xsl:when>
         <xsl:when test="$node-type = 'node()'"><node /></xsl:when>
         <xsl:when test="$node-type = 'processing-instruction()'"><pi /></xsl:when>
         <xsl:when test="starts-with($node-type, 'processing-instruction(')">
            <xsl:variable name="pi-arg" select="normalize-space(substring-before(substring-after($node-type, 'processing-instruction('), ')'))" />
            <xsl:variable name="pi-name" select="substring($pi-arg, 2, string-length($pi-arg) - 2)" />
            <pi name="{$pi-name}" />
         </xsl:when>
         <xsl:when test="$node-type = '*'">
            <xsl:choose>
               <xsl:when test="$axis = 'attribute'"><attribute namespace="{$namespace}" /></xsl:when>
            	<xsl:otherwise><element namespace="{$namespace}" /></xsl:otherwise>
            </xsl:choose>
         </xsl:when>
         <xsl:when test="$axis = 'attribute'"><attribute name="{$node-type}" namespace="{$namespace}" /></xsl:when>
      	<xsl:otherwise><element name="{$node-type}" namespace="{$namespace}" /></xsl:otherwise>
      </xsl:choose>
      <xsl:if test="string($predicates)">
         <xsl:call-template name="predicates">
           <xsl:with-param name="predicates" select="$predicates" />
         </xsl:call-template>
      </xsl:if>
   </step>
</xsl:template>

<xsl:template name="predicate">
	<xsl:param name="predicate" />
   <xsl:message>predicate: <xsl:value-of select="$predicate" /></xsl:message>
   <predicate>
      <xsl:call-template name="expression">
         <xsl:with-param name="expr" select="$predicate" />
      </xsl:call-template>
   </predicate>
</xsl:template>

<xsl:template name="expression">
	<xsl:param name="expr" />
      <xsl:message>expression: <xsl:value-of select="$expr" /> ()</xsl:message>
   <xsl:call-template name="or-expression">
   	<xsl:with-param name="expr" select="$expr" />
         </xsl:call-template>
</xsl:template>

<xsl:template name="or-expression">
	<xsl:param name="expr" />
      <xsl:message>or-expression: <xsl:value-of select="$expr" /> ()</xsl:message>
   <xsl:variable name="ors-rtf">
      <xsl:call-template name="split">
         <xsl:with-param name="string" select="$expr" />
         <xsl:with-param name="at" select="'or'" />
         <xsl:with-param name="test-before" select="true()" />
         <xsl:with-param name="test-after" select="true()" />
      </xsl:call-template>
   </xsl:variable>
   <xsl:variable name="ors" select="msxsl:node-set($ors-rtf)" />
   <xsl:choose>
   	<xsl:when test="count($ors/item) > 1">
         <or>
            <xsl:for-each select="$ors/item">
               <xsl:call-template name="and-expression">
                  <xsl:with-param name="expr" select="." />
                                 </xsl:call-template>
            </xsl:for-each>
         </or>
      </xsl:when>
   	<xsl:otherwise>
         <xsl:call-template name="and-expression">
         	<xsl:with-param name="expr" select="$expr" />
                     </xsl:call-template>
      </xsl:otherwise>
   </xsl:choose>
</xsl:template>

<xsl:template name="and-expression">
	<xsl:param name="expr" />
      <xsl:message>and-expression: <xsl:value-of select="$expr" /> ()</xsl:message>
   <xsl:variable name="ands-rtf">
      <xsl:call-template name="split">
         <xsl:with-param name="string" select="$expr" />
         <xsl:with-param name="at" select="'and'" />
         <xsl:with-param name="test-before" select="true()" />
         <xsl:with-param name="test-after" select="true()" />
      </xsl:call-template>
   </xsl:variable>
   <xsl:variable name="ands" select="msxsl:node-set($ands-rtf)" />
   <xsl:choose>
   	<xsl:when test="count($ands/item) > 1">
         <and>
            <xsl:for-each select="$ands/item">
               <xsl:call-template name="equality-expression">
                  <xsl:with-param name="expr" select="." />
               </xsl:call-template>
            </xsl:for-each>
         </and>
      </xsl:when>
   	<xsl:otherwise>
         <xsl:call-template name="equality-expression">
         	<xsl:with-param name="expr" select="$expr" />
         </xsl:call-template>
      </xsl:otherwise>
   </xsl:choose>
</xsl:template>

<xsl:template name="equality-expression">
	<xsl:param name="expr" />
      <xsl:message>equality-expression: <xsl:value-of select="$expr" /> ()</xsl:message>
   <xsl:variable name="split-on-equals-rtf">
   	<xsl:call-template name="split-at-first">
   		<xsl:with-param name="string" select="$expr" />
         <xsl:with-param name="at" select="'='" />
   	</xsl:call-template>
   </xsl:variable>
   <xsl:variable name="split-on-equals" select="msxsl:node-set($split-on-equals-rtf)/item" />
   <xsl:choose>
   	<xsl:when test="count($split-on-equals) > 1">
         <xsl:variable name="before-char" select="substring($split-on-equals[1], string-length($split-on-equals[1]), 1)" />
         <xsl:choose>
         	<xsl:when test="$before-char = '&lt;' or $before-char = '&gt;'">
               <xsl:call-template name="relational-expression">
               	<xsl:with-param name="expr" select="$expr" />
               </xsl:call-template>
            </xsl:when>
            <xsl:when test="$before-char = '!'">
               <neq>
                  <xsl:call-template name="relational-expression">
                     <xsl:with-param name="expr" select="substring($split-on-equals[1], 1, string-length($split-on-equals[1]) - 1)" />
                  </xsl:call-template>
                  <xsl:call-template name="equality-expression">
                     <xsl:with-param name="expr" select="$split-on-equals[2]" />
                  </xsl:call-template>
                  <xsl:text> </xsl:text>
              </neq>
            </xsl:when>
         	<xsl:otherwise>
               <eq>
                  <xsl:call-template name="relational-expression">
                     <xsl:with-param name="expr" select="$split-on-equals[1]" />
                  </xsl:call-template>
                  <xsl:call-template name="equality-expression">
                     <xsl:with-param name="expr" select="$split-on-equals[2]" />
                  </xsl:call-template>
                  <xsl:text> </xsl:text>
               </eq>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:when>
   	<xsl:otherwise>
         <xsl:call-template name="relational-expression">
         	<xsl:with-param name="expr" select="$expr" />
         </xsl:call-template>
      </xsl:otherwise>
   </xsl:choose>
</xsl:template>

<xsl:template name="relational-expression">
	<xsl:param name="expr" />
      <xsl:message>relational-expression: <xsl:value-of select="$expr" /> ()</xsl:message>
   <xsl:variable name="split-on-lt-rtf">
   	<xsl:call-template name="split-at-first">
   		<xsl:with-param name="string" select="$expr" />
         <xsl:with-param name="at" select="'&lt;'" />
   	</xsl:call-template>
   </xsl:variable>
   <xsl:variable name="split-on-lt" select="msxsl:node-set($split-on-lt-rtf)/item" />
   <xsl:variable name="split-on-gt-rtf">
   	<xsl:call-template name="split-at-first">
   		<xsl:with-param name="string" select="$expr" />
         <xsl:with-param name="at" select="'&gt;'" />
   	</xsl:call-template>
   </xsl:variable>
   <xsl:variable name="split-on-gt" select="msxsl:node-set($split-on-gt-rtf)/item" />
   <xsl:choose>
   	<xsl:when test="count($split-on-lt) > 1">
         <xsl:variable name="after-char" select="substring($split-on-lt[2], 1, 1)" />
         <xsl:choose>
            <xsl:when test="$after-char = '='">
               <lteq>
                  <xsl:call-template name="relational-expression">
                     <xsl:with-param name="expr" select="$split-on-lt[1]" />
                  </xsl:call-template>
                  <xsl:call-template name="relational-expression">
                     <xsl:with-param name="expr" select="substring($split-on-lt[2], 2)" />
                  </xsl:call-template>
                  <xsl:text> </xsl:text>
               </lteq>
            </xsl:when>
         	<xsl:otherwise>
               <lt>
                  <xsl:call-template name="relational-expression">
                     <xsl:with-param name="expr" select="$split-on-lt[1]" />
                  </xsl:call-template>
                  <xsl:call-template name="relational-expression">
                     <xsl:with-param name="expr" select="$split-on-lt[2]" />
                  </xsl:call-template>
                  <xsl:text> </xsl:text>
               </lt>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:when>
   	<xsl:when test="count($split-on-gt) > 1">
         <xsl:variable name="after-char" select="substring($split-on-gt[2], 1, 1)" />
         <xsl:choose>
            <xsl:when test="$after-char = '='">
               <gteq>
                  <xsl:call-template name="relational-expression">
                     <xsl:with-param name="expr" select="$split-on-gt[1]" />
                  </xsl:call-template>
                  <xsl:call-template name="relational-expression">
                     <xsl:with-param name="expr" select="substring($split-on-gt[2], 2)" />
                  </xsl:call-template>
                  <xsl:text> </xsl:text>
               </gteq>
            </xsl:when>
         	<xsl:otherwise>
               <gt>
                  <xsl:call-template name="relational-expression">
                     <xsl:with-param name="expr" select="$split-on-gt[1]" />
                  </xsl:call-template>
                  <xsl:call-template name="relational-expression">
                     <xsl:with-param name="expr" select="$split-on-gt[2]" />
                  </xsl:call-template>
                  <xsl:text> </xsl:text>
               </gt>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:when>
   	<xsl:otherwise>
         <xsl:call-template name="additative-expression">
         	<xsl:with-param name="expr" select="$expr" />
         </xsl:call-template>
      </xsl:otherwise>
   </xsl:choose>
</xsl:template>

<xsl:template name="additative-expression">
	<xsl:param name="expr" />
      <xsl:message>additative-expression: <xsl:value-of select="$expr" /> ()</xsl:message>
   <xsl:variable name="split-on-plus-rtf">
   	<xsl:call-template name="split-at-first">
   		<xsl:with-param name="string" select="$expr" />
         <xsl:with-param name="at" select="'+'" />
   	</xsl:call-template>
   </xsl:variable>
   <xsl:variable name="split-on-plus" select="msxsl:node-set($split-on-plus-rtf)/item" />
   <xsl:message>split on plus: <xsl:copy-of select="$split-on-plus" /></xsl:message>
   <xsl:variable name="split-on-minus-rtf">
   	<xsl:call-template name="split-at-first">
   		<xsl:with-param name="string" select="$expr" />
         <xsl:with-param name="at" select="'-'" />
         <xsl:with-param name="test-before" select="true()" />
   	</xsl:call-template>
   </xsl:variable>
   <xsl:variable name="split-on-minus" select="msxsl:node-set($split-on-minus-rtf)/item" />
   <xsl:message>split on minus: <xsl:copy-of select="$split-on-minus" /></xsl:message>
   <xsl:choose>
   	<xsl:when test="count($split-on-plus) > 1">
         <plus>
            <xsl:call-template name="additative-expression">
               <xsl:with-param name="expr" select="$split-on-plus[1]" />
            </xsl:call-template>
            <xsl:call-template name="additative-expression">
               <xsl:with-param name="expr" select="$split-on-plus[2]" />
            </xsl:call-template>
            <xsl:text> </xsl:text>
         </plus>
      </xsl:when>
   	<xsl:when test="count($split-on-minus) > 1">
         <minus>
            <xsl:call-template name="additative-expression">
               <xsl:with-param name="expr" select="$split-on-minus[1]" />
            </xsl:call-template>
            <xsl:call-template name="additative-expression">
               <xsl:with-param name="expr" select="$split-on-minus[2]" />
            </xsl:call-template>
            <xsl:text> </xsl:text>
         </minus>
      </xsl:when>
   	<xsl:otherwise>
         <xsl:call-template name="multiplicative-expression">
         	<xsl:with-param name="expr" select="$expr" />
         </xsl:call-template>
      </xsl:otherwise>
   </xsl:choose>
</xsl:template>

<xsl:template name="multiplicative-expression">
	<xsl:param name="expr" />
      <xsl:message>multiplicative-expression: <xsl:value-of select="$expr" /> ()</xsl:message>
   <xsl:variable name="split-on-times-rtf">
   	<xsl:call-template name="split-at-first">
   		<xsl:with-param name="string" select="$expr" />
         <xsl:with-param name="at" select="'*'" />
   	</xsl:call-template>
   </xsl:variable>
   <xsl:variable name="split-on-times" select="msxsl:node-set($split-on-times-rtf)/item" />
   <xsl:variable name="split-on-div-rtf">
   	<xsl:call-template name="split-at-first">
   		<xsl:with-param name="string" select="$expr" />
         <xsl:with-param name="at" select="'div'" />
         <xsl:with-param name="test-before" select="true()" />
         <xsl:with-param name="test-after" select="true()" />
   	</xsl:call-template>
   </xsl:variable>
   <xsl:variable name="split-on-div" select="msxsl:node-set($split-on-div-rtf)/item" />
   <xsl:variable name="split-on-mod-rtf">
   	<xsl:call-template name="split-at-first">
   		<xsl:with-param name="string" select="$expr" />
         <xsl:with-param name="at" select="'mod'" />
         <xsl:with-param name="test-before" select="true()" />
         <xsl:with-param name="test-after" select="true()" />
   	</xsl:call-template>
   </xsl:variable>
   <xsl:variable name="split-on-mod" select="msxsl:node-set($split-on-mod-rtf)/item" />
   <xsl:choose>
   	<xsl:when test="count($split-on-times) > 1">
         <times>
            <xsl:call-template name="multiplicative-expression">
               <xsl:with-param name="expr" select="$split-on-times[1]" />
            </xsl:call-template>
            <xsl:call-template name="multiplicative-expression">
               <xsl:with-param name="expr" select="$split-on-times[2]" />
            </xsl:call-template>
            <xsl:text> </xsl:text>
         </times>
      </xsl:when>
   	<xsl:when test="count($split-on-div) > 1">
         <div>
            <xsl:call-template name="multiplicative-expression">
               <xsl:with-param name="expr" select="$split-on-div[1]" />
            </xsl:call-template>
            <xsl:call-template name="multiplicative-expression">
               <xsl:with-param name="expr" select="$split-on-div[2]" />
            </xsl:call-template>
            <xsl:text> </xsl:text>
         </div>
      </xsl:when>
   	<xsl:when test="count($split-on-mod) > 1">
         <mod>
            <xsl:call-template name="multiplicative-expression">
               <xsl:with-param name="expr" select="$split-on-mod[1]" />
            </xsl:call-template>
            <xsl:call-template name="multiplicative-expression">
               <xsl:with-param name="expr" select="$split-on-mod[2]" />
            </xsl:call-template>
            <xsl:text> </xsl:text>
         </mod>
      </xsl:when>
   	<xsl:otherwise>
         <xsl:call-template name="unary-expression">
         	<xsl:with-param name="expr" select="$expr" />
         </xsl:call-template>
      </xsl:otherwise>
   </xsl:choose>
</xsl:template>

<xsl:template name="unary-expression">
	<xsl:param name="expr" />
      <xsl:message>unary-expression: <xsl:value-of select="$expr" /> ()</xsl:message>
   <xsl:choose>
   	<xsl:when test="starts-with(normalize-space($expr), '-')">
         <neg>
            <xsl:call-template name="union-expression">
               <xsl:with-param name="expr" select="substring-after($expr, '-')" />
            </xsl:call-template>
         </neg>
      </xsl:when>
   	<xsl:otherwise>
         <xsl:call-template name="union-expression">
         	<xsl:with-param name="expr" select="$expr" />
         </xsl:call-template>
      </xsl:otherwise>
   </xsl:choose>
</xsl:template>

<xsl:template name="union-expression">
   <xsl:param name="expr" />
   <xsl:message>union-expression: <xsl:value-of select="$expr" /> ()</xsl:message>
   <xsl:variable name="union-rtf">
   	<xsl:call-template name="split">
   		<xsl:with-param name="string" select="$expr" />
         <xsl:with-param name="at" select="'|'" />
   	</xsl:call-template>
   </xsl:variable>
   <xsl:variable name="union" select="msxsl:node-set($union-rtf)/item" />
   <xsl:choose>
      <xsl:when test="count($union) > 1">
         <union>
            <xsl:for-each select="$union">
               <xsl:call-template name="path-expression">
                  <xsl:with-param name="expr" select="." />
               </xsl:call-template>
            </xsl:for-each>
         </union>
      </xsl:when>
   	<xsl:otherwise>
         <xsl:call-template name="path-expression">
         	<xsl:with-param name="expr" select="$expr" />
          </xsl:call-template>
      </xsl:otherwise>
   </xsl:choose>
</xsl:template>

<xsl:template name="path-expression">
	<xsl:param name="expr" />
      <xsl:message>path-expression: <xsl:value-of select="$expr" /> ()</xsl:message>
   <xsl:variable name="path" select="normalize-space($expr)" />
   <xsl:choose>
      <xsl:when test="$path = '.'">
         <path><context /></path>
      </xsl:when>
      <xsl:when test="$path = '..'">
         <path>
            <context />
            <step axis="parent">
               <node />
            </step>
         </path>
      </xsl:when>
      <xsl:when test="contains($path, '/')">
         <xsl:variable name="from">
         	<xsl:choose>
         		<xsl:when test="starts-with($path, '//')">//</xsl:when>
               <xsl:when test="starts-with($path, '/')">/</xsl:when>
         	</xsl:choose>
         </xsl:variable>
         <xsl:variable name="steps-string">
            <xsl:choose>
               <xsl:when test="$from = '//'"><xsl:value-of select="substring-after($path, '//')" /></xsl:when>
               <xsl:when test="$from = '/'"><xsl:value-of select="substring-after($path, '/')" /></xsl:when>
               <xsl:otherwise><xsl:value-of select="$path" /></xsl:otherwise>
            </xsl:choose>
         </xsl:variable>
         <xsl:variable name="steps-rtf">
            <xsl:call-template name="split">
               <xsl:with-param name="string" select="$steps-string" />
               <xsl:with-param name="at" select="'/'" />
            </xsl:call-template>
         </xsl:variable>
         <xsl:variable name="steps" select="msxsl:node-set($steps-rtf)/item" />
         <xsl:choose>
            <xsl:when test="count($steps) = 1 and not(string($from))">
               <xsl:call-template name="primary-expression">
                  <xsl:with-param name="expr" select="$path" />
               </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
               <path>
                  <xsl:choose>
                     <xsl:when test="$from = '//'">
                        <root />
                        <step axis="descendant-or-self"><node /></step>
                        <xsl:call-template name="step">
                           <xsl:with-param name="xpath" select="$steps[1]" />
                        </xsl:call-template>
                     </xsl:when>
                     <xsl:when test="$from = '/'">
                        <root />
                        <xsl:call-template name="step">
                           <xsl:with-param name="xpath" select="$steps[1]" />
                        </xsl:call-template>
                     </xsl:when>
                     <xsl:otherwise>
                        <xsl:variable name="first-step-rtf">
                           <xsl:call-template name="primary-expression">
                              <xsl:with-param name="expr" select="$steps[1]" />
                           </xsl:call-template>
                        </xsl:variable>
                        <xsl:variable name="first-step" select="msxsl:node-set($first-step-rtf)" />
                        <xsl:choose>
                           <xsl:when test="$first-step/path"><xsl:copy-of select="$first-step/path/*" /></xsl:when>
                           <xsl:otherwise><xsl:copy-of select="$first-step/*" /></xsl:otherwise>
                        </xsl:choose>
                     </xsl:otherwise>
                  </xsl:choose>
                  <xsl:for-each select="$steps[position() > 1]">
                     <xsl:call-template name="step">
                        <xsl:with-param name="xpath" select="." />
                     </xsl:call-template>
                  </xsl:for-each>
               </path>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
         <xsl:call-template name="primary-expression">
            <xsl:with-param name="expr" select="$path" />
         </xsl:call-template>
      </xsl:otherwise>
   </xsl:choose>
</xsl:template>

<xsl:template name="primary-expression">
	<xsl:param name="expr" />
      <xsl:message>primary-expression: <xsl:value-of select="$expr" /> ()</xsl:message>
   <xsl:choose>
   	<xsl:when test="starts-with($expr, '$')">
         <xsl:choose>
            <xsl:when test="contains($expr, '[')">
               <path>
                  <var name="{substring-before(substring-after($expr, '$'), '[')}" />
                  <xsl:call-template name="predicates">
                    <xsl:with-param name="predicates" select="concat('[', substring-after(substring-after($expr, '$'), '['))" />
                  </xsl:call-template>
               </path>
            </xsl:when>
            <xsl:otherwise>
               <var name="{substring-after($expr, '$')}" />
            </xsl:otherwise>
         </xsl:choose>
      </xsl:when>
      <xsl:when test="starts-with($expr, '(') and substring($expr, string-length($expr), 1) = ')'">
         <expr>
            <xsl:call-template name="expression">
               <xsl:with-param name="expr" select="substring($expr, 2, string-length($expr) - 2)" />
            </xsl:call-template>
         </expr>
      </xsl:when>
      <xsl:when test="starts-with($expr, '&quot;')">
         <string><xsl:value-of select="substring($expr, 2, string-length($expr) - 2)" /></string>
      </xsl:when>
      <xsl:when test='starts-with($expr, "&apos;")'>
         <string><xsl:value-of select="substring($expr, 2, string-length($expr) - 2)" /></string>
      </xsl:when>
      <xsl:when test="string(number($expr)) != 'NaN'">
         <number><xsl:value-of select="number($expr)" /></number>
      </xsl:when>
      <xsl:when test="substring($expr, string-length($expr), 1) = ')' and
                      not($expr = 'comment()' or contains(substring-before($expr, '('), '::comment') or
                          $expr = 'text()' or contains(substring-before($expr, '('), '::text') or
                          $expr = 'node()' or contains(substring-before($expr, '('), '::node') or
                          substring-before($expr, '(') = 'processing-instruction' or
                          contains(substring-before($expr, '('), '::processing-instruction'))">
         <xsl:variable name="function" select="substring-before($expr, '(')" />
         <xsl:call-template name="function">
         	<xsl:with-param name="function" select="$function" />
            <xsl:with-param name="arg-string" select="substring-after(substring($expr, 1, string-length($expr) - 1), '(')" />
         </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
         <path>
            <context />
            <xsl:call-template name="step">
               <xsl:with-param name="xpath" select="$expr" />
            </xsl:call-template>
         </path>
      </xsl:otherwise>
  	</xsl:choose>
</xsl:template>

<xsl:template name="function">
   <xsl:param name="function" />
   <xsl:param name="arg-string" />
      <xsl:message>function: <xsl:value-of select="$function" /> ()</xsl:message>
   <xsl:variable name="args-rtf">
      <xsl:call-template name="split">
         <xsl:with-param name="string" select="$arg-string" />
         <xsl:with-param name="at" select="','" />
      </xsl:call-template>
   </xsl:variable>
   <xsl:variable name="args" select="msxsl:node-set($args-rtf)/item" />
   <function name="{$function}">
      <xsl:for-each select="$args">
         <xsl:if test="string(.)">
            <arg>
               <xsl:call-template name="expression">
                  <xsl:with-param name="expr" select="." />
               </xsl:call-template>
            </arg>
         </xsl:if>
      </xsl:for-each>
   </function>
</xsl:template>

<xsl:template name="step">
	<xsl:param name="xpath" />
   <xsl:message>step: <xsl:value-of select="$xpath" /></xsl:message>
   <xsl:variable name="step-rtf">
      <xsl:call-template name="split-at-first">
         <xsl:with-param name="string" select="$xpath" />
         <xsl:with-param name="at" select="'['" />
      </xsl:call-template>
   </xsl:variable>
   <xsl:variable name="step" select="msxsl:node-set($step-rtf)/item" />
   <xsl:variable name="predicates">
      <xsl:if test="$step[2]">[<xsl:value-of select="$step[2]" /></xsl:if>
   </xsl:variable>
   <xsl:variable name="no-pred" select="$step[1]" />
   <step>
      <xsl:choose>
         <xsl:when test="starts-with($no-pred, '$')">
            <var name="{substring-after($no-pred, '$')}" />            
         </xsl:when>
         <xsl:when test="starts-with($no-pred, '(') and substring($no-pred, string-length($no-pred), 1) = ')'">
            <expr>
               <xsl:call-template name="expression">
                  <xsl:with-param name="expr" select="substring($no-pred, 2, string-length($no-pred) - 2)" />
               </xsl:call-template>
            </expr>
         </xsl:when>
         <xsl:when test="substring($no-pred, string-length($no-pred), 1) = ')' and
                         not($no-pred = 'comment()' or contains(substring-before($no-pred, '('), '::comment') or
                             $no-pred = 'text()' or contains(substring-before($no-pred, '('), '::text') or
                             $no-pred = 'node()' or contains(substring-before($no-pred, '('), '::node') or
                             substring-before($no-pred, '(') = 'processing-instruction' or
                             contains(substring-before($no-pred, '('), '::processing-instruction'))">
            <xsl:variable name="function" select="substring-before($no-pred, '(')" />
            <xsl:call-template name="function">
               <xsl:with-param name="function" select="$function" />
               <xsl:with-param name="arg-string" select="substring-after(substring($no-pred, 1, string-length($no-pred) - 1), '(')" />
            </xsl:call-template>
         </xsl:when>
         <xsl:otherwise>
            <xsl:variable name="axis">
               <xsl:choose>
                  <xsl:when test="contains($no-pred, '::')"><xsl:value-of select="substring-before($no-pred, '::')" /></xsl:when>
                  <xsl:when test="starts-with($no-pred, '@')">attribute</xsl:when>
                  <xsl:when test="$no-pred = '.'">self</xsl:when>
                  <xsl:when test="$no-pred = '..'">parent</xsl:when>
                  <xsl:when test="not(string($no-pred))">descendant-or-self</xsl:when>
                  <xsl:otherwise>child</xsl:otherwise>
               </xsl:choose>
            </xsl:variable>
            <xsl:variable name="node-test">
               <xsl:choose>
                  <xsl:when test="contains($no-pred, '::')"><xsl:value-of select="substring-after($no-pred, '::')" /></xsl:when>
                  <xsl:when test="starts-with($no-pred, '@')"><xsl:value-of select="substring-after($no-pred, '@')" /></xsl:when>
                  <xsl:when test="not(string($xpath)) or $xpath = '.' or $xpath = '..'">node()</xsl:when>
                  <xsl:otherwise><xsl:value-of select="$no-pred" /></xsl:otherwise>
               </xsl:choose>
            </xsl:variable>
            <xsl:variable name="namespace">
               <xsl:choose>
                  <xsl:when test="$node-test = '*'">any</xsl:when>
                  <xsl:when test="contains($node-test, ':')"><xsl:value-of select="substring-before($node-test, ':')" /></xsl:when>
                  <xsl:when test="$axis = 'attribute'">element</xsl:when>
                  <xsl:otherwise>default</xsl:otherwise>
               </xsl:choose>
            </xsl:variable>
            <xsl:variable name="node-type">
               <xsl:choose>
                  <xsl:when test="contains($node-test, ':')"><xsl:value-of select="substring-after($node-test, ':')" /></xsl:when>
                  <xsl:otherwise><xsl:value-of select="$node-test" /></xsl:otherwise>
               </xsl:choose>
            </xsl:variable>
            <xsl:attribute name="axis"><xsl:value-of select="$axis" /></xsl:attribute>
            <xsl:choose>
               <xsl:when test="$node-type = '.'"><context /></xsl:when>
               <xsl:when test="$node-type = 'comment()'"><comment /></xsl:when>
               <xsl:when test="$node-type = 'text()'"><text /></xsl:when>
               <xsl:when test="$node-type = 'node()'"><node /></xsl:when>
               <xsl:when test="$node-type = 'processing-instruction()'"><pi /></xsl:when>
               <xsl:when test="starts-with($node-type, 'processing-instruction(')">
                  <xsl:variable name="pi-arg" select="normalize-space(substring-before(substring-after($node-type, 'processing-instruction('), ')'))" />
                  <xsl:variable name="pi-name" select="substring($pi-arg, 2, string-length($pi-arg) - 2)" />
                  <pi name="{$pi-name}" />
               </xsl:when>
               <xsl:when test="$node-type = '*'">
                  <xsl:choose>
                     <xsl:when test="$axis = 'attribute'"><attribute namespace="{$namespace}" /></xsl:when>
                     <xsl:otherwise><element namespace="{$namespace}" /></xsl:otherwise>
                  </xsl:choose>
               </xsl:when>
               <xsl:when test="$axis = 'attribute'"><attribute name="{$node-type}" namespace="{$namespace}" /></xsl:when>
               <xsl:otherwise><element name="{$node-type}" namespace="{$namespace}" /></xsl:otherwise>
            </xsl:choose>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="string($predicates)">
         <xsl:call-template name="predicates">
           <xsl:with-param name="predicates" select="$predicates" />
         </xsl:call-template>
      </xsl:if>
   </step>
</xsl:template>

<xsl:template name="predicates">
	<xsl:param name="predicates" />
   <xsl:message>predicates: <xsl:value-of select="$predicates" /></xsl:message>
   <xsl:variable name="preds-rtf">
   	<xsl:call-template name="split-at-first">
   		<xsl:with-param name="string" select="substring($predicates, 2)" />
         <xsl:with-param name="at" select="']'" />
   	</xsl:call-template>
   </xsl:variable>
   <xsl:variable name="preds" select="msxsl:node-set($preds-rtf)/item" />
   <xsl:choose>
      <xsl:when test="$preds[2]">
         <xsl:call-template name="predicate">
            <xsl:with-param name="predicate" select="$preds[1]" />
         </xsl:call-template>
         <xsl:call-template name="predicates">
            <xsl:with-param name="predicates" select="$preds[2]" />
         </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
         <xsl:call-template name="predicate">
            <xsl:with-param name="predicate" select="substring($preds[1], 1, string-length($preds[1]) - 1)" />
         </xsl:call-template>
      </xsl:otherwise>
   </xsl:choose>
</xsl:template>

<xsl:variable name="quot" select="'&quot;'" />
<xsl:variable name="punctuation" select='concat(" []()|&lt;&gt;&apos;", $quot)' />

<xsl:template name="split-at-first">
	<xsl:param name="string" />
   <xsl:param name="at" />
   <xsl:param name="test-before" select="false()" />
   <xsl:param name="test-after" select="false()" />
   <xsl:param name="include" />
   <xsl:message>splitting <xsl:value-of select="$string" /> on '<xsl:value-of select="$at" />'</xsl:message>
   <xsl:choose>
      <xsl:when test="contains($string, $at)">
         <xsl:variable name="before" select="substring-before($string, $at)" />
         <xsl:variable name="after" select="substring-after($string, $at)" />
         <xsl:variable name="combined" select="concat($include, $before)" />
         <xsl:variable name="test">
            <xsl:if test="not($before)">no before</xsl:if>
            <xsl:if test="not($after)">no after</xsl:if>
            <xsl:if test="$test-before and not(contains($punctuation, substring($before, string-length($before), 1)))">bad before</xsl:if>
            <xsl:if test="$test-after and not(contains($punctuation, substring($after, 1, 1)))">bad after</xsl:if>
            <xsl:if test="$at = '*' and (contains('@:([/', substring($before, string-length($before), 1)) or
                                         contains('|', substring(normalize-space($before), string-length(normalize-space($before)), 1)))">not multiplies</xsl:if>
         </xsl:variable>
         <xsl:choose>
            <xsl:when test="string($test)">
               <xsl:call-template name="split-at-first">
               	<xsl:with-param name="string" select="$after" />
                  <xsl:with-param name="at" select="$at" />
                  <xsl:with-param name="include" select="concat($include, $before, $at)" />
                  <xsl:with-param name="test-before" select="$test-before" />
                  <xsl:with-param name="test-after" select="$test-after" />
               </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
               <xsl:variable name="balanced-before">
                  <xsl:call-template name="balanced">
                     <xsl:with-param name="string" select="$combined" />
                  </xsl:call-template>
               </xsl:variable>
               <xsl:message>balanced? <xsl:value-of select="$combined" />: <xsl:value-of select="$balanced-before" /></xsl:message>
               <xsl:choose>
                  <xsl:when test="$balanced-before = 'yes'">
                     <item><xsl:value-of select="normalize-space($combined)" /></item>
                     <item><xsl:value-of select="normalize-space(substring-after($string, $at))" /></item>
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:call-template name="split-at-first">
                        <xsl:with-param name="string" select="$after" />
                        <xsl:with-param name="at" select="$at" />
                        <xsl:with-param name="include" select="concat($include, $before, $at)" />
                        <xsl:with-param name="test-before" select="$test-before" />
                        <xsl:with-param name="test-after" select="$test-after" />
                     </xsl:call-template>
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:when>
   	<xsl:otherwise><item><xsl:value-of select="concat($include, $string)" /></item></xsl:otherwise>
   </xsl:choose>
</xsl:template>

<xsl:template name="split">
	<xsl:param name="string" />
   <xsl:param name="at" />
   <xsl:param name="test-before" select="false()" />
   <xsl:param name="test-after" select="false()" />
   <xsl:variable name="split-rtf">
   	<xsl:call-template name="split-at-first">
   		<xsl:with-param name="string" select="$string" />
         <xsl:with-param name="at" select="$at" />
         <xsl:with-param name="test-before" select="$test-before" />
         <xsl:with-param name="test-after" select="$test-after" />
      </xsl:call-template>
   </xsl:variable>
   <xsl:variable name="split" select="msxsl:node-set($split-rtf)/item" />
   <xsl:choose>
      <xsl:when test="count($split) > 1">
         <xsl:copy-of select="$split[1]" />
         <xsl:call-template name="split">
         	<xsl:with-param name="string" select="string($split[2])" />
            <xsl:with-param name="at" select="$at" />
         </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
         <xsl:copy-of select="$split[1]" />
      </xsl:otherwise>
   </xsl:choose>
</xsl:template>

<xsl:template name="balanced">
	<xsl:param name="string" />
   <xsl:variable name="quotes">
   	<xsl:call-template name="count">
   		<xsl:with-param name="string" select="$string" />
         <xsl:with-param name="count" select="'&quot;'" />
   	</xsl:call-template>
   </xsl:variable>
   <xsl:variable name="apos">
   	<xsl:call-template name="count">
   		<xsl:with-param name="string" select="$string" />
         <xsl:with-param name="count" select='"&apos;"' />
   	</xsl:call-template>
   </xsl:variable>
   <xsl:choose>
      <xsl:when test="($apos = 0 and $quotes mod 2 = 1) or ($quotes = 0 and $apos mod 2 = 1) or ($quotes mod 2 = 1 and $apos mod 2 = 1)">no</xsl:when>
      <xsl:otherwise>
         <xsl:variable name="test-string">
            <xsl:call-template name="omit-strings">
               <xsl:with-param name="string" select="$string" />
            </xsl:call-template>
         </xsl:variable>
         <xsl:variable name="open-braces">
            <xsl:call-template name="count">
               <xsl:with-param name="string" select="$test-string" />
               <xsl:with-param name="count" select="'('" />
            </xsl:call-template>
         </xsl:variable>
         <xsl:variable name="close-braces">
            <xsl:call-template name="count">
               <xsl:with-param name="string" select="$test-string" />
               <xsl:with-param name="count" select="')'" />
            </xsl:call-template>
         </xsl:variable>
         <xsl:variable name="open-square">
            <xsl:call-template name="count">
               <xsl:with-param name="string" select="$test-string" />
               <xsl:with-param name="count" select="'['" />
            </xsl:call-template>
         </xsl:variable>
         <xsl:variable name="close-square">
            <xsl:call-template name="count">
               <xsl:with-param name="string" select="$test-string" />
               <xsl:with-param name="count" select="']'" />
            </xsl:call-template>
         </xsl:variable>
         <xsl:choose>
            <xsl:when test="$open-braces != $close-braces">no</xsl:when>
            <xsl:when test="$open-square != $close-square">no</xsl:when>
            <xsl:otherwise>yes</xsl:otherwise>
         </xsl:choose>
      </xsl:otherwise>
   </xsl:choose>
</xsl:template>

<xsl:template name="count">
	<xsl:param name="string" />
   <xsl:param name="count" />
   <xsl:choose>
   	<xsl:when test="contains($string, $count)">
         <xsl:variable name="total">
         	<xsl:call-template name="count">
         		<xsl:with-param name="string" select="substring-after($string, $count)" />
               <xsl:with-param name="count" select="$count" />
         	</xsl:call-template>
         </xsl:variable>
         <xsl:value-of select="$total + 1" />
      </xsl:when>
   	<xsl:otherwise>0</xsl:otherwise>
   </xsl:choose>
</xsl:template>

<xsl:template name="omit-strings">
   <xsl:param name="string" />
   <xsl:variable name="first-quote">
      <xsl:variable name="quot" select="substring-before($string, '&quot;')" />
      <xsl:variable name="apos" select='substring-before($string, "&apos;")' />
      <xsl:choose>
         <xsl:when test="contains($string, '&quot;') and string-length($quot) &lt; string-length($apos)">"</xsl:when>
         <xsl:when test='contains($string, "&apos;")'>&apos;</xsl:when>
      </xsl:choose>
   </xsl:variable>
   <xsl:choose>
      <xsl:when test="string($first-quote)">
         <xsl:variable name="after" select="substring-after($string, $first-quote)" />
         <xsl:value-of select="substring-before($string, $first-quote)" />
         <xsl:call-template name="omit-strings">
            <xsl:with-param name="string" select="substring-after($after, $first-quote)" />
         </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
         <xsl:value-of select="$string" />
      </xsl:otherwise>
   </xsl:choose>
</xsl:template>

</xsl:stylesheet>