require "spec_helper"

describe Hadooken do
  describe "::VERSION" do
    it "has a version number" do
      expect(Hadooken::VERSION).not_to be nil
    end
  end
end
