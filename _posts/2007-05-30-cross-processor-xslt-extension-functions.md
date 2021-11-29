---
layout: drupal-post
excerpt_separator: "<!--break-->"
title: Cross-processor XSLT extension functions
created: 1180516707
tags:
- xslt
---
[David Carlisle][1]'s posted a [great tip][2] on getting [`exsl:node-set()`][3] to work in IE:

>In the above XSL-List thread I casually suggested that an alternative would be to just always use exslt:node-set in the body of the stylesheet and use the msxsl:script extension to define exslt:node-set for IE. That turned out not to be as easy as I thought as node-set isn't a valid function name in either of the supported extension languages in msxsl (JScript or VBScript). However Julian Reschke came up with the construct needed, use associative array syntax so you can use ['node-set'] to define the function.

[1]: http://dpcarlisle.blogspot.com/ "David Carlisle's Blog"
[2]: http://dpcarlisle.blogspot.com/2007/05/exslt-node-set-function.html "The EXSLT node-set function"
[3]: http://www.exslt.org/exsl/functions/node-set/index.html "exsl:node-set()"

<!--break--> 

I've been having related problems getting my [XSLT unit testing framework][4] to work with XSLT 1.0 stylesheets designed to work with MSXML, and specifically to use the `msxsl:node-set()` function. The solution there was to provide an implementation of `msxsl:node-set()` using `<xsl:function>`:

    <xsl:function name="msxsl:node-set" as="document-node()" override="no">
      <xsl:param name="items" as="item()*" />
      <xsl:document>
        <xsl:sequence select="$items" />
      </xsl:document>
    </xsl:function>

Note the `override="no"` which marks this as an implementation to be used only when the processor doesn't support it natively. This is an issue with `msxsl:node-set()` at the moment, but in the general case if you're writing a user-defined function that mirrors a vendor's extension function then you ought to use `override="no"`.

What I *should* do is add XSLT 2.0 implementations of all the [EXSLT][5] functions to the unit testing framework too...

[4]: http://www.jenitennison.com/xslt/utilities/unit-testing/ "Jeni's XSLT Unit Testing Framework"
[5]: http://www.exslt.org/ "EXSLT"
