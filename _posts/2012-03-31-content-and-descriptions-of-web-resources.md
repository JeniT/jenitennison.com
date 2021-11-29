---
layout: drupal-post
excerpt_separator: "<!--break-->"
title: Content and Descriptions of Web Resources
created: 1333229228
tags:
- rest
- linked data
- tag
---
Those readers who follow the [TAG](http://lists.w3.org/Archives/Public/www-tag/) or [public-lod](http://lists.w3.org/Archives/Public/public-lod/) mailing lists over the last couple of weeks cannot have failed to notice a large number of posts on a theme that recurs on roughly a 9-monthly cycle within these communities: [httpRange-14](http://www.w3.org/2001/tag/group/track/issues/14).

The reason for this particular recurrence was a [Call for Change Proposals](http://www.w3.org/2001/tag/doc/uddp/change-proposal-call.html) on the resolution. The TAG meets on Monday, and discussion of this issue is one of the first items on [our agenda](http://www.w3.org/2001/tag/2012/04/02-agenda). These are my thoughts going in to that discussion.

<!--break-->

## The Questions ##

The recent discussion on the lists has, I think, helped to refine the questions that lie at the core of the httpRange-14 issue. They are:

  1. When you get a successful response from a URI, does that response, by definition, include the *content* of the resource identified by the URI?
  2. How can you discover a *description* of the resource identified by a URI?

Knowing whether the response to a URI provides the content of the resource identified by that URI is important because when you have data about the thing identified by a URI, such as its author or the license that it is provided under, you need to know what information is actually being referred to so that you can tell what information you can reuse and whom you have to attribute. 

For example, the [GOV UK](http://www.gov.uk/) website has a license at the bottom of each page:

    <p>
      Much of the information on this website is available for reuse under the 
      <a href="http://www.nationalarchives.gov.uk/doc/open-government-licence/" 
         rel="licence">Open Government Licence</a>
    </p>

Seeing this, an application that knows the [Open Government License](http://www.nationalarchives.gov.uk/id/open-government-licence/) enables free reuse can tell that it can lift content out of the page and use it on their own site. An application could automatically scrape out and republish the first paragraph of those [news stories](https://www.gov.uk/government/news-and-speeches) provided on this site and any others that were published with under this license.

## The Conflict ##

There are vocal disagreements about particularly the first of the two questions I outlined above. What's become clear to me is that the source of the arguments stem from a difference in world view about what kind of resources are available on the web.

## Web of Data ##

Under the *web of data* view, the web consists of data, and all the resources on the web are *information resources*, defined as those [resources whose essential characteristics can be conveyed in a message](http://www.w3.org/TR/webarch/#def-information-resource). Data, in other words.

URIs can still be used to name other resources, which are not on the web either because they are not information resources (such as a Person) or because they are not available yet (such as unscanned books). Under this world view, however, giving a successful HTTP response for such a resource is simply wrong, because these resources aren't on the web.

The problem that this world view therefore needs to address is how to create URIs to identify resources that aren't on the web. There are two answers:

#### Hash URIs ####

Hash URIs have the benefit that there is a direct relationship between the hash URI which identifies the resource and a resource on the web that describes it. An HTTP client naturally strips the fragment identifier from the URI in order to make the request to a server, which then delivers the description of the resource.

#### 303 Redirections ####

If you identify a resource that isn't on the web using an HTTP URI that is not a hash URI, you cannot get a successful response back because the resource you have asked for is, by definition in this world view, not on the web. The workaround is for the publisher to use the [303 See Other](http://tools.ietf.org/html/draft-ietf-httpbis-p2-semantics-19#section-7.3.4) status code to point from the resource that you requested to its description on the web. (This is the essence of [the httpRange-14 resolution](http://lists.w3.org/Archives/Public/www-tag/2005Jun/0039.html).)

### Web of Things ###

Under the *web of things* view, the web consists of things, and resources on the web could be anything: documents, people, films, teapots and so on. When a client makes an HTTP request for a resource, the response must reflect the state of the resource, but that state could be its content (if it's an information resource) or it could be a description of the resource.

Under this world view, giving a successful HTTP response for a resource that isn't an information resource is absolutely fine: the description of the resource is still a reflection of its state.

The problem that needs to be addressed when you have this world view becomes apparent when you think back to the licensing example above. Given an application knows that the resource identified by a given URI can be reused, how does it know whether the representation of that resource is reusable? It could be that the identified resource (for example an out-of-copyright book) has an open license, but that the representation of the resource holds only a description of that resource (some metadata about the book), and that description has a much more restrictive license. Or vice versa.

So to address this use case, you need some other mechanism to enable an application to tell that the representation is the content of the resource, rather than merely a description of it.

## The Current State ##

To generalise, the linked data community operates within the *web of data* world view and the larger web community operates within the *web of things* world view.

What is happening increasingly, however, is that these two world views are rubbing up against each other, and while both are internally coherent, switching between the world views causes not only a cognitive disconnect for developers but practical problems when transforming or moving data published under one world view into the other world view.

In addition, publication of data on the web through APIs is growing all the time, particularly [REST APIs](https://en.wikipedia.org/wiki/Representational_State_Transfer) supporting the [Hypertext as the Engine of Application State (HATEOAS) principle](https://en.wikipedia.org/wiki/HATEOAS). As we share more data on the web, and we use URIs in our APIs, the question of what those URIs mean and how we associate licenses and provenance information with data, will only become more important.

We have an obligation, therefore, to reflect on the experience from the linked data community over the last few years and how that experience might spread to the larger web community.

Discussions within the linked data community over the httpRange-14 resolution centre on two problems that people have encountered:

  1. the *web of data* vs *web of things* disconnect hurting adoption
  2. practical aspects of responding to requests with 303 redirections such as
     * round-trip delays, particularly as in HTTP 1.1 303s can't be cached
     * inability for people to use 303s without server admin access

## The Social Context ##

A bit of a side-point here. I think that the questions I posed at the start of this post are general questions about web architecture, so it puzzles me that the only people who seem to really care about them, and who debate them endlessly, are the linked data community. This is partly because the linked data community use URIs extensively to identify the things about which they provide data, but I think it's also about the fundamental attitude of those within the community, which was characterised in a [recent post](http://lists.w3.org/Archives/Public/public-lod/2012Mar/0185.html) by [Hugh Glaser](http://www.seme4.com/who-we-are/profile/hugh-glaser/):

> Personally, I never did agree with the solution [to httpRange-14], but have always aimed to carry out the implications of it in the systems I construct.
> 
> This is for two reasons:<br>
> a) as a member of a small community, it is destructive to do otherwise;<br>
> b) as a professional engineer, my ethical obligations require me to do so.
> 
> It is this second, the ethical obligations that are the most significant.<br>
> I should not digress from the standards, or even Best Practice, in my work.

The linked data community is jam packed with people who feel an ethical obligation to adhere to standards and best practices. We try to do what we are told is the Right Thing by individuals and standards organisations even when we don't agree that it is the Right Thing and even if it turns out to be impractical.

In the larger web community, people who don't agree with a standard or best practice, or who find it too impractical to implement, simply ignore it. There is no need to endlessly debate something that you can just ignore. And the httpRange-14 resolution is ignorable by the larger web community because so far it has had very little impact on any implementations at all, let alone widely-deployed implementations that work over the non-linked-data web.

## The Choices ##

Going into the TAG meeting about this on Monday, the main decision that I see is whether to continue to assume a *web of data* world view. In the *web of data* world view, it is impossible for a URI to return a description of a resource, whereas in the *web of things* world view it is fine. Personally, I would prefer to design around the *web of things* world view as I think this would ease some of the disconnects between linked data and the wider web, but there are others on the TAG who adhere strongly to the *web of data* view, so I think that change is unlikely.

If we stick with the *web of data* view, the main issues are how to alleviate the current practical difficulties that people are encountering with its implementation and explanation. I think there are three measures that would help:

  1. Determine a conventional syntax for fragment identifiers that are used to identify things that are not on the web, as opposed to fragments of content. I'm thinking something like hash-bang URIs: using a character after the hash character that just gives a quick indication that the fragment identifier is being used in a special way, to refer to something that isn't on the web rather than a fragment of a document, for example `#*`.
  
  2. Change to recommending a single best practice of using hash URIs for resources that aren't on the web, and in particular recommending having a one-to-one correspondence between resources on the web and those not on the web, using one particular conventional hash URI. For example, `http://www.whitehouse.gov/#*` would identify the resource that `http://www.whitehouse.gov/` is about: The Whitehouse. This ensures that new publishers of data won't run into the problems with publishing using 303 redirections, because they won't use that method of publication. It also removes choice, which helps adopters who can otherwise get overwhelmed with options and the trade-offs between them.
  
  3. Allow publishers who are currently using 303 redirections to publish descriptions of resources identified using non-hash URIs to switch to providing a representation using a 200 status code, along with a method of indicating that the representation is the *description* of the resource rather than its *content*. This indicator could be:
    * a new HTTP header or status code (though I'd prefer not)
    * a Link: header with a particular relationship (eg 'describedby')
    * a statement embedded in the response itself (eg a `<link rel="describedby">` element in HTML)

If we did move to a *web of things* view, the main question would be how to provide an indicator that the representation of a particular resource is the content of that resource as opposed to being a description. It would help ease transition if this was a natural consequence of the current pattern of publication on httpRange-14-compliant sites, so for example, you'd want to consider the representation of a resource the content of the resource if you got to it:

  * when retrieving a hash URI, if it was the part of the URI before the hash
  * when following a 303 See Other redirection, if it was the target of the redirection
  * when following a 'describedby' link, if it was the target of the link

as well as if there was an explicit indicator within the representation that said the resource was an information resource.

Whichever decisions are made, I would personally like to see the concrete requirements on client behaviour that arise from these different publication practices, for example enabling a reuser to associate a license with a particular piece of content or a crawler to create RDF statements about URIs encountered on the web, to bring whatever decisions are made down to earth and less ignorable.
