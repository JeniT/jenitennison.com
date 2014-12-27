---
layout: drupal-post
title: ! 'XTech 2007: Thursday 17th May Afternoon'
created: 1180303404
tags:
- xtech
- atom
- google
- rest
---
**UPDATE:** Dare Obasanjo has written [an interesting critique][1] on using the [Atom Publishing Protocol][6] as the basis for general purpose sharing of data in the way that the [Google Data API][5] does.

[1]: http://www.25hoursaday.com/weblog/2007/06/09/WhyGDataAPPFailsAsAGeneralPurposeEditingProtocolForTheWeb.aspx "Why GData/APP Fails as a General Purpose Editing Protocol for the Web"
[5]: http://code.google.com/apis/gdata/index.html "Google Data API"
[6]: http://bitworking.org/projects/atom/draft-ietf-atompub-protocol-15.html "Atom Publishing Protocol (v15)"

 * * *

Thursday afternoon had a few really interesting talks. I learned about the Google Data API (no longer called gData); Oracle's use of XLink to represent relationships between documents, and the requirements that entails; using XSLT to create JSON to use Exhibit widgets; and using XMPP to enhance instant messaging.

<!--break-->

## [Google Data API][3] ##
### Frank Mantek ###

The [Google Data API][5] is the unified API that Google offers to all its services, such as Google Base, Blogger, Google Calendar, Google Spreadsheets and so on.

Frank talked about how awful SOAP/WSDL is, in particular how two services developed in different platforms can't talk to each other (which one might imagine is rather the point of Web Services). (Later, when challenged by a Microsoft guy about this claim, he revealed that he'd been a major developer of the SOAP/WSDL stuff at Microsoft, so knew exactly what he was talking about from bitter experience.)

So the Google Data API is a RESTful API, using the [Atom Publishing Protocol][6] with a few additions:

 *  extra data model
 *  querying
 *  concurrency control
 *  extra authentication

What this basically means is that you can query any of the Google services using HTTP, and get back an Atom document. The URI can contain queries (the precise nature of which depend on the service; [Google Base][7], for example, uses a single URI request parameter that has a complex internal query syntax), and you get back the feed with the items that you'd requested. The Atom items themselves have the basic Atom elements, but then a bunch of service-specific elements that provide the extra information you need.

Listening to this talk I finally got what [Tim Bray][8] was talking about at the [XML Summer School][9] a couple of years ago: REST gives us verbs and Atom gives us objects and lists of objects. I didn't get it before, because, after all, aren't all XML documents objects? But I think the point is that Atom has a lot of the mechanics that you need for talking about objects built into it, and the extensibility necessary for adding your own information to it (which is what each of Google's services are doing).

The really interesting part of the talk was where Frank started talking about what the problems (still) are. The problems I noted were:

 *  Atom's verbose
 *  Google have to use `<category>` to indicate the kind of thing they're representing (as opposed to using the document element which is what you'd do with normal XML documents)
 *  the `rel` attribute is too vague
 *  they made up their own markup languages, rather than reusing existing standards
 *  they should be using [ETags][10] for concurrency control
 *  they haven't got any versioning (eek)
 *  incremental updates are a problem; they don't want to serve the whole Atom feed (to a mobile device) when only a small amount has changed, so what they do is have several feeds, each of which reveals a different part of the information

[3]: http://2007.xtech.org/public/schedule/detail/33 "Google Data API (Talk)"
[7]: http://base.google.com/ "Google Base"
[8]: http://www.tbray.org/ongoing/ "ongoing"
[9]: http://www.xmlsummerschool.com/ "XML Summer School, Oxford"
[10]: http://en.wikipedia.org/wiki/HTTP_ETag "Wikipedia: HTTP ETags"

## [From Trees to Graphs: Evolving XML for building enterprise applications][11] ##
### Ravi Murthy ###

Ravi Murthy talked about the provision for defining links between documents in [Oracle][12]'s database, and their consequent requirements. Information Oracle's XML database has a file system abstraction (every XML 'object' has a file path) with access control, versioning, metadata and protocol access. Within an XML 'object' stored in the database, they use XLink to represent the relationships with other objects. When you export the XML, the XLinks get resolved to create the XML document.

Using XLink to represent relationships between documents brings a whole new set of constraints that you might want to express in a schema language, or annotations that you can use to describe the links (depending on how you look at it):

 *  The **type** of the linked resource (eg the document element's name, substitution group or XSD type)
 *  The **scope** of a particular reference, similar to the scoping of XSD's identity constraints
 *  That a particular link is **acyclic** (eg, given an XPath expression, keep evaluating it and make sure you never get back to where you started)
 *  The **kind** of a link, one of:
     *  **hard**: the target of the link must exist, and cannot be deleted while this resource exists (but can be renamed) -- these are similar to links in normal databases
     *  **symbolic**: trust the file path specified by the link and only resolve it on demand
     *  **weak**: like a hard link, except the target can be deleted, in which case the link becomes symbolic
 *  The **versioning** of a link, whether it points to the "current" version of a resource or a specific version

These extra constraints are expressed as annotations on the definitions of `xlink:href` attributes in XSD schemas for the documents held in the database.

Ravi also talked a bit about expressing decomposition rules: how an XML document should be shredded when it gets put into the database. They use XPath to specify rules that indicate that particular elements should be placed at a particular filepath.

[11]: http://2007.xtech.org/public/schedule/detail/81 "From Trees to Graphs: Evolving XML for building enterprise applications"
[12]: http://www.oracle.com/ "Oracle"

 * * *

I was really flattered in the tea break. Chatting with a guy called [Phil][25] working at the University of Bath, who politely asked about my presentation, and after I'd explained how it was all to do with overlapping markup and that kind of hard-core theory he said: "You don't *look* like a markup geek". Me: "What, because I'm a girl?". Him: "No, no, that's not what I meant. You just look more Web 2.0-ey." [Max][26] was there at the time, and labelled me "the Geekess of XSLT", which I think clarified things. (Actually most of the people at XTech this year were Web 2.0-ey rather than markup geeks, but I'm glad I *looked* as though I fitted in.) 

[25]: http://philwilson.org/blog/ "Phil's Blog"
[26]: http://lapin-bleu.net/riviera/ "Max's Blog"

## [XML-powered Exhibit: A Case Study of JSON & XML Coexistence][13] ##
### [Chimezie Ogbuji][14] ###

"What's [Exhibit][15]?" I hear you ask. Or maybe you're more with-it than I am, but that's what I was asking. Chimezie never really explained, but I kinda gathered that it's a funky AJAX toolset for creating views of data by importing scripts and using magical IDs and extension attributes within web pages. The other phrase that Chimezie dropped in was [Rich Web Application Backplane][17], which again I hadn't heard of. Even having read the W3C Note, I still don't get it. Ho hum.

Anyway, Chimezie made the point that while entering data using XForms is great, it's too heavy-weight for viewing that data. Exhibit gives a lot more flexibility (take a look at the [US presidents][16] example), which enables users to explore data more freely. In Exhibit pages, you provide a JSON schema for your data, a number of lenses/views/widgets that you can use to view the data, then you embed the widgets in the HTML page and point it at the data source. The JSON schema indicates the type of a particular property (eg "country"), and gives labels for it (including a plural label ("countries") and a reverse label ("country of")) that it uses in the widgets.

But that requires JSON, right? Chimezie showed how easy it is (and it's *really* easy) to transform data-oriented XML into JSON using XSLT.

You know, there are all these cool ways out there for viewing information, I just wish I had some really meaty data to use them on! [Timelines][18] are one thing, but I'd also love to find some data to employ in [Gapminder][19] or even in an interface like the one for [the music of Philip Glass][20]. Perhaps I should just mine [Google Base][21], but I'd like it to be something personally or collectively useful.

[13]: http://2007.xtech.org/public/schedule/detail/155 "XML-powered Exhibit: A Case Study of JSON & XML Coexistence"
[14]: http://metacognition.info/ "Chimezie Ogbuji's Website"
[15]: http://simile.mit.edu/wiki/Exhibit "Exhibit Wiki"
[16]: http://simile.mit.edu/exhibit/examples/presidents/presidents.html "US Presidents in Exhibit"
[17]: http://www.w3.org/TR/backplane/ "Rich Web Application Backplane"
[18]: http://simile.mit.edu/timeline/ "SIMILE Timelines"
[19]: http://www.gapminder.org/ "Gapminder"
[20]: http://www.philipglass.com/glassengine/ "Philip Glass Engine"
[21]: http://base.google.com/ "Google Base"

## [Real-time user-to-user web with Mozilla and XMPP][22] ##
### [Massimiliano Mirra][23] ###

This talk was strong on motivation -- the requirement to enhance basic instant messaging functionality -- and strong on demonstration, with Massimiliano chatting and playing with a pre-programmed bot, but really weak on the technical details. It was only through the post-talk questions that we learned that what we'd seen was based on [XMPP (the Extensible Messaging and Presence Protocol)][24], which allowed DOM events to be passed between clients. Have to read the paper if you want to learn more.

[22]: http://2007.xtech.org/public/schedule/detail/97 "Real-time user-to-user web with Mozilla and XMPP"
[23]: http://blog.hyperstruct.net/ "Massimiliano Mirra's Website"
[24]: http://www.xmpp.org/ "XMPP Standards Foundation"
