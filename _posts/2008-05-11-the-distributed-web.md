---
layout: drupal-post
title: The Distributed Web
created: 1210540049
tags:
- web
- atom
- xtech2008
---
XTech was subtitled "the mobile web", but one of the major themes for me was that of **the distributed web**. The [first keynote][2], by [Simon Wardley][1], gave a vision of a future in which hardware, frameworks and applications are services in the cloud rather than products on machines we own: where we use [flickr][3] to store our photographs, [Google App Engine][4] to host our applications, and [Amazon S3][5] to store our data. In [David Recordon][6]'s keynote ([written up by Jeremy Keith][7]), he talked about small, specific services provided by sites that aren't "destination sites". The same picture was painted by [Gareth Rushgrove][8] in his talk on [Design Strategies for a Distributed Web][9].

[1]: http://www.gardeviance.org/about-me "Simon Wardley"
[2]: http://assets.expectnation.com/15/event/3/Why%20%22open%22%20matters%20—%20from%20innovation%20to%20commoditisation%20Paper%201.pdf "XTech 2008: Why "open" matters — from innovation to commoditisation"
[3]: http://www.flickr.com/ "flickr"
[4]: http://code.google.com/appengine/ "Google App Engine"
[5]: http://www.amazon.com/gp/browse.html?node=16427261 "Amazon Simple Storage Service"
[6]: http://www.davidrecordon.com/ "David Recordon"
[7]: http://adactio.com/journal/1461/ "Adactio: David Recordon’s XTech keynote"
[8]: http://morethanseven.net/ "Gareth Rushgrove"
[9]: http://2008.xtech.org/public/schedule/detail/549 "XTech 2008: Design Strategies for a Distributed Web"

<!--break-->

So I was surprised at how contentious [Steven Pemberton][10]'s talk on [Why you should have a Website][11] (thankfully again [documented by Jeremy Keith][12]) proved to be. Because to me it seemed to be the logical extension to the distribution of hardware, frameworks and application: the distribution of data. In fact, I've [written about the same idea myself][13], [as has Leigh Dodds][14], more recently.

[10]: http://www.cwi.nl/~steven/ "Steven Pemberton"
[11]: http://2008.xtech.org/public/schedule/detail/545 "XTech 2008: Why you should have a Website"
[12]: http://adactio.com/journal/1468/ "Adactio: Why you should have a Website"
[13]: http://www.jenitennison.com/blog/node/60 "Jeni's Musings: A sketch: personal APP servers and feed-based web apps"
[14]: http://www.ldodds.com/blog/archives/000330.html "Lost Boy: Google AppEngine for Personal Web Presence?"

From the session, the main question seems to be "how could we do flickr without them holding our data?" I don't want to particularly pick on flickr, especially because it's not one of the worst offenders, but the problem of serving and sharing images does illustrate a whole range of issues, so I will use it as an example. I could just as easily be talking about ancestry.com. The way I see it, you need three levels:

  * **providers** which make information available in known formats
  * **user interfaces** which provide the end-user with a way to access and manipulate the information
  * **brokers** which locate information on the web and provide an aggregated interface

(It occurs to me that this is similar to a model/view/controller architecture: the providers give the model, the user interfaces give the views and the brokers control the flow between the two.)

Where flickr is at the moment is a conglomeration of the three: to have your photo appear on flickr, and to gain the advantages that it gives you in terms of tag-based aggregations and social networking, you have to upload it. They are then the provider of the image+metadata (perhaps the only place it is located on the web), the user interface on the image+metadata (the interface through which the image is annotated), and the broker (they provide keyword-based retrieval, for example).

What would it look like to separate those functions?

First, you, as the owner of the image+metadata, could put your data anywhere: on a home wireless network box, on a webserver hosted by an ISP of your choice, on a site specifically designed for hosting photos. Your data is exposed to the larger web through a standard read/write protocol (I'm betting on [AtomPub][21]) that allows you to provide metadata both about resources and the links between resources. The point of it being read/write is that it allows other people to add metadata to or links from your resource to others, such as adding a comment on your image.

[21]: http://tools.ietf.org/html/rfc5023 "RFC 5023: The Atom Publishing Protocol"

Second, an information broker would locate your photos by crawling for them (or perhaps by you submitting the URL somewhere, but mostly that shouldn't be necessary). There are already information brokers around: Google provides a [RESTful API for general search results][19], [as does Yahoo!][20]; at XTech, [Richard Cyganiak][15] talked about [Sindice][16], and [Aidan Hogan][17] about the [Semantic Web Search Engine][18], both of which crawl for RDF triples and provide an API for querying the results. In an AtomPub-based environment, you'd want an information broker that located Atom feeds and resources, indexed them, and provided an AtomPub-based API for publishers to use.

[15]: http://dowhatimean.net/ "Richard Cyganiak"
[16]: http://sindice.com/ "Sindice"
[17]: http://sw.deri.org/~aidanh/ "Aidan Hogan"
[18]: http://www.swse.org/ "Semantic Web Search Engine"
[19]: http://code.google.com/apis/ajaxsearch/documentation/#fonje "Google AJAX Search API"
[20]: http://developer.yahoo.com/search/ "Yahoo Search Web Services"

Third, a user interface would provide an attractive and usable front-end that brought together many different sets of information. For example, flickr might combine your friends feed with an image search to provide a view of images recently made available by your friends. There's no requirement for your friends to use flickr for this to work: flickr queries a broker for a list of your friends, then queries a broker for images by a particular person, the broker searches its index and points the application to the original resources that are provided by your friends.

A user interface has another role, though: to add to the web. Flickr wants to make it easy to add tags to photos, to create sets and collections that help you navigate your photos, for others to add comments and so on and on. And that's fine, because AtomPub is a read/write API. To add a tag to a photo, flickr simply edits the resource with PUT. To add a comment, it locates the comment feed (which would be referenced from the entry for the particular image) and POSTs to create a new resource. And everyone can see those changes -- the added value that you get from a social network.

None of this is to say that a single application can't act as provider, broker and publisher at the same time, but I'm certain that users will favour those applications that do *all* of each role: provide to the whole web, broker the whole web, provide a user interface to the whole web. Flickr is almost there, but it doesn't do the whole brokering job because it only brokers the data it provides, and therefore it doesn't provide the whole user interface job.

This distributed web is a clear win, particularly for users, over walled gardens. They can switch from user interface to user interface, even use more than one at a time (perhaps one application is good for browsing while another is good for categorising), without any cost. They can choose who to use to serve their information on the basis of things that matter when you're serving information (low downtime, backups, security, etc.) rather than on how pretty an interface looks or how much functionality it gives you. On the other side of the equation, applications get to do one thing and do it well.

It seems to me that this is simply how the web works, and the questions we should be asking are about privacy and trust and licensing and revenue models and standards development.
