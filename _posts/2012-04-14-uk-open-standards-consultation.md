---
layout: drupal-post
excerpt_separator: "<!--break-->"
title: UK Open Standards Consultation
created: 1334443491
tags:
- opendata
---
Over the last few months, the UK Government has been running a [consultation on its Open Standards policy](http://consultation.cabinetoffice.gov.uk/openstandards/). The outcome of this consultation is incredibly important not only for organisations and individuals who want to work with government but also because of its potential knock-on effects on the publication of Open Data and the use of Open Source software within public sector organisations.

Unsurprisingly, Microsoft, Qualcomm and other organisations who have a vested interest in keeping the UK Government locked in to their products are [responding vociferously to the consultation](http://www.computerweekly.com/blogs/public-sector/2012/04/proprietary-lobby-triumphs-in.html). They risk not only losing business to smaller enterprises within the UK but also, if the policy is successfully adopted here, in other countries in Europe and internationally that follow suit.

If we want our Government to be Open -- to use Open Standards, to publish Open Data, to adopt Open Source -- then we must respond to this consultation in numbers.

There are three things that you can do:

  1. **Respond to the consultation** -- made even easier by [this response form](http://open.squarecows.com/) developed by Ric Harvey
  2. **Attend the [events](http://consultation.cabinetoffice.gov.uk/openstandards/events/)** -- these seem pretty full now, but try to get in if you can
  3. **Spread the message** -- blog and tweet and write to raise awareness of the importance and impact that this consultation could have

<!--break-->

The consultation is quite long and there are a lot of questions to answer. In the hope of making this easier for everyone, I'm publishing my response below. Please consider these responses public domain, and feel free to copy as much or as little as you like from them (though I recommend you omit the parts that are about my individual experience and substitute them with your own).

For extra background, read:

  * [Of Microsoft, Netscape, Patents and Open Standards](http://blogs.computerworlduk.com/open-enterprise/2012/04/of-microsoft-netscape-patents-and-open-standards/index.htm) by Glyn Moody
  * [Are open standards a closed barrier?](http://digital.cabinetoffice.gov.uk/2012/04/12/are-open-standards-a-closed-barrier/) by Linda Humphries
  * [Open Standards at risk](http://dev.squarecows.com/2012/04/10/open-standards-at-risk/) by Ric Harvey

## Criteria for Open Standards ##

### 1. How does this definition of open standard compare to your view of what makes a standard 'open'? ###

The definition in the consultation closely matches my view of what makes a standard open. The important factors are:

  * a documented, open process which enables participation not just from implementers but also from users of the standard, and that provides ongoing maintenance and development of the standard
  * publication of the standard such that anyone can read it
  * a royalty-free and non-discriminatory license such that anyone can implement the standard without cost

The one factor that does not match my view is the availability of multiple independent implementations of the standard. In some cases it may be that market pressures mean there are not currently multiple good implementations of an otherwise Open Standard, or several but only for one particular platform. Limiting the definition of Open Standards to only those with multiple cross-platform implementations is probably too constraining.

There are two examples from my work that demonstrate why the availability of multiple implementations should not be a factor.

First, one of the Open Standards that I use is XSLT, which for years has been dominated by a single implementation -- Saxon -- giving customers no real choice. Nevertheless, because it is an Open Standard, Saxon has had a lot of pressure to be completely conformant with that standard, and in the past year a number of other implementations have been started that can compete with it on different platforms, so the presence of a single implementation has proven to be a short-term issue.

Second, in some new technology areas such as Linked Data, there may be only single implementations simply because the area and the Open Standards on which they are built are not yet very mature. As the use of the technology grows, so do the number of implementations and their adherence to the standard. Thus number and quality of implementations does develop over time; government should concentrate on long-term adoption rather than short-term availability.

### 2. What will the Government be inhibited from doing if this definition of open standards is adopted for software interoperability, data and document formats across central government? ###

In some specialist areas, there may not be existing Open Standards available, or it may be that the Open Standards that are available do not match the specialist needs of the UK government. Where an Open Standard is imminent but not yet fully standardised or implemented, waiting for standardisation or implementation could delay government IT projects. However, the measures suggested in the rest of the proposed policy, including government involvement in standards creation and allowing for selecting other standards where there is no available Open Standard, mitigate against this risk.

The other mitigating factor is that where an Open Standard doesn't exist, it is usually possible to build new work on top of Open Standards. In my experience working on legislation.gov.uk, even though good appropriate Open Standards for UK legislation weren't available, we have been able to work using the underlying Open Standards such as XML, RDF and HTTP, so the gap between necessary custom work and Open Standards is minimised.

The definition of Open Standards may also prevent the Government from entering into contracts with companies which do not adopt Open Standards. It may hinder exchange of information with outside organisations that use software that doesn't support Open Standards. These may be problems in the short term but over the longer term, an Open Standards policy will move the supplier market and other organisations towards Open Standards more generally.

### 3. For businesses attempting to break into the government IT market, would this policy make things easier or more difficult – does it help to level the playing field? ###

The policy does help to level the playing field for two main reasons:

  * using Open Standards reduces the cost of switching to new suppliers, because the new suppliers do not have to spend a lot of time reverse engineering existing processing and data; this means new suppliers can make more competitive bids
  * Open Standards are often implemented within Open Source Software, which has low or no cost; this helps smaller businesses because it lowers the cost of their entering the market

### 4. How would mandating open standards for use in government IT for software interoperability, data and document formats affect your organisation? ###

I work as an independent contractor who specialises in a variety of Open Web Standards. For me as a contractor, the adoption of Open Standards within government increases the potential opportunities for me to work on government projects.

I am currently contracted to work on the delivery of legislation.gov.uk and The National Archives' Expert Participation Programme. This work is already built substantially on Open Standards. One of the main pain points in this work has been that the government organisations that provide data such as Bills, new Statutory Instruments or Tables of Effects for legislation.gov.uk are using proprietary technologies to do so, and converting from those proprietary data formats, or getting users to save in an open data format, can be both hard to do initially and difficult to maintain as new versions of software are rolled out. An Open Standards policy within government would greatly reduce the cost involved in those conversion processes and increase the ease of use for government users.

I am also a member of the Technical Architecture Group within the World Wide Web Consortium (W3C), which is the main standards body for Web Standards. From that perspective, the Open Standards policy would increase UK government, and UK government supplier, involvement in the development of Open Standards within the W3C, which can only improve the quality of the standards and the life of the organisation as a whole.

### 5. What effect would this policy have on improving value for money in the provision of government services? ###

This policy would greatly increase value for money in the provision of government services. Adopting Open Standards often means that the basic building blocks for a service can be selected off the shelf, and then fitted together and customised, rather than a proprietary solution built from scratch. This can reduce the cost of providing the service as a whole and improve the service as development effort can be directed on the unique features of the service.

### 6. Would this policy support innovation, competition and choice in delivery of government services? ###

The policy as written is well-framed to support innovation, competition and choice across the market in the medium and long term, in areas which are beneficial to the UK Government and to the rest of the economy.

Adopting Open Standards focuses innovation on novel areas (which are not currently covered by existing standards) and on providing better quality services (which may mean better performance, better user experience and so on). It also encourages innovation in public, and this greater exposure brings with it higher quality and a better focus on user requirements. The only innovation it prevents is that whose purpose is to lock the government in to individual suppliers, such as closed standards that largely repeat existing work but can only be implemented by one supplier.

As part of the work that I did on Linked Data for data.gov.uk, myself and several colleagues worked on new RDF vocabularies such as [org](http://www.w3.org/TR/vocab-org/), [Data Cube](http://www.w3.org/TR/vocab-data-cube/) and [OPMV](http://purl.org/net/opmv/ns) and processing standards such as the [Linked Data API](https://code.google.com/p/linked-data-api/). We did this in the open, and it was all based on Open Standards: that approach did not prevent us from doing new and innovative things. The results of that innovation were then taken forward by the wider community, being made more rigorous and better suited to applicability across a wider audience, and are resulting in Open Standards from W3C. In addition, my colleagues have built new products that integrate that work, for example in [Kasabi](http://kasabi.com/).

Adopting Open Standards focuses competition on the quality of service that is offered rather than on winning a single competition that will lock the government in to contracts for many years to come. It prevents supplier complacency: when the government can move easily to a new supplier, suppliers have to provide continuous improvements over the lifetime of a contract, because they cannot be guaranteed to win the next one simply because they are the only ones who have implementations that can process the data. Competition is thus focused into areas that matter to the customer, including cost, rather than areas that matter to the supplier.

I was involved tangentially in The Stationery Office's (TSO) bid during the recent re-procurement of legislation services by The National Archives. Because legislation.gov.uk was built on Open Standards, TSO's bid had to be based on quality of service, on continuing innovation over the lifetime of the contract, and on low cost of delivery.

Adopting Open Standards increases choice for the UK Government because it opens up competition to suppliers who would not otherwise be able to compete (as in Question 3). Of course some companies may not currently use Open Standards, and under this policy the UK Government would not be able to choose them as suppliers in the short term, but it is unlikely that companies would continue their use of closed standards in the long term, if they wish to compete for UK Government contracts.

Put another way, adopting Open Standards means companies are innovating and competing on the **right** things: on things that are important to the UK Government.

### 7. In what way do software copyright licences and standards patent licences interact to support or prevent interoperability? ###

It is possible to have a Open Standard implemented by software that is public domain or completely closed or anything in between: Open Standards do not necessarily lead to free software. On the other hand, standards patent licenses reduce the ability of developers to produce free (open licensed) software because they need to make enough money to pay to use the license. Thus standards patent licenses limit the number and type of implementations of a standard, effectively limiting the market to those with enough capital to enter it.

The fewer implementations of a standard, the less pressure there is on those implementations to be interoperable, because there are a known and limited number of other implementations with which they need to interoperate. The greater the market of implementations, the greater the drive for interoperability because it becomes increasingly likely that they will have to interoperate with each other.

For example, I have often had to move code that I have written based on an Open Standard from one implementation and use it in another. If it doesn't work, I can work out which implementation is correct (by looking at the standard) and report the error to the implementation developers, which helps them improve the interoperability of their product. The ability to move between implementations is vital to ensure interoperability between them, and the broader the market the more likely that is to happen.

### 8. How could adopting (Fair) Reasonable and Non Discriminatory ((F)RAND) standards deliver a level playing field for open source and proprietary software solution providers? ###

Adopting (F)RAND standards does not deliver a level playing field across providers, because it limits the ability of open source providers to enter the market, as they have to recoup licensing cost. Only royalty-free licenses provide a completely level playing field across providers.

### 9. Does selecting open standards which are compatible with a free or open source software licence exclude certain suppliers or products? ###

Selecting Open Standards necessarily excludes those products that only use closed standards, and suppliers that only offer those products. In the short term, suppliers who have built their products and business models around closed standards and lock-in will be excluded.

However, there is no requirement for companies that adopt Open Standards to license their products using a free or open source software license. While there are often free or open source products built around Open Standards, these are only competitive when they are at the same quality as those with closed licenses.

An example from legislation.gov.uk is that our early development used eXist, which is an XML database available under an open source software license which implemented the Open Standards of XML and XQuery. It became clear that (at that time) eXist did not support the level of use that we needed, in its performance and its scalability. We therefore instead adopted MarkLogic, which uses the same Open Standards but is not available under an open source software license. This demonstrates how companies which adopt Open Standards can still offer competitive value even within a market with open source implementations.

Another interesting point to draw from this is that the presence of an open source implementation of an Open Standard enabled us to prototype and experiment using that implementation, knowing that should we need better performance and so on we would be able to move all our code to another interoperable implementation. If MarkLogic had implemented a custom method of querying XML, committing to paying for it early in the process would have been too high a risk. So the use of Open Standards effectively helped MarkLogic win that business.

### 10. Does a promise of non-assertion of a patent when used in open source software alleviate concerns relating to patents and royalty charging? ###

I would personally be very wary of implementing a standard which had a promise of non-assertion of a patent, and standards made available under those terms would seem more risky and costly to implement because any such promise would have to be checked by a lawyer and would likely constrain my future actions and the use of the software in other environments.

### 11. Should a different rationale be applied when purchasing off-the-shelf software solutions than is applied when purchasing bespoke solutions? ###

The same policy should be applied both to off-the-shelf and bespoke solutions, particularly as the difference between these is not at all clear cut: off-the-shelf solutions are often customised, and bespoke solutions built from off-the-shelf products. Whatever the type of solution, the crucial point is that it needs to interoperate with other products, using Open Standards.

### 12. In terms of standards for software interoperability, data and document formats, is there a need for the Government to engage with or provide funding for specific committees/bodies? ###

The Government should engage with those standards bodies that work on standards that the Government uses, so that it can shape the development of those standards and highlight new areas where standards work is needed to satisfy the UK Government's requirements. In my own area of web standards, the main one is the W3C. In fact, given the UK Government's transparency, open data and "digital by default" policies, all which require the use of W3C standards, the UK Government is under-represented within W3C, with only two agencies (Ordnance Survey (OS) and The National Archives (TNA)) being members. Other public-sector organisations which make heavy use of W3C standards, such as the BBC, have made a business decision be become more engaged in W3C activities in order to shape and influence them.

Membership of W3C and other standards bodies is particularly important where standards development impacts on the ability to achieve the goals of particular organisations. For example, TNA are taking particular interest in the provenance work being done at W3C; the Government Digital Service should be participating in the development of standards in web design and applications; the Office of National Statistics should be taking an interest in the development of the Data Cube vocabulary for statistical information and so on.

### 13. Are there any are other policy options which would meet the described outcomes more effectively? ###

I believe that the Open Standards policy described in the consultation is the best way to achieve lower cost, higher interoperability, reduced lock-in, increased innovation and competition in the right areas and to level the playing field both for open source software and for small and medium enterprises who wish to compete for government contracts.

## Open Standards Mandation ##

### 1. What criteria should the Government consider when deciding whether it is appropriate to mandate particular standards? ###

The only time the Government should mandate a particular Open Standard for IT is when there is a clear and apparent cost in two competing Open Standards that offer equivalent functionality being adopted by different parts of Government due to poor interoperability between them. In most cases, central government should avoid mandating a particular Open Standard, but instead let individual public-sector organisations select an appropriate Open Standard based on their own requirements.

Government should mandate a particular Open Standard where:

  * there are competing Open Standards that cover the given functionality and
  * interoperability or conversion between these standards is lossy or difficult and
  * there are multiple organisations within government with which interoperability involving the standard is required

### 2. What effect would mandating particular open standards have on improving value for money in the provision of government services? ###

A central government authority mandating particular Open Standards could reduce value for money in the provision of government services, because that central authority is unlikely to fully understand the requirements of the particular service in detail. Public sector bodies who are actually procuring solutions should select particular Open Standards as part of the procurement process.

Where mandating particular Open Standards could improve value for money is if there are competing Open Standards and different public sector bodies are likely to adopt different ones. In those cases, there may be interoperability problems between the standards which make it more costly to provide services, and mandating the adoption of a particular Open Standard could help.

### 3. Are there any legal or procurement barriers to mandating specific open standards in the UK Government's IT? ###

I do not know.

### 4. Could mandation of competing open standards for the same function deliver interoperable software and information at reduced cost? ###

It is unclear what this question means.

Mandating both of two competing Open Standards may increase the availability of interoperable software, but it will raise the cost of implementation and therefore of software, because implementing two standards takes more development effort than implementing one.

Mandating a single Open Standard from two competing standards may increase interoperability but comes with a possible risk and cost. It may be that two competing standards, while similar, have different target audiences and capabilities. If one is mandated, those public sector bodies whose requirements fit more closely with the other will suffer increased cost in trying to use the first standard to fit their requirements. In addition, the standards may evolve over time such that they either diverge in functionality or increase in interoperability (so that mandation is no longer necessary) or such that the original judgement about which to mandate no longer applies.

### 5. Could mandation of open standards promote anti-competitive behaviour in public procurement? ###

Anti-competitive behaviour arises when the number of potential competitors is artificially restricted due to the terms of the procurement. Whether mandating a particular Open Standard promotes anti-competitive behaviour depends on two factors.

First, it depends on the nature of the Open Standard and its implementations. Some Open Standards are small and easy to implement while others are large and complex to implement. Some have open source implementations across a number of platforms, others have few implementations, available under restricted terms or on restricted platforms. In the short term, mandating an Open Standard that is costly for a company to implement and for which there is no easily available implementation is going to favour those companies who have already implemented the Open Standard. In the longer term, by their nature, implementations of Open Standards tend to become more widely available, and companies are likely to invest in implementing them if they are industry standards. Crucially, because the standards are Open, they are freely able to read them and can implement them without  royalty payments, so in the long term it is not anti-competitive.

Secondly, the reason for the mandation of a particular Open Standard should be clear within the procurement exercise and a particular Open Standard should not be mandated unless there are clear reasons for that mandation. As an example from my own experience, there are two Open Standards for embedding metadata within HTML pages: RDFa and microdata. Either could be used to provide largely the same functionality so there would generally not be a need to mandate one or the other during procurement, but there should be a requirement to show how the standard selected by the supplier would be used to achieve the aims of the system.

### 6. How would mandation of specific open standards for government IT software interoperability, data and document formats affect your organisation/business? ###

Mandating specific Open Standards could limit the approaches that I would be able to take in my work, which could mean that I was less able to select an appropriate technology based on the requirements of the system. Any technology selection requires balancing a large set of requirements, both in terms of functionality and in terms of performance, reliability, scalability and so on. As a developer, I and my direct customers have the clearest understanding of these requirements and their relative importance within the system. These are complex choices, and they should not be made by central authorities who do not understand the details.

It is much more important to me to have a clear understanding that Open Standards should be used wherever possible and which Open Standards are being used within the organisations that interact with the systems that I am responsible for, so that the systems I build interoperate with them more smoothly.

### 7. How should the Government best deal with the issue of change relating to legacy systems or incompatible updates to existing open standards? ###

Good Open Standards provide clear statements about both forwards and backwards compatibility and, as they are developed through open participation, the extent of changes and the reasons for them are usually clear, which makes the process of working out what needs to be upgraded easier than with closed standards. For example, I was involved in the development of the second version of XSLT, and those of us in the Working Group spent substantial time ensuring that the impact on existing users of XSLT were not too great and were thoroughly documented.

When adopting a particular Open Standard within a system, the Government or their suppliers should assess the impacts of future changes in the standard on the system and should be involved to an appropriate level in the development of the standard to ensure that it continues to meet requirements.

### 8. What should trigger the review of an open standard that has already been mandated? ###

The Government should continuously work with its suppliers during the contract term and with potential suppliers during procurement to assess the best Open Standard to use. Even when a given standard itself doesn't change, the wider IT environment may alter: there may be more or fewer implementations over time, alternative standards, or a change in interoperating standards used by other organisations. Thus there are no particular trigger points at which an Open Standard should be reviewed, though re-procurement will naturally cause a re-exploration of a system's environment and the best approach to its implementation.

### 9. How should the Government strike a balance between nurturing innovation and conforming to standards? ###

Good Open Standards have built-in extensibility points which provide the scope for implementer innovation while providing general interoperability. In the best cases these extensions gradually become standardised themselves: this is what has happened with XSLT, for example. Thus, conforming to standards does not prevent innovation; instead it focuses innovation on user requirements, and in particular on improving the quality of implementation. The Government's Open Standards policy should ensure that when standards are selected they provide broad interoperability while giving scope for extension, and this is particularly important if the Government mandates particular Open Standards for general use.

### 10. How should the Government confirm that a solution claiming conformity to a standard is interoperable in practice? ###

Within the W3C, new standards must have an associated test suite, usually constructed both by the Working Group who develop the standard and from the test suites created by individual implementers of the standard. Running an implementation against such a test suite makes it possible to empirically test whether there is conformance to the standard. The results of running a given implementation against such a test suite are often available, for example see [the RDFa test suite results](http://rdfa.info/earl-reports/), but the Government could also ask the solution provider for evidence of interoperability in the form of test suite results.

### 11. Are there any are other policy options which would meet the objective more effectively? ###

A general Government policy to use Open Standards will in most cases naturally lead to the best Open Standard being adopted across the public sector without Government needing to mandate the use of specific Open Standards. Systems should be procured on the basis of their ability to interoperate with those other systems with which they need to work; in such an environment the easiest approach for suppliers will be to adopt the standards used by other systems.

We have seen this happen within legislation.gov.uk, where we store and publish legislation using a particular XML vocabulary. Various parliaments and government departments draft legislation which is published on the site, and they have traditionally done so based on the particular requirements of the drafters themselves (for example, the UK parliament uses Framemaker while government departments use Word). We have to cater for these different formats, and converting them into the standard that we use within legislation.gov.uk. However, as these authoring systems are being re-procured, the ability to produce the XML vocabulary that we use within legislation.gov.uk has become part of the requirements on future authoring systems, because it gives greater fidelity between authoring and eventual publication. Thus we are naturally moving towards a more interoperable environment without any central mandation of the standard and without overriding the local requirements of particular authors.

## International Alignment ##

### 1. Is the proposed UK policy compatible with European policies, directives and regulations (existing or planned) such as the European Interoperability Framework version 2.0 and the reform proposal for European Standardisation? ###

I do not know.

### 2. Will the open standards policy be beneficial or detrimental for innovation and competition in the UK and Europe? ###

The UK's Open Standards policy will be beneficial to innovation and competition in the UK because it levels the playing field for a wider set of providers and focuses innovation and competition on the requirements of the users of software rather than the suppliers. These benefits apply as well to Europe as to the UK, and the successful adoption of an Open Standards policy within the UK will naturally aid the adoption of similar policies in other countries within Europe and internationally.

### 3. Are there any are other policy options which would meet the objectives described in this consultation paper more effectively? ###

The one part of the international alignment policy that needs to be rethought is the preference to international standards over local standards. While in general the wider and greater adoption of a given standard, the better, it is not always the case that international standards provide greater benefits than local ones.

Looking at providing data about legislation, for example, different jurisdictions have very different ways of identifying, creating, revising and formatting legislation. Any international standards for legislation are highly unlikely to take into account the complexities and special cases that are specific to UK legislation (such as the use of regnal years for identifying older items). A local standard can be better tailored to the requirements of the locality, which may be incredibly important in easing implementation cost and data fidelity.

I would therefore recommend a policy approach that emphasised interoperability with international standards without requiring their wholesale adoption, particularly where there are specific local requirements that are not met by the international standard.
