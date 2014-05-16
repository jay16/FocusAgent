require "rubygems"

ENV["APP_NAME"] ||= "focus_mail_agent"
ENV["RACK_ENV"] ||= "development"

begin
  ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../../Gemfile", __FILE__) 
  require "rake"
  require "bundler"
  Bundler.setup
rescue => e
  puts e.backtrace &&  exit
end
Bundler.require(:default, ENV["RACK_ENV"])

ENV["APP_ROOT_PATH"] = File.expand_path("../../", __FILE__)
ENV["VIEW_PATH"] = File.join(ENV["APP_ROOT_PATH"], "app/views")

# 扩充require路径数组
# require 文件时会在$:数组中查找是否存在
$:.unshift(File.join(ENV["APP_ROOT_PATH"],"config"))
$:.unshift(File.join(ENV["APP_ROOT_PATH"],"lib/tasks"))
%w(controllers helpers models).each do |path|
  $:.unshift(File.join(ENV["APP_ROOT_PATH"],"app",path))
end

# config文夹下为配置信息优先加载
# modle信息已在asset-hanler中加载
# asset-hanel嵌入在application_controller
require "asset-handler"
require "form-helpers"

controllers = %w(application open) 
# helper在controller中被调用，优先于controller
controllers.each { |part| require "#{part}_helper" }
# controller,基类application_controller.rb
# application_controller.rb最先被引用
controllers.each { |part| require "#{part}_controller" }

ENV["OS_PLATFORM"] = `uname -s`.to_s.strip
ENV["OS_HOSTNAME"] = `hostname`.to_s.strip

script_path = File.join(ENV["APP_ROOT_PATH"],"lib/script")
system "nohup ruby #{File.join(script_path,'agent_wget.rb')} &"
system "nohup ruby #{File.join(script_path,'agent_mv2wait.rb')} #{Settings.mailgates.speed} #{Settings.mailgates.wait_path} &"
