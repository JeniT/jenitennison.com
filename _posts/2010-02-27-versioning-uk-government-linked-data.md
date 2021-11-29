---
layout: drupal-post
excerpt_separator: "<!--break-->"
title: Versioning (UK Government) Linked Data
created: 1267308940
tags:
- linked data
- versioning
- named graphs
---
As you probably know, I've been working quite a lot recently on the UK government's use of linked data, and in particular on providing guidance for people who want to publish their data as linked data. One of the things that we need to provide guidance about is how to publish linked data that changes over time. I've [touched on this topic before](http://www.jenitennison.com/blog/node/108) but things have progressed now to the stage where we have to make some real, practical, recommendations.

*Note: the contents of this post have been greatly informed through discussions with [Leigh Dodds](http://www.ldodds.com/blog/), [Stuart Williams](http://twitter.com/skwlilac), [Dave Reynolds](http://www.amberdown.net/), [Ian Davis](http://iandavis.com/) and John Sheridan. Ian Davis' series on [representing time in RDF](http://blog.iandavis.com/2009/08/time-in-rdf-1) is also well worth a look for a comparison of alternative approaches.*

I've split this into two parts: versioned information resources (which are pretty easy) and versioned non-information resources (which are pretty hard). For both, we need to

  * provide some guidance about what the RDF should look like
  * mint or adopt properties to support that model

## Versioned Information Resources ##

Easy things first. Some of the things that we talk about, such as legislation, are information resources (web documents), and these have different versions. The relevant level of precision for legislation is a day, but this will be different for different kinds of documents -- some might change every second, for others an incrementally increasing version number might be more appropriate than a date. A generic pattern for the URIs, based on the [design of URI sets for the UK public sector report](http://writetoreply.org/ukgovurisets/) would be:

    http://{sector}.data.gov.uk/doc/{concept}/{identifier}/{version}

For example, the OFSTED report for a particular school based on an inspection carried out in 2009 might be something like:

    http://education.data.gov.uk/doc/inspection-report/12345/2009

(There might be sub-versions too, if the inspection report itself goes through a revision process.) The RDF for this document should include links to the previous reports that it replaces, and dates that indicate when it was created and so on:

    <http://education.data.gov.uk/doc/inspection-report/12345/2009>
      rdfs:label "2009 Inspection Report for Such-and-Such School"@en ;
      dct:created "2009-10-18"^^xsd:date ;
      dct:replaces <http://education.data.gov.uk/doc/inspection-report/12345/2006> .

It's also useful to have a URI for unversioned document; this is the same as for the versioned document, but without the version:

    http://{sector}.data.gov.uk/doc/{concept}/{identifier}

This document acts as a hub for the various concrete versions of the document:

    <http://education.data.gov.uk/doc/inspection-report/12345>
      rdfs:label "Inspection Report for Such-and-Such School"@en ;
      dct:hasVersion
        <http://education.data.gov.uk/doc/inspection-report/12345/2009> ,
        <http://education.data.gov.uk/doc/inspection-report/12345/2006> ,
        <http://education.data.gov.uk/doc/inspection-report/12345/2003> ,
        ... .
    
    <http://education.data.gov.uk/doc/inspection-report/12345/2009>
      rdfs:label "2009 Inspection Report for Such-and-Such School"@en ;
      dct:created "2009-10-18"^^xsd:date ;
      dct:replaces <http://education.data.gov.uk/doc/inspection-report/12345/2006> ;
      dct:isVersionOf <http://education.data.gov.uk/doc/inspection-report/12345> .
    
    <http://education.data.gov.uk/doc/inspection-report/12345/2006>
      rdfs:label "2009 Inspection Report for Such-and-Such School"@en ;
      dct:created "2003-11-23"^^xsd:date ;
      dct:isReplacedBy <http://education.data.gov.uk/doc/inspection-report/12345/2009> ;
      dct:replaces <http://education.data.gov.uk/doc/inspection-report/12345/2003> ;
      dct:isVersionOf <http://education.data.gov.uk/doc/inspection-report/12345> .

It would be expected that people linking to the document would either point to a particular (dated) resource or to the unversioned (hub) document. For example, if someone were talking specifically about the 2006 OFSTED inspection, they would point to the 2006 inspection report; if they were referring to whatever inspection report is current, they'd use the unversioned URI.

> _Note: Although `dct:hasVersion` and `dct:isVersionOf` are sort-of OK here, having a property that points to the current version (ie most recent) version of a resource would be very helpful._

## Versioned Non-Information Resources ##

The harder problem is how we handle changes to non-information resources over time. For example, how do we handle the fact that a school often changes head, sometimes changes name, regularly changes class sizes, rarely changes address and so on? How do we handle the fact that we have legacy statistics about local authorities as they were in 2008, prior to the 2009 reorganisation, and that it's very likely that these kinds of changes will continue to take place regularly in the future?

Our requirements are:

  * that the data is easily usable by people who only care about the current state of a resource
  * that the (current) data remains easily queryable at a SPARQL endpoint
  * that it's *possible* (not necessarily easy) to query historic data
  * that historic data can be moderately easily retrieved and navigated
  * that it can represent historical states even when the precise time period is not known
  * that it can distinguish between a change in the concept and a change in our record of it (e.g. changing the name of a school, versus correcting a typo in the database entry for the school)
  * that it can trace what the nature or cause of the change was (e.g. redrawing of local authority boundaries)

### Statistical Data ###

To begin our discussion, let's look at statistical data. Statistical data is data that's usually numeric and for which we have values that are categorised along multiple dimensions as well as time. School census information is statistical data, for example, because each value is associated with not only the school and the date at which the census was taken but also the age (and gender, but to simplify I'll pretend just age) of the children being counted. This gives us a set of observations which might each look like:

    </data/edubase/census/12345/age/11/2009> 
      a sdmx:Observation ;
      sdmx:dataset </data/edubase> ;
      dct:replaces </data/edubase/census/12345/age/11/2008> ;
      rdf:value 85 ;
      edu:school </id/school/12345> ;
      edu:schoolYear </id/school-year/2009> ;
      sdmx:age 11 .

> Note: This is indicative of the vocabulary we might use for statistics; don't rely on it. If you're interested in the progress we're making on modelling statistical datasets using RDF, come and join [the publishing statistical data Google Group](http://groups.google.com/group/publishing-statistical-data).

These statistical observations point to the interval that they apply to as a property, with the `rdf:value` property holding the actual value. The observation won't change over time (unless it is corrected, which I will come back to), and **observations from different times can all remain present within the graph without interacting badly with each other**.

This is great because it means that we can make queries that give us time series views over the data. For example, we could define a series for girls aged 11 at this particular school over time something like this:

    </data/edubase/census/12345/age/11>
      a sdmx:TimeSeries ;
      edu:school </id/school/12345> ;
      sdmx:age 11 ;
      sdmx:observation
        </data/edubase/census/12345/age/11/gender/F/2009> ,
        </data/edubase/census/12345/age/11/gender/F/2008> ,
        </data/edubase/census/12345/age/11/gender/F/2007> ,
        ... .

and associate this with the school through a specialised property:

    </id/school/12345> edu:age11 </data/edubase/census/12345/age/11> .

The fly in the ointment is that data that is purely represented in this way is really hard to query if all you're actually interested in is the *current* value for the particular statistic. For example, say that you've just moved to an area and are trying desperately to find a school that might have room for your 11-year-old. Given that class sizes are capped at 30, you could look for schools that have a number of 11-year-olds that is not a multiple of 30. If you want to know how many 11 year-olds are *currently* in a school (according to the most recent measurement), you need a query like:

    SELECT ?age11
    WHERE {
      </id/school/12345> edu:age11 [
        sdmx:observation ?currentObservation ;
      ]
      OPTIONAL {
        ?futureObservation dct:replaces ?currentObservation .
      }
      FILTER ( !bound(?futureObservation) ) .
      ?currentObservation rdf:value ?age11 .
    }

(it's even more complicated if you don't have the `dct:replaces` links!).

How much simpler it would be for people if there was a property that just indicated the current state of the world:

    </id/school/12345> edu:currentAge11 85 .

The same argument applies even more strongly for values that we would categorise as **reference data**, such as the name of a school. Although it would be possible to model all this information using the kind of n-ary relation approach we have to use for statistical observations, it would be both incredibly hard to query and incredibly verbose to do so. Even if n-ary relations are the "correct" way of modelling the changing data, they are impractical for querying.

And, as I hinted, we have to have some way of managing the possibility of statistics themselves being versioned (for example if an error is detected within the statistics). Using n-ary relations to provide the value of an observation gets very complicated very quickly.

So, we have made the decision to use named graphs.

### Named Graphs ###

Named graphs can be used in two ways which are related but need to be thought about slightly differently.

First, we can use a named-graph approach to the **publication** of RDF. We can describe the same *thing* within multiple documents; each document can contain different (and contradictory) information, but also metadata about the document that indicates precisely when the information it contains is valid.

Second, we can use a named-graph approach to the **representation** of RDF within a triple- (or more accurately quad-) store. We can collect together statements that are made at the same time, from the same source, and with the same level of authority into a named graph. These graphs can then be loaded into the store, with the metadata about each graph made explicitly available so that relevant graphs can be selected and queried.

There are two things that are worth noting about this:

  1. Publishing named graphs is relevant however RDF is published. For example, in some linked data publication set-ups, RDF/XML or RDFa might be generated on demand based on an underlying database of some description. In this case, the named graphs for representing data aren't relevant (the database will presumably capture some provenance and validity information itself that can be exposed within the RDF).
  2. In the case where linked data is published natively (ie stored in a triplestore and exposed as linked data through an API), the two uses of named graphs don't precisely align with each other. The named graphs that we create when we convert or load data within a triplestore are not (necessarily) the same as the named graphs that we expose when we publish data. What's important here is
    * that the named graphs that we have within the triplestore can feasibly be used (by a publication framework such as the [linked data API](http://purl.org/linked-data/api/spec) we're working on) to create the publication-based named graphs
    * that the SPARQL endpoint offered by the triplestore has a default graph which reflects the current state of affairs

Let's look at these two uses of named graphs in more detail.

### Publication of Named Graphs ###

Our intention is to publish different information about the same resource within different documents (aka named graphs). This approach hooks into the approach for versioning information resources outlined above. A resource is described in a document, and many documents may describe the same resource.

For example, if a school changes its name from "Broadmoor Primary School" to "Wildmoor Heath School" on 1st September 2009, then after 1st September 2009, requesting information about the school at `http://education.data.gov.uk/id/school/12345` would result in a `303 See Other` redirection to `http://education.data.gov.uk/doc/school/12345` which would contain information about the school that is currently relevant:

    # Information about the school that is currently relevant
    <http://education.data.gov.uk/id/school/12345>
      rdfs:label "Wildmoor Heath School"@en ;
      foaf:isPrimaryTopicOf 
        <http://education.data.gov.uk/doc/school/12345> ,
        <http://education.data.gov.uk/doc/school/12345/2009-09-01> ,
        <http://education.data.gov.uk/doc/school/12345/2001-09-01> ,
        <http://education.data.gov.uk/doc/school/12345/1996-09-01> ,
        ... .
    

as well as metadata about the document that's been returned and the "hub" document that lists the alternative versions:

    <http://education.data.gov.uk/doc/school/12345>
      rdfs:label "Information about School 123456"@en ;
      foaf:primaryTopic <http://education.data.gov.uk/id/school/12345> ;
      dct:hasVersion
        <http://education.data.gov.uk/doc/school/12345/2009-09-01> ,
        <http://education.data.gov.uk/doc/school/12345/2001-09-01> ,
        <http://education.data.gov.uk/doc/school/12345/1996-09-01> ,
        ... .
    
    <http://education.data.gov.uk/doc/school/12345/2009-09-01>
      rdfs:label "Information about Wildmoor Heath School from 1st Sept 2009"@en ;
      foaf:primaryTopic <http://education.data.gov.uk/id/school/12345> ;
      dct:created "2009-09-01"^^xsd:date ;
      dct:replaces <http://education.data.gov.uk/doc/school/12345/2001-09-01> ;
      dct:isVersionOf <http://education.data.gov.uk/doc/school/12345> .

A request to the replaced document `http://education.data.gov.uk/doc/school/12345/2001-09-01` would result in the information that was valid about the school on the 1st September 2001:

    <http://education.data.gov.uk/id/school/12345>
      rdfs:label "Broadmoor Primary School"@en ;
      foaf:isPrimaryTopicOf 
        <http://education.data.gov.uk/doc/school/12345> ,
        <http://education.data.gov.uk/doc/school/12345/2009-09-01> ,
        <http://education.data.gov.uk/doc/school/12345/2001-09-01> ,
        <http://education.data.gov.uk/doc/school/12345/1996-09-01> ,
        ... .

and, again, metadata about the document that's been returned and the "hub" document that lists the alternative versions:

    <http://education.data.gov.uk/doc/school/12345>
      rdfs:label "Information about School 123456"@en ;
      foaf:primaryTopic <http://education.data.gov.uk/id/school/12345> ;
      dct:hasVersion
        <http://education.data.gov.uk/doc/school/12345/2009-09-01> ,
        <http://education.data.gov.uk/doc/school/12345/2001-09-01> ,
        <http://education.data.gov.uk/doc/school/12345/1996-09-01> ,
        ... .
    
    <http://education.data.gov.uk/doc/school/12345/2001-09-01>
      rdfs:label "Information about Broadmoor Primary School (2001-2008)"@en ;
      foaf:primaryTopic <http://education.data.gov.uk/id/school/12345> ;
      dct:created "2001-09-01"^^xsd:date ;
      dct:isReplacedBy <http://education.data.gov.uk/doc/school/12345/2009-09-01> ;
      dct:replaces <http://education.data.gov.uk/doc/school/12345/1996-09-01> ;
      dct:isVersionOf <http://education.data.gov.uk/doc/school/12345> .

The statements about `http://education.data.gov.uk/id/school/12345` in this second document are inconsistent with the statements retrieved from `http://education.data.gov.uk/doc/school/12345` but because they are published within different documents, they should be considered (by anyone retrieving this data) to be different graphs and therefore are allowed to provide different views of the world.

The statements about the named graphs `http://education.data.gov.uk/doc/school/12345/2009-09-01` and `http://education.data.gov.uk/doc/school/12345/2001-09-01` can include information about the interval during which the content of the document is valid. (We haven't worked out exactly how to indicate this yet; `dct:valid` is no good; see later.)

#### Associated Resources ####

This story seems fine until you start to look at linked resources. For example, schools may link out to separate resources, particularly when different aspects of a school are likely to change at different rates or come from different sources. A school is unlikely to change its name in the middle of a school year, but may well change some of its staff, and the number of pupils it has, during a year. It's likely that these separate sets of information will be represented as different resources.

The document published about the school for a particular date will not necessarily include all the details of the linked resource at that point in time. This can make it hard to navigate to the particular version of the linked resource. For example, if a client wants to look at the information about a school at 1st September 2001, they would locate the graph at `http://education.data.gov.uk/doc/school/12345/2001-09-01`. This might contain:

    <http://education.data.gov.uk/id/school/12345>
      rdfs:label "Broadmoor Primary School"@en ;
      edu:staffing <http://education.data.gov.uk/id/school/12345/staff> .

A request to `http://education.data.gov.uk/id/school/12345/staff` will result in a `303 See Other` request to `http://education.data.gov.uk/doc/school/12345/staff`. This is _current_ information about the staffing, and which will include:

    <http://education.data.gov.uk/id/school/12345/staff>
      rdfs:label "Staffing of Wildmoor Heath School"@en ;
      edu:school <http://education.data.gov.uk/id/school/12345> ;
      edu:head ... ;
      edu:deputy ... ;
      ... ;
      foaf:isPrimaryTopicOf
        <http://education.data.gov.uk/doc/school/12345/staff> ,
        <http://education.data.gov.uk/doc/school/12345/staff/2009-09-01> ,
        <http://education.data.gov.uk/doc/school/12345/staff/2009-04-23> ,
        <http://education.data.gov.uk/doc/school/12345/staff/2009-01-01> ,
        ... .
    
    <http://education.data.gov.uk/doc/school/12345/staff>
      rdfs:label "Information about Staffing at School 123456"@en ;
      foaf:primaryTopic <http://education.data.gov.uk/id/school/12345/staff> ;
      dct:hasVersion
        <http://education.data.gov.uk/doc/school/12345/staff/2009-09-01> ,
        <http://education.data.gov.uk/doc/school/12345/staff/2009-04-23> ,
        <http://education.data.gov.uk/doc/school/12345/staff/2009-01-01> ,
        ... .
    
    <http://education.data.gov.uk/doc/school/12345/staff/2009-09-01>
      rdfs:label "Staffing of Wildmoor Heath School in Autumn Term, 2009"@en ;
      foaf:primaryTopic <http://education.data.gov.uk/id/school/12345/staff> ;
      dct:created "2009-09-01"^^xsd:date ;
      dct:isVersionOf <http://education.data.gov.uk/doc/school/12345/staff> ;
      dct:replaces <http://education.data.gov.uk/doc/school/12345/staff/2009-04-23> .

The client then has to work out which of the possible versions of the graph about `http://education.data.gov.uk/id/school/12345/staff` it should look at to navigate back to the information that's relevant at 1st September 2001.

There are two techniques that we might use to help address this. One is for the information that's retrieved at `http://education.data.gov.uk/doc/school/12345/2001-09-01` to include some basic information about the linked resource that includes `foaf:isPrimaryTopicOf` links directly to the relevant versioned document about the linked resource. For example, that document should contain:

    <http://education.data.gov.uk/id/school/12345/staff>
      rdfs:label "Staffing of Wildmoor Heath School"@en ;
      foaf:isPrimaryTopicOf <http://education.data.gov.uk/doc/school/12345/staff/2001-09-01> .

These links will have to be generated by the publication framework since they are calculated based on the date of the requested resource.

The other technique is to use HTTP headers to request the applicable date, as suggested by the [Memento Experiment](http://www.mementoweb.org/). Even with this technique, it's still useful to have distinct URIs for the individual documents so that they can be pointed to and talked about.

### Representation of Data in Named Graphs ###

Let's turn to looking at the use of named graphs within a triplestore. In the government case, we're expecting that information about schools going into a single triplestore is likely to come from multiple sources. Each source may release information at different intervals, with different temporal validity. The data from a single source will over-ride other information from that source over time, but equally data from different sources will be overlapping and contradictory.

To manage this, we split up triples into named graphs based on:

  * their source
  * their temporal validity (and their temporal relationship with other graphs)
  * their authoritativeness

This metadata about the named graph is recorded within the named graph itself, using `voiD` and other vocabularies.

In more detail:

#### Named Graphs over Time ####

Named graphs are expected to occur within a series over time. The triples within one graph will be completely replaced by the triples within another graph. The most recent graph is one that has not yet been replaced. To record this, the graphs should have associated with them:

  * the dates when the data in the graph is valid (only the start date is really required)
  * the graph(s) that the graph replaces
  * the graph(s) that the graph is replaced by
  * the date when the data in the graph was created

To avoid repetition of data within multiple graphs, graphs should be split up at the level that updates are likely to occur within the source of the data. For example, Edubase holds a database of schools. If the linked data for schools is generated based on dumps of the entire Edubase database, then there would be a separate named graph for each dump of the database. If the linked data is created more dynamically, based on updates at the level of an individual school, say, then there should be a separate series of named graphs for each school. If the updates can occur at an even finer level of granularity (eg at each record within each table within the database), then there can be separate named graphs at that level.

#### Named Graphs from Different Sources ####

Information about the same resources will come from different sources, and have gone through different levels of processing to become linked data. To allow us to provide information about the provenance of different triples, separate named graphs should be used for data from different sources. The metadata about a graph should include:

  * the source of the data (through `dct:source`)
  * the provenance of the data (through something more complex, yet to be finalised)

Much of the information about a particular resource will only come from one source. For example, Edubase contains the pupil census for a school while Ofsted provides inspection reports. However, there will be overlaps between the information available from different sources, such as the name and address of the school.

For any given property of a resource (such as the name of the school), there should be one source that is the authoritative source of that information; other sources are considered supplementary. Each source should therefore usually provide two series of named graphs: one of information for which they are considered the authority, and one of information for which they are not. The metadata about the graph should include a property that indicates whether the information it contains is authoritative or not.

#### Constructing a Graph for a Given Date ####

It's extremely useful to be able to create snapshots that contain information that's current at a particular point in time. The most useful of these is the *current* graph, which is the one that should be exposed as the default graph in the SPARQL endpoint offered by the triplestore.

The graph can be created by combining:

  1. all the triples from authoritative graphs that are valid at that point in time (eg have a validity date before that point in time, and that are not replaced by a graph whose validity date is also before that point in time)
  2. those triples from supplementary graphs for which there is no existing triple in the graph with the same subject and property

For example, there may be information available about a school from Edubase and from OFSTED, as follows (in TRiG syntax):

    # graph containing data from Edubase from 2008-09-01
    <http://education.data.gov.uk/data/edubase/12345/2008-09-01/authoritative> {
      <http://education.data.gov.uk/id/school/12345>
        rdfs:label "Broadmoor Primary School"@en ;
        edu:census <http://education.data.gov.uk/id/school/12345/census> .
      
      <http://education.data.gov.uk/id/school/12345/census>
        ... .
    
      <http://education.data.gov.uk/data/edubase/12345/2008-09-01/authoritative>
        a void:Dataset ;
        dct:created "2008-09-01"^^xsd:date ;
        dct:replaces <http://education.data.gov.uk/data/edubase/12345/2007-09-01/authoritative> ;
        dct:isReplacedBy <http://education.data.gov.uk/data/edubase/12345/2009-09-01/authoritative> ;
        dct:source <http://www.edubase.gov.uk/> ;
        :authoritative true .
    
      <http://education.data.gov.uk/data/edubase/12345/2008-09-01>
        a void:Dataset ;
        void:subset <http://education.data.gov.uk/data/edubase/12345/2008-09-01/authoritative> ;
        ... .
    }
    
    # graph containing data from Edubase from 2009-09-01; the name of the school 
    # has changed (as have) the details of the census
    <http://education.data.gov.uk/data/edubase/12345/2009-09-01/authoritative> {
      <http://education.data.gov.uk/id/school/12345>
        rdfs:label "Wildmoor Heath School"@en ;
        edu:census <http://education.data.gov.uk/id/school/12345/census> .
      
      <http://education.data.gov.uk/id/school/12345/census>
        ... .
    
      ... metadata about this graph ...
    }
    
    # graph containing authoritative data from Ofsted from 2008-03-01
    # note that this doesn't include the name of the school
    <http://education.data.gov.uk/data/ofsted/12345/2008-03-01/authoritative> {
      <http://education.data.gov.uk/id/school/12345>
        edu:inspection <http://education.data.gov.uk/doc/school/12345/inspection/2008> .
      
      <http://education.data.gov.uk/doc/school/12345/inspection/2008>
        ... .
    
      ... metadata about this graph ...
    }
    
    # graph containing supplementary data from Ofsted from 2008-03-01
    # this includes the name of the school (at the time of the inspection)
    <http://education.data.gov.uk/data/ofsted/12345/2008-03-01/supplementary> {
      <http://education.data.gov.uk/id/school/12345>
        rdfs:label "Broadmoor Primary School"@en ;
    
      ... metadata about this graph ...
    }

Note that metadata about each graph is embedded in the graph itself.

In the example above, a graph for 2010-01-01 would contain:

    <http://education.data.gov.uk/id/school/12345>
      rdfs:label "Wildmoor Heath School"@en ;
      edu:census <http://education.data.gov.uk/id/school/12345/census> ;
      edu:inspection <http://education.data.gov.uk/doc/school/12345/inspection/2008> .
      
    <http://education.data.gov.uk/id/school/12345/census>
      ... .
      
    <http://education.data.gov.uk/doc/school/12345/inspection/2008>
      ... .

It would not contain the triple:

    <http://education.data.gov.uk/id/school/12345>
      rdfs:label "Broadmoor Primary School"@en ;

because this triple is only present in an authoritative form within `http://education.data.gov.uk/data/edubase/12345/2008-09-01/authoritative`, which is replaced by `http://education.data.gov.uk/data/edubase/12345/2009-09-01/authoritative` or from `http://education.data.gov.uk/data/ofsted/school/12345/2008-03-01/supplementary` which is a supplementary graph and can't override the label provided by the authoritative graph.

## Unanswered Questions ##

There are three gaps within this that need plugging.

First, how should we represent the interval during which a graph is valid? As I've indicated above, `dct:valid` doesn't cut it because it can't represent an interval very well (there is a [Dublin Core recommended format for representing periods](http://dublincore.org/documents/dcmi-period/) but it's not going to be easy for people to process). We have work ongoing on defining intervals (by Stuart Williams) and will probably have to mint our own property to indicate the temporal validity of a named graph, given that `dct:valid` takes a literal rather than a resource.

Second, how should we indicate whether a graph is authoritative or not? Should this be a simple boolean switch (which will make the logic for combining graphs easier, and probably be easiest to assess) or a kind of confidence level, which might allow for missing data better?

Third, how should we represent the events that cause the replacement of one named graph with another? I think that we should be able to use the provenance vocabulary that we end up using to represent these changes, so that it's possible to indicate whether the new information is the correction of a clerical error or an actual change to the real world thing.

And, we have to try this out. While it looks as if it might work, I won't be confident until we've tried it out with some real data and some real queries. I'm also concerned that while keeping data in separate, annotated, named graphs seems like our best chance of managing versions and tracking provenance, it adds a hurdle onto the generation of linked data that might be too high, particularly for people who are just starting out.
