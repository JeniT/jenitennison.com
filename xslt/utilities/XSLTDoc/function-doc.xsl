<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template match="function[@name = 'last']" mode="explain-xpath">
   <xsl:param name="context" />
   <xsl:if test="$context = 'string'"> the string value of</xsl:if>
   <xsl:text> the length of the context node list</xsl:text>
   <xsl:if test="$context = 'boolean'"> is non-zero (always true)</xsl:if>
</xsl:template>

<xsl:template match="function[@name = 'position']" mode="explain-xpath">
   <xsl:param name="context" />
   <xsl:if test="$context = 'string'"> the string value of</xsl:if>
   <xsl:choose>
      <xsl:when test="$context = 'predicate'"> its position</xsl:when>
      <xsl:otherwise>
         <xsl:text> the position of the</xsl:text>
         <xsl:choose>
            <xsl:when test="ancestor::predicate"> context node</xsl:when>
            <xsl:otherwise> current node</xsl:otherwise>
         </xsl:choose>
      </xsl:otherwise>
   </xsl:choose>
   <xsl:if test="$context = 'boolean'"> is non-zero (always true)</xsl:if>
</xsl:template>

<xsl:template match="function[@name = 'count']" mode="explain-xpath">
   <xsl:param name="context" />
   <xsl:if test="$context = 'string'"> the string value of</xsl:if>
   <xsl:text> the number of nodes in the node set comprising</xsl:text>
   <xsl:apply-templates select="arg[1]/*" mode="explain-xpath">
      <xsl:with-param name="context" select="'node-set'" />
   </xsl:apply-templates>
   <xsl:if test="$context = 'boolean'"> is non-zero (true if the node set has any nodes in it; this function is superfluous)</xsl:if>
</xsl:template>

<xsl:template match="function[@name = 'id']" mode="explain-xpath">
   <xsl:param name="context" />
   <xsl:choose>
      <xsl:when test="$context = 'string'"> the string value of</xsl:when>
      <xsl:when test="$context = 'number'"> the numerical value of</xsl:when>
      <xsl:when test="$context = 'boolean' or $context = 'predicate'"> there are any nodes in the node set comprising</xsl:when>
   </xsl:choose>
   <xsl:choose>
      <xsl:when test="arg[1]/path">
         <xsl:text> those elements that have ID attributes equal to the string values of</xsl:text>
         <xsl:apply-templates select="arg[1]/*" mode="explain-xpath">
            <xsl:with-param name="context" select="'node-set'" />
         </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="arg[1]/string">
         <xsl:text> the element with an ID of</xsl:text>
         <xsl:apply-templates select="arg[1]/*" mode="explain-xpath">
            <xsl:with-param name="context" select="'string'" />
         </xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise>
         <xsl:text> the element with an ID equal to</xsl:text>
         <xsl:apply-templates select="arg[1]/*" mode="explain-xpath">
            <xsl:with-param name="context" select="'string'" />
         </xsl:apply-templates>
      </xsl:otherwise>
   </xsl:choose>
</xsl:template>

<xsl:template match="function[@name = 'local-name']" mode="explain-xpath">
   <xsl:param name="context" />
   <xsl:if test="$context = 'number'"> the numerical value of</xsl:if>
   <xsl:text> the local part of</xsl:text>
   <xsl:choose>
      <xsl:when test="arg[1]/*">
         <xsl:text> the name of the first node in the node set comprising</xsl:text>
         <xsl:apply-templates select="arg[1]/*" mode="explain-xpath">
            <xsl:with-param name="context" select="'node-set'" />
         </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$context = 'predicate'"> its name</xsl:when>
      <xsl:otherwise>
         <xsl:text> the name of the</xsl:text>
         <xsl:choose>
            <xsl:when test="ancestor::predicate"> context node</xsl:when>
            <xsl:otherwise> current node</xsl:otherwise>
         </xsl:choose>
      </xsl:otherwise>
   </xsl:choose>
   <xsl:if test="$context = 'boolean' or $context = 'predicate'"> is a non-empty string (always true)</xsl:if>
</xsl:template>

<xsl:template match="function[@name = 'namespace-uri']" mode="explain-xpath">
   <xsl:param name="context" />
   <xsl:if test="$context = 'number'"> the numerical value of</xsl:if>
   <xsl:text> the URI of</xsl:text>
   <xsl:choose>
      <xsl:when test="arg[1]/*">
         <xsl:text> the namespace of the first node in the node set comprising</xsl:text>
         <xsl:apply-templates select="arg[1]/*" mode="explain-xpath">
            <xsl:with-param name="context" select="'node-set'" />
         </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$context = 'predicate'"> its namespace</xsl:when>
      <xsl:otherwise>
         <xsl:text> the namespace of the</xsl:text>
         <xsl:choose>
            <xsl:when test="ancestor::predicate"> context node</xsl:when>
            <xsl:otherwise> current node</xsl:otherwise>
         </xsl:choose>
      </xsl:otherwise>
   </xsl:choose>
   <xsl:choose>
      <xsl:when test="$context = 'number'"> (almost certainly NaN)</xsl:when>
      <xsl:when test="$context = 'boolean' or $context = 'predicate'"> is a non-empty string (true unless there is no node or the node is in the default namespace)</xsl:when>
   </xsl:choose>
</xsl:template>

<xsl:template match="function[@name = 'name']" mode="explain-xpath">
   <xsl:param name="context" />
   <xsl:if test="$context = 'number'"> the numerical value of</xsl:if>
   <xsl:choose>
      <xsl:when test="arg[1]/*">
         <xsl:text> the expanded name of the first node in the node set comprising</xsl:text>
         <xsl:apply-templates select="arg[1]/*" mode="explain-xpath">
            <xsl:with-param name="context" select="'node-set'" />
         </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$context = 'predicate'"> its expanded name</xsl:when>
      <xsl:otherwise>
         <xsl:text> the expanded name of the</xsl:text>
         <xsl:choose>
            <xsl:when test="ancestor::predicate"> context node</xsl:when>
            <xsl:otherwise> current node</xsl:otherwise>
         </xsl:choose>
      </xsl:otherwise>
   </xsl:choose>
   <xsl:if test="$context = 'boolean' or $context = 'predicate'"> is a non-empty string (always true)</xsl:if>
</xsl:template>

<xsl:template match="function[@name = 'string']" mode="explain-xpath">
	<xsl:param name="context" />
   <xsl:if test="$context = 'number'"> the numerical value of</xsl:if>
   <xsl:apply-templates select="arg[1]/*" mode="explain-xpath">
      <xsl:with-param name="context" select="'string'" />
   </xsl:apply-templates>
   <xsl:choose>
      <xsl:when test="$context = 'boolean' or $context = 'predicate'"> is a non-empty string</xsl:when>
      <xsl:when test="$context = 'string'"> (this is a string context anyway; this function is superfluous)</xsl:when>
   </xsl:choose>
</xsl:template>

<xsl:template match="function[@name = 'concat']" mode="explain-xpath">
	<xsl:param name="context" />
   <xsl:if test="$context = 'number'"> the numerical value of</xsl:if>
   <xsl:text> the concatenation of:</xsl:text>   
   <ul>
      <xsl:for-each select="arg">
         <li>
            <xsl:apply-templates select="*" mode="explain-xpath">
               <xsl:with-param name="context" select="'string'" />
            </xsl:apply-templates>
         </li>
      </xsl:for-each>
   </ul>
   <xsl:if test="$context = 'boolean' or $context = 'predicate'"> is a non-empty string</xsl:if>
</xsl:template>

<xsl:template match="function[@name = 'starts-with']" mode="explain-xpath">
	<xsl:param name="context" />
   <xsl:choose>
      <xsl:when test="$context = 'string'"> the string value ('true' or 'false') of whether</xsl:when>
      <xsl:when test="$context = 'number'"> the numerical value (0 or 1) of whether</xsl:when>
   </xsl:choose>
   <ul>
      <li>
         <xsl:apply-templates select="arg[1]/*" mode="explain-xpath">
            <xsl:with-param name="context" select="'string'" />
         </xsl:apply-templates>
         <span class="join"> starts with</span>
      </li>
      <li>
         <xsl:apply-templates select="arg[2]/*" mode="explain-xpath">
            <xsl:with-param name="context" select="'string'" />
         </xsl:apply-templates>
      </li>
   </ul>
</xsl:template>

<xsl:template match="function[@name = 'contains']" mode="explain-xpath">
	<xsl:param name="context" />
   <xsl:choose>
      <xsl:when test="$context = 'string'"> the string value ('true' or 'false') of whether</xsl:when>
      <xsl:when test="$context = 'number'"> the numerical value (0 or 1) of whether</xsl:when>
   </xsl:choose>
   <ul>
      <li>
         <xsl:apply-templates select="arg[1]/*" mode="explain-xpath">
            <xsl:with-param name="context" select="'string'" />
         </xsl:apply-templates>
         <span class="join"> contains</span>
      </li>
      <li>
         <xsl:apply-templates select="arg[2]/*" mode="explain-xpath">
            <xsl:with-param name="context" select="'string'" />
         </xsl:apply-templates>
      </li>
   </ul>
</xsl:template>

<xsl:template match="function[@name = 'substring-before']" mode="explain-xpath">
	<xsl:param name="context" />
   <xsl:if test="$context = 'number'"> the numerical value of</xsl:if>
   <xsl:text> the text before</xsl:text>
   <xsl:apply-templates select="arg[2]/*" mode="explain-xpath">
      <xsl:with-param name="context" select="'string'" />
   </xsl:apply-templates>
   <xsl:text> in</xsl:text>
   <xsl:apply-templates select="arg[1]/*" mode="explain-xpath">
      <xsl:with-param name="context" select="'string'" />
   </xsl:apply-templates>
   <xsl:if test="$context = 'boolean' or $context = 'predicate'"> is a non-empty string</xsl:if>
</xsl:template>

<xsl:template match="function[@name = 'substring-after']" mode="explain-xpath">
	<xsl:param name="context" />
   <xsl:if test="$context = 'number'"> the numerical value of</xsl:if>
   <xsl:text> the text after</xsl:text>
   <xsl:apply-templates select="arg[2]/*" mode="explain-xpath">
      <xsl:with-param name="context" select="'string'" />
   </xsl:apply-templates>
   <xsl:text> in</xsl:text>
   <xsl:apply-templates select="arg[1]/*" mode="explain-xpath">
      <xsl:with-param name="context" select="'string'" />
   </xsl:apply-templates>
   <xsl:if test="$context = 'boolean' or $context = 'predicate'"> is a non-empty string</xsl:if>
</xsl:template>

<xsl:template match="function[@name = 'substring']" mode="explain-xpath">
	<xsl:param name="context" />
   <xsl:if test="$context = 'number'"> the numerical value of</xsl:if>
   <xsl:choose>
      <xsl:when test="arg[2]/number = 1">
         <xsl:text> the first</xsl:text>
         <xsl:choose>
            <xsl:when test="arg[3]/number = 1">
               <xsl:text> character of</xsl:text>
            </xsl:when>
            <xsl:otherwise>
               <xsl:apply-templates select="arg[3]/*" mode="explain-xpath">
                  <xsl:with-param name="context" select="'number'" />
               </xsl:apply-templates>
               <xsl:text> characters of</xsl:text>
            </xsl:otherwise>
         </xsl:choose>
         <xsl:apply-templates select="arg[1]/*" mode="explain-xpath">
            <xsl:with-param name="context" select="'string'" />
         </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="arg[2]/function[@name = 'string-length'] and
                      ((arg[1]/var and arg[2]/function/arg/var and
                        arg[2]/function/arg/var/@name = arg[1]/var/@name) or
                       (arg[1]/string and arg[2]/function/arg/string and
                        arg[2]/function/arg/string = arg[1]/string))">
         <xsl:text> the last character of</xsl:text>
         <xsl:apply-templates select="arg[1]/*" mode="explain-xpath">
            <xsl:with-param name="context" select="'string'" />
         </xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise>
         <xsl:text> the substring of</xsl:text>
         <xsl:apply-templates select="arg[1]/*" mode="explain-xpath">
            <xsl:with-param name="context" select="'string'" />
         </xsl:apply-templates>
         <xsl:text> starting at character</xsl:text>
         <xsl:apply-templates select="arg[2]/*" mode="explain-xpath">
            <xsl:with-param name="context" select="'number'" />
         </xsl:apply-templates>
         <xsl:if test="arg[3]">
            <xsl:text> and</xsl:text>
            <xsl:apply-templates select="arg[3]/*" mode="explain-xpath">
               <xsl:with-param name="context" select="'number'" />
            </xsl:apply-templates>
            <xsl:choose>
               <xsl:when test="arg[3]/number = 1"> character long</xsl:when>
               <xsl:otherwise> characters long</xsl:otherwise>
            </xsl:choose>
         </xsl:if>
      </xsl:otherwise>
   </xsl:choose>
   <xsl:if test="$context = 'boolean' or $context = 'predicate'"> is a non-empty string</xsl:if>
</xsl:template>

<xsl:template match="function[@name = 'string-length']" mode="explain-xpath">
	<xsl:param name="context" />
   <xsl:if test="$context = 'string'"> the string value of</xsl:if>
   <xsl:text> the number of characters in</xsl:text>
   <xsl:choose>
      <xsl:when test="arg[1]">
         <xsl:apply-templates select="arg[1]/*" mode="explain-xpath">
            <xsl:with-param name="context" select="'string'" />
         </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$context = 'predicate'"> its string value</xsl:when>
      <xsl:otherwise>
         <xsl:text> the string value of the</xsl:text>
         <xsl:choose>
            <xsl:when test="ancestor::predicate"> context node</xsl:when>
            <xsl:otherwise> current node</xsl:otherwise>
         </xsl:choose>
      </xsl:otherwise>
   </xsl:choose>
   <xsl:if test="$context = 'boolean' or $context = 'predicate'"> is non-zero (true if the argument is a non-empty string; this function is superfluous)</xsl:if>
</xsl:template>

<xsl:template match="function[@name = 'normalize-space']" mode="explain-xpath">
	<xsl:param name="context" />
   <xsl:if test="$context = 'number'"> the numerical value of</xsl:if>
   <xsl:choose>
      <xsl:when test="arg[1]">
         <xsl:apply-templates select="arg[1]/*" mode="explain-xpath">
            <xsl:with-param name="context" select="'string'" />
         </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$context = 'predicate'"> its string value</xsl:when>
      <xsl:otherwise>
         <xsl:text> the string value of the</xsl:text>
         <xsl:choose>
            <xsl:when test="ancestor::predicate"> context node</xsl:when>
            <xsl:otherwise> current node</xsl:otherwise>
         </xsl:choose>
      </xsl:otherwise>
   </xsl:choose>
   <xsl:text> with starting and ending whitespace stripped and any line breaks substituted for spaces</xsl:text>
   <xsl:if test="$context = 'boolean' or $context = 'predicate'"> is a non-empty string</xsl:if>
</xsl:template>

<xsl:template match="function[@name = 'translate']" mode="explain-xpath">
	<xsl:param name="context" />
   <xsl:if test="$context = 'number'"> the numerical value of</xsl:if>
   <xsl:apply-templates select="arg[1]/*" mode="explain-xpath">
      <xsl:with-param name="context" select="'string'" />
   </xsl:apply-templates>
   <xsl:text> with the characters in</xsl:text>
   <xsl:apply-templates select="arg[2]/*" mode="explain-xpath">
      <xsl:with-param name="context" select="'string'" />
   </xsl:apply-templates>
   <xsl:text> substituted for the corresponding character in</xsl:text>
   <xsl:apply-templates select="arg[3]/*" mode="explain-xpath">
      <xsl:with-param name="context" select="'string'" />
   </xsl:apply-templates>
   <xsl:if test="$context = 'boolean' or $context = 'predicate'"> is a non-empty string</xsl:if>
</xsl:template>

<xsl:template match="function[@name = 'boolean']" mode="explain-xpath">
   <xsl:param name="context" />
   <xsl:choose>
      <xsl:when test="$context = 'string'"> the string value ('true' or 'false') of whether</xsl:when>
      <xsl:when test="$context = 'number'"> the numerical value (0 or 1) of whether</xsl:when>
   </xsl:choose>
   <xsl:apply-templates select="arg[1]/*" mode="explain-xpath">
      <xsl:with-param name="context" select="'boolean'" />
   </xsl:apply-templates>
   <xsl:if test="$context = 'boolean'"> (this is in a boolean context anyway; this function is superfluous)</xsl:if>
</xsl:template>

<xsl:template match="function[@name = 'not']" mode="explain-xpath">
   <xsl:param name="context" />
   <xsl:choose>
      <xsl:when test="$context = 'string'"> the string value ('true' or 'false') of whether</xsl:when>
      <xsl:when test="$context = 'number'"> the numerical value (0 or 1) of whether</xsl:when>
   </xsl:choose>
   <xsl:choose>
      <xsl:when test="arg/var">
         <xsl:text> the</xsl:text>
         <xsl:call-template name="explain-variable">
            <xsl:with-param name="variable-name" select="@name" />
         </xsl:call-template>
         <xsl:text> variable is false, an empty string, zero, NaN or an empty node set</xsl:text>
      </xsl:when>
      <xsl:otherwise>
         <xsl:text> it is not the case that</xsl:text>
         <xsl:apply-templates select="arg[1]/*" mode="explain-xpath">
            <xsl:with-param name="context" select="'boolean'" />
         </xsl:apply-templates>
      </xsl:otherwise>
   </xsl:choose>
</xsl:template>

<xsl:template match="function[@name = 'true']" mode="explain-xpath">
   <xsl:param name="context" />
   <xsl:choose>
      <xsl:when test="$context = 'string'"> 'true'</xsl:when>
      <xsl:when test="$context = 'number'"> 1</xsl:when>
      <xsl:otherwise>true</xsl:otherwise>
   </xsl:choose>
</xsl:template>

<xsl:template match="function[@name = 'false']" mode="explain-xpath">
   <xsl:param name="context" />
   <xsl:choose>
      <xsl:when test="$context = 'string'"> 'false'</xsl:when>
      <xsl:when test="$context = 'number'"> 0</xsl:when>
      <xsl:otherwise>false</xsl:otherwise>
   </xsl:choose>
</xsl:template>

<xsl:template match="function[@name = 'lang']" mode="explain-xpath">
   <xsl:param name="context" />
   <xsl:choose>
      <xsl:when test="$context = 'string'"> the string value ('true' or 'false') of whether</xsl:when>
      <xsl:when test="$context = 'number'"> the numerical value (0 or 1) of whether</xsl:when>
   </xsl:choose>
   <xsl:choose>
      <xsl:when test="$context = 'predicate'"> its language is</xsl:when>
      <xsl:otherwise>
         <xsl:text> the language of the</xsl:text>
         <xsl:choose>
            <xsl:when test="ancestor::predicate"> context node is</xsl:when>
            <xsl:otherwise> current node is</xsl:otherwise>
         </xsl:choose>
      </xsl:otherwise>
   </xsl:choose>
   <xsl:apply-templates select="arg[1]/*" mode="explain-xpath">
      <xsl:with-param name="context" select="'string'" />
   </xsl:apply-templates>
</xsl:template>

<xsl:template match="function[@name = 'number']" mode="explain-xpath">
   <xsl:param name="context" />
   <xsl:if test="$context = 'string'"> the string value of</xsl:if>
   <xsl:apply-templates select="arg[1]/*" mode="explain-xpath">
      <xsl:with-param name="context" select="'number'" />
   </xsl:apply-templates>
   <xsl:choose>
      <xsl:when test="$context = 'boolean'"> is non-zero</xsl:when>
      <xsl:when test="$context = 'number'"> (this is a numerical context anyway; this function is superfluous)</xsl:when>
   </xsl:choose>
</xsl:template>

<xsl:template match="function[@name = 'sum']" mode="explain-xpath">
	<xsl:param name="context" />
   <xsl:if test="$context = 'string'"> the string value of</xsl:if>
   <xsl:text> the sum of the numerical values of</xsl:text>   
   <xsl:apply-templates select="arg[1]/*" mode="explain-xpath">
      <xsl:with-param name="context" select="'node-set'" />
   </xsl:apply-templates>
   <xsl:if test="$context = 'boolean' or $context = 'predicate'"> is non-zero</xsl:if>
</xsl:template>

<xsl:template match="function[@name = 'floor']" mode="explain-xpath">
	<xsl:param name="context" />
   <xsl:if test="$context = 'string'"> the string value of</xsl:if>
   <xsl:apply-templates select="arg[1]/*" mode="explain-xpath">
      <xsl:with-param name="context" select="'number'" />
   </xsl:apply-templates>
   <xsl:text> rounded down to the nearest integer</xsl:text>
   <xsl:if test="$context = 'boolean' or $context = 'predicate'"> is non-zero</xsl:if>
</xsl:template>

<xsl:template match="function[@name = 'ceiling']" mode="explain-xpath">
	<xsl:param name="context" />
   <xsl:if test="$context = 'string'"> the string value of</xsl:if>
   <xsl:apply-templates select="arg[1]/*" mode="explain-xpath">
      <xsl:with-param name="context" select="'number'" />
   </xsl:apply-templates>
   <xsl:text> rounded up to the nearest integer</xsl:text>
   <xsl:if test="$context = 'boolean' or $context = 'predicate'"> is non-zero</xsl:if>
</xsl:template>

<xsl:template match="function[@name = 'round']" mode="explain-xpath">
	<xsl:param name="context" />
   <xsl:if test="$context = 'string'"> the string value of</xsl:if>
   <xsl:apply-templates select="arg[1]/*" mode="explain-xpath">
      <xsl:with-param name="context" select="'number'" />
   </xsl:apply-templates>
   <xsl:text> rounded to the nearest integer</xsl:text>
   <xsl:if test="$context = 'boolean' or $context = 'predicate'"> is non-zero</xsl:if>
</xsl:template>

<xsl:template match="function[@name = 'document']" mode="explain-short-xpath">
   <xsl:param name="context" />
   <xsl:choose>
      <xsl:when test="arg[1]/path">
         <xsl:text> the documents at the URLs specified by</xsl:text>
         <xsl:apply-templates select="arg[1]/*" mode="explain-xpath">
            <xsl:with-param name="context" select="'node-set'" />
         </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="arg[1]/string">
         <xsl:choose>
            <xsl:when test="string(arg[1]/string)">
               <a href="{arg[1]/string}">
                  <xsl:value-of select="arg[1]/string" />
               </a>
            </xsl:when>
            <xsl:otherwise> the stylesheet</xsl:otherwise>
         </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
         <xsl:text> the document at the URL specified as</xsl:text>
         <xsl:apply-templates select="arg[1]/*" mode="explain-xpath">
            <xsl:with-param name="context" select="'string'" />
         </xsl:apply-templates>
      </xsl:otherwise>
   </xsl:choose>
   <xsl:if test="arg[2] and not(arg[1]/string and not(string(arg[1]/string)))">
      <xsl:text> resolved relative to the base URI of</xsl:text>
      <xsl:apply-templates select="arg[2]/*" mode="explain-xpath">
         <xsl:with-param name="context" select="'node'" />
      </xsl:apply-templates>
   </xsl:if>
   <xsl:text>&apos;s root node</xsl:text>
</xsl:template>

<xsl:template match="function[@name = 'document']" mode="explain-xpath">
	<xsl:param name="context" />
   <xsl:choose>
      <xsl:when test="$context = 'string'"> the string value of</xsl:when>
      <xsl:when test="$context = 'number'"> the numerical value of</xsl:when>
   </xsl:choose>
   <xsl:choose>
      <xsl:when test="arg[1]/path">
         <xsl:if test="$context = 'string' or $context = 'number'"> the first of</xsl:if>
         <xsl:text> the root nodes of the documents at the URLs specified by</xsl:text>
         <xsl:apply-templates select="arg[1]/*" mode="explain-xpath">
            <xsl:with-param name="context" select="'node-set'" />
         </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="arg[1]/string">
         <xsl:text> the root node of</xsl:text>
         <xsl:choose>
            <xsl:when test="string(arg[1]/string)">
               <a href="{arg[1]/string}">
                  <xsl:value-of select="arg[1]/string" />
               </a>
            </xsl:when>
            <xsl:otherwise> the stylesheet</xsl:otherwise>
         </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
         <xsl:text> the root node of the document at the URL specified as</xsl:text>
         <xsl:apply-templates select="arg[1]/*" mode="explain-xpath">
            <xsl:with-param name="context" select="'string'" />
         </xsl:apply-templates>
      </xsl:otherwise>
   </xsl:choose>
   <xsl:if test="arg[2] and not(arg[1]/string and not(string(arg[1]/string)))">
      <xsl:text> resolved relative to the base URI of the first node in the node set comprising</xsl:text>
      <xsl:apply-templates select="arg[2]/*" mode="explain-xpath">
         <xsl:with-param name="context" select="'string'" />
      </xsl:apply-templates>
   </xsl:if>
   <xsl:if test="$context = 'boolean' or $context = 'predicate'"> exists (always true)</xsl:if>
</xsl:template>

<xsl:template match="function[@name = 'key']" mode="explain-xpath">
	<xsl:param name="context" />
   <xsl:choose>
      <xsl:when test="$context = 'string'"> the string value of the first node in the node set comprising</xsl:when>
      <xsl:when test="$context = 'number'"> the numerical value of the first node in the node set comprising</xsl:when>
      <xsl:when test="$context = 'boolean' or $context = 'predicate'"> there are nodes in the node set comprising</xsl:when>
   </xsl:choose>
   <xsl:text> the nodes returned from the keyspace</xsl:text>
   <xsl:apply-templates select="arg[1]/*" mode="explain-xpath">
      <xsl:with-param name="context" select="'string'" />
   </xsl:apply-templates>
   <xsl:text> with a key value of</xsl:text>
   <xsl:choose>
      <xsl:when test="arg[2]/path">
         <xsl:text> the string value of any of the nodes in the node set comprising</xsl:text>
         <xsl:apply-templates select="arg[2]/*" mode="explain-xpath">
            <xsl:with-param name="context" select="'node-set'" />
         </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="arg[2]/var">
         <xsl:text> the string value of any of</xsl:text>
         <xsl:apply-templates select="arg[2]/*" mode="explain-xpath">
            <xsl:with-param name="context" select="'node-set'" />
         </xsl:apply-templates>
         <xsl:text>, if it holds a node set, or its string value if not</xsl:text>
      </xsl:when>
      <xsl:otherwise>
         <xsl:apply-templates select="arg[2]/*" mode="explain-xpath">
            <xsl:with-param name="context" select="'string'" />
         </xsl:apply-templates>
      </xsl:otherwise>
   </xsl:choose>
</xsl:template>

<xsl:template match="function[@name = 'format-number']" mode="explain-xpath">
	<xsl:param name="context" />
   <xsl:if test="$context = 'number'"> the numerical value of</xsl:if>
   <xsl:text> the string produced by formatting</xsl:text>
   <xsl:apply-templates select="arg[1]/*" mode="explain-xpath">
      <xsl:with-param name="context" select="'number'" />
   </xsl:apply-templates>
   <xsl:text> according to the pattern</xsl:text>
   <xsl:apply-templates select="arg[2]/*" mode="explain-xpath">
      <xsl:with-param name="context" select="'string'" />
   </xsl:apply-templates>
   <xsl:if test="arg[3]">
      <xsl:text> using the decimal format</xsl:text>
      <xsl:apply-templates select="arg[3]/*" mode="explain-xpath">
         <xsl:with-param name="context" select="'string'" />
      </xsl:apply-templates>
   </xsl:if>
   <xsl:if test="$context = 'boolean' or $context = 'predicate'"> is a non-empty string</xsl:if>
</xsl:template>

<xsl:template match="function[@name = 'current']" mode="explain-xpath">
	<xsl:param name="context" />
   <xsl:choose>
      <xsl:when test="$context = 'number'"> the numerical value of</xsl:when>
      <xsl:when test="$context = 'string'"> the string value of</xsl:when>
   </xsl:choose>
   <xsl:text> the current node</xsl:text>
   <xsl:if test="$context = 'boolean' or $context = 'predicate'"> exists (always true)</xsl:if>
</xsl:template>

<xsl:template match="function[@name = 'unparsed-entity-uri']" mode="explain-xpath">
	<xsl:param name="context" />
   <xsl:if test="$context = 'number'"> the numerical value of</xsl:if>
   <xsl:text> the URI of the unparsed entity named</xsl:text>
   <xsl:apply-templates select="arg[1]/*" mode="explain-xpath">
      <xsl:with-param name="context" select="'string'" />
   </xsl:apply-templates>
   <xsl:if test="$context = 'boolean' or $context = 'predicate'"> is a non-empty string (true if the entity exists)</xsl:if>
</xsl:template>

<xsl:template match="function[@name = 'generate-id']" mode="explain-xpath">
	<xsl:param name="context" />
   <xsl:if test="$context = 'number'"> the numerical value (NaN) of</xsl:if>
   <xsl:text> a unique identifier generated for the first node in the node set comprising</xsl:text>
   <xsl:apply-templates select="arg[1]/*" mode="explain-xpath">
      <xsl:with-param name="context" select="'node-set'" />
   </xsl:apply-templates>
   <xsl:if test="$context = 'boolean' or $context = 'predicate'"> is a non-empty string (always true)</xsl:if>
</xsl:template>

<xsl:template match="function[@name = 'system-property']" mode="explain-xpath">
	<xsl:param name="context" />
   <xsl:if test="$context = 'number'"> the numerical value (NaN) of</xsl:if>
   <xsl:text> the system property of</xsl:text>
   <xsl:apply-templates select="arg[1]/*" mode="explain-xpath">
      <xsl:with-param name="context" select="'node-set'" />
   </xsl:apply-templates>
   <xsl:if test="$context = 'boolean' or $context = 'predicate'"> is a non-empty string</xsl:if>
</xsl:template>

</xsl:stylesheet>