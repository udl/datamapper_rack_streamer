require 'dm-core'
require File.dirname(__FILE__)+'/product'
class Shop
  include DataMapper::Resource
  def self.default_repository_name
    :products
  end

  property :id, Serial
  property :name, String, :length => 100

  # On delete no action / restrict
  # On update cascade
  has n, :products, :constraint => :protect
end