---
layout: drupal-post
excerpt_separator: "<!--break-->"
title: Minimising hard-disk power consumption
created: 1187553609
tags:
- environment
- hardware
---
Me: You know that new laptop I was talking about? The [Dell XPS M1330][10]? The one where you can get it with a 32Gb solid-state drive?

Him (wary): Yeeesss...

Me: Well listen to [this][11]: "a 64 GB solid-state drive can read 64 MB/S, write 45 MB/s, and consumes just half a Watt when operating (one tenth of a Watt when idle). In comparison, an 80 GB 1.8-inch hard drive reads at 15 MB/s, writes at 7 MB/s, and eats 1.5 Watts either operating or when idle."

Him: So what you're saying is, if you get this laptop you'll be saving the planet.

Me: Precisely!

[10]: http://www.dell.com/content/products/productdetails.aspx/xpsnb_m1330 "Dell XPS M1330"
[11]: http://news.digitaltrends.com/news/story/12556/samsung_announces_64_gb_solid_state_drive "Digital Trends: Samsung Announces 64Gb Solid State Drive"

<!--break-->

***

Until such time as I can afford said Dell, I'm trying other ways of limiting the power consumption of our computer equipment. I [mentioned][1] that my dad's set me up nicely with a [NSLU2][2]. One of its USB ports has a 2Gb USB key stuck in it: that holds the core operating system. The other's got a 500Gb hard drive attached to it; that holds the data.

[1]: http://www.jenitennison.com/blog/node/46 "here, a week ago, in 'And she's back'"
[2]: http://en.wikipedia.org/wiki/NSLU2 "Wikipedia: NSLU2"

The NSLU2 acts as my file server and mail server. It runs all the time, so one of its attractions is its low power consumption. But having a hard drive spun-up all the time isn't very efficient, particularly during the night when there's no need for constant disk access and the noise might disturb people sleeping in the spare room where the server's located. On the other hand, you don't want to do a huge amount of spinning up and spinning down because it strains the hardware.

The disk Barry (my dad) bought powers down after about 15 minutes of non-activity. Which is great, until you realise that what you think of as non-activity ("I'm not even logged in!") isn't what counts. Background processes writing to logs is enough to keep the disk spun up.

So the first challenge was to identify those processes that were writing to disk and keeping it spun up. Barry wrote the following script to do it:

    #!/bin/sh
    
    # script by barry, intended for cron.hourly,
    # to log (under /root/disk-access-logs)
    #  (without accessing the hd unnecessarily)
    # the atime and mtime of
    # files on /var (one partition of the mounted usb-hd)
    # which have been accessed in the last hour
    
    # AND (later, maybe temporarily also) the value in 
    #  /var/lib/ntp/ntp.drift to a different logfile
    
    # LOG_FILE=log-`date +%y%m%d-%H%M`

    LOG_FILE=/root/disk-access-logs/log-`date +%y%m%d`
    [ -f $LOG_FILE ] || touch $LOG_FILE

    echo "Result of:  find /var -mmin -59 -printf "%a %t %p\n" |sort -t ":" -k4nr -k5nr' at:" >>$LOG_FILE
    echo `date +%y%m%d-%H%M` >>$LOG_FILE
    find /var -mmin -59 -printf "%a %t %p\n" |sort -t ":" -k4nr -k5nr >>$LOG_FILE
    echo "------" >>$LOG_FILE

This reveals things like [fetchmail][3] (pretty obviously) writing every five minutes when it wakes up to check for new mail on my POP3 server. It reveals [exim][4] writing to its log every half hour. It reveals [ntp][5] collecting statistics (and, still unresolved, writing to `daemon.log` in the early hours of the morning). It also revealed that [Samba][6], which we'd previously been using to give me Windows-based access to the hard drives, was doing a lot of logging, and this was part of the reason we stopped using it. And that [syslog][9] was also logging frequently.

[3]: http://en.wikipedia.org/wiki/Fetchmail "Wikpedia: fetchmail"
[4]: http://en.wikipedia.org/wiki/Exim "Wikipedia: exim"
[5]: http://en.wikipedia.org/wiki/Network_Time_Protocol "Wikipedia: Network Time Protocol"
[6]: http://us3.samba.org/samba/ "Samba website"
[9]: http://en.wikipedia.org/wiki/Syslog "Wikipedia: syslog"

The ntp logging was minimised by editing `/etc/ntp.conf` and the syslog logging by setting a long "mark" interval in `/etc/default/syslogd`. Having a [cron][7] job that stops all the processes that don't need to be constantly running overnight is working reasonably well at the moment. My crontab currently looks like this:

    # Fixed the PATH to provide access to start-stop-daemon, 
    # env and rm that /etc/init.d/exim4 requires
    
    PATH=/usr/bin:/bin:/sbin:$PATH
    
    # m h  dom mon dow   command
    00 23 * * * /etc/init.d/fetchmail stop > /dev/null &
    00 23 * * * /etc/init.d/exim4 stop > /dev/null &
    00 07 * * * /etc/init.d/exim4 start > /dev/null &
    00 07 * * * /etc/init.d/fetchmail start > /dev/null &

but I'm probably going to tweak it to take care of the ntp thing and to remain spun down on days when I'm not constantly at the computer.

[7]: http://en.wikipedia.org/wiki/Cron "Wikipedia: cron"
[8]: http://en.wikipedia.org/wiki/Crontab "Wikipedia: crontab"

Any other ideas?
