---
layout: drupal-post
title: Lessons learnt
created: 1182237324
tags:
- xslt
---
I'm coming up to completion on the project that I've been working on for the last six months or so. It's been very different from the projects that I'm used to: usually I fly in and either write a stylesheet or schema to a given specification and hand it off, or have to wade through, critique and improve a lot of existing XSLT code or schemas. Here, I've been involved in a much more end-to-end way: having to do the technical specification myself, do a lot of the testing, and deal with the bugs. Plus half of the project has involved customising existing (complex) stylesheets, written by someone else.

So, what have I learned?

<!--break-->

On the coding, the biggest thing that I wish I'd done right from the start was to clean up the source XML before transforming it. The initial source XML that I was dealing with was *extremely* irregular, due to having been written in different XML editors by different people over a fairly long period of time, to a loose DTD, for the express purpose of rendering into HTML with a particular stylesheet. It was littered with tag abuse, empty elements (containing whitespace) and, basically, a huge amount of variability in the markup of similar content. I should have normalised it from the start, instead of attempting to deal with all that variability in the transforming stylesheet; that would have made for a lot cleaner code. So this is my big lesson: next project, I will add a "rationalising" step at the start of the process, even if that rationalising step (initially) does nothing.

Splitting the process up into steps would have helped a lot generally. I was creating three views of the same set of (3500) documents; the three views were essentially the same, except that two of the three were paginated and they each used a different HTML "skin". The code I was building on produced these three views entirely separately, so I followed that design. But I really kicked myself when it came to transforming the 3500 documents! I sat and watched the hours pass by, knowing that this particular batch was doing pretty much exactly the same transformation as the batch I'd set going the previous night. Better up-front analysis of the commonalities between the three views would have reduced the repetition, made the code cleaner and easier to debug, and saved me a huge amount of time. Repeat to self: pipeline pipeline pipeline.

On documentation, I found having to write the technical specifications up-front really frustrating. It's impossible to fully understand the potential problems in an application without starting to code. I found I spent at least as much time correcting the technical specification as I did coding... until I stopped updating the technical specification (so now it's out of date, sigh). I think next time I won't be so ambitious in the technical spec, both in terms of the amount that I do prior to starting coding and in the depth to which I describe the way the code works. Code-level documentation probably belongs in the code, and where I've done it (judiciously, on particularly complicated code), it's really helped me during the debugging stage.

There are several lessons on the testing side.

First, for half of the project I was able to use my [XSLT unit testing framework][1]. In the places where I (a) wrote the tests and (b) ran the tests, the code is really solid. In the places where I (a) didn't write the tests or (b) didn't keep running the tests, it's not. So, like, I need to write more tests and actually run them! Duh-huh.

[1]: http://www.jenitennison.com/xslt/utilities/unit-testing/ "Jeni's XSLT Unit Testing Framework"

Second, there was a fairly tight (XSD) schema for the output for one of the transformations I was doing, so one of the ways in which the output could be tested was by validating it against this schema. This was very worthwhile. But (and I knew this, but it bears repeating) validation only tells you that something *isn't* valid, it doesn't tell you that something *is* valid. It couldn't detect when my stylesheets were ignoring part of the source, nor when they mistakenly repeated it.

Third, a reasonable amount of the testing was done by other people. This is great, especially at exposing the kinds of bugs where I'd sort of thought "well, it's not ideal, but it's probably not worth fixing at the moment..." Just as when writing, you get to a point where you *scan* the result of a transformation, rather than really looking at it, and a fresh pair of eyes is essential.

Yes, I know these lessons are hardly earth-shattering, and that I'll make exactly these errors again in the name of just getting the code out of the door, and regret it. Such is life.

A final word: [Firebug][2]. This tool is absolutely essential when debugging layout or scripting problems in Firefox. The best thing is that you can actually edit the CSS (or HTML) in the Firebug frame and see the results of that editing on the page. So you don't have endless cycles of editing, saving, switching windows, reloading, switching windows, editing, etc. etc. How I wish there were a similar tool for IE.

[2]: http://www.getfirebug.com/ "Firebug plug-in for Firefox"
