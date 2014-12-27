<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:doc="http://www.jenitennison.com/xslt/doc"
                extension-element-prefixes="doc"
                doc:base="summary.xsl">

<xsl:import href="xslt-doc-utils.xsl" />
<xsl:import href="table.xsl" />

<xsl:param name="tables-rtf">
	<tables>
      <table name="templates">
         <col value="name()" label="Templates" movable="no" />
         <col value="@match" label="Match" />
         <col value="@mode" label="Mode" />
         <sort select="@mode" />
         <sort select="@match" />
      </table>
      <table name="named-templates">
         <col value="name()" label="Named Templates" movable="no" />
         <col value="@name" label="Name" />
         <sort select="@name" />
      </table>
      <table name="variables">
         <col value="name()" label="Variables &amp; Parameters" movable="no" />
         <col value="@name" label="Name" />
         <col value="@select" label="Select" />
         <col value="#content" label="Content" />
         <sort select="name()" />
         <sort select="@name" />
         <sort select="@select" />
         <sort select="#content" />
      </table>
      <table name="keys">
         <col value="name()" label="Keys" movable="no" />
         <col value="@name" label="Name" />
         <col value="@match" label="Match" />
         <col value="@use" label="Use" />
         <sort select="@name" />
         <sort select="@match" />
         <sort select="@use" />
      </table>
      <table name="import">
         <col value="name()" label="Imports &amp; Includes" movable="no" />
         <col value="@href" label="URL" />
         <sort select="name()" />
         <sort select="@href" />
      </table>
      <table name="spacing">
         <col value="name()" label="Whitespace Control" movable="no" />
         <col value="@elements" label="Elements" />
         <sort select="name()" />
         <sort select="@elements" />
      </table>
      <table name="output">
         <col value="name()" label="Output Control" movable="no" />
         <col value="@method" label="Method" />
         <col value="@doctype-public" label="Public" />
         <col value="@doctype-system" label="System" />
      </table>
      <table name="namespaces">
         <col value="name()" label="Namespace Aliases" movable="no" />
         <col value="@stylesheet-prefix" label="Stylesheet" />
         <col value="@result-prefix" label="Result" />
         <sort select="@stylesheet-prefix" />
         <sort select="@result-prefix" />
      </table>
      <table name="attributes">
         <col value="name()" label="Attribute Sets" movable="no" />
         <col value="@name" label="Name" />
         <col value="@use-attribute-sets" label="Uses" />
         <sort select="@name" />
         <sort select="@use-attribute-sets" />
      </table>
      <table name="decimals">
         <col value="name()" label="Decimal Formats" movable="no" />
         <col value="@name" label="Name" />
         <col value="@grouping-separator" label="Groups" />
         <col value="@decimal-separator" label="Decimals" />
         <sort select="@name" />
         <sort select="@grouping-separator" />
         <sort select="@decimal-separator" />
      </table>
   </tables>
</xsl:param>

<xsl:template name="add-parameters">
	XSLTProcessor.addParameter('source-stylesheet', '<xsl:value-of select="$source-stylesheet" />');
   XSLTProcessor.addParameter('current-stylesheet', '<xsl:value-of select="$current-stylesheet" />');
   XSLTProcessor.addParameter('show', '<xsl:value-of select="$show" />');
</xsl:template>

<xsl:variable name="row">
   <xsl:text>row</xsl:text>
   <xsl:choose>
      <xsl:when test="generate-id($node) = generate-id($node-construct)"><xsl:value-of select="$show" /></xsl:when>
      <xsl:otherwise><xsl:value-of select="count($node-construct/preceding::* | $node-construct/ancestor::*) + 1" /></xsl:otherwise>
   </xsl:choose>
</xsl:variable>

<xsl:template match="xsl:stylesheet">
   <html>
      <head>
         <style type="text/css">
            body { <xsl:apply-templates select="$prefs/summary/body" mode="css" /> }
            table { <xsl:apply-templates select="$prefs/summary/table" mode="css" /> }
            th { <xsl:apply-templates select="$prefs/summary/headers" mode="css" /> }
            td { <xsl:apply-templates select="$prefs/summary/rows" mode="css" /> }
            <xsl:for-each select="$prefs/notes/*[not(self::body or self::table or self::headers or self::rows or self::selected)]">
               <xsl:text />.<xsl:value-of select="name()" /> {<xsl:text />
               <xsl:apply-templates select="." mode="css" /> }<xsl:text />
            </xsl:for-each>
         </style>
         <xsl:call-template name="insert-script-for-tables">
            <xsl:with-param name="xml-file" select="$current-stylesheet" />
            <xsl:with-param name="xsl-file" select="concat($stylesheet-path, 'summary.xsl')" />
            <xsl:with-param name="script-dir" select="$stylesheet-path" />
         </xsl:call-template>
         <script type="text/javascript">
            var selectedRow = '';
            function select(row) {
               if (selectedRow != '') {
                  selectedRow.style.background = '';
                  selectedRow.style.color = '';
                  selectedRow.style.cursor = '';
               }
               selectedRow = row;
               row.style.background = '<xsl:value-of select="$prefs/summary/selected/@background" />';
               row.style.color = '<xsl:value-of select="$prefs/summary/selected/@color" />';
               row.style.cursor = '<xsl:value-of select="$prefs/summary/selected/@cursor" />';
            }
         </script>
      </head>
      <body onload="javascript:select({$row});">
         <xsl:call-template name="insert-table">
            <xsl:with-param name="name" select="'import'" />
            <xsl:with-param name="rows" select="xsl:import | xsl:include" />
         </xsl:call-template>
         
         <xsl:call-template name="insert-table">
            <xsl:with-param name="name" select="'spaces'" />
            <xsl:with-param name="rows" select="xsl:strip-space | xsl:preserve-space" />
         </xsl:call-template>
         
         <xsl:call-template name="insert-table">
            <xsl:with-param name="name" select="'output'" />
            <xsl:with-param name="rows" select="xsl:output" />
         </xsl:call-template>
         
         <xsl:call-template name="insert-table">
            <xsl:with-param name="name" select="'namespaces'" />
            <xsl:with-param name="rows" select="xsl:namespace-alias" />
         </xsl:call-template>
         
         <xsl:call-template name="insert-table">
            <xsl:with-param name="name" select="'variables'" />
            <xsl:with-param name="rows" select="xsl:variable | xsl:param" />
         </xsl:call-template>
         
         <xsl:call-template name="insert-table">
            <xsl:with-param name="name" select="'keys'" />
            <xsl:with-param name="rows" select="xsl:key" />
         </xsl:call-template>
         
         <xsl:call-template name="insert-table">
            <xsl:with-param name="name" select="'templates'" />
            <xsl:with-param name="rows" select="xsl:template[not(@name)]" />
         </xsl:call-template>
         
         <xsl:call-template name="insert-table">
            <xsl:with-param name="name" select="'named-templates'" />
            <xsl:with-param name="rows" select="xsl:template[@name]" />
         </xsl:call-template>
         
         <xsl:call-template name="insert-table">
            <xsl:with-param name="name" select="'attributes'" />
            <xsl:with-param name="rows" select="xsl:attribute-set" />
         </xsl:call-template>
         
         <xsl:call-template name="insert-table">
            <xsl:with-param name="name" select="'decimals'" />
            <xsl:with-param name="rows" select="xsl:decimal-format" />
         </xsl:call-template>
      </body>
   </html>
</xsl:template>

<xsl:template match="*" mode="row">
   <xsl:param name="table" select="/.." />
   <xsl:variable name="id" select="@original-position" />
   <xsl:variable name="override">
      <xsl:if test="@name">
         <xsl:apply-templates select="." mode="find-overriding" />
      </xsl:if>
   </xsl:variable>
	<tr id="row{$id}" onclick="javascript:top.loadSource('{$current-stylesheet}', '{$id}'); select(row{$id})">
      <xsl:variable name="node" select="." />
      <xsl:for-each select="$table/col">
         <xsl:variable name="value">
            <xsl:apply-templates select="$node" mode="cell-value">
               <xsl:with-param name="cell" select="@value" />
            </xsl:apply-templates>
         </xsl:variable>
         <td>
            <xsl:if test="string($override)">
               <xsl:attribute name="class">overridden</xsl:attribute>
            </xsl:if>
            <xsl:choose>
               <xsl:when test="string($value)"><xsl:copy-of select="$value" /></xsl:when>
               <xsl:otherwise>&#160;</xsl:otherwise>
            </xsl:choose>
         </td>
      </xsl:for-each>
   </tr>
</xsl:template>

</xsl:stylesheet>