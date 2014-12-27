---
layout: drupal-post
title: Copy-and-paste coding
created: 1183580791
tags:
- coding
---
Copy-and-paste coding drives me crazy. Here's some Javascript that I was passed today that illustrates the problem:

    if (navigator.userAgent.toLowerCase().indexOf("safari") >= 0) {
      if (pageSize > 1000000) {
        hideLink();
      }
    } else if (navigator.userAgent.toLowerCase().indexOf("opera") >= 0) {
      if (pageSize > 1000000) {
        hideLink();
      }
    } else if (navigator.userAgent.toLowerCase().indexOf("firefox") >= 0) {
      if (pageSize > 1000000) {
        hideLink();
      }
    } else if (navigator.userAgent.toLowerCase().indexOf("netscape") >= 0) {
      if (pageSize > 1000000) {
        hideLink();
      }
    } else if (navigator.userAgent.toLowerCase().indexOf("msie") >= 0) {
      if (pageSize > 1000000) {
        hideLink();
      }
    } 

The person who wrote this probably started with:

    if (navigator.userAgent.toLowerCase().indexOf("firefox") >= 0) {
      if (pageSize > 1000000) {
        hideLink();
      }
    }

then decided to expand the code to test other browsers as well. So what did they do? They copied the lines and pasted them, edited a bit, pasted again, edited a bit, and so on, until they had code to cover all the situations, ending up with 21 lines of code: 15 are exact copies and 5 are very similar to each other. Ho boy.

This is an example of copy-and-paste coding, and it has three disadvantages:

  * it bloats your code, and as we all know [the best code is no code at all][1]

  * it makes your code less efficient, because you repeatedly do the same thing; for example, the above code converts the user agent string to lower case every time it hits one of the main conditions

  * it makes your code much harder to maintain: imagine you have to maintain this code and work out that actually the test `navigator.userAgent.toLowerCase().indexOf(...)` isn't the right test. Because the code is simply repeated, you have to edit five lines. What about if the numeric limit of `1000000` needs to be changed? You have to edit five lines. Add an argument to the function call? Five lines.

[1]: http://www.codinghorror.com/blog/archives/000878.html "Coding Horror: The Best Code is No Code At All"

Copy-and-paste once, and edit heavily, by all means, but if you find yourself copy-and-pasting code repeatedly, with small edits each time, Stop. Think. Refactor. Extract the commonalities, with the aim of coding each thing just once (not just the processor doing each thing once, actually *writing* each thing once). Think about the changes that someone might need to make to your code, and factor those parts out so that they're easy to change.

OK, so I guess I have to put my neck on the line and give an example of how I'd write it. Assuming that you do actually need to have individual control over the allowed page sizes for each browser, then

    var browser = navigator.userAgent.toLowerCase();
    var defaultLimit = 1000000;

    var limits = new Array();
    limits["safari"]   = defaultLimit;
    limits["opera"]    = defaultLimit;
    limits["firefox"]  = defaultLimit;
    limits["netscape"] = defaultLimit;
    limits["msie"]     = defaultLimit;

    for (limit in limits) {
      if (browser.indexOf(limit) >= 0 &&
          pageSize > limits[limit]) {
        hideLink();
        break;
      }
    }

does the trick. I'm getting the lower case browser name only once. The tests aren't repeated, so if they change, I only have to edit in one place. The most likely things to change are split off into variables at the top of the code, so that they're easy to locate and easy to alter.

Why do I even bother to write about this, something that surely every coder knows? Because I've seen programmers, real life ones, ones who earn money as developers, doing copy-and-paste coding, and I'm fed up of being the muggins who has to wade through it, copying and pasting the same fixes, or rewriting swathes of it that they couldn't be bothered to refactor themselves along the way. I'm tired of picking my way through code to confirm that, yes, this really is a character-by-character verbatim copy of exactly the same very complex XPath used just three lines above. And don't get me started on the same code repeated in separate modules. Argh.

Show some empathy for the person who's going to be maintaining your code. Who knows: it might even be you.
