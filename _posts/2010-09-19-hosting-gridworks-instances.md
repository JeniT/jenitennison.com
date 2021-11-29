---
layout: drupal-post
excerpt_separator: "<!--break-->"
title: Hosting Gridworks Instances
created: 1284922610
tags:
- datagovuk
- gridworks
---
I've [written previously](http://www.jenitennison.com/blog/node/145) about how wonderful [Freebase Gridworks](http://code.google.com/p/freebase-gridworks/) ([shortly to be "Google Refine"](http://groups.google.com/group/freebase-gridworks/browse_thread/thread/f58390cd729c35fe/636f8332b44fbb00#636f8332b44fbb00)) is for cleaning and converting data. Within the UK public sector, there are two big barriers to its use, however:

  1. Public sector workers typically can't install software on their computers.
  2. They're also typically stuck with IE7 (or even, if they're really unlucky, IE6).

We've got around the first of these issues by installing Gridworks as a hosted (password-protected) instance on `http://source.data.gov.uk/gridworks`. Now, this isn't perfect of course: Gridworks wasn't designed to be used as a shared instance, so it doesn't have support for multiple users operating on the same project at the same time, let alone things like user accounts or access control. So we're operating on trust here -- hoping that people won't delete or edit each others' projects -- but it's worth the risk.

It's also not particularly pretty in that the links that Gridworks uses all assume that it's running at the root of a web server. Fortunately, source.data.gov.uk doesn't need to have a home page, so it's possible to have Gridworks available at the root (although in hope of something better in the future, I've made the main point of entry `/gridworks`).

I got this working by installing Gridworks normally on the server and using Apache as a proxy, with the following configuration:

    # Gridworks support
    RewriteRule "^/$" "/gridworks" [R,L]
    RewriteRule "^/gridworks(.*)$" "http://localhost:3333$1" [P,L]
    RewriteRule "^/(.*)$" "http://localhost:3333/$1" [P,L]
    ProxyPass /gridworks/ http://localhost:3333/
    ProxyPassReverse /gridworks/ http://localhost:3333/

That's it.

The IE7 problem will take a bit longer to solve, I imagine.
