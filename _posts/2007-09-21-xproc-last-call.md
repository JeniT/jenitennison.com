---
layout: drupal-post
excerpt_separator: "<!--break-->"
title: XProc Last Call
created: 1190410520
tags:
- pipelines
---
Can you believe it, we've made it to Last Call on XProc (*the* XML pipeline language)! That's only, like, nine months later than the [published schedule][1], which I reckon is pretty good going. (Then again, I'm judging it against XSLT 2.0...)

I'm really excited about XProc. I've found that pipelining in XSLT -- splitting up processing tasks into smaller, more manageable processing tasks and stringing them together -- has greatly improved my productivity and the simplicity and maintainability of the code I write. But some processing (such as that used by my [XSLT unit test framework][7]) can't be done in a single transformation, some is on massive documents that you can't realistically process with XSLT (and I *really* don't want to have to write SAX or StAX code to do it), and some I just want to do on all the files in a directory.

XProc gives me a high-level, declarative, streamable processing language for XML documents. And I think we've struck the right balance between something that's simple enough to be easy for everyday tasks, and powerful enough to be able to do the more complex things you might want to do with it.

[1]: http://www.w3.org/XML/Processing/#schedule "XML Processing Working Group Schedule"
[7]: http://www.jenitennison.com/xslt/utilities/unit-testing/index.html "XSLT Unit Test Framework"

<!--break-->

It's going to be really interesting to see how much of current XSLT use it replaces, and how much it opens up. For example, the ability to use a [viewport][6] to isolate a subtree of a document for processing means that XSLT could be used on (the records in) huge database dumps. A bit like [Saxon's support for streaming large documents][8], but standardised.

Anyway, **Last Call**, guys! [Read the specification.][2] [Send us your comments.][3] Write some pipelines. Try them out with [Norm's XML Pipeline Processor][4]. Heck, write [test cases][5]! Implement it!

On the subject of comments, I recommend:

  * resending any comments you already made that you don't feel we've addressed; as I understand it, we're obligated to discuss every comment we receive during Last Call
  * sending a separate mail for each technical comment (but a single mail with multiple editorial comments is OK)
  * only sending requests that you think are must-haves for version 1.0
  * supporting requests with examples
  * searching for what you want to comment on in the [archives of the XML Processing WG mailing list][9] just to make sure we haven't already discussed it to death

I hope that doesn't sound as if I'm discouraging comments. If you've got something to say, say it. But be aware that the more comments we receive the longer it'll take us to get to Recommendation, so make 'em count. You've got until the 24th October.

[2]: http://www.w3.org/TR/2007/WD-xproc-20070920/ "XProc: An XML Pipeline Language: Last Call Working Draft 20 September 2007"
[3]: mailto:public-xml-processing-model-comments@w3.org "public-xml-processing-model-comments@w3.org"
[4]: http://norman.walsh.name/2007/projects/xproc "Norm Walsh's XML Pipeline Processor"
[5]: http://norman.walsh.name/2007/09/05/xprocTests "Norm Walsh: Bring out your tests"
[6]: http://www.w3.org/TR/xproc/#p.viewport "XProc: Viewport"
[8]: http://www.saxonica.com/documentation/sourcedocs/serial.html "Saxonica: Streaming Large Documents"
[9]: http://lists.w3.org/Archives/Public/public-xml-processing-model-wg/ "W3C XML Processing Model WG Discussion Archive"
