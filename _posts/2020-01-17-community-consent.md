---
layout: post
title: Community consent
---

If we accept that individual consent for handling personal data is not working, what are the alternatives?

I'm writing this because it's an area where I think there is some emerging consensus, in my particular data bubble, but also areas of disagreement. This post contains exploratory thinking: I'd really welcome thoughts and pointers to work and thinking I've missed.

The particular impetus for writing this is some of the recent work being done by UK regulators around adtech. First, there's the Information Commissioner's Office (ICO) work on [how personal data is used in real-time bidding for ad space](https://ico.org.uk/about-the-ico/news-and-events/news-and-blogs/2019/12/adtech-and-the-data-protection-debate-where-next/), which has found that many adtech intermediaries are relying on "legitimate interests" as the legal basis for processing personal data, even when this isn't appropriate. Second, there's the Competition and Markets Authority (CMA) [interim report](https://www.gov.uk/cma-cases/online-platforms-and-digital-advertising-market-study#interim-report) on the role of Google and Facebook in the adtech market, which includes examining the role of personal data and how current regulation affects the market.

But there's other related work going on. In health, for example, there are long running debates on how to gain consent to use data in ways to improve healthcare (by [Understanding Patient Data](https://understandingpatientdata.org.uk/), [medConfidential](https://medconfidential.org/), etc). In transport or "Smart Cities" more generally, we see local government wanting to use data about people's journeys for urban planning.

Personal data is used both for personalising services for individuals and (when aggregated into datasets that contain personal data about lots of people) understanding populations. The things that data is used to do or inform can be both beneficial and harmful for individuals, for societies and for particular groups and communities. And regardless of what it is used for, the collection of data can in itself be oppressive, and its sharing or sale inequitable. 

The big question of this data age is how to control and govern this collection, use and sharing of personal data.


## Personal data use entails choices

Going back to first principles, the point of collecting, using and sharing data is ultimately to inform decision making and action. There are always a range of options about what data to use for any analysis, with different data providing more or less accuracy or certainty when answering different questions. For example, the decision about what ads to serve within a story in an online newspaper could be based on any combination of the content of the story; knowledge about the general readership of the newspaper; or specific personal data about the reader looking at the page, their demographics and/or browser history.

There are also options when it comes to the architecture of the ecosystem supporting that analysis and use: how data is sourced and by whom, who performs which parts of the analysis and therefore what data gets shared with whom and in what ways.

[Curious hackers](https://towardsdatascience.com/gpt2-counting-consciousness-and-the-curious-hacker-323c6639a3a8#51d2) like me will always think any data analysis is worth doing on its own terms - just because it's interesting - and aim to use data that gives as accurate an answer as possible to the question posed. But there are damaging consequences whenever personal data is collected, shared and used: risks of data breaches, negative impacts on already excluded groups, the chilling effect of surveillance, and/or reduced competition, for example.

So behind any analysis there is a choice - an assessment that is a value judgement - about which combination of data to use, and how to source, collect and share it, to get value from it.

Our current data protection regime in the UK/Europe recognises some purposes for using data as being inherently worthwhile. For example, if someone needs to use or share personal data to [comply with the law](https://ico.org.uk/for-organisations/guide-to-data-protection/guide-to-the-general-data-protection-regulation-gdpr/lawful-basis-for-processing/legal-obligation/), there is an assumption that there is a democratic mandate for doing so (since the law was created through democratic processes). So for example, the vast data collection exercise that is the census has been deemed worthwhile democratically, is [enshrined in law](https://www.ons.gov.uk/census/censustransformationprogramme/legislationandpolicy), and has a number of accountable governance structures in place to ensure it is done well and to mitigate the risks it entails.

In many other places, though, because people have different values, preferences and risk appetites, our current data protection regime has largely delegated making these value judgements to individuals. If someone [consents](https://ico.org.uk/for-organisations/guide-to-data-protection/guide-to-the-general-data-protection-regulation-gdpr/lawful-basis-for-processing/consent/) to data about them being collected, used and shared in a particular way, then it's deemed ok. And that’s a problem.


## Challenges with individual consent

There are some very different attitudes to the role individuals should play in making assessments about the use of data about them. At one extreme, individual informed consent is seen as a gold standard, and anything done with personal data about someone that is done without their explicit consent is problematic. At the other extreme, people see basing what organisations can do on individual informed consent as [fundamentally broken](https://www.technologyreview.com/s/612588/its-time-for-a-bill-of-data-rights/). There are a number of arguments for this:



1. In practice, no matter how simple your T&Cs, well designed your cookie notices, or accessible your privacy controls, the vast majority of people [agree to whatever they need to](https://arxiv.org/abs/2001.02479) in order to access a service they want to access and never change the default privacy settings.
2. Expecting people to spend time and effort on controlling their data shadows is placing an unfair and unnecessary burden on people’s lives, when that burden should be on organisations that use data to be responsible in how they handle it.
3. Data value chains are so complex that [no one can really anticipate how data might end up being used](https://www.nytimes.com/2018/01/30/opinion/strava-privacy.html) or what the consequences might be, so being properly informed when making those choices is unrealistic. Similarly, as with the climate crisis, it is unfair to hold individuals responsible for the systemic impacts of their actions.
4. [Data is never just about one person](https://theodi.org/article/most-data-is-about-multiple-people-what-does-that-mean-for-data-portability/), so choices made by one individual can affect others that are linked to them (eg your friends and family on Facebook) or that share characteristics with them (we are not as unique as we like to think: data about other people like me gives you insights about me).
5. Data about us and our communities is collected from our ambient environment (eg satellite imagery, [CCTV cameras](https://www.adalovelaceinstitute.org/biometrics-and-facial-recognition-technology-where-next/), [Wifi signals](https://www.wired.co.uk/article/london-underground-wifi-tracking), [Streetview](https://en.wikipedia.org/wiki/Google_Street_View)) in ways that it is impractical to provide individual consent for.
6. The biases in who opts out of data collection and use aren't well enough understood to compensate for them, which may undermine the validity of analyses of data where opting out is permitted and exacerbate the issue of solutions being designed for majority groups.

The applicability of these arguments varies from case to case. It may be that some of the issues can be mitigated in part through good design: requesting consent in straight forward ways, the availability of easy to understand privacy controls, [finding ways to recognise the consent of multiple parties](https://dataportability.projectsbyif.com/). All these are important both to allow for individual differences and to give people a sense of agency.

But even when consent is sought and controls provided, organisations handling personal data are the ones deciding:



*   What they never do
*   What they only do if people explicitly opt in (defaulting to "never do")
*   What they do unless people opt out (defaulting to "always do")
*   What they always do

Realistically, even with all the information campaigns in the world, and even with excellent design around consent and control over data, even with personal data stores and [bottom up data trusts](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3265315), the vast majority of people will neither opt in nor opt out but stick with the defaults. So in practice, even where a bit of individual choice is granted, organisations are making and will continue to make those assessments about the collection, use and sharing of data I talked about earlier.

Individual consent is theatre. In practice it's no better than the most flexible (and abused) of legal bases for processing data under GDPR - ["legitimate interests"](https://ico.org.uk/for-organisations/guide-to-data-protection/guide-to-the-general-data-protection-regulation-gdpr/lawful-basis-for-processing/legitimate-interests/) - which specifically allows an organisation to make an assessment that balances their own, a third party's, or broader public interest against the privacy interests of data subjects. Organisations that rely on consent for data processing don't even have to demonstrate they carry out the balancing tests required for legitimate interests.

I do not think it's acceptable for organisations to make decisions about how they handle data without giving those affected a voice, and listening and responding to it. But how can we make sure that happens?


## Gaining community consent

Beyond individual consent, mechanisms for ensuring organisations listen to the preferences of people they affect are few and far between. When they rely on legitimate interests as their legal basis for processing data, ICO recommends organisations carry out and record the results of a [Legitimate Interests Assessment (LIA)](https://ico.org.uk/for-organisations/guide-to-data-protection/guide-to-the-general-data-protection-regulation-gdpr/lawful-basis-for-processing/legitimate-interests/). This is a set of questions that prompts an organisation to reflect on whether the processing has a legitimate purpose, that personal data is necessary to fulfill it, and considers the balance of that purpose against individual rights.

But there is no requirement for LIAs to be contributed to, commented on, or even seen by anyone outside the organisation. The only time they become of interest to the ICO is if they carry out an investigation.

I believe that for meaningful accountability, organisations should be engaging with people affected by what they're doing whenever they're making assessments about how they handle personal data. And I think (because data is about multiple people, and its use can have systemic, community and society-wide effects) this shouldn't just include the direct subjects of the data who might provide consent but everyone in the communities and groups who will be affected. Carrying out this community-level engagement is completely compatible with also providing consent and control mechanisms to individuals, where that’s possible.

There are lots of different approaches for engagement:



*   Publishing and seeking comment on LIAs or similar
*   Ethics boards that include representatives from affected groups, or where appropriate elected representatives (eg letting local councils or parliament decide)
*   Carrying out targeted research through surveys, interviews, focus groups or other user research methods
*   Holding [citizen juries](https://www.connectedhealthcities.org/chc-hub/public-engagement/citizens-juries-chc/citizens-juries/) or assemblies where a representative sample of the affected population is led through structured discussion of the options

I note that the Nuffield Foundation has just put out a call for a [review of the evidence on the effectiveness of public deliberation](https://www.nuffieldfoundation.org/news/the-value-of-public-deliberation-request-for-proposals/) like this, so aware I’m not being rigorous here, but it seems to me that in all cases, it's important for participation to be and to be seen as legitimate (for people in the affected communities who are not directly involved to feel their opinions will have been stated and heard). It's vital that organisations follow through in using the results of the engagement (so that it isn't just an engagement-washing exercise). It's also important that this engagement continues after the relevant data processing starts: that there are mechanisms for reviewing objections and changing the organisation's approach as technologies, norms and populations change.

The bottom line is that I would like to see organisations being required to provide evidence that their use of data is acceptable to those affected by it, and to important subgroups that may be differentially affected. For example, if we're talking about data about the use of bikes, the collection and use of that data should be both acceptable to the community in which the monitoring is taking place, and to the subset who use bikes.

I would like to see higher expectations around the level of evidence required for larger organisations than smaller, and higher expectations for those that are in the advantageous position of people not being able to switch to alternative providers that might have different approaches to personal data. This includes both government services and big tech platform businesses.

Perhaps, at a very basic and crude level, to make this evidence easier to create and easier to analyse, there could be some standardisation around the collection of quantitative evidence. For example, there could be a standard approach to surveying, with respondents shown a description of how data is used and asked questions such as "how beneficial do you think this use of data is?", "how comfortable would you feel if data about you was used like this?", "on balance, do you think it's ok to use data like this?". There could be a standard way of transparently summarising the results of those surveys alongside the descriptions of processing, and perhaps statistics about the percentage of people who exercise any privacy controls the organisation offers.

Now I don’t think the results of such surveys should be the entirety of the evidence organisations provide to demonstrate the legitimacy of their processing of personal data, not least because reasoning about acceptability is complex and contextual. But the publication of the results of standard surveys (which could work a bit like the reporting of [gender pay gap data](https://gender-pay-gap.service.gov.uk/)) would furnish consumer rights organisations, the media and privacy advocates with ammunition to lobby for better behaviour. It would enable regulators like ICO to prioritise their efforts on examining those organisations with poor survey results. (Eventually there could be hard requirements around the results of such surveys, but we’d need some benchmarking first.)

Whether this is realistic or not, I believe we have to move forward from critiquing the role of individual consent to requiring broader engagement and consent from people who are affected by how organisations handle data.


## Possible effects

Let’s say that some of these ideas were put into place. What effects might that have?

The first thing to observe is that [people are deeply unhappy](https://theodi.org/article/who-do-we-trust-with-personal-data-odi-commissioned-survey-reveals-most-and-least-trusted-sectors-across-europe/) with how some organisations are using data about them and others. This is particularly true about the tracking and profiling carried out by big tech and adtech and underpinning surveillance capitalism. ODI’s research with the RSA, [“Data About Us”](https://www.thersa.org/discover/publications-and-articles/reports/data-about-us), showed people were also concerned about more systemic impacts such as information bubbles. Traditional market drivers are not working because of network effects and the lack of competitive alternatives. If the organisations involved were held to account against current public opinion (rather than being able to say “but our users consented to the T&Cs”), they would have to change how they operated fairly substantially.

It’s clear that both ICO and the CMA are concerned about the impact on content publishers and existing adtech businesses if the adtech market were disrupted too much and are consequently cautious about taking action. It is certainly true that if adtech intermediaries couldn’t use personal data in the way they currently do, many would have to pivot fairly rapidly to using different forms of data to match advertisers to display space, such as the content and source of the ad, and the content of the page in which it would be displayed. Facebook’s business model would be challenged. Online advertisers might find advertising spend provides less bang for buck (though it’s not clear to me what impact that would have on advertising spend or balance across different media). But arguments about how to weigh these potential business and economic consequences against the impacts of data collection on people and communities are precisely those we need to have in the open.

I can also foresee that a requirement for community consent would mean wider information campaigns from industry associations and others about the benefits of using personal data. Currently the media narrative about the use of personal data is almost entirely negative - to the extent that [Doctor Who bad guys are big tech monopolists](https://en.wikipedia.org/wiki/Spyfall_(Doctor_Who)). Sectors, like health, where progress such as new treatments or better diagnosis often requires the use of personal data, are negatively impacted by this narrative, and can’t afford the widespread information campaigns that would shift that dial. If other industries needed to make the case that the use of personal data can bring benefits, that could mean the conversation about data starts to be more balanced.

Finally, and most importantly, people currently feel dissatisfied, that they don’t have control, and [resigned to a status quo they are unhappy with](https://journals.sagepub.com/doi/abs/10.1177/1461444819833331). Requiring community consent could help provide a greater sense of collective power and agency over how organisations use data that should increase the levels of trust they have in the data economy. I believe that is essential if we are to build a healthy and robust data future.
