---
layout: drupal-post
title: Working With Fragmented Overlapping Markup
created: 1230495356
tags:
- xslt
- overlapping markup
- xml
---
In my [last post][XMLoverlap] I talked about different techniques for representing overlap within XML. One technique is fragmentation. In the work that I've been doing, I've been using milestone-based formats similar to [ECLIX][ECLIX], but my eyes were opened at the [GODDAG workshop][workshop]: fragmentation would make overlap so much easier to process in XSLT, especially when dealing with localised overlap such as revision or comment markup.

[XMLoverlap]: http://www.jenitennison.com/blog/node/97 "Jeni's Musings: Representing Overlap in XML"
[workshop]: http://ilps.science.uva.nl/PoliticalMashup/2008/11/workshop-on-multi-dimensional-markup/ "Workshop on Multi-Dimensional Markup"
[ECLIX]: http://www.lmnl.org/wiki/index.php/ECLIX "LMNL Wiki: Extended Canonical LMNL in XML"

But how could fragmentation be used with full-on overlap? I had a little play and came up with [some XSLT to demonstrate][XSLT].

[XSLT]: http://www.jenitennison.com/blog/files/fragmentation-utils.xsl "fragmentation-utils.xsl"

<!--break-->

## Fragmentation Example ##

First, an example of how to represent overlap using fragments. Using fragments for overlap comes straight out of the support for [aggregation within TEI][TEI] where they're used to not only represent overlapping structures but to construct completely new "virtual" elements that are not necessarily contiguous (and may even contain fragments in different orders from how they appear in the text). In TEI, they usually use the `next` and `prev` attributes to point from one fragment to another in order to reconstruct the element.

[TEI]: http://www.tei-c.org/release/doc/tei-p5-doc/en/html/SA.html#SAAG "TEI: Linking, Segmentation, and Alignment: Aggregation"

In the example here, I've done something slightly different, namely to use an ID in the `http://www.jenitennison.com/xslt/fragmentation` namespace to link the elements: all elements with the same ID are actually the same element. Here's what it looks like.

    <book xmlns:f="http://www.jenitennison.com/xslt/fragmentation">
    	<page f:id="page199" n="199">
    		...
    	</page>
    	<poem>
    		<page f:id="page199" n="199">
    			<title>
    				<pl>Recueillement</pl>
    			</title>
    			<stanza>
    				<sl><s><pl>Sois sage, ô ma douleur, et tiens-toi plus </pl>
    						                                  <pl>tranquille.</pl></s></sl>
    				<s>
    					<sl><pl>Tu réclamais le Soir; il descend; le voici:</pl></sl>
    					<sl><pl>Une atmosphère obscure enveloppe la ville,</pl></sl>
    					<sl><pl>Aux uns portant la paix, aux autres le souci.</pl></sl>
    				</s>
    			</stanza>
    			<stanza>
    			  <s f:id="s3">
    				  <sl><pl>Pendant que des mortels la multitude vile,</pl></sl>
    				  <sl><pl>Sous le fouet du Plaisir, ce bourreau sans merci,</pl></sl>
    				  <sl><pl>Va cueillir des remords dans la fête servile,</pl></sl>
    				  <sl><pl>Ma douleur, donne moi la main; viens par ici,</pl></sl>
            </s>
    			</stanza>
    			<stanza>
    				<sl><pl><s f:id="s3">Loin d'eux. </s><s f:id="s4">Vois se pencher les défuntes </s></pl>
    					                                                    <pl><s f:id="s4">Années, </s></pl></sl>
    				<s f:id="s4">
    				  <sl><pl>Sur les balcons du ciel, en robes surannées; </pl></sl>
    				  <sl><pl>Surgir du fond des eaux le Regret souriant; </pl></sl>
            </s>
    			</stanza>
    		</page>
    		<page f:id="page200">
    			<stanza>
    			  <s f:id="s4">
    				  <sl><pl>Le Soleil moribund s'endormir sous une arche, </pl></sl>
      				<sl><pl>Et, comme un long linceul traînant à l'Orient, </pl></sl>
      				<sl><pl>Entends, ma chère, entends la douce Nuit qui </pl>
    						                                       <pl>marche.</pl></sl>
    				</s>
    			</stanza>
    		</page>
    	</poem>
    </book>

You can see that I've played pretty fast and loose here with the markup language. The `<s>` elements can be children of `<stanza>` or `<sl>` or even `<pl>`, purely depending on what happens to most neatly contain them. This makes the XML inconsistent, but less verbose than it would otherwise be. Elements that are actually fragments have `f:id` attributes, and multiple elements may have the same `f:id`; this is precisely what's used to work out that they're the same element.

## Desired Rendering ##

So what would we like to do when processing this? Say we wanted to create an HTML rendition of the poem, looking something like:

<blockquote style="width: 30em; ">
  <hr />
  <p style="text-align: right; ">page 199</p>
  <h3>Recueillement</h3>
  <ol start="1">
     <li>
        <p>Sois sage, ô ma douleur, et tiens-toi plus </p>
        <p style="text-align: right; ">tranquille.</p>
     </li>
     <li>
        <p>Tu réclamais le Soir; il descend; le voici:</p>
     </li>
     <li>
        <p>Une atmosphère obscure enveloppe la ville,</p>
     </li>
     <li>
        <p>Aux uns portant la paix, aux autres le souci.</p>
     </li>
  </ol>
  <ol start="5">
     <li>
        <p>Pendant que des mortels la multitude vile,</p>
     </li>
     <li>
        <p>Sous le fouet du Plaisir, ce bourreau sans merci,</p>
     </li>
     <li>
        <p>Va cueillir des remords dans la fête servile,</p>
     </li>
     <li>
        <p>Ma douleur, donne moi la main; viens par ici,</p>
     </li>
  </ol>
  <ol start="9">
     <li style="background-color: yellow; ">
        <p>Loin d'eux. Vois se pencher les défuntes </p>
        <p style="text-align: right; ">Années, </p>
     </li>
     <li>
        <p>Sur les balcons du ciel, en robes surannées; </p>
     </li>
     <li>
        <p>Surgir du fond des eaux le Regret souriant; </p>
     </li>
  </ol>
  <hr />
  <p style="text-align: right; ">page 200</p>
  <ol start="12">
     <li>
        <p>Le Soleil moribund s'endormir sous une arche, </p>
     </li>
     <li>
        <p>Et, comme un long linceul traînant à l'Orient, </p>
     </li>
     <li>
        <p>Entends, ma chère, entends la douce Nuit qui </p>
        <p style="text-align: right; ">marche.</p>
     </li>
  </ol>
</blockquote>

The logic behind this rendition is:

  1. process the pages; for each one, create a horizontal rule followed by a paragraph giving the page number
  2. process the parts of the poem within each page; give the title if it has one in this fragment, followed by the stanzas
  3. create an ordered list for each stanza, starting at the number for the stanza line within the (whole) poem, and process the stanza lines
  4. create a list item for each stanza line; if the line contains parts of two sentences and the first of these sentences doesn't begin in this line, highlight it as this indicates an interesting overlap between prosodic and syntactic structures
  5. process the page lines within each stanza line; if there's more than one, align the second to the right

It wouldn't be easy to express that logic against the fragmented XML above, for two reasons.

First, the fragmented markup above is inconsistent: you can't tell what kinds of children a particular element will have and which elements will be fragmented. You could fix this in the markup by deciding, for example, that the prosodic hierarchy of book/poem/stanza/sl would be primary and all other elements fragmented as necessary; you could further decide which of the hierarchies would be secondary within this: whether an `<sl>` element would hold `<s>` or `<page>` elements as children.

Second, though, the different logical steps require the markup to be structured in different ways: 1 requires a physical hierarchy where the markup is primarily divided into pages; 2 and 3 require a prosodic hierarchy within the page, dividing the poem into stanzas and stanza lines; 4 requires a syntactic hierarchy, where the stanza lines are split into sentences; 5 requires switching back to the physical hierarchy to see the page lines within the stanza line.

What you can do (and what I've done) is to write a function to help with this kind of processing by switching between the different hierarchies as and when necessary.

## Labelling Elements ##

To prepare for switching, you must annotate the elements in the document with an indication of the trees that they belong to. The trees can be called anything you like; for the example above, I could use the labels "physical" (book, page, page line), "syntactic" (book, poem, sentence) and "prosodic" (book, poem, stanza, stanza line). The idea of labelling elements based on a tree that they belong to comes from the [multi-coloured trees][colour] technique, but I think it's more useful to use meaningful labels if you can.

[colour]: http://www.research.att.com/~divesh/papers/jlssw2004-mct.pdf "Colorful XML: One Hierarchy Isn't Enough"

You could imagine a built-in extension element that allowed you to describe the trees that different elements belonged to, and the annotation happening at the level of the XPath Data Model as its created.  But to make things easier I'm using a `f:trees` attribute on each element. Adding the attribute can be done in XSLT with code like:

    <xsl:template match="*" mode="annotate">
      <xsl:copy>
        <xsl:attribute name="f:trees">
          <xsl:apply-templates select="." mode="trees" />
        </xsl:attribute>
        <xsl:copy-of select="@*" />
        <xsl:apply-templates mode="annotate" />
      </xsl:copy>
    </xsl:template>
    
    <xsl:template match="book" mode="trees">prosodic syntactic physical</xsl:template>
    <xsl:template match="poem" mode="trees">prosodic syntactic</xsl:template>
    <xsl:template match="title | stanza | sl" mode="trees">prosodic</xsl:template>
    <xsl:template match="s" mode="trees">syntactic</xsl:template>
    <xsl:template match="page | pl" mode="trees">physical</xsl:template>

Once elements are labelled with the trees they belong to, it's possible to work out dominance hierarchies. An element A is a descendant of an element B if the elements share a tree and A starts and ends within B. If A is within B but they don't appear in the same tree, then the containment is happenstance and does not imply dominance.

> *Note: Trees should be defined so that all the elements within a given tree fit within each other without fragmenting. I haven't considered how self-overlap should be handled here; the elements need to be part of the same tree, but they can still overlap and therefore be fragmented even when that particular tree is primary. In my experience, self-overlap usually occurs in situations like comments or revision markup, in which the self-overlapping markup is never primary anyway, so I'm not sure how serious this issue is.*

## Swapping Hierarchies ##

Once the elements are annotated, it's possible to swap between hierarchies. The function I've written -- `f:swap()` -- takes two or three arguments. The first is an element, and the `f:swap()` function returns this same element (actually a copy) but with its children, and possibly its parents, rearranged based on the trees listed in the second argument. The third argument defaults to the element specified as the first argument and provides a starting point from which the rearrangement takes place; the two most useful values for this argument are the element itself (which means that its children are restructured) and the root of the tree (which means that the entire document is rearranged).

Some examples will help make this clearer. Starting with the poem above, to get the rendering I want, I need to swap to a "physical" view and process the pages:

    <xsl:apply-templates select="$annotated/book/f:swap(., 'physical')/page" />

The `f:swap()` call here returns the `<book>` element but with its descendants rearranged so that the physical hierarchy is primary. The new version of the `<book>` element will have `<page>` children, which will themselves have `<pl>` children. The `<pl>` elements will contain fragments of `<poem>`, `<s>`, `<stanza>` and `<sl>` elements, nested purely based on their happenstance containment within a particular `<pl>`.

Here's the code for processing the `<page>` elements:

    <xsl:template match="page">
      <hr />
      <p style="text-align: right; ">page <xsl:value-of select="@n" /></p>
      <xsl:apply-templates select="f:swap(., ('prosodic', 'syntactic'))/poem" />
    </xsl:template>

So each `<page>` generates a horizontal rule, a paragraph containing the page number and then processes... here the switch is from the physical hierarchy to a prosodic/syntactic hierarchy. The list of two items as the second argument of `f:swap()` means that the primary hierarchy is prosodic (poems, containing stanzas, containing stanza lines), but once you reach the bottom of the prosodic hierarchy (the stanza lines) you switch to a syntactic hierarchy (sentences) rather than a physical hierarchy (page lines).
  
The fact that the `f:swap()` call above only has two arguments means that the rearrangement starts from the `<page>` element that's being processed. The ancestry of the `<page>` element itself stays the same, and only its content is rearranged according to the views specified in the second argument. So in this case the `<poem>` elements that a given `<page>` contains will be fragments.
  
Processing the poems can continue in the normal way:

    <xsl:template match="poem">
      <xsl:apply-templates select="title" />
      <xsl:apply-templates select="stanza" />
    </xsl:template>
    
    <xsl:template match="title">
      <h3><xsl:value-of select="." /></h3>
    </xsl:template>

The next difficulty appears when I want to start the numbering for a particular stanza based on the number of the first line within the stanza. I'm doing this by setting the `start` attribute like this:

    <xsl:template match="stanza">
      <ol>
        <xsl:attribute name="start">
          <xsl:number select="f:swap(., 'prosodic', /)/sl[1]" 
            count="sl" from="poem" level="any" />
        </xsl:attribute>
        <xsl:apply-templates select="sl" />
      </ol>
    </xsl:template>

This illustrates the three-argument version of the `f:swap()` function. To number the stanza line, I need to know the number of that stanza line within the poem that contains it. That would be easy to do with `<xsl:number>` (or in other ways), but for the fact that the `<poem>` element the `<stanza>` element appears in is currently fragmented between two `<page>` elements. To work out the number of the line, I really want an XML document in which the physical hierarchy is completely ignored, and the elements are arranged `book/poem/stanza/sl`.
  
The three-argument version of `f:swap()` allows me to swap to a prosodic hierarchy, starting from the very root of the document. It returns the element given as the first argument as it appears within the new hierarchy. Unlike the two-argument version, which only affects the descendants of the first argument, the three-argument version may also affect its ancestors, and even merge the element if it's originally fragmented or split it if it doesn't appear in the primary hierarchy. In this example, the returned `<stanza>` element's parent `<poem>` is a child of the `<book>` element rather than being a fragmented child of the `<page>` element.

The rearrangement for the purposes of computing the start number for the list doesn't affect the tree that's being processed; the template for the `<stanza>` elements goes on to process the `<sl>` elements it contains, which use this template:

    <xsl:template match="sl">
      <li>
        <xsl:if test="count(s) > 1 and not(f:first(s[1]))">
          <xsl:attribute name="style">background-color: yellow; </xsl:attribute>
        </xsl:if>
        <xsl:apply-templates select="f:swap(., 'physical')/pl" />
      </li>
    </xsl:template>

Recall that the hierarchy currently being processed is a prosodic/syntactic hierarchy. The `<sl>` elements contain `<s>` elements, and it's therefore possible to check whether the `<sl>` element being processed contains more than one `<s>`. The `f:first()` function checks whether a given fragment is the first fragment of that element, so the test in the `<xsl:if>` in this template checks whether the `<sl>` contains more than one `<s>` and the first `<s>` is not the first fragment of the sentence it represents.
  
To get the rendering I want, I need to generate an HTML paragraph for each page line within the stanza line. Currently the `<sl>` elements contain `<s>` elements, so to get the page lines I need to switch once more to the physical hierarchy and process the `<pl>` elements that are children of this `<sl>`. That processing is done by the template:

    <xsl:template match="pl">
      <p>
        <xsl:if test="preceding-sibling::pl">
          <xsl:attribute name="style">text-align: right; </xsl:attribute>
        </xsl:if>
        <xsl:value-of select="." />
      </p>
    </xsl:template>

and we're done.

## Final Thoughts ##

The one thing that concerns me about the approach I'm taking is the fact that because XSLT can't actually amend an existing tree, the `f:swap()` function essentially makes a copy of the entire tree every time you use it, and I don't know how well that will scale (both in terms of memory and in terms of work copying elements) when you get to documents that are larger than this toy example. Maybe processors are clever enough to discard trees they no longer need so it won't be an issue; I just don't know.

Other than that, I think this approach is promising because it enables users to mostly use familiar tree-processing approaches rather than having to learn new paradigms for transforming overlapping markup or introducing a raft of new axes.

