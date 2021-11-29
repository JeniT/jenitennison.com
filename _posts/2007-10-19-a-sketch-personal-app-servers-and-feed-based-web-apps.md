---
layout: drupal-post
excerpt_separator: "<!--break-->"
title: ! 'A sketch: personal APP servers and feed-based web apps'
created: 1192829278
tags:
- web
- atom
---
OK, so I can't remain a Luddite for long. What's a technological solution to the [posterity problem][1], in particular in regard to web applications that tuck away all your data in their databases, just waiting to be forgotten?

Well, what if web applications accepted information as feeds rather than through forms? The original data would be distributed rather than centralised. Web applications would use the web as more than a distribution medium: they would be [*of* the web rather than simply *on* the web][6].

[1]: http://www.jenitennison.com/blog/node/59 "Jeni's Musings: Posterity"
[6]: http://www.25hoursaday.com/weblog/2007/10/20/IfYouFightTheWebYouWillLose.aspx "Dare Obasanjo: If You Fight the Web You Will Lose"

<!--break-->

How it would work:

  * Keep your data on your computer (in XML where possible). Use whatever tool you like to create and edit it (by hand, using a dedicated standalone application, using a browser-based application in the manner of [TiddlyWiki][4], or however), in some common markup language.

  * Serve your data through a web server that supports [APP][5], and provide a feed that exposes the data. I'm not saying that this is easy for [Joe Bloggs][7] to do now, but if we're talking about having [web servers on mobile phones][3] then surely it's not long before having a personal web server is a matter of course, and why not with APP support? Feeds could be generated based on directory structures, or simply created as the main file format for a particular application.

  * Visit the web application that you want to use and point them at your data feed. They access, store and index your data, and relate it to the other data that they have stored from other people's feeds. It's their responsibility to keep their database up to date by doing a regular crawl of the feeds they know about; they don't have to store *all* your data, just the bits that enable them to do their job.

  * Edit your data through the web application's interface; it can update your data for you using APP. (The web application is a APP *client*, and you host an APP *server*.) That can include adding comments or whatever other community-level annotations you might expect.

Why bother?

 1. You have all your data locally (although it might be mirrored elsewhere).
 2. You can edit your data in whatever tool you want to use, but still use a funky "rich internet application" to view it and share it.
 3. You can provide the same data feed to any number of web applications; you're not locked in.
 4. Because it's stored locally, your data is available for viewing and editing even when you're offline.
 5. Because the important parts are cached by a web application, your data is available for viewing and editing even when you're away from your normal computer.
 6. Your friends can access your data directly in a peer-to-peer network.

The obvious problems:

  * Setup: Web servers aren't that easy to set up and maintain at the moment, because they're designed for the use of sysadmins who are quite happy hacking text-based configuration files. That could change (look at WiFi router setup nowadays compared to how it was a few years ago).

  * Security: you might not want everyone to be able to access the data you keep on your personal web server. So you'll need a way of assigning user names and passwords to feeds, and only handing those over to web applications that you trust.

  * Server load: it's not so much DoS attacks (which tend to have big juicy targets), but the fact you're more likely to experience large volumes of requests if, say, a picture you host suddenly gets popular, and might not be able to respond to them, or might have to start paying heavily for the bandwidth. So sites that offer hosting will still be really useful, particularly for media that's (a) large and (b) likely to be embedded in other people's pages.

  * Schemas: you can't split creation of XML from processing of XML unless you have some kind of mutual understanding about the markup language that's used. This used to seem like a major stumbling block to me, but in fact people seem to be sensible enough to use standards where there are standards, write stylesheets to convert between languages, extend what exists with what they need in more-or-less acceptable ways and generally muddle through without spending years in meetings thrashing out a single consensual model. And Atom and APP are pretty good at supporting extensions and so on that would make that work.

My hope is that we'll get round to trying some of these ideas out in our [genealogy-based Web 2.0 project][8].

[2]: http://news.bbc.co.uk/1/hi/technology/7044606.stm "BBC News: Drive advance fuels terabyte era"
[3]: http://dubinko.info/blog/2006/06/04/would-you-run-a-web-server-on-your-phone/ "Micah Dubinko:  Would you run a web server on your phone?"
[4]: http://www.tiddlywiki.com/ "TiddlyWiki"
[5]: http://www.ietf.org/rfc/rfc5023.txt "The Atom Publishing Protocol"
[7]: http://en.wikipedia.org/wiki/Placeholder_name#People "Wikipedia: Placeholder names for people"
[8]: http://www.jenitennison.com/blog/node/54 "Jeni's Musings: Web 2.0 Project"
