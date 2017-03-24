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

- **group_name<String>:**         Name of the consumer group(Same group always read from same partition).
- **daemon<Boolean>:**            To run as daemon.
- **environment<String|Symbol>:** Environment to run.
- **logfile<String>:**            Location of the log file. Required if daemon is true.
- **pidfile<String>:**            Location of the pid file. Required if daemon is true.
- **workers<Integer>:**           Number of processes hadooken will use.
- **threads<Integer>:**           Number of threads hadooken will spawn for each worker.
- **topics<Dictionary>:**
  - **key:**                      Name of the topic you want to register.
  - **value:**                    Name of the class which will handle incoming messages.
- **kafka<Dictionary>:**
  - **brokers:**                  An array of brookers list.
- **require_env<String>:**        Custom path to require.
- **heartbeat<Dictionary>:**
  - **topic:**                    The name of the topic that heartbeat messages will be published
  - **frequency:**                Publish frequency

Also you can configure hadooken via ruby script! Create a file under initializerz directory of rails and fill it like so:

```ruby
  require 'hadooken'

  Hadooken.configure do |c|
    c.error_capturer = -> (e) { puts e.class }
    c.heartbeat      = { topic: :consumer_heartbeat, frequency: 0.1 }
    c.logfile        = 'tmp/hadooken.log'
    c.pidfile        = 'tmp/hadooken.pid'
    c.daemon         = true
  end
```
