---
layout: drupal-post
title: ! 'rdfQuery: Progressive Enhancement with RDFa'
created: 1226767562
tags:
- rdf
- genealogy
- rdfquery
- jquery
- rdfa
---
Earlier this week I presented at [SWIG-UK][SWIG] about [rdfQuery][rdfQuery]. rdfQuery is a set of plugins that I've developed for [jQuery][jQuery] in order to support RDFa parsing, querying and generation. There are a bunch of other Javascript libraries for RDFa around, such as Mark Birbeck's [Ubiquity RDFa][Ubiquity] and Ben Adida's [RDFa library][Adida]. What I've really tried to do with rdfQuery is tie it in with the "Write Less, Do More" philosophy of jQuery and provide a neat, elegant API. At least that's the aim!

[SWIG]: http://swig.networkedplanet.com/november2008.html "Semantic Web Interest Group Community Event"
[rdfQuery]: http://code.google.com/p/rdfquery "rdfQuery: RDF plugins for jQuery"
[jQuery]: http://www.jquery.com "jQuery: The Write Less, Do More, Javascript Library"
[Ubiquity]: http://code.google.com/p/ubiquity-rdfa/ "Ubiquity RDFa"
[Adida]: http://www.w3.org/2006/07/SWD/RDFa/impl/js/ "RDFa Javascript Library"

<!--break-->

So what does it do? Well, I've just added the demo that I used on Tuesday into [the repository][svn], so if you grab hold of that you can take a look. Here's a screenshot of the demo.

[svn]: http://code.google.com/p/rdfquery/source/checkout "rdfQuery: SVN repository"

<img src="/blog/files/markup-demo.jpg" alt="Screenshot of rdfQuery demo" width="100%" />

The demo shows the overall concept of rdfQuery, namely that semantic markup can be useful not only to the crawlers that extract data from your pages to pump into massive triplestores, but also for you as a developer. In this case, which is a simple genealogy-type application, I want to have the people and places that are relevant to this particular extract highlighted within the text. I also want them listed on the left, with their details summarised.

So the demo illustrates three things that rdfQuery does to help:

  * gleaning triples from a section of the page (not just the whole page); in this case the triples are marked up with RDFa
  * querying the data to construct objects that represent the results of those queries, then doing things with those results
  * automatically adding RDFa to elements within the page, to update the data that it holds

It also demonstrates rough versions of a couple of things that rdfQuery could and should do that I aim to work on soon:

  * reasoning based on the data that's found in the page
  * using ontologies to decide how to handle the data you find

By the by, it shows a simple, natural-language interface for making statements based on some text, but don't let that distract you. It's just regular expression processing.

There are four parts of this page. The main part contains some text about Charles Darwin. If you look at the source, you'll see that it's been marked up with some RDFa like this:

    <span about="#CharlesRobertDarwin" typeof="foaf:Person" 
          property="rdfs:label" datatype="">
      <span property="foaf:firstName">Charles</span> Robert 
      <span property="foaf:surname">Darwin</span>
    </span> was <span about="#CharlesRobertDarwin" rel="biografr:hasBirthPlace">born in 
    <span about="#Shrewsbury" typeof="vcard:Address" 
          property="rdfs:label" datatype="">
      <span property="vcard:locality">Shrewsbury</span>, 
      <span property="vcard:region">Shropshire</span>, 
      <span property="vcard:country">England</span>
    </span></span> on <span about="#CharlesRobertDarwin" property="biografr:bornOn" 
      content="1809-02-12" datatype="xsd:date">12 February 1809</span> at his 
      family home, the Mount. ...

This source is also shown in the textarea at the bottom of the page. Obviously this wouldn't be visible in a real application, but it enables you to see what's going on in the demo. Changing it won't do anything; you can imagine that string being POSTed back to the server. I've also added some CSS that gives a border to any elements with a `typeof` attribute. Elements that have a `property` change their colour when you mouse over them.

So the page contains some RDFa. But what it doesn't contain (in the source) is any information in the menu on the left. This gets populated based on the RDFa. If you click on Charles Robert Darwin, you'll see the data that's been gleaned about him, including (at the bottom), the derived fact that Robert Darwin was Charles Darwin's father. Anything in black is information pulled from the RDFa; anything in orange is derived.

Next, try typing "Susannah Darwin was a person" into the text input and hit return. You should get Susannah Darwin added to the list of people. More importantly, if you look at the new source of the page, you'll see that the phrase "Susannah Darwin" has been marked up with some RDFa to indicate that she was, indeed, a person and that "Susannah Darwin" can be used as a label for her.

You can try typing a few more facts into the box if you like. I suggest:

  1. "Charles Robert Darwin was also known as Darwin"
  2. "Susannah Darwin was Darwin's mother"
  3. "Susannah Darwin's surname was Darwin"
  4. "Josiah Wedgwood was a person"
  5. "Susannah Darwin's father was Josiah Wedgwood"

So this is all very cool and all, but the point was to show the code. So here we go.

## Gleaning and Querying ##

Let's look at how the lists are populated:

    457: populateLists = function () {
    458:   var rdf = $('#content').rdf();
    459:   people.empty();
    460:   places.empty();
    461:   rdf
    462:     .prefix('rdfs', ns.rdfs)
    463:     .prefix('foaf', ns.foaf)
    464:     .where('?person a foaf:Person')
    465:     .where('?person rdfs:label ?label')
    466:     .each(function () {
    467:       addIndividual(people, this.person, this.label.value);
    468:     })
    469:     .reset()
    470:     .where('?place a vcard:Address')
    471:     .where('?place rdfs:label ?label')
    472:     .each(function () {
    473:       addIndividual(places, this.place, this.label.value);
    474:     });
    475: },

Line 458 parses the RDFa within the element with the id `content` (this is a `<div>` that wraps around the paragraphs about Charles Darwin). The `rdf` variable holds an rdfQuery object, which is very similar to a jQuery object except that it queries over RDF triples rather than DOM nodes. The rdfQuery object holds a pointer to a databank, which holds the triples that have been collected.
  
Lines 459 and 460 empty out the existing lists of people and places if there are any. The `people` and `places` variables are set earlier in the script and are jQuery objects.

Now the fun begins. I first set some prefixes on the rdfQuery object so that I can use those prefixes in [CURIEs][CURIE] within the queries. In fact, these prefixes will have been set up by default anyway, because they're declared in the HTML page, but it doesn't hurt.

[CURIE]: http://www.w3.org/TR/curie/ "CURIE Syntax 1.0"

Lines 464 and 465 locate triples in the databank based on simple [SPARQL][SPARQL]-based queries. The first `where()` call creates a new rdfQuery object that, like a jQuery object, looks a bit like an array. The array contains objects, one for each triple that matches the pattern `?person a foaf:Person`. Each of the objects has a `person` property containing the resource that represents the person. So the rdfQuery that results from this `where()` call looks like:

[SPARQL]: http://www.w3.org/TR/rdf-sparql-query/ "SPARQL Query Language for RDF"

    { length: 2,
      0: { person: $.rdf.resource('<#CharlesRobertDarwin>') },
      1: { person: $.rdf.resource('<#RobertDarwin>') },
      ... bunch of other properties and methods that aren't important here ... }

The second `where()` call creates another new rdfQuery object based on combining the previous query results with the any triples that match the pattern `?person rdfs:label ?label`. This holds objects with `person` and `label` properties, one for each person and their label. So the result of this looks like:

    { length: 2,
      0: { person: $.rdf.resource('<#CharlesRobertDarwin>'),
           label:  $.rdf.literal('"Charles Robert Darwin"') },
      1: { person: $.rdf.resource('<#RobertDarwin>'),
           label:  $.rdf.literal('"Robert Darwin"') },
      ... bunch of other properties and methods that aren't important here ... }

The `each()` on lines 466-468 then iterates over the objects that it's constructed and calls the `addIndividuals()` function (which is particular for this demo), passing in the list in the HTML, the person resource and the value of the label literal.

Line 469 uses the `reset()` method to go back to the original rdfQuery object. If I didn't do this, any further queries would simply add to the objects that I already have, or remove them if nothing matched.

Lines 470-474 do the same thing for the places that are marked up within the text.

There are various other places within `markup.js` that glean and query RDF. For example, the `addDescription()` function, which populates the list items on the left with data about particualr people and places. That function demonstrates the use of the `about()` method, which gives you all the triples about a particular subject, and shows how to use arguments with the `each()` method when you want to use the index of the query result or the triples that were used to create the query result.

## Updating RDFa ##

So how easy is it to update the RDFa on the web page? Well, if you know what you want to add, then it's dead easy. Here's the code that does it on lines 452 and 532:

    span.rdfa(triple);

The variable `span` here is a jQuery object. The triple itself is a `$.rdf.triple`. I'd tell you more about them but I think I've gone on long enough.

## Final Words ##

[rdfQuery][rdfQuery] is a Google Code project, released under an MIT license. If you're interested in contributing, send me an email and I'll add you as a member, or an owner if you're really keen. If you're interested, I've set up a [discussion group][group]. You can post any questions there, although of course if you find bugs, do [add an issue][issue].

[group]: http://groups.google.com/group/rdfquery "rdfQuery Discussion Group"
[issue]: http://code.google.com/p/rdfquery/issues/entry "rdfQuery: Add Issue"

