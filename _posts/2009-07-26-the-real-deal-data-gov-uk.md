---
layout: drupal-post
title: ! 'The Real Deal: data.gov.uk'
created: 1248622734
tags:
- rdf
- linked data
- talis
- uri
- psi
---
I'm sure that you've noticed that my recent posts have been somewhat obsessed with publishing and using public sector information. It's because I've somehow been sucked into the work going on within the UK government, [with Tim Berners-Lee and Nigel Shadbolt advising](http://blogs.cabinetoffice.gov.uk/digitalengagement/post/2009/06/09/Data-So-what-happens-now.aspx), to publish its data as linked data.

My [recent](http://www.jenitennison.com/blog/node/109) [blog](http://www.jenitennison.com/blog/node/110) [posts](http://www.jenitennison.com/blog/node/111) about publishing data using [Talis](http://www.talis.com/platform/) have actually been a front for much more complex work that I've been doing with a different data set.

<!--break-->

As an early demonstration of how existing government data sets might be turned into linked data, a few weeks ago I was given a CSV file containing road traffic counts; the raw data that lies behind the [traffic flow information](http://www.dft.gov.uk/matrix/) available on the Department for Transport website. The data is really interesting and ripe for visualisations and analysis. For each hour of particular days each year, at particular points on many roads within the UK, the Department for Transport measures the number of bicycles, motorbikes, cars, vans, buses and HGVs of various types that roll past in each direction. The data contains information about:

  * the count of each of the various classes of traffic that pass the point in a particular direction on a particular hour of a particular day
  * the points at which these measurements were taken
  * the roads on which the points are situated
  * the areas in which the points are situated
  * the local authority that is in charge of these areas
  * the region that the area is in
  * the country that the region is in 

The challenge was to turn the 386Mb CSV file into linked data. The result is up and available for you to look at; a good starting point is [http://geo.data.gov.uk/0/country](http://geo.data.gov.uk/0/country). Just follow the links from there.

With a few false starts and mis-steps, this is the process that I went through:

  1. Tidied the CSV file so that it could be processed using awk. That meant replacing the commas that were delimiters with `|`s. It also meant removing a couple of weird ^M characters that had snuck into the file.
  2. Examined the data and came up with an informal ontology and prototype URI scheme.
  3. Created a bunch of awk scripts to extract different data from the files and create RDF/XML from it.
  4. Ran the scripts to create RDF/XML.
  5. Uploaded the data into a Talis store.
  6. Created appropriate PHP for the data and put it into a proxy server.

Some of this has been covered by my recent posts, so I'm just going to talk about a few of these steps in a bit more detail.

First, the URIs. Frankly, they're an experiment to see how it plays. The templates are:

  * countries: `http://geo.data.gov.uk/0/id/country/{name}`, eg [http://geo.data.gov.uk/0/id/country/england](http://geo.data.gov.uk/0/id/country/england)
  * regions: `http://geo.data.gov.uk/0/id/region/{name}`, eg [http://geo.data.gov.uk/0/id/region/north-west](http://geo.data.gov.uk/0/id/region/north-west)
  * areas: `http://geo.data.gov.uk/0/id/area/{ONS code}`, eg [http://geo.data.gov.uk/0/id/area/00KA](http://geo.data.gov.uk/0/id/area/00KA)
  * local authorities: `http://local-government.data.gov.uk/0/id/local-authority/{ONS code for area}`, eg [http://local-government.data.gov.uk/0/id/local-authority/00KA](http://local-government.data.gov.uk/0/id/local-authority/00KA)
  * roads: `http://transport.data.gov.uk/0/id/road/{name}` or `http://transport.data.gov.uk/0/id/road/U-{random number}`, eg [http://transport.data.gov.uk/0/id/road/M5](http://transport.data.gov.uk/0/id/road/M5)
  * traffic count points: `http://transport.data.gov.uk/0/id/traffic-count-point/{number}`, eg [http://transport.data.gov.uk/0/id/traffic-count-point/36195](http://transport.data.gov.uk/0/id/traffic-count-point/36195)
  * traffic counts: `http://transport.data.gov.uk/0/id/traffic-count/{point number}/{direction}/{date}/{hour}/{traffic type}`, eg [http://transport.data.gov.uk/0/id/traffic-count/4/N/2008-06-05/08:00:00/HGVr2](http://transport.data.gov.uk/0/id/traffic-count/4/N/2008-06-05/08:00:00/HGVr2)

The subdomains are one way of subdividing the vast set of public sector information into vague categories that might be handled by different departments, without using the (highly changeable) department names in the URI. The `/0` portion of each URI is a version number: these URIs are experimental and liable to be unsupported in the future so they're marked with a version 0. The `/id` portion of each URI indicates that these are URIs for non-information resources; the response is a `303 See Other` redirect to the same URIs but without the `/id`.

After the `/id`, the URIs follow a common pattern of naming a class of resource, followed by an appropriate identifier for that resource. The identifiers themselves are designed to be unique, [unlikely to change](http://www.jenitennison.com/blog/node/112), and [human readable](http://www.jenitennison.com/blog/node/114).

The ontologies, well, actually they don't exist as yet except in my head. It's been more important to make the data available than to provide ontologies for it. Triplestores and SPARQL queries work without ontologies; indeed you have to go out of your way to find applications that actually reason with them. Like schemas for XML documents, they're not absolutely essential, but useful for documentation purposes and *potentially* useful for applications.

There are, though, a couple of [SKOS](http://www.w3.org/2004/02/skos/) schemes for categorising roads and vehicle types. These are available via:

  * http://transport.data.gov.uk/0/category/road
  * http://transport.data.gov.uk/0/category/vehicle

They were informed by the [British Roads FAQ](http://www.cbrd.co.uk/roadsfaq/) and the [data definitions from the Department for Transport](http://www.dft.gov.uk/matrix/forms/definitions.aspx). I heartily recommend a read; it's scintillating stuff!

Anyway, with this size of file, and the kind of processing that needed to be done with it, the simple XSLT that I talked about [previously](http://www.jenitennison.com/blog/node/109) for extracting data out of CSV files just wasn't going to cut it. Awk, on the other hand, is designed for this kind of processing. Most of the RDF/XML could be generated by collecting unique values from the file. For example, to generate the RDF/XML for the regions I used:

    BEGIN { 
      FS = "|";
      print "<rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\"";
      print "  xmlns:rdfs=\"http://www.w3.org/2000/01/rdf-schema#\"";
      print "  xmlns:g=\"http://geo.data.gov.uk/0/ontology/geo#\">";
    }
    FNR > 1 {
      countries[$2] = substr($1, 2, length($1) - 2);
      regions[$2] = substr($2, 2, length($2) - 2);
      codes[$2] = substr($3, 2, length($3) - 2);
    }
    END { 
      for (region in regions) {
        country = countries[region];
        name = regions[region];
        code = codes[region];
        path = tolower(name);
        gsub(" ", "-", path);
        print "<g:Region rdf:about=\"http://geo.data.gov.uk/0/id/region/" path "\">";
        print "  <rdfs:label>" name "</rdfs:label>";
        print "  <g:isInCountry>";
        print "    <g:Country rdf:about=\"http://geo.data.gov.uk/0/id/country/" tolower(country) "\">";
        print "      <g:hasRegion rdf:resource=\"http://geo.data.gov.uk/0/id/region/" path "\" />";
        print "    </g:Country>";
        print "  </g:isInCountry>";
        if (code != "") {
          print "  <g:ONScode rdf:datatype=\"http://www.w3.org/2001/XMLSchema#NCName\">" code "</g:ONScode>";
        }
        print "</g:Region>";
      }
      print "</rdf:RDF>"; 
    }

This generated RDF/XML that looks like:

    <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
      xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
      xmlns:g="http://geo.data.gov.uk/0/ontology/geo#">
    <g:Region rdf:about="http://geo.data.gov.uk/0/id/region/london">
      <rdfs:label>London</rdfs:label>
      <g:isInCountry>
        <g:Country rdf:about="http://geo.data.gov.uk/0/id/country/england">
          <g:hasRegion rdf:resource="http://geo.data.gov.uk/0/id/region/london" />
        </g:Country>
      </g:isInCountry>
      <g:ONScode rdf:datatype="http://www.w3.org/2001/XMLSchema#NCName">H</g:ONScode>
    </g:Region>
    <g:Region rdf:about="http://geo.data.gov.uk/0/id/region/yorkshire-and-the-humber">
      <rdfs:label>Yorkshire and The Humber</rdfs:label>
      <g:isInCountry>
        <g:Country rdf:about="http://geo.data.gov.uk/0/id/country/england">
          <g:hasRegion rdf:resource="http://geo.data.gov.uk/0/id/region/yorkshire-and-the-humber" />
        </g:Country>
      </g:isInCountry>
      <g:ONScode rdf:datatype="http://www.w3.org/2001/XMLSchema#NCName">D</g:ONScode>
    </g:Region>
    ...
    </rdf:RDF>

In other cases, I needed to split up the RDF/XML that was generated into several files. Uploads to Talis of more than about 2Mb cause the upload to fail. The traffic count point RDF/XML needed to be split into 13 separate files. The traffic counts themselves... well, I haven't managed to do it all yet but to give you an idea, the 2008 data alone generated 1800 RDF/XML files, each about 1.6Mb in size and each taking about a minute to upload. What's there now is all the 2008 data, and the overall motor vehicle counts from all the years. More will be added gradually.

The awk script that generates the count data in separate files is:

    BEGIN { 
      FS = "|";
      fileCount = 0;
      countCount = 99999;
      curlFile = "traffic-counts.curl.sh";
    }
    FNR > 1 && $15 ~ /\/2008 / {
      countCount += 1;
      if (countCount > 200) {
        if (fileCount != 0) {
          print "</rdf:RDF>" > fileName; 
          close(fileName);
        }
        countCount = 0;
        fileCount += 1;
        fileName = "traffic-counts/traffic-counts." fileCount ".rdf";
        print "creating", fileName;
        print "echo loading", fileName > curlFile;
        print "curl -H \"Content-type: application/rdf+xml\" -o progress.txt --digest -u username:password --data-binary @" fileName " http://api.talis.com/stores/transport/meta" > curlFile;
    
        print "<?xml version=\"1.0\" encoding=\"ASCII\"?>" > fileName;
        print "<rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\"" > fileName;
        print "  xmlns:rdfs=\"http://www.w3.org/2000/01/rdf-schema#\"" > fileName;
        print "  xmlns:xsd=\"http://www.w3.org/2001/XMLSchema#\"" > fileName;
        print "  xmlns:t=\"http://transport.data.gov.uk/0/ontology/traffic#\"" > fileName;
        print "  xml:base=\"http://transport.data.gov.uk/0/id/traffic-count/\">" > fileName;
      }
    
      cp = $7;
      date = $15;
      direction = substr($16, 2, length($16) - 2);
      split(date, dateFields, " ");
      date = dateFields[1];
      split(date, dateFields, "/");
      date = sprintf("%04d-%02d-%02d", dateFields[3], dateFields[2], dateFields[1]);
      hour = sprintf("%02d:00:00", $17);
      base = "http://transport.data.gov.uk/0/id/traffic-count/" cp "/" direction "/" date "/" hour;
      
      cycles = $18;
      motorbikes = $19;
      ...
    
      print "<t:Count rdf:about=\"" base "/cycle\">" > fileName;
      print "  <t:point>" > fileName;
      print "    <t:CountPoint rdf:about=\"http://transport.data.gov.uk/0/id/traffic-count-point/" cp "\">" > fileName;
      print "      <t:count rdf:resource=\"" base "/cycle\" />" > fileName;
      print "    </t:CountPoint>" > fileName;
      print "  </t:point>" > fileName;
      print "  <t:hour rdf:datatype=\"http://www.w3.org/2001/XMLSchema#dateTime\">" date "T" hour "</t:hour>" > fileName;
      print "  <t:direction>" direction "</t:direction>" > fileName;
      print "  <t:category rdf:resource=\"http://transport.data.gov.uk/0/category/bicycle\" />" > fileName;
      print "  <rdf:value  rdf:datatype=\"http://www.w3.org/2001/XMLSchema#integer\">" cycles "</rdf:value>" > fileName;
      print "</t:Count>" > fileName;
      print "<t:Count rdf:about=\"" base "/motorbike\">" > fileName;
      print "  <t:point>" > fileName;
      print "    <t:CountPoint rdf:about=\"http://transport.data.gov.uk/0/id/traffic-count-point/" cp "\">" > fileName;
      print "      <t:count rdf:resource=\"" base "/motorbike\" />" > fileName;
      print "    </t:CountPoint>" > fileName;
      print "  </t:point>" > fileName;
      print "  <t:hour rdf:datatype=\"http://www.w3.org/2001/XMLSchema#dateTime\">" date "T" hour "</t:hour>" > fileName;
      print "  <t:direction>" direction "</t:direction>" > fileName;
      print "  <t:category rdf:resource=\"http://transport.data.gov.uk/0/category/motorbike\" />" > fileName;
      print "  <rdf:value  rdf:datatype=\"http://www.w3.org/2001/XMLSchema#integer\">" motorbikes "</rdf:value>" > fileName;
      print "</t:Count>" > fileName;
      ...
    }
    END {
      print "</rdf:RDF>" > fileName; 
      close(fileName);
    }

This also generates a shall script that includes the curl instructions to upload the files.

The original data contained easing/northing information about each point when generally latitude/longitude is easier for mapping. So I extracted the easting/northings, used the [free (Windows only) software available via the Ordnance Survey](http://gps.ordnancesurvey.co.uk/convert.asp) to turn these into latitude/longitude -- there is a [web service](http://gps.ordnancesurvey.co.uk/convertbatch.asp?location=0) to do the same, but you can only do 200 coordinates at a time -- converted those into decimals, then RDF, and uploaded them.

The PHP scripts that serve the data as linked data are exactly what I've [shown before](http://www.jenitennison.com/blog/node/111). I amended the `.htaccess` file to redirect to an appropriate PHP script like this:

    <IfModule mod_rewrite.c>
      RewriteEngine on
      RewriteCond %{REQUEST_FILENAME} !-f
      RewriteCond %{REQUEST_FILENAME} !-d
    
      RewriteRule ^id/(.+)$  id.php [L]
    
      RewriteCond %{REQUEST_URI} !\.php
      RewriteRule ^([^/]+)(/.+)? $1.php$2 [L,QSA]
    </IfModule>

and created PHP scripts for each of the types of data being published. For example, `region.php` is:

    <?php
      include "utils.php";
      proxy('http://geo.data.gov.uk/0/ontology/geo#Region', 50);
    ?>

And there we have it. Linked traffic count data on the web.

(And because this is all published through Talis, there's also a [SPARQL endpoint](http://api.talis.com/stores/transport/services/sparql) that you could use to run queries and [create visualisations](http://www.jenitennison.com/blog/node/112). Knock yourself out.)

Please take a look and comment on what we've done. What's your opinion of the URI scheme? Is it useful to be able to access the data as linked data? Which other formats would you like to see?
