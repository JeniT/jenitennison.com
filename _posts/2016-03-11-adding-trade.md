---
layout: post
title: Introducing trade to a basic agent-based economic model
---

My next step in [building an agent-based model for the information economy](http://www.jenitennison.com/2016/02/09/abm-information-economy.html) is to add trade to the [basic model](http://www.jenitennison.com/2016/02/09/basic-abm-repast.html).

The trade protocol is described in [Wilhite's Bilateral Trade and ‘Small-World’ Networks](http://www.physik-uni-muenchen.de/lehre/vorlesungen/wise_07_08/vorlesung-biophysik-der-systeme/downloads/trade_networks.pdf). First, you calculate the [marginal rate of substitution](TODO) for an agent: the amount of GOLD that they would need to exchange for a unit of FOOD in order to increase their [utility](https://en.wikipedia.org/wiki/Utility). This can be calculated for each agent as:

<math>
  <mi>mrs</mi>
  <mo>=</mo>
  <mfrac>
    <mi>GOLD</mi>
    <mi>FOOD</mi>
  </mfrac>
</math>

or in code form:

```
def mrs() {
	currentGold / currentFood
}
```

If this is greater than 1 then the Firm would rather buy FOOD (give up GOLD for FOOD). If it's less than 1 then the Firm would rather sell FOOD (give up FOOD for GOLD).

## Working out a fair price

Now imagine you have two Firms, A and B. Firm A has 20 GOLD and 10 FOOD (a utility of 20 &times; 10 = 200, and a mrs of 20 / 10 = 2). Firm B has 10 GOLD and 20 FOOD (with a utility of 200 as well, but a mrs of 10 / 20 = 0.5). These two firms can beneficially trade with each other to maximise their utility. If Firm A buys 5 FOOD from Firm B for 5 GOLD, both Firms end up with 15 GOLD and 15 FOOD, a utility of 225 with a mrs of exactly 1. This is the best they can do: if Firm A buys 4 FOOD for 4 GOLD they both end up with a utility of 14 &times; 16 = 224, if Firm A buys 6 FOOD for 6 GOLD they also both end up with a utility of 16 &times; 14 = 224.

In another scenario, let's say you have Firm A with 20 GOLD and 10 FOOD and Firm B with the same. In this case, both Firms want to buy FOOD &mdash; they both have a mrs of 20 / 10 = 2, above 1 &mdash; and there is no mutually beneficial trade.

Then there's the case where Firm A has 30 GOLD and 5 FOOD (a utility of 150 and a mrs of 30 / 5 = 6) and Firm B has 10 GOLD and 15 FOOD (a utility of 150 and a mrs of 10 / 15 = 0.67). In this case, if Firm A bought 2 FOOD from Firm B for 2 GOLD, Firm A would have 28 GOLD and 7 FOOD (a utility of 196, an increase of 46). Firm B would have 12 GOLD and 13 FOOD (a utility of 156, an increase of just 6). In this case the price of 1 GOLD for 1 FOOD unfairly benefits Firm A more than Firm B.

Wilhite uses the following formula to calculate the acceptable price between two firms:

<math>
  <mi>price</mi>
  <mo>=</mo>
  <mfrac>
    <mrow>
      <msub><mi>GOLD</mi><mi>A</mi></msub>
      <mo>+</mo>
      <msub><mi>GOLD</mi><mi>B</mi></msub>
    </mrow>
    <mrow>
      <msub><mi>FOOD</mi><mi>A</mi></msub>
      <mo>+</mo>
      <msub><mi>FOOD</mi><mi>B</mi></msub>
    </mrow>
  </mfrac>
</math>

In the final scenario described above, the price would be:

<math>
  <mi>price</mi>
  <mo>=</mo>
  <mfrac>
    <mrow>
      <mn>30</mn>
      <mo>+</mo>
      <mn>10</mn>
    </mrow>
    <mrow>
      <mn>5</mn>
      <mo>+</mo>
      <mn>15</mn>
    </mrow>
  </mfrac>
  <mo>=</mo>
  <mfrac>
    <mn>40</mn>
    <mn>20</mn>
  </mfrac>
  <mo>=</mo>
  <mn>2</mn>
</math>

This means Firm A should pay 2 GOLD for each FOOD from Firm B. Let's see how that price works out:

| <math><msub><mi>GOLD</mi><mi>A</mi></msub></math> | <math><msub><mi>FOOD</mi><mi>A</mi></msub></math> | <math><msub><mi>U</mi><mi>A</mi></msub></math> | <math><msub><mi>mrs</mi><mi>A</mi></msub></math> | <math><msub><mi>GOLD</mi><mi>B</mi></msub></math> | <math><msub><mi>FOOD</mi><mi>B</mi></msub></math> | <math><msub><mi>U</mi><mi>B</mi></msub></math> | <math><msub><mi>mrs</mi><mi>B</mi></msub></math> |
| - | - | - | - | - | - |
| 30 | 5 | 150 | 6.00 | 10 | 15 | 150 | 0.67 |
| 28 | 6 | 168 | 4.67 | 12 | 14 | 168 | 0.86 |
| 26 | 7 | 182 | 3.71 | 14 | 13 | 182 | 1.08 |
| 24 | 8 | 192 | 3.00 | 16 | 12 | 192 | 1.33 |
| 22 | 9 | 198 | 2.44 | 18 | 11 | 198 | 1.64 |
| 20 | 10 | 200 | 2.00 | 20 | 10 | 200 | 2.00 |
| 18 | 11 | 198 | 1.64 | 22 | 9 | 198 | 2.44 |

Each step of the trade is equitable, and both achieve a maximum utility when Firm A has bought 5 FOOD for 10 GOLD, at which point they both have the same amount of GOLD and FOOD.

## Turning this into code

First a few utility functions. We already have one to work out the marginal rate of substitution. This one works out the price that the firm should use to deal with another firm:

```
def priceForTrade(firm) {
	(currentGold + firm.currentGold) / (currentFood + firm.currentFood)
}
```

Now some functions that work out how much FOOD or GOLD to trade:

```
def tryBuyingFood(firm) {
	def price = priceForTrade(firm)
	def foodToBuy = Math.floor((firm.currentFood - currentFood) / 2)
	def result = [
		firm: firm,
		price: price,
		food: currentFood + foodToBuy,
		gold: currentGold - foodToBuy * price,
		utility: 0
	]
	result.put('utility', utility(result['food'], result['gold']))
	return result
}

def trySellingFood(firm) {
	def price = priceForTrade(firm)
	def foodToSell = Math.floor((currentFood - firm.currentFood) / 2)
	def result = [
		firm: firm,
		price: price,
		food: currentFood - foodToSell,
		gold: currentGold + foodToSell * price,
		utility: 0
	]
	result.put('utility', utility(result['food'], result['gold']))
	return result
}
```


For this version of the project, each Firm is going to try to trade with every other firm. The code to work out the best possible trade looks like this:

```
// work out the mrs for the firm
def mrs = mrs()

// set up a variable to record the best trade found
def trade = [
	firm: null,
	price: 0,
	food: currentFood,
	gold: currentGold,
	utility: currentUtility()
]

// cycle through each of the firms to see whether a trade is worthwhile
def thisFirm = self()
firms().each {
	def result = null
	if (mrs >= 1 && it.mrs() < 1) {
		// more GOLD than FOOD, so buy FOOD
		result = thisFirm.tryBuyingFood(it)
	} else if (mrs < 1 && it.mrs() >= 1) {
		// more FOOD than GOLD, so sell FOOD
		result = thisFirm.trySellingFood(it)
	} else {
		result = trade
	}
	// set the best trade to the result if it's a better trade than the best found so far
	if (result['firm'] == null) {
		trade = result
	} else if (result['utility'] > trade['utility']) {
		trade = result
	}
}
```

The final piece of the puzzle is to work out what to do given knowledge about the best possible trade, the potential utility achieved by making FOOD and the potential utility achieved by making GOLD. The decision uses this code:

```
if (utilityMakingFood > utilityMakingGold) {
	if (trade['utility'] > utilityMakingFood) {
		makeTrade(trade)
	} else {
		currentFood += foodPerStep
	}
} else if (trade['utility'] > utilityMakingGold) {
	makeTrade(trade)
} else {
	currentGold += goldPerStep
}
```

Where `makeTrade()` is defined as:

```
def makeTrade(trade) {
	trade['firm'].currentFood += currentFood - trade['food']
	trade['firm'].currentGold += currentGold - trade['gold']
	currentFood = trade['food']
	currentGold = trade['gold']
}
```

## Adding monitoring

This code is all that's needed to get the agents operating in a market. But to get useful data out of the model, we have to capture what's going on for each agent. To do that, I've set up an `actions` property that holds an array of actions that the agent takes. These can be of three types: making FOOD, making GOLD and initating trade (I don't capture the recipient of trade). I've also created an `activity` property that is very similar but includes times when the agent is the recipient of a trade rather than the initiator. They're both defined as arrays:

```
def actions = []
def activity = []
```

with the `makeTrade()` function returning the relevant trade action and adding to the activity of the firm that's being traded with:

```
def makeTrade(trade) {
	def action = [ type: 'trade', food: trade['food'] - currentFood, gold: trade['gold'] - currentGold, price: trade['price'], utility: trade['utility'] ]
	trade['firm'].currentFood += currentFood - trade['food']
	trade['firm'].currentGold += currentGold - trade['gold']
	trade['firm'].activity << [ type: 'receive-trade', food: currentFood - trade['food'], gold: currentGold - trade['gold'], price: trade['price'], utility: trade['firm'].currentUtility() ]
	currentFood = trade['food']
	currentGold = trade['gold']
	return action
}
```

and the code that decides which action to take adding the relevant action to the `actions` list:

```
def action = []
if (utilityMakingFood > utilityMakingGold) {
	if (trade['utility'] > utilityMakingFood) {
		action = makeTrade(trade)
	} else {
		currentFood += foodPerStep
		action = [ type: 'make', good: 'food', amount: foodPerStep, utility: currentUtility() ]
	}
} else if (trade['utility'] > utilityMakingGold) {
	action = makeTrade(trade)
} else {
	currentGold += goldPerStep
	action = [ type: 'make', good: 'gold', amount: goldPerStep, utility: currentUtility() ]
}
actions << action
activity << action
```

## Looking at the results

First achievement: this looks to work! In a single sample run of 30 ticks, some of the agents (about 38%) spend all their time producing goods, while others (about 62%) trade in some way. Of those that trade, about 5% never initiate trade themselves but just respond to offers from other agents. The price negotiated with each trade starts off quite uneven, but stabilises at around 1 FOOD for 1 GOLD:

![graph showing price stabilisation as max and min prices converge on a mean over around 8 ticks](/assets/2016-03-11/price-stabilisation.png)

Because of the way the model is set up, with no consumption of either FOOD or GOLD once it's created, all the Firms increase in utility over the run. We can plot the final utility of each firm against its initial utility like so:

![graph showing correlation between initial utility of a Firm and its final utility](/assets/2016-03-11/utility.png)

The expected utility of a firm, if it doesn't participate in any trading, can be calculated as `foodPerStep * 11 * goldPerStep * 11`. This accounts for the strong diagonal line in the above graph: one dot for each Firm that is a pure producer. The dots above that line are the Firms that participate in trade, who manage to achieve a greater utility through trading than they would if they had just produced all the time. There are no dots below the line because (unlike in real life) the Firms are very sensible about only choosing actions that are going to increase their utility.

An example trading history of just the first activities for a Firm that does well out of trading looks like this:

| activity | FOOD | GOLD | utility |
| - | - | - | - |
| | 24 | 2 | 48 |
| accept offer to sell 11 FOOD for 6.6 GOLD | 13 | 8.6 | 111.8 |
| produce 24 FOOD | 37 | 8.6 | 318.2 |
| sell 12 FOOD for 18.13 GOLD | 25 | 26.73 | 668.19 |
| produce 24 FOOD | 49 | 26.73 | 1309.65 |
| produce 24 FOOD | 73 | 26.73 | 1951.11 |
| sell 19 FOOD for 23.93 GOLD | 54 | 50.66 | 2735.73 |
| produce 24 FOOD | 78 | 50.66 | 3951.61 |
| produce 24 FOOD | 102 | 50.66 | 5167.49 |
| produce 24 FOOD | 126 | 50.66 | 6383.36 |
| accept offer to sell 40 FOOD for 37.66 GOLD | 86 | 88.32 | 7595.29 |

This Firm only ever produces FOOD. It trades eight times during the 30 ticks of the simulation, initating the trade itself half of the time and ends up having about 9 times as much utility by the end as you'd expect given its starting condition.

It's easy to predict which Firms will do well within the simulation: the higher the ratio between the amount of FOOD a Firm can produce and the amount of GOLD they can produce, the better they do. For example, a Firm that can produce only 1 FOOD per tick, but 25 GOLD per tick will do a lot better than a Firm that can produce 5 FOOD and 5 GOLD per tick, despite starting with the same utility. Specialisation wins!

## Next steps

There are a few parts of the model that I am not sure about. There are parts of the code that, all things being equal, favour production over trading and favour GOLD production over FOOD production. I've also started each Firm off with amounts of FOOD and GOLD that depend on how much they can create, rather than starting everyone off with 1 FOOD and 1 GOLD, or randomising how much they get at the start. I want to do a bit of [sensitivity analysis](https://en.wikipedia.org/wiki/Sensitivity_analysis) to make sure the model is robust before I expand it to include DATA.

I also want to work out how to run the simulation multiple times so that I can aggregate the results and smooth out some of the jagged lines in the graph.

## Trying it out

As before, if you want to try out where I've got to so far, I've committed the source code to [Github](https://github.com/theodi/abm-information-economy) and there are instructions there about how to run it. Any comments/PRs will be gratefully received.



