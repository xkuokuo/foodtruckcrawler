require 'pry'
require 'json'
require 'simple_file_aggregator'

RSpec.describe SimpleFileAggregator, "#start" do
  context "Given a vaid non-exist filename" do
    it "should create the file" do
      file_name = "dummy_file.txt"
      aggregator = SimpleFileAggregator.new(file_name)
      expect(File.exist?(file_name)).to eq true
    end
  end
end

RSpec.describe SimpleFileAggregator, "#start" do
  context "Given a vaid non-exist filename, and a obj" do
    it "should create the file and write to the file" do
      file_name = "dummy_file.txt"
      obj = "dummy"
      aggregator = SimpleFileAggregator.new(file_name)
      aggregator.aggregate("dummy")

      test = ''
      File.open(file_name) { |f|
        f.each_line  { |line|
          test = test + line
        }
      }
      expect(test.strip).to eq(obj.to_json)
    end
  end
end
