---
layout: drupal-post
excerpt_separator: "<!--break-->"
title: Lessons for Microdata from schema.org
created: 1307737658
tags:
- html5
- microdata
- schema.org
---
There is (obviously, from the way my tweet stream, feed reader and email have filled up) lots to say at many levels about [schema.org](http://schema.org/), a new collaboration between Google, Microsoft and Yahoo! that describes the next phase in search engines' extraction of semantics from web pages. In this post I'm going to focus on what we can learn from schema.org about the design of [microdata](http://www.w3.org/TR/microdata/) and how it might be improved.

<!--break-->

Digging into the details of schema.org there are several examples of places where its recommended method of marking up metadata directly contradicts the HTML5 specs. Given the number of internal contradictions within schema.org, I'm assuming that these are mistakes that will be corrected as the material is reviewed and matures rather than deliberate forking of HTML5.

> *Note: What I say about HTML5 here is equally true -- at least at time of writing -- of the WHATWG version of HTML, which of course already diverges from HTML5.*

One of the inputs to the design of microdata was to look at the mistakes that people make and try to design something to address the cause of those errors, so it's interesting to apply that method to the errors made by schema.org. This doesn't mean changing specs so that erroneous markup is conformant, but it does mean providing facilities that enable people to more easily do things in a conformant way, removing the temptation of non-conformance and lowering the likelihood of future mistakes.

> *Note: I am certain that there would also have been errors had schema.org used RDFa or microformats, indeed I gather that they are common in the documentation of [Google's Rich Snippets](http://www.google.com/support/webmasters/bin/answer.py?answer=99170).*

## Use of `<time>` element

The first example is one [spotted by Tantek](http://tantek.com/2011/155/t5/schemaorg-html5-fork-smoke-openinghours-time-duration): the value of the `openingHours` property of [EventVenue](http://schema.org/EventVenue) is described as:

> The opening hours for a business. Opening hours can be specified as a weekly time range, starting with days, then times per day. Multiple days can be listed with commas ',' separating each day. Day or time ranges are specified using a hyphen '-'.
>
> - Days are specified using the following two-letter combinations: `Mo`, `Tu`, `We`, `Th`, `Fr`, `Sa`, `Su`.
> - Times are specified using 24:00 time. For example, 3pm is specified as `15:00`.
>
> Here is an example: `<time itemprop="openingHours" datetime="Tu,Th 16:00-20:00">Tuesdays and Thursdays 4-8pm</time>`

A similar error involving the `<time>` element can be found on the [Getting Started page](http://schema.org/docs/gs.html#advanced_dates) which has an example in which the `datetime` attribute contains an ISO 8601 *duration*:

> Durations can be specified in an analogous way using the time tag with the datetime attribute. Durations are prefixed with the letter P (stands for "period"). Here's how you can specify a recipe cook time of 1 ½ hours:
>
>     <time itemprop="cookTime" datetime="P1H30M">1 1/2 hrs</time>
>
> H is used to designate the number of hours, and M is used to designate the number of minutes.

According to the HTML5 specification, the `datetime` attribute holds a [valid date or time string](http://www.w3.org/TR/html5/Overview.html#valid-date-or-time-string) which is specified as using the normal ISO 8601 syntaxes for dates and times. [Conforming HTML5 document](http://www.w3.org/TR/html5/Overview.html#conforming-html5-documents) must not hold the syntax used in the above example. From what I can tell (please correct me if I have this wrong), [conforming data-mining tools](http://www.w3.org/TR/html5/Overview.html#data-mining) *can* process this syntax because they use the [value of the `datetime` content attribute](http://www.w3.org/TR/microdata/#values), rather than the value of the `dateTime` IDL attribute to provide the property's value, but from an authoring perspective, no one should be encouraging people to create non-conformant HTML5.

In fact, given that values from microdata are never typed, it's not clear why these examples use the `<time>` element at all. The conformant way to provide the data would be to use a separate `<meta>` element to hold the data:

    <meta itemprop="openingHours" content="Tu,Th 16:00-20:00">
    Tuesdays and Thursdays 4-8pm

But I can understand the itch to use the `<time>` element here; the `<meta>` element above is *before*, rather than *around*, the textual content of the page which it reflects, whereas with the `<time>` element it is more obviously an explicit machine-readable version of that content. In microformats, the pattern is to use a `title` attribute:

    <span class="openingHours" title="Tu,Th 16:00-20:00">
      Tuesdays and Thursdays 4-8pm
    </span>

and in RDFa a `content` attribute:

    <span property="openingHours" content="Tu,Th 16:00-20:00">
      Tuesdays and Thursdays 4-8pm
    </span>

So maybe this error is an indication that microdata needs an `itemvalue` attribute for those cases where the human-readable content can be expressed in a more formal machine-readable microsyntax, with special handling with the `<time>` element for the case when the value is a date/time and `href`/`src` when the value is a URI.

## String parsing of URIs

The second example of non-conformance with HTML5 in schema.org is the method by which they [support extensibility](http://schema.org/docs/extension.html). Schema.org provides a set of types for the things described by web pages. Naturally, this set does not cover everything, but search engines still want to be able to use the metadata within the page about a `Person` even when that `Person` is described as a `Minister` (say).

So schema.org says that to extend their type hierarchy, you simply append the name of the new type after a `/` at the end of the URI for the parent type. In this example, a `Minister` should be given the type `http://schema.org/Person/Minister`.

My guess (as I can't see any other way in which they'd do it) is that the search engines intend to use string processing on the type URI in order to work out whether it's a subtype of a known type (ie, does the URI start with the string `http://schema.org/Person`? If it does, it's a Person of some kind).

The [microdata specification](http://www.w3.org/TR/2011/WD-microdata-20110525/#items) states that:

> The item type must be a type defined in an [applicable specification](http://www.w3.org/TR/html5/Overview.html#other-applicable-specifications).

and that:

> Item types are opaque identifiers, and user agents must not dereference unknown item types, or otherwise deconstruct them, in order to determine how to process items that use them.

Treating URIs as opaque identifiers, and forbidding inferring semantic meaning through string processing, is a fairly fundamental web architectural principle as well as fitting with microdata's constraint that types are specified somewhere.

Perhaps the gloss is that schema.org is an applicable specification that states that any URI that looks like `http://schema.org/{known-type}/{extension-type}` is a type that is defined in schema.org. But I think what's actually happening is that schema.org wants to grow their vocabulary organically, responding to the data that the search engines find on the web. They recognise that people will want to use their own vocabularies for their own purposes (for example to provide data for scripts, reusers, or for browsers and other agents that aren't search engines) but want to continue to be able to understand the semantics of that data.

Schema.org is constrained in the mechanisms that it could use to recognise these new types:

  * they can't resolve the type URI and expect metadata at the end of it to indicate the parent schema.org type, because the HTML5 microdata specification forbids resolving unrecognised item type URIs; even if they were allowed to do so, working out inheritance by declarative mechanisms that involve resolving URIs and interpreting the results is computationally expensive compared to string munging; for search engines that expect to do this with billions of web pages, this may be a significant processing burden
  * they can't tell people to use the schema.org type in addition to their own type because the HTML5 microdata specification doesn't allow an item to have more than one type; if it did, they could encourage people to use the schema.org type as well as their more specific one, so rather than `itemtype="http://schema.org/Person/Minister"`, enable publishers to do `itemtype="http://schema.org/Person http://reference.data.gov.uk/def/central-government/Minister"`

I suspect that having multiple types is currently disallowed in microdata because the semantics of the (non-URI) properties of an item are based on its type, but I think that microdata could handle multiple types for an item if instead of saying:

> If the item is a typed item: [the property token must be] a defined property name allowed in this situation according to the specification that defines the relevant type for the item

it said:

> If the item is a typed item: [the property token must be] a defined property name allowed in this situation according to any of the specifications that define the relevant types for the item; if the property is defined for more than one type, these definitions must be identical

It's worth noting that, unlike `itemtype`, the `itemprop` attribute *can* take multiple values which, along with its ability to take URIs, provides for an easier inheritance mechanism. However, schema.org again recommends a string-based approach for extended properties; maybe that's for consistency, or perhaps the real reason is that they want to become a centralised repository for acceptable microdata on the web.

## Summary

Whatever method publishers use, creating structured machine-processable data is hard and embedding it in a page is even harder. It is a layer that necessarily sits above or alongside the content of a page, invisible to people simply looking at the page in a browser and therefore difficult to get right without additional tooling.

Microdata specifically aims to make this easy to do; schema.org demonstrates some of the ways in which it doesn't *quite* meet that requirement. Perhaps the search engines behind the effort haven't managed to (or bothered to) implement HTML5/microdata parsing correctly or perhaps the people writing the documentation thought they understood how HTML5/microdata works but actually didn't. 

Either way, the mistakes are worth learning from to improve the specs while they are not yet final. As I discussed above I think that means:

  * adding an `itemvalue` attribute for machine-readable versions of content
  * enabling `itemtype` to take multiple values to support extensibility

though I suspect the latter point at least will be contentious among those who don't think decentralised extensibility is ever a desirable feature.
