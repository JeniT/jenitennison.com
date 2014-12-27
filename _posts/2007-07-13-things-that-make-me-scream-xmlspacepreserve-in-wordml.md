---
layout: drupal-post
title: ! 'Things that make me scream: xml:space="preserve" in WordML'
created: 1184352960
tags:
- markup
---
I intend to do a series of "things that make me scream" posts. Many of them will be about WordML (as in the markup language used by Word 2003) because that's what I'm struggling with at the moment and because it's so goddam awful. I don't want to get into the whole [ODF][6] vs [OOXML][1] open standard-or-not debate. My problems with WordML (and OOXML) are mainly about aesthetics rather than process: I look at it and... well, it makes me want to scream. Examining what it is about the language (or implementation thereof) that prompts this visceral reaction might help in designing better languages.

So: did you know that Word 2003 puts a `xml:space="preserve"` attribute on the `<w:wordDocument>` document element of the XML that it produces and doesn't indent its output? This is a nightmare if you ever have to actually look at the documents: auto-indentation programs (like the one in [&lt;oXygen/&gt;][2]) quite rightly won't add whitespace to elements that are in the scope of an `xml:space="preserve"` attribute, which means you can't use these programs to indent XML automatically.

[1]: http://en.wikipedia.org/wiki/Office_Open_XML "Office Open XML"
[2]: http://www.oxygenxml.com/ "<oXygen/> XML Editor"
[6]: http://en.wikipedia.org/wiki/OpenDocument "Open Document Format"

<!--break-->

In fact, &lt;oXygen/&gt; has syntax-highlighting-related problems when you open a document that has very long lines (like over 5000 characters; it doesn't actually crash, but it eats all your CPU until you kill it, which I suppose is a kind of assisted suicide). This is usually mitigated by the fact &lt;oXygen/&gt; now prompts you to auto-indent when it detects such a document. But that doesn't help with these WordML documents, because the auto-indent can't actually reduce the line size. (Bear in mind that even the shortest WordML document -- one with no actual content -- created in Word 2003 is 4kb in size; 3926 characters in one line.)

So my regular experience debugging these WordML stylesheets I'm working on is to edit something in Word, save as XML, open in WordPad, remove `xml:space="preserve"`, hit Save, remember that I can't save it in WordPad while it's still open in Word, close it in Word, go back to WordPad, hit Save, open in &lt;oXygen/&gt;, auto-indent, look around and debug the code. And repeat. Argh.

I could write an XSLT output filter that removed the `xml:space="preserve"`, but really I shouldn't have to. What on earth is `xml:space="preserve"` doing on the document element? It's meant to be used on elements that really do contain significant whitespace that really must be preserved. The examples in the [XML 1.1 Recommendation][3] are of `<poem>` and `<pre>` where you'd want to see the line breaks, tabs and spaces when you viewed the content of the element in some kind of default viewer. In other words, the examples are elements whose content should be displayed with `white-space: pre` in CSS, or `white-space-treatment="preserve"` in XSL-FO. That just isn't the case for the `<w:wordDocument>` element. Far from it.

In fact, in Word 2003, whitespace is only significant in terms of the appearance of the document in a handful of elements, the most common being `<w:t>`, which holds text inside a run. I also observe the following:

  * line breaks are done with `<w:br>`, carriage returns with `<w:cr>` and tabs with `<w:tab>`
  * any non-space whitespace within a `<w:t>` always gets converted to a space, however `xml:space` is set
  * any runs of spaces between words within a `<w:t>` get preserved, however `xml:space` is set
  * runs of leading and trailing spaces get stripped if `xml:space` isn't set to `preserve`, and are preserved otherwise

I don't know if the same thing happens in Word 2007, because I haven't got a copy, but I note that in the [OOXML spec][4], all the examples have `xml:space="preserve"` on all `<w:t>` elements, and it says (in section 2.3.1, page 34):

> It is also notable that since leading and trailing whitespace is not normally significant in XML; some runs require a designating [sic] specifying that their whitespace is significant via the xml:space element [sic].

This seems to be a... umm... misinterpretation of the XML spec. Whitespace is always reported to XML applications (by any *conformant* parser, anyway), and the application gets to decide what to do with it. The default whitespace handling is that the application should use its default whitespace handling **whatever that means**. So I reckon that OOXML could just specify that whitespace is generally ignored except for in `<w:t>` (and a few other) elements which are normalized strings in the XML Schema sense (`xs:normalizedString`s have all whitespace characters replaced by a space). To be honest, I really don't see the point of `xml:space` here at all.

[3]: http://www.w3.org/TR/xml11/#sec-white-space "W3C: XML 1.1 Recommendation"
[4]: http://www.ecma-international.org/publications/files/ECMA-ST/Office%20Open%20XML%20Part%204%20(PDF).zip "Zipped Office Open XML Part 4: Markup Language Reference PDF"

Whitespace handling is one of the hardest things to get right in any markup language or application, and there's no single right way to do it, but WordML's nowhere near right in my opinion. I'm gonna have to put my thoughts about how it *should* be done in a separate post, or just let the markup design experts out there have their say in comments on this one.
