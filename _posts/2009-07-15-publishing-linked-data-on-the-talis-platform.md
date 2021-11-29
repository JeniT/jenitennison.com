---
layout: drupal-post
excerpt_separator: "<!--break-->"
title: Publishing Linked Data on the Talis Platform
created: 1247687590
tags:
- rdf
- talis
---
I was at [OpenTech](http://www.ukuug.org/events/opentech2009/) a couple of weekends ago, and heard a lot of great talks. I particularly enjoyed the one by [Simon Willison](http://simonwillison.net/) in which he talked about the [Guardian Data Blog](http://www.guardian.co.uk/news/datablog). Essentially, the data collected by the journalists at the Guardian, that form the basis of their pretty visualisations and so forth, gets published in Google Spreadsheets.

Looking through the data blog today, I saw that the [Greater London Authority](http://www.london.gov.uk/) have similarly [released their data](http://www.london.gov.uk/focusonlondon/datastore.jsp) using Google Spreadsheets.

Now Google Spreadsheets are just fine -- they're easy for end-users to use and it's not hard for data nerds to extract data from them. They have real advantages for publishing because they are quick and easy to set up.

But take a look through the page listing the tables of data and you can see that many of them are about the same areas. The Guardian Data Blog have actually created a [new spreadsheet](http://spreadsheets.google.com/ccc?key=t3bns85prAbiChLmFhlcB1Q) that pulls together that information. Even with the aggregated data, in Google Spreadsheets there's no way to address the data held in each table about Sutton (say).

Now, a few months ago, [Talis](http://www.talis.com/platform/) announced the [Talis Connected Commons](http://www.talis.com/platform/cc/), which enables anyone to publish public domain data using the Talis Platform for free. It turns out that it's really easy to publish addressable data using the Talis Platform as a host.

<!--break-->

The first stage is to get hold of the data and convert it into some RDF/XML that can be loaded into Talis. You can get hold of a CSV version of a Google Spreadsheet by exporting it as CSV. Converting the CSV into RDF/XML can be done in any number of ways. Given that this is a small dataset and it has commas in some of the fields I've used some simple reusable XSLT rather than awk. Here's `csv.xsl` for parsing the CSV:

    <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
          xmlns:xs="http://www.w3.org/2001/XMLSchema"
          xmlns:csv="http://www.jenitennison.com/xslt/csv"
          xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
          xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
          exclude-result-prefixes="xs csv"
          version="2.0">
          
    <xsl:param name="filename" as="xs:string" required="yes" />
    
    <xsl:variable name="csv" as="xs:string" select="unparsed-text($filename)" />
    <xsl:variable name="lines" as="xs:string+" select="tokenize($csv, '\n')[normalize-space(.) != '']" />
    <xsl:variable name="fields" as="xs:string+" select="csv:values($lines[1])" />
    <xsl:variable name="data" as="xs:string+" select="$lines[position() > 1]" />
    
    <xsl:template match="/" name="main">
      <rdf:RDF>
        <xsl:for-each select="$lines[position() > 1]">
          <xsl:call-template name="csv:line">
            <xsl:with-param name="values" select="csv:values(.)" />
          </xsl:call-template>
        </xsl:for-each>
      </rdf:RDF>
    </xsl:template>
    
    <xsl:template name="csv:line">
      <xsl:param name="values" as="xs:string+" required="yes" />
    </xsl:template>
    
    <xsl:function name="csv:values" as="xs:string+">
      <xsl:param name="line" as="xs:string" />
      <xsl:analyze-string select="$line" regex="(&quot;([^&quot;]+)&quot;|([^,]+))?,">
        <xsl:matching-substring>
          <xsl:choose>
            <xsl:when test="regex-group(2) != ''">
              <xsl:sequence select="regex-group(2)" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:sequence select="regex-group(3)" />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:matching-substring>
        <xsl:non-matching-substring>
          <xsl:variable name="value" as="xs:string" select="normalize-space(.)" />
          <xsl:choose>
            <xsl:when test="starts-with($value, '&quot;') and ends-with($value, '&quot;')">
              <xsl:sequence select="substring($value, 2, string-length($value) - 2)" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:sequence select="$value" />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:non-matching-substring>
      </xsl:analyze-string>
    </xsl:function>
    
    <xsl:function name="csv:field" as="xs:string">
      <xsl:param name="values" as="xs:string+" />
      <xsl:param name="field" as="xs:string" />
      <xsl:sequence select="$values[index-of($fields, $field)]" />
    </xsl:function>
    
    </xsl:stylesheet>

and here's the stylesheet that I've used to create some basic RDF data about the boroughs:

    <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
          xmlns:xs="http://www.w3.org/2001/XMLSchema"
          xmlns:csv="http://www.jenitennison.com/xslt/csv"
          exclude-result-prefixes="xs csv"
          xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
          xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
          xmlns:data="http://www.jenitennison.com/ontology/data#"
          version="2.0">
          
    <xsl:import href="../csv.xsl" />
    
    <xsl:param name="filename" select="resolve-uri('boroughs.txt', static-base-uri())" />
    
    <xsl:template match="/" name="main">
      <rdf:RDF>
        <xsl:for-each select="$data">
          <xsl:variable name="values" as="xs:string+" select="csv:values(.)" />
          <xsl:variable name="borough" as="xs:string" select="csv:field($values, 'BOROUGH')" />
          <xsl:variable name="maleLifeExpectancy" as="xs:string" 
            select="csv:field($values, '2005-07 Life expectancy at birth (years), Males')" />
          <xsl:variable name="femaleLifeExpectancy" as="xs:string" 
            select="csv:field($values, 'Life expectancy at birth (years) Females')" />
          <data:LondonBorough rdf:about="http://www.jenitennison.com/data/id/london-borough/{translate(lower-case(replace($borough, '&amp;', 'and')), ' ', '-')}">
            <rdfs:label><xsl:value-of select="$borough" /></rdfs:label>
            <xsl:if test="$maleLifeExpectancy != ''">
              <data:maleLifeExpectancy rdf:datatype="http://www.w3.org/2001/XMLSchema#integer">
                <xsl:value-of select="$maleLifeExpectancy" />
              </data:maleLifeExpectancy>
            </xsl:if>
            <xsl:if test="$femaleLifeExpectancy != ''">
              <data:femaleLifeExpectancy rdf:datatype="http://www.w3.org/2001/XMLSchema#integer">
                <xsl:value-of select="$femaleLifeExpectancy" />
              </data:femaleLifeExpectancy>
            </xsl:if>
          </data:LondonBorough>
        </xsl:for-each>
      </rdf:RDF>
    </xsl:template>
    
    </xsl:stylesheet>

The result is some RDF/XML for each borough which looks like:

    <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
      xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
      xmlns:data="http://www.jenitennison.com/ontology/data#">
      <data:LondonBorough rdf:about="http://www.jenitennison.com/data/id/london-borough/city-of-london">
        <rdfs:label>City of London</rdfs:label>
      </data:LondonBorough>
      <data:LondonBorough
        rdf:about="http://www.jenitennison.com/data/id/london-borough/barking-and-dagenham">
        <rdfs:label>Barking &amp; Dagenham</rdfs:label>
        <data:maleLifeExpectancy rdf:datatype="http://www.w3.org/2001/XMLSchema#integer">76.3</data:maleLifeExpectancy>
        <data:femaleLifeExpectancy rdf:datatype="http://www.w3.org/2001/XMLSchema#integer>80.3</data:femaleLifeExpectancy>
      </data:LondonBorough>
      <data:LondonBorough rdf:about="http://www.jenitennison.com/data/id/london-borough/barnet">
        <rdfs:label>Barnet</rdfs:label>
        <data:maleLifeExpectancy rdf:datatype="http://www.w3.org/2001/XMLSchema#integer">79.5</data:maleLifeExpectancy>
        <data:femaleLifeExpectancy rdf:datatype="http://www.w3.org/2001/XMLSchema#integer">83.6</data:femaleLifeExpectancy>
      </data:LondonBorough>
      ...
    </rdf:RDF>

To load this into a Talis store, you have to first have one set up, which I do (primarily for experimenting with [rdfQuery](http://code.google.com/p/rdfquery)). You can get one by filling in the form on [the Talis website](http://www.talis.com/platform/cc/contact/). Loading data into Talis just means a `POST` request like this:

    > curl -H "Content-type: application/rdf+xml" --digest -u username:password 
      --data-binary @LondonBoroughs/boroughs.rdf http://api.talis.com/stores/rdfquery-dev1/meta

Once that's done, you can check whether the data has been successfully loaded or not by visiting the URI of the store in an ordinary browser, in this case:

    http://api.talis.com/stores/rdfquery-dev1/meta

You can enter the URI of a resource in the form, for example `http://www.jenitennison.com/data/id/london-borough/barnet` and indicate the format for the response. Requesting Turtle gets you something like:

    <http://www.jenitennison.com/data/id/london-borough/barnet>
      <http://www.w3.org/1999/02/22-rdf-syntax-ns#type>
        <http://www.jenitennison.com/ontology/data#LondonBorough> ;
      <http://www.w3.org/2000/01/rdf-schema#label>
        "Barnet" ;
      <http://www.jenitennison.com/ontology/data#femaleLifeExpectancy>
        "83.6"^^<http://www.w3.org/2001/XMLSchema#integer> ;
      <http://www.jenitennison.com/ontology/data#maleLifeExpectancy>
        "79.5"^^<http://www.w3.org/2001/XMLSchema#integer> .

All is well and good, but this isn't really linked data. For it to be linked data, this RDF needs to be accessible at the URI `http://www.jenitennison.com/data/id/london-borough/barnet`. So how do we do that? Tune in next time to find out.
