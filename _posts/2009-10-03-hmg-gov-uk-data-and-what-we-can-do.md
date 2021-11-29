---
layout: drupal-post
excerpt_separator: "<!--break-->"
title: hmg.gov.uk/data and What We Can Do
created: 1254578424
tags:
- linked data
- psi
- opendata
---
This week, the Cabinet Office [went live](http://blogs.cabinetoffice.gov.uk/digitalengagement/) with a preview version of [hmg.gov.uk/data](http://data.hmg.gov.uk), available only to those who subscribe to the [UK Government Data Developers Google Group](http://groups.google.com/group/uk-government-data-developers). [Harry Metcalfe](http://harrymetcalfe.com/) has written a [great review](http://thedextrousweb.com/2009/10/the-wraps-come-off-data-gov-uk/), or of course you can check it out yourselves.

Already, though, there are discussions starting on the mailing list about [how the data is being made available](http://groups.google.com/group/uk-government-data-developers/browse_thread/thread/73f1f4e8a8c2d6bb), and I'm worried that these might distract us from getting things done.

<!--break-->

There are a range of ways in which data can be made available on the web:

  * embedded in PDFs and Word documents (ie proprietary formats that make it nearly impossible to get hold of the data itself)
  * through a Web Services / RPC style interface whereby a custom API is available for each data set
  * as downloadable (possibly compressed) files in a machine-readable format such as CSV or XML
  * through a RESTful API whereby there is a URI for each resource and GETting that URI provides information about the resource, and there are also URIs for lists of resources
  * through a search interface, such as a SQL or SPARQL interface onto a database or triplestore, which may enable aggregations over multiple resources

All of us Open Data advocates agree that we need to encourage government away from the first two methods of making data "available" and towards the last three. But there's a vast array of opinion within the developer community about which of the latter three are most useful, and precisely which technologies to use in each of those categories.

What's the real answer? "All of them!"

We need the raw data because it enables us to double-check all the other interfaces which are provided to it. We need RESTful APIs. We need them to serve RDF and XML and JSON and CSV and all the other formats that people ask for. We need the data to be made available in SQL databases and NoSQL databases and triplestores; we need access to SQL queries and SPARQL queries and map/reduce processing. All of that, all of them, and more.

This is not a [zero-sum game](http://en.wikipedia.org/wiki/Zero-sum). Just because someone makes [edubase](http://www.edubase.gov.uk/) available on the [Talis platform](http://www.talis.com/platform) through a SPARQL interface does not prevent someone else making it available on [Amazon S3](http://aws.amazon.com/s3/). The more methods of access there are, the more widely available and therefore useful the data is. The more things we try, the more lessons we learn, the better we get.

One thing is certain, though: the government cannot do all of this itself. They simply don't have the resources or expertise. If we think something's important, we can help by doing it. And we can help them, and each other, by sharing both the results of our work (so that others can build on it) and how we got them (so that others can follow the same patterns for other datasets). That, as far as I'm concerned, is what hmg.gov.uk/data is for.

Whatever our technology preferences, we can help each other by sharing our results whenever we:

  * clean up the data that the government have supplied
  * analyse the data (which is often in de-normalised formats)
  * find areas of commonality between different data sets
  * transform the data into other formats
  * build other types of APIs on top of the ones others have constructed

The hmg.gov.uk/data has a certain bias towards Linked Data, it's true, and this should come as no surprise [given its advisors](http://blogs.cabinetoffice.gov.uk/digitalengagement/post/2009/06/09/Data-So-what-happens-now.aspx). But whichever side of that particular argument we're on, we're shooting ourselves in the feet if we assert that this is an exclusive choice.
