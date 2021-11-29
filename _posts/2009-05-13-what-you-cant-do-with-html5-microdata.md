---
layout: drupal-post
excerpt_separator: "<!--break-->"
title: What You Can't Do with HTML5 Microdata
created: 1242176266
tags:
- rdfa
- html5
---
**Update:** Fixed a couple of errors in the microdata code.

The [HTML5 microdata][microdata] proposal has hit the web, just days before Google announced its [support for RDFa][google] (or at least [one vocabulary encoded using RDFa attributes][iand]). These are, indeed, ["interesting times"][interesting] for the semantic web.

[microdata]: http://dev.w3.org/html5/spec/Overview.html#microdata "W3C: HTML5: Microdata"
[google]: http://radar.oreilly.com/2009/05/google-announces-support-for-m.html "O'Reilly: Google Announces Support for Microformats and RDFa"
[iand]: http://iandavis.com/blog/2009/05/googles-rdfa-a-damp-squib "Ian Davis: Google's RDFa a Damp Squib"
[interesting]: http://en.wikipedia.org/wiki/May_you_live_in_interesting_times "Wikipedia: May you live in interesting times"

Now, if you're one of those weirdos who want to embed RDF triples within your web pages, what you're going to care about is whether you can use microdata to do it. Those of us who have been using RDFa in anger, rather than in toy examples, know that it can be hard to map a particular set of RDF statements onto HTML content. I thought I'd take a look to see just what it would be like to create particular RDF with the HTML5 microdata proposal.

<!--break-->

## Basics ##

On the face of it, you can express any triple in microdata because a triple like this (Turtle):

    <http://www.example.com/subject> <http://www.example.com/property> <http://www.example.com/object> .

can always, and anywhere, be expressed with (HTML5):

    <span item>
      <link itemprop="about" href="http://www.example.com/subject">
      <link itemprop="http://www.example.com/property" href="http://www.example.com/object">
    </span>

while a triple like:

    <http://www.example.com/subject> <http://www.example.com/otherProperty> "value" .

can be expressed with:

    <span item>
      <link itemprop="about" href="http://www.example.com/subject">
      <meta itemprop="http://www.example.com/otherProperty" content="value">
    </span>

Of course having to use all those long, repetitive URIs is a bit of a pain and bloats out the markup, but we'd never expect this to be hand-authored, right? Right? And what we really care about is that we can express the RDF.

It's not just the URIs that are long-winded, by the way. RDFa manages to cram a lot into each element, whereas microdata usually requires separate elements. This is an example from the RDFa specification:

    <img src="photo1.jpg"
      rel="license" resource="http://creativecommons.org/licenses/by/2.0/"
      property="dc:creator" content="Mark Birbeck" />

which produces the triples:

    <photo1.jpg> xhv:license <http://creativecommons.org/licenses/by/2.0/> .
    <photo1.jpg> dc:creator "Mark Birbeck" .
  
In HTML5, I think this has to be done with:

    <span item>
      <img itemprop="about" src="photo1.jpg">
      <link itemprop="http://www.w3.org/1999/xhtml/vocab#license" 
            href="http://creativecommons.org/licenses/by/2.0/">
      <meta itemprop="http://purl.org/dc/elements/1.1/creator" 
            content="Mark Birbeck">
    </span>

It's a bit more tedious, but also more obvious what's going on. Even after handling RDFa as much as I have, I still struggle to work out when, for example, an `href` attribute is providing the object for a statement, and when the subject. And if you look at the [London Gazette][gazette] RDFa, you'll notice many occasions where empty `<span>` elements are used to provide the equivalent of the inline `<link>` and `<meta>` elements shown above. (In fact, as far as I recall earlier drafts of RDFa allowed `<link>` and `<meta>` elements to be used this too.)

[gazette]: http://www.london-gazette.co.uk/ "London Gazette"

From what I can see, though, there are two things that the microdata proposal in its current form can't handle: datatyping and XML literals.

## Datatypes ##

Datatypes are important in RDF. Values of properties are often not just strings, but dates, times, integers and so on. The microdata proposal mentions using the `<time>` element to create values, and has this example:
  
    <div item>
     I was born on <time itemprop="birthday" datetime="2009-05-10">May 10th 2009</time>.
    </div>

The triple that you'd want to create from this is:

    <> <http://www.w3.org/1999/xhtml/custom#birthday> "2009-05-10"^^xsd:date .

which makes it plain that the value is a date. However, the definition of the mapping from microdata to RDF makes it clear that the triple that's created is:

    <> <http://www.w3.org/1999/xhtml/custom#birthday> "2009-05-10" .

In other words, the value is a plain literal, not a date.

In RDFa, the `datatype` attribute is used to indicate the datatype of the value, so you can do:

    <div xmlns:custom="http://www.w3.org/1999/xhtml/custom#">
      I was born on <span property="custom:birthday" content="2009-05-10" datatype="xsd:date">May 10th 2009</span>
    </div>

It would be easy enough to say that the value of a `<time>` element has the datatype `xsd:date`, `xsd:time` or `xsd:dateTime` dependent on the syntax of its `datetime` attribute, but there are other times that you want typed values. We've used strings (as opposed to plain literals), integers and years. I wouldn't want to rule out the use of custom datatypes such as colours (and RDF permits these). The JSON mapping could, perhaps, use an appropriate object if there is one, and otherwise use just the string value without too much loss of power.

## XML Literals ##

Arguably less important is the lack of support for XML literals, which are values that contain markup. The example in the RDFa spec is:

    <h2 property="dc:title">
      E = mc<sup>2</sup>: The Most Urgent Problem of Our Time
    </h2>

which generates the triple (Turtle):

    <> <http://purl.org/dc/elements/1.1/title> "E = mc<sup>2</sup>: The Most Urgent Problem of Our Time"^^rdf:XMLLiteral . 

RDFa allows you to force a value as an XML literal or a plain literal using the `datatype` attribute. Otherwise, if the element has any element children then it's assumed to be an XML literal, and if not, a plain literal. I think the microdata proposal could adopt the same course of action. The JSON mapping could, perhaps, result in a value which is an array or some other container for a sequence of text and element nodes.

## Final Thoughts ##

To my mind, the HTML5 microdata proposal is unacceptable in its current form because, unlike RDFa, it can't be used to represent all the statements that you might want to represent. If those issues were fixed, there would be pros and cons between it and RDFa. Microdata is more long-winded, but more explicit. RDFa is more arcane but doesn't swamp the content of the page to quite the same extent.

Like a lot of people, I would have far rather seen a proposal which didn't reinvent the wheel, but how does the old saying go: "The great thing about standards is that there are so many to choose from." If the microdata proposal stays the course, I only hope that we'll see consumers supporting both it and RDFa so that producers can choose which to use rather than being forced to embed both within their pages.
