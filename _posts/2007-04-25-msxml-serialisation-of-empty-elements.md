---
layout: drupal-post
title: MSXML serialisation of empty elements
created: 1177514274
tags:
- xslt
---
The problem: You're using MSXML (and therefore XSLT 1.0). You're outputting XHTML (and therefore using the `xml` method). You want to output an empty `<a>` element for an anchor, but want to make sure that you get a start tag and and end tag (`<a id="foo"></a>`) rather than an empty element tag (`<a id="foo"/>`).

Is the only solution disable-output-escaping? <!--break--> No! MSXML outputs start and end tags if you create an element using literal result elements, `<xsl:copy>` or `<xsl:element>` with any instruction that could potentially produce content. So whereas

    <a id="foo"></a>

produces

    <a id="foo"/>

putting something innocuous inside, such as

    <a id="foo"><xsl:value-of select="''" /></a>

creates

    <a id="foo"></a>

### Disclaimers ###

 *  Of course with another XSLT processor, or XSLT 2.0, you would use an xhtml output method to make sure that empty element syntax was only used for elements that are declared to be `EMPTY`, such as `<br>` and `<img>`.
 *  This trick might not work with other XSLT processors; certainly Saxon always outputs an empty element if the element is empty.
 *  And anyway, using empty `<a>` elements for anchors is *not* good quality XHTML.
