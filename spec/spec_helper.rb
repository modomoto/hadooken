$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "hadooken"
require "hadooken/test/rspec"

Dir["#{File.dirname(__FILE__)}/fixtures/*.rb"].each   {|f| require f }
