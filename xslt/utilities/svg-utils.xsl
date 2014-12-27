<?xml version="1.0"?>
<!--
    svg-utils.xsl - a XSLT stylesheet with utilities for using SVG
    Copyright (C) 2000, 2001  Dr Jeni Tennison & Xi advies bv

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
    
    Dr Jeni Tennison - http://www.jenitennison.com - mail@jenitennison.com
    Gert Bultman - http://www.xi-advies.nl - bultman@xi-advies.nl
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                xmlns:saxon="http://icl.com/saxon"
                xmlns:exsl="http://exslt.org/common"
                extension-element-prefixes="msxsl saxon exsl">

<xsl:output method="html" />

<xsl:strip-space elements="*" />

<xsl:template name="insertSVGScript">
   <xsl:param name="images" select="/.." />
   <script type="text/javascript" src="domtodom.js" />
   <script type="text/javascript">
      var embedsLoaded = 0;

      function triggerSVGLoading() {
         embedsLoaded++;
         if (embedsLoaded == <xsl:value-of select="count($images)" />) {
            <xsl:for-each select="$images">
               <xsl:text>loadSVG(&apos;</xsl:text>
               <xsl:call-template name="serialiseSVG">
                  <xsl:with-param name="svg-rtf">
                     <xsl:apply-templates select="." mode="getSVG" />
                  </xsl:with-param>
               </xsl:call-template>
               <xsl:text>&apos;, &apos;</xsl:text>
               <xsl:apply-templates select="." mode="getSVGID" />&apos;);
            </xsl:for-each>
         }
      }

      function loadSVG(imageXML, embedID) {
         var svg = getDOMFromXML(imageXML);
         domtodom(svg, embedID);
      }

      function getDOMFromXML(XML) {
            DOM = new ActiveXObject('Msxml2.FreeThreadedDOMDocument');
            DOM.async = false;
            DOM.validateOnParse = false;
            DOM.loadXML(XML);
            if (DOM.parseError.errorCode != 0) {
              alert('Error parsing XML:\n' + explainParseError(DOM.parseError));
              return;
            }
           return DOM;
      }
   </script>
</xsl:template>

<xsl:template match="node()" mode="createEmbed">
   <xsl:param name="src" select="'blank.svg'" />
   <xsl:param name="width" />
   <xsl:param name="height" />
   <xsl:variable name="id">
      <xsl:apply-templates select="." mode="getSVGID" />
   </xsl:variable>
   <embed name="{$id}" 
          src="{$src}" 
          pluginspage="http://www.adobe.com/svg/viewer/install/" 
          type="image/svg+xml">
      <xsl:if test="$width">
         <xsl:attribute name="width"><xsl:value-of select="$width" /></xsl:attribute>
      </xsl:if>
      <xsl:if test="$height">
         <xsl:attribute name="height"><xsl:value-of select="$height" /></xsl:attribute>
      </xsl:if>
   </embed>
</xsl:template>

<xsl:template match="node()" mode="getSVGID">
   <xsl:value-of select="concat('SVGEmbed', generate-id())" />
</xsl:template>

<xsl:template name="serialiseSVG">
   <xsl:param name="svg-rtf">
      <svg />
   </xsl:param>
   <xsl:choose>
      <xsl:when test="function-available('exsl:node-set')">
         <xsl:apply-templates select="exsl:node-set($svg-rtf)/node()" mode="serialise" />
      </xsl:when>
      <xsl:when test="function-available('saxon:node-set')">
         <xsl:apply-templates select="saxon:node-set($svg-rtf)/node()" mode="serialise" />
      </xsl:when>
      <xsl:when test="function-available('msxsl:node-set')">
         <xsl:apply-templates select="msxsl:node-set($svg-rtf)/node()" mode="serialise" />
      </xsl:when>
      <xsl:otherwise>
         <xsl:message terminate="yes">
            ERROR: Unknown processor - this stylesheet requires processor support for exsl:node-set()
         </xsl:message>
      </xsl:otherwise>
   </xsl:choose>
</xsl:template>

<xsl:template match="*" mode="serialise">
   <xsl:text />&lt;<xsl:value-of select="name()" />
   <xsl:for-each select="namespace::*[local-name() != 'xml']">
      <xsl:if test="not(../../namespace::*[local-name() = local-name(current()) and . = current()])">
         <xsl:text> xmlns</xsl:text>
         <xsl:if test="local-name()">:<xsl:value-of select="local-name()" /></xsl:if>
         <xsl:text>="</xsl:text>
         <xsl:call-template name="js-escape">
            <xsl:with-param name="string" select="." />
         </xsl:call-template>
         <xsl:text>"</xsl:text>
      </xsl:if>
   </xsl:for-each>
   <xsl:for-each select="@*">
      <xsl:text> </xsl:text>
      <xsl:value-of select="name()" />="<xsl:text />
      <xsl:call-template name="js-escape">
         <xsl:with-param name="string" select="." />
      </xsl:call-template>
      <xsl:text>"</xsl:text>
   </xsl:for-each>
   <xsl:choose>
      <xsl:when test="node()">
         <xsl:text />&gt;<xsl:apply-templates mode="serialise" />
         <xsl:text />&lt;/<xsl:value-of select="name()" />&gt;<xsl:text />
      </xsl:when>
      <xsl:otherwise> /&gt;</xsl:otherwise>
   </xsl:choose>
</xsl:template>

<xsl:template match="text()" mode="serialise">
   <xsl:call-template name="js-escape">
      <xsl:with-param name="string" select="." />
   </xsl:call-template>
</xsl:template>

<xsl:template match="comment()" mode="serialise">
   <xsl:text>&lt;!-- </xsl:text>
   <xsl:call-template name="js-escape">
      <xsl:with-param name="string" select="." />
   </xsl:call-template>
   <xsl:text> --&gt;</xsl:text>
</xsl:template>

<xsl:template match="processing-instruction()" mode="serialise">
   <xsl:text>&lt;?</xsl:text>
   <xsl:value-of select="name()" />
   <xsl:text> </xsl:text>
   <xsl:call-template name="js-escape">
      <xsl:with-param name="string" select="." />
   </xsl:call-template>
   <xsl:text> ?&gt;</xsl:text>
</xsl:template>

<xsl:template name="js-escape">
   <xsl:param name="string" />
   <xsl:call-template name="substitute">
      <!-- normalize spaces to get rid of line breaks, which javascript does not like -->
      <xsl:with-param name="string" select="normalize-space($string)" />
      <xsl:with-param name="find" select='"&apos;"' />
      <xsl:with-param name="replace" select='"\&apos;"' />
   </xsl:call-template>
</xsl:template>

<xsl:template name="substitute">
   <xsl:param name="string" />
   <xsl:param name="find" />
   <xsl:param name="replace" />
   <xsl:choose>
      <xsl:when test="$find and $string and contains($string, $find)">
         <xsl:value-of select="substring-before($string, $find)" />
         <xsl:value-of select="$replace" />
         <xsl:call-template name="substitute">
            <xsl:with-param name="string" select="substring-after($string, $find)" />
            <xsl:with-param name="find" select="$find" />
            <xsl:with-param name="replace" select="$replace" />
         </xsl:call-template>
      </xsl:when>
      <xsl:otherwise><xsl:value-of select="$string" /></xsl:otherwise>
   </xsl:choose>
</xsl:template>

</xsl:stylesheet>