---
layout: drupal-post
title: ! 'Incomplete implementations #1: Atom in IE7'
created: 1195850548
tags:
- atom
---
IE7 gives you a really quite nice view of an Atom feed. Take a look at the [one for this blog][1], for example. You can filter by category, sort by date or title or author, and search for particular words or phrases. Pretty neat.

[1]: http://www.jenitennison.com/blog/atom/feed "Jeni's Musings: Atom feed"

But it's only a partial implementation. I've been having to create some Atom feeds recently, and getting them to display nicely in IE7 has proven a bit tricky. I couldn't find any documentation about this with a quick google, so thought I'd blog it for future reference.

<!--break-->

The main things are:

 1. Do not use a prefix for the Atom namespace. IE7's Atom support is not namespace aware. (I gather this is a problem in a lot of Atom readers. Sigh.)

 2. If you don't embed the content in the entry then it will display the summary; to get a clickable link to the content, you must provide a `<link>` element whose `href` attribute points to that content. The `<link>` element mustn't have any other attributes on it, so don't add `rel="alternate"` or `type="application/xhtml+xml"`. Having a `src` on `<content>` will not give you a link.

If you want to support viewing the feed in IE6 as well, you need to provide a stylesheet to transform it into something nice. As long as the feed is served as XML, IE6 will interpret an `<?xml-stylesheet?>` PI correctly, and both IE7 and Firefox will ignore it (which is probably what you want, since both Firefox and IE7 have decent native rendering of Atom).
