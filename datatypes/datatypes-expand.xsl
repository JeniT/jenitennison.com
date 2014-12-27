<?xml version="1.0"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.jenitennison.com/datatypes"
                xmlns:dt="http://www.jenitennison.com/datatypes"
                xmlns:xs="http://www.w3.org/2001/XMLSchema">

<xsl:key name="datatypes" match="dt:datatype" use="dt:expanded-qname(@name)" />
<xsl:key name="patterns" match="dt:define" use="dt:expanded-qname(@name)" />

<xsl:template match="dt:define" mode="expand" />

<xsl:template match="dt:cast" mode="expand">
  <cast from="{dt:qname(@from)}" from-ns="{dt:namespace(@from)}"
        to="{dt:qname(@to)}" to-ns="{dt:namespace(@to)}">
    <xsl:copy-of select="node()" />
  </cast>
</xsl:template>

<xsl:template match="dt:datatype" mode="expand">
  <datatype name="{dt:local-name(@name)}" prefix="{dt:prefix(@name)}" ns="{dt:namespace(@name)}" qname="{dt:qname(@name)}">
    <xsl:apply-templates select="dt:supertype" mode="expand" />
    <xsl:if test="dt:parse">
      <parse>
        <xsl:copy-of select="dt:parse/@*" />
        <xsl:variable name="parse" as="element()">
          <group name="{dt:local-name(@name)}"
                 prefix="{dt:prefix(@name)}"
                 ns="{dt:namespace(@name)}"
                 qname="{dt:qname(@name)}">
            <xsl:apply-templates select="dt:parse" mode="expand" />
          </group>
        </xsl:variable>
        <xsl:apply-templates select="$parse" mode="simplify" />
      </parse>
    </xsl:if>
    <xsl:copy-of select="dt:params | dt:validate | dt:normalize | dt:compare" />
  </datatype>
</xsl:template>

<xsl:template match="dt:supertype" mode="expand">
  <supertype name="{dt:local-name(@name)}" prefix="{dt:prefix(@name)}" ns="{dt:namespace(@name)}" qname="{dt:qname(@name)}">
    <xsl:copy-of select="node()" />
  </supertype>
</xsl:template>

<xsl:template match="dt:parse" mode="expand">
  <xsl:apply-templates mode="expand" />
</xsl:template>

<xsl:template match="dt:ref" mode="expand">
  <xsl:apply-templates select="key('patterns', dt:expanded-qname(@name))/node()" mode="expand" />
</xsl:template>

<xsl:template match="dt:data" mode="expand">
  <group name="{dt:local-name(@type)}"
         prefix="{dt:prefix(@type)}"
         ns="{dt:namespace(@type)}"
         qname="{dt:qname(@type)}"
         ref="yes">
    <xsl:apply-templates select="key('datatypes', dt:expanded-qname(@type))" mode="expand-parse" />
  </group>
</xsl:template>

<xsl:template match="dt:datatype[dt:parse]" mode="expand-parse">
  <xsl:apply-templates select="dt:parse" mode="expand" />
</xsl:template>

<xsl:template match="dt:datatype[dt:supertype]" mode="expand-parse">
  <xsl:apply-templates select="key('datatypes', dt:expanded-qname(dt:supertype/@name))" mode="expand-parse" />
</xsl:template>

<xsl:template match="dt:datatype" mode="expand-parse">
  <zeroOrMore>
    <anyChar />
  </zeroOrMore>
</xsl:template>

<xsl:template match="dt:string | dt:charGroup | dt:notCharGroup" mode="expand">
  <group>
    <xsl:copy-of select="@ignore" />
    <xsl:copy-of select="." />
  </group>
</xsl:template>

<xsl:template match="dt:optional | dt:oneOrMore | dt:zeroOrMore | dt:repeat" mode="expand">
  <group>
    <xsl:copy-of select="@ignore" />
    <xsl:copy>
      <xsl:copy-of select="@*" />
      <group>
        <xsl:apply-templates mode="expand" />
      </group>
    </xsl:copy>
  </group>
</xsl:template>

<xsl:template match="dt:choice" mode="expand">
  <group>
    <xsl:copy-of select="@ignore" />
    <xsl:copy>
      <xsl:copy-of select="@*" />
      <xsl:apply-templates mode="expand" />
    </xsl:copy>
  </group>
</xsl:template>

<xsl:template match="dt:group[@name]" mode="expand">
  <group name="{dt:local-name(@name)}"
         prefix="{dt:prefix(@name)}"
         ns="{dt:namespace(@name)}"
         qname="{dt:qname(@name)}">
    <xsl:copy-of select="@*[local-name() != 'name']" />
    <xsl:apply-templates mode="expand" />
  </group>
</xsl:template>

<xsl:template match="dt:* | text()" mode="expand simplify">
  <xsl:copy>
    <xsl:copy-of select="@*" />
    <xsl:apply-templates mode="#current" />
  </xsl:copy>
</xsl:template>

<xsl:template match="dt:group[@name or @ignore][count(*) = 1 and dt:group[not(@name or @ignore)]]" mode="simplify" priority="4">
  <group>
    <xsl:copy-of select="@*" />
    <xsl:apply-templates select="dt:group/node()" mode="simplify" />
  </group>
</xsl:template>

<xsl:template match="dt:group[@name or @ignore]" mode="simplify" priority="3">
  <group>
    <xsl:copy-of select="@*" />
    <xsl:apply-templates mode="simplify" />
  </group>
</xsl:template>

<xsl:template match="dt:group[count(*) = 1 and dt:group]" mode="simplify" priority="2">
  <xsl:apply-templates mode="simplify" />
</xsl:template>

</xsl:stylesheet>