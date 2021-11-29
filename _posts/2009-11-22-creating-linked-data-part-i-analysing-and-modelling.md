---
layout: drupal-post
excerpt_separator: "<!--break-->"
title: ! 'Creating Linked Data - Part I: Analysing and Modelling'
created: 1258909097
tags: []
---
One of the goals of the government's Data Project is to equip the people who own data with the capability to publish it as linked data. There's an overwhelming amount of work to do here from providing tool support to changing a culture that makes it hard to publish data. But we can start by taking some baby steps that simply explain what's involved in turning existing data into linked data.

I'm currently reworking the traffic count linked data that I first transformed back in September, and I thought it would be helpful to talk through that process for several reasons:
  
  * to give people using the traffic count data more insight into how it fits together
  * so that other people can follow it as they transform their own data
  * so that tool providers can spot some of the places where tools might help

Rather than creating one massive blog post, I'm going to break it down into several steps. These are:

  1. analysing and modelling
  2. defining URIs
  3. defining concept schemes
  4. defining classes, properties and datatypes
  5. adding finishing touches

This is the first instalment.

<!--break-->

---

The first thing to do is to work out what *things* the data we have contains information about. One way of thinking about this is to try to identify anything in the data that you can imagine wanting to get information about. This process is exactly the same as the process you would go through when designing a database or an XML format.

It's worth noting that this is a design process rather than a discovery process. There is no inherent model in any set of data; I can guarantee you that someone else will break down a given set of data in a different way from you. That means you have to make decisions along the way.

The column headers in the traffic count dataset are:

    "Country Name","Region Name","ONS Region Code","DfT LA Code","ONS LA Code",
    "Local Authority Name","Count Point Number","Road Number","Road Sequence",
    "Road Category","Road Name at CP","CP Location","Site coordinate easting",
    "Site coordinate northin","Date of count","Direction of flow","Hour of count",
    "Pedal cycles","Two wheeled motor vehicles","Cars and taxis","Buses and coaches",
    "Light vans","HGVr2","HGVr3","HGVr4+","HGVa3/4","HGVa5","HGVa6","All HGV",
    "All motor vehicles"

A couple of example records are:

    "England","North West","B",4315.00,"00BZ","St.Helens Metropolitan Borough Council",
    4,"U",,"Unclassified Urban",,
    ,352100,398200,
    7/6/2001 00:00:00,"N",7,1,0,5,1,0,0,0,0,0,0,0,0,6

and:

    "England","South West","K",1115.00,"18","Devon County Council",
    13,"B3178",,"B Urban","Salterton Road",
    "Salterton Road, EAST OF DINAN WAY, EXMOUTH",302600,81984,
    8/10/2001 00:00:00,"E",17,2,2,400,5,41,0,2,0,0,0,0,2,450

After a bit of reading [documentation](http://www.dft.gov.uk/matrix/forms/definitions.aspx) and poking around in the data, it emerges that we can group these together as follows:

  * fields about **countries**
    * `Country Name`
  * fields about **regions**
    * `Region Name`
    * `ONS Region Code` (ONS = Office of National Statistics)
  * fields about **local authorities**
    * `DfT LA Code` (DfT = Department for Transport)
    * `ONS LA Code`
    * `Local Authority Name`
  * fields about **roads**
    * `Road Number` (not available for unclassified roads)
  * fields about **count points**
    * `Count Point Number`
    * `Road Sequence` (indicates order of count points on particular roads; only applicable to count points on those long roads)
    * `Road Category` (roads can have different categories at different points; for example the A1 is sometimes "Trunk Motorway" and sometimes "Principal A Urban")
    * `Road Name at CP` (roads can have different names at different points; for example the A240 is sometimes "Surbiton Hill Road", sometimes "Reigate Road", sometimes something else)
    * `CP Location` (a description of the location, sometimes missing)
    * `Site coordinate easting`
    * `Site coordinate northing`
  * fields about **counts**
    * `Date of count`
    * `Direction of flow` (one of the cardinal directions; observations at a particular count point will be made in both directions the road goes in)
    * `Hour of count` (observations each cover an hour of traffic, from 7am to 7pm)
  * fields that are counts
    * `Pedal cycles`
    * `Two wheeled motor vehicles`
    * `Cars and taxis`
    * `Buses and coaches`
    * `Light vans`
    * `HGVr2` (HGVs with two rigid axles)
    * `HGVr3`
    * `HGVr4+`
    * `HGVa3/4` (articulated HGVs with three or four axles)
    * `HGVa5`
    * `HGVa6`
    * `All HGV`
    * `All motor vehicles`

Some of the fields contain information about things (countries, regions etc), and some of them contain the actual data themselves, with the field names telling us about their type (ie the counts of various sorts). The `Road Category` field actually contains a whitespace-separated list of road categories about which we can imagine wanting to have more information (like what, exactly, is a 'principal' road?). So as a first cut, the things in the data are:

  * countries
  * regions
  * local authorities
  * roads
  * road categories
  * count points
  * counts
  * vehicle types

There are also implied relationships between the various things that are described within the dataset, that can be identified through the co-occurrence of things within the same record. For example, all records that contain `"North West"` as a value for `Region Name` have `"England"` as the value for `Country Name`, so we can tell from the data that England contains the North West.

There's obviously some kind of relationship between local authorities and regions (eg a `Local Authority Name` of `"Surrey County Council"` implies a `Region Name` of `South East`), but it's hard to put a name to it. The relationship becomes more obvious if we introduce a new type of thing: a **local authority district**. Then we can say that a local authority covers a local authority district which is within a region.

So a first cut at a model is:

                        +---- country
                        |        |
                        |        | contains
               contains |        v
                        |     region
                        |        |
                        |        | contains
                        v        v           covers
                  local authority district <--------- local authority
                             |
                             | contains
                on           v          category
      road <----------- count point -----------------> road category
                             ^
                             | at
                             |            of
                           count --------------------> vehicle type

This is how I modelled it the first time round. It's a pretty pure conceptual model: I haven't taken into consideration how the model's going to be represented (you could use the model to create some database tables, some XML or some RDF) or how it's going to be queried.

But the fact is that it's going to be represented as linked data, using RDF and querying with SPARQL. Having had experience with querying the model as represented above, there are three changes that I'm going to make:

  1. During a given hour at a given count point, the counts of all the different types of traffic are made by the same observer (be it human or electronic). It feels as if that set of counts (which are all represented within a single record in the CSV) belong together in some way. It also feels like it would be useful to be able to talk about that set of counts as a set, because they're all going to be affected by the same factors (eg faults in the machine recording the counts; traffic jams; roadworks), and even though it's not present in this dataset, we might want somewhere to hang that information. Pulling that duplicated data out into a separate *thing* will also help reduce the repetition and the number of triples needed in the RDF, which will speed up searching.
  
  2. The data itself records the actual date on which the observation was taken, and the hour on which it was done. This could be represented just by a start date time like `2001-06-07T07:00:00`, and that's how I did it initially. However, when you're trying to analyse the data the things that really matter, most of the time, about the observation are the year and the hour. SPARQL isn't very good at doing date/time processing, and anyway there are all sorts of things about a particular date that might be interesting (what day of the week is it? is it during the school summer holiday?) so it makes sense to pull these hour-long intervals out as separate *things* that we can talk about.
  
  3. In a similar way, although the cardinal direction associated with a particular count could be represented as a simple string, whenever there's a set of enumerated values it's a good idea to consider turning them into *things*, because to do so enables you to associate extra information about them. For example, it would let us say that the English word for North is North, and that North is the opposite direction to South, and so on.

So here's what the revised model looks like:
  
                       +---- country
                       |        |
                       |        | contains
              contains |        v
                       |     region
                       |        |
                       |        | contains
                       v        v            covers
                 local authority district <----------- local authority
                            | 
                            | contains
                on          v           category
     road <----------- count point -------------------> road category
                            ^
                            | at
                   in       |     at           during
    direction <---------- count -----> period --------> year
                            ^            +-----start--> instant
                            | at         +-----end----> instant
                            |              of
                       observation -------------------> vehicle type

and here's a list of the things with a rough set of properties; properties marked with a question mark (?) are ones that don't always have values in the data. Properties marked with an arrow (->) are ones that are pointers to other things.

  * country
    * name
  * region
    * name
    * ONS code
    * country ->
  * local authority district
    * name
    * ONS code
    * DfT code
    * local authority ->
    * region ->
    * country ->
  * local authority
    * name
    * ONS code
    * DfT code
    * local authority district ->
  * road
    * number ?
  * count point
    * number
    * road sequence ?
    * road name ?
    * description ?
    * easting
    * northing
    * road ->
    * road category ->
    * local authority ->
    * local authority district ->
  * road category
    * name
    * related categories ->
  * count
    * direction ->
    * count point ->
    * period ->
  * direction
    * name
    * related directions
  * observation
    * value
    * count ->
    * vehicle type ->
  * vehicle type
    * name
    * related types ->
  * period
    * start (instant) ->
    * end (instant) ->
    * year (period) ->
  * instant
    * year, month, day, hour, minute, second etc.

This is the first part of the process done. More soon.
