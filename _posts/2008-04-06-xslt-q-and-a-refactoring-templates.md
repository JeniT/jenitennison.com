---
layout: drupal-post
excerpt_separator: "<!--break-->"
title: ! 'XSLT Q&A: Refactoring templates'
created: 1207509600
tags:
- xslt
---
A question about how to refactor some repetitive templates.

> The issue is in creating XHTML headings.  

> For a small docbook article, I have the following templates in one of my stylesheets:

<!--break-->

    <xsl:template match="article/title | article/info/title">
      <h1><xsl:apply-templates /></h1>
    </xsl:template>

    <xsl:template match="article/section/title">
      <h2><xsl:apply-templates /></h2>
    </xsl:template>

    <xsl:template match="article/section/section/title">
      <h3><xsl:apply-templates /></h3>
    </xsl:template>

    <xsl:template match="article/section/section/section/title">
      <h4><xsl:apply-templates /></h4>
    </xsl:template>

    <xsl:template match="article/section/section/section/section/title">
      <h5><xsl:apply-templates /></h5>
    </xsl:template>

    <xsl:template match="article/section/section/section/section/section/title">
      <h6><xsl:apply-templates /></h6>
    </xsl:template>

> Obviously this was a quick and (VERY) dirty way to achieve the output I wanted.

> So, I know you can do something similar with an `<xsl:choose>` and some cases, but I have a feeling there's a more automatic way.

Seek out the similarities. The last five of these templates all match `<title>` elements within a `<section>` element. They all create an XHTML heading element and apply templates to the content of the `<title>` to get the content of the heading.

Identify the differences. They're different in the level of heading that they create and in the number of ancestor `<section>` elements the `<title>` has.

Find the algorithm. Here's the mapping:

<table>
  <thead>
    <tr>
      <th>number of <code>&lt;section></code> ancestors</th>
      <th>required heading</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>1</td>
      <td>2</td>
    </tr>
    <tr>
      <td>2</td>
      <td>3</td>
    </tr>
    <tr>
      <td>3</td>
      <td>4</td>
    </tr>
    <tr>
      <td>4</td>
      <td>5</td>
    </tr>
    <tr>
      <td>5</td>
      <td>6</td>
    </tr>
  </tbody>
</table>

So the level of the heading is the number of ancestor `<section>` elements plus one.

Put it together. Get the number of ancestor `<section>` elements with `count(ancestor::section)`. Create the name of the heading element to create using an attribute value template in the `name` attribute.

    <xsl:template match="section/title">
      <xsl:variable name="nAncestorSections"
        select="count(ancestor::section)" />
      <xsl:variable name="headingLevel"
        select="$nAncestorSections + 1" />
      <xsl:element name="h{$headingLevel}">
        <xsl:apply-templates />
      </xsl:element>
    </xsl:template>

Of course there *are* differences between this refactored code and the original. In particular, this template deals improperly with the case where there are more than five nested sections, because it creates an `<h7>` element, which isn't legal. If you thought that was likely to occur, you could change how `$headingLevel` is calculated to:

    <xsl:variable name="headingLevel">
      <xsl:choose>
        <xsl:when test="$nAncestorSections >= 5">6</xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$nAncestorSections + 1" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

or:

    <xsl:variable name="headingLevel"
      select="if ($nAncestorSections >= 5)
              then 6 else $nAncestorSections + 1" />

in XSLT 2.0.

The other problem is that the template deals differently with `<title>` elements that appear within a `<section>` whose parent is neither `<article>` nor another `<section>` (which aren't matched by the original templates). There are other possible parents for `<section>` namely `<appendix>`, `<chapter>`, `<partintro>` and `<preface>`, so if these elements are likely to appear in the subset of DocBook you're using and you want the code to behave differently you need to either add more templates or some extra conditions into this one.
