---
layout: drupal-post
title: ! 'Creating Linked Data - Part IV: Developing RDF Schemas'
created: 1259231732
tags:
- rdf
- linked data
---
This is the fourth instalment in a series about turning an existing dataset into some linked data. I've previously talked about [analysis and modelling](http://www.jenitennison.com/blog/node/135), [defining URIs](http://www.jenitennison.com/blog/node/136) and [defining concept schemes](http://www.jenitennison.com/blog/node/137). In this instalment, we'll look at developing a schema in which we define the classes, properties and datatypes that we want to use in the RDF that describes the *things* in our dataset.

We'll start by writing out some RDF for our record, using Turtle here for readability, and use unprefixed names to indicate classes, properties and datatypes, just so we can see what we need. Then we'll see how those requirements match up to existing vocabularies and ontologies that we can reuse. Anything that's left over we're going to have to put in our own vocabulary. We'll call this

    http://transport.data.gov.uk/def/traffic/

All the classes, properties and datatypes that we define will eventually use that namespace.

Let's focus on this record; I find it easiest to use an actual example rather than talk in abstract:

    "England","South West","K",1115.00,"18","Devon County Council",
    13,"B3178",,"B Urban","Salterton Road",
    "Salterton Road, EAST OF DINAN WAY, EXMOUTH",302600,81984,
    8/10/2001 00:00:00,"E",17,2,2,400,5,41,0,2,0,0,0,0,2,450

We'll put this into RDF bit by bit.

## Areas ##

First, let's look at the areas and local authorities. The kind of RDF that we want to have looks like:

    <http://statistics.data.gov.uk/id/country?name=England>
      a :Country ;
      :name "England"@en .
    
    <http://statistics.data.gov.uk/id/government-office-region/K>
      a :GovernmentOfficeRegion ;
      :name "South West"@en ;
      :code "K"^^:ONScode ;
      :containedBy <http://statistics.data.gov.uk/id/country?name=England> .
    
    <http://statistics.data.gov.uk/id/local-authority-district/18>
      a :LocalAuthorityDistrict ;
      :code "18"^^:ONScode ;
      :code "1115"^^:DfTLAcode ;
      :localAuthority <http://statistics.data.gov.uk/id/local-authority/18> ;
      :containedBy <http://statistics.data.gov.uk/id/country?name=England> ;
      :containedBy <http://statistics.data.gov.uk/id/government-office-region/K> .
    
    <http://transport.data.gov.uk/id/local-authority-district/1115>
      :sameAs <http://statistics.data.gov.uk/id/local-authority-district/18> .
    
    <http://statistics.data.gov.uk/id/local-authority/18>
      a :LocalAuthority ;
      :name "Devon County Council"@en ;
      :code "18"^^:ONSLAcode ;
      :code "1115"^^:DfTLAcode ;
      :localAuthorityDistrict <http://statistics.data.gov.uk/id/local-authority-district/18> .
    
    <http://transport.data.gov.uk/id/local-authority/1116>
      :sameAs <http://statistics.data.gov.uk/id/local-authority/18> .

To work out what we need to put in our schema, we should first look at what existing vocabularies there are that could help. These areas are already defined elsewhere, so we can just use the same vocabulary for countries, regions, local authority districts and local authorities as is used there. The vocabularies that are useful here are:

  * `http://statistics.data.gov.uk/def/administrative-geography/` which defines classes and properties related to administrative areas and local authorities (as described by the [Office of National Statistics](http://www.statistics.gov.uk/))
  * `http://data.ordnancesurvey.co.uk/ontology/admingeo/` which also defines classes and properties related to administrative areas (as described by the [Ordnance Survey](http://www.ordnancesurvey.co.uk/))
  * `http://data.ordnancesurvey.co.uk/ontology/spatialrelations/`, also developed by John Goodwin at the Ordnance Survey, which defines spatial relationships between areas

There are other commonly used vocabularies that it's helpful to know about:

  * RDFS is designed for representing RDF schemas, but it has a few general-purpose properties that are good to know, namely `rdfs:label` (the label for a thing) and `rdfs:comment` (a comment or description about the thing).
  * SKOS is designed for representing concept schemes, but again it has a few properties that can be used with any set of linked data, in particular `skos:prefLabel` (the preferred label for a thing), `skos:altLabel` (an alternative label for a thing) and `skos:notation` (a code for the thing).
  * OWL is designed for representing ontologies, but it has one very important property that you should know about -- `owl:sameAs` -- which is used to link two things that are the same thing.
  * XML Schema datatypes can be used within RDF, which is useful for things like dates, times, integers and so on.
  * For our purposes here, OWL-Time is going to prove useful, as it has a bunch of properties that are used to represent instants and durations.

If we look through the RDF above, the only thing that *isn't* covered by these vocabularies is the `DfTLAcode` datatype. If we use the `http://transport.data.gov.uk/def/traffic/` namespace, there's not really any need to indicate that this is a transport-related code, so we can just call it `LAcode`. Let's define that datatype:

    <http://transport.data.gov.uk/def/traffic/LAcode>
      a rdfs:Datatype ;
      rdfs:label "Local Authority Code"@en .

That's it. Now here's the Turtle for the areas with the relevant namespaces added, and property names changed where appropriate:

    @prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
    @prefix xsd: <http://www.w3.org/2001/XMLSchema#"> .
    @prefix skos: <http://www.w3.org/2004/02/skos/core#> .
    @prefix owl: <http://www.w3.org/2002/07/owl#> .
    @prefix area: <http://statistics.data.gov.uk/def/administrative-geography/> .
    @prefix space: <http://data.ordnancesurvey.co.uk/ontology/spatialrelations/> .
    @prefix admingeo: <http://data.ordnancesurvey.co.uk/ontology/admingeo/> .
    @prefix traffic: <http://transport.data.gov.uk/def/traffic/> .
    
    <http://statistics.data.gov.uk/id/country?name=England>
      a area:Country ;
      rdfs:label "England"@en .
    
    <http://statistics.data.gov.uk/id/government-office-region/K>
      a admingeo:GovernmentOfficeRegion ;
      rdfs:label "South West"@en ;
      skos:notation "K"^^area:StandardCode ;
      area:country <http://statistics.data.gov.uk/id/country?name=England> .
    
    <http://statistics.data.gov.uk/id/local-authority-district/18>
      a area:LocalAuthorityDistrict ;
      skos:notation "18"^^area:StandardCode ;
      skos:notation "1115"^^traffic:LAcode ;
      area:localAuthority <http://statistics.data.gov.uk/id/local-authority/18> ;
      area:country <http://statistics.data.gov.uk/id/country?name=England> ;
      area:region <http://statistics.data.gov.uk/id/government-office-region/K> .
    
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

## Roads ##

Here's the kind of RDF we want to create for roads:

    <http://transport.data.gov.uk/id/road/B3178>
      a :Road ;
      :code "B3178"^^:RoadNumber .

Obviously, we need a class for roads:

    <http://transport.data.gov.uk/def/traffic/Road>
      a rdfs:Class ;
      rdfs:label "Road"@en .

Wherever there's a code, I like to reuse `skos:notation`. But it's important to define a datatype for the values used with that notation because (as we saw with local authorities above) there may be several different coding schemes that apply to the same Thing, and we need to be able to distinguish between them in case they clash. So:

    <http://transport.data.gov.uk/def/traffic/RoadNumber>
      a rdfs:Datatype ;
      rdfs:label "Road Number"@en .

That's all we have to define for roads; now the RDF can look like:

    @prefix traffic: <http://transport.data.gov.uk/def/traffic/> .
    @prefix skos: <http://www.w3.org/2004/02/skos/core#> .
    
    <http://transport.data.gov.uk/id/road/B3178>
      a traffic:Road ;
      skos:notation "B3178"^^traffic:RoadNumber .

## Count Points ##

On to count points. Here's the sketch of the RDF we want to create:

    <http://transport.data.gov.uk/id/traffic-count-point/13>
      a :TrafficCountPoint ;
      :description "Salterton Road, EAST OF DINAN WAY, EXMOUTH"@en ;
      :code "13"^^:CountPointNumber ;
      :road <http://transport.data.gov.uk/id/road/B3178> ;
      :roadName "Salterton Road"@en ;
      :roadCategory 
        <http://transport.data.gov.uk/def/road-category/b> ,
        <http://transport.data.gov.uk/def/road-category/urban> ;
      :easting 302600 ;
      :northing 81984 ;
      :localAuthority <http://statistics.data.gov.uk/id/local-authority/18> ;
      :localAuthorityDistrict <http://statistics.data.gov.uk/id/local-authority-district/18> .

Of these, the description could be done with `rdfs:comment`. The code can be held by a `skos:notation` (provided we define a datatype for the count point number):

    <http://transport.data.gov.uk/def/traffic/CountPointNumber>
      a rdfs:Datatype ;
      rdfs:label "Traffic Count Point Number"@en .

Properties for easting and northing are actually defined by the OS's spatial relations ontology (although unfortunately neither the ontology nor the property is currently resolvable; the only way you'd know this is through looking at their use in the conversion of the edubase data). Links to local authorities and local authority districts can be done using the ONS-based administrative geography ontology, which again is currently only guessable at by looking at the online data.

That leaves us with a `traffic:CountPoint` class (no point calling it `TrafficCountPoint` if the namespace provides sufficient disambiguation):

    <http://transport.data.gov.uk/def/traffic/CountPoint>
      a rdfs:Class ;
      rdfs:label "Traffic Count Point"@en .

A road property to point to a road:

    <http://transport.data.gov.uk/def/traffic/road>
      a rdf:Property ;
      rdfs:label "road"@en ;
      rdfs:range <http://transport.data.gov.uk/def/traffic/Road> .

Note that properties are by convention named with a lowercase first letter, whereas classes are named with an uppercase first letter. It's a good idea to follow that convention. Note also that I've defined a `rdfs:range` for this property, which means that anything that's the *object* in a RDF statement that involves this property must be a `traffic:Road`.

We need a road name property to give the name of the road at the count point.

    <http://transport.data.gov.uk/def/traffic/road>
      a rdf:Property ;
      rdfs:label "road name"@en ;
      rdfs:range <http://transport.data.gov.uk/def/traffic/Road> .

We also need a road category property to point to the categor(ies) of the road at the count point:

    <http://transport.data.gov.uk/def/traffic/roadCategory>
      a rdf:Property ;
      rdfs:label "road category"@en .

You'll remember that we defined different road categories using SKOS, such that each road category is a `skos:Concept`. But to give a range to the `traffic:roadCategory` property, we need to create a class for all the things that are categories of road. These are all `skos:Concept`s, and we can indicate that through an `rdfs:subClassOf` property:

    <http://transport.data.gov.uk/def/traffic/RoadCategory>
      a rdfs:Class ;
      rdfs:subClassOf skos:Concept ;
      rdfs:label "Road Category"@en .

use this as the range of the `traffic:roadCategory` property:

    <http://transport.data.gov.uk/def/traffic/roadCategory>
      a rdf:Property ;
      rdfs:label "road category"@en ;
      rdfs:range <http://transport.data.gov.uk/def/traffic/RoadCategory> .

and amend the concept scheme we created to include references to this new class, for example:

    <motorway> a traffic:RoadCategory ;
      skos:prefLabel "Motorway"@en ;
      skos:broader <major> ;
      skos:scopeNote "Major roads often used for long distance travel. They are usually three or more lanes in each direction and generally have the maximum speed limit of 70mph."@en ;
      skos:inScheme <> .

So here is the RDF with the relevant properties properly defined:

    @prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
    @prefix skos: <http://www.w3.org/2004/02/skos/core#> .
    @prefix area: <http://statistics.data.gov.uk/def/administrative-geography/> .
    @prefix space: <http://data.ordnancesurvey.co.uk/ontology/spatialrelations/> .
    @prefix traffic: <http://transport.data.gov.uk/def/traffic/> .
    
    <http://transport.data.gov.uk/id/traffic-count-point/13>
      a traffic:CountPoint ;
      rdfs:comment "Salterton Road, EAST OF DINAN WAY, EXMOUTH"@en ;
      skos:notation "13"^^traffic:CountPointNumber ;
      traffic:road <http://transport.data.gov.uk/id/road/B3178> ;
      traffic:roadName "Salterton Road"@en ;
      traffic:roadCategory 
        <http://transport.data.gov.uk/def/road-category/b> ,
        <http://transport.data.gov.uk/def/road-category/urban> ;
      space:easting 302600 ;
      space:northing 81984 ;
      area:localAuthority <http://statistics.data.gov.uk/id/local-authority/18> ;
      area:district <http://statistics.data.gov.uk/id/local-authority-district/18> .

## Traffic Counts ##

On to traffic counts. The un-namespaced RDF should look like:

    <http://transport.data.gov.uk/id/traffic-count-point/13/direction/E/hour/2001-10-08T17:00:00>
      a :TrafficCount ;
      :countPoint <http://transport.data.gov.uk/id/traffic-count-point/13> ;
      :direction <http://dbpedia.org/resource/East> ;
      :hour <http://placetime.com/interval/gregorian/2001-10-08T17:00:00Z/PT1H> .

So for that we need a class for traffic counts:

    <http://transport.data.gov.uk/def/traffic/Count>
      a rdfs:Class ;
      rdfs:label "Traffic Count"@en .

a property that can link to the traffic count to the count point where the count is taken:

    <http://transport.data.gov.uk/def/traffic/countPoint>
      a rdf:Property ;
      rdfs:label "traffic count point"@en ;
      rdfs:range <http://transport.data.gov.uk/def/traffic/CountPoint> .

a property to link to the the direction the traffic is flowing in (we can't put a range on this one because the DBPedia resources we're using don't have a common type):

    <http://transport.data.gov.uk/def/traffic/direction>
      a rdf:Property ;
      rdfs:label "traffic direction"@en .

and finally a property to link to the hour during which the measurement was taken. This last one is a very common thing to need to do, so we'd imagine that there might be an existing property defined somewhere that we could use. [SDMX](http://sdmx.org/), which includes a standard for representing statistical information in XML, defines a `REF_PERIOD` field which would seem to suit our purposes, but we don't yet have a proper mapping of SDMX into RDF (I've had an initial cut, but it needs some input from statisticians).

So for now, we'll use a specific property in our own namespace; we can always indicate that it's a sub-property of a future SDMX property at a later date. I'm going to call it `countHour` and give it a domain of `traffic:Count` to indicate that the property has a pretty specific use for providing the count for an hour. We could just give its range as a generic `time:Interval`, but the kind of hours that are traffic count hours are kinda special intervals: they're obviously an hour long, but are also restricted to start and end on the hour, cover an hour between 7am and 7pm, and don't occur in winter. So it feels like we should have a special kind of interval for that purpose:

    <http://transport.data.gov.uk/def/traffic/countHour>
      a rdf:Property ;
      rdfs:label "hour of count"@en ;
      rdfs:domain <http://transport.data.gov.uk/def/traffic/Count> ;
      rdfs:range <http://transport.data.gov.uk/def/traffic/CountHour> .
    
    <http://transport.data.gov.uk/def/traffic/CountHour>
      a rdfs:Class ;
      rdfs:subClassOf time:Interval ;
      rdfs:label "Count Hour"@en .

All those properties were in the traffic namespace, so here's the RDF with it added:

    @prefix traffic: <http://transport.data.gov.uk/def/traffic/> .
    
    <http://transport.data.gov.uk/id/traffic-count-point/13/direction/E/hour/2001-10-08T17:00:00>
      a traffic:Count ;
      traffic:countPoint <http://transport.data.gov.uk/id/traffic-count-point/13> ;
      traffic:direction <http://dbpedia.org/resource/East> ;
      traffic:countHour <http://placetime.com/interval/gregorian/2001-10-08T17:00:00Z/PT1H> .

## Cardinal Directions ##

As I discussed in the last instalment, we're not actually going to mint URIs for cardinal directions, but that doesn't mean we can't make statements about them in the RDF we generate. As I'll discuss in more depth in the next instalment, it's always good to provide a label at the very least:

    <http://dbpedia.org/resource/East>
      rdfs:label "East"@en .

## Intervals and Instants ##

Let's look now at the RDF we want to generate about the hour during which the count was taken. As I've said above, these hours are a special kind of interval, and we've already created a class for them. I also discussed earlier that the things about this interval that are really useful for the purposes of querying are the year during which the count was taken and the hour at which it was taken, so we should pull out at least those pieces of information. Time-based data can be represented in RDF using the [OWL-Time ontology](http://www.w3.org/2006/time).

Unfortunately, expressing time very specifically gets. This is what the statements we want to make look like using OWL-Time:

    @prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
    @prefix time: <http://www.w3.org/2006/time> .
    
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
    
    <http://placetime.com/interval/gregorian/2001-10-08T18:00:00Z>
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

## Observations ##

Finally we're on to the observations themselves. The un-namespaced RDF looks like:
        
    <http://transport.data.gov.uk/id/traffic-count-point/13/direction/E/hour/2001-10-08T17:00:00/type/bicycle>
      a :Observation ;
      :count <http://transport.data.gov.uk/id/traffic-count-point/13/direction/E/hour/2001-10-08T17:00:00> ;
      :vehicleType <http://transport.data.gov.uk/def/vehicle/bicycle> ;
      :value 2 .

The [SCOVO](http://purl.org/NET/scovo) vocabulary exists to represent statistical information like this. In SCOVO, observations are called `scovo:Item`s, the value of the statistical measure itself (the count in this case) should be held in the `rdf:value` property, and any other properties should be subtypes of `scovo:dimension`, which has a domain of `scovo:Dimension`.

To fit in with SCOVO, then, we need to have the pointer to the count that this observation belongs to as a property that is a sub-property of `scovo:dimension`:

    <http://transport.data.gov.uk/def/traffic/count>
      a rdf:Property ;
      rdfs:subPropertyOf scovo:dimension ;
      rdfs:label "count"@en ;
      rdfs:range <http://transport.data.gov.uk/def/traffic/Count> .

We might be tempted to indicate that the type of thing pointed to by the `traffic:count` property is a subclass of `scovo:Dimension`, but this is unnecessary and probably untrue: there might exist some traffic counts that *aren't* dimensions, and the ones that are will be linked to by the `traffic:count` property can be inferred to be dimensions.

Similarly, the property that provides the pointer to the vehicle type should be a sub-property of `scovo:dimension` and we need a class for those various vehicle types in order to restrict the range of that property:

    <http://transport.data.gov.uk/def/vehicleType>
      a rdf:Property ;
      rdfs:subPropertyOf scovo:dimension ;
      rdfs:label "vehicle type"@en ;
      rdfs:range <http://transport.data.gov.uk/def/VehicleType> .
    
    <http://transport.data.gov.uk/def/VehicleType>
      a rdfs:Class ;
      rdfs:subClassOf skos:Concept ;
      rdfs:label "Vehicle Type"@en .

Of course all the concepts that we created for the vehicle types need to be designated as instances of this new `traffic:VehicleType` class:

    <bicycle> a traffic:VehicleType ;
      ... .

So, the RDF with the proper namespaces is:

    @prefix scovo: <http://purl.org/NET/scovo#> .
    @prefix traffic: <http://transport.data.gov.uk/def/traffic/> .
    
    <http://transport.data.gov.uk/id/traffic-count-point/13/direction/E/hour/2001-10-08T17:00:00/type/bicycle>
      a scovo:Item ;
      traffic:count <http://transport.data.gov.uk/id/traffic-count-point/13/direction/E/hour/2001-10-08T17:00:00> ;
      traffic:vehicleType <http://transport.data.gov.uk/def/vehicle/bicycle> ;
      rdf:value 2 .

---

That concludes our initial walkthrough of the data to create a vocabulary. I've duplicated the schema and the example data below so that it's all in one place. But it's not quite done. In the next instalment, I'll look at adding some finishing touches that make the RDF easier to use.

---

## Schema ##

This is the full schema. It contains just six classes, seven properties and three datatypes at the moment, so it's pretty small as vocabularies go. We've been able to reuse a lot of classes, properties and datatypes that have already been defined elsewhere in the RDF itself, so this vocabulary is pretty focused on just what we need to describe traffic counts.

    @prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
    @prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
    @prefix skos: <http://www.w3.org/2004/02/skos/core#> .
    @prefix scovo: <http://purl.org/NET/scovo#> .
    @prefix time: <http://www.w3.org/2006/time> .
    
    # Classes #
    
    <http://transport.data.gov.uk/def/traffic/Road>
      a rdfs:Class ;
      rdfs:label "Road"@en .
    
    <http://transport.data.gov.uk/def/traffic/CountPoint>
      a rdfs:Class ;
      rdfs:label "Traffic Count Point"@en .
    
    <http://transport.data.gov.uk/def/traffic/Count>
      a rdfs:Class ;
      rdfs:label "Traffic Count"@en .
    
    <http://transport.data.gov.uk/def/traffic/RoadCategory>
      a rdfs:Class ;
      rdfs:subClassOf skos:Concept ;
      rdfs:label "Road Category"@en .    
    
    <http://transport.data.gov.uk/def/traffic/CountHour>
      a rdfs:Class ;
      rdfs:subClassOf time:Interval ;
      rdfs:label "Count Hour"@en .
    
    <http://transport.data.gov.uk/def/VehicleType>
      a rdfs:Class ;
      rdfs:subClassOf skos:Concept ;
      rdfs:label "Vehicle Type"@en .
    
    # Properties #
    
    <http://transport.data.gov.uk/def/traffic/road>
      a rdf:Property ;
      rdfs:label "road name"@en ;
      rdfs:range <http://transport.data.gov.uk/def/traffic/Road> .
    
    <http://transport.data.gov.uk/def/traffic/countPoint>
      a rdf:Property ;
      rdfs:label "traffic count point"@en ;
      rdfs:range <http://transport.data.gov.uk/def/traffic/CountPoint> .
    
    <http://transport.data.gov.uk/def/traffic/count>
      a rdf:Property ;
      rdfs:subPropertyOf scovo:dimension ;
      rdfs:label "count"@en ;
      rdfs:range <http://transport.data.gov.uk/def/traffic/Count> .
    
    <http://transport.data.gov.uk/def/traffic/roadCategory>
      a rdf:Property ;
      rdfs:label "road category"@en ;
      rdfs:range <http://transport.data.gov.uk/def/traffic/RoadCategory> .
    
    <http://transport.data.gov.uk/def/traffic/direction>
      a rdf:Property ;
      rdfs:label "traffic direction"@en .
    
    <http://transport.data.gov.uk/def/traffic/countHour>
      a rdf:Property ;
      rdfs:label "hour of count"@en ;
      rdfs:domain <http://transport.data.gov.uk/def/traffic/Count> ;
      rdfs:range <http://transport.data.gov.uk/def/traffic/CountHour> .
    
    <http://transport.data.gov.uk/def/vehicleType>
      a rdf:Property ;
      rdfs:subPropertyOf scovo:dimension ;
      rdfs:label "vehicle type"@en ;
      rdfs:range <http://transport.data.gov.uk/def/VehicleType> .
    
    # Datatypes #
    
    <http://transport.data.gov.uk/def/traffic/LAcode>
      a rdfs:Datatype ;
      rdfs:label "Local Authority Code"@en .
    
    <http://transport.data.gov.uk/def/traffic/RoadNumber>
      a rdfs:Datatype ;
      rdfs:label "Road Number"@en .
    
    <http://transport.data.gov.uk/def/traffic/CountPointNumber>
      a rdfs:Datatype ;
      rdfs:label "Traffic Count Point Number"@en .

---

## RDF Data ##

Here's a sample set of data. It looks like rather a lot to simply describe the number of bicycles at a particular point on a road (and it doesn't even include the SKOS concept schemes that we did last time), but (a) it all provides valuable context for that measurement and (b) most of it will be reused by a lot of other measurements.

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
      rdfs:label "England"@en .
      
    <http://statistics.data.gov.uk/id/government-office-region/K>
      a admingeo:GovernmentOfficeRegion ;
      rdfs:label "South West"@en ;
      skos:notation "K"^^area:StandardCode ;
      area:country <http://statistics.data.gov.uk/id/country?name=England> .
      
    <http://statistics.data.gov.uk/id/local-authority-district/18>
      a area:LocalAuthorityDistrict ;
      skos:notation "18"^^area:StandardCode ;
      skos:notation "1115"^^traffic:LAcode ;
      area:localAuthority <http://statistics.data.gov.uk/id/local-authority/18> ;
      area:country <http://statistics.data.gov.uk/id/country?name=England> ;
      area:region <http://statistics.data.gov.uk/id/government-office-region/K> .
      
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
      skos:notation "B3178"^^traffic:RoadNumber .
      
    <http://transport.data.gov.uk/id/traffic-count-point/13>
      a traffic:CountPoint ;
      rdfs:comment "Salterton Road, EAST OF DINAN WAY, EXMOUTH"@en ;
      skos:notation "13"^^traffic:CountPointNumber ;
      traffic:road <http://transport.data.gov.uk/id/road/B3178> ;
      traffic:roadName "Salterton Road"@en ;
      traffic:roadCategory 
        <http://transport.data.gov.uk/def/road-category/b> ,
        <http://transport.data.gov.uk/def/road-category/urban> ;
      space:easting 302600 ;
      space:northing 81984 ;
      area:localAuthority <http://statistics.data.gov.uk/id/local-authority/18> ;
      area:district <http://statistics.data.gov.uk/id/local-authority-district/18> .
    
    <http://transport.data.gov.uk/id/traffic-count-point/13/direction/E/hour/2001-10-08T17:00:00>
      a traffic:Count ;
      traffic:countPoint <http://transport.data.gov.uk/id/traffic-count-point/13> ;
      traffic:direction <http://dbpedia.org/resource/East> ;
      traffic:countHour <http://placetime.com/interval/gregorian/2001-10-08T17:00:00Z/PT1H> .
    
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
      traffic:count <http://transport.data.gov.uk/id/traffic-count-point/13/direction/E/hour/2001-10-08T17:00:00> ;
      traffic:vehicleType <http://transport.data.gov.uk/def/vehicle/bicycle> ;
      rdf:value 2 .    
