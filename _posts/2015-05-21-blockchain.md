---
layout: drupal-post
title: How might we use blockchains outside cryptocurrencies?
tags:
- blockchain
- register
---
# How might we use blockchains outside cryptocurrencies?

There's been a bit of a buzz recently about using blockchains, one of the approaches used within the Bitcoin protocol, to support things other than the bitcoin currency.

Honduras is reportedly [piloting a land register using blockchain technologies](https://uk.news.yahoo.com/honduras-build-land-title-registry-using-bitcoin-technology-162701917.html#RM3nR6s). On a smaller scale, the Isle of Man is piloting a [registry of digital currency companies](http://www.coindesk.com/isle-of-man-trials-first-government-run-blockchain-project/), again using blockchain. There are [articles](http://startupmanagement.org/2014/12/27/the-blockchain-is-the-new-database-get-ready-to-rewrite-everything/) and [videos](https://www.youtube.com/watch?v=UzIQ3dPf_XA) that claim that blockchain can be used in the internet of things, for health records, and to track votes.

I want to dig a bit deeper and try to work out the **practical application of blockchain for sharing registries**, with a particular eye on open data. But before I can start looking at how those kinds of applications might work, I needed to understand [how the Bitcoin blockchain works](https://www.khanacademy.org/economics-finance-domain/core-finance/money-and-banking/bitcoin), at a technical level.

*Note that this is written based only on a couple of days of research. I might well have missed things and certainly haven't gotten into the arguments and subtleties within the blockchain community about how it should develop and grow.*

## What is a blockchain?

A [blockchain](http://en.wikipedia.org/wiki/Bitcoin#Block_chain) is a **chain of blocks**, obviously. Here's a picture of what a Bitcoin blockchain looks like:

<a title="By Matthäus Wander (Own work) [CC BY-SA 3.0 (http://creativecommons.org/licenses/by-sa/3.0)], via Wikimedia Commons" href="http://commons.wikimedia.org/wiki/File%3ABitcoin_Block_Data.png"><img alt="Bitcoin Block Data" src="http://upload.wikimedia.org/wikipedia/commons/thumb/7/7a/Bitcoin_Block_Data.png/512px-Bitcoin_Block_Data.png"/></a>

Each [block](https://en.bitcoin.it/wiki/Block) in the chain contains a reference to the previous block in the chain (that's the `Prev_Hash` in the picture) and some additional information which makes up the content of the block. The link to the previous block is what makes it a chain: **given a block you can find all the information in all the previous blocks that led to this one**, right back to what's called the **genesis block**, the very first one in the chain.

## Where is the blockchain stored?

The Bitcoin blockchain is managed by a network of **distributed nodes**. Every node has a **copy of the entire blockchain** (though from what I can gather some of the blockchain may be archived). New nodes can come and go, synchronising their copies of the blockchain against those of other nodes as they join the network.

<p><a href="http://en.wikipedia.org/wiki/File:Centralised-decentralised-distributed.png#/media/File:Centralised-decentralised-distributed.png"><img src="http://upload.wikimedia.org/wikipedia/en/b/ba/Centralised-decentralised-distributed.png" alt="Centralised-decentralised-distributed.png"></a><br>"<a href="http://en.wikipedia.org/wiki/File:Centralised-decentralised-distributed.png#/media/File:Centralised-decentralised-distributed.png">Centralised-decentralised-distributed</a>" by <a href="//en.wikipedia.org/w/index.php?title=User:1983&amp;action=edit&amp;redlink=1" class="new" title="User:1983 (page does not exist)">1983</a> (<a href="//en.wikipedia.org/w/index.php?title=User_talk:1983&amp;action=edit&amp;redlink=1" class="new" title="User talk:1983 (page does not exist)">talk</a>) (<a href="//en.wikipedia.org/wiki/Special:ListFiles/1983" title="Special:ListFiles/1983">Uploads</a>) - Own work. Licensed under <a href="http://creativecommons.org/licenses/by-sa/3.0/" title="Attribution-ShareAlike 3.0">CC BY-SA 3.0</a> via <a href="//en.wikipedia.org/wiki/">Wikipedia</a>.</p>

The fact that there are multiple copies of the blockchain on a distributed network of nodes is one of the powerful features of the blockchain. It **makes the blockchain robust against nodes disappearing** either temporarily or permanently, whether that's due to connectivity issues, hardware failures, or interference. The more nodes there are in the network, the harder it is to disrupt the storage of the blockchain. There is no single point of failure, unlike in a centralised system with a single authority.

## What does a block contain?

In Bitcoin, a block has a header and a list of bitcoin transactions (they are the `Tx0`, `Tx1` ... `Tx3` in the picture of the blockchain). The header includes:

  * a pointer to the previous block (`Prev_Hash` in the picture)
  * a summary of the bitcoin transactions the block contains (technically, the [Merkle hash](https://en.wikipedia.org/wiki/Merkle_tree) of those transactions, the `Tx_Root` in the picture)
  * a timestamp that indicates when the block was created
  * a proof of the work that went into creating the block (that's the `Nonce` in the picture)

The [original paper on bitcoin](https://bitcoin.org/bitcoin.pdf) doesn't actually use the term "blockchain". It talks about a **timestamp server** because that's really what the blockchain is for: it **provides irrefutable evidence that the data in a block existed at a particular time**. 

The actual [timestamp](https://en.bitcoin.it/wiki/Block_timestamp) given in a particular block isn't necessarily to-the-second accurate. In fact there's nothing stopping the timestamp of a particular block being before the timestamp of the previous block. If a block is in the blockchain, what is guaranteed is:

 1. the block was added at most two hours before its timestamp
 2. the block before this block in the chain existed at the time the block was created
 3. this block was added to the chain before the next block in the chain existed
 4. the data in this block (ie the bitcoin transactions) existed at the time the block was created

The **hash of the header of the block**, incorporating each of these pieces of information, becomes the identifier for the block which is used by the next block in the chain.

## How do new blocks get added to the chain?

Every node in the network can add blocks to the chain. Every node is sent the data that needs to go into the blocks (eg the bitcoin transactions). Every node can package up that data into a block that links back to the last block in the chain that they are aware of. And every node can then transmit that block to the rest of the network to assert "this is the new chain".

So what stops this being a completely chaotic situation where every node is adding blocks at the same point in the chain at the same time, forking it willy-nilly? What ensures that the nodes in the network have a consistent, consensus view of what the blockchain holds?

The first barrier is that nodes all operate under a set of [protocol rules](https://en.bitcoin.it/wiki/Protocol_rules) that determine what a valid block looks like. These rules include ensuring that each transaction is a valid transaction: that it is spending money that actually exists (technically, pointing to a previous matching transaction within the blockchain) and that it has been signed by the creator of the transaction. They also ensure integrity between transactions: that the same money isn't being spent twice (technically, each output of a transaction can only form the input of one other transaction).

The other test for a valid block is where its **nonce** comes in. To be a valid block, **the hash of the header of the block always has to start with a certain number of zeros**. (Or, put another way, it has to be below a certain [target number](https://en.bitcoin.it/wiki/Target).) If you remember, the header contains:

  * the hash of the previous block in the chain
  * the Merkle hash of the transactions in the block
  * a timestamp
  * a nonce

So imagine you're a node and you have a whole bunch of transactions that you want to put together into a block to add to the chain. You know the hash of the previous block in the chain. You can calculate the Merkle hash for the transactions you want to put in the block. You know what the time is. But what you don't know, and what you have to work out, is **what nonce will result in the header of your new block having a hash that starts with lots of zeros**.

Now, the way that [hashing](https://en.wikipedia.org/wiki/SHA-2) works means that there is no way a node can algorithmically compute what nonce is going to give the block this magic property. Finding the nonce is like finding a Golden Ticket in [Charlie & the Chocolate Factory](https://en.wikipedia.org/wiki/Charlie_and_the_Chocolate_Factory). You might get lucky and find that the first nonce that you try gives you a valid hash. But realistically, **you're going to have to try lots and lots and lots of different nonces**, like having to buy lots and lots and lots of chocolate bars in the hope of getting a Golden Ticket.

What do I mean by "lots and lots and lots"? Well, the [current probability](http://blockexplorer.com/q/probability) of managing to get a nonce that works per attempt is about 1 in a sextillion (10^21, [about the number of grains of sand on all the beaches in the world](https://en.wikipedia.org/wiki/Orders_of_magnitude_%28numbers%29#1021)). Specialised hardware performs at 1000 GH (giga-hashes), which means it tries about one trillion (10^12) nonces each second.

So nodes have to work really hard to create valid blocks. They have to try lots and lots and lots of different nonces, calculating lots and lots and lots of hashes. A valid block, whose hash begins with lots of zeros, is proof that the node that created it did lots of work, hence the nonce is sometimes called a [proof of work](https://en.wikipedia.org/wiki/Proof-of-work_system).

## How fast does the blockchain grow?

The number of zeros that a block's hash has to start with, or the target number that it has to be below, determines the difficulty of creating a new block, and hence the average time that it will take. The smaller the target number, the more zeros the hash has to start with, the lower the probability of hitting on such a hash, and the harder it is to create a new block.

**The difficulty of creating a new block is automatically regulated** such that no matter how big the network of nodes gets, and no matter how much compute power they have, **it will always take [about 10 minutes](https://blockchain.info/charts/avg-confirmation-time?timespan=2year&showDataPoints=false&daysAverageString=1&show_header=true&scale=0&address=) for the whole network to find a new block**. 

Every 2016 blocks, which is about every 2 weeks, a new target number is calculated based on how long it took to create those 2016 blocks. If it averaged more than 10 minutes to create them, the target number goes up and the difficulty goes down; if it took less than 10 minutes to create them, the target number goes down and the difficulty goes up. So the difficulty adapts and [varies over time](https://blockchain.info/charts/difficulty?timespan=2year&showDataPoints=false&daysAverageString=1&show_header=true&scale=0&address=) based on the total compute power of the network.

This adaptation does give some limits to the growth of the blockchain and to the number of transactions the network can handle. A new block is added roughly every 10 minutes. Each block currently has a maximum size of 1MB, put in place to limit the amount of data that nodes have to pass around to stay synchronised. The size of transactions varies, but the commonly quoted [maximum transaction rate](https://en.bitcoin.it/wiki/Maximum_transaction_rate) is 7 transactions per second, equivalent to 4200 transactions per block. Bitcoin [hasn't reached these limits yet](https://blockchain.info/charts/n-transactions-per-block?timespan=2year&showDataPoints=false&daysAverageString=1&show_header=true&scale=0&address=).

It also means that **as the network grows, the total energy consumed grows**, but the output stays the same. [Researchers have estimated](http://karlodwyer.github.io/publications/pdf/bitcoin_KJOD_2014.pdf) that the total power consumed by the Bitcoin network is something in the region of 3GW &mdash; about the same power consumption as Ireland.

## Why do nodes make new blocks?

We've looked at the large numbers of calculations that nodes have to do in order to create new blocks. At the time of writing there are estimated to be [about 100,000 nodes (called miners) in the Bitcoin network](http://organofcorti.blogspot.co.uk/). All of them are trying to add new blocks to the chain; about every 10 minutes one of them will succeed.

Doing all this work requires computing power, and computers cost money to buy and to run. So what motivates the nodes to perform all these calculations?

The answer for the Bitcoin network is **nodes participate because of the financial reward of creating a new block**. This comes in two flavours:

  1. the node that creates a block gets a fixed reward, currently 25 bitcoins; this fixed reward halves every 210,000 blocks (roughly every 4 years)
  2. the node that creates a block picks up any transaction fees that the creator of the transaction assigns

Even with these rewards, the cost of specialised hardware and of electricity means that [it can take more than a year to break even](http://www.vnbitcoin.org/bitcoincalculator.php). It's therefore common to have node pools which share the work, and the reward, to even up the odds somewhat.

## What if two new blocks are made at the same time?

The work that nodes have to do to create a new block takes time. This lowers the probability that two blocks are made at the same time, but it's still possible. When this happens, it creates a fork in the blockchain; some nodes might start building on one of those branches and some on the other.

But the [protocol rules](https://en.bitcoin.it/wiki/Protocol_rules) that govern how the nodes operate prevent this situation from going on for very long. Each node keeps track of all the branches, but **nodes will only try to extend the longest branch they know about**. (The length isn't determined by the number of blocks but by the total amount of work that has gone into building the branch, based on the number of zeros at the beginning of the block hash.)

The transactions in shorter branches aren't lost. When a node learns that another branch is longer than the one it has been working on, it checks its current branch for any transactions that aren't in the new branch. These missed transactions are broadcast to the network again, and incorporated into new blocks on the chain.

So the blocks at the end of the blockchain could be retracted at any time. The network of nodes will eventually come to a consensus position on which block follows a given block, but at any one time there might be many branches in operation, potentially including different transactions.

And some of the transactions that are in the blockchain currently accepted by a node may eventually turn out to be invalid. If two branches contain transactions that cannot coexist (eg because they involve spending bitcoins twice over), one of the transactions will eventually be refused.

This uncertainty about the end of the chain leads to the common rule that **a given bitcoin transaction isn't [confirmed](https://en.bitcoin.it/wiki/Confirmation) until it is at least 6 blocks deep in the chain** (ie after about an hour, given each block takes about 10 minutes to create). This number is based on understanding what it would take to change the contents of the blockchain, which leads on to the next question.

## How can you change the contents of the blockchain?

As we've seen, each block contains a reference to the previous block, and that reference &mdash; the hash of the block &mdash; encodes both the content of the block and the reference to the previous block. In other words, **if you changed the content of a block, you would change its hash**. If you changed its hash, you would need to change the reference to it in the block after it in the chain. That in turn would change that block's hash, which would mean changing the reference in the block after that, and so on to the end of the chain.

So changing the content of a block is hard to do when the block is followed by other blocks. Once a block is embedded within the chain, you have to unpick all the following blocks right back to the one you want to change, and then reconstruct those blocks again. As we've seen, creating a block is hard work: it takes lots of computational power. But more than that, while you are busy trying to recreate the chain you've unpicked, the rest of the network is merrily continuing to add even more blocks to that chain: you're left playing catch-up.

**The ease with which someone can alter the blockchain depends on the proportion of the network that they own.** It's possible to [calculate the probability](https://bitcoil.co.il/Doublespend.pdf) of someone being able to alter the blockchain depending on the proportion of the compute power that they control and the number of blocks back in the chain they are trying to amend.

For example, someone who controlled 20% of the compute power of the network has a 40% chance of being able to change the last block in the chain, but only a 4% chance of being able to change a block that is 5 blocks back in the chain. Someone who controls 10% of the compute power of the network has a less than 0.1% chance of being able to change a block 6 blocks back in the chain.

This last calculation is the basis for deciding when a transaction is confirmed: even if someone managed to capture 10% of the compute power of the network, they'd still have less than a 0.1% chance of altering a block that is 6 blocks deep in the chain. It's judged unlikely that anyone would capture that much of the network, and they're still unlikely to succeed even if they did, so 6 blocks feels like a safe bar for transactions in the Bitcoin network to need to meet.

## How are people using blockchains for things other than bitcoin?

I haven't yet dug into [everything everyone is doing with blockchains](http://startupmanagement.org/2014/12/16/the-ultimate-list-of-bitcoin-and-blockchain-white-papers/) but from my initial look there seem to be three main patterns for extending the use of Bitcoin blockchain to satisfy other requirements:

  * embedding data into Bitcoin blockchains
  * creating other kinds of cryptocurrency blockchains with different features
  * creating blockchains that aren't based on cryptocurrencies at all

### Embedding data into Bitcoin blockchains

Transactions within a cryptocurrency blockchain are simply blocks of data. It is possible to embed additional data within those transactions. [Factom](http://factom.org/), the organisation implementing the pilot land registry for Honduras, inserts references to data managed on a completely separate network into the Bitcoin blockchain, using it as a timestamp server.

### Creating other kinds of cryptocurrency blockchains with different features

There are various constraining features of the Bitcoin blockchain which limit its utility, such as the limits on the speed with which the blockchain can grow or the size and content of the blocks. [Florincoin](http://florincoin.org/) adds comments which developers can use to embed other data or references to other data. [Alexandria](http://blocktech.com/) is an application built on top of Florincoin that takes advantage of these comments to create a decentralised peer-to-peer library. The content itself (such as videos or music) isn't embedded into the blockchain &mdash; it's distributed via Bittorrent &mdash; but the metadata about that content is embedded in that way. 

### Creating non-cryptocurrency blockchains

Other developers are using blockchain principles to create blockchains that aren't based on cryptocurrency exchange. I *think* this is what [Guardtime](https://guardtime.com) are doing, using what they call a [Keyless Signature Infrastructure (KSI)](https://guardtime.com/technology), but I don't yet have access to their Knowledge Base to be able to tell.

## Questions, questions

Having understood more about how blockchains, and specifically the Bitcoin blockchain, works, I still have lots of questions about how it might be used for (open data) global registeries.

The unconstrained peer-to-peer nature of blockchain networks is important, but:

  * Are there other forms of network that might eg limit size of the network by limiting membership to trusted entities (no entity can be completely trusted)?
  * If not, then how do you incentivise nodes to join the network without it being associated with a cryptocurrency?
  * Or is the cryptocurrency side of blockchains essential to make them work?

The rules about the way in which currency transactions work (eg that the amount of money coming in to a transaction has to be equal to the amount of money coming out of the transaction) are built in to how Bitcoin nodes operate. It isn't possible for an invalid transactions to be written into the Bitcoin blockchain (except by an error-prone node, whose outputs will be swamped by the rest of the network). When you move into other domains, however, validity rules might start to be untestable by machines, reliant on processes where human error can creep in.

  * How can you design blockchains in circumstances where mistakes can be made?
  * Or is this a natural limit for what blockchains are and aren't suited for?

The Bitcoin blockchain records transactions rather than the state of each bitcoin. Getting a summary of who owns what is technically possible &mdash; all that data is public &mdash; but requires an additional layer of processing on top of the blockchain.

  * Do we similarly have to model things other than plain records in blockchains when we're using them for other kinds of data?
  * How does this affect the ease of getting hold of the data itself, or creating aggregated summary statistics based on that data?

Because of the need for each node to copy the entire blockchain, it isn't appropriate to embed large amounts of data within a blockchain. Hashing summaries into the blockchain guarantees integrity, but it doesn't guarantee access.

  * How can blockchain be effectively used alongside distributed data storage mechanisms (such as Bittorrent)?

Blockchains are public ledgers. Although they can contain encrypted data, the validity of the blockchain relies on nodes being able to double check that the important aspects of the data match the hash summaries that they've been given.

  * How can blockchains be used for private data?

The way that the Bitcoin network is set up means that the total output of the network (in terms of adding blocks to the chain) remains constant regardless of the size of the network. This doesn't seem scalable, either in terms of energy consumption or in terms of handling growing amounts of activity.

  * Which are the pieces of the Bitcoin protocol that can be tweaked to create something that is more scalable and energy efficient?

Any thoughts on, or pointers to documents discussing, any of these questions would be gladly received. Email me on [jeni@jentennison.com](mailto:jeni@jenitennison.com) or tweet me [@JeniT](https://twitter.com/JeniT).