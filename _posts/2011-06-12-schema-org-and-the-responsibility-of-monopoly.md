---
layout: drupal-post
excerpt_separator: "<!--break-->"
title: Schema.org and the Responsibility of Monopoly
created: 1307906607
tags:
- google
- schema.org
---
*Update: This post has been translated to Italian on the [Linked Open Data Italia](http://www.linkedopendata.it/schema-org-e-le-responsabilita-dei-monopolisti) blog.*

In this post about [schema.org](http://schema.org) I'm going to speculate about the economic drivers that affect how search engines use structured metadata on the web. I discuss how the technical features and choices within schema.org may cause wider long-term harm, and the role of open standards as a method for responsible companies to avoid the pitfalls of monopoly.

<!--break-->

Before I launch into this, two things. The first is the standard disclaimer that I am speaking purely for myself. The second is that I recommend that you read [Rufus Pollock](http://en.wikipedia.org/wiki/Rufus_Pollock)'s paper [Is Google the Next Microsoft? Competition, Welfare and Regulation in Internet Search](http://rufuspollock.org/economics/papers/search_engines.pdf). In it, he demonstrates how the search engine market will naturally tend to monopoly, and that because of the economic drivers in the search engine market, those monopolies will generally under-perform in terms of social good. In other words, if you are a [search engine monopolist](http://www.guardian.co.uk/commentisfree/2011/jun/02/google-claws-web-dominance-challenged), you have to take positive steps to [not be evil](http://en.wikipedia.org/wiki/Don't_be_evil) because all the market drivers force you in that direction.

Clearly schema.org is a significant move by our current search engine monopolist, Google, on several fronts and while I don't pretend to have any particular insight, it's fun to speculate about how schema.org fits with their wider goals, the extent to which they are avoiding monopolist traps, and what it might mean for the web in general.

Search engines serve their customers: advertisers. So why the interest in structured metadata? Structured metadata benefits search engines in at least three ways:

  1. presenting richer information increases the utility of the search engine for users, thus attracting more of them (more users => more attention overall => more money from advertisers)
  2. presenting richer information keeps users on the site for longer because search engines can present relevant information directly rather than users navigating away from the search engine's site (more time on the site => more attention from individual users => more money from advertisers)
  3. analysing social metadata extracted from web pages, such as [social graphs](http://schema.org/Person) and individual interests can aid the targeting of adverts to particular users (more targeted adverts => more effective adverts => more money from advertisers)

Clearly there's a lot of potential for search engines in structured metadata. Their difficulty is in getting people to use it such that they don't lie, don't find it too much hassle, and don't make too many mistakes, because that way lies [metacrap](http://www.well.com/~doctorow/metacrap.htm).

So the drivers for search engines are towards making it as easy as it could possibly be for publishers to embed metadata in their pages. It is also in their interest to ensure that the information that they extract is based as much as possible on the visible content of the page as this reduces the opportunity for people to lie (or make honest mistakes) by providing one value in the metadata and another in the content of the page. And it is in their interest to correct for errors when publishers make them.

The trap is that blindly pursuing these interests can also lead to anti-competitive behaviour.

## Raising Barriers to Entry ##

The [Conformance section of the Data Model page](http://schema.org/docs/datamodel.html) says (my emphasis):

> While we would like all the markup we get to follow the schema, in practice, we expect a lot of data that does not. We expect schema.org properties to be used with new types. We also expect that often, where we expect a property value of type Person, Place, Organization or some other subClassOf Thing, we will get a text string. **In the spirit of "some data is better than none", we will accept this markup and do the best we can.**

Schema.org contains multiple examples of properties whose values should be interpreted as being of a particular type, such as dates, times, numbers, durations, and specialised micro-syntaxes such as for an [`EventVenue`'s](http://schema.org/EventVenue) `openingHours` property or an [`Article`'s](http://schema.org/Article) `interactionCount` property which (from the examples, if not the text) expects a syntax like `UserTweets:65`. These seem clear enough.

However, looking in more detail at the examples, it seems that even putting aside the option of providing a string when the schema expects an item, there are a variety of ways of expressing values for properties in schema.org. There are examples where [numbers contain commas or are preceded by currency signs](http://schema.org/Offer). [Distances](http://schema.org/Distance) are a number followed by a "unit of measurement" without any indication of what acceptable units of measurements are. [Fat content](http://schema.org/NutritionInformation) seems to follow some kind of syntax that includes a number and a measure but various other text as well. Even when values have to adhere to a particular microsyntax, there are examples that are non-standard (such as initial '`P`'s missing from durations).

In other words, there is no documentation about the way in which the values of the schema.org properties will be interpreted by search engines and there is a clear intention on the part of the search engines behind schema.org to be generous in what they accept, so as to ensure that publishers can be lazy while search engines maximise the amount of data that they can understand on the web. Lacking a specification that describes how values are interpreted, the only way for publishers, validators and tool developers to work it out will be to try it out, see what happens, and attempt to find patterns that are generally interpreted in the same way by at least the major search engines, or more likely (because why bother with anyone else), try to work out what Google is going to do with it.

We have been here before, with HTML, pre-WHATWG. Then, IE, which dominated the browser market, had the clear intention to be generous in what it accepted, and there was no specification that described the various error handling quirks that had to be reproduced in bug-for-bug compatible user agents. WHATWG have had to work extremely hard to reverse engineer a specification that provides some kind of predictability and consistency for publishers as well as making it possible for new entrants to the browser market (such as Google's Chrome), validators, and other tools to reproduce the behaviour of existing browsers. This work has paid off: over the past few years, [browser market share has diversified](http://en.wikipedia.org/wiki/Usage_share_of_web_browsers#Historical_usage_share) somewhat, largely due to the rise of mobile browsers and Chrome taking market share from IE.

With structured metadata, Google is in an extremely dominant position. Concretely, it will be very hard for Google to reveal the methods by which they extract meaningful metadata from the huge variety of textual content on the web: they may have patents that cover some aspects, and in other cases (particularly when that interpretation depends on the analysis of their vast caches of web pages, as in the case of natural language translation) the behaviour simply might not be replicable by any third party.

None of this, by the way, would be helped by using a different syntax to express the data within the page. The only way it could be addressed is by much more clarity, detail, and conformance criteria within the schema.org vocabulary specification.

Without that specificity, we get into a world where Bing, Facebook and any other search engines will spend a lot of time and effort trying to reverse engineer Google behaviour to extract the same data as they do. They might even sometimes manage to introduce useful quirks of interpretation of their own, but that's unlikely given that their constrained engineering effort will naturally be focused on matching Google. This also forms a massive barrier to entry (as if those weren't already significant) to potential new search engines. Overall, the lack of specificity suppresses innovation in the market.

And of course publishers, writers and tool creators are left struggling to keep up.

## Syntax Fixing ##

While both Google and Yahoo! have previously used information described using [microformats](http://microformats.org/) and [RDFa](http://www.w3.org/TR/xhtml-rdfa-primer/) to provide similar functionality, in schema.org they deprecate that support, both by using microdata throughout the examples and by [explicitly saying](http://schema.org/docs/faq.html#11):

> If you have already done markup and it is already being used by Google, Microsoft, or Yahoo!, the markup format will continue to be supported. Changing to the new markup format could be helpful over time because you will be switching to a standard that is accepted across all three companies, but you don't have to do it.

Whichever technology they choose, the act of search engine monopolies making that choice and the consequent widespread adoption via SEO creates a large barrier to changes to the technology. Even if the specification for the technology changes, those changes will be likely to be ignored in practice as Google (and hence other search engines) seek to retain backwards compatibility with the examples and guidance published on schema.org as they stand now.

It is particularly damaging to have the choice be microdata because microdata is a relatively new technology that has only just reached W3C Last Call Working Draft. In my experience, Last Call is usually the *first time* that a wider community outside interested Working Groups start to look at a technology seriously. To create better technologies and better specifications, Working Groups must be able to change in response to this review.

The ultimate result is again standardisation-by-implementation, which has long term adverse consequences in restricting competition (not between technologies, but between organisations using those technologies) and leads us to a situation where we could end up using something that is less than optimal for any kind of wider purpose outside the interests of the monopolist.

## Standards Bodies ##

The development of schema.org might seem like a very minor thing, only of interest to people interested in SEO and structured metadata, but it is part of a bigger picture of the kinds of ripple-through effects the dominant players on the internet can have. It is almost [impossible for monopolies not to do harm](http://gigaom.com/2010/02/26/the-myth-of-the-benign-monopoly/), not because anyone within them sets out to, but simply because they are so large that their behaviour is that much more important than anyone else's.

The kinds of effects described above -- ones that result in an overall sub-optimal outcome for society as a whole -- are why society has [competition laws](http://en.wikipedia.org/wiki/Competition_law) that constrain monopolies and [cartels](http://en.wikipedia.org/wiki/Cartel). Sooner or later, [just as it did with Microsoft](http://en.wikipedia.org/wiki/European_Union_Microsoft_competition_case), society applies the corrective force of regulation. [There are already rumblings of this storm approaching.](http://www.huffingtonpost.com/2011/05/24/sarkozy-eg8-governments-regulate-internet_n_866065.html)

It is also why we have neutral standards bodies, such as the [W3C](http://www.w3.org/) or the [IETF](http://www.ietf.org/), which provide a [royalty-free patent policy](http://www.w3.org/Consortium/Patent-Policy/) as well as a [defined process](http://www.w3.org/Consortium/Process/) for developing specifications. These might seem tedious to comply with, and it might seem beneficial to companies to form a small cabal in order to get things done more quickly without having to seek wide consensus, but the bigger picture is that open standards developed within standards bodies protect companies from antitrust actions. Companies can point to royalty-free standards developed through a defined and fair process as proof of good behaviour that demonstrates their understanding of a wider responsibility to society as a whole.

As [Winston Churchill might have said](http://hansard.millbanksystems.com/commons/1947/nov/11/parliament-bill#column_207):

> Many ways of developing standards have been tried and will be tried in this world of sin and woe. No one pretends that standards bodies are perfect or all-wise, and it has been said that developing standards within standards bodies is the worst possible way to do it except all those other ways that have been tried from time to time.

Objections to schema.org may seem to be [sour grapes](http://hsivonen.iki.fi/schema-org-and-communities/) because they didn't use a particular existing syntax or vocabulary, but look deeper and the issues schema.org raises are all about the responsibilities of monopolies and the role of open standards. The parallels with HTML, IE and Microsoft are striking; it will be interesting to see if this turns out the same way.
