<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" exclude-result-prefixes="xs dt" xmlns:dt="http://www.jenitennison.com/datatypes" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:my="http://www.example.com/datatypes">

<!--***** my:decimal *****-->
   <xsl:function name="my:decimal" as="element()">
      <xsl:param name="decimal" as="item()"/>
      <xsl:choose xpath-default-namespace="http://www.example.com/datatypes">
         <xsl:when test="$decimal instance of xs:string">
            <xsl:variable name="parsed" select="my:parse-decimal($decimal)"/>
            <xsl:choose>
               <xsl:when test="$parsed">
                  <xsl:sequence select="my:validated-decimal($parsed)"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:message terminate="yes">
                     <xsl:text>Invalid format for my:decimal: </xsl:text>
                     <xsl:sequence select="$decimal"/>
                  </xsl:message>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:when>
         <xsl:when test="$decimal instance of element()">
            <xsl:choose>
               <xsl:when test="tokenize($decimal/@supertypes, ' ')[if (.) then resolve-QName(., $decimal) = expanded-QName('http://www.example.com/datatypes', 'decimal') else false()]">
                  <xsl:sequence select="$decimal"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:sequence select="my:decimal(dt:string($decimal))"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:when>
         <xsl:otherwise>
            <xsl:sequence select="my:decimal(dt:string($decimal))"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <xsl:function name="my:parse-decimal" as="element()?">
      <xsl:param name="string" as="xs:string"/>
      <xsl:variable name="string" select="normalize-space($string)"/>
      <xsl:if test="my:matches-decimal-regex($string)">
         <xsl:analyze-string select="$string" regex="{my:decimal-regex()}">
            <xsl:matching-substring>
               <my:decimal>
                  <my:sign>
                     <xsl:value-of select="regex-group(2)"/>
                  </my:sign>
                  <my:whole-part>
                     <xsl:value-of select="regex-group(6)"/>
                  </my:whole-part>
                  <xsl:if test="regex-group(9) != ''">
                     <xsl:value-of select="regex-group(10)"/>
                     <my:fraction-part>
                        <xsl:value-of select="regex-group(11)"/>
                     </my:fraction-part>
                  </xsl:if>
               </my:decimal>
            </xsl:matching-substring>
         </xsl:analyze-string>
      </xsl:if>
   </xsl:function>
   <xsl:function name="my:decimal-regex" as="xs:string">
      <xsl:text>^((((\+)(\-))?)(([0-9])+)(((\.)(([0-9])+))?))$</xsl:text>
   </xsl:function>
   <xsl:function name="my:matches-decimal-regex" as="xs:boolean">
      <xsl:param name="string" as="xs:string"/>
      <xsl:sequence select="matches($string, my:decimal-regex())"/>
   </xsl:function>
   <xsl:function name="my:format-decimal" as="xs:string">
      <xsl:param name="decimal" as="element()"/>
      <xsl:sequence select="string(my:normalize-decimal($decimal))"/>
   </xsl:function>
   <xsl:function name="my:validated-decimal" as="element()">
      <xsl:param name="decimal" as="element()"/>
      <xsl:variable name="errors" as="xs:string*" select="my:validate-decimal($decimal)"/>
      <xsl:choose>
         <xsl:when test="$errors">
            <xsl:message terminate="yes">
               <xsl:text>Invalid my:decimal: </xsl:text>
               <xsl:value-of select="distinct-values($errors)" separator="; "/>
               <xsl:text>

               </xsl:text>
               <xsl:sequence select="$decimal"/>
            </xsl:message>
         </xsl:when>
         <xsl:otherwise>
            <xsl:sequence select="$decimal"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <xsl:function name="my:validate-decimal" as="xs:string*">
      <xsl:param name="decimal" as="element()"/>
      <xsl:for-each select="$decimal"/>
   </xsl:function>
   <xsl:function name="my:normalize-decimal" as="element()">
      <xsl:param name="decimal" as="element()"/>
      <my:decimal>
         <xsl:copy-of select="$decimal/dt:supertype"/>
         <xsl:for-each select="$decimal" xpath-default-namespace="http://www.example.com/datatypes">
            <xsl:if test="sign = '-'">
               <xsl:copy-of select="sign"/>
            </xsl:if>
            <my:whole-part>
               <xsl:value-of select="format-number(whole-part, '0')"/>
            </my:whole-part>
            <xsl:if test="fraction-part != 0">
               <xsl:text>.</xsl:text>
               <my:fraction-part>
                  <xsl:value-of select="replace(fraction-part, '0*$', '')"/>
               </my:fraction-part>
            </xsl:if>
         </xsl:for-each>
      </my:decimal>
   </xsl:function>
   <xsl:function name="my:compare-decimals" as="xs:integer">
      <xsl:param name="decimal1" as="element()"/>
      <xsl:param name="decimal2" as="element()"/>
      <xsl:variable name="decimal1" select="my:normalize-decimal($decimal1)"/>
      <xsl:variable name="decimal2" select="my:normalize-decimal($decimal2)"/>
      <xsl:variable name="result" as="xs:integer?">
         <xsl:sequence select="if (number($decimal1) &gt; number($decimal2)) then 1                         else if (number($decimal1) &lt; number($decimal2)) then -1                         else 0"/>
      </xsl:variable>
      <xsl:choose>
         <xsl:when test="$result instance of xs:integer">
            <xsl:sequence select="$result"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:message terminate="yes">
               <xsl:text>Incomparable my:decimals: </xsl:text>
               <xsl:sequence select="$decimal1"/>
               <xsl:text> and </xsl:text>
               <xsl:sequence select="$decimal2"/>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>

<!--***** my:price *****-->
   <xsl:function name="my:price" as="element()">
      <xsl:param name="price" as="item()"/>
      <xsl:choose xpath-default-namespace="http://www.example.com/datatypes">
         <xsl:when test="$price instance of xs:string">
            <xsl:variable name="parsed" select="my:parse-price($price)"/>
            <xsl:choose>
               <xsl:when test="$parsed">
                  <xsl:sequence select="my:validated-price($parsed)"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:message terminate="yes">
                     <xsl:text>Invalid format for my:price: </xsl:text>
                     <xsl:sequence select="$price"/>
                  </xsl:message>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:when>
         <xsl:when test="$price instance of element()">
            <xsl:choose>
               <xsl:when test="tokenize($price/@supertypes, ' ')[if (.) then resolve-QName(., $price) = expanded-QName('http://www.example.com/datatypes', 'price') else false()]">
                  <xsl:sequence select="$price"/>
               </xsl:when>
               <xsl:when test="$price[self::my:decimal]">
                  <xsl:variable name="parsed" as="element()">
                     <my:price supertypes="my:decimal">
                        <xsl:variable name="converted" as="node()*">
                           <xsl:for-each select="$price">
                              <xsl:if test="not(sign = '-')">
                                 <xsl:copy-of select="whole-part"/>
                                 <xsl:text>.</xsl:text>
                                 <my:fraction-part>
                                    <xsl:value-of select="substring(concat(fraction-part, '00'), 1, 2)"/>
                                 </my:fraction-part>
                              </xsl:if>
                           </xsl:for-each>
                        </xsl:variable>
                        <xsl:choose>
                           <xsl:when test="$converted">
                              <xsl:sequence select="$converted"/>
                           </xsl:when>
                           <xsl:otherwise>
                              <xsl:message terminate="yes">
                                 <xsl:text>my:decimal could not be converted to my:price: </xsl:text>
                                 <xsl:sequence select="$price"/>
                              </xsl:message>
                           </xsl:otherwise>
                        </xsl:choose>
                     </my:price>
                  </xsl:variable>
                  <xsl:sequence select="my:validated-price($parsed)"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:sequence select="my:price(my:decimal($price))"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:when>
         <xsl:otherwise>
            <xsl:sequence select="my:price(dt:string($price))"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <xsl:function name="my:parse-price" as="element()?">
      <xsl:param name="string" as="xs:string"/>
      <xsl:variable name="decimal" as="element()?">
         <xsl:sequence select="my:parse-decimal($string)"/>
      </xsl:variable>
      <xsl:if test="$decimal">
         <my:price supertypes="my:decimal {$decimal/@supertypes}">
            <xsl:copy-of select="$decimal/node()"/>
         </my:price>
      </xsl:if>
   </xsl:function>
   <xsl:function name="my:price-regex" as="xs:string">
      <xsl:sequence select="my:decimal-regex()"/>
   </xsl:function>
   <xsl:function name="my:matches-price-regex" as="xs:boolean">
      <xsl:param name="string" as="xs:string"/>
      <xsl:sequence select="my:matches-decimal-regex($string)"/>
   </xsl:function>
   <xsl:function name="my:format-price" as="xs:string">
      <xsl:param name="price" as="element()"/>
      <xsl:sequence select="string(my:normalize-price($price))"/>
   </xsl:function>
   <xsl:function name="my:validated-price" as="element()">
      <xsl:param name="price" as="element()"/>
      <xsl:variable name="errors" as="xs:string*" select="my:validate-price($price)"/>
      <xsl:choose>
         <xsl:when test="$errors">
            <xsl:message terminate="yes">
               <xsl:text>Invalid my:price: </xsl:text>
               <xsl:value-of select="distinct-values($errors)" separator="; "/>
               <xsl:text>

               </xsl:text>
               <xsl:sequence select="$price"/>
            </xsl:message>
         </xsl:when>
         <xsl:otherwise>
            <xsl:sequence select="$price"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <xsl:function name="my:validate-price" as="xs:string*">
      <xsl:param name="price" as="element()"/>
      <xsl:sequence select="my:validate-decimal($price)"/>
      <xsl:for-each select="$price" xpath-default-namespace="http://www.example.com/datatypes">
         <xsl:if test="not(sign) = false()">
            <xsl:text>Failed to satisfy signed parameter (false)</xsl:text>
         </xsl:if>
         <xsl:if test="not(my:compare-decimals(., my:decimal('0')) lt 0)">
            <xsl:text>Failed to satisfy minExclusive parameter (0)</xsl:text>
         </xsl:if>
         <xsl:if test="not((if (string-length(fraction-part)) then string-length(fraction-part) else 0) = 2)">
            <xsl:text>Failed to satisfy decimalPlaces parameter (2)</xsl:text>
         </xsl:if>
      </xsl:for-each>
   </xsl:function>
   <xsl:function name="my:normalize-price" as="element()">
      <xsl:param name="price" as="element()"/>
      <xsl:variable name="decimal" as="element()">
         <xsl:sequence select="my:normalize-decimal($price)"/>
      </xsl:variable>
      <my:price supertypes="my:decimal {$decimal/@supertypes}">
         <xsl:sequence select="$decimal/node()"/>
      </my:price>
   </xsl:function>
   <xsl:function name="my:compare-prices" as="xs:integer">
      <xsl:param name="price1" as="element()"/>
      <xsl:param name="price2" as="element()"/>
      <xsl:variable name="price1" select="my:normalize-price($price1)"/>
      <xsl:variable name="price2" select="my:normalize-price($price2)"/>
      <xsl:variable name="result" as="xs:integer?">
         <xsl:sequence select="my:compare-decimals($price1, $price2)"/>
      </xsl:variable>
      <xsl:choose>
         <xsl:when test="$result instance of xs:integer">
            <xsl:sequence select="$result"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:message terminate="yes">
               <xsl:text>Incomparable my:prices: </xsl:text>
               <xsl:sequence select="$price1"/>
               <xsl:text> and </xsl:text>
               <xsl:sequence select="$price2"/>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>

<!--***** my:ISODate *****-->
   <xsl:function name="my:ISODate" as="element()">
      <xsl:param name="ISODate" as="item()"/>
      <xsl:choose xpath-default-namespace="http://www.example.com/datatypes">
         <xsl:when test="$ISODate instance of xs:string">
            <xsl:variable name="parsed" select="my:parse-ISODate($ISODate)"/>
            <xsl:choose>
               <xsl:when test="$parsed">
                  <xsl:sequence select="my:validated-ISODate($parsed)"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:message terminate="yes">
                     <xsl:text>Invalid format for my:ISODate: </xsl:text>
                     <xsl:sequence select="$ISODate"/>
                  </xsl:message>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:when>
         <xsl:when test="$ISODate instance of element()">
            <xsl:choose>
               <xsl:when test="$ISODate[self::my:UKDate]">
                  <xsl:variable name="parsed" as="element()">
                     <my:ISODate>
                        <xsl:for-each select="$ISODate">
                           <xsl:sequence select="year"/>
                           <xsl:text>-</xsl:text>
                           <xsl:sequence select="month"/>
                           <xsl:text>-</xsl:text>
                           <xsl:sequence select="day"/>
                        </xsl:for-each>
                     </my:ISODate>
                  </xsl:variable>
                  <xsl:sequence select="my:validated-ISODate($parsed)"/>
               </xsl:when>
               <xsl:when test="tokenize($ISODate/@supertypes, ' ')[if (.) then resolve-QName(., $ISODate) = expanded-QName('http://www.example.com/datatypes', 'ISODate') else false()]">
                  <xsl:sequence select="$ISODate"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:sequence select="my:ISODate(dt:string($ISODate))"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:when>
         <xsl:otherwise>
            <xsl:sequence select="my:ISODate(dt:string($ISODate))"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <xsl:function name="my:parse-ISODate" as="element()?">
      <xsl:param name="string" as="xs:string"/>
      <xsl:variable name="string" select="normalize-space($string)"/>
      <xsl:if test="my:matches-ISODate-regex($string)">
         <xsl:analyze-string select="$string" regex="{my:ISODate-regex()}">
            <xsl:matching-substring>
               <my:ISODate>
                  <xsl:sequence select="my:parse-year(regex-group(2))"/>
                  <xsl:value-of select="regex-group(4)"/>
                  <xsl:sequence select="my:parse-month(regex-group(5))"/>
                  <xsl:value-of select="regex-group(7)"/>
                  <xsl:sequence select="my:parse-day(regex-group(8))"/>
               </my:ISODate>
            </xsl:matching-substring>
         </xsl:analyze-string>
      </xsl:if>
   </xsl:function>
   <xsl:function name="my:ISODate-regex" as="xs:string">
      <xsl:text>^((([0-9]){4,})(\-)(([0-9]){2})(/)(([0-9]){2}))$</xsl:text>
   </xsl:function>
   <xsl:function name="my:matches-ISODate-regex" as="xs:boolean">
      <xsl:param name="string" as="xs:string"/>
      <xsl:sequence select="matches($string, my:ISODate-regex())"/>
   </xsl:function>
   <xsl:function name="my:format-ISODate" as="xs:string">
      <xsl:param name="ISODate" as="element()"/>
      <xsl:sequence select="string(my:normalize-ISODate($ISODate))"/>
   </xsl:function>
   <xsl:function name="my:validated-ISODate" as="element()">
      <xsl:param name="ISODate" as="element()"/>
      <xsl:variable name="errors" as="xs:string*" select="my:validate-ISODate($ISODate)"/>
      <xsl:choose>
         <xsl:when test="$errors">
            <xsl:message terminate="yes">
               <xsl:text>Invalid my:ISODate: </xsl:text>
               <xsl:value-of select="distinct-values($errors)" separator="; "/>
               <xsl:text>

               </xsl:text>
               <xsl:sequence select="$ISODate"/>
            </xsl:message>
         </xsl:when>
         <xsl:otherwise>
            <xsl:sequence select="$ISODate"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <xsl:function name="my:validate-ISODate" as="xs:string*">
      <xsl:param name="ISODate" as="element()"/>
      <xsl:for-each select="$ISODate">
         <xsl:if test="my:year">
            <xsl:sequence select="my:validate-year(my:year)"/>
         </xsl:if>
         <xsl:if test="my:month">
            <xsl:sequence select="my:validate-month(my:month)"/>
         </xsl:if>
         <xsl:if test="my:day">
            <xsl:sequence select="my:validate-day(my:day)"/>
         </xsl:if>
         <xsl:variable name="error" as="xs:string*">
            <xsl:choose xpath-default-namespace="http://www.example.com/datatypes">
               <xsl:when test="day &gt; 30 and month = (4, 6, 9, 11)">Month <xsl:value-of select="month"/> only has 30 days.</xsl:when>
               <xsl:when test="month = 2 and day &gt; 29">February never has more than 29 days.</xsl:when>
               <xsl:when test="month = 2 and day = 29 and (year mod 4 or (not(year mod 100) and year mod 400))">In <xsl:value-of select="year"/>, February had 28 days.</xsl:when>
            </xsl:choose>
         </xsl:variable>
         <xsl:sequence select="if ($error) then string-join($error, '') else ()"/>
      </xsl:for-each>
   </xsl:function>
   <xsl:function name="my:normalize-ISODate" as="element()">
      <xsl:param name="ISODate" as="element()"/>
      <xsl:sequence select="$ISODate"/>
   </xsl:function>
   <xsl:function name="my:compare-ISODates" as="xs:integer">
      <xsl:param name="ISODate1" as="element()"/>
      <xsl:param name="ISODate2" as="element()"/>
      <xsl:variable name="ISODate1" select="my:normalize-ISODate($ISODate1)"/>
      <xsl:variable name="ISODate2" select="my:normalize-ISODate($ISODate2)"/>
      <xsl:variable name="result" as="xs:integer?">
         <xsl:choose xpath-default-namespace="http://www.example.com/datatypes">
            <xsl:when test="($ISODate1/year or $ISODate2/year) and not($ISODate1/year and $ISODate2/year)"/>
            <xsl:when test="number($ISODate1/year) != number($ISODate2/year)">
               <xsl:sequence select="if (number($ISODate1/year) &gt; number($ISODate2/year)) then 1 else -1"/>
            </xsl:when>
            <xsl:when test="($ISODate1/month or $ISODate2/month) and not($ISODate1/month and $ISODate2/month)"/>
            <xsl:when test="$ISODate1/month != $ISODate2/month">
               <xsl:sequence select="compare($ISODate1/month, $ISODate2/month)"/>
            </xsl:when>
            <xsl:when test="($ISODate1/day or $ISODate2/day) and not($ISODate1/day and $ISODate2/day)"/>
            <xsl:when test="$ISODate1/day != $ISODate2/day">
               <xsl:sequence select="compare($ISODate1/day, $ISODate2/day)"/>
            </xsl:when>
            <xsl:otherwise>0</xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:choose>
         <xsl:when test="$result instance of xs:integer">
            <xsl:sequence select="$result"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:message terminate="yes">
               <xsl:text>Incomparable my:ISODates: </xsl:text>
               <xsl:sequence select="$ISODate1"/>
               <xsl:text> and </xsl:text>
               <xsl:sequence select="$ISODate2"/>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>

<!--***** my:UKDate *****-->
   <xsl:function name="my:UKDate" as="element()">
      <xsl:param name="UKDate" as="item()"/>
      <xsl:choose xpath-default-namespace="http://www.example.com/datatypes">
         <xsl:when test="$UKDate instance of xs:string">
            <xsl:variable name="parsed" select="my:parse-UKDate($UKDate)"/>
            <xsl:choose>
               <xsl:when test="$parsed">
                  <xsl:sequence select="my:validated-UKDate($parsed)"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:message terminate="yes">
                     <xsl:text>Invalid format for my:UKDate: </xsl:text>
                     <xsl:sequence select="$UKDate"/>
                  </xsl:message>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:when>
         <xsl:when test="$UKDate instance of element()">
            <xsl:choose>
               <xsl:when test="$UKDate[self::my:ISODate]">
                  <xsl:variable name="parsed" as="element()">
                     <my:UKDate>
                        <xsl:for-each select="$UKDate">
                           <xsl:sequence select="day"/>
                           <xsl:text>/</xsl:text>
                           <xsl:sequence select="month"/>
                           <xsl:text>/</xsl:text>
                           <xsl:sequence select="year"/>
                        </xsl:for-each>
                     </my:UKDate>
                  </xsl:variable>
                  <xsl:sequence select="my:validated-UKDate($parsed)"/>
               </xsl:when>
               <xsl:when test="tokenize($UKDate/@supertypes, ' ')[if (.) then resolve-QName(., $UKDate) = expanded-QName('http://www.example.com/datatypes', 'UKDate') else false()]">
                  <xsl:sequence select="$UKDate"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:sequence select="my:UKDate(dt:string($UKDate))"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:when>
         <xsl:otherwise>
            <xsl:sequence select="my:UKDate(dt:string($UKDate))"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <xsl:function name="my:parse-UKDate" as="element()?">
      <xsl:param name="string" as="xs:string"/>
      <xsl:variable name="string" select="normalize-space($string)"/>
      <xsl:if test="my:matches-UKDate-regex($string)">
         <xsl:analyze-string select="$string" regex="{my:UKDate-regex()}">
            <xsl:matching-substring>
               <my:UKDate>
                  <xsl:sequence select="my:parse-day(regex-group(2))"/>
                  <xsl:value-of select="regex-group(4)"/>
                  <xsl:sequence select="my:parse-month(regex-group(5))"/>
                  <xsl:value-of select="regex-group(7)"/>
                  <xsl:sequence select="my:parse-year(regex-group(8))"/>
               </my:UKDate>
            </xsl:matching-substring>
         </xsl:analyze-string>
      </xsl:if>
   </xsl:function>
   <xsl:function name="my:UKDate-regex" as="xs:string">
      <xsl:text>^((([0-9]){2})(/)(([0-9]){2})(/)(([0-9]){4,}))$</xsl:text>
   </xsl:function>
   <xsl:function name="my:matches-UKDate-regex" as="xs:boolean">
      <xsl:param name="string" as="xs:string"/>
      <xsl:sequence select="matches($string, my:UKDate-regex())"/>
   </xsl:function>
   <xsl:function name="my:format-UKDate" as="xs:string">
      <xsl:param name="UKDate" as="element()"/>
      <xsl:sequence select="string(my:normalize-UKDate($UKDate))"/>
   </xsl:function>
   <xsl:function name="my:validated-UKDate" as="element()">
      <xsl:param name="UKDate" as="element()"/>
      <xsl:variable name="errors" as="xs:string*" select="my:validate-UKDate($UKDate)"/>
      <xsl:choose>
         <xsl:when test="$errors">
            <xsl:message terminate="yes">
               <xsl:text>Invalid my:UKDate: </xsl:text>
               <xsl:value-of select="distinct-values($errors)" separator="; "/>
               <xsl:text>

               </xsl:text>
               <xsl:sequence select="$UKDate"/>
            </xsl:message>
         </xsl:when>
         <xsl:otherwise>
            <xsl:sequence select="$UKDate"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <xsl:function name="my:validate-UKDate" as="xs:string*">
      <xsl:param name="UKDate" as="element()"/>
      <xsl:for-each select="$UKDate">
         <xsl:if test="my:day">
            <xsl:sequence select="my:validate-day(my:day)"/>
         </xsl:if>
         <xsl:if test="my:month">
            <xsl:sequence select="my:validate-month(my:month)"/>
         </xsl:if>
         <xsl:if test="my:year">
            <xsl:sequence select="my:validate-year(my:year)"/>
         </xsl:if>
         <xsl:sequence select="my:validate-ISODate(my:ISODate($UKDate))"/>
      </xsl:for-each>
   </xsl:function>
   <xsl:function name="my:normalize-UKDate" as="element()">
      <xsl:param name="UKDate" as="element()"/>
      <xsl:sequence select="$UKDate"/>
   </xsl:function>
   <xsl:function name="my:compare-UKDates" as="xs:integer">
      <xsl:param name="UKDate1" as="element()"/>
      <xsl:param name="UKDate2" as="element()"/>
      <xsl:variable name="UKDate1" select="my:normalize-UKDate($UKDate1)"/>
      <xsl:variable name="UKDate2" select="my:normalize-UKDate($UKDate2)"/>
      <xsl:variable name="result" as="xs:integer?">
         <xsl:sequence select="my:compare-ISODates(my:ISODate($UKDate1), my:ISODate($UKDate2))"/>
      </xsl:variable>
      <xsl:choose>
         <xsl:when test="$result instance of xs:integer">
            <xsl:sequence select="$result"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:message terminate="yes">
               <xsl:text>Incomparable my:UKDates: </xsl:text>
               <xsl:sequence select="$UKDate1"/>
               <xsl:text> and </xsl:text>
               <xsl:sequence select="$UKDate2"/>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>

<!--***** my:day *****-->
   <xsl:function name="my:day" as="element()">
      <xsl:param name="day" as="item()"/>
      <xsl:choose xpath-default-namespace="http://www.example.com/datatypes">
         <xsl:when test="$day instance of xs:string">
            <xsl:variable name="parsed" select="my:parse-day($day)"/>
            <xsl:choose>
               <xsl:when test="$parsed">
                  <xsl:sequence select="my:validated-day($parsed)"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:message terminate="yes">
                     <xsl:text>Invalid format for my:day: </xsl:text>
                     <xsl:sequence select="$day"/>
                  </xsl:message>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:when>
         <xsl:when test="$day instance of element()">
            <xsl:choose>
               <xsl:when test="tokenize($day/@supertypes, ' ')[if (.) then resolve-QName(., $day) = expanded-QName('http://www.example.com/datatypes', 'day') else false()]">
                  <xsl:sequence select="$day"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:sequence select="my:day(dt:string($day))"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:when>
         <xsl:otherwise>
            <xsl:sequence select="my:day(dt:string($day))"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <xsl:function name="my:parse-day" as="element()?">
      <xsl:param name="string" as="xs:string"/>
      <xsl:variable name="string" select="normalize-space($string)"/>
      <xsl:if test="my:matches-day-regex($string)">
         <xsl:analyze-string select="$string" regex="{my:day-regex()}">
            <xsl:matching-substring>
               <my:day>
                  <xsl:value-of select="regex-group(1)"/>
               </my:day>
            </xsl:matching-substring>
         </xsl:analyze-string>
      </xsl:if>
   </xsl:function>
   <xsl:function name="my:day-regex" as="xs:string">
      <xsl:text>^(([0-9]){2})$</xsl:text>
   </xsl:function>
   <xsl:function name="my:matches-day-regex" as="xs:boolean">
      <xsl:param name="string" as="xs:string"/>
      <xsl:sequence select="matches($string, my:day-regex())"/>
   </xsl:function>
   <xsl:function name="my:format-day" as="xs:string">
      <xsl:param name="day" as="element()"/>
      <xsl:sequence select="string(my:normalize-day($day))"/>
   </xsl:function>
   <xsl:function name="my:validated-day" as="element()">
      <xsl:param name="day" as="element()"/>
      <xsl:variable name="errors" as="xs:string*" select="my:validate-day($day)"/>
      <xsl:choose>
         <xsl:when test="$errors">
            <xsl:message terminate="yes">
               <xsl:text>Invalid my:day: </xsl:text>
               <xsl:value-of select="distinct-values($errors)" separator="; "/>
               <xsl:text>

               </xsl:text>
               <xsl:sequence select="$day"/>
            </xsl:message>
         </xsl:when>
         <xsl:otherwise>
            <xsl:sequence select="$day"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <xsl:function name="my:validate-day" as="xs:string*">
      <xsl:param name="day" as="element()"/>
      <xsl:for-each select="$day">
         <xsl:variable name="error" as="xs:string*">
            <xsl:choose xpath-default-namespace="http://www.example.com/datatypes">
               <xsl:when test="not(. &gt; 0 and . &lt;= 31)">The day must be between 1 and 31</xsl:when>
            </xsl:choose>
         </xsl:variable>
         <xsl:sequence select="if ($error) then string-join($error, '') else ()"/>
      </xsl:for-each>
   </xsl:function>
   <xsl:function name="my:normalize-day" as="element()">
      <xsl:param name="day" as="element()"/>
      <xsl:sequence select="$day"/>
   </xsl:function>
   <xsl:function name="my:compare-days" as="xs:integer">
      <xsl:param name="day1" as="element()"/>
      <xsl:param name="day2" as="element()"/>
      <xsl:variable name="day1" select="my:normalize-day($day1)"/>
      <xsl:variable name="day2" select="my:normalize-day($day2)"/>
      <xsl:variable name="result" as="xs:integer?">
         <xsl:sequence select="compare(dt:string($day1), dt:string($day2))"/>
      </xsl:variable>
      <xsl:choose>
         <xsl:when test="$result instance of xs:integer">
            <xsl:sequence select="$result"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:message terminate="yes">
               <xsl:text>Incomparable my:days: </xsl:text>
               <xsl:sequence select="$day1"/>
               <xsl:text> and </xsl:text>
               <xsl:sequence select="$day2"/>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>

<!--***** my:month *****-->
   <xsl:function name="my:month" as="element()">
      <xsl:param name="month" as="item()"/>
      <xsl:choose xpath-default-namespace="http://www.example.com/datatypes">
         <xsl:when test="$month instance of xs:string">
            <xsl:variable name="parsed" select="my:parse-month($month)"/>
            <xsl:choose>
               <xsl:when test="$parsed">
                  <xsl:sequence select="my:validated-month($parsed)"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:message terminate="yes">
                     <xsl:text>Invalid format for my:month: </xsl:text>
                     <xsl:sequence select="$month"/>
                  </xsl:message>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:when>
         <xsl:when test="$month instance of element()">
            <xsl:choose>
               <xsl:when test="tokenize($month/@supertypes, ' ')[if (.) then resolve-QName(., $month) = expanded-QName('http://www.example.com/datatypes', 'month') else false()]">
                  <xsl:sequence select="$month"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:sequence select="my:month(dt:string($month))"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:when>
         <xsl:otherwise>
            <xsl:sequence select="my:month(dt:string($month))"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <xsl:function name="my:parse-month" as="element()?">
      <xsl:param name="string" as="xs:string"/>
      <xsl:variable name="string" select="normalize-space($string)"/>
      <xsl:if test="my:matches-month-regex($string)">
         <xsl:analyze-string select="$string" regex="{my:month-regex()}">
            <xsl:matching-substring>
               <my:month>
                  <xsl:value-of select="regex-group(1)"/>
               </my:month>
            </xsl:matching-substring>
         </xsl:analyze-string>
      </xsl:if>
   </xsl:function>
   <xsl:function name="my:month-regex" as="xs:string">
      <xsl:text>^(([0-9]){2})$</xsl:text>
   </xsl:function>
   <xsl:function name="my:matches-month-regex" as="xs:boolean">
      <xsl:param name="string" as="xs:string"/>
      <xsl:sequence select="matches($string, my:month-regex())"/>
   </xsl:function>
   <xsl:function name="my:format-month" as="xs:string">
      <xsl:param name="month" as="element()"/>
      <xsl:sequence select="string(my:normalize-month($month))"/>
   </xsl:function>
   <xsl:function name="my:validated-month" as="element()">
      <xsl:param name="month" as="element()"/>
      <xsl:variable name="errors" as="xs:string*" select="my:validate-month($month)"/>
      <xsl:choose>
         <xsl:when test="$errors">
            <xsl:message terminate="yes">
               <xsl:text>Invalid my:month: </xsl:text>
               <xsl:value-of select="distinct-values($errors)" separator="; "/>
               <xsl:text>

               </xsl:text>
               <xsl:sequence select="$month"/>
            </xsl:message>
         </xsl:when>
         <xsl:otherwise>
            <xsl:sequence select="$month"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <xsl:function name="my:validate-month" as="xs:string*">
      <xsl:param name="month" as="element()"/>
      <xsl:for-each select="$month">
         <xsl:variable name="error" as="xs:string*">
            <xsl:choose xpath-default-namespace="http://www.example.com/datatypes">
               <xsl:when test="not(. &gt; 0 and . &lt;= 12)">The month must be between 1 and 12</xsl:when>
            </xsl:choose>
         </xsl:variable>
         <xsl:sequence select="if ($error) then string-join($error, '') else ()"/>
      </xsl:for-each>
   </xsl:function>
   <xsl:function name="my:normalize-month" as="element()">
      <xsl:param name="month" as="element()"/>
      <xsl:sequence select="$month"/>
   </xsl:function>
   <xsl:function name="my:compare-months" as="xs:integer">
      <xsl:param name="month1" as="element()"/>
      <xsl:param name="month2" as="element()"/>
      <xsl:variable name="month1" select="my:normalize-month($month1)"/>
      <xsl:variable name="month2" select="my:normalize-month($month2)"/>
      <xsl:variable name="result" as="xs:integer?">
         <xsl:sequence select="compare(dt:string($month1), dt:string($month2))"/>
      </xsl:variable>
      <xsl:choose>
         <xsl:when test="$result instance of xs:integer">
            <xsl:sequence select="$result"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:message terminate="yes">
               <xsl:text>Incomparable my:months: </xsl:text>
               <xsl:sequence select="$month1"/>
               <xsl:text> and </xsl:text>
               <xsl:sequence select="$month2"/>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>

<!--***** my:year *****-->
   <xsl:function name="my:year" as="element()">
      <xsl:param name="year" as="item()"/>
      <xsl:choose xpath-default-namespace="http://www.example.com/datatypes">
         <xsl:when test="$year instance of xs:string">
            <xsl:variable name="parsed" select="my:parse-year($year)"/>
            <xsl:choose>
               <xsl:when test="$parsed">
                  <xsl:sequence select="my:validated-year($parsed)"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:message terminate="yes">
                     <xsl:text>Invalid format for my:year: </xsl:text>
                     <xsl:sequence select="$year"/>
                  </xsl:message>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:when>
         <xsl:when test="$year instance of element()">
            <xsl:choose>
               <xsl:when test="tokenize($year/@supertypes, ' ')[if (.) then resolve-QName(., $year) = expanded-QName('http://www.example.com/datatypes', 'year') else false()]">
                  <xsl:sequence select="$year"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:sequence select="my:year(dt:string($year))"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:when>
         <xsl:otherwise>
            <xsl:sequence select="my:year(dt:string($year))"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <xsl:function name="my:parse-year" as="element()?">
      <xsl:param name="string" as="xs:string"/>
      <xsl:variable name="string" select="normalize-space($string)"/>
      <xsl:if test="my:matches-year-regex($string)">
         <xsl:analyze-string select="$string" regex="{my:year-regex()}">
            <xsl:matching-substring>
               <my:year>
                  <xsl:value-of select="regex-group(1)"/>
               </my:year>
            </xsl:matching-substring>
         </xsl:analyze-string>
      </xsl:if>
   </xsl:function>
   <xsl:function name="my:year-regex" as="xs:string">
      <xsl:text>^(([0-9]){4,})$</xsl:text>
   </xsl:function>
   <xsl:function name="my:matches-year-regex" as="xs:boolean">
      <xsl:param name="string" as="xs:string"/>
      <xsl:sequence select="matches($string, my:year-regex())"/>
   </xsl:function>
   <xsl:function name="my:format-year" as="xs:string">
      <xsl:param name="year" as="element()"/>
      <xsl:sequence select="string(my:normalize-year($year))"/>
   </xsl:function>
   <xsl:function name="my:validated-year" as="element()">
      <xsl:param name="year" as="element()"/>
      <xsl:variable name="errors" as="xs:string*" select="my:validate-year($year)"/>
      <xsl:choose>
         <xsl:when test="$errors">
            <xsl:message terminate="yes">
               <xsl:text>Invalid my:year: </xsl:text>
               <xsl:value-of select="distinct-values($errors)" separator="; "/>
               <xsl:text>

               </xsl:text>
               <xsl:sequence select="$year"/>
            </xsl:message>
         </xsl:when>
         <xsl:otherwise>
            <xsl:sequence select="$year"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <xsl:function name="my:validate-year" as="xs:string*">
      <xsl:param name="year" as="element()"/>
      <xsl:for-each select="$year">
         <xsl:variable name="error" as="xs:string*">
            <xsl:choose xpath-default-namespace="http://www.example.com/datatypes">
               <xsl:when test=". = 0">There is no year 0</xsl:when>
            </xsl:choose>
         </xsl:variable>
         <xsl:sequence select="if ($error) then string-join($error, '') else ()"/>
      </xsl:for-each>
   </xsl:function>
   <xsl:function name="my:normalize-year" as="element()">
      <xsl:param name="year" as="element()"/>
      <xsl:sequence select="$year"/>
   </xsl:function>
   <xsl:function name="my:compare-years" as="xs:integer">
      <xsl:param name="year1" as="element()"/>
      <xsl:param name="year2" as="element()"/>
      <xsl:variable name="year1" select="my:normalize-year($year1)"/>
      <xsl:variable name="year2" select="my:normalize-year($year2)"/>
      <xsl:variable name="result" as="xs:integer?">
         <xsl:sequence select="compare(dt:string($year1), dt:string($year2))"/>
      </xsl:variable>
      <xsl:choose>
         <xsl:when test="$result instance of xs:integer">
            <xsl:sequence select="$result"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:message terminate="yes">
               <xsl:text>Incomparable my:years: </xsl:text>
               <xsl:sequence select="$year1"/>
               <xsl:text> and </xsl:text>
               <xsl:sequence select="$year2"/>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function><!--***** Utilities *****-->
   <xsl:function name="dt:string" as="xs:string">
      <xsl:param name="string" as="item()"/>
      <xsl:choose>
         <xsl:when test="$string instance of element()">
            <xsl:choose>
               <xsl:when test="$string[self::my:decimal]">
                  <xsl:sequence select="my:format-decimal($string)"/>
               </xsl:when>
               <xsl:when test="$string[self::my:price]">
                  <xsl:sequence select="my:format-price($string)"/>
               </xsl:when>
               <xsl:when test="$string[self::my:ISODate]">
                  <xsl:sequence select="my:format-ISODate($string)"/>
               </xsl:when>
               <xsl:when test="$string[self::my:UKDate]">
                  <xsl:sequence select="my:format-UKDate($string)"/>
               </xsl:when>
               <xsl:when test="$string[self::my:day]">
                  <xsl:sequence select="my:format-day($string)"/>
               </xsl:when>
               <xsl:when test="$string[self::my:month]">
                  <xsl:sequence select="my:format-month($string)"/>
               </xsl:when>
               <xsl:when test="$string[self::my:year]">
                  <xsl:sequence select="my:format-year($string)"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:sequence select="string($string)"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:when>
         <xsl:otherwise>
            <xsl:sequence select="xs:string($string)"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
</xsl:stylesheet>