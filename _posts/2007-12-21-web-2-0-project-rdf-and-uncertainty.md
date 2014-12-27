---
layout: drupal-post
title: ! 'Web 2.0 project: RDF and uncertainty'
created: 1198274631
tags:
- rdf
- genealogy
---
I've been thinking a bit recently about how to deal with certainty in our Genealogical Web 2.0 application. We've come round to using an RDF model to represent what the Gentech data model calls "assertions"; assertions such as "Charles Darwin was a passenger on the Beagle Voyage" are represented as an RDF Statement in which (a resource representing) "Charles Darwin" is the subject, (a resource representing) "Beagle Voyage" is the object, and "was a passenger on" is the predicate/property.

All the statements in the genealogical application should be based on some source of information, either an external piece of evidence (such as a marriage certificate) or by combining existing statements. Either way, there's certain metadata that we want to store about it, such as

  * who created the statement
  * when it was made
  * the date(s) when the statement was true
  * the certainty in the statement

The certainty factor is interesting. For statements based directly on evidence, there are three factors that come into play:

  * the reliability of the evidence itself; for example, a marriage certificate is more reliable than a diary entry for a wedding
  * the certainty the user has in drawing their conclusion based on the evidence; for example,  you would be more certain in the statement that the groom named on a marriage certificate is a man than in the statement that the witness named on a marriage certificate is a friend of the groom
  * the reliability of the user who has made the statement: an expert in family history is likely to draw more accurate conclusions than someone who has only just started

So now the question is how to assess these factors. The usual Web 2.0 method is to use ratings. We could get users to rate each other to provide the third score. We could then get users to rate the reliability of particular pieces of evidence, modify that score based on the users' reliability, and aggregate those scores.

The final certainty of the statement would be a combination of this score for evidence reliability and ratings from multiple users, again weighted according to the users' reliability.
