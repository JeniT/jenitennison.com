---
layout: drupal-post
title: ! 'Web 2.0 project: privacy in genealogy'
created: 1200606538
tags:
- web
- genealogy
---
There were a couple of comments on my previous post about [RDF and uncertainty in our Web 2.0 genealogy project][1] concerning the problems of privacy in a genealogy app. My ideas about this aren't fully thought-through, let alone implemented, but I thought I'd share them anyway.

[1]: http://www.jenitennison.com/blog/node/67 "Jeni's Musings: Web 2.0 project: RDF and uncertainty"

First, the things we could restrict access to are:

  * sources of information (eg birth records)
  * personas (eg Charles Darwin) and assertions about them
  * events (eg the Beagle Voyage) and assertions about them
  * groups (eg the Royal Society) and assertions about them

There are different kinds of things you might do to the resources:

  * who can know it *exists*?
  * who can *read* it?
  * who can *change* it?
  * who can *delete* it?

and different levels of access for each of those things:

  * global (public)
  * group (restricted)
  * user (private)

I imagine that at any point, a user will have a default set of permissions in play. For example, they might be generating information that anyone can know exists and can read, but only a restricted set of people can change, and only the user themselves can delete.

## Searchability ##

I'm going to side-track for a second here to explain why I've separated out "knowing something exists" from "readable".

Our genealogy application is evidence-based, which means that to say that someone exists you must have a source for that information, be it a birth certificate or a picture or the transcription of an interview. The *persona* that you believe to exist on the basis of one source may or may not be the same persona that you believe to exist on the basis of a different source. A separate step is required to link the two personas together.

The intention is that our application will help you link personas (and events, groups and anything else that might be quoted in more than one piece of evidence) together through searching through other personas (etc) to find those that are similar. They might have similar names, but most of the evidence for similarity will come from similar assertions having been made about them.

Now say that I have some evidence about Charles Darwin and enter it into the system, and you similarly have some evidence about Charles Darwin that you enter into the system. We both create "Charles Darwin" personas based on our evidence. I'd like it to be the case that, even if we don't want the information we've captured about Charles Darwin to be readable by others, we can still make it searchable so that others can find out we're working on that person too so that (after some interpersonal negotiation) the two sets of information can be brought together.

So the "who can know it exists?" access is about making your information searchable, even if the details aren't readable.

## Default access ##

As I understand it, in genealogy circles it would be bad form to make any information about living people publicly available. Some would argue that any information that is currently publicly available (on the web, or even off it, in electoral rolls, phone books, wherever) is fair game: if it's already "out there" then you can use it. But I don't agree with that. There's a big difference between there being multiple disparate, human-readable sources of information about an individual "out there somewhere" and providing a single aggregated public source for all this data in a computer-readable format. In short, I agree with Jeff "Coding Horror" Atwood's recent post on privacy in which he characterises [privacy as an inalienable right][2].

[2]: http://www.codinghorror.com/blog/archives/001027.html "Coding Horror: An Inalienable Right to Privacy"

Also, some people make money from doing genealogical research, and it would be short-sighted to prevent people from using the application if they simply wanted to keep what they were doing private for their own reasons.

So there must be a setting such that information can be kept entirely private, to the extent that only the person who constructed it knows that it exists.

On the other hand, many of the benefits of Web 2.0 applications come from integrating your own material with other people's. Genealogy is a good example of this, because there's a distinct thrill in hooking into other people's research and discovering other branches of the family.

So there must be a setting such that information can be made globally available to all and sundry, even to the extent of others changing and deleting it.

I think the default has to be that the information you enter is completely private. I'd like to encourage people to share their information, but I think that the way to do that is through social mechanisms (eg the more useful information you share, the more kudos you get) rather than technological ones.

## User Groups ##

Public and private access aside, there's a huge middle ground of access that's somehow restricted to a subset of users. I don't think I'm being particularly radical if I say that the current state of the art of social software access control isn't great, that the "restricted" subset is usually to "my friends", but people don't have one social circle: they operate in different spheres, and have a different set of friends/colleagues in each.

The same is true in our genealogy app. A given user might be working (collaboratively) on several projects, with different teams. For example, I might work on a family tree with my mother for her side of the family and my father for his, with no need for either of them to be aware of the other (unless they overlap, in which case "searchability" comes into play).

So I think it makes sense to use the familiar notion from *nix of "user groups", and assign each item (sources/people/events/groups) to one or more user groups. User groups will probably mostly arise from those working on particular projects, but could be more arbitrary. I'm thinking:

  * moderated (by-invitation) and open (by-subscription) user groups
  * private, public and restricted permissions on the user groups

The other thing I was considering here was having a notion of "degrees of separation". If I entered details about our daughters into a family tree, I might be happy for immediate family, and their immediate family, to see them: a separation of two. I don't know whether this kind of network-based user group would be useful or a pain to manage, or even implementable; it's just an idea I had.
