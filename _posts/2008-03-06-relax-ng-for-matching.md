---
layout: drupal-post
excerpt_separator: "<!--break-->"
title: RELAX NG for matching
created: 1204815543
tags:
- pipelines
- schema
---
I'm still thinking about doing [automatic markup with XML pipelines][1], and the kind of components that you might need in such a pipeline. These are the useful ones (list inspired by the components offered by [GATE][2]):

  * a **tokeniser** that uses regular expressions to add markup to plain text
  * a **gazetteer** that uses a lookup to add markup to plain text
  * an **annotater** that adds attributes to existing elements based on their context/content
  * a **grouper** that adds markup around sequences of existing markup
  * a **stripper** that removes markup
  * a general purpose **transformer** that uses XSLT to do just about everything else

[1]: http://www.jenitennison.com/blog/node/76 "Jeni's Musings: Automatic markup and XML pipelines"
[2]: http://www.gate.ac.uk/ "General Architecture for Text Engineering"
[3]: http://www.gate.ac.uk/sale/tao/index.html#x1-1520007 "GATE: JAPE: Regular expressios over annotations"

<!--break-->

The "grouper" is the most interesting and difficult of these. It needs to act like a tokeniser, except use regular expressions over markup rather than over text. For example, say I had:

    <number>06</number><punc>/</punc><number>03</number><punc>/</punc><number>08</number>

I want to be able to create a rule that says "any sequence that looks like a number element that contains a two-digit number between 1 and 31, followed by a punc element that contains a slash, followed by another two-digit number between 1 and 12, followed by a punc element that contains a slash, followed by another two-digit number should be wrapped in a date element".

Now this is something that XPath is really bad at. Try writing an expression that selects, from a sequence of elements that may contain other `<number>` and `<punc>` elements as well as other elements, only those sequences of elements that match the pattern I just described. It's something like:

    number[. >= 1 and . <= 31 and string-length(.) = 2]
          [following-sibling::*[1]/self::punc = '/']
          [following-sibling::*[2]/self::number[. >= 1 and . <= 12 and string-length(.) = 2]]
          [following-sibling::*[3]/self::punc = '/']
          [following-sibling::*[4]/self::number[string-length(.) = 2]]
      /(self::number, following-sibling::*[position() <= 4])

which is fiddly and messy and only works in this particular example because I know precisely how many elements there are supposed to be in the group.

In fact, it's even difficult to do this kind of grouping using XSLT, even with `<xsl:for-each-group>` because the grouping is designed around elements either returning the same value or starting or ending with a particular kind of element, rather than grouping together a sequence that has a particular internal structure.

The language that *is* designed to describe sequences of elements is RELAX NG. Obviously RELAX NG is really useful as a schema language, but it's really all to do with defining regular expressions over XML structures. We can use RELAX NG to describe the pattern of elements we want to match:

    <group>
      <element name="number">
        <data type="integer">
          <param name="minInclusive">1</param>
          <param name="maxInclusive">31</param>
          <param name="pattern">[0-9]{2}</param>
        </data>
      </element>
      <element name="punc">
        <value>/</value>
      </element>
      <element name="number">
        <data type="integer">
          <param name="minInclusive">1</param>
          <param name="maxInclusive">12</param>
          <param name="pattern">[0-9]{2}</param>
        </data>
      </element>
      <element name="punc">
        <value>/</value>
      </element>
      <element name="number">
        <data type="integer">
          <param name="pattern">[0-9]{2}</param>
        </data>
      </element>
    </group>

or, in compact syntax:

    element number { 
      xs:integer { minInclusive = "1" maxInclusive = "31" pattern = "[0-9]{2}" }
    },
    element punc { "/" },
    element number { 
      xs:integer { minInclusive = "1" maxInclusive = "12" pattern = "[0-9]{2}" }
    },
    element punc { "/" },
    element number { 
      xs:integer { pattern = "[0-9]{2}" }
    }

As a language, RELAX NG is really good at this. You could even imagine adding attributes to name subexpressions which you could then do things with (in the same way as you can get the substring matching a subexpression when you use a regular expression over text).

So I think a "grouper" component should use RELAX NG to identify sequences to be marked up. But I have no idea if there are RELAX NG libraries out there that can be used in this way: to identify and extract matching sequences rather than to validate entire documents.
