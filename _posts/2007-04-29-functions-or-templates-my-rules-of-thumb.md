---
layout: drupal-post
excerpt_separator: "<!--break-->"
title: Functions or templates? My rules of thumb
created: 1177841512
tags:
- xslt
---
In [XSLT 2.0][1], functions and templates have very similar behaviour: both can accept arguments/parameters and return sequences of any kind. The difference is in how they're called: functions can be called concisely from within expressions and patterns, and arguments are passed by position; whereas templates have to be called using [`<xsl:call-template>`][1], and parameters are passed by name. Also, there's no context node for functions, but there is one for templates. I've built up some rules of thumb about which to use when:

[1]: http://www.w3.org/TR/xslt20 "XSLT 2.0 spec"
[2]: http://www.w3.org/TR/xslt20/#named-templates "XSLT 2.0 spec: Named Templates"

<!--break-->

 *  Use functions to return sequences of atomic values, because their results are often used as arguments to further functions.
 *  Use functions to return sequences of existing nodes, because you can call them in the middle of a location path in order to navigate the source document.
 *  Use templates (and matching templates as much as possible) to return new nodes.

There is one special situation, though, where I use templates to return atomic values or existing nodes, and that's when the value that's returned depends on a single node. In this case, I define a function that accepts the node as one of its arguments and applies templates to that node, in a mode named after the function name. Then I have a number of matching templates in that mode, returning the relevant value for the different kinds of node.

A really simple example is a `xhtml:is-heading()` function, which returns true for `<h1>`, `<h2>`, `<h3>` and so on, and false otherwise. Here's the definition:

    <xsl:function name="xhtml:is-heading" as="xs:boolean">
      <xsl:param name="element" as="element()" />
      <xsl:apply-templates select="$element" mode="xhtml:is-heading" />
    </xsl:function>

    <xsl:template match="xhtml:h1 | xhtml:h2 | xhtml:h3 | xhtml:h4 | xhtml:h5 | xhtml:h6"
      mode="xhtml:is-heading" as="xs:boolean">
      <xsl:sequence select="true()" />
    </xsl:template>

    <xsl:template match="*" mode="xhtml:is-heading" as="xs:boolean">
      <xsl:sequence select="false()" />
    </xsl:template>

A more complex example is this one, which gathers all the function definitions in a given namespace in a stylesheet:

    <xsl:function name="xsl:function-definitions" as="element(xsl:function)*">
      <xsl:param name="stylesheet" as="node()" />
      <xsl:param name="namespace" as="xs:string" />
      <xsl:apply-templates select="$stylesheet" mode="xsl:function-definitions">
        <xsl:with-param name="namespace" tunnel="yes" />
      </xsl:apply-templates>
    </xsl:function>

    <xsl:template match="xsl:stylesheet | xsl:transform" mode="xsl:function-definitions"
      as="element(xsl:function)*">
      <xsl:apply-templates mode="xsl:function-definitions" />
    </xsl:template>

    <xsl:template match="xsl:function" mode="xsl:function-definitions" 
      as="element(xsl:function)*">
      <xsl:param name="namespace" tunnel="yes" as="xs:string" />
      <xsl:variable name="qname" as="xs:QName" select="resolve-QName(@name, .)" />
      <xsl:if test="$namespace = namespace-uri-from-QName($qname)">
        <xsl:sequence select="." />
      </xsl:if>
    </xsl:template>

    <xsl:template match="xsl:include | xsl:import" mode="xsl:function-definitions"
      as="element(xsl:function)*">
      <xsl:param name="namespace" tunnel="yes" as="xs:string" />
      <xsl:sequence select="xsl:function-definitions(document(@href), $namespace)" />
    </xsl:template>

    <xsl:template match="*" mode="xsl:function-definitions" />

(Note that this code will give you overridden definitions from imported stylesheets: if you don't want those then you need to modify the template matching `xsl:stylesheet | xsl:transform`.)

What I like about this pattern is that it maintains the function interface for calling the code while breaking down what would otherwise be a big `<xsl:choose>` into pieces of code that are individually manageable and testable. Also, it means I can take advantage of some of the useful features of XSLT template matching, such as the built-in templates and priorities. And it means that the function can be customised very easily by adding or overriding templates in an importing stylesheet. On the downside, it's that much longer than the code would otherwise be, and, as always with XSLT, debugging through matching templates can be challenging.

This pattern gives you polymorphic functions -- in the form of different templates for different node types -- at least for one node argument. There are also associations for me here with object-oriented coding (think of the function definition as an abstract method, the mode as a method name and the node as an object instance). Anyway, I thought it worth sharing.
