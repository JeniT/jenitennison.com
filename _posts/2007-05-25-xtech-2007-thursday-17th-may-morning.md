---
layout: drupal-post
title: ! 'XTech 2007: Thursday 17th May Morning'
created: 1180128858
tags:
- xtech
- xforms
- atom
- google
- ontologies
- wikis
---
On Thursday morning, I was down to chair the first session in the "Core Technologies" track. Two interesting papers: one on XForms and one on Google Base. Then I snuck on to the "Applications" track to hear about scientific Wikis and the trials of managing schema repositories.

<!--break-->

## [XForms, REST, XQuery... and skimming][1] ##
### [Mark Birbeck][2] ###

Mark Birbeck, one of the developers of [formsPlayer][4] (and an invited expert on the XForms and XHTML WGs), discussed the rationale behind using [XForms][3]. The only thing that really stood out for me was the fact that he used an XML document to provide the *labels* for the form controls (in just the same way as you can use XML documents to provide the *data* in the form controls). That was quite neat, and made me think of the different requirements of data entry and data presentation: a topic that returned in [Chimezie Ogbuji's talk][5] later that afternoon.

Another theme here, for me, was the use of declarative programming: you write a form, which is just some XML and leave all the technical stuff about submitting a PUT HTTP request to the XForms player. Mark talked about using [WebDAV][6] and [eXist][7] on the server to store the XML documents, and demonstrated using [&lt;oXygen/&gt;][8] to load and save documents. Hmm... I wonder if I should experiment with XForms and that Unicode database browser I was thinking about...

[1]: http://2007.xtech.org/public/schedule/detail/114 "XForms, REST, XQuery... and skimming"
[2]: http://internet-apps.blogspot.com/ "Mark Birbeck's Blog"
[3]: http://www.w3.org/MarkUp/Forms/ "XForms W3C Page"
[4]: http://www.formsplayer.com/ "formsPlayer Website"
[5]: http://2007.xtech.org/public/schedule/detail/155 "XML-powered Exhibit: A Case Study of JSON & XML Coexistence"
[6]: http://en.wikipedia.org/wiki/WebDAV "Wikipedia: WebDAV"
[7]: http://exist.sourceforge.net/ "eXist"
[8]: http://www.oxygenxml.com/ "oXygen XML editor"

## [Google Base, a mashups database for the REST of us][9] ##
### Jeffrey Scudder ###

A very popular, thought-provoking, and slightly disturbing, talk on [Google Base][11]. So Google are asking us to upload data on *anything* (jobs, personals, cars, etc.) into their huge databases. And then they'll serve us back that information (and other people's information) in formats such as [Atom][12], [RSS][13] and [JSON][14], as well as standard web pages.

The thought-provoking bit, for me, was the fact that they don't have any particular schema for each of these kinds of items. Now, I come from a knowledge engineering background where we're very into ontologies and creating conceptual models and all that stuff. But Google don't bother: you create categories and structure your data the way you want to, and they'll serve it back in that way. But they look at *all* the data they have their hands on in order to decide how to display and serve information. So, for example, if I define cars with the property 'shade' but a hundred other people define them with the property 'colour' then on a feed that includes all our items, we'll see the 'colour' property.

This is a kind of bottom-up ontology design: the properties of an item are the properties that other people think are important about an item. One thing that surprised me was that it looks like it's not very intelligent yet: simple differences in case (like 'color' vs. 'Color') don't seem to be detected, so I guess nothing else is. Time to dig out my old research on automated comparison of ontologies...

The slightly disturbing part? Well, Google are trying to get us to upload our data to their servers. And they're not putting any limit on how much we upload. One member of the audience asked "What's in it for you?"; Jeffrey seemed to have a hard time understanding the question and said something like "Better indexed information means we can give you better information", but that doesn't really answer the question. Presumably it's all about being able to advertise to us better: the more data we upload, the more They know about us, the better targeted Their adverts can be.

What I found strange was the idea of *uploading* data to a *central* *server*. Surely the whole point of the web is that I put my data on my machine. I don't have a problem putting the data together in a nice Atom feed so that Google can index it easily and pointing them at it, but I want to own it, y'know?

By the way, one thing that was apparent to me during this talk was how important it is that web pages look good with large font sizes, not just for people with poor eyesight, but also for when you're *demoing* your cool web applications! The Google Base drop-down menus were impossible to see with increased font size because their height is fixed in pixels.

[9]: http://2007.xtech.org/public/schedule/detail/104 "Google Base, a mashups database for the REST of us"
[11]: http://base.google.com/ "Google Base"
[12]: http://en.wikipedia.org/wiki/Atom_(standard) "Wikipedia: Atom"
[13]: http://en.wikipedia.org/wiki/RSS_(file_format) "Wikipedia: RSS"
[14]: http://www.json.org/ "JSON"

## [An Augmented Wiki for Interactive Scientific Visualization and Evolutionary Collaboration][15] ##
### [Frank Marchese][16] ###

On to the less well-attended "Applications" track. This talk was about supporting scientists (specifically biochemists) in providing side-by-side visualisation (of complex molecules) and textual analysis. Frank talked about a Wiki in which [Jmol][17] Java applets for visualising molecules are arranged side-by-side with standard journal articles. The articles themselves have links in them that animate the Jmol visualisation: highlighting particular groups of atoms, moving it to show a particular view, and so on.

It was kind of neat, as pretty pictures of molecules often are, but I didn't think the Wikiness of the whole enterprise was really explored: I got the impression that the textual articles were basically static: you could add comments, but not collaboratively create an article about the molecule. Also, the link between the text and the animation of the molecule was through Javascript, as far as I could tell: I'd expect a declarative method of defining animations would make it a lot more accessible.

[15]: http://2007.xtech.org/public/schedule/detail/134 "An Augmented Wiki for Interactive Scientific Visualization and Evolutionary Collaboration"
[16]: http://csis.pace.edu/~marchese "Frank Marchese's Website"
[17]: http://jmol.sourceforge.net/ "Jmol molecule viewer"

## [Real-world metadata registries; sharing concepts, schemas and semantics][18] ##
### [Emma Tonkin][19] ###

This talk took me back to the trials of creation of top-down conceptual models, focusing on the definition of metadata schemas. Unfortunately, there was a lot of philosophy and not many practical guidelines in the talk, and I didn't get a lot out of it. One thing that Emma touched on, though, was the way that the meaning of a term can change over time, through:

 *  extension or generalisation
 *  narrowing or specialisation
 *  amelioration (when a term gains approval)
 *  deterioration or perjoration (when a term gains disapproval)

The latter two are particularly demonstrated by political correctness, whereby terms like "Eskimo" fall out of favour and "Inuit" becomes more acceptable (all highly culture-specific; see the [Wikipedia Eskimo page][20] for more discussion on what term to use).

The advantage of a principled conceptual model is that the concept itself and the term(s) you use for that concept are loosely coupled, so if a given term falls out of favour or becomes inappropriate, you can always decouple it. On the other hand, bottom-up tagging tends (I think) to have a 1:1 relationship between term and concept, so if the use of terminology changes you might be left with inaccurate tagging of legacy data. Maybe.

[18]: http://2007.xtech.org/public/schedule/detail/176 "Real-world metadata registries; sharing concepts, schemas and semantics"
[19]: http://www.ukoln.ac.uk/ "UKOLN Website"
[20]: http://en.wikipedia.org/wiki/Eskimo "Wikipedia: Eskimo"
