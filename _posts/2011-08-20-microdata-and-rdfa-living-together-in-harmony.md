---
layout: drupal-post
title: Microdata and RDFa Living Together in Harmony
created: 1313858351
tags:
- rdfa
- microdata
---
One of the options that the TAG put forward when it [asked the W3C to put together task force on embedded data in HTML](http://lists.w3.org/Archives/Public/public-html/2011Jun/0366.html) was the co-existence of RDFa and microdata. If [that's what we're headed for](http://lists.w3.org/Archives/Public/www-tag/2011Aug/0050.html), what might make things easier for consumers and publishers who have to live in that world?

In a situation where there are two competing standards, I think that developers -- both on the publication and consumption sides -- are going to want to hedge their bets. They will want to avoid being tied to one syntax in case it turns out that that syntax isn't supported by the majority of publishers/consumers in the long term and they have to switch.

Publishers like us at [legislation.gov.uk](http://www.legislation.gov.uk/) who are aiming to share their data to whoever is interested in it (rather than having a particular consumer in mind) are also likely to want to publish in both microdata and RDFa, rather than force potential consumers to adopt a particular processing model, and will therefore need to mix the syntaxes within their pages.

(Of course developers might just avoid embedded data altogether while they wait to see what happens, but let's assume that they want to press ahead regardless of the lack of consensus from the standardistas.)

I've therefore embarked on a task of trying:

  * to identify the differences in approach and functionality of the two languages, which should help developers choose between them
  * to identify any guidelines for developers of vocabularies for use with both languages
  * to identify a subset of functionality that is common between the two languages, which developers might want to stick to to make switching and mixing easier
  * to identify mapping rules that might be applied to automatically or manually map from one language to another if the simple subset is used

I've done this by looking at converting microdata examples to RDFa and vice versa, and the lessons to be drawn from that exercise. I've broken down the result into three posts:

  * [converting microdata to RDFa](http://www.jenitennison.com/blog/node/163)
  * [converting RDFa to microdata](http://www.jenitennison.com/blog/node/164)
  * [lessons learned from this exercise](http://www.jenitennison.com/blog/node/165)

This is the last of these posts. It is probably the only one you will want to read :)

<!--break-->

Please treat this as a draft on which I'd welcome comments. I have based what's written here on the latest specifications of both microdata (in its [WHAT WG](http://www.whatwg.org/specs/web-apps/current-work/multipage/microdata.html) and [W3C](http://dev.w3.org/html5/md/Overview.html) variants) and [RDFa Core](http://www.w3.org/2010/02/rdfa/drafts/2011/ED-rdfa-core-20110814/) and [HTML+RDFa](http://dev.w3.org/html5/rdfa/) but I haven't consulted with anyone involved in these efforts and may well have got things wrong. Plus the specs are changing all the time. I have only here considered the syntax of the two languages, not the features such as DOM APIs or drag-and-drop support, where there are also clear differences.

Please add comments if there are things that I've missed or got wrong, or just to have your say.

[Philip Jägenstedt's Live Microdata service](http://foolip.org/microdatajs/live/) and [Gregg Kellogg's Distiller service](http://rdf.greggkellogg.net/distiller) have both proved invaluable for testing -- thank you to both for making these services available. I heartily recommend them.

## Mapping Rules

The first problem is how to judge equivalence when microdata and RDFa have different data models. Microdata essentially uses a JSON data model: there are objects (items) with properties that have values that are strings, other objects, or arrays of strings or objects or both. RDFa naturally uses a RDF data model: there are resources with properties that have values that are literals (of some datatype or with a language) or other resources.

Underlying both is the same basic entity-attribute-value pattern, but there are various mismatches between the models that make some mappings more complicated than others, or in other cases mean that information is necessarily lost on conversion.

In performing the analysis, I've tried to map microdata into sensible RDF and then match that RDF output using RDFa, and to map RDFa into sensible microdata+JSON and then match that microdata+JSON using microdata. The microdata-to-RDF mapping rules that I've followed are basically those outlined in my post on [Microdata + RDF](http://www.jenitennison.com/blog/node/162). To create microdata JSON from RDFa, I've used the rule that the URI of the first type of a resource is processed to provide a namespace that is stripped from the URIs of the properties (to create simple names where possible). In addition, when a resource has no properties, it will be represented as a string (URI) value rather than as a nested item.

These rules need to be formalised, obviously, but the basics above work well enough for the examples from the specs.

## Mismatched Features

The following features are problematic when mapping from microdata to RDFa or vice versa. I've described them roughly in an order from things where it might be relatively easy to address the problem by changing one or other specification, to places where the necessary changes would be difficult to make in the specs, which means that publishers and consumers need to be aware of the issue so that they can make an educated choice about how they proceed.

### Local Property Names

Many of the microdata examples involve items with no type and local property names. I've assumed in the analysis below that this generates properties whose URI is based on the document in which they are found, but this is not a helpful solution for data sharing: if a whole site uses short property names across its pages, those properties really need to be recognised as being the same across the site for any kind of useful processing to occur.

What microdata actually creates here is a global namespace, shared by everyone, specifically for embedded data. There are three things that could be done at different levels here:

  1. In a mapping from microdata to RDF, any short property names on items that don't have a type could be assigned to a global namespace (eg `http://w3.org/ns/global/`). Of course there will be clashes in semantics within this namespace, but that is true in microdata generally and not having to create a new namespace makes the initial experimentation easier for those starting with embedded data. The W3C (or whoever operates the namespace) could operate a wiki at that location that would operate as an informal registry for the property names.
  
  2. HTML+RDFa could change to use this global namespace as the default vocabulary URI (rather than not having one). This would make it a little easier for people to convert microdata to RDFa: if they don't use types for their items, there would then be no need for a `vocab` attribute to be added to the HTML. It also makes it possible to use RDFa in a basic, lightweight way, which might help people get started with it.
  
  3. Publishers can be advised to use `itemtype` within their microdata, reusing existing classes or creating their own, if they want to ensure that the embedded data within their pages isn't misinterpreted by global consumers.

### Interpretation of `<time>` Element's `datetime` Attribute

Interpreting the `datetime` attribute of the `<time>` element to supply a value, rather than repeating that value in a `content` attribute, is [ISSUE-97](http://www.w3.org/2010/02/rdfa/track/issues/97) on RDFa, and hopefully RDFa will be changed to use that value (or the content of the element if there is no `datetime` attribute), add a seconds component if necessary, and work out an appropriate date/time datatype for it based on its syntax.

### Content Overrides

In RDFa, publishers can provide a machine-readable version of the content of an element (or even an entirely different value) using the `content` attribute. This can only be done for date/times in microdata. The ability to [annotate non-date/time content with machine-readable values](http://www.w3.org/Bugs/Public/show_bug.cgi?id=13240) is a current issue on HTML5. Resolving this in favour of providing such annotation would make using RDFa and microdata in concert, or converting between them, easier, particularly if HTML5 uses the attribute `content` or RDFa adopts whatever attribute is introduced to HTML5.

### `<link>` and `<meta>` Elements in Flow Content

The ability to [use `<link>` and `<meta>` elements in flow content](http://dev.w3.org/html5/md/Overview.html#content-models) is only supported in microdata: it's support that's added by the microdata specification (in the Editor's Draft since May 31st; the text allowing this didn't make it into the Last Call version of the spec), in which it's limited to `<link>` and `<meta>` elements with an `itemprop` attribute. 

It would be possible for the RDFa specification to similarly make the statement that `<link>` and `<meta>` elements are allowed in flow content as long as they have particular attributes. This would ease the transition between the two formats, and works a lot better than empty `<span>` elements which crop up fairly commonly in RDFa content.

(One oddity here is that because date/time values have to be on a `<time>` element in microdata, publishers cannot replace empty `<time>` elements with `<meta>` elements as they might an empty `<span>`.)

### Identifiers without Types

Many of the RDFa examples are of resources that have a URI identifier but for which no type is supplied. Microdata, on the other hand, states that `itemid` is only allowed on elements that also have an `itemtype` (and an `itemscope`). The reason given is because the `itemid` needs to be interpreted based on the `itemtype`. This would be understandable if it held a string, but given that the `itemid` provides a URI it seems a bit strange. Perhaps it's an attempt to avoid the whole [httpRange-14 / ambiguity in URIs issue](http://www.jenitennison.com/blog/node/159).

If this restriction remains, the advice to RDFa users who might want to convert to microdata at a future date would be to always provide a type for your (non-blank-node) resources. It may be useful to define a `http://w3.org/ns/global/Thing` within the vocabulary that I propose above, given that the URI for `rdfs:Resource` is long and hard to recall.

### Built-in Prefixes

The built-in [profile for RDFa](http://www.w3.org/profile/rdfa-1.1) defines a number of prefixes for vocabularies that are either coined by the W3C or coined elsewhere but in common use on the web. This, coupled with `vocab` and the ability to directly use URIs in the relevant attributes, means that declaring prefixes within the document is increasingly unnecessary in RDFa.

In contrast, using existing vocabularies, even popular ones, within microdata is relatively difficult, particularly when vocabularies are mixed on the same item.

Most useful for publishers would be if both RDFa and microdata recognised the same set of prefixes. This would reduce the size of microdata created from existing RDFa content as well as making it easier to move between the languages. At the very least, it would be good to have `rdf:`, `rdfs:`, `xsd:` and `xhv:` built into both.

The list of popular vocabularies is likely to change over time; for example a prefix for the schema.org vocabulary might be useful at some point in the near future. The problem is that publishers and consumers need to be synchronised in their use of prefixes: it's no good for a publisher to use the prefix `sch:` if there might be processors for the page that don't recognise it. Equally, consumers shouldn't be reliant on a network connection to retrieve the latest set of prefix mappings in order to parse the page. It's not clear to me how best to manage this evolution, but even a fixed set of prefixes at the point the specs reach Recommendation is more usable than spelling out URIs all the time.

### Literals Including Markup

RDFa supports literals that include markup (the `innerHTML` of an element) as well as those that don't (the `textContent` of an element), whereas microdata only supports creating values from particular attributes or the `textContent` of the element. This makes it hard to create embedded microdata that includes values which contain things like mathematical or chemical formulae, ruby text, or multiple paragraphs.

A solution would be for microdata to introduce an `itemhtml` (or something) attribute that, when present, indicates that the value of the property should include markup. There is a current issue on microdata to [support HTML values](http://www.w3.org/Bugs/Public/show_bug.cgi?id=13468).

### Itemref

RDFa can support a subset of `itemref`'s functionality, namely to have properties defined elsewhere in a document be associated with a given resource. What it doesn't support is the sharing of properties defined in one place by two or more resources.

RDFa could add such support by adding an attribute that mirrors `itemref` (eg `ref`, I guess), with the referenced element being processed using the [evaluation context](http://www.w3.org/TR/rdfa-core/#evaluation-context) inherited by the referencing element (which means that attributes such as `vocab` would sometimes have a scope that wasn't based on the document tree). This would make it easier to tackle the use case for `itemref` using RDFa as well as making it easier to move between or mix RDFa and microdata.

### Lists

It is easy for microdata to represent a property with a list of values, and really really hard to do the same in RDFa. This is in part because RDF views lists resources rather than a distinct data type, and in part because RDFa hasn't added any syntax sugar to make creating `rdf:List` resources easy. Adding some syntax sugar for lists would make life a lot easier for anyone using RDFa, but especially if they are adapting existing microdata content to RDFa.

### Datatypes

Microdata assumes that consumers will convert values to appropriate datatypes based on the property (which they understand) as a separate process after microdata processing, whereas RDFa supports the use of a `datatype` attribute to explicitly indicate the datatype of each value. This mismatch means that information is lost when RDFa is converted to microdata, and has to be added when microdata is converted to RDFa.

Bringing the languages completely into sync would mean either microdata adding a facility to support (at least some) datatypes, or deprecating the `datatype` attribute in RDFa. Alternatively, this may simply be an area where the differences in behaviour between the two specifications doesn't matter because the data models that they use are distinct anyway.

### Languages

Languages are similar to datatypes, in that RDF (and hence RDFa) supports annotating strings with the language that they are in whereas microdata doesn't within its core data model or its JSON serialisation. However, the elements that represent properties within the HTML, used within the DOM API access to microdata, will have a language.

It may be that in practice consumers need to base their microdata processing on the DOM API rather than the core microdata data model or JSON extracted through a standalone process, and thus pick up the language from the property elements, I don't know. In any case, the microdata JSON serialisation, used for drag-and-drop, is lossy and could be extended to include the language of each value when available, at fairly substantial complexity cost.

For publishers, it doesn't much matter either way; if they are dealing with multi-lingual text they will want to include a `lang` attribute in the HTML anyway, regardless of the impact on embedded data.

### Multiple Types

RDFa supports having multiple types named in the `typeof` attribute whereas microdata only supports one type per item. In any mapping from RDFa to microdata, publishers have to choose which type is the primary type for the item and move the others to be expressed via `rdf:type` properties. Consumers who want to support publishers who might not choose their type as the primary type have to detect items that have the type they are interested in within the `rdf:type` property as well as those which have the type as the main type. Given that the `rdf:type` URI is long and (naturally) associated with RDF, it might be better to define a property such as `http://w3.org/ns/global/type` for this use.

Microdata could be extended to allow multiple values in the `itemtype` attribute, with the first being used to interpret any properties that aren't full URIs. This would make it easier for both consumers to detect when a type they were interested in was used and for publishers to use RDFa and microdata in tandem or move between them.

### The `src` Attribute

RDFa and microdata interpret the `src` attribute in opposite ways. In RDFa, it provides the identifier for a new resource (equivalent to `itemid` in microdata); in microdata, it provides a URL value of a property on elements that support it (equivalent to `resource` or `href` in RDFa).

RDFa interprets `src` in this way to make it easier to make assertions about an image, but it's of limited effect as even in RDFa its only possible to make three such assertions (through the `typeof`, `rel` and `property` attributes). So, for example, you can specify the type of the image, link to its license and give the name of its creator, with:

    <img src="photo1.jpg" typeof="foaf:Image"
      rel="license" resource="http://creativecommons.org/licenses/by/2.0/"
      property="dc:creator" content="Mark Birbeck">

but this won't help you if you *also* want to give the title for the image and when it was created (say). At that point, the microdata and RDFa start to look similar:

    <div itemscope itemid="photo1.jpg" itemtype="http://xmlns.com/foaf/0.1/Image">
      <link itemprop="license" href="http://creativecommons.org/licenses/by/2.0/">
      <meta itemprop="http://purl.org/dc/terms/creator" content="Mark Birbeck">
      <meta itemprop="http://purl.org/dc/terms/title" content="Picture of Mark">
      <time itemprop="http://purl.org/dc/terms/created" datetime="2009-03-17"></time>
      <img src="photo1.jpg">
    </div>

or:

    <div about="photo1.jpg" typeof="http://xmlns.com/foaf/0.1/Image">
      <span property="http://purl.org/dc/terms/title" content="Picture of Mark"></span>
      <time property="http://purl.org/dc/terms/created" content="2009-03-17" datatype="xsd:date" datetime="2009-03-17"></time>
      <img src="photo1.jpg" typeof="foaf:Image"
        rel="license" resource="http://creativecommons.org/licenses/by/2.0/"
        property="dc:creator" content="Mark Birbeck">
    </div>

and really, to make the markup consistent, you may as well not use the `src` of the image at all in the RDFa either:

    <div about="photo1.jpg" typeof="http://xmlns.com/foaf/0.1/Image">
      <span rel="license" href="http://creativecommons.org/licenses/by/2.0/"></span>
      <span property="http://purl.org/dc/terms/creator" content="Mark Birbeck"></span>
      <span property="http://purl.org/dc/terms/title" content="Picture of Mark"></span>
      <time property="http://purl.org/dc/terms/created" content="2009-03-17" datatype="xsd:date" datetime="2009-03-17"></time>
      <img src="photo1.jpg">
    </div>

So it's not clear to me that interpreting the `src` attribute as the subject of triples offers such a huge advantage that it's worth the inconvenience that it brings for the simple things, such as having to use:

    <span rel="image"><img src="google-logo.png" alt="Google"></span>

rather than:

    <img property="image" src="google-logo.png" alt="Google">

### Link relations

This isn't so much a clash between RDFa and microdata as between the interpretation that RDFa has for the `rel` attribute and that specified in HTML.

The built-in `rel` values in HTML are a bit of a mix. Some of them, like `alternate`, `prev` and `next` encode relationships between the document in which the link appears and another document. Others, such as `bookmark` and `help`, create relationships between the context in which the link is found and the referenced document. Still others, like `nofollow`, `noreferrer` and `prefetch`, are really instructions to the client about how to manage the act of traversing the link.

It doesn't seem semantically correct to automatically create relationships based on the built-in HTML `rel` values, unless you are deliberately trying to extract [*document* semantics](http://lin-clark.com/blog/two-meanings-semantics-html5) from the page. This is a problem for RDFa, which reuses the `rel` attribute to provide property values for the embedded *data*.

One thing that could be done would be for RDFa to consistently use the `property` attribute everywhere rather than the `rel` attribute. This would not only ease the overloading but also reduce the confusion for users, who currently have to work out which attribute to use based on whether the value is a resource or a literal.

## Possible Subset of RDFa

When mapping from microdata to RDFa, the only attributes that are really needed are:

  * `vocab` to define a vocabulary for the types and properties within its scope (not technically necessary, but keeps the markup simple compared to spelling out URIs for everything)
  * `typeof` to define the type of a resource or indicate a new blank node
  * `about` to provide a URI for a resource or a local identifier for a blank node
  * `property` and `rel` to define property names (though see above for discussion about dropping `rel`)
  * `href`, `src` and `content` to provide values (and `datetime` assuming that is supported)

In the mappings in the analysis below, I did also use the `resource` attribute, but only to create a reference to a blank node that was described elsewhere, when replicating the functionality of `itemref`. If RDFa were to enable `<link>` and `<meta>` in content in the same way as microdata, `resource` functionality could be replicated using `<link>`; as it is, you can get away with using an empty `<a>` element.

Similarly, I only used `datatype` when providing a datatype for date/time values, something that could be done automatically by RDFa. But this isn't surprising given that microdata doesn't support datatypes at all and the examples I was using for the mapping were from the microdata specification.

There was no need for:

  * `prefix` which defines prefixes to simplify references to properties and classes; this is hardly surprising as few of the microdata examples involved mixing namespaces, but it's notable that the built-in prefixes of `rdf:` and `xsd:` were useful
  * `profile` which is a pointer to an external document that defines a set of terms; this is being dropped from RDFa in any case

I also kept to a simplified version of the syntax in which each property element only provided one value. This subset is basically:

  * resource elements can have `about` (equivalent to `itemid`) and `typeof` (equivalent to `itemtype`) attributes on them
  * property elements can have `property` or `rel` (equivalent to `itemprop`), and a value-providing attribute on them such as `href` or `content`
  * no element is both a resource element and a property element; to provide a property whose value is a resource, nest the resource element within the property element (using "hanging rel" processing)
  * no property element should provide more than one value for a property; in particular, a "hanging rel" should only have a single resource element child

This simplified profile of RDFa is fairly easy to remember and maps easily to and from microdata: most attributes can be simply renamed; the only attribute that needs to be moved as well as renamed is the "hanging rel", which moves onto the resource element and is renamed to `itemprop`. Note that it also means avoiding using the `src` attribute to encode embedded data.

In addition to sticking to this subset of attributes, developers might be advised that using HTML link relations may lead to clashes with browser or search engine interpretation of the links in the page.

## Possible Subset of Microdata

Microdata is pretty minimalistic already. The only feature that developers need to be warned about is `itemref`, which has no RDFa equivalent at the moment.

## Guidelines for Vocabulary Authors

There are a several guidelines that come out of this comparison for people putting together vocabularies that aim to be usable in both RDFa and microdata:

  * The classes in the vocabulary should be distinct, or subclasses created with any relevant combinations of superclasses, so that publishers don't have to assign more than one type to an item/resource. This restriction helps with using the vocabulary with microdata, which assumes that every item has a single type.
  * Provide explicit classes for everything which you anticipate might be given an identifier, as microdata doesn't (currently) enable items to have an identifier without also having a type.
  * Put classes and properties in the same namespace, but do not name classes and properties with the same local name; while this doesn't matter in microdata because the properties are interpreted relative to the class, standard conversions to RDF will create a class and a property with the same URI. URIs are case-sensitive to a simple way of ensuring that there aren't clashes is to follow the usual RDF convention of beginning class names with an upper-case letter and property names with a lower-case letter.
  * Avoid property names that contain dots, as these aren't allowed in non-URI property names in microdata.
  * Ensure that properties either only expect one type of value or expect values whose type can be sniffed based on the syntax of the value. If publishers use microdata, they will not be able to indicate the type of a value through the markup.
  * Be aware that consumers of microdata using your vocabulary will have to use the DOM API to identify the language used in any strings, and that language information won't be carried through the standard microdata JSON serialisation (used by drag-and-drop, for example). If you anticipate multi-lingual use of your vocabulary, you may way to define a `MultiLingual` class with `value` and `language` properties that people can use as nested items. (It may be useful for this class and properties to be defined in the proposed 'global' W3C namespace so that it can be used anywhere.) If you know what languages will be used then provide separate properties for each language (eg for UK legislation I know the languages are English and Welsh so on a vocabulary for UK Legislation I could have `title-en` and `title-cy` properties).
  * To make markup cleaner, only reuse properties from other vocabularies on your classes if they have built-in prefixes (eg unless `rdfs:` is built-in to microdata as well as RDFa, don't use `rdfs:label` to provide a label, but create your own `label` property). On the other hand, do reuse classes from other vocabularies if you don't need to add any specialised properties to them. Note that avoiding reuse has the unfortunate side-effect of not enabling processors that understand these other vocabularies to process your data.
  * Avoid having properties whose values need to be retrieved in order, as these are hard to represent in RDFa. Instead, use properties with distinct names when position is important. (Yes, I know this sucks.)

## Choosing Between Microdata and RDFa

The choices developers make between microdata and RDFa will, I suspect, be largely dictated by what their consumers/toolsets/publishers will support. Nevertheless, there are some features that are better supported by one or other format and might therefore sway developers one way or another:

  * **multi-lingual embedded data** is better supported in RDF than microdata+JSON
  * **explicit datatypes for values** can be provided by RDFa but not microdata
  * **resources with multiple types** are a lot easier to describe in RDFa
  * **property values that include markup** are a lot easier to write in RDFa
  * **mixed vocabulary use** is a bit easier in RDFa than in microdata
  * **HTML5 link relations** may be misinterpreted by RDFa processors
  * **properties with list values** are much easier to support in microdata
  * **common content** adopted by multiple entities is much easier in microdata

## Final Words

I have no doubt that developers would be better off if there were only one recommended way of embedding data in HTML (so long as it met their requirements of course). But realistically that is, and always has been, a long shot, given the entrenched positions of the microdata and RDFa communities.

Regardless, there are lessons that RDFa and microdata could learn from each other, and changes to both languages that would help developers use them on their own, switch between them and mix them in the same document. I expect and welcome debate about the viability and effectiveness of the changes and guidelines that I've suggested here.

Investigating those lessons, documenting those changes and generating those guidelines was something that I had hoped the microdata/RDFa task force would be able to do. The other question to ask, given the argument that there shouldn't be a task force at all if it's not going to be able to bring the languages together, is whether this kind of analysis is worthwhile, and worth publishing as something more official than a blog post?
