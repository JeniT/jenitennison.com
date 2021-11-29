---
layout: drupal-post
excerpt_separator: "<!--break-->"
title: Unicode database in XML
created: 1179173483
tags:
- unicode
- xml
---
Whatever [algorithm][1] you use to [calculate Levenshtein distance][2], one of its great features is that you can tweak the cost of letter substitutions. For example, you can do a case-insensitive comparison of two strings, or perhaps more interestingly a semi-case-sensitive comparison of two strings, where the cost of replacing a character for its upper or lower case equivalent is less than the cost of replacing a character with an unrelated character, but more than zero. But that requires knowledge of whether and how two characters are related.

Of course all that information is stored in the [Unicode Database][3], which are a bunch of text files in a structured format. I looked for an XML version but couldn't find one (well, Googling "Unicode database XML" isn't much help). So I downloaded [UnicodeData.txt][4] and [NamesList.txt][5] and put together an [XSLT 2.0 stylesheet][7] to create an [XML version of the Unicode database][6].

[1]: http://www.jenitennison.com/blog/node/12 "Levenshtein distance on the diagonal"
[2]: http://www.jenitennison.com/blog/node/11 "Levenshtein distance in XSLT 2.0"
[3]: http://www.unicode.org/Public/UNIDATA/ "Unicode Database directory"
[4]: http://www.unicode.org/Public/UNIDATA/UnicodeData.txt "Unicode Database"
[5]: http://www.unicode.org/Public/UNIDATA/NamesList.txt "Unicode Names List Database"
[6]: http://www.jenitennison.com/blog/files/unicode.zip "Unicode XML"
[7]: http://www.jenitennison.com/blog/files/Unicode.xsl "Unicode database builder XSLT"

<!--break-->

The XML contains practically everything that you can get from those two files, which means:

 * block and subblock structures
 * hexadecimal and decimal codepoints
 * names, aliases and comments
 * category and numeric information
 * uppercase, lowercase and titlecase equivalents
 * decomposition of various kinds
 * related characters
 * bidi information

It might prove easier to search than grepping the text files, if you're used to using XPath. I might split it up and put together an AJAX browser, in my Copious Spare Time.
