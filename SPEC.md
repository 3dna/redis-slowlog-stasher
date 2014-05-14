This is a simple spec doc so I can record the features I want to have and options I want to support.

# Simplest usage

    ./redis-slowlog-stasher redis://localhost:6379/ amqp://foo:bar@rabbitmq1.example.com:5672/logstash logstash

Real simple. the redis server to watch the slowlog of, and the rabbitmq server to drop the messages on.

# options

* `--state-file`

  defaults to none. This file will contain the id of the last slowlog entry processed so as not to duplicate messages or 

* `--type`

  the value of the type field passed to logstash. there is no field by default

* `--tags tag1[,tag2[,tag3, ...]]`

  a comma? separated list of tags to be put into the event. the comma-separated depends on ruby's argument parsing library, how it wants them.

* `--add-field field1=value,field2=value,field3=value`

  arbitrary fields and their values to add. Useful for adding things like `source_host` if you're into that sort of thing.

* `--check-interval`

  how frequently to check the redis slowlog for new entries in seconds. Defaults to 10. Can be a decimal.

* `--check-entries`

  how many slowlog entries to get at a time. We don't necessarily want to get the whole list every time, especially if the list is large and rate of change low. defaults to 25.

  You should tune this and `--check-interval` to make sure you aren't missing any entries.
  If you have a high rate of slowlog entries, you may lose some, as I only grab `$num_entries` using slowlog get and report any new ones to logstash. If there are more new ones than that, they'll get effectively dropped.

  Also keep in mind if you are getting a high rate of slowlog entries that the maintenance of the slowlog itself is not free, so you don't want to turn your threshold down TOO low or you'll actually be impacting redis performance.
  The discussion of what's an appropriate value is outside the scope of this document as it's very site specific.

* `--exchange`
  
  The rabbitmq exchange to use. Defaults to 'logstash'

* `--routing-key`

  The routing key to use. Defaults to 'logstash'


# example usage

```
./redis-slowlog-stasher --type redis-slowlog --tags webcache --add-field hostname=`fqdn` redis://redis1.example.com:6379/ rabbitmq1.example.com
```

# implementation

This uses the [redis-rb](https://github.com/redis/redis-rb) ruby redis client gem and [bunny](http://rubybunny.info/).

# new event logic

in order to determine if the event is new or not, we use some really simple logic, and we track the old event.

`event_id > old_event_id` is always new event, right? log it.
`event_id < old_event_id && timestamp >= old_timestamp` is a server restart, `event_id` goes back to 0. new event. log it
`event_id == old_event_id && timestamp != old_timestamp` is also a server restart, and we just happened to get the same event id, new event, log it.

All other events are ignored, as we've already logged them.

The only flaw here is if the event's ID rolls back (due to restart of redis) *and* a timestamp rollback occurs (due to clock correction). Those slowlog entries will get dropped. Oops. Document, move along. The only real thing I can think of to resolve that is to check based on the uptime of the redis as well, but that's a separate command, and I think unnecessary. Don't do that.

# event format

```
{
	'@timestamp': "timestamp from redis, converted to ISO8601",
	'version': 1, # the version of the logstash format, and we'll just use 1 in this program
	'duration': 'the duration in us of the command's run time',
	'command': 'the command being run',
	'args': 'the arguments passed to the command',
}
```

So, for a slowlog entry from redis like:

```
1) (integer) 13
2) (integer) 1309448128
3) (integer) 30
4) 1) "slowlog"
   2) "get"
   3) "100"
```

the generated logstash event would look like this: (of course using a real json library so the trailing commas may go away or whatever)

```
{
  '@timestamp': '2011-06-30T15:35:28Z',
  'duration': 30,
  'command': 'slowlog',
  'args': [
    'get',
    '100',
  ],
}
```

If you choose to add a type or tags, those will just go in like so:

```
{
  '@timestamp': '2011-06-30T15:35:28Z',
  'duration': 30,
  'command': 'slowlog',
  'args': [
    'get',
    '100',
  ],
  'tags': [ 'foo','bar'],
  'type': 'redis-slowlog'
}
```
