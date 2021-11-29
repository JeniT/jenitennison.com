---
layout: drupal-post
excerpt_separator: "<!--break-->"
title: Matching templates, named templates or for-each? My rules of thumb
created: 1178055117
tags:
- xslt
---
More rules of thumb: these are about when to use matching templates, when to use named templates, and when to use for-each. These have as much bearing in XSLT 1.0 as they do in XSLT 2.0.

<!--break-->

My rules of thumb are:

 *  If the code depends on the context position (`position()`), put it in a `<xsl:for-each>`.
 *  If the code depends on the context node (`.` or any location path), put it in a matching template.
 *  Otherwise, use a named template.

It's easiest to debug and maintain a block of code if those factors that have an effect on its functionality are in close proximity to that block of code. Context position is affected by exactly which nodes are selected, and whether they're sorted. For example, if you add commas between author names with

    <xsl:template match="author/name">
      <xsl:apply-templates />
      <xsl:if test="position() != last()">, </xsl:if>
    </xsl:template>

then you can't know (just by looking at the template) when the commas will actually be added, because it all depends on how the template is invoked. It will work fine when you do

    <xsl:apply-templates select="author/name" />

(because the sequence of nodes being processed contains the `<name>` elements) but say that six months later, someone else decided to add a `<span>` around the author information, with the template

    <xsl:template match="author">
      <span class="author">
        <xsl:apply-templates select="name" />
      </span>
    </xsl:template>

and changed the original `<xsl:apply-templates>` to

    <xsl:apply-templates select="author" />

Assuming each `<author>` has only one `<name>`, both context position and size in the original `author/name` template will always be `1`, and they will no longer get any commas.

So, I think it's better to use `<xsl:for-each>` when you have tests on position, for example

    <xsl:for-each select="author/name">
      <xsl:apply-templates select="." />
      <xsl:if test="position() != last()">, </xsl:if>
    </xsl:for-each>

With this code, you can change the `select` on the `<xsl:for-each>` and the commas will still be added.

Similarly, I hate having to debug named templates that use the context node. The only way of finding out what the context node is (and therefore whether the location paths in the template are correct) is to examine all the `<xsl:call-template>` instructions that call that template, which can be really tedious. At least with a matching template, you know the kinds of nodes that the template might be used on. For example, rather than

    <xsl:template name="CreateTOCentry">
      <xsl:call-template name="CreateTOCnumber" />
      <xsl:call-template name="CreateTOCtitle" />
    </xsl:template>

I prefer

    <xsl:template match="part | chapter | section" mode="TOC">
      <xsl:apply-templates select="number" mode="TOC" />
      <xsl:apply-templates select="title" mode="TOC" />
    </xsl:template>

I can look up the definitions of `<part>`, `<chapter>` and `<section>` to make sure that they have `<number>` and `<title>` children.

Another pattern I see is named templates that contain a big `<xsl:choose>` instruction that tests what the context node is; the code would be much better split into separate templates with different match patterns for the different kinds of nodes.

Of course sometimes you need to use a named template because you need to recurse, but want to use information about the context node, either to provide a default value for a parameter or within the body of the template itself. A really stupid example is

    <xsl:template name="CopyNode">
      <xsl:param name="n" select="1" />
      <xsl:if test="$n > 0">
        <xsl:copy-of select="." />
        <xsl:call-template name="CopyNode">
          <xsl:with-param name="n" select="$n - 1" />
        </xsl:call-template>
      </xsl:if>
    </xsl:template>

In these cases, I either pass the node in as an additional (required) parameter, as in

    <xsl:template name="CopyNode">
      <xsl:param name="node" />
      <xsl:param name="n" select="1" />
      <xsl:if test="$n > 0">
        <xsl:copy-of select="$node" />
        <xsl:call-template name="CopyNode">
          <xsl:with-param name="node" select="$node" />
          <xsl:with-param name="n" select="$n - 1" />
        </xsl:call-template>
      </xsl:if>
    </xsl:template>

(there's no way of saying the `$node` parameter is required in XSLT 1.0, so defaulting it to an empty string is the best we can do) or make the template a matching template as well

    <xsl:template match="*" mode="CopyNode" name="CopyNode">
      <xsl:param name="n" select="1" />
      <xsl:if test="$n > 0">
        <xsl:copy-of select="." />
        <xsl:call-template name="CopyNode">
          <xsl:with-param name="n" select="$n - 1" />
        </xsl:call-template>
      </xsl:if>
    </xsl:template>

and only invoke it with `<xsl:apply-templates>`. I don't really care that the match pattern doesn't tell me anything special about the node being copied: the fact that it's a general pattern tells me that it's a template that is designed to work with any element.
