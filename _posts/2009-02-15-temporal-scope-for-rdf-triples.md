---
layout: drupal-post
title: Temporal Scope for RDF Triples
created: 1234718590
tags:
- rdf
- rdfa
---
To me, the biggest deficiency in RDF is how hard it is to associate metadata with statements. I've [talked before][1] about the requirement in the genealogical application I'm toying with to provide metadata such as who made a statement, when, based on which source, the certainty in it and so on. But there's one type of metadata that I think is required in practically every domain: the temporal scoping of statements.

[1]: http://www.jenitennison.com/blog/node/85 "Jeni's Musings: Metadata about RDF triples: reification and Linked Data"

<!--break-->

In the [London Gazette RDFa work][2] that we've been doing for [OPSI][3] at [TSO][4], there are frequently notices that contain a statement that is not true at the time the notice is published, but will become true on a particular date in the future. Take this example from [a notice published on 10th February 2009][5]:

[2]: http://2008.xtech.org/public/schedule/detail/528 "XTech 2008: SemWebbing the London Gazette"
[3]: http://www.opsi.gov.uk/ "Office of Public Sector Information"
[4]: http://www.tso.co.uk/ "The Stationery Office"
[5]: http://www.london-gazette.co.uk/issues/58976/notices/732083 "Issue 58976: Notice 732083"

> Jikoa Chiwete Monu, ceased to be a Partner in John & Co Solicitors, of Suites G, H & I, 1st Floor, 135-143 Stockwell Road, London SW9 9TN, with effect from 30 January 2009.

We know that Jikoa Chiwete Monu was a partner in John & Co Solicitors *up to* 30 January 2009, and was not a partner in John & Co Solicitors *after* 30 January 2009. We know that on 10 February 2009, the address of John & Co Solicitors was the one given in the notice, but we don't know that was their address a year ago.

Notices like this are published every day in the London Gazette. The assertions in the notices reflect the state of the world on the day the notice is published, or (as in this case) at some other known date. Also, the date on which a notice is published is important: in many cases it has legal significance. But it would be wrong to believe that the statements in the notices continue to be true indefinitely, or that they were true before the date of publication.

There seem to be two acceptable ways of handling the problem, and one unacceptable way. The unacceptable way is to give a reified triple and hang metadata from that reified object. Something like:

    :triple1 a rdf:Statement ;
      rdf:subject :JikoaChiweteMonu ;
      rdf:predicate partnerships:isMemberOf ;
      rdf:object :JohnAndCoSolicitors ;
      dc:temporal [ 
        g:endDate "2009-01-30"^^xsd:date 
      ] .
    
    :triple2 a rdf:Statement ;
      rdf:subject :JohnAndCoSolicitors ;
      rdf:predicate organisation:hasAddress ;
      rdf:object [
        a vcard:Address ;
        vcard:street-address "135-143 Stockwell Road" ;
        vcard:locality "London" ;
        vcard:postal-code "SW9 9TN"
      ] ;
      dc:temporal [
        g:includesDate "2009-02-10"^^xsd:date 
      ] .

The reason that this is unacceptable is that reified statements aren't incorporated into triplestores in the same way as normal statements, so you can't query as naturally on these statements as you can on unreified statements. It's even more of a problem when some of the triples are reified and some aren't.

On to the acceptable ways of representing the temporal scope of the statements. One is to create objects that represent things like 'membership' and 'occupation'. Then you can do things like:

    :membership a partnerships:Membership ;
      partnerships:hasMember :JikoaChiweteMonu ;
      partnerships:hasPartnership :JohnAndCoSolicitors ;
      dc:temporal [
        g:endDate "2009-01-30"^^xsd:date 
      ] .
      
    :occupation a organisation:Occupation ;
      organisation:isOccupiedBy :JohnAndCoSolicitors ;
      organisation:hasAddress [
        a vcard:Address ;
        vcard:street-address "135-143 Stockwell Road" ;
        vcard:locality "London" ;
        vcard:postal-code "SW9 9TN"
      ] ;
      dc:temporal [
        g:includesDate "2009-02-10"^^xsd:date
      ] .

The other approach is to use named graphs to provide metadata about the statements. This next example uses [TriG syntax][6], in which statements can be clustered into named graphs:

[6]: http://www4.wiwiss.fu-berlin.de/bizer/TriG/ "TriG Syntax"

    :G1 {
      :JikoaChiweteMonu partnerships:isMemberOf :JohnAndCoSolicitors .
    }
    :G2 {
      :JohnAndCoSolicitors organisation:hasAddress [
        a vcard:Address ;
        vcard:street-address "135-143 Stockwell Road" ;
        vcard:locality "London" ;
        vcard:postal-code "SW9 9TN"
      ] .
    }
    {
      :G1 dc:temporal [
        g:endDate "2009-01-30"^^xsd:date 
      ] .
      :G2 dc:temporal [
        g:includesDate "2009-02-10"^^xsd:date 
      ] .
    }

I prefer the latter approach because it doesn't require any forward planning: you don't have to think before hand about the ways in which things might change over time in order to make statements about the temporal scope of assertions. If you look at existing ontologies, such as FOAF, they don't really address the fact that people might change their name or (even more likely) place of work over time.

If you think about it long term (which we have to given that the Gazette goes back 350 years or thereabouts), even the details of an address can change over time, as streets can change name, be reclassified as boundaries change to belong to different localities and regions, and can change their postcode. Introducing additional resources for all these temporally scoped statements would cause an amazing amount of bloat and lots of indirection.

The named graph method also, in my opinion, enables more natural querying of the dataset. You can do something like:

    SELECT ?locality
    WHERE {
      :JohnAndCoSolicitors organisation:hasAddress ?address .
      ?address vcard:locality ?locality .
    }

rather than:

    SELECT ?locality
    WHERE {
      ?occupation organisation:isOccupiedBy :JohnAndCoSolicitors ;
                  organisation:hasAddress ?address .
      ?address vcard:locality ?locality .
    }

Named graphs can be queried with SPARQL. So with the named graph method, it's possible to find look for partners of `:JohnAndCoSolicitors` prior to a particular date:

    SELECT ?partner
    WHERE {
      GRAPH ?graph {
        ?person partnerships:isMemberOf :JohnAndCoSolicitors .
      }
      OPTIONAL {
        ?graph dc:temporal ?scope .
        ?scope g:endDate ?date .
        FILTER (?date > "2009-01-01"^^xsd:date) 
      }
    }

But the standard way of naming a graph seems to be to use the location from which the graph was retrieved. This makes a lot of sense as a default: you can infer the provenance, and that the statements on the page were true on the day the RDF representation was retrieved. But it doesn't work in cases like that above where there are several statements on the page with different provenance or certainty or temporal scope (or any other statement metadata you might care to mention).

We're serving the London Gazette notices as RDFa, so the challenge is how to incorporate information about the graph in which a triple appears within RDFa.

A generalised way to do it would be to introduce a new `graph` attribute, defaulting to the base URI of the page. Then we could do:

    <meta about="[:G2]" property="g:onDate" content="2009-02-10" datatype="xsd:date" />
    ...
    <p graph="[:G1]" about="[:JikoaChiweteMonu]">
      Jikoa Chiwete Monu, ceased to be a Partner in 
      <span rel="partnerships:isMemberOf" resource="[:JohnAndCoSolicitors]">
        John & Co Solicitors, of 
        <span graph="[:G2]" rel="organisation:hasAddress">
          <span typeof="vcard:Address">
            Suites G, H & I, 1st Floor, 
            <span property="vcard:street-address">135-143 Stockwell Road</span>, 
            <span property="vcard:locality">London</span> 
            <span property="vcard:postal-code">SW9 9TN</span>
          </span>
        </span>
      </span>, with effect from 
      <span about="[:G1]" property="g:endDate" 
        content="2009-01-30" datatype="xsd:date">30 January 2009</span>.
    </p>

Another possibility would be to use the `id` attribute to label parts of the page that hold statements, and use fragment identifiers in `about` attributes to provide metadata about those particular statements:

    <meta about="#G2" property="g:onDate" content="2009-02-10" datatype="xsd:date" />
    ...
    <p id="G1" about="[:JikoaChiweteMonu]">
      Jikoa Chiwete Monu, ceased to be a Partner in 
      <span rel="partnerships:isMemberOf" resource="[:JohnAndCoSolicitors]">
        John & Co Solicitors, of 
        <span id="G2" rel="organisation:hasAddress">
          <span typeof="vcard:Address">
            Suites G, H & I, 1st Floor, 
            <span property="vcard:street-address">135-143 Stockwell Road</span>, 
            <span property="vcard:locality">London</span> 
            <span property="vcard:postal-code">SW9 9TN</span>
          </span>
        </span>
      </span>, with effect from 
      <span about="#G1" property="g:endDate" 
        content="2009-01-30" datatype="xsd:date">30 January 2009</span>.
    </p>

The disadvantage of this approach is that you can't have statements in two different parts of the page that belong to the same graph. On the other hand, it's valid!

I'm really interested in other approaches that people have used to address the requirement of associating metadata with triples, particularly using RDFa. I'm also interested to know if anyone has existing vocabularies for periods of time with known start/end dates and included dates.

