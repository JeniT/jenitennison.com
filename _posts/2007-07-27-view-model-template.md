---
layout: drupal-post
excerpt_separator: "<!--break-->"
title: View-Model-Template
created: 1185530524
tags:
- xslt
- rest
---
I don't know anything about Struts 1, but [Bill de hÓra's recent post][1] has got some interesting web-application-design tips. There were two particular bits that spoke to me:

> **struts-config.xml** struts-config tries to capture primarily the flow of application state on the server, by being an awkward representation of a call graph. In doing it misses a key aspect of the web - hypertext. In web architecture, HTML hypertext on the client is the engine of application state, not an XML file on the server.

In other words (I think) in web applications your state in the page you're on and taking action is about following the links (or submitting the forms) on the page. Your actions (and therefore the transitions between different states) are determined by what links and forms are on the page. But in fact, URLs should be hackable, and transitions unlimited. When you design the application what you really need to think about are the tasks the users want to achieve (and therefore the transitions that they might *want* to make) rather than the *possible* state transitions.

[1]: http://www.dehora.net/journal/2007/07/struts_1_problems.html "Bill de hÓra: Struts 1 Problems"

<!--break-->

> On the web, a suitable pattern is View, Model, Template [rather than Model, View, Controller (MVC)]. A request to a URL is dispatched to a View. This View calls into the Model, performs manipulations and prepares data for output. The data is passed to a Template that is rendered an [sic] emitted as a response. ideally [sic] in web frameworks, the controller is hidden from view. Note that this framework style is often called MVC anyway, confusing matters somewhat; The key differences are that Views and Templates are cohesive and Controllers are pushed down into the framework infrastructure.

I've been thinking recently about whether and how XSLT might fit into a [Ruby on Rails][2] set-up. In <abbr title="Ruby on Rails">RoR</abbr>, the controller usually either queries the database (via the model) to set up instance variables, and then renders a (template) view, or updates the database (via the model) and redirects to another view. The templates (for (X)HTML) use fairly standard `<% ... %>` placeholders to hold code and insert values.

I've spent most of my professional life cursing (X)HTML documents with `<% ... %>` in, because they use unescaped less-than-signs and therefore can't be generated or processed by XML tools, particularly XSLT. There's an advantage of having templates that are themselves well-formed, not least that you can easily process the templates themselves (for example to generate, update or document them). Plus if your templates are declarative, rather than containing embedded code, you aren't tied to a particular framework: I could move templates from Ruby on Rails to Django and they wouldn't need modification. When I think "declarative templates", I think "XSLT".

The other advantage of using XSLT is that it can be used on the client side as well as the server side. So there's the possibility of moving that rendering from one server to client completely or using it on particular clients, perhaps in an AJAX set-up, while having the same stylesheets on the server for those browsers that don't support client-side XSLT.

You still need a way of getting the data from the model into the stylesheet, which can be done through a combination of XML and parameters. The XML is itself a view of the model, of course, but if you've got any kind of intention to make your web application mashable, you're going to want to generate XML, probably Atom, anyway (yeah, or JSON, but it's easy enough to get from XML to JSON using XSLT too). If you add caching to the equation, this approach might help reduce database requests.

[2]: http://www.rubyonrails.org/ "Ruby on Rails"

So I think that using XSLT as a templating language, even within a RoR framework, has at least something going for it. What I hope is that I'm not falling into the "when you've got a hammer everything looks like a nail" trap.
