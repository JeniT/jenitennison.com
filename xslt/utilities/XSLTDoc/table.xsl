<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="xslt-doc.xsl" ?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                xmlns:saxon="http://icl.com/saxon"
                exclude-result-prefixes="saxon msxsl">

<xsl:output indent="yes" />

<xsl:param name="tables-rtf">
	<tables />
</xsl:param>

<xsl:variable name="tables" select="msxsl:node-set($tables-rtf)/tables" />

<xsl:template name="insert-script-for-tables">
   <xsl:param name="xml-file" />
   <xsl:param name="xsl-file">
      <xsl:variable name="pi" select="//processing-instruction('xml-stylesheet')" />
      <xsl:variable name="after" select="substring-after($pi, ' href=')" />
      <xsl:variable name="quote" select="substring($after, 1, 1)" />
      <xsl:value-of select="substring-before(substring-after($after, $quote), $quote)" />
   </xsl:param>
   <xsl:param name="script-dir" />
  <script type="text/javascript" src="{$script-dir}loadTransformedXML.js" />
  <script type="text/javascript">
   function reloadXMLForTables(tables) {
      XMLfile = '<xsl:value-of select="$xml-file" />';
      if (XMLfile == '') {
        XMLfile = document.URL;
      }
      XSLTProcessor = getProcessor(XMLfile, '<xsl:value-of select="$xsl-file" />');

      XSLTProcessor.addParameter('tables-rtf', getDOMFromXML(tables.replace(/&amp;/g, '&amp;amp;')));
      <xsl:call-template name="add-parameters" />

      loadTransformedXML(XSLTProcessor, self);
    }

    function popupMenu(menu) {
      menu.style.visibility = 'visible';
    }

    function popdownMenu(menu) {
      menu.style.visibility = 'hidden';
    }
  </script>
  <style type="text/css">
      .menu { background: Menu; color: MenuText; 
              visibility: hidden; position: absolute;
              padding: 0.5em; border: 1px solid black;
              text-align: left; top: 40%; left: 40%; }
      .disabled { color: GrayText; }
  </style>
</xsl:template>

<xsl:template name="add-parameters" />

<xsl:template name="insert-table">
   <xsl:param name="name" />
   <xsl:param name="rows" select="/.." />

   <xsl:if test="$rows">
      <xsl:variable name="table" select="$tables/table[@name = $name]" />
      <xsl:variable name="unsorted-rows">
         <xsl:for-each select="$rows">
            <xsl:copy>
               <xsl:attribute name="original-position"><xsl:value-of select="count(ancestor::* | preceding::*) + 1" /></xsl:attribute>
               <xsl:copy-of select="@*" />
               <xsl:copy-of select="node()" />
            </xsl:copy>
         </xsl:for-each>
      </xsl:variable>
      <xsl:variable name="sorted-rows">
         <xsl:call-template name="sort">
            <xsl:with-param name="list" select="msxsl:node-set($unsorted-rows)" />
            <xsl:with-param name="sort" select="$table/sort" />
         </xsl:call-template>
      </xsl:variable>
      <table>
         <xsl:call-template name="table-header">
            <xsl:with-param name="table" select="$table" />
         </xsl:call-template>
         <tbody>
            <xsl:apply-templates select="msxsl:node-set($sorted-rows)/*" mode="row">
               <xsl:with-param name="table" select="$table" />
            </xsl:apply-templates>
         </tbody>
      </table>
   </xsl:if>
</xsl:template>

<xsl:template match="*" mode="row">
   <xsl:param name="table" select="/.." />
	<tr>
      <xsl:variable name="node" select="." />
      <xsl:for-each select="$table/col">
         <xsl:variable name="value">
            <xsl:apply-templates select="$node" mode="cell-value">
               <xsl:with-param name="cell" select="@value" />
            </xsl:apply-templates>
         </xsl:variable>
         <td>
            <xsl:choose>
               <xsl:when test="string($value)"><xsl:copy-of select="$value" /></xsl:when>
               <xsl:otherwise>&#160;</xsl:otherwise>
            </xsl:choose>
         </td>
      </xsl:for-each>
   </tr>
</xsl:template>

<xsl:template match="*" mode="cell-value">
	<xsl:param name="cell" />
   <xsl:choose>
      <xsl:when test="$cell = 'name()'"><xsl:value-of select="name()" /></xsl:when>
      <xsl:when test="$cell = '#content'"><xsl:apply-templates select="child::node()" mode="serialise-for-content" /></xsl:when>
      <xsl:when test="starts-with($cell, '@')"><xsl:value-of select="@*[name() = substring-after($cell, '@')]" /></xsl:when>
      <xsl:otherwise><xsl:value-of select="*[name() = $cell]" /></xsl:otherwise>
   </xsl:choose>
</xsl:template>

<xsl:template match="col" mode="table-header-menu">
   <xsl:variable name="table" select=".." />
   <div class="menu" id="menu{generate-id()}" onmouseout="javascript:popdownMenu(menu{generate-id()});">
      <span>
         <xsl:variable name="sort" select="$table/sort[@select = current()/@value]" />
         <xsl:choose>
            <xsl:when test="$sort">
               <xsl:variable name="reorder-rtf">
                  <xsl:copy-of select="$table/preceding-sibling::table" />
                  <table name="{$table/@name}">
                     <xsl:copy-of select="$table/col" />
                     <sort select="{$sort/@select}">
                        <xsl:attribute name="order">
                           <xsl:choose>
                              <xsl:when test="$sort/@order = 'descending'">ascending</xsl:when>
                              <xsl:otherwise>descending</xsl:otherwise>
                           </xsl:choose>
                        </xsl:attribute>
                     </sort>
                     <xsl:copy-of select="$table/sort[@select != $sort/@select]" />
                  </table>
                  <xsl:copy-of select="$table/following-sibling::table" />
               </xsl:variable>
               <xsl:attribute name="onclick">
                  <xsl:text>javascript:reloadXMLForTables('&lt;tables&gt;</xsl:text>
                  <xsl:apply-templates select="msxsl:node-set($reorder-rtf)" mode="serialise" />
                  <xsl:text>&lt;/tables&gt;');</xsl:text>
               </xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
               <xsl:attribute name="class">disabled</xsl:attribute>
            </xsl:otherwise>
         </xsl:choose>
         <xsl:attribute name="onmouseover">javascript:popupMenu(menu<xsl:value-of select="generate-id()" />);</xsl:attribute>
         <xsl:text>Sort</xsl:text>
      </span>
      <br />
      <span>
         <xsl:choose>
            <xsl:when test="not(@movable = 'no') and preceding-sibling::col and not(preceding-sibling::col[1]/@movable = 'no')">
               <xsl:variable name="move-left-rtf">
                  <xsl:copy-of select="$table/preceding-sibling::table" />
                  <table name="{$table/@name}">
                     <xsl:copy-of select="preceding-sibling::col[position() &gt; 1]" />
                     <xsl:copy-of select="." />
                     <xsl:copy-of select="preceding-sibling::col[1]" />
                     <xsl:copy-of select="following-sibling::col" />
                     <xsl:copy-of select="$table/sort" />
                  </table>
                  <xsl:copy-of select="$table/following-sibling::table" />
               </xsl:variable>
               <xsl:attribute name="onclick">
                  <xsl:text>javascript:reloadXMLForTables('&lt;tables&gt;</xsl:text>
                  <xsl:apply-templates select="msxsl:node-set($move-left-rtf)" mode="serialise" />
                  <xsl:text>&lt;/tables&gt;');</xsl:text>
               </xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
               <xsl:attribute name="class">disabled</xsl:attribute>
            </xsl:otherwise>
         </xsl:choose>
         <xsl:attribute name="onmouseover">javascript:popupMenu(menu<xsl:value-of select="generate-id()" />);</xsl:attribute>
         <xsl:text>Move&#160;Left</xsl:text>
      </span>
      <br />
      <span>
         <xsl:choose>
            <xsl:when test="not(@movable = 'no') and following-sibling::col and not(following-sibling::col[1]/@movable = 'no')">
                <xsl:variable name="move-right-rtf">
                  <xsl:copy-of select="$table/preceding-sibling::table" />
                  <table name="{$table/@name}">
                     <xsl:copy-of select="preceding-sibling::col" />
                     <xsl:copy-of select="following-sibling::col[1]" />
                     <xsl:copy-of select="." />
                     <xsl:copy-of select="following-sibling::col[position() &gt; 1]" />
                     <xsl:copy-of select="$table/sort" />
                  </table>
                  <xsl:copy-of select="$table/following-sibling::table" />
               </xsl:variable>
               <xsl:attribute name="onclick">
                  <xsl:text>javascript:reloadXMLForTables('&lt;tables&gt;</xsl:text>
                  <xsl:apply-templates select="msxsl:node-set($move-right-rtf)" mode="serialise" />
                  <xsl:text>&lt;/tables&gt;');</xsl:text>
               </xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
               <xsl:attribute name="class">disabled</xsl:attribute>
            </xsl:otherwise>
         </xsl:choose>
         <xsl:attribute name="onmouseover">javascript:popupMenu(menu<xsl:value-of select="generate-id()" />);</xsl:attribute>
         <xsl:text>Move&#160;Right</xsl:text>
      </span>
   </div>
</xsl:template>

<xsl:template name="table-header">
   <xsl:param name="table" select="/.." />
	<thead>
      <tr>
         <xsl:for-each select="$table/col">
            <xsl:variable name="value">
               <xsl:call-template name="header-cell-value">
                  <xsl:with-param name="cell" select="@value" />
               </xsl:call-template>
            </xsl:variable>
            <th>
               <span onclick="javascript:popupMenu(menu{generate-id()});" style="position: relative;">
                  <xsl:copy-of select="$value" />
                  <xsl:apply-templates select="." mode="table-header-menu" />
               </span>
            </th>   	
         </xsl:for-each>
      </tr>
   </thead>
</xsl:template>

<xsl:template name="header-cell-value">
	<xsl:param name="cell" />
   <xsl:choose>
      <xsl:when test="@label"><xsl:value-of select="@label" /></xsl:when>
      <xsl:when test="$cell = 'name()'">&#160;</xsl:when>
      <xsl:when test="starts-with($cell, '@')"><xsl:value-of select="substring-after($cell, '@')" /></xsl:when>
      <xsl:otherwise><xsl:value-of select="$cell" /></xsl:otherwise>
   </xsl:choose>
</xsl:template>

<xsl:template name="sort">
	<xsl:param name="list" select="/.." />
   <xsl:param name="sort" select="/.." />
   <xsl:variable name="list-to-sort-rtf">
   	<xsl:choose>
   		<xsl:when test="count($sort) > 1">
   			<xsl:call-template name="sort">
               <xsl:with-param name="list" select="$list" />
               <xsl:with-param name="sort" select="$sort[position() &gt; 1]" />
            </xsl:call-template>
   		</xsl:when>
   		<xsl:otherwise>
   			<xsl:copy-of select="$list" />
   		</xsl:otherwise>
   	</xsl:choose>
   </xsl:variable>
   <xsl:variable name="list-to-sort" select="msxsl:node-set($list-to-sort-rtf)" />

   <xsl:variable name="this-sort" select="$sort[1]" />
   <xsl:variable name="sort-by" select="$this-sort/@select" />
   <xsl:variable name="data-type" select="$sort/parent::table/col[@value = $sort-by]/@data-type" />
   <xsl:variable name="sort-type">
      <xsl:choose>
      	<xsl:when test="$data-type"><xsl:value-of select="$data-type" /></xsl:when>
      	<xsl:otherwise>text</xsl:otherwise>
      </xsl:choose>
   </xsl:variable>
   <xsl:variable name="order" select="$this-sort/@order" />
   <xsl:variable name="sort-order">
      <xsl:choose>
      	<xsl:when test="$order"><xsl:value-of select="$order" /></xsl:when>
      	<xsl:otherwise>ascending</xsl:otherwise>
      </xsl:choose>
   </xsl:variable>

   <xsl:choose>
   	<xsl:when test="$sort-by = 'name()'">
   		<xsl:for-each select="$list-to-sort/*">
   			<xsl:sort select="name()" order="{$sort-order}" data-type="{$sort-type}" />
            <xsl:copy-of select="." />
   		</xsl:for-each>
   	</xsl:when>
      <xsl:when test="$sort-by = '#content'">
         <xsl:for-each select="$list-to-sort/*">
         	<xsl:sort select="string(.)" order="{$sort-order}" data-type="{$sort-type}" />
            <xsl:copy-of select="." />
         </xsl:for-each>
      </xsl:when>
      <xsl:when test="starts-with($sort-by, '@')">
      	<xsl:variable name="attr" select="substring($sort-by, 2)" />
   		<xsl:for-each select="$list-to-sort/*">
   			<xsl:sort select="@*[name() = $attr]" order="{$sort-order}" data-type="{$sort-type}" />
            <xsl:copy-of select="." />
   		</xsl:for-each>
      </xsl:when>
   	<xsl:otherwise>
   		<xsl:for-each select="$list-to-sort/*">
   			<xsl:sort select="*[name() = $sort-by]" order="{$sort-order}" data-type="{$sort-type}" />
            <xsl:copy-of select="." />
   		</xsl:for-each>
   	</xsl:otherwise>
   </xsl:choose>
</xsl:template>

<xsl:template match="*" mode="serialise-for-content">
   <xsl:text />&lt;<xsl:value-of select="name()" />
   <xsl:for-each select="@*">
   	<xsl:text> </xsl:text>
      <xsl:value-of select="name()" />="<xsl:value-of select="." />"<xsl:text />
   </xsl:for-each>
   <xsl:choose>
   	<xsl:when test="* or normalize-space(.)">
         <xsl:text />&gt;...&lt;/<xsl:value-of select="name()" />&gt;<xsl:text />
      </xsl:when>
   	<xsl:otherwise> /&gt;</xsl:otherwise>
   </xsl:choose>
   <xsl:if test="position() != last()"><br /></xsl:if>
</xsl:template>

<xsl:template match="text()[normalize-space()]" mode="serialise">
   <xsl:value-of select="." />
   <xsl:if test="position() != last()"><br /></xsl:if>
</xsl:template>

<xsl:template match="*" mode="serialise">
   <xsl:text />&lt;<xsl:value-of select="name()" />
   <xsl:for-each select="@*">
   	<xsl:text> </xsl:text>
      <xsl:value-of select="name()" />="<xsl:value-of select="." />"<xsl:text />
   </xsl:for-each>
   <xsl:choose>
   	<xsl:when test="* or normalize-space(.)">
         <xsl:text />&gt;<xsl:apply-templates mode="serialise" />
         <xsl:text />&lt;/<xsl:value-of select="name()" />&gt;<xsl:text />
      </xsl:when>
   	<xsl:otherwise> /&gt;</xsl:otherwise>
   </xsl:choose>
   <xsl:if test="position() != last()"><br /></xsl:if>
</xsl:template>

</xsl:stylesheet>