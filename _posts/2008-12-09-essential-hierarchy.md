---
layout: drupal-post
excerpt_separator: "<!--break-->"
title: Essential Hierarchy
created: 1228845572
tags:
- overlapping markup
---
In my [last post][previous] I discussed the kinds of situations where overlapping markup can appear in documents, and the distinction between *containment*, when one element happens to contain another, and *dominance*, where the relationship between the two elements is more meaningful. Here I'll expand a bit more on the issue of whether dominance relationships are or should be part of the essential information in the document.

[previous]: http://www.jenitennison.com/blog/node/95 "Overlap, Containment and Dominance"

<!--break-->

I wrote:

> So an important challenge is how to get from a flat, containment-only model to a DAG. There are four approaches that can be taken:
> 
>  1. For any document, for each pair of range names A and B, if every range named A contains a range named B, then assume that A dominates B; from that set of relationships, create a DAG.
>  2. Introduce additional syntax into tags, such that dominance relationships between ranges can be expressed explicitly within the serialisation.
>  3. Associate each document with a schema, and use the model expressed in the schema to identify dominance relationships; a Creole schema like the one above could be taking as asserting that poems dominate stanzas, for example, since stanzas are mentioned in the content model of the poem range.
>  4. Defer the construction of a DAG to the point of processing; a document would then not be a DAG in and of itself, but only in relation to a particular process.
>
> I find the last of these the most satisfactory. 1 is too arbitrary. 2 requires too much syntax. 3 requires a single schema per document (which, from experience with XML, I think is a broken model).

[James Clark][JamesClark] commented:

> I’m surprised by your rejection of approach 2 on the grounds that it “requires too much syntax”. I would be inclined to start by designing the information model first and then figure out a syntax to represent that information model. Maybe I’m just brainwashed by too much XML/SGML, but the hierarchical relationships seem like a fundamental aspect of the information about the document which the markup should be capturing explicitly.

[JamesClark]: http://www.jclark.com/ "James Clark"

So I shall expand upon my rather throw-away rejection of the option of using additional syntax within tags to express dominance relationships. There are two parts to it: philosophical and pragmatic.

## Philosophy ##

My philosophical objection applies to both the idea of indicating hierarchy within tags and using a schema (option 3 above). My attitude going into the development of [LMNL][LMNL] (an attitude that might not be shared by the [other members of the ad hoc LMNL committee][committee]) has been to carry over as few assumptions as possible from the SGML/XML world, and to see how far we can get without those assumptions. So as well as overlap, LMNL has weird things like [structured and ordered annotations][annotations], [atoms][atoms], and [anonymous ranges][anon].

[LMNL]: http://www.lmnl.org/wiki "LMNL"
[committee]: http://www.lmnl.org/wiki/index.php/Ad_Hoc_LMNL_Committee "Ad Hoc LMNL Committee"
[annotations]: http://www.lmnl.org/wiki/index.php/LMNL_data_model#Annotations "LMNL: Annotations"
[atoms]: http://www.lmnl.org/wiki/index.php/LMNL_data_model#Atoms "LMNL: Atoms"
[anon]: http://www.lmnl.org/wiki/index.php/LMNL_data_model#Ranges "LMNL: Ranges"

In that spirit, I want to see if we can get away with *not* having hierarchy as a fundamental part of the information model. Does this allow us to do things that we couldn't otherwise do, or is it a burden? I don't know yet.

I view this as somewhat similar to the questions around datatyping XML. Some people (seem to) think that elements and attributes have a particular datatype as part of their essential nature, others (myself amongst them) that two processes could reasonably view a document using different datatypes or no datatypes at all if it wasn't important for that particular processing. Just as with datatyping, the restrictive, "there can be only one", attitude is fine for people whose documents fit that model, but causes problems for those whose don't. Conversely, if your documents need only ever be seen in one way, it won't (or shouldn't) hurt you that other people want to take a more permissive approach. So allowing processing to determine hierarchy seems more likely to satisfy more people.

As a small illustration that hierarchy is in the eye of the beholder, take the [poem from my previous post][previous]. During my talk at the workshop in Amsterdam I asserted that the stanza line (`sl`) elements could hold (dominate) one or more page line (`pl`) elements. [Fabio Vitali][Fabio] objected strongly to this, saying that the relationship was simply one of containment. Shouldn't it be possible for us both to process the poem based on our differing views?

[Fabio]: http://vitali.web.cs.unibo.it/ "Professor Fabio Vitali, University of Bologna"

## Pragmatism ##

There are several models floating around as possibilities for representing overlapping structures. I talked about two of them in my last post: the [LMNL data model][LMNL] in which a document is basically a sequence of atoms (most of which will be characters) with annotated ranges over them, and the [GODDAG][GODDAG] model in which a document is a directed acyclic graph (DAG) of nodes. The GODDAG model is closest to SGML/XML in that it views the hierarchy of elements as an fundamental part of the document.

[LMNL]: http://www.lmnl.org/wiki/index.php/LMNL_data_model "LMNL data model"
[GODDAG]: http://www.w3.org/People/cmsmcq/2000/poddp2000.html "GODDAG: A Data Structure for Overlapping Hierarchies"

The [TexMECS][TexMECS] syntax, which is supposed to be amenable to representing GODDAG structures, only represents hierarchy through containment. If you want to read about it, [Yves Marcoux][Yves] did some [analysis of what is and isn't serialisable within TexMECS][ooTexMECS] at [Balisage][Balisage] last year.

[TexMECS]: http://decentius.aksis.uib.no/mlcd/2003/Papers/texmecs.html "TexMECS"
[Yves]: http://www.mapageweb.umontreal.ca/marcoux/ "Yves Marcoux"
[ooTexMECS]: http://www.balisage.net/Proceedings/html/2008/Marcoux01/Balisage2008-Marcoux01.html "Graph characterization of overlap-only TexMECS and other overlapping markup formalisms"
[Balisage]: http://www.balisage.net/ "Balisage: The Markup Conference"

In LMNL, we have the concept of limina which hold ranges (rather than atoms/characters), over which you can define other ranges. This gives us a structure roughly equivalent to a GODDAG. But despite a *lot* of back and fro, we were never able to come up with a satisfactory serialisation. You might imagine an extension to the [LMNL syntax][LMNLsyntax] that goes something like:

    [page=p199 [n}199{]}
    ...
    [poem=poem}
      [title^poem}[pl^p199}Recueillement{pl]{title]
      [stanza=s1^poem}
        [s^poem}[sl^s1}[pl^p199}Sois sage, ô ma douleur, et tiens-toi plus {pl]
                                            [pl^p199}tranquille.{pl]{sl]{s]
        [s^poem}[sl^s1}[pl^p199}Tu réclamais le Soir; il descend; le voici:{pl]{sl]
        [sl^s1}[pl^p199}Une atmosphère obscure enveloppe la ville,{pl]{sl]
        [sl^s1}[pl^p199}Aux uns portant la paix, aux autres le souci.{pl]{sl]{s}
      {stanza]
      [stanza=s2^poem}
        [s^poem}[sl^s2}[pl^p199}Pendant que des mortels la multitude vile,{pl]{sl]
        [sl^s2}[pl^p199}Sous le fouet du Plaisir, ce bourreau sans merci,{pl]{sl]
        [sl^s2}[pl^p199}Va cueillir des remords dans la fête servile,{pl]{sl]
        [sl^s2}[pl^p199}Ma douleur, donne moi la main; viens par ici,{pl]{sl]
      {stanza]
      [stanza=s3^poem}
        [sl^s3}[pl^p199}Loin d'eux.{s] [s^poem}Vois se pencher les défuntes {pl]
                                                    [pl^p199}Années,{pl]{sl]
        [sl^s3}[pl^p199}Sur les balcons du ciel, en robes surannées;{pl]{sl]
        [sl^s3}[pl^p199}Surgir du fond des eaux le Regret souriant;{pl]{sl]
      {stanza]{page]
      [page=p200 [n}200{]}[stanza=s4^poem}
        [sl^s4}[pl^p200}Le Soleil moribund s'endormir sous une arche,{pl]{sl]
        [sl^s4}[pl^p200}Et, comme un long linceul traînant à l'Orient,{pl]{sl]
        [sl^s4}[pl^p200}Entends, ma chère, entends la douce Nuit qui {pl]
                                                  [pl^p200}marche.{pl]{sl]{s]
      {stanza]
    {poem]
    ...
    {page]

in which each range can point to its parent range via its ID (IDs being set with the standard `=id` and the child relationship being indicated by `^id`). Or various other ways of doing it, none of which are convincing.

[LMNLsyntax]: http://www.lmnl.org/wiki/index.php/LMNL_syntax "LMNL syntax"

[XCONCUR][XCONCUR] (which is pretty much the same syntax as CONCUR in SGML, but using XML) does indicate hierarchy, using syntax like this:

    <(phy)page n="199">
    ...
    <(syn)poem><(pro)poem>
      <(pro)title><(syn)title><(phy)pl>Recueillement</(phy)pl></(syn)title></(pro)title>
      <(pro)stanza>
        <(syn)s><(pro)sl><(phy)pl>Sois sage, ô ma douleur, et tiens-toi plus </(phy)pl>
                                            <(phy)pl>tranquille.</(phy)pl></(pro)sl></(syn)s>
        <(syn)s><(pro)sl><(phy)pl>Tu réclamais le Soir; il descend; le voici:</(phy)pl></(pro)sl>
        <(pro)sl><(phy)pl>Une atmosphère obscure enveloppe la ville,</(phy)pl></(pro)sl>
        <(pro)sl><(phy)pl>Aux uns portant la paix, aux autres le souci.</(phy)pl></(pro)sl></(syn)s>
      </(pro)stanza>
      <(pro)stanza>
        <(syn)s><(pro)sl><(phy)pl>Pendant que des mortels la multitude vile,</(phy)pl></(pro)sl>
        <(pro)sl><(phy)pl>Sous le fouet du Plaisir, ce bourreau sans merci,</(phy)pl></(pro)sl>
        <(pro)sl><(phy)pl>Va cueillir des remords dans la fête servile,</(phy)pl></(pro)sl>
        <(pro)sl><(phy)pl>Ma douleur, donne moi la main; viens par ici,</(phy)pl></(pro)sl>
      </(pro)stanza>
      <(pro)stanza>
        <(pro)sl><(phy)pl>Loin d'eux.</(syn)s> <(syn)s>Vois se pencher les défuntes </(phy)pl>
                                                    <(phy)pl>Années,</(phy)pl></(pro)sl>
        <(pro)sl><(phy)pl>Sur les balcons du ciel, en robes surannées;</(phy)pl></(pro)sl>
        <(pro)sl><(phy)pl>Surgir du fond des eaux le Regret souriant;</(phy)pl></(pro)sl>
      </(pro)stanza></(phy)page>
      <(phy)page n="200"><(pro)stanza>
        <(pro)sl><(phy)pl>Le Soleil moribund s'endormir sous une arche,</(phy)pl></(pro)sl>
        <(pro)sl><(phy)pl>Et, comme un long linceul traînant à l'Orient,</(phy)pl></(pro)sl>
        <(pro)sl><(phy)pl>Entends, ma chère, entends la douce Nuit qui </(phy)pl>
                                                  <(phy)pl>marche.</(phy)pl></(pro)sl></(syn)s>
      </(pro)stanza>
    </(pro)poem></(syn)poem>
    ...
    </(phy)page>

The `pro`, `syn` and `phy` labels in brackets before the element names indicate the hierarchy to which each element belongs. Elements can overlap if they have different labels. As you can see, this syntax means a lot of repetition for elements that belong to more than one hierarchy and there's a built-in limitation here regarding self-overlap (ie of elements that can overlap other elements with the same name).

[XCONCUR]: http://www.xconcur.org/ "XCONCUR"

Now this isn't altogether rational, but I think that the fact that we haven't managed to come up with a good syntax that expresses hierarchy, even without the restrictions of XML well-formedness, is an indication that it's not meant to be. I am firmly of the opinion that simplicity and elegance are hallmarks of good design. If hierarchies can only be expressed through an ugly syntax, then it's just not worth it.

Slightly more rationally: if the syntax for expressing hierarchies is that verbose and difficult to use, people won't use it, and we'll have to find a way to add dominance relationships programmatically. We might as well start from that point.

But perhaps someone out there can come up with a clean, elegant syntax for expressing dominance within overlapping markup?

