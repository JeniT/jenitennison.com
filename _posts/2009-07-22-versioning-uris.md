---
layout: drupal-post
excerpt_separator: "<!--break-->"
title: Versioning URIs
created: 1248300980
tags:
- web
- rdf
- uri
---
Yesterday I went along to a workshop on developing URI guidelines for the UK public sector. Because of the current drive to get more UK public sector information online, and the fact that [we have Tim Berners-Lee on board](http://blogs.cabinetoffice.gov.uk/digitalengagement/post/2009/06/09/Data-So-what-happens-now.aspx), there's a growing recognition of the fact that we need URIs for the real-world and conceptual things that we talk about in the public sector: schools, roads, hospitals, services, councils, and so on.

One of the particular points of contention at the meeting was whether URIs for non-information resources (ie for real-world and conceptual things) should contain dates or version numbers, or not.

<!--break-->

Let's get some of the argument out of the way first. We are not talking about documents here. Documents will almost always have multiple versions, and if you care at all about maintaining a historical record you will want to refer to the previous version of a document. So dates or version numbers within URIs that refer to documents are often a really good idea. Even better if you have one URI *without* a date that consistently redirects (through a `307 Temporary Redirect`) to the current version of the document.

Documents (that people read) are just one form of **"information resource"**: things that are information and therefore can be transmitted electronically. Other things in the world are **"non-information resources"**: things that are more than simple information and therefore cannot be transmitted electronically, such as schools, roads, hospitals and so on. A lot of things that we want to talk about (make RDF assertions about) are non-information resources. We give them URIs to name them, so that we can talk about them unambiguously, and we give them HTTP URIs so that we have a way of finding information resources (documents) that give us information *about* them.

Does the information that you get when you resolve a non-information resource URI change? Absolutely. A request to a non-information resource URI will respond with a `303 See Other` that redirects to an information resource (probably without a version number) that itself redirects (`307 Temporary Redirect`) to a URI for a particular version of information about the resource. For example an identifier that means a particular school such as:

    http://id.example.org/education/school/78

can 303 redirect to the current version of a document that contains information about that school, such as:

    http://www.example.org/education/school/78

which will 307 redirect to a particular version of information about that school, such as:

    http://www.example.org/education/school/78/2008-09-01

The date is in the URI for the information resource (the information about the school), and therefore it doesn't need to be in the URI for the non-information resource (the school).

OK, but say that the identifier for a school changes over time. Let's say that you've designed your URIs for schools like:

    http://id.example.org/school/bracknell-forest/broadmoor-primary

and the name of the school changes. Now the above identifier isn't applicable any more, and any RDF statements out there on the web that have used this identifier are now talking about something that no longer exists. How do you deal with this?

Well, the first rule is that **non-information resource URIs must not include information that is likely to change**. That's why a lot of URIs contain numbers rather than names. So we shouldn't have included the name of the school in the URI? OK, we'll use a number instead:

    http://id.example.org/school/bracknell-forest/78

Hang on. Bracknell Forest is a council, and historically it's been known for councils to change, either in their boundaries (which would mean that a school would move council) or in its name, or they are merged, or... well, there are lots of things that could happen to a council. So in the face of all these possibilities, and given that we no longer need the council name to disambiguate the school name (because we have a number instead), we can employ a second rule: **non-information resource URIs must not include unnecessary hierarchy**. We can eliminate part of the path and still identify the school:

    http://id.example.org/school/78

And so we come to the final thing that could change: "school". Now surely, you might say, the concept of a school cannot change. And maybe you're right, maybe it won't. On the other hand, in the UK we have in the past had things called [polytechnics](http://en.wikipedia.org/wiki/Polytechnic_(United_Kingdom)), which are now known as universities, so the types of educational establishments that we have do change over time.

We could do a bunch of things to help prevent a conceptual change like this from requiring a change to the URI:

  * we keep the number of concepts named within the URI to a minimum (eg don't have both 'education' and 'school')
  * we use wide terms rather than narrow terms (eg use a generic 'school' rather than having separate 'grammar-school', 'primary-school' and so on)
  * we could change the term 'school' to a code (eg use 'C3X0' instead of 'school'), but I don't think this will help: you'll still have problems if 'C3X0' and 'F9R2' mean the same thing in the future, whatever they're called.
  * we could eliminate the concept term from the URI altogether, and label everything under one flat naming scheme, using something that has billions and billions of possible combinations. I know, a UUID! No, I'm not serious.

And so we come to the question of versioning the URIs themselves. This is what Tim Berners-Lee says in [Cool URIs don't change](http://www.w3.org/Provider/Style/URI):

> I'll go into this danger in more detail as it is one of the more difficult things to avoid. Typically, topics end up in URIs when you classify your documents according to a breakdown of the work you are doing. That breakdown will change. Names for areas will change. At W3C we wanted to change "MarkUp" to "Markup" and then to "HTML" to reflect the actual content of the section. Also, beware that this is often a flat name space. In 100 years are you sure you won't want to reuse anything? We wanted to reuse "History" and "Stylesheets" for example in our short life.
> 
> This is a tempting way of organizing a web site - and indeed a tempting way of organizing anything, including the whole web. It is a great medium term solution but has serious drawbacks in the long term
> 
> Part of the reasons for this lie in the philosophy of meaning. every term in the language it a potential clustering subject, and each person can have a different idea of what it means. Because the relationships between subjects are web-like rather than tree-like, even for people who agree on a web may pick a different tree representation. These are my (oft repeated) general comments on the dangers of hierarchical classification as a general solution.
> 
> Effectively, when you use a topic name in a URI you are binding yourself to some classification. You may in the future prefer a different one. Then, the URI will be liable to break.
> 
> A reason for using a topic area as part of the URI is that responsibility for sub-parts of a URI space is typically delegated, and then you need a name for the organizational body - the subdivision or group or whatever - which has responsibility for that sub-space. This is binding your URIs to the organizational structure. It is typically safe only when protected by a date further up the URI (to the left of it): 1998/pics can be taken to mean for your server "what we meant in 1998 by pics", rather than "what in 1998 we did with what we now refer to as pics."

Let's spell out the danger with some examples. Let's say that in 20 year's time, nurseries and primary schools merge into 'schools' and secondary schools, sixth-form colleges and universities merge into 'academies'. A particular primary school currently known as:

    http://id.example.org/school/78
    
will continue to be known by that URI. A particular university currently known as:

    http://id.example.org/university/307

is now known as:

    http://id.example.org/academy/79

To support these changes, we have to set up some `301 Moved Permanently` redirects;  `http://id.example.org/university/307` has to redirect to `http://id.example.org/academy/79`. The RDF found at the end of the new URIs has to include `owl:sameAs` triples that link the new URIs back to the old ones, to indicate they are talking about the same institution:

    <http://id.example.org/academy/79> owl:sameAs <http://id.example.org/university/307>

or this would be [derived from the 301 response](http://www.ldodds.com/blog/2007/03/the-semantics-of-301-moved-permanently/).

Similar changes may or may not happen within the RDF hosted elsewhere that talks about these institutions. Since it can be discovered that they are identical, there's no real reason for anyone to start using the new URIs unless they want to.

Then 30 years later, the government of the time decide to create a new kind of institution which they call a 'university'. The university of 50 years hence isn't actually the same as the 'university' as we mean it -- they are virtual meeting places for independent researchers, each centered on a particular topic of study rather than a physical location -- but they need URIs. And since they are called 'university' that is the name that should be used in the URI. Now someone mints the URI:

    http://id.example.org/university/307

But disaster! This University 307 is not at all the same as the old University 307, now known as Academy 79. The same URI has been used for two different things. Redirections halt, graphs are smushed, distinctions are lost and fallacies haunt the web.

TimBL's solution to this possibility is for every URI that includes a topic to include the year in which the topic was minted. So we would have:

    http://id.example.org/2009/school/78

that remains the same, and then:

    http://id.example.org/2009/university/307

redirecting to:

    http://id.example.org/2029/academy/79

and the introduction of:

    http://id.example.org/2059/university/307

which can be guaranteed to be distinct from `http://id.example.org/2009/university/307`.

This, to me, is the crux of the argument for including a version inside the URIs that you use for non-information resources. It means that you can reuse old terms with new meanings within URIs without breaking the web.

On the other hand, many people, myself among them, really dislike the use of years or version numbers within URIs for non-information resources (unless, I should say, they are used as part of the identification of the resource). I think there are four main reasons:

  * they are additional cruft that add to the length of a URI but provide no information about the thing being identified
  * they can give a misleading impression about the relevance of a concept; for example [FOAF](http://xmlns.com/foaf/spec/) is stuck at version 0.1 (`http://xmlns.com/foaf/0.1/`) despite being widely used, while `http://www.w3.org/1998/Math/MathML` is feeling distinctly old (in internet time) despite being under active development
  * it leads to a proliferation of URIs and creates additional work for people who want to keep their URIs up to date, even when the concepts themselves don't change (such as for the primary school's URI above)

In essence, the likelihood of a term being reused with a different meaning seems low enough that the cost (in readability, understandability and maintainability) of supporting URIs that contain versions or years doesn't seem worthwhile. We can keep the likelihood low by using terms that are unlikely to change their meaning (particularly avoiding those that have more than one meaning) and by disambiguating them (for example by using 'train-station' rather than just 'station').

There is also, perhaps, a middle way here that can keep the majority of URIs clean without leading to overlapping names. That's to start with a URI scheme that does not include a version number or year, and only to start introducing them when it becomes necessary due to the reuse of previous terms. In the example above, in 2059 we might have:

    http://id.example.org/school/78
    http://id.example.org/academy/79
    http://id.example.org/university2.0/307

In other words, we make a decision now that our future selves will have to act upon. All we have to worry about is our future selves caring as much about persisting historical URIs as we do about persisting our current ones.

What do you think? Should versioning be avoided in URIs at all costs, or always be included just in case? Are there other arguments for or against including versions or years in URIs? What other design considerations are there that help prevent changes to URIs over (long periods of) time?
