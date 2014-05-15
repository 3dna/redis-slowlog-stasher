$:.unshift File.expand_path("../lib", __FILE__)

require 'redis_slowlog_stasher/version'
Gem::Specification.new do |s|
  s.name = 'redis-slowlog-stasher'
  s.version = RedisSlowlogStasher::VERSION
  s.date = '2014-05-14'
  s.summary = 'put redis slowlog entries into logstash'
  s.description = 'watches the redis slowlog command and sends structured slowlog entries to logstash for processing and storage'
  s.authors = ['Jeremy Kitchen']
  s.email = 'jeremy@nationbuilder.com'
  s.files = [
    'lib/redis_slowlog_stasher.rb',
    'lib/redis_slowlog_stasher/statefile.rb',
    'lib/redis_slowlog_stasher/argparser.rb',
    'lib/redis_slowlog_stasher/version.rb',
    'bin/redis-slowlog-stasher',
    'README.md',
    'LICENSE',
  ]
  s.executables << 'redis-slowlog-stasher'
  s.homepage = 'https://github.com/3dna/redis-slowlog-stasher'
  s.license = 'BSD-3-Clause'

  s.add_runtime_dependency('redis','>= 3.0.0')
  s.add_runtime_dependency('bunny','>= 1.0.0')
end
