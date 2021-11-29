---
layout: drupal-post
excerpt_separator: "<!--break-->"
title: ! 'SPARQL & Visualisation Frustrations: Linked Data'
created: 1249331794
tags:
- rdf
- linked data
- talis
- visualisation
- sparql
---
I'll start with the problem. To create the graphs I showed in [my last post](http://www.jenitennison.com/blog/node/120), I wanted to split MPs into groups based on their party affiliation. Ideally, I wanted the Google Visualisation query to look like:

    select mp, additionalCosts, totalTravel, totalBasic 
    where party = 'Conservative' 
    order by totalClaim desc 
    limit 25

because this is reasonably easy to understand and for a developer to create without having to know any magic URIs.

The party affiliation for an MP is given in the RDF supplied within the [Talis store](http://guardian.dataincubator.org/) as a pointer to one of the resources:

  * `http://dbpedia.org/resource/Labour_Party_(UK)`
  * `http://dbpedia.org/resource/Conservative_Party_(UK)`
  * `http://dbpedia.org/resource/Liberal_Democrats`

Now, if you visit <a href="http://dbpedia.org/resource/Conservative_Party_(UK)">http://dbpedia.org/resource/Conservative\_Party\_(UK)</a> then you'll see precious few properties and none of them give you access to the string 'Conservative'. If you look at [http://dbpedia.org/resource/Liberal_Democrats](http://dbpedia.org/resource/Liberal_Democrats), you'll see plenty of properties, one of which is `dbpprop:partyName`. But trying to query on `dbpprop:partyName` within the Talis data store gives me nothing, because that information hasn't been imported into the particular store that this SPARQL query is running on.

<!--break-->

What I did in `utils.php` was extend the parsing of the `tq` parameter, which is supposed to be in the Google Visualisation query language, to understand `<URI>` as a reference to a resource. In other words, you can create a query like:
  
    select mp, additionalCosts, totalTravel, totalBasic 
    where rParty = <http://dbpedia.org/resource/Conservative_Party_(UK)> 
    order by totalClaim desc 
    limit 25

and this will be mapped to a SPARQL query that looks like:

    SELECT ?mp ?additionalCosts ?totalTravel ?totalBasic 
    WHERE {
      ...
      FILTER (?rParty = <http://dbpedia.org/resource/Conservative_Party_(UK)>)
    }
    ORDER BY desc(?totalClaim)
    LIMIT 25

I don't like having done this, because I don't want Data Sources that happen to be SPARQL queries to look any different from other Data Sources. Introducing a new syntax for URI literals isn't really on.

The superficial fix is to **always provide basic labelling information for the resources referenced within a triplestore**. In this case, Leigh actually did include an `rdfs:label` property for each of the party URIs within the Guardian store, so it was possible to use the query I wanted to use after all (though it took some experimentation to find this out).

But underlying this is a bigger issue. Much is made of linked data -- that you can find out more about a particular thing by resolving the link to that thing -- but the best illustrations of the power and benefits of the semantic web tend to revolve around analysis and visualisations of moderately large amounts of data using SPARQL. And SPARQL (as yet) only runs on individual triplestores, which do not contain the entire semantic web. Every SPARQL query is limited by what has been loaded into the particular triplestore that is queried.

Now, one of the "time-permitting" requirements for SPARQL 1.1 is [Federated Queries](http://www.w3.org/TR/sparql-features/#Basic_federated_query):

> Federated query is the ability to take a query and provide solutions based on information from many different sources. It is a hard problem in its most general form and is the subject of continuing (and continuous) research. A building block is the ability to have one query be able to issue a query on another SPARQL endpoint during query execution.
>
> Time-permitting, the SPARQL Working Group will define the syntax and semantics for handling a basic class of federated queries in which the SPARQL endpoints to use in executing portions of the query are explicitly given by the query author.

That's certainly "a building block", but it can't be the only method. For many data publishers, it's going to be far far simpler to publish their data as linked data in RDF/XML than it is to provide a SPARQL endpoint for that data. We can ask organisations like [Talis](http://www.talis.com/platform) to crawl our data and provide a SPARQL endpoint for it, and hope that the SPARQL Working Group have time to address federated search, but really we need tools that make it easy to aggregate, analyse and visualise linked data directly rather than through a triplestore silo.

So how about it?
