<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:saxon="http://icl.com/saxon"
                xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                extension-element-prefixes="saxon msxsl">

<xsl:import href="xpath.xsl" />
<xsl:include href="function-doc.xsl" />

<xsl:param name="short-namespaces" select="'true'" />

<xsl:template match="xpath">
	<xsl:variable name="xpath-rtf">
	   <xsl:call-template name="expression">
	      <xsl:with-param name="expr" select="." />
	   </xsl:call-template>
	</xsl:variable>
   <xsl:apply-templates select="msxsl:node-set($xpath-rtf)/*" mode="explain-xpath" />
</xsl:template>

<xsl:template name="explain">
   <xsl:param name="xpath" />
   <xsl:param name="type" />
	<xsl:variable name="xpath-rtf">
      <xsl:choose>
         <xsl:when test="$type = 'pattern'">
            <xsl:call-template name="pattern">
               <xsl:with-param name="xpath" select="$xpath" />
            </xsl:call-template>
         </xsl:when>
         <xsl:when test="$type = 'avt'">
            <xsl:call-template name="avt">
               <xsl:with-param name="avt" select="$xpath" />
            </xsl:call-template>
         </xsl:when>
         <xsl:otherwise>
            <xsl:call-template name="expression">
               <xsl:with-param name="expr" select="$xpath" />
            </xsl:call-template>
         </xsl:otherwise>
      </xsl:choose>
	</xsl:variable>
   <xsl:apply-templates select="msxsl:node-set($xpath-rtf)/*" mode="explain-xpath">
      <xsl:with-param name="context" select="$type" />
   </xsl:apply-templates>
</xsl:template>

<!-- avts and patterns will always be top-level -->
<xsl:template match="avt" mode="explain-xpath">
   <xsl:choose>
      <xsl:when test="count(*) > 1">
         <xsl:text> the concatenation of:</xsl:text>
         <ul>
            <xsl:for-each select="*">
               <li>
                  <xsl:apply-templates select="." mode="explain-xpath">
                     <xsl:with-param name="context" select="'string'" />
                  </xsl:apply-templates>               
               </li>
            </xsl:for-each>
         </ul>
      </xsl:when>
      <xsl:otherwise>
         <xsl:apply-templates mode="explain-xpath">
            <xsl:with-param name="context" select="'string'" />
         </xsl:apply-templates>
      </xsl:otherwise>
   </xsl:choose>
</xsl:template>

<xsl:template match="pattern" mode="explain-xpath">
   <xsl:text> nodes matching</xsl:text>
   <xsl:apply-templates mode="explain-xpath">
      <xsl:with-param name="context" select="'pattern'" />
   </xsl:apply-templates>
</xsl:template>

<!-- expressions might be embedded -->
<xsl:template match="expr" mode="explain-xpath">
   <xsl:param name="context" />
   <xsl:apply-templates mode="explain-xpath">
      <xsl:with-param name="context" select="$context" />
   </xsl:apply-templates>
</xsl:template>

<xsl:template match="union" mode="explain-xpath">
   <xsl:param name="context" select="'node-set'" />
   <xsl:choose>
      <xsl:when test="$context = 'boolean'"> there are any nodes in the union of</xsl:when>
      <xsl:when test="$context = 'number'"> the numerical value of the first node in the union of</xsl:when>
      <xsl:when test="$context = 'string'"> the string value of the first node in the union of</xsl:when>
      <xsl:when test="$context = 'comparison'"> any of the nodes in the union of</xsl:when>
      <xsl:when test="$context = 'comparison-number'"> the numerical value of any of the nodes in the union of</xsl:when>
   </xsl:choose>
   <xsl:variable name="new-context">
      <xsl:choose>
         <xsl:when test="$context = 'pattern'">pattern</xsl:when>
         <xsl:otherwise>node-set</xsl:otherwise>
      </xsl:choose>
   </xsl:variable>
   <ul>
      <xsl:for-each select="*">
         <li>
            <xsl:apply-templates select="." mode="explain-xpath">
               <xsl:with-param name="context" select="$new-context" />
            </xsl:apply-templates>
            <xsl:if test="position() != last()">
               <span class="join">
                  <xsl:choose>
                     <xsl:when test="$context = 'pattern'"> or</xsl:when>
                     <xsl:when test="$context = 'node-set'"> unioned with</xsl:when>
                     <xsl:otherwise> and</xsl:otherwise>
                  </xsl:choose>
               </span>
            </xsl:if>
         </li>
      </xsl:for-each>
   </ul>
</xsl:template>

<xsl:template match="path" mode="explain-xpath">
   <xsl:param name="context" select="'node-set'" />
   <xsl:choose>
      <xsl:when test="context and count(step) = 1 and step[@axis = 'self']">
         <xsl:variable name="plural" select="ancestor::predicate" />
         <xsl:choose>
            <xsl:when test="$context = 'pattern'"> all</xsl:when>
            <xsl:otherwise>
               <xsl:choose>
                  <xsl:when test="$context = 'string'">
                     <xsl:choose>
                        <xsl:when test="$plural"> their</xsl:when>
                        <xsl:otherwise> its</xsl:otherwise>
                     </xsl:choose>
                     <xsl:text> string value if</xsl:text>
                  </xsl:when>
                  <xsl:when test="$context = 'number' or $context = 'comparison-number'">
                     <xsl:choose>
                        <xsl:when test="$plural"> their</xsl:when>
                        <xsl:otherwise> its</xsl:otherwise>
                     </xsl:choose>
                     <xsl:text> numerical value if</xsl:text>
                  </xsl:when>
                  <xsl:when test="$context = 'comparison'">
                     <xsl:choose>
                        <xsl:when test="$plural"> their</xsl:when>
                        <xsl:otherwise> its</xsl:otherwise>
                     </xsl:choose>
                     <xsl:text> value if</xsl:text>
                  </xsl:when>
               </xsl:choose>
               <xsl:choose>
                  <xsl:when test="$plural"> they are</xsl:when>
                  <xsl:otherwise> it is a</xsl:otherwise>
               </xsl:choose>
            </xsl:otherwise>
         </xsl:choose>
         <xsl:apply-templates select="step/*[1]" mode="explain-node-test">
            <xsl:with-param name="context">
               <xsl:choose>
                  <xsl:when test="$plural">node-set</xsl:when>
                  <xsl:otherwise>node</xsl:otherwise>
               </xsl:choose>
            </xsl:with-param>
         </xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise>
         <xsl:choose>
            <xsl:when test="$context = 'string'">
               <xsl:text> the string value of the</xsl:text>
               <xsl:if test="count(step) &gt; 1 or step/@axis != 'attribute'"> first</xsl:if>
            </xsl:when>
            <xsl:when test="$context = 'number'">
               <xsl:text> the numerical value of the</xsl:text>
               <xsl:if test="count(step) &gt; 1 or step/@axis != 'attribute'"> first</xsl:if>
            </xsl:when>
            <xsl:when test="$context = 'comparison'">
               <xsl:choose>
                  <xsl:when test="count(step) = 1 and step/@axis = 'attribute'"> the</xsl:when>
                  <xsl:otherwise> any</xsl:otherwise>
               </xsl:choose>
            </xsl:when>
            <xsl:when test="$context = 'comparison-number'">
               <xsl:text> the numerical value of</xsl:text>
               <xsl:choose>
                  <xsl:when test="count(step) = 1 and step/@axis = 'attribute'"> the</xsl:when>
                  <xsl:otherwise> any</xsl:otherwise>
               </xsl:choose>
            </xsl:when>
            <xsl:when test="$context = 'pattern' and step"> all</xsl:when>
         </xsl:choose>
         <xsl:variable name="new-context">
            <xsl:choose>
               <xsl:when test="$context = 'string' or $context = 'number'">node</xsl:when>
               <xsl:when test="$context = 'pattern'">pattern</xsl:when>
               <xsl:otherwise>node-set</xsl:otherwise>
            </xsl:choose>
         </xsl:variable>
         <xsl:choose>
            <xsl:when test="($context = 'boolean' or $context = 'predicate') and count(step) &lt;= 1">
               <xsl:apply-templates select="*[1]" mode="explain-short-xpath">
                  <xsl:with-param name="context">
                     <xsl:choose>
                        <xsl:when test="step">node-set</xsl:when>
                        <xsl:otherwise>boolean</xsl:otherwise>
                     </xsl:choose>
                  </xsl:with-param>
               </xsl:apply-templates>
               <xsl:choose>
                  <xsl:when test="not(step)">
                     <xsl:if test="context or root"> exists</xsl:if>
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:text> has a</xsl:text>
                     <xsl:apply-templates select="step" mode="explain-short-xpath">
                        <xsl:with-param name="context" select="'boolean'" />
                     </xsl:apply-templates>
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:when>
            <xsl:when test="$context != 'pattern' and 
                            (not(function) or function[@name = 'document']) and
                            (count(step[not(@axis = 'descendant-or-self' and node and not(predicate))]) = 1 or
                             not(step[predicate]))">
               <xsl:choose>
                  <xsl:when test="$context = 'predicate' and context">
                     <xsl:text> there are</xsl:text>
                     <xsl:apply-templates select="step" mode="explain-short-xpath">
                        <xsl:with-param name="context" select="$new-context" />
                     </xsl:apply-templates>
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:if test="$context = 'string' or $context = 'number' or $context = 'comparison' or $context = 'comparison-number'"> of</xsl:if>
                     <xsl:apply-templates select="*" mode="explain-short-xpath">
                        <xsl:with-param name="context" select="$new-context" />
                     </xsl:apply-templates>
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
               <xsl:if test="$context = 'boolean' or $context = 'predicate'"> there are any</xsl:if>
               <xsl:apply-templates select="*" mode="explain-xpath">
                  <xsl:sort select="position()" order="descending" />
                  <xsl:with-param name="context" select="$new-context" />
               </xsl:apply-templates>
            </xsl:otherwise>
         </xsl:choose>   
      </xsl:otherwise>
   </xsl:choose>
</xsl:template>

<xsl:template match="*" mode="explain-short-xpath">
   <xsl:param name="context" select="'node-set'" />
   <xsl:apply-templates select="." mode="explain-xpath">
      <xsl:with-param name="context" select="$context" />
   </xsl:apply-templates>
</xsl:template>

<xsl:template match="root" mode="explain-xpath">
   <xsl:param name="context" select="'node-set'" />
   <xsl:text> the root node</xsl:text>
</xsl:template>

<xsl:template match="context" mode="explain-short-xpath">
   <xsl:param name="context" select="'node-set'" />
   <xsl:choose>
      <xsl:when test="../following-sibling::step[not(@axis)]" />
      <xsl:when test="ancestor::predicate"> it</xsl:when>
      <xsl:otherwise> the current node</xsl:otherwise>
   </xsl:choose>
</xsl:template>

<xsl:template match="context" mode="explain-xpath">
   <xsl:param name="context" select="'node-set'" />
   <xsl:choose>
      <xsl:when test="../following-sibling::step[not(@axis)]" />
      <xsl:when test="$context = 'pattern' or ancestor::predicate"> the context node</xsl:when>
      <xsl:otherwise> the current node</xsl:otherwise>
   </xsl:choose>
</xsl:template>

<xsl:template match="step" mode="explain-short-xpath">
   <xsl:param name="context" select="'node-set'" />
   <xsl:choose>
      <xsl:when test="@axis = 'descendant-or-self' and child::node and not(child::predicate)" />
      <xsl:otherwise>
         <xsl:choose>
            <xsl:when test="$context = 'boolean'" />
            <xsl:when test="preceding-sibling::*[1][self::context] and parent::predicate" />
            <xsl:when test="preceding-sibling::*[1][self::context] and ancestor::predicate">s</xsl:when>
            <xsl:otherwise>&apos;s</xsl:otherwise>
         </xsl:choose>
         <xsl:apply-templates select="." mode="explain-short-axis" />
         <xsl:apply-templates select="child::*[1]" mode="explain-node-test">
            <xsl:with-param name="context">
               <xsl:choose>
                  <xsl:when test="@axis = 'attribute' and attribute[@name] and not(preceding-sibling::step)">node</xsl:when>
                  <xsl:when test="predicate[last()]/number">node</xsl:when>
                  <xsl:when test="$context = 'boolean'">node</xsl:when>
                  <xsl:otherwise>node-set</xsl:otherwise>
               </xsl:choose>
            </xsl:with-param>
         </xsl:apply-templates>
         <xsl:if test="predicate">
            <xsl:apply-templates select="." mode="explain-predicates" />
         </xsl:if>
      </xsl:otherwise>
   </xsl:choose>
</xsl:template>

<xsl:template match="step" mode="explain-xpath">
   <xsl:param name="context" select="'node-set'" />
   <xsl:choose>
      <xsl:when test="@axis = 'descendant-or-self' and child::node and not(child::predicate)" />
      <xsl:otherwise>
         <xsl:variable name="num" select="predicate[last()]/number" />
         <xsl:if test="$num">
            <xsl:text> the </xsl:text>
            <xsl:value-of select="$num" />
            <xsl:choose>
               <xsl:when test="$num mod 10 = 1">st</xsl:when>
               <xsl:when test="$num mod 10 = 2">nd</xsl:when>
               <xsl:when test="$num mod 10 = 3">rd</xsl:when>
               <xsl:otherwise>th</xsl:otherwise>
            </xsl:choose>
         </xsl:if>
         <xsl:apply-templates select="child::*[1]" mode="explain-node-test">
            <xsl:with-param name="context">
               <xsl:choose>
                  <xsl:when test="$context = 'pattern'">pattern</xsl:when>
                  <xsl:when test="@axis = 'attribute' and not(preceding-sibling::step)">node</xsl:when>
                  <xsl:when test="not(predicate[last()]/number) and following-sibling::step">node-set</xsl:when>
                  <xsl:otherwise><xsl:value-of select="$context" /></xsl:otherwise>
               </xsl:choose>
            </xsl:with-param>
         </xsl:apply-templates>
         <xsl:choose>
            <xsl:when test="predicate[not(number) or following-sibling::predicate]">
               <xsl:apply-templates select="." mode="explain-predicates" />
               <xsl:if test="preceding-sibling::* and @axis">
                  <xsl:text> and</xsl:text>
                  <xsl:apply-templates select="." mode="explain-axis" />
               </xsl:if>
            </xsl:when>
            <xsl:when test="preceding-sibling::* and @axis">
               <xsl:apply-templates select="." mode="explain-axis" />
            </xsl:when>
         </xsl:choose>
      </xsl:otherwise>
   </xsl:choose>
</xsl:template>

<xsl:template match="step" mode="explain-short-axis">
   <xsl:choose>
      <xsl:when test="preceding-sibling::step[1][@axis = 'descendant-or-self' and node and not(predicate)]"> descendant</xsl:when>
      <xsl:when test="@axis = 'descendant-or-self'"> descendant or own</xsl:when>
      <xsl:when test="@axis = 'ancestor-or-self'"> ancestor or own</xsl:when>
      <xsl:when test="@axis = 'self'"> own</xsl:when>
      <xsl:when test="@axis = 'attribute'" />
      <xsl:otherwise>
         <xsl:text> </xsl:text>
         <xsl:value-of select="translate(@axis, '-', ' ')" />
      </xsl:otherwise>
   </xsl:choose>
</xsl:template>

<xsl:template match="step" mode="explain-axis">
   <xsl:choose>
      <xsl:when test="preceding-sibling::step[1][@axis = 'descendant-or-self' and node and not(predicate)]"> that are descendants of</xsl:when>
      <xsl:when test="@axis = 'descendant-or-self'"> that are descendants of, or are themselves</xsl:when>
      <xsl:when test="@axis = 'ancestor-or-self'"> that are ancestors of, or are themselves</xsl:when>
      <xsl:when test="@axis = 'self'"> that are themselves</xsl:when>
      <xsl:when test="@axis = 'child'"> that are children of</xsl:when>
      <xsl:when test="@axis = 'preceding'"> that precede</xsl:when>
      <xsl:when test="@axis = 'following'"> that follow</xsl:when>
      <xsl:when test="@axis = 'attribute'"> on</xsl:when>
      <xsl:otherwise> are <xsl:value-of select="translate(@axis, '-', ' ')" />s of</xsl:otherwise>
   </xsl:choose>
</xsl:template>

<xsl:template match="function | var | expr" mode="explain-node-test">
   <xsl:apply-templates select="." mode="explain-xpath">
      <xsl:with-param name="context" select="'node-set'" />
   </xsl:apply-templates>
</xsl:template>

<xsl:template match="node | comment" mode="explain-node-test">
   <xsl:param name="context" select="'node-set'" />
   <xsl:text> </xsl:text>
   <xsl:value-of select="name()" />
   <xsl:if test="$context != 'node'">s</xsl:if>
</xsl:template>

<xsl:template match="text" mode="explain-node-test">
   <xsl:param name="context" select="'node-set'" />
   <xsl:text> text node</xsl:text>
   <xsl:if test="$context != 'node'">s</xsl:if>
</xsl:template>

<xsl:template match="pi" mode="explain-node-test">
   <xsl:param name="context" select="'node-set'" />
   <xsl:if test="@name"> '<xsl:value-of select="@name" />'</xsl:if>
   <xsl:text> processing instruction</xsl:text>
   <xsl:if test="$context != 'node'">s</xsl:if>
</xsl:template>

<xsl:template match="attribute" mode="explain-node-test">
   <xsl:param name="context" select="'node-set'" />
   <xsl:variable name="plural" select="$context != 'node'" />
   <xsl:choose>
      <xsl:when test="@namespace != 'any' and @namespace != 'element'">
         <xsl:choose>
            <xsl:when test="@name and $short-namespaces = 'true'">
               <xsl:text /> '<xsl:value-of select="@namespace" />:<xsl:value-of select="@name" />'<xsl:text />
               <xsl:text /> attribute<xsl:if test="$plural">s</xsl:if>
            </xsl:when>
            <xsl:otherwise>
               <xsl:if test="@name"> '<xsl:value-of select="@name" />'</xsl:if>
               <xsl:text /> attribute<xsl:if test="$plural">s</xsl:if>
               <xsl:text /> in the '<xsl:value-of select="@namespace" />' namespace<xsl:text />
            </xsl:otherwise>
         </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
         <xsl:if test="@name"> '<xsl:value-of select="@name" />'</xsl:if>
         <xsl:text /> attribute<xsl:if test="$plural">s</xsl:if>
      </xsl:otherwise>
   </xsl:choose>
</xsl:template>

<xsl:template match="element" mode="explain-node-test">
   <xsl:param name="context" select="'node-set'" />
   <xsl:variable name="plural" select="$context != 'node'" />
   <xsl:choose>
      <xsl:when test="@namespace != 'any'">
         <xsl:choose>
            <xsl:when test="@name and $short-namespaces = 'true'">
               <xsl:text> &apos;</xsl:text>
               <xsl:if test="@namespace != 'default'"><xsl:value-of select="@namespace" />:</xsl:if>
               <xsl:value-of select="@name" />&apos; element<xsl:text />
               <xsl:if test="$plural">s</xsl:if>
            </xsl:when>
            <xsl:otherwise>
               <xsl:if test="@name"> '<xsl:value-of select="@name" />'</xsl:if>
               <xsl:text /> element<xsl:if test="$plural">s</xsl:if> in the <xsl:text />
               <xsl:choose>
                  <xsl:when test="@namespace = 'default'">default</xsl:when>
                  <xsl:otherwise>'<xsl:value-of select="@namespace" />'</xsl:otherwise>
               </xsl:choose>
               <xsl:text> namespace</xsl:text>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
         <xsl:if test="@name"> '<xsl:value-of select="@name" />'</xsl:if>
         <xsl:text> element</xsl:text>
         <xsl:if test="$plural">s</xsl:if>
      </xsl:otherwise>
   </xsl:choose>
</xsl:template>

<xsl:template match="step" mode="explain-predicates">
   <xsl:variable name="predicates" select="predicate[not(number) or following-sibling::predicate]" />
   <xsl:if test="$predicates">
      <xsl:choose>
         <xsl:when test="count($predicates) > 1">
            <ol>
               <xsl:for-each select="$predicates">
                  <li>
                     <xsl:apply-templates select="." mode="explain-xpath" />
                     <xsl:if test="position() != last()"><span class="join"> and</span></xsl:if>
                  </li>
               </xsl:for-each>
            </ol>
         </xsl:when>
         <xsl:otherwise>
            <xsl:apply-templates select="$predicates" mode="explain-xpath" />
         </xsl:otherwise>
      </xsl:choose>
   </xsl:if>
</xsl:template>

<xsl:template match="predicate" mode="explain-xpath">
   <!-- predicates have a special 'predicate' context because of the special way numbers are dealt with -->
   <xsl:choose>
      <xsl:when test="number">
         <xsl:text> that are </xsl:text>
         <xsl:value-of select="number" />
         <xsl:choose>
            <xsl:when test="number mod 10 = 1">st</xsl:when>
            <xsl:when test="number mod 10 = 2">nd</xsl:when>
            <xsl:when test="number mod 10 = 3">rd</xsl:when>
            <xsl:otherwise>th</xsl:otherwise>
         </xsl:choose>
         <xsl:text> in the context node list</xsl:text>
      </xsl:when>
      <xsl:when test="count(*) = 1 and function[@name = 'last']">
         <xsl:text> that are last in the current node list</xsl:text>
      </xsl:when>
      <xsl:when test="plus or minus or times or div or mod or
                      function[@name = 'number'] or 
                      function[@name = 'sum'] or function[@name = 'sum'] or
                      function[@name = 'floor'] or function[@name = 'ceiling'] or
                      function[@name = 'round']">
         <xsl:text> that have a position equal to</xsl:text>
         <xsl:apply-templates mode="explain-xpath">
            <xsl:with-param name="context" select="'predicate'" />
         </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="path/context and count(path/step) = 1">
         <xsl:choose>
            <xsl:when test="path/step/expr/union">
               <xsl:text> for which there are any nodes in the set of</xsl:text>
               <xsl:apply-templates select="path/step" mode="explain-xpath">
                  <xsl:with-param name="context" select="'node-set'" />
               </xsl:apply-templates>
            </xsl:when>
            <xsl:when test="path/step/@axis = 'self'">
               <xsl:text> that are</xsl:text>
               <xsl:apply-templates select="path/step/*[1]" mode="explain-node-test">
                  <xsl:with-param name="context" select="'node-set'" />
               </xsl:apply-templates>
            </xsl:when>
            <xsl:otherwise>
               <xsl:text> that have a</xsl:text>
               <xsl:apply-templates select="path/step" mode="explain-short-axis" />
               <xsl:apply-templates select="path/step/*[1]" mode="explain-node-test">
                  <xsl:with-param name="context" select="'node'" />
               </xsl:apply-templates>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:when>
      <xsl:when test="function[@name = 'not']/arg/path[context and count(step) = 1]/step[not(expr)]">
         <xsl:choose>
            <xsl:when test="function/arg/path/step/@axis = 'self'">
               <xsl:text> that are not</xsl:text>
               <xsl:apply-templates select="function/arg/path/step/*[1]" mode="explain-node-test">
                  <xsl:with-param name="context" select="'node-set'" />
               </xsl:apply-templates>
            </xsl:when>
            <xsl:otherwise>
               <xsl:text> that do not have a</xsl:text>
               <xsl:apply-templates select="function/arg/path/step" mode="explain-short-axis" />
               <xsl:apply-templates select="function/arg/path/step/*[1]" mode="explain-node-test">
                  <xsl:with-param name="context" select="'node'" />
               </xsl:apply-templates>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
         <xsl:text> for which</xsl:text>
         <xsl:apply-templates mode="explain-xpath">
            <xsl:with-param name="context" select="'predicate'" />
         </xsl:apply-templates>
      </xsl:otherwise>
   </xsl:choose>
</xsl:template>

<xsl:template match="plus | minus | times | div | mod" mode="explain-xpath">
   <xsl:param name="context" select="'number'" />
   <xsl:choose>
      <xsl:when test="$context = 'string'"> the string value of the number</xsl:when>
      <xsl:when test="$context = 'boolean'"> the boolean value of the number</xsl:when>
   </xsl:choose>
   <xsl:variable name="join">
      <xsl:text> </xsl:text>
      <span class="join">
         <xsl:choose>
            <xsl:when test="self::div"> divided by</xsl:when>
            <xsl:otherwise>
               <xsl:text> </xsl:text>
               <xsl:value-of select="local-name()" />
            </xsl:otherwise>
         </xsl:choose>
      </span>
   </xsl:variable>
   <ul>
      <xsl:for-each select="*">
         <li>
            <xsl:apply-templates select="." mode="explain-xpath">
               <xsl:with-param name="context" select="'number'" />
            </xsl:apply-templates>
            <xsl:if test="position() != last()">
               <xsl:copy-of select="$join" />
            </xsl:if>
         </li>
      </xsl:for-each>
   </ul>
</xsl:template>

<xsl:template match="lt | lteq | gt | gteq" mode="explain-xpath">
   <xsl:param name="context" select="'boolean'" />
   <xsl:choose>
      <xsl:when test="$context = 'string'"> the string value ('true' or 'false') of the test</xsl:when>
      <xsl:when test="$context = 'number'"> the numerical value (0 or 1) of the test</xsl:when>
   </xsl:choose>
   <xsl:variable name="join">
      <xsl:text> </xsl:text>
      <span class="join">
         <xsl:choose>
            <xsl:when test="self::lt"> is less than</xsl:when>
            <xsl:when test="self::gt"> is greater than</xsl:when>
            <xsl:when test="self::lteq"> is less than or equal to</xsl:when>
            <xsl:when test="self::gteq"> is greater than or equal to</xsl:when>
         </xsl:choose>
      </span>
   </xsl:variable>
   <ul>
      <xsl:for-each select="*">
         <li>
            <xsl:apply-templates select="." mode="explain-xpath">
               <xsl:with-param name="context" select="'comparison-number'" />
            </xsl:apply-templates>
            <xsl:if test="position() != last()">
               <xsl:copy-of select="$join" />
            </xsl:if>
         </li>
      </xsl:for-each>
   </ul>
</xsl:template>

<xsl:template match="neg" mode="explain-xpath">
   <xsl:param name="context" select="'number'" />
   <xsl:choose>
      <xsl:when test="$context = 'string'"> the string value of</xsl:when>
      <xsl:when test="$context = 'boolean'"> the boolean value of</xsl:when>
   </xsl:choose>
   <xsl:text> negative</xsl:text>
   <xsl:apply-templates mode="explain-xpath">
      <xsl:with-param name="context" select="'number'" />
   </xsl:apply-templates>
</xsl:template>

<xsl:template match="eq | neq" mode="explain-xpath">
   <xsl:param name="context" select="'boolean'" />
   <xsl:choose>
      <xsl:when test="$context = 'number'"> the numerical value (0 or 1) of the test</xsl:when>
      <xsl:when test="$context = 'string'"> the string value ('true' or 'false') of the test</xsl:when>
   </xsl:choose>
   <xsl:variable name="join">
      <xsl:text> </xsl:text>
      <span class="join">
         <xsl:choose>
            <xsl:when test="self::eq"> equals</xsl:when>
            <xsl:when test="self::neq"> is not equal to</xsl:when>
         </xsl:choose>
      </span>
   </xsl:variable>
   <ul>
      <xsl:for-each select="*">
         <li>
            <xsl:apply-templates select="." mode="explain-xpath">
               <xsl:with-param name="context" select="'comparison'" />
            </xsl:apply-templates>
            <xsl:if test="position() != last()">
               <xsl:copy-of select="$join" />
            </xsl:if>
         </li>
      </xsl:for-each>
   </ul>
</xsl:template>

<xsl:template match="and | or" mode="explain-xpath">
   <xsl:param name="context" select="'boolean'" />
   <xsl:choose>
      <xsl:when test="$context = 'number'"> the numerical value (0 or 1) of the test</xsl:when>
      <xsl:when test="$context = 'string'"> the string value ('true' or 'false') of the test</xsl:when>
   </xsl:choose>
   <xsl:variable name="join">
      <xsl:text> </xsl:text>
      <span class="join">
         <xsl:value-of select="local-name()" />
      </span>
   </xsl:variable>
   <xsl:variable name="list-type">
      <xsl:choose>
         <xsl:when test="self::and">ol</xsl:when>
         <xsl:otherwise>ul</xsl:otherwise>
      </xsl:choose>
   </xsl:variable>
   <xsl:element name="{$list-type}">
      <xsl:for-each select="*">
         <li>
            <xsl:apply-templates select="." mode="explain-xpath">
               <xsl:with-param name="context" select="'boolean'" />
            </xsl:apply-templates>
            <xsl:if test="position() != last()">
               <xsl:copy-of select="$join" />
            </xsl:if>
         </li>
      </xsl:for-each>
   </xsl:element>
</xsl:template>

<xsl:template match="var" mode="explain-xpath">
   <xsl:param name="context" />
   <xsl:choose>
      <xsl:when test="$context = 'number' or $context = 'comparison-number'"> the numerical value of</xsl:when>
      <xsl:when test="$context = 'node-set'"> the nodes held by</xsl:when>
      <xsl:when test="not($context = 'boolean' or $context = 'comparison') and not(($context = 'node' or $context = 'node-set') and following-sibling::step)">
         <xsl:text> the </xsl:text>
         <xsl:value-of select="$context" />
         <xsl:text> value of</xsl:text>
      </xsl:when>
   </xsl:choose>
   <xsl:text> the</xsl:text>
   <xsl:call-template name="explain-variable">
      <xsl:with-param name="variable-name" select="@name" />
   </xsl:call-template>
   <xsl:text> variable</xsl:text>
   <xsl:if test="$context = 'boolean' or $context = 'predicate'"> is true, a result tree fragment, a non-empty string, a non-zero number or a non-empty node set</xsl:if>
</xsl:template>

<xsl:template name="explain-variable">
   <xsl:param name="variable-name" />
   <xsl:text /> '<xsl:value-of select="$variable-name" />'<xsl:text />
</xsl:template>

<xsl:template match="function" mode="explain-xpath">
   <xsl:param name="context" />
   <xsl:text> the</xsl:text>
   <xsl:choose>
      <xsl:when test="$context = 'predicate'"> numerical or boolean</xsl:when>
      <xsl:when test="$context = 'number'"> numerical</xsl:when>
      <xsl:otherwise>
         <xsl:text> </xsl:text>
         <xsl:value-of select="$context" />
      </xsl:otherwise>
   </xsl:choose>
   <xsl:text> result of calling the function</xsl:text>
   <xsl:text /> '<xsl:value-of select="@name" />'<xsl:text />
   <xsl:if test="arg">
      <xsl:choose>
         <xsl:when test="count(arg) > 1">
            <xsl:text> with the arguments:</xsl:text>
            <ul>
               <xsl:for-each select="arg">
                  <li>
                     <xsl:if test="path">
                        <xsl:text> the node-set comprising</xsl:text>
                     </xsl:if>
                     <xsl:apply-templates select="*" mode="explain-xpath" />
                     <xsl:choose>
                        <xsl:when test="position() = last() - 1"> and</xsl:when>
                        <xsl:when test="position() != last()">, </xsl:when>
                     </xsl:choose>
                  </li>
               </xsl:for-each>
            </ul>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text> with an argument of</xsl:text>
            <xsl:if test="arg/path"> the node-set comprising</xsl:if>
            <xsl:apply-templates select="arg/*" mode="explain-xpath" />
         </xsl:otherwise>
      </xsl:choose>
   </xsl:if>
</xsl:template>

<xsl:template match="string" mode="explain-xpath">
   <xsl:param name="context" select="'string'" />
   <xsl:choose>
      <xsl:when test="$context = 'number'">
         <xsl:text> the numerical value of '</xsl:text>
         <xsl:value-of select="." />
         <xsl:text />' (<xsl:value-of select="number(.)" />)<xsl:text />
      </xsl:when>
      <xsl:when test="$context = 'boolean'">
         <xsl:text> the boolean value of '</xsl:text>
         <xsl:value-of select="." />
         <xsl:text />' (<xsl:value-of select="boolean(.)" />)<xsl:text />
      </xsl:when>
      <xsl:otherwise> '<xsl:value-of select="." />'</xsl:otherwise>
   </xsl:choose>
</xsl:template>

<xsl:template match="number" mode="explain-xpath">
   <xsl:param name="context" select="'number'" />
   <xsl:choose>
      <xsl:when test="$context = 'string'">
         <xsl:text> the string value of </xsl:text>
         <xsl:value-of select="." />
         <xsl:text /> ('<xsl:value-of select="string(.)" />')<xsl:text />
      </xsl:when>
      <xsl:when test="$context = 'boolean'">
         <xsl:text> the boolean value of </xsl:text>
         <xsl:value-of select="." />
         <xsl:text /> (<xsl:value-of select="boolean(.)" />)<xsl:text />
      </xsl:when>
      <xsl:otherwise>
         <xsl:text> </xsl:text>
         <xsl:value-of select="." />
      </xsl:otherwise>
   </xsl:choose>
</xsl:template>

</xsl:stylesheet>