---
layout: post
title: How can you control how data gets used?
---

Democracy Club are [asking for advice](https://twitter.com/democlub/status/1179788208504262660) on some [changes they’re considering making to their API’s terms and conditions](https://democracyclub.org.uk/blog/2019/10/03/one-possible-api-terms-use-changes/). They’re considering changes for two reasons: to enable them to track impact and to give them the right to withdraw access from those they believe are damaging democracy or Democracy Club’s reputation. Here’s my reckons.

## Service T&Cs vs data licences

When you are making decisions about terms and conditions around data provided through an API, you actually have to worry about two things:
restrictions on who gets to use the API or how they can use it
restrictions on what people who get access to the data can do with it

It’s important to think of these separately as it makes you more realistic about what you can and can’t monitor and control and therefore more likely to put useful mechanisms in place to achieve your goals.

To help with thinking separately about these two things, don’t think about the simple case of someone building an app directly on your API. Instead imagine a scenario where you have an intermediary who uses the API to access data from you, augments the data with additional information, and then provides access to that augmented data to a number of third parties who build applications with it.

If you think your data is useful and you want it to be used, this should be something you want to enable to happen. Combining datasets helps generate more valuable insights. Organisations that provide value added services might make money and create jobs and bring economic benefits, or at least give people something to hack on enjoyably over a weekend.

In this scenario, you have two technical/legal levers you can use to restrict what happens with the data:

  1. You can control access to the API. This is technically really easy, using API keys. And you can write into your T&Cs the conditions under which you will withdraw access privileges. The trouble is that when there are intermediaries, you cannot, on your own, selectively control access by the end users that the intermediaries serve. The intermediary won’t access your API for each request they receive: they will batch requests and cache responses and so on in order to reduce their load and reliance on you. So if there is a single bad actor on the other side of an intermediary, and API keys are your only lever, you will be faced with the decision of cutting off all the other good actors or tackling the bad actor through some other mechanism.

  2. You can put conditions in the data licence. You can of course put any conditions you like into a licence. But there are three problems with doing so. First, restrictions within a licence can mean that data cannot be combined with other data that people might feasibly want to combine it with. In particular, data that isn’t available under an open licence can’t be combined with data available under a share-alike licence, such as that from OpenStreetMap. Second, if everyone does this, intermediaries who combine data from lots of sources with different licences end up with all sorts of weird combination licences so you get not only licence proliferation but ever expanding complexity within those licences, which makes things complex for data users who are further downstream. Third, you have to be able to detect and enforce breaches. Detection is hard. Enforcement is costly - it’s a legal battle rather than a technical switch.

The viral complexity and practical unenforceability of restrictive data licences is why I would always recommend simply using an open licence for the data itself - make it open data. You can still have terms and conditions on the API while using an open licence for the data, but you need to recognises their limitations too.

So with that in mind, let’s consider the two goals of understanding impact and preventing bad uses with this scenario in mind.

## Understanding impact

Here you have three choices:

  1. Track every use of your data. You will need to gather information about every direct user of your API, but you will also need a mechanism for intermediaries to report back to you about any users they have. You will need to have a way of enforcing this tracking, so that intermediaries don’t lie to you about how many people are using their services. This requirement will also restrict how the intermediaries themselves work: they couldn’t, for example, just publish the augmented data they've created under an open licence for anyone to download; they’ll have to use an API or other mechanism to track uses as well.

  2. Track only direct uses of your data. This is easy enough with a sign-up form of course, when you give out API keys. But be aware that some people will obfuscate who they are because they’re contrary sods who simply don’t see why you need to know so much about them. How much do you care? What rigour are you going to put around identity checks?

  3. Track only the uses people are kind enough to tell you about. Use optional sign-up forms. Send public and private requests for information about how people are using your data and how it’s been useful. Get trained evaluators to do more rigorous studies every now and then.

Personally, I reckon all impact measures are guesses, and we can never get the entire picture of the impact of anything that creates changes that are remotely complex or systemic. Every barrier you put in place around people using data is a transaction cost that reduces usage. So personally, if your primary goal is for the data you steward to get used, I would keep that friction as low as possible - provide sign-up forms to supply API keys, but make the details optional - and be prepared to explain to whomever asks that when you describe your impact you can only provide part of the picture. They're used to that. They'll understand.

## Withdrawing access from bad actors

When you provide infrastructure, some people who use that infrastructure are going to be doing bad stuff with it. Bank robbers escape by road. Terrorists call each other on the phone. Presidents tweet racist comments. What's true for transport, communications and digital infrastructure is true for data infrastructure.

It is right to think about the bad things people could do and how to respond to these inevitable bad actors, so that you give yourselves the levers you need to act and communicate clearly the rules of the road. You also need to think through the consequences for good actors for the systems you put in place.

First question: how are you going to detect bad actors in the first place? Two options:

  1. Proactively check every use of the data you’re making available to see if you approve of it. This is prohibitively expensive and unwieldy for you and introduces a large amount of cost and friction for reusers, especially given some will be using it through intermediaries.

  2. Reactively respond to concerns that are raised to you. This means you will miss some bad uses (perhaps if they happen in places you and your community don’t usually see). It also means anyone who uses the data you provide will need to live with the risk that someone who disagrees with what they’re doing reports them as a bad actor. Sometimes that risk alone can reduce the willingness to reuse of data.

Second question: how will you decide whether someone is a good or bad actor? There are some behaviours that are easily to quantify and detect (like overusing an API). But there are other behaviours where “bad” is a moral judgement. These are by definition fuzzy and the fuzzier they are, the more uncertainty there is for people reusing data about whether, at some point in the future, it might be decided that what they are doing is “bad” and the thing they have put time into developing be rendered useless. How do you give certainty to the people thinking about using the data you are providing? What if the people contributing to maintaining the data you're stewarding disagree with your decision (one way or another)? When you make a judgement against someone do they get to appeal? To whom?

Third question: what are you going to do about it? Some of the actions you think are bad won’t be ongoing - they might be standalone analyses based on the data you're providing, for example. So withdrawing access to the API isn’t always going to be a consequence that matters for people. Does that matter? Do people who have had API access withdrawn ever get to access it again, if they clean up their act? How will you detect people who you ban through one intermediary potentially accessing it again through another, or those who have accessed the API directly using an intermediary to do so instead?

It is completely possible to put in place data governance structures, systems and processes that can detect, assess and take action against bad actors. Just as it's possible to have traffic police, wiretaps and content moderation. But it needs to be designed proportionally to the risks and in consideration of the costs to you and other users.

If we were talking about personal health records, I would be all for proactive ethical assessment of proposed uses, regular auditing of reusers and their systems, and having enough legal firepower to effectively enforce these terms and discourage breaches.

But with a collaboratively maintained register of public information, for me the systemic risks of additional friction and uncertainty that arise from introducing such a system, and the fact you can't make it watertight anyway within the resources of a small non-profit, make me favour a different approach. 

I would personally do the following:

  1. Make a very clear statement that guarantees you will not revoke access through the API except in very clearly defined, objectively verifiable circumstances, such as exceeding agreed rate limits. This is what you point to as your policy when people raise complaints about not shutting off access to people they think are bad. Write up why you've adopted this policy. Indicate when you will review it, the circumstances in which it might change, and the notice period you'll give of any changes. This is to give certainty to the people you want to use and build on the data.

  2. Institute an approvals scheme. Either give those approved a special badge or only let those who get your approval use your logo or your name in any advertising they do of their product. Publish a list of the uses that have been approved and why (they're great case studies too - look, impact measurement!). Make it clear in your policy that the only signal that you approve of a use of the data you're providing is this approvals process. It will take work to assess a product so charge for it (you can have a sliding scale for this). Have the approval only last a year and make them pay for renewal.

  3. Name and shame. When you see uses of the data you steward that you disagree with or think are bad, write about them. Point the finger at the people doing the bad thing and galvanise the community to put pressure on them to stop. Point out the use is not approved by you. Point out that these bad uses make you more likely to start placing harder restrictions on everyone's use and access in the future.

I do not know whether anyone will go for an approvals scheme. It depends on how much being associated with you matters to them. It's worth asking, to design it in a way that works for them and you.

And this approach will not protect you from all criticism or feeling bad about people doing bad things using the infrastructure you've built. But nothing will do that. Even if you design a stricter governance system, people will criticise you when they disagree with your moral judgements. They will criticise you for arbitrariness, unfairness, lack of appeal, lack of enforcement, not listening to them etc etc etc. Bad stuff will happen that you only work out months down the line and couldn't have done anything about anyway. You'll take action against someone who goes on to do something even worse as a consequence.

Life is suffering.

If you don't take the approach outlined above, then do aim to:

  * Communicate clearly with potential reusers about what you will do, so they can assess the risks of depending on the data you're making available.

  * Have a plan for how to deal with bad actors that access data through intermediaries.

  * Have a plan for how to deal with bad actors that perform one-off analyses.

And either way, do try to monitor and review what the impact of whatever measures you put in place actually are. Ask for feedback. Do user research. We're all working this out as we go, and what works in one place won't work in another, so be prepared to learn and adapt.

For more discussion / other opinion see [comments from Peter Wells and others on the original Democracy Club post](https://docs.google.com/document/d/148kYvEFiN-WDgRW7RQfim-SICB4RHpHnP45IYs0zH68/edit#) and the obligatory Leigh Dodds blog posts:

  * [What is an Open API?](https://blog.ldodds.com/2014/03/25/what-is-an-open-api/)
  * [How do data publishing choices shape data ecosystems?](https://blog.ldodds.com/2019/07/24/how-do-data-publishing-choices-shape-data-ecosystems/)
  * [How can open data publishers monitor usage?](https://blog.ldodds.com/2015/11/25/how-can-open-data-publishers-monitor-usage/)
