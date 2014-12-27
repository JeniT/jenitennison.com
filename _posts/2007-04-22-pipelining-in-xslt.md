---
layout: drupal-post
title: Pipelining in XSLT
created: 1177277330
tags:
- xslt
- pipelines
---
I took on a long-term contract back in January which is good fun (of course I have to say that; my boss might read this) and pretty challenging.

First, I'm hobbled by having to use XSLT 1.0 (MSXML, what's more). I hadn't really realised either how fantastic XSLT 2.0 is, nor how used to it I've become, until I started this work. How I miss user-defined functions, sequence constructors and `if` expressions.

Second, my task is to take some XHTML generated from WordprocessingML and (a) turn all the CSS styling relative, so that it uses ems and percentages all over the place rather than points and (b) rationalise the CSS so that common styling appears in the `<head>` of the XHTML rather than on individual elements.

<!--break-->

Now I hesitate to say that something is impossible in out-of-the-box XSLT 1.0, but I have developed a sense of when something is impractical. Here, to rationalise styles, we're looking at grouping (elements) with a calculated value (their inherited style). That would be OK in XSLT 2.0, with `<xsl:for-each-group>` and user-defined functions, but in XSLT 1.0 it means code that is hard to write and impossible to maintain.

The good news? I'm allowed to use `msxsl:node-set()`, and that means I can use a pipeline. I can break down the complex process into simple steps, such as:

 *  turn CSS declarations into attributes
 *  inherit declarations from element and class rules down to individual elements
 *  inherit declarations down the tree, so that child elements inherit undefined inheritable properties from their parent
 *  inherit declarations *up* the tree, so that parent elements have declarations that are common to their children
 *  convert those properties that can take relative values into relative values
 *  update existing and create new class definitions for combinations of declarations that are used many times in the document
 *  remove declarations that are inherited from element and class rules or from parent elements
 *  remove elements that don't have any new declarations
 *  turn attributes back into CSS declarations

In my stylesheet, I have a different mode for each step. I can capture the result of processing a document in that mode in a result tree fragment, then convert that into a new document using `msxsl:node-set()`, and process that document. I end up with lots of variable declarations like:

    <xsl:variable name="inheritedDeclarations">
      <xsl:apply-templates select="msxsl:node-set($declarationsAsAttributes)"
        mode="inheritDeclarations" />
    </xsl:variable>

The trouble with this is that it's hard to modify the pipeline and you have to make up unique names for each intermediate variable, which is such a challenge that they end up with meaningless names. So I created a mini pipeline definition in the stylesheet:

    <my:pipeline>
      <my:step mode="styleToAttributes" />
      <my:step mode="inheritDeclarations" />
      ...
    </my:pipeline>

and then process it with a template similar to the following:

    <xsl:template name="processPipeline">
      <xsl:param name="steps" select="document('')/*/my:pipeline/my:step" />
      <xsl:param name="source" select="/" />
      <xsl:choose>
        <xsl:when test="$steps">
          <xsl:variable name="mode" select="$steps[1]/@mode" />
          <xsl:variable name="result">
            <xsl:choose>
              <xsl:when test="$mode = 'styleToAttributes'">
                <xsl:apply-templates select="$source" mode="styleToAttributes" />
              </xsl:when>
              <xsl:when test="$mode = 'inheritDeclarations'">
                <xsl:apply-templates select="$source" mode="inheritDeclarations" />
              </xsl:when>
              ...
            </xsl:choose>
          </xsl:variable>
          <xsl:call-template name="processPipeline">
            <xsl:with-param name="steps" select="$steps[position() > 1]" />
            <xsl:with-param name="source" select="msxsl:node-set($result)" />
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:copy-of select="$document" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:template>

I have to modify the `processPipeline` template each time I introduce a new step, but dropping, repeating, or reordering the steps in my pipeline is very easy: I just change the pipeline definition by removing, copying or moving the `<my:step>` elements.

(You can use the same template in other XSLT 1.0 processors by changing the `msxsl:node-set()` call into the version of the function used by your processor. And you can use the same code in XSLT 2.0 by just dropping the call to `msxsl:node-set()` altogether, though I'd also change the `<xsl:copy-of>` to a `<xsl:sequence>` to prevent unnecessary node creation.)

The only thing that bugs me about this approach is the performance: creating so many nodes seems wasteful, especially when many are straight-forward copies of existing nodes. Now that I understand better what the stylesheet needs to do, perhaps I can merge some of the step together. In any case, in the environment I'm writing for, performance isn't a particularly big issue.

Of course what I *really* want is [XProc][1] to be finished and implemented (and adopted by the company I'm working for). Several of the steps I'm using could be streamed and might be better implemented in something other than XSLT. But at least breaking down my transformation in this way has made it easier (possible!) to write, more manageable, and more amenable to migration to a proper pipeline in the future.

[1]: http://www.w3.org/TR/xproc "XML Pipeline Language"
