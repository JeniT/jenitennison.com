---
layout: drupal-post
excerpt_separator: "<!--break-->"
title: On Resolvability
created: 1251496936
tags:
- rdf
- rdfquery
- html5
- linked data
---
In my [last post about RDFa and HTML](http://www.jenitennison.com/blog/node/124) I talked about how one of the gulfs that separates the HTML5 and Semantic Web communities is the attitude to the resolvability of property (and class) URIs.

I'm currently experimenting with introducing the ability to automatically locate information about properties and other resources that are referenced within triples to [rdfQuery](http://code.google.com/p/rdfquery), so now is a good time, as far as I'm concerned, to look more closely at what the ability to resolve properties gives you and how to avoid problems if the property URI is (temporarily or permanently) unresolvable or resolvable to something new.

I'm going to attempt to answer:

  * How do or might applications use property and class URIs?
  * How can data and ontology publishers assist them in doing so?
  * What should frameworks (such as rdfQuery) do to help application developers?

<!--break-->

## Application Developers ##

We can divide applications using online data into three general categories:

  * **data-specific applications** are constructed around particular data sets that are known to the developer of the application; the [visualisations](http://www.jenitennison.com/blog/node/125) [that](http://www.jenitennison.com/blog/node/123) [I've been](http://www.jenitennison.com/blog/node/119) [doing](http://www.jenitennison.com/blog/node/113) are examples of data-specific applications
  * **vocabulary-specific applications** are constructed around particular vocabularies, wherever the data might be found that uses them; [Google's Social Graph API](http://code.google.com/apis/socialgraph/) and [Yahoo! SearchMonkey](http://developer.search.yahoo.com/start) are examples
  * **generic applications** are constructed to navigate through any RDF that they find; [Tabulator](http://www.w3.org/2005/ajar/tab) is one example

Most mashups are data-specific applications. When you, as a developer, create a data-specific application, the thing that you need to know most of all is what information the dataset contains. Part of that is working out the meaning of a particular property (or class). What the data publisher needs to do is make sure that the data they publish is documented.

There are three ways of locating the documentation about a particular property or class:

  * looking through the general documentation the data publisher has provided
  * resolving the URI of the class or property
  * searching

For a developer, it's very useful to find out about a property by bunging its URI into a browser and hitting return. Want to know what `http://xmlns.com/foaf/0.1/name` means? Look up that URI. By comparison, if you want to know what a `vevent` is, your best bet is a search engine. In the results I get from Google, the microformat definition of `vevent` is currently second on the list. (The Microdata definition of `vevent` doesn't even feature.) **Even if a property isn't available at its URI, its URI gives a more unique identifier to search for than an short term**: you're more likely to find relevant information if you search for `http://xmlns.com/foaf/0.1/name` than if you search for `name`.

But there's no requirement for data-specific applications to use computer-readable information about properties or classes. If you know the data that's available in a dataset, you can find out the semantics of the properties and classes it contains and hard-code those within your application. Most applications that reuse data are currently of this type, and it tends to be the only kind that non-Semantic Web people think about.

Vocabulary-specific and generic applications will have some vocabularies built in but may also operate with unknown vocabularies. For example, an application that cares about FOAF profiles is almost certainly going to want to hard-code information about FOAF rather than download its schema every time it's used. 

There are three reasons for building-in knowledge about particular vocabularies:

  * some information about a vocabulary simply can't be represented in a schema or ontology; if you want special handling for particular properties, you're going to want to hard-code it
  * downloading, parsing and interpreting a schema that you know you're going to need every time you run the application is really inefficient
  * relying on the network to provide information about a vocabulary you know you're going to need makes your application fragile, especially if you do not have control over the publication of the schema yourself
  
> *It's worth noting that applications increasingly do rely on the availability of networked resources in order to operate -- that's what [cloud computing](http://en.wikipedia.org/wiki/Cloud_computing) is all about -- but the resources are usually ones that the application developers have some kind of control over.*

**It helps to use URIs for properties and classes for well-known vocabularies only in as much as it means that property and class names from different vocabularies won't clash**, so you don't have to worry about your application confusing `http://xmlns.com/foaf/0.1/title` with `http://purl.org/dc/terms/title`.

On the other hand, if data uses an unknown vocabulary, vocabulary-specific and generic applications would like to get hold of extra information. This falls into three categories:

  * **human-readable information** includes things that help with the display of data, such as human-readable labels for properties and classes; the expected datatype of the values of a property might also fall into this category
  * **mapping information** helps applications map unknown properties and classes onto known ones; for example, if `http://people.example.org/ontology/fullName` is defined as a sub-property of `http://xmlns.com/foaf/0.1/name` then the application can use or display the value of `http://people.example.org/ontology/fullName` in exactly the same way as the value of `http://xmlns.com/foaf/0.1/name`
  * **reasoning information** helps applications draw further conclusions about the resources for which there's information based on what they already know; for example, if `http://people.example.org/ontology/fullName` has a domain of `http://xmlns.com/foaf/0.1/Person` then anything that has the property `http://people.example.org/ontology/fullName` must be a `http://xmlns.com/foaf/0.1/Person`

These are in descending order of priority: many applications will want to interact with the user in some way, in which case human-readable information is vital. Applications that have built-in knowledge about one or more vocabularies are likely to have special handling for those vocabularies, so being able to map unknown properties and classes into those known vocabularies will enhance the behaviour of the application, although it adds a bit of complexity in the implementation to do so. Further reasoning has the potential to increase the value of sparse data but again increases the complexity of implementation.

**Using URIs for classes and properties provides a mechanism for applications to get hold of this extra information about unknown vocabularies**. They might try four tactics, in order of priority:

  * **look at the data they already know**; the information they need about the unknown properties and classes may be included in the files they've already accessed (including those containing data)
  * **look in an application-specific (possibly cloud-hosted) cache** of vocabularies that the application has already downloaded
  * **resolve the URI** of the class or property by performing an HTTP GET (and add it to the application-specific cache)
  * **look in a general-purpose cache**, such as [the Internet Archive](http://www.archive.org/) or an ontology repository such as [Swoogle](http://swoogle.umbc.edu/)

Robust applications will not break if they don't manage to locate the definition of a property or class. They can certainly continue to parse any data that they come across. To create a human-readable label, they might use the part of the URI after the last `#` or `/`. It's no loss (to the application) if they cannot perform other reasoning: they might display the data in some default way or simply ignore it.

It's worth noting, because of the fear of [DDoS attacks](http://en.wikipedia.org/wiki/Denial-of-service_attack) that some people have, that the majority of applications won't need to actually `GET` property or class URIs, either because they are data-specific applications or because they only work with vocabularies that are hard-coded into them. Applications that are good web citizens will avoid DDoS attacks on popular vocabularies by hard-coding knowledge about those vocabularies and/or maintaining a cache, either locally or in the cloud, of vocabularies that have already been resolved.

## Publishers ##

With what I've said above in mind, what can publishers do to help applications to understand the data that they provide?

If a publisher is only concerned about data-specific, point-to-point mashups, all they *have* to provide is the data itself. It will help developers if there is some documentation of the dataset and the properties and classes used within it. But data publishers who only want their data to be discoverable by *people* can rely on human intelligence for locating information, and for them using URIs for properties and classes may seem like overkill.

But in a linked data world, publishers should really support their data being discovered automatically via the links from other data. Here we're talking about making life easier for vocabulary-specific and generic applications to use the data that you provide.

The vocabularies that you use within your data fall into three general categories:

* **well-known vocabularies** are vocabularies that are commonly enough used that vocabulary-specific and generic applications are likely to have them built-in; these vocabularies tend to be useful across domains, such as FOAF, which is useful whenever you want to express information about people or organisations
* **local vocabularies** are vocabularies that are specific to the dataset that you are publishing; you have as much control over their publication as you do over the publication of the data itself
* **reused vocabularies** are vocabularies that you are using that are owned by other people but that do not have the take-up of well-known vocabularies; these are typically domain-specific; one example is [Metalex](http://www.metalex.eu/), which is a vocabulary about legislation

As a data publisher, the first thing you can do is to **use well-known vocabularies in your data wherever possible**, even if you also use local or reused vocabularies to express the same properties or classes.

For example, say you have some data describing a cricket team and use `http://cricket.example.org/ontology#name` for the name of a member of a team, and that you mean it to be a sub-property of `http://xmlns.com/foaf/0.1/name` (which is itself a sub-property of `http://www.w3.org/2000/01/rdf-schema#label`). If you *just* publish the `http://cricket.example.org/ontology#name` property then the only way that a generic application can know that `http://cricket.example.org/ontology#name` can be used as a label for a resource (which is a person) is by attempting to resolve `http://cricket.example.org/ontology` and reasoning based on what it finds. On the other hand, if you *also* provide `http://xmlns.com/foaf/0.1/name` and `http://www.w3.org/2000/01/rdf-schema#label` properties, applications are no longer dependent on the network, nor on having the ability to reason, to use that information.

You *could* also provide mappings onto any reused vocabularies that you specialise, but this is less worthwhile given that vocabulary-specific and generic applications are unlikely to understand them either. 

The second thing you can do is to **include information about the properties that you use within the data that you publish**. This isn't important for well-known vocabularies (because they're... uh... well-known) and it's only useful for local vocabularies if you're not publishing those vocabularies, because if someone can access your data, odds are they're able to access your local vocabulary's property URIs as well. But it is useful for reused vocabularies, where you can't guarantee access, in just the same way as it's useful to provide basic labelling information about any resources you reference.

> *If you're publishing your data embeddded within a web page, as well as marking up the **data**, you can mark up the **labels** that you use for those values, which more than likely appear as headings in a table or something similar.*

If you are publishing a schema or ontology that describes your properties and types, there are also things that you can do to help applications. The most important thing is to assist caches in their caching of the ontology, which will reduce the number of times that it needs to be accessed directly and help you avoid DDoS attacks: see [Mark Nottingham's Caching Tutorial](http://www.mnot.net/cache_docs/). You can also reduce the number of hits on your server by using hash URIs for your property and class names and use standard load-balancing techniques to manage the traffic.

If you're referring to reused vocabularies within your own, you can also embed information about the relevant properties and classes from those vocabularies within your own ontology. This can save applications an extra hop, and lessens the risk of the reused vocabulary disappearing (perhaps forever).

If you want to help people who might reuse your ontology, you can make the process of copying it easier by publishing it as a single file, or broken up into segments that are likely to be reused individually. At a non-technical level, it's also a good idea to provide a announcement mailing list or a feed so that people who reuse your vocabulary can be kept up to date with any changes you make to it.

## Framework Developers ##

Bearing all this in mind, what should I (and other framework developers) do to support the reusers of data? I think I need to make it easy for application developers to:

  * load in known ontologies from known locations
  * hard-code relevant semantics in the script
  * create catalogs that map known property or class names onto known locations of documents that contain details about them
  * use caching proxies when accessing unknown vocabularies
  * access vocabularies directly at the relevant URI
  * fallback on archives when the URI cannot be found

In other words, I need to make it easy for people to use a range of strategies for getting hold of information about a property or class, aside from simply trying to access it at its URI. I think that means that it's better to provide a lightweight solution, giving developers the opportunity to be in control of which URIs get resolved rather than automatically downloading extra information from the URI that's actually used for the property or class. It also means I need to provide hooks in the code that they can use to trigger that resolution.

It would also be useful, of course, for developers to be able to use information about properties and classes easily, in particular to reason with it. That kind of support is something I've been working on for rdfQuery. It's not quite ready yet.

## Conclusions ##

My (somewhat contentious) view is that we place too much emphasis on the resolvability of property and class names, and that this can put people off the idea of the Semantic Web. You can do useful things with data without resolving properties or classes. And for a large number of useful applications, being able to actually *reason* over the data you get at the end of a property URI would have a high implementation cost without providing a great deal of functional benefit. 

Further, for data publishers, the requirement to enable the resolution of every property and class URI you use within your data just adds to the publishing burden, especially if you're made to feel it has to resolve to some kind of grand OWL ontology.

There's a concept in psychology of the [zone of proximal development](http://en.wikipedia.org/wiki/Zone_of_proximal_development). The idea is that if someone is operating at a particular level then as a teacher you should help them to achieve something *slightly* above that level, rather than trying to get them to do everything straight away.

The same is true here. We need to help publishers make the small steps that they can make, one at a time, to gradually get them to full Semantic Web goodness:

  1. publish a dataset in some kind of open format (CSV, XML etc) so that people can get hold of it
  1. publish the data with distinct URIs for distinct resources so that people can reference them
  1. publish the data in a machine-readable format so that people can easily reuse it
  1. publish the data in a way that can be interpreted as RDF, with URIs for properties and types, to avoid conflicts with other vocabularies and so that the data can be "understood" even when discovered automatically
  1. put some human-readable documentation at the end of the property/type URIs, so that developers can easily discover what your data's about
  1. embed machine-readable labels and descriptions for your properties/types within your data, so that applications can display it
  1. embed `rdfs:subPropertyOf`/`rdfs:subClassOf` mappings from your properties/types to well-known properties/types within your data, so that it can be displayed in custom ways
  1. put the machine-readable information about the properties/types at the end of the property/type URIs, so that you can update your vocabulary easily and so that other people can reuse it
  1. add other RDFS and OWL statements about the properties/types, so that reasoners can add value to your data

The biggest leap, the one that requires the most persuasion and the most justification, is probably from simply publishing the data in a machine-readable format to using the RDF model with URIs for properties and types. But if you remove the cost of having to provide anything at the end of the URI and factor in the potential benefits you may reap in the future (as you step further up that ladder), the question becomes less "why?" and more "why not?".
