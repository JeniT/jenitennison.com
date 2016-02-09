---
layout: post
title: "Agent-Based Model of the Information Economy: Initial Thoughts"
---

There are several [studies on the impact of open data](https://medium.com/@ODIHQ/the-economic-impact-of-open-data-what-do-we-already-know-1a119c1958a0#.gafuoqaqu), ranging from specific case studies through to macroeconomic studies that estimate the overall impact of greater availability of information.

Case studies are problematic because they tend to look only at effects around specific datasets or companies, and it's hard to know how or whether these scale up to the economy as a whole. From what I've seen of the macroeconomic studies, on the other hand, they tend to be based on estimates created by multiplying big numbers together and don't reveal who the winners and losers might be in a more open information-based economy.

Is it the case that opening data simply increases the gap between the information haves and have-nots, and that leads to wider economic inequality, or does everyone benefit when information is more widely available? Are there tipping points of availability at which we start realising the benefits of open data? What is the role of government in encouraging data to be more widely available and more widely used? To what extent should government invest in data infrastructure as a public good? How can local or specialist cooperatives pool resources to maintain data?

These are the kinds of questions we have answer in order to help frame public policy. While I can come up with and rationalise answers to those questions, I would prefer that they were based on something slightly more rigorous than a persuasive argument.

So I have been thinking recently about applying [Agent-Based Modelling](https://en.wikipedia.org/wiki/Agent-based_model) (ABM) or more specifically [Agent-based Computational Economics](https://en.wikipedia.org/wiki/Agent-based_computational_economics) (ACE) to the information economy. These seem to be promising techniques to get under the skin of the kind of impact that data might have on the variety of actors that there are within the economy, and to understand how public policy might affect that impact.

Now, I am not an economist, I do not have any background in agent-based modelling and it's been a long time since I could justifiably call myself an artificial intelligence researcher. I'd like to learn about this field, and need to in order to pursue the goals described above. I hope other people will forgive my ignorance and mis-steps, and behave as this XKCD encourages:

[![](http://imgs.xkcd.com/comics/ten_thousand.png)](http://xkcd.com/1053/)

## Model design

I'll share where my thinking is at so far.

The useful [Tutorial on agent-based modelling and simulation](http://www.palgrave-journals.com/jos/journal/v4/n3/full/jos20103a.html) contains a number of [questions](http://www.palgrave-journals.com/jos/journal/v4/n3/full/jos20103a.html#.-Methods-for-agent-based-modelling) to help modellers focus on what they want to achieve:

**What specific problem should be solved by the model? What specific questions should the model answer? What value-added would agent-based modelling bring to the problem that other modelling approaches cannot bring?**

I've described above the kind of questions that I have in mind. Trying to be more specific, I'd like to explore:

  * What different groups or clusters of agents emerge in an information economy? Via an [undergraduate dissertation](http://www.doc.ic.ac.uk/teaching/distinguished-projects/2009/g.hagen.pdf) by Gemma Hagen, I've found a [paper](http://fmwww.bc.edu/cef00/papers/paper273.pdf) by Allen Wilhite that talks about the emergence of specialisation in production or in trade. The [Deloitte report on PSI](https://www.gov.uk/government/uploads/system/uploads/attachment_data/file/198905/bis-13-743-market-assessment-of-public-sector-information.pdf) talks about information holders, infomediaries, consumers and enablers: is there a model in which these roles emerge?
  * What difference does it make to overall [productivity](https://en.wikipedia.org/wiki/Productivity) in an economy when there is a culture of data being open, available for anyone to access, use and share, as opposed to paid-for, available only to researchers or for non-commercial use, or completely closed?
  * How do share-alike licences propagate within an information economy? I would like to be able to work out whether we would achieve higher productivity by promoting share-alike licensing rather than public domain or attribution-based licensing.

An agent-based approach enables the study of emergent roles and enables us to tweak parameters to explore the difference that policy positions, capability building and emerging technologies might provide.

**What should the agents be in the model? Who are the decision makers in the system? What are the entities that have behaviours? What data on agents are simply descriptive (static attributes)? What agent attributes would be calculated endogenously by the model and updated in the agents (dynamic attributes)?**

Models of the [circular flow of income](https://en.wikipedia.org/wiki/Circular_flow_of_income) contain additional agents. A two-sector model includes Households and Firms; a three sector model introduces Government. Given that I am particularly interested in the role of government and information held or gathered by the public sector, I think the model should eventually include Government, but I'm tempted to keep it really simple and only consider Firms in the first instance. Given at the moment I'm not so interested in the role of citizens, I think it shouldn't include Households but instead abstract away their contribution.

In the [Wilhite model](http://fmwww.bc.edu/cef00/papers/paper273.pdf) there is only one type of agent (a Firm) but different Firms have different (randomly assigned) abilities to produce Goods of two types which you might characterise as FOOD and GOLD, which means that they naturally fall into different categories as producers or (if they're not very good at production) traders.

So to start with, to keep it simple, I think the model should assign each Firm agent with a variable capacity to create DATA, FOOD and GOLD. We can imagine that agents that can create a lot of GOLD are services companies; those that can create a lot of FOOD are factories; those that can create a lot of DATA are technology companies.

Each agent will keep track of their DATA, FOOD and GOLD. To simulate the role of DATA within a Firm, I think that the amount of DATA held by the Firm should influence its productivity, namely its ability to create more FOOD or GOLD. Calculated from the amount of FOOD and GOLD held by the Firm is its wealth, which the Firm will attempt to maximise.

**What is the agents’ environment? How do the agents interact with the environment? Is an agent's mobility through space an important consideration?**

I'm not sure whether to include proximity between Firms within the model. To keep it simple, and especially to mirror the fact that when it comes to exchanges of data, distance doesn't matter, I'm tempted to simply have the agents co-existing in a soup.

**What agent behaviours are of interest? What decisions do the agents make? What behaviours are being acted upon? What actions are being taken by the agents?**

Mirroring the Wilhite model, I plan to let the agents choose between the following actions:

  * produce DATA, FOOD or GOLD
  * trade DATA, FOOD or GOLD with other Firms

In the initial model, they should choose between these actions based on which is going to increase their wealth the most. To ensure that agents ever want to trade for DATA, given that it doesn't contribute directly to their wealth, they will need to have at least some predictive ability: to look forward to what they will be able to do if they have more DATA.

The other thing that makes DATA distinctive is that it is [non-rivalrous](https://en.wikipedia.org/wiki/Rivalry_\(economics\)). When it is traded, the original owner of the DATA doesn't lose it. I'll have to see how and whether that leads to sensible costing for DATA - I suspect that I'll have to introduce knowledge of prior prices or earlier deals into the model to make it work.

**How do the agents interact with each other? With the environment? How expansive or focused are agent interactions?**

The Firms will interact with each other through trade. They can trade either DATA or FOOD for GOLD or vice versa, with a willing partner.

**Where might the data come from, especially on agent behaviours, for such a model?**

I aim to dig into the existing macroeconomic studies to see what estimates they use for the added productivity associated with access to data. I can also base behaviours on the [Open data means business](http://theodi.org/open-data-means-business) study we did at ODI. I'm open to other suggestions.

**How might you validate the model, especially the agent behaviours?**

There are [statistics](https://beta.ons.gov.uk/businessindustryandtrade/business/activitysizeandlocation) on the distribution of Firm sizes and sectors within the UK economy that could be used to validate the model. We can see whether instances emerge that match some of the case studies that we use. Again, I'm open to sugestions.

## Modelling software

There's a [whole bunch of agent-based modelling software](https://en.wikipedia.org/wiki/Comparison_of_agent-based_modeling_software) out there. I'll admit when I looked at that list I was put off by the number of Java-based implementations, because it's been something like 15 years since I last wrote Java. 

I did like the look of [ABCE](http://abce.readthedocs.org/en/latest/) because it's Python (even though I don't know Python very well either) and has a lot of the basic economic model that's needed built-in. However, I was concerned that it might be hard to adapt it to an information economy because its primitive operations assume the transfer of physical goods, and about its relative immaturity.

Eventually I've settled on using [Repast Simphony](http://repast.sourceforge.net/). The main reason for adopting it is the level of support that's available, the [easy-to-follow tutorial](http://repast.sourceforge.net/docs/ReLogoGettingStarted.pdf) being a good example.

## Final thought

I didn't know anything about this field - not even that it was called agent-based computational economics - when I started looking on Friday night. By Sunday evening I had written my first agent-based model using the Repast tutorial and had a reasonably good idea about what to try first.

It's at times like these when you realise quite how *amazing* the web is, how transformational. I can't even imagine how I would have gotten started looking at this without it. But you also realise that *we* make this web through being generous with our time and knowledge, and not just on Wikipedia and Twitter. Take a look at these fantastic [pages maintained by Leigh Tesfatsion](http://www2.econ.iastate.edu/tesfatsi/ace.htm) on agent-based computational economics. From the HTML I guess they were started some time ago; the dates indicate they are still maintained. They contain tutorials, references to prior work, pointers to people working in the field. I have barely scratched the surface.

You also realise the tragedy of restricted access to academic research. The papers whose abstracts seem interesting but probably not £30 interesting. The book chapters that you can read snippets of, or pay £80 for. A world where those outside academia can't easily access academic research is one where that research can have little impact.

I've created a [repository on Github](https://github.com/theodi/abm-information-economy) which I'll use for code as it comes (currently all it has is the README and an open licence!). If you have any comments, advice or suggestions then please use the [issue list](https://github.com/theodi/abm-information-economy/issues) there.