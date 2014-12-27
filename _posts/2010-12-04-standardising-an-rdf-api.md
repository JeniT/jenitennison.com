---
layout: drupal-post
title: Standardising an RDF API
created: 1291449943
tags:
- rdf
---
I got a little bit of [pushback](http://twitter.com/vambenepe/status/9097914244669440) on my [previous blog post](http://www.jenitennison.com/blog/node/149) for suggesting that W3C should standardise an API for RDF. (I'm talking here about a programming-interface-kind-of-API to enable developers to extract information out of an RDF document rather than a website-API to enable them to access RDF data in the first place.)

I just wanted to talk about a couple of actual real-life scenarios that make me want a standard RDF API:

  1. [TimBL](http://www.w3.org/People/Berners-Lee/) wants an [RDFa](http://www.w3.org/TR/xhtml-rdfa-primer/) parser for [Tabulator](http://www.w3.org/2005/ajar/tab). There are a few RDFa parsers in Javascript; he chooses to use [rdfQuery's](http://code.google.com/p/rdfquery/). Tabulator works on top of its own datastore, which has its own interface for inserting data. rdfQuery's RDFa parser works on top of its own datastore, which has a different interface for inserting data. To use rdfQuery, TimBL has to either rewrite some of its internal code to call the methods that insert data into Tabulator's datastore, or rewrite some of Tabulator's internal code to call the methods that query rdfQuery's datastore. **The lack of a standard API for RDF has made it harder for TimBL to reuse my code.**

  2. I'm working on [Puelia](http://code.google.com/p/puelia-php/), which needs to both parse and generate RDF in various ways and uses [Moriarty](http://code.google.com/p/moriarty/) to do so. I am editing the code to create triples in an in-memory RDF graph. I want to add a triple with a literal value. I have no idea how to do so, because I haven't used Moriarty before, so I have to hunt through its documentation to find the [`add_literal_triple()`](http://code.google.com/p/moriarty/wiki/SimpleGraph#add_literal_triple) function. **The lack of a standard API for RDF has made it harder for me to use the library.** If I ever wanted to switch to using some other PHP RDF library, such as [EasyRDF](http://www.aelius.com/njh/easyrdf/) or [Graphite](http://graphite.ecs.soton.ac.uk/), for whatever reason, I would have to rewrite substantial parts of Puelia to use the functions provided by that library. **The lack of a standard API for RDF has made Puelia less modular and adaptable.**

For all that the [W3C XML DOM](http://www.w3.org/DOM/) seems to be universally reviled as an API for querying and creating XML, it and [SAX](http://www.saxproject.org/) mean that people can write XSLT and XProc processors (etc) without writing their own XML parser. They mean that whatever programming language I find myself writing code in, I know that I'll be able to use `getElementsByTagName()` to get hold of elements with a particular name. They mean that XML parsers have a reason to improve over time, because applications can easily switch to better parsers when they come along. DOM and SAX provide a foundation, a level of standardisation and pluggability, that improves the XML landscape as a whole.

Of course sometimes components need tighter integration in order to achieve performance benefits; that's a modularity/performance judgement on the part of the developer of the application. And of course there are better object model APIs for XML than the W3C XML DOM around. But better APIs are almost always programming-language or library specific; they are better simply because cross-platform APIs like DOM and SAX cannot take full advantage of the idioms of a particular programming language or style.

Now regarding the W3C's involvement in creating such a standard, the argument seems to be "W3C created the horror that is the XML DOM and therefore every API specification that comes out of the W3C will be horrendous". 

I think sometimes that W3C is seen as a kind of monolithic organisation that exists *over there*, with secret committees whose work takes place out of public eyes until they deign to let us mere mortals read the results of their machinations. And who then fend off all comments and criticism in order to protect their lovingly crafted (but completely impractical) specifications.

What this overlooks is that the standards organisation merely provides the framework and administrative support within which groups who are interested in creating a standard can come together. The existing [RDFa Working Group's](http://www.w3.org/2010/02/rdfa/) [meetings are documented](http://www.w3.org/2010/02/rdfa/wiki/Meetings) and [discussion takes place in public](http://lists.w3.org/Archives/Public/public-rdfa-wg/) and is open to all. I'm sure this will continue in the RDF Core Working Group when it is set up.

It will happen anyway. There is *already* work going on with the W3C to create a [standard RDFa API](http://www.w3.org/TR/rdfa-api/#the-rdf-interfaces), out of which, [so I am told](http://www.jenitennison.com/blog/node/149#comment-10515), will arise a Working Draft of an RDF API. From the looks of [the most recent Working Draft](http://www.w3.org/TR/2010/WD-rdfa-api-20100923/) I will be able to add a literal triple to a [DataStore](http://www.w3.org/TR/2010/WD-rdfa-api-20100923/#data-store) using something like

    $store->add(
      $store->createTriple(
        $store->createBlankNode('puelia'),
        $store->createIRI('http://www.w3.org/2000/01/rdf-schema#label'),
        $store->createPlainLiteral('Puelia', 'en')
      )
    );

(compared to

    $graph->add_literal_triple('_:puelia', 'http://www.w3.org/2000/01/rdf-schema#label', 'Puelia', 'en')

in Moriarty). So OK, it needs a bit of work. But these are early days, and from the looks of the [editor's draft](http://webr3.org/_pvt/rdfa-api) it's likely to change quite rapidly.

W3C's standardisation is what we make it; wherever it is done, it is a self-fulfilling prophecy that an API will not be suited to its purpose if the people who would benefit from implementing and using that API don't get involved in its design. And to be clear, I am talking to myself more than anyone.
