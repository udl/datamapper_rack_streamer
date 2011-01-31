source :rubygems

gem "datamapper", "1.0.0"
gem "dm-sqlite-adapter", "1.0.0"
gem "rack", "1.2.1"

group :test do
  gem "rr", "1.0.2"
  gem "rspec", "2.4.0"
  gem "rack-test", "0.5.4"
  gem "sinatra", "1.0"
  gem "haml", "3.0.13"
  gem "ZenTest", "4.3.3"
  if RUBY_PLATFORM =~ /darwin/
    gem "autotest-growl", "0.2.4"
    gem "autotest-fsevent", "0.2.2"
  end
end

group :ci do
  gem "ci_reporter", "1.6.2"
end
