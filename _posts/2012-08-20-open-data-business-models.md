---
layout: drupal-post
title: Open Data Business Models
created: 1345494690
tags:
- opendata
---
As you may have seen, I have been appointed to the [Cabinet Office's Open Data User Group](http://www.cabinetoffice.gov.uk/content/open-data-user-group) which had its [first meeting in July](http://www.cabinetoffice.gov.uk/news/open-data-user-group-help-unleash-potential-open-data). The [minutes and slides are available](http://data.gov.uk/search/apachesolr_search?filters=tid%3A12001).

The purpose of the group is to act as an "intelligent customer" to the government on the release of open data. This is a bit of a misnomer, as the word "customer" implies that the group will in some way *buy* data that should be made open, which it's unlikely to do. Perhaps "intelligent consumer" would be more appropriate: our task is to advise the government about which data should be opened up, and (if the commitment has already been made to open it) which should be opened first or how access to it could be improved.

One of the tasks that we face, particularly for datasets that are currently being sold by government (mostly from the [Public Data Group](http://www.bis.gov.uk/policies/shareholderexecutive/structure/portfolio-unit/public-data-group): Met Office, Ordnance Survey, Land Registry and Companies House), is making a strong economic argument for opening up data. To do that, it's useful to understand two things:

  * the ways in which open data can be used in the wider economy, to aid innovation, growth and thereby lift the country out of the economic doldrums
  * the business models that are being used by open data publishers to support open data releases, to illustrate the benefits that they can bring to publishers themselves

<!--break-->

I find business cases for data publishers much more compelling than examples of how open data can be used. For a start, I don't think it's possible to predict how open data will be used or what that will mean in terms of economic or societal impact: the wide world into which it's released is just too complex to know. Sure, there's the development of "Apps", but there are many more hidden uses for open data within businesses, which data publishers and those external to the process are unlikely to ever be aware of. There are also impacts on vendors of support products like analysis and visualisation software, and on society as a whole when you have better informed people and organisations.

As well as wider impact being hard to measure, I don't think anyone is likely to publish open data *well* if they don't have some motivation that is a lot nearer to home than "helping grow the economy". To be useful for reusers, open data needs to be structured, supported, timely, accurate and so on. To be useful for business, data releases need to be reliable and sustained over time: data can go out of date very rapidly and single releases are rarely interesting. So open data publishers need to have business models that enable their data-publishing activities to be self-sustaining and preferably improving.

Below I've described several such models, many of which are based on the business models that currently exist around open source. I'd be really interested to hear of any other business models that you know of for open data, and in particular to hear about examples where any of these models have been employed successfully.

## Cost Avoidance ##

One argument I've heard made about government open data is that releasing it can help organisations avoid the costs of Freedom of Information requests. This probably applies only to data that is likely to be requested (perhaps it is published annually and was requested last year) or has a very low publishing cost. Organisations that have a high FOI spend with lots of successful requests may find that they can lower that FOI spend by proactively releasing data (and making it easy to find).

There are other, less direct, costs that organisations might avoid by releasing data. Most obviously in the public sector, there is political cost in not toeing the [Open Data line](http://www.cabinetoffice.gov.uk/resource-library/open-data-white-paper-unleashing-potential).

## Sponsorship ##

The reverse of cost avoidance is finding sponsors for open data publication. If there are people who strongly believe that a particular dataset should be open and available to all, they may be prepared to sponsor its publication (which isn't the same as licensing it; the consequence is that the data is open for all, not just for those who pay). As I understand it, some data that has been opened up by government, such as that from Ordnance Survey, has essentially been opened up through the sponsorship of the Treasury: they have paid for the data to be made open, for their own reasons (to do with belief that it will enable the economy to grow).

How could you persuade others to sponsor opening up data? If it's something that they would otherwise license, perhaps they are in a better place to face any disruption that will come from the data being freely available than their competitors. Perhaps, if it's the type of dataset that is hard to close up again after it has been made open, they might gamble that it would lower their long term costs. Perhaps they sell analysis or visualisation products that they know those who use the data will find useful, and so getting the data available widely will aid their business.

## Freemium ##

The freemium model has been used with some success for web-based services; it might also work for open data. Under this model, an organisation would publish open data in a basic form -- perhaps with some limitations on formats and throttling of API calls -- and offer advanced access to those who are willing to pay.

There are many ways in which open data can be made more useful than static publication of spreadsheets or a basic API; under a freemium model some of these enhancements would only be offered to those who pay for it:

  * availability of different machine-readable formats
  * unconstrained numbers of API calls
  * more sophisticated querying
  * access to data dumps rather than through an API (or vice versa)
  * provision of feeds of changes to the data
  * enhancement of the data with additional information
  * early access to data
  * provision of data on DVDs or hard disks rather than over the net

## Dual Licensing ##

Data publishers could provide data under an open license for certain purposes, and under a closed license for others. This technique has worked for some open source products. The 'certain purposes' might not be simply 'non-commercial': publishers could still encourage start-up use of the data by charging based on the size or revenue of the organisation. Or the license could state that the data can be used in products but cannot be used in further "added value" data feeds without being licensed (this is roughly equivalent to dual-licensing with a share-alike license). This is the model used by [OpenCorporates](http://opencorporates.com/info/licence).

## Support and Services ##

Offering support and services is a business model which seems to work well for companies built around open source. In the open data world, data publishers could offer paid packages with:

  * guarantees on data availability
  * prioritisation on bug fixes (both in data and its provision) for paying customers
  * timely help for customers using the data
  * services around data visualisation, analysis and mashing with other data

These kinds of services still tend to be coupled with licenses in the data world, whereas in open source they have been successfully disentangled.

## Charging for Changes ##

In some cases, individuals or organisations are obliged to provide information to public bodies (and they have a statutory duty to collect it), so that it is available within government and more generally in society. These public bodies can (and sometimes do) charge the providers of that information "administration costs". Examples of this are Companies House information, the Gazettes, Land Registrations, VAT Registrations and so on.

In these cases, those who supply the information to the register are bound to by law, so it would be possible to charge them whatever it took to support providing the data as open data. Indeed, supplying the data as open data is likely to increase its usage (both within government and more widely), and therefore the political pressure to retain the registry and thereby maintain its longevity.

## Increasing Quality through Participation ##

The [model that we are using at legislation.gov.uk](http://www.nationalarchives.gov.uk/news/732.htm) is based on increasing the quality of the data that we have to publish -- bringing the statute book up to date -- by enlisting the help of other parties who would benefit from having an up-to-date open statute book. Because otherwise this information is very costly to get hold of, there are any number of potential contributors, including publishers, lawyers, academics, and government itself.

This model doesn't entirely cover the costs of opening up data: contributors aren't generally paying money to be involved, but donating effort to maintaining the published data. Thus this business model doesn't completely cover costs, but it's a very useful one for organisations that have an obligation to publish information but lack the resources to do it well.

## Supporting Primary Business ##

The final business model that I have seen being used is where releasing open data naturally supports the primary business goal of the organisation. The best example of this is around the Barclays Cycle Hire in London (or Boris Bikes as we call them for some reason), where releasing open data about the bikes drives the development of Apps that make it easier for potential customers to use the scheme, thus bringing in revenue to the core business.

Another example is the recent release of data about [Manchester City football players](http://www.guardian.co.uk/football/blog/2012/aug/16/manchester-city-player-statistics) which, they hope, will lead people to create better ways of measuring player performance, which they will then be able to take advantage of. (And if it means that they are being talked about in the blogosphere, so much the better.)

I'd also place under this category situations where the organisation that publishes the data ends up improving its own use of its data by using the third-party tools that are created because the data is open and available. The kind of thing that I'm thinking about here is how MPs (reportedly) use [TheyWorkForYou.com](http://theyworkforyou.com). There's great opportunity, I think, for the public sector to create a market place for tools that enable it to work more efficiently, by opening up its data.

In cases where organisations are releasing data to support their primary business, they may even find it worthwhile backing up such releases with hackdays and competitions and so on in order to drive the initial creation of some products.

## Discussion ##

I have listed here business models for open data that I have either seen being used or think could viably be used by organisations, particularly public sector organisations. There may be others business models, or examples, that I don't know about, and as I said at the start, I'd really value your suggestions for more.

One thing that I wanted to touch on was about motivations for data publishers. Although, as I've said, I think it's going to be very hard to measure or predict the impact of particular datasets in terms of how it is used in the wider world, it's fairly obvious that high quality data, supplied in a timely and consistent fashion, is going to be easier to use and more accurate than low quality data, supplied as and when, using different formats and coding schemes within each release. In other words, it seems likely that data that is published well will lead to greater usage and thus the better economic outcomes on which much of the open data argument is based.

The different business models above provide different incentives for data publishers. In fact, only the last two include any incentive to publish data *well*: when publishing data to support your primary business, the whole point is to make it easily reusable; when you are supporting data publication by eliciting contributions from others, they are more likely to contribute if the released data is useful for them.

In other cases, the incentive for the data publisher is towards doing the least amount of work so that they can retain as much money as possible, or sometimes (as in the Freemium or Support/Service models) to make the data hard to use unless you are a paying customer. Of course that doesn't mean that organisations using these models will deliberately restrict the utility of the data that they publish -- public sector employees tend to be more motivated towards doing the right thing than making a profit -- but they will have a lot less incentive to invest in making the data easy to use than those employing either of the latter two models.

Another aspect of the business models above that's worth thinking about is about knowing who is using your data. Many data releases have been done in a "fire and forget" mode, using either cost avoidance or sponsorship as a model, which has the advantage of being a cheap method of releasing data. But having a rudimentary idea of who is using data and what they are using it for helps you to understand where there are gaps in your provision, be it in formats, coding schemes, timeliness and so on. Many of the other business models on the list above (as well as the 'selling licenses' business model of closed data) put you in direct contact with at least some of those using the data, which helps you improve provision in the right direction. In particular, getting people to participate to help improve data quality is [good open data engagement](http://www.opendataimpacts.net/engagement/) and something that I think most data releases should aim for.

Which brings me back to ODUG. The best indications that we have about what data will prove useful to people are the data that people are currently using and the data that they tell us they want. If you're a potential or actual reuser of public sector information, ODUG will shortly be providing routes to tell us about what you'd like to have access to, but in the meantime do [get in touch with me](mailto:jeni@jenitennison.com?subject=ODUG) if you have any requests.
