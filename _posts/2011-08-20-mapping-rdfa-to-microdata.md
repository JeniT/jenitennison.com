---
layout: drupal-post
excerpt_separator: "<!--break-->"
title: Mapping RDFa to Microdata
created: 1313858318
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

This post is the second of these, which looks at how RDFa might be mapped to microdata.  In this case, I will aim to express the RDF created from the RDFa as the equivalent microdata JSON, and aim to create that JSON with the microdata.

<!--break-->

To create the microdata JSON, I've used the rule that the URI of the first type of a resource is processed to provide a namespace that is stripped from the URIs of the properties (to create simple names where possible). In addition, when a resource has no properties, it will be represented as a string (URI) value rather than as a nested item. Other than that I hope the mapping will be obvious; I'll point out where it involves a loss of information. I'm assuming that the document is at `http://example.org/` throughout.

I have based what's written here on the latest specifications of both microdata (in its [WHAT WG](http://www.whatwg.org/specs/web-apps/current-work/multipage/microdata.html) and [W3C](http://dev.w3.org/html5/md/Overview.html) variants) and [RDFa Core](http://www.w3.org/2010/02/rdfa/drafts/2011/ED-rdfa-core-20110814/) and [HTML+RDFa](http://dev.w3.org/html5/rdfa/) but I haven't consulted with anyone involved in these efforts and may well have got things wrong. [Philip Jägenstedt's Live Microdata service](http://foolip.org/microdatajs/live/) has proved invaluable for testing, so many thanks to him for providing that service.

The post is rather heavy going and you might want to just [skip to the summary](http://www.jenitennison.com/blog/node/165) instead of reading the whole thing.

The post goes through the examples from the RDFa specification plus one additional example from the wild. I haven't included examples that don't illustrate anything new, so there are some that are skipped. Other examples would be welcome.

## Page Metadata

> When parsing begins, the current subject will be the IRI of the document being parsed, or a value as set by a Host Language-provided mechanism (e.g., the base element in (X)HTML). This means that by default any metadata found in the document will concern the document itself:
> 
>     <html>
>       <head>
>         <title>Jo's Friends and Family Blog</title>
>         <link rel="foaf:primaryTopic" href="#bbq" />
>         <meta property="dc:creator" content="Jo" />
>       </head>
>       <body>
>         ...
>       </body>
>     </html>

The equivalent microdata JSON for this document that we'd want to create is (**note: invalid example**):

    { "items": [
      {
        "id": "http://example.org/" ,
        "properties": {
          "http://xmlns.com/foaf/0.1/primaryTopic": [ "http://example.org/#bbq" ],
          "http://purl.org/dc/terms/creator": [ "Jo" ]
        }
      }
    ]}

and we'd want to create it with (**note: invalid example**):

    <html>
      <head itemscope itemid=".">
        <title>Jo's Friends and Family Blog</title>
        <link itemprop="http://xmlns.com/foaf/0.1/primaryTopic" href="#bbq" />
        <meta itemprop="http://purl.org/dc/terms/creator" content="Jo" />
      </head>
      <body>
        ...
      </body>
    </html>

However, this is is not valid according to the microdata specification. In microdata, [only items that have types are allowed to have identifiers](http://www.whatwg.org/specs/web-apps/current-work/multipage/microdata.html#attr-itemid). Rather than losing the identifier, we'll add a type; I'm going to use `rdfs:Resource`. It's not the nicest of URIs to type, but it's got something close to the correct semantics. So we'll aim for the microdata JSON:

    { "items": [
      {
        "type": "http://www.w3.org/2000/01/rdf-schema#Resource" ,
        "id": "http://example.org/" ,
        "properties": {
          "http://xmlns.com/foaf/0.1/primaryTopic": [ "http://example.org/#bbq" ] ,
          "http://purl.org/dc/terms/creator": [ "Jo" ]
        }
      }
    ]}

which means we need:

    <html>
      <head itemscope itemtype="http://www.w3.org/2000/01/rdf-schema#Resource" itemid=".">
        <title>Jo's Friends and Family Blog</title>
        <link itemprop="http://xmlns.com/foaf/0.1/primaryTopic" href="#bbq" />
        <meta itemprop="http://purl.org/dc/terms/creator" content="Jo" />
      </head>
      <body>
        ...
      </body>
    </html>


Notes:

  * The `itemscope` is necessary for the page to be recognised as containing any data at all.
  * The `itemid` can't just be empty: the `.` is the shortest URI you can use to reference the page itself.
  * I put the `itemscope`, `itemtype` and `itemid` on the `<head>` element rather than the `<html>` element so that they wouldn't be inherited into the `<body>`: it seems to make sense for any data within the `<head>` to be about the page itself.
  * The `foaf:` and `dc:` prefixes are built-in to RDFa, so it's easy for people to use classes and properties in those common vocabularies without having to remember their full URI. In microdata, that URI and the one for the `rdfs:Resource` class have to be spelled out in full.

## Base URI

> In (X)HTML the value of base may change the initial value of current subject:
> 
>     <html>
>       <head>
>         <base href="http://www.example.org/jo/blog" />
>         <title>Jo's Friends and Family Blog</title>
>         <link rel="foaf:primaryTopic" href="#bbq" />
>         <meta property="dc:creator" content="Jo" />
>       </head>
>       <body>
>         ...
>       </body>
>     </html>

This changes the id of the item generated:

    { "items": [
      {
        "type": "http://www.w3.org/2000/01/rdf-schema#Resource" ,
        "id": "http://www.example.org/jo/blog" ,
        "properties": {
          "http://xmlns.com/foaf/0.1/primaryTopic": [ "http://www.example.org/jo/blog#bbq" ] ,
          "http://purl.org/dc/terms/creator": [ "Jo" ]
        }
      }
    ]}

In the microdata, the `itemid` can still be `.` as the base URI set by the `<base>` element is used to resolve it:

    <html>
      <head itemscope itemtype="http://www.w3.org/2000/01/rdf-schema#Resource" itemid=".">
        <base href="http://www.example.org/jo/blog" />
        <title>Jo's Friends and Family Blog</title>
        <link itemprop="http://xmlns.com/foaf/0.1/primaryTopic" href="#bbq" />
        <meta itemprop="http://purl.org/dc/terms/creator" content="Jo" />
      </head>
      <body>
        ...
      </body>
    </html>

## Explicit Subjects / ItemIds

> To illustrate how this affects the statements, note in this markup how the properties inside the (X)HTML body element become part of a new calendar event object, rather than referring to the document as they do in the head of the document:
> 
>     <html prefix="cal: http://www.w3.org/2002/12/cal/ical#">
>       <head>
>         <title>Jo's Friends and Family Blog</title>
>         <link rel="foaf:primaryTopic" href="#bbq" />
>         <meta property="dc:creator" content="Jo" />
>       </head>
>       <body>
>         <p about="#bbq" typeof="cal:Vevent">
>           I'm holding
>           <span property="cal:summary">
>             one last summer barbecue
>           </span>,
>           on
>           <span property="cal:dtstart" content="2015-09-16T16:00:00-05:00" 
>                 datatype="xsd:dateTime">
>             September 16th at 4pm
>           </span>.
>         </p>
>       </body>
>     </html>

In microdata JSON, this would be:

    { "items": [
      {
        "type": "http://www.w3.org/2000/01/rdf-schema#Resource" ,
        "id": "http://example.org/" ,
        "properties": {
          "http://xmlns.com/foaf/0.1/primaryTopic": [ "http://example.org/#bbq" ],
          "http://purl.org/dc/terms/creator": [ "Jo" ]
        }
      } ,
      {
        "type": "http://www.w3.org/2002/12/cal/ical#Vevent" ,
        "id": "http://example.org/#bbq" ,
        "properties": {
          "summary": [ "one last summer barbecue" ] ,
          "dtstart": [ "2015-09-16T16:00:00-05:00" ] ,
        }
      }
    ]}

Note that this mapping loses the fact that the value of the `dtstart` property is a date-and-time. Processors of this JSON are expected to know that the `dtstart` property takes a date/time value and would have to sniff the value to work out that it's a date-and-time rather than a date.

In-browser microdata processors can identify the value as a date/time value because the property element itself is accessed through the `element.properties` IDL attribute; processors that work with this DOM API can tell that it's a `<time>` element, get hold of the date/time itself and access the content of the element for the human-readable representation used on the page. However, this information isn't part of the core [microdata data model](http://www.w3.org/TR/microdata/#the-microdata-model).

To create this JSON from microdata you need:

    <html>
      <head itemscope itemtype="http://www.w3.org/2000/01/rdf-schema#Resource" itemid=".">
        <title>Jo's Friends and Family Blog</title>
        <link itemprop="http://xmlns.com/foaf/0.1/primaryTopic" href="#bbq" />
        <meta itemprop="http://purl.org/dc/terms/creator" content="Jo" />
      </head>
      <body>
        <p itemscope itemid="#bbq" itemtype="http://www.w3.org/2002/12/cal/ical#Vevent">
          I'm holding
          <span itemprop="summary">
            one last summer barbecue
          </span>,
          on
          <time itemprop="dtstart" datetime="2015-09-16T16:00:00-05:00">
            September 16th at 4pm
          </time>.
        </p>
      </body>
    </html>

Notes:

  * There are no prefix definitions in microdata, so the type has to be spelled out in full. However, with the mapping I'm assuming from RDFa to microdata JSON, the properties in that same namespace for items in that class don't.
  * The `itemscope` has to be added despite the `<p>` element having both an `itemid` and an `itemtype`; if the `itemscope` is forgotten, the item isn't recognised.
  * The original `<span>` element has to be changed to a `<time>` element because it isn't conformant microdata for a date/time value to be supplied by any other element.

## Items from the `src` Attribute

> If @about is not present, then @src is next in priority order, for setting the subject of a statement. A typical use would be to indicate the licensing type of an image:
> 
>     <img src="photo1.jpg" rel="license" 
>          resource="http://creativecommons.org/licenses/by/2.0/" />

This should generate the microdata JSON:

    { "items": [
      {
        "type": "http://www.w3.org/2000/01/rdf-schema#Resource" ,
        "id": "http://example.org/photo1.jpg" ,
        "properties": {
          "http://www.w3.org/1999/xhtml/vocab#license": [ "http://creativecommons.org/licenses/by/2.0/" ] ,
        }
      }
    ]}

The `src` attribute in microdata is only used for a value, so creating the microdata about the image means a wrapper `<span>` element and a separate `<link>` element:

     <span itemscope itemtype="http://www.w3.org/2000/01/rdf-schema#Resource" itemid="photo1.jpg">
       <img src="photo1.jpg" />
       <link itemprop="http://www.w3.org/1999/xhtml/vocab#license" href="http://creativecommons.org/licenses/by/2.0/" />
     </span>

Note:

  * The `license` property is part of the built-in set of link relationships in HTML, but there is no easy way to refer to that property from microdata; they have to be spelled out as full URLs.

## Additional Properties for Images

> Since there is no difference between @src and @about, then the information expressed in the last example in the section on @about (the creator of an image), could be expressed as follows:
> 
>     <img src="photo1.jpg"
>       rel="license" resource="http://creativecommons.org/licenses/by/2.0/"
>       property="dc:creator" content="Mark Birbeck"
>     />

This is a simple additional property in the microdata JSON:

    { "items": [
      {
        "type": "http://www.w3.org/2000/01/rdf-schema#Resource" ,
        "id": "http://example.org/photo1.jpg" ,
        "properties": {
          "http://www.w3.org/1999/xhtml/vocab#license": [ "http://creativecommons.org/licenses/by/2.0/" ] ,
          "http://purl.org/dc/terms/creator": [ "Mark Birbeck" ]
        }
      }
    ]}

which can be created through a `<meta>` element within the `<span>`:

    <span itemscope itemtype="http://www.w3.org/2000/01/rdf-schema#Resource" itemid="photo1.jpg">
      <img src="photo1.jpg" />
      <link itemprop="http://www.w3.org/1999/xhtml/vocab#license" href="http://creativecommons.org/licenses/by/2.0/" />
      <meta itemprop="http://purl.org/dc/terms/creator" content="Mark Birbeck" />
    </span>

## Nested Images

> Since normal chaining rules will apply, the image IRI can also be used to complete hanging triples:
> 
>     <div about="http://www.blogger.com/profile/1109404" rel="foaf:img">
>       <img src="photo1.jpg"
>         rel="license" resource="http://creativecommons.org/licenses/by/2.0/"
>         property="dc:creator" content="Mark Birbeck"
>       />
>     </div>

This should generate the microdata JSON:

    { "items": [
      {
        "type": "http://www.w3.org/2000/01/rdf-schema#Resource" ,
        "id": "http://www.blogger.com/profile/1109404" ,
        "properties": {
          "http://xmlns.com/foaf/0.1/img": [{
            "type": "http://www.w3.org/2000/01/rdf-schema#Resource" ,
            "id": "http://example.org/photo1.jpg" ,
            "properties": {
              "http://www.w3.org/1999/xhtml/vocab#license": [ "http://creativecommons.org/licenses/by/2.0/" ] ,
              "http://purl.org/dc/terms/creator": [ "Mark Birbeck" ]
            }
          }]
        }
      }
    ]}

The microdata to generate this is:

    <div itemscope itemtype="http://www.w3.org/2000/01/rdf-schema#Resource" 
         itemid="http://www.blogger.com/profile/1109404">
      <span itemprop="http://xmlns.com/foaf/0.1/img" 
            itemscope itemtype="http://www.w3.org/2000/01/rdf-schema#Resource" 
            itemid="photo1.jpg">
        <img src="photo1.jpg" />
        <link itemprop="http://www.w3.org/1999/xhtml/vocab#license" href="http://creativecommons.org/licenses/by/2.0/" />
        <meta itemprop="http://purl.org/dc/terms/creator" content="Mark Birbeck" />
      </span>
    </div>

Notes:

  * The big gotcha in this conversion is that in microdata, the `foaf:img` property has to be moved onto the item that is a value of that property; there's no equivalent to the "hanging rel" processing in RDFa. A disadvantage of this is that anyone copying-and-pasting the `<span>` element to embed the same information about the image within their own page will have the `itemprop` attribute carried along with the image, into a context where the `foaf:img` property might not be relevant.

## Types with Blank Nodes

> For example, an author may wish to create markup for a person using the FOAF vocabulary, but without having a clear identifier for the item:
> 
>     <div typeof="foaf:Person">
>       <span property="foaf:name">Albert Einstein</span>
>       <span property="foaf:givenName">Albert</span>
>     </div>

Now we have an explicit type, we can create microdata JSON that uses short names:

    { "items": [
      {
        "type": "http://xmlns.com/foaf/0.1/Person" ,
        "properties": {
          "name": [ "Albert Einstein" ] ,
          "givenName": [ "Albert" ] ,
        }
      }
    ]}

This can be generated with the microdata:

    <div itemscope itemtype="http://xmlns.com/foaf/0.1/Person">
      <span itemprop="name">Albert Einstein</span>
      <span itemprop="givenName">Albert</span>
    </div>

which is nice and simple.

## Inherited Subject

> The most usual way that an inherited subject might get set would be when the parent statement has an object that is a resource. Returning to the earlier example, in which the long name for the German_Empire was added, the following markup was used:
> 
>     <div about="http://dbpedia.org/resource/Albert_Einstein">
>       <span property="foaf:name">Albert Einstein</span>
>       <span property="dbp:dateOfBirth" datatype="xsd:date">1879-03-14</span>
>       <div rel="dbp:birthPlace" resource="http://dbpedia.org/resource/German_Empire" />
>       <span about="http://dbpedia.org/resource/German_Empire"
>         property="dbp:conventionalLongName">the German Empire</span>
>     </div>

The equivalent microdata JSON for this would be:

    { "items": [
      {
        "type": "http://www.w3.org/2000/01/rdf-schema#Resource" ,
        "id": "http://dbpedia.org/resource/Albert_Einstein" ,
        "properties": {
          "http://xmlns.com/foaf/0.1/name": [ "Albert Einstein" ] ,
          "http://dbpedia.org/property/dateOfBirth": [ "1879-03-14" ] ,
          "http://dbpedia.org/property/birthPlace": [ "http://dbpedia.org/resource/German_Empire" ]
        }
      } , {
        "type": "http://www.w3.org/2000/01/rdf-schema#Resource" ,
        "id": "http://dbpedia.org/resource/German_Empire" ,
        "properties": {
          "http://dbpedia.org/property/conventionalLongName": [ "the German Empire" ] ,
        }
      }
    ]}

Note that this microdata JSON could only be generated syntactically from the RDFa, not via RDF, because going via RDF would make it impossible to know whether to give the `dbp:birthPlace` property a string (which is a URI) value or a nested item. We'll see the alternative version of the microdata RDF in the next example.

To create this microdata JSON, we need:

    <div itemscope itemtype="http://www.w3.org/2000/01/rdf-schema#Resource" 
         itemid="http://dbpedia.org/resource/Albert_Einstein">
      <span itemprop="http://xmlns.com/foaf/0.1/name">Albert Einstein</span>
      <time itemprop="http://dbpedia.org/property/dateOfBirth">1879-03-14</time>
      <link itemprop="http://dbpedia.org/property/birthPlace" href="http://dbpedia.org/resource/German_Empire" />
      <span itemscope itemtype="http://www.w3.org/2000/01/rdf-schema#Resource"  
            itemid="http://dbpedia.org/resource/German_Empire">
        <span itemprop="http://dbpedia.org/property/conventionalLongName">the German Empire</span>
      </span>
    </div>

Notes:

  * I've had to change two elements here: the `<span>` for the date of birth has become a `<time>` element as the value of the property is a date, and the `<div>` for the birth place has become a `<link>` element because the value of that property is a URL.
  * I've also had to add a nested `<span>` element as it's not possible in microdata to have a single element describe both an item and a property for that item as it is in RDFa.

> In an earlier illustration the subject and object for the German Empire were connected by removing the @resource, relying on the @about to set the object:
> 
>     <div about="http://dbpedia.org/resource/Albert_Einstein">
>       <span property="foaf:name">Albert Einstein</span>
>       <span property="dbp:dateOfBirth" datatype="xsd:date">1879-03-14</span>
>       <div rel="dbp:birthPlace">
>         <span about="http://dbpedia.org/resource/German_Empire"
>           property="dbp:conventionalLongName">the German Empire</span>
>       </div>
>     </div>

While this generates the same RDF as the previous example, the microdata JSON that it generates should probably be different: this time, the item for the German Empire is nested within the item for Albert Einstein:

    { "items": [
      {
        "type": "http://www.w3.org/2000/01/rdf-schema#Resource" ,
        "id": "http://dbpedia.org/resource/Albert_Einstein" ,
        "properties": {
          "http://xmlns.com/foaf/0.1/name": [ "Albert Einstein" ] ,
          "http://dbpedia.org/property/dateOfBirth": [ "1879-03-14" ] ,
          "http://dbpedia.org/property/birthPlace": [{
            "type": "http://www.w3.org/2000/01/rdf-schema#Resource" ,
            "id": "http://dbpedia.org/resource/German_Empire" ,
            "properties": {
              "http://dbpedia.org/property/conventionalLongName": [ "the German Empire" ]
            }
          }
        }
      }
    ]}

To create this, the microdata needs to look like:

    <div itemscope itemtype="http://www.w3.org/2000/01/rdf-schema#Resource" 
         itemid="http://dbpedia.org/resource/Albert_Einstein">
      <span itemprop="http://xmlns.com/foaf/0.1/name">Albert Einstein</span>
      <time itemprop="http://dbpedia.org/property/dateOfBirth">1879-03-14</time>
      <div itemprop="http://dbpedia.org/property/birthPlace" 
           itemscope itemtype="http://www.w3.org/2000/01/rdf-schema#Resource"  
           itemid="http://dbpedia.org/resource/German_Empire">
        <span itemprop="http://dbpedia.org/property/conventionalLongName">the German Empire</span>
      </div>
    </div>

Note that while this looks quite similar to the RDFa version, in fact the `itemid` attribute that holds the URI for the German Empire is on a different element from the `about` attribute in the RDFa.

The third RDFa example around this same content is:

> but it is also possible for authors to achieve the same effect by removing the @about and leaving the @resource:
> 
>     <div about="http://dbpedia.org/resource/Albert_Einstein">
>       <span property="foaf:name">Albert Einstein</span>
>       <span property="dbp:dateOfBirth" datatype="xsd:date">1879-03-14</span>
>       <div rel="dbp:birthPlace" resource="http://dbpedia.org/resource/German_Empire">
>         <span property="dbp:conventionalLongName">the German Empire</span>
>       </div>
>     </div>

This should lead to the same microdata JSON, so I won't bother repeating the microdata. What's interesting is that this pattern: the wrapper element containing the property (`rel`) and identifier for the item that is the value for that property (`resource`) is a lot closer to the microdata pattern of expressing nested items. The big distinction here is that while in microdata, the `itemtype` also resides on that element, if you tried adding a `typeof` attribute to the inner `<div>` in RDFa, you'd end up with a new blank node.

## Anonymous Nested Resources

> However, an author could just as easily say that Spinoza influenced something by the name of Albert Einstein, that was born on March 14th, 1879:
> 
>     <div about="http://dbpedia.org/resource/Baruch_Spinoza" rel="dbp-owl:influenced">
>       <div>
>         <span property="foaf:name">Albert Einstein</span>
>         <span property="dbp:dateOfBirth" datatype="xsd:date">1879-03-14</span>
>       </div>
>     </div>

This should generate the microdata JSON:

    { "items": [
      {
        "type": "http://www.w3.org/2000/01/rdf-schema#Resource" ,
        "id": "http://dbpedia.org/resource/Baruch_Spinoza" ,
        "properties": {
          "http://dbpedia.org/ontology/influenced": [{
            "properties": {
              "http://xmlns.com/foaf/0.1/name": [ "Albert Einstein" ] ,
              "http://dbpedia.org/property/dateOfBirth": [ "1879-03-14" ]
            }
          }]
        }
      }
    ]}

which again means moving an attribute in microdata:

    <div itemscope itemtype="http://www.w3.org/2000/01/rdf-schema#Resource"
         itemid="http://dbpedia.org/resource/Baruch_Spinoza">
      <div itemprop="http://dbpedia.org/ontology/influenced"
           itemscope>
        <span itemprop="http://xmlns.com/foaf/0.1/name">Albert Einstein</span>
        <time itemprop="http://dbpedia.org/property/dateOfBirth">1879-03-14</time>
      </div>
    </div>

It is generally harder to move to microdata from RDFa when the RDFa has an element that both provides a subject and provides a property.

The RDFa spec provides a couple of additional methods of marking up the same content to give exactly the same RDF (and microdata JSON):

> Note that the div is superfluous, and an RDFa Processor will create the intermediate object even if the element is removed:
> 
>     <div about="http://dbpedia.org/resource/Baruch_Spinoza" rel="dbp-owl:influenced">
>       <span property="foaf:name">Albert Einstein</span>
>       <span property="dbp:dateOfBirth" datatype="xsd:date">1879-03-14</span>
>     </div>
> 
> An alternative pattern is to keep the div and move the @rel onto it:
> 
>     <div about="http://dbpedia.org/resource/Baruch_Spinoza">
>       <div rel="dbp-owl:influenced">
>         <span property="foaf:name">Albert Einstein</span>
>         <span property="dbp:dateOfBirth" datatype="xsd:date">1879-03-14</span>
>       </div>
>     </div>
> 
> From the point of view of the markup, this latter layout is to be preferred, since it draws attention to the 'hanging rel'. But from the point of view of an RDFa Processor, all of these permutations need to be supported.

Interestingly, it's this latter permutation that is the one that's closest to the microdata method of expressing the data, though as we will see in the next section, the "hanging rel" is not exactly equivalent to the `itemprop` on the wrapper element.

## Hanging Rels

> Note that each occurrence of @about will complete any incomplete triples. For example, to mark up the fact that Albert Einstein had a residence both in the German Empire and Switzerland, an author need only specify one @rel value that is then used with multiple @about values:
> 
>     <div about="http://dbpedia.org/resource/Albert_Einstein" rel="dbp-owl:residence">
>       <span about="http://dbpedia.org/resource/German_Empire" />
>       <span about="http://dbpedia.org/resource/Switzerland" />
>     </div>

The data embedded here gives two values for the `dbp-owl:residence` property:

    { "items": [
      {
        "type": "http://www.w3.org/2000/01/rdf-schema#Resource" ,
        "id": "http://dbpedia.org/resource/Albert_Einstein" ,
        "properties": {
          "http://dbpedia.org/ontology/residence": [
            "http://dbpedia.org/resource/German_Empire" ,
            "http://dbpedia.org/resource/Switzerland"
          ]
        }
      }
    ]}

In microdata, the `itemprop` attribute has to appear on both the nested elements to make it clear that they both provide values for that property:

    <div itemscope itemtype="http://www.w3.org/2000/01/rdf-schema#Resource" 
         itemid="http://dbpedia.org/resource/Albert_Einstein">
     <link itemprop="http://dbpedia.org/ontology/residence" 
           href="http://dbpedia.org/resource/German_Empire" />
     <link itemprop="http://dbpedia.org/ontology/residence"
           href="http://dbpedia.org/resource/Switzerland" />
    </div>

The next example illustrates this with nested items rather than strings:

> To illustrate, to indicate that Spinoza influenced both Einstein and Schopenhauer, the following markup could be used:
> 
>     <div about="http://dbpedia.org/resource/Baruch_Spinoza">
>       <div rel="dbp-owl:influenced">
>         <div typeof="foaf:Person">
>           <span property="foaf:name">Albert Einstein</span>
>           <span property="dbp:dateOfBirth" datatype="xsd:date">1879-03-14</span>
>         </div>
>         <div typeof="foaf:Person">
>           <span property="foaf:name">Arthur Schopenhauer</span>
>           <span property="dbp:dateOfBirth" datatype="xsd:date">1788-02-22</span>
>         </div>          
>       </div>
>     </div>

This should generate:

    { "items": [
      {
        "type": "http://www.w3.org/2000/01/rdf-schema#Resource" ,
        "id": "http://dbpedia.org/resource/Baruch_Spinoza" ,
        "properties": {
          "http://dbpedia.org/ontology/influenced": [{
            "type": "http://xmlns.com/foaf/0.1/Person" ,
            "properties": {
              "name": [ "Albert Einstein" ] ,
              "http://dbpedia.org/property/dateOfBirth": [ "1879-03-14" ]
            }
          }, {
            "type": "http://xmlns.com/foaf/0.1/Person" ,
            "properties": {
              "name": [ "Arthur Schopenhauer" ] ,
              "http://dbpedia.org/property/dateOfBirth": [ "1788-02-22" ]
            }
          }]
        }
      }
    ]}

In this case, the `itemprop` that is equivalent to the RDFa `rel` has to move down onto the elements representing the items:

    <div itemscope itemtype="http://www.w3.org/2000/01/rdf-schema#Resource"
         itemid="http://dbpedia.org/resource/Baruch_Spinoza">
      <div>
        <div itemprop="http://dbpedia.org/ontology/influenced"
             itemscope itemtype="http://xmlns.com/foaf/0.1/Person">
          <span itemprop="name">Albert Einstein</span>
          <time itemprop="http://dbpedia.org/property/dateOfBirth">1879-03-14</time>
        </div>
        <div itemprop="http://dbpedia.org/ontology/influenced"
             itemscope itemtype="http://xmlns.com/foaf/0.1/Person">
          <span itemprop="name">Arthur Schopenhauer</span>
          <time itemprop="http://dbpedia.org/property/dateOfBirth">1788-02-22</time>
        </div>
      </div>
    </div>

The wrapper `<div>` around both items isn't necessary; I've left it to stay as close to the markup of the original RDFa as possible.

## Implicit Resources

> Triples are also 'completed' if any one of @property, @rel or @rev are present. However, unlike the situation when @about or @typeof are present, all predicates are attached to one bnode:
> 
>     <div about="http://dbpedia.org/resource/Baruch_Spinoza" rel="dbp-owl:influenced">
>       <span property="foaf:name">Albert Einstein</span>
>       <span property="dbp:dateOfBirth" datatype="xsd:date">1879-03-14</span>
>       <div rel="dbp-owl:residence">
>         <span about="http://dbpedia.org/resource/German_Empire" />
>         <span about="http://dbpedia.org/resource/Switzerland" />
>       </div>
>     </div>

To be equivalent to the RDF generated from this markup, the microdata JSON would be:

    { "items": [
      {
        "type": "http://www.w3.org/2000/01/rdf-schema#Resource" ,
        "id": "http://dbpedia.org/resource/Baruch_Spinoza" ,
        "properties": {
          "http://dbpedia.org/ontology/influenced": [{
            "properties": {
              "http://xmlns.com/foaf/0.1/name": [ "Albert Einstein" ] ,
              "http://dbpedia.org/property/dateOfBirth": [ "1879-03-14" ]
              "http://dbpedia.org/ontology/residence": [
                "http://dbpedia.org/resource/German_Empire" ,
                "http://dbpedia.org/resource/Switzerland"
              ]
            }
          }]
        }
      }
    ]}

Microdata is a lot more explicit about when items get created, and consequently requires a bit more markup:

    <div itemscope itemtype="http://www.w3.org/2000/01/rdf-schema#Resource"
         itemid="http://dbpedia.org/resource/Baruch_Spinoza">
      <div itemprop="http://dbpedia.org/ontology/influenced" itemscope>
        <span itemprop="name">Albert Einstein</span>
        <time itemprop="http://dbpedia.org/property/dateOfBirth">1879-03-14</time>
        <div>
         <link itemprop="http://dbpedia.org/ontology/residence" 
               href="http://dbpedia.org/resource/German_Empire" />
         <link itemprop="http://dbpedia.org/ontology/residence"
               href="http://dbpedia.org/resource/Switzerland" />
        </div>
      </div>
    </div>

## Overriding Text Content

> The value of @content is given precedence over any element content, so the following would give exactly the same triple as shown above:
> 
>     <span about="http://internet-apps.blogspot.com/"
>           property="dc:creator" content="Mark Birbeck">John Doe</span>

The equivalent microdata should generate the JSON:

    { "items": [
      {
        "type": "http://www.w3.org/2000/01/rdf-schema#Resource" ,
        "id": "http://internet-apps.blogspot.com/" ,
        "properties": {
          "http://purl.org/dc/terms/creator": [ "Mark Birbeck" ]
        }
      }
    ]}

Only the `<time>` element and links override the content of an element in microdata. So a mirror of this example needs a separate element:

      <span itemscope itemtype="http://www.w3.org/2000/01/rdf-schema#Resource"
            itemid="http://internet-apps.blogspot.com/">
        <meta itemprop="http://purl.org/dc/terms/creator" content="Mark Birbeck" />
        John Doe
      </span>

## Language Support

> In RDFa the Host Language may provide a mechanism for setting the language tag. In XHTML+RDFa [XHTML-RDFA], for example, the XML language attribute @xml:lang or the attribute @lang is used to add this information, whether the plain literal is designated by @content, or by the inline text of the element:
> 
>     <meta about="http://example.org/node"
>       property="ex:property" xml:lang="fr" content="chat" />

Like the datatype of a value, the language of a value isn't captured by the microdata data model or the JSON representation of that data model. So the fact that 'chat' is French is lost:

    { "items": [
      {
        "type": "http://www.w3.org/2000/01/rdf-schema#Resource" ,
        "id": "http://example.org/node" ,
        "properties": {
          "http://example.org/property": [ "chat" ]
        }
      }
    ]}

The equivalent microdata is thus:

    <span itemscope itemtype="http://www.w3.org/2000/01/rdf-schema#Resource"
          itemid="http://example.org/node"
      <meta itemprop="ex:property" xml:lang="fr" content="chat" />
    </span>

with the language only accessible if you are using the DOM to process the microdata.

## Literals that Include Markup

> RDFa therefore supports the use of normal markup to express XML literals, by using @datatype:
> 
>     <h2 property="dc:title" datatype="rdf:XMLLiteral">
>       E = mc<sup>2</sup>: The Most Urgent Problem of Our Time
>     </h2>

The `datatype="rdf:XMLLiteral"` acts like a flag to indicate that the serialised content of the element (`innerHTML`) needs to be used as the value of the property, rather than the `textContent`, which includes markup, can be expressed in microdata JSON as follows:

    { "http://purl.org/dc/terms/title": "E = mc<sup>2</sup>: The Most Urgent Problem of Our Time" }

There's no way to generate this in microdata except by repeating the escaped version of the content in a `content` attribute:

    <h2>
      E = mc<sup>2</sup>: The Most Urgent Problem of Our Time
      <meta itemprop="http://purl.org/dc/terms/title"
        content="E = mc&lt;sup>2&lt;/sup>: The Most Urgent Problem of Our Time" />
    </h2>

This is hardly ideal. It's tedious enough with a short string like this one; for larger amounts of information such as long descriptions of an event, it would be very tedious.

## The `resource` Attribute

> RDFa provides the @resource attribute as a way to set the object of statements. This is particularly useful when referring to resources that are not themselves navigable links:
> 
>     <html>
>       <head>
>         <title>On Crime and Punishment</title>
>         <base href="http://www.example.com/candp.xhtml" />
>       </head>
>       <body>
>         <blockquote about="#q1" rel="dc:source" resource="urn:ISBN:0140449132" >
>           <p id="q1">
>             Rodion Romanovitch! My dear friend! If you go on in this way
>             you will go mad, I am positive! Drink, pray, if only a few drops!
>           </p>
>         </blockquote>
>       </body>
>     </html>

This should produce:

    { "items": [
      {
        "type": "http://www.w3.org/2000/01/rdf-schema#Resource" ,
        "id": "http://www.example.com/candp.xhtml#q1" ,
        "properties": {
          "http://purl.org/dc/terms/source": [ "urn:ISBN:0140449132" ]
        }
      }
    ]}

which is expressed through:

    <html>
      <head>
        <title>On Crime and Punishment</title>
        <base href="http://www.example.com/candp.xhtml" />
      </head>
      <body>
        <blockquote itemscope itemtype="http://www.w3.org/2000/01/rdf-schema#Resource" itemid="#q1">
          <link itemprop="http://purl.org/dc/terms/source" href="urn:ISBN:0140449132" />
          <p id="q1">
            Rodion Romanovitch! My dear friend! If you go on in this way
            you will go mad, I am positive! Drink, pray, if only a few drops!
          </p>
        </blockquote>
      </body>
    </html>

The property and value have to be moved onto a nested `<link>`, but this is a more extensible pattern than the RDFa method as it enables other properties to be expressed in the same way.

## Multiple Types

This last example comes from the wild rather than being an example in the specification. At [http://bitmunk.com/browse](http://bitmunk.com/browse) we find:

    <span about="http://bitmunk.com/about#service" 
          typeof="vcard:VCard commerce:Business gr:BusinessEntity" 
          property="rdfs:label vcard:fn">Bitmunk</span> 

This shows the use of multiple types and of multiple properties with the same value, because the pages are attempting to use multiple vocabularies that cover the same domain (organisations) to different depths. In the equivalent microdata, we have to choose one of the types; I'm going to assume that it should just use the first one from the `typeof` attribute:

    { "items": [
      {
        "type": "http://www.w3.org/2006/vcard/ns#VCard" ,
        "id": "http://bitmunk.com/about#service" ,
        "properties": {
          "http://www.w3.org/1999/02/22-rdf-syntax-ns#type": [
            "http://purl.org/commerce#Business" ,
            "http://purl.org/goodrelations/v1#BusinessEntity"
          ] ,
          "http://www.w3.org/2000/01/rdf-schema#label": [ "Bitmunk" ] ,
          "fn": [ "Bitmunk" ]
        }
      }
    ]}

The microdata equivalent is:

    <span itemscope itemid="http://bitmunk.com/about#service" 
          itemtype="http://www.w3.org/2006/vcard/ns#VCard">
      <link itemprop="http://www.w3.org/1999/02/22-rdf-syntax-ns#type"
           href="http://purl.org/commerce#Business" />
      <link itemprop="http://www.w3.org/1999/02/22-rdf-syntax-ns#type"
           href="http://purl.org/goodrelations/v1#BusinessEntity" />
      <span itemprop="http://www.w3.org/2000/01/rdf-schema#label fn">Bitmunk</span>
    </span>

Notes:

  * Technically, the RDFa doesn't place any ordering on the three classes, but I'm picking the first for the purpose of the microdata conversion. The other classes are harder to get at in the JSON: they have to be referenced via the `rdf:type` microdata property rather than the `type` JSON property. Consumers that are on the lookout for items of the type `gr:BusinessEntity` wouldn't spot these items.
