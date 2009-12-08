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
      @csv_streamer = CsvStreamer.new(@model_class, @ids){|elem| OpenStruct.new(:value => elem.value + 1)}
    end
    it "should apply the block on each model element" do
      elements = @csv_streamer.collect {|elem| UTF_8_ICONV.iconv(elem).strip.to_i}[2..-1]
      elements.should == [2,5,6]
    end
  end

end

