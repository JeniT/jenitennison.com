---
layout: drupal-post
title: Detecting streamability in XPath expressions and patterns
created: 1194378345
tags:
- xslt
- pipelines
---
The XSL Working Group [gave some comments][1] recently on the [Last Call Working Draft of XProc][2]. One of the comments was about a bunch of standard steps that we've specified which do things you can do in XSLT, such as renaming certain nodes. These steps generally use XPath expressions or XSLT patterns to identify which nodes should be processed.

What bothers the XSL WG is that these steps aren't guaranteed to be streamable. In a streamable process, an input document can be delivered to the processor as a stream of events (and an output similarly generated as a stream of events) rather than as an in-memory representation. Such processes will start producing results more quickly and require less memory than non-streamable ones. And, because they don't need as much memory, they are able to work on larger documents.

If the processes we defined in XProc *were* streamable, there'd have a clear advantage over their XSLT equivalents, and therefore a purpose. However, since they're *not* guaranteed streamable, it looks like we're simply creating yet another transformation language.

[1]: http://lists.w3.org/Archives/Public/public-xml-processing-model-comments/2007Oct/0118.html "XSL WG Comments on XProc Last Call"
[2]: http://www.w3.org/TR/2007/WD-xproc-20070920/ "W3C: XProc Last Call Working Draft"

<!--break-->

My [response][3] was basically that we left it down to implementers to detect when a particular expression/pattern was streamable because defining a streamable subset of XPath would (a) take too long, (b) require people to learn a particular XPath subset, raising the adoption barrier, (c) require implementers to implement their own XPath engines, raising the implementation barrier.

[3]: http://lists.w3.org/Archives/Public/public-xml-processing-model-comments/2007Oct/0123.html "Jeni's response to XSL WG comments on XProc's streamability"

But if you put those pragmatic reasons to one side, I think there are good abstract reasons not to specify a streamable XPath subset. First, there is no clear line that can be drawn between a streamable XPath and an unstreamable one, only a scale between "buffering nothing" and "buffering everything" (building an object model). Second, you can't judge the streamability of an XPath expression on its own: there are multiple other factors that effect how streamable a given XPath expression is for a particular processor.

To illustrate, say that we're renaming all elements that we select, and let's start with an expression that's obviously streamable:

    //section

No problems here: as soon as we hit an start-tag (or end-tag) for a `<section>` element, we can change its name.

Now add a predicate:

    //section[@type = 'summary']

This predicate tests the value of the `type` attribute on the `<section>` element. If we're using SAX or StAX events, then this is as straightforwardly streamable as the previous example, because attribute values are reported at the same time as start-tags. But that's purely down to the API: the underlying algorithm for streaming RELAX NG validation uses a different event model, for example, in which attributes are reported after the start tag begins (and before the start tag ends). So **streamability depends on the event model**.

Now a different predicate:

    //section[title = 'Summary']

This predicate tests the value of the `<title>` child of the `<section>` element. In fact, it tests if the `<section>` element has *any* `<title>` child with the value `'Summary'`. Normally, an XPath processor won't be able to tell that a `<section>` *doesn't* satisfy the predicate until it gets to the end-tag of the element. So it will have to buffer the events from each `<section>` start tag until its end tag until it can work out whether to do the renaming or not.

But say the `<section>` elements in this markup language can only contain a single `<title>`, and that's the first child of the `<section>`. For an XPath processor that's aware of the DTD or schema that the document adheres to, the situation is then very similar to the previous one, which tested the attribute. So **streamability depends on how much the processor knows about the markup language**.

Changing the XPath to

    //section[title[1] = 'Summary']

similarly limits how much the processor will have to buffer if the `<title>` always appears, and always appears first, even without the processor being told that rule through a schema. So **streamability depends on the markup language itself**.

Anyway, I had a quick look at some academic work on streamability, such as [XSQ][4], [TurboXPath][5] or the recent paper ["Efficient Algorithms for Evaluating XPath over Streams"][6]. These papers really surprised me. The things that prove difficult include backwards axes (which is surprising since information about the previous nodes should be easily available), the descendant axis, and the position function. On the other hand, predicates are absolutely fine (despite requiring a "look ahead"). [Weirdly enough, all the papers I looked at contained XPath errors; I guess when you're considering abstract algorithms you don't have to care about insignificant things like language syntax.]

The [paper][6] I mentioned above actually defines something called Univariate XPath which conforms to the syntax:

    Path      := Step | Path Step
    Step      := Axis NodeTest
                 | Axis NodeTest '[' Predicate ']'
    Axis      := '/' | '//'
    NodeTest  := Name | '*'
    Predicate := Path
                 | Path CompOp Path
                 | Predicate 'and' Predicate
                 | Predicate 'or' Predicate
                 | 'not' Predicate                            [sic]
    CompOp    := '=' | '!=' | '>' | '>=' | '<' | '<='

This might be a useful starting point, but it omits useful things like attributes and functions which (as far as I can tell) wouldn't effect the applicability of the algorithms. It's also worth noting that it will allow paths such as `/database[dummy]/record`, which would involve buffering every `<record>` until the end tag of the `<database>` document element was reached. This illustrates that just because an XPath is theoretically streamable (can be evaluated based on a stream of events) doesn't mean it can be evaluated efficiently.

Some final thoughts:

  * I wonder if there's scope for an XPath subset that can be mapped to RELAX NG syntax and therefore evaluated using Brozozowski derivatives
  * what about an algorithm that evaluates XPaths using a pipeline process, whereby the stream of events is actually passed through several filters in order to provide the final evaluation
  * I'm sure there's preprocessing that could be done on some XPath expressions that would increase their streamability

[4]: http://www.cs.umd.edu/projects/xsq/ "XSQ: A Streaming XPath Engine"
[5]: http://www-cs-students.stanford.edu/~amrutaj/work/papers/xpath.pdf "Project Report on Streaming XPath Engine"
[6]: http://doi.acm.org/10.1145/1247480.1247512 "Efficient Algorithms for Evaluating XPath over Streams"
