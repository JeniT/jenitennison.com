---
layout: drupal-post
title: RDFa, sure, but now?
created: 1187555675
tags:
- rdf
---
I think [RDFa][1] has a lot of things going for it. I've been a big Semantic Web sceptic for a long time, but getting semantic information embedded into web pages is cool, and RDFa is that much more rigorous than [microformats][2]. Sure, it's a bit more complicated too, but I'm not afraid of namespaces!

[1]: http://www.w3.org/TR/xhtml-rdfa-primer/ "W3C: RDFa Primer"
[2]: http://www.microformats.org/ "Microformats website"

The problem is that I'm supposed to be assessing the introduction of RDFa into a biggish, important, real-world website. It's a website where every change has to go through a Process. There are project managers, development managers, product managers. There are functional specifications, technical specifications, and rollout documents. There are unit tests, peer reviews and user acceptance tests. The database is huge; the HTML is pre-generated.

<!--break-->

In short, every change takes time and costs money. I'm just not sure it's a good idea to introduce a technology that only exists in a Working Draft of a Primer *now*, when tracking that technology could be very costly.

And if we used RDFa, we wouldn't be using XHTML 1.0 any more; we'd be using XHTML 2.0. If we want to have valid pages, we'd have to reference a non-existent DTD, or make our own. And tracking XHTML 2.0 is even more of a risk, it seems to me.

So my current thinking is that in this case, RDFa just isn't practical. Better to use [GRDDL][3] with something less revolutionary, like [eRDF][4] or microformats or plain-old custom class names.

[3]: http://www.w3.org/TR/grddl/ "W3C: Gleaning Resource Descriptions from Dialects of Languages"
[4]: http://research.talis.com/2005/erdf/wiki/Main/RdfInHtml "Talis: Embedded RDF"

Anyone want to persuade me otherwise?
