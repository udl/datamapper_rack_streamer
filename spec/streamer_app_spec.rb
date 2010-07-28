require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'streamer_app'  # <-- your sinatra app
require 'spec'
require 'rack/test'
require 'rr'
require 'iconv'
require 'utf_16_bom'

set :environment, :test
require 'streamer_app'

describe StreamerApp do
  include Rack::Test::Methods

  def app
    StreamerApp
  end

  before do
    @shops = [Shop.create(:name=>'shop'),Shop.create(:name=>'shop2')]
    @shop = @shops.first
    @products = [1,2,5].collect do |num|
      Product.create(:shop => @shop,
        :id => num,
        :title => "title #{num}",
        :description => "description #{num}",
        :price => num*100
      )
    end
    csv_sequence = CsvStreamer.csv_sequence(Product)
    p csv_sequence
    rows = ([csv_sequence] + @products.collect do |product|
      csv_sequence.collect do |field|
        product.send(field)
      end
    end)
    p rows
    @csv = rows.collect {|values| values.join(CsvStreamer::COLUMN_SEPARATOR)}.join(CsvStreamer::ROW_SEPARATOR)+CsvStreamer::ROW_SEPARATOR
  utf_16_le_iconv = Iconv.new('UTF-16LE', 'UTF-8')
  @csv =  utf16le_bom + utf_16_le_iconv.iconv(@csv)
  @json = Product.all.to_json
  end

  ["csv", "json"].each do |format|
    it "should respond to URLs like /demo/$/products.#{format}" do
      get "/demo/1/products.#{format}"
      last_response.should be_ok
    end
  end

  it "should return csv for all products of the shop" do
     get '/demo/1/products.csv'
     last_response.body.should == @csv
     last_response.content_type.should == 'text/csv'
  end

  it "should return json for all products of the shop" do
     get '/demo/1/products.json'
     last_response.body.should == @json
     last_response.content_type.should == 'application/json'
  end

  it "should return json for all products of the shop and user defined page sizes" do
    -1.upto(4) do |i|
      get "/demo/1/products.json?page_size=#{i}"
      last_response.body.should == @json
      last_response.content_type.should == 'application/json'
    end
  end

  it "should return a BOM and one BOM only" do
    get '/demo/1/products.csv'
    last_response.body.should include(utf16le_bom)
    last_response.body.should_not include(utf16le_bom + utf16le_bom)
  end

  ['/demo', '/demo/'].each do |shop_string|
    it "should list all shops when calling #{shop_string}" do
      get shop_string
      last_response.should be_ok
      @shops.each do |shop|
      last_response.body.should include "<a href='/demo/#{shop.id}/products.csv'>#{shop.name}</a>"
      end
    end
  end
end

