---
layout: drupal-post
title: ! 'Creating Linked Data - Part II: Defining URIs'
created: 1258910614
tags:
- linked data
- uri
---
This is the second instalment in a series of posts about how to create linked data from existing data sets, using traffic count data as an example. In the last instalment, I talked about [analysing and modelling data](http://www.jenitennison.com/blog/node/135). This instalment discusses the creation of URIs for the various *things* that have been identified within the model.

This part of the process is the same as what you'd do if you were simply creating a RESTful API to a website. The principal is that everything has a URI, and if you resolve that URI you get information about the thing.

<!--break-->

For the data.gov.uk site, we now have some [guidelines about the design of URIs for the UK public sector](http://www.cabinetoffice.gov.uk/media/308995/public_sector_uri.pdf). Basically, URIs for *things* should look like:

    http://{sector}.data.gov.uk/id/{type of thing}/{thing identifier}

There'll be plenty of examples in what follows.

## Areas ##

Some of the things that we've identified as being part of the traffic count dataset already have centrally-defined identifiers. As part of other data.gov.uk work, we've defined URIs for administrative areas like countries, regions, local authority districts and local authorities. The templates for these URIs are:

    http://statistics.data.gov.uk/id/country/{ONS code}
    http://statistics.data.gov.uk/id/government-office-region/{ONS code}
    http://statistics.data.gov.uk/id/local-authority-district/{ONS code}
    http://statistics.data.gov.uk/id/local-authority/{ONS code}

We can use these identifiers directly for the regions, districts and local authorities. But there's a problem with the country URI: we don't have the ONS code for the country, only the name of the country. Fortunately, we've also defined URIs with this pattern:

    http://statistics.data.gov.uk/id/country?name={country name}
    http://statistics.data.gov.uk/id/government-office-region?name={region name}
    http://statistics.data.gov.uk/id/local-authority-district?name={district name}
    http://statistics.data.gov.uk/id/local-authority?name={authority name}

so in this situation we can use the name-based country URI and we'll get redirected to the canonical, code-based URI.

Local authorities actually have two codes within the dataset that we have: the ONS code and a DfT code. I can well imagine that other datasets from the Department for Transport will only reference the DfT code, so it's a good idea to create URIs that are based on these codes; later on, we can state that the two identifiers actually mean exactly the same thing.

    http://transport.data.gov.uk/id/local-authority-district/{DfT code}
    http://transport.data.gov.uk/id/local-authority/{DfT code}

So given the record:

    "England","North West","B",4315.00,"00BZ","St.Helens Metropolitan Borough Council",
    4,"U",,"Unclassified Urban",,
    ,352100,398200,
    7/6/2001 00:00:00,"N",7,1,0,5,1,0,0,0,0,0,0,0,0,6

the URIs we've defined so far are:

    http://statistics.data.gov.uk/id/country?name=England
    http://statistics.data.gov.uk/id/government-office-region/B
    http://statistics.data.gov.uk/id/local-authority-district/00BZ
    http://statistics.data.gov.uk/id/local-authority/00BZ
    http://transport.data.gov.uk/id/local-authority-district/4315
    http://transport.data.gov.uk/id/local-authority/4315

## Roads ##

Now we're onto things that aren't defined already. First is roads. If there's a road number, the obvious thing to use is that road number; something like:

    http://transport.data.gov.uk/id/road/{road number}

For example:

    http://transport.data.gov.uk/id/road/B3178

If there isn't a road number, we'll have to construct a URI. Since each count point is on one particular road, we can use the identifier of the count point to identify the road, so:

    http://transport.data.gov.uk/id/road/{class}-{count point number}

For example:

    http://transport.data.gov.uk/id/road/U-4

## Count Points ##

Count points can be identified through their number, so it makes sense to use that in the URI:

    http://transport.data.gov.uk/id/traffic-count-point/{count point number}

For example:

    http://transport.data.gov.uk/id/traffic-count-point/4

## Counts ##

The counts themselves don't have their own identifiers, but they can be identified through a combination of the count point that they're associated with, the direction of travel of the traffic that's being counted, and the date and time that the count is made. So we can create a URI that combines these things. To aid hackability, I'm going to build on top of the traffic count point URI that we've already defined:

    http://transport.data.gov.uk/id/traffic-count-point/{count point number}/direction/{direction}/hour/{time}

For example:

    http://transport.data.gov.uk/id/traffic-count-point/4/direction/N/hour/2001-06-07T07:00:00

## Observations ##

Again, observations build on top of the counts by adding a vehicle type to the mix, so we can construct URIs that reflect that:

    http://transport.data.gov.uk/id/traffic-count-point/{count point number}/direction/{direction}/hour/{time}/type/{vehicle type}

For example:

    http://transport.data.gov.uk/id/traffic-count-point/4/direction/N/hour/2001-06-07T07:00:00/type/motor-vehicle

## Road Categories ##

Road categories are a bit different from the kinds of things that we've been talking about so far: they are concepts. For these URIs we use a slightly different pattern from the URIs above: `/def/` rather than `/id/`. For road categories we can use:

    http://transport.data.gov.uk/def/road-category/{category}

For example:

    http://transport.data.gov.uk/def/road-category/motorway

## Vehicle Types ##

Vehicle types are also concepts, so have similar URIs:

    http://transport.data.gov.uk/def/vehicle-category/{type}

For example:

    http://transport.data.gov.uk/def/vehicle-category/HGVa5

## Cardinal Directions ##

Cardinal directions are also concepts, but really they are global concepts, not specific to transport, or even to the UK. So it feels a bit strange to use URIs for them that imply that they somehow belong to data.gov.uk.

Fortunately, for this kind of general concept we can use URIs defined by [DBPedia](http://dbpedia.org). DBPedia is a linked data view on Wikipedia, so it has URIs for everything that Wikipedia has a page about, making it an excellent general purpose resource. The relevant URIs for the cardinal directions are:

    http://dbpedia.org/resource/North
    http://dbpedia.org/resource/South
    http://dbpedia.org/resource/East
    http://dbpedia.org/resource/West

so that's what we'll use.

## Dates, Times and Periods ##

For dates, times and periods, we can use the URIs provided by another general-purpose linked data resource: [placetime.com](http://www.placetime.com/). URIs for instants have the pattern:

    http://placetime.com/instant/gregorian/{dateTime}

while periods have the pattern:

    http://placetime.com/interval/gregorian/{dateTime}/{duration}

So the hour from 7-8am on 7th June 2001 would be:

    http://placetime.com/interval/gregorian/2001-06-07T07:00:00/PT1H

and the year 2001 would be:

    http://placetime.com/interval/gregorian/2001-01-01T00:00:00/P1Y

The thing is that the latter isn't particularly approachable. Calendar years are used all over the place, so it would be nice to have a set of URIs for them that we use consistently. Again, DBPedia provides URIs for every year, such as:

    http://dbpedia.org/resource/2001

so where we need to refer to a calendar year, it would be good to reuse that.

---

And that completes the sets of URIs that we need for this data. Stay tuned.
