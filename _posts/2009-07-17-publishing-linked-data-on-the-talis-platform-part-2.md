---
layout: drupal-post
excerpt_separator: "<!--break-->"
title: Publishing Linked Data on the Talis Platform, Part 2
created: 1247863780
tags:
- rdf
- talis
---
In [my last post](http://www.jenitennison.com/blog/node/109), I showed how to add data to a [Talis](http://www.talis.com/platform/) store. In this post, I'm going to show how you can use the Talis Platform as a back end for a Linked Data view on the RDF you added to it.

As you'll see, the great thing about this method is that it only takes a couple of PHP files and an `.htaccess` file on a server. Assuming that you've got a web server that supports PHP, it's an approach you can use without installing anything. The code I've written is pretty generic and should be widely applicable; feel free to reuse and adapt it.

<!--break-->

One of the principles of Linked Data is that if you make a GET request to a URI that's used as an identifier within an RDF triple, you'll get back some useful information about that resource. I've created URIs like `http://www.jenitennison.com/data/id/london-borough/barnet` and added triples to Talis about those resources, but I haven't yet put anything in place such that actually requesting `http://www.jenitennison.com/data/id/london-borough/barnet` will provide a useful response. So how do I do that?

Well, it's easy enough with a bit of PHP to do the forwarding. (By the way, this is the first bit of PHP I've ever done, so feel free to point out all the glaring problems with it; I'd love to learn.)

Now, the URI `http://www.jenitennison.com/data/id/london-borough/barnet` is a URI that I've made up for a London Borough, and obviously when you request that URI you're not actually going to get the London Borough delivered to you through your computer screen. Instead, based on [Cool URIs for the Semantic Web](http://www.w3.org/TR/cooluris/#r303gendocument), I want to either respond with a `303 See Other` redirection to a document resource *describing* the borough, or a `404 Not Found` to say that it doesn't exist.

Note that I don't just want to blindly respond with a `303 See Other`. If someone requests `http://www.jenitennison.com/data/id/london-borough/rubbish` I want to tell them that the London Borough of 'Rubbish' doesn't exist. If I redirected them to a document URI which then 404'ed, it would mean the London Borough of 'Rubbish' exists, but we have no information about it. So I can't use a simple URL rewrite; I have to check for its presence first.

## Existence Tests ##

The first task, then, is to test whether the resource exists. To do that, I can execute an ASK request on the [SPARQL endpoint](http://n2.talis.com/wiki/Store_Sparql_Service) that Talis provides for the store. The ASK request simply looks like:

    ASK { <http://www.jenitennison.com/data/id/london-borough/barnet> ?p ?v . }

which asks if there are any triples at all that involve that URI. I request the JSON response using the `output=json` parameter. The JSON looks like:

    {"head":{},"boolean":true}

if the store holds any triples about the borough and:

    {"head":{},"boolean":false}

if it doesn't. The URI for the request looks like:

    http://api.talis.com/stores/rdfquery-dev1/services/sparql?query=ASK+%7B+%3Chttp%3A%2F%2Fwww.jenitennison.com%2Fdata%2Fid%2Flondon-borough%2Fbarnet%3E+%3Fp+%3Fv+.+%7D

which looks pretty horrendous when you write it out but is easy enough to construct with PHP. Here's the `exists()` function which does the test based on the server host name used in the request and a path that's passed in.

    $store = 'rdfquery-dev1';
    
    function exists($idUri) {
      global $store;
      $host = $_SERVER['HTTP_HOST'];
      $id = "http://$host$idUri";
      $sparql = "ASK { <$id> ?p ?v . }";
      $params = array('query' => $sparql, 'output' => 'json');
      $query = http_build_query($params);
      $request = "http://api.talis.com/stores/$store/services/sparql?$query";
      $resource = file_get_contents($request, 'rb');
      $result = strstr(strstr($resource, "\"boolean\":"), ":");
      return !strstr($result, "false");
    }

## Handling Identifier URIs ##

With that function in `utils.php`, it's pretty easy to create a `id.php` that does the redirection that I need to do. For my purposes, I'm using `/id/` in all the URIs that identify abstract resources, and removing it for the document URIs that describe them. So the URI for the abstract resource `http://www.jenitennison.com/data/id/london-borough/barnet` will redirect to the document resource `http://www.jenitennison.com/data/london-borough/barnet`. Here's `id.php`:

    <?php
      include "utils.php";
      $idUri = $_SERVER['REQUEST_URI'];
      if (exists($idUri)) {
        $docUri = str_replace('/id/', '/', $idUri);
        header("Location: $docUri", true, 303);
      } else {
        error(404);
      }
    ?>

The `error()` function is also in `utils.php` and looks like:

      function error() {
        header("HTTP/1.1 404 Not Found");
        echo <<<EOF
    <html>
      <head>
        <title>404 Not Found</title>
      </head>
      <body>
        <h1>404 Not Found</h1>
        <p>No such resource</p>
      </body>
    </html>
    EOF;
      }

I have `id.php` which will check for the presence of triples about the requested resource, and respond with either a `404 Not Found` or a `303 See Other`. Now I need to invoke `id.php` whenever someone requests an identifier URI like `http://www.jenitennison.com/data/id/london-borough/barnet`. To do this, I put `id.php` in the `/data` directory within my webserver's documents and added a `.htaccess` file that looks like:

    <IfModule mod_rewrite.c>
      RewriteEngine on
      RewriteCond %{REQUEST_FILENAME} !-f
      RewriteCond %{REQUEST_FILENAME} !-d
      
      RewriteRule ^id/([^/]+)/(.+)$  id.php [L]
    </IfModule>

This says that any requests that aren't for existing files or directories and that start with `id` should be redirected to `id.php`. Since `id.php` picks up on the original request URI, I don't need to pass anything extra into it by way of query parameters and what have you.

> To make this `.htaccess` file work, you have to have `mod_rewrite` enabled and have `AllowOverride` include `FileInfo` (in `http.conf`) . My ISP allows this, but the Apache installation on my Mac doesn't, and Apache generally doesn't out of the box, so you may need to do a bit of fiddling with configuration files.

Now, requesting `http://www.jenitennison.com/data/id/london-borough/barnet` redirects me with a `303 See Other` to `http://www.jenitennison.com/data/london-borough/barnet`, while requesting `http://www.jenitennison.com/data/id/london-borough/rubbish` gives me a `404 Not Found` response.

## Handling Document URIs ##

The next stage is supporting the document URIs like `http://www.jenitennison.com/data/london-borough/barnet`. For them, I need to actually get the data about the resource out of the Talis Platform. Fortunately, there's a really easy way of doing that using a simple [request on the metabox](http://n2.talis.com/wiki/Metabox) like:

    http://api.talis.com/stores/rdfquery-dev1/meta?about=http%3A%2F%2Fwww.jenitennison.com%2Fdata%2Fid%2Flondon-borough%2Fbarnet&output=rdf

In other words, you pass the URI of the resource that you're interested in as the value of the `about` parameter to the metabox store URI of `http://api.talis.com/stores/{store}/meta?about={resource}&output=rdf`. This gives you back some RDF/XML. For the particular request above, the RDF/XML looks like:

    <rdf:RDF
        xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
        xmlns:j.0="http://www.jenitennison.com/ontology/data#"
        xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" > 
      <rdf:Description rdf:about="http://www.jenitennison.com/data/id/london-borough/barnet">
        <rdfs:label>Barnet</rdfs:label>
        <rdf:type rdf:resource="http://www.jenitennison.com/ontology/data#LondonBorough"/>
        <j.0:maleLifeExpectancy rdf:datatype="http://www.w3.org/2001/XMLSchema#decimal">79.5</j.0:maleLifeExpectancy>
        <j.0:femaleLifeExpectancy rdf:datatype="http://www.w3.org/2001/XMLSchema#decimal">83.6</j.0:femaleLifeExpectancy>
      </rdf:Description>
    </rdf:RDF>

Now I don't know about you, but this RDF/XML really makes me cringe. It's very obviously RDF, and it has a horrible `j.0` prefix that no one would ever actually write if they were creating it in an editor. Readability matters, even for data that's aimed at computers. If I'm going to use RDF/XML, I'd really like it to be [sensible XML as well as being RDF](http://www.jenitennison.com/blog/node/74) (and [Leigh Dodds has given some good guidelines about how to do it](http://www.jenitennison.com/blog/node/74#comment-4463)).

But of course since it's XML it's amendable to a spot of transformation. So it's not hard to transform the RDF/XML above into:

    <LondonBorough xmlns="http://www.jenitennison.com/ontology/data#"
                   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                   xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                   rdf:about="http://www.jenitennison.com/data/id/london-borough/sutton">
       <rdfs:label>Sutton</rdfs:label>
       <femaleLifeExpectancy rdf:datatype="http://www.w3.org/2001/XMLSchema#decimal">82.6</femaleLifeExpectancy>
       <maleLifeExpectancy rdf:datatype="http://www.w3.org/2001/XMLSchema#decimal">78.7</maleLifeExpectancy>
    </LondonBorough>

which is a little more acceptable. Talis offers a [transformation service](http://n2.talis.com/wiki/Transformation_Service) at:

    http://api.talis.com/tx

It only supports XSLT 1.0. (There's also the [W3C XSLT 2.0 Service](http://www.w3.org/2005/08/online_xslt/) based on Saxon, but I get the impression they don't like people to use it in anger.)

Anyway, each Talis store contains a contentbox as well as a metabox. The metabox holds the RDF/XML, and the contentbox can hold anything you like. I can put the XSLT stylesheet (`tidyRDF.xsl`) into my store's contentbox using the command:

    curl -X PUT -H "Content-type: application/xslt+xml" --digest -u username:password --data-binary @tidyRDF.xsl 
      http://api.talis.com/stores/rdfquery-dev1/items/tidyRDF.xsl

which then makes it accessible at:

    http://api.talis.com/stores/rdfquery-dev1/items/tidyRDF.xsl

(I could also use my own server of course, but if Talis are offering free hosting, why not?...)

And that means that I can get the RDF/XML associated with `http://www.jenitennison.com/data/london-borough/barnet` and transform it into some decent XML using a horrendous double-escaped URI that I'm not going to replicate here. The `proxy.php` script does this all nicely behind the scenes:

    <?php
      include "utils.php";
      $docUri = $_SERVER['REQUEST_URI'];
      $dir = dirname($_SERVER['SCRIPT_NAME']);
      $path = substr($docUri, strlen($dir));
      $idUri = "$dir/id$path";
      if (exists($idUri)) {
        $domain = $_SERVER['HTTP_HOST'];
    
        // URL for the RDF
        $id = "http://$domain$idUri";
        $params = array('about' => $id, 'output' => 'rdf');
        $query = http_build_query($params);
        $rdfURL = "http://api.talis.com/stores/$store/meta?$query";
    
        // URL for the transformation
        $params = array('xml-uri' => $rdfURL, 
          'xsl-uri' => "http://api.talis.com/stores/$store/items/tidyRDF.xsl");
        $query = http_build_query($params);
        $txURL = "http://api.talis.com/tx?$query";
    
        $resource = fopen($txURL, 'rb');
        header("Content-Type: application/rdf+xml");
        header("Content-Location: $docUri.rdf");
        fpassthru($resource);
        return;
      } else {
        error(404);
      }
    ?>

With `proxy.php` in the `/data` directory on my server, I need a slight tweak to the `.htaccess` to make sure that all non-id requests go to it:

    <IfModule mod_rewrite.c>
      RewriteEngine on
      RewriteCond %{REQUEST_FILENAME} !-f
      RewriteCond %{REQUEST_FILENAME} !-d
      
      RewriteRule ^id/(.+)$  id.php [L]
      
      RewriteCond %{REQUEST_URI} !\.php
      RewriteRule ^(.+)$ proxy.php [L]
    </IfModule>

And Bob, as they say, is your uncle.

Requests to identifier URIs redirect to document URIs. Requests to document URIs return relevant RDF/XML for the resource. Have a look at [http://www.jenitennison.com/data/id/london-borough/barnet](http://www.jenitennison.com/data/id/london-borough/barnet) for example.

*Updated: fixed the link in the final paragraph so it actually pointed to the right location. Duh.*
