require 'dm-core'
require 'dm-types'
require File.dirname(__FILE__)+'/shop'
class Product
  include DataMapper::Resource
  def self.default_repository_name
    :products
  end
 
  property :id, Serial
  property :title, String, :length => (1..255), :nullable => false
  property :shop_id, Integer, :nullable => false, :key=>true 
  property :description, Text, :lazy => false
  property :image_url, String, :length => 1000
  property :price, Integer, :min => 1
 
  belongs_to :shop, :constraint => :protect
end

