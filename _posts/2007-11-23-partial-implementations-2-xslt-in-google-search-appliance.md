---
layout: drupal-post
title: ! 'Partial implementations #2: XSLT in Google Search Appliance'
created: 1195856539
tags:
- xslt
- atom
- google
---
A [Google Search Appliance][1] (GSA) is a box that you plug into your network which crawls and indexes your data, and serves up the results of searches. Search results come in an XML format, and there's a built in XSLT engine which means you can convert that XML into as many different views as you like. So you can have HTML-based search results, summaries, feeds, and so on.

[1]: http://www.google.com/enterprise/gsa/ "Google Search Appliance"

My task recently was to debug some XSLT that transformed the GSA XML into an Atom feed. Easy enough, right? The GSA [XML format][2] is pretty hideous -- most of the elements max out at three capital letters in length (whatever happened to human-readability) -- but logical enough, and the mapping is hardly complex.

[2]: http://code.google.com/apis/searchappliance/documentation/46/xml_reference.html#results_xml "Google Search Appliance Documentation: XML Results Reference"

But all was not as it seemed. The GSA's XSLT implementation is... how can I put this politely?... "non-standard". This post describes some of the problems and workarounds.

<!--break-->

To get the GSA to use your own XSLT, you have to go through its web interface. Basically there's a form with a text field in which you can type your XSLT. Or you can upload a file that you develop offline. Naturally you're going to do the latter because it means you can use your favourite editor with helpful things like syntax highlighting and validation-as-you-type, but of course that means switching between web browser windows and your IDE as you develop.

So I upload the transformation, point the browser at a relevant search page, and... oh...

When the GSA doesn't like the XSLT that you use, you get a really helpful error message. It says:

> Internal server error.

So you know that there's been an error. With the server. Internally.

Back to basics, I thought. Let's find out what processor the server's using. Then we can develop on that processor and be pretty sure the resulting XSLT will work. So I load up the default XSLT (which is used to create an HTML result) and add the line

    <xsl:value-of select="system-property('xsl:vendor')" />

Save the XSLT, reload the page, and...

> Internal server error.

Okaaay... so this is an XSLT processor that doesn't support the `xsl:vendor` system property. If it doesn't support that, I'm going to have to tread carefully. So let's start with something really simple:

    <xsl:stylesheet version="1.0"
       xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:template match="/">
      <xsl:copy-of select="." />
    </xsl:template>
    </xsl:stylesheet>

Save the XSLT, reload the page, and...

> Internal server error.

On a whim, I tried

    <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
       version="1.0">

    <xsl:template match="/">
      <xsl:copy-of select="." />
    </xsl:template>
    </xsl:stylesheet>

instead. Save the XSLT, reload the page, and... Success!

Can you spot the difference? Yes, that's right: it's the order of the XSLT namespace declaration and the version attribute. Namespace declaration first, you're OK, version first, you're not.

Okaaay... so this is an XSLT processor that doesn't support the XML Recommendation (which says that attribute order doesn't matter). But heck, why split hairs? At least it's working! Now to create some Atom instead:

    <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
       version="1.0"
       xmlns="http://www.w3.org/2005/Atom">

    <xsl:template match="/">
      <feed />
    </xsl:template>
    </xsl:stylesheet>

Save the XSLT, reload the page, and we're back to

> Internal server error

At least there's some [documentation][3] about this one:

> XSL stylesheets that include other files may not be used with the Google search engine. An XSL stylesheet that contains the following tags generates an error result:

>  * `<xsl:import>`
>  * `<xsl:include>`
>  * `xmlns:`
>  * `document()`

[3]: http://code.google.com/apis/searchappliance/documentation/46/xml_reference.html#results_xslt "Google Search Appliance Documentation: Custom HTML"

Read that again. Yes, the third bullet point. That's right, it's saying that an XSLT that contains a namespace declaration will generate an error result because it "includes other files".

But, but, but, namespace declarations in XSLT stylesheets (or elsewhere for that matter) do not indicate file inclusion. Namespace URIs are *identifiers*, not *locations*. They are strings. They are not resolved. You do not need to be connected to the 'net to use them.

And how am I supposed to serve an Atom feed, since Atom documents use a namespace? Or XHTML for that matter? Fortunately, the GSA only goes so far in banning namespace declarations: you're OK as long as you don't put them on the `<xsl:stylesheet>` element. Moving it to the `<feed>` element as in

    <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
       version="1.0">

    <xsl:template match="/">
      <feed xmlns="http://www.w3.org/2005/Atom" />
    </xsl:template>
    </xsl:stylesheet>

and you're OK. Of course you have to repeat the namespace declaration in every template so you don't end up creating elements in no namespace. Tedious, oh so tedious, but workable.

(I have a vague suspicion that the idea behind banning namespace declarations is something to do with certain XSLT processors using namespace URIs to pull in Java classes. But addressing that problem by banning namespace declarations entirely isn't just throwing the baby out with the bathwater, it's throwing the whole bathroom suite out of the window. And if you then allow namespace declarations further down the stylesheet, you haven't actually solved the problem.)

Amazingly enough, given the inauspicious beginning, everything else I tried actually worked. I suspect that it's some standard XSLT processor underneath with a regex based filter that (among other things) limits what's allowed in the `<xsl:stylesheet>` start tag. They probably disallow `system-property('xsl:vendor')` for security -- knowledge is power, after all.

Anyway, my suggestions to others who might want to create a customised XSLT processor:

 1. Use a custom URL resolver to restrict access to documents.
 2. Restrict external function calls using something like the `ALLOW_EXTERNAL_FUNCTIONS` property in JAXP
 3. Document the restrictions you're placing on the stylesheets.
 4. Produce meaningful error messages that explain the extra restrictions when they're broken.
