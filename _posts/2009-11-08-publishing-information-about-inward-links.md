---
layout: drupal-post
excerpt_separator: "<!--break-->"
title: Publishing Information About Inward Links
created: 1257708620
tags:
- legislation
- linked data
---
In the Linked Data world, we talk a lot about having URIs that are identifiers for things, and making them HTTP URIs so that they can be dereferenced and people can find *more* information about those things.

This raises the questions of "what information should you publish?" Let's make this concrete by using a real example: [UK Legislation](http://www.opsi.gov.uk/legislation-api/), which 
[TSO](http://www.tso.co.uk/) is publishing for [OPSI](http://www.opsi.gov.uk/) as Linked Data.

UK Legislation now has a set of URIs that are explicitly intended to be used as unique identifiers for items of legislation and parts, sections, subsections and so on within them. If you request one of these URIs, requesting RDF/XML, you will get some information about that bit of legislation, such as:

  * bibliographic metadata such as its title, publisher, created date and so on
  * links to other related sections or items of legislation
  * links to particular versions of that bit of legislation

So we provide some basic information, and the links we know about, ie those within UK Legislation.

It turns out that lots of things aside from UK Legislation reference legislation, and that when you publish information about them it's helpful to be able to point to the relevant legislation. For example:

  * the Home Office relate offences to sections of legislation that state that a particular activity is illegal and has a certain maximum penalty
  * local authorities are bound to provide certain services by law, so there's a natural pointer from the definition of a service to that law
  * administrative areas such as counties and local authorities are defined by law, so when the Ordnance Survey publish information about those areas, it helps to point to the law in which their names are legally defined as the authority on which their statements are based
  * the publication of notices posted within the London Gazette is enforced by legislation, and the text of the notices usually indicates which piece of legislation caused the notice to be published
  
These are all inward pointers. As we publish information about UK Legislation, we won't know about all these links to the information we publish. But people who access information about UK Legislation might well want to know about those links. Wouldn't it be useful to know -- given an item of legislation -- what it makes illegal, what it compels local authorities to do, which administrative areas it defines, which notices it has caused to be published?

We were discussing the same issue the other day in respect of spatial objects. The Ordnance Survey, or other organisations peddling spatial data, may define spatial objects, but other people define the things that those spatial objects represent, such as schools, roads, parks and so on. It's obviously useful to go from a school to the spatial objects that represent its buildings, but it would also be useful to go from a spatial object that is a school building to the school.

So what should we, as publishers, do about the inward links (that we know about)? When we publish information about something should we also try to publish information about the things that (we know) reference that thing? I think the answer's "yes," at the very least in any human-readable access we give to the information. And from that come two further thoughts:

  * If you are publishing data with outward links, it would be a good idea to provide feeds or other mechanisms that enable people to pull in basic information about the things that you're publishing that link to something they're publishing. SPARQL queries would do, but something a bit less general purpose and more approachable -- I'm thinking a URL like `http://example.org/links?url=http://example.net/linked/resource` -- would be better.
  
  * Information from another source is going to have different provenance/trust etc characteristics than the primary information you publish. That needs to be clearly indicated *somehow*; sounds to me like a requirement for named graphs.
