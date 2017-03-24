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

Beside of these options there are other aditional options you can provide through configuration file. For these options please refer to `config.example.yml`.
