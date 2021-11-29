---
layout: drupal-post
excerpt_separator: "<!--break-->"
title: Claiming your online identity
created: 1184156640
tags:
- web
---
I ("Jeni Tennison") manage to score 10/10 on the [online identity calculator][1], thanks to having a pretty rare name and there being multiple archives of [XSL-List][2], to which I was a prolific contributor in my early XML days. (I think I can also claim to be "Jenni Tennison", "Jenny Tennison" less so, "Jenifer Tennison" is obviously the pre-XML me, and "Jennifer Tennison" not me at all, and quite rightly so.)

Anyway, I've just registered with [claimID][3] to get myself an [OpenID][4], to lower the barrier to accessing certain sites. As well as getting a claimID URL (eg `http://claimid.com/jenitennison`) to use as an OpenID, you can also use the URL of your own web page as your OpenID identity URL which delegates to the claimID identity URL, by adding links to the claimID server in the head of the web page. (View the source of [my home page][6] to see what this looks like.) This provides some flexibility in the event that claimID stops functioning: I can move to another OpenID provider without changing my OpenID.

[1]: http://www.careerdistinction.com/onlineid/step1.html "Career Distinction: Online Identity Calculator"
[2]: http://www.mulberrytech.com/xsl/xsl-list "XSL-List: Mailing list for XSL"
[3]: http://claimid.com/ "claimID.com"
[4]: http://openid.net/ "OpenID"
[5]: http://www.microid.org/ "microID"
[6]: http://www.jenitennison.com/ "Jeni's XML Pages"

<!--break-->

ClaimID uses [microID][5] to verify that the pages that you say you own are really pages that you own. A microID is a hash of your email address and the URI of the page, placed in a `<meta>` element in the head of the HTML page (or in the `class` attribute of a section of a page). It bothered me for a bit that other people could easily create this hash and put it on their own pages, claiming that I'd created them. Then I realised that microID's for confirming your claim that you own a page, not for discovering who owns a page (the hashing algorithm is non-reversible), and the only person who can claim a given page (at least on any reputable site) using the email `jeni@jenitennison.com` is me.

So now I have to work out how to get Drupal to add the hash into the head of my blog pages, and to enable OpenID and microID for people who post comments.
