<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:my="http://www.jenitennison.com/"
                extension-element-prefixes="my">

<xsl:import href="svg-utils.xsl" />

<my:diagrams>
   <my:diagram type="column" />
   <my:diagram type="line" />
</my:diagrams>

<xsl:variable name="stats" select="/stats" />

<xsl:template match="/">
   <xsl:variable name="images" select="document('')/*/my:diagrams/my:diagram" />
   <html>
      <head>
         <title>SVG Chart Demonstration</title>
         <xsl:call-template name="insertSVGScript">
            <xsl:with-param name="images" select="$images" />
         </xsl:call-template>
      </head>
      <body>
         <h1>SVG Chart Demonstration</h1>
         <p>The following charts are generated automatically using XSLT.</p>
         <xsl:apply-templates select="$images" mode="createEmbed" />
      </body>
   </html>
</xsl:template>

<xsl:template match="my:diagram" mode="getSVG">
   <xsl:variable name="points" select="$stats/item" />
   <xsl:variable name="type" select="@type" />
   <xsl:variable name="space" select="30" />
   <xsl:variable name="width-height-ratio" select="2 div 3" />
   <xsl:variable name="col-width" select="20" />
   <xsl:variable name="col-gap" select="10" />
   <xsl:variable name="point-width" select="5" />
   <xsl:variable name="xaxis-width" select="count($points) * ($col-width + $col-gap)" />
   <xsl:variable name="width" select="round($xaxis-width + (2 * $space))" />
   <xsl:variable name="height" select="round($xaxis-width * $width-height-ratio + (2 * $space))" />
   <xsl:variable name="max-value">
      <xsl:for-each select="$points">
         <xsl:sort select="value" order="descending" />
         <xsl:if test="position() = 1"><xsl:value-of select="value" /></xsl:if>
      </xsl:for-each>
   </xsl:variable>
   <xsl:variable name="unit-multiplier" select="($xaxis-width * $width-height-ratio) div ($max-value * 1.05)" />
   <svg width="100%" viewBox="0 0 {$width} {$height}" preserveAspectRatio="xMinYMin meet">
      <!-- border around chart -->
      <rect width="{$width}" height="{$height}" style="fill: #CCC; stroke: black;" />
      <!-- X Axis line -->
      <line x1="{$space}" y1="{$height - $space}" x2="{$width - $space}" y2="{$height - $space}" style="stroke: black;" />
      <!-- Y Axis line -->
      <line x1="{$space}" y1="{$space}" x2="{$space}" y2="{$height - $space}" style="stroke: black;" />
      <xsl:for-each select="$points">
         <xsl:variable name="item-height" select="round(value * $unit-multiplier)" />
         <xsl:variable name="xMin" select="$space + (count(preceding-sibling::item) * ($col-width + $col-gap))" />
         <!-- Columns -->
         <xsl:choose>
            <xsl:when test="$type = 'column'">
               <rect x="{$xMin + ($col-gap div 2)}" y="{$height - $space - $item-height}" width="{$col-width}" height="{$item-height}" style="fill: blue; stroke: black;" />
            </xsl:when>
            <xsl:otherwise>
               <xsl:variable name="x" select="$xMin + ($col-gap div 2) + (($col-width - $point-width) div 2)" />
               <xsl:variable name="y" select="$height - $space - $item-height - ($point-width div 2)" />
               <rect x="{$x}"
                     y="{$y}"
                     width="{$point-width}"
                     height="{$point-width}"
                     style="fill: blue; stroke: black;" />
               <xsl:variable name="next" select="following-sibling::item" />
               <xsl:if test="$next">
                  <xsl:variable name="nextX" select="$xMin + $col-width + $col-gap * 1.5 + (($col-width - $point-width) div 2)" />
                  <xsl:variable name="nextY" select="$height - $space - ($point-width div 2) - round($next/value * $unit-multiplier)" />
                  <line x1="{$x + $point-width div 2}"
                        y1="{$y + $point-width div 2}"
                        x2="{$nextX + $point-width div 2}"
                        y2="{$nextY + $point-width div 2}"
                        style="stroke: blue;" />
               </xsl:if>
            </xsl:otherwise>
         </xsl:choose>
         <!-- Column captions -->
         <text x="{$xMin}" y="{$height - $space div 3}" textLength="{$col-width}" style="font: Arial;"><xsl:value-of select="label" /></text>
      </xsl:for-each>
   </svg>
</xsl:template>

</xsl:stylesheet>