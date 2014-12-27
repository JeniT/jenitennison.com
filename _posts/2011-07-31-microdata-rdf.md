---
layout: drupal-post
title: Microdata + RDF
created: 1312142144
tags:
- rdf
- rdfa
- microdata
---
As part of the ongoing discussion about how to reconcile RDFa and microdata (if at all), [Nathan Rixham](http://webr3.org/blog/) has put together a suggested [Microdata RDFa Merge](http://www.w3.org/wiki/Microdata_RDFa_Merge) which brings together parts of [microdata](http://www.whatwg.org/specs/web-apps/current-work/multipage/microdata.html) and parts of [RDFa](http://www.w3.org/TR/rdfa-core/), creating a completely new set of attributes, but a parsing model that more or less follows microdata's.

I want here to put forward another possibility to the debate. I should say that this is just some noodling on my part as a way of exploring options, not any kind of official position on the behalf of the W3C or the TAG or any other body that you might associate me with, nor even a decided position on my part.

<!--break-->

## Simplifying RDFa ##

As [I've said before](http://www.jenitennison.com/blog/node/103), RDFa, in my experience, is complicated not primarily because of the whole namespaces/CURIEs issue but because its processing model tries to be too clever. RDFa was designed to largely fit in with existing markup and turn it into embedded data "just" by adding a few attributes here and there. Thus a simple image like:

    <img src="photo1.jpg">

is first marked up to indicate that it's an image:

    <img src="photo1.jpg" typeof="foaf:Image">

then to provide its license:

    <img src="photo1.jpg" typeof="foaf:Image"
      rel="license" resource="http://creativecommons.org/licenses/by/2.0/">

and finally to add a title:

    <img src="photo1.jpg" typeof="foaf:Image"
      rel="license" resource="http://creativecommons.org/licenses/by/2.0/"
      property="dc:title" content="A Pretty Picture">

all by adding attributes to the one `<img>` element. The trouble with this approach is that the rules about how statements are made become extremely complex, dependent on context (eg what other attributes are present, what the parent element has on it, what content it has) and default in ways that are hard to remember.

Even having written an RDFa parser, having written code to mark up documents with RDFa, having *taught* it, I still cannot write RDFa past a trivial example and be 100% sure that it will produce what I was aiming to produce.

If we were to look at really simplifying RDFa, rather than making cosmetic changes, we need to address this complexity. It would certainly mean backwards-incompatible changes, such as dropping the use of particular attributes and revising the way the processing model works, such that future RDFa processors couldn't be used on RDFa 1.0. There are two possible ways of approaching this:

  1. retaining some backwards compatibility, and aiming for a simplified subset of RDFa 1.0 such that RDFa 1.0 processor will still get the intended triples out of data marked up with RDFa 1.1
  2. dropping backwards compatibility entirely and using completely different attributes, essentially creating a new language

I do not know which of these routes is the best one to take.

My instinct is that the first will be hard to do. For example, there are already certain simplifications in RDFa 1.1 -- such as assuming an element with no `datatype` attribute is giving a string value rather than looking to see if there are any non-text-nodes in the content of the element -- which lead to markup that will not be processed correctly by RDFa 1.0 processors. Perhaps that could be addressed by rewriting history: creating a RDFa 1.0 Second Edition that includes any changes that are needed to make a simple subset viable.

What I want to explore here is what the second route -- using entirely different attributes from those currently used in RDFa 1.0 -- might mean. I think that in this case the substantial difference between microdata and this new language would be support for that much-derided requirement: decentralised extensibility.

## Adding Decentralised Extensibility to Microdata ##

As I discussed [earlier in the week](http://www.jenitennison.com/blog/node/161), microdata is simply not designed for use in a web where publishers might want to use multiple vocabularies to mark up the same thing for different consumers. This focus is very probably the right one for the majority of uses, where publishers address single consumers or everyone has standardised on a single vocabulary. It's certainly an assumption that keeps the markup simple.

However, there is a larger data web out there. It's not just browsers and search engines who might look for and process data embedded within a page. Unlike with HTML, those few, large consumers don't have to understand a particular vocabulary for other consumers to get valuable information from it. If you operate in a world of multiple consumers with different requirements, you need decentralised extensibility. And support for decentralised extensibility is RDF's niche as a data model, its unique selling point.

Given that a new language would have to use a different processing model from RDFa 1.0, I would suggest that it simply uses microdata's as a starting point. Using attributes from RDFa 1.0 would only cause conflicts with RDFa 1.0 processors. Microdata processing is there, already defined, already implemented. It isn't going to go away. And you know, *it's pretty good*.

The 'new language' would then not so much a 'new language' as an enhancement on something that already exists. It would be a set of additions that augment the data that is generated from normal microdata processing with a few extra features that are useful in a world where there are multiple vocabularies for the same domain, where publishers have to provide data to multiple consumers, where an RDF view of data is useful. Call it microdata+RDF.

So what would we need to add? Well, there are three things, I think, that make microdata hard to use in a decentralised world, and make it hard to generate good RDF from microdata markup:

  1. lack of support for multiple types
  2. scoping of properties by type
  3. lack of datatypes

We would need to find a way to add these for use within the RDF extracted from the microdata markup such that a basic microdata parser would still generate the same JSON, and such that microdata's DOM API would work as specified in the microdata spec. So we can't change the types of values that are possible in microdata's attributes or how they're interpreted in the DOM API.

### Multiple Types ###

Because of the restrictions I just mentioned in not touching microdata itself, we can't simply make `itemtype` take multiple URLs. We could rely on `itemprop="http://www.w3.org/1999/02/22-rdf-syntax-ns#type"` as a mechanism of providing types for use by RDF processors, but I think that the types of something is such a fundamental property that it makes sense to have a dedicated attribute.

I suggest `itemclass`. It would only be allowed on elements with an `itemscope` attribute and would take a space-separated set of values in exactly the same way as the `itemprop` attribute. The values would be turned into URIs in the same way as for the `itemprop` attribute, which I'll describe below.

Microdata+RDF would add a method to the existing microdata DOM API to enable people to access items by class rather than their single type. So:

    document . getItemsByClass( classes )
    Returns a NodeList of the elements in the Document that create items, that are not 
    part of other items, and that have one or more of the types or classes given in the 
    argument.
    
    The classes argument is interpreted as a space-separated list of classes.

Note that for simplicity, because they are interpreted in the same way within the RDF model, this returns items whose `itemtype` is listed in the argument list of classes as well as those whose `itemclass` is listed.

Within the DOM API, the `itemClass` IDL attribute on HTML elements would reflect the `itemclass` attribute.

The `itemclass` attribute would be ignored for the purpose of creating JSON from microdata, and only be used when creating RDF.

An example would be:

    <li class="conference" itemscope itemid="/2011/oscon/"
        itemtype="http://schema.org/Event"
        itemclass="http://microformats.org/profile/hcalendar#vevent /vocab/Conference">
      ...
    </li>

The JSON generated from this would look like:

    {
      "type": "http://schema.org/Event" ,
      "id": "http://lanyrd.com/2011/oscon/",
      "properties": {}
    }

The RDF would look like:

    <http://lanyrd.com/2011/oscon>
      a <http://schema.org/Event> ,
        <http://microformats.org/profile/hcalendar#vevent> ,
        <http://lanyrd.com/vocab/Conference> ;
      .

### Disambiguating Properties ###

To work with the RDF model, properties have to have URIs. We need to have a way of easily creating the URIs for the short-name properties without people changing their existing microdata markup.

> Note: I've substantially revised this section following discussion with [Philip Jägenstedt](http://blog.foolip.org/). Old text is struck through, new text underlined.

The way that this is done in RDFa 1.1 is through a `vocab` attribute, which provides a URI prefix that is concatenated to any short-name properties or types. <strike>We could use the same approach here, but call the attribute `itemvocab` to fit in with the general method of naming attributes in microdata.</strike> <u>Using this with microdata would be tedious for users however, and it would be easy for the `itemtype` and `itemvocab` to get out of sync in weird ways.</u>

<strike>`itemvocab` would only be allowed on elements with an `itemscope`. The scope of `itemvocab` would be limited to the item itself, so that it's not forgotten when it's needed, particularly in copy-and-paste scenarios. However, to make it easier to use I think it should probably be given a default value if it isn't present, as follows:</strike>

<u>Instead, the vocabulary for the properties could be identified as follows:</u>

  1. set *vocab* to the `itemtype` of the item if it is present, and the URL of the document if not
  2. use a substring of *vocab*:
    1. if *vocab* contains a `#`, the substring of *vocab* up to and including the `#`
    2. otherwise, the substring of *vocab* up to and including its final `/`

For example, if you have:

    <li class="conference" itemscope itemid="/2011/oscon/"
        itemtype="http://schema.org/Event"
        itemclass="http://microformats.org/profile/hcalendar#vevent /vocab/Conference">
      ...
    </li>

then <strike>`itemvocab`</strike> <u>the item vocabulary</u> would default to `http://schema.org/`.

<strike>There could be an extra restriction that if `itemtype` is specified, `itemvocab` must be in the same domain as that type; that could help prevent the weird situation where in the generated RDF the properties would be interpreted as being in a completely different vocabulary from the `itemtype`.</strike>

<strike>Within the DOM API, the `itemVocab` IDL attribute on HTML elements would reflect the `itemvocab` attribute.</strike>

<u>Note: the following example has been altered in place.</u>

For example, take the following markup:

    <li class="conference" itemscope itemid="/2011/oscon/"
        itemtype="http://schema.org/Event" 
        itemclass="SocialEvent BusinessEvent EducationEvent">
      <h3>
        <a itemprop="url" href="/2011/oscon/">
          <span itemprop="name">OSCON 2011</span>
        </a>
      </h3>
      <p itemprop="location" itemscope itemid="/places/portland/"
         itemtype="http://schema.org/Place">
        <span itemprop="name"><a href="/places/usa/">United States</a> / <a itemprop="url" href="/places/portland/">Portland</a></span>
      </p>
      <p class="date">
        <time itemprop="startDate" datetime="2011-07-25">25th</time>–
        <time itemprop="endDate" datetime="2011-07-29">29th July 2011</time>
      </p>
      ...
    </li>

The vocabulary for the `<li>` element defaults to `http://schema.org/` based on the value of the `itemtype`. The short-named properties and classes within that item are turned into URIs by pre-pending `http://schema.org/` to their name. Similarly, the properties on the nested `http://schema.org/Place` are pre-pended with `http://schema.org/Place/`. The resulting RDF would be:
  
    @prefix s: <http://schema.org/>
    
    </2011/oscon/>
      a s:Event ,
        s:SocialEvent ,
        s:BusinessEvent ,
        s:EducationEvent ;
      s:url <http://lanyrd.com/2011/oscon/> ;
      s:name "OSCON 2011" ;
      s:location </places/portland/> ;
      s:startDate "2011-07-25"^^xsd:date ;
      s:endDate "2011-07-29"^^xsd:date ;
      .
    
    </places/portland/>
      a s:Place ;
      s:url <http://lanyrd.com/places/portland/> ;
      s:name "United States / Portland" ;
      .

Note: see below for how the values are created in this example.

The JSON would be just the same as from a standard microdata processor; there's no mapping to URIs for that output:

    {
      "type": "http://schema.org/Event",
      "id": "http://lanyrd.com/2011/oscon/",
      "properties": {
        "url": [
          "http://lanyrd.com/2011/oscon/"
        ],
        "name": [
          "OSCON 2011"
        ],
        "location": [
          {
            "type": "http://schema.org/Place",
            "id": "http://lanyrd.com/places/portland/",
            "properties": {
              "name": [
                "United States / Portland"
              ],
              "url": [
                "http://lanyrd.com/places/portland/"
              ]
            }
          }
        ],
        "startDate": [
          "2011-07-25"
        ],
        "endDate": [
          "2011-07-29"
        ]
      }
    }

### Adding Datatypes ###

How to manage datatypes in RDF generated from microdata is something where the best approach is not at all clear to me. A couple of years ago I talked about some [frustrations with RDF datatyping](http://www.jenitennison.com/blog/node/120), and datatypes in RDF still frustrate me by being hard to use in sensible ways throughout the RDF toolchain. Nevertheless, it's what we have. 

The possibilities I can see for microdata+RDF are:

  1. Use plain literals for everything, including URIs, equivalent to using strings as microdata does. This makes things simple for the publisher and keeps the markup in the page clean, but makes it difficult for consumers who are using RDF toolchains: they will *usually* have to do some kind of processing of the RDF generated from microdata+RDF to add appropriate datatypes to the values. There are two issues with this approach:
  
    * I have a feeling that microdata+RDF processors will make up their own rules to add datatypes to the data extracted from a page (using rules like those described below and/or sniffing of values and/or using information from known built-in vocabularies), in an effort to add value for their users. But if different processors do that in different ways, we have an interoperability problem.
    * In some vocabularies, the datatype of a value is not derivable from the property. The most important/common example of this is [`skos:notation`](http://www.w3.org/TR/skos-reference/#notations), which uses values with different datatypes to supply different identifiers from different identification schemes for a given concept.

  2. Assign datatypes based on the element type in the HTML. If the property value has come from a URL attribute, assume that it's a resource rather than a literal; if the element is a `<time>` element, work out the datatype based on the syntax of the `datetime` attribute; otherwise assume it's a string and give it a language in the case that one is specified. This gives some information but leads to a somewhat strange situation where you can mark up something as a date/time but not as a number.

  3. Supplement the processing described in 2. with some basic datatype sniffing. Basically, if the value looks like a number or a boolean value then assign it a numeric or boolean datatype based on its syntax. This could reuse the [rules for recognising different literals from Turtle](http://www.w3.org/TeamSubmission/turtle/#literal). This wouldn't be perfect; in particular, it would guess that strings that consist purely of numbers such as zip codes were numbers. I'm inclined not to go down this path.

  4. Supplement the processing described in 2. with a `itemvaltype` attribute that takes a token from the list of [built-in XML Schema Datatypes](http://www.w3.org/TR/xmlschema-2/#built-in-datatypes) or the token '`literal`'. The '`literal`' token would be used to override the normal processing of URL attributes in the case where those really should be literals rather than resources. In this design, it would be easy to create literals using one of the most usual datatypes, but not possible to use datatypes that are specific to a given vocabulary.
  
  5. Supplement the processing described in 4. by allowing the `itemvaltype` to take either a token or a URL. The thing I don't like about this design is that the token would be interpreted as being within the XML Schema Datatypes vocabulary rather than the vocabulary specified for `itemvocab` (used for tokens in `itemprop` and `itemclass`). This seems like it might turn into a source of confusion, but if we went the other way and had `itemvaltype` being interpreted based on `itemvocab`, it would be harder to give a value the more common datatypes such as numbers and boolean values.

My inclination, somewhat reluctantly as it's the most complex, would be to use the last of these, because it provides for decentralised extensibility of datatypes, and support for decentralised extensibility is the core aim of these extensions. In other words, have a `itemvaltype` attribute that can hold either a token, which must be one of `literal` or the local name of an XML Schema datatype, or a URL. On a `<time>` element, this would default to the appropriate type based on the syntax of the value of the `datetime` attribute.

To be conformant, the `itemvaltype` would have to be an allowed value type for the properties given in `itemprop` and the value of the property must be a legal value for the datatype. (In keeping with the style of the microdata specification, the mechanisms for working out what value types are allowed and what the legal values are for non-XML Schema datatypes would be left undefined -- a consuming application would look at the definition of the vocabulary.)

Within the DOM API, the `itemValType` IDL attribute on HTML elements would reflect the `itemvaltype` attribute. The value of `itemvaltype` *wouldn't* change the types of the values returned by `element.itemValue` or in the JSON mapping from microdata; it would purely be used when generating RDF from that data.

For example, if someone started with some markup like:

    <div itemscope itemtype="http://schema.org/AggregateOffer">
      Priced from: <span itemprop="lowPrice">$35</span>
      <span itemprop="offerCount">1938</span> tickets left
    </div>

it might be supplemented with some type information like:

    <div itemscope itemtype="http://schema.org/AggregateOffer">
      Priced from: <span itemprop="lowPrice" itemvaltype="http://schema.org/Price">$35</span>
      <span itemprop="offerCount" itemvaltype="integer">1938</span> tickets left
    </div>

which would generate RDF like:

    @prefix s: <http://schema.org/>
    
    [] a s:AggregateOffer ;
      s:lowPrice "$35"^^s:Price ;
      s:offerCount 1938 ;
      .

(Note: Here I'm assuming that schema.org defines a `http://schema.org/Price` datatype which includes a currency and a number. They don't currently.)

The JSON would still be:

    {
      "type": "http://schema.org/AggregateOffer",
      "properties": {
        "lowPrice": [
          "$35"
        ],
        "offerCount": [
          "1938"
        ]
      }
    }

### Non-Additions ###

When I wrote a couple of years ago about [what microdata can't do](http://www.jenitennison.com/blog/node/103), one of the things that I identified was not being able to express XML Literals. Having thought about this more, what's actually missing isn't to do with RDF, but is the ability to use the [`innerHTML`](http://www.whatwg.org/specs/web-apps/current-work/multipage/content-models.html#innerhtml) of an element to provide a value for a property rather than its [`textContent`](http://www.whatwg.org/specs/web-apps/current-work/multipage/infrastructure.html#textcontent).

For example, the description of an event might run over several paragraphs, or even in a single paragraph include other markup such as emphasised text, ruby markup, or links to additional information. People who are working from the DOM API can capture this information when they need it by getting the `innerHTML` of the element rather than its `itemValue`, but in the JSON mapping, the value is always the `itemValue` -- the text content of the element.

So this is a general microdata simplifying limitation. I'd argue that we shouldn't add any special handling to plug this hole at the microdata+RDF level. If it turns out that having values that contain markup is useful then it will be added to microdata, and the microdata+RDF mapping would then be extended to create `rdf:XMLLiteral`s or HTML literals (for which there is no defined datatype in RDF at the moment) for such values.

Similarly, I haven't said anything in this post about providing machine-readable values to override the text content of an element. There is [an open bug](http://www.w3.org/Bugs/Public/show_bug.cgi?id=13240) about whether and how that capability might be added to HTML/microdata. I happen to think that it's useful, but that utility isn't limited to RDF processing. Whichever route is chosen there, I think it's important to keep the property values used by basic microdata and microdata+RDF aligned.

## Summary ##

To summarise, one direction that we could take in aligning microdata and RDFa would be to define an extension to microdata to add support for decentralised extensibility and the RDF data model. I think that would entail adding attributes such as:

  * `itemclass` to make it easy to define multiple types for an item
  * `itemvocab` and some default processing to provide nice mappings for short-name properties into URIs
  * `itemvaltype` and some default processing to assign datatypes to values

For publishers and consumers, a single language with optional extensions greatly simplifies the use of embedded data. Property names don't have to be repeated or balancing acts made between different processing models.

RDFa proponents get a syntax that can be used to generate a natural RDF model against which they can build RDF-oriented APIs and map to other formats such as JSON-LD.

For microdata proponents, this approach doesn't pollute microdata with requirements that they see as superfluous, and doesn't change the behaviour of core microdata processors. Browsers, search engines and other consumers can continue to use the JSON output and only those who really want to support RDF need to do so.

I'm sure that there are things that I've missed in my outline above, issues that I haven't thought of. But if there is to be any kind of convergence between microdata/RDFa, this layered approach seems to me to be the kind of convergence that is most likely to eventually result in one language for embedding data in HTML rather than two or three.

**Note: if you prefer to comment on Google+, please add your comment to [my announcement post there](https://plus.google.com/u/0/112095156983892490612/posts/aUqGQSLzDPv)**
