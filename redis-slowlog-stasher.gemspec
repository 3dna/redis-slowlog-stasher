Gem::Specification.new do |s|
  s.name = 'redis-slowlog-stasher'
  s.version = '0.0.1'
  s.date = '2014-05-14'
  s.summary = 'put redis slowlog entries into logstash'
  s.description = 'watches the redis slowlog command and sends structured slowlog entries to logstash for processing and storage'
  s.authors = ['Jeremy Kitchen']
  s.email = 'jeremy@nationbuilder.com'
  s.files = [
    'lib/redis_slowlog_stasher.rb',
    'lib/redis_slowlog_stasher/statefile.rb',
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
