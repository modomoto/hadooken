require 'hadooken'
require "rspec/expectations"
require "json-schema"
require "hadooken/test"

RSpec::Matchers.define :create_topic_named do |expected|
  match do |topic|
    topic.name == expected
  end
end

RSpec::Matchers.define :have_version do |expected|
  match do |envelope|
    envelope.version == expected
  end
end

RSpec::Matchers.define :have_name do |expected|
  match do |envelope|
    envelope.message_name == expected
  end
end

RSpec::Matchers.define :be_delivered_to do |expected|
  match do |envelope|
    envelope.topic == expected
  end
end

RSpec::Matchers.define :have_schema do |schema|
  match do |envelope|
    schema_file = "#{schema}.json"
    schema_path = File.expand_path([Hadooken.configuration.test[:schema_path], schema_file].join("/"))
    JSON::Validator.validate!(schema_path, envelope.data_as_json, strict: true)
  end
end

Hadooken.configuration.test[:schema_path] = File.expand_path([caller_locations[1].path, "..", "fixtures", "schemas"].join("/"))
