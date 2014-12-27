<?xml version="1.0"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/XSL/TransformAlias"
                xmlns:dt="http://www.jenitennison.com/datatypes"
                xmlns:xs="http://www.w3.org/2001/XMLSchema">

<xsl:output indent="yes" />

<xsl:strip-space elements="*" />
<xsl:preserve-space elements="dt:string" />
                    
<xsl:namespace-alias result-prefix="xsl" stylesheet-prefix="#default"/>

<xsl:variable name="namespaces" select="/dt:datatypes/namespace::*[name(.)]" />

<xsl:function name="dt:namespace" as="xs:string">
  <xsl:param name="name" as="attribute()" />
  <xsl:sequence
    select="if (contains($name, ':'))
            then get-namespace-uri-for-prefix($name/.., substring-before($name, ':'))
            else string($name/ancestor::*[@ns][1]/@ns)" />
</xsl:function>

<xsl:function name="dt:prefix" as="xs:string">
  <xsl:param name="name" as="attribute()" />
  <xsl:sequence select="name($namespaces[. = dt:namespace($name)])" />
</xsl:function>

<xsl:function name="dt:local-name" as="xs:string">
  <xsl:param name="name" as="attribute()" />
  <xsl:sequence select="if (contains($name, ':'))
                        then substring-after($name, ':')
                        else $name" />
</xsl:function>

<xsl:function name="dt:expanded-qname" as="xs:string">
  <xsl:param name="name" as="attribute()" />
  <xsl:sequence select="concat('{', dt:namespace($name), '}', dt:local-name($name))" />
</xsl:function>

<xsl:function name="dt:qname" as="xs:string">
  <xsl:param name="name" as="attribute()" />
  <xsl:variable name="prefix" select="dt:prefix($name)" />
  <xsl:sequence select="concat(dt:prefix($name), ':', dt:local-name($name))" />
</xsl:function>

<xsl:function name="dt:subtypes" as="element()*">
  <xsl:param name="supertype" as="element()" />
  <xsl:variable name="subtypes" select="$supertype/key('subtypes', $supertype/@qname)" as="element()*" />
  <xsl:for-each select="$subtypes">
    <xsl:sequence select="., dt:subtypes(.)" />
  </xsl:for-each>
</xsl:function>

<xsl:key name="casts" match="dt:cast" use="@to" />
<xsl:key name="supertype" match="dt:datatype" use="@qname" />
<xsl:key name="subtypes" match="dt:datatype" use="dt:supertype/@qname" />
                
<xsl:template match="dt:datatypes">
  <xsl:variable name="expanded" as="element()">
    <xsl:apply-templates select="." mode="expand" />
  </xsl:variable>
  <stylesheet version="2.0" exclude-result-prefixes="xs dt">
    <xsl:copy-of select="$namespaces" />
    <xsl:apply-templates select="$expanded/dt:datatype" />
    <xsl:comment>
      <xsl:text>***** Utilities *****</xsl:text>
    </xsl:comment>
    <function name="dt:string" as="xs:string">
      <param name="string" as="item()" />
      <choose>
        <when test="$string instance of element()">
          <choose>
            <xsl:for-each select="dt:datatype">
              <when test="$string[self::{dt:qname(@name)}]">
                <sequence select="{dt:prefix(@name)}:format-{dt:local-name(@name)}($string)" />
              </when>
            </xsl:for-each>
            <otherwise>
              <sequence select="string($string)" />
            </otherwise>
          </choose>
        </when>
        <otherwise>
          <sequence select="xs:string($string)" />
        </otherwise>
      </choose>
    </function>
  </stylesheet>
</xsl:template>
<xsl:include href="datatypes-expand.xsl" />

<xsl:template match="dt:datatype">
  <xsl:text>&#xA;</xsl:text>
  <xsl:text>&#xA;</xsl:text>
  <xsl:comment>
    <xsl:text>***** </xsl:text><xsl:value-of select="@qname" /><xsl:text> *****</xsl:text>
  </xsl:comment>
  <xsl:apply-templates select="." mode="constructor" />
  <xsl:apply-templates select="." mode="parser" />
  <xsl:apply-templates select="." mode="formatter" />
  <xsl:apply-templates select="." mode="validator" />
  <xsl:apply-templates select="." mode="normalizer" />
  <xsl:apply-templates select="." mode="comparer" />
</xsl:template>

<xsl:template match="dt:datatype" mode="constructor">
  <function name="{@qname}" as="element()">
    <param name="{@name}" as="item()" />
    <choose xpath-default-namespace="{@ns}">
      <when test="${@name} instance of xs:string">
        <variable name="parsed"
                  select="{@prefix}:parse-{@name}(${@name})" />
        <choose>
          <when test="$parsed">
            <sequence select="{@prefix}:validated-{@name}($parsed)" />
          </when>
          <otherwise>
            <message terminate="yes">
              <text>Invalid format for <xsl:value-of select="@qname" />: </text>
              <sequence select="${@name}" />
            </message>
          </otherwise>
        </choose>
      </when>
      <when test="${@name} instance of element()">
        <choose>
          <xsl:variable name="dt" select="." />
          <xsl:for-each select="key('casts', @qname)">
            <when test="${$dt/@name}[self::{@from}]">
              <variable name="parsed" as="element()">
                <xsl:element name="{@to}" namespace="{@to-ns}">
                  <xsl:if test="$dt/dt:supertype">
                    <xsl:attribute name="supertypes">
                      <xsl:apply-templates select="$dt" mode="supertypes" />
                    </xsl:attribute>
                  </xsl:if>
                  <for-each select="${$dt/@name}">
                    <xsl:apply-templates select="*" mode="copy" />
                  </for-each>
                </xsl:element>
              </variable>
              <sequence select="{$dt/@prefix}:validated-{$dt/@name}($parsed)" />
            </when>
          </xsl:for-each>
          <when test="tokenize(${@name}/@supertypes, ' ')[if (.) then resolve-QName(., ${@name}) = expanded-QName('{@ns}', '{@name}') else false()]">
            <sequence select="${@name}" />
          </when>
          <xsl:choose>
            <xsl:when test="dt:supertype">
              <when test="${@name}[self::{dt:supertype/@qname}]">
                <variable name="parsed" as="element()">
                  <xsl:element name="{@qname}" namespace="{@ns}">
                    <xsl:attribute name="supertypes">
                      <xsl:apply-templates select="." mode="supertypes" />
                    </xsl:attribute>
                    <xsl:choose>
                      <xsl:when test="dt:supertype/dt:cast">
                        <variable name="converted" as="node()*">
                          <for-each select="${@name}">
                            <xsl:apply-templates select="dt:supertype/dt:cast/node()" mode="copy" />
                          </for-each>
                        </variable>
                        <choose>
                          <when test="$converted">
                            <sequence select="$converted" />
                          </when>
                          <otherwise>
                            <message terminate="yes">
                              <text><xsl:value-of select="dt:supertype/@qname" /> could not be converted to <xsl:value-of select="@qname" />: </text>
                              <sequence select="${@name}" />
                            </message>
                          </otherwise>
                        </choose>
                      </xsl:when>
                      <xsl:otherwise>
                        <sequence select="${@name}/node()" />
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:element>
                </variable>
                <sequence select="{@prefix}:validated-{@name}($parsed)" />
              </when>
              <otherwise>
                <sequence select="{@qname}({dt:supertype/@qname}(${@name}))" />
              </otherwise>
            </xsl:when>
            <xsl:otherwise>
              <otherwise>
                <sequence select="{@qname}(dt:string(${@name}))" />
              </otherwise>
            </xsl:otherwise>
          </xsl:choose>
        </choose>
      </when>
      <otherwise>
        <sequence select="{@qname}(dt:string(${@name}))" />
      </otherwise>
    </choose>
  </function>
</xsl:template>

<xsl:template match="dt:datatype" mode="supertypes" as="xs:string*" />

<xsl:template match="dt:datatype[dt:supertype]" mode="supertypes" as="xs:string*">
  <xsl:sequence select="string(dt:supertype/@qname)" />
  <xsl:apply-templates select="key('supertype', dt:supertype/@qname)" mode="supertypes" />
</xsl:template>

<xsl:template match="dt:datatype" mode="parser">
  <xsl:choose>
    <xsl:when test="dt:parse">
      <xsl:variable name="regex">
        <xsl:apply-templates select="dt:parse" mode="regex" />
      </xsl:variable>
      <function name="{@prefix}:parse-{@name}" as="element()?">
        <param name="string" as="xs:string" />
        <xsl:choose>
          <xsl:when test="not(dt:parse/@whitespace) or dt:parse/@whitespace = 'collapse'">
           <variable name="string" select="normalize-space($string)" />
          </xsl:when>
          <xsl:when test="dt:parse/@whitespace = 'replace'">
            <variable name="string" select="replace($string, '\s', ' ')" />
          </xsl:when>
        </xsl:choose>
        <if test="{@prefix}:matches-{@name}-regex($string)">
          <analyze-string select="$string" regex="{{{@qname}-regex()}}">
            <matching-substring>
              <xsl:apply-templates select="dt:parse" mode="group" />
            </matching-substring>
          </analyze-string>
        </if>
      </function>
      <function name="{@qname}-regex" as="xs:string">
        <text>^<xsl:value-of select="$regex" />$</text>
      </function>
      <function name="{@prefix}:matches-{@name}-regex" as="xs:boolean">
        <param name="string" as="xs:string" />
        <xsl:choose>
          <xsl:when test="dt:supertype">
            <choose>
              <when test="{dt:supertype/@prefix}:matches-{dt:supertype/@name}-regex($string)">
                <sequence select="matches($string, {@qname}-regex())" />
              </when>
              <otherwise>
                <message terminate="yes">
                  <text>Mismatched regular expressions: legal <xsl:value-of select="@qname" /> is illegal <xsl:value-of select="dt:supertype/@qname" />: </text>
                  <value-of select="$string" />
                </message>
              </otherwise>
            </choose>
          </xsl:when>
          <xsl:otherwise>
            <sequence select="matches($string, {@qname}-regex())" />
          </xsl:otherwise>
        </xsl:choose>
      </function>
    </xsl:when>
    <xsl:when test="dt:supertype">
      <function name="{@prefix}:parse-{@name}" as="element()?">
        <param name="string" as="xs:string" />
        <variable name="{dt:supertype/@name}" as="element()?">
          <sequence select="{dt:supertype/@prefix}:parse-{dt:supertype/@name}($string)" />
        </variable>
        <if test="${dt:supertype/@name}">
          <xsl:element name="{@qname}" namespace="{@ns}">
            <xsl:attribute name="supertypes">
              <xsl:value-of select="concat(dt:supertype/@qname, ' {$', dt:supertype/@name, '/@supertypes}')" />
            </xsl:attribute>
            <copy-of select="${dt:supertype/@name}/node()" />
          </xsl:element>
        </if>
      </function>
      <function name="{@qname}-regex" as="xs:string">
        <sequence select="{dt:supertype/@qname}-regex()" />
      </function>
      <function name="{@prefix}:matches-{@name}-regex" as="xs:boolean">
        <param name="string" as="xs:string" />
        <sequence select="{dt:supertype/@prefix}:matches-{dt:supertype/@name}-regex($string)" />
      </function>
    </xsl:when>
    <xsl:otherwise>
      <function name="{@prefix}:parse-{@name}" as="element()?">
        <param name="string" as="xs:string" />
        <xsl:element name="{@qname}" namespace="{@ns}">
          <value-of select="$string" />
        </xsl:element>
      </function>
      <function name="{@qname}-regex" as="xs:string">
        <text>^(.*)$</text>
      </function>
      <function name="{@prefix}:matches-{@name}-regex" as="xs:boolean">
        <param name="string" as="xs:string" />
        <sequence select="true()" />
      </function>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="dt:parse" mode="regex">
  <xsl:apply-templates mode="regex" />
</xsl:template>

<xsl:template match="dt:group" mode="regex">
  <xsl:text>(</xsl:text>
  <xsl:apply-templates mode="#current" />
  <xsl:text>)</xsl:text>
</xsl:template>

<xsl:template match="dt:anyChar" mode="regex">.</xsl:template>
<xsl:template match="dt:newline" mode="regex">\n</xsl:template>
<xsl:template match="dt:return" mode="regex">\r</xsl:template>
<xsl:template match="dt:tab" mode="regex">\t</xsl:template>
<xsl:template match="dt:whitespace" mode="regex">\s</xsl:template>
<xsl:template match="dt:notWhitespace" mode="regex">\S</xsl:template>
<xsl:template match="dt:initialNameChar" mode="regex">\i</xsl:template>
<xsl:template match="dt:notInitialNameChar" mode="regex">\I</xsl:template>
<xsl:template match="dt:nameChar" mode="regex">\c</xsl:template>
<xsl:template match="dt:notNameChar" mode="regex">\C</xsl:template>
<xsl:template match="dt:digit" mode="regex">\d</xsl:template>
<xsl:template match="dt:notDigit" mode="regex">\D</xsl:template>
<xsl:template match="dt:wordChar" mode="regex">\w</xsl:template>
<xsl:template match="dt:notWordChar" mode="regex">\W</xsl:template>

<xsl:template match="dt:string" mode="regex">
  <xsl:value-of select="replace(., '(\\|\||\.|\-|\^|\?|\*|\+|\{|\}|\(|\)|\[|\])', '\\$1')" />
</xsl:template>

<xsl:template match="dt:category" mode="regex">
  <xsl:text>\p{</xsl:text>
  <xsl:value-of select="." />
  <xsl:text>}</xsl:text>
</xsl:template>

<xsl:template match="dt:notCategory" mode="regex">
  <xsl:text>\P{</xsl:text>
  <xsl:value-of select="." />
  <xsl:text>}</xsl:text>
</xsl:template>

<xsl:template match="dt:block" mode="regex">
  <xsl:text>\p{Is</xsl:text>
  <xsl:value-of select="." />
  <xsl:text>}</xsl:text>
</xsl:template>

<xsl:template match="dt:notBlock" mode="regex">
  <xsl:text>\P{Is</xsl:text>
  <xsl:value-of select="." />
  <xsl:text>}</xsl:text>
</xsl:template>

<xsl:template match="dt:charGroup" mode="regex">
  <xsl:text>[</xsl:text>
  <xsl:apply-templates mode="#current" />
  <xsl:text>]</xsl:text>
</xsl:template>

<xsl:template match="dt:notCharGroup" mode="regex">
  <xsl:text>[^</xsl:text>
  <xsl:apply-templates mode="#current" />
  <xsl:text>]</xsl:text>
</xsl:template>

<xsl:template match="dt:range[@from and @to]" mode="regex">
  <xsl:value-of select="@from" />-<xsl:value-of select="@to" />
</xsl:template>

<xsl:template match="dt:range" mode="regex">
  <xsl:apply-templates select="*[1]" mode="regex" />
  <xsl:text>-</xsl:text>
  <xsl:apply-templates select="*[2]" mode="regex" />
</xsl:template>

<xsl:template match="dt:except" mode="regex">
  <xsl:text>-[</xsl:text>
  <xsl:apply-templates mode="#current" />
  <xsl:text>]</xsl:text>
</xsl:template>

<xsl:template match="dt:chars" mode="regex">
  <xsl:value-of select="replace(., '(\\|\[|\])', '\\$1')" />
</xsl:template>

<xsl:template match="dt:choice" mode="regex">
  <xsl:for-each select="*">
    <xsl:apply-templates select="." mode="#current" />
    <xsl:if test="position() != last()">|</xsl:if>
  </xsl:for-each>
</xsl:template>

<xsl:template match="dt:optional" mode="regex">
  <xsl:apply-templates mode="#current" />
  <xsl:text>?</xsl:text>
</xsl:template>

<xsl:template match="dt:oneOrMore" mode="regex">
  <xsl:apply-templates mode="#current" />
  <xsl:text>+</xsl:text>
</xsl:template>

<xsl:template match="dt:zeroOrMore" mode="regex">
  <xsl:apply-templates mode="#current" />
  <xsl:text>*</xsl:text>
</xsl:template>

<xsl:template match="dt:repeat" mode="regex">
  <xsl:apply-templates mode="#current" />
  <xsl:text>{</xsl:text>
  <xsl:value-of select="if (@exactly) then @exactly else concat(@min, ',', @max)" />
  <xsl:text>}</xsl:text>
</xsl:template>

<xsl:template match="dt:choice" mode="group">
  <choose>
    <xsl:apply-templates mode="group" />
  </choose>
</xsl:template>

<xsl:template match="dt:choice/dt:group" mode="group" priority="4">
  <xsl:variable name="pos" select="count(ancestor::dt:parse//dt:group[. &lt;&lt; current()]) + 1" />
  <when test="regex-group({$pos}) != ''">
    <xsl:next-match />
  </when>
</xsl:template>

<xsl:template match="dt:optional/dt:group" mode="group" priority="4">
  <xsl:variable name="pos" select="count(ancestor::dt:parse//dt:group[. &lt;&lt; current()]) + 1" />
  <if test="regex-group({$pos}) != ''">
    <xsl:next-match />
  </if>
</xsl:template>

<xsl:template match="dt:group[@ignore]" mode="group" priority="3" />

<xsl:template match="dt:group[@ref]" mode="group" priority="2">
  <xsl:variable name="pos" select="count(ancestor::dt:parse//dt:group[. &lt;&lt; current()]) + 1" />
  <sequence select="{@prefix}:parse-{@name}(regex-group({$pos}))" />
</xsl:template>

<xsl:template match="dt:group[@name]" mode="group">
  <xsl:element name="{@qname}" namespace="{@ns}">
    <xsl:if test="parent::dt:parse/parent::dt:datatype/dt:supertype">
      <xsl:attribute name="supertypes">
        <xsl:apply-templates select="parent::dt:parse/parent::dt:datatype/dt:supertype" mode="supertypes" />
      </xsl:attribute>
    </xsl:if>
    <xsl:next-match />
  </xsl:element>
</xsl:template>

<xsl:template match="dt:group" mode="group">
  <xsl:choose>
    <xsl:when test=".//dt:group[@name or @ignore] or .//dt:choice">
      <xsl:apply-templates mode="group" />
    </xsl:when>
    <xsl:otherwise>
      <value-of select="regex-group({count(ancestor::dt:parse//dt:group[. &lt;&lt; current()]) + 1})" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="dt:*" mode="group">
  <xsl:apply-templates mode="group" />
</xsl:template>

<xsl:template match="dt:datatype" mode="formatter">
  <function name="{@prefix}:format-{@name}" as="xs:string">
    <param name="{@name}" as="element()" />
    <sequence select="string({@prefix}:normalize-{@name}(${@name}))" />
  </function>
</xsl:template>

<xsl:template match="dt:datatype" mode="validator">
  <function name="{@prefix}:validated-{@name}" as="element()">
    <param name="{@name}" as="element()" />
    <variable name="errors" as="xs:string*"
              select="{@prefix}:validate-{@name}(${@name})" />
    <choose>
      <when test="$errors">
        <message terminate="yes">
          <text>Invalid <xsl:value-of select="@qname" />: </text>
          <value-of select="distinct-values($errors)" separator="; " />
          <text><xsl:text>&#xA;</xsl:text></text>
          <sequence select="${@name}" />
        </message>
      </when>
      <otherwise>
        <sequence select="${@name}" />
      </otherwise>
    </choose>
  </function>
  <function name="{@prefix}:validate-{@name}" as="xs:string*">
    <param name="{@name}" as="element()" />
    <xsl:if test="dt:supertype">
      <sequence select="{dt:supertype/@prefix}:validate-{dt:supertype/@name}(${@name})" />
      <xsl:apply-templates select="dt:supertype/dt:params" mode="tests" />
    </xsl:if>
    <xsl:if test="dt:parse or dt:validate">
      <for-each select="${@name}">
        <xsl:apply-templates select="dt:parse" mode="tests" />
        <xsl:apply-templates select="dt:validate" mode="tests" />
      </for-each>
    </xsl:if>
  </function>
</xsl:template>

<xsl:template match="dt:params" mode="tests">
  <for-each select="${ancestor::dt:datatype/@name}" xpath-default-namespace="{ancestor::dt:datatype/@ns}">
    <xsl:apply-templates select="dt:param" mode="tests" />
  </for-each>
</xsl:template>

<xsl:template match="dt:param" mode="tests">
  <xsl:apply-templates select="key('supertype', ancestor::dt:supertype/@qname)" mode="test-param">
    <xsl:with-param name="param" select="string(@name)" />
    <xsl:with-param name="value" select="string(.)" />
    <xsl:with-param name="type" select="string(ancestor::dt:supertype/@qname)" />
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="dt:datatype" mode="test-param">
  <xsl:param name="param" as="xs:string" required="yes" />
  <xsl:param name="value" as="xs:string" required="yes" />
  <xsl:param name="type" as="xs:string" required="yes" />
  <xsl:choose>
    <xsl:when test="dt:params/dt:param[@name = $param]">
      <xsl:variable name="param" select="dt:params/dt:param[@name = $param]" />
      <xsl:choose>
        <xsl:when test="$param/@test and $param/@select">
          <xsl:variable name="op"
                        select="if ($param/@test = 'eq') then '='
                                else if ($param/@test = 'ne') then '!='
                                else if ($param/@test = 'lt') then '&lt;'
                                else if ($param/@test = 'le') then '&lt;='
                                else if ($param/@test = 'gt') then '>'
                                else '>='" />
          <if test="not({if ($param/@as = 'number') then
                           concat('(if (', $param/@select, ') then ', $param/@select, ' else 0) ', $op, ' ', $value)
                         else
                           concat($param/@select, ' ', $op, ' ''', translate($value, '''', ''''''), '''')})">
            <text>Failed to satisfy <xsl:value-of select="$param/@name" /> parameter (<xsl:value-of select="$value" />)</text>
          </if>
        </xsl:when>
        <xsl:when test="$param/@select">
          <if test="not({$param/@select}) = {$value}()">
            <text>Failed to satisfy <xsl:value-of select="$param/@name" /> parameter (<xsl:value-of select="$value" />)</text>
          </if>
        </xsl:when>
        <xsl:otherwise>
          <if test="not({@prefix}:compare-{@name}s(., {$type}('{replace($value, '''', '''''')}')) {$param/@test} 0)">
            <text>Failed to satisfy <xsl:value-of select="$param/@name" /> parameter (<xsl:value-of select="$value" />)</text>
          </if>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:when test="dt:supertype">
      <xsl:apply-templates select="key('supertype', dt:supertype/@qname)" mode="test-param">
        <xsl:with-param name="param" select="$param" />
        <xsl:with-param name="value" select="$value" />
        <xsl:with-param name="type" select="$type" />
      </xsl:apply-templates>
    </xsl:when>
    <xsl:otherwise>
      <xsl:message terminate="yes">No param called <xsl:value-of select="$param" /> for <xsl:value-of select="$type" /></xsl:message>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="dt:*" mode="tests">
  <xsl:param name="path" as="xs:string" />
  <xsl:apply-templates mode="tests">
    <xsl:with-param name="path" select="$path" />
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="dt:group[@name]//dt:group[@name]" mode="tests">
  <xsl:param name="path" as="xs:string" />
  <xsl:apply-templates mode="tests">
    <xsl:with-param name="path"
      select="if ($path) then concat($path, '/', dt:qname(@name)) else dt:qname(@name)" />
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="dt:group[@ref]" mode="tests" priority="2">
  <xsl:param name="path" as="xs:string" />
  <xsl:variable name="path" select="if ($path) then concat($path, '/', @qname) else @qname" />
  <if test="{$path}">
    <sequence select="{@prefix}:validate-{@name}({$path})" />
  </if>
</xsl:template>

<xsl:template match="dt:validate[@as]" mode="tests">
  <sequence select="{dt:prefix(@as)}:validate-{dt:local-name(@as)}({dt:qname(@as)}(${../@name}))" />
</xsl:template>

<xsl:template match="dt:validate" mode="tests">
  <variable name="error" as="xs:string*">
    <choose xpath-default-namespace="{../@ns}">
      <xsl:apply-templates mode="tests" />
    </choose>
  </variable>
  <sequence select="if ($error) then string-join($error, '') else ()" />
</xsl:template>

<xsl:template match="dt:assert" mode="tests">
  <when test="not({normalize-space(@test)})">
    <xsl:apply-templates mode="copy" />
  </when>
</xsl:template>

<xsl:template match="dt:report" mode="tests">
  <when test="{normalize-space(@test)}">
    <xsl:apply-templates mode="copy" />
  </when>
</xsl:template>

<xsl:template match="dt:datatype" mode="normalizer">
  <function name="{@prefix}:normalize-{@name}" as="element()">
    <param name="{@name}" as="element()" />
    <xsl:choose>
      <xsl:when test="dt:normalize">
        <xsl:element name="{@qname}" namespace="{@ns}">
          <copy-of select="${@name}/dt:supertype" />
          <xsl:apply-templates select="dt:normalize" mode="normalize" />
        </xsl:element>
      </xsl:when>
      <xsl:when test="dt:supertype">
        <variable name="{dt:supertype/@name}" as="element()">
          <sequence select="{dt:supertype/@prefix}:normalize-{dt:supertype/@name}(${@name})" />
        </variable>
        <xsl:element name="{@qname}" namespace="{@ns}">
          <xsl:attribute name="supertypes">
            <xsl:value-of select="concat(dt:supertype/@qname, ' {$', dt:supertype/@name, '/@supertypes}')" />
          </xsl:attribute>
          <sequence select="${dt:supertype/@name}/node()" />
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <sequence select="${@name}" />
      </xsl:otherwise>
    </xsl:choose>
  </function>
</xsl:template>

<xsl:template match="dt:normalize" mode="normalize">
  <for-each select="${../@name}"
            xpath-default-namespace="{../@ns}">
    <xsl:apply-templates mode="copy" />
  </for-each>
</xsl:template>

<xsl:template match="dt:normalize[@as]" mode="normalize">
  <sequence select="{../@qame}({dt:prefix(@as)}:normalize-{dt:local-name(@as)}({dt:qname(@as)}(${../@name})))" />
</xsl:template>

<xsl:template match="dt:datatype" mode="comparer">
  <function name="{@prefix}:compare-{@name}s" as="xs:integer">
    <param name="{@name}1" as="element()" />
    <param name="{@name}2" as="element()" />
    <variable name="{@name}1" select="{@prefix}:normalize-{@name}(${@name}1)" />
    <variable name="{@name}2" select="{@prefix}:normalize-{@name}(${@name}2)" />
    <variable name="result" as="xs:integer?">
      <xsl:choose>
        <xsl:when test="dt:compare">
          <xsl:apply-templates select="dt:compare" mode="compare" />
        </xsl:when>
        <xsl:when test="dt:supertype">
          <sequence select="{dt:supertype/@prefix}:compare-{dt:supertype/@name}s(${@name}1, ${@name}2)" />
        </xsl:when>
        <xsl:otherwise>
          <sequence select="compare(dt:string(${@name}1), dt:string(${@name}2))" />
        </xsl:otherwise>
      </xsl:choose>
    </variable>
    <choose>
      <when test="$result instance of xs:integer">
        <sequence select="$result" />
      </when>
      <otherwise>
        <message terminate="yes">
          <text>Incomparable <xsl:value-of select="@qname" />s: </text>
          <sequence select="${@name}1" />
          <text> and </text>
          <sequence select="${@name}2" />
        </message>
      </otherwise>
    </choose>
  </function>
</xsl:template>

<xsl:template match="dt:compare" mode="compare">
  <choose xpath-default-namespace="{../@ns}">
    <xsl:apply-templates mode="compare" />
    <otherwise>0</otherwise>
  </choose>
</xsl:template>

<xsl:template match="dt:compare[@as]" mode="compare">
  <xsl:choose>
    <xsl:when test="@as = 'number'">
      <sequence select="if (number(${../@name}1) > number(${../@name}2)) then 1
                        else if (number(${../@name}1) &lt; number(${../@name}2)) then -1
                        else 0" />
    </xsl:when>
    <xsl:when test="@as = 'string'">
      <sequence select="compare(${../@name}1, ${../@name}2)" />
    </xsl:when>
    <xsl:otherwise>
      <sequence select="{dt:prefix(@as)}:compare-{dt:local-name(@as)}s({dt:qname(@as)}(${../@name}1), {dt:qname(@as)}(${../@name}2))" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="dt:compare/dt:compare" mode="compare" priority="2">
  <xsl:variable name="name" select="../../@name" />
  <xsl:variable name="name1" select="concat('$', $name, '1/', @path)" />
  <xsl:variable name="name2" select="concat('$', $name, '2/', @path)" />
  <when test="({$name1} or {$name2}) and not({$name1} and {$name2})" />
  <xsl:choose>
    <xsl:when test="@as = 'number'">
      <when test="number({$name1}) != number({$name2})">
        <sequence select="if (number({$name1}) > number({$name2})) then 1 else -1" />
      </when>
    </xsl:when>
    <xsl:otherwise>
      <when test="{$name1} != {$name2}">
        <sequence select="compare({$name1}, {$name2})" />
      </when>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="dt:*" mode="copy">
  <xsl:element name="xsl:{local-name()}">
    <xsl:apply-templates select="@*|node()" mode="copy" />
  </xsl:element>
</xsl:template>

<xsl:template match="node()|@*" mode="copy">
  <xsl:copy copy-namespaces="no">
    <xsl:apply-templates select="@*|node()" mode="copy" />
  </xsl:copy>
</xsl:template>

<xsl:template match="node()" mode="#all" priority="-10" />

</xsl:stylesheet>