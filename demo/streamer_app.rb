require 'sinatra'
require 'haml'
require 'model/shop'
require 'model/product'
require File.dirname(__FILE__)+'/../lib/csv_streamer'

PATH_TO_HAML = File.expand_path(File.dirname(__FILE__)+'/demo.haml')

class StreamerApp < Sinatra::Base
 
  get %r{/demo/(\d+)/products.csv} do |shop_id|
    ids = repository(:products).adapter.query('SELECT id FROM products WHERE shop_id = ?', shop_id.to_i)
    [200, {'Content-Type' => 'text/csv'}, CsvStreamer.new(Product,ids)]
  end
  get '/demo/?' do
    engine = Haml::Engine.new(File.read(PATH_TO_HAML))
    engine.render
  end
end
