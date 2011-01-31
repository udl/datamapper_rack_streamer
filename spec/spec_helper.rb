$LOAD_PATH << File.dirname(__FILE__)+'/../lib/'
$LOAD_PATH << File.dirname(__FILE__)+'/../'
require "rspec" # Satisfies Autotest and anyone else not using the Rake tasks
require 'rr'
require 'datamapper'
require 'ostruct'
require 'pp'
require 'demo/model/shop'
require 'demo/model/product'

DataMapper::Logger.new(STDOUT, :debug)
DataMapper.setup(:products, 'sqlite3::memory:')
Shop.auto_migrate!
Product.auto_migrate!

RSpec.configure do |config|
 config.mock_with :rr
  config.after(:each) do
    repository(:products) do
      while repository.adapter.current_transaction
        repository.adapter.current_transaction.rollback
        repository.adapter.pop_transaction
      end
    end
  end

  config.before(:each) do
    repository(:products) do
      transaction = DataMapper::Transaction.new(repository)
      transaction.begin
      repository.adapter.push_transaction(transaction)
    end
  end

end