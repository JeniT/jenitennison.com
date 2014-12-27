---
layout: drupal-post
title: ! 'Web 2.0 Project: Using Atom and XML with Graph Data Structures'
created: 1188763056
tags:
- xml
- atom
---
[A Ruby on Rails specialist friend][1] and I are building a Web 2.0 application. I would say it's "social networking for the dead" except that I doubt that description would be attractive to most people (my ex-Goth [defacto][2] being a rare exception), and it can be for the living too. It's a bit like [all][3] [those][4] [genalogy][5] websites, except that our focus is on people's social relationships as well as their familial ones.

(I should say that this is all very casual. We're both fitting it in around our other responsibilities, and are mainly interested in working together, learning new things, and trying out all the best practices that everyone keeps talking about. So don't think I'm becoming a dotcom entrepreneur or anything. Its got a very Web 2.0 name, and I'm only not telling you in case you start hitting our servers. We're nowhere near ready for visitors.) 

[1]: http://www.louisecrow.com/blog/ "Louise Crow's blog"
[2]: http://en.wikipedia.org/wiki/Domestic_partnership "Wikipedia: domestic partner/common law husband/father of my children etc. etc."
[3]: http://www.ancestry.com/ "ancestry.com"
[4]: http://www.familypursuit.com/ "familypursuit.com"
[5]: http://www.geni.com/ "geni.com"

<!--break-->

We're using the [Gentech data model][6] as the basis for the application (though I expect that we'll tweak it a bit). You don't really need to know anything about it to follow what I'm talking about here. The Gentech data model is very much a relational model. They might call it a logical model, but for anyone who *isn't* a database head, it's a physical model. That's fine; we're storing our data in a database, so a relational model for that is great.

In the Rails world, the model that Rails is object-oriented rather than relational. So there's a certain amount of mapping from the relational world into the OO world, in particular eliding the tables that are created simply for normalisation purposes. Making that mapping is one thing that Rails is very good at, of course.

Then we're into the worlds that I'm particularly interested in. One of our goals is to use [Atom][7] as an API, on the basis that it's a fairly generic way of packaging things (entries) and lists-of-things (feeds) with a bunch of metadata. Plus, the [Atom Publication Protocol][8] shows you how to do RESTful applications right.

The trouble, [as others][9] [have found][10] is that Atom is designed for a flattish structure, in which you have things, and a list of things. Like blog posts and feeds of posts, or pictures and feeds of pictures. But the model that we're starting from is relational, or object-oriented, or anyway it's a **graph**. And that makes things more complicated.

The first steps are pretty obvious. Objects are equivalent to entries, and lists of objects equivalent to feeds. So every object has its own URL, and every significant feed has its own URL too. There's the obvious `http://www.example.com/people/DarwinC01` for a person, and `http://www.example.com/people/` for a feed of people, but also `http://www.example.com/people/DarwinC01/events/` for events that are related to a particular person. An entry's content is an XML document that describes the equivalent object. It has attributes and children to represent the properties from the OO model (columns in the database tables).

Atom defines a bunch of metadata that you can associate with the content in an entry. These are:

  * id
  * title
  * summary (optional, as long as there's textual or XML content)
  * updated
  * published (optional)
  * category (multiple, optional)
  * source (optional)
  * author (multiple, optional as long as there's a source that specifies one or the entry's in a feed that specifies one)
  * contributor (multiple, optional)
  * link (multiple, optional as long as there's some content)
  * rights (optional, defaults to the feed's rights)
  * extension elements (optional)

The metadata properties need to be used to indicate who created/updated the object and when. This gets confusing because some of the information in our system is likely to be *about* content that has authors and publishing dates and so on: the Gentech data model is strong on documenting the sources of information about people you're reasearching. Even when documenting the source of some information, the Atom metadata should still be metadata about that object in our data model.

The set of Atom metadata does indicate a place where we're going to want to tweak the Gentech data model though: every object should have metadata associated with it, at the very least an updated date, to populate the Atom metadata fields. Also, we need to identify the property of each object that is used in the `<atom:title>`, though the title can be something generic if there isn't an obvious one.

Now the question that's vexing me: how should we represent relationships to other objects/entries? Let's take the example of documenting [Charles Darwin's voyage on HMS Beagle][11]. It goes something like this:

    <atom:entry>
      ...
      <atom:content type="application/xml">
        <passenger>
          <source href="http://www.aboutdarwin.com/voyage/voyage01.html" />
          ...
        </passenger>
      </atom:content>
    </atom:entry>

The `<evr:passenger>` element needs to reference a person and a voyage (event), to say that Darwin was a passenger on the voyage.

Here are the options, I think:

 1. Use `<atom:link>` within the `<atom:entry>`, with a URL in `rel` that indicates the kind of relationship  

	    <atom:entry xml:base="http://www.example.com">
	      ...
	      <atom:link rel="/link-relationships/assertion-persona"
	                 href="/persona/DarwinC01" />
	      <atom:link rel="/link-relationships/assertion-event"
	                 href="/events/BeagleVoyage" />
	      <atom:content type="application/xml">
	        <passenger>
	          <source href="http://www.aboutdarwin.com/voyage/voyage01.html" />
	        </passenger>
	      </atom:content>
	    </atom:entry>

 2. Use extension elements within the `<atom:entry>`
 
	    <atom:entry xml:base="http://www.example.com">
	      ...
	      <persona href="/persona/DarwinC01" />
	      <event href="/events/BeagleVoyage" />
	      <atom:content type="application/xml">
	        <passenger>
	          <source href="http://www.aboutdarwin.com/voyage/voyage01.html" />
	        </passenger>
	      </atom:content>
	    </atom:entry>
 
 3. Use child elements in the object's XML, referencing the URLs of the related objects
 
	    <atom:entry xml:base="http://www.example.com">
	      ...
	      <atom:content type="application/xml">
	        <passenger>
	          <source href="http://www.aboutdarwin.com/voyage/voyage01.html" />
		      <persona href="/persona/DarwinC01" />
		      <event href="/events/BeagleVoyage" />
	        </passenger>
	      </atom:content>
	    </atom:entry>

 4. Use child elements in the object's XML, embedding the related objects' Atom entry or feed
 
	    <atom:entry xml:base="http://www.example.com">
	      ...
	      <atom:content type="application/xml">
	        <passenger>
	          <source href="http://www.aboutdarwin.com/voyage/voyage01.html" />
	          <persona>
	            <atom:entry>
	              ...
	              <atom:title>Charles Darwin</atom:title>
	              <atom:content>
	                <persona>
	                  <name>Charles Darwin</name>
	                  ...
	                </persona>
	              </atom:content>
	            </atom:entry>
	          </persona>
		      <event>
		        <atom:entry>
		          ...
		          <atom:title>Beagle Voyage</atom:title>
		          <atom:content>
		            <event>
		              <name>Beagle Voyage</name>
		              <date-range>
		                <date>1831-12-27</date>
		                <date>1836-10-02</date>
		              </date-range>
		              ...
		            </event>
		          </atom:content>
		        </atom:entry>
		      </event>
	        </passenger>
	      </atom:content>
	    </atom:entry>

 5. Use child elements in the object's XML, embedding the related objects' XML content
 
	    <atom:entry xml:base="http://www.example.com">
	      ...
	      <atom:content type="application/xml">
	        <passenger>
	          <source href="http://www.aboutdarwin.com/voyage/voyage01.html" />
              <persona>
                <name>Charles Darwin</name>
                ...
              </persona>
		      <event>
                <name>Beagle Voyage</name>
                <date-range>
                  <date>1831-12-27</date>
                  <date>1836-10-02</date>
                </date-range>
		        ...
		      </event>
	        </passenger>
	      </atom:content>
	    </atom:entry>

I don't think that there's any point in using an extension element (#2), given that using `<atom:link>` (#1) situates the information in the same place in a more standard way.

Embedding information (as in #4 and #5) is a good thing because it means fewer requests to the server in order to get some useful information. Providing access to Atom feeds (as in #1, #3 and #4) is a good thing because it means you can get metadata about who created the refenced objects, and additional information about them. So #4 is good, since it does both these things, but I don't like embedding Atom in the XML because it's a lot of extra weight in the XML (making it harder to read/process).

In fact, #1, #3 and #5 aren't mutually exclusive. It's possible to add relevant `<atom:link>`s to the metadata, reference the URLs of the other objects *and* embed their content at the same time:

	    <atom:entry xml:base="http://www.example.com">
	      ...
	      <atom:link rel="/link-relationships/assertion-persona"
	                 href="/persona/DarwinC01" />
	      <atom:link rel="/link-relationships/assertion-event"
	                 href="/events/BeagleVoyage" />
	      <atom:content type="application/xml">
	        <passenger>
	          <source href="http://www.aboutdarwin.com/voyage/voyage01.html" />
		      <persona src="/persona/DarwinC01">
                <name>Charles Darwin</name>
                ...
              </persona>
		      <event src="/events/BeagleVoyage">
                <name>Beagle Voyage</name>
                <date-range>
                  <date>1831-12-27</date>
                  <date>1836-10-02</date>
                </date-range>
		        ...
		      </event>
	        </passenger>
	      </atom:content>
	    </atom:entry>
 
We embed the core information for easy access (#5), reference its original URI for more details (#3), and then we may as well add the `<atom:link>`s (#1) so that run-of-the-mill Atom readers who have no knowledge about our content can do something useful. We *don't* get the metadata embedded in the XML, but it's retrievable: a client could use the entry as a kind of "low resolution" information set, which they can add to by retrieving the "high resolution" Atom for the referenced objects, via their URLs, as necessary.

The problem with using an embedding method rather than a referencing method is that the object model is a graph, not a hierarchy. So you can't *always* embed an object's XML: sometimes you have to only use a reference (#3 without #5) to avoid getting into an endless loop of repeated information. As a publisher, sometimes you might *want* to only use a reference, because the information is only tangential to the main subject of the original entry. I'm imagining that we might serve several different Atom entries for the same object, with different amounts of detail. Maybe.

As an author, creating this XML, you can't include a reference if you're constructing XML (either in code or by hand) for new objects because they won't have URLs yet. Therefore, for the purpose of *creating* objects as defined by the Atom Publishing Protocol, you'll use embedded XML (#5) with references to existing objects if necessary. The resource returned will include the references for all the created objects. When updating, you'll want to include as little as possible aside from the updated information, I imagine (small updates being less prone to clashes than large ones). 

By the way, I'm using `src` attributes when the information is embedded and `href` attributes when the information is purely referenced (or almost purely referenced; the referencing elements might still have some content equivalent to the `<atom:title>` element, in the interests of presenting a clickable link).

So that's the plan at the moment, but we're open to suggestions. Anybody?

[6]: http://www.ngsgenealogy.org/ngsgentech/projects/Gdm/Gdm.cfm "GENTECH genealogical data model"
[7]: http://en.wikipedia.org/wiki/Atom_(standard) "Wikipedia: Atom"
[8]: http://www.ietf.org/internet-drafts/draft-ietf-atompub-protocol-17.txt "Atom Publishing Protocol"
[9]: http://code.google.com/apis/gdata/overview.html "Google Data (GData) API"
[10]: http://www.25hoursaday.com/weblog/2007/06/09/WhyGDataAPPFailsAsAGeneralPurposeEditingProtocolForTheWeb.aspx "Dare Obasanjo: Why GData/APP Fails as a General Purpose Editing Protocol for the Web"
[11]: http://www.aboutdarwin.com/voyage/voyage01.html "About Darwin: HMS Beagle Voyage"
