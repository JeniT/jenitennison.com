---
layout: drupal-post
title: Automatic markup and XML pipelines
created: 1203976977
tags:
- pipelines
- markup
---
The project I'm working on at the moment aims to use RDFa (in XHTML) to expose some of the semantics in some natural-language text. We're aiming moderately low -- marking up dates, addresses, people's names, and various other more domain-specific things -- at least at the moment.

The problem we're getting into now is how to get that information marked up. Because the information comes from various pretty unregulated sources, there's no way we can force the authors to do the mark up. And the scope for making it "worth their while" (in terms of making their authoring job easier or more effective or even offering financial rewards) is very low.

So we're taking a look at the technologies we might use for automating the markup, specifically [GATE][1] and [UIMA][2].

[1]: http://www.gate.ac.uk/ "GATE: A General Architecture for Text Engineering"
[2]: http://incubator.apache.org/uima/ "Apache UIMA: Unstructured Information Management Applications"

<!--break-->

These technologies basically use pipelines of components which each add some (out of line) annotations to the text. The annotations are done out of line because they might overlap, but you can (usually) serialize them into XML, which is what we want to do.

I find these technologies frustrating for a number of reasons:

  * any configuration we do will be specific to that particular application; it'll be hard to for us to change to another implementation later on, and reuse by others will be limited to those who use the same implementation
  * they involve a fair bit of proper coding (by which I mean Java or C++)
  * where components can be configured through declarative means (such as keyword lists), there's no way to reuse (XML/RDF) resources that we already have; we'll have to manage transformations from them into the accepted formats through some external means, and I just *know* they'll get out of sync
  * their user documentation is dreadful; it seems like you need to have a good understanding of natural language processing to have a hope of even getting started

It strikes me that the really powerful part of each of these technologies is the pipelining. The pipelining allows you to string together relatively simple operations (tokenising text, extrapolating sentences, marking up keywords, resolving ambiguities based on context etc.) which together give you something reasonably sophisticated.

Using [XProc][3] to coordinate the pipeline would alleviate many of my frustrations. XProc can and will be implemented on many platforms, in many languages, so it'll be possible to move the pipeline from place to place (assuming that the components of the pipelines are similarly generic). It's declarative, so no "proper coding". We'll be able to incorporate any transformations from existing XML/RDF data to the required configuration formats right into the pipeline. And... OK, it won't automatically give us great user documentation or GUIs, but they'll come.

[3]: http://www.w3.org/TR/xproc/ "W3C Working Draft: XProc: An XML Pipeline Language"

The big problem is that XProc is still a Working Draft and the XProc ecosystem isn't well-developed. If we were one or two years down the line, XProc would be a Recommendation, there'd be a .NET implementation readily available, and even perhaps extension XProc step types for tokenising, grouping and the other things we'd need to do; anything that was missing we could pull together using XSLT.

As it is, we're in that annoying in-between-time when the Right technology isn't ready and it looks like we're going to have to put effort into working with what feels like the Wrong technology just to get things done. But perhaps I'm overlooking something in GATE or UIMA, or have missed another technology that would help us. Anyone out there got some experience that could help guide us?
