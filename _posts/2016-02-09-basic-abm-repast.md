---
layout: post
title: Building a basic agent-based economic model in Repast
---

My [previous post](http://www.jenitennison.com/2016/02/09/abm-information-economy.html) talked about building an agent-based model for the information economy.

Step one is to create the basic agent-based model described in [Wilhite's Bilateral Trade and ‘Small-World’ Networks](http://www.physik-uni-muenchen.de/lehre/vorlesungen/wise_07_08/vorlesung-biophysik-der-systeme/downloads/trade_networks.pdf) in [Repast Simphony](http://repast.sourceforge.net/). In fact I'm going to set myself an even smaller task for this post: setting up the Firm agents to produce FOOD and GOLD without letting them trade.

Let's set up the agents first. Each agent has at any point in time an amount of FOOD and an amount of GOLD. These are set in the `Firm.groovy` code.

```
def currentFood = 0
def currentGold = 0
```

## Calculating utility

From the FOOD and GOLD we can apparently calculate the [utility](https://en.wikipedia.org/wiki/Utility) of the agent using a rudimentary [Cobb-Douglas function](https://en.wikipedia.org/wiki/Cobb%E2%80%93Douglas_production_function) like so:

```
def utility(food, gold) {
	food * gold
}
```

Utility is an economic term and as I said I'm not an economist. According to the Wikipedia article, utility is about commodities, not agents, so I'm not sure that this is "the agent's utility" as such. The Cobb-Douglas function is giving the utility of the commodity generated from the FOOD and GOLD. Since that commodity doesn't go anywhere, I'm taking it that in this model the "current utility" is more like a measure of, in layman's terms, "current wealth". I'd love it if someone corrected my understanding here.

The Cobb-Douglas function used here, and in Wilhite's paper, is one particular form of a more general function:

<math>
    <mi>Y</mi>
    <mo>=</mo>
    <mi>A</mi>
    <mo> &#x2062;<!--INVISIBLE TIMES--> </mo> 
    <msup>
        <mi>L</mi>
        <mi>&beta;</mi>
    </msup>
    <mo> &#x2062;<!--INVISIBLE TIMES--> </mo> 
    <msup>
        <mi>K</mi>
        <mi>&alpha;</mi>
    </msup>
</math>

(Go, MathML! I remember a time you'd have to have a plugin in the page to render that!)

In the version we're using <math><mi>L</mi></math> (usually labour) is FOOD and <math><mi>K</mi></math> (usually capital) is GOLD. These seem like reasonable analogies, or you could argue it the other way round.

As you can see, in the version Wilhite uses, both <math><mi>&alpha;</mi></math> and <math><mi>&beta;</mi></math> are 1. There are some consequences to this ("returns to scale are increasing", whatever that means) but I'm going to follow Wilhite's model for now.

## Choosing what to do

At each step, the agents can choose whether to produce FOOD or to produce GOLD. The amount that they can produce of each at each step is random and needs to be set up when the agent is first created. So I need to define some variables on the agents to hold the values:

```
def foodPerStep = 0
def goldPerStep = 0
```

Then when the agents are created I need to set these randomly (between 1 and 30 is what Wilhite uses). This is in the `UserObserver.groovy` code as the setup function run at the beginning of the simulation:

```
@Setup
def setup(){
	clearAll()
	setDefaultShape(Firm, "circle")
	createFirms(500){
		setxy(randomXcor(),randomYcor())
		foodPerStep = random(29) + 1
		goldPerStep = random(29) + 1
	}
}
```

You'll notice that I decided to make the Firms circles in the visualisation and distribute them randomly. Good enough for now. And I'm making 500 Firms: that's the number Wilhite used.

On each step, each Firm will decide whether to produce FOOD or produce GOLD, based on which increases their utility the most. The choice is in this code:

```
def step() {
	def utilityMakingFood = utility(currentFood + foodPerStep, currentGold)
	def utilityMakingGold = utility(currentFood, currentGold + goldPerStep)
	if (utilityMakingFood > utilityMakingGold) {
		currentFood += foodPerStep
	} else {
		currentGold += goldPerStep
	}
}
```

Note that if it doesn't make a difference whether FOOD or GOLD gets produced, it'll produce GOLD.

To make that work, the `UserMonitor.groovy` code needs to call the `Firm.step()` method for each Firm on each step:

```	
@Go
def go() {
	ask(firms()){
		step()
	}
}
```

## Monitoring

When you run this code in Repast it generates a rather pretty picture of lots of multi-coloured circles (completely meaningless of course):

![Randomly distributed firms in Repast](/assets/2016-02-09/firms.png)

Repast lets you monitor individual agents. So I can see that the first agent in the simulation has a `foodPerStep` of 12 and a `goldPerStep` of 1. Here's how its food and gold changes over the ticks of the simulation:

| step | FOOD | GOLD | utility |
| - | - | - | - |
| 0 | 0 | 0 | 0 |
| 1 | 0 | 1 | 0 |
| 2 | 12 | 1 | 12 |
| 3 | 12 | 2 | 24 |
| 4 | 24 | 2 | 48 |
| 5 | 24 | 3 | 72 |
| 6 | 36 | 3 | 108 |

So things are working as expected (if not in any very interesting way, since the agents aren't currently interacting with each other).

## Thinking ahead

The main next step is to get trade working between the agents, which will hopefully make things more interesting. There are several areas that seem extremely simplified:

  * I'm not sure that <math><mi>&alpha;</mi></math> and <math><mi>&beta;</mi></math> in the Cobb-Douglas function should both be 1. I think perhaps they should sum to 1 (eg be 0.75 and 0.25). Maybe different agents should have slightly different values for those exponents.
  
  * If the projected benefit of making FOOD or GOLD are the same, perhaps the agent should randomly choose between them rather than always producing GOLD. That would introduce a bit more randomness into the simulation.
  
  * Currently, the amount of FOOD and GOLD that the agent can produce at each step is distributed evenly across the agents: roughly the same number of agents will be able to produce between 1-5 FOOD as between 10-15 FOOD as between 25-30 FOOD. There are various other distributions that could be used: perhaps a exponential distribution to reflect the fact that there are many more small companies than large ones.
  
  * Shouldn't the ability of an organisation to produce be related to its current holdings? I would have thought that the production ability of a firm should be proportional to its existing FOOD and GOLD rather than fixed throughout its life.
  
  * Shouldn't there be some consumption of FOOD and GOLD that leads to firms going bankrupt if they don't have minimum levels? Should there be some mechanism for new entrants to appear? If we're looking at an area where there is innovation, these factors seem important.
  
I keep reminding myself that examining what happens when these tweaks are added is part of the experimentation that the model enables. The main goal at this stage is just to replicate Wilhite.

The one piece where I will need to make a decision is in how to fit DATA's role into the Cobb-Doublas function to represent the value of information or knowledge. I'd value some guidance on this. The two options that I can think of are:

  * DATA is <math><mi>A</mi></math>. <math><mi>A</mi></math> is supposed to be "[Total factor productivity](https://en.wikipedia.org/wiki/Total_factor_productivity)", representative of technological growth and efficiency.
  
  * DATA adjusts <math><mi>&alpha;</mi></math> and/or <math><mi>&beta;</mi></math>. These are supposed to be the "[output elasticities](https://en.wikipedia.org/wiki/Output_elasticity)" of labour and capital, ie increasing the utility from the same amount of FOOD and/or GOLD. This could be rationalised as data providing the ability to get more output from the same inputs.

Using DATA in either of these ways will change the way in which utility is measured but scale in different ways. I'm inclined to use the simplest (DATA is <math><mi>A</mi></math>) as a starting point.

## Trying it out

If you want to try out where I've got to so far, I've committed the source code to [Github](https://github.com/theodi/abm-information-economy) and there are instructions there about how to run it. Any comments/PRs will be gratefully received.



