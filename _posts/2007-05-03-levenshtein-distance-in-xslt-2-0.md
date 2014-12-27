---
layout: drupal-post
title: Levenshtein distance in XSLT 2.0
created: 1178226737
tags:
- xslt
---
[UPDATE: Added a link to the full stylesheet, and edited the code so it doesn't overlap the right-hand column.]

[Levenshtein distance][1] is a measure of how many edits it takes to get from one string to another. In the basic algorithm, each addition, deletion and substitution counts as a single edit. So, for example, the distance between `"XSLT 1.0"` and `"XSLT 2.0"` is `1`: the only difference is the substitution of `2` for `1`, whereas the distance between `"XSLT"` and `"XQuery"` is `5`: three substitutions and two additions.

One of the interesting features of Levenshtein distance is that there's a fairly straight-forward [dynamic programming][2] algorithm that can be used to calculate it. I thought it might be interesting to see what an XSLT 2.0 implementation might look like.

[1]: http://en.wikipedia.org/wiki/Levenshtein_distance "Wikipedia: Levenshtein distance"
[2]: http://en.wikipedia.org/wiki/Dynamic_programming "Wikipedia: Dynamic programming"

<!--break-->

In its naive form, the Levenshtein distance is calculated by saying:

 1. The distance between an empty string A and another string B is the number of characters in B (eg distance between `''` and `'foo'` is `3`)
 2. Otherwise, take the minimum of:
     *  one plus the distance between string A and B except for its last character
     *  one plus the distance between A except for its last character and string B
     *  the distance between A except for its last character and B except for its last character, plus one if the last characters of the two strings aren't the same

In the normal case, then, for each distance you calculate, you have to calculate three other distances and take a minimum. A naive XSLT implementation would be:

    <xsl:function name="my:LevenshteinDistanceA" 
      as="xs:integer">
      <xsl:param name="string1" as="xs:string" />
      <xsl:param name="string2" as="xs:string" />
      <xsl:sequence 
        select="my:LevenshteinDistanceA(
                  string-to-codepoints($string1),
      	         string-to-codepoints($string2),
      	         string-length($string1),
      	         string-length($string2))" />
    </xsl:function>

    <xsl:function name="my:LevenshteinDistanceA" 
      as="xs:integer">
      <xsl:param name="chars1" as="xs:integer+" />
      <xsl:param name="chars2" as="xs:integer+" />
      <xsl:param name="i1" as="xs:integer" />
      <xsl:param name="i2" as="xs:integer" />
      <xsl:choose>
        <xsl:when test="$i1 = 0">
          <xsl:sequence select="$i2" />
        </xsl:when>
        <xsl:when test="$i2 = 0">
          <xsl:sequence select="$i1" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="char1" as="xs:integer" 
            select="$chars1[$i1]" />
          <xsl:variable name="char2" as="xs:integer"
            select="$chars2[$i2]" />
          <xsl:variable name="deletion" as="xs:integer"
            select="my:LevenshteinDistanceA($chars1, $chars2, 
                                            $i1 - 1, $i2) + 
                    1" />
          <xsl:variable name="insertion" as="xs:integer"
            select="my:LevenshteinDistanceA($chars1, $chars2, 
                                            $i1, $i2 - 1) + 
                    1" />
          <xsl:variable name="substitution" as="xs:integer"
            select="my:LevenshteinDistanceA($chars1, $chars2, 
                                            $i1 - 1, $i2 - 1) +
                    (if ($char1 eq $char2) then 0 else 1)" />
          <xsl:sequence select="min(($deletion, $insertion, 
                                     $substitution))" />
        </xsl:otherwise>
      </xsl:choose>	
    </xsl:function>

This is horrendously slow for even moderate-length strings. In Saxon 8.9B, on my laptop, it will compare two five-character strings in 63ms on average; for ten-character strings it takes 
26 seconds!

If you look at the [Wikipedia page on Levenshtein distance][1], you'll see an algorithm that effectively does memoisation to address the performance problem. Memoisation is the technique of recording the result of a function for a given set of arguments, and then using that stored result rather than recalculating it each time. For the Levenshtein distance algorithm, this is done by building a matrix of the distances between all possible leading substrings of the strings you're comparing. So to compare `"foo"` and `"bar"`, you effectively compare `""` and `""`, `"b"`, `"ba"` and `"bar"`; `"f"` and `""`, `"b"`, `"ba"` and `"bar"`; `"fo"` and `""`, `"b"`, `"ba"` and `"bar"`; and `"foo"` and `""`, `"b"`, and `"ba"`, recording the results as you go.

Here's the dynamic programming version of the function in XSLT 2.0:

    <xsl:function name="my:LevenshteinDistanceB" 
      as="xs:integer">
      <xsl:param name="string1" as="xs:string" />
      <xsl:param name="string2" as="xs:string" />
      <xsl:sequence 
        select="my:LevenshteinDistanceB(
                  string-to-codepoints($string1),
      	         string-to-codepoints($string2),
      	         1, 1,
      	         for $p in (0 to string-length($string1)) 
                    return $p,
      	         1)" />
    </xsl:function>

    <xsl:function name="my:LevenshteinDistanceB" 
      as="xs:integer">
      <xsl:param name="chars1" as="xs:integer+" />
      <xsl:param name="chars2" as="xs:integer+" />
      <xsl:param name="i1" as="xs:integer" />
      <xsl:param name="i2" as="xs:integer" />
      <xsl:param name="lastRow" as="xs:integer+" />
      <xsl:param name="thisRow" as="xs:integer+" />
      <xsl:choose>
        <xsl:when test="$i1 > count($chars1)">
          <xsl:choose>
            <xsl:when test="$i2 = count($chars2)">
              <xsl:sequence select="$thisRow[last()]" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:sequence 
                select="my:LevenshteinDistanceB(
                          $chars1, $chars2, 
                          1, $i2 + 1, 
                          $thisRow, ($i2 + 1))" />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="char1" as="xs:integer" 
            select="$chars1[$i1]" />
          <xsl:variable name="char2" as="xs:integer" 
            select="$chars2[$i2]" />
          <xsl:variable name="deletion" as="xs:integer"
            select="$lastRow[$i1 + 1] + 1" />
          <xsl:variable name="insertion" as="xs:integer"
            select="$thisRow[last()] + 1" />
          <xsl:variable name="substitution" as="xs:integer"
            select="$lastRow[$i1] +
                    (if ($char1 eq $char2) then 0 else 1)" />
          <xsl:variable name="cost" 
            select="min(($deletion, $insertion, 
                         $substitution))" />
          <xsl:sequence 
            select="my:LevenshteinDistanceB(
                      $chars1, $chars2, 
                      $i1 + 1, $i2, 
                      $lastRow, ($thisRow, $cost))" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:function>

This performs *much* better. Here's a little table showing the results:

<table>
  <tr><th># characters</th><th>time</th></tr>
  <tr><td>5</td><td>33ms</td></tr>
  <tr><td>10</td><td>50ms</td></tr>
  <tr><td>15</td><td>67ms</td></tr>
  <tr><td>20</td><td>77ms</td></tr>
</table>

Why do I end there, when the timings are by no means unreasonable? Well, the bad news is that with anything over 20 characters, Saxon bails with a "Too many nested function calls. May be due to infinite recursion." error. Which isn't unreasonable I guess, given that, with 20 characters, you're calling the same function 400 times in a row, but is kinda annoying given the recursion is not actually infinite.

I know David C.'s done an implementation as well, which I hope he'll post in a comment, and I'll be interested to see whether that (or any other implementation) performs any better (both in terms of speed and in terms of not running out of stack). When we've had a look at them, I'll try to put together some suitably gnomic comments on the design of recursive functions and templates in general...

You can [download the full stylesheet][3] if you want.

[3]: http://www.jenitennison.com/blog/files/LevenshteinDistance.xsl "LevenshteinDistance.xsl"
