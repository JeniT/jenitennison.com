---
layout: drupal-post
excerpt_separator: "<!--break-->"
title: Partitioning overlapping markup
created: 1181594169
tags:
- creole
- overlapping markup
---
[Wendell Piez][1] forwarded me an interesting poster by [Bert Van Elsacker][2] on automatic fragmentation of overlapping structures. That's taking something like:

    <bold> this is bold <italic> and italic </bold> text </italic>

and turning it into something well-formed, like:

    <bold> this is bold <italic> and italic </italic></bold><italic> text </italic>

[1]: http://www.piez.org/ "Wendell's Home Page"
[2]: http://www.huygensinstituut.knaw.nl/index.php?option=com_content&task=view&id=120&Itemid=57 "Bert Van Elsacker"

When you do this, you have to decide which elements can be split and which can't, and their relative priorities. Wendell suggested that perhaps Creole might help to do this. I have been thinking about is using Creole to add annotations to markup (something like, you add attributes to the Creole patterns and they get copied on to the matched ranges, or are used to create new ranges), but I haven't done that yet, and actually I think you probably want a different kind of language to do it ([a new kind of schema language][3] like James Clark suggested), because the way in which you break up overlapping structures has a lot to do with how you're going to process them.

[3]: http://blog.jclark.com/2007/04/do-we-need-new-kind-of-schema-language.html "James Clark: Do we need a new kind of schema language?"

<!--break-->

I'm reminded of the paper

> Sperberg-McQueen, C. M., David Dubin, Claus Huitfeldt and Allen Renear. “[Drawing inferences on the basis of markup.][4]” In Proceedings of Extreme Markup Languages 2002. 

[4]: http://www.idealliance.org/papers/extreme/proceedings/html/2002/CMSMcQ01/EML2002CMSMcQ01.html

in which (based on my memory of the talk) they discuss how different elements allow you to make different assertions about the text they contain, and consequently can be split in different ways. For example, a `<paragraph>` element can't be split into two `<paragraph>` elements without changing the meaning of the document, whereas a `<bold>` element can be split into two `<bold>` elements with no problems because it's really indicating "these characters are bold" rather than "this is a bold phrase".

You can take a purist view (which would usually entail splitting hardly any elements, since most elements *do* mark up a range of text rather than the individual characters they contain), but I think the main reason you want to do this fragmentation is for presentation. And in that context, the notional semantics of the element don't really matter: what matters is how they're styled. For example, a `<comment>` element, marking up a range of text that has been commented on, might not be splittable at a theoretical level, but if you're going to render it simply by turning the background yellow, then in fact you *can* split it for that purpose.

Since it's related to presentation, I wonder whether you could use a (simplified) CSS stylesheet to provide both the fragmentation and the style. Block-level elements (`display: block;`) couldn't be split whereas inline elements could. Elements that have the box model properties (margin, padding & borders) can't be split, or, if they are, you need to mark the fragments as "left", "middle" and "right", and only apply the *left* margin/padding/border to the "left" fragment, and similarly with the right.

It wouldn't be a general purpose transformation mechanism, but it would be darned useful!
