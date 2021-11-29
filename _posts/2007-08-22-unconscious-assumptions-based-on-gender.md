---
layout: drupal-post
excerpt_separator: "<!--break-->"
title: Unconscious assumptions based on gender
created: 1187799335
tags:
- equality
---
I was reading the [Draft TAG Finding on Dereferencing HTTP URIs][1] the other day. It has a load of "Stories" in it: examples that illustrate the technical points of the document. In general, examples fall into three categories:

  * examples that illustrate an expert doing the right thing
  * examples that illustrate a beginner doing the right thing
  * examples that illustrate a beginner doing the wrong thing (and being corrected)

What I realised as I read the stories in this document was that the gender of the protagonist of the story changed how I read them. In particular, when the protagonist was female (as in the stories in this Finding), I assumed that they were a beginner, and probably doing something wrong.

[1]: http://www.w3.org/2001/tag/doc/httpRange-14/2007-05-31/HttpRange-14 "W3C: Dereferencing HTTP URIs"

<!--break-->

Here's an example:

> Angela decides to provide information related to the meter as part of her work on the ontology. She configures her web server to return an HTTP 303 response code when the URI for the meter (`http://www.example.com/ontology/meter`) is dereferenced. She arranges for the URI returned with the HTTP 303 response (`http://www.example.com/ontology/related/meter`) to refer to an information resource that can provide multiple, equivalent representations via content negotiation. In particular she arranges for representations in HTML and RDF to be available to requests that specify the appropriate content type.

Mentally changing "Angela" to "Bob" completely changed how I interpreted the story. Suddenly someone I'd assumed to be incompetent, tentatively making changes while unsure of their outcome, I now assumed to competent, assertively making changes to meet a requirement. I've probably primed you enough that you don't have the same experience as you read the example above, but you might try changing the protagonist's gender next time you read a similar example, just to see.

I should also point out, in mitigation, that assumptions about people in stories are affected by all sorts of things, particularly people-you-have-known-called-X. Mentally changing "Angela" to "Eve", for example, has the same kind of effect as changing it to "Bob".

Anyway, kudos to the TAG for including in their documents stories with competent female protagonists.
