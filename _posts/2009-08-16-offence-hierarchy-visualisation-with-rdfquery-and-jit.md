---
layout: drupal-post
title: Offence Hierarchy Visualisation with rdfQuery and JIT
created: 1250452850
tags:
- rdf
- rdfquery
- visualisation
---
The [Home Office](http://www.homeoffice.gov.uk/) recently [opened up some of its data](http://www.homeoffice.gov.uk/about-us/publications/non-personal-data/), mostly in the form of PDF reports and Excel spreadsheets. Right after, I went on holiday and offline (!) for a week, so I set myself the task of putting together some visualisations of the data using two client-side visualisation libraries that I liked the look of:

  * [jQuery sparklines](http://www.omnipotent.net/jquery.sparkline/) which I think look simply gorgeous and which follow the jQuery tradition of being incredibly easy to put on a page
  * [the JavaScript InfoVis Toolkit (JIT)](http://thejit.org/) which can be used to create some very attractive and interactive visualisations for hierarchical information

As a quick summary, I ended up with solutions that use an HTML page with [rdfQuery](http://code.google.com/p/rdfquery) code that pulls in static RDF/XML files and performs queries on them to create the particular formats that the two client-side libraries require.

The first one I'm going to talk about is a [visualisation of types of offences](http://www.jenitennison.com/visualisation/offences.html) using JIT. There's a screenshot below to give you a flavour, but you'd be better off actually [visiting the page](http://www.jenitennison.com/visualisation/offences.html) because it's interactive: mousing over and clicking on the labels enables you to navigate around the hierarchy.

<img alt="Visualisation of Criminal Damage offences" src="/blog/files/offences.jpg" width="100%" />

<!--break-->

The data for this visualisation comes from a [spreadsheet of notifiable offences](http://www.homeoffice.gov.uk/rds/pdfs09/countnotif09.xls), available amongst a bunch of interesting information about [counting rules for recording crime](http://www.homeoffice.gov.uk/rds/countrules.html). The columns are:

  * Home Office code, which is split into a major and minor part (eg 6/4)
  * Mode ('I' for indictable, 'E' for triable-either-way or 'S' for summary)
  * Max sentence (eg life, 15, 3m, fine)
  * Class (eg "Violence Against The Person")
  * Subclass (eg "Endangering Railway Passengers")
  * Offence (eg "Destroying, damaging etc. a Channel Tunnel train or the Tunnel system or committing acts of violence likely to endanger safety of operation")
  * Act(s) (eg "Channel Tunnel Act 1987 Sec 1(7)")

There are a couple of things that I find particularly interesting about this data.

First, it includes references to legislation! Since my day job at [TSO](http://www.tso.co.uk/) is currently all about publishing legislation as linked data, I find this really exciting! I haven't done anything with those links yet, but I aim to.

Second, you would have thought that the Home Office code would be tied to a particular Subclass or Offence, but it's not. The same Subclass can have multiple codes, but two Offences can have the same Home Office code. There doesn't seem to be a natural way of identifying the Offences, except through their (often long) descriptive name. The terminology for the Offence often comes straight out of a piece of legislation, but sometimes it's simply common law.

On the other hand, the offence Classes have reasonably short labels like "Burglary" and "Drug Offences" which can be turned into URIs like:

    http://www.jenitennison.com/data/scheme/offence/drug-offences

The fact that Class-Subclass-Offence defines a hierarchy of concepts led me to think that [SKOS](http://www.w3.org/TR/skos-primer/) would be a good ontology to use to model it. The Classes and Subclasses can be plain old `skos:Concept`s but the Offences need to have their own type so that extra information, such as the maximum sentence that applies to the offence, can be associated with it.

So if you look at [http://www.jenitennison.com/data/scheme/offence/drug-offences](http://www.jenitennison.com/data/scheme/offence/drug-offences) you'll see RDF/XML that includes the triples:

    <http://www.jenitennison.com/data/scheme/offence/drug-offences>
      a skos:Concept ;
      skos:topConceptOf <http://www.jenitennison.com/data/scheme/offence/> ;
      skos:prefLabel "Drug Offences"@en ;
      skos:narrower
        [ 
          a skos:Concept ;
          skos:inScheme <http://www.jenitennison.com/data/scheme/offence/> ;
          skos:broader <http://www.jenitennison.com/data/scheme/offence/drug-offences> ;
          skos:prefLabel "Trafficking in controlled drugs"@en ;
          skos:narrower
            [
              a crime:Offence ;
              skos:inScheme <http://www.jenitennison.com/data/scheme/offence/> ;
              skos:prefLabel "Manufacturing a scheduled substance"@en ;
              crime:maxSentence "P14Y"^^xsd:yearMonthDuration
            ],
            [
              a crime:Offence ;
              skos:inScheme <http://www.jenitennison.com/data/scheme/offence/> ;
              skos:prefLabel "Supplying a scheduled substance to another person"@en ;
              crime:maxSentence "P14Y"^^xsd:yearMonthDuration
            ],
            ...
        ],
        [
          a skos:Concept ;
          skos:inScheme <http://www.jenitennison.com/data/scheme/offence/> ;
          skos:broader <http://www.jenitennison.com/data/scheme/offence/drug-offences> ;
          skos:prefLabel "Possession of controlled drugs"@en ;
          skos:narrower
            ...
        ],
        ...

You'll notice that I've used blank nodes in the above rather than constructing an identifier for each Subclass or Offence. This makes things simpler because it means I can easily publish the dataset as a few flat files. An alternative would have been to use hash URIs, I suppose, but anyway this is the way I went. The (big) disadvantage is that it means the individual offences themselves aren't referenceable. So I might work on that, especially if I migrate the data over to data.gov.uk rather than just using it to try out a visualisation.

The URI for the concept scheme is [http://www.jenitennison.com/data/scheme/offence/](http://www.jenitennison.com/data/scheme/offence/). The slash on the end is entirely the result of trying to make Apache serve the static files correctly. As it is, I have one RDF/XML file for each Class of offence, plus an `index.rdf` within the same (`offence`) directory, with the `.htaccess` file:

    AddType application/rdf+xml .rdf
    DirectoryIndex index.rdf
    RewriteEngine On
    RewriteRule ^([^\.]+)$ $1.rdf [L]

The concept scheme file itself contains a list of the top concepts in the scheme (the Classes) and their labels. This serves as a useful entry point to the data.

So to the code. To create the visualisation, I needed to construct a Javascript structure that adhered to the [JIT Input JSON Structure](http://thejit.org/docs/files/Loader-js.html#Loader.loadJSON). Basically, each "node" within the visualisation needed to have an `id`, a `name` and a number of `children`. This structure needed to be constructed from the RDF/XML for a particular offence Class, ie that held within a particular RDF/XML document. The RDF/XML document can be accessed using the standard [`$.get()` jQuery method](http://docs.jquery.com/Ajax/jQuery.get#urldatacallbacktype). This passes the DOM for the document into the callback function passed as the third argument, which can then invoke [rdfQuery's `$.rdf.load()` method](http://www.jenitennison.com/rdfquery/symbols/jQuery.rdf.html#load) to load the triples encoded in the RDF/XML into an rdfQuery object that can then operate over those triples.

Here's the relevant part of the code, in which `view` is the URI for the particular offence class and `ht` is a JIT HyperTree instance:

    $.get(view, null, function (rdfXml) {
      var rdf, offences = {};
      rdf = $.rdf()
        .load(rdfXml)
        .prefix('skos', 'http://www.w3.org/2004/02/skos/core#')
        .prefix('crime', 'http://www.jenitennison.com/data/ontology/crime#');
      rdf
        .where('<' + view + '> skos:prefLabel ?label')
        .each(function () {
          offences.id = view;
          offences.name = this.label.value;
          offences.data = {
            '$color': '#0CC',
            'type': 'class'
          };
          offences.children = rdf
            .where('<' + view + '> skos:narrower ?subclass')
            .where('?subclass skos:prefLabel ?label')
            .map(function () {
              return {
                id: this.subclass.id,
                name: this.label.value,
                data: {
                  'type': 'subclass'
                },
                children: rdf
                  .where(this.subclass + ' skos:narrower ?offence')
                  .where('?offence skos:prefLabel ?label')
                  .where('?offence crime:maxSentence ?sentence')
                  .map(function () {
                    var sentence;
                    if (this.sentence.datatype.toString() === 'http://www.w3.org/2001/XMLSchema#token') {
                      sentence = this.sentence.value;
                    } else if (this.sentence.value > 12) {
                      sentence = this.sentence.value / 12 + ' years';
                    } else {
                      sentence = this.sentence.value + ' months';
                    }
                    return {
                      id: this.offence.id,
                      name: this.label.value,
                      data: {
                        'type': 'offence',
                        'sentence': sentence
                      },
                      children: []
                    };
                  })
                  .get()
              };
            })
            .get();
        });
      ht.loadJSON(offences);
      ht.refresh();
    }, 'xml');

You can look at the rest of the code simply by viewing source on [`offences.html`](http://www.jenitennison.com/visualisation/offences.html) if you want to. It's mostly the same as the [HyperTree animation example](http://thejit.org/Jit/Examples/Hypertree/example1.html) but with a bit of refactoring particularly to add some jQuery goodness.

Some random thoughts having done this:
  
  * rdfQuery is really good to use, even if I do say so myself. It provides a very flexible way of creating data structures based on RDF accessed from elsewhere, particularly because you have the full power of Javascript at your fingertips.
  
  * JIT itself is OK to work with, though it doesn't have the ease of use that it could have. The visualisation's reasonably attractive, but my attempts to do clever things with the size of nodes to reflect the severity of the sentence proved fruitless.

  * The HyperTree visualisation works far better for smallish hierarchies (eg for [Criminal Damage](http://www.jenitennison.com/visualisation/offences.html?offences=http%3A%2F%2Fwww.jenitennison.com%2Fdata%2Fscheme%2Foffence%2Fcriminal-damage)) than for large ones (eg [Violence Against The Person](http://www.jenitennison.com/visualisation/offences.html?offences=http%3A%2F%2Fwww.jenitennison.com%2Fdata%2Fscheme%2Foffence%2Fviolence-against-the-person) or, if you have the patience, [Other Offences](http://www.jenitennison.com/visualisation/offences.html?offences=http%3A%2F%2Fwww.jenitennison.com%2Fdata%2Fscheme%2Foffence%2Fother-offences)).

  * The Offence hierarchy itself is a bit of a mess. There are 738 'Other Offences' compared with 453 offences categorised within the other Classes, some of which contain only a handful of Offences. If this visualisation shows anything, it's how disorganised the offences are. Even more so if you take into account some of the other data that's been made available which I'll post about another time and shows a completely different classification. I wonder if there's data or other visualisations that would help identify where it could be rationalised.
  
  * The data is also out of date. I was surprised to see that it said that under the Piracy Act 1837 Section 2, Piracy with violence (one of the many 'Other Offences') still attracted a death penalty. But looking at the [relevant Section on the Statue Law Database](http://www.statutelaw.gov.uk/documents/1837/88/ukpga/c88/2) it appears that the death penalty was replaced with life imprisonment by [Section 36 of the Crime and Disorder Act 1998](http://www.statutelaw.gov.uk/content.aspx?LegType=All+Legislation&searchEnacted=0&extentMatchOnly=0&confersPower=0&blanketAmendment=0&sortAlpha=0&PageNumber=0&NavFrom=0&parentActiveTextDocId=1570287&ActiveTextDocId=1570337&filesize=10394). Getting better links into the legislation itself might help identify similar problems with the offence data.

  * I don't know how easy it would have been to create this visualisation if I hadn't been hosting the data myself. Danny Ayers put together a helpful post recently in which he listed the various ways of [getting around the restrictions in doing cross-domain Ajax](http://blogs.talis.com/n2/archives/770), which I'll no doubt draw on if and when I need to do that.
