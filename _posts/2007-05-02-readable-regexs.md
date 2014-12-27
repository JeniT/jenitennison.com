---
layout: drupal-post
title: Readable regexs
created: 1178112235
tags:
- xslt
---
Excellent post on [XSL-List][1] by Abel Braaksma on [creating readable regex expressions][2] in XSLT 2.0. He suggests always defining regular expressions in the content of a `<xsl:variable>`,  using normal XML comments to annotate the different parts of the regex, and then using the `x` flag to ignore the extraneous whitespace that you've introduced.

[1]: http://www.mulberrytech.com/xsl/xsl-list/ "XSL-List information"
[2]: http://www.biglist.com/lists/xsl-list/archives/200705/msg00022.html "Re: [xsl] How to split an RegEx into several lines for readability?"

<!--break-->

Here's a full example. Say that you want to parse a UK date. You could do:

    <xsl:variable name="UKdate" as="xs:string">
      ([0-9]{,2})      <!-- group 1 holds the day: one or two digits -->
      /                <!-- separator -->
      ([0-9]{,2})      <!-- group 2 holds the month: one or two digits -->
      /                <!-- separator -->
      ([0-9]{2})       <!-- group 3 holds the year: two digits -->
    </xsl:variable>

The variable is set to a string with lots of whitespace in it. The comments are, of course, ignored (when the XSLT stylesheet is initially compiled).

Then when you want to use the regular expression, use the `x` flag. This ignores all whitespace in the regular expression. For example:

    <xsl:if test="matches(@date, $UKdate, 'x')">
      <xsl:analyze-string select="@date" regex="{$UKdate}" flags="x">
        ...
      </xsl:analyze-string>
    </xsl:if>

(I know I don't need to do the `<xsl:if>`, I'm just trying to show how you'd use the regular expression in a function call as well.)

Even if you don't want to document your regular expressions (David C.), it's a good idea to define them in variables. I've been caught out a number of times accidentally doing something like:

    <xsl:analyze-string select="$n" regex="[0-9]{2}">
      ...
    </xsl:analyze-string>

which of course matches any two digit number where the second digit is a `2`. (The problem's that the `regex` attribute value template, so the `{}`s are replaced by the result of evaluating their content, leaving the regular expression `[0-9]2`.) Using the content of an `<xsl:variable>` is a good idea as well, because it means you don't have to escape quotes and apostrophes: regex syntax is enough of a headache without worrying about extra levels of escaping.
