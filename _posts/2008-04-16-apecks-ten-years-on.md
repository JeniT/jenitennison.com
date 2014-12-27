---
layout: drupal-post
title: APECKS, ten years on
created: 1208378083
tags:
- web
- ontologies
- life
---
Roughly ten years ago, I was attending [KAW'98][1]. I remember that conference as one of the best weeks of my life. I had [great][3] [company][4]. I saw [scenery like I'd never seen before][5]. I presented [my PhD work][2] for the first time to people who were (at least politely) interested in it. And I learned a lot, both from the presentations and less formal discussions.

(I remember driving back to Nottingham when we returned; a rainbow appeared in front of us, seeming to arch over our destination in a perfect finale.)

[1]: http://ksi.cpsc.ucalgary.ca/KAW/KAW98/KAW98Proc.html "Proceedings of KAW'98"
[2]: http://ksi.cpsc.ucalgary.ca/KAW/KAW98/tennison/ "KAW'98: APECKS: A Tool to Support Living Ontologies"
[3]: http://users.ecs.soton.ac.uk/nrs/ "University of Southampton: Nigel Shadbolt"
[4]: http://www.louisecrow.com/blog/ "Louise Crow"
[5]: http://en.wikipedia.org/wiki/Lake_Louise,_Alberta "Lake Louise"

Looking back at that paper is like looking at my past generally is: much of it makes me cringe, but parts of it are surprisingly good. What's interesting is that if you swap a few terms for modern buzzwords, it's still a pretty neat idea. It's also amazing how far we've come -- how much has become common-place -- in just ten years.

<!--break-->

In modern terms, what I did was develop web-based [social software][6], called <acronym title="Adaptive Presentation Environment for Collaborative Knowledge Structuring">APECKS</acronym>, for ontology creation. The idea was that people would create their own ontologies (either from scratch or based on others), and the system would find similarities and differences between them, with the aim of starting conversations about and sharing knowledge.

[6]: http://en.wikipedia.org/wiki/Social_software "Wikipedia: Social software"

APECKS was built on top of a [web application framework][7] written in a [dynamic programming language][8]. We didn't have [Ruby on Rails][9] in those days: I turned a MOO (a text-based virtual reality) into a HTTP server (with caching and everything!) and that formed the basis of the application.

[7]: http://en.wikipedia.org/wiki/Web_application_framework "Wikipedia: Web application framework"
[8]: http://en.wikipedia.org/wiki/Dynamic_programming_language "Wikipedia: Dynamic programming language"
[9]: http://en.wikipedia.org/wiki/Ruby_on_Rails "Wikipedia: Ruby on Rails"
[10]: http://en.wikipedia.org/wiki/MOO "Wikipedia: MOO"

APECKS was designed to use (lowercase) web services. It used [one][13] for some of the complex ontology comparison that it needed to do. [RDF was nowhere near done][11]; OWL not even in a twinkle in its parents' eyes: nowadays, you'd build around those formats, which fit fairly well onto the [KIF][12]-based formalism that APECKS used. (The lack of a standard way to make the captured knowledge available was one of the reasons I got interested in XML -- we've just celebrated *that* 10-year anniversary too.)

[11]: http://www.w3.org/TR/1998/WD-rdf-syntax-19980216/ "W3C: RDF Working Draft from February 1998"
[12]: http://en.wikipedia.org/wiki/Knowledge_Interchange_Format "Wikipedia: Knowledge Interchange Format"
[13]: http://tiger.cpsc.ucalgary.ca/ "WebGrid III"

APECKS captured change history and design rationale as well as supporting unstructured communication between users. It didn't provide feeds because, guess what, [feeds hadn't been invented yet][14]. If I were doing it today, they would be a major feature.

[14]: http://en.wikipedia.org/wiki/RSS_(file_format) "Wikipedia: RSS"

APECKS didn't do [REST][15] properly, but that concept wasn't around either! APECKS was also rather formal and uninventive in getting knowledge out of people (although it did use those knowledge-acquisition techniques that are automatable, such as card sorts). Now, you could make the interface so much better, because now we have [AJAX][16].

[15]: http://en.wikipedia.org/wiki/Representational_State_Transfer "Wikipedia: Representation State Transfer"
[16]: http://en.wikipedia.org/wiki/AJAX "Wikipedia: AJAX"

Part of me wants to update it. The semantic web is going to happen, and we're going to need tools that help people share and link together the ontologies that they create. Tools that help people create ontologies without being semantic-web experts. 

But I've been there, and done that, and anyway I'm sure that today's students are creating applications that are much more innovative.
