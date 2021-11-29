---
layout: drupal-post
excerpt_separator: "<!--break-->"
title: Expressing Statistics with RDF
created: 1256335670
tags:
- rdf
- psi
---
_**Update:** If you're interested in expressing statistics in RDF, I'd encourage you to join the [publishing statistical data](http://groups.google.com/group/publishing-statistical-data) group and take a look at the documentation for 'SDMX-RDF' described there._

One of the things that we've been discussing over on the [UK Government Data Developers mailing list](http://groups.google.com/group/uk-government-data-developers) is how best to represent the vast quantities of statistical data that the government produces, in RDF. This is what we've come up with.

<!--break-->

  1. We'll use [SCOVO](http://sw.joanneum.at/scovo/schema.html) as our main vocabulary.

  1. Dimensions (the things a statistic are about) should be instances of specialised classes such as 'Hospital' or 'School'; these will often be [SKOS](http://www.w3.org/TR/skos-primer/) concepts. We will try to reuse these as much as possible across datasets (see below).

  1. We will create subproperties of `scv:dimension` that have appropriate names and different subclasses of `scv:Dimension`s as ranges. We will try to reuse these as much as possible across datasets (see below).

  1. The `scv:Item`s we use (representing individual statistics) should not be blank nodes (because giving them URIs allows us to attach other information to them); they will each have a `scv:dataset` property that points to the `scv:Dataset` they belong to (which will probably also be a `void:Dataset`).

  1. Every `scv:Item` will also be the object of at least one triple that involves one of its dimensions; this will usually be the real-world thing that the statistic is associated with (eg the school or hospital).
  
  1. Most statistics are provided for a particular time period; for these, we will define relationships from [OWL-Time](http://www.w3.org/TR/owl-time/) to [placetime.com](http://www.placetime.com/) resources, but will also use appropriately datatyped literals where possible to make querying easier.

Here's an example of what this looks like:

    @prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
    @prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
    @prefix xsd: <http://www.w3.org/2001/XMLSchema#> .
    @prefix scv: <http://purl.org/NET/scovo#> .
    @prefix skos: <http://www.w3.org/2004/02/skos/core#> .
    @prefix dct: <http://purl.org/dc/terms/> .
    @prefix void: <http://rdfs.org/ns/void#> .
    @prefix time: <http://www.w3.org/2006/time#> .
    @prefix sdmx: <http://proxy.data.gov.uk/sdmx.org/def/sdmx/> .
    @prefix pop: <http://statistics.data.gov.uk/def/population/> .
    @prefix year: <http://statistics.data.gov.uk/def/census-year/> .
    
    # The statistics themselves
    
    <http://statistics.data.gov.uk/id/local-authority-district/00HE>
      rdfs:label "Cornwall" ;
      pop:totalPopulation <http://statistics.data.gov.uk/id/local-authority-district/00HE/population/total/year/2001> ;
      pop:ruralPopulation <http://statistics.data.gov.uk/id/local-authority-district/00HE/population/rural/year/2001> ;
      ... .
      
    <http://statistics.data.gov.uk/id/local-authority-district/00HE/population/total/year/2001>
      a scv:Item ;
      rdf:value "499399"^^xsd:integer ;
      scv:dataset <http://statistics.data.gov.uk/doc/local-authority-district/*/population> ;
      sdmx:refArea <http://statistics.data.gov.uk/id/local-authority-district/00HE> ;
      pop:populationType pop:total ;
      sdmx:timePeriod <http://statistics.data.gov.uk/def/census-year/2001> .
      
    <http://statistics.data.gov.uk/id/local-authority-district/00HE/population/rural/year/2001>
      a scv:Item ;
      rdf:value "127904"^^xsd:integer ;
      scv:dataset <http://statistics.data.gov.uk/doc/local-authority-district/*/population> ;
      sdmx:refArea <http://statistics.data.gov.uk/id/local-authority-district/00HE> ;
      pop:populationType pop:rural ;
      sdmx:timePeriod <http://statistics.data.gov.uk/def/census-year/2001> .
      
    ...
    
    # Datasets
    
    <http://statistics.data.gov.uk/doc/local-authority-district/*/population/*/year/2001>
      a scv:Dataset ;
      a void:Dataset ;
      dct:title "Populations of Local Authority Districts" ;
      ... .
    
    # Common definitions for the dataset
    
    pop:totalPopulation a rdf:Property ;
      rdfs:label "total population" ;
      rdfs:range scv:Item .
    pop:ruralPopulation a rdf:Property ;
      rdfs:label "rural population" ;
      rdfs:range scv:Item .
    ...
    
    pop:populationType rdfs:subPropertyOf scv:dimension ;
      rdfs:label "population type" ;
      rdfs:domain scv:Item ;
      rdfs:range pop:Population .
    
    pop:Population a rdfs:Class ;
      rdfs:subClassOf skos:Concept ;
      rdfs:subClassOf scv:Dimension ;
      rdfs:label "population type" .
    
    pop:populationScheme a skos:ConceptScheme ;
      skos:prefLabel "Population Types" ;
      pop:hasTopConcept pop:total .
    
    pop:total a pop:Population ;
      skos:prefLabel "total population" ;
      skos:topConceptOf pop:populationScheme ;
      skos:narrower pop:rural ;
      ... .
    
    pop:rural a pop:Population ;
      skos:prefLabel "rural population" ;
      skos:inScheme pop:populationScheme ;
      skos:broader pop:total ;
      ... .
    
    year:Year a rdfs:Class ;
      rdfs:subClassOf time:Interval ;
      rdfs:subClassOf scv:Dimension .
    
    <http://statistics.data.gov.uk/def/census-year/2001>
      rdfs:label "mid-2001" ;
      time:intervalDuring <http://www.placetime.com/interval/gregorian/2001-01-01T00:00:00Z/P1Y> .
    
    <http://www.placetime.com/interval/gregorian/2001-01-01T00:00:00Z/P1Y>
      rdfs:label "2001" ;
      rdf:value "2001"^^xsd:gYear .

One source of sub-properties of `scv:dimension` (and subtypes of `scv:Dimension`) is [SDMX](http://sdmx.org/) (Statistical Data and Metadata eXchange). This provides standard ways of indicating things like the area and time that a statistic applies to. I've made an [initial mapping into some RDFS properties](/blog/files/sdmx.ttl) and [SKOS schemes](/blog/files/codelists.ttl) as an indication of the kind of thing that would work here, but expect it to change.

We're currently working on providing identifiers for the areas that statistics are likely to be about (such as local authority districts, MSOAs or wards). They are of the form:

    http://statistics.data.gov.uk/id/{area-type}/{ONS-area-code}

and they tie into the [newly released OS data](http://data.ordnancesurvey.co.uk/). I hope we'll have them available as Linked Data soon.

One issue that hasn't been resolved is how to handle the huge amount of repetition that is inherent in this method of representing statistical data. For example, in the data above, all the `scv:DataItem`s in the `scv:Dataset` `http://statistics.data.gov.uk/doc/local-authority-district/*/population/*/year/2001` are from 2001. Rather than indicating the year of each individual `scv:DataItem`, it would be nice if we could have a property on the dataset that indicated that *all* the items in that dataset had the same value for a particular dimension. If this were called `scv:itemDimension`, for example, then we could do:
    
    <http://statistics.data.gov.uk/doc/local-authority-district/*/population/*/year/2001>
      a scv:Dataset ;
      a void:Dataset ;
      dct:title "Populations of Local Authority Districts" ;
      sdmx:itemTimePeriod <http://statistics.data.gov.uk/def/census-year/2001> ;
      ... .
    
    sdmx:itemTimePeriod rdfs:subPropertyOf scv:itemDimension ;
      rdfs:label "time period of items in the dataset" ;
      rdfs:domain scv:Dataset .

and the individual `scv:Item`s would not have to have any `sdmx:timePeriod` properties explicitly. Perhaps this is something that the people beind SCOVO might consider, or we might create the property ourselves.

As far as I know, this pattern for representing statistics has yet to be used "in anger", but I hope that we'll have some illustrations soon which will help us assess whether it's viable. Any comments and suggestions would, of course, be very welcome!
