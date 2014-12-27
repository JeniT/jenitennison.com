<?xml version="1.0"?>
<!--
    selectParameters.xsl - an XSLT stylesheet to give dynamic parameter-based 
                           transformation
    Copyright (C) 2000,2002  Dr Jeni Tennison

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
    
    Dr Jeni Tennison - http://www.jenitennison.com - jeni@jenitennison.com
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:doc="http://www.jenitennison.com/xslt/doc"
                extension-element-prefixes="doc">

<xsl:param name="selectParameters-xsl-file">
  <xsl:variable name="pi" select="//processing-instruction()[name() = 'xml-stylesheet']" />
  <xsl:variable name="after" select="substring-after($pi, ' href=')" />
  <xsl:variable name="quote" select="substring($after, 1, 1)" />
  <xsl:value-of select="substring-before(substring-after($after, $quote), $quote)" />
</xsl:param>

<xsl:param name="selectParameters-xml-file" select="/*/@base" />

<xsl:variable name="params" select="document($selectParameters-xsl-file, /)/*/xsl:param" />

<xsl:variable name="param-separator" select="'---uniqueParamSeparator---'" />

<xsl:param name="stylesheetParams">
  <xsl:for-each select="$params">
    <xsl:value-of select="@name" />=<xsl:value-of select="substring(@select, 2, string-length(@select) - 2)" /><xsl:value-of select="$param-separator" /><xsl:text />
  </xsl:for-each>
</xsl:param>

<xsl:key name="param-doc" match="/*/doc:param" use="@name" />

<xsl:template name="insert-selectParameters-form">
  <xsl:param name="xml-file" select="$selectParameters-xml-file" />
  <xsl:param name="xsl-file" select="$selectParameters-xsl-file" />
  <xsl:param name="choose-xml-file" select="false()" />
  <xsl:param name="choose-xsl-file" select="false()" />
  <xsl:param name="lang" select="'en'" />

  <xsl:variable name="escaped-xml-file">
    <xsl:call-template name="escape">
      <xsl:with-param name="string" select="$xml-file" />
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="escaped-xsl-file">
    <xsl:call-template name="escape">
      <xsl:with-param name="string" select="$xsl-file" />
    </xsl:call-template>
  </xsl:variable>

  <script type="text/javascript">
    function explainParseError(error) {
      return error.reason + '[' + error.url + ': line ' + error.line + ', col ' + error.linepos + ']';
    }
  
    function formLoadXML() {

      // XMLDOM = new ActiveXObject('Msxml2.FreeThreadedDOMDocument');
      XMLDOM = new ActiveXObject('Msxml2.DOMDocument');
      XMLDOM.async = false;
      
      <xsl:choose>
        <xsl:when test="$choose-xml-file">
          XMLfile = stylesheetParams.all('selectParameters-xml-file').value;
        </xsl:when>
        <xsl:otherwise>
          XMLfile = '<xsl:value-of select="$escaped-xml-file" />';
        </xsl:otherwise>
      </xsl:choose>
      if (XMLfile == '') {
        XMLfile = document.URL;
      }
      XMLDOM.load(XMLfile);

      if (XMLDOM.parseError.errorCode != 0) {
        alert('Error parsing XML file:\n' + explainParseError(XMLDOM.parseError));
        return;
      }

      XSLTDOM = new ActiveXObject('Msxml2.FreeThreadedDOMDocument');
      XSLTDOM.async = false;
      
      <xsl:choose>
        <xsl:when test="$choose-xsl-file">
          XSLfile = stylesheetParams.all('selectParameters-xsl-file').value;
        </xsl:when>
        <xsl:otherwise>
          XSLfile = '<xsl:value-of select="$escaped-xsl-file" />';
        </xsl:otherwise>
      </xsl:choose>
      
      if (XSLfile == '') {
        XSLfile = '<xsl:value-of select="$escaped-xsl-file" />';
      }
      XSLTDOM.load(XSLfile);

      if (XSLTDOM.parseError.errorCode != 0) {
        alert('Error parsing stylesheet:\n' + explainParseError(XSLTDOM.parseError));
        return;
      }

      XSLStylesheet = new ActiveXObject('Msxml2.XSLTemplate');
      XSLStylesheet.stylesheet = XSLTDOM;
      XSLTProcessor = XSLStylesheet.createProcessor();

      XSLTProcessor.input = XMLDOM;
      stylesheetParamString = '';
      <xsl:for-each select="$params">
        XSLTProcessor.addParameter('<xsl:value-of select="@name" />', stylesheetParams.all('<xsl:value-of select="@name" />').value);
        stylesheetParamString = stylesheetParamString + '<xsl:value-of select="@name" />=' + stylesheetParams.all('<xsl:value-of select="@name" />').value + '<xsl:value-of select="$param-separator" />';
      </xsl:for-each>
    
      XSLTProcessor.addParameter('selectParameters-xml-file', XMLfile);
      XSLTProcessor.addParameter('selectParameters-xsl-file', XSLfile);

      if (stylesheetParamString != '') {
        XSLTProcessor.addParameter('stylesheetParams', stylesheetParamString);
      }
    	XSLTProcessor.transform();

      document.open();
      document.write(XSLTProcessor.output);
      document.close();
    }
  </script>
  <form name="stylesheetParams" action="javascript:formLoadXML()">
    <xsl:choose>
      <xsl:when test="$choose-xml-file and $choose-xsl-file">
        <table>
          <xsl:call-template name="insert-selectParameters-xml-file">
            <xsl:with-param name="xml-file" select="$xml-file" />
            <xsl:with-param name="lang" select="$lang" />
          </xsl:call-template>
          <xsl:call-template name="insert-selectParameters-xsl-file">
            <xsl:with-param name="xsl-file" select="$xsl-file" />
            <xsl:with-param name="lang" select="$lang" />
          </xsl:call-template>
        </table>
      </xsl:when>
      <xsl:when test="$choose-xml-file">
        <table>
          <xsl:call-template name="insert-selectParameters-xml-file">
            <xsl:with-param name="xml-file" select="$xml-file" />
            <xsl:with-param name="lang" select="$lang" />
          </xsl:call-template>
        </table>
        <xsl:call-template name="insert-selectParameters-xsl-file">
          <xsl:with-param name="xsl-file" select="$xsl-file" />
          <xsl:with-param name="choose" select="false()" />
          <xsl:with-param name="lang" select="$lang" />
        </xsl:call-template>        
      </xsl:when>
      <xsl:when test="$choose-xsl-file">
        <table>
          <xsl:call-template name="insert-selectParameters-xsl-file">
            <xsl:with-param name="xsl-file" select="$xsl-file" />
            <xsl:with-param name="lang" select="$lang" />
          </xsl:call-template>
        </table>
        <xsl:call-template name="insert-selectParameters-xml-file">
          <xsl:with-param name="xml-file" select="$xml-file" />
          <xsl:with-param name="choose" select="false()" />
          <xsl:with-param name="lang" select="$lang" />
        </xsl:call-template>        
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="insert-selectParameters-xml-file">
          <xsl:with-param name="xml-file" select="$xml-file" />
          <xsl:with-param name="choose" select="false()" />
          <xsl:with-param name="lang" select="$lang" />
        </xsl:call-template>
        <xsl:call-template name="insert-selectParameters-xsl-file">
          <xsl:with-param name="xsl-file" select="$xsl-file" />
          <xsl:with-param name="choose" select="false()" />
          <xsl:with-param name="lang" select="$lang" />
        </xsl:call-template>        
      </xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="insert-selectParameters-entries" />
    <xsl:call-template name="insert-selectParameters-button" />
  </form>
</xsl:template>

<xsl:template name="insert-selectParameters-xml-file">
  <xsl:param name="xml-file" />
  <xsl:param name="choose" select="true()" />
  <xsl:param name="lang" select="'en'" />
  <xsl:choose>
    <xsl:when test="$choose">
      <tr>
        <th><label for="stylesheetParamselectParameters-xml-file">XML File:</label></th>
        <td>
          <input id="stylesheetParamselectParameters-xml-file"
                 name="selectParameters-xml-file"
                 value="{$xml-file}"
                 type="text" />
        </td>
      </tr>
    </xsl:when>
    <xsl:otherwise>
      <input id="stylesheetParamselectParameters-xml-file"
             name="selectParameters-xml-file"
             value="{$xml-file}"
             type="hidden" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="insert-selectParameters-xsl-file">
  <xsl:param name="xsl-file" />
  <xsl:param name="choose" select="true()" />
  <xsl:param name="lang" select="'en'" />
  <xsl:choose>
    <xsl:when test="$choose">
      <tr>
        <th><label for="stylesheetParamselectParameters-xsl-file">XSL File:</label></th>
        <td>
          <input id="stylesheetParamselectParameters-xsl-file"
                 name="selectParameters-xsl-file"
                 value="{$xsl-file}"
                 type="text" />
        </td>
      </tr>
    </xsl:when>
    <xsl:otherwise>
      <input id="stylesheetParamselectParameters-xsl-file"
             name="selectParameters-xsl-file"
             value="{$xsl-file}"
             type="hidden" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="insert-selectParameters-entries">
  <xsl:param name="lang" select="'en'" />
  <table>
    <xsl:apply-templates select="$params" mode="entry">
      <xsl:with-param name="lang" select="$lang" />
    </xsl:apply-templates>
  </table>
</xsl:template>

<xsl:template match="xsl:param" mode="entry">
  <xsl:param name="lang" select="'en'" />
  <tr>
    <th>
      <xsl:apply-templates select="." mode="label">
        <xsl:with-param name="lang" select="$lang" />
      </xsl:apply-templates>
    </th>
    <td>
      <xsl:apply-templates select="." mode="input">
        <xsl:with-param name="lang" select="$lang" />
      </xsl:apply-templates>
    </td>
  </tr>
</xsl:template>

<xsl:template match="xsl:param" mode="label">
  <xsl:param name="lang" select="'en'" />
  <label for="stylesheetParam{@name}">
    <xsl:variable name="label" select="key('param-doc', @name)/doc:label" />
    <xsl:choose>
      <xsl:when test="$label[lang($lang)]"><xsl:value-of select="$label[lang($lang)]" /></xsl:when>
      <xsl:when test="$label"><xsl:value-of select="$label" /></xsl:when>
      <xsl:otherwise><xsl:value-of select="@name" /></xsl:otherwise>
    </xsl:choose>
  </label>
</xsl:template>

<xsl:template match="xsl:param" mode="input">
  <xsl:param name="lang" select="'en'" />
  <xsl:variable name="default" select="substring-before(substring-after(concat($param-separator, $stylesheetParams), concat($param-separator, @name, '=')), $param-separator)" />
  <xsl:variable name="param-doc" select="key('param-doc', @name)" />
  <xsl:variable name="desc" select="$param-doc/doc:desc" />
  <xsl:variable name="choices" select="$param-doc/doc:choice" />
  <xsl:variable name="options" select="$param-doc/doc:option" />
  <xsl:variable name="min" select="$param-doc/doc:min" />
  <xsl:variable name="max" select="$param-doc/doc:max" />

  <xsl:choose>
    <xsl:when test="$choices">
      <select id="stylesheetParam{@name}" name="{@name}">
        <xsl:for-each select="$choices">
          <xsl:variable name="label">
            <xsl:choose>
              <xsl:when test="doc:label[lang($lang)]">
                <xsl:value-of select="doc:label[lang($lang)]" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="doc:label" />
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <option value="{doc:value}">
            <xsl:if test="string($label)">
              <xsl:attribute name="label"><xsl:value-of select="$label" /></xsl:attribute>
            </xsl:if>
            <xsl:if test="doc:value = $default">
              <xsl:attribute name="selected">selected</xsl:attribute>
            </xsl:if>
            <xsl:choose>
              <xsl:when test="string($label)">
                <xsl:value-of select="$label" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="doc:value" />
              </xsl:otherwise>
            </xsl:choose>
          </option>
        </xsl:for-each>
      </select>
    </xsl:when>
    <xsl:when test="$options">
      <xsl:variable name="name" select="@name" />
      <xsl:for-each select="$options">
        <input type="checkbox"
               name="{$name}"
               value="{doc:value}"
               id="stylesheetParam{$name}{doc:value}">
          <xsl:if test="contains(concat('::', $default, '::'), concat('::', doc:value, '::'))">
            <xsl:attribute name="checked">checked</xsl:attribute>
          </xsl:if>
        </input>
        <label for="stylesheetParam{$name}{doc:value}">
          <xsl:choose>
            <xsl:when test="doc:label[lang($lang)]">
              <xsl:value-of select="doc:label[lang($lang)]" />
            </xsl:when>
            <xsl:when test="doc:label">
              <xsl:value-of select="doc:label" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="doc:value" />
            </xsl:otherwise>
          </xsl:choose>
        </label>
      </xsl:for-each>
    </xsl:when>
    <xsl:otherwise>
      <input id="stylesheetParam{@name}" name="{@name}">
        <xsl:if test="$default">
          <xsl:attribute name="value"><xsl:value-of select="$default" /></xsl:attribute>
        </xsl:if>
        <xsl:if test="$min or $max">
          <xsl:attribute name="onchange">
            <xsl:choose>
              <xsl:when test="$min and $max">
                javascript:
                  if (this.value &lt; <xsl:value-of select="$min" /> | this.value > <xsl:value-of select="$max" />) {
                    alert("<xsl:value-of select="@name" /> must be between <xsl:value-of select="$min" /> and <xsl:value-of select="$max" />")
                  }
              </xsl:when>
              <xsl:when test="$min">
                javascript:
                  if (this.value &lt; <xsl:value-of select="$min" />) {
                    alert("<xsl:value-of select="@name" /> must be greater than <xsl:value-of select="$min" />")
                  }
              </xsl:when>
              <xsl:otherwise>
                javascript:
                  if (this.value > <xsl:value-of select="$max" />) {
                    alert("<xsl:value-of select="@name" /> must be less than <xsl:value-of select="$max" />")
                  }
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
        </xsl:if>
      </input>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="insert-selectParameters-button">
  <xsl:param name="lang" select="'en'" />
  <button type="submit">change</button>
</xsl:template>

<xsl:template name="escape">
  <xsl:param name="string" />
  <xsl:choose>
    <xsl:when test="contains($string, '\')">
      <xsl:value-of select="substring-before($string, '\')" />
      <xsl:text>\\</xsl:text>
      <xsl:call-template name="escape">
        <xsl:with-param name="string" select="substring-after($string, '\')" />
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$string" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

</xsl:stylesheet>