---
layout: drupal-post
excerpt_separator: "<!--break-->"
title: Whitespace in markup languages
created: 1185093145
tags:
- markup
---
I [wrote previously][1] about the, to my mind, wrong-headed use of `xml:space` in WordML (and [OOXML][2]), and promised something a bit more positive about how whitespace *should* be handled in markup languages. So here it is.

A bit of a disclaimer up front: my attitude on this topic is highly skewed by the fact I use XSLT all the time, and it has particular ways of dealing with whitespace. I happen to think that the way XSLT deals with whitespace is pretty solid, but that might just be because it's what I'm used to.

The aim of this post is to answer the following question "when designing a markup language, what should I say about whitespace processing?"

[1]: http://www.jenitennison.com/blog/node/41 "Things that make me scream: xml:space=preserve in WordML"
[2]: http://en.wikipedia.org/wiki/Office_Open_XML "Office Open XML"

<!--break-->

Markup languages are data formats, not applications. Different applications may add or remove whitespace from documents in a given markup language. For example:

  * automatic indentation algorithms may change whitespace to make the document easier to read
  * programs querying documents may normalise whitespace when doing (text-based) searches or comparisons
  * renderers may ignore, collapse, change and add whitespace when rendering the document; for example browsers generally collapse whitespace and wrap the text when they display XML with a default (CSS) stylesheet

As a markup language designer, you need to describe how whitespace should be handled in your markup language. You need to answer the questions of people generating documents in your markup language:

  * can/should/must I add whitespace here?
  * if I add whitespace here, will it make a difference to my target application?

and the questions of the people processing the documents:

  * can/should/must I ignore this whitespace?
  * does this whitespace change the meaning of this value?

## Whitespace in Element-Only Content ##

Whitespace in element-only content can be ignored without changing the meaning of an XML document. "Element-only content" means that the element can only ever contain elements. That's something like

    element name { element given { text },
                   element family { text } }

in compact RELAX NG. It does *not* mean element instances that happen to contain only elements and whitespace. If you declare `<name>` as:

    element name { text &
                   element given { text } &
                   element family { text } }

then the whitespace in

    <name><given>Jeni</given> <family>Tennison</family></name>

does *not* count as whitespace in element-only content. Parsers that come from the Microsoft stable have an annoying tendancy to think you can just get rid of this whitespace, which is why you should only ever use them with `preserveWhiteSpace` set. (This has the unfortunate side-effect of keeping *all* your whitespace, but it's better to have whitespace that you don't need than to not have whitespace you do need.)

The XML spec requires parsers to pass all characters on to the application, although validating parsers can indicate if a character is a whitespace character that appears in element-only content according to the DTD associated with the document. The **element content whitespace** [infoset][3] property of these characters has the value true.

[3]: http://www.w3.org/TR/xml-infoset "W3C: XML Infoset (Second Edition)"

In practice, since MSXML doesn't do it right, since you can't rely on DTDs being accessible, and since applications don't tend to strip element content whitespace automatically anyway, people processing documents generally have to ignore this whitespace manually. In XSLT, for example, you should use `<xsl:strip-space>` to get rid of whitespace from the elements you list. This reduces the size of the tree you're dealing with and prevents you from counting whitespace-only text nodes or outputting them and thus getting screwy indentation in the output.

As a markup language designer, it doesn't hurt to clarify matters by making a global statement like "whitespace that appears in element-only content can be ignored by processing applications" and then listing which elements this applies to. But mostly people will assume this to be the case anyway.

## Whitespace in Data Content ##

Next up is whitespace that appears in elements or attributes that contain data. Whitespace rules here usually come into play when testing values. For example, you'll usually want `date = '2007-07-12'` to be true for both

    <date>
      2007-07-12
    </date>

and

    <date>2007-07-12</date>

There are three standard kinds of whitespace normalisation. These are defined most formally in [XML Schema][4], but actually arise from the whitespace normalisation done to attribute values in basic XML:

  * **preserve**: all whitespace is preserved
  * **replace**: every whitespace character is replaced with a space character
  * **collapse**: all runs of whitespace are replaced by a single space; leading and trailing whitespace is stripped

Attribute values are always either replaced (the default if there's no DTD) or collapsed (if they are typed as something other than CDATA in a DTD) during the parsing of the document. Like other text, element values are never touched during normal parsing.

[4]: http://www.w3.org/TR/xmlschema-1/#d0e1654 "W3C: XML Schema Part 1: White Space Normalisation During Validation"

The types that you use in a DTD or schema should indicate to people writing or processing documents in your markup language which kind of whitespace processing is going to be done. Here's how it goes for the XML Schema datatypes:

  * if you define the type as `xs:string`, it means the whitespace should be preserved (although this won't happen for attribute values, since their whitespace gets replaced automatically)
  * if you define the type as `xs:normalizedString`, it means the whitespace should be replaced
  * otherwise, (including `xs:token`) it means the whitespace should be collapsed

It's worth thinking carefully about which of `xs:string`, `xs:normalizedString` or `xs:token` should be used when defining enumerations. If you base an enumeration on `xs:string` as in

    <xs:simpleType name="windowType">
      <xs:restriction base="xs:string">
        <xs:enumeration value="single glazed" />
        <xs:enumeration value="double glazed" />
      </xs:restriction>
    </xs:simpleType>

then no whitespace processing is done before the value is assessed against the enumerated values; the only values that are allowed are `"single glazed"` and `"double glazed"`. For example

    <window>
      single
      glazed
    </window>

would be invalid. On the other hand, if you base an enumeration on `xs:token` as in

    <xs:simpleType name="windowType">
      <xs:restriction base="xs:token">
        <xs:enumeration value="single glazed" />
        <xs:enumeration value="double glazed" />
      </xs:restriction>
    </xs:simpleType>

then whitespace is collapsed before the value is assessed against the enumerated values, so the example above would be valid.

Generally, when you enumerate values you do want to collapse whitespace, so you should base the type on `xs:token`. In RELAX NG, this is the default, and doing

    <choice>
      <value>single glazed</value>
      <value>double glazed</value>
    </choice>

will result in the same behaviour as basing a simple type on `xs:token`. If you don't want to strip whitespace, then you can use the `type` attribute on the `<value>` element to specify that the values are strings, not tokens

    <choice>
      <value type="string">single glazed</value>
      <value type="string">double glazed</value>
    </choice>

Of course one time you'll *really* want enumerated values to be based on strings is if they can consist purely of whitespace.

## Whitespace in Document Content ##

Once you have document content (content that is targeted at human consumption, which is usually mixed content), the only applications that should touch whitespace are rendering applications. Markup languages should be designed so that processors don't have to add (or remove) whitespace to get something human readable.

I've been dealing with a markup language recently where this rule is broken in two ways. First, within a `<text>` element, processing applications have to add a space before any processing instruction or element that it contains. For example, look at:

    <text>The proviso to section 6(2) of the<?change id="797826" 
      type="commentary"?>Statutory Orders (Special Procedure) 
      Act 1945 (power to withdraw an order or submit it to 
      Parliament for further consideration by means of a Bill for its 
      confirmation) shall have effect in relation to compensation 
      orders as if for the words<quotation class="double">"may 
      by notice given in the prescribed manner, withdraw the 
      order or may"</quotation> there were substituted the 
      word<quotation class="double">"shall"</quotation>.</text>

See how there's no space before the `<?change?>` PI or the `<quotation>` elements? In this case, spaces need to be added before them. On the other hand, if the `<?change?>` or `<quotation>` element happens to start after certain kinds of punctuation, such as quotation marks or brackets then whitespace shouldn't be added.

Second, in this badly designed markup language, if a `<text>` element has element-only content, processing applications have to ignore the whitespace around them. For example:

    <commentarycontent><text>S. 39(5)(</text>
    <text>
    <font class="italic">b</font>
    </text>
    <text>) repealed by Industry Act 1980 (c. 33, SIF 64), 
      Sch. 2</text></commentarycontent>

In this case, the whitespace in the second `<text>` element can be ignored without any problems, but of course if the first `<text>` didn't end with a bracket, but instead with a comma or a letter, the whitespace would have to be preserved (or at least turned into a space).

Whitespace processing of the kind illustrated here is time-consuming, hard to specify and inaccurate. The only people who really know what whitespace is needed in document-oriented content are the authors who create it, so it's really important that they have the right, and responsibility, to determine where whitespace appears.

Rendering applications are a special case, because they have to munge whitespace to make text more readable. That often includes normalising whitespace away and adding line breaks (and hyphens) in the rendered view of the document. Different presentation-oriented markup languages use different algorithms to do this normalisation:

  * In HTML, whitespace within a block gets collapsed, while whitespace at the beginning or end of a block gets stripped away, except in `<pre>` elements where all whitespace is preserved.
  * In XSL-FO, whitespace processing depends on the `linefeed-treatment`, `white-space-treatment` and `white-space-collapse` properties, which provide practically any kind of behaviour; the default is the HTML rules.
  * In WordML, whitespace is replaced (not collapsed); whitespace at the beginning or end of a `<w:t>` element is stripped away unless `xml:space="preserve"` for that `<w:t>` element.

Because every piece of human-readable text eventually makes its way into HTML, I think it's best to try to make your markup language follow the HTML rules. That means defining what the blocks are (the equivalent of paragraphs) and which ones have significant whitespace in them.

## On `xml:space` ##

As the above discussion has shown, there are at least three different kinds of whitespace normalisation that can be used on an XML document. But `xml:space` has just two values: `default` and `preserve`. So one problem with using `xml:space` is that it doesn't have any predefined semantics: in one application is might identify the distinction between collapsing and preserving, in another the distinction between replacing and preserving, in another (OOXML) the distinction between replacing-with-leading-and-trailing-whitespace-stripped and replacing.

So my advice would be: don't use it. Instead, take the time to define explicitly how whitespace should be handled in the schema and documentation for your markup language.

I could just about be argued into providing `xml:space` as an optional attribute on elements where the user is likely to want to change the way whitespace is processed on a case-by-case basis. But I can't actually think of any example where that might happen.

 * * *

The biggest problem with whitespace handling is not that it can't be defined, but that so many applications do it wrong. I'm sure that the bad whitespace use I described above, where PIs and elements implicitly added whitespace, arose not because the markup language designer decided that it would be a good idea but because the applications the authors used either added whitespace in their WYSIWYG displays or stripped it out when it was saved. Likewise, the abysmal whitespace-stripping behaviour of MSXML has led to many a strange use of markup, like David Carlisle adding `xml:space="preserve"` to his `<html>` elements.

So it's the responsibility of markup language designers to specify how whitespace should be used, but it's equally the responsibility of processors to honour those specifications.
