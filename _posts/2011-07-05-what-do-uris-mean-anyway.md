---
layout: drupal-post
excerpt_separator: "<!--break-->"
title: What Do URIs Mean Anyway?
created: 1309903593
tags:
- linked data
- uris
---
If you've hung around in linked data circles for any amount of time, you'll probably have come across the [httpRange-14 issue](http://www.w3.org/wiki/HttpRange14Webography). This was an issue placed before the [W3C TAG](http://www.w3.org/2001/tag/) years and years ago which has become a [permathread](http://en.wiktionary.org/wiki/permathread) on semantic web and linked data mailing lists. The basic question (or my interpretation of it) is:

> Given that URIs can sometimes be used to name things that aren't on the web (eg the novel Moby Dick) and sometimes things that are (eg the [Wikipedia page about Moby Dick](http://en.wikipedia.org/wiki/Moby-Dick)), how can you tell, for a given URI, how it's being used so that you can work out what a statement (say, about its author) means?

<!--break-->

One answer is to use a [hash URI](http://www.jenitennison.com/blog/node/154) whenever you want to refer to something that doesn't live on the web, with the base URI providing information about that thing. For example:

  * `http://en.wikipedia.org/wiki/Moby-Dick` is the URI for the Wikipedia page
  * `http://en.wikipedia.org/wiki/Moby-Dick#thing` is a URI for the novel itself

The problem some people (including me) have with this is that hash URIs are primarily used to indicate portions of a web page, and using them for things that aren't page fragments overloads them. It's also an inflexible method, because the server isn't told what the fragment identifier is, and therefore it can't be used as the basis for a redirection, for example.

The [2005 TAG resolution](http://lists.w3.org/Archives/Public/www-tag/2005Jun/0039.html) for people who wanted to use separate non-hash URIs, such as [*warning, made-up URIs*]

  * `http://en.wikipedia.org/wiki/Moby-Dick` is the URI for the Wikipedia page
  * `http://wikipedia.org/thing/Moby-Dick` is the URI for the novel itself

was:

  1. if you get a `2XX` response when you request a URI, that URI refers to a document (the document that you get back)
  2. if you get a `303` response when you request a URI, that URI could refer to anything, and the resource you get by following the redirection describes that thing (hence if a URI should refer to something that isn't on the web then requests to it should respond with a 303)
  3. if you get a `4XX` response when you request a URI, that URI could represent anything

This leads to the `303` pattern described for example within [Cool URIs for the Semantic Web](http://www.w3.org/TR/cooluris/#r303gendocument); in the example here, the response to `http://wikipedia.org/thing/Moby-Dick` would be a 303 redirection to `http://en.wikipedia.org/wiki/Moby-Dick`.

Six years later, we have a lot of experience about this technique of distinguishing between things that are or are not on the web, and it has a bunch of practical limitations.

  * it requires access to web server configuration (to add `303` redirections) that make life difficult for people without that level of access
  * URIs for things that aren't on the web always require two round-trips to get hold of information, as the first always responds with a `303` redirection, which adds server load and slows things down (this is made worse as `303` responses can't be cached -- an oversight in the HTTP spec that I gather is fixed in [HTTPbis](http://tools.ietf.org/wg/httpbis/))
  * using the `303` pattern requires a level of knowledge and understanding that is beyond most web developers, particularly if they get no benefit from taking care over their use of URIs (for example, Facebook, schema.org and so on all encourage the use of URIs for non-web things without a word about `303` redirections)
  * even people who do have this knowledge and understanding sometimes find it hard to work out whether a particular thing that they want to talk about is a thing-on-the-web or not and therefore whether the use of a `303` redirection is required
  * even people who *do* try to take care in their use of URIs easily make mistakes because we interact with URIs by copy-and-pasting them from browser address bars, and the only URIs that appear there are URIs for things on the web

Basically, while the web architectural principles behind the use of `303` redirections are (arguably!) sound, the collective experience of the past six years indicates that many publishers will not use it because they don't know to, because they don't care to, because they make mistakes or because they simply can't while meeting the other practical constraints of their project.

A number of other approaches have been suggested, before and after the TAG decision, many of which are documented within the draft TAG finding [Providing and discovering definitions of URIs](http://www.w3.org/2001/tag/awwsw/issue57/latest/).

The first observation that I want to make is that many of the objections to the `303` pattern are about the practicalities of publishers using it. Therefore, any suggestions to provide an alternative technique that involves

  * introducing new URI schemes (eg `tdb`)
  * introducing new HTTP methods (eg `MGET`)
  * introducing new HTTP status codes (eg `209`)
  * using particular HTTP headers (eg `Link` or `Content-Location` or other specialist headers)

are not going to be widely used for exactly the same reason. I'm not at all persuaded that it's worth spending time developing them.

My second observation is that there are three questions that are being conflated and we might make more progress if we separated them:

  * Must publishers provide separate URIs for things-on-the-web and the non-web-things that they describe?
  * How can you tell what a reference to a particular URI within a piece of data (eg an RDF statement) means?
  * How can you get from a URI to information about whatever that URI refers to?

## Ambiguity in URIs

Both the hash URI pattern and the `303` pattern make the assumption that you need to have separate URIs for things that are not on the web (eg books) and documents on the web about them (eg pages about books). This is useful because it enables people to make separate statements about the author of a book:

    <http://wikipedia.org/thing/Moby-Dick> 
      dct:creator <http://wikipedia.org/thing/Herman_Melville> ;
      .

from the authors of the Wikipedia page about that book:

    <http://en.wikipedia.org/wiki/Moby-Dick>
      dct:creator 
        <http://wikipedia.org/user/Aristophanes68> ,
        <http://wikipedia.org/user/SporkBot> ,
        <http://wikipedia.org/user/Curb_Chain> ,
        ...
      .

If we only have the URI `http://en.wikipedia.org/wiki/Moby-Dick` then we run into difficulties interpreting statements made about that URI, and indeed different people might use the URI in different ways, or make some statements that use the URI to mean the novel and some to mean the Wikipedia page.

So there are good reasons to have two separate URIs in these cases.

But the fact is that many publishers currently have a one-URI-fits-all policy. And even if they don't, people reusing those URIs will often make mistakes and use the wrong one. It would be nice if we could make the world see that this leads to all sorts of logical problems for the Semantic Web, but I just can't see that happening.

This situation reminds me of one of the central innovations that the web had over previous hypertext systems. There is a [great slide](http://www.w3.org/2006/09dc-aus/swpf#(7)) by [Dan Connolly](http://en.wikipedia.org/wiki/Dan_Connolly) which roughly looks like:

<blockquote>
  <table border="1">
    <tr>
      <th></th>
      <th>Web</th>
      <th>Semantic Web</th>
    </tr>
    <tr>
      <th>Traditional Design</th>
      <td style="text-align: center">hypertext</td>
      <td style="text-align: center">logic/database</td>
    </tr>
    <tr>
      <th>+</th>
      <td colspan="2" style="text-align: center">URIs</td>
    </tr>
    <tr>
      <th>-</th>
      <td style="text-align: center">link integrity</td>
      <td style="text-align: center">?</td>
    </tr>
    <tr>
      <th>=</th>
      <td colspan="2" style="text-align: center">viral growth</td>
    </tr>
  </table>
  <p>Are there parts of traditional logic and databases that, if we set them aside, will result in viral growth of the Semantic Web?</p>
</blockquote>

(By the way, in case my replication of this slide is interpreted incorrectly: I'm certainly not implying that viral growth of the Semantic Web as an end in itself, though I would like to see viral growth in data sharing.)

Dropping the requirement for link integrity, coping with the fact that sometimes links would break, was what made the web work. It would have been simply impossible to build the web as a decentralised system if there had been a requirement for links to always work.

Of course that doesn't mean that we *like it* when links get broken. There's oodles of best practice advice out there on making sure that you retain support for old URIs if you change your web space; we have backup systems in place in the form of web archives so we can work out what was once at the end of a particular URI; and the resolvability of links is something a linter will check about your website.

So it's not that when he developed the web TimBL rejected entirely the very concept of link integrity, it's that he recognised that we have to work with the imperfection of the real world. Links break. HTTP copes. Browsers cope. People cope.

The imperfection of the real world as it applies to linked data is that [URIs will be used in ambiguous ways](http://www.ibiblio.org/hhalpin/homepage/publications/indefenseofambiguity.html). We might not like it; we might write best practice documents that encourage people to have separate URIs for web-thing and non-web-thing, develop tools that help people detect when they've used the wrong URI, and so on. But it will still happen, and in my opinion we need to work out how to cope.

In fact, ambiguity in URIs goes much further than just a confusion between the Wikipedia page about Moby Dick and the novel Moby Dick itself. URIs are names, and names are used by different people to mean different things. The same URI might end up meaning:

  * the Wikipedia page about Moby Dick
  * the novel Moby Dick
  * the whale Moby Dick
  * the story Moby Dick (originally a novel but later adapted as a film)
  * *and so on*

Even if the publisher provides a clear and unambiguous definition about what the URI `http://en.wikipedia.org/wiki/Moby-Dick` means, other people will use it to mean something different because it's close enough for what they want to say.

So I think the answer to the first question I posed -- "Must publishers provide separate URIs for things-on-the-web and the non-web-things that they describe?" -- has to be "No, though it is good practice to." We can fight against ambiguity, but we have to accept that we cannot win.

## Disambiguating Statements

As discussed above, in a perfect world, we would have separate URIs for things-on-the-web and non-web-things and any data that we published about Moby Dick would use the URI for the Wikipedia page to talk about things like the licence for that information, or how the information was created (its provenance), and the URI for the novel to talk about things like the licence for the novel and what characters appeared in it.

But the world is not perfect, and we are going to end up with situations where the same URI is used to refer to a whole range of different things. How do we cope?

Well, first let me say that I don't see people merging data together willy-nilly and hoping to get something useful out of it. URIs give us connection points and RDF gives us a flexible data model, which means that merging data can be easier than the kinds of custom merging that you have to do with CSV and JSON, but I don't think it can ever remove entirely the requirement for curation. We want to ensure that the need for intervention in merging two datasets is kept to a minimum, but we can't expect it to be entirely removed.

So with that in mind, there are at least three techniques that can be used to get useful data out of a world in which the same URI is used to mean different things.

### One-Step-Removed Properties

The first technique is to interpret particular properties as describing a one-or-more-step-removed relationship between a resource and a value. For example, the `bib:author` and `dct:creator` properties would be defined such that the RDF statements

    <http://en.wikipedia.org/wiki/Moby-Dick>
      bib:author <http://en.wikipedia.org/wiki/Herman_Melville> ;
      dct:creator <http://en.wikipedia.org/wiki/User:Aristophanes68> ;
      .

would be interpreted as saying

> The **topic of the page** `http://en.wikipedia.org/wiki/Moby-Dick` was authored by the **topic of the page** `http://en.wikipedia.org/wiki/Herman_Melville`. The creator of the page `http://en.wikipedia.org/wiki/Moby-Dick` is the **topic of the page** `http://en.wikipedia.org/wiki/User:Aristophanes68`.

The biggest problem with the global application of this approach is that there are a lot of existing properties defined in vocabularies such as FOAF or Dublin Core that aren't defined as one-step-removed properties. One publisher might use `dct:creator` to link to "a page describing the creator of this page" and another might use it to point directly to a (non-web-thing) URI for the creator of the page. So practically, this approach requires the interpretation of properties to be done on a dataset-by-dataset basis. Which leads onto the next approach.

### Named Graphs

A second technique would be to make the assumption that within a single dataset, a single URI has a single meaning, but that the meaning may differ between datasets. I suspect that this is true even when publishers attempt to take care about which URI they use, because, like names, the meaning of a URI is slightly different depending on its use.

Re-users of data need to work out whether the way URIs are used in one dataset is close enough to the way they are used in another dataset, to ascertain whether it's appropriate to simply merge the datasets or whether something slightly more complicated needs to be done to bring the datasets together.

The problem with this approach is that it raises the barrier to joining together graphs: you can't just bung the data into a triplestore and perform queries on it, you have to work out some kind of mapping between the datasets up front.

### Duck Typing

The final technique that I'll talk about here is to say that different applications need to access different properties, and can ignore any properties that don't fit with how they want to use the data. It is relatively rarely useful to have generic RDF viewers; people (generally) build applications to answer questions and perform tasks, not to just browse around data.

For example, if a single dataset were to contain:

    <http://en.wikipedia.org/wiki/Moby-Dick>
      a bib:Book ;
      bib:author <http://en.wikipedia.org/wiki/Herman_Melville> ;
      a foaf:Document ;
      dct:creator <http://en.wikipedia.org/wiki/User:Aristophanes68> ;
      .

then an application that was interested in gathering data about books would only care about the fact that `http://en.wikipedia.org/wiki/Moby-Dick` was a book with an author of `http://en.wikipedia.org/wiki/Herman_Melville` and wouldn't care about the FOAF or Dublin Core classes or properties associated with the URI. An application that was interested in gathering information about the authorship of documents on the web, on the other hand, might look for the `foaf:Document` class and Dublin Core properties and ignore everything else.

To me, this approach seems the most promising way of retaining the core benefits of RDF. It seems more robust in the face of user error than the idea of defining one-step-removed properties, and retains the ease of mashing together data from different sources in a way that you wouldn't get if you had to think about the URI usage within each of the datasets that you want to bring together.

## Locating Data From URIs

And so we get to the final question: how should people be able to get from a URI to information about whatever the URI refers to?

I've discussed above how I think distinguishing between things-on-the-web and non-web-things has to be seen as a best practice. I think we should continue to recommend the `303` or hash URI methods as the best practice for accessing data from a URI. My reason for this is that introducing yet another method will just makes it harder for publishers to know which method to use when, plus I don't want to see people who have adopted these techniques in good faith being told that they were doing the wrong thing all along. What I'd like to aim to do is to find a way of fitting these methods into a larger approach.

I also recognise the argument that articulating the relationships between on-the-web and not-on-the-web resources purely through HTTP responses isn't ideal. It's useful to have explicit links between resources within the data itself. Within the linked data work that I've done for `data.gov.uk` I've tried to adopt a pattern of explicitly using `foaf:primaryTopic`, `foaf:primaryTopicOf` and `foaf:page` to link together the different resources. Other people have suggested the [`wdrs:describedby`](http://www.w3.org/2007/05/powder-s#describedby) property for pointers from a resource to information about that resource; `rdfs:isDefinedBy` performs a similar function for classes and properties within RDFS.

It would be nice to have one defined property or set of properties to describe these relationships, but we have to recognise that not everyone will use them, so the approach we take has to work when these links aren't present. The majority of people and sites are going to start off by publishing data about something at a single URI, and simply return data about that thing (a `200` response) when the URI is requested. If they then progress to wanting to have separate URIs for that thing and the page about the thing, or indeed to disambiguate the URI that they've used in some other way, we need to make it easy for them to do so.

I think we need two properties: `eg:describedBy` and `eg:couldBe`. `eg:describedBy` describes the link between a resource (of any type) and a document that describes it; `eg:couldBe` is a disambiguation link that points from a URI to other possible, more precise, URIs.

Then I think we need some rules along the lines of (I don't pretend these are entirely worked out):

  * if you get a `303` response redirecting to `U'` when you fetch a URI `U` then behave as if the response from `U'` included the triple `U eg:describedBy U'`
  * if the URI `U` is a hash URI whose base URI is `U'` then behave as if the response from `U'` included the triple `U eg:describedBy U'`
  * if you get a `2XX` response in response to a URI `U` then:
    * if there are multiple triples that match the pattern `U eg:describedBy ?page` then assume that the document you have is `U'` where `U'` `eg:couldBe` any of the `?page`s
    * otherwise, if there is a single triple that matches the pattern `U eg:describedBy ?page` then assume that the document that you have is `?page` and it is about `U` (along with other things, possibly); statements about `?page` might include information about the licence or provenance of the returned document
    * if there are any triples that match the pattern `?thing eg:describedBy U` then assume that the document you have is `U` and it is about (possibly multiple) `?thing`s
    * otherwise, behave as if there is a triple `U eg:describedBy U`; in this case, `U` is being used in an ambiguous way

We could go further and say:

  * if there are two triples that match the pattern `U eg:couldBe ?page . ?thing eg:describedBy ?page` then assume that the document you have is `?page` and it is about `?thing`
  * if there are two triples that match the pattern `U eg:couldBe ?thing . ?thing eg:describedBy ?page` then assume that the document you have is `?page` and it is about `?thing`

This way, if someone starts off using `U` in an ambiguous way, or to mean only the page or only the thing, they can later add `eg:describedBy` and `eg:couldBe` statements to disambiguate and add information about the page or thing the page describes.

It's worth bearing in mind that we shouldn't just be concerned about locating information about things that aren't on the web, but about things that *are* on the web but that cannot have metadata embedded within them. For example, how do we discover the licence associated with a particular image? Although there are methods of embedding metadata within image and other binary formats, such as [XMP](http://en.wikipedia.org/wiki/Extensible_Metadata_Platform), it's still useful to be able to locate metadata about images based on their URI.

With a scheme such as that described above, publishers that used content negotiation to return some data about the image in another format could use `eg:describedBy` to indicate that the returned document is about the image (or set of images in different formats).

## Summary

The summary of my thinking is:

  * we should learn to cope with ambiguity in URIs
  * we should not constrain how applications manage that ambiguity, though duck typing seems the most promising approach to me
  * we should define some specific properties that can be used to disambiguate URIs, describe their defaults with `303`s and hash URIs and provide an easy upgrade path as publishers choose to add more specificity

The key will be how we find practical ways to cope with the real, imperfect, fuzzy web of data while providing an evolutionary path to greater clarity and specificity that publishers can take when they see the benefit of doing so.
