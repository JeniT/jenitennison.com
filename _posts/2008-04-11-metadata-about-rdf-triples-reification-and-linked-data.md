---
layout: drupal-post
excerpt_separator: "<!--break-->"
title: ! 'Metadata about RDF triples: reification and Linked Data'
created: 1207947547
tags:
- rdf
- genealogy
---
Those of you who have been following this blog will know that I've been thinking recently about [how to handle uncertainty related to RDF triples][4] (specifically in the context of a genealogical web app). Certainty isn't the only kind of metadata-about-triples that you'd want to keep in an app like this. We need to know things like:

  * who made the statement
  * when the statement was made
  * what evidence that led to the statement being made
  * licensing information about the reuse of the statement
  * (if we go with the rating idea) what ratings the statement has been given
  * (if we allow editing of statements) what changes have been made to the statement over time

and so on. In short, all the metadata that you'd want to associate with *resources* you'd also want to associate with *statements*.

[4]: http://www.jenitennison.com/blog/node/67#comment-4512 "Jeni's Musings: Web 2.0 project: RDF and uncertainty"

<!--break-->

I'd anticipated using [reification][2] to associate metadata with statements. Something like this

    <rdf:Statement rdf:about="#statement1">
      <rdf:subject rdf:resource="/people/CharlesDarwin" />
      <rdf:predicate rdf:resource="/ontology/event-roles/passenger" />
      <rdf:object rdf:resource="/events/BeagleVoyage" />
      <dc:creator rdf:resource="/users/JeniT" />
      <dc:date rdf:datatype="xsd:date">2008-04-11</dc:date>
      <g:certainty rdf:datatype="xsd:decimal">1.0</g:certainty>
      ...
    </rdf:Statement>

or [using `rdf:ID`][3], although this does limit the URI of our statements to hash-URIs:

    <rdf:Description about="/people/CharlesDarwin">
      <r:passenger rdf:ID="#statement1" rdf:resource="/events/BeagleVoyage" /> 
    </rdf:Description>
    <rdf:Description about="#statement1">
      <dc:creator rdf:resource="/users/JeniT" />
      <dc:date rdf:datatype="xsd:date">2008-04-11</dc:date>
      <g:certainty rdf:datatype="xsd:decimal">1.0</g:certainty>
    </rdf:Description>

[2]: http://www.w3.org/TR/rdf-primer/#reification "W3C: RDF Primer: Reification"
[3]: http://www.w3.org/TR/2004/REC-rdf-syntax-grammar-20040210/#section-Syntax-reifying "W3C: RDF/XML Syntax Specification: Reifying Statements: rdf:ID"

(Please feel free to correct my RDF, RDF-folks!)

We can embed this information into our web pages using RDFa:

    <div about="#statement1" instanceof="rdf:Statement">
      <p class="statement">
        <a rel="rdf:subject" href="/people/CharlesDarwin">
          Charles Darwin
        </a>
        was a
        <a rel="rdf:predicate" href="/ontologies/event-roles/passenger">
          passenger
        </a>
        on the
        <a rel="rdf:object" href="/events/BeagleVoyage">
          <span about="/people/CharlesDarwin" 
                rel="r:passenger" 
                resource="/events/BeagleVoyage">
            Beagle Voyage
          </span>
        </a>
      </p>
      <dl class="metadata">
        <dt>Author:</dt>
        <dd>
          <a rel="dc:creator" href="/users/JeniT">
            Jeni Tennison
          </a>
        </dd>
        <dt>Date:</dt>
        <dd property="dc:date" datatype="xsd:date" 
            content="2008-04-11">
          11 Apr, 2008
        </dd>
        <dt>Certainty:</dt>
        <dd property="b:certainty" datatype="xsd:decimal"
            content="1.0">
          <img src="stars5.gif" alt="five stars" />
        </dd>
      </dl>
    </div>

Note that I've incorporated both the reified statement and the statement itself into the RDFa. If I'm correct in my mental parsing of RDFa, I think this leads to the set of triples from the RDF/XML in the above examples plus the triple:

    </people/CharlesDarwin> r:passenger </events/BeagleVoyage> .

But then the other day, I was reading the tutorial [How to publish Linked Data on the Web][1], which says

> We discourage the use of RDF reification as the semantics of reification are unclear and as reified statements are rather cumbersome to query with the SPARQL query language. Metadata can be attached to the information resource instead, as explained in Section 5.

[1]: http://www4.wiwiss.fu-berlin.de/bizer/pub/LinkedDataTutorial/ "How to publish Linked Data on the Web"

Jumping to Section 5, I find

> **Metadata:** The representation should contain any metadata you want to attach to your published data, such as a URI identifying the author and licensing information. These should be recorded as RDF descriptions of the information resource that describes a non-information resource; that is, the subject of the RDF triples should be the URI of the information resource. Attaching meta-information to that information resource, rather than attaching it to the described resource itself or to specific RDF statements about the resource (as with RDF reification) plays nicely together with using Named Graphs and the SPARQL query language in Linked Data client applications...

There are some examples of what this looks like within the tutorial. The first is an "**authoritative description**" found at `http://dbpedia.org/data/Alec_Empire` after a 303 redirection from `http://dbpedia.org/resource/Alec_Empire`.

    # Metadata and Licensing Information
    <http://dbpedia.org/data/Alec_Empire>
        rdfs:label "RDF description of Alec Empire" ;
        rdf:type foaf:Document ;
        dc:publisher <http://dbpedia.org/resource/DBpedia> ;
        dc:date "2007-07-13"^^xsd:date ;
        dc:rights <http://en.wikipedia.org/wiki/WP:GFDL> .
    
    # The description
    <http://dbpedia.org/resource/Alec_Empire> 
        foaf:name "Empire, Alec" ;
        rdf:type foaf:Person ;
        rdf:type <http://dbpedia.org/class/yago/musician> ;
        rdfs:comment
            "Alec Empire (born May 2, 1972) is a German musician who is ..."@en ;
        rdfs:comment
            "Alec Empire (eigentlich Alexander Wilke) ist ein deutscher Musiker. ..."@de ;
        dbpedia:genre <http://dbpedia.org/resource/Techno> ;
        dbpedia:associatedActs 
          <http://dbpedia.org/resource/Atari_Teenage_Riot> ;
        foaf:page <http://en.wikipedia.org/wiki/Alec_Empire> ;
        foaf:page <http://dbpedia.org/page/Alec_Empire> ; 
        rdfs:isDefinedBy <http://dbpedia.org/data/Alec_Empire> ;
        owl:sameAs <http://zitgist.com/music/artist/d71ba53b-23b0-4870-a429-cce6f345763b> .

The second is a **non-authoritative description** found at `http://sites.wiwiss.fu-berlin.de/suhl/bizer/pub/LinkedDataTutorial/ChrisAboutRichard`:

    # Metadata and Licensing Information
    <>
        rdf:type foaf:Document ;
        dc:author <http://www.bizer.de#chris> ;
        dc:date "2007-07-13"^^xsd:date ;
        cc:license <http://web.resource.org/cc/PublicDomain> .
    
    # The description
    <http://richard.cyganiak.de/foaf.rdf#cygri> 
        foaf:name "Richard Cyganiak" ;
        foaf:topic_interest <http://dbpedia.org/resource/Category:Databases> ;
        foaf:topic_interest <http://dbpedia.org/resource/MacBook_Pro> ;
        rdfs:isDefinedBy <http://richard.cyganiak.de/foaf.rdf> ;
        rdf:seeAlso <> .

Note that `rdfs:isDefinedBy` does not necessarily point to the data you get when you retrieve the resource, but to an (presumably there can be more than one) authoritative description of the resource. It's also associated with a particular *resource* rather than a particular *statement*.

To know which metadata applies to a particular statement, an application must know where it got the statement from. In effect, a statement here has *four* parts: subject, property, object and location (with the possibility that multiple statements with the same subject, property and object might have different locations and therefore different metadata). This is similar to assigning an ID to a statement, as with `rdf:ID`, but restricts the statement's identifier to being the location where it was found.

So what does that mean for the genealogical web app? Well, in the app we're going to find any given statement by a particular user quoted on lots of pages. I was intending to RDFa them all but that would mean lots of duplicate statements from different locations, potentially bloating applications that were harvesting the data.

I can't work out whether I like or loathe the Linked Data concept of associating metadata with the document in which you find triples. In some ways it seems very natural -- look for information about a resource at the URI for the resouce -- but the metadata mechanisms restrict where you can place statements on the web (or at least assign semantics to their location which aren't necessarily intended), and that seems like a Bad Thing. On the other hand, perhaps I'm just being overly influenced by the desire to use RDFa, which does lead one to want to mark up data wherever it appears.

I'd welcome any advice.
