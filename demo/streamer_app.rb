require 'sinatra'
require 'haml'
require 'model/shop'
require 'model/product'
require File.dirname(__FILE__)+'/../lib/csv_streamer'
require File.dirname(__FILE__)+'/../lib/json_streamer'

PATH_TO_HAML = File.expand_path(File.dirname(__FILE__)+'/demo.haml')

class StreamerApp < Sinatra::Base

  get '/demo/:shop_id/products.:format/?' do |shop_id, format|
    ids = repository(:products).adapter.query('SELECT id FROM products WHERE shop_id = ?', shop_id.to_i)
    page_size = params[:page_size].to_i
    if (format == 'csv')
      [200, {'content-type' => 'text/csv'}, CsvStreamer.new(Product,ids,nil,page_size)]
    elsif (format == 'json')
      [200, {'content-type' => 'application/json'}, JsonStreamer.new(Product,ids, page_size)]
    else
      halt 415, "Supported Types are CSV and JSON."
    end
  end
  get '/demo/?' do
    engine = Haml::Engine.new(File.read(PATH_TO_HAML))
    engine.render
  end
end
