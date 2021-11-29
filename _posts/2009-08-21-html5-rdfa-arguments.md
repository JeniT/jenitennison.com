---
layout: drupal-post
excerpt_separator: "<!--break-->"
title: HTML5/RDFa Arguments
created: 1250879296
tags:
- rdf
- rdfa
- html5
---
When I came back from holiday, I caught up with the recent [discussions around RDFa and HTML5](http://lists.w3.org/Archives/Public/public-rdf-in-xhtml-tf/2009Aug/thread.html). It's exhausting reading so many posts repetitively reiterating the positions of people who all have the best of intentions but fundamentally different priorities. And such a shame that so much energy is spent on fruitless discussion when it could be spent at the very least improving specifications, if not testing, implementing, experimenting or otherwise in some very minor way changing the world.

<!--break-->

The particular thread's subject was the use of prefixes, which are used to provide a shorthand for URIs, which are used to name properties such as `http://xmlns.com/foaf/0.1/firstName`. It's unquestionable, really, that prefixes are a source of problems:

  * with copy-and-paste, because it's easy to lose the bindings that are used to construct the full URI
  * in general understandability, because people just don't get the idea that the prefix `foaf` could be used for something other than `http://xmlns.com/foaf/0.1/` or that `http://xmlns.com/foaf/0.1/` might be bound to a prefix other than `foaf`
  * when declared using namespace declarations, because of differences in interpretation between HTML and XHTML and for the general namespaces-in-content problems that we see in XML

I think it's generally the case that the Semantic Web community, who are used to using syntaxes such as RDF/XML and Turtle which use prefixes all the time, judge these as being less disadvantageous than the members of the HTML5 community, who are much more in touch with and concerned about the "common user".

But underlying the arguments about the costs of prefixes are arguments about whether these disadvantages are important enough to stop

  1. giving people shorthands for URIs and/or
  2. using URIs when naming properties and/or
  3. using RDF as the data model for data on the web

Fundamentally, members of the Semantic Web (capital S, capital W) community take it as a matter of faith that the correct data model to use for expressing data about things both on and off the web is RDF. If there's anything that defines the Semantic Web community, it's that underlying assumption. (Well, probably: I'm sure there are still some who hanker after Topic Maps.)

Further, they think it is absolutely essential that if a property such as 'first name' is used within a page, you can `GET` a URI to find interesting information about the property. For example, with `http://xmlns.com/foaf/0.1/firstName`, you will get

      <rdf:Property rdf:about="http://xmlns.com/foaf/0.1/firstName" 
        vs:term_status="testing" 
        rdfs:label="firstName" 
        rdfs:comment="The first name of a person.">
        <rdf:type rdf:resource="http://www.w3.org/2002/07/owl#DatatypeProperty"/>
        <rdfs:domain rdf:resource="http://xmlns.com/foaf/0.1/Person"/>
        <rdfs:range rdf:resource="http://www.w3.org/2000/01/rdf-schema#Literal"/>
        <rdfs:isDefinedBy rdf:resource="http://xmlns.com/foaf/0.1/"/>
      </rdf:Property>

which among other things includes a human-readable label that you might use in a display of information about things that have the property, and a statement about the domain of the property, from which you can tell that anything that has a `http://xmlns.com/foaf/0.1/firstName` property is a `http://xmlns.com/foaf/0.1/Person`.

Given that you need URIs for properties, members of the Semantic Web community generally think that you need a way to shorten those URIs to make them palatable to people who might be embedding metadata in their pages. The cost of that is that you have to use prefixes, with the disadvantages that I've outlined above, but it's a cost that's worth paying to gain resolvability and concision. And since it can be done in RDF/XML and Turtle and SPARQL and almost every other syntax in existence for expressing RDF, it seems unnatural not to be able to do it in the metadata embedded within webpages.

At an equally fundamental level, members of the HTML5 community are unconvinced that RDF is a necessary or useful model to use for data. They do not see how it offers significant advantages over Javascript object structures, for example.

Part of the reason for not being convinced of the utility of RDF is that members of the HTML5 community think it simply isn't important for properties to be named with resolvable URIs. After all, [microformats](http://microformats.org/) have illustrated that applications can derive meaning without having a machine-readable definition of the semantics of a property.

I haven't heard them make these arguments, but they could also point out that there are vastly more mash-ups constructed with the developer having knowledge and understanding of the data that they are mashing up (and therefore requiring human-readable but not machine-readable definitions), than there are generic applications that could, or do, actually retrieve and reason with schemas or ontologies.

Some within the HTML5 community even think it is *dangerous* to use information from a property or class's URI, because if the metadata within an HTML page can only be accurately understood when coupled with information from an external document, applications that are built on being able to locate that external information are in real trouble if (when) that document disappears, either temporarily or permanently.

For example, say that I have a page that contains the triple:

    <http://www.jenitennison.com/#me> 
      <http://xmlns.com/foaf/0.1/firstName> "Jenifer"^^<http://www.w3.org/2001/XMLSchema#token> .

If it is the case that an application that resolves that triple also (a) retrieves the information available about the property and (b) reasons using it and any information derived from it, then having that triple in my page entails:

    <http://www.jenitennison.com/#me> 
      a <http://xmlns.com/foaf/0.1/Person> ,
      a <http://xmlns.com/foaf/0.1/Agent> ,
      a <http://www.w3.org/2000/10/swap/pim/contact#Person> ,
      a <http://www.w3.org/2000/10/swap/pim/contact#SocialEntity> ,
      a <http://www.w3.org/2003/01/geo/wgs84_pos#SpatialThing> .

but this information can only be known by collecting the documents at:

  * `http://xmlns.com/foaf/0.1/firstName`
  * `http://xmlns.com/foaf/0.1/Person` (actually the same document as `http://xmlns.com/foaf/0.1/firstName` but I can't know that)
  * `http://xmlns.com/foaf/0.1/Agent` (as with `http://xmlns.com/foaf/0.1/Person`, actually the same document as `http://xmlns.com/foaf/0.1/firstName`)
  * `http://www.w3.org/2000/10/swap/pim/contact`
  * `http://www.w3.org/2003/01/geo/wgs84_pos` (resolving this doesn't actually tell me anything extra, but I have to do it all the same to check)

In these circumstances, if, say, `http://xmlns.com/foaf/0.1/Person` can't be located (my connection dips out for a second or whatever) then suddenly the page's metadata *means* something different, which is surely a problem in a *Semantic* Web.

Putting aside all that, even if you did need URIs for properties, the HTML5 community feels that the costs in usability of using prefixes to shorten URIs are simply too high to justify the benefit of concision. Why not simply use the full URI within an attribute?

In summary, you will not be able to persuade members of the HTML5 community that it's worth paying the usability cost of prefixes until you have persuaded them:

  * that RDF has significant advantages as a way of modelling data over and above Javascript object structures
  * that the ability to resolve the URIs that are used to name properties is not dangerous, and can even be helpful
  * that it is ugly and tedious to have to use full URIs when naming properties

Really I'm just trying to draw attention to the fact that the HTML5 community has very reasonable concerns about things much more fundamental than using prefix bindings. After redrafting this concluding section many times, the things that I want to say are:

  * so wouldn't things be better if we put as much effort into understanding each other as persuading each other (hah, what an idealist!)
  * so we will make more progress in discussions if we focus on the underlying arguments
  * so we need to talk in a balanced way about the advantages and disadvantages of RDF
  
or, in a more realistic frame of mind:
  
  * so it's just not going to happen for HTML5
  * so why not just stop arguing and use the spare time and energy *doing*?
  * so why not demonstrate RDF's power in real-world applications?
