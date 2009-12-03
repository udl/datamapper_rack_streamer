require 'datamapper'
#DataMapper::Logger.new(STDOUT, :debug)
DataMapper.setup(:products, 'sqlite3::memory:')
require 'lib/streamer_app'
run StreamerApp