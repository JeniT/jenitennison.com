---
layout: drupal-post
excerpt_separator: "<!--break-->"
title: Map Visualisation of MPs Travel Expenses
created: 1249079593
tags:
- rdf
- talis
- visualisation
---
During [Guardian Hack Day 2](http://www.guardian.co.uk/media/pda/2009/jul/31/hacking-opensource1), [Leigh](http://www.ldodds.com/) ported the [Guardian's MP's Expenses data](http://mps-expenses.guardian.co.uk/) into [Talis](http://guardian.dataincubator.org/). Most wonderfully, this gives a [SPARQL endpoint](http://api.talis.com/stores/guardian/services/sparql) that can be used to query the data. I thought I'd try to use the same approach as I [blogged about recently](http://www.jenitennison.com/blog/node/113), using a SPARQL query as a [Data Source](http://code.google.com/apis/visualization/documentation/dev/implementing_data_source.html) for a [Google Visualisation](http://code.google.com/apis/visualization/documentation/gallery.html) of the MP's expenses data.

To cut to the chase, here's a screenshot of [the result](http://www.jenitennison.com/visualisation/mp-travel.html) (follow the link for the more interactive version):

<img alt="Map of travel expenses for the 100 MPs with the lowest majorities" src="/blog/files/mp-travel.jpg" width="100%" />

<!--break-->

I created this visualisation with the same general approach as I [explained last time](http://www.jenitennison.com/blog/node/113).

First, I've been working on the visualisation `utils.php`, which is a reasonably simple PHP script that exposes a SPARQL endpoint as a Google Visualisation Data Source. Requests to a Data Source use a special [query language](http://code.google.com/apis/visualization/documentation/querylanguage.html) to indicate the information that should be included, how it should be sorted, how many rows of data there should be, and so on.

Previously, [`utils.php`](/blog/files/utils.php_2.txt) only understood the `select` portion of the `tq` parameter which contains this query; I've expanded it to understand (somewhat limited versions of) the `select`, `where`, `order by`, `limit` and `offset` parts of the query, which of course have equivalents in [SPARQL](http://www.w3.org/TR/rdf-sparql-query/). Since these parts of the Google Visualisation query language are pretty close to SPARQL, this is actually just a bunch of string munging, which isn't particularly interesting, so just [grab hold of it](/blog/files/utils.php_2.txt) if you want to use it.

Second, I created a PHP script ([`mp-travel.php`](/blog/files/mp-travel.php.txt)) specifically for the MPs expenses data that pulls out the parts that I'm interested in and exposes them as variables which can be used in the query language. This is what the file looks like:

    <?php
      include "utils.php";
      proxy('?rMP a <http://guardian.dataincubator.org/ns/MemberOfParliament> .
             ?rMP <http://xmlns.com/foaf/0.1/name> ?mp .
             ?rMP <http://guardian.dataincubator.org/ns/mp-expenses/majority> ?majority .
             ?rMP <http://dbpedia.org/property/constituency> ?rConstituency .
             ?rConstituency rdfs:label ?constituency .
             ?rConstituency <http://www.w3.org/2003/01/geo/wgs84_pos#lat> ?lat .
             ?rConstituency <http://www.w3.org/2003/01/geo/wgs84_pos#long> ?long .
             ?rMP <http://guardian.dataincubator.org/ns/mp-expenses/total-travel> ?totalTravel .',
            'desc(?totalTravel)', 
            'guardian');
    ?>

The second argument to the `proxy()` function is the default ordering (`desc(?totalTravel)`) and the third is the name of the Talis data store that's being used (`guardian`).

The first argument is a query which determines the variables that are exposed by the Data Source. This Data Source exposes the variables:

  * `mp`: the name of the MP
  * `majority`: the majority that they have in their constituency
  * `constituency`: the name of the constituency
  * `lat`, `long`: the latitude and longitude of the constituency (presumably the centre of it)
  * `totalTravel`: the total amount claimed for travel by the MP
  * `rMP`: the URI used to identify the MP
  * `rConstituency`: the URI used to identify the constituency

Third, I created an [HTML document](/blog/files/mp-travel.html) that used the Google Visualisation API to create the map visualisation that I've shown above. The really important lines are:

    var query = new google.visualization.Query('http://www.jenitennison.com/visualisation/data/mp-travel');
    query.setQuery('select lat, long, totalTravel, mp order by majority limit 100');

The first line shows the URL for the Data Source, which is essentially a pointer to the `mp-travel.php` script. The second line shows the query that's sent to the Data Source: "`select lat, long, totalTravel, mp order by majority limit 100`".

Put together, when you load [http://www.jenitennison.com/visualisation/mp-travel.html](http://www.jenitennison.com/visualisation/mp-travel.html), you create a [Google Visualisation GeoMap](http://code.google.com/apis/visualization/documentation/gallery/geomap.html) which uses as its data the result of the SPARQL query

    SELECT ?lat ?long ?totalTravel ?mp
    WHERE {
      ?rMP a <http://guardian.dataincubator.org/ns/MemberOfParliament> .
      ?rMP <http://xmlns.com/foaf/0.1/name> ?mp .
      ?rMP <http://guardian.dataincubator.org/ns/mp-expenses/majority> ?majority .
      ?rMP <http://dbpedia.org/property/constituency> ?rConstituency .
      ?rConstituency rdfs:label ?constituency .
      ?rConstituency <http://www.w3.org/2003/01/geo/wgs84_pos#lat> ?lat .
      ?rConstituency <http://www.w3.org/2003/01/geo/wgs84_pos#long> ?long .
      ?rMP <http://guardian.dataincubator.org/ns/mp-expenses/total-travel> ?totalTravel .
    }
    ORDER By ?majority
    LIMIT 100

on the SPARQL endpoint at [http://api.talis.com/stores/guardian/services/sparql](http://api.talis.com/stores/guardian/services/sparql).

Here's hoping you can reuse the Data Source or the code that was used to make it. Let me know if you do!
