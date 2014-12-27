---
layout: drupal-post
title: XTech Creole presentation fallout
created: 1179348527
tags:
- xtech
- creole
---
[Henry Thompson][1] had a lot to say after [my Creole presentation][2] (open takahashi.xul?data=creole.data; requires Firefox) about the benefits of stand-off markup for linguistic information. From his overview, it seems that the [NITE XML Toolkit][3] that he's been involved with represents overlapping linguistic data by holding atoms (here meaning the "lowest common denominator" shared pieces of data) and having multiple trees marking up these atoms. The trees are independently validated (since they are pure XML), with cross-hierarchy validation done through the query language. This is pretty similar to the [XCONCUR][4] approach, which augments a CONCUR-like multi-grammar validation with a Schematron-like constraint language.

[1]: http://www.ltg.ed.ac.uk/~ht/ "Henry S. Thompson's Home Page"
[2]: http://www.jenitennison.com/blog/files/XTech2007CreoleSlides.zip "XTech 2007 Creole presentation"
[3]: http://www.ltg.ed.ac.uk/NITE "NITE XML Toolkit"
[4]: http://www.idealliance.org/papers/extreme/Proceedings/html/2006/Schonefeld01/EML2006Schonefeld01.html "Towards Validation of Concurrent Markup"

<!--break-->

Now, I have nothing against using constraint languages (like Schematron) to validate documents, but grammars (like RELAX NG) have big advantages. Most importantly, they are easier to write (if they're designed properly), and tools can analyse them to do useful things, such as tell you what element or attribute is expected next. If it's possible to write cross-grammar constraints in a grammar (like Creole) then why would you use a constraint language to do it?

I think the big difference between Henry's domain and the one that I think will move overlap into the mainstream is between global and local concurrence. With global concurrence, entirely separate hierarchies are applied to the same data, so the natural validation mechanism is to use entirely separate grammars (with perhaps a few small rules to do cross-grammar validation where that proves necessary). With local concurrence, the vast majority of the document follows a single hierarchy with concurrence happening at a low level.

Actually, the best example for this doesn't even involve overlap. Consider HTML paragraphs, which contain various inline elements such as `<strong>`, `<em>` and `<a>`. It doesn't make sense for these elements to contain themselves (strong text is neither made stronger nor negated by appearing in two `<strong>` elements, and it's not allowed for links to contain other links). So the natural model in Creole is

    p      = element p { mixed { strong* & em* & a* } }
    strong = range strong { text }
    em     = range em { text }
    a      = range a { attribute href { text }, ..., text }

This model allows `<a>` elements to appear within `<em>` elements, or vice versa, not because of the content model of `<em>` but because the two ranges are interleaved (and one arrangement of interleaved ranges is containment). It doesn't allow any of these elements to appear inside themselves. It would be a real maintenance headache to have separate grammars for each of these inline elements, when most of each of the grammars (all the hierarchy down to the paragraph level) would be the same.

Actually, looking at NITE, it seems like it employs a data model that's quite like [LMNL's][5], in that it has the concept of layers over atoms or ranges/elements. (Interestingly it looks like they get around the problem of identifying which ranges belong to which layers purely by using their name.) Another difference here might be that while I'm talking about supporting overlap in fairly heavily structured documents (like office documents), they're really using fairly flat annotations, where there isn't much of a grammar anyway. But I might have that wrong: need to do more reading. The other thing to investigate is whether they have any support for self-overlap (`<phrase>` elements overlapping other `<phrase>` elements): I kinda gather that they don't.

[5]: http://www.lmnlwiki.org/index.php/LMNL_data_model "LMNL data model"

Anyway, Henry also made the points that (a) that he doesn't want a new syntax for overlap and (b) stand-off markup works very well thank you. To address the latter point first, I think stand-off markup works very well if you have the tools to support it. It's fine if you have an integrated toolkit which can pull together and display the stand-off markup as embedded markup, and let you create ranges by highlighting text with a mouse. But the great power of HTML and other web technologies is that you don't need to use a specialised toolkit to write it: you can just use a text editor and it's all right there in front of you with no (or minimal) cross-referencing required. Frankly, I'm not interested in "core" technologies that require me to install a particular piece of software in order to make use of them (cf [Erik Meijer][6]'s talk on [LINQ][7], which I'll have to discuss another time). I expect to be able to write a document containing overlap as easily as I can write a normal XML document.

[6]: http://research.microsoft.com/~emeijer/ "Erik Meijer's Home Page"
[7]: http://msdn.microsoft.com/data/ref/linq/ "LINQ"

On Henry's point about yet another syntax for overlap, I am more and more coming to the conclusion that overlap will hit the mainstream if we have a simple way of encoding overlap in normal XML documents, namely something along the lines of [LIX][8]. Interestingly, [Yves Savourel][10]'s talk on Applying the [Internationalization Tag Set][9] was quite inspirational in this regard, since the working group seem to have put together a standard that both provides a set of standard elements and attributes to guide localisation, along with a method of mapping elements and attributes in existing markup languages onto those ITS elements and attributes. I wonder whether a similar approach could be used with LIX... but I'll have to leave those thoughts for another time.

[8]: http://www.lmnlwiki.org/index.php/Talk:ECLIX#LIX "LMNL-in-XML"
[9]: http://www.w3.org/TR/2007/REC-its-20070403/ "Internationalization Tag Set (ITS) Version 1.0"
[10]: http://www.translate.com/ "Yves Savourel's Website"
