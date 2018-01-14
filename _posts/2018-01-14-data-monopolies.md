---
layout: post
title: Doesn't open data make data monopolies more powerful?
---

We live in a world where a few, mostly US-based companies hold huge amounts of data about us and about the world. Google and Facebook, and to a lesser extent Amazon and Apple, (GAFA) make money by providing services, including advertising services, that make excellent use of this data. They are big, rich, and powerful in both obvious and subtle ways. This makes people uncomfortable, and working out what to do about them and their impact on our society and economy has become one of the big questions of our age.

An argument has started to emerge against [opening data](https://theodi.org/guides/what-open-data), particularly government owned data, because of the power of these data monopolies. "If we make this data available with no restrictions," the argument goes, “big tech will suck it up and become even more powerful. None of us want that.”

I want to dig into this line of argument, the elements of truth it contains, why the conclusion about not opening data is wrong, why the argument is actually being made, and look at better ways to address the issue.

## More data disproportionately benefits big tech

It is true that big tech benefits, and benefits disproportionately to smaller organisations, from the greater availability of data.

Big tech have great capacity to work with data. They are geared to getting value from data: analysing it, drawing conclusions that help them grow and succeed, creating services that win them more customers. They have an advantage in both skills and scale when it comes to working with data.

Big tech have huge amounts of data that they can combine. Because of the network effects of linking and aggregating data together, the more data they have, the more useful that data becomes. They have an advantage because they have access to more data than other organisations.

## Not opening data disproportionately damages smaller organisations

It is also true that small organisations suffer most from not opening data. Access to data enables organisations to experiment with ideas for innovative products and services. It helps them make better decisions, faster, which is particularly important for small organisations who need to make good choices about where to direct their energies or risk failure.

If data is sold instead of opened, big tech can buy it easily while smaller organisations are less able to afford to. Big tech have cash to spare, in house lawyers and negotiators, and savvy developers used to working with whatever copy or access protection is put around data. The friction that selling data access introduces is of minimal inconvenience to them. For small organisations, who lack these things, the friction is proportionately much greater. So on top of the disproportionate benefits big tech get from the data itself, they get an extra advantage from the barriers selling data puts in the way of smaller organisations.

If data isn't made available to them (for example because they can't negotiate to acceptable licensing conditions or the price is too high), big tech have the money and user base that enable them to invest in creating their own versions. Small organisations simply cannot invest in data collection to anywhere near the same scale. The data that big tech collects is (at least initially) lower quality than official versions, but it usually improves as people use it and correct it. Unlike public authorities, big tech have low motivation to provide equal coverage for everyone, favouring more lucrative users.

An example is addresses in the UK. Google couldn't get access to that data under licensing conditions they could accept, so they built their own address data for use in Google Maps. Professionals think it is less accurate than officially held records. It particularly suffers outside urban and tourist areas because fewer people live there and there’s less need for people to use Google’s services there, which means less data available for Google to use to correct it.

## Using different terms & conditions for different organisations doesn't help

"Ah," I hear you say, “but we can use different terms & conditions for different kinds of organisations so smaller ones don't bear the same costs.”

It is true that it is possible to [construct licensing terms](https://theodi.org/guides/impacts-of-non-open-licenses) and differential charging schemes that make it free for smaller firms to access and use data and charge larger firms. You can have free developer licences; service levels that flex with the size of companies (whether in employees or turnover or terminals); non-commercial licences for researchers, not-for-profits and hobbyists.

These are all possible, but they do not eliminate the problems.

First, the barrier for smaller organisations is not just about cash but about time and risk. Differential licensing and charging schemes are inevitably complex. Organisations have to understand whether they qualify for a particular tier and whether they are permitted to do what they want to do with the data. This takes time and often legal fees. The latter is often hard to work out because legal restrictions on particular data processing activities tend not to be black and white. They require interpretation and create uncertainty. This means organisations have to protect themselves against litigation arising from unintended non-compliance with the terms, which adds the cost of insurance. The more complex the scheme, the greater this friction.

Second, the clauses within a free licence always include one that prevents the organisation undercutting the original supplier of the data and selling it on to large organisations. Necessarily, this will place restrictions on the services that an organisation offers and the business model they adopt. They might be unable, for example, to build an API that adds value by providing different cuts of data on demand, or if they do their price might be determined by additional fees from the original supplier. Licensing restrictions limit what kinds of organisations can benefit from the data, and their ability to make money. And, as above, uncertainty about the scope of the restrictions (and whether the originating organisation will ever actually act on them) introduce risk and costs.

Third, while these costs and barriers are bad enough with one set of data, add another from a different supplier with another set of conditions, and [you have to make sure you meet both of them](https://github.com/theodi/open-data-licensing/blob/master/guides/licence-compatibility.md). Sometimes this will be impossible (for example combining OpenStreetMap data, available under a share-alike licence, with non-commercial data). Add a third or fourth and you're dealing with a combinatorial explosion of T&C intersections to navigate.

In part, the problems with differential pricing approach for data arise from the unique characteristics of data and the data economy.

  * it is **endlessly manipulable** which makes it necessarily complex to list all the ways in which you can, or can't, use it, and which are allowed and which not

  * the greatest opportunities for innovation and growth are within **infomediaries** who slice and dice and add value to datasets; they need freedom to thrive

  * added value usually comes from the **network effects** of combining multiple datasets; but if there's friction inherent in bringing datasets together, those same network effects will amplify that friction as well

It's not surprising that people who are used to selling other kinds of things than data reach for "free licences for startups" as a solution to lower costs for smaller organisations. It seems an obvious thing to do. It might work for other kinds of products. It doesn't work for data.

## Opening data is better than not opening data

So far I've focused almost exclusively on the impacts of opening and not opening data on innovation and the ability of small businesses to thrive in comparison to big tech. I've discussed why selling or restricting access to and use of data favours big tech over and above the advantages they already receive from amassing more data.

If you like to think of playing fields, it's true that opening data lifts big tech’s end of the pitch, but overall, it lifts the startup’s end more.

There are a few other considerations it's worth quickly touching on.

### Do we want big tech to use high quality data?

Earlier I wrote about how big tech makes its own data when it can't get hold of official sources. They stitch together information from remote sensors, from what people upload, from explicit corrections, use clever machine learning techniques and come out with remarkably good reconstructions.

But "remarkably good" is not comprehensive. It is often skewed towards areas of high user demand, whether that's cities rather than countryside or favouring the digitally included.

When big tech uses its own data rather than official data to provide services to citizens, it favours the enfranchised. It exacerbates societal inequalities.

It can also cost lives. I talked about Google's address data and the doubts about its accuracy particularly outside towns and cities. Ambulances have started using it. When they are delayed because they go to the wrong place, people can die. Restricting access to address data forced Google to spend a bunch of money to recreate it, but who is actually suffering the consequences?

Not all services require the same level of detail in data. The impact of data errors is higher for some products than for others. But in general, we should want the products and services we use to be built on the highest quality, most reliable, most authoritative, timely, and comprehensive data infrastructure that we can provide. When we restrict access to that by not permitting companies with massive user bases amongst our citizenry to use that data, we damage ourselves.

### What about big tech’s other advantages with data?

I've focused much of this on the advantage big tech enjoys in having access to data. As I touched on earlier, they also have an advantage in capability. If there's a real desire to equalise smaller companies with big tech, they need support in growing their capability. This isn't just about skills but also about tool availability and the ease of use of data.

Anything that helps people use data quickly and easily removes friction and gives a disproportionate advantage to organisations who aren't able to just throw extra people at a problem. Make it available in standard formats and use standard identifiers. Create simple guides to help people understand how to use it. Provide open source tools and libraries to manipulate it. These are good things to do to increase the accessibility of data beyond simply opening it up.

### How do we make this benefit society as a whole?

I’ve also been focusing deliberately on the narrow question of how we level the playing field between small organisations and big tech. Of course it’s not the case that everything small organisations do is good and everything big tech does is evil. Making data more open and accessible doesn’t ensure that anyone builds what society as a whole needs, and may mean the creation of damaging tools as well as beneficial ones. There might even (whisper it) be issues that can’t be solved with tech or data.

That said, the charities, community groups, and social enterprises that are most likely to want to build products or produce insights with positive social impact are also likely to be small organisations with the same constraints as I’ve discussed above. We should aim to help them. We can also encourage people to use data for good through targeted stimulus funding towards applications that create social or environmental benefits, as we did in the [Open Data Challenge Series that ODI ran with Nesta](https://www.nesta.org.uk/project/open-data-challenge-series).

## Making it fair

When you dig into why people actually cite increasing inequality between data businesses as a reason for not opening data, it usually comes down to it feeling unfair that large organisations don’t contribute towards the cost of its collection and maintenance. After all, they benefit from the data and can certainly afford to pay for it. In the case of government data, where the public is paying the upkeep costs, this can feel particularly unfair.

It is unfair. It is unfair in the same way that it’s unfair that big tech benefits from the education system that the PhDs they employ went through, the national health service that lowers their cost of employment, the clean air they breathe and the security they enjoy. These are all public goods that they benefit from. The best pattern we have found for getting them, and everyone else who enjoys those benefits, to pay for them is taxation.

Getting the right taxation regime so that big tech makes a fair contribution to public goods is a large, international issue. We can't work around failures at that level by charging big tech for access to public data. Trying to do so would be cutting off our nose to spite our face.

What can be done from a data perspective, whether a data steward is in the public sector or not, is to try to lower the costs of collection and maintenance. Having mechanisms for other people and organisations to correct data themselves, or even just highlight areas that need updating by the professionals, can help to distribute the load. Opening data helps to motivate collaborative maintenance: the same data becomes a common platform for many organisations and individuals, all of whom also contribute to its upkeep, just like [Wikipedia](https://en.wikipedia.org/wiki/Wikipedia:About), [wikidata](https://www.wikidata.org/wiki/Wikidata:Main_Page) and [OpenStreetMap](https://www.openstreetmap.org/). With government data, this requires government to shift its role towards being a platform provider — [legislation.gov.uk’s Expert Participation Programme](https://theodi.org/case-studies/case-study-legislationgovuk) demonstrates how this can be done without compromising quality.

## Big tech and data monopolies

I have focused on big tech as if all data monopolies are big tech. That isn’t the case. What makes a data monopoly a monopoly is not that it is big and powerful and has lots of users, it's that it has a monopoly on the data it holds. These appear as much in the public sector as the private sector. Within the confines of the law, they get to either benefit exclusively or choose the conditions in which others can benefit from the data they hold.

Some of that data could benefit us as individuals, as communities and as societies. Rather than restricting what data of ours data monopolies can access, another way to level the playing field is to ensure that others can access the data they hold by making it as open as possible while protecting people’s privacy, commercial confidentiality and national security. Take the [1956 Consent Decree against Bell Labs](http://voxeu.org/article/how-antitrust-enforcement-can-spur-innovation) as inspiration. That decree forced Bell Labs to license their patents royalty free. It increased innovation in the US over the long term, and particularly that by startups.

There are various ways of making something similar happen around data. At the soft, encouraging end of the spectrum there are collaborative efforts such as [OpenActive](https://www.openactive.io/) or making positive noises whenever [Uber Movements helps cities gain insights](https://movement.uber.com/use-case/ipa?lang=en-GB), or [Facebook adds more data into OpenStreetMap](https://groups.google.com/forum/#!msg/openstreetmap/IuX9LUF-u88/WIjr6jZqBgAJ) or supports [EveryPolitician](https://www.mysociety.org/2017/06/09/increasing-political-engagement-with-facebook/). At the hard regulatory end of the spectrum, we see legislation: the new [data portability right in GDPR](http://www.jenitennison.com/2017/12/26/data-portability.html); the rights given under the Digital Economy Act to the Office of National Statistics in the UK to [access administrative data held by companies](https://blog.ons.gov.uk/2016/11/10/tapping-into-new-data-sources/); the [French Digital Republic Act’s definition of data of public interest](https://www.republique-numerique.fr/pages/digital-republic-bill-rationale); the [Competition & Markets Authority Order on Open Banking](https://www.gov.uk/government/news/cma-paves-the-way-for-open-banking-revolution).

We should be much more concerned about unlocking the huge value of data held by data monopolies for everyone to benefit from — building a strong, fair and sustainable data infrastructure — than about getting them to pay for access to public data.

Opening up authoritative, high quality data benefits smaller companies, communities, and citizens. There’s no doubt that it also benefits larger organisations. But attempts at ever more complex restrictions about who can use data are likely to be counterproductive. There are other ways of leveling these playing fields.
