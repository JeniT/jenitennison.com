---
layout: drupal-post
excerpt_separator: "<!--break-->"
title: Linked Open Data in a Changing World
created: 1247252092
tags:
- rdf
- linked data
---
There's a big push within the UK government right now, helped along by the [appointment of Tim Berners-Lee](http://blogs.cabinetoffice.gov.uk/digitalengagement/post/2009/06/09/Data-So-what-happens-now.aspx), to publish their data using Linked Data principles.

One of the challenges is how to publish Linked Data in a world that sometimes, even frequently, changes. Cool URIs don't change, but departmental domain names do, as departments are split and merged and rebranded. So the URIs that are minted for things like schools and roads need to be detached from the departments that have responsibility for them, neutralised into general domains such as `education.data.gov.uk` and `transport.data.gov.uk`.

But that's the least of the problems. Because schools and roads themselves don't remain static either. They are split and merged and rebranded. They are resources that change over time. What should their URIs look like?

<!--break-->

Some choices are (more or less) obvious. If we have an identifier for a school such as:

    http://education.data.gov.uk/id/school/109812

then if the school is merged, and a new school is created, this URI can redirect (`301 Moved Permanently`) to the URI for the new school. If the school is shut down, the URI can respond with a `410 Gone`.

But what if the [school's name changes](http://www.getbracknell.co.uk/news/s/2043401_broadmoor_primary_school_votes_on_new_name)? If we have a triple like this:

    <http://education.data.gov.uk/id/school/109812>
      ed:name "Broadmoor Primary School" .

that is true up to 1st September 2009, and:

    <http://education.data.gov.uk/id/school/109812>
      ed:name "Wildmoor Heath School"

that is true from 1st September 2009? Are there precautions we should be taking to ensure that these URIs will still work -- that the statements we make now about the school will remain valid -- in the face of these changes?

I can think of two ways of handling this. (But I'm sure there are others.)

  1. Having 'current' and 'dated' resource URIs, with the 'current' one redirecting to an appropriate 'dated' one.
  2. Having 'dated' document URIs that become named graphs.
  
Let me flesh these out a bit. 

## Current and Dated URLs ##

On the web, it's a common pattern to have URIs without dates in them meaning the "current" version of the resource, and URIs with dates to be used for versions on particular dates.

So `http://education.data.gov.uk/id/school/19081` could be used for the school as it is now, whereas `http://education.data.gov.uk/id/school/19081/2008-09-01` is used for the school as it was on 1st September 2008. If you requested `http://education.data.gov.uk/id/school/19081` on 1st April 2009 you'd get a `307 Temporary Redirect` response pointing you at `http://education.data.gov.uk/id/school/19081/2008-09-01`, since that was the last date that the school was updated.

In this scheme, the eventual response you'd get on 1st September 2009 would be something like:

    <http://education.data.gov.uk/id/school/19081/2009-09-01>
      ed:name "Wildmoor Heath School" ;
      rdfs:isDefinedBy <http://education.data.gov.uk/school/19081/2009-09-01> .
    
    <http://education.data.gov.uk/school/19081/2009-09-01>
      dc:modified "2009-09-01"^^xsd:date ;
      dct:hasVersion <http://education.data.gov.uk/school/19081/2008-09-01> .

and the same request, to `http://education.data.gov.uk/id/school/19081`, the day before would have given you:

    <http://education.data.gov.uk/id/school/19081/2008-09-01>
      ed:name "Broadmoor Primary School" ;
      rdfs:isDefinedBy <http://education.data.gov.uk/school/19081/2008-09-01> .
    
    <http://education.data.gov.uk/school/19081/2008-09-01>
      dc:modified "2008-09-01"^^xsd:date .

I think there could be another set of triples in both graphs about the timeless `http://education.data.gov.uk/id/school/19081` and its relationship to the two versions. But I don't know what relationship should be used between them (`dct:hasVersion`?).

The benefit of this approach is that the two sets of triples can be combined without the two versions of the school being merged together (although you still have to make sure you pick the most recent version when you're doing a query).

The downside is that as time goes on and changes pile on changes, you get more and more repeated triples with differently dated subjects, because many of the properties of the school won't change. It would be possible to define triples about the unddated `http://education.data.gov.uk/id/school/19081`, but

  1. those are properties on a different resource, and therefore queries won't automatically access them;
  2. it's hubristic to think that you can identify what will and won't change about a school over its lifetime, so I think you'd end up putting all the properties on the dated versions of the resource just to be on the safe side.
  
Another problem with this approach is that it makes it harder for people to make assertions externally about the resource. If I'm running my own site and want to say something about this school, I could make the statement:

    <http://education.data.gov.uk/id/school/19081> my:rating 5 .

but this would apply forevermore. Or I could make the statement:

    <http://education.data.gov.uk/id/school/19081/2008-09-01> my:rating 5 .

which would only apply to the school as on 2008-09-01. I would have to keep track of the new versions of the school as they became available, which is a lot of effort.

## Using Dated Document URIs ##

We could use undated identifier URIs but include metadata about the document containing the RDF in that document which indicates its currency. This is along the lines of what is shown in the [Linked Data Tutorial](http://www4.wiwiss.fu-berlin.de/bizer/pub/LinkedDataTutorial/#deref).

Under this approach, the identifier URI `http://education.data.gov.uk/id/school/19081` would give a `303 See Other` redirection. On 1st April 2009, it would redirect to `http://education.data.gov.uk/school/19081/2008-09-01` and would return:

    <http://education.data.gov.uk/id/school/19081>
      ed:name "Broadmoor Primary School" ;
      rdfs:isDefinedBy <http://education.data.gov.uk/school/19081/2008-09-01> .
    
    <http://education.data.gov.uk/school/19081/2008-09-01>
      dc:modified "2008-09-01"^^xsd:date .

On 1st September 2009, the identifier URI `http://education.data.gov.uk/id/school/19081` would redirect to `http://education.data.gov.uk/school/19081/2009-09-01` and the RDF returned would include triples like:

    <http://education.data.gov.uk/id/school/19081>
      ed:name "Wildmoor Heath School" ;
      rdfs:isDefinedBy <http://education.data.gov.uk/school/19081/2009-09-01> .
    
    <http://education.data.gov.uk/school/19081/2009-09-01>
      dc:modified "2009-09-01"^^xsd:date ;
      dct:hasVersion <http://education.data.gov.uk/school/19081/2008-09-01> .

The data available about the school at any particular time would always be current, and the metadata about that data can indicate when it was last changed.

A Linked-Data-aware triplestore that regularly scraped the site would create named graphs like:

    <http://education.data.gov.uk/school/19081/2008-09-01> {
      <http://education.data.gov.uk/id/school/19081>
        ed:name "Broadmoor Primary School" ;
        rdfs:isDefinedBy <http://education.data.gov.uk/school/19081/2008-09-01> .
        
      <http://education.data.gov.uk/school/19081/2008-09-01>
        dc:modified "2008-09-01"^^xsd:date .
    }
    
    <http://education.data.gov.uk/school/19081/2009-09-01> {
      <http://education.data.gov.uk/id/school/19081>
        ed:name "Wildmoor Heath School" ;
        rdfs:isDefinedBy <http://education.data.gov.uk/school/19081/2009-09-01> .
      
      <http://education.data.gov.uk/school/19081/2009-09-01>
        dc:modified "2009-09-01"^^xsd:date ;
        dct:hasVersion <http://education.data.gov.uk/school/19081/2008-09-01> .
    }

and it would then be possible to use SPARQL to query the graphs either individually or in combination.

What bothers me about this approach is that anything scraping the data needs to understand the interaction between the date of requesting `http://education.data.gov.uk/id/school/19081` and the value of `dc:modified` in the resource linked to through `rdfs:isDefinedBy` to tell the difference between information that *is* true and information that *was* true. A naive aggregator that regularly visited the site could easily end up with just:

    <http://education.data.gov.uk/id/school/19081>
      ed:name "Broadmoor Primary School" ;
      ed:name "Wildmoor Heath School" ;
      rdfs:isDefinedBy <http://education.data.gov.uk/school/19081/2009-09-01> 
      rdfs:isDefinedBy <http://education.data.gov.uk/school/19081/2008-09-01> .
    
    <http://education.data.gov.uk/school/19081/2009-09-01>
      dc:modified "2009-09-01"^^xsd:date .
      
    <http://education.data.gov.uk/school/19081/2008-09-01>
      dc:modified "2008-09-01"^^xsd:date .

with no means of telling which name is associated with which modification date.

*Aside: What really bothers me about named graphs is that there's no real standard. The closest is in SPARQL, which standardises how to query over a set of graphs but doesn't really say how these graphs could be created. There's nothing that I know of that says that named graphs should be created as I've described above. The syntaxes suggested for expressing named graphs are drafts and notes and proposals.*

*Without standards that define how named graphs should be created and expressed, it's hard to work out how exactly they should be used.*

So: what options have I missed? How should we be publishing Linked Data in a changing world?
