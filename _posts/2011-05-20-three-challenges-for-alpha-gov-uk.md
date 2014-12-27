---
layout: drupal-post
title: Three challenges for alpha.gov.uk
created: 1305920740
tags:
- psi
- opendata
- alphagovuk
---
The new [alpha.gov.uk](http://alpha.gov.uk/) website was launched recently, as a prototype for the "single Government website" described in Martha Lane Fox's report [Directgov 2010 and Beyond: Revolution Not Evolution](http://download.cabinetoffice.gov.uk/digital/directgov-2010-and-beyond.pdf). Apparently [the real deal could go live "in about a year"](http://www.guardian.co.uk/government-computing-network/2011/may/11/cabinet-office-launches-alphagovuk).

The site is lovely, a far cry from the standard government fare. But this isn't exactly surprising: it's been developed using [modern technologies](http://twitter.com/jystewart/status/68343015407763456) by a [top team](http://alpha.gov.uk/humans.txt) with a set of [design rules](http://blog.alpha.gov.uk/blog/alpha-gov-uk-design-rules) far removed from those usually applied to government websites, a [budget that's not exactly tight](http://twitter.com/alphagov/status/68225799282634752) and using an Agile methodology. These factors mark it out from the majority ([though not all](http://blog.alpha.gov.uk/blog/shoulders-of-giants)) government websites. And this is part of the point, to illustrate the gap between what we have and what a revolution could bring.

There are three challenges where I am and have been particularly interested to see the alpha.gov.uk approach. These are in balancing:

  * simplicity and complexity
  * centralisation and distribution
  * end-user and data re-user

It is not currently clear to me whether alpha.gov.uk has decided an approach on any of these -- whether the way the site works currently is the way that they have decided it should work -- or whether these are areas that are still up in the air at the moment. I'm hoping it's the latter.

<!--break-->

*Disclaimer: What I write here is largely coloured by having worked on [legislation.gov.uk](http://www.legislation.gov.uk/) for the last few years, both in terms of the difficulties that we face and the question at the back of my mind of how legislation.gov.uk fits in this brave new world.*

## Simplicity vs Complexity

alpha.gov.uk does a great job at providing the simple message that is needed by the majority of people. The first challenge, I think, lies in also addressing the complex situations that are faced by the minority. For example, alpha.gov.uk provides information about [child car seats](http://alpha.gov.uk/does-my-child-need-car-seat/) but what if my child is disabled? What if I want to check whether it's OK to go without in a taxi? Similarly, there's a tool for [calculating holiday entitlement](http://alpha.gov.uk/calculate-holiday-pay), but what if I work part time and my days include Mondays; how do bank holidays fit in?

Does a single Government website need to address all these complexities? I can see arguments both ways. On the one hand, handling minority cases can mean making things unnecessarily complex for everyone -- this is the trap that DirectGov falls into too much of the time. On the other hand, if people can't find this information from the single Government website, what other authoritative source is there? Can we even assume that non-authoritative third parties will fill the gaps? Will people trust the information if it isn't from a government source?

My feeling is that, unlike conventional websites, a single Government website has an additional responsibility to provide complex content, and that this includes helping people find information as well as perform tasks. For example, if I'm writing a holiday travel guide and want to include a page describing what to do when you've lost your passport, including contact details for common countries, I want a description and a list, not a tool.

One of the alpha.gov.uk design rules was "optimise for the common case", and the emphasis on clear content and straightforward tools is admirable. But optimisation for a common situation shouldn't mean completely ignoring the uncommon one. The challenge -- which I think is primarily a design challenge and handled pretty nicely in the Guides -- is to make a website that contains complex information appear simple.

## Centralisation vs Distribution

In her report, Martha Lane-Fox laid out a number of advantages to a single government website, including providing consistency in user experience, ensuring that there is no "wrong part" of the government web estate from which to start your search for government information, and saving money by building on shared platforms. These imply a high level of centralisation.

Against that is the fact that there is no single owner of government content. Departments have the best understanding of their policies. HMRC collects taxes. DVLA licenses drivers. The Identity and Passport Service issues passports. The greater the distance between the website and the people who understand the area, the more likely the content and tools are to be simply wrong or out of date and ultimately worthless. To completely centralise all government websites runs counter to the way the web works and the advantages that it gives in distributing control over content. If Google is your front page, then what does it matter how many domains the content is distributed across?

So this is what I see as the second challenge for a single government website. It is a question of governance and of technology. How does a single Government website enable the people that own information to keep control of it while providing a consistent user experience? 

While there are very likely large swathes of government content that could be perfectly well served by a Wordpress or Drupal installation with some custom templates, other content really couldn't fit into that kind of content management system (yes, I'm thinking of legislation), and need custom solutions which are best owned and updated by those that understand the content. What does the "single Government website" mean for these sites? Do they continue running their own sites with a common set of styles and links? Do they only run a service with an API that is skinned centrally?

In my opinion, alpha.gov.uk should be trying out the different ways in which different content could be brought together from distributed sources, learning lessons from experience at the BBC and beyond, to find approaches that work within government.

## End User vs Data Reuser

The third challenge is particularly important for those of us who care about freeing government data. We don't want information locked within government's web pages, but available for us to re-present, mash together and build into our own products. The balancing act here is between the end-user who really doesn't care at all about the data underlying the pages they see, and the citizen developer who wants to reuse that information.

There is some evidence of the idea of providing access to underlying data in some of the alpha.gov.uk Guides, such as the [An employee's guide to Redundancy](http://alpha.gov.uk/guides-redundancy/), which include a "Syndication API" box with (not yet working) links to JSON, XML and Atom versions of the content. But there's no provision of a feed on the search results page, no RDFa or microdata markup, or separate data versions, on pages that contain data such as [What is the minimum wage?](http://alpha.gov.uk/how-much-minimum-wage/), and the tools such as that used to [Calculate holiday pay](http://alpha.gov.uk/calculate-holiday-pay) are provided as client-side scripts rather than server-side APIs which could be called from other applications.

As we've found with legislation.gov.uk, building websites based on data and API access to that data is very possible, but doing so can change your approach to both site design and technology use. I'd love to see alpha.gov.uk being built around making reuse easy rather than retrofitting it as a secondary concern.

## Other Challenges

There are undoubtedly other challenging balancing acts for alpha.gov.uk.

Steph talks about [lack of community](http://www.helpfultechnology.com/helpful-blog/2011/05/10-things-alpha-gov-uk-gets-wrong-part-2/); I view this as something to balance against the need to provide authoritative set of information, which is hard to do when you let just anyone participate in a site.

There's also the balance between the need for small-g government to provide a persistent and consistent website while big-g Government wants to create short-lived special-case sites to tout particular policies, such as [Red Tape Challenge](http://www.redtapechallenge.cabinetoffice.gov.uk/) or [Your Freedom](http://yourfreedom.hmg.gov.uk/). How do these sites fit within the single Government website?

Navigating a way through these challenges will require making hard decisions, reaching difficult compromises and finding imaginative third ways. I for one am very interested to see the directions alpha.gov.uk chooses to take.
