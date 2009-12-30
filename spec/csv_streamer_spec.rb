require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'csv_streamer'
describe CsvStreamer do
  describe "with a block" do
    UTF_8_ICONV = Iconv.new('UTF-8', 'UTF-16LE' )
    before do
      @model_class = Object.new
      stub(@model_class).all {@ids.collect {|id| OpenStruct.new(:value=>id)} }
      stub(@model_class).properties {[OpenStruct.new(:name=>:value)]}
      @ids = [1,4,5]
    end
    it "should apply the block on each model element" do
      streamer = CsvStreamer.new(@model_class, @ids){|elem| OpenStruct.new(:value => elem.value + 1)}
      elements = streamer.collect {|elem| UTF_8_ICONV.iconv(elem).strip.to_i}[2..-1]
      elements.should == [2,5,6]
    end
    it "should apply filtermapping blocks on model elements" do
      filter_mappings = {:value => '|val| val + 1'}
      streamer = CsvStreamer.new(@model_class, @ids, nil, 100, filter_mappings)
      elements = streamer.collect {|elem| UTF_8_ICONV.iconv(elem).strip.to_i}[2..-1]
      elements.should == [2,5,6]
    end
  end
end

