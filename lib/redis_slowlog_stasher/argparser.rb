require 'ostruct'
require 'optparse'
module RedisSlowlogStasher
  class Argparser
    def self.parse(args)
      options = OpenStruct.new

      options.check_interval = 10
      options.check_entries = 25
      options.exchange = 'logstash'
      options.routing_key = 'logstash'

      options.logger = Logger.new(STDOUT)

      opts = OptionParser.new do |opts|
        opts.banner = 'Usage: redis-slowlog-stasher [options] redis-server rabbitmq-amqp-uri'

        opts.separator ""
        opts.separator "options:"

        opts.on("--exchange EXCHANGE", String, "the name of the exchange to use") do |exchange|
          options.exchange = exchange
        end

        opts.on("--routing-key KEY", String, "the routing key to use") do |routing_key|
          options.routing_key = routing_key
        end

        opts.on("--state-file FILE", String, "the path to the state file which tells this program which",
                "slowlog entry was the last one processed so we can attempt",
                "to not lose any messages and not duplicate any, either.") do |state_file|
          options.state_file = StateFile.new(state_file)
        end

        opts.on("--type TYPE", String, "the value of the type field of the event") do | type |
          options.type = type
        end

        opts.on("--tags tag1,tag2,tag3", Array, "a list of tags to add to the event") do | tags |
          options.tags ||= []
          options.tags.concat(tags)
        end

        opts.on("--add-field field1=value1,field2=value2", Array, "a list of option fields and their values to add to the event") do |fields|
          options.fields ||= {}
          options.fields.merge!(Hash[fields.map { |field| field.split('=', 2) }])
        end

        opts.on("--check-interval SECONDS", Float, "how frequently to check the slowlog for new entries. In seconds") do |check_interval|
          options.check_interval = check_interval
        end

        opts.on("--check-entries COUNT", Integer, "how many entries to check for each interval.") do |check_entries|
          options.check_entries = check_entries
        end

        opts.on("--log-level LEVEL", ["FATAL","ERROR","WARN","INFO","DEBUG"], "sets the level of output verbosity") do |log_level|
          case log_level
          when "FATAL"
            options.logger.level = Logger::FATAL
          when "ERROR"
            options.logger.level = Logger::ERROR
          when "WARN"
            options.logger.level = Logger::WARN
          when "INFO"
            options.logger.level = Logger::INFO
          when "DEBUG"
            options.logger.level = Logger::DEBUG
          end
        end

        opts.on_tail("-h", "--help", "Show this message") do
          puts opts
          exit
        end

        opts.on_tail("--version", "Show version") do
          puts '0.0.1'
          exit
        end

      end

      opts.parse!(args)
      options
    end
  end
end
