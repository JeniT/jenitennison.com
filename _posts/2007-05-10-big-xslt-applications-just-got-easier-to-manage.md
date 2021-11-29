---
layout: drupal-post
excerpt_separator: "<!--break-->"
title: Big XSLT applications just got easier to manage
created: 1178783922
tags:
- xslt
- software
---
I used to know how to arrange my XSLT modules. Each module had to be self-contained, and any common code imported into all the modules that used it. The reason? Because when you have on-going validation of your XSLT stylesheets, if the module can't stand alone then you get all sorts of spurious errors. For example, if you define a variable in module A, which includes module B which uses that variable, then although the application as a whole will work fine, when you're editing module B you'll get errors because the variable isn't defined in that module.

That rationale just got blown out of the water.

<!--break-->

Yes, it's another [&lt;oXygen/&gt;][1] release! Back in the 90s, the release of a new web browser would set my heart racing (yes, I was that much of a geek). Nowadays I get my thrills from new versions of &lt;oXygen/&gt; (yes, I'm still that much of a geek). &lt;oXygen/&gt;'s already packed with features that make my life easier, but somehow each release seems to come up with something that I never knew I needed but find I can't live without.

It's as if George Cristian Bina and the team are spying on me. I've been dealing recently with some large XSLT applications, written by someone else, that *haven't* been designed with standalone modules. And it's such a headache, not knowing whether an error that's been reported is a *real* error (like a mis-spelled variable reference) or something that will be fine when the module is used in context. I've had to resort to running the transformation to identify static errors in the stylesheet, which is tedious and time-consuming.

New &lt;oXygen/&gt; release to the rescue! &lt;oXygen/&gt; 8.2 has "Validation Scenarios", which means you can tell &lt;oXygen/&gt; to validate particular files starting from other modules. Suddenly the only errors that are reported are the ones that you really have to do something about. And the same technique works for schema files, or any document that needs to be validated in context!

There are a couple of other new things that are handy too. Just the other day I was thinking "Hmm, this Outline view is really useful but I wish it would show me the name attribute rather than the id attribute for these elements." Now I can configure it to show whichever attributes I want. And multi-line search & replace: what a godsend! (There are lots more new features; these are just the ones that I've used in the day since I installed it.)

There were a couple of things that came up in the last version of &lt;oXygen/&gt; that I reported and have been fixed. One was a problem opening files with long lines: now if you try to open such a file you get asked if you want to format & indent it on opening. I think that being responsive to users (whether bug reports or requests for features) is a real indication of the development of great software. It makes a huge difference that George Cristian Bina (like Michael Kay) is approachable and active in the community: their applications are better for it, and their users much more loyal!

So now I have to go re-think my rules of thumb on how to organise modules...

[Disclosure: I get a free license for &lt;oXygen/&gt;, and they've made it easy for me to provide temporary licenses when I run training courses, so I'm in their debt. But honestly, I'd pay for it if I didn't get it for free. I really couldn't live without it.]

[1]: http://www.oxygenxml.com/ "Oxygen XML Editor"
