require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'json_streamer'
require 'demo/model/product'

describe JsonStreamer do
  describe "with a provided header and footer" do
    before do
      @model_class = Product
      Product.create(:id => 1, :title => "Hans1", :shop_id => 1)
      Product.create(:id => 4, :title => "Hans4", :shop_id => 1)
      Product.create(:id => 5, :title => "Hans5", :shop_id => 1)
      @ids = Product.all.map{|p| p.id}
      @header = '{"items": '
      @footer = '}'
    end
    it "should apply the header and footer to the response" do
      streamer = JsonStreamer.new(Product, @ids, 1, @header, @footer)
      result_string = streamer.inject("") do |strg,elem|
        strg = strg + elem
      end
      result_string.should == @header + Product.all.to_json + @footer
      JSON.parse(result_string)
    end
  end
end