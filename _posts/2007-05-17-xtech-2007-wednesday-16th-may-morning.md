---
layout: drupal-post
excerpt_separator: "<!--break-->"
title: ! 'XTech 2007: Wednesday 16th May Morning'
created: 1179435059
tags:
- xtech
- xslt
- schema
- xlinq
---
Since there's next to no 'net connection at XTech 2007 (obviously the Web is not so ubiquitous as all that), I have nothing to do in the sessions but listen! Here are some thoughts about the sessions that I attended on the morning of Wednesday 16th. I haven't included the keynotes not because they weren't interesting but because I can't think of anything to say about them at the moment.

<!--break-->

## [XML and LINQ: What's New in Orcas and Beyond][1] ##
### [Erik Meijer][2] (Microsoft) ###

I thought I'd better go to this one because I'm supposed to be talking about XML APIs at this year's [XML Summer School][3] and LINQ, or XLINQ, is one of the hot topics. I'm not a .NET developer, so it's all kinda passed me by thus far, and I'm not sure I really understand it now. (I'd welcome corrections and clarifications.) The three things that seemed to be important are:

 1.  You can get at information held in objects, databases or XML using the same syntax. (Erik showed accessing XML with faulty XQuery syntax, which made me and [Priscilla Walmsley][8] grimace at each other.) This means you can decide how you want to actually hold your data further down the line. A big distinction between previous attempts to work across paradigms is that the *data* doesn't get converted, but the *queries* do. So you write your LINQ query in LINQ syntax and it gets mapped on to SQL to query your SQL database, or on to XQuery (I guess) to query your XML document. This all seemed to assume data-oriented information: I have no idea, yet, how or whether mixed content gets handled.

 2.  XML is a "first class datatype" in LINQ, so to create static XML you just write XML in your program (a bit like in XQuery). The example Erik showed included an XML declaration, which is just plain weird: dunno if that was an error or it's a way of indicating what version of XML you're using, or what. To create dynamic portions of the XML, you use `<%=...%>` "expression holes" which can contain .NET code, including calls to a new API for creating XML elements and attributes (a DOM replacement).

 3.  Erik talked about writing applications in .NET and then automatically refactoring them (with a click in a context menu) to work in client/server architectures, and refactoring again to work across several clients. Presumably this creates all the code necessary to make the application work with WS* messaging, so you don't have to program it. This all sounded really dodgy to me: I don't want to rely on a tool to make a language/approach/architecture usable.

There was an amusing digression into the art of rendering triangles, and thus three-dimensional models, with zero-width, zero-height, bordered `<div>`s in XHTML. And a mention of the "backbutton" problem that you get when you spawn tabs/windows in your web browser and then go back to your original tab/window and hit submit, which made me think that perhaps a RESTful architecture would make a whole lot of complexity go away.

[1]: http://2007.xtech.org/public/schedule/paper/60 "XML and LINQ: What's New in Orcase and Beyond"
[2]: http://research.microsoft.com/~emeijer/ "Erik Meijer's Website"
[3]: http://www.xmlsummerschool.com/ "XML Summer School, Oxford"
[8]: http://www.datypic.com/ "Priscilla Walmsley's Website"

## [Data Model Perspectives for XML Schema][4] ##
### [Felix Michel][5] (ETH Zurich), [Erik Wilde][6] (UC Berkeley) ###

Felix mentioned that I might be interested in his talk in a [comment here][7], and sure enough I found it fascinating. He's created a single-file representation of XML Schemas (consolidating schemas that, by virtue of using different namespaces, must be in different physical documents), and a set of XSLT 2.0 user-defined functions that provide access to and queries on the XML Schema information.

For example, you can go from an instance element in your document to its type, find out if it's an extension or restriction, go to its base type, look at the annotations on it, and so on and so on. And all this in Basic XSLT 2.0 (the functions that work on instance elements traverse the instance document and schema in parallel to locate the element declaration that applies). You could use these functions to do everything you can do in Schema-Aware XSLT 2.0, with more flexibility, at the expense of performance.

He also mapped content models onto `<occurrence>` elements that encode the "follow set" for a particular occurrence, so you can easily answer the question "what elements could come next?". I can't immediately think of a way of using that information in a stylesheet, but perhaps he can describe one.

Anyway, I think Felix's point was not to provide XSLT programmers with a set of useful functions, but to demonstrate the kind of standard, fairly light-weight, API that we might use to access XML Schema information. There was some discussion, in the development of XPath 2.0, of providing this kind of API, but getting agreement on XDM was hard enough!

However, my thoughts were veering off in different directions. To my mind, validation and annotation are separable processes, and the data types, element groups and linking behaviour that you might find useful on a data set are processing-specific. For example, it might make sense for one process to annotate the element `<foo>2007-05-17</foo>` as having the type date, while for another process (such as a transformation that deletes all `<foo>` elements) it's unnecessary. I really don't want to have to define an XSD schema for my entire schema just to indicate that the `<foo>` element is of type `xs:date`.

Just as it's better to define the links between elements using keys, rather than relying on ID annotations made by a DTD, I think type annotations and node groups (why limit it to elements?) could be defined in the stylesheet. To give an idea:

    <!-- all date attributes have the type named 'xs:date' -->
    <ann:type name="xs:date" match="@date" />
    <!-- h1, h2, h3, h4, h5, h6 elements are heading elements -->
    <ann:group name="xhtml:heading" 
      match="xhtml:h1 | xhtml:h2 | xhtml:h3 | xhtml:h4 | xhtml:h5 | xhtml:h6" />
    <!-- oh, and so's the h element -->
    <ann:group name="xhtml:heading" match="xhtml:h" />

It'd be reasonably easy to give rudimentary support for `ann:type($node)` and `ann:group($node)` user-defined functions based on these, but they'd really have to be built into the XSLT processor to get full pattern support and to work with modularised stylesheets. This all requires more detail than I have time to write right now, but is it even worth pursuing?

[4]: http://2007.xtech.org/public/schedule/detail/159 "Data Model Perspectives for XML Schema"
[5]: http://www.ee.ethz.ch/ "Felix Michel's Website"
[6]: http://dret.net/netdret/ "Erik Wilde's Website"
[7]: http://www.jenitennison.com/blog/node/2#comment-24 "Comment: Re: XTech Preparation"
