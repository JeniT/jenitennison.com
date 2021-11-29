---
layout: drupal-post
excerpt_separator: "<!--break-->"
title: PRESTO and the limits of XPath-based URLs
created: 1205439536
tags:
- web
- xpath
---
Rick Jelliffe has been writing recently about [PRESTO][1], most recently about the [design of URLs][2] based on the PRESTO system. In his latest post, Rick talks about using XPath as the basis of a URL scheme:

> The Xpath for accessing a particular part’s title would be /law/part[2]/title so the PRESTO URLs would need some kind of convention.

> [snip]

> Now, I am not sure I understand the issues well enough to say which system for indexing is absolutely best. But I think the advantage of `http://www.eg.com/law/part2/title` over  `http://www.eg.com/law/part2/title` is that it is probably a more common case that your system is interested in `/law/part[2]/title` rather than all titles of parts `/law/part/title`. But it is a matter of the particular use case and the consequent virtual schema.

[1]: http://www.oreillynet.com/xml/blog/2008/02/presto_a_www_information_archi.html "PRESTO - A WWW Information Architecture for Legislation and Public Information systems"
[2]: http://www.oreillynet.com/xml/blog/2008/03/presto_urls_as_xpaths_to_views.html "PRESTO: URLs as XPaths to views of information"

<!--break-->

This has particular interest to me because I've recently been involved in putting some of the [UK's legislation online][3]. We don't expose the parts/sections and so on as individual documents at the moment (although this *is* something that you get with the [Statute Law Database][4], albeit with an awful URL scheme).

[3]: http://www.opsi.gov.uk/legislation/about_legislation.htm "OPSI: Legislation"
[4]: http://www.statutelaw.gov.uk/ "The Statute Law Database"

Anyway, we do have *anchors* for parts/sections within the main legislation which follow a similar scheme to the one that Rick suggests here. But they have a drawback: at least for consolidated legislation (which reflects the "current state" of legislation that has been amended by later legislation), the anchors don't reflect the semantics of the numbering scheme used by the document. For example, see [Section 5A of the Rent Act 1977][5], whose URL is:

    http://www.opsi.gov.uk/RevisedStatutes/Acts/ukpga/1977/cukpga_19770042_en_2#pt1-pb2-l1g6

[5]: http://www.opsi.gov.uk/RevisedStatutes/Acts/ukpga/1977/cukpga_19770042_en_2#pt1-pb2-l1g6 "OPSI: Legislation: Revised: Rent Act 1977: Section 5A"

As you can see, the URL ends in a 6 rather than 5A because it's the 6th Section that appears in the document.

The thing is that generic, position-based XPaths into content are seldom the ones that make most sense semantically. A friendly XPath to Section 5A would look like:

    /part[1]/group[2]/section[3]

and even if you just counted sections it would be:

    //section[6]

when what you really want is the equivalent of:

    //section[number = '5A']

Given this, I wonder if a "striped" URL scheme would be better, by which I mean something that follows the general pattern `/name/identifier/name/identifier`. For example:

    /part/I/section/5A

There are several advantages to this. The resulting URLs are more semantically meaningful than those based on positions. They are more robust to changes in the document (which naturally happen with consolidated legislation). They also provide a neat method of returning *all* the sections in a particular part, such as:

    /part/I/section

(though you could get this advantage with a position-based scheme as well, depending on how you map from XPath to URL).

The main disadvantage is that you have to provide a custom mapping from XPath to URL, because it's not immediately obvious what identifier to use for a given element: it might be a `<number>` element child for one kind of element, but an `id` attribute for another element, and the position of the child for some other element. Of course you could add annotations to your schema to indicate what acts as the identifier for that particular element type, but it does raise the implementation barrier.
