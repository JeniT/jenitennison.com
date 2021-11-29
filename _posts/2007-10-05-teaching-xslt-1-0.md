---
layout: drupal-post
excerpt_separator: "<!--break-->"
title: Teaching XSLT 1.0
created: 1191619717
tags:
- xslt
---
I'm exhausted after two days of teaching XSLT 1.0. Yes, there are still people out there who want to learn it. The exhaustion comes mainly because I'm an introvert (INFP, Myers-Briggs fans!) who finds it tiring just being in the same room as someone else.

In fact, I've been teaching XSLT 1.0 rather a lot in the past couple of months. The first lot was a bunch of C# programmers who had done some light XSLT work, the second a bunch of developers who'd been using XSLT for years, but wanted to improve. The majority of people on this most recent course weren't even developers.

It's interesting seeing who struggles and who sails through the course. Some observations:

  * You need to understand XML to use XSLT. At the very least, you need to know what elements and attributes look like in an XML document, so you just know that attributes need matching quotation marks and elements need end tags. Half the syntax problems learners have with XSLT are because they're not using proper XML syntax. Without that fundamental terminology, you haven't a hope, because you can't even talk about XSLT, let alone getting information out of an XML document. I guess this is an advantage of XQuery: at least as a teacher you *know* you have to teach the basic syntax of the language, rather than taking it as a given. Actually, scratch that: you still have to teach XML syntax with XQuery, since that's what people are processing and generating, *and* you have to teach the bastardised, almost-XML syntax that XQuery uses. I haven't done an XQuery course yet, but surely that must be confusing?

  * I always always always have to spend a long time explaining namespaces. That's not going to surprise anybody. In the end I just provide these rules of thumb:

    1. Declare the XSLT namespace (usually `xsl` prefix)
    2. Declare the namespaces you want to appear in the result, with the prefixes that you want to appear in the result. This can include a default namespace declaration.
    3. Declare the namespaces that appear in the source, with prefixes for every one (even if they're usually the default namespace in the source). Add an `exclude-result-prefixes` attribute that lists these prefixes (at least the ones that aren't also used in the result).
    4. Declare the namespaces that you use in the stylesheet. List the ones that are used for extensions (elements or functions) in `extension-element-prefixes` (technically, you don't have to declare the ones you use for extension functions; I just think it's clearer if you list all the prefixes used for extensions here); make sure the other ones are listed in `exclude-result-prefixes`.

  * Having a programming background is a blessing and a curse when learning XSLT. It's a blessing because you understand basic principles like "instructions" and "expressions" and "operators" and "functions" and "code blocks". But it's a curse because most programmers use conventional programming languages like C# and Java, which are procedural, and XSLT's way of doing things is completely different. The most recent course I taught was to people who dealt with completely data-oriented XML; trying to explain to them why applying templates is a useful thing to do was really hard.

  * Creating exercises that are based on the markup languages used by the people attending the course is always worthwhile. It takes time to prepare, but they get a better grasp on what's going on in the transformations that they create (because they understand the domain), and they learn how to do things on the course that are going to be directly useful for them in their ongoing practice.

  * The students find the examples the most helpful things in the slides. Whenever I see them look at the slides as they're doing the exercises, they're looking at the examples, not the abstract descriptions of how something works. Perhaps I should try having slides with (almost) nothing but examples. (It's interesting, because *I'm* always interested in the theoretical underpinnings of the things I learn about -- if I don't understand why, I can hardly understand how -- but it seems I'm in the minority; it's the N in INFP, I guess.)

  * Having a bit of enforced interaction in the middle of the presentation works well, such as a list of examples and going around the room asking the students to explain what each means. It wakes up the students who are falling asleep. It forces them to think about what they've been listening to. It highlights parts that they haven't understood (so I know they need a fresh explanation). And it seems to encourage them to ask questions. Just asking a question to the room doesn't work so well -- it tends to be the same people that answer each time, or there's an embarrassing silence.

  * I've been trying to use a [Socratic Method][1] when I'm asked for help during the exercises, at least when the problem isn't "obvious" (like a mis-spelled element name). The difficulty for me is finding the right question to ask, but eventually I find one that they're able to answer easily, and things flow well from there. More often than not, the student's able to find the answer to their problem without me providing the solution, which has to be good for learning.

[1]: http://www.garlikov.com/Soc_Meth.html "The Socratic Method in teaching"

  * In the end, the main things that differentiate between those that learn a lot and those that learn a little are a willingness to try (those who don't attempt the exercises don't absorb what I've taught from the front of the class) and a willingness to ask questions (those who don't end up getting stuck on one thing, and can't move past it). I also think cut-and-paste coders learn less -- cut-and-paste coding practices recognition (finding the right example to cut-and-paste) rather than generation (creating something new from scratch) -- but maybe that's just snobbishness on my part.

Anyway, I'm hoping I can get rid of my XSLT 1.0 course soon, and move on to teaching XSLT 2.0. It'll be a longer course, but there'll be less "no, there's no built-in support for that in XSLT 1.0".
