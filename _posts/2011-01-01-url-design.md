---
layout: drupal-post
title: URL design
created: 1293898688
tags:
- legislation
- uri
---
[Kyle Neath's post on URL design](http://warpspire.com/posts/url-design/) (go read it) reflects a lot of the thinking that we went through in the design of the [legislation.gov.uk URIs](http://www.legislation.gov.uk/developer/uris) and the [linked data API](http://code.google.com/p/linked-data-api) as used within [data.gov.uk](http://data.gov.uk/).

I found the section about HTML5's [History interface](http://www.w3.org/TR/html5/history.html#the-history-interface) particularly interesting. We haven't started using AJAX within legislation.gov.uk yet, but when we do, we will want to ensure that the different views these pages provide have distinct URIs, so that they remain bookmarkable and sharable. This is [progressive enhancement](http://en.wikipedia.org/wiki/Progressive_enhancement) applied to web applications at a deeper level than CSS and Javascript.

There are a couple of additional things that I think are worth drawing out.

<!--break-->

## Content Negotiation ##

It's very powerful to provide multiple formats at close variants of a given URI (preferably using [content negotiation](http://www.w3.org/Protocols/rfc2616/rfc2616-sec12.html) to serve up an appropriate one). Kyle illustrates this with the use of `.diff` and `.patch` extensions on `/pull` URIs within [GitHub](http://github.com/), which of course complement the usual HTML view.

At legislation.gov.uk, you can add `/data.xml` to provide the underlying XML for each content-bearing page and `/data.feed` to provide an Atom feed for each search result. Similarly, linked data API pages such as [http://education.data.gov.uk/doc/school](http://education.data.gov.uk/doc/school) are available in a variety of formats, by appending an appropriate extension to the end of the URI.

The biggest benefit of this approach is that the human-readable views of the information that's being presented is closely bound to the computer-readable views. This aids developers by providing context and descriptive information that helps them to better understand the data the API is providing to them, far better than separate documentation would.

A secondary benefit is that the information required to generate a human-readable version of a page is likely to be useful to other reusers of the underlying data. Basing the HTML pages of a site purely on information available via the API increases the quality of the API.

## Fragment Identifiers ##

Kyle touches on the use of [fragment identifiers](http://en.wikipedia.org/wiki/Fragment_identifier) (the bit of a URI after a `#`) to point to scrollable positions within a page, but they can be used for more than that. The important and useful thing about fragment identifiers is that they are stripped from the URI before it is submitted to the server. You can therefore have multiple fragment identifiers on the same actual page, which can then be served from a (local or intermediate or accelerator) cache without adding load to the server.

Within legislation.gov.uk, we're planning to use this technique in the presentation of the results of free-text searches. Following a search for text within legislation, the visitor will be presented with a list of items of legislation that contain sections that contain that search term. From there, they will click through to a table of contents in which the relevant sections are highlighted; this must be a standard query URI.

What we ideally want to support next is for the visitor to click through to a relevant section, and then on to the next section and so on, but ensure they can click through to the highlighted table of contents at any point. This behaviour isn't essential as the highlighted table of contents is always accessible through the Back button, and it doesn't change the actual content of the page, but it's helpful -- an enhancement of the page.

We rely heavily on caching to support the large number of visitors to legislation.gov.uk and we really don't want to have to handle the number of distinct query-based requests that we'd get for the section views that we anticipate will result from free-text searches. Equally, we don't really want to use cookies to record the original free-text query, as we would like to keep the URIs bookmarkable and sharable.

So we will use a fragment identifier of the form `#text={search}`. If Javascript is enabled, the fragment identifier will be used to rewrite the links to the table of contents and other sections. It might, in the future, be used to highlight the terms within the page or provide a status message reminding the visitor of what they originally searched for.

This technique is not uncommon in AJAX-based websites, for example the URI for my page on Twitter is [http://twitter.com/#!/JeniT](http://twitter.com/#!/JeniT). [Google treats fragment identifiers that begin with a `!` in a special way](http://googlewebmastercentral.blogspot.com/2009/10/proposal-for-making-ajax-crawlable.html), requesting `?_escaped_fragment_=/JeniT` in this case (though it seems that Twitter responds to this request with a `301 Moved Permanently` pointing to the original URI, rather than a static copy of the page that could be understood by Google).
