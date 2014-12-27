---
layout: drupal-post
title: Naming Properties and Relations
created: 1252876786
tags:
- rdf
---
This post is about how to name properties and relations in RDF schemas. Or rather, about how different ontology developers use different conventions and how this can sometimes be confusing.

Part of the work that I've been doing over the last few months at [TSO](http://www.tso.co.uk/) has been for [OPSI](http://www.opsi.gov.uk/), who want to provide information about UK legislation for reuse through an API as well as eventually through a new end-user service. The [Single Legislation Service API](http://www.legislation.gov.uk/) is now available, in beta, if you want to take a look.

One way in which we're providing information about legislation is using RDF/XML. An example is the Criminal Justice Act 1993 Section 67, for which RDF is available at [http://legislation.data.gov.uk/ukpga/1993/36/section/67/data.rdf](http://legislation.data.gov.uk/ukpga/1993/36/section/67/data.rdf). For now, we've made the decision to not attempt to create any of our own ontologies for the RDF, but to reuse ones that are already out there.

<!--break-->

We're making an explicit distinction within the service between the idea of an item or section of legislation (such as the Criminal Justice Act 1993 Section 67), versions of that legislation (such as the Criminal Justice Act 1993 Section 67 as it was in force on 1st December 2001) and that version formatted in XML, HTML or some other format (such as the XML version of the Criminal Justice Act 1993 Section 67 as it was in force on 1st December 2001).

These three ways of thinking about legislation correspond to the [FRBR](http://en.wikipedia.org/wiki/Functional_Requirements_for_Bibliographic_Records) Work, Expression and Manifestation. So to talk about them in RDF, we use the [FRBR vocabulary](http://vocab.org/frbr/) created by Ian Davis and Richard Newman, in which these classes are called `frbr:Work`, `frbr:Expression` and `frbr:Manifestation`.

One of the other ontologies that we're using is the [Metalex](http://www.metalex.eu/) ontology which is specifically designed for legislation. It also builds on FRBR, and calls the relevant classes `metalex:BibliographicWork`, `metalex:BibliographicExpression` and `metalex:BibliographicManifestation`.

So we have two vocabularies that represent the same concepts with equivalent classes, and obviously they have equivalent properties linking them. And this is what I find interesting. In the FRBR vocabulary, the relationships are:

  * `frbr:Work -- frbr:realization --> frbr:Expression`
  * `frbr:Expression -- frbr:realizationOf --> frbr:Work`
  * `frbr:Expression -- frbr:embodiment --> frbr:Manifestation`
  * `frbr:Manifestation -- frbr:embodimentOf --> frbr:Expression`
  
The FRBR vocabulary uses nouns to name the relations. It's the same pattern that's often used to name properties (ie predicates that take literals as values):

  * `foaf:name`
  * `dc:title`
  * `rdfs:label`

Using nouns leads you to read statements in the pattern "*subject*'s *predicate* is *object*":

  * Jeni's *name* is "Jeni"
  * the legislation's *title* is "Criminal Justice Act 1993"
  * England's *label* is "England"
  * the legislation's *realization* is the version from 1st December 2001
  * this document's *embodiment* is that XML file

The trouble is that this pattern really doesn't work for the inverse relationships: `frbr:realizationOf` and `frbr:embodimentOf`:

  * the version from 1st December 2001's *realization of* is the legislation
  * that XML file's *embodiment of* is this document
  
They really want to support a sentence structure like "*subject* is a *predicate* *object*":

  * the version from 1st December 2001 is a *realization of* the legislation
  * that XML file is a *embodiment of* this document

But if you then map that back to the original relation, you run into trouble, because there's a temptation to add a preposition into the sentence to make it make sense, and inserting that preposition inverts the meaning of the statement:

  * the legislation is a *realization* [of] the version from 1st December 2001
  * this document is a *embodiment* [of] that XML file

You don't run into this problem when you use nouns to name *properties* because there's never an inverse relationship from a literal to a resource that you need to name. You also won't run into it for relations that have easily named inverses, such as parent/child or owner/possession although there is a similar confusion with the use of comparatives for relation names, as in SKOS, where the relation `skos:broader` could mean:

  * X is *broader* than Y; or
  * X's *broader* term is Y

In the Metalex ontology, on the other hand, the relationships are:

  * `metalex:BibliographicWork -- metalex:realizedBy --> metalex:BibliographicExpression`
  * `metalex:BibliographicExpression -- metalex:realizes --> metalex:BibliographicWork`
  * `metalex:BibliographicExpression -- metalex:embodiedBy --> metalex:BibliographicManifestation`
  * `metalex:BibliographicManifestation -- metalex:embodies --> metalex:BibliographicExpression`

Here, the relationships are verbs, leading you to read sentences in the form "*subject* [is] *predicate* *object*":

  * the legislation is *realized by* the version from 1st December 2001
  * the version from 1st December 2001 *realizes* the legislation
  * this document is *embodied by* that XML file
  * that XML file *embodies* this document

The only weirdness here is having to add "is" before some predicates but not others.

The tradition in AI is to use verbs everywhere. Instead of `foaf:name` or `dc:title`, you would have `foaf:hasName` and `dc:hasTitle`. Doing this for properties with literal values seems unnecessarily verbose, but for relations I think it's a good rule of thumb in order to disambiguate the direction of the relation.
