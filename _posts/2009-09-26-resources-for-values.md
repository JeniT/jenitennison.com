---
layout: drupal-post
title: Resources for Values
created: 1253994544
tags:
- linked data
---
When [Leigh Dodds](http://www.ldodds.com/) presented about Linked Data at the [XML Summer School](http://www.xmlsummerschool.com/) this year, one of the things he suggested was that when you have a controlled vocabulary, you should define resources for the terms in that vocabulary rather than having a fixed set of literal values.

For example, if you're saying that the topic of a page is elephants you should use a triple like:

    <> dc:subject <http://example.com/id/concept/animal/elephant> .

rather than one like:

    <> dc:subject "elephant"^^xsd:token .

There are two advantages of using a resource here rather than a literal value:

  * You can associate other metadata with the term. For example, you can use [SKOS](http://www.w3.org/2004/02/skos/) to describe it and its associations with terms from other controlled vocabularies, giving it multiple labels in different languages, providing a description and examples and so on.
  
  * You can more accurately and easily associate multiple documents that use the same term. Of course you could always use string-based matching to pull together documents using the same subject, but that's much more prone to error, and would leave you with less certainty about the results of your query.

What struck me, though, was that these arguments apply just as well to other typed values that we use within RDF. For example, say I wanted to describe the colour of my eyes. I could say something like:

    <#me> eg:eyeColour "#695C3E"^^eg:colour .

But wouldn't it be better to use:

    <#me> eg:eyeColour <http://example.com/id/concept/colour/rgb/695C3E> .

The colour resource could have properties associated with it:

    <http://example.com/id/concept/colour/rgb/695C3E>
      a eg:Colour ;
      skos:prefLabel "#695C3E" ;
      eg:red "69"^^eg:hex ;
      eg:green "5C"^^eg:hex ;
      eg:blue "3E"^^eg:hex ;
      eg:hue 42 ;
      eg:saturation 41 ;
      eg:brightness 41 ;
      eg:pantone ... ;
      ... .

and so on. And if other people pointed to the same resource, a semantic search engine could give you a list of things of that colour.

And what about those numbers? Would it be better if I said:

    <http://example.com/id/concept/colour/rgb/695C3E>
      eg:red <http://example.com/id/concept/number/hex/69> .

and there was information about that resource:

    <http://example.com/id/concept/number/hex/69>
      owl:sameAs <http://example.com/id/concept/number/105> .
      
    <http://example.com/id/concept/number/105>
      a eg:Integer ;
      rdf:value 105 ;
      eg:divisor
        <http://example.com/id/concept/number/3> ,
        <http://example.com/id/concept/number/5> ,
        <http://example.com/id/concept/number/7> ;
      ... .

and so on.

In fact, we already have identifiers for some of these resources. [DBPedia](http://www.dbpedia.org) inherits from [Wikipedia](http://www.wikipedia.org) information about (many) numbers and (some) dates. For example, check out what it says about [the number 720](http://dbpedia.org/resource/720_%28number%29) or the rather less helpful page on [the year 1914](http://dbpedia.org/resource/1914).

What we lose is a certain level of ease of querying because the values that can be compared by SPARQL (say) are an extra step away. But it's still doable so long as the resource has a `rdf:value` property holding the primitive literal for the type (one recognised by SPARQL). If I wanted to find married couples where the husband is younger than the wife, I could do something like:

    SELECT ?husband ?wife
    WHERE {
      ?husband eg:age ?husbandAgeResource .
      ?husbandAgeResource rdf:value ?husbandAge .
      ?wife eg:age ?wifeAgeResource .
      ?wifeAgeResource rdf:value ?wifeAge .
      FILTER (?husbandAge < ?wifeAge)
    }

One interesting aspect of these kinds of resources (and something Leigh promised to blog about too) is that they're either infinite or have a large enough value space that it would be impractical to store all the information about them within a traditional triplestore. They could be made available as linked data easily enough since much of the interesting information about a colour or number would be derivable. But it might be difficult to provide a SPARQL end point for them. For example, consider:

    SELECT ?number
    WHERE {
      ?number eg:divisor <http://example.com/id/concept/number/3> .
    }
    ORDER BY ?number
    LIMIT 10

There are already linked data spaces a bit like this floating around. The URIs defined by [LinkedGeoData](http://linkedgeodata.org/) are infinite, given that it accepts any number of decimal places for latitude and longitude (technically it defines resources for circular areas rather than points). The RDF/XML that we're producing for [UK Legislation](http://www.legislation.gov.uk/) is generated on demand based on a date which, for each item, can be any date between 1st February 1991 and the current date.

What do you think? Is it mad to use resources instead of literal values? Where do you stop? How can queries be carried out over these infinite (or extremely large) sets of resources?
