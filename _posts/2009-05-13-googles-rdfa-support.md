---
layout: drupal-post
title: Google's RDFa Support
created: 1242250231
tags:
- google
- rdfa
---
I can't reply to [Henri Sivonen][tweet]

> @JeniT What's wrong with http://rdf.data-vocabulary.org/rdf.xml ?

[tweet]: http://twitter.com/hsivonen/status/1785106195 "Tweet: @JeniT What's wrong with http://rdf.data-vocabulary.org/rdf.xml ?"

in 140 characters.

[http://rdf.data-vocabulary.org/rdf.xml][rdf] is the the RDF schema that describes the classes and properties recognised by Google's [rich snippets][snippets], which promises to provide richer information about search results than is available currently, in the manner of [SearchMonkey][searchmonkey].

[rdf]: http://rdf.data-vocabulary.org/rdf.xml "http://rdf.data-vocabulary.org/rdf.xml"
[snippets]: http://google.com/support/webmasters/bin/topic.py?topic=21997 "Google: Structured Data (Rich Snippets)"
[searchmonkey]: http://developer.yahoo.com/searchmonkey/ "Yahoo! SearchMonkey"

So what's so bad about this RDF schema?

<!--break-->

Well, firstly, unlike what I just claimed, it's *not* the RDF schema for Google's rich snippets. If you look at an example like this one from their own help pages:

    <div xmlns:v="http://rdf.data-vocabulary.org/" typeof="v:Person">
       <span property="v:name">John Smith</span>
       <span property="v:nickname">Smithy</span>
       <span property="v:url">http://www.example.com</span>
       <span property="v:affiliation">ACME</span>
       <span rel="v:address">
         <span property="v:locality">Albuquerque</span>
       </span>
       <span property="title">Engineer</span>
       <a href="http://darryl-blog.example.com/" rel="v:friend">
       <span property="v:name">Darryl</span>
    </div>

you'll see that the CURIE `v:name` resolves to the URI `http://rdf.data-vocabulary.org/name`. And that resolves to... well, [take a look][name]. **The fact that you can't resolve a property URI to a definition within a schema or ontology really undermines the idea of [self-describing documents][sdd].** To know anything about what `http://rdf.data-vocabulary.org/name` means you have to be human enough to go hunting for the documentation that describes it. Contrast with `http://xmlns.com/foaf/0.1/name` which, if you ask for RDF, takes you to ontology in which you can look for the definition of that resource, and find out its domain, range, a label for it and so on.

[name]: http://rdf.data-vocabulary.org/name "http://rdf.data-vocabulary.org/name"
[sdd]: http://www.w3.org/2001/tag/doc/selfDescribingDocuments.html "W3C: Self-Describing Documents"

So the redirection's screwed up. What about the schema itself? Well, it's not that it's bad in and of itself; it reflects a reasonable model of the world of products, reviews, people, organisations. The model's obviously heavily based on those used within the microformats that Google is also supporting: [hProduct][hProduct], [hReview][hReview], [hCard][hCard] and [XFN][XFN], which in turn are based on existing standards such as [vCard][vCard] or on solid document analysis on existing behaviour. So it's not surprising that it's a reasonable model.

[hProduct]: http://www.microformats.org/wiki/hproduct "microformats: hProduct"
[hReview]: http://www.microformats.org/wiki/hreview "microformats: hReview"
[hCard]: http://microformats.org/wiki/hcard "microformats: hCard"
[XFN]: http://gmpg.org/xfn/intro "XFN"
[vCard]: http://www.ietf.org/rfc/rfc2426.txt "RFC2426: vCard"

The problem is not so much what has been done as what hasn't. I'm not completely surprised that there's no support for [FOAF][FOAF] -- the model is sufficiently different from that of hCard to make it harder to use -- but not reusing the [existing RDF ontology for vCard][rdfVCard] smacks of either ignorance or arrogance. I've advocated before going ahead and building your own ontologies rather than waiting for community standardisation, but not doing a rudimentary search for previous work is going too far.

The schema itself is very sparse. It only uses RDF schema, rather than OWL, so it's not surprising that it's not particularly expressive, but even so a few labels would have been useful! The classes that have been introduced have no hierarchy (they are all subclasses of `rdf:Resource`), so properties that are shared between people and organisations, such as `v:name`, have a domain of all resources. And there's no property subclass, so no way to automatically identify the appropriate property to use as a substitute for `rdfs:label` when displaying information about a person or organisation. **From a technical standpoint, it seems like it was hastily thrown together by people who either don't understand why self-description is important, or don't care about other people's use of the vocabulary.**

[FOAF]: http://www.foaf-project.org/ "Friend-of-a-Friend"
[rdfVCard]: http://www.w3.org/2006/vcard/ns# "W3C: RDF Ontology for vCard"

But more than these, the reason that I am disappointed with what's been shown so far is that **Google is really missing the point of using RDF: its extensibility**. It's easy enough to parse a set of microformats; to build something useful around a small number of known vocabularies. It's easy, but it's limited. When I heard the buzz of "Google supporting RDFa" I expected it to support not just the syntax of RDFa, but its extensibility, because otherwise what's the point?

The quote that scares me most comes from the [interview with RV Guha and Othar Hansson][interview]:

> **RV Guha** ... It's really important that everybody, as far as possible, use the same vocabulary. So Google is essentially going to be making an investment in sort of hosting a vocabulary that maybe is Google Services. ...

[interview]: http://radar.oreilly.com/2009/05/google-adds-microformat-parsin.html "O'Reilly: Google Adds Microformat Parsing"

because a single centralised vocabulary is just not going to be feasible. The web's too large and diverse for that.

And I believe that Google, by working with the web and combining semantic markup with their formidable computing power and existing natural language understanding, could do so much more. Let me talk through a really simple scenario to illustrate.

> Google publish their own RDF vocabulary for products (as they have done). Amazon look at the vocabulary and decide that it doesn't include some information that's useful and important specifically for books, such as the author of the book. So Amazon extend Google's vocabulary by adding a new class that's a subclass of `google:Product`, `amazon:Book` and introduce another property in their RDFa markup, `amazon:author`, giving it a range of `amazon:Book`.
>
> When Google indexes Amazon's pages, the RDFa parser sees that the resources that are described in the pages are described as `amazon:Book`s. It doesn't know what a `amazon:Book` is, so it resolves the URI, looks at Amazon's ontology and finds the label and description of the class, and the fact that it's a subclass of `google:Product`. The fact that an `amazon:Book` is a kind of `google:Product` means that it can be displayed just like other products. Perhaps Google even specify some other things that can be put in your ontology to supplement the rich snippet, like an icon, or a list of properties that are important. I don't know. The point is that the ontology provides information to Google about what to do with this class, without Google having to invent and own the vocabulary.
>
> Similarly, when the RDFa is parsed, Google generates triples for this new `amazon:author` property just as it does for the other Google ones. It recognises that it doesn't know what it means, so it resolves the URI for the property and finds a schema. The schema includes a label for the property, "author" and a natural language description. Google uses the label in the display of the rich snippet; it processes the natural language description to disambiguate the label and translate it into other languages. Perhaps it can even assess the importance of the property, and whether it should actually be displayed at all, by understanding its description.

Anyway, back to earth. These are the kind of pipe dreams that I used to ridicule semantic web folk about back before they body-snatched me! So although I'm sure that Google could do so much more, there are some things to be thankful for:

  * They have made the first steps towards recognising semantic markup as a potentially useful source of information.
  * They haven't gone and invent yet another syntax for encoding semantic information within HTML. (Well, at least this arm hasn't.)
  * They have reused microformats.
  * They have developed a vocabulary for a few things that are really useful, even if we did have ontologies for some of it already.
  * They will now have a stake in answering the difficult questions around trust, confidence, accuracy and time-sensitivity of semantic information.

And, of course, this will encourage people who haven't previously been interested to use semantic markup, which will make data easier to get at and more open to reuse and I believe will benefit the web as a whole.
