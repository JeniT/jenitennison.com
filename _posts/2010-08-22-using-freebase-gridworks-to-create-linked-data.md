---
layout: drupal-post
title: Using Freebase Gridworks to Create Linked Data
created: 1282515812
tags:
- linked data
- datagovuk
- provenance
- gridworks
---
When we encourage people to put their data on the web as linked data, the biggest question is "How?". There are so many "How?" questions to answer:

  * how do we choose what URIs to use for things?
  * how do we choose what vocabularies to use?
  * how do we handle changing data?
  * how do we tell people how the data was created?
  * how do we publish it?
  * how will other people know about it?

and, of course:

  * how do we create it?

<!--break-->

Our goal within the linked data part of data.gov.uk (and I know we haven't achieved it yet) is to both answer these questions and to make the answers as simple as possible. The answers to the questions *cannot* either require up-front knowledge of all possible types of data that might be published or depend on the availability of linked data for all the things we want to talk about. It *cannot* require registration at centralised services. It *cannot* require everyone to do everything in the same way or at the same pace.

We must take adopt an approach that encourages people to make their data available in forms that are easier for other people to pick up and use **because they see the benefits for them** and their stakeholders and because the effort of doing so is not too high to bear. We must grow, adapt and evolve incrementally. If linked data eventually wins, it will be due to its benefits, not to faith.

Anyway, enough rant. The point of this blog post is to talk about one of the answers to the 'How do we create it?' question: using [Freebase Gridworks](http://code.google.com/p/freebase-gridworks/). For those who haven't encountered it, Gridworks is an incredibly useful application that enables you to easily analyse, clean and manipulate tabular data. In a few steps, it can be used to generated linked datasets which can then be published on the web just like any other file, ready for other people to reuse without jumping through hoops. I'm going to assume that you can [download it](http://code.google.com/p/freebase-gridworks/wiki/Downloads?tm=2) and [install it](http://code.google.com/p/freebase-gridworks/wiki/GettingStarted) following the instructions provided on the Gridworks site.

In this post, I'm going to talk about how to use Gridworks to generate linked data, using an example of local government spending data from [Windsor and Maidenhead council](http://www.rbwm.gov.uk/web/finance_payments_to_suppliers.htm). Like a good train journey, there's quite a lot to see along the way.

*Note: Many thanks to Dave Reynolds for his work on this data and comments on an earlier version of this post.*

## Importing Data ##

The first step is to import the data into Gridworks. If you just take the Windsor & Maidenhead data and import it directly, you'll get a single not-very-useful column as shown in the following screenshot:

<img src="/blog/files/bad-import.jpg" title="Bad import into Gridworks" style="width: 100%" />

If you look at the spreadsheet in a normal spreadsheet programme then you'll see why. Like a lot of spreadsheets created by normal people, who want to create something readable by human beings rather than computers, it has some extra lines at the top to explain what the spreadsheet contains, as shown in the following screenshot:

<img src="/blog/files/spreadsheet.jpg" title="Original spreadsheet" style="width: 100%" />

Fortunately, Gridworks lets us easily skip over these first few lines. When you import the data, put the number `1` in the box for "Ignore X initial non-blank lines", as shown here:

<img src="/blog/files/import-dialog.jpg" title="Import dialog" style="text-align: center" />

(You need the number `1` because although there are three lines before the table really starts, the second two of those are blank.)

That done, the data should look a lot more useful, as shown in the following screenshot:

<img src="/blog/files/good-import.jpg" title="Good import into Gridworks" style="width: 100%" />

## Cleaning Data ##

The next thing to do is to explore the data a bit to get a handle on what's there and work out whether any cleaning or rationalisation is necessary to improve its quality.

With columns that hold names, such as 'Directorate', 'Service' or 'Supplier Name', you're looking for slight misspellings caused by bad data entry. Gridworks helps you find these by creating a list of the distinct values for a particular column and telling you how many instances there are of each. Use the arrow at the side of the column name to pull down the menu, then choose `Facet > Text Facet` to create this list, as shown here:

<img src="/blog/files/facet-menu.jpg" title="Choosing from the facet menu" style="text-align: center" />

Once you've chosen `Text Facet`, the list pops up on the left hand side of the window. You can click on these to filter the table to contain just those rows that have that value for that column, but you can then scan through this to spot any places where there looks to be a typo or two entries that should really be the same. For example, the Services list holds both 'Libraries & Information Services' and 'Library & Information Services', as shown here:

<img src="/blog/files/services-list.jpg" title="Repetition in the Services list" style="text-align: center" />

It's unlikely that there are really two distinct services with such similar names, so we'd like to clean up this data by standardising on one name or another. You can quickly change all occurrences of one value to another using the `edit` option that appears just to the right of the value when you hover over it. This brings up a dialog that enables you to change all of those values to something else, as shown here:

<img src="/blog/files/edit-value-dialog.jpg" title="Editing a value across the spreadsheet" style="text-align: center" />

You can do something similar with numeric columns, such as the 'Amount excl vat £' column. This time choose `Numeric Facet` rather than `Text Facet` and you'll get a histogram up as shown here:

<img src="/blog/files/amount-facet.jpg" title="Amount histogram" style="text-align: center" />

This is useful for identifying outliers. If you grab the handle on the left of the histogram and move it to the centre, the rows will get filtered to only those that have an amount within that range. For example, moving it to only show rows between £500,000 and £1,500,000 shows that there are three payments of this size, all made by Children's Services to Wilmott Dixon Construction Limited, as shown in this screenshot:

<img src="/blog/files/high-value-transactions.jpg" title="High value transactions" style="width: 100%" />

Although these values are much higher than most of the others in the spreadsheet, they don't seem to be errors -- I guess a new school was being built or something -- so there's nothing to correct here, but it shows how numeric facets can be used to explore the data.

Another approach to exploring and cleaning the data is to use the clustering algorithms that are built into Gridworks to identify duplicates. To do this, pull down the column menu and this time choose `Edit Cells... > Cluster and Edit`, as shown in the following screenshot, this time for the 'Supplier Name' column:

<img src="/blog/files/edit-cells-menu.jpg" title="Choosing from the Edit Cells menu" style="text-align: center" />

This brings up a dialog that groups together values that look similar. In this case, 'Siemens plc' and 'Siemens PLC', as shown in the following screenshot:

<img src="/blog/files/cluster-dialog.jpg" title="Clustering values in a column" style="width: 100%" />

You can use this dialog to change all the similar values to a standard one. Check the `Merge` checkbox for the clusters of values that should be merged, edit the `New Cell Value` field to whatever standard value you want to adopt, and choose `Apply & Re-cluster` or simply `Apply & Close` to make the change.

You will often find that the default clustering algorithm (key collision/fingerprint) doesn't come up with any clusters as it's fairly conservative. It's worth playing around a bit with different algorithms to look for other duplicates by selecting other possibilities from the drop-down menus. For example, choosing the 'nearest neighbour' method with the Levenstein distance function and a radius of 2 (edits) results in four possible duplicates within the Suppliers list, as shown here:

<img src="/blog/files/levenstein-cluster.jpg" title="Clustering values with Levenstein distance" style="width: 100%" />

If you're not sure about whether the cluster is due to a typo or not, hover over the row and click on the `Browse this cluster` link that appears. That will bring up a separate window that will show you just the rows in the cluster, from which you should be able to make a judgement. For example, it's not clear whether 'Academia Ltd' is a typo for 'Academics Ltd' but browsing the cluster shows that the Cost Centre codes and the Types of the transactions are completely different for the two Suppliers, so they are probably different.

## Deriving Data ##

The next step is to derive some data from what we have within the spreadsheet. Since our goal is to produce linked data, the kind of derived data that we're interested in are URIs.

At this point we need to start making decisions about what URIs to use. If you look at the [list of spending data from Windsor and Maidenhead](http://www.rbwm.gov.uk/web/finance_payments_to_suppliers.htm), you'll see that there are a whole bunch of these spreadsheets. It would be really useful if we could tie these spreadsheets together by using the same URIs for the same things across the datasets. For that reason, the only URI that's going to be local to the dataset is the URI for each line (or data point if you like) itself. On the other hand, most of the things that are named here are going to be local to Windsor & Maidenhead: 'Abba Cars' may be sufficient to identify a single company within Windsor & Maidenhead, but certainly wouldn't be nationwide. So the URIs I'm going to create here are mostly going to be within the `www.rbwm.gov.uk` domain.

Here's the table of the columns and the associated URIs that I'm going to use. I should stress that this is just for example purposes, but I've used the following principles:

  * URIs for datasets are just like URIs for any other web document, but shouldn't have an extension because the data itself should be available in many formats
  * URIs for real-world things should have `/id` at the start of the path, and URIs for conceptual things should have `/def` at the start of their paths; both should result in a 303 redirection to a suitable web page

This is what we're doing within data.gov.uk, but it's an important principle of the web that different councils might well choose their own URI schemes, depending on the kind of technology support that they have, without any bad side-effects on the interpretation of the data.

<table>
  <thead>
    <tr>
      <th>Column</th>
      <th>URI pattern</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>(Dataset)</th>
      <td>http://www.rbwm.gov.uk/public/finance_supplier_payments_2010_q2</td>
    </tr>
    <tr>
      <th>(Row/ExpenditureLine)</th>
      <td>http://www.rbwm.gov.uk/public/finance_supplier_payments_2010_q2#{row-number}</td>
    </tr>
    <tr>
      <th>(Council)</th>
      <td>http://statistics.data.gov.uk/id/local-authority/00ME</td>
    </tr>
    <tr>
      <th>Directorate</th>
      <td>http://www.rbwm.gov.uk/id/directorate/{directorate-slug}</td>
    </tr>
    <tr>
      <th>Updated</th>
      <td>http://reference.data.gov.uk/id/day/{date}</td>
    </tr>
    <tr>
      <th>TransNo/Payment</th>
      <td>http://www.rbwm.gov.uk/id/transaction/{transaction-number}</td>
    </tr>
    <tr>
      <th>Service</th>
      <td>http://www.rbwm.gov.uk/id/service/{service-slug}</td>
    </tr>
    <tr>
      <th>Cost Centre</th>
      <td>http://www.rbwm.gov.uk/def/cost-centre/{cost-centre-code}</td>
    </tr>
    <tr>
      <th>Supplier Name</th>
      <td>http://www.rbwm.gov.uk/id/supplier/{supplier-slug}</td>
    </tr>
  </tbody>
</table>

As you can see, those of the columns that contain text fields have, as part of their URI, a ['slug'](http://en.wikipedia.org/wiki/Slug_\(production\)). This is a shortened, normalised value suitable for putting in a URI: basically ensuring that the string doesn't contain any punctuation or spaces. For example, 'Adult & Community Services' would turn into 'adult-community-services'.

Our first task will be to create these slugs. To do this, we'll create a new column based on the existing ones by choosing `Edit Column > Add Column Based on This Column ...` from the drop-down menu on the appropriate column:

<img src="/blog/files/edit-column-menu.jpg" title="Edit Column menu" style="text-align: center" />

Selecting this will bring up a dialog which will ask you to name the new column and then enter a formula to calculate the new value, as shown here:

<img src="/blog/files/create-slug.jpg" title="Edit Column menu" style="text-align: center" />

The default language for this formula is Gridworks' own, though there are other options available. To create the slug, we need to:

  1. turn the value to lower case
  2. replace all spaces with hyphens
  3. remove anything that isn't a letter, number, or hyphen
  4. replace all sequences of two hyphens with a single hyphen

This is done in two steps. The first three steps can be done using the formula:

    replace(replace(toLowercase(value), ' ', '-'), /[^-a-z0-9]/, '')

Gridworks helps by listing the original and resulting values for the first several rows of the spreadsheet, so that you can see whether it's working as expected. When you're happy, hitting `OK` creates the new column.

The last step (replacing all sequences of two hyphens with a single hyphen) can be done by editing the cells in the new column. Bring up the `Edit Cells... > Transform...` dialog using the menu:

<img src="/blog/files/edit-cells-menu-2.jpg" title="Edit Cells menu" style="text-align: center" />

and use the formula:

    replace(value, '--', '-')

then check the `Re-transform until no change` checkbox so that any pairs of hyphens are repeatedly replaced with single hyphens, as shown here:

<img src="/blog/files/transform.jpg" title="Edit Cells menu" style="text-align: center" />

The other tabs in the new column and edit cells dialogs are really helpful. The `History` tab lets you choose formulae that you've used before to use again. This is useful here because we want to create the slugs for the Service and Supplier Name in the same way. The `Help` tab lists all the functions that you can use within the formula.

Creating the URIs for the columns proceeds in the same way, except this time the formulae are more like:

    'http://www.rbwm.gov.uk/id/directorate/' + value

There are two that are slightly different. First, there's the URI for the date, which needs to be constructed from the date/time value held by Gridworks as follows. We can do this in two stages. First, to construct a new column called 'Date' to hold the formatted date:

    datePart(value, 'year') + '-' + 
    if (datePart(value, 'month') < 9, '0', '') + replace(datePart(value, 'month') + 1, '.0', '') + '-' + 
    if (datePart(value, 'day') < 10, '0', '') + datePart(value, 'day')

(note that the `datePart()` function returns a 0-based count for the month) and then to create the Date URI column based on this:

    'http://reference.data.gov.uk/id/day/' + value

Second, there's the URI for the row (an expenditure line) itself, which needs to be constructed using the row number. It's useful to construct it as a local URI (ie just the fragment) as this means the same code can be used to construct the column across different datasets, so it's just:

    '#' + rowIndex

## Exporting Data ##

Once the extra columns have been made, it's time to export data from Gridworks. While Gridworks makes it easy to export to CSV or into Freebase, it's also possible to export in any format you want using templates. Use the `Project` menu and choose `Export Filtered Rows > Templating ...`, as shown in the following screenshot:

<img src="/blog/files/project-menu.jpg" title="Project menu" style="text-align: center" />

Note that this will only export the rows that you currently have selected, so if you want to export everything, make sure that you deselect any facets that you've currently got selected.

Choosing the `Templating ...` option will open up a dialog that you can use to create whatever format you want. The default, as shown in the following screenshot, is JSON.

<img src="/blog/files/template-dialog-json.jpg" title="Templating dialog to create JSON" style="width: 100%" />

On the left are four fields:

  * **Prefix** is content that's put at the top of the exported data
  * **Row Template** is content that's generated for each row
  * **Row Separator** is content that's put between each row
  * **Suffix** is content that's put at the bottom of the exported data

One thing to be extremely careful of here is that any changes you made to the fields on the left here **will not be saved** when the dialog is closed. For that reason, it's a good idea to create your templates in a separate text file and copy and paste them in. Also note that the sample data on the right is only for the first set of rows, not for the whole spreadsheet.

We're going to generate Turtle using the template, so the next stage is to work out precisely what Turtle to generate. We've been working on small vocabulary for payment data based on the [Data Cube vocabulary](http://publishing-statistical-data.googlecode.com/svn/trunk/specs/src/main/html/cube.html) and that's what I'll use here, although it isn't quite complete and available yet as it will be. We'll start at the bottom, with the individual rows, and then add extra surrounding information as we go.

### Row Template ###

Within this data, each row corresponds to a `payment:ExpenditureLine` within the dataset. The expenditure lines can be organised into groups based on the `payment:Payment` that they're associated with, which is indicated through the 'TransNo' column in the database. Within the payment vocabulary we're using, we can assign individual expenditure lines to the payment using the `payment:expenditureLine` property.

The `payment:payer` of each `payment:Payment` is Windsor & Maidenhead council. The `payment:payee` is the 'Supplier' listed in the spreadsheet. The `payment:date` is the 'Updated' date.

Each individual line in the spreadsheet is a `payment:ExpenditureLine` which is associated with one of these payments. The `payment:expenditureCode` is the 'Cost Centre' and the actual `payment:amountExcludingVAT` is the 'Amount excl vat £' value. Some example Turtle for the first line is thus:

    <http://www.rbwm.gov.uk/public/finance_supplier_payments_2010_q2>
      qb:slice <http://www.rbwm.gov.uk/id/transaction/2650750> .
    
    <http://www.rbwm.gov.uk/id/transaction/2650750>
      a payment:Payment , qb:Slice ;
      rdfs:label "Transaction 2650750"@en ;
      qb:sliceStructure payment:payment-slice ;
      payment:transactionReference "2650750" ;
      payment:payer <http://statistics.data.gov.uk/id/local-authority/00ME> ;
      payment:payee <http://www.rbwm.gov.uk/id/supplier/1st-choice-d-b-driveways-limited> ;
      payment:date <http://reference.data.gov.uk/id/day/2010-04-09> ;
      payment:expenditureLine <http://www.rbwm.gov.uk/public/finance_supplier_payments_2010_q2#0> .
      
    <http://www.rbwm.gov.uk/public/finance_supplier_payments_2010_q2#0>
      a payment:ExpenditureLine , qb:Observation ;
      rdfs:label "Expenditure Line 0"@en ;
      qb:dataSet <http://www.rbwm.gov.uk/public/finance_supplier_payments_2010_q2> ;
      payment:expenditureCode <http://www.rbwm.gov.uk/def/cost-centre/LM05> ;
      payment:amountExcludingVAT 1875.00 .

That's the basic data for each line, but there's also some other information which should be brought out for each line:

  * the name of the payee
  * the date, year, month and day-of-month for the payment, which may help further analysis of the data
  * the meaning of the expenditure code (particularly its association to a particular service)

In each of these cases, pulling the information out from each line is going to lead to a lot of repetition, because the same payee, date and so on will be described in multiple lines, but we don't have any choice and we can tidy it up by removing duplicates afterwards. The Turtle for the first line will look like:

    <http://www.rbwm.gov.uk/id/supplier/1st-choice-d-b-driveways-limited>
      a org:Organization ;
      rdfs:label "1st Choice - D B Driveways Limited"@en .
    
    <http://reference.data.gov.uk/id/day/2010-04-09>
      a interval:CalendarDay ;
      rdfs:label "2010-04-09" ;
      time:hasBeginning <http://reference.data.gov.uk/id/gregorian-instant/2010-04-09T00:00:00> ;
      interval:ordinalYear 2010 ;
      interval:ordinalMonthOfYear 4 ;
      interval:ordinalDayOfMonth 9 .
    
    <http://reference.data.gov.uk/id/gregorian-instant/2010-04-09T00:00:00>
      a time:Instant ;
      time:inXSDDateTime "2010-04-09T00:00:00"^^xsd:dateTime .
    
    <http://www.rbwm.gov.uk/def/cost-centre/LM05>
      a rbwm:CostCentre , skos:Concept ;
      rdfs:label "Cost Centre LM05"@en ;
      rbwm:costCentreCode "LM05"^^rbwm:CostCentreCode ;
      rbwm:service <http://www.rbwm.gov.uk/id/service/magnet-leisure-centre> .
    
    <http://www.rbwm.gov.uk/id/service/magnet-leisure-centre>
      a rbwm:Service ;
      rdfs:label "Magnet Leisure Centre"@en ;
      rbwm:providedBy <http://www.rbwm.gov.uk/id/directorate/adult-community-services> .
    
    <http://www.rbwm.gov.uk/id/directorate/adult-community-services>
      a rbwm:Directorate ;
      rdfs:label "Adult & Community Services"@en ;
      org:unitOf <http://statistics.data.gov.uk/id/local-authority/00ME> ;
      rbwm:provides <http://www.rbwm.gov.uk/id/service/magnet-leisure-centre> .
    
    <http://statistics.data.gov.uk/id/local-authority/00ME>
      org:hasUnit <http://www.rbwm.gov.uk/id/directorate/adult-community-services> .

You'll see that in the last part of this I've introduced some properties and classes with a `rbwm:` prefix. These are for classes and properties that are here in this data, but aren't part of the payment vocabulary. The basic schema is:

    rbwm:CostCentre a rdfs:Class ;
      rdfs:label "Cost Centre"@en ;
      rdfs:comment "A cost centre."@en .
    
    rbwm:Service a rdfs:Class ;
      rdfs:label "Service"@en ;
      rdfs:comment "A service provided by the council."@en .
    
    rbwm:Directorate a rdfs:Class ;
      rdfs:label "Directorate"@en ;
      rdfs:comment "A directorate within the council"@en .
    
    rbwm:service a rdf:Property , owl:ObjectProperty ;
      rdfs:label "Service"@en ;
      rdfs:comment "The service associated with a particular cost centre."@en ;
      rdfs:domain rbwm:CostCentre ;
      rdfs:range rbwm:Service .
    
    rbwm:providedBy a rdf:Property , owl:ObjectProperty ;
      rdfs:label "Provided By"@en ;
      rdfs:comment "The directorate that provides this service."@en ;
      rdfs:domain rbwm:Service ;
      rdfs:range rbwm:Directorate .
    
    rbwm:provides a rdf:Property , owl:ObjectProperty ;
      rdfs:label "Provides"@en ;
      rdfs:comment "A service provided by this directorate."@en ;
      rdfs:domain rbwm:Directorate ;
      rdfs:range rbwm:Service .
    
    rbwm:costCentreCode a rdf:Property , owl:DatatypeProperty ;
      rdfs:label "Cost Centre Code"@en ;
      rdfs:comment "The code of this cost centre."@en ;
      rdfs:domain rbwm:CostCentre ;
      rdfs:range rbwm:CostCentreCode .
    
    rbwm:CostCentreCode a rdfs:Datatype ;
      rdfs:label "Cost Centre Code"@en ;
      rdfs:comment "A cost centre code consisting of two capital letters followed by two digits."@en .

This illustrates how individual councils might extend the information that they make available in RDF without having to seek any kind of prior agreement from anyone else. If, later on, a third party starts to make available ontologies for cost centres, services and directorates, Windsor & Maidenhead could start to link up their RDF with those more widely standardised classes and properties, with appropriate use of `rdfs:subClassOf` or `rdfs:subPropertyOf`.

Now we have an idea about what data we can extract for a single row, we can turn this into a Gridworks template. The templates are fairly straight forward. Wherever you want to insert a value from a particular column, you use the syntax `${Column Name}`. If you want to do any further processing, you can use the syntax `{{Formula}}` to insert the result of a calculation.

    <http://www.rbwm.gov.uk/public/finance_supplier_payments_2010_q2>
      qb:slice <${Transaction URI}> .
    
    <${Transaction URI}>
      a payment:Payment , qb:Slice ;
      rdfs:label "Transaction ${TransNo}"@en ;
      qb:sliceStructure payment:payment-slice ;
      payment:transactionReference "${TransNo}" ;
      payment:payer <http://statistics.data.gov.uk/id/local-authority/00ME> ;
      payment:payee <${Supplier URI}> ;
      payment:date <${Date URI}> ;
      payment:expenditureLine <http://www.rbwm.gov.uk/public/finance_supplier_payments_2010_q2${Line URI}> .
      
    <http://www.rbwm.gov.uk/public/finance_supplier_payments_2010_q2${Line URI}>
      a payment:ExpenditureLine , qb:Observation ;
      rdfs:label "Expenditure Line {{rowIndex}}"@en ;
      qb:dataSet <http://www.rbwm.gov.uk/public/finance_supplier_payments_2010_q2> ;
      payment:expenditureCode <${Cost Centre URI}> ;
      payment:amountExcludingVAT {{cells['Amount excl vat £'].value + 0}} .

Note that the last line here uses the expression `cells['Amount excl vat £'].value + 0` in order to ensure that every figure has a decimal place, which makes them into `xsd:decimal` values within the resulting RDF.

I won't do the rest of the row template here, though it's [available in full in a separate file](/blog/files/finance_supplier_payments_2010_q2_provenance.ttl).

The other parts of the template are easier to complete. The prefix needs to contain any namespace prefixes that are used within the RDF. It's also useful to put a base URI here and describe the dataset itself. The RDF for the dataset should contain a number of properties about the dataset as a whole. There are a number of levels at which the dataset can be described:

  * basic metadata such as its title and the license that it's available under
  * statistical metadata including what dimensions it has and how it's sliced
  * linked data metadata such as how this dataset links out to other linked datasets

The Turtle for this description is shown here:

    <http://www.rbwm.gov.uk/public/finance_supplier_payments>
      a void:Dataset ;
      void:subset <http://www.rbwm.gov.uk/public/finance_supplier_payments_2010_q2> .
    
    <http://www.rbwm.gov.uk/public/finance_supplier_payments_2010_q2>
      a payment:PaymentDataset , void:Dataset ;
      # basic metadata
      rdfs:label "Windsor & Maidenhead Supplier Payments where charge to specific cost centre is >= £500 for period April 2010 - June 2010"@en ;
      dct:license <http://data.gov.uk/id/licence> ;
      dct:temporal [
        # this time is retrieved from the Last-Modified date on the original spreadsheet
        time:hasBeginning <http://reference.data.gov.uk/id/gregorian-instant/2010-08-02T08:37:02>
      ] ;
      
      # statistical metadata
      qb:structure payment:payments-with-expenditure-structure ;
      qb:sliceKey payment:payment-slice ;
      payment:currency <http://dbpedia.org/resource/Pound_sterling> ;
      
      # linked data metadata
      void:exampleResource
        <http://www.rbwm.gov.uk/id/transaction/2650750> ,
        <http://www.rbwm.gov.uk/public/finance_supplier_payments_2010_q2#0> ;
      void:vocabulary payment: , qb: , rbwm: ;
      void:subset [
        a void:Linkset ;
        void:linkPredicate qb:slice ;
        void:subjectsTarget <http://www.rbwm.gov.uk/public/finance_supplier_payments_2010_q2> ;
        void:objectsTarget <http://www.rbwm.gov.uk/id/transaction> ;
      ] , [
        a void:Linkset ;
        void:linkPredicate payment:payer ;
        void:subjectsTarget <http://www.rbwm.gov.uk/id/transaction> ;
        void:objectsTarget <http://statistics.data.gov.uk/id/local-authority> ;
      ] , [
        a void:Linkset ;
        void:linkPredicate payment:payee ;
        void:subjectsTarget <http://www.rbwm.gov.uk/id/transaction> ;
        void:objectsTarget <http://www.rbwm.gov.uk/id/supplier> ;
      ] , [
        a void:Linkset ;
        void:linkPredicate payment:date ;
        void:subjectsTarget <http://www.rbwm.gov.uk/id/transaction> ;
        void:objectsTarget <http://reference.data.gov.uk/id/day> ;
      ] , [
        a void:Linkset ;
        void:linkPredicate payment:expenditureLine ;
        void:subjectsTarget <http://www.rbwm.gov.uk/id/transaction> ;
        void:objectsTarget <http://www.rbwm.gov.uk/public/finance_supplier_payments_2010_q2> ;
      ] , [
        a void:Linkset ;
        void:linkPredicate payment:expenditureCode ;
        void:subjectsTarget <http://www.rbwm.gov.uk/public/finance_supplier_payments_2010_q2> ;
        void:objectsTarget <http://www.rbwm.gov.uk/def/cost-centre> ;
      ] , [
        a void:Linkset ;
        void:linkPredicate rbwm:service ;
        void:subjectsTarget <http://www.rbwm.gov.uk/def/cost-centre> ;
        void:objectsTarget <http://www.rbwm.gov.uk/id/service> ;
      ] , [
        a void:Linkset ;
        void:linkPredicate rbwm:providedBy ;
        void:subjectsTarget <http://www.rbwm.gov.uk/id/service> ;
        void:objectsTarget <http://www.rbwm.gov.uk/id/directorate> ;
      ] , [
        a void:Linkset ;
        void:linkPredicate rbwm:provides ;
        void:subjectsTarget <http://www.rbwm.gov.uk/id/directorate> ;
        void:objectsTarget <http://www.rbwm.gov.uk/id/service> ;
      ] , [
        a void:Linkset ;
        void:linkPredicate org:hasUnit ;
        void:subjectsTarget <http://statistics.data.gov.uk/id/local-authority> ;
        void:objectsTarget <http://www.rbwm.gov.uk/id/directorate> ;
      ] , [
        a void:Linkset ;
        void:linkPredicate org:unitOf ;
        void:subjectsTarget <http://www.rbwm.gov.uk/id/directorate> ;
        void:objectsTarget <http://statistics.data.gov.uk/id/local-authority> ;
      ] .

## Provenance ##

I've described here, verbally, exactly what I've done in terms of the cleaning of the data, deriving new columns, and the template that I've used to create a Turtle rendition of the data in this spreadsheet. One of the things that we've worked hard on within data.gov.uk is finding ways of expressing this provenance information in RDF. There are two reasons for this:

  1. Providing provenance increases transparency and enables you to check the processing that the data has been through, increasing your trust in the data.
  2. Describing the process in sufficient detail for you to replicate that process enables you to modify and repeat the process, which both enables you to add value and to apply the same processing to your own situation, thus spreading best practice.

The basic provenance vocabulary that we're using within data.gov.uk is the [Open Provenance Model Vocabulary](http://code.google.com/p/opmv/). This vocabulary talks about Artifacts, Processes that create and use them, and Agents that control those processes. We've created an extension of this vocabulary specifically to help describe this kind of scenario, where a spreadsheet is processed using Gridworks and then exported using a template. I'll put this provenance information in a separate file simply because embedding provenance information, which includes a template, in the template itself gets us into nasty recursion issues.

As well as the template, there are two supplementary artifacts that we need to record the provenance of this data:

  * the Gridworks project itself
  * the JSON description of the set of operations performed by Gridworks

The first can be exported using the `Project` menu. The second is accessed through the `Undo/Redo` tab as shown in the following screenshot:

<img src="/blog/files/undo-redo.jpg" title="Undo/Redo tab" style="text-align: center" />

This tab shows the actions that have been carried out on the data, and enables you to undo them in sequence. The `extract` link at the bottom opens up the dialog shown in the following screenshot:

<img src="/blog/files/extract-dialog.jpg" title="Extract Operations dialog" style="width: 100%" />

You have to manually copy and paste the JSON description from the right of this dialog into a separate file in order to save it.

We can then start describing the provenance of the RDF; this needs to go in the Turtle file itself. We start by saying that the RDF that we've created was created from the Gridworks project and through an extraction operation. A simple link to the spreadsheet that was used as the source of the data also provides a quick link back to the original data:

    <http://www.rbwm.gov.uk/public/finance_supplier_payments_2010_q2>
      a opmv:Artifact ;
      dct:source <http://www.rbwm.gov.uk/public/finance_supplier_payments_2010_q2.xls> ;
      gridworks:wasExportedBy <finance_supplier_payments_2010_q2_provenance#gridworks-export> ;
      gridworks:wasExportedFrom <finance_supplier_payments_2010_q2_project.tar.gz> .

The provenance information then needs to describe the export process:

    <#gridworks-export>
      a gridworks:ExportUsingTemplate , opmv:Process ;
      rdfs:label "Process for Exporting Windsor & Maidenhead data as Turtle" ;
      gridworks:project <finance_supplier_payments_2010_q2_project.tar.gz> ;
      gridworks:template <#gridworks-template> .

The project itself was created from the original Excel spreadsheet. The details of how it was generated are through an import that ignored a single non-blank header row and then went through the set of operations described by the JSON.

    <finance_supplier_payments_2010_q2_project.tar.gz>
      a gridworks:Project , opmv:Artifact ;
      rdfs:label "Windsor & Maidenhead Supplier Payments April 2010 - June 2010 Gridworks Project"@en ;
      gridworks:wasCreatedFrom <http://www.rbwm.gov.uk/public/finance_supplier_payments_2010_q2.xls> ;
      opmv:wasGeneratedBy <#gridworks-processing> .
    
    <#gridworks-processing>
      a gridworks:Process , opmv:Process ;
      rdfs:label "Processing on the Gridworks Project"@en ;
      common:usedData <http://www.rbwm.gov.uk/public/finance_supplier_payments_2010_q2.xls> ;
      gridworks:ignore 1 ;
      gridworks:operationDescription <finance_supplier_payments_2010_q2_operations.json> .
    
    <finance_supplier_payments_2010_q2_operations.json>
      a gridworks:OperationDescription , opmv:Artifact ;
      rdfs:label "Dump of the Processing carried out by Gridworks on Windsor &amp; Maidenhead Supplier Payments April 2010 - June 2010 data"@en ;
      gridworks:wasExportedFrom <finance_supplier_payments_2010_q2_project.tar.gz> ;
      gridworks:wasExportedBy <#gridworks-operation-description-extraction> .
    
    <#gridworks-operation-description-extraction>
      a gridworks:ExtractOperationDescription , opmv:Process ;
      rdfs:label "Extraction of the operation description from the Windsor &amp; Maidenhead Supplier Payments April 2010 - June 2010 Project from Gridworks"@en ;
      gridworks:project <finance_supplier_payments_2010_q2_project.tar.gz> .

The template is described in terms of the separate parts; in fact it's useful to use this provenance file as the record of the template that you use, given that Gridworks won't save the template in the project itself.

    <#gridworks-template>
      a gridworks:Template , opmv:Artifact ;
      gridworks:prefix """
    ...
    """^^xsd:string ;
      gridworks:rowTemplate """
    ...
    """^^^xsd:string .

## Rinse and Repeat ##

Gridworks makes it easy to repeat a given set of operations on another spreadsheet that follows the same structure. If you download the [Windsor and Maidenhead spending data from 2009 Q4](http://www.rbwm.gov.uk/web/finance_payments_to_suppliers.htm) and import it into Gridworks, you'll see that it uses the same set of columns as the 2010 Q2 data that we've been looking at. (Strangely enough, the 2010 Q1 data doesn't quite follow the same structure as it doesn't include the 'TransNo' column.)

There are a couple of differences:

  * the 'Updated' column isn't recognised as holding dates on import; you can use `Edit Cells... > Transform` to change these values into dates using the `toDate(value)` formula
  * the 'Amount excl vat £' column isn't recognised as holding numbers on import because the values have commas in them; you can use the formula `toNumber(replace(value, ',', ''))` to rectify this

You might want to do some more cleaning, for example to check for duplicates, but once that is done, you use the `apply` link at the bottom of the `Undo/Redo` tab to apply the JSON operation description that you imported for the previous spreadsheet on this one. The templates require only a little tweaking to give different filenames and labels, but otherwise can be used as-is.

So while the process of cleaning data, deriving values and creating a template for exporting as Turtle is a bit of effort, the likelihood is that you will be able to repeat the same operations on similar data with a minimal amount of work.

## Conclusions ##

Gridworks is a simply amazing tool for data cleansing, analysis and, as we've seen, transformation. It's set to become more so for our purposes in the near future, as it comes to support the mapping of names for things to URIs using configurable reconciliation services (which might allow it to automatically map Government Department names to URIs, for example), and the creation of RDF using a more intuitive and user-friendly approach than the templates that I've illustrated here.

Of course there are issues, particularly for UK civil servants who typically have to operate on locked-down machines running IE7 (if they're lucky). Gridworks also only deals with the fairly simple cases of data that fits in a spreadsheet-like structure, without the complexities of annotations on rows, columns or individual cells that we often see in government data.

Nevertheless, there's huge potential here to provide a fairly easy route to the publication of linked data for people who are familiar with spreadsheets, in particular one that can be tweaked and extended to allow for the variety and complexity of real-world data.
