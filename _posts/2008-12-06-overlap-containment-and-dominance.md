---
layout: drupal-post
title: Overlap, Containment and Dominance
created: 1228597012
tags:
- creole
- overlapping markup
---
I've spent the last few days at a [workshop on overlapping markup][workshop] in Amsterdam. It was organised by [Claus Huitfeldt][Claus] and [Michael Sperberg-McQueen][Michael] under a GODDAG banner, but included representatives of other approaches, such as the [XCONCUR crowd][XCONCUR] and the [LMNListas][LMNL] [Wendell][Wendell] and myself.

[workshop]: http://ilps.science.uva.nl/PoliticalMashup/2008/11/workshop-on-multi-dimensional-markup/ "Workshop on multi dimensional markup"
[Claus]: http://www.hf.uib.no/i/Filosofisk/claus/ "Claus Huitfeldt"
[Michael]: http://www.w3.org/People/cmsmcq/ "Michael Sperberg-McQueen"
[XCONCUR]: http://www.xconcur.org/ "XCONCUR"
[LMNL]: http://www.lmnl.org/wiki/ "LMNL Wiki"
[Wendell]: http://www.piez.org/wendell/ "Wendell Piez"

<!--break-->

Overlap is arguably the main remaining problem area for markup technologists. Capturing and analysing the overlap between poetic and syntactic structures in poems and plays helps academics gain a deeper understanding of the ways poetic technique has changed over time. And the complexities of structures in documents such as the Bible simply cannot be represented without allowing overlap to happen.

But academic study aside, overlap is a really important problem because whenever we collaborate on documents and whenever we change documents, we create overlapping structures. One of the major projects that I've worked on at [TSO][TSO] deals with publishing [consolidated legislation][legislation], showing the places where "current" legislation was amended over time from its original, enacted state. The authors of legislation care little for document structures, and amendments often overlap document structures such as paragraphs and list items, and each other.

[TSO]: http://www.tso.co.uk/ "The Stationery Office"
[legislation]: http://www.opsi.gov.uk/legislation/revised "OPSI: Revised Legislation"

## An Example ##

I used the following example during my talk on the [Creole][Creole] schema language during the workshop. It uses [TexMECS][TexMECS] notation, in which `<name|` is a start tag, `|name>` an end tag and the normal XML syntax is used for attributes:

[Creole]: http://www.lmnl.org/wiki/index.php/Creole "Creole Schema Language"
[TexMECS]: http://decentius.aksis.uib.no/mlcd/2003/Papers/texmecs.html "TexMECS"

    <page n="199"|
    ...
    <poem|
      <title|<pl|Recueillement|pl>|title>
      <stanza|
        <s|<sl|<pl|Sois sage, ô ma douleur, et tiens-toi plus |pl>
                                            <pl|tranquille.|pl>|sl>|s>
        <s|<sl|<pl|Tu réclamais le Soir; il descend; le voici:|pl>|sl>
        <sl|<pl|Une atmosphère obscure enveloppe la ville,|pl>|sl>
        <sl|<pl|Aux uns portant la paix, aux autres le souci.|pl>|sl>|s>
      |stanza>
      <stanza|
        <s|<sl|<pl|Pendant que des mortels la multitude vile,|pl>|sl>
        <sl|<pl|Sous le fouet du Plaisir, ce bourreau sans merci,|pl>|sl>
        <sl|<pl|Va cueillir des remords dans la fête servile,|pl>|sl>
        <sl|<pl|Ma douleur, donne moi la main; viens par ici,|pl>|sl>
      |stanza>
      <stanza|
        <sl|<pl|Loin d'eux.|s> <s|Vois se pencher les défuntes |pl>
                                                    <pl|Années,|pl>|sl>
        <sl|<pl|Sur les balcons du ciel, en robes surannées;|pl>|sl>
        <sl|<pl|Surgir du fond des eaux le Regret souriant;|pl>|sl>
      |stanza>|page>
      <page n="200"|<stanza|
        <sl|<pl|Le Soleil moribund s'endormir sous une arche,|pl>|sl>
        <sl|<pl|Et, comme un long linceul traînant à l'Orient,|pl>|sl>
        <sl|<pl|Entends, ma chère, entends la douce Nuit qui |pl>
                                                  <pl|marche.|pl>|sl>|s>
      |stanza>
    |poem>
    ...
    |page>

The start and end tags mark *ranges* in the text. (In some discussions of overlap, the ranges are called "elements", but I prefer to reserve that term for structures that are self-contained, such as those in XML, to avoid confusion.) In Creole's compact syntax, you could articulate the structure as follows:

    # a book is a sequence of pages; it is also a sequence of poems
    start = element book { page+ ~ poem+ }
    
    # a page is a sequence of page lines
    page = range page { pl+ }
    
    # a poem starts with a title; the body of the poem can be characterised
    # as a sequence of stanzas, but also as a sequence of sentences
    poem = range poem { title, ( stanza+ ~ s+ ) }
    
    # a title is a self-contained structure that may contains several page lines
    title = element title { pl+ }
    
    # a stanza contains several stanza lines
    stanza = range stanza { sl+ }
    
    # a stanza line contains one or more page lines
    sl = range sl { pl+ }
    
    # a sentence contains some text
    s = range s { text }
    
    # a page line contains some text
    pl = range pl { text }

You could go further: sentences are made up of phrases, which are made up of words, which are made up of syllables, which are made up of letters. Stanzas within a sonnet such as this one can be clustered into an octet and a sestet and classified as quatrains and tercets based on the number of lines they contain. Stanza lines are also made up of syllables. And so on. Analysing the way in which the syntactic (sentence/phrase) structure overlaps with the prosodic (stanza/line) structure is one important way in which you can [analyse a poem][analysis].

[analysis]: http://www.tau.ac.il/~tsurxx/Recueillement.html "Archetypal Pattern in Baudelaire's 'Recueillement'"

## Containment vs Dominance ##

When you're talking about overlapping structures, it's useful to make the distinction between structures that *contain* each other and structures that *dominate* each other. Containment is a happenstance relationship between ranges while dominance is one that has a meaningful semantic. A page may happen to *contain* a stanza, but a poem *domainates* the stanzas that it contains.

In LMNL, we view a document as consisting of a *sequence of atoms*, usually characters, and ranges over those characters. But the model makes no assertions about dominance relationships between the ranges. This document model is easy to construct from a serialised document like the one above.

Conversely, [GODDAG document models][GODDAG] are directed acyclic graphs (DAGs): the nodes within those graphs have children and parents, with leaf nodes containing characters, and the parent-child relationship implies dominance. This is a useful model for processing, and particularly querying. Navigating a DAG is a lot like navigating a tree, just one that represents multiple hierarchies. But it isn't possible to construct a DAG from a serialised document like the one above without extra information about which containment relationships are actually dominance relationships, and which mere happenstance.

[GODDAG]: http://www.w3.org/People/cmsmcq/2000/poddp2000.html "GODDAG: A Data Structure for Overlapping Hierarchies"

So an important challenge is how to get from a flat, containment-only model to a DAG. There are four approaches that can be taken:

  1. For any document, for each pair of range names A and B, if every range named A contains a range named B, then assume that A dominates B; from that set of relationships, create a DAG.
  2. Introduce additional syntax into tags, such that dominance relationships between ranges can be expressed explicitly within the serialisation.
  3. Associate each document with a schema, and use the model expressed in the schema to identify dominance relationships; a Creole schema like the one above could be taking as asserting that poems dominate stanzas, for example, since stanzas are mentioned in the content model of the poem range.
  4. Defer the construction of a DAG to the point of processing; a document would then not be a DAG in and of itself, but only in relation to a particular process.

I find the last of these the most satisfactory. 1 is too arbitrary. 2 requires too much syntax. 3 requires a single schema per document (which, from experience with XML, I think is a broken model). One could imagine being able to specify something like:

    book > page > pl > #text
    book > poem > stanza > sl > #text
    book > poem > s > #text

and this generating a DAG in which a `book` node had `page` and `poem` children, `page` nodes had `pl` children which had text children, `poem` nodes had `stanza` children and `s` children, and so on. With this structure, it would be easy enough to find stanzas with four lines (`/book/poem/stanza[count(sl) = 4]`) without having to worry about the possibilities of happenstance containment, such as some stanza lines being contained by sentences that are contained by stanzas.

There's lots more to talk about here. In particular, things about the useful and appropriate ways of querying and transforming these structures, and how to best serialise them in XML. But I'll leave those thoughts for another post.

