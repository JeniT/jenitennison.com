<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="xslt-doc.xsl" ?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:saxon="http://icl.com/saxon"
                xmlns:doc="http://www.jenitennison.com/xslt/doc"
                extension-element-prefixes="saxon">

<xsl:import href="xslt-doc-utils.xsl" />

<xsl:template match="xsl:stylesheet">
   <xsl:variable name="source">
   	<xsl:choose>
   		<xsl:when test="@doc:base"><xsl:value-of select="@doc:base" /></xsl:when>
   		<xsl:otherwise>#source</xsl:otherwise>
   	</xsl:choose>
   </xsl:variable>
   <html>
      <head>
         <title>Stylesheet Documentation</title>
         <script type="text/javascript">
            function openStylesheet() {
               var undefined;
               var stylesheet = prompt('Enter the filename of the stylesheet, either relative to the XSLTDoc stylesheet or as a full URL:', '');
               if (stylesheet == undefined) {
                  alert('You must enter the name for the styleheet to be viewed.  Reload this page to try again.');
                  return;
               }
               sourceStylesheet = stylesheet;
               populateFrames();
            }
            
            var sourceStylesheet;
            var treeXSLTDOM;
            var summaryXSLTDOM;
            var summaryXSLT;
            var sourceXSLTDOM;
            var sourceXSLT;
            var notesXSLTDOM;
            var notesXSLT;

            function populateFrames() {
               treeXSLTDOM = getDOMFromFile("<xsl:value-of select="$stylesheet-path" />tree.xsl");
               summaryXSLTDOM = getDOMFromFile("<xsl:value-of select="$stylesheet-path" />summary.xsl");
               sourceXSLTDOM = getDOMFromFile("<xsl:value-of select="$stylesheet-path" />source.xsl");
               notesXSLTDOM = getDOMFromFile("<xsl:value-of select="$stylesheet-path" />notes.xsl");
               loadTree(sourceStylesheet, 2);
            }

            function loadTree(stylesheet, show) {
               var sourceDOM = getDOMFromFile(stylesheet);
               var treeXSLT = getProcessorFromDOMs(sourceDOM, treeXSLTDOM);
               treeXSLT.addParameter('source-stylesheet', sourceStylesheet);
               treeXSLT.addParameter('current-stylesheet', stylesheet);
               treeXSLT.addParameter('show', show);
               loadTransformedXML(treeXSLT, importFrame);
               summaryXSLT = getProcessorFromDOMs(sourceDOM, summaryXSLTDOM);
               sourceXSLT = getProcessorFromDOMs(sourceDOM, sourceXSLTDOM);
               notesXSLT = getProcessorFromDOMs(sourceDOM, notesXSLTDOM);
               loadSummary(stylesheet, show);
            }

            function loadSummary(stylesheet, show) {
               summaryXSLT.reset();
               summaryXSLT.addParameter('source-stylesheet', sourceStylesheet);
               summaryXSLT.addParameter('current-stylesheet', stylesheet);
               summaryXSLT.addParameter('show', show);
               loadTransformedXML(summaryXSLT, summaryFrame);
               loadSource(stylesheet, show);
            }

            function loadSource(stylesheet, show) {
               sourceXSLT.reset();
               sourceXSLT.addParameter('source-stylesheet', sourceStylesheet);
               sourceXSLT.addParameter('current-stylesheet', stylesheet);
               sourceXSLT.addParameter('show', show);
               loadTransformedXML(sourceXSLT, sourceFrame);
               loadNotes(stylesheet, show);
            }

            function loadNotes(stylesheet, show) {
               notesXSLT.reset();
               notesXSLT.addParameter('source-stylesheet', sourceStylesheet);
               notesXSLT.addParameter('current-stylesheet', stylesheet);
               notesXSLT.addParameter('show', show);
               loadTransformedXML(notesXSLT, notesFrame);
            }

            function highlight(stylesheet, show, node, row) {
               summaryFrame.select(row);
               sourceFrame.select(node);
               loadNotes(stylesheet, show);
            }
         </script>
         <script type="text/javascript" src="{$stylesheet-path}loadTransformedXML.js" />
      </head>
      <frameset rows="30%,*" onload="openStylesheet()">
         <frameset cols="30%,*">
            <frame name="importFrame" />
            <frame name="summaryFrame" />
         </frameset>
         <frameset cols="60%,*">
            <frame name="sourceFrame" />
            <frame name="notesFrame" />
         </frameset>
      </frameset>
   </html>
</xsl:template>

<xsl:template match="xsl:import | xsl:include" mode="source">
	<xsl:variable name="stylesheet" select="document(@href, /)/xsl:stylesheet" />
   <xsl:text />&lt;source href="<xsl:value-of select="@href" />"><xsl:text />
      <xsl:apply-templates select="$stylesheet" mode="copy" />
   <xsl:text>&lt;/source></xsl:text>
   <xsl:apply-templates select="$stylesheet/xsl:import | $stylesheet/xsl:include" mode="source" />
</xsl:template>

<xsl:template match="*" mode="copy">
   <xsl:text />&lt;<xsl:value-of select="name()" />
   <xsl:text /> doc:id="<xsl:value-of select="generate-id()" />"<xsl:text />
   <xsl:for-each select="@*">
      <xsl:text> </xsl:text>
      <xsl:value-of select="name()" />="<xsl:text />
      <xsl:call-template name="escape-js">
         <xsl:with-param name="string" select="." />
      </xsl:call-template>
      <xsl:text>"</xsl:text>
   </xsl:for-each>
   <xsl:text>&gt;</xsl:text>
   <xsl:apply-templates mode="copy" />
   <xsl:text />&lt;/<xsl:value-of select="name()" />&gt;<xsl:text />
</xsl:template>

<xsl:template match="text()" mode="copy">
   <xsl:call-template name="escape-js">
      <xsl:with-param name="string" select="." />
   </xsl:call-template>
</xsl:template>

<xsl:template name="escape-js">
   <xsl:param name="string" />
   <xsl:variable name="quotes-escaped">
      <xsl:call-template name="escape-quotes">
         <xsl:with-param name="string" select="$string" />
      </xsl:call-template>
   </xsl:variable>
   <xsl:call-template name="escape-line-breaks">
      <xsl:with-param name="string" select="$quotes-escaped" />
   </xsl:call-template>
</xsl:template>

<xsl:template name="escape-line-breaks">
   <xsl:param name="string" />
   <xsl:choose>
      <xsl:when test="contains($string, '&#x0A;')">
         <xsl:value-of select="substring-before($string, '&#x0A;')" />
         <xsl:text>\n</xsl:text>
         <xsl:call-template name="escape-line-breaks">
           <xsl:with-param name="string" select="substring-after($string, '&#x0A;')" />
         </xsl:call-template>
      </xsl:when>
      <xsl:otherwise><xsl:value-of select="$string" /></xsl:otherwise>
   </xsl:choose>
</xsl:template>

<xsl:template name="escape-quotes">
   <xsl:param name="string" />
   <xsl:choose>
      <xsl:when test='contains($string, "&apos;")'>
         <xsl:value-of select='substring-before($string, "&apos;")' />
         <xsl:text>\'</xsl:text>
         <xsl:call-template name="escape-quotes">
           <xsl:with-param name="string" select='substring-after($string, "&apos;")' />
         </xsl:call-template>
      </xsl:when>
      <xsl:otherwise><xsl:value-of select="$string" /></xsl:otherwise>
   </xsl:choose>
</xsl:template>

</xsl:stylesheet>