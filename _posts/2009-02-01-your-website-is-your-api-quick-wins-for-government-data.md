---
layout: drupal-post
excerpt_separator: "<!--break-->"
title: ! 'Your Website is Your API: Quick Wins for Government Data'
created: 1233480537
tags:
- web
- xml
- atom
- rest
- rdfa
- ukgc09
---
*This is the talk I prepared for the UKGovWeb Barcamp, in blog form. It's probably better this way. Most of what's written here seems blindingly obvious to me, and probably to most readers of this blog, but maybe Google will direct someone here who finds it useful.*

Working with public-sector information on the web, one of the things that I take an interest in is making government data freely available for anyone to re-present, mash-up, analyse and generally do whatever they want to do. This post is born out of a feeling that the people who control data don't realise that the smallest changes can be beneficial: they don't need to do *everything* right now, just *something*.

<!--break-->

There are three fundamental things that you need to do:

  * **identify** the data that you control
  * **represent** that data in a way that people can use
  * **expose** the data to the wider world

but you can choose the degree to which you do each of these things.

## Identify ##

Take a look at what data you have some kind of responsibility for or control over. You might be a PDF containing a table of schools in the local area and their intakes over the last couple of years. You might have a spreadsheet of the amount of money assigned to maintaining the playgrounds within the borough. You might have a database of company information. You might have a set of HTML agendas for court cases.

The first step is simply to identify what the information is *about*. Schools, playgrounds, companies, court cases -- each row in your table or spreadsheet or database, or each section in your document will be about something. We call this a **resource**.

To play nicely with the web, every resource should have an **identifier**. A Uniform Resource Identifier. A URI. That URI tells us where we can find information about the resource (we'll get to what those look like later). So your second step is to work out URIs for each of your resources.

Now, there are actually three levels of URIs that you can care about:

  * identifier URIs
  * document URIs
  * representation URIs

You probably already have document and representation URIs on your web server. Representation URIs are URIs for particular formats and languages and views of the information that you make available. Document URIs are typically the same URI without an extension; web servers use **content negotiation** to work out which representation to serve up when a web browser asks for the page at a particular document URI.

So you already have a URI for the PDF that contains the table of schools, for the Excel spreadsheet about the playgrounds. You already have URIs for the results of a particular query on your database, and of course the HTML pages that you deliver have URIs already. That's all in place. You don't want to change it.

But identifier URIs are what are really important when it comes to opening up your data. They shift the focus from the documents that you serve to the resources that they are about. **By assigning URIs to resources, you enable other people to talk about them. Even if that's all you do, you have done good.**

For example, if [Companies House][1] stated that companies could be referred to using URIs of the form `http://www.companieshouse.co.uk/id/company/{registeredNumber}` then other people who needed to talk about companies (websites containing customer feedback, monitoring companies going into receivership, displaying stock price information, whatever) could use these URIs whenever they referred to a company. If all websites that make data available about companies point to the same identifier for a company, then it's possible to pull that data together very easily.

[1]: http://www.companieshouse.co.uk/ "Companies House"

Now the URIs that you use should be short, clean, readable, hackable, hierarchical and so on. If you can, **you should use a natural identifier for the resource within the URI for that resource**. So URIs for registered companies should use their registered number. URIs for schools should use the school's unique reference number (URN). URIs for playgrounds could use the name of the playground (scoped within the council responsible for the playground). URIs for court cases should include the court, the year, and the case number. And so on.

Remember as you're creating these identifier URIs that they are nothing to do with the structure of your website or the user's experience of navigating through your website. For navigation, you might want to group schools into primary, secondary and sixth-form, but you shouldn't do that in the identifier URIs. To help decide, imagine someone wanting to construct a URI and the information that they need to do so. If any of the information they need can be derived from other information (as a school's type can be derived from its URN), leave it out.

When you're doing this, you might realise that actually you shouldn't be the one in control of these URIs. If you're not the one assigning the registered number, URN or case number then there's probably a higher authority that does assign those (real-world) identifiers. Don't let that stop you creating URIs -- you'll still find them useful for identifying *your* information about that particular resource -- but do look to see if there are existing URIs that you could point to and reuse whatever scheme they're using if there are.

## Represent ##

So I said in the last section that assigning URIs to resources was useful. And it is. But it's even more useful if you provide some kind of response when someone **requests** those URIs. A request for a URI can be done by a web browser or one of those search-engine-spider-things that crawls the web looking for data. Requests are done on the web using HTTP (hypertext transfer protocol), specifically using a **GET** request, which means "get this resource".

When a web server receives a request, it sends back a **response**. The first part of the response is a **status code** that tells the browser, spider, or whatever issued the request, generally what kind of response it is. Now when a browser says "get this company" or "get this school" a web server should either respond with a `404 Not Found` response or a `303 See Other` response.

If the company or school doesn't exist, a web server should respond with a `404 Not Found` response. It's actually really useful to give appropriate `404 Not Found` responses, because it tells whoever made the request that the resource (company/school/playground/court case) doesn't exist. This can act as simple validation: if I'm building a site that parents can use to rate schools, and a parent enters a URN into a form, I can construct a URI based on that URN, try to GET the information about that school, and if I get a `404 Not Found` response then I know that the parent has entered an invalid URN.

If the company or school exists, a web server should respond with a `303 See Other` response that points the browser to a *document URI* that contains information about the company or school. After all, the web server can't very well deliver the company or school itself into your lap; all it can do is give you *information* about it. `303 See Other` means "if you want information about that, see that other thing over there instead". The "other thing over there" will be a document of some kind. It might be the PDF that contains information about the school, or the spreadsheet that contains information about the playground.

**Simply giving a yes-this-exists or no-this-doesn't-exist response is useful. Even if that's all you do, you have done good.**

It's even more useful, though, if you can make the information that you have about the school, playground, company, court case or whatever, available in a format that can be processed by a computer reasonably easily. PDFs are really really hard to extract information from, so do everything you can not to use PDFs. Word documents and Excel spreadsheets are next worse; if you have to use them, keep them really really simple and definitely don't use Word Art or embed images to display your data.

**You should always make your data available in HTML.** Try to make it as clean and regular as you can; use [microformats][2] to indicate information about people, places and events. If you want to push the boat out, use [RDFa][3] to mark up the data in your page even more explicitly.

[2]: http://www.microformats.org/ "microformats"
[3]: http://www.w3.org/TR/xhtml-rdfa-primer/ "W3C: RDFa Primer"

The great thing about HTML is that it's human readable as well as (if you do it well) machine readable. You can also make your data available in explicitly machine-readable forms as well if you want: XML, JSON, RDF/XML, whatever floats your boat. If there are already standard formats or ontologies for the kind of data that you're making available, then use them, certainly, but it's very likely that there aren't. And in comparison to the nightmare of extracting anything useful from a PDF, it's easy to transform between different formats, so you only have to concern yourself with different formats if you want to.

If you do provide multiple formats for your data, you should use server-driven content negotiation to deliver the data in an appropriate format to whatever's requesting it. So a web browser will request HTML; a semantic web crawler will request RDF/XML; a Javascript program will request JSON and so on. The `200 OK` response that the web server sends with your data should include a `Content-Location` header that gives the representation URI of whichever format is being returned, and a `Vary` header that tells caches how it's decided which representation to serve up.

## Expose ##

All the good work identifying resources and representing them comes to naught if you don't expose it. You can (and should!) tell other people about the URIs that you've developed, but the best way to give them exposure is to use them yourself, within your website. **Simply using the URIs within your website gives them exposure. Even if that's all you do, you have done good.** People who are interested in linking to you will look at your site and they will learn about your URI scheme from your use of it.

The identifier URIs that you've created might not be particularly easy to generate. For example, with the URI scheme that I suggested above for Companies House, unless you happen to know that Tesco Plc's registered company number is `00445790`, you're not going to be able to get to information about them. So **you should have a way of searching** based on something that people *will* know, such as the name of the company. Use an HTML search form that makes GET requests like

    http://www.companieshouse.gov.uk/company?name=Tesco Plc

The response should be a `302 Found` that redirects (using the `Location` header) to the true identifier URI for the company (`http://www.companieshouse.gov.uk/id/company/00445790`). If it's not possible to identify a single resource from the search string (for example, there are lots of companies with 'Tesco' in their name), then the correct response is a `300 Multiple Choices` that provides a list of links to the possible URIs (in HTML).

There are other ways to help people find your data. If there aren't gazillions of resources, you can list the URIs within your **sitemap**, which will make them discoverable by search engines. You can also list them on web pages and, especially for data that's constantly updating, in (Atom) **feeds** which you link to from your HTML pages. Use metadata within the pages and feeds to help the consumers of your data work out what's relevant to them.

To help even more, slice your Atom feeds into portions that different consumers of your data are going to be interested in. Slice by type, by area, by subject. That way people can stay up to date with just the resources that they're interested in, and not be bothered with information about those that are irrelevant to them.

## That's It ##

What I've tried to describe here is the minimum that you need to do to help people use the information you have, and some of the other things that you can do to make it even more useful. Here are some things that you shouldn't do:

  * don't wait for someone else to define a URI scheme for the things that you want to talk about
  * don't wait for someone else to define an XML schema or RDF ontology for your data
  * don't wait until you can find the time and money to do it all "properly"

Just do what you can, now.

