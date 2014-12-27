---
layout: drupal-post
title: My Perfect XML-Based Publishing Platform
created: 1243633220
tags:
- pipelines
- xml
- rest
- xquery
---
For the last several months, I've been working on a project at [TSO](http://www.tso.co.uk/) for publishing [UK legislation](http://www.opsi.gov.uk/legislation) using a native XML database (eg [eXist](http://www.exist-db.org/) or [MarkLogic Server](http://www.marklogic.com/)) with some middleware (eg [Orbeon](http://www.orbeon.com/) or [Cocoon](http://cocoon.apache.org/)). It's a powerful and flexible approach that's built on declarative languages like XQuery, XSLT, and XML pipelines; you can see it in action with the [Command and House Papers demo](http://sandbox.opsi.gov.uk/).

But the killer platform isn't quite here yet, partly because the specs aren't quite done. Both Orbeon and Cocoon use XML pipelines, but they use different languages to define them; [XProc](http://www.w3.org/TR/xproc/) is just around the corner. XML databases are all over the place in their conformance to XQuery, its optional features and the not-quite-finalised specs for free-text searching and updating.

People talk about how productive you can be using [Ruby on Rails](http://rubyonrails.org/) or [Django](http://www.djangoproject.com/), and they work great for publishing data you can store in a relational database. What *we* need is a similarly easy-to-use platform for document-oriented, XML-based content. This is my wish-list.

<!--break-->

The killer platform would have a configuration mechanism for mapping HTTP requests that it receives onto XProc pipelines. The pipeline that would be used could be based on one or more of:

  * the HTTP method
  * the requested URI
  * any HTTP header
  
The pipelines would have a signature like:

  * a primary 'source' input that encodes the HTTP method, headers and body of the request; this would use the `<c:request>` element used within the [`p:http-request` XProc step](http://www.w3.org/XML/XProc/docs/langspec.html#c.http-request)
  * a parameter input populated by parsing the URI against a simplified version of [URI templates](http://tools.ietf.org/html/draft-gregorio-uritemplate-03)
  * a primary 'result' output that is an XML version of the response body
  * a 'response' output that encodes the HTTP status code and headers of the response; this would use the `<c:response>` element used within the `p:http-request` XProc step
  * a 'serialize' output that holds a `<c:parameters>` element containing parameters for serializing the result body; possible serialisations would include serialising XSL-FO as PDF and SVG as JPEG, for example.

The pipeline engine would of course include efficient implementations of all the required steps, most importantly XSLT 2.0.

The platform would have an easy mechanism for invoking queries on its XML store through an implementation-defined step that was similar to the [`p:xquery` XProc step](http://www.w3.org/XML/XProc/docs/langspec.html#c.xquery). The step might have the signature:

  * a primary 'query' input for the query itself (like the 'query' input for `p:xquery`)
  * a parameter input for specifying the values of external variables within the query
  * a 'database' option for specifying the database to query
  * a primary 'result' output for the result of the query, this being a sequence of documents resulting from the query

The XML store itself would support:

  * [XQuery 1.0](http://www.w3.org/TR/xquery/), with no extensions to the syntax except those permitted by that specification
  * [XQuery and XPath Full Text 1.0](http://www.w3.org/TR/xpath-full-text-10/)
  * [XQuery Update Facility 1.0](http://www.w3.org/TR/xquery-update-10/)

It would also support setting up indexes on any expression for a particular kind of context node (usually an element); these would work like keys in XSLT, except that the XQuery engine would automatically detect when the index could be applied. For example, it would be possible to set up a key on a document for the expression `substring(//dc:identifier, 7, 2)` and if the query used exactly this expression, the index would be used.

The platform would provide an extensible architecture such that it would be possible to set up replicated XML store(s) on separate servers from the main pipeline engine. It would cache the results of queries against the XML store. It would serve up static content such as images and scripts bypassing the pipeline. It would be configured using files, so that it was easy to transfer a configuration between development and production platforms and to version control configurations through normal means.

Have you used (or developed!) anything that comes close? What's on your wish-list?
