---
layout: drupal-post
title: Distributed Publication and Querying
created: 1269293213
tags:
- linked data
- sparql
---
One of the biggest selling points of linked data is that it's supposed to facilitate web-scale distributed publication of data. Just as with the human web, anyone can publish data at their local site without having to go through any kind of central authority.

Just as with the human web, convergence on particular sets of URIs for particular kinds of things can happen in an evolutionary way: in a blog post I might point to Amazon when I want to talk about a particular book, Wikipedia to define the concepts I mention, people's blogs or twitter streams when I mention them.

And with everyone using the same terms to talk about the same things, there's the prospect of being able to easily pull together information from completely different sources to find connections and patterns that we'd never have found otherwise.

What's been very unclear to me is how this distributed publication of data can be married with the use of SPARQL for querying. After all, SPARQL doesn't (in its present form) support federated search, so to use SPARQL over all this distributed linked data, it sounds like you really need a central triplestore that contains everything you might want to query.

This post is an attempt to explore this tension, between distributed publication and centralised query, and to try to find a pattern that we might use within the UK government (and potentially more widely, of course) to publish and expose linked data in a queryable way. It's a bit sketchy, and I'd welcome comments.

<!--break-->

## Publishing Datasets ##

First, let's look at the publication of data. We publish data at the moment in all kinds of ways: embedded tables within PDFs, CSV database dumps, Excel spreadsheets, Word documents, XML, JSON, N3 and so on and on. Each of these documents contains a set of information: a dataset.

Each dataset contains information about a whole load of *things*, usually real-world things. This is easy to see when you have datasets that contain lots of things of the same type: a spreadsheet might contain information about lots of different local authorities, a database dump about a bunch of schools. In FOAF terms, we'd say that the dataset has each of these things as a *topic*.

Even datasets that are really about one *thing* (have, in FOAF terms, a *primary topic*) contain information about lots of other things. For example, a web page about a hospital might include some level of information about the different departments within the hospital, the strategic health authority that it belongs to, the chief executive and so on. Information that is just about one thing is rarely useful; at the very least, you will want to know the labels of things that it's related to.

If we move to thinking about linked data, each *thing* is assigned an HTTP URI. There is then one particular dataset that stands above all the other datasets that contain information about that *thing*: the dataset in the document that you get when you resolve its URI. The fact that there is this dataset doesn't alter the fact that there are many many other datasets out there that contain information about the *thing*. But the dataset that you get at the URI for the thing obviously has a special role.

These datasets -- the ones you get at the end of a resource's URI -- are *the* way in which an organisation can exercise control over the use of URIs minted within their domain. The organisation that controls the URI for a *thing* determines whether that URI resolves, and what is at the end of the URI. If fifteen different websites all published information about a school consistently using the same URI for that school, anyone could pull that information together into something potentially useful. But if the URI for the school doesn't actually resolve, then you would have to wonder whether the school actually exists, or if it's just a figment of the imagination of those fifteen websites: a spoof school.

Also, you'd expect the information that you find at the end of the URI to be correct and up to date. You'd expect it to be reasonably complete as well: to return a bunch of information about the school and pointers to more information about the school. This information is likely to come from a bunch of trusted sources: an integrated view over a collection of other datasets.

## Providing SPARQL Endpoints ##

We've established that

  * anyone can publish information about anything they choose, but that people will have different levels of trust in different sources of information
  * information about any one *thing* is seldom useful on its own; the power of the linked data web is the ability to make connections between things

And so on to querying. Linked data can be useful without explicit querying -- you can navigate around related sets of information by following links, and pull together information gleaned from different sites -- but querying of some kind provides much more potential power and, with a [linked data API](http://purl.org/linked-data/api/spec), the opportunity to provide an easy-to-use web-based API for the data.

SPARQL queries operate over a default graph (or dataset) and a set of supplementary named graphs. For efficiency, these need to be pulled into a single triplestore.

And so we have a quandry. To support queries, we need all the data we might want to query to be pulled into a single triplestore. Given that all data is linked, and all links are potentially interesting, the only answer seems to be to have the whole web of data in a single store. And that kind of centralised solution seems impractical, both in terms of the sheer size of store you'd need and the obvious impact on efficiency of doing so.

## Curated Triplestores ##

I think the answer (for the moment at least) is to forget about querying the entire web of linked data and focus on supporting the easy creation of targeted, curated, triplestores that each incorporate a useful subset of the linked data that's out there. What subset is useful for a given triplestore is a design question that should be informed by the potential users of that particular service. Larger subsets are likely to locate more cross-connections, but have a performance penalty.

For example, a service that was oriented towards helping local authorities plan their schooling provision might include all the current data about nursery, primary and secondary schools (but not universities or versioned data), information about their administrative district and the district that they appear in (but no extra information about census areas), and those neighbourhood statistics, including historic data, that relate to children and schooling (but not those that relate to care of the elderly, for example).

Another service might include all historic information about schools and universities and historic information about all associated administrative geography, but not include neighbourhood statistics.

## Supporting On-Demand Triplestores ##

In the scenario painted above, each triplestore will include different datasets, brought together for a particular purpose. Imagine a huge warehouse full of boxes, each of which is a particular dataset. Each triplestore will fit together a different set of those boxes. What's neat about the linked data approach is that the boxes are really easy to bring together: creating a triplestore should just be a matter of selecting which datasets you want to use with little or no hand-crafting of links between them or resolution of naming conflicts.

The challenge from the side of the data publisher is to enable these triplestores to be both created and kept up to date. A data publisher has to:

  * describe what datasets are available
  * describe how these link to other potentially interesting datasets, to give hints about where connections might be made
  * provide a mechanism for getting the current state of all the available datasets (which can obviously be through crawling but could alternatively be through a dump or set of dumps)
  * provide a mechanism for informing interested parties about new datasets being made available (which could be through routine crawling or through a feed)
  * provide a mechanism for informing interested parties about when a dataset changes (which could also be through routine crawling or through a feed)

A lot of these problems are solved.

[VoiD](http://rdfs.org/ns/void/)'s purpose in life is to describe datasets and how they link to each other, and it provides a `void:dataDump` property that points to a dump of the data. VoiD can describe datasets that are supersets of other datasets, which enables datasets to be grouped together into potentially useful bundles.

Where information needs to be kept up to date, we can use feeds. We need to keep up to date information about the datasets that a publisher makes available, and information about the content of a particular dataset. This can be achieved through a single Atom feed in which each dataset is recorded as an entry, with an `<updated>` element indicating its last update. Datasets that are removed can be indicated through a [`deleted-entry` element](http://tools.ietf.org/html/draft-snell-atompub-tombstones-06). There is some ongoing work that suggests how to [augment voiD with a pointer to such a feed](http://groups.google.com/group/dataset-dynamics/web/components-vocabularies-protocols-formats).

As well as pointing to a dataset, and indicating that it has been updated, the Atom feed could contain information about the change itself, represented as a [changeset](http://vocab.org/changeset/schema.html). This could be included as part of the information provided about the new version of the dataset, described in terms of its [provenance](http://www.jenitennison.com/blog/node/142).

Feeds that were provided in this way could be provided using the normal model, whereby any interested triplestores would regularly check the feed for updates, or using [PubSubHubbub](http://code.google.com/p/pubsubhubbub/) in order to push notifications to triplestores. The latter would require triplestore providers to support a service that accepted such notifications, of course.

A triplestore should expose which datasets (and which versions of those datasets) are used within the triplestore. This can be gathered through a SPARQL query to list the available graphs and their metadata, so long as that information is included within the named graphs themselves.

## What Should We Do? ##

How does all this translate into what guidelines we should put into place for UK government publishers and what tools we should provide centrally?

First, we need to recognise the responsibility that comes with the ownership of a URI. Within the UK, we are encouraging people to use URIs of the form:

    http://{sector}.data.gov.uk/id/{concept}/{identifier}

to name things like schools and hospitals, with the recognition that information about those things might come from many different public bodies. *Someone* has to be in charge of that domain: they have to determine which URIs within a particular URI set are resolvable, and what information is provided at the end of each URI. These same sector owners should support easy-to-use APIs based around the particular URI sets that they are responsible for.

The easiest route to supporting the pages, an easy-to-use API, and a SPARQL endpoint for deeper querying is going to be to create a curated triplestore with a [linked data API](http://purl.org/linked-data/api/spec) layer over the top. This triplestore will need to be populated with data from multiple datasets, both as separate named graphs (to provide traceability back to the original data) and merged into a default graph that reflects the current state of the world.

The precise datasets that are included within the triplestore will depend on the judgement of the sector owners about both the trustworthiness of the available datasets and their utility. For example, it's likely that a lot of triplestores will want to include information about administrative geography and perhaps some information about time, simply because everything happens somewhere and sometime.

Second, we need to make this process really easy, through guidelines and tooling.

We encourage the data owners themselves (which are individual public bodies) to publish, along with the datasets themselves:

  * voiD descriptions of the groups of datasets that they publish
  * metadata about the individual datasets that they publish (within each dataset itself)
  * Atom feeds that are updated each time datasets are added, removed or altered, preferably including changeset information
  * (optionally) dumps of groups of datasets, in NQuads format
  * (optionally) notifications of changes to the Atom feed to a PubSubHubbub hub

Data owners should be able to split up the datasets that they provide into different groups based on their knowledge of the domain, with the possibility of individual datasets belonging to more than one group.

We then create tooling that can:

  * enable the sector owners to quickly and easily put together a list of trusted sites from which datasets can be gathered
  * collect datasets from these sites, either through NQuads dumps or through crawling
  * merge datasets to create a default current view
  * put these datasets into a triplestore
  * keep the triplestore up to date, either through polling feeds or by accepting PubSubHubbub notifications to identify changes, applying those changes, and merging data as required
  
To facilitate PubSubHubbub use, which supports timely updating of triplestores, we'd need a PubSubHubbub hub. Data owners can inform this hub of updates to their feeds and sector owners can register interest in particular feeds.

These guidelines and tooling are not just useful for sector owners: they are useful for anyone who wants to pull together linked data published in a distributed way across the web. We should expect and encourage multiple stores offering different combinations of datasets and different levels of service. The ones offered centrally, by sector owners, are certainly not the be-all and end-all -- in fact we should look on them as a basic level of service, to be superseded by the community.
