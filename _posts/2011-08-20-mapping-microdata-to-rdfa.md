---
layout: drupal-post
title: Mapping Microdata to RDFa
created: 1313858128
tags:
- rdfa
- microdata
---
This post is part of a three-part series that analyses the differences in features and syntax between microdata and RDFa. The series attempts:

  * to identify the differences in approach and functionality of the two languages, which should help developers choose between them
  * to identify any guidelines for developers of vocabularies for use with both languages
  * to identify a subset of functionality that is common between the two languages, which developers might want to stick to to make switching and mixing easier
  * to identify mapping rules that might be applied to automatically or manually map from one language to another if the simple subset is used

I've done this by looking at converting microdata examples to RDFa and vice versa, and the lessons to be drawn from that exercise. The three posts are on:

  * [converting microdata to RDFa](http://www.jenitennison.com/blog/node/163)
  * [converting RDFa to microdata](http://www.jenitennison.com/blog/node/164)
  * [lessons learned from this exercise](http://www.jenitennison.com/blog/node/165)

This post is the first of these, which looks at how microdata might be mapped to RDFa, in terms of generating the same RDF according to the microdata-to-RDF mapping rules that I outlined in my post on [Microdata + RDF](http://www.jenitennison.com/blog/node/162).

<!--break-->

I have based what's written here on the latest specifications of both microdata (in its [WHAT WG](http://www.whatwg.org/specs/web-apps/current-work/multipage/microdata.html) and [W3C](http://dev.w3.org/html5/md/Overview.html) variants) and [RDFa Core](http://www.w3.org/2010/02/rdfa/drafts/2011/ED-rdfa-core-20110814/) and [HTML+RDFa](http://dev.w3.org/html5/rdfa/) but I haven't consulted with anyone involved in these efforts and may well have got things wrong. [Gregg Kellogg's Distiller service](http://rdf.greggkellogg.net/distiller) has proved invaluable for testing, so many thanks to him for providing that service.

The post is rather heavy going and you might want to just [skip to the summary](http://www.jenitennison.com/blog/node/165) instead of reading the whole thing.

The post goes through the examples from the microdata specification (most of them are in both versions, the only exceptions being those that use the vCard vocabulary). I haven't included examples that don't illustrate anything new, so there are some that are skipped. Other examples would be welcome.

## Unidentified Items / Blank Node Subjects

> Here there are two items, each of which has the property "name":
>
>     <div itemscope>
>      <p>My name is <span itemprop="name">Elizabeth</span>.</p>
>     </div>
>     
>     <div itemscope>
>      <p>My name is <span itemprop="name">Daniel</span>.</p>
>     </div>

The first challenge is to map this into RDFa because the properties are tokens rather than URIs and there is no type for either of the items. What I'll assume here is that the `name` properties are local to the document itself and thus the equivalent RDF is:

    [ <#name> "Elizabeth" ] .
    [ <#name> "Daniel" ] .

This can be achieved in RDFa through either:

    <div vocab="#" about="_:elizabeth">
      <p>My name is <span property="name">Elizabeth</span>.</p>
    </div>
    
    <div vocab="#" about="_:daniel">
      <p>My name is <span property="name">Daniel</span>.</p>
    </div>

or:

    <div vocab="#" typeof>
      <p>My name is <span property="name">Elizabeth</span>.</p>
    </div>
    
    <div vocab="#" typeof>
      <p>My name is <span property="name">Daniel</span>.</p>
    </div>

Notes:

  * The `vocab="#"` sets the vocabulary to the location of the current document (plus an empty fragment identifier); this URI is then concatenated to the property token (`name`) to create a URI that is unique to the document. In a document such as this it would make sense to put the `vocab="#"` attribute on the `<html>` element rather than on every single item.
  * With no type in sight, blank nodes can either be created by having an empty `typeof` attribute or through an `about` attributes whose value starts with `_:`. The latter has the advantage of providing an identifier for the blank node that can be used elsewhere in the document, but the former is shorter so will be used where possible in the remaining examples of this post.

## Values from the `src` Attribute

The next example introduces the use of the `src` attribute to set the value of the property.

> In this example, the item has one property, "image", whose value is a URL:
> 
>     <div itemscope>
>      <img itemprop="image" src="google-logo.png" alt="Google">
>     </div>

This should probably be mapped to the RDF:

    [ <#image> <google-logo.png> ] .

The difficulty with this is that in RDFa, the `src` attribute is used for the *subject* of a statement (equivalent to a microdata item) rather than the *object* (equivalent to a microdata value). So we have two choices for equivalent RDFa. One is to use a similar pattern to that used above, but introduce a wrapper element that provides the property:

    <div vocab="#" typeof>
     <span rel="image"><img src="google-logo.png" alt="Google"></span>
    </div>

Another is to provide what would normally be an *object* through a `resource` attribute and then use a `rev` attribute (rather than the usual `rel`) attribute to reverse the relationship:

    <div vocab="#">
     <img resource="_:thing" rev="image" src="google-logo.png" alt="Google">
    </div>

This has three disadvantages over the first option:

  * the `resource` attribute that creates the item is on the `<img>` element rather than on the wrapper `<div>` which makes it hard to create other properties for that item
  * we have to use a `rev` attribute, reversing the normal flow of relationships; I (at least) find this hard to figure out when there's not a `rel` attribute as well
  * <ins>we have to make up an id for the blank node we want to generate</ins>

I'll note that it took me five or six failed attempts to generate the above options. If I hadn't had the [RDF Distiller](http://rdf.greggkellogg.net/distiller) to test with, I would have got it wrong. <del>Note that at least through the RDF Distiller, to be recognised, the `resource` attribute has to have an (empty) value -- it is not enough for it to simply be present, unlike with the `typeof` attribute.</del> <ins>Note that the `resource` attribute has to explicitly point to a blank node to create a blank node rather than having the property be associated with the document in which this appears.</ins>

## Values from the `datetime` Attribute

The next example illustrates the use of the `<time>` element to provide a date/time value for a property.

> In this example, the item has one property, "birthday", whose value is a date:
> 
>     <div itemscope>
>      I was born on <time itemprop="birthday" datetime="2009-05-10">May 10th 2009</time>.
>     </div>

I'm assuming this should map to the RDF:

    [ <#birthday> "2009-05-10"^^<http://www.w3.org/2001/XMLSchema#date> ]

There is an open issue ([ISSUE-97](http://www.w3.org/2010/02/rdfa/track/issues/97)) about this on RDFa, which currently requires the use of the `content` attribute to provide the value as follows:

    <div vocab="#" typeof>
     I was born on <time property="birthday" content="2009-05-10" datatype="xsd:date" datetime="2009-05-10">May 10th 2009</time>.
    </div>

Note that the `xsd:` prefix is built-in within RDFa so there's on need for any declaration for it, which makes it fairly easy to specify the standard date/time datatypes.

If ISSUE-97 were resolved nicely it would be possible to instead do:

    <div vocab="#" typeof>
     I was born on <time property="birthday" datetime="2009-05-10">May 10th 2009</time>.
    </div>

Notes:

  * To make this work, RDFa processors would have to look at the syntax of the `datetime` attribute to work out what datatype the value should be matched to.
  * The syntax permitted in the `datetime` attribute isn't exactly the same as that permitted by the XML Schema `time` and `dateTime` types usually used in RDF (and XML), in that the seconds component is optional within HTML. The resolution to ISSUE-97 will need to take this into account. Otherwise, anyone mapping from microdata to RDFa manually will need to ensure that the `content` attribute includes the seconds component.

## Nested Items / Object Properties

> In this example, the outer item represents a person, and the inner one represents a band:
> 
>     <div itemscope>
>      <p>Name: <span itemprop="name">Amanda</span></p>
>      <p>Band: <span itemprop="band" itemscope> <span itemprop="name">Jazz Band</span> (<span itemprop="size">12</span> players)</span></p>
>     </div>
> 
> The outer item here has two properties, "name" and "band". The "name" is "Amanda", and the "band" is an item in its own right, with two properties, "name" and "size". The "name" of the band is "Jazz Band", and the "size" is "12".

The equivalent RDF for this example would be:

    [
      <#name> "Amanda" ;
      <#band> [
        <#name> "Jazz Band" ;
        <#size> "12"
      ]
    ]

Note that the `size` property is just a plain literal value; unlike with date/times, there's no way to tell from the microdata that the value is a number.

In RDFa this could be done with:

    <div vocab="#" typeof>
     <p>Name: <span property="name">Amanda</span></p>
     <p>Band: <span rel="band"> <span property="name">Jazz Band</span> (<span property="size">12</span> players)</span></p>
    </div>

This follows the microdata fairly closely but note that the nested resource doesn't need an empty `typeof` attribute: it's only the top-level items that do. It might be easier, for consistency and extensibility, to always include an explicit nested element (with an empty `typeof` attribute in this case) to represent the nested resource:

    <div vocab="#" typeof>
     <p>Name: <span property="name">Amanda</span></p>
     <p>Band: <span rel="band"><span typeof> <span property="name">Jazz Band</span> (<span property="size">12</span> players)</span></span></p>
    </div>

The other thing that people have to watch out for is that because the value of the `band` property is a resource rather than a literal, we have to use the `rel` attribute rather than the `property` attribute as we do elsewhere.

## Itemref

> This example is the same as the previous one, but all the properties are separated from their items:
> 
>     <div itemscope id="amanda" itemref="a b"></div>
>     <p id="a">Name: <span itemprop="name">Amanda</span></p>
>     <div id="b" itemprop="band" itemscope itemref="c"></div>
>     <div id="c">
>      <p>Band: <span itemprop="name">Jazz Band</span></p>
>      <p>Size: <span itemprop="size">12</span> players</p>
>     </div>

This should create the same RDF as the previous example:

    [
      <#name> "Amanda" ;
      <#band> [
        <#name> "Jazz Band" ;
        <#size> "12"
      ]
    ]

changing the markup as little as possible. The RDFa equivalent is:

    <div id="amanda"></div>
    <p vocab="#" about="_:amanda">Name: <span property="name">Amanda</span></p>
    <div vocab="#" about="_:amanda" rel="band" resource="_:c"></div>
    <div vocab="#" about="_:c">
     <p>Band: <span property="name">Jazz Band</span></p>
     <p>Size: <span property="size">12</span> players</p>
    </div>

In microdata, the `itemref` attribute is a method of an item adopting name/value pairs described in a separate location within the page. In RDFa, the equivalent is to say that the name/value pairs are all related to the same resource by consistently referring to the resource as the subject of the statements. In the above case, there are two blank nodes labelled `_:amanda` and `_:c`, and the `about` attribute is used on the same elements that provide the properties (or a wrapper element) to indicate the identity of the subject of the statements.

Notes:

  * The `resource` attribute has to be used to indicate the blank node for the band.
  * As before, the `rel` attribute has to be used for the `band` property, rather than the `property` attribute, because the object of the statement is a resource. The rule is that if you're using `resource`, you should use `rel`. (I used `property` erroneously the first time I tried to write this mapping. I will never learn.)

There is another example of `itemref` in use later in the microdata specification:

>     <!DOCTYPE HTML>
>     <html>
>      <head>
>       <title>Photo gallery</title>
>      </head>
>      <body>
>       <h1>My photos</h1>
>       <figure itemscope itemtype="http://n.whatwg.org/work" itemref="licenses">
>        <img itemprop="work" src="images/house.jpeg" alt="A white house, boarded up, sits in a forest.">
>        <figcaption itemprop="title">The house I found.</figcaption>
>       </figure>
>       <figure itemscope itemtype="http://n.whatwg.org/work" itemref="licenses">
>        <img itemprop="work" src="images/mailbox.jpeg" alt="Outside the house is a mailbox. It has a leaflet inside.">
>        <figcaption itemprop="title">The mailbox.</figcaption>
>       </figure>
>       <footer>
>        <p id="licenses">All images licensed under the <a itemprop="license"
>        href="http://www.opensource.org/licenses/mit-license.php">MIT
>        license</a>.</p>
>       </footer>
>      </body>
>     </html>

This is equivalent to the RDF:

    [
      a <http://n.whatwg.org/work> ;
      <http://n.whatwg.org/license> <http://www.opensource.org/licenses/mit-license.php> ;
      <http://n.whatwg.org/work> <images/house.jpeg> ;
      <http://n.whatwg.org/title> "The house I found." ;
    ] .
    [
      a <http://n.whatwg.org/work> ;
      <http://n.whatwg.org/license> <http://www.opensource.org/licenses/mit-license.php> ;
      <http://n.whatwg.org/work> <images/mailbox.jpeg> ;
      <http://n.whatwg.org/title> "The mailbox." ;
    ] .

Note that the `license` property is adopted by both the items in the microdata. In this particular example, the two items have the same type, and thus the `license` property has the same meaning in each item. It's also possible for `itemref` to be used on two items that have different types, pointing to the same element, in which case the shared properties defined within that element could mean different things for the two items.

There is no way that I am aware of within RDFa to support shared use of portions of content. There could be a rough equivalent that would work in the case where the shared properties had the same semantics if RDFa allowed the `about` attribute to take multiple values (**note: invalid example**):

    <!DOCTYPE HTML>
    <html>
     <head>
      <title>Photo gallery</title>
     </head>
     <body vocab="http://n.whatwg.org/">
      <h1>My photos</h1>
      <figure about="_:house" typeof="work">
       <span rel="work"><img src="images/house.jpeg" alt="A white house, boarded up, sits in a forest."></span>
       <figcaption property="title">The house I found.</figcaption>
      </figure>
      <figure about="_:mailbox" typeof="work">
       <span rel="work"><img src="images/mailbox.jpeg" alt="Outside the house is a mailbox. It has a leaflet inside."></span>
       <figcaption property="title">The mailbox.</figcaption>
      </figure>
      <footer>
       <p about="_:house _:mailbox">All images licensed under the <a rel="license"
       href="http://www.opensource.org/licenses/mit-license.php">MIT
       license</a>.</p>
      </footer>
     </body>
    </html>

but this wouldn't support the possibility of the same property having different semantics (and therefore different URIs) for the separate resources.

It's also worth noting in this example that the mapping to RDF that I'm assuming results, in this example, in `http://n.whatwg.org/work` being both a class and a property. The creators of RDF vocabularies tend to name classes with an Uppercase initial letter and properties with a lowercase initial letter, and thus avoid these kinds of clashes. Vocabulary designers who are mindful of mappings to RDF may want to take the same approach.

## Multiple Values

> This example describes an ice cream, with two flavors:
> 
>     <div itemscope>
>      <p>Flavors in my favorite ice cream:</p>
>      <ul>
>       <li itemprop="flavor">Lemon sorbet</li>
>       <li itemprop="flavor">Apricot sorbet</li>
>      </ul>
>     </div>
> 
> This thus results in an item with two properties, both "flavor", having the values "Lemon sorbet" and "Apricot sorbet".

This example highlights one of the real nightmares of RDF: lists. In microdata, the order of the values 'Lemon sorbet' and 'Apricot sorbet' is naturally retained. There are three possible mappings to RDF.

### Creating Multiple Statements

If the order of the flavours of ice cream in this example don't actually matter, the equivalent RDF is:

    [ <#flavor> "Lemon sorbet" , "Apricot sorbet" ]

which is equivalent to:

    [ <#flavor> "Apricot sorbet" , "Lemon sorbet" ]

In this case, the RDFa is straight-forward:

    <div vocab="#" typeof>
     <p>Flavors in my favorite ice cream:</p>
     <ul>
      <li property="flavor">Lemon sorbet</li>
      <li property="flavor">Apricot sorbet</li>
     </ul>
    </div>

It's surprising how common it is that order doesn't actually matter when there are multiple values for a property, such that this mapping is quite sufficient. But I'm absolutely not going to pretend that order is never important...

### Creating an `rdf:Seq`

If the order of the flavours does matter, there are two ways of representing that order using RDF. The first is to use an `rdf:Seq` resource. This method was the original method of representing lists in RDF and is very natural to do in RDF/XML, but has largely fallen out of favour for the second method which I'll describe below.

Using the `rdf:Seq` method, the equivalent RDF for the microdata would be:

    @prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
    [
      <#flavor> [
        a rdf:Seq ;
        rdf:_1 "Lemon sorbet" ;
        rdf:_2 "Apricot sorbet"
      ]
    ]

which can be generated with:

    <div vocab="#" typeof>
     <p>Flavors in my favorite ice cream:</p>
     <div rel="flavor">
      <ul typeof="rdf:Seq">
       <li property="rdf:_1">Lemon sorbet</li>
       <li property="rdf:_2">Apricot sorbet</li>
      </ul>
     </div>
    </div>

Notes:

  * There are various other ways in which the namespace for the `rdf:Seq` could be created, but since the `rdf:` prefix is built-in to RDFa 1.1, it seems easier to use that than anything that explicitly writes out the full (ugly) RDF namespace.
  * The `<div>` wrapper for the `<ul>` is needed in the same way as the wrapper `<span>` element was needed in the `<img>` example above. Whereas in microdata, the property element also describes the value of that property, in RDFa when the object of a statement is a resource the description of that resource is nested inside the property element (in a similar way to RDF/XML).

### Creating a `rdf:List`

The current recommended way to create a list in RDF is to use a `rdf:List` resource. This essentially uses a [linked list](http://en.wikipedia.org/wiki/Linked_list) model to represent lists, with the `rdf:first` item of a list being a value and the `rdf:rest` being either another `rdf:List` or `rdf:nil`. Spelled out, the RDF would look like:

    @prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
    [ 
      <#flavor> [
        a rdf:List ;
        rdf:first "Lemon sorbet" ;
        rdf:rest [
          rdf:first "Apricot sorbet" ;
          rdf:rest rdf:nil
        ]
      ]
    ]

but of course Turtle lets you write it:

    [] <#flavor> ( "Lemon sorbet" "Apricot sorbet" ) .

Unfortunately, RDFa has no such syntax sugar. Which means:

    <div vocab="#" typeof>
     <p>Flavors in my favorite ice cream:</p>
     <div rel="flavor">
      <ul typeof="rdf:List">
       <li property="rdf:first">Lemon sorbet</li>
       <li rel="rdf:rest">
        <span typeof="rdf:List">
         <span property="rdf:first">Apricot sorbet</span>
         <a rel="rdf:rest" href="rdf:nil"></a>
        </span>
       </li>
      </ul>
     </div>
    </div>

Yep, horrific. Verbose and easy to get wrong, and that's just for two items. If a third is added, the pattern is to add an `about` attribute on the middle items of the list so that the `rdf:rest` property which covers the next item in the list can be assigned to it. For example:

    <div vocab="#" typeof>
     <p>Flavors in my favorite ice cream:</p>
     <div rel="flavor">
      <ul typeof="rdf:List">
       <li property="rdf:first">Lemon sorbet</li>
       <li rel="rdf:rest">
        <span about="_:2" typeof="List">
         <span property="rdf:first">Apricot sorbet</span>
        </span>
       </li>
       <li about="_:2" rel="rdf:rest">
         <span typeof="rdf:List">
         <span property="rdf:first">Raspberry sorbet</span>
         <a rel="rdf:rest" href="http://www.w3.org/1999/02/22-rdf-syntax-ns#nil"></a>
         </span>
       </li>
      </ul>
     </div>
    </div>

Note:

  * I've used an empty `<a>` element with a `href` attribute to point to the `rdf:nil` resource. An alternative would be to use the `resource` attribute, which would have the advantage of not having to spell out the full URI for `rdf:nil`, but I'm trying to stick to using as few attributes as possible.
  * Using an empty `<a>` element for a link isn't ideal; it would be neater to use a `<link>` element, but these aren't allowed in flow content within HTML5 (`<link>` and `<meta>` are only permitted within the microdata specification, and then only if they have an `itemprop` attribute). The RDFa specification could likewise allow them.

## Multiple Properties Sharing a Value

> Here we see an item with two properties, "favorite-color" and "favorite-fruit", both set to the value "orange":
>
>     <div itemscope>
>      <span itemprop="favorite-color favorite-fruit">orange</span>
>     </div>

This should map to the RDF:

    [
      <#favorite-color> "orange" ;
      <#favorite-fruit> "orange"
    ]

Like `itemprop`, `property` can take multiple values, so the RDFa equivalent is simply:

    <div vocab="#" typeof>
     <span property="favorite-color favorite-fruit">orange</span>
    </div>

## Types

> Here, the item's type is "http://example.org/animals#cat":
> 
>     <section itemscope itemtype="http://example.org/animals#cat">
>      <h1 itemprop="name">Hedral</h1>
>      <p itemprop="desc">Hedral is a male american domestic
>      shorthair, with a fluffy black fur with white paws and belly.</p>
>      <img itemprop="img" src="hedral.jpeg" alt="" title="Hedral, age 18 months">
>     </section>
> 
> In this example the "http://example.org/animals#cat" item has three properties, a "name" ("Hedral"), a "desc" ("Hedral is..."), and an "img" ("hedral.jpeg").

I'll assume that this should be mapped to the RDF:

    [
      a <http://example.org/animals#cat> ;
      <http://example.org/animals#name> "Hedral" ;
      <http://example.org/animals#desc> "Hedral is a male american domestic shorthair, with a fluffy black fur with white paws and belly." ;
      <http://example.org/animals#img> <hedral.jpeg>
    ]

In this case, the `vocab` can be set to `http://example.org/animals#` and both the `itemtype` and the various `property` and `rel` attributes will use that as the basis for their identifying URIs:

    <section vocab="http://example.org/animals#" typeof="cat">
     <h1 property="name">Hedral</h1>
     <p property="desc">Hedral is a male american domestic
     shorthair, with a fluffy black fur with white paws and belly.</p>
     <div rel="img"><img src="hedral.jpeg" alt="" title="Hedral, age 18 months"></div>
    </section>

## Global Identifiers

> Here, an item is talking about a particular book:
> 
>     <dl itemscope
>         itemtype="http://vocab.example.net/book"
>         itemid="urn:isbn:0-330-34032-8">
>      <dt>Title
>      <dd itemprop="title">The Reality Dysfunction
>      <dt>Author
>      <dd itemprop="author">Peter F. Hamilton
>      <dt>Publication date
>      <dd><time itemprop="pubdate" datetime="1996-01-26">26 January 1996</time>
>     </dl>

Here, the item has an identifier so unlike the previous examples, the subject of the statements in the RDF is no longer a blank node:

    @prefix xsd: <http://www.w3.org/2001/XMLSchema#> .
    <urn:isbn:0-330-34032-8>
      a <http://vocab.example.net/book> ;
      <http://vocab.example.net/title> "The Reality Dysfunction\n " ;
      <http://vocab.example.net/author> "Peter F. Hamilton\n " ;
      <http://vocab.example.net/pubdate> "1996-01-26"^^xsd:date ;
      .

In RDFa, the subject is provided using the `about` attribute:

    <dl vocab="http://vocab.example.net/"
        typeof="book"
        about="urn:isbn:0-330-34032-8">
     <dt>Title
     <dd property="title">The Reality Dysfunction
     <dt>Author
     <dd property="author">Peter F. Hamilton
     <dt>Publication date
     <dd><time property="pubdate" content="1996-01-26" datatype="xsd:date" datetime="1996-01-26">26 January 1996</time>
    </dl>

## Global Property Names

> Here, an item is an "http://example.org/animals#cat", and most of the properties have names that are words defined in the context of that type. There are also a few additional properties whose names come from other vocabularies.
> 
>     <section itemscope itemtype="http://example.org/animals#cat">
>      <h1 itemprop="name http://example.com/fn">Hedral</h1>
>      <p itemprop="desc">Hedral is a male american domestic
>      shorthair, with a fluffy <span
>      itemprop="http://example.com/color">black</span> fur with <span
>      itemprop="http://example.com/color">white</span> paws and belly.</p>
>      <img itemprop="img" src="hedral.jpeg" alt="" title="Hedral, age 18 months">
>     </section>

The RDF equivalent to this is:

    [
      a <http://example.org/animals#cat> ;
      <http://example.org/animals#name> "Hedral" ;
      <http://example.com/fn> "Hedral" ;
      <http://example.org/animals#desc> "Hedral is a male american domestic shorthair, with a fluffy black fur with white paws and belly." ;
      <http://example.com/color> "black" , "white" ;
      <http://example.org/animals#img> <hedral.jpeg>
    ]

To create this, we need the RDFa:

    <section vocab="http://example.org/animals#" typeof="cat">
     <h1 property="name http://example.com/fn">Hedral</h1>
     <p property="desc">Hedral is a male american domestic
     shorthair, with a fluffy <span
     property="http://example.com/color">black</span> fur with <span
     property="http://example.com/color">white</span> paws and belly.</p>
     <span rel="img"><img src="hedral.jpeg" alt="" title="Hedral, age 18 months"></span>
    </section>

## Link Relations

> Here is an example of a page that uses the vEvent vocabulary to mark up an event:
> 
>     <body itemscope itemtype="http://microformats.org/profile/hcalendar#vevent">
>      ...
>      <h1 itemprop="summary">Bluesday Tuesday: Money Road</h1>
>      ...
>      <time itemprop="dtstart" datetime="2009-05-05T19:00:00Z">May 5th @ 7pm</time>
>      (until <time itemprop="dtend" datetime="2009-05-05T21:00:00Z">9pm</time>)
>      ...
>      <a href="http://livebrum.co.uk/2009/05/05/bluesday-tuesday-money-road"
>         rel="bookmark" itemprop="url">Link to this page</a>
>      ...
>      <p>Location: <span itemprop="location">The RoadHouse</span></p>
>      ...
>      <p><input type=button value="Add to Calendar"
>                onclick="location = getCalendar(this)"></p>
>      ...
>      <meta itemprop="description" content="via livebrum.co.uk">
>     </body>

This example is interesting because it contains, in the natural markup of the page, a `rel` attribute with the value [`bookmark`](http://www.w3.org/TR/html5/links.html#link-type-bookmark), which is used for links that go to the page or section of the page within which the link is found. In this case, it's the page. The RDF that should be generated from the page is:

    [
      a <http://microformats.org/profile/hcalendar#vevent> ;
      <http://microformats.org/profile/hcalendar#summary> "Bluesday Tuesday: Money Road" ;
      <http://microformats.org/profile/hcalendar#dtstart> "2009-05-05T19:00:00Z"^^xsd:dateTime ;
      <http://microformats.org/profile/hcalendar#dtend> "2009-05-05T21:00:00Z"^^xsd:dateTime ;
      <http://microformats.org/profile/hcalendar#url> <http://livebrum.co.uk/2009/05/05/bluesday-tuesday-money-road> ;
      <http://microformats.org/profile/hcalendar#location> "The RoadHouse" ;
      <http://microformats.org/profile/hcalendar#description> "via livebrum.co.uk"
    ] .

The following statement could legitimately be generated as well:

    <> 
      <http://www.w3.org/1999/xhtml/vocab#bookmark> <http://livebrum.co.uk/2009/05/05/bluesday-tuesday-money-road> ;
      .

but the item representing the event should definitely not have the `http://www.w3.org/1999/xhtml/vocab#bookmark` property.

Achieving this without significantly changing the HTML markup is problematic in RDFa because RDFa uses the `rel` attribute to provide properties for the resources that it describes within the page, overloading its standard use in HTML which is to describe properties of the page or sections within the page. The following involves the least amount of repetition:

    <body vocab="http://microformats.org/profile/hcalendar#">
     <div typeof="vevent">
      ...
      <h1 property="summary">Bluesday Tuesday: Money Road</h1>
      ...
      <time property="dtstart" content="2009-05-05T19:00:00Z" datatype="xsd:dateTime" 
            datetime="2009-05-05T19:00:00Z">May 5th @ 7pm</time>
      (until <time property="dtend" content="2009-05-05T21:00:00Z" datatype="xsd:dateTime" 
                   datetime="2009-05-05T21:00:00Z">9pm</time>)
      ...
      <a rel="url" href="http://livebrum.co.uk/2009/05/05/bluesday-tuesday-money-road"></a>
      <a about href="http://livebrum.co.uk/2009/05/05/bluesday-tuesday-money-road"
         rel="bookmark">Link to this page</a>
      ...
      <p>Location: <span property="location">The RoadHouse</span></p>
      ...
      <p><input type=button value="Add to Calendar"
                onclick="location = getCalendar(this)"></p>
      ...
      <span property="description" content="via livebrum.co.uk"></span>
     </div>
    </body>

Notes:

  * In the above, the `typeof` attribute has been moved onto a wrapper `<div>` that encompasses the entirety of the page because if it resides on the `<body>` element, it's assumed to apply to the document itself rather than a blank node. An alternative mapping would use `about="_:event"` to create a blank node for the event.
  * There's no way to avoid creating a statement for the `rel="bookmark"` link, so the best we can do is make sure that the statement is accurate, and relates the current document to the provided URI. Unfortunately, that means creating a separate element for the `url` property, repeating that URL within the page, and adding an empty `about` attribute; here I've used an empty `<a>` element to express the relationship; a `<link>` element would do the same job if it were allowed in flow content.
  * The `<meta>` element in the original has been mapped to an empty `<span>` element as it isn't allowed in flow content without an `itemprop` attribute.

