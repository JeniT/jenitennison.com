<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:u="http://www.jenitennison.com/ns/unicode"
  exclude-result-prefixes="xs u">

<xsl:output indent="yes" />

<xsl:variable name="NamesList" as="xs:string"
  select="unparsed-text('NamesList.txt', 'ISO-8859-1')" />

<xsl:variable name="UnicodeData" as="xs:string"
  select="unparsed-text('UnicodeData.txt', 'UTF-8')" />

<xsl:key name="Characters" match="character" use="@hex" />

<xsl:template match="/" name="createUnicodeDatabase">
  <xsl:param name="from" as="xs:integer" select="0" />
  <xsl:param name="to" as="xs:integer" select="591" />
  <xsl:param name="characters" as="xs:integer+" select="$from to $to" />
  <xsl:variable name="database">
    <characters>
      <xsl:for-each select="tokenize($UnicodeData, '\n')[. ne '']">
        <xsl:variable name="fields" as="xs:string+"
          select="tokenize(., ';')" />
        <xsl:variable name="dec" as="xs:integer" 
          select="u:hexToDecimal($fields[1])" />
        <character hex="{$fields[1]}"
                   dec="{$dec}"
                   category="{$fields[3]}"
                   bidi="{$fields[5]}">
          <xsl:if test="$fields[4] ne '0'">
            <xsl:attribute name="canon_combining_class"
              select="$fields[4]" />
          </xsl:if>
          <xsl:if test="$fields[7] ne ''">
            <xsl:attribute name="decimal"
              select="$fields[7]" />
          </xsl:if>
          <xsl:if test="$fields[8] ne ''">
            <xsl:attribute name="digit"
              select="$fields[8]" />
          </xsl:if>
          <xsl:if test="$fields[9] ne ''">
            <xsl:attribute name="numeric"
              select="$fields[9]" />
          </xsl:if>
          <xsl:if test="$fields[10] ne 'N'">
            <xsl:attribute name="bidi_mirrored"
              select="$fields[10]" />
          </xsl:if>
          <xsl:if test="$fields[11] ne ''">
            <xsl:attribute name="alias"
              select="$fields[11]" />
          </xsl:if>
          <name>
            <xsl:value-of select="$fields[2]" />
          </name>
          <xsl:if test="$fields[12] ne ''">
            <comment>
              <xsl:value-of select="$fields[12]" />
            </comment>
          </xsl:if>
          <xsl:if test="$fields[6] ne ''">
            <xsl:variable name="decomp" select="$fields[6]" />
            <decomp>
              <xsl:if test="starts-with($decomp, '&lt;')">
                <xsl:attribute name="type"
                  select="substring-before(substring($decomp, 2), '&gt;')" />
              </xsl:if>
              <!-- decomposition sometimes is one character and description,
                   so have to ignore the rest of the string in this case -->
              <xsl:variable name="rest" as="xs:string"
                select="if (starts-with($decomp, '&lt;')) 
                        then normalize-space(substring-after($decomp, '&gt;')) 
                        else $decomp" />
              <xsl:analyze-string select="$rest" regex="[0-9A-F]+">
                <xsl:matching-substring>
                  <char hex="{.}" />
                </xsl:matching-substring>
              </xsl:analyze-string>
            </decomp>
          </xsl:if>
          <xsl:if test="$fields[13]">
            <uppercase hex="{$fields[13]}" />
          </xsl:if>
          <xsl:if test="$fields[14]">
            <lowercase hex="{$fields[14]}" />
          </xsl:if>
          <xsl:if test="$fields[15]">
            <titlecase hex="{$fields[15]}" />
          </xsl:if>
        </character>
      </xsl:for-each>
    </characters>
  </xsl:variable>
  <xsl:variable name="records" as="element()+">
    <xsl:for-each select="tokenize($NamesList, '\n')[. ne '']">
      <xsl:choose>
        <xsl:when test="starts-with(., '@@&#x9;')">
          <xsl:analyze-string select="." regex="@@\t([0-9A-F]+)\t([^\t]+)\t([0-9A-F]+)">
            <xsl:matching-substring>
              <block start="{regex-group(1)}" end="{regex-group(3)}">
                <name><xsl:value-of select="regex-group(2)" /></name>
              </block>
            </xsl:matching-substring>
          </xsl:analyze-string>
        </xsl:when>
        <xsl:when test="starts-with(., '@&#x9;')">
          <subblock>
            <name><xsl:value-of select="substring-after(., '@&#x9;&#x9;')" /></name>
          </subblock>
        </xsl:when>
        <xsl:when test="starts-with(., '@+')">
          <comment><xsl:value-of select="substring-after(., '@+&#x9;&#x9;')" /></comment>
        </xsl:when>
        <xsl:when test="starts-with(., '&#x9;')">
          <xsl:variable name="char" as="xs:string"
            select="substring(., 2, 1)" />
          <xsl:variable name="content" as="xs:string"
            select="substring-after(., ' ')" />
          <xsl:choose>
            <xsl:when test="$char = '*'">
              <xsl:analyze-string select="$content" regex="^other[^:]+: (([0-9A-F]+)-([0-9A-F]+)(, ([0-9A-F]+)-([0-9A-F]+))*)$">
                <xsl:matching-substring>
                  <xsl:for-each select="tokenize(regex-group(1), ', ')">
                    <xsl:for-each select="u:hexToDecimal(substring-before(., '-')) to
                                          u:hexToDecimal(substring-after(., '-'))">
                      <rel hex="{u:decimalToHex(.)}" />
                    </xsl:for-each>
                  </xsl:for-each>
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                  <comment><xsl:value-of select="." /></comment>
                </xsl:non-matching-substring>
              </xsl:analyze-string>
            </xsl:when>
            <xsl:when test="$char = '='">
              <xsl:for-each select="tokenize($content, ', ')">
                <alias><xsl:value-of select="." /></alias>
              </xsl:for-each>
            </xsl:when>
            <xsl:when test="$char = '%'">
              <alias type="formal"><xsl:value-of select="$content" /></alias>
            </xsl:when>
            <xsl:when test="$char = 'x'">
              <xsl:analyze-string select="$content" regex="\((([^-]|([^ ]-[^ ]))+) - ([0-9A-F]+)\)">
                <xsl:matching-substring>
                  <ref hex="{regex-group(4)}" />
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                  <ref hex="{.}" />
                </xsl:non-matching-substring>
              </xsl:analyze-string>
            </xsl:when>
            <xsl:when test="$char = (':', '#')">
              <!-- ignore: get this from UnicodeData.txt -->
            </xsl:when>
            <xsl:otherwise>
              <other type="{$char}">
                <xsl:value-of select="$content" />
              </other>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:analyze-string select="." 
            regex="([0-9A-F]+)\t([^(\n]+)(\s\(([^)\n]+)\))?">
            <xsl:matching-substring>
              <xsl:variable name="hex" as="xs:string"
                select="regex-group(1)" />
              <xsl:variable name="matched" as="element(character)?"
                select="key('Characters', $hex, $database)" />
              <character hex="{$hex}">
                <xsl:if test="empty($matched)">
                  <xsl:attribute name="unused" select="'true'" />
                </xsl:if>
                <xsl:copy-of select="$matched/@* except $matched/@alias" />
                <name>
                  <xsl:value-of select="regex-group(2)" />
                </name>
                <xsl:if test="regex-group(4)">
                  <comment>
                    <xsl:value-of select="regex-group(4)" />
                  </comment>
                </xsl:if>
                <xsl:copy-of select="$matched/* except $matched/(name, comment)" />
              </character>
            </xsl:matching-substring>
          </xsl:analyze-string>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:variable>
  <characters>
    <xsl:for-each-group select="$records" 
      group-starting-with="block">
      <xsl:if test="self::block">
        <xsl:copy>
          <xsl:copy-of select="@*, node()" />
          <xsl:for-each-group select="current-group() except ." 
            group-starting-with="subblock">
            <xsl:choose>
              <xsl:when test="self::subblock">
                <xsl:copy>
                  <xsl:copy-of select="@*, node()" />
                  <xsl:for-each-group select="current-group() except ." 
                    group-starting-with="character">
                    <xsl:choose>
                      <xsl:when test="self::character">
                        <xsl:copy>
                          <xsl:copy-of select="@*, *" />
                          <xsl:copy-of select="current-group() except ." />
                        </xsl:copy>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:copy-of select="current-group()" />
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:for-each-group>
                </xsl:copy>
              </xsl:when>
              <xsl:otherwise>
                <xsl:copy-of select="current-group()" />
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each-group>
        </xsl:copy>
      </xsl:if>
    </xsl:for-each-group>
  </characters>
</xsl:template>

<xsl:variable name="hexDigits" as="xs:string" select="'0123456789ABCDEF'" />

<xsl:function name="u:hexToDecimal" as="xs:integer">
  <xsl:param name="hex" as="xs:string" />
  <xsl:sequence select="u:hexToDecimal($hex, 0)" />
</xsl:function>

<xsl:function name="u:hexToDecimal" as="xs:integer">
  <xsl:param name="hex" as="xs:string" />
  <xsl:param name="dec" as="xs:integer" />
  <xsl:variable name="hexDigit" as="xs:string" select="substring($hex, 1, 1)" />
  <xsl:variable name="decDigit" as="xs:integer" 
    select="string-length(substring-before($hexDigits, $hexDigit))" />
  <xsl:variable name="newDec" as="xs:integer"
    select="16 * $dec + $decDigit" />
  <xsl:choose>
    <xsl:when test="string-length($hex) = 1">
      <xsl:sequence select="$newDec" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="u:hexToDecimal(substring($hex, 2), $newDec)" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="u:decimalToHex" as="xs:string">
  <xsl:param name="dec" as="xs:integer" />
  <xsl:sequence select="u:decimalToHex($dec, '')" />
</xsl:function>

<xsl:function name="u:decimalToHex" as="xs:string">
  <xsl:param name="dec" as="xs:integer" />
  <xsl:param name="hex" as="xs:string" />
  <xsl:variable name="char" as="xs:string" 
    select="substring($hexDigits, ($dec mod 16) + 1, 1)" />
  <xsl:choose>
    <xsl:when test="$dec >= 16">
      <xsl:sequence select="u:decimalToHex($dec idiv 16, concat($char, $hex))" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="concat($char, $hex)" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

</xsl:stylesheet>
