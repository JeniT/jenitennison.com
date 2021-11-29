---
layout: drupal-post
excerpt_separator: "<!--break-->"
title: Using Multiple Vocabularies in Microdata
created: 1311841521
tags:
- microdata
- schema.org
---
I [wrote the other day](http://www.jenitennison.com/blog/node/160) about how [legislation.gov.uk](http://www.legislation.gov.uk/) needs to share data at three levels to satisfy its goals as a website:

  * large-scale consumers such as search engines
  * small-scale consumers that provide us with a useful service
  * specialist consumers that are interested specifically in our data

and the requirement to use multiple, incrementally more specialised, vocabularies to describe the same things as a result.

What I want to do here is explore how a publisher might handle this kind of situation using microdata. The ground has already been substantially covered by [Stéphane Corlosquet](http://openspring.net/blog/2011/06/10/microdata-multiple-vocabularies); what I do here is work through an example where the consumers are microdata's primary targets -- search engines and browsers -- look at why it's hard to fix this within microdata itself, and discuss how people who create vocabularies to be used with microdata might help publishers who find themselves in this situation by designing those vocabularies to be used together as well as on their own.

<!--break-->

## Use Case ##

I'm going to use [Lanyrd](http://lanyrd.com/) from [Simon Willison](http://simonwillison.net/) and [Natalie Downe](http://natbat.net/) as an example. Lanyrd is "the social conference directory": it keeps track of conferences that you're attending or speaking at, and lets you know about ones that your friends (or at least the people you follow on Twitter) are going to as well, as well as providing a bunch of other useful facilities.

Lanyrd currently uses microformats to mark up events so that nice summaries appear within search engine results. Here's a (slightly simplified for concision) example from the front page:

    <li class="conference vevent">
      <h3><a href="/2011/oscon/" class="summary url">OSCON 2011</a></h3>
      <p class="location">
        <a href="/places/usa/">United States</a> / <a href="/places/portland/">Portland</a>
      </p>
      <p class="date">
        <abbr class="dtstart" title="2011-07-25">25th</abbr>–
        <abbr class="dtend"   title="2011-07-29">29th July 2011</abbr>
      </p>
      ...
    </li>

This is easy enough to understand: OSCON 2011 has a URL of [`http://lanyrd.com/2011/oscon/`](http://lanyrd.com/2011/oscon/), is located in Portland (US), starts on 25th July and ends on 29th July 2011.

Say that Lanyrd decided to switch to using [schema.org](http://www.schema.org/) microdata. The markup would change to something like the following:

    <li class="conference" itemscope 
        itemtype="http://schema.org/Event" itemid="/2011/oscon/">
      <h3>
        <a itemprop="url" href="/2011/oscon/">
          <span itemprop="name">OSCON 2011</span>
        </a>
      </h3>
      <p itemprop="location" itemscope 
         itemtype="http://schema.org/Place" itemid="/places/portland/">
        <span itemprop="name">
          <a href="/places/usa/">United States</a> / <a itemprop="url" href="/places/portland/">Portland</a>
        </span>
      </p>
      <p class="date">
        <time itemprop="startDate" datetime="2011-07-25">25th</time>–
        <time itemprop="endDate"   datetime="2011-07-29">29th July 2011</time>
      </p>
      ...
    </li>

A few notes, because there were some design decisions involved in this mapping:

  * I've used a plain [`http://schema.org/Event`](http://schema.org/Event) because I wasn't sure how to classify a conference -- is it a `SocialEvent` or a `BusinessEvent` or an `EducationEvent`? Depends on the conference, I guess
  * I've assumed that the URIs for both the conference and its location are also item identifiers
  * I've changed the markup a bit to add `<span>` elements where necessary to get the desired data out, namely around the names of the conference and the place; I could have used separate `<meta>` or `<link>` elements instead but that would have meant repetition of data within the page

All well and good.

Now let's say that browsers start to support the [vEvent vocabulary defined within the WHATWG HTML microdata specification](http://www.whatwg.org/specs/web-apps/current-work/multipage/microdata.html#vevent) and offer some really nice functionality: because there's a clear mapping to iCalendar, they enable users to drag an event from the browser to a calendar application, and have it create an entry within the calendar.

Say Lanyrd really want to take advantage of this. It means marking up their pages in something like a mix between the two examples we've looked at so far -- microdata syntax but with the vEvent vocabulary (which is based on the hCalendar microformat vocabulary) rather than the schema.org vocabulary:

    <li class="conference" itemscope 
        itemtype="http://microformats.org/profile/hcalendar#vevent" itemid="/2011/oscon/">
      <h3>
        <a itemprop="url" href="/2011/oscon/">
          <span itemprop="summary">OSCON 2011</span>
        </a>
      </h3>
      <p itemprop="location">
        <a href="/places/usa/">United States</a> / <a href="/places/portland/">Portland</a>
      </p>
      <p class="date">
        <time itemprop="dtstart" datetime="2011-07-25">25th</time>–
        <time itemprop="dtend"   datetime="2011-07-29">29th July 2011</time>
      </p>
      ...
    </li>

But now Lanyrd have a dilemma. If they mark up their pages using the schema.org vocabulary, they can't take advantage of the browser drag-and-drop support; if they mark up their pages using the vEvent vocabulary they won't get their pages displaying nicely in search engine results. They can get the benefits from one consumer or the other but not both at the same time. What to do?

## Publisher Workarounds ##

What could Lanyrd do to work around this problem?

### Different Syntaxes ###

The first, eminently pragmatic, workaround, would be to use different syntaxes to encode the event information for the two different consumers. Since schema.org is likely to continue to understand microformats for the forseeable future, Lanyrd could stick to their original microformat markup and just add similar microdata for browsers to pull out to create iCalendar data. The page would look like:

    <li class="conference vevent" itemscope 
        itemtype="http://microformats.org/profile/hcalendar#vevent" itemid="/2011/oscon/">
      <h3>
        <a itemprop="url" class="url" href="/2011/oscon/">
          <span itemprop="summary" class="summary">OSCON 2011</span>
        </a>
      </h3>
      <p itemprop="location" class="location">
        <a href="/places/usa/">United States</a> / <a href="/places/portland/">Portland</a>
      </p>
      <p class="date">
        <time itemprop="dtstart" class="dtstart" datetime="2011-07-25">25th</time>–
        <time itemprop="dtend"   class="dtend"   datetime="2011-07-29">29th July 2011</time>
      </p>
      ...
    </li>

In other words, they could handle their requirement by not using microdata for one of the vocabularies. I don't think this is a particularly acceptable solution, given that schema.org specifically wants publishers to use microdata, but it would work.

### Repeated Data ###

A second workaround that Lanyrd could use would be to have some shadow markup for the data targeted at schema.org; the visible event information in the page itself should still be marked up using the vEvent vocabulary because it gives an area of the page that users can drag and drop. The basic version of this would look like:

    <li class="conference">
      <!-- data for browsers -->
      <span itemscope 
        itemtype="http://microformats.org/profile/hcalendar#vevent" itemid="/2011/oscon/">
        <h3>
          <a itemprop="url" href="/2011/oscon/">
            <span itemprop="summary">OSCON 2011</span>
          </a>
        </h3>
        <p itemprop="location">
          <a href="/places/usa/">United States</a> / <a href="/places/portland/">Portland</a>
        </p>
        <p class="date">
          <time itemprop="dtstart" datetime="2011-07-25">25th</abbr>–
          <time itemprop="dtend"   datetime="2011-07-29">29th July 2011</abbr>
        </p>
        ...
      </span>
      
      <!-- data for search engines -->
      <span itemscope itemtype="http://schema.org/Event" itemid="/2011/oscon/">
        <link itemprop="url" href="/2011/oscon/">
        <meta itemprop="name" content="OSCON 2011">
        <span itemprop="location" itemscope 
              itemtype="http://schema.org/Place" itemid="/places/portland/">
          <link itemprop="url" href="/places/portland/">
          <meta itemprop="name" content="United States / Portland">
        </span>
        <time itemprop="startDate" datetime="2011-07-25"></time>
        <time itemprop="endDate"   datetime="2011-07-29"></time>
        ...
      </li>
    </li>

Note: I've used empty `<time>` elements to mark up the dates for the conference in the schema.org shadow data because the microdata spec says "If a property's value represents a date, time, or global date and time, the property must be specified using the `datetime` attribute of a `time` element." They're empty, though, so they won't be displayed on the page.

There are a few issues with this workaround:

  * it repeats content and thus bloats the page
  * in the microdata DOM API, there now appear to be two items when really there's one conference; this might not be a big deal if scripts access items by type rather than just getting all the items
  * search engines might (wild speculation follows) be more suspicious of data that isn't visible within the page; there's no way for schema.org to know that the same data appears visibly elsewhere with equivalent markup

### Use `itemref` ###

A third possibility for Lanyrd would be to something similar to the previous example but use the `itemref` attribute to point to any shared data. Unfortunately in this case, there's only one property that's actually shared (with the same semantics) between the two vocabularies -- `url` -- so using this technique doesn't improve the markup all that much from the previous example:

    <li class="conference">
      <!-- data for browsers -->
      <span itemscope 
        itemtype="http://microformats.org/profile/hcalendar#vevent" itemid="/2011/oscon/">
        <h3>
          <a id="oscon-url" itemprop="url" href="/2011/oscon/">
            <span itemprop="summary">OSCON 2011</span>
          </a>
        </h3>
        <p itemprop="location">
          <a href="/places/usa/">United States</a> / <a href="/places/portland/">Portland</a>
        </p>
        <p class="date">
          <time itemprop="dtstart" datetime="2011-07-25">25th</abbr>–
          <time itemprop="dtend"   datetime="2011-07-29">29th July 2011</abbr>
        </p>
        ...
      </span>
    
      <!-- data for search engines -->
      <span itemscope itemtype="http://schema.org/Event" itemid="/2011/oscon/"
        itemref="oscon-url">
        <meta itemprop="name" content="OSCON 2011">
        <span itemprop="location" itemscope 
              itemtype="http://schema.org/Place" itemid="/places/portland/">
          <link itemprop="url" href="/places/portland/">
          <meta itemprop="name" content="United States / Portland">
        </span>
        <time itemprop="startDate" datetime="2011-07-25"></time>
        <time itemprop="endDate"   datetime="2011-07-29"></time>
        ...
      </li>
    </li>

In other situations, where there is more overlap in the property names used by the two types, there might be more advantage in this approach.

### Content Negotiation ###

A final workaround would be for Lanyrd to serve up an HTML page that uses the schema.org vocabulary to search engines and an HTML page that uses the vEvent vocabulary to browsers, by sniffing the `User-Agent` header.

This has the advantage of not having to try to cram two conflicting vocabularies into a single page but the disadvantage of having to code for the content negotiation. Essentially, it shifts the complexity and repetition from the HTML page to the code that generates the HTML page, but does address the three disadvantages that I listed for the 'repeated content' solution described above.

## Publisher Workarounds ##

Lanyrd could also lobby schema.org and/or WHATWG to make changes to what data they consume.

### Lobby for Convergence ###

Lanyrd could lobby schema.org to understand the vEvent vocabulary and/or WHATWG to specify browser handling of the schema.org vocabulary.

This might work, but the vocabularies do have different goals and requirements, which might make it hard to unify them: vEvent maps neatly and easily to iCalendar, schema.org is oriented around Rich Snippets in search engine results. The modelling of the `location` property in each shows this different emphasis: it only needs to map to a string in iCalendar so there's no need to model the location as an item itself, but in search engine results it's useful to link to the location, display a map and so on, which is only possible if the location is modelled as an item in its own right.

### Lobby for Different Processing ###

Finally, Lanyrd could lobby schema.org and/or WHATWG to trigger their recognition of an event based on something other than the `itemtype` of an item, and to interpret full URIs for properties in the same way as equivalent short names.

For example, currently the [conversion of vEvent to iCalendar defined in the WHATWG HTML specification](http://www.whatwg.org/specs/web-apps/current-work/multipage/microdata.html#conversion-to-icalendar) is triggered by the presence of an item that is an vEvent:

> If none of the nodes in nodes are items with the type `http://microformats.org/profile/hcalendar#vevent`, then there is no vEvent data. Abort the algorithm, returning nothing.

Let's say that it were instead triggered by items with *either*:

  * an `itemtype` of `http://microformats.org/profile/hcalendar#vevent` *or*
  * a `http://microformats.org/profile/hcalendar#type` of `vevent`

and that in the former case, it would read short name properties but in the latter case it would read properties with URIs like `http://microformats.org/profile/hcalendar#location`.

In that case, Lanyrd could use the schema.org vocabulary for the type given in the `itemtype` attribute, but markup extra properties for the item using the vEvent property URIs. The markup would be something like:

    <li class="conference" itemscope 
        itemtype="http://schema.org/Event" itemid="/2011/oscon/">
      <meta itemprop="http://microformats.org/profile/hcalendar#type" content="vevent">
      <h3>
        <a itemprop="url http://microformats.org/profile/hcalendar#url" href="/2011/oscon/">
          <span itemprop="name http://microformats.org/profile/hcalendar#summary">OSCON 2011</span>
        </a>
      </h3>
      <p itemprop="location" itemscope 
         itemtype="http://schema.org/Place" itemid="/places/portland/">
        <span itemprop="name">
          <a href="/places/usa/">United States</a> / <a itemprop="url" href="/places/portland/">Portland</a>
        </span>
      </p>
      <meta itemprop="http://microformats.org/profile/hcalendar#location" 
            content="United States / Portland">
      <p class="date">
        <time itemprop="startDate http://microformats.org/profile/hcalendar#dtstart" 
              datetime="2011-07-25">25th</time>–
        <time itemprop="endDate   http://microformats.org/profile/hcalendar#dtend"   
              datetime="2011-07-29">29th July 2011</time>
      </p>
      ...
    </li>

Note that here the location has to be repeated because vEvent expects a string while schema.org expects an item.

The same kind of pattern could work the other way around: schema.org could recognised events based on a `http://schema.org/type` property with the value `Event`, and understand property URIs that were equivalent to each of the short-name properties that it uses. (Such [URIs for schema.org properties](http://schema.org/schema.owl) already exist.)

## Multiple Types for Microdata Items ##

Earlier this year there was some [discussion on the WHATWG mailing list](http://lists.whatwg.org/htdig.cgi/whatwg-whatwg.org/2011-June/032243.html) about the requirement for multiple types for items.

The use cases there were not the same multiple-consumers use case that I have outlined above, but around support for inheritance in types. For example, schema.org lets people define their own types in the schema.org domain, such as `http://schema.org/Event/Conference`. There's no way of exposing the type hierarchy explicitly (that all `Conference`s are `Event`s) so scripts that use microdata's DOM API to search for items of the type `http://schema.org/Event` won't find conferences. The discussion was about alleviating this by allowing publishers to put both `http://schema.org/Event` and `http://schema.org/Event/Conference` within the `itemtype` attribute. Alternatively, a conference could be typed as a `SocialEvent`, `BusinessEvent` *and* a `EducationEvent`, enabling it to take properties from all three.

The conclusion of the discussion was that it just wasn't possible to use what would seem to be the obvious method of assigning multiple types to an item: having a space-separated list in the `itemtype` attribute. If we look at the markup that you would get for this example, we can see why there's a problem:

    <li class="conference" itemscope itemid="/2011/oscon/"
        itemtype="http://schema.org/Event http://microformats.org/profile/hcalendar#vevent">
      <h3>
        <a itemprop="url" href="/2011/oscon/">
          <span itemprop="name summary">OSCON 2011</span>
        </a>
      </h3>
      <p itemprop="location" itemscope 
         itemtype="http://schema.org/Place" itemid="/places/portland/">
        <span itemprop="name">
          <a href="/places/usa/">United States</a> / <a itemprop="url" href="/places/portland/">Portland</a>
        </span>
      </p>
      <meta itemprop="location" content="United States / Portland">
      <p class="date">
        <time itemprop="startDate dtstart" datetime="2011-07-25">25th</time>–
        <time itemprop="endDate   dtend"   datetime="2011-07-29">29th July 2011</time>
      </p>
      ...
    </li>

There are two issues with this markup. First, the definitions of the two types (in prose within the two specs) have different expectations about:

  * what properties will be present: schema.org expects a `name` property and not a `summary` property, and vice versa for vEvent; similarly for `startDate`/`dtstart` and `endDate`/`dtend`
  * what values the properties will have: schema.org expects `location` to have an item value whereas vEvent expects a string

The result is that the mixed markup isn't conformant with either vocabulary, and hence not a conformant HTML document. (Whether microdata consumers do anything about that non-conformance is a different question -- they could just ignore properties that they don't understand, or with value types that they don't expect.)

Second, if the data is turned into any kind of format that needs full URIs for properties, such as RDF through [microdata's RDF mapping](http://www.whatwg.org/specs/web-apps/current-work/multipage/microdata.html#rdf), it's impossible to tell what type URI to use as the basis of that URI. If the item is assigned *just* the schema.org type, the `name` property would map to the URI:

    http://www.w3.org/1999/xhtml/microdata#http://schema.org/Event%23:name

If there is *just* the vEvent type, the `summary` property would map to the URI:

    http://www.w3.org/1999/xhtml/microdata#http://microformats.org/profile/hcalendar%23vevent:summary

When the item has more than one type, there is no way to know which type should be used as the basis of the URI generated for the property, or even if *both* should be used, as in the properties used by both vocabularies such as `url`.

(This issue isn't specific to the RDF mapping defined in the microdata specification; it would arise in any RDF mapping from microdata, or any mapping in which short names for properties needed to be turned into globally unique terms.)

## Guidance for Microdata Vocabularies ##

Having short names for properties makes writing microdata simple. They are much easier on the fingers and the eye than URIs, and, because they are scoped by type rather than vocabulary, they can be given simple names while still being specified tightly in terms of the types on which they can appear and the values that they can take. For example, the `location` of an `Event` can be limited to a geographical place while the `location` of a `Click` can be specified in terms of a point on a web page, rather than having to use more complex property names like `placeLocation` and `pointLocation`.

This could be a particular advantage in large and wide-ranging vocabularies such as schema.org's where it's likely that at some point there will be a clash in meaning between properties with the same name for different things. (Though the flip side for schema.org is that it has lots of inherited properties which really do have the same meaning across subtypes.)

The biggest problem with short names arise when you want to provide data to different consumers that use different vocabularies for that data. My guess is that in real life, in many cases this won't be an issue, and certainly microdata has been designed with that assumption. Realistically, the majority of websites will probably only care about embedding data in web pages to the extent that search engines will read it, and will therefore only use one vocabulary -- schema.org's. Where more than one vocabulary *is* used in the page, it may well be that they are used in different locations (eg OGP for Facebook in the head of a page, schema.org in the body), or to mark up data about completely different kinds of things.

However, if you're a publisher who wants to provide data to multiple consumers who understand different vocabularies -- search engines *and* browsers as in the Lanyrd example above, for example -- and those consumers define what they will consume solely based on the `itemtype` of an item, then you're going to have to either workaround consumer's behaviour as I described above, or ask those consumers to change how they work.

The most promising direction I can see at the moment would be to ask consumers to define their vocabularies such that they include

  1. a property that is used to identify the in-vocabulary type of items whose `itemtype` is not in that vocabulary
  2. defined URIs for properties that are equivalent (and processed in the same way as) the short name properties for a given type

The type-defining property *could* be `http://www.w3.org/1999/02/22-rdf-syntax-ns#type`, with the value being the URI of the relevant type. However,

    <link itemprop="http://www.w3.org/1999/02/22-rdf-syntax-ns#type"
          href="http://schema.org/Event">

is a lot more verbose than:

    <meta itemprop="http://schema.org/type" content="Event">

so I imagine that the designers of microdata vocabularies would prefer to ask publishers to do the latter. On the other hand, if publishers are using multiple vocabularies, they might find it easier to use a consistent type-defining property across vocabularies; it's hard to tell what the global usability payoffs might be here.

Or microdata could standardise the pattern by adding an attribute (eg `itemkind`, `iteminherit`, `itemothertype`, `itemmixin`, I dunno) which would list additional types. These could be exposed within the DOM API (which would be a big advantage for in-page scripts) but not used in the interpretation of short-name properties.

Vocabularies that don't support processing of items based on a type-defining property and property URIs are effectively indicating that they don't anticipate being mixed with others that have *also* made the same assumption that they won't be mixed with others. Currently, for example, schema.org and the vocabularies defined within the WHATWG microdata specification both make this assumption. Working with one vocabulary that makes that assumption for a particular type is fine; working with two in microdata is much harder.
