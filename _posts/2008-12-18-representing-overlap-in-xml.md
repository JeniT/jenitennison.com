---
layout: drupal-post
excerpt_separator: "<!--break-->"
title: Representing Overlap in XML
created: 1229636697
tags:
- overlapping markup
---
I'm still on an overlap jag. I've shown some examples in the [last couple][dominance] [of posts][hierarchy] of [TexMECS][TexMECS], [XCONCUR][XCONCUR] and [LMNL syntax][LMNLsyntax], which depart from the usual well-formedness strictures in XML. But these syntaxes have one big problem: they're not XML. XML is well-known, well-understood, and has great tools available for it, for querying, transforming, and [pipelining][XProc]. So it would be a real win if overlap could be represented within XML in a usable manner.

[dominance]: http://www.jenitennison.com/blog/node/95 "Jeni's Musings: Overlap, Containment and Dominance"
[hierarchy]: http://www.jenitennison.com/blog/node/96 "Jeni's Musings: Essential Hierarchy"
[TexMECS]: http://decentius.aksis.uib.no/mlcd/2003/Papers/texmecs.html "TexMECS"
[XCONCUR]: http://www.xconcur.org/ "XCONCUR"
[LMNLsyntax]: http://www.lmnl.org/wiki/index.php/LMNL_syntax "LMNL Wiki: LMNL syntax"
[XProc]: http://www.w3.org/TR/xproc/ "XProc: An XML Pipeline Language"

<!--break-->

XML syntaxes for overlap, such as in [TEI][TEI] or in [LMNL][LMNLaltSyntaxes], adopt five different techniques:

[TEI]: http://www.tei-c.org/index.xml "TEI: Text Encoding Initiative"
[LMNLaltSyntaxes]: http://www.lmnl.org/wiki/index.php/Alternative_Syntaxes "LMNL Wiki: Alternative Syntaxes"

  * **milestones:** one hierarchy is represented through normal XML markup; the others through empty elements (or, in some cases, processing instructions) that mark the start and end of structures that do not fit into that hierarchy
  * **fragmentation:** one hierarchy is represented through normal XML markup: the others are represented through fragment elements that are linked together through their attributes (eg all XML elements that represent the same structure are given the same identifier)
  * **flattened:** all start and end tags are represented by milestones within a single meaningless root element
  * **multiple document:** the document is split into multiple documents, each with a different set of elements within them. A particular element may be present in more than one of these documents, and of course the textual content (known as the **frontier**) remains the same in each
  * **standoff:** the frontier is kept in a single place, perhaps including a common (**sacred**) hierarchy and all other overlapping structures are represented by elements that point to their start and end within that content (either using offsets or [XPointers][XPointer])

[XPointer]: http://www.w3.org/TR/xptr-framework/ "W3C: XPointer Framework"

There's been some really good research at the University of Bologna on [how to translate between formats that use these techniques][translate] (as well as LMNL and TexMECS syntax). What I want to look at here is when and why it might be appropriate to use each of them.

[translate]: http://upsilon.cc/~zack/research/publications/nrhm-overlapping-conversions.pdf "Towards the unification of formats for overlapping markup"

All these representations are useful in their own ways and in different situations. I'm going to talk a bit about the payoffs here. Here's a summary of pros and cons:

<table>
  <thead>
    <tr>
      <th>technique</th>
      <th>advantages</th>
      <th>disadvantages</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th align="left" valign="top">milestones</th>
      <td valign="top">easy to see main structure</td>
      <td valign="top">favours one main structure;<br />hard to identify content of overlapping structures</td>
    </tr>
    <tr>
      <th align="left" valign="top">fragmentation</th>
      <td valign="top">easy to see main structure;<br />easy to work out content of overlapping structures</td>
      <td valign="top">favours one main structure;<br />leads to spurious containment;<br />can lead to discontinuous elements</td>
    </tr>
    <tr>
      <th align="left" valign="top">flattened</th>
      <td valign="top">all structures treated equally</td>
      <td valign="top">hard to see any structure;<br />hard to process naturally using XML tools</td>
    </tr>
    <tr>
      <th align="left" valign="top">stand-off</th>
      <td valign="top">all structures treated equally</td>
      <td valign="top">hard to see any structure;<br />hard to process naturally using XML tools<br />hard to edit without tools</td>
    </tr>
    <tr>
      <th align="left" valign="top">multiple document</th>
      <td valign="top">easy to see individual structures</td>
      <td valign="top">content gets repeated;<br />complex to align structures;<br />hard to do cross-hierarchy analysis;<br />hard to edit without tools</td>
    </tr>
  </tbody>
</table>

So first, there's the ability of the format to represent different kinds of overlap or support specialised tasks. Multiple separate well-formed documents, for example, can't represent self-overlapping markup unless you have some variable, and possibly increasing, number of documents based on how much self-overlap there is. Fragmentation naturally supports discontinuous elements in a way that the other methods don't. Stand-off markup lets you mark up other people's documents without having write permissions on them. You might be constrained to use, or avoid, a particular technique simply because of what kind of overlap you're dealing with.

Second, there's editability. Milestones, fragments and (arguably) flattened structures are almost as easy to edit by hand as normal XML (that is, straight-forward for geeks, impossible for normal people). Stand-off markup (depending a little on how the marked up parts of the document are referenced) and multiple documents really require specific editing tools both for adding markup and changing the content of the document. I'm generally of the opinion that tools should never been a necessity, but if you're creating an editor then you're probably going to use stand-off markup or multiple documents behind the scenes.

Third, there's how much, and how easily, you can use standard XML tools to process the documents. If you were using XSLT (as I usually am), and were presented with multiple documents, stand-off markup or flattened structures, you'd want someone to translate them into a milestoned or fragmented structure before you did anything. I have done quite a few transforms in which the documents were represented using a milestone technique, for example the changes within the [revised statutes on the OPSI website][SPO], which all have to be highlighted in blue, surrounded by square brackets and have a link at the start, and they're fiddly (especially in XSLT 1.0), though tractable. Fragmented markup, on the other hand, would be much easier to process.

[SPO]: http://www.opsi.gov.uk/legislation/revised "OPSI: Revised Legislation"

Finally, there's the issue of whether one particular hierarchy has prominence within the XML. In some examples of overlap, particularly the ones I'm concerned with such as comments and revisions, there's an obvious primary hierarchy (the main document markup) with the others being secondary. This makes techniques such as milestones and fragmentation particularly appropriate. On the other hand, when there are multiple equal hierarchies, particularly when the two hierarchies use elements with the same names (such as marking up the pages in two editions of the same book), it might seem strange to choose one over another. You either need a neutral format (such as flattened markup, stand-off markup or multiple documents) or, in processing, the ability to easily switch between different primary hierarchies.

So I don't think it's ever going to be possible to say "this is *the* way in which you should mark up your overlap using XML". However, I do think it would be really useful to have standard vocabularies for marking up overlap in XML, mostly in the form of namespaced attributes. If we had a set of model-neutral (ie not LMNL, nor GODDAG, nor XCONCUR, nor ...) and markup-language-neutral (ie not TEI, nor ...) vocabularies for representing overlap, we could start constructing querying, transformation and validation tools that would be useful across a range of projects. (I was thinking an RFC, but I have no idea how to go about it.)
