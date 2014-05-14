redis-slowlog-stasher

# what?

[redis](http://redis.io) has this awesome feature called the [slowlog](http://redis.io/commands/slowlog), which keeps track of commands that take a long time to run.

# why?

because redis is single threaded, if you have a command that takes too long, it'll block all other commands, and on a high traffic redis server, this can be disastrous.

# how?

funny enough, this program is designed to use [rabbitmq](http://www.rabbitmq.com/)as a transport for the logs. Why rabbitmq? Because I already have a rabbitmq set up for "reliable" log transport and that's what I'm going to keep using for now.

The basic idea, though, is that it calls the `slowlog` command on the redis server periodically and any new messages in the slowlog get sent over to logstash. Pretty simple, right?

# who?

This script was written by Jeremy Kitchen while working at NationBuilder in May, 2014

# license

I consider this to be a pretty trivial thing, so I won't be making any claims of copyright. Please feel free to use, modify, steal, sell, use for bad things, whatever.

In jurisdictions where applicable, I'm placing this code into the public domain. Where it's not I'm granting a non-exclusive non-revokable royalty free license to use the code as you please.

If you like it, drop me a [gittip](https://www.gittip.com/kitchen) or buy me a beverage some time.
