---
layout: drupal-post
title: Priorities for RDF
created: 1290980692
tags:
- rdf
- linked data
- tpac2010
---
A couple of weeks ago I did a talk at the [TPAC Plenary Day](http://www.w3.org/2010/11/TPAC/PlenaryAgenda) about why RDF hasn't had the uptake that it might and what could be done about it.

I felt quite uncomfortable about doing this for many reasons. The predominant one is that I'm well aware that the world is made by the people who turn up. It is far far easier to snipe from the sidelines than it is to put in the effort to attend telcons and face-to-face meetings, to engage on mailing lists, to write specifications and implementations and tutorials.

On the other hand, what I hope is that the perspective of someone who is outside that process, someone who tries to understand and interpret and *use* the results of that process, might be valuable. And so I aimed to provide that honestly.

In that spirit, I'm going to put my stake in the ground and say that there are three areas where I think W3C should be concentrating its efforts:

  1. standardising (something like) TriG -- Turtle plus named graphs
  2. standardising an API for the RDF data model
  3. standardising a path language for RDF that can be used by that API and others for easy access

and that it should specifically *not* put its efforts into standardising another syntax for RDF based on JSON.

<!--break-->

## Format Standardisation ##

The first point is that I think we need to decide on a single recommended format for RDF. 

Fundamentally, unlike XML or JSON, RDF is defined first and foremost as a model rather than as a syntax. That means it can be expressed in a number of syntaxes, the most common of which are [RDF/XML](http://www.w3.org/TR/REC-rdf-syntax/), [Turtle](http://www.w3.org/TeamSubmission/turtle/) and [N-Triples](http://www.w3.org/TR/rdf-testcases/#ntriples) though of course there's also [RDFa](http://www.w3.org/TR/xhtml-rdfa-primer/), [RDF/JSON](http://n2.talis.com/wiki/RDF_JSON_Specification), [JSON-LD](http://json-ld.org/) and [N3](http://www.w3.org/DesignIssues/Notation3) and if you start factoring in named graphs you can add [TriX](http://www.hpl.hp.com/techreports/2004/HPL-2004-56.html), [TriG](http://www4.wiwiss.fu-berlin.de/bizer/TriG/) and [N-Quads](http://sw.deri.org/2008/07/n-quads/) to the list.

Except for a few corner cases, it would be perfectly possible to express the same RDF model in any of these syntaxes. Why is this so bad? Surely having choice is a good thing, because publishers can choose an option that fits with their workflows? And aren't all these formats generated automatically anyway, such that the same data can be provided in many ways with no overhead?

Well, no, there are actually two ways in which **having multiple syntaxes makes adoption harder**.

First, **publishers aren't always generating data automatically**; in a number of cases (which I think and hope will grow) RDF data is being generated just like CSV files are, as static documents which are simply published in the same way as other static documents. In these cases, publishers either have to do the research and make a decision about which format to use, or produce the data in multiple formats. This is a particular challenge when people aren't convinced they want to generate RDF anyway.

Second, **toolsets have to handle producing or consuming multiple formats**. That means more code, more testing and more maintenance on both the production and consumption sides of the equation, all of which raise the implementation burden.

Of course it's natural that during the initial stages of the use of a technology that we should see a variety of patterns of use: there need to be innovations and experiments so that we can find what works and what doesn't. But as that technology matures, we need to start bedding down some basics. There need to be agreed foundations that, *even if imperfect*, are solid enough for the majority of us to build upon. And we need to exercise some self-restraint to concentrate on doing that building rather than revisiting those decisions.

We have a number of years of experience now about what formats are easy to understand, to pass around, to create and to process. It is time, I think, to pick one, to get it standardised, to deprecate others and to provide a much cleaner and clearer picture to publishers and consumers.

Of the formats that we have, the one that fits best with the RDF data model and is simplest for humans to understand is Turtle. But it needs to support named graphs, so that it's possible to share the [RDF datasets](http://www.w3.org/TR/rdf-sparql-query/#rdfDataset) that are exposed within a SPARQL endpoint, which is why I say W3C should standardise something like TriG.

## RDF APIs ##

The second point is to work on standardising the APIs that are available for developers who work with RDF. Why standardise APIs? Because it would make accessing RDF easier and more predictable for web developers, who often work across multiple languages and platforms. Developers don't really care about syntax -- although having something readable is useful for debugging -- they care about the way in which they get to interact with in-memory structures that hold the data.

RDF needs an API that exposes its internal model (of literals and resources and triples and graphs and datasets) in a way that isn't too onerous for people to use. There are lots and lots of RDF APIs about, within the various parsers that are available for different platforms; the only one that's approaching a standard is the one embedded within the [RDFa API specification](http://www.w3.org/TR/rdfa-api/). I would like to see that disentangled from RDFa and for it, or something like it, to gain traction amongst the writers of RDF libraries such as the [Redland RDF libraries](http://librdf.org/), [RDFLib](http://www.rdflib.net/), [Moriarty](http://code.google.com/p/moriarty/), [Reddy](https://github.com/tommorris/reddy), [rdfQuery](http://code.google.com/p/rdfquery/) and so on and on.

But **having an API for RDF's data model is not enough**.

I think there is a lot that we can learn from XML's experience here. James Clark's recent blog post about [XML and the web](http://blog.jclark.com/2010/11/xml-vs-web_24.html) describes what it's like for developers working with XML compared to JSON:

> The fundamental problem is the mismatch between programming language data structures and the XML element/attribute data model of elements. This leaves the developer with three choices, all unappetising:
>
>  * live with an inconvenient element/attribute representation of the data;
>  * descend into XML Schema hell in the company of your favourite data binding tool;
>  * write reams of code to convert the XML into a convenient data structure.
>
> By contrast with JSON, especially with a dynamic programming language, you can get a reasonable in-memory representation just by calling a library function.

So JSON is popular because accessing information within the JSON is really easy. And that's for two reasons:

  1. it's parsed with a single simple function call in a common library
  2. the result of parsing is simple to navigate; typically you can do so using native methods such as dot-notation paths

The first of these is a simple matter of winning hearts and minds. The second is the important one: it's easy to use because the underlying JSON model fits neatly onto the object-oriented programming paradigm that most developers use.

XML isn't so popular among web developers because its underlying model doesn't fit well into most programming languages: it has attributes and mixed content and a whole bunch of other things that don't map straight-forwardly onto objects-with-properties. Navigating through XML (or HTML) structures using a DOM is tedious and automatic binding mostly doesn't work.

What about RDF? On the face of it, RDF is a good fit with object-oriented models; they both follow a basic entity-attribute-value approach. However, there are (at least) three things in RDF that do not fit with the object-oriented model:

  1. Properties in RDF are identified through URIs rather than simple names (ie those containing just letters and numbers and underscores). Some programming languages, such as Javascript, let you have properties that aren't simple names, but you then have to access them through the relatively clunky `[]` notation rather than dot-notation paths. Properties are first-class objects in RDF with things like labels and ranges and inverses; fitting with standard programming languages here means using [reflection][reflection] and having the ability to annotate fields, and everything gets a bit mind-bending.

  2. Values in RDF often have datatypes or languages associated with them, and the set of datatypes that you can use is completely extensible (and of course datatypes are first-class objects, with their own properties, too). This wouldn't be so bad except that making every value an object means comparisons with basic strings or numbers won't generally work.

  3. In RDF, a property can have more than one value (an unordered bag of values, if you like) or it can have a value that is a `rdf:List` (an ordered sequence of values); it can even have many values which are `rdf:List`s. On the other hand, the object-oriented model generally supports values that are arrays (and of course you can have arrays within arrays), which are always ordered. So there is always a choice to be made when mapping from an object-oriented model to RDF, about whether the values should be at the same level or be `rdf:List`s.

[reflection]: http://en.wikipedia.org/wiki/Reflection_(computer_science)

In other words, just as with XML, **there is no straight-forward mapping from RDF to an object structure that developers can immediately use**. That doesn't stop us trying, of course:

There's the approach that we use within the [linked data API](http://code.google.com/p/linked-data-api/) and elsewhere, which is to make it easy for data publishers to create simple JSON versions of the RDF they publish. A website-specific configuration file determines what the mapping looks like. URIs of properties get turned into readable names (and provide the map back to the original property URI, so that it's possible to get more information about the property). Datatypes and languages are ignored by default (but mapped onto structured values if so configured). And the distinction between properties-with-multiple-values and properties-whose-value-is-a-List is ignored. We purposefully lose some of RDF's expressivity and power in order to gain usability. You can see the result in action at [http://education.data.gov.uk/doc/school](http://education.data.gov.uk/doc/school) and [http://education.data.gov.uk/doc/department](http://education.data.gov.uk/doc/department) for example.

There's the approach that Nathan has taken within [js3](https://github.com/webr3/js3) which is to create libraries that, with a bit of work on the client side, give a way of mapping RDF into an object-oriented structure which is easy to manipulate (or vice versa, create RDF from OO structures). It's the same basic principle as helping publishers to generate JSON, but the interpretation and mapping is done by the client rather than the publisher. The work that Nathan's done to manage this in Javascript is very impressive; I don't know whether the same approach can be mapped to other languages.

But as James intimated, data binding is hairy and scary. **Mappings between different data models are always imperfect, lossy, sensitive to what seem like small changes and therefore hard to maintain**. I remember nodding along as Mike Kay talked about this at the XML Summer School in relation to the use of XML: the horrors of working with systems in which there three way maps between relational and object-oriented and XML structures, and the relief that comes with working with an XML-only architecture. I suspect this same observation is one of the drivers behind the growth of JSON databases.

On the other hand, you know, perhaps RDF is close enough to the object-oriented model that it won't be so bad. Perhaps we could find a way to standardise on a method of configuring applications that do the mapping, such as defining short names for properties, describing how to handle objects with datatypes and languages and so on. We have [a body of experience](http://code.google.com/p/linked-data-api/wiki/JSONFormats) that can be learnt from, including the ones above, and perhaps it can be tied into the [RDB-to-RDF](http://www.w3.org/TR/r2rml/) work too. The biggest challenge, I suspect, will be to create something round-trippable.

## Path Languages ##

The other option that James didn't mention but that I touched on in my TPAC talk is to learn from how working with HTML and XML has been made easier in libraries such as [jQuery](http://jquery.org/) or [hpricot](http://hpricot.com/). These libraries still allow the HTML and XML to be accessed through a DOM, rather than mapping HTML or XML into object structures, but **make the lives of developers simpler by supporting querying of the HTML/XML using path languages that are *designed* to be used to query those kinds of structures**. For HTML, that's CSS; for XML that's XPath. (It's the same approach as is used for strings: we use regular expressions for many operations rather than working with them at the character level.) Path languages work over the native model; all that's offered in the library are functions that take strings (holding the path language) and return objects or values as appropriate.

I don't know exactly what it looks like, and it might already be out there (the world moves fast and I know I'm not aware of everything), but what I think we need is a path language for navigating around RDF, probably based on [SPARQL property paths](http://www.w3.org/TR/sparql11-query/#propertypaths) or the [FRESNEL selector language](http://www.w3.org/2005/04/fresnel-info/fsl/) and an API (or APIs) that uses it. For example, something that lets developers use code like:

    graph.find("*[foaf:nick = 'web3r']/foaf:name")

to pick values out of an in-memory graph. In my opinion, something like this would be much more likely to bring benefits than a data binding approach.

## Why Not RDF in JSON? ##

What I've tried to explain above is firstly that we already have too many syntaxes for RDF, and secondly that the main barrier to developers using RDF is the way in which they are forced to interact with that RDF once they have hold of it, not the syntax itself. The syntax that we use for RDF really doesn't matter, because developers interact with the in-memory dataset, not directly on the syntax.

Nathan's recent post on [Opening Linked Data](http://webr3.org/blog/linked-data/opening-linked-data/), which is worth reading in its entirety, captures the essence of the issue:

> You can't shoe horn RDF in to JSON, no matter how hard you try - well, you can, but you loose all the benefits of JSON in the first place, because the data is RDF, triples and not objects, rdf nodes and not simple values

In other words, **using JSON as the basis for an RDF syntax doesn't actually win you anything in terms of the ease of processing of that RDF**. In fact, I'll go further and say it has exactly the same bad qualities as RDF/XML.

One of the bad things about RDF/XML is that it misleads people into thinking they can use normal XML tooling to process RDF, but XML tooling exposes the XML tree, not the RDF graph that they need. It's good enough in some circumstances, of course, but it's not working with RDF as RDF. Similarly, just because you're using XML tools doesn't mean RDF/XML is easy to generate; you're a lot safer to generate correct RDF/XML from an in-memory graph, in the same way as generating XML using string manipulation is harder work than it first appears.

In exactly the same way, I think that a JSON-based syntax for RDF will mislead developers into thinking that they can interpret and generate that JSON like they can normal JSON, and interact with it at that level, when this simply isn't the case.

The only advantage that I can see for a JSON-based RDF syntax is equivalent to the only advantage of RDF/XML: it is easier to store for people who use JSON databases, just as RDF/XML is easier to store for people who use XML databases. I am not sure that benefit is worth the cost of an additional RDF syntax; isn't RDF better stored in a triplestore?

## Summary ##

So to reiterate, as far as I'm concerned, W3C and the RDF community should be concentrating on a syntax for RDF that doesn't come saddled with those kinds of assumptions, which I think is Turtle + graphs; something like TriG. They should be concentrating on developing a standard API for RDF access that has a chance of adoption among the developers of RDF libraries, and on working out what parts of SPARQL and FRESNEL could be used to create a path language that could be reused in several contexts, including within such an API. And these should be done in preference to a RDF syntax in JSON which doesn't solve the core problems, and in fact just adds another syntax to the mix.
