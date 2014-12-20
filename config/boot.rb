app_root_path = File.dirname(File.dirname(__FILE__))#File.expand_path("../../", __FILE__)
ENV["APP_NAME"]  ||= "focus_mail_agent"
ENV["RACK_ENV"]  ||= "development"
ENV["ASSET_CDN"] ||= "false"
ENV["VIEW_PATH"]  = "%s/app/views" % app_root_path
ENV["APP_ROOT_PATH"] = app_root_path

begin
  ENV["BUNDLE_GEMFILE"] ||= "%s/Gemfile" % app_root_path
  require "rake"
  require "bundler"
  Bundler.setup
rescue => e
  puts e.backtrace &&  exit
end
Bundler.require(:default, ENV["RACK_ENV"])

# execute linux shell command
# return array with command result
# [execute status, execute result] 
def run_command(cmd)
  IO.popen(cmd) do |stdout|
    stdout.reject(&:empty?)
  end.unshift($?.exitstatus.zero?)
end 

status, *result = run_command("whoami")
whoami = result[0].strip 
if whoami != "webmail"
  warn "\n\t[warning] user [#{whoami}] start up web server.\n"
end

# 扩充require路径数组
# require 文件时会在$:数组中查找是否存在
$:.unshift(app_root_path)
$:.unshift("%s/config" % app_root_path)
$:.unshift("%s/lib/tasks" % app_root_path) 
%w(controllers helpers models).each do |path|
  $:.unshift("%s/app/%s" % [app_root_path, path])
end
require "setting.rb"

require "lib/utils/boot.rb"
include Utils::Boot

# expand Module methods
recursion_require("lib/utils/core_ext", /\.rb$/, app_root_path)

# config文夹下为配置信息优先加载
# modle信息已在asset-hanler中加载
# asset-hanel嵌入在application_controller
require "asset-handler"
require "form-helpers"
# base on model ActionLog

# helper will include into controller
# helper load before controller
recursion_require("app/helpers", /_helper\.rb$/, app_root_path)
recursion_require("app/controllers", /_controller\.rb$/, app_root_path, [/^application_/])

# expand env variables
ENV["OS_PLATFORM"] = `test -f /etc/issue && cat /etc/issue | head -n 1 || uname -s`.to_s.strip
ENV["OS_HOSTNAME"] = `hostname`.to_s.strip
# make sure source files privilege
#`chown -R #{Setting.mailgates.user}:#{Setting.mailgates.group} #{app_root_path}`
#`chmod -R #{Setting.mailgates.mode} #{app_root_path}`

# basc tmp direcotry
`cd #{app_root_path} && mkdir -p ./{log,tmp/pids}`
`cd #{app_root_path} && echo "#{app_root_path}" > tmp/app_root_path`
pool_wait_path = File.join(app_root_path, Setting.pool.wait)
`cd #{app_root_path} && echo "#{pool_wait_path}" > tmp/pool_wait_path`

# run this then startup successfully
# record start log in log/startup.log
ENV["DATE_STARTUP"] = Time.now.to_i.to_s #strftime("%Y-%m-%d %H:%M:%S")
tmp_title = "timestamp, action, plantform, hostname"
tmp_str   = [ENV["DATE_STARTUP"], "start", ENV["OS_PLATFORM"], ENV["OS_HOSTNAME"]].join(", ")
startup_log = "log/startup.log"
`cd #{app_root_path} && test -f #{startup_log} || echo "#{tmp_title}" > #{startup_log}`
`cd #{app_root_path} && echo "#{tmp_str}" >> #{startup_log}`

#$# catch sinatra shutdown
#$threads = Array.new()
#$threads << Thread.new { ApplicationController.run! }
#$threads << Thread.new {
#$  sleep 1 until ApplicationController.running?
#$  trap("INT") do 
#$    puts "trapped in subthread"; 
#$    tmp_str   = [Time.now.strftime("%Y-%m-%d %H:%M:%S"), "stop", ENV["OS_PLATFORM"], ENV["OS_HOSTNAME"]].join(", ")
#$    `cd #{app_root_path} && echo "#{tmp_str}" >> #{startup_log}`
#$    exit
#$  end
#$  puts "ok, trap registered"
#$}
#$threads.each do |thread|
#$  thread.join
#$end
