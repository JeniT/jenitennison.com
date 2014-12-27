---
layout: drupal-post
title: ! 'legislation.gov.uk: Credit Where it''s Due'
created: 1281784718
tags:
- legislation
- psi
- opendata
---
I'm aware I've been quiet for the past few months. This isn't because nothing interesting has been going on -- rather the opposite. It's been difficult to get a chance to sit down and write about the work I've been doing, when actually doing the work has been taking up so much time.

Most of my time has been spent on the new [legislation.gov.uk](http://www.legislation.gov.uk) website and its underlying API. There's so much to say about this project that I hardly know where to start, so I'll just try to do an overview and we can take it from there. Let me know what you're interested in.

<!--break-->

legislation.gov.uk is a government website built on the principles of transparency and open data, including ideas laid out in the [Power of Information Taskforce Report](http://webarchive.nationalarchives.gov.uk/20100413152047/http://poit.cabinetoffice.gov.uk/poit/2009/02/modernising-information-publishing-final/). We have a lovely user interface which helps end-users find and understand legislation, but it's layered over the top of an API that [anyone is free to use](http://www.legislation.gov.uk/licence) to construct their own websites based on the same data.

In fact, we built the API first, and it's been around (though not in a particularly stable state) for about a year. However, it turned out that building the user interface really helped in two ways. First, it helped the legislation experts who were looking at the documents to spot errors in a way that they unsurprisingly struggled to do when presented with raw XML. Second, it helped to identify things that the API needed to do to support a useful website, such as always providing links to the table of contents for an item of legislation or providing a search based on modification date.

Now, if you've been reading [Sean McGrath's blog](http://seanmcgrath.blogspot.com/2010/05/kliss-first-things-first-what-is.html) you'll know that as far as content goes, legislation is about as tough as you can get. For a start, Acts and Statutory Instruments are *semi-structured documents*, not tabular data. It's not a simple matter of storing and extracting rows in a database: we need to be able to address portions of an item of legislation such as "Local Government Act 1988 (c. 9, SIF 81:2), Sch. 3 para. 13(1)(b)(2)" (this an [actual citation](http://www.legislation.gov.uk/ukpga/1975/30/section/24/2000-09-08#commentary-c1075749)! I am not making this up!).

The content itself is complex. For legislation.gov.uk, the main challenge is not to do with faithfully reconstructing page and line breaks (fortunately!) but how to represent complex, annotated, changes to legislation over time, and then how to present them. Much of this had already been done (in terms of technology) within the [Statute Law](http://www.statutelaw.gov.uk) and [OPSI](http://www.opsi.gov.uk/legislation) websites, although the data comes from a variety of sources over time, each with its own set of peculiarities to be navigated. The larger challenge here was to provide a mechanism of navigating through the content that made clear the distinctions between the various versions of legislation that people can look at and warning them about their status without overwhelming them with information.

We also have a lot of documents, some of which are very large. There are nearly 60,000 items of legislation on the site. The largest and most complex of them has hundreds of sections and about a hundred distinct versions. When you consider all the versions of all the possible fragments of all the items of legislation, you're talking about 6.5 million distinct documents, each of which is available in HTML, XML, PDF and for which there is some RDF metadata.

On top of this, the content is constantly changing. New legislation is published every working day, first as PDFs, then as HTML (and XML), and then various associated documents the most important of which are Explanatory Notes, again first in PDF and then in HTML/XML form. Old legislation changes too; the legislation.gov.uk editorial team is constantly working through a backlog of changes to existing legislation brought about by new legislation. Simply hooking up the site to keep up to date with these changes has been an enormous challenge.

The content also changes because we intend to add features to the site over time. The site has already seen bug fixes and tweaks to address problems that we've encountered post-launch, and there are a number of new features in the pipeline to bring the site up to the level of completeness where it can fully replace the existing OPSI and Statute Law websites.

Then we needed something that was reasonably fast and robust in the face of moderately heavy traffic. Providing fast access to ever changing content, especially when the changes themselves are unpredictable, is an ongoing challenge.

All of this has only been possible by having an excellent team of experts and developers. One of the things that made this project quite different from the majority of government projects of this size was that it was much closer to Agile than Prince2: clients and providers working closely in the same team, chatting on daily calls, working side-by-side. From the developer perspective, it gave us direct access to the people who both had the expertise about the content and knew what they wanted. From the customer side, I hope and believe that it gave them as close involvement in the development of the site as they could want and a far deeper level of understanding about exactly how it works (and therefore what is easy and what is hard, and where compromises are best made) than they would have had otherwise.

So here are some credits. First, from [TSO](http://www.tso.co.uk/), where I work:

  * **[Carey Farrell](http://twitter.com/careyfarrell)** ran the project, keeping track of the many and various bits and pieces that needed doing and finding the people to get them done; he has been the project's backbone
  * **[Paul Appleby](http://twitter.com/pauldappleby)** may have moved on to better things part way through, but made his mark early on in its design and architecture, and much much earlier in the design of the XML schema, and in many of the stylesheets that underlie the HTML and PDF views of this data
  * **Lee Goodby** put together the system infrastructure, arranging more machines and memory and disk space to satisfy our endless demands
  * **Chunyu Cong** performed many a thankless data wrangling task without complaint
  * **Griff Chamberlain** has worked doggedly on this project (with occasional pauses for beer) since he came aboard, among many *many* other things working on the generation of PDF (via XSL-FO) from the XML source and dealing with the difficulties of usable next/previous navigation
  * **[Tony Graham](http://www.menteithconsulting.com/wiki/People/TonyGraham)** made the publication of Tables of Effects his own, as well as constantly improving our build processes
  * **Gavin Mannings** achieved quite remarkable things with a combination of HTML, CSS and Javascript. If you don't believe me, take a look at the source underlying [the histograms on the browse pages](http://www.legislation.gov.uk/ukpga) or [the timelines for legislation content](http://www.legislation.gov.uk/ukpga/1985/67/section/6?timeline=true)
  * **Faiz Muhammad** quickly got to grips with a whole set of complex and unfamiliar content and technologies, to create the UI from the API data
  * **Paul Harvey** furnished us with data, warned us of bear pits, and remained astonishingly uncomplaining of the changes we were putting him through
  * **Marc Sturman** brought all his expertise to bear in managing the publication of legislation from the SLD editorial system into the new website and pulled our fat from the fire both on deployment and in the creation of the larger PDFs
  * **Vinod Sathyamoorthy** worked on all aspects of the infrastructure: scaling out the environment, testing it, configuring it and so on, to make it into a site that more than a few people could access at a time
  * **[Rob Bullen](http://twitter.com/RobBullen)** brought a little more order to a kind of controlled chaos, in the way a good project manager should
  * **Terry Blake** had the clout and the clear-sighted vision to get things done, as well as (and perhaps secretly enjoying) getting his hands dirty on occasion

From [Bunnyfoot](http://www.bunnyfoot.com/):

  * **Mark Pierce** designed the look and feel of the site, having to get to grips with the complexities of legislative content as well as treading the fine line between making the site look modern yet authoritative, appealing whilst not detracting from the content
  * **Rebecca Gill** provided clear eyes, analysis and insight to help us understand how to improve the site for our users

And from [The National Archives](http://www.nationalarchives.gov.uk/):

  * **[Clare Allison](http://twitter.com/crallison)** has devoted her life to ensuring that the content on the site is as accurate and meaningful as it can be, working with the astonishing complexities of the legislation content with an amazing depth of knowledge and expertise
  * **[Claire Lait](http://twitter.com/clairelait)** has poured her soul into providing a meaningful and useful experience for the end users of the site with insight, intelligence and unparalleled openness and enthusiasm
  * **Catherine Tabone** has dealt with the traumas of the ups and downs of deployment with fortitude and good humour

And finally, none of this would have happened without **[John Sheridan](http://twitter.com/johnlsheridan)** having the ambition and the vision for how legislation should be published on the web, creating the environment that enabled this project to be done, setting a positive tone and providing support, encouragement and a gently guiding hand throughout the process.

This isn't everyone who has been involved in the project: there are system administrators and testers and beta users and a whole cloud of other support particularly from [MarkLogic](http://www.marklogic.com/), [Orbeon](http://orbeon.com/) and [Akamai](http://www.akamai.com/). But these are the people who let it consume their lives for at least a while. Every one of them was vitally important to the project, bringing their own expertise and skills and personality. I admire them all hugely. 
No project of this size is completely plain sailing, and I am convinced that we would be in a very different position today if the project hadn't been built on mutual respect and trust. I've sketched some of the challenges that we faced. If it all looks easy, it's only because this group of people did their jobs incredibly well. This is my public thanks to them for all their work.
