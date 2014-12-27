---
layout: drupal-post
title: ! 'XSLT 2.0 Q&A: Linking elements in different documents'
created: 1200677594
tags:
- xslt
---
The first of what will probably become a series of posts where I answer publicly questions that people post me privately (with permission, of course)...

> How should I model (and store) data for Courses, while being able to pull info about a Course into a particular context (a Semester or Curriculum)?

> I'm not quite sure how to do this in terms of writing the schema (and consequently the XML), and/or how to connect it with XSL (if that is appropriate).  My experience with XSLT is limited to pretty much straight templates, and I've never cross-referenced two nodesets and used the result to provide a different output before.

The important thing is that within whatever XML you use, you have identifiers of some description that you can use to work out what a particular element means. The simplest and most general purpose identifiers are `xml:id` attributes, but they're a bit limited because they have to be legal IDs.

If you have something like a course that's identified by a number then it makes more sense to use the number of the course as the identifier; that can't live in an xml:id attribute, so you have to use some other attribute (eg `number` for it). (You can use an element instead of an attribute, of course, but identifiers are usually metadata, and metadata should usually be an attribute unless it's structured.)

You might have something that is actually uniquely identified by a combination of values. For example, a course might be identified by the department that offers the course plus the number identifying the course; it might be possible for two courses to have the same number, but be different courses, offered by different departments. Again, ultimately all that's really important is that it's possible to identify the department from the course, but the identifier itself might be on the element representing the course or on one of its ancestors, it doesn't really matter.

In the XSLT, the first task is to pull in all the documents that hold the information you want to use and store them as global variables:

    <xsl:variable name="curriculum" as="document-node()"
      select="document('curriculum.xml')" />
    <xsl:variable name="transcript" as="document-node()"
      select="document('transcript.xml')" />
    <xsl:variable name="database" as="document-node()"
      select="document('database.xml')" />

Then you should set up keys that will create indexes of the information in your documents based on their identifier(s). A simple key would look like:

    <xsl:key name="departments" match="dept" use="@xml:id" />

The `name` attribute is a name for the key; you can call it anything you like, but for identifiers I usually just use the plural of a noun for the thing I'm identifying. The `match` attribute is a pattern that matches the elements that you're indexing (don't forget namespaces, if you have them). The `use` attribute holds an XPath that should return a value for a given node that you're indexing, in the above case it's the value of the `xml:id` attribute on the `<dept>` element.

For elements that use a combination of values as an identifier, you can use the `concat()` function to create a unique value that combines the identifying values. For example, if your XML looks like:

    <courses dept="CMSC">
      <course number="131">...</course>
      <course number="198W">...</course>
      <course number="434">...</course>
    </courses>

then you could index each course by its department and number with:

    <xsl:key name="courses" match="course" use="concat(../@dept, ':', @number)" />

It's not really necessary in this case, but I've put a separator in the `concat()` call out of habit as it helps prevent problems such as something identified as `'a' + 'bc'` being given the same identifier as something identified through `'ab' + 'c'`.

Note that the keys don't indicate which document the information is held in. It's only when you *call* the key that you say which document you want to use. For example:

    key('courses', 'CMSC:198W', $curriculum)

would pull out the `<course>` element whose parent had a `dept` attribute equal to `'CMSC'` and  a `number` attribute with the value `'198W'` from the document held in the `$curriculum` variable. (This used to be harder to manage in XSLT 1.0, when there wasn't a third argument; without the third argument, the XSLT processor looks in the document you're currently in.)

You can just call the `key()` function directly, but if you're using XSLT 2.0 then I'd suggest wrapping it in a function like this:

    <xsl:function name="my:course" as="element(course)">
      <xsl:param name="dept" as="xs:string" />
      <xsl:param name="number" as="xs:string" />
      <xsl:variable name="identifier" select="concat($dept, ':', $number)" />
      <xsl:sequence select="key('courses', $identifier, $curriculum)" />
    </xsl:function>

This means you can use

    my:course('CMSC', '198W')

to locate the `<course>` element you're after.

Of course, most of the time you won't have fixed values for the arguments for that function: you'll have some XML that refers to the course in its own way. For example, you might have:

    <semester season="fall" year="2007">
      <course dept="ARTT" number="210" />
      <course dept="INFM" number="210" />
    </semester>

and want to make a list of the titles of the courses. You could do this with:

    <xsl:template match="course">
      <li>
        <xsl:apply-templates select="my:course(@dept, @number)/title" />
      </li>
    </xsl:template>

Just a final thought: if you have control over it, it's useful to make a clear distinction between elements that define information and elements that reference those definitions. One way of doing that is to name them differently (eg `<course>` and `<courseRef>`) or make sure that they have different sets of attributes (eg `number` and `numberRef`). Using the name of an element can be more useful because you can use that when you're defining the types of parameters and return values. For example:

    <xsl:function name="my:courses" as="element(course)+">
      <xsl:param name="semester" as="element(semester)" />
      <xsl:variable name="courseRefs" as="element(courseRef)+"
        select="$semester/courseRef" />
      <xsl:sequence select="$courseRefs/my:course(@dept, @number)" />
    </xsl:function>
