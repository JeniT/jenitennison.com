---
layout: drupal-post
title: Extension primitives in XSDL
created: 1200783620
tags:
- xslt
- schema
- dtll
---
Michael Sperberg McQueen (CMSMcQ) has written a couple of interesting posts about [datatypes in W3C's XML Schema (XSDL)][1]. (The second is [a response to][2] a comment from [John Cowan][4], and attempts to justify some of the seemingly arbitrary decisions made in the set of datatypes present in XSDL 1.0.) The posts are a discussion of one of the issues against XSDL 1.1 raised by [Michael Kay][5]:

> Michael proposes: just specify that implementations may provide additional implementation-defined primitive types. In the nature of things, an implementation can do this however it wants. Some implementors will code up email dates and CSS lengths the same way they code the other primitives. Fine. Some implementors will expose the API that their existing primitive types use, so they choose, at the appropriate moment, to link in a set of extension types, or not. Some will allow users to provide implementations of extension types, using that API, and link them at run time. Some may provide extension syntax to allow users to describe new types in some usable way (DTLL, anyone?) without having to write code in Java or C or [name of language here].

[1]: http://people.w3.org/~cmsmcq/blog/?p=26 "Michael Sperberg McQueen: Allowing ‘extension primitives’ in XML Schema?"
[2]: http://people.w3.org/~cmsmcq/blog/?p=27 "Michael Sperberg McQueen: Primitives and non-primitives in XSDL"
[3]: http://www.idealliance.org/papers/extreme/proceedings/html/2006/Tennison01/EML2006Tennison01.html "Extreme 2006: Datatypes for XML: the Datatyping Library Language (DTLL)"
[4]: http://recycledknowledge.blogspot.com/ "John Cowan's Blog: Recycled Knowledge"
[5]: http://saxonica.blogharbor.com/ "Michael Kay's Blog: Saxon diaries"
[6]: http://www.exslt.org/ "EXSLT: Extensions in XSLT"
[7]: http://www.relaxng.org/ "RELAX NG"

<!--break-->

Since I'm principally responsible for the [Datatype Library Language (DTLL)][3] it'll come as no surprise that I think that XSDL is currently deficient in not providing mechanisms for creating new primitive types (such as colours) or different lexical representations for the primitive types it has (such as UK-style dates). So yes, I do think XSDL would be a better schema language if it supported "extension primitives". 

In XSLT and XPath, providing extensibility hooks has proved very effective. It's enabled implementers to innovate (and those innovations fed back into the design of XSLT 2.0 and XPath 2.0). It's provided users with functionality (such as `xxx:node-set()`) that they would otherwise not have had for years, and therefore made the lives of thousands of users much easier.

On the other hand, it's impossible to say how XSLT and XPath would have developed if those extensibility hooks hadn't been there. Would implementers have extended the language anyway, leading to fragmentation? Would the WG have felt more pressure to get later versions of XSLT out the door if the only way the language could have been improved was through centralised changes?

I think the big thing that helped XSLT's extensibility actually work was [EXSLT][6] (but then, I would say that, wouldn't I?). The majority of XSLT processors implement EXSLT extensions, and even those processors that don't implement all (or any) of EXSLT have other extensibility hooks (such as `<msxsl:script>` or `<xsl:function>`) and there are third-party implementations of EXSLT's functions available so it's possible to write interoperable stylesheets while still using those functions.

(EXSLT is by no means perfect: if we were doing it over again, we'd build in much better methods for receiving user contributions of various kinds. But I think the general principle is sound.)

If XSDL were to allow extension primitives, you'd hope for something similar to happen:

  * a repository for common extension primitives
  * implementations that respond to user demand for extensions in the repository
  * development of higher-level languages for defining extension primitives
  * implementations that provide hooks (in whatever way) for defining extension primitives

You can't predict what implementers will do, but it seems likely that they'd provide hooks for users to create their own extension primitives (albeit most likely using Java or .NET or whatever rather than a higher-level language such as DTLL). And once they do that, it's possible for the community to provide third-party implementations for extension primitives, thus retaining interoperability.

So I think it could work, if implementers do the right thing and the user community gets involved.

(Just in case you get the wrong impression: I still think [RELAX NG][7] is a vastly superior schema language to XSDL. If you need extension datatypes, you can have them in RELAX NG right now. Unfortunately, however, in the real world, you don't always get to make the right technical choice.)
