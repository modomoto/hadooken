require "yaml"
require "optparse"
require "socket"

module Hadooken
  class Configuration

    DEFAULT_CONFIG_FILE  = "config/hadooken.yml".freeze
    VALID_CONFIG_OPTIONS = {
      group_name:    Socket.gethostname,
      daemon:        false,
      environment:   :development,
      logfile:       nil,
      error_logfile: nil,
      pidfile:       nil,
      workers:       1,
      threads:       16,
      topics:        {},
      kafka:         { client: Kafka },
      test:          {},
      producer:      { delivery_treshhold: 100, delivery_interval: 10 },
      require_env:   nil,
      heartbeat:     { topic: :consumer_heartbeat, frequency: 5 },
      meta_topic:    :consumer_data
    }.freeze

    attr_accessor :error_capturer
    attr_reader :options

    # Parses ARGV and stores the configuration
    # options in options instance variable.
    def initialize
      @options = {}
      # Populate the @options hash, if and only if
      # hadooken started directly by its own command.
      # The reason is, ARGV can be populated by puma
      # or rspec configuration options and this options
      # can be unrecognized by Hadooken and will lead
      # an exception in OptionParser.
      parser.parse! if Kernel.const_defined?(:HADOOKEN)
      @options[:config_file] ||= DEFAULT_CONFIG_FILE if File.exist?(DEFAULT_CONFIG_FILE)
      parse_config_file if @options[:config_file]
    end

    # Defines getter & setter methods for
    # all valid configuration keys
    # which fallbacks the default
    # values defined in hash.
    VALID_CONFIG_OPTIONS.each do |option, value|
      define_method(option) do
        options[option] || value
      end

      define_method("#{option}=") do |config|
        options[option] = config
      end
    end

    def validate!
      validate_daemonization!
      validate_consumers!
    end

    private
      def parser
        @parser = OptionParser.new do |o|
          o.banner = "Usage: bundle exec hadooken [options]"

          o.on "-d", "--daemon", "Daemonize process" do
            options[:daemon] = true
          end

          o.on "-e", "--environment ENV", "Application environment" do |arg|
            options[:environment] = arg
          end

          o.on "-c", "--config PATH", "path to YAML config file" do |arg|
            options[:config_file] = arg
          end

          o.on "-l", "--logfile PATH", "path to writable logfile" do |arg|
            options[:logfile] = arg
          end

          o.on "-p", "--pidfile PATH", "path to pidfile" do |arg|
            options[:pidfile] = arg
          end

          o.on "-v", "--version", "Print version and exit" do |arg|
            puts "Hadooken #{Hadooken::VERSION}"
            exit 0
          end
        end
      end

      # Configurations in config file should not
      # override the ones given as arguments.
      def parse_config_file
        if !File.exist?(options[:config_file])
          puts "Configuration file is not found"
          exit 1
        end

        configs = YAML.load_file(options[:config_file]).deep_symbolize_keys
        options.reverse_merge!(configs[environment.to_sym] || {})
      end

      def validate_daemonization!
        if options[:daemon] && !(options[:logfile] && options[:pidfile])
          puts "Can not be deamonized without logfile and pidfile options"
          puts parser.on_tail "-h"
          exit 1
        end
      end

      # Check the consumers before start
      # If user provides wrong consumer name
      # hadooken will stop at this step.
      def validate_consumers!
        return if !options[:topics]

        options[:topics].each do |topic, consumer|
          begin
            consumer.constantize
          rescue
            puts "Couldn't constantize '#{consumer}'! Please check the configuration you've provided."
            exit 1
          end
        end
      end

  end
end
