#encoding: utf-8
source "http://ruby.taobao.org"

if defined? Encoding
  Encoding.default_external = Encoding::UTF_8
  Encoding.default_internal = Encoding::UTF_8
end

#sinatra
gem "sinatra"
gem "sinatra-reloader"
gem "sinatra-flash"

#db
#gem "dm-core"
#gem "dm-migrations"
#gem "dm-timestamps"
#gem "dm-sqlite-adapter"

#assets
gem "haml"
gem "sass"
gem "therubyracer"
gem "coffee-script"

gem "passenger"
gem "thin"
gem "rake"
gem "settingslogic"

#代码覆盖率
#rake stats
gem "code_statistics"

group :test do
  gem "rack-test"
  gem "rspec"
  gem "factory_girl"
end
