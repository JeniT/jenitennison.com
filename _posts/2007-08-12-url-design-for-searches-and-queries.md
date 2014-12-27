---
layout: drupal-post
title: URL design for searches and queries
created: 1186956000
tags:
- atom
- rest
---
Another [fascinating post from Bill de hÓra][1], this time on URL design for resources:

> Let's take editing some resource, like a document, and let's look at browsers and HTML forms in particular, which don't a do a good job of allowing you to cleanly affect resource state. What you would like to do in this suboptimal environment is provide an "edit-uri" of some kind. There are basically 5 options for this; here they are going from most to least desirable

>   1. Uniform method. Alter the state by sending a PUT to the document's URL. The edit-uri is the resource URL. URL format: http://example.org/document/xyz
>   2. Function passing. Allow the document resource to accept a function as an argument. URL format: http://example.org/document/xyz?f=edit
>   3. Surrogate. Create another resource that will accept edits on behalf of the document. URL format: http://example.org/document/xyz/edit
>   4. CGI/RPC explicit: send a POST to an "edit-document" script passing the id of the document as a argument. URL format: http://example.org/edit-document?id=xyz
>   5. CGI/RPC stateful: send a POST to an "edit-document" script and fetch the id of the document from server state, or a cookie. URL format: http://example.org/edit-document

[1]: http://www.dehora.net/journal/2007/08/web_resource_mapping_criteria_for_frameworks.html "Bill de hÓra: Web resource mapping criteria for frameworks"

<!--break-->

My current task at work is to look at how to add [RDFa][2] to a website that is completely driven by "CGI/RPC explicit" URLs. That includes URLs for the resources themselves, by the way, we're not even talking about edit URLs here. Take a look at the URL for [this page][3], for example (this isn't the actual website that I'm working on, but it's more or less the same in terms of URL design). The URL is

    http://www.statutelaw.gov.uk/content.aspx?LegType=All+Legislation&title=wine&Year=2007&searchEnacted=0&extentMatchOnly=0&confersPower=0&blanketAmendment=0&sortAlpha=0&TYPE=QS&PageNumber=1&NavFrom=0&parentActiveTextDocId=3032571&ActiveTextDocId=3032571&filesize=16218

[2]: http://www.w3.org/TR/xhtml-rdfa-primer/ "W3C: RDFa Primer"
[3]: http://www.statutelaw.gov.uk/content.aspx?LegType=All+Legislation&title=wine&Year=2007&searchEnacted=0&extentMatchOnly=0&confersPower=0&blanketAmendment=0&sortAlpha=0&TYPE=QS&PageNumber=1&NavFrom=0&parentActiveTextDocId=3032571&ActiveTextDocId=3032571&filesize=16218 "Statute Law Database Legislation"

So here I am trying to construct RDF examples, and all the URLs look like this mess. What URI am I supposed to use in RDF to talk about the resource itself, rather than a particular view (table of contents, actual content, etc) of that resource?

In this case, the thing that identifies the resource in the URL is the value of the `ActiveTextDocId` request parameter: you can do

    http://www.statutelaw.gov.uk/content.aspx?ActiveTextDocId=3032571

and see the same legislation; this could be mapped to a resource-oriented URL such as

    http://www.statutelaw.gov.uk/legislation/3032571

very easily. It isn't, but it could.

However, doing that, you do lose some context about what the original search was that led you to this page. In the case of the above URI, the fact that I searched for all 2007 legislation with "wine" in the title gets lost. And this is important because the [breadcrumb][5] on the page has to take me back to that original search.

[5]: http://www.statutelaw.gov.uk/content.aspx?LegType=All+Legislation&title=wine&Year=2007&searchEnacted=0&extentMatchOnly=0&confersPower=0&blanketAmendment=0&sortAlpha=0&TYPE=QS&PageNumber=1&NavFrom=0&parentActiveTextDocId=3032571&ActiveTextDocId=3032571&filesize=16218#breadcrumb "Breadcrumb on legislation page"

Now, you could argue that this is bad website design: after all, you can navigate back to a search page using \*gasp\* the **Back** button, and not doing so just adds unnecessary items to your history. But what about providing **previous** and **next** links for navigating through the items found in a search? There, surely, you do need some state information that indicates how we got to this particular item?

Well, no. When you're navigating through the results of a search, the primary resource that you're viewing is the *collection* of items that have been identified by the search. Even if you're just viewing one of the items in that collection, if the collection still matters then that item should be viewed as just a subresource of the collection.

In this case, the search has three fields -- title, year and (legislation) number -- so the search URL has three parts after the initial one. The general scheme (using [URI template syntax][4]) is

    http://www.statutelaw.gov.uk/search/{title}/{year}/{number}

[4]: http://bitworking.org/projects/URI-Templates/draft-gregorio-uritemplate-01.html "URI Template Internet-Draft"

So here, I could use

    http://www.statutelaw.gov.uk/search/wine/2007/_

as a URL that would give me a list of all the 2007 legislation with any number whose title contained "wine", and then

    http://www.statutelaw.gov.uk/search/wine/2007/_/1

would show me the first piece of legislation found in the context of that search, with a **next** button taking me to

    http://www.statutelaw.gov.uk/search/wine/2007/_/2

An individual resource itself could occur in many searches, and thus you would get many URLs for the resource in the context of those particular searches, but that's OK so long as there is one URI that identifies the resource itself. You should link to the actual resource from the page, of course, both in a `<link>` in the header and a `<a>` in the body (it feels like there should be a "this is the real resource" value for the `rel` attribute of `<link>` or `<a>`, but I don't know of one).

The kind of URL above works fine when you have a fixed number of fields for searches, but what if you're doing more complicated searches: something that requires a proper query language? Well, you can stuff a query language into a URL. See [Dare Obasanjo's comparison of Google and Astoria APIs for queries][6] to see what that looks like.

[6]: http://www.25hoursaday.com/weblog/2007/07/13/GoogleBaseDataAPIVsAstoriaTwoApproachesToSQLlikeQueriesInARESTfulProtocol.aspx "Dare Obasanjo: Google Base Data API vs. Astoria: Two Approaches to SQL-like Queries in a RESTful Protocol"

Alternatively, several years ago Paul Prescod introduced me to the notion that the query itself is a resource -- it's something that you'll probably want to save and edit -- and can be assigned a unique identifier in the same way as other resources. So you visit

    http://www.example.com/queries/new

to create a new query, which gets assigned the URL

    http://www.example.com/queries/4328

and you can then visit that page to see a list of the results of the query. Unlike with a simple search, the query parameters themselves don't get used in the URL: they're stored on the server. So you can't hack the URL to change the query, but you do have a simple URL that you can easily share with other people if you want to.
