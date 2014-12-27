<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	exclude-result-prefixes="xs"
	xmlns:f="http://www.jenitennison.com/xslt/fragmentation">

<xsl:key name="f:fragments" match="*[@f:id]" use="@f:id" />

<xsl:function name="f:swap" as="element()">
  <xsl:param name="elem" as="element()" />
  <xsl:param name="trees" as="xs:string+" />
  <xsl:sequence select="f:swap($elem, $trees, $elem)" />
</xsl:function>

<!-- This swaps the whole tree, but returns the first node that's equivalent
	   to this one -->
<xsl:function name="f:swap" as="element()">
  <xsl:param name="elem" as="element()" />
	<xsl:param name="trees" as="xs:string+" />
  <xsl:param name="pivot" as="node()" />
	<xsl:variable name="id" as="xs:string" 
	  select="if ($elem/@f:id) then $elem/@f:id else generate-id($elem)" />
	<xsl:variable name="flat" as="node()+">
	  <xsl:variable name="pivot-ancestors" as="element()*"
	    select="$pivot/ancestor-or-self::*" />
	  <xsl:for-each select="$pivot//text()">
			<xsl:variable name="ancestors" as="element()*">
				<xsl:perform-sort select="ancestor::* except $pivot-ancestors">
					<!-- sort those in the tree before those not in the tree -->
					<xsl:sort select="empty(f:in-trees(., $trees))" />
				  <!-- then sort by the index of the tree -->
				  <xsl:sort select="f:in-trees(., $trees)" />
					<!-- sort those with the greatest length first -->
					<xsl:sort select="f:length(.)" order="descending" />
				</xsl:perform-sort>
			</xsl:variable>
			<xsl:call-template name="f:nest">
				<xsl:with-param name="text" select="." />
				<xsl:with-param name="ancestors" select="$ancestors" />
			</xsl:call-template>
		</xsl:for-each>
	</xsl:variable>
	<xsl:variable name="nested" as="node()+">
		<xsl:call-template name="f:group">
			<xsl:with-param name="flat" select="$flat" />
			<xsl:with-param name="trees" select="$trees" />
		</xsl:call-template>
	</xsl:variable>
  <xsl:variable name="embedded" as="document-node()">
    <xsl:apply-templates select="$elem/root()" mode="f:embed">
      <xsl:with-param name="pivot" tunnel="yes" select="$pivot" />
      <xsl:with-param name="subtree" tunnel="yes" select="$nested" />
    </xsl:apply-templates>
  </xsl:variable>
  <xsl:variable name="newpivot" as="node()"
    select="if ($pivot instance of document-node()) 
            then $embedded 
            else $embedded//*[@f:pivot]" />
	<xsl:sequence select="key('f:fragments', $id, $newpivot)[1]" />
</xsl:function>

<xsl:template name="f:group">
	<xsl:param name="flat" as="node()*" required="yes" />
	<xsl:param name="trees" as="xs:string+" required="yes" />
	<xsl:for-each-group select="$flat" group-adjacent="if (exists(@f:id)) then @f:id else ''">
		<xsl:choose>
			<xsl:when test=". instance of text()">
				<xsl:copy-of select="." />
			</xsl:when>
			<xsl:when test="f:in-trees(., $trees) > 0">
				<xsl:copy>
					<xsl:copy-of select="@* except @f:pivot" />
					<xsl:call-template name="f:group">
						<xsl:with-param name="flat" select="current-group()/node()" />
						<xsl:with-param name="trees" select="$trees" />
					</xsl:call-template>
				</xsl:copy>
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="current-group()" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:for-each-group>
</xsl:template>

<xsl:template name="f:nest">
	<xsl:param name="text" required="yes" as="text()" />
	<xsl:param name="ancestors" required="yes" as="element()*" />
	<xsl:choose>
		<xsl:when test="exists($ancestors)">
			<xsl:for-each select="$ancestors[1]">
				<xsl:copy>
					<xsl:attribute name="f:id" select="generate-id()" />
					<xsl:copy-of select="@* except @f:pivot" />
					<xsl:call-template name="f:nest">
						<xsl:with-param name="text" select="$text" />
						<xsl:with-param name="ancestors" select="subsequence($ancestors, 2)" />
					</xsl:call-template>
				</xsl:copy>
			</xsl:for-each>
		</xsl:when>
		<xsl:otherwise>
			<xsl:copy-of select="$text" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="document-node() | node()" mode="f:embed">
  <xsl:param name="pivot" tunnel="yes" as="node()" required="yes" />
  <xsl:param name="subtree" tunnel="yes" as="node()+" required="yes" />
  <xsl:copy>
    <xsl:if test=". instance of element()">
      <xsl:attribute name="f:id" select="generate-id()" />
      <xsl:copy-of select="@* except @f:pivot" />
    </xsl:if>
    <xsl:choose>
      <xsl:when test=". is $pivot">
        <xsl:if test=". instance of element()">
          <xsl:attribute name="f:pivot" select="true()" />
        </xsl:if>
        <xsl:sequence select="$subtree" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates mode="f:embed" />
      </xsl:otherwise>
    </xsl:choose>
   </xsl:copy>
</xsl:template>

<xsl:function name="f:length" as="xs:integer">
	<xsl:param name="elem" as="element()" />
	<xsl:variable name="text" as="text()*"
		select="if ($elem/@f:id) 
		        then key('f:fragments', $elem/@f:id, $elem/root())//text()
		        else $elem//text()" />
	<xsl:sequence select="sum($text/string-length(.))" />
</xsl:function>

<xsl:function name="f:first" as="xs:boolean">
	<xsl:param name="elem" as="element()" />
	<xsl:sequence select="empty($elem/@f:id) or key('f:fragments', $elem/@f:id, $elem/root())[1] is $elem" />
</xsl:function>

<xsl:function name="f:last" as="xs:boolean">
  <xsl:param name="elem" as="element()" />
  <xsl:sequence select="empty($elem/@f:id) or key('f:fragments', $elem/@f:id, $elem/root())[last()] is $elem" />
</xsl:function>

<xsl:function name="f:in-trees" as="xs:integer?">
	<xsl:param name="elem" as="element()" />
	<xsl:param name="trees" as="xs:string+" />
  <xsl:variable name="elem-trees" as="xs:string*"
    select="tokenize($elem/@f:trees, '\s+')" />
  <xsl:variable name="tree" as="xs:string?"
    select="$trees[. = $elem-trees][1]" />
	<xsl:sequence select="if (empty($tree)) then () else index-of($trees, $tree)" />
</xsl:function>

</xsl:stylesheet>
