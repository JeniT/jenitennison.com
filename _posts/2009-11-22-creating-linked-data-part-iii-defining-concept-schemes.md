---
layout: drupal-post
excerpt_separator: "<!--break-->"
title: ! 'Creating Linked Data - Part III: Defining Concept Schemes'
created: 1258923881
tags:
- rdf
- linked data
- skos
---
This is the third instalment in a series that I'm writing about turning data into linked data. I'm using traffic count data as the example, since that's a dataset that I'm currently working on. In the last two instalments, I talked about [analysing and modelling the data](http://www.jenitennison.com/blog/node/135) and about [designing URIs](http://www.jenitennison.com/blog/node/136) for the *things* in that model.

Within the model, there are three sets of things that are **concepts**:

  * road categories
  * vehicle types
  * cardinal directions

As I discussed last time, cardinal directions have URIs defined within DBPedia which are good enough for our purposes. The categorisation of roads and vehicles, on the other hand, is something specific to UK transport data, so they are up to us to define.

There's a really useful RDF vocabulary called [SKOS](http://www.w3.org/TR/skos-primer/) which is designed precisely for defining the kind of concept schemes that we want to use here. SKOS provides classes for concepts, concept schemes and collections (groupings of concepts within a scheme), and properties for linking them and providing labels, codes, definitions and so forth. Many of the SKOS properties can be used outside concept schemes -- for example `skos:prefLabel` can be used anywhere you want to indicate the preferred label for a thing -- so it's good to get to know them.

## Vehicle Types ##

Before we dive into RDF, let's take some time to understand the classification that we need to model. We're modelling vehicle types because counts are made of each different type of vehicle passing a traffic count point over a particular hour. Within the CSV data, the relevant column headings are:

  * `Pedal cycles`
  * `Two wheeled motor vehicles`
  * `Cars and taxis`
  * `Buses and coaches`
  * `Light vans`
  * `HGVr2`
  * `HGVr3`
  * `HGVr4+`
  * `HGVa3/4`
  * `HGVa5`
  * `HGVa6`
  * `All HGV`
  * `All motor vehicles`

These classifications are detailed in the [Department for Transport documentation of the dataset](http://www.dft.gov.uk/matrix/forms/definitions.aspx). It's clear that it's not a flat classification, but can be arranged into a hierarchy as follows:

    +- Pedal cycles
    +- All motor vehicles
       +- Two wheeled motor vehicles
       +- Cars and taxis
       +- Buses and coaches
       +- Light vans
       +- All HGV
          +- Rigid HGV
          |  +- HGVr2
          |  +- HGVr3
          |  +- HGVr4+
          +- Articulated HGV
             +- HGVa3/4
             +- HGVa5
             +- HGVa6

So all we have to do is define that in SKOS. We've already decided that the URIs will look like:

    http://transport.data.gov.uk/def/vehicle-category/{type}

so for URI-hackability reasons we'll call the concept scheme:

    http://transport.data.gov.uk/def/vehicle-category/

It's probably easiest to just show what the concept scheme looks like. This is in [Turtle](http://www.w3.org/TeamSubmission/turtle/).

    @prefix skos: <http://www.w3.org/2004/02/skos/core#> .
    @base <http://transport.data.gov.uk/def/vehicle-category/> .
    
    <> a skos:ConceptScheme ;
      skos:prefLabel "Vehicle Types"@en ;
      skos:hasTopConcept <bicycle> ;
      skos:hasTopConcept <motor-vehicle> .
    ...
    <motor-vehicle> a skos:Concept ;
      skos:prefLabel "Motor Vehicle"@en ;
      skos:topConceptOf <> ;
      skos:narrower <motorbike> ;
      skos:narrower <car> ;
      skos:narrower <bus> ;
      skos:narrower <van> ;
      skos:narrower <HGV> .
    ...
    <HGV> a skos:Concept ;
      skos:prefLabel "Heavy Goods Vehicle"@en ;
      skos:altLabel "HGV"@en ;
      skos:definition "Goods vehicles over 3,500 kgs gross vehicle weight."@en ;
      skos:scopeNote "Includes tractors (without trailers), road rollers, box vans and similar large vans. A two axle motor tractive unit without trailer is also included."@en ;
      skos:broader <motor-vehicle> ;
      skos:narrower <HGVr> ;
      skos:narrower <HGVa> ;
      skos:inScheme <> .
    ...

The properties shown here are:

  * `skos:prefLabel` - the preferred label for something; there can only be one in any given language
  * `skos:altLabel` - an alternative label for the thing; there can be any number
  * `skos:definition` - provides a definition of the term
  * `skos:scopeNote` - provides information about the scope of the term (eg what's included or excluded)
  * `skos:broader`/`skos:narrower` - link together concepts into a hierarchy
  * `skos:hasTopConcept`/`skos:topConceptOf` - links together the concept schemes and the concepts at the top of the concept hierarchy defined within the scheme
  * `skos:inScheme` - points from a concept the concept scheme it's defined in; it's necessary to use either this or `skos:topConceptOf` on every `skos:Concept` otherwise it's not clear which concept scheme they belong to

Note that in the RDF I've assigned every string a language (English). That's good practice when values are textual; a Welsh translation could be provided for each one as well, for example.

## Road Categories ##

Road categories are also described within the documentation for this dataset. The hierarchy is shown in the documentation as:

    +- Major Roads
    |  +- Motorways
    |  |  +- Trunk
    |  |  +- Principal
    |  +- A Roads
    |     +- Trunk
    |     |  +- Urban
    |     |  +- Rural
    |     +- Principal
    |        +- Urban
    |        +- Rural
    +- Minor Roads
       +- B Roads
       |  +- Urban
       |  +- Rural
       +- C Roads
       |  +- Urban
       |  +- Rural
       +- Unclassified Roads
          +- Urban
          +- Rural

But this is actually the result of three sets of overlapping concepts:

  * roads by classification (major/minor, motorway/A/B/C/unclassified)
  * roads by locale (urban/rural)
  * major roads by maintenance responsibility (trunk/principal)

These kinds of subdivisions of concepts can be managed in SKOS through `skos:Collection`s, which group together concepts without being broader than those concepts. Here's a snippet from the concept scheme that shows how this works.

    @prefix skos: <http://www.w3.org/2004/02/skos/core#> .
    @base <http://transport.data.gov.uk/def/road-category/> .
    
    <> a skos:ConceptScheme ;
      skos:prefLabel "Road Categories"@en ;
      skos:hasTopConcept <major> ;
      skos:hasTopConcept <minor> ;
      skos:hasTopConcept <urban> ;
      skos:hasTopConcept <rural> .
    
    <classification> a skos:Collection ;
      skos:prefLabel "Road by Classification"@en ;
      skos:member <major> ;
      skos:member <minor> .
    
    <maintenance> a skos:Collection ;
      skos:prefLabel "Major Road by Maintenance Responsibility"@en ;
      skos:member <principal> ;
      skos:member <trunk> .
    
    <major> a skos:Concept ;
      skos:prefLabel "Major Road"@en ;
      skos:altLabel "Major"@en ;
      skos:scopeNote "Include motorways and A roads. These roads usually have high traffic flows and are often the main arteries to major destinations."@en ;
      skos:narrower <motorway> ;
      skos:narrower <a> ;
      skos:narrower <principal> ;
      skos:narrower <trunk> ;
      skos:topConceptOf <> .
    
    <motorway> a skos:Concept ;
      skos:prefLabel "Motorway"@en ;
      skos:broader <major> ;
      skos:scopeNote "Major roads often used for long distance travel. They are usually three or more lanes in each direction and generally have the maximum speed limit of 70mph."@en ;
      skos:inScheme <> .
    ...
    <trunk> a skos:Concept ;
      a skos:Concept ;
      skos:prefLabel "Trunk Road"@en ;
      skos:altLabel "Trunk"@en ;
      skos:scopeNote "Most motorways and many of the long distance rural A roads are trunk roads."@en ;
      skos:note "The responsibility for the maintenance of trunk roads lies with the Secretary of State and they are managed by the Highways Agency in England, the National Assembly of Wales in Wales and the Scottish Executive in Scotland (National Through Routes)."@en ;
      skos:broader <major> ;
      skos:inScheme <> .
    ...

In a hierarchy, these multiple overlapping concepts can be shown as:

    +- <Road by Classification>
    |  +- Major Road
    |  |  +- <Major Road by Classification>
    |  |  |  +- Motorway
    |  |  |  +- A Road
    |  |  +- <Major Road by Maintenance Responsibility>
    |  |     +- Principal Road
    |  |     +- Trunk Road
    |  +- Minor Road
    |     +- B Road
    |     +- C Road
    |     +- Unclassified Road
    +- <Road by Locale>
       +- Urban Road
       +- Rural Road

That's our concept schemes done. Next it will be time to turn to defining a vocabulary for the particular *things* that we want to describe from this dataset.
