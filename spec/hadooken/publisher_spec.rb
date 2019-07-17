require "spec_helper"

class FooBarPublisher < Hadooken::Publisher; end
class FooBarSerializer
  attr_reader :object

  def initialize(object)
    @object = object
  end

  def as_json
    object
  end
end
class SpecifiedSerializerClass; end

describe Hadooken::Publisher do
  describe "::version" do
    subject { FooBarPublisher.version }

    context "when the version is not specified" do
      it { is_expected.to eql("1.0") }
    end

    context "when the version is specified" do
      let(:specified_version) { "1.1" }

      before { FooBarPublisher.version = specified_version }

      it { is_expected.to eql(specified_version) }
    end
  end

  describe "::message_name" do
    let(:publisher_options) { {} }

    subject { FooBarPublisher.new(nil, publisher_options).send(:message_name) }

    context "when the message_name is not specified" do
      let(:inferred_message_name) { "foo_bar" }

      it { is_expected.to eql(inferred_message_name) }
    end

    context "when the message_name is specified" do
      context "when the message_name responds to `call` messages" do
        let(:message_name_from_options) { "message-name-from-options" }
        let(:publisher_options) { { message_name: message_name_from_options } }
        let(:specified_message_name) { Proc.new { options[:message_name] } }

        before { FooBarPublisher.message_name = specified_message_name }

        it { is_expected.to eql(message_name_from_options) }
      end

      context "when the message_name does not respond to `call` messages" do
        let(:specified_message_name) { "test-message" }

        before { FooBarPublisher.message_name = specified_message_name }

        it { is_expected.to eql(specified_message_name) }
      end
    end
  end

  describe "::serializer" do
    subject { FooBarPublisher.serializer }

    context "when the serializer is not specified" do
      let(:inferred_serializer) { FooBarSerializer }

      it { is_expected.to eql(inferred_serializer) }
    end

    context "when the serializer is specified" do
      before { FooBarPublisher.serializer = SpecifiedSerializerClass }

      it { is_expected.to eql(SpecifiedSerializerClass) }
    end
  end

  describe "::topic" do
    let(:publisher_options) { {} }

    subject { FooBarPublisher.new(nil, publisher_options).send(:topic) }

    context "when the topic is not specified" do
      it "raises exception" do
        expect { subject }.to raise_error(Hadooken::Errors::MissingTopic)
      end
    end

    context "when the topic is specified" do
      context "when the topic responds to `call` messages" do
        let(:topic_name_from_options) { "topic-name-from-options" }
        let(:publisher_options) { { topic: topic_name_from_options } }
        let(:specified_topic) { Proc.new { options[:topic] } }

        before { FooBarPublisher.topic = specified_topic }

        it { is_expected.to eql(topic_name_from_options) }
      end

      context "when the topic does not respond to `call` messages" do
        let(:specified_topic) { "topic" }

        before { FooBarPublisher.topic = specified_topic }

        it { is_expected.to eql(specified_topic) }
      end
    end
  end

  describe "::publish" do
    subject { FooBarPublisher.publish("message") }

    let(:expected_version) { "1.0" }
    let(:expected_name) { "foo-message" }
    let(:expected_topic) { "foo-topic" }

    before do
      FooBarPublisher.serializer = FooBarSerializer
      FooBarPublisher.version = expected_version
      FooBarPublisher.message_name = expected_name
      FooBarPublisher.topic = expected_topic
    end

    it { is_expected.to have_version(expected_version) }
    it { is_expected.to have_name(expected_name) }
    it { is_expected.to be_delivered_to(expected_topic) }
    it { is_expected.to have_schema("test_publisher") }
  end
end
