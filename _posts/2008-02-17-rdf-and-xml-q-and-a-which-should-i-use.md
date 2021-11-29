---
layout: drupal-post
excerpt_separator: "<!--break-->"
title: ! 'RDF and XML Q&A: Which should I use?'
created: 1203279012
tags:
- xml
- rdf
---
Another question to answer:

> I’ve been reading about RDF, and I’m not sure in what situations it is more appropriate to use RDF over straight XML. I usually see RDF expressed as XML, but sometimes I see it written as language-independent functions (or methods).

> Part of me is wondering if RDF is more appropriate for this project. What might the benefits be? And if it is, how difficult it would be to refactor it.

(Note that the person asking the question is talking about a small data-oriented project.) There's a huge amount that could be said about this, so I might well post about some of it again. Here, I'm going to cut to the chase. This is what I'd recommend:

 1. **Model your application in RDF terms**: Create a description of what classes of resources your application needs to deal with, and which properties link those together. You can call this description a RDF schema or conceptual model or ontology, depending on how impressive you want to sound. This modelling activity is useful in itself, largely because it helps you understand what information you’re dealing with and how it fits together.

 2. **Create a markup language that can be mapped to RDF**: An XML version of your data allows you to make your data more generally available and reusable than locking it away in a triple store. Do one of the following:

      * **Define a subset of [RDF/XML][1] for your application**: The full flexibility of RDF/XML is complicated to handle for plain XML processors, so subset it to, for example, always used typed elements (such as `<my:Course>`) rather than `rdf:type` properties, and to use referencing or nesting in a consistent way.

      * **Design markup languages that use [RDFa][2] attributes to reflect the semantics of the data**: This gives you a standard way of mapping your markup language into RDF triples without having to adopt the "striped" design of RDF/XML in your markup language. A lot of the attributes can be defaulted to leave the markup language fairly streamlined.

      * **Design markup languages exactly as you like, and define [GRDDL][3] mappings from them into RDF/XML**: This gives you the most flexibility in your markup language design (though not complete flexibility -- you still need to be able to identify the statements that you want to make from the XML), at the expense of having to write some XSLT.

The point of doing this is to put you in a position where you *can* just use XML if you want, but you also have the flexibility of using RDF either now or in the future.

The benefits of using RDF are partly to do with the ease with which you can do certain kinds of processing (specifically combining "facts" together to draw conclusions) and partly to do with the potential of reuse of your data. In the same way that XML gives people a common *syntax* and thus aids interchange of information, RDF allows others to draw *some* conclusions (more than they would with a random mess of elements and attributes) about what your data means.

I don't think that using RDF triple stores, [SPARQL][4] and all that jazz gives you a great return for a small-scale, personal project -- you're better off sticking to flat files and some XSLT -- but it doesn't hurt to build in some of the formality of RDF anyway.

[1]: http://www.w3.org/TR/rdf-syntax-grammar/ "W3C Recommendation: RDF/XML Syntax Specification"
[2]: http://www.w3.org/TR/xhtml-rdfa-primer/ "W3C Working Draft: RDFa Primer"
[3]: http://www.w3.org/TR/grddl/ "W3C Recommendation: Gleaning Resource Descriptions from Dialects of Languages (GRDDL)"
[4]: http://www.w3.org/TR/rdf-sparql-query/ "W3C Recommendation: SPARQL Query Language for RDF"
