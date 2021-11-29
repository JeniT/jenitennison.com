---
layout: drupal-post
excerpt_separator: "<!--break-->"
title: Publishing Linked Data on the Talis Platform, Part 3
created: 1248212361
tags:
- rdf
- talis
---
This is the third in a series of posts about using the [Talis Platform](http://www.talis.com/platform/) as a back end for serving linked data. In the [first part](http://www.jenitennison.com/blog/node/109), I showed how to add data to a store. In the [second post](http://www.jenitennison.com/blog/node/110), I showed how to use some PHP scripts to publish the data as Linked Data, at the URLs you use as your identifiers.

In this post, I'm going to begin the process of exposing the data in a way that makes it easy to locate and reuse. One of the biggest lessons I learned after the initial publication of the [London Gazette](http://www.london-gazette.co.uk) data as RDFa is that the publication of data and metadata about individual items is not enough. To make the data usable, you have to make it discoverable. To make it discoverable there must be an entry point from which you can locate the data. One kind of easy entry point is a list.

In the case of the data about London Boroughs that I've been using, there aren't currently any links to the data, so there is no way to discover it aside from me telling you the URI template (`http://www.jenitennison.com/data/id/london-borough/{name}`, where name is hyphenated and in lowercase) and you knowing the name of a London Borough that you want to look up. Discovery via a URI template that I told you relies on out-of-band information, and contradicts the RESTful tenet of "hypertext as the engine of application state".

Instead, I need to offer an entry point from which you can follow links (or fill in forms) to discover information about the various London Boroughs. Since I'm dealing with a small set of information here, I'm going to do this in the straight-forward way of having `http://www.jenitennison.com/data/london-borough` contain a brief description of each of the known London Boroughs, including (obviously) a link to the URI for the London Borough, from which you can get more information.

<!--break-->

I don't want to return *all* the information about each of the London Boroughs within the list, so I'm going to use a `CONSTRUCT` SPARQL query to create triples that include just the type and label (if it has one) of the borough. Here's the initial query:

    CONSTRUCT { 
      ?thing a <http://www.jenitennison.com/ontology/data#LondonBorough> . 
      ?thing <http://www.w3.org/2000/01/rdf-schema#label> ?label . } 
    WHERE { 
      ?thing a <http://www.jenitennison.com/ontology/data#LondonBorough> . 
      OPTIONAL { ?thing <http://www.w3.org/2000/01/rdf-schema#label> ?label . }} 

Now I want to make this request a bit more generic. The type that I'm looking for here is `http://www.jenitennison.com/ontology/data#LondonBorough` but if I (or you!) wanted to use it for resources of different types, you'd want it to reference a different class. In addition, while the list of London Boroughs is reasonably small, lists of individuals of other types might be much larger, in which case you'd want a facility to page through them.

So in the PHP code I'm going to have three variables: `$type` is the URI of the class of things that should be listed, `$limit` is the number of those things that should appear on each page, and `$start` is the first item in the page. In addition, to ensure a consistent and (hopefully) meaningful order, I'm going to order the results based on their URI. So this is what the query looks like:

    CONSTRUCT { 
      ?thing a <$type> . 
      ?thing <http://www.w3.org/2000/01/rdf-schema#label> ?label . } 
    WHERE { 
      ?thing a <$type> . 
      OPTIONAL { ?thing <http://www.w3.org/2000/01/rdf-schema#label> ?label . }} 
    ORDER BY ?thing
    LIMIT $limit
    OFFSET $start

I'm also going to rejig the PHP that I've been using to use this query when it receives the request `http://www.jenitennison.com/data/london-borough`. First,  `utils.php` is now going to hold a `proxy()` function that performs requests based on the URI of the request or the arguments passed to it. Aside from the body of the SPARQL query, the code is pretty similar to the ASK query (it's getting close to the point where I should at least refactor, or maybe start using [Moriarty](http://code.google.com/p/moriarty) though I'd like to keep this lightweight to provide the minimum overhead for other people wanting to use this mechanism for publishing their data). Here's the function:

    function proxy($type, $limit = 10) {
      global $store;
      $docUri = $_SERVER['REQUEST_URI'];
      
      // URL for the RDF
      if ($_SERVER['PATH_INFO']) {
        // Request for a specific thing
        $dir = dirname($_SERVER['SCRIPT_NAME']);
        $path = substr($docUri, strlen($dir));
        $idUri = "$dir/id$path";
        if (exists($idUri)) {
          $domain = $_SERVER['HTTP_HOST'];
          $id = "http://$domain$idUri";
          $params = array('about' => $id, 'output' => 'rdf');
          $query = http_build_query($params);
          $rdfURL = "http://api.talis.com/stores/$store/meta?$query";
        } else {
          error();
          return;
        }
      } else {
        // Request for a list of $limit individuals of type $type
        $start = (int)$_GET['start'];
        $sparql = "CONSTRUCT { ?thing a <$type> . ?thing <http://www.w3.org/2000/01/rdf-schema#label> ?label . } WHERE { ?thing a <$type> . OPTIONAL { ?thing <http://www.w3.org/2000/01/rdf-schema#label> ?label . }} ORDER BY ?thing LIMIT $limit OFFSET $start";
        $params = array('query' => $sparql, 'output' => 'rdf');
        $query = http_build_query($params);
        $rdfURL = "http://api.talis.com/stores/$store/services/sparql?$query";
      }
      
      // URL for the transformation
      $params = array('xml-uri' => $rdfURL, 
        'xsl-uri' => "http://api.talis.com/stores/$store/items/tidyRDF.xsl");
      $query = http_build_query($params);
      $txURL = "http://api.talis.com/tx?$query";
    
      $resource = fopen($txURL, 'rb');
      header("Content-Type: application/rdf+xml", true);
      header("Content-Location: $docUri.rdf", true);
      fpassthru($resource);
      return;
    }

Now I need to make sure that requests to `http://www.jenitennison.com/data/london-borough` calls this function with the correct type and limit. To do this I create a `london-borough.php` that looks like:

    <?php
      include "utils.php";
      proxy('http://www.jenitennison.com/ontology/data#LondonBorough', 50);
    ?>

and adjust `.htaccess` to redirect to this PHP script:

    <IfModule mod_rewrite.c>
      RewriteEngine on
      RewriteCond %{REQUEST_FILENAME} !-f
      RewriteCond %{REQUEST_FILENAME} !-d
  
      RewriteRule ^id/(.+)$ id.php [L]
      RewriteRule ^london-borough(/.+)? london-borough.php$1 [L,QSA]
    </IfModule>

Note that in the `RewriteRule` for URIs starting with `london-borough`, I've included `QSA` in the options, which means that query string parameters (such as the `start`) parameter will enable paging through the results. For example, if I were only reporting 10 London Boroughs at a time, I could use

    http://www.jenitennison.com/data/london-borough

to get the first ten London Boroughs and

    http://www.jenitennison.com/data/london-borough?start=10

to get the next ten.

When you request `http://www.jenitennison.com/data/london-borough` what you get back is the neatened RDF for the London Boroughs, which looks like:

    <rdf:RDF xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
             xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
      <LondonBorough xmlns="http://www.jenitennison.com/ontology/data#"
                      rdf:about="http://www.jenitennison.com/data/id/london-borough/barking-and-dagenham">
        <rdfs:label>Barking &amp; Dagenham</rdfs:label>
      </LondonBorough>
      <LondonBorough xmlns="http://www.jenitennison.com/ontology/data#"
                      rdf:about="http://www.jenitennison.com/data/id/london-borough/barnet">
        <rdfs:label>Barnet</rdfs:label>
      </LondonBorough>
      ...
    </rdf:RDF>

Now this is OK, but I think the best way of serving *lists of things* is through Atom or RSS, with RSS 1.0 fitting better with the RDF world because it is RDF. Both formats provide mechanisms to give metadata about the list, including links to the next set of information, to enable pagination through the list. So what I'd like to do is provide a mechanism for serving back different formats for this information. And not only for the lists, but for the data about the London Boroughs themselves: Talis supports serving data in Turtle and RDF/JSON as well as RDF/XML, so providing those formats should be cheap. This is something to come back to later.

