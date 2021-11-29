---
layout: drupal-post
excerpt_separator: "<!--break-->"
title: Converting (people) to RDF
created: 1195157073
tags:
- rdf
---
As I've mentioned before, I've been a RDF sceptic for a long time. Perhaps it's precisely *because* of my knowledge engineering background: in my experience, the field is about equal parts academic optimism, sales-related exaggeration and plain old information management. In other (un-minced) words, unrealistic aims with unproven technologies that are sold as being much cleverer (and more innovative) than they are. It's not just RDF, I should say, but the whole Semantic Web pitch (typified for me by the idea of [halting global terrorism using the power of Topic Maps][1]) that seemed ludicrous to me.

[1]: http://www.idealliance.org/papers/extreme/proceedings/html/2002/Newcomb01/EML2002Newcomb01.html "Extreme 2002: Forecasting Terrorism: Meeting the Scaling Requirements"

Time moves on, and I might be changing my mind.

<!--break-->

Putting the whole over-selling thing to one side, one underlying reason for my scepticism was that it seemed that the Semantic Web depended on people doing things in one way: using big standard ontologies with RDF/XML representations. That doesn't seem to me to fit with the web. The power of the web comes from people (largely) being able to do their own thing, in their own time, with opportunistic linking between sets of information. If you want to use the web, you have to work with the loose coupling.

But RDF is becoming more web-friendly. [GRDDL][2] and [RDFa][3] both provide mechanisms for providing RDF triples whilst retaining your own markup language. GRDDL does it by pointing at some XSLT that will turn your markup into [RDF/XML][5], while RDFa provides a set of conventions that you can use in your markup that allow it to be directly interpreted as RDF by RDFa processors. Either way, it means you don't have to adopt the [striped syntax][4] pattern in your markup, or even use the RDF namespace. The RDF data model always was theoretically distinct from the RDF/XML syntax; these new technologies (plus simple notations such as [Turtle][6]) place the emphasis back on the model.

[2]: http://www.w3.org/TR/grddl/ "W3C: Gleaning Resource Descriptions from Dialects of Languages (GRDDL): Recommendation"
[3]: http://www.w3.org/TR/rdfa-syntax/ "W3C: RDFa in XHTML: Syntax and Processing: Working Draft"
[4]: http://www.w3.org/2001/10/stripes/ "W3C: RDF: Understanding the Striped RDF/XML Syntax"
[5]: http://www.w3.org/TR/rdf-syntax-grammar/ "W3C: RDF/XML Syntax Specification (Revised): Recommendation"
[6]: http://www.dajobe.org/2004/01/turtle/ "Turtle - Terse RDF Triple Language"

Also encouraging is that [OWL][7] specifically supports linking between ontologies, allowing you to indicate that classes, properties and individuals from different ontologies are equivalent. This means you are free to create your own local ontology, as am I, and either of us (or a third party) can later link the two ontologies together, along with any related triples.

[7]: http://www.w3.org/TR/owl-features/ "W3C:  OWL Web Ontology Language Overview: Recommendation"

However, I was chatting to my friend Louise the other day about RDF, and asked her whether she'd be using it in her next project. Her basic argument against was simply that it wasn't worth it. And this is the second underlying reason for my scepticism: does RDF give a big enough win to justify the effort required to use it? The "market" seems to say not. RDF has been around for years; if it was going to become an established technology, surely it would have by now. When I look at the web today, it's pretty hard to find RDF. Where semantic information is available, it's usually provided in a JSON or XML format. Or of course they're using microformats in their pages. Why go to the bother of defining an ontology and providing a GRDDL transformation, or adopting the rigour of RDFa, when these technologies get the job done?

It *should* be that mashing up RDF is easier than mashing up random JSON/XML. Just a few "this is equivalent to that" assertions and you're good to go. So show me the places (outside academia) where RDF-based mash-ups are being made. Show me the interfaces that are allowing people in the real world to use RDF to pull together information from diverse sources, get better overviews, draw more accurate conclusions.

I want to believe. Show me the uses of RDF that will convert the sceptic in me.
