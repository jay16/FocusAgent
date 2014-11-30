root_path = File.dirname(File.dirname(__FILE__))#File.expand_path("../../", __FILE__)
ENV["APP_NAME"]  ||= "focus_mail_agent"
ENV["RACK_ENV"]  ||= "development"
ENV["ASSET_CDN"] ||= "false"
ENV["VIEW_PATH"]  = "%s/app/views" % root_path
ENV["APP_ROOT_PATH"] = root_path

begin
  ENV["BUNDLE_GEMFILE"] ||= "%s/Gemfile" % root_path
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
if whoami == "root"
  system("chown -R nobody:nobody #{root_path} && chmod -R 777 #{root_path}")
else
  warn "warning: [#{whoami}] can't execute chown/chmod"
end

# 扩充require路径数组
# require 文件时会在$:数组中查找是否存在
puts root_path
$:.unshift(root_path)
$:.unshift("%s/config" % root_path)
$:.unshift("%s/lib/tasks" % root_path) 
%w(controllers helpers models).each do |path|
  $:.unshift("%s/app/%s" % [root_path, path])
end
require "setting.rb"

require "lib/utils/boot.rb"
include Utils::Boot

# expand Module methods
recursion_require("lib/utils/core_ext", /\.rb$/, root_path)

# config文夹下为配置信息优先加载
# modle信息已在asset-hanler中加载
# asset-hanel嵌入在application_controller
require "asset-handler"
require "form-helpers"
# base on model ActionLog

# helper will include into controller
# helper load before controller
recursion_require("app/helpers", /_helper\.rb$/, root_path)
recursion_require("app/controllers", /_controller\.rb$/, root_path, [/^application_/])

# expand env variables
ENV["OS_PLATFORM"] = `test -f /etc/issue && cat /etc/issue | head -n 1 || uname -s`.to_s.strip
ENV["OS_HOSTNAME"] = `hostname`.to_s.strip
# make sure source files privilege
`chown -R #{Setting.mailgates.user}:#{Setting.mailgates.group} #{root_path}`
`chmod -R #{Setting.mailgates.mode} #{root_path}`

def kill_agent_process_if_exist(script_file, pid_file)
  if File.exist?(pid_file) and !(lines = IO.readlines(pid_file)).empty?
    pid = lines[0].strip
    ps = "ps aux | grep #{pid} | grep -v 'grep'"
    puts "execute shell - #{ps}"
    status, *result = run_command(ps)
    if status and result.join.include?(script_file)
      `kill -9 #{pid}`
      status, *result = run_command(ps)
      puts "kill -9 #{pid} " + (result.empty? ?  "successfully!" : "failure!")
    end
  end
end

tmp_path    = "%s/tmp" % root_path
script_path = "%s/lib/script" % root_path
%w(agent_wget agent_mv2wait).each do |p|
  script_file = File.join(script_path, [p, "rb"].join("."))
  pid_file    = File.join(tmp_path, [p, "pid"].join("."))

  # kill exist old agent process 
  # before startup new agent process
  kill_agent_process_if_exist(script_file, pid_file)
end

# run this then startup successfully
# record start log in log/startup.log
ENV["DATE_STARTUP"] = Time.now.to_i.to_s #strftime("%Y-%m-%d %H:%M:%S")
tmp_title = "timestamp, action, plantform, hostname"
tmp_str   = [ENV["DATE_STARTUP"], "start", ENV["OS_PLATFORM"], ENV["OS_HOSTNAME"]].join(", ")
startup_log = "log/startup.log"
`cd #{root_path} && test -f #{startup_log} || echo "#{tmp_title}" > #{startup_log}`
`cd #{root_path} && echo "#{tmp_str}" >> #{startup_log}`

#$# catch sinatra shutdown
#$threads = Array.new()
#$threads << Thread.new { ApplicationController.run! }
#$threads << Thread.new {
#$  sleep 1 until ApplicationController.running?
#$  trap("INT") do 
#$    puts "trapped in subthread"; 
#$    tmp_str   = [Time.now.strftime("%Y-%m-%d %H:%M:%S"), "stop", ENV["OS_PLATFORM"], ENV["OS_HOSTNAME"]].join(", ")
#$    `cd #{root_path} && echo "#{tmp_str}" >> #{startup_log}`
#$    exit
#$  end
#$  puts "ok, trap registered"
#$}
#$threads.each do |thread|
#$  thread.join
#$end
