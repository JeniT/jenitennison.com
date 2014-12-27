---
layout: drupal-post
title: ! 'Creating Linked Data - Part V: Finishing Touches'
created: 1260003028
tags:
- rdf
- linked data
---
This is the fifth part in this series about creating linked data. I've talked previously about [analysis and modelling](http://www.jenitennison.com/blog/node/135), [defining URIs](http://www.jenitennison.com/blog/node/136), [defining concept schemes](http://www.jenitennison.com/blog/node/137) and [defining a vocabulary](http://www.jenitennison.com/blog/node/138). In this instalment I'll talk about the finishing touches that can make linked data easier to browse, query, locate and trust.

Note that we don't *have* to do any of these things; they're not part of the core data. We shouldn't beat ourselves up if we don't have time to do it right now, because we can always add them later, and it might be that you just don't agree that they should be done. But many of them don't take a lot of time and can enhance the user's experience of the data.

<!--break-->

## Labels ##

Every resource should have a label, even blank nodes. Adding labels makes it easier for people to generate HTML views from the data. Sometimes we have resources that have an obvious label (like the name of a local authority); at other times, the label needs to be constructed based on the other information that's available about the resource.

I talked in the last instalment about `skos:prefLabel` (preferred label), `skos:altLabel` (alternative label) and `rdfs:label`. Technically, `skos:prefLabel` and `skos:altLabel` are sub properties of `rdfs:label`, which means that if a resource has a `skos:prefLabel` it also has a `rdfs:label` with that value. However, drawing that conclusion requires either built-in knowledge of SKOS or the ability to both automatically get hold of the SKOS ontology and reason with it, which is feasible (this is one of the advantages of RDF, after all), but adds an extra hurdle for people wanting to use your data.

So it's best to give everything a `rdfs:label`, even if they already have a `skos:prefLabel` or `skos:altLabel`. It's also good to try to imagine that label in the context of having no other information about the thing that it's labelling, such as in the title of a page. For example, if you're looking at the observation `http://transport.data.gov.uk/id/traffic-count-point/13/direction/E/hour/2001-10-08T17:00:00/type/bicycle` in the context of a traffic count, it may seem sensible to label it just "bicycle" (as I did in the first iteration of turning this traffic count data into RDF). But without that context, it makes no sense. Better to label it "Bicycles - 8 Oct 2001 17:00-18:00 - East - Salterton Road, EAST OF DINAN WAY, EXMOUTH" and provide an even more descriptive `rdfs:comment` like "Number of bicycles counted travelling East at Salterton Road, EAST OF DINAN WAY, EXMOUTH on 8 October 2001 between 17:00 and 18:00.".

## Datasets ##

There are two kinds of datasets that are applicable to this particular ...err... set of data ... and that we should describe within the RDF. They are:

  * datasets that are sets of statistical data items (such as the observations in the traffic count data); these are best described using [SCOVO](http://sw.joanneum.at/scovo/schema.html)
  * datasets that are general descriptions of particular sets of linked data (such as roads or local authorities); these are best described using [voiD](http://semanticweb.org/wiki/VoiD)

Both kinds of datasets can be identified for UK government data using URIs in the form:

    http://{sector}.data.gov.uk/set/{dataset}/

### SCOVO Datasets ###

Every `scovo:Item` should be part of a `scovo:Dataset`, associated through a `scovo:dataset` (and a reverse `scovo:datasetOf`). A `scovo:Dataset` is pretty simple: all you really need to do is give it an identifier and, of course, a label. In this case, something like:

    http://transport.data.gov.uk/set/traffic-count/2001-2008/

This is an identifier that the various `scovo:Item`s should use to indicate where the data comes from:

    <http://transport.data.gov.uk/id/traffic-count-point/13/direction/E/hour/2001-10-08T17:00:00/type/bicycle>
      a scovo:Item ;
      scovo:dataset <http://transport.data.gov.uk/set/traffic-count/2001-2008/> ;
      traffic:count <http://transport.data.gov.uk/id/traffic-count-point/13/direction/E/hour/2001-10-08T17:00:00> ;
      traffic:vehicleType <http://transport.data.gov.uk/def/vehicle/bicycle> ;
      rdf:value 2 .

It's also an identifier that we can attach some metadata to. Obviously it needs a label, but we can also attach other metadata, such as the [provenance of the dataset](http://www.jenitennison.com/blog/node/133).

    <http://transport.data.gov.uk/set/traffic-count/2001-2008/>
      a scovo:Dataset ;
      a prv:DataItem ;
      rdfs:label "Traffic counts between 2001 and 2008"@en ;
      prv:createdBy [
        a prv:DataCreation ;
        prv:performedAt ... ;
        prv:performedBy ... ;
        prv:usedData ... ;
        prv:usedGuideline ... ;
      ] .

### VoiD Datasets ###

VoiD is designed to be used to describe sets of linked data, their contents, their provenance and their relationships with each other. There are many ways of dividing up the data that we've been looking at into datasets. We can start with a simple example: the dataset containing linked data about countries:

    <http://statistics.data.gov.uk/set/country/>
      a void:Dataset ;
      rdfs:label "Countries"@en ;
      foaf:homepage <http://statistics.data.gov.uk/set/country> ;
      dct:subject <http://dbpedia.org/resource/Country> ;
      cc:license [
        a cc:License ;
        rdfs:label "data.gov.uk Licence"@en ;
        foaf:homepage <http://data.hmg.gov.uk/terms-privacy> ;
        cc:permits cc:DerivativeWorks, cc:Distribution, cc:Reproduction ;
        cc:requires cc:Attribution ;
      ] ;
      void:exampleResource <http://statistics.data.gov.uk/id/country?name=England> ;
      void:sparqlEndpoint <http://services.data.gov.uk/statistics/sparql> ;
      void:uriRegexPattern "http://statistics.data.gov.uk/id/country?name=.+"^^xs:string ;
      void:vocabulary <http://statistics.data.gov.uk/def/administrative-geography/> ;
      void:vocabulary <http://www.w3.org/2000/01/rdf-schema#> .

This provides a link to a home page for the dataset, which should contain information about the dataset itself. (Accessing the URI for the dataset should also redirect users to this home page.) I've used the same URI as the dataset URI but without the slash at the end. (This is probably too subtle a difference between URIs; we don't currently have official guidance for URIs for documents-about-datasets or documents-about-definitions.)

The `void:exampleResource` property can be used to point to resources that can act as starting points for exploring the data, and the `void:sparqlEndpoint` property points at a SPARQL endpoint that can be used for deeper querying. The `void:uriRegexPattern` property provides a regular expression for the URIs that are used to identify the resources that the dataset is about. `void:vocabulary` points to the vocabularies that the dataset uses.

Various [Dublin Core](http://dublincore.org/documents/dcmi-terms/) properties can be used to provide metadata about the dataset, such as its subject matter. The [Creative Commons schema](http://creativecommons.org/ns) provides a way of indicating the licence that the dataset is made available under, which is essential information to enable reuse. (I've derived some RDF about the licence here from the one [described on the data.hmg.gov.uk pages](http://data.hmg.gov.uk/terms-privacy); there should be an official version some time soon.)

The data that we can actually produce from this traffic count dataset is actually a *subset* of the dataset of all countries, and we can indicate this through a `void:subset` relationship:

    <http://statistics.data.gov.uk/set/country/>
      ...
      void:subset [
        a void:Dataset ;
        a prv:DataItem ;
        rdfs:label "Country data from the DfT traffic count dataset 2001-2008"@en ;
        prv:createdBy [
          a prv:DataCreation ;
          prv:performedAt ... ;
          prv:performedBy ... ;
          prv:usedData ... ;
          prv:usedGuideline ... ;
        ] ;
      ] .

The other kind of subset that we should describe are link sets. Link sets are datasets that contain links between datasets. The country dataset doesn't (currently) contain any links to other datasets, but the count dataset does:

    <http://transport.data.gov.uk/set/traffic-count>
      a void:Dataset ;
      rdfs:label "Traffic Counts"@en ;
      foaf:homepage <http://transport.data.gov.uk/set/traffic-count> ;
      dct:subject <http://dbpedia.org/resource/Traffic> ;
      dct:subject <http://dbpedia.org/resource/Counting> ;
      cc:license [
        a cc:License ;
        rdfs:label "data.gov.uk Licence"@en ;
        foaf:homepage <http://data.hmg.gov.uk/terms-privacy> ;
        cc:permits cc:DerivativeWorks, cc:Distribution, cc:Reproduction ;
        cc:requires cc:Attribution ;
      ] ;
      void:exampleResource <http://transport.data.gov.uk/id/traffic-count-point/13/direction/E/hour/2001-10-08T17:00:00> ;
      void:uriRegexPattern <http://transport.data.gov.uk/id/traffic-count-point/[0-9]+/direction/[NSEW]/hour/[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:00:00> ;
      void:sparqlEndpoint <http://services.data.gov.uk/transport/sparql> ;
      void:vocabulary <http://transport.data.gov.uk/def/traffic/> ;
      void:subset [
        a void:Dataset ;
        rdfs:label "Traffic Counts from the DfT traffic count dataset 2001-2008"@en ;
        prv:createdBy ...
      ] ;
      void:subset [
        a void:Linkset ;
        rdfs:label "Traffic count / count point links"@en ;
        rdfs:comment "Links from a traffic count to the count point at which the count was taken."@en ;
        void:subjectsTarget <http://transport.data.gov.uk/set/traffic-count/> ;
        void:linkPredicate <http://transport.data.gov.uk/def/count> ;
        void:objectsTarget <http://transport.data.gov.uk/set/traffic-count-point/> ;
      ] ;
      void:subset [
        a void:Linkset ;
        rdfs:label "Traffic count / cardinal direction"@en ;
        rdfs:comment "Links from a traffic count to the direction in which the traffic was going."@en ;
        void:subjectsTarget <http://transport.data.gov.uk/set/traffic-count/> ;
        void:linkPredicate <http://transport.data.gov.uk/def/direction> ;
        void:objectsTarget <http://dbpedia.org/void/Dataset> ;
      ] ;
      void:subset [
        a void:Linkset ;
        rdfs:label "Traffic count / hour"@en ;
        rdfs:comment "Links from a traffic count to the hour when the traffic was being monitored."@en ;
        void:subjectsTarget <http://transport.data.gov.uk/set/traffic-count/> ;
        void:linkPredicate <http://transport.data.gov.uk/def/direction> ;
        void:objectsTarget [
          a void:Dataset ;
          rdfs:label "URIs for places and times" ;
          foaf:homepage "http://placetime.com/" ;
        ] ;
      ] .

`scovo:Dataset`s are often subsets of `void:Datasets`. In the case of the traffic count data, the observations described by the `scovo:Dataset` above are a subset of the `void:Dataset` that is the set of *all* such observations (including ones from other years).

## Derivable Data ##

The discussion about `rdfs:label` above touched on another set of information that should be included within the RDF data we produce: data that is automatically derivable from the data we provide. There are three main reasons for including derivable data within what we publish:

  1. Given the current adoption of RDF-aware technologies, the consumers of our data are pretty unlikely to be able to (or to want to) use schemas, ontologies or rule sets to help them to reason over the data and draw conclusions. The consumers of this data *might* include semantic search engines and people scraping the data into their own triplestores, but they're far more likely to be developers who really don't care about RDF at all. It would be a shame to publish the data and then have no one use it.
  
  2. Computing derivable data once saves overall effort. We calculate it once, centrally, and it means that the people using the data don't have to spend processing time doing it themselves. (There's a classic time/space trade-off here, of course; the down side of including data that isn't strictly necessary is that the documents will end up larger.)
  
  3. If we provide information that people are likely to need within the document that they get when they request a given resource, they're less likely to need to resort to (harder to construct and more intensive to process) SPARQL queries to get what they need.

The overriding principle that we can use to help us decide what to include is to consider what we would like to see if we visited a page about the particular thing.

How we manage to provide the derived data depends on how we publish the data. I'm not talking here about how to do the publishing, but rather about what the consumers of the data should expect to see eventually. So, for example, if we publish the data as static files then we're going to have to include all this data in those files. If we generate the RDF dynamically, we just have to make sure that the generated RDF includes the derived data; we might be able to set up rules in a triplestore, or a transformation of the data that it naturally produces, to include the derivable data.

### Superclasses and Super-properties ###

One set of derived data is that inferred from the superclasses and super-properties that are defined with the RDF vocabularies we use in our data. Basically, if a resource has a type that is a subclass of another type, then the resource should have that superclass as a type as well. Similarly, if a triple includes a property that has a super-property, then there ought also to be a triple that links the subject and object of the original triple with the super-property as well.

To understand when it's important to include this kind of derived data, we need to be aware of the kind of applications that will use the data. Some applications will be targeting just this dataset about traffic counts, and will be written to use whatever properties and classes that we've made available. Other applications will be targeted at specific vocabularies at a more general-purpose level. There might be applications that can be used to visualise SKOS hierarchies as a tree, for example, or applications that can plot any `geo:lat`/`geo:long` coordinates on a map, or any OWL-Time intervals and instants on a timeline. Still other applications, such as viewers like Tabulator, will be used with any old RDF. We need to provide enough information to make the data easily usable by these more generic applications.

As an example, in the last instalment we introduced classes for `traffic:VehicleType` and `traffic:RoadCategory` which were subclasses of `skos:Concept`. If we want generic SKOS visualisers to be able to display the vehicle type and road category concept schemes, we should try to make it easy for them to work out which things are concepts, by indicating that they are concepts as well. Bearing in mind what I've said above about labels, that means that the original RDF:

    <motorway> a traffic:RoadCategory ;
      skos:prefLabel "Motorway"@en ;
      skos:broader <major> ;
      skos:scopeNote "Major roads often used for long distance travel. They are usually three or more lanes in each direction and generally have the maximum speed limit of 70mph."@en ;
      skos:inScheme <> .

should include a reference to `skos:Concept` and a `rdfs:label`:

    <motorway> a traffic:RoadCategory ;
      a skos:Concept ;
      rdfs:label "Motorway"@en ;
      skos:prefLabel "Motorway"@en ;
      skos:broader <major> ;
      skos:scopeNote "Major roads often used for long distance travel. They are usually three or more lanes in each direction and generally have the maximum speed limit of 70mph."@en ;
      skos:inScheme <> .

Note that I haven't included the results of *all* the reasoning that we could anticipate. The property `skos:scopeNote` is a sub-property of `skos:note`, for example, but I haven't included a `skos:note` explicitly because any SKOS-aware processor should have that kind of knowledge built in. The rule of thumb is that **if the result of the reasoning involves a resource from another vocabulary, then we should include it**.

### Derivable Values ###

There are other kinds of derivable data in this data set. In particular, there are eastings and northings, but not latitudes and longitudes. When there's useful derivable data, especially when it's not trivial to derive, it makes sense to make that available explicitly, otherwise everyone else will have to go through the effort of deriving it themselves.

We've already done this with the information about the hours of the traffic counts, by pulling out the year and hour of the count rather than having them tucked away within a `xs:dateTime` literal. The same should be true of the eastings and northings. For small numbers of values, you can use the [Ordnance Survey's online converter](http://gps.ordnancesurvey.co.uk/convert.asp); for larger numbers of values you can download the (Windows only and very dated) software or try one of the various converters you can find with a [Google search](http://www.google.com/search?q=easting+northing+latitude+longitude+conversion+UK).

Latitudes and longitudes for points should, of course, be expressed using the `geo:lat` and `geo:long` properties from the [http://www.w3.org/2003/01/geo/wgs84_pos#](http://www.w3.org/2003/01/geo/) vocabulary.

### Inverses ###

Statements in RDF link two things. For example, you can view the statement:

    <http://transport.data.gov.uk/id/traffic-count-point/13>
      traffic:road <http://transport.data.gov.uk/id/road/B3178> .

as saying that traffic count point 13 is on the B3178 *and* that the B3178 has a count point on it that is traffic count point 13.

So it's always possible, when creating a query about or a representation of the road to include the 'backward links' -- the statements in which the road features as an *object* as well as those in which it features as a *subject*. This has caused some people to argue that [relationships should only be defined in one direction](http://dowhatimean.net/2006/06/an-rdf-design-pattern-inverse-property-labels).

Personally, I don't agree, for two reasons.

  1. Although it's *possible* to create queries and representations that include backward links, it often doesn't happen like that. It's different with different triplestores, but result of a the `DESCRIBE` SPARQL query commonly only includes triples in which the thing being described in the subject, not the object. Also, when constructing queries, it seem more natural to always "travel forward" through the graph. For example:
    
        SELECT ?count
        WHERE {
          ?point
            area:localAuthority <http://statistics.data.gov.uk/id/local-authority/43UC> ;
            traffic:count ?count .
        }
    
    rather than:
    
        SELECT ?count
        WHERE {
          ?point
            area:localAuthority <http://statistics.data.gov.uk/id/local-authority/43UC> .
          ?count
            traffic:countPoint ?point .
        }
    
    So although it introduces redundancy, I think that including inverse relationships in RDF aids usability and navigability.

  2. Sometimes both directions of a relationship contain meaningful information. For example, it's not enough to include a `gen:mother` relationship from a person to their mother because the implied reverse relationship is simply that the person is a child of their mother -- you need to include a `gen:son` or `gen:daughter` relationship as well to tell which type of child.

So in this dataset, I'm going to include inverse relationships where appropriate:

  * from countries to regions
  * from regions to local authority districts
  * from roads to count points
  * from count points to counts
  * from counts to observations

### Shortcuts ###

Another thing that can aid the navigability of a set of RDF data is to provide "shortcuts". For example, at the moment we have links that say which country a region belongs to and which region a local authority district belongs to, but we don't have a link that says which country a local authority district belongs to. These kind of links can make it easier to navigate through (and to query) a dataset, so they can be worth adding so long as they don't clutter up the data too much.

Just think of what you'd like to know about a particular *thing* when you visit its page. If you're looking at transport in a local authority district, it would be useful to know what region and country it belongs to and about what roads and traffic count points it contains. But it would be too much to have a list of all the counts and observations that have been taken on those count points.

For this dataset, I'm going to add shortcuts from:

  * countries to local authority districts (and vice versa)
  * count points to regions and countries
  * roads to local authority districts (and vice versa)
  * roads to regions and countries
  * roads to road categories and road names
  * roads to counts (and vice versa)
  * observations to count points, roads, directions and count hours

These are all judgement calls -- there are no hard and fast rules -- and as you can see I'm not adding inverses everywhere here because to do so would lead to unnecessarily large sets of RDF in some cases.

---

That's the end of this instalment. I had been intending to make this the final one, but there are a couple of things still left to talk about: the publication of RDF, and the supplementary documents that we need to provide (including RDF about those supplementary documents). I've also had a request to talk about OWL ontologies, so I'll probably do that, and there are things to say about how to manage things changing over time. So this may end up being an eight-part series!

To keep us up to date, with all the extra derived information added, the RDF looks as follows:

    @prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
    @prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
    @prefix xsd: <http://www.w3.org/2001/XMLSchema#"> .
    @prefix owl: <http://www.w3.org/2002/07/owl#> .
    @prefix skos: <http://www.w3.org/2004/02/skos/core#> .
    @prefix time: <http://www.w3.org/2006/time> .
    @prefix scovo: <http://purl.org/NET/scovo#> .
    @prefix area: <http://statistics.data.gov.uk/def/administrative-geography/> .
    @prefix admingeo: <http://data.ordnancesurvey.co.uk/ontology/admingeo/> .
    @prefix space: <http://data.ordnancesurvey.co.uk/ontology/spatialrelations/> .
    @prefix traffic: <http://transport.data.gov.uk/def/traffic/> .
    
    <http://statistics.data.gov.uk/id/country?name=England>
      a area:Country ;
      rdfs:label "England"@en ;
      area:region <http://statistics.data.gov.uk/id/government-office-region/K> ;
      area:district <http://statistics.data.gov.uk/id/local-authority-district/18> .
    
    <http://statistics.data.gov.uk/id/government-office-region/K>
      a admingeo:GovernmentOfficeRegion ;
      rdfs:label "South West"@en ;
      skos:notation "K"^^area:StandardCode ;
      area:country <http://statistics.data.gov.uk/id/country?name=England> ;
      area:district <http://statistics.data.gov.uk/id/local-authority-district/18> .
    
    <http://statistics.data.gov.uk/id/local-authority-district/18>
      a area:LocalAuthorityDistrict ;
      rdfs:label "Devon"@en ;
      skos:notation "18"^^area:StandardCode ;
      skos:notation "1115"^^traffic:LAcode ;
      area:localAuthority <http://statistics.data.gov.uk/id/local-authority/18> ;
      area:country <http://statistics.data.gov.uk/id/country?name=England> ;
      area:region <http://statistics.data.gov.uk/id/government-office-region/K> ;
      traffic:countPoint <http://transport.data.gov.uk/id/traffic-count-point/13> ;
      traffic:road <http://transport.data.gov.uk/id/road/B3178> .
    
    <http://transport.data.gov.uk/id/local-authority-district/1115>
      owl:sameAs <http://statistics.data.gov.uk/id/local-authority-district/18> .
    
    <http://statistics.data.gov.uk/id/local-authority/18>
      a area:LocalAuthority ;
      rdfs:label "Devon County Council"@en ;
      skos:notation "18"^^area:StandardCode ;
      skos:notation "1115"^^traffic:LAcode ;
      area:coverage <http://statistics.data.gov.uk/id/local-authority-district/18> .
    
    <http://transport.data.gov.uk/id/local-authority/1116>
      owl:sameAs <http://statistics.data.gov.uk/id/local-authority/18> .
    
    <http://transport.data.gov.uk/id/road/B3178>
      a traffic:Road ;
      rdfs:label "B3178" ;
      rdfs:label "Salterton Road"@en ;
      skos:prefLabel "B3178" ;
      skos:altLabel "Salterton Road"@en ;
      skos:notation "B3178"^^traffic:RoadNumber ;
      area:country <http://statistics.data.gov.uk/id/country?name=England> ;
      area:region <http://statistics.data.gov.uk/id/government-office-region/K> ;
      area:localAuthority <http://statistics.data.gov.uk/id/local-authority/18> ;
      area:district <http://statistics.data.gov.uk/id/local-authority-district/18> ;
      traffic:roadCategory 
        <http://transport.data.gov.uk/def/road-category/b> ,
        <http://transport.data.gov.uk/def/road-category/urban> ;
      traffic:count <http://transport.data.gov.uk/id/traffic-count-point/13/direction/E/hour/2001-10-08T17:00:00> .
    
    <http://transport.data.gov.uk/id/traffic-count-point/13>
      a traffic:CountPoint ;
      rdfs:label "Salterton Road, EAST OF DINAN WAY, EXMOUTH"@en ;
      rdfs:comment "Salterton Road, EAST OF DINAN WAY, EXMOUTH"@en ;
      skos:notation "13"^^traffic:CountPointNumber ;
      traffic:road <http://transport.data.gov.uk/id/road/B3178> ;
      traffic:roadName "Salterton Road"@en ;
      traffic:roadCategory 
        <http://transport.data.gov.uk/def/road-category/b> ,
        <http://transport.data.gov.uk/def/road-category/urban> ;
      space:easting 302600 ;
      space:northing 81984 ;
      geo:lat 50.6294 ;
      geo:long -3.3784 ;
      area:country <http://statistics.data.gov.uk/id/country?name=England> ;
      area:region <http://statistics.data.gov.uk/id/government-office-region/K> ;
      area:localAuthority <http://statistics.data.gov.uk/id/local-authority/18> ;
      area:district <http://statistics.data.gov.uk/id/local-authority-district/18> ;
      traffic:count <http://transport.data.gov.uk/id/traffic-count-point/13/direction/E/hour/2001-10-08T17:00:00> .
    
    <http://transport.data.gov.uk/id/traffic-count-point/13/direction/E/hour/2001-10-08T17:00:00>
      a traffic:Count ;
      rdfs:label "8 Oct 2001 17:00-18:00 - East - Salterton Road, EAST OF DINAN WAY, EXMOUTH"@en ;
      traffic:countPoint <http://transport.data.gov.uk/id/traffic-count-point/13> ;
      traffic:road <http://transport.data.gov.uk/id/road/B3178> ;
      traffic:direction <http://dbpedia.org/resource/East> ;
      traffic:countHour <http://placetime.com/interval/gregorian/2001-10-08T17:00:00Z/PT1H> ;
      traffic:observation <http://transport.data.gov.uk/id/traffic-count-point/13/direction/E/hour/2001-10-08T17:00:00/type/bicycle> .
    
    <http://dbpedia.org/resource/East>
      rdfs:label "East"@en .
    
    <http://placetime.com/interval/gregorian/2001-10-08T17:00:00Z/PT1H>
      a traffic:CountHour ;
      rdfs:label "8 Oct 2001, 17:00-18:00"@en ;
      time:hasBeginning <http://placetime.com/instant/gregorian/2001-10-08T17:00:00Z> ;
      time:hasEnd <http://placetime.com/instant/gregorian/2001-10-08T18:00:00Z> ;
      time:hasDurationDescription _:OneHour ;
      time:intervalDuring <http://dbpedia.org/resource/2001> .
    
    _:OneHour a time:DurationDescription ;
      rdfs:label "one hour"@en ;
      time:years 0 ;
      time:months 0 ;
      time:days 0 ;
      time:hours 1 ;
      time:minutes 0 ;
      time:seconds 0 .
    
    <http://placetime.com/instant/gregorian/2001-10-08T17:00:00Z>
      a time:Instant ;
      rdfs:label "8 Oct 2001, 17:00"@en ;
      time:inXSDDateTime "2001-10-08T17:00:00Z"^^xsd:dateTime ;
      time:inDateTime [
        a time:DateTimeDescription ;
        time:unitType time:unitHour ;
        time:year "2001"^^xsd:gYear ;
        time:month "--10"^^xsd:gMonth ;
        time:day "---08"^^xsd:gDay ;
        time:hour 17 ;
      ] .
    
    <http://placetime.com/instant/gregorian/2001-10-08T18:00:00Z>
      a time:Instant ;
      rdfs:label "8 Oct 2001, 18:00"@en ;
      time:inXSDDateTime "2001-10-08T18:00:00Z"^^xsd:dateTime ;
      time:inDateTime [
        a time:DateTimeDescription ;
        time:unitType time:unitHour ;
        time:year "2001"^^xsd:gYear ;
        time:month "--10"^^xsd:gMonth ;
        time:day "---08"^^xsd:gDay ;
        time:hour 18 ;
      ] .
    
    <http://dbpedia.org/resource/2001>
      a time:Interval ;
      rdfs:label "2001" ;
      rdf:value "2001"^^xsd:gYear ;
      time:intervalEquals <http://placetime.com/interval/gregorian/2001-01-01T00:00:00Z/P1Y> .
    
    <http://transport.data.gov.uk/id/traffic-count-point/13/direction/E/hour/2001-10-08T17:00:00/type/bicycle>
      a scovo:Item ;
      rdfs:label "8 Oct 2001 17:00-18:00 - East - Salterton Road, EAST OF DINAN WAY, EXMOUTH"@en ;
      traffic:count <http://transport.data.gov.uk/id/traffic-count-point/13/direction/E/hour/2001-10-08T17:00:00> ;
      traffic:countPoint <http://transport.data.gov.uk/id/traffic-count-point/13> ;
      traffic:direction <http://dbpedia.org/resource/East> ;
      traffic:countHour <http://placetime.com/interval/gregorian/2001-10-08T17:00:00Z/PT1H> ;
      traffic:vehicleType <http://transport.data.gov.uk/def/vehicle/bicycle> ;
      rdf:value 2 .
