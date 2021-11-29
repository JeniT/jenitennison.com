---
layout: drupal-post
excerpt_separator: "<!--break-->"
title: Levenshtein distance on the diagonal
created: 1178488603
tags:
- xslt
---
The big problem with the [previous Levenshtein distance][1] implementation is that it recurses so much a number of times (roughly) equal to the multiple of the lengths of the two strings you're comparing. If you're using an XSLT processor that doesn't recognise the function as being tail recursive then you can't compare two strings more than about 20 characters in length (400 recursions).

The problem is that the standard dynamic programming [Levenshtein distance algorithm][2] is written for procedural programming languages in which you can do useful things like updating variables. XSLT ain't like that, so we need an alternative algorithm.

[1]: http://www.jenitennison.com/blog/node/11 "Levenshtein distance in XSLT 2.0"
[2]: http://en.wikipedia.org/wiki/Levenshtein_distance "Wikipedia: Levenshtein distance"

<!--break-->

The dynamic programming algorithm for computing Levenshtein distance between two strings creates a matrix like this

<table style="width: auto;">
  <tr><th colspan="2"></th><th>k</th><th>i</th><th>t</th><th>t</th><th>e</th><th>n</th></tr>
  <tr><td></td><td>0</td><td>1</td><td>2</td><td>3</td><td>4</td><td>5</td><td>6</td></tr>
  <tr><th>s</th><td>1</td><td>1</td><td>2</td><td>3</td><td>4</td><td>5</td><td>6</td></tr>
  <tr><th>i</th><td>2</td><td>2</td><td>1</td><td>2</td><td>3</td><td>4</td><td>5</td></tr>
  <tr><th>t</th><td>3</td><td>3</td><td>2</td><td>1</td><td>2</td><td>3</td><td>4</td></tr>
  <tr><th>t</th><td>4</td><td>4</td><td>3</td><td>2</td><td>1</td><td>2</td><td>3</td></tr>
  <tr><th>i</th><td>5</td><td>5</td><td>4</td><td>3</td><td>2</td><td>2</td><td>3</td></tr>
  <tr><th>n</th><td>6</td><td>6</td><td>5</td><td>4</td><td>3</td><td>3</td><td>2</td></tr>
  <tr><th>g</th><td>7</td><td>7</td><td>6</td><td>5</td><td>4</td><td>4</td><td>3</td></tr>
</table>

and gets the final edit distance from the bottom right-most cell (in this case `3`). The top row holds the numbers `0` to *`n`* (where *`n`* is the number of characters in the first string) and the left column holds the numbers `0` to *`m`* (where *`m`* is the number of characters in the second string). The values in the rest of the cells are calculated by looking at the cells above, to the left and diagonally above-and-left.

In the standard algorithm, you create this matrix row-by-row. This is fine in a procedural language where you can do the whole thing in a big loop, updating the matrix as you go. But in XSLT, there's no way of using a `<xsl:for-each>` to create a row because to calculate the value of a given cell, you have to know the value in the previous cell (to the left), and you can't carry values over from one iteration to the next in XSLT.

However, there is a way of doing part of the calculation with iteration: calculate the diagonals. If you look at the matrix

<table style="width: auto;">
  <tr><th colspan="2"></th><th>k</th><th>i</th><th>t</th><th>t</th><th>e</th><th>n</th></tr>
  <tr><td></td><td>0</td><td><em>1</em></td><td><em>2</em></td><td><strong>3</strong></td><td></td><td></td><td></td></tr>
  <tr><th>s</th><td><em>1</em></td><td><em>1</em></td><td><strong>2</strong></td><td></td><td></td><td></td><td></td></tr>
  <tr><th>i</th><td><em>2</em></td><td><strong>2</strong></td><td></td><td></td><td></td><td></td><td></td></tr>
  <tr><th>t</th><td><strong>3</strong></td><td></td><td></td><td></td><td></td><td></td><td></td></tr>
  <tr><th>t</th><td></td><td></td><td></td><td></td><td></td><td></td><td></td></tr>
  <tr><th>i</th><td></td><td></td><td></td><td></td><td></td><td></td><td></td></tr>
  <tr><th>n</th><td></td><td></td><td></td><td></td><td></td><td></td><td></td></tr>
  <tr><th>g</th><td></td><td></td><td></td><td></td><td></td><td></td><td></td></tr>
</table>

the values in bold can be calculated purely on the basis of the values in italics, which means they can be calculated in a loop rather than using recursion.

So here's an implementation of this approach:

    <xsl:function name="my:LevenshteinDistanceC" as="xs:integer">
      <xsl:param name="string1" as="xs:string" />
      <xsl:param name="string2" as="xs:string" />
      <xsl:choose>
        <xsl:when test="$string1 = ''">
          <xsl:sequence select="string-length($string2)" />
        </xsl:when>
        <xsl:when test="$string2 = ''">
          <xsl:sequence select="string-length($string1)" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="my:LevenshteinDistanceC(
                                  string-to-codepoints($string1),
                                  string-to-codepoints($string2),
                                  string-length($string1),
                                  string-length($string2),
                                  (1, 0, 1),
                                  2)" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:function>
    
    <xsl:function name="my:LevenshteinDistanceC" as="xs:integer">
      <xsl:param name="chars1" as="xs:integer*" />
      <xsl:param name="chars2" as="xs:integer*" />
      <xsl:param name="length1" as="xs:integer" />
      <xsl:param name="length2" as="xs:integer" />
      <xsl:param name="lastDiag" as="xs:integer*" />
      <xsl:param name="total" as="xs:integer" />
      <xsl:variable name="shift" as="xs:integer" 
        select="if ($total > $length2) then ($total - ($length2 + 1)) else 0" />
      <xsl:variable name="diag" as="xs:integer*">
        <xsl:for-each select="max((0, $total - $length2)) to 
                              min(($total, $length1))">
          <xsl:variable name="i" as="xs:integer" select="." />
          <xsl:variable name="j" as="xs:integer" select="$total - $i" />
          <xsl:variable name="d" as="xs:integer" select="($i - $shift) * 2" />
          <xsl:if test="$j &lt; $length2">
            <xsl:sequence select="$lastDiag[$d - 1]" />
          </xsl:if>
          <xsl:choose>
            <xsl:when test="$i = 0">
              <xsl:sequence select="$j" />
            </xsl:when>
            <xsl:when test="$j = 0">
              <xsl:sequence select="$i" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:sequence 
                select="min(($lastDiag[$d - 1] + 1,
                             $lastDiag[$d + 1] + 1,
                             $lastDiag[$d] +
                               (if ($chars1[$i] eq $chars2[$j]) then 0 else 1)))" />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="$total = $length1 + $length2">
          <xsl:sequence select="exactly-one($diag)" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="my:LevenshteinDistanceC(
                                  $chars1, $chars2, 
                                  $length1, $length2, 
                                  $diag, $total + 1)" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:function>

Basically, this keeps track of a diagonal of cells (the ones in italic in the earlier matrix), and creates another diagonal based on it to pass into the next recursion. The hardest part is working out when the diagonals go off the edge of the matrix, and adjusting for it. If it helps any, the

    max((0, $total - $length2)) to min(($total, $length1))

is the same as

    (0 to $total)[. &lt;= $length1 and ($total - .) &lt;= $length2]

(but faster) and just keeps `$i` and `$j` within the scope of the matrix.

If you take out the call to `exactly-one()` (which is necessary for Saxon to recognise this as tail-recursive), then this can be used to compare two strings of 200 characters each without running out of stack. With the `exactly-one()` call in place, here's the comparative performance:

<table>
  <tr><th># characters</th><th>row-based</th><th>diagonal-based</th></tr>
  <tr><th>5</th><td>33ms</td><td>36ms</td></tr>
  <tr><th>10</th><td>50ms</td><td>56ms</td></tr>
  <tr><th>20</th><td>70ms</td><td>73ms</td></tr>
  <tr><th>50</th><td>117ms</td><td>110ms</td></tr>
  <tr><th>100</th><td>290ms</td><td>210ms</td></tr>
  <tr><th>200</th><td>1455ms</td><td>711ms</td></tr>
  <tr><th>500</th><td>18934ms</td><td>4389ms</td></tr>
</table>

There's not much in it with short strings (any differences are within the margin of error), but when they get to over 100 characters in length, the diagonal algorithm starts to be faster, by 200 characters it's twice as fast, and at 500 characters over four times as fast!

I guess the take-home messages are: (a) try to iterate rather than recurse whenever you can and (b) don't blindly adapt algorithms designed for procedural programming languages to XSLT.
