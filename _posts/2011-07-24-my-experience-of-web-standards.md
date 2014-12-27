---
layout: drupal-post
title: My Experience of Web Standards
created: 1311524640
tags:
- xml
- rdf
- rdfa
- html5
- microdata
---
One of the things that's been niggling at the back of my mind since the [schema.org](http://schema.org) announcement is how small a role search engine results plays in the wider data sharing efforts that I'm more familiar with in my work on [legislation.gov.uk](http://www.legislation.gov.uk/), and more generally how my day job experience differs from (what seem to be) more common experiences of development on the web. In this post, I'm going to talk about that experience, and about the particular problems that I see with the coexistence of microdata and RDFa as a result.

<!--break-->

My day job (the one I actually get paid for) is web development. The site I spend most of my time and effort on is [legislation.gov.uk](http://www.legislation.gov.uk/). This deals with complex content (UK legislation) that has to be presented in multiple formats (users love PDFs of legislation). Our aim is to make the data as reusable as possible by third parties through good, RESTful, web architecture, and we want to use open standards and open source technologies as part of the [UK government's general strategy](http://www.cabinetoffice.gov.uk/resource-library/open-source-open-standards-and-re-use-government-action-plan).

legislation.gov.uk is not a global website like Amazon or eBay, but it's not small either: it covers 60,000 changing items of legislation, providing point-in-time views for many of them, and with more added every day. It's one of the top ten most used UK Government websites, with 2 million visits (about 10-12 million page views) each month and typically about 120 requests/second during the active times of the day. Legislation might sound like a highly specialist interest, but if you [search for legislation.gov.uk on Twitter](http://twitter.com/search/legislation.gov.uk) you'll see it being referenced over and over by people who want to share what the law says.

I do not by any means claim that my experience is representative of the wider web. I know that there are large numbers of sites that deal only in data, not documents, and certainly not documents with the kind of rich semantic structure that legislation has. I offer the following discussion as a data point, partly because I can't quite believe that legislation.gov.uk is *completely* unique in its requirements and partly because obviously my perspective on a bunch of issues arises from this experience.

## Technology Stacks ##

Legislation items are complex, semi-structured documents. Their natural fit is XML (well, that's not quite true -- their natural fit would be something that allowed overlapping markup -- but XML is the closest that we have). So we store it in XML in a native XML database and we use an XML toolset to query it (XQuery) and transform it (XSLT) into various formats including rendering it as PDF (through XSL-FO).

Our next step for the development of the site involves looking at legislative effects. These form a graph: one item of legislation affects other items of legislation which may in turn affect other items and so on. There are all sorts of other links between items of legislation in terms of commencements, conferred powers and so on. Particularly because we already have well-thought-through URIs for legislation, the natural fit is to use RDF to represent this graph. We already offer a SPARQL endpoint for accessing some aspects of our data, but we expect to expand and develop this over the next few months and to use it as a layer under the website and exposed for reusers, in much the same way as we use the XML database.

As a government site, we have fairly strict limits on what we can do within our web pages: we have to make sure that they're accessible by everyone who wants to view them. We aren't able to use technologies that are only available in the latest browsers, but that's OK because with the kind of content we deal with, we don't have to do anything fancy anyway. So we use pretty basic HTML and CSS and Javascript, because that's how you deliver content to end-users on the web (as well as exposing the underlying XML and RDF, to enable others to reuse the data).

In other words, we use three web stacks for delivering legislation.gov.uk:

  * the XML stack, which is great for single-source publishing of documents that have more semantic structures than those supported by HTML
  * the RDF stack, which is well-suited for metadata about things that are identified by URIs
  * the HTML stack, which is absolutely necessary for delivering human-accessible content on the web

What bemuses me, because of this experience, is that sometimes it appears that the narrative around these technologies is framed in terms of an exclusive choice between them. For example, [@mattur asked](http://twitter.com/mattur/status/89331716430372864):

<p style="text-align:center;">
  <a href="http://twitter.com/mattur/status/89331716430372864"><img src="/blog/files/mattur-tweet.jpg" alt="@gimsieke @JeniT how may TAG members believe RDF(a) and X(HT)ML are way forward? How many think they aren't?" /></a>
</p>

It is as if, if you use XML you *cannot* appreciate the utility of error-handling in HTML; or if you use RDF you *cannot* understand the need to represent documents in XML; or if you want to utilise HTML fully, you *cannot* adopt RDF's view of data on the web. That's simply not my experience. They each have their role on the web; supporting the use of one does not necessitate rejecting the use of the others.

It's interesting that some of the standards that are most reviled are those that arise at the intersections, where it appears that one technology is trying to encroach on the space of another:

  * XHTML at the border of XML and HTML
  * RDF/XML at the border of RDF and XML
  * RDFa at the border of all three

At the same time, within legislation.gov.uk, we publish XHTML (because it's the natural output from an XML toolchain) and create and process RDF/XML (because it gives us access to that data from within the XML toolchain). We use a small bit of RDFa in the XHTML to indicate the rights under which our information is avaialble, and don't yet, but are thinking about using RDFa to mark up non-document semantics within our XML (to enable the XML markup to focus on the document structures that it's good at). For all their imperfections, these intersection technologies are useful for managing cross-overs; the problems arise when they overstep their remit and people start to think that *all* HTML must be XHTML or *all* XML must be RDF/XML or *all* RDF must be RDFa.

## Sharing Scenarios ##

The second thing that I wanted to explore is the experience from legislation.gov.uk of what it's like to be a publisher who actively wants to share their data. We need to operate simultaneously at three levels in our data sharing efforts.

### Large-Scale Consumer-Driven Data Sharing ###

The first target for our data sharing efforts are the search engines. Obviously we're not selling anything, but we want people to be able to locate legislation easily when they want it, and we want people who have done the search to be able to see some information about the legislation so that they know that they've located the right item.

This is large-scale consumer (search engine) driven data sharing, typified by schema.org and Facebook's [Open Graph Protocol](http://developers.facebook.com/docs/opengraph/) (OGP). There are a few very big data consumers (Google, Microsoft, Yahoo!, Facebook etc) who need to consume data from large numbers of data providers. These consumers obviously can't understand *everything*, so they determine and document what syntaxes and vocabularies they *do* understand and expect publishers to follow.

The benefits that publishers get from a particular consumer determines which syntax/vocabulary they use; publishers who are particularly keen to show up prettily within search results will target schema.org whereas those who want to be sharable within Facebook will target OGP. Many publishers will want to target both. There is probably a driver towards eventual convergence:

  * publishers might push back about inserting two lots of very similar data in their pages
  * consumers might want to include data from publishers who haven't specifically targeted them

although there's likely to be a period where they coexist, much as there was for VHS and Betamax (and [V2000](http://en.wikipedia.org/wiki/Video_2000), I know, dad) during the early days of video players.

As [I discussed previously](http://www.jenitennison.com/blog/node/157), these large-scale consumers will be driven by the data that they find in the wild, in all its messy variety. They get relatively little benefit directly from using a generic *syntax*, as they are really interested in only a few, pretty generic, *vocabularies* for which they have hardwired processing. Indirectly, adopting a generic syntax has benefits in that publishers might find it easier to find tools that enable them to generate it, tutorials about how to use it, and feel that they aren't being quite as locked in to something proprietary. However, rejecting data that isn't marked up properly using that syntax has no benefit for consumers except in so far as it makes them feel that they are being good community members. 

This is the pattern we see with schema.org (which accepts microdata but, based on its documentation, won't reject data that isn't fully compliant with it) and with OGP (which accepts a subset of RDFa but doesn't reject data that hasn't got prefixes properly bound, for example).

Another point to mention is that there is very little trust in this scenario. The communication between consumers and publishers is very limited, and the consumers will want to protect themselves against accidental or malicious errors that are evident in mismatches between explicit metadata and that which is parsed from the visible content of the page.

The parallels to HTML and browser vendors are very strong in this type of data sharing.

### Small-Scale Consumer-Driven Data Sharing ###

A second type of data sharing is again driven by consumers, but this time at a lot smaller and more specialised scale. For legislation.gov.uk, these are services such as [GLIN](http://www.glin.gov/), which is a global legislation registry. Other examples are the recent work that we've done to publish [UK Government organograms](http://data.gov.uk/organogram) or [Chris Taggart](http://countculture.wordpress.com/)'s [Open Election Data](http://openelectiondata.org/) project. In these cases, there's a single, relatively small and specialised consumer and a small number of publishers which are closely coordinated together.

As in the large-scale case, the consumer ultimately determines the syntax/vocabulary that it recognises, and communicates that to the publishers. However, small-scale consumers typically have close coordination with the publishers, which has a number of side-effects:

  * consumers may be more able to both apply pressure to and help publishers to do well in their markup
  * publishers have the opportunity to feed back directly to the consumer any suggestions that they have about changes to the syntax/vocabulary
  * publishers are likely to gain an immediate and tangible benefit from their cooperation, such as visualisations of their data that they otherwise wouldn't have seen

Another noteworthy point about small-scale consumers is that they're unlikely to have the engineering capability to create a custom parser for a particular syntax, but will instead want to use something off-the-shelf to extract data from pages and into their own backend systems. This, coupled with the closer coordination with publishers, means that they're much more likely to stick to a specification, assuming that the off-the-shelf tools do.

### Publisher-Driven Data Sharing ###

The final type of data sharing is driven by publishers. At legislation.gov.uk, we're motivated to make our data available for reuse for transparency/accountability reasons (to help citizens understand the law), efficiency reasons (to help parliament and government departments to publish new legislation better) and economic reasons (to foster innovation in legal publishing). We don't have any individual consumers in mind when we publish our data, but have found that simply by publishing it well, we foster reuse.

In this case, we as publishers are highly motivated to ensure that the data we publish is easily parsed with something off-the-shelf, since that lowers the barrier for potential consumers. Publishers like us are very likely to have unique, specialised, content and need to use a vocabulary that fits closely to our internal data structures as this lowers implementation cost. Consumers can also trust publishers like us: we simply have no motivation to lie in the data that we provide for reuse.

## Mixed Markup ##

As I've outlined above, publishers like legislation.gov.uk need to target several potential consumers at the same time:

  * large-scale consumers such as search engines
  * small-scale consumers that provide us with a useful service
  * specialist consumers that are interested specifically in our data

We cannot use a single vocabulary for all these different purposes. (Well, we could write our own vocabulary and describe mappings to other vocabularies using RDFS, but search engines wouldn't read it.)

We must therefore use a mix of vocabularies:

  * generic vocabularies about things that search engines care about
  * specialised vocabularies for particular small consumers
  * site-specific vocabularies for sharing our unique data

It's repetitive, but it's manageable so long as we have a syntax that enables us to say that an item of legislation is a `http://scheme.org/CreativeWork` and a `http://purl.org/dc/dcmitype/Text` and a `http://www.legislation.gov.uk/def/legislation/Legislation` and allows us to give multiple properties the same value.

The way things are going at the moment, we might well end up having to use multiple *syntaxes* on the same page, as some consumers understand microdata, others consume RDFa, and still others will parse microformats. This leads to more repetition: adding `itemprop` for microdata, `property` for RDFa and specialised `class` attributes for microformats. But worse (much worse), each of the syntaxes uses a different parsing model to create an entity-property-value structure, so not only do we have to learn substantially different markup patterns but our pages quickly become some kind of hideous polyglot mess trying to balance between them.

## Looking Forward

As I said at the start, I'm fairly sure that my experience at legislation.gov.uk isn't representative of the wider web, but I don't have a clear idea about just how unrepresentative it is, in terms of technology use or motivations around data sharing. When I read my twitter stream or blogs, there's a massive sampling bias, both in terms of who I follow and what I read, but also about who talks about what they're doing. (I'm reminded of [Jeff Atwood](http://www.codinghorror.com/blog/)'s post on the [Two Types of Programmers](http://www.codinghorror.com/blog/2007/11/the-two-types-of-programmers.html): the vast majority of web developers don't make a noise about what they do.)

Taking part in web standardisation today often feels like being part on an ongoing cold war between distinct camps rather than a community working towards common aims. The underlying question seems to be "who's side are you on?" Every decision and activity is cast as a victory or defeat. Time is wasted on attack and defence, or on raking over past slights and stupidities, rather than on progress. Valid criticism from outside a group cannot be listened to for fear of giving ground, cannot be made within a group where it seems like betrayal.

It is the [Robbers Cave Experiment](http://en.wikipedia.org/wiki/Realistic_conflict_theory#The_Robbers_Cave_Experiment) played out in web standards. As a psychologist, I find it fascinating. As a developer, and particularly one who doesn't self-identify with any single group, it is frustrating. As a TAG member, trying to work for the longer-term good of the web, it is worrying, because situations of intergroup conflict lead to [groupthink](http://en.wikipedia.org/wiki/Groupthink) and non-optimal solutions.

As I described above, a non-optimal outcome seems to be the most likely result of the particular microdata vs RDFa conflict for us at legislation.gov.uk. While I know we are not generally representative, I believe that it will be similarly bad for other developers: publishers, consumers and tool implementers.

This is a problem for all who want to foster data sharing on the web using open standards; it is not one that any one group can fix on their own. It's my hope that a balanced task force of individuals with a variety of experience and backgrounds can provide a focus for us all to work together to solve it. If we can't, then we have let our prejudice and bias overcome our judgement.
