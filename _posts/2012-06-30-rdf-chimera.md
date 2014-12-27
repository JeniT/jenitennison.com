---
layout: drupal-post
title: RDF Chimera
created: 1341088964
tags:
- xml
- rdf
- json
---
During [my keynote at XML Prague](http://www.slideshare.net/JeniT/collisions-chimera-and-consonance-in-web-content) (the [video](http://www.youtube.com/watch?v=0K_CAiVyqTQ) might make more sense than the slides on their own; there are notes on the slides but Slideshare doesn't do well with Keynote), I talked about how the advantages of using chimeras created from two formats with different underlying models are seldom outweighed by the disadvantages. RDF/XML gets knocked so frequently it's not even much fun to do it any more, but I've [applied the same arguments](http://www.jenitennison.com/blog/node/149) to [JSON-LD](http://json-ld.org/) in the past. My argument was that RDF, XML, JSON and HTML should each be used individually for their strengths rather than trying to find a middle ground that rarely satisfies anyone.

[Leigh Dodds' post on principled use of RDF/XML](http://blog.ldodds.com/2012/06/12/principled-use-of-rdfxml/) makes the point that RDF/XML can be useful when it is used in a regular, principled way. And in fact, I am using RDF/XML extensively in my work on [Expert Participation](http://www.nationalarchives.gov.uk/documents/expert_participation_press_release.pdf) for [legislation.gov.uk](http://digital.cabinetoffice.gov.uk/2012/03/30/putting-apis-first-legislation-gov-uk/), though slightly differently from how Leigh describes. What I want to explore in this post is when and how it makes sense to use RDF/XML and how that might translate into usage of JSON versions of RDF. The key point I want to make is that RDF chimera are *roads*, not *destinations*, and when you're choosing a road you have to think about the destination you're aiming for.

<!--break-->

## My Destination ##

Within legislation.gov.uk, our primary content is stored as XML (because it's documents) and our primary toolchain is therefore based on XML: we use XSLT, XSL-FO and [Orbeon pipelines](http://wiki.orbeon.com/forms/doc/developer-guide/xml-pipeline-language-xpl) (for historic reasons; today I'd try to find something similar that supported [XProc](http://www.w3.org/TR/xproc/)) to create the various views of legislation we have on the site.

We store RDF content in a triplestore, and query it with SPARQL, because these are technologies designed for easy and efficient storage and querying of RDF, but when it comes to integrating that data into HTML pages, it makes sense to reuse the same core pipelines and processing tooling as we have been using thus far. If we'd been using Ruby on Rails we'd have wanted to use Ruby, if Django then Python, if Node.js then Javascript -- the point is that once we've extracted the data we needed, we needed to get it into a format that we could easily process with the tooling we are using.

## Using SPARQL Results ##

One of the nice things about SPARQL is that you can use it over HTTP and get the results of a standard [`SELECT`](http://www.w3.org/TR/sparql11-query/#select) SPARQL query in [XML](http://www.w3.org/TR/rdf-sparql-XMLres/), [JSON](http://www.w3.org/TR/sparql11-results-json/) or [CSV/TSV](http://www.w3.org/TR/sparql11-results-csv-tsv/). Making HTTP requests is easy across programming languages, and every environment is going to be able to handle at least one of the three possible output formats. So for us, requesting an XML result to a `SELECT` query fits right into our processing pipeline. Well, to be honest, writing paths like 

    sparql:result[sparql:binding[@name = 'process']/sparql:uri = $update]/sparql:binding[@name = 'count']/sparql:literal

is a little irritating, but if I cared enough it would be easy to transform the SPARQL results XML format into something I could more directly query through XPath.

What I've found, however, is that it is usually a lot more flexible and often more efficient to use a `CONSTRUCT` or `DESCRIBE` SPARQL query to extract a subgraph from the store to process. At that point, you need a format that can represent an RDF graph, and you need your processing chain to be able to process an RDF graph as an RDF graph. I'll come on to other languages in a second, but sticking with XML: if your processing toolchain is XML-based, you need it in XML.

There are actually two choices here: RDF/XML or [TriX](http://www.w3.org/2004/03/trix/). TriX is fine, but it suffers similarly to the SPARQL XML results format when you try to use it with XPath: you have to do things like

    $task[trix:uri[2] = $task:assignedTo]/trix:uri[3]

where `$task` is a sequence of `trix:triple` elements and `$task:assignedTo` is the URI of a property that I'm interested in, to work out who is assigned to a particular task in the system I'm building. Of course that gnarliness could be hidden behind a function call, but it means using functions *everywhere*. Using RDF/XML on the other hand can be somewhat easier and use natural XML paths **but only if it is normalised**.

## Normalised RDF/XML for XML/XSLT Processing ##

The biggest problem with RDF/XML for use with XML tooling is that as a format it is too damned flexible. There are multiple ways of representing everything: resource types can be indicated by the name of the resource element or through an explicit `rdf:type` child element; literal property values can be held as attributes or elements; resource property values can be referenced or nested. All these different options for representing the same information makes the format a complete sod to work with.

This is the thrust of Leigh's post. The question is then: how do you normalise RDF/XML into a regular format that you can process? In Leigh's post, he advises ["Use all of the [RDF/XML] shortcuts"](http://blog.ldodds.com/2012/06/12/principled-use-of-rdfxml/), which he describes as basically:

  * using a single root resource element rather than a flat structure with a `rdf:RDF` wrapper
  * using the element name of a resource element to indicate the type of the element
  * using a single resource element to represent each resource

(I note these aren't *all* the RDF/XML shortcuts: you can use attributes for literal properties for example. It looks like Leigh instead chooses the regularity of having all properties be represented as elements in the XML.)

This normalisation routine gives you XML that is very close to "natural" XML: it will only have a few `rdf:about` and `rdf:resource` attributes here and there to give away that it can be processed as RDF/XML. However, if you are starting with RDF, it only gives you a nice, non-repetitive, regular structure if:

  * it's easy to identify a root resource within which everything is nested within a given graph
  * resources only have one type
  * you don't get resources used in more than one place in the graph

For the legislation.gov.uk Expert Participation work, I needed to have a normalisation routine that would work across graphs which included resources with multiple types and that were highly repetitive. I also needed a normalisation routine that I could use without it having to guess what the appropriate root node would be, or me having to feed in that decision or artificially create a root node for each graph (which would have just been extra work). The normalisation that I've found that works for me is instead:

  * always use a `rdf:RDF` wrapper
  * all resource elements are directly within the `rdf:RDF` wrapper, including blank nodes
  * all resource elements are represented by a `rdf:Description` element
  * there's one resource element per resource
  * all properties are represented by elements

There are disadvantages to this algorithm: if you want to find all the `leg:Legislation` items in the RDF, for example, then you need to do something like `//rdf:Description[rdf:type/@rdf:resource = $leg:Legislation]` with an appropriately set `$leg:Legislation` variable, whereas under Leigh's scheme you would do `//leg:Legislation`. The thing is that in the data that I'm dealing with, `leg:Legislation` resources might also be `leg:UnitedKingdomPublicGeneralAct`s or `leg:CommencementOrder`s: I can't know at normalisation time which of the various types of a given resource is the one that I'll want to easily be able to query over, and the cost of changing my mind later on would be quite high.

Similarly, not having nesting means that I can't write simple paths like `$task/task:assignedTo/sioc:User/sioc:name` which I would have been able to do under Leigh's suggested normalisation. What I do instead is define a couple of keys that index the descriptions by their `rdf:about` or `rdf:nodeID` attributes

    <xsl:key name="descriptions" match="rdf:Description" use="@rdf:about" />
    <xsl:key name="nodeID" match="rdf:Description" use="@rdf:nodeID" />

and a function that makes it easy to traverse through properties:

    <xsl:function name="rdf:get" as="element()*">
      <xsl:param name="descriptions" as="element()*" />
      <xsl:param name="propertyChain" as="xs:QName+" />
      <xsl:variable name="properties" as="element()*" select="$descriptions/*[node-name(.) = $propertyChain[1]]" />
      <xsl:variable name="values" as="element()*">
        <xsl:for-each select="$properties">
          <xsl:choose>
            <xsl:when test="@rdf:resource">
              <xsl:sequence select="key('descriptions', @rdf:resource, root())" />
            </xsl:when>
            <xsl:when test="@rdf:nodeID">
              <xsl:sequence select="key('nodeID', @rdf:nodeID, root())" />
            </xsl:when>
            <xsl:when test="*[@rdf:about or @rdf:nodeID]">
              <xsl:sequence select="*" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:sequence select="." />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </xsl:variable>
      <xsl:variable name="values" as="element()*" select="$values | $values" />
      <xsl:choose>
        <xsl:when test="exists($values) and count($propertyChain) > 1">
          <xsl:sequence select="rdf:get($values, subsequence($propertyChain, 2))" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="$values" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:function>

The normalisation I describe coupled with this bit of utility coding means that I can just use a simple path to get to the value of a (literal) property like this: `$task/task:assignedAt` and the `rdf:get()` function when I want to navigate to another resource: `$task/rdf:get(., xs:QName('task:assignedTo'))/sioc:name`. In XSLT 3.0 I think I'd be able to define some funky functional functions and write things like `$task($task:assignedTo)($sioc:name)`, but we're not quite there yet.

## Another Destination ##

What I wanted to bring out is that for all its failings RDF/XML is a useful format, but to process RDF/XML using XML tooling, you need to normalise it into a regular structure that retains the semantics of the underlying RDF graph. I thought it was interesting that Leigh suggested a different normalisation algorithm from the one I use: working through it, it's clear there are different advantages and disadvantages of the different algorithms, both in terms of how easy they are to apply to given data and how easy the results are to process.

But the other thing I wonder is whether Leigh's destination was different from mine. The goal of producing a natural-looking XML format, and one that you would want to validate using RELAX-NG, implies that Leigh was going along the RDF/XML road in another direction: basically scattering some RDF attributes around an XML format so that it could be interpreted by RDF tools. I'm sure that this was the reason RDF/XML was made so flexible to begin with: if you can take some naturalistic XML and just add attributes to turn it into RDF then (the argument goes) you get the best of both worlds.

But this is what I'm really sceptical about. XML formats tend not to fit into the "striped syntax" of resource/property/resource/property required by RDF/XML: they miss out resource elements or they group them in wrappers, or they put references in attributes. To get an XML format to be compliant RDF/XML you really have to design it that way from the start, and this goes to the root of my objection to chimera: when you do that, you stop using XML in the way it's naturally used, and you lose (some of) its advantages. It's like putting yourself in a straitjacket. It seems a lot wiser to me to let XML be XML, and run it through a transformation to create an RDF format (TriX or RDF/XML are both easy targets here) when you want to extract the data within it as RDF.

## JSON and RDF ##

And so I turn again to JSON and RDF, because the same arguments apply. If my destination were using RDF data in a non-XML-based toolchain, I think that I would have a very similar experience to the one described above. Getting the results of a `SELECT` SPARQL query as JSON would be great, but eventually I'd need to handle an RDF graph as an RDF graph and I'd want to be able to manipulate it in my programming language of choice using the idioms of that programming language.

There are RDF processing libraries for most programming languages, of course, that make it easy to load RDF graphs into a data structure that you can then query and process "naturally". If you're using one of these libraries, then the format of the data that you get back from a SPARQL query doesn't really matter, so long as it can be loaded into that data structure through the library.

Does a JSON format for RDF help here? Well, if there isn't a library for a given programming language, or you don't like the API that any of them give you, then a JSON format for RDF is a format that you will be able to load (because every programming language supports JSON) and manipulate.

If you're in this world, you need a regular structure that enables you do that processing in a regular way. You know the format that you're dealing with, so putting URIs into variables isn't an issue (there's no need for shorthands in the syntax itself). You want a flat and predictable structure which you can query into easily to follow links to information about other resources in the graph. You can of course use JSON-LD in this way. It might look something like:

    {
      "@graph": [{
        "@id": "http://www.legislation.gov.uk/id/task/research/effects/uksi/2011/1901",
        "http://www.legislation.gov.uk/def/legislation/assignedTo": [{
          "@value": "http://www.legislation.gov.uk/id/user/tso.co.uk/jeni.tennison"
        }]
      }, {
        "@id": "http://www.legislation.gov.uk/id/user/tso.co.uk/jeni.tennison",
        "http://rdfs.org/sioc/ns#name": [{
          "@value": "Jeni Tennison"
        }]
      }]
    }

This isn't great for navigation, at least in Javascript -- you really need to build a hash table to get quickly from the object ids to the details of the objects themselves -- but once you have that you can do things like:

    objects[task[leg.assignedTo][0].@value][sioc.name][0].@value

which isn't too bad. It gets nastier when you start to have multiple values for properties and want to navigate through them, but people who use these kinds of object structures are used to that.

What about going the other direction? One of the JSON-LD raisons d'être is to provide a quick and easy annotation route for adding RDF semantics on top of existing JSON formats. Just as with RDF/XML used in this way, I'm really not convinced that the majority of existing JSON formats are going to be easily coercible into JSON that can be processed into sensible RDF through the JSON-LD processing rules, nor that JSON designed from scratch to be JSON-LD compatible will have the advantages of "natural" JSON. I can see JSON-LD as an easy-to-generate target format for people wanting to extract RDF from JSON, though given how people generate HTML and XML they might just stick with string manipulation and generate N-triples or N-quads.

## Thoughts? ##

What do you think? Are there advantages in RDF chimeras like RDF/XML and JSON-LD *as destinations* that I'm just not seeing? Are there other ways of normalising them that make them easy to process as XML or JSON?
