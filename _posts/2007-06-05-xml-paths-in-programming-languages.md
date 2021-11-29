---
layout: drupal-post
excerpt_separator: "<!--break-->"
title: XML Paths in Programming Languages
created: 1181079348
tags:
- xml
---
I've finally finished my "Progress in Processing" talk for this year's [XML Summer School][2]. It's been really interesting looking at the different APIs developed for different programming languages in the last few years, all *so* much easier to use than the [DOM][3]. One of the themes is the use of path-based syntax to query XML.

[2]: http://www.xmlsummerschool.com/ "XML Summer School in Oxford"
[3]: http://www.w3.org/DOM/

<!--break-->

Even with the simpler XML APIs, accessing nodes in an XML tree can be pretty laborious. For example, get all the `<room>` elements in the first `<floor>` element of a house with (this is [XLinq][1]):

    doc.Element("house").Element("floor").Elements("room")

Of course [XPath][4] does this pretty well:

    /house/floor[1]/room

and many of the APIs that I looked at provided XPath access. For example (this is Ruby's [REXML][7]):

    doc.elements["/house/floor[1]/room"]

But using XPath is tricky for a couple of reasons:
 
 *  A cognitive leap is required to switch from the usual object/method dot-notation syntax that you use in the surrounding language to the specialised XPath notation. In particular, it's difficult mixing the one-based indexing in XPath with the zero-based indexing that's used in most programming languages.

 *  XPaths have to be passed as strings; there's a temptation to construct the strings automatically, which leads to all sorts of headaches (such as remembering to put quotes around the strings that you concatenate into the XPath when you really want them to be interpreted as strings rather than element names). [A clean way of approaching this would be to use variables in the XPath and pass in a set of variable bindings when you use the XPath, but I don't know any API that actually does this.]

Because of these issues, there's been some effort to use the native dot-notation syntax to query XML within general-purpose programming languages. I knew about [JAXB][5] before I started looking, but didn't know before about [Uche Ogbuji][8]'s [Amara][6] or the details of the VB.NET interface. Whereas with JAXB you have to compile a schema (an XML Schema schema, what's more) into Java classes, with Amara and VB.NET there's the kind of dynamic binding you get with XPath. In Amara, for example, you can do:

    doc.house.floor.room

while in VB.NET you can use (I think):

    doc.<house>.<floor>.First().<room>

(Don't ask me how to get the rooms on the *second* floor in VB.NET; that, I couldn't figure out. In Amara, it's `doc.house.floor[1].room`.)

[1]: http://www.xlinq.net/ "XLinq website"
[4]: http://www.w3.org/1999/xpath "W3C: XPath specification"
[5]: http://java.sun.com/developer/technicalArticles/WebServices/jaxb/ "Java API for XML Binding"
[6]: http://uche.ogbuji.net/tech/4suite/amara/ "Amara: Python XML Toolkit"
[7]: http://www.ruby-doc.org/stdlib/libdoc/rexml/rdoc/ "REXML's Ruby Documentation"
[8]: http://uche.ogbuji.net/ "Uche Ogbuji's Home Page"

Path-based syntax in general-purpose programming languages is really neat: it exposes XML documents as if they were objects, which makes them "closer" to you as a programmer. They work particularly well for data-oriented XML in which elements contain either elements or text and not both.

There are two main areas where the path-based languages differ.

First, what they do with paths with intermediate steps that select more than one element. For example, in XPath, `/house/floor/room` gets you all the rooms in all the floors of the house, as does `doc.<house>.<floor>.<room> in VB.NET: both provide an implicit iteration over the selected elements in the intermediate steps. In Amara, `doc.house.floor.room` gets you all the rooms in the *first* floor of the house, so you have to explicitly iterate over the `<floor>` elements if you want to collect all the rooms in the house.

Second, how they handle namespaces. In XPath, you have to provide a set of namespace bindings whenever you evaluate an XPath expression, and the prefixes you use on element names are resolved against those namespace bindings. In XPath 1.0, element names with no prefix only match elements in no namespace; in XPath 2.0, you can also provide a default namespace that's used for names with no prefix.

That works well when XPath is embedded in some XML (such as in XSLT, XForms, XProc and so on), because the namespace bindings from the XML environment can provide the namespace bindings for the XPath expression. But that can't generally happen when XPaths are used in a programming language.

All the APIs that use XPaths allow you to specify the namespace bindings explicitly, but some, such as REXML, do an automatic namespace binding based on the namespace bindings from the source document. So if I have:

    <xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
      ...
    </xs:schema>

in the document I'm querying then I can use the `xs` prefix to mean the XML Schema namespace in the path that I use to query the document, such as `/xs:schema/xs:element/@name` to get the names of the global element declarations.

This makes paths nice and simple... right until you have to use them process a document that uses different namespace bindings. For example, it's not uncommon to find XML Schema documents that use the prefix `xsd` instead of `xs`, or even the default namespace; for those documents, the automatic binding won't work and the path `/xs:schema/xs:element/@name` will give you an error. [REXML also provides `XPath.match()` and `XPath.each()`, to which you can provide an explicit set of namespace bindings; you'll use these if you care about keeping the indirection between prefixes and namespaces.]

In Amara (when using Pythonic paths), you can just forget about namespaces: the elements and attributes are selected purely based on their local name. The only time you'll run into problems is if you actually have, in the same context, two elements from different namespaces with the same local name, which is an event that's rarer than people using different prefixes for a given namespace. In the XML Schema example, you can use `doc.schema.element.name` (yes, attributes are picked up with the same syntax as elements), and will only have a problem if there's an `<element>` element in some other namespace. [Amara also provides XPath-based querying, and you can supply explicit namespace bindings for that.]

In VB.NET, the `Imports` directive is used to provide global namespace bindings, so it gets the benefits that you would have from using XPath in an XML context. What's more, you can use a default namespace binding so that you don't have to use prefixes in your paths. So you can do:

    Imports <xmlns:xs="http://www.w3.org/2001/XMLSchema">

and then `doc.<xs:schema>.<xs:element>.@name` and it will work as planned, no matter what prefixes were actually used in the schema document. Or you can do:

    Imports <xmlns="http://www.w3.org/2001/XMLSchema">

and `doc.<schema>.<element>.@name`. Overall, I think it's pretty impressive that VB.NET is going to have support for querying XML documents built in at such a low level.

Using default namespaces in paths is a tricky issue, though. I'll have to dedicate a different post to that; this one's quite long enough already.
