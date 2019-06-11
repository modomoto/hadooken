# Hadooken

Hadooken handles all underlying stuff for you to consume messages from kafka bus.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'hadooken'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install hadooken

## Usage

From the path of your project run the following;

```
$ bundle exec hadooken
```

other available commands are:

```
$ bundle exec hadooken start
```

```
$ bundle exec hadooken stop
```

```
$ bundle exec hadooken restart
```

## Configuration

Normally hadooken assumes that there is a configuration file located at `config/hadooken.yml` but you can change this behaviour while starting it like so:

```
$ bundle exec hadooken -c config/a-config-file.yml
```

Other configuration options can be provided as argument are:

- `-d` or `--daemon` to daemonize hadooken
- `-e` or `--environment` to change environment
- `-l` or `--logfile` to change location of log file
- `-p` or `--pidfile` to change location of pid file
- `-v` or `--version` to print out current version of hadooken you have
- `-h` or `--help` to list above options

Configurable options via configuration yml file:

- **group_name<String>:** Name of the consumer group(Same group always read from same partition).
- **daemon<Boolean>:** To run as daemon.
- **environment<String|Symbol>:** Environment to run.
- **logfile<String>:** Location of the log file. Required if daemon is true.
- **pidfile<String>:** Location of the pid file. Required if daemon is true.
- **workers<Integer>:** Number of processes hadooken will use.
- **threads<Integer>:** Number of threads hadooken will spawn for each worker.
- **topics<Dictionary>:**
  - **key:** Name of the topic you want to register.
  - **value:** Name of the class which will handle incoming messages.
- **kafka<Dictionary>:**
  - **client:** The client library to be used to connect Kafka. Default is Kafka.
  - **brokers:** An array of brookers list.
- **test<Dictionary>:**
  - **schema_path:** The path of the JSON schema files.
- **require_env<String>:** Custom path to require.
- **heartbeat<Dictionary>:**
  - **topic:** The name of the topic that heartbeat messages will be published
  - **frequency:** Publish frequency in seconds

Also you can configure hadooken via ruby script! Create a file under initializerz directory of rails and fill it like so:

```ruby
  require 'hadooken'

  Hadooken.configure do |c|
    c.error_capturer = -> (error, context) { puts error.class }
    c.heartbeat      = { topic: :consumer_heartbeat, frequency: 0.1 }
    c.logfile        = 'tmp/hadooken.log'
    c.pidfile        = 'tmp/hadooken.pid'
    c.daemon         = true
  end
```

## Producing messages

Hadooken comes with the Publisher DSL that you can use for producing messages.

```ruby
class FooPublisher < Hadooken::Publisher
  self.topic = 'foo'
  self.message_name = 'foo_created'
  self.version = '1.2'
  self.serializer = FooBarSerializer
end

FooPublisher.publish(foo) # Will send the payload generated for `foo` object to Kafka
```

#### Publisher Configuration Attributes

- **topic:** The name of the topic that message will be sent to. This attribute is **required**.
- **message_name:** The name of the message. Default to publisher class name substracted `Publisher` and underscored. The default message name for `FooUpdatedPublisher` class would be `foo_updated`.
- **version:** Version of the message. Default to `"1.0"`.
- **serializer:** The serializer class which will serialize the given object. The serializer class should respond to `as_json` method like ActiveModelSerializers. Default value for this attribute is, class name without `Publisher` suffix but with `Serializer` suffix. An example default value would be `FooUpdatedSerializer` for `FooUpdatedPublisher` class.


## Consuming messages

After mapping topics with the consumer classes `Hadooken` will call the `perform` method of the provided consumer class with passing **raw json payload** as string parameter. Basic consumer class should look like:

```ruby
class FooConsumer
  def self.perform(payload)
    puts payload
  end
end
```

At this point, you have to parse the json to work with and do your job with the data.
If you've registered to a topic which has different type of messages recognizable by the `name` attribute wrapped into the `meta` attribute then you can do work with the data like so:

```ruby
class ZooConsumer
  def self.perform(payload)
    hash = JSON.parse(payload)

    case hash[:meta][:name]
    when 'lion'
        runaway
    when 'squirrel'
        throw_nut
    else
        end_of_the_world
    end
  end

  ...
end
```

Or you can use extend your classes from **Hadooken::Consumer** class and enjoy!

```ruby
class ZooConsumer < Hadooken::Consumer
  register :lion, :runaway
  register :squirrel, :throw_nut

  ...
end
```

If you extend your consumer classes from **Hadooken::Consumer** class, you will be able to access the `data` via `data` instance variable same thing applies for the `meta`.

You can also use `callback` support of **Hadooken::Consumer** class like so:

```ruby
class ZooConsumer < Hadooken::Consumer
  register :lion, :runaway
  register :squirrel, :throw_nut
  register_rest :unknown_handler

  before_consume :tie_shoelaces, only: :lion
  before_consume :prepare_camera, except: :lion

  ...
end
```

For more information about the consumer and it's API please have a look at the `lib/hadooken/consumer.rb`.

## Testing

Hadooken provides test helpers for RSpec and uses noop No-op kafka client if you require `hadooken/test` or `hadooken/test/rspec` which means, the messages won't go to Kafka instances but rather stays in in-memory queue.
If you require RSpec helpers, you can use the following test helpers;

- **have_version:** Tests if the version of the published message is correct. An example usage of the test helper would be; `it { is_expected.to have_version("1.0") }`
- **have_name:** Tests if the name of the published message is correct. An example usage of the test helper would be; `it { is_expected.to have_name("expected_name") }`
- **be_delivered_to:** Tests if the topic of the published message is correct. An example usage of the test helper would be; `it { is_expected.to be_delivered_to("expected_topic") }`
- **have_schema:** Tests if the schema of the published message is correct. By default, Hadooken assumes the schema files are located under `spec/fixtures/schemas` directory and uses the given schema name to find the correct file.
You can change it by setting the schema_path configuration like so; `Hadooken.configuration.test[:schema_path] = "..."`. An example usage of the test helper would be; `it { is_expected.to have_schema("schema.json") }`.


## TODOS

- In cluster mode with multiple workers if one of the topics you've registered has just one partition this will crash the entire worker. Not the entire cluster but this should be fixed.
- Consumer constantization should be done in one place(while booting), for now we are doing this whenever we need, does not effect the performance of consumers that bad though.
- In cluster mode, send consumer data just once.
- Write unit test(In progress)
