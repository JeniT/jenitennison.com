---
layout: drupal-post
title: Free Our Bills
created: 1206990614
tags:
- xslt
- xml
- legislation
---
The [Free Our Bills][1] campaign was launched recently in the UK. [Some of the comments I've seen][9] about the campaign makes me think that it might be helpful if people understood more about how Bills and legislation get published in the UK. I thought I'd offer a bit of background based on my experience (though there are many people with more intimate knowledge of the processes involved; perhaps they'll correct me when I get it wrong).

[1]: http://www.theyworkforyou.com/freeourbills/ "TheyWorkForYou.com: Free Our Bills"
[9]: http://www.theregister.co.uk/2008/03/26/mysociety_xml_bills_cameron/comments/#c_185029 "The Register: Comments on UK.gov urged to adopt web-friendly legislation format"

<!--break-->

  * Bills are draft legislation that is under discussion within the House of Commons or House of Lords. A Bill becomes law (legislation) when it is enacted.
  
  * Bills are published by Parliament and are available on the [Parliament website][2]. Legislation is published by [The Stationery Office (TSO)][3] under contract to the Office of Public Sector Information (OPSI) on the [OPSI website][4].
  
[2]: http://services.parliament.uk/bills/ "UK Parliament: Bills Before Parliament"
[3]: http://www.tso.co.uk/ "The Stationery Office"
[4]: http://www.opsi.gov.uk/legislation "OPSI: Legislation"

  * Bills are changed (amended) as they progress through the Houses of Parliament. People are mostly interested in the most recent version of a Bill. Legislation can be changed (amended) by other legislation; the version of a piece of legislation with all the changes applied to it is known as consolidated legislation. Consolidated legislation is published in the [Statute Law Database][5] as well as (too a more limited extent) on the [OPSI website][6].
  
[5]: http://www.statutelaw.gov.uk "Statute Law Database"
[6]: http://www.opsi.gov.uk/legislation/revised "OPSI: Revised Legislation"

  * Bills are edited by a dedicated team of Parliament employees who must reflect the amendments that the MPs say they want to make. They use a WYSIWYG XML editor. As is usual in an environment that has only been concerned about printed copies for centuries, they tend to focus on appearance rather than semantics, even when the XML supports the semantics.
  
  * The Free Our Bills campaign is not about making Bills (or legislation) easier for humans to read and understand, it's about making it easier to extract information from a Bill so that people can be notified when a new Bill comes along on a subject they care about, or an old Bill is redrafted, and so on.
  
  * Bills are already available for the public to view on the web, in PDF and HTML forms. The problem is that the HTML is Really Really Bad ([View Source to see][7]) and that makes it Really Really Hard to extract useful information from them.
  
[7]: http://www.publications.parliament.uk/pa/ld200708/ldbills/044/08044.i-v.html "Parliament: Climate Change Bill"

  * There are reasons for the Bills HTML being Really Really Bad:
  
      * The HTML must look *exactly* like it does in printed form, otherwise Members of Parliament (MPs) would get Really Really Confused.
      * MPs refer to pieces of a Bill (which they might want to change) by page and line number, not by the semantic structure of the Bill, so the HTML must have page and line numbers in it or MPs would get Really Really Confused. 
      * Although the formatting of Bills is pretty consistent, there's always the chance that a piece will need to be formatted specially. It might be safe to assume a particular presentation for a particular semantic 99% of the time, but if that 1% isn't formatted in the different way, MPs would be Really Really Confused.
      * The code that creates the Bill HTML was written several years ago, when browser support for CSS was Really Really Bad.

  * The picture for legislation is rather better because a strategic decision was made to focus on semantics rather than presentation. When a Bill is enacted, it gets converted into [reasonably good semantic XML][8], which forms the basis of all the HTML views. It also helps that this HTML was designed fairly recently, for modern browsers; it makes heavy use of CSS so there's relatively little obfuscation of the content.

[8]: http://www.opsi.gov.uk/legislation/schema/ "OPSI: Legislation schema"

I think there are interesting general lessons here:

  * **Different user communities have different requirements.** MPs have different requirements from Bills from the general public, who don't care (as) much about line or page numbers. On the other hand, you need to actually consult with users about what they need rather than make assumptions about it: are MPs really likely to get Really Really Confused if the HTML presentation of a Bill looks slightly different from the PDF print version? I don't know.

  * **Authors don't care about what they don't use.** When the only way of using a Bill is to print it, it's natural that authors and publishers only care about how it looks when it's printed. Training people to care about semantic markup is really hard, and it's made harder by WYSIWYG tools that allow them to override the semantic style. If a difference isn't visible, then in author's eyes it doesn't exist.

  * **You have to positively decide to ignore appearance.** When transforming from a WYSIWYG view, replicating appearance is the obvious thing to do. But it's worthwhile in the long run to focus on extracting the semantics, because the resulting documents are so much more reusable.

  * **HTML, XML and XSLT are not inherently good.** Parliament wanted Bills in HTML so that they were more accessible on the web. But the HTML is dreadfully inaccessible because of the other requirements placed on it. Similarly, XML can be incredibly obfuscated, or entirely about presentation, as formats such as OOXML illustrate. And just because your code is written in XSLT does not make it inherently easier to maintain then (say) a SAX transformation. It's easy to misuse a technology.

  * **Developers who produce atrocious HTML aren't necessarily ignorant.** Unfortunately, there's sometimes a limit to how much you can argue with your customers.

