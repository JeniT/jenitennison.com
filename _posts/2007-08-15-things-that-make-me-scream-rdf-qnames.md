---
layout: drupal-post
title: ! 'Things that make me scream: RDF "QNames"'
created: 1187213908
tags:
- rdf
---
Having avoided [RDF][1] like the veritable plague for years, I have been forced to look at it properly for my latest "put [RDFa][2] on our web pages" project. So the other day I came across this weirdness surrounding "QNames" in [Turtle][4], [SPARQL][5] and RDFa (and so on)...

As we all know, RDF is about making statements about resources, and resources are identified by URI. And the predicates/properties that you use to make statements about resources are *also* identified by URI. So I can say things like (in Turtle syntax):

    <http://www.lmnl.org/wiki/Creole>
      <http://purl.org/dc/elements/1.1/creator>
        [<http://xmlns.com/foaf/0.1/weblog>
         <http://www.jenitennison.com/blog>] .

and it means that the creator (as defined by [Dublin Core][6]) of the page `<http://www.lmnl.org/wiki/Creole>` is someone whose weblog (as defined by [FOAF][7]) is `<http://www.jenitennison.com/blog/>`.

[1]: http://en.wikipedia.org/wiki/Resource_Description_Framework "Wikipedia: Resource Description Framework"
[2]: http://en.wikipedia.org/wiki/RDFa "Wikipedia: RDFa"
[4]: http://www.dajobe.org/2004/01/turtle/ "Turtle: notation for RDF"
[5]: http://www.w3.org/TR/rdf-sparql-query/ "W3C: SPARQL: queries over RDF" 
[6]: http://www.dublincore.org/ "Dublin Core Metadata Initiative"
[7]: http://www.foaf-project.org/ "Friend of a Friend Project Page"
[8]: http://www.w3.org/TR/rdf-syntax-grammar/ "W3C: RDF/XML"

<!--break-->

The trouble with URIs is that they're so *long*. Turtle, SPARQL and RDFa, and all of these technologies want to make it easy to write RDF, so they want to provide a shorthand. The shorthand they provide looks similar to, and is even sometimes called, a "QName".

Here's how "QNames" work in these RDF technologies. You associate a prefix with a URI like so (this from Turtle):

    @prefix dc: <http://purl.org/dc/elements/1.1/> .

Then when you write the prefix followed by a `:`, followed by a local part, it's equivalent to concatenating the URI with the local part; the result is the URI represented by the "QName". So having defined the `dc` prefix as above, I can use `dc:creator` in place of the URI `<http://purl.org/dc/elements/1.1/creator>`.

Seems simple enough, right? I mean, I know how QNames work in XML, and these look the same, just with some behind-the-scenes assumptions about how to resolve QNames to get to further information about them.

My first double-take was when I wanted to add a datatype to a literal. I wanted to indicate that the value was a date, which you can do in Turtle or SPARQL with the syntax:

    "2007-08-13"^^xs:date

I can write the namespace for XML Schema on auto-pilot, so I started writing it `<http://www.w3.org/2001/XMLSchema>`, then wondered whether they just used the datatypes URI so went to check. What URI is used in the examples? `<http://www.w3.org/2001/XMLSchema#>`. Huh? What's that `#` doing there? Well, it's because the full URI is then `<http://www.w3.org/2001/XMLSchema#date>`, which looks a whole lot better than `<http://www.w3.org/2001/XMLSchemadate>`. It doesn't matter that `<http://www.w3.org/2001/XMLSchema#date>` doesn't resolve to anything (or does it?), so long as we all use the same URI to mean date-as-defined-in-XML-Schema. The small matter that the RDF "namespace" for XML Schema is different from the normal XML namespace for XML Schema is by-the-by. Boggle.

My second double-take was when I wanted to write an example that used numbers as identifiers. My last post was about URL design, and used the URL `<http://www.statutelaw.gov.uk/legislation/3032571>` as an illustration. Now say I want to use a QName to represent that URI. I can do

    @prefix leg: <http://www.statutelaw.gov.uk/legislation/> .

but if I then do `leg:3032571` that's not a legal (XML) QName: the local part isn't an XML Name because it begins with a number. Turtle doesn't allow it, SPARQL kinda does (it's an "at risk feature"), and who knows what RDFa will do (there's not enough of a spec to tell as yet).

Then there's the weirdnesses of "QNames" with no prefix, which still have a colon. And QNames with an underscore as the prefix, which of course mean a blank node with a specified ID, but let's leave that to one side.

Really, the whole mess started with [RDF/XML][8] which allows you to give elements the "QName" equivalent of the class that you're talking about. So `<rdf:Description>` can be replaced by `<foaf:Person>`. Indeed, properties pretty much *have* to be represented by elements whose name is equivalent to the property URI in RDF/XML. That doesn't usually matter so much because, unlike instances, which could be pretty much any URI, properties and classes are likely to have sensible names (`rdf:_1`, `rdf:_2` and so on being notable, but illustrative, exceptions: it really shouldn't be necessary to add underscores just to satisfy the QName naming rules which don't apply in the abstract RDF model).

Fundamentally, using "QNames" as abbreviations for URIs is a bad idea. QNames have a number of restrictions on them because they are built to be legal XML Names: the kinds of things that you  can call elements and attributes. URIs *don't* have these restrictions: it's perfectly possible for the last part of a URI to consist purely of numbers, or to have a slash at the end, or even to have request parameters. Fair enough that meaningful QNames can be used for *some* URIs, but if you can't use them properly for *all* URIs, then there has to be a better way.

The way that you usually create short URIs is to use a *relative* URI, which is resolved against a *base* URI to produce an *absolute* URI. And that's the mechanism that should be used in RDF. The only difficulty is that in most RDF documents, you'll have lots of URIs with completely different base URIs, so having just one base URI (like normal) doesn't cut it.

You need to be able to associate shorthands (I won't call them prefixes, because doing so is confusing) with base URIs -- a `@base` directive will do -- and have a simple syntax for resolving relative URIs against a given base. You could use a *shorthand*:<*relativeURI*> syntax, I think, and allow the `<>`s to be dropped if the relative URI happens to be a legal Name. So with

    @base leg: <http://www.statutelaw.gov.uk/legislation/> .

you could use `leg:<3032571>` to mean the URI `<http://www.statutelaw.gov.uk/legislation/3032571>` or `leg:<wine/2007/-/>` to mean the URI `<http://www.statutelaw.gov.uk/legislation/wine/2007/-/>`.

SPARQL already has a `BASE` directive to define a *single* base URI that's used when resolving relative URIs in URI references; really all I'm suggesting is allowing several base URIs to operate at the same time (using shorthands to distinguish between them), and dropping `PREFIX`. Turtle doesn't have a `@base` directive, though there's a suggestion that one might be added, so there the changes are a little more major.

In RDFa, "QNames" are used in attribute values to indicate class URIs, property URIs, and datatype URIs. And normal namespace declarations are used to make the prefixes, which means training yourself to write

    xmlns:xs="http://www.w3.org/2001/XMLSchema#"

when you're writing RDFa, while everywhere else (schemas, stylesheets, etc.) you write

    xmlns:xs="http://www.w3.org/2001/XMLSchema"

XML namespace declarations really shouldn't be used here. Instead, you could extend the `<base>` element-as-was to provide bindings

    <base short="xs" href="http://www.w3.org/2001/XMLSchema#" />
    <base short="leg" href="http://www.statutelaw.gov.uk/legislation/" />

and then use *those* bindings when interpreting the attribute values (the *shorthand*:<*relativeURI*> syntax won't work here, because of having to escape the `<`s in attribute values, but you get the idea).

Meanwhile, if you have free reign over your URL space and you're thinking of using RDF, URLs should be designed such that the last part (be it fragment or path segment) is a legal XML local name. Doing so will make it a lot easier to express statements in Turtle or RDFa and queries in SPARQL. What's more, the last part of the URI should be the unique identifier for the resource in question; if your URLs look like `<http://www.example.com/collection/5326/view>` then you should consider dropping the `/view` part to provide the canonical URI, or swapping the last two parts of the path (oh and adding a prefix to the numeric identifier) to give `<http://www.example.com/collection/view/i5326>`.

And this is *particularly* true, indeed fairly essential, for any URLs that you might want to use to represent classes or properties.
