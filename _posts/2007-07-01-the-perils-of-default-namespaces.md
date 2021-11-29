---
layout: drupal-post
excerpt_separator: "<!--break-->"
title: The perils of default namespaces
created: 1183318364
tags:
- xslt
- xml
- xlinq
- xquery
---
A lot of people run into problems with namespaces, and most of those arise from using default namespaces (ie not giving namespaces prefixes). The transformation technology you use can have a big effect on how confusing and irritating it gets.

Default namespaces make XML documents easier to read because they allow you to just give the local name of an element rather than using prefixes all over the place. For example, using:

    <house status="For Sale" xmlns="http://www.example.com/ns/house">
      <askingPrice>...</askingPrice>
      <address>...</address>
      <layout>...</layout>
    </house>

<!--break-->

rather than:

    <h:house status="For Sale" xmlns:h="http://www.example.com/ns/house">
      <h:askingPrice>...</h:askingPrice>
      <h:address>...</h:address>
      <h:layout>...</h:layout>
    </h:house>

In some cases, specifically documents that are validated against a DTD or interpreted by non-namespace-aware applications, you might be forced to use the default namespace. The biggest example of this is (X)HTML.

In transformation technologies, such as [XSLT][1], [XQuery][2] and [XLinq in VB.NET][3], you have to deal with at least two documents: the source documents that you are processing and the result documents that you are creating. Often, the source and result documents will use default namespaces, or at any rate you'll want to query and create the documents without using prefixes. Sometimes, the source and result documents all use the same namespace, but it's far more common that they don't.

[1]: http://www.w3.org/Style/XSL/
[2]: http://www.w3.org/XML/Query/
[3]: http://www.xlinq.net/

So transformation technologies have to support at least *two* default namespaces: one for querying and one for construction.

In XPath 1.0, you must specify a prefix for each namespace you want to use. A path like `/house/layout` will only select `<layout>` elements in no namespace. In XSLT 1.0, the default namespace in the stylesheet (as declared by the `xmlns` attribute on `<xsl:stylesheet>`) is then free to be used for the result documents. For example, I might do

    <xsl:stylesheet version="1.0"
      xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
      xmlns:h="http://www.example.com/ns/house"
      exclude-result-prefixes="h"
      xmlns="http://www.w3.org/1999/xhtml">

    <xsl:template match="h:house">
      <div class="house">
        <h1><xsl:apply-templates select="h:askingPrice" /></h1>
        ...
      </div>
    </xsl:template>

    </xsl:stylesheet>

[The best way to deal with multiple result documents in different default namespaces is to simply have different stylesheet documents to handle their generation, all included or imported into your main stylesheet application.]

Users of XSLT 1.0 found it confusing that they couldn't just copy the namespace declarations (including a default namespace declaration) from a sample source document and have the paths just work. So in XPath 2.0, rather than no prefix meaning no namespace, the **default element/type namespace** in the context is used for element names with no prefix. If the default element/type namespace is set to `http://www.example.com/ns/house` then the path `/house/layout` will select all `<layout>` elements in the `http://www.example.com/ns/house` namespace. You can set this default element/type namespace in XSLT 2.0 using the `[xsl:]xpath-default-namespace` attribute, which can go anywhere but will usually be situated on the `<xsl:stylesheet>` element (in which case it appears without the `xsl:` prefix). The default element/type namespace can be scoped to a particular area of your stylesheet in the same way as namespace declarations.

Otherwise, XSLT 2.0 works like XSLT 1.0 in that the default namespace in the stylesheet supplies the default namespace for created elements, so you can do:

    <xsl:stylesheet version="2.0"
      xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
      xmlns="http://www.w3.org/1999/xhtml"
      xpath-default-namespace="http://www.example.com/ns/house">

    <xsl:template match="house">
      <div class="house">
        <h1><xsl:apply-templates select="askingPrice" /></h1>
        ...
      </div>
    </xsl:template>

    </xsl:stylesheet>

By keeping the default query namespace and the default construction namespace separate, you're able to use unprefixed names in both paths and element constructors, even if the default namespaces in the two cases are different.

XQuery and VB.NET, on the other hand, provide a single default namespace that is used for both queries and construction, and they work in slightly different ways.

In XQuery you can declare the default namespace for the query, with

    declare default element namespace "http://www.example.com/ns/house";

which means that you can query the source document with paths like `/house/askingPrice` and create elements in the `http://www.example.com/ns/house` namespace with direct element constructors without prefixes, like

    <house status="For Sale">
      <askingPrice>...</askingPrice>
      <address>...</address>
      <layout>...</layout>
    </house>

If you then want to generate XHTML (or some other result for which you'd prefer to use the default namespace), you can use a default namespace declaration on the XHTML you generate:
 
    <div class="house" xmlns="http://www.w3.org/1999/xhtml">
      <h1>...</h1>
      ...
    </div>

But the default namespace declaration in the element constructor carries through into the embedded expressions, so

      <div class="house" xmlns="http://www.w3.org/1999/xhtml">
        <h1>{ /house/askingPrice }</h1>
        ...
      </div>

won't work. As a result, you end up having to use the query's default namespace declaration to set the default namespace to XHTML (or whatever the default namespace is in the result), and use prefixes in your queries (essentially the same situation as in XSLT 1.0).

In XLinq in VB.NET, there's the same kind of pattern. The `Imports` statement allows you to declare a default namespace that's used in both queries and construction, as in:

    Imports <xmlns="http://www.example.com/ns/house">

and you can use a default namespace declaration on the XHTML you generate to provide the default namespace for the elements in the XML literal:

    houseDiv =
      <div class="house" xmlns="http://www.w3.org/1999/xhtml">
        <h1>...</h1>
        ...
      </div>

But unlike in XQuery, the default XHTML namespace declaration in the `<div>` *doesn't* have an effect on the default namespace used in embedded expressions, which means you can still use unprefixed element names in any paths used within the XML literal, like this:

    houseDiv =
      <div class="house" xmlns="http://www.w3.org/1999/xhtml">
        <h1><%= doc.<house>.<askingPrice> %></h1>
        ...
      </div>

However, if you build up your XHTML gradually, perhaps by using separate variables or methods, then every time you create a snippet of XHTML you have to specify this default namespace. Again, people will end up using the `Imports` statement to set the default namespace to the default result namespace and using prefixes in their paths.

The other factor to consider is that sometimes no prefix really does mean no namespace. If you're querying an XML document that contains elements in no namespace, you have to set the default query namespace to no namespace. In XSLT 1.0, that's always the case anyway; in XSLT 2.0, the `xpath-default-namespace` shouldn't be set (or should be unset for those places that need to query no-namespace elements). In XQuery you can't use the query default namespace declaration and in XLinq in VB.NET you can't use the `Imports` statement. In both these cases, you better hope your result is in no namespace too. If not, the best route (to make it work at all in XQuery, and to avoid repetitive `xmlns` attributes in VB.NET) is to create a no-namespace version of your result first, and have a standard function or method that will add the right default namespace to that result.
