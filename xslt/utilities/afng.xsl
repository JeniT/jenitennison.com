<?xml version="1.0" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:afng="x-whatever:somethingorother"
                version="1.0"
                exclude-result-prefixes="afng">

<xsl:param name="af-filename" select="'afng.xml'" />
<xsl:param name="af" select="document($af-filename)" />

<xsl:template match="/">
  <xsl:apply-templates select="*" mode="afng:match" />
</xsl:template>

<!-- the $form-att-ns is taken from the arch-ns attribute on the archform
     document element; this is the same as the default namespace for the
     resulting document -->
<xsl:variable name="form-att-name" select="string($af/afng:archmap/@form-att)" />
<xsl:variable name="form-att-ns" select="string($af/afng:archmap/@arch-ns)" />

<xsl:key name="form-by-name" match="afng:form" use="@name" />
<xsl:key name="form-by-elem" match="afng:form" 
         use="concat('{', ancestor-or-self::*/@source-ns[last()], '}', @source-elem)" />

<xsl:template match="text()" mode="afng:match">
  <xsl:value-of select="." />
</xsl:template>

<xsl:template match="*" mode="afng:match">
  <xsl:param name="data-mode" select="'preserve'" />
  <xsl:param name="children-mode" select="'process'" />
  <xsl:variable name="form-att" 
                select="@*[local-name() = $form-att-name and 
                           namespace-uri() = $form-att-ns]" />
  <xsl:variable name="source-elem" select="." />
  <xsl:for-each select="$af">
    <xsl:choose>
      <xsl:when test="$form-att">
        <xsl:variable name="form" select="key('form-by-name', $form-att)" />
        <xsl:choose>
          <xsl:when test="$form">
            <xsl:apply-templates select="$source-elem" mode="afng:process">
              <xsl:with-param name="data-mode" select="$data-mode" />
              <xsl:with-param name="children-mode" select="$children-mode" />
              <xsl:with-param name="form" select="$form" />
            </xsl:apply-templates>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="$source-elem" mode="afng:process">
              <xsl:with-param name="data-mode" select="$data-mode" />
              <xsl:with-param name="children-mode" select="$children-mode" />
              <xsl:with-param name="form-att" select="$form-att" />
            </xsl:apply-templates>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="form" 
          select="key('form-by-elem', 
                      concat('{', namespace-uri($source-elem), '}', 
                             local-name($source-elem)))" />
        <xsl:apply-templates select="$source-elem" mode="afng:process">
          <xsl:with-param name="data-mode" select="$data-mode" />
          <xsl:with-param name="children-mode" select="$children-mode" />
          <xsl:with-param name="form" select="$form" />
        </xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:for-each>
</xsl:template>

<xsl:template match="*" mode="afng:process">
  <xsl:param name="data-mode" select="'preserve'" />
  <xsl:param name="children-mode" select="'process'" />
  <xsl:param name="form" select="/.." />
  <xsl:param name="form-att" select="/.." />
  <xsl:choose>
    <!-- when a matching form has been found... -->
    <xsl:when test="$form">
      <xsl:choose>
        <!-- when the matching form has an arch-elem attribute... -->
        <xsl:when test="$form/@arch-elem">
          <xsl:choose>
            <!-- when the arch-elem attribute has the value #NONE... -->
            <xsl:when test="$form/@arch-elem = '#NONE'">
              <!-- process the content -->
              <xsl:apply-templates select="." mode="afng:process-content">
                <xsl:with-param name="data-mode" select="$data-mode" />
                <xsl:with-param name="children-mode" select="$children-mode" />
                <xsl:with-param name="form" select="$form" />
              </xsl:apply-templates>
            </xsl:when>
            <!-- when the arch-elem attribute is something other than #NONE -->
            <xsl:otherwise>
              <!-- create an element based on the arch-elem attribute -->
              <xsl:element name="{$form/@arch-elem}" 
                           namespace="{$form/ancestor-or-self::*/@arch-ns[last()]}">
                <xsl:apply-templates select="." mode="afng:process-atts">
                  <xsl:with-param name="form" select="$form" />
                </xsl:apply-templates>
                <xsl:apply-templates select="." mode="afng:process-content">
                  <xsl:with-param name="data-mode" select="$data-mode" />
                  <xsl:with-param name="children-mode" select="$children-mode" />
                  <xsl:with-param name="form" select="$form" />
                </xsl:apply-templates>
              </xsl:element>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <!-- when the matching form doesn't have an arch-elem attribute -->
        <xsl:otherwise>
          <!-- create an element based on the name attribute -->
          <xsl:element name="{$form/@name}"
                       namespace="{$form/ancestor-or-self::*/@arch-ns[last()]}">
            <xsl:apply-templates select="." mode="afng:process-atts">
              <xsl:with-param name="form" select="$form" />
            </xsl:apply-templates>
            <xsl:apply-templates select="." mode="afng:process-content">
              <xsl:with-param name="data-mode" select="$data-mode" />
              <xsl:with-param name="children-mode" select="$children-mode" />
              <xsl:with-param name="form" select="$form" />
            </xsl:apply-templates>
          </xsl:element>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <!-- when there's no matching form element -->
    <xsl:otherwise>
      <xsl:choose>
        <!-- when the element is not the document element -->
        <xsl:when test="parent::*">
          <xsl:choose>
            <!-- when the element has a form attribute -->
            <xsl:when test="$form-att">
              <xsl:element name="{$form-att}"
                           namespace="{$form-att-ns}">
                <xsl:apply-templates select="." mode="afng:process-atts" />
                <xsl:apply-templates select="." mode="afng:process-content">
                  <xsl:with-param name="data-mode" select="$data-mode" />
                  <xsl:with-param name="children-mode" select="$children-mode" />
                </xsl:apply-templates>
              </xsl:element>
            </xsl:when>
            <!-- when the output is 'decorate' -->
            <xsl:when test="$af/afng:archmap/@output = 'decorate'">
              <xsl:copy>
                <xsl:apply-templates select="." mode="afng:process-atts" />
                <xsl:apply-templates select="." mode="afng:process-content">
                  <xsl:with-param name="data-mode" select="$data-mode" />
                  <xsl:with-param name="children-mode" select="$children-mode" />
                </xsl:apply-templates>
              </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="." mode="afng:process-content">
                <xsl:with-param name="data-mode" select="$data-mode" />
                <xsl:with-param name="children-mode" select="$children-mode" />
              </xsl:apply-templates>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <!-- when the element is the document element -->
        <xsl:otherwise>
          <xsl:choose>
            <!-- when there's a doc-elem attribute on the archmap -->
            <xsl:when test="$af/afng:archmap/@doc-elem">
              <xsl:element name="{$af/afng:archmap/@doc-elem}"
                           namespace="{$af/afng:archmap/@arch-ns}">
                <xsl:apply-templates select="." mode="afng:process-atts" />
                <xsl:apply-templates select="." mode="afng:process-content">
                  <xsl:with-param name="data-mode" select="$data-mode" />
                  <xsl:with-param name="children-mode" select="$children-mode" />
                </xsl:apply-templates>
              </xsl:element>
            </xsl:when>
            <!-- when there's not a doc-elem attribute on the archmap -->
            <xsl:otherwise>
              <xsl:element name="{$form-att-name}"
                           namespace="{$form-att-ns}">
                <xsl:apply-templates select="." mode="afng:process-atts" />
                <xsl:apply-templates select="." mode="afng:process-content">
                  <xsl:with-param name="data-mode" select="$data-mode" />
                  <xsl:with-param name="children-mode" select="$children-mode" />
                </xsl:apply-templates>
              </xsl:element>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="*" mode="afng:process-atts">
  <xsl:param name="form" select="/.." />
  <xsl:for-each select="@*">
    <xsl:variable name="att-name" select="local-name()" />
    <xsl:variable name="att-ns" select="namespace-uri()" />
    <xsl:if test="not($att-name = $form-att-name and
                      $att-ns = $form-att-ns) and
                  not($form/afng:attmap[@source = $att-name and
                                        ancestor-or-self::*/@arch-ns[last()] = $att-ns])">
      <xsl:copy-of select="." />
    </xsl:if>
  </xsl:for-each>
  <xsl:apply-templates select="$form/afng:attmap" mode="afng:attributes">
    <xsl:with-param name="source-elem" select="." />
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="*" mode="afng:process-content">
  <xsl:param name="data-mode" select="'preserve'" />
  <xsl:param name="children-mode" select="'process'" />
  <xsl:param name="form" select="/.." />
  <xsl:if test="not($form/afng:attmap/@source = '#CONTENT')">
    <xsl:variable name="new-data-mode">
      <xsl:value-of select="$form/@data" />
      <xsl:if test="not($form/@data)">
        <xsl:value-of select="$data-mode" />
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="new-children-mode">
      <xsl:value-of select="$form/@children" />
      <xsl:if test="not($form/@children)">
        <xsl:value-of select="$children-mode" />
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="content" 
                  select="(text()[$new-data-mode = 'preserve'] | 
                           *[$new-children-mode != 'skip'])" />
    <xsl:choose>
      <xsl:when test="$new-children-mode = 'process'">
        <xsl:apply-templates select="$content" mode="afng:match">
          <xsl:with-param name="data-mode" select="$new-data-mode" />
          <xsl:with-param name="children-mode" select="$new-children-mode" />
        </xsl:apply-templates>  
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="$content" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:if>
</xsl:template>

<xsl:template match="afng:attmap" mode="afng:process-attributes">
  <xsl:param name="source-elem" select="/.." />
  <xsl:attribute name="{@arch-att}" 
                 namespace="{ancestor-or-self::*/@arch-ns[last()]}">
    <xsl:choose>
      <xsl:when test="@source">
        <xsl:choose>
          <xsl:when test="@source = '#CONTENT'">
            <!-- using the string value of the element as the "character data
                 of the element" -->
            <xsl:apply-templates select="." mode="afng:value">
              <xsl:with-param name="value" select="$source-elem" />
            </xsl:apply-templates>
          </xsl:when>
          <xsl:otherwise>
            <xsl:variable name="att-name" select="@source" />
            <xsl:variable name="att-ns"
                          select="ancestor-or-self::*/@arch-ns[last()]" />
            <xsl:apply-templates select="." mode="afng:value">
              <xsl:with-param name="value" 
                 select="$source-elem/@*[local-name() = $att-name and
                                         namespace-uri() = $att-ns]" />
            </xsl:apply-templates>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="@value" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:attribute>
</xsl:template>

<xsl:template match="afng:attmap" mode="afng:value">
  <xsl:param name="value" />
  <xsl:choose>
    <xsl:when test="afng:tokenmap and normalize-space($value)">
      <xsl:apply-templates select="." mode="afng:map-tokens">
        <xsl:with-param name="value" select="normalize-space($value)" />
      </xsl:apply-templates>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$value" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="afng:attmap" mode="afng:map-tokens">
  <xsl:param name="value" />
  <xsl:choose>
    <xsl:when test="contains($value, ' ')">
      <xsl:apply-templates select="." mode="afng:map-token">
        <xsl:with-param name="value" select="substring-before($value, ' ')" />      
      </xsl:apply-templates>
      <xsl:text> </xsl:text>
      <xsl:apply-templates select="." mode="afng:map-tokens">
        <xsl:with-param name="value" select="substring-after($value, ' ')" />
      </xsl:apply-templates>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates select="." mode="afng:map-token">
        <xsl:with-param name="value" select="$value" />      
      </xsl:apply-templates>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="afng:attmap" mode="afng:map-token">
  <xsl:param name="value" />
  <xsl:variable name="tokenmap" select="afng:tokenmap[@from = $value]" />
  <xsl:choose>
    <xsl:when test="$tokenmap">
      <xsl:value-of select="$tokenmap/@to" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$value" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

</xsl:stylesheet>
